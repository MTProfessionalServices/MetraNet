/**************************************************************************
 * @doc ScriptedFrame
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
 * Modification History:
 *		Chen He - September 14, 1998 : Initial version
 *
 * $Header$
 *
 *****************************************************************************/

// ScriptHosting.cpp: implementation of the CScriptHosting class.
//
//////////////////////////////////////////////////////////////////////

#include "StdAfx.h"
#include "ScriptHost.h"
#include "ScriptHosting.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
//#define new DEBUG_NEW
#endif

using namespace MTPipelineLib;

#include <ConfigDir.h>
#include "mtprogids.h"
#include "MTUtil.h"

//const wchar_t regKey[] = L"SOFTWARE\\MetraTech\\Netmeter";
//const wchar_t regValue[] = L"ConfigDir";

//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CScriptHosting::CScriptHosting()
{
#if MTDEBUG
	cout << "CScriptHosting::CScriptHosting()" << endl;
#endif
	mpScriptedFrame = NULL;
	mSHProcFlag = FALSE;

	// initialize log
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), PIPELINE_TAG);
}

CScriptHosting::~CScriptHosting()
{
#if MTDEBUG
	cout << "CScriptHosting::~CScriptHosting()" << endl;
#endif
	if (mpScriptedFrame != NULL)
	{
		mpScriptedFrame->QuitScript();
		mpScriptedFrame->Release();
		mpScriptedFrame = NULL;
	}
}


//////////////////////////////////////////////////////////////////////////////////
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CScriptHosting::Serialization"
BOOL CScriptHosting::Serialization(IUnknown * systemContext, 
																 IMTConfigPropSetPtr apPropSet)
{
	//IMTNameIDPtr				idlookup(systemContext);
	IMTConfigPropSetPtr scriptConfigSet;
	string						sessionFlag;
	string						sFilename;
	char logBuf[MAX_BUFFER_SIZE];
	BOOL bRetCode = TRUE;

	//ASSERT(0);

#if MTDEBUG
	cout << "CScriptHosting::Serialization" << endl;
#endif

	apPropSet->Reset();

	// 1) Get Script file name, type
	try
	{
		_bstr_t scriptFileName = apPropSet->NextStringWithName(SCRIPT_SOURCE);
		sFilename = scriptFileName;
	}
	catch(_com_error err)
	{
		sprintf (logBuf, "Error getting configuration data - <%s>: %s",
						SCRIPT_SOURCE,
						PROCEDURE);
		mErrorMsg = logBuf;
		bRetCode = mLogger.LogThis(LOG_ERROR,logBuf) ;
		return FALSE;
	}

	if (!ProcessScriptFilename(systemContext,sFilename))
	{
		sprintf (logBuf, "Failed to find script source file - <%s>: %s",
						mScriptFileName.c_str(),
						PROCEDURE);
		mErrorMsg = logBuf;
		//bRetCode = mLogger.LogThis(LOG_ERROR,logBuf) ;
		return FALSE;
	}

	try
	{
		_bstr_t scriptType = apPropSet->NextStringWithName(SCRIPT_TYPE);
		mScriptType = scriptType;
	}
	catch(_com_error err)
	{
		sprintf (logBuf, "Error getting configuration data - <%s>: %s",
						SCRIPT_TYPE,
						PROCEDURE);
		mErrorMsg = logBuf;
		bRetCode = mLogger.LogThis(LOG_ERROR,logBuf) ;
		return FALSE;
	}

	// Get process session set flag
	try
	{
		_bstr_t procSessionFlag = apPropSet->NextStringWithName(PROCESS_SESSION_SET);
		sessionFlag = procSessionFlag;
	}
	catch(_com_error err)
	{
		sprintf (logBuf, "Error getting configuration data - <%s>: %s",
						PROCESS_SESSION_SET,
						PROCEDURE);
		mErrorMsg = logBuf;
		bRetCode = mLogger.LogThis(LOG_ERROR,logBuf) ;
		return FALSE;
	}

	if (strcmp(sessionFlag.c_str(), PROCESS_SESSION_SET_FLAG) == 0)
	{
		mSHProcFlag = TRUE;
	}

	VARIANT_BOOL bFlag = apPropSet->NextMatches(SCRIPT_CONFIGDATA, MTPipelineLib::PROP_TYPE_SET);
	
	if (bFlag == VARIANT_TRUE)
	{
		// Get the config data set form script to use
		try
		{
			scriptConfigSet = apPropSet->NextSetWithName(SCRIPT_CONFIGDATA);
		}
		catch(_com_error err)
		{
			sprintf (logBuf, "No <%s> section available: %s",
							SCRIPT_CONFIGDATA,
							PROCEDURE);
			mErrorMsg = logBuf;
			bRetCode = mLogger.LogThis(LOG_WARNING,logBuf) ;
			scriptConfigSet = NULL;
		}

		if (scriptConfigSet == NULL)
		{
			sprintf (logBuf, "No Script configuration data available in <%s>: %s",
							SCRIPT_CONFIGDATA,
							PROCEDURE);
			mErrorMsg = logBuf;
			bRetCode = mLogger.LogThis(LOG_WARNING,logBuf) ;
		}
		else
		{
			scriptConfigSet->Reset();
		}

		mScriptConfig = scriptConfigSet;
	}
	else
	{
		mScriptConfig = NULL;
	}

	// 2) Initialize the script frame
	if ((mpScriptedFrame = new CScriptedFrame(mScriptType)) == NULL)
	{
		sprintf (logBuf, "Error create object CScriptedFrame: %s",
						PROCEDURE);
		mErrorMsg = logBuf;
		bRetCode = mLogger.LogThis(LOG_ERROR,logBuf) ;
		return FALSE;
	}
	mpScriptedFrame->AddRef();

	return TRUE;
}

