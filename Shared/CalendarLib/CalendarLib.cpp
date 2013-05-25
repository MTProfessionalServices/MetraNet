/**************************************************************************
 * @doc CALENDARLIB
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

#include <CalendarLib.h>

#include <mtzoneinfo.h>
#include <algorithm>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Localization.tlb> inject_statement("using namespace mscorlib;")

using std::string;

/************************************************** Calendar ***/

Calendar::Calendar() :
	mUseFixedOffset(FALSE)
{ }

Calendar::~Calendar()
{ }


// NOTE: the caller is responsible for deleting elements
// placed into the TimeSegmentVector
BOOL Calendar::SplitTimeSpan(time_t aStartTime, time_t aEndTime,
														 const char * apTimeZone, TimeSegmentVector & arSegments)
{
	time_t startTime = aStartTime;

	while (TRUE)
	{
		int durationInRange;
		time_t segmentStart = startTime;
		const TimeRange * range = GetRangeAndUpdate(startTime, aEndTime,
																								apTimeZone, durationInRange);
		ASSERT(range);

		time_t endTime = segmentStart + durationInRange;
		//ASSERT(endTime != segmentStart);

		TimeSegment * segment = new TimeSegment(segmentStart, durationInRange,
																						range);

		arSegments.push_back(segment);

		if (startTime == aEndTime)
			break;
		ASSERT(startTime < aEndTime);
	}

	return TRUE;
}

long Calendar::GetSecondCount(struct tm * timeFields)
{
	long daysInYears = 0;

	daysInYears = timeFields->tm_year + 1900;

	long leapYear = daysInYears / 4;

	// we don't count on extra day when current year is a leap year
	if ((leapYear * 4) == daysInYears)
	{
		leapYear--;
	}
	
	daysInYears = daysInYears * 365 + leapYear;
	
	long timeValue = ((daysInYears + timeFields->tm_yday) * 24 + timeFields->tm_hour) * 60 * 60;

	return timeValue;
}


void Calendar::UseFixedOffset(const char * apZoneName)
{
	mUseFixedOffset = TRUE;
	mFixedOffset = apZoneName;
}

void Calendar::UseFloatingOffset()
{
	mUseFixedOffset = FALSE;
}

BOOL Calendar::GetUsesFixedOffset() const
{
	return mUseFixedOffset;
}

const string & Calendar::GetFixedOffset() const
{
	return mFixedOffset;
}



const TimeRange * Calendar::GetRangeAndUpdate(time_t & arStartTime, time_t aEndTime,
																							const char * apTimeZone,
																							int & arDurationInRange)
{
	struct tm * timeFields = tzlocaltime(apTimeZone, &arStartTime);
	ASSERT(timeFields);

#if 0
	long localStartTime = arStartTime;
	if (mUseFixedOffset)
		localStartTime += (long) (mFixedOffset * 60.0 * 60.0);
	else
		localStartTime += aOffset;

	struct tm * timeFields = gmtime(&localStartTime);
	ASSERT(timeFields);

#endif
	struct tm startTimeFields = *timeFields;

	//timeFields = localtime(&aEndTime);
	//ASSERT(timeFields);

	//////////////////////////////////////////////////////
	long totalDuration = (long (aEndTime - arStartTime));
	ASSERT(totalDuration >= 0);

	// tm structure:
	//
	// tm_sec Seconds after minute (0 - 59)
	// tm_min Minutes after hour (0 - 59)
	// tm_hour Hours since midnight (0 - 23)
	// tm_mday Day of month (1 - 31)
	// tm_mon Month (0 - 11; January = 0)
	// tm_year Year (current year minus 1900)
	// tm_wday Day of week (0 - 6; Sunday = 0)
	// tm_yday Day of year (0 - 365; January 1 = 0)
	// tm_isdst Always 0 for gmtime

	int duration = totalDuration;

	int yearValue = startTimeFields.tm_year;
	int dayValue = startTimeFields.tm_yday;
	int timeValue = startTimeFields.tm_hour * 60 * 60
		+ startTimeFields.tm_min * 60
		+ startTimeFields.tm_sec;

	// go after the start time and figure out which range it's in

	// narrow down to the year..
	const CalendarYear * year = GetYear(yearValue);
	// TODO: better error
	ASSERT(year);

	// narrow down to the day
	const CalendarDay * day = year->GetDayOfYear(dayValue);
	ASSERT(day);

	// narrow down to the time range
	const TimeRange * range = day->RangeForTime(timeValue);
	ASSERT(range->TimeInRange(timeValue));

	// does the segment we're looking at fit entirely into
	// this time range?
	long newStart;
	if (range->ContainsTimeSegment(timeValue, duration))
		// end condition - last range
		newStart = (long) aEndTime;
	else
		// set the new start time to be immediately after the current range
		newStart = (long) arStartTime + (range->GetEndTime() - timeValue);

	arDurationInRange = newStart - (long) arStartTime;
	arStartTime = newStart;

	return range;
}


