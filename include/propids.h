/**************************************************************************
 * @doc PROPIDS
 *
 * @module |
 *
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
 *
 * @index | PROPIDS
 ***************************************************************************/

#ifndef _PROPIDS_H
#define _PROPIDS_H

#include <NTThreadLock.h>

class PipelinePropIDs
{
public:
	// NOTE: throws _com_error on failure
	static void Init();

	static int AccountIDCode()
	{ return mAccountIDCode; }

	static int CurrencyCode()
	{ return mCurrencyCode; }

	static int AmountCode()
	{ return mAmountCode; }

	static int TimestampCode()
	{ return mTimestampCode; }

	static int MeteredTimestampCode()
	{ return mMeteredTimestampCode; }

	static int ProductViewIDCode()
	{ return mProductViewIDCode; }

	static int ProductIDCode()
	{ return mProductIDCode; }

	static int ServiceIDCode()
	{ return mServiceIDCode; }

	static int FeedbackMeterID()
	{ return mFeedbackMeterIDCode; }

	static int IPAddressCode()
	{ return mIPAddressCode; }

	static int FedTaxCode()
	{ return mFedTaxCode; }

	static int StateTaxCode()
	{ return mStateTaxCode; }

	static int CountyTaxCode()
	{ return mCountyTaxCode; }

	static int LocalTaxCode()
	{ return mLocalTaxCode; }

	static int OtherTaxCode()
	{ return mOtherTaxCode; }

	static int ProfileStageCode()
	{ return mProfileStageCode; }

	static int IntervalIdCode()
	{ return mIntervalIdCode; }

	static int NewParentIDCode()
	{ return mNewParentIDCode; }

	static int NewParentInternalIDCode()
	{ return mNewParentInternalIDCode; }

	static int TransactionCookieCode()
	{ return mTransactionCookieCode; }

	static int NextStageCode()
	{ return mNextStageCode; }

	static int ErrorStringCode()
	{ return mErrorStringCode; }

	static int ErrorCodeCode()
	{ return mErrorCodeCode; }

	static int PriceableItemInstanceIDCode()
	{ return mPriceableItemInstanceIDCode; }

	static int PriceableItemTemplateIDCode()
	{ return mPriceableItemTemplateIDCode; }

	static int PriceableItemNameIDCode()
	{ return mPriceableItemNameIDCode; }

	static int ProductOfferingIDCode()
	{ return mProductOfferingIDCode; }

	static int SubscriptionIDCode()
	{ return mSubscriptionIDCode; }

	static int AccountPriceListCode()
	{ return mAccountPriceListCode; }

	static int CollectionIDCode()
	{ return mCollectionIDCode; }

	static int TransactionObjectCode()
	{ return mTransactionObject; }

	static int ResubmitCode()
	{ return mResubmitCode; }

	static int PayingAccount()
	{ return mPayingAccount; }

	static int PayingAccountCode()
	{ 
		return mPayingAccount; 
	}
  static int AccountState()
	{ 
		return mAccountState; 
	}

	static int SubscriptionEntityIDCode()
	{ return mSubscriptionEntityIDCode; }

	static int DivisionCurrencyCode()
	{ return mDivisionCurrencyCode; }
	
	static int DivisionAmountCode()
	{ return mDivisionAmountCode; }

	static int ExecutePluginCode()
	{ return mExecutePlugin; }

	
	static int SessionIDCode()
	{ return mSessionIDCode; }

	static int SessionSetIDCode()
	{ return mSessionSetIDCode; }

	static int ExternalSessionIDCode()
	{ return mExternalSessionIDCode; }
    
    static int TaxInclusiveCode()
    {return mTaxInclusiveCode; }

    static int TaxCalculatedCode()
    {return mTaxCalculatedCode; }

    static int TaxInformationalCode()
    {return mTaxInformationalCode;}

private:
	static BOOL mIsInitialized;
	static NTThreadLock mLock;
private:
	static int mAccountIDCode;
	static int mCurrencyCode;
	static int mAmountCode;
	static int mTimestampCode;
	static int mMeteredTimestampCode;
	static int mProductViewIDCode;
	static int mProductIDCode;
	static int mServiceIDCode;
	static int mFeedbackMeterIDCode;
	static int mIPAddressCode;
	static int mFedTaxCode;
	static int mStateTaxCode;
	static int mCountyTaxCode;
	static int mLocalTaxCode;
	static int mOtherTaxCode;
	static int mProfileStageCode;
	static int mIntervalIdCode;
	static int mNewParentIDCode;
	static int mNewParentInternalIDCode;
	static int mTransactionCookieCode;
	static int mNextStageCode;
	static int mErrorStringCode;
	static int mErrorCodeCode;
	static int mPriceableItemInstanceIDCode;
	static int mPriceableItemTemplateIDCode;
	static int mPriceableItemNameIDCode;
	static int mProductOfferingIDCode;
	static int mSubscriptionIDCode;
	static int mAccountPriceListCode;
	static int mCollectionIDCode;
	static int mTransactionObject;
	static int mPayingAccount;
	static int mExecutePlugin; 
	static int mResubmitCode; 
	static int mSessionIDCode; 
    static int mAccountState;
	static int mSubscriptionEntityIDCode;
	static int mSessionSetIDCode;
	static int mExternalSessionIDCode;
	static int mDivisionCurrencyCode;
	static int mDivisionAmountCode;
    static int mTaxInclusiveCode;
    static int mTaxCalculatedCode;
    static int mTaxInformationalCode;
};


#endif /* _PROPIDS_H */
