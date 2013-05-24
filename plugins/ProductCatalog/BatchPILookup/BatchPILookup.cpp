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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <BatchPlugInSkeleton.h>

#include <MSIX.h>

#include <NTThreader.h>
#include <NTThreadLock.h>

#include <propids.h>
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
#include <mtprogids.h>
#include <mtcomerr.h>

#import <MTProductCatalog.tlb> rename("EOF", "EOFX")
using MTPRODUCTCATALOGLib::IMTProductCatalogPtr;
using MTPRODUCTCATALOGLib::IMTPriceableItemPtr;

typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;


// generate using uuidgen
CLSID CLSID_BATCHPILOOKUP = { /*c1f5bf87-c5b7-4efb-9b4f-f9c76f669813 */
    0xc1f5bf87,
    0xc5b7,
    0x4efb,
    {0x9b, 0x4f, 0xf9, 0xc7, 0x6f, 0x66, 0x98, 0x13}
  };


class ATL_NO_VTABLE BatchPILookup
	: public MTBatchPipelinePlugIn<BatchPILookup, &CLSID_BATCHPILOOKUP>
{
protected:
	virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																			 MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																			 MTPipelineLib::IMTNameIDPtr aNameID,
																			 MTPipelineLib::IMTSystemContextPtr aSysContext);
	virtual HRESULT BatchPlugInInitializeDatabase();
	virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet);
	virtual HRESULT BatchPlugInShutdownDatabase();
	
private:
	typedef std::map<std::string, long> StringToLongMap;
	
	template <class T>
	HRESULT InsertIntoTempTable(vector<MTPipelineLib::IMTSessionPtr>& aSessionArray,
															T arStatement,
                              COdbcConnectionHandle& connection);
	
	void TruncateTempTable(COdbcConnectionHandle& connection);
	
	HRESULT ResolveBatch(vector<MTPipelineLib::IMTSessionPtr>& aSessions,
											 StringToLongMap & arTemplateIDMap,
                       COdbcConnectionHandle& connection);

	HRESULT GetTemplatesForUnsubscribedAccounts(vector<MTPipelineLib::IMTSessionPtr>& aSessionArray,
																							StringToLongMap& arTemplateIDMap,
																							vector<bool> arResolutionArray);
	
	NTThreadLock mValuesLock;
	
private:
	MTPipelineLib::IMTLogPtr    mLogger;
	MTPipelineLib::IMTLogPtr    mPerfLogger;
	MTPipelineLib::IMTNameIDPtr mNameID;
	IMTProductCatalogPtr mCatalog;

  MTAutoSingleton<COdbcResourceManager> mOdbcManager;
	boost::shared_ptr<COdbcPreparedInsertStatementCommand> mOracleArrayInsertToTempTableCommand;
	boost::shared_ptr<COdbcPreparedArrayStatementCommand> mSqlArrayInsertToTempTableCommand;
	boost::shared_ptr<COdbcPreparedBcpStatementCommand>   mBcpInsertToTempTableCommand;
	boost::shared_ptr<COdbcPreparedArrayStatementCommand> mStatementCommand;

	boost::shared_ptr<COdbcConnectionCommand>    mConnectionCommand;

	BOOL mUseBcpFlag;
	BOOL mLookupByID;
	int mArraySize;
	std::string mTempTableName;
	std::string mTagName;
	
	ITransactionPtr mTransaction;

	// TODO: subscriptionID

	// inputs
	long mTimestampPropID;
	long mPriceableItemNamePropID;
	long mAccountPropID;

	// outputs
	long mPriceableItemInstanceIDPropID;
	long mProductOfferingIDPropID;
	long mSubscriptionIDPropID;

	// inputs/outputs
	long mPriceableItemTemplateIDPropID;


	// performance stats
	double  mTotalMillis;
	__int64 mTotalRecords;
	__int64 mTotalFetchTicks;
	__int64 mInsertTempTableTicks;
	__int64 mTruncateTableTicks;

private:
	// perfmon instrumentation
	PerfShare mPerfShare;
	SharedStats * mpStats;
};

PLUGIN_INFO(CLSID_BATCHPILOOKUP, BatchPILookup,
						"MetraPipeline.PILookup.1", "MetraPipeline.PILookup", "Free")


