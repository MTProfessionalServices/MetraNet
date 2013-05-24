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
* $Header: ProductCatalog.h, 47, 10/11/2002 2:52:47 PM, Boris$
* 
***************************************************************************/

#ifndef __MTPRODUCTCATALOG_H_
#define __MTPRODUCTCATALOG_H_

#include "resource.h"       // main symbols
#include "MTPCBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTProductCatalog
class ATL_NO_VTABLE CMTProductCatalog : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTProductCatalog, &CLSID_MTProductCatalog>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTProductCatalog, &IID_IMTProductCatalog, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase
{
	DEFINE_MT_PCBASE_METHODS


public:
	CMTProductCatalog();
	HRESULT FinalConstruct();
	void FinalRelease();


DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTCATALOG)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTProductCatalog)
	COM_INTERFACE_ENTRY(IMTProductCatalog)
	COM_INTERFACE_ENTRY(IMTPCBase)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mpUnkMarshaler.p)
END_COM_MAP()



// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTProductCatalog
public:
	STDMETHOD(GetCounterParameter)(/*[in]*/long aDBID, /*[out, retval]*/IMTCounterParameter** apParam);
	STDMETHOD(FindCounterParametersAsRowset)(/*[in]*/VARIANT aFilter, /*[out, retval]*/IMTRowSet** apRowset);
	STDMETHOD(SubscribeBatch)(long aProductOffering,IMTPCTimeSpan* pTimeSpan,/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress, /*[out]*/ VARIANT_BOOL* pDateModified,/*[in,optional]*/ VARIANT transaction,/*[out,retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(OverrideBusinessRule)(MTPC_BUSINESS_RULE aBusRule,VARIANT_BOOL aVal);
	STDMETHOD(FindAvailableProductOfferingsAsRowset)(/*[in,optional]*/ VARIANT aFilter,/*[in,optional]*/ VARIANT RefDate,/*[out,retval]*/ ::IMTSQLRowset** ppRowset);
  STDMETHOD(FindAvailableProductOfferingsForGroupSubscriptionAsRowset)(/*[in]*/ long corpAccID, /*[in, optional]*/ VARIANT aFilter, /*[in, optional]*/ VARIANT RefDate, /*[out,retval]*/ ::IMTSQLRowset **ppRowset);
	STDMETHOD(GetGroupSubscriptionByCorporateAccount)(/*[in]*/ long aCorporateAccount,/*[out,retval]*/ ::IMTSQLRowset** ppRowset);
	STDMETHOD(GetGroupSubscriptionByID)(/*[in]*/ long aGroupSubID,/*[out,retval]*/ IMTGroupSubscription** ppSub);
	STDMETHOD(GetGroupSubscriptionByName)(DATE RefDate,/*[in]*/ BSTR name,/*[out,retval]*/ IMTGroupSubscription** ppGroupSub);
	STDMETHOD(GetGroupSubscriptionsAsRowset)(/*[in]*/ DATE RefDate,VARIANT aFilter,/*[out,retval]*/ ::IMTSQLRowset** ppRowset);
	STDMETHOD(CreateGroupSubscription)(/*[out, retval]*/ IMTGroupSubscription** ppGroupSub);
	STDMETHOD(ClearCache)();
	STDMETHOD(RemoveCounter)(/*[in]*/long aCounterID);
	STDMETHOD(GetPriceableItemTypeByName)(/*[in]*/ BSTR aName,/*[out,retval]*/ IMTPriceableItemType** apType);
	STDMETHOD(GetCalendar)(/*[in]*/ long aID, /*[out, retval]*/ IMTCalendar ** apCalendar);
	STDMETHOD(GetCalendarByName)(/*[in]*/ BSTR aName, /*[out, retval]*/ IMTCalendar ** apCalendar);
	STDMETHOD(GetCalendarsAsRowset)(/*[out, retval]*/ IMTRowSet ** apRowset);
	STDMETHOD(CreateCalendar)(/*[out, retval]*/ IMTCalendar ** apCalendar);
	STDMETHOD(BulkSubscriptionChange)(/*[in]*/ long aOldPO_id,/*[in]*/ long aNewPO_id,/*[in]*/ VARIANT vtDate,VARIANT_BOOL bNextBillingCycle);
	STDMETHOD(GetCounterPropertyDefinition)(/*[in]*/long aDBID, /*[out, retval]*/IMTCounterPropertyDefinition** apCPD);
	STDMETHOD(GetPriceableItemByName)(BSTR aName, /*[out, retval]*/ IMTPriceableItem * * apPI);
	STDMETHOD(CreateCounter)(/*[in]*/long aTypeID, /*[out, retval]*/IMTCounter** apCounter);
	STDMETHOD(FindPriceListsForMappingAsRowset)(/*[in]*/ long aParamTblDefID, /*[in]*/ long aPrcItemTmplID, /*[in, optional]*/ VARIANT aFilter, /*[out, retval]*/ IMTRowSet** apRowset);
	STDMETHOD(FindPriceListsAsRowset)(/*[in, optional]*/ VARIANT aFilter, /*[out, retval]*/ IMTRowSet** apRowset);
	STDMETHOD(GetPriceListByName)(BSTR aName, IMTPriceList * * apPriceList);
	STDMETHOD(GetPriceList)(long id, /*[out, retval]*/ IMTPriceList * * apPriceList);
	STDMETHOD(RemovePriceList)(long id);
	STDMETHOD(CreatePriceList)(/*[out, retval]*/ IMTPriceList * * apPriceList);
	STDMETHOD(FindPriceableItemsAsRowset)(/*[in, optional]*/ VARIANT aFilter, /*[out, retval]*/ IMTRowSet** apRowset);
	STDMETHOD(GetPriceableItem)(/*[in]*/ long aID, /*[out, retval]*/ IMTPriceableItem** apPrcItem);
	STDMETHOD(RemovePriceableItemType)(/*[in]*/ long aID);
	STDMETHOD(GetPriceableItemTypes)(/*[in, optional]*/ VARIANT aFilter,/*[out, retval]*/ IMTCollection** apColl);
	STDMETHOD(GetPriceableItemType)(/*[in]*/ long aID, /*[out, retval]*/ IMTPriceableItemType** apType);
	STDMETHOD(CreatePriceableItemType)(/*[out, retval]*/ IMTPriceableItemType** apType);
	STDMETHOD(GetMetaData)(/*[in]*/ MTPCEntityType aEntityType, /*[out, retval]*/ IMTPropertyMetaDataSet ** apMetaDataSet);
	STDMETHOD(GetParamTableDefinition)(long id, /*[out, retval]*/ IMTParamTableDefinition * * table);
	STDMETHOD(GetCountersOfType)(/*[in]*/long aTypeDBID, /*[out, retval]*/IMTCollection** apColl);
	STDMETHOD(GetParamTableDefinitionByName)(BSTR name, /*[out, retval]*/ IMTParamTableDefinition * * table);
	STDMETHOD(GetCounter)(/*[in]*/long aDBID, /*[out, retval]*/IMTCounter** apCounter);
	STDMETHOD(GetCounterTypes)(/*[out, retval]*/IMTCollection** apColl);
	STDMETHOD(GetCounterTypeByName)(/*[in]*/BSTR aCounterTypeName,/*[out, retval]*/IMTCounterType** apVal);
	STDMETHOD(GetCounterType)(/*[in]*/long aDBID, /*[out, retval]*/IMTCounterType** apVal);
	STDMETHOD(FindCountersAsRowset)(/*[in]*/VARIANT aFilter, /*[out, retval]*/IMTRowSet** apRowset);
	STDMETHOD(FindProductOfferingsAsRowset)(/*[in, optional]*/ VARIANT apFilter, /*[out, retval]*/ IMTRowSet** apRowset);
	STDMETHOD(RemoveProductOffering)(/*[in]*/ long aID);
	STDMETHOD(CreateProductOffering)(/*[out, retval]*/ IMTProductOffering** apProdOff);
	STDMETHOD(GetProductOffering)(/*[in]*/ long ID, /*[out, retval]*/ IMTProductOffering**);
	STDMETHOD(GetProductOfferingByName)(/*[in]*/ BSTR aName, /*[out, retval]*/ IMTProductOffering**);
	STDMETHOD(GetAccount)(long accountID,IMTPCAccount** ppAccount);
	STDMETHOD(RateAllAggregateCharges)(long aUsageIntervalID, long aSessionSetSize);
	STDMETHOD(RateAllAggregateChargesForAccount)(long aUsageIntervalID, long aAccountID);
	STDMETHOD(RateAllAggregateChargesForAccountAsynch)(long aUsageIntervalID, long aAccountID);
	STDMETHOD(GetPriceableItemInstancesByKind)(MTPCEntityType aKind, /*[out, retval]*/ IMTCollection** apInstances);
	STDMETHOD(GetPricelistChaining)(/*[out, retval]*/ MTPC_PRICELIST_CHAIN_RULE* apChainRule);
	STDMETHOD(IsBusinessRuleEnabled)(/*[in]*/MTPC_BUSINESS_RULE aBusRule,/*[out, retval]*/VARIANT_BOOL* apEnabledFlag);
	STDMETHOD(SetSessionContextAccountID)(/*[in]*/long aAccountID);
  STDMETHOD(DeleteGroupSubscription)(/*[in]*/ long aGroupID);
	STDMETHOD(SubscribeToGroups)(/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress, /*[out]*/ VARIANT_BOOL* pDateModified,/*[in,optional]*/ VARIANT transaction,/*[out,retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(SubscribeAccounts)(/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress, /*[out]*/ VARIANT_BOOL* pDateModified,/*[in,optional]*/ VARIANT transaction,/*[out,retval]*/ IMTRowSet** ppRowset);

//data
private:
	CComPtr<IUnknown> mpUnkMarshaler;
	HRESULT Rate(long aIntervalID, long aAccountID, bool aWaitForCommit, long aSessionSetSize);
};

#endif //__MTPRODUCTCATALOG_H_
