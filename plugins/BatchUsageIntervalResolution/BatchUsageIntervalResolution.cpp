/**************************************************************************
 * @doc INSERTSESSION
 *
 * Copyright 2000 by MetraTech Corporation
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
 *
 * Created by: Travis Gebhardt
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metralite.h>
#include <MTUtil.h>
#include <mttime.h>
#include <mtglobal_msg.h>
#include <mtprogids.h>
#include <BatchPlugInSkeleton.h>

#include <MSIX.h>

#include <NTThreader.h>
#include <NTThreadLock.h>

#include <propids.h>

#include <OdbcSessionRouter.h>
#include <OdbcException.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcResultSet.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcConnMan.h>
#include <OdbcResourceManager.h>

#include <autoptr.h>
#include <errutils.h>
#include <perfshare.h>
#include <reservedproperties.h>
#include <mtcomerr.h>
#include <formatdbvalue.h>

using MTPipelineLib::IMTConfigPropSetPtr;
using MTPipelineLib::IMTConfigPropPtr;

typedef MTautoptr<COdbcResultSet> COdbcResultSetPtr;
typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;


// generate using uuidgen
CLSID CLSID_BATCHUSAGEINTERVALRESOLUTION = { /* 61df605b-931c-4980-a8a6-597463b86953 */
	0x61df605b,
	0x931c,
	0x4980,
	{0xa8, 0xa6, 0x59, 0x74, 0x63, 0xb8, 0x69, 0x53}
};


class ATL_NO_VTABLE BatchUsageIntervalResolution
	: public MTBatchPipelinePlugIn<BatchUsageIntervalResolution, &CLSID_BATCHUSAGEINTERVALRESOLUTION>
{
protected:
	virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																			 MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																			 MTPipelineLib::IMTNameIDPtr aNameID,
																			 MTPipelineLib::IMTSystemContextPtr aSysContext);
	virtual HRESULT BatchPlugInShutdownDatabase();
	virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet);
	virtual HRESULT BatchPlugInInitializeDatabase();

	
private:
	template <class T>
	void InsertIntoTempTable(vector<MTPipelineLib::IMTSessionPtr>& aSessionArray,
													 T arStatement,
                           COdbcConnectionHandle& connection);

	void AddValidationRequest(unsigned int requestID,
                            long accountID,
														long intervalID,
														BOOL isOkToLogDebug);

	BOOL Validate(vector<MTPipelineLib::IMTSessionPtr>& sessions);

	void TruncateTempTable(COdbcConnectionHandle& connection);
	
	HRESULT ResolveBatch(vector<MTPipelineLib::IMTSessionPtr>& aSessions, COdbcConnectionHandle & connection);


private:
	MTPipelineLib::IMTLogPtr    mLogger;
	MTPipelineLib::IMTLogPtr    mPerfLogger;
	MTPipelineLib::IMTNameIDPtr mNameID;

	// used for resolution against temp table
  MTAutoSingleton<COdbcResourceManager> mOdbcManager;
	boost::shared_ptr<COdbcConnectionCommand> mConnectionCommand;

	boost::shared_ptr<COdbcPreparedInsertStatementCommand> mOracleArrayInsertToTempTableCommand;
	boost::shared_ptr<COdbcPreparedArrayStatementCommand> mSqlArrayInsertToTempTableCommand;
	boost::shared_ptr<COdbcPreparedBcpStatementCommand>   mBcpInsertToTempTableCommand;
	boost::shared_ptr<COdbcPreparedArrayStatementCommand> mResolveBySessionTimeStatementCommand;

  typedef std::map<std::string, std::vector<long>*> IntervalToRequestMap;
	IntervalToRequestMap mIntervalToRequestMap;
	std::string mValidationIntervalRequests;
  std::string mValidationAccountRequests;

	unsigned int mResolutionRequestCount;
	unsigned int mValidationRequestCount;

	ITransactionPtr mTransaction;

	MTPipelineLib::IMTSQLRowsetPtr mQueryAdapter;

	long mTimestampPropID;
	long mAccountPropID;
	long mUsageIntervalPropID;

	BOOL mUseBcpFlag;
	int mArraySize;
	std::string mTempTableName;
	std::string mTagName;

	unsigned long mTotalSQLExecutionMS;
	__int64 mTotalFetchTicks;
	__int64 mInsertTempTableTicks;
	__int64 mTruncateTableTicks;
	__int64 mTotalValidationTicks;

