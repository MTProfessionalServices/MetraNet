/**************************************************************************
 * @doc PIPELINE
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
 *  $Date$
 *  $Author$
 *  $Revision$
 ***************************************************************************/

// we need the full windows.h file for a couple defines we use
#include <mtcom.h>
#include <windows.h>

#include <metra.h>

#import <MTConfigLib.tlb>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#include "pipeline.h"

#include <multi.h>
#include <domainname.h>
#include <MTUtil.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <pipelinehooks.h>
#include <ConfigDir.h>
#include <makeunique.h>
#include <observedevent.h>
#include <errutils.h>
#include <stopevent.h>
#include <mtcomerr.h>
#include <winsvc.h>
#include <iostream>
#include <stdutils.h>

using namespace std;

static ComInitialize gComInitialize;

void PrintError(const char * apStr, const ErrorObject * obj)
{
	string buffer;
	StringFromError(buffer, apStr, obj);
	cout << buffer.c_str() << endl;
}

/********************************************* RunningStages ***/

RunningStages::RunningStages()
{ }

template void destroyPtr(StageProcess *);

RunningStages::~RunningStages()
{
	for_each(mStageProcesses.begin(), mStageProcesses.end(), destroyPtr<StageProcess>);
}

void RunningStages::LogUnstartedStages()
{
	mLock.Lock();

	StageReferences::const_iterator it;
	for (it = mStageReferences.begin(); it != mStageReferences.end(); ++it)
	{
		const StageReference & reference = it->second;
		if (reference.GetState() != PipelineStageStatus::PIPELINE_STAGE_READY)
		{
			const char * status;
			switch (reference.GetState())
			{
			case PipelineStageStatus::PIPELINE_STAGE_STARTING:
				status = "STARTING"; break;
			case PipelineStageStatus::PIPELINE_STAGE_READY:
				status = "READY"; break;
			case PipelineStageStatus::PIPELINE_STAGE_PAUSED:
				status = "PAUSED"; break;
			case PipelineStageStatus::PIPELINE_STAGE_QUITTING:
				status = "QUITTING"; break;
			case PipelineStageStatus::PIPELINE_STAGE_QUIT:
				status = "QUIT"; break;
			case PipelineStageStatus::PIPELINE_STAGE_RESTARTING:
				status = "RESTARTING"; break;
			default:
				status = "*UNKNOWN*"; break;
			}

			mLogger.LogVarArgs(LOG_WARNING, "Stage %s not started: state is %s",
												 reference.GetStageName().c_str(),
												 status);
		}
	}

	mLock.Unlock();
}

int RunningStages::GetStartingStages()
{
	mLock.Lock();

	int count = 0;
	StageReferences::const_iterator it;
	for (it = mStageReferences.begin(); it != mStageReferences.end(); ++it)
	{
		const StageReference & reference = it->second;
		if (reference.GetState() == PipelineStageStatus::PIPELINE_STAGE_STARTING)
			count++;
	}

	mLock.Unlock();

	return count;
}

int RunningStages::GetQuitProcesses()
{
	mLock.Lock();

	int quitProcesses = 0;
	if (mPipeSvc.GetState() == PipelineStageStatus::PIPELINE_STAGE_QUIT)
		quitProcesses++;

	for (int i = 0; i < (int) mStageProcesses.size(); i++)
	{
		StageProcess * process = mStageProcesses[i];
		if (process->GetState() == PipelineStageStatus::PIPELINE_STAGE_QUIT)
			quitProcesses++;
	}

	mLock.Unlock();

	return quitProcesses;
}

BOOL RunningStages::StageStarted(int aStageID, int &startCount)
{
	mLock.Lock();

	const char * functionName = "RunningStages::StageStarted";

	StageReferences::iterator findit = mStageReferences.find(aStageID);
	if (findit == mStageReferences.end())
	{
		SetError(PIPE_ERR_INVALID_STAGE_ID, ERROR_MODULE, ERROR_LINE, functionName);
		mLock.Unlock();
		return FALSE;
	}

	StageReference & reference = findit->second;

  int instCnt = reference.GetInstanceCount();
  reference.SetInstanceCount( ++instCnt );

	if (reference.GetState() != PipelineStageStatus::PIPELINE_STAGE_STARTING)
	{
		mLogger.LogThis(LOG_WARNING,
										"received stage ready message but stage was already ready.");
	}
	else
	{
		mLogger.LogVarArgs(LOG_INFO, "Stage %s ready.",
											 reference.GetStageName().c_str());
		cout << "Stage " << reference.GetStageName().c_str() << " ready." << endl;
		reference.SetState(PipelineStageStatus::PIPELINE_STAGE_READY);

    startCount++;
	}

	reference.SetState(PipelineStageStatus::PIPELINE_STAGE_READY);

	mLock.Unlock();
	return TRUE;
}

void RunningStages::AddStageProcess(StageProcess * process)
{
	mLock.Lock();
	mStageProcesses.push_back(process);
	mLock.Unlock();
}

void RunningStages::AddStageReference(int aStageID, const char * apStageName,
																			BOOL aPrivateQueues)
{
	mLock.Lock();

	StageReference ref(apStageName, aPrivateQueues);
	mStageReferences[aStageID] = ref;
	mLock.Unlock();
}

BOOL RunningStages::CalculateWaitHandles(HANDLE aStopEvent, const HANDLE * & arpHandles,
																				 int & arHandleCount)
{
	mLock.Lock();

	mLiveProcesses.clear();
	mProcessHandles.clear();
	if (mPipeSvc.GetState() == PipelineStageStatus::PIPELINE_STAGE_STARTING
		|| mPipeSvc.GetState() == PipelineStageStatus::PIPELINE_STAGE_READY)
		mProcessHandles.push_back(mPipeSvc.GetProcessHandle());
	mProcessHandles.push_back(aStopEvent);
	for (int i = 0; i < (int) mStageProcesses.size(); i++)
	{
		StageProcess * process = mStageProcesses[i];
		ASSERT(process);
		if (process->GetState() != PipelineStageStatus::PIPELINE_STAGE_QUIT)
		{
			mProcessHandles.push_back(process->GetProcessHandle());
			mLiveProcesses.push_back(process);
		}
	}

	arpHandles = &mProcessHandles[0];
	arHandleCount = mProcessHandles.size();

	mLock.Unlock();
	return TRUE;
}

BOOL RunningStages::MonitorExits(HANDLE aStopEventHandle)
{
	// TODO: rewrite this routine!

	const char * functionName = "RunningStages::MonitorExits";

	while (TRUE)
	{
		const HANDLE * handles = NULL;
		int handleCount = -1;
		BOOL waitForPipeSvc =
			(mPipeSvc.GetState() == PipelineStageStatus::PIPELINE_STAGE_STARTING
			 || mPipeSvc.GetState() == PipelineStageStatus::PIPELINE_STAGE_READY);

		CalculateWaitHandles(aStopEventHandle, handles, handleCount);
		// the stop event handle is always part of the array.
		if (handleCount == 1)
			break;										// nothing to wait for!

		DWORD waitResult = WaitForMultipleObjects(handleCount, // number of handles
																							handles, // pointer to the object-handles
																							FALSE, // wait flag (wait for any of them)
																							INFINITE); // time-out interval (in millis)

		//
		// now we know _at least_ one process has exited.  we need to test them
		// all in case more than one has exited.  The return value of WaitForMultipleObjects
		// is the index of the first one.
		//

		if (waitResult == WAIT_FAILED)
		{
			// TODO: pass win32 or hresult?
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
							 "Error while waiting for process handles");
			return FALSE;
		}

		// event is the index of the first stage to have quit
		int event = waitResult - WAIT_OBJECT_0;

		// if we aren't waiting for the pipesvc event, then all events have been
		// shifted back by one.  shift them up again
		int handleIndex = event;
		if (!waitForPipeSvc)
			event++;

		if (event == STOP_EVENT_OFFSET)
			break;										// stop event!

		if (waitForPipeSvc && event == PIPESVC_EVENT_OFFSET)
			PipelineServiceExited();	// pipesvc stopped
		else
		{
			for (int test = handleIndex; test < handleCount; test++)
			{
				DWORD testResult = ::WaitForSingleObject(handles[test], // handle to wait for
																								 0); // test and return immediately
				if (testResult == WAIT_OBJECT_0)
				{
					mLogger.LogVarArgs(LOG_TRACE, "Event %d fired.", event);


					BOOL expected;
					if (!ProcessExitedWithIndex(test, waitForPipeSvc, expected))
					{
						ASSERT(0);
						// TODO: handle this error
					}
				}
			}
		}
	}

	mLogger.LogThis(LOG_DEBUG, "Exiting MonitorExits thread.");
	return TRUE;
}

void RunningStages::PipelineServiceExited()
{
	if (mPipeSvc.IsExiting())
	{
		cout << "Pipeline service process (pipesvc) stopped as expected" << endl;
		mLogger.LogThis(LOG_DEBUG, "Pipeline service process (pipesvc) stopped as expected");
	}
	else
	{
		cout << "Pipeline service process (pipesvc) quit unexpectedly." << endl;
		mLogger.LogThis(LOG_FATAL, "Pipeline service process (pipesvc) quit unexpectedly!");
        // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
        /** JAB (ESR-3208) Detect catastrophic failures 
         ** with CMDSTAGE or PIPESVC then 
         ** shutdown, and allow ourselves
         ** to clean up and get restarted
         **/
        PipelineController::GetController()->EmergencyStop();
	}

	// either way, it's not running now
	mPipeSvc.SetState(PipelineStageStatus::PIPELINE_STAGE_QUIT);
}


