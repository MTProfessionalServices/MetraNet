/**************************************************************************
 * @doc CLEARQUEUES
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

#include <mtcom.h>
#import <MTConfigLib.tlb>
#include <HookSkeleton.h>
#include <mtprogids.h>
#include <ConfigDir.h>
#include <msmqlib.h>
#include <makeunique.h>

#import <MTConfigLib.tlb>

#include <pipelineconfig.h>


// generate using uuidgen

CLSID CLSID_ClearQueues = { /* d3ebd190-1d1d-11d4-a403-00c04f484788 */
    0xd3ebd190,
    0x1d1d,
    0x11d4,
    {0xa4, 0x03, 0x00, 0xc0, 0x4f, 0x48, 0x47, 0x88}
  };


class ATL_NO_VTABLE ClearQueues :
  public MTHookSkeleton<ClearQueues,&CLSID_ClearQueues>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var, long* pVal);


private:
	HRESULT ClearStageQueues();
};

HOOK_INFO(CLSID_ClearQueues, ClearQueues,
						"MetraHook.PipelineClearQueues.1", "MetraHook.PipelineClearQueues", "free")


HRESULT ClearQueues::ExecuteHook(VARIANT var, long* pVal)
{
	ASSERT(pVal);
	if (!pVal)
		return E_POINTER;

	enum
	{
		PIPELINE_STARUP = 1,
		PIPELINE_SHUTDOWN = 2,
	};

	try
	{
		if (*pVal == PIPELINE_STARUP)
			mLogger.LogThis(LOG_DEBUG, "ClearQueues hook running during startup");
		else
			mLogger.LogThis(LOG_DEBUG, "ClearQueues hook running during shutdown");

		return ClearStageQueues();
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

  return S_OK;
}


HRESULT ClearQueues::ClearStageQueues()
{
	//
	// read the main pipeline configuration file
	//

	std::string configDir;
	if (!GetMTConfigDir(configDir))
		return Error("No configuration directory found");

	mLogger.LogThis(LOG_DEBUG, "Reading pipeline configuration file");
	PipelineInfoReader pipelineReader;
	// TODO: have to convert from one namespace to another
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	PipelineInfo pipelineInfo;
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		mLogger.LogErrorObject(LOG_ERROR, pipelineReader.GetLastError());
		return Error("Unable to read pipeline.xml configuration file");
	}

	StageList & stages = pipelineInfo.GetStages();
	StageList::const_iterator it;
	for (it = stages.begin(); it != stages.end(); ++it)
	{
		const StageIDAndName & stageInfo = *it;
		mLogger.LogVarArgs(LOG_DEBUG, "Clearing queue of stage %s",
											 stageInfo.mStageName.c_str());

		MessageQueue queue;

		std::wstring queueName;
		ASCIIToWide(queueName, stageInfo.mStageName);
		queueName += L"Queue";
		MakeUnique(queueName);
		if (!queue.Init(queueName.c_str(), pipelineInfo.UsePrivateQueues())
				|| !queue.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE))
		{
			//SetError(queue);
			mLogger.LogVarArgs(LOG_ERROR, "Unable to clear queue for stage %s",
												 stageInfo.mStageName.c_str());
			mLogger.LogErrorObject(LOG_ERROR, queue.GetLastError());
		}		
			// NOTE: we continue here even though we failed to clear the queue

		else
		{
			QueueMessage receiveme;
			receiveme.SetAppSpecificLong(0);
			while(queue.Receive(receiveme, 0))
			{};
			queue.Close();
		}
		//	continue;
	}

	return S_OK;
}
