// MTRange.cpp : Implementation of CMTRange
#include "StdAfx.h"
#include "MTCalendar.h"
#include "MTRange.h"

/////////////////////////////////////////////////////////////////////////////
// CMTRange

STDMETHODIMP CMTRange::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRange,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTRange::get_Code(BSTR * pVal)
{
    *pVal = mCode.copy();
	return S_OK;
}

STDMETHODIMP CMTRange::put_Code(BSTR newVal)
{
    mCode = newVal;
	return S_OK;
}

STDMETHODIMP CMTRange::get_StartTime(BSTR * pVal)
{
    *pVal = mStartTime.copy();
	return S_OK;
}

STDMETHODIMP CMTRange::put_StartTime(BSTR newVal)
{
    mStartTime = newVal;
	return S_OK;
}

STDMETHODIMP CMTRange::get_EndTime(BSTR * pVal)
{
    *pVal = mEndTime.copy();
	return S_OK;
}

STDMETHODIMP CMTRange::put_EndTime(BSTR newVal)
{
    mEndTime = newVal;
	return S_OK;
}

STDMETHODIMP CMTRange::Add(BSTR code, BSTR starttime, BSTR endtime)
{
    mCode = code;
    mStartTime = starttime;
    mEndTime = endtime;

	return S_OK;
}

STDMETHODIMP CMTRange::WriteSet(::IMTConfigPropSet * apPropSet)
{
    HRESULT hr = S_OK;
	const char* procName = "CMTRange::WriteSet";

    if (apPropSet == NULL)
	  return E_POINTER;

	MTConfigLib::IMTConfigPropSetPtr aHours(apPropSet);

	MTConfigLib::IMTConfigPropSetPtr hoursSet = aHours->InsertSet(HOURSSET_TAG);
	if (hoursSet == NULL)
	{
	    //TODO: change it to ERROR_INVALID_WEEKDAY
	    hr = ERROR_INVALID_PARAMETER;
		SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (hr);
	}

	_variant_t varStartTime;
	std::string strStartTime(mStartTime);
    varStartTime = MTConvertTime(strStartTime);
	hoursSet->InsertProp(STARTTIME_TAG, MTConfigLib::PROP_TYPE_TIME, varStartTime.lVal);

	_variant_t varEndTime;
	std::string strEndTime(mEndTime);
	varEndTime = MTConvertTime(strEndTime);
	hoursSet->InsertProp(ENDTIME_TAG, MTConfigLib::PROP_TYPE_TIME, varEndTime.lVal);

	_variant_t var;
	var = mCode;
	hoursSet->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, var);

	return S_OK;
}