BOOL RunningStages::ProcessExitedWithIndex(int aIndex, BOOL aWaitForPipeSvc,
																					 BOOL & arExpected)
{
	// if we aren't waiting for the pipesvc event, then all events have been
	// shifted back by one.  shift them up again
	if (!aWaitForPipeSvc)
		aIndex++;

	mLock.Lock();
	StageProcess * process = mLiveProcesses[aIndex - STAGE_PROCESS_OFFSET];
	ASSERT(process);
	const char * name = process->GetName();

	if (process->GetState() == PipelineStageStatus::PIPELINE_STAGE_QUITTING)
	{
		// it was expected to quit..
		mLogger.LogVarArgs(LOG_DEBUG, "Process %s quit as expected.", name);
		cout << "Process " << name << " quit as expected." << endl;

		// remove it like we were expecting to
		process->SetState(PipelineStageStatus::PIPELINE_STAGE_QUIT);
		arExpected = TRUE;
		mLock.Unlock();
		return TRUE;
	}

	arExpected = FALSE;
	mLogger.LogVarArgs(LOG_ERROR, "Process %s has exited unexpectedly.", name);

	char buffer[256];
	sprintf(buffer, "Process %s has exited unexpectedly.", name);
	mLogger.LogEvent(NTEventMsg::EVENT_ERROR, buffer);

	cout << "Process " << name << " has exited unexpectedly." << endl;
// ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
#if 0 
    /** JAB: Removed as part of ESR-3208 **/
	// if we haven't restarted it too many times already, restart it
	// TODO: temporary!
	if (FALSE)
	//if (stage->Restart())
	{
		// it's restarting now...
		process->SetState(PipelineStageStatus::PIPELINE_STAGE_RESTARTING);
	}
	else
#endif
	{
		mLogger.LogVarArgs(LOG_FATAL, "Process %s stopped, shutting down service.", name);

		cout << "Process " << name << " stopped, shutting down service." << endl;

		char buffer[256];
		sprintf(buffer, "Process %s stopped, shutting down service.", name);
		mLogger.LogEvent(NTEventMsg::EVENT_ERROR, buffer);

		// remove it - couldn't be restarted
		process->SetState(PipelineStageStatus::PIPELINE_STAGE_QUIT);
	}
    // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
    /** JAB (ESR-3208) Detect catastrophic failures 
     ** with CMDSTAGE or PIPESVC then 
     ** shutdown, and allow ourselves
     ** to clean up and get restarted
     **/
    PipelineController::GetController()->EmergencyStop();

	mLock.Unlock();
	return TRUE;
}


BOOL RunningStages::StopAllStages()
{
	mLock.Lock();

	// mark all processes as quitting.
	// NOTE: there may not be a 1 to 1 mapping between stage and process
	for (int i = 0; i < (int) mStageProcesses.size(); i++)
		mStageProcesses[i]->SetState(PipelineStageStatus::PIPELINE_STAGE_QUITTING);

	cout << "Stopping all pipeline stages: " << endl;
	mLogger.LogThis(LOG_INFO, "Stopping all pipeline stages.");

  int refCount;
	StageReferences::iterator it;
	for (it = mStageReferences.begin(); it != mStageReferences.end(); ++it)
	{
		StageReference & reference = it->second;

    refCount = reference.GetInstanceCount();
    for( int i = 0; i < refCount; i++ )
    {
		  std::string name = reference.GetStageName();
		  cout << "Sending message to " << name.c_str() << endl;
		  BOOL result = reference.SendStopSignal();
		  if (!result)
		  {
			  cout << "Unable to send stop signal to " << name.c_str() << endl;

			  mLogger.LogVarArgs(LOG_ERROR, "Unable to send stop signal %s", name.c_str());
			  mLogger.LogErrorObject(LOG_ERROR, reference.GetLastError());
			  // TODO: what do we do here?
		  }
    }
	}

	mLogger.LogThis(LOG_INFO, "Stop message sent to all stages.");

	mLock.Unlock();

	return TRUE;
}

BOOL RunningStages::StartPipelineService(const char * apLogin,
																				 const char * apPassword,
																				 const char * apDomain,
																				 BOOL aStartConsoles)
{
	if (mPipeSvc.GetState() == PipelineStageStatus::PIPELINE_STAGE_STARTING
			|| mPipeSvc.GetState() == PipelineStageStatus::PIPELINE_STAGE_READY)
		return TRUE;								// already started

	if (!mPipeSvc.Start(apLogin, apPassword, apDomain,
											aStartConsoles))
	{
		SetError(mPipeSvc);
		return FALSE;
	}

	long pid = mPipeSvc.GetProcessID();
	mLogger.LogVarArgs(LOG_INFO, "Pipeline service process starting (pid=%ld).",
										 pid);
	cout << "Pipeline service process starting.  Process ID = " << pid << endl;

	return TRUE;
}

BOOL RunningStages::StopPipelineService()
{
	if (!mPipeSvc.Stop())
	{
		SetError(mPipeSvc);
		return FALSE;
	}
	return TRUE;
}

BOOL RunningStages::PipelineServiceRunning()
{
	return mPipeSvc.IsStarted();
}

PipelineStageStatus::StageStatus RunningStages::GetPipelineServiceState()
{
	return mPipeSvc.GetState();
}

void RunningStages::SetPipelineServiceState(PipelineStageStatus::StageStatus aState)
{
	mPipeSvc.SetState(aState);
}

/******************************************* PipelineProcess ***/

PipelineProcess::~PipelineProcess()
{ }



BOOL PipelineProcess::StartProcess(const char * apEXE,
																	 const char * apCommandLine,
																	 const char * apLogin,
																	 const char * apPassword,
																	 const char * apDomain,
																	 BOOL aStartConsoles,
																	 const char * apConsoleTitle)
{
	const char * functionName = "StageProcess::CreateStageInternal";

	if (!apLogin || !*apLogin)
		apLogin = NULL;
	if (!apPassword || !*apPassword)
		apPassword = "";
	if (!apDomain || !*apDomain)
		apDomain = "";							// this shouldn't happen

	STARTUPINFO startupInfo;
	startupInfo.cb = sizeof(startupInfo);
	startupInfo.lpReserved = NULL;
	startupInfo.lpDesktop = NULL;
	startupInfo.lpTitle = const_cast<char *>(apConsoleTitle);
	startupInfo.dwX = startupInfo.dwY = 0;
	startupInfo.dwXSize = startupInfo.dwYSize = 0;
	startupInfo.dwFillAttribute = 0;
	startupInfo.dwFlags = STARTF_USESHOWWINDOW;
//	startupInfo.dwFlags = 0;
	startupInfo.wShowWindow = SW_MINIMIZE;
//	startupInfo.wShowWindow = 0;
	startupInfo.cbReserved2 = 0;
	startupInfo.lpReserved2 = 0;
	startupInfo.hStdInput = 0;
	startupInfo.hStdOutput = 0;
	startupInfo.hStdError = 0;

	BOOL result;

	DWORD creationFlags;
	if (aStartConsoles)
		creationFlags = CREATE_NEW_CONSOLE;
	else
		creationFlags = 0;

	if (apLogin)
	{
		HANDLE loginHandle = NULL;
		if (!::LogonUserA(const_cast<char *>(apLogin),
											const_cast<char *>(apDomain),
											const_cast<char *>(apPassword),
											// TODO: should we do this or LOGON32_LOGON_NETWORK?
											//LOGON32_LOGON_NETWORK,
											//LOGON32_LOGON_SERVICE,
											//LOGON32_LOGON_BATCH,
											LOGON32_LOGON_INTERACTIVE,	// type of logon operation
											LOGON32_PROVIDER_DEFAULT, // logon provider
											&loginHandle))
		{
			std::string buffer("Unable to login as user ");
			buffer += apLogin;
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
							 buffer.c_str());
			return FALSE;
		}


		result = ::CreateProcessAsUserA(loginHandle,
																		apEXE, // pointer to name of executable module
																// pointer to command line string
																		const_cast<char *>(apCommandLine),
																		NULL, // pointer to process security attributes
																		NULL, // pointer to thread security attributes
																		FALSE, // handle inheritance flag
																		creationFlags, // creation flags
																		//0, // creation flags
																		NULL, // pointer to new environment block
																		NULL, // pointer to current directory name
																		&startupInfo, // pointer to STARTUPINFO
																		&mProcessInfo); // pointer to PROCESS_INFORMATION
	}
	else
	{
		result = ::CreateProcessA(apEXE, // pointer to name of executable module
																// pointer to command line string
														 const_cast<char *>(apCommandLine),
														 NULL, // pointer to process security attributes
														 NULL, // pointer to thread security attributes
														 FALSE, // handle inheritance flag
														 creationFlags, // creation flags
														 NULL, // pointer to new environment block
														 NULL, // pointer to current directory name
														 &startupInfo, // pointer to STARTUPINFO
														 &mProcessInfo); // pointer to PROCESS_INFORMATION
	}

	if (!result)
	{
		DWORD err = ::GetLastError();
		SetError(err, ERROR_MODULE, ERROR_LINE, functionName);
		mpLastError->GetProgrammerDetail() =
			"Unable to start process with command line '";
		mpLastError->GetProgrammerDetail() += apCommandLine;
		mpLastError->GetProgrammerDetail() += '\'';

		return FALSE;
	}
	return TRUE;
}


