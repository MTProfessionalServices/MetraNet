/**************************************************************************
 * @doc PROCESSOR
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
 * @index | PROCESSOR
 ***************************************************************************/

#ifndef _PROCESSOR_H
#define _PROCESSOR_H


/*
 * includes
 */

#include <string>
#include <list>
#include <vector>
using std::string;
using std::list;
using std::vector;

#include <errobj.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <sessionsconfig.h>
#include <autosessiontest.h>

class MTSQLSharedSessionFactoryWrapper;
class PlugInConfig;

/*
 * typedefs
 */

typedef MTPipelineLib::IMTConfigPropSetPtr PropSet;

/*********************************************** ArgumentMap ***/

class ArgumentMap
{
public:
	_bstr_t argument;
	_bstr_t property;

	// needs the == to be placed in a vector
	bool operator ==(const ArgumentMap & arMap) const
	{
		return argument == arMap.argument && property == arMap.property;
	}
};

/**************************************** ProcessorInterface ***/

class ProcessorInterface : public virtual ObjectWithError
{
public:
	virtual ~ProcessorInterface()
	{ }

	virtual BOOL Initialize(MTPipelineLib::IMTSystemContextPtr aSystemContext,
													PropSet aConfigData) = 0;

	virtual BOOL Shutdown() = 0;

	virtual BOOL ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet) = 0;
};

/********************************** DirectProcessorInterface ***/

class DirectProcessorInterface : public ProcessorInterface
{
public:
	DirectProcessorInterface(MTPipelineLib::IMTPipelinePlugInPtr aInterface);

	virtual BOOL Initialize(MTPipelineLib::IMTSystemContextPtr aSystemContext,
													PropSet aConfigData);

	virtual BOOL Shutdown();

	virtual BOOL ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet);

private:
	MTPipelineLib::IMTPipelinePlugInPtr mInterface;
};

/********************************* DirectProcessorInterface2 ***/

// NOTE: this interface is nearly identical to DirectProcessorInterface
// except that it is VB/Java compatible

class DirectProcessorInterface2 : public ProcessorInterface
{
public:
	DirectProcessorInterface2(MTPipelineLib::IMTPipelinePlugIn2Ptr aInterface);

	virtual BOOL Initialize(MTPipelineLib::IMTSystemContextPtr aSystemContext,
													PropSet aConfigData);

	virtual BOOL Shutdown();

	virtual BOOL ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet);

private:
	MTPipelineLib::IMTPipelinePlugIn2Ptr mInterface;
};


/******************************** DispatchProcessorInterface ***/

class DispatchProcessorInterface : public ProcessorInterface
{
public:
	DispatchProcessorInterface(IDispatchPtr aInterface);

	virtual BOOL Initialize(MTPipelineLib::IMTSystemContextPtr aSystemContext,
													PropSet aConfigData);

	virtual BOOL Shutdown();

	virtual BOOL ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet);
private:
	IDispatchPtr mInterface;
};

/******************************************** PlugInAutoTest ***/

class PlugInAutoTest : public PipelineAutoTest
{
public:
	void SetPlugIn(PlugInConfig * apPlugIn)
	{ mpPlugIn = apPlugIn; }

protected:
	virtual BOOL RunSession(PipelineAutoTest & arTest,
													MTPipelineLib::IMTSessionSetPtr aSet);

private:
	PlugInConfig * mpPlugIn;
};


/********************************************** PlugInConfig ***/

class PlugInInfoReader;
class MTSQLInterpreter;
class MTSQLExecutable;
class MTSQLSessionCompileEnvironment;

class PipelinePlugIn : public virtual ObjectWithError
{
public:
	virtual ~PipelinePlugIn()
	{ }

public:
	void SetName(const char * apName)
	{ mName = apName; }

	const string & GetName() const
	{ return mName; }

	virtual BOOL LoadProcessor() = 0;
	virtual BOOL Initialize(MTPipelineLib::IMTSystemContextPtr aSystemContext) = 0;
	virtual BOOL Shutdown() = 0;
	virtual void Clear() = 0;
	virtual BOOL ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet) = 0;

	virtual BOOL ReadAutoTest(MTPipelineLib::IMTConfigPtr aConfig,
														const char * apConfigDir, const char * apStageName) = 0;

	virtual BOOL RunAutoTest(MTPipelineLib::IMTNameIDPtr aNameID,
													 MTPipelineLib::IMTSessionServerPtr aSessionServer) = 0;

private:
	// name of the plugin
	string mName;
};


