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
#include <string>

#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF")
#import <MTEnumConfigLib.tlb>

// generate using uuidgen
CLSID CLSID_CalendarCodeLookupPlugIn =
{ /* 8838b898-3350-43c3-8ea6-5186aad73f55 */
	  0x8838b898,
    0x3350,
    0x43c3,
    {0x8e, 0xa6, 0x51, 0x86, 0xaa, 0xd7, 0x3f, 0x55}
};

#include <ConfiguredCal.h>

#include <processor.h>

#include <ConfigDir.h>

#include <ConfiguredCalCache.h>

class ATL_NO_VTABLE CalendarCodeLookupPlugIn
	: public MTPipelinePlugIn<CalendarCodeLookupPlugIn, &CLSID_CalendarCodeLookupPlugIn>
{
public:
	CalendarCodeLookupPlugIn();

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

private:
	//ConfiguredCalendar mCalendar;
  //Calendar* mpCalendar;
	
	long mCalendarPropID;
	long mCalendarIDPropID;
	long mCalendarTimePropID;
	long mOffsetPropID;
	long mZoneIDPropID;
	

	bool mbEnumCalendarCode;
	bool mbPluginSupportsEnumCalendarCode;
	_bstr_t mCalendarCodeEnumSpace;
	_bstr_t mCalendarCodeEnumType;

	_bstr_t mCalendarFileName;
	_bstr_t mCalendarDir;

  ConfiguredCalendarCache mCalendarCache;

	//long mCalendarID;	
	MTPipelineLib::IMTLogPtr mLogger;

	MTPRODUCTCATALOGLib::IMTProductCatalogPtr mProdCat;

	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
};


PLUGIN_INFO(CLSID_CalendarCodeLookupPlugIn, CalendarCodeLookupPlugIn,
						"MetraPipeline.CalendarCodeLookup.1", "MetraPipeline.CalendarCodeLookup", "Free")


#include <mtprogids.h>
#include <pipelineconfig.h>
#include <propids.h>

CalendarCodeLookupPlugIn::CalendarCodeLookupPlugIn()
{
}

HRESULT
CalendarCodeLookupPlugIn::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
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

	_bstr_t calendarTimePropName = aPropSet->NextStringWithName("lookup_time_prop_name");
	_bstr_t offsetPropName = aPropSet->NextStringWithName("offset_prop_name");
	_bstr_t timezoneIDPropName = aPropSet->NextStringWithName("timezoneid_prop_name");
	
	mCalendarFileName = aPropSet->NextStringWithName("calendar");
	_bstr_t mCalendarIDPropName	= aPropSet->NextStringWithName("calendar_id_prop_name");

	// get the property IDs
	mCalendarPropID = aNameID->GetNameID(calendarCodePropName);
	mCalendarIDPropID = aNameID->GetNameID(mCalendarIDPropName);
	mOffsetPropID = aNameID->GetNameID(offsetPropName);
	mZoneIDPropID = aNameID->GetNameID(timezoneIDPropName);
	mCalendarTimePropID = aNameID->GetNameID(calendarTimePropName);
	

	// initialize the config loader
  std::string configDir;
	if (!GetMTConfigDir(configDir))
		return E_FAIL;							// if this didn't work we wouldn't have been called

	mEnumConfig = aSysContext->GetEnumConfig();

	mLogger = aLogger;

  // construct path to global calendar files directory
	_bstr_t aStageDir = aSysContext->GetStageDirectory();
	mCalendarDir = aStageDir;

	return mProdCat.CreateInstance(__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
}

