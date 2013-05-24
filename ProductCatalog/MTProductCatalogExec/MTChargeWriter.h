// MTChargeWriter.h : Declaration of the CMTChargeWriter

#ifndef __MTCHARGEWRITER_H_
#define __MTCHARGEWRITER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTChargeWriter
class ATL_NO_VTABLE CMTChargeWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTChargeWriter, &CLSID_MTChargeWriter>,
	public IObjectControl,
	public IDispatchImpl<IMTChargeWriter, &IID_IMTChargeWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTChargeWriter();

DECLARE_REGISTRY_RESOURCEID(IDR_MTCHARGEWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTChargeWriter)

BEGIN_COM_MAP(CMTChargeWriter)
	COM_INTERFACE_ENTRY(IMTChargeWriter)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> mpObjectContext;

// IMTChargeWriter
public:
	STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTCharge* apCharge, /*[out, retval]*/ long* apID);
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTCharge* apCharge);
	STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID);
};

#endif //__MTCHARGEWRITER_H_
