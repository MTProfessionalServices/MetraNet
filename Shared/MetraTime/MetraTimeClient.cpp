// MetraTimeClient.cpp : Implementation of CMetraTimeClient
#include "StdAfx.h"
#include "MetraTime.h"
#include "MetraTimeClient.h"

#include <MTUtil.h>
#include <mttime.h>

/////////////////////////////////////////////////////////////////////////////
// CMetraTimeClient

STDMETHODIMP CMetraTimeClient::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMetraTimeClient
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMetraTimeClient::FinalConstruct()
{
	if (!mIPC.Init())
		return E_FAIL;

	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}

void CMetraTimeClient::FinalRelease()
{
	mIPC.Reset();

	m_pUnkMarshaler.Release();
}


STDMETHODIMP CMetraTimeClient::GetMTTime(long *currentTime)
{
	long offset = mIPC.GetReadOnlyData().GetOffset();
	time_t now = time(NULL);
  // COM 32BIT TIME_T
	*currentTime = (long) (now + offset);
	return S_OK;
}

STDMETHODIMP CMetraTimeClient::GetMTOLETime(VARIANT *currentTime)
{
	// TODO: is this the most efficient way to do it?
	DATE oleTime;
	long mttime;
	this->GetMTTime(&mttime);
	OleDateFromTimet(&oleTime, mttime);
	_variant_t val(oleTime, VT_DATE);
	*currentTime = val.Detach();

	return S_OK;
}

STDMETHODIMP CMetraTimeClient::GetMTTimeWithMilliSecAsString(BSTR *currentTimeStr)
{
  long offset = mIPC.GetReadOnlyData().GetOffset();

  FILETIME currentFileTime;
	GetSystemTimeAsFileTime(&currentFileTime);

	ULARGE_INTEGER largeTime;
	largeTime.LowPart = currentFileTime.dwLowDateTime;
	largeTime.HighPart = currentFileTime.dwHighDateTime;

	ULARGE_INTEGER adjustedLargeTime;
	adjustedLargeTime.QuadPart = largeTime.QuadPart +
		(ULONGLONG) offset * (ULONGLONG) (1000 * 1000 * 10);

	currentFileTime.dwLowDateTime = adjustedLargeTime.LowPart;
	currentFileTime.dwHighDateTime = adjustedLargeTime.HighPart;

	SYSTEMTIME currentSystemTime;
	BOOL result = FileTimeToSystemTime(&currentFileTime, &currentSystemTime);
	ASSERT(result);

	wchar_t buffer[255];
	wsprintf(buffer, L"%d-%02d-%02d %02d:%02d:%02d.%03d",
					 currentSystemTime.wYear,
					 currentSystemTime.wMonth,
					 currentSystemTime.wDay,
					 currentSystemTime.wHour,
					 currentSystemTime.wMinute,
					 currentSystemTime.wSecond,
					 currentSystemTime.wMilliseconds);


  _bstr_t strTime = (_bstr_t(buffer));
  *currentTimeStr = strTime.copy();

  return S_OK;
}
STDMETHODIMP CMetraTimeClient::get_IsTimeAdjusted(VARIANT_BOOL *pVal)
{
	long offset = mIPC.GetReadOnlyData().GetOffset();
	*pVal = (offset != 0) ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP CMetraTimeClient::get_MaxDate(long *pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_POINTER;
  // COM 32BIT TIME_T
  *pVal = (long) getMaxDate();
	return S_OK;
}

STDMETHODIMP CMetraTimeClient::get_MaxMTOLETime(DATE *pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_POINTER;
  *pVal = GetMaxMTOLETime();
	return S_OK;
}

STDMETHODIMP CMetraTimeClient::get_MinDate(long *pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_POINTER;
  // COM 32BIT TIME_T
  *pVal = (long) getMinDate();
	return S_OK;
}

STDMETHODIMP CMetraTimeClient::get_MinMTOLETime(DATE *pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_POINTER;
  *pVal = getMinMTOLETime();
	return S_OK;
}
