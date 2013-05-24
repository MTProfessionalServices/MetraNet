// MTChargeReader.h : Declaration of the CMTChargeReader

#ifndef __MTCHARGEREADER_H_
#define __MTCHARGEREADER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTChargeReader
class ATL_NO_VTABLE CMTChargeReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTChargeReader, &CLSID_MTChargeReader>,
	public IObjectControl,
	public IDispatchImpl<IMTChargeReader, &IID_IMTChargeReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTChargeReader();

DECLARE_REGISTRY_RESOURCEID(IDR_MTCHARGEREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTChargeReader)

BEGIN_COM_MAP(CMTChargeReader)
	COM_INTERFACE_ENTRY(IMTChargeReader)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> mpObjectContext;

// IMTChargeReader
public:
	STDMETHOD(Load)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTSQLRowset* apRowset, /*[out, retval]*/ IMTCharge** apCharge);
	STDMETHOD(Find)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aChargeID, /*[out, retval]*/ IMTCharge** apCharge);
	STDMETHOD(FindChargeProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aChargeID, /*[out, retval]*/ IMTCollection** apChargeProperties);
};

#endif //__MTCHARGEREADER_H_