private:
	// perfmon instrumentation
	PerfShare mPerfShare;
	SharedStats * mpStats;
};

PLUGIN_INFO(CLSID_BATCHUSAGEINTERVALRESOLUTION, BatchUsageIntervalResolution,
						"MetraPipeline.UsageIntervalResolution.1", "MetraPipeline.UsageIntervalResolution", "Free")


/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT BatchUsageIntervalResolution::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																													 MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																													 MTPipelineLib::IMTNameIDPtr aNameID,
																													 MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	const char* procName = "BatchUsageIntervalResolution::BatchPlugInConfigure";
	HRESULT hr;
	
	mNameID = aNameID;
	mLogger = aLogger;
	mPerfLogger = MTPipelineLib::IMTLogPtr(MTPROGID_LOG);
	mPerfLogger->Init("logging\\perflog", "[UsageIntervalResolution]");

	mUseBcpFlag = TRUE;

	PipelinePropIDs::Init();
	
	// NOTE: The stage harness may configure this plug-in directly
	// when trying to write a failed session to the error product view.
	// The harness will pass in a NULL propset.

	// allow the user to set size of batches/arrays.  default is 1000.
	if (aPropSet != NULL &&
			VARIANT_TRUE == aPropSet->NextMatches("batch_size", MTPipelineLib::PROP_TYPE_INTEGER))
	{
		mArraySize = aPropSet->NextLongWithName("batch_size");
	}
	else
	{
		// high array size benefits BCP especially
		mArraySize = 1000;
	}

	if (aPropSet != NULL &&
			aPropSet->NextMatches("properties", MTPipelineLib::PROP_TYPE_SET) == VARIANT_TRUE)
	{
		// reads in the properties (if any)
		IMTConfigPropSetPtr propertiesset = aPropSet->NextSetWithName(L"properties");
		if (propertiesset == NULL)
			return Error("No properties found in the properties set");

		DECLARE_PROPNAME_MAP(inputs)
			DECLARE_PROPNAME_OPTIONAL(MT_TIMESTAMP_PROP_A, &mTimestampPropID)
			DECLARE_PROPNAME_OPTIONAL(MT_PAYINGACCOUNT_PROP_A, &mAccountPropID)
			DECLARE_PROPNAME_OPTIONAL(MT_INTERVALID_PROP_A, &mUsageIntervalPropID)
		END_PROPNAME_MAP
		
		hr = ProcessProperties(inputs, propertiesset, aNameID, aLogger, procName);
		if (FAILED(hr))
		  return hr;
	}
	else
	{
		mTimestampPropID = -1;
		mAccountPropID = -1;
		mUsageIntervalPropID = -1;
	}

	// create a unique name based on the stage name and plug-in name
	mTagName = GetTagName(aSysContext);

	// defaults the prop IDs if they weren't specified
	if (mTimestampPropID == -1)
		mTimestampPropID = PipelinePropIDs::TimestampCode();
	
	if (mAccountPropID == -1)
		mAccountPropID = PipelinePropIDs::PayingAccountCode();
	
	if (mUsageIntervalPropID == -1)
		mUsageIntervalPropID = PipelinePropIDs::IntervalIdCode();


	// initializes the perfmon integration library
	if (!mPerfShare.Init())
	{
		std::string buffer;
		StringFromError(buffer, "Unable to initialize perfmon counters", 
										mPerfShare.GetLastError());
		return Error(buffer.c_str());
	}
	mpStats = &mPerfShare.GetWriteableStats();

  std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpStatements;
  std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayStatements;
  std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertStatements;

	// prepares temp table insert query
	if (IsOracle())
	{
		mUseBcpFlag = FALSE;
		mTempTableName = "t_arg_intervalres";
	}
	else
		mTempTableName = ("tmp_intres_" + mTagName).c_str();

	if (mUseBcpFlag)
	{
		COdbcBcpHints hints;
		// use minimally logged inserts.
		// TODO: this may only matter if database recovery model settings are correct.
		//       however, it won't hurt if they're not
		hints.SetMinimallyLogged(true);
		mBcpInsertToTempTableCommand = boost::shared_ptr<COdbcPreparedBcpStatementCommand>(
      new COdbcPreparedBcpStatementCommand(mTempTableName, hints));
    bcpStatements.push_back(mBcpInsertToTempTableCommand);
	}
	else
	{

		if (IsOracle())
		{
			mOracleArrayInsertToTempTableCommand = boost::shared_ptr<COdbcPreparedInsertStatementCommand>(
        new COdbcPreparedInsertStatementCommand(mTempTableName, mArraySize, true));
      insertStatements.push_back(mOracleArrayInsertToTempTableCommand);
		}
		else
		{
			mSqlArrayInsertToTempTableCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(
        new COdbcPreparedArrayStatementCommand(
          "insert into " + mTempTableName +
          " (id_request, id_acc, dt_session, b_override) "
          "values  (?, ?, ?, ?)",
          mArraySize,
          true));


      arrayStatements.push_back(mSqlArrayInsertToTempTableCommand);
		}
	}

	mQueryAdapter.CreateInstance(MTPROGID_SQLROWSET);
	_bstr_t queryString;
	mQueryAdapter->Init("Queries\\Database");
	mQueryAdapter->SetQueryTag("__RESOLVE_USAGE_INTERVAL_BATCH__");
	mQueryAdapter->AddParam("%%TABLE_NAME%%", mTempTableName.c_str());
	queryString = mQueryAdapter->GetQueryString();
	mQueryAdapter = NULL; // Release connection

	mResolveBySessionTimeStatementCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(
    new COdbcPreparedArrayStatementCommand((const char *) queryString, 1, true));
  arrayStatements.push_back(mResolveBySessionTimeStatementCommand);
    
  mConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
    new COdbcConnectionCommand(COdbcConnectionManager::GetConnectionInfo("NetMeter"),
                               COdbcConnectionCommand::TXN_AUTO,
                               FALSE==IsOracle(),
                               bcpStatements,
                               arrayStatements,
                               insertStatements));
                                             
  mOdbcManager->RegisterResourceTree(mConnectionCommand);

	return S_OK;
}


