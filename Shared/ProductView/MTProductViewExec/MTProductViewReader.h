// MTProductViewReader.h : Declaration of the CMTProductViewReader

#ifndef __MTPRODUCTVIEWREADER_H_
#define __MTPRODUCTVIEWREADER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewReader
class ATL_NO_VTABLE CMTProductViewReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTProductViewReader, &CLSID_MTProductViewReader>,
	public IObjectControl,
	public IDispatchImpl<IMTProductViewReader, &IID_IMTProductViewReader, &LIBID_MTPRODUCTVIEWEXECLib>
{
public:
	CMTProductViewReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTVIEWREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTProductViewReader)

BEGIN_COM_MAP(CMTProductViewReader)
	COM_INTERFACE_ENTRY(IMTProductViewReader)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTProductViewReader
public:
		STDMETHOD(Load)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTSQLRowset* apRowset, /*[out, retval]*/ IProductView** apPV);
		STDMETHOD(Find)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPVID, /*[out, retval]*/ IProductView** apPV);
		STDMETHOD(FindProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPVID, /*[out, retval]*/ IMTCollection** apProperties);
		STDMETHOD(FindByName)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ BSTR aPVName, /*[out, retval]*/ IProductView** apPV);
};

#endif //__MTPRODUCTVIEWREADER_H_
