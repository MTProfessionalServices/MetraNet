/**************************************************************************
 * @doc PIPESVC
 *
 * Copyright 2000 by MetraTech Corporation
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
#include <errutils.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTConfigLib.tlb"

#include <pipesvc.h>

#include <mtprogids.h>

#include <mtglobal_msg.h>

#include <loggerconfig.h>
#include <routeconfig.h>
#include <pipelineconfig.h>
#include <listenerconfig.h>
#include <ConfigDir.h>
#include <MTUtil.h>
#include <mtcomerr.h>
#include <ConfigDir.h>
#include <multi.h>
#include <errutils.h>
#include <makeunique.h>
#include <mtcomerr.h>

using namespace std;

ComInitialize gComInitialize;

/************************************ PipelineServicesParams ***/

PipelineServicesParams::PipelineServicesParams()
	: mStartRouter(TRUE),
		mStartAuditor(TRUE)
{ }


/********************************************* RouterService ***/

BOOL RouterService::RoutingConfigured() const
{
	return mRoutingConfigured;
}


BOOL RouterService::Init(BOOL aMainRouter,
												 const char * apConfigDir,
												 const PipelineInfo & arPipelineInfo)
{
	const char * functionName = "RouterService::Init";


	mUsePrivateQueues = arPipelineInfo.UsePrivateQueues();

	BOOL transactionalQueue;
	std::wstring machine;
	std::wstring queue;

	if (aMainRouter)
	{
		machine = arPipelineInfo.GetOneRoutingQueueMachine();
		queue = arPipelineInfo.GetOneRoutingQueueName();
		transactionalQueue = FALSE;
	}
	else
	{
		machine = arPipelineInfo.GetResubmitQueueMachine();
		queue = arPipelineInfo.GetResubmitQueueName();
		transactionalQueue = TRUE;
	}

	if (queue.empty())
	{
		mRoutingConfigured = FALSE;
		// NOTE: we return TRUE because no routing is required.
		return TRUE;
	}
	mRoutingConfigured = TRUE;

	// hold onto a name ID to speed up startup
	MTPipelineLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);

	// read pipeline.xml for use by the services
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	ListenerInfoReader listenerReader;

	ListenerInfo listenerInfo;
	if (!listenerReader.ReadConfiguration(config, apConfigDir, listenerInfo))
	{
		SetError(listenerReader);
		return FALSE;
	}

	MeterRoutes routeInfo;

	MeterRouteReader routeReader;
	if (!routeReader.ReadConfiguration(config, apConfigDir, routeInfo))
	{
		SetError(routeReader);
		return FALSE;
	}

	// initialize the session server
	MTPipelineLib::IMTSessionServerPtr sessionServer(MTPROGID_SESSION_SERVER);

	sessionServer->Init((const char *) arPipelineInfo.GetSharedSessionFile().c_str(),
											(const char *) arPipelineInfo.GetShareName().c_str(),
											arPipelineInfo.GetSharedFileSize());

	if (!SessionRouter::Init(listenerInfo, arPipelineInfo, ascii(machine).c_str(),
													 ascii(queue).c_str(), transactionalQueue,
													 routeInfo, sessionServer))
		return FALSE;

	return TRUE;
}

/******************************************** RestartService ***/

void RestartService::Init(const PipelineInfo & arInfo)
{
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[RestartService]");

	mLogger.LogThis(LOG_DEBUG, "Creating suspended transaction manager");
	mSuspendedTxnManager = MetraTech_Pipeline::ISuspendedTxnManagerPtr(__uuidof(MetraTech_Pipeline::SuspendedTxnManager));

	mLogger.LogThis(LOG_DEBUG, "Suspended transaction manager component found");

	// convert fractions of an hour into milliseconds
	int minutes = (int) (arInfo.GetSuspendRestartPeriod() * 60);

	if (minutes < 1)
	{
		mPeriodMS = 0;
		mLogger.LogVarArgs(LOG_INFO, "Not checking for suspended transactions");
	}
	else
	{
		mPeriodMS = minutes * 60 * 1000;
		mLogger.LogVarArgs(LOG_INFO, "Checking for suspended transactions every %d minutes (%d ms)",
											 minutes, mPeriodMS);
	}


}

