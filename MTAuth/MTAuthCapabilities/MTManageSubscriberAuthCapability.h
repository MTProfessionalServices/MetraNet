	
// MTManageSubscriberAuthCapability.h : Declaration of the CMTManageSubscriberAuthCapability

#ifndef __MTMANAGESUBSCRIBERAUTHCAPABILITY_H_
#define __MTMANAGESUBSCRIBERAUTHCAPABILITY_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTManageSubscriberAuthCapability
class ATL_NO_VTABLE CMTManageSubscriberAuthCapability : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTManageSubscriberAuthCapability, &CLSID_MTManageSubscriberAuthCapability>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTCompositeCapability, &IID_IMTCompositeCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CMTManageSubscriberAuthCapability()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTMANAGESUBSCRIBERAUTHCAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTManageSubscriberAuthCapability)
	COM_INTERFACE_ENTRY(IMTCompositeCapability)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

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

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTManageSubscriberAuthCapability
public:
};

#endif //__MTMANAGESUBSCRIBERAUTHCAPABILITY_H_
