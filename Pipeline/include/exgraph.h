/**************************************************************************
 * @doc EXGRAPH
 *
 * @module |
 *
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
 *
 * @index | EXGRAPH
 ***************************************************************************/

#ifndef _EXGRAPH_H
#define _EXGRAPH_H

#include <processor.h>
#include <pipelinehooks.h>

#include <map>
#include <list>
#include <string>

using std::map;
using std::list;
using std::string;

class ExecutionGraph;

/***************************************** StagePlugInConfig ***/

class StagePlugIn;

typedef list<StagePlugIn *> PlugInList;

typedef map<string, StagePlugIn> PlugInMap;

class StagePlugIn : public CompositePlugIn
{
public:
	// default constructor needed to go into the map
	StagePlugIn();
	StagePlugIn(const char * apName);
	virtual ~StagePlugIn();

	void AddDependency(StagePlugIn & arProc);

	void DependsOnMe(StagePlugIn & arProc);

	const PlugInList & GetDependencies() const;

	PlugInList & GetDependencies();

	const PlugInList & GetDependsOnMe() const;

	void PrintConfiguration(PropSet & arPropSet);

	int GetIndex() const
	{ return mIndex; }

	void SetIndex(int aIndex)
	{ mIndex = aIndex; }


	int GetDepth() const
	{ return mDepth; }

	void SetDepth(int aDepth)
	{ mDepth = aDepth; }


	BOOL Mark();

	void ClearMark();

	bool operator == (const StagePlugIn &) const;

private:
	PlugInList mDependsOn;
	PlugInList mDependsOnMe;

	BOOL mMark;

	// current processor index.  starts at 0, and increases for each
	// new processor
	int mIndex;

	int mDepth;

	NTLogger mLogger;
};


/***************************************** RelationshipInfo ***/

class RelationshipInfo
{
public:
	RelationshipInfo() : mpPlugIn(NULL)
	{ }
	virtual ~RelationshipInfo()
	{ }

	int GetProcessorDepth() const
	{ return mpPlugIn->GetDepth(); }

	int GetProcessorIndex() const
	{ return mpPlugIn->GetIndex(); }

	StagePlugIn * GetPlugIn()
	{ return mpPlugIn; }

	const StagePlugIn * GetPlugIn() const
	{ return mpPlugIn; }

protected:
	void SetPlugIn(StagePlugIn * apPlugIn)
	{ mpPlugIn = apPlugIn; }

private:
	StagePlugIn * mpPlugIn;
};

/*************************************** InitialPlugInState ***/

class InitialPlugInState : public RelationshipInfo
{
public:
	InitialPlugInState();
	virtual ~InitialPlugInState();

	const int * GetDependsOnMe() const
	{ return mDependsOnMe; }

	int GetDependsOnMeSize() const
	{ return mDependsOnMeSize; }

	void Initialize(StagePlugIn * apPlugIn);

	int GetInitialDependencyCount() const
	{ return mInitialDependencyCount; }

private:
	int * mDependsOnMe;
	int mDependsOnMeSize;

	int mInitialDependencyCount;
};

/********************************************** PlugInState ***/

class PlugInState : public RelationshipInfo
{
public:
	PlugInState();
	virtual ~PlugInState();

	void Initialize(InitialPlugInState * apInitialState,
									PlugInState * apStateArray);

	bool operator == (const PlugInState & arInfo) const;

	bool operator < (const PlugInState & arInfo) const;

	PlugInState * * GetDependsOnMe()
	{ return mDependsOnMe; }

	int GetDependsOnMeSize() const
	{ return mDependsOnMeSize; }

	int GetCurrentDependencyCount() const
	{ return mCurrentDependencyCount; }

	int DecrementDependencyCount()
	{ return --mCurrentDependencyCount; }

	int GetTag() const
	{ return mTag; }

