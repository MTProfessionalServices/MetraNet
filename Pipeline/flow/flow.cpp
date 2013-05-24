/**************************************************************************
 * @doc FLOW
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
 ***************************************************************************/

#include <metra.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#include <flow.h>

#include <loggerconfig.h>
#include <makeunique.h>

PipelineFlowControl::PipelineFlowControl()
	: mpMappedView(NULL),
		mpHeader(NULL)
{ }

PipelineFlowControl::~PipelineFlowControl()
{
	if (mpMappedView)
	{
		delete mpMappedView;
		mpMappedView = NULL;
	}
	mpHeader = NULL;
}


BOOL PipelineFlowControl::Init(MTPipelineLib::IMTSessionServerPtr aSessionServer, double aTMin,
															 double aTMax, double aTRejection)
{
	const char * functionName = "PipelineFlowControl::Init";

	LoggerConfigReader configReader;
	if (!mLogger.Init(configReader.ReadConfiguration("logging"), "[flow]"))
	{
		SetError(mLogger);
		return FALSE;
	}

	mSessionThresholdMax = aTMax;
	mSessionThresholdMin = aTMin;
	mSessionThresholdRejection = aTRejection;
	

	mLogger.LogVarArgs(LOG_DEBUG, "Rejection threshold = %.3f%%.",
										 mSessionThresholdRejection * 100.0);
	mLogger.LogVarArgs(LOG_DEBUG, "Max threshold = %.3f%%.",
										 mSessionThresholdMax * 100.0);
	mLogger.LogVarArgs(LOG_DEBUG, "Min threshold = %.3f%%.",
										 mSessionThresholdMin * 100.0);

	mSessionServer = aSessionServer;

	//
	// create a named event that will be signalled we can accept messages,
	// and not signalled when the pipeline is operating at capacity
	//

	// what's the current capacity?
	double cap = mSessionServer->GetPercentUsed();
	BOOL accept = (cap < mSessionThresholdMin);

	if (accept)
	{
		mLogger.LogVarArgs(LOG_DEBUG, "Starting with %.3f%% used.  "
											 "New sessions accepted.",
											 cap * 100.0);
	}
	else
	{
		mLogger.LogVarArgs(LOG_WARNING, "%.3f%% used at startup. "
											 " No new sessions accepted.",
											 cap * 100.0);
	}

	mAcceptSessions = ::CreateEvent(NULL,// security
																	TRUE, // manually reset
																	accept, // initial state
																	GetEventName());
	if (mAcceptSessions == NULL)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}

const wchar_t * PipelineFlowControl::GetEventName()
{
	// return it if we already know it
	if (mEventName.length() > 0)
		return mEventName.c_str();

	// make it unique
	mEventName = L"MTFlowControlValve";
	MakeUnique(mEventName);
	// make this globally unique across terminal services sessions.
	mEventName.insert(0, L"Global\\");

	return mEventName.c_str();
}

BOOL PipelineFlowControl::CanAcceptSessions()
{
	DWORD waitRes = ::WaitForSingleObject(mAcceptSessions, 0);
	return (waitRes == WAIT_OBJECT_0);
}

HANDLE PipelineFlowControl::GetAcceptSessionsEvent() const
{
	return mAcceptSessions;
}


BOOL PipelineFlowControl::StartAcceptingSessions()
{
	const char * functionName = "PipelineFlowControl::StartAcceptingSessions";

	if (!::SetEvent(mAcceptSessions))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
	return TRUE;
}

BOOL PipelineFlowControl::StopAcceptingSessions()
{
	const char * functionName = "PipelineFlowControl::StopAcceptingSessions";

	if (!::ResetEvent(mAcceptSessions))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
	return TRUE;
}

BOOL PipelineFlowControl::ReevaluateFlow(double * capacity)
{
	double cap = mSessionServer->GetPercentUsed();

  if (capacity)
  {
    *capacity = cap;
  }

	// NOTE: printfs are useful for debugging but commented out in production

	BOOL result = TRUE;
	if (CanAcceptSessions())
	{
		// if we're currently accepting sessions and we've hit capacity, stop accepting
		// more sessions.
		if (cap > mSessionThresholdMax)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "%.3f%% used. Pausing the flow of sessions.",
												 cap * 100.0);
			result = StopAcceptingSessions();

			//fprintf(stderr, "Pausing flow: %.3f%% used\n", cap * 100.0);
		}
	}
	else
	{
		// if we're not accepting sessions we've dropped below the lower threshold,
		// start accepting sessions again.
		if (cap < mSessionThresholdMin)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "%.3f%% used. "
												 "Starting to accept sessions again.",
												 cap * 100.0);
			result = StartAcceptingSessions();

			//fprintf(stderr, "Starting flow: %.3f%% used\n", cap * 100.0);
		}
		else
		{
			//fprintf(stderr, "Still not accepting: %.3f%% used\n", cap * 100.0);
		}
	}

	return result;
}


