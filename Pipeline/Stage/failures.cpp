#include <map>
#include <string>

#include <failures.h>
#include <OdbcException.h>
#include <OdbcResultSet.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcConnMan.h>
#include <RowsetDefs.h>
#include <MSIX.h>
#include <propids.h>
#include <mtglobal_msg.h>
#include <MTTime.h>
#include <mtprogids.h>
#include <SetIterate.h>
#include <autocritical.h>

typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;
typedef MTautoptr<COdbcResultSet> COdbcResultSetPtr;
typedef MTautoptr<COdbcIdGenerator> COdbcIdGeneratorPtr;

#import <Rowset.tlb> rename("EOF", "RowsetEOF")
#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )

static void TruncateString(std::string & arTruncated, int aMaxLen)
{
	if (arTruncated.length() > (unsigned) aMaxLen)
		arTruncated.resize(aMaxLen);
}

PipelineFailureWriter::PipelineFailureWriter(MTPipelineLib::IMTNameIDPtr aNameID,
                                             MTPipelineLib::IMTSessionServerPtr aSessionServer,
                                             bool aIsDatabaseQueue)
  :
  mNameID(aNameID),
  mSessionServer(aSessionServer),
  mWriteErrorInitialized(FALSE),
  mGenerator(NULL),
  mBcpInsertToFailureTable(NULL),
  mArrayInsertToFailureTable(NULL),
  mArrayInsertToFailureSessionStateTable(NULL),
  mBcpInsertToFailureSessionStateTable(NULL),
  mIsDatabaseQueue(aIsDatabaseQueue)
{
}

void PipelineFailureWriter::Clear()
{
  //Need to guarantee destruction of ODBC prepared statements before connection is destroyed
  mWriteErrorInitialized = FALSE;
	mArrayInsertToFailureTable=NULL;
	mBcpInsertToFailureTable=NULL;
  mArrayInsertToFailureSessionStateTable=NULL;
  mBcpInsertToFailureSessionStateTable=NULL;
	mBatchIDWriter=NULL;
	mConnection=NULL;
  mStateConnection=NULL;
  //Release Id generator
  if (mGenerator != NULL)
  {
    COdbcIdGenerator::ReleaseInstance();
    mGenerator = NULL;
  }  
}

BOOL PipelineFailureWriter::PrepareWriteError()
{
	const char * functionName = "PipelineFailureWriter:::PrepareWriteError";
  //Prepare ODBC statement and connection
  try
  {
		// we clear everything in the right order in case we're hitting this
		// code because a write attempt failed
		mArrayInsertToFailureTable = NULL;
		mBcpInsertToFailureTable = NULL;
    mArrayInsertToFailureSessionStateTable = NULL;
    mBcpInsertToFailureSessionStateTable = NULL;
		mBatchIDWriter = NULL;
		mConnection = NULL;
    mStateConnection = NULL;

		COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
		COdbcConnectionInfo stageInfo = COdbcConnectionManager::GetConnectionInfo("NetMeter");
		mStagingDBName = COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalog();
    stageInfo.SetCatalog(mStagingDBName.c_str());

  		mIsOracle = (info.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);

		mBatchIDWriter = new COdbcBatchIDWriter(info);
		mBatchIDWriter->CreateTempTable();
		mBatchIDWriter->CreateBatchSummaryInsertStatement();

    // Make sure staging table for t_session_state exists and is empty
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(L"Queries\\Pipeline");
    rowset->SetQueryTag("_CREATE_FAILED_SESSION_STATE_STAGING_");
    rowset->AddParam("%%NETMETERSTAGE%%", _bstr_t(mStagingDBName.c_str()));
    rowset->Execute();

		mConnection = new COdbcConnection(stageInfo);
    mStateConnection = new COdbcConnection(stageInfo);

    // Make sure staging table for t_failed_transaction exists and is empty
    rowset->SetQueryTag("__CREATE_FAILED_STAGING__");
    rowset->Execute();
    rowset = NULL;

		if (mIsOracle)
		{
			mConnection->SetAutoCommit(false);
      mStateConnection->SetAutoCommit(false);
			mArrayInsertToFailureTable = mConnection->PrepareInsertStatement("t_failed_transaction_stage", 1000);
      mArrayInsertToFailureSessionStateTable = mStateConnection->PrepareInsertStatement("t_failed_session_state_stage", 1000);
		}
		else
		{

			// use auto commit only if using bcp
			//if (mUseBcpFlag)
			mConnection->SetAutoCommit(true);
      mStateConnection->SetAutoCommit(true);

			COdbcBcpHints hints;
			// use minimally logged inserts.
			// TODO: this may only matter if database recovery model settings are correct.
			//       however, it won't hurt if they're not
			hints.SetMinimallyLogged(true);
			mBcpInsertToFailureTable = mConnection->PrepareBcpInsertStatement("t_failed_transaction_stage", hints);
      mBcpInsertToFailureSessionStateTable = mStateConnection->PrepareBcpInsertStatement("t_failed_session_state_stage", hints);
		}


    //Initialize the id generator
    if (mGenerator == NULL)
    {
      mGenerator = COdbcIdGenerator::GetInstance(info);
    }
  }
  catch(COdbcException & e)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "ODBC exception caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += e.toString().c_str();
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(e.getErrorCode(), ERROR_MODULE, ERROR_LINE, functionName, buffer.c_str());
    return FALSE;
  }
	catch(_com_error& e)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "COM error caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += (const char*)(e.Description());
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(e.Error(), ERROR_MODULE, ERROR_LINE, functionName, buffer.c_str());
    return FALSE;
	}


  mWriteErrorInitialized = TRUE;
  return mWriteErrorInitialized;
}

