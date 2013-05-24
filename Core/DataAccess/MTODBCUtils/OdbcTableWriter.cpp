#include "OdbcTableWriter.h"
#include "OdbcException.h"


COdbcTableWriter::~COdbcTableWriter()
{
	while(mColumnMappings.size() > 0)
	{
		delete mColumnMappings.back();
		mColumnMappings.pop_back();
	}

  // This may be called when database connectivity is lost, so
  // reinitialize just in case
  if (mNonTrxConnectionCommand.get() != 0)
    mOdbcManager->Reinitialize(mNonTrxConnectionCommand);
}

COdbcTableWriter::COdbcTableWriter(
								 	MTPipelineLib::IMTLogPtr aLogger,
									MTPipelineLib::IMTNameIDPtr aNameID)
{
  mLogger = aLogger;
  mNameID = aNameID;
  ColumnMappings v;
  mColumnMappings = v;
}


void COdbcTableWriter::InitializeDatabase(
									const string& aTempTableName, 
									const string& aTempTableFullName,
									const string& aTempTableReCreateDDL,
									const int& aArraySize)
{
	COdbcConnectionInfo stageDBInfo  = COdbcConnectionManager::GetConnectionInfo("NetMeter");
	COdbcConnectionInfo stageDBEntry = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
    stageDBInfo.SetCatalog(stageDBEntry.GetCatalog().c_str());

	COdbcConnectionInfo netmeterDBInfo  = COdbcConnectionManager::GetConnectionInfo("NetMeter");

	mIsOracle = (netmeterDBInfo.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);
	
	// use auto commit only if using bcp
	mUseBcpFlag = !mIsOracle;

	if (true)//!IsOracle())
	{
    COdbcConnectionPtr conn(new COdbcConnection(stageDBInfo));
		COdbcStatementPtr createTempTable = conn->CreateStatement();
		createTempTable->ExecuteUpdate(aTempTableReCreateDDL);
		conn->CommitTransaction();
	}

  if (mTempTableName != aTempTableName ||
      mTempTableFullName != aTempTableFullName ||
      mArraySize != aArraySize)
  {
    mTempTableName = aTempTableName;
    mTempTableFullName = aTempTableFullName;
    mArraySize = aArraySize;

    std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpStatements;
    std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayStatements;
    std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertStatements;
    if (mUseBcpFlag)
    {
      COdbcBcpHints hints;
      // use minimally logged inserts.
      // TODO: this may only matter if database recovery model settings are correct.
      //       however, it won't hurt if they're not
      hints.SetMinimallyLogged(true);
      mBcpInsertToTmpTableStmtCommand = boost::shared_ptr<COdbcPreparedBcpStatementCommand>(
        new COdbcPreparedBcpStatementCommand(mTempTableName, hints));
      bcpStatements.push_back(mBcpInsertToTmpTableStmtCommand);
    }
    else
    {
      mArrayInsertToTmpTableStmtCommand = boost::shared_ptr<COdbcPreparedInsertStatementCommand>(
        new COdbcPreparedInsertStatementCommand(mTempTableName, mArraySize, true));
      insertStatements.push_back(mArrayInsertToTmpTableStmtCommand);
    }


    mTrxConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
      new COdbcConnectionCommand(netmeterDBInfo, COdbcConnectionCommand::TXN_AUTO, false));
    mOdbcManager->RegisterResourceTree(mTrxConnectionCommand);

    mNonTrxConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
      new COdbcConnectionCommand(stageDBInfo,
                                 COdbcConnectionCommand::TXN_AUTO,
                                 bcpStatements.size() > 0,
                                 bcpStatements,
                                 arrayStatements,
                                 insertStatements));

    mOdbcManager->RegisterResourceTree(mNonTrxConnectionCommand);
  }
}

void COdbcTableWriter::AddTempTableColumnMapping(int aColumnOffset, 
																	MTPipelineLib::MTSessionPropType aSessionPropertyType, 
																	string& aSessionPropertyName,
																	bool aRequired)
{
	//ODBC columns start at 1, vector starts at 0
  AddTempTableColumnMapping(aColumnOffset, aSessionPropertyType, mNameID->GetNameID(aSessionPropertyName.c_str()), aRequired);
}

void COdbcTableWriter::AddTempTableColumnMapping(int aColumnOffset, 
																	MTPipelineLib::MTSessionPropType aSessionPropertyType, 
																	long aSessionPropertyID,
																	bool aRequired)
{
	//ODBC columns start at 1, vector starts at 0
	ASSERT(aColumnOffset > 0);
    if(aColumnOffset == 1) 
	  MT_THROW_COM_ERROR("Offset of 1 is reserved for RequestID");

	int idx = aColumnOffset - 1;

	mColumnMappings.push_back(new COdbcTempTableMapping(aColumnOffset, aSessionPropertyType, 
														aSessionPropertyID, aRequired)
                              );
											
}

