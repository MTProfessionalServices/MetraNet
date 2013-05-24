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
#include "MPSReportInfo.h"

/////////////////////////////////////////////////////////////////////////////
// CMPSReportInfo

STDMETHODIMP CMPSReportInfo::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMPSReportInfo,
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMPSReportInfo::get_Name(BSTR *pVal)
{
	// TODO: Add your implementation code here
  

  *pVal = mstrName.copy();

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_Name(BSTR newVal)
{

  mstrName = newVal;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_Description(BSTR *pVal)
{
  *pVal = mstrDescription.copy();

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_Description(BSTR newVal)
{
  mstrDescription = newVal;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_Type(MPS_REPORT_TYPE *pVal)
{
  *pVal = static_cast<MPS_REPORT_TYPE>(msType);
  
	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_Type(MPS_REPORT_TYPE newVal)
{
	msType = newVal;
	
  return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_ViewType(MPS_VIEW_TYPE *pVal)
{
  *pVal = static_cast<MPS_VIEW_TYPE>(msViewType);

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_ViewType(MPS_VIEW_TYPE newVal)
{
	msViewType = newVal;

	return S_OK;
}


STDMETHODIMP CMPSReportInfo::get_RestrictionBillable(MPS_RESTRICTION *pVal)
{
  *pVal = static_cast<MPS_RESTRICTION>(msRestrictionBillable);

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_RestrictionBillable(MPS_RESTRICTION newVal)
{
	msRestrictionBillable = newVal;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_RestrictionFolderAccount(MPS_RESTRICTION *pVal)
{
	*pVal = static_cast<MPS_RESTRICTION>(msRestrictionFolderAccount);

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_RestrictionFolderAccount(MPS_RESTRICTION newVal)
{
  msRestrictionFolderAccount = newVal;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_RestrictionOwnedFolders(MPS_RESTRICTION *pVal)
{
  *pVal = static_cast<MPS_RESTRICTION>(msRestrictionOwnedFolders);

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_RestrictionOwnedFolders(MPS_RESTRICTION newVal)
{
	msRestrictionOwnedFolders = newVal;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_RestrictionBillableOwnedFolders(VARIANT_BOOL *pVal)
{
	*pVal = static_cast<MPS_RESTRICTION>(msRestrictionOwnedBillableFolders);

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_RestrictionBillableOwnedFolders(VARIANT_BOOL newVal)
{
	msRestrictionOwnedBillableFolders = newVal;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_RestrictionIndependentAccount(VARIANT_BOOL *pVal)
{
	*pVal = static_cast<MPS_RESTRICTION>(msRestrictionIndependentAccount);

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_RestrictionIndependentAccount(VARIANT_BOOL newVal)
{
	msRestrictionIndependentAccount = newVal;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_Restricted(VARIANT_BOOL *pVal)
{
	*pVal = mbRestricted;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_Restricted(VARIANT_BOOL newVal)
{
	mbRestricted = newVal;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_DisplayMethod(MPS_DISPLAY_METHOD *pVal)
{
	*pVal = static_cast<MPS_DISPLAY_METHOD>(msDisplayMethod);

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_DisplayMethod(MPS_DISPLAY_METHOD newVal)
{
	msDisplayMethod = newVal;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_DisplayData(BSTR *pVal)
{
	*pVal = mstrDisplayData.copy();

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_DisplayData(BSTR newVal)
{
	mstrDisplayData = newVal;

	return S_OK;
}


STDMETHODIMP CMPSReportInfo::get_Index(long *pVal)
{
	*pVal = mlngIndex;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_Index(long newVal)
{
	mlngIndex = newVal;

	return S_OK;
}


STDMETHODIMP CMPSReportInfo::get_AccountIDOverride(long *pVal)
{
	*pVal = mlngAccountIDOverride;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_AccountIDOverride(long newVal)
{
	mlngAccountIDOverride = newVal;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_InlineVATTaxes(VARIANT_BOOL *pVal)
{
  *pVal = mbInlineVATTaxes;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_InlineVATTaxes(VARIANT_BOOL newVal)
{
  mbInlineVATTaxes = newVal;
	return S_OK;
}

STDMETHODIMP CMPSReportInfo::get_InlineAdjustments(VARIANT_BOOL *pVal)
{
  *pVal = mbInlineAdjustments;

	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_InlineAdjustments(VARIANT_BOOL newVal)
{
  mbInlineAdjustments = newVal;
	return S_OK;
}
STDMETHODIMP CMPSReportInfo::get_InteractiveReport(VARIANT_BOOL *pVal)
{
  *pVal = mbInteractiveReport;
	return S_OK;
}

STDMETHODIMP CMPSReportInfo::put_InteractiveReport(VARIANT_BOOL newVal)
{
  mbInteractiveReport = newVal;
	return S_OK;
}