BOOL PipelineFailureWriter::BeginWriteError()
{
	const char * functionName = "PipelineFailureWriter::BeginWriteError";

  try
  {    
    if (!mWriteErrorInitialized)
    {
      if (!this->PrepareWriteError())
      {
        std::string buffer;
        buffer = "Unable to initialize database to write failed transaction: ";
        buffer += functionName;
        mLogger.LogThis(LOG_ERROR, buffer.c_str());
        ASSERT(GetLastError());
        return FALSE;
      }
    }

    // truncate staging
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(L"Queries\\Pipeline");
    rowset->SetQueryTag("__TRUNCATE_FAILED_STAGING_PIPELINE__");
    rowset->Execute();
    rowset->SetQueryTag("__TRUNCATE_FAILED_SESSION_STATE_STAGING__");
    rowset->Execute();
    rowset = NULL;
    if (mIsOracle)
	{
      mArrayInsertToFailureTable->BeginBatch();
      mArrayInsertToFailureSessionStateTable->BeginBatch();
	}
    else
	{
      mBcpInsertToFailureTable->BeginBatch();
      mBcpInsertToFailureSessionStateTable->BeginBatch();
	}

  }
  catch(COdbcException & e)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "ODBC exception caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += e.toString().c_str();
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(e.getErrorCode(), ERROR_MODULE, ERROR_LINE, functionName, buffer.c_str());
    return FALSE;
  }
	catch(_com_error& e)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "COM error caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += (const char*)(e.Description());
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(e.Error(), ERROR_MODULE, ERROR_LINE, functionName, buffer.c_str());
    return FALSE;
	}

  return mWriteErrorInitialized;
}

BOOL PipelineFailureWriter::FinalizeWriteError(MTPipelineLib::IMTTransactionPtr apTran, map<wstring, int>& arBatchCounts)
{
	const char * functionName = "PipelineFailureWriter::FinalizeWriteError";

  try
  {
    if (mIsOracle)
    {
         int rc = 0;
         
         rc = mArrayInsertToFailureTable->ExecuteBatch();
         if (rc < 0)
         {
           std::string buffer;
           buffer = "Failed to write failed transactions: ";
           buffer += functionName;
           mLogger.LogThis(LOG_ERROR, buffer.c_str());
         }
         else if (rc == 0)
         {
           std::string buffer;
           buffer = "Did not write any failed transactions: ";
           buffer += functionName;
           mLogger.LogThis(LOG_WARNING, buffer.c_str());
         }
      mConnection->CommitTransaction();
      rc = mArrayInsertToFailureSessionStateTable->ExecuteBatch();
      if (rc < 0)
      {
        std::string buffer;
        buffer = "Failed to write failed session states: ";
        buffer += functionName;
        mLogger.LogThis(LOG_ERROR, buffer.c_str());
      }
      else if (rc == 0)
      {
        std::string buffer;
        buffer = "Did not write any failed session states: ";
        buffer += functionName;
        mLogger.LogThis(LOG_WARNING, buffer.c_str());
      }
      mStateConnection->CommitTransaction();
    }
    else
    {
      int rc = 0;
      rc = mBcpInsertToFailureTable->ExecuteBatch();
      if (rc < 0)
      {
        std::string buffer;
        buffer = "Failed to write failed transactions: ";
        buffer += functionName;
        mLogger.LogThis(LOG_ERROR, buffer.c_str());
      }
      else if (rc == 0)
      {
        std::string buffer;
        buffer = "Did not write any failed transactions: ";
        buffer += functionName;
        mLogger.LogThis(LOG_WARNING, buffer.c_str());
      }
      rc = mBcpInsertToFailureSessionStateTable->ExecuteBatch();
      if (rc < 0)
      {
        std::string buffer;
        buffer = "Failed to write failed session states: ";
        buffer += functionName;
        mLogger.LogThis(LOG_ERROR, buffer.c_str());
      }
      else if (rc == 0)
      {
        std::string buffer;
        buffer = "Did not write any failed session states: ";
        buffer += functionName;
        mLogger.LogThis(LOG_WARNING, buffer.c_str());
      }
      rc = mBcpInsertToFailureSessionStateTable->ExecuteBatch();
      if (rc < 0)
      {
        std::string buffer;
        buffer = "Failed to write failed session states: ";
        buffer += functionName;
        mLogger.LogThis(LOG_ERROR, buffer.c_str());
      }
      else if (rc == 0)
      {
        std::string buffer;
        buffer = "Did not write any failed session states: ";
        buffer += functionName;
        mLogger.LogThis(LOG_WARNING, buffer.c_str());
      }
    }
	  	

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(L"Queries\\Pipeline");
    rowset->JoinDistributedTransaction((ROWSETLib::IMTTransaction *) apTran.GetInterfacePtr());
    rowset->SetQueryTag("__UPDATE_FAILED_FROM_STAGING__");
    rowset->Execute();
    if(mIsDatabaseQueue)
    {
      _variant_t maxDate = GetMaxMTOLETime();
      rowset->SetQueryTag(L"__UPDATE_SESSION_STATE__");
      rowset->AddParam("%%MAX_DATE%%", maxDate);
      rowset->Execute();
      rowset->SetQueryTag(L"__INSERT_SESSION_STATE__");
      rowset->AddParam("%%MAX_DATE%%", maxDate);
      rowset->Execute();
    }
    rowset->JoinDistributedTransaction(NULL);

    if (arBatchCounts.size() > 0)
    {
      // update batch status table with error counts
      mBatchIDWriter->UpdateErrorCounts(arBatchCounts, apTran);
    }
  }  
  catch(COdbcException & e)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "ODBC exception caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += e.toString().c_str();
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(e.getErrorCode(), ERROR_MODULE, ERROR_LINE, functionName, buffer.c_str());
    return FALSE;
  }
	catch(_com_error& e)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "COM error caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += (const char*)(e.Description());
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(e.Error(), ERROR_MODULE, ERROR_LINE, functionName, buffer.c_str());
    return FALSE;
	}


  return TRUE;
}

