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
#include <ProductViewCollection.h>
#include <MSIXDefinition.h>
#include <autoptr.h>
#include <perflog.h>

#include "OdbcSessionManager.h"
#include "OdbcSessionRouter.h"
#include "OdbcAsyncWriter.h"

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

_COM_SMARTPTR_TYPEDEF(ITransaction, IID_ITransaction);

COdbcSessionManagerBase::COdbcSessionManagerBase(const COdbcConnectionInfo& aInfo,
										         MTPipelineLib::IMTLogPtr aLogger,
										         MTPipelineLib::IMTNameIDPtr aNameID, 
										         int aMaxBatchSize,
										         int aNumThreads)
	: mMaxBatchSize(aMaxBatchSize),
	  mCurrentBatchSize(0),
	  mPopulating(NULL),
	  mNumThreads(aNumThreads),
	  mLogger(aLogger),
	  mTotalCompletionWaitTicks(0),
	  mTotalWriteSessionTicks(0),
	  mTotalSubmitWaitTicks(0),
	  mTotalCommitTicks(0)
{
	LARGE_INTEGER freq;
	::QueryPerformanceFrequency(&freq);
	mTicksPerSecond = freq.QuadPart;

	::InitializeCriticalSection(&mCriticalSection); 

  mConnection = new COdbcConnection(aInfo);
  mConnection->SetAutoCommit(true); //DTC requires AutoCommit true
}

COdbcSessionManagerBase::~COdbcSessionManagerBase()
{
	for (unsigned int i = 0; i < mRouters.size(); i++)
	{
		COdbcAsyncWriterProxy * tmp = mRouters[i];
		mRouters[i] = NULL;
		delete tmp;
	}

	delete mConnection;
	mConnection = NULL;

	::DeleteCriticalSection(&mCriticalSection);
}

void COdbcSessionManagerBase::AddRouter(COdbcSessionRouter* aRouter)
{
	COdbcAsyncWriterProxy* proxyRouter = new COdbcAsyncWriterProxy(mLogger, &mCriticalSection, aRouter);
	mRouters.push_back(proxyRouter);
	mAvailable.push_back(proxyRouter);
}

void COdbcSessionManagerBase::InternalExecuteBatch()
{
	ASSERT(mNumThreads == (int) (mExecuting.size() + mAvailable.size() + (mPopulating != NULL ? 1 : 0)));
	if (mPopulating == NULL) return;

	// Async execute the current populating router.  
	COdbcAsyncWriterProxy* router = mPopulating;
	mExecuting.push_back(mPopulating);
	mPopulating = NULL; //set to NULL before executing since ExecuteBatch can throw an exception
	
	router->ExecuteBatch();

	// Clear the current batch
	mCurrentBatchSize = 0;
	ASSERT(mNumThreads == (int) (mExecuting.size() + mAvailable.size() + (mPopulating != NULL ? 1 : 0)));
}

