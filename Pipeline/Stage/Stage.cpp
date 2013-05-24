/**************************************************************************
 * @doc STAGE
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

#include <mtcomerr.h>

#include <stage.h>
#include <mtprogids.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <MSIX.h>
#include <propids.h>
#include <mtprogids.h>
#include <SetIterate.h>
#include <queue.h>
#include <makeunique.h>
#include <harness.h>
#include <tpstimer.h>
#include <perflog.h>

#include <pipemessages.h>

#include <sessionerr.h>

#include <memhook.h>
#include <ConfigDir.h>

#pragma warning(disable: 4244)

#include <stageschedule.h>
#include <DistributedTransaction.h>

// Can't use our template guard because it assumes
// a "real" pointer not a smart pointer.
class ObjectOwnerGuard
{
private:
  MTPipelineLib::IMTObjectOwnerPtr mOwner;
public:
  ObjectOwnerGuard(MTPipelineLib::IMTObjectOwnerPtr owner)
    :
    mOwner(owner)
  {
    mOwner->Lock();
  }

  ~ObjectOwnerGuard()
  {
    mOwner->Unlock();
  }
};

/********************************************* StageAutoTest ***/

BOOL StageAutoTest::RunSession(PipelineAutoTest & arTest,
															 MTPipelineLib::IMTSessionSetPtr aSet)
{	
	ASSERT(mpStage);
	// TODO: do we need to use the name of the failed plug-in
	if (!mpStage->ProcessTestSession(aSet))
	{
		arTest.SetError(*mpStage);
		return FALSE;
	}

	return TRUE;
}

/********************************************* PipelineStage ***/


PipelineStage::PipelineStage()
	:
	  	mExitFlag(FALSE),
			mSessionsProcessed(0),
			mSessionsFailed(0),
			mpHarness(NULL),
			mRunAutoTests(TRUE),
			mAwake(FALSE),
			mStartAsleep(FALSE)
{
	memset(&mFirstSessionProcessed, 0, sizeof(mFirstSessionProcessed));
	memset(&mLastSessionProcessed, 0, sizeof(mLastSessionProcessed));
}

PipelineStage::~PipelineStage()
{
	Clear();

#ifdef MT_MEM_LOG
	StopMemoryActivityLog();
#endif

}

void PipelineStage::Clear()
{
	ClearConfiguration();


	// NOTE: good idea to call shutdown plug-ins first, then clear
	(void) mExecution.ShutdownPlugIns();
	(void) mExecution.ClearPlugIns();
}


void PipelineStage::ClearConfiguration()
{
	// NOTE: good idea to call shutdown plug-ins first, then clear
	(void) mExecution.ShutdownPlugIns();
	(void) mExecution.ClearPlugIns();
}




BOOL PipelineStage::Wakeup()
{
	if (mAwake)
		return TRUE;

	if (!InitForWakeup())
		return FALSE;

	if (!PrepareStageInternal())
		return FALSE;

	mAwake = TRUE;
	return TRUE;
}



BOOL PipelineStage::Init(StageScheduler * apScheduler,
												 const char * apConfigPath,
												 const char * apStageName,
                         int aStageInstance,
												 BOOL aStartAsleep)
{
	mpHarness = apScheduler->GetHarness();
	mpScheduler = apScheduler;

	mStartAsleep = aStartAsleep;

  mStageInstance = aStageInstance;
#ifdef MT_MEM_LOG
	LogMemoryActivity();
#endif

	if (!InitInternal(apConfigPath, apStageName))
		return FALSE;

	return TRUE;
}


BOOL PipelineStage::InitInternal(const char * apConfigPath, const char * apStageName)
{
	const char * functionName = "PipelineStage::InitInternal";

	mStageName = apStageName;

  char buf[10];
  sprintf(buf, "%d", mStageInstance);

	// TODO: better init here
	std::string tag("[");
	tag += apStageName;
  tag += "_";
  tag += buf;
	tag += ']';
	LoggerConfigReader configReader;
	if (!mLogger.Init(configReader.ReadConfiguration("logging"), tag.c_str()))
	{
		SetError(mLogger);
		return FALSE;
	}

	// NOTE: this has to be done very early
	PipelinePropIDs::Init();

	mLogger.LogThis(LOG_INFO, "Initializing stage");

	// print some diagnostics info in the log
	std::string blank("");
	MakeUnique(blank);
	if (blank == "")
		mLogger.LogThis(LOG_INFO, "Running in single instance mode.");
	else
		mLogger.LogVarArgs(LOG_INFO, "Running as instance %s.", blank.c_str());

	DWORD pid = ::GetCurrentProcessId();
	mLogger.LogVarArgs(LOG_INFO, "Stage %s has process ID %ld", apStageName, pid);

	//
	// initialize the config reader
	//
	mLogger.LogThis(LOG_DEBUG, "Initializing configuration reader");
	HRESULT hr = mConfig.CreateInstance(MTPROGID_CONFIG);
	if (FAILED(hr))
	{
		// TODO: pass win32 or hresult?
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
			"Could not create an instance of " MTPROGID_CONFIG);
		return FALSE;
	}

	//
	// initialize the config loader
	//
	mLogger.LogThis(LOG_DEBUG, "Initializing configuration loader");
	hr = mConfigLoader.CreateInstance(MTPROGID_CONFIGLOADER);
	if (FAILED(hr))
	{
		// TODO: pass win32 or hresult?
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
			"Could not create an instance of " MTPROGID_CONFIGLOADER);
		return FALSE;
	}

	mConfigLoader->InitWithPath(apConfigPath);

	//
	// look up the stage XML file
	//
	if(!mpHarness->GetPipelineInfo().GetStageXmlfile(mStageName.c_str(),mStageXmlFile))
	{
		SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
			"could not find stage xml configuration file");
		return FALSE;
	}


	//
	// read the stage definition
	//
	StageInfoReader stageReader;
	if (!stageReader.ReadConfiguration(mConfig, mStageXmlFile.c_str(), *this))
	{
		SetError(stageReader.GetLastError());
		return FALSE;
	}

	// make sure the names match
	//if (0 != mStageName.compare(GetName(), std::string::ignoreCase))
	if (stricmp(mStageName.c_str(), GetName().c_str()) != 0)
	{
		SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Stage name in stage file does not match argument to stage executable");
		return FALSE;
	}

	if (IsFinalStage())
		mLogger.LogThis(LOG_DEBUG, "Final stage in the pipeline");
	else
		mLogger.LogVarArgs(LOG_DEBUG, "Next stage is %s", (const char *) GetNextStageName().c_str());

	// figure out our stage ID and the next stage ID
	mStageID = mpHarness->GetStageID(GetName().c_str());
	if (mStageID == -1)
	{
		SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Stage is not part of pipeline configuration");
		return FALSE;
	}

	// initialize perfmon support
	mLogger.LogThis(LOG_DEBUG, "Initializing perfmon support");
	if (!mPerfShare.Init())
	{
		SetError(mPerfShare);
		return FALSE;
	}

	if (IsFinalStage())
		mNextStageID = -1;
	else
	{
		mNextStageID = mpHarness->GetStageID(GetNextStageName().c_str());

		if (mNextStageID == -1)
		{
			SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 "listed next stage does not exist");
			return FALSE;
		}
	}

	if (!mStartAsleep)
	{
		// the stage will be starting awake
		mAwake = TRUE;
		return InitForWakeup();
	}


	return TRUE;
}

