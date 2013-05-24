/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Travis Gebhardt
* $Header$
* 
***************************************************************************/

#if !defined _MTDATE_H
#define _MTDATE_H

#include <time.h>
#include <assert.h>
#include <string>
#include <SQLTYPES.H>

#include <comdef.h>

//------------------
//MTDate

class MTDate {
public:

	
	//constructors
	MTDate();
	MTDate(const MTDate& arDate);
	MTDate(const time_t& arTime);
	MTDate(int aMonth, int aDay, int aYear);
	MTDate(const std::string& arDateStr);
  #ifdef _WIN32
	MTDate(const DATE& arOLEDate);
	#endif

	//accessor methods
	int          GetMonth()        const;     
	const char*  GetMonthName()    const; 
	int          GetDay()          const;
	int          GetWeekday()      const;
	const char*  GetWeekdayName()  const;
	int          GetYear()         const;     
	int          GetDaysInMonth()  const; 
	time_t       GetSecondsSinceEpoch() const;
	unsigned long GetDaysSinceEpoch() const;

	#ifdef _WIN32
	void         GetOLEDate(DATE* apOLEDate) const;
	DATE         GetOLEDate() const;  //more convenient
	#endif

	TIMESTAMP_STRUCT GetODBCDate() const;
	TIMESTAMP_STRUCT GetODBCDateAtEndOfDate() const;
	
	bool         IsLeap() const; 
	bool         IsAfter(const MTDate& arDate) const;
	bool         IsBefore(const MTDate& arDate) const;
	int          ToString(const char* apFormat, std::string& arBuffer) const;
	bool         IsValid() const;

	//static methods useful to everyone
	static int  GetDaysInMonth(int month, int year);
	static bool IsLeap(int year);

	//mutator methods
	void SetDate(int aMonth, int aDay, int aYear);
	void SetDate(const time_t& arTime);
	void SetDate(const std::string& arDateStr);
#ifdef _WIN32
	void SetDate(const DATE& arOLEDate);
#endif



	void SetMonth(int aMonth);
	void SetDay(int aDay);
	void SetYear(int aYear);

//If aAdjustForEOM is true, the case in which the
//original date have had a day of month that
//does not exist in the newly calculated date (i.e. Aug 30th +
//18 months = Feb 30th), is detected and resolved by setting the
//day to the end of the new month.
	
	void AddDay(int aDays = 1);
	void AddMonth(int aMonths = 1, bool aAdjustForEOM = true);
	void AddYear(int aYears = 1,   bool aAdjustForEOM = true);
	void SubtractDay(int aDays = 1);
	void SubtractMonth(int aMonths = 1, bool aAdjustForEOM = true);
	void SubtractYear(int aYears = 1,   bool aAdjustForEOM = true);
	void NextWeekday(int aWeekday);

  //operators
	friend bool operator==(const MTDate& a, const MTDate& b);
	MTDate& operator+=(int dx);
	MTDate& operator-=(int dx);
	MTDate  operator++(int);  //postfix ++
	MTDate  operator--(int);  //postfix --
	MTDate& operator=(const MTDate& arDate);
#ifdef _WIN32
	MTDate& MTDate::operator=(const DATE& arOLEDate);
#endif
	
	//constant used to refer to the day at the end of the month
	//this can be passed in to methods such as SetDate and SetDay
	static const int END_OF_MONTH;

	//defines how many seconds are in a day
	static const long SECONDS_IN_DAY;

	//constant used with MTDate(time_t&) constructor and SetDate(time_t&) to
	//construct a date from today
	static const time_t TODAY;
	
	//Define the maximum possible days there are in a month
	static const int MAX_DAYS_IN_MONTH;

	enum Weekday {SUNDAY = 1, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY};
	enum Month {JANUARY = 1, FEBRUARY, MARCH, APRIL, MAY, JUNE, JULY, AUGUST, SEPTEMBER, OCTOBER, NOVEMBER, DECEMBER};
	


private:
	void Calculate() const;  //logically const 
	void Calculate(const time_t& arTime) const; //logically const
	
	//clears the unused fields in mDate
	void ClearUnusedFields() const; //logically const

	//the heart and soul of MTDate... the tm struct
	struct tm mDate;

	//the dates validity status
	bool mValid;
	bool mCalculated;

	static const char* MTDate::dayNames[];
	static const char* MTDate::monthNames[];
	static const int MTDate::monthDays[];

};

//other MTDate operators that don't need special access
bool operator!=(const MTDate& a, const MTDate& b);
bool operator> (const MTDate& a, const MTDate& b);
bool operator< (const MTDate& a, const MTDate& b);
bool operator>=(const MTDate& a, const MTDate& b);
bool operator<=(const MTDate& a, const MTDate& b);

MTDate operator+(const MTDate& a, int dx);
MTDate operator+(int dx, const MTDate& a);
MTDate operator-(const MTDate& a, const int dx);
unsigned long operator-(const MTDate& a, const MTDate& b);



//constructs an MTDate object with no date information
inline MTDate::MTDate() : mValid(true), mCalculated(false) 
{
}

