	
// MTImpersonateUserCapability.h : Declaration of the CMTImpersonateUserCapability

#ifndef __MTIMPERSONATEUSERCAPABILITY_H_
#define __MTIMPERSONATEUSERCAPABILITY_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTImpersonateUserCapability
class ATL_NO_VTABLE CMTImpersonateUserCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTImpersonateUserCapability, &CLSID_MTImpersonateUserCapability>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTCompositeCapability, &IID_IMTCompositeCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CMTImpersonateUserCapability()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTIMPERSONATEUSERCAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTImpersonateUserCapability)
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


public:
};

#endif //__MTIMPERSONATEUSERCAPABILITY_H_
