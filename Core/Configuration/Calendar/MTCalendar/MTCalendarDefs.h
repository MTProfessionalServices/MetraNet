
#ifndef __MTCALENDARDEFS_H_
#define __MTCALENDARDEFS_H_

#include <metra.h>

#define MTDEBUG							0   // 1 debug flag on, 0 debug flag off


// == operator
inline bool operator ==(const CComVariant & arVar1, const CComVariant & arVar2)
{
    ASSERT(0);
	return FALSE;
}

// == operator
inline bool operator <(const CComVariant & arVar1, const CComVariant & arVar2)
{
    ASSERT(0);
	return FALSE;
}

// tag for the calendar logger
const char CALENDAR_STR[] = "Calendar";

// tag names
const char XMLCONFIG_TAG[] = "xmlconfig";
const char CALENDAR_TAG[] = "calendar";
const char WEEKDAY_TAG[] = "weekday";
const char DAYOFYEAR_TAG[] = "dayofyear";
const char DATE_TAG[] = "date";
const char CODE_TAG[] = "code";
const char HOURSSET_TAG[] = "hoursset";
const char TIMEOFDAY_TAG[] = "timeofday";
const char STARTTIME_TAG[] = "starttime";
const char ENDTIME_TAG[] = "endtime";
const char NOTES_TAG[] = "notes";
const char DATESET_TAG[] = "date";
const char DAYTYPE_TAG[] = "daytype";

// config loader stuff
const char MTCONFIGDATA_TAG[] = "mtconfigdata";
const char CALENDAR_CONFIG[] = "calendar.xml";

// weekday strings 
const char MONDAY_STR[] = "monday";
const char TUESDAY_STR[] = "tuesday";
const char WEDNESDAY_STR[] = "wednesday";
const char THURSDAY_STR[] = "thursday";
const char FRIDAY_STR[] = "friday";
const char SATURDAY_STR[] = "saturday";
const char SUNDAY_STR[] = "sunday";
const char DEFAULT_WEEKDAY_STR[] = "defaultweekday";
const char DEFAULT_WEEKEND_STR[] = "defaultweekend";

// weekday strings (wide character)
const wchar_t W_MONDAY_STR[] = L"monday";
const wchar_t W_TUESDAY_STR[] = L"tuesday";
const wchar_t W_WEDNESDAY_STR[] = L"wednesday";
const wchar_t W_THURSDAY_STR[] = L"thursday";
const wchar_t W_FRIDAY_STR[] = L"friday";
const wchar_t W_SATURDAY_STR[] = L"saturday";
const wchar_t W_SUNDAY_STR[] = L"sunday";
const wchar_t W_DEFAULT_WEEKDAY_STR[] = L"defaultweekday";
const wchar_t W_DEFAULT_WEEKEND_STR[] = L"defaultweekend";



#endif
