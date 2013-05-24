/**************************************************************************
 * @doc PERFLOG
 *
 * @module |
 *
 *
 * Copyright 2002 by MetraTech Corporation
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
 * @index | PERFLOG
 ***************************************************************************/

#ifndef _PERFLOG_H
#define _PERFLOG_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

//
// interface used to profile the system
//

#if defined(PERF_LOG_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

// comment out this next line to remove all overhead of the performance log
#define MT_PERF_LOG


// NOTE: these are the real methods - use the macros below!
// return true if performance logging is on
extern "C"
{

// returns true if performance logging is active
DllExport bool PerfLogActive_();

// call when entering a piece of code that should appear in the perf log
DllExport void MarkEnterRegion_(const char * regionName, const char * arg = 0);

// call when exiting a piece of code that should appear in the perf log
DllExport void MarkExitRegion_(const char * regionName, const char * arg = 0);

};

#ifndef MT_PERF_LOG

// perf log is off
#define PerfLogActive() (false)

#define MarkEnterRegion(regionName)
#define MarkEnterRegion1(regionName, arg)

#define MarkExitRegion(regionName)
#define MarkExitRegion1(regionName, arg)

class MarkRegion
{
public:
	MarkRegion(const char * regionName, const char * arg = 0)
	{ }

	~MarkExitRegion()
	{ }
};

#else

// perf log is on
#define PerfLogActive() PerfLogActive_(false)

#define MarkEnterRegion(regionName) MarkEnterRegion_(regionName)
#define MarkEnterRegion1(regionName, arg) MarkEnterRegion_(regionName, arg)

#define MarkExitRegion(regionName) MarkExitRegion_(regionName)
#define MarkExitRegion1(regionName, arg) MarkExitRegion_(regionName, arg)

class MarkRegion
{
public:
	MarkRegion(const char * regionName, const char * arg = 0)
		: mpRegionName(regionName),
			mpArg(arg)
	{ MarkEnterRegion1(mpRegionName, mpArg); }

	~MarkRegion()
	{ MarkExitRegion1(mpRegionName, mpArg); }

private:
	const char * mpRegionName;
	const char * mpArg;
};

#endif

#endif /* _PERFLOG_H */
