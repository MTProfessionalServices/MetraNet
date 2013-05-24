	
// MTUpdAccFromPendingFinalBillToActiveCapability.h : Declaration of the CMTUpdAccFromPendingFinalBillToActiveCapability

#ifndef __MTUPDACCFROMPENDINGFINALBILLTOACTIVECAPABILITY_H_
#define __MTUPDACCFROMPENDINGFINALBILLTOACTIVECAPABILITY_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTUpdAccFromPendingFinalBillToActiveCapability
class ATL_NO_VTABLE CMTUpdAccFromPendingFinalBillToActiveCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTUpdAccFromPendingFinalBillToActiveCapability, &CLSID_MTUpdAccFromPendingFinalBillToActiveCapability>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTCompositeCapability, &IID_IMTCompositeCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CMTUpdAccFromPendingFinalBillToActiveCapability()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTUPDACCFROMPENDINGFINALBILLTOACTIVECAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTUpdAccFromPendingFinalBillToActiveCapability)
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

// IMTUpdAccFromPendingFinalBillToActiveCapability
public:
};

#endif //__MTUPDACCFROMPENDINGFINALBILLTOACTIVECAPABILITY_H_
