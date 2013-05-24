/**************************************************************************
 * @doc CAPACITY
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
 * @index | CAPACITY
 ***************************************************************************/

#ifndef _CAPACITY_H
#define _CAPACITY_H

#include <perfmon.h>

#include <sharedsess.h>

/*********************************** PipelineCapacityCounter ***/

class PipelineCapacityCounter : public PerfmonFraction
{
public:
	PipelineCapacityCounter()
		: mCounter(0)
	{ }

	BOOL Init();

	// return the name displayed in perfmon
	const char * GetInternalName() const
	{ return "PercentCapacity"; }

	// return the name displayed in perfmon
	const char * GetName() const
	{ return "% Usage"; }

	// return the help text displayed in perfmon
	const char * GetHelpText() const
	{ return "Current usage of shared memory, as a percentage."; }

protected:
	// store your counter value in memory and advance the
	// pointer past it.
	BOOL Collect(DWORD & arValue);

private:
	SharedSessionHeader * mpHeader;
	SharedSessionMappedViewHandle mMappedView;

	int mCounter;
};

/******************************* PipelineCapacityBaseCounter ***/

class PipelineCapacityBaseCounter : public PerfmonBase
{
protected:
	BOOL Collect(DWORD & arValue);

	// return the name displayed in perfmon
	const char * GetInternalName() const
	{ return "PercentCapacity"; }

	// return the name displayed in perfmon
	const char * GetName() const
	{ return "% Usage"; }

	// return the help text displayed in perfmon
	const char * GetHelpText() const
	{ return "Current usage of shared memory, as a percentage."; }
};


#endif /* _CAPACITY_H */
