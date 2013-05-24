/**************************************************************************
 * @doc PROCESSOR
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

// uncomment this line to get the pipeline to print the execution time of each plug-in to stdout
//#define PRINT_PLUG_IN_TIMINGS

/*
 * imports
 */

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTConfigLib.tlb"

#include <processor.h>
#include <MTDec.h>
#include <propids.h>
#include <pluginconfig.h>
#include <mtglobal_msg.h>
#include <stdutils.h>
#include <perflog.h>

#include <SetIterate.h>

// need the MSIX header to generate UIDs
#include <MSIX.h>

#include <MTSQLPipelineInterpreter.h>
#include <MTSQLSharedSessionInterface.h>

#ifdef PRINT_PLUG_IN_TIMINGS
#include <perf.h>
#endif

/*************************************************** statics ***/

static void GetTimeString(std::string & arString, time_t aTime)
{
	const char * ctimeStr = ctime(&aTime);
	arString = ctimeStr;
	arString.resize(arString.length() - 1);
}

/********************************************** PlugInConfig ***/


PlugInConfig::PlugInConfig(const char * apDirName,
													 const char * apTagName,
													 MTPipelineLib::IMTSessionServerPtr aSessionServer)
	: mpInterface(NULL),
		mpSQLInterpreter(NULL),
		mpSQLConditionProcedure(NULL),
		mpSQLCompileEnv(NULL),
		mpFactory(NULL),
		mSessionServer(aSessionServer)
{
	mAutoTest.SetPlugIn(this);

	// TODO: move this init?

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration(apDirName), apTagName);
}

PlugInConfig::~PlugInConfig()
{
	Clear();
}

BOOL PlugInConfig::Initialize(MTPipelineLib::IMTSystemContextPtr aSystemContext)
{
	if (!mAutoTest.Init())
	{
		SetError(mAutoTest.GetLastError(), "Unable to initialize autotest object");
		return FALSE;
	}

	// before calling initialize, get The IUnknown on the effective date objects
	aSystemContext->PutEffectiveConfig(mConfigFile);

	// NOTE: other errors throw _com_error objects
	if (!mpInterface->Initialize(aSystemContext, mConfigData))
	{
		SetError(*mpInterface);
		return FALSE;
	}

	// keep this around for MTSQL
	mCOMLogger = aSystemContext;

	return TRUE;
}

BOOL PlugInConfig::Shutdown()
{
	if (!mpInterface)
		return TRUE;								// interface hasn't been initialized

	// NOTE: other errors throw _com_error objects
	if (!mpInterface->Shutdown())
	{
		SetError(*mpInterface);
		return FALSE;
	}

	return TRUE;
}

void PlugInConfig::Clear()
{
	if (mpInterface)
	{
		delete mpInterface;
		mpInterface = NULL;
	}

	if (mpSQLInterpreter)
	{
		delete mpSQLInterpreter;
		mpSQLInterpreter = NULL;
	}		
	
	if (mpSQLCompileEnv)
	{
		delete mpSQLCompileEnv;
		mpSQLCompileEnv = NULL;
	}

	if (mpFactory)
	{
		delete mpFactory;
		mpFactory = NULL;
	}		
	
	// TODO: do we have to delete mpSQLConditionProcedure? MTSQL plugin doesn't.

	// clear the whole thing
	mConfigData = NULL;
	mAllConfigData = NULL;
	mProgId = "";
	mInputVector.clear();
	mOutputVector.clear();
	mAutoTestList.clear();
	mConfigFile = NULL;

	// TODO: do we have to clear mTestSessions?
}

BOOL PlugInConfig::ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
  //Determine if plugin is conditionally executed
	if (mpSQLConditionProcedure)
  {
		return ProcessSessionsConditionally(aSet);
  }
  else
  {
    //Not expecting error here but may be first time sessionset is initialized
    //If there is an error initializing, SetError has been called and we return early
    if (!ResetExecutePluginProperty(aSet))
      return FALSE;
  }

	// NOTE: other errors throw _com_error objects
	if (!mpInterface->ProcessSessions(aSet))
	{
		SetError(*mpInterface);
		return FALSE;
	}

	return TRUE;
}

