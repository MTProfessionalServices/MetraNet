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
 ***************************************************************************
 *
 * File:				ScriptedFrame.h
 *
 * Description: This file contains the declaration of a generic class for 
 *              the implementation of an ActiveX Scripting Host.  This 
 *              class implements the interfaces necessary to serve as a 
 *              Script Host, and can be modified for specific applications 
 *              and examples.
 *
 * Modification History:
 *		Chen He - September 14, 1998 : Initial version
 *
 * $Header$
 *
 *****************************************************************************/

#include "StdAfx.h"
#include "ScriptedFrame.h"

using namespace std;

using namespace MTPipelineLib;


void ShowBSTR(char *prompt, BSTR pbStr) 
{
	static char sz[256];
	static char txt[8192];

	// Convert down to ANSI
	WideCharToMultiByte(CP_ACP, 0, pbStr, -1, sz, 256, NULL, NULL);

	sprintf(txt, "%s: %s", prompt, sz);
	printf("%s\n", txt);
   //::MessageBox(NULL, txt, "ShowBSTR", MB_SETFOREGROUND | MB_OK);
}


//Constructor
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CScriptedFrame::CScriptedFrame"
CScriptedFrame::CScriptedFrame()
{
#if MTDEBUG
	cout << "CScriptedFrame::CScriptedFrame()" << endl;
#endif
	mRefCount = 0;
  mEngine = NULL;
	mParser = NULL;
	mpTheScript = NULL;
  mpMTScriptHost = NULL;
	BOOL bRetCode;
	char logBuf[MAX_BUFFER_SIZE];

	// Default script host engine
	mScriptType = L"VBScript";

	// initialize log
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), PIPELINE_TAG);

	sprintf (logBuf, "Leaving %s", PROCEDURE);
	bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
#if MTDEBUG
  printf("CScriptedFrame\n");
#endif
}

///////////////////////////////////////////////////////////////////////////////
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CScriptedFrame::CScriptedFrame(wstring& aScriptType)"
CScriptedFrame::CScriptedFrame(wstring& aScriptType)
{
#if MTDEBUG
	cout << "CScriptedFrame::CScriptedFrame(wstring& aScriptType)" << endl;
#endif
	BOOL bRetCode;
	char logBuf[MAX_BUFFER_SIZE];

	mRefCount = 0;
	mEngine = NULL;
	mParser = NULL;
	mpTheScript = NULL;
	mpMTScriptHost = NULL;
	mpIMTLog = NULL;

	mScriptType = aScriptType;

	// initialize log
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), PIPELINE_TAG);

	sprintf (logBuf, "Leaving %s", PROCEDURE);
	bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
}

//Destructor
CScriptedFrame::~CScriptedFrame()
{
#if MTDEBUG
	printf("CScriptedFrame::~CScriptedFrame\n");
#endif

  if (mEngine != NULL)
	{
		mEngine->Release();
		mEngine = NULL;
  }

  if (mParser != NULL)
	{
		mParser->Release();
		mParser = NULL;
  }

	if (mpTheScript != NULL)
	{
		delete mpTheScript;
		mpTheScript = NULL;
	}

  if (mpMTScriptHost != NULL)
	{
		mpMTScriptHost->Release();
		mpMTScriptHost = NULL;
	}

}

