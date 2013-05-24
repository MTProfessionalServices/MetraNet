/**************************************************************************
 * SCHEDULE
 *
 * Copyright 1997-2001 by MetraTech Corp.
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

#include <metra.h>
#include <mtcom.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTConfigLib.tlb"

#include <mtcomerr.h>

#include <stageschedule.h>
#include <stage.h>
#include <mtprogids.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <MSIX.h>
#include <propids.h>
#include <mtprogids.h>
#include <SetIterate.h>
#include <queue.h>
#include <makeunique.h>
#include <harness.h>
#include <perflog.h>

#include <pipemessages.h>

#include <sessionerr.h>

#include <memhook.h>
#include <ConfigDir.h>

BOOL StageScheduler::IsStartStage() const
{ return mpStage->IsStartStage(); }

const std::string & StageScheduler::GetName() const
{ return mpStage->GetName(); }

int StageScheduler::GetStageID() const
{ return mpStage->GetStageID(); }


/*********************************************** SessionInfo ***/

SessionInfo::SessionInfo(MTPipelineLib::IMTSessionPtr aSession, PipelineStage * apStage)
{
	mSession = aSession;
	::GetSystemTimeAsFileTime(&mTimeEntered);
	mpStage = apStage;
}

SessionInfo::SessionInfo(MTPipelineLib::IMTSessionPtr aSession, const FILETIME & arTime,
												 PipelineStage * apStage)
{
	mSession = aSession;
	mTimeEntered = arTime;
	mpStage = apStage;
}

int SessionInfo::MicrosSinceEntered() const
{
#if 0
	// TODO: do we need this data?
	ASSERT(0);
	return -1;
#else
	LARGE_INTEGER largeTime;
	largeTime.LowPart = mTimeEntered.dwLowDateTime;
	largeTime.HighPart = mTimeEntered.dwHighDateTime;

	FILETIME now;
	::GetSystemTimeAsFileTime(&now);
	LARGE_INTEGER largeNow;
	largeNow.LowPart = now.dwLowDateTime;
	largeNow.HighPart = now.dwHighDateTime;

	// TODO: is this safe to do?
	int count = (int) (largeNow.QuadPart - largeTime.QuadPart);
	return count / 10;
#endif
}

void SessionInfo::SetTimeEnteredToNow()
{
	::GetSystemTimeAsFileTime(&mTimeEntered);
}

/******************************************** SessionSetInfo ***/

SessionSetInfo::SessionSetInfo(MTPipelineLib::IMTSessionSetPtr aSet, PipelineStage * apStage)
{
	mSet = aSet;
	mpStage = apStage;
}


/******************************************** StageScheduler ***/

StageScheduler::StageScheduler()
	: mExitFlag(FALSE),
		mpHarness(NULL),
		mpStage(NULL)
{ }

StageScheduler::~StageScheduler()
{
	Clear();

	if (mpStage)
	{
		delete mpStage;
		mpStage = NULL;
	}
}


void StageScheduler::Clear()
{
	DisableProcessing();
	ClearExitFlag();
	mpStage->Clear();
}

BOOL StageScheduler::Init(PipelineStageHarnessBase * apHarness, const char * apConfigPath,
													const char * apStageName, int aStateInstance, BOOL aStartAsleep)
{
	const char * functionName = "StageScheduler::Init";

	mpHarness = apHarness;

	mStageName = apStageName;

	// TODO: better init here
	std::string tag("[");
	tag += apStageName;

  char buf[10];
  sprintf(buf, "%d", aStateInstance);
  tag += "_";
  tag += buf;

	tag += ']';
	LoggerConfigReader configReader;
	if (!mLogger.Init(configReader.ReadConfiguration("logging"), tag.c_str()))
	{
		SetError(mLogger);
		return FALSE;
	}

	//
	// create the stage itself and initialize it
	//
	ASSERT(!mpStage);
	mpStage = new PipelineStage;

	if (!mpStage->Init(this, apConfigPath, apStageName, aStateInstance, aStartAsleep))
	{
		SetError(*mpStage);
		return FALSE;
	}


	//
	// initialize the message receiver
	//
	mLogger.LogThis(LOG_DEBUG, "Initializing receiver");
	if (!mReceiver.Init(this, mLogger, mStageName.c_str(),
											mpHarness->GetPipelineInfo().UsePrivateQueues()))
	{
		SetError(mReceiver.GetLastError());
		return FALSE;
	}

	//
	// initialize transmitter
	//
	mLogger.LogThis(LOG_DEBUG, "Initializing transmitter");
	if (!mpStage->IsFinalStage())
	{
		if (!mTransmitter.Init(mLogger, mpStage->GetNextStageName().c_str(),
													 mpHarness->GetPipelineInfo().UsePrivateQueues()))
		{
			SetError(mTransmitter.GetLastError());
			return FALSE;
		}
	}
	else
	{
		if (!mTransmitter.Init(mLogger, mpHarness->GetPipelineInfo().UsePrivateQueues()))
		{
			SetError(mTransmitter.GetLastError());
			return FALSE;
		}
	}


	//
	// flush any unnecessary messages
	//
	mLogger.LogThis(LOG_INFO, "Flushing system messages");
	if (!mReceiver.FlushSystemMessages())
	{
		SetError(mReceiver.GetLastError());
		return FALSE;
	}


	//
	// initialize system profiler
	//
	mCollectProfile = mpHarness->GetCollectProfile();

	//
	// initialize the session server
	//
	mSessionServer = mpHarness->GetSessionServer();

	return TRUE;
}


