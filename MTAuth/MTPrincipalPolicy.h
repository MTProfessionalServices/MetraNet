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

#ifndef __MTPRINCIPALPOLICY_H_
#define __MTPRINCIPALPOLICY_H_

#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTPrincipalPolicy
class ATL_NO_VTABLE CMTPrincipalPolicy : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPrincipalPolicy, &CLSID_MTPrincipalPolicy>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPrincipalPolicy, &IID_IMTPrincipalPolicy, &LIBID_MTAUTHLib>
{
public:
	CMTPrincipalPolicy()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRINCIPALPOLICY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPrincipalPolicy)
	COM_INTERFACE_ENTRY(IMTPrincipalPolicy)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
  COM_INTERFACE_ENTRY_FUNC(IID_NULL,0,_This)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		mID = -1;
		mPrincipal = NULL;
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

// IMTPrincipalPolicy
public:
	
	STDMETHOD(IsPrincipalInRole)(/*[in]*/BSTR aRoleName, /*[out, retval]*/VARIANT_BOOL* apResult);
	STDMETHOD(GetRolesAsRowset)(/*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(GetCapabilitiesOfType)(/*[in]*/long aCapTypeID, /*[out, retval]*/IMTCollection** apCaps);
	STDMETHOD(GetCapabilitiesAsRowset)(/*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(RemoveCapabilitiesOfType)(/*[in]*/long aTypeID);
	STDMETHOD(RemoveRole)(/*[in]*/long aRoleID);
	STDMETHOD(RemoveCapability)(/*[in]*/long aCapInstanceID);
	STDMETHOD(AddRole)(/*[in]*/IMTRole* aRole);
	STDMETHOD(AddCapability)(/*[in]*/IMTCompositeCapability* aCap);
	STDMETHOD(get_PolicyType)(/*[out, retval]*/ MTPrincipalPolicyType *pVal);
	STDMETHOD(put_PolicyType)(/*[in]*/ MTPrincipalPolicyType newVal);
	STDMETHOD(GetAll)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/IMTSecurityPrincipal* aPrincipal, /*[out, retval]*/IMTCollection** apPolicies);
	STDMETHOD(GetDefault)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/IMTSecurityPrincipal* aPrincipal, /*[out, retval]*/IMTPrincipalPolicy** apPolicy);
	STDMETHOD(GetActive)(IMTSessionContext* aCtx, /*[in]*/IMTSecurityPrincipal* aPrincipal, /*[out, retval]*/IMTPrincipalPolicy** apPolicy);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_Principal)(/*[out, retval]*/ IMTSecurityPrincipal* *pVal);
  STDMETHOD(put_Principal)(/*[out, retval]*/ IMTSecurityPrincipal* pVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Roles)(/*[out, retval]*/ IMTCollection** pVal);
	STDMETHOD(get_Capabilities)(/*[out, retval]*/ IMTCollection** pVal);
	STDMETHOD(Save)();
	STDMETHOD(SaveCapabilities)();
  STDMETHOD(InternalGet)(IMTSecurityPrincipal* aPrincipal, MTPrincipalPolicyType aPolicyType, /*[out, retval]*/IMTPrincipalPolicy** apPolicy);
  STDMETHOD(FromXML)(/*[in]*/IMTSessionContext* aCtx, IDispatch* aDomNode);
  STDMETHOD(ToXML)(BSTR* apXmlString);
  STDMETHOD(RemoveAllRoles)();
	STDMETHOD(RemoveAllCapabilities)();
  STDMETHOD(RemoveCapabilityAt)(/*[in]*/long aCollectionPosition);

  void Initialize();
private:
	MTObjectCollection<IMTRole> mRoles;
	MTObjectCollection<IMTCompositeCapability> mCaps;
  MTObjectCollection<IMTCompositeCapability> mAllCaps;
	MTObjectCollection<IMTCompositeCapability> mDeletedCaps;
	MTPrincipalPolicyType mPolicyType;
	MTAUTHLib::IMTSecurityPrincipalPtr mPrincipal;
  STDMETHODIMP CMTPrincipalPolicy::CheckSubscriberCorporateAccount(MTAUTHLib::IMTPathCapabilityPtr& aAttemptedCapability, MTYAACLib::IMTYAACPtr& aAccount);
	long mID;

};

#endif //__MTPRINCIPALPOLICY_H_
