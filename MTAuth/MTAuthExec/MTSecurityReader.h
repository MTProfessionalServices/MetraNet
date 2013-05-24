// MTSecurityReader.h : Declaration of the CMTSecurityReader

#ifndef __MTSECURITYREADER_H_
#define __MTSECURITYREADER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTSecurityReader
class ATL_NO_VTABLE CMTSecurityReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTSecurityReader, &CLSID_MTSecurityReader>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTSecurityReader, &IID_IMTSecurityReader, &LIBID_MTAUTHEXECLib>
{
public:
	CMTSecurityReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSECURITYREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTSecurityReader)

BEGIN_COM_MAP(CMTSecurityReader)
	COM_INTERFACE_ENTRY(IMTSecurityReader)
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
	STDMETHOD(GetRoleByName)(IMTSessionContext* aCtx, BSTR aRoleName, IMTRole** apRole);
	STDMETHOD(GetRoleByID)(IMTSessionContext* aCtx, long aRoleID, IMTRole** apRole);

	CComPtr<IObjectContext> m_spObjectContext;

// IMTSecurityReader
public:
	STDMETHOD(GetAvailableRolesAsRowset)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/IMTSecurityPrincipal* aPrincipal, MTPrincipalPolicyType aPolicyType, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(GetAvailableCapabilityTypesAsRowset)(IMTSessionContext* aCtx, IMTSecurityPrincipal* aPrincipal, IMTSQLRowset** apRowset);
	STDMETHOD(GetCapabilityTypesAsRowset)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(GetAllRolesAsRowset)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/IMTSQLRowset** apRowset);
private:
  char* GetStringPolicyType(MTPrincipalPolicyType aPolType);
};

#endif //__MTSECURITYREADER_H_
