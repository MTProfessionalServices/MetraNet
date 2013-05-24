/**************************************************************************
 * @doc PIPESVC
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
 * @index | PIPESVC
 ***************************************************************************/

#ifndef _PIPESVC_H
#define _PIPESVC_H

#include <stopevent.h>
#include <PipelineApplication.h>
// services
#include <route.h>
#include <audit.h>
#include <queueflag.h>
#include <restart.h>

/************************************ PipelineServicesParams ***/

class PipelineServicesParams
{
public:
	PipelineServicesParams();

	BOOL StartRouter() const
	{ return mStartRouter; }

	BOOL StartAuditor() const
	{ return mStartAuditor; }

private:
	BOOL mStartRouter;
	BOOL mStartAuditor;
};

/********************************************* RouterService ***/

class RouterService :
	public SessionRouter
{
public:
	// mainrouter flag is true for routingqueue, false
	// for resubmit queue
	BOOL Init(BOOL aMainRouter, const char * apConfigDir,
						const PipelineInfo & arInfo);

	BOOL RoutingConfigured() const;

	BOOL UsePrivateQueues() const
	{ return mUsePrivateQueues; }

private:
	BOOL mRoutingConfigured;

	BOOL mUsePrivateQueues;
};

/****************************************** PipelineServices ***/
	
class PipelineServices
	: public virtual ObjectWithError,
		public PipelineStopEventObserver,
    public PipelineApplication
{
public:
	int Run();

	void SetMaxSessionsRouted(int aMax)
	{ mRouter.SetMaxSessions(aMax); }

	void SetMaxAudits(int aMax)
	{ mAuditor.SetMaxAudits(aMax); }

public:
	// called when pipeline stops.. this shuts down the service
	virtual void PipelineStop();

private:
	BOOL SendReadyMessage();

	BOOL FreeMemory();

private:
	// services
	RouterService mRouter;

	RouterService mResubmitRouter;

	// "suspended transaction" restart service
	RestartService mSessionRestart;

	MTAuditor mAuditor;
	
	QueueFlag mQueueFlag;
private:
	// startup parameters
	PipelineServicesParams mParams;

	// if true, use private queues
	BOOL mUsePrivateQueues;

	NTLogger mLogger;

	// stop event signal
	PipelineStopEventObservable mStopObservable;
};


#endif /* _PIPESVC_H */