//ResetExecutePluginProperty
//In the case that a plugin is not conditionally executed, need to reset the _ExecutePlugin property for the session
//if a previous conditionally executed plugin has set it to false
BOOL PlugInConfig::ResetExecutePluginProperty(MTPipelineLib::IMTSessionSetPtr aSet)
{
  const char * functionName = "PlugInConfig::ResetExecutePluginProperty";

  //----- Get the session set iterator.
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
  {
    std::string buffer("Could not initialize session set");
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName, buffer.c_str());
		return FALSE;
  }
	
	MTPipelineLib::IMTSessionPtr curSession = it.GetNext();

	while (curSession != NULL)
	{
		if(curSession->PropertyExists(PipelinePropIDs::ExecutePluginCode(), MTPipelineLib::SESS_PROP_TYPE_BOOL) == VARIANT_TRUE)
    {
      curSession->SetBoolProperty(PipelinePropIDs::ExecutePluginCode(), VARIANT_TRUE);
    }
		//----- Get the next session.
		curSession = it.GetNext();
	}

  return TRUE;
}

BOOL PlugInConfig::ProcessSessionsConditionally(MTPipelineLib::IMTSessionSetPtr aSet)
{
	MarkRegion region("ProcessSessionsConditionally");

	const char * functionName = "PlugInConfig::ProcessSessionsConditionally";

	long totalSessions = 0;
	long executableSessions = 0;

  MTSQLSharedSessionWrapper wrapper;

#ifdef PRINT_PLUG_IN_TIMINGS
	PerformanceTickCount initialTicks;
	GetCurrentPerformanceTickCount(&initialTicks);
#endif

	// creates a new session set to hold the sessions
	// which will be executed by this plug-in
	MTPipelineLib::IMTSessionSetPtr executionSet = NULL;
	executionSet = mSessionServer->CreateSessionSet();

	// loops over original session set to determine which
	// sessions will be processed by this plug-in and which won't
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

  bool first = true;
  MTPipelineLib::IMTSessionPtr firstSession;
	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;

		try 
		{
 		  if (first)
		  {
			  first = false;
        firstSession = session;
		  }

			// executes the condition procedure
      mpFactory->InitSession(session->SessionID, &wrapper);
			MTSQLSharedSessionRuntimeEnvironment<MTSQLSharedSessionActivationRecord> renv(mCOMLogger, &wrapper, firstSession);
			mpSQLConditionProcedure->execCompiled(&renv);
		} 
		catch (MTSQLException & e) 
		{
			SetError(PIPE_ERR_CONDITION_EXECUTION_FAILED, ERROR_MODULE, ERROR_LINE,
							 functionName, e.toString().c_str()); 
			return FALSE;
		}
		catch (_com_error & e) 
		{
			if (e.Error() == PIPE_ERR_INVALID_PROPERTY)
			{
				// lets the developer know that the missing property error
				// is coming from the condition procedure
				std::string buffer = "Condition procedure failed to execute (" + e.Description() + ")";
 				SetError(e.Error(), ERROR_MODULE, ERROR_LINE, functionName, buffer.c_str()); 
			}
			else
				SetError(e.Error(), ERROR_MODULE, ERROR_LINE, functionName); 

			return FALSE;
		}

		try 
		{
			if (session->GetBoolProperty(PipelinePropIDs::ExecutePluginCode()) == VARIANT_TRUE)
			{
				executionSet->AddSession(session->GetSessionID(), session->GetServiceID());
				executableSessions++;
			}
		}
		catch (_com_error &)
		{
			// the _ExecutePlugin property must be set by the condition procedure
			SetError(PIPE_ERR_CONDITION_PROP_MISSING, ERROR_MODULE, ERROR_LINE, functionName); 
			return FALSE;
		}

		totalSessions++;
	}


	if (mLogger.IsOkToLog(LOG_DEBUG))
		mLogger.LogVarArgs(LOG_DEBUG, "Execution condition has been matched by %d out of %d sessions",
											 executableSessions, totalSessions);


#ifdef PRINT_PLUG_IN_TIMINGS
	PerformanceTickCount finalTicks;
	GetCurrentPerformanceTickCount(&finalTicks);

	long frequency;
	GetPerformanceTickCountFrequency(frequency);

	__int64 ticks = PerformanceCountTicks(&initialTicks, &finalTicks);
	printf("    %f %s\n",
				 ((double) ticks * 1000) / (double) frequency,
				 GetName().c_str());
#endif

	// processes the set of sessions which evaluated to true
	if (executableSessions > 0) 
	{
		MarkRegion region("ProcessSessions");

		if (mLogger.IsOkToLog(LOG_DEBUG))
			mLogger.LogVarArgs(LOG_DEBUG, "Processing %d qualifying session(s)", executableSessions);

		if (!mpInterface->ProcessSessions(executionSet))
		{
			// NOTE: other errors throw _com_error objects
			SetError(*mpInterface);
			return FALSE;
		}
	}
	else
	{
		// no sessions qualified
		if (mLogger.IsOkToLog(LOG_DEBUG))
			mLogger.LogVarArgs(LOG_DEBUG, "Skipping processing of this set");
	}

	return TRUE;
}

