// MTUserCalendar.cpp : Implementation of CMTUserCalendar
#include "StdAfx.h"
#include <comdef.h>

#pragma warning(disable: 4297)  // disable warning "function assumed not to throw an exception but does"

#include "MTCalendar.h"
#include "MTUserCalendar.h"
#include "MTRange.h"
#include "MTCalendarDate.h"
#include "MTTimezone.h"
#include <mtglobal_msg.h>

#include <CalendarLib.h>

#import <MTCalendar.tlb>
#include <mtzoneinfo.h>
#include <ConfigDir.h>

#include <mtcomerr.h>

/////////////////////////////////////////////////////////////////////////////
// CMTUserCalendar

STDMETHODIMP CMTUserCalendar::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTUserCalendar,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get__NewEnum(LPUNKNOWN * pVal)
{
    HRESULT hr = S_OK;

	typedef CComObject<CComEnum<IEnumVARIANT, 
	  &IID_IEnumVARIANT, VARIANT, _Copy<VARIANT> > > enumvar;

	enumvar* pEnumVar = new enumvar;
	ASSERT (pEnumVar);

	// Note: end pointer has to be one past the end of the list
	if (mSize == 0)
	{
		hr = pEnumVar->Init(NULL,
							NULL, 
							NULL, 
							AtlFlagCopy);
	}
	else
	{
	    hr = pEnumVar->Init(&mDateList[0], 
							&mDateList[mSize - 1] + 1, 
							NULL, 
							AtlFlagCopy);
	}

	if (SUCCEEDED(hr))
		hr = pEnumVar->QueryInterface(IID_IEnumVARIANT, reinterpret_cast<void**>(pVal));

	if (FAILED(hr))
		delete pEnumVar;

	return hr;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get_Monday(IMTRangeCollection * * pVal)
{
    if (pVal == NULL)
	  return E_POINTER;
	
	if (mpMonday != NULL)
	  mpMonday->QueryInterface(IID_IMTRangeCollection, reinterpret_cast<void**>(pVal));
	else
	{
	  *pVal = NULL;
	  return S_FALSE;
	}

	return S_OK;
}

STDMETHODIMP CMTUserCalendar::put_Monday(IMTRangeCollection *pRangeCollection)
{
	mpMonday = pRangeCollection;
	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get_Tuesday(IMTRangeCollection * * pVal)
{
    if (pVal == NULL)
	  return E_POINTER;
	
	if (mpTuesday != NULL)
	  mpTuesday->QueryInterface(IID_IMTRangeCollection, reinterpret_cast<void**>(pVal));
	else
	{
	  *pVal = NULL;
	  return S_FALSE;
	}

	return S_OK;
}

STDMETHODIMP CMTUserCalendar::put_Tuesday(IMTRangeCollection * pRangeCollection)
{
	mpTuesday = pRangeCollection;
	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get_Wednesday(IMTRangeCollection * * pVal)
{
    if (pVal == NULL)
	  return E_POINTER;
	
	if (mpWednesday != NULL)
	  mpWednesday->QueryInterface(IID_IMTRangeCollection, reinterpret_cast<void**>(pVal));
	else
	{
	  *pVal = NULL;
	  return S_FALSE;
	}

	return S_OK;
}

STDMETHODIMP CMTUserCalendar::put_Wednesday(IMTRangeCollection * pRangeCollection)
{
	mpWednesday = pRangeCollection;
	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get_Thursday(IMTRangeCollection * * pVal)
{
    if (pVal == NULL)
	  return E_POINTER;
	
	if (mpThursday != NULL)
	  mpThursday->QueryInterface(IID_IMTRangeCollection, reinterpret_cast<void**>(pVal));
	else
	{
	  *pVal = NULL;
	  return S_FALSE;
	}

	return S_OK;
}

STDMETHODIMP CMTUserCalendar::put_Thursday(IMTRangeCollection * pRangeCollection)
{
	mpThursday = pRangeCollection;
	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get_Friday(IMTRangeCollection * * pVal)
{
    if (pVal == NULL)
	  return E_POINTER;
	
	if (mpFriday != NULL)
	  mpFriday->QueryInterface(IID_IMTRangeCollection, reinterpret_cast<void**>(pVal));
	else
	{
	  *pVal = NULL;
	  return S_FALSE;
	}

	return S_OK;
}

STDMETHODIMP CMTUserCalendar::put_Friday(IMTRangeCollection * pRangeCollection)
{
	mpFriday = pRangeCollection;
	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get_Saturday(IMTRangeCollection * * pVal)
{
    if (pVal == NULL)
	  return E_POINTER;
	
	if (mpSaturday != NULL)
	  mpSaturday->QueryInterface(IID_IMTRangeCollection, reinterpret_cast<void**>(pVal));
	else
	{
	  *pVal = NULL;
	  return S_FALSE;
	}

	return S_OK;
}

STDMETHODIMP CMTUserCalendar::put_Saturday(IMTRangeCollection * pRangeCollection)
{
	mpSaturday = pRangeCollection;
	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get_Sunday(IMTRangeCollection * * pVal)
{
    if (pVal == NULL)
	  return E_POINTER;
	
	if (mpSunday != NULL)
	  mpSunday->QueryInterface(IID_IMTRangeCollection, reinterpret_cast<void**>(pVal));
	else
	{
	  *pVal = NULL;
	  return S_FALSE;
	}

	return S_OK;
}

STDMETHODIMP CMTUserCalendar::put_Sunday(IMTRangeCollection * pRangeCollection)
{
	mpSunday = pRangeCollection;
	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get_DefaultWeekend(IMTRangeCollection * * pVal)
{
    if (pVal == NULL)
	  return E_POINTER;
	
	if (mpDefaultWeekend != NULL)
	  mpDefaultWeekend->QueryInterface(IID_IMTRangeCollection, reinterpret_cast<void**>(pVal));
	else
	{
	  *pVal = NULL;
	  return S_FALSE;
	}

	return S_OK;
}

STDMETHODIMP CMTUserCalendar::put_DefaultWeekend(IMTRangeCollection * pRangeCollection)
{
	mpDefaultWeekend = pRangeCollection;
	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get_DefaultWeekday(IMTRangeCollection * * pVal)
{
    if (pVal == NULL)
	  return E_POINTER;
	
	if (mpDefaultWeekday != NULL)
	  mpDefaultWeekday->QueryInterface(IID_IMTRangeCollection, reinterpret_cast<void**>(pVal));
	else
	{
	  *pVal = NULL;
	  return S_FALSE;
	}

	return S_OK;
}

STDMETHODIMP CMTUserCalendar::put_DefaultWeekday(IMTRangeCollection * pRangeCollection)
{
	mpDefaultWeekday = pRangeCollection;
	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::Initialize(BSTR aHostName)
{
	mHostName = aHostName;
	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get_Count(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mSize;

	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::get_Item(long aIndex, VARIANT * pVal)
{
    ASSERT(pVal);
	if (!pVal)
		return E_POINTER;

	VariantInit(pVal);
	pVal->vt = VT_UNKNOWN;
	pVal->punkVal = NULL;

	if ((aIndex < 1) || (aIndex > mSize))
		return E_INVALIDARG;

	VariantCopy(pVal, &mDateList[aIndex-1]);

	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::Add(IMTCalendarDate* pDate)
{
    HRESULT hr = S_OK;
	LPDISPATCH lpDisp = NULL;

	hr = pDate->QueryInterface(IID_IDispatch, (void**)&lpDisp);
	if (FAILED(hr))
	{
		return hr;
	}
	
	// create a variant
	CComVariant var;
	var.vt = VT_DISPATCH;
	var.pdispVal = lpDisp;

	// append data
	mDateList.push_back(var);
	mSize++;

	return S_OK;
}

// -----------------------------------------------------------------------
STDMETHODIMP CMTUserCalendar::Remove(DATE aDate)
{
	// output data here 
    HRESULT hr = S_OK;
	IMTCalendarDate* pIMTCalendarDate;

	// set each of the date objects
	for (unsigned long index = 0; index < mDateList.size(); index++)
	{
		LPDISPATCH lpDisp = NULL;
			
   		lpDisp = NULL;
		lpDisp = mDateList[index].pdispVal;
		hr = lpDisp->QueryInterface(IID_IMTCalendarDate, (void**)&pIMTCalendarDate);

		if (FAILED(hr))
		  return FALSE;
		ASSERT (pIMTCalendarDate);

		DATE date;
		pIMTCalendarDate->get_Date(&date);
		
		if (date == aDate)
		{
		  mDateList.erase(mDateList.begin() + index);
			--index;
		  mSize--;
		}

		int ref = lpDisp->Release();
	}

	return S_OK;
}


// -----------------------------------------------------------------------
// call this if you have called initialize
// because initialize will set up the hostname
STDMETHODIMP CMTUserCalendar::Read(BSTR aRelativePath, BSTR aFileName)
{
    HRESULT hr(S_OK);

	_bstr_t bstrRelativePath;
	_bstr_t bstrFileName;
	_bstr_t bstrFullPath;

	const char* procName = "MTUserCalendar::Read";

	try
	{
	    ASSERT(aFileName != bstr_t(""));
		mFileName = aFileName;

		// initialize the _com_ptr_t
		CONFIGLOADERLib::IMTConfigLoaderPtr configLoader(MTPROGID_CONFIGLOADER);

		// initialize the configloader
		configLoader->InitWithPath(aRelativePath);

		// create the full path
		bstrFileName = aFileName;

		// open the config file
		CONFIGLOADERLib::IMTConfigPropSetPtr aPropSet = 
		  configLoader->GetEffectiveFile("", bstrFileName);
		
		// check for null propset
		if (aPropSet == NULL)
    	{
		    hr = CORE_ERR_NO_PROP_SET; 
			SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, procName,
					 "No propset read");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			mLogger.LogVarArgs (LOG_ERROR, 
								L"Configuration file <%s> not read.", mFileName);
			return Error ("No propset read from host.", IID_IMTUserCalendar, hr);
		}

		// since this is going to be read with configuration information
		// (effective date) information in it, parse through the
		// <mtconfigdata> tag
		CONFIGLOADERLib::IMTConfigPropSetPtr mtconfigSet = 
		                             aPropSet->NextSetWithName(CALENDAR_TAG);

		if (mtconfigSet == NULL)
		{
		    mLogger.LogThis(LOG_ERROR, "Missing Config Data tag");
			return (FALSE);
		}

		// all set.. process the file now
		if(!ProcessModuleFile(mtconfigSet))
		{
		    hr = E_FAIL; 
			SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, procName,
					 "Failure processing the calendar XML file");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			mLogger.LogVarArgs (LOG_ERROR, 
								L"Configuration file <%s>.", mFileName);
			return Error ("No propset read.", IID_IMTUserCalendar, hr);
		}
	}
	catch (_com_error err)
	{
		return ReturnComError(err);
	}


	return hr;
}

// -----------------------------------------------------------------------
// call this if you have not called initialize
// because host name will not be set in this case 
STDMETHODIMP CMTUserCalendar::ReadFromHost(BSTR aHostName, 
										   BSTR aRelativePath,
										   BSTR aFileName)
{
    HRESULT hr(S_OK);
	_bstr_t bstrRelativePath;
	_bstr_t bstrFileName;
	_bstr_t bstrFullPath;
	VARIANT_BOOL secure = VARIANT_FALSE;
	const char* procName = "MTUserCalendar::ReadFromHost";

	try
	{
	    ASSERT(aFileName != bstr_t(""));
	    ASSERT(aHostName != bstr_t(""));
		mFileName = aFileName;
		mHostName = aHostName;

		VARIANT_BOOL checksumMatch;
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

		// create the config directory....
		bstrRelativePath = aRelativePath;
		bstrFileName = aFileName;
		bstrFullPath = bstrRelativePath + "\\" + bstrFileName;

		MTConfigLib::IMTConfigPropSetPtr aPropSet = 
		  config->ReadConfigurationFromHost(mHostName, bstrFullPath, secure, &checksumMatch);

		// read the site configuration information out of the prop set ...
		if (aPropSet == NULL)
    	{
		    hr = CORE_ERR_NO_PROP_SET; 
			SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, procName,
					 "No propset read");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			mLogger.LogVarArgs (LOG_ERROR, 
								L"Configuration file <%s> not read from host <%s>.", 
								bstrFullPath, aHostName);
			return Error ("No propset read from host.", IID_IMTUserCalendar, hr);
		}

		// since this is going to be read with configuration information
		// (effective date) information in it, parse through the
		// <mtconfigdata> tag
		MTConfigLib::IMTConfigPropSetPtr mtconfigSet = 
		  aPropSet->NextSetWithName(MTCONFIGDATA_TAG);

		if (mtconfigSet == NULL)
		{
		    mLogger.LogThis(LOG_ERROR, "Missing Config Data tag");
			return (FALSE);
		}

		MTConfigLib::IMTConfigPropSetPtr calendarSet = 
		  mtconfigSet->NextSetWithName(CALENDAR_TAG);

		if (calendarSet == NULL)
		{
		    mLogger.LogThis(LOG_ERROR, "Missing Calendar tag");
			return (FALSE);
		}

		// all set... process the file now
		if(!ProcessModuleFile(calendarSet)) 
		{
		    hr = E_FAIL; 
			SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, procName,
					 "Failure processing the calendar XML file");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			mLogger.LogVarArgs (LOG_ERROR, 
								L"Configuration file <%s> not read from host <%s>.", 
								bstrFullPath, aHostName);
			return Error ("No propset read from host.", IID_IMTUserCalendar, hr);
		}
	}
	catch (_com_error err)
	{
	    SetError(err.Error(), ERROR_MODULE, ERROR_LINE, procName,
				 "Caught error while reading calendar information.");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		mLogger.LogVarArgs (LOG_ERROR, 
							L"Caught error during the reading of calendar file <%s> on host <%s>.", 
							bstrFullPath, mHostName);
		throw err;
	}

	return hr;
}

// -----------------------------------------------------------------------
// call this if you have called initialize
// because initialize will set up the hostname
STDMETHODIMP CMTUserCalendar::Write(BSTR aRelativePath, BSTR aFileName)
{
    HRESULT hr(S_OK);
	_bstr_t bstrRelativePath;
	_bstr_t bstrFileName;
	_bstr_t bstrFullPath;
	std::string strConfigDir;
	const char* procName = "MTUserCalendar::Write";
	
	// create the config directory....
	bstrRelativePath = aRelativePath;
	bstrFileName = aFileName;
	bstrFullPath = bstrRelativePath + "\\" + bstrFileName;

	try 
	{
	    ASSERT(!!aFileName && (aFileName != bstr_t("")));
		if (!aFileName || aFileName ==  bstr_t("")) 
		  throw _com_error(E_FAIL);

    	// step 1: verify that the directory specified in the file name path exists
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    
		MTConfigLib::IMTConfigPropSetPtr propSet = 
		  config->NewConfiguration(XMLCONFIG_TAG);

	   	MTConfigLib::IMTConfigPropSetPtr mtconfigdata(propSet);
		MTConfigLib::IMTConfigPropSetPtr mtconfigdataSet 
		  = propSet->InsertSet(MTCONFIGDATA_TAG);

		if (mtconfigdataSet == NULL)
		{
		   	//TODO: change it to ERROR_INVALID_WEEKDAY
	    	hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}

	   	MTConfigLib::IMTConfigPropSetPtr calendar(propSet);
		MTConfigLib::IMTConfigPropSetPtr calendarSet 
		  = mtconfigdataSet->InsertSet(CALENDAR_TAG);

		if (calendarSet == NULL)
		{
		   	//TODO: change it to ERROR_INVALID_WEEKDAY
	    	hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}

		if(!WriteModuleFile(calendarSet)) 
		{
		    hr = E_FAIL; 
			SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, procName,
					 "Failure writing the calendar XML file");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			mLogger.LogVarArgs (LOG_ERROR, 
								L"Configuration file <%s> not written.", bstrRelativePath);
			return Error ("No propset written.", IID_IMTUserCalendar, hr);
		}
		else 
		{
		    propSet->Write(bstrFullPath);
		}
	}
	catch (_com_error err)
	{
	    hr = HRESULT_FROM_WIN32(err.Error());
		SetError(err.Error(), ERROR_MODULE, ERROR_LINE, procName,
				 "Caught error while writing configuration information.");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		mLogger.LogVarArgs (LOG_ERROR, 
							L"Caught error during the writing of configuration file <%s> on host <%s>.", 
							bstrRelativePath, mHostName);
	}

	return hr;
}

// -----------------------------------------------------------------------
// call this if you have not called initialize
// because host name will not be set in this case 
STDMETHODIMP CMTUserCalendar::WriteToHost(BSTR aHostName, 
										  BSTR aRelativePath,
										  BSTR aFileName)
{
    HRESULT hr(S_OK);
	_bstr_t bstrRelativePath;
	_bstr_t bstrFileName;
	_bstr_t bstrFullPath;
	VARIANT_BOOL secure = VARIANT_FALSE;
	const char* procName = "MTUserCalendar::WriteToHost";

	try 
	{
	    ASSERT(!!aFileName && (aFileName != bstr_t("")));
	    ASSERT(!!aHostName && (aHostName != bstr_t("")));
		if (!aFileName || aFileName ==  bstr_t("")) 
		  throw _com_error(E_FAIL);
		if (!aHostName || aHostName ==  bstr_t("")) 
		  throw _com_error(E_FAIL);

		mHostName = aHostName;
		bstrRelativePath = aRelativePath;
		bstrFileName = aFileName;
		bstrFullPath = bstrRelativePath + "\\" + bstrFileName;

    	// step 1: verify that the directory specified in the file name path exists
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    
		MTConfigLib::IMTConfigPropSetPtr propSet = 
		  config->NewConfiguration(XMLCONFIG_TAG);

	   	MTConfigLib::IMTConfigPropSetPtr mtconfigdata(propSet);
		MTConfigLib::IMTConfigPropSetPtr mtconfigdataSet 
		  = propSet->InsertSet(MTCONFIGDATA_TAG);

		if (mtconfigdataSet == NULL)
		{
		   	//TODO: change it to ERROR_INVALID_WEEKDAY
	    	hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}

	   	MTConfigLib::IMTConfigPropSetPtr calendar(propSet);
		MTConfigLib::IMTConfigPropSetPtr calendarSet 
		  = mtconfigdataSet->InsertSet(CALENDAR_TAG);

		if (calendarSet == NULL)
		{
		   	//TODO: change it to ERROR_INVALID_WEEKDAY
	    	hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}

		if(!WriteModuleFile(calendarSet)) 
		{
		    hr = E_FAIL; 
			SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, procName,
					 "Failure writing the calendar XML file");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			mLogger.LogVarArgs (LOG_ERROR, 
								L"Configuration file <%s> not written to host <%s>.", 
								bstrFullPath, aHostName);
			return Error ("No propset written to host.", IID_IMTUserCalendar, hr);
		}
		else 
		{
		    propSet->WriteToHost(mHostName, bstrFullPath, L"", L"", secure, VARIANT_TRUE);
		}
	}
	catch (_com_error err)
	{
	    hr = HRESULT_FROM_WIN32(err.Error());
		SetError(err.Error(), ERROR_MODULE, ERROR_LINE, procName,
				 "Caught error while writing configuration information.");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		mLogger.LogVarArgs (LOG_ERROR, 
							L"Caught error during the writing of configuration file <%s> on host <%s>.", 
							bstrFullPath, mHostName);
	}

	return hr;
}

// -----------------------------------------------------------------------
BOOL 
CMTUserCalendar::ProcessModuleFile(CONFIGLOADERLib::IMTConfigPropSetPtr& aPropSet)
{
    _bstr_t starttime;
    _bstr_t endtime;
    _bstr_t timecode;
	HRESULT hr = S_OK;
	DWORD nError = NO_ERROR; 
	const char* procName = "CMTUserCalendar::ProcessModuleFile";

	// ------------------------------------------------------------
	// create the MTTimezone object
	CComObject<CMTTimezone>* pMTTimezone;
	hr = CComObject<CMTTimezone>::CreateInstance(&pMTTimezone);
	ASSERT (SUCCEEDED(hr));

	if (aPropSet == NULL)
	{
	    mLogger.LogThis(LOG_ERROR, "Bad Propset");
		return (FALSE);
	}

	try 
	{
	    // [RVM] -- get the timezone stuff here
		CONFIGLOADERLib::IMTConfigPropSetPtr timezoneSet = 
		                             aPropSet->NextSetWithName("timezone");

		if (timezoneSet == NULL)
		{
		    mLogger.LogThis(LOG_DEBUG, 
							"Missing timezone tag. Defaulting with ID of 0 and timezone of 0.0");
			pMTTimezone->put_TimezoneID(0);
			pMTTimezone->put_TimezoneOffset(0.0);
		}
		else
		{
		    while (timezoneSet != NULL)
			{
			    long timezoneid = timezoneSet->NextLongWithName("timezoneid");
			    double timezoneoffset = timezoneSet->NextDoubleWithName("timezoneoffset");
				
				pMTTimezone->put_TimezoneID(timezoneid);
				pMTTimezone->put_TimezoneOffset(timezoneoffset);

			    // go to the next set
				timezoneSet = aPropSet->NextSetWithName("timezone");
			}
		}
		
		// put the timezone in the user calendar object
		put_Timezone(pMTTimezone);

		// reset the propset
		aPropSet->Reset();

		CONFIGLOADERLib::IMTConfigPropSetPtr dayTypeSet = 
		                             aPropSet->NextSetWithName(DAYTYPE_TAG);

		if (dayTypeSet == NULL)
		{
		    mLogger.LogThis(LOG_ERROR, "Missing Day Type tag");
			return (FALSE);
		}

		while (dayTypeSet != NULL)
		{
		    CONFIGLOADERLib::IMTConfigPropSetPtr dateSet = 
		                             dayTypeSet->NextSetWithName(DATE_TAG);

			if (dateSet == NULL)
			{
			    dayTypeSet->Reset();
			    if (!ProcessReadingRangeCollection(dayTypeSet, TRUE))
						return FALSE;
			}
			else
			{
			    while (dateSet != NULL)
				{
				  dayTypeSet->Reset(); 
				  if (!ProcessReadingHolidays(dayTypeSet))
						return FALSE;
				  dateSet = dayTypeSet->NextSetWithName(DATE_TAG);
				}
			}
			// go to the next set
			dayTypeSet = aPropSet->NextSetWithName(DAYTYPE_TAG);
		}
	}
	catch(_com_error e) 
	{
	    SetError(e.Error(),
				 ERROR_MODULE, 
				 ERROR_LINE, procName, e.Description());
	    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	return (TRUE);
}

// -----------------------------------------------------------------------
BOOL 
CMTUserCalendar::ProcessModuleFile(MTConfigLib::IMTConfigPropSetPtr& aPropSet)
{
    _bstr_t starttime;
    _bstr_t endtime;
    _bstr_t timecode;
	HRESULT hr = S_OK;
	DWORD nError = NO_ERROR; 
	MTCALENDARLib::IMTTimezonePtr p;
	const char* procName = "CMTUserCalendar::ProcessModuleFile";

	// ------------------------------------------------------------
	// create the MTTimezone object
	CComObject<CMTTimezone>* pMTTimezone;
	hr = CComObject<CMTTimezone>::CreateInstance(&pMTTimezone);
	ASSERT (SUCCEEDED(hr));

	if (aPropSet == NULL)
	{
	    mLogger.LogThis(LOG_ERROR, "Bad Propset");
		return (FALSE);
	}

	try 
	{
	    // [RVM] -- get the timezone stuff here
		CONFIGLOADERLib::IMTConfigPropSetPtr timezoneSet = 
		                             aPropSet->NextSetWithName("timezone");

		if (timezoneSet == NULL)
		{
		    mLogger.LogThis(LOG_DEBUG, 
							"Missing timezone tag. Defaulting with ID of 0 and timezone of 0.0");
			pMTTimezone->put_TimezoneID(0);
			pMTTimezone->put_TimezoneOffset(0.0);
		}
		else
		{
		    while (timezoneSet != NULL)
			{
			    long timezoneid = timezoneSet->NextLongWithName("timezoneid");
			    double timezoneoffset = timezoneSet->NextDoubleWithName("timezoneoffset");
				
				pMTTimezone->put_TimezoneID(timezoneid);
				pMTTimezone->put_TimezoneOffset(timezoneoffset);

			    // go to the next set
				timezoneSet = aPropSet->NextSetWithName("timezone");
			}
		}
		
		// put the timezone in the user calendar object
		put_Timezone(pMTTimezone);

		aPropSet->Reset();

		MTConfigLib::IMTConfigPropSetPtr dayTypeSet = 
		                             aPropSet->NextSetWithName(DAYTYPE_TAG);

		if (dayTypeSet == NULL)
		{
		    mLogger.LogThis(LOG_ERROR, "Missing Day Type tag");
			return (FALSE);
		}

		while (dayTypeSet != NULL)
		{
		    MTConfigLib::IMTConfigPropSetPtr dateSet = 
		                             dayTypeSet->NextSetWithName(DATE_TAG);

			if (dateSet == NULL)
			{
			    dayTypeSet->Reset();
			    if (!ProcessReadingRangeCollection(dayTypeSet, TRUE))
						return FALSE;
			}
			else
			{
			    while (dateSet != NULL)
				{
				  dayTypeSet->Reset(); 
				  if (!ProcessReadingHolidays(dayTypeSet)) 
						return FALSE;
				  dateSet = dayTypeSet->NextSetWithName(DATE_TAG);
				}
			}
			// go to the next set
			dayTypeSet = aPropSet->NextSetWithName(DAYTYPE_TAG);
		}
	}
	catch(_com_error e) 
	{
	    SetError(e.Error(),
				 ERROR_MODULE, 
				 ERROR_LINE, procName, e.Description());
	    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	return (TRUE);
}



// -----------------------------------------------------------------------
BOOL 
CMTUserCalendar::ProcessReadingRangeCollection(CONFIGLOADERLib::IMTConfigPropSetPtr& aPropSet,
											   BOOL abParseWeekdayFlag)
{
    _bstr_t starttime;
    _bstr_t endtime;
    _bstr_t timecode;
	char errBuf[255];
	HRESULT hr = S_OK;
	DWORD nError = NO_ERROR; 
	const char* procName = "CMTUserCalendar::ProcessReadingRangeCollection";

	_bstr_t code;

	// ------------------------------------------------------------
	// create the MTRangeCollection object
	CComObject<CMTRangeCollection>* pMTRangeCollection;
	hr = CComObject<CMTRangeCollection>::CreateInstance(&pMTRangeCollection);
	ASSERT (SUCCEEDED(hr));
	
	// put the weekday
	if (abParseWeekdayFlag == TRUE)
	{
		std::wstring weekday;
	    weekday = aPropSet->NextStringWithName(WEEKDAY_TAG);

		if (0 == _wcsicmp,(weekday.c_str(), W_MONDAY_STR))
			put_Monday(pMTRangeCollection);
		else if (0 == _wcsicmp,(weekday.c_str(), W_TUESDAY_STR))
			put_Tuesday(pMTRangeCollection);
		else if (0 == _wcsicmp,(weekday.c_str(), W_WEDNESDAY_STR))
			put_Wednesday(pMTRangeCollection);
		else if (0 == _wcsicmp,(weekday.c_str(), W_THURSDAY_STR))
			put_Thursday(pMTRangeCollection);
		else if (0 == _wcsicmp,(weekday.c_str(), W_FRIDAY_STR))
			put_Friday(pMTRangeCollection);
		else if (0 == _wcsicmp,(weekday.c_str(), W_SATURDAY_STR))
			put_Saturday(pMTRangeCollection);
		else if (0 == _wcsicmp,(weekday.c_str(), W_SUNDAY_STR))
			put_Sunday(pMTRangeCollection);
		else if (0 == _wcsicmp,(weekday.c_str(), W_DEFAULT_WEEKDAY_STR))
			put_DefaultWeekday(pMTRangeCollection);
		else if (0 == _wcsicmp,(weekday.c_str(), W_DEFAULT_WEEKEND_STR))
			put_DefaultWeekend(pMTRangeCollection);
		else
		{
    		mLogger.LogThis(LOG_ERROR, "Unknown weekday");
			return (FALSE);
		}
	}
		
	// put the code
	code = aPropSet->NextStringWithName(CODE_TAG);
	pMTRangeCollection->put_Code(code); 

	
	MTConfigLib::IMTConfigPropSetPtr hoursSet = 
                            	aPropSet->NextSetWithName(HOURSSET_TAG);
	
	if (hoursSet == NULL)
		return TRUE;

	try
	{
		while (hoursSet != NULL)
		{
			std::string starttime;
			std::string endtime;
			_bstr_t bstrstarttime;
			_bstr_t bstrendtime;
			_bstr_t code;
		
			// ------------------------------------------------------------
			// create the MTRangeCollection object
			CComObject<CMTRange>* pMTRange;
			HRESULT hr = CComObject<CMTRange>::CreateInstance(&pMTRange);
			ASSERT (SUCCEEDED(hr));
	
        	// put the starttime
			CONFIGLOADERLib::IMTConfigPropPtr propstarttime = 
			  hoursSet->NextWithName(STARTTIME_TAG);
			CONFIGLOADERLib::PropValType type;
			_variant_t propVal;

			// try to get the value
			propVal = propstarttime->GetValue(&type);
			if (type != MTConfigLib::PROP_TYPE_TIME)
			{
			  sprintf (errBuf, 
					   "Datatype missmatch - expecting MTConfigLib::PROP_TYPE_TIME");
			  SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, procName, errBuf);
			  mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
			  return FALSE;
			}
			MTFormatTime(propVal.lVal, starttime);
			bstrstarttime = starttime.c_str();

        	// put the endtime
			CONFIGLOADERLib::IMTConfigPropPtr propendtime = 
			  hoursSet->NextWithName(ENDTIME_TAG);

			// try to get the value
			propVal = propendtime->GetValue(&type);
			if (type != MTConfigLib::PROP_TYPE_TIME)
			{
			  sprintf (errBuf, 
					   "Datatype missmatch - expecting MTConfigLib::PROP_TYPE_TIME");
			  SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, procName, errBuf);
			  mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
			  return FALSE;
			}
			MTFormatTime(propVal.lVal, endtime);
			bstrendtime = endtime.c_str();

			// put the code
			code = hoursSet->NextStringWithName(CODE_TAG);
	
			pMTRange->put_StartTime(bstrstarttime); 
			pMTRange->put_EndTime(bstrendtime); 
			pMTRange->put_Code(code); 
		
			pMTRangeCollection->Add(pMTRange);
	
			// go to the next set
			hoursSet = aPropSet->NextSetWithName(HOURSSET_TAG);
		}
	}
	catch(_com_error e) 
	{
	    SetError(e.Error(),
				 ERROR_MODULE, 
				 ERROR_LINE, procName, e.Description());
	    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	return (TRUE);
}

// -----------------------------------------------------------------------
BOOL 
CMTUserCalendar::ProcessReadingRangeCollection(MTConfigLib::IMTConfigPropSetPtr& aPropSet,
											   BOOL abParseWeekdayFlag)
{
    _bstr_t starttime;
    _bstr_t endtime;
    _bstr_t timecode;
	char errBuf[255];
	HRESULT hr = S_OK;
	DWORD nError = NO_ERROR; 
	const char* procName = "CMTUserCalendar::ProcessReadingRangeCollection";

	_bstr_t code;

	// ------------------------------------------------------------
	// create the MTRangeCollection object
	CComObject<CMTRangeCollection>* pMTRangeCollection;
	hr = CComObject<CMTRangeCollection>::CreateInstance(&pMTRangeCollection);
	ASSERT (SUCCEEDED(hr));
	
	// put the weekday
	if (abParseWeekdayFlag == TRUE)
	{
		std::wstring weekday;
	    weekday = aPropSet->NextStringWithName(WEEKDAY_TAG);
		
		if (0 ==  _wcsicmp(weekday.c_str(), W_MONDAY_STR))
			put_Monday(pMTRangeCollection);
		else if (0 == _wcsicmp(weekday.c_str(), W_TUESDAY_STR))
			put_Tuesday(pMTRangeCollection);
		else if (0 == _wcsicmp(weekday.c_str(), W_WEDNESDAY_STR))
			put_Wednesday(pMTRangeCollection);
		else if (0 == _wcsicmp(weekday.c_str(), W_THURSDAY_STR))
			put_Thursday(pMTRangeCollection);
		else if (0 == _wcsicmp(weekday.c_str(), W_FRIDAY_STR))
			put_Friday(pMTRangeCollection);
		else if (0 == _wcsicmp(weekday.c_str(), W_SATURDAY_STR))
			put_Saturday(pMTRangeCollection);
		else if (0 == _wcsicmp(weekday.c_str(), W_SUNDAY_STR))
			put_Sunday(pMTRangeCollection);
		else if (0 == _wcsicmp(weekday.c_str(), W_DEFAULT_WEEKDAY_STR))
			put_DefaultWeekday(pMTRangeCollection);
		else if (0 == _wcsicmp(weekday.c_str(), W_DEFAULT_WEEKEND_STR))
			put_DefaultWeekend(pMTRangeCollection);
		else
		{
    		mLogger.LogThis(LOG_ERROR, "Unknown weekday");
			return (FALSE);
		}
	}
		
	// put the code
	code = aPropSet->NextStringWithName(CODE_TAG);
	pMTRangeCollection->put_Code(code); 

	
	MTConfigLib::IMTConfigPropSetPtr hoursSet = 
                            	aPropSet->NextSetWithName(HOURSSET_TAG);
	
	if (hoursSet == NULL)
		return TRUE;

	try
	{
		while (hoursSet != NULL)
		{
			std::string starttime;
			std::string endtime;
			_bstr_t bstrstarttime;
			_bstr_t bstrendtime;
			_bstr_t code;
		
			// ------------------------------------------------------------
			// create the MTRangeCollection object
			CComObject<CMTRange>* pMTRange;
			HRESULT hr = CComObject<CMTRange>::CreateInstance(&pMTRange);
			ASSERT (SUCCEEDED(hr));
	
        	// put the starttime
			MTConfigLib::IMTConfigPropPtr propstarttime = 
			  hoursSet->NextWithName(STARTTIME_TAG);
			MTConfigLib::PropValType type;
			_variant_t propVal;

			// try to get the value
			propVal = propstarttime->GetValue(&type);
			if (type != MTConfigLib::PROP_TYPE_TIME)
			{
			  sprintf (errBuf, 
					   "Datatype missmatch - expecting MTConfigLib::PROP_TYPE_TIME");
			  SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, procName, errBuf);
			  mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
			  return FALSE;
			}
			MTFormatTime(propVal.lVal, starttime);
			bstrstarttime = starttime.c_str();

        	// put the endtime
			MTConfigLib::IMTConfigPropPtr propendtime = 
			  hoursSet->NextWithName(ENDTIME_TAG);

			// try to get the value
			propVal = propendtime->GetValue(&type);
			if (type != MTConfigLib::PROP_TYPE_TIME)
			{
			  sprintf (errBuf, 
					   "Datatype missmatch - expecting MTConfigLib::PROP_TYPE_TIME");
			  SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, procName, errBuf);
			  mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
			  return FALSE;
			}
			MTFormatTime(propVal.lVal, endtime);
			bstrendtime = endtime.c_str();

			// put the code
			code = hoursSet->NextStringWithName(CODE_TAG);
	
			pMTRange->put_StartTime(bstrstarttime); 
			pMTRange->put_EndTime(bstrendtime); 
			pMTRange->put_Code(code); 
		
			pMTRangeCollection->Add(pMTRange);
	
			// go to the next set
			hoursSet = aPropSet->NextSetWithName(HOURSSET_TAG);
		}
	}
	catch(_com_error e) 
	{
	    SetError(e.Error(),
				 ERROR_MODULE, 
				 ERROR_LINE, procName, e.Description());
	    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	return (TRUE);
}

// -----------------------------------------------------------------------
BOOL 
CMTUserCalendar::ProcessReadingHolidays(CONFIGLOADERLib::IMTConfigPropSetPtr& aPropSet)
{
    _bstr_t notes;
	_bstr_t code;
	char errBuf[255];
	HRESULT hr = S_OK;
	DWORD nError = NO_ERROR; 
	const char* procName = "CMTUserCalendar::ProcessModuleFile";

	// ------------------------------------------------------------
	// create the MTCalendarDate object
	CComObject<CMTCalendarDate>* pMTCalendarDate;
	hr = CComObject<CMTCalendarDate>::CreateInstance(&pMTCalendarDate);
	ASSERT (SUCCEEDED(hr));

	// ------------------------------------------------------------
	// create the MTRangeCollection object
	CComObject<CMTRangeCollection>* pMTRangeCollection;
	hr = CComObject<CMTRangeCollection>::CreateInstance(&pMTRangeCollection);
	ASSERT (SUCCEEDED(hr));

	MTConfigLib::IMTConfigPropSetPtr dateSet = aPropSet->NextSetWithName(DATE_TAG);

	if (dateSet == NULL)
	{
		return FALSE;
	}
	
	while (dateSet != NULL)
	{
	    // put the weekday
	    CONFIGLOADERLib::IMTConfigPropPtr prop = dateSet->NextWithName(DATE_TAG);

		CONFIGLOADERLib::PropValType type;
		_variant_t propVal;

		// try to get the value
		propVal = prop->GetValue(&type);
		if (type != MTConfigLib::PROP_TYPE_DATETIME)
		{
		    sprintf (errBuf, 
					 "Datatype missmatch - expecting MTConfigLib::PROP_TYPE_DATETIME");
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, procName, errBuf);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
			return FALSE;
		}

		DATE date;
		time_t tTime = propVal;
		OleDateFromTimet(&date, tTime);
	
		notes = dateSet->NextStringWithName(NOTES_TAG);
	
		pMTCalendarDate->put_Date(date);
		pMTCalendarDate->put_Notes(notes);

		dateSet = aPropSet->NextSetWithName(DATE_TAG);
	}

	// -----------------------------------------------
	// put the code... reset before that
	aPropSet->Reset();
	code = aPropSet->NextStringWithName(CODE_TAG);
	pMTRangeCollection->put_Code(code); 
	
	MTConfigLib::IMTConfigPropSetPtr hoursSet = 
                            	aPropSet->NextSetWithName(HOURSSET_TAG);
	
	if (hoursSet == NULL)
	{
	    // associate the rangecollection with the date object
		pMTCalendarDate->put_RangeCollection(pMTRangeCollection);
	
		// add the date to the list in the user calendar
		Add(pMTCalendarDate);
		return TRUE;
	}

	try
	{
		while (hoursSet != NULL)
		{
			std::string starttime;
			std::string endtime;
			_bstr_t bstrstarttime;
			_bstr_t bstrendtime;
			_bstr_t code;
		
			// ------------------------------------------------------------
			// create the MTRangeCollection object
			CComObject<CMTRange>* pMTRange;
			HRESULT hr = CComObject<CMTRange>::CreateInstance(&pMTRange);
			ASSERT (SUCCEEDED(hr));
	
        	// put the starttime
			CONFIGLOADERLib::IMTConfigPropPtr propstarttime = 
			  hoursSet->NextWithName(STARTTIME_TAG);
			CONFIGLOADERLib::PropValType type;
			_variant_t propVal;

			// try to get the value
			propVal = propstarttime->GetValue(&type);
			if (type != MTConfigLib::PROP_TYPE_TIME)
			{
			  sprintf (errBuf, 
					   "Datatype missmatch - expecting MTConfigLib::PROP_TYPE_TIME");
			  SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, procName, errBuf);
			  mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
			  return FALSE;
			}
			MTFormatTime(propVal.lVal, starttime);
			bstrstarttime = starttime.c_str();

        	// put the endtime
			CONFIGLOADERLib::IMTConfigPropPtr propendtime = 
			  hoursSet->NextWithName(ENDTIME_TAG);

			// try to get the value
			propVal = propendtime->GetValue(&type);
			if (type != MTConfigLib::PROP_TYPE_TIME)
			{
			  sprintf (errBuf, 
					   "Datatype missmatch - expecting MTConfigLib::PROP_TYPE_TIME");
			  SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, procName, errBuf);
			  mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
			  return FALSE;
			}
			MTFormatTime(propVal.lVal, endtime);
			bstrendtime = endtime.c_str();

			// put the code
			code = hoursSet->NextStringWithName(CODE_TAG);
	
			pMTRange->put_StartTime(bstrstarttime); 
			pMTRange->put_EndTime(bstrendtime); 
			pMTRange->put_Code(code); 
		
			// add the range list in the rangecollection 
			pMTRangeCollection->Add(pMTRange);
	
			// go to the next set
			hoursSet = aPropSet->NextSetWithName(HOURSSET_TAG);
		}
	}
	catch(_com_error e) 
	{
	    SetError(e.Error(),
				 ERROR_MODULE, 
				 ERROR_LINE, procName, e.Description());
	    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	// -----------------------------------------------

	// associate the rangecollection with the date object
	pMTCalendarDate->put_RangeCollection(pMTRangeCollection);
	
	// add the date to the list in the user calendar
	Add(pMTCalendarDate);

	return (TRUE);
}

// -----------------------------------------------------------------------
BOOL 
CMTUserCalendar::ProcessReadingHolidays(MTConfigLib::IMTConfigPropSetPtr& aPropSet)
{
    _bstr_t notes;
	_bstr_t code;
	char errBuf[255];
	HRESULT hr = S_OK;
	DWORD nError = NO_ERROR; 
	const char* procName = "CMTUserCalendar::ProcessModuleFile";

	// ------------------------------------------------------------
	// create the MTCalendarDate object
	CComObject<CMTCalendarDate>* pMTCalendarDate;
	hr = CComObject<CMTCalendarDate>::CreateInstance(&pMTCalendarDate);
	ASSERT (SUCCEEDED(hr));

	// ------------------------------------------------------------
	// create the MTRangeCollection object
	CComObject<CMTRangeCollection>* pMTRangeCollection;
	hr = CComObject<CMTRangeCollection>::CreateInstance(&pMTRangeCollection);
	ASSERT (SUCCEEDED(hr));

	// ------------------------------------------------------------
	// create the MTRange object
	CComObject<CMTRange>* pMTRange;
	hr = CComObject<CMTRange>::CreateInstance(&pMTRange);
	ASSERT (SUCCEEDED(hr));


	MTConfigLib::IMTConfigPropSetPtr dateSet = aPropSet->NextSetWithName(DATE_TAG);

	if (dateSet == NULL)
	{
		return FALSE;
	}
	
	while (dateSet != NULL)
	{
	    // put the weekday
	    MTConfigLib::IMTConfigPropPtr prop = dateSet->NextWithName(DATE_TAG);

		MTConfigLib::PropValType type;
		_variant_t propVal;

		// try to get the value
		propVal = prop->GetValue(&type);
		if (type != MTConfigLib::PROP_TYPE_DATETIME)
		{
		    sprintf (errBuf, 
					 "Datatype missmatch - expecting MTConfigLib::PROP_TYPE_DATETIME");
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, procName, errBuf);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
			return FALSE;
		}

		DATE date;
		time_t tTime = propVal;
		OleDateFromTimet(&date, tTime);
	
		notes = dateSet->NextStringWithName(NOTES_TAG);
	
		pMTCalendarDate->put_Date(date);
		pMTCalendarDate->put_Notes(notes);

		dateSet = aPropSet->NextSetWithName(DATE_TAG);
	}

	// -----------------------------------------------
	// put the code... reset before that
	aPropSet->Reset();
	code = aPropSet->NextStringWithName(CODE_TAG);
	pMTRangeCollection->put_Code(code); 
	
	MTConfigLib::IMTConfigPropSetPtr hoursSet = 
                            	aPropSet->NextSetWithName(HOURSSET_TAG);
	
	if (hoursSet == NULL)
	{
	    // associate the rangecollection with the date object
		pMTCalendarDate->put_RangeCollection(pMTRangeCollection);
	
		// add the date to the list in the user calendar
		Add(pMTCalendarDate);
		return TRUE;
	}

	try
	{
		while (hoursSet != NULL)
		{
			std::string starttime;
			std::string endtime;
			_bstr_t bstrstarttime;
			_bstr_t bstrendtime;
			_bstr_t code;
		
			// ------------------------------------------------------------
			// create the MTRangeCollection object
			CComObject<CMTRange>* pMTRange;
			HRESULT hr = CComObject<CMTRange>::CreateInstance(&pMTRange);
			ASSERT (SUCCEEDED(hr));
	
        	// put the starttime
			MTConfigLib::IMTConfigPropPtr propstarttime = 
			  hoursSet->NextWithName(STARTTIME_TAG);
			MTConfigLib::PropValType type;
			_variant_t propVal;

			// try to get the value
			propVal = propstarttime->GetValue(&type);
			if (type != MTConfigLib::PROP_TYPE_TIME)
			{
			  sprintf (errBuf, 
					   "Datatype missmatch - expecting MTConfigLib::PROP_TYPE_TIME");
			  SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, procName, errBuf);
			  mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
			  return FALSE;
			}
			MTFormatTime(propVal.lVal, starttime);
			bstrstarttime = starttime.c_str();

        	// put the endtime
			MTConfigLib::IMTConfigPropPtr propendtime = 
			  hoursSet->NextWithName(ENDTIME_TAG);

			// try to get the value
			propVal = propendtime->GetValue(&type);
			if (type != MTConfigLib::PROP_TYPE_TIME)
			{
			  sprintf (errBuf, 
					   "Datatype missmatch - expecting MTConfigLib::PROP_TYPE_TIME");
			  SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, procName, errBuf);
			  mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
			  return FALSE;
			}
			MTFormatTime(propVal.lVal, endtime);
			bstrendtime = endtime.c_str();

			// put the code
			code = hoursSet->NextStringWithName(CODE_TAG);
	
			pMTRange->put_StartTime(bstrstarttime); 
			pMTRange->put_EndTime(bstrendtime); 
			pMTRange->put_Code(code); 
		
			// add the range list in the rangecollection 
			pMTRangeCollection->Add(pMTRange);
	
			// go to the next set
			hoursSet = aPropSet->NextSetWithName(HOURSSET_TAG);
		}
	}
	catch(_com_error e) 
	{
	    SetError(e.Error(),
				 ERROR_MODULE, 
				 ERROR_LINE, procName, e.Description());
	    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	// -----------------------------------------------

	// associate the rangecollection with the date object
	pMTCalendarDate->put_RangeCollection(pMTRangeCollection);
	
	// add the date to the list in the user calendar
	Add(pMTCalendarDate);

	return (TRUE);
}


// ------------------------------------------------------------------------
BOOL 
CMTUserCalendar::WriteModuleFile(MTConfigLib::IMTConfigPropSetPtr& aPropSet)
{
	// we already have the top level tag, we just need to create the sub tags
    HRESULT hr = S_OK;
	_variant_t var;
	MTCALENDARLib::IMTConfigPropSet* pDatePropSet;
	::IMTConfigPropSet* pDateSetPropSet;
	::IMTConfigPropSet* pCode;
	IMTCalendarDate* pIMTCalendarDate;

    const char* procName = "CMTUserCalendar::WriteModuleFile";


	if (aPropSet == NULL)
	{
	    mLogger.LogThis(LOG_ERROR, "Bad Propset");
		return (FALSE);
	}

   	// create the timezone set
   	MTConfigLib::IMTConfigPropSetPtr aTimezone(aPropSet);
	MTConfigLib::IMTConfigPropSetPtr timezoneSet = aTimezone->InsertSet("timezone");
	if (timezoneSet == NULL)
	{
    	//TODO: change it to ERROR_INVALID_WEEKDAY
   		hr = ERROR_INVALID_PARAMETER;
		SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (hr);
	}

	// now insert the timezoneid
	var = mpTimezone->GetTimezoneID();
    timezoneSet->InsertProp("timezoneid", MTConfigLib::PROP_TYPE_INTEGER, var);

	// now insert the timezoneid
	var = mpTimezone->GetTimezoneOffset();
    timezoneSet->InsertProp("timezoneoffset", MTConfigLib::PROP_TYPE_DOUBLE, var);

	long count;
	get_Count(&count);

    // enumerate through the date list
	if (count != 0)
	{
		// set each of the date objects
		for (int index = 0; index < count; index++)
		{
	    	// create the daytype set
	    	MTConfigLib::IMTConfigPropSetPtr aDayType(aPropSet);
			MTConfigLib::IMTConfigPropSetPtr dayTypeSet = 
			  aDayType->InsertSet(DAYTYPE_TAG);
			if (dayTypeSet == NULL)
			{
		    	//TODO: change it to ERROR_INVALID_WEEKDAY
	    		hr = ERROR_INVALID_PARAMETER;
				SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
				mLogger.LogErrorObject(LOG_ERROR, GetLastError());
				return (hr);
			}
			LPDISPATCH lpDisp = NULL;
			
   			lpDisp = NULL;
			lpDisp = mDateList[index].pdispVal;
			hr = lpDisp->QueryInterface(IID_IMTCalendarDate, (void**)&pIMTCalendarDate);

			if (FAILED(hr))
			  return FALSE;
			ASSERT (pIMTCalendarDate);

			dayTypeSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pDateSetPropSet);
		
			pIMTCalendarDate->WriteDateSet(pDateSetPropSet);
			int ref = lpDisp->Release();

			dayTypeSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pCode);
			pIMTCalendarDate->WriteSet(pCode);
		}
	}

    // insert monday if checked 
    if (mpMonday != NULL)
	{
	    // create the daytype set
	    MTConfigLib::IMTConfigPropSetPtr aDayType(aPropSet);
		MTConfigLib::IMTConfigPropSetPtr dayTypeSet = aDayType->InsertSet(DAYTYPE_TAG);
		if (dayTypeSet == NULL)
		{
		    //TODO: change it to ERROR_INVALID_WEEKDAY
    		hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}
    	dayTypeSet->InsertProp(WEEKDAY_TAG, 
							   MTConfigLib::PROP_TYPE_STRING, 
							   MONDAY_STR);

		// now insert the code
		var = mpMonday->GetCode();
		dayTypeSet->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, var);

		dayTypeSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pDatePropSet);
		mpMonday->WriteSet(pDatePropSet);
	}

	// insert tuesday if checked 
	if (mpTuesday != NULL)
	{
	    // create the daytype set
    	MTConfigLib::IMTConfigPropSetPtr aDayType(aPropSet);
		MTConfigLib::IMTConfigPropSetPtr dayTypeSet = aDayType->InsertSet(DAYTYPE_TAG);
		if (dayTypeSet == NULL)
		{
		    //TODO: change it to ERROR_INVALID_WEEKDAY
    		hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}
		dayTypeSet->InsertProp(WEEKDAY_TAG, 
							   MTConfigLib::PROP_TYPE_STRING, 
							   TUESDAY_STR);

		var = mpTuesday->GetCode();
		dayTypeSet->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, var);

		dayTypeSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pDatePropSet);
		mpTuesday->WriteSet(pDatePropSet);
	}
	
	// insert wednesday if checked 
	if (mpWednesday != NULL)
	{
    	// create the daytype set
    	MTConfigLib::IMTConfigPropSetPtr aDayType(aPropSet);
		MTConfigLib::IMTConfigPropSetPtr dayTypeSet = aDayType->InsertSet(DAYTYPE_TAG);
		if (dayTypeSet == NULL)
		{
	    	//TODO: change it to ERROR_INVALID_WEEKDAY
    		hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}
		dayTypeSet->InsertProp(WEEKDAY_TAG, 
							   MTConfigLib::PROP_TYPE_STRING, 
							   WEDNESDAY_STR);
	
		var = mpWednesday->GetCode();
		dayTypeSet->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, var);

		dayTypeSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pDatePropSet);
		mpWednesday->WriteSet(pDatePropSet);
	}
		
	// insert thursday if checked 
	if (mpThursday != NULL)
	{
    	// create the daytype set
    	MTConfigLib::IMTConfigPropSetPtr aDayType(aPropSet);
		MTConfigLib::IMTConfigPropSetPtr dayTypeSet = aDayType->InsertSet(DAYTYPE_TAG);
		if (dayTypeSet == NULL)
		{
	    	//TODO: change it to ERROR_INVALID_WEEKDAY
    		hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}
		dayTypeSet->InsertProp(WEEKDAY_TAG, 
							   MTConfigLib::PROP_TYPE_STRING, 
							   THURSDAY_STR);
		
		var = mpThursday->GetCode();
		dayTypeSet->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, var);

		dayTypeSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pDatePropSet);
		mpThursday->WriteSet(pDatePropSet);
	}
		
	// insert friday if checked 
	if (mpFriday != NULL)
	{
    	// create the daytype set
    	MTConfigLib::IMTConfigPropSetPtr aDayType(aPropSet);
		MTConfigLib::IMTConfigPropSetPtr dayTypeSet = aDayType->InsertSet(DAYTYPE_TAG);
		if (dayTypeSet == NULL)
		{
	    	//TODO: change it to ERROR_INVALID_WEEKDAY
    		hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}
		dayTypeSet->InsertProp(WEEKDAY_TAG, 
							   MTConfigLib::PROP_TYPE_STRING, 
							   FRIDAY_STR);
		
		var = mpFriday->GetCode();
		dayTypeSet->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, var);

		dayTypeSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pDatePropSet);
		mpFriday->WriteSet(pDatePropSet);
	}
		
	// insert saturday if checked 
	if (mpSaturday != NULL)
	{
    	// create the daytype set
    	MTConfigLib::IMTConfigPropSetPtr aDayType(aPropSet);
		MTConfigLib::IMTConfigPropSetPtr dayTypeSet = aDayType->InsertSet(DAYTYPE_TAG);
		if (dayTypeSet == NULL)
		{
	    	//TODO: change it to ERROR_INVALID_WEEKDAY
    		hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}
		dayTypeSet->InsertProp(WEEKDAY_TAG, 
							   MTConfigLib::PROP_TYPE_STRING, 
							   SATURDAY_STR);
		
		var = mpSaturday->GetCode();
		dayTypeSet->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, var);

		dayTypeSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pDatePropSet);
		mpSaturday->WriteSet(pDatePropSet);
	}
		
	// insert sunday if checked 
	if (mpSunday != NULL)
	{
    	// create the daytype set
    	MTConfigLib::IMTConfigPropSetPtr aDayType(aPropSet);
		MTConfigLib::IMTConfigPropSetPtr dayTypeSet = aDayType->InsertSet(DAYTYPE_TAG);
		if (dayTypeSet == NULL)
		{
	    	//TODO: change it to ERROR_INVALID_WEEKDAY
    		hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}
		dayTypeSet->InsertProp(WEEKDAY_TAG, 
							   MTConfigLib::PROP_TYPE_STRING, 
							   SUNDAY_STR);
	
		var = mpSunday->GetCode();
		dayTypeSet->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, var);

		dayTypeSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pDatePropSet);
		mpSunday->WriteSet(pDatePropSet);
	}

	// insert default if checked 
	if (mpDefaultWeekend != NULL)
	{
    	// create the daytype set
    	MTConfigLib::IMTConfigPropSetPtr aDayType(aPropSet);
		MTConfigLib::IMTConfigPropSetPtr dayTypeSet = aDayType->InsertSet(DAYTYPE_TAG);
		if (dayTypeSet == NULL)
		{
	    	//TODO: change it to ERROR_INVALID_WEEKDAY
    		hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}
		dayTypeSet->InsertProp(WEEKDAY_TAG, 
							   MTConfigLib::PROP_TYPE_STRING, 
							   DEFAULT_WEEKEND_STR);
	
		var = mpDefaultWeekend->GetCode();
		dayTypeSet->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, var);

		dayTypeSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pDatePropSet);
		mpDefaultWeekend->WriteSet(pDatePropSet);
	}


	// insert default if checked 
	if (mpDefaultWeekday != NULL)
	{
    	// create the daytype set
    	MTConfigLib::IMTConfigPropSetPtr aDayType(aPropSet);
		MTConfigLib::IMTConfigPropSetPtr dayTypeSet = aDayType->InsertSet(DAYTYPE_TAG);
		if (dayTypeSet == NULL)
		{
	    	//TODO: change it to ERROR_INVALID_WEEKDAY
    		hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}
		dayTypeSet->InsertProp(WEEKDAY_TAG, 
							   MTConfigLib::PROP_TYPE_STRING, 
							   DEFAULT_WEEKDAY_STR);
	
		var = mpDefaultWeekday->GetCode();
		dayTypeSet->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, var);

		dayTypeSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pDatePropSet);
		mpDefaultWeekday->WriteSet(pDatePropSet);
	}

	return (TRUE);
}


