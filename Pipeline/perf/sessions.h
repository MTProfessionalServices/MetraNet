/**************************************************************************
 * @doc SESSIONS
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
 * @index | SESSIONS
 ***************************************************************************/

#ifndef _SESSIONS_H
#define _SESSIONS_H

#include <perfmon.h>
#include <perfshare.h>

/********************************************* SessionsCount ***/

class SessionsCount : public PerfmonCounterImpl<DWORD>
{
public:
	SessionsCount();

	BOOL Init(const SharedStats & arStats);
protected:
	BOOL Collect(DWORD & arValue);

private:
	const SharedStats * mpStats;

	int mSessionCount;
};


/************************************* SessionsPerSecCounter ***/

class SessionsPerSecCounter : public SessionsCount
{
public:
	// return the name displayed in perfmon
	const char * GetInternalName() const
	{ return "SessionsPerSec"; }

	// return the name displayed in perfmon
	const char * GetName() const
	{ return "Sessions/sec"; }

	// return the help text displayed in perfmon
	const char * GetHelpText() const
	{ return "Number of sessions/transactions processed per second."; }

protected:
	virtual DWORD GetType() const
	{ return PERF_COUNTER_COUNTER; }

	// override to change the default scale.  0 = 10^0 = 1, 1 = 10^1 = 10, etc
	virtual int DefaultScale() const
	{ return 4; }
};

/******************************************* SessionsCounter ***/

class SessionsCounter : public SessionsCount
{
public:
	// return the name displayed in perfmon
	const char * GetInternalName() const
	{ return "Sessions"; }

	// return the name displayed in perfmon
	const char * GetName() const
	{ return "Sessions"; }

	// return the help text displayed in perfmon
	const char * GetHelpText() const
	{ return "Number of sessions (transactions) processed."; }

protected:
	virtual DWORD GetType() const
	{ return PERF_COUNTER_RAWCOUNT; }

	// override to change the default scale.  0 = 10^0 = 1, 1 = 10^1 = 10, etc
	virtual int DefaultScale() const
	{ return 4; }

};



#endif /* _SESSIONS_H */