HRESULT BatchPILookup::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																						MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																						MTPipelineLib::IMTNameIDPtr aNameID,
																						MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	const char * functionName = "BatchPILookup::BatchPlugInConfigure";

	mNameID = aNameID;
	mLogger = aLogger;
	mPerfLogger = MTPipelineLib::IMTLogPtr(MTPROGID_LOG);
	mPerfLogger->Init("logging\\perflog", "[PILookup]");

	mTotalRecords = 0;
	mTotalMillis = 0.0;
	mTotalFetchTicks = 0;

	PipelinePropIDs::Init();

	// if the lookupbyid property is true, then the template ID is the basis of the lookup
	// (rather than the priceable item's name)
	if (aPropSet->NextMatches(L"lookupbyid", MTPipelineLib::PROP_TYPE_BOOLEAN) == VARIANT_TRUE)
		mLookupByID = aPropSet->NextBoolWithName(L"lookupbyid");
	else 
		mLookupByID = TRUE;
	if (mLookupByID)
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "PILookup will resolve based on template ID");
	else
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "PILookup will resolve based on name");

	//if the usebcpflag property is true, then the BCP interface is used
	if (aPropSet->NextMatches(L"usebcpflag", MTPipelineLib::PROP_TYPE_BOOLEAN) == VARIANT_TRUE)
		mUseBcpFlag = aPropSet->NextBoolWithName(L"usebcpflag") == VARIANT_TRUE;
	else
		mUseBcpFlag = TRUE;

  if (aPropSet->NextMatches(L"batchsize", MTPipelineLib::PROP_TYPE_INTEGER))
    mArraySize = aPropSet->NextLongWithName("batchsize");
  else
    mArraySize = 1000;

	DECLARE_PROPNAME_MAP(inputs)
		DECLARE_PROPNAME_OPTIONAL("_Timestamp", &mTimestampPropID)
		DECLARE_PROPNAME_OPTIONAL("_PriceableItemName", &mPriceableItemNamePropID)
		DECLARE_PROPNAME_OPTIONAL("_AccountID", &mAccountPropID)
		DECLARE_PROPNAME_OPTIONAL("_PriceableItemInstanceID", &mPriceableItemInstanceIDPropID)
		DECLARE_PROPNAME_OPTIONAL("_ProductOfferingID", &mProductOfferingIDPropID)
		DECLARE_PROPNAME_OPTIONAL("_SubscriptionID", &mSubscriptionIDPropID)
		DECLARE_PROPNAME_OPTIONAL("_PriceableItemTemplateID", &mPriceableItemTemplateIDPropID)
	END_PROPNAME_MAP
		
	HRESULT hr = ProcessProperties(inputs, aPropSet, aNameID, aLogger, functionName);
	if (!SUCCEEDED(hr))
		return hr;

	// default input propids
	if (mTimestampPropID == -1)
		mTimestampPropID = aNameID->GetNameID(L"_Timestamp");

	if (mPriceableItemNamePropID == -1)
		mPriceableItemNamePropID = aNameID->GetNameID(L"_PriceableItemName");

	if (mAccountPropID == -1)
		mAccountPropID = aNameID->GetNameID(L"_AccountID");

	// default output propids
	if (mPriceableItemInstanceIDPropID == -1)
		mPriceableItemInstanceIDPropID = PipelinePropIDs::PriceableItemInstanceIDCode();

	if (mProductOfferingIDPropID == -1)
		mProductOfferingIDPropID = PipelinePropIDs::ProductOfferingIDCode();

	if (mSubscriptionIDPropID == -1)
		mSubscriptionIDPropID = PipelinePropIDs::SubscriptionIDCode();

	// default input/output propids
	if (mPriceableItemTemplateIDPropID)
		mPriceableItemTemplateIDPropID = PipelinePropIDs::PriceableItemTemplateIDCode();

	hr = mCatalog.CreateInstance("MetraTech.MTProductCatalog");
	if (FAILED(hr))
		return Error(L"Unable to create product catalog object", IID_IMTPipelinePlugIn, hr);

	// initializes the perfmon integration library
	if (!mPerfShare.Init())
	{
		std::string buffer;
		StringFromError(buffer, "Unable to initialize perfmon counters", 
										mPerfShare.GetLastError());
		return Error(buffer.c_str());
	}
	mpStats = &mPerfShare.GetWriteableStats();

	// create a unique name based on the stage name and plug-in name
	mTagName = GetTagName(aSysContext);

  // create commands for database resources.
	if (IsOracle())
	{
		mTempTableName = "t_arg_pilookup";
		mUseBcpFlag = FALSE;
	}
	else
		mTempTableName = ("tmp_pilookup_" + mTagName).c_str();

	if (mUseBcpFlag)
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "PILookup will use BCP");
	else
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "PILookup will not use BCP");

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
          " (id_request, id_acc, dt_session, id_pi_template, nm_pi_name) "
          "values  (?, ?, ?, ?, ?)",
          mArraySize, true));
      arrayStatements.push_back(mSqlArrayInsertToTempTableCommand);
		}
	}


	// prepares the PI look up query (based on view)
	// if both template ID and PI name are given, then the template ID is used
	MTPipelineLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init("Queries\\ProductCatalog");
	rowset->SetQueryTag("__RESOLVE_PI_LOOKUP__");
	rowset->AddParam("%%TABLE_NAME%%", mTempTableName.c_str());
	_bstr_t queryString = rowset->GetQueryString();
	mStatementCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(
    new COdbcPreparedArrayStatementCommand((const char *) queryString, 1, true));
  arrayStatements.push_back(mStatementCommand);

  mConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
    new COdbcConnectionCommand(COdbcConnectionManager::GetConnectionInfo("NetMeter"), 
                               COdbcConnectionCommand::TXN_AUTO,
                               FALSE == IsOracle(),
                               bcpStatements,
                               arrayStatements,
                               insertStatements));

  mOdbcManager->RegisterResourceTree(mConnectionCommand);

	return S_OK;
}