const CalendarYear * Calendar::GetYear(int aYear)
{
	CalendarYear & year = mYearMap[aYear];
	if (year.IsInitialized())
		return &year;

	if (!CreateYear(&year, aYear))
	{
		// TODO:
		ASSERT(0);
		return NULL;
	}

	return &year;
}


// TODO: temporary!
string Calendar::TranslateZone(int aZoneID)
{
	// TODO: temporary! move to an XML file
  std::string timezone("");
  MetraTech_Localization::ITimeZoneListPtr tzlist
      (__uuidof(MetraTech_Localization::TimeZoneList));

  _bstr_t tzName = tzlist->GetTimeZoneName(aZoneID);

  if(tzName.length() > 0)
  {
    timezone = (const char*) tzName;
  }
  return timezone; 
}


/********************************************** CalendarYear ***/

CalendarYear::CalendarYear()
{
	for (int i = 0; i < sizeof(mDays) / sizeof(mDays[0]); i++)
		mDays[i] = NULL;
}

CalendarYear::~CalendarYear()
{
	CalendarDayList::iterator it;
	for (it = mOwnedDays.begin(); it != mOwnedDays.end(); it++)
		delete *it;

	mOwnedDays.clear();
}

BOOL CalendarYear::IsInitialized() const
{
	return (mDays[0] != NULL);
}	

void CalendarYear::SetDay(int aDay, const CalendarDay * apDay)
{
	ASSERT(aDay >= 0 && aDay < (sizeof(mDays) / sizeof(mDays[0])));
	mDays[aDay] = apDay;
}

void CalendarYear::OwnDay(CalendarDay * apDay)
{
	mOwnedDays.push_back(apDay);
}

const CalendarDay * CalendarYear::GetDayOfYear(int aDay) const
{
	ASSERT(aDay >= 0 && aDay < (sizeof(mDays) / sizeof(mDays[0])));
	const CalendarDay * day = mDays[aDay];
	ASSERT(day);
	return day;
}


void CalendarYear::AssignWeekdays(int aYear, CalendarDay * apWeekdays[],
																	BOOL aTakeOwnership /* = TRUE */)
{
	// optionally take ownership of all the days
	if (aTakeOwnership)
	{
		for (int i = 0; i < 7; i++)
			OwnDay(apWeekdays[i]);
	}

	// determine the day of week of the first day of the year

	// tm_sec Seconds after minute (0 - 59)
	// tm_min Minutes after hour (0 - 59)
	// tm_hour Hours since midnight (0 - 23)
	// tm_mday Day of month (1 - 31)
	// tm_mon Month (0 - 11; January = 0)
	// tm_year Year (current year minus 1900)
	// tm_wday Day of week (0 - 6; Sunday = 0)
	// tm_yday Day of year (0 - 365; January 1 = 0)
	// tm_isdst Always 0 for gmtime
	struct tm timeStruct;
	timeStruct.tm_sec = 0;
	timeStruct.tm_min = 0;
	timeStruct.tm_hour = 0;
	timeStruct.tm_mday = 1;
	timeStruct.tm_mon = 0;
	timeStruct.tm_year = aYear;
	timeStruct.tm_wday = 0;
	timeStruct.tm_yday = 0;
	timeStruct.tm_isdst = 0;

	// TODO: timezone problem?
	time_t firstOfYear = mktime(&timeStruct);

	// we are looking for relative time, 
	// mktime() will return a local time in time_t
	timeStruct = *localtime(&firstOfYear);
	ASSERT(timeStruct.tm_year == aYear);
	ASSERT(timeStruct.tm_mon == 0);
	ASSERT(timeStruct.tm_mday == 1);

	int dayOfWeek = timeStruct.tm_wday;

	for (int i = 0; i < (sizeof(mDays) / sizeof(mDays[0])); i++)
	{
		SetDay(i, apWeekdays[dayOfWeek]);

		dayOfWeek++;
		dayOfWeek = dayOfWeek % 7;
	}
}


