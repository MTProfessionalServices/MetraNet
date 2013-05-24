/**************************************************************************
 * @doc EXECUTE
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

#include <exgraph.h>

#include <mtprogids.h>
#include <mtglobal_msg.h>

#include <propids.h>
#include <SetIterate.h>

#include <perf.h>
#include <perflog.h>

#include <mtcomerr.h>

#include <stdutils.h>

// uncomment this line to get the pipeline to print the execution time of each plug-in to stdout
//#define PRINT_PLUG_IN_TIMINGS


using namespace std;

//#define TIME_STARTUP
#ifdef TIME_STARTUP
static long gStartTime;
static long gLastMeasurement;

static void InitStartTimes()
{
	gStartTime = gLastMeasurement = ::GetTickCount();
}

static void PrintTimingInfo(const char * apComment)
{
	long now = ::GetTickCount();
	cout << apComment << " -- Time since last measurement: " << (now - gLastMeasurement)
			 << endl;
	gLastMeasurement = now;
}
#endif

/******************************************** ExecutionGraph ***/


ExecutionGraph::ExecutionGraph()
	: mRelationshipPrototype(NULL),
		mRelationshipPrototypeSize(0),
		mInitialized(FALSE),
		mRunAutoTests(TRUE),
		mVerbose(FALSE)
{
}

ExecutionGraph::~ExecutionGraph()
{
	Clear();
}

void ExecutionGraph::Clear()
{
	if (mRelationshipPrototype)
	{
		delete [] mRelationshipPrototype;
		mRelationshipPrototype = NULL;
	}

	mMap.clear();
	mAllProcessors.clear();				// don't clear and destroy - they live in mMap
	mFinal.clear();
}


BOOL ExecutionGraph::ReadDependencies(MTPipelineLib::IMTConfigPropSetPtr & arDependencies)
{
	// start index off at 0 - there are no processors yet
	mIndex = 0;

	MTPipelineLib::IMTConfigPropPtr prop;
	while ((prop = arDependencies->Next()) != NULL)
	{
		MTPipelineLib::PropValType type;
		_variant_t var = prop->GetValue(&type);
		if (type == MTPipelineLib::PROP_TYPE_STRING && 0 == strcmp(prop->GetName(), "dependson"))
		{
			_bstr_t dep = var;
			StagePlugIn & proc = GetProcessor(dep);

			AddFinalDependency(proc);
		}
		else if (type == MTPipelineLib::PROP_TYPE_SET && 0 == strcmp(prop->GetName(), "dependency"))
		{
			// dependency between processors
			MTPipelineLib::IMTConfigPropSetPtr dependency(var);

			_bstr_t procName = dependency->NextStringWithName("processor");

			StagePlugIn & proc = GetProcessor(procName);

			MTPipelineLib::IMTConfigPropPtr dependsOn;
			while ((dependsOn = dependency->Next()) != NULL)
			{
				MTPipelineLib::PropValType deptype;
				_variant_t depvar = dependsOn->GetValue(&deptype);
				_bstr_t bstr = dependsOn->GetName();

				if (deptype != MTPipelineLib::PROP_TYPE_STRING || 0 != strcmp(bstr, "dependson"))
				{
					SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
									 "StageInfo::ReadDependencies");
					mpLastError->GetProgrammerDetail() =
						"Set " "dependson" " not found or not a string";
					return FALSE;
				}

				_bstr_t depname = depvar;
				StagePlugIn & dependsOnProc = GetProcessor(depname);
				proc.AddDependency(dependsOnProc);
			}
		}
	}
	return TRUE;
}



StagePlugIn & ExecutionGraph::GetProcessor(const char * apName)
{
	string mystring;
	std::string lowerName(apName);
	mystring = _strlwr((char *)lowerName.c_str());

	StagePlugIn & proc = mMap[mystring];
	// if this is the first access, the name will be an empty string
	if (proc.GetName().length() == 0)
	{
		// first access to this plug-in
		proc.SetName(apName);
		proc.SetIndex(mIndex++);
		mAllProcessors.push_back(&proc);
	}

	return proc;
}

void ExecutionGraph::AddFinalDependency(StagePlugIn & arProc)
{
	mFinal.push_back(&arProc);
}


