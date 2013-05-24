// MTCalendar.cpp : Implementation of CMTCalendar
#include "StdAfx.h"
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#pragma warning(disable: 4297)  // disable warning "function assumed not to throw an exception but does"

#include "MTProductCatalog.h"
#include "MTCalendar.h"


/////////////////////////////////////////////////////////////////////////////
// CMTCalendar


CMTCalendar::CMTCalendar()
{
	m_pUnkMarshaler = NULL;
}

// FinalConstruct - besides the usual, we will also create the default week and weekend days for this calendar.
// Note that if you call CreateWeekday to create a day that already exists, then it returns the existing day
HRESULT CMTCalendar::FinalConstruct()
{

	HRESULT hr = S_OK;
	long enumID;
	_bstr_t dayEnumVal;
	long enumVal;

	try
	{

		hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &m_pUnkMarshaler.p);
		if (FAILED(hr))
			return hr;
	
		LoadPropertiesMetaData(PCENTITY_TYPE_CALENDAR);

		PutPropertyValue("ID", 0L);


		// Let's initialize the weekday collection with a default weekday and a default weekend
		MTPRODUCTCATALOGLib::IMTCalendarWeekdayPtr pWeekday;
		MTPRODUCTCATALOGLib::IMTCalendarWeekdayPtr pWeekend;
		MTPRODUCTCATALOGLib::IMTCalendarPtr thisCalPtr = this;
		MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
	
		// Setup default weekday
		enumID = enumConfig->GetID(L"metratech.com/calendar", L"CalendarCode", L"Off-Peak");
		dayEnumVal = enumConfig->GetEnumeratorValueByID(enumID);
		enumVal = atol((const char*) dayEnumVal); // The enum value is supposed to be a number
		pWeekday = thisCalPtr->CreateWeekday(CALENDARDAY_DEFAULTWEEKDAY);
		pWeekday->Code = enumVal;
		
		// Setup default weekend
		enumID = enumConfig->GetID(L"metratech.com/calendar", L"CalendarCode", L"Weekend");
		dayEnumVal = enumConfig->GetEnumeratorValueByID(enumID);
		enumVal = atol((const char*) dayEnumVal); // The enum value is supposed to be a number
		pWeekend = thisCalPtr->CreateWeekday(CALENDARDAY_DEFAULTWEEKEND);
		pWeekend->Code = enumVal;

	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
	return hr;
}

STDMETHODIMP CMTCalendar::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTCalendar,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTCalendar::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal);
}

STDMETHODIMP CMTCalendar::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTCalendar::get_Name(BSTR *pVal)
{
	return GetPropertyValue("Name", pVal);
}

STDMETHODIMP CMTCalendar::put_Name(BSTR newVal)
{
	return PutPropertyValue("Name", newVal);
}

STDMETHODIMP CMTCalendar::get_Description(BSTR *pVal)
{
	return GetPropertyValue("Description", pVal);
}

STDMETHODIMP CMTCalendar::put_Description(BSTR newVal)
{
	return PutPropertyValue("Description", newVal);
}

STDMETHODIMP CMTCalendar::get_TimezoneOffset(long *pVal)
{
	return GetPropertyValue("TimezoneOffset", pVal);
}

STDMETHODIMP CMTCalendar::put_TimezoneOffset(long newVal)
{
	return PutPropertyValue("TimezoneOffset", newVal);
}

STDMETHODIMP CMTCalendar::get_CombinedWeekend(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("CombinedWeekend", pVal);
}

STDMETHODIMP CMTCalendar::put_CombinedWeekend(VARIANT_BOOL newVal)
{
	return PutPropertyValue("CombinedWeekend", newVal);
}

// ----------------------------------------------------------------
// Name:          GetWeekday
// Arguments:    newVal (int) -> number representing weekday to add
//                
// Errors Raised: none
// Description: return desired weekday from collection. If weekday is not
//	in the collection, then return NULL. 
// ----------------------------------------------------------------

