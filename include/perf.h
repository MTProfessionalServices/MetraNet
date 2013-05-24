/**************************************************************************
 * @doc PERF
 *
 * @module |
 *
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
 *
 * @index | PERF
 ***************************************************************************/

#ifndef _PERF_H
#define _PERF_H

typedef LARGE_INTEGER PerformanceTickCount;

//#define USE_TICK_COUNT

inline void GetCurrentPerformanceTickCount(PerformanceTickCount * apTickCount)
{
#ifdef USE_TICK_COUNT
	apTickCount->LowPart = ::GetTickCount();
	apTickCount->HighPart = 0;
#else
	BOOL result = ::QueryPerformanceCounter(apTickCount);
	ASSERT(result);
#endif
}

inline __int64 PerformanceCountTicks(PerformanceTickCount * apStart,
																		 PerformanceTickCount * apEnd)
{
	return (apEnd->QuadPart - apStart->QuadPart);
}

inline BOOL GetPerformanceTickCountFrequency(long & arTickFrequency)
{
#ifdef USE_TICK_COUNT
	arTickFrequency = 1000;
	return TRUE;
#else
	LARGE_INTEGER freq;
	if (!QueryPerformanceFrequency(&freq))
	{
		ASSERT(0);
		return FALSE;								// not supported
	}

	arTickFrequency = (long) freq.QuadPart;
	return TRUE;
#endif
}

inline BOOL GetPerformanceTickCountFrequency(__int64 & arTickFrequency)
{
#ifdef USE_TICK_COUNT
	arTickFrequency = 1000;
	return TRUE;
#else
	LARGE_INTEGER freq;
	if (!QueryPerformanceFrequency(&freq))
	{
		ASSERT(0);
		return FALSE;								// not supported
	}

	arTickFrequency = freq.QuadPart;
	return TRUE;
#endif
}

#endif /* _PERF_H */