BOOL PipelineFailureWriter::WriteError(
	MTPipelineLib::IMTSessionPtr aSession,
	SessionErrorObject & arErrObject)
{
  
  if (mIsOracle)
  {
	// Will this batch exceed array size, if yes then execute work already done.
	if (mArrayInsertToFailureTable->GetCurrentArrayPos() + 1 > mArrayInsertToFailureTable->GetArraySize())
	{
		mArrayInsertToFailureTable->ExecuteBatch();
		mArrayInsertToFailureTable->Finalize();
	}

    BOOL result = WriteErrorEx(aSession, arErrObject, mArrayInsertToFailureTable);
    if (result)
	{
		// Will this batch exceed array size, if yes then execute work already done.
		if (mArrayInsertToFailureSessionStateTable->GetCurrentArrayPos() + 1 > mArrayInsertToFailureSessionStateTable->GetArraySize())
		{
			mArrayInsertToFailureSessionStateTable->ExecuteBatch();
			mArrayInsertToFailureSessionStateTable->Finalize();
		}
		
		return WriteErrorStateEx(aSession, arErrObject, mArrayInsertToFailureSessionStateTable);
	}
	else
		return result;
  }
  else
  {
    BOOL result = WriteErrorEx(aSession, arErrObject, mBcpInsertToFailureTable);
    if (result)
      return WriteErrorStateEx(aSession, arErrObject, mBcpInsertToFailureSessionStateTable);
    else
      return result;
  }
}

template<class T>
void FlushIfArrayIsFull(T & arStateStatement) {}

template<>
void FlushIfArrayIsFull(COdbcPreparedArrayStatementPtr & arStateStatement) 
{
		if (arStateStatement->GetCurrentArrayPos() + 1 > arStateStatement->GetArraySize())
		{
			arStateStatement->ExecuteBatch();
			arStateStatement->Finalize();
		}
}

