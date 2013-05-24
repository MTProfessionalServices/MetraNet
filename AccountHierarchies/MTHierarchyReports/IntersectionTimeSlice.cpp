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
#include "IntersectionTimeSlice.h"

#include <comdef.h>
#include <mtcomerr.h>
#include <SliceToken.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.OnlineBill.tlb> inject_statement("using namespace mscorlib;")

/////////////////////////////////////////////////////////////////////////////
// CIntersectionTimeSlice

STDMETHODIMP CIntersectionTimeSlice::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IIntersectionTimeSlice,
    &IID_IViewSlice
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CIntersectionTimeSlice::get_LHS(ITimeSlice **pVal)
{
	if(!pVal) 
		return E_POINTER;
	else
		*pVal = NULL;

	try 
	{
    MTHIERARCHYREPORTSLib::ITimeSlicePtr ptr = mLHS;

    *pVal = (ITimeSlice *)ptr.Detach();
		
	} 
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}

	return S_OK;
}

STDMETHODIMP CIntersectionTimeSlice::putref_LHS(ITimeSlice *newVal)
{
	try 
	{
		mLHS = newVal;
	} 
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}

	return S_OK;
}

STDMETHODIMP CIntersectionTimeSlice::get_RHS(ITimeSlice **pVal)
{
	if(!pVal) 
		return E_POINTER;
	else
		*pVal = NULL;

	try 
	{
    MTHIERARCHYREPORTSLib::ITimeSlicePtr ptr = mRHS;

    *pVal = (ITimeSlice *)ptr.Detach();
		
	} 
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}

	return S_OK;
}

STDMETHODIMP CIntersectionTimeSlice::putref_RHS(ITimeSlice *newVal)
{
	try 
	{
		mRHS = newVal;
	} 
	catch(_com_error & err)
	{
		return returnHierarchyReportError(err);
	}

	return S_OK;
}

STDMETHODIMP CIntersectionTimeSlice::ToString(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%s/%s", (const wchar_t *)SliceToken::INTERSECTION, 
						 (const wchar_t *)mLHS->ToStringUnencrypted(), (const wchar_t *)mRHS->ToStringUnencrypted());
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

STDMETHODIMP CIntersectionTimeSlice::ToStringUnencrypted(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		wchar_t buf [512];
		swprintf_s(buf, 512, L"%s/%s/%s", (const wchar_t *)SliceToken::INTERSECTION, 
						 (const wchar_t *)mLHS->ToStringUnencrypted(), (const wchar_t *)mRHS->ToStringUnencrypted());
    *pVal = _bstr_t(buf).copy();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CIntersectionTimeSlice::FromString(ISliceLexer* apLexer)
{
	if (!apLexer)
		return E_POINTER;
	try
	{
		MTHIERARCHYREPORTSLib::ISliceLexerPtr pLexer(apLexer);
		if(SliceToken::INTERSECTION != pLexer->GetNextToken()) 
		{
			char buf [512];
			sprintf_s(buf, 512, "Parse Error: Expected token %s", (const char *)SliceToken::INTERSECTION);
			return Error(buf);
		}
		MTHIERARCHYREPORTSLib::ISliceFactoryPtr pSliceFactory(__uuidof(MTHIERARCHYREPORTSLib::SliceFactory));
		mLHS = pSliceFactory->GetSlice(pLexer);
		mRHS = pSliceFactory->GetSlice(pLexer);
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CIntersectionTimeSlice::GenerateQueryPredicate(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		_bstr_t pred = mLHS->GenerateQueryPredicate();
		pred += L" AND ";
    pred += mRHS->GenerateQueryPredicate();
		*pVal = pred.copy();
	} 
	catch(_com_error & e)
	{
    return returnHierarchyReportError(e);
	}

	return S_OK;
}

STDMETHODIMP CIntersectionTimeSlice::Equals(IViewSlice* apSlice, VARIANT_BOOL *pVal)
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
			MTHIERARCHYREPORTSLib::IIntersectionTimeSlicePtr pCast(pSlice);
			if(NULL != pCast &&
         mRHS->Equals(pCast->RHS) &&
         mLHS->Equals(pCast->LHS))
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

STDMETHODIMP CIntersectionTimeSlice::Clone(IViewSlice* *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		MTHIERARCHYREPORTSLib::IIntersectionTimeSlicePtr This(this);
		MTHIERARCHYREPORTSLib::IIntersectionTimeSlicePtr clone(__uuidof(MTHIERARCHYREPORTSLib::IntersectionTimeSlice));
		clone->LHS = MTHIERARCHYREPORTSLib::ITimeSlicePtr(This->LHS->Clone());
		clone->RHS = MTHIERARCHYREPORTSLib::ITimeSlicePtr(This->RHS->Clone());
		*pVal = reinterpret_cast<IIntersectionTimeSlice *> (clone.Detach());
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	return S_OK;
}

STDMETHODIMP CIntersectionTimeSlice::GetTimeSpan(DATE * pMinDate, DATE * pMaxDate)
{
	if (!pMinDate || !pMaxDate)
		return E_POINTER;

	try
	{
		// TODO: Figure out what the correct thing to do is
		DATE lhsMin, lhsMax, rhsMin, rhsMax;

		mLHS->GetTimeSpan(&lhsMin, &lhsMax);
		mRHS->GetTimeSpan(&rhsMin, &rhsMax);

		*pMinDate = lhsMin < rhsMin ? lhsMin : rhsMin;
		*pMaxDate = lhsMax < rhsMax ? rhsMax : lhsMax;
	}
	catch(_com_error & e)
	{
    return returnHierarchyReportError(e);
	}

	return S_OK;
}