/******************************************************************************
*   InitializeScriptFrame -- Creates the ActiveX Scripting Engine and 
*   initializes it.  Returns true if successful, false otherwise.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CScriptedFrame::InitializeScriptFrame"
BOOL CScriptedFrame::InitializeScriptFrame(string& aScriptFileName)
{
	long	fileSize = 0;
	char	*str;
	BOOL bRetCode;
	char logBuf[MAX_BUFFER_SIZE];

#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::InitializeScriptedFrame\n");
#endif
	sprintf (logBuf, "Entering %s", PROCEDURE);
	bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

	if (mpTheScript)
		return TRUE;

	HRESULT hr = CLSIDFromProgID(mScriptType.c_str(), &mEngineClsid);
	if (FAILED(hr))
	{
		sprintf (logBuf, "Failed to get ScriptHost engine(%s) progid(HRESULT=%lx): %s",
						mScriptType.c_str(),
						hr,
						PROCEDURE);
		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}

	//First, create the scripting engine with a call to CoCreateInstance, 
  //placing the created engine in mEngine.
  hr = CoCreateInstance(mEngineClsid, 
																NULL, 
																CLSCTX_INPROC_SERVER, 
																IID_IActiveScript, 
																(void **)&mEngine);
	if (FAILED(hr))
	{
#if MTDEBUG
		printf("Failed to create scripting engine.\n");
#endif
		sprintf (logBuf, "Failed to create ScriptHost engine instance(HRESULT=%lx): %s", 
						hr,
						PROCEDURE);

		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}

	//Now query for the IActiveScriptParse interface of the engine
	hr = mEngine->QueryInterface(IID_IActiveScriptParse, (void**)&mParser);
	if (FAILED(hr))
	{
#if MTDEBUG
		printf("Engine doesn't support IActiveScriptParse.\n");
#endif
		sprintf (logBuf, "Engine doesn't support IActiveScriptParse(HRESULT=%lx): %s",
						hr,
						PROCEDURE);

		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}

	//The engine needs to know the host it runs on.
	// called AddRef() by reference this to the interface
	hr = mEngine->SetScriptSite(this);
	if (FAILED(hr))
	{
#if MTDEBUG
		printf("Error calling SetScriptSite\n");
#endif
		sprintf (logBuf, "Error calling SetScriptSite(HRESULT=%lx): %s", 
						hr,
						PROCEDURE);

		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}

	//Initialize the script engine so it's ready to run.
	hr = mParser->InitNew();
	if (FAILED(hr))
	{
#if MTDEBUG
		printf("Error calling InitNew\n");
#endif
		sprintf (logBuf, "Error calling InitNew(HRESULT=%lx): %s", 
						hr,
						PROCEDURE);

		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}

	// a) Get file size
	if ((fileSize = FileSize(aScriptFileName)) == -1)
	{
#if MTDEBUG
		cout << "Error getting script file size: " << aScriptFileName << endl;
#endif
		sprintf (logBuf, "Error getting script file size(filename=%s): %s", 
						aScriptFileName.c_str(),
						PROCEDURE);

		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}

	//Read the file into a string
	//Open and read the file of the script to be run
	ifstream scriptStream(aScriptFileName.c_str(), 
												ios::binary | ios::in);
	if (!scriptStream)
	{
#if MTDEBUG
		printf("Error opening script file.\n");
#endif
		sprintf (logBuf, "Error openning script file(filename=%s): %s", 
						aScriptFileName.c_str(),
						PROCEDURE);

		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
  }

	if ((str = new char[fileSize+1]) == NULL)
	{
#if MTDEBUG
		printf("Error allocate internal buffer.\n");
#endif
		sprintf (logBuf, "Error allocate internal buffer: %s", 
						PROCEDURE);

		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}

	memset(str, 0, fileSize + 1);

	scriptStream.read((char *)str, fileSize);

	scriptStream.close();

	//Copy the file to the script buffer, which is a Unicode string
	if ((mpTheScript = new WCHAR[fileSize+1]) == NULL)
	{
#if MTDEBUG
		printf("Error allocate script buffer.\n");
#endif
		sprintf (logBuf, "Error allocate script buffer: %s", 
						PROCEDURE);

		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}

	memset(mpTheScript, 0, sizeof(WCHAR)*(fileSize+1));

	if (!MultiByteToWideChar( CP_ACP, MB_PRECOMPOSED, 
														(char *)str, fileSize, 
														mpTheScript, fileSize+1))
	{
#if MTDEBUG
		printf("Error translating script code string.\n");
#endif
		sprintf (logBuf, "Error translating script code string: %s", 
						PROCEDURE);

		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf);
		delete str;
		delete mpTheScript;
		mpTheScript = NULL;
		return FALSE;
	}

	delete str;

	//everything succeeded.
	return TRUE;

}

/******************************************************************************
*   RunScript -- starts the script engine and executes it's instructions.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CScriptedFrame::RunScript()"
void CScriptedFrame::RunScript(IUnknown* apSystemContext)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::RunScript\n");
#endif
	ErrorObject localError;
	char errStr[MAX_BUFFER_SIZE];

	if (mpMTScriptHost)
		return;

	//Create an object for the script to interact with.
	if ((mpMTScriptHost = new CMTScriptHost()) == NULL)
	{
		localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);

		localError.GetProgrammerDetail() = "Error create MTScriptHost object";
		mLogger.LogErrorObject(LOG_ERROR, &localError);
		throw localError;
	}
	mpMTScriptHost->AddRef();

	///////////////////////////

	IMTSystemContextPtr MTSystemContext(apSystemContext);
	mpSystemContext = MTSystemContext;

	IMTLogPtr MTLog = MTSystemContext->GetLog();
	mpIMTLog = MTLog;

	IMTNameIDPtr idlookup(apSystemContext);
	mpNameID = idlookup;

	//////////////////////////

	//Add the name of the object that will respond to the script
	mEngine->AddNamedItem(L"MTPipeline", SCRIPTITEM_ISVISIBLE | 
																				SCRIPTITEM_ISSOURCE);

	mEngine->AddNamedItem(L"MTSystemContext", SCRIPTITEM_ISVISIBLE);

	mEngine->AddNamedItem(L"MTLog", SCRIPTITEM_ISVISIBLE);

	mEngine->AddNamedItem(L"MTNameID", SCRIPTITEM_ISVISIBLE);

	//Pass the script to be run to the script engine with a call to 
  //ParseScriptText
  HRESULT hr = mParser->ParseScriptText(mpTheScript, 
																				L"MTPipeline", 
																				NULL, 
																				NULL, 0, 0, 0L, 
																				NULL, NULL);
  if (FAILED(hr))
	{
#if MTDEBUG
		printf("Error calling ParseScriptText\n");
#endif

		QuitScript();

		if (hr == MTOLESCRIPT_E_SYNTAX)
		{
			localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);

			sprintf(errStr, "Scriptlet syntax error: HRESULT=%lx", hr);
			localError.GetProgrammerDetail() = errStr;

			mLogger.LogErrorObject(LOG_ERROR, &localError);
			throw localError;
		}
		else
		{
			localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);

			sprintf(errStr, "Scriptlet parser error: HRESULT=%lx", hr);
			localError.GetProgrammerDetail() = errStr;
			mLogger.LogErrorObject(LOG_ERROR, &localError);
			throw localError;
		}
	}

	//Tell the engine to start processing the script with a call to 
	//SetScriptState().
  hr = mEngine->SetScriptState(SCRIPTSTATE_CONNECTED);
  if (FAILED(hr))
	{
#if MTDEBUG
		printf("Error calling SetScriptState\n");
#endif

		QuitScript();
		localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);

		sprintf(errStr, "Error setting ScriotHost state: HRESULT=%lx", hr);
		localError.GetProgrammerDetail() = errStr;
		mLogger.LogErrorObject(LOG_ERROR, &localError);
		throw localError;
	}

}

/******************************************************************************
*	QuitScript -- Closes the script engine and cleans up.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CScriptedFrame::QuitScript()"
void CScriptedFrame::QuitScript()
{
#if MTDEBUG
		printf("CScriptedFrame::QuitScript()\n");
#endif
	ErrorObject localError;
	char errStr[MAX_BUFFER_SIZE];

	if (mEngine)
	{
		HRESULT hr = mEngine->Close();
		if (FAILED(hr))
		{
#if MTDEBUG
			printf("Error calling Close\n");
#endif
			localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);

			sprintf(errStr, "Error calling ScriptHost Engine Close: HRESULT=%lx", hr);
			localError.GetProgrammerDetail() = errStr;
			mLogger.LogErrorObject(LOG_ERROR, &localError);
			throw localError;
		}
	}

	// release MTScriptHost class when done
	if (mpMTScriptHost)
	{
		mpMTScriptHost->Release();
		mpMTScriptHost = NULL;
	}

	if (mEngine)
	{
		mEngine->Release();
		mEngine = NULL;
	}

	if (mParser)
	{
		mParser->Release();
		mParser = NULL;
	}

	// clean up the previous allocated memory
	if (mpTheScript != NULL)
	{
		delete mpTheScript;
		mpTheScript = NULL;
	}
}

/******************************************************************************
*   IUnknown Interfaces -- All COM objects must implement, either directly or 
*   indirectly, the IUnknown interface.
******************************************************************************/