BOOL PlugInConfig::LoadProcessor()
{
	const char * functionName = "PlugInConfig::LoadProcessor";

	// TODO: this could be more efficient, using queryinterface on IUnknown
	MTPipelineLib::IMTPipelinePlugInPtr direct;
	HRESULT hr = direct.CreateInstance(mProgId.c_str());
	if (SUCCEEDED(hr))
		mpInterface = new DirectProcessorInterface(direct);
	else
	{
		MTPipelineLib::IMTPipelinePlugIn2Ptr direct2;
		hr = direct2.CreateInstance(mProgId.c_str());
		if (SUCCEEDED(hr))
			mpInterface = new DirectProcessorInterface2(direct2);
		else
		{
			IDispatchPtr idisp;
			hr = idisp.CreateInstance(mProgId.c_str());
			if (SUCCEEDED(hr))
				mpInterface = new DispatchProcessorInterface(idisp);
			else
			{
				std::string buffer("Could not create plug-in object ");
				buffer += mProgId;
				SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
								 buffer.c_str());
				return FALSE;
			}
		}
	}

	// NOTE: any errors throw _com_error objects
	return TRUE;
}

long PlugInConfig::GetEffectiveDate()
{
	return mConfigFile->GetEffectDate();
}

BOOL PlugInConfig::ReadAutoTest(MTPipelineLib::IMTConfigPtr aConfig,
																const char * apConfigDir, const char * apStageName)
{
	if (!mAutoTest.ReadAutoTest(aConfig, GetAutoTestList(), mTestSessions,
															apConfigDir, apStageName))
	{
		SetError(mAutoTest);
		return FALSE;
	}

	return TRUE;
}

BOOL PlugInConfig::RunTestSession(MTPipelineLib::IMTSessionSetPtr aSet)
{
	mLogger.LogVarArgs(LOG_DEBUG, "Testing plug-in: %s", GetName().c_str());

	// run the plug in
	if (!ProcessSessions(aSet))
		return FALSE;

	return TRUE;
}


BOOL PlugInConfig::RunAutoTest(MTPipelineLib::IMTNameIDPtr aNameID,
															 MTPipelineLib::IMTSessionServerPtr aSessionServer)
{
	if (!mAutoTest.RunAutoTest(aNameID, aSessionServer, mTestSessions))
	{
		SetError(mAutoTest);
		return FALSE;
	}

	return TRUE;
}

/******************************************* CompositePlugIn ***/

CompositePlugIn::CompositePlugIn(const char * apDirName, const char * apTagName)
{
	// TODO: move this init?
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration(apDirName), apTagName);
}

CompositePlugIn::~CompositePlugIn()
{
	Clear();
}

BOOL CompositePlugIn::Initialize(MTPipelineLib::IMTSystemContextPtr aSystemContext)
{
	for (PlugInConfigList::const_iterator it = mConfigList.begin();
			 it != mConfigList.end(); it++)
	{
		PlugInConfig * config = *it;

		if (mLogger.IsOkToLog(LOG_INFO))
		{
			time_t thisEffective = config->GetEffectiveDate();
			std::string effective;
			GetTimeString(effective, thisEffective);
			mLogger.LogVarArgs(LOG_INFO, "Initializing plug-in %s with configuration as of %s",
												 GetName().c_str(), (const char *) effective.c_str());
		}

		if (!config->Initialize(aSystemContext))
		{
			SetError(config->GetLastError());
			return FALSE;
		}

		mLogger.LogVarArgs(LOG_DEBUG, "Plug-in %s initialized", GetName().c_str());
	}
	return TRUE;
}

BOOL CompositePlugIn::Shutdown()
{
	for (PlugInConfigList::const_iterator it = mConfigList.begin();
			 it != mConfigList.end(); it++)
	{
		PlugInConfig * config = *it;

		mLogger.LogVarArgs(LOG_DEBUG, "Shutting down plug-in %s", GetName().c_str());

		if (!config->Shutdown())
		{
			SetError(config->GetLastError());
			return FALSE;
		}
	}
	return TRUE;
}

void CompositePlugIn::Clear()
{
	PlugInConfigList::const_iterator it;

	for (it = mConfigList.begin(); it != mConfigList.end(); it++)
	{
		PlugInConfig * config = *it;

		mLogger.LogVarArgs(LOG_DEBUG, "Clearing plug-in %s", GetName().c_str());

		// TODO: should clear return a value?
		config->Clear();
	}


	for (it = mConfigList.begin(); it != mConfigList.end(); it++)
	{
		PlugInConfig * config = *it;
		delete config;
	}
	mConfigList.clear();
}

