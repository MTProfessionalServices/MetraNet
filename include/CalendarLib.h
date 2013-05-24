/**************************************************************************
 * @doc CALENDARLIB
 *
 * @module |
 *
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
 *
 * @index | CALENDARLIB
 ***************************************************************************/

#ifndef _CALENDARLIB_H
#define _CALENDARLIB_H

#include <time.h>
#include <string>
#include <map>
#include <list>
#include <vector>

class YearDays;
class TimeRange;
class CalendarYear;
class CalendarDay;

/*********************************************** TimeSegment ***/

class TimeSegment
{
public:
	TimeSegment(time_t aStartTime, int aDuration,
							const TimeRange * aRange)
		: mStartTime(aStartTime),
			mDuration(aDuration),
			mRange(aRange)
	{ }

	time_t GetStartTime() const
	{ return mStartTime; }

	time_t GetEndTime() const
	{ return mStartTime + mDuration; }

	int GetDuration() const
	{ return mDuration; }

	const std::string & GetCode() const;

	bool operator ==(const TimeSegment & arSegment)
	{ return FALSE; }

private:
	// time the segment started within the range
	const time_t mStartTime;
	// duration of the segment within this range
	const int mDuration;

	// range the segment fell into
	const TimeRange * mRange;
};

typedef std::vector<TimeSegment *> TimeSegmentVector;

/********************************************** CalendarYear ***/

class CalendarYear
{
public:
	CalendarYear();
	~CalendarYear();

	// return the CalendarDay for a given day of year
	const CalendarDay * GetDayOfYear(int aDay) const;

	// set the given day to a CalendarDay.  the CalendarYear
	// object does NOT delete the CalendarDay object unless you call
	// OwnDay
	void SetDay(int aDay, const CalendarDay * apDay);

	// take ownership of a day object and arrange to delete it when the
	// CalendarYear object is deleted.
	void OwnDay(CalendarDay * apDay);

	// assign each day of the year to the correct CalendarDay
	// for each day of the week.  optionally take ownership of
	// the days as well.
	void AssignWeekdays(int aYear, CalendarDay * apWeekdays[],
											BOOL aTakeOwnership = TRUE);

	// return TRUE if this object has been intiailized
	BOOL IsInitialized() const;

private:
	// all days of this year
	// NOTE: leap years have 366 days, not 365!
	const CalendarDay * mDays[366];

	// list of CalendarDays "owned" by the object that will be deleted
	// in the destructor
	typedef std::list<CalendarDay *> CalendarDayList;
	CalendarDayList mOwnedDays;
};


/*********************************************** CalendarDay ***/

class CalendarDay
{
public:
	// destructor deletes all TimeRange objects it contains
	~CalendarDay();

	typedef std::vector<TimeRange *> TimeRangeVector;

	const TimeRange * RangeForTime(int aTime) const;

	// add a time range to the day.
	// this method takes ownership of the object passed in and deletes
	// it in the destructor.
	void AddTimeRange(TimeRange * apRange);

	void FillGapsWithCode(const char * apCode);

private:
	TimeRangeVector mOwnedRanges;
};


/************************************************* TimeRange ***/

class TimeRange
{
public:
	TimeRange(int aTimeOfDay);
	TimeRange(const char * apCode, int aStartTime, int aEndTime);
	TimeRange(const TimeRange & arRange);

	TimeRange & operator =(const TimeRange & arRange);

	// start time
	void SetStartTime(int aStartTime)
	{ mStartTime = aStartTime; }

	int GetStartTime() const
	{ return mStartTime; }

	// end time
	void SetEndTime(int aEndTime)
	{ mEndTime = aEndTime; }

	int GetEndTime() const
	{ return mEndTime; }

	// code
	const std::string & GetCode() const
	{ return mCode; }

	void SetCode(const std::string & arCode)
	{ mCode = arCode; }


	// testing/searching for ranges
	void SetTestTime(int aTimeOfDay)
	{ mStartTime = mEndTime = aTimeOfDay; }