/******************************************************************************
*   QueryInterface -- Determines if this component supports the requested 
*   interface, places a pointer to that interface in ppvObj if it's available,
*   and returns S_OK.  If not, sets ppvObj to NULL and returns E_NOINTERFACE.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CScriptedFrame::QueryInterface()"
STDMETHODIMP CScriptedFrame::QueryInterface(REFIID riid, void ** ppvObj)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::QueryInterface->");
#endif
	char logBuf[MAX_BUFFER_SIZE];

	if (riid == IID_IUnknown)
	{
#if MTDEBUG
		printf("IUnknown\n");
#endif
		*ppvObj = static_cast<IActiveScriptSite*>(this);
	}
	else if (riid == IID_IActiveScriptSite)
	{
#if MTDEBUG
		printf("IActiveScriptSite\n");
#endif
		*ppvObj = static_cast<IActiveScriptSite*>(this);
	}
	else if (riid == IID_IActiveScriptSiteWindow)
	{
#if MTDEBUG
		printf("IActiveScriptSiteWindow\n");
#endif
		*ppvObj = static_cast<IActiveScriptSiteWindow*>(this);
	}
	else
	{
#if MTDEBUG
		printf("Unsupported Interface  \n");
#endif
		*ppvObj = NULL;
		sprintf (logBuf, "Unsupported Interface: %s", PROCEDURE);
		mLogger.LogThis(LOG_DEBUG, logBuf);
		return E_NOINTERFACE;
	}

	static_cast<IUnknown*>(*ppvObj)->AddRef();
	
	return S_OK;
}


/******************************************************************************
*   AddRef() -- In order to allow an object to delete itself when it is no 
*   longer needed, it is necessary to maintain a count of all references to 
*   this object.  When a new reference is created, this function increments
*   the count.
******************************************************************************/
STDMETHODIMP_(ULONG) CScriptedFrame::AddRef()
{
#if MTDEBUG
	//tracing purposes only
	cout << "CScriptedFrame::AddRef: " << mRefCount+1 << endl;
#endif

	return ++mRefCount;
}

