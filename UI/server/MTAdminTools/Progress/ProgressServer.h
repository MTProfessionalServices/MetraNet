/**************************************************************************
 * ProgressServer.h : Declaration of the CProgressServer
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
 * $Header: ProgressServer.h
 *
 ***************************************************************************/
#ifndef __PROGRESSSERVER_H_
#define __PROGRESSSERVER_H_

#include "resource.h"       // main symbols
#include <asptlb.h>         // Active Server Pages Definitions
#include <autocritical.h>
#include <comdef.h>

/////////////////////////////////////////////////////////////////////////////
// CProgressServer
class ATL_NO_VTABLE CProgressServer : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CProgressServer, &CLSID_ProgressServer>,
	public IDispatchImpl<IProgressServer, &IID_IProgressServer, &LIBID_PROGRESSLib>

	/*
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CDummy, &CLSID_Dummy>,
	public IDispatchImpl<IDummy, &IID_IDummy, &LIBID_PROGRESSLib>
{
		
			*/
{
public:
	CProgressServer()
	{
		bDone = FALSE;
		m_bOnStartPageCalled = FALSE;
		mbstrProgressKey = ".";
		mnDelay = 1000; // 1 second for default
	}

DECLARE_REGISTRY_RESOURCEID(IDR_PROGRESSSERVER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CProgressServer)
	COM_INTERFACE_ENTRY(IProgressServer)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()


	HRESULT FinalConstruct()
	{
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		AutoCriticalSection aLock(&mLock);
		bDone = TRUE;
		m_pUnkMarshaler.Release();
	}


	CComPtr<IUnknown> m_pUnkMarshaler;

// IProgressServer
public:
	STDMETHOD(get_Delay)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Delay)(/*[in]*/ long newVal);
	STDMETHOD(WriteResponse)(BSTR);
	STDMETHOD(SetProgress)(BSTR bstrProgress);
	STDMETHOD(GetProgress)(/*[out, retval]*/BSTR* pbstrProgress);
	STDMETHOD(Stop)();
	STDMETHOD(Start)();
	//Active Server Pages Methods
	STDMETHOD(OnStartPage)(IUnknown* IUnk);
	STDMETHOD(OnEndPage)();

	static BOOL bDone;
	static NTThreadLock mLock;
  static HANDLE mhDoneEvent;
	static _bstr_t mbstrProgressKey;
	static long mnDelay;

private:
	CComPtr<IRequest> m_piRequest;					//Request Object
	CComPtr<IResponse> m_piResponse;				//Response Object
	CComPtr<ISessionObject> m_piSession;			//Session Object
	CComPtr<IServer> m_piServer;					//Server Object
	CComPtr<IApplicationObject> m_piApplication;	//Application Object
	BOOL m_bOnStartPageCalled;						//OnStartPage successful?
	DWORD m_dwThreadID;


	
};

#endif //__PROGRESSSERVER_H_
