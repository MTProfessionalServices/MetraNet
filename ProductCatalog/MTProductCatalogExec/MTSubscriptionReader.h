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

#ifndef __MTSUBSCRIPTIONREADER_H_
#define __MTSUBSCRIPTIONREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF")
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

/////////////////////////////////////////////////////////////////////////////
// CMTSubscriptionReader
class ATL_NO_VTABLE CMTSubscriptionReader : 
  public CComObjectRootEx<CComSingleThreadModel>,
  public CComCoClass<CMTSubscriptionReader, &CLSID_MTSubscriptionReader>,
  public ISupportErrorInfo,
  public IObjectControl,
  public IDispatchImpl<IMTSubscriptionReader, &IID_IMTSubscriptionReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
  CMTSubscriptionReader()
  {
  }

DECLARE_REGISTRY_RESOURCEID(IDR_MTSUBSCRIPTIONREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTSubscriptionReader)

BEGIN_COM_MAP(CMTSubscriptionReader)
  COM_INTERFACE_ENTRY(IMTSubscriptionReader)
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

// IMTSubscriptionReader
public:
  STDMETHOD(GetGroupSubscriptionsWithCycleConflictsAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[in]*/ long aCycleTypeID, /*[out, retval]*/ IMTSQLRowset **apRowset);
  STDMETHOD(GetCountOfSubscribersWithCycleConflicts)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[in]*/ IMTPCCycle* apCycle, /*[out, retval]*/ long *apSubCount);
  STDMETHOD(GetAccountSubscriptionsAsRowset)(IMTSessionContext* apCTX,long aAccountID,IMTRowSet** ppRowset);
  STDMETHOD(GetAccountGroupSubscriptionsAsRowset)(IMTSessionContext* apCTX,long aAccountID,IMTRowSet** ppRowset);
  STDMETHOD(GetSubParamTablesAsRowset)(/*[in]*/ IMTSessionContext* apCTX,/*[in]*/ long aSubID, IMTSQLRowset** ppRowset);
  STDMETHOD(FindMember)(/*[in]*/ IMTSessionContext* pCtx,/*[in]*/ long aAccountID,long gSubID,DATE RefDate,/*[out,retval]*/ IMTGSubMember** ppMember);
  STDMETHOD(GetGroupSubscriptionByID)(/*[in]*/ IMTSessionContext* apSession,/*[in]*/ long aGroupSubID,/*[out,retval]*/ IMTGroupSubscription** ppGroupSub);
  STDMETHOD(GetGroupSubscriptionByCorporateAccount)(/*[in]*/ long aCorporateAccount,/*[out, retval]*/ IMTSQLRowset** ppRowset);
  STDMETHOD(GetGroupSubscriptionByName)(/*[in]*/ IMTSessionContext* apSession,DATE RefDate,/*[in]*/ BSTR name,/*[out,retval]*/ IMTGroupSubscription** ppGroupSub);
  STDMETHOD(GetGroupSubscriptionMembers)(IMTSessionContext *apSession,/*[in]*/ DATE RefDate,/*[in]*/ long aGroupSubId,/*[in,optional]*/ DATE aSystemDate,/*[out, retval]*/ IMTGroupSubSlice** ppSlice);
  STDMETHOD(GetGroupSubscriptionsAsRowset)(IMTSessionContext* apCtxt,/*[in]*/ DATE RefDate,/*[in,optional]*/ VARIANT aFilter,/*[out,retval]*/ IMTSQLRowset** ppRowset);
  STDMETHOD(GetSubscriptionByID)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long sub_id,/*[out,retval]*/ IMTSubscriptionBase** ppSub);
  STDMETHOD(GetSubscriptionByPIType)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID,/*[in]*/ long pi_type_id,/*[out, retval]*/ IMTSubscription** ppSub);
  STDMETHOD(GetSubscriptionsByPIAsCollection)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID,/*[in]*/ long pi_type_id,/*[out, retval]*/ IMTCollection** ppSubs);
  STDMETHOD(GetSubscriptionsByPO)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID,/*[in]*/ long PO_ID,/*[out, retval]*/ IMTSubscription** ppSub);
  STDMETHOD(GetSubscriptionsByPOAsCollection)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID,/*[in]*/ long PO_ID,/*[out, retval]*/ IMTCollection** ppSubs);
  STDMETHOD(GetSubParamTables)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID,/*[out, retval]*/ IMTSQLRowset** ppRowset);
  STDMETHOD(GetInActiveSubscriptionsByAccIDAsCollection)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID,/*[out, retval]*/ IMTCollection** ppCol);
  STDMETHOD(GetActiveSubscriptionsByAccIDAsCollection)(/*[in]*/ IMTSessionContext* apCtxt, long accountID,/*[out, retval]*/ IMTCollection** ppCol);
  STDMETHOD(GetInActiveSubscriptionsByAccID)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID,/*[out, retval]*/ IMTSQLRowset** ppRowset);
  STDMETHOD(GetActiveSubscriptionsByAccID)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID,/*[out, retval]*/ IMTSQLRowset** ppRowset);
  STDMETHOD(GetCountOfActiveSubscriptionsByPO)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[out, retval]*/ long* apSubCount);
  STDMETHOD(SubscriberCanChangeBillingCycles)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID, /*[out, retval]*/ VARIANT_BOOL * pCanChange);
	STDMETHOD(GetCountOfAllSubscriptionsByPO)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[out, retval]*/ long* apSubCount);
	STDMETHOD(GetChargeAccount)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aGroupSubID, /*[in]*/ long aPrcItemInstanceID, /*[in]*/ DATE aEffDate, /*[out, retval]*/ long* apAccountID);
	STDMETHOD(GetRecurringChargeAccountsAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aGroupSubID, /*[in]*/ DATE aEffDate, /*[out, retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(GetPerSubscriptionChargesAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPOID, /*[out, retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(GetUnitValue)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aGroupSubID, /*[in]*/ long aPrcItemInstanceID, /*[in]*/ DATE aEffDate, /*[out, retval]*/ DECIMAL * apValue);
	STDMETHOD(GetUnitValuesAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aGroupSubID, /*[out, retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(GetUnitValuesForChargeAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aGroupSubID, /*[in]*/ long aPrcItemInstanceID, /*[out, retval]*/ IMTSQLRowset** ppRowset);
	STDMETHOD(GetAccountSubscriptions)(IMTSessionContext* apCTX, long aAccountID, IMTCollection** ppColl);
  STDMETHOD(GetAccountGroupSubscriptions)(IMTSessionContext* apCTX, long aAccountID, IMTCollection** ppColl);
	STDMETHOD(get_WarnOnEBCRStartDateChange)(long subID, VARIANT_BOOL *pVal);
	STDMETHOD(WarnOnEBCRMemberStartDateChange)(long subID, long accountID, VARIANT_BOOL *pVal);
  STDMETHOD(GetAvailableGroupSubscriptionByCorporateAccount)(IMTSessionContext* apCtxt, IMTYAAC* apYAAC, IMTSQLRowset **ppRowset);
  

  

protected:
  HRESULT GetSubscriptionsInternal(IMTSessionContext* apCtxt, long accountID,IMTSQLRowset** ppRowset,const char* pActiveStr);
  void PopulateSubscriptionByRowset(MTPRODUCTCATALOGLib::IMTSubscriptionPtr sub,
                               ROWSETLib::IMTSQLRowsetPtr rowset);
  HRESULT GetSubscriptionsByAccIdAsCollectionInternal(IMTSessionContext* apCtxt, long accountID,IMTCollection **ppCol,bool bActive);
  void InternalPopulateGroupSubscription(IMTSessionContext *apSession,ROWSETLib::IMTSQLRowsetPtr rowset,IMTGroupSubscription **ppGroupSub);
  void InternalGetPOExtendedProperties(_bstr_t& selectList,_bstr_t& joinList);

};

#endif //__MTSUBSCRIPTIONREADER_H_