__int64 COdbcSessionManagerBase::WriteSession(MTPipelineLib::IMTSessionPtr aSession)
{
	LARGE_INTEGER tick, tock;
	ASSERT(mNumThreads == (int) (mExecuting.size() + mAvailable.size() + (mPopulating != NULL ? 1 : 0)));

	// There must be room in the current batch, because previous calls to this method will submit
	// a batch as soon as it is full (see below)
	ASSERT(mCurrentBatchSize < mMaxBatchSize);

	if(mPopulating == NULL)
	{
		// First grab from the available threads; if there are none, wait
		// on a worker to finish
		if(mAvailable.size() == 0)
		{
			ASSERT(mExecuting.size() > 0);
			// Cycle through mExecuting queue in a fifo manner.
			::QueryPerformanceCounter(&tick);
			PopExecutingWhenCompleted();
			::QueryPerformanceCounter(&tock);
			mTotalCompletionWaitTicks += (tock.QuadPart - tick.QuadPart);

			ASSERT(mAvailable.size() > 0);
		}

		mPopulating = mAvailable.back();
		mAvailable.pop_back();
	}
	ASSERT(mPopulating != NULL);
	ASSERT(mNumThreads == (int) (mExecuting.size() + mAvailable.size() + (mPopulating != NULL ? 1 : 0)));

	::QueryPerformanceCounter(&tick);

	__int64 id_sess = mPopulating->WriteSession(aSession);

	::QueryPerformanceCounter(&tock);
	mTotalWriteSessionTicks += (tock.QuadPart - tick.QuadPart);

	mCurrentBatchSize++;

	if (mCurrentBatchSize >= mMaxBatchSize) 
	{
		MarkEnterRegion("ExecuteBatch");
		::QueryPerformanceCounter(&tick);

		InternalExecuteBatch();

		::QueryPerformanceCounter(&tock);
		MarkExitRegion("ExecuteBatch");
		mTotalSubmitWaitTicks += (tock.QuadPart - tick.QuadPart);
		ASSERT(mCurrentBatchSize == 0);
	}

	ASSERT(mNumThreads == (int) (mExecuting.size() + mAvailable.size() + (mPopulating != NULL ? 1 : 0)));
	return id_sess;
}

__int64 COdbcSessionManagerBase::WriteChildSession(__int64 aParentId,
																									MTPipelineLib::IMTSessionPtr aSession)
{
	LARGE_INTEGER tick, tock;
	ASSERT(mNumThreads == (int) (mExecuting.size() + mAvailable.size() + (mPopulating != NULL ? 1 : 0)));

	// There must be room in the current batch, because previous calls to this method will submit
	// a batch as soon as it is full (see below)
	ASSERT(mCurrentBatchSize < mMaxBatchSize);

	if(mPopulating == NULL)
	{
		// First grab from the available threads; if there are none, wait
		// on a worker to finish
		if(mAvailable.size() == 0)
		{
			ASSERT(mExecuting.size() > 0);
			// Cycle through mExecuting queue in a fifo manner.
			::QueryPerformanceCounter(&tick);
			PopExecutingWhenCompleted();
			::QueryPerformanceCounter(&tock);
			mTotalCompletionWaitTicks += (tock.QuadPart - tick.QuadPart);

			ASSERT(mAvailable.size() > 0);
		}

		mPopulating = mAvailable.back();
		mAvailable.pop_back();

	}
	ASSERT(mPopulating != NULL);
	ASSERT(mNumThreads == (int) (mExecuting.size() + mAvailable.size() + (mPopulating != NULL ? 1 : 0)));

	::QueryPerformanceCounter(&tick);

	__int64 id_sess = mPopulating->WriteChildSession(aParentId, aSession);

	::QueryPerformanceCounter(&tock);
	mTotalWriteSessionTicks += (tock.QuadPart - tick.QuadPart);

	mCurrentBatchSize++;

	if (mCurrentBatchSize >= mMaxBatchSize) 
	{
		::QueryPerformanceCounter(&tick);

		InternalExecuteBatch();

		::QueryPerformanceCounter(&tock);
		mTotalSubmitWaitTicks += (tock.QuadPart - tick.QuadPart);
		ASSERT(mCurrentBatchSize == 0);
	}

	ASSERT(mNumThreads == (int) (mExecuting.size() + mAvailable.size() + (mPopulating != NULL ? 1 : 0)));
	return id_sess;
}

int COdbcSessionManagerBase::ExecuteBatch()
{
	LARGE_INTEGER tick, tock;
	::QueryPerformanceCounter(&tick);
	InternalExecuteBatch();
	::QueryPerformanceCounter(&tock);
	mTotalSubmitWaitTicks += (tock.QuadPart - tick.QuadPart);

	ASSERT(mPopulating == NULL);
	int numRows = 0;
	while(mExecuting.size() > 0)
	{
		::QueryPerformanceCounter(&tick);
		//waits for request, throws COdbcExceptions on error
		numRows += PopExecutingWhenCompleted();
		::QueryPerformanceCounter(&tock);
		mTotalCompletionWaitTicks += (tock.QuadPart - tick.QuadPart);
	}

	ASSERT(mExecuting.size() == 0);
	ASSERT(mAvailable.size() == (unsigned int) mNumThreads);
	ASSERT(NULL == mPopulating);

	return numRows;
}