BOOL ExecutionGraph::Init(MTPipelineLib::IMTConfigLoaderPtr aConfigLoader,
													MTPipelineLib::IMTConfigPtr aConfig,
													MTPipelineLib::IMTSessionServerPtr aSessionServer,
													MTPipelineLib::IMTSystemContextPtr aSysContext,
													std::string aConfigPath, std::string aStageName, int aStageInstance)
{
	this->aConfigLoader = aConfigLoader;
	this->aConfig = aConfig;
	this->aSessionServer = aSessionServer;
	this->aSysContext = aSysContext;
	this->aConfigPath = aConfigPath;

	mStageName = aStageName;
  mStageInstance = aStageInstance;

#if 1
	mInitialized = TRUE;
	return RealInit();

#else
	return TRUE;
#endif
}

BOOL ExecutionGraph::RealInit()
{
	const char * functionName = "ExecutionGraph::Init";

	// TODO: better init here
  char buf[10];
  sprintf(buf, "%d", mStageInstance);

	std::string tag("[");
	tag += mStageName;
  tag += "_";
  tag += buf;
	tag += ']';
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), tag.c_str());

	/*
	 * initialize system context object
	 */

	// TODO: the log object should be initialized specifically for each plugin
	MTPipelineLib::IMTLogPtr logger(aSysContext);
	logger->Init("logging", "[PlugIn]");

#ifdef TIME_STARTUP
	InitStartTimes();
#endif


	/*
	 * calculate spacing for verbose output
	 */
	int maxNameLen = 0;
	if (mVerbose)
	{
		PlugInList & procList = GetPlugIns();

		PlugInList::iterator it;
		for (it = procList.begin(); it != procList.end(); ++it)
		{
			StagePlugIn * plugin = *it;

			if ((int) plugin->GetName().length() > maxNameLen)
				maxNameLen = plugin->GetName().length();
		}
	}

	// Number of columns
	int columns;
	// Number of characters per column
	int charsPerColumn;

	if (mVerbose)
	{
		charsPerColumn = maxNameLen + 2;
		columns = (80 - 4) / charsPerColumn;
	
		// leading spaces
		cout << "    ";
	}
	// Current column
	int column = 0;

	/*
	 * read the processor configurations
	 */

	MTPipelineLib::IMTNameIDPtr nameId(aSysContext);

	PlugInList & procList = GetPlugIns();

	PlugInList::iterator it;
	for (it = procList.begin(); it != procList.end(); ++it)
	{
		StagePlugIn * plugin = *it;

		mLogger.LogVarArgs(LOG_DEBUG, "Preparing plug-in %s",
											 plugin->GetName().c_str());

		if (mVerbose)
		{
			cout << plugin->GetName().c_str();
			cout.flush();

			column++;
			if (column < columns)
			{
				for (int i = 0; i < charsPerColumn - (int) plugin->GetName().length(); i++)
					cout << ' ';
			}
			else
			{
				cout << endl << "    ";
				column = 0;
			}
		}

		if (!plugin->Configure(aConfig, aConfigLoader, "", mStageName.c_str(), aSessionServer))
		{
			SetError(plugin->GetLastError());
			return FALSE;
		}

#ifdef TIME_STARTUP
		PrintTimingInfo(plugin->GetName());
#endif

		mLogger.LogVarArgs(LOG_DEBUG, "Loading plug-in %s",
											 plugin->GetName().c_str());

		if (!plugin->LoadProcessor())
		{
			SetError(plugin->GetLastError());
			return FALSE;
		}

#ifdef TIME_STARTUP
		PrintTimingInfo(plugin->GetName());
#endif

		mLogger.LogVarArgs(LOG_DEBUG, "Initializing plug-in %s",
											 plugin->GetName().c_str());


    SetUpLoggerTagName( plugin );

		if (!plugin->Initialize(aSysContext))
		{
			SetError(plugin->GetLastError());
			return FALSE;
		}

#ifdef TIME_STARTUP
		PrintTimingInfo(plugin->GetName());
#endif

		if (mRunAutoTests)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Reading %s's autotest files",
												 plugin->GetName().c_str());

			if (!plugin->ReadAutoTest(aConfig, aConfigPath.c_str(), mStageName.c_str()))
			{
				SetError(plugin->GetLastError());
				return FALSE;
			}

			mLogger.LogThis(LOG_DEBUG, "About to run autotest");

			if (!plugin->RunAutoTest(nameId, aSessionServer))
			{
				SetError(plugin->GetLastError());
				return FALSE;
			}

