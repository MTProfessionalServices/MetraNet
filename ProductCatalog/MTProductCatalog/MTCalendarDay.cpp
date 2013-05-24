// MTCalendarDay.cpp : Implementation of CMTCalendarDay
#include "StdAfx.h"
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#pragma warning(disable: 4297)  // disable warning "function assumed not to throw an exception but does"

#include "MTProductCatalog.h"
#include "MTCalendarDay.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarDay

STDMETHODIMP CMTCalendarDay::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal);
}

STDMETHODIMP CMTCalendarDay::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

// ----------------------------------------------------------------
// Name: get_Code
// Arguments: 
//
// Returns: long pVal, which is the default calendar code value for this day
// Errors Raised: 
// Description: Looks up enum value based on enum_id stored in property, then returns it
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarDay::get_Code(long *pVal)
{
	HRESULT hr = S_OK;
	long lVal;
	_bstr_t enumvalue = "";

	hr = GetPropertyValue("Code", &lVal);
	if (FAILED(hr))
		return hr;

	MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
	
	try
		{
			enumvalue = enumConfig->GetEnumeratorValueByID(lVal);
		}
	catch (_com_error & err)
		{
			MT_THROW_COM_ERROR(IID_IMTCalendarDay, MTPC_CANNOT_FIND_ENUM_FOR_CALENDARCODE, lVal);
			return LogAndReturnComError(PCCache::GetLogger(), err);	
		}

	*pVal = atol((const char*) enumvalue);

	return hr;
}

STDMETHODIMP CMTCalendarDay::put_Code(long newVal)
{
	long lVal = -1;
	try
		{
			MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
			lVal = enumConfig->GetID(L"metratech.com/calendar", L"CalendarCode", _bstr_t(newVal));
		}
	catch (_com_error & err)
		{
			MT_THROW_COM_ERROR(IID_IMTCalendarPeriod, MTPC_CANNOT_FIND_ENUM_FOR_CALENDARCODE, newVal);
			return LogAndReturnComError(PCCache::GetLogger(), err);
		}
		
	return PutPropertyValue("Code", lVal);
}

// ----------------------------------------------------------------
// Name: get_CodeAsString
// Arguments: 
//
// Returns: BSTR pVal, which is the default calendar code for this da
// Errors Raised: 
// Description: Looks up enum name based on enum_id stored in property, then returns it
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarDay::GetCodeAsString(BSTR* pVal)
{
	long icode, lVal;
	HRESULT hr = S_OK;
	hr = get_Code(&icode);
	if (FAILED(hr))
		return hr;

	try
		{
			MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
			lVal = enumConfig->GetID(L"metratech.com/calendar", L"CalendarCode", _bstr_t(icode));
			_bstr_t calcode = enumConfig->GetEnumeratorByID(lVal);
			*pVal = calcode.copy();
		}
	catch (_com_error & err)
		{
			return LogAndReturnComError(PCCache::GetLogger(), err);	
		}

	return hr;
}

// ----------------------------------------------------------------
// Name: CreatePeriod
// Arguments: 
//
// Returns: IMTCalendarPeriod apCalPeriod
// Errors Raised: 
// Description: Creates a new IMTCalendarPeriod and adds it to the collection
//									for this day
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarDay::CreatePeriod(IMTCalendarPeriod* *apCalPeriod)
{
	HRESULT hr = S_OK;

	try
	{
		MTPRODUCTCATALOGLib::IMTCalendarPeriodPtr calPeriod(__uuidof(MTCalendarPeriod));
	
		hr = mPeriods.Add(reinterpret_cast<IMTCalendarPeriod*>(calPeriod.GetInterfacePtr()));
		if (FAILED(hr))
			return hr;
		
		*apCalPeriod  = reinterpret_cast<IMTCalendarPeriod*>(calPeriod.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(), err);	
	}

	return hr;	
}

