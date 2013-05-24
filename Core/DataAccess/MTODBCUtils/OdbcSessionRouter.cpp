/**************************************************************************
* Copyright 1997-2006 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/
#include <metra.h>
#include <propids.h>
#include <mtprogids.h>
#include <MSIXDefinition.h>
#include <autoptr.h>
#include "OdbcSessionMapping.h"
#include "OdbcSessionRouter.h"
#include "OdbcConnMan.h"
#include "OdbcConnection.h"
#include "OdbcStatementGenerator.h"
#include "OdbcPreparedArrayStatement.h"
#include "OdbcException.h"
#include "OdbcMetadata.h"
#include "OdbcStatement.h"
#include "OdbcResultSet.h"
#include "OdbcIdGenerator.h"
#include "OdbcSessionTypeConversion.h"
#include "DistributedTransaction.h"
#include "MTSessionServerBaseDef.h"
#include <sharedsess.h>
#include <ConfigDir.h>
#import <MTConfigLib.tlb>
#include <pipelineconfig.h>
#include <perflog.h>

typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;

const char* gAccUsageTableName = "t_acc_usage";
const int gExtraDefinitions = 1;

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")

// Use this critical section to provide safe thread functionality.
class MTCriticalSection
{
  public:
	  MTCriticalSection() {	::InitializeCriticalSection(&mCS); }
	  ~MTCriticalSection(){	::DeleteCriticalSection(&mCS); }
	  void Enter() { ::EnterCriticalSection(&mCS); }
	  void Leave() { ::LeaveCriticalSection(&mCS); }

  private:
    CRITICAL_SECTION mCS;
};

class MTAutoCriticalSection
{
  public:
	  MTAutoCriticalSection(MTCriticalSection& cs)
      : mCS(cs) {	mCS.Enter();	}
	  ~MTAutoCriticalSection() {	mCS.Leave(); }
  
  private:
	  MTCriticalSection& mCS;
};


// Lookup index for SessionRoutingTable based on service name id.
static RoutingTableIndexMap gRoutingTableIndex;

// Lock for gRoutingTableIndex; thread safety.
static MTCriticalSection gCS;

// t_acc_usage session write name id, used to lookup into session writer hash.
static int gAccUsageNameID;

// private constructor
COdbcSessionRouter::COdbcSessionRouter(COdbcConnection* aConnection,
                                       MTPipelineLib::IMTLogPtr aLogger,
                                       MTPipelineLib::IMTNameIDPtr aNameID,
                                       int aMaxBatchSize)
  :  mMaxBatchSize(aMaxBatchSize),
	  mTotalRecords(0),
	  mpSessServer(NULL),
	  mpHeader(NULL),
    mConnection(aConnection),
    mEndBatchExecuted(false)
{
	mGenerator = COdbcLongIdGenerator::GetInstance(aConnection->GetConnectionInfo());
  PipelinePropIDs::Init();
	InitSharedSessions();

  CProductViewCollection& pvcoll = GetProductViewCollection();
	if (!pvcoll.Initialize())
		throw COdbcException("Could not initialize product view collection");

  // Get the routing index table.
  mRoutingTableIndex = GetRoutingTableIndex(aConnection->GetConnectionInfo().GetCatalog(), aNameID, pvcoll, aLogger);

  // Initialize product view session write vector.
  mRoutingTable = SessionRoutingTable(mRoutingTableIndex->size());
}

// This function is static: Initialize routing table index.
// It will guarantee that all product views are updated in the same order.
RoutingTableIndexMap* COdbcSessionRouter::GetRoutingTableIndex(const string& aTransactionDatabase,
                                                               MTPipelineLib::IMTNameIDPtr aNameID,
                                                               CProductViewCollection& pvcoll,
                                                               MTPipelineLib::IMTLogPtr aLogger)
{
  MTAutoCriticalSection lock(gCS);

  // initialize based on sorted t_prod_view query by id_prod_view
  // index is 0 .. N where N is number of product views
  // id is the Name ID of the product view.
  if (gRoutingTableIndex.size() == 0)
  {
    ROWSETLib::IMTSQLRowsetPtr rowset;
    HRESULT hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
    if (FAILED(hr))
    {
    	char buf[512];
      sprintf(buf, "Unable to create instance of SQL Rowset object", hr);
      throw COdbcException(buf);
    }

		hr = rowset->Init(L"\\Queries\\Database");
		if (FAILED(hr))
    {
    	char buf[512];
      sprintf(buf, "Init() failed. Unable to initialize database access layer", hr);
      throw COdbcException(buf);
    }

    rowset->SetQueryTag("__GET_ORDERED_PRODUCT_VIEW_LIST__");
    rowset->Execute();
    
    if (rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
      throw COdbcException("Unable to find any defined product views");

    int index = 0;
    while(!bool(rowset->RowsetEOF))
    {
      // Product View name.
      _bstr_t bstrPVName(rowset->GetValue(L"nm_name"));

      // Check if name found in database exists in msixdef collection.
      CMSIXDefinition* pProductView ;
      if (!pvcoll.FindProductView((const wchar_t*)bstrPVName, pProductView))
      {
        // Product View in database not found in msixdef collection; log warning and continue.
        wchar_t buf[512];
        swprintf(buf, L"Product view defined in t_prod_view table is not found in msixdef collection: '%s'", (const wchar_t*) bstrPVName);
        aLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, buf);
      }
      else
      {
        // Add to index table.
        gRoutingTableIndex[aNameID->GetNameID(bstrPVName)] = index++;
      }

      // Move to next record.
      rowset->MoveNext();
    }

	// Add usage table to the mix.
	gAccUsageNameID = aNameID->GetNameID(gAccUsageTableName);
	gRoutingTableIndex[gAccUsageNameID] = index++;
  }

  return &gRoutingTableIndex;
}

// Set up all of the session writers and the routing table using BCP
COdbcSessionRouter* COdbcSessionRouter::CreateForInserts(const COdbcConnectionInfo& aConnectionInfo,
                                                         COdbcConnection* aConnection,
                                                         MTPipelineLib::IMTLogPtr aLogger,
																					               MTPipelineLib::IMTNameIDPtr aNameID, 
																					               int aMaxBatchSize,
                                                         bool bUseBcp)
{
	COdbcSessionRouter* newRouter = new COdbcSessionRouter(aConnection, aLogger, aNameID, aMaxBatchSize);

  // The number of items in msix def collection must equal or less than the number in 
  // of items in the t_prod_view table. When a product view is removed and sync'd
  // an entry for it still remains in the table
  ProductViewDefList& list = newRouter->GetProductViewCollection().GetDefList();
  if (list.size() > newRouter->mRoutingTableIndex->size() - gExtraDefinitions)
    throw COdbcException("There are more msix product definitions then entries in t_prod_view table. Product View sync may not have been run.");
  else if (list.size() < newRouter->mRoutingTableIndex->size() - gExtraDefinitions)
    throw COdbcException("The number of msix product definitions does not match the number of product view listed in t_prod_view table");

  //
	ProductViewDefList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXDefinition *productView = *it;
		std::wstring pvName = productView->GetName();
		int id = aNameID->GetNameID(pvName.c_str());

    // Validate that product view exists in database.
    RoutingTableIndexMap::iterator ndx = newRouter->mRoutingTableIndex->find(id);
    if (ndx == newRouter->mRoutingTableIndex->end())
    {
      char buf[512];
      sprintf(buf, "Product view defined with msixdef is not found in database: '%s'", pvName.c_str());
	    throw COdbcException(buf);
    }

    // Add writer to table at a specific index.
    int index = (*newRouter->mRoutingTableIndex)[id];
    if (bUseBcp)
    {
      newRouter->mRoutingTable[index] = new COdbcBcpSessionWriter(
																					  aMaxBatchSize,
																					  aConnection->GetConnectionInfo(),
																					  newRouter->mGenerator,
																					  productView,
																					  aNameID,
																					  newRouter->mpHeader);
    }
    else
    {
      newRouter->mRoutingTable[index] = new COdbcArraySessionWriter(
																										  aMaxBatchSize,
																										  aConnection,
																										  newRouter->mGenerator,
																										  productView,
																										  aNameID,
																										  newRouter->mpHeader);
    }
	}	

	return newRouter;
}

// Set up all of the session writers and the routing table using BCP to staging table
COdbcSessionRouter* COdbcSessionRouter::CreateForStagedInserts(const COdbcConnectionInfo& aConnectionInfo, 
												               COdbcConnection* aConnection,
                                                               MTPipelineLib::IMTLogPtr aLogger,
												               MTPipelineLib::IMTNameIDPtr aNameID, 
												               int aMaxBatchSize,
												               const string& aTableSuffix,
                                                               bool bUseBcp,
												               bool aStageOnly,
															   bool bBatchedInsert /* = true */)
{

  // Create acc usage stage writer.
  COdbcSessionRouter* newRouter = new COdbcMaterializedViewSessionRouter(aConnection, aLogger, aNameID, aMaxBatchSize,
																		 bBatchedInsert && !bUseBcp /* only for array inserts */);

  // The number of items in msix def collection must equal or less than the number in 
  // of items in the t_prod_view table. When a product view is removed and sync'd
  // an entry for it still remains in the table
  ProductViewDefList& list = newRouter->GetProductViewCollection().GetDefList();
  if (list.size() > newRouter->mRoutingTableIndex->size() - gExtraDefinitions)
    throw COdbcException("There are more msix product definitions then entries in t_prod_view table. Product View sync may not have been run.");
  else if (list.size() < newRouter->mRoutingTableIndex->size() - gExtraDefinitions)
    throw COdbcException("The number of msix product definitions does not match the number of product view listed in t_prod_view table");

  //
  ProductViewDefList::iterator it;
  for (it = list.begin(); it != list.end(); ++it)
  {
	CMSIXDefinition *productView = *it;
	std::wstring pvName = productView->GetName();
	int id = aNameID->GetNameID(pvName.c_str());

    // Validate that product view exists in database.
    RoutingTableIndexMap::iterator ndx = newRouter->mRoutingTableIndex->find(id);
    if (ndx == newRouter->mRoutingTableIndex->end())
    {
      char buf[512];
      sprintf(buf, "Product view defined with msixdef is not found in database: '%s'", pvName.c_str());
	  throw COdbcException(buf);
    }

    // Add writer to table at a specific index.
    int index = (*newRouter->mRoutingTableIndex)[id];
    if (bUseBcp)
    {
      newRouter->mRoutingTable[index] = new COdbcStagedSessionWriter<COdbcBcpSessionStagingTableWriter, COdbcBcpSessionStagingAccUsageWriter>
                                            (aMaxBatchSize,
											 aConnection,
											 aConnectionInfo,
											 newRouter->mGenerator,
											 productView,
											 aTableSuffix,
											 aStageOnly,
											 newRouter->mpHeader,
                                             false);
    }
    else
    {
      newRouter->mRoutingTable[index] = new COdbcStagedSessionWriter<COdbcArraySessionStagingTableWriter, COdbcArraySessionStagingAccUsageWriter>
                                            (aMaxBatchSize,
										     aConnection,
										     aConnectionInfo,
										     newRouter->mGenerator,
										     productView,
										     aTableSuffix,
										     aStageOnly,
										     newRouter->mpHeader,
                                             false);
    }
  } // for	

  // Add staged acc usage writer.
  RoutingTableIndexMap::iterator ndx = newRouter->mRoutingTableIndex->find(gAccUsageNameID);
  if (ndx != newRouter->mRoutingTableIndex->end())
  {
	  if (bUseBcp)
		  newRouter->mRoutingTable[(*ndx).second] = new COdbcBcpAccUsageStagedWriter(aConnection, aConnectionInfo, newRouter->mGenerator, newRouter->mpHeader, aMaxBatchSize);
	  else
		  newRouter->mRoutingTable[(*ndx).second] = new COdbcArrayAccUsageStagedWriter(aConnection, aConnectionInfo, newRouter->mGenerator, newRouter->mpHeader, aMaxBatchSize);
  }

  return newRouter;
}

