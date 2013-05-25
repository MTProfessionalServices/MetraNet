	
// ProductViewCatalog.h : Declaration of the CProductViewCatalog

#ifndef __PRODUCTVIEWCATALOG_H_
#define __PRODUCTVIEWCATALOG_H_

#include "resource.h"       // main symbols

#import <MTProductView.tlb> rename ("EOF", "EOFX")
#import <MTProductViewExec.tlb> rename ("EOF", "EOFX")

/////////////////////////////////////////////////////////////////////////////
// CProductViewCatalog
class ATL_NO_VTABLE CProductViewCatalog : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CProductViewCatalog, &CLSID_ProductViewCatalog>,
	public ISupportErrorInfo,
	public IDispatchImpl<IProductViewCatalog, &IID_IProductViewCatalog, &LIBID_MTPRODUCTVIEWLib>
{
public:
	CProductViewCatalog()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_PRODUCTVIEWCATALOG)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CProductViewCatalog)
	COM_INTERFACE_ENTRY(IProductViewCatalog)
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

// IProductViewCatalog
public:
	STDMETHOD(get_SessionContext)(/*[out, retval]*/ IMTSessionContext* *pVal);
	STDMETHOD(putref_SessionContext)(/*[in]*/ IMTSessionContext* newVal);
	STDMETHOD(RemoveProductView)(/*[in]*/ long aID);
	STDMETHOD(GetProductView)(/*[in]*/ long aID, /*[out, retval]*/ IProductView* *apPV);
	STDMETHOD(GetProductViewByName)(/*[in]*/ BSTR aName, /*[out, retval]*/ IProductView* *apPV);
	STDMETHOD(CreateProductViewFromConfig)(/*[in]*/ BSTR aProductViewName, /*[in]*/ VARIANT_BOOL aHasChildren, /*[out, retval]*/ IProductView* *apPV);
	STDMETHOD(GetProductViewProperty)(/*[in]*/ long aID, /*[out, retval]*/ IProductViewProperty* *apPVProp);
private:
  MTPRODUCTVIEWLib::IMTSessionContextPtr mSessionContext;	
  MTPRODUCTVIEWEXECLib::IMTSessionContextPtr mSessionContextExec;	
	
};

#endif //__PRODUCTVIEWCATALOG_H_
