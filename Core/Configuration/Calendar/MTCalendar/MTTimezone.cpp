// MTTimezone.cpp : Implementation of CMTTimezone
#include "StdAfx.h"
#include "MTCalendar.h"
#include "MTTimezone.h"


/////////////////////////////////////////////////////////////////////////////
// CMTTimezone

STDMETHODIMP CMTTimezone::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTTimezone
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTTimezone::get_TimezoneOffset(double *pVal)
{
    *pVal = mTimezoneOffset;
	return S_OK;
}

STDMETHODIMP CMTTimezone::put_TimezoneOffset(double newVal)
{
    mTimezoneOffset = newVal;
	return S_OK;
}

STDMETHODIMP CMTTimezone::get_TimezoneID(long *pVal)
{
    *pVal = mTimezoneID;
	return S_OK;
}

STDMETHODIMP CMTTimezone::put_TimezoneID(long newVal)
{
    mTimezoneID = newVal;
	return S_OK;
}
