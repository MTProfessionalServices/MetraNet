/**************************************************************************
 * @doc PIPELINE
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
 * $Date: 10/2/2002 2:12:43 PM$
 * $Author: Derek Young$
 * $Revision: 34$
 ***************************************************************************/

#include <metra.h>

#include <mtcom.h>

#import "MTConfigLib.tlb"

#include <pipelineconfig.h>

using namespace MTConfigLib;

#include <mtglobal_msg.h>
#include <mtcomerr.h>
#import <RCD.tlb>
#include <mtprogids.h>
#include <SetIterate.h>
#include <RcdHelper.h>
#include <vector>
#include <set>
#include <stdutils.h>
using namespace std;

/*
 * tags used in the pipeline.xml file
 */

#define PIPECONFIG_FILENAME_TAG "filename"
#define PIPECONFIG_NAME_TAG "name"
#define PIPECONFIG_SHAREDSESSIONS_TAG "sharedsessions"
#define PIPECONFIG_SHARENAME_TAG "sharename"
#define PIPECONFIG_SIZE_TAG "size"
#define PIPECONFIG_PROFILE_TAG "profile"
#define PIPECONFIG_SESSIONS_TAG "sessions"
#define PIPECONFIG_MESSAGES_TAG "messages"
#define PIPECONFIG_THRESHOLDMIN_TAG "thresholdmin"
#define PIPECONFIG_THRESHOLDMAX_TAG "thresholdmax"
#define PIPECONFIG_THRESHOLDREJECTION_TAG "thresholdrejection"
#define PIPECONFIG_MAX_QUEUE_SIZE "max_queue_size"
#define PIPECONFIG_MIN_QUEUE_SIZE "min_queue_size"
#define PIPECONFIG_STAGES_TAG "stages"
#define PIPECONFIG_VERSION_TAG "version"
#define PIPECONFIG_STARTSTAGE_TAG "startstage"
#define PIPECONFIG_FINALSTAGE_TAG "finalstage"
#define PIPECONFIG_ERRORQUEUE_TAG "errorqueue"
#define PIPECONFIG_AUDITQUEUE_TAG "auditqueue"
#define PIPECONFIG_FAILEDAUDITQUEUE_TAG "failedauditqueue"
#define PIPECONFIG_RESUBMITQUEUE_TAG "resubmitqueue"
#define PIPECONFIG_MACHINE_TAG "machine"
#define PIPECONFIG_QUEUE_TAG "queue"
#define PIPECONFIG_ROUTE_QUEUE_TAG "routefrom"
#define PIPECONFIG_SUSPEND_RESTART_PERIOD "suspend_restart_period"
#define PIPECONFIG_AUDIT_START "startauditting"
#define PIPECONFIG_AUDIT_INTERVAL "auditinterval"
#define PIPECONFIG_AUDIT_BACKTIME "auditbacktime"
#define PIPECONFIG_AUDIT_JOURNALSIZE "routingjournalsize"
#define PIPECONFIG_AUDIT_FREQUENCY "auditfrequency"
#define PIPECONFIG_STARTUP_TAG "startup"
#define PIPECONFIG_SLEEP_TAG "sleep"
#define PIPECONFIG_PROCESS_SETTING_TAG "process_setting"
#define PIPECONFIG_USE_PRIVATE_QUEUES_TAG "use_private_queues"
#define PIPECONFIG_STAGE_MULTIPLICITY_TAG "stage_multiplicity"
#define PIPECONFIG_HARNESS_TAG "harness"
#define PIPECONFIG_TYPE_TAG "type"
#define PIPECONFIG_ROUTINGDATABASE_TAG "routingdatabase"
#define PIPECONFIG_PROPORTION_SESS_TAG "session_proportion"
#define PIPECONFIG_PROPORTION_PROP_TAG "property_proportion"
#define PIPECONFIG_PROPORTION_SET_TAG "session_set_proportion"
#define PIPECONFIG_PROPORTION_NODE_TAG "session_node_proportion"
#define PIPECONFIG_PROPORTION_STRING_TAG "string_property_proportion"
#define PIPECONFIG_PROPORTION_OWNER_TAG "object_owner_proportion"
// ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
#define PIPECONFIG_EMERG_STOP_POLICY_TAG "emergency_stop_policy"

