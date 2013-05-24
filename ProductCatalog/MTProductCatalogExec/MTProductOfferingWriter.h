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


#ifndef __MTPRODUCTOFFERINGWRITER_H_
#define __MTPRODUCTOFFERINGWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <IMTAccountType.tlb> rename ("EOF", "RowsetEOF")
#import <MetraTech.Accounts.Type.tlb>  inject_statement("using namespace mscorlib;") inject_statement("using namespace MTAccountTypeLib;") inject_statement("using MTAccountTypeLib::IMTAccountTypePtr;")



/////////////////////////////////////////////////////////////////////////////
// CMTProductOfferingWriter
class ATL_NO_VTABLE CMTProductOfferingWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTProductOfferingWriter, &CLSID_MTProductOfferingWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTProductOfferingWriter, &IID_IMTProductOfferingWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTProductOfferingWriter();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTOFFERINGWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTProductOfferingWriter)

BEGIN_COM_MAP(CMTProductOfferingWriter)
	COM_INTERFACE_ENTRY(IMTProductOfferingWriter)
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

// IMTProductOfferingWriter
public:
	STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTProductOffering* apProdOff, /*[out, retval]*/ long* apID);
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTProductOffering* apProdOff);
	STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID);
  STDMETHOD(AddSubscribableAccountType)(/*[in]*/IMTSessionContext* apCtx,/*[in]*/ long poid, /*[in]*/ IMTAccountType* aType);
  STDMETHOD(RemoveSubscribableAccountType)(/*[in]*/IMTSessionContext* apCtx,/*[in]*/ long poid, /*[in]*/ IMTAccountType* aType);
  //STDMETHOD(AddSubscribableAccountTypeByName)(/*[in]*/IMTSessionContext* apCtx,/*[in]*/ long poid, /*[in]*/ BSTR acctype);
  //STDMETHOD(RemoveSubscribableAccountTypeByName)(/*[in]*/IMTSessionContext* apCtx,/*[in]*/ long poid, /*[in]*/ BSTR acctype);
  STDMETHOD(RemoveSubscribableAccountTypes)(/*[in]*/IMTSessionContext* apCtx,/*[in]*/ long aTypeID);
  STDMETHOD(CheckConfigurationIfSettingAvailabilityDate)(/*[in]*/IMTProductOffering* apProdOff);
private:
	void AddPendingPriceableItems(IMTSessionContext* apCtxt, IMTProductOffering* apProdOff,long aProdOfferringID);
	void VerifyName(IMTSessionContext* apCtxt, IMTProductOffering* apProdOff);
	//void CheckConfigurationIfSettingAvailabilityDate(IMTProductOffering* apProdOff);
	bool IsAvailabilityDateBeingSet(IMTProductOffering* apProdOff);
  void AddSubscribableAccountTypeByName(long poid, /*[in]*/ BSTR acctype);


// data
private:
	CComPtr<IObjectContext> mpObjectContext;

};

#endif //__MTPRODUCTOFFERINGWRITER_H_
