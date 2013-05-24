/**************************************************************************
 * @doc HARNESS
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 *
 * @index | HARNESS
 ***************************************************************************/

#ifndef _HARNESS_H
#define _HARNESS_H

#include <NTThreader.h>
#include <ConfigChange.h>

#include <route.h>
#include <feedback.h>
#include <receipt.h>
#include <resubmit.h>

#include <set>

#include <transactionconfig.h>
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <MTEnumConfigLib.tlb>
#import <PipelineControl.tlb> rename("EOF", "RowsetEOF")
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent")
#import <MetraTech.Pipeline.Messages.tlb> inject_statement("using namespace mscorlib;")

#import "MTPipelineLibExt.tlb" rename ("EOF", "RowsetEOF") no_function_mapping

#include <OdbcSessionRouter.h>
#include <OdbcException.h>
#include <OdbcConnection.h>
#include <OdbcBatchIDWriter.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcResultSet.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcConnMan.h>

typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcBatchIDWriter> COdbcBatchIDWriterPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;
typedef MTautoptr<COdbcResultSet> COdbcResultSetPtr;
typedef MTautoptr<COdbcIdGenerator> COdbcIdGeneratorPtr;
_COM_SMARTPTR_TYPEDEF(ITransaction, __uuidof(ITransaction));

// TODO: remove undefs
#if defined(STAGE_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

// forward references
class SessionErrorObject;
class BatchErrorObject;
class PipelineStage;
class StageScheduler;
class PipelineStageHarnessBase;
class PipelineFailureWriter;
class PipelineResubmitDatabase;

/*************************************** PipelineStageThread ***/

class PipelineStageThread :
	public virtual ObjectWithError,
	public NTThreader
{
public:
	enum State
	{
		RUNNING,		// thread is running normally
		STOPPED,		// thread stopped
	};

public:
	PipelineStageThread() :
		mpStage(NULL),
		mCurrentState(RUNNING)
	{ }

	virtual ~PipelineStageThread();

	void SetStage(StageScheduler * apStage)
	{ mpStage = apStage; }

	void SetState(State aState)
	{ mCurrentState = aState; }

	State GetState() const
	{ return mCurrentState; }

	const char * GetStageName() const;

protected:
	// worker thread
	DllExport virtual int ThreadMain();

	int ThreadMainInternal();

private:
	// stage this thread will drive
	StageScheduler * mpStage;

	State mCurrentState;
};

/************************************** PipelineStageHarnessFactory ***/
class PipelineStageHarnessFactory :
  public virtual ObjectWithError
{
public:
  // Caller has ownership of the allocated harness.
  DllExport PipelineStageHarnessBase * Create(const char * apConfigPath,
                                              std::list<std::string> & arStageNames,
                                              BOOL aStartAsleep);
};

/************************************** PipelineStageHarness ***/

typedef struct _tagThreadData
{
	PipelineStageHarnessBase* pThis;
	int nThreadNumber;	// Thread index
	int nStartIndex;	// Index in stage thread vecor to first thread
	int nEndIndex;		// Index in stage thread vecord to last thread
} THREAD_DATA;