BOOL CompositePlugIn::ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	const char * functionName = "CompositePlugIn::ProcessSessions";

	// TODO: rework this code!

	long timestamp = GetSetTimestamp(aSet);

	if (mLogger.IsOkToLog(LOG_DEBUG))
	{
		time_t thisEffective = timestamp;

		std::string effective;
		GetTimeString(effective, thisEffective);
		mLogger.LogVarArgs(LOG_DEBUG, "Processing sessions using timestamp of %s",
											 (const char *) effective.c_str());
	}

	// use the latest configuration that's before this time
	PlugInConfig * effectiveConfig = NULL;

	PlugInConfigList::const_iterator it;
	for (it = mConfigList.begin(); it != mConfigList.end(); it++)
	{
		PlugInConfig * config = *it;

		time_t thisEffective = config->GetEffectiveDate();

#if 0
		if (mLogger.IsOkToLog(LOG_DEBUG))
		{
			std::string effective;
			GetTimeString(effective, thisEffective);
			mLogger.LogVarArgs(LOG_DEBUG, "Checking against timestamp of %s",
												 (const char *) effective);
		}
#endif

		if (thisEffective <= timestamp)
			effectiveConfig = config;
		else
			break;
	}

	// the oldest (first in time) configuration is the first in the list
	PlugInConfig * firstConfig = mConfigList.front();

	// if no configurations matched it means the transaction was
	// before all known start dates.  in this case, use the oldest configuration
	BOOL useFirstConfig;
	if (!effectiveConfig)
	{
		effectiveConfig = firstConfig;
		useFirstConfig = TRUE;
	}
	else
		useFirstConfig = FALSE;

	// log info about which configuration but only if there is more than
	// once choice
	if (mLogger.IsOkToLog(LOG_DEBUG) && mConfigList.size() > 1)
	{
		time_t thisEffective = effectiveConfig->GetEffectiveDate();

		std::string effective;
		GetTimeString(effective, thisEffective);

		if (!useFirstConfig)
			mLogger.LogVarArgs(LOG_DEBUG,
												 "Processing sessions with configuration that became effective %s",
												 (const char *) effective.c_str());
		else
			mLogger.LogVarArgs(LOG_DEBUG,
												 "Processing sessions with oldest configuration (effective %s)",
												 (const char *) effective.c_str());
	}

	// now process the sessions
	if (!effectiveConfig->ProcessSessions(aSet))
	{
		SetError(effectiveConfig->GetLastError());
		return FALSE;
	}

	mLogger.LogThis(LOG_DEBUG, "Successfully processed sessions");

	return TRUE;
}

BOOL CompositePlugIn::LoadProcessor()
{
	PlugInConfigList::const_iterator it;
	for (it = mConfigList.begin(); it != mConfigList.end(); it++)
	{
		PlugInConfig * config = *it;

		if (mLogger.IsOkToLog(LOG_INFO))
		{
			time_t thisEffective = config->GetEffectiveDate();
			std::string effective;
			GetTimeString(effective, thisEffective);
			mLogger.LogVarArgs(LOG_DEBUG, "Loading plug-in %s with configuration as of %s",
												 GetName().c_str(), (const char *) effective.c_str());
		}

		if (!config->LoadProcessor())
		{
			SetError(config->GetLastError());
			return FALSE;
		}
	}
	return TRUE;
}


long CompositePlugIn::GetSetTimestamp(MTPipelineLib::IMTSessionSetPtr aSet)
{
	// TODO: rework this code!
	long timestamp = 0;

	SetIterator<MTPipelineLib::IMTSessionSet *, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
		return hr;

	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;

		timestamp = session->GetDateTimeProperty(PipelinePropIDs::TimestampCode());
		break;
	}

	return timestamp;
}