BOOL PipelineStage::InitForWakeup()
{
	const char * functionName = "PipelineStage::InitForWakeup";

	//
	// initialize the system context object
	//
	mLogger.LogThis(LOG_DEBUG, "Initializing syscontext object");
	HRESULT hr = mSysContext.CreateInstance(MTPROGID_SYSCONTEXT);
	if (FAILED(hr))
	{
		// TODO: pass win32 or hresult?
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
			"Could not create an instance of " MTPROGID_SYSCONTEXT);
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}

	InitSysContextWithConfigInfo();


	//
	// initialize the session server
	//
	mSessionServer = mpHarness->GetSessionServer();


	//
	// initialize system profiler
	//
	mCollectProfile = mpHarness->GetCollectProfile();

	//
	// read the list of sessions that are currently in-process for our stage.
	// because we haven't started accepting any sessions like this yet, the sessions
	// must be failures from a previous crash.  roll them back and log them to the event log
	//
	if (!RollbackSessionsInProcess())
		return FALSE;

	return TRUE;
}




BOOL PipelineStage::PrepareStage(BOOL aRunAutoTests)
{
	// set the autotest flag
	mRunAutoTests = aRunAutoTests;

	if (!mStartAsleep)
	{
		if (!PrepareStageInternal())
		{
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return FALSE;
		}
		else
			return TRUE;
	}
	else
	{
		cout << "  stage " << GetStageName() << " is sleeping." << endl;
		return TRUE;
	}
}


BOOL
PipelineStage::PrepareStageInternal()
{
	const char * functionName = "PipelineStage::PrepareStage";

	cout << endl << "  Preparing stage " << GetStageName() << "..." << endl;

	mLogger.LogVarArgs(LOG_INFO, "Starting stage %s", (const char *) mStageName.c_str());


	//
	// configure the stage
	//
	if (!PrepareConfiguration())
		return FALSE;

	if (mRunAutoTests)
	{
		//
		// stage autotest
		//
		mAutoTest.SetStage(this);
		if (!mAutoTest.Init())
		{
			SetError(mAutoTest);
			return FALSE;
		}

		mLogger.LogThis(LOG_DEBUG, "Reading stage autotest files");

		// strip the path from the stage xml file.
		std::string fullConfigPath(mStageXmlFile);
		fullConfigPath.resize(fullConfigPath.find_last_of('\\'));

		TestSessions testSessions;
		if (!mAutoTest.ReadAutoTest(mConfig, mAutoTestList, testSessions,
																fullConfigPath.c_str(), mStageName.c_str()))
		{
			SetError(mAutoTest);
			return FALSE;
		}

		mLogger.LogThis(LOG_DEBUG, "About to run stage autotest");

		if (!mAutoTest.RunAutoTest(mpHarness->GetNameID(), mSessionServer, testSessions))
		{
			SetError(mAutoTest);
			return FALSE;
		}

		mLogger.LogThis(LOG_DEBUG, "Stage autotest complete");
	}

	// information for routing messages to and from the pipeline
	// (needed for feedback and for the routing thread)
	MTConfigLib::IMTConfig * iconfig = (MTConfigLib::IMTConfig *) (MTPipelineLib::IMTConfig *) mConfig;
	MTConfigLib::IMTConfigPtr config(iconfig);


	mLogger.LogThis(LOG_INFO, "--- Pipeline stage is ready ---");
	return TRUE;
}



void PipelineStage::InitSysContextWithConfigInfo()
{
	// set the stage path
	// strip the path from the stage xml file.
	std::string aPipelinConfigPath =mStageXmlFile;
	aPipelinConfigPath.resize(mStageXmlFile.find_last_of('\\'));
	mSysContext->PutStageDirectory(_bstr_t((const char*)aPipelinConfigPath.c_str()));

	// set the stage name in the system context object
	// remove pipeline
	aPipelinConfigPath.resize(aPipelinConfigPath.find_last_of('\\'));
	// remove config
	aPipelinConfigPath.resize(aPipelinConfigPath.find_last_of('\\'));
	aPipelinConfigPath.resize(aPipelinConfigPath.find_last_of('\\'));


	std::string aExtensionsDir;
	GetExtensionsDir(aExtensionsDir);
	aPipelinConfigPath.erase(0,aExtensionsDir.length()+1);
	mSysContext->PutExtensionName(_bstr_t((const char*)aPipelinConfigPath.c_str()));
}




BOOL PipelineStage::PrepareConfiguration()
{

	// strip the path from the stage xml file.
	std::string aPipelinConfigPath(mStageXmlFile);
	aPipelinConfigPath.resize(aPipelinConfigPath.find_last_of('\\'));
	//
	// initialize the execution graph
	//
	mConfigLoader->InitWithPath(_bstr_t(aPipelinConfigPath.c_str()));

	mExecution.SetRunAutoTests(mRunAutoTests);
	mExecution.SetVerbose(TRUE);

	if (!mExecution.Init(mConfigLoader, mConfig, mSessionServer, mSysContext,
											 aPipelinConfigPath, mStageName, mStageInstance))
	{
		SetError(mExecution.GetLastError());
		return FALSE;
	}
	return TRUE;
}


