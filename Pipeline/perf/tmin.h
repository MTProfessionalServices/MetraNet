/**************************************************************************
 * @doc TMIN
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
 * @index | TMIN
 ***************************************************************************/

#ifndef _TMIN_H
#define _TMIN_H

#include <perfmon.h>

#include <sharedsess.h>

/*************************************** PipelineTMinCounter ***/

class PipelineTMinCounter : public PerfmonFraction
{
public:
	PipelineTMinCounter()
	{ }

	BOOL Init();

	// return the name displayed in perfmon
	const char * GetInternalName() const
	{ return "TMin"; }

	// return the name displayed in perfmon
	const char * GetName() const
	{ return "Min Threshold"; }

	// return the help text displayed in perfmon
	const char * GetHelpText() const
	{ return "Min flow control threshold."; }

protected:
	BOOL Collect(DWORD & arValue);

private:
	SharedSessionHeader * mpHeader;
	SharedSessionMappedViewHandle mMappedView;

	int mTMin;
};

/*********************************** PipelineTMinBaseCounter ***/

class PipelineTMinBaseCounter : public PerfmonBase
{
protected:
	BOOL Collect(DWORD & arValue);

	// return the name displayed in perfmon
	const char * GetInternalName() const
	{ return "TMin"; }

	// return the name displayed in perfmon
	const char * GetName() const
	{ return "Min Threshold"; }

	// return the help text displayed in perfmon
	const char * GetHelpText() const
	{ return "Min flow control threshold."; }
};



#endif /* _TMIN_H */
