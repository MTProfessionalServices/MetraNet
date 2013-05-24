/**************************************************************************
 * @doc STOPEVENT
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
 * @index | STOPEVENT
 ***************************************************************************/

#ifndef _STOPEVENT_H
#define _STOPEVENT_H

#include <observedevent.h>

class PipelineStopEvent : public ObservedEvent
{
public:
	BOOL Init();
};

class PipelineStopEventObserver : public EventObserver
{
public:
	virtual void EventOccurred()
	{ PipelineStop(); }

public:
	virtual void PipelineStop() = 0;
};

class PipelineStopEventObservable : public EventObservable
{
public:
	BOOL Init();

	void AddObserver(PipelineStopEventObserver & arObserver);
};


#endif /* _STOPEVENT_H */