template<class T>
BOOL PipelineFailureWriter::WriteErrorStateEx(
	MTPipelineLib::IMTSessionPtr aSession,
	SessionErrorObject & arErrObject,
  T & arStateStatement)
{
  const char * functionName = "PipelineFailureWriter::WriteErrorStateEx";
  unsigned char uid[UID_LENGTH];
  try
  {
    int field = 1;
    time_t ltime;
    TIMESTAMP_STRUCT odbcTimestamp;

    ltime = arErrObject.GetFailureTime();
    ::TimetToOdbcTimestamp(&ltime, &odbcTimestamp);

    //get to the root.
    MTPipelineLib::IMTSessionPtr root = aSession;
		while (root->GetParentID() != -1)
			root = GetSessionServer()->GetSession(root->GetParentID());
    root->GetUID(uid);

 
		arStateStatement->SetBinary(field++, uid, UID_LENGTH); //tx_FailureID
    arStateStatement->SetDatetime(field++,odbcTimestamp);  //dt_FailureTime
    //add the root session
    arStateStatement->AddBatch();

    if (root->GetIsParent() == VARIANT_TRUE)
    {
      // A call to SessionChildren on a session without children is REALY expensive
      // as it creates a new session set.
   MTPipelineLib::IMTSessionSetPtr children = root->SessionChildren();
   SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	 HRESULT hr = it.Init(children);
	 if (FAILED(hr))
	 {
			mLogger.LogThis(LOG_ERROR, "Unable to step through session set");
      SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
      return FALSE;
	 }

	 while (TRUE)
		{
			MTPipelineLib::IMTSessionPtr child = it.GetNext();
			if (child == NULL)
				break;
			FlushIfArrayIsFull<T>(arStateStatement);
      field = 1;
      child->GetUID(uid);
      arStateStatement->SetBinary(field++, uid, UID_LENGTH); //tx_FailureID
      arStateStatement->SetDatetime(field++,odbcTimestamp);  //dt_FailureTime
      //add the child session
      arStateStatement->AddBatch();
		
		}
  }
  }
  catch(COdbcException & e)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "ODBC exception caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += e.toString().c_str();
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
  }
	catch(_com_error& e)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "COM error caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += (const char*)(e.Description());
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
	}
  // CR 15759 - handle all exceptions
  catch(...)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "Error caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += "Unknown error";
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
	}
	return TRUE;

}

