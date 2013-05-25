// MTProductViewOps.h : Declaration of the CMTProductViewOps

#ifndef __MTPRODUCTVIEWOPS_H_
#define __MTPRODUCTVIEWOPS_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewOps
class ATL_NO_VTABLE CMTProductViewOps : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTProductViewOps, &CLSID_MTProductViewOps>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTProductViewOps, &IID_IMTProductViewOps, &LIBID_MTPRODUCTVIEWLib>
{
public:
	CMTProductViewOps()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTVIEWOPS)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTProductViewOps)
	COM_INTERFACE_ENTRY(IMTProductViewOps)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTProductViewOps
public:
	STDMETHOD(DropAllProductViews)();
	STDMETHOD(DropProductView)(/*[in]*/ BSTR xmlfile);
	STDMETHOD(AddAllProductViews)();
	STDMETHOD(AddProductView)(/*[in]*/ BSTR xmlFile);
	STDMETHOD(UpgradeProductViews30To35)();
};

#endif //__MTPRODUCTVIEWOPS_H_
