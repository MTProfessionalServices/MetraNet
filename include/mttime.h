/**************************************************************************
 * @doc MTTIME
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 *
 * @index | MTTIME
 ***************************************************************************/

#ifndef _MTTIME_H
#define _MTTIME_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include <time.h>

#ifdef WIN32
#include <comutil.h>
#endif

// return the current system time.  This differs from TIME because it can be overridden
// for testing.
time_t GetMTTime();

#ifdef WIN32
// return the current system time as an OLE date.
// This differs from TIME because it can be overridden for testing.
_variant_t GetMTOLETime();
#endif

// returns the maximum date supported by the system. 
// hopefully we will get ride of time_t's because they only support
// dates to 2038.
time_t getMaxDate();

#ifdef WIN32
_variant_t GetMaxMTOLETime();
#endif

time_t getMinDate();

#ifdef WIN32
// This is based on time_t, so it NOT the same as the minimum
// date in the database
_variant_t getMinMTOLETime();
// This is the same as the value return by the database UDF MTMinDate().
_variant_t GetMinDatabaseTime();
#endif

// override the timestamp used by GetMTTime.  Currently this sets the value in the process
// environment.
//void OverrideMTTime(const char * apTimeString);

#ifdef WIN32
// return the current (possibly adjusted) time formatted in the ODBC
// escape sequence form
_variant_t GetMTTimeForDB();
#endif

#endif /* _MTTIME_H */