COdbcSessionRouter::~COdbcSessionRouter()
{
  SessionRoutingTable::iterator it;
	for (it = mRoutingTable.begin(); it != mRoutingTable.end(); it++)
		delete (*it);
	mRoutingTable.clear();
  mRoutingTableIndex->clear();

	COdbcLongIdGenerator::ReleaseInstance();
	mGenerator = NULL;

	// releases shared memory resources
	if (mpSessServer)
  {
		mpSessServer->Release();
    mpSessServer = NULL;
  }
}

__int64 COdbcSessionRouter::WriteSession(MTPipelineLib::IMTSessionPtr aSession)
{
	long pvid = aSession->GetLongProperty(PipelinePropIDs::ProductViewIDCode());
  RoutingTableIndexMap::iterator ndx = mRoutingTableIndex->find(pvid);
  if (ndx != mRoutingTableIndex->end())
  {
	  __int64 id_sess = mRoutingTable[(*ndx).second]->WriteSession(aSession);
	  mTotalRecords++;

	  // t_acc_usage is not metered directly. We need to pass session information to acc usage session writer.
	  ndx = mRoutingTableIndex->find(gAccUsageNameID);
	  if (ndx != mRoutingTableIndex->end())
		  mRoutingTable[(*ndx).second]->UpdateSessionMap(id_sess, aSession);
	  else
	  {
		  throw COdbcException("WriteSession: t_acc_usage session writer not found");
	  }

	  return id_sess;
  }

  char buf[512];
  sprintf(buf, "Received session with unknown product view id '%d'", pvid);
	throw COdbcException(buf);
}

