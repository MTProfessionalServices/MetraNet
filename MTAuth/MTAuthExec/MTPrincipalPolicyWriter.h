// MTPrincipalPolicyWriter.h : Declaration of the CMTPrincipalPolicyWriter

#ifndef __MTPRINCIPALPOLICYWRITER_H_
#define __MTPRINCIPALPOLICYWRITER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTPrincipalPolicyWriter
class ATL_NO_VTABLE CMTPrincipalPolicyWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPrincipalPolicyWriter, &CLSID_MTPrincipalPolicyWriter>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTPrincipalPolicyWriter, &IID_IMTPrincipalPolicyWriter, &LIBID_MTAUTHEXECLib>
{
public:
	CMTPrincipalPolicyWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRINCIPALPOLICYWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPrincipalPolicyWriter)

BEGIN_COM_MAP(CMTPrincipalPolicyWriter)
	COM_INTERFACE_ENTRY(IMTPrincipalPolicyWriter)
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

// IMTPrincipalPolicyWriter
public:
	STDMETHOD(DeleteRoleMappings)(/*[in]*/IMTPrincipalPolicy* aPolicy);
	STDMETHOD(InsertRoleMappings)(/*[in]*/IMTPrincipalPolicy* aPolicy);
	STDMETHOD(CreateAtomicInstance)(/*[in]*/IMTAtomicCapability* aCap, /*[in]*/IMTPrincipalPolicy* aPolicy,  /*[out, retval]*/long* apID);
	STDMETHOD(UpdateCompositeInstance)(/*[in]*/IMTCompositeCapability* aCap, /*[in]*/IMTPrincipalPolicy* aPolicy);
	STDMETHOD(CreateCompositeInstance)(/*[in]*/IMTCompositeCapability* aCap, /*[in]*/IMTPrincipalPolicy* aPolicy,  /*[out, retval]*/long* apID);
	STDMETHOD(Create)(/*[in]*/IMTPrincipalPolicy* aPolicy, long* apID);
	STDMETHOD(Update)(/*[in]*/IMTSessionContext* apCtxt, /*[in]*/IMTPrincipalPolicy* aPolicy);
private:
	char* GetStringPolicyType(MTPrincipalPolicyType aPolType);
	char* GetPrincipalColumn(MTSecurityPrincipalType aPrType);
	void SaveCapabilities(IMTPrincipalPolicy* aPolicy);

};

#endif //__MTPRINCIPALPOLICYWRITER_H_
