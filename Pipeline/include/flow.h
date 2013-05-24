/**************************************************************************
 * @doc FLOW
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
 * @index | FLOW
 ***************************************************************************/

#ifndef _FLOW_H
#define _FLOW_H

#include <errobj.h>
#include <autohandle.h>
#include <NTLogger.h>

#import <MTConfigLib.tlb>
#include <pipelineconfig.h>
#include <pipemessages.h>
#include <sharedsess.h>

class SharedSessionMappedViewHandle;
class SharedSessionHeader;

class PipelineFlowControl : public ObjectWithError
{
public:
	PipelineFlowControl();
	virtual ~PipelineFlowControl();

	BOOL Init(MTPipelineLib::IMTSessionServerPtr aSessionServer,
						double aTMin, double aTMax, double aTRejection);

	// return TRUE if the "valve control" event shows that
	// we can accept sessions.
	BOOL CanAcceptSessions();

	// return the valve control event handle.
	HANDLE GetAcceptSessionsEvent() const;

	// signal the valve control to stop accepting sessions
	BOOL StopAcceptingSessions();

	// signal the valve control to start accepting sessions again
	BOOL StartAcceptingSessions();

	// called after the number of sessions in the pipeline
	// has changed.  This call can stop or restart sessions.
	BOOL ReevaluateFlow(double * capacity = NULL);

	// called just before a session is generated to ensure
	// that the shared memory file doesn't overflow
	BOOL IsOverflow(PipelineInfo & arPipelineInfo, 
									PropertyCount & arPropCount, BOOL & overflow);


private:
	const wchar_t * GetEventName();

	// called by IsOverflow to initialize the handle to shared memory
	BOOL InitMappedView(PipelineInfo & arPipelineInfo);

private:
	std::wstring mEventName;

	// event that is signalled when we can accept sessions
	AutoHANDLE mAcceptSessions;

	MTPipelineLib::IMTSessionServerPtr mSessionServer;

	double mSessionThresholdMax;
	double mSessionThresholdMin;
	double mSessionThresholdRejection;

	SharedSessionMappedViewHandle * mpMappedView;
	SharedSessionHeader * mpHeader;

	NTLogger mLogger;
};

#endif /* _FLOW_H */
