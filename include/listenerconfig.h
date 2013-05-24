/**************************************************************************
 * @doc LISTENERCONFIG
 *
 * @module |
 *
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
 *
 * @index | LISTENERCONFIG
 ***************************************************************************/

#ifndef _LISTENERCONFIG_H
#define _LISTENERCONFIG_H

#include <map>
#include <string>

using std::map;
using std::string;

#include <errobj.h>

#if defined(DEFINING_CONFIGREADERS) && !defined(DLL_EXPORT_READERS) 
#define DLL_EXPORT_READERS __declspec( dllexport )
#else
#define DLL_EXPORT_READERS //__declspec( dllimport )
#endif

// 30 seconds
const static long DEFAULT_FEEDBACK_TIMEOUT = 30;

/*
 * tags used in the pipeline.xml file
 */

#define LISTENERCONFIG_VERSION_TAG "version"


/********************************************** StageMapInfo ***/

// stage name and timeout.
class StageMapInfo
{
public:
	const char * GetName() const
	{ return mStageName.c_str(); }

	void SetName(const char * apName)
	{ mStageName = apName; }

	// returns the service specific timeout, or -1 if non is specified.
	int GetTimeout() const
	{ return mTimeout; }

	// set the service specific timeout to the specified value
	void SetTimeout(int aTimeout)
	{ mTimeout = aTimeout; }

	// make the service specific timeout unspecified.
	void SetUnspecifiedTimeout()
	{ mTimeout = -1; }

private:
	string mStageName;
	int mTimeout;
};

/********************************************** ListenerInfo ***/

class ListenerInfo
{
	friend class ListenerInfoReader;
public:

	typedef map<int, StageMapInfo> StageNameMap;

public:
	ListenerInfo() : mDefaultFeedbackTimeout(-1)
	{ }

	virtual ~ListenerInfo()
	{ }


	int GetVersion() const
	{ return mVersion; }

	const StageNameMap & GetStages() const
	{ return mStages; }

	const string & GetRouteToMachine() const
	{ return mRouteToMachine; }

	const string & GetRouteToQueue() const
	{ return mRouteToQueue; }

#if 0
	const string & GetResponsesToMachine() const
	{ return mResponsesToMachine; }

	const string & GetResponsesToQueue() const
	{ return mResponsesToQueue; }
#endif

	const string & GetMeterName() const
	{ return mMeterName; }

	int GetDefaultFeedbackTimeout() const
	{ return mDefaultFeedbackTimeout; }

private:
 	// try to randomize the integer key a bit
	static unsigned int IntHashKey(const int & arKey)
	{ return ((arKey ^ 0xA5A5A5) << 16) ^ arKey; }

	int mVersion;

	string mMeterName;

	string mRouteToMachine;
	string mRouteToQueue;

#if 0
	string mResponsesToMachine;
	string mResponsesToQueue;
#endif

  StageNameMap mStages;

	int mDefaultFeedbackTimeout;
};

/**************************************** ListenerInfoReader ***/

class ListenerInfoReader : public virtual ObjectWithError
{
public:
	BOOL DLL_EXPORT_READERS
	ReadConfiguration(MTConfigLib::IMTConfigPtr & arReader,
										const char * apConfigDir, ListenerInfo & arInfo);

	BOOL DLL_EXPORT_READERS
	GetFileName(const char * apConfigDir, string & arPipelineConfig);

	BOOL DLL_EXPORT_READERS
	ReadConfiguration(MTConfigLib::IMTConfigPropSetPtr & arTop,
										ListenerInfo & arInfo);

protected:
	BOOL ReadServiceToStageMap(ListenerInfo & arInfo);
};




#endif /* _LISTENERCONFIG_H */