void COdbcTableWriter::InitializeFromSessionSet(MTPipelineLib::IMTSessionSetPtr aSessionSetPtr)
{
  ITransactionPtr itrans = NULL;

	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSessionSetPtr);
	if (FAILED(hr))
		return MT_THROW_COM_ERROR(hr);
	
	mSessionArray.clear();

	MTPipelineLib::IMTTransactionPtr transaction;
	mTransaction = NULL;
	bool first = true;

	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;
		
		if (first)
		{
			first = false;
			transaction = GetTransaction(session);
      mMTTransaction = transaction;

			if (transaction != NULL)
			{
				itrans = transaction->GetTransaction();
				ASSERT(itrans != NULL);
        mTransaction = itrans;
			}
		}

		mSessionArray.push_back(session);
		
	}

  //fix later for multiple inserts
  ASSERT(mSessionArray.size() <= (unsigned int)mArraySize);

}

void COdbcTableWriter::InsertIntoTempTable()
{
  try
  {
    COdbcConnectionHandle nonTrxConnection(mOdbcManager, mNonTrxConnectionCommand);

	  TruncateTempTable(nonTrxConnection);
      if (mUseBcpFlag)
		  InsertInternal(nonTrxConnection[mBcpInsertToTmpTableStmtCommand], nonTrxConnection);
	  else
		  InsertInternal(nonTrxConnection[mArrayInsertToTmpTableStmtCommand], nonTrxConnection);
  }
  catch(...)
  {
	  mSessionArray.clear();
    throw;
  }
  
}

void COdbcTableWriter::TruncateTempTable(COdbcConnectionHandle & nonTrxConnection)
{
	COdbcStatementPtr truncate = nonTrxConnection->CreateStatement();
	int numRows = truncate->ExecuteUpdate("truncate table " + mTempTableFullName);
	nonTrxConnection->CommitTransaction();
}

template <class T>
void COdbcTableWriter::InsertInternal(T arStatement, COdbcConnectionHandle & nonTrxConnection)
{
  bool bSessionsFailed = false;

	for(unsigned int i=0; i<mSessionArray.size(); i++)
	{
		MTPipelineLib::IMTSessionPtr session = mSessionArray[i];
    //skip sessions that have already been marked as failed by a plugin
    if(session->CompoundMarkedAsFailed == VARIANT_TRUE)
    {
      bSessionsFailed = true;
      continue;
    }

		// First column is always request ID
		arStatement->SetInteger(1, (long) i);
    unsigned int size = mColumnMappings.size();
		for(unsigned int j=0; j<size; j++)
		{ 
      try
      {
  			SetPipelineProperty(session, mColumnMappings[j], arStatement);
      }
      catch (_com_error& err)
      {
        if (err.Error() == PIPE_ERR_SUBSET_OF_BATCH_FAILED)
          bSessionsFailed = true;
        else
        {
          arStatement->ExecuteBatch();
          throw;
        }
      }
      catch (...)
      {
        arStatement->ExecuteBatch();
      }
		}

    // Once we have a failed session there is no point in adding
    // things to the batch.  We still want to process all the sessions
    // to identify any additional sessions that are bad.
    if (!bSessionsFailed)
      arStatement->AddBatch();
	}

 	arStatement->ExecuteBatch();
    nonTrxConnection->CommitTransaction();

 if (bSessionsFailed)
    MT_THROW_COM_ERROR(PIPE_ERR_SUBSET_OF_BATCH_FAILED);
}

void COdbcTableWriter::ExecuteRowsetSelectInDistributedTransaction(ROWSETLib::IMTSQLRowsetPtr& rs)
{
  if(mMTTransaction != NULL)
  {
    rs->JoinDistributedTransaction(reinterpret_cast<ROWSETLib::IMTTransaction*>(mMTTransaction.GetInterfacePtr()));
    rs->Execute();
    rs->JoinDistributedTransaction(NULL);
  }
  else
    rs->Execute();
}

ROWSETLib::IMTSQLRowset* COdbcTableWriter::ExecuteRowsetSelectInDistributedTransaction(const char* qstring)
{
  ROWSETLib::IMTSQLRowsetPtr rs;
  HRESULT hr = rs.CreateInstance(MTPROGID_SQLROWSET);
  if(FAILED(hr)) MT_THROW_COM_ERROR(hr);
  //init from account creation dir only because rs needs to be oledb
  rs->Init("queries\\AccountCreation");
  rs->SetQueryString(qstring);
  ExecuteRowsetSelectInDistributedTransaction(rs);
  return rs.GetInterfacePtr();
}