#ifdef TIME_STARTUP
			PrintTimingInfo(plugin->GetName());
#endif
		}
	}

	// output another newline if we didn't just do that
	if (mVerbose && column != 0)
		cout << endl;

	/*
	 * create relationship map
	 */
	// calculate max depth by traversing the tree
	PlugInList & list = GetPlugIns();
	if (list.size() == 0)
	{
		SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Stage has no plugins");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}

	mLogger.LogThis(LOG_DEBUG, "Creating relationship map");
	CreateRelationshipMap();



	/*
	 * initialize the hooks
	 */

	if (!InitializeHooks(aConfig))
		return FALSE;

	return TRUE;
}

BOOL ExecutionGraph::ShutdownPlugIns()
{
	if (!mInitialized)
		return TRUE;

	PlugInList & procList = GetPlugIns();

	BOOL ok = TRUE;
	PlugInList::iterator it;
	for (it = procList.begin(); it != procList.end(); ++it)
	{
		StagePlugIn * plugin = *it;
		if (!plugin->Shutdown())
			ok = FALSE;
	}
	return ok;
}

BOOL ExecutionGraph::ClearPlugIns()
{
	if (!mInitialized)
		return TRUE;

	PlugInList & procList = GetPlugIns();


	BOOL ok = TRUE;

	PlugInList::iterator it;
	for (it = procList.begin(); it != procList.end(); ++it)
	{
		StagePlugIn * plugin = *it;
		plugin->Clear();
	}
	return ok;
}


#ifdef PRINT_PLUG_IN_TIMINGS
NTThreadLock gLock;
#endif

