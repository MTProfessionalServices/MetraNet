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
#include "UsageSummaryQuery.h"

#include <comdef.h>
#include <mtcomerr.h>
#include <mtprogids.h>

#import <MTHierarchyReports.tlb> rename("EOF", "RowsetEOF")
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") 

#include "usedatamart.h"

/////////////////////////////////////////////////////////////////////////////
// CUsageSummaryQuery

STDMETHODIMP CUsageSummaryQuery::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IUsageSummaryQuery
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CUsageSummaryQuery::GenerateQueryString(long aLocaleId,
                                                     ITimeSlice *apTimeSlice,
                                                     IAccountSlice *apAccountSlice,
                                                     IViewSlice *apSessionSlice,
                                                     VARIANT_BOOL bUseDatamart,
                                                     BSTR *pQuery)
{
	if(!apTimeSlice || !apAccountSlice || !pQuery)
		return E_POINTER;
	else
		*pQuery = NULL;

	try
	{
		MTHIERARCHYREPORTSLib::ITimeSlicePtr pTimeSlice(apTimeSlice);
		MTHIERARCHYREPORTSLib::IAccountSlicePtr pAccountSlice(apAccountSlice);
		MTHIERARCHYREPORTSLib::IViewSlicePtr pSessionSlice(apSessionSlice);

		// The account slice might have an additional table (for the ancestor table)
		_bstr_t accountFromClause;
		_bstr_t fromClause;
		if((accountFromClause=pAccountSlice->GenerateFromClause()) != _bstr_t(L""))
		{
			fromClause += accountFromClause;
		}

    WCHAR* pQueryTag = NULL;
    if (UseDataMart())
        pQueryTag = (bUseDatamart == VARIANT_TRUE) ? L"__GET_USAGE_SUMMARY_DATAMART__" : L"__GET_USAGE_SUMMARY__";
    else
        pQueryTag = L"__GET_USAGE_SUMMARY__";

    // Grab the query skeleton and fill it in
		QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
		pQueryAdapter->Init(L"\\Queries\\PresServer");
		pQueryAdapter->SetQueryTag(pQueryTag);
		pQueryAdapter->AddParam(L"%%FROM_CLAUSE%%", fromClause) ;
		pQueryAdapter->AddParam(L"%%TIME_PREDICATE%%", pTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);
		pQueryAdapter->AddParam(L"%%ACCOUNT_PREDICATE%%", pAccountSlice->GenerateQueryPredicate(), VARIANT_TRUE);
		pQueryAdapter->AddParam(L"%%SESSION_PREDICATE%%", pSessionSlice->GenerateQueryPredicate());

    // Here we calculate the DisplayAmount for the charge based on the following
    // DisplayMode matrix:
    // 
    //  --------------------------------------------------------------------------------------------
    //  | Online  | Interactive | Inline      | Inline | Calculated
    //  | Bill    | Report      | Adjustments | Taxes  | Display Amount 
    //  ---------------------------------------------------------------------------------------------
    //  |    X    |             |     X       |   X    | Amount + TotalTax +  PreBillAdjustmentAmount
    //  |         |             |             |        | + PreBillTotalTaxAdjustmentAmount 
    //  ---------------------------------------------------------------------------------------------
    //  |    X    |             |     X       |        | Amount + PreBillAdjustmentAmount
    //  ---------------------------------------------------------------------------------------------
    //  |    X    |             |             |   X    | Amount + TotalTax
    //  ---------------------------------------------------------------------------------------------
    //  |    X    |             |             |        | Amount
    //  ---------------------------------------------------------------------------------------------
    //  |         |     X       |     X       |   X    | Amount + TotalTax + PostBillAdjustmentAmount
    //  |         |             |             |        | + PostBillTotalTaxAdjustmentAmount 
    //  |         |             |             |        | + PreBillAdjustmentAmount 
    //  |         |             |             |        | + PreBillTotalTaxAdjustmentAmount
    //  ---------------------------------------------------------------------------------------------
    //  |         |     X       |     X       |        | Amount + PostBillAdjustmentAmount 
    //  |         |             |             |        | + PreBillAdjustmentAmount 
    //  ---------------------------------------------------------------------------------------------
    //  |         |     X       |             |   X    | Amount + TotalTax + PostBillAdjustmentAmount
    //  |         |             |             |        | + PostBillTotalTaxAdjustmentAmount 
    //  |         |             |             |        | + PreBillAdjustmentAmount 
    //  |         |             |             |        | + PreBillTotalTaxAdjustmentAmount    
    //  ---------------------------------------------------------------------------------------------
    //  |         |     X       |             |        | Amount + PostBillAdjustmentAmount
    //  |         |             |             |        | + PreBillAdjustmentAmount
    //  ---------------------------------------------------------------------------------------------

    // First we do a little setup so it's easier to build out the matrix
    _bstr_t bstrDisplayAmount = "";
    _bstr_t bstrAmount = L"au.Amount";
    _bstr_t bstrTotalTax = L"{fn IFNULL((tax_federal), 0.0)} + {fn IFNULL((tax_state), 0.0)} + {fn IFNULL((tax_county), 0.0)} + "\
		  							       L"{fn IFNULL((tax_local), 0.0)} + {fn IFNULL((tax_other), 0.0)}";
    _bstr_t bstrPreBillAdjustmentAmount = L"{fn IFNULL((CompoundPrebillAdjAmt), 0.0)}";
    _bstr_t bstrPostBillAdjustmentAmount = L"{fn IFNULL((CompoundPostbillAdjAmt), 0.0)}";
    _bstr_t bstrPreBillTotalTaxAdjustmentAmount = L"{fn IFNULL((CompoundPrebillTotalTaxAdjAmt), 0.0)}";
    _bstr_t bstrPostBillTotalTaxAdjustmentAmount = L"{fn IFNULL((CompoundPostbillTotalTaxAdjAmt), 0.0)}";
	  wchar_t buf[2048];

    if(!mInteractiveReport)
    {
      if(mInlineAdjustments)
      {
        if(mbInlineVATTaxes == VARIANT_TRUE)
        {
          // Online Bill and Inline Adjustments and Inline Taxes
		      swprintf_s(buf, 2048, L"%s + %s + %s + %s", (wchar_t*)bstrAmount,
                                              (wchar_t*)bstrTotalTax,
                                              (wchar_t*)bstrPreBillAdjustmentAmount,
                                              (wchar_t*)bstrPreBillTotalTaxAdjustmentAmount);
        }
        else
        {
          // Online Bill and Inline Adjustments
		      swprintf_s(buf, 2048, L"%s + %s", (wchar_t*)bstrAmount,
                                    (wchar_t*)bstrPreBillAdjustmentAmount);
        }
      }
      else
      {
        if(mbInlineVATTaxes == VARIANT_TRUE)
        {
          // Online Bill and Inline Taxes
		      swprintf_s(buf, 2048, L"%s + %s", (wchar_t*)bstrAmount,
                                    (wchar_t*)bstrTotalTax);
        }
        else
        {
          // Online Bill
		      swprintf_s(buf, 2048, L"%s", (wchar_t*)bstrAmount);
        }
      }
    }
    else
    {
      if(mInlineAdjustments)
      {
        if(mbInlineVATTaxes == VARIANT_TRUE)
        {
          // Report and Inline Adjustments and Inline Taxes
		      swprintf_s(buf, 2048, L"%s + %s + %s + %s + %s + %s", (wchar_t*)bstrAmount,
                                                        (wchar_t*)bstrTotalTax,
                                                        (wchar_t*)bstrPreBillAdjustmentAmount,
                                                        (wchar_t*)bstrPreBillTotalTaxAdjustmentAmount,
                                                        (wchar_t*)bstrPostBillAdjustmentAmount,
                                                        (wchar_t*)bstrPostBillTotalTaxAdjustmentAmount);
        }
        else
        {
          // Report and Inline Adjustments
		      swprintf_s(buf, 2048, L"%s + %s + %s", (wchar_t*)bstrAmount,
                                        (wchar_t*)bstrPreBillAdjustmentAmount,
                                        (wchar_t*)bstrPostBillAdjustmentAmount);
        }
      }
      else
      {
        // NOTE: We always inline adjustments in the report view so that is why you see adjustments in this case.
        if(mbInlineVATTaxes == VARIANT_TRUE)
        {
          // Report and Inline Taxes
		      swprintf_s(buf, 2048, L"%s + %s + %s + %s + %s + %s", (wchar_t*)bstrAmount,
                                                        (wchar_t*)bstrTotalTax,
                                                        (wchar_t*)bstrPreBillAdjustmentAmount,
                                                        (wchar_t*)bstrPreBillTotalTaxAdjustmentAmount,
                                                        (wchar_t*)bstrPostBillAdjustmentAmount,
                                                        (wchar_t*)bstrPostBillTotalTaxAdjustmentAmount);
        }
        else
        {
          // Report
		      swprintf_s(buf, 2048, L"%s + %s + %s", (wchar_t*)bstrAmount,
                                        (wchar_t*)bstrPreBillAdjustmentAmount,
                                        (wchar_t*)bstrPostBillAdjustmentAmount);
        }
      }
    }
    bstrDisplayAmount = buf;
  	
	  pQueryAdapter->AddParam(L"%%DISPLAYAMOUNT%%",  bstrDisplayAmount, VARIANT_TRUE);

		pQueryAdapter->AddParam(L"%%ID_LANG%%", aLocaleId) ;
		*pQuery = pQueryAdapter->GetQuery().copy();
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CUsageSummaryQuery::get_InlineAdjustments(VARIANT_BOOL* pVal)
{
  (*pVal) = mInlineAdjustments ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP CUsageSummaryQuery::put_InlineAdjustments(VARIANT_BOOL newVal)
{
  mInlineAdjustments =  (newVal == VARIANT_TRUE) ? true : false;

	return S_OK;
}


STDMETHODIMP CUsageSummaryQuery::get_InteractiveReport(VARIANT_BOOL* pVal)
{
  (*pVal) = mInteractiveReport ? VARIANT_TRUE : VARIANT_FALSE;

	return S_OK;
}

STDMETHODIMP CUsageSummaryQuery::put_InteractiveReport(VARIANT_BOOL newVal)
{
  mInteractiveReport =  (newVal == VARIANT_TRUE) ? true : false;

	return S_OK;
}



STDMETHODIMP CUsageSummaryQuery::get_InlineVATTaxes(VARIANT_BOOL *pVal)
{
  *pVal = mbInlineVATTaxes;

	return S_OK;
}

STDMETHODIMP CUsageSummaryQuery::put_InlineVATTaxes(VARIANT_BOOL newVal)
{
  mbInlineVATTaxes = newVal;
	return S_OK;
}
