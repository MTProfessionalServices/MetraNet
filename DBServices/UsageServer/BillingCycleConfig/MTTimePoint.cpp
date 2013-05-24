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
// The MTTimePoint object represents the temporal information of a
// billing cycle. Depending on the cycle type of the billing cycle,
// the information contained in this object could be interpeted as
// either a starting point or a closing point. Information such as
// day of week, day, second day and month are stored in this object.


#include "StdAfx.h"
#include "BillingCycleConfig.h"
#include "MTTimePoint.h"

/////////////////////////////////////////////////////////////////////////////
// CMTTimePoint


// ----------------------------------------------------------------
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  AUTO GENERATED
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTTimePoint
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


// ----------------------------------------------------------------
// Name:     			get_Month
// Arguments:     
// Return Value:  BSTR* pVal		-		the name of the month
// Raised Errors:
// Description:   returns the name of the month
//                (i.e., "January", "May"). If this property
//                wasn't set, it will return an empty string.
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::get_Month(BSTR *pVal)
{
	*pVal = mMonth.copy();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			put_Month
// Arguments:     BSTR newVal   -   the name of the month
// Return Value:  
// Raised Errors:
// Description:   sets the name of the month (i.e., "January", "May")
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::put_Month(BSTR newVal)
{
	mMonth = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			get_Day
// Arguments:     
// Return Value:  long* pVal		-		a day (-1 if not set)
// Raised Errors:
// Description:   returns a long representing a day. This can be used
//                as the day of the month. If this property
//                isn't set, it will return the value -1.
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::get_Day(long *pVal)
{
	*pVal = mDay;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			put_MonthIndex
// Arguments:     long newVal		-		the index of the month
// Return Value:  
// Raised Errors:
// Description:   Sets the month's index information. For example,
//                March's index would be 3.
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::put_MonthIndex(long newVal)
{
	mMonthIndex = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			get_MonthIndex
// Arguments:     
// Return Value:  long* pVal		-		the index of the month (-1 if not set)
// Raised Errors:
// Description:   returns a index of the month. This value should be between
//                1-12.
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::get_MonthIndex(long *pVal)
{
	*pVal = mMonthIndex;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			put_Day
// Arguments:     long newVal		-		a day number
// Return Value:  
// Raised Errors:
// Description:   Sets the day property. This can be used as the day
//                of the month or anything else.
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::put_Day(long newVal)
{
	mDay = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			get_SecondDay
// Arguments:     
// Return Value:  long* pVal		-		a day number (-1 if not set)
// Raised Errors:
// Description:   returns a long representing a day. This can be used
//                as a second day of the month (as in Semi-monthly).
//                If this property isn't set, it will return the value -1.
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::get_SecondDay(long *pVal)
{
	*pVal = mSecondDay;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			put_SecondDay
// Arguments:     long newVal		-		a day number
// Return Value:  
// Raised Errors:
// Description:   Sets the second day property. This can be used as a
//                second day of the month or anything else.
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::put_SecondDay(long newVal)
{
	mSecondDay = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			get_NamedDay
// Arguments:     
// Return Value:  BSTR* pVal		-		the name of the day of the week
// Raised Errors:
// Description:   returns the name of the day of the week
//                (i.e., "Monday", "Tuesday"). If this property
//                wasn't set, it will return an empty string.
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::get_NamedDay(BSTR *pVal)
{
	*pVal = mNamedDay.copy();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			put_NamedDay
// Arguments:     BSTR newVal   -   the name of the day of the week
// Return Value:  
// Raised Errors:
// Description:   sets the name of the day of the week
//                (i.e., "Monday", "Tuesday").
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::put_NamedDay(BSTR newVal)
{
	mNamedDay = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			get_Year
// Arguments:     
// Return Value:  long* pVal		-		a 4 digit year (-1 if not set)
// Raised Errors:
// Description:   returns a long representing a year. 
//                If this property isn't set, it will return the value -1.
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::get_Year(long *pVal)
{
	*pVal = mYear;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			put_Year
// Arguments:     long newVal		-		a 4 digit year
// Return Value:  
// Raised Errors:
// Description:   Sets the year property.
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::put_Year(long newVal)
{
	mYear = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			get_Label
// Arguments:     
// Return Value:  BSTR* pVal		-		a convienient label for the cycle
// Raised Errors:
// Description:   returns the label describing of the cycle. This is 
//                used to help CSRs identify Bi-weekly cycles in MAM.
//                The label may contain any string. If this property
//                wasn't set, it will return an empty string.
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::get_Label(BSTR *pVal)
{
	*pVal = mLabel.copy();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			put_Label
// Arguments:     BSTR newVal   -  a convienient label for the cycle
// Return Value:  
// Raised Errors:
// Description:   sets a descriptive label describing the purpose of
//                the cycle. This is used to help CSRs identify
//                Bi-weekly cycles in MAM. The label may contain any
//                string. 
// ----------------------------------------------------------------
STDMETHODIMP CMTTimePoint::put_Label(BSTR newVal)
{
	mLabel = newVal;
	return S_OK;
}