BOOL CompositePlugIn::Configure(MTPipelineLib::IMTConfigPtr aConfig,
																MTPipelineLib::IMTConfigLoaderPtr aConfigLoader,
																const char * apConfigPath,
																const char * apStageName,
																MTPipelineLib::IMTSessionServerPtr aSessionServer)
{
	const char * functionName = "CompositePlugIn::ReadPlugInConfig";

	ASSERT(GetName().c_str() != NULL);

  //Set the logging application tag
  string ApplicationTag("[");
  ApplicationTag += apStageName;
  ApplicationTag += ":";
  ApplicationTag += GetName();
  ApplicationTag += "]";
  mLogger.SetApplicationTag(ApplicationTag.c_str());

	mLogger.LogVarArgs(LOG_DEBUG, "Reading configuration files for %s",
										 GetName().c_str());

	
	string fileName(GetName());
	fileName += ".xml";


	MTPipelineLib::IMTConfigFileListPtr fileList =
		aConfigLoader->GetActiveFiles(apConfigPath, fileName.c_str());

	// figure out the newest plug-in configuration, or NULL if there are none
	PlugInConfig * newestConfig = NULL;
	long newestEffective = 0;

	if (mConfigList.size() > 0)
	{
		newestConfig = mConfigList.front();
		newestEffective = newestConfig->GetEffectiveDate();
	}

	if (mLogger.IsOkToLog(LOG_DEBUG))
	{
		if (newestConfig)
		{
			std::string effective;
			GetTimeString(effective, newestEffective);

			mLogger.LogVarArgs(LOG_DEBUG, "Newest configuration has effective date of %s",
												 (const char *) effective.c_str());
		}
		else
			mLogger.LogThis(LOG_DEBUG, "No current configuration active");
	}

	PlugInInfoReader reader;

	SetIterator<MTPipelineLib::IMTConfigFileListPtr, MTPipelineLib::IMTConfigFilePtr> setit;
	HRESULT hr = setit.Init(fileList);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	while (TRUE)
	{
		MTPipelineLib::IMTConfigFilePtr configFile = setit.GetNext();
		if (configFile == NULL)
			break;

		if (mLogger.IsOkToLog(LOG_DEBUG))
		{
			time_t thisEffective = configFile->GetEffectDate();

			std::string effective;
			GetTimeString(effective, thisEffective);
			
			mLogger.LogVarArgs(LOG_DEBUG,
												 "Read configuration with effective date of %s",
												 (const char *) effective.c_str());
		}

		// see if this is newer than the newest file in the list.
		long effective = configFile->GetEffectDate();
		if (effective > newestEffective)
		{
			string tag("[");
			tag += GetName();
			tag += "]";
			PlugInConfig * plugInConfig = new PlugInConfig("logging", tag.c_str(), aSessionServer);
			plugInConfig->SetConfigFile(configFile);
			MTPipelineLib::IMTConfigPropSetPtr propSet = configFile->GetConfigData();
			if (!reader.ReadConfiguration(aConfig, propSet, *plugInConfig))
			{
				SetError(reader.GetLastError());
				delete plugInConfig;
				return FALSE;
			}

			// make sure the names match
			if (0 != strcasecmp(plugInConfig->GetName(), GetName()))
			{
				std::string buffer("Plug-in name in ");
				buffer += GetName().c_str();
				buffer += "'s configuration file does not match";
				SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE,
								 functionName, buffer.c_str());
				delete plugInConfig;
				return FALSE;
			}

			// if so, insert into the beginning of the list
			mConfigList.push_front(plugInConfig);
		}
	}

	mLogger.LogVarArgs(LOG_INFO, "%d total configurations loaded",
										 mConfigList.size());

	return TRUE;
}


BOOL CompositePlugIn::ReadAutoTest(MTPipelineLib::IMTConfigPtr aConfig,
																	 const char * apConfigDir, const char * apStageName)
{
	PlugInConfigList::const_iterator it;
	for (it = mConfigList.begin(); it != mConfigList.end(); it++)
	{
		PlugInConfig * config = *it;

		if (!config->ReadAutoTest(aConfig, apConfigDir, apStageName))
		{
			SetError(config->GetLastError());
			return FALSE;
		}
	}
	return TRUE;
}

BOOL CompositePlugIn::RunAutoTest(MTPipelineLib::IMTNameIDPtr aNameID,
																	MTPipelineLib::IMTSessionServerPtr aSessionServer)
{
	PlugInConfigList::const_iterator it;
	for (it = mConfigList.begin(); it != mConfigList.end(); it++)
	{
		PlugInConfig * config = *it;

		if (!config->RunAutoTest(aNameID, aSessionServer))
		{
			SetError(config->GetLastError());
			return FALSE;
		}
	}
	return TRUE;
}

/******************************************** PlugInAutoTest ***/

BOOL PlugInAutoTest::RunSession(PipelineAutoTest & arTest,
																MTPipelineLib::IMTSessionSetPtr aSet)
{
	ASSERT(mpPlugIn);
	if (!mpPlugIn->RunTestSession(aSet))
	{
		arTest.SetError(*mpPlugIn);
		return FALSE;
	}
	return TRUE;
}
