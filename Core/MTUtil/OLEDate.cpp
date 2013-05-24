/**************************************************************************
 * @doc OLEDATE
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
 *
 * $Date$
 * $Author$
 * $Revision$
 * Jiang Chen 4/27/1999
 ***************************************************************************/

#include <metra.h>

#include <time.h>

#include <comutil.h>

#include <MTUtil.h>
#include <mttime.h>

void OleDateFromTimet(DATE * apOleDate, time_t aTime)
{
	struct tm * timeTm = gmtime(&aTime);
	ASSERT(timeTm);

	SYSTEMTIME systemTime;

	systemTime.wDay = timeTm->tm_mday;
	systemTime.wDayOfWeek = timeTm->tm_wday; 
	systemTime.wHour = timeTm->tm_hour;
	systemTime.wMilliseconds =0;
	systemTime.wMinute = timeTm->tm_min;
	systemTime.wMonth = timeTm->tm_mon + 1;	// tm months start from 0
	systemTime.wSecond = timeTm->tm_sec;
	systemTime.wYear = timeTm->tm_year + 1900;

	SystemTimeToVariantTime(&systemTime, apOleDate);

	return;
}

void TimetFromOleDate(time_t * apTime, DATE aDate)
{
	SYSTEMTIME systemTime;
	VariantTimeToSystemTime(aDate, &systemTime);
	
	struct tm timeTm;
	
	timeTm.tm_hour =systemTime.wHour;

	timeTm.tm_min = systemTime.wMinute;
	timeTm.tm_sec = systemTime.wSecond;
	timeTm.tm_mday = systemTime.wDay;
	timeTm.tm_mon = systemTime.wMonth - 1; // system time months start from 1
	timeTm.tm_year = systemTime.wYear-1900; // Year(current year minus 1900)
	timeTm.tm_wday = 0;
	timeTm.tm_isdst = 0;
	timeTm.tm_yday = 0;
	
	// hack because time_t's suck the big one
	if (systemTime.wYear >= 2038)
  {
		*apTime = getMaxDate();
	}
	else
  {
		* apTime = mktime(&timeTm); 
    if (*apTime != -1)
		* apTime -= _timezone;
	}
	return;
}

void StructTmFromOleDate(struct tm * apTime, DATE aDate)
{
	time_t theTime;
	TimetFromOleDate(&theTime, aDate);
	*apTime = *(gmtime(&theTime));

	return;
}


void OleDateFromStructTm(DATE * apOleDate, struct tm * aTimeTm)
{
	SYSTEMTIME systemTime;

	systemTime.wDay = aTimeTm->tm_mday;
	systemTime.wDayOfWeek = aTimeTm->tm_wday; 
	systemTime.wHour = aTimeTm->tm_hour;
	systemTime.wMilliseconds =0;
	systemTime.wMinute = aTimeTm->tm_min;
	systemTime.wMonth = aTimeTm->tm_mon + 1;	// tm months start from 0
	systemTime.wSecond = aTimeTm->tm_sec;
	systemTime.wYear = aTimeTm->tm_year + 1900;

	SystemTimeToVariantTime(&systemTime, apOleDate);

	return;
}