BOOL ExecutionGraph::ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet,
																		 std::string & arFailurePlugIn)
{
	const char * functionName = "ExecutionGraph::ProcessSessions";

	MarkRegion region("ExGraph::ReceiveMessage");

	if (!mInitialized)
	{
		mInitialized = TRUE;
		if (!RealInit())
			return FALSE;
	}

	// initialize hook arguments if required
	BOOL executeHooks = mBeforeHooks.HooksRequired() || mAfterHooks.HooksRequired();
	if (executeHooks)
	{
		if (!InitializeExecutionInfo(aSet))
			return FALSE;
	}

	// create an array of dependency counts.
  vector<PlugInState *> processingInfo;
  PlugInState * stateInfo = NULL;
  {   // explicit scope for perf log
    MarkRegion region("ExGraph::Setup");

	  stateInfo = new PlugInState[mRelationshipPrototypeSize];

	  for (int i = 0; i < mRelationshipPrototypeSize; i++)
	  {
		  stateInfo[i].Initialize(&mRelationshipPrototype[i], stateInfo);

		  // TODO: use tag
		  stateInfo[i].SetTag(0);
	  }

	  for (i = 0; i < mRelationshipPrototypeSize; i++)
		  processingInfo.push_back(&stateInfo[i]);
  }

#ifdef PRINT_PLUG_IN_TIMINGS
	long frequency;
	GetPerformanceTickCountFrequency(frequency);
#endif

	BOOL success = TRUE;
	while (TRUE)
	{
		//PrintStateInfo(processingInfo);

		// if there's nothing left to execute, we're done
		if (processingInfo.size() == 0)
			break;

		// find the plug-in that has the lowest score
		PlugInState * state = 0;
		vector<PlugInState *>::iterator removeIt;
		vector<PlugInState *>::iterator it;
		for (it = processingInfo.begin(); it != processingInfo.end(); ++it)
		{
			PlugInState * test = *it;
			if (!state || *test < *state)
			{
				state = test;
				removeIt = it;
			}
		}

		if (state->GetCurrentDependencyCount() > 0)
		{
			char msg[1024];
			sprintf(msg, "Circular dependency detected in stage '%s' involving plug-in '%s'! Fix the stage.xml file in order to continue",
							mStageName.c_str(), state->GetPlugIn()->GetName().c_str());
			SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName, msg);
			success = FALSE;
			break;
		}

		mLogger.LogVarArgs(LOG_DEBUG, "Executing plug-in %s",
											 state->GetPlugIn()->GetName().c_str());

		// remove it from the queue
		processingInfo.erase(removeIt);

		// execute the plug-in
		StagePlugIn * plugIn = state->GetPlugIn();

    SetUpLoggerTagName( plugIn );

		try
		{
			BOOL processSuccess;

			// process the session normally with no timing data

			// call the before plug-in hooks
			if (mBeforeHooks.HooksRequired())
				CallBeforeHooks(plugIn);

			char stageplugin[512];
			sprintf(stageplugin, "%s_%s", mStageName.c_str(), plugIn->GetName().c_str());
			{         // explicit scope for perf log
				MarkRegion region("PlugIn", stageplugin);

                MTPipelineLib::IMTSessionSetPtr aSet2 = NULL;

                MTPipelineLib::IMTSessionServerPtr mSessionServer;
                mSessionServer = MTPipelineLib::IMTSessionServerPtr(MTPROGID_SESSION_SERVER);
                if (mSessionServer == NULL)
                {
                  mLogger.LogVarArgs(LOG_ERROR, "execute.cpp: ProcessSessions(): (mSessionServer == NULL) is TRUE");
                  success = FALSE;
                  break;
                }

                aSet2 = mSessionServer->CreateSessionSet();

                SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it2;

                HRESULT hr2 = it2.Init(aSet);
                if (FAILED(hr2))
                {
                  mLogger.LogVarArgs(LOG_ERROR, "execute.cpp: ProcessSessions(): if (FAILED(hr2)) is TRUE");
                  success = FALSE;
                  break;
                }

                VARIANT_BOOL isMyCompoundSessionFailed = VARIANT_TRUE;
                char bufferGeneric[1024] = "";
                while (TRUE)
                {
                  MTPipelineLib::IMTSessionPtr session2 = it2.GetNext();
                  if (session2 == NULL)
                  {
                    break;
                  }

                  session2->get_CompoundMarkedAsFailed(((VARIANT_BOOL*)&isMyCompoundSessionFailed));
                  if(isMyCompoundSessionFailed == VARIANT_FALSE)
                  {
                    aSet2->AddSession(session2->GetSessionID(), session2->GetServiceID());
                  } else
                  {
                    if (mLogger.IsOkToLog(LOG_DEBUG) == TRUE) {
                      _bstr_t session2GetUIDAsString = session2->GetUIDAsString();
                      sprintf(bufferGeneric,
                                     "execute.cpp: Detected session in my compound session failed, skipping my session from processing. pipelineServiceNameEnumID_stage_plugin: %d_%s_%s, sessionUID: %s.",
                                                                                              session2->GetServiceID(), mStageName.c_str(), state->GetPlugIn()->GetName().c_str(), (const char*)session2GetUIDAsString); 
                      mLogger.LogVarArgs(LOG_DEBUG, bufferGeneric);
                    }
                  }

                }

				processSuccess = plugIn->ProcessSessions(aSet2);
			}
  
			// call the after plug-in hooks
			if (mAfterHooks.HooksRequired())
				CallAfterHooks(plugIn);

			if (!processSuccess)
			{
				arFailurePlugIn = plugIn->GetName().c_str();
				SetError(plugIn->GetLastError());
				success = FALSE;
				break;
			}
		}
		catch (_com_error err)
		{
			arFailurePlugIn = plugIn->GetName().c_str();

			_bstr_t bstrDesc = err.Description();
			std::string desc;
			if (!bstrDesc)					// only operator ! defined
				;
			else
				desc = bstrDesc;

			SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName, desc.c_str());

			string message("Plugin ");
			message += plugIn->GetName();
			message += " failed to process sessions";

			std::string buffer;
			StringFromComError(buffer, message.c_str(), err);

			mLogger.LogThis(LOG_ERROR, buffer.c_str());

			success = FALSE;
			break;
		}
		catch (std::exception& stlErr)
		{
			arFailurePlugIn = plugIn->GetName().c_str();

			string message("Plugin ");
			message += plugIn->GetName();
			message += " threw an uncaught exception: ";
			message += stlErr.what();

			SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 message.c_str());

			mLogger.LogErrorObject(LOG_ERROR, GetLastError());

			success = FALSE;