__int64 COdbcSessionRouter::WriteChildSession(__int64 aParentId,
											  MTPipelineLib::IMTSessionPtr aSession)
{
	long pvid = aSession->GetLongProperty(PipelinePropIDs::ProductViewIDCode());
  RoutingTableIndexMap::iterator ndx = mRoutingTableIndex->find(pvid);
  if (ndx != mRoutingTableIndex->end())
  {
		__int64 id_sess =  mRoutingTable[(*ndx).second]->WriteChildSession(aParentId, aSession);
		mTotalRecords++;

		// t_acc_usage is not metered directly. We need to pass session information to acc usage session writer.
		ndx = mRoutingTableIndex->find(gAccUsageNameID);
		if (ndx != mRoutingTableIndex->end())
			mRoutingTable[(*ndx).second]->UpdateSessionMap(id_sess, aSession);
		else
		{
			throw COdbcException("WriteChildSession: t_acc_usage session writer not found");
		}

		return id_sess;
  }

	char buf[512];
  sprintf(buf, "Received session with unknown product view id '%d'", pvid);
	throw COdbcException(buf);
}

void COdbcSessionRouter::BeginBatch()
{
  mEndBatchExecuted = false;

	SessionRoutingTable::iterator it = mRoutingTable.begin();
	while(it != mRoutingTable.end())
	{
		COdbcSessionWriter * writer = (*it++);
		if (writer->IsInitialized())
			writer->BeginBatch();
	}
}

