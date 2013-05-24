	
// MTManageCSRAuthCapability.h : Declaration of the CMTManageCSRAuthCapability

#ifndef __MTMANAGECSRAUTHCAPABILITY_H_
#define __MTMANAGECSRAUTHCAPABILITY_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTManageCSRAuthCapability
class ATL_NO_VTABLE CMTManageCSRAuthCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTManageCSRAuthCapability, &CLSID_MTManageCSRAuthCapability>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTCompositeCapability, &IID_IMTCompositeCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CMTManageCSRAuthCapability()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTMANAGECSRAUTHCAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTManageCSRAuthCapability)
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

// IMTManageCSRAuthCapability
public:
};

#endif //__MTMANAGECSRAUTHCAPABILITY_H_
