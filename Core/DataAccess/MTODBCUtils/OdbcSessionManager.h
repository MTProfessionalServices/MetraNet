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

#ifndef _ODBCSESSIONMANAGER_H_
#define _ODBCSESSIONMANAGER_H_

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF")

// TODO: remove undefs
#if defined(MTODBCUTILS_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class COdbcConnection;
class COdbcLongIdGenerator;
class COdbcConnectionInfo;
class CDistributedTransaction;
class COdbcSessionRouter;
class COdbcAsyncWriterProxy;


class DllExport IOdbcSessionManager
{
public:

	virtual ~IOdbcSessionManager() {}

	// Sets up batch 
	// Called before any WriteSession methods
	// aTransaction specifies the transaction in which the session set gets written to the database.
	virtual void BeginBatch(MTPipelineLib::IMTTransactionPtr aTransaction) =0;

	// Write a session.  Note that the session is likely to be
	// batched up and will not necessarily be sent immediately.
	// If you need the session to be sent immediately call ExecuteBatch()
	// to flush.
	virtual __int64 WriteSession(MTPipelineLib::IMTSessionPtr aSession) =0;

	// Write a child session.  Note that the session is likely to be
	// batched up and will not necessarily be sent immediately.
	// If you need the session to be sent immediately call ExecuteBatch()
	// to flush.
	// the database ID is returned
	virtual __int64 WriteChildSession(__int64 aParentId,
																			 MTPipelineLib::IMTSessionPtr aSession) =0;

	// Although the session writer will execute batches once 
	// maxBatchSize sessions have been added, clients can also
	// force an execute themselves.  Note that the number of records
	// reported from ExecuteBatch will not reflect the count of records
	// submitted through any implicit call.
	virtual int ExecuteBatch() =0;

	// Called at end of batch to free up resources.
	// Function is called in case of success OR error.
	// If aThrowExceptions is true, Exceptions can be thrown and some resources might not be freed
	// If aThrowExceptions is false, OdbcExceptions will be logged but not thrown, and an attempt to free all resources will be made
	virtual void FinalizeBatch(bool aThrowExceptions) =0;

	// Retrieve the total number of records written to this is instance.
	virtual __int64 GetTotalRecords() =0;

	// Total number of milliseconds executing batches (sum over all internal routers)
	virtual double GetTotalExecuteMillis() =0;

	// Total number of milliseconds waiting for batches to complete
	virtual double GetTotalCompletionWaitMillis() const =0;

	// Total number of milliseconds waiting to submit a batch
	virtual double GetTotalSubmitWaitMillis() const =0;

	// Total number of milliseconds waiting to commit transactions
	virtual double GetTotalCommitMillis() const =0;

	// Total number of milliseconds spent writing sessions to buffer
	virtual double GetTotalWriteSessionMillis() const =0;

	// Total number of milliseconds spent checking required properties
	virtual double GetTotalCheckRequiredMillis() const =0;

	// Total number of milliseconds spent setting default values
	virtual double GetTotalApplyDefaultsMillis() const =0;

	// Total number of milliseconds spent actually writing session properties
	virtual double GetTotalWriteSessionPropertiesMillis() const =0;
};

class DllExport COdbcSimpleStagedSessionManager : public IOdbcSessionManager
{
private:
	COdbcSessionRouter* mRouter;
  COdbcConnection* mConnection; //shared, transactional connection
	MTPipelineLib::IMTLogPtr mLogger;
	__int64 mTotalWriteSessionTicks;
	__int64 mTotalCommitTicks;
	__int64 mTotalSubmitWaitTicks;
	__int64 mTicksPerSecond;
	int mMaxBatchSize;
	int mCurrentBatchSize;
	bool mBatchedInsert;

public:

  COdbcSimpleStagedSessionManager(const COdbcConnectionInfo& aSharedInfo, 
						          const COdbcConnectionInfo& aInfo, 
							      MTPipelineLib::IMTLogPtr aLogger, 
							      MTPipelineLib::IMTNameIDPtr aNameID, 
							      int aMaxBatchSize,
                                  bool bUseBcp,
								  bool aStageOnly);