BOOL PipelineStage::ReadDependencies(MTPipelineLib::IMTConfigPropSetPtr & arDependencies)
{
	if (!mExecution.ReadDependencies(arDependencies))
	{
		SetError(mExecution.GetLastError());
		return FALSE;
	}
	return TRUE;
}


BOOL PipelineStage::ConfigurationHasChanged()
{
	mLogger.LogThis(LOG_INFO, "Configuration change signalled - refreshing configuration");

	if (!mAwake)
	{
		mLogger.LogThis(LOG_DEBUG, "Stage is asleep - no configuration to change");
		return TRUE;
	}

	try
	{
		ClearConfiguration();
		mLogger.LogThis(LOG_DEBUG, "Current configuration cleared successfully");

		if (!PrepareConfiguration())
			return FALSE;
		else
		{
			mLogger.LogThis(LOG_DEBUG, "Configuration changed successfully");
		}
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Error reconfiguring pipeline", err);

		mLogger.LogThis(LOG_FATAL, buffer.c_str());

		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
		{
			cout << "  Description: " << (const char *) desc << endl;
		}
		if (src.length() > 0)
		{
			mLogger.LogVarArgs(LOG_FATAL, " Source: %s", (const char *) src);
			cout << "  Source: " << (const char *) src << endl;
		}
		return FALSE;
	}
	return TRUE;
}


/*
 * session processing
 */

// return TRUE if the given set has a non-null ID
BOOL SetHasID(MTPipelineLib::IMTSessionSetPtr aSet)
{
	static unsigned char nullUID[16] = { 0x00 };

	unsigned char setID[16];
	aSet->GetUID(setID);
	return (0 != memcmp(nullUID, setID, sizeof(nullUID)));
}


BOOL PipelineStage::ProcessTestSession(MTPipelineLib::IMTSessionSetPtr aSet)
{
	std::string plugIn;
	if (!mExecution.ProcessSessions(aSet, plugIn))
	{
		SetError(mExecution);
		return FALSE;
	}
	return TRUE;
}

BOOL PipelineStage::ProcessSessions(long aSetID,
																		const unsigned char * apSetUID)
{
	MarkRegion region("ProcessSessions(setid)");

	const char * functionName = "PipelineStage::ProcessSessions";

	vector<long> groupsComplete;
	vector<ProcessSetMessage> messages;

  // Did session processing succeed?
	BOOL returnStatus = TRUE;
  // Were there any problems during failure processing?
  BOOL failureStatus = TRUE;

	// NOTE: this is scoped like this so that there are no references
	// left to the sessionSet when we call GroupComplete.
  // Don't be confused though, the session set isn't deleted when we leave this scope.
	{
		MTPipelineLib::IMTSessionSetPtr sessionSet;
		try
		{
			sessionSet = mSessionServer->GetSessionSet(aSetID);
		}
		catch (_com_error & err)
		{
			std::string buffer;
			StringFromComError(buffer, "Unable to retrieve session set", err);
			mLogger.LogThis(LOG_ERROR, buffer.c_str());
			// NOTE: true returned because we don't want the stage to return exit
			// its message loop.  We've handled this case and can keep handling messages
			return FALSE;
		}

		unsigned char uid[16];
		sessionSet->GetUID(uid);

		if (mLogger.IsOkToLog(LOG_DEBUG))
		{
			string asciiUID;
			// encode it to ASCII
			MSIXUidGenerator::Encode(asciiUID, uid);
			mLogger.LogVarArgs(LOG_DEBUG, "Session set has ID %s", asciiUID.c_str());
		}

		if (0 != memcmp(uid, apSetUID, 16))
		{
			SetError(PIPE_ERR_BAD_MESSAGE, ERROR_MODULE, ERROR_LINE, functionName,
							 "UID in message doesn't match session set UID.");

			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return FALSE;
		}

		returnStatus = ProcessSessions(sessionSet, groupsComplete, messages);


		sessionSet = NULL;
	}

	vector<MTPipelineLib::IMTTransactionPtr> pendingTransactions;

	int i;
	for (i = 0; i < (int) groupsComplete.size(); i++)
	{
		if (!GroupComplete(groupsComplete[i], pendingTransactions))
    {
      failureStatus = FALSE;
			returnStatus = FALSE;
    }
	}
	groupsComplete.clear();

	// make sure all references to the set have been released or we'll deadlock
	if (!mpHarness->ReevaluateFlow())
	{
		SetError(*mpHarness);
		returnStatus = FALSE;
	}

	for (i = 0; i < (int) messages.size(); i++)
	{
		ProcessSetMessage & message = messages[i];

		// TODO: is this method quick enough?
		StageIDAndName idAndName = mpHarness->GetStage(message.mNextStageID);

		mLogger.LogVarArgs(LOG_DEBUG,
											 "Sending process session set message to stage %s",
											 (const char *) idAndName.mStageName.c_str());

		if (!GetTransmitter()->SendProcessSet(message.mSetID,
																					message.mUID,
																					(const char *) idAndName.mStageName.c_str()))
			returnStatus = FALSE;
	}
	messages.clear();

	for (i = 0; i < (int) pendingTransactions.size(); i++)
	{
		MTPipelineLib::IMTTransactionPtr aTran = pendingTransactions[i];
		if(failureStatus == TRUE)
    {
      mLogger.LogVarArgs(LOG_DEBUG,
                         "Committing failure processing transaction");
      aTran->Commit();
    }
    else
    {
      mLogger.LogVarArgs(LOG_ERROR,
                         "Rolling back failure processing transaction");
      aTran->Rollback();
    }
	}
	pendingTransactions.clear();

	return returnStatus;
}


