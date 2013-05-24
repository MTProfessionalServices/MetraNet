/**************************************************************************
 * @doc OBSERVEDEVENT
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
 * @index | OBSERVEDEVENT
 ***************************************************************************/

#ifndef _OBSERVEDEVENT_H
#define _OBSERVEDEVENT_H

#include <NTThreadLock.h>
#include <MTObserver.h>
#include <NTThreader.h>

#include <errobj.h>

class ObservedEvent
	: public virtual ObjectWithError
{
public:
	ObservedEvent();
	virtual ~ObservedEvent();

	BOOL Init(const char * EventName);

	HANDLE GetEvent() const;

	BOOL Signal();

	operator HANDLE () const
	{ return GetEvent(); }

private:

	// NT event handle for the event signalling that the configuration has changed
	HANDLE mObservedEvent;
};


class EventObserver
{
public:
	// Implement this method to take an appropriate action when the configuration
	// has changed.  Normally this means reloading your configuration files and
	// reparsing them.  All other configuration should be reread as well (registry, etc).
	virtual void EventOccurred() = 0;

private:
	friend MTObservable<EventObserver, void>;
	void Update(MTObservable<EventObserver, void> & arObservable, void * apArg);

	BOOL operator == (const EventObserver & arObserver) const
	{ return this == &arObserver; }
};


class EventObservable
	: private MTObservable<EventObserver, void>,
		public virtual ObjectWithError,
		public NTThreader
{
public:
	virtual ~EventObservable();

	// initialize the class to listen for the event
	BOOL Init(const char * EventName);

	void AddObserver(EventObserver & arObserver);

private:
	// thread to wait for the NT event signalling that the configuration has changed
	virtual int ThreadMain();

	// called by the thread waiting for the event to occur
	void ChangeSignalled();

private:

	// event that is signalled when a config change occurs
	ObservedEvent mEvent;
};



#endif /* _OBSERVEDEVENT_H */