/*********************************************** CalendarDay ***/

CalendarDay::~CalendarDay()
{
	TimeRangeVector::iterator it;
	for (it = mOwnedRanges.begin(); it != mOwnedRanges.end(); it++)
		delete *it;

	mOwnedRanges.clear();
}

void CalendarDay::AddTimeRange(TimeRange * apRange)
{
	mOwnedRanges.push_back(apRange);
}


const TimeRange * CalendarDay::RangeForTime(int aTime) const
{
	// must be within a day
	ASSERT(aTime >= 0 && aTime < (24 * 60 * 60));

	TimeRange testRange(aTime);

	TimeRange * found = NULL;
	TimeRangeVector::const_iterator it;
	for (it = mOwnedRanges.begin(); it != mOwnedRanges.end(); it++)
	{
		if (**it == testRange)
			found = *it;
	}

	ASSERT(found);
	ASSERT(found->TimeInRange(aTime));

	return found;
}

// Fix for CR#13010
// The sort in FillGapsWithCode is non-deterministic because the
// vector contains pointers to TimeRange objects. The overloaded '<'
// on TimeRange is never called.

// This sort is made deterministic by using the following predicate.
bool Range1LessThanRange2 (TimeRange *range1, TimeRange *range2)
{
   return (range1->GetStartTime() < range2->GetStartTime());
}

void CalendarDay::FillGapsWithCode(const char * apCode)
{
	TimeRangeVector ranges;

	std::sort(mOwnedRanges.begin(), mOwnedRanges.end(), Range1LessThanRange2);

	// create ranges for all gaps
	int beginAt = 0;
	for (int i = 0; i < (int) mOwnedRanges.size(); i++)
	{
		TimeRange * range = mOwnedRanges[i];

		if (range->GetStartTime() > beginAt)
		{
			// need to create a new range to fill the gap
			TimeRange * gap = new TimeRange(apCode, beginAt, range->GetStartTime());
			ranges.push_back(gap);
		}
		beginAt = range->GetEndTime();
	}

	// any gap from last range to the end of the day?
	const int endOfDay = 24 * 60 * 60;
	if (beginAt < endOfDay)
	{
		TimeRange * gap = new TimeRange(apCode, beginAt, endOfDay);
		ranges.push_back(gap);
	}

	// insert the new ranges back into the day
	for (i = 0; i < (int) ranges.size(); i++)
	{
		TimeRange * range = ranges[i];
		mOwnedRanges.push_back(range);
	}
}


/************************************************* TimeRange ***/

TimeRange::TimeRange(int aTimeOfDay)
	: mStartTime(aTimeOfDay),
		mEndTime(aTimeOfDay)
{ }

TimeRange::TimeRange(const TimeRange & arRange)
{
	*this = arRange;
}

TimeRange::TimeRange(const char * apCode, int aStartTime, int aEndTime)
	: mCode(apCode),
		mStartTime(aStartTime),
		mEndTime(aEndTime)
{ }

bool TimeRange::operator==(const TimeRange & arRange) const
{
	// NOTE: when operator == is used for searching, the time
	// range passed in will have its start time and end time
	// set equal to each other.
	// in this case, equality is tested by calling TimeInRange.
	//
	// in all other cases, start time must equal end time for
	// this operator to return TRUE


	if (GetStartTime() == GetEndTime())
	{
		// used for identifying which range a time falls into
		return arRange.TimeInRange(GetStartTime()) ? true : false;
	}
	else if (arRange.GetStartTime() == arRange.GetEndTime())
	{
		// used for identifying which range a time falls into
		return TimeInRange(arRange.GetStartTime()) ? true : false;
	}

	return (arRange.GetStartTime() == GetStartTime()
					&& arRange.GetEndTime() == GetEndTime());
}

bool TimeRange::operator<(const TimeRange & arRange) const
{
	return (GetStartTime() < arRange.GetStartTime());
}