HRESULT BatchPILookup::BatchPlugInInitializeDatabase()
{
	
	// this is a read-only plugin, so retry is safe
	AllowRetryOnDatabaseFailure(TRUE);
	
	COdbcConnectionInfo info =
		COdbcConnectionManager::GetConnectionInfo("NetMeter");
	boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(info));

	// use auto commit only if using bcp
	// don't use bcpflag to set autocommit
	conn->SetAutoCommit(true); //mUseBcpFlag ? true : false);

	// creates temp table for plugin input parameters (if not Oracle)

	if (!IsOracle())
	{
		COdbcStatementPtr createTempTable = conn->CreateStatement();
		createTempTable->ExecuteUpdate("if OBJECT_ID('" + mTempTableName + "') is null "
																	 "create table " + mTempTableName +
																	 " (id_request int NOT NULL, "
																	 "id_acc int NOT NULL, "
																	 "dt_session datetime NOT NULL, "
																	 "id_pi_template int NULL, "
																	 "nm_pi_name nvarchar(256) NULL)");  //TODO: is nm_pi_name too big?
		string tempIndexName = "idx_" + mTempTableName;
		createTempTable->ExecuteUpdate("if INDEXPROPERTY (OBJECT_ID('"
																	 + mTempTableName + "'), '" + tempIndexName
																	 + "', 'IndexId') is null "
																	 "create index " + tempIndexName +
																	 " on " + mTempTableName + " (id_pi_template)");
		conn->CommitTransaction();
	}


	return S_OK;
}


HRESULT BatchPILookup::BatchPlugInShutdownDatabase()
{
  mOdbcManager->Reinitialize(mConnectionCommand);

	return S_OK;
}


