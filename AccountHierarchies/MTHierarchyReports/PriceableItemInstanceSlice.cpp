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
#include "PriceableItemInstanceSlice.h"

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
// CPriceableItemInstanceSlice

STDMETHODIMP CPriceableItemInstanceSlice::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IPriceableItemInstanceSlice,
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

STDMETHODIMP CPriceableItemInstanceSlice::ToString(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%d/%d", (const wchar_t *)SliceToken::PIINSTANCE, mInstanceID, mViewID);
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

STDMETHODIMP CPriceableItemInstanceSlice::ToStringUnencrypted(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%d/%d", (const wchar_t *)SliceToken::PIINSTANCE, mInstanceID, mViewID);

    *pVal = (_bstr_t(buf)).copy();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CPriceableItemInstanceSlice::FromString(ISliceLexer* apLexer)
{
	if (!apLexer)
		return E_POINTER;
	try
	{
		MTHIERARCHYREPORTSLib::ISliceLexerPtr pLexer(apLexer);
		if(SliceToken::PIINSTANCE != pLexer->GetNextToken()) 
		{
			char buf [512];
			sprintf_s(buf, 512, "Parse Error: Expected token %s", (const char *)SliceToken::PIINSTANCE);
			return Error(buf);
		}
		int scanned;
		scanned = swscanf((const wchar_t *) pLexer->GetNextToken(), L"%d", &mInstanceID);
		if (scanned != 1) return Error("Parse Error: expected integer");
		scanned = swscanf((const wchar_t *) pLexer->GetNextToken(), L"%d", &mViewID);
		if (scanned != 1) return Error("Parse Error: expected integer");
    mProductView = NULL;
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CPriceableItemInstanceSlice::Equals(IViewSlice* apSlice, VARIANT_BOOL *pVal)
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
			MTHIERARCHYREPORTSLib::IPriceableItemInstanceSlicePtr pCast(pSlice);
			if(NULL != pCast &&
         pCast->InstanceID == mInstanceID &&
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

STDMETHODIMP CPriceableItemInstanceSlice::Clone(IViewSlice* *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		MTHIERARCHYREPORTSLib::IPriceableItemInstanceSlicePtr This(this);
		MTHIERARCHYREPORTSLib::IPriceableItemInstanceSlicePtr clone;//(__uuidof(MTHIERARCHYREPORTSLib::PriceableItemInstanceSlice));
		CComObject<CPriceableItemInstanceSlice> * pCloneClass;
    
    CComObject<CPriceableItemInstanceSlice>::CreateInstance(&pCloneClass);
    HRESULT hr =  pCloneClass->QueryInterface(IID_IPriceableItemInstanceSlice,
								reinterpret_cast<void**>(&clone));
    if FAILED(hr)
      MT_THROW_COM_ERROR(hr);
    
    clone->InstanceID = This->InstanceID;
		clone->ViewID = This->ViewID;
    pCloneClass->SetPredicates(mPredicates);
    
    *pVal = reinterpret_cast<IPriceableItemInstanceSlice *> (clone.Detach());
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CPriceableItemInstanceSlice::get_InstanceID(long *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mInstanceID;	

	return S_OK;
}

STDMETHODIMP CPriceableItemInstanceSlice::put_InstanceID(long newVal)
{
	mInstanceID = newVal;

	return S_OK;
}

STDMETHODIMP CPriceableItemInstanceSlice::get_ViewID(long *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mViewID;	

	return S_OK;
}

STDMETHODIMP CPriceableItemInstanceSlice::put_ViewID(long newVal)
{
	mViewID = newVal;

	return S_OK;
}

STDMETHODIMP CPriceableItemInstanceSlice::GenerateQueryPredicate(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		QUERYADAPTERLib::IMTQueryAdapterPtr pQueryAdapter(MTPROGID_QUERYADAPTER) ;
		pQueryAdapter->Init(L"\\Queries\\PresServer");
		pQueryAdapter->SetQueryTag(UseDataMart() ? L"__PRICEABLE_ITEM_INSTANCE_PREDICATE_DATAMART_PRESSERVER__" : L"__PRICEABLE_ITEM_INSTANCE_PREDICATE_PRESSERVER__");
		pQueryAdapter->AddParam(L"%%ID_INSTANCE%%", _variant_t(mInstanceID)) ;
		pQueryAdapter->AddParam(L"%%ID_VIEW%%", _variant_t(mViewID)) ;
    _bstr_t out;
    out = pQueryAdapter->GetQuery() +  
      SingleProductViewSliceImpl<IPriceableItemInstanceSlice, 
      &IID_IPriceableItemInstanceSlice, 
      &LIBID_MTHIERARCHYREPORTSLib>::GetPredicateString();
    *pVal = out.copy();
	} 
	catch(_com_error & e)
	{
    return returnHierarchyReportError(e);
	}

	return S_OK;
}

STDMETHODIMP CPriceableItemInstanceSlice::get_ProductView(IProductView* *pVal)
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
			ROWSETLib::IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET);
			pRowset->Init(L"\\Queries\\PresServer");
			pRowset->SetQueryTag(L"__GET_ENUM_NAME__");
			pRowset->AddParam(L"%%ID_ENUM_DATA%%", mViewID) ;
		
			pRowset->Execute();

			if (1 != pRowset->RecordCount)
			{
				return Error("Invalid Product Slice");
			}
			_bstr_t bstrProductViewName = _bstr_t(pRowset->GetValue(L"nm_enum_data"));

			// Find out whether we are a parent or not.  We use to use the product catalog
			// for this but the performance got to be intolerable, so we break encapsulation
			// and head to the schema...
			pRowset->Clear();
			pRowset->SetQueryTag(L"__GET_CHILD_COUNT_FROM_INSTANCE__");
			pRowset->AddParam(L"%%ID_PI_INSTANCE%%", mInstanceID) ;
			pRowset->Execute();
			if (1 != pRowset->RecordCount)
			{
				return Error("Invalid Product Slice");
			}

      mProductView->Init(bstrProductViewName,
												 long(pRowset->GetValue(L"cnt")) > 0 ? VARIANT_TRUE : VARIANT_FALSE);
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

STDMETHODIMP CPriceableItemInstanceSlice::get_DisplayName(ICOMLocaleTranslator *apLocale, BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		MTHIERARCHYREPORTSLib::ICOMLocaleTranslatorPtr pLocale(reinterpret_cast<MTHIERARCHYREPORTSLib::ICOMLocaleTranslator *>(apLocale));
		
		long languageID = pLocale->LanguageID;
		if (mDisplayName.end() == mDisplayName.find(languageID))
		{
			ROWSETLib::IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET);
			pRowset->Init(L"\\Queries\\ProductCatalog");
			pRowset->SetQueryTag(L"__GET_LOCALIZED_BASE_PROPS__");
			pRowset->AddParam(L"%%ID_PROP%%", mInstanceID) ;
			pRowset->AddParam(L"%%ID_LANG%%", languageID) ;
		
			pRowset->Execute();

			if (0 == pRowset->RecordCount)
			{
				return Error("Invalid Product Slice");
			}
			mDisplayName[languageID] = _bstr_t(pRowset->GetValue(L"nm_display_name"));
		}

		*pVal = mDisplayName[languageID].copy();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}

	return S_OK;
}
