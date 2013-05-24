/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"
#include "MTHierarchyReports.h"
#include "MPSRenderInfo.h"

#include <mtcomerr.h>

/////////////////////////////////////////////////////////////////////////////
// CMPSRenderInfo

STDMETHODIMP CMPSRenderInfo::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMPSRenderInfo,
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


STDMETHODIMP CMPSRenderInfo::get_IntervalID(int *pVal)
{
	if(!pVal) 
		return E_POINTER;
	else
		*pVal = mIntervalID;

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::put_IntervalID(int newVal)
{
	mIntervalID = newVal;
	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::get_LanguageCode(int *pVal)
{
	if(!pVal) 
		return E_POINTER;
	else
		*pVal = mLanguageCode;

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::put_LanguageCode(int newVal)
{
	mLanguageCode = newVal;
	return S_OK;
}


STDMETHODIMP CMPSRenderInfo::get_ViewType(MPS_VIEW_TYPE *pVal)
{
	*pVal = static_cast<MPS_VIEW_TYPE>(msViewType);

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::put_ViewType(MPS_VIEW_TYPE newVal)
{
	msViewType = newVal;

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::get_UseInterval(VARIANT_BOOL *pVal)
{
	*pVal = mbUseInterval;

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::put_UseInterval(VARIANT_BOOL newVal)
{
	mbUseInterval = newVal;

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::get_StartDate(BSTR *pVal)
{
	*pVal = mstrStartDate.copy();

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::put_StartDate(BSTR newVal)
{
	mstrStartDate = newVal;

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::get_EndDate(BSTR *pVal)
{
	*pVal = mstrEndDate.copy();

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::put_EndDate(BSTR newVal)
{
  mstrEndDate = newVal;

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::get_TimeSlice(ITimeSlice **pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try 
	{
    MTHIERARCHYREPORTSLib::ITimeSlicePtr ptr = mTimeSlice;

    *pVal = reinterpret_cast<ITimeSlice*> (ptr.Detach());
		
	} 
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::putref_TimeSlice(ITimeSlice *newVal)
{
	try
	{
		mTimeSlice = newVal;
	}
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::get_AccountID(long *pVal)
{
	*pVal = mlngAccountID;

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::put_AccountID(long newVal)
{
	mlngAccountID = newVal;

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::get_Estimate(VARIANT_BOOL *pVal)
{
	*pVal = mbEstimate;

	return S_OK;
}

STDMETHODIMP CMPSRenderInfo::put_Estimate(VARIANT_BOOL newVal)
{
	mbEstimate = newVal;

	return S_OK;
}
