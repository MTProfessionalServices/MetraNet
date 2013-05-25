/**************************************************************************
 * @doc CONFIGUREDCAL
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <ConfiguredCal.h>

#include <SetIterate.h>
#include <MTUtil.h>

#include <mtprogids.h>

#include <mtzoneinfo.h>

#include <ConfigDir.h>

using namespace MTCALENDARLib;

/**************************************** ConfiguredCalendar ***/

BOOL ConfiguredCalendar::Setup(const char * apPathname, const char * apFilename)
{
	try
	{
		// initialize the timezone library with the correct directory
		// TODO: set this somewhere else
		string tzdir;
		if (!GetMTConfigDir(tzdir))
			// TODO: SetError
			return FALSE;

		tzdir += "\\timezone\\zoneinfo";
		settzdir(tzdir.c_str());


		HRESULT hr = mCalendar.CreateInstance(MTPROGID_USERCALENDAR);
		if (FAILED(hr))
		// TODO: SetError
			return FALSE;

		mCalendar->Read(apPathname, apFilename);

		IMTTimezonePtr timezone = mCalendar->GetTimezone();
		if (timezone->GetTimezoneID() != 0)
		{
			string tz = TranslateZone(timezone->GetTimezoneID());
			if (tz.length() == 0)
			{
#if 0
				char buffer[256];
				sprintf("Unsupported timezone ID %d", timezone->GetTimezoneID());
#endif
				return FALSE;
			}

			UseFixedOffset(tz.c_str());
		}
		else
			UseFloatingOffset();
	}
	catch (_com_error err)
	{
		// TODO: SetError
		return FALSE;
	}
	return TRUE;
}

BOOL ConfiguredCalendar::CreateYear(CalendarYear * apYear, int aYear)
{
	try
	{
		// create a day for each of the week days
		CalendarDay * weekdays[7];
		for (int i = 0; i < sizeof(weekdays) / sizeof(weekdays[0]); i++)
		{
			weekdays[i] = new CalendarDay;
			apYear->OwnDay(weekdays[i]);
		}
	
		IMTRangeCollectionPtr defaultWeekday = mCalendar->GetDefaultWeekday();
		IMTRangeCollectionPtr defaultWeekend = mCalendar->GetDefaultWeekend();

		IMTRangeCollectionPtr rangeCollection = mCalendar->GetSunday();
		if (rangeCollection == NULL)
			rangeCollection = defaultWeekend;
		if (!DayFromRangeCollection(weekdays[0], rangeCollection))
			return FALSE;

		rangeCollection = mCalendar->GetMonday();
		if (rangeCollection == NULL)
			rangeCollection = defaultWeekday;
		if (!DayFromRangeCollection(weekdays[1], rangeCollection))
			return FALSE;

		rangeCollection = mCalendar->GetTuesday();
		if (rangeCollection == NULL)
			rangeCollection = defaultWeekday;
		if (!DayFromRangeCollection(weekdays[2], rangeCollection))
			return FALSE;

		rangeCollection = mCalendar->GetWednesday();
		if (rangeCollection == NULL)
			rangeCollection = defaultWeekday;
		if (!DayFromRangeCollection(weekdays[3], rangeCollection))
			return FALSE;

		rangeCollection = mCalendar->GetThursday();
		if (rangeCollection == NULL)
			rangeCollection = defaultWeekday;
		if (!DayFromRangeCollection(weekdays[4], rangeCollection))
			return FALSE;

		rangeCollection = mCalendar->GetFriday();
		if (rangeCollection == NULL)
			rangeCollection = defaultWeekday;
		if (!DayFromRangeCollection(weekdays[5], rangeCollection))
			return FALSE;

		rangeCollection = mCalendar->GetSaturday();
		if (rangeCollection == NULL)
			rangeCollection = defaultWeekend;
		if (!DayFromRangeCollection(weekdays[6], rangeCollection))
			return FALSE;

		// fill in each day with the correct weekday
		apYear->AssignWeekdays(aYear, weekdays, FALSE);


		SetIterator<IMTUserCalendarPtr, IMTCalendarDatePtr> it;
		HRESULT hr = it.Init(mCalendar);
		if (FAILED(hr))
		{
			// TODO: set error
			return FALSE;
		}

		// go through each day called out by date
		while (TRUE)
		{
			IMTCalendarDatePtr date = it.GetNext();
			if (date == NULL)
				break;

			DATE oledate = date->GetDate();
			UDATE udate;
			HRESULT hr = ::VarUdateFromDate(oledate, NULL, &udate);
			ASSERT(SUCCEEDED(hr));

			if (udate.st.wYear - 1900 == aYear)
				// TODO: or if it's recurring!
			{
				// get the day of year
				// TODO: is this correct?
				int dayOfYear = udate.wDayOfYear - 1;
				
				CalendarDay * newDay = new CalendarDay;
				apYear->OwnDay(newDay);

#if 0
				newDay->FillGapsWithCode("Holiday");
#else
				rangeCollection = date->GetRangeCollection();
				if (!DayFromRangeCollection(newDay, rangeCollection))
					return FALSE;
#endif

				apYear->SetDay(dayOfYear, newDay);
			}
		}
	}
	catch (_com_error err)
	{
		// weekday array is owned by the year so we don't have to deal
		// with deleting them

		// TODO: SetError
		return FALSE;
	}


	return TRUE;
}

BOOL
ConfiguredCalendar::DayFromRangeCollection(CalendarDay * apDay,
																					 IMTRangeCollectionPtr aRangeCollection)
{

	SetIterator<IMTRangeCollectionPtr, IMTRangePtr> it;
	HRESULT hr = it.Init(aRangeCollection);
	if (FAILED(hr))
	{
		// TODO: set error
		return FALSE;
	}

	// add each of the time ranges
	while (TRUE)
	{
		IMTRangePtr range = it.GetNext();
		if (range == NULL)
			break;

		string startTimeBstr = range->GetStartTime();
		long startTime = MTConvertTime(startTimeBstr);

		string endTimeBstr = range->GetEndTime();
		long endTime = MTConvertTime(endTimeBstr);

		string code = range->GetCode();

		TimeRange * timeRange = new TimeRange(code.c_str(), startTime, endTime);
		apDay->AddTimeRange(timeRange);
	}

	apDay->FillGapsWithCode(aRangeCollection->GetCode());

	return TRUE;
}