void StageScheduler::LogPerfData()
{
	mpStage->LogPerfData();
}

int StageScheduler::GetSessionsProcessed() const
{
	return mpStage->GetSessionsProcessed();
}

// prepare the stage by reading the configuration and preparing the
// queue.  This can be called again to refresh the initialization.
// if routefrom is set, this overrides the name of the routing queue to read from.
BOOL StageScheduler::PrepareStage(BOOL aRunAutoTests)
{
	const char * functionName = "StageScheduler::PrepareStage";

	if (!mpStage->PrepareStage(aRunAutoTests))
	{
		SetError(*mpStage);
		return FALSE;
	}

	return TRUE;
}





BOOL StageScheduler::ProcessMessage()
{
	try
	{
		if (!mReceiver.ReceiveMessage())
		{
			SetError(mReceiver);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return FALSE;
		}
		else
			return TRUE;
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Exception thrown while processing a pipeline message",
											 err);
		mLogger.LogThis(LOG_FATAL, buffer.c_str());
		return FALSE;
	}
}

BOOL StageScheduler::SendStageReadyMessage()
{
	if (!mTransmitter.SendStageReadyMessage(GetStageID()))
	{
		SetError(mTransmitter.GetLastError());
		return FALSE;
	}
	return TRUE;
}


void StageScheduler::SetExitFlag()
{ mExitFlag = TRUE; }

void StageScheduler::ClearExitFlag()
{	mExitFlag = FALSE; }

BOOL StageScheduler::GetExitFlag() const
{	return mExitFlag; }

/*
 * worker thread
 */

BOOL StageScheduler::StopProcessing()
{
	return TRUE;
}

/*
 * Handlers
 */

BOOL StageScheduler::HandleWaitProcessSession(const PipelineProcessSession & arMessage)
{
	const char * functionName = "StageScheduler::HandleWaitProcessSession";

	if (!mpStage->Wakeup())
		return FALSE;

	ASSERT(0);
	return FALSE;
}



BOOL StageScheduler::HandleProcessSession(const PipelineProcessSession & arMessage)
{
	const char * functionName = "PipeineStage::HandleProcessSession";

	if (!mpStage->Wakeup())
		return FALSE;

	ASSERT(0);
	return FALSE;
}



BOOL StageScheduler::HandleProcessSet(const PipelineProcessSessionSet & arMessage)
{
	const char * functionName = "StageScheduler::HandleProcessSet";

	MarkRegion region("HandleProcessSet");
	if (!mpStage->Wakeup())
		return FALSE;

	//
	// process a set of sessions that exist in the shared memory
	//

	mLogger.LogVarArgs(LOG_DEBUG, "Received process set(%d)", arMessage.mSetID);

	if (!mpStage->ProcessSessions(arMessage.mSetID, arMessage.mSetUID))
	{
		mLogger.LogVarArgs(LOG_DEBUG, "Processing of session set %d failed", arMessage.mSetID);
		// NOTE: true returned because we don't want the stage to return exit
		// its message loop.  We've handled this case and can keep handling messages
		return TRUE;
	}

	return TRUE;
}

BOOL StageScheduler::HandleWaitProcessSessionSet(
	const PipelineWaitProcessSessionSet & arMessage)
{
	MarkRegion region("HandleWaitProcessSessionSet");

	// TODO: this assumes we're receiving the wait/process session
	// message before we receive the group complete message.

	int group = arMessage.mObjectOwnerID;

	GroupCompleteActionMap::const_iterator it = mGroupCompleteActions.find(group);
	if (it != mGroupCompleteActions.end())
	{
		// TODO: in this case, we already know the group is complete
		const GroupCompleteAction & action = it->second;

		ASSERT(0);
	}
	else
	{
		GroupCompleteAction action;
		action.mAction = GroupCompleteAction::PROCESS_SESSION_SET;
		action.mID = arMessage.mSetID;
		memcpy(action.mUID, arMessage.mSetUID, 16);

		mGroupCompleteActions[group] = action;
	}

	return TRUE;
}