STDMETHODIMP CMTUserCalendar::get_Timezone(IMTTimezone** pVal)
{
    if (pVal == NULL)
	  return E_POINTER;

	mpTimezone->QueryInterface(IID_IMTTimezone, (void**) pVal);
	return S_OK;
}

STDMETHODIMP CMTUserCalendar::put_Timezone(IMTTimezone* pTimezone)
{
    ASSERT (pTimezone);
	if (!pTimezone)
	  return E_POINTER;
	
	mpTimezone = pTimezone;

	return S_OK;
}



STDMETHODIMP CMTUserCalendar::GMTToLocalTime(VARIANT aGMTDatetime, long aMTZoneCode, VARIANT* pLocalDatetime)
{
	std::string tzdir;
	if (!GetMTConfigDir(tzdir))
	{
    mLogger.LogVarArgs (LOG_ERROR, "Unable to get configuration root directory") ;
		return E_FAIL;
	}
	else
	{
		tzdir += "\\timezone\\zoneinfo";
		settzdir(tzdir.c_str());
	}

	_variant_t varDate(aGMTDatetime);
	time_t timeVal;

	timeVal = ParseVariantDate(varDate);
	if (timeVal == -1)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Parse input variant date failed: CMTUserCalendar::GMTToLocalTime()");
		return E_FAIL;
	}

  string tz = Calendar::TranslateZone(aMTZoneCode);
	//const char * tz = Calendar::TranslateZone(aMTZoneCode);
	
	if (tz.length() == 0)
	{
		mLogger.LogVarArgs(LOG_ERROR, 
											"Unsupported timezone ID %d: CMTUserCalendar::GMTToLocalTime()", 
											aMTZoneCode);
		return E_FAIL;
	}
	
	// local time in struct tm format
	struct tm * newTm = tzlocaltime(tz.c_str(), &timeVal);
	ASSERT(newTm);