HRESULT BatchPILookup::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	StringToLongMap templateIDMap;

  COdbcConnectionHandle connection(mOdbcManager, mConnectionCommand);
	
	// gets an iterator for the set of sessions
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
		return hr;

	__int64 currentFetchTicks = mTotalFetchTicks;
	LARGE_INTEGER freq;
	LARGE_INTEGER tick;
	LARGE_INTEGER tock;
	::QueryPerformanceFrequency(&freq);

	// get the DTC txn to be joined
	// The DTC txn is owned by the MTObjectOwner and shared among all sessions in the session set.
	// if null, no transaction has been started yet.
	MTPipelineLib::IMTTransactionPtr transaction;
	mTransaction = NULL;
	bool first = true;

	// iterates through the session set
	::QueryPerformanceCounter(&tick);
	int totalRecords=0;
	vector<MTPipelineLib::IMTSessionPtr> sessionArray;
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
			hr = ResolveBatch(sessionArray, templateIDMap, connection);
			if (FAILED(hr))
				return hr;
		}
	}

	// resolves the last partial chunk if necessary
	if (sessionArray.size() > 0)
	{
		hr = ResolveBatch(sessionArray, templateIDMap, connection);
		if (FAILED(hr))
			return hr;
	}

	if (transaction != NULL)
		connection->LeaveTransaction();

	connection->CommitTransaction();
	mTransaction = NULL;
	::QueryPerformanceCounter(&tock);

	// overall performance statistics
	char buf[256];
	long ms = (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart);
	sprintf(buf, "BatchPILookup::PlugInProcessSessions for %d records took %d milliseconds", totalRecords, ms);
	mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
	mpStats->SetTiming(SharedStats::PILOOKUP_PROCESS_SESSIONS, ms);

	// main SQL query performance statistics
	ms = (long) (connection[mStatementCommand]->GetTotalExecuteMillis() - mTotalMillis);
	sprintf(buf, "BatchPILookup::SQLExecute for %d records took %d milliseconds", totalRecords, ms);
	mTotalMillis = connection[mStatementCommand]->GetTotalExecuteMillis();
	mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
	mpStats->SetTiming(SharedStats::PILOOKUP_SQL_EXECUTE, ms);

	// fetch performance statistics
	ms = (long) ((1000*(mTotalFetchTicks - currentFetchTicks))/freq.QuadPart);
	sprintf(buf, "BatchPILookup fetch for %d records took %d milliseconds", totalRecords, ms);
	mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
	mpStats->SetTiming(SharedStats::PILOOKUP_FETCH, ms);
	
	return S_OK;
}



