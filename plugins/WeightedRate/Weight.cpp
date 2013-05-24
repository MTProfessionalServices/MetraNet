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
CLSID CLSID_WeightedRatePlugIn =
{ /* c11b2ce0-00c5-11d3-a1e8-006008c0e24a */
    0xc11b2ce0,
    0x00c5,
    0x11d3,
    {0xa1, 0xe8, 0x00, 0x60, 0x08, 0xc0, 0xe2, 0x4a}
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

class ATL_NO_VTABLE WeightedRatePlugIn
	: public MTPipelinePlugIn<WeightedRatePlugIn, &CLSID_WeightedRatePlugIn>
{
public:
	WeightedRatePlugIn();

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

	bool mbEnumCalendarCode;
	bool mbPluginSupportsEnumCalendarCode;

	_bstr_t mExecutePlugIn;
	_bstr_t mStageName;

	_bstr_t mCalendarCodeEnumSpace;
	_bstr_t mCalendarCodeEnumType;

	_bstr_t mCalendarFileName;
	_bstr_t mCalendarDir;

  ConfiguredCalendarCache mCalendarCache;
 
	CompositePlugIn mPlugIn;

	MTPipelineLib::IMTSessionServerPtr mSessionServer;
	MTPipelineLib::IMTLogPtr mLogger;

	MTPRODUCTCATALOGLib::IMTProductCatalogPtr mProdCat;

	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
};


PLUGIN_INFO(CLSID_WeightedRatePlugIn, WeightedRatePlugIn,
						"MetraPipeline.WeightedRate.1", "MetraPipeline.WeightedRate", "Free")


#include <mtprogids.h>
#include <pipelineconfig.h>
#include <propids.h>

WeightedRatePlugIn::WeightedRatePlugIn()
	: mPlugIn("logging", "[Plug-in]")
{ 
}

HRESULT
WeightedRatePlugIn::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																		MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																		MTPipelineLib::IMTNameIDPtr aNameID,
																		MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	MTConfigLib::IMTConfigPropPtr prop;

	// read the configuration

  // read in the rate schedules to process
	vector<_bstr_t> ratePropName;
	while(aPropSet->NextMatches(L"rate_prop_name", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
	{
		ratePropName.push_back(aPropSet->NextStringWithName("rate_prop_name"));
	}
	if(ratePropName.size() == 0)
	{
		return Error("Must specify at least one rate_prop_name element");
	}

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

	mStageName = aPropSet->NextStringWithName("stage_name");
	mExecutePlugIn = aPropSet->NextStringWithName("execute_plug_in");

	mCalendarFileName = aPropSet->NextStringWithName("calendar");
	_bstr_t mCalendarIDPropName	= aPropSet->NextStringWithName("calendar_id_prop_name");

	// get the property IDs
	for (unsigned int j = 0; j < ratePropName.size(); j++)
	{
		mRatePropID.push_back(aNameID->GetNameID(ratePropName[j]));
	}

	mCalendarPropID = aNameID->GetNameID(calendarCodePropName);
	mStartTimePropID = aNameID->GetNameID(startTimePropName);
	mEndTimePropID = aNameID->GetNameID(endTimePropName);
	mZoneIDPropID = aNameID->GetNameID(timezoneIDPropName);
	mCalendarIDPropID = aNameID->GetNameID(mCalendarIDPropName);

	mPlugIn.SetName(mExecutePlugIn);

	// initialize the config loader

	string configDir;
	if (!GetMTConfigDir(configDir))
		return E_FAIL;							// if this didn't work we wouldn't have been called

	_bstr_t aStageDir = aSysContext->GetStageDirectory();

	mEnumConfig = aSysContext->GetEnumConfig();

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

	// configure the rate plug-in

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

	// initialize the pipeline
	PipelineInfo pipelineInfo;

	PipelineInfoReader pipelineReader;

	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		aLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
											 "Unable to read pipeline configuration");
		return pipelineReader.GetLastError()->GetCode();
	}

	mLogger = aLogger;

	// TODO: shouldn't need to do this!
	PipelinePropIDs::Init();

	// construct path to global calendar files directory
	mCalendarDir = aStageDir;

  // create a product catalog instance for latter use
	return mProdCat.CreateInstance(__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
}


HRESULT WeightedRatePlugIn::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	return E_NOTIMPL;
}


