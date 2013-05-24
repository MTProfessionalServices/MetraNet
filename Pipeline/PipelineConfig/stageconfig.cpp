/**************************************************************************
 * @doc STAGECONFIG
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
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTConfigLib.tlb"

#include <stageinfo.h>
#include <stageconfig.h>
#include <mtcomerr.h>

#include <mtglobal_msg.h>


/******************************************* StageInfoReader ***/


BOOL StageInfoReader::ReadConfiguration(MTPipelineLib::IMTConfigPtr & arReader,
																				const char * apFullName,
																				StageInfo & arInfo)
{
	try
	{
		VARIANT_BOOL flag;

		MTPipelineLib::IMTConfigPropSetPtr propset =
			arReader->ReadConfiguration((const char *) apFullName, &flag);

		return ReadConfiguration(propset, arInfo);
	}
	catch (_com_error & err)
	{
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		return FALSE;
	}
}



BOOL StageInfoReader::ReadConfiguration(MTPipelineLib::IMTConfigPropSetPtr & arTop,
																				StageInfo & arInfo)
{
	const char * functionName = "StageInfoReader::ReadConfiguration";

	arInfo.mVersion = arTop->NextLongWithName("version");
	MTPipelineLib::IMTConfigPropSetPtr stageprops = arTop->NextSetWithName("stage");
	if (stageprops == NULL)
	{
		SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
						 functionName);
		mpLastError->GetProgrammerDetail() =
			"Set " "stage" " not found or not a set";
		return FALSE;
	}

	arInfo.mName = stageprops->NextStringWithName("name");
	arInfo.mStartStage =
		(stageprops->NextBoolWithName("startstage") == VARIANT_TRUE);
	arInfo.mFinalStage =
		(stageprops->NextBoolWithName("finalstage") == VARIANT_TRUE);

	if (stageprops->NextMatches("nextstage", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
		arInfo.mNextStage = stageprops->NextStringWithName("nextstage");
	else
	{
		if (!arInfo.mFinalStage)
		{
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName);
			mpLastError->GetProgrammerDetail() =
				"String " "finalstage" " not found or not a set";
		}
		else
			arInfo.mNextStage = "";
	}

	// routing info (optional)
	if (stageprops->NextMatches("routefrom", MTPipelineLib::PROP_TYPE_SET) == VARIANT_TRUE)
	{
		MTPipelineLib::IMTConfigPropSetPtr routeFromSet =
			stageprops->NextSetWithName("routefrom");

		// machine name (optional)
		if (routeFromSet->NextMatches("machine", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
			arInfo.mRouteFromMachine = routeFromSet->NextStringWithName("machine");
		else
			arInfo.mRouteFromMachine = "";

		// queue name (required)
		arInfo.mRouteFromQueue = routeFromSet->NextStringWithName("queue");
	}

  if(stageprops->NextMatches("instancecount", MTPipelineLib::PROP_TYPE_INTEGER))
  {
    // need to read the value in, if it exists, so that the following sections get loaded properly
    stageprops->NextLongWithName("instancecount");
  }

	if (stageprops->NextMatches("autotest", MTPipelineLib::PROP_TYPE_SET))
	{
		// read autotest files

		MTPipelineLib::IMTConfigPropSetPtr files = stageprops->NextSetWithName("autotest");		

		MTPipelineLib::IMTConfigPropPtr file;
		while ((file = files->NextWithName("file")) != NULL)
		{
			MTPipelineLib::PropValType fileType;
			_variant_t fileVariant = file->GetValue(&fileType);
			if (fileType != MTPipelineLib::PROP_TYPE_STRING)
			{
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
								 functionName);
				mpLastError->GetProgrammerDetail() =
					"Tag " "file" " has an incorrect type";
				return FALSE;
			}

			string fileName((const char *) (_bstr_t) fileVariant);
			arInfo.mAutoTestList.push_back(fileName);
		}
	}


	// read processor dependency tree
	if (!stageprops->NextMatches("dependencies", MTPipelineLib::PROP_TYPE_SET))
	{
		SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
						 functionName);
		mpLastError->GetProgrammerDetail() =
			"Set " "dependencies" " not found or not a set";
		return FALSE;
	}

	MTPipelineLib::IMTConfigPropSetPtr dependencies;
	dependencies = stageprops->NextSetWithName("dependencies");
	// just verified that the set existed so it must be there.
	ASSERT(dependencies != NULL);

	return ReadDependencies(dependencies, arInfo);
}



BOOL StageInfoReader::ReadDependencies(MTPipelineLib::IMTConfigPropSetPtr & arDependencies,
																			 StageInfo & arInfo)
{
	if (!arInfo.ReadDependencies(arDependencies))
	{
		SetError(arInfo.GetLastError());
		return FALSE;
	}
	return TRUE;
}