//
// NOTE: not currently in use
//
BOOL StageScheduler::HandleSessionFailed(const PipelineSessionFailed & arMessage)
{
	ASSERT(0);
	return FALSE;
}


//
// NOTE: not currently in use
//
BOOL StageScheduler::HandleSetFailed(const PipelineSetFailed & arMessage)
{
	ASSERT(0);
	return FALSE;
}

BOOL StageScheduler::HandleChildrenComplete(const PipelineChildrenComplete & arMessage)
{
	const char * functionName = "StageScheduler::HandleChildrenComplete";

	if (!mpStage->Wakeup())
		return FALSE;

	ASSERT(0);
	return FALSE;
}

BOOL StageScheduler::HandleGroupComplete(const PipelineGroupComplete & arMessage)
{
	const char * functionName = "StageScheduler::HandleGroupComplete";

	MarkRegion region("HandleGroupComplete");

	if (!mpStage->Wakeup())
		return FALSE;

	//
	// a group has completed - this will trigger some action
	//

	ASSERT(IsStartStage());
	if (!IsStartStage())
	{
		SetError(PIPE_ERR_ROUTING_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Non-start stage receive PIPELINE_GROUP_COMPLETE.");
		return FALSE;
	}

	mLogger.LogVarArgs(LOG_DEBUG, "Received group complete(%d)", arMessage.mObjectOwnerID);

	// find the action that needs to be taken
	int group = arMessage.mObjectOwnerID;

	GroupCompleteActionMap::iterator it = mGroupCompleteActions.find(group);
	if (it == mGroupCompleteActions.end())
	{
		// TODO: in this case, we don't have any pending actions...
		// this should queue it up in case the action comes in later
		mLogger.LogVarArgs(LOG_ERROR, "Received UNRECOGNIZED group complete(%d)", arMessage.mObjectOwnerID);
		//ASSERT(0);
	}
	else
	{
		// copy it by value so we can delete the value in the map
		GroupCompleteAction action = it->second;
		mGroupCompleteActions.erase(it);

		PipelineProcessSessionSet processSet;
		BOOL result;
		switch (action.mAction)
		{
		case GroupCompleteAction::PROCESS_SESSION_SET:
			// fake a process session set action
			processSet.mSetID = action.mID;
			memcpy(processSet.mSetUID, action.mUID, 16);
			result = HandleProcessSet(processSet);
			break;
		case GroupCompleteAction::PROCESS_SESSION:
			// fake a process session action
			ASSERT(0);
			break;
		case GroupCompleteAction::GENERATE_FEEDBACK:
			// send a message back to the listener
			ASSERT(0);
			break;
		default:
			ASSERT(0);
			break;
		}
	}


	return TRUE;
}

BOOL StageScheduler::HandleSysCommand(const PipelineSysCommand & arMessage)
{
	switch (arMessage.mCommand)
	{
	case PipelineSysCommand::EXIT:
		// setting this flag will cause the stage to exit next time through the loop.
		mLogger.LogVarArgs(LOG_DEBUG, "Exiting stage %s...", (const char *) GetName().c_str());
		SetExitFlag();
		cout << "Exiting..." << endl;
		break;
	case PipelineSysCommand::LOG_PERF_DATA:
		/// return?
		mpStage->LogPerfData();
		break;
	default:
		SetError(PIPE_ERR_BAD_MESSAGE, ERROR_MODULE, ERROR_LINE,
						 "StageScheduler::HandleSysCommand",
						 "Unknown system command.");

		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}

	return TRUE;
}

void StageScheduler::ConfigurationHasChanged()
{
	mLogger.LogThis(LOG_INFO, "Configuration change signalled - refreshing configuration");

	try
	{
		if (!mpStage->ConfigurationHasChanged())
		{
			// TODO: what should be done here?
			mLogger.LogThis(LOG_FATAL, "Unable to refresh configuration");
			mLogger.LogErrorObject(LOG_FATAL, GetLastError());
		}
		else
		{
			mLogger.LogThis(LOG_DEBUG, "Configuration changed successfully");
		}
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Error reconfiguring pipeline", err);

		mLogger.LogThis(LOG_FATAL, buffer.c_str());

		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
		{
			cout << "  Description: " << (const char *) desc << endl;
		}
		if (src.length() > 0)
		{
			mLogger.LogVarArgs(LOG_FATAL, " Source: %s", (const char *) src);
			cout << "  Source: " << (const char *) src << endl;
		}
	}
}



BOOL StageScheduler::EnableProcessing()
{
	return TRUE;
}

BOOL StageScheduler::DisableProcessing()
{
	return TRUE;
}

int StageScheduler::GetMessagesReceived() const
{
	return mReceiver.GetMessagesReceived();
}

