/**************************************************************************
 * QUEUEFLAG
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <queueflag.h>


QueueFlag::QueueFlag()
{ }

QueueFlag::~QueueFlag()
{
	StopThread(INFINITE);
}

BOOL QueueFlag::Init()
{
	const char * functionName = "QueueFlag::Init";

	//
	// initialize the perfmon integration library
	//
	if (!mPerfShare.Init())
	{
		SetError(mPerfShare);
		return FALSE;
	}
	mpStats = &mPerfShare.GetWriteableStats();


	// TODO: this should check the queue size but it doesn't
	// seem to work under IIS.
	// setting it to true may not be the right decision since it will
	// enable the listener to queue messages forever when the pipeline's
	// not running.
	BOOL accept = TRUE;

	// create a NULL security descriptor
	SECURITY_ATTRIBUTES sa;
	SECURITY_DESCRIPTOR sd;
	sa.nLength = sizeof(SECURITY_ATTRIBUTES);
	sa.bInheritHandle = TRUE;
	sa.lpSecurityDescriptor = &sd;
	if (!::InitializeSecurityDescriptor(&sd, SECURITY_DESCRIPTOR_REVISION)
		|| !::SetSecurityDescriptorDacl(&sd, TRUE, (PACL)NULL, FALSE))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// make this visible in performance monitor
	mpStats->SetTiming(SharedStats::QUEUEING_ENABLED_FLAG, accept ? 1 : 0);

	mEvent = ::CreateEvent(&sa,		// security
												 TRUE,	// manually reset
												 accept, // initial state
												 L"MTQueuingEnabled");
	if (mEvent == NULL)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	mLogger->LogThis(LOG_DEBUG, "Queue flag initialized, accepting messages");


	return TRUE;
}


BOOL QueueFlag::Init(const PipelineInfo & arPipelineInfo)
{
	const char * functionName = "QueueFlag::Init";

	//
	// initialize the perfmon integration library
	//
	if (!mPerfShare.Init())
	{
		SetError(mPerfShare);
		return FALSE;
	}
	mpStats = &mPerfShare.GetWriteableStats();


	// read settings from pipeline.xml
	mSize = arPipelineInfo.GetMaxQueueSize();
	mLowerSize = arPipelineInfo.GetMinQueueSize();

	if (!mQueueSize.Init(arPipelineInfo.GetOneRoutingQueueMachine().c_str(),
											 arPipelineInfo.GetOneRoutingQueueName().c_str(),
											 arPipelineInfo.UsePrivateQueues(), FALSE))
	{
		SetError(mQueueSize);
		return FALSE;
	}

	int size = mQueueSize.GetCurrentQueueSize();
	BOOL accept = (size < mSize);

	// create a NULL security descriptor
	SECURITY_ATTRIBUTES sa;
	SECURITY_DESCRIPTOR sd;
	sa.nLength = sizeof(SECURITY_ATTRIBUTES);
	sa.bInheritHandle = TRUE;
	sa.lpSecurityDescriptor = &sd;
	if (!::InitializeSecurityDescriptor(&sd, SECURITY_DESCRIPTOR_REVISION)
		|| !::SetSecurityDescriptorDacl(&sd, TRUE, (PACL)NULL, FALSE))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// make this visible in performance monitor
	mpStats->SetTiming(SharedStats::QUEUEING_ENABLED_FLAG, accept ? 1 : 0);

	mEvent = ::CreateEvent(&sa,	// security
												 TRUE,	// manually reset
												 accept, // initial state
												 L"MTQueuingEnabled");
	if (mEvent == NULL)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	if (accept)
		mLogger->LogThis(LOG_DEBUG, "Queue flag initialized, accepting messages");
	else
		mLogger->LogThis(LOG_DEBUG, "Queue flag initialized, not accepting messages");

	return TRUE;
}

BOOL QueueFlag::CanQueue()
{
	DWORD waitRes = ::WaitForSingleObject(mEvent, 0);
	ASSERT(waitRes != WAIT_FAILED);
	return (waitRes == WAIT_OBJECT_0);
}


void QueueFlag::EnableQueue()
{
	const char * functionName = "QueueFlag::EnableQueue";

	if (!::SetEvent(mEvent))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		ASSERT(0);
	}

	// make this visible in performance monitor
	mpStats->SetTiming(SharedStats::QUEUEING_ENABLED_FLAG, 1);
}

void QueueFlag::DisableQueue()
{
	const char * functionName = "QueueFlag::DisableQueue";

	if (!::ResetEvent(mEvent))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		ASSERT(0);
	}

	// make this visible in performance monitor
	mpStats->SetTiming(SharedStats::QUEUEING_ENABLED_FLAG, 0);
}

int QueueFlag::ThreadMain()
{
	HANDLE stopHandle = StopEventHandle();

	while (TRUE)
	{
		DWORD result = ::WaitForSingleObject(
			stopHandle, 3 * 1000);		// 3 second period

		ASSERT(result != WAIT_FAILED);
		if (result == WAIT_OBJECT_0 || result == WAIT_ABANDONED)
			break;

		ASSERT(result == WAIT_TIMEOUT);

		int size = mQueueSize.GetCurrentQueueSize();
		if (size == -1)
		{
			SetError(mQueueSize);
			mLogger->LogErrorObject(LOG_ERROR, GetLastError());

			// disable access to the queue until we can accurately read the size
			DisableQueue();
		}

		if (CanQueue())
		{
			// if we're currently accepting messages and we've hit the upper limit,
			// stop accepting more
			if (size > mSize)
			{
				//mLogger->LogVarArgs(LOG_DEBUG, "size at %d: disabling queueing", size);
				DisableQueue();
			}
		}
		else
		{
			// if we're not currently accepting messages and we've dropped below the
			// low mark, start accepting again
			if (size <= mLowerSize)
			{
				//mLogger->LogVarArgs(LOG_DEBUG, "size at %d: enabling queueing", size);
				EnableQueue();
			}
		}
	}

	return 1;
}

BOOL QueueFlag::WaitToSend(int aTimeout)
{
	DWORD result = ::WaitForSingleObject(
		mEvent, aTimeout);

	return (result == WAIT_OBJECT_0);
}
