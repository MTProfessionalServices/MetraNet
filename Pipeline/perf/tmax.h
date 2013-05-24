/**************************************************************************
 * @doc TMAX
 *
 * @module |
 *
 *
 * Copyright 2000 by MetraTech Corporation
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
 * @index | TMAX
 ***************************************************************************/

#ifndef _TMAX_H
#define _TMAX_H

#include <perfmon.h>

#include <sharedsess.h>

/*************************************** PipelineTMaxCounter ***/

class PipelineTMaxCounter : public PerfmonFraction
{
public:
	PipelineTMaxCounter()
	{ }

	BOOL Init();

	// return the name displayed in perfmon
	const char * GetInternalName() const
	{ return "TMax"; }

	// return the name displayed in perfmon
	const char * GetName() const
	{ return "Max Threshold"; }

	// return the help text displayed in perfmon
	const char * GetHelpText() const
	{ return "Max flow control threshold."; }

protected:
	BOOL Collect(DWORD & arValue);

private:
	SharedSessionHeader * mpHeader;
	SharedSessionMappedViewHandle mMappedView;

//	int mCounter;

	int mTMax;
};

/*********************************** PipelineTMaxBaseCounter ***/

class PipelineTMaxBaseCounter : public PerfmonBase
{
protected:
	BOOL Collect(DWORD & arValue);

	// return the name displayed in perfmon
	const char * GetInternalName() const
	{ return "TMax"; }

	// return the name displayed in perfmon
	const char * GetName() const
	{ return "Max Threshold"; }

	// return the help text displayed in perfmon
	const char * GetHelpText() const
	{ return "Max flow control threshold."; }
};



#endif /* _TMAX_H */