	BOOL TimeInRange(int aTimeOfDay) const;

	BOOL ContainsTimeSegment(int time, int duration) const;

	// sorted vector operators
	bool operator==(const TimeRange & arRange) const;

	bool operator<(const TimeRange & arRange) const;

	static int MakeTimeOfDay(int aHour, int aMin, int aSec)
	{
		return aHour * (60 * 60) + aMin * 60 + aSec;
	}

private:
	// start time of the range expressed in number of seconds since
	// midnight
	int mStartTime;

	// end time of the range expressed in number of seconds since
	// midnight
	int mEndTime;

	// code associated with this time range
	std::string mCode;
};


inline const std::string & TimeSegment::GetCode() const
{
	return mRange->GetCode();
}


/************************************************* DateRange ***/

class DateRange
{
public:
	DateRange(time_t dtStart, time_t dtEnd);
	DateRange(const DateRange & arRange);
	DateRange() : mStartDate(0), mEndDate(0) {};

	DateRange & operator =(const DateRange & arRange);

	// start date
	void SetStartDate(time_t aStartDate);

	time_t GetStartDate() const
	{ return mStartDate; }

	// end date
	void SetEndDate(time_t aEndDate);

	time_t GetEndDate() const
	{ return mEndDate; }

	// how many days range spans across.
	long Days() const;

	bool IsEmpty() const
	{
		return Days() == 0;
	}

	// check validity of the range
	bool IsValid()  const;

	// checks, if start and end dates are determined. 
	bool IsClosed()  const
	{
		return IsClosedStart() && IsClosedEnd();
	}

	// checks, if start date is determined. 
	bool IsClosedEnd()  const
	{
		return (mEndDate != 0);
	}

	// checks, if end date is determined. 
	bool IsClosedStart() const
	{
		return (mStartDate != 0);
	}

	// returns new range, which is intersection of this and arg
	DateRange Intersection(const DateRange& arg) const;

	// returns new range, which spans from the end of the argument till the end of this range.
	//	e.g. 
	//
	//	this:   1/1/01 - 1/30/01
	//	 arg:   1/15/01 - 1/20/01
	//  result: 1/20/01 - 1/30/01
	DateRange After(const DateRange& arg) const;

	bool operator< (const DateRange & arRange) const;
	bool operator!= (const DateRange & arRange) const;

private:
	// if value is 0, it means 'undetermined'
	time_t mStartDate;
	time_t mEndDate;

	static const time_t scSecondsInTheDay;
};


/************************************************** Calendar ***/

class Calendar
{
public:
	Calendar();
	virtual ~Calendar();

#if 0
	BOOL SplitTimeSpan(time_t aStartTime, time_t aEndTime, TimeSegmentVector & arSegments);
#endif

	BOOL SplitTimeSpan(time_t aStartTime, time_t aEndTime, const char * apTimezone,
											TimeSegmentVector & arSegments);

	void UseFixedOffset(const char * apZoneName);
	void UseFloatingOffset();

	BOOL GetUsesFixedOffset() const;
	const std::string & GetFixedOffset() const;


	// TODO: temporary!
  static std::string TranslateZone(int aZoneID);

private:
	const TimeRange * GetRangeAndUpdate(time_t & arStartTime, time_t aEndTime,
																			const char * apTimeZone, int & arDurationInRange);

	const CalendarYear * GetYear(int aYear);

	long GetSecondCount(struct tm * timeFields);

protected:
	// called when a new year has to be calculated
	virtual BOOL CreateYear(CalendarYear * apYear, int aYear) = 0;

private:
	BOOL mUseFixedOffset;
	std::string mFixedOffset;

	// map of year number to initialized year objects
	// years are in numerical form.
	//  example: 90 = 1990, 110 = 2010
	std::map<int, CalendarYear> mYearMap;
};




#endif /* _CALENDARLIB_H */