template<class T>
BOOL PipelineFailureWriter::WriteErrorEx(
	MTPipelineLib::IMTSessionPtr aSession,
	SessionErrorObject & arErrObject,
	T & arStatement)
{


	const char * functionName = "PipelineFailureWriter::WriteErrorEx";

	string uidString;
	unsigned char uid[16];
	MSIXUidGenerator::Generate(uidString);
	MSIXUidGenerator::Decode(uid, uidString);


  //Add the error and state information to ODBC batch 
  try
  {
    
    std::string truncated;
    time_t ltime;
		TIMESTAMP_STRUCT odbcTimestamp;

    long idFailure = mGenerator->GetNext("id_failed_txn");
		int field = 1;
	  // set all properties correctly..
    arStatement->SetInteger(field++,idFailure);



    arStatement->SetString(field++,"N");

		// skip tx_StateReasonCode - leave it null
		field++;

	  const unsigned char * sessionID = arErrObject.GetSessionID();
	  ASSERT(sessionID);

		arStatement->SetBinary(field++, sessionID, 16); //tx_FailureID

	  string encodedID;
	  MSIXUidGenerator::Encode(encodedID, sessionID);
    arStatement->SetWideString(field++,(wchar_t*)_bstr_t(encodedID.c_str()));	// tx_FailureID_encoded
	  string encodedSessionID = encodedID;


	  const unsigned char * rootID = arErrObject.GetRootID();

		arStatement->SetBinary(field++, rootID, 16); //tx_FailureCompoundID

	  encodedID.resize(0);
	  if (rootID)
		  MSIXUidGenerator::Encode(encodedID, rootID);
    arStatement->SetWideString(field++,(wchar_t*)_bstr_t(encodedID.c_str())); //tx_FailureCompoundID_encoded


    arStatement->SetInteger(field++,arErrObject.GetPayeeID());//id_PossiblePayeeID
    arStatement->SetInteger(field++,arErrObject.GetPayerID());//id_PossiblePayerID

	  long failureServiceID = arErrObject.GetServiceID();
	  _bstr_t serviceName = GetNameID()->GetName(failureServiceID);
	  std::wstring lowerServiceName = (const wchar_t *) serviceName;
	  _wcslwr((wchar_t *)lowerServiceName.c_str());
    arStatement->SetWideString(field++, (const wchar_t *) lowerServiceName.c_str()); //tx_FailureServiceName

    arStatement->SetInteger(field++, arErrObject.GetErrorCode());//n_Code
    arStatement->SetInteger(field++, arErrObject.GetLineNumber());//n_Line

    ltime = arErrObject.GetFailureTime();
    ::TimetToOdbcTimestamp(&ltime, &odbcTimestamp);
    arStatement->SetDatetime(field++,odbcTimestamp);  //dt_FailureTime

    ltime = arErrObject.GetMeteredTime();
    ::TimetToOdbcTimestamp(&ltime, &odbcTimestamp);
    arStatement->SetDatetime(field++,odbcTimestamp);  //dt_MeteredTime

    arErrObject.GetIPAddressAsString(truncated);
  	TruncateString(truncated, 30);
    arStatement->SetWideString(field++,(wchar_t*)_bstr_t(truncated.c_str())); //tx_Sender

    truncated = arErrObject.GetErrorMessage();
  	TruncateString(truncated, MAX_FAILURE_ERROR_MESSAGE_SIZE);
    arStatement->SetWideString(field++,(wchar_t*)_bstr_t(truncated.c_str())); //tx_ErrorMessage

    truncated = arErrObject.GetStageName();
    TruncateString(truncated, 64);
    arStatement->SetWideString(field++,(wchar_t*)_bstr_t(truncated.c_str())); //tx_StageName

    truncated = arErrObject.GetPlugInName();
    TruncateString(truncated, 64);
    arStatement->SetWideString(field++,(wchar_t*)_bstr_t(truncated.c_str())); //tx_PlugIn

    truncated = arErrObject.GetModuleName();
    TruncateString(truncated, 255);
    arStatement->SetWideString(field++,(wchar_t*)_bstr_t(truncated.c_str())); //tx_Module

    truncated = arErrObject.GetProcedureName();
    TruncateString(truncated, 64);
    arStatement->SetWideString(field++,(wchar_t*)_bstr_t(truncated.c_str())); //tx_Method

    //get batch id if it exists and set tx_batch property in session
  	//batch id metered in session

		// walk up to the root of the compound
		MTPipelineLib::IMTSessionPtr root = aSession;
		while (root->GetParentID() != -1)
			root = GetSessionServer()->GetSession(root->GetParentID());

		// the batch ID always comes from the root
	  if (root->PropertyExists(PipelinePropIDs::CollectionIDCode(), MTPipelineLib::SESS_PROP_TYPE_STRING))
	  {
		  _bstr_t bstrBatchID = root->GetStringProperty(PipelinePropIDs::CollectionIDCode());

		  // decodes the UID back to binary 
		  unsigned char batchUID[16];
		  MSIXUidGenerator::Decode(batchUID, WideStringToString(bstrBatchID));

      arStatement->SetBinary(field++, batchUID, 16); //tx_Batch
      arStatement->SetWideString(field++,(wchar_t*)bstrBatchID); //tx_Batch_Encoded
	  }
		else
			// skip those two fields
			field += 2;

		if (arErrObject.GetIsCompound())
			arStatement->SetString(field++, "Y");
		else
			arStatement->SetString(field++, "N");

		// the error code string is also useful.  this is the translated string
		// version of the error code
		Message msg(arErrObject.GetErrorCode());
    std::string codeText;
		msg.GetErrorMessage(codeText, true);
    TruncateString(codeText, 255);

    if (mIsOracle && codeText.length() == 0)
      codeText = " "; // Oracle treats empty string as NULL and NULL is not allowed.

    arStatement->SetWideString(field++,(wchar_t*)_bstr_t(codeText.c_str())); // tx_errorcodestring 

    if(mIsDatabaseQueue)
    {
    // set the session set id
    arStatement->SetInteger(field++,arErrObject.GetScheduleSessionSetID());
    }

    // Record state modified time.
    DATE now = GetMTOLETime();
		OLEDateToOdbcTimestamp(&now, &odbcTimestamp);
    arStatement->SetDatetime(field++, odbcTimestamp);  // dt_StateLastModifiedTime

    arStatement->AddBatch();


 	  Message message(arErrObject.GetErrorCode());
	  std::string codeString;
	  if (!message.GetErrorMessage(codeString, true))
		  codeString = "unknown";

	  mLogger.LogVarArgs(LOG_ERROR, "Session %s failed with error %x (%s) %s",
										   encodedSessionID.c_str(),
										   arErrObject.GetErrorCode(),
										   codeString.c_str(),
										   arErrObject.GetErrorMessage().c_str());

  }
  catch(COdbcException & e)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "ODBC exception caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += e.toString().c_str();
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
  }
	catch(_com_error& e)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "COM error caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += (const char*)(e.Description());
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
	}
  // CR 15759 - handle all exceptions
  catch(...)
	{
    //marks the database as needing to be re-initialized next time
    mWriteErrorInitialized = FALSE;

    std::string buffer;
    buffer = "Error caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += "Unknown error";
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
	}

	return TRUE;
}

PipelineResubmitDatabase::PipelineResubmitDatabase(MTPipelineLib::IMTSessionServerPtr aSessionServer)
  :
	mConnection(NULL),
  mWriteErrorInitialized(FALSE),
  mArrayInsertToSuccessTable(NULL),
  mBcpInsertToSuccessTable(NULL),
  mSessionServer(aSessionServer)
{
}

