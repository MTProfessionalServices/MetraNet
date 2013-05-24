/**************************************************************************
 * @doc PLUGINCONFIG
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

#include <pluginconfig.h>
#include <mtcomerr.h>

#include <mtglobal_msg.h>

#include <MTDec.h>
#include <MTSQLInterpreter.h>
#include <MTSQLSharedSessionInterface.h>

using MTPipelineLib::IMTConfigPtr;
using MTPipelineLib::IMTConfigPropPtr;
using MTPipelineLib::IMTConfigPropSetPtr;
using MTPipelineLib::PropValType;

/****************************************** PlugInInfoReader ***/

BOOL PlugInInfoReader::ReadConfiguration(IMTConfigPtr & arReader,
																				 const char * apConfigDir,
																				 const char * apStageName,
																				 const char * apPlugInName,
																				 PlugInConfig & arInfo)
{
	string fullName;
	if (!GetFileName(apConfigDir, apStageName, apPlugInName, fullName))
		return FALSE;								// error already set

	return ReadConfiguration(arReader, fullName.c_str(), arInfo);
}

BOOL PlugInInfoReader::ReadConfiguration(IMTConfigPtr & arReader,
																				 const char * apFullName,
																				 PlugInConfig & arInfo)
{
	try
	{
		VARIANT_BOOL flag;

		IMTConfigPropSetPtr propset =
			arReader->ReadConfiguration(apFullName, &flag);

		return ReadConfiguration(arReader, propset, arInfo);
	}
	catch (_com_error err)
	{
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		return FALSE;
	}
}


BOOL PlugInInfoReader::GetFileName(const char * apConfigDir,
																	 const char * apStageName,
																	 const char * apPlugInName,
																	 string & arStageConfig)
{
	if (!apConfigDir || !*apConfigDir)
	{
		SetError(CORE_ERR_BAD_CONFIG_DIRECTORY, ERROR_MODULE, ERROR_LINE,
						 "PlugInInfoReader::GetFileName");
		return FALSE;
	}

	arStageConfig = apConfigDir;

	if (arStageConfig[arStageConfig.length() - 1] != '\\')
		arStageConfig += '\\';

	arStageConfig += "pipeline\\";
	arStageConfig += apStageName;
	arStageConfig += '\\';
	arStageConfig += apPlugInName;
	arStageConfig += ".xml";

	return TRUE;
}

BOOL PlugInInfoReader::AllWhiteSpace(wstring & arStr)
{
	for (int i = 0; i < (int) arStr.length(); i++)
	{
		if (!iswspace(arStr[i]))
			return FALSE;
	}
	return TRUE;
}


BOOL PlugInInfoReader::ReadConfiguration(IMTConfigPtr & arReader,
																				 IMTConfigPropSetPtr & arPropSet,
																				 PlugInConfig & arInfo)
{
	const char * functionName = "PlugInInfoReader::ReadConfiguration";

	arInfo.mAllConfigData = arPropSet;

	arInfo.mVersion = arPropSet->NextLongWithName("version");

	IMTConfigPropSetPtr subset = arPropSet->NextSetWithName("processor");

	_bstr_t name = subset->NextStringWithName("name");
	arInfo.SetName(name);

	arInfo.mProgId = subset->NextStringWithName("progid");

	IMTConfigPropPtr prop;
	for (prop = subset->Next(); prop != NULL; prop = subset->Next())
	{
		PropValType type;
		_variant_t valueVariant = prop->GetValue(&type);
		_bstr_t propName = prop->GetName();

		if (0 == wcscmp(L"inputs", propName))
		{
			//
			// read inputs
			//
			if (type == MTPipelineLib::PROP_TYPE_STRING)
			{
				wstring inputString((_bstr_t) valueVariant);
				if (!AllWhiteSpace(inputString))
				{
					SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
									 functionName);
					mpLastError->GetProgrammerDetail() =
						"Tag " "inputs" " contents not understood";
					return FALSE;
				}
			}
			else
			{
				if (type != MTPipelineLib::PROP_TYPE_SET)
				{
					SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
									 functionName);
					mpLastError->GetProgrammerDetail() =
						"Tag " "inputs" " contents not understood";
					return FALSE;
				}

				// TODO: read and store the inputs correctly
#if 0
				IMTConfigPropSetPtr inputs = valueVariant;
				IMTConfigPropSetPtr input;
				while ((input = inputs->NextSetWithName("input")) != NULL)
				{
					ArgumentMap map;
					map.argument = input->NextStringWithName("argument");
					map.property = input->NextStringWithName("property");
					arInfo.mInputVector.push_back(map);
				}

				// fit to size
				arInfo.mInputVector.resize(arInfo.mInputVector.size());
#endif
			}
		}
		else if (0 == wcscmp(L"outputs", propName))
		{
			//
			// read outputs
			//

			if (type == MTPipelineLib::PROP_TYPE_STRING)
			{
				wstring inputString((_bstr_t) valueVariant);
				if (!AllWhiteSpace(inputString))
				{
					SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
									 functionName);
					mpLastError->GetProgrammerDetail() =
						"Tag " "outputs" " contents not understood";
					return FALSE;
				}
			}
			else
			{
				if (type != MTPipelineLib::PROP_TYPE_SET)
				{
					SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
									 functionName);
					mpLastError->GetProgrammerDetail() =
						"Tag " "outputs" " contents not understood";
					return FALSE;
				}

				// TODO: read and store the outputs correctly
