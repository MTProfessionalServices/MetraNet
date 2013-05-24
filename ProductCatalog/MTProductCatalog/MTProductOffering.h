/**************************************************************************
 *
 * Copyright 2001 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Ralf Boeck
 * $Header$
 *
 ***************************************************************************/
  
// MTProductOffering.h : Declaration of the CMTProductOffering

#ifndef __MTPRODUCTOFFERING_H_
#define __MTPRODUCTOFFERING_H_

#include <comdef.h>
#include "resource.h"       // main symbols
#include "PropertiesBase.h"
#include <MTObjectCollection.h>
#include "IMTUsageCycle.h"
//#include "MTProductCatalog.h"

/////////////////////////////////////////////////////////////////////////////
// CMTProductOffering
class ATL_NO_VTABLE CMTProductOffering : 
  public CComObjectRootEx<CComMultiThreadModel>,
  public CComCoClass<CMTProductOffering, &CLSID_MTProductOffering>,
  public ISupportErrorInfo,
  public IDispatchImpl<IMTProductOffering, &IID_IMTProductOffering, &LIBID_MTPRODUCTCATALOGLib>,
  public CMTPCBase,
  public PropertiesBase
{
  DEFINE_MT_PCBASE_METHODS
  DEFINE_MT_PROPERTIES_BASE_METHODS

public:
  CMTProductOffering();
  HRESULT FinalConstruct();
  void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTOFFERING)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTProductOffering)
  COM_INTERFACE_ENTRY(IMTProductOffering)
	COM_INTERFACE_ENTRY(IMTPCBase)
  COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
  COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()

// ISupportsErrorInfo
  STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTProductOffering
public:
  STDMETHOD(CheckValidCycle)(/*[in]*/ IMTPCCycle* apCycle, /*[in]*/ IMTPriceableItem* apInstanceToIgnore);
  STDMETHOD(GroupSubscriptionRequiresCycle)(/*[out,retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(GetConstrainedCycleType)(/*[out, retval]*/ MTUsageCycleType* pCycleType);
  STDMETHOD(GetCountOfActiveSubscriptions)(/*[out, retval]*/ long* apSubCount);
	STDMETHOD(GetCountOfAllSubscriptions)(/*[out, retval]*/ long* apSubCount);
  STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
  STDMETHOD(put_ID)(/*[in]*/ long newVal);
  STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(put_DisplayName)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_DisplayNames)(/*[out, retval]*/ IDispatch **pVal);

  STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_SelfSubscribable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(put_SelfSubscribable)(/*[in]*/ VARIANT_BOOL newVal);
  STDMETHOD(get_SelfUnsubscribable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(put_SelfUnsubscribable)(/*[in]*/ VARIANT_BOOL newVal);
  STDMETHOD(get_EffectiveDate)(/*[out, retval]*/ IMTPCTimeSpan **pVal);
  STDMETHOD(get_AvailabilityDate)(/*[out, retval]*/ IMTPCTimeSpan **pVal);
  STDMETHOD(get_NonSharedPriceListID)(/*[out, retval]*/ long *pVal);
  STDMETHOD(put_NonSharedPriceListID)(/*[in]*/ long newVal);
  STDMETHOD(get_Hidden)(/*[out, retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(put_Hidden)(/*[in]*/ VARIANT_BOOL newVal);
  STDMETHOD(Save)();
  STDMETHOD(AddPriceableItem)(/*[in]*/ IMTPriceableItem* apPrcItemTmpl, /*[out, retval]*/ IMTPriceableItem** apPrcItemInstance);
  STDMETHOD(RemovePriceableItem)(/*[in]*/ long aPrcItemInstanceID);
  STDMETHOD(GetPriceableItem)(/*[in]*/ long aPrcItemInstanceID, /*[out, retval]*/ IMTPriceableItem** apPrcItemInstance);
  STDMETHOD(GetPriceableItemByName)(/*[in]*/ BSTR aName, /*[out, retval]*/ IMTPriceableItem** apPrcItemInstance);
  STDMETHOD(GetPriceableItems)(/*[out, retval]*/ IMTCollection** apPrcItemInstances);
  STDMETHOD(GetPriceableItemsAsRowset)(/*[out, retval]*/ IMTRowSet** apRowset);
  STDMETHOD(GetPriceableItemsOfType)(/*[in]*/ long aPITypeID, /*[out, retval]*/ IMTCollection** apPrcItemInstances);
  STDMETHOD(CanBeModified)(/*[out, optional]*/ VARIANT* apErrors, /*[out, retval]*/ VARIANT_BOOL *apCanBeModifed);
  STDMETHOD(CreateCopy)(/*[in]*/ BSTR aNewName, /*[in]*/ VARIANT aNewCurrency, /*[out, retval]*/ IMTProductOffering** apProdOff);
  STDMETHOD(CheckConfiguration)(/*[out, retval]*/ IMTCollection** apErrors);
  STDMETHOD(GetCurrencyCode)(/*[out, retval]*/ BSTR* apCurrency);
	STDMETHOD(SetCurrencyCode)(/*[in]*/ BSTR aCurrency);
  STDMETHOD(HasAvailabilityDateBeenSet)(/*[out, retval]*/ VARIANT_BOOL *apHasBeenSet);
  STDMETHOD(GetDistributionRequirement)(/*[out, retval]*/ MTDistributionRequirementType* apDistrReq);
	STDMETHOD(MapToNonSharedPL)(/*[in]*/ IMTPriceableItem* apPi);
	STDMETHOD(GetCountOfPriceListMappings)(/*[in]*/ MTPriceListMappingType aType, /*[out, retval]*/ long *apCount);
	STDMETHOD(GetNonSharedPriceList)(/*[out, retval]*/ IMTPriceList** apPriceList);
  STDMETHOD(get_SubscribableAccountTypes)(/*[out, retval]*/ IMTCollection** pVal);

  STDMETHOD(GetSubscribableAccountTypesAsRowset)(/*[out, retval]*/ IMTRowSet** apRowset);
  STDMETHOD(AddSubscribableAccountType)(/*[in]*/ int aTypeID);
  STDMETHOD(RemoveSubscribableAccountType)(/*[in]*/ int aTypeID);
  STDMETHOD(get_DisplayDescriptions)(/*[out, retval]*/ IDispatch **pVal);

  STDMETHOD(CheckCanSave)();
  
  

//CMTPCBase override
  virtual void OnSetSessionContext(IMTSessionContext* apSessionContext);

private:
  MTPRODUCTCATALOGLib::IMTPriceableItemPtr
    FindPrcItemWithIncompatibleCycle(MTPRODUCTCATALOGLib::IMTPCCyclePtr aCycle,
                                     MTPRODUCTCATALOGLib::IMTPriceableItemPtr aInstanceToIgnore = NULL);

  void Validate();
  void CheckConfigurationForPIAndChildren(MTPRODUCTCATALOGLib::IMTPriceableItemPtr aPrcItem,
                                          MTPRODUCTCATALOGLib::IMTCollectionPtr aErrors);

	
//data

  CComPtr<IUnknown> mUnkMarshalerPtr;   // free threaded marshaller

  //if this po has not yet been created, mPrcItemsToAdd holds the PI templates to add on Save()
  MTObjectCollection<IMTPriceableItem> mPrcItemsToAdd;
	_bstr_t nonsharedPLCurrency;
};

#endif //__MTPRODUCTOFFERING_H_
