/**************************************************************************
 * @doc ISOTIME
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header$
 ***************************************************************************/

#include <MTUtil.h>

#include <time.h>
#include <stdio.h>

#ifdef UNIX

// returns a number, corresponding to _timezone value under WIN32.
// This is a difference between local time and GMT in seconds.
static time_t MTGetLocalTimeZoneShift()
{
	tm tmlocal, tmgmt;
	const time_t sometime = 100000;	// some time, not close to 0

	// get local and gmt for some constant time
	tmlocal = *localtime(&sometime);
	tmgmt = *gmtime(&sometime);

	// convert local and gmt into time_t
	time_t ttlocal, ttgmt;
	ttlocal = mktime(&tmlocal);
	ttgmt = mktime(&tmgmt);

	// return difference between local and gmt	
	return ttlocal - ttgmt;
}

#endif

BOOL MTParseISOTime(const char * apTimeString, time_t * apTime)
{
  //     YYYY-MM-DDThh:mm:ssTZD
	// ex: 1994-11-05T08:15:30-05:00
	struct tm tm;

	int year, mon, day;
	//char sign;
	//int offsetHours, offsetMins;
	// %c%2d:%2d
	int fields = sscanf(apTimeString, "%4d-%2d-%2dT%2d:%2d:%2dZ",
											&year, &mon, &day,
											&tm.tm_hour, &tm.tm_min, &tm.tm_sec);

											//&sign, &offsetHours, &offsetMins);
	if (fields != 6)
		return FALSE;								// invalid date format
	tm.tm_year = year - 1900;
	tm.tm_mon = mon - 1;
	tm.tm_mday = day;

	// reset other fields
	tm.tm_wday = 0;
	tm.tm_yday = 0;
	tm.tm_isdst = 0;							// GMT/UTC never uses DST
//	tm.tm_isdst = -1;							// -1 mean compute DST

  // Need to ensure that value is convertable to _time_t64 or else we hit assertion in debug mode
  if( tm.tm_year > 1100)
  {
    return FALSE;
  }

	// mktime converts _local_ time
	// so it needs to be adjusted back to GMT
	*apTime = mktime(&tm);
	if (*apTime == (time_t) -1)
		return FALSE;								// invalid conversion to unix time

#ifdef _WIN32
	*apTime -= _timezone;
#else
	*apTime -= MTGetLocalTimeZoneShift();
#endif

	if (*apTime == (time_t) -1)
		return FALSE;								// invalid conversion to unix time

#if 0
	int offset = (offsetHours * 60 * 60) + (offsetMins * 60);
	switch (sign)
	{
	case '+':
		break;
	case '-':
		offset = - offset;
		break;
	default:
		return FALSE;								// invalid offset sign
	}
#endif

	// adjust the time to convert it to UTC time
	// TODO: why don't we have to adjust the offset?
//	mTime += offset;

	return TRUE;
}

void MTFormatISOTime(time_t aISOTime, string & arBuffer)
{
  //     YYYY-MM-DDThh:mm:ssTZD
	// ex: 1994-11-05T08:15:30-05:00
	//       %Y-%m-%dT%H:%M:%S

	//long aab = time(NULL);
	//struct tm * tm = gmtime((time_t *) &aab);
	struct tm * tm = gmtime(&aISOTime);
	//struct tm * tm = localtime((time_t *) &aISOTime);


	char buffer[40];
#if 0

	arBuffer = ctime(&aab);
	//ctime
	return;
#endif


	strftime(buffer, sizeof(buffer), "%Y-%m-%dT%H:%M:%SZ", tm);
	arBuffer = buffer;

	// TODO: adjust time with timezone offset
#if 0
	// TODO: calculate the time zone ahead of time
	// NOTE: make sure use of tm is complete before calling
	// ftime.  It reinitializes tm.
	struct _timeb timebuffer;
	_ftime(&timebuffer);

	// timezone difference
	// TODO: is the sign of this calculation correct?
	if (timebuffer.timezone > 0)
		sprintf(buffer, "-%02d:%02d",
						timebuffer.timezone / 60, timebuffer.timezone % 60);
	else
		sprintf(buffer, "+%02d:%02d",
						(-timebuffer.timezone) / 60, (-timebuffer.timezone) % 60);

	arBuffer += buffer;
#endif
}


