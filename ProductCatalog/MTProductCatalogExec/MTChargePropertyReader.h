// MTChargePropertyReader.h : Declaration of the CMTChargePropertyReader

#ifndef __MTCHARGEPROPERTYREADER_H_
#define __MTCHARGEPROPERTYREADER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTChargePropertyReader
class ATL_NO_VTABLE CMTChargePropertyReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTChargePropertyReader, &CLSID_MTChargePropertyReader>,
	public IObjectControl,
	public IDispatchImpl<IMTChargePropertyReader, &IID_IMTChargePropertyReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTChargePropertyReader();

DECLARE_REGISTRY_RESOURCEID(IDR_MTCHARGEPROPERTYREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTChargePropertyReader)

BEGIN_COM_MAP(CMTChargePropertyReader)
	COM_INTERFACE_ENTRY(IMTChargePropertyReader)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> mpObjectContext;

// IMTChargePropertyReader
public:
	STDMETHOD(Load)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTSQLRowset* apRowset, /*[out, retval]*/ IMTChargeProperty** apChargeProperty);
	STDMETHOD(Find)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aChargePropertyID, /*[out, retval]*/ IMTChargeProperty** apChargeProperty);
};

#endif //__MTCHARGEPROPERTYREADER_H_