BOOL PipelineProcess::GetExePath(std::string & arExePath, const char * apExeName)
{
	const char * functionName = "PipelineProcess::GetExePath";

	char buffer[MAX_PATH];
	if (::GetModuleFileName(NULL, // handle to module to find filename for 
													buffer, sizeof(buffer)) == 0)
	{
		DWORD err = ::GetLastError();
		SetError(err, ERROR_MODULE, ERROR_LINE, functionName);
		mpLastError->GetProgrammerDetail() = "Unable to get module file name";
		return FALSE;
	}

	arExePath = buffer;

	int last = arExePath.find_last_of( '\\', arExePath.length() - 1);
	if (last == string::npos)
		return FALSE;
	if ((unsigned) last == arExePath.length() - 1)
	{
		arExePath.substr(0, last - 1);
		last = arExePath.find_last_of('\\', arExePath.length() -1);
		if (last == NULL)
			return FALSE;
	}

	arExePath.resize(last + 1);

	arExePath += apExeName;

	return TRUE;
}


/********************************************** StageProcess ***/

const char * StageProcess::mpEXE = "cmdstage.exe";

StageProcess::StageProcess(const char * apName, BOOL aPrivateQueue)
	: mName(apName), mRetries(0),
		mState(PipelineStageStatus::PIPELINE_STAGE_STARTING),
		mUsePrivateQueues(aPrivateQueue)
{
}

StageProcess::~StageProcess()
{
}

bool StageProcess::operator == (const StageProcess & arStage)
{
	return &arStage == this;
}

BOOL StageProcess::CreateCommandLine(const char * apConfigDir,
																		 const char * apLogin,
																		 const char * apPassword,
																		 const char * apDomain)
{
	if (!GetExePath(mStageEXE, mpEXE))
		return FALSE;

	mCommandLine += mStageEXE;
	mCommandLine += ' ';
	/// TODO:
	mCommandLine += mName.c_str();

#if 0
	if (!apLogin || !*apLogin)
		apLogin = NULL;
	if (!apPassword || !*apPassword)
		apPassword = NULL;
	if (!apDomain || !*apDomain)
		apDomain = NULL;							// this shouldn't happen
#endif

	return TRUE;
}


BOOL StageProcess::CreateHarnessProcess(BOOL aSleep,
																				const char * apLogin,
																				const char * apPassword,
																				const char * apDomain,
																				BOOL aStartConsoles)
{
	const char * functionName = "StageProcess::CreateStageProcess";

	if (!GetExePath(mStageEXE, mpEXE))
		return FALSE;

	mCommandLine += mStageEXE;
	mCommandLine += ' ';
	/// TODO:
	mCommandLine += "*all*";
	if (aSleep)
		mCommandLine += " -sleep";

#if 0
	if (!apLogin || !*apLogin)
		apLogin = NULL;
	if (!apPassword || !*apPassword)
		apPassword = NULL;
	if (!apDomain || !*apDomain)
		apDomain = NULL;							// this shouldn't happen
#endif

	return StartStageInternal(apLogin, apPassword, apDomain, aStartConsoles);
}

BOOL StageProcess::CreateStageProcess(const char * apConfigDir,
																			const char * apLogin,
																			const char * apPassword,
																			const char * apDomain,
																			BOOL aStartConsoles)
{
	const char * functionName = "StageProcess::CreateStageProcess";

	if (!CreateCommandLine(apConfigDir, apLogin, apPassword, apDomain))
		return FALSE;

	return StartStageInternal(apLogin, apPassword, apDomain, aStartConsoles);
}

BOOL StageProcess::StartStageInternal(const char * apLogin,
																			const char * apPassword,
																			const char * apDomain,
																			BOOL aStartConsoles)

{
	return StartProcess(mStageEXE.c_str(), mCommandLine.c_str(),
											apLogin, apPassword, apDomain,
											aStartConsoles, mName.c_str());
}

#if 0
BOOL StageProcess::Restart()
{
	// TODO: TEMPORARY!!!!!!!!!!!!!!!!!!!!!
	return FALSE;
	// TODO: TEMPORARY!!!!!!!!!!!!!!!!!!!!!


	const char * functionName = "StageProcess::Restart";

	if (mRetries >= MAX_RETRIES - 1)
	{
		SetError(PIPE_ERR_RESTART_FAILED, ERROR_MODULE, ERROR_LINE, functionName);
		mpLastError->GetProgrammerDetail() = "Too many retries";

		SetState(PipelineStageStatus::PIPELINE_STAGE_QUIT);
		return FALSE;
	}

	SetState(PipelineStageStatus::PIPELINE_STAGE_STARTING);
	mRetries++;
	return StartStageInternal();
}
#endif

/************************************ PipelineServiceProcess ***/

PipelineServiceProcess::PipelineServiceProcess()
{
	mState = PipelineStageStatus::PIPELINE_STAGE_QUIT;
}


BOOL PipelineServiceProcess::Start(const char * apLogin,
																	 const char * apPassword,
																	 const char * apDomain,
																	 BOOL aStartConsoles)
{
	SetState(PipelineStageStatus::PIPELINE_STAGE_STARTING);

	std::string exe;

	if (!GetExePath(exe, "pipesvc.exe"))
		return FALSE;

	return StartProcess(exe.c_str(), exe.c_str(), apLogin, apPassword, apDomain,
											aStartConsoles, "Pipeline Services");
}

BOOL PipelineServiceProcess::Stop()
{
	SetState(PipelineStageStatus::PIPELINE_STAGE_QUITTING);
	PipelineStopEvent stopEvent;
	if (!stopEvent.Init()
			|| !stopEvent.Signal())
	{
		SetError(stopEvent);
		return FALSE;
	}

	return TRUE;
}

/**************************************** PipelineStopThread ***/

int PipelineStopThread::ThreadMain()
{
	mpController->Stop();
	return 1;
}

/**************************************** PipelineController ***/

PipelineController * PipelineController::mpControllerInstance = NULL;

PipelineController::PipelineController()
{
	// only one controller can be active at one time
	ASSERT(mpControllerInstance == NULL);
	mpControllerInstance = this;
}

PipelineController::~PipelineController()
{ }


int PipelineController::ThreadMain()
{
	// MonitorExits loops forever until all stages have died and can't be restarted
	if (!mRunningStages.MonitorExits(StopEventHandle()))
		return -1;
	return 0;
}


BOOL PipelineController::CreateQueueWithName(const wchar_t * apQueueName,
																						 const wchar_t * apLabel,
																						 BOOL aPrivate,
																						 BOOL aJournalOn /* = FALSE */)
{
	const char * functionName = "PipelineController::CreateQueueWithName";

	MessageQueue msgq;
	MessageQueueProps props;

	props.SetLabel(apLabel);
	props.SetJournal(aJournalOn);

	std::wstring queueName(apQueueName);
	MakeUnique(queueName);
	if (!msgq.CreateQueue(queueName.c_str(), aPrivate, props))
	{
		if (msgq.GetLastError()->GetCode() != MQ_ERROR_QUEUE_EXISTS)
		{
			SetError(msgq.GetLastError());
			return FALSE;
		}
	}
	return TRUE;
}


BOOL PipelineController::CreateQueue(const char * apStageName)
{
	cout << "Creating pipeline queue for stage: " << apStageName << endl;

	std::wstring name;
	ASCIIToWide(name, apStageName, strlen(apStageName));

	std::wstring queueName = name + L"Queue";

	std::wstring label(L"Queue for MetraTech Pipeline Stage ");
	label += name;

	if (!CreateQueueWithName(queueName.c_str(), label.c_str(), UsePrivateQueues()))
		return FALSE;

	return TRUE;
}

BOOL PipelineController::CreateQueues()
{
	cout << "Creating pipeline control queue" << endl;
	const wchar_t * queueName = PIPELINE_CONTROL_QUEUE;
	const wchar_t * label = L"Pipeline controller's queue";
	if (!CreateQueueWithName(queueName, label, UsePrivateQueues()))
		return FALSE;

	cout << "Creating all pipeline queues: " << endl;

	StageList & list = GetStages();
	StageList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		std::string name = (*it).mStageName;

		if (!CreateQueue(name.c_str()))
			return FALSE;
	}

	return TRUE;
}

BOOL PipelineController::DeleteQueues()
{
	cout << "Deleting queues..." << endl;
	const wchar_t * queueName = PIPELINE_CONTROL_QUEUE;
	if (!DeleteQueueWithName(queueName))
		return FALSE;

	StageList & list = GetStages();
	StageList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		std::string name = (*it).mStageName;

		if (!DeleteQueue(name.c_str()))
			return FALSE;
	}
	return TRUE;
}

BOOL PipelineController::DeleteQueue(const char* apStageName)
{
	cout << "deleting pipeline queue for stage: " << apStageName << endl;
	
	std::wstring name;
	ASCIIToWide(name, apStageName, strlen(apStageName));

	std::wstring queueName = name + L"Queue";

	if (!DeleteQueueWithName(queueName.c_str()))
		return FALSE;

	return TRUE;

}