BOOL PipelineStage::ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet,
																		vector<long> & arGroupsComplete,
																		vector<ProcessSetMessage> & arMessages)
{
	const char * functionName = "PipelineStage::ProcessSessions";

	MarkRegion region("ProcessSessions");

	// TODO: this is a rather inefficient way to determine if the
	// set has failed

	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
	{
		mLogger.LogThis(LOG_ERROR, "Unable to step through session set");
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	MTPipelineLib::IMTSessionPtr rootSession = it.GetNext();

	// this is the object owner of the current level
	MTPipelineLib::IMTObjectOwnerPtr objectOwner = 
		mSessionServer->GetObjectOwner(rootSession->GetObjectOwnerID());

	if (rootSession == NULL)
	{
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unexpected zero length session set");
		return FALSE;
	}

	long parentId;
	while ((parentId = rootSession->GetParentID()) != -1)
	{
		rootSession = mSessionServer->GetSession(parentId);
	}

	// this is the root most object owner
	MTPipelineLib::IMTObjectOwnerPtr rootOwner =
		mSessionServer->GetObjectOwner(rootSession->GetObjectOwnerID());

	BOOL sessionsHaveFailed = (rootOwner->GetErrorFlag() == VARIANT_TRUE);

	if (sessionsHaveFailed)
	{
		mLogger.LogThis(LOG_DEBUG, "Some sessions have failed");

		//
		// immediately process the group as it it were complete
		//
		if (!MarkSetComplete(aSet, arGroupsComplete))
			return FALSE;
		return TRUE;
	}

	//
	// mark the sessions as being in process
	//
	if (!sessionsHaveFailed)
	{
		long stageId = GetStageID();
		if (!SetOperation(aSet, &PipelineStage::OpMarkInProcess, &stageId))
			return FALSE;
	}

	long plugInNameID = mpHarness->GetNameID()->GetNameID("_PlugInName");
	long stageNameID = mpHarness->GetNameID()->GetNameID("_StageName");

	// info about the sessions if they fail
	SessionErrorObject batchError;

	BOOL processSucceeded;
	BOOL batchAwarePlugin    = FALSE;
	BOOL partialFailure      = FALSE;
	long failedSessionCount;

  // We lock on the root object owner to prevent concurrent execution
  // within the transaction owned by it.
  rootOwner->InitLock();

	try
	{
    ObjectOwnerGuard autocritical(rootOwner);

		std::string plugIn;
		
		processSucceeded = mExecution.ProcessSessions(aSet, plugIn);
		if (!processSucceeded)
		{
			const ErrorObject * err = mExecution.GetLastError();
			SetError(err);
			mLogger.LogErrorObject(LOG_ERROR, err);

			// the plugin has failed in a special way indicating
			// that we may be able to salvage some of the good sessions
			// from the batch. we must first determine if the whole batch
			// failed or just part of the batch has failed.
			if (err->GetCode() == PIPE_ERR_SUBSET_OF_BATCH_FAILED)
			{
				batchAwarePlugin = TRUE;

				// counts the failed sessions 
				failedSessionCount = 0;
				SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
				HRESULT hr = it.Init(aSet);
				if (FAILED(hr))
				{
					mLogger.LogThis(LOG_ERROR, "Unable to step through session set to count failed sessions");
					SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
					return FALSE;
				}
				while (TRUE)
				{
					MTPipelineLib::IMTSessionPtr session = it.GetNext();
					if (session == NULL)
						break;
					if (session->CompoundMarkedAsFailed == VARIANT_TRUE)
						failedSessionCount++;
				}

				// helps the developer write better plugins
				if (failedSessionCount == 0)
				{
					mLogger.LogVarArgs(LOG_ERROR,
														 "The plugin returned PIPE_ERR_SUBSET_OF_BATCH_FAILED but did not call"
														 "IMTSession::MarkAsFailed(). The plugin should be changed!");
					ASSERT(0);
				}


				// TODO: does this matter?
				// did only part of the batch fail?
				if (failedSessionCount != aSet->Count)
				{
					// only part of the batch failed
					mLogger.LogVarArgs(LOG_ERROR, "A partial batch failure has occurred. %d out of %d sessions failed!",
														 failedSessionCount, aSet->Count);
					partialFailure = TRUE;
				}
				else
					mLogger.LogVarArgs(LOG_ERROR, "All %d sessions in the batch have failed.",
														 failedSessionCount);
			}

			batchError.SetErrorCode(err->GetCode());
			batchError.SetErrorMessage(err->GetProgrammerDetail().c_str());
			batchError.SetLineNumber(err->GetLineNumber());				
			batchError.SetStageName(GetName().c_str());
			batchError.SetPlugInName(plugIn.c_str());
			batchError.SetModuleName(err->GetModuleName());
			batchError.SetProcedureName(err->GetFunctionName());
		}
	}
	catch (_com_error & err)
	{
		// NOTE: ProcessSessions should not throw!  All plug-in
		// errors are caught internally.

		std::string buffer;
		StringFromComError(buffer, "Failed to process sessions", err);
		mLogger.LogThis(LOG_ERROR, buffer.c_str());
		SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName);

		ASSERT(0);

		_bstr_t descBstr = err.Description();
		const char * desc = descBstr;
		std::string descString(desc ? desc : "");

		// populate the error object
		batchError.SetErrorCode(err.Error());
		batchError.SetLineNumber(-1);
		batchError.SetErrorMessage(desc);
		batchError.SetStageName(GetName().c_str());
		batchError.SetPlugInName("");
		batchError.SetModuleName("");
		batchError.SetProcedureName("");
	}

#ifndef DEBUG
	catch (...)
	{
		mLogger.LogThis(LOG_FATAL,
										"Failed to process sessions: Caught ... - unexpected failure");
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);

		std::string descString = "Stage or plug-in threw an illegal exception";

		// populate the error object
		batchError.SetErrorCode(PIPE_ERR_INTERNAL_ERROR);
		batchError.SetLineNumber(-1);
		batchError.SetErrorMessage(descString.c_str());
		batchError.SetStageName(GetName().c_str());
		batchError.SetPlugInName("");
		batchError.SetModuleName("");
		batchError.SetProcedureName("");
	}
