/**************************************************************************
 * @doc WEIGHT
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
 ***************************************************************************/

#include <mtcom.h>
#include <PlugInSkeleton.h>
#include <MTDec.h>
#include <perflog.h>

#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF")
#import <MTEnumConfigLib.tlb>

// generate using uuidgen
CLSID CLSID_CalendarTimesPlugIn =
{ /* c11b2ce0-00c5-11d3-a1e8-006008c0e24b */
    0xc11b2ce0,
    0x00c5,
    0x11d3,
    {0xa1, 0xe8, 0x00, 0x60, 0x08, 0xc0, 0xe2, 0x4b}
};

#include <ConfiguredCal.h>
#include <processor.h>
#include <ConfigDir.h>
#include <ConfiguredCalCache.h>
#include <SetIterate.h> 
#include <stdutils.h>

typedef std::vector<MTDecimal> DecimalVector;
typedef std::map<long, TimeSegmentVector*> SegmentsMap;
typedef std::map<long, TimeSegmentVector*>::iterator SegmentsMapIterator;
typedef std::map<long, DecimalVector> RateMap;

typedef std::map <string, int> DurationMap;

class ATL_NO_VTABLE CalendarTimesPlugIn
	: public MTPipelinePlugIn<CalendarTimesPlugIn, &CLSID_CalendarTimesPlugIn>
{
public:
	CalendarTimesPlugIn();

protected:
	
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
																	MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();
	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);
 	virtual HRESULT PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet);
	
private:
	HRESULT ClearAndDestroySegmentMap(SegmentsMap mSegmentsMap);
	
	vector<long> mRatePropID;

	long mCalendarPropID;
	long mStartTimePropID;
	long mEndTimePropID;
	long mZoneIDPropID;
	long mCalendarIDPropID;

	long mCalendarTimePeakPropID;
	long mCalendarTimeOffpeakPropID;
	long mCalendarTimeWeekendPropID;
	long mCalendarTimeHolidayPropID;

	bool mbEnumCalendarCode;
	bool mbPluginSupportsEnumCalendarCode;

	//_bstr_t mExecutePlugIn;
	_bstr_t mStageName;

	_bstr_t mCalendarCodeEnumSpace;
	_bstr_t mCalendarCodeEnumType;

	_bstr_t mCalendarFileName;
	_bstr_t mCalendarDir;

  // Yes, another cache.  It turns otu TranslateZone is
  // going through .NET interop (in fact creates a .NET object)
  // and hence is quite expensive.  This data never changes, so
  // no harm in caching here.
  std::map<long, std::string> mLocalZoneIdCache;

  ConfiguredCalendarCache mCalendarCache;
 
	CompositePlugIn mPlugIn;

	//MTPipelineLib::IMTSessionServerPtr mSessionServer;
	MTPipelineLib::IMTLogPtr mLogger;

	MTPRODUCTCATALOGLib::IMTProductCatalogPtr mProdCat;

	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
};


PLUGIN_INFO(CLSID_CalendarTimesPlugIn, CalendarTimesPlugIn,
						"MetraPipeline.CalendarTimes.1", "MetraPipeline.CalendarTimes", "Free")


#include <mtprogids.h>
#include <pipelineconfig.h>
#include <propids.h>

CalendarTimesPlugIn::CalendarTimesPlugIn()
	: mPlugIn("logging", "[Plug-in]")
{ 
}