void COdbcSessionRouter::EndBatch()
{
	if (!mEndBatchExecuted)
	{
		static std::string OdbcIntegrityViolation("23000");
		bool bBatchFailed = false;
		std::auto_ptr<COdbcException> FirstError;
		SessionRoutingTable::iterator it = mRoutingTable.begin();

		while(it != mRoutingTable.end())
		{
			COdbcSessionWriter * writer = (*it++);
			if (writer->IsInitialized())
			{
				try
				{
					writer->EndBatch();
				}
				catch(COdbcException& ex) 
				{
					// Note: this implementation will not only throw the FirstError, but it will also
					// not finish processing the remainder of writers in list if a second 
					// OdbcIntegrityViolation is encountered.
					if (ex.getSqlState() == OdbcIntegrityViolation && !bBatchFailed)
					{
						FirstError = std::auto_ptr<COdbcException>(new COdbcException(PIPE_ERR_SUBSET_OF_BATCH_FAILED, ex.getMessage(), ex.getSqlState()));
						bBatchFailed = true;
						continue;
					}

					// Rethrow the error.
					mEndBatchExecuted = true;
					throw ex;
				}
			}
		} 

		// Rethrow the first error if we had a failure.
		if (bBatchFailed)
		{
			mEndBatchExecuted = true;
			throw COdbcException(*FirstError.release());
		}
	}
}

int COdbcSessionRouter::ExecuteBatch()
{
	int numRows = 0;
	SessionRoutingTable::iterator it = mRoutingTable.begin();
	while(it != mRoutingTable.end())
	{
		COdbcSessionWriter * writer = (*it++);
		if (writer->IsInitialized())
			numRows += writer->ExecuteBatch();
	}

  return numRows;
}

