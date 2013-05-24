/**************************************************************************
 * @doc PIPESIGNAL
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
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
 * @index | PIPESIGNAL
 ***************************************************************************/

#ifndef _PIPESIGNAL_H
#define _PIPESIGNAL_H

/********************************************* PipelineEvent ***/

#define PIPELINE_EVENT_PREFIX "MetraTechPipelineEvent"
#define PIPELINE_EVENT_DEFAULT_TIMEOUT (5 * 1000)

class PipelineEvent : public virtual ObjectWithError
{
public:
	PipelineEvent();
	virtual ~PipelineEvent();

	// create the event and initialize the object
	BOOL Initialize(int aSuffix);

	BOOL Wait();
	BOOL Wait(DWORD aTimeout);
	BOOL WaitForever();

private:
	// NT event handle
	HANDLE mEventHandle;

	// numerical suffix used to generate the event name
	int mSuffix;

	// number of users in the current process waiting for the event
	int mLocalUsers;

	static const int mDefaultWait;
};

/****************************************** PipelineEventSet ***/

class PipelineEventSet : public virtual ObjectWithError
{
	PipelineEventSet();
	virtual ~PipelineEventSet();

public:
	BOOL Initialize(int aNumEvents);

private:
	PipelineEvent * mpEventArray;
};


#endif /* _PIPESIGNAL_H */
