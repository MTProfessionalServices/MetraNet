/**************************************************************************
 * @doc CONFIGCHANGE
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
 * @index | CONFIGCHANGE
 ***************************************************************************/

#ifndef _CONFIGCHANGE_H
#define _CONFIGCHANGE_H

#include <observedevent.h>

#define CONFIG_CHANGE_EVENT_NAME "MTConfigChangeEvent"
#define CONFIG_NEWSERVICEDEF_NAME "MTServiceDefChangeEvent"
#define CONFIG_NEWPV_EVENT_NAME "MTProductViewChangeEvent"

class ConfigChangeEvent : public ObservedEvent
{
public:
	BOOL Init();

	// TODO: not sure why this is necessary
	BOOL Init(const char * apEventName)
	{ return ObservedEvent::Init(apEventName); }
};

class ConfigChangeObserver : public EventObserver
{
public:
	virtual void EventOccurred()
	{ ConfigurationHasChanged(); }

public:
	virtual void ConfigurationHasChanged() = 0;
};

class ConfigChangeObservable : public EventObservable
{
public:
	BOOL Init();

	// TODO: not sure why this is necessary
	BOOL Init(const char * apEventName)
	{ return EventObservable::Init(apEventName); }

	void AddObserver(ConfigChangeObserver & arObserver);
};

#endif /* _CONFIGCHANGE_H */