__int64 COdbcSessionManagerBase::GetTotalRecords()
{ 
	__int64 numRecords=0;
	vector<COdbcAsyncWriterProxy*>::iterator it = mRouters.begin(); 
	while(it != mRouters.end())
	{
		numRecords += (*it++)->GetRouter()->GetTotalRecords();
	}
	return numRecords;
}

double COdbcSessionManagerBase::GetTotalExecuteMillis()
{
	double numMillis=0.0;
	vector<COdbcAsyncWriterProxy*>::iterator it = mRouters.begin(); 
	while(it != mRouters.end())
	{
		numMillis += (*it++)->GetRouter()->GetTotalExecuteMillis();
	}
	return numMillis;
}

	// Total number of milliseconds spent checking required properties
double COdbcSessionManagerBase::GetTotalCheckRequiredMillis() const
{
	double numMillis=0.0;
	vector<COdbcAsyncWriterProxy*>::const_iterator it = mRouters.begin(); 
	while(it != mRouters.end())
	{
		numMillis += (*it++)->GetRouter()->GetTotalCheckRequiredMillis();
	}
	return numMillis;
}

	// Total number of milliseconds spent setting default values
double COdbcSessionManagerBase::GetTotalApplyDefaultsMillis() const
{
	double numMillis=0.0;
	vector<COdbcAsyncWriterProxy*>::const_iterator it = mRouters.begin(); 
	while(it != mRouters.end())
	{
		numMillis += (*it++)->GetRouter()->GetTotalApplyDefaultsMillis();
	}
	return numMillis;
}

	// Total number of milliseconds spent actually writing session properties
double COdbcSessionManagerBase::GetTotalWriteSessionPropertiesMillis() const
{
	double numMillis=0.0;
	vector<COdbcAsyncWriterProxy*>::const_iterator it = mRouters.begin(); 
	while(it != mRouters.end())
	{
		numMillis += (*it++)->GetRouter()->GetTotalWriteSessionPropertiesMillis();
	}
	return numMillis;
}

double COdbcSessionManagerBase::GetTotalSubmitWaitMillis() const
{
	return (1000.0*mTotalSubmitWaitTicks)/mTicksPerSecond;
}

// Total number of milliseconds waiting to commit transactions
double COdbcSessionManagerBase::GetTotalCommitMillis() const
{
	return (1000.0*mTotalCommitTicks)/mTicksPerSecond;
}

double COdbcSessionManagerBase::GetTotalCompletionWaitMillis() const 
{
	return (1000.0*mTotalCompletionWaitTicks)/mTicksPerSecond;
/*
	double numMillis=(1000.0*mTotalCompletionWaitTicks)/mTicksPerSecond;
	vector<COdbcAsyncWriterProxy*>::const_iterator it = mRouters.begin(); 
	while(it != mRouters.end())
	{
		//numMillis += (*it)->GetEnqueueWaitMillis();
		numMillis += (*it++)->GetDequeueWaitMillis();
	}
	return numMillis;
*/
}

double COdbcSessionManagerBase::GetTotalWriteSessionMillis() const
{
	return (1000.0*mTotalWriteSessionTicks)/mTicksPerSecond;
}