bool PipelineResubmitDatabase::Prepare()
{
  const char * functionName = "PipelineResubmitDatabase::Prepare";
  ASSERT(mWriteErrorInitialized == FALSE);
  try
  {
		COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
		COdbcConnectionInfo stageInfo = COdbcConnectionManager::GetConnectionInfo("NetMeter");
		mStagingDBName = COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalog();
    stageInfo.SetCatalog(mStagingDBName.c_str());

    mIsOracle = (info.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);
    // Make sure staging table for t_failed_transaction exists and is empty
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(L"Queries\\Pipeline");
    rowset->SetQueryTag("__CREATE_RESUBMIT_STAGING__");
    rowset->AddParam("%%NETMETERSTAGE%%", _bstr_t(mStagingDBName.c_str()));
    rowset->Execute();
    rowset = NULL;


		mConnection = new COdbcConnection(stageInfo);
		if (mIsOracle)
		{
			mConnection->SetAutoCommit(false);
			mArrayInsertToSuccessTable = mConnection->PrepareInsertStatement("t_resubmit_transaction_stage", 1000);
		}
		else
		{
			// use auto commit only if using bcp
			//if (mUseBcpFlag)
			mConnection->SetAutoCommit(true);
			COdbcBcpHints hints;
			// use minimally logged inserts.
			// TODO: this may only matter if database recovery model settings are correct.
			//       however, it won't hurt if they're not
			hints.SetMinimallyLogged(true);
			mBcpInsertToSuccessTable = mConnection->PrepareBcpInsertStatement("t_resubmit_transaction_stage", hints);
		}

    mWriteErrorInitialized = TRUE;
  }
  catch(COdbcException & e)
  {
    //marks the database as needing to be re-initialized next time
    Clear();

    std::string buffer;
    buffer = "ODBC exception caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += e.toString().c_str();
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
  }
  catch(_com_error & e)
  {
    //marks the database as needing to be re-initialized next time
    Clear();

    std::string buffer;
    buffer = "COM error caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += (const char*)(e.Description());
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
  }
  return TRUE;
}

void PipelineResubmitDatabase::WriteResubmitSession(MTPipelineLib::IMTSessionPtr aSession, 
                                                    map<long, PipelineResubmitDatabase::ServiceStats> & serviceToSessionSet)
{
  const char * functionName = "PipelineResubmitDatabase::WriteResubmitSession";
  map<long, ServiceStats>::iterator it=serviceToSessionSet.find(aSession->ServiceID);
  if(it == serviceToSessionSet.end())
  {
    ServiceStats stats;
    stats.SessionSetID = -1;
    stats.NumSessions = 1;
    serviceToSessionSet[aSession->ServiceID] = stats;
  }
  else
  {
    it->second.NumSessions++;
  }

	unsigned char uidBytes[UID_LENGTH];
	aSession->GetUID(uidBytes);

  if(mIsOracle)
  {
	// Will this batch exceed array size, if yes then execute work already done.
	if (mArrayInsertToSuccessTable->GetCurrentArrayPos() + 1 > mArrayInsertToSuccessTable->GetArraySize())
	{
		mArrayInsertToSuccessTable->ExecuteBatch();
		mArrayInsertToSuccessTable->Finalize();
	}

    mArrayInsertToSuccessTable->SetBinary(1, uidBytes, UID_LENGTH);
    mArrayInsertToSuccessTable->SetInteger(2, aSession->ServiceID);
    mArrayInsertToSuccessTable->AddBatch();
  }
  else
  {
    mBcpInsertToSuccessTable->SetBinary(1, uidBytes, UID_LENGTH);
    mBcpInsertToSuccessTable->SetInteger(2, aSession->ServiceID);
    mBcpInsertToSuccessTable->AddBatch();
  }
}