BOOL PipelineController::DeleteQueueWithName(const wchar_t* apQueueName)
{
	MessageQueue msgq;
	std::wstring queueName(apQueueName);
	MakeUnique(queueName);
	if (!msgq.DeleteQueue(queueName.c_str(),TRUE))
	{
		if (msgq.GetLastError()->GetCode() != MQ_ERROR_QUEUE_NOT_FOUND)
		{
			SetError(msgq.GetLastError());
			return FALSE;
		}
	}
	return TRUE;
}

BOOL PipelineController::ExecuteStartupHooks()
{
	const char * functionName = "PipelineController::ExecuteStartupHooks";

	try
	{
		return ExecuteHooks("pipeline_startup", HOOK_PIPELINE_STARTUP);
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Stage failure while executing startup hooks", err);

		_bstr_t desc = err.Description();
		_bstr_t message = err.ErrorMessage();
		SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName,
						 !(err.Description()) ? "Startup hooks failed for unknown reason"
						 : err.Description());
		return FALSE;
	}
}

BOOL PipelineController::ExecuteShutdownHooks()
{
	const char * functionName = "PipelineController::ExecuteShutdownHooks";

	try
	{
		return ExecuteHooks("pipeline_shutdown", HOOK_PIPELINE_SHUTDOWN);
	}
	catch (_com_error & err)
	{
		SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName,
						 !(err.Description()) ? "Shutdown hooks failed for unknown reason"
						 : err.Description());
		return FALSE;
	}
}

BOOL PipelineController::ExecuteHooks(const char * apSection, HookState aState)
{
	// NOTE: this function can throw if there's an error

	PipelineHooks hooks;
	MTPipelineLib::IMTConfigPtr config(MTPROGID_CONFIG);

	MTPipelineLib::IMTConfigPropSetPtr propset;

	if (!hooks.ReadHookFile(config, propset)
			|| !hooks.SetupHookHandler(propset, apSection))
	{
		SetError(hooks);
		return FALSE;
	}

	_variant_t var;
	unsigned long arg = aState;	// tell the hook we're starting up or shutting down

	hooks.ExecuteAllHooks(var, arg);

	return TRUE;
}



BOOL PipelineController::StartupStage(const char * apStageName, BOOL /* aDebug */)
{
	cout << "Starting pipeline stage: " << apStageName << endl;

	mLogger.LogVarArgs(LOG_INFO, "Starting pipeline stage %s.", apStageName);

	StageProcess * process = new StageProcess(apStageName, UsePrivateQueues());

	if (!process->CreateStageProcess(mConfigDir.c_str(), mLogin.c_str(), mPassword.c_str(), mDomain.c_str(), mUseWindows))
	{
		SetError(process->GetLastError());
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		PrintError("Unable to start pipeline stage", GetLastError());
		delete process;
		return FALSE;
	}
	else
	{
		long pid = process->GetProcessID();
		mLogger.LogVarArgs(LOG_INFO, "Stage %s process started (pid=%ld).",
											 apStageName, pid);

		cout << "Stage " << apStageName << " started.  process ID = "
				 << pid << endl;

		// TODO: GetStageID is expensive
		int id = GetStageID(apStageName);
		mRunningStages.AddStageReference(id, apStageName, UsePrivateQueues());
		mRunningStages.AddStageProcess(process);

		mLogger.LogThis(LOG_DEBUG, "About to exit Startup");
		return TRUE;
	}
}

BOOL PipelineController::StartupExtension(const char * apStageName, BOOL /* aDebug */)
{
	ASSERT(0);
	return FALSE;
#if 0
	cout << "Starting pipeline stage: " << apStageName << endl;

	mLogger.LogVarArgs(LOG_INFO, "Starting pipeline stage %s.", apStageName);

	StageProcess * process = new StageProcess(apStageName, UsePrivateQueues());

	if (!process->CreateStageProcess(mConfigDir, mLogin, mPassword, mDomain, mUseWindows))
	{
		SetError(process->GetLastError());
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		PrintError("Unable to start pipeline stage", GetLastError());
		delete process;
		return FALSE;
	}
	else
	{
		long pid = process->GetProcessID();
		mLogger.LogVarArgs(LOG_INFO, "Stage %s process started (pid=%ld).",
											 apStageName, pid);

		cout << "Stage " << apStageName << " started.  process ID = "
				 << pid << endl;

		// TODO: GetStageID is expensive
		int id = GetStageID(apStageName);
		if (!mRunningStages.AddStageProcess(process))
		{
			// TODO: handle this error
			ASSERT(0);
		}

		mLogger.LogThis(LOG_DEBUG, "About to exit Startup");
		return TRUE;
	}
#endif
}

BOOL PipelineController::StartupAllAsProcess(BOOL /* aDebug */)
{
	StageList & list = GetStages();

	StageList::iterator it = list.begin();
	for (int i = 0; it != list.end(); i++, ++it)
	{
		std::string name = (*it).mStageName;
		int id = GetStageID(name.c_str());

		mRunningStages.AddStageReference(id, name.c_str(), UsePrivateQueues());
	}

	StageProcess * process = new StageProcess("stage harness", UsePrivateQueues());

	if (!process->CreateHarnessProcess(GetSleepAtStartup(),
																		 mLogin.c_str(), mPassword.c_str(), mDomain.c_str(), mUseWindows))
	{
		SetError(process->GetLastError());
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		PrintError("Unable to start stage harness", GetLastError());
		delete process;
		return FALSE;
	}
	else
	{
		long pid = process->GetProcessID();
		mLogger.LogVarArgs(LOG_INFO, "Stage harness process started (pid=%ld).",
											 pid);

		cout << "Stage harness process started.  process ID = "
				 << pid << endl;

		mRunningStages.AddStageProcess(process);

		mLogger.LogThis(LOG_DEBUG, "About to exit Startup");
		return TRUE;
	}
	return TRUE;
}


BOOL PipelineController::ReportServiceState(DWORD aState)
{
	const char * functionName = "PipelineController::ReportServiceState";

	if (!mRunningAsService)
		return TRUE;								// nothing to do

	mServiceStatus.dwCurrentState = aState;
	mServiceStatus.dwCheckPoint++;
	mServiceStatus.dwWaitHint = CHECKPOINT_DURATION + 20 * 1000;
    // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
    /** JAB: ESR-3208 
     ** Only accept failures under normal operation
     ** NOTES: During emergency shutdown, we go via the SCM, so during our shutdown
     ** the handle may become invalidated... so during this shutdown case, we 
     ** will not need to assert if we cannot set the state due to an invalid handle. 
     **/
    if (!::SetServiceStatus(mServiceStatusHandle, &mServiceStatus) && FATAL != mStopMode)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to set service status");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		ASSERT(0);
		return FALSE;
	}

	return TRUE;
}


BOOL PipelineController::StartupAll(BOOL aDebug)
{
	time_t startTime = time(NULL);

	const char * functionName = "PipelineController::StartupAll";

	if (!ReportServiceState(SERVICE_START_PENDING))
		return FALSE;

	std::string blank("");
	MakeUnique(blank);
	if (blank == "")
		mLogger.LogThis(LOG_INFO, "Running in single instance mode.");
	else
		mLogger.LogVarArgs(LOG_INFO, "Running as instance %s.", blank.c_str());

	if (!CreateQueues())
	{
		mLogger.LogThis(LOG_ERROR, "Unable to create queues. Has MSMQ service been started?");
		return FALSE;
	}

	if (!ReportServiceState(SERVICE_START_PENDING))
		return FALSE;

	if (!ExecuteStartupHooks())
	{
		mLogger.LogThis(LOG_ERROR, "Unable to execute startup hooks");
		return FALSE;
	}

	if (!ReportServiceState(SERVICE_START_PENDING))
		return FALSE;

	if (!InitControlQueue())
	{
		mLogger.LogThis(LOG_ERROR, "Unable to initialize control queue");
		return FALSE;
	}

	if (!ReportServiceState(SERVICE_START_PENDING))
		return FALSE;

	if (!FlushControlQueue())
	{
		mLogger.LogThis(LOG_ERROR, "Unable to flush control queue");
		return FALSE;
	}

	if (!ReportServiceState(SERVICE_START_PENDING))
		return FALSE;

	cout << "Starting pipeline service process" << endl;
	try
	{
		if (!mRunningStages.StartPipelineService(mLogin.c_str(), mPassword.c_str(), mDomain.c_str(), mUseWindows))
		{
			SetError(mRunningStages);
			mLogger.LogThis(LOG_ERROR, "Unable to start pipeline service process");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			PrintError("Unable to start pipeline service process", GetLastError());
			return FALSE;
		}
	}
	catch(_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Stage failure while starting pipeline", err);
		mLogger.LogThis(LOG_FATAL, buffer.c_str());
		return FALSE;
	}


	switch (GetProcessSetting())
	{
	case STAGE:
	{
		cout << "Starting all pipeline stages: " << endl;
		mLogger.LogThis(LOG_INFO, "Starting all pipeline stages.");
		StageList & list = GetStages();

		StageList::iterator it = list.begin();
		for (int i = 0; it != list.end(); i++, ++it)
		{
			std::string name = (*it).mStageName;
			if (!StartupStage(name.c_str(), aDebug))
			{
				mLogger.LogVarArgs(LOG_ERROR, "Unable to start stage %s", name.c_str());
				return FALSE;
			}
		}
		break;
	}

#if 0
	case EXTENSION:
		cout << "Starting all pipeline stages by extension: " << endl;
		mLogger.LogThis(LOG_INFO, "Starting all pipeline stages by extension.");
		if (!StartupExtension(name, aDebug))
		{
			mLogger.LogVarArgs(LOG_ERROR, "Unable to start stage %s", name.c_str());
			return FALSE;
		}
#endif

	case ALL:
		cout << "Starting all pipeline stages as one process: " << endl;
		mLogger.LogThis(LOG_INFO, "Starting all pipeline stages as one process.");
		if (!StartupAllAsProcess(aDebug))
		{
			mLogger.LogVarArgs(LOG_ERROR, "Unable to start stage harness");
			return FALSE;
		}
		break;

	}


	mLogger.LogThis(LOG_DEBUG, "Starting thread to wait for process exits.");

	// start thread to watch for dying stages
	StartThread();

	if (!HandleStartMessages(STAGE_START_TIMEOUT))
	{
		cout << "Unable to start all stages." << endl;
		mLogger.LogThis(LOG_ERROR, "Unable to start all stages");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());

		if (!Stop())
		{
			mLogger.LogThis(LOG_ERROR, "Unable to stop all stages");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		}

		return FALSE;
	}

	time_t now = time(NULL);

	mLogger.LogThis(LOG_INFO, "All stages have started.");
	cout << "All stages have started." << endl;
	cout << "Startup time: " << (now - startTime) << " seconds." << endl;

	return TRUE;
}


