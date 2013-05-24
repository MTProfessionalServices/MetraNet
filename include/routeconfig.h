/**************************************************************************
 * @doc ROUTECONFIG
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
 * @index | ROUTECONFIG
 ***************************************************************************/

#ifndef _ROUTECONFIG_H
#define _ROUTECONFIG_H

/****************************************** MeterRouteReader ***/

#include <string>

#include <errobj.h>

// Get rid of STL export Warning from compiler.
#pragma warning (disable : 4251)

#if defined(DEFINING_CONFIGREADERS)
#define DllExportReaders __declspec( dllexport )
#else
#define DllExportReaders //__declspec( dllimport )
#endif


class MeterRouteQueueInfo
{
public:
	DllExportReaders const std::string & GetMeterName() const
	{ return mMeterName; }

 	DllExportReaders void SetMeterName(const char * apName)
	{ mMeterName = apName; }


	DllExportReaders const std::wstring & GetMachineName() const
	{ return mMachineName; }

	DllExportReaders void SetMachineName(const wchar_t * apName)
	{ mMachineName = apName; }


	DllExportReaders const std::wstring & GetQueueName() const
	{ return mQueueName; }

	DllExportReaders void SetQueueName(const wchar_t * apName)
	{ mQueueName = apName; }

	DllExportReaders bool operator == (const MeterRouteQueueInfo & /* arInfo */)
	{ ASSERT(0); return FALSE; }

private:
	std::string mMeterName;
	std::wstring mMachineName;
	std::wstring mQueueName;
};

typedef list<MeterRouteQueueInfo> MeterRouteQueueInfoList;

class DllExportReaders MeterRoutes
{
public:
	MeterRoutes();
	virtual ~MeterRoutes();

	MeterRouteQueueInfoList mQueueInfo;

	int mVersion;
};


class MeterRouteReader : public virtual ObjectWithError
{
public:
	DllExportReaders
	BOOL ReadConfiguration(MTConfigLib::IMTConfigPtr & arReader,
												 const char * apConfigDir, MeterRoutes & arInfo);

	DllExportReaders
	BOOL GetFileName(const char * apConfigDir, std::string & arPipelineConfig);

	DllExportReaders
	BOOL ReadConfiguration(MTConfigLib::IMTConfigPropSetPtr & arTop,
												 MeterRoutes & arInfo);
};



#endif /* _ROUTECONFIG_H */
