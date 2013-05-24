/**************************************************************************
 * @doc MISCTIMING
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
 * @index | MISCTIMING
 ***************************************************************************/

#ifndef _MISCTIMING_H
#define _MISCTIMING_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include <perfmon.h>
#include <perfshare.h>

/********************************************* SessionsCount ***/

class MiscTiming : public PerfmonCounterImpl<DWORD>
{
public:
	MiscTiming();

	// initialize with the appropriate timer and the perfmon data.
	// NOTE: strings passed in are not copied!  they should be literals
	BOOL Init(const SharedStats & arStats,
						enum SharedStats::Timing aTiming,
						const char * apInternalName,
						const char * apDisplayName,
						const char * apHelpText,
						DWORD aType,
						int aDefaultScale);

protected:
	BOOL Collect(DWORD & arValue);

protected:
	virtual DWORD GetType() const
	{ return mType; }

	// override to change the default scale.  0 = 10^0 = 1, 1 = 10^1 = 10, etc
	virtual int DefaultScale() const
	{ return mDefaultScale; }

	// return the name displayed in perfmon
	const char * GetInternalName() const
	{ return mpInternalName; }

	// return the name displayed in perfmon
	const char * GetName() const
	{ return mpDisplayName; }

	// return the help text displayed in perfmon
	const char * GetHelpText() const
	{ return mpHelpText; }

private:
	const SharedStats * mpStats;

	enum SharedStats::Timing mTiming;

	const char * mpInternalName;
	const char * mpDisplayName;
	const char * mpHelpText;

	DWORD mType;
	int mDefaultScale;
};

#endif /* _MISCTIMING_H */