HRESULT WeightedRatePlugIn::PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)  
{
	MarkRegion region ("WeightedRate");

	HRESULT hr = S_OK;

//*** ALGORITHM FOR BATCH WEIGHTED RATE ***

//	1) configuring sessions 
//	For each session in set
//	  load calendar if not already cached (
// 	  call splittimespan to generate segments putting them in structure 1
// 	Next
// 	2) figuring out the rate
// 	While there are sessions with segments unprocessed do 
// 	  int i = 0
// 	  For each session
// 	    if the session has a segment at index i then
// 	      Add session to sessionset
// 	      set calendar code from proper segment in session
// 	    end if
// 	    i++
// 	  Next
// 	  call plugin passing in sessionset
// 	  accumulate percentage in structure 2
// 	  clear sessionset
// 	Wend
// 	3) Set back properties in session and finish
// 	For each session in the original sessionset
// 	  Set average rate, and any other properties in session
// 	Next

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
		// Initialize Weighted Rate placeholder in Map for this session
		for(unsigned int j = 0; j < mRatePropID.size(); j++)
		{
			(mRateMap[session->GetSessionID()]).push_back(0L);
			//weightedRate.push_back(0L);
		}
		
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
		string tz = Calendar::TranslateZone(zoneid);
		
		if (tz.length() == 0)
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
        sprintf(buf, "Using floating timezone of '%s'", tz.c_str());
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
			}
		}

		TimeSegmentVector* segments = new TimeSegmentVector();

		// Now, we will call SplitTimeSpan for this session and put the resulting segment
    // in mSegmentsMap
		if (!pCalendar->SplitTimeSpan(startTime, endTime, tz.c_str(), *segments))
		{
			// segments.clearAndDestroy();
			hr = ClearAndDestroySegmentMap(mSegmentsMap);
			if (FAILED(hr))
				return hr;
			return Error("Unable to split time span");
		}
		long dbg_nsegs = segments->size();

		mSegmentsMap[session->GetSessionID()] = segments;

		// LOGGING info about splitted times
		// NOTE: segments are processed in reverse order because the
		// session should end up with values computed as if the
		// session fell entirely into the first segment.
		if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
		{
			for (int i = 0; i < (int) mSegmentsMap[session->GetSessionID()]->size(); i++)
			{
				struct tm *tempTime;
				TimeSegment * segment = (*mSegmentsMap[session->GetSessionID()])[i];
				
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
	}

	// OK, so by now all sessions should have an entry on mSegmentsMap
	// Loop again, and submit sessionset to helper plugin, setting calendar code properly
  // before doing so. (Loop internally while there are sessions with segments that
  // haven't been processed.)

	long nSessionsToProcess = 1;
	unsigned long segmentColumn = 0;
	long duration = 0;

	// create a set to hold the session
	// the set is passed to the external plugin
	MTPipelineLib::IMTSessionSetPtr helperPluginSetPtr;

	// Remember to update nSessionsToProcess inside loop
	while (nSessionsToProcess > 0)
	{
		// Reset counter
		nSessionsToProcess = 0;
		
		hr = it.Init(aSet);
		if (FAILED(hr))
			return hr;

		// Create a new session set for this batch
		helperPluginSetPtr = mSessionServer->CreateSessionSet();

		// Iterate the sessions, add them to the session set if they have a segment to be
    // processed in this iteration
		while ((session = it.GetNext()) != NULL)  
		{
      //skip the session if it was marked as failed
      if(session->CompoundMarkedAsFailed == VARIANT_TRUE)
      {
        continue;
      }
      
			// We are processing all Nth segments of a session at a time.
			// If the session has <= N segments, we process the Nth segment at iteration N.
			// If it should be processed at this iteration, we set the proper calendar
      // code and add it to the helperPluginSetPtr
			if (segmentColumn < (mSegmentsMap[session->GetSessionID()])->size())
			{
				// TimeSegmentVector * segments = mSegmentsMap[session->GetSessionID()];
				TimeSegment * segment = (*(mSegmentsMap[session->GetSessionID()]))[segmentColumn];

				// Configure the plugin with the proper calendar code so the helper plugin knows
        // how to rate this segment.  Check if need to set CalendarCode as ENUM, if not
				// then set it as string
				if (mbPluginSupportsEnumCalendarCode && mbEnumCalendarCode)
				{
					try
					{
						long lVal = mEnumConfig->GetID(mCalendarCodeEnumSpace,
																					 mCalendarCodeEnumType,
																					 segment->GetCode().c_str());
						session->SetEnumProperty(mCalendarPropID, lVal);
					}
					catch(_com_error& e)
					{
            session->MarkAsFailed(e.Description(), e.Error());
            bFailure = true;
						//return ReturnComError(e);
					}
				}
				else
				{
					session->SetBSTRProperty(mCalendarPropID, segment->GetCode().c_str());
				}
				
				nSessionsToProcess++;
				
				// If we got here, there were no errors, so we will add this session to the
        // set that will be processed by the helper plugin
				helperPluginSetPtr->AddSession(session->GetSessionID(), session->GetServiceID());
			}
		}

		// CALLING THE HELPER PLUGIN WITH THE SESSION SET
		// If there is at least one session in the set, call the helper plugin
		if (nSessionsToProcess > 0)
		{
      // TODO: include meta info on logger, like iteration number and number of
      //       sessions in set
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,
												 "About to execute external plug-in with sessionset");
			
			MarkEnterRegion("ProcessSessions");
			if (!mPlugIn.ProcessSessions(helperPluginSetPtr))
			{
				MarkExitRegion("ProcessSessions");
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
													 "External plug-in returned an error");

				hr = ClearAndDestroySegmentMap(mSegmentsMap);
				return mPlugIn.GetLastError()->GetCode();
			}

			MarkExitRegion("ProcessSessions");
			
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,
												 "External plug-in executed with no error");

			// Iterate the helperPluginSetPtr, grabbing the rate and accumulating the rate
      // on mRateMap
			hr = it.Init(helperPluginSetPtr);
			if (FAILED(hr))
				return hr;

			MTDecimal rate = 0L;
			MTDecimal percentage = 0L;
			long startTime = 0;
			long endTime = 0;
			long totalDuration = 0;
			
			// Note: here, we are only iterating on the sessions that were added to
      // helperPluginSetPtr.  So this sessionset should become smaller and smaller
      // until all segments are processed
      //BP: Seems like here there is no need to worry about partial session failures.
      //Anything that fails here is probably serious enough to fail entire thing.
			while ((session = it.GetNext()) != NULL) 
			{
				// get the rate back that the plug-in generated for this session
				//rate = session->GetDecimalProperty(mRatePropID);

				//------ CALCULATING DURATION ------//
				// Grab current segment and calculate duration
				// TimeSegmentVector * segments = mSegmentsMap[session->GetSessionID()];
				TimeSegment * segment = (*(mSegmentsMap[session->GetSessionID()]))[segmentColumn];

				// duration of this segment
				duration = segment->GetDuration();
				
				startTime = session->GetDateTimeProperty(mStartTimePropID);
				endTime = session->GetDateTimeProperty(mEndTimePropID);
				totalDuration = endTime - startTime;
				//----------------------------------//
				
				// get the percentage of this time compared to the entire time
				if (totalDuration == 0)
					percentage = 1;
				else
					percentage = MTDecimal(duration) / MTDecimal(totalDuration);
				
				// accumulate the rate on the rate map
				// get the rate back that the plug-in generated
				for(unsigned int j = 0; j < mRatePropID.size(); j++)
				{
					rate = session->GetDecimalProperty(mRatePropID[j]);
				  //accumulate the rate
					//weightedRate[j] += rate * percentage;
					mRateMap[session->GetSessionID()][j] += rate * percentage;
				}

				// If this is the last accumulation for this session, set the accumulated rate
        // back in the session.  Do it for each one of the elements in mRatePropID
				if (segmentColumn == (mSegmentsMap[session->GetSessionID()]->size() - 1))
				{
					for(unsigned int j = 0; j < mRatePropID.size(); j++)
					{
						session->SetDecimalProperty(mRatePropID[j], mRateMap[session->GetSessionID()][j]);

						// Log the resulting weighted rates
						if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
						{
							char buffer[512];
							MTDecimal dgbRate = mRateMap[session->GetSessionID()][j];
							sprintf(buffer, "Resulting Weighted Rate for rate property %d is : %s", mRatePropID[j], dgbRate.Format().c_str());	
							mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
						}
					}
				}
			}
		}

		// Move to the next column of segments
		segmentColumn++;
	}

	hr = ClearAndDestroySegmentMap(mSegmentsMap);
  return (bFailure == true) ? PIPE_ERR_SUBSET_OF_BATCH_FAILED : hr;
}

HRESULT WeightedRatePlugIn::ClearAndDestroySegmentMap(SegmentsMap mSegmentsMap)
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

HRESULT WeightedRatePlugIn::PlugInShutdown()
{
	return S_OK;
}
