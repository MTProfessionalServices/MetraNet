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
#include "DescendentPayeeSlice.h"

#include <mtprogids.h>
#include <SliceToken.h>
#include <formatdbvalue.h>

#include "usedatamart.h"

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <MTHierarchyReports.tlb> rename("EOF", "EOFHR")

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.OnlineBill.tlb> inject_statement("using namespace mscorlib;")

/////////////////////////////////////////////////////////////////////////////
// CDescendentPayeeSlice

STDMETHODIMP CDescendentPayeeSlice::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IDescendentPayeeSlice,
    &IID_IAccountSlice,
    &IID_IViewSlice
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CDescendentPayeeSlice::ToString(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%d/%g/%g", (const wchar_t *)SliceToken::DESCENDENT, mAncestorID, mBegin, mEnd);
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

STDMETHODIMP CDescendentPayeeSlice::ToStringUnencrypted(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%d/%g/%g", (const wchar_t *)SliceToken::DESCENDENT, mAncestorID, mBegin, mEnd);

    *pVal = _bstr_t(buf).copy();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CDescendentPayeeSlice::FromString(ISliceLexer* apLexer)
{
	if (!apLexer)
		return E_POINTER;
	try
	{
		MTHIERARCHYREPORTSLib::ISliceLexerPtr pLexer(apLexer);
		if(SliceToken::DESCENDENT != pLexer->GetNextToken()) 
		{
			char buf [512];
			sprintf_s(buf, 512, "Parse Error: Expected token %s", (const char *)SliceToken::DESCENDENT);
			return Error(buf);
		}
		int scanned;
		scanned = swscanf((const wchar_t *) pLexer->GetNextToken(), L"%d", &mAncestorID);
		if (scanned != 1) return Error("Parse Error: expected integer");
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

STDMETHODIMP CDescendentPayeeSlice::Equals(IViewSlice* apSlice, VARIANT_BOOL *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = VARIANT_FALSE;

	try
	{
		// Cast to descendent payee slice
		MTHIERARCHYREPORTSLib::IViewSlicePtr pSlice(apSlice);
		if(pSlice)
		{
			MTHIERARCHYREPORTSLib::IDescendentPayeeSlicePtr pCast(pSlice);
			if(NULL != pCast &&
         pCast->AncestorID == mAncestorID &&
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

STDMETHODIMP CDescendentPayeeSlice::Clone(IViewSlice* *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		MTHIERARCHYREPORTSLib::IDescendentPayeeSlicePtr This(this);
		MTHIERARCHYREPORTSLib::IDescendentPayeeSlicePtr clone(__uuidof(MTHIERARCHYREPORTSLib::DescendentPayeeSlice));
		clone->AncestorID = This->AncestorID;
		*pVal = reinterpret_cast<IDescendentPayeeSlice *> (clone.Detach());
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CDescendentPayeeSlice::get_AncestorID(long *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mAncestorID;

  return S_OK;
}

STDMETHODIMP CDescendentPayeeSlice::put_AncestorID(long newVal)
{
	mAncestorID = newVal;

	return S_OK;
}

STDMETHODIMP CDescendentPayeeSlice::get_Begin(DATE *pVal)
{
	if(!pVal)
		return E_POINTER;
	else 
		*pVal = mBegin;

	return S_OK;
}

STDMETHODIMP CDescendentPayeeSlice::put_Begin(DATE newVal)
{
	mBegin = newVal;

	return S_OK;
}

STDMETHODIMP CDescendentPayeeSlice::get_End(DATE *pVal)
{
	if(!pVal)
		return E_POINTER;
	else 
		*pVal = mEnd;

	return S_OK;
}

STDMETHODIMP CDescendentPayeeSlice::put_End(DATE newVal)
{
	mEnd = newVal;

	return S_OK;
}

STDMETHODIMP CDescendentPayeeSlice::GenerateQueryPredicate(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
		pQueryAdapter->Init(L"\\Queries\\PresServer");
		pQueryAdapter->SetQueryTag(UseDataMart() ? L"__DESCENDENT_PAYEE_PREDICATE_DATAMART_PRESSERVER__" : L"__DESCENDENT_PAYEE_PREDICATE_PRESSERVER__");
		pQueryAdapter->AddParam(L"%%ID_ANCESTOR%%", _variant_t(mAncestorID)) ;

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

STDMETHODIMP CDescendentPayeeSlice::GenerateFromClause(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		*pVal = _bstr_t(L"\nINNER JOIN t_account_ancestor aa ON au.id_payee=aa.id_descendent").copy();
	} 
	catch(_com_error & e)
	{
    return returnHierarchyReportError(e);
	}

	return S_OK;
}

