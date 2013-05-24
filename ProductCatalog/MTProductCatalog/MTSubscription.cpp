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
#include "MTSubscription.h"
#include <metra.h>
#include <mtcomerr.h>

/////////////////////////////////////////////////////////////////////////////
// CMTSubscription

STDMETHODIMP CMTSubscription::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSubscription,
    &IID_IMTSubscriptionBase,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTSubscription::FinalConstruct()
{
	try {
		LoadPropertiesMetaData(PCENTITY_TYPE_SUBSCRIPTION);

		//construct nested objects
		//(note: session context of nested objects needs to be set in CMTProductOffering::SetSessionContext())
		MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr effectiveDatePtr(__uuidof(MTPCTimeSpan));
		// effective dates are always absolute, initially: no start date, infinite end date
    effectiveDatePtr->Init(MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE, MTPRODUCTCATALOGLib::PCDATE_TYPE_NO_DATE,   
													 MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE, MTPRODUCTCATALOGLib::PCDATE_TYPE_NULL );
		PutPropertyObject("EffectiveDate", effectiveDatePtr);

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err) { 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
}

STDMETHODIMP CMTSubscription::get_AccountID(long *pVal)
{
	return GetPropertyValue("accountID", pVal);
}

STDMETHODIMP CMTSubscription::put_AccountID(long newVal)
{
	return PutPropertyValue("accountID", newVal);
}

// ----------------------------------------------------------------
// Name:   Save  	
// Arguments:  none   
//                
// Return Value:  
// Errors Raised: 
// Description:   Saves the current subscription.  If the ID does not exist,
// assume the subscription does not exist yet in persitent storage.
// ----------------------------------------------------------------

STDMETHODIMP CMTSubscription::Save(VARIANT_BOOL* pDateModified)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
		//validate properties based on their meta data (required, length, ...)
		//throws _com_error on failure
		ValidateProperties();
    //MTPRODUCTCATALOGLib::IMTSubscriptionPtr thisPtr = this;
    long lAccountID = 0;
    long aID = 0;
    bool bSelf = false;
		if(!pDateModified)
			return E_POINTER;
		*pDateModified = VARIANT_FALSE;

    HRESULT hr = get_AccountID(&lAccountID);
    if(FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    ASSERT(lAccountID > 0);

    // step 1: create instance of subscription writer executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));


    //if actor scubscribes himself, then check selfsubscription capability
    if(GetSecurityContext()->AccountID == lAccountID){
      bSelf = true;
      deniedEvent = AuditEventsLib::AUDITEVENT_SELF_SUB_DENIED;
    }
		
		if(SUCCEEDED(get_ID(&aID)) && aID != 0) {
      if(!bSelf){
        deniedEvent = AuditEventsLib::AUDITEVENT_SUB_UPDATE_DENIED;
        CHECKCAP(UPDATE_SUBSCRIPTION_CAP);
      }
      else{
       CHECKCAP(SELF_SUBSCRIBE);
      }
			*pDateModified = SubWriter->UpdateExisting(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSubscription*>(this));
		}
		else {
      // new subscription, check capability
      if(!bSelf){
			  deniedEvent = AuditEventsLib::AUDITEVENT_SUB_CREATE_DENIED;
        CHECKCAP(CREATESUB_CAP);
      }
      else{
       CHECKCAP(SELF_SUBSCRIBE);
      }
			//Brazilio claimed that SaveNew method and, hence, AddNewSub stored proc should return a boolean flag
			//indicating if date range for subscription was overridden if it spans Product Offering effiective dates
			//Currently it's not done
			*pDateModified = SubWriter->SaveNew(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSubscription*>(this));
			return S_OK;
		}
	}
	catch(_com_error& error) {
		long accountID;
		get_AccountID(&accountID);
		AuditAuthFailures(error, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											accountID);

		return LogAndReturnComError(PCCache::GetLogger(), error);
	}

	return S_OK;
}


