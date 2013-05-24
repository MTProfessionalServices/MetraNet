/**************************************************************************
 * @doc PIPELINE
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
 *  $Date$
 *  $Author$
 *  $Revision$
 *
 * @index | PIPELINE
 ***************************************************************************/

#ifndef _PIPELINE_H
#define _PIPELINE_H

#include <errobj.h>

#include <pipelineconfig.h>
#include <NTLogger.h>
#include <NTThreader.h>
#include <NTThreadLock.h>
#include <msmqlib.h>
#include <pipemessages.h>
#include <StageReference.h>

#include <map>

// argument to pass to hooks when starting or stopping the pipeline
enum HookState
{
	HOOK_PIPELINE_STARTUP = 1,
	HOOK_PIPELINE_SHUTDOWN = 2,
};


class PipelineProcess : public virtual ObjectWithError
{
public:
	virtual ~PipelineProcess();

	const PROCESS_INFORMATION & GetProcessInfo() const
	{ return mProcessInfo; }

	HANDLE GetProcessHandle() const
	{ return mProcessInfo.hProcess; }

	DWORD GetProcessID() const
	{ return mProcessInfo.dwProcessId; }

	BOOL StartProcess(const char * apEXE,
										const char * apCommandLine,
										const char * apLogin,
										const char * apPassword,
										const char * apDomain,
										BOOL aStartConsoles,
										const char * apConsoleTitle);

	BOOL GetExePath(std::string & arExePath, const char * apExeName);

	PipelineStageStatus::StageStatus GetState() const
	{ return mState; }

	void SetState(PipelineStageStatus::StageStatus aState)
	{ mState = aState; }

private:
	PROCESS_INFORMATION mProcessInfo;

protected:
	PipelineStageStatus::StageStatus mState;
};

class StageProcess : public PipelineProcess
{
public:
	StageProcess(const char * apName, BOOL aPrivateQueue);
	virtual ~StageProcess();

	BOOL CreateStageProcess(const char * apConfigDir,
													const char * apLogin, const char * apPassword,
													const char * apDomain,
													BOOL aStartConsoles);

	BOOL CreateHarnessProcess(BOOL aSleep,
														const char * apLogin, const char * apPassword,
														const char * apDomain,
														BOOL aStartConsoles);

	//BOOL Restart();


	const std::string & GetStageEXE() const
	{ return mStageEXE; }


	const char * GetName() const
	{ return mName.c_str(); }


	bool operator == (const StageProcess & arStage);

private:
	BOOL StartStageInternal(const char * apLogin,
													const char * apPassword,
													const char * apDomain,
													BOOL aStartConsoles);

	BOOL CreateCommandLine(const char * apConfigDir,
												 const char * apLogin,
												 const char * apPassword,
												 const char * apDomain);

	static const char * mpEXE;


	std::string mCommandLine;
	std::string mStageEXE;
	std::string mName;
	int mStageID;

	PipelineStageStatus::StageStatus mState;
	int mRetries;

	// if true, use a private queue when sending a message
	BOOL mUsePrivateQueues;

	enum
	{
		MAX_RETRIES = 5,
	};
};


class PipelineServiceProcess : public PipelineProcess
{
public:
	PipelineServiceProcess();

	BOOL Start(const char * apLogin,
						 const char * apPassword,
						 const char * apDomain,
						 BOOL aStartConsoles);

	BOOL Stop();

	BOOL IsExiting() const
	{ return mState == PipelineStageStatus::PIPELINE_STAGE_QUITTING; }

	BOOL IsStarted() const
	{ return mState == PipelineStageStatus::PIPELINE_STAGE_READY; }
};




class RunningStages : public virtual ObjectWithError
{
public:
	RunningStages();
	~RunningStages();

	int GetStartingStages();
	int GetQuitProcesses();

	BOOL StageStarted(int aStageID, int &startCount);

	void AddStageProcess(StageProcess * process);
	void AddStageReference(int aStageID, const char * apStageName,
												 BOOL aPrivateQueues);


	BOOL MonitorExits(HANDLE aStopEventHandle);

	void SetLogger(NTLogger & arLogger)
	{ mLogger = arLogger; }

	BOOL StopAllStages();

	void LogUnstartedStages();


	BOOL StartPipelineService(const char * apLogin,
														const char * apPassword,
														const char * apDomain,
														BOOL aStartConsoles);

	BOOL StopPipelineService();

	BOOL PipelineServiceRunning();

	PipelineStageStatus::StageStatus GetPipelineServiceState();
	void SetPipelineServiceState(PipelineStageStatus::StageStatus aState);

private:
	BOOL CalculateWaitHandles(HANDLE aStopEvent, const HANDLE * & arpHandles,
														int & arHandleCount);

	BOOL ProcessExitedWithIndex(int aIndex, BOOL aWaitForPipeSvc, BOOL & arExpected);

	// pipesvc stopped
	void PipelineServiceExited();

