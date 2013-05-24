// PayerAndPayeeAndEndpointSlice.cpp : Implementation of CPayerAndPayeeAndEndpointSlice

#include "StdAfx.h"
#include "PayerAndPayeeAndEndpointSlice.h"


// CPayerAndPayeeAndEndpointSlice
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
// CPayerAndPayeeAndEndpointSlice

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IPayerAndPayeeAndEndpointSlice,
    &IID_IViewSlice,
    &IID_IAccountSlice
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::ToString(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%d/%d", (const wchar_t *)SliceToken::PAYERPAYEEENDPOINT, mPayerID, mPayeeID);
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

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::ToStringUnencrypted(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%d/%d", (const wchar_t *)SliceToken::PAYERPAYEEENDPOINT, mPayerID, mPayeeID);

    *pVal = (_bstr_t(buf)).copy();		
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::FromString(ISliceLexer* apLexer)
{
	if (!apLexer)
		return E_POINTER;
	try
	{
		MTHIERARCHYREPORTSLib::ISliceLexerPtr pLexer(apLexer);
		if(SliceToken::PAYERPAYEEENDPOINT != pLexer->GetNextToken()) 
		{
			char buf [512];
			sprintf_s(buf, 512, "Parse Error: Expected token %s", (const char *)SliceToken::PAYERPAYEEENDPOINT);
			return Error(buf);
		}
		int scanned;
		scanned = swscanf((const wchar_t *) pLexer->GetNextToken(), L"%d", &mPayerID);
		if (scanned != 1) return Error("Parse Error: expected integer");
		scanned = swscanf((const wchar_t *) pLexer->GetNextToken(), L"%d", &mPayeeID);
		if (scanned != 1) return Error("Parse Error: expected integer");
		//scanned = swscanf((const wchar_t *) pLexer->GetNextToken(), L"%d", &mServiceEndpointID);
		//if (scanned != 1) return Error("Parse Error: expected integer");
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::Equals(IViewSlice* apSlice, VARIANT_BOOL *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = VARIANT_FALSE;

	try
	{
		// Cast to payer/payee slice
		MTHIERARCHYREPORTSLib::IViewSlicePtr pSlice(apSlice);
		if(pSlice)
		{
			MTHIERARCHYREPORTSLib::IPayerAndPayeeAndEndpointSlicePtr pCast(pSlice);
			if(NULL != pCast &&
         pCast->PayerID == mPayerID &&
         pCast->PayeeID == mPayeeID //&&
				 //pCast->ServiceEndpointID == mServiceEndpointID
         )
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

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::Clone(IViewSlice* *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		MTHIERARCHYREPORTSLib::IPayerAndPayeeAndEndpointSlicePtr This(this);
		MTHIERARCHYREPORTSLib::IPayerAndPayeeAndEndpointSlicePtr clone(__uuidof(MTHIERARCHYREPORTSLib::PayerAndPayeeAndEndpointSlice));
		clone->PayerID = This->PayerID;
		clone->PayeeID = This->PayeeID;
		//clone->ServiceEndpointID = This->ServiceEndpointID;
		*pVal = reinterpret_cast<IPayerAndPayeeAndEndpointSlice *> (clone.Detach());
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::get_PayeeID(long* pVal)
{
	if(pVal == NULL) 
		return E_POINTER;

	*pVal = mPayeeID;

	return S_OK;
}

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::put_PayeeID(long newVal)
{
	mPayeeID = newVal;

	return S_OK;
}

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::get_PayerID(long* pVal)
{
	if(pVal == NULL) 
		return E_POINTER;

	*pVal = mPayerID;

	return S_OK;
}

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::put_PayerID(long newVal)
{
	mPayerID = newVal;

	return S_OK;
}

/*STDMETHODIMP CPayerAndPayeeAndEndpointSlice::get_ServiceEndpointID(long* pVal)
{
	if(pVal == NULL) 
		return E_POINTER;

	*pVal = mServiceEndpointID;

	return S_OK;
}

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::put_ServiceEndpointID(long newVal)
{
	mServiceEndpointID = newVal;

	return S_OK;
}
*/
STDMETHODIMP CPayerAndPayeeAndEndpointSlice::GenerateQueryPredicate(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
		pQueryAdapter->Init(L"\\Queries\\PresServer");
		pQueryAdapter->SetQueryTag(UseDataMart() ? L"__PAYER_AND_PAYEE_AND_ENDPOINT_ACCOUNT_PREDICATE_DATAMART__" : L"__PAYER_AND_PAYEE_AND_ENDPOINT_ACCOUNT_PREDICATE__");
		pQueryAdapter->AddParam(L"%%ID_PAYEE%%", _variant_t(mPayeeID)) ;
		pQueryAdapter->AddParam(L"%%ID_PAYER%%", _variant_t(mPayerID)) ;
		//pQueryAdapter->AddParam(L"%%ID_ENDPOINT%%", _variant_t(mServiceEndpointID)) ;
		*pVal = pQueryAdapter->GetQuery().copy();
	} 
	catch(_com_error & e)
	{
    return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CPayerAndPayeeAndEndpointSlice::GenerateFromClause(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		*pVal = _bstr_t(L"").copy();
	} 
	catch(_com_error & e)
	{
    return ReturnComError(e);
	}

	return S_OK;
}
