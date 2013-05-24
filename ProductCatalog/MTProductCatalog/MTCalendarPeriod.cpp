// MTCalendarPeriod.cpp : Implementation of CMTCalendarPeriod
#include "StdAfx.h"
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#pragma warning(disable: 4297)  // disable warning "function assumed not to throw an exception but does"

#include "MTProductCatalog.h"
#include "MTCalendarPeriod.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarPeriod

HRESULT CMTCalendarPeriod::FinalConstruct()
{
	try
	{
		LoadPropertiesMetaData(PCENTITY_TYPE_CALENDARPERIOD);

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
}

STDMETHODIMP CMTCalendarPeriod::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCalendarPeriod,
    &IID_IMTPCBase
	};
	
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTCalendarPeriod::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal);
}

STDMETHODIMP CMTCalendarPeriod::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTCalendarPeriod::get_Code(long *pVal)
{
	HRESULT hr = S_OK;
	long lVal;
	_bstr_t enumvalue;

	hr = GetPropertyValue("Code", &lVal);
	if (FAILED(hr))
		return hr;

	MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
	
	try
		{
			enumvalue = enumConfig->GetEnumeratorValueByID(lVal);
		}
	catch (_com_error & err)
		{
			MT_THROW_COM_ERROR(IID_IMTCalendarPeriod, MTPC_CANNOT_FIND_ENUM_FOR_CALENDARCODE, lVal);
			return LogAndReturnComError(PCCache::GetLogger(), err);	
		}

	*pVal = atol((const char*) enumvalue);

	return hr;
}

STDMETHODIMP CMTCalendarPeriod::put_Code(long newVal)
{
	long lVal = -1;
	try
		{
			MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
			lVal = enumConfig->GetID(L"metratech.com/calendar", L"CalendarCode", _bstr_t(newVal));
		}
	catch (_com_error & err)
		{
			MT_THROW_COM_ERROR(IID_IMTCalendarPeriod, MTPC_CANNOT_FIND_ENUM_FOR_CALENDARCODE, newVal);
			return LogAndReturnComError(PCCache::GetLogger(), err);	
		}
		
	return PutPropertyValue("Code", lVal);
}

STDMETHODIMP CMTCalendarPeriod::get_StartTime(long *pVal)
{
	return GetPropertyValue("StartTime", pVal);
}

STDMETHODIMP CMTCalendarPeriod::put_StartTime(long newVal)
{
	if (newVal > 24*60*60)
		{
			MT_THROW_COM_ERROR(IID_IMTCalendarPeriod, MTPCUSER_PERIOD_TIME_MORETHAN_24H);
		}
	else if (newVal < 0)
		{
			MT_THROW_COM_ERROR(IID_IMTCalendarPeriod, MTPCUSER_PERIOD_NEGATIVE_TIME);
		}

	return PutPropertyValue("StartTime", newVal);
}

STDMETHODIMP CMTCalendarPeriod::get_EndTime(long *pVal)
{
	return GetPropertyValue("EndTime", pVal);
}

STDMETHODIMP CMTCalendarPeriod::put_EndTime(long newVal)
{
	if (newVal > 24*60*60)
		{
			MT_THROW_COM_ERROR(IID_IMTCalendarPeriod, MTPCUSER_PERIOD_TIME_MORETHAN_24H);
		}
	else if (newVal < 0)
		{
			MT_THROW_COM_ERROR(IID_IMTCalendarPeriod, MTPCUSER_PERIOD_NEGATIVE_TIME);
		}
		
	return PutPropertyValue("EndTime", newVal);
}

STDMETHODIMP CMTCalendarPeriod::GetCodeAsString(BSTR* pVal)
{
	long icode, lVal;
	HRESULT hr = S_OK;
	hr = get_Code(&icode);
	if (FAILED(hr))
		return hr;

	try
		{
			MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
			lVal = enumConfig->GetID(L"metratech.com/calendar", L"CalendarCode", _bstr_t(icode));
			_bstr_t calcode = enumConfig->GetEnumeratorByID(lVal);
			*pVal = calcode.copy();
		}
	catch (_com_error & err)
		{
			return LogAndReturnComError(PCCache::GetLogger(), err);	
		}

	return hr;
}

STDMETHODIMP CMTCalendarPeriod::get_StartTimeAsString(BSTR *pVal)
{
	HRESULT hr = S_OK;
	long seconds;
	string strtime;

	hr = GetPropertyValue("StartTime", &seconds);
	if (FAILED(hr))
		return hr;

	MTFormatTime(seconds, strtime);
	
	_bstr_t returntime = strtime.c_str();

	*pVal = returntime;
	return hr;
}

STDMETHODIMP CMTCalendarPeriod::put_StartTimeAsString(BSTR newVal)
{
	long minutes = 0;
	try
		{
			_bstr_t bstrtime = newVal;
			string strtime = (const char*) bstrtime;
			minutes = MTConvertTime(strtime);
			if (minutes == -1)
				MT_THROW_COM_ERROR(IID_IMTCalendarPeriod, MTPCUSER_PERIOD_CANNOT_CONVERT_STRING_TO_SECONDS);
		}
	catch (_com_error & err)
		{
			return LogAndReturnComError(PCCache::GetLogger(),err);
		}

	// Now that we have a long value, put it in the property
	return PutPropertyValue("StartTime", minutes);
}


STDMETHODIMP CMTCalendarPeriod::get_EndTimeAsString(BSTR *pVal)
{
	HRESULT hr = S_OK;
	long seconds;
	string strtime;

	hr = GetPropertyValue("EndTime", &seconds);
	if (FAILED(hr))
		return hr;

	MTFormatTime(seconds, strtime);
	
	_bstr_t returntime = strtime.c_str();

	*pVal = returntime;
	return hr;
}

STDMETHODIMP CMTCalendarPeriod::put_EndTimeAsString(BSTR newVal)
{
	long minutes = 0;
	try
		{
			_bstr_t bstrtime = newVal;
			string endtime = (const char*) bstrtime;
			minutes = MTConvertTime(endtime);
			if (minutes == -1)
				MT_THROW_COM_ERROR(IID_IMTCalendarPeriod, MTPCUSER_PERIOD_CANNOT_CONVERT_STRING_TO_SECONDS);
		}
	catch (_com_error & err)
		{
			return LogAndReturnComError(PCCache::GetLogger(),err);
		}

	// Now that we have a long value, put it in the property
	return PutPropertyValue("EndTime", minutes);
}

STDMETHODIMP CMTCalendarPeriod::Compare(IUnknown* pUnk, VARIANT_BOOL *apGreaterThan)
{
	MTPRODUCTCATALOGLib::IMTCalendarPeriodPtr periodPtr = pUnk;
	MTPRODUCTCATALOGLib::IMTCalendarPeriodPtr thisPtr = this;

	if (thisPtr->StartTime <= periodPtr->StartTime) 
		*apGreaterThan = VARIANT_TRUE;
	else
		*apGreaterThan = VARIANT_FALSE;
	return S_OK;
}