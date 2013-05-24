/**************************************************************************
 * @doc PERFOBJ
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
 * @index | PERFOBJ
 ***************************************************************************/

#ifndef _PERFOBJ_H
#define _PERFOBJ_H

#include <perfmon.h>
#include <perfshare.h>

#include "capacity.h"
#include "sessions.h"
#include "tmax.h"
#include "tmin.h"
#include "misctiming.h"

#include <vector>

/****************************************** PipelineCounters ***/

class PipelineCounters : public PerfmonObject
{
protected:
	virtual BOOL Init();

	virtual const char * GetInternalName() const
	{ return "Pipeline"; }

	virtual const char * GetName() const
	{ return "MetraTech Pipeline"; }


	virtual const char * GetHelpText() const
	{ return "MetraTech Pipeline"; }

private:
	PipelineCapacityCounter mCapacity;
	PipelineCapacityBaseCounter mCapacityBase;

	PipelineTMaxCounter mTMax;
	PipelineTMaxBaseCounter mTMaxBase;

	PipelineTMinCounter mTMin;
	PipelineTMinBaseCounter mTMinBase;

  SessionsCounter mSessionsCounter;
  SessionsPerSecCounter mSessionsPerSec;

	std::vector<MiscTiming> mMiscTimings;

	PerfShare mPerfShare;
};


DECLARE_PERF_ENTRIES();

#endif /* _PERFOBJ_H */
