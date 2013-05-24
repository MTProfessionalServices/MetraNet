/**************************************************************************
 * @doc RecurringChargeProration
 *
 * Copyright 1999 by MetraTech Corporation
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
 * Created by: Michael Efimov
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <mtcom.h>
#include <MTDate.h>
#include <mtprogids.h>
#include <PlugInSkeleton.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <DBConstants.h>
#include <reservedproperties.h>
#include <MTDec.h>
#include <time.h>
#include <algorithm>
#include <list>
#include <CalendarLib.h>
#include <sstream>

// generate using uuidgen
CLSID CLSID_RCPRORATION = { /* {7B675E31-E406-41a5-8047-6003BFD8DFD0} */
	0x7b675e31, 0xe406, 0x41a5, { 0x80, 0x47, 0x60, 0x3, 0xbf, 0xd8, 0xdf, 0xd0 }
};

struct RecurringChargeProrationData
{
	// members
	MTPipelineLib::IMTSessionPtr mSession;

	// inputs
	_bstr_t		msActionType;

	DateRange	mdrRecurringCharge;
	DateRange	mdrSubscription;
  DateRange mdrFullSub;

	bool		mbChargeInAdvance;

	bool		mbProrateOnSubscription;
	bool		mbProrateOnUnSubscription;
  bool    mbProrateInstantly;
	long		mProrationCycleLength;

	MTDecimal	mdRecurringChargeAmount;

	// outputs
	MTDecimal	mdProratedRecurringChargeAmount;

	DateRange	mdrProratedCharge;

	bool		mbProratedOnSubscription;
	bool		mbProratedOnUnSubscription;
  bool    mbProratedInstantly;
	long		mlProratedDays;
	MTDecimal   mdProratedDailyRate;

};


class ATL_NO_VTABLE RecurringChargeProrationPlugIn : 
  public MTPipelinePlugIn<RecurringChargeProrationPlugIn, &CLSID_RCPRORATION>
{
protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary 
    // initialization.
	// NOTE: This method can be called any number of times in order to
	// refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(
	  MTPipelineLib::IMTLogPtr aLogger,
	  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
	  MTPipelineLib::IMTNameIDPtr aNameID,
      MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(
	  MTPipelineLib::IMTSessionPtr aSession);

private:

	long mActionType;
	long mRecurringChargeCycleStartDate;
	long mRecurringChargeCycleEndDate;
	long mSubscriptionStartDate;
	long mSubscriptionEndDate;
	long mRealSubEndDate;
	
	long mAdvanceChargeFlag;
	long mProrateOnSubscriptionFlag;
	long mProrateOnUnSubscriptionFlag;
  long mProrateInstantlyFlag;
	long mProrationCycleLength;

	// output properties
	long mRecurringChargeAmount;
	long mProratedRecurringChargeAmount;
	long mProratedStartDate;
	long mProratedEndDate;

	long mProratedOnSubscription;
	long mProratedOnUnSubscription;
  long mProratedInstantly;

	long mProratedDays;
	long mProratedDailyRate;

    MTPipelineLib::IMTLogPtr mLogger;

	HRESULT InitDateRange(MTPipelineLib::IMTSessionPtr aSession,
						  DateRange& refDateRange,
						  long lStartDatePropertyId,
						  long lEndDatePropertyId);

	// processes everything
	HRESULT Process(RecurringChargeProrationData* pRCPD);
  
};