STDMETHODIMP CMTCalendar::GetWeekday(long newVal, IMTCalendarWeekday* *apWeekday)
{
	// here we need to:
	// 1-search for the desired weekday in the mWeekdays collection
	// 2-Return it or throw error

	if (!apWeekday)
		return E_POINTER;
	else
		*apWeekday = NULL;

	MTPRODUCTCATALOGLib::IMTCalendarWeekdayPtr weekdayptr;

	long count = 0;
	HRESULT hr = mWeekdays.Count(&count);
	if (FAILED(hr)) return hr;

	// If the desired day is not found, return NULL
	*apWeekday = NULL;

	for (long i = 1; i <= count; ++i) 	// collection indexes are 1-based
	{
		IMTCalendarWeekday* currweekday = NULL;
				
		hr = mWeekdays.Item(i, &currweekday);
		if (FAILED(hr)) return hr;
				
		weekdayptr.Attach(reinterpret_cast<MTPRODUCTCATALOGLib::IMTCalendarWeekday*>(currweekday));

		if ((weekdayptr->GetDayofWeek()) == newVal)
		{
			// We found the weekday on the collection in memory - return it
			*apWeekday = reinterpret_cast<IMTCalendarWeekday*>(weekdayptr.Detach());
			return S_OK;
		}
	}

	//We will not return a COM error, it is ok 
	//MT_THROW_COM_ERROR("MTCalendar","Could not retrieve weekday because it does not belong in this calendar");
	return hr;
}

// ----------------------------------------------------------------
// Name:          GetWeekdayorDefault
// Arguments:    newVal (int) -> number representing weekday to add
//                
// Errors Raised: none
// Description: return desired weekday from collection. If weekday is not
//	in the collection, then return the defaultweekend (if newVal is Sat or Sun)
//	or the defaultweekday otherwise 
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendar::GetWeekdayorDefault(long newVal, IMTCalendarWeekday* *apWeekday)
{
	HRESULT hr  S_OK;
	
	if (!apWeekday)
		return E_POINTER;
	else
		*apWeekday = NULL;

	MTPRODUCTCATALOGLib::IMTCalendarPtr thisCalPtr = this;
	MTPRODUCTCATALOGLib::IMTCalendarWeekdayPtr pWdayPtr = thisCalPtr->GetWeekday(newVal);
	
	if (pWdayPtr == NULL)
		{
			if ((newVal == CALENDARDAY_SUNDAY) || (newVal == CALENDARDAY_SATURDAY))	
				// Sat & Sun - Get the default weekend instead
				pWdayPtr = thisCalPtr->GetWeekday(CALENDARDAY_DEFAULTWEEKEND);
			else
				// Mon thru Fri - Fill it in with the default weekday
				pWdayPtr = thisCalPtr->GetWeekday(CALENDARDAY_DEFAULTWEEKDAY);
		}
	*apWeekday = reinterpret_cast<IMTCalendarWeekday*>(pWdayPtr.Detach());
	return hr;
}

// ----------------------------------------------------------------
// Name:          GetHoliday
// Arguments:    newVal (BSTR) -> name of holiday to retrieve
//                
// Errors Raised: none
// Description: return desired holiday from collection. If holiday is not
//	in the collection, then return NULL. 
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendar::GetHoliday(BSTR newVal, IMTCalendarHoliday* *apHoliday)
{
	// here we need to:
	// 1-search for the desired holidays in the mHolidays collection
	// 2-Return it or throw error

	HRESULT hr = S_OK;	

	if (!apHoliday)
		return E_POINTER;
	else
		*apHoliday = NULL;

	MTPRODUCTCATALOGLib::IMTCalendarHolidayPtr holidayptr;

	long count = 0;
	hr = mHolidays.Count(&count);
	if (FAILED(hr)) 
		return hr;

	for (long i = 1; i <= count; ++i) 	// collection indexes are 1-based
	{
		IMTCalendarHoliday* currHoliday = NULL;
				
		hr = mHolidays.Item(i, &currHoliday);
		if (FAILED(hr)) 
			return hr;
				
		holidayptr.Attach(reinterpret_cast<MTPRODUCTCATALOGLib::IMTCalendarHoliday*>(currHoliday));

		// If we don't find this holiday, return NULL
		*apHoliday = NULL;

		if (_bstr_t(holidayptr->GetName()) == _bstr_t(newVal))
		{
			// We found the Holiday on the collection in memory - return it
			*apHoliday = reinterpret_cast<IMTCalendarHoliday*>(holidayptr.Detach());
			return hr;
		}
	}

	//MT_THROW_COM_ERROR("MTCalendar","Could not retrieve holiday because it does not belong in this calendar");
	return hr;
}