// Sets up batch 
// Called before any WriteSession methods
// aTransaction specifies the transaction in which the session set gets written to the database.
// Gives objects an opportunity to (re)intialize batch state
// Note: writes to staging tables to not participate in this rowset's transaction
//       (so we can use BCP via ODBC). This is OK since staging tables get truncated
//        on BeginBatch
void COdbcSessionManagerBase::BeginBatch(MTPipelineLib::IMTTransactionPtr aTransaction)
{
	if(mExecuting.size() > 0)
	{	// no thread should be executing at start of batch.
		throw COdbcException("There are still executing threads at BeginBatch()");
	}

	// reinitialize state
	mCurrentBatchSize = 0;

	// enlist the shared connection in the transaction
	IUnknownPtr punk = aTransaction->GetTransaction();
	ITransactionPtr iTxn = punk;
	mConnection->JoinTransaction(iTxn);


	// use first router to execute BeginBatch synchronously 
	if (mAvailable.size() <= 0)
		throw COdbcException("No available routers for write sessions");

	COdbcAsyncWriterProxy* routerProxy = mAvailable.back();
  COdbcSessionRouter* router = routerProxy->GetRouter();

	// call BeginBatch for all dependent objects
	router->BeginBatch();
}

// Called at end of batch to free up resources.
// Function is called in case of success OR error.
// If aThrowExceptions is true, Exceptions can be thrown and some resources might not be freed
// If aThrowExceptions is false, OdbcExceptions will be logged but not thrown, and an attempt to free all resources will be made
void COdbcSessionManagerBase::FinalizeBatch(bool aThrowExceptions)
{
	//wait for all executing threads to finish
	while(mExecuting.size() > 0)
	{	
		try
		{	PopExecutingWhenCompleted();
		}
		catch(COdbcException& ex) 
		{	if(aThrowExceptions)
				throw ex;
			else
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, _bstr_t(ex.toString().c_str()));
		}
	}

	//put any populating thread back in the available pool
	if( mPopulating )
	{	
    try
    {
      // In this case, we may have a bcp batch in process, there is no way to 
      // cancel a batch, you have to "commit".  Note that since this places data into
      // staging tables there is no danger in commiting the batch even if there is no
      // desire to write into t_acc_usage.
      mPopulating->GetRouter()->ExecuteBatch();
    }
    catch(COdbcException & ex)
    {
      if(aThrowExceptions)
        throw ex;
      else
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, _bstr_t(ex.toString().c_str()));
    }
		mAvailable.push_back(mPopulating);
		mPopulating = NULL;
	}
}

// Wait for first executing request to complete, and pop it from executing queue to available queue
// returns number of rows written
// on error throws exception
int COdbcSessionManagerBase::PopExecutingWhenCompleted()
{
	COdbcAsyncWriterProxy* router = mExecuting.front();
	
	// wait for request to complete
	ArrayWriterRequest* pRequest = router->GetCompletedRequest();

	// make sure router gets moved to available before throwing exception
	mAvailable.push_back(router);
	mExecuting.pop_front();

	// request can be null in abort scenario
	if (pRequest == NULL)
		return 0;

	if (pRequest->GetException() != NULL) 
	{
		throw *((COdbcException*) pRequest->GetException());
	}

	return pRequest->GetWritten();
}

//-------------------------------------------------------------------------------
COdbcSimpleStagedSessionManager::COdbcSimpleStagedSessionManager(const COdbcConnectionInfo& aSharedInfo, 
																const COdbcConnectionInfo& aStagedInfo, 
																MTPipelineLib::IMTLogPtr aLogger, 
																MTPipelineLib::IMTNameIDPtr aNameID, 
																int aMaxBatchSize,
																bool bUseBcp,
																bool aStageOnly)
	: mLogger(aLogger),
  	mTotalWriteSessionTicks(0),
  	mTotalCommitTicks(0),
  	mTotalSubmitWaitTicks(0),
  	mMaxBatchSize(aMaxBatchSize),
  	mCurrentBatchSize(0),
	mBatchedInsert(false)
{
	LARGE_INTEGER freq;
	::QueryPerformanceFrequency(&freq);
	mTicksPerSecond = freq.QuadPart;

	//
	mConnection = new COdbcConnection(aSharedInfo);
	mConnection->SetAutoCommit(true); //DTC requires AutoCommit true

	mRouter = COdbcSessionRouter::CreateForStagedInserts(aStagedInfo, mConnection, aLogger, aNameID,
													     aMaxBatchSize, "", bUseBcp, aStageOnly, mBatchedInsert);

	// Commit initial work
	mConnection->CommitTransaction();
}