double COdbcSessionRouter::GetTotalExecuteMillis()
{
	double totalMillis=0.0;
	SessionRoutingTable::iterator it = mRoutingTable.begin();
	while(it != mRoutingTable.end())
	{
		totalMillis += (*it++)->GetTotalExecuteMillis();
	}
	return totalMillis;
}

	// Total number of milliseconds spent checking required properties
double COdbcSessionRouter::GetTotalCheckRequiredMillis() const
{
	double totalMillis=0.0;
	SessionRoutingTable::const_iterator it = mRoutingTable.begin();
	while(it != mRoutingTable.end())
	{
		totalMillis += (*it++)->GetTotalCheckRequiredMillis();
	}
	return totalMillis;
}

	// Total number of milliseconds spent setting default values
double COdbcSessionRouter::GetTotalApplyDefaultsMillis() const
{
	double totalMillis=0.0;
	SessionRoutingTable::const_iterator it = mRoutingTable.begin();
	while(it != mRoutingTable.end())
	{
		totalMillis += (*it++)->GetTotalApplyDefaultsMillis();
	}
	return totalMillis;
}

// Total number of milliseconds spent actually writing session properties
double COdbcSessionRouter::GetTotalWriteSessionPropertiesMillis() const
{
	double totalMillis=0.0;
	SessionRoutingTable::const_iterator it = mRoutingTable.begin();
	while(it != mRoutingTable.end())
	{
		totalMillis += (*it++)->GetTotalWriteSessionPropertiesMillis();
	}
	return totalMillis;
}

// obtains access to shared session memory
// NOTE: throws
void COdbcSessionRouter::InitSharedSessions()
{
	//
	// reads in the pipeline configuration file
	//
	std::string configDir;
	if (!GetMTConfigDir(configDir))
		throw COdbcException("Could not read configuration directory setting!");

	PipelineInfo pipelineInfo;
	PipelineInfoReader pipelineReader;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
		throw COdbcException("Could not read pipeline configuration file!");

  mpSessServer = CMTSessionServerBase::CreateInstance();
  if (mpSessServer == NULL)
  {
    throw COdbcException("Could not attach to shared memory region");
  }
  mpHeader = mpSessServer->GetSharedHeader();
  if (mpSessServer == NULL)
  {
    throw COdbcException("Attached to uninitialized shared memory region");
  }
}

COdbcMaterializedViewSessionRouter::COdbcMaterializedViewSessionRouter
                          (COdbcConnection* aConnection, 
                           MTPipelineLib::IMTLogPtr aLogger,
                           MTPipelineLib::IMTNameIDPtr aNameID,
                           int aMaxBatchSize,
						   bool bBatchedInsert /* = true */)
  : COdbcSessionRouter(aConnection, aLogger, aNameID, aMaxBatchSize),
    mInitialized(false),
	mBatchedInsert(bBatchedInsert)
{
  // Initialize materialized view manager.
  mMaterializedViewMgr = new MetraTech_DataAccess_MaterializedViews::IManagerPtr(__uuidof(MetraTech_DataAccess_MaterializedViews::Manager));
  mMaterializedViewMgr->Initialize();

  // Cache this result so that we don't need to do a COM interop each time.
  mIsMVSupportEnabled = mMaterializedViewMgr->GetIsMetraViewSupportEnabled() == VARIANT_TRUE ? true : false;

  // Make sure the cache is enabled.
  mMaterializedViewMgr->EnableCache(VARIANT_TRUE);
}

void COdbcMaterializedViewSessionRouter::Setup()
{
	if (mIsMVSupportEnabled)
	{
		IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER);
		pQueryAdapter->Init(L"\\Queries\\Database");
      
		// Generate relationship map between Base Tables and t_pv stage tables.
		wchar_t wszTableName[256];
		wstring StageTableName;
		SessionRoutingTable::iterator it = mRoutingTable.begin();
		while(it != mRoutingTable.end())
		{
			COdbcSessionWriter* writer = (*it++);

			// Get product view stage table name.
			pQueryAdapter->ClearQuery();			
			pQueryAdapter->SetQueryTag("__GET_FULLY_QUALIFIED_STAGE_TABLE_NAME__");
			pQueryAdapter->AddParam(L"%%TABLE_NAME%%", writer->GetTableName().c_str()) ;
			StageTableName = pQueryAdapter->GetQuery();

			// Strip all whitespace.
			swscanf(StageTableName.c_str(), L"%s", wszTableName);

			// Add product view table binding.
			mMaterializedViewMgr->AddInsertBinding(writer->GetTableName().c_str(), wszTableName);
		}
	}

	// Materialized View router initialized.
	mInitialized = true;
}

