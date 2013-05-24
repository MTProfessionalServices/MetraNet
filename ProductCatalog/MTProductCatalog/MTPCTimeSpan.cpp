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

#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalog.h"
#include "MTPCTimeSpan.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPCTimeSpan

/******************************************* error interface ***/
STDMETHODIMP CMTPCTimeSpan::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTPCTimeSpan,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/********************************** construction/destruction ***/
CMTPCTimeSpan::CMTPCTimeSpan()
{
	mUnkMarshalerPtr = NULL;
}

HRESULT CMTPCTimeSpan::FinalConstruct()
{
	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mUnkMarshalerPtr.p);
		if (FAILED(hr))
			throw _com_error(hr);

		mStartDateTypeConstraint = PCDATE_TYPE_NO_DATE; // unconstrained
		mEndDateTypeConstraint = PCDATE_TYPE_NO_DATE; // unconstrained

		LoadPropertiesMetaData( PCENTITY_TYPE_TIME_SPAN );
	}	
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

void CMTPCTimeSpan::FinalRelease()
{
	mUnkMarshalerPtr.Release();
}


// initialize the timespan object for its intended use
// meant to be called by owning object to set up special constraints
// if this function is not called object will be intialized to:
//   "unconstrained", initial value: PCDATE_TYPE_NULL
STDMETHODIMP CMTPCTimeSpan::Init(MTPCDateType aStartDateTypeConstraint, MTPCDateType aInitialStartDateType,
																 MTPCDateType aEndDateTypeConstraint,   MTPCDateType aInitialEndDateType)
{
	mStartDateTypeConstraint = aStartDateTypeConstraint;
	mEndDateTypeConstraint = aEndDateTypeConstraint;

	put_StartDateType(aInitialStartDateType);
	put_EndDateType(aInitialEndDateType);

	return S_OK;
}

/********************************** IMTPCTimeSpan ***/
STDMETHODIMP CMTPCTimeSpan::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal);
}

STDMETHODIMP CMTPCTimeSpan::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTPCTimeSpan::get_StartDateType(MTPCDateType *pVal)
{
	return GetPropertyValue("StartDateType", reinterpret_cast<long*>(pVal));
}

STDMETHODIMP CMTPCTimeSpan::put_StartDateType(MTPCDateType newVal)
{
	return PutPropertyValue("StartDateType", static_cast<long>(newVal));
}
STDMETHODIMP CMTPCTimeSpan::get_StartDate(DATE *pVal)
{
	return GetPropertyValue("StartDate", pVal);
}

STDMETHODIMP CMTPCTimeSpan::put_StartDate(DATE newVal)
{
	return PutPropertyValue("StartDate", newVal);
}

STDMETHODIMP CMTPCTimeSpan::get_StartOffset(long *pVal)
{
	return GetPropertyValue("StartOffset", pVal);
}

STDMETHODIMP CMTPCTimeSpan::put_StartOffset(long newVal)
{
	return PutPropertyValue("StartOffset", newVal);
}

STDMETHODIMP CMTPCTimeSpan::get_EndDateType(MTPCDateType *pVal)
{
	return GetPropertyValue("EndDateType", reinterpret_cast<long*>(pVal));
}

STDMETHODIMP CMTPCTimeSpan::put_EndDateType(MTPCDateType newVal)
{
	return PutPropertyValue("EndDateType", static_cast<long>(newVal));
}

STDMETHODIMP CMTPCTimeSpan::get_EndDate(DATE *pVal)
{
	return GetPropertyValue("EndDate", pVal);
}

STDMETHODIMP CMTPCTimeSpan::put_EndDate(DATE newVal)
{
	return PutPropertyValue("EndDate", newVal);
}

STDMETHODIMP CMTPCTimeSpan::get_EndOffset(long *pVal)
{
	return GetPropertyValue("EndOffset", pVal);
}

STDMETHODIMP CMTPCTimeSpan::put_EndOffset(long newVal)
{
	return PutPropertyValue("EndOffset", newVal);
}