BOOL PipelineController::WaitForShutdown(BOOL aReportStatus)
{
	// TODO: this will wait infinitely.  should probably timeout
	// wait until the stages die - the thread will exit when they do
	if (mRunningAsService && aReportStatus)
	{
		while (TRUE)
		{
			if (!ReportServiceState(SERVICE_STOP_PENDING))
				return FALSE;

			if (WaitForThread(3 * 1000))
				break;
		}
	}
	else
		WaitForThread(INFINITE);

	mLogger.LogThis(LOG_DEBUG, "All stages have quit - exiting.");
	cout << "All stages have quit - exiting." << endl;
	return TRUE;
}


BOOL PipelineController::HandleStartMessages(DWORD aTimeout)
{
	const char * functionName = "PipelineController::HandleStartMessages";

	int initialStartingStages = mRunningStages.GetStartingStages();

	time_t startWait = time_t(NULL);
	int startCount = 0;
	while (TRUE)
	{
		if (!ReportServiceState(SERVICE_START_PENDING))
			return FALSE;

		time_t now = time_t(NULL);
		if ((now - startWait) > (long) aTimeout)
			break;										// timeout..

		int quitProcesses = mRunningStages.GetQuitProcesses();
		if (quitProcesses > 0) // && mRunningStages.PipelineServiceRunning())
			break;

		// get the count of stages starting, plus pipesvc if it's starting
		int startingStages = mRunningStages.GetStartingStages();
		if (mRunningStages.GetPipelineServiceState()
				== PipelineStageStatus::PIPELINE_STAGE_STARTING)
			startingStages++;

		if (startingStages == 0)
			break;

		// first we peek at the message so we know what type to receive
		QueueMessage message;

		// get the app specific part
		message.SetAppSpecificLong(0);

		// peek at the message
		if (!mListenQueue.Peek(message, CHECKPOINT_DURATION))
		{
			// timeout waiting for the message..
			// recalculate the count - stages may have quit before sending the message.
			continue;
		}

		const ULONG * type = message.GetAppSpecificLong();
		ASSERT(type);
		PipelineMessageID messageType = (PipelineMessageID) *type;

		if (messageType != PIPELINE_STAGE_STATUS)
		{
			// TODO: be more forgiving with other messages
			mLogger.LogVarArgs(LOG_FATAL,
												 "received bad message type %d.", (int) messageType);
			SetError(PIPE_ERR_ROUTING_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}

		PipelineStageStatus status;

		message.SetBody((UCHAR *) &status, sizeof(status));
		if (!mListenQueue.Receive(message))
		{
			SetError(mListenQueue.GetLastError());
			return FALSE;
		}

		// TODO: relax this...
		ASSERT(status.mStatus == PipelineStageStatus::PIPELINE_STAGE_READY);

		if (status.mStageID == -1)
		{
			// HACK: -1 means pipesvc
			if (mRunningStages.GetPipelineServiceState()
					!= PipelineStageStatus::PIPELINE_STAGE_STARTING)
			{
				mLogger.LogThis(LOG_WARNING,
												"received stage ready message but stage was already ready.");
			}
			else
			{
				mLogger.LogThis(LOG_INFO, "pipesvc ready.");
				cout << "pipesvc is ready" << endl;
				mRunningStages.SetPipelineServiceState(PipelineStageStatus::PIPELINE_STAGE_READY);
			}
		}
		else
		{
			// a stage started
			mRunningStages.StageStarted(status.mStageID, startCount);
		}
	}

	if (!mRunningStages.PipelineServiceRunning())
	{
		// hack: don't send stop messages to cmdstage before they actually start
		// up because they clear their stop messages on startup!
		int retry = 0;
		while (mRunningStages.GetStartingStages() > 0 && retry < 10)
		{
			Sleep(5 * 1000);
			retry++;
		}

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Pipeline service process failed to start");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}

	if (startCount != initialStartingStages)
	{
		mRunningStages.LogUnstartedStages();
		SetError(PIPE_ERR_STAGES_FAILED_STARTUP, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
	return TRUE;
}

void PipelineController::DumpInfo()
{
	cout << "Configuration version: " << GetVersion() << endl;
	cout << "Shared session memory mapped file name: "
			 << GetSharedSessionFile().c_str() << endl;
	cout << "Share name: " << GetShareName().c_str() << endl;
	cout << "Shared file size: " << GetSharedFileSize() << endl;
	cout << "Stages:" << endl;

	StageList & list = GetStages();

	StageList::iterator it = list.begin();
	for (it = list.begin(); it != list.end(); ++it)
	{
		std::string name = (*it).mStageName;
		cout << ' ' << name.c_str() << endl;
	}
}

BOOL PipelineController::LogPerformance()
{
	cout << "Requesting pipeline performance logging: " << endl;
	StageList & list = GetStages();

	StageList::iterator it = list.begin();
	for (it = list.begin(); it != list.end(); ++it)
	{
		std::string name = (*it).mStageName;
		cout << ' ' << name.c_str() << endl;

		std::wstring queueName;

		ASCIIToWide(queueName, name);

		queueName += L"Queue";

		MakeUnique(queueName);

		MessageQueue msgq;
		if (!msgq.Init(queueName.c_str(), UsePrivateQueues())
				|| !msgq.Open(MQ_SEND_ACCESS, MQ_DENY_NONE))
		{
			SetError(msgq.GetLastError());
			return FALSE;
		}

		QueueMessage sendme;

		sendme.ClearProperties();
		sendme.SetExpressDelivery(TRUE);

		PipelineSysCommand command;
		command.mCommand = PipelineSysCommand::LOG_PERF_DATA;

		sendme.SetBody((UCHAR *) &command, sizeof(command));

		sendme.SetAppSpecificLong(PIPELINE_SYSTEM_COMMAND);
		sendme.SetPriority(PIPELINE_SYSTEM_PRIORITY);

		if (!msgq.Send(sendme))
		{
			SetError(msgq.GetLastError());
			return FALSE;
		}
	}
	return TRUE;
}


BOOL PipelineController::Signal(const char * apEventName)
{
	cout << "Signalling event " << apEventName << "... " << endl;

	ObservedEvent event;
	if (!event.Init(apEventName)
			|| !event.Signal())
	{
		string buffer;
		StringFromError(buffer, "Unable to initialize event", event.GetLastError());
		cout << buffer.c_str() << endl;
		return FALSE;
	}

	cout << "Event signalled." << endl;
	return TRUE;
}


BOOL PipelineController::Stop()
{
	const char * functionName = "PipelineController::Stop";

	if (!mRunningStages.StopPipelineService()
		|| !mRunningStages.StopAllStages())
	{
		SetError(mRunningStages.GetLastError());		
		return FALSE;
	}

	BOOL retval = WaitForShutdown(TRUE);
    // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
    // JAB: ESR-3208 (Let the users know about the CMDSTAGE/PIPESVC crash/shutdown completion **/
    if(FATAL == mStopMode) 
        mLogger.LogThis(LOG_FATAL, "Pipeline emergency shutdown process complete.");

	if (retval)
		// NOTE: hooks only executed if shutdown succeeds
		retval = ExecuteShutdownHooks();

	return retval;
}



#if 0
int PipelineController::Pause()
{
	const char * functionName = "PipelineController::Pause";

	cout << "Pausing all pipeline stages: " << endl;
	StageList & list = GetStages();

	StageListIterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		// TODO: inefficient
		StageIDAndName info = it.key();

		StageProcess * process = NULL;

		std::string name = info.mStageName;
		cout << ' ' << name << endl;

		if (!mStageMap.findValue(info.mStageID, process))
		{
			cout << "Stage " << name << " has already quit." << endl;
		}
		else
		{
			std::wstring queueName;
			ASCIIToWide(queueName, name, name.length());
			queueName += L"Queue";
			MakeUnique(queueName);

			try
			{
				process->SetState(PipelineStageStatus::PIPELINE_STAGE_QUITTING);

				MSMsgQ msgq(queueName, FALSE);
				msgq.Open(MQ_SEND_ACCESS, MQ_DENY_NONE);

				MsgQMessage sendme;

				sendme.ClearProperties();
				sendme.SetExpressDelivery(TRUE);

				PipelineSysCommand command;
				command.mCommand = PipelineSysCommand::EXIT;

				sendme.SetBody((UCHAR *) &command, sizeof(command));

				sendme.SetAppSpecificLong(PIPELINE_SYSTEM_COMMAND);
				sendme.SetPriority(PIPELINE_SYSTEM_PRIORITY);

				msgq.Send(sendme);
			}
			catch (HRESULT hr)
			{
				cout << "Unable to send message to " << name << ": " << hex << hr << dec << endl;
				return FALSE;
			}
		}
	}

#if 0
	// wait for the messages to come back that the stages are ready
	int readyStages = 0;
	while (readyStages != mStageProcesses.size())
	{
		// first we peek at the message so we know what type to receive
		MsgQMessage message;

		// get the app specific part
		message.SetAppSpecificLong(0);

		// peek at the message
		mListenQueue.Peek(message);

		PipelineMessageID messageType = (PipelineMessageID) message.GetAppSpecificLong();

		if (messageType != PIPELINE_STAGE_STATUS)
		{
			// TODO: be more forgiving with other messages
			SetError(PIPE_ERR_ROUTING_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}

		PipelineStageStatus status;

		message.SetBody((UCHAR *) &status, sizeof(status));
		mListenQueue.Receive(message);

		// TODO: better ID to stage lookup
		//ASSERT(status.mStageID < mStageProcesses.size());
		StageProcess * process = mStageMap[status.mStageID];
		ASSERT(process);


		//StageProcess * process = mStageProcesses[status.mStageID];
		if (process->GetState() != PipelineStageStatus::PIPELINE_STAGE_QUITTING)
		{
			cout << "received bad quit message" << endl;
		}
		else
		{
			cout << "Stage " << process->GetStageName() << " quitting." << endl;
			process->SetState(PipelineStageStatus::PIPELINE_STAGE_READY);
			readyStages++;
		}
	}

	cout << "All stages have quit." << endl;
#endif

	return TRUE;
}
#endif



// TODO: very temporary patch.  dump the assert text to stderr, then
// signal the C runtime library to invoke a breakpoint exception.
int DirectReportHook(int reportType, char *userMessage, int *retVal)
{
	if (reportType == _CRT_ASSERT)
	{
		cerr << userMessage;

		*retVal = 1;								// this means do an int 3 (breakpoint)

		return TRUE;								// this mean don't call the normal handling
	}
	else
	{
		*retVal = 0;								// don't break
		return FALSE;
	}
}



BOOL PipelineController::Init()
{
	const char * functionName = "PipelineController::Init";

	// override the normal assert handling so we don't do a popup.
	_CrtSetReportHook(DirectReportHook);

	// Read the stage definition.
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	PipelineInfoReader reader;
	ASSERT(mConfigDir.length() != 0);
	if (!reader.ReadConfiguration(config, mConfigDir.c_str(), *this))
	{
		SetError(reader.GetLastError());
		return FALSE;
	}

	mRunningStages.SetLogger(mLogger);

	return TRUE;
}

BOOL PipelineController::InitControlQueue()
{
	const char * functionName = "PipelineController::InitControlQueue";

	std::wstring queueName(PIPELINE_CONTROL_QUEUE);
	MakeUnique(queueName);

	// initialize the queue we listen on
	if (!mListenQueue.Init(queueName.c_str(), UsePrivateQueues())
			|| !mListenQueue.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE))
	{
		SetError(mListenQueue.GetLastError());
		mpLastError->GetProgrammerDetail() = "Unable to initialize control queue";
		return FALSE;
	}

	return TRUE;
}

BOOL PipelineController::FlushControlQueue()
{
	while (TRUE)
	{
		QueueMessage receiveme;

		// get the app specific part
		receiveme.SetAppSpecificLong(0);

		// peek at the message, but don't wait for one to arrive
		if (!mListenQueue.Peek(receiveme, 0))
			// TODO: could be an error
			break;										// no more messages

		const ULONG * type = receiveme.GetAppSpecificLong();
		ASSERT(type);
		PipelineMessageID messageType = (PipelineMessageID) *type;

		if (messageType == PIPELINE_STAGE_STATUS)
		{

			PipelineStageStatus status;

			receiveme.SetBody((UCHAR *) &status, sizeof(status));
			mListenQueue.Receive(receiveme);

			const char * statusString = NULL;
			switch (status.mStatus)
			{
			case PipelineStageStatus::PIPELINE_STAGE_STARTING:
				statusString = "PIPELINE_STAGE_STARTING";
				break;
			case PipelineStageStatus::PIPELINE_STAGE_READY:
				statusString = "PIPELINE_STAGE_READY";
				break;
			case PipelineStageStatus::PIPELINE_STAGE_PAUSED:
				statusString = "PIPELINE_STAGE_PAUSED";
				break;
			case PipelineStageStatus::PIPELINE_STAGE_QUITTING:
				statusString = "PIPELINE_STAGE_QUITTING";
				break;
			case PipelineStageStatus::PIPELINE_STAGE_QUIT:
				statusString = "PIPELINE_STAGE_QUIT";
				break;
			default:
				statusString = "Unknown Status!";
				break;
			}

			mLogger.LogVarArgs(LOG_INFO, "Flushed stage status: stage %d has status %s",
												 status.mStageID, statusString);
		}
		else
			// if we don't understand the message type, leave it in the queue
			break;
	}
	return TRUE;
}



BOOL PipelineController::HandlerRoutine(DWORD aCtrlType)
{
	BOOL stopService = FALSE;
	switch (aCtrlType)
	{
	case CTRL_C_EVENT:
		// A CTRL+C signal was received, either from keyboard input or
		// from a signal generated by the GenerateConsoleCtrlEvent function. 
		cout << "Control C pressed" << endl;
		stopService = TRUE;
		break;
 
	case CTRL_BREAK_EVENT:
		// A CTRL+BREAK signal was received, either from keyboard input or from a
		// signal generated by GenerateConsoleCtrlEvent. 
		cout << "Control break pressed" << endl;
		stopService = TRUE;
		break;
 
	case CTRL_CLOSE_EVENT:
		// A signal that the system sends to all processes attached to a console when
		// the user closes the console (either by choosing the Close command from the
		// console windows System menu, or by choosing the End Task command
		// from the Task List).
		cout << "Close event" << endl;
		stopService = TRUE;
		break;
 
	case CTRL_LOGOFF_EVENT:
		// A signal that the system sends to all console processes when a user
		// is logging off. This signal does not indicate which user is logging off,
		// so no assumptions can be made. 
		cout << "Logoff event" << endl;
		// don't stop the service when a user logs out
		stopService = FALSE;
		break;
 
	case CTRL_SHUTDOWN_EVENT:
		// A signal that the system sends to all console processes when the system
		// is shutting down. 
		cout << "Shutdown event" << endl;
		stopService = TRUE;
		break;
	}

	if (stopService)
	{
		// no matter what the event was, stop the pipeline
		PipelineController * controller = GetController();
		if (!controller->Stop())
		{
			ASSERT(0);
			// what should we do if the service can't stop?
		}
	}

	// we've handled the stop - the process should be exiting soon
	return TRUE;
}


void PipelineController::ServiceStartHelper(DWORD argc, char * *argv)
{
	PipelineController * controller = PipelineController::GetController();
	controller->ServiceStart(argc, argv);
}

void PipelineController::ServiceStart(DWORD argc, char * *argv)
{
	const char * functionName = "PipelineController::ServiceStart";

	//call the SetServiceStatus function, specifying the SERVICE_START_PENDING 

	// initialize...

	// call SetServiceStatus, specifying the SERVICE_RUNNING state in the
	// SERVICE_STATUS structure

	// if error,
	// SetServiceStatus, specifying the SERVICE_STOP_PENDING state in the SERVICE_STATUS
	// structure, if cleanup will be lengthy. Once cleanup is complete, call
	// SetServiceStatus from the last thread to terminate, specifying SERVICE_STOPPED
	// in the SERVICE_STATUS structure. Be sure to set the dwServiceSpecificExitCode
	// and dwWin32ExitCode members of the SERVICE_STATUS structure to identify the error. 
    // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
    mStopMode = NORMAL;
	mServiceStatus.dwServiceType = SERVICE_WIN32;
	mServiceStatus.dwCurrentState = SERVICE_START_PENDING;
	mServiceStatus.dwControlsAccepted =
		SERVICE_ACCEPT_STOP | SERVICE_ACCEPT_PAUSE_CONTINUE;
	mServiceStatus.dwWin32ExitCode = 0;
	mServiceStatus.dwServiceSpecificExitCode = 0;
	mServiceStatus.dwCheckPoint = 0;
	mServiceStatus.dwWaitHint = CHECKPOINT_DURATION + 20 * 1000;

	// Initialization code goes here.
	if (!GetMTConfigDir(mConfigDir))
	{
		mLogger.LogThis(LOG_ERROR, "Unable to read configuration directory");
		return;
	}

 	mServiceStatusHandle = RegisterServiceCtrlHandler("Pipeline",	ServiceCtrlHandlerHelper);
	if (mServiceStatusHandle == (SERVICE_STATUS_HANDLE)0)
		{
		mLogger.LogVarArgs(LOG_FATAL, "RegisterServiceCtrlHandler failed %d\n", ::GetLastError());
		return;
	}

  mLogger.LogVarArgs(LOG_DEBUG, "Service status handle: %x", mServiceStatusHandle);

	if (!Init())
	{
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		mServiceStatus.dwCurrentState = SERVICE_STOPPED;
		mServiceStatus.dwCheckPoint = 0;
		mServiceStatus.dwWaitHint = 0;
		mServiceStatus.dwWin32ExitCode = GetLastError()->GetCode();
		// if dwWin32ExitCode is ERROR_SERVICE_SPECIFIC_ERROR
		// then this next value has meaning
		mServiceStatus.dwServiceSpecificExitCode = 0;
		if (!::SetServiceStatus(mServiceStatusHandle, &mServiceStatus))
		{
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
							 "Unable to set service status");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		}

		return;
	}

	// allow the handler to clean up when the process quits
	// TODO: is this cast safe?
	::SetConsoleCtrlHandler((PHANDLER_ROUTINE) HandlerRoutine, TRUE);

	mLogger.LogEvent(NTEventMsg::EVENT_INFO, "Pipeline starting");

	mLogger.LogThis(LOG_INFO, "");
	mLogger.LogThis(LOG_INFO, "");
	mLogger.LogThis(LOG_INFO, "");
	mLogger.LogThis(LOG_INFO, "");
	mLogger.LogThis(LOG_INFO, "##########################################################");
	mLogger.LogThis(LOG_INFO, "############### MetraTech Pipeline Service ###############");
	mLogger.LogThis(LOG_INFO, "##########################################################");
	mLogger.LogThis(LOG_INFO, "");
	mLogger.LogThis(LOG_INFO, "");
	mLogger.LogThis(LOG_INFO, "");
	mLogger.LogThis(LOG_INFO, "");


	mLogger.LogThis(LOG_DEBUG, "Initializing.");

	mLogger.LogThis(LOG_DEBUG, "Starting all");

#ifdef _DEBUG
	if (!StartupAll(TRUE))
#else // _DEBUG
	if (!StartupAll(FALSE))
#endif // _DEBUG
	{
		mServiceStatus.dwCurrentState = SERVICE_STOPPED;
		mServiceStatus.dwCheckPoint = 0;
		mServiceStatus.dwWaitHint = 0;
		mServiceStatus.dwWin32ExitCode = ERROR_SERVICE_SPECIFIC_ERROR;
		// if dwWin32ExitCode is ERROR_SERVICE_SPECIFIC_ERROR
		// then this next value has meaning
		mServiceStatus.dwServiceSpecificExitCode = GetLastError()->GetCode();

		if (!::SetServiceStatus(mServiceStatusHandle, &mServiceStatus))
		{
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
							 "Unable to set service status");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		}
		return;
	}

	mLogger.LogThis(LOG_DEBUG, "Pipeline started");

	// Initialization complete - report running status.
	mServiceStatus.dwCurrentState = SERVICE_RUNNING;
	mServiceStatus.dwCheckPoint = 0;
	mServiceStatus.dwWaitHint = 0;
	if (!::SetServiceStatus(mServiceStatusHandle, &mServiceStatus))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to set service status");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
	}

	// This is where the service does its work. 
	mLogger.LogThis(LOG_DEBUG, "Waiting for processes to exit");

	// hopefully this will never return - then the service is running permanently
	WaitForShutdown(FALSE);

	mLogger.LogThis(LOG_DEBUG, "Service exiting main thread");

	// service is now stopped
	mServiceStatus.dwCurrentState = SERVICE_STOPPED;
	mServiceStatus.dwCheckPoint = 0;
	mServiceStatus.dwWaitHint = 0;
	mServiceStatus.dwWin32ExitCode = 0;
	// if dwWin32ExitCode is ERROR_SERVICE_SPECIFIC_ERROR
	// then this next value has meaning
	mServiceStatus.dwServiceSpecificExitCode = 0;

	if (!::SetServiceStatus(mServiceStatusHandle, &mServiceStatus))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to set service status");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
	}



	mLogger.LogEvent(NTEventMsg::EVENT_INFO, "Pipeline exiting");
}

