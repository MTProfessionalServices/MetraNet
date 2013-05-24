	
// PriceableItemInstanceSlice.h : Declaration of the CPriceableItemInstanceSlice

#ifndef __PRICEABLEITEMINSTANCESLICE_H_
#define __PRICEABLEITEMINSTANCESLICE_H_

#include "resource.h"       // main symbols
#include <map>
#import <MTHierarchyReports.tlb> rename("EOF", "EOFHR")
#include <SingleProductViewSliceImpl.h>

/////////////////////////////////////////////////////////////////////////////
// CPriceableItemInstanceSlice
class ATL_NO_VTABLE CPriceableItemInstanceSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CPriceableItemInstanceSlice, &CLSID_PriceableItemInstanceSlice>,
	public ISupportErrorInfo,
	public SingleProductViewSliceImpl<IPriceableItemInstanceSlice, &IID_IPriceableItemInstanceSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CPriceableItemInstanceSlice() :
		mInstanceID(-1),
		mViewID(-1)
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_PRICEABLEITEMINSTANCESLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CPriceableItemInstanceSlice)
	COM_INTERFACE_ENTRY(IPriceableItemInstanceSlice)
	COM_INTERFACE_ENTRY(IViewSlice)
	COM_INTERFACE_ENTRY(ISingleProductSlice)
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

// IPriceableItemInstanceSlice
public:
	STDMETHOD(get_InstanceID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_InstanceID)(/*[in]*/ long newVal);
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
// ISingleProductSlice
public:
	STDMETHOD(get_ProductView)(/*[out, retval]*/ IProductView* *pVal);
	STDMETHOD(get_DisplayName)(/*[in]*/ ICOMLocaleTranslator *apLocale, /*[out,retval]*/ BSTR *pVal);
private:
	long mInstanceID;
	long mViewID;
  MTPRODUCTVIEWLib::IProductViewPtr mProductView;

	std::map<long,_bstr_t> mDisplayName;
};

#endif //__PRICEABLEITEMINSTANCESLICE_H_