#if 0
	char* tmStr = asctime(newTm);

	cout << "asctime: " << tmStr << endl;
#endif

	DATE dateTime;
	OleDateFromStructTm(&dateTime, newTm);

	const _variant_t & varResult = dateTime;
	::VariantInit(pLocalDatetime);
	const tagVARIANT * vp = &varResult;
	::VariantCopy(pLocalDatetime, const_cast<tagVARIANT *>(vp));

	return S_OK;
}



STDMETHODIMP CMTUserCalendar::LocalTimeToGMT(VARIANT aLocalDatetime, long aMTZoneCode, VARIANT* pGMTDatetime)
{
	std::string tzdir;
	if (!GetMTConfigDir(tzdir))
	{
    mLogger.LogVarArgs (LOG_ERROR, "Unable to get configuration root directory") ;
		return E_FAIL;
	}
	else
	{
		tzdir += "\\timezone\\zoneinfo";
		settzdir(tzdir.c_str());
	}

	_variant_t varDate(aLocalDatetime);
	time_t timeVal;

	timeVal = ParseVariantDate(varDate);
	if (timeVal == -1)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Parse input variant date failed: CMTUserCalendar::LocalTimeToGMT()");
		return E_FAIL;
	}

	string tz = Calendar::TranslateZone(aMTZoneCode);
	
	if (tz.length() == 0)
	{
		mLogger.LogVarArgs(LOG_ERROR, 
											"Unsupported timezone ID %d: CMTUserCalendar::GMTToLocalTime()", 
											aMTZoneCode);
		return E_FAIL;
	}
	
	// time_t -> struct tm
	struct tm* newTm= gmtime(&timeVal);
	ASSERT(newTm);

