/**************************************************************************
 * @doc THREADTEST
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
 * $Header$
 *
 * @index | THREADTEST
 ***************************************************************************/

#ifndef _THREADTEST_H
#define _THREADTEST_H

#include <stdio.h>

#ifdef UNIX
#include <synch.h>  // for semaphores
#else
#include <process.h> // for begin thread
#endif // UNIX


/*
 * UNIX TODO:
 *
 * implement locking
 */


class ThreadTest
{
public:
	ThreadTest(int aThreads, int aSerialCount, int aParallelCount);

	BOOL RunTest(int argc, char * * argv);

	void SafePrint(const char * apFmt);
	void SafePrint(const char * apFmt, double aArg1);
	void SafePrint(const char * apFmt, int aArg1);
	void SafePrint(const char * apFmt, int aArg1, int aArg2);
	void SafePrint(const char * apFmt, const char * aArg1);

	void AddThread();
	void RemoveThread(DWORD aDuration);
	int GetLiveCount();

	// thread entry point
	static void ThreadFunc(void * apArg);

	virtual BOOL Test() = 0;


	DWORD GetSerialTicks() const
	{ return mSerialTicks; }

	DWORD GetParallelTicks() const
	{ return mParallelTicks; }

	DWORD GetThreadTotalTicks() const
	{ return mThreadTotalTicks; }
		
	const int mParallelCount;

protected:
	virtual BOOL Setup(int argc, char * * argv) = 0;

private:
#ifdef WIN32
	CRITICAL_SECTION mCountGuard;
	CRITICAL_SECTION mPrintGuard;
	CRITICAL_SECTION mTestGuard;
#else // WIN32
	sema_t mCountGuard;
	sema_t mPrintGuard;
	sema_t mTestGuard;
#endif

	DWORD mSerialTicks;
	DWORD mParallelTicks;

	// protected by mCountGuard
	DWORD mThreadTotalTicks;
	int mThreadCount;

	const int mThreads;
	const int mSerialCount;
};


#endif /* _THREADTEST_H */