PLUGIN_INFO(CLSID_RCPRORATION, 
			RecurringChargeProrationPlugIn,
			"MetraPipeline.RecurringChargeProration.1", 
			"MetraPipeline.RecurringChargeProration", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT RecurringChargeProrationPlugIn::PlugInConfigure(
  MTPipelineLib::IMTLogPtr aLogger,
  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
  MTPipelineLib::IMTNameIDPtr aNameID,
  MTPipelineLib::IMTSystemContextPtr aSysContext)
{
    const char* procName = "RecurringChargeProrationPlugIn::PlugInConfigure";

    mLogger = aLogger;

    DECLARE_PROPNAME_MAP(inputs)
		DECLARE_PROPNAME("rcactiontype", &mActionType)

		DECLARE_PROPNAME("rcintervalstart", &mRecurringChargeCycleStartDate)
		DECLARE_PROPNAME("rcintervalend", &mRecurringChargeCycleEndDate)

		DECLARE_PROPNAME("rcintervalsubscriptionstart", &mSubscriptionStartDate)
		DECLARE_PROPNAME("rcintervalsubscriptionend", &mSubscriptionEndDate)
		DECLARE_PROPNAME("realsubscriptionend",&mRealSubEndDate)
		
		DECLARE_PROPNAME("advance", &mAdvanceChargeFlag)

		DECLARE_PROPNAME("prorateonsubscription", &mProrateOnSubscriptionFlag)
		DECLARE_PROPNAME("prorateinstantly", &mProrateInstantlyFlag)
    DECLARE_PROPNAME("prorateonunsubscription", &mProrateOnUnSubscriptionFlag)

		// prorate for 28 days, prorate for actual month, etc.
		DECLARE_PROPNAME("prorationcyclelength", &mProrationCycleLength)

		// outputs
		DECLARE_PROPNAME("recurringchargeamount", &mRecurringChargeAmount)
		DECLARE_PROPNAME("proratedrecurringchargeamount", &mProratedRecurringChargeAmount)

		DECLARE_PROPNAME("proratedstartdate", &mProratedStartDate)
		DECLARE_PROPNAME("proratedenddate", &mProratedEndDate)
		DECLARE_PROPNAME("prorateddays", &mProratedDays)
		DECLARE_PROPNAME("prorateddailyrate", &mProratedDailyRate)

		DECLARE_PROPNAME("proratedonsubscription", &mProratedOnSubscription)
		DECLARE_PROPNAME("proratedonunsubscription", &mProratedOnUnSubscription)
		DECLARE_PROPNAME("proratedinstantly", &mProratedInstantly)

  	END_PROPNAME_MAP
	  
  	return ProcessProperties(inputs,aPropSet,aNameID,aLogger,procName);
}

HRESULT RecurringChargeProrationPlugIn::InitDateRange(MTPipelineLib::IMTSessionPtr aSession,
						  DateRange& refDateRange,
						  long lStartDatePropertyId,
						  long lEndDatePropertyId)
{
	refDateRange.SetStartDate(aSession->GetDateTimeProperty(lStartDatePropertyId));
	refDateRange.SetEndDate(aSession->GetDateTimeProperty(lEndDatePropertyId));

	return S_OK;
}

static _bstr_t DateRangeString(const DateRange& dr)
{
	MTDate dtStart(dr.GetStartDate()); 
	MTDate dtEnd(dr.GetEndDate());
	std::string strStart;
	std::string strEnd;
	LPCSTR strFormat = "%m/%d/%y %H:%M:%S";
	dtStart.ToString(strFormat, strStart);
	dtEnd.ToString(strFormat, strEnd);

	std::stringstream strout;
	strout << strStart.c_str() << " - " << strEnd.c_str() << " (" << dr.Days() << " days)";

	return strout.str().c_str();
}


/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT 
RecurringChargeProrationPlugIn::PlugInProcessSession(
  MTPipelineLib::IMTSessionPtr aSession)
{
	_bstr_t buffer;
	const char* procName = "RecurringChargeProrationPlugIn::PlugInProcessSession";

	buffer = L"Entering RecurringChargeProrationPlugIn::PlugInProcessSession()";
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));

	RecurringChargeProrationData rcp;

	// members
	rcp.mSession = aSession;

	buffer = L"reading session data";
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));

	// inputs

	// amount before proration
	rcp.msActionType = aSession->GetStringProperty(mActionType);
	rcp.mdRecurringChargeAmount = aSession->GetDecimalProperty(mRecurringChargeAmount);

	InitDateRange(aSession, rcp.mdrRecurringCharge, mRecurringChargeCycleStartDate, mRecurringChargeCycleEndDate);

	rcp.mProrationCycleLength = aSession->GetLongProperty(mProrationCycleLength);

	rcp.mbChargeInAdvance = (VARIANT_TRUE == aSession->GetBoolProperty(mAdvanceChargeFlag));
	rcp.mbProrateOnSubscription = (VARIANT_TRUE == aSession->GetBoolProperty(mProrateOnSubscriptionFlag));
	rcp.mbProrateInstantly = (VARIANT_TRUE == aSession->GetBoolProperty(mProrateInstantlyFlag));
	rcp.mbProrateOnUnSubscription = (VARIANT_TRUE == aSession->GetBoolProperty(mProrateOnUnSubscriptionFlag));
	InitDateRange(aSession, rcp.mdrSubscription, mSubscriptionStartDate, mSubscriptionEndDate);
  InitDateRange(aSession, rcp.mdrFullSub, mSubscriptionStartDate, mRealSubEndDate);

	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Recurring Charge Interval: " + DateRangeString(rcp.mdrRecurringCharge));
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Subscription Adjusted Recurring Charge Interval: " + DateRangeString(rcp.mdrSubscription));

	buffer = L"processing session";
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));

	// calculations here
	// .........
	HRESULT hr = Process(&rcp);
	if(FAILED(hr))
		return hr;

	buffer = L"storing session data";
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));

	// outputs
	aSession->SetDecimalProperty(mProratedRecurringChargeAmount, rcp.mdProratedRecurringChargeAmount);

  DATE dt;
  ::OleDateFromTimet(&dt, rcp.mdrProratedCharge.GetStartDate());
	aSession->SetOLEDateProperty(mProratedStartDate, dt);
  ::OleDateFromTimet(&dt, rcp.mdrProratedCharge.GetEndDate());
	aSession->SetOLEDateProperty(mProratedEndDate, dt);
	aSession->SetLongProperty(mProratedDays, rcp.mlProratedDays);
	aSession->SetDecimalProperty(mProratedDailyRate, rcp.mdProratedDailyRate);

	aSession->SetBoolProperty(mProratedOnSubscription, rcp.mbProratedOnSubscription ? VARIANT_TRUE : VARIANT_FALSE);
	aSession->SetBoolProperty(mProratedOnUnSubscription, rcp.mbProratedOnUnSubscription ? VARIANT_TRUE : VARIANT_FALSE);
	aSession->SetBoolProperty(mProratedInstantly, rcp.mbProratedInstantly ? VARIANT_TRUE : VARIANT_FALSE);

	buffer = L"Leaving RecurringChargeProrationPlugIn::PlugInProcessSession()";
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));

	return (S_OK);
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT 
RecurringChargeProrationPlugIn::PlugInShutdown()
{
	return S_OK;
}

