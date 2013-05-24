/**************************************************************************
 * @doc NTTHREADER
 * 
 * @module Thread encapsulation |
 * 
 * This is thread class. A simple encapsulation for threads.
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | NTTHREADER
 ***************************************************************************/

#include "MTSL_PCH.h"

#include <NTThreader.h>

//
//	@mfunc
//	Initialize the critical section and events.
//  @rdesc 
//  No return value.
// 
NTThreader::NTThreader ()
  : mThreadHandle  (INVALID_HANDLE_VALUE), mRetCode (0),
	mThreadAddr (0)
{
  InitializeCriticalSection (&mLock);
	mStopEvent		= CreateEvent (NULL, TRUE, FALSE, NULL);
	mInitEvent = CreateEvent (NULL, TRUE, FALSE, NULL);
}

//
//	@mfunc
//	Delete the critical section and free the events.
//  @rdesc 
//  No return value
// 
NTThreader::~NTThreader()
{
	SetEvent (mStopEvent);

	WaitForThread (INFINITE);

	CloseHandle (mStopEvent);
	CloseHandle (mInitEvent);
  DeleteCriticalSection (&mLock); 
}

//
//	@mfunc
//	Call _beginthreadex to start the thread. Use the BootstrapThread function as the 
//  starting point for the thread. The ThreadMain() function gets called by the 
//  BootstrapThread function.
//  @rdesc 
//  Returns TRUE on successful starting of the thread. Otherwise, FALSE is returned and
//  the error code gets saved in the mRetCode data member.
//  @devnote
//  This function is inherited from the Threader class.
// 
BOOL NTThreader::StartThread()
{
	if (IsRunning()) 
    return TRUE;

	// Initialize state variables here.  This is required for re-started threads
	//
	mRetCode = 0;
	mThreadHandle  = INVALID_HANDLE_VALUE;
	mThreadAddr = 0;

	// Reset events too.  Re-started threads may have left these signaled
	//
	ResetEvent (mStopEvent);
	ResetEvent (mInitEvent);

	// Crank up the thread and check for errors
	//
	const DWORD threadCode = _beginthreadex (NULL, 0, BootstrapThread,
											  (void *) this, 0,
											  &mThreadAddr);

	if (threadCode != 0)
	{
		// Stash the thread_code
		//
		mThreadHandle = (HANDLE) threadCode;

		return TRUE;
	}
	else
	{
		mRetCode = GetLastError();
		return FALSE;
	}
}

//
//	@mfunc
//  This function sets the stop event to indicate that the thread should stop. It then 
//  waits the specified amount of time for the thread to stop.
//	@parm The amount of time to wait for the thread to stop.
//  @rdesc 
//  Returns TRUE if the thread stopped in the specified amount of time. Otherwise, FALSE
//  is returned.
//  @devnote
//  This function is inherited from the Threader class.
// 
BOOL NTThreader::StopThread (const DWORD timeout)
{
	SetEvent (mStopEvent);

	return WaitForThread (timeout);
}

//
//	@mfunc
//	This function waits the specified amount of time for the thread to be signalled.
//	@parm The amount of time to wait for the thread to stop.
//  @rdesc 
//  Returns TRUE if the thread was signalled in the specified amount of time. Otherwise,
//  FALSE is returned.
//  @devnote
//  This function is inherited from the Threader class.
// 
BOOL NTThreader::WaitForThread (const DWORD timeout)
{
	//
	// Trivial case
	//
	if (mThreadHandle == INVALID_HANDLE_VALUE)
	{
		mThreadAddr = 0;
		return TRUE;
	}

	// If timeout is INFINITE, avoid infinite lock
	// by testing if thread is still active.
	// This check would also make sense for other timeouts, but don't
	// want to disturb code that happens to depend on timeout.
	if( timeout == INFINITE )
	{
		DWORD exitCode = 0;
		BOOL success = GetExitCodeThread(mThreadHandle, &exitCode );

		if (!success && GetLastError() == ERROR_INVALID_HANDLE)
		{	// invalid handle
			mThreadHandle = INVALID_HANDLE_VALUE;
			mThreadAddr = 0;
			return TRUE;
		}

		if (success && exitCode != STILL_ACTIVE)
		{	// handle valid, but thread not active anymore
			CloseHandle (mThreadHandle);
			mThreadHandle = INVALID_HANDLE_VALUE;
			mThreadAddr = 0;
			return TRUE;
		}
	}

	const int retCode = WaitForSingleObject (mThreadHandle, timeout);

	switch (retCode)
	{
	case WAIT_OBJECT_0:
		//
		// Object is signalled.  Delete thread handle
		//
		ThreadLock();
		
		if (mThreadHandle != INVALID_HANDLE_VALUE)
		{
			CloseHandle (mThreadHandle);
			mThreadHandle  = INVALID_HANDLE_VALUE;
			mThreadAddr = 0;
		}
		
		ThreadUnlock();

		return TRUE;
		
		break;
	case WAIT_TIMEOUT:
		//
		// Not yet signalled
		//
		return FALSE;
		
		break;
	case WAIT_FAILED:
	{
		const int errorCode = GetLastError();
		mThreadHandle  = INVALID_HANDLE_VALUE;
		return TRUE;
		break;
	}

	case WAIT_ABANDONED:
	default:
		return TRUE;
	
	}
}

//
//	@mfunc
//	This helper function wraps the ThreadMain routine. This routine calls the ThreadMain 
//  routine and saves the errorcode in the mRetCode data member.
//	@parm The arg_list of the thread which is a pointer to this.
//  @rdesc 
//  The return value of the thread
//  @devnote
//  This is a static function
// 
unsigned int __stdcall NTThreader::BootstrapThread (void *arg_list)
{
	NTThreader	*const pObject = (NTThreader *) arg_list;

  if (pObject->mRetCode == ERROR_SUCCESS)
	{
		//
		// Run Thread's Main loop, provided by consumer object
		//
		pObject->mRetCode = pObject->ThreadMain();
	}

 	_endthreadex (pObject->mRetCode);

	return pObject->mRetCode;
}

