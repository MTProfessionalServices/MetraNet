/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Boris Partensky
* 
***************************************************************************/
	
// MTLoginContext.h : Declaration of the CMTLoginContext

#ifndef __MTLOGINCONTEXT_H_
#define __MTLOGINCONTEXT_H_

#include "resource.h"       // main symbols



/////////////////////////////////////////////////////////////////////////////
// CMTLoginContext
class ATL_NO_VTABLE CMTLoginContext : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTLoginContext, &CLSID_MTLoginContext>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTLoginContext, &IID_IMTLoginContext, &LIBID_MTAUTHLib>
{
public:
	CMTLoginContext()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_CLASSFACTORY_EX(CMTSingletonFactory<CMTLoginContext>)
DECLARE_REGISTRY_RESOURCEID(IDR_MTLOGINCONTEXT)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTLoginContext)
	COM_INTERFACE_ENTRY(IMTLoginContext)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTLoginContext
public:
	STDMETHOD(LoginWithTicket)(/*[in]*/BSTR aNameSpace, /*[in]*/BSTR aTicket, /*[out, retval]*/IMTSessionContext** apCtx);
	STDMETHOD(Login)(/*[in]*/BSTR aAlias, /*[in]*/BSTR aNamespace, /*[in]*/BSTR aPassword, /*[out, retval]*/IMTSessionContext** aCtx);
	STDMETHOD(LoginAnonymous)(/*[out, retval]*/IMTSessionContext** aCtx);
	STDMETHOD(LoginAsAccount)(/*[in]*/ IMTSessionContext * apCurrentContext, /*[in]*/ int aAccountID,
														/*[out, retval]*/IMTSessionContext** apCtx);
	STDMETHOD(LoginAsAccountByName)(/*[in]*/ IMTSessionContext * apCurrentContext, /*[in]*/ BSTR aNamespace, /*[in]*/ BSTR aUserName,
														/*[out, retval]*/IMTSessionContext** apCtx);

	STDMETHOD(LoginAsMPSAccount)(/*[in]*/ IMTSessionContext * apCurrentContext, /*[in]*/ BSTR aNamespace, BSTR aUserName,
														/*[out, retval]*/IMTSessionContext** apCtx);

	STDMETHOD(LoginWithAdditionalData)(/*[in]*/BSTR aAlias, /*[in]*/BSTR aNamespace,/*[in]*/ BSTR aPassword,/*[in]*/ BSTR aLoggedInAs, 
										/*[in]*/BSTR aApplicationName,/*[out, retval]*/ IMTSessionContext **aCtx);

	STDMETHOD(LoginAsMPSAccountWithAdditionalData)(/*[in]*/IMTSessionContext * apCurrentContext, /*[in]*/BSTR aNamespace, /*[in]*/BSTR aUserName, 
													/*[in]*/BSTR aLoggedInAs, /*[in]*/BSTR aApplicationName,/*[out, retval]*/  IMTSessionContext** apCtx);

private:
	MTAUTHLib::IMTSessionContextPtr mAnonymousContext;
  MTAUTHLib::IMTSessionContextPtr CreateSessionContext();
  MTAUTHLib::IMTSecurityContextPtr CreateSecurityContext();
  MTAUTHLib::IMTSessionContextPtr CreateAndInitSessionContext(BSTR aName, BSTR aNameSpace);
  MTAUTHLib::IMTSessionContextPtr CreateAndInitSessionContext(BSTR aName, BSTR aNameSpace, IMTSessionContext * apCurrentContext);
	MTAUTHLib::IMTSessionContextPtr CreateAndInitSessionContextWithAdditionalData(BSTR aName, BSTR aNameSpace,BSTR aLoggedInAs, BSTR aApplicationName);
};

#endif //__MTLOGINCONTEXT_H_