BOOL RestartService::ServiceRequired()
{
	return mSuspendedTxnManager != NULL && mPeriodMS > 0;
}

int RestartService::ThreadMain()
{
	try
	{
		// run once at the start
		mSuspendedTxnManager->FindAndResubmit();
	}
	catch (_com_error & err)
	{
		string buffer;
		StringFromComError(buffer, "Error in suspended transaction manager", err);

		mLogger.LogThis(LOG_ERROR, buffer.c_str());
		// NOTE: continue running
	}

	while (TRUE)
	{
		try
		{
			// number of milliseconds to wait between executions of
			// the suspended transaction service.
			int waitLengthMs = mPeriodMS;
			DWORD waitResult = ::WaitForSingleObject(StopEventHandle(), waitLengthMs);
			if (waitResult == WAIT_OBJECT_0)
			{
				// thread was signaled to stop
				break;
			}

			// perform actions of the service
			mSuspendedTxnManager->FindAndResubmit();
		}
		catch (_com_error & err)
		{
			string buffer;
			StringFromComError(buffer, "Error in suspended transaction manager", err);

			mLogger.LogThis(LOG_ERROR, buffer.c_str());
			// NOTE: continue running
		}
	}

	return 0;
}

/****************************************** PipelineServices ***/

BOOL PipelineServices::Run()
{
	const char * functionName = "PipelineServices::Run";

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[PipeSvc]");

	mLogger.LogThis(LOG_INFO, "Pipeline services starting");


	// read pipeline.xml for use by the services
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Configuration directory not set in the registry.");
		return FALSE;
	}

	PipelineInfoReader pipelineReader;
	PipelineInfo pipelineInfo;
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		SetError(pipelineReader);
		return FALSE;
	}


	// start thread that is signalled when pipeline should stop
	if (!mStopObservable.Init())
	{
		SetError(mStopObservable.GetLastError(),
						 "Could not initialize pipeline stop observable");
		return FALSE;
	}

	mStopObservable.AddObserver(*this);

	if (!mStopObservable.StartThread())
	{
		SetError(mStopObservable.GetLastError(), "Could not pipeline stop event thread");
		return FALSE;
	}

	BOOL startRouter = mParams.StartRouter();
	BOOL startResubmitRouter = mParams.StartRouter() && PipelineInfo::PERSISTENT_MSMQ == pipelineInfo.GetHarnessType();
	BOOL startAuditor = mParams.StartAuditor() && PipelineInfo::PERSISTENT_MSMQ == pipelineInfo.GetHarnessType();

	// TODO: read from pipeline.xml
	BOOL startQueueFlag = TRUE && PipelineInfo::PERSISTENT_MSMQ == pipelineInfo.GetHarnessType();

	BOOL startRestart = TRUE;
	BOOL routerSucceeded = TRUE;
	BOOL resubmitRouterSucceeded = TRUE;
	BOOL auditorSucceeded = TRUE;
	BOOL queueFlagSucceeded = TRUE;
	BOOL restartServiceSucceeded = TRUE;

	if (startAuditor)
	{
		cout << "Starting Auditor..." << endl;
		mLogger.LogThis(LOG_INFO, "Starting Auditor...");
		if (!mAuditor.Init())
		{
			mLogger.LogThis(LOG_ERROR, "Unable to initialize audit service");
			mLogger.LogErrorObject(LOG_ERROR, mAuditor.GetLastError());
			SetError(mAuditor);
			startAuditor = FALSE;
			auditorSucceeded = FALSE;
		}
		else
		{
			if (mAuditor.AuditingEnabled())
			{
				startAuditor = TRUE;
				mAuditor.StartThread();
				mLogger.LogThis(LOG_INFO, "Session auditor started");
				cout << "Session auditor started." << endl;
			}
			else
			{
				cout << "Auditing disabled." << endl;
				startAuditor = FALSE;
				mLogger.LogThis(LOG_INFO, "Session Auditor disabled");
			}
		}
	}

	if (startRouter)
	{
		cout << "Starting session router..." << endl;
		mLogger.LogThis(LOG_INFO, "Starting session router...");
		if (!mRouter.Init(TRUE, configDir.c_str(), pipelineInfo))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to initialize router service");
			mLogger.LogErrorObject(LOG_ERROR, mRouter.GetLastError());
			SetError(mRouter);
			startRouter = FALSE;
			routerSucceeded = FALSE;
		}
		else
		{
			if (mRouter.RoutingConfigured())
			{
				mRouter.StartThread();

				mLogger.LogThis(LOG_INFO, "Session router started");
				startRouter = TRUE;
				cout << "Session router started." << endl;
			}
			else
			{
				cout << "No routing configured." << endl;
				mLogger.LogThis(LOG_INFO, "Session routing not configured.");
				startRouter = FALSE;
			}
		}
	}

	if (startResubmitRouter)
	{
		cout << "Starting auto-resubmit router..." << endl;
		mLogger.LogThis(LOG_INFO, "Starting auto-resubmit router...");
		// FALSE means not the main router
		if (!mResubmitRouter.Init(FALSE, configDir.c_str(), pipelineInfo))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to initialize auto-resubmit router service");
			mLogger.LogErrorObject(LOG_ERROR, mResubmitRouter.GetLastError());
			SetError(mResubmitRouter);
			startResubmitRouter = FALSE;
			resubmitRouterSucceeded = FALSE;
		}
		else
		{
			if (mResubmitRouter.RoutingConfigured())
			{
				mResubmitRouter.StartThread();

				mLogger.LogThis(LOG_INFO, "Auto-resubmit router started");
				startResubmitRouter = TRUE;
				cout << "Auto-resubmit router started." << endl;
			}
			else
			{
				cout << "No routing configured." << endl;
				mLogger.LogThis(LOG_INFO, "Auto-resubmit routing not configured.");
				startResubmitRouter = FALSE;
			}
		}
	}


	if (startQueueFlag)
	{
		cout << "Starting routing queue guard..." << endl;
		mLogger.LogThis(LOG_INFO, "Starting routing queue guard...");
		if (!mQueueFlag.Init(pipelineInfo))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to initialize routing queue guard service");
			mLogger.LogErrorObject(LOG_ERROR, mQueueFlag.GetLastError());
			SetError(mQueueFlag);
			startQueueFlag = FALSE;
			queueFlagSucceeded = FALSE;
		}
		else
		{
			mQueueFlag.StartThread();

			mLogger.LogThis(LOG_INFO, "Routing queue guard started");
			startQueueFlag = TRUE;
			cout << "Routing queue guard started." << endl;
		}
	}

	if (startRestart)
	{
		cout << "Starting session restart service..." << endl;
		mLogger.LogThis(LOG_INFO, "Starting session restart service...");
		mSessionRestart.Init(pipelineInfo);
		if (mSessionRestart.ServiceRequired())
		{
			mSessionRestart.StartThread();
			mLogger.LogThis(LOG_INFO, "Session restart service started");
			startRestart = TRUE;
			cout << "Session restart service started." << endl;
		}
		else
		{
			mLogger.LogThis(LOG_INFO, "Session restart service not started");
			startRestart = FALSE;
			cout << "Session restart service not started." << endl;
		}
	}

	enum WhichService
	{
		ROUTER_SERVICE = 0,
		RESUBMIT_ROUTER_SERVICE,
		AUDITOR_SERVICE,
		QUEUE_GUARD_SERVICE,
		RESTART_SERVICE,

		NUMBER_OF_SERVICES					// terminator
	};

	HANDLE handles[NUMBER_OF_SERVICES];
	WhichService services[NUMBER_OF_SERVICES];

	int serviceIndex = 0;
	if (startRouter)
	{
		handles[serviceIndex] = mRouter.ThreadHandle();
		services[serviceIndex] = ROUTER_SERVICE;
		serviceIndex++;
	}

	if (startResubmitRouter)
	{
		handles[serviceIndex] = mResubmitRouter.ThreadHandle();
		services[serviceIndex] = RESUBMIT_ROUTER_SERVICE;
		serviceIndex++;
	}

	if (startAuditor)
	{
		handles[serviceIndex] = mAuditor.ThreadHandle();
		services[serviceIndex] = AUDITOR_SERVICE;
		serviceIndex++;
	}

	if (startQueueFlag)
	{
		handles[serviceIndex] = mQueueFlag.ThreadHandle();
		services[serviceIndex] = QUEUE_GUARD_SERVICE;
		serviceIndex++;
	}

	if (startRestart)
	{
		handles[serviceIndex] = mSessionRestart.ThreadHandle();
		services[serviceIndex] = RESTART_SERVICE;
		serviceIndex++;
	}


	if (serviceIndex == 0)
	{
		// nothing started.
		// TODO: what should be done in this 
		cout << "No services started.  Shutting down." << endl;
		return TRUE;
	}

	if (!auditorSucceeded || !routerSucceeded || !resubmitRouterSucceeded)
	{
		cout << "Some Pipeline services did not start - exiting." << endl;
		PipelineStop();
	}
	else
	{
		cout << "Pipeline services started - running indefintely." << endl;

		if (!SendReadyMessage())
		{
			cout << "Unable to send ready message." << endl;
			PipelineStop();
			return FALSE;
		}
		else
		{
			FreeMemory();

			DWORD waitResult =
				::WaitForMultipleObjects(serviceIndex, // number of handles
																 handles, // pointer to the object-handles
																 FALSE, // wait flag (wait for both of them)
																 INFINITE); // time-out interval (in millis)
			PipelineStop();
		}
	}

	mLogger.LogThis(LOG_INFO, "Pipeline services shutdown");
	return TRUE;
}

