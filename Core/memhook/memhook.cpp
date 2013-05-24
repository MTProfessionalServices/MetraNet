/**************************************************************************
 * @doc MEMHOOK
 *
 * Copyright 1999 by MetraTech Corporation
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
#include <memhook.h>

#include <crtdbg.h>

#include <stdio.h>

/*
 * log all allocations to a file in CSV form
 */

static FILE * gMemLogFile = NULL;
static HANDLE gMemLogMutex = NULL;


// data format of the log:
// 99,A,N,1000,stack.cpp,123

int __cdecl CSVLogAllocHook(int nAllocType, void * pvData,
														size_t nSize, int nBlockUse,
														long lRequest, const unsigned char * szFileName,
														int nLine)
{
	if (nBlockUse == _CRT_BLOCK) // Ignore internal
		// C runtime library
		// allocations
		return TRUE;

	if (!gMemLogMutex || !gMemLogFile)
		return TRUE;

	ASSERT(nAllocType > 0 && nAllocType < 4);
	ASSERT(nBlockUse >= 0 && nBlockUse < 5 );

	char allocType;
	switch (nAllocType)
	{
	case _HOOK_ALLOC:
		allocType = 'A'; break;
	case _HOOK_REALLOC:
		allocType = 'R'; break;
	case _HOOK_FREE:
		allocType = 'F'; break;
	default:
		allocType = '?'; break;
	}

	char blockType;
	switch (nBlockUse)
	{
	case _FREE_BLOCK:
		blockType = 'F'; break;
	case _NORMAL_BLOCK:
		blockType = 'N'; break;
	case _CRT_BLOCK:
		blockType = 'C'; break;
	case _IGNORE_BLOCK:
		blockType = 'I'; break;
	case _CLIENT_BLOCK:
		blockType = 'C'; break;
	default:
		blockType = '?'; break;
	}

	const char * fileName = szFileName ? (const char *) szFileName : "?";

  DWORD dwWaitResult = ::WaitForSingleObject(gMemLogMutex, (10 * 1000));
  switch (dwWaitResult)
  {
    // The thread got mutex ownership.        
  case WAIT_ABANDONED:
  case WAIT_OBJECT_0:
    // write the data out to the file ...
		fprintf(gMemLogFile, "%d,%c,%c,%d,%s,%d\n",
						lRequest,
						allocType,
						blockType,
						nSize,
						fileName,
						nLine);

		fflush(gMemLogFile);

    // release the mutex 
		::ReleaseMutex(gMemLogMutex);
    break; 

    // Cannot get mutex ownership due to time-out
  case WAIT_TIMEOUT:
    break; 
  default:
    break;
  }

	return TRUE;   // Let memory operation proceed
}


BOOL LogMemoryActivity()
{
	gMemLogFile = fopen("c:\\temp\\memlog.csv", "a+");
	if (!gMemLogFile)
		return FALSE;

	gMemLogMutex = ::CreateMutex(NULL, FALSE, L"MemLogMutex");
	if (!gMemLogMutex)
	{
		fclose(gMemLogFile);
		return FALSE;
	}

	_CrtSetAllocHook(CSVLogAllocHook);
	return TRUE;
}

void StopMemoryActivityLog()
{
	if (gMemLogMutex)
	{
		::CloseHandle(gMemLogMutex);
		gMemLogMutex = NULL;
	}

	if (gMemLogFile)
	{
		fclose(gMemLogFile);
		gMemLogFile = NULL;
	}
}

