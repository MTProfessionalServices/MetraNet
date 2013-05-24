// MTChargePropertyWriter.h : Declaration of the CMTChargePropertyWriter

#ifndef __MTCHARGEPROPERTYWRITER_H_
#define __MTCHARGEPROPERTYWRITER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTChargePropertyWriter
class ATL_NO_VTABLE CMTChargePropertyWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTChargePropertyWriter, &CLSID_MTChargePropertyWriter>,
	public IObjectControl,
	public IDispatchImpl<IMTChargePropertyWriter, &IID_IMTChargePropertyWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTChargePropertyWriter();

DECLARE_REGISTRY_RESOURCEID(IDR_MTCHARGEPROPERTYWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTChargePropertyWriter)

BEGIN_COM_MAP(CMTChargePropertyWriter)
	COM_INTERFACE_ENTRY(IMTChargePropertyWriter)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> mpObjectContext;

// IMTChargePropertyWriter
public:
	STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTChargeProperty* apChargeProperty, /*[out, retval]*/ long* apID);
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTChargeProperty* apChargeProperty);
	STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID);
};

#endif //__MTCHARGEPROPERTYWRITER_H_
