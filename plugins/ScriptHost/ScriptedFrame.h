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
 * $Header$
 *
 *****************************************************************************/

#include "activscp.h"
#include "MTScriptHost.h"
#include "ScriptHostInclude.h"
#include "errobj.h"


class CScriptedFrame :	public IActiveScriptSite,
												public IActiveScriptSiteWindow
{
protected:
	int									mRefCount;			//variable to maintain the reference count
	IActiveScript*			mEngine;				//reference to the scripting engine
	IActiveScriptParse* mParser;				//reference to scripting engine in parsing 
																			//mode.
	CLSID								mEngineClsid;	//The CLSID of the script engine we want 
																			//to use.
	CMTScriptHost*											mpMTScriptHost;

	MTPipelineLib::IMTSystemContextPtr	mpSystemContext;
	
	MTPipelineLib::IMTNameIDPtr					mpNameID;

	MTPipelineLib::IMTLogPtr						mpIMTLog;

	WCHAR*															mpTheScript;		//The script that is being run.

public:
	//Constructor
	CScriptedFrame();
	CScriptedFrame(wstring& aScriptType);

	//Destructor
	~CScriptedFrame();

	BOOL InitializeScriptFrame(string& aScriptFileName);
	void RunScript(IUnknown* systemContext);
	void QuitScript();
	void OnFireEvent();
	HRESULT Configure(MTPipelineLib::IMTConfigPropSetPtr apPropSet);
  HRESULT ProcessSession(MTPipelineLib::IMTSessionPtr apSession);
  HRESULT ProcessSessionSet(MTPipelineLib::IMTSessionSetPtr apSessionSet);
  BOOL ReloadScript(string& aScriptFileName);

  // IUnknown
  STDMETHODIMP QueryInterface(REFIID riid, void * * ppvObj);
  STDMETHODIMP_(ULONG) AddRef();
  STDMETHODIMP_(ULONG) Release();

  // IActiveScriptSite
  STDMETHODIMP GetLCID( LCID *plcid );  // address of variable for 
																				//language identifier
  STDMETHODIMP GetItemInfo(LPCOLESTR pstrName, // address of item name
											DWORD dwReturnMask,			// bit mask for information retrieval
											IUnknown **ppunkItem,		// address of pointer to item's IUnknown
											ITypeInfo **ppTypeInfo);// address of pointer to item's ITypeInfo

  STDMETHODIMP GetDocVersionString(
									    BSTR *pbstrVersionString);  // address of document version string

  STDMETHODIMP OnScriptTerminate(
											const VARIANT *pvarResult,		// address of script results
											const EXCEPINFO *pexcepinfo); // address of structure with exception 
																										// information
  STDMETHODIMP OnStateChange(
											SCRIPTSTATE ssScriptState);   // new state of engine

	STDMETHODIMP OnScriptError(
											IActiveScriptError *pase);    // address of error interface

  STDMETHODIMP OnEnterScript(void);

  STDMETHODIMP OnLeaveScript(void);

  /******* IActiveScriptSiteWindow *******/
  STDMETHODIMP GetWindow(HWND *phwnd);

  STDMETHODIMP EnableModeless(BOOL fEnable);				// enable flag

	const string& GetErrorMsg()
	{
		return mErrorMsg;
	}

private:
	int FileSize(string& aFileName);

	wstring mScriptType;

	string mErrorMsg;

	NTLogger	mLogger;
};

