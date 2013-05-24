/**************************************************************************
 * @doc THREADTEST
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
 * $Header$
 ***************************************************************************/

#include <metra.h>
#include "threadtest.h"

#ifdef UNIX
static void InitializeCriticalSection(sema_t *s)
{
  sema_init(s, 1, USYNC_THREAD, NULL);
}
  
static void DeleteCriticalSection(sema_t *s)
{
  sema_destroy(s);
}

static void EnterCriticalSection(sema_t *s)
{
  sema_wait(s);
}

static void LeaveCriticalSection(sema_t *s)
{
  sema_post(s);
}


static long GetTickCount()
{
	return 0;
}

#endif


ThreadTest::ThreadTest(int aThreads, int aSerialCount, int aParallelCount)
	: mThreads(aThreads), mSerialCount(aSerialCount), mParallelCount(aParallelCount)
{
	mSerialTicks = mParallelTicks = mThreadTotalTicks = 0;
}


void ThreadTest::AddThread()
{
	EnterCriticalSection(&mCountGuard);
	mThreadCount++;
	LeaveCriticalSection(&mCountGuard);
}

void ThreadTest::RemoveThread(DWORD aDuration)
{
	EnterCriticalSection(&mCountGuard);
	mThreadCount--;
	mThreadTotalTicks += aDuration;
	LeaveCriticalSection(&mCountGuard);
}

int ThreadTest::GetLiveCount()
{
	int count;
	EnterCriticalSection(&mCountGuard);
	count = mThreadCount;
	LeaveCriticalSection(&mCountGuard);
	return count;
}


void ThreadTest::SafePrint(const char * apFmt)
{
	EnterCriticalSection(&mPrintGuard);
	printf(apFmt);
	fflush(stdout);
	LeaveCriticalSection(&mPrintGuard);
}

void ThreadTest::SafePrint(const char * apFmt, double aArg1)
{
	EnterCriticalSection(&mPrintGuard);
	printf(apFmt, aArg1);
	fflush(stdout);
	LeaveCriticalSection(&mPrintGuard);
}

void ThreadTest::SafePrint(const char * apFmt, int aArg1)
{
	EnterCriticalSection(&mPrintGuard);
	printf(apFmt, aArg1);
	fflush(stdout);
	LeaveCriticalSection(&mPrintGuard);
}

void ThreadTest::SafePrint(const char * apFmt, int aArg1, int aArg2)
{
	EnterCriticalSection(&mPrintGuard);
	printf(apFmt, aArg1, aArg2);
	fflush(stdout);
	LeaveCriticalSection(&mPrintGuard);
}

void ThreadTest::SafePrint(const char * apFmt, const char * aArg1)
{
	EnterCriticalSection(&mPrintGuard);
	printf(apFmt, aArg1);
	fflush(stdout);
	LeaveCriticalSection(&mPrintGuard);
}

BOOL ThreadTest::RunTest(int argc, char * * argv)
{
	InitializeCriticalSection(&mPrintGuard);
	InitializeCriticalSection(&mCountGuard);
	InitializeCriticalSection(&mTestGuard);


	if (!Setup(argc, argv))
		return FALSE;

	//
	// single threaded
	//

	SafePrint("#### Running test in serial. ####\n");

	DWORD start = ::GetTickCount();
	int i;
	for (i = 0; i < mSerialCount; i++)
	{
		//SafePrint("Iteration %d\n", i);
		if (!Test())
		{
			SafePrint("**** Test failed on iteration %d of serial test! ****", i);
			break;
		}
	}

	DWORD end = ::GetTickCount();
	SafePrint("Duration: %ldms\n", (int) (end - start));
	SafePrint("%f/s\n", (((double) mSerialCount) / ((double) (end - start))) * 1000.0);

	//
	// multithreaded
	//

#ifndef UNIX
	if (mThreads > 0)
	{
		SafePrint("#### Running test in parallel. ####\n");

		start = ::GetTickCount();

		mThreadCount = 0;
		for (i = 0; i < mThreads; i++)
		{
			//ThreadArgument * arg = new ThreadArgument;
			//arg->mBuffer = buffer;
			//arg->mTest = this;

			unsigned long hand = _beginthread(ThreadFunc, 0, this);

#if 0
			DWORD threadId;


			HANDLE threadHand =
				CreateThread(NULL,					// pointer to thread security attributes 
										 0,							// initial thread stack size, in bytes (default)
										 ThreadFunc,
										 (LPVOID) arg,	// argument for new thread 
										 0,				 		// creation flags 
										 &threadId);		// pointer to returned thread identifier 
#endif


			SafePrint("Started thread #%d (%d)\n", i, hand);
			AddThread();
		}

		SafePrint("Waiting for threads to exit\n");
		int live;
		int iteration = 0;
		while ((live = GetLiveCount()) > 0)
		{
			// print the message about once every 10 seconds
			iteration++;
			if (iteration % 10 == 0)
				SafePrint("Live: %d\n", live);
			Sleep(1000);
		}

		end = ::GetTickCount();
		SafePrint("Duration: %ld+=100ms\n", (long) (end - start));
		SafePrint("Accumulated ticks: %ldms\n", (long) mThreadTotalTicks);
		SafePrint("Accumulated total: %fms\n",
							((double) mThreadTotalTicks / (double) mThreads));
		SafePrint("%f/s\n", ((double) (mParallelCount * mThreads) / (end - start)) * 1000.0);


		SafePrint("All threads are complete\n");
	}
#endif // UNIX


	DeleteCriticalSection(&mPrintGuard);
	DeleteCriticalSection(&mCountGuard);
	DeleteCriticalSection(&mTestGuard);

	return TRUE;
}

//DWORD WINAPI ThreadFunc(LPVOID arg)

void ThreadTest::ThreadFunc(void * apArg)
{
	ThreadTest * test = (ThreadTest *) apArg;
	
	DWORD start = ::GetTickCount();
	for (int i = 0; i < test->mParallelCount; i++)
	{
		if (!test->Test())
		{
			test->SafePrint("**** Test failed on iteration %i of the parallel test ****", i);
			break;
		}
	}

	DWORD end = ::GetTickCount();

	test->RemoveThread(end - start);
}




