/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/


#ifndef __MTPRICEABLEITEMTYPEWRITER_H_
#define __MTPRICEABLEITEMTYPEWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItemTypeWriter
class ATL_NO_VTABLE CMTPriceableItemTypeWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPriceableItemTypeWriter, &CLSID_MTPriceableItemTypeWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTPriceableItemTypeWriter, &IID_IMTPriceableItemTypeWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTPriceableItemTypeWriter();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRICEABLEITEMTYPEWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPriceableItemTypeWriter)

BEGIN_COM_MAP(CMTPriceableItemTypeWriter)
	COM_INTERFACE_ENTRY(IMTPriceableItemTypeWriter)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

// IMTPriceableItemTypeWriter
public:
	STDMETHOD(RemoveCharge)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemTypeID, /*[in]*/ long aChargeID);
	STDMETHOD(AddCharge)(/*[in]*/ IMTSessionContext *apCtxt, /*[in]*/ long aPrcItemTypeID, /*[in]*/ long aChargeID);
	STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTPriceableItemType* apType, /*[out, retval]*/ long* apID);
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTPriceableItemType* apType);
	STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID);
	STDMETHOD(AddParamTableDefinition)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemTypeID, /*[in]*/ long aParamTblDefID);
	STDMETHOD(RemoveParamTableDefinition)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemTypeID, /*[in]*/ long aParamTblDefID);

private:
	void VerifyName(IMTSessionContext* apCtxt, IMTPriceableItemType* apType);


// data
	CComPtr<IObjectContext> mpObjectContext;

};

#endif //__MTPRICEABLEITEMTYPEWRITER_H_
