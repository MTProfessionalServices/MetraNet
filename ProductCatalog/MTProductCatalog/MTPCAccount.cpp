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
#include "StdAfx.h"
#include "MTProductCatalog.h"
#include "MTPCAccount.h"
#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>


/////////////////////////////////////////////////////////////////////////////
// CMTPCAccount

STDMETHODIMP CMTPCAccount::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTPCAccount,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name: GetDefaultPriceList    	
// Arguments:   none
//                
// Return Value:  IMTPriceList
// Errors Raised: E_FAIL
// Description:   Gets the default account pricelist for the users account
// ----------------------------------------------------------------


STDMETHODIMP CMTPCAccount::GetDefaultPriceList(IMTPriceList **pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	try {
		// step 1: create an instance of the pricelist executant
		MTPRODUCTCATALOGEXECLib::IMTPriceListReaderPtr PLReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceListReader));

		// step 2: return the pricelist
		*pVal = reinterpret_cast<IMTPriceList *>(PLReader->FindByAccountID(GetSessionContextPtr(), mAccountID).Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name: SetDefaultPriceList    	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::SetDefaultPriceList(IMTPriceList *newVal)
{
	try {
		// step 1: create an instance of the account writer executant
		MTPRODUCTCATALOGEXECLib::IMTAccountWriterPtr AccountWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTAccountWriter));

		MTPRODUCTCATALOGLib::IMTPriceListPtr aPl(newVal);

		// step 2: set the pricelist
		AccountWriter->UpdateDefaultPricelist(GetSessionContextPtr(), mAccountID,aPl->GetID());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
	return S_OK;
}


