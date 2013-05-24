/**************************************************************************
 * ProgressServer.cpp : Implementation of CProgressServer
 * 
 * CProgressServer kicks off a thread with the start method and provides
 * feedback to a web page by talking to the scripting context directly
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin A. Boucher
 * $Source: ProgressServer.cpp
 *
 ***************************************************************************/
#include "StdAfx.h"
#include "Progress.h"
#include "ProgressServer.h"
#import "Progress.tlb"

BOOL CProgressServer::bDone = FALSE;
NTThreadLock CProgressServer::mLock;
HANDLE CProgressServer::mhDoneEvent;
_bstr_t CProgressServer::mbstrProgressKey(".");  // default progress is '.'
long CProgressServer::mnDelay = 1000;            // default delay is 1 second

/////////////////////////////////////////////////////////////////////////////
// ProgressThread - reports progress string to web page every n milliseconds
//                  exits upon CProgressServer destructor or Stop() event
/////////////////////////////////////////////////////////////////////////////
static void ProgressThread(LPVOID p)
{
	CProgressServer *pProgressServer = (CProgressServer*)p;

	try {
	
		 // wait for mnDelay miliseconds and print progress or if we are done reset event and exit thread
   	while (1)
		{
			{
				AutoCriticalSection aLock(&CProgressServer::mLock);
				if(!CProgressServer::bDone) {
					pProgressServer->WriteResponse(CProgressServer::mbstrProgressKey );
				}
				else {
					ResetEvent(CProgressServer::mhDoneEvent);
					return;
				}
				if(WaitForSingleObject(CProgressServer::mhDoneEvent, CProgressServer::mnDelay) != WAIT_TIMEOUT)
				{
					ResetEvent(CProgressServer::mhDoneEvent);
					return;
				}
			}
	
		}

	}
  catch(_com_error e) {
		// handle error - exit thread
		ResetEvent(CProgressServer::mhDoneEvent);
		return;
	}	
	
}

/////////////////////////////////////////////////////////////////////////////
// CProgressServer

STDMETHODIMP CProgressServer::OnStartPage (IUnknown* pUnk)  
{
	if(!pUnk)
		return E_POINTER;

	CComPtr<IScriptingContext> spContext;
	HRESULT hr;

	// Get the IScriptingContext Interface
	hr = pUnk->QueryInterface(IID_IScriptingContext, (void **)&spContext);
	if(FAILED(hr))
		return hr;

	// Get Request Object Pointer
	hr = spContext->get_Request(&m_piRequest);
	if(FAILED(hr))
	{
		spContext.Release();
		return hr;
	}

	// Get Response Object Pointer
	hr = spContext->get_Response(&m_piResponse);
	if(FAILED(hr))
	{
		m_piRequest.Release();
		return hr;
	}
	
	// Get Server Object Pointer
	hr = spContext->get_Server(&m_piServer);
	if(FAILED(hr))
	{
		m_piRequest.Release();
		m_piResponse.Release();
		return hr;
	}
	
	// Get Session Object Pointer
	hr = spContext->get_Session(&m_piSession);
	if(FAILED(hr))
	{
		m_piRequest.Release();
		m_piResponse.Release();
		m_piServer.Release();
		return hr;
	}

	// Get Application Object Pointer
	hr = spContext->get_Application(&m_piApplication);
	if(FAILED(hr))
	{
		m_piRequest.Release();
		m_piResponse.Release();
		m_piServer.Release();
		m_piSession.Release();
		return hr;
	}
	m_bOnStartPageCalled = TRUE;
	return S_OK;
}

STDMETHODIMP CProgressServer::OnEndPage ()  
{
	m_bOnStartPageCalled = FALSE;
	// Release all interfaces
	m_piRequest.Release();
	m_piResponse.Release();
	m_piServer.Release();
	m_piSession.Release();
	m_piApplication.Release();

	return S_OK;
}

///////////////////////////////////////////////////////////////////////////////
// Start - signals the ProgressThread to start and creates the done event
///////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CProgressServer::Start()
{
  // create done event to exit as soon as Stop is called
	CProgressServer::mhDoneEvent = CreateEvent(NULL, TRUE, FALSE, L"HoldOn");

	// create progress thread
	::CreateThread( 
		NULL,                                    // security attributes
		NULL,                                    // stack size
		(LPTHREAD_START_ROUTINE) ProgressThread, // thread entry
		this,                                    // argument - pass in CProgressServer
		NULL,                                    // creation flags
		&m_dwThreadID                            // thread ID
		);

	return S_OK;
}


///////////////////////////////////////////////////////////////////////////////
// Stop - signals a stop event telling the ProgressThread to exit
///////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CProgressServer::Stop()
{
	AutoCriticalSection aLock(&CProgressServer::mLock);
	CProgressServer::bDone = TRUE;
	SetEvent(CProgressServer::mhDoneEvent);

	return S_OK;
}

///////////////////////////////////////////////////////////////////////////////
// GetProgress - returns the current progress string
///////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CProgressServer::GetProgress(BSTR *pbstrProgress)
{
	AutoCriticalSection aLock(&CProgressServer::mLock);
	*pbstrProgress = CProgressServer::mbstrProgressKey.copy();

	return S_OK;
}

///////////////////////////////////////////////////////////////////////////////
// SetProgress - Sets the current progress string
///////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CProgressServer::SetProgress(BSTR bstrProgress)
{
	AutoCriticalSection aLock(&CProgressServer::mLock);
	CProgressServer::mbstrProgressKey = bstrProgress;

	return S_OK;
}

///////////////////////////////////////////////////////////////////////////////
// WriteResponse - sends the incoming string to the web page
///////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CProgressServer::WriteResponse(BSTR str)
{
	_bstr_t bstr = str;
	_variant_t vstr = _variant_t(bstr);

	if(m_piResponse)
	{
		m_piResponse->Write(vstr);
		return S_OK;
	}
	return E_FAIL;

	
}

///////////////////////////////////////////////////////////////////////////////
// get_Delay - Gets the delay in milliseconds between progress string output
///////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CProgressServer::get_Delay(long *pVal)
{
	AutoCriticalSection aLock(&CProgressServer::mLock);
	*pVal = CProgressServer::mnDelay;
	return S_OK;
}

///////////////////////////////////////////////////////////////////////////////
// put_Delay - Sets the delay in milliseconds between progress string output
///////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CProgressServer::put_Delay(long newVal)
{
	AutoCriticalSection aLock(&CProgressServer::mLock);
	CProgressServer::mnDelay = newVal;
	return S_OK;
}
