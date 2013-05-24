/**************************************************************************
 *
 * Copyright 2004 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 ***************************************************************************/

#include <metra.h>
#include <mttime.h>
#include "BatchAudit.h"

/***************************************************************************
 * PlugInConfigure                                                         *
 ***************************************************************************/
HRESULT CMTBatchAuditPlugin::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
												  MTPipelineLib::IMTConfigPropSetPtr pPropSetPtr,
												  MTPipelineLib::IMTNameIDPtr pNameIDPtr,
												  MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	try
	{
		//-----
		// Declare the list of properties we will read from the XML configuration
		// When ProcessProperties is called, it loads the property Ids into the
		// variable that was passed 
		//-----
		DECLARE_PROPNAME_MAP(inputs)
			DECLARE_PROPNAME("AuditEventID", &m_lAuditEventID)
			DECLARE_PROPNAME("AuditEntityTypeId", &m_lAuditEntityTypeID)
			DECLARE_PROPNAME("AuditEntityId", &m_lAuditEntityID)
			DECLARE_PROPNAME("AuditDetails", &m_lAuditDetailsID)
		END_PROPNAME_MAP

		HRESULT hr = ProcessProperties(inputs, pPropSetPtr, pNameIDPtr, mLogger,
									   "CMTBatchAuditPlugin::PlugInConfigure");
		if (FAILED(hr))
			return hr;

		//----- Get queries used to get/set audit id..
		m_QueryAdapterAC.CreateInstance(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		m_QueryAdapterAC->Init("queries\\AccountCreation");

		m_QueryAdapterPipe.CreateInstance(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		m_QueryAdapterPipe->Init("queries\\Pipeline");

		//----- Is BCP enabled?
		if (pPropSetPtr->NextMatches(L"usebcpflag", MTPipelineLib::PROP_TYPE_BOOLEAN))
			m_bUseBcpFlag = pPropSetPtr->NextBoolWithName(L"usebcpflag") == VARIANT_TRUE;
		else
			m_bUseBcpFlag = true;

		if (IsOracle())
		{
			//----- Never use BCP with Oracle.
			m_bUseBcpFlag = false;
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BCP interface disabled (Oracle detected)");
		}
		else 
		{
			if (m_bUseBcpFlag)
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BCP interface enabled (usebcpflag is TRUE)");
			else
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BCP interface disabled (usebcpflag is FALSE)");
		}

		//----- What is the batch size?
		//----- Allow the user to set size of batches/arrays.
		if (pPropSetPtr->NextMatches(L"batch_size", MTPipelineLib::PROP_TYPE_INTEGER))
			m_uiArraySize = pPropSetPtr->NextLongWithName("batch_size");
		else
			m_uiArraySize = DEFAULT_BCP_BATCH_SIZE;

		char tmpBuf[64];
		sprintf(tmpBuf, "BatchAudit will use a batch size of %d", m_uiArraySize);
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, tmpBuf);

		//----- Create a unique name based on the stage name and plug-in name.
		m_strTagName = GetTagName(aSysContext);

	  //----- Get target table names.
   	COdbcConnectionInfo NetmeterDBInfo = COdbcConnectionManager::GetConnectionInfo("NetMeter");
	  string strAuditTableName = "t_audit";
	  string strAuditDetailsTableName = "t_audit_details";
  
    //----- Generate queries.
    COdbcConnectionInfo stageDBInfo = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
	  NetmeterDBInfo.SetCatalog(stageDBInfo.GetCatalog().c_str());
    GenerateQueries(strAuditTableName, strAuditDetailsTableName, NetmeterDBInfo.GetCatalog().c_str());

    //----- Create temp table.
    if (true)//!IsOracle())
    {
      //----- Make sure our "temporary" table exists and is empty.
      COdbcConnectionPtr stageConnection(new COdbcConnection(NetmeterDBInfo));
      COdbcStatementPtr createTmpTableStmt = stageConnection->CreateStatement();
      createTmpTableStmt->ExecuteUpdate(m_strCreateTempTableSQL);
    }

    std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpStatements;
    std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayStatements;
    std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertStatements;

    //----- Prepare insert query.
    if (m_bUseBcpFlag)
    {
      //-----
      // use minimally logged inserts.
      // TODO: this may only matter if database recovery model settings are correct.
      //       however, it won't hurt if they're not
      //-----
      COdbcBcpHints hints;
      hints.SetMinimallyLogged(true);

      //----- Get object to use for bulk copy.
      m_BcpInsertToTempTableStmtCommand = boost::shared_ptr<COdbcPreparedBcpStatementCommand>(
        new COdbcPreparedBcpStatementCommand(m_strTmpTableName, hints));
      bcpStatements.push_back(m_BcpInsertToTempTableStmtCommand);
    } 

    //----- Get object to use for array insertion.
    else if (IsOracle())
    {
      m_OracleArrayInsertToTempTableStmtCommand = boost::shared_ptr<COdbcPreparedInsertStatementCommand>(
        new COdbcPreparedInsertStatementCommand(m_strTmpTableName, m_uiArraySize, true));
      insertStatements.push_back(m_OracleArrayInsertToTempTableStmtCommand);
    }
    else
    {
      //----- Query used to insert into t_audit table:
      m_QueryAdapterAC->ClearQuery();
      m_QueryAdapterAC->SetQueryTag("__INSERT_INTO_BATCHAUDIT_TEMP_TABLE__");
      m_QueryAdapterAC->AddParam("%%TMP_TABLE_NAME%%", m_strTmpTableFullName.c_str());
      string strInsertToTempTableSQL = m_QueryAdapterAC->GetQuery();
      m_SqlArrayInsertToTempTableStmtCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(
        new COdbcPreparedArrayStatementCommand(strInsertToTempTableSQL, m_uiArraySize, true));
      arrayStatements.push_back(m_SqlArrayInsertToTempTableStmtCommand);
    }

    m_StageDbBcpConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
      new COdbcConnectionCommand(NetmeterDBInfo,
                                 COdbcConnectionCommand::TXN_AUTO,
                                 FALSE==IsOracle(),
                                 bcpStatements,
                                 arrayStatements,
                                 insertStatements));

    m_OdbcManager->RegisterResourceTree(m_StageDbBcpConnectionCommand);
 	}
	catch(_com_error & e)
	{
		char buffer[1024];
		sprintf(buffer, "An exception was thrown while parsing the config file: %x, %s", 
						e.Error(), (const char*) _bstr_t(e.Description()));
		return Error(buffer);
	}

	return S_OK;
}