#ifdef DEBUG
			// rethrow the error to annoy the developer into fixing the problem.
			throw;
#else
			break;
#endif
		}
		catch (...)
		{
			arFailurePlugIn = plugIn->GetName().c_str();

			string message("Plugin ");
			message += plugIn->GetName();
			message += " threw an illegal exception";

			SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 message.c_str());

			mLogger.LogErrorObject(LOG_ERROR, GetLastError());

			success = FALSE;
#ifdef DEBUG
			// rethrow the error to annoy the developer into fixing the problem.
			throw;
#else
			break;
#endif
		}

		// update dependency counts
		PlugInState * * dependsOnMe = state->GetDependsOnMe();
		int dependsOnMeSize = state->GetDependsOnMeSize();
		for (int i = 0; i < dependsOnMeSize; i++)
		{
			PlugInState * dep = dependsOnMe[i];

			// to adjust where the PlugInState falls in the queue,
			// we have to remove it, modify its state, and then
			// add it back to the queue.

			(void) dep->DecrementDependencyCount();
		}
	}

	if (executeHooks)
		mExecutionInfo = NULL;

	delete [] stateInfo;
	return success;
}

/// This method sets the application tag in the logger object shared between plugins
/// This is useful so that log messages appear with the correct stage/plugin name
void ExecutionGraph::SetUpLoggerTagName( StagePlugIn *plugIn )
{
  char buf[5];
  
  sprintf(buf, "%d", mStageInstance);

    //Set the stage/plugin name in the shared logger... this works because we know plugins are not run in parallel
    string sApplicationTag("[");
    sApplicationTag += mStageName;
    sApplicationTag += "_";
    sApplicationTag += buf;
    sApplicationTag += "_";
    sApplicationTag += plugIn->GetName();
    sApplicationTag += "]";

    MTPipelineLib::IMTLogPtr logger(aSysContext);
    logger->ApplicationTag=sApplicationTag.c_str();
}

void ExecutionGraph::CreateRelationshipMap()
{
	// create the empty relationship map that
	// is used as a prototype for further processing runs

	// calculate max depth by traversing the tree
	PlugInList & list = GetPlugIns();
	ASSERT(list.size() != 0);

	// all depths are initially 0
	PlugInList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		StagePlugIn * plugin = *it;
		plugin->SetDepth(0);
	}

	// recursively figure out the maximum depths
	MeasureDepths(0, NULL, mFinal);

	mRelationshipPrototype = new InitialPlugInState[list.size()];
	mRelationshipPrototypeSize = list.size();

	// initialize the array of initial processing states.
	int i;
	for (i = 0, it = list.begin(); it != list.end(); ++it, ++i)
	{
		StagePlugIn * plugin = *it;
		InitialPlugInState * state = &mRelationshipPrototype[i];

		state->Initialize(plugin);
		ASSERT(state->GetProcessorIndex() == i);
	}
}

void ExecutionGraph::MeasureDepths(int aDepth, StagePlugIn * apProc,
																	 PlugInList & arList)
{
	if (apProc)
	{
		// if there's already a path down the tree that caused this node to have
		// a greater depth, no need to go further.
		if (apProc->GetDepth() > aDepth)
			return;
		else
			apProc->SetDepth(aDepth);
	}

	PlugInList::iterator it;
	for (it = arList.begin(); it != arList.end(); ++it)
	{
		StagePlugIn * newproc = *it;
		MeasureDepths(aDepth + 1, newproc, newproc->GetDependencies());
	}
}


void ExecutionGraph::PrintDependencies()
{
	cout << "Dependencies: " << endl;
	const PlugInList & final = GetFinalDependencies();
	PrintSubDependencies(2, final);
}

void ExecutionGraph::PrintSpaces(int aIndent)
{
	for (int i = 0; i < aIndent; i++)
		cout << ' ';
}

