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
#include "SessionSlice.h"

#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <SliceToken.h>

#include "usedatamart.h"

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <MTHierarchyReports.tlb> rename("EOF", "EOFHR")

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.OnlineBill.tlb> inject_statement("using namespace mscorlib;")

/////////////////////////////////////////////////////////////////////////////
// CSessionSlice

STDMETHODIMP CSessionSlice::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ISessionSlice,
    &IID_IViewSlice
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CSessionSlice::ToString(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%I64d", (const wchar_t *)SliceToken::SESSION, mSessionID);
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

STDMETHODIMP CSessionSlice::ToStringUnencrypted(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%I64d", (const wchar_t *)SliceToken::SESSION, mSessionID);

    *pVal = (_bstr_t(buf)).copy();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CSessionSlice::FromString(ISliceLexer* apLexer)
{
	if (!apLexer)
		return E_POINTER;
	try
	{
		MTHIERARCHYREPORTSLib::ISliceLexerPtr pLexer(apLexer);
		if(SliceToken::SESSION != pLexer->GetNextToken()) 
		{
			char buf [512];
			sprintf_s(buf, 512, "Parse Error: Expected token %s", (const char *)SliceToken::SESSION);
			return Error(buf);
		}
		int scanned;
		scanned = swscanf((const wchar_t *) pLexer->GetNextToken(), L"%I64d", &mSessionID);
		if (scanned != 1) return Error("Parse Error: expected integer");
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CSessionSlice::Equals(IViewSlice* apSlice, VARIANT_BOOL *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = VARIANT_FALSE;

	try
	{
		// Cast to session slice
		MTHIERARCHYREPORTSLib::IViewSlicePtr pSlice(apSlice);
		if(pSlice)
		{
			MTHIERARCHYREPORTSLib::ISessionSlicePtr pCast(pSlice);
			if(NULL != pCast &&
         pCast->SessionID == mSessionID)
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

STDMETHODIMP CSessionSlice::Clone(IViewSlice* *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		MTHIERARCHYREPORTSLib::ISessionSlicePtr This(this);
		MTHIERARCHYREPORTSLib::ISessionSlicePtr clone(__uuidof(MTHIERARCHYREPORTSLib::SessionSlice));
		clone->SessionID = This->SessionID;
		*pVal = reinterpret_cast<ISessionSlice *> (clone.Detach());
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CSessionSlice::get_SessionID(__int64 *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mSessionID;

	return S_OK;
}

STDMETHODIMP CSessionSlice::put_SessionID(__int64 newVal)
{
	mSessionID = newVal;

	return S_OK;
}

STDMETHODIMP CSessionSlice::CreateChildSlice(IViewSlice* *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	try
	{
    MTHIERARCHYREPORTSLib::ISessionChildrenSlicePtr ptr(__uuidof(MTHIERARCHYREPORTSLib::SessionChildrenSlice));
    ptr->ParentID = mSessionID;
    *pVal = reinterpret_cast<IViewSlice *>(ptr.Detach());
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}


STDMETHODIMP CSessionSlice::GenerateQueryPredicate(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
		pQueryAdapter->Init(L"\\Queries\\PresServer");
		pQueryAdapter->SetQueryTag(UseDataMart() ? L"__SESSION_PREDICATE_DATAMART__" : L"__SESSION_PREDICATE__");
		pQueryAdapter->AddParam(L"%%ID_SESSION%%", _variant_t(mSessionID)) ;
		*pVal = pQueryAdapter->GetQuery().copy();
	} 
	catch(_com_error & e)
	{
    return ReturnComError(e);
	}

	return S_OK;
}