// processes everything
HRESULT RecurringChargeProrationPlugIn::Process(RecurringChargeProrationData* pRCD)
{
	HRESULT hr = S_OK;
	_bstr_t buffer;
	
	bool bIssueCredit = (pRCD->msActionType == _bstr_t(L"Credit"));
	bool bIssueInitialCredit = (pRCD->msActionType == _bstr_t(L"InitialCredit"));
	bool bInitialDebit = (pRCD->msActionType == _bstr_t(L"InitialDebit"));

	// regular interval
	DateRange tpRegular = pRCD->mdrRecurringCharge;
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"*****Action: " + pRCD->msActionType);
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"*****tpRegular: " + DateRangeString(tpRegular));
	// actual interval is limited by subscription
	DateRange tpActual = pRCD->mdrSubscription;
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"*****tpActual: " + DateRangeString(tpActual));

    //  If we have an actual unsubscription date, we'll need that for instant prorate
    DateRange tpInstant = pRCD->mdrFullSub;
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"*****tpInstant: " + DateRangeString(tpInstant));

	// figure out wheter to prorate or not, and wheter to credit or not.
	// calculate number of days in regular interval.
	int	iRegularDays = pRCD->mProrationCycleLength;
  
    std::stringstream placeholder;
	placeholder << "*****iRegularDays: " << iRegularDays;
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, placeholder.str().c_str());
	
    // if cycle length is not fixed, use actual length
	if(iRegularDays == 0)
	{
		iRegularDays = tpRegular.Days();

        placeholder.clear();
		placeholder <<  "Recurring charge interval uses actual number of days: " << iRegularDays; 
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, placeholder.str().c_str());
	}
	else
	{
		buffer = "Recurring charge interval uses fixed number of days"; 
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
	}

	if(iRegularDays == 0)
	{
		LPOLESTR strErr = L"Recurring charge interval is empty in RecurringChargeProrationPlugIn::ChargeOrCredit()";
		// error
		return Error(strErr);
	}

	// account subscribed to this charge in this interval, 
	// if actual starting date is later then start of charge interval
	// and we are not issuing a credit
	bool bSubscribedDuringInterval = ((!bIssueCredit || bIssueInitialCredit) && (tpRegular.GetStartDate() < tpActual.GetStartDate()));

    //If the end of the subscription is outside of the end of the period, then don't prorate instantly.
    bool bSubscribedForInstant = (tpRegular.GetStartDate() <= tpActual.GetStartDate()) && (tpActual.GetEndDate() > tpInstant.GetEndDate());

	// account unsubscribed from this charge in this interval, 
	// if actual end date is before then end of charge interval
	// or we are issuing a credit
    bool bUnsubscribedDuringInterval = ((bIssueCredit || bIssueInitialCredit) && (tpActual.GetStartDate() != tpRegular.GetStartDate())) || 
      (!bIssueCredit && (tpRegular.GetEndDate() > tpActual.GetEndDate()));


	// if we don't prorate on subscription, 
	// then just charge from the beginning of the regular interval
	if(!pRCD->mbProrateOnSubscription && bSubscribedDuringInterval)
	{
		tpActual.SetStartDate(tpRegular.GetStartDate());

		buffer = "Do not prorate on subscription"; 
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
	}
	else if (pRCD->mbProrateOnSubscription && bSubscribedDuringInterval)
	{
		buffer = "Prorate on subscription"; 
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
	} 
    else if (pRCD->mbProrateInstantly && bSubscribedForInstant) {
	    buffer = "Instant pro-rate";
	    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
    }
	
	// if we don't prorate on unsubscription, then just charge to the end of the interval
    //  We also have to prorate if this is an initial credit, because we might have moved
    // the start date from, say, 3/1 to 3/4, and we want to prorate those 3 days.
	if (!pRCD->mbProrateOnUnSubscription && bUnsubscribedDuringInterval && !bIssueInitialCredit && !bInitialDebit)
	{
		tpActual.SetEndDate(tpRegular.GetEndDate());

		// if we are trying to issue a credit, but don't prorate on subscription,
		// then no credit should be given
		if(bIssueCredit)
		{
			tpActual.SetStartDate(tpActual.GetEndDate());
		}

		buffer = "Do not prorate on unsubscription"; 
 		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
    }
	else
	{
		buffer = "Prorate on unsubscription"; 
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
	}

  // If we prorate instantly, set the end date to the actual end of the sub
  if (pRCD->mbProrateInstantly && bSubscribedForInstant)
  {
    tpActual.SetEndDate(tpInstant.GetEndDate());
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Instant date range now " + DateRangeString(tpActual));
  }

	// usually we just charge actual amount, but for accounts, unsubscribed from 
	// (charged) advanced charges we have to issue a credit.
	int iActualDays = tpActual.Days();

  // if actual number of days is the same as the regular number of days, then we do not prorate
	// because our proration resolution is 1 day.
	if (iActualDays == iRegularDays)
	{
		pRCD->mbProratedOnSubscription = false;
		pRCD->mbProratedOnUnSubscription = false;
        pRCD->mbProratedInstantly = false;
	}
	else
	{
        //Always prorate on sub or unsub for initial debit/credit, because those are for corrections.
        //  I.e. if we move the initial start date backward or forward, we must use the exact number
        //  of days that were moved, regardless of whether the prorateOnSub/Unsub flag is set
		pRCD->mbProratedOnSubscription = (pRCD->mbProrateOnSubscription || bInitialDebit || bIssueInitialCredit) && bSubscribedDuringInterval;
 		pRCD->mbProratedInstantly = pRCD->mbProrateInstantly && bSubscribedForInstant;
		pRCD->mbProratedOnUnSubscription = (pRCD->mbProrateOnUnSubscription || bInitialDebit || bIssueInitialCredit) && bUnsubscribedDuringInterval;
	}

	// make sure, that we don't prorate over fixed amount
	if(iActualDays > iRegularDays)
		iActualDays = iRegularDays;

	//Determine Daily Rate
	pRCD->mdProratedDailyRate = pRCD->mdRecurringChargeAmount / (long)iRegularDays;
	


	//If we are prorating, amount = DailyRate * ActualDays, otherwise it is just the full recurring charge amount
	if (pRCD->mbProratedOnSubscription || pRCD->mbProratedOnUnSubscription 	|| pRCD->mbProratedInstantly) 
	{
		pRCD->mdProratedRecurringChargeAmount = pRCD->mdProratedDailyRate * (long)iActualDays;
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Prorating.");
    }
	else
	{
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"NOT prorating.");
		pRCD->mdProratedRecurringChargeAmount = pRCD->mdRecurringChargeAmount;
	}

	//Is this a credit?
	if(bIssueCredit || bIssueInitialCredit)
	{
		pRCD->mdProratedRecurringChargeAmount = - pRCD->mdProratedRecurringChargeAmount;
	}


	pRCD->mdrProratedCharge = tpActual;
	pRCD->mlProratedDays = iActualDays;
  placeholder.clear();
	placeholder <<  "Prorated amount: " << pRCD->mdProratedRecurringChargeAmount.Format(); 
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, placeholder.str().c_str());
	//pRCD->mdProratedRecurringChargeAmount.Round(2);

	return hr;
}