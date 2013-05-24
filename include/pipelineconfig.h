/**************************************************************************
 * @doc PIPELINECONFIG
 *
 * @module |
 *
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
 *
 * @index | PIPELINECONFIG
 ***************************************************************************/

#ifndef _PIPELINECONFIG_H
#define _PIPELINECONFIG_H

#include <errobj.h>
#include <pipeconfigutils.h>
#include <map>
#include <list>

using std::list;
using std::map;

#if defined(DEFINING_CONFIGREADERS) && !defined(DLL_EXPORT_READERS) 
#define DLL_EXPORT_READERS __declspec( dllexport )
#else
#define DLL_EXPORT_READERS //__declspec( dllimport )
#endif


#define DEFAULT_THRESHOLDMIN       20
#define DEFAULT_THRESHOLDMAX       50
#define DEFAULT_THRESHOLDREJECTION 80

// Proportions for splitting up shared memory.
// proportions out of 500.  defines the recommended relative size of each pool
#define MT_PROPORTION_SESS 160
#define MT_PROPORTION_PROP 135
#define MT_PROPORTION_SET 1
#define MT_PROPORTION_NODE 11
#define MT_PROPORTION_STRING 192
#define MT_PROPORTION_OWNER 1


#define DEFAULT_MAX_QUEUE_SIZE (20*1024*1024)
#define DEFAULT_MIN_QUEUE_SIZE (5*1024*1024)

class StageIDAndName
{
public:
	int mStageID;
	std::string mStageName;
	std::string mFullStageXmlPath;

	StageIDAndName & operator =(const StageIDAndName & arStage)
	{
		mStageID = arStage.mStageID;
		mStageName = arStage.mStageName;
		return *this;
	}
};

typedef list<StageIDAndName> StageList;

// for fast lookups use this instead of StageList
typedef map<string, int> StageNameToIDMap;

class PipelineInfo
{
	friend class PipelineInfoReader;
public:
	// how the pipeline will start processes.
	enum ProcessSetting
	{
		EXTENSION,									// one process per extension
		STAGE,											// one process per stage
		ALL													// one process for everything
	};

  enum HarnessType
  {
    PERSISTENT_DATABASE_QUEUE,
    PERSISTENT_MSMQ
  };

public:
	int GetVersion() const
	{ return mVersion; }

	//
	// shared session info
	//
	const std::string & GetSharedSessionFile() const
	{ return mSharedSessionFileName; }

	const std::string & GetShareName() const
	{ return mShareName; }

	long GetSharedFileSize() const
	{ return mSharedFileSize; }

	long GetProportionSession() const
	{ return mProportionSession; }

	long GetProportionProperty() const
	{ return mProportionProperty; }

	long GetProportionSessionSet() const
	{ return mProportionSessionSet; }

	long GetProportionNode() const
	{ return mProportionNode; }

	long GetProportionString() const
	{ return mProportionString; }

	long GetProportionObjectOwner() const
	{ return mProportionObjectOwner; }

	//
	// profile info
	//
	const std::string & GetProfileFile() const
	{ return mProfileFileName; }

	const std::string & GetProfileShareName() const
	{ return mProfileShareName; }

	long GetProfileSessions() const
	{ return mProfileSessions; }

	long GetProfileMessages() const
	{ return mProfileMessages; }

	BOOL ProfileEnabled() const
	{ return mProfileFileName.length() > 0; }

	//
	// stage list
	//
	const StageList & GetStages() const
	{ return mStages; }

	StageList & GetStages()
	{ return mStages; }

  //
  // Harness type
  //
  const HarnessType GetHarnessType() const
  { return mRoutingDatabase.size() > 0 ? PERSISTENT_DATABASE_QUEUE : PERSISTENT_MSMQ; }

  // 
  // database routing queue
  //
  const std::wstring & GetRoutingDatabase() const
  { return mRoutingDatabase; }

	//
	// error queue
	//
	const std::wstring & GetErrorQueueMachine() const
	{ return mErrorQueueMachine; }

	const std::wstring & GetErrorQueueName() const
	{ return mErrorQueueName; }

	//
	// audit queue
	//
	const std::wstring & GetAuditQueueMachine() const
	{ return mAuditQueueMachine; }

	const std::wstring & GetAuditQueueName() const
	{ return mAuditQueueName; }

	//
	// failed audit queue
	//
	const std::wstring & GetFailedAuditQueueMachine() const
	{ return mFailedAuditQueueMachine; }

	const std::wstring & GetFailedAuditQueueName() const
	{ return mFailedAuditQueueName; }

	//
	// resubmit queue
	//
	const std::wstring & GetResubmitQueueMachine() const
	{ return mResubmitQueueMachine; }

	const std::wstring & GetResubmitQueueName() const
	{ return mResubmitQueueName; }

