	
// ProductView.h : Declaration of the CProductView

#ifndef __PRODUCTVIEW_H_
#define __PRODUCTVIEW_H_

#include "resource.h"       // main symbols

#include <comutil.h>
#include <MSIXProperties.h>
#include <UniqueKey.h>
#include <MTObjectCollection.h>

#import <MTProductView.tlb> rename ("EOF", "EOFX")
#import <MTProductViewExec.tlb> rename ("EOF", "EOFX")

/////////////////////////////////////////////////////////////////////////////
// CProductView
class ATL_NO_VTABLE CProductView : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CProductView, &CLSID_ProductView>,
	public ISupportErrorInfo,
	public IDispatchImpl<IProductView, &IID_IProductView, &LIBID_MTPRODUCTVIEWLib>
{
public:
	CProductView();

DECLARE_REGISTRY_RESOURCEID(IDR_PRODUCTVIEW)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CProductView)
	COM_INTERFACE_ENTRY(IProductView)
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

// IProductView
public:
	STDMETHOD(Init)(/*[in]*/ BSTR aProductViewName, /*[in]*/ VARIANT_BOOL aHasChildren);
	STDMETHOD(get_TableName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_TableName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ViewID)(/*[out, retval]*/ long *pVal);
   STDMETHOD(put_ViewID)(/*[in]*/ long newVal);
	STDMETHOD(get_HasChildren)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(GetProperties)(/*[out, retval]*/ IMTCollection **pProperties);
	STDMETHOD(GetPropertyByName)(/*[in]*/ BSTR aDN, IProductViewProperty* *pVal);
	STDMETHOD(GetPropertyByColumnName)(/*[in]*/ BSTR aColumnName, IProductViewProperty* *pVal);
	STDMETHOD(get_SessionContext)(/*[out, retval]*/ IMTSessionContext* *pVal);
	STDMETHOD(putref_SessionContext)(/*[in]*/ IMTSessionContext* newVal);
	STDMETHOD(Save)(/*[out, retval]*/ long *apID);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(GetUniqueKeys)(/*[out, retval]*/ IMTCollection **pUniqueKeys);
	STDMETHOD(get_CanResubmitFrom)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_CanResubmitFrom)(/*[in]*/ VARIANT_BOOL newVal);
private:
	_bstr_t mTableName;
	_bstr_t mProductViewName;
	long mViewID;
	long mID;
  VARIANT_BOOL mCanResubmitFrom;
	VARIANT_BOOL mHasChildren;
	MTObjectCollection<IProductViewProperty> mProperties;
	MTObjectCollection<IProductViewUniqueKey> mUniqueKeys;
	MSIX_PROPERTY_TYPE Convert(CMSIXProperties::PropertyType pt);

	HRESULT AddMSIXProperty(CMSIXProperties * apPVProp, bool aIsCore);
	HRESULT AddUniqueKey(UniqueKey * pUK);
	HRESULT GetCoreProperties();
	MTPRODUCTVIEWLib::IMTSessionContextPtr mSessionContext;	
	MTPRODUCTVIEWEXECLib::IMTSessionContextPtr mSessionContextExec;	
};

#endif //__PRODUCTVIEW_H_
