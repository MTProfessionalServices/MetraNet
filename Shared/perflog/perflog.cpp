/**************************************************************************
 * PERFLOG
 *
 * Copyright 1997-2002 by MetraTech Corp.
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
#define PERF_LOG_DEF
#include "perflog.h"

#include <loggerconfig.h>
#include <autocritical.h>

#include <perf.h>
#include <stdio.h>

// what's logged:
// enter or exit
// 64 bit absolute performance counter value
// process ID
// thread ID
// region name
// 

static FILE * gLogFile = 0;
static bool gLoggingStateKnown = false;
static NTThreadLock gLock;
int gLinesSinceFlush;
HANDLE gMutex = 0;
char * gBuffer = 0;
int gBufferPos = 0;

struct DefineSymbol
{
	short type;										// 2

	int threadID;									// 4
	int number;										// 4
	char name[50];
};

struct StartThread
{
	short type;										// 2
	char name[48];

	int threadID;									// 4
	__int64 systemTime;						// 8

};

struct EndThread
{
	short type;										// 2
	char empty[58];

	int threadID;									// 4
};

// 16 bytes
struct EnterRegion
{
	int symbol;										// 4
	int threadID;									// 4
	__int64 mark_time;						// 8

};


static bool InitMutex()
{
	const char * functionName = "CMTBillingReRunExec::InitMutex";

	// do nothing if it's already initialized
	if (gMutex)
		return true;

	SECURITY_ATTRIBUTES sa;
	SECURITY_DESCRIPTOR sd;

	/*
	 * create a NULL security descriptor
	 * TODO: create a more restricted discretionary access control list.
	 */
	sa.nLength = sizeof(SECURITY_ATTRIBUTES);
	sa.bInheritHandle = TRUE;
	sa.lpSecurityDescriptor = &sd;
	if (!::InitializeSecurityDescriptor(&sd, SECURITY_DESCRIPTOR_REVISION))
		return false;

	if (!::SetSecurityDescriptorDacl(&sd, TRUE, (PACL)NULL, FALSE))
		return false;


	/*
	 * create the mutex
	 */
	std::string mutexName("MTPerfLogMutex");
	// make this globally unique across terminal services sessions.
	mutexName.insert(0, "Global\\");

	gMutex = ::CreateMutexA(&sa,			// security
													FALSE,		// initially not owned
													mutexName.c_str()); // mutex name
	if (gMutex == NULL)
		return false;

	return true;
}

static bool AccessMutex()
{
	ASSERT(gMutex);
	DWORD waitResult =
		::WaitForSingleObject(gMutex,   // handle of mutex
													1000 * 60 * 60); // 1 hour

	if (waitResult == WAIT_OBJECT_0 || waitResult == WAIT_ABANDONED)
		return true;
	else
		return false;
}

static void ReleaseMutex()
{
	BOOL result = ::ReleaseMutex(gMutex);
	ASSERT(result);
}

static void CloseMutex()
{
	CloseHandle(gMutex);
	gMutex = NULL;
}

static void AtExitHook()
{
	if (!AccessMutex())
		ASSERT(0);

	fwrite(gBuffer, gBufferPos, 1, gLogFile);

	fprintf(gLogFile, "*** log ending for process %04d.\n",
					GetCurrentProcessId());

	fflush(gLogFile);

	fclose(gLogFile);
	ReleaseMutex();
	CloseMutex();
}

static void StartLoggingSession()
{
	ASSERT(sizeof(DefineSymbol) == 64);
	ASSERT(sizeof(StartThread) == 64);
	ASSERT(sizeof(EndThread) == 64);
	ASSERT(sizeof(EnterRegion) == 16);

	ASSERT(gLogFile);

	atexit(AtExitHook);
	gLinesSinceFlush = 0;

	ASSERT(gBuffer == 0);
	gBuffer = new char[4096];
	gBufferPos = 0;

	__int64 freq;
	BOOL result = GetPerformanceTickCountFrequency(freq);
	ASSERT(freq);									// if false, machine doesn't support counters


#if 0
	if (!AccessMutex())
		ASSERT(0);


	fprintf(gLogFile, "*** log started for process %04d.  counter frequency = %d counts per second\n",
					GetCurrentProcessId(), freq);

	ReleaseMutex();
#endif


	AutoCriticalSection lock(&gLock);
	int len = sprintf(gBuffer + gBufferPos, "*** log started for process %04d.  counter frequency = %I64d counts per second\n",
										GetCurrentProcessId(), freq);
	gBufferPos += len;

}

bool PerfLogActive_()
{
	AutoCriticalSection lock(&gLock);

	if (gLoggingStateKnown)
		return gLogFile != 0;
	else
	{
		gLoggingStateKnown = true;
		LoggerConfigReader configReader;

		// NOTE: we may be operating in an alien environment (like the SDK)
		// where COM is not initialized.  Initialize it ourself
		HRESULT hr = ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
		LoggerInfo * perfLogInfo = configReader.ReadConfiguration("logging\\perflog\\");

		if (!perfLogInfo)
		{
			if (SUCCEEDED(hr))
				::CoUninitialize();

			return false;
		}

		MTLogLevel level = perfLogInfo->GetLogLevel();
		std::string filename = (const char *) perfLogInfo->GetFilename();
		delete perfLogInfo;

		if (SUCCEEDED(hr))
			::CoUninitialize();

		if (level == LOG_TRACE)
		{
			if (!InitMutex())
			{
				gLogFile = 0;
				return false;
			}

			// logging is active
			gLogFile = fopen(filename.c_str(), "a");
			if (gLogFile)
			{
				StartLoggingSession();
				return true;
			}
			return false;
		}
		else
		{
			// no logging
			gLogFile = 0;
			return false;
		}
	}
}

static void Mark(const char * regionName, const char * arg, bool enter)
{
	if (PerfLogActive_())
	{
		ASSERT(gLogFile);

		DWORD processID = GetCurrentProcessId();
		DWORD threadID = GetCurrentThreadId();

		PerformanceTickCount tickCount;
		GetCurrentPerformanceTickCount(&tickCount);

		__int64 absoluteTime = tickCount.QuadPart;

		// enter
		//  exit


		gLock.Lock();
		int len = sprintf(gBuffer + gBufferPos, "%016I64d %08d:%08d %s %s%s%s\n",
						absoluteTime,
						processID, threadID,
						enter ? ">" : "<",
						regionName,
						arg ? ": " : "",
						arg ? arg : "");

		gBufferPos += len;
		gLinesSinceFlush++;

		if (gBufferPos > 3 * 1024)
		{
			if (!AccessMutex())
				ASSERT(0);

			fwrite(gBuffer, gBufferPos, 1, gLogFile);
			fflush(gLogFile);
			gBufferPos = 0;
			gLinesSinceFlush = 0;

			ReleaseMutex();
		}

		gLock.Unlock();
	}
}


void MarkEnterRegion_(const char * regionName, const char * arg /* = 0 */)
{
	Mark(regionName, arg, true);
}

void MarkExitRegion_(const char * regionName, const char * arg /* = 0 */)
{
	Mark(regionName, arg, false);
}

