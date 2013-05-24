/**************************************************************************
 * HARNESS
 *
 * Copyright 1997-2004 by MetraTech Corp.
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
#import "Rowset.tlb" rename ("EOF", "RowsetEOF") 

#include <mtcomerr.h>

#include <harness.h>
#include <StageReference.h>
#include <mtprogids.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <MSIX.h>
#include <propids.h>
#include <mtprogids.h>
#include <SetIterate.h>
#include <queue.h>
#include <makeunique.h>
#include <stageschedule.h>
#include <stage.h>
#import <RCD.tlb>
#include <RcdHelper.h>
#include <stdutils.h>
#include <algorithm>
#include <mttime.h>
#include <perflog.h>
#include <pipemessages.h>
#include <failures.h>

#include <sessionerr.h>

#include <memhook.h>
#include <ConfigDir.h>

#include <formatdbvalue.h>  // For FormatValueForDB()
#include <atlconv.h>        // For W2A
// CORE-1133 added some more logging when a plugin fails
#include <boost/format.hpp>
#import <MetraTech.Utils.tlb> inject_statement("using namespace mscorlib;")

//#include "DistributedTransaction.h"

_COM_SMARTPTR_TYPEDEF(ITransaction, IID_ITransaction);

#pragma warning(disable: 4244)

static void TruncateString(std::string & arTruncated, int aMaxLen)
{
	if (arTruncated.length() > (unsigned) aMaxLen)
		arTruncated.resize(aMaxLen);
}

BOOL PipelineStageHarnessBase::ReevaluateFlow()
{
  const char * functionName = "PipelineStageHarnessBase::ReevaluateFlow()";
  double capacity;
	if (!mFlowControl.ReevaluateFlow(&capacity))
	{
		SetError(mFlowControl);
		return FALSE;
	}

	return TRUE;
}

BOOL PipelineStageHarnessBase::RequiresFeedback(MTPipelineLib::IMTSessionPtr aSession)
{
	return mFeedback.RequiresFeedback(aSession);
}


BOOL PipelineStageHarnessBase::SendFeedback(
	const vector<MTPipelineLib::IMTSessionSetPtr> & arSessionSets,
	BOOL aError, BOOL aExpress)
{
	if (!mFeedback.SendFeedback(arSessionSets, aError, aExpress))
	{
		SetError(mFeedback);
		return FALSE;
	}
	return TRUE;
}

int PipelineStageHarnessBase::GetStageID(const char * apStageName) const
{
	return mPipelineInfo.GetStageID(apStageName);
}

StageIDAndName PipelineStageHarnessBase::GetStage(int aId)
{
	return mPipelineInfo.GetStage(aId);
}

/*************************************** PipelineStageThread ***/
// worker thread
int PipelineStageThread::ThreadMain()
{
  //Do ComInitialize at a thread level
  //because we encountered some weird interactions with Oracle libraries
  //if we do ComInit at a process level.
  ComInitialize cominit;
	const char * functionName = "PipelineStageThread::ThreadMain";

	int retval = ThreadMainInternal();

//	mLogger.LogVarArgs(LOG_DEBUG, "Queueing thread exiting with status %d", retval);
	return retval;
}

int PipelineStageThread::ThreadMainInternal()
{
//	int mMaxSessions = -1;

	// tell the controller we're ready
	mpStage->SendStageReadyMessage();


	while (!mpStage->GetExitFlag())
	{
		try
		{
			if (!mpStage->ProcessMessage())
			{
//			PrintError("Unable to process pipeline message", stage.GetLastError());
				break;
			}
		}
		catch (_com_error & err)
		{
			std::string buffer;
			StringFromComError(buffer, "Unhandled exception thrown while processing a pipeline message", err);
			cout << buffer.c_str() << endl;
		}
	}

	if (!mpStage->StopProcessing())
	{
//		PrintError("Unable to stop processing", stage.GetLastError());
		return FALSE;
	}

	mpStage->LogPerfData();
	int processed = mpStage->GetSessionsProcessed();
	cout << "Total sessions processed: " << processed << endl;
	return TRUE;
}


PipelineStageThread::~PipelineStageThread()
{
	StopThread(INFINITE);
	mpStage = NULL;
}

const char * PipelineStageThread::GetStageName() const
{
	return mpStage->GetName().c_str();
}

/************************************** PipelineStageHarnessBase ***/
PipelineStageHarnessBase::PipelineStageHarnessBase()
	: mExitFlag(FALSE),
	  mpRouter(NULL),
	  mStartAsleep(FALSE),
    mFailureWriter(NULL)
{ 
	InitializeCriticalSection(&m_cs);
}

PipelineStageHarnessBase::~PipelineStageHarnessBase()
{
	DeleteCriticalSection(&m_cs);

	Clear();

#ifdef MT_MEM_LOG
	StopMemoryActivityLog();
#endif

	if(mFailureWriter)
	{
		delete mFailureWriter;
		mFailureWriter = NULL;
	}

	if (mpRouter)
	{
		delete mpRouter;
		mpRouter = NULL;
	}
}

void PipelineStageHarnessBase::Clear()
{
	// stop the configuration change notification
	// thread so we don't recursively signal changes
	// and reinitialize the stage
	mConfigObservable.StopThread(INFINITE);

	DisableProcessing();

	//ASSERT(mWaitingSessionList.entries() == 0);

	ClearExitFlag();

	// clear the stages
	// TODO: lock the list?
	StageListIterator it;
	for (it = mStages.begin(); it != mStages.end(); it++)
	{
		StageScheduler * stage = *it;
		stage->Clear();
		delete stage;
	}
	mStages.clear();


	StageThreadListIterator it2;
	for (it2 = mStageThreads.begin(); it2 != mStageThreads.end(); it2++)
	{
		PipelineStageThread * thread = *it2;
		delete thread;
	}
	mStageThreads.clear();

	// Need to release the reference on the mTransactionConfig object;
	mTransactionConfig->ReleaseInstance();
}

BOOL PipelineStageHarnessBase::Init(const char * apConfigPath,
									std::list<std::string> & arStageNames,
									BOOL aStartAsleep)
{
#ifdef MT_MEM_LOG
	LogMemoryActivity();
#endif

	if (!InitInternal(apConfigPath, arStageNames, aStartAsleep))
	{
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}
	return TRUE;
}

// TODO: very temporary patch.  dump the assert text to stderr, then
// signal the C runtime library to invoke a breakpoint exception.
int DirectReportHook(int reportType, char *userMessage, int *retVal)
{
	if (reportType == _CRT_ASSERT)
	{
		cerr << userMessage;

		*retVal = 1;								// this means do an int 3 (breakpoint)

		return TRUE;								// this mean don't call the normal handling
	}
	else
	{
		*retVal = 0;								// don't break
		return FALSE;
	}
}

BOOL PipelineStageHarnessBase::InitInternal(const char * apConfigPath,
																				std::list<std::string> & arStageNames,
																				BOOL aStartAsleep)
{
	const char * functionName = "PipelineStageHarnessBase::InitInternal";

	// override the normal assert handling so we don't do a popup.
	_CrtSetReportHook(DirectReportHook);

	mConfigPath = apConfigPath;

	// TODO: better init here
	std::string tag("[");
	tag += "stageharness";
	tag += ']';
	LoggerConfigReader configReader;
	if (!mLogger.Init(configReader.ReadConfiguration("logging"), tag.c_str()))
	{
		SetError(mLogger);
		return FALSE;
	}
	
	// initialize any singletons so they're only initialized once
	if (!InitializeSingletons())
		return FALSE;

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

//	mLogger.LogVarArgs(LOG_INFO, "Stage %s has process ID %ld", apStageName, pid);

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
	// read the main pipeline configuration file
	//

	mLogger.LogThis(LOG_DEBUG, "Reading pipeline configuration file");
	PipelineInfoReader pipelineReader;
	// TODO: have to convert from one namespace to another
	MTConfigLib::IMTConfigPtr config((MTConfigLib::IMTConfig *)(MTPipelineLib::IMTConfig *) mConfig);
	if (!pipelineReader.ReadConfiguration(config, apConfigPath, mPipelineInfo))
	{
		SetError(pipelineReader.GetLastError());
		return FALSE;
	}

	//
	// initialize the system context object
	//
	// NOTE: this isn't a full sys context object.  It's
	// just enough to get writeproductview initialized.  See
	// stage.cpp for a procedure to fully initialize.
	mLogger.LogThis(LOG_DEBUG, "Initializing syscontext object");
	hr = mSysContext.CreateInstance(MTPROGID_SYSCONTEXT);
	if (FAILED(hr))
	{
		// TODO: pass win32 or hresult?
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
			"Could not create an instance of " MTPROGID_SYSCONTEXT);
		return FALSE;
	}

	//
	// initialize the pipeline control object
	//
	mLogger.LogThis(LOG_DEBUG, "Initializing pipeline control object");
	hr = mPipelineControl.CreateInstance(MTPROGID_PIPELINE);
	if (FAILED(hr))
	{
		// TODO: pass win32 or hresult?
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
			"Could not create an instance of " MTPROGID_PIPELINE);
		return FALSE;
	}
	

	//
	// initialize the session server
	//
	mLogger.LogThis(LOG_DEBUG, "Initializing session server.");
	hr = mSessionServer.CreateInstance(MTPROGID_SESSION_SERVER);
	if (FAILED(hr))
	{
		// TODO: pass win32 or hresult?
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Could not create an instance of " MTPROGID_SESSION_SERVER);
		return FALSE;
	}

	mLogger.LogVarArgs(LOG_INFO, "Initializing shared memory (%s, %s, %d).",
										 (const char *) mPipelineInfo.GetSharedSessionFile().c_str(),
										 (const char *) mPipelineInfo.GetShareName().c_str(),
										 (const char *) mPipelineInfo.GetSharedFileSize());

	try
	{
	   mSessionServer->Init((const char *) mPipelineInfo.GetSharedSessionFile().c_str(),
							(const char *) mPipelineInfo.GetShareName().c_str(), 
							mPipelineInfo.GetSharedFileSize());
	}	
	catch(_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Error while initializing memory ", err);

		mLogger.LogThis(LOG_FATAL, buffer.c_str());
		mLogger.LogThis(LOG_FATAL, (const char *) err.Description());
		mLogger.LogThis(LOG_FATAL, (const char *) err.Source());

        // Adding a sleep of 1000 ms here to ensure that all error messages are written to the log file
        // before the process aborts and kills all the threads.
		// Sleep(1000);
		
		mLogger.FlushAllMessages();
		return FALSE;
	}
	catch(...)
	{
       mLogger.LogThis(LOG_FATAL, "Caught ... - unexpected failure");
       return FALSE;
	}

	//
	// initialize system profiler
	//
	const PipelineInfo & pipeInfo = mPipelineInfo;
	if (pipeInfo.ProfileEnabled())
	{
		mCollectProfile = TRUE;

		if (!mProfile.Init(pipeInfo.GetProfileFile().c_str(),
											 pipeInfo.GetProfileShareName().c_str(),
											 pipeInfo.GetProfileSessions(),
											 pipeInfo.GetProfileMessages()))
		{
			SetError(mProfile);
			mLogger.LogThis(LOG_ERROR, "Unable to initialize profile object");
			return FALSE;
		}
	}
	else
		mCollectProfile = FALSE;


	//
	// initialize config change object
	//
	if (!mConfigObservable.Init())
	{
		SetError(mConfigObservable.GetLastError(), "Could not initialize config change observable");
		return FALSE;
	}


	// get the list of extensions in case the user passes in an extension name
	std::set<std::string> extensions;
	if (!GetExtensions(extensions))
		return FALSE;

	// final set of stages
	std::set<std::string> finalStages;

	// set of all stages
	std::set<std::string> allStages;

	{
		std::list<std::string> allStagesList;
		if (!GetStages(allStagesList, ""))
			return FALSE;

		std::list<std::string>::iterator it;
		for (it = allStagesList.begin(); it != allStagesList.end(); ++it)
		{
			std::string name = *it;
			StrToLower(name);
			allStages.insert(name);
		}
	}

	//
	// go through the arguments they pass through and replace
	//   1. extension names with the stages within an extension
	//   2. *all* with all stages in the pipeline
	std::list<std::string>::iterator it;
	for (it = arStageNames.begin(); it != arStageNames.end(); it++)
	{
		std::string name = *it;

		std::string lowerName = name;
		StrToLower(lowerName);

		if (lowerName == "*all*")
		{
			// user passed in the special name *all.
			// replace it with all the stages in the pipeline

			std::list<std::string> stages;
			std::string extension;
			if (!GetStages(stages, extension))
				return FALSE;
			
			finalStages.insert(stages.begin(), stages.end());
		}
		else if (allStages.count(lowerName) > 0)
		{
			// this is a stage name.
			// use it even if it's an extension
			finalStages.insert(lowerName);			
		}
		else if (extensions.count(lowerName) > 0)
		{
			// user passed in an extension name.
			// replace it with all the stages within that extension

			std::list<std::string> stages;
			if (!GetStages(stages, lowerName))
				return FALSE;
			
			finalStages.insert(stages.begin(), stages.end());
		}
		else
			// TODO: this is probably an error
			// this is a stage name
			finalStages.insert(lowerName);
	}

	if (finalStages.size() == 0)
	{
		mLogger.LogThis(LOG_ERROR, "No stages found in requested list");
		SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "No stages found in requested list");
		return FALSE;
	}

  // Create and initialize the stage objects
	std::set<std::string>::iterator it2;
  int stageCount;

	for (it2 = finalStages.begin(); it2 != finalStages.end(); ++it2)
	{
		std::string name = *it2;

    stageCount = GetStageCount(apConfigPath, name);

		for(long i=0; i < stageCount; i++)
		{
			StageScheduler * stage = new StageScheduler;
			cout << "  initializing stage " << name.c_str() << "..." << endl;
			if (!stage->Init(this, apConfigPath, name.c_str(), i, aStartAsleep))
			{
				SetError(*stage);
				return FALSE;
			}

			mStages.push_back(stage);


			PipelineStageThread * thread = new PipelineStageThread;
			thread->SetStage(stage);
			mStageThreads.push_back(thread);
		}
	}

	return TRUE;
}

