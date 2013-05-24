// MTCalendarDate.cpp : Implementation of CMTCalendarDate
#include "StdAfx.h"
#include "MTCalendar.h"
#include "MTCalendarDate.h"

#import <MTConfigLib.tlb>
using namespace MTConfigLib;

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarDate

STDMETHODIMP CMTCalendarDate::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCalendarDate,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTCalendarDate::get_Date(DATE * pVal)
{
    *pVal = mDate;
  //*pVal = mDate.copy();
	return S_OK;
}

STDMETHODIMP CMTCalendarDate::put_Date(DATE newVal)
{
    mDate = newVal;
	return S_OK;
}

STDMETHODIMP CMTCalendarDate::get_Notes(BSTR * pVal)
{
    *pVal = mNotes.copy();
	return S_OK;
}

STDMETHODIMP CMTCalendarDate::put_Notes(BSTR newVal)
{
	mNotes = newVal;
	return S_OK;
}


STDMETHODIMP CMTCalendarDate::Add(DATE aDate, BSTR aNotes)
{
	mDate = aDate;
	mNotes = aNotes;
	return S_OK;
}

STDMETHODIMP CMTCalendarDate::get_RangeCollection(IMTRangeCollection** pVal)
{
    if (pVal == NULL)
	  return E_POINTER;

	mpRangeCollection->QueryInterface(IID_IMTRangeCollection, (void**) pVal);
	return S_OK;
}

STDMETHODIMP CMTCalendarDate::put_RangeCollection(IMTRangeCollection* pRangeCollection)
{
    ASSERT (pRangeCollection);
	if (!pRangeCollection)
	  return E_POINTER;
	
	mpRangeCollection = pRangeCollection;

	return S_OK;
}

STDMETHODIMP CMTCalendarDate::WriteDateSet(::IMTConfigPropSet* apPropSet)
{
    HRESULT hr = S_OK;
	const char* procName = "CMTCalendarDate::WriteDateSet";

	if (apPropSet == NULL)
	    return E_POINTER;

	IMTConfigPropSetPtr aDate(apPropSet);

	IMTConfigPropSetPtr dateSet = aDate->InsertSet(DATE_TAG);
	if (dateSet == NULL)
	{
	    //TODO: change it to ERROR_INVALID_WEEKDAY
	    hr = ERROR_INVALID_PARAMETER;
		SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (hr);
	}
			
	_variant_t var;
	time_t tTime;
	TimetFromOleDate(&tTime, mDate);
	dateSet->InsertProp(DATE_TAG, MTConfigLib::PROP_TYPE_DATETIME, tTime);

	var = mNotes;
	dateSet->InsertProp(NOTES_TAG, MTConfigLib::PROP_TYPE_STRING, var);
	
	return S_OK;
}


STDMETHODIMP CMTCalendarDate::WriteSet(::IMTConfigPropSet* apPropSet)
{
    HRESULT hr = S_OK;
	const char* procName = "CMTCalendarDate::WriteSet";

	if (apPropSet == NULL)
	    return E_POINTER;

    // create the daytype set
    IMTConfigPropSetPtr aCode(apPropSet);

	BSTR bVar;
	mpRangeCollection->get_Code(&bVar);
	aCode->InsertProp(CODE_TAG, MTConfigLib::PROP_TYPE_STRING, bVar);

	long count = mpRangeCollection->GetCount();
	if (count > 0)
	{
	    MTCALENDARLib::IMTConfigPropSet* pRangeCollectionPropSet;
		apPropSet->QueryInterface(IID_IMTConfigPropSet, (void**)&pRangeCollectionPropSet);

		hr = mpRangeCollection->WriteSet(pRangeCollectionPropSet);
		if (FAILED (hr))
		{
		    //TODO: change it to ERROR_INVALID_WEEKDAY
	    	hr = ERROR_INVALID_PARAMETER;
			SetError (hr, ERROR_MODULE, ERROR_LINE, procName);
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return (hr);
		}
	}

	return S_OK;
}