class PipelineStageHarnessBase :
	public virtual ObjectWithError,
	public ConfigChangeObserver
{
public:
	DllExport PipelineStageHarnessBase();
	DllExport virtual ~PipelineStageHarnessBase();

	// clear all internal data structures
	DllExport virtual void Clear();

	DllExport virtual BOOL Init(const char * apConfigPath,
															std::list<std::string> & arStageNames,
															BOOL aStartAsleep);

	//
	// accessors/mutators
	//

	DllExport BOOL GetExitFlag() const;
	DllExport void SetExitFlag();
	DllExport void ClearExitFlag();

	DllExport BOOL GetRefreshFlag() const;
	DllExport void SetRefreshFlag();
	DllExport void ClearRefreshFlag();


	//
	// setup/configuration
	//

public:
	// prepare the stage by reading the configuration and preparing the
	// queue.  This can be called again to refresh the initialization.
	// if routefrom is set, this overrides the name of the routing queue to read from.
	DllExport BOOL PrepareStage(const char * apRouteFrom, BOOL aRunAutoTests);

//// move me
	DllExport BOOL MainLoop(int aMaxSessions);

private:
	// Thread function.
	static DWORD WINAPI WaitThreadFunc(void* apArg);

	// initialize and hold onto instances of any singletons
	BOOL InitializeSingletons();

	// return a list of stages in the given extension.
	// if extension is an empty string, return all stages
	BOOL GetStages(std::list<std::string> & arStageList, const std::string & arExtension);

  // open stage XML file and retrieve instancecount value
  int GetStageCount(const char *apConfigPath, std::string &name);

	// return a set of all extensions
	BOOL GetExtensions(std::set<std::string> & arExtensionList);

protected:
	//
	// configuration change notification
	//
	DllExport virtual void ConfigurationHasChanged();

	virtual BOOL InitInternal(const char * apConfigPath, std::list<std::string> & arStageNames,
                            BOOL aStartAsleep);

	// the real work for PrepareStage.  If this is overridden,
	// continue to call this version in the derived class
	DllExport virtual BOOL PrepareStageInternal(const char * apRouteFrom,
																							BOOL aRunAutoTests);

  // Do what ever success processing that is needed prior to transaction commit
  virtual BOOL OnPreCommit(MTPipelineLib::IMTSessionSetPtr aSet, 
                           MTPipelineLib::IMTTransactionPtr apTran,
                           BOOL aExpress);
  // Do what ever success processing that is needed after transaction commit
  virtual BOOL OnPostCommit(MTPipelineLib::IMTSessionSetPtr aSet, BOOL aExpress);

 	// the ODBC batch processing is not multithreaded
	NTThreadLock mWriteErrorLock;

public:
	BOOL ReevaluateFlow();

	BOOL RequiresFeedback(MTPipelineLib::IMTSessionPtr aSession);


	BOOL SendFeedback(const vector<MTPipelineLib::IMTSessionSetPtr> & arSessionSets,
										BOOL aError, BOOL aExpress);

	virtual BOOL SendReceiptOfSuccess(MTPipelineLib::IMTSessionSetPtr aSet, 
                                    BOOL aExpress);

	virtual BOOL SendReceiptOfError(MTPipelineLib::IMTSessionSetPtr aSet, 
                                  MTPipelineLib::IMTTransactionPtr apTran,
                                  BOOL aExpress)=0;

	int GetStageID(const char * apStageName) const;

	StageIDAndName GetStage(int aId);

	const PipelineInfo & GetPipelineInfo() const
	{ return mPipelineInfo; }

	MTPipelineLib::IMTNameIDPtr GetNameID() const
	{ return mNameID; }

	// database transaction routines
	BOOL ProcessCurrentTransaction(MTPipelineLib::IMTSessionPtr aSession,
																 BOOL aErrorsFlagged);


	MTPipelineLib::IMTSessionServerPtr GetSessionServer() const
	{ return mSessionServer; }

	ProfileDataReference & GetProfile()
	{ return mProfile; }

	BOOL GetCollectProfile() const
	{ return mCollectProfile; }

private:
	//
	// session processing
	//

	// start worker thread that initiates processing of sessions
	BOOL EnableProcessing();

	// stop worker thread that initiates processing of sessions
	BOOL DisableProcessing();


	/*
	 * routing
	 */

	// machine to optionally route from
	const std::string & GetRouteFromMachine() const
	{ return mRouteFromMachine; }

	// queue to optionally route from
	const std::string & GetRouteFromQueue() const
	{ return mRouteFromQueue; }

	void SetRouteFromQueue(const char * apQueue)
	{ mRouteFromQueue = apQueue; }

	// return TRUE if this stage routes messages from listeners
	BOOL RoutesMessages() const
	{ return (mRouteFromQueue.length() > 0); }


public:
	virtual BOOL RecordBatchError(MTPipelineLib::IMTSessionSetPtr aSet,
												MTPipelineLib::IMTTransactionPtr apTran,
												BOOL aCanAutoResubmit)=0;
	
	virtual BOOL RecordSessionError(std::string & arSessionSetID,
													MTPipelineLib::IMTSessionPtr aSession,
													SessionErrorObject & errObject,
													MTPipelineLib::IMTTransactionPtr apTran)=0;

	virtual BOOL RecordSessionError(std::string & arSessionSetID,
													MTPipelineLib::IMTSessionPtr aSession,
													SessionErrorObject & errObject,
													const char * apMessage,
													HRESULT aError,
													MTPipelineLib::IMTTransactionPtr apTran)=0;

protected:

  // Writing failures to t_failed_transaction
  PipelineFailureWriter * mFailureWriter;

	// get the UID of the root most session in a compound
	void GetRootUID(MTPipelineLib::IMTSessionPtr aSession, unsigned char * apBytes);

	// divide a set of sessions into two groups - those that have
	// an error marked specifically and those that do not
	BOOL DivideFailedSessions(
		MTPipelineLib::IMTSessionSetPtr aSessionSet,
		std::vector<MTPipelineLib::IMTSessionPtr> & arErrorsMarked,
		std::vector<MTPipelineLib::IMTSessionPtr> & arErrorsNotMarked,
		HRESULT & arCommonError,
		_bstr_t & arCommonErrorString,
		BOOL & aAllErrorsMatch,
		BOOL aCanAutoResubmit);

	// find the error code and error string for this session.
	// NOTE: if this is a compound session the error might be
	// a child.
	MTPipelineLib::IMTSessionPtr
	FindFailedSession(MTPipelineLib::IMTSessionPtr aSession);

  void CalculateFailureCounts(MTPipelineLib::IMTSessionPtr aSession,
                              map<wstring, int> & arFailureCounts);

  virtual void PopulateErrorObject(SessionErrorObject &         arErrObj,
                                   MTPipelineLib::IMTSessionPtr aSession);

	// generate a message that holds the parts of a session set that don't have
	// errors marked.
	BOOL CollectSuccessfulSessions(
		std::string & arSuccessful,
		std::wstring & arUID,
		const std::string & arSessionSetID,
		const std::vector<MTPipelineLib::IMTSessionPtr> & arErrorsNotMarked);

	// message logger
	NTLogger mLogger;

	PIPELINECONTROLLib::IMTPipelinePtr mPipelineControl;

	// configuration info on the pipeline itself
	PipelineInfo mPipelineInfo;

private:
	MTPipelineLib::IMTSessionServerPtr mSessionServer;

  /*
	// the write product view plugin - used to record session errors
	MTPipelineLib::IMTPipelinePlugInPtr mWriteProductView;
	// the usage interval resolution plugin - used to record session errors
	MTPipelineLib::IMTPipelinePlugInPtr mUsageIntervalResolution;
  */


	// basic configuration reader
	MTPipelineLib::IMTConfigPtr mConfig;
	// date based configuration reader
	MTPipelineLib::IMTConfigLoaderPtr mConfigLoader;

	// configuration change notification
	ConfigChangeObservable mConfigObservable;

	// set to TRUE once config change has been initialized
	// so we only initialize it once
	BOOL mConfigChangeInitialized;

	//
	// singleton objects we keep a reference to
	//

	// name ID so we can ensure that the singleton stays around
	MTPipelineLib::IMTNameIDPtr mNameID;

	// transaction config object should stay around until it is shutdown.
	CTransactionConfig * mTransactionConfig;

	QUERYADAPTERLib::IMTQueryCachePtr mQueryCachePtr;

	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

	MTPipelineLib::IMTSecurityPtr mMTSecurity;

	MTPipelineLibExt::IMTLoginContextPtr mMTLoginContext;

	MTPipelineLib::IMTSQLRowsetPtr mDummyRowset;

	//
	// stage properties
	//

	// if true, exit the stage's main loop
	BOOL mExitFlag;

	// full configuration pathname
	std::string mConfigPath;

	//
	// helper classes
	//

	// session router (used only if configured)
	SessionRouter * mpRouter;

	// session feedback coordinator
	SessionFeedback mFeedback;

	// flow control valve
	PipelineFlowControl mFlowControl;

	// TODO: initialize this correctly!
	MTPipelineLib::IMTSystemContextPtr mSysContext;


	//
	// system profiler
	//

	// used when profiling the system
	ProfileDataReference mProfile;

	// if TRUE, profile
	BOOL mCollectProfile;

	//
	// routing info
	//
	std::string mRouteFromMachine;
	std::string mRouteFromQueue;

	// list of all the stages this harness is running
	typedef std::list<StageScheduler *> StageList;
	typedef std::list<StageScheduler *>::iterator StageListIterator;

	typedef std::vector<PipelineStageThread *> StageThreadList;
	typedef std::vector<PipelineStageThread *>::iterator StageThreadListIterator;

	StageList mStages;
	StageThreadList mStageThreads;

	// Used to protect mStageThreads vector.
	CRITICAL_SECTION m_cs;

  // Count session sets processed.  For debug testing
  __int64 mSessionSetsProcessed;
  __int64 mMaxSessions;

	// if true, do minimal initialization
	BOOL mStartAsleep;
};