// ----------------------------------------------------------------
// Name:          CreateWeekday
// Arguments:    newVal - weekday index representing desired day of week to create
//                
// Errors Raised: none
// Description: create weekday, add it to collection and return it.
// NOTE: If day is already in the collection, just return it
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendar::CreateWeekday(long newVal, IMTCalendarWeekday* *apWeekday)
{
	// here we need to:
	// 1-crate a new CalendarWeekday - if it exists, throw error
	// 2-set it's day property to newVal
	// 3-add it to the mWeekdays collection
	// 4-set the return value

	HRESULT hr = S_OK;

	// If the day to be created already belongs to the collection, we will return the current value.
	try
	{
		MTPRODUCTCATALOGLib::IMTCalendarPtr thisCalPtr = this;
		MTPRODUCTCATALOGLib::IMTCalendarWeekdayPtr wdPtr = thisCalPtr->GetWeekday(newVal);

		if (wdPtr == NULL)
			{
				MTPRODUCTCATALOGLib::IMTCalendarWeekdayPtr calWeekday(__uuidof(MTCalendarWeekday));
				wdPtr = calWeekday;
				wdPtr->PutDayofWeek(newVal);
				hr = mWeekdays.Add(reinterpret_cast<IMTCalendarWeekday*>(wdPtr.GetInterfacePtr()));
				if (FAILED(hr))
					return hr;
			}
			*apWeekday  = reinterpret_cast<IMTCalendarWeekday*>(wdPtr.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(), err);	
	}

	return hr;
}

// ----------------------------------------------------------------
// Name:          CreateWeekday
// Arguments:    newVal - weekday index representing desired day of week to create
//                
// Errors Raised: none
// Description: create weekday, add it to collection and return it.
// NOTE: If day is already in the collection, just return it
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendar::CreateHoliday(BSTR newVal, IMTCalendarHoliday* *apHoliday)
{
	// here we need to:
	// 1-crate a new CalendarHoliday
	// 2-set it's name property
	// 3-set it's date property 
	// 4-add it to the mHolidays collection
	
	HRESULT hr = S_OK;

	try
	{
	
		// Get smart pointer to this object
		MTPRODUCTCATALOGLib::IMTCalendarPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTCalendarHolidayPtr hdPtr;

		// Set the holiday's code to "holiday"
		MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
		long lVal = enumConfig->GetID(L"metratech.com/calendar", L"CalendarCode", L"Holiday");
		_bstr_t hdayEnumVal = enumConfig->GetEnumeratorValueByID(lVal);

		// Test if holiday with this name already exists...
		hdPtr = thisPtr->GetHoliday(newVal);
		if (hdPtr != NULL)
			{
				MT_THROW_COM_ERROR("MTCalendar","Holiday already exists, cannot create it");
				return E_FAIL;
			}

		// Looks like we have a valid enum id. Instantiate the new holiday and set it's properties
		MTPRODUCTCATALOGLib::IMTCalendarHolidayPtr calHoliday(__uuidof(MTCalendarHoliday));

		if (lVal > 0)
			calHoliday->PutCode(atol((const char*) hdayEnumVal));
		else {}
			// TODO: Throw error, calendar code enumtype not defined, or holiday is not there

		calHoliday->PutName(newVal);

		hr = mHolidays.Add(reinterpret_cast<IMTCalendarHoliday*>(calHoliday.GetInterfacePtr()));
		if (FAILED(hr))
			return hr;
		
		*apHoliday  = reinterpret_cast<IMTCalendarHoliday*>(calHoliday.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(), err);	
	}

	return hr;
}

// ----------------------------------------------------------------
// Name: RemoveWeekday
// Arguments: newVal
//                
// Errors Raised:
// Description: Removes weekday from collection
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendar::RemoveWeekday(long newVal)
{
	// here we need to:
	// 1-See if weekday exists in mWeekdays collection
	// 2-If so, remove it. Otherwise, throw error
	
	HRESULT hr = S_OK;
	MTPRODUCTCATALOGLib::IMTCalendarWeekdayPtr weekdayptr;

	long count = 0;
	hr = mWeekdays.Count(&count);
	if (FAILED(hr)) return hr;

	for (long i = 1; i <= count; ++i) 	// collection indexes are 1-based
	{
		IMTCalendarWeekday* currweekday = NULL;
				
		hr = mWeekdays.Item(i, &currweekday);
		if (FAILED(hr)) 
			return hr;
				
		weekdayptr.Attach(reinterpret_cast<MTPRODUCTCATALOGLib::IMTCalendarWeekday*>(currweekday));

		if ((weekdayptr->GetDayofWeek()) == newVal)
		{
			// We found the weekday on the collection in memory - remove it
			hr = mWeekdays.Remove(i);
			if (FAILED(hr)) 
				return hr;
			return S_OK;
		}
	}

	MT_THROW_COM_ERROR("MTCalendar","Could not remove weekday because it does not belong in this calendar");
	return E_FAIL;

}

