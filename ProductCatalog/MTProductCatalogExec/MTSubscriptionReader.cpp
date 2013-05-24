/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header: MTSubscriptionReader.cpp, 31, 10/31/2002 4:38:44 PM, David Blair$
* 
***************************************************************************/

#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTSubscriptionReader.h"

#include <metra.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <mtautocontext.h>
#include <MTObjectCollection.h>
#include <mtglobal_msg.h>
#include <formatdbvalue.h>
#include <AccHierarchiesShared.h>
#include <mttime.h>


/////////////////////////////////////////////////////////////////////////////
// CMTSubscriptionReader

/******************************************* error interface ***/
STDMETHODIMP CMTSubscriptionReader::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTSubscriptionReader
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (::InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

HRESULT CMTSubscriptionReader::Activate()
{
  HRESULT hr = GetObjectContext(&m_spObjectContext);
  if (SUCCEEDED(hr))
    return S_OK;
  return hr;
} 

BOOL CMTSubscriptionReader::CanBePooled()
{
  return TRUE;
} 

void CMTSubscriptionReader::Deactivate()
{
  m_spObjectContext.Release();
} 

void CMTSubscriptionReader::InternalGetPOExtendedProperties(_bstr_t& selectList,_bstr_t& joinList)
{
  BSTR pSelectList,pJoinList;
  MTPRODUCTCATALOGLib::IMTProductCatalogPtr aProductCatalog(__uuidof(MTProductCatalog));
  aProductCatalog->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING)->
    GetPropertySQL("t_po.id_po", L"", VARIANT_FALSE, // VARIANT_FALSE means all extended properties
                   &pSelectList,&pJoinList);


  selectList = _bstr_t(pSelectList, false);
  joinList = _bstr_t(pJoinList, false);
}

// ----------------------------------------------------------------
// Name: GetSubscriptionsInternal     
// Arguments:  accountID,rowset, active string   
//                
// Return Value:  
// Errors Raised: 
// Description:   Runs the query that returns a list of subscriptions 
// based on the active flag
// ----------------------------------------------------------------

HRESULT CMTSubscriptionReader::GetSubscriptionsInternal(IMTSessionContext* apCtxt,
                                                        long accountID,
                                                        IMTSQLRowset** ppRowset,
                                                        const char* pActiveStr)
{
  MTAutoContext context(m_spObjectContext);

  try {
    _bstr_t selectlist,joinlist;
    InternalGetPOExtendedProperties(selectlist,joinlist);

    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr contextPtr(apCtxt);


    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_ACTIVE_SUBSCRIPTIONS__");
    rowset->AddParam("%%ID_ACC%%",accountID);
    rowset->AddParam("%%ACTIVE%%",pActiveStr);
    rowset->AddParam("%%COLUMNS%%",selectlist);
    rowset->AddParam("%%JOINS%%",joinlist);
    rowset->AddParam("%%ID_LANG%%", contextPtr->GetLanguageID());
    rowset->Execute();

    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach()); 

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;

}

// ----------------------------------------------------------------
// Name:  GetActiveSubscriptionsByAccID     
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description: Return all active subscriptions
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetActiveSubscriptionsByAccID(IMTSessionContext* apCtxt, long accountID, IMTSQLRowset **ppRowset)
{
  ASSERT(ppRowset);
  if(!ppRowset) return E_POINTER;
  return GetSubscriptionsInternal(apCtxt, accountID,ppRowset,"Y");
}

// ----------------------------------------------------------------
// Name: GetInActiveSubscriptionsByAccID      
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   return inactive subscriptions
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetInActiveSubscriptionsByAccID(IMTSessionContext* apCtxt, long accountID, IMTSQLRowset **ppRowset)
{
  ASSERT(ppRowset);
  if(!ppRowset) return E_POINTER;
  return GetSubscriptionsInternal(apCtxt, accountID,ppRowset,"N");
}

// ----------------------------------------------------------------
// Name: PopulateSubscriptionByRowset     
// Arguments: subscription smart pointer, rowset  
//                
// Return Value:  
// Errors Raised: 
// Description:   Populates a single subscription object by with a rowset
// ----------------------------------------------------------------
void CMTSubscriptionReader::PopulateSubscriptionByRowset(MTPRODUCTCATALOGLib::IMTSubscriptionPtr sub,
                                                         ROWSETLib::IMTSQLRowsetPtr rowset)
{
  /// XXX Error handling?


//  t_sub.id_sub,t_sub.id_acc,t_sub.id_po,t_sub.id_eff_date,t_sub.b_active,
//  te.n_begintype,te.dt_start,te.n_beginoffset,te.n_endtype,te.dt_end,te.n_endoffset

  // step 1: create an effective date object and populate it
  MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr timespan(__uuidof(MTPCTimeSpan));

  sub->PutEffectiveDate(timespan);


	// start and end information
	sub->GetEffectiveDate()->PutStartDate(rowset->GetValue("vt_start"));
	sub->GetEffectiveDate()->PutEndDate(rowset->GetValue("vt_end"));
	sub->PutID(rowset->GetValue("id_sub"));

  // step 2: set the account ID
  sub->PutAccountID(rowset->GetValue("id_acc"));
  // step 3: set the product offering ID
  sub->PutProductOfferingID(rowset->GetValue("id_po"));

  _bstr_t tempExternalID;
  MTMiscUtil::GuidToString(rowset->GetValue("id_sub_ext"),tempExternalID);
  sub->PutExternalIdentifier(tempExternalID);

}
// ----------------------------------------------------------------
// Name:    GetSubscriptionsByAccIdAsCollectionInternal   
// Arguments:   accountID,collection interface  
//                
// Return Value:  S_OK,E_FAIL
// Errors Raised: 
// Description:   Get all the active subscriptions and return as a collection of
// IMTSubscription interface pointers
// ----------------------------------------------------------------


