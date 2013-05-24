// MTSubscriptionCatalog.h : Declaration of the CMTSubscriptionCatalog

#pragma once
#include "resource.h"       // main symbols

#include "Subscription.h"


// CMTSubscriptionCatalog

class ATL_NO_VTABLE CMTSubscriptionCatalog : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSubscriptionCatalog, &CLSID_MTSubscriptionCatalog>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSubscriptionCatalog, &IID_IMTSubscriptionCatalog, &LIBID_SubscriptionLib, /*wMajor =*/ 1, /*wMinor =*/ 0>
{
public:
	CMTSubscriptionCatalog()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSUBSCRIPTIONCATALOG)


BEGIN_COM_MAP(CMTSubscriptionCatalog)
	COM_INTERFACE_ENTRY(IMTSubscriptionCatalog)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

	DECLARE_PROTECT_FINAL_CONSTRUCT()
	DECLARE_GET_CONTROLLING_UNKNOWN()

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

protected:
// methods only visible to derived C++ classes (not exposed to COM clients)
	MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr GetSessionContextPtr();
  MTAuthInterfacesLib::IMTSecurityContextPtr GetSecurityContext();
//overridable methods
	virtual void OnSetSessionContext(IMTSessionContext* apSessionContext);

	MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr mSessionContextPtr;

public:
	STDMETHOD(SubscribeToGroups)(/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress, /*[in]*/ VARIANT_BOOL bUnsubscribeConflicting, /*[out]*/ VARIANT_BOOL* pDateModified,/*[in,optional]*/ VARIANT transaction,/*[out,retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(SubscribeAccounts)(/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress, /*[in]*/ VARIANT_BOOL bUnsubscribeConflicting, /*[out]*/ VARIANT_BOOL* pDateModified,/*[in,optional]*/ VARIANT transaction,/*[out,retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(SetSessionContext)(/*[in]*/ IMTSessionContext* apSessionContext);
	STDMETHOD(GetSessionContext)(/*[out, retval]*/ IMTSessionContext** apSessionContext);
};

OBJECT_ENTRY_AUTO(__uuidof(MTSubscriptionCatalog), CMTSubscriptionCatalog)