void COdbcMaterializedViewSessionRouter::EndBatch()
{
	// Call base class.
	if (!mEndBatchExecuted)
	{
		COdbcSessionRouter::EndBatch();

		// Update materialized views if enabled.
		if (mIsMVSupportEnabled)
			ExecuteMaterializedViewsUpdate();
	}
}

int COdbcMaterializedViewSessionRouter::ExecuteBatch()
{
  // Setup all static values one time.
  if (!mInitialized)
      Setup();

  // Process session data.
  int numRows = COdbcSessionRouter::ExecuteBatch();

  // If we have any rows and we are batching the session set then we need 
  // end the batch here.
  if (mBatchedInsert && numRows > 0)
    EndBatch();
  
  // Return number of row affected.
  return numRows;
}

void COdbcMaterializedViewSessionRouter::ExecuteMaterializedViewsUpdate()
{
	// Prepared statement key
	wstring key;
	int nMeteredCount = 0;
	SessionRoutingTable::iterator it = mRoutingTable.begin();
	while(it != mRoutingTable.end())
	{
		COdbcSessionWriter * writer = (*it++);
		if (writer->IsInitialized() && writer->IsDataMetered())
		{
			key += writer->GetTableName();
			nMeteredCount++;
		}
	}

	// Check prepared statement cache.
	COdbcPreparedArrayStatementPtr stmt;
	PreparedStatementMap::const_iterator itStmt = mPreparedStatements.find(key);
	if (itStmt != mPreparedStatements.end())
	{
		// Execute the query.
		stmt = itStmt->second;
		COdbcPreparedResultSetPtr resultSet(stmt->ExecuteQuery());
		resultSet->Close();
		return;
	}

	// Create safe array of product view tables that were metered.
	SAFEARRAYBOUND sabound[1];
	sabound[0].lLbound = 0;
	sabound[0].cElements = nMeteredCount;
	SAFEARRAY* pSA = SafeArrayCreate(VT_BSTR, 1, sabound);
	if (pSA == NULL)
		throw COdbcException("Unable to create safe arrary for materialized view insert trigger list.");

	// Try - Catch, to make sure safe arrays are cleaned up.
	bool bSALocked = false;
	try
	{
		// Set data to the contents of the safe array.
		BSTR HUGEP *pbstrNames;
		if (!::SafeArrayAccessData(pSA, (void**)&pbstrNames))
		{
			bSALocked = true;

			// Loop through all the product views and update the datamarts.
			nMeteredCount = 0;
			SessionRoutingTable::iterator it = mRoutingTable.begin();
			while(it != mRoutingTable.end())
			{
				COdbcSessionWriter * writer = (*it++);

				// Add table to trigger list if data was metered to it.
				if (writer->IsInitialized() && writer->IsDataMetered())
					pbstrNames[nMeteredCount++] = ::SysAllocString(writer->GetTableName().c_str());
			}

			// Release lock on safe array
			::SafeArrayUnaccessData(pSA);
			bSALocked = false;
		}
		else
			throw COdbcException("Unable to access safe array trigger data.");

		// Get query to execute for all materialized views that changed due to
		// changes made to t_pv_* tables.
		_bstr_t _bstrQueriesToExecute(mMaterializedViewMgr->GetMaterializedViewInsertQuery(pSA));

		// Free safe array.
		::SafeArrayDestroy(pSA);
		pSA = NULL;

		// Execute the queries.
		if (!!_bstrQueriesToExecute)
		{
			// Prepare the query.
			stmt = mConnection->PrepareStatement((char *) _bstrQueriesToExecute, 1);

			// Execute the query.
			COdbcPreparedResultSetPtr resultSet(stmt->ExecuteQuery());
			resultSet->Close();

			// Cache the prepared statement.
			mPreparedStatements[key] = stmt;
		}
	}
	catch(_com_error& comerror)
	{
		if (pSA)
		{
			if (bSALocked)
				::SafeArrayUnaccessData(pSA);

			::SafeArrayDestroy(pSA);
		}

		throw COdbcException((const char*) comerror.Description());
	}
}

// EOF
