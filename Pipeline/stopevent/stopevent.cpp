/**************************************************************************
 * @doc STOPEVENT
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
 ***************************************************************************/

#include <metra.h>
#include <stopevent.h>

#define PIPELINE_STOP_EVENT_NAME "MTPipelineStopEvent"

BOOL PipelineStopEvent::Init()
{
	return ObservedEvent::Init(PIPELINE_STOP_EVENT_NAME);
}

BOOL PipelineStopEventObservable::Init()
{
	return EventObservable::Init(PIPELINE_STOP_EVENT_NAME);
}

void PipelineStopEventObservable::AddObserver(PipelineStopEventObserver & arObserver)
{
	EventObservable::AddObserver(arObserver);
}