COdbcPreparedResultSetPtr COdbcTableWriter::ExecuteOdbcSelectInDistributedTransaction(const char* qstring)
{
  COdbcConnectionHandle trxConnection(mOdbcManager, mTrxConnectionCommand);
  COdbcPreparedArrayStatementPtr stmt = trxConnection->PrepareStatement(qstring);
  COdbcPreparedResultSetPtr resultSet = NULL;
  if(mTransaction != NULL)
  {
    trxConnection->JoinTransaction(mTransaction);
    resultSet = stmt->ExecuteQuery();
    trxConnection->LeaveTransaction();
  }
  else
    resultSet = stmt->ExecuteQuery();
  return resultSet;
}

void COdbcTableWriter::ExecuteInsertInDistributedTransaction(string query)
{
  COdbcConnectionHandle trxConnection(mOdbcManager, mTrxConnectionCommand);
  COdbcStatementPtr stmt = trxConnection->CreateStatement();
  if(mTransaction != NULL)
  {
    trxConnection->JoinTransaction(mTransaction);
    stmt->ExecuteUpdate(query);
    trxConnection->LeaveTransaction();
  }
  else
  {
	stmt->ExecuteUpdate(query);
  }
}



template <class T>
void COdbcTableWriter::SetPipelineProperty(MTPipelineLib::IMTSessionPtr session, COdbcTempTableMapping* apMapping, T & arStatement)
{
	bool required = apMapping->GetRequired();
	//we add 1 because 1 is implicitely reguestid
	int offset = apMapping->GetOffset();
  ASSERT(offset > 1);
	MTPipelineLib::MTSessionPropType type = apMapping->GetPipelinePropType();
  long propid = apMapping->GetPipelinePropID();
	//for logging
  string name = mNameID->GetName(propid);
	if(session->PropertyExists(propid, type) == VARIANT_TRUE)
	{
		_variant_t val;
		switch(type)
		{
			case MTPipelineLib::SESS_PROP_TYPE_STRING:
      {
        val = session->GetStringProperty(propid);
        arStatement->SetWideString(offset, (const wchar_t*)(_bstr_t) val);
        break;
      }
			case MTPipelineLib::SESS_PROP_TYPE_DATE:
			case MTPipelineLib::SESS_PROP_TYPE_TIME:
			{
				TIMESTAMP_STRUCT refTimeStamp;
				_variant_t sessionTimestamp;
				val = session->GetOLEDateProperty(propid);
				DATE pDate = val;
				OLEDateToOdbcTimestamp(&pDate,&refTimeStamp);
        arStatement->SetDatetime(offset, refTimeStamp);
        break;
			}
			case MTPipelineLib::SESS_PROP_TYPE_LONG:
      {
        val = session->GetLongProperty(propid);
        arStatement->SetInteger(offset, (long)val);
        break;
      }
			case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
      {
        val = session->GetLongLongProperty(propid);
        arStatement->SetBigInteger(offset, (__int64)val);
        break;
      }
			case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
      {
        val = session->GetDoubleProperty(propid);
        arStatement->SetDouble(offset, (double)val);
        break;
      }
      case MTPipelineLib::SESS_PROP_TYPE_ENUM:
       {
        val = session->GetEnumProperty(propid);
        arStatement->SetInteger(offset, (long)val);
        break;
      }
			case MTPipelineLib::SESS_PROP_TYPE_BOOL:
      {
        ASSERT(false);
        MT_THROW_COM_ERROR("Unsupported data type: SESS_PROP_TYPE_DECIMAL");
      }
			case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
      {
        ASSERT(false);
        MT_THROW_COM_ERROR("Unsupported data type: SESS_PROP_TYPE_DECIMAL");
      }
		}
	}
  else
  {
    if(required)
    {
      char buf[256];
      sprintf(buf, "Property '%s' is required, but not found in session!", name.c_str());
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buf);
      session->MarkAsFailed(buf, PIPE_ERR_MISSING_PROP_NAME);
      MT_THROW_COM_ERROR(PIPE_ERR_SUBSET_OF_BATCH_FAILED);
    }
    //it shall be NULL then
  }
}


MTPipelineLib::IMTTransactionPtr COdbcTableWriter::GetTransaction(MTPipelineLib::IMTSessionPtr aSession)
{
	MTPipelineLib::IMTTransactionPtr tran = NULL;

	// has a transaction already been started?
	tran = aSession->GetTransaction(VARIANT_FALSE);

	if (tran != NULL)
	{
		// yes
		ITransactionPtr itrans = tran->GetTransaction();
		if (itrans != NULL)
			return tran;
		else
			return NULL;
	}

	// is the transaction ID set in the session?  If so we're working on
	// an external transaction
	_bstr_t txnID = aSession->GetTransactionID();
	if (txnID.length() > 0)
	{
		// join the transaction
		tran = aSession->GetTransaction(VARIANT_TRUE);

		ITransactionPtr itrans = tran->GetTransaction();
		if (itrans != NULL)
			return tran;
		else
			return NULL;
	}

	// no transaction
	return NULL;
}


