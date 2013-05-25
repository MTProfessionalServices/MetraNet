/**************************************************************************
 * @doc PROPIDS
 *
 * Copyright 1998 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>

#include <propids.h>
#include <reservedproperties.h>

#include <mtprogids.h>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
using namespace MTPipelineLib;

BOOL PipelinePropIDs::mIsInitialized = FALSE;
NTThreadLock PipelinePropIDs::mLock;

int PipelinePropIDs::mAccountIDCode = -1;
int PipelinePropIDs::mCurrencyCode = -1;
int PipelinePropIDs::mAmountCode = -1;
int PipelinePropIDs::mTimestampCode = -1;
int PipelinePropIDs::mMeteredTimestampCode = -1;
int PipelinePropIDs::mProductViewIDCode = -1;
int PipelinePropIDs::mProductIDCode = -1;
int PipelinePropIDs::mServiceIDCode = -1;
int PipelinePropIDs::mFeedbackMeterIDCode = -1;
int PipelinePropIDs::mIPAddressCode = -1;
int PipelinePropIDs::mFedTaxCode = -1;
int PipelinePropIDs::mStateTaxCode = -1;
int PipelinePropIDs::mCountyTaxCode = -1;
int PipelinePropIDs::mLocalTaxCode = -1;
int PipelinePropIDs::mOtherTaxCode = -1;
int PipelinePropIDs::mProfileStageCode = -1;
int PipelinePropIDs::mIntervalIdCode = -1;
int PipelinePropIDs::mNewParentIDCode = -1;
int PipelinePropIDs::mNewParentInternalIDCode = -1;
int PipelinePropIDs::mTransactionCookieCode = -1;
int PipelinePropIDs::mNextStageCode = -1;
int PipelinePropIDs::mErrorStringCode = -1;
int PipelinePropIDs::mErrorCodeCode = -1;
int PipelinePropIDs::mPriceableItemInstanceIDCode = -1;
int PipelinePropIDs::mPriceableItemTemplateIDCode = -1;
int PipelinePropIDs::mPriceableItemNameIDCode = -1;
int PipelinePropIDs::mProductOfferingIDCode = -1;
int PipelinePropIDs::mSubscriptionIDCode = -1;
int PipelinePropIDs::mAccountPriceListCode = -1;
int PipelinePropIDs::mCollectionIDCode = -1;
int PipelinePropIDs::mTransactionObject = -1;
int PipelinePropIDs::mPayingAccount = -1;
int PipelinePropIDs::mExecutePlugin = -1;
int PipelinePropIDs::mResubmitCode = -1;
int PipelinePropIDs::mSessionIDCode = -1;
int PipelinePropIDs::mAccountState = -1;
int PipelinePropIDs::mSubscriptionEntityIDCode = -1;
int PipelinePropIDs::mSessionSetIDCode = -1;
int PipelinePropIDs::mExternalSessionIDCode = -1;
int PipelinePropIDs::mDivisionCurrencyCode = -1;
int PipelinePropIDs::mDivisionAmountCode = -1;
int PipelinePropIDs::mTaxInclusiveCode = -1;
int PipelinePropIDs::mTaxCalculatedCode = -1;
int PipelinePropIDs::mTaxInformationalCode = -1;
void PipelinePropIDs::Init()
{
	if (mIsInitialized)
		return;

	// only need the lookup temporarily
	try
	{
		mLock.Lock();

		IMTNameIDPtr nameid(MTPROGID_NAMEID);
		mAccountIDCode        = nameid->GetNameID(MT_ACCOUNTID_PROP);
		mCurrencyCode         = nameid->GetNameID(MT_CURRENCY_PROP);
		mAmountCode           = nameid->GetNameID(MT_AMOUNT_PROP);
		mTimestampCode        = nameid->GetNameID(MT_TIMESTAMP_PROP);
		mMeteredTimestampCode = nameid->GetNameID(MT_METEREDTIMESTAMP_PROP);
		mProductViewIDCode    = nameid->GetNameID(MT_PRODUCTVIEWID_PROP);
		mProductIDCode        = nameid->GetNameID(MT_PRODUCTID_PROP);
		mServiceIDCode        = nameid->GetNameID(MT_SERVICEID_PROP);
		mFeedbackMeterIDCode  = nameid->GetNameID(MT_FEEDBACKMETERID_PROP);
		mIPAddressCode        = nameid->GetNameID(MT_IPADDRESS_PROP);
		mFedTaxCode           = nameid->GetNameID(MT_FEDTAX_PROP);
		mStateTaxCode         = nameid->GetNameID(MT_STATETAX_PROP);
		mCountyTaxCode        = nameid->GetNameID(MT_COUNTYTAX_PROP);
		mLocalTaxCode         = nameid->GetNameID(MT_LOCALTAX_PROP);
		mOtherTaxCode         = nameid->GetNameID(MT_OTHERTAX_PROP);
		mProfileStageCode     = nameid->GetNameID(MT_PROFILESTAGE_PROP);
		mIntervalIdCode       = nameid->GetNameID(MT_INTERVALID_PROP);
		mNewParentIDCode			= nameid->GetNameID(MT_NEWPARENTID_PROP);
		mNewParentInternalIDCode = nameid->GetNameID(MT_NEWPARENTINTERNALID_PROP);
		mTransactionCookieCode = nameid->GetNameID(MT_TRANSACTIONCOOKIE_PROP);
		mNextStageCode			  = nameid->GetNameID(MT_NEXTSTAGE_PROP);
		mErrorStringCode			= nameid->GetNameID(MT_ERRORSTRING_PROP);
		mErrorCodeCode			  = nameid->GetNameID(MT_ERRORCODE_PROP);
		mPriceableItemInstanceIDCode = nameid->GetNameID(MT_PRICEABLEITEMINSTANCEID_PROP);
		mPriceableItemTemplateIDCode = nameid->GetNameID(MT_PRICEABLEITEMTEMPLATEID_PROP);
		mPriceableItemNameIDCode     = nameid->GetNameID(MT_PRICEABLEITEMNAMEID_PROP);
		mProductOfferingIDCode = nameid->GetNameID(MT_PRODUCTOFFERINGID_PROP);
		mSubscriptionIDCode    = nameid->GetNameID(MT_SUBSCRIPTIONID_PROP);
		mAccountPriceListCode = nameid->GetNameID(MT_ACCOUNTPRICELIST_PROP);
		mCollectionIDCode = nameid->GetNameID(MT_COLLECTIONID_PROP);
		mTransactionObject = nameid->GetNameID(MT_TRANSACTION_OBJECT_PROP);
		mPayingAccount = nameid->GetNameID(MT_PAYINGACCOUNT_PROP);
		mExecutePlugin = nameid->GetNameID(MT_EXECUTEPLUGIN_PROP);
		mResubmitCode = nameid->GetNameID(MT_RESUBMIT_PROP);
		mSessionIDCode = nameid->GetNameID(MT_SESSIONID_PROP);
    mAccountState = nameid->GetNameID(MT_ACCOUNTSTATE_PROP);
		mSubscriptionEntityIDCode = nameid->GetNameID(MT_SUBSCRIPTIONENTITY_PROP);
		mSessionSetIDCode = nameid->GetNameID(MT_SESSIONSETID_PROP);
		mExternalSessionIDCode = nameid->GetNameID(MT_EXTERNALSESSIONID_PROP);
		mDivisionCurrencyCode = nameid->GetNameID(MT_DIVISIONCURRENCY_PROP);
		mDivisionAmountCode = nameid->GetNameID(MT_DIVISIONAMOUNT_PROP);
		mTaxInclusiveCode = nameid->GetNameID(MT_TAXINCLUSIVE_PROP);
        mTaxCalculatedCode = nameid->GetNameID(MT_TAXCALCULATED_PROP);
        mTaxInformationalCode = nameid->GetNameID(MT_TAXINFORMATIONAL_PROP);
        mIsInitialized = TRUE;

		mLock.Unlock();
	}
	catch (_com_error &)
	{
		// didn't work - invalidate all codes
		mLock.Unlock();

		//ASSERT(0);
		mAccountIDCode        = -1;
		mCurrencyCode         = -1;
		mAmountCode           = -1;
		mTimestampCode        = -1;
		mMeteredTimestampCode = -1;
		mProductViewIDCode    = -1;
		mProductIDCode        = -1;
		mServiceIDCode        = -1;
		mFeedbackMeterIDCode  = -1;
		mIPAddressCode        = -1;
		mFedTaxCode           = -1;
		mStateTaxCode         = -1;
		mCountyTaxCode        = -1;
		mLocalTaxCode         = -1;
		mOtherTaxCode         = -1;
		mIntervalIdCode       = -1;
		mNewParentIDCode			= -1;
		mNewParentInternalIDCode = -1;
		mTransactionCookieCode = -1;
		mErrorStringCode			= -1;
		mErrorCodeCode			  = -1;
		mPayingAccount				= -1;
    mAccountState				  = -1;
		mSubscriptionEntityIDCode = -1;
		mDivisionCurrencyCode	= -1;
		mDivisionAmountCode		= -1;
        mTaxInclusiveCode = -1;
        mTaxCalculatedCode = -1;
        mTaxInformationalCode = -1;
        throw;
	}
}