#endif
	

	//
	// stage forking
	//

	MarkEnterRegion("ForkSessions");
	// splits the original set into multiple sets based on which
	// stage it is going to next
	LongToSessionSetMap stageSets;
	BOOL originalSetNeeded;
	if (processSucceeded)
	{
		if (!CreateStageSets(aSet, stageSets, originalSetNeeded))
		{
			MarkExitRegion("ForkSessions");
			return FALSE;
		}

		if (!originalSetNeeded)
			// this set can be discarded.  All sessions are now help in
			// the stageSets collection.
      // Warning: this set really won't be discarded at this point if it is a root service type.
      // An object owner still has a reference!  This means there will be two session sets
      // containing each of the sessions involved in the fork.  The original will still be used
      // as part of GroupComplete processing (e.g. error handling, transaction rollback/commit),
      // while the forked ones will be used by the pipeline to schedule processing.
			aSet->DecreaseSharedRefCount();
	}

	MarkExitRegion("ForkSessions");

	// TODO: this doesn't seem to be propagating correctly
  BOOL success = TRUE;

  // send the error information through the sessions
  if (!processSucceeded)
	{
		MarkRegion errorRegion("MarkErrors");

		// big loop over session set
		SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
		HRESULT hr = it.Init(aSet);
		if (FAILED(hr))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to step through session set");
			SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}

		while (TRUE)
		{
			MTPipelineLib::IMTSessionPtr session = it.GetNext();
			if (session == NULL)
				break;

			BOOL markIt =
				!batchAwarePlugin
				|| session->GetCompoundMarkedAsFailed() == VARIANT_TRUE;
			if (markIt)
			{
				session->SetStringProperty(plugInNameID, (const char *) batchError.GetPlugInName().c_str());
				session->SetStringProperty(stageNameID, (const char *) batchError.GetStageName().c_str());
				if (!batchAwarePlugin)
				{
					// only set if it's not a "batch aware" plug-in.  otherwise
					// it would have already been set.
					session->MarkAsFailed((const char *) batchError.GetErrorMessage().c_str(),
																batchError.GetErrorCode());
				}
			}
		}

		// this (should) remove the session from the shared memory
		// it will also do any signalling back to the parent if part of a compound.
    // the above statement isn't quite true!  for root service types, there is an
    // object owner that has a reference to this set.  it isn't until this object owner
    // is dispensed with that the set is deleted.
		if (!MarkSetComplete(aSet, arGroupsComplete))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to mark set complete!");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			success = FALSE;
		}
	}
	else
	{
		//
		// sends sets to next stage
		//
		if (!StageComplete(stageSets, arGroupsComplete, arMessages))
			success = FALSE;
	}

	mLogger.LogThis(LOG_DEBUG, "Stage idle.");
	return processSucceeded;
}



BOOL PipelineStage::StageComplete(LongToSessionSetMap & arStageSets,
																	vector<long> & arGroupsComplete,
																	vector<ProcessSetMessage> & arMessages)
{
	MarkRegion region("StageComplete");

	const char * functionName = "PipelineStage::SessionsProcessed";

	for (LongToSessionSetMap::iterator it = arStageSets.begin();
			 it != arStageSets.end(); ++it)
	{

		long nextStageID = it->first;
		MTPipelineLib::IMTSessionSetPtr sessionSet = it->second;
		
		mLogger.LogVarArgs(LOG_DEBUG, "Session set %d has completed",
											 sessionSet->Getid());
		
		if (nextStageID == -1) // final stage?
		{
			// the set has reached its final stage so mark it complete
			mLogger.LogThis(LOG_DEBUG, "Marking set as complete");

			if (!MarkSetComplete(sessionSet, arGroupsComplete))
				return FALSE;
		}
		else
		{
			// otherwise, the set is in still in transit to its final stage
			if (!MarkSetInTransit(sessionSet, nextStageID))
			{
				mLogger.LogThis(LOG_ERROR, "Unable to mark set as in transit");
				return FALSE;
			}

			ProcessSetMessage message;
			message.mSetID = sessionSet->Getid();
			sessionSet->GetUID(message.mUID);
			message.mNextStageID = nextStageID;
			arMessages.push_back(message);
		}
	}

	return TRUE;
}

BOOL PipelineStage::RollbackSessionsInProcess()
{
	mLogger.LogThis(LOG_INFO, "Rolling back sessions in progress by this stage.");

	mSessionServer->DeleteSessionsInProcessBy(mStageID);
	return TRUE;
}

BOOL PipelineStage::GroupComplete(int aObjectOwnerID,
																	vector<MTPipelineLib::IMTTransactionPtr> & arPendingTransactions)
{
	BOOL success = TRUE;
	// first send messages to all stage that ask for it.
	MTPipelineLib::IMTObjectOwnerPtr headObjectOwner = mSessionServer->GetObjectOwner(aObjectOwnerID);
	MTPipelineLib::IMTObjectOwnerPtr objectOwner = headObjectOwner;

	ASSERT(objectOwner->GetIsComplete() == VARIANT_TRUE
		|| objectOwner->GetErrorFlag() == VARIANT_TRUE);

	if (objectOwner->GetNotifyStage() == VARIANT_TRUE)
	{
		// notify another stage that this group of sessions has finished

		// even when object owners are chained together, always use the
		// ID of the first/primary one.  The other objects just hold additional
		// stage IDs

		while (TRUE)
		{
			long stageId = objectOwner->GetStageID();

			// send a message to all the stages that care about this.
			StageIDAndName idAndName = mpHarness->GetStage(stageId);

			mLogger.LogVarArgs(LOG_DEBUG, "Sending group complete message to %s",
												 (const char *) idAndName.mStageName.c_str());

			if (!GetTransmitter()->SendGroupComplete(aObjectOwnerID,
																							 idAndName.mStageName.c_str()))
			{
				SetError(GetTransmitter()->GetLastError());
				success = FALSE;
				break;
			}

			int next = objectOwner->GetNextObjectOwnerID();
			if (next == -1)
				break;

			objectOwner = mSessionServer->GetObjectOwner(next);
		}
	}
	else if (objectOwner->GetSendFeedback() == VARIANT_TRUE)
	{
		MarkRegion region("SendFeedback");

		// send feedback on this session set
		// NOTE: this also means we must complete processing on the session
		// before sending feedback

		BOOL overallErrorFlag = FALSE;
		vector<int> setIDs;
		while (TRUE)
		{
			long setId = objectOwner->GetSessionSetID();
			setIDs.push_back(setId);
			BOOL errorFlag = (objectOwner->GetErrorFlag() == VARIANT_TRUE);
			if (errorFlag)
				overallErrorFlag = TRUE;

			BOOL wantFeedback = TRUE;
			BOOL transactional = (objectOwner->GetTransactionID().length() > 0);
			BOOL processingSuccess = CompleteProcessing(setId, errorFlag,
																									wantFeedback, transactional,
																									arPendingTransactions);
			if(!processingSuccess)
				success = FALSE;

			int next = objectOwner->GetNextObjectOwnerID();
			if (next == -1)
				break;

			objectOwner = mSessionServer->GetObjectOwner(next);
		}

		if (success)
			success = PrepareFeedback(setIDs, overallErrorFlag);
		else
			mLogger.LogThis(LOG_ERROR,
											"Error attempting to complete processing, no feedback sent");
	}
	else
	{
		MarkRegion region("CompleteProcessing");

		ASSERT(objectOwner->GetCompleteProcessing() == VARIANT_TRUE);

		BOOL errorFlag = (objectOwner->GetErrorFlag() == VARIANT_TRUE);

		BOOL wantFeedback = FALSE;
		BOOL transactional = (objectOwner->GetTransactionID().length() > 0);

		while (TRUE)
		{
			long setId = objectOwner->GetSessionSetID();

			BOOL processingSuccess =
				CompleteProcessing(setId, errorFlag,
													 wantFeedback, transactional,
													 arPendingTransactions);

			if(!processingSuccess)
				success = FALSE;

			int next = objectOwner->GetNextObjectOwnerID();
			if (next == -1)
				break;

			objectOwner = mSessionServer->GetObjectOwner(next);
		}
	}
		
	//
	// now delete the objects
	// NOTE: it's important that nothing else will be referencing these
	//
	(void) headObjectOwner->DecreaseSharedRefCount(); //this is where the session set should be deleted from shared memory

	if (!success)
	{
		mLogger.LogThis(LOG_ERROR, "Error completing processing");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
	}

	return success;
}