///////////////////////////////////////////////////////////////////////////
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CScriptHosting::InitializeScriptHost"
BOOL CScriptHosting::InitializeScriptHost(IUnknown * systemContext)
{
	char logBuf[MAX_BUFFER_SIZE];
	BOOL bRetCode = TRUE;

	if (mpScriptedFrame == NULL)
	{
		if ((mpScriptedFrame = new CScriptedFrame(mScriptType)) == NULL)
		{
			mErrorMsg = "Error creating CScriptedFrame object";
			sprintf (logBuf, "%s: %s", 
							mErrorMsg.c_str(), 
							PROCEDURE);
			bRetCode = mLogger.LogThis(LOG_ERROR,logBuf) ;
			return FALSE;
		}
		mpScriptedFrame->AddRef();
	}

  // 3) If initialization of the script host is successful, run the script
	if (mpScriptedFrame->InitializeScriptFrame(mScriptFileName))
	{
		try
		{
			mpScriptedFrame->RunScript(systemContext);
		}
		catch(ErrorObject aLocalError)
		{
			sprintf(logBuf, "Error: %s, %s(%d) %s(%d)", 
							aLocalError.GetModuleName(),
							aLocalError.GetFunctionName(),
							aLocalError.GetLineNumber(),
							aLocalError.GetProgrammerDetail().c_str(),
							aLocalError.GetCode());
			mErrorMsg = logBuf;
			return FALSE;
		}

	}
	else
	{
		mpScriptedFrame->QuitScript();
		mErrorMsg = "Error calling InitializeScriptFrame()";
		sprintf (logBuf, "%s: %s", 
						mErrorMsg.c_str(), 
						PROCEDURE);
		bRetCode = mLogger.LogThis(LOG_ERROR,logBuf) ;
		return FALSE;
	}

	if (mScriptConfig != NULL)
	{
		mScriptConfig->Reset();
	}

	// Fire the event to initialize the process (Script code side)
	HRESULT hr = mpScriptedFrame->Configure(mScriptConfig);
	if (FAILED(hr))
	{
		mErrorMsg = mpScriptedFrame->GetErrorMsg();
		sprintf (logBuf, "%s: %s", 
						mErrorMsg.c_str(), 
						PROCEDURE);
		bRetCode = mLogger.LogThis(LOG_ERROR,logBuf) ;
		return FALSE;
	}

	return TRUE;
}


HRESULT CScriptHosting::ProcessSession(IMTSessionPtr apSession)
{
	HRESULT hr = mpScriptedFrame->ProcessSession(apSession);
	if (FAILED(hr))
	{
		mErrorMsg = mpScriptedFrame->GetErrorMsg();
	}

	return hr;
}


HRESULT CScriptHosting::ProcessSessionSet(IMTSessionSetPtr apSessionSet)
{
	HRESULT hr = mpScriptedFrame->ProcessSessionSet(apSessionSet);
	if (FAILED(hr))
	{
		mErrorMsg = mpScriptedFrame->GetErrorMsg();
	}

	return hr;
}


BOOL CScriptHosting::QuitScript()
{
	if (mpScriptedFrame)
	{
		mpScriptedFrame->QuitScript();
	}

	return TRUE;
}

BOOL CScriptHosting::Shutdown()
{
	if (mpScriptedFrame)
	{
		mpScriptedFrame->QuitScript();
		mpScriptedFrame->Release();
		mpScriptedFrame = NULL;
	}

	return TRUE;
}


///////////////////////////////////////////////////////////////////////////
BOOL CScriptHosting::ProcessScriptFilename(IUnknown * systemContext,string aFilename)
{
	int index = aFilename.find_first_of(DISK_DEVICE_CHAR);

	// This is not a absolute device path, go to the registry to get the config root
  if (index == string::npos) {
		// get the sys context object
		MTPipelineLib::IMTSystemContextPtr aSysContext = systemContext;
		mScriptFileName = aSysContext->GetStageDirectory();
		mScriptFileName += DIR_SEP;
		mScriptFileName += "..\\..\\";
		mScriptFileName += aFilename;
	}

	// check if script file exist
	return CheckFile(mScriptFileName);
}

//////////////////////////////////////////////////////////////////////////////
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CScriptHosting::GetConfigRoot"
BOOL CScriptHosting::GetConfigRoot(string& aRoot)
{
	if (!GetMTConfigDir(aRoot))
	{
		mLogger.LogThis(LOG_ERROR, "Script plugin unable to read configuration directory");
		return FALSE;
	}
	return TRUE;
}