HRESULT CalendarCodeLookupPlugIn::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{

  //This is a pointer to the calendar we will use to process this session
  Calendar* pCalendar;

  // Check to see if we have the appropriate calendar in the cache or if we need to load it from the
  // database or from the file and then add it to the cache
	if (aSession->PropertyExists(mCalendarIDPropID, MTPipelineLib::SESS_PROP_TYPE_LONG)) 
	{
    // Calendar ID is specified in the session so we will load it from the database/product catalog
		long calendarID = aSession->GetLongProperty(mCalendarIDPropID);

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
    // If we do not have a calendar id, then we assume it is the calendar specified by the plugin config file
    // and we will explicitly use/store it in the cache as id 0.
    pCalendar = mCalendarCache.Find(0);
    
    if (!pCalendar)
    {

      ConfiguredCalendar * pTemp = new ConfiguredCalendar;
      if (!pTemp->Setup(mCalendarDir,mCalendarFileName))
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
		sprintf(buffer, "Calendar Not Configured");
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
		return Error(buffer);
	}


	// split into periods based on start/end time
	long CalendarTime = aSession->GetDateTimeProperty(mCalendarTimePropID);

	// We will retrieve the zone id from the enum id that was set in the session
	long zone_enumid = aSession->GetLongProperty(mZoneIDPropID);
	long zoneid = _wtol(mEnumConfig->GetEnumeratorValueByID(zone_enumid));

	// TODO: zone determination temporary!
	//const char * tz = Calendar::TranslateZone(zoneid);
  std::string timezone = Calendar::TranslateZone(zoneid);

	if (timezone.length() == 0)
	{
		char buffer[100];
		sprintf(buffer, "Unsupported zone ID: %d", zoneid);
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
		return Error(buffer);
	}

	if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG) == VARIANT_TRUE)
	{
		if (pCalendar->GetUsesFixedOffset())
		{
			_bstr_t logString = "Using fixed timezone offset of ";
			char buffer[40];
			sprintf(buffer, "%s", pCalendar->GetFixedOffset().c_str());
			logString += buffer;
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, (char*)logString);
		}
		else
		{
      char buf[512];
      sprintf(buf, "Using floating timezone of '%s'", timezone.c_str());
			//_bstr_t logString = "Using floating timezone of ";
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
		}
	}

	TimeSegmentVector segments;
	//there always be one segment based on which session property is used
	//to look up calendar code. CalendarTime is used for both start and end time
	if (!pCalendar->SplitTimeSpan(CalendarTime, CalendarTime, timezone.c_str(), segments))
	{
		TimeSegmentVector::iterator it;
		for (it = segments.begin(); it != segments.end(); it++)
			delete *it;
		segments.clear();

		return Error("Unable to split time span");
	}

	if (1 != (int)segments.size())
	{
		//will never get here
		TimeSegmentVector::iterator it;
		for (it = segments.begin(); it != segments.end(); it++)
			delete *it;
		segments.clear();

		return Error("Number of segments != 1, although used same timestamp for start and end time");
	}

	TimeSegment * segment = segments[0];

	
	// set calendar code appropriately

	//check if need to set CalendarCode as ENUM, if not
	//then set it as string
	char buf[1024];

	if(mbPluginSupportsEnumCalendarCode && mbEnumCalendarCode)
	{
		try {
			long lVal = mEnumConfig->GetID(	mCalendarCodeEnumSpace,
																			mCalendarCodeEnumType,
																			segment->GetCode().c_str());
			aSession->SetEnumProperty(mCalendarPropID, lVal);
			sprintf(buf, "Looked up CalendarCode: <%s>, setting it as ENUM property", segment->GetCode().c_str());
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
		}
		catch(_com_error& e) {
			TimeSegmentVector::iterator it;
			for (it = segments.begin(); it != segments.end(); it++)
				delete *it;
			segments.clear();

			return ReturnComError(e);
		}
	}
	else
	{
		sprintf(buf, "Looked up CalendarCode: <%s>, setting it as STRING property", segment->GetCode().c_str());
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
		aSession->SetBSTRProperty(mCalendarPropID, buf);
	}

	TimeSegmentVector::iterator it;
	for (it = segments.begin(); it != segments.end(); it++)
		delete *it;
	segments.clear();

	return S_OK;
}


HRESULT CalendarCodeLookupPlugIn::PlugInShutdown()
{
	return S_OK;
}
