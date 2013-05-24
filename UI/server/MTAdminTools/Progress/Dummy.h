	
// Dummy.h : Declaration of the CDummy

#ifndef __DUMMY_H_
#define __DUMMY_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CDummy
class ATL_NO_VTABLE CDummy : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CDummy, &CLSID_Dummy>,
	public IDispatchImpl<IDummy, &IID_IDummy, &LIBID_PROGRESSLib>
{
public:
	CDummy()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_DUMMY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CDummy)
	COM_INTERFACE_ENTRY(IDummy)
	COM_INTERFACE_ENTRY(IDispatch)
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

// IDummy
public:
};

#endif //__DUMMY_H_