//constructs an MTDate object with no date information
inline MTDate::MTDate(const MTDate& arDate) : mValid(true), mCalculated(false) 
{
	*this = arDate; 
}


//constructs a MTDate object given a month, day, and a year
inline MTDate::MTDate(int aMonth, int aDay, int aYear) : mValid(true), mCalculated(false) {
	SetDate(aMonth, aDay, aYear);
}


//constructs a MTDate object from the given time_t
//to construct today's date pass in MTDate::TODAY
inline MTDate::MTDate(const time_t& arTime) : mValid(true), mCalculated(false) {
	SetDate(arTime);
}


//constructs a MTDate object from a string formatted as the following:
//"MM/DD/YYYY", "MM-DD-YYYY"
inline MTDate::MTDate(const std::string& arDateStr) : mValid(true), mCalculated(false) {
	SetDate(arDateStr);
}


//constructs a MTDate object from an OLE date
#ifdef _WIN32
inline MTDate::MTDate(const DATE& arOLEDate) : mValid(true), mCalculated(false) {
	SetDate(arOLEDate);
}
#endif


//gets the current month [1-12, january == 1]     
inline int MTDate::GetMonth() const {
	return mDate.tm_mon + 1;
}


//gets the current month's name
inline const char* MTDate::GetMonthName() const {
	return monthNames[mDate.tm_mon];
}


//gets the current day [1-31]     
inline int MTDate::GetDay() const {
	return mDate.tm_mday;
}


//gets the current year     
inline int MTDate::GetYear() const {
	return mDate.tm_year + 1900;
}


//gets the current day's name
inline const char* MTDate::GetWeekdayName() const {
	return dayNames[GetWeekday() - 1];
}


//gets the amount of days in the current month
inline int MTDate::GetDaysInMonth() const {
	return MTDate::GetDaysInMonth(mDate.tm_mon + 1, mDate.tm_year + 1900);
}


//sets the current month to the given day [1-12]     
inline void MTDate::SetMonth(int aMonth) {
	mDate.tm_mon = aMonth - 1;
	mCalculated = false;
}


//sets the current year to the given year [1900 - the distant future]     
inline void MTDate::SetYear(int aYear) {
	mDate.tm_year = aYear - 1900;
	mCalculated = false;
}


//determines if the current year is a leap year     
inline bool MTDate::IsLeap() const {
	return MTDate::IsLeap(mDate.tm_year + 1900);
}


//determines if the current date occurs after the given date
inline bool MTDate::IsAfter(const MTDate& arDate) const {
	return (GetSecondsSinceEpoch() > arDate.GetSecondsSinceEpoch());
}


//determines if the current date occurs after the given date
inline bool MTDate::IsBefore(const MTDate& arDate) const {
	return (GetSecondsSinceEpoch() < arDate.GetSecondsSinceEpoch());
}


//subtracts the specified amount of days from the current date
inline void MTDate::SubtractDay(int aDays) {
  AddDay(-aDays);
}


//subtracts the specified amount of months from the current date
inline void MTDate::SubtractMonth(int aMonths, bool aAdjustForEOM) {
  AddMonth(-aMonths, aAdjustForEOM);
}


//subtracts the specified amount of years from the current date
inline void MTDate::SubtractYear(int aYears, bool aAdjustForEOM) {
  AddYear(-aYears, aAdjustForEOM);
}


//adds the amount of days to the current date
inline MTDate& MTDate::operator+=(int dx) {
	AddDay(dx);
	return *this;
}


//subtracts the amount of days from the current date
inline MTDate& MTDate::operator-=(int dx) {
	SubtractDay(dx);
	return *this;
}


//tests for date inequality
inline bool operator!=(const MTDate& a, const MTDate& b) {
	return !(a == b);
}


//tests if a is chronologically after b
inline bool operator>(const MTDate& a, const MTDate& b) {
	return a.IsAfter(b);
}


//tests if a is chronologically before b
inline bool operator<(const MTDate& a, const MTDate& b) {
	return a.IsBefore(b);
}


//tests if a is chronologically after or at the same time as b
inline bool operator>=(const MTDate& a, const MTDate& b) {
	return (a.IsAfter(b) ||  (a == b));
}


//tests if a is chronologically before or at the same time as b
inline bool operator<=(const MTDate& a, const MTDate& b) {
	return (a.IsBefore(b) ||  (a == b));
}

inline TIMESTAMP_STRUCT MTDate::GetODBCDate() const
{
	TIMESTAMP_STRUCT retval;
	retval.year = GetYear();
	retval.month = mDate.tm_mon+1;
	retval.day = mDate.tm_mday;
	retval.hour = 0; // unused field, don't copy
	retval.minute = 0; // unused field, don't copy
	retval.second = 0; // unused field, don't copy
	retval.fraction = 0; // unused field, don't copy
	return retval;
}

inline TIMESTAMP_STRUCT MTDate::GetODBCDateAtEndOfDate() const
{
	TIMESTAMP_STRUCT retval;
	retval.year = GetYear();
	retval.month = mDate.tm_mon+1;
	retval.day = mDate.tm_mday;
	retval.hour = 23;
	retval.minute = 59;
	retval.second = 59;
	retval.fraction = 0;
	return retval;
}


#endif
