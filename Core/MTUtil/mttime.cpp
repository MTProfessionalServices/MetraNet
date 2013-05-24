/**************************************************************************
 * MTTIME
 *
 * Copyright 1997-2001 by MetraTech Corp.
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mttime.h>
#include <MTUtil.h>
#ifdef WIN32
#include <mtcom.h>
#endif

#include <stdlib.h>

#ifdef WIN32
#import <MetraTime.tlb>

using METRATIMELib::IMetraTimeClientPtr;
using METRATIMELib::MetraTimeClient;

static BOOL gOverrideSetup = FALSE;
static BOOL gUseOverride = FALSE;
#endif

time_t GetMTTime()
{
#ifdef WIN32
	if (!gOverrideSetup || gUseOverride)
	{
		try
		{
      //CR 12682: it will trash Com+ context
      //ComInitialize comInit;

			IMetraTimeClientPtr timeClient(__uuidof(MetraTimeClient));

			long currentTime;
			HRESULT hr = timeClient->raw_GetMTTime(&currentTime);
			if (SUCCEEDED(hr))
			{
				gOverrideSetup = TRUE;
				gUseOverride = TRUE;
				return currentTime;
			}
		}
		catch (_com_error &)
		{ 
			ASSERT(!"Initialize COM before using MetraTime!");
		}

		gOverrideSetup = TRUE;
		gUseOverride = FALSE;
	}

#endif
	return time(NULL);
}

#ifdef WIN32
_variant_t GetMTOLETime()
{
	if (!gOverrideSetup || gUseOverride)
	{
		try
		{
			//CR 12682: it will trash Com+ context
      //ComInitialize comInit;

			IMetraTimeClientPtr timeClient(__uuidof(MetraTimeClient));

			VARIANT varTime;
			HRESULT hr = timeClient->raw_GetMTOLETime(&varTime);
			if (SUCCEEDED(hr))
			{
				gOverrideSetup = TRUE;
				gUseOverride = TRUE;
				// attach to the variant and return it
				return _variant_t(varTime, false);
			}
		}
		catch (_com_error &)
		{
			ASSERT(!"Initialize COM before using MetraTime!");
		}

		gOverrideSetup = TRUE;
		gUseOverride = FALSE;
	}

	DATE oleTime;
	OleDateFromTimet(&oleTime, time(NULL));
	return _variant_t(oleTime, VT_DATE);
}
#endif

#if 0
time_t GetMTTime()
{
	static const char * timeVar = getenv("MTTIME");
	if (!timeVar)
		// don't override the time
		return time(NULL);
	else
	{
		// environment variable is formatted as:
		// 10/22/2000   (this means midnight, 00:00:00, of that day)
		// 10/22/2000 5:21:00 (this means the time is specified)
		static time_t convertedTime = -1;
		if (convertedTime == -1)
		{
			// test length so we can make all buffers a reasonable size
			if (strlen(timeVar) > 100)
			{
				ASSERT(0);
				return time(NULL);
			}

			int mon, day, year;
			char timeStr[100];
			int count = sscanf(timeVar, "%d/%d/%d %s",
												 &mon, &day, &year, timeStr);
			if (count != 4 && count != 3)
			{
				ASSERT(0);
				return time(NULL);			// can't be converted
			}


			tm newTime;
			newTime.tm_year = year - 1900;
			newTime.tm_mon = mon - 1;
			newTime.tm_mday = day;

			newTime.tm_hour = 0;
			newTime.tm_min = 0;
			newTime.tm_sec = 0;

			// reset other fields
			newTime.tm_wday = 0;
			newTime.tm_yday = 0;
			newTime.tm_isdst = 0;			// GMT/UTC never uses DST

			// mktime converts _local_ time
			// so it needs to be adjusted back to GMT
			convertedTime = mktime(&newTime);
			convertedTime -= _timezone;

			if (count == 4 && strlen(timeStr) > 0)
				// add in the time component
				convertedTime += MTConvertTime((std::string) timeStr);
		}

		return convertedTime;
	}
}

_variant_t GetMTOLETime()
{
	DATE oleTime;
	OleDateFromTimet(&oleTime, GetMTTime());
	return _variant_t(oleTime, VT_DATE);
}

void OverrideMTTime(const char * apTimeString)
{
	// set the new date into the environment
	std::string buffer("MTTIME=");
	buffer += apTimeString;
	_putenv(buffer.c_str());
}
#endif

time_t getMaxDate()
{
  // Midnight Jan 1, 2038 
	return 0x7FE81780;
}

#ifdef WIN32
_variant_t GetMaxMTOLETime()
{
	DATE oleTime;
	OleDateFromTimet(&oleTime, getMaxDate());
	return _variant_t(oleTime, VT_DATE);
}
#endif

time_t getMinDate()
{
	return 0;
}

#ifdef WIN32
_variant_t getMinMTOLETime()
{
	DATE oleTime;
	OleDateFromTimet(&oleTime, getMinDate());
	return _variant_t(oleTime, VT_DATE);
}
#endif

#ifdef WIN32
_variant_t GetMinDatabaseTime()
{
	static bool init = false;
	static DATE oleTime;
	if(!init)
	{
		_bstr_t bStr(L"1/1/1753");
		::VarDateFromStr(bStr, LOCALE_SYSTEM_DEFAULT, 0, &oleTime);
		init = true;
	}
	return _variant_t(oleTime, VT_DATE);
}
#endif