// ----------------------------------------------------------------
// Name: RemoveHoliday
// Arguments: newVal
//                
// Errors Raised:
// Description: Removes Holiday from collection
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendar::RemoveHoliday(BSTR newVal)
{
	// here we need to:
	// 1-See if holiday exists in mHolidays collection
	// 2-If so, remove it. Otherwise, throw error

	HRESULT hr = S_OK;
	MTPRODUCTCATALOGLib::IMTCalendarHolidayPtr holidayptr;

	long count = 0;
	hr = mHolidays.Count(&count);
	if (FAILED(hr)) return hr;

	for (long i = 1; i <= count; ++i) 	// collection indexes are 1-based
	{
		IMTCalendarHoliday* currHoliday = NULL;
				
		hr = mHolidays.Item(i, &currHoliday);
		if (FAILED(hr)) 
			return hr;
				
		holidayptr.Attach(reinterpret_cast<MTPRODUCTCATALOGLib::IMTCalendarHoliday*>(currHoliday));

		if (_bstr_t(holidayptr->GetName()) == _bstr_t(newVal))
		{
			// We found the Holiday on the collection in memory - remove it
			hr = mHolidays.Remove(i);
			if (FAILED(hr)) 
				return hr;
			return S_OK;
		}
	}

	//return ERROR("Can not remove Holiday because it was not found in the collection");
	MT_THROW_COM_ERROR("MTCalendar","Could not remove holiday because it does not belong in this calendar");
	return E_FAIL;

}

// ----------------------------------------------------------------
// Name: GetWeekdays
// Arguments: 
//
// Returns: Weekdays IMTCollection                
// Errors Raised: 
// Description: just returns Weekdays collection
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendar::GetWeekdays(IMTCollection* *apWeekdayColl)
{
	// here we need to:
	// 1-Create new MTCollection with mWeekdays values
	// 2-Return it

	if (!apWeekdayColl)
		return E_POINTER;
	else
		*apWeekdayColl = NULL;

	try
	{
		return mWeekdays.CopyTo(apWeekdayColl);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
}

// ----------------------------------------------------------------
// Name: GetHolidays
// Arguments: 
//
// Returns: Holidays IMTCollection                
// Errors Raised: 
// Description: just returns Holidays collection
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendar::GetHolidays(IMTCollection* *apHolidayColl)
{
	// here we need to:
	// 1-Create new MTCollection with mHolidays values
	// 2-Return it

	if (!apHolidayColl)
		return E_POINTER;
	else
		*apHolidayColl = NULL;

	try
	{
		return mHolidays.CopyTo(apHolidayColl);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
}

// ----------------------------------------------------------------
// Name: Validate
// Arguments: 
//
// Returns: boolean indicating if this calendar is valid (and thus ready to be saved)
// Errors Raised: 
// Description: Validate the following calendar properties:
//									1-Is this name already used by another calendar?
//									2-Is the period collection valid for each weekday and holiday?
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendar::Validate(VARIANT_BOOL* pVal)
{
	HRESULT hr = S_OK;
	*pVal = VARIANT_TRUE;
	
	MTPRODUCTCATALOGLib::IMTCalendarPtr thisPtr = this;
	MTPRODUCTCATALOGEXECLib::IMTCalendarReaderPtr pCalReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTCalendarReader));
	
	// Check for duplicate calendar name
	MTPRODUCTCATALOGLib::IMTCalendarPtr tmpCalPtr = pCalReader->GetCalendarByName(GetSessionContextPtr(), thisPtr->Name);
	
	if ((tmpCalPtr != NULL) && (tmpCalPtr->ID != thisPtr->ID))
		{
			*pVal = VARIANT_FALSE;
			MT_THROW_COM_ERROR(IID_IMTCalendar, MTPCUSER_CALENDAR_WITHNAME_ALREADY_EXISTS, (const char*) thisPtr->Name);
		}
	
	return hr;
}

STDMETHODIMP CMTCalendar::Save()
{
	try
	{
		//validate properties based on their meta data (required, length, ...)
		//throws _com_error on failure
		ValidateProperties();
		
		//Validate Calendar properties, like name, values of calendar periods, etc...
		VARIANT_BOOL isValid;
		Validate(&isValid);
		
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTCalendarWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTCalendarWriter));
		writer->Save(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCalendar*>(this));
		
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(), err); 
	}	

	return S_OK;
}
