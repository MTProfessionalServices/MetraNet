/**************************************************************************
 * @doc PIPELINEHOOKS
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

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping

#include <pipelinehooks.h>

#include <MTUtil.h>
#include <mtglobal_msg.h>
#include <mtprogids.h>

#include <ConfigDir.h>	

#include <string>


BOOL PipelineHooks::ReadHookFile(MTPipelineLib::IMTConfigPtr aConfig,
																 MTPipelineLib::IMTConfigPropSetPtr & arPropset)
{
	const char * functionName = "PipelineHooks::ReadHookFile";

	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to read configuration directory");
		return FALSE;
	}

	std::string file(configDir);
	file += "pipeline\\hooks\\hooks.xml";

	VARIANT_BOOL checksumMatch;
	arPropset =
		aConfig->ReadConfiguration(file.c_str(), &checksumMatch);

	return TRUE;
}


/*
 * Hooks
 */

#if 0
BOOL ExecutionGraph::InitializeHooks(MTPipelineLib::IMTConfigPtr aConfig)
{
	const char * functionName = "ExecutionGraph::InitializeHooks";

	mLogger.LogThis(LOG_DEBUG, "Initializing plug-in hooks");

	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to read configuration directory");
		return FALSE;
	}

	std::string file(configDir);
	file += "pipeline\\hooks\\hooks.xml";

	VARIANT_BOOL checksumMatch;
	MTPipelineLib::IMTConfigPropSetPtr propset =
		aConfig->ReadConfiguration(file.c_str(), &checksumMatch);


	// pipeline startup hooks
	if (!SetupHookHandler(propset, mStartupHookHandler,
												mStartupHooksRequired, "pipeline_startup"))
		return FALSE;

	// pipeline shutdown hooks
	if (!SetupHookHandler(propset, mShutdownHookHandler,
												mShutdownHooksRequired, "pipeline_shutdown"))
		return FALSE;

	// before plug-in hooks
	if (!SetupHookHandler(propset, mBeforePl,
												mShutdownHooksRequired, "pipeline_shutdown"))
		return FALSE;




	// ... now the after hook handler
	hr = mAfterHookHandler.CreateInstance(MTPROGID_HOOKHANDLER);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to initialize after plug-in hook handler");
		return FALSE;
	}

	try
	{
		VARIANT_BOOL checksumMatch;
		MTPipelineLib::IMTConfigPropSetPtr propset =
			aConfig->ReadConfiguration(file.c_str(), &checksumMatch);

		MTPipelineLib::IMTConfigPropPtr prop = propset->NextWithName("after_plugin");


		mAfterHooksRequired = FALSE;

		// see if it's an empty set, which is actually just an empty string
		if (prop->GetPropType() == MTConfigLib::PROP_TYPE_SET)
		{
			// there are hooks
			MTPipelineLib::IMTConfigPropSetPtr hooks = prop->GetPropValue();

			mAfterHookHandler->Read(hooks);

			// if there's more than one hook configured, we need to call it
			if (mAfterHookHandler->GetHookCount() > 0)
				mAfterHooksRequired = TRUE;
		}
	}
	catch (_com_error &)
	{
		mLogger.LogThis(LOG_ERROR, "Unable to configure before plug-in hook handler");
		throw;											// rethrow the error
	}


	return TRUE;
}

#endif


BOOL PipelineHooks::SetupHookHandler(MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																		 const char * apSetName)
{
	const char * functionName = "PipelineHooks::SetupHookHandler";

	// NOTE: this function throws on error

	HRESULT hr = mHandler.CreateInstance(MTPROGID_HOOKHANDLER);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to initialize hook handler");
		return FALSE;
	}

	// always reset in case another hook was already setup
	aPropSet->Reset();
	MTPipelineLib::IMTConfigPropPtr prop = aPropSet->NextWithName(apSetName);

	mHooksRequired = FALSE;

	// see if it's an empty set, which is actually just an empty string
	if (prop->GetPropType() == MTPipelineLib::PROP_TYPE_SET)
	{
		// there are hooks
		MTPipelineLibExt::IMTConfigPropSetPtr hooks = prop->GetPropValue();

		mHandler->Read(hooks);

		// if there's more than one hook configured, we need to call it
		if (mHandler->GetHookCount() > 0)
			mHooksRequired = TRUE;
	}

	return TRUE;
}
