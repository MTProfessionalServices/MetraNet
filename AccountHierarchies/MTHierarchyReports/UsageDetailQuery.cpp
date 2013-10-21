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
#include "UsageDetailQuery.h"

#include <comdef.h>
#include <mtcomerr.h>
#include <DBConstants.h>
#include <mtprogids.h>
#include <DataAccessDefs.h>
#include <stdutils.h>

#include "usedatamart.h"

#import <MTHierarchyReports.tlb> rename("EOF", "RowsetEOF")
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.DataAccess.Hinter.tlb> inject_statement("using namespace mscorlib;")

/////////////////////////////////////////////////////////////////////////////
// CUsageDetailQuery

STDMETHODIMP CUsageDetailQuery::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IUsageDetailQuery
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CUsageDetailQuery::get_TimeSlice(IViewSlice **pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CUsageDetailQuery::putref_TimeSlice(IViewSlice *newVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CUsageDetailQuery::get_AccountSlice(IAccountSlice **pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CUsageDetailQuery::putref_AccountSlice(IAccountSlice *newVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CUsageDetailQuery::GenerateQueryString(long aLocaleId,
                                                    IQueryParams* pQueryParams,
                                                    BSTR * pQuery)
{
  if(!pQuery)
		return E_POINTER;
	else
		*pQuery = NULL;

	try
	{
    MTHIERARCHYREPORTSLib::ITimeSlicePtr pTimeSlice;
    HRESULT hr = pQueryParams->get_TimeSlice((ITimeSlice **) &pTimeSlice);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    if (pTimeSlice == NULL)
      MT_THROW_COM_ERROR("Invalid query paramter: TimeSlice");

    MTHIERARCHYREPORTSLib::IAccountSlicePtr pAccountSlice;
    hr = pQueryParams->get_AccountSlice((IAccountSlice**) &pAccountSlice);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    if (pAccountSlice == NULL)
      MT_THROW_COM_ERROR("Invalid query paramter: AccountSlice");

    MTHIERARCHYREPORTSLib::ISingleProductSlicePtr pProductSlice;
    hr = pQueryParams->get_SingleProductSlice((ISingleProductSlice**) &pProductSlice);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    if (pProductSlice == NULL)
      MT_THROW_COM_ERROR("Invalid query paramter: SingleProductSlice");

    MTHIERARCHYREPORTSLib::IViewSlicePtr pSessionSlice;
    hr = pQueryParams->get_SessionSlice((IViewSlice**) &pSessionSlice);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);
    if (pSessionSlice == NULL)
      MT_THROW_COM_ERROR("Invalid query paramter: SessionSlice");

    BSTR aExtension;
    hr = pQueryParams->get_Extension(&aExtension);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);

    long lTopRows;
    hr = pQueryParams->get_TopRows(&lTopRows);
    if (FAILED(hr))
      MT_THROW_COM_ERROR(hr);

		*pQuery = GenerateQueryStringInternal
      (aLocaleId, (ITimeSlice*)(MTHIERARCHYREPORTSLib::ITimeSlice *) pTimeSlice,
      (IAccountSlice*)(MTHIERARCHYREPORTSLib::IAccountSlice *) pAccountSlice,
      (ISingleProductSlice*)(MTHIERARCHYREPORTSLib::ISingleProductSlice *) pProductSlice,
      (IViewSlice*)(MTHIERARCHYREPORTSLib::IViewSlice *) pSessionSlice,
       aExtension,
       UseDataMart() ? "__GET_USAGE_DETAIL_DATAMART_PRESSERVER__" : "__GET_USAGE_DETAIL_PRESSERVER__",
       lTopRows).copy();
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CUsageDetailQuery::GenerateQueryStringFinder(long aLocaleId, ITimeSlice *apTimeSlice, IAccountSlice *apAccountSlice, ISingleProductSlice* apProductSlice, IViewSlice *apSessionSlice, BSTR aExtension, BSTR * pQuery)
{
  if(!pQuery)
		return E_POINTER;
	else
		*pQuery = NULL;

	try
	{
		*pQuery = GenerateQueryStringInternal
      (aLocaleId, apTimeSlice, apAccountSlice, apProductSlice, apSessionSlice, aExtension,"__GET_TRANSACTION_DETAIL__").copy();
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CUsageDetailQuery::GenerateAdjustmentQueryString(long aLocaleId, ITimeSlice *apTimeSlice, IAccountSlice *apAccountSlice, ISingleProductSlice* apProductSlice, IViewSlice *apSessionSlice, BSTR aExtension, BSTR * pQuery)
{
  if(!pQuery)
		return E_POINTER;
	else
		*pQuery = NULL;

	try
	{
		*pQuery = GenerateQueryStringInternal
      (aLocaleId, apTimeSlice, apAccountSlice, apProductSlice, apSessionSlice, aExtension, UseDataMart() ? "__GET_ADJUSTMENT_DETAIL__" : "__GET_ADJUSTMENT_DETAIL__").copy();
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

_bstr_t CUsageDetailQuery::GenerateQueryStringInternal(long aLocaleId, ITimeSlice *apTimeSlice, IAccountSlice *apAccountSlice, ISingleProductSlice* apProductSlice, IViewSlice *apSessionSlice, BSTR aExtension, char* aTag, long lTopRows /*= -1,  value not provided */)
{
	if(!apProductSlice || !apTimeSlice || !apAccountSlice || !apSessionSlice)
		return E_POINTER;

	_bstr_t bstrTag = aTag;
	// Use smart pointers for the dimension arguments
	MTHIERARCHYREPORTSLib::ITimeSlicePtr pTimeSlice(apTimeSlice);
	MTHIERARCHYREPORTSLib::IAccountSlicePtr pAccountSlice(apAccountSlice);
	MTHIERARCHYREPORTSLib::ISingleProductSlicePtr pProductSlice(apProductSlice);
	MTHIERARCHYREPORTSLib::IViewSlicePtr pSessionSlice(apSessionSlice);
	
	// The product slice will tell us which product view table (fact table) to use
	MTPRODUCTVIEWLib::IProductViewPtr pView = pProductSlice->ProductView;
	if(pView == NULL || pView->name.length() == 0 || pView->ViewID < 0)
		MT_THROW_COM_ERROR("Invalid ProductView property on the Product Slice");
	
	// Ordinary product view properties just go in the select list,
	// enumerated types need a join against t_description to get localized.
	_bstr_t selectList;
	_bstr_t fromClause;
	_bstr_t whereClause;
	
	MTHIERARCHYREPORTSLib::IMTCollectionPtr properties = pView->GetProperties();		
	for (int i=1; i <= properties->Count; ++i)
	{
		MTPRODUCTVIEWLib::IProductViewPropertyPtr property = properties->GetItem(i);
		
		if (property->Core == VARIANT_FALSE && property->UserVisible == VARIANT_TRUE) 
		{
			if (property->PropertyType != MTHIERARCHYREPORTSLib::MSIX_TYPE_ENUM)
			{
				selectList += _bstr_t(L", pv.");
				selectList += property->ColumnName;
			}
			else  // Enum type property
			{
				// ESR-6199:
				//     (Required property)      INNER JOIN t_description desc71 ON  desc71.id_desc = pv.c_ServiceLevel AND desc71.id_lang_code = 840 
				// (Non-required property) LEFT OUTER JOIN t_description desc71 ON  desc71.id_desc = pv.c_ServiceLevel AND desc71.id_lang_code = 840 
				wchar_t buf [512];
				// From Clause : t_description desc71
				int lDescID = property->DescriptionID;
				swprintf_s(buf, 512, L"\n%s t_description desc%d ON desc%d.id_desc = pv.%s AND desc%d.id_lang_code = %d AND pv.%s > 0",
								 ((property->required == VARIANT_TRUE) ? L"INNER JOIN" : L"LEFT OUTER JOIN"),
								 lDescID, lDescID, (const wchar_t *)property->ColumnName, lDescID, aLocaleId, (const wchar_t *)property->ColumnName);
				fromClause += _bstr_t(buf);
				// Select List :  desc71.tx_desc ColumnName
				swprintf_s(buf, 512, L", desc%d.tx_desc %s", 
								 lDescID, 
								 (const wchar_t *)property->ColumnName);
				selectList += _bstr_t(buf);
			}
		}
	}

	// The account slice might have an additional table (for the ancestor table)
	_bstr_t accountFromClause = pAccountSlice->GenerateFromClause();
	if(accountFromClause.length() > 0)
	{
		fromClause += accountFromClause;
	}

	// Grab the query skeleton and fill it in
	QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
	pQueryAdapter->Init(L"\\Queries\\PresServer");
	pQueryAdapter->SetQueryTag(bstrTag);

  // If top rows value is provided then...
  if (lTopRows >= 0)
  {
    char szTopRows[128];
    bool isOracle = (mtwcscasecmp(pQueryAdapter->GetDBType(), ORACLE_DATABASE_TYPE) == 0); 

    // 0 means caller wants all rows to be returned.
    // In SQL Server we do "TOP N" and in Oracle we do "where rownum <= N"
    if (lTopRows == 0)
    {
      szTopRows[0] = 0;
      if(isOracle)
      {
        sprintf_s(szTopRows, 128, "%s", "1=1");  // return all rows
      }
    }
    else
    {
      if(isOracle)
      {
        sprintf_s(szTopRows, 128, "rownum <= %d", lTopRows);  
      }
      else
      {
        sprintf_s(szTopRows, 128, "top %d", lTopRows);
      }
    }

    pQueryAdapter->AddParam(L"%%TOP_ROWS%%", _bstr_t(szTopRows));
  }

	pQueryAdapter->AddParam(L"%%SELECT_CLAUSE%%", selectList);
	pQueryAdapter->AddParam(L"%%FROM_CLAUSE%%", fromClause);
	pQueryAdapter->AddParam(L"%%TABLE_NAME%%", pView->tablename);
	pQueryAdapter->AddParam(L"%%TIME_PREDICATE%%", pTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);
	pQueryAdapter->AddParam(L"%%ACCOUNT_PREDICATE%%", pAccountSlice->GenerateQueryPredicate(), VARIANT_TRUE);
	pQueryAdapter->AddParam(L"%%PRODUCT_PREDICATE%%", pProductSlice->GenerateQueryPredicate(), VARIANT_TRUE);
	pQueryAdapter->AddParam(L"%%SESSION_PREDICATE%%", pSessionSlice->GenerateQueryPredicate());
	if(pView->HasChildren == VARIANT_TRUE)
	{
		pQueryAdapter->AddParam(L"%%SESSION_TYPE%%", DB_COMPOUND_SESSION);
	}
	else
	{
		pQueryAdapter->AddParam(L"%%SESSION_TYPE%%", DB_ATOMIC_SESSION);
	}
	pQueryAdapter->AddParam(L"%%EXT%%",  _bstr_t(aExtension ? aExtension : L""), VARIANT_TRUE) ;
	
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
	_bstr_t bstrDisplayAmount  = "";
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
	
	// applies hints, if any
	MetraTech_DataAccess_Hinter::IQueryHinterPtr hinter = pQueryAdapter->GetHinter();
	if (hinter)
	{
		hinter->AddParam("AccountSlice", pAccountSlice->ToStringUnencrypted()); 
		hinter->AddParam("ProductSlice", pProductSlice->ToStringUnencrypted()); 
		hinter->AddParam("SessionSlice", pSessionSlice->ToStringUnencrypted()); 
		hinter->Apply();
	}

	return pQueryAdapter->GetQuery();
}

STDMETHODIMP CUsageDetailQuery::GenerateBaseAdjustmentQueryString(long aLocaleId, ITimeSlice *apTimeSlice, IAccountSlice *apAccountSlice, IViewSlice *apSessionSlice, BSTR aExtension, VARIANT_BOOL aIsPostBill, BSTR * pQuery)
{
  if(!pQuery || !apTimeSlice || !apAccountSlice)
		return E_POINTER;
	else
		*pQuery = NULL;

	try
	{
		// Use smart pointers for the dimension arguments
		MTHIERARCHYREPORTSLib::ITimeSlicePtr pTimeSlice(apTimeSlice);
		MTHIERARCHYREPORTSLib::IAccountSlicePtr pAccountSlice(apAccountSlice);
		MTHIERARCHYREPORTSLib::IViewSlicePtr pSessionSlice(apSessionSlice);

		// If the session slice is null, then treat it as an AllSession slice.
		if (pSessionSlice.GetInterfacePtr() == NULL)
		{
			pSessionSlice.CreateInstance(__uuidof(MTHIERARCHYREPORTSLib::AllSessionSlice));
		}

		// The account slice might have an additional table (for the ancestor table)
		_bstr_t accountFromClause = pAccountSlice->GenerateFromClause();
		_bstr_t fromClause;
		if(accountFromClause.length() > 0)
		{
			fromClause += accountFromClause;
		}
		// Grab the query skeleton and fill it in
		QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
		pQueryAdapter->Init(L"\\Queries\\PresServer");
		pQueryAdapter->SetQueryTag(UseDataMart() ? L"__GET_BASE_ADJUSTMENT_DETAIL_DATAMART_PRESSERVER__" : L"__GET_BASE_ADJUSTMENT_DETAIL_PRESSERVER__");

		bool parentInserted = false;
		MTHIERARCHYREPORTSLib::IDateRangeSlicePtr pDateRange(apTimeSlice);
		if (NULL != pDateRange.GetInterfacePtr())
		{
			// UGLY HACK!  I am breaking abstraction here because date ranges have such wierd
			// semantics and need to be handled so differently for usage and adjustments.  Here is
			// the scoop.  A date range on parent usage is exactly as one expects (i.e. dt_session between start and endd).
			// However, for child usage a date range is not that but rather is a predicate on the PARENT
			// (i.e. select conference connections whose associated call has dt_session between start and end).
			// For usage this is handled in a goofy way by having DateRangeSlice implement no constraint
			// for children; there is an implicit assumption that DateRangeSlices will only be applied to
			// children with a corresponding ParentSession slice.  This is valid for viewing usage since we
			// navigate to usage by walking the session hierarchy.  However, this is NOT valid for adjustments,
			// we need the ability to show all adjustments in a date range in a single rowset.  This necessitates
			// the following very nasty code that self joins t_acc_usage and implements the date range as a 
			// predicate on the parent.
			fromClause += L"\nLEFT OUTER JOIN t_acc_usage auparent on au.id_parent_sess=auparent.id_sess";
			parentInserted = true;

			QUERYADAPTERLib::IMTQueryAdapterPtr pPredicateQueryAdapter(MTPROGID_QUERYADAPTER) ;
			pPredicateQueryAdapter->Init(L"\\Queries\\PresServer");
			pPredicateQueryAdapter->SetQueryTag(UseDataMart() ? L"__ADJUSTMENT_DATE_RANGE_PREDICATE_DATAMART__" : L"__ADJUSTMENT_DATE_RANGE_PREDICATE__");
			
			pPredicateQueryAdapter->AddParam(L"%%DT_BEGIN%%", _variant_t(pDateRange->Begin, VT_DATE)) ;
			pPredicateQueryAdapter->AddParam(L"%%DT_END%%", _variant_t(pDateRange->End, VT_DATE)) ; 
			pQueryAdapter->AddParam(L"%%TIME_PREDICATE%%", pPredicateQueryAdapter->GetQuery(), VARIANT_TRUE);
		}
		else
		{
			pQueryAdapter->AddParam(L"%%TIME_PREDICATE%%", pTimeSlice->GenerateQueryPredicate(), VARIANT_TRUE);
		}
		pQueryAdapter->AddParam(L"%%FROM_CLAUSE%%", fromClause);
		MTHIERARCHYREPORTSLib::IDescendentPayeeSlicePtr pDescendent(apAccountSlice);
		if (NULL != pDescendent.GetInterfacePtr())
		{
			// Same hack for the same reason as above.  Not quite convinced that this deserves
			// an abstraction like a "GenerateAdjustmentQueryPredicate" method on slices.  Yuck.
			if(!parentInserted)
			{
				fromClause += L"\nLEFT OUTER JOIN t_acc_usage auparent on au.id_parent_sess=auparent.id_sess";
				parentInserted = true;
			}

			QUERYADAPTERLib::IMTQueryAdapterPtr pPredicateQueryAdapter(MTPROGID_QUERYADAPTER) ;
			pPredicateQueryAdapter->Init(L"\\Queries\\PresServer");
			pPredicateQueryAdapter->SetQueryTag(UseDataMart() ? L"__ADJUSTMENT_DESCENDENT_PAYEE_PREDICATE_DATAMART__" : L"__ADJUSTMENT_DESCENDENT_PAYEE_PREDICATE__");
			pPredicateQueryAdapter->AddParam(L"%%ID_ANCESTOR%%", pDescendent->AncestorID);
			pPredicateQueryAdapter->AddParam(L"%%DT_BEGIN%%", _variant_t(pDescendent->Begin, VT_DATE)) ;
			pPredicateQueryAdapter->AddParam(L"%%DT_END%%", _variant_t(pDescendent->End, VT_DATE)) ; 
			pQueryAdapter->AddParam(L"%%ACCOUNT_PREDICATE%%", pPredicateQueryAdapter->GetQuery(), VARIANT_TRUE);
		}
		else
		{
			pQueryAdapter->AddParam(L"%%ACCOUNT_PREDICATE%%", pAccountSlice->GenerateQueryPredicate(), VARIANT_TRUE);
		}
		pQueryAdapter->AddParam(L"%%SESSION_PREDICATE%%", pSessionSlice->GenerateQueryPredicate());
		pQueryAdapter->AddParam(L"%%EXT%%",  _bstr_t(aExtension ? aExtension : L""), VARIANT_TRUE) ;
		pQueryAdapter->AddParam(L"%%ID_LANG_CODE%%", aLocaleId);
		pQueryAdapter->AddParam(L"%%IS_POSTBILL%%", _bstr_t(aIsPostBill == VARIANT_TRUE ? "Y" : "N"), VARIANT_TRUE);

		*pQuery = pQueryAdapter->GetQuery().copy();		
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CUsageDetailQuery::get_InlineAdjustments(VARIANT_BOOL* pVal)
{
  (*pVal) = mInlineAdjustments ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP CUsageDetailQuery::put_InlineAdjustments(VARIANT_BOOL newVal)
{
  mInlineAdjustments =  (newVal == VARIANT_TRUE) ? true : false;

	return S_OK;
}


STDMETHODIMP CUsageDetailQuery::get_InteractiveReport(VARIANT_BOOL* pVal)
{
  (*pVal) = mInteractiveReport ? VARIANT_TRUE : VARIANT_FALSE;

	return S_OK;
}

STDMETHODIMP CUsageDetailQuery::put_InteractiveReport(VARIANT_BOOL newVal)
{
  mInteractiveReport =  (newVal == VARIANT_TRUE) ? true : false;

	return S_OK;
}



STDMETHODIMP CUsageDetailQuery::get_InlineVATTaxes(VARIANT_BOOL *pVal)
{
  *pVal = mbInlineVATTaxes;

	return S_OK;
}

STDMETHODIMP CUsageDetailQuery::put_InlineVATTaxes(VARIANT_BOOL newVal)
{
  mbInlineVATTaxes = newVal;
	return S_OK;
}
