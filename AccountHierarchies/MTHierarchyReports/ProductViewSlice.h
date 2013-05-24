	
// ProductViewSlice.h : Declaration of the CProductViewSlice

#ifndef __PRODUCTVIEWSLICE_H_
#define __PRODUCTVIEWSLICE_H_

#include "resource.h"       // main symbols
#include <map>
#include <SingleProductViewSliceImpl.h>

#import <MTHierarchyReports.tlb> rename("EOF", "EOFHR")
#include <SingleProductViewSliceImpl.h>

/////////////////////////////////////////////////////////////////////////////
// CProductViewSlice
class ATL_NO_VTABLE CProductViewSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CProductViewSlice, &CLSID_ProductViewSlice>,
	public ISupportErrorInfo,
	public SingleProductViewSliceImpl<IProductViewSlice, &IID_IProductViewSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CProductViewSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_PRODUCTVIEWSLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CProductViewSlice)
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

#endif //__PRODUCTVIEWSLICE_H_
