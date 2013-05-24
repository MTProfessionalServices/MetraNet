// MTManageProductOfferingsCapability.h : Declaration of the CMTManageProductOfferingsCapability

#pragma once
#include "resource.h"       // main symbols

//#include "MTAuthCapabilities.h"


// CMTManageProductOfferingsCapability

class ATL_NO_VTABLE CMTManageProductOfferingsCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTManageProductOfferingsCapability, &CLSID_MTManageProductOfferingsCapability>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTCompositeCapability, &IID_IMTCompositeCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CMTManageProductOfferingsCapability()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTMANAGEPRODUCTOFFERINGSCAPABILITY)


BEGIN_COM_MAP(CMTManageProductOfferingsCapability)
	COM_INTERFACE_ENTRY(IMTCompositeCapability)
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

public:

};

OBJECT_ENTRY_AUTO(__uuidof(MTManageProductOfferingsCapability), CMTManageProductOfferingsCapability)
