/**************************************************************************
 * @doc STAGESCHEDULE
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
 * @index | STAGESCHEDULE
 ***************************************************************************/

#ifndef _STAGESCHEDULE_H
#define _STAGESCHEDULE_H

#include <stageinfo.h>
#include <ConfigChange.h>
#include <msgsend.h>
#include <msgreceive.h>
#include <stagecommon.h>

// TODO: remove undefs
#if defined(STAGE_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

// defined in harness.h
class PipelineStageHarnessBase;

// defined in stage.h
class PipelineStage;

// defined in stage.h
class SessionErrorObject;

/*************************************** GroupCompleteAction ***/
// this class is used by StageScheduler to track what action
// should be taken with a group of sessions completes

struct GroupCompleteAction
{
	enum Action
	{
		// start processing on a session set
		PROCESS_SESSION_SET,
		// start processing on an individual session
		PROCESS_SESSION,
		// send feedback to the listener
		GENERATE_FEEDBACK,
	} mAction;

	// session ID, set ID, etc.
	int mID;

	// session/session set UID;
	unsigned char mUID[16];

public:
	// leave the default undefined
	GroupCompleteAction()
	{ }

	GroupCompleteAction(const GroupCompleteAction & arOther)
	{ *this = arOther; }

	GroupCompleteAction & operator = (const GroupCompleteAction & arOther)
	{
		mAction = arOther.mAction;
		mID = arOther.mID;
		memcpy(mUID, arOther.mUID, 16);
		return *this;
	}
};

/***************************************** PipelineScheduler ***/

class StageScheduler :
	public StageMessageHandler,
	public virtual ObjectWithError,
	public ConfigChangeObserver
{
public:
	StageScheduler();
	virtual ~StageScheduler();

public:
	// clear all internal data structures
	DllExport virtual void Clear();

	DllExport virtual BOOL Init(PipelineStageHarnessBase * apHarness, const char * apConfigPath,
															const char * apStageName, int aStageInstance, BOOL aStartAsleep);


	DllExport void LogPerfData();
	DllExport int GetSessionsProcessed() const;

	// prepare the stage by reading the configuration and preparing the
	// queue.  This can be called again to refresh the initialization.
	// if routefrom is set, this overrides the name of the routing queue to read from.
	DllExport BOOL PrepareStage(BOOL aRunAutoTests);


	// the body of the server's main loop - read a message from the queue
	// and call the appropriate handler
	DllExport BOOL ProcessMessage();


	// call after the stage is ready to begin processing messages
	DllExport BOOL SendStageReadyMessage();

	PipelineStage * GetStage()
	{ return mpStage; }

	const PipelineStage * GetStage() const
	{ return mpStage; }


	PipelineStageHarnessBase * GetHarness()
	{ return mpHarness; }

	const PipelineStageHarnessBase * GetHarness() const
	{ return mpHarness; }


	StageMessageTransmitter * GetTransmitter()
	{ return &mTransmitter; }

	const StageMessageTransmitter * GetTransmitter() const
	{ return &mTransmitter; }


	//
	// accessors/mutators
	//

	DllExport BOOL GetExitFlag() const;
	DllExport void SetExitFlag();
	DllExport void ClearExitFlag();

private:
	DllExport BOOL GetRefreshFlag() const;
	DllExport void SetRefreshFlag();
	DllExport void ClearRefreshFlag();



//	DllExport int GetSessionsProcessed() const;

public:
	DllExport int GetMessagesReceived() const;

public:

	DllExport BOOL StopProcessing();


protected:
	//
	// handlers
	//
	DllExport virtual BOOL HandleProcessSession(const PipelineProcessSession & arMessage);
	DllExport virtual BOOL HandleWaitProcessSession(const PipelineProcessSession & arMessage);
	DllExport virtual BOOL HandleProcessSet(const PipelineProcessSessionSet & arMessage);
	DllExport virtual BOOL HandleWaitProcessSessionSet(
		const PipelineWaitProcessSessionSet & arMessage);
	DllExport virtual BOOL HandleSysCommand(const PipelineSysCommand & arMessage);
	DllExport virtual BOOL HandleChildrenComplete(const PipelineChildrenComplete & arMessage);
	DllExport virtual BOOL HandleSessionFailed(const PipelineSessionFailed & arMessage);
	DllExport virtual BOOL HandleSetFailed(const PipelineSetFailed & arMessage);
	DllExport virtual BOOL HandleGroupComplete(const PipelineGroupComplete & arMessage);

public:
	//
	// configuration change notification
	//
	DllExport virtual void ConfigurationHasChanged();

private:
	// start worker thread that initiates processing of sessions
	BOOL EnableProcessing();

	// stop worker thread that initiates processing of sessions
	BOOL DisableProcessing();

	// after a compound has failed, this sends feedback to the listener.
	BOOL SendCompoundResponse(MTPipelineLib::IMTSessionPtr aSession);

	// place info about a session on the ready list, but
	// only if the session isn't part of a failed compound.
	// if the session is part of a failed compound, immediately
	// mark it as complete.
	BOOL ScheduleSessionInternal(SessionInfo * apSessionInfo,
															 BOOL & arScheduled);

	BOOL SessionsProcessed(MTPipelineLib::IMTSessionSetPtr aSet);

	BOOL AfterProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet,
														SessionErrorObject & errObject,
														BOOL processSucceeded);



	// parent of the argument is now ready (all children have completed) - signal it to
	// continue through the pipeline
	BOOL ParentReady(MTPipelineLib::IMTSessionPtr aSession);

	//
	// signalling
	//
	BOOL SessionsAreReady();
	BOOL RemoveReadySessions();


	BOOL IsStartStage() const;

public:
	const std::string & GetName() const;

	int GetStageID() const;


private:
	// message logger
	NTLogger mLogger;

	MTPipelineLib::IMTSessionServerPtr mSessionServer;

	//
	// session scheduling
	//

	// the action to take when any group completes processing
	typedef std::map<int, GroupCompleteAction> GroupCompleteActionMap;
	GroupCompleteActionMap mGroupCompleteActions;

	//
	// stage properties
	//

	// if true, exit the stage's main loop
	BOOL mExitFlag;

	// name of this stage
	std::string mStageName;

	// if TRUE, profile
	BOOL mCollectProfile;

	//
	// helper classes
	//

	// message receiver/dispatcher
	StageMessageReceiver mReceiver;

	// message transmitter
	StageMessageTransmitter mTransmitter;


	// pointer back to the harness
	PipelineStageHarnessBase * mpHarness;

	// pointer to the object that processes sessions
	PipelineStage * mpStage;
};


#endif /* _STAGESCHEDULE_H */
