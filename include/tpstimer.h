/**************************************************************************
 * @doc TPSTIMER
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 *
 * @index | TPSTIMER
 ***************************************************************************/

#ifndef _TPSTIMER_H
#define _TPSTIMER_H

class TimingInfo
{
public:
	TimingInfo(int aPeriod);

	void AddTransactions(int aCount);

private:

// timing info
	PerformanceTickCount initialTicks;
	PerformanceTickCount finalTicks;

	DWORD threads;
	DWORD maxConcurrent;

	int mCount;

	int mSinceLast;

	// lock for the whole structure
	NTThreadLock mLock;

	int mPeriod;

	long mFrequency;
};

TimingInfo::TimingInfo(int aPeriod)
	: mPeriod(aPeriod),
		mCount(0),
		mSinceLast(0),
		threads(0),
		maxConcurrent(0)
{
	GetPerformanceTickCountFrequency(mFrequency);
	GetCurrentPerformanceTickCount(&initialTicks);
}

void TimingInfo::AddTransactions(int aCount)
{
	AutoCriticalSection autolock(&mLock);

	mSinceLast += aCount;
	mCount += aCount;

	if (mSinceLast >= mPeriod)
	{
		int ops = mSinceLast;
		GetCurrentPerformanceTickCount(&finalTicks);

		__int64 ticks = PerformanceCountTicks(&initialTicks, &finalTicks);
		printf("transactions: %d\n", ops);
		printf("ticks: %I64d\n", ticks);
		printf("TPS: %f\n", (((double) mSinceLast / (double) ticks) * (double) mFrequency));

		//printf("max concurrent threads: %d\n", gTimingInfo->maxConcurrent);

		GetCurrentPerformanceTickCount(&initialTicks);
		mSinceLast = 0;
	}
}

#endif /* _TPSTIMER_H */