HRESULT BatchUsageIntervalResolution::BatchPlugInInitializeDatabase()
{
	// this is a read-only plugin, so retry is safe
	AllowRetryOnDatabaseFailure(TRUE);

	COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
	COdbcConnectionPtr conn (new COdbcConnection(info));

  conn->SetAutoCommit(true);
	
	if (!IsOracle())
	{
		// creates temp table for plugin input parameters
		COdbcStatementPtr createTempTable = conn->CreateStatement();
		createTempTable->ExecuteUpdate("IF OBJECT_ID('" + mTempTableName + "') IS NULL "
																	 "CREATE TABLE " + mTempTableName +
																	 "(id_request INT NOT NULL,"
																	 "id_acc INT NOT NULL,"
																	 "dt_session DATETIME NOT NULL,"
																	 "b_override INT NOT NULL)");
		conn->CommitTransaction();
	}


	return S_OK;
}



HRESULT BatchUsageIntervalResolution::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
  COdbcConnectionHandle connection(mOdbcManager, mConnectionCommand);

	// gets an iterator for the set of sessions
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
		return hr;

	// resets performance counters
	mTotalSQLExecutionMS = 0;
	mTotalFetchTicks = 0;
	mTotalValidationTicks = 0;

	LARGE_INTEGER freq;
	LARGE_INTEGER tick;
	LARGE_INTEGER tock;
	::QueryPerformanceFrequency(&freq);

	// iterates through the session set
	::QueryPerformanceCounter(&tick);
	int totalRecords=0;
	vector<MTPipelineLib::IMTSessionPtr> sessionArray;

	// get the DTC txn to be joined
	// The DTC txn is owned by the MTObjectOwner and shared among all sessions in the session set.
	// if null, no transaction has been started yet.
	MTPipelineLib::IMTTransactionPtr transaction;
	mTransaction = NULL;
	bool first = true;

	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
					
		// is this the last session in the set?
		if (session == NULL) 
			break;

		if (first)
		{
			first = false;

			// Get the txn from the first session in the set.
			// don't begin a new transaction unless 
			transaction = GetTransaction(session);

			if (transaction != NULL)
			{
				ITransactionPtr itrans = transaction->GetTransaction();
				ASSERT(itrans != NULL);
				mTransaction = itrans;
			}
		}

		totalRecords++;
		sessionArray.push_back(session);

		// resolves a chunk of sessions
		if (sessionArray.size() >= (unsigned int) mArraySize)
		{
			ASSERT(sessionArray.size() == (unsigned int) mArraySize);
			hr = ResolveBatch(sessionArray, connection);
			if (FAILED(hr))
				return hr;
		}
	}

	// resolves the last partial chunk if necessary
	if (sessionArray.size() > 0)
	{
		hr = ResolveBatch(sessionArray, connection);
		if (FAILED(hr))
			return hr;
	}

	connection->CommitTransaction();
	mTransaction = NULL;
	::QueryPerformanceCounter(&tock);

	// overall performance statistics
	char buf[256];
	long ms = (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart);
	sprintf(buf, "BatchUsageIntervalResolution::PlugInProcessSessions for %d records took %d milliseconds", totalRecords, ms);
	mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
	mpStats->SetTiming(SharedStats::PILOOKUP_PROCESS_SESSIONS, ms);	// TODO: this not PILOOKUP

	// main SQL query performance statistics
	sprintf(buf, "BatchUsageIntervalResolution::SQLExecute for %d records took %d milliseconds", totalRecords, mTotalSQLExecutionMS);
	mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
	mpStats->SetTiming(SharedStats::PILOOKUP_SQL_EXECUTE, ms); // TODO: this not PILOOKUP

	// fetch performance statistics
	ms = (long) (1000 * mTotalFetchTicks / freq.QuadPart);
	sprintf(buf, "BatchUsageIntervalResolution fetch for %d records took %d milliseconds", totalRecords, ms);
	mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
	mpStats->SetTiming(SharedStats::PILOOKUP_FETCH, ms);	// TODO: this not PILOOKUP

	// validation performance statistics
	ms = (long) (1000 * mTotalValidationTicks / freq.QuadPart);
	sprintf(buf, "BatchUsageIntervalResolution validation for %d records took %d milliseconds", totalRecords, ms);
	mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));

	return S_OK;
}