	static unsigned KeyHashFun(const int & arKey)
	{ return arKey ^ 0xA5A5A5; }

private:
	typedef std::map<int, StageReference> StageReferences;

	typedef vector<StageProcess *> StageProcessVector;

	typedef vector<HANDLE> HANDLEVector;

	// pipeline service process
	PipelineServiceProcess mPipeSvc;
	BOOL mPipeSvcStarted;

	StageProcessVector mStageProcesses;

	StageReferences mStageReferences;

	// NOTE: mProcessHandles and mLiveProcesses are kept in sync
	// mProcessHandles[0] = stop event handle
	// mProcessHandles[1] = pipesvc
	// mProcessHandles[i+2] = mLiveProcesses[i]
	enum
	{
		PIPESVC_EVENT_OFFSET = 0,
		STOP_EVENT_OFFSET,
		STAGE_PROCESS_OFFSET,
	};
	HANDLEVector mProcessHandles;
	StageProcessVector mLiveProcesses;

	NTLogger mLogger;

	NTThreadLock mLock;
};


// a thread used to stop the pipeline.
// because we need to return from the service control handler
// immediately, Microsoft recommends a thread to control the shutdown process
class PipelineController;
class PipelineStopThread : public NTThreader
{
public:
	int ThreadMain();

	void SetController(PipelineController * apController)
	{ mpController = apController; }

private:
	PipelineController * mpController;
};


class PipelineController :
	public PipelineInfo,
	public NTThreader,
	public virtual ObjectWithError
{
public:
	PipelineController();
	virtual ~PipelineController();

	BOOL DeleteShare();
	BOOL FlushQueue(const char * apQueueName);
	BOOL FlushQueues();
	BOOL CreateQueue(const char * apStageName);
	BOOL DeleteQueue(const char* apStageName);
	BOOL CreateQueues();
	BOOL DeleteQueues();

	BOOL StartupStage(const char * stageName, BOOL aDebug);
	BOOL StartupExtension(const char * apName, BOOL aDebug);
	BOOL StartupAllAsProcess(BOOL aDebug);

	BOOL StartupAll(BOOL aDebug);

	void DumpInfo();

	BOOL RefreshConfig();
	BOOL Stop();
	BOOL Pause();
	BOOL Pipeline(int argc, char * argv[]);

	static PipelineController * GetController()
	{ return mpControllerInstance; }

	void NTService();

	BOOL RegisterNTService(const char * apServiceName, const char * apDesc);
	BOOL UnregisterNTService(const char * apServiceName);

	BOOL LogPerformance();
	BOOL Signal(const char * apEventName);
    // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
    /** Crash control Interfaces **/
    void EmergencyStop(void);
private:
    void EmergencyStopHardFast(void);
    void EmergencyStopGraceful(void);

private:
	BOOL WaitForShutdown(BOOL aReportStatus);

	BOOL ReportServiceState(DWORD aState);

	BOOL Init();

	BOOL ExecuteHooks(const char * apSection, HookState aState);
	BOOL ExecuteStartupHooks();
	BOOL ExecuteShutdownHooks();

	BOOL CreateQueueWithName(const wchar_t * apQueueName,
													 const wchar_t * apLabel,
													 BOOL aPrivate,
													 BOOL aJournalOn = FALSE);
	BOOL DeleteQueueWithName(const wchar_t* apQueueName);
	
	BOOL InitControlQueue();
	BOOL FlushControlQueue();

	static BOOL HandlerRoutine(DWORD aCtrlType);

private:
	BOOL StageExited(StageProcess * apStage);

	BOOL HandleStartMessages(DWORD aTimeout);

	virtual int ThreadMain();

	static void WINAPI ServiceStartHelper(DWORD argc, char * *argv);
	void ServiceStart(DWORD argc, char * *argv);

	static void WINAPI ServiceCtrlHandlerHelper(DWORD aOpcode);
	void ServiceCtrlHandler(DWORD aOpcode);

private:
	// if true, the process is running as a service
	BOOL mRunningAsService;

	RunningStages mRunningStages;

	std::string mConfigDir;

	std::string mLogin;
	std::string mPassword;
	std::string mDomain;

	BOOL mUseWindows;

	NTLogger mLogger;

	// queue we listen to
	MessageQueue mListenQueue;

	SERVICE_STATUS mServiceStatus;
	SERVICE_STATUS_HANDLE mServiceStatusHandle;

	static PipelineController * mpControllerInstance;

	PipelineStopThread mStopperThread;

	enum
	{
		// timeout to wait for stages to return a start message (in seconds)
		STAGE_START_TIMEOUT = 60,

		// (rough) duration between calls to the callback used during startup
		CHECKPOINT_DURATION = 5 * 1000,
	};
// ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1    
    enum STOPMODE {
        NORMAL = 0,
        FATAL,
    };
    STOPMODE mStopMode;

};


#endif /* _PIPELINE_H */