/******************************************************************************
*   Release() -- When a reference to this object is removed, this function 
*   decrements the reference count.  If the reference count is 0, then this 
*   function deletes this object and returns 0;
******************************************************************************/
STDMETHODIMP_(ULONG) CScriptedFrame::Release()
{
#if MTDEBUG
	//tracing purposes only
	cout << "CScriptedFrame::Release: " << mRefCount-1 << endl;

#endif

	if (--mRefCount == 0)
	{
		delete this;
		return 0;
	}

	return mRefCount;
}

/******************************************************************************
*   IActiveScriptSite Interfaces -- These interfaces define the exposed methods
*   of ActiveX Script Hosts.
******************************************************************************/

/******************************************************************************
*   GetLCID() -- Gets the identifier of the host's user interface.  This method 
*   returns S_OK if the identifier was placed in plcid, E_NOTIMPL if this 
*   function is not implemented, in which case the system-defined identifier
*   should be used, and E_POINTER if the specified pointer was invalid.
******************************************************************************/
STDMETHODIMP CScriptedFrame::GetLCID( LCID *plcid )
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::GetLCID\n");
#endif

	return E_NOTIMPL;
}

/******************************************************************************
*   GetItemInfo() -- Retrieves information about an item that was added to the 
*   script engine through a call to AddNamedItem.
*   Parameters:   pstrName -- the name of the item, specified in AddNamedItem.
*            dwReturnMask -- Mask indicating what kind of pointer to return
*               SCRIPTINFO_IUNKNOWN or SCRIPTINFO_ITYPEINFO
*            ppunkItem -- return spot for an IUnknown pointer
*            ppTypeInfo -- return spot for an ITypeInfo pointer
*   Returns:   S_OK if the call was successful
*            E_INVALIDARG if one of the arguments was invalid
*            E_POINTER if one of the pointers was invalid
*            TYPE_E_ELEMENTNOTFOUND if there wasn't an item of the 
*               specified type.
******************************************************************************/
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CScriptedFrame::GetItemInfo"
STDMETHODIMP CScriptedFrame::GetItemInfo(LPCOLESTR pstrName, 
																				 DWORD dwReturnMask,
																				 IUnknown **ppunkItem, 
																				 ITypeInfo **ppTypeInfo)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::GetItemInfo\n");