BOOL PipelineStage::PrepareFeedback(const vector<int> & arSetIDs,
																		BOOL aErrorFlag)
{
	vector<MTPipelineLib::IMTSessionSetPtr> sessionSets;

	for (int i = 0; i < (int) arSetIDs.size(); i++)
	{
		int setID = arSetIDs[i];
		mLogger.LogVarArgs(LOG_DEBUG, "Sending feedback for session set %d", setID);

		MTPipelineLib::IMTSessionSetPtr sessionSet = mSessionServer->GetSessionSet(setID);
		sessionSets.push_back(sessionSet);
	}

	// send in express mode.
	// TODO: do we need a reliable send?
	if (!mpHarness->SendFeedback(sessionSets, aErrorFlag, TRUE))
	{
		SetError(*mpHarness);
		return FALSE;
	}

	return TRUE;
}

void PipelineStage::PopulateErrorObject(SessionErrorObject & arErrObj,
																				MTPipelineLib::IMTSessionPtr aSession)
{
	long plugInNameID = mpHarness->GetNameID()->GetNameID("_PlugInName");
	long stageNameID = mpHarness->GetNameID()->GetNameID("_StageName");

	arErrObj.SetErrorCode(
		aSession->GetLongProperty(PipelinePropIDs::ErrorCodeCode()));
	arErrObj.SetErrorMessage(
		aSession->GetStringProperty(PipelinePropIDs::ErrorStringCode()));

	// not useful
	arErrObj.SetLineNumber(-1);
	arErrObj.SetModuleName("unknown");
	arErrObj.SetProcedureName("unknown");

	arErrObj.SetStageName(aSession->GetStringProperty(stageNameID));
	arErrObj.SetPlugInName(aSession->GetStringProperty(plugInNameID));
}


