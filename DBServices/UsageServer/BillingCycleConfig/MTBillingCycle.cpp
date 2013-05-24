/**************************************************************************
* Copyright 1997-2000 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Travis Gebhardt
* $Header$
* 
***************************************************************************/


// CLASS OVERVIEW
// ==============
//
// The MTBillingCycle object represents a billing cycle choice
// for the purposes of the CSR. It is a collection of MTTimePoints
// representing different allowable start/end dates (depending on
// the cycle type). A CycleType property is also included. The
// cycle type can be used to determine exactly what the time points
// mean to the specific billing cycle.


#include <StdAfx.h>
#include <metra.h>
#include "BillingCycleConfig.h"
#include "MTBillingCycleConfig.h"
#include "MTBillingCycle.h"
#include "MTTimePoint.h"
#include "MTUtil.h"
#include <MTDate.h>


// ----------------------------------------------------------------
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  AUTO GENERATED
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycle::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTBillingCycle


	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


// ----------------------------------------------------------------
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  COM INTERNAL USE ONLY
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycle::get__NewEnum(LPUNKNOWN *pVal)
{
	HRESULT hr = S_OK;

	typedef CComObject<CComEnum<IEnumVARIANT, &IID_IEnumVARIANT, 
		VARIANT, _Copy<VARIANT> > > enumvar;

	enumvar* pEnumVar = new enumvar;
  ASSERT(pEnumVar);
	int size = mCollection.size();

	// Note: end pointer has to be one past the end of the list
	if (size == 0)
	{
		hr = pEnumVar->Init(NULL,
							NULL, 
							NULL, 
							AtlFlagCopy);
	}
	else
	{
		hr = pEnumVar->Init(&mCollection[0], 
							&mCollection[size - 1] + 1, 
							NULL, 
							AtlFlagCopy);
	}

	if (SUCCEEDED(hr))
		hr = pEnumVar->QueryInterface(IID_IEnumVARIANT, (void**)pVal);

	if (FAILED(hr))
		delete pEnumVar;

	return hr;
}


// ----------------------------------------------------------------
// Name:     			get_Count
// Arguments:     
// Return Value:  long* val - collection size
// Raised Errors:
// Description:   Returns the amount of time points in the collection
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycle::get_Count(long *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = (long)mCollection.size();

	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			get_Item
// Arguments:     long aIndex			-		index
// Return Value:  VARIANT* pVal		-		MTTimePoint
// Raised Errors:
// Description:   returns an MTTimePoint object at a specified index
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycle::get_Item(long aIndex, VARIANT *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	pVal->vt = VT_UNKNOWN;
	pVal->punkVal = NULL;

	//is the index within limits?
	if ((aIndex < 1) || (TimePointColl::size_type(aIndex) > mCollection.size()))
		return E_INVALIDARG;

	::VariantClear(pVal);
	::VariantCopy(pVal, &mCollection.at(aIndex - 1));

	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			Add
// Arguments:     IMTTimePoint *apTimePoint 
// Return Value:  
// Raised Errors:
// Description:		Adds a MTTimePoint object to the collection
//
//                *** FOR INTERNAL USE ONLY ***
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycle::Add(IMTTimePoint *apTimePoint)
{
	HRESULT hr = S_OK;
	LPDISPATCH lpDisp = NULL;

	
	hr = apTimePoint->QueryInterface(IID_IDispatch, (void**)&lpDisp);
	
	if (FAILED(hr))
	{
		return hr;
	}
	
	// create a variant
	CComVariant var;
	var.vt = VT_DISPATCH;
	var.pdispVal = lpDisp;
	
	mCollection.push_back(var);
	return hr;
}


// ----------------------------------------------------------------
// Name:     			get_CycleType
// Arguments:     
// Return Value:  BSTR* pVal		-		the name of the cycle type
// Raised Errors:
// Description:   returns the name of the cycle type
//                (i.e., "Monthly", "Quarterly"). If this property
//                wasn't set it will return an empty string.
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycle::get_CycleType(BSTR *pVal)
{
	*pVal = mCycleType.copy();
	return S_OK;	
}

// ----------------------------------------------------------------
// Name:     			set_CycleType
// Arguments:     BSTR newVal		-		the name of the cycle type
// Return Value:  
// Raised Errors:
// Description:   sets the name of the cycle type
//                (i.e., "Monthly", "Quarterly")
//
//                *** FOR INTERNAL USE ONLY ***
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycle::put_CycleType(BSTR newVal)
{
	mCycleType = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			CalculateClosestInterval
// Arguments:     IMTTimePoint *apTimePoint - a TimePoint object 
//                VARIANT  apToday          - a DATE variant representing today
// Return Value:  VARIANT* apStartDate      - a DATE variant representing
//                                            the start of the closest interval
//                VARIANT* apStartDate      - a DATE variant representing
//                                            the end of the closest interval
// Raised Errors:
// Description:		Based on the TimePoint, the date passed in, and the
//                BillingCycle's CycleType, calculates the start date and 
//                end date of the closest interval.
// ----------------------------------------------------------------
STDMETHODIMP CMTBillingCycle::CalculateClosestInterval(IMTTimePoint* apTimePoint,
																											 VARIANT  apToday,
																											 VARIANT* apStartDate,
																											 VARIANT* apEndDate)
{
	MTDate today, startDate, endDate;
	
	//gets the date out of the variant
	if ((apToday.vt == (VT_VARIANT | VT_BYREF)) &&  //handles VBScript variables
			((apToday.pvarVal)->vt == VT_DATE))
		today.SetDate((apToday.pvarVal)->date);
	else if (apToday.vt == (VT_DATE | VT_BYREF))    //handles VB variables
		today.SetDate(*apToday.pdate);
	else if (apToday.vt == VT_DATE)                 //handles VBScript and VB expressions
		today.SetDate(apToday.date);
	else
		return E_INVALIDARG;
	
	
	//calculates the biweekly interval dates
	//(this code was taken from MTStdBiWeekly.cpp and should stay in synch with it)
	bstr_t cycleType =_strlwr(_strdup(mCycleType));
	if (cycleType == _bstr_t(BILLCONFIG_CYCLE_BIWEEKLY)) {
		long month, day, year;
		apTimePoint->get_MonthIndex(&month);
		apTimePoint->get_Day(&day);
		apTimePoint->get_Year(&year);

		MTDate reference(month, day, year);
		time_t referenceTime = reference.GetSecondsSinceEpoch();
		time_t todayTime     = today.GetSecondsSinceEpoch();
		time_t diff          = todayTime - referenceTime;
		long   intervals     = (long) (diff / (MTDate::SECONDS_IN_DAY * 14));
		time_t startTime     = referenceTime + (intervals * (MTDate::SECONDS_IN_DAY * 14));

		startDate.SetDate(startTime);
		
		//if the date is invalid (perhaps bad input from the xml file?)
		if (!startDate.IsValid())
			return E_FAIL;
		
		endDate = startDate + 13;
		
		//converts the results into ole dates
		apStartDate->vt = VT_DATE;
		apEndDate->vt   = VT_DATE;
		startDate.GetOLEDate(&apStartDate->date);
		endDate.GetOLEDate(&apEndDate->date);

	} else
		return Error("This method can only be called for bi-weekly cycles");
	
	return S_OK;
}


