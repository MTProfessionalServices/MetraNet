	
// MTSelfSubscribe.h : Declaration of the CMTSelfSubscribe

#ifndef __MTSELFSUBSCRIBE_H_
#define __MTSELFSUBSCRIBE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTSelfSubscribe
class ATL_NO_VTABLE CMTSelfSubscribe : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSelfSubscribe, &CLSID_MTSelfSubscribe>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTCompositeCapability, &IID_IMTCompositeCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CMTSelfSubscribe()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSELFSUBSCRIBE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTSelfSubscribe)
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

// IMTSelfSubscribe
public:
};

#endif //__MTSELFSUBSCRIBE_H_