#if 0
	char* tmStr = asctime(newTm);

	cout << "asctime: " << tmStr << endl;
#endif

	newTm->tm_isdst = -1;
	time_t converted = tzmktime(tz.c_str(), newTm);

	DATE dateTime;
	OleDateFromTimet(&dateTime, converted);

	const _variant_t & varResult = dateTime;
	::VariantInit(pGMTDatetime);
	const tagVARIANT * vp = &varResult;
	::VariantCopy(pGMTDatetime, const_cast<tagVARIANT *>(vp));

	return S_OK;
}



time_t CMTUserCalendar::ParseVariantDate(VARIANT aDate)
{
	time_t		lDate = 0;
	DATE		varDate;
	_bstr_t	bstrDate;

	switch(aDate.vt)
	{
		case VT_I4:
			lDate = aDate.lVal;
			break;

		case VT_DATE:
			varDate = aDate.date;
			TimetFromOleDate(&lDate, varDate);
			break;

		case (VT_DATE | VT_BYREF):
			varDate = *(aDate.pdate);
			TimetFromOleDate(&lDate, varDate);
			break;

		case VT_BSTR:
			bstrDate = aDate.bstrVal;

			//     YYYY-MM-DDThh:mm:ssTZD
			// ex: 1994-11-05T08:15:30-05:00
			if (MTParseISOTime((char *)bstrDate, &lDate) == FALSE)
			{
				mLogger.LogVarArgs(LOG_ERROR, 
									"Bad input date format(MTParseISOTime) in: DBLocale::ParseVariantDate()");
				return -1;
				
			}
			break;

		case (VT_BSTR | VT_BYREF):
			bstrDate = *(aDate.pbstrVal);

			//     YYYY-MM-DDThh:mm:ssTZD
			// ex: 1994-11-05T08:15:30-05:00
			if (MTParseISOTime((char *)bstrDate, &lDate) == FALSE)
			{
				mLogger.LogVarArgs(LOG_ERROR, 
					"Bad effective date ref format(MTParseISOTime) in: DBLocale::ParseVariantDate()");
				return -1;
			}
			break;

		default:
			mLogger.LogVarArgs(LOG_ERROR, 
				"Unknown input variant date type in: DBLocale::ParseVariantDate()");
			lDate = -1;
	}

	return lDate;
}