// ----------------------------------------------------------------
// Name: RemovePeriod
// Arguments: periodStartTime
//
// Returns:
// Errors Raised: 
// Description: Removes a period from the collection based on starttime
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarDay::RemovePeriod(long periodStartTime)
{
	HRESULT hr = S_OK;
	MTPRODUCTCATALOGLib::IMTCalendarPeriodPtr periodptr;

	long count = 0;
	hr = mPeriods.Count(&count);
	if (FAILED(hr)) return hr;

	for (long i = 1; i <= count; ++i) 	// collection indexes are 1-based
	{
		IMTCalendarPeriod* currPeriod = NULL;
				
		hr = mPeriods.Item(i, &currPeriod);
		if (FAILED(hr)) 
			return hr;
				
		periodptr.Attach(reinterpret_cast<MTPRODUCTCATALOGLib::IMTCalendarPeriod*>(currPeriod));

		if ((periodptr->GetStartTime()) == periodStartTime)
		{
			// We found the Period on the collection in memory - remove it
			hr = mPeriods.Remove(i);
			if (FAILED(hr)) 
				return hr;
			return S_OK;
		}
	}

	MT_THROW_COM_ERROR("MTCalendarDay","Could not remove Period");
	return hr;
}

// ----------------------------------------------------------------
// Name: GetPeriods
// Arguments: 
//
// Returns: IMTCalendarPeriodCollection ptr
// Errors Raised: 
// Description: Returns the period collection for this day
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarDay::GetPeriods(IMTCollection** apPeriodColl)
{

	if (!apPeriodColl)
		return E_POINTER;
	else
		*apPeriodColl = NULL;

	try
	{
		mPeriods.Sort();
		return mPeriods.CopyTo(apPeriodColl);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

// ----------------------------------------------------------------
// Name: ValidatePeriodTimes
// Arguments:
//
// Returns: Boolean indicating if those start and end can be used as a period
//						 on this collection
// Errors Raised:
// Description: Validates start and end times against current period collection
//									checks for: overlaps, and semantic errors
// ----------------------------------------------------------------

STDMETHODIMP CMTCalendarDay::ValidatePeriodTimes(IMTCalendarDay* thisDay, long startVal, long endVal, VARIANT_BOOL* pVal)
{
	HRESULT hr = S_OK;
	*pVal = VARIANT_TRUE;

	try
	{

		// We can not have a period with negative duration
		if (endVal <= startVal)
			MT_THROW_COM_ERROR(IID_IMTCalendarDay, MTPCUSER_PERIODSTART_MUSTBE_BEFORE_PERIODEND);

		MTPRODUCTCATALOGLib::IMTCalendarDayPtr thisPtr = thisDay;
		
		// Note: the call to the function below returns a sorted period collection by Start Time
		MTPRODUCTCATALOGLib::IMTCollectionPtr collPtr = thisPtr->GetPeriods();
		
		long aCount = collPtr->GetCount();
	  if (aCount == 0) // No periods in collection, return aCount
			{
				*pVal = VARIANT_TRUE;
				return hr;
			}

		MTPRODUCTCATALOGLib::IMTCalendarPeriodPtr periodPtr;

		// There is at least one period in the collection already. Iterate the collection and see if there is room for the new period
		long ii = 1;
		long range = 0;
		while (ii <= aCount)
			{
				periodPtr = collPtr->GetItem(ii);
				
				// Algorithm to detect if the startVal and endVal have room in this collection of periods
				// Basically, I test to see if the sum of the sizes of "period n" and the new period (endVal - startVal)
				// is less than the maximum range occupied by both of these periods. If it is, then we a re fine, otherwise
				// they overlap at some point.

				if (periodPtr->EndTime > endVal)
					range = (periodPtr->EndTime - startVal);
				else
					range = (endVal - periodPtr->StartTime);

				// Test if the (total) range is less then the sum of the individual durations
				*pVal = (VARIANT_BOOL) (range >= ((periodPtr->EndTime - periodPtr->StartTime) + (endVal - startVal)));

				// If the sum of ranges is greater than the total range, then throw an error: they overlap
				if (*pVal == VARIANT_FALSE)
					{
						MT_THROW_COM_ERROR(IID_IMTCalendarDay, MTPCUSER_PERIODS_OVERLAP);
					}
				ii++;
			}
		}
	catch (_com_error & err)
		{
			return LogAndReturnComError(PCCache::GetLogger(),err);
		}

	return hr;
}