COdbcSimpleStagedSessionManager::~COdbcSimpleStagedSessionManager()
{
	delete mRouter;
	mRouter = NULL;

	delete mConnection;
	mConnection = NULL;
}

__int64 COdbcSimpleStagedSessionManager::WriteSession(MTPipelineLib::IMTSessionPtr aSession)
{
	LARGE_INTEGER tick, tock;

	// There must be room in the current batch, because previous calls to this method will submit
	// a batch as soon as it is full (see below)
	ASSERT(mCurrentBatchSize < mMaxBatchSize);

	::QueryPerformanceCounter(&tick);
	__int64 id_sess = mRouter->WriteSession(aSession);
	::QueryPerformanceCounter(&tock);
	mTotalWriteSessionTicks += (tock.QuadPart - tick.QuadPart);

	mCurrentBatchSize++;

	if (mCurrentBatchSize >= mMaxBatchSize) 
	{
		::QueryPerformanceCounter(&tick);
		mRouter->ExecuteBatch();
		::QueryPerformanceCounter(&tock);
		mTotalSubmitWaitTicks += (tock.QuadPart - tick.QuadPart);
		// Clear the current batch
		mCurrentBatchSize = 0;
	}
	return id_sess;
}

__int64 COdbcSimpleStagedSessionManager::WriteChildSession(__int64 aParentId,
																												MTPipelineLib::IMTSessionPtr aSession)
{
	LARGE_INTEGER tick, tock;

	// There must be room in the current batch, because previous calls to this method will submit
	// a batch as soon as it is full (see below)
	ASSERT(mCurrentBatchSize < mMaxBatchSize);

	::QueryPerformanceCounter(&tick);
	__int64 id_sess = mRouter->WriteChildSession(aParentId, aSession);
	::QueryPerformanceCounter(&tock);
	mTotalWriteSessionTicks += (tock.QuadPart - tick.QuadPart);

	mCurrentBatchSize++;

	if (mCurrentBatchSize >= mMaxBatchSize) 
	{
		::QueryPerformanceCounter(&tick);
		mRouter->ExecuteBatch();
		::QueryPerformanceCounter(&tock);
		mTotalSubmitWaitTicks += (tock.QuadPart - tick.QuadPart);
		// Clear the current batch
		mCurrentBatchSize = 0;
	}
	return id_sess;
}

void COdbcSimpleStagedSessionManager::BeginBatch(MTPipelineLib::IMTTransactionPtr aTransaction)
{
	// reinitialize state
	mCurrentBatchSize = 0;

	// enlist the shared connection in the transaction
	IUnknownPtr punk = aTransaction->GetTransaction();
	ITransactionPtr iTxn = punk;
	mConnection->JoinTransaction(iTxn);

	// call BeginBatch for all dependent objects
	mRouter->BeginBatch();
}

int COdbcSimpleStagedSessionManager::ExecuteBatch() 
{
	if (mCurrentBatchSize == 0)
		return 0;

	LARGE_INTEGER tick, tock;
	::QueryPerformanceCounter(&tick);
	int numRows = mRouter->ExecuteBatch();
	::QueryPerformanceCounter(&tock);
	mTotalSubmitWaitTicks += (tock.QuadPart - tick.QuadPart);
	return numRows;
}

// Called at end of batch to free up resources.
// Function is called in case of success OR error.
// If aThrowExceptions is true, Exceptions can be thrown and some resources might not be freed
// If aThrowExceptions is false, OdbcExceptions will be logged but not thrown, and an attempt to free all resources will be made
void COdbcSimpleStagedSessionManager::FinalizeBatch(bool aThrowExceptions)
{
	// If mBatchedInsert is true then the Router will call EndBatch for each Batch Execute
	// that returns any rows. the SimpleStagedSessionManager only wants to update the base tables
	// at the end of session set processing. Therefore, we set mBatchedInsert to false and
	// call end batch here.
	if (mBatchedInsert == false)
		mRouter->EndBatch();
}

