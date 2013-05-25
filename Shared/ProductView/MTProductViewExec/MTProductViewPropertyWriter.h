// MTProductViewPropertyWriter.h : Declaration of the CMTProductViewPropertyWriter

#ifndef __MTPRODUCTVIEWPROPERTYWRITER_H_
#define __MTPRODUCTVIEWPROPERTYWRITER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewPropertyWriter
class ATL_NO_VTABLE CMTProductViewPropertyWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTProductViewPropertyWriter, &CLSID_MTProductViewPropertyWriter>,
	public IObjectControl,
	public IDispatchImpl<IMTProductViewPropertyWriter, &IID_IMTProductViewPropertyWriter, &LIBID_MTPRODUCTVIEWEXECLib>
{
public:
	CMTProductViewPropertyWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTVIEWPROPERTYWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTProductViewPropertyWriter)

BEGIN_COM_MAP(CMTProductViewPropertyWriter)
	COM_INTERFACE_ENTRY(IMTProductViewPropertyWriter)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTProductViewPropertyWriter
public:
    STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IProductViewProperty* apPVProp, /*[out, retval]*/ long* apID);
    STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IProductViewProperty* apPVProp);
    STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID);
};

#endif //__MTPRODUCTVIEWPROPERTYWRITER_H_
