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
#include "UsageIntervalSlice.h"

#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#include <autoinstance.h>
#include <DBUsageCycle.h>
#include <SliceToken.h>

#include "usedatamart.h"

// import the query adapter tlb ...
#import <QueryAdapter.tlb>  rename("GetUserName", "GetUserNameQA")
#import <MTHierarchyReports.tlb> rename("EOF", "EOFHR")

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.OnlineBill.tlb> inject_statement("using namespace mscorlib;")

/////////////////////////////////////////////////////////////////////////////
// CUsageIntervalSlice

STDMETHODIMP CUsageIntervalSlice::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IUsageIntervalSlice,
    &IID_IViewSlice
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CUsageIntervalSlice::ToString(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
    wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%d", (const wchar_t *)SliceToken::USAGEINTERVAL, mIntervalID);
    //Encrypt for QueryString
    MetraTech_OnlineBill::IQueryStringEncryptPtr qsEncrypt;
    qsEncrypt = new MetraTech_OnlineBill::IQueryStringEncryptPtr(__uuidof(MetraTech_OnlineBill::QueryStringEncrypt));
    *pVal = qsEncrypt->EncryptString(_bstr_t(buf)).copy();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CUsageIntervalSlice::ToStringUnencrypted(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%d", (const wchar_t *)SliceToken::USAGEINTERVAL, mIntervalID);
    *pVal = _bstr_t(buf).copy();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CUsageIntervalSlice::FromString(ISliceLexer* apLexer)
{
	if (!apLexer)
		return E_POINTER;
	try
	{
		MTHIERARCHYREPORTSLib::ISliceLexerPtr pLexer(apLexer);
		if(SliceToken::USAGEINTERVAL != pLexer->GetNextToken()) 
		{
			char buf [512];
			sprintf_s(buf, 512, "Parse Error: Expected token %s", (const char *)SliceToken::USAGEINTERVAL);
			return Error(buf);
		}
		int scanned;
		scanned = swscanf((const wchar_t *) pLexer->GetNextToken(), L"%d", &mIntervalID);
		if (scanned != 1) return Error("Parse Error: expected integer");
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CUsageIntervalSlice::Equals(IViewSlice* apSlice, VARIANT_BOOL *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = VARIANT_FALSE;

	try
	{
		// Cast to usage interval slice
		MTHIERARCHYREPORTSLib::IViewSlicePtr pSlice(apSlice);
		if(pSlice)
		{
			MTHIERARCHYREPORTSLib::IUsageIntervalSlicePtr pCast(pSlice);
			if(NULL != pCast &&
         pCast->IntervalID == mIntervalID)
			{
				*pVal = VARIANT_TRUE;
			}
		}
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CUsageIntervalSlice::Clone(IViewSlice* *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		MTHIERARCHYREPORTSLib::IUsageIntervalSlicePtr This(this);
		MTHIERARCHYREPORTSLib::IUsageIntervalSlicePtr clone(__uuidof(MTHIERARCHYREPORTSLib::UsageIntervalSlice));
		clone->IntervalID = This->IntervalID;
		*pVal = reinterpret_cast<IUsageIntervalSlice *> (clone.Detach());
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CUsageIntervalSlice::get_IntervalID(long *pVal)
{
	if(!pVal)
		return E_POINTER;
	else 
		*pVal = mIntervalID;

	return S_OK;
}

STDMETHODIMP CUsageIntervalSlice::put_IntervalID(long newVal)
{
	mIntervalID = newVal;

	return S_OK;
}

STDMETHODIMP CUsageIntervalSlice::GenerateQueryPredicate(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
		pQueryAdapter->Init(L"\\Queries\\PresServer");
		pQueryAdapter->SetQueryTag(UseDataMart() ? L"__USAGE_INTERVAL_PREDICATE_DATAMART_PRESSERVER__" : L"__USAGE_INTERVAL_PREDICATE_PRESSERVER__");
		pQueryAdapter->AddParam(L"%%ID_INTERVAL%%", _variant_t(mIntervalID));
		*pVal = pQueryAdapter->GetQuery().copy();
	} 
	catch(_com_error & e)
	{
    return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CUsageIntervalSlice::GetTimeSpan(DATE * pMinDate, DATE * pMaxDate)
{
	if (!pMinDate || !pMaxDate)
		return E_POINTER;
	else
	{
		*pMinDate = (DATE)0;
		*pMaxDate = (DATE)0;
	}

	// Lookup interval endpoints from id.
	MTAutoSingleton<DBUsageCycleCollection> usageCycleCol;
	if(!usageCycleCol->GetIntervalStartAndEndDate(mIntervalID,*pMinDate,*pMaxDate)) 
	{
		char buf[128];
		sprintf_s(buf, 128, "Failed to get date range of usage interval: %d", mIntervalID);
		return Error(buf);
	}
	return S_OK;
}