// Retrieve the total number of records written to this is instance.
__int64 COdbcSimpleStagedSessionManager::GetTotalRecords()
{
	return mRouter->GetTotalRecords();
}

// Total number of milliseconds executing batches (sum over all internal routers)
double COdbcSimpleStagedSessionManager::GetTotalExecuteMillis() 
{
	return mRouter->GetTotalExecuteMillis();
}

// Total number of milliseconds spent checking required properties
double COdbcSimpleStagedSessionManager::GetTotalCheckRequiredMillis() const
{
	return mRouter->GetTotalCheckRequiredMillis();
}

// Total number of milliseconds spent setting default values
double COdbcSimpleStagedSessionManager::GetTotalApplyDefaultsMillis() const 
{
	return mRouter->GetTotalApplyDefaultsMillis();
}

// Total number of milliseconds spent actually writing session properties
double COdbcSimpleStagedSessionManager::GetTotalWriteSessionPropertiesMillis() const
{
	return mRouter->GetTotalWriteSessionPropertiesMillis();
}

double COdbcSimpleStagedSessionManager::GetTotalWriteSessionMillis() const
{
	return (1000.0*mTotalWriteSessionTicks)/mTicksPerSecond;
}

double COdbcSimpleStagedSessionManager::GetTotalCommitMillis() const
{
	return (1000.0*mTotalCommitTicks)/mTicksPerSecond;	
}

double COdbcSimpleStagedSessionManager::GetTotalSubmitWaitMillis() const 
{
	// No time spent waiting on a submit queue (we are synchronous)
	return (1000.0*mTotalSubmitWaitTicks)/mTicksPerSecond;	
}

//-------------------------------------------------------------------------------
COdbcSessionManager::COdbcSessionManager(const COdbcConnectionInfo& aSharedInfo,
										 MTPipelineLib::IMTLogPtr aLogger,
										 MTPipelineLib::IMTNameIDPtr aNameID, 
										 int aMaxBatchSize,
										 int aNumThreads,
                                         bool bUseBcp)
	: COdbcSessionManagerBase(aSharedInfo, aLogger, aNameID, aMaxBatchSize, aNumThreads)
{
	for (int i = 0; i < aNumThreads; i++)
	{
		AddRouter(COdbcSessionRouter::CreateForInserts(aSharedInfo, GetSharedConnection(), aLogger, aNameID,
													   aMaxBatchSize, bUseBcp));
	}

	//commit initial work
	GetSharedConnection()->CommitTransaction();
}

COdbcSessionManager::~COdbcSessionManager()
{
}

//-------------------------------------------------------------------------------
COdbcStagedSessionManager::COdbcStagedSessionManager(const COdbcConnectionInfo& aSharedInfo, 
													const COdbcConnectionInfo& aStagedInfo, 
													MTPipelineLib::IMTLogPtr aLogger, 
													MTPipelineLib::IMTNameIDPtr aNameID, 
													int aMaxBatchSize, 
													int aNumThreads,
													bool bUseBcp,
													bool aStageOnly)
	: COdbcSessionManagerBase(aSharedInfo, aLogger, aNameID, aMaxBatchSize, aNumThreads)
{
	int i;
	for(i=0; i<aNumThreads; i++)
	{
		char buf[256];
		if (i == 0)
		{
			strcpy(buf, "");
		}
		else
		{
			sprintf(buf, "_%d", i);
		}
		AddRouter(COdbcSessionRouter::CreateForStagedInserts(aStagedInfo, GetSharedConnection(), aLogger, aNameID,
															 aMaxBatchSize, buf, bUseBcp, aStageOnly));
	}

	// Commit initial work
	GetSharedConnection()->CommitTransaction();
}

COdbcStagedSessionManager::~COdbcStagedSessionManager()
{
}

// EOF