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


#ifndef __MTACCOUNTWRITER_H_
#define __MTACCOUNTWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTAccountWriter
class ATL_NO_VTABLE CMTAccountWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAccountWriter, &CLSID_MTAccountWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTAccountWriter, &IID_IMTAccountWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTAccountWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTAccountWriter)

BEGIN_COM_MAP(CMTAccountWriter)
	COM_INTERFACE_ENTRY(IMTAccountWriter)
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

	CComPtr<IObjectContext> m_spObjectContext;

// IMTAccountWriter
public:
	STDMETHOD(UpdateICBPriceList)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID,/*[in]*/ long PriceListID);
	STDMETHOD(UpdateDefaultPricelist)(/*[in]*/ IMTSessionContext* apCtxt, long accountID,long PriceListID);
};

#endif //__MTACCOUNTWRITER_H_
