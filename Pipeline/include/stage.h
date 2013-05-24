/**************************************************************************
 * @doc STAGE
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
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
 * @index | STAGE
 ***************************************************************************/

#ifndef _STAGE_H
#define _STAGE_H

#include <stageinfo.h>
#include <exgraph.h>

#include <msgsend.h>
#include <msgreceive.h>

#include <stagecommon.h>
#include <perfshare.h>

#include <set>

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
class PipelineStage;

// defined in harness.h
class PipelineStageHarnessBase;

// defined in stageschedule.h
class StageScheduler;

/********************************************* StageAutoTest ***/

class StageAutoTest : public PipelineAutoTest
{
public:
	StageAutoTest() : mpStage(NULL)
	{ }

	void SetStage(PipelineStage * apStage)
	{ mpStage = apStage; }

protected:
	virtual BOOL RunSession(PipelineAutoTest & arTest,
													MTPipelineLib::IMTSessionSetPtr aSet);

private:
	PipelineStage * mpStage;
};


/***************************************** ProcessSetMessage ***/

// this class holds enough information to send a "process session set"
// message.  We need to hold these messages separately so that
// references to all session sets are gone by the time we send
// the messages

struct ProcessSetMessage
{
	int mSetID;
	unsigned char mUID[16];
	int mNextStageID;

	ProcessSetMessage()
	{ }

	ProcessSetMessage(const ProcessSetMessage & other)
	{
		mSetID = other.mSetID;
		memcpy(mUID, other.mUID, 16);
		mNextStageID = other.mNextStageID;
	}
};


/********************************************* PipelineStage ***/

class PipelineStage : public StageInfo,
										  public virtual ObjectWithError
{
	friend StageAutoTest;
public:
	DllExport PipelineStage();
	DllExport virtual ~PipelineStage();

	// clear all internal data structures
	DllExport virtual void Clear();

	DllExport virtual BOOL Init(StageScheduler * apScheduler, const char * apConfigPath,
															const char * apStageName, int aStageInstance, BOOL aStartAsleep);


	DllExport void LogPerfData();
	DllExport int GetSessionsProcessed() const;

	// prepare the stage by reading the configuration and preparing the
	// queue.  This can be called again to refresh the initialization.
	// if routefrom is set, this overrides the name of the routing queue to read from.
	DllExport BOOL PrepareStage(BOOL aRunAutoTests);


public:
	//
	// accessors/mutators
	//

	DllExport NTLogger & GetLogger()
	{ return mLogger; }

	DllExport virtual BOOL ReadDependencies(MTPipelineLib::IMTConfigPropSetPtr & arDependencies);


	DllExport const char * GetStageName() const
	{ return mStageName.c_str(); }

	DllExport int GetStageID() const
	{ return mStageID; }


private:
	StageMessageTransmitter * GetTransmitter();

	//
	// setup/configuration
	//

public:

	//
	// configuration change notification
	//
	DllExport virtual BOOL ConfigurationHasChanged();

	BOOL Wakeup();

private:
	// the real work for PrepareStage.  If this is overridden,
	// continue to call this version in the derived class
	DllExport virtual BOOL PrepareStageInternal();

	BOOL InitInternal(const char * apConfigPath, const char * apStageName);

	BOOL InitForWakeup();

	void InitSysContextWithConfigInfo();

protected:
	//
	// handlers
	//

	// clear the current configuration
	void ClearConfiguration();

	BOOL PrepareConfiguration();

public:
	// process a group of sessions
	BOOL ProcessSessions(long aSetID, const unsigned char * apSetUID);

	BOOL ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet,
											 vector<long> & arGroupsComplete,
											 vector<ProcessSetMessage> & arMessages);

private:
	typedef std::map<long, MTPipelineLib::IMTSessionSetPtr> LongToSessionSetMap;
	typedef std::multimap<long, MTPipelineLib::IMTSessionPtr> LongToSessionMultimap;
	typedef std::pair<long, MTPipelineLib::IMTSessionPtr> LongSessionPair;

	// process a session, but don't invoke the full error handling sequence.
	// used for processing test sessions during autotest
	BOOL ProcessTestSession(MTPipelineLib::IMTSessionSetPtr aSet);


	// after a compound has failed, this sends feedback to the listener.
	BOOL SendCompoundResponse(MTPipelineLib::IMTSessionPtr aSession);

	// get the UID of the root most session in a compound
	void GetRootUID(MTPipelineLib::IMTSessionPtr aSession, unsigned char * apBytes);

	// processing of this stage is complete.  either free up the sessions
	// or send them to another stage.
	BOOL StageComplete(LongToSessionSetMap & arStageSets,
										 vector<long> & arGroupsComplete,
										 vector<ProcessSetMessage> & arMessages);