BOOL PipelineStage::CompleteProcessing(
	int aSetID, BOOL aErrorsFlagged,
	BOOL aWantFeedback,
	BOOL aTransactional,
	vector<MTPipelineLib::IMTTransactionPtr> & arPendingTransactions)
{
	const char * functionName = "PipelineStage::CompleteProcessing";

	mLogger.LogVarArgs(LOG_DEBUG, "Completing processing of session set %d", aSetID);

	BOOL success = TRUE;

	MTPipelineLib::IMTSessionSetPtr sessionSet = mSessionServer->GetSessionSet(aSetID);

	if (!aErrorsFlagged)
	{
		// processing succeeded
		// session set receipt
		if (!mpHarness->SendReceiptOfSuccess(sessionSet, FALSE))
		{
			SetError(*mpHarness);
			mLogger.LogThis(LOG_ERROR, "Unable to send receipt to audit queue");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			success = FALSE;
		}

   	AddToSessionsProcessed(sessionSet->GetCount());
  	mLogger.LogThis(LOG_DEBUG, "Completed processing of session set.");
	}
	else
	{
		MarkRegion region("ProcessFailure");

		// big loop over session set
		SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
		HRESULT hr = it.Init(sessionSet);
		if (FAILED(hr))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to step through session set");
			SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}

			// commit or rollback the transaction.  always done after
			// the stage is complete, even if this session is going to another stage.
			// NOTE: this only has to be done once per session set since they should
			// all have the same owner and therefore the same transaction
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session != NULL)
			{
				if (!mpHarness->ProcessCurrentTransaction(session, aErrorsFlagged))
				{
					SetError(*mpHarness);
					mLogger.LogThis(LOG_ERROR, "Unable to commit transaction");
					mLogger.LogErrorObject(LOG_ERROR, GetLastError());
					success = FALSE;
				}
			}

			//
			// send the whole session set to the error queue
			//
			// parts of the set can only be resubmitted if we're not transactional
			// and the set was not metered synchronously.
		BOOL canAutoResubmit = (!aTransactional && !aWantFeedback);

    // For a bit of added robustness, we will retry writing of error information.
    // One has to be prepared to retry several times because connection pooling seems
    // to result in us getting bad connections even after connectivity is restored.
    static const int numRetries(5);
    int i = numRetries;
    while(i-- > 0)
    {
      // ok, we are not writing messages to the error queue, we don't need msmq transactions, but we need dtc transactions.
      MTPipelineLib::IMTTransactionPtr aTransaction;
      hr = aTransaction.CreateInstance(MTPROGID_MTTRANSACTION);
      aTransaction->Begin("starting new?", aTransaction->GetDefaultTimeout());


      // Only record errors if the session/session set was metered
      // synchronously.
      if (!aWantFeedback)
      {
        if (!mpHarness->RecordBatchError(sessionSet, aTransaction, canAutoResubmit))
        {
          if(i==0)
          {
            SetError(*mpHarness);
            // TODO: send this to the event log?
            if (!GetLastError())
              mLogger.LogThis(LOG_FATAL, "Unable to record session failure: UNKNOWN ERROR");
            else
              mLogger.LogErrorObject(LOG_FATAL, GetLastError());
            success = FALSE;
            arPendingTransactions.push_back(aTransaction);
            break;
          }
          else
          {
            if (!mpHarness->GetLastError())
              mLogger.LogThis(LOG_ERROR, "Unable to record session failure: UNKNOWN ERROR.  Retrying...");
            else
            {
              mLogger.LogThis(LOG_ERROR, "Unable to record session failure.  Retrying...");
              mLogger.LogErrorObject(LOG_ERROR, mpHarness->GetLastError());
            }            
            aTransaction->Rollback();
            continue;
          }
        }
      }

      //
      // session set receipt
      // 
      // always send a receipt if processing failed.
      // otherwise only send one when we're the final stage
      // NOTE: this MUST be done after the errors are recorded because the
      // error handling code needs to reference the original message
      if (!mpHarness->SendReceiptOfError(sessionSet, aTransaction, FALSE))
      {
        if(i==0)
        {
          SetError(*mpHarness);
          mLogger.LogThis(LOG_FATAL, "Unable to send receipt to audit queue");
          mLogger.LogErrorObject(LOG_FATAL, GetLastError());
          success = FALSE;
          arPendingTransactions.push_back(aTransaction);
          break;
        }
        else
        {
          mLogger.LogThis(LOG_ERROR, "Unable to send receipt to audit queue.  Retrying...");
          mLogger.LogErrorObject(LOG_ERROR, mpHarness->GetLastError());
          aTransaction->Rollback();
          continue;
        }
      }


      if(success == TRUE && i < numRetries  - 1)
      {
          mLogger.LogThis(LOG_INFO, "Succeeded recording session failure after retrying.");        
      }
      // We have success or are done retrying, don't commit or rollback here but pass the transaction up the food
      // chain for processing.
      arPendingTransactions.push_back(aTransaction);
      break;
    }

	AddToSessionsProcessed(sessionSet->GetCount());

	mLogger.LogThis(LOG_DEBUG, "Completed processing of session set.");
	}

	return success;
}


/*
 * session/set manipulation
 */

BOOL PipelineStage::BeforeSessionRemoval(MTPipelineLib::IMTSessionPtr aSession)
{

	return TRUE;
}

BOOL PipelineStage::MarkSessionComplete(MTPipelineLib::IMTSessionPtr aSession,
																				vector<long> & arGroupsComplete)
{
	aSession->DecreaseSharedRefCount();

	// send notifications now after the ref counts have been adjusted
	mLogger.LogVarArgs(LOG_DEBUG, "Marking session %d complete", aSession->GetSessionID());
  // IMTSession::MarkComplete decrements the waiting count on the object owner (if it has one).
  // If the session has an object owner and the waiting count of the owner hits 0, then MarkComplete
  // returns VARIANT_TRUE.
	VARIANT_BOOL groupComplete = aSession->MarkComplete();
	if (groupComplete == VARIANT_TRUE)
	{
		long ownerId = aSession->GetObjectOwnerID();
		if (ownerId != -1)
			arGroupsComplete.push_back(ownerId);
	}

	return TRUE;
}


BOOL PipelineStage::MarkSetInTransit(MTPipelineLib::IMTSessionSetPtr aSet, long aID)
{
	return SetOperation(aSet, &PipelineStage::OpMarkInTransit, &aID);
}

BOOL PipelineStage::MarkSetComplete(MTPipelineLib::IMTSessionSetPtr aSet,
																		vector<long> & arGroupsComplete)
{
	const char * functionName = "PipelineStage::MarkSetComplete";

	MarkRegion region("MarkSetComplete");

	aSet->DecreaseSharedRefCount();

	BOOL markedComplete = TRUE;
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;

		if (!MarkSessionComplete(session, arGroupsComplete))
			markedComplete = FALSE;
	}

	return markedComplete;
}



/*
 * set operations
 */

BOOL PipelineStage::SetOperation(MTPipelineLib::IMTSessionSetPtr aSet,
																 SetFunction aOperation, void * apArg)
{
	const char * functionName = "PipelineStage::SetOperation";

	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
	
	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;

		// perform the operation
		BOOL res = (this->*aOperation)(session, apArg);
		if (!res)
			return FALSE;
	}

	return TRUE;
}

BOOL PipelineStage::OpMarkInTransit(MTPipelineLib::IMTSessionPtr aSession, void * apArg)
{
	long * id = (long *) apArg;
	ASSERT(id);
	aSession->PutInTransitTo(*id);

	return TRUE;
}

BOOL PipelineStage::OpMarkInProcess(MTPipelineLib::IMTSessionPtr aSession, void * apArg)
{
	long * id = (long *) apArg;
	ASSERT(id);
	aSession->PutInProcessBy(*id);
	return TRUE;
}

StageMessageTransmitter * PipelineStage::GetTransmitter()
{
	return mpScheduler->GetTransmitter();
}


/*
 * statistics
 */

// TODO: make these methods thread safe
void PipelineStage::LogPerfData()
{
#if 0
	int sent = mpTransmitter.GetMessagesSent();
	int recv = mReceiver.GetMessagesReceived();

	int failed = GetSessionsFailed();
	int processed = GetSessionsProcessed();
	long micros = GetProcessedSessionTimeSpan();
	double sps = ((double) processed * 1000000.0) / (double) micros;
	mLogger.LogVarArgs(LOG_INFO,
										 "Performance: %d messages sent, %d messages received, "
										 "%d sessions processed, %d sessions failed.  %f sessions/sec, "
										 "over %ld micros",
										 sent, recv, processed, failed,
										 sps, micros);
#endif
}

