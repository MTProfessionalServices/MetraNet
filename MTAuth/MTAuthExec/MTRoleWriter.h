// MTRoleWriter.h : Declaration of the CMTRoleWriter

#ifndef __MTROLEWRITER_H_
#define __MTROLEWRITER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTRoleWriter
class ATL_NO_VTABLE CMTRoleWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTRoleWriter, &CLSID_MTRoleWriter>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTRoleWriter, &IID_IMTRoleWriter, &LIBID_MTAUTHEXECLib>
{
public:
	CMTRoleWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTROLEWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTRoleWriter)

BEGIN_COM_MAP(CMTRoleWriter)
	COM_INTERFACE_ENTRY(IMTRoleWriter)
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

// IMTRoleWriter
public:
	STDMETHOD(CreateOrUpdate)(/*[in]*/IMTRole* aRole);
	STDMETHOD(AddMemberBatch)(/*[in]*/IMTCollection* aBatch, /*[in]*/IMTProgress* aProgress, /*[in]*/IMTRole* aRole, /*[out, retval]*/IMTRowSet** apRowset);
	STDMETHOD(RemoveMember)(/*[in]*/IMTRole* aRole, /*[in]*/long aMember);
	STDMETHOD(AddMember)(/*[in]*/IMTRole* aRole, /*[in]*/long aMember);
	STDMETHOD(Remove)(/*[in]*/IMTSessionContext* apCtxt, /*[in]*/IMTRole* aRole, IMTPrincipalPolicy* aPolicy);
	STDMETHOD(Update)(/*[in]*/IMTSessionContext* apCtxt, /*[in]*/IMTRole* apRole);
	STDMETHOD(Create)(/*[in]*/IMTSessionContext* apCtxt, /*[in]*/IMTRole* apRole, /*[out, retval]*/long* apID);
};

#endif //__MTROLEWRITER_H_
