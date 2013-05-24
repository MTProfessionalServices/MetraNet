// MTCalendarWeekday.cpp : Implementation of CMTCalendarWeekday
#include "StdAfx.h"
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalog.h"
#include "MTCalendarWeekday.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarWeekday


HRESULT CMTCalendarWeekday::FinalConstruct()
{
	try
	{
		LoadPropertiesMetaData(PCENTITY_TYPE_CALENDARWEEKDAY);

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
}

STDMETHODIMP CMTCalendarWeekday::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTCalendarWeekday,
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

STDMETHODIMP CMTCalendarWeekday::get_DayofWeek(long *pVal)
{
	return GetPropertyValue("DayofWeek", pVal);
}

STDMETHODIMP CMTCalendarWeekday::put_DayofWeek(long newVal)
{
	return PutPropertyValue("DayofWeek", newVal);
}

STDMETHODIMP CMTCalendarWeekday::GetDayofWeekAsString(BSTR* pVal)
{
	// TODO: Make weekdays enumerated types - These are hardcoded only temporarily
	HRESULT hr = S_OK;
	_bstr_t dayname;
	long dofweek = 0;
	hr = get_DayofWeek(&dofweek);
	
	switch(dofweek)
	{
		case 0:	
			dayname = "Sunday";
			break;		
		case 1:	
			dayname = "Monday";
			break;
		case 2:	
			dayname = "Tuesday";
			break;
		case 3:	
			dayname = "Wednesday";
			break;
		case 4:	
			dayname = "Thursday";
			break;
		case 5:	
			dayname = "Friday";
			break;
		case 6:	
			dayname = "Saturday";
			break;
		case 7:	
			dayname = "Default Weekday";
			break;
		case 8:	
			dayname = "Default Weekend";
			break;
	}
	*pVal = dayname.copy();
	return hr;
}