HRESULT CMTSubscriptionReader::GetSubscriptionsByAccIdAsCollectionInternal(IMTSessionContext* apCtxt, 
                                                                           long accountID,
                                                                           IMTCollection **ppCol,
                                                                           bool bActive)
{
  ASSERT(ppCol);
  if(!ppCol) return E_POINTER;
  HRESULT hr;

  MTAutoContext context(m_spObjectContext);
  MTObjectCollection<IMTSubscription> coll;

  try {
    // step 1: find all the active subscriptions
    ROWSETLib::IMTSQLRowset* pRowset;

    if(bActive) {
      hr = GetActiveSubscriptionsByAccID(apCtxt, accountID,reinterpret_cast<IMTSQLRowset**>(&pRowset));
    }
    else {
      hr = GetInActiveSubscriptionsByAccID(apCtxt, accountID,reinterpret_cast<IMTSQLRowset**>(&pRowset));
    }

    if(SUCCEEDED(hr)) {
      // attach smart pointer
      ROWSETLib::IMTSQLRowsetPtr rowset(pRowset,false); // don't addref
      // step 2: iterate the list
      while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE) {
        MTPRODUCTCATALOGLib::IMTSubscriptionPtr sub(__uuidof(MTSubscription));
        // step 3: populate the subscription
        PopulateSubscriptionByRowset(sub,rowset);

        // step 4: add to the collection
        coll.Add( (IMTSubscription*) sub.GetInterfacePtr());
        rowset->MoveNext();
      }
    }
    else {
      return Error("failed to find active subscriptions");
    }
    // step 5: return the collection
    coll.CopyTo(ppCol);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  context.Complete();
  return S_OK;
}


STDMETHODIMP CMTSubscriptionReader::GetActiveSubscriptionsByAccIDAsCollection(IMTSessionContext* apCtxt, long accountID,IMTCollection **ppCol)
{
  return GetSubscriptionsByAccIdAsCollectionInternal(apCtxt, accountID,ppCol,true);
}

STDMETHODIMP CMTSubscriptionReader::GetInActiveSubscriptionsByAccIDAsCollection(IMTSessionContext* apCtxt, long accountID, IMTCollection **ppCol)
{
  return GetSubscriptionsByAccIdAsCollectionInternal(apCtxt, accountID,ppCol,false);
  return S_OK;
}

