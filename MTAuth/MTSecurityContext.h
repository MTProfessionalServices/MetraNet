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
	
// MTSecurityContext.h : Declaration of the CMTSecurityContext

#ifndef __MTSECURITYCONTEXT_H_
#define __MTSECURITYCONTEXT_H_

#include "resource.h"       // main symbols


using namespace std;

typedef set<_bstr_t> RoleNameSet;
typedef map<long, MTAUTHLib::IMTCompositeCapabilityPtr> Capabilities;
typedef map<long, MTAUTHLib::IMTCompositeCapabilityPtr>::iterator CapIterator;

/////////////////////////////////////////////////////////////////////////////
// CMTSecurityContext
class ATL_NO_VTABLE CMTSecurityContext : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSecurityContext, &CLSID_MTSecurityContext>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSecurityContext, &IID_IMTSecurityContext, &LIBID_MTAUTHLib>
{
public:
	CMTSecurityContext()
	{
		m_pUnkMarshaler = NULL;
    mAccountID = -1;
	}

	
DECLARE_REGISTRY_RESOURCEID(IDR_MTSECURITYCONTEXT)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTSecurityContext)
 	COM_INTERFACE_ENTRY(IMTSecurityContext)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		mPolicy = NULL;
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

// IMTSecurityContext
public:
	STDMETHOD(GetCapabilitiesOfType)(/*[in]*/BSTR aTypeName, /*[out, retval]*/IMTCollection** apColl);
	STDMETHOD(IsSuperUser)(/*[out, retval]*/VARIANT_BOOL* apRes);
	STDMETHOD(FromXML)(/*[in]*/BSTR aXMLString);
	STDMETHOD(ToXML)(/*[out, retval]*/BSTR* apXMLString);
	STDMETHOD(IsInRole)(/*[in]*/BSTR aRoleName, /*[out, retval]*/VARIANT_BOOL* apResult);
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
	STDMETHOD(CoarseHasAccess)(/*[in]*/IMTCompositeCapability* aCap, /*[out, retval]*/VARIANT_BOOL* apHasAccess);
  STDMETHOD(HasAccess)(/*[in]*/IMTCompositeCapability* aCap, /*[out, retval]*/VARIANT_BOOL* apHasAccess);
	STDMETHOD(Init)(BSTR aName, BSTR aNameSpace);
	STDMETHOD(CheckAccess)(/*[in]*/IMTCompositeCapability* aCap);
	STDMETHOD(get_LoggedInAs)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LoggedInAs)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ApplicationName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ApplicationName)(/*[in]*/ BSTR newVal);

private:
	MTAUTHLib::IMTPrincipalPolicyPtr mPolicy;
	RoleNameSet mRoleNames;
	Capabilities mCapabilities;
	long mAccountID;
	_bstr_t mLoggedInAs;
	_bstr_t mApplicationName;
};

#endif //__MTSECURITYCONTEXT_H_