BOOL PipelineServices::FreeMemory()
{
	mLogger.LogThis(LOG_INFO, "Attempting to free unused memory...");

	//
	// make an attempt to free memory used during startup
	//

	// NOTE: this call seems to cause ADO to crash.  right now,
	// we'll avoid the call.  However, we need to figure out if
	// we have an inaccurate ref count to an ADO object or something.

	// free COM libraries that are no longer in use
	//::CoFreeUnusedLibraries();

	// attempt to free up memory used by COM
	IMalloc* iMalloc = NULL;
	if (SUCCEEDED(::CoGetMalloc(1, &iMalloc)))
	{
		iMalloc->HeapMinimize();
		iMalloc->Release();
		iMalloc = NULL;
	}

	// free C runtime memory as much as possible
	_heapmin();


	// reset the working size
	if (!SetProcessWorkingSetSize(::GetCurrentProcess(), -1, -1))
	{
		DWORD err = ::GetLastError();
	}

	return TRUE;
}

void PipelineServices::PipelineStop()
{
	mLogger.LogThis(LOG_INFO, "Shutting down Pipeline services...");
	cout << "Stopping Pipeline services..." << endl;

	if (mRouter.RoutingConfigured())
		mRouter.StopThread(INFINITE);

	if (mResubmitRouter.RoutingConfigured())
		mResubmitRouter.StopThread(INFINITE);

	mAuditor.StopThread(INFINITE);
}