	//
	// routing queue
	//
	const std::wstring & GetOneRoutingQueueMachine() const
	{
	  return mRoutingQueueMachine;
	}
	const std::wstring & GetOneRoutingQueueName() const
	{
	  return mRoutingQueueName;
	}

	//
	// threshold values
	//
	int GetThresholdMin() const
	{ return mThresholdMin; }

	int GetThresholdMax() const
	{ return mThresholdMax; }

	int GetThresholdRejection() const
	{ return mThresholdRejection; }

	//
	// min/max queue size
	//
	int GetMaxQueueSize() const
	{ return mMaxQueueSize; }

	int GetMinQueueSize() const
	{ return mMinQueueSize; }

	// NOTE: this routine isn't very quick
	DLL_EXPORT_READERS StageIDAndName GetStage(int aId);

	// NOTE: this routine isn't very quick
	DLL_EXPORT_READERS int GetStageID(const char * apStageName) const;

	DLL_EXPORT_READERS BOOL GetStageXmlfile(const char* apStageName,std::string& aXmlFile) const;

	// suspended transaction information
	double GetSuspendRestartPeriod() const
	{ return mSuspendRestartPeriod; }

	// Auditing information

	BOOL GetStartAuditting() const 
	{ return mbStartAuditing; }
	
	double GetAuditInterval() const
	{ return mAuditInterval; }

	long GetAuditBacktime() const
	{ return mbAuditBackTime; }

	long GetRoutingJournalSize() const
	{ return mbRoutingJournalSize; }

	long GetAuditfrequency() const
	{ return mbAuditFrequency; }

	ProcessSetting GetProcessSetting() const
	{ return mProcessSetting; }

	//
	// misc settings
	//

	// if true, stages are asleep at startup
	BOOL GetSleepAtStartup() const
	{ return mSleepAtStartup; }

	// if true, the pipeline should use private queues
	BOOL UsePrivateQueues() const
	{ return mUsePrivateQueues; }
    // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1 
    // if true, the pipeline will crash during emergency stop
	BOOL UseEmergencyCrashPolicy() const
	{ return mEmergStopPolicyIsCrash; }


  long GetStageMultiplicity() const
  { return mStageMultiplicity; }

private:
	int mVersion;

	std::string mSharedSessionFileName;
	std::string mShareName;
	long mSharedFileSize;

  // Shared session pool proportions
	long mProportionSession; 
	long mProportionProperty; 
	long mProportionSessionSet;
  long mProportionNode; 
	long mProportionString; 
	long mProportionObjectOwner; 

	std::string mProfileFileName;
	std::string mProfileShareName;
	long  mProfileSessions;
	long mProfileMessages;

	std::wstring mErrorQueueMachine;
	std::wstring mErrorQueueName;

	std::wstring mAuditQueueMachine;
	std::wstring mAuditQueueName;

	std::wstring mResubmitQueueMachine;
	std::wstring mResubmitQueueName;

	std::wstring mFailedAuditQueueMachine;
	std::wstring mFailedAuditQueueName;

  std::wstring mRoutingDatabase;

	int mThresholdMin;
	int mThresholdMax;
	int mThresholdRejection;

	int mMaxQueueSize;
	int mMinQueueSize;

	double mSuspendRestartPeriod;

 	StageList mStages;
	StageNameToIDMap mStageIDMap;
	RoutingQueueList mRoutingQueueList;
	// Next time it should be removed. Jiang
	std::wstring mRoutingQueueMachine;
	std::wstring mRoutingQueueName;

	// auditinformation
	BOOL mbStartAuditing;
	double mAuditInterval;
	long mbAuditBackTime;
	long mbRoutingJournalSize;
	long mbAuditFrequency;

	// how the pipeline should start processes
	ProcessSetting mProcessSetting;

	// if true, have the stages sleep at startup
	BOOL mSleepAtStartup;

	// if true, the pipeline should use private queues
	BOOL mUsePrivateQueues;
    // ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1 
    // if true, the pipeline will crash during emergency stop
    BOOL mEmergStopPolicyIsCrash;

  // Number of copies of each stage to crank up
  long mStageMultiplicity;
};

class PipelineInfoReader : public virtual ObjectWithError
{
public:
	BOOL DLL_EXPORT_READERS ReadConfiguration(MTConfigLib::IMTConfigPtr & arReader,
																						const char * apConfigDir,
																						PipelineInfo & arInfo);

	BOOL DLL_EXPORT_READERS GetFileName(const char * apConfigDir,
																			std::string & arPipelineConfig);

	BOOL DLL_EXPORT_READERS ReadConfiguration(MTConfigLib::IMTConfigPropSetPtr & arTop,
																						PipelineInfo & arInfo);

protected:
	BOOL ReadAuditInformation(MTConfigLib::IMTConfigPropSetPtr & arTop,
																						PipelineInfo & arInfo);
	BOOL GetStageList(PipelineInfo & arInfo);
};

#endif /* _PIPELINECONFIG_H */
