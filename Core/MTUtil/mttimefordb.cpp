/**************************************************************************
 * MTTIMEFORDB
 *
 * Copyright 1997-2002 by MetraTech Corp.
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
#include <mtcom.h>

#import <MetraTime.tlb>

#include <string>

using METRATIMELib::IMetraTimeClientPtr;
using METRATIMELib::IMetraTimeControlPtr;
using METRATIMELib::MetraTimeClient;
using METRATIMELib::MetraTimeControl;

static BOOL gOverrideSetup = FALSE;
static BOOL gUseOverride = FALSE;

_variant_t GetMTTimeForDB()
{
	BOOL offsetFound = FALSE;
	long offset;
	if (!gOverrideSetup || gUseOverride)
	{
		try
		{
			//ComInitialize comInit;

			IMetraTimeControlPtr timeControl(__uuidof(MetraTimeControl));

			offset = timeControl->GetSimulatedTimeOffset();
			offsetFound = TRUE;

			gOverrideSetup = TRUE;
			gUseOverride = TRUE;
		}
		catch (_com_error &)
		{ }

		if (!offsetFound)
		{
			offset = 0;

			gOverrideSetup = TRUE;
			gUseOverride = FALSE;
		}
	}

	FILETIME currentFileTime;
	GetSystemTimeAsFileTime(&currentFileTime);

	ULARGE_INTEGER largeTime;
	largeTime.LowPart = currentFileTime.dwLowDateTime;
	largeTime.HighPart = currentFileTime.dwHighDateTime;

	ULARGE_INTEGER adjustedLargeTime;
	adjustedLargeTime.QuadPart = largeTime.QuadPart +
		(ULONGLONG) offset * (ULONGLONG) (1000 * 1000 * 10);

	currentFileTime.dwLowDateTime = adjustedLargeTime.LowPart;
	currentFileTime.dwHighDateTime = adjustedLargeTime.HighPart;

	SYSTEMTIME currentSystemTime;
	BOOL result = FileTimeToSystemTime(&currentFileTime, &currentSystemTime);
	ASSERT(result);

	wchar_t buffer[255];
	wsprintf(buffer, L"{ts \'%d-%02d-%02d %02d:%02d:%02d.%03d\'}",
					 currentSystemTime.wYear,
					 currentSystemTime.wMonth,
					 currentSystemTime.wDay,
					 currentSystemTime.wHour,
					 currentSystemTime.wMinute,
					 currentSystemTime.wSecond,
					 currentSystemTime.wMilliseconds);

	return _variant_t(_bstr_t(buffer));
}