HRESULT BatchPILookup::ResolveBatch(vector<MTPipelineLib::IMTSessionPtr>& aSessionArray,
																		StringToLongMap& arTemplateIDMap,
                                    COdbcConnectionHandle& connection)
{
	TruncateTempTable(connection);

	unsigned sessionsResolved = 0;
	vector<bool> resolutionArray;
	resolutionArray.resize(aSessionArray.size(), false);

	// inserts sessions' arguments into the temp table
	HRESULT hr;
	if(mUseBcpFlag)
		hr = InsertIntoTempTable(aSessionArray, connection[mBcpInsertToTempTableCommand], connection);
	else if (IsOracle())
		hr = InsertIntoTempTable(aSessionArray, connection[mOracleArrayInsertToTempTableCommand], connection);
  else
		hr = InsertIntoTempTable(aSessionArray, connection[mSqlArrayInsertToTempTableCommand], connection);
 	if (FAILED(hr))
		return hr;

	BOOL isOkToLogDebug = mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);

	// enter transaction
	if (mTransaction != NULL)
		connection->JoinTransaction(mTransaction);

	// performs the pilookup
	COdbcPreparedResultSetPtr resultSet = connection[mStatementCommand]->ExecuteQuery();

	LARGE_INTEGER tick;
	LARGE_INTEGER tock;
	::QueryPerformanceCounter(&tick);

	// loops over result set setting properties into individual sessions
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Results of priceable item lookups:");
	long requestID, subID, poID, templateID, instanceID;
	while(resultSet->Next())
	{
		// retrieve a session's results from the current row
		requestID = resultSet->GetInteger(1);
		ASSERT(!resultSet->WasNull());
		subID = resultSet->GetInteger(2);
		ASSERT(!resultSet->WasNull());
		poID = resultSet->GetInteger(3);
		ASSERT(!resultSet->WasNull());
		templateID = resultSet->GetInteger(4);
		ASSERT(!resultSet->WasNull());
		instanceID = resultSet->GetInteger(5);
		ASSERT(!resultSet->WasNull());

		// marks this session as being properly resolved
		resolutionArray[requestID] = true;
		sessionsResolved++;

		// set the results back into the session
		MTPipelineLib::IMTSessionPtr session = aSessionArray[requestID];
		session->SetLongProperty(mSubscriptionIDPropID, subID);
		session->SetLongProperty(mProductOfferingIDPropID, poID);
		session->SetLongProperty(mPriceableItemInstanceIDPropID, instanceID);
		session->SetLongProperty(mPriceableItemTemplateIDPropID, templateID);

		if (isOkToLogDebug)
		{
			wchar_t buffer[1024];
			swprintf(buffer, L"Resolved PI: poID = %d; instanceID = %d; subscriptionID = %d; templateID = %d; requestID = %d",
							 poID, instanceID, subID, templateID, requestID);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
		}

	}
	ASSERT(!resultSet->NextResultSet());

	if (mTransaction != NULL)
		connection->LeaveTransaction();

	// resolves the template IDs for unsubscribed accounts
	if (sessionsResolved < aSessionArray.size())
	{
		HRESULT hr = GetTemplatesForUnsubscribedAccounts(aSessionArray, arTemplateIDMap, resolutionArray);
		if (FAILED(hr))
			return hr;
	}
		
	::QueryPerformanceCounter(&tock);
	mTotalFetchTicks += (tock.QuadPart - tick.QuadPart);

	aSessionArray.clear();
	
	return S_OK;
}

	
HRESULT BatchPILookup::GetTemplatesForUnsubscribedAccounts(vector<MTPipelineLib::IMTSessionPtr>& arSessionArray,
																													 StringToLongMap& arTemplateIDMap,
																													 vector<bool> arResolutionArray)
{
	BOOL isOkToLogDebug = mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);
	BOOL allSessionsSucceeded = TRUE;

	for (int i = 0; i < (int) arResolutionArray.size(); i++)
	{
		if (!arResolutionArray[i])
		{
			MTPipelineLib::IMTSessionPtr session = arSessionArray[i];
			
			// does _TemplateID already exist?
			if (session->PropertyExists(mPriceableItemTemplateIDPropID,
																	MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)
				continue;
			
			std::string piName;
			try
			{
				piName = (const char *) session->GetStringProperty(mPriceableItemNamePropID);
			}
			catch (_com_error & e)
			{
				_bstr_t buffer = "Session is missing _PriceableItemName property!"; 
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
				session->MarkAsFailed(buffer, e.Error());
				allSessionsSucceeded = FALSE;
				continue;
			}
			
			// attempts to get the template ID from the cache
			long templateID;
			StringToLongMap::const_iterator findIt = arTemplateIDMap.find(piName);
			if (findIt != arTemplateIDMap.end()) 
			{
				templateID = findIt->second;
			}
			else
			{
				// looks it up the expensive way
				IMTPriceableItemPtr pi = mCatalog->GetPriceableItemByName(_bstr_t(piName.c_str()));
				if (pi == NULL)
				{
					std::string buffer = "Could not find priceable item with name = '";
					buffer += piName + "' (case sensitive)!";
					mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, _bstr_t(buffer.c_str()));
					
					session->MarkAsFailed(buffer.c_str(), MTPC_ITEM_NOT_FOUND);
					allSessionsSucceeded = FALSE;
					continue;
				}
				templateID = pi->GetID();
				
				arTemplateIDMap[piName] = templateID;
			}
			
			session->SetLongProperty(mPriceableItemTemplateIDPropID, templateID);
			
			if (isOkToLogDebug)
			{
				wchar_t buffer[1024];
				swprintf(buffer, L"Resolved PI: poID = -1; instanceID = -1; subscriptionID = -1; templateID = %d; requestID = %d",
								 templateID, i);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
			}
		}
	}

	if (!allSessionsSucceeded)
		return PIPE_ERR_SUBSET_OF_BATCH_FAILED;

	return S_OK;
}


void BatchPILookup::TruncateTempTable(COdbcConnectionHandle& connection)
{
	LARGE_INTEGER tick, tock;
	::QueryPerformanceCounter(&tick);

	COdbcStatementPtr truncate = connection->CreateStatement();
	// The truncate syntax is the same for sql server and oracle
	int numRows = truncate->ExecuteUpdate("truncate table " + mTempTableName);
	
	//ASSERT(numRows == 0 || numRows == mArraySize);

	connection->CommitTransaction();

	::QueryPerformanceCounter(&tock);
	mTruncateTableTicks += (tock.QuadPart - tick.QuadPart);
}