void ExecutionGraph::PrintSubDependencies(int aIndent, const PlugInList & aProcList)
{
	PlugInList::const_iterator it;
	for (it = aProcList.begin(); it != aProcList.end(); ++it)
	{
		StagePlugIn * proc = *it;
		PrintSpaces(aIndent);
		cout << proc->GetName().c_str();
		const PlugInList & dependencies = proc->GetDependencies();
		if (dependencies.size() > 0)
		{
			cout << " ->" << endl;
			PrintSubDependencies(aIndent + 2, dependencies);
		}
		else
			cout << endl;
	}
}

#if 0
void ExecutionGraph::PrintStateInfo(const SortedStateInfo & arStateInfo)
{
	cout << "Processor\t\tDependencies\tMax Depth\tRelative age" << endl;
	for (int i = 0; i < (int) arStateInfo.entries(); i++)
	{
		PlugInState * info = arStateInfo[i];

		cout << info->GetPlugIn()->GetName().c_str();
		PrintSpaces(24-info->GetPlugIn()->GetName().length());
		cout << info->GetCurrentDependencyCount() << "\t\t";
		cout << info->GetProcessorDepth() << "\t\t";
		cout << info->GetTag() << endl;
	}
}
#endif

/*
 * Hooks
 */

BOOL ExecutionGraph::InitializeHooks(MTPipelineLib::IMTConfigPtr aConfig)
{
	const char * functionName = "ExecutionGraph::InitializeHooks";

	mLogger.LogThis(LOG_DEBUG, "Initializing plug-in hooks");

	MTPipelineLib::IMTConfigPropSetPtr propset;
	if (!mBeforeHooks.ReadHookFile(aConfig, propset))
	{
		SetError(mBeforeHooks);
		return FALSE;
	}

	if (!mBeforeHooks.SetupHookHandler(propset, "before_plugin"))
	{
		SetError(mBeforeHooks);
		return FALSE;
	}

	if (!mAfterHooks.SetupHookHandler(propset, "after_plugin"))
	{
		SetError(mBeforeHooks);
		return FALSE;
	}

	return TRUE;
}

BOOL ExecutionGraph::InitializeExecutionInfo(MTPipelineLib::IMTSessionSetPtr aSet)
{
	const char * functionName = "ExecutionGraph::InitializeExecutionInfo";

	HRESULT hr = mExecutionInfo.CreateInstance("MetraPipeline.MTExecutionInfo.1");
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to create execution info object ("
						 "MetraPipeline.MTExecutionInfo.1"
						 ")");
		return FALSE;
	}

	mExecutionInfo->PutSessionSet(aSet);
	mExecutionInfo->PutStageName(mStageName.c_str());
	return TRUE;
}


void ExecutionGraph::CallBeforeHooks(StagePlugIn * aPlugIn)
{
	// change the plug-in name
	mExecutionInfo->PutPlugInName(aPlugIn->GetName().c_str());

	// execute the hooks
	IDispatchPtr idisp = mExecutionInfo;
	_variant_t var = idisp.GetInterfacePtr();
	unsigned long arg = HOOK_BEFORE_PLUG_IN;

	mBeforeHooks.ExecuteAllHooks(var, arg);
}

void ExecutionGraph::CallAfterHooks(StagePlugIn * aPlugIn)
{
	// change the plug-in name
	mExecutionInfo->PutPlugInName(aPlugIn->GetName().c_str());

	// execute the hooks
	IDispatchPtr idisp = mExecutionInfo;
	_variant_t var = idisp.GetInterfacePtr();
	unsigned long arg = HOOK_AFTER_PLUG_IN;

	mAfterHooks.ExecuteAllHooks(var, arg);
}


/**************************************** InitialPlugInState ***/

InitialPlugInState::InitialPlugInState()
	: mDependsOnMe(NULL), mDependsOnMeSize(0), mInitialDependencyCount(0)
{
}

InitialPlugInState::~InitialPlugInState()
{
	if (mDependsOnMe)
	{
		delete [] mDependsOnMe;
		mDependsOnMe = NULL;
	}
}

