// MTRoleReader.h : Declaration of the CMTRoleReader

#ifndef __MTROLEREADER_H_
#define __MTROLEREADER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTRoleReader
class ATL_NO_VTABLE CMTRoleReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTRoleReader, &CLSID_MTRoleReader>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTRoleReader, &IID_IMTRoleReader, &LIBID_MTAUTHEXECLib>
{
public:
	CMTRoleReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTROLEREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTRoleReader)

BEGIN_COM_MAP(CMTRoleReader)
	COM_INTERFACE_ENTRY(IMTRoleReader)
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

	CComPtr<IObjectContext> m_spObjectContext;

// IMTRoleReader
public:
	STDMETHOD(GetByName)(IMTSessionContext* aCtx, /*[in]*/BSTR aRoleName, IMTRole** apRole);
	STDMETHOD(Get)( /*[in]*/IMTSessionContext* aCtx, /*[in]*/long aRoleID, /*[out, retval]*/IMTRole** apRole);
	STDMETHOD(IsDuplicateName)(/*[in]*/BSTR aRoleName, /*[out, retval]*/VARIANT_BOOL* apRes);
	STDMETHOD(HasMembers)(/*[in]*/BSTR aName, /*[out, retval]*/VARIANT_BOOL* apRes);
	STDMETHOD(FindRecordsByNameAsRowset)(/*[in]*/BSTR aTypeName, IMTSQLRowset** apRowset);
	STDMETHOD(GetMembersAsRowset)(/*[in]*/long aRoleID,MTPrincipalPolicyType aPolicyType, /*[out, retval]*/IMTSQLRowset** apRowset);
  STDMETHOD(HasCapabilities)(/*[in]*/BSTR aRoleName, /*[out, retval]*/VARIANT_BOOL* apRes);
};

#endif //__MTROLEREADER_H_