class PipelineStageHarness : public PipelineStageHarnessBase
{
private:
	// queue where all errors are sent
	MessageQueue mErrorQueue;

	// audit receipt generator
 	SessionReceipt mReceipt;

	// resubmit queue handler
 	PipelineResubmit mResubmit;

	// utility class to compress/encrypt messages
	MetraTech_Pipeline_Messages::IMessageUtilsPtr mMessageUtils;

  BOOL mIsOracle;

protected:
	DllExport virtual BOOL PrepareStageInternal(const char * apRouteFrom,
																							BOOL aRunAutoTests);

	virtual BOOL InitInternal(const char * apConfigPath, std::list<std::string> & arStageNames,
                            BOOL aStartAsleep);

  virtual BOOL OnPostCommit(MTPipelineLib::IMTSessionSetPtr aSet, BOOL aExpress);
public:
  DllExport PipelineStageHarness();
  DllExport ~PipelineStageHarness();

	// clear all internal data structures
	DllExport virtual void Clear();

	virtual BOOL SendReceiptOfError(MTPipelineLib::IMTSessionSetPtr aSet,
													MTPipelineLib::IMTTransactionPtr apTran, BOOL aExpress);

	virtual BOOL RecordBatchError(MTPipelineLib::IMTSessionSetPtr aSet,
												MTPipelineLib::IMTTransactionPtr apTran,
												BOOL aCanAutoResubmit);
	