void WINAPI PipelineController::ServiceCtrlHandlerHelper(DWORD aOpcode)
{
	PipelineController * controller = PipelineController::GetController();
	controller->ServiceCtrlHandler(aOpcode);
}


void PipelineController::ServiceCtrlHandler(DWORD aOpcode)
{ 
	const char * functionName = "PipelineController::ServiceCtrlHandler";

	switch (aOpcode)
	{
	case SERVICE_CONTROL_PAUSE:
		// Do whatever it takes to pause here.
		ASSERT(0);
		mServiceStatus.dwCurrentState = SERVICE_PAUSED;
		break;

	case SERVICE_CONTROL_CONTINUE:
		// Do whatever it takes to continue here.
		ASSERT(0);
		mServiceStatus.dwCurrentState = SERVICE_RUNNING;
		break;

	case SERVICE_CONTROL_STOP:
		mServiceStatus.dwWin32ExitCode = 0;
		mServiceStatus.dwCurrentState = SERVICE_STOP_PENDING;
		mServiceStatus.dwCheckPoint = 0;
		mServiceStatus.dwWaitHint = CHECKPOINT_DURATION + 3 * 1000;

		if (!::SetServiceStatus(mServiceStatusHandle, &mServiceStatus))
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Service status handle: %x", mServiceStatusHandle);
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
							 "Unable to set service status");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		}

		// NOTE: we need to start a thread to run the shutdown process.
		// we have to return from this method quickly or the SCM will complain
		mStopperThread.SetController(this);
		mStopperThread.StartThread();

		// return immediately
		return;

	case SERVICE_CONTROL_INTERROGATE:
		// Fall through to send current status.
		break;

	default:
		mLogger.LogVarArgs(LOG_ERROR, "Unrecognized opcode %ld", aOpcode);
		//SvcDebugOut(" [MY_SERVICE] Unrecognized opcode %ld\n",
		//Opcode);
	}

	// Send current status.
	if (!::SetServiceStatus(mServiceStatusHandle,  &mServiceStatus))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to set service status");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
	}
}
// ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
/** Hard/Fast shutdown ends in a crash to allow use of 
 ** SCM auto restart policies. This will also end up in an
 ** event in the system event logs which can be useful.
 ** This should be the preferred method.
 **/