	virtual ~COdbcSimpleStagedSessionManager();

 	// Sets up batch 
	// Called before any WriteSession methods
	// Gives objects an opportunity to (re)intialize batch state
	// aTransaction specifies the transaction in which the session set gets written to the database.
  void BeginBatch(MTPipelineLib::IMTTransactionPtr aTransaction);

	// Write a session.  Note that the session is likely to be
	// batched up and will not necessarily be sent immediately.
	// If you need the session to be sent immediately call ExecuteBatch()
	// to flush.
	// the generated database ID is returned
	__int64 WriteSession(MTPipelineLib::IMTSessionPtr aSession);

	// Write a child session.  Note that the session is likely to be
	// batched up and will not necessarily be sent immediately.
	// If you need the session to be sent immediately call ExecuteBatch()
	// to flush.
	// the database ID is returned
	__int64 WriteChildSession(__int64 aParentId,
															 MTPipelineLib::IMTSessionPtr aSession);

	// Although the session writer will execute batches once 
	// maxBatchSize sessions have been added, clients can also
	// force an execute themselves.  Note that the number of records
	// reported from ExecuteBatch will not reflect the count of records
	// submitted through any implicit call.
	int ExecuteBatch(); 

 	// Called at end of batch to free up resources.
	// Function is called in case of success OR error.
	// If aThrowExceptions is true, Exceptions can be thrown and some resources might not be freed
	// If aThrowExceptions is false, OdbcExceptions will be logged but not thrown, and an attempt to free all resources will be made
	void FinalizeBatch(bool aThrowExceptions);

	// Retrieve the total number of records written to this is instance.
	__int64 GetTotalRecords();

	// Total number of milliseconds executing batches (sum over all internal routers)
	double GetTotalExecuteMillis();

	// Total number of milliseconds waiting for batches to complete
	double GetTotalCompletionWaitMillis() const 
	{
		// No time spent waiting on a completion queue (we are synchronous)
		return 0.0;
	}

	// Total number of milliseconds waiting to submit a batch
	double GetTotalSubmitWaitMillis() const ;

	// Total number of milliseconds waiting to commit transactions
	double GetTotalCommitMillis() const;

	// Total number of milliseconds spent writing sessions to buffer
	double GetTotalWriteSessionMillis() const;

	// Total number of milliseconds spent checking required properties
	double GetTotalCheckRequiredMillis() const;

	// Total number of milliseconds spent setting default values
	double GetTotalApplyDefaultsMillis() const;

	// Total number of milliseconds spent actually writing session properties
	double GetTotalWriteSessionPropertiesMillis() const;
};

class DllExport COdbcSessionManagerBase : public IOdbcSessionManager
{
  private:
	  COdbcConnection* mConnection; //shared, transactional connection
	  vector<COdbcAsyncWriterProxy*> mRouters;
	  list<COdbcAsyncWriterProxy*> mExecuting;
	  list<COdbcAsyncWriterProxy*> mAvailable;
	  COdbcAsyncWriterProxy* mPopulating;
	  int mMaxBatchSize;
	  int mCurrentBatchSize;

	  int mNumThreads;

	  MTPipelineLib::IMTLogPtr mLogger;

	  CRITICAL_SECTION mCriticalSection;


	  void InternalExecuteBatch();

	  // Performance counters
	  __int64 mTotalCompletionWaitTicks;
	  __int64 mTotalSubmitWaitTicks;
	  __int64 mTotalWriteSessionTicks;
	  __int64 mTotalCommitTicks;
	  __int64 mTicksPerSecond;

  protected:

	  COdbcConnection* GetSharedConnection() { return mConnection; }

	  void AddRouter(COdbcSessionRouter* aRouter);
  	
	  int PopExecutingWhenCompleted();
  	