#if 0
				IMTConfigPropSetPtr outputs = valueVariant;
				IMTConfigPropSetPtr output;
				while ((output = outputs->NextSetWithName("output")) != NULL)
				{
					ArgumentMap map;
					map.argument = output->NextStringWithName("argument");
					map.property = output->NextStringWithName("property");
					arInfo.mOutputVector.push_back(map);
				}

				// fit to size
				arInfo.mOutputVector.resize(arInfo.mOutputVector.size());
#endif
			}
		}
		else if (0 == wcscmp(L"autotest", propName))
		{
			if (type != MTPipelineLib::PROP_TYPE_SET)
			{
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
								 functionName);
				mpLastError->GetProgrammerDetail() =
					"Tag " "autotest" " contents not understood";
				return FALSE;
			}

			// read autotest files
			IMTConfigPropSetPtr files = valueVariant;
			IMTConfigPropPtr file;
			while ((file = files->NextWithName("file")) != NULL)
			{
				PropValType fileType;
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
		else if (0 == wcscmp(L"condition", propName))
		{
			//
			// reads and compiles the condition procedure
			//
			arInfo.mLogger.LogVarArgs(LOG_DEBUG, "Compiling condition procedure");
			MTPipelineLib::IMTNameIDPtr nameID("MetraPipeline.MTNameID.1");
			MTPipelineLib::IMTLogPtr comLogger("MetraPipeline.MTLog.1");
			comLogger->Init("logging", name);

			try 
			{
				arInfo.mpSQLCompileEnv = new MTSQLSessionCompileEnvironment(comLogger, nameID);
				arInfo.mpSQLInterpreter = new MTSQLInterpreter(arInfo.mpSQLCompileEnv);
        arInfo.mpFactory = new MTSQLSharedSessionFactoryWrapper();
				
				_bstr_t program = (_bstr_t) valueVariant;
				arInfo.mpSQLConditionProcedure = arInfo.mpSQLInterpreter->analyze((const wchar_t *) program);
				if (arInfo.mpSQLConditionProcedure == NULL) 
				{
					SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
					mpLastError->GetProgrammerDetail() = "Condition procedure could not be compiled";
					return FALSE;
				}
        
        arInfo.mpSQLConditionProcedure->codeGenerate(arInfo.mpSQLCompileEnv);
			} 
			catch (MTSQLException & ex)
			{
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
				mpLastError->GetProgrammerDetail() = "Condition procedure could not be compiled";
				arInfo.mLogger.LogThis(LOG_ERROR, ex.toString().c_str());
				return FALSE;
			}

		}
		else if (0 == wcscmp(L"configdata", propName))
		{
			// store plugin configuration data

			// support an empty configdata section, which is considered a string
			if (type == MTPipelineLib::PROP_TYPE_STRING)
			{
				wstring inputString((_bstr_t) valueVariant);
				if (!AllWhiteSpace(inputString))
				{
					SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
									 functionName);
					mpLastError->GetProgrammerDetail() =
						"Tag " "configdata" " contents not understood";
					return FALSE;
				}

				// create an empty propset to use instead of the empty string.
				arInfo.mConfigData = arReader->NewConfiguration("configdata");
			}
			else
				arInfo.mConfigData = valueVariant;
		}
		else if (0 == wcscmp(L"description", propName))
		{
			// for now, ignore the description
			// TODO: do we need to store the description?
		}
		else
		{
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName);
			mpLastError->GetProgrammerDetail() = "Tag ";
			mpLastError->GetProgrammerDetail() += (const char *) propName;
			mpLastError->GetProgrammerDetail() += " not understood";
			return FALSE;
		}
	}

	if (arInfo.mConfigData == NULL)
	{
		SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
						 functionName);
		mpLastError->GetProgrammerDetail() = "configdata required";
		return FALSE;
	}

	return TRUE;
}
