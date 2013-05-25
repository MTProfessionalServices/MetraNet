	
// MTCollectionEx.h : Declaration of the CMTCollectionEx

#ifndef __MTCOLLECTIONEX_H_
#define __MTCOLLECTIONEX_H_

#include "resource.h"       // main symbols
#include "MTCollectionImpl.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCollectionEx
class ATL_NO_VTABLE CMTCollectionEx : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCollectionEx, &CLSID_MTCollectionEx>,
	public ISupportErrorInfo,
	public MTCollectionImplEx<IMTCollectionEx, &IID_IMTCollectionEx, &LIBID_GENERICCOLLECTIONLib>
{
public:
	CMTCollectionEx()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOLLECTIONEX)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCollectionEx)
	COM_INTERFACE_ENTRY(IMTCollectionReadOnly)
	COM_INTERFACE_ENTRY(IMTCollection)
	COM_INTERFACE_ENTRY(IMTCollectionEx)
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

// IMTCollectionEx
public:
};

#endif //__MTCOLLECTIONEX_H_