/***************************************************************************
 * BatchPlugInInitializeDatabase                                           *
 ***************************************************************************/
HRESULT CMTBatchAuditPlugin::BatchPlugInInitializeDatabase()
{
	//----- This plug-in writes to the database so we should not allow retry.
	AllowRetryOnDatabaseFailure(FALSE);

	return S_OK;
}

/***************************************************************************
 * BatchPlugInShutdownDatabase                                             *
 ***************************************************************************/
HRESULT CMTBatchAuditPlugin::BatchPlugInShutdownDatabase()
{
  m_OdbcManager->Reinitialize(m_StageDbBcpConnectionCommand);
  //----- Done.
	return S_OK;
}

/***************************************************************************
 * BatchPlugInProcessSessions                                              *
 ***************************************************************************/
HRESULT CMTBatchAuditPlugin::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr pSessionSetPtr)
{
  COdbcConnectionHandle stageConnection(m_OdbcManager, m_StageDbBcpConnectionCommand);

  COdbcConnectionPtr connection(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));

	//----- Get the session set iterator.
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(pSessionSetPtr);
	if (FAILED(hr))
		return hr;

	m_bSessionsFailed = false;

	//----- If there are any sessions, enter into a transaction.
	ITransactionPtr pITransaction;
	MTPipelineLib::IMTSessionPtr curSession = it.GetNext();
	if (curSession)
	{
		//----- Get the transaction from the first session in the set.
		MTPipelineLib::IMTTransactionPtr pMTTransaction = GetTransaction(curSession);
		if (pMTTransaction != NULL)
		{
			//----- Join the connection to transaction.
			pITransaction = pMTTransaction->GetTransaction();
			ASSERT(pITransaction != NULL);
			connection->JoinTransaction(pITransaction);
 		}
	}

	//----- Loop through all the sessions in set.
	//----- Process entire session set in chunck of size m_uiArraySize.
	vector<MTPipelineLib::IMTSessionPtr> sessionArray;
	while (curSession != NULL)
	{
		sessionArray.push_back(curSession);

		//----- Resolves a chunk of sessions.
		if (sessionArray.size() >= m_uiArraySize)
		{
			ASSERT(sessionArray.size() == m_uiArraySize);

			if (m_bUseBcpFlag)
				hr = InsertIntoTempTable(sessionArray, stageConnection[m_BcpInsertToTempTableStmtCommand], connection, stageConnection);
			else if (IsOracle())
				hr = InsertIntoTempTable(sessionArray, stageConnection[m_OracleArrayInsertToTempTableStmtCommand], connection, stageConnection);
      else
				hr = InsertIntoTempTable(sessionArray, stageConnection[m_SqlArrayInsertToTempTableStmtCommand], connection, stageConnection);
			if (FAILED(hr))
				return hr;

			sessionArray.clear();
		}
		
		//----- Get the next session.
		curSession = it.GetNext();
	}

	//----- Resolves the last partial chunk if necessary
	if (sessionArray.size() > 0)
	{
		if (m_bUseBcpFlag)
			hr = InsertIntoTempTable(sessionArray, stageConnection[m_BcpInsertToTempTableStmtCommand], connection, stageConnection);
		else if (IsOracle())
			hr = InsertIntoTempTable(sessionArray, stageConnection[m_OracleArrayInsertToTempTableStmtCommand], connection, stageConnection);
    else
			hr = InsertIntoTempTable(sessionArray, stageConnection[m_SqlArrayInsertToTempTableStmtCommand], connection, stageConnection);
		if (FAILED(hr))
			return hr;
	}

	//----- Leave transaction.
	if (pITransaction != NULL)
		connection->LeaveTransaction();

	//----- Done.
  if (m_bSessionsFailed)
    return PIPE_ERR_SUBSET_OF_BATCH_FAILED;

	return S_OK;
}