STDMETHODIMP CMTPCTimeSpan::SetStartDateNull()
{
	HRESULT hr = put_StartDateType(PCDATE_TYPE_NULL);
	if (FAILED(hr))
		return hr;
	return put_StartDate( 0.0 );
}

STDMETHODIMP CMTPCTimeSpan::IsStartDateNull(VARIANT_BOOL* pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = VARIANT_FALSE;

	DATE dt = 0.0;
	HRESULT hr = get_StartDate(&dt);
	if (SUCCEEDED(hr) && dt == 0.0)
		*pVal = VARIANT_TRUE;

	return hr;
}

STDMETHODIMP CMTPCTimeSpan::SetEndDateNull()
{
	HRESULT hr = put_EndDateType(PCDATE_TYPE_NULL);
	if (FAILED(hr))
		return hr;
	return put_EndDate( 0.0 );
}

STDMETHODIMP CMTPCTimeSpan::IsEndDateNull(VARIANT_BOOL* pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = VARIANT_FALSE;

	DATE dt = 0.0;
	HRESULT hr = get_EndDate(&dt);
	if (SUCCEEDED(hr) && dt == 0.0)
		*pVal = VARIANT_TRUE;

	return hr;
}

STDMETHODIMP CMTPCTimeSpan::IsEndBeforeStart(VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = VARIANT_FALSE;

	try
	{

		MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr thisPtr = this;

		MTPRODUCTCATALOGLib::MTPCDateType startDateType = thisPtr->StartDateType;
		MTPRODUCTCATALOGLib::MTPCDateType endDateType = thisPtr->EndDateType;

		// compare absolute and next_billing_period types against each other
		// (note a null date has its own type)
		if ((startDateType == MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE || startDateType == MTPRODUCTCATALOGLib::PCDATE_TYPE_NEXT_BILLING_PERIOD) &&
				(endDateType == MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE || endDateType == MTPRODUCTCATALOGLib::PCDATE_TYPE_NEXT_BILLING_PERIOD))
		{
			DATE startDate = thisPtr->StartDate;
			DATE endDate = thisPtr->EndDate;
			
			if (endDate < startDate)
			{	*pVal = VARIANT_TRUE;
				return S_OK;
			}
			else
			{	*pVal = VARIANT_FALSE;
				return S_OK;
			}
		}

		// compare SUBSCRIPTION_RELATIVE dates against each other
		if (startDateType == PCDATE_TYPE_SUBSCRIPTION_RELATIVE &&
				endDateType == PCDATE_TYPE_SUBSCRIPTION_RELATIVE)
		{
			long startOffset = thisPtr->StartOffset;
			long endOffset = thisPtr->EndOffset;
			if (endOffset < startOffset)
			{	*pVal = VARIANT_TRUE;
				return S_OK;
			}
			else
			{	*pVal = VARIANT_FALSE;
				return S_OK;
			}
		}
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

// normalizes members and validates settings
// on failure sets com_error
STDMETHODIMP CMTPCTimeSpan::Validate()
{
	try
	{
		MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr thisPtr = this;

		// normalize before validating to fix up inconsistent members (eg. PCDATE_TYPE_NULL)
		thisPtr->Normalize();


		// enforce busrule #25:
		// prohibit mixing subscr. relative date with a non-subscription relative date
		MTPRODUCTCATALOGLib::MTPCDateType startDateType = thisPtr->StartDateType;
		MTPRODUCTCATALOGLib::MTPCDateType endDateType = thisPtr->EndDateType;
		if( PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_EffDate_CheckDateCompatibility))
		{
			if ((startDateType == PCDATE_TYPE_SUBSCRIPTION_RELATIVE && endDateType != PCDATE_TYPE_SUBSCRIPTION_RELATIVE) ||
					(startDateType != PCDATE_TYPE_SUBSCRIPTION_RELATIVE && endDateType == PCDATE_TYPE_SUBSCRIPTION_RELATIVE))
			{
				MT_THROW_COM_ERROR(MTPCUSER_INCOMPATIBLE_DATE_COMBINATION);		
			}
		}

		// enforce busrule #22 Start Date less than End Date
		if( PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_EffDate_NoEndBeforeStart))
		{
			if (thisPtr->IsEndBeforeStart() == VARIANT_TRUE)
			{
				MT_THROW_COM_ERROR(MTPCUSER_END_DATE_BEFORE_START_DATE);		
			}
		}

	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

// normalizes members 
// on failure sets com_error
STDMETHODIMP CMTPCTimeSpan::Normalize()
{
	try
	{
		MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr thisPtr = this;

		// normalize all values 

		// if type is constrained, don't require types to be set
		switch(mStartDateTypeConstraint)
		{	
			case PCDATE_TYPE_NO_DATE: //unconstrained
				//no special logic
				break;

			case PCDATE_TYPE_ABSOLUTE:
			case PCDATE_TYPE_NEXT_BILLING_PERIOD:
				// figure out type depending on value
				if (thisPtr->StartDate == 0.0)
				{	if (thisPtr->StartDateType != MTPRODUCTCATALOGLib::PCDATE_TYPE_NO_DATE) //don't change NO_DATE type 
						thisPtr->StartDateType = MTPRODUCTCATALOGLib::PCDATE_TYPE_NULL;
				}
				else
					thisPtr->StartDateType = (MTPRODUCTCATALOGLib::MTPCDateType)mStartDateTypeConstraint;
				break;

			default:
				MT_THROW_COM_ERROR( "unsupported type constrain: %d", mStartDateTypeConstraint);
		}

		switch(mEndDateTypeConstraint)
		{	
			case PCDATE_TYPE_NO_DATE: //unconstrained
				//no special logic
				break;

			case PCDATE_TYPE_ABSOLUTE:
			case PCDATE_TYPE_NEXT_BILLING_PERIOD:
				// figure out type depending on value
				if (thisPtr->EndDate == 0.0)
				{	if (thisPtr->EndDateType != PCDATE_TYPE_NO_DATE) //don't change NO_DATE type 
						thisPtr->EndDateType = MTPRODUCTCATALOGLib::PCDATE_TYPE_NULL;
				}
				else
					thisPtr->EndDateType = (MTPRODUCTCATALOGLib::MTPCDateType)mEndDateTypeConstraint;
				break;

			default:
				MT_THROW_COM_ERROR( "unsupported type constrain: %d", mEndDateTypeConstraint);
		}

		MTPRODUCTCATALOGLib::MTPCDateType startDateType = thisPtr->StartDateType;
		MTPRODUCTCATALOGLib::MTPCDateType endDateType = thisPtr->EndDateType;

		// clear out not used properties, set type correctly
		switch(startDateType)
		{	
			case PCDATE_TYPE_NULL:
				thisPtr->StartDate = 0.0;
				thisPtr->StartOffset = 0;
				break;

			case PCDATE_TYPE_ABSOLUTE:
			case PCDATE_TYPE_NEXT_BILLING_PERIOD:
				thisPtr->StartOffset = 0;
				if (thisPtr->StartDate == 0.0)
					thisPtr->StartDateType = MTPRODUCTCATALOGLib::PCDATE_TYPE_NULL;
				break;

			case PCDATE_TYPE_SUBSCRIPTION_RELATIVE:
				thisPtr->StartDate = 0.0;
				break;
		}

		switch(endDateType)
		{	
			case PCDATE_TYPE_NULL:
				thisPtr->EndDate = 0.0;
				thisPtr->EndOffset = 0;
				break;

			case PCDATE_TYPE_ABSOLUTE:
			case PCDATE_TYPE_NEXT_BILLING_PERIOD:
				thisPtr->EndOffset = 0;
				if (thisPtr->EndDate == 0.0)
					thisPtr->EndDateType = MTPRODUCTCATALOGLib::PCDATE_TYPE_NULL;
				break;

			case PCDATE_TYPE_SUBSCRIPTION_RELATIVE:
				thisPtr->EndDate = 0.0;
				break;
		}

	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}
