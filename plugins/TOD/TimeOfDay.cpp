// TimeOfDay.cpp : Implementation of CTimeOfDay
#include "StdAfx.h"
#include <metralite.h>
#include "TOD.h"
#include "TimeOfDay.h"

// time functions for doing time of day conversion
#include <time.h>

using namespace MTPipelineLib;

#include <SetIterate.h>

/////////////////////////////////////////////////////////////////////////////
// CTimeOfDay

STDMETHODIMP CTimeOfDay::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ITimeOfDay,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


STDMETHODIMP CTimeOfDay::Configure(IUnknown * systemContext,
																		::IMTConfigPropSet * propSetInterface)
{
	// do any initialization necessary here.
	// this method can be called any number of times during the
	// lifetime of the plugin.

	// the plug in's configuration is in the IMTConfigPropSet object

	// the system context object can be used to retrieve interface
	// pointers to the name ID lookup object and logging object.
	try
	{
		// store a pointer to the logger object
		mLogger = systemContext;

		IMTConfigPropSetPtr propset(propSetInterface);
		// figure out which property we're going to take as an input
		_bstr_t datetime = propset->NextStringWithName("datetime");
		// retrieve the property we're going to set as an output
		_bstr_t timeofday = propset->NextStringWithName("timeofday");


		// an example of logging
		if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
		{
			TCHAR buffer[1024];
			wsprintf(buffer,
							 _T("Time of day using %s as date time and setting %s as time of day"),
				(const TCHAR *) datetime, (const TCHAR *) timeofday);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
		}

		// look up the property IDs of the two props we need
		IMTNameIDPtr idlookup(systemContext);
		mDateTimeID = idlookup->GetNameID(datetime);
		mTimeOfDayID = idlookup->GetNameID(timeofday);
	}
	catch (_com_error err)
	{
		return err.Error();
	}

	return S_OK;
}

STDMETHODIMP CTimeOfDay::Shutdown()
{
	// this plug in doesn't have any clean up to do.
	// normally this method would be used to free resources
	// allocated in initialize
	return S_OK;
}

//#include <stdio.h>
STDMETHODIMP CTimeOfDay::ProcessSessions(/* [in] */ ::IMTSessionSet * sessionset)
{
	try
	{
		SetIterator<::IMTSessionSet *, IMTSessionPtr> it;
		HRESULT hr = it.Init(sessionset);
		if (FAILED(hr))
			return hr;

		while (TRUE)
		{
			IMTSessionPtr session = it.GetNext();
			if (session == NULL)
				break;

			//
			// read the date/time and convert to time of day
			// (seconds since midnight)
			//

			time_t datetime = session->GetDateTimeProperty(mDateTimeID);

			struct tm * timeStruct = gmtime(&datetime);
			int timeOfDay = timeStruct->tm_sec
				+ (timeStruct->tm_min * 60)
				+ (timeStruct->tm_hour * 60 * 60);

			// set the time of day property specified in the
			// plug-in's configuration
			session->SetTimeProperty(mTimeOfDayID, timeOfDay);

			// an example of logging.  usually there would be
			// more useful information to log.
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,
												 "Time of Day plug-in: computed time of day");
		}
	}
	// catch all errors and return the appropriate HRESULT
	catch (_com_error err)
	{
		return err.Error();
	}

	// successfully processed
	return S_OK;
}

        
STDMETHODIMP CTimeOfDay::get_ProcessorInfo(/* [out] */ long * info)
{
	// this method is currently undefined.
	return E_NOTIMPL;
}