/***************************************************************************
 * BatchPlugInShutdown                                                     *
 ***************************************************************************/
HRESULT CMTBatchAuditPlugin::BatchPlugInShutdown()
{
	//----- Done.
	return S_OK;
}

/***************************************************************************
 * InsertIntoTempTable		                                               *
 ***************************************************************************/
template<class T> HRESULT 
CMTBatchAuditPlugin::InsertIntoTempTable(vector<MTPipelineLib::IMTSessionPtr>& aSessionArray,
                                         T insertStmtPtr,
                                         COdbcConnectionPtr connection,
                                         COdbcConnectionHandle & stageConnection)
{
	//----- Truncate the temporary table.
	COdbcStatementPtr truncateStmtPtr = stageConnection->CreateStatement();
	truncateStmtPtr->ExecuteUpdate(m_strTruncateTmpTableSQL);

	//----- Process the batch.
	MTPipelineLib::IMTSessionPtr pSessionPtr;
	try
	{
		//----- Get size of Array.
		unsigned int uiSessionCount = aSessionArray.size();

		//----- Get date and time for this batch.
		TIMESTAMP_STRUCT curODBCDateTime;
		DATE curDate = GetMTOLETime();
		OLEDateToOdbcTimestamp(&curDate, &curODBCDateTime);

		long lUserId;
		long lEventId;
		long lEntityTypeId;
		long lEntityId;
		wstring wstrDetails;

			//----- Get/update last audit id;
		MetraTech_DataAccess::IIdGenerator2Ptr idAuditGenerator(__uuidof(MetraTech_DataAccess::IdGenerator));
		idAuditGenerator->Initialize("id_audit", uiSessionCount);

		//----- Insert all sessions from input array into temp table.
		for (unsigned int i = 0; i < uiSessionCount; i++)
		{
			pSessionPtr = aSessionArray[i];

			try
			{
				//----- Get data from session.
				MTPipelineLib::IMTSessionContextPtr ctx = pSessionPtr->GetSessionContext();
				lUserId = ctx->GetAccountID();
				lEventId = pSessionPtr->GetLongProperty(m_lAuditEventID);
				lEntityTypeId = pSessionPtr->GetLongProperty(m_lAuditEntityTypeID);
				lEntityId = pSessionPtr->GetLongProperty(m_lAuditEntityID);
				wstrDetails = pSessionPtr->GetStringProperty(m_lAuditDetailsID);
			}
			catch(_com_error & err)
			{
				_bstr_t message = err.Description();
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
				pSessionPtr->MarkAsFailed(message.length() > 0 ? message : L"", err.Error());
				m_bSessionsFailed = true;
				continue;
			}

			//----- Set the data into the temp table.
			insertStmtPtr->SetInteger(1, idAuditGenerator->NextId);
			insertStmtPtr->SetInteger(2, lEventId);
			insertStmtPtr->SetInteger(3, lUserId);
			insertStmtPtr->SetInteger(4, lEntityTypeId);
			insertStmtPtr->SetInteger(5, lEntityId);
			insertStmtPtr->SetWideString(6, wstrDetails);
			insertStmtPtr->SetDatetime(7, curODBCDateTime);
			
			//----- Add to batch.
			insertStmtPtr->AddBatch();
		}

		//----- Insert the records to the temp table.
		insertStmtPtr->ExecuteBatch();
    stageConnection->CommitTransaction();

		//----- Execute update from queries on the destination database.
		COdbcStatementPtr pUpdateStmtPtr = connection->CreateStatement();
		pUpdateStmtPtr->ExecuteUpdate(m_strUpdateAuditTableSQL);
		pUpdateStmtPtr->ExecuteUpdate(m_strUpdateDetailsTableSQL);
	}
	catch(_com_error & e)
	{
		insertStmtPtr->ExecuteBatch();

		char buffer[1024];
		_bstr_t msg = e.Description();
		sprintf(buffer, "An exception was thrown while inserting sessions: 0x%x, %s", 
						e.Error(), (const char*) msg.length() > 0 ? msg : L"");

		return Error(buffer);
	}
  catch(...)
  {
    insertStmtPtr->ExecuteBatch();
    throw;
  }

	return S_OK;
}

