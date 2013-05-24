/**************************************************************************
 * TMAX
 *
 * Copyright 1997-2000 by MetraTech Corp.
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
#include <tmax.h>
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

/*************************************** PipelineTMaxCounter ***/

BOOL PipelineTMaxCounter::Init()
{
	const char * functionName = "PipelineTMaxCounter::Collect";

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

	mTMax = pipelineInfo.GetThresholdMax();

	return TRUE;
}

BOOL PipelineTMaxCounter::Collect(DWORD & arValue)
{
	const char * functionName = "PipelineTMaxCounter::Collect";

	arValue = mTMax;

	return TRUE;
}

/*********************************** PipelineTMaxBaseCounter ***/

BOOL PipelineTMaxBaseCounter::Collect(DWORD & arValue)
{
	// percentages are always over 100
	arValue = 100;

	return TRUE;
}