void PipelineController::EmergencyStopHardFast()
{
	const char * functionName = "PipelineController::EmergencyStopHardFast";

	if (!mRunningStages.StopPipelineService()
		|| !mRunningStages.StopAllStages())
	{
        SetError(mRunningStages.GetLastError());
	}
    mLogger.LogThis(LOG_FATAL, "Pipeline emergency shutdown process complete; hard crashing process now.");
	exit(-1);
}

/** Graceful shutdown simply uses the SCM to stop the service
 ** however this method will not allow SCM auto restart 
 ** to function. However this is much more graceful a shutdown
 ** sequence if an external HA monitor is being used
 **/
void PipelineController::EmergencyStopGraceful()
{
	const char * functionName = "PipelineController::EmergencyStopGraceful";
    SC_HANDLE schSCManager = ::OpenSCManager(NULL, // local machine 
                                             NULL, // ServicesActive database 
                                             SC_MANAGER_ALL_ACCESS); // full access rights

    if (schSCManager == NULL)
    {
        DWORD err = ::GetLastError();
        SetError(err, ERROR_MODULE, ERROR_LINE, functionName, "Unable to open SC manager");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
        return;
    }

    SC_HANDLE svcHandle = ::OpenService(schSCManager,  // handle to service control manager database 
                                        "pipeline",    // pointer to name of service
                                        SERVICE_STOP | // type of access to service 
                                        SERVICE_QUERY_STATUS | 
                                        SERVICE_ENUMERATE_DEPENDENTS); 

    if (svcHandle == NULL)
    {
        DWORD err = ::GetLastError();
        SetError(err, ERROR_MODULE, ERROR_LINE, functionName, "Unable to open service");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
        ::CloseServiceHandle(schSCManager);
        return;
    }

    SERVICE_STATUS_PROCESS ssp;
    if(!::ControlService(svcHandle, SERVICE_CONTROL_STOP,(LPSERVICE_STATUS) &ssp))
    {
        DWORD err = ::GetLastError();
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
        SetError(err, ERROR_MODULE, ERROR_LINE, functionName, "Unable to send close to pipeline manager");
    }
    ::CloseServiceHandle(svcHandle);
    ::CloseServiceHandle(schSCManager);
}

/** JAB (ESR-3208) Detect catastrophic failures 
 ** with CMDSTAGE or PIPESVC then 
 ** shutdown, and allow ourselves
 ** to clean up and get restarted
 **/
void PipelineController::EmergencyStop(void)
{
	const char * functionName = "PipelineController::EmergencyStop";
    mStopMode = FATAL;
    
    mLogger.LogThis(LOG_INFO, "Pipeline emergency shutdown in progress...");
    // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
    if(UseEmergencyCrashPolicy()) EmergencyStopHardFast();
    else EmergencyStopGraceful();
}

void PipelineController::NTService()
{
	mRunningAsService = TRUE;

	SERVICE_TABLE_ENTRY DispatchTable[] =
	{ 
		{ "Pipeline",				ServiceStartHelper			}, 
		{ NULL,							NULL										},
	};  

	if (!::StartServiceCtrlDispatcher(DispatchTable))
		mLogger.LogThis(LOG_FATAL, "Unable to start MetraTech Pipeline service");
}

