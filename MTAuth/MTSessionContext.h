/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#ifndef __MTSESSIONCONTEXT_H_
#define __MTSESSIONCONTEXT_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTSessionContext
class ATL_NO_VTABLE CMTSessionContext : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSessionContext, &CLSID_MTSessionContext>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSessionContext, &IID_IMTSessionContext, &LIBID_MTAUTHLib>
{
public:
	CMTSessionContext()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSESSIONCONTEXT)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTSessionContext)
	COM_INTERFACE_ENTRY(IMTSessionContext)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		mAccountID = -1;
		// this is the language ID for US English
		mLanguageID = 840;

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

// IMTSessionContext
public:
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
	STDMETHOD(get_SecurityContext)(/*[out, retval]*/ IMTSecurityContext** pVal);
	STDMETHOD(put_SecurityContext)(/*[in]*/ IMTSecurityContext* newVal);
	STDMETHOD(get_LanguageID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_LanguageID)(/*[in]*/ long newVal);
	STDMETHOD(FromXML)(/*[in]*/BSTR aXMLString);
	STDMETHOD(ToXML)(/*[out, retval]*/BSTR* apXMLString);
	STDMETHOD(get_LoggedInAs)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LoggedInAs)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ApplicationName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ApplicationName)(/*[in]*/ BSTR newVal);
private:
	MTAUTHLib::IMTSecurityContextPtr mSecurityContext;
	long mAccountID;
	long mLanguageID;
	_bstr_t mLoggedInAs;
	_bstr_t mApplicationName;
};

#endif //__MTSESSIONCONTEXT_H_
