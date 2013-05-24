// DateRangeSlice.cpp : Implementation of CDateRangeSlice
#include "StdAfx.h"
#include "MTHierarchyReports.h"
#include "DateRangeSlice.h"

#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <formatdbvalue.h>

#include <autoinstance.h>
#include <DBUsageCycle.h>
#include <SliceToken.h>

#include "usedatamart.h"

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "GetUserNameQA")
#import <MTHierarchyReports.tlb> rename("EOF", "EOFHR")

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.OnlineBill.tlb> inject_statement("using namespace mscorlib;")

/////////////////////////////////////////////////////////////////////////////
// CDateRangeSlice

STDMETHODIMP CDateRangeSlice::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IDateRangeSlice,
    &IID_IViewSlice
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CDateRangeSlice::ToString(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%g/%g", (const wchar_t *)SliceToken::DATERANGE, mBegin, mEnd);
  
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

STDMETHODIMP CDateRangeSlice::ToStringUnencrypted(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%g/%g", (const wchar_t *)SliceToken::DATERANGE, mBegin, mEnd);
    *pVal = _bstr_t(buf).copy();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}	
	return S_OK;
}

STDMETHODIMP CDateRangeSlice::FromString(ISliceLexer* apLexer)
{
	if (!apLexer)
		return E_POINTER;
	try
	{
		MTHIERARCHYREPORTSLib::ISliceLexerPtr pLexer(apLexer);
		if(SliceToken::DATERANGE != pLexer->GetNextToken()) 
		{
			char buf [512];
			sprintf_s(buf, 512, "Parse Error: Expected token %s", (const char *)SliceToken::DATERANGE);
			return Error(buf);
		}
		int scanned;
		scanned = swscanf((const wchar_t *) pLexer->GetNextToken(), L"%lg", &mBegin);
		if (scanned != 1) return Error("Parse Error: expected DATE");
		scanned = swscanf((const wchar_t *) pLexer->GetNextToken(), L"%lg", &mEnd);
		if (scanned != 1) return Error("Parse Error: expected DATE");
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CDateRangeSlice::Equals(IViewSlice* apSlice, VARIANT_BOOL *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = VARIANT_FALSE;

	try
	{
		// Cast to date range slice
		MTHIERARCHYREPORTSLib::IViewSlicePtr pSlice(apSlice);
		if(pSlice)
		{
			MTHIERARCHYREPORTSLib::IDateRangeSlicePtr pCast(pSlice);
			if(NULL != pCast &&
         pCast->Begin == mBegin &&
         pCast->End == mEnd)
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

STDMETHODIMP CDateRangeSlice::Clone(IViewSlice* *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		MTHIERARCHYREPORTSLib::IDateRangeSlicePtr This(this);
		MTHIERARCHYREPORTSLib::IDateRangeSlicePtr clone(__uuidof(MTHIERARCHYREPORTSLib::DateRangeSlice));
		clone->Begin = This->Begin;
		clone->End = This->End;
		*pVal = reinterpret_cast<IDateRangeSlice *> (clone.Detach());
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CDateRangeSlice::get_Begin(DATE *pVal)
{
	if(!pVal)
		return E_POINTER;
	else 
		*pVal = mBegin;

	return S_OK;
}

STDMETHODIMP CDateRangeSlice::put_Begin(DATE newVal)
{
	mBegin = newVal;

	return S_OK;
}

STDMETHODIMP CDateRangeSlice::get_End(DATE *pVal)
{
	if(!pVal)
		return E_POINTER;
	else 
		*pVal = mEnd;

	return S_OK;
}

STDMETHODIMP CDateRangeSlice::put_End(DATE newVal)
{
	mEnd = newVal;

	return S_OK;
}

STDMETHODIMP CDateRangeSlice::put_IntervalID(long newVal)
{
	// Lookup interval endpoints from id.
	DATE dtBegin, dtEnd;

	MTAutoSingleton<DBUsageCycleCollection> usageCycleCol;
	if(!usageCycleCol->GetIntervalStartAndEndDate(newVal, dtBegin , dtEnd)) 
	{
		char buf[512];
		sprintf_s(buf, 512, "Failed to get date range of usage interval: %d", newVal);
		return Error(buf);
	}
	
	mBegin = dtBegin;
	mEnd = dtEnd;

	return S_OK;
}

STDMETHODIMP CDateRangeSlice::GenerateQueryPredicate(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
		pQueryAdapter->Init(L"\\Queries\\PresServer");
		pQueryAdapter->SetQueryTag(UseDataMart() ? L"__DATE_RANGE_PREDICATE_DATAMART_PRESSERVER__" : L"__DATE_RANGE_PREDICATE_PRESSERVER__");

		std::wstring buffer;
		BOOL bSuccess = FormatValueForDB(_variant_t(mBegin, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return Error("Failure formatting DATE for database write");
		}

		pQueryAdapter->AddParam(L"%%DT_BEGIN%%", buffer.c_str(), VARIANT_TRUE) ;

		bSuccess = FormatValueForDB(_variant_t(mEnd, VT_DATE), FALSE, buffer);
		if (bSuccess == FALSE)
		{
			return Error("Failure formatting DATE for database write");
		}

		pQueryAdapter->AddParam(L"%%DT_END%%", buffer.c_str(), VARIANT_TRUE) ;
		*pVal = pQueryAdapter->GetQuery().copy();
	} 
	catch(_com_error & e)
	{
    return returnHierarchyReportError(e);
	}

	return S_OK;
}

STDMETHODIMP CDateRangeSlice::GetTimeSpan(DATE * pMinDate, DATE * pMaxDate)
{
	if (!pMinDate || !pMaxDate)
		return E_POINTER;
	else
	{
		*pMinDate = mBegin;
		*pMaxDate = mEnd;
	}

	return S_OK;
}