HRESULT
CalendarTimesPlugIn::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																		MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																		MTPipelineLib::IMTNameIDPtr aNameID,
																		MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	MTConfigLib::IMTConfigPropPtr prop;

	// read the configuration

	_bstr_t calendarCodePropName = aPropSet->NextStringWithName("calendar_code_prop_name");

	prop = aPropSet->Next();
	if(	prop != NULL && 
			!_wcsicmp( (wchar_t*)prop->GetName(), L"SetEnumCalendarCode") &&
			prop->GetPropType() ==  MTPipelineLib::PROP_TYPE_BOOLEAN
		)
	{
		_variant_t val = prop->GetPropValue();
		mbEnumCalendarCode = val.boolVal == VARIANT_TRUE;
		mCalendarCodeEnumSpace = aPropSet->NextStringWithName("calendar_code_enum_space");
		mCalendarCodeEnumType = aPropSet->NextStringWithName("calendar_code_enum_type");
		mbPluginSupportsEnumCalendarCode = TRUE;
	}
	else /* old plugin configuration file, just go back to previous entry */
	{
		aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,
										 "Old plugin configuration file, CalendarCode property will be set as STRING");
		mbPluginSupportsEnumCalendarCode = FALSE;
		aPropSet->Previous();
	}
	
	_bstr_t startTimePropName = aPropSet->NextStringWithName("start_time_prop_name");
	_bstr_t endTimePropName = aPropSet->NextStringWithName("end_time_prop_name");
	_bstr_t timezoneIDPropName = aPropSet->NextStringWithName("timezoneid_prop_name");

	mCalendarFileName = aPropSet->NextStringWithName("calendar");
	_bstr_t mCalendarIDPropName	= aPropSet->NextStringWithName("calendar_id_prop_name");

 	_bstr_t mCalendarTimePeakPropName	= aPropSet->NextStringWithName("CalendarTimeOutputProperty_Peak");
	_bstr_t mCalendarTimeOffpeakPropName	= aPropSet->NextStringWithName("CalendarTimeOutputProperty_Offpeak");
	_bstr_t mCalendarTimeWeekendPropName	= aPropSet->NextStringWithName("CalendarTimeOutputProperty_Weekend");
	_bstr_t mCalendarTimeHolidayPropName	= aPropSet->NextStringWithName("CalendarTimeOutputProperty_Holiday");


	mCalendarPropID = aNameID->GetNameID(calendarCodePropName);
	mStartTimePropID = aNameID->GetNameID(startTimePropName);
	mEndTimePropID = aNameID->GetNameID(endTimePropName);
	mZoneIDPropID = aNameID->GetNameID(timezoneIDPropName);
	mCalendarIDPropID = aNameID->GetNameID(mCalendarIDPropName);

  mCalendarTimePeakPropID =     aNameID->GetNameID(mCalendarTimePeakPropName);
  mCalendarTimeOffpeakPropID =  aNameID->GetNameID(mCalendarTimeOffpeakPropName);
  mCalendarTimeWeekendPropID =  aNameID->GetNameID(mCalendarTimeWeekendPropName);
  mCalendarTimeHolidayPropID =  aNameID->GetNameID(mCalendarTimeHolidayPropName);


	// initialize the config loader

	string configDir;
	if (!GetMTConfigDir(configDir))
		return E_FAIL;							// if this didn't work we wouldn't have been called

	_bstr_t aStageDir = aSysContext->GetStageDirectory();

	mEnumConfig = aSysContext->GetEnumConfig();
/*
	MTPipelineLib::IMTConfigLoaderPtr configLoader(MTPROGID_CONFIGLOADER);
	configLoader->InitWithPath(aStageDir);

  // initialize the session server we will use to run our rating plugin

	aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Initializing session server.");
	HRESULT hr = mSessionServer.CreateInstance(MTPROGID_SESSION_SERVER);
	if (FAILED(hr))
	{
		aLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
											 "Unable to create session server object");
		return hr;
	}

#if 0

	mSessionServer->Init((const char *) pipelineInfo.GetSharedSessionFile(),
											 (const char *) pipelineInfo.GetShareName(),
											 pipelineInfo.GetSharedFileSize());
#endif

	aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,
										 "Preparing external plug-in");
  

	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
*/
	// configure the rate plug-in
  
  /*
	if (!mPlugIn.Configure(config, configLoader, "", mStageName, mSessionServer))
	{
		aLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
											 "Unable to initialize external plug-in");
		return mPlugIn.GetLastError()->GetCode();
	}

	aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,
										 "Loading external plug-in");

	if (!mPlugIn.LoadProcessor())
	{
		aLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
											 "Unable to load external plug-in");
		return mPlugIn.GetLastError()->GetCode();
	}

	aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,
										 "Initializing external plug-in");

	if (!mPlugIn.Initialize(aSysContext))
	{
		aLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
											 "Unable to load external plug-in");
		return mPlugIn.GetLastError()->GetCode();
	}
  */

  /*
	// initialize the pipeline
	PipelineInfo pipelineInfo;

	PipelineInfoReader pipelineReader;

	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		aLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
											 "Unable to read pipeline configuration");
		return pipelineReader.GetLastError()->GetCode();
	}
*/
	mLogger = aLogger;

	// TODO: shouldn't need to do this!
	PipelinePropIDs::Init();

	// construct path to global calendar files directory
	mCalendarDir = aStageDir;

  // create a product catalog instance for latter use
	return mProdCat.CreateInstance(__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
}