bool PipelineResubmitDatabase::AutoResubmit(MTPipelineLib::IMTTransactionPtr apTran,
																						std::vector<MTPipelineLib::IMTSessionPtr> & arErrorsNotMarked,
																						int originalMessageID)
{
  const char * functionName = "PipelineResubmitDatabase::AutoResubmit";
  
  AutoCriticalSection autolock(&mThreadLock);
  try
  {
    if(!mWriteErrorInitialized)
    {
      if (Prepare() == FALSE)
      {
        ASSERT(GetLastError());
        return FALSE;
      }
    }
    // truncate staging (in a local transaction that auto commits)
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(L"Queries\\Pipeline");
    rowset->SetQueryTag("__TRUNCATE_RESUBMIT_STAGING__");
    rowset->Execute();
    rowset = NULL;

    // Keep track of service ids seen; we'll later assign session set ids to them
    map<long, ServiceStats> serviceToSessionSet;

    // Begin batch to staging
    if (mIsOracle)
    {
      mArrayInsertToSuccessTable->BeginBatch();
    }
    else
    {
      mBcpInsertToSuccessTable->BeginBatch();
    }


		// NOTE: there is only one root service def per message (this is enforced by the listener)
		ASSERT(arErrorsNotMarked.size() > 0);
		int rootSvcDefID = arErrorsNotMarked[0]->ServiceID;

    // Place all resubmit sessions in staging
    for(unsigned int i=0; i< arErrorsNotMarked.size(); i++)
    {
      WriteResubmitSession(arErrorsNotMarked[i], serviceToSessionSet);
      if (arErrorsNotMarked[i]->GetIsParent() == VARIANT_TRUE)
      {
      // If compound, we must add record of all children as well.
      MTPipelineLib::IMTSessionSetPtr descendants = arErrorsNotMarked[i]->SessionChildren();
      SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
      HRESULT hr = it.Init(descendants);
      if (FAILED(hr))
      {
        mLogger.LogThis(LOG_ERROR, "Unable to step through session set");
        SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
        return FALSE;
      }

      while (TRUE)
      {
        MTPipelineLib::IMTSessionPtr session = it.GetNext();
        if (session == NULL)
          break;

        WriteResubmitSession(session, serviceToSessionSet);
      }
    }
    }

    // Finalize by committing to staging and moving data into core schema (t_session_set).
    // Also schedule the work (t_session_set, t_message).
    if(mIsOracle)
    {
      mArrayInsertToSuccessTable->ExecuteBatch();
      mConnection->CommitTransaction();
    }
    else
    {
      mBcpInsertToSuccessTable->ExecuteBatch();
    }

    // Get the block of session set ids.  Don't do this in DTC cause we don't
    // want to hold locks.
    HRESULT hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
    if (FAILED(hr))
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
               "Failed allocating rowset");
      return FALSE;
    }
    rowset->Init(L"Queries\\Pipeline");
    rowset->InitializeForStoredProc("GetIdBlock");
		rowset->AddInputParameterToStoredProc ("block_size", MTTYPE_INTEGER, INPUT_PARAM, (long) serviceToSessionSet.size());
		rowset->AddInputParameterToStoredProc ("sequence_name", MTTYPE_W_VARCHAR, INPUT_PARAM, _bstr_t(L"id_dbqueuess"));
		rowset->AddOutputParameterToStoredProc("block_start", MTTYPE_INTEGER, OUTPUT_PARAM);
    rowset->ExecuteStoredProc();
    long sessionSetID = (long) rowset->GetParameterFromStoredProc("block_start");
    long cnt=0;
    for(map<long,ServiceStats>::iterator it = serviceToSessionSet.begin();
        it != serviceToSessionSet.end();
        it++, cnt++)
    {
      // Assign the session set id for each service
      serviceToSessionSet[it->first].SessionSetID = sessionSetID + cnt;
    }
    rowset = NULL;

    // Get the message id.  Also don't do this in DTC.
    hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
    if (FAILED(hr))
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
               "Failed allocating rowset");
      return FALSE;
    }
    rowset->Init(L"Queries\\Pipeline");
    rowset->InitializeForStoredProc("GetIdBlock");
		rowset->AddInputParameterToStoredProc ("block_size", MTTYPE_INTEGER, INPUT_PARAM, 1L);
		rowset->AddInputParameterToStoredProc ("sequence_name", MTTYPE_W_VARCHAR, INPUT_PARAM, _bstr_t(L"id_dbqueuesch"));
		rowset->AddOutputParameterToStoredProc("block_start", MTTYPE_INTEGER, OUTPUT_PARAM);
    rowset->ExecuteStoredProc();
    long messageID = (long) rowset->GetParameterFromStoredProc("block_start");
    rowset = NULL;

    hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
    if (FAILED(hr))
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
               "Failed allocating rowset");
      return FALSE;
    }
    rowset->Init(L"Queries\\Pipeline");
    rowset->JoinDistributedTransaction((ROWSETLib::IMTTransaction *) apTran.GetInterfacePtr());
    // First, move into t_session_set.  Do this separately for each service id since these
    // will each correspond to a session set.
    for(map<long,ServiceStats>::iterator it = serviceToSessionSet.begin();
        it != serviceToSessionSet.end();
        it++)
    {
      rowset->SetQueryTag("__UPDATE_RESUBMIT_FROM_STAGING__");
      rowset->AddParam("%%ID_SVC%%", it->first);
      rowset->AddParam("%%ID_SS%%", it->second.SessionSetID);
      rowset->Execute();

      rowset->SetQueryTag("__INSERT_SESSION_SET__");
      rowset->AddParam("%%ID_MESSAGE%%", messageID);
      rowset->AddParam("%%ID_SVC%%", it->first);
      rowset->AddParam("%%ID_SS%%", it->second.SessionSetID);
			rowset->AddParam("%%B_ROOT%%", (it->first == rootSvcDefID) ? "1" : "0");
      rowset->AddParam("%%SESSION_COUNT%%", it->second.NumSessions);
      rowset->Execute();
    }
    rowset->SetQueryTag("__INSERT_MESSAGE__");
    rowset->AddParam("%%ID_MESSAGE%%", messageID);
    rowset->AddParam("%%ID_ORIGINAL_MESSAGE%%", originalMessageID);
    rowset->Execute();

    // D'tor handles this now.