/********************************************** PipelineInfo ***/

// ----------------------------------------------------------------
// Name:     	<name of the method>
// Arguments:     <argument 1> - <argument 1 description>
//                <argument 2> - <argument 2 description>
// Return Value:  <return value description>    
// Errors Raised: <error number> - <error description>
// Description:   <enter detailed description here>
// ----------------------------------------------------------------

int PipelineInfo::GetStageID(const char * apStageName) const
{
	std::string stageName = apStageName;
	StrToLower(stageName);

	StageNameToIDMap::const_iterator findit;
	findit = mStageIDMap.find(stageName);

	if (findit == mStageIDMap.end())
		return -1;
	
	return findit->second;
}

// ----------------------------------------------------------------
// Name:     	<name of the method>
// Arguments:     <argument 1> - <argument 1 description>
//                <argument 2> - <argument 2 description>
// Return Value:  <return value description>    
// Errors Raised: <error number> - <error description>
// Description:   <enter detailed description here>
// ----------------------------------------------------------------

BOOL PipelineInfo::GetStageXmlfile(const char* apStageName, std::string& aFullStageFile) const
{
	// this method is slow and shouldn't be used too often
	BOOL bRetVal = FALSE;
	
	StageList::const_iterator it;
	for (it = mStages.begin(); it != mStages.end(); ++it)
	{
		const StageIDAndName & idAndName = *it;
		if (_stricmp(idAndName.mStageName.c_str(), apStageName) == 0) {
			aFullStageFile = 	idAndName.mFullStageXmlPath;
			bRetVal = TRUE;
			break;
		}
	}

	return bRetVal;
}


// ----------------------------------------------------------------
// Name:     	<name of the method>
// Arguments:     <argument 1> - <argument 1 description>
//                <argument 2> - <argument 2 description>
// Return Value:  <return value description>    
// Errors Raised: <error number> - <error description>
// Description:   <enter detailed description here>
// ----------------------------------------------------------------

// NOTE: this routine isn't very quick
StageIDAndName PipelineInfo::GetStage(int aId)
{
	StageList::const_iterator it;
	for (it = mStages.begin(); it != mStages.end(); ++it)
	{
		const StageIDAndName & idAndName = *it;
		if (aId == idAndName.mStageID)
			return idAndName;
	}
	ASSERT(0);
	StageIDAndName newIdAndName;
	return newIdAndName;
}



/**************************************** PipelineInfoReader ***/

// ----------------------------------------------------------------
// Name:     	<name of the method>
// Arguments:     <argument 1> - <argument 1 description>
//                <argument 2> - <argument 2 description>
// Return Value:  <return value description>    
// Errors Raised: <error number> - <error description>
// Description:   <enter detailed description here>
// ----------------------------------------------------------------

BOOL PipelineInfoReader::ReadConfiguration(IMTConfigPtr & arReader,
																					 const char * apConfigDir,
																					 PipelineInfo & arInfo)
{
	try
	{
		std::string fullName;
		if (!GetFileName(apConfigDir, fullName))
			return FALSE;								// error already set

		VARIANT_BOOL flag;

		IMTConfigPropSetPtr propset =
			arReader->ReadConfiguration(fullName.c_str(), &flag);

		return ReadConfiguration(propset, arInfo);
	}
	catch (_com_error err)
	{
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		return FALSE;
	}
}


// ----------------------------------------------------------------
// Name:     	<name of the method>
// Arguments:     <argument 1> - <argument 1 description>
//                <argument 2> - <argument 2 description>
// Return Value:  <return value description>    
// Errors Raised: <error number> - <error description>
// Description:   <enter detailed description here>
// ----------------------------------------------------------------

BOOL PipelineInfoReader::GetFileName(const char * apConfigDir,
									 std::string & arPipelineConfig)
{
	if (!apConfigDir || !*apConfigDir)
	{
		SetError(CORE_ERR_BAD_CONFIG_DIRECTORY, ERROR_MODULE, ERROR_LINE,
						 "PipelineInfoReader::GetFileName");
		return FALSE;
	}

	arPipelineConfig = apConfigDir;

	if (arPipelineConfig[arPipelineConfig.length() - 1] != '\\')
		arPipelineConfig += '\\';

	arPipelineConfig += "pipeline\\pipeline.xml";
	return TRUE;
}

