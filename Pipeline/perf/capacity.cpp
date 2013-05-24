/**************************************************************************
 * @doc CAPACITY
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
#include <capacity.h>
#include <mtprogids.h>
#import <MTConfigLib.tlb>
#include <pipelineconfig.h>
#include <mtcomerr.h>
using namespace MTConfigLib;
#include <MTUtil.h>
#include <ConfigDir.h>
#include <makeunique.h>

#import <SessServer.tlb> rename("EOF", "RowsetEOF")
using namespace SESSSERVERLib;

/*********************************** PipelineCapacityCounter ***/

BOOL PipelineCapacityCounter::Init()
{
	const char * functionName = "PipelineCapacityCounter::Collect";

	PipelineInfo pipelineInfo;

	
	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		SetError(FALSE, ERROR_MODULE, ERROR_LINE, functionName,"Unable to read configuration directory");
		return FALSE;
	}


	try
	{
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

		PipelineInfoReader reader;
		ASSERT(configDir.length() != 0);
		if (!reader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
		{
			SetError(FALSE,ERROR_MODULE, ERROR_LINE, functionName,"Unable to read pipeline configuration");
			return FALSE;
		}
	}
	catch (_com_error & err)
	{
		SetError(err.Error(),ERROR_MODULE, ERROR_LINE, functionName,"Unable to read pipeline configuration");
		return FALSE;
	}


	std::string shareName = pipelineInfo.GetShareName();
	MakeUnique(shareName);

	// make this globally unique across terminal services sessions.
	shareName.insert(0, "Global\\");

	DWORD err = mMappedView.Open(pipelineInfo.GetSharedSessionFile().c_str(),shareName.c_str(),pipelineInfo.GetSharedFileSize(), FALSE);

	if (err != NO_ERROR)
	{
		SetError(err, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// create an instance of the SessionServer object and initialize the shared memory
	IMTSessionServerPtr aServer;
	HRESULT hr = aServer.CreateInstance(MTPROGID_SESSION_SERVER);
	if(aServer == NULL) {
		SetError( hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	try {
		aServer->Init((const char*)pipelineInfo.GetSharedSessionFile().c_str(),(const char*)pipelineInfo.GetShareName().c_str(),pipelineInfo.GetSharedFileSize());
	}
	catch(_com_error& err) {
		SetError(CreateErrorFromComError(err));
		return FALSE;
	}

	mpHeader = SharedSessionHeader::Open(mMappedView);
	if (!mpHeader)
		return FALSE;

	return TRUE;
}

BOOL PipelineCapacityCounter::Collect(DWORD & arValue)
{
	const char * functionName = "PipelineCapacityCounter::Collect";

	if (!mMappedView.WaitForAccess(1000) != NULL)
	{
		SetError(ERROR_TIMEOUT, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	//
	// return the percentage filled of the most filled pool
	//
	double mostFilled = 0;
	double cap;

	FixedSizePoolStats stats;

	// session pool
	mpHeader->GetSessionPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// property pool
	mpHeader->GetPropPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// set pool
	mpHeader->GetSetPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// set node pool
	mpHeader->GetSetNodePoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// small string pool
	mpHeader->GetSmallStringPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// medium string pool
	mpHeader->GetMediumStringPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// large string pool
	mpHeader->GetLargeStringPoolStats(stats);
	cap = double(stats.mCurrentlyAllocated) / double(stats.mSize);
	if (cap > mostFilled)
		mostFilled = cap;

	// it will be a percentage
	arValue = int(mostFilled * 100);


	// releasing the mutex is critical!
	mMappedView.ReleaseAccess();

#if 0
	arValue = mCounter;
	mCounter = (mCounter + 1) % 100;
#endif

	return TRUE;
}

/******************************* PipelineCapacityBaseCounter ***/

BOOL PipelineCapacityBaseCounter::Collect(DWORD & arValue)
{
	// percentages are always over 100
	arValue = 100;

	return TRUE;
}
