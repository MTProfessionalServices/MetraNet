	
// ProductViewProperty.h : Declaration of the CProductViewProperty

#ifndef __PRODUCTVIEWPROPERTY_H_
#define __PRODUCTVIEWPROPERTY_H_

#include "resource.h"       // main symbols

#include <comutil.h>
#import <MTProductView.tlb> rename ("EOF", "EOFX")
#import <MTProductViewExec.tlb> rename ("EOF", "EOFX")

/////////////////////////////////////////////////////////////////////////////
// CProductViewProperty
class ATL_NO_VTABLE CProductViewProperty : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CProductViewProperty, &CLSID_ProductViewProperty>,
	public ISupportErrorInfo,
	public IDispatchImpl<IProductViewProperty, &IID_IProductViewProperty, &LIBID_MTPRODUCTVIEWLib>
{
public:
	CProductViewProperty();

DECLARE_REGISTRY_RESOURCEID(IDR_PRODUCTVIEWPROPERTY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CProductViewProperty)
	COM_INTERFACE_ENTRY(IProductViewProperty)
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

// IProductViewProperty
public:
	STDMETHOD(get_DataType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DataType)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ColumnName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ColumnName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DN)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DN)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Required)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Required)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_DescriptionID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_DescriptionID)(/*[in]*/ long newVal);
	STDMETHOD(get_CompositeIndex)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_CompositeIndex)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_SingleIndex)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_SingleIndex)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_PartOfKey)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_PartOfKey)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_Exportable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Exportable)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_Filterable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Filterable)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_UserVisible)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_UserVisible)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_DefaultValue)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_DefaultValue)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get_PropertyType)(/*[out, retval]*/ MSIX_PROPERTY_TYPE *pVal);
	STDMETHOD(put_PropertyType)(/*[in]*/ MSIX_PROPERTY_TYPE newVal);
	STDMETHOD(get_EnumNamespace)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumNamespace)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EnumEnumeration)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumEnumeration)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Core)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Core)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_DisplayName)(/*[in]*/ ICOMLocaleTranslator *apLocale, /*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_SessionContext)(/*[out, retval]*/ IMTSessionContext* *pVal);
	STDMETHOD(putref_SessionContext)(/*[in]*/ IMTSessionContext* newVal);
	STDMETHOD(Save)(/*[out, retval]*/ long *apID);
	STDMETHOD(get_ProductView)(/*[out, retval]*/ IProductView* *pVal);
	STDMETHOD(putref_ProductView)(/*[in]*/ IProductView* newVal);
	STDMETHOD(get_ProductViewID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ProductViewID)(/*[in]*/ long newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);	
private:
	_bstr_t mDN;
	_bstr_t mColumnName;
	_bstr_t mDataType;
	_bstr_t mEnumNamespace;
	_bstr_t mEnumEnumeration;
	VARIANT_BOOL mRequired;
	long mDescriptionID;
	VARIANT_BOOL mCompositeIndex;
	VARIANT_BOOL mSingleIndex;
	VARIANT_BOOL mPartOfKey;
	VARIANT_BOOL mExportable;
	VARIANT_BOOL mFilterable;
	VARIANT_BOOL mUserVisible;
	_variant_t mDefaultValue;
	MSIX_PROPERTY_TYPE mPropertyType;
	VARIANT_BOOL mCore;
	long mViewID;
	long mID;
	long mProductViewID;
	_bstr_t mDescription;
  MTPRODUCTVIEWLib::IMTSessionContextPtr mSessionContext;	
  MTPRODUCTVIEWEXECLib::IMTSessionContextPtr mSessionContextExec;	
	MTPRODUCTVIEWLib::IProductViewPtr mProductView;
};

#endif //__PRODUCTVIEWPROPERTY_H_