#endif

	//Use logical ANDs to determine which type(s) of pointer the caller wants, 
	//and make sure that that placeholder is currently valid.
	if (dwReturnMask & SCRIPTINFO_IUNKNOWN)
	{
		if (!ppunkItem)
			return E_INVALIDARG;
    *ppunkItem = NULL;
  }

	if (dwReturnMask & SCRIPTINFO_ITYPEINFO)
	{
		if (!ppTypeInfo)
			return E_INVALIDARG;
    *ppTypeInfo = NULL;
  }

  /****** Do tests for named items here.  *******/
  if (!_wcsicmp(L"MTPipeline", pstrName))
	{
		if (dwReturnMask & SCRIPTINFO_IUNKNOWN)
		{
			mpMTScriptHost->QueryInterface(IID_IUnknown, (void**)ppunkItem);
      return S_OK;
    }
    else if (dwReturnMask & SCRIPTINFO_ITYPEINFO)
		{
			return mpMTScriptHost->LoadTypeInfo(ppTypeInfo, CLSID_MTScriptHost, 0);
    }
	}

  /****** Do tests for named items here.  *******/
  if (!_wcsicmp(L"MTSystemContext", pstrName))
	{
		if (dwReturnMask & SCRIPTINFO_IUNKNOWN)
		{
			mpSystemContext->QueryInterface(IID_IUnknown, (void**)ppunkItem);
      return S_OK;
    }
    else if (dwReturnMask & SCRIPTINFO_ITYPEINFO)
		{
			return mpSystemContext->GetTypeInfo(0, 0x0, ppTypeInfo);
    }
	}

 /****** Do tests for named items here.  *******/
  if (!_wcsicmp(L"MTLog", pstrName))
	{
		if (dwReturnMask & SCRIPTINFO_IUNKNOWN)
		{
			HRESULT hr = mpIMTLog->QueryInterface(IID_IUnknown, (void**)ppunkItem);
      return S_OK;
    }
    else if (dwReturnMask & SCRIPTINFO_ITYPEINFO)
		{
			return mpIMTLog->GetTypeInfo(0, 0x0, ppTypeInfo);
    }
	}

 /****** Do tests for named items here.  *******/
  if (!_wcsicmp(L"MTNameID", pstrName))
	{
		if (dwReturnMask & SCRIPTINFO_IUNKNOWN)
		{
			HRESULT hr = mpNameID->QueryInterface(IID_IUnknown, (void**)ppunkItem);
      return S_OK;
    }
    else if (dwReturnMask & SCRIPTINFO_ITYPEINFO)
		{
			return mpNameID->GetTypeInfo(0, 0x0, ppTypeInfo);
    }
	}

	return TYPE_E_ELEMENTNOTFOUND;
}

/******************************************************************************
*   GetDocVersionString() -- It is possible, even likely that a script document
*   can be changed between runs.  The host can define a unique version number 
*   for the script, which can be saved along with the script.  If the version 
*   changes, the engine will know to recompile the script on the next run.
******************************************************************************/
STDMETHODIMP CScriptedFrame::GetDocVersionString(BSTR *pbstrVersionString)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::GetDocVersionString\n");
#endif

	//For the generic case, this function isn't implemented.
	return E_NOTIMPL;
}

/******************************************************************************
*   OnScriptTerminate() -- This method may give the host a chance to react when
*   the script terminates.  pvarResult give the result of the script or NULL
*   if the script doesn't give a result, and pexcepinfo gives the location of
*   any exceptions raised by the script.  Returns S_OK if the calls succeeds.
******************************************************************************/
STDMETHODIMP CScriptedFrame::OnScriptTerminate(const VARIANT *pvarResult, 
																							const EXCEPINFO *pexcepinfo)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::OnScriptTerminate\n");
#endif

	//If something needs to happen when the script terminates, put it here.
	return S_OK;
}

/******************************************************************************
*   OnStateChange() -- This function gives the host a chance to react when the
*   state of the script engine changes.  ssScriptState lets the host know the
*   new state of the machine.  Returns S_OK if successful.
******************************************************************************/
STDMETHODIMP CScriptedFrame::OnStateChange( SCRIPTSTATE ssScriptState)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::OnStateChange\n");
#endif

	//If something needs to happen when the script enters a certain state, 
	//put it here.
	switch (ssScriptState)
	{
	case SCRIPTSTATE_UNINITIALIZED:
#if MTDEBUG
		printf("State: Uninitialized.\n");
#endif
		break;

	case SCRIPTSTATE_INITIALIZED:
#if MTDEBUG
		printf("State: Initialized.\n");
#endif
		break;

	case SCRIPTSTATE_STARTED:
#if MTDEBUG
		printf("State: Started.\n");
#endif
		break;

	case SCRIPTSTATE_CONNECTED:
#if MTDEBUG
		printf("State: Connected.\n");
#endif
		break;

	case SCRIPTSTATE_DISCONNECTED:
#if MTDEBUG
		printf("State: Disconnected.\n");
#endif
		break;

	case SCRIPTSTATE_CLOSED:
#if MTDEBUG
		printf("State: Closed.\n");
#endif
		break;

	default:
#if MTDEBUG
		printf("State: unknown.\n");
#endif
		break;
	}

	return S_OK;
}

