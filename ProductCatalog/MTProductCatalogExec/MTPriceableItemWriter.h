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


#ifndef __MTPRICEABLEITEMWRITER_H_
#define __MTPRICEABLEITEMWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItemWriter
class ATL_NO_VTABLE CMTPriceableItemWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPriceableItemWriter, &CLSID_MTPriceableItemWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTPriceableItemWriter, &IID_IMTPriceableItemWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTPriceableItemWriter();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRICEABLEITEMWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPriceableItemWriter)

BEGIN_COM_MAP(CMTPriceableItemWriter)
	COM_INTERFACE_ENTRY(IMTPriceableItemWriter)
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

// IMTPriceableItemWriter
public:
	STDMETHOD(CreateTemplate)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTPriceableItem* apPrcItem, /*[out, retval]*/ long* apID);
	STDMETHOD(CreateInstance)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[in]*/ IMTPriceableItem *apPrcItemInst, /*[out, retval]*/ long *apPrcItemInstID);
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTPriceableItem* apPrcItem);
	STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID);
	STDMETHOD(SetPriceListMapping)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemInstanceID, /*[in]*/ long aParamTblDefID, /*[in]*/ long aPrcLstID);
	//STDMETHOD(CreateOrSetAllPriceListMappings)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTPriceableItem* apPrcItemInst, /*[in]*/ long aPrcLstID);

private:
	void CreateChildTemplates(IMTPriceableItem* apPrcItemTmpl);
	void CreateChildInstances(IMTSessionContext* apCtxt, long aProdOffID, IMTPriceableItem* apPrcItemInst);
	void InsertPriceListMapping( long aParamTableDefID, long aProdOffID, IMTPriceableItem* apPrcItemInst);
	void VerifyName(IMTSessionContext* apCtxt, IMTPriceableItem* apPrcItem);
  void CheckValidCycleChange(IMTSessionContext* apCtxt, IMTPriceableItem* apPrcItem);



// data
	CComPtr<IObjectContext> mpObjectContext;

};

#endif //__MTPRICEABLEITEMWRITER_H_