BOOL PipelineController::RegisterNTService(const char * apServiceName,
																					 const char * apDesc)
{
	const char * functionName = "PipelineController::RegisterNTService";

	// by default, call it pipeline
	if (apServiceName == NULL)
		apServiceName = "Pipeline";

	// default description
	if (apDesc == NULL)
		apDesc = "MetraTech Pipeline";

	char buffer[MAX_PATH];
	if (::GetModuleFileName(NULL, // handle to module to find filename for 
													buffer, sizeof(buffer)) == 0)
	{
		DWORD err = ::GetLastError();
		SetError(err, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to get module file name");
		return FALSE;
	}

	SC_HANDLE schSCManager =
		::OpenSCManager(NULL, // local machine 
										NULL,				// ServicesActive database 
										SC_MANAGER_ALL_ACCESS);	// full access rights

  if (schSCManager == NULL)
	{
		DWORD err = ::GetLastError();
		SetError(err, ERROR_MODULE, ERROR_LINE, functionName, "Unable to open SC manager");
		return FALSE;
	}

	SC_HANDLE schService =
		::CreateService(
			schSCManager,							// SCManager database
			apServiceName,						// name of service
			apDesc,										// service name to display
			SERVICE_ALL_ACCESS,				// desired access
			SERVICE_WIN32_OWN_PROCESS, // service type
			SERVICE_DEMAND_START,			// start type
			SERVICE_ERROR_NORMAL,			// error control type
			buffer,										// service's binary
			NULL,											// no load ordering group
			NULL,											// no tag identifier
			NULL,											// no dependencies
			NULL,											// LocalSystem account
			NULL);										// no password

	if (schService == NULL)
	{
		DWORD err = ::GetLastError();
// ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
		SetError(err, ERROR_MODULE, ERROR_LINE, functionName, "Unable to create service");
	    ::CloseServiceHandle(schSCManager);
		return FALSE;
	}

	::CloseServiceHandle(schService);
// ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
    ::CloseServiceHandle(schSCManager);
	return TRUE;
} 

BOOL PipelineController::UnregisterNTService(const char * apServiceName)
{
	const char * functionName = "PipelineController::UnregisterNTService";

	// by default, call it pipeline
	if (apServiceName == NULL)
		apServiceName = "Pipeline";


	SC_HANDLE schSCManager =
		::OpenSCManager(NULL, // local machine 
										NULL,				// ServicesActive database 
										SC_MANAGER_ALL_ACCESS);	// full access rights

  if (schSCManager == NULL)
	{
		DWORD err = ::GetLastError();
		SetError(err, ERROR_MODULE, ERROR_LINE, functionName, "Unable to open SC manager");
		return FALSE;
	}


	SC_HANDLE svcHandle =
		::OpenService(schSCManager,	// handle to service control manager database 
									apServiceName, // pointer to name of service
									DELETE);			// type of access to service 


	if (svcHandle == NULL)
	{
		DWORD err = ::GetLastError();
		SetError(err, ERROR_MODULE, ERROR_LINE, functionName, "Unable to open service");
                // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
		::CloseServiceHandle(schSCManager);
		return FALSE;
	}

	if (!::DeleteService(svcHandle))
	{
		DWORD err = ::GetLastError();
		SetError(err, ERROR_MODULE, ERROR_LINE, functionName, "Unable to open service");
        // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
        ::CloseServiceHandle(svcHandle);
	    ::CloseServiceHandle(schSCManager);
		return FALSE;
	}

	::CloseServiceHandle(svcHandle);

	::CloseServiceHandle(schSCManager);

	return TRUE;
} 


BOOL PipelineController::Pipeline(int argc, char * argv[])
{
	//
	// interpret actions
	//
	int nonFlags = 0;
	for (int i = 1; i < argc; i++)
	{
		if (*argv[i] == '-')
		{
			nonFlags = i;
			break;
		}
	}
	if (nonFlags == 0)
		nonFlags = argc;

	const char * verb;
	if (nonFlags > 1)
		verb = argv[1];
	else
		verb = NULL;

	const char * arg;
	if (nonFlags > 2)
		arg = argv[2];
	else
		arg = NULL;

	const char * arg2;
	if (nonFlags > 3)
		arg2 = argv[3];
	else
		arg2 = NULL;

	//
	// interpret flags
	//
	const char * login = NULL;
	const char * password = NULL;
	const char * domain = NULL;
	mUseWindows = TRUE;
	for (i = nonFlags; i < argc; i++)
	{
		const char * arg = argv[i];

		if (0 == strcmp("-login", arg))
		{
			i++;
			if (i >= argc)
				return FALSE;
			login = argv[i];
		}
		else if (0 == strcmp("-password", arg))
		{
			i++;
			if (i >= argc)
				return FALSE;
			password = argv[i];
		}
		else if (0 == strcmp("-domain", arg))
		{
			i++;
			if (i >= argc)
				return FALSE;
			domain = argv[i];
		}
		else if (0 == strcmp("-nw", arg))
			mUseWindows = FALSE;
	}

  // Initialize logger.
 	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), PIPELINE_TAG);

	// TODO: multi instance is not currently supported and needs to be re-enabled.
#if 0
	//
	// setup for multi instance use
	//
	MultiInstanceSetup multiSetup;
	if (!multiSetup.SetupMultiInstance(login, password, domain))
	{
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		PrintError("Multi-instance setup failed", multiSetup.GetLastError());
		return -1;
	}


	// store login info for use later, creating processes
	mLogin = login ? login : "";
	mPassword = password ? password : "";

	if (!domain)
	{
		std::wstring defaultDomainNameWide;
		// TODO: this call doesn't work when running as a service
		if (!GetNTDomainName(defaultDomainNameWide))
		{
			cout << "Unable to read default NT domain name: 0x"
					 << hex << ::GetLastError() << dec << endl;
			return FALSE;
		}

		mDomain = defaultDomainNameWide.toAscii();
	}
	else
		mDomain = domain;
#endif


	const char * config;
#if 0
	if (argc > 1)
		config = argv[1];
	else
		config = NULL;
#endif

	std::string configDir;
	if (!GetMTConfigDir(configDir))
  {
    mLogger.LogThis(LOG_ERROR, "Unable to read configuration directory");
		return FALSE;
  }
	config = configDir.c_str();


	if (!verb)
	{
		NTService();
		return 0;
	}

	// we're not running as a service
	mRunningAsService = FALSE;

	if (0 == strcmp(verb, "create-service"))
	{
		if (!RegisterNTService(arg, arg2))
		{
      mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			PrintError("Unable to register service", GetLastError());
			return FALSE;
		}
		cout << "Service registered." << endl;
		return TRUE;
	}
	else if (0 == strcmp(verb, "delete-service"))
	{
		if (!UnregisterNTService(arg))
		{
      mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			PrintError("Unable to register service", GetLastError());
			return FALSE;
		}
		cout << "Service unregistered." << endl;
		return TRUE;
	}

	if (config == NULL)
	{
		cout << "Configuration directory and command required" << endl;
		return FALSE;
	}
	mConfigDir = config;

	if (!Init())
	{
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		PrintError("Unable to initialize pipeline stage", GetLastError());
		return FALSE;
	}

	// allow the handler to clean up when the process quits
	// TODO: is this cast safe?
	::SetConsoleCtrlHandler((PHANDLER_ROUTINE) HandlerRoutine, TRUE);


	if (0 == strcmp(verb, "create-queue"))
	{
		if (arg)
			return CreateQueue(arg);
		else
			return CreateQueues();
	}
	if(0 == strcmp(verb,"delete-queue")) {
		if(arg) {
			return DeleteQueue(arg);
		}
		else {
			return DeleteQueues();
		}
	}
	else if (0 == strcmp(verb, "info"))
	{
		DumpInfo();
		return 0;
	}
	else if (0 == strcmp(verb, "start"))
	{
		if (!StartupAll(FALSE))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to start pipeline");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			PrintError("Unable to start pipeline.  See log file for more information.", GetLastError());
			return FALSE;
		}
		(void) WaitForShutdown(FALSE);
		return TRUE;
	}
	else if (0 == strcmp(verb, "debug-start"))
	{
		if (!StartupAll(TRUE))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to start pipeline");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			PrintError("Unable to start pipeline.  See log file for more information.", GetLastError());
			return FALSE;
		}
		WaitForShutdown(FALSE);
		return TRUE;
	}
	else if (0 == strcmp(verb, "performance"))
	{
		return LogPerformance();
	}
	else if (0 == strcmp(verb, "signal"))
	{
		if (!arg)
		{
			cout << "Signal command requires an event name to signal" << endl;
			return FALSE;
		}
		return Signal(arg);
	}
	else if (0 == strcmp(verb, "stop"))
	{
		if (!arg)
		{
			cout << "Stop command requires \"pipesvc\" or a stage name to stop" << endl;
			return FALSE;
		}
		if (0 == strcmp(arg, "pipesvc"))
		{
			PipelineStopEvent stopEvent;
			if (!stopEvent.Init()
					|| !stopEvent.Signal())
			{
				SetError(stopEvent);
				return FALSE;
			}
			return TRUE;
		}
	}

	return 0;
}


int main(int argc, char * argv[])
{
	try
	{
		PipelineController controller;

		if (!controller.Pipeline(argc, argv))
			return -1;
		else
			return 0;
	}
	catch (_com_error & err)
	{
		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "  Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "  Source: " << (const char *) src << endl;
	}

	return 0;
}