/******************************************************************************
*   OnScriptError() -- This function gives the host a chance to respond when 
*   an error occurs while running a script.  pase holds a reference to the 
*   IActiveScriptError object, which the host can use to get information about
*   the error.  Returns S_OK if the error was handled successfully, and an OLE
*   error code if not.
******************************************************************************/
STDMETHODIMP CScriptedFrame::OnScriptError(IActiveScriptError *pase)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::OnScriptError\n");
#endif

	char		errStr[256];
	BSTR		errBstr;
	DWORD		context;
	ULONG		lineNo;
	LONG		pos;
	HRESULT hr;

	USES_CONVERSION;

	EXCEPINFO theException;

	hr = pase->GetExceptionInfo(&theException);
	if (SUCCEEDED(hr))
	{
		if (theException.bstrDescription != NULL)
		{
#if MTDEBUG
			_bstr_t desc(theException.bstrDescription);
			cout << "Script Error" << desc << endl;
#endif
			sprintf(errStr, "Script Error: %s", OLE2A(theException.bstrDescription));
			mErrorMsg = errStr;
			SysFreeString(theException.bstrDescription);
		}

		SysFreeString(theException.bstrSource);
		
		SysFreeString(theException.bstrHelpFile);
	}

	sprintf(errStr, ": %X ", theException.scode);
	mErrorMsg += errStr;

	hr = pase->GetSourcePosition(&context, &lineNo, &pos);
	if (SUCCEEDED(hr))
	{
		// adjust one
		lineNo++;
		sprintf(errStr, "(line: %d position: %d)", lineNo, pos);
#if MTDEBUG
		printf("Script Error: %s\n", errStr);
#endif
		mErrorMsg += errStr;
	}

	hr = pase->GetSourceLineText(&errBstr);
	if (SUCCEEDED(hr))
	{
#if MTDEBUG
		ShowBSTR("Script Error at line", errBstr);
#endif
		sprintf(errStr, " SOURCE: '%s'", errBstr);
		mErrorMsg += errStr;
	}

	SysFreeString(errBstr);

	mLogger.LogVarArgs(LOG_ERROR, "%s", mErrorMsg.c_str());

	return S_OK;
}

/******************************************************************************
*   OnEnterScript() -- This function gives the host a chance to respond when
*   the script begins running.  Returns S_OK if the call was successful.
******************************************************************************/
STDMETHODIMP CScriptedFrame::OnEnterScript(void)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::OnEnterScript\n");
#endif

	return S_OK;
}

/******************************************************************************
*   OnExitScript() -- This function gives the host a chance to respond when
*   the script finishes running.  Returns S_OK if the call was successful.
******************************************************************************/
STDMETHODIMP CScriptedFrame::OnLeaveScript(void)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::OnLeaveScript\n");
#endif

	return S_OK;
}

/******************************************************************************
*   IActiveScriptSiteWindow -- This interface allows the script engine to 
*   manipulate the user interface, if it's located in the same object as the 
*   IActiveScriptSite.
******************************************************************************/

/******************************************************************************
*   GetWindow() -- This function returns a handle to a window that the script
*   engine can use to display information to the user.  Returns S_OK if the 
*   call was successful, and E_FAIL if there was an error.
******************************************************************************/
STDMETHODIMP CScriptedFrame::GetWindow(HWND *phwnd)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::GetWindow\n");
#endif

	//If there is a window that the script engine can use, pass it back.
	//Otherwise, this function should be removed.
	return E_FAIL;
}

/******************************************************************************
*   EnableModeless() -- This function instructs the host to enable or disable
*   it's main window and any modeless dialog boxes it may have.  Returns S_OK
*   if successful, and E_FAIL if not.
******************************************************************************/
STDMETHODIMP CScriptedFrame::EnableModeless(BOOL fEnable)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::EnableModeless\n");
#endif

	//Do any enabling or disabling required.
	return E_FAIL;
}

