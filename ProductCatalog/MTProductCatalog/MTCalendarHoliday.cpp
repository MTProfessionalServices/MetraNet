// MTCalendarHoliday.cpp : Implementation of CMTCalendarHoliday
#include "StdAfx.h"
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalog.h"
#include "MTCalendarHoliday.h"
#include <MTDate.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarHoliday

STDMETHODIMP CMTCalendarHoliday::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCalendarHoliday,
    &IID_IMTCalendarDay,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCalendarHoliday::FinalConstruct()
{
	try
	{
		LoadPropertiesMetaData(PCENTITY_TYPE_CALENDARHOLIDAY);

		//PutPropertyValue("ID", 0L);
		
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
		
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}

}

STDMETHODIMP CMTCalendarHoliday::get_Name(BSTR *pVal)
{
	return GetPropertyValue("Name", pVal);
}

STDMETHODIMP CMTCalendarHoliday::put_Name(BSTR newVal)
{
	return PutPropertyValue("Name", newVal);
}

// ----------------------------------------------------------------
// Name: Get & Put Day
// Arguments: 
//
// Returns: 
// Errors Raised: 
// Description: Property Methods to set & get the day of the year for this holiday
// Note: In the future, different types of holidays might be implemented. In the case
//					of a holiday like "second monday of april", this property might also hold
//				  the weekday (in this sample, monday or 6)								
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarHoliday::get_Day(long *pVal)
{
	return GetPropertyValue("Day", pVal);
}

STDMETHODIMP CMTCalendarHoliday::put_Day(long newVal)
{
	return PutPropertyValue("Day", newVal);
}

// ----------------------------------------------------------------
// Name: Get & Put WeekofMonth
// Arguments: 
//
// Returns: 
// Errors Raised: 
// Description: In the future, different types of holidays might be implemented.
//									If this property is NULL, then the holiday is like xmas: mm/dd/yyyy (in the future, year might be optional too)
//									If this property is not NULL, it will flag that this holiday is of the type "second monday of may", and it will hold
//									the week of the month that the holiday falls on
// ----------------------------------------------------------------

STDMETHODIMP CMTCalendarHoliday::get_WeekofMonth(long *pVal)
{
	return GetPropertyValue("WeekofMonth", pVal);
}

STDMETHODIMP CMTCalendarHoliday::put_WeekofMonth(long newVal)
{
	return PutPropertyValue("WeekofMonth", newVal);
}

STDMETHODIMP CMTCalendarHoliday::get_Month(long *pVal)
{
	return GetPropertyValue("Month", pVal);
}

STDMETHODIMP CMTCalendarHoliday::put_Month(long newVal)
{
	return PutPropertyValue("Month", newVal);
}

// ----------------------------------------------------------------
// Name: Get & Put Year
// Arguments: 
//
// Returns: 
// Errors Raised: 
// Description: Year that the holiday falls on. Right now, it is necessary,
//									but in the future it might be optional, meaning the holiday
//									is recurring
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarHoliday::get_Year(long *pVal)
{
	return GetPropertyValue("Year", pVal);
}

STDMETHODIMP CMTCalendarHoliday::put_Year(long newVal)
{
	return PutPropertyValue("Year", newVal);
}

// ----------------------------------------------------------------
// Name: Get & Put Date
// Arguments: 
//
// Returns: 
// Errors Raised: 
// Description: Translate a Date into and from the properties above (day, month, year)
//
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarHoliday::get_Date(DATE *pVal)
{
	// This is not a property, it is a date constructed with the properties above	
	HRESULT hr = S_OK;

	// TODO: Add support for other holiday types : recurring, 2nd monday of june, etc...
	MTDate hdate;
	long ndate;

	hr = get_Day(&ndate);
	hdate.SetDay(ndate);
	hr = get_Month(&ndate);
	hdate.SetMonth(ndate);
	hr = get_Year(&ndate);
	hdate.SetYear(ndate);

	*pVal = hdate.GetOLEDate();

	return hr;
}

STDMETHODIMP CMTCalendarHoliday::put_Date(DATE newVal)
{
	HRESULT hr = S_OK;	
	MTDate hdate(newVal);

	hr = put_Day(hdate.GetDay());
	hr = put_Month(hdate.GetMonth());
	hr = put_Year(hdate.GetYear());

	// This is not a property, all we do is parse the date above and set the properties above correctly
	return hr;
}

