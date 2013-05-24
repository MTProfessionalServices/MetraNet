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


#ifndef __MTPRICELISTWRITER_H_
#define __MTPRICELISTWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTPriceListWriter
class ATL_NO_VTABLE CMTPriceListWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPriceListWriter, &CLSID_MTPriceListWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTPriceListWriter, &IID_IMTPriceListWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTPriceListWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRICELISTWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPriceListWriter)

BEGIN_COM_MAP(CMTPriceListWriter)
	COM_INTERFACE_ENTRY(IMTPriceListWriter)
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

// IMTPriceListWriter
public:
	STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, long aID);
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, IMTPriceList * apList);
	STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, IMTPriceList * apList, /*[out, retval]*/ long * apID);

private:
	void VerifyName(IMTSessionContext * apCtxt, IMTPriceList *apList);
	void CheckAccountState(IMTSessionContext *apCtx,long AccountID);

	//data
	CComPtr<IObjectContext> mpObjectContext;

};

#endif //__MTPRICELISTWRITER_H_