BOOL PipelineServices::SendReadyMessage()
{
	BOOL usePrivateQueues = mRouter.UsePrivateQueues();

 	// initialize the master control queue.
	MessageQueueProps queueProps;

	// master control queue
	MessageQueue pipelineControlQueue;

	queueProps.SetLabel(L"Pipeline controller's queue");
	queueProps.SetJournal(FALSE);

	std::wstring controlQueueName(PIPELINE_CONTROL_QUEUE);
	MakeUnique(controlQueueName);
	if (!pipelineControlQueue.CreateQueue(controlQueueName.c_str(),
																				usePrivateQueues, queueProps))
	{
		if (pipelineControlQueue.GetLastError()->GetCode()
				!= MQ_ERROR_QUEUE_EXISTS)
		{
			SetError(pipelineControlQueue.GetLastError());
			return FALSE;
		}
		mLogger.LogThis(LOG_DEBUG, "Control queue already exists");
	}
	else
		mLogger.LogThis(LOG_DEBUG, "Control queue created sucessfully");

	if (!pipelineControlQueue.Init(controlQueueName.c_str(), usePrivateQueues)
			|| !pipelineControlQueue.Open(MQ_SEND_ACCESS, MQ_DENY_NONE))
	{
		SetError(pipelineControlQueue.GetLastError(),
						 "Could not initialize control queue.");
		return FALSE;
	}


	mLogger.LogThis(LOG_DEBUG, "Sending message reporting pipesvc is ready");

	QueueMessage sendme;

	sendme.ClearProperties();

	sendme.SetPriority(PIPELINE_SYSTEM_PRIORITY);
	sendme.SetExpressDelivery(TRUE);

	sendme.SetAppSpecificLong(PIPELINE_STAGE_STATUS);

	PipelineStageStatus status;
	// HACK: -1 means pipesvc
	status.mStageID = -1;
	status.mStatus = PipelineStageStatus::PIPELINE_STAGE_READY;
	sendme.SetBody((UCHAR *) &status, sizeof(status));

	if (!pipelineControlQueue.Send(sendme))
	{
		SetError(pipelineControlQueue.GetLastError());
		return FALSE;
	}

	return TRUE;
}



