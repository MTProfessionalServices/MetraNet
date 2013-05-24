/**************************************************************************
 * @doc PERFOBJ
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
#include <perfobj.h>

#include <mtcom.h>

struct MiscTimingSetup
{
	enum SharedStats::Timing timing;
	const char * internalName;
	const char * displayName;
	const char * helpText;
	DWORD type;
	int defaultScale;
};

static MiscTimingSetup miscTimings[] =
{

	// 
	// BatchAccountResolution timings
	//
 	{ SharedStats::ACCT_RES_PROCESS_SESSIONS,
		"BatchAccountResolutionPlugInProcessSessions",
		"BatchAccountResolution::PlugInProcessSessions",
		"Total execution time (ms) for last batch of sessions through account resolution",
		PERF_COUNTER_RAWCOUNT, -1 },

	{ SharedStats::ACCT_RES_PROCESS_SESSIONS,
		"BatchAccountResolutionPlugInProcessSessionsDelta",
		"BatchAccountResolution::PlugInProcessSessions Delta",
		"Difference in ms. between the total time spent in the most recent batch through account resolution and batch preceding it",
		PERF_COUNTER_DELTA, -1 },

	{ SharedStats::ACCT_RES_SQL_EXECUTE,
		"BatchAccountResolutionSQLExecute",
		"BatchAccountResolution::SQLExecute",
		"Time in ms. spent in SQLExecute for last batch of sessions through account resolution",
		PERF_COUNTER_RAWCOUNT, -1 },

	{ SharedStats::ACCT_RES_FETCH,
		"BatchAccountResolutionFetch",
		"BatchAccountResolution::Fetch",
		"Time in ms. spent in fetch for last batch of sessions through account resolution",
		PERF_COUNTER_RAWCOUNT, -1 },


	// 
	// BatchPILookup timings
	// 
	{ SharedStats::PILOOKUP_PROCESS_SESSIONS,
		"BatchPILookupPlugInProcessSessions",
		"BatchPILookup::PlugInProcessSessions",
		"Total execution time (ms) for last batch of sessions through PILookup",
		PERF_COUNTER_RAWCOUNT, -1 },

	{ SharedStats::PILOOKUP_PROCESS_SESSIONS,
		"BatchPILookupPlugInProcessSessionsDelta",
		"BatchPILookup::PlugInProcessSessions Delta",
		"Difference in time (ms) between the the last two batches of sessions through PILookup",
		PERF_COUNTER_DELTA, -1 },

	{ SharedStats::PILOOKUP_SQL_EXECUTE,
		"BatchPILookupSQLExecute",
		"BatchPILookup::SQLExecute",
		"Execution time (ms) for the main PILookup SQL query for the last batch of sessions",
		PERF_COUNTER_RAWCOUNT, -1 },

	{ SharedStats::PILOOKUP_FETCH,
		"BatchPILookupFetch",
		"BatchPILookup::Fetch",
		"Execution time (ms) spent in fetch for last batch of sessions through PILookup",
		PERF_COUNTER_RAWCOUNT, -1 },


	//
	// queueing enabled flag
	//
	{ SharedStats::QUEUEING_ENABLED_FLAG,
		"QueueingEnabledFlag",
		"Queueing enabled",
		"Set to 1 when the messages can be sent to the routing queue and 0 they can't.",
		PERF_COUNTER_RAWCOUNT, -1 },


	//
	// auditing flag
	//
	{ SharedStats::AUDIT_FLAG,
		"AuditFlag",
		"Audit flag",
		"Set to 1 when the pipeline is cleaning up completed sessions.",
		PERF_COUNTER_RAWCOUNT, -1 },

};

/****************************************** PipelineCounters ***/

BOOL PipelineCounters::Init()
{
	// initialize COM if it isn't already
	ComInitialize init;

	if (!mCapacity.Init())
	{
		SetError(mCapacity);
		return FALSE;
	}

	if (!mTMax.Init())
	{
		SetError(mCapacity);
		return FALSE;
	}

	if (!mTMin.Init())
	{
		SetError(mCapacity);
		return FALSE;
	}

	AddCounter(mCapacity);
	AddCounter(mCapacityBase);

	AddCounter(mTMax);
	AddCounter(mTMaxBase);

	AddCounter(mTMin);
	AddCounter(mTMinBase);

	if (!mPerfShare.Init())
	{
		SetError(mPerfShare);
		return FALSE;
	}

	const SharedStats & sharedStats = mPerfShare.GetReadOnlyStats();

	if (!mSessionsCounter.Init(sharedStats))
	{
		SetError(mSessionsCounter);
		return FALSE;
	}

	if (!mSessionsPerSec.Init(sharedStats))
	{
		SetError(mSessionsPerSec);
		return FALSE;
	}

	AddCounter(mSessionsCounter);
	AddCounter(mSessionsPerSec);

	int miscTimingCount = sizeof(miscTimings) / sizeof(miscTimings[0]);
	mMiscTimings.resize(miscTimingCount);

	for (int i = 0; i < miscTimingCount; i++)
	{
		const MiscTimingSetup & setup = miscTimings[i];
		MiscTiming & count = mMiscTimings[i];
		if (!count.Init(sharedStats,
										setup.timing,
										setup.internalName,
										setup.displayName,
										setup.helpText,
										setup.type,
										setup.defaultScale))
		{
			SetError(count);
			return FALSE;
		}

		AddCounter(count);
	}

	return TRUE;
}

/****************************************** DLL Entry Points ***/

PipelineCounters gCounters;


// necessary so we can snarf the HINSTANCE
HINSTANCE hDllInstance;

BOOL WINAPI DllMain(HINSTANCE hDLL, DWORD dwReason, LPVOID lpReserved)
{
	if(dwReason == DLL_PROCESS_ATTACH) {
		hDllInstance = hDLL;
	}
	return TRUE;
}

// the macro takes care of the work
DEFINE_PERF_ENTRIES(gCounters)