HRESULT BatchUsageIntervalResolution::ResolveBatch(vector<MTPipelineLib::IMTSessionPtr>& aSessionArray,
                                                   COdbcConnectionHandle& connection)
{
	TruncateTempTable(connection);

	mResolutionRequestCount = 0;
	mValidationRequestCount = 0;
	mValidationIntervalRequests = "";
  mValidationAccountRequests = "";

	// inserts sessions' arguments into the temp table
	if(mUseBcpFlag)
		InsertIntoTempTable(aSessionArray, connection[mBcpInsertToTempTableCommand], connection);
	else if (IsOracle())
		InsertIntoTempTable(aSessionArray, connection[mOracleArrayInsertToTempTableCommand], connection);
  else
		InsertIntoTempTable(aSessionArray, connection[mSqlArrayInsertToTempTableCommand], connection);

	BOOL isOkToLogDebug = mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);
	BOOL batchFailed = FALSE;
	BOOL fallbackJoined = FALSE;
  COdbcConnectionPtr fallbackConnection;

	// only performs resolution query if we have at least
	// one resolution request (dt_session based)
	if (mResolutionRequestCount > 0)
	{
		// enter transaction
		if (mTransaction != NULL)
			connection->JoinTransaction(mTransaction);
		
		// performs the usage interval resolution
		COdbcPreparedResultSetPtr resultSet = connection[mResolveBySessionTimeStatementCommand]->ExecuteQuery();

		mTotalSQLExecutionMS += (long) connection[mResolveBySessionTimeStatementCommand]->GetTotalExecuteMillis();
		
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceCounter(&tick);
		
		long requestID, usageIntervalID;
		unsigned int resolvedCount = 0;
		// loops over result set setting properties into individual sessions
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Results of usage interval resolution:");
		while(resultSet->Next())
		{
			// retrieve a session's results from the current row
			requestID = resultSet->GetInteger(1);
			ASSERT(!resultSet->WasNull());
			
			MTPipelineLib::IMTSessionPtr session = aSessionArray[requestID];
			
			usageIntervalID = resultSet->GetInteger(2);
			
			// no effective open usage interval was found which contained the
			// transaction's time stamp. this should be an exceptional case.
			if (resultSet->WasNull()) 
			{
				
				wchar_t buffer[1024];
				swprintf(buffer,
								 L"An effective, open usage interval was not found for request %d!",
								 requestID);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
				
				// TODO: extra _Timestamp lookup
				// formats the timestamp
				DATE timestamp = session->GetOLEDateProperty(mTimestampPropID);
				BSTR bstrVal;
				HRESULT hr = VarBstrFromDate(timestamp, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
				_bstr_t displayTimeBuffer(bstrVal, false);
				std::wstring dbTimeBuffer;
				FormatValueForDB(_variant_t(timestamp, VT_DATE), IsOracle(), dbTimeBuffer);
				
				long accountID = resultSet->GetInteger(3);
				ASSERT(!resultSet->WasNull());
				
				// resolves the next open usage interval
				// NOTE: can't prepare the statement directly because of ODBC parameter binding bugs
				mQueryAdapter.CreateInstance(MTPROGID_SQLROWSET);
				mQueryAdapter->Init("Queries\\Database");
				mQueryAdapter->SetQueryTag("__RESOLVE_NEXT_OPEN_USAGE_INTERVAL__");
				mQueryAdapter->AddParam("%%DT_SESSION%%", dbTimeBuffer.c_str(), VARIANT_TRUE);
				mQueryAdapter->AddParam("%%ID_ACC%%", accountID);
				_bstr_t queryString = mQueryAdapter->GetQueryString();
				mQueryAdapter = NULL; // Release connection

				// enter transaction
        fallbackConnection = new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter"));
				if (mTransaction != NULL && !fallbackJoined)
				{
					fallbackConnection->JoinTransaction(mTransaction);
					fallbackJoined = TRUE;
				}

        COdbcStatementPtr fallbackStmt (fallbackConnection->CreateStatement());
				COdbcResultSetPtr innerResultSet = fallbackStmt->ExecuteQuery((const char *) queryString);
				if (!innerResultSet->Next()) 
				{
					// strange... there is no currently associated interval. someone has either
					// mucked around with tables or warped time
					
					swprintf(buffer,
									 L"Could not find the next open usage interval for account %d based on a transaction time of '%s'!",
									 accountID,
									 (const wchar_t*) displayTimeBuffer);
					mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
					
					session->MarkAsFailed(buffer, PIPE_ERR_USAGE_INTERVAL_RESOLUTION);
					
					batchFailed = TRUE;
					continue;
				}
				
				usageIntervalID = innerResultSet->GetInteger(1);
				
				swprintf(buffer,
								 L"Falling back to the next open usage interval %d for account %d based on transaction time '%s'",
								 usageIntervalID,
								 accountID,
								 (const wchar_t*) displayTimeBuffer);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
			}
			
			// set the results back into the session
			session->SetLongProperty(mUsageIntervalPropID, usageIntervalID);
			
			if (isOkToLogDebug)
			{
				wchar_t buffer[1024];
				swprintf(buffer, L"Resolved usage interval: usageIntervalID = %d; requestID = %d",
								 usageIntervalID, requestID);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
			}
			
			resolvedCount++;
		}
		ASSERT(!resultSet->NextResultSet());

		// checks to make sure the request to result relationship is one-to-one.
		// if it isn't, a serious bug exists!
		if (resolvedCount > mResolutionRequestCount)
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, "More results were returned than there were requests!");
			

		// leaves the transaction
		if (mTransaction != NULL)
		{
			connection->LeaveTransaction();

			if (fallbackJoined)
				fallbackConnection->JoinTransaction(mTransaction);
		}

		::QueryPerformanceCounter(&tock);
		mTotalFetchTicks += (tock.QuadPart - tick.QuadPart);
	}
	
	// only performs validation query if we have at least
	// one validation request (_IntervalID is set)
	if (mValidationRequestCount > 0)
		batchFailed = Validate(aSessionArray) || batchFailed;

	aSessionArray.clear();

	if (batchFailed)
		return PIPE_ERR_SUBSET_OF_BATCH_FAILED;
	
	return S_OK;
}