HRESULT CalendarTimesPlugIn::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	return E_NOTIMPL;
}


HRESULT CalendarTimesPlugIn::PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)  
{
	MarkRegion region ("CalendarTimes");

	HRESULT hr = S_OK;

	// gets an iterator for the set of sessions
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	hr = it.Init(aSet);
	if (FAILED(hr))
		return hr;

	// Maps
	// The map below will keep track of the weighted rate for each session in the session set
	RateMap mRateMap;
	// This is the structure that will hold a list of segments for each session in sessionset.
	SegmentsMap mSegmentsMap;

  //This is a pointer to the calendar we will use to process each session
  Calendar* pCalendar;

	MTPipelineLib::IMTSessionPtr session;

  bool bFailure = false;

	while ((session = it.GetNext()) != NULL)  
	{
		// CHOOSING A CALENDAR - Check to see if we have the appropriate calendar in the cache
    // or if we need to load it from the database or from the file and then add it to the
    // cache
		if (session->PropertyExists(mCalendarIDPropID, MTPipelineLib::SESS_PROP_TYPE_LONG)) 
		{
			// Calendar ID is specified in the session so we will load it from the
      // database/product catalog
			long calendarID = session->GetLongProperty(mCalendarIDPropID);

			pCalendar = mCalendarCache.Find(calendarID);

			if (!pCalendar)
			{
				ConfiguredCalendarDB * pTemp = new ConfiguredCalendarDB;
				if(!pTemp->Setup(calendarID))
				{
					delete pTemp;
					pTemp = NULL;
				}
				pCalendar = pTemp;
				mCalendarCache.Insert(calendarID,pCalendar);
			}
		}
		else
		{
			// If we do not have a calendar id, then we assume it is the calendar specified by
      // the plugin config file and we will explicitly use/store it in the cache as id 0.
			pCalendar = mCalendarCache.Find(0);
			
			if (!pCalendar)
			{
				ConfiguredCalendar * pTemp = new ConfiguredCalendar;
				if (!pTemp->Setup(mCalendarDir, mCalendarFileName))
				{
					delete pTemp;
					pTemp=NULL;
				}
				pCalendar = pTemp;
				mCalendarCache.Insert(0,pCalendar);
			}
		}

		//Safety check to make sure we have a calendar
		if (!pCalendar)
		{
			char buffer[100];
			sprintf(buffer, "Could not configure calendar for one of the sessions in set.");
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
      session->MarkAsFailed(buffer, E_FAIL);
      bFailure = true;
			//return Error(buffer);
		}
		
		// split into periods based on start/end time
		long startTime = session->GetDateTimeProperty(mStartTimePropID);
		long endTime = session->GetDateTimeProperty(mEndTimePropID);
		
		if (startTime > endTime)
		{
			// that doesn't make sense.. the calendar library will hang
			// if the times are reversed
      //BP: this is the part where PSG noticed the issue I am fixing (ES 1396):
      //This is most likely the only place where we really need to handle partial failures.
			session->MarkAsFailed("Session start time is after end time", E_FAIL);
      bFailure = true;
		}

		// We will retrieve the zone id from the enum id that was set in the session
		long zone_enumid = session->GetLongProperty(mZoneIDPropID);
		long zoneid = _wtol(mEnumConfig->GetEnumeratorValueByID(zone_enumid));
		
		// TODO: zone determination - temporary!
    map<long,std::string>::const_iterator tz = mLocalZoneIdCache.find(zoneid);
    if (tz == mLocalZoneIdCache.end())
    {
      mLocalZoneIdCache[zoneid] = Calendar::TranslateZone(zoneid);
      tz = mLocalZoneIdCache.find(zoneid);
		}

		if (tz->second.length() == 0)
		{
			char buffer[100];
			sprintf(buffer, "Unsupported zone ID: %d", zoneid);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
			session->MarkAsFailed(buffer, E_FAIL);
      bFailure = true;
		}
		
		if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG) == VARIANT_TRUE)
		{
			if (pCalendar->GetUsesFixedOffset())
			{
				string logString = "Using fixed timezone offset of ";
				char buffer[40];
				sprintf(buffer, "%s", pCalendar->GetFixedOffset().c_str());
				logString += buffer;
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, logString.c_str());
			}
			else
			{
        char buf[512];
        sprintf(buf, "Using floating timezone of '%s'", tz->second.c_str());
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
			}
		}

		TimeSegmentVector* segments = new TimeSegmentVector();

		// Now, we will call SplitTimeSpan for this session and put the resulting segment
    // in mSegmentsMap
		if (!pCalendar->SplitTimeSpan(startTime, endTime, tz->second.c_str(), *segments))
		{
			// segments.clearAndDestroy();
			hr = ClearAndDestroySegmentMap(mSegmentsMap);
			if (FAILED(hr))
				return hr;
			return Error("Unable to split time span");
		}
		long dbg_nsegs = segments->size();

		mSegmentsMap[session->GetSessionID()] = segments;

    DurationMap durations;
    durations["Peak"]=0;
    durations["Off-Peak"]=0;
    durations["Weekend"]=0;
    durations["Holiday"]=0;

			for (int i = 0; i < (int) mSegmentsMap[session->GetSessionID()]->size(); i++)
			{
				struct tm *tempTime;
				TimeSegment * segment = (*mSegmentsMap[session->GetSessionID()])[i];
	
        durations[segment->GetCode().c_str()]+=segment->GetDuration();

		    if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
		    {
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "-- Time Segment--");
				  time_t segStart = segment->GetStartTime();
				  tempTime = gmtime(&segStart);
				  const char * timeString = asctime( tempTime );
				  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Start time:");
				  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, timeString);

				  time_t segEnd = segment->GetEndTime();
				  tempTime = gmtime(&segEnd);
				  timeString = asctime( tempTime );
				  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "End time:");
				  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, timeString);
  				
				  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Code:");
				  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,
													  segment->GetCode().c_str());
        }
			}

      if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
		  {
        char buffer[100];
		    sprintf(buffer, "Total duration Peak [%d]",durations["Peak"]);
		    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,buffer);

 		    sprintf(buffer, "Total duration Off-Peak [%d]",durations["Off-Peak"]);
		    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,buffer);

 		    sprintf(buffer, "Total duration Weekend [%d]",durations["Weekend"]);
		    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,buffer);

        sprintf(buffer, "Total duration Holiday [%d]",durations["Holiday"]);
		    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,buffer);
      }

    if (mCalendarTimePeakPropID != -1)
      session->SetLongProperty(mCalendarTimePeakPropID, durations["Peak"]);
    if (mCalendarTimeOffpeakPropID != -1)
      session->SetLongProperty(mCalendarTimeOffpeakPropID, durations["Off-Peak"]);
    if (mCalendarTimeWeekendPropID != -1)
      session->SetLongProperty(mCalendarTimeWeekendPropID, durations["Weekend"]);
    if (mCalendarTimeHolidayPropID != -1)
      session->SetLongProperty(mCalendarTimeHolidayPropID, durations["Holiday"]);

	}

	hr = ClearAndDestroySegmentMap(mSegmentsMap);
  return (bFailure == true) ? PIPE_ERR_SUBSET_OF_BATCH_FAILED : hr;
}

HRESULT CalendarTimesPlugIn::ClearAndDestroySegmentMap(SegmentsMap mSegmentsMap)
{
	HRESULT hr = S_OK;
	
	SegmentsMapIterator segMapIter;
	TimeSegmentVector segments;

	for (segMapIter = mSegmentsMap.begin(); segMapIter != mSegmentsMap.end(); ++segMapIter)
	{
		TimeSegmentVector * segments = segMapIter->second;

		// free the contents of the vector
		TimeSegmentVector::iterator it;
		for (it = segments->begin(); it != segments->end(); it++)
			delete *it;
		segments->clear();

		delete(segments);
	}
	
	return hr;
}

HRESULT CalendarTimesPlugIn::PlugInShutdown()
{
	return S_OK;
}