	virtual BOOL RecordSessionError(std::string & arSessionSetID,
													MTPipelineLib::IMTSessionPtr aSession,
													SessionErrorObject & errObject,
													MTPipelineLib::IMTTransactionPtr apTran);

	virtual BOOL RecordSessionError(std::string & arSessionSetID,
													MTPipelineLib::IMTSessionPtr aSession,
													SessionErrorObject & errObject,
													const char * apMessage,
													HRESULT aError,
													MTPipelineLib::IMTTransactionPtr apTran);
};

class PipelineStageHarnessDatabase : public PipelineStageHarnessBase
{
private:
  PipelineResubmitDatabase * mResubmitDatabase;

  BOOL mIsOracle;

	//COdbcIdGeneratorPtr mIdGenerator;
	string mStagingDBName;

protected:
	DllExport virtual BOOL PrepareStageInternal(const char * apRouteFrom,
																							BOOL aRunAutoTests);

	virtual BOOL InitInternal(const char * apConfigPath, std::list<std::string> & arStageNames,
                            BOOL aStartAsleep);

	virtual BOOL OnPreCommit(MTPipelineLib::IMTSessionSetPtr aSet, 
                           MTPipelineLib::IMTTransactionPtr apTran,
                           BOOL aExpress);

public:
  DllExport PipelineStageHarnessDatabase();
  DllExport ~PipelineStageHarnessDatabase();

	// clear all internal data structures
	DllExport virtual void Clear();

	virtual BOOL SendReceiptOfError(MTPipelineLib::IMTSessionSetPtr aSet,
                                  MTPipelineLib::IMTTransactionPtr apTran,
                                  BOOL aExpress);

	virtual BOOL RecordBatchError(MTPipelineLib::IMTSessionSetPtr aSet,
                                MTPipelineLib::IMTTransactionPtr apTran,
                                BOOL aCanAutoResubmit);
	
	virtual BOOL RecordSessionError(std::string & arSessionSetID,
													MTPipelineLib::IMTSessionPtr aSession,
													SessionErrorObject & errObject,
													MTPipelineLib::IMTTransactionPtr apTran);

	virtual BOOL RecordSessionError(std::string & arSessionSetID,
													MTPipelineLib::IMTSessionPtr aSession,
													SessionErrorObject & errObject,
													const char * apMessage,
													HRESULT aError,
													MTPipelineLib::IMTTransactionPtr apTran);

  virtual void PopulateErrorObject(SessionErrorObject &         arErrObj,
                                   MTPipelineLib::IMTSessionPtr aSession);
};

#endif /* _HARNESS_H */
