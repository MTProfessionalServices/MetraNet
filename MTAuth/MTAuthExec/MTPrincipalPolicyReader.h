// MTPrincipalPolicyReader.h : Declaration of the CMTPrincipalPolicyReader

#ifndef __MTPRINCIPALPOLICYREADER_H_
#define __MTPRINCIPALPOLICYREADER_H_

#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTPrincipalPolicyReader
class ATL_NO_VTABLE CMTPrincipalPolicyReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPrincipalPolicyReader, &CLSID_MTPrincipalPolicyReader>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTPrincipalPolicyReader, &IID_IMTPrincipalPolicyReader, &LIBID_MTAUTHEXECLib>
{
public:
	CMTPrincipalPolicyReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRINCIPALPOLICYREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPrincipalPolicyReader)

BEGIN_COM_MAP(CMTPrincipalPolicyReader)
	COM_INTERFACE_ENTRY(IMTPrincipalPolicyReader)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> mpObjectContext;

// IMTPrincipalPolicyReader
public:
	STDMETHOD(GetRolesAsRowset)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/long aPolicyID, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(GetCapabilitiesAsRowset)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/long aPolicyID, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(GetPrincipalCapabilities)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/IMTSecurityPrincipal* aPrincipal, MTPrincipalPolicyType aPolicyType,  VARIANT_BOOL abIncludeOwnedFolders, IMTCollection **apCaps);
	STDMETHOD(GetAccountRoles)(/*[in]*/IMTSessionContext* aCtx, long aAccountID, MTPrincipalPolicyType aPolicyType,  VARIANT_BOOL abIncludeOwnedFolders, IMTCollection **apRoles);
	STDMETHOD(GetPolicyID)(/*[in]*/IMTSessionContext* aCtx, IMTPrincipalPolicy* aPolicy, long* apID);
	
private:
	char* GetStringPolicyType(MTPrincipalPolicyType aPolType);
	char* GetPrincipalColumn(MTSecurityPrincipalType aPrType);
  
};

#endif //__MTPRINCIPALPOLICYREADER_H_