void InitialPlugInState::Initialize(StagePlugIn * apPlugIn)
{
	SetPlugIn(apPlugIn);

	// fill in the "depends on me" index list
	const PlugInList & dependsOnMe = apPlugIn->GetDependsOnMe();

	// we know the size
	mDependsOnMeSize = dependsOnMe.size();
	if (mDependsOnMeSize > 0)
	{
		mDependsOnMe = new int[dependsOnMe.size()];

		PlugInList::const_iterator dependsIt;
		int i;
		for (i = 0, dependsIt = dependsOnMe.begin();
				 dependsIt != dependsOnMe.end();
				 ++dependsIt, ++i)
		{
			StagePlugIn * dependency = *dependsIt;
			int index = dependency->GetIndex();

			mDependsOnMe[i] = index;
		}
	}
	else
		mDependsOnMe = NULL;

	mInitialDependencyCount = apPlugIn->GetDependencies().size();
}


/*********************************************** PlugInState ***/

PlugInState::PlugInState() : mDependsOnMe(NULL), mDependsOnMeSize(0),
	mCurrentDependencyCount(0), mTag(0)
{
}

PlugInState::~PlugInState()
{
	if (mDependsOnMe)
	{
		delete [] mDependsOnMe;
		mDependsOnMe = NULL;
	}
}


void PlugInState::Initialize(InitialPlugInState * apInitialState,
														 PlugInState * apStateArray)
{
	SetPlugIn(apInitialState->GetPlugIn());
	mCurrentDependencyCount = apInitialState->GetInitialDependencyCount();

	// resolve the pointers to relationships
	const int * indeces = apInitialState->GetDependsOnMe();
	mDependsOnMeSize = apInitialState->GetDependsOnMeSize();
	if (mDependsOnMeSize > 0)
	{
		mDependsOnMe = new PlugInState * [mDependsOnMeSize];

		for (int i = 0; i < mDependsOnMeSize; i++)
		{
			PlugInState * state = &apStateArray[indeces[i]];
			mDependsOnMe[i] = state;
		}
	}
	else
		mDependsOnMe = NULL;
}



bool PlugInState::operator == (const PlugInState & arInfo) const
{
	return (GetPlugIn() == arInfo.GetPlugIn()) ? true : false;
}


bool PlugInState::operator < (const PlugInState & arInfo) const
{
	// TODO: maybe this routine should be optimized?

	// this comparison is critical!

	if (GetCurrentDependencyCount() < arInfo.GetCurrentDependencyCount())
		return TRUE;

	if (GetCurrentDependencyCount() > arInfo.GetCurrentDependencyCount())
		return FALSE;

	// mDependencyCount == arInfo.mDependencyCount
	if (GetTag() < arInfo.GetTag())
		return TRUE;

	if (GetTag() > arInfo.GetTag())
		return FALSE;

	// mDependencyCount == arInfo.mDependencyCount && mTag == arInfo.mTag

	// deeper nodes should be higher up in the queue
	if (GetProcessorDepth() > arInfo.GetProcessorDepth())
		return TRUE;

	if (GetProcessorDepth() < arInfo.GetProcessorDepth())
		return FALSE;

	// TODO: use any other heuristics (performance based?)

	// has to be well defined
	return this < &arInfo;
}


/*********************************************** StagePlugIn ***/


// default constructor needed to go into the map
StagePlugIn::StagePlugIn() : CompositePlugIn("logging", "[PlugIn]")
{ }

StagePlugIn::StagePlugIn(const char * apName) : CompositePlugIn("logging", "[PlugIn]")
{
	SetName(apName);
}

StagePlugIn::~StagePlugIn()
{ }

void StagePlugIn::AddDependency(StagePlugIn & arProc)
{
	mDependsOn.push_back(&arProc);
	arProc.DependsOnMe(*this);
}

void StagePlugIn::DependsOnMe(StagePlugIn & arProc)
{
	mDependsOnMe.push_back(&arProc);
}


const PlugInList & StagePlugIn::GetDependencies() const
{ return mDependsOn; }

PlugInList & StagePlugIn::GetDependencies()
{ return mDependsOn; }


const PlugInList & StagePlugIn::GetDependsOnMe() const
{ return mDependsOnMe; }


BOOL StagePlugIn::Mark()
{
	BOOL oldMark = mMark;
	mMark = TRUE;
	return oldMark;
}

void StagePlugIn::ClearMark()
{ mMark = FALSE; }

bool StagePlugIn::operator == (const StagePlugIn & arStage2) const
{
	return (arStage2.GetName() == GetName()) ? true : false;
}
