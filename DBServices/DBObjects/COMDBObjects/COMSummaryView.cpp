/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Kevin Fitzgerald
* $Header$
* 
***************************************************************************/
// COMSummaryView.cpp : Implementation of CCOMSummaryView
#include "StdAfx.h"
#include "COMDBObjects.h"
#include "COMSummaryView.h"
#include <DBRowset.h>
#include <DBConstants.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <CodeLookup.h>
#include <DBMiscUtils.h>
#include <mtprogids.h>

#import <NameID.tlb>
#import <COMDBObjects.tlb> rename( "EOF", "RowsetEOF" )
_COM_SMARTPTR_TYPEDEF(IDispatch, __uuidof(IDispatch));

/////////////////////////////////////////////////////////////////////////////
// CCOMSummaryView
CCOMSummaryView::CCOMSummaryView()
: mpView(NULL), mAcctID(-1), 
mIntervalID(-1), mViewID(-1)
{
}

CCOMSummaryView::~CCOMSummaryView()
{
  mpView = NULL ;
}

STDMETHODIMP CCOMSummaryView::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMSummaryView,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     	Init
// Arguments:     aLangCode - the language code
//                pQueryExtension - the query extension
// Return Value:  
// Errors Raised: 0xE1500008L - Unable to get code lookup singleton.
//                0xE1500005L - Unable to find root id of view hierarchy.
//                0xE1500008L - Unable to get view hierarchy.
//                ???         - Unable to find view in view hierarchy.
//                ???         - Unable to get summary view display items.
// Description:   The Init method initializes the summary view rowset with the
//  specified account id, and interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMSummaryView::Init(BSTR aLangCode, BSTR pQueryExtension)
{
  // local variables ...
  char* buffer = NULL;
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;

  // get a copy of the query extension ...
  mQueryExtension = pQueryExtension ;
  mLangCode = aLangCode ;

	try {
		mViewID = -1;
		NAMEIDLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);
		mViewID = nameID->GetNameID("Root");
		ASSERT(mViewID != -1);
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	try {

		// get a fresh copy of the Product catalog view hierarchy object

		MTautoptr<MTPCViewHierarchy> aHierarchy = mVHinstance->GetAccHierarchy(mAcctID,mIntervalID,mLangCode.c_str());
		if(!aHierarchy) {
			mLogger->LogVarArgs (LOG_ERROR,  
				"Unable to get account view hierarchy for id_acc = %d and interval %d",mAcctID,mIntervalID);
				return Error("Failed to get account view hierarchy");
		}

		// find the view ...
		bRetCode = aHierarchy->FindView (mViewID, mpView) ;
		if (bRetCode == FALSE) {
			const ErrorObject *pError = aHierarchy->GetLastError() ;
			buffer = "Unable to find view in view hierarchy";
			mLogger->LogVarArgs (LOG_ERROR,  
				"Unable to find view in view hierarchy for view ID <%d>", mViewID) ;
			return Error (buffer, IID_ICOMSummaryView, pError->GetCode()) ;
		}

		bRetCode = mpView->GetDisplayItems(mAcctID, mIntervalID,
      mLangCode, mQueryExtension, mpRowset);
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpView->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to get summary view display items. Error = %x", nRetVal) ;
      return Error ("Unable to get summary view display items", 
        IID_ICOMSummaryView, nRetVal) ;
    }
	
	}
	catch(ErrorObject& ) {
		return Error("Could not obtain account specific view hierarchy information");
	}

  return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	GetContents
