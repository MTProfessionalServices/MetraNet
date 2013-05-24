/**************************************************************************
* Copyright 1997-2005 by MetraTech
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

#ifndef _ODBCSESSIONROUTER_H_
#define _ODBCSESSIONROUTER_H_

#include <ProductViewCollection.h>

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF")
#import <MetraTech.DataAccess.MaterializedViews.tlb>
#import <MetraTech.Collections.tlb>

class COdbcSessionWriter;
class COdbcConnection;
class COdbcLongIdGenerator;
class COdbcConnectionInfo;
class CDistributedTransaction;
class COdbcStatement;
class COdbcPreparedArrayStatement;
class COdbcPreparedResultSet;

// forward declares for shared session implementation
class CSessionWriterSession;
class SharedSessionHeader;
class SharedSessionMappedViewHandle;
class PipelineInfo;
class CMTSessionServerBase;

typedef vector<COdbcSessionWriter*> SessionRoutingTable;
typedef map<int, int> RoutingTableIndexMap;

class COdbcSessionRouter
{
private:
	int mMaxBatchSize;
	__int64 mTotalRecords;
	CProductViewCollection mPVCollection;
	CMTSessionServerBase* mpSessServer;

protected:
	COdbcLongIdGenerator* mGenerator;
	SharedSessionHeader* mpHeader;
	COdbcConnection* mConnection;
	bool mEndBatchExecuted;

	// Use a map and a vector to make sure we have the lookup speed of the map
	// and guaranteed ordering of a vector.
	SessionRoutingTable mRoutingTable;                 // Lookup ODBC session writer at a given index.
	RoutingTableIndexMap* mRoutingTableIndex;          // Lookup index for SessionRoutingTable based on service name id.
	static RoutingTableIndexMap* GetRoutingTableIndex
				(const string& aTransactionDatabase,
				 MTPipelineLib::IMTNameIDPtr aNameID,
				 CProductViewCollection& pvcoll,
				 MTPipelineLib::IMTLogPtr aLogger);      // Initialize/get mRoutingTableIndex 

	// Private constructor, use CreateForXXX factory method to create a SessionRouter
	COdbcSessionRouter(COdbcConnection* aConnection,
                     MTPipelineLib::IMTLogPtr aLogger,
                     MTPipelineLib::IMTNameIDPtr aNameID,
                     int aMaxBatchSize);

	// used in the virtual constructors
	CProductViewCollection & GetProductViewCollection()
		{ return mPVCollection; }

	void InitSharedSessions();

public:

	// Factory methods for a SessionRouter
  static COdbcSessionRouter* CreateForInserts(const COdbcConnectionInfo& aConnectionInfo,
												COdbcConnection* apConnection, 
												MTPipelineLib::IMTLogPtr aLogger,
												MTPipelineLib::IMTNameIDPtr aNameID, 
												int aMaxBatchSize,
												bool bUseBcp);
	
	static COdbcSessionRouter* CreateForStagedInserts(const COdbcConnectionInfo& aConnectionInfo,
														COdbcConnection* aConnection, 
														MTPipelineLib::IMTLogPtr aLogger,
														MTPipelineLib::IMTNameIDPtr aNameID, 
														int aMaxBatchSize,
														const string& aTableSuffix,
														bool bUseBcp,
														bool aStageOnly,
														bool bBatchedInsert = true);

	virtual ~COdbcSessionRouter();

	// Called before first session written. 
	// Gives objects an opportunity to (re)intialize batch state
	virtual void BeginBatch();

	// Write a session.  Note that the session is likely to be
	// batched up and will not necessarily be sent immediately.
	// If you need the session to be sent immediately call ExecuteBatch()
	// to flush.
	__int64 WriteSession(MTPipelineLib::IMTSessionPtr aSession);

	// Write a child session.  Note that the session is likely to be
	// batched up and will not necessarily be sent immediately.
	// If you need the session to be sent immediately call ExecuteBatch()
	// to flush.
	__int64 WriteChildSession(__int64 aParentId, MTPipelineLib::IMTSessionPtr aSession);

	// Although the session writer will execute batches once 
	// maxBatchSize sessions have been added, clients can also
	// force an execute themselves.  Note that the number of records
	// reported from ExecuteBatch will not reflect the count of records
	// submitted through any implicit call.
	virtual int ExecuteBatch();

    // Any post execute batch processing.
    virtual void EndBatch();

	// Retrieve the total number of records written to this is instance.
	__int64 GetTotalRecords() { return mTotalRecords; }

	// Total number of milliseconds executing batches
	double GetTotalExecuteMillis();

	// Total number of milliseconds spent checking required properties
	double GetTotalCheckRequiredMillis() const;

	// Total number of milliseconds spent setting default values
	double GetTotalApplyDefaultsMillis() const;

	// Total number of milliseconds spent actually writing session properties
	double GetTotalWriteSessionPropertiesMillis() const;
};

// Staged BCP Materialized View Router class definition.
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef std::map<std::wstring, COdbcPreparedArrayStatementPtr> PreparedStatementMap;
class COdbcMaterializedViewSessionRouter : public COdbcSessionRouter
{
private:
  bool mIsMVSupportEnabled;
  bool mInitialized;
  PreparedStatementMap mPreparedStatements;

  // If this value is true the insert into select from will occur at array set size.
  // When set to false the moving of data from staging tables will occur at session set size.
  bool mBatchedInsert;

protected:

  // One time initialization function.
  void Setup();

  // Execute materialized view update.
  void ExecuteMaterializedViewsUpdate();

public:
	// Public constructor, only used by CreateForStageBCP factory method to create a SessionRouter
	COdbcMaterializedViewSessionRouter(COdbcConnection* aConnection,
                                     MTPipelineLib::IMTLogPtr aLogger,
                                     MTPipelineLib::IMTNameIDPtr aNameID,
                                     int aMaxBatchSize,
									 bool bBatchedInsert = true);
	virtual ~COdbcMaterializedViewSessionRouter() {};

  // Execute batch.
  virtual int ExecuteBatch();

  // End batch
  virtual void EndBatch();

  // Single instance of materialized views manager.
  MetraTech_DataAccess_MaterializedViews::IManagerPtr mMaterializedViewMgr;
};

#endif

// EOF