template<class T>
HRESULT BatchPILookup::InsertIntoTempTable(vector<MTPipelineLib::IMTSessionPtr>& aSessionArray,
																					 T arStatement,
                                           COdbcConnectionHandle& connection)
{
	LARGE_INTEGER tick,tock;
	::QueryPerformanceCounter(&tick);

	//cache this to minimize cost in the following loop
	BOOL isOkToLogDebug = mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);
	
	BOOL allSessionsSucceeded = TRUE;

	unsigned int i;
	for (i=0; i < aSessionArray.size(); i++)
	{
		MTPipelineLib::IMTSessionPtr session = aSessionArray[i];

		try
		{
			// sets the request ID (internal ID used to match up responses)
			arStatement->SetInteger(1, (long) i);


			// sets the account ID
			long accountID;
			try
			{
				accountID = session->GetLongProperty(mAccountPropID);
			}
			catch (_com_error & e)
			{
				_bstr_t buffer = "Session is missing the _AccountID property!"; 
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
				session->MarkAsFailed(buffer, e.Error());
				allSessionsSucceeded = FALSE;
				continue;
			}
			arStatement->SetInteger(2, accountID);


			// sets the timestamp
			DATE timestamp;
			try
			{
				timestamp = session->GetOLEDateProperty(mTimestampPropID);
			}
			catch (_com_error & e)
			{
				_bstr_t buffer = "Session is missing the _Timestamp property!"; 
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
				session->MarkAsFailed(buffer, e.Error());
				allSessionsSucceeded = FALSE;
				continue;
			}
			TIMESTAMP_STRUCT odbcTimestamp;
			OLEDateToOdbcTimestamp(&timestamp, &odbcTimestamp);
			// TODO: this conversion routine should handle errors, currently it returns void
			arStatement->SetDatetime(3, odbcTimestamp);


			long templateID;
			_bstr_t piName;
			BOOL actualLookupByID = TRUE;
			if (mLookupByID 
					&& session->PropertyExists(mPriceableItemTemplateIDPropID,
																		 MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)

			{
				// gets and sets the template ID
				templateID = session->GetLongProperty(mPriceableItemTemplateIDPropID);
				arStatement->SetInteger(4, templateID);
			} 
			else 
			{
				// gets and sets the priceable item's name
				if (session->PropertyExists(mPriceableItemNamePropID,
																		MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
				{
					piName = session->GetStringProperty(mPriceableItemNamePropID);
					arStatement->SetWideString(5, (const wchar_t *)piName);

					actualLookupByID = FALSE;
				}
				else
				{
					// a required property is missing!
					if (mLookupByID)
					{
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, "Session is missing the _PriceableItemTemplateID property.");
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, "This property is inspected first since LookupByID is TRUE.");
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, "Attempting to look up by name instead...");
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,   "Session is missing the _PriceableItemName property!");
						session->MarkAsFailed(L"Session is missing the _PriceableItemName property!", PIPE_ERR_INVALID_PROPERTY);
						allSessionsSucceeded = FALSE;
						continue;
					}
					else
					{
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Session is missing the _PriceableItemName property!"
															 "This property is required since LookupByID is FALSE.");
						session->MarkAsFailed(L"Session is missing the _PriceableItemName property.", PIPE_ERR_INVALID_PROPERTY);
						allSessionsSucceeded = FALSE;
						continue;
					}
				}
			}

			// logs debug info
			if (isOkToLogDebug) 
			{
				// formats the timestamp
				BSTR bstrVal;
				HRESULT hr = VarBstrFromDate(timestamp, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
				_bstr_t timeBuffer(bstrVal, false);

				wchar_t buffer[1024];
				if (actualLookupByID)
				{
					swprintf(buffer,
									 L"Resolving PI based on: accountID = %d; timestamp = %s; templateID = %d; requestID = %d",
									 accountID, (const wchar_t *) timeBuffer, templateID, i);
				}
				else
				{
					swprintf(buffer,
									 L"Resolving PI based on: accountID = %d; timestamp = %s; piName = \'%s\'; requestID = %d",
									 accountID, (const wchar_t *) timeBuffer, (const wchar_t*) piName, i);
				}

				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
			}
		
			arStatement->AddBatch();
		}
		catch (_com_error & err)
		{
			_bstr_t message = err.Description();
			HRESULT errHr = err.Error();
			session->MarkAsFailed(message.length() > 0 ? message : L"", errHr);
			allSessionsSucceeded = FALSE;
		}
	}

	if (!allSessionsSucceeded)
		return PIPE_ERR_SUBSET_OF_BATCH_FAILED;

	// Insert the records to the temp table
	arStatement->ExecuteBatch();
	
	connection->CommitTransaction();

	::QueryPerformanceCounter(&tock);
	mInsertTempTableTicks += (tock.QuadPart - tick.QuadPart);
	
	return S_OK;
}
