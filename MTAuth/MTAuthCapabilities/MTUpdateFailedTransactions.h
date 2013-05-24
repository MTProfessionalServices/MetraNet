	
// MTUpdateFailedTransactions.h : Declaration of the CMTUpdateFailedTransactions

#ifndef __MTUPDATEFAILEDTRANSACTIONS_H_
#define __MTUPDATEFAILEDTRANSACTIONS_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTUpdateFailedTransactions
class ATL_NO_VTABLE CMTUpdateFailedTransactions : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTUpdateFailedTransactions, &CLSID_MTUpdateFailedTransactions>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTCompositeCapability, &IID_IMTCompositeCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CMTUpdateFailedTransactions()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTUPDATEFAILEDTRANSACTIONS)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTUpdateFailedTransactions)
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

// IMTUpdateFailedTransactions
public:
};

#endif //__MTUPDATEFAILEDTRANSACTIONS_H_