/******************************************************************************
*   OnFireEvent() -- This function calls the OnFireEvent method of m_Object and 
*   then cleans up the script engine, in preparation for closing the 
*   application.
******************************************************************************/
void CScriptedFrame::OnFireEvent()
{
   mpMTScriptHost->OnFireEvent();
}

HRESULT CScriptedFrame::Configure(IMTConfigPropSetPtr apPropSet)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::Configure\n");
#endif
   return mpMTScriptHost->Configure(apPropSet);
}

HRESULT CScriptedFrame::ProcessSession(IMTSessionPtr apSession)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::ProcessSession\n");
#endif
   return mpMTScriptHost->ProcessSession(apSession);
}

HRESULT CScriptedFrame::ProcessSessionSet(IMTSessionSetPtr apSessionSet)
{
#if MTDEBUG
	//tracing purposes only
	printf("CScriptedFrame::ProcessSessionSet\n");
#endif

   return mpMTScriptHost->ProcessSessionSet(apSessionSet);
}

///////////////////////////////////////////////////////////////////////////////
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CScriptedFrame::ReloadScript"
BOOL CScriptedFrame::ReloadScript(string& aScriptFileName)
{
	long	fileSize;
	char*	str;
	char logBuf[MAX_BUFFER_SIZE];


	if ((fileSize = FileSize(aScriptFileName)) == -1)
	{
#if MTDEBUG
		cout << "Error getting script file size: " << aScriptFileName << endl;
#endif
		sprintf (logBuf, "Error getting script file size(filename=%s): %s", 
						aScriptFileName.c_str(),
						PROCEDURE);

		mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}
#if MTDEBUG
	cout << "Script file size: " << fileSize << endl;
#endif

	//Open and read the file of the script to be run
	//ifstream scriptStream("MyScript.txt", ios::binary | ios::in);
	ifstream scriptStream(aScriptFileName.c_str(), ios::binary | ios::in);

	if (!scriptStream)
	{
#if MTDEBUG
	cout << "Error opening script file." << endl;
#endif
		sprintf (logBuf, "Error openning script file(filename=%s): %s", 
						aScriptFileName.c_str(),
						PROCEDURE);

		mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}

	// b) Allocate buffer
	if ((str = new char[fileSize + 1]) == NULL)
	{
#if MTDEBUG
	cout << "Error allocate temp buffer." << endl;
#endif
		sprintf (logBuf, "Error allocate internal buffer: %s", 
						PROCEDURE);

		mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}

	if (mpTheScript != NULL)
	{
		delete mpTheScript;
		mpTheScript = NULL;
	}

	if ((mpTheScript = new WCHAR[fileSize + 1]) == NULL)
	{
#if MTDEBUG
	cout << "Error alllocate script file buffer." << endl;
#endif
		sprintf (logBuf, "Error allocate script buffer: %s", 
						PROCEDURE);

		mLogger.LogThis(LOG_ERROR, logBuf);
		delete str;
		return FALSE;
	}

	memset(str, 0, fileSize+1);
	memset(mpTheScript, 0, (sizeof(WCHAR) * fileSize) + 1);

	// c) Load the data
  scriptStream.read(str, fileSize);

	scriptStream.close();

	if (!MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, str, -1, mpTheScript, 
													fileSize))
	{
#if MTDEBUG
	cout << "Error translating string." << endl;
#endif
		sprintf (logBuf, "Error translating script code string: %s", 
						PROCEDURE);

		mLogger.LogThis(LOG_ERROR, logBuf);
		delete str;
		delete mpTheScript;
		mpTheScript = NULL;
	  return FALSE;
  }

	delete str;

	return TRUE;
}


///////////////////////////////////////////////////////////////////////////////////
int CScriptedFrame::FileSize(string& aFileName)
{
	int	fh;
	int size;

	// Get file size
	if ((fh = _open(aFileName.c_str(), _O_RDONLY)) == -1)
	{
#if MTDEBUG
		cout << "Error opening script file: " << aFileName.c_str() << endl;
#endif
		return -1;
	}

	size = _filelength(fh);

#if MTDEBUG
	cout << "Script file size: " << size << endl;
#endif

	_close(fh);

	return size;
}