private:
	BOOL RollbackSessionsInProcess();

	// this group of sessions is complete - send a message to the correct stage.
	BOOL GroupComplete(int aObjectOwnerID,
										 vector<MTPipelineLib::IMTTransactionPtr> & arPendingTransactions);

	// called by GroupComplete - prepare feedback for a session set
	BOOL PrepareFeedback(const std::vector<int> & arSetID, BOOL aErrorFlag);

	// called by GroupComplete - complete processing of a session set.
	// perform any error handling, cleanup, etc.
	BOOL CompleteProcessing(int aSetID, BOOL aErrorFlag,
													BOOL aWantFeedback, BOOL aTransactional,
													vector<MTPipelineLib::IMTTransactionPtr> & arPendingTransactions);

	// populate a SessionErrorObject from a failed session
	void PopulateErrorObject(SessionErrorObject & arErrObj,
													 MTPipelineLib::IMTSessionPtr aSession);

	// support for stage forking, creates new sets based on next stage
	// if originalSetNeeded is returned as false, the set passed in
	// can be discarded.
	BOOL CreateStageSets(MTPipelineLib::IMTSessionSetPtr & arOriginalSet, 
											 LongToSessionSetMap & arStageSets,
											 BOOL & arOriginalSetNeeded);

	//
	// session/set manipulation
	//
	BOOL MarkSetInTransit(MTPipelineLib::IMTSessionSetPtr aSet, long aID);
	BOOL MarkSetComplete(MTPipelineLib::IMTSessionSetPtr aSet,
											 vector<long> & arGroupsComplete);
	BOOL BeforeSessionRemoval(MTPipelineLib::IMTSessionPtr aSession);
	BOOL MarkSessionComplete(MTPipelineLib::IMTSessionPtr aSession,
													 vector<long> & arGroupsComplete);

	//
	// set operations
	//

	// pointer to an operation that can be performed on a set
	typedef BOOL (PipelineStage::*SetFunction)(MTPipelineLib::IMTSessionPtr aSet,
																						 void * apArg);

	// perform an operation on a set
	BOOL SetOperation(MTPipelineLib::IMTSessionSetPtr aSet,
										SetFunction aOperation, void * apArg);

	BOOL OpMarkInTransit(MTPipelineLib::IMTSessionPtr aSession, void * apArg);
	BOOL OpMarkComplete(MTPipelineLib::IMTSessionPtr aSession, void * apArg);
	BOOL OpCompoundFailed(MTPipelineLib::IMTSessionPtr aSession, void * apArg);
	BOOL OpMarkInProcess(MTPipelineLib::IMTSessionPtr aSession, void * apArg);

	//
	// statistics
	//
	void AddToSessionsProcessed(int aCount);
	void AddToSessionsFailed(int aCount);

	long GetProcessedSessionTimeSpan() const;

	int GetSessionsFailed() const;

private:
	// message logger
	NTLogger mLogger;

	// basic configuration reader
	MTPipelineLib::IMTConfigPtr mConfig;
	// date based configuration reader
	MTPipelineLib::IMTConfigLoaderPtr mConfigLoader;

	MTPipelineLib::IMTSessionServerPtr mSessionServer;

	//
	// stage properties
	//

	// this stage's ID
	int mStageID;

	// next stage's ID
	int mNextStageID;

	// if true, exit the stage's main loop
	BOOL mExitFlag;

	// name of this stage
	std::string mStageName;
  
  // Instance of this stage
  int mStageInstance;

	// path to XML file for this stage
	std::string mStageXmlFile;

	// if true, pipeline is awake
	BOOL mAwake;

	//
	// helper classes
	//

	// plug-in execution
	ExecutionGraph mExecution;

	// auto test
 	StageAutoTest mAutoTest;

	// if true, run the autotests
	BOOL mRunAutoTests;


	MTPipelineLib::IMTSystemContextPtr mSysContext;

	//
	// statistics
	//
	PerfShare mPerfShare;

	int mSessionsProcessed;
	int mSessionsFailed;

	FILETIME mFirstSessionProcessed;
	FILETIME mLastSessionProcessed;

	// if TRUE, profile
	BOOL mCollectProfile;

	// pointer back to the harness
	PipelineStageHarnessBase * mpHarness;

	StageScheduler * mpScheduler;

	// if true, do minimal initialization
	BOOL mStartAsleep;
};

#endif /* _STAGE_H */