long PipelineStage::GetProcessedSessionTimeSpan() const
{
	LARGE_INTEGER last;
	last.LowPart = mLastSessionProcessed.dwLowDateTime;
	last.HighPart = mLastSessionProcessed.dwHighDateTime;

	LARGE_INTEGER first;
	first.LowPart = mFirstSessionProcessed.dwLowDateTime;
	first.HighPart = mFirstSessionProcessed.dwHighDateTime;


	LONGLONG diff = last.QuadPart - first.QuadPart;

	// diff is in 100-nanosecond intervals.  convert to microseconds
	return long(diff / 10);
}

void PipelineStage::AddToSessionsProcessed(int aCount)
{
	if (IsFinalStage())
	{
		// NOTE: reenable to get a print out as sessions are processed
#if 0
		static TimingInfo * gTimingInfo = new TimingInfo(3000);

		gTimingInfo->AddTransactions(aCount);
#endif

		// update the perfmon counter
		mPerfShare.GetWriteableStats().UpdateSessionsRated(aCount);
	}

	mSessionsProcessed += aCount;	


	if (mFirstSessionProcessed.dwLowDateTime == 0
			&& mFirstSessionProcessed.dwHighDateTime == 0)
		::GetSystemTimeAsFileTime(&mFirstSessionProcessed);

	::GetSystemTimeAsFileTime(&mLastSessionProcessed);
}

void PipelineStage::AddToSessionsFailed(int aCount)
{
	mSessionsFailed += aCount;
}

int PipelineStage::GetSessionsProcessed() const
{
	return mSessionsProcessed;
}

int PipelineStage::GetSessionsFailed() const
{
	return mSessionsFailed;
}

BOOL PipelineStage::CreateStageSets(MTPipelineLib::IMTSessionSetPtr & arOriginalSet,
																		LongToSessionSetMap & arStageSets,
																		BOOL & arOriginalSetNeeded)
{
	const char * functionName = "PipelineStage::CreateStageSets";
	LongToSessionMultimap stageMultimap;

	arOriginalSetNeeded = FALSE;

	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(arOriginalSet);
	if (FAILED(hr))
	{
		mLogger.LogThis(LOG_ERROR, "Unable to step through session set");
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	BOOL forkFound = FALSE;

	// loops over the original session set
	while(TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;
		
		BOOL propertyFound = FALSE;
		if (session->PropertyExists(PipelinePropIDs::NextStageCode(),
																MTPipelineLib::SESS_PROP_TYPE_STRING))
		{
			// the _nextStage property was found in this session 
		 
			std::string forkedNextStage;
			forkedNextStage = (char *) session->GetStringProperty(PipelinePropIDs::NextStageCode());

			// the property may be set to empty string if _nextStage was previously
			// used in a different stage. (properties cannnot be un-set, just cleared)
			if (forkedNextStage != "")
			{
				propertyFound = TRUE;
				
				long forkedNextStageID;
				if (forkedNextStage == "!") // final stage?
					forkedNextStageID = -1;
				else
				{
					forkedNextStageID = mpHarness->GetStageID(forkedNextStage.c_str());
					if (forkedNextStageID == -1)
					{
						mLogger.LogVarArgs(LOG_ERROR, "Cannot fork to unknown stage: %s", forkedNextStage.c_str());
						SetError(PIPE_ERR_INVALID_STAGE_ID, ERROR_MODULE, ERROR_LINE, functionName);
						return FALSE;
					}
				}
				if (!forkFound)
					forkFound = TRUE;

				stageMultimap.insert(LongSessionPair(forkedNextStageID, session));

				// clears the _nextStage property which enforces stage-wide scope
				session->SetStringProperty(PipelinePropIDs::NextStageCode(), "");
			}
		}

		if (!propertyFound)
		{
			// the _nextStage property was not found 

			// NOTE: if all of sessions in the original set are found not to fork then this
			// information won't be used. if there is just one fork though, we need to
			// split the original session set. unfortunately we don't know this
			// until after we've looked at every session in the set. 

			// adds the session using original next stage ID
			stageMultimap.insert(LongSessionPair(mNextStageID, session));
		}
	}

	// TODO: handle efficiently the case of a set of 1 session which forks

	if (forkFound == FALSE)
	{
		// no forks were found, so add the original session set to
		// the stage ID map with the original next stage
		arStageSets[mNextStageID] = arOriginalSet;

		// don't discard the original set
		arOriginalSetNeeded = TRUE;
		return TRUE;
	}
	
	mLogger.LogVarArgs(LOG_DEBUG, "Stage forking detected in session set");

	// the original session set must now be broken down into
	// as many session sets as there were forks to unique stages
	MTPipelineLib::IMTSessionSetPtr sessionSet;
	long stageID = -2;
	long oldStageID = -2; // can't use -1 (final stage)
	long sessionCount = 0;
	for (LongToSessionMultimap::iterator multiIt = stageMultimap.begin();
			 multiIt != stageMultimap.end();
			 ++multiIt)
	{
		stageID = multiIt->first;
		MTPipelineLib::IMTSessionPtr session = multiIt->second;
		
		// if this is the first time we've seen this stage ID
		if (stageID != oldStageID)
		{			
			// creates a new session set
			sessionSet = NULL;
			sessionSet = mSessionServer->CreateSessionSet();
			sessionSet->IncreaseSharedRefCount();

			if (oldStageID != -2) // don't log the first time
				mLogger.LogVarArgs(LOG_DEBUG, "   created new session set (%d) with %d sessions headed toward stage %d",
													 sessionSet->Getid(), sessionCount, oldStageID);

			// puts the session set in the results map
			arStageSets[stageID] = sessionSet; 

			sessionCount = 0;
			oldStageID = stageID;
		}

		ASSERT(sessionSet != NULL);
		
		sessionSet->AddSession(session->GetSessionID(), session->GetServiceID());
		sessionCount++;
	}
	// logs the last session set
	mLogger.LogVarArgs(LOG_DEBUG, "   created new session set with %d sessions headed toward stage %d",
										 sessionCount, stageID);
	
	ASSERT(forkFound);

	return TRUE;
}

