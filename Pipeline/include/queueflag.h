/**************************************************************************
 * @doc QUEUEFLAG
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
 * @index | QUEUEFLAG
 ***************************************************************************/

#ifndef _QUEUEFLAG_H
#define _QUEUEFLAG_H

#include <NTThreader.h>
#include <autohandle.h>
#import <MTConfigLib.tlb>
#include <pipelineconfig.h>
#include <errobj.h>
#include <autologger.h>
#include <queueflaglogging.h>
#include <perfshare.h>

#include <queuesize.h>

class QueueFlag : public NTThreader, public virtual ObjectWithError
{
public:
	QueueFlag();
	virtual ~QueueFlag();

	// loop forever, polling the queue size and setting the event
	// appropriately every three seconds.
	virtual int ThreadMain();

	// stop the thread
	void Stop();

	// initialize only to call WaitToSend
	BOOL Init();

	// setup the thread that sets/clear the event
	BOOL Init(const PipelineInfo & arPipelineInfo);

	// override the max size (normally initialized in Init)
	void SetMaxSize(int aSize)
	{ mSize = aSize; }

public:
	// wait at most a given number of milliseconds until the
	// queue is at an acceptable level for receiving messages
	BOOL WaitToSend(int aTimeout);

private:
	// returns true if clients are currently allowed to send to the queue
	BOOL CanQueue();

	// set the event indicating the queue is ready for messages
	void EnableQueue();

	// reset the event indicating the queue is ready for messages
	void DisableQueue();

private:
	MTAutoInstance<MTAutoLoggerImpl<gQueueFlagLoggingMessage> > mLogger;

	// if we get larger than this, stop accepting messages
	int mSize;

	// if we get lower than this, start accepting messages again
	int mLowerSize;

	AutoHANDLE mEvent;

	QueueSize mQueueSize;

private:
 // perfmon instrumentation
 PerfShare mPerfShare;
 SharedStats * mpStats;
};


#endif /* _QUEUEFLAG_H */