int PipelineStageHarnessBase::GetStageCount(const char *apConfigPath, std::string &name)
{
  const char * functionName = "PipelineStageHarnessBase::GetStageCount";
  int retval = 1;

  //
	// initialize the config reader
	//
	mLogger.LogThis(LOG_DEBUG, "Initializing configuration reader");
  MTPipelineLib::IMTConfigPtr mConfig;
	HRESULT hr = mConfig.CreateInstance(MTPROGID_CONFIG);
	if (SUCCEEDED(hr))
	{
	  //
	  // initialize the config loader
	  //
	  mLogger.LogThis(LOG_DEBUG, "Initializing configuration loader");
    MTPipelineLib::IMTConfigLoaderPtr mConfigLoader;
	  hr = mConfigLoader.CreateInstance(MTPROGID_CONFIGLOADER);
	  if (SUCCEEDED(hr))
	  {
      mConfigLoader->InitWithPath(apConfigPath);

      //
      // look up the stage XML file
      //
      std::string mStageXmlFile;
      if(GetPipelineInfo().GetStageXmlfile(name.c_str(),mStageXmlFile))
      {
        VARIANT_BOOL flag;

        MTPipelineLib::IMTConfigPropSetPtr propset =
			    mConfig->ReadConfiguration((const char *) mStageXmlFile.c_str(), &flag);

        MTPipelineLib::IMTConfigPropSetPtr stageprops = propset->NextSetWithName("stage");
	    
        if (stageprops != NULL)
        {
          while(stageprops->Next() != NULL)
          {
            if(stageprops->NextMatches("instancecount", MTPipelineLib::PROP_TYPE_INTEGER))
            {
              retval = stageprops->NextLongWithName("instancecount");
              break;
            }
          }
        }
        else
        {
		      SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
						       functionName);
		      mpLastError->GetProgrammerDetail() =
			      "Set " "stage" " not found or not a set";
	      }
      }
      else
      {
	      SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
		      "could not find stage xml configuration file");
      }
    }
    else
    {
      // TODO: pass win32 or hresult?
		  SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
			  "Could not create an instance of " MTPROGID_CONFIGLOADER);
	  }
  }
  else
  {
    // TODO: pass win32 or hresult?
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
			"Could not create an instance of " MTPROGID_CONFIG);
	}

  return retval;
}

BOOL PipelineStageHarnessBase::GetExtensions(std::set<std::string> & arExtensionList)
{
	const char * functionName = "PipelineStageHarnessBase::GetExtensions";

	// create an instance of the RCD
	RCDLib::IMTRcdPtr rcd(MTPROGID_RCD);

	RCDLib::IMTRcdFileListPtr fileList = rcd->GetExtensionList();

	// iterate through the list		
	SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;

	HRESULT hr = it.Init(fileList);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	while (TRUE)
	{
		_variant_t variant = it.GetNext();
		_bstr_t file = variant;

		if (file.length() == 0)
			break;

		std::string lowerName = (const char *) file;
		StrToLower(lowerName);

		arExtensionList.insert(lowerName);
	}
	return TRUE;
}

BOOL PipelineStageHarnessBase::GetStages(std::list<std::string> & arStageList,
																		 const std::string & arExtension)
{
	const char * functionName = "PipelineInfoReader::GetStages";

	// create an instance of the RCD
	RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);

	// run a query for all stage.xml files
	RCDLib::IMTRcdFileListPtr fileList = aRCD->RunQuery("config\\pipeline\\stage.xml",VARIANT_TRUE);

	// iterate through the list		
	SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
	
	HRESULT hr = it.Init(fileList);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	while (TRUE)
	{
		_variant_t variant = it.GetNext();
		_bstr_t file = variant;

		if (file.length() == 0)
			break;

		std::vector<mtstring> vec;

		mtstring query = file;

		// the string now looks like
		// i:\cfg\extensions\audioconf\config\pipeline\audioconfcall\stage.xml
		//        -6         -5        -4     -3       -2            -1
		Tokenize<std::vector<mtstring> >(vec, query);
		std::vector<mtstring>::iterator vectorIt = vec.end();
		vectorIt -= 2;							// get to stage name

		std::string & name = *vectorIt;

		vectorIt -= 3;							// get to extension name
		std::string & extension = *vectorIt;

		if (arExtension.length() != 0)
		{
			// an extension name was specified and it matched
			if (0 == strcasecmp(extension, arExtension))
					arStageList.push_back(name);
		}
		else
			// no extension name.
			arStageList.push_back(name);
	}

	return TRUE;
}