  public:
	  // Set up all of the session writers and the routing table
	  COdbcSessionManagerBase(const COdbcConnectionInfo& aInfo,
											      MTPipelineLib::IMTLogPtr aLogger,
											      MTPipelineLib::IMTNameIDPtr aNameID,
											      int aMaxBatchSize,
											      int aNumThreads);

	  virtual ~COdbcSessionManagerBase();

	  // Sets up batch 
	  // Called before any WriteSession methods
	  // Gives objects an opportunity to (re)intialize batch state
	  // aTransaction specifies the transaction in which the session set gets written to the database.
	  virtual void BeginBatch(MTPipelineLib::IMTTransactionPtr aTransaction);


	  // Write a session.  Note that the session is likely to be
	  // batched up and will not necessarily be sent immediately.
	  // If you need the session to be sent immediately call ExecuteBatch()
	  // to flush.
	  // the generated database ID is returned
	  __int64 WriteSession(MTPipelineLib::IMTSessionPtr aSession);

	  // Write a child session.  Note that the session is likely to be
	  // batched up and will not necessarily be sent immediately.
	  // If you need the session to be sent immediately call ExecuteBatch()
	  // to flush.
	  // the database ID is returned
	  __int64 WriteChildSession(__int64 aParentId,
															  MTPipelineLib::IMTSessionPtr aSession);


	  // Although the session writer will execute batches once 
	  // maxBatchSize sessions have been added, clients can also
	  // force an execute themselves.  Note that the number of records
	  // reported from ExecuteBatch will not reflect the count of records
	  // submitted through any implicit call.
	  int ExecuteBatch();

	  // Called at end of batch to free up resources.
	  // Function is called in case of success OR error.
	  // If aThrowExceptions is true, Exceptions can be thrown and some resources might not be freed
	  // If aThrowExceptions is false, OdbcExceptions will be logged but not thrown, and an attempt to free all resources will be made
	  virtual void FinalizeBatch(bool aThrowExceptions);

	  // Retrieve the total number of records written to this is instance.
	  __int64 GetTotalRecords();

	  // Total number of milliseconds executing batches (sum over all internal routers)
	  double GetTotalExecuteMillis();

	  // Total number of milliseconds waiting for batches to complete
	  double GetTotalCompletionWaitMillis() const;

	  // Total number of milliseconds waiting to submit a batch
	  double GetTotalSubmitWaitMillis() const;

	  // Total number of milliseconds waiting to commit transactions
	  double GetTotalCommitMillis() const;

	  // Total number of milliseconds spent writing sessions to buffer
	  double GetTotalWriteSessionMillis() const;

	  // Total number of milliseconds spent checking required properties
	  double GetTotalCheckRequiredMillis() const;

	  // Total number of milliseconds spent setting default values
	  double GetTotalApplyDefaultsMillis() const;

	  // Total number of milliseconds spent actually writing session properties
	  double GetTotalWriteSessionPropertiesMillis() const;
};

//
class DllExport COdbcSessionManager : public COdbcSessionManagerBase
{
  public:
	  // Set up all of the session writers and the routing table
	  COdbcSessionManager(const COdbcConnectionInfo& aInfo,
											  MTPipelineLib::IMTLogPtr aLogger,
											  MTPipelineLib::IMTNameIDPtr aNameID, 
											  int aMaxBatchSize,
											  int aNumThreads,
                        bool bUseBcp);

	  ~COdbcSessionManager();
};

//
class DllExport COdbcStagedSessionManager : public COdbcSessionManagerBase
{
  public:
	  // Set up all of the session writers and the routing table
	  COdbcStagedSessionManager(const COdbcConnectionInfo& aSharedInfo,
															const COdbcConnectionInfo& aInfo, 
															MTPipelineLib::IMTLogPtr aLogger, 
															MTPipelineLib::IMTNameIDPtr aNameID, 
															int aMaxBatchSize, 
															int aNumThreads,
                              bool bUseBcp,
															bool aStageOnly);

	  ~COdbcStagedSessionManager();
};

#endif
