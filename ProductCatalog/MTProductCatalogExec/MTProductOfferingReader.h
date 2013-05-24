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
* $Header: c:\mainline\development\ProductCatalog\MTProductCatalogExec\MTProductOfferingReader.h, 21, 11/13/2002 6:09:26 PM, Fabricio Pettena$
* 
***************************************************************************/

// MTProductOfferingReader.h : Declaration of the CMTProductOfferingReader

#ifndef __MTPRODUCTOFFERINGREADER_H_
#define __MTPRODUCTOFFERINGREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>
#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF")
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

/////////////////////////////////////////////////////////////////////////////
// CMTProductOfferingReader
class ATL_NO_VTABLE CMTProductOfferingReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTProductOfferingReader, &CLSID_MTProductOfferingReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTProductOfferingReader, &IID_IMTProductOfferingReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTProductOfferingReader();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTOFFERINGREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTProductOfferingReader)

BEGIN_COM_MAP(CMTProductOfferingReader)
	COM_INTERFACE_ENTRY(IMTProductOfferingReader)
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

// IMTProductOfferingReader
public:
	STDMETHOD(GetConstrainedCycleType)(IMTSessionContext* apCTX,long poID,/*[out, retval]*/ MTUsageCycleType* pCycleType);
	STDMETHOD(FindAvailableProductOfferingsAsRowset)(/*[in]*/ IMTSessionContext* apCTX,/*[in,optional]*/ VARIANT aFilter,/*[in,optional]*/ VARIANT aRefDate,/*[out,retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(FindForPrcItemType)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemTypeID, /*[out, retval]*/ IMTCollection** apProdOffs);
	STDMETHOD(GetCurrencyCode)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[out, retval]*/ BSTR* apCurrency);
	STDMETHOD(HasPriceableItemTemplate)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[in]*/ long aPrcItemTmplID, /*[out, retval]*/ VARIANT_BOOL* apHasTmpl);
	STDMETHOD(FindSubscribablePoByAccIDasCollection)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accID, /*[in, optional]*/ VARIANT aRefDate, /*[out, retval]*/ IMTCollection** ppCol);
	STDMETHOD(FindSubscribablePoByAccID)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accID, /*[in, optional]*/ VARIANT aRefDate, /*[out, retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(FindAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in, optional]*/ VARIANT aFilter, /*[out, retval]*/ IMTSQLRowset** apRowset);
	STDMETHOD(FindByName)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ BSTR aName, /*[out, retval]*/ IMTProductOffering** apProdOff);
	STDMETHOD(Find)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long ID, /*[out, retval]*/ IMTProductOffering**);
  STDMETHOD(FindAvailableProductOfferingsForGroupSubscriptionAsRowset)(/*[in]*/ IMTSessionContext* apCTX, /*[in]*/ long corpAccID, /*[in, optional]*/ VARIANT aFilter, /*[in, optional]*/ VARIANT aRefDate, /*[out, retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(FindWithNonSharedPriceList)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long pricelistID, /*[out, retval]*/ IMTProductOffering**);
	STDMETHOD(FindRecurringChargeWithUnitName)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[in]*/ BSTR aUnitName, /*[out, retval]*/ BSTR* apChargeName);
	STDMETHOD(GetNumberOfCycleRelativePrcItems)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long poID, /*[out]*/ long * apDiscounts, /*[out]*/ long * apAggregates, /*[out]*/ long * apRCs);
	STDMETHOD(GetDiscountDistribution)            (/*[in]*/IMTSessionContext* apCtxt, /*[in]*/ long poID, /*[out]*/ long * apNumDistributedDiscounts, /*[out]*/ long * apNumUndistributedDiscounts);
  STDMETHOD(GetSubscribableAccountTypesAsRowset)(/*[in]*/IMTSessionContext* apCtx,/*[in]*/ long poid, /*[out, retval]*/ IMTSQLRowset** apCtxt);

  

protected:
	void PopulateByRowset(long aID,ROWSETLib::IMTSQLRowsetPtr rowset,MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff);


// data
private:
	CComPtr<IObjectContext> mpObjectContext;

};

#endif //__MTPRODUCTOFFERINGREADER_H_