int main(int argc, char * argv[])
{
	const char * login = NULL;
	const char * password = NULL;
	const char * domain = NULL;

	int maxSessions = -1;
	int maxAudit = -1;

	// negative means test forever
	int i = 0;
	while (i < argc)
	{
		if (0 == strcmp(argv[i], "-login"))
		{
			i++;
			if (i >= argc)
			{
				cout << "login name required after -login" << endl;
				return 1;
			}
			login = argv[i];
		}
		else if (0 == strcmp(argv[i], "-password"))
		{
			i++;
			if (i >= argc)
			{
				cout << "password required after -password" << endl;
				return 1;
			}
			password = argv[i];
		}
		else if (0 == strcmp(argv[i], "-domain"))
		{
			i++;
			if (i >= argc)
			{
				cout << "domain required after -domain" << endl;
				return 1;
			}
			domain = argv[i];
		}
		else if (0 == strcmp(argv[i], "-maxroute"))
		{
			i++;
			if (i >= argc)
			{
				cout << "number required after -maxroute" << endl;
				return 1;
			}
			maxSessions = atoi(argv[i]);
		}
		else if (0 == strcmp(argv[i], "-maxaudit"))
		{
			i++;
			if (i >= argc)
			{
				cout << "number required after -maxaudit" << endl;
				return 1;
			}
			maxAudit = atoi(argv[i]);
		}
		i++;
	}

	try
	{
		MultiInstanceSetup multiSetup;
		if (!multiSetup.SetupMultiInstance(login, password, domain))
		{
			string buffer;
			StringFromError(buffer, "Multi-instance setup failed", multiSetup.GetLastError());
			cout << buffer.c_str() << endl;
			return -1;
		}

		PipelineServices services;
		services.SetMaxSessionsRouted(maxSessions);
		services.SetMaxAudits(maxAudit);
		if (!services.Run())
		{
			const ErrorObject * err = services.GetLastError();
			string buffer;
			StringFromError(buffer, "Unable to run pipeline service", err);
			cout << buffer.c_str() << endl;
		}
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Error running pipeline services", err);
		cout << buffer.c_str() << endl;
		return -1;
	}

	return 0;
}