// ----------------------------------------------------------------
// Name:  Subscribe   	
// Arguments: Product offering ID,timespan    
//                
// Return Value:  a subscription interface pointer
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::Subscribe(long aprodOffID, IMTPCTimeSpan *pEffDate,VARIANT* apDateModified, IMTSubscription **ppSub)
{
	ASSERT(pEffDate && ppSub && apDateModified);
	if(!(pEffDate && ppSub && apDateModified)) return E_POINTER;

	AuditEventsLib::MTAuditEvent event = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
    // step 1: create a new subscription object
		MTPRODUCTCATALOGLib::IMTSubscriptionPtr aSub(__uuidof(MTPRODUCTCATALOGLib::MTSubscription));

		// step 1a: pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTPCAccountPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		aSub->SetSessionContext(ctxt);

		// step 2: populate it
		aSub->PutAccountID(mAccountID);
		aSub->PutEffectiveDate(MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr(pEffDate));
		aSub->SetProductOffering(aprodOffID);
		::VariantInit(apDateModified);
		VARIANT_BOOL bDateModified = aSub->Save();
		_variant_t vBoolOut = (bDateModified == VARIANT_TRUE) ? true : false;
		::VariantCopy(apDateModified, &vBoolOut);
		*ppSub = reinterpret_cast<IMTSubscription*>(aSub.Detach());

		//PCCache::GetAuditor()->FireEvent(1501,126,1,aSubPtr->GetAccountID(),aSubPtr->GetProductOffering()->GetName());

	}
	catch(_com_error& err) {
		AuditAuthFailures(err, event, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											mAccountID);

		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:  Unsubscribe   	
// Arguments:  subscription ID, enddate
//                
// Return Value:  S_OK
// Errors Raised: 
// Description:   Unsubscribe to a product offering with the specified
// end date
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::Unsubscribe(long aSubscrID, VARIANT aEndDate,
                                       MTPCDateType aEndType,
                                       VARIANT_BOOL* pDateModified)
{
	HRESULT result = S_OK;
  long lEventID;

	AuditEventsLib::MTAuditEvent event = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
    // check for the modify subscription capability
    //if actor unsubscribes himself, then check selfsubscription capability
    long lAccountID;
    result = get_AccountID(&lAccountID);
    if(FAILED(result))
      MT_THROW_COM_ERROR(result);
    if(GetSecurityContext()->AccountID == lAccountID){
      event = AuditEventsLib::AUDITEVENT_SELF_SUB_DENIED;
      CHECKCAP(SELF_SUBSCRIBE);
      lEventID = 1613; /*AUDITEVENT_SELF_SUB_UNSUBSCRIBE*/
    }
    else{
		  event = AuditEventsLib::AUDITEVENT_SUB_UNSUBSCRIBE_DENIED;
      CHECKCAP(UPDATE_SUBSCRIPTION_CAP);
      lEventID = 1503; /*AUDITEVENT_SUB_UNSUBSCRIBE*/
    }

		// step 1: verify that the endtype is absolute or usage cycle relative
		if(!(aEndType == PCDATE_TYPE_ABSOLUTE || aEndType == PCDATE_TYPE_NEXT_BILLING_PERIOD)) {
			return Error("date type must be absolute or next billing period");
		}

		// step 1: create subscription executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		// step 2: get the list of IN active subscriptions
		MTPRODUCTCATALOGLib::IMTSubscriptionPtr aSub = SubReader->GetSubscriptionByID(GetSessionContextPtr(), aSubscrID);

		// set the required properties
		MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr aTimeSpan = aSub->GetEffectiveDate();
		aTimeSpan->PutEndDateType((MTPRODUCTCATALOGLib::MTPCDateType)aEndType);
		aTimeSpan->PutEndDate(_variant_t(aEndDate));

		// create the subscription writer executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
		*pDateModified = SubWriter->UpdateExisting(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSubscription*>(aSub.GetInterfacePtr()));

		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext = GetSessionContextPtr();
		PCCache::GetAuditor()->FireEvent(lEventID, pContext->AccountID, 1, mAccountID,aSub->GetProductOffering()->GetName());

	}
	catch(_com_error& err) {
		AuditAuthFailures(err, event, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											aSubscrID);

		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return result;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::RemoveSubscription(long aSubscrID)
{
  AuditEventsLib::MTAuditEvent event;
	try {
    long lAccountID;
    HRESULT result = get_AccountID(&lAccountID);
    if(FAILED(result))
      MT_THROW_COM_ERROR(result);

    if(GetSecurityContext()->AccountID == lAccountID){
      event = AuditEventsLib::AUDITEVENT_SELF_SUB_DENIED;
      CHECKCAP(SELF_SUBSCRIBE);
    }
    else{
      event = AuditEventsLib::AUDITEVENT_SUB_DELETE_DENIED;
      CHECKCAP(DELETESUB_CAP);
    }

    MTPRODUCTCATALOGLib::IMTPCAccountPtr accountPtr(this);
    MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr basePtr= accountPtr->GetSubscription(aSubscrID);

		MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
    SubWriter->DeleteSubscription(GetSessionContextPtr(),
      reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSubscriptionBase*>(basePtr.GetInterfacePtr()));
  }
	catch (_com_error & err)
	{ 
		AuditAuthFailures(err, event, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											mAccountID);
		return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}

// ----------------------------------------------------------------
// Name:  FindSubscribableProductOfferingsAsRowset   	
// Arguments:   pFilter (optional)  
//							ppRowset (returned rowset)
// Return Value:  
// Errors Raised: 
// Description:   Returns all of the product offerings that are available for subscription.
// 
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::FindSubscribableProductOfferingsAsRowset(VARIANT pFilter, VARIANT aRefDate, IMTRowSet **ppRowset)
{
	try
	{
		ASSERT(ppRowset);
		if(!ppRowset) return E_POINTER;

		// step 1: see if the optional argument was passed in or not

		// step 2: If we have an optional argument, make sure it supports the IMTFilter interface

		// step 3: create an instance of the product offering executant
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr PoReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));

		// step 4: return results from the executant, query interface
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = PoReader->FindSubscribablePoByAccID(GetSessionContextPtr(), mAccountID, aRefDate);

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter = 
      pc->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING)->TranslateFilter(pFilter);
	
		if(aDataFilter != NULL) {
			aRowset->PutRefFilter(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTDataFilter *>(aDataFilter.GetInterfacePtr()));
		}
	
		*ppRowset = reinterpret_cast<IMTRowSet*>(aRowset.Detach());
		return S_OK;
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
}

// ----------------------------------------------------------------
// Name:  GetSubscribableProductOfferings   	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description: Same as FindSubscribableProductOfferingsAsRowset but returns the objects 
// in a collection
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::GetSubscribableProductOfferings(VARIANT aRefDate, IMTCollection **ppCol)
{
	ASSERT(ppCol);
	if(!ppCol) return E_POINTER;
	try {
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr PoReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));

		*ppCol = reinterpret_cast<IMTCollection*>(PoReader->FindSubscribablePoByAccIDasCollection(GetSessionContextPtr(), mAccountID, aRefDate).Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:  GetActiveSubscriptions
// Arguments: collection on output     
//                
// Return Value:  
// Errors Raised: 
// Description:   returns all the active subscriptions in a collection
// of IMTSubscription interface pointers
//
// DEPRECATED: Use GetSubscriptionsAsRowset
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::GetActiveSubscriptions(IMTCollection **ppCol)
{
	try {
    PCCache::GetLogger().LogThis(LOG_WARNING,"Calling deprecated method GetActiveSubscriptions");

    // step 1: create the subscription reader executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		// step 2: get the list of active subscriptions
		*ppCol = reinterpret_cast<IMTCollection*>(SubReader->GetActiveSubscriptionsByAccIDAsCollection(GetSessionContextPtr(), mAccountID).Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:  GetActiveSubscriptionsAsRowset   	
// Arguments:  rowset on output
//                
// Return Value:  
// Errors Raised: 
// Description:  Returns all the active subscriptions as a rowset (duh) 
//
// DEPRECATED: Use GetSubscriptionsAsRowset
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::GetActiveSubscriptionsAsRowset(IMTRowSet **ppRowset)
{
	try {
    PCCache::GetLogger().LogThis(LOG_WARNING,"Calling deprecated method GetActiveSubscriptionsAsRowset");

		// step 1: create the subscription reader executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		// step 2: get the list of active subscriptions
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = SubReader->GetActiveSubscriptionsByAccID(GetSessionContextPtr(), mAccountID);
		*ppRowset = reinterpret_cast<IMTRowSet*>(aRowset.Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:  GetInactivateSubscriptions   	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:  Return all inactive subscriptions as a collection of IMTSubscription interface pointers
//
// DEPRECATED: Use GetSubscriptionsAsRowset
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::GetInactivateSubscriptions(IMTCollection **ppCol)
{
	try {
    PCCache::GetLogger().LogThis(LOG_WARNING,"Calling deprecated method GetActiveSubscriptions");

    // step 1: create the subscription reader executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		// step 2: get the list of active subscriptions
		*ppCol = reinterpret_cast<IMTCollection*>(SubReader->GetInActiveSubscriptionsByAccID(GetSessionContextPtr(), mAccountID).Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:  GetInactiveSubscriptionsAsRowset   	
// Arguments:     rowset on output
//                
// Return Value:  
// Errors Raised: 
// Description:  Returns all inactive subscriptions as a rowset 
//
// DEPRECATED: Use GetSubscriptionsAsRowset
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::GetInactiveSubscriptionsAsRowset(IMTRowSet **ppRowset)
{
	try {
    PCCache::GetLogger().LogThis(LOG_WARNING,"Calling deprecated method GetActiveSubscriptions");

    // step 1: create the subscription reader executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		// step 2: get the list of IN active subscriptions
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = SubReader->GetInActiveSubscriptionsByAccID(GetSessionContextPtr(), mAccountID);
		*ppRowset = reinterpret_cast<IMTRowSet*>(aRowset.Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

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

STDMETHODIMP CMTPCAccount::GetPossiblePriceLists(long aPrcItemID, long paramTblID, IMTCollection **ppCol)
{
	return E_NOTIMPL;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::GetSubscriptionByProductOffering(long prodOffID, IMTSubscription **ppSub)
{
	try {
		// step 1: create the subscription reader executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		// step 2: get the list of IN active subscriptions
		*ppSub = reinterpret_cast<IMTSubscription*>(SubReader->GetSubscriptionsByPO(GetSessionContextPtr(), mAccountID,prodOffID).Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

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

STDMETHODIMP CMTPCAccount::GetSubscriptionsByProductOffering(long prodOffID, IMTCollection **ppSubs)
{
	try {
		// step 1: create the subscription reader executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		// step 2: get the list of subscriptions for the PO
		*ppSubs = reinterpret_cast<IMTCollection*>(SubReader->GetSubscriptionsByPOAsCollection(GetSessionContextPtr(), mAccountID,prodOffID).Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

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

STDMETHODIMP CMTPCAccount::GetSubscriptionByPriceableItem(long aPrcItemID, IMTSubscription **ppSub)
{
	try {
		// step 1: create the subscription reader executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		// step 2: get the list of IN active subscriptions
		*ppSub = reinterpret_cast<IMTSubscription*>(SubReader->GetSubscriptionByPIType(GetSessionContextPtr(), mAccountID,aPrcItemID).Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

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

STDMETHODIMP CMTPCAccount::GetSubscriptionsByPriceableItem(long aPrcItemID, IMTCollection **ppSubs)
{
	try {
		// step 1: create the subscription reader executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		// step 2: get the list of IN active subscriptions
		*ppSubs = reinterpret_cast<IMTCollection*>(SubReader->GetSubscriptionsByPIAsCollection(GetSessionContextPtr(), mAccountID,aPrcItemID).Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

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

STDMETHODIMP CMTPCAccount::GetParamTablesAsRowset(IMTRowSet **ppRowset)
{
	try {
		// step 1: create the subscription reader executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		// step 2: get the list of IN active subscriptions
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = SubReader->GetSubParamTables(GetSessionContextPtr(), mAccountID);
		*ppRowset = reinterpret_cast<IMTRowSet*>(aRowset.Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPCAccount::get_AccountID(long *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	*pVal = mAccountID;
	return S_OK;
}

STDMETHODIMP CMTPCAccount::put_AccountID(long newVal)
{
	mAccountID = newVal;
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

STDMETHODIMP CMTPCAccount::GetSubscription(long sub_id, IMTSubscriptionBase **ppSub)
{
	try {
		// step 1: create the subscription reader executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		// step 2: get the list of IN active subscriptions
		*ppSub = reinterpret_cast<IMTSubscriptionBase*>(SubReader->GetSubscriptionByID(GetSessionContextPtr(), sub_id).Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

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

STDMETHODIMP CMTPCAccount::CanChangeBillingCycles(/*[out, retval]*/ VARIANT_BOOL * pCanChange)
{
	try {
		// create the subscription reader executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

		return SubReader->raw_SubscriberCanChangeBillingCycles(GetSessionContextPtr(), mAccountID, pCanChange);
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

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

STDMETHODIMP CMTPCAccount::GetSubscriptionsAsRowset(IMTRowSet **ppRowset)
{
	try {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = SubReader->GetAccountSubscriptionsAsRowset(GetSessionContextPtr(), mAccountID);
		*ppRowset = reinterpret_cast<IMTRowSet*>(aRowset.Detach());
  }
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

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

STDMETHODIMP CMTPCAccount::GetSubscriptions(IMTCollection **ppColl)
{
	try {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr aColl = SubReader->GetAccountSubscriptions(GetSessionContextPtr(), mAccountID);
		*ppColl = reinterpret_cast<IMTCollection*>(aColl.Detach());
  }
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

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

STDMETHODIMP CMTPCAccount::GetGroupSubscriptionsAsRowset(IMTRowSet **ppRowset)
{
	try {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = SubReader->GetAccountGroupSubscriptionsAsRowset(GetSessionContextPtr(), mAccountID);
		*ppRowset = reinterpret_cast<IMTRowSet*>(aRowset.Detach());
  }
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

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

STDMETHODIMP CMTPCAccount::GetGroupSubscriptions(IMTCollection **ppColl)
{
	try {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr SubReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr aColl = SubReader->GetAccountGroupSubscriptions(GetSessionContextPtr(), mAccountID);
		*ppColl = reinterpret_cast<IMTCollection*>(aColl.Detach());
  }
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

// ----------------------------------------------------------------
// Name: GetNextBillingIntervalEndDate    	
// Arguments: DATE datecheck - start date to calculate billing cycle from
//                
// Return Value: VARIANT pVal - return date representing account's next billing cycle from the given start date
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------
STDMETHODIMP CMTPCAccount::GetNextBillingIntervalEndDate(DATE datecheck, VARIANT *pVal)
{
	try 
	{
		MTPRODUCTCATALOGEXECLib::IMTAccountReaderPtr AccReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTAccountReader));
		*pVal = AccReader->GetNextBillingIntervalEndDate(GetSessionContextPtr(), mAccountID, datecheck);
  }
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

// ----------------------------------------------------------------
// Name:  CreateSubscription   	
// Arguments: Product offering ID,timespan    
//                
// Return Value:  a subscription interface pointer
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPCAccount::CreateSubscription(long aprodOffID, IMTPCTimeSpan *pEffDate,IMTSubscription **ppSub)
{
	ASSERT(pEffDate && ppSub);
	if(!(pEffDate && ppSub)) return E_POINTER;

	AuditEventsLib::MTAuditEvent event = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
    // step 1: create a new subscription object
		MTPRODUCTCATALOGLib::IMTSubscriptionPtr aSub(__uuidof(MTPRODUCTCATALOGLib::MTSubscription));

		// step 1a: pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTPCAccountPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		aSub->SetSessionContext(ctxt);

		// step 2: populate it
		aSub->PutAccountID(mAccountID);
		aSub->PutEffectiveDate(MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr(pEffDate));
		aSub->SetProductOffering(aprodOffID);
		*ppSub = reinterpret_cast<IMTSubscription*>(aSub.Detach());

		//PCCache::GetAuditor()->FireEvent(1501,126,1,aSubPtr->GetAccountID(),aSubPtr->GetProductOffering()->GetName());

	}
	catch(_com_error& err) {
		AuditAuthFailures(err, event, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											mAccountID);

		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