void BatchUsageIntervalResolution::TruncateTempTable(COdbcConnectionHandle & connection)
{
	LARGE_INTEGER tick, tock;
	::QueryPerformanceCounter(&tick);

	COdbcStatementPtr truncate = connection->CreateStatement();
	int numRows = truncate->ExecuteUpdate("truncate table " + mTempTableName);
	//ASSERT(numRows == 0 || numRows == mArraySize);

	connection->CommitTransaction();

	::QueryPerformanceCounter(&tock);
	mTruncateTableTicks += (tock.QuadPart - tick.QuadPart);
}


template<class T>
void BatchUsageIntervalResolution::InsertIntoTempTable(vector<MTPipelineLib::IMTSessionPtr>& aSessionArray,
																											 T arStatement,
                                                       COdbcConnectionHandle & connection)
{
	LARGE_INTEGER tick,tock;
	::QueryPerformanceCounter(&tick);

	//cache this to minimize cost in the following loop
	BOOL isOkToLogDebug = mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);
	
	unsigned int i;
	for (i=0; i < aSessionArray.size(); i++)
	{
		MTPipelineLib::IMTSessionPtr session = aSessionArray[i];

		// if session is a child then skip it
		if (session->GetParentID() != -1)
			continue;

    // Get account id.
    long accountID = session->GetLongProperty(mAccountPropID);

		// if _IntervalID is set it must be validated that
		// the interval is not hard closed (CR10386)
		bool softCloseOverride = false;
		if (session->PropertyExists(mUsageIntervalPropID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)
		{
			long intervalID = session->GetLongProperty(mUsageIntervalPropID);
			if (intervalID == -1)
			{
				// the interval will be resolved via _Timestamp as normal,
				// except soft closed intervals are also considered as valid
				// choices. This was a necessary change to make writing scheduled
				// adapters that meter behave correctly. (CR10750)
				softCloseOverride = true;
			}
			else
			{
				AddValidationRequest(i, accountID, intervalID, isOkToLogDebug);
				continue;
			}
		}
			

		// sets the request ID (internal ID used to match up responses)
		arStatement->SetInteger(1, (long) i);

		// sets the account ID
		arStatement->SetInteger(2, accountID);

		// sets the timestamp
		DATE timestamp = session->GetOLEDateProperty(mTimestampPropID);
		TIMESTAMP_STRUCT odbcTimestamp;
		OLEDateToOdbcTimestamp(&timestamp, &odbcTimestamp);
		// TODO: this conversion routine should handle errors, currently it returns void
		arStatement->SetDatetime(3, odbcTimestamp);

		arStatement->SetInteger(4, softCloseOverride ? 1 : 0);

		// logs debug info
		if (isOkToLogDebug) 
		{
			// formats the timestamp
			BSTR bstrVal;
			HRESULT hr = VarBstrFromDate(timestamp, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
			_bstr_t timeBuffer(bstrVal, false);

			wchar_t buffer[1024];
			swprintf(buffer,
							 L"Resolving usage interval based on: accountID = %d; timestamp = '%s'; requestID = %d",
							 accountID, (const wchar_t *) timeBuffer, i);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
		}
		
		arStatement->AddBatch();

		mResolutionRequestCount++;
	}

	// Insert the records to the temp table
	arStatement->ExecuteBatch();
	
	connection->CommitTransaction();

	::QueryPerformanceCounter(&tock);
	mInsertTempTableTicks += (tock.QuadPart - tick.QuadPart);
}

void BatchUsageIntervalResolution::AddValidationRequest(unsigned int requestID,
                                                        long accountID,
																												long intervalID,
																												BOOL isOkToLogDebug)
{
  // construct validation key
	char buffer[32];
	sprintf(buffer, "%d_%d", accountID, intervalID);
  std::string key = buffer;

	// has the interval ID already been encountered?
	IntervalToRequestMap::const_iterator findIt;
	findIt = mIntervalToRequestMap.find(key);
	if (findIt == mIntervalToRequestMap.end())
	{
		// not found - adds the interval ID to the list
		if (mValidationRequestCount == 0)
			sprintf(buffer, "%d", intervalID);
		else
			sprintf(buffer, ", %d", intervalID);
		mValidationIntervalRequests += buffer;

		if (mValidationRequestCount == 0)
			sprintf(buffer, "%d", accountID);
		else
			sprintf(buffer, ", %d", accountID);
    mValidationAccountRequests += buffer;

		mValidationRequestCount++;

		// creates a new request list and adds the request ID to the list
		std::vector<long> * requestList = new std::vector<long>;
		requestList->push_back(requestID);
		
		// associates the request list with interval ID, account ID pairing.
		mIntervalToRequestMap[key] = requestList;
		
		if (isOkToLogDebug) 
		{
			wchar_t buffer[128];
      swprintf(buffer, L"Validating usage interval: %d, account: %d", intervalID, accountID);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
		}
	}
	else
	{
		// interval ID was found!
		
		// adds the request ID to the request list associated with the interval
		(mIntervalToRequestMap[key])->push_back(requestID);
	}
}

BOOL BatchUsageIntervalResolution::Validate(vector<MTPipelineLib::IMTSessionPtr>& sessions)
{
	LARGE_INTEGER tick;
	LARGE_INTEGER tock;
	::QueryPerformanceCounter(&tick);

	MTPipelineLib::IMTSQLRowsetPtr rowset = sessions[0]->GetRowset("Queries\\Database");
	rowset->SetQueryTag("__VALIDATE_INTERVALID_BATCH__");
  rowset->AddParam("%%ACCOUNT_ID_LIST%%", mValidationAccountRequests.c_str());
	rowset->AddParam("%%INTERVAL_ID_LIST%%", mValidationIntervalRequests.c_str());
	rowset->Execute();
	
	// iterates over the violations 
 	char buffer[32];
	BOOL failure = FALSE;
	while (! (bool) rowset->GetRowsetEOF())
	{
		_variant_t val = rowset->GetValue(0L);
		long accountID = val.lVal;

		val = rowset->GetValue(1L);
		long intervalID = val.lVal;
    
	  sprintf(buffer, "%d_%d", accountID, intervalID);
    std::string key = buffer;

		// looks up requests associated with the usage interval
		std::vector<long>* requests = mIntervalToRequestMap[key];
		std::vector<long>::const_iterator it;
		for (it = requests->begin(); it != requests->end(); it++)
		{
			// fails each session
			// ESR-4769 increase the size of the buffer from 128 to 256, the message being written to the buffer is 128 characters, 
			// writing 128 characters to a wchar_t buffer[128] was causing a pipeline failure because we are writing over part of the call stack			
			wchar_t buffer[256];
			swprintf(buffer,
							 L"Account %d, usage interval %d referenced by the _IntervalID property is hard closed and cannot accept new usage!",
							 accountID, intervalID);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
			(sessions[*it])->MarkAsFailed(buffer, PIPE_ERR_USAGE_INTERVAL_RESOLUTION);
		}

		failure = TRUE;
		rowset->MoveNext();
	}

	// deallocates the request lists
	IntervalToRequestMap::iterator it;
	for (it = mIntervalToRequestMap.begin(); it != mIntervalToRequestMap.end(); it++)
		delete it->second;
	mIntervalToRequestMap.clear();

	::QueryPerformanceCounter(&tock);
	mTotalValidationTicks += (tock.QuadPart - tick.QuadPart);
	
	return failure;
}


HRESULT BatchUsageIntervalResolution::BatchPlugInShutdownDatabase()
{
  mOdbcManager->Reinitialize(mConnectionCommand);

	return S_OK;
}
