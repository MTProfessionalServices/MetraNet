// ProductViewAllUsageSlice.h : Declaration of the CProductViewAllUsageSlice

#pragma once
#include "resource.h"       // main symbols
#include <map>
#import <MTHierarchyReports.tlb> rename("EOF", "EOFHR")
#include <SingleProductViewSliceImpl.h>

/////////////////////////////////////////////////////////////////////////////
// CProductViewAllUsageSlice
class ATL_NO_VTABLE CProductViewAllUsageSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CProductViewAllUsageSlice, &CLSID_ProductViewAllUsageSlice>,
	public ISupportErrorInfo,
	public SingleProductViewSliceImpl<IProductViewAllUsageSlice, &IID_IProductViewAllUsageSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CProductViewAllUsageSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_PRODUCTVIEWALLUSAGESLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CProductViewAllUsageSlice)
	COM_INTERFACE_ENTRY(IProductViewAllUsageSlice)
  COM_INTERFACE_ENTRY(IProductViewSlice)
	COM_INTERFACE_ENTRY(ISingleProductSlice)
	COM_INTERFACE_ENTRY(IViewSlice)
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

// IProductViewSlice
public:
	STDMETHOD(get_ViewID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ViewID)(/*[in]*/ long newVal);
// IViewSlice
public:
	STDMETHOD(GenerateQueryPredicate)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToString)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToStringUnencrypted)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(FromString)(/*[in]*/ ISliceLexer* apLexer);
  STDMETHOD(Equals)(/*[in]*/ IViewSlice* apSlice, /*[out,retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(Clone)(/*[out,retval]*/ IViewSlice* *pVal);
public:
  //ISingleProductSlice
  STDMETHOD(get_ProductView)(/*[out, retval]*/ IProductView* *pVal);
	STDMETHOD(get_DisplayName)(/*[in]*/ ICOMLocaleTranslator *apLocale, /*[out,retval]*/ BSTR *pVal);
  
};

OBJECT_ENTRY_AUTO(__uuidof(ProductViewAllUsageSlice), CProductViewAllUsageSlice)