	void SetTag(int aTag)
	{ mTag = aTag; }

private:
	// array of pointers to all PlugInStates that depend on this one
	PlugInState * * mDependsOnMe;
	int mDependsOnMeSize;

	int mCurrentDependencyCount;

	int mTag;
};

/******************************************* ExecutionGraph ***/

class ExecutionGraph : public virtual ObjectWithError
{
public:
	ExecutionGraph();
	virtual ~ExecutionGraph();

	// clear all internal data structures
	void Clear();

	BOOL Init(MTPipelineLib::IMTConfigLoaderPtr aConfigLoader,
						MTPipelineLib::IMTConfigPtr aConfig,
						MTPipelineLib::IMTSessionServerPtr aSessionServer,
						MTPipelineLib::IMTSystemContextPtr aSysContext,
						std::string aConfigPath, std::string aStageName, int aStageinstance);

	BOOL ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet, std::string & arFailurePlugIn);

	// shutdown all plug-ins
	BOOL ShutdownPlugIns();

	// clear all plug-ins
	BOOL ClearPlugIns();

	BOOL ReadDependencies(MTPipelineLib::IMTConfigPropSetPtr & arDependencies);

	void SetRunAutoTests(BOOL aFlag)
	{ mRunAutoTests = aFlag; }

	void SetVerbose(BOOL aFlag)
	{ mVerbose = aFlag; }

private:
	BOOL RealInit();

	void CreateRelationshipMap();

	static void MeasureDepths(int aDepth, StagePlugIn * apProc, PlugInList & arList);

	StagePlugIn & GetProcessor(const char * apName);
	void AddFinalDependency(StagePlugIn & arProc);

	const PlugInList & GetPlugIns() const
	{ return mAllProcessors; }

	PlugInList & GetPlugIns()
	{ return mAllProcessors; }

	const PlugInList & GetFinalDependencies()
	{ return mFinal; }

  void SetUpLoggerTagName( StagePlugIn *plugIn );

	//
	// debugging
	//
	void PrintDependencies();
	void PrintSubDependencies(int aIndent, const PlugInList & aProcList);

	void PrintSpaces(int aIndent);


	//
	// hooks
	//
	BOOL InitializeHooks(MTPipelineLib::IMTConfigPtr aConfig);

	BOOL InitializeExecutionInfo(MTPipelineLib::IMTSessionSetPtr aSet);

	void CallBeforeHooks(StagePlugIn * aPlugIn);

	void CallAfterHooks(StagePlugIn * aPlugIn);

private:
	InitialPlugInState * mRelationshipPrototype;
	int mRelationshipPrototypeSize;

	// map of processors referenced by name
	PlugInMap mMap;
	// list of final dependencies
	PlugInList mFinal;

	// HACK - keep list of pointers to all processors
	PlugInList mAllProcessors;

	NTLogger mLogger;

	int mIndex;


private:
	// set to true when the execution graph is actually initialized
	BOOL mInitialized;

	MTPipelineLib::IMTConfigLoaderPtr aConfigLoader;
	MTPipelineLib::IMTConfigPtr aConfig;
	MTPipelineLib::IMTSessionServerPtr aSessionServer;
	MTPipelineLib::IMTSystemContextPtr aSysContext;
	std::string aConfigPath;
	std::string mStageName;
  int mStageInstance;

	// hooks to call before each plug-in is executed.
	PipelineHooks mBeforeHooks;

	// hooks to call after each plug-in is executed.
	PipelineHooks mAfterHooks;

	// passed into hooks
	// NOTE: this single use object could become a problem if this
	// class becomes multi-threaded.
	MTPipelineLib::IMTExecutionInfoPtr mExecutionInfo;

	// if true, run the plug-in autotests
	BOOL mRunAutoTests;

	// if true, print status to stdout
	BOOL mVerbose;

	enum
	{
		HOOK_BEFORE_PLUG_IN = 1,
		HOOK_AFTER_PLUG_IN = 2,
	};
};


#endif /* _EXGRAPH_H */
