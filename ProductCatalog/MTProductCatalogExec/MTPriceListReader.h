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


#ifndef __MTPRICELISTREADER_H_
#define __MTPRICELISTREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CMTPriceListReader
class ATL_NO_VTABLE CMTPriceListReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPriceListReader, &CLSID_MTPriceListReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTPriceListReader, &IID_IMTPriceListReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTPriceListReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRICELISTREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPriceListReader)

BEGIN_COM_MAP(CMTPriceListReader)
	COM_INTERFACE_ENTRY(IMTPriceListReader)
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

	CComPtr<IObjectContext> mpObjectContext;

// IMTPriceListReader
public:
	STDMETHOD(FindByAccountID)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID,/*[out, retval]*/ IMTPriceList** ppVal);
	STDMETHOD(FindAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aParamTblDefID, /*[in]*/ long aPrcItemTmplID, /*[in, optional]*/ VARIANT aFilter, /*[out, retval]*/ IMTSQLRowset** apRowset);
	STDMETHOD(FindByName)(/*[in]*/ IMTSessionContext* apCtxt, BSTR aName, /*[out, retval]*/ IMTPriceList * * apPriceList);
	STDMETHOD(Find)(/*[in]*/ IMTSessionContext* apCtxt, long aID, /*[out, retval]*/ IMTPriceList * * apPriceList);

private:
	// used by Find and FindByName.
	// throws COM errors
	HRESULT PopulatePriceListObject(IMTSessionContext* apCtxt,
																	ROWSETLib::IMTSQLRowsetPtr aRowset,
																	IMTPriceList **apPriceList);
};

#endif //__MTPRICELISTREADER_H_