/***************************************************************************
 * GenerateQueries		                                               *
 ***************************************************************************/
void CMTBatchAuditPlugin::GenerateQueries(string& strAuditTableName,
                                          string& strAuditDetailsTableName,
                                          const char* stagingDBName)
{
  //----- Create temp table names.
  MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));
  m_strTmpTableName = nameHash->GetDBNameHash(("tmp_acct_audit_" + m_strTagName).c_str());
  string schemaDots = m_QueryAdapterAC->GetSchemaDots();

  m_strTmpTableFullName = stagingDBName + schemaDots + m_strTmpTableName;

	//----- Get temp table truncate query
	m_QueryAdapterAC->ClearQuery();
	m_QueryAdapterAC->SetQueryTag("__TRUNCATE_TEMP_TABLE__");
	m_QueryAdapterAC->AddParam("%%TMP_TABLE_NAME%%", m_strTmpTableFullName.c_str());
	m_strTruncateTmpTableSQL = m_QueryAdapterAC->GetQuery();

	//----- Create query to insert from tmp to t_audit table.
	m_QueryAdapterAC->ClearQuery();
	m_QueryAdapterAC->SetQueryTag("__INSERT_INTO_AUDIT_TABLE__");
	m_QueryAdapterAC->AddParam("%%TABLE_NAME%%", strAuditTableName.c_str());
	m_QueryAdapterAC->AddParam("%%TMP_TABLE_NAME%%", m_strTmpTableFullName.c_str());
	m_strUpdateAuditTableSQL = m_QueryAdapterAC->GetQuery();

	//----- Create query to insert from tmp to t_audit_details table.
	m_QueryAdapterAC->ClearQuery();
	m_QueryAdapterAC->SetQueryTag("__INSERT_INTO_AUDIT_DETAILS_TABLE__");
	m_QueryAdapterAC->AddParam("%%TABLE_NAME%%", strAuditDetailsTableName.c_str());
	m_QueryAdapterAC->AddParam("%%TMP_TABLE_NAME%%", m_strTmpTableFullName.c_str());
	m_strUpdateDetailsTableSQL = m_QueryAdapterAC->GetQuery();

	//----- Query used to create temp table.
	m_QueryAdapterAC->ClearQuery();
	m_QueryAdapterAC->SetQueryTag("__CREATE_BATCHAUDIT_TEMP_TABLE__");
	m_QueryAdapterAC->AddParam("%%TMP_TABLE_NAME%%", m_strTmpTableFullName.c_str());
	m_strCreateTempTableSQL = m_QueryAdapterAC->GetQuery();
}
//-- EOF --