//     rowset->JoinDistributedTransaction(NULL);
  }
  catch(COdbcException & e)
  {
    //marks the database as needing to be re-initialized next time
    Clear();

    std::string buffer;
    buffer = "ODBC exception caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += e.toString().c_str();
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
  }
  catch(_com_error & e)
  {
    //marks the database as needing to be re-initialized next time
    Clear();

    std::string buffer;
    buffer = "COM error caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += (const char*)(e.Description());
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
  }
  return TRUE;
}

void PipelineResubmitDatabase::Clear()
{
  AutoCriticalSection autolock(&mThreadLock);
  mArrayInsertToSuccessTable = NULL;
  mBcpInsertToSuccessTable = NULL;
  mConnection = NULL;
  mWriteErrorInitialized = FALSE;
}

bool PipelineResubmitDatabase::MarkAsSucceeded(MTPipelineLib::IMTTransactionPtr apTran,
                                               MTPipelineLib::IMTSessionSetPtr aSet,
                                               long aMessageID)
{
  const char * functionName = "PipelineResubmitDatabase::MarkAsSucceeded";

  AutoCriticalSection autolock(&mThreadLock);
  try
  {
    if(!mWriteErrorInitialized)
    {
      if (Prepare() == FALSE)
      {
        ASSERT(GetLastError());
        return FALSE;
      }
    }
    // truncate staging (in a local transaction that auto commits)
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(L"Queries\\Pipeline");
    rowset->SetQueryTag("__TRUNCATE_RESUBMIT_STAGING__");
    rowset->Execute();
    rowset = NULL;

    // Begin batch to staging
    if (mIsOracle)
    {
      mArrayInsertToSuccessTable->BeginBatch();
    }
    else
    {
      mBcpInsertToSuccessTable->BeginBatch();
    }


    // Keep track of service ids seen; we'll later assign session set ids to them
    map<long, ServiceStats> serviceToSessionSet;
    SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
    HRESULT hr = it.Init(aSet);
    if (FAILED(hr))
    {
      mLogger.LogThis(LOG_ERROR, "Unable to step through session set");
      SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
      return FALSE;
    }
    while (TRUE)
    {
      MTPipelineLib::IMTSessionPtr session = it.GetNext();
      if (session == NULL)
        break;

      WriteResubmitSession(session, serviceToSessionSet);
      if(session->GetIsParent() == VARIANT_TRUE)
      {
      // If compound, we must add record of all children as well.
      MTPipelineLib::IMTSessionSetPtr descendants = session->SessionChildren();
      SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> childIt;
      HRESULT hr = childIt.Init(descendants);
      if (FAILED(hr))
      {
        mLogger.LogThis(LOG_ERROR, "Unable to step through session set");
        SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
        return FALSE;
      }

      while (TRUE)
      {
        MTPipelineLib::IMTSessionPtr childSession = childIt.GetNext();
        if (childSession == NULL)
          break;

        WriteResubmitSession(childSession, serviceToSessionSet);
      }
    }
    }

    // Finalize by committing to staging and moving data into core schema (t_session_state).
    // Also mark the message as completed (t_message).
    if(mIsOracle)
    {
      mArrayInsertToSuccessTable->ExecuteBatch();
      mConnection->CommitTransaction();
    }
    else
    {
      mBcpInsertToSuccessTable->ExecuteBatch();
    }

    // Do a sequenced insert of the new session states.
    hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
    if (FAILED(hr))
    {
      SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
               "Failed allocating rowset");
      return FALSE;
    }
    rowset->Init(L"Queries\\Pipeline");
    rowset->JoinDistributedTransaction((ROWSETLib::IMTTransaction *) apTran.GetInterfacePtr());
    rowset->SetQueryTag("__UPDATE_MESSAGE_SUCCESS_FROM_STAGING__");
    rowset->AddParam("%%ID_MESSAGE%%", aMessageID);
    rowset->AddParam("%%MAX_DATE%%", GetMaxMTOLETime());
    rowset->Execute();

    // D'tor handles this now.
//     rowset->JoinDistributedTransaction(NULL);
  }
  catch(COdbcException & e)
  {
    //marks the database as needing to be re-initialized next time
    Clear();

    std::string buffer;
    buffer = "ODBC exception caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += e.toString().c_str();
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
  }
  catch(_com_error & e)
  {
    //marks the database as needing to be re-initialized next time
    Clear();

    std::string buffer;
    buffer = "COM error caught in ";
    buffer += functionName;
    buffer += ": ";
    buffer += (const char*)(e.Description());
	  mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
    return FALSE;
  }
  return TRUE;
}

