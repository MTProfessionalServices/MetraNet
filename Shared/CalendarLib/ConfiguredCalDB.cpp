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

#include <MTObjectCollection.h>

using namespace MTCALENDARLib;


/**************************************** ConfiguredCalendar ***/

BOOL ConfiguredCalendarDB::Setup(long idCalendar)
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

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));

		mCalendar = pc->GetCalendar(idCalendar);


	//	MTObjectCollection<MTPRODUCTCATALOGLib::IMTCalendarWeekday> coll;
		//coll.Create(reinterpret_cast<IMTCollection *>(mCalendar->GetWeekdays()));
	//	coll.Create(mCalendar->GetWeekdays());



/*
		HRESULT hr = mCalendar.CreateInstance(MTPROGID_USERCALENDAR);
		if (FAILED(hr))
		// TODO: SetError
			return FALSE;

		//mCalendar->Read(apPathname, apFilename);

		IMTTimezonePtr timezone = mCalendar->GetTimezone();
		if (timezone->GetTimezoneID() != 0)
		{
			const char * tz = TranslateZone(timezone->GetTimezoneID());
			if (!tz || !*tz)
			{
#if 0
				char buffer[256];
				sprintf("Unsupported timezone ID %d", timezone->GetTimezoneID());
#endif
				return FALSE;
			}

			UseFixedOffset(tz);
		}
		else
			UseFloatingOffset();
			*/
	}
	catch (_com_error err)
	{
		// TODO: SetError
		return FALSE;
	}
	return TRUE;
}

BOOL ConfiguredCalendarDB::CreateYear(CalendarYear * apYear, int aYear)
{
	try
	{
		// create a day for each of the week days
		CalendarDay * weekdays[7];
		for (int i = 0; i < sizeof(weekdays) / sizeof(weekdays[0]); i++)
		{
			weekdays[i] = new CalendarDay;
			apYear->OwnDay(weekdays[i]);

      MTPRODUCTCATALOGLib::IMTCalendarWeekdayPtr pDay = mCalendar->GetWeekdayorDefault(i);
			
      if (!SetDayFromCOMDay(weekdays[i], pDay))
      {
        return false;
      }

		}


		// Fill in each day of the year with the correct weekday
		apYear->AssignWeekdays(aYear, weekdays, FALSE);


		// Handle holidays (explicitly sets dates)
		MTPRODUCTCATALOGLib::IMTCollectionPtr pHolidayColl = mCalendar->GetHolidays();
		
		int iHolidayCount = pHolidayColl->Count;

		for (i=1; i <= iHolidayCount; i++)
		{
			MTPRODUCTCATALOGLib::IMTCalendarHolidayPtr pDay = pHolidayColl->GetItem(i);

			DATE oledate = pDay->GetDate();
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

        if (!SetDayFromCOMDay(newDay, pDay))
        {
          return false;
        }

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
ConfiguredCalendarDB::SetDayFromCOMDay(CalendarDay * apDay,
																					 MTPRODUCTCATALOGLib::IMTCalendarDayPtr apCOMDay)
{

			MTPRODUCTCATALOGLib::IMTCollectionPtr pPeriodColl = apCOMDay->GetPeriods();

			int iPeriodCount = pPeriodColl->Count;

				for (int j=1; j<=iPeriodCount; j++)
				{
					MTPRODUCTCATALOGLib::IMTCalendarPeriodPtr pPeriod = pPeriodColl->GetItem(j);

					string sPeriodCode = pPeriod->GetCodeAsString();
					long startTime = pPeriod->GetStartTime();
					long endTime = pPeriod->GetEndTime();

					TimeRange * timeRange = new TimeRange(sPeriodCode.c_str(), startTime, endTime);
					apDay->AddTimeRange(timeRange);
				}
			
			//We have set the explicit periods and there codes, now fill any other 'gaps' in the day
			//with the 'default' code for the day.
    	string sDayCode = apCOMDay->GetCodeAsString();
      apDay->FillGapsWithCode(sDayCode.c_str());

/*
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

		TimeRange * timeRange = new TimeRange(code, startTime, endTime);
		apDay->AddTimeRange(timeRange);
	}

	apDay->FillGapsWithCode(aRangeCollection->GetCode());
*/

	return TRUE;
}

/*
BOOL
ConfiguredCalendarDB::DayFromPeriodCollection(CalendarDay * apDay,
																					 MTPRODUCTCATALOGLib::IMTCollectionPtr apPeriodColl)
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

		TimeRange * timeRange = new TimeRange(code, startTime, endTime);
		apDay->AddTimeRange(timeRange);
	}

	apDay->FillGapsWithCode(aRangeCollection->GetCode());

	return TRUE;
}
*/
