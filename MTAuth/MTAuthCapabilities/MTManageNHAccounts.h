	
// MTManageNHAccounts.h : Declaration of the CMTManageNHAccounts

#ifndef __MTMANAGENHACCOUNTS_H_
#define __MTMANAGENHACCOUNTS_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTManageNHAccounts
class ATL_NO_VTABLE CMTManageNHAccounts : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTManageNHAccounts, &CLSID_MTManageNHAccounts>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTCompositeCapability, &IID_IMTCompositeCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CMTManageNHAccounts()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTMANAGENHACCOUNTS)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTManageNHAccounts)
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

// IMTManageNHAccounts
public:
};

#endif //__MTMANAGENHACCOUNTS_H_
