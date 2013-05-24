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

#ifndef __MTROLE_H_
#define __MTROLE_H_

#include "resource.h"       // main symbols
#include "MTSecurityPrincipalImpl.h"



/////////////////////////////////////////////////////////////////////////////
// CMTRole
class ATL_NO_VTABLE CMTRole : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRole, &CLSID_MTRole>,
	public ISupportErrorInfo,
	public MTSecurityPrincipalImpl<IMTRole, &IID_IMTRole, &LIBID_MTAUTHLib>
{
public:
	CMTRole()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTROLE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTRole)
	COM_INTERFACE_ENTRY(IMTRole)
	COM_INTERFACE_ENTRY(IMTSecurityPrincipal)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
  COM_INTERFACE_ENTRY_FUNC(IID_NULL,0,_This)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		//		CMTSecurityPrincipalImpl::put_PrincipalType(ROLE_PRINCIPAL); 	
		MTSecurityPrincipalImpl<IMTRole, &IID_IMTRole, &LIBID_MTAUTHLib>::put_PrincipalType(ROLE_PRINCIPAL);
		mCSRAssignable = VARIANT_TRUE;
		mSubscriberAssignable = VARIANT_TRUE;
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

// IMTRole
public:
	STDMETHOD(GetMembersAsRowset)(/*[in]*/IMTSessionContext* aCtx,MTPrincipalPolicyType aPolicyType, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(HasMembers)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/VARIANT_BOOL* apRes);
	STDMETHOD(get_GUID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_GUID)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_SubscriberAssignable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_SubscriberAssignable)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_CSRAssignable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_CSRAssignable)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(Save)();
  STDMETHOD(FromXML)(IMTSessionContext* aCtx, BSTR aXmlString);
  STDMETHOD(ToXML)(BSTR* apXmlString);
  STDMETHOD(AddMember)(IMTSessionContext* aCtx, long aNewMember);
  STDMETHOD(RemoveMember)(IMTSessionContext* aCtx, long aMember);
  STDMETHOD(AddMemberBatch)
    (IMTSessionContext* aCtx, IMTCollection* apMembers, IMTProgress* aProgress, IMTRowSet** apResultRs);
  STDMETHOD(SaveBase)();

private:
	_bstr_t mName;
	_bstr_t mDesc;
	_bstr_t mGUID;
	VARIANT_BOOL mCSRAssignable;
	VARIANT_BOOL mSubscriberAssignable;
};


#endif //__MTROLE_H_