BOOL PipelineFlowControl::InitMappedView(PipelineInfo & arPipelineInfo)
{
	const char * functionName = "PipelineFlowControl::InitMappedView";

	if (mpMappedView)
		return TRUE;

	mpMappedView = new SharedSessionMappedViewHandle;

	std::string shareName = arPipelineInfo.GetShareName();
	MakeUnique(shareName);
	DWORD err = mpMappedView->Open(arPipelineInfo.GetSharedSessionFile().c_str(),
																 shareName.c_str(),
																 arPipelineInfo.GetSharedFileSize(), FALSE);

	if (err != NO_ERROR) {
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName, 
						 "Couldn't open SharedSessionMappedViewHandle");
		delete mpMappedView;
		mpMappedView = NULL;
		return FALSE;
	}

	long spaceAvail = mpMappedView->GetAvailableSpace() - sizeof(SharedSessionHeader);

	mpHeader =
		SharedSessionHeader::Initialize(
			*mpMappedView, mpMappedView->GetMemoryStart(),
			spaceAvail / 5,
			spaceAvail / 5,
			spaceAvail / 5,
			spaceAvail / 5,
			spaceAvail / 5,
			FALSE);

	if (!mpHeader)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName, 
						 "Unable to init shared memory");
		delete mpMappedView;
		mpMappedView = NULL;
		return FALSE;
	}
	return TRUE;
}

//determines if there will be an overflow condition in the shared
//memory file based on the property count tallied in the listener.
// return TRUE on success/FALSE on error.
BOOL PipelineFlowControl::IsOverflow(PipelineInfo & arPipelineInfo, 
																		 PropertyCount & arPropCount,
																		 BOOL & overflow)
{
	const char * functionName = "PipelineFlowControl::isOverflow";

	overflow = TRUE;

	if (!mpMappedView)
	{
		if (!InitMappedView(arPipelineInfo))
			return FALSE;
	}

	BOOL bOverflow = FALSE;

	if (!mpMappedView->WaitForAccess(5000))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName, 
						 "Could not gain access to mutex");
		return FALSE;
	}

	FixedSizePoolStats stats;

  //the capacity of a given pool multipied by the maximum threshold
	unsigned effectiveMax; 

	//checks the prop pool
	mpHeader->GetPropPoolStats(stats);
	effectiveMax = (unsigned) (stats.mSize * mSessionThresholdRejection);
	mLogger.LogVarArgs(LOG_DEBUG, "Checking for total prop overflow: current(%d) + new(%d) < effectiveMax(%d).  absoluteMax(%d)",
										 stats.mCurrentlyAllocated, arPropCount.total, effectiveMax, stats.mSize);
  if (stats.mCurrentlyAllocated + arPropCount.total >= effectiveMax)
		bOverflow = TRUE;


	//checks the small string prop pool
	mpHeader->GetSmallStringPoolStats(stats);
	effectiveMax = (unsigned) (stats.mSize * mSessionThresholdRejection);
	mLogger.LogVarArgs(LOG_DEBUG, "Checking for small string overflow: current(%d) + new(%d) < effectiveMax(%d).  absoluteMax(%d)",
										 stats.mCurrentlyAllocated, arPropCount.smallStr, effectiveMax, stats.mSize);
  if (stats.mCurrentlyAllocated + arPropCount.smallStr >= effectiveMax)
		bOverflow = TRUE;

	//checks the medium string prop pool
	mpHeader->GetMediumStringPoolStats(stats);
	effectiveMax = (unsigned) (stats.mSize * mSessionThresholdRejection);
	mLogger.LogVarArgs(LOG_DEBUG, "Checking for medium string overflow: current(%d) + new(%d) < effectiveMax(%d).  absoluteMax(%d)",
										 stats.mCurrentlyAllocated, arPropCount.mediumStr, effectiveMax, stats.mSize);
  if (stats.mCurrentlyAllocated + arPropCount.mediumStr >= effectiveMax)
		bOverflow = TRUE;

	//checks the large string prop pool
	mpHeader->GetLargeStringPoolStats(stats);
	effectiveMax = (unsigned) (stats.mSize * mSessionThresholdRejection);
	mLogger.LogVarArgs(LOG_DEBUG, "Checking for large string overflow: current(%d) + new(%d) < effectiveMax(%d).  absoluteMax(%d)",
										 stats.mCurrentlyAllocated, arPropCount.largeStr, effectiveMax, stats.mSize);
  if (stats.mCurrentlyAllocated + arPropCount.largeStr >= effectiveMax)
		bOverflow = TRUE;

	//releases the mutex
	mpMappedView->ReleaseAccess();

	//if there will be an overflow condition then return true
	if (bOverflow) {
		mLogger.LogVarArgs(LOG_DEBUG, "Overflow condition detected!");
		overflow = TRUE;
		return TRUE;
	} else 
	{
		overflow = FALSE;
		return TRUE;
	}
}
