/**************************************************************************
 * @doc UTILS
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
#include <mtcom.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTConfigLib.tlb"

#include <stage.h>
#include <pipelineconfig.h>
#include <pipeconfigutils.h>
#include <stageconfig.h>
#include <mtprogids.h>

#include <stdutils.h>

#include <ConfigDir.h>

#include <set>
#include <algorithm>
using std::set;
using std::copy;

typedef set<RoutingQueueInfo> RoutingQueueSet;

/****************************************** RoutingQueueInfo ***/

RoutingQueueInfo::RoutingQueueInfo(const wchar_t * apMachine,
																	 const wchar_t * apQueue)
	: mMachineName(apMachine), mQueueName(apQueue)
{ }

RoutingQueueInfo::RoutingQueueInfo(const RoutingQueueInfo & arOther)
{
	*this = arOther;
}

RoutingQueueInfo & RoutingQueueInfo::operator = (const RoutingQueueInfo & arOther)
{
	mMachineName = arOther.GetMachineName();
	mQueueName = arOther.GetQueueName();
	return *this;
}

bool RoutingQueueInfo::operator < (const RoutingQueueInfo & arQueueInfo) const
{
	std::wstring key1(GetMachineName());
	key1 += L":";
	key1 += GetQueueName();
	StrToLower(key1);


	std::wstring key2(arQueueInfo.GetMachineName());
	key2 += L":";
	key2 += arQueueInfo.GetQueueName();
	StrToLower(key2);

	return key1 < key2;
}

bool RoutingQueueInfo::operator == (const RoutingQueueInfo & arQueueInfo) const
{
	return (0 == strcasecmp(arQueueInfo.GetMachineName(), GetMachineName())
					&& 0 == strcasecmp(arQueueInfo.GetQueueName(), GetQueueName()));
}

/*************************************************** globals ***/

BOOL GetAllRoutingQueues(RoutingQueueList & arQueueList,
												 ErrorObject & arError)
{
	const char * apFunctionName = "GetAllRoutingQueues";

	// get config dir
	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		arError = ErrorObject(::GetLastError(), ERROR_MODULE, ERROR_LINE,
													apFunctionName);
		arError.GetProgrammerDetail() = "Cannot read configuration directory";
		return FALSE;
	}

	// read pipeline config file
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	PipelineInfo pipeInfo;
	PipelineInfoReader reader;
	if (!reader.ReadConfiguration(config, configDir.c_str(), pipeInfo))
	{
		arError = *reader.GetLastError();
		return FALSE;
	}

	RoutingQueueSet queueSet;

	// TODO: for now, add the single queue from pipeline.xml
	//       in the future, add a list of routing queues from this file
	if (pipeInfo.GetOneRoutingQueueName().length() > 0)
	{
		RoutingQueueInfo queueInfo((pipeInfo.GetOneRoutingQueueMachine()).c_str(),
															 (pipeInfo.GetOneRoutingQueueName()).c_str());

		queueSet.insert(queueInfo);
	}

	// for each stage, add the routing queue if there is one
	MTPipelineLib::IMTConfigPtr pipeConfig(MTPROGID_CONFIG);

	StageList::const_iterator it;
	const StageList & stages = pipeInfo.GetStages();
	for (it = stages.begin(); it != stages.end(); ++it)
	{
		const StageIDAndName & stage = *it;
		StageInfo stageInfo;

		StageInfoReader stageReader;
		if (!stageReader.ReadConfiguration(pipeConfig,stage.mFullStageXmlPath.c_str(),
																			 stageInfo))
		{
			arError = *stageReader.GetLastError();
			return FALSE;
		}

		if (stageInfo.RoutesMessages())
		{
			std::wstring wideMachine;
			ASCIIToWide(wideMachine, stageInfo.GetRouteFromMachine().c_str(),
									stageInfo.GetRouteFromMachine().length());
			std::wstring wideQueue;
			ASCIIToWide(wideQueue, stageInfo.GetRouteFromQueue().c_str(),
									stageInfo.GetRouteFromQueue().length());

			// stage does routing - add the info
			RoutingQueueInfo queueInfo(wideMachine.c_str(), wideQueue.c_str());
			
			queueSet.insert(queueInfo);
		}
	}

	RoutingQueueInfo queueInfo(pipeInfo.GetResubmitQueueMachine().c_str(),
														 pipeInfo.GetResubmitQueueName().c_str());
	queueSet.insert(queueInfo);

	// only return unique queues
	RoutingQueueSet::const_iterator copyit;
	for (copyit = queueSet.begin(); copyit != queueSet.end(); copyit++)
		arQueueList.push_back(*copyit);

	return TRUE;
}