// ----------------------------------------------------------------
// Name:      
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetSubParamTables(IMTSessionContext* apCtxt, long accountID, IMTSQLRowset **ppRowset)
{
  MTAutoContext context(m_spObjectContext);

  try {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_SUB_PARAMTABLES__");
    rowset->AddParam("%%ID_ACC%%",accountID);
    rowset->Execute();
    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach()); 
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

// ----------------------------------------------------------------
// Name:      
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetSubscriptionsByPO(IMTSessionContext* apCtxt, long accountID, long PO_ID, IMTSubscription **ppSub)
{
  MTAutoContext context(m_spObjectContext);

  try {

    // step 1: populate and execute query
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_SUBSCRIPTIONS_BY_PO__");
    rowset->AddParam("%%ID_ACC%%",accountID);
    rowset->AddParam("%%ID_PO%%",PO_ID);
    rowset->Execute();

    if(rowset->GetRecordCount() > 0) {
      MTPRODUCTCATALOGLib::IMTSubscriptionPtr sub(__uuidof(MTSubscription));
      sub->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

      PopulateSubscriptionByRowset(sub,rowset);

      // step 2: populate subscription object
      *ppSub = reinterpret_cast<IMTSubscription*>(sub.Detach()); 
    }
    else {
      *ppSub = NULL;
    }
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

// ----------------------------------------------------------------
// Name:    GetSubscriptionsByPOAsCollection
// Arguments:   accountID,collection interface  
//                
// Return Value:  S_OK,E_FAIL
// Errors Raised: 
// Description:   Get all the subscriptions to a product offering and return as a collection of
// IMTSubscription interface pointers
// ----------------------------------------------------------------


HRESULT CMTSubscriptionReader::GetSubscriptionsByPOAsCollection(IMTSessionContext* apCtxt, 
																																long accountID,
																																long PO_ID,
																																IMTCollection **ppCol)
{
  ASSERT(ppCol);
  if(!ppCol) return E_POINTER;

  MTAutoContext context(m_spObjectContext);
  MTObjectCollection<IMTSubscription> coll;

  try {
    // step 1: populate and execute query
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_SUBSCRIPTIONS_BY_PO__");
    rowset->AddParam("%%ID_ACC%%",accountID);
    rowset->AddParam("%%ID_PO%%",PO_ID);
    rowset->Execute();

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE) {
			MTPRODUCTCATALOGLib::IMTSubscriptionPtr sub(__uuidof(MTSubscription));
			PopulateSubscriptionByRowset(sub,rowset);

			coll.Add( (IMTSubscription*) sub.GetInterfacePtr());
			rowset->MoveNext();
    }

    coll.CopyTo(ppCol);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  context.Complete();
  return S_OK;
}


// ----------------------------------------------------------------
// Name:      
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetSubscriptionByPIType(IMTSessionContext* apCtxt, long accountID, long pi_type_id, IMTSubscription **ppSub)
{
  MTAutoContext context(m_spObjectContext);

  try {

    // step 1: populate and execute query
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_SUBSCRIPTIONS_BY_PI_TYPE__");
    rowset->AddParam("%%ID_ACC%%",accountID);
    rowset->AddParam("%%ID_PI_TYPE%%",pi_type_id);
    rowset->Execute();


    if(rowset->GetRecordCount() > 0) {
      MTPRODUCTCATALOGLib::IMTSubscriptionPtr sub(__uuidof(MTSubscription));
      sub->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

      PopulateSubscriptionByRowset(sub,rowset);

      // step 2: populate subscription object
      *ppSub = reinterpret_cast<IMTSubscription*>(sub.Detach()); 
    }
    else {
      *ppSub = NULL;
    }
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

// ----------------------------------------------------------------
// Name:      
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetSubscriptionsByPIAsCollection(IMTSessionContext* apCtxt, long accountID, long PI_ID, IMTCollection **ppCol)
{
  ASSERT(ppCol);
  if(!ppCol) return E_POINTER;

  MTAutoContext context(m_spObjectContext);
  MTObjectCollection<IMTSubscription> coll;

  try {
    // step 1: populate and execute query
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_SUBSCRIPTIONS_BY_PI_TEMPLATE__");
    rowset->AddParam("%%ID_ACC%%",accountID);
    rowset->AddParam("%%ID_PI%%",PI_ID);
    rowset->Execute();

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE) {
			MTPRODUCTCATALOGLib::IMTSubscriptionPtr sub(__uuidof(MTSubscription));
			PopulateSubscriptionByRowset(sub,rowset);

			coll.Add( (IMTSubscription*) sub.GetInterfacePtr());
			rowset->MoveNext();
    }

    coll.CopyTo(ppCol);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  context.Complete();
  return S_OK;
}

// ----------------------------------------------------------------
// Name:      
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetSubscriptionByID(IMTSessionContext* apCtxt,
                                                        long sub_id,
                                                        IMTSubscriptionBase **ppSub)
{
  MTAutoContext context(m_spObjectContext);

  try {

    // step 1: populate and execute query
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_SUB_BY_ID__");
    rowset->AddParam("%%ID_SUB%%",sub_id);
    rowset->Execute();

    if(rowset->GetRecordCount() > 0) {

      MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr pRetValPtr;

      _variant_t vtVal = rowset->GetValue("id_group");
      if(vtVal.vt == VT_NULL) {
        MTPRODUCTCATALOGLib::IMTSubscriptionPtr sub(__uuidof(MTSubscription));
        sub->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));
        PopulateSubscriptionByRowset(sub,rowset);

       pRetValPtr = sub; // QI
      }
      else {
        MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr pGroupSub;
        InternalPopulateGroupSubscription(apCtxt,rowset,reinterpret_cast<IMTGroupSubscription**>(&pGroupSub));
        pRetValPtr = pGroupSub; // QI
      }

      // step 2: populate subscription object
      *ppSub = reinterpret_cast<IMTSubscriptionBase*>(pRetValPtr.Detach()); 
    }
    else {
      *ppSub = NULL;
    }
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

// ----------------------------------------------------------------
// Name: GetCountOfActiveSubscriptionsByPO
// Arguments: long aProdOffID as the product offering ID
//                
// Return Value: apSubCount as the number of active subscriptions for that product offering
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------
STDMETHODIMP CMTSubscriptionReader::GetCountOfActiveSubscriptionsByPO(IMTSessionContext* apCtxt, long aProdOffID, long *apSubCount)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    if (!apSubCount)
      return E_POINTER;
    
    *apSubCount = 0;

    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_SUB_COUNT_BY_PO__");
    rowset->AddParam("%%ID_PO%%", aProdOffID);
    rowset->Execute();

    *apSubCount = rowset->GetValue(0L);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

// ----------------------------------------------------------------
// Name: GetCountOfAllSubscriptionsByPO
// Arguments: long aProdOffID as the product offering ID 
//                
// Return Value: apSubCount as the total number of subscriptions that were ever done on that product offering
// Errors Raised: none
// Description:   
// ----------------------------------------------------------------
STDMETHODIMP CMTSubscriptionReader::GetCountOfAllSubscriptionsByPO(IMTSessionContext* apCtxt, long aProdOffID, long *apSubCount)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    if (!apSubCount)
      return E_POINTER;
    
    *apSubCount = 0;

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_ALL_SUB_COUNT_BY_PO__");
    rowset->AddParam("%%ID_PO%%", aProdOffID);
    rowset->Execute();

    *apSubCount = rowset->GetValue(0L);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTSubscriptionReader::SubscriberCanChangeBillingCycles(IMTSessionContext* apCtxt, 
                                                                     /*[in]*/ long accountID,
                                                                     /*[out, retval]*/ VARIANT_BOOL * pCanChange)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    if (PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Account_CheckBillingCycleChange))
    {
      if (!pCanChange)
        return E_POINTER;

      // get the number of priceable items that have "constrained" billing cycles
      ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
      rowset->Init(CONFIG_DIR);
      rowset->SetQueryTag("__GET_CONSTRAINED_PI_COUNT_FOR_ACCOUNT__");
      rowset->AddParam("%%ID_ACC%%", accountID);
      rowset->Execute();

      long count = rowset->GetValue(0L);

      // if there are any then the user can't change their billing cycle
      *pCanChange = (count == 0) ? VARIANT_TRUE : VARIANT_FALSE;
    }
    else
      // if the business rule is not in effect then always allow them to change
      // billing cycles
      *pCanChange = VARIANT_TRUE;
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetGroupSubscriptionsAsRowset(IMTSessionContext* apCtxt,
                                                                  DATE RefDate,
                                                                  VARIANT aFilter,
                                                                  IMTSQLRowset **ppRowset)
{
  MTAutoContext context(m_spObjectContext);

  try {
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter = 
      pc->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_GROUPSUBSCRIPTION)->TranslateFilter(aFilter);
    _bstr_t filter;
    if (aDataFilter != NULL)
    {
      filter = aDataFilter->FilterString;
      if (filter.length() > 0) 
      {
        filter = _bstr_t(L" AND ") + filter;
      }
    }

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(ACC_HIERARCHIES_QUERIES);
    rowset->SetQueryTag("__FIND_GROUP_SUBS_BY_DATE_RANGE__");

    wstring aValue;
    FormatValueForDB(_variant_t(RefDate,VT_DATE),FALSE,aValue);
    rowset->AddParam("%%TIMESTAMP%%",aValue.c_str(),VARIANT_TRUE);
    rowset->AddParam("%%FILTERS%%",filter,VARIANT_TRUE);
    rowset->Execute();
    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error& err) {
    return ReturnComError(err);
  }

  return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetGroupSubscriptionMembers(IMTSessionContext *apSession,
                                                                DATE RefDate, long aGroupSubId, 
                                                                DATE aSystemDate, IMTGroupSubSlice **ppSlice)
{
  MTAutoContext context(m_spObjectContext);

  try {
    // XXX support bitemporal stuff here eventually

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init("queries\\__FIND_GSUB_MEMBERS__");
    rowset->SetQueryTag("__FIND_GROUP_SUBS_BY_NAME__");

    wstring aValue;
    FormatValueForDB(_variant_t(RefDate,VT_DATE),FALSE,aValue);
    rowset->AddParam("%%TIMESTAMP%%",aValue.c_str(),VARIANT_TRUE);
    rowset->AddParam("%%ID_GROUP%%",aGroupSubId);
    rowset->Execute();
  }
  catch (_com_error& err) {
    return ReturnComError(err);
  }

  return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetGroupSubscriptionByName(IMTSessionContext *apSession,
                                                               DATE RefDate,
                                                               BSTR aName,
                                                               IMTGroupSubscription **ppGroupSub)
{
  MTAutoContext context(m_spObjectContext);

  try {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(ACC_HIERARCHIES_QUERIES);
    rowset->SetQueryTag("__FIND_GROUP_SUBS_BY_NAME__");

    wstring aValue;
    FormatValueForDB(_variant_t(RefDate,VT_DATE),FALSE,aValue);

    rowset->AddParam("%%TIMESTAMP%%",aValue.c_str(),VARIANT_TRUE);
    rowset->AddParam("%%NAME%%",aName);
    rowset->Execute();

    if(rowset->GetRecordCount() == 0) {
      MT_THROW_COM_ERROR(MT_GROUPSUB_NOT_FOUND);
    }
    InternalPopulateGroupSubscription(apSession,rowset,ppGroupSub);

  }
  catch (_com_error& err) {
    return ReturnComError(err);
  }

  return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetGroupSubscriptionByID(IMTSessionContext *apSession, long aGroupSubID, IMTGroupSubscription **ppGroupSub)
{
  try {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(ACC_HIERARCHIES_QUERIES);
    rowset->SetQueryTag("__FIND_GROUP_SUB_BY_ID__");
    rowset->AddParam("%%GROUPID%%",aGroupSubID);
    rowset->Execute();

    InternalPopulateGroupSubscription(apSession,rowset,ppGroupSub);

  }
  catch(_com_error& err) {
    return ReturnComError(err);
  }
  return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

void CMTSubscriptionReader::InternalPopulateGroupSubscription(IMTSessionContext *apSession,
                                                              ROWSETLib::IMTSQLRowsetPtr rowset,
                                                              IMTGroupSubscription **ppGroupSub)
{
  if(rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
    MT_THROW_COM_ERROR(MT_GROUP_SUBSCRIPTION_DOES_NOT_EXIST);
  MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr groupSub(__uuidof(MTPRODUCTCATALOGLib::MTGroupSubscription));
	groupSub->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apSession));
	groupSub->PutID(rowset->GetValue("id_sub"));
  
  _bstr_t tempExternalID;
  MTMiscUtil::GuidToString(rowset->GetValue("id_sub_ext"),tempExternalID);
	groupSub->PutExternalIdentifier(tempExternalID);
	groupSub->PutGroupID(rowset->GetValue("id_group"));
	groupSub->PutProductOfferingID(rowset->GetValue("id_po"));

	MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr effDate(__uuidof(MTPRODUCTCATALOGLib::MTPCTimeSpan));

	groupSub->PutEffectiveDate(effDate);
	effDate->PutStartDate(rowset->GetValue("vt_start"));
	effDate->PutEndDate(rowset->GetValue("vt_end"));

	MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle(__uuidof(MTPRODUCTCATALOGLib::MTPCCycle));
	groupSub->PutCycle(cycle);
	cycle->PutCycleID(rowset->GetValue("usage_cycle"));
	cycle->ComputePropertiesFromCycleID();

	groupSub->PutName(_bstr_t(rowset->GetValue("tx_name")));
  _variant_t vDesc = rowset->GetValue("tx_desc");
  if(vDesc.vt == VT_BSTR) {
	  groupSub->PutDescription(_bstr_t(vDesc));
  }

	groupSub->PutProportionalDistribution(_bstr_t(rowset->GetValue("b_proportional")) == _bstr_t("Y")
		? VARIANT_TRUE : VARIANT_FALSE);
  groupSub->PutSupportGroupOps(_bstr_t(rowset->GetValue("b_supportgroupops")) == _bstr_t("Y")
    ? VARIANT_TRUE : VARIANT_FALSE);

  groupSub->PutCorporateAccount(rowset->GetValue("corporate_account"));

  if(groupSub->GetProportionalDistribution() == VARIANT_FALSE) {
    groupSub->PutDistributionAccount(rowset->GetValue("discount_account"));
  }
  
  try
  {
    groupSub->PutHasRecurringCharges(_bstr_t(rowset->GetValue("b_RecurringCharge")) == _bstr_t("Y")
      ? VARIANT_TRUE : VARIANT_FALSE);

    groupSub->PutHasDiscounts(_bstr_t(rowset->GetValue("b_Discount")) == _bstr_t("Y")
      ? VARIANT_TRUE : VARIANT_FALSE);
    
    groupSub->PutHasPersonalRates(_bstr_t(rowset->GetValue("b_PersonalRate")) == _bstr_t("Y")
        ? VARIANT_TRUE : VARIANT_FALSE);
    
  }
  catch (_com_error &)
  {
    // Some queries don't have the above columns
    // Ignore error
  }

  *ppGroupSub = reinterpret_cast<IMTGroupSubscription*>(groupSub.Detach());

}


// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetGroupSubscriptionByCorporateAccount(long aCorporateAccount, IMTSQLRowset **ppRowset)
{
  try {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(ACC_HIERARCHIES_QUERIES);
    rowset->SetQueryTag("__FIND_GROUP_SUBS_BY_CORPORATE_ACCOUNT__");
    rowset->AddParam("%%CORPORATEACCOUNT%%",aCorporateAccount);
    rowset->Execute();
    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch(_com_error& err) {
    return ReturnComError(err);
  }
  return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------


STDMETHODIMP CMTSubscriptionReader::FindMember(IMTSessionContext *pCtx,
                                               long aAccountID,
                                               long gSubID,
                                               DATE RefDate,
                                               IMTGSubMember **ppMember)
{
  try {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(ACC_HIERARCHIES_QUERIES);
    rowset->SetQueryTag("__FIND_GSUB_MEMBER_BY_ID__");
    rowset->AddParam("%%ACCOUNTID%%",aAccountID);
    rowset->AddParam("%%GSUBID%%",gSubID);
    wstring aValue;
    FormatValueForDB(_variant_t(RefDate,VT_DATE),FALSE,aValue);
    rowset->AddParam("%%REFDATE%%",aValue.c_str(),VARIANT_TRUE);
    rowset->Execute();

    if(rowset->GetRecordCount() == 0) {
      *ppMember = NULL;
    }
    else {
      MTPRODUCTCATALOGLib::IMTGSubMemberPtr member(__uuidof(MTPRODUCTCATALOGLib::MTGSubMember));
      member->PutAccountID(rowset->GetValue("id_acc"));
      member->PutStartDate(rowset->GetValue("vt_start"));
      member->PutEndDate(rowset->GetValue("vt_end"));
      member->PutAccountName(_bstr_t(rowset->GetValue("acc_name")));
      *ppMember = reinterpret_cast<IMTGSubMember*>(member.Detach());
    }
  }

  catch(_com_error& err) {
    return ReturnComError(err);
  }
  return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetSubParamTablesAsRowset(IMTSessionContext *apCTX, 
                                                                   long aSubID,
                                                                    IMTSQLRowset** ppRowset)
{
  try {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_ONE_SUB_PARAMTABLES__");
    rowset->AddParam("%%ID_SUB%%",aSubID);
    rowset->AddParam("%%LANGCODE%%",MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr(apCTX)->GetLanguageID());
    rowset->ExecuteDisconnected();
    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch(_com_error& err) {
    return ReturnComError(err);
  }
  return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetAccountSubscriptionsAsRowset(IMTSessionContext* apCTX,
                                                                    long aAccountID,
                                                                    IMTRowSet** ppRowset)
{
  MTAutoContext context(m_spObjectContext);
  try {

    _bstr_t selectlist,joinlist;
    InternalGetPOExtendedProperties(selectlist,joinlist);

    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr contextPtr(apCTX);


    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_ALL_SUBSCRIPTIONS__");
    rowset->AddParam("%%ID_ACC%%",aAccountID);
    rowset->AddParam("%%COLUMNS%%",selectlist);
    rowset->AddParam("%%JOINS%%",joinlist);
    rowset->AddParam("%%ID_LANG%%", contextPtr->GetLanguageID());
    rowset->Execute();

    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach()); 

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTSubscriptionReader::GetAccountSubscriptions(IMTSessionContext* apCTX,
                                                                 long aAccountID,
                                                                 IMTCollection** ppCol)
{
  MTAutoContext context(m_spObjectContext);
  try 
	{
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr thisPtr = this;
		MTObjectCollection<IMTSubscription> coll;
		ROWSETLib::IMTSQLRowsetPtr rowset = thisPtr->GetAccountSubscriptionsAsRowset
			((MTPRODUCTCATALOGEXECLib::IMTSessionContext*)apCTX, aAccountID);
		
		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE) 
		{
			MTPRODUCTCATALOGLib::IMTSubscriptionPtr sub(__uuidof(MTSubscription));
			PopulateSubscriptionByRowset(sub, rowset);
			coll.Add( (IMTSubscription*) sub.GetInterfacePtr());
			rowset->MoveNext();
    }

    coll.CopyTo(ppCol);

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}



// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetAccountGroupSubscriptionsAsRowset(IMTSessionContext* apCTX,
                                                                         long aAccountID,
                                                                         IMTRowSet** ppRowset)
{
  MTAutoContext context(m_spObjectContext);
  try {

    _bstr_t selectlist,joinlist;
    InternalGetPOExtendedProperties(selectlist,joinlist);

    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr contextPtr(apCTX);


    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_ALL_ACCOUNT_GROUP_SUBS__");
    rowset->AddParam("%%ID_ACC%%",aAccountID);
    rowset->AddParam("%%COLUMNS%%",selectlist);
    rowset->AddParam("%%JOINS%%",joinlist);
    rowset->AddParam("%%ID_LANG%%", contextPtr->GetLanguageID());
    rowset->Execute();

    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach()); 

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTSubscriptionReader::GetAccountGroupSubscriptions(IMTSessionContext* apCTX,
                                                                 long aAccountID,
                                                                 IMTCollection** ppCol)
{
  MTAutoContext context(m_spObjectContext);
  try 
	{
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr thisPtr = this;
		MTObjectCollection<IMTGroupSubscription> coll;
		ROWSETLib::IMTSQLRowsetPtr rowset = thisPtr->GetAccountGroupSubscriptionsAsRowset
			((MTPRODUCTCATALOGEXECLib::IMTSessionContext*)apCTX, aAccountID);
		
		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE) 
		{
			MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr sub(__uuidof(MTGroupSubscription));
			InternalPopulateGroupSubscription(apCTX,rowset,reinterpret_cast<IMTGroupSubscription**>(&sub));
			coll.Add( (IMTGroupSubscription*) sub.GetInterfacePtr());
			rowset->MoveNext();
    }

    coll.CopyTo(ppCol);

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}


STDMETHODIMP CMTSubscriptionReader::GetCountOfSubscribersWithCycleConflicts(
                                              IMTSessionContext* apCtxt,
                                              long aProdOffID,
                                              IMTPCCycle * apCycle,
                                              long *apSubCount)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    if (!apSubCount)
      return E_POINTER;
    
    *apSubCount = 0;

    MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle(apCycle);

		// Fixed and BCR cycles will never have conflicts with subscribers
		if ((cycle->Mode == CYCLE_MODE_FIXED) || (cycle->Mode == CYCLE_MODE_BCR))
		{
			context.Complete();
 			return S_OK;
		}

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_SUB_COUNT_WITH_CYCLE_CONFLICT__");
    rowset->AddParam("%%ID_PO%%", aProdOffID);

		_bstr_t cycleTypeFilter = "";
		if (cycle->Mode == CYCLE_MODE_EBCR)
			rowset->AddParam("%%CYCLE_TYPE_FILTER%%", "(dbo.CheckEBCRCycleTypeCompatibility(%%CYCLE_TYPE%%, uc.id_cycle_type) = 0)");
		else if (cycle->Mode == CYCLE_MODE_BCR_CONSTRAINED)
			rowset->AddParam("%%CYCLE_TYPE_FILTER%%", "uc.id_cycle_type <> %%CYCLE_TYPE%%");
		else
			return E_FAIL; // unsupported cycle mode
			 

    rowset->AddParam("%%CYCLE_TYPE%%", cycle->CycleTypeID);
    rowset->Execute();

    *apSubCount = rowset->GetValue(0L);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

// TODO: EBCR
STDMETHODIMP CMTSubscriptionReader::GetGroupSubscriptionsWithCycleConflictsAsRowset(
                                              IMTSessionContext* apCtxt,
                                              long aProdOffID,
                                              long aCycleTypeID,
                                              IMTSQLRowset **apRowset)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    if (!apRowset)
      return E_POINTER;

    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_GSUB_WITH_CYCLE_CONFLICT__");
    rowset->AddParam("%%ID_PO%%", aProdOffID);
    rowset->AddParam("%%CYCLE_TYPE%%", aCycleTypeID);
    rowset->Execute();
    *apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error& err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}


STDMETHODIMP CMTSubscriptionReader::GetChargeAccount(IMTSessionContext* apCtxt,
																										 long aGroupSubID,
																										 long aPrcItemInstanceID,
																										 DATE aEffDate, 
																										 long * apAccountID)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    if (!apAccountID)
      return E_POINTER;
    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_GSUB_RECUR_ACCOUNT__");
    rowset->AddParam("%%ID_GSUB%%", aGroupSubID);
    rowset->AddParam("%%ID_PROP%%", aPrcItemInstanceID);

		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(_variant_t(aEffDate, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
    rowset->AddParam("%%VT_DATE%%", buffer.c_str(), VARIANT_TRUE);

    rowset->Execute();
		*apAccountID = (long) rowset->GetValue("id_acc");
  }
  catch (_com_error& err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTSubscriptionReader::GetRecurringChargeAccountsAsRowset(
                                              IMTSessionContext* apCtxt,
                                              long aGroupSubID,
																							DATE aEffDate,
                                              IMTSQLRowset **apRowset)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    if (!apRowset)
      return E_POINTER;

    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_GSUB_CHARGE_ACCOUNT_HISTORY__");
    rowset->AddParam("%%ID_GSUB%%", aGroupSubID);
		rowset->AddParam("%%VT_MAX%%", GetMaxMTOLETime());
// TODO: Create a new method for this that doesn't have a eff date parameter
// 		std::wstring buffer;
// 		BOOL bSuccess = FormatValueForDB(_variant_t(aEffDate, VT_DATE), FALSE, buffer);
// 		if (bSuccess == FALSE)
// 		{
// 			return E_FAIL;
// 		}
//     rowset->AddParam("%%VT_DATE%%", buffer.c_str(), VARIANT_TRUE);

    rowset->Execute();
    *apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error& err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTSubscriptionReader::GetPerSubscriptionChargesAsRowset(
                                              IMTSessionContext* apCtxt,
                                              long aPOID,
                                              IMTSQLRowset **apRowset)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    if (!apRowset)
      return E_POINTER;

    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_PO_PER_SUB_CHARGES__");
    rowset->AddParam("%%ID_PO%%", aPOID);
    rowset->Execute();
    *apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error& err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTSubscriptionReader::GetUnitValue(IMTSessionContext* apCtxt, 
																								 long aGroupSubID, 
																								 long aPrcItemInstanceID, 
																								 DATE aEffDate, 
																								 DECIMAL * apUnitValue)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    if (!apUnitValue)
      return E_POINTER;

    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_RECUR_VALUE_FOR_CHARGE__");
    rowset->AddParam("%%ID_SUB%%", aGroupSubID);
    rowset->AddParam("%%ID_PROP%%", aPrcItemInstanceID);
		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(_variant_t(aEffDate, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%DT_EFF%%", buffer.c_str(), VARIANT_TRUE);
		bSuccess = FormatValueForDB(GetMaxMTOLETime(), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%DT_MAX_VALUE%%", buffer.c_str(), VARIANT_TRUE);
    rowset->Execute();

		*apUnitValue = (DECIMAL) rowset->GetValue("n_value");
  }
  catch (_com_error& err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTSubscriptionReader::GetUnitValuesAsRowset(IMTSessionContext* apCtxt, 
																													long aGroupSubID, 
																													IMTSQLRowset** apRowset)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    if (!apRowset)
      return E_POINTER;

    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_RECUR_VALUE_HISTORY__");
    rowset->AddParam("%%ID_SUB%%", aGroupSubID);
		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(GetMaxMTOLETime(), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%DT_MAX_VALUE%%", buffer.c_str(), VARIANT_TRUE);
    rowset->Execute();
    *apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error& err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTSubscriptionReader::GetUnitValuesForChargeAsRowset(IMTSessionContext* apCtxt, 
																																	 long aGroupSubID, 
																																	 long aPrcItemInstanceID, 
																																	 IMTSQLRowset** apRowset)
{
  MTAutoContext context(m_spObjectContext);

  try
  {
    if (!apRowset)
      return E_POINTER;

    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_RECUR_VALUE_HISTORY_FOR_CHARGE__");
    rowset->AddParam("%%ID_SUB%%", aGroupSubID);
    rowset->AddParam("%%ID_PROP%%", aPrcItemInstanceID);
		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(GetMaxMTOLETime(), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		rowset->AddParam(L"%%DT_MAX_VALUE%%", buffer.c_str(), VARIANT_TRUE);
    rowset->Execute();
    *apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error& err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTSubscriptionReader::get_WarnOnEBCRStartDateChange(long subID, VARIANT_BOOL *pVal)
{
	MTAutoContext context(m_spObjectContext);

  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    //rowset->SetQueryTag("__GET_WARN_ON_EBCR_STARTDATE_CHANGE__");
    rowset->SetQueryString("SELECT dbo.WarnOnEBCRStartDateChange(%%ID_SUB%%) warn %%%FROMDUAL%%%");
    rowset->AddParam("%%ID_SUB%%", subID);
    rowset->Execute();

		if (rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
			return E_FAIL;
		
		long rc = rowset->GetValue("warn");
		switch (rc)
		{
		case 1:
			*pVal = VARIANT_TRUE;
			break;

		case 0:
			*pVal = VARIANT_FALSE;
			break;

		default: 
			char msg[128];
			sprintf(msg, "WarnOnEBCRStartDateChange: unknown error = %d", rc); 
      MT_THROW_COM_ERROR(msg);
		}
  }
  catch (_com_error& err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTSubscriptionReader::WarnOnEBCRMemberStartDateChange(long subID, long accountID, VARIANT_BOOL *pVal)
{
	MTAutoContext context(m_spObjectContext);

  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryString("SELECT dbo.WarnOnEBCRMemberStartDateChang(%%ID_SUB%%, %%ID_ACC%%) warn %%%FROMDUAL%%%");

    rowset->AddParam("%%ID_SUB%%", subID);
    rowset->AddParam("%%ID_ACC%%", accountID);
    rowset->Execute();

		if (rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
			return E_FAIL;
		
		long rc = rowset->GetValue("warn");
		switch (rc)
		{
		case 1:
			*pVal = VARIANT_TRUE;
			break;

		case 0:
			*pVal = VARIANT_FALSE;
			break;

		default: 
			char msg[128];
			sprintf(msg, "WarnOnEBCRMemberStartDateChang: unknown error = %d", rc); 
      MT_THROW_COM_ERROR(msg);
		}
  }
  catch (_com_error& err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscriptionReader::GetAvailableGroupSubscriptionByCorporateAccount(
                                                                                    IMTSessionContext* apCtxt, 
                                                                                    IMTYAAC* apYAAC,
                                                                                    IMTSQLRowset **ppRowset)
{
  try {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    MTYAACLib::IMTYAACPtr yaac = apYAAC;
    rowset->Init(ACC_HIERARCHIES_QUERIES);
    rowset->SetQueryTag("__FIND_AVAILABLE_GROUP_SUBS_BY_CORPORATE_ACCOUNT__");
    rowset->AddParam("%%CORPORATEACCOUNT%%",yaac->CorporateAccountID);
    rowset->AddParam("%%ID_ACCOUNT_TYPE%%",yaac->AccountTypeID);
    rowset->Execute();
    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch(_com_error& err) {
    return ReturnComError(err);
  }
  return S_OK;
}