TimeRange & TimeRange::operator =(const TimeRange & arRange)
{
	SetStartTime(arRange.GetStartTime());
	SetEndTime(arRange.GetEndTime());
	SetCode(arRange.GetCode());
	return *this;
}


BOOL TimeRange::TimeInRange(int aTimeOfDay) const
{
	// note we are inclusive on the start time,
	// exclusive on the end time
	return aTimeOfDay >= mStartTime && aTimeOfDay < mEndTime;
}

BOOL TimeRange::ContainsTimeSegment(int time, int duration) const
{
	return (TimeInRange(time) && TimeInRange(time + duration));
}


/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: DateRange::After()
// DESCRIPTION	: returns new range, which spans from the end of the argument till the end of this range.
//				: e.g. 
//				:	this:   1/1/01 - 1/30/01
//				:   arg:    1/15/01 - 1/20/01
//				:   result: 1/20/01 - 1/30/01
// RETURN		: DateRange
// ARGUMENTS	: const DateRange& arg
// EXCEPTIONS	: 
// COMMENTS		: 
// CREATED		: 4/18/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
DateRange DateRange::After(const DateRange& arg) const
{
	DateRange res(arg.mEndDate, mEndDate);

	if((res.mStartDate > res.mEndDate) && IsClosedEnd())
	{
		res.SetEndDate(res.mStartDate);
	}

	return res;

}

/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: DateRange::Intersection()
// DESCRIPTION	: returns new range, which is intersection of this and arg
// RETURN		: DateRange
// ARGUMENTS	: const DateRange& arg
// EXCEPTIONS	: 
// COMMENTS		: 
// CREATED		: 4/18/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
DateRange DateRange::Intersection(const DateRange& arg)  const
{
	DateRange res( max(mStartDate, arg.mStartDate),
				   min(mEndDate, arg.mEndDate));

	// if resulting end date is open, then take whatever date is defined.
	if(!res.IsClosedEnd())
		res.SetEndDate(max(mEndDate, arg.mEndDate));

	return res;
}


const time_t DateRange::scSecondsInTheDay = 60*60*24;

/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: DateRange::Days()
// DESCRIPTION	: subtract start from the end, and calculate number of days.
// RETURN		: int
// ARGUMENTS	: none
// EXCEPTIONS	: 
// COMMENTS		: if start and end are exactly the same, this returns 0, otherwise partial days
//              : always round up to one day
// CREATED		: 4/18/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
long DateRange::Days() const
{
	// If the period is not closed, this is an error.
	if(!IsClosed())
	{
		ASSERT(0);
		return 0;  
	}

	if (mStartDate==mEndDate)
		return 0;

	time_t daysStart = (mStartDate + 1) / scSecondsInTheDay;
	time_t daysEnd = mEndDate / scSecondsInTheDay;

	if(daysEnd < daysStart)
		daysStart = daysEnd;

	return ((long) (daysEnd - daysStart + 1));


/*


	int intDays;
	div_t div_result;

	if (mStartDate>=mEndDate)
		return 0;

    div_result = div(mEndDate-mStartDate, scSecondsInTheDay);
	
	intDays = div_result.quot;

	if (div_result.rem>0)
		intDays++;

	return intDays;

*/
}

DateRange & DateRange::operator =(const DateRange & arRange)
{
	if(this != &arRange)
	{
		mStartDate = arRange.mStartDate;
		mEndDate = arRange.mEndDate;
	}

	return *this;
}

DateRange::DateRange(const DateRange & arRange)
{
	mStartDate = arRange.mStartDate;
	mEndDate = arRange.mEndDate;
}

DateRange::DateRange(time_t dtStart, time_t dtEnd)
{
	SetStartDate(dtStart);
	SetEndDate(dtEnd);
}

bool DateRange::operator !=(const DateRange & arRange) const
{
	return (mStartDate != arRange.mStartDate) || (mEndDate != arRange.mEndDate);
}

/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: SetStartDate()
// DESCRIPTION	: 
// RETURN		: void
// ARGUMENTS	: time_t aStartDate
// EXCEPTIONS	: 
// COMMENTS		: 
// CREATED		: 4/19/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
void DateRange::SetStartDate(time_t aStartDate)
{
	mStartDate = aStartDate; 
}

void DateRange::SetEndDate(time_t aEndDate)
{ 
	mEndDate = aEndDate; 
}