// Arguments:     pView - the summary or product view rowset
// Return Value:  the summary or product view rowset 
// Errors Raised: ???         - Unable to get view id out of summary view item
//                ???         - Unable to get view type out of summary view item
//                ???         - Unable to create summary view COM object
//                ???         - Unable to get the interface for the summary view.
//                ???         - Unable to set the account id in the summary view.
//                ???         - Unable to set the interval id in the summary view.
//                ???         - Unable to initialize summary view.
//                ???         - Unable to create product view COM object.
//                ???         - Unable to get the interface for the product view.
//                ???         - Unable to set the account id in the product view.
//                ???         - Unable to set the interval id in the product view.
//                ???         - Unable to set the view id in the product view.
//                ???         - Unable to initialize product view.
//                ???         - Unable to get contents. Invalid view type
// Description:   The GetContents method gets the summary or product view rowset 
//  for the specified account id, view id and interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMSummaryView::GetContents(LPDISPATCH * pView)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  int nViewID ;
  std::wstring wstrType ;
  _variant_t vtIndex ;

  // get the view id of the current item in the view ...
  vtIndex = DB_VIEW_ID ;
  bRetCode = mpRowset->GetIntValue (vtIndex, nViewID) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mpRowset->GetLastError() ;
    nRetVal = pError->GetCode() ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get view id out of summary view item. Error = %x", nRetVal) ;
    return Error ("Unable to get view id out of summary view item", 
      IID_ICOMSummaryView, nRetVal);
  }
  else
  {
    // get the view type of the current item in the view ...
    vtIndex.Clear() ;
    vtIndex = DB_VIEW_TYPE ;
    bRetCode = mpRowset->GetWCharValue (vtIndex, wstrType) ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to get view type out of summary view item. Error = %x", nRetVal) ;
      return Error ("Unable to get view type out of summary view item", 
       IID_ICOMSummaryView, nRetVal) ;
    }
    else
    {
			try {
				// if the view is a summary view ...
				//if (wstrType.compareTo(DB_SUMMARY_VIEW, RWWString::ignoreCase) == 0)
				if (_wcsicmp(wstrType.c_str(), DB_SUMMARY_VIEW) == 0)
				{
					COMDBOBJECTSLib::ICOMSummaryViewPtr aSummaryView(__uuidof(COMSummaryView));
					aSummaryView->PutAccountID(mAcctID);
					aSummaryView->PutIntervalID (mIntervalID);
					aSummaryView->PutViewID(nViewID);
					aSummaryView->Init(_bstr_t(mLangCode.c_str()), _bstr_t(mQueryExtension.c_str()));
					*pView = IDispatchPtr(aSummaryView).Detach();

				}
				//else if ((wstrType.compareTo(DB_PRODUCT_VIEW, RWWString::ignoreCase) == 0) ||
				//	(wstrType.compareTo(DB_DISCOUNT_VIEW, RWWString::ignoreCase) == 0))
				else if ((_wcsicmp(wstrType.c_str(), DB_PRODUCT_VIEW) == 0) ||
						(_wcsicmp(wstrType.c_str(), DB_DISCOUNT_VIEW) == 0))
				{
					COMDBOBJECTSLib::ICOMProductViewPtr pCOMProductView(__uuidof(COMProductView));
					pCOMProductView->PutAccountID(mAcctID);
					pCOMProductView->PutIntervalID(mIntervalID);
					pCOMProductView->PutViewID (nViewID);
					pCOMProductView->Init(_bstr_t(mLangCode.c_str()), _bstr_t(mQueryExtension.c_str()));
					*pView = IDispatchPtr(pCOMProductView).Detach();
				}
				else
				{
					mLogger->LogVarArgs (LOG_ERROR, 
						"Unable to get contents. Invalid view type = %s", ascii(wstrType.c_str())) ;
					return Error ("Unable to get contents. Invalid view type", 
						IID_ICOMSummaryView, nRetVal) ;
				}
			}
			catch(_com_error& err) {
				return ReturnComError(err);
			}
    }
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	AccountID
// Arguments:     pVal - the account id
// Return Value:  
// Errors Raised: 
// Description:   The AccountID property gets the account id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMSummaryView::get_AccountID(long * pVal)
{
	*pVal = (long) mAcctID;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	AccountID
// Arguments:     newVal - the account id
// Return Value:  
// Errors Raised: 
// Description:   The AccountID property sets the account id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMSummaryView::put_AccountID(long newVal)
{
	mAcctID = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	IntervalID
// Arguments:     pVal - the interval id
// Return Value:  
// Errors Raised: 
// Description:   The Interval ID property gets the interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMSummaryView::get_IntervalID(long * pVal)
{
	*pVal = (long) mIntervalID;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	IntervalID
// Arguments:     newVal - the interval id
// Return Value:  
// Errors Raised: 
// Description:   The Interval ID property gets the interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMSummaryView::put_IntervalID(long newVal)
{
	mIntervalID = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	ViewID
// Arguments:     pVal - the view id
// Return Value:  
// Errors Raised: 
// Description:   The ViewID property gets the view id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMSummaryView::get_ViewID(long * pVal)
{
	*pVal = (long) mViewID;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	ViewID
// Arguments:     newVal - the view id
// Return Value:  
// Errors Raised: 
// Description:   The ViewID property sets the view id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMSummaryView::put_ViewID(long newVal)
{
	mViewID = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     	Value
// Arguments:     vtIndex - the specified column of the rowset
//                pVal - the value of the column
// Return Value:  the value of the column
// Errors Raised: 0xE1500004L - Unable to get the value of a column in the rowset
// Description:   The Value property gets the value of the specified column 
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CCOMSummaryView::get_Value(VARIANT arIndex, VARIANT * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  _variant_t vtIndex ;

  // convert the index ...
  vtIndex = ConvertPropertyName (arIndex);

	return MTRowSetImpl<ICOMSummaryView, &IID_ICOMSummaryView, &LIBID_COMDBOBJECTSLib>::get_Value(vtIndex,pVal);
}

