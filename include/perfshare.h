/**************************************************************************
 * @doc PERFSHARE
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
 * @index | PERFSHARE
 ***************************************************************************/

#ifndef _PERFSHARE_H
#define _PERFSHARE_H


#include <errobj.h>
#include <autohandle.h>


// shared performance data
class SharedStats
{
private:
	enum
	{
		MAGIC = 0xBABADADA
	};

public:
	enum Timing
	{
		// BatchAccountResolution::PlugInProcessSessions
		ACCT_RES_PROCESS_SESSIONS=0,
		// BatchAccountResolution::SQLExecute
		ACCT_RES_SQL_EXECUTE,
		// BatchAccountResolution fetch
		ACCT_RES_FETCH,

		// BatchPILookup plugin timings
		PILOOKUP_PROCESS_SESSIONS,  //the whole deal
		PILOOKUP_SQL_EXECUTE,       //just the resolution query
		PILOOKUP_FETCH,             //setting the results into the sessions

		// true when accepting messages into the routing queue
		QUEUEING_ENABLED_FLAG,

		// true when the auditing procedure is running
		AUDIT_FLAG,

		// NOTE: must be last - count of all timings
		TIMING_COUNT
	};

public:
	//
	// TPS through various points in the pipeline
	//
	void UpdateSessionsRated(int aCount);
	void UpdateSessionsRouted(int aCount);
	void UpdateSessionsQueued(int aCount);

	int GetSessionsRated() const
	{ return mSessionsRated; }

	int GetSessionsRouted() const
	{ return mSessionsRouted; }

	int GetSessionsQueued() const
	{ return mSessionsQueued; }

	//
	// misc timings
	//
	void SetTiming(enum Timing aTiming, int aValue);

	int GetMiscTiming(enum Timing aTiming) const
	{ return mMiscTimings[aTiming]; }

	//
	// setup
	//
	BOOL IsValid()
	{ return mMagic == MAGIC; }

	void Init();
private:
	LONG mMagic;

	LONG mSessionsRated;
	LONG mSessionsRouted;
	LONG mSessionsQueued;

	LONG mMiscTimings[TIMING_COUNT];
private:
	void UpdateValue(LONG * apValue, int aCount);
};

// owner of shared data - creates a mapped view in the page file
class PerfShare : public ObjectWithError
{
public:
	PerfShare()
		: mpStats(NULL)
	{ }

	~PerfShare();

	BOOL Init();

	// get stats meant for update
	SharedStats & GetWriteableStats()
	{ return *mpStats; }
	
	// get stats meant only for reading
	const SharedStats & GetReadOnlyStats() const
	{ return *mpStats; }

private:
	AutoHANDLE mMapHandle;

	SharedStats * mpStats;
};


#endif /* _PERFSHARE_H */
