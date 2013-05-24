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

#include <metralite.h>
#include <MTDate.h>
#include "MTUtil.h"
#include <mttime.h>
#include <time.h>
using namespace std;

const char* MTDate::dayNames []   = {"Sunday",  "Monday", "Tuesday","Wednesday",
																		 "Thursday","Friday", "Saturday"};

const char* MTDate::monthNames [] = {"January","February","March","April",
																		 "May","June","July","August",
																		 "September","October","November","December"};

const int MTDate::monthDays[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

//set the static constant (work around for VC++ non-compliance)
const int    MTDate::END_OF_MONTH = -1;
const long   MTDate::SECONDS_IN_DAY = 86400;
const time_t MTDate::TODAY = -1;
const int MTDate::MAX_DAYS_IN_MONTH = 31;







//determines the validity of the MTDate object.
//this method should be called after constructors and SetXXXX
//methods to ensure that the new date is a valid date
bool MTDate::IsValid() const {

	//this method obeys logical constness, not physical constness, so
	//it must get a non-const pointer to this
	MTDate* ncThis = const_cast<MTDate*>(this);
	
	//if we know we're invalid already then just return
	if (!mValid)
		return false;
	

	// check to see if the year is > 1970 or <= 2038 -- max time is 1/1/2038 00:00:00.000
	if ((mDate.tm_year + 1900 < 1970) || (mDate.tm_year + 1900 > 2038)) {
		ncThis->mValid = false;
		return false;
	}

	//checks to make sure the month is in the range of 0 - 11 or if year is 2038, that month = 0
	if ((mDate.tm_mon < 0) || (mDate.tm_mon > 11) || ((mDate.tm_year + 1900 == 2038) && (mDate.tm_mon != 0))) {
		ncThis->mValid = false;
		return false;
	}

	//checks to make sure that the day is between 1 - EOM, or if year is 2038, that day = 1
	if ((mDate.tm_mday < 1) || (mDate.tm_mday > GetDaysInMonth(mDate.tm_mon + 1, mDate.tm_year + 1900)) ||
		((mDate.tm_year + 1900 == 2038) && (mDate.tm_mday != 1))) {
		ncThis->mValid = false;
		return false;
	}

	return mValid;
}


//sets the date to the given month, day, year
void MTDate::SetDate(int aMonth, int aDay, int aYear) {

	//gets the end of month if it was requested
	if (aDay == END_OF_MONTH)
		aDay = GetDaysInMonth(aMonth, aYear);
	
	//sets the given date into a temporary tm struct
	mDate.tm_mon  = aMonth - 1;
	mDate.tm_mday = aDay;
	mDate.tm_year = aYear - 1900;

	mCalculated = false;
}


//sets the date to the given time_t
void MTDate::SetDate(const time_t& arTime) {
	if (arTime == MTDate::TODAY) {
		//gets the current time (or overridden MTTIME environment variable) 
		time_t currentTime;
		currentTime = GetMTTime();
		Calculate(currentTime);		
	} else {
		Calculate(arTime);
	}
}


//sets the date to the given OLE date
//this code was taken from OLEDate.cpp/TimetFromOleDate()
//this method is the preferred way to convert OLEDate
#ifdef _WIN32
void MTDate::SetDate(const DATE& arOLEDate) {
	SYSTEMTIME systemTime;
	VariantTimeToSystemTime(arOLEDate, &systemTime);
	
	mDate.tm_mon  = systemTime.wMonth - 1; // system time months start from 1
	mDate.tm_mday = systemTime.wDay;
	mDate.tm_year = systemTime.wYear-1900; // Year(current year minus 1900)
	mDate.tm_hour = systemTime.wHour;
	mDate.tm_min = systemTime.wMinute;
	mDate.tm_sec = systemTime.wSecond;

	mCalculated = false;
}
#endif


//sets the date from a string formatted as the following:
//"MM/DD/YYYY", "MM-DD-YYYY"
void MTDate::SetDate(const string& arDateStr) {

	//finds the break between the month and day fields
	string::size_type posMonthDay = arDateStr.find_first_of("/-");
	if (posMonthDay == string::npos) {	//the delimiter characters were not found
		mValid = false;
		return;
	}

	//finds the break between the day and year fields
	string::size_type posDayYear = arDateStr.find_first_of("/-", posMonthDay + 1);
	if (posDayYear == string::npos) {	//the delimiter characters were not found
		mValid = false;
		return;
	}

	string monthStr = arDateStr.substr(0, posMonthDay);
	string dayStr   = arDateStr.substr(posMonthDay + 1, posDayYear);
	string yearStr  = arDateStr.substr(posDayYear  + 1, arDateStr.length());

//	cout << "month: " << monthStr.c_str() << endl;
//	cout << "day  : " << dayStr.c_str()   << endl;
//	cout << "year : " << yearStr.c_str()  << endl;


	char* end;
	long val;
	//converts the month string to a long and stores it in mDate
	val = strtol(monthStr.c_str(), &end, 10);
	if ((val == 0) || (val == LONG_MAX) || (val == LONG_MIN)) {
		mValid = false;
		return;
	}
	mDate.tm_mon = val - 1;

	//converts the day string to a long and stores it in mDate
	val = strtol(dayStr.c_str(), &end, 10);
	if ((val == 0) || (val == LONG_MAX) || (val == LONG_MIN)) {
		mValid = false;
		return;
	}
	mDate.tm_mday = val;

	//converts the year string to a long and stores it in mDate
	val = strtol(yearStr.c_str(), &end, 10);
	if ((val == 0) || (val == LONG_MAX) || (val == LONG_MIN)) {
		mValid = false;
		return;
	}
	mDate.tm_year = val - 1900;

  mCalculated = false;
}


//returns the the date represented as the amount of seconds
//past the epoch (Jan 1, 1970)
time_t MTDate::GetSecondsSinceEpoch() const {
	ClearUnusedFields();
	ASSERT(IsValid());
	return mktime(const_cast<struct tm*>(&mDate));
}

//returns the amount of days past the epoch (Jan 1, 1970)
unsigned long MTDate::GetDaysSinceEpoch() const {
	return (unsigned long) (GetSecondsSinceEpoch() / 60 * 60 * 24);
}


//gets the current week day [1-7, sunday == 1]     
int MTDate::GetWeekday() const {

	//makes sure we get the associated week day (lazy evaluation)
	if (!mCalculated)
		Calculate();

	return mDate.tm_wday + 1;
}


//returns the the date as an OLE date
//this code was taken from OLEDate.cpp/OleDateFromStructTm()
//this method is the preferred way to convert to OLEDate
#ifdef _WIN32
void MTDate::GetOLEDate(DATE* apOLEDate) const {

	//makes sure we get the associated week day (lazy evaluation)
	if (!mCalculated)
		Calculate();

	SYSTEMTIME systemTime;

	systemTime.wMonth        = mDate.tm_mon + 1;	// tm months start from 0
	systemTime.wDay          = mDate.tm_mday;
	systemTime.wYear         = mDate.tm_year + 1900;
	systemTime.wDayOfWeek    = mDate.tm_wday; 

	//zeros out the time related fields
	systemTime.wHour         = 0; 
	systemTime.wMinute       = 0;
	systemTime.wSecond       = 0;
	systemTime.wMilliseconds = 0;

	SystemTimeToVariantTime(&systemTime, apOLEDate);
}

//a more convenient version
DATE MTDate::GetOLEDate() const {

	//makes sure we get the associated week day (lazy evaluation)
	if (!mCalculated)
		Calculate();

	SYSTEMTIME systemTime;

	systemTime.wMonth        = mDate.tm_mon + 1;	// tm months start from 0
	systemTime.wDay          = mDate.tm_mday;
	systemTime.wYear         = mDate.tm_year + 1900;
	systemTime.wDayOfWeek    = mDate.tm_wday; 

	//zeros out the time related fields
	systemTime.wHour         = 0; 
	systemTime.wMinute       = 0;
	systemTime.wSecond       = 0;
	systemTime.wMilliseconds = 0;

	DATE date;
	SystemTimeToVariantTime(&systemTime, &date);
	
	return date;
}
#endif


//sets the current day to the given day [1-31]     
void MTDate::SetDay(int aDay) {

  //Check if the end-date is greater than the end of the month.  If it is, set it back.
	int endOfMonth = GetDaysInMonth(mDate.tm_mon + 1, mDate.tm_year + 1900);
  if (aDay > endOfMonth){
		aDay = endOfMonth;
  }

	mDate.tm_mday = aDay;
	mCalculated = false;
}


//returns a string representing the date formatted by the
//given format specifier (see help on strftime for more info)
int MTDate::ToString(const char* apFormat, string& arBuffer) const {

	//makes sure we get the associated week day (lazy evaluation)
	if (!mCalculated)
		Calculate();

	char temp[128];
	int count = strftime(temp, 128, apFormat, &mDate);
	arBuffer.assign(temp);
	
	return count;
}


//adds the specified amount of days to the current date
//(handles all wrap around conditions)
void MTDate::AddDay(int aDays) {
	ASSERT(IsValid());

	//unset values for tm_hour, etc... could give mktime trouble
	ClearUnusedFields();

	time_t seconds = mktime(&mDate);
	seconds += (aDays * SECONDS_IN_DAY);
	Calculate(seconds);
}


//adds the specified amount of months to the current date
void MTDate::AddMonth(int aMonths, bool aAdjustForEOM) {
	mDate.tm_mon += aMonths;

	//must check for month wrap arounds
	mDate.tm_year += mDate.tm_mon / 12;     //collapses the month count into years-to-add
	                                        //since it may now be out of the 0-11 range. 
	mDate.tm_mon   = mDate.tm_mon % 12;     //and sets the month to the remainder left over

	//special handling for the negative case
	if (mDate.tm_mon < 0) {
		mDate.tm_year--;
		mDate.tm_mon += 12;
	}

	//handles EOM
	if (aAdjustForEOM) {
		int endOfMonth = GetDaysInMonth(mDate.tm_mon + 1, mDate.tm_year + 1900);
		if (mDate.tm_mday > endOfMonth)
			mDate.tm_mday = endOfMonth;
	}

	mCalculated = false;
}

//adds the specified amount of years to the current date
void MTDate::AddYear(int aYears, bool aAdjustForEOM) {
	mDate.tm_year += aYears;

	//handles EOM leap year condition
	if (aAdjustForEOM) {
		int endOfMonth = GetDaysInMonth(mDate.tm_mon + 1, mDate.tm_year + 1900);
		if (mDate.tm_mday > endOfMonth)
			mDate.tm_mday = endOfMonth;
	}

	mCalculated = false;
}




//moves the current date ahead to the next occurrence of the
//given day of the week (Sunday == 1)
void MTDate::NextWeekday(int aWeekday) {

	//makes sure we get the associated week day (lazy evaluation)
	if (!mCalculated)
		Calculate();

	aWeekday--; //day is now between 0-6

	//finds the difference between the current day and the next weekday
	int delta = aWeekday - mDate.tm_wday; 
	if (delta < 0)
		delta += 7;

	//adds the difference
	AddDay(delta);
}


//calculates the date based on information in mDate
void MTDate::Calculate() const {
	if (!mValid)
		return;

	ASSERT(IsValid());

	//this method obeys logical constness, not physical constness, so
	//it must get a non-const pointer to this
	MTDate* ncThis = const_cast<MTDate*>(this);

	//unset values for tm_hour etc... will give mktime trouble
	ClearUnusedFields();

	//converts the date to time
	time_t time = mktime(&ncThis->mDate);
	if (time == -1) {
		ncThis->mValid = false;
		return;
	}

	//converts the time back to date (forcing day of week calculation)
	struct tm* tempDate;
	tempDate = localtime(&time);
	if (tempDate == NULL) {
		ncThis->mValid = false;
		return;
	}

	//copies the struct since localtime points to a static tm
	ncThis->mDate = *tempDate;

	ncThis->mCalculated = true;
}


//calculates and stores the date based on the time_t passed in
void MTDate::Calculate(const time_t& arTime) const {
	if (!mValid)
		return;

	//this method obeys logical constness, not physical constness, so
	//it must get a non-const pointer to this
	MTDate* ncThis = const_cast<MTDate*>(this);

	struct tm* tempDate;
	tempDate = localtime(&arTime);

	if (tempDate == NULL) {
		ncThis->mValid = false;
		return;
	}

	//copies the struct since localtime points to a static tm
	ncThis->mDate = *tempDate;

	ncThis->mCalculated = true;
}

//clears unused fields in the struct tm mDate
void MTDate::ClearUnusedFields() const {

	//this method obeys logical constness, not physical constness, so
	//it must get a non-const pointer to this
	MTDate* ncThis = const_cast<MTDate*>(this);

	//we do not want DST so by setting this to 0 we are in standard time
	//if this is set to 1 or -1 there will be problems (trust me!)
	ncThis->mDate.tm_isdst = 0;

	//zeros out the unused fields to be safe
	ncThis->mDate.tm_sec   = 0;
	ncThis->mDate.tm_min   = 0;
	ncThis->mDate.tm_hour  = 0;
	ncThis->mDate.tm_wday  = 0;
	ncThis->mDate.tm_yday  = 0;
}


//determines if the given year is a leap year
//NOTE: I did not implement the following logic, the code came from
//A Computer Science Tapestry, second edition (ISBN: 0072322039)
//http://www.cs.duke.edu/~ola/ap/datestuff.html
bool MTDate::IsLeap(int aYear) {
	if (aYear % 400 == 0){
		return true;
	}
	else if (aYear % 100 == 0){
		return false;
	}
	else if (aYear % 4 == 0){
		return true;
	}
	
	return false;
}


//returns the amount of days in a given month from a given year
int MTDate::GetDaysInMonth(int aMonth, int aYear) {
	if ((aMonth == 2) && IsLeap(aYear))
		return 29;

	return monthDays[aMonth - 1];
}


//assignment operator
//performs a memberwise copy of the internal tm structs
MTDate& MTDate::operator=(const MTDate& arDate) {
	mDate = arDate.mDate;
	mValid = arDate.mValid;
	mCalculated = arDate.mCalculated;
	return *this;
}

#ifdef _WIN32
//assignment operator
//performs a memberwise copy of the internal tm structs
MTDate& MTDate::operator=(const DATE& arOLEDate) {
	SetDate(arOLEDate);
	return *this;
}
#endif

//adds the amount of days to the given date
MTDate operator+(const MTDate& a, int dx) {
	MTDate result(a);
	result.AddDay(dx);
	return result;
}

//subtracts the amount of days to the given date
MTDate operator-(const MTDate& a, int dx) {
	MTDate result(a);
	result.SubtractDay(dx);
	return result;
}

// returns the distance in days between two dates
unsigned long operator-(const MTDate& a, const MTDate& b) {
	if (a > b)
		return a.GetDaysSinceEpoch() - b.GetDaysSinceEpoch();
	else
		return b.GetDaysSinceEpoch() - a.GetDaysSinceEpoch();
}


//adds a day to the current date (postfix increment)
MTDate MTDate::operator++(int) {
	MTDate hold = *this;
	AddDay(1);
	return hold;
}

//subtracts a day from the current date (postfix decrement)
MTDate MTDate::operator--(int) {
	MTDate hold = *this;
	SubtractDay(1);
	return hold;
}

//tests for date equality
//uses member data to be efficient (rather than accessor methods)
bool operator==(const MTDate& a, const MTDate& b) {
	return ((a.mDate.tm_mday == b.mDate.tm_mday) &&
					(a.mDate.tm_mon  == b.mDate.tm_mon) &&
					(a.mDate.tm_year == b.mDate.tm_year));
}