// ----------------------------------------------------------------
// Name:     	<name of the method>
// Arguments:     <argument 1> - <argument 1 description>
//                <argument 2> - <argument 2 description>
// Return Value:  <return value description>    
// Errors Raised: <error number> - <error description>
// Description:   <enter detailed description here>
// ----------------------------------------------------------------


BOOL PipelineInfoReader::ReadConfiguration(IMTConfigPropSetPtr & arTop,
																					 PipelineInfo & arInfo)
{
	const char * functionName = "PipelineInfoReader::ReadConfiguration";

	// set defaults
	arInfo.mProcessSetting = PipelineInfo::STAGE;
	arInfo.mSleepAtStartup = FALSE;

	try
	{
		arInfo.mVersion = arTop->NextLongWithName(PIPECONFIG_VERSION_TAG);

		//
		// shared memory information
		//
		IMTConfigPropSetPtr sharedsessions =
			arTop->NextSetWithName(PIPECONFIG_SHAREDSESSIONS_TAG);
		if (sharedsessions == NULL)
		{
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, "Tag " PIPECONFIG_SHAREDSESSIONS_TAG " not found");
			return FALSE;
		}

		// Get the log filename. Support environment variables.
		char ExpandedFilename[MAX_PATH];
		ExpandedFilename[0] = 0;
		ExpandEnvironmentStringsA(sharedsessions->NextStringWithName(PIPECONFIG_FILENAME_TAG), ExpandedFilename, sizeof(ExpandedFilename));
		arInfo.mSharedSessionFileName =	ExpandedFilename;

		arInfo.mShareName = sharedsessions->NextStringWithName(PIPECONFIG_SHARENAME_TAG);
		arInfo.mSharedFileSize = sharedsessions->NextLongWithName(PIPECONFIG_SIZE_TAG);

    //
    // Session server pool configuration
		if (sharedsessions->NextMatches(PIPECONFIG_PROPORTION_SESS_TAG, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
			arInfo.mProportionSession = sharedsessions->NextLongWithName(PIPECONFIG_PROPORTION_SESS_TAG);
		else
			arInfo.mProportionSession = MT_PROPORTION_SESS;

		if (sharedsessions->NextMatches(PIPECONFIG_PROPORTION_PROP_TAG, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
			arInfo.mProportionProperty = sharedsessions->NextLongWithName(PIPECONFIG_PROPORTION_PROP_TAG);
		else
			arInfo.mProportionProperty = MT_PROPORTION_PROP;

		if (sharedsessions->NextMatches(PIPECONFIG_PROPORTION_SET_TAG, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
			arInfo.mProportionSessionSet = sharedsessions->NextLongWithName(PIPECONFIG_PROPORTION_SET_TAG);
		else
			arInfo.mProportionSessionSet = MT_PROPORTION_SET;

		if (sharedsessions->NextMatches(PIPECONFIG_PROPORTION_NODE_TAG, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
			arInfo.mProportionNode = sharedsessions->NextLongWithName(PIPECONFIG_PROPORTION_NODE_TAG);
		else
			arInfo.mProportionNode = MT_PROPORTION_NODE;

		if (sharedsessions->NextMatches(PIPECONFIG_PROPORTION_STRING_TAG, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
			arInfo.mProportionString = sharedsessions->NextLongWithName(PIPECONFIG_PROPORTION_STRING_TAG);
		else
			arInfo.mProportionString = MT_PROPORTION_STRING;

		if (sharedsessions->NextMatches(PIPECONFIG_PROPORTION_OWNER_TAG, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
			arInfo.mProportionObjectOwner = sharedsessions->NextLongWithName(PIPECONFIG_PROPORTION_OWNER_TAG);
		else
			arInfo.mProportionObjectOwner = MT_PROPORTION_OWNER;

    // Constraint check the server pool configuration
    if (500 != arInfo.mProportionSession + arInfo.mProportionProperty + arInfo.mProportionSessionSet +
        arInfo.mProportionNode + arInfo.mProportionString + arInfo.mProportionObjectOwner)
    {
      SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, "Sum of shared memory configuration parameters session_proportion, session_proportion, property_proportion, session_set_proportion, session_node_proportion, string_proportion and object_owner_proportion must equal 500");
      return FALSE;
    }

    if (arInfo.mProportionSession <= 0 ||
        arInfo.mProportionProperty <= 0 ||
        arInfo.mProportionSessionSet <= 0 || 
        arInfo.mProportionNode <= 0 || 
        arInfo.mProportionObjectOwner <= 0 ||
        arInfo.mProportionString <= 0)
    {
      SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, "All shared memory configuration parameters session_proportion, session_proportion, property_proportion, session_set_proportion, session_node_proportion, string_proportion and object_owner_proportion must be greater than 0");
      return FALSE;
    }
    // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
		// crash response mode setting
		if (arTop->NextMatches(PIPECONFIG_EMERG_STOP_POLICY_TAG, PROP_TYPE_BOOLEAN) == VARIANT_TRUE)
		{
			arInfo.mEmergStopPolicyIsCrash = (arTop->NextBoolWithName(PIPECONFIG_EMERG_STOP_POLICY_TAG) == VARIANT_TRUE) ? TRUE : FALSE;
		}
		else arInfo.mEmergStopPolicyIsCrash = TRUE;
    //
		// thresholds for flow control
		//
		if (arTop->NextMatches(PIPECONFIG_THRESHOLDMIN_TAG, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
			arInfo.mThresholdMin = arTop->NextLongWithName(PIPECONFIG_THRESHOLDMIN_TAG);
		else
			arInfo.mThresholdMin = DEFAULT_THRESHOLDMIN;

		if (arTop->NextMatches(PIPECONFIG_THRESHOLDMAX_TAG, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
			arInfo.mThresholdMax = arTop->NextLongWithName(PIPECONFIG_THRESHOLDMAX_TAG);
		else
			arInfo.mThresholdMax = DEFAULT_THRESHOLDMAX;

		if (arTop->NextMatches(PIPECONFIG_THRESHOLDREJECTION_TAG, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
			arInfo.mThresholdRejection = arTop->NextLongWithName(PIPECONFIG_THRESHOLDREJECTION_TAG);
		else
			arInfo.mThresholdRejection = DEFAULT_THRESHOLDREJECTION;

		//
		// max routing queue size
		//
		if (arTop->NextMatches(PIPECONFIG_MAX_QUEUE_SIZE, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
			arInfo.mMaxQueueSize = arTop->NextLongWithName(PIPECONFIG_MAX_QUEUE_SIZE);
		else
			arInfo.mMaxQueueSize = DEFAULT_MAX_QUEUE_SIZE;

		if (arTop->NextMatches(PIPECONFIG_MIN_QUEUE_SIZE, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
			arInfo.mMinQueueSize = arTop->NextLongWithName(PIPECONFIG_MIN_QUEUE_SIZE);
		else
			arInfo.mMinQueueSize = DEFAULT_MIN_QUEUE_SIZE;


		//
		// profile information
		//
		if (arTop->NextMatches(PIPECONFIG_PROFILE_TAG, PROP_TYPE_SET)
				== VARIANT_TRUE)
		{
			IMTConfigPropSetPtr profileConfig =
				arTop->NextSetWithName(PIPECONFIG_PROFILE_TAG);
			ASSERT(profileConfig != NULL);
			if (profileConfig == NULL)
			{
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
								 functionName, "Tag " PIPECONFIG_PROFILE_TAG " not found");
				return FALSE;
			}

			ExpandedFilename[0] = 0;
			ExpandEnvironmentStringsA(profileConfig->NextStringWithName(PIPECONFIG_FILENAME_TAG), ExpandedFilename, sizeof(ExpandedFilename));
			arInfo.mProfileFileName = ExpandedFilename;
			arInfo.mProfileShareName =
				profileConfig->NextStringWithName(PIPECONFIG_SHARENAME_TAG);
			arInfo.mProfileSessions =
				profileConfig->NextLongWithName(PIPECONFIG_SESSIONS_TAG);
			arInfo.mProfileMessages =
				profileConfig->NextLongWithName(PIPECONFIG_MESSAGES_TAG);
		}

    //
    // database harness configuration
    //
		if (arTop->NextMatches(PIPECONFIG_HARNESS_TAG, PROP_TYPE_SET)
				== VARIANT_TRUE)
    {
      IMTConfigPropSetPtr harness =
        arTop->NextSetWithName(PIPECONFIG_HARNESS_TAG);
      ASSERT(harness != NULL);
      if (harness->NextMatches(PIPECONFIG_ROUTINGDATABASE_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
      {
        arInfo.mRoutingDatabase = harness->NextStringWithName(PIPECONFIG_ROUTINGDATABASE_TAG);
      }
      else
      {
        SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
                 functionName, "Tag " PIPECONFIG_ROUTINGDATABASE_TAG " not found");
        return FALSE;
      }
    }

    // If there is no specification of the <harness>, then look for "old-style" MSMQ configuration
    // information.

		//
		// error queue info
		//
		IMTConfigPropSetPtr errorqueue =
			arTop->NextSetWithName(PIPECONFIG_ERRORQUEUE_TAG);
		if (errorqueue == NULL)
		{
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, "Tag " PIPECONFIG_ERRORQUEUE_TAG " not found");
			return FALSE;
		}

		if (errorqueue->NextMatches(PIPECONFIG_MACHINE_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
			arInfo.mErrorQueueMachine =
				errorqueue->NextStringWithName(PIPECONFIG_MACHINE_TAG);
		else
			arInfo.mErrorQueueMachine = L"";
		arInfo.mErrorQueueName = errorqueue->NextStringWithName(PIPECONFIG_QUEUE_TAG);

		//
		// audit queue
		//
		IMTConfigPropSetPtr auditqueue =
			arTop->NextSetWithName(PIPECONFIG_AUDITQUEUE_TAG);
		if (auditqueue == NULL)
		{
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, "Tag " PIPECONFIG_AUDITQUEUE_TAG " not found");
			return FALSE;
		}

		if (auditqueue->NextMatches(PIPECONFIG_MACHINE_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
			arInfo.mAuditQueueMachine =
				auditqueue->NextStringWithName(PIPECONFIG_MACHINE_TAG);
		else
			arInfo.mAuditQueueMachine = L"";
		arInfo.mAuditQueueName = auditqueue->NextStringWithName(PIPECONFIG_QUEUE_TAG);
		auditqueue = NULL;


		//
		// failedaudit queue
		//
		IMTConfigPropSetPtr failedauditqueue =
			arTop->NextSetWithName(PIPECONFIG_FAILEDAUDITQUEUE_TAG);
		if (failedauditqueue == NULL)
		{
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, "Tag " PIPECONFIG_FAILEDAUDITQUEUE_TAG " not found");
			return FALSE;
		}

		if (failedauditqueue->NextMatches(PIPECONFIG_MACHINE_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
			arInfo.mFailedAuditQueueMachine =
				failedauditqueue->NextStringWithName(PIPECONFIG_MACHINE_TAG);
		else
			arInfo.mFailedAuditQueueMachine = L"";
		arInfo.mFailedAuditQueueName =
			failedauditqueue->NextStringWithName(PIPECONFIG_QUEUE_TAG);
		failedauditqueue = NULL;

		//
		// resubmit queue
		//
		IMTConfigPropSetPtr resubmitqueue =
			arTop->NextSetWithName(PIPECONFIG_RESUBMITQUEUE_TAG);
		if (resubmitqueue == NULL)
		{
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, "Tag " PIPECONFIG_RESUBMITQUEUE_TAG " not found");
			return FALSE;
		}

		if (resubmitqueue->NextMatches(PIPECONFIG_MACHINE_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
			arInfo.mResubmitQueueMachine =
				resubmitqueue->NextStringWithName(PIPECONFIG_MACHINE_TAG);
		else
			arInfo.mResubmitQueueMachine = L"";
		arInfo.mResubmitQueueName =
			resubmitqueue->NextStringWithName(PIPECONFIG_QUEUE_TAG);
		resubmitqueue = NULL;


		//
		// routing queue list
    //

		wstring machinename;
		wstring queuename;
		
		if((arTop->NextMatches(PIPECONFIG_ROUTE_QUEUE_TAG, PROP_TYPE_SET)) == VARIANT_FALSE)
		{
			//setup the deflaut one which is the localhost and routingqueue;
			//machinename = L"localhost";
			//queuename = L"routingqueue";
			machinename = L"";
			queuename = L"";
			arInfo.mRoutingQueueList.push_back(RoutingQueueInfo(machinename.c_str(), queuename.c_str()));
			arInfo.mRoutingQueueMachine = machinename;
			arInfo.mRoutingQueueName = queuename;
		}
		else 
		{
			BOOL more = TRUE;

			do {
				IMTConfigPropSetPtr routingqueue = arTop->NextSetWithName(PIPECONFIG_ROUTE_QUEUE_TAG);

				if (routingqueue->NextMatches(PIPECONFIG_MACHINE_TAG,
																			PROP_TYPE_STRING) == VARIANT_TRUE)
					machinename = routingqueue->NextStringWithName(PIPECONFIG_MACHINE_TAG);
				else
					machinename = L"";
			
				queuename = routingqueue->NextStringWithName(PIPECONFIG_QUEUE_TAG);
				arInfo.mRoutingQueueList.push_back(RoutingQueueInfo(machinename.c_str(), queuename.c_str()));
				arInfo.mRoutingQueueMachine = machinename;
				arInfo.mRoutingQueueName = queuename;
				more = ((arTop->NextMatches(PIPECONFIG_ROUTE_QUEUE_TAG, PROP_TYPE_STRING)) == VARIANT_TRUE);
			} while(more);
		}

		if (arTop->NextMatches(PIPECONFIG_SUSPEND_RESTART_PERIOD, PROP_TYPE_DOUBLE)
				== VARIANT_TRUE)
			arInfo.mSuspendRestartPeriod = arTop->NextDoubleWithName(PIPECONFIG_SUSPEND_RESTART_PERIOD);
		else
			// default is six hours
			arInfo.mSuspendRestartPeriod = 6;

		// read the auditing information
		if(!ReadAuditInformation(arTop,arInfo)) return FALSE;

		//
		// startup information
		//

		if (arTop->NextMatches(PIPECONFIG_STARTUP_TAG, PROP_TYPE_SET)
				== VARIANT_TRUE)
		{
			IMTConfigPropSetPtr startupConfig =
				arTop->NextSetWithName(PIPECONFIG_STARTUP_TAG);
			ASSERT(startupConfig != NULL);
			if (startupConfig == NULL)
			{
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
								 functionName, "Tag " PIPECONFIG_STARTUP_TAG " not found");
				return FALSE;
			}

			arInfo.mSleepAtStartup =
				(startupConfig->NextBoolWithName(PIPECONFIG_SLEEP_TAG) == VARIANT_TRUE)
				? TRUE : FALSE;

			_bstr_t processSetting =
				startupConfig->NextStringWithName(PIPECONFIG_PROCESS_SETTING_TAG);

			if (0 == mtwcscasecmp((const wchar_t *) processSetting, L"extension"))
				arInfo.mProcessSetting = PipelineInfo::EXTENSION;
			else if (0 == mtwcscasecmp((const wchar_t *) processSetting, L"stage"))
				arInfo.mProcessSetting = PipelineInfo::STAGE;
			else if (0 == mtwcscasecmp((const wchar_t *) processSetting, L"all"))
				arInfo.mProcessSetting = PipelineInfo::ALL;
			else
			{
				std::string buffer("Unknown process_setting value ");
				buffer += (const char *) processSetting;
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
								 functionName, buffer.c_str());
				return FALSE;
			}
		}


		// private queues setting
		if (arTop->NextMatches(PIPECONFIG_USE_PRIVATE_QUEUES_TAG, PROP_TYPE_BOOLEAN)
				== VARIANT_TRUE)
		{
			arInfo.mUsePrivateQueues =
				(arTop->NextBoolWithName(PIPECONFIG_USE_PRIVATE_QUEUES_TAG) == VARIANT_TRUE)
				? TRUE : FALSE;
		}
		else
			arInfo.mUsePrivateQueues = FALSE;

		// stage multiplicity setting
		if (arTop->NextMatches(PIPECONFIG_STAGE_MULTIPLICITY_TAG, PROP_TYPE_INTEGER)
				== VARIANT_TRUE)
		{
			arInfo.mStageMultiplicity = arTop->NextLongWithName(PIPECONFIG_STAGE_MULTIPLICITY_TAG);
		}
		else
			arInfo.mStageMultiplicity = 1;

		//
		// stage list
		//
		if(!GetStageList(arInfo)) return FALSE;

		return TRUE;
	}
	catch (_com_error err)
	{
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		return FALSE;
	}
}

// ----------------------------------------------------------------
// Name:     	ReadAuditInformation
// Arguments:     <arTop> - propset containing auditing configuration
//                <arInfo> - pipeline-info object to populate
// Return Value:  Boolean  
// Description:   Reads the auditing configuration.
// ----------------------------------------------------------------

BOOL PipelineInfoReader::ReadAuditInformation(MTConfigLib::IMTConfigPropSetPtr & arTop,
																						PipelineInfo & arInfo)
{
	static const char* functionName = "PipelineInfoReader::ReadAuditInformation";
	BOOL bRetVal = TRUE;

	// get the properties
	try {
		arInfo.mbStartAuditing = arTop->NextBoolWithName(PIPECONFIG_AUDIT_START);
		arInfo.mAuditInterval = arTop->NextDoubleWithName(PIPECONFIG_AUDIT_INTERVAL);
		arInfo.mbAuditBackTime = arTop->NextLongWithName(PIPECONFIG_AUDIT_BACKTIME);
		arInfo.mbRoutingJournalSize = arTop->NextLongWithName(PIPECONFIG_AUDIT_JOURNALSIZE);
		arInfo.mbAuditFrequency = arTop->NextLongWithName(PIPECONFIG_AUDIT_FREQUENCY);

	}
	catch(_com_error& err) {
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		bRetVal =  FALSE;
	}
	return bRetVal;
}
	

// ----------------------------------------------------------------
// Name:     	GetStageList
// Arguments:     <arInfo> - Stage list to populate
// Return Value:  boolean
// Description:   Get the list of stages to run using the RCD
// ----------------------------------------------------------------

BOOL PipelineInfoReader::GetStageList(PipelineInfo & arInfo)
{
	const char * functionName = "PipelineInfoReader::GetStageList";

	BOOL bRetval = TRUE;
	int stageID = 1;

	try {
		// create an instance of the RCD
		RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
		aRCD->Init();
		// run a query for all stage.xml files
		RCDLib::IMTRcdFileListPtr aFileList = aRCD->RunQuery("config\\pipeline\\stage.xml",VARIANT_TRUE);
		// iterate through the list		
		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
	
		if(FAILED(it.Init(aFileList))) return FALSE;

		std::set<std::string> stageSet;
		while (TRUE)
		{
			_variant_t aVariant= it.GetNext();
			_bstr_t afile = aVariant;
			if(afile.length() == 0) break;

			vector<mtstring> aVector;
			mtstring aQuery = afile;
			Tokenize<vector<mtstring> >(aVector,aQuery);
			vector<mtstring>::iterator it= aVector.end();
			it -= 2;

			std::string & name = *it;

			std::string lowerName = name;
			StrToLower(lowerName);

			if (stageSet.count(lowerName) > 0)
			{
				std::string error("Stage ");
				error += name;
				error += " exists in two different places. "; 
				error += " Please look for duplicate stage/pipeline folders!";
				SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE,
								 functionName, error.c_str());
				return FALSE;
			}
			else
				stageSet.insert(lowerName);

			StageIDAndName stage;
			stage.mStageName = name.c_str();
			stage.mFullStageXmlPath = afile;
			stage.mStageID = stageID++;
			arInfo.mStages.push_back(stage);
			arInfo.mStageIDMap[lowerName] = stage.mStageID;
		}
	}
	catch(_com_error& err) {
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		bRetval =  FALSE;
	}
	return bRetval;
}


