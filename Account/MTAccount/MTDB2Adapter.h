	
// MTDB2Adapter.h : Declaration of the CMTDB2Adapter

#ifndef __MTDB2ADAPTER_H_
#define __MTDB2ADAPTER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTDB2Adapter
class ATL_NO_VTABLE CMTDB2Adapter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTDB2Adapter, &CLSID_MTDB2Adapter>,
	public IDispatchImpl<::IMTAccountAdapter, &IID_IMTAccountAdapter, &LIBID_MTACCOUNTLib>,
	public ISupportErrorInfo,
	public IMTAccountAdapter2
{
public:
	CMTDB2Adapter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTDB2ADAPTER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTDB2Adapter)
	COM_INTERFACE_ENTRY(::IMTAccountAdapter)
	COM_INTERFACE_ENTRY(::IMTAccountAdapter2)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

	HRESULT FinalConstruct() { return S_OK; }

	void FinalRelease() { }

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTDB2Adapter
public:
	STDMETHOD(Uninstall)();
	STDMETHOD(Install)();
	STDMETHOD(Initialize)(BSTR AdapterName);
	STDMETHOD(AddData)(BSTR AdapterName, 
				       ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset);
	STDMETHOD(UpdateData)(BSTR AdapterName, 
					      ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset);
	STDMETHOD(GetData)(BSTR AdapterName, 
				       long AccountID,
					   VARIANT apRowst,
				       ::IMTAccountPropertyCollection** mtptr);
	STDMETHOD(SearchData)(BSTR AdapeterName,
						::IMTAccountPropertyCollection* mtptr,
					    VARIANT apRowst,
						::IMTSearchResultCollection** mtp);
	STDMETHOD(GetPropertyMetaData)(BSTR aPropertyName,
								   ::IMTPropertyMetaData** apMetaData); 
	STDMETHOD(SearchDataWithUpdLock)(BSTR AdapeterName,
						::IMTAccountPropertyCollection* mtptr,
					    BOOL wUpdLock,
						VARIANT apRowst,						
						::IMTSearchResultCollection** mtp);
};

#endif //__MTDB2ADAPTER_H_
