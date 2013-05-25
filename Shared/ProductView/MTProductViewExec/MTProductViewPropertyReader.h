// MTProductViewPropertyReader.h : Declaration of the CMTProductViewPropertyReader

#ifndef __MTPRODUCTVIEWPROPERTYREADER_H_
#define __MTPRODUCTVIEWPROPERTYREADER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewPropertyReader
class ATL_NO_VTABLE CMTProductViewPropertyReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTProductViewPropertyReader, &CLSID_MTProductViewPropertyReader>,
	public IObjectControl,
	public IDispatchImpl<IMTProductViewPropertyReader, &IID_IMTProductViewPropertyReader, &LIBID_MTPRODUCTVIEWEXECLib>
{
public:
	CMTProductViewPropertyReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTVIEWPROPERTYREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTProductViewPropertyReader)

BEGIN_COM_MAP(CMTProductViewPropertyReader)
	COM_INTERFACE_ENTRY(IMTProductViewPropertyReader)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTProductViewPropertyReader
public:
		STDMETHOD(Load)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTSQLRowset* apRowset, /*[out, retval]*/ IProductViewProperty** apPVProp);
		STDMETHOD(LoadInternal)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTSQLRowset* apRowset, /*[out, retval]*/ IProductViewProperty** apPVProp);
		STDMETHOD(Find)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPVPropID, /*[out, retval]*/ IProductViewProperty** apPVProp);
private:
	MSIX_PROPERTY_TYPE Convert(long pt);
};

#endif //__MTPRODUCTVIEWPROPERTYREADER_H_