class PlugInConfig : public PipelinePlugIn
{
	friend PlugInInfoReader;
public:
	PlugInConfig(const char * apDirName,
							 const char * apTagName,
							 MTPipelineLib::IMTSessionServerPtr aSessionServer);
	virtual ~PlugInConfig();

	virtual BOOL LoadProcessor();
	virtual BOOL Initialize(MTPipelineLib::IMTSystemContextPtr aSystemContext);
	virtual BOOL Shutdown();
	virtual void Clear();
	virtual BOOL ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet);									 

	//
	// autotesting
	//
	virtual BOOL ReadAutoTest(MTPipelineLib::IMTConfigPtr aConfig,
														const char * apConfigDir, const char * apStageName);

	virtual BOOL RunAutoTest(MTPipelineLib::IMTNameIDPtr aNameID,
													 MTPipelineLib::IMTSessionServerPtr aSessionServer);

	// called by PlugInAutoTest class
	BOOL RunTestSession(MTPipelineLib::IMTSessionSetPtr aSet);

public:
	ProcessorInterface * GetInterface()
	{ return mpInterface; }

	PropSet & GetConfigData()
	{ return mConfigData; }

	const PipelineAutoTest::AutoTestList & GetAutoTestList() const
	{ return mAutoTestList; }

	long GetEffectiveDate();

	void SetConfigFile(MTPipelineLib::IMTConfigFilePtr aConfigFile)
	{ mConfigFile = aConfigFile; }

private:
	BOOL ReadTestSetup(MTPipelineLib::IMTConfigPtr aConfig, const char * apTestFile);

	MTPipelineLib::IMTSessionPtr
	CreateTestSession(MTPipelineLib::IMTNameIDPtr aNameID,
										MTPipelineLib::IMTSessionServerPtr aSessionServer,
										TestSession & arSession,
										MTPipelineLib::IMTSessionPtr aParentSession);

	BOOL TestOutputProps(MTPipelineLib::IMTNameIDPtr aNameID,
											 MTPipelineLib::IMTSessionPtr aSession, TestSession & arSession);

	BOOL ProcessSessionsConditionally(MTPipelineLib::IMTSessionSetPtr aSet);
  BOOL ResetExecutePluginProperty(MTPipelineLib::IMTSessionSetPtr aSet);

	ProcessorInterface * mpInterface;

	PropSet mConfigData;
	// TODO: hack!
	PropSet mAllConfigData;

	int mVersion;

	std::string mProgId;

	vector<ArgumentMap> mInputVector;
	vector<ArgumentMap> mOutputVector;


	PlugInAutoTest mAutoTest;

	PipelineAutoTest::AutoTestList mAutoTestList;

	// effective date info
	MTPipelineLib::IMTConfigFilePtr mConfigFile;

	// a set of test sessions used to autotest the plug-in
	TestSessions mTestSessions;

	NTLogger mLogger;
	MTPipelineLib::IMTLogPtr mCOMLogger;

	MTSQLInterpreter * mpSQLInterpreter;
	MTSQLExecutable * mpSQLConditionProcedure;
	MTSQLSessionCompileEnvironment * mpSQLCompileEnv;
  MTSQLSharedSessionFactoryWrapper * mpFactory;

	MTPipelineLib::IMTSessionServerPtr mSessionServer;
};



typedef list<PlugInConfig *> PlugInConfigList;

class CompositePlugIn : public PipelinePlugIn
{
public:
	CompositePlugIn(const char * apDirName, const char * apTagName);
	virtual ~CompositePlugIn();

	virtual BOOL LoadProcessor();
	virtual BOOL Initialize(MTPipelineLib::IMTSystemContextPtr aSystemContext);
	virtual BOOL Shutdown();
	virtual void Clear();
	virtual BOOL ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet);

	virtual BOOL ReadAutoTest(MTPipelineLib::IMTConfigPtr aConfig,
														const char * apConfigDir, const char * apStageName);

	virtual BOOL RunAutoTest(MTPipelineLib::IMTNameIDPtr aNameID,
													 MTPipelineLib::IMTSessionServerPtr aSessionServer);

	BOOL Configure(MTPipelineLib::IMTConfigPtr aConfig,
								 MTPipelineLib::IMTConfigLoaderPtr aConfigLoader,
								 const char * apConfigPath,
								 const char * apStageName,
								 MTPipelineLib::IMTSessionServerPtr aSessionServer);

private:
	long GetSetTimestamp(MTPipelineLib::IMTSessionSetPtr aSet);

private:
	// active configurations, listed with the most recent configuration first,
	// older configuration following in sorted order
	PlugInConfigList mConfigList;

	NTLogger mLogger;
};

#endif /* _PROCESSOR_H */
