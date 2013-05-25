	
// ProductViewUniqueKey.h : Declaration of the CProductViewUniqueKey

#ifndef __PRODUCTVIEWUNIQUEKEY_H_
#define __PRODUCTVIEWUNIQUEKEY_H_

#include "resource.h"       // main symbols

#include <comutil.h>
#include <MTObjectCollection.h>

#import <MTProductView.tlb> rename ("EOF", "EOFX")
#import <MTProductViewExec.tlb> rename ("EOF", "EOFX")

/////////////////////////////////////////////////////////////////////////////
// CProductViewProperty
class ATL_NO_VTABLE CProductViewUniqueKey : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CProductViewUniqueKey, &CLSID_ProductViewUniqueKey>,
	public ISupportErrorInfo,
	public IDispatchImpl<IProductViewUniqueKey, &IID_IProductViewUniqueKey, &LIBID_MTPRODUCTVIEWLib>
{
public:
	CProductViewUniqueKey();

DECLARE_REGISTRY_RESOURCEID(IDR_PRODUCTVIEWUNIQUEKEY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CProductViewUniqueKey)
	COM_INTERFACE_ENTRY(IProductViewUniqueKey)
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

// IProductViewUniqueKey
public:
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_TableName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_TableName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ProductView)(/*[out, retval]*/ IProductView* *pVal);
	STDMETHOD(putref_ProductView)(/*[in]*/ IProductView* newVal);
	STDMETHOD(GetProperties)(/*[out, retval]*/ IMTCollection **pProperties);
	STDMETHOD(AddProperty)(/*[in]*/ IProductViewProperty *pProperty);

private:
	long mID;
	_bstr_t mName;
	_bstr_t mTableName;

	MTPRODUCTVIEWLib::IProductViewPtr mProductView;

	MTObjectCollection<IProductViewProperty> mProperties;
};

#endif //__PRODUCTVIEWUNIQUEKEY_H_
