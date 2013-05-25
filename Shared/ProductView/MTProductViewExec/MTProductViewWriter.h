// MTProductViewWriter.h : Declaration of the CMTProductViewWriter

#ifndef __MTPRODUCTVIEWWRITER_H_
#define __MTPRODUCTVIEWWRITER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewWriter
class ATL_NO_VTABLE CMTProductViewWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTProductViewWriter, &CLSID_MTProductViewWriter>,
	public IObjectControl,
	public IDispatchImpl<IMTProductViewWriter, &IID_IMTProductViewWriter, &LIBID_MTPRODUCTVIEWEXECLib>
{
public:
	CMTProductViewWriter();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTVIEWWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTProductViewWriter)

BEGIN_COM_MAP(CMTProductViewWriter)
	COM_INTERFACE_ENTRY(IMTProductViewWriter)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTProductViewWriter
public:
    STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IProductView* apPV, /*[out, retval]*/ long* apID);
    STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IProductView* apPV);
    STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID);
    STDMETHOD(RecursiveUpdate)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IProductView* apPV);
};

#endif //__MTPRODUCTVIEWWRITER_H_