BOOL PipelineStageHarnessBase::InitializeSingletons()
{
	const char * functionName = "PipelineStageHarnessBase::InitializeSingletons";

	// The transaction config object should be create as soon as possible.
	// CR: check the transactionconfig is NULL or not

	mTransactionConfig = CTransactionConfig::GetInstance();
	if (mTransactionConfig == NULL)
	{
		// TODO: better error code should be used here
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
			"Could not create a transaction configuration object");
		return FALSE;
	}

	// hold onto an instance of the name ID object so we can guarantee that
	// it stays around in memory

	// TODO: temporary
	mLogger.LogThis(LOG_DEBUG, "Initializing name ID object");
	HRESULT hr = mNameID.CreateInstance(MTPROGID_NAMEID);
	if (FAILED(hr))
	{
		// TODO: pass win32 or hresult?
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
			"Could not create an instance of " MTPROGID_NAMEID);
		return FALSE;
	}

	// TODO: this works around the COM+ 15 second delay issue.
	// we need a cleaner fix!
	hr = mDummyRowset.CreateInstance("MTSQLRowset.MTSQLRowset.1");
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
			"Could not create an instance of " "MTSQLRowset.MTSQLRowset.1");
		return FALSE;
	}
	mDummyRowset->Init("queries\\ProductCatalog");

	// query adapter
	mLogger.LogThis(LOG_DEBUG, "Initializing query cache object");
	hr = mQueryCachePtr.CreateInstance(MTPROGID_QUERYCACHE);
	if(FAILED(hr))
	{
		SetError (hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// enum config
	mLogger.LogThis(LOG_DEBUG, "Initializing enum config object");
	hr = mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);

	if (FAILED(hr))
	{
		SetError (hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// MTSecurity
	mLogger.LogThis(LOG_DEBUG, "Initializing security object");
	hr = mMTSecurity.CreateInstance(MTPROGID_MTSECURITY);
	if (FAILED(hr))
	{
		SetError (hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// MTLoginContext
	mLogger.LogThis(LOG_DEBUG, "Initializing login object");
	hr = mMTLoginContext.CreateInstance(MTPROGID_MTLOGINCONTEXT);
	if (FAILED(hr))
	{
		SetError (hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// NOTE: we don't initialize the enum config object because it may not be used..
	//hr = mEnum->Initialize();
	return TRUE;
}

DWORD WINAPI PipelineStageHarnessBase::WaitThreadFunc(void* apArg)
{
	const char * functionName = "PipelineStageHarnessBase::WaitThreadFunc";

	THREAD_DATA* pData = (THREAD_DATA*) apArg;
	if (!pData)
	{
		//----- Should never get here
		ASSERT(false); // In debug.
		return FALSE;
	}

	//----- Get data.
	PipelineStageHarnessBase* pThis = pData->pThis;
	int nThreadNumber = pData->nThreadNumber;
	int nStartIndex = pData->nStartIndex;
	int nEndIndex = pData->nEndIndex;
	delete pData;

	//----- Wait till all the stage thread quit.
	bool bWaitFirstTime = true;
	while(true)
	{
		//----- Create a vector of running threads.
		std::vector<HANDLE> handles;
		for (int nIndex = nStartIndex; nIndex < nEndIndex; nIndex++)
		{
			::EnterCriticalSection(&pThis->m_cs);
			PipelineStageThread* thread = pThis->mStageThreads.at(nIndex);
			::LeaveCriticalSection(&pThis->m_cs);
			if (thread->GetState() == PipelineStageThread::RUNNING)
			{
				//------ Check if thread quit after wait.
				if (!bWaitFirstTime)
				{
					DWORD dwResult = ::WaitForSingleObject(thread->ThreadHandle(), 0);
					if (dwResult == WAIT_OBJECT_0)
					{
						thread->SetState(PipelineStageThread::STOPPED);
						pThis->mLogger.LogVarArgs(LOG_INFO, "Stage %s thread stopped.", thread->GetStageName());
					}
					else
						handles.push_back(thread->ThreadHandle());
				}
				else
					handles.push_back(thread->ThreadHandle());
			}
		}

		if (handles.size() == 0)
		{
			if (bWaitFirstTime)
			{
				ASSERT(false); // In debug.
				pThis->SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 "No threads to wait for");
				
				char buff[MAX_PATH];
				sprintf(buff, "No threads to wait for. Wait thread %d", nThreadNumber);
				pThis->mLogger.LogThis(LOG_INFO, buff);
				pThis->mLogger.LogErrorObject(LOG_ERROR, pThis->GetLastError());
				return FALSE;
			}

			//----- We're done.
			break;
		}

		//----- Wait for some thread to finish.
		DWORD waitResult = ::WaitForMultipleObjects(handles.size(), &handles[0], FALSE,	INFINITE);
		if (waitResult == WAIT_FAILED)
		{
			pThis->SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
					 	    "Error while waiting for threads");
			char buff[MAX_PATH];
			sprintf(buff, "Error while waiting for threads. Wait thread %d", nThreadNumber);
			pThis->mLogger.LogThis(LOG_INFO, buff);
			pThis->mLogger.LogErrorObject(LOG_ERROR, pThis->GetLastError());
			return FALSE;
		}

		bWaitFirstTime = false;
	} // while(true)

	char buff[MAX_PATH];
	sprintf(buff, "All stage threads assigned to wait thread %d, have quit.", nThreadNumber);
	pThis->mLogger.LogThis(LOG_INFO, buff);
	return TRUE;
}

BOOL PipelineStageHarnessBase::MainLoop(int aMaxSessions)
{
	const char * functionName = "PipelineStageHarnessBase::MainLoop";

  mMaxSessions = aMaxSessions;
  mSessionSetsProcessed = 0LL;

	//-----
	// We cannot wait on more than MAXIMUM_WAIT_OBJECTS number of threads.
	// The way to solve this is to spin of a thread for each block of 
	// MAXIMUM_WAIT_OBJECTS threads and wait on new threads.
	//-----
	std::vector<HANDLE> WaitThreadHandles;

	//xxx TODO: lock the list?

	//----- Start all the stage threads.
	int nThreadNumber = 0;
	int nThreadCounter = 0;
	int nStartIndex = 0;
	StageThreadListIterator it;
	for (it = mStageThreads.begin(); it != mStageThreads.end(); it++)
	{
		PipelineStageThread* thread = *it;

		//------ Start the stage thread.
		thread->StartThread();
		nThreadCounter++;

		//----- Check if the next one will fit into out batch.
		if (nThreadCounter+1 >= MAXIMUM_WAIT_OBJECTS)
		{
			//----- Create data to pass to wait thread.
			THREAD_DATA* pData = new THREAD_DATA;
			pData->pThis = this;
			pData->nThreadNumber = ++nThreadNumber;
			pData->nStartIndex = nStartIndex;
			pData->nEndIndex = nStartIndex + nThreadCounter;

			//----- Adjust indexes.
			nStartIndex = pData->nEndIndex;
			nThreadCounter = 0;

			//----- Start wait thread
			HANDLE hWaitThread = ::CreateThread(NULL, NULL,	(LPTHREAD_START_ROUTINE) WaitThreadFunc,
												pData, NULL, NULL);

			//----- Add wait thread handle to array of threads to block on.
			WaitThreadHandles.push_back(hWaitThread);

			char buff[MAX_PATH];
			sprintf(buff, "Starting stage wait thread %d", pData->nThreadNumber);
			mLogger.LogThis(LOG_INFO, buff);
		}
	}

	//----- If we still have threads to process, do so.
	if (nThreadCounter)
	{
		THREAD_DATA* pData = new THREAD_DATA;
		pData->pThis = this;
		pData->nThreadNumber = ++nThreadNumber;
		pData->nStartIndex = nStartIndex;
		pData->nEndIndex = nStartIndex + nThreadCounter;
		unsigned thrdaddr = 0;
		HANDLE hWaitThread = ::CreateThread(NULL, NULL,	(LPTHREAD_START_ROUTINE) WaitThreadFunc,
											pData, NULL, NULL);
		WaitThreadHandles.push_back(hWaitThread);

		char buff[MAX_PATH];
		sprintf(buff, "Started wait thread %d", pData->nThreadNumber);
		mLogger.LogThis(LOG_INFO, buff);
	}

	//----- Wait for all the wait threads to finish.
	while (true)
	{
		std::vector<HANDLE> CompactWaitThreadHandles;

		//----- Loop through all wait handles to see if they are also done.
		//----- Compact the handle array.
		CompactWaitThreadHandles.clear();
		for (int i = 0; i < (int) WaitThreadHandles.size(); i++)
		{
			HANDLE hWaitThread = WaitThreadHandles[i];
			if (hWaitThread)
			{
				//------ Check if done.
				DWORD dwResult = ::WaitForSingleObject(hWaitThread, 0); // No wait
				if (dwResult == WAIT_OBJECT_0)
				{
					CloseHandle(hWaitThread);
					WaitThreadHandles[i] = NULL;
				}
				else
					CompactWaitThreadHandles.push_back(hWaitThread);
			}
		}

		//----- Check if we are done.
		int nTotalHandles = CompactWaitThreadHandles.size();
		if (!nTotalHandles)
		{
			mLogger.LogThis(LOG_INFO, "All wait threads exited.");
			break; // We're done!
		}

		//----- Wait indefinetely for threads to finish. 
		DWORD waitResult = ::WaitForMultipleObjects(nTotalHandles, &CompactWaitThreadHandles[0], TRUE, INFINITE);
		if (waitResult == WAIT_FAILED)
		{
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName, "Error while waiting for wait threads");
			return FALSE;
		}
	}

	mLogger.LogThis(LOG_INFO, "Exiting harness main loop.");
	return TRUE;
}

BOOL PipelineStageHarnessBase::PrepareStage(const char * apRouteFrom, BOOL aRunAutoTests)
{
	if (!PrepareStageInternal(apRouteFrom && *apRouteFrom ? apRouteFrom : NULL,
														aRunAutoTests))
	{
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}
	else
		return TRUE;
}

BOOL PipelineStageHarnessBase::PrepareStageInternal(const char * apRouteFrom, BOOL aRunAutoTests)
{
	const char * functionName = "PipelineStageHarnessBase::PrepareStage";

	cout << "Preparing stage harness..." << endl;

	// override the routing queue if necessary
	if (apRouteFrom)
		SetRouteFromQueue(apRouteFrom);

	// information for routing messages to and from the pipeline
	// (needed for feedback and for the routing thread)
	MTConfigLib::IMTConfig * iconfig = (MTConfigLib::IMTConfig *) (MTPipelineLib::IMTConfig *) mConfig;
	MTConfigLib::IMTConfigPtr config(iconfig);

	MeterRoutes routeInfo;

	MeterRouteReader routeReader;
	if (!routeReader.ReadConfiguration(config, mConfigPath.c_str(), routeInfo))
	{
		SetError(routeReader.GetLastError());
		return FALSE;
	}

	//
	// initialize the feedback to the listeners.
	// Errors can be sent as well as successes so we always need to
	// initialize.
	//
	if (!mFeedback.Init(routeInfo, mPipelineInfo.UsePrivateQueues()))
	{
		SetError(mFeedback);
		return FALSE;
	}

	//
	// if the stage is configured for routing, start the thread to do routing
	//
	if (RoutesMessages())
	{
		mpRouter = new SessionRouter;

		ListenerInfoReader listenerReader;

		ListenerInfo listenerInfo;
		if (!listenerReader.ReadConfiguration(config, mConfigPath.c_str(), listenerInfo))
		{
			SetError(listenerReader.GetLastError(), "Unable to read listener information");
			return FALSE;
		}

		const std::string & machineName = GetRouteFromMachine();
		const std::string & queueName = GetRouteFromQueue();

		if (!mpRouter->Init(listenerInfo, mPipelineInfo, machineName.c_str(), queueName.c_str(),
												FALSE, routeInfo, mSessionServer))
		{
			mLogger.LogErrorObject(LOG_ERROR, mpRouter->GetLastError());
			SetError(mpRouter->GetLastError(), "Unable to initialize message router");
			return FALSE;
		}

		// start the thread up
		mpRouter->StartThread();
	}


	//
	// initialize the flow control mechanism
	//
	// thresholds must be between 0.0 and 1.0
	if (!mFlowControl.Init(mSessionServer, mPipelineInfo.GetThresholdMin() / 100.0,
												 mPipelineInfo.GetThresholdMax() / 100.0,
												 mPipelineInfo.GetThresholdRejection() / 100.0))
	{
		SetError(mFlowControl);
		return FALSE;
	}

	//
	// prepare the stages
	// TODO: lock the list?
	//
	StageListIterator it;
	for (it = mStages.begin(); it != mStages.end(); it++)
	{
		StageScheduler * stage = *it;
		if (!stage->PrepareStage(aRunAutoTests))
		{
			SetError(*stage);
			return FALSE;
		}
	}

	cout << endl;

	// NOTE: prepare stage is called over and over again
	//       so we only want to 
	//if (!mConfigChangeInitialized)
	//{

	//
	// set up to observe configuration changes
	//
	mConfigObservable.AddObserver(*this);

	if (!mConfigObservable.StartThread())
	{
		SetError(mConfigObservable.GetLastError(), "Could not start config change thread");
		return FALSE;
	}

	// don't initialize again or we'll start another thread
	//mConfigChangeInitialized = TRUE;
	//}

	//
	// make an attempt to free memory used during startup
	//

	// NOTE: this call seems to cause ADO to crash.  right now,
	// we'll avoid the call.  However, we need to figure out if
	// we have an inaccurate ref count to an ADO object or something.

	// free COM libraries that are no longer in use
	//::CoFreeUnusedLibraries();

	// attempt to free up memory used by COM
	IMalloc* iMalloc = NULL;
	if (SUCCEEDED(::CoGetMalloc(1, &iMalloc)))
	{
		iMalloc->HeapMinimize();
		iMalloc->Release();
		iMalloc = NULL;
	}

	// free C runtime memory as much as possible
	_heapmin();


	// reset the working size
	if (!SetProcessWorkingSetSize(::GetCurrentProcess(), -1, -1))
	{
		DWORD err = ::GetLastError();
	}

//	mLogger.LogThis(LOG_INFO, "--- Pipeline stage is ready ---");
	return TRUE;
}


BOOL PipelineStageHarnessBase::EnableProcessing()
{
	return TRUE;
}

BOOL PipelineStageHarnessBase::DisableProcessing()
{
	return TRUE;
}

void PipelineStageHarnessBase::SetExitFlag()
{ mExitFlag = TRUE; }

void PipelineStageHarnessBase::ClearExitFlag()
{	mExitFlag = FALSE; }

BOOL PipelineStageHarnessBase::GetExitFlag() const
{	return mExitFlag; }

void PipelineStageHarnessBase::ConfigurationHasChanged()
{
	// refresh the stage configurations
	// TODO: lock the list?
	StageListIterator it;
	for (it = mStages.begin(); it != mStages.end(); it++)
	{
		StageScheduler * stage = *it;
		stage->ConfigurationHasChanged();
	}
}

void PipelineStageHarnessBase::CalculateFailureCounts(MTPipelineLib::IMTSessionPtr aSession,
                                                      map<wstring, int> & arFailureCounts)
{
	//
	// update the number of failures per batch
	//
	// walk up to the root of the compound
	MTPipelineLib::IMTSessionPtr root = aSession;
	while (root->GetParentID() != -1)
		root = mSessionServer->GetSession(root->GetParentID());

	if (root->PropertyExists(
				PipelinePropIDs::CollectionIDCode(),
				MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
	{
		wstring id =
			root->GetStringProperty(PipelinePropIDs::CollectionIDCode());
			 
		map<wstring, int>::iterator it;
		it = arFailureCounts.find(id);
		if (it == arFailureCounts.end())
		{
			// not found in the map
			arFailureCounts[id] = 1;
		}
		else
		{
			// increment the count
			++(it->second);
		}
	}
}

// This code looks suspicious.  It is being called immediatedly before
// RecordSessionError which also spends a good deal of time populating the
// error object.  Furthermore, I have noticed a few bugs in the code that indicate
// that some of the work it does is in fact always overwritten by RecordSessionError.
// TODO: Decide whether this deserves to live on it own.  Perhaps the only use in this
// method is the update of the failure counts.
void PipelineStageHarnessBase::PopulateErrorObject(
	SessionErrorObject & arErrObj,
	MTPipelineLib::IMTSessionPtr aSession)
{
	long plugInNameID = mNameID->GetNameID("_PlugInName");
	long stageNameID = mNameID->GetNameID("_StageName");

	MTPipelineLib::IMTSessionPtr failedSession = aSession;

	arErrObj.SetErrorCode(
		failedSession->GetLongProperty(PipelinePropIDs::ErrorCodeCode()));
	arErrObj.SetErrorMessage(
		failedSession->GetStringProperty(PipelinePropIDs::ErrorStringCode()));

	// not useful
	arErrObj.SetLineNumber(-1);
	arErrObj.SetModuleName("unknown");
	arErrObj.SetProcedureName("unknown");

	// this information is not known if the session was marked as "cannot resubmit"
	if (failedSession->PropertyExists(stageNameID, MTPipelineLib::SESS_PROP_TYPE_STRING)
		== VARIANT_TRUE)
		arErrObj.SetStageName(failedSession->GetStringProperty(stageNameID));
	else
		arErrObj.SetStageName("unknown");

	if (failedSession->PropertyExists(plugInNameID, MTPipelineLib::SESS_PROP_TYPE_STRING)
		== VARIANT_TRUE)
		arErrObj.SetPlugInName(failedSession->GetStringProperty(plugInNameID));
	else
		arErrObj.SetPlugInName("unknown");
}

BOOL PipelineStageHarnessBase::CollectSuccessfulSessions(
	std::string & arSuccessful,
	std::wstring & arUID,
	const std::string & arSessionSetID,
	const std::vector<MTPipelineLib::IMTSessionPtr> & arErrorsNotMarked)
{
	MarkRegion region("CollectSuccessfulSessions");

	// push all the UIDs into a set so we can search them
	std::set<std::wstring> successfulUIDs;
	for (int i = 0; i < (int) arErrorsNotMarked.size(); i++)
	{
		MTPipelineLib::IMTSessionPtr session = arErrorsNotMarked[i];
		successfulUIDs.insert((const wchar_t *) session->GetUIDAsString());
	}

	//
	// read and parse the old message
	//
	// NOTE: the message is only technically "lost" because
	// it's in the routing queue journal but not the audit queue
	_bstr_t fullMessage = mPipelineControl->GetLostMessage(arSessionSetID.c_str());

	VARIANT_BOOL checksumMatch;
	MTPipelineLib::IMTConfigPropSetPtr original = mConfig->ReadConfigurationFromString(fullMessage, &checksumMatch);

	// generate a new message
	// <msix>
	//   <timestamp>2001-11-14T22:01:38Z</timestamp>
	//   <version>1.1</version>
	//   <uid>wKgBZCAjcO/PyrXRrdy3dw==</uid>
	//   <entity>192.168.1.100</entity>

	std::wstring timestamp = original->NextStringWithName("timestamp");
	std::wstring version = original->NextStringWithName("version");
	std::wstring uid = original->NextStringWithName("uid");
	std::wstring entity = original->NextStringWithName("entity");

	// Get session context, if it exists in the original message
	std::wstring contextUsername, contextPassword, contextNamespace, serializedContext;
	if (original->NextMatches(L"sessioncontextusername", MTPipelineLib::PROP_TYPE_STRING))
		contextUsername = original->NextStringWithName(L"sessioncontextusername");
	if (original->NextMatches(L"sessioncontextpassword", MTPipelineLib::PROP_TYPE_STRING))
		contextPassword = original->NextStringWithName(L"sessioncontextpassword");
	if (original->NextMatches(L"sessioncontextnamespace", MTPipelineLib::PROP_TYPE_STRING))
		contextNamespace = original->NextStringWithName(L"sessioncontextnamespace");
	if (original->NextMatches(L"sessioncontext", MTPipelineLib::PROP_TYPE_STRING))
		serializedContext = original->NextStringWithName(L"sessioncontext");

	MTPipelineLib::IMTConfigPropSetPtr newMessage = mConfig->NewConfiguration("msix");
	//newMessage->InsertProp("timestamp", PROP_TYPE_DATETIME);

	// copy the header
	// NOTE: this is a string, not a date/time
	newMessage->InsertProp("timestamp", MTPipelineLib::PROP_TYPE_STRING, timestamp.c_str());
	newMessage->InsertProp("version", MTPipelineLib::PROP_TYPE_STRING, L"1.1");

	//
	std::string generatedUidBuffer;
	MSIXUidGenerator::Generate(generatedUidBuffer);
	_bstr_t newUid(generatedUidBuffer.c_str());
	arUID = (const wchar_t *) newUid;
	newMessage->InsertProp("uid", MTPipelineLib::PROP_TYPE_STRING, newUid);

	//
	newMessage->InsertProp("entity", MTPipelineLib::PROP_TYPE_STRING, entity.c_str());

	// Attach the session context, if it existed in the original message
	if (contextUsername.length() > 0)
		newMessage->InsertProp("sessioncontextusername",
							   MTPipelineLib::PROP_TYPE_STRING, contextUsername.c_str());
	if (contextPassword.length() > 0)
		newMessage->InsertProp("sessioncontextpassword",
							   MTPipelineLib::PROP_TYPE_STRING, contextPassword.c_str());
	if (contextNamespace.length() > 0)
		newMessage->InsertProp("sessioncontextnamespace",
							   MTPipelineLib::PROP_TYPE_STRING, contextNamespace.c_str());

	if (serializedContext.length() > 0)
		newMessage->InsertProp("sessioncontext",
							   MTPipelineLib::PROP_TYPE_STRING, serializedContext.c_str());

	// return a copy to the caller
	///*apNewUID = newUid.copy();

	// look for all sessions with the UIDs that matches the success list,
	// including child sessions
	MTPipelineLib::IMTConfigPropSetPtr session;

	// As children come in, their UIDs are added to the set.
	// This way we can retrieve the whole tree
	
	while (TRUE)
	{
		session = original->NextSetWithName("beginsession");
		if (session == NULL)
			break;

		//  <beginsession>
		//    <dn>metratech.com/HostedExchange</dn>
		//    <uid>wKgBZCAjcO9NrnPbo9y3dw==</uid>
		//    <parentid>wKgBZLCuQOWoyNy67t3/pw==</parentid> <!-- optional -->

		_bstr_t uid = session->NextStringWithName("uid");
		std::wstring uidTest(uid);
		bool insertSession = false;
		if (successfulUIDs.find(uidTest) != successfulUIDs.end())
		{
			// a match
			insertSession = true;
		}
		else
		{
			if (session->NextMatches("parentid", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
			{
				_bstr_t parentID = session->NextStringWithName("parentid");
				std::wstring childTest = parentID;
				if (successfulUIDs.find(childTest) != successfulUIDs.end())
				{
					// add this session's ID to the set of parents we're looking for
					successfulUIDs.insert(uidTest);	// the parent
					insertSession = true;
				}
			}
		}

		if (insertSession)
		{
			MTPipelineLib::IMTConfigPropSetPtr beginSession = newMessage->InsertSet("beginsession");
			session->Reset();
			beginSession->AddSubSet(session);
		}
	}

	_bstr_t newMessageStr = newMessage->WriteToBuffer();

	// TODO: is this conversion safe?
	arSuccessful = (const char *) newMessageStr;

	return TRUE;
}

BOOL PipelineStageHarnessBase::DivideFailedSessions(
	MTPipelineLib::IMTSessionSetPtr aSessionSet,
	std::vector<MTPipelineLib::IMTSessionPtr> & arErrorsMarked,
	std::vector<MTPipelineLib::IMTSessionPtr> & arErrorsNotMarked,
	HRESULT & arCommonError,
	_bstr_t & arCommonErrorString,
	BOOL & arAllErrorsMatch,
	BOOL aCanAutoResubmit)
{
	const char * functionName = "PipelineStageHarnessBase::DivideFailedSessions";

	MarkRegion region("DivideFailedSessions");

	BOOL foundFirstError = FALSE;

	arAllErrorsMatch = TRUE;

	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSessionSet);
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

		if ((session->GetCompoundMarkedAsFailed() == VARIANT_FALSE)
		     && (!aCanAutoResubmit))
		{
			// even though this session appears to have succeeded, it can't
			// automatically be resubmitted.  Therefore we have to fail it

			_bstr_t message("Session was rolledback and can not be resubmitted");
			session->MarkAsFailed(message,
														PIPE_ERR_CANNOT_AUTO_RESUBMIT);
		}

		if (session->GetCompoundMarkedAsFailed() == VARIANT_TRUE)
		{
			arErrorsMarked.push_back(session);

			MTPipelineLib::IMTSessionPtr failedSession = FindFailedSession(session);
			if (failedSession == NULL)
				return FALSE;

			HRESULT errorCode = failedSession->GetLongProperty(PipelinePropIDs::ErrorCodeCode());
			_bstr_t errorString = failedSession->GetStringProperty(PipelinePropIDs::ErrorStringCode());

			if (!foundFirstError)
			{
				// first error we've seen
				arCommonError = errorCode;
				arCommonErrorString = errorString;
				foundFirstError = TRUE;
			}
			if (arAllErrorsMatch
					&& (errorCode != arCommonError || errorString != arCommonErrorString))
				// this error is different
				arAllErrorsMatch = FALSE;
		}
		else
		{
			// otherwise it would have been marked as failed
			ASSERT(aCanAutoResubmit);

			// this can be resubmitted automatically
			arErrorsNotMarked.push_back(session);
		}
	}

	return TRUE;
}

MTPipelineLib::IMTSessionPtr PipelineStageHarnessBase::FindFailedSession(MTPipelineLib::IMTSessionPtr aSession)
{
	const char * functionName = "PipelineStageHarnessBase::FindFailedSession";

	// find the error code and error string for this session.
	// NOTE: if this is a compound session the error might be
	// a child.

	if (aSession->PropertyExists(PipelinePropIDs::ErrorCodeCode(), MTPipelineLib::SESS_PROP_TYPE_LONG))
		return aSession;
	else
	{
		MTPipelineLib::IMTSessionSetPtr descendants = aSession->SessionChildren();
		
		SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
		HRESULT hr = it.Init(descendants);
		if (FAILED(hr))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to step through session set");
			SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
			return NULL;
		}

		MTPipelineLib::IMTSessionPtr firstSession;
		while (TRUE)
		{
			MTPipelineLib::IMTSessionPtr session = it.GetNext();
			if (session == NULL)
				break;

			if (session->PropertyExists(PipelinePropIDs::ErrorCodeCode(), MTPipelineLib::SESS_PROP_TYPE_LONG))
				return session;
		}
	}

	SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
					 "Unable to find failed descendant");
	return NULL;
}


void PipelineStageHarnessBase::GetRootUID(MTPipelineLib::IMTSessionPtr aSession, unsigned char * apBytes)
{
	// walk up the tree
	while (aSession->GetParentID() != -1)
	{
		long id = aSession->GetParentID();
		aSession = mSessionServer->GetSession(id);
		ASSERT(aSession != NULL);
	}

	// TODO: don't hardcode length
	aSession->GetUID(apBytes);
}


BOOL PipelineStageHarnessBase::SendReceiptOfSuccess(MTPipelineLib::IMTSessionSetPtr aSet,
                                                    BOOL aExpress)
{
	const char * functionName = "PipelineStageHarnessBase::SendReceiptOfSuccess";

  // big loop over session set
  SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
  HRESULT hr = it.Init(aSet);
  if (FAILED(hr))
  {
    mLogger.LogThis(LOG_ERROR, "Unable to step through session set");
    SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
    return FALSE;
  }

  // Process current transaction using the first session.
  MTPipelineLib::IMTSessionPtr session = it.GetNext();
  if (session != NULL)
    {
      // Do what ever needs to be done as part of the transaction to acknowledge success.
      BOOL aErrorsFlagged = !OnPreCommit(aSet, session->GetTransaction(VARIANT_FALSE), aExpress) ? TRUE : FALSE;
      if (aErrorsFlagged)
      {
        ASSERT(GetLastError() != NULL);
      }

      //
      // commit or rollback the transaction.  always done after
      // the stage is complete, even if this session is going to another stage.
      // NOTE: this only has to be done once per session set since they should
      // all have the same owner and therefore the same transaction
      //
      // Rollback transaction when aErrorsFlagged is TRUE
      //
      if (!ProcessCurrentTransaction(session, aErrorsFlagged))
      {
        if (aErrorsFlagged)
        mLogger.LogThis(LOG_ERROR, "Unable to rollback transaction");
        else
        mLogger.LogThis(LOG_ERROR, "Unable to commit transaction");

        mLogger.LogErrorObject(LOG_ERROR, GetLastError());
        return FALSE;
      }

      // if error then exit.
      if (aErrorsFlagged)
        return FALSE;
    }

  // Do what ever needs to be done after the transaction to acknowledge success.
  // Obviously there is a danger that a commit just happened and this operation may fail!!!!!
  BOOL ret = OnPostCommit(aSet, aExpress);
  // Send stop messages to running stages.
  if (++mSessionSetsProcessed == mMaxSessions)
  {
    // 
    for(StageList::iterator it = mStages.begin(); it != mStages.end(); it++)
    {
      StageReference ref((*it)->GetName().c_str(), TRUE);
      ref.SendStopSignal();
    }
  }
  return ret;
}

BOOL PipelineStageHarnessBase::OnPreCommit(MTPipelineLib::IMTSessionSetPtr aSet, 
                                           MTPipelineLib::IMTTransactionPtr apTran,
                                           BOOL aExpress)
{
	return TRUE;
}

BOOL PipelineStageHarnessBase::OnPostCommit(MTPipelineLib::IMTSessionSetPtr aSet, BOOL aExpress)
{
	return TRUE;
}

BOOL PipelineStageHarnessBase::ProcessCurrentTransaction(MTPipelineLib::IMTSessionPtr aSession, BOOL aErrorsFlagged)
{
	const char * functionName = "PipelineStageHarnessBase::ProcessCurrentTransaction";

	HRESULT hr;

	// Commit or Rollback transaction, if it exists
	MTPipelineLib::IMTTransactionPtr xaction = aSession->GetTransaction(VARIANT_FALSE);

	if (aErrorsFlagged)
	{
		// If session is part of an external transaction, roll back that transaction
		// even if internal transaction has not yet been created
		if (xaction == NULL)
		{
			_bstr_t xactionID = aSession->GetTransactionID(); 
			if (xactionID.length() > 0)
				xaction = aSession->GetTransaction(VARIANT_TRUE);
		}

		if(xaction != NULL)
		{
			mLogger.LogThis(LOG_DEBUG, "Stage failed -- attempting transaction rollback");

			try
			{
				// D'oh!  It failed.  Kill it
				if (xaction != NULL)
				{
					if (FAILED(hr = xaction->Rollback()))
					{
						mLogger.LogThis(LOG_ERROR, "Rollback failed");
						// mLogger.LogVarArgs(LOG_DEBUG, "About to process %d sessions", sessionsAdded);
						aSession->FinalizeTransaction();
						return FALSE;
					}
				}

				mLogger.LogThis(LOG_DEBUG, "Transaction rolled back");
			}
			catch (_com_error & err)
			{
				std::string buffer;
				StringFromComError(buffer, "Unable to rollback transaction", err);
				SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName, buffer.c_str());
				mLogger.LogThis(LOG_ERROR, "Caught exception attempting to rollback transaction");
				aSession->FinalizeTransaction();
				return FALSE;
			}
		}
	}
	else //not aErrorsFlagged
	{
		if (xaction != NULL)
		{
			mLogger.LogThis(LOG_DEBUG, "Attempting transaction commit");

			try
			{
				if (xaction != NULL)
				{
					if (FAILED(hr = xaction->Commit()))
					{
						mLogger.LogThis(LOG_ERROR, "Commit failed");
						if (FAILED(hr = xaction->Rollback())) {
							mLogger.LogThis(LOG_ERROR, "Rollback failed");
						}
						SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
						aSession->FinalizeTransaction();
						return FALSE;
					}
				}

				mLogger.LogThis(LOG_DEBUG, "Transaction committed");
			}
                        // CORE-1133  added some more logging when a plugin fails
			catch (_com_error & e)
			{
        std::wstring errorMessage(e.ErrorMessage());
				mLogger.LogThis(LOG_ERROR, (boost::wformat(L"Caught exception attempting to commit transaction: hr= %1%, msg = %2%") % e.Error() % errorMessage).str().c_str());
				if (FAILED(hr = xaction->Rollback())) {
					mLogger.LogThis(LOG_ERROR, "Commit failed");
				}
				SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
				aSession->FinalizeTransaction();
				return FALSE;
			}
		}
	}

	// clean up after transaction
	aSession->FinalizeTransaction();

	return TRUE;
}

PipelineStageHarness::PipelineStageHarness()
{
}

PipelineStageHarness::~PipelineStageHarness()
{
}

BOOL PipelineStageHarness::InitInternal(const char * apConfigPath,
										std::list<std::string> & arStageNames,
										BOOL aStartAsleep)
{
	const char * functionName = "PipelineStageHarness::InitInternal";
	//
	// initialize the helper to encrypt/compress errors
	//
	HRESULT hr = mMessageUtils.CreateInstance("MetraTech.Pipeline.Messages.MessageUtils");
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
  BOOL bResult = PipelineStageHarnessBase::InitInternal(apConfigPath, arStageNames, aStartAsleep);

  if (bResult)
  {
    //
    // Initialize writer to t_failed_transaction; indicate use of MSMQ
    //
    mFailureWriter = new PipelineFailureWriter(GetNameID(), GetSessionServer(), false);
  }

  return bResult;
}

BOOL PipelineStageHarness::OnPostCommit(MTPipelineLib::IMTSessionSetPtr aSet,
                                        BOOL aExpress)
{
  // Non-transactional send of success in the queue case (performance reasons).
	if (!mReceipt.SendReceiptOfSuccess(aSet, aExpress))
	{
		SetError(mReceipt);
		return FALSE;
	}
	return TRUE;
}

BOOL PipelineStageHarness::SendReceiptOfError(MTPipelineLib::IMTSessionSetPtr aSet,
											  MTPipelineLib::IMTTransactionPtr apTran, 
                                              BOOL aExpress)
{
	const char * functionName = "PipelineStageHarness::SendReceiptOfError";

  IUnknownPtr unknownTxn = apTran->GetTransaction();
  ITransactionPtr txn = unknownTxn;
  if (txn == NULL)
  {
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
    return FALSE;			// QueryInterface must have failed
  }
  QueueTransaction qt(txn);
	if (!mReceipt.SendReceiptOfError(aSet, qt, aExpress))
	{
		SetError(mReceipt);
		return FALSE;
	}
	return TRUE;
}


BOOL PipelineStageHarness::RecordSessionError(std::string & arSessionSetID,
											MTPipelineLib::IMTSessionPtr aSession,
											SessionErrorObject & errObject,
											const char * apMessage,
											HRESULT aError,
											MTPipelineLib::IMTTransactionPtr apTran)
{
	const char * functionName = "PipelineStageHarnessBase::RecordSessionError";

	BOOL success = TRUE;
	try
	{
		errObject.SetErrorMessage(apMessage);
		errObject.SetErrorCode(aError);

		// time of failure
		time_t failureTime = GetMTTime();
		errObject.SetFailureTime(failureTime);

		// set the IP address
		_bstr_t ip = aSession->GetBSTRProperty(PipelinePropIDs::IPAddressCode());
		unsigned char ipBuffer[4];
		if (!DecodeIPAddress(ip, ipBuffer))
		{
			// bad IP
			mLogger.LogVarArgs(LOG_ERROR, "Bad IP address: %s",
												 (const char *) ip);
			memset(ipBuffer, 0, 4);
		}
		errObject.SetIPAddress(ipBuffer);

		// payee ID
		long possiblePayeeID=-1;
    if (VARIANT_TRUE == aSession->PropertyExists(PipelinePropIDs::AccountIDCode(), MTPipelineLib::SESS_PROP_TYPE_LONG))
    {
			possiblePayeeID = aSession->GetLongProperty(PipelinePropIDs::AccountIDCode());
		}
		errObject.SetPayeeID(possiblePayeeID);

    // payer ID
    long possiblePayerID=-1;
    if (VARIANT_TRUE == aSession->PropertyExists(PipelinePropIDs::PayingAccountCode(), MTPipelineLib::SESS_PROP_TYPE_LONG))
    {
			possiblePayerID = aSession->GetLongProperty(PipelinePropIDs::PayingAccountCode());
		}
    errObject.SetPayerID(possiblePayerID);

		// service ID
		errObject.SetServiceID(aSession->GetServiceID());
		// time session was metered
		time_t meteredTime =
			aSession->GetDateTimeProperty(PipelinePropIDs::MeteredTimestampCode());
		errObject.SetMeteredTime(meteredTime);

		// get the UID of the session or compound
		// NOTE: we get the root most parent UID here
		unsigned char uidBytes[16];
		GetRootUID(aSession, uidBytes);
		errObject.SetRootID(uidBytes);

		// encode it to ASCII
		string asciiRootUID;
		MSIXUidGenerator::Encode(asciiRootUID, uidBytes);

		mLogger.LogVarArgs(LOG_ERROR, "Session %s failed to process in "
									  "stage %s, plug-in %s with error %X",
									  asciiRootUID.c_str(),
									  errObject.GetStageName().c_str(),
									  errObject.GetPlugInName().c_str(),
									  (unsigned long) errObject.GetErrorCode());

		aSession->GetUID(uidBytes);
		errObject.SetSessionID(uidBytes);

		//
		// retrieve the XML representation of the session
		//

		BSTR newUIDBstr;
		_bstr_t message = mPipelineControl->GetSessionSetMessage(arSessionSetID.c_str(),
																 asciiRootUID.c_str(),
																 &newUIDBstr);
		// set the UID of the session set (resubmit will work with this UID)
		// UID of generated message
		_bstr_t newUID(newUIDBstr, false);

		// the new session set we attach to the message has a newly generated
		// session set ID.  We use that instead of the old session set ID.
		// aSet->GetUID(uidBytes);
		MSIXUidGenerator::Decode(uidBytes, (const char *) newUID);
		errObject.SetSessionSetID(uidBytes);

		// compound flag
		if (aSession->GetIsParent() == VARIANT_TRUE
				|| aSession->GetParentID() != -1)
			errObject.SetIsCompound(TRUE);
		else
			errObject.SetIsCompound(FALSE);

		// batch ID
	  if (aSession->PropertyExists(PipelinePropIDs::CollectionIDCode(),
																 MTPipelineLib::SESS_PROP_TYPE_STRING))
	  {
		  _bstr_t bstrBatchID = aSession->GetStringProperty(PipelinePropIDs::CollectionIDCode());

		  // decodes the UID back to binary 
		  unsigned char batchUID[16];
		  MSIXUidGenerator::Decode(batchUID, (const char *) bstrBatchID);

			errObject.SetBatchID(batchUID);
	  }
		else
			errObject.SetBatchID(NULL);

		BOOL encrypt = FALSE;
		BOOL compress = FALSE;
		if (mPipelineControl->RequiresEncryption(message) == VARIANT_TRUE)
			// encrypt the message so it doesn't end up on the queue in clear text
			encrypt = TRUE;

		if (encrypt || compress)
		{
			_bstr_t encoded = mMessageUtils->EncodeMessage(message, newUID,
																										 compress, encrypt);

			// errObject copies the data
			errObject.SetMessage((const char *) encoded, encoded.length());
		}
		else
			// no encryption/compression required
			errObject.SetMessage(message, message.length());

		//
		// encode it
		//
		int bufferSize = errObject.GetEncodeBufferSize();
		unsigned char * buffer = new unsigned char[bufferSize];
		errObject.Encode(buffer, bufferSize);

		QueueMessage sendme;

		sendme.ClearProperties();

		sendme.SetPriority(PIPELINE_STANDARD_PRIORITY);
		sendme.SetExpressDelivery(FALSE);

		// TODO: could use app specific long for something
		//sendme.SetAppSpecificLong(PIPELINE_SESSION_FAILED);

		// hold the session set ID in the label so we can easily audit against it
		std::wstring wideRootUID;
		ASCIIToWide(wideRootUID, asciiRootUID.c_str());
		sendme.SetLabel(wideRootUID.c_str());

		sendme.SetBody((UCHAR *) buffer, bufferSize);

		if (apTran)
		{
      IUnknownPtr unknownTxn = apTran->GetTransaction();
      ITransactionPtr txn = unknownTxn;
      if (txn == NULL)
      {
        SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
        return FALSE;			// QueryInterface must have failed
      }
      QueueTransaction qt(txn);
			success = mErrorQueue.Send(sendme, qt);
			if (!success)
				SetError(mErrorQueue.GetLastError());
		}
		else
		{
			success = mErrorQueue.Send(sendme);
			if (!success)
				SetError(mErrorQueue.GetLastError());
		}

		delete [] buffer;

		if (!mFailureWriter->WriteError(aSession, errObject))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to write error information to database");
      SetError(*mFailureWriter);
			success = FALSE;
		}
	}
	catch(COdbcException& ex)
	{	
		mLogger.LogVarArgs(LOG_FATAL, "Error while recording error: %s", ex.what());
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		success = FALSE;
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Error while recording error to ", err);

		mLogger.LogThis(LOG_FATAL, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		success = FALSE;
	}
	return success;
}

/*
 * session errors
 */
BOOL PipelineStageHarness::RecordBatchError(MTPipelineLib::IMTSessionSetPtr aSet,
                                            MTPipelineLib::IMTTransactionPtr apTran,
                                            BOOL aCanAutoResubmit)
{
  const char * functionName = "PipelineStageHarnessBase::RecordBatchError";

  MarkRegion region("RecordBatchError");

  // record all pieces of the batch as errors (even though some may have been
  // successful
  BOOL recordedOK = TRUE;

  try
  {
    std::vector<MTPipelineLib::IMTSessionPtr> errorsMarked;
    std::vector<MTPipelineLib::IMTSessionPtr> errorsNotMarked;
    HRESULT errorCode;
    _bstr_t errorDescription;
    BOOL allErrorsMatch;

    if (aCanAutoResubmit)
      mLogger.LogThis(LOG_DEBUG, "Recording batch failure - sessions can be auto-resubmitted");
    else
      mLogger.LogThis(LOG_DEBUG, "Recording batch failure - sessions cannot be auto-resubmitted");

    if (!DivideFailedSessions(aSet, errorsMarked, errorsNotMarked,
                              errorCode, errorDescription, allErrorsMatch,
                              aCanAutoResubmit))
    {
      ASSERT(GetLastError());
      return FALSE;
    }

    // encode it to ASCII
    string asciiSessionSetID;
    unsigned char uidBytes[16]; 
    aSet->GetUID(uidBytes);
    MSIXUidGenerator::Encode(asciiSessionSetID, uidBytes);

    // Critical section (block) for iterating over the errors, adding them to the odbc batch
    // and executing the batch.
    {
      MarkRegion region("WriteErrors");
      AutoCriticalSection autolock(&mWriteErrorLock);

      // map between batch ID and number of failures for that batch
      map<wstring, int> batchCounts;

      if (recordedOK)
      {
        if (!mFailureWriter->BeginWriteError())
        {
          mLogger.LogThis(LOG_ERROR,"Unable to write error records to the failure table.");
          SetError(*mFailureWriter);
          ASSERT(GetLastError());
          return FALSE;
        }
      }

      if (recordedOK)
      {
        MarkRegion region("RecordSessionErrors");
        for (int i = 0; i < (int) errorsMarked.size(); i++)
        {
          MTPipelineLib::IMTSessionPtr session = errorsMarked[i];
              
          SessionErrorObject errObject;

          MTPipelineLib::IMTSessionPtr failedSession = FindFailedSession(session);
          if (failedSession == NULL)
          {
            ASSERT(GetLastError());
            return FALSE;
          }
          
          CalculateFailureCounts(failedSession, batchCounts);
          PopulateErrorObject(errObject, failedSession);

          if (!RecordSessionError(asciiSessionSetID, failedSession, errObject, apTran))
          {
            ASSERT(GetLastError());
            recordedOK = FALSE;
          }
        }
      }

      MarkEnterRegion("InsertErrors");
      if (recordedOK && !mFailureWriter->FinalizeWriteError(apTran, batchCounts))
      {
        mLogger.LogThis(LOG_ERROR,"Unable to write error records to the failure table!");
        SetError(*mFailureWriter);
        ASSERT(GetLastError());
        recordedOK = FALSE;
      }
      MarkExitRegion("InsertErrors");
    }

    if (recordedOK && errorsNotMarked.size() > 0)
    {
      MarkRegion resubmitRegion("AutoResubmit");

      mLogger.LogVarArgs(LOG_DEBUG, "Automatically resubmitting %d sessions", errorsNotMarked.size());

      std::string successfulSessions;
      std::wstring uid;
      if (!CollectSuccessfulSessions(successfulSessions, uid, asciiSessionSetID,
                                     errorsNotMarked))
      {
        ASSERT(GetLastError());
        mLogger.LogErrorObject(LOG_ERROR, GetLastError());
        return FALSE;
      }

      PropertyCount propCount;
      propCount.total = 0;
      propCount.smallStr = 0;
      propCount.mediumStr = 0;
      propCount.largeStr = 0;

      MarkRegion region("SpoolMessage");
      IUnknownPtr unknownTxn = apTran->GetTransaction();
      ITransactionPtr txn = unknownTxn;
      if (txn == NULL)
      {
        SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
        return FALSE;			// QueryInterface must have failed
      }
      QueueTransaction qt(txn);
      if (!mResubmit.SpoolMessage(successfulSessions.c_str(),
                                  uid.c_str(), propCount, &qt, 0))
      {
        SetError(mResubmit);
        ASSERT(GetLastError());
        mLogger.LogThis(LOG_ERROR, "Unable to resubmit successful sessions");
        mLogger.LogErrorObject(LOG_ERROR, GetLastError());
        return FALSE;
      }
    }
  }
  catch(COdbcException& ex)
  { 
    mLogger.LogVarArgs(LOG_FATAL, "Error while recording error: %s", ex.what());
    SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
    recordedOK = FALSE;
  }
  catch (_com_error & err)
  {
    std::string buffer;
    StringFromComError(buffer, "Error while recording error to ", err);

    mLogger.LogThis(LOG_FATAL, buffer.c_str());

    SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
    recordedOK = FALSE;
  }

	return recordedOK;
}

BOOL PipelineStageHarness::RecordSessionError(std::string & arSessionSetID,
																							MTPipelineLib::IMTSessionPtr aSession,
																							SessionErrorObject & errObject,
																							MTPipelineLib::IMTTransactionPtr apTran)
{
	const char * functionName = "PipelineStageHarnessBase::RecordSessionError";

	BOOL success = TRUE;
	_bstr_t message;
	HRESULT code = E_FAIL;
	try 
	{
		message = aSession->GetStringProperty(PipelinePropIDs::ErrorStringCode());
	} 
	catch (_com_error &) {}
	try 
	{
		code = aSession->GetLongProperty(PipelinePropIDs::ErrorCodeCode());
	} 
	catch (_com_error &) {}

	return RecordSessionError(arSessionSetID, aSession, errObject, message, code,
														apTran);
}


BOOL
PipelineStageHarness::PrepareStageInternal(const char * apRouteFrom, BOOL aRunAutoTests)
{
	const char * functionName = "PipelineStageHarness::PrepareStage";
	//
	// initialize the error queue, creating if necessary
	//
	mLogger.LogThis(LOG_DEBUG, "Initializing error queue");
	ErrorObject * queueErr;
	std::wstring errorQueueName(mPipelineInfo.GetErrorQueueName());
	MakeUnique(errorQueueName);
	if (!SetupQueue(mErrorQueue, errorQueueName.c_str(),
									mPipelineInfo.GetErrorQueueMachine().c_str(),
									L"Error Queue", FALSE, TRUE, mPipelineInfo.UsePrivateQueues(),
									TRUE,					// transactional
									&queueErr))
	{
		SetError(queueErr);
		delete queueErr;
		mLogger.LogThis(LOG_ERROR, "Could not setup error queue");
		return FALSE;
	}

	MessageQueueProps queueProps;
	queueProps.SetTransactional(FALSE);
	BOOL transactional;
	if (!mErrorQueue.GetQueueProperties(queueProps)
			|| !queueProps.GetTransactional(&transactional))
	{
		if (mErrorQueue.GetLastError()->GetCode() == MQ_ERROR_UNSUPPORTED_FORMATNAME_OPERATION)
		{
			// this happens when the queue is remote.  log a warning in this
			// case and just assume the error queue is transactional
			mLogger.LogThis(LOG_WARNING,
										"Transactional setting of error queue could not be verified (queue is probably remote)");
			transactional = TRUE;
		}
		else
		{
			SetError(mErrorQueue);
			mLogger.LogThis(LOG_ERROR,
											"Could not verify transactional setting of error queue");
			return FALSE;
		}
	}

	if (!transactional)
	{
		mLogger.LogThis(LOG_FATAL,
										"The error queue must be transactional.  Delete the error queue and start again");
		SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE,
						 functionName,
						 "The error queue must be transactional.  Delete the error queue and start again");
		return FALSE;
	}

	//
	// initialize the audit queue
	//
	// TODO: create this on first use?
	const std::wstring & auditMachine = mPipelineInfo.GetAuditQueueMachine();
	const std::wstring & auditQueue = mPipelineInfo.GetAuditQueueName();

	const std::wstring & failedAuditMachine = mPipelineInfo.GetFailedAuditQueueMachine();
	const std::wstring & failedAuditQueue = mPipelineInfo.GetFailedAuditQueueName();

	if (!mReceipt.Init(auditMachine.length() > 0 ? auditMachine.c_str() : NULL,
										 auditQueue.c_str(),
										 failedAuditMachine.length() > 0 ? failedAuditMachine.c_str() : NULL,
										 failedAuditQueue.c_str(),
										 mPipelineInfo.UsePrivateQueues()))
	{
		SetError(mReceipt);
		return FALSE;
	}

	//
	// initialize the resubmit queue
	//
	mLogger.LogThis(LOG_DEBUG, "Initializing resubmit queue");
	if (!mResubmit.Init(mPipelineInfo))
	{
		SetError(mResubmit);
		return FALSE;
	}

  return PipelineStageHarnessBase::PrepareStageInternal(apRouteFrom, aRunAutoTests);
}

void PipelineStageHarness::Clear()
{
  PipelineStageHarnessBase::Clear();
  mFailureWriter->Clear();
}

PipelineStageHarnessDatabase::PipelineStageHarnessDatabase()
  :
  mResubmitDatabase(NULL)
{
}

PipelineStageHarnessDatabase::~PipelineStageHarnessDatabase()
{
  delete mResubmitDatabase;
}

BOOL PipelineStageHarnessDatabase::InitInternal(const char * apConfigPath,
																				std::list<std::string> & arStageNames,
																				BOOL aStartAsleep)
{
	const char * functionName = "PipelineStageHarnessDatabase::InitInternal";
  BOOL bResult = PipelineStageHarnessBase::InitInternal(apConfigPath, arStageNames, aStartAsleep);

  if (bResult)
  {
    //
    // Initialize writer to t_failed_transaction indicate use of database queues
    //
    mFailureWriter = new PipelineFailureWriter(GetNameID(), GetSessionServer(), true);
    mResubmitDatabase = new PipelineResubmitDatabase(GetSessionServer());
  }

  return bResult;
}

BOOL PipelineStageHarnessDatabase::OnPreCommit(MTPipelineLib::IMTSessionSetPtr aSet,
                                               MTPipelineLib::IMTTransactionPtr apTran, 
                                               BOOL aExpress)
{
  const char * functionName = "PipelineStageHarnessDatabase::OnPreCommit";
  try
  {
    // HACK: The UID of the session set is where we saved the id_message.
    unsigned char uid [16];
    aSet->GetUID(&uid[0]);
    long messageID = ((long *)uid)[0];
    if(!mResubmitDatabase->MarkAsSucceeded(apTran, aSet, messageID))
    {
      mLogger.LogThis(LOG_ERROR,"Failed to mark transactions as succeeded!");
      SetError(*mResubmitDatabase);
      ASSERT(GetLastError());
      return FALSE;
    }
  }
  catch(_com_error & err)
  {
		std::string buffer;
		StringFromComError(buffer, "Error while recording success receipt ", err);

		mLogger.LogThis(LOG_FATAL, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
  }
	return TRUE;
}

BOOL PipelineStageHarnessDatabase::SendReceiptOfError(MTPipelineLib::IMTSessionSetPtr aSet,
                                                      MTPipelineLib::IMTTransactionPtr apTran, 
                                                      BOOL aExpress)
{
  const char * functionName = "PipelineStageHarnessDatabase::SendReceiptOfError";
  try
  {
    // HACK: The UID of the session set is where we saved the id_message.
    unsigned char uid [16];
    aSet->GetUID(&uid[0]);
    long messageID = ((long *)uid)[0];
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(L"Queries\\Pipeline");
    rowset->SetQueryTag("__UPDATE_MESSAGE_FAILURE__");
    rowset->AddParam("%%ID_MESSAGE%%", messageID);
    rowset->JoinDistributedTransaction((ROWSETLib::IMTTransaction *) apTran.GetInterfacePtr());
    rowset->Execute();
    rowset->JoinDistributedTransaction(NULL);
    rowset = NULL;
  }
  catch(_com_error & err)
  {
		std::string buffer;
		StringFromComError(buffer, "Error while recording failure receipt ", err);

		mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
  }
	return TRUE;
}


BOOL PipelineStageHarnessDatabase::RecordSessionError(std::string & arSessionSetID,
																							MTPipelineLib::IMTSessionPtr aSession,
																							SessionErrorObject & errObject,
																							const char * apMessage,
																							HRESULT aError,
																							MTPipelineLib::IMTTransactionPtr apTran)
{
	const char * functionName = "PipelineStageHarnessDatabase::RecordSessionError";

	BOOL success = TRUE;
	try
	{

		string errorStr = apMessage;
		 
		if (!(apMessage == NULL))
		{ 
			errorStr = errorStr.substr(0, MAX_FAILURE_ERROR_MESSAGE_SIZE-1);
		}

		errObject.SetErrorMessage(((const char *)errorStr.c_str()));
		errObject.SetErrorCode(aError);

		// time of failure
		time_t failureTime = GetMTTime();
		errObject.SetFailureTime(failureTime);

		// set the IP address
		_bstr_t ip = aSession->GetBSTRProperty(PipelinePropIDs::IPAddressCode());
		unsigned char ipBuffer[4];
		if (!DecodeIPAddress(ip, ipBuffer))
		{
			// bad IP
			mLogger.LogVarArgs(LOG_ERROR, "Bad IP address: %s",
												 (const char *) ip);
			memset(ipBuffer, 0, 4);
		}
		errObject.SetIPAddress(ipBuffer);

		// payee ID
		long possiblePayeeID;
		try
		{
			possiblePayeeID = aSession->GetLongProperty(PipelinePropIDs::AccountIDCode());
		}
		catch (_com_error &)
		{
			possiblePayeeID = -1;
		}
		errObject.SetPayeeID(possiblePayeeID);

 		// payer ID
		long possiblePayerID;
		try
		{
			possiblePayerID = aSession->GetLongProperty(PipelinePropIDs::PayingAccountCode());
		}
		catch (_com_error &)
		{
			possiblePayerID = -1;
		}
		errObject.SetPayerID(possiblePayerID);

		// service ID
		errObject.SetServiceID(aSession->GetServiceID());
		// time session was metered
		time_t meteredTime =
			aSession->GetDateTimeProperty(PipelinePropIDs::MeteredTimestampCode());
		errObject.SetMeteredTime(meteredTime);

		// get the UID of the session or compound
		// NOTE: we get the root most parent UID here
		unsigned char uidBytes[16];
		GetRootUID(aSession, uidBytes);
		errObject.SetRootID(uidBytes);

		// encode it to ASCII
		string asciiRootUID;
		MSIXUidGenerator::Encode(asciiRootUID, uidBytes);

		mLogger.LogVarArgs(LOG_ERROR,
											 "Session %s failed to process in "
											 "stage %s, plug-in %s with error %X",
											 asciiRootUID.c_str(),
											 errObject.GetStageName().c_str(),
											 errObject.GetPlugInName().c_str(),
											 (unsigned long) errObject.GetErrorCode());

		aSession->GetUID(uidBytes);
		errObject.SetSessionID(uidBytes);

		//
		// retrieve the XML representation of the session
		//

// 		BSTR newUIDBstr;
// 		_bstr_t message = mPipelineControl->GetSessionSetMessage(arSessionSetID.c_str(),
// 																														 asciiRootUID.c_str(),
// 																														 &newUIDBstr);
// 		// set the UID of the session set (resubmit will work with this UID)
// 		// UID of generated message
// 		_bstr_t newUID(newUIDBstr, false);

// 		// the new session set we attach to the message has a newly generated
// 		// session set ID.  We use that instead of the old session set ID.
// 		// aSet->GetUID(uidBytes);
// 		MSIXUidGenerator::Decode(uidBytes, (const char *) newUID);
// 		errObject.SetSessionSetID(uidBytes);

		// compound flag
		if (aSession->GetIsParent() == VARIANT_TRUE
				|| aSession->GetParentID() != -1)
			errObject.SetIsCompound(TRUE);
		else
			errObject.SetIsCompound(FALSE);

		// batch ID
	  if (aSession->PropertyExists(PipelinePropIDs::CollectionIDCode(),
																 MTPipelineLib::SESS_PROP_TYPE_STRING))
	  {
		  _bstr_t bstrBatchID = aSession->GetStringProperty(PipelinePropIDs::CollectionIDCode());

		  // decodes the UID back to binary 
		  unsigned char batchUID[16];
		  MSIXUidGenerator::Decode(batchUID, (const char *) bstrBatchID);

			errObject.SetBatchID(batchUID);
	  }
		else
			errObject.SetBatchID(NULL);

		if (!mFailureWriter->WriteError(aSession, errObject))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to write error information to database");
      SetError(*mFailureWriter);
			success = FALSE;
		}
	}
	catch(COdbcException& ex)
	{	
		mLogger.LogVarArgs(LOG_ERROR, "Error while recording error: %s", ex.what());
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		success = FALSE;
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Error while recording error to ", err);

		mLogger.LogThis(LOG_ERROR, buffer.c_str());

		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		success = FALSE;
	}
	return success;
}

/*
 * session errors
 */
BOOL PipelineStageHarnessDatabase::RecordBatchError(
                                           MTPipelineLib::IMTSessionSetPtr   aSet,
                                           MTPipelineLib::IMTTransactionPtr apTran,
                                           BOOL               aCanAutoResubmit)
{
  const char * functionName = "PipelineStageHarnessDatabase::RecordBatchError";

  MarkRegion region("RecordBatchError");

  // record all pieces of the batch as errors (even though some may have been
  // successful
  BOOL recordedOK = TRUE;

  try
  {
    std::vector<MTPipelineLib::IMTSessionPtr> errorsMarked;
    std::vector<MTPipelineLib::IMTSessionPtr> errorsNotMarked;
    HRESULT errorCode;
    _bstr_t errorDescription;
    BOOL allErrorsMatch;

    if (aCanAutoResubmit)
      mLogger.LogThis(LOG_DEBUG, "Recording batch failure - sessions can be auto-resubmitted");
    else
      mLogger.LogThis(LOG_DEBUG, "Recording batch failure - sessions cannot be auto-resubmitted");

    if (!DivideFailedSessions(aSet, errorsMarked, errorsNotMarked,
                              errorCode, errorDescription, allErrorsMatch,
                              aCanAutoResubmit))
    {
      ASSERT(GetLastError());
      return FALSE;
    }

    // encode it to ASCII
    string asciiSessionSetID;
    unsigned char uidBytes[16]; 
    aSet->GetUID(uidBytes);

    // HACK: The UID encodes the message ID from the database!
    long messageID = ((long *) uidBytes)[0];

    MSIXUidGenerator::Encode(asciiSessionSetID, uidBytes);

    // Critical section (block) for iterating over the errors, adding them to the odbc batch
    // and executing the batch.
    {
      MarkRegion region("WriteErrors");
      AutoCriticalSection autolock(&mWriteErrorLock);

      // map between batch ID and number of failures for that batch
      map<wstring, int> batchCounts;

      if (recordedOK)
      {
        if (!mFailureWriter->BeginWriteError())
        {
          mLogger.LogThis(LOG_ERROR,"Unable to write error records to the failure table.");
          SetError(*mFailureWriter);
          ASSERT(GetLastError());
          return FALSE;
        }
      }

      if (recordedOK)
      {
        MarkRegion region("RecordSessionErrors");
        for (int i = 0; i < (int) errorsMarked.size(); i++)
        {
          MTPipelineLib::IMTSessionPtr session = errorsMarked[i];
              
          SessionErrorObject errObject;

          MTPipelineLib::IMTSessionPtr failedSession = FindFailedSession(session);
          if (failedSession == NULL)
          {
            ASSERT(GetLastError());
            return FALSE;
          }

          CalculateFailureCounts(failedSession, batchCounts);
          PopulateErrorObject(errObject, failedSession);

          if (!RecordSessionError(asciiSessionSetID, failedSession, errObject, apTran))
          {
            ASSERT(GetLastError());
            mLogger.LogErrorObject(LOG_DEBUG, GetLastError());
            recordedOK = FALSE;
          }
        }
      }

      MarkEnterRegion("InsertErrors");
      if (recordedOK && !mFailureWriter->FinalizeWriteError(apTran, batchCounts))
      {
        mLogger.LogThis(LOG_ERROR,"Unable to write error records to the failure table!");
        SetError(*mFailureWriter);
        ASSERT(GetLastError());
        recordedOK = FALSE;
      }
      MarkExitRegion("InsertErrors");
    }

    if (recordedOK && errorsNotMarked.size() > 0)
    {
      MarkRegion resubmitRegion("AutoResubmit");

      mLogger.LogVarArgs(LOG_DEBUG, "Automatically resubmitting %d sessions", errorsNotMarked.size());

      if(FALSE==mResubmitDatabase->AutoResubmit(apTran, errorsNotMarked, messageID))
      {
        mLogger.LogThis(LOG_ERROR,"Failed to auto resubmit transactions!");
        SetError(*mResubmitDatabase);
        ASSERT(GetLastError());
        recordedOK = FALSE;
      }
    }
  }
  catch(COdbcException& ex)
  { 
    mLogger.LogVarArgs(LOG_ERROR, "Error while recording error: %s", ex.what());
    SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
    recordedOK = FALSE;
  }
  catch (_com_error & err)
  {
    std::string buffer;
    StringFromComError(buffer, "Error while recording error to ", err);

    mLogger.LogThis(LOG_ERROR, buffer.c_str());

    SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
    recordedOK = FALSE;
  }

  ASSERT(recordedOK == TRUE || GetLastError() != NULL);

  return recordedOK;
}

BOOL PipelineStageHarnessDatabase::RecordSessionError(std::string & arSessionSetID,
																							MTPipelineLib::IMTSessionPtr aSession,
																							SessionErrorObject & errObject,
																							MTPipelineLib::IMTTransactionPtr apTran)
{
	const char * functionName = "PipelineStageHarnessDatabase::RecordSessionError";

	BOOL success = TRUE;
	_bstr_t message;
	HRESULT code = E_FAIL;
	try 
	{
		message = aSession->GetStringProperty(PipelinePropIDs::ErrorStringCode());
	} 
	catch (_com_error &) {}
	try 
	{
		code = aSession->GetLongProperty(PipelinePropIDs::ErrorCodeCode());
	} 
	catch (_com_error &) {}

	return RecordSessionError(arSessionSetID, aSession, errObject, message, code,
														apTran);
}


BOOL
PipelineStageHarnessDatabase::PrepareStageInternal(const char * apRouteFrom, BOOL aRunAutoTests)
{
	const char * functionName = "PipelineStageHarnessDatabase::PrepareStage";

  return PipelineStageHarnessBase::PrepareStageInternal(apRouteFrom, aRunAutoTests);
}

void PipelineStageHarnessDatabase::Clear()
{
  PipelineStageHarnessBase::Clear();

  //Need to guarantee destruction of ODBC prepared statements before connection is destroyed
  mFailureWriter->Clear();
  mResubmitDatabase->Clear();
}

void PipelineStageHarnessDatabase::PopulateErrorObject(
	SessionErrorObject &         arErrObj,
	MTPipelineLib::IMTSessionPtr aSession)
{
  PipelineStageHarnessBase::PopulateErrorObject(arErrObj, aSession);

	// 4.0
  arErrObj.SetScheduleSessionSetID(aSession->GetLongProperty(PipelinePropIDs::SessionSetIDCode()));
}

PipelineStageHarnessBase* PipelineStageHarnessFactory::Create(const char * apConfigPath,
                                                              std::list<std::string> & arStageNames,
                                                              BOOL aStartAsleep)
{
  const char * functionName = "PipelineStageHarnessFactory::Create";
	//
	// initialize the config reader
	//
	//mLogger.LogThis(LOG_DEBUG, "Initializing configuration reader");
  MTPipelineLib::IMTConfigPtr pConfig;
	HRESULT hr = pConfig.CreateInstance(MTPROGID_CONFIG);
	if (FAILED(hr))
	{
		// TODO: pass win32 or hresult?
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
			"Could not create an instance of " MTPROGID_CONFIG);
		return NULL;
	}

	//
	// read the main pipeline configuration file
	//
	//mLogger.LogThis(LOG_DEBUG, "Reading pipeline configuration file");
	PipelineInfoReader pipelineReader;
  PipelineInfo pipelineInfo;

	MTConfigLib::IMTConfigPtr config((MTConfigLib::IMTConfig *)(MTPipelineLib::IMTConfig *) pConfig);
	if (!pipelineReader.ReadConfiguration(config, apConfigPath, pipelineInfo))
	{
		SetError(pipelineReader.GetLastError());
		return NULL;
	}

  //
  // Examine the pipeline configuration to decide what type of stage harness
  // to use.
  //
  PipelineStageHarnessBase* harness = NULL;
  if (PipelineInfo::PERSISTENT_DATABASE_QUEUE == pipelineInfo.GetHarnessType())
  {
    harness = new PipelineStageHarnessDatabase();
  }
  else
  {
    harness = new PipelineStageHarness();
  }

  BOOL success = harness->Init(apConfigPath, arStageNames, aStartAsleep);
  if(!success)
  {
    SetError(*harness);
    return NULL;
  }
  else
  {
    return harness;
  }
}
