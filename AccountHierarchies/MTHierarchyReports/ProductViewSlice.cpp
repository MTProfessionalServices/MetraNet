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
#include "ProductViewSlice.h"

#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <SliceToken.h>

#include "usedatamart.h"

#import <QueryAdapter.tlb> rename("GetUserName", "GetUserNameQA")
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.OnlineBill.tlb> inject_statement("using namespace mscorlib;")

/////////////////////////////////////////////////////////////////////////////
// CProductViewSlice

STDMETHODIMP CProductViewSlice::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IProductViewSlice,
    &IID_ISingleProductSlice,
    &IID_IViewSlice
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CProductViewSlice::ToString(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%d", (const wchar_t *)SliceToken::PRODUCTVIEW, mViewID);
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

STDMETHODIMP CProductViewSlice::ToStringUnencrypted(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%d", (const wchar_t *)SliceToken::PRODUCTVIEW, mViewID);

    *pVal = (_bstr_t(buf)).copy();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CProductViewSlice::FromString(ISliceLexer* apLexer)
{
	if (!apLexer)
		return E_POINTER;
	try
	{
		MTHIERARCHYREPORTSLib::ISliceLexerPtr pLexer(apLexer);
		if(SliceToken::PRODUCTVIEW != pLexer->GetNextToken()) 
		{
			char buf [512];
			sprintf_s(buf, 512, "Parse Error: Expected token %s", (const char *)SliceToken::PRODUCTVIEW);
			return Error(buf);
		}
		int scanned;
		scanned = swscanf((const wchar_t *) pLexer->GetNextToken(), L"%d", &mViewID);
		if (scanned != 1) return Error("Parse Error: expected integer");
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CProductViewSlice::Equals(IViewSlice* apSlice, VARIANT_BOOL *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = VARIANT_FALSE;

	try
	{
		// Cast to instance slice
		MTHIERARCHYREPORTSLib::IViewSlicePtr pSlice(apSlice);
		if(pSlice)
		{
			MTHIERARCHYREPORTSLib::IProductViewSlicePtr pCast(pSlice);
			if(NULL != pCast &&
         pCast->ViewID == mViewID)
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

STDMETHODIMP CProductViewSlice::Clone(IViewSlice* *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		MTHIERARCHYREPORTSLib::IProductViewSlicePtr This(this);
		MTHIERARCHYREPORTSLib::IProductViewSlicePtr clone(__uuidof(MTHIERARCHYREPORTSLib::ProductViewSlice));
		clone->ViewID = This->ViewID;
		*pVal = reinterpret_cast<IProductViewSlice *> (clone.Detach());
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CProductViewSlice::get_ViewID(long *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mViewID;	

	return S_OK;
}

STDMETHODIMP CProductViewSlice::put_ViewID(long newVal)
{
	mViewID = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewSlice::GenerateQueryPredicate(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
		pQueryAdapter->Init(L"\\Queries\\PresServer");
		pQueryAdapter->SetQueryTag(UseDataMart() ? L"__PRODUCT_VIEW_PREDICATE_DATAMART_PRESSERVER__" : L"__PRODUCT_VIEW_PREDICATE_PRESSERVER__");
		pQueryAdapter->AddParam(L"%%ID_VIEW%%", _variant_t(mViewID)) ;
   
    _bstr_t out = pQueryAdapter->GetQuery() +  
      SingleProductViewSliceImpl<IProductViewSlice, 
      &IID_IProductViewSlice, 
      &LIBID_MTHIERARCHYREPORTSLib>::GetPredicateString();
    // MTSecurityPrincipalImplBase<IMTYAAC, &IID_IMTYAAC, &LIBID_MTYAACLib>
    //::put_ID(mAccountID);	
		*pVal = out.copy();
	} 
	catch(_com_error & e)
	{
    return returnHierarchyReportError(e);
	}

	return S_OK;
}

STDMETHODIMP CProductViewSlice::get_ProductView(IProductView* *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	try
	{
		if (NULL == mProductView)
		{
			// Get an instance of the product view
			mProductView.CreateInstance(__uuidof(MTPRODUCTVIEWLib::ProductView));
			// Gotta get the product view name from the viewid
			ROWSETLib::IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET);
			pRowset->Init(L"\\Queries\\PresServer");
			pRowset->SetQueryTag(L"__GET_ENUM_NAME__");
			pRowset->AddParam(L"%%ID_ENUM_DATA%%", mViewID) ;
		
			pRowset->Execute();

			if (0 == pRowset->RecordCount)
			{
				return Error("Invalid Product Slice");
			}

			// Use the count of children to determine whether there are children or not.
			mProductView->Init(_bstr_t(pRowset->GetValue(L"nm_enum_data")), long(pRowset->GetValue(L"num_children")) > 0 ? VARIANT_TRUE : VARIANT_FALSE);
		}

    MTPRODUCTVIEWLib::IProductViewPtr ptr = mProductView;
    *pVal = (IProductView *)ptr.Detach();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CProductViewSlice::get_DisplayName(ICOMLocaleTranslator *apLocale, BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		MTHIERARCHYREPORTSLib::ICOMLocaleTranslatorPtr pLocale(reinterpret_cast<MTHIERARCHYREPORTSLib::ICOMLocaleTranslator *>(apLocale));
		
		*pVal = pLocale->GetViewDescription(mViewID).copy();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}

	return S_OK;
}
