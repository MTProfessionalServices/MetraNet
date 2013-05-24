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
// COMProductViewSummary.cpp : Implementation of CCOMProductViewSummary
#include "StdAfx.h"
#include "COMDBObjects.h"
#include "COMProductViewSummary.h"
#include <DBViewHierarchy.h>
#include <DBProductView.h>
#include <DBRowset.h>
#include <DBConstants.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <DBMiscUtils.h>

#import <COMDBObjects.tlb> rename( "EOF", "RowsetEOF" )
_COM_SMARTPTR_TYPEDEF(IDispatch, __uuidof(IDispatch));


/////////////////////////////////////////////////////////////////////////////
// CCOMProductViewSummary
CCOMProductViewSummary::CCOMProductViewSummary()
: mpView(NULL), mAcctID(-1), 
mViewID(-1), mSessionID(-1), mIntervalID(-1)
{
}

CCOMProductViewSummary::~CCOMProductViewSummary()
{
  // don't delete the view ... it doesnt belong to you ...
  mpView = NULL ;
}

STDMETHODIMP CCOMProductViewSummary::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMProductViewSummary,
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
// Return Value:  
// Errors Raised: ???         - Unable to find view in view hierarchy.
//                ???         - Unable to get product view summary display items.
// Description:   The Init method initializes the product view summary rowset with the
//  specified view id, account id, session id, and interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewSummary::Init(BSTR aLangCode)
{
  // local variables ...
  char* buffer = NULL;
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  
  // copy the lang code ...
  mLangCode = aLangCode ;

  try {
		MTautoptr<MTPCViewHierarchy> aHierarchy = mVHinstance->GetAccHierarchy(mAcctID,mIntervalID,mLangCode.c_str());
		if(!aHierarchy) {
			mLogger->LogVarArgs (LOG_ERROR,  
				"Unable to get account view hierarchy for id_acc = %d and interval %d",mAcctID,mIntervalID);
				return Error("Failed to get account view hierarchy");
		}

		// find the view ...
		bRetCode = aHierarchy->FindView (mViewID, (DBView * &) mpView) ;
		if (bRetCode == FALSE)
		{
			const ErrorObject *pError = aHierarchy->GetLastError() ;
			buffer = "Unable to find view in view hierarchy";
			mLogger->LogVarArgs (LOG_ERROR, "Unable to find view in view hierarchy for view ID <%d>", mViewID) ;
			return Error (buffer, IID_ICOMProductViewSummary, pError->GetCode()) ;
		}
		else
		{      
			// get the display items ...
			bRetCode = mpView->GetDisplayItems(mAcctID, mIntervalID, mSessionID, 
				mLangCode, mpRowset) ;
			if (bRetCode == FALSE)
			{
				const ErrorObject *pError = mpView->GetLastError() ;
				nRetVal = pError->GetCode() ;
				mLogger->LogVarArgs (LOG_ERROR,  
					"Unable to get product view summary display items. Error = %x", nRetVal) ;
				return Error ("Unable to get product view summary display items", 
					IID_ICOMProductViewSummary, nRetVal) ;
			}
		}
	}
	catch(ErrorObject& ) {
		return Error("Could not obtain account specific view hierarchy information");
	}
  
  return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	GetContents
// Arguments:     pQueryExtenstion - the extenstion that is appended to the query
//                pView - the product view children summary rowset
// Return Value:  the product view children summary rowset
// Errors Raised: ???         - Unable to get view id out of product view item
//                ???         - Unable to create product view child COM object
//                ???         - Unable to get the interface for the product view child.
//                ???         - Unable to set account id in product view child
//                ???         - Unable to set view id in product view child
//                ???         - Unable to set interval id in product view child
//                ???         - Unable to set session id in product view child
//                ???         - Unable to initialize product view child
// Description:   The GetContents method gets the product view child
//  rowset for the specified view id, account id, interval id, and session id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewSummary::GetContents(BSTR pQueryExtension, LPDISPATCH * pView)
{
	try {
		int nViewID ;
		if (!mpRowset->GetIntValue (DB_VIEW_ID, nViewID))
		{
			const ErrorObject *pError = mpRowset->GetLastError() ;
			long nRetVal = pError->GetCode() ;
			mLogger->LogVarArgs (LOG_ERROR,  
				"Unable to get view id out of product view item. Error = %x", nRetVal) ;
			return Error ("Unable to get view id out of product view item", 
				IID_ICOMProductViewSummary, nRetVal) ;
		}
		
		COMDBOBJECTSLib::ICOMProductViewChildPtr pCOMProductViewChild(__uuidof(COMProductViewChild));
		pCOMProductViewChild->PutAccountID(mAcctID);
		pCOMProductViewChild->PutIntervalID(mIntervalID);
		pCOMProductViewChild->PutViewID(nViewID);
		pCOMProductViewChild->PutSessionID(mSessionID);
		pCOMProductViewChild->Init(_bstr_t(mLangCode.c_str()), pQueryExtension);
		IDispatchPtr pDisp = pCOMProductViewChild;
		*pView = pDisp.Detach();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	IntervalID
// Arguments:     pVal - the interval id
// Return Value:  
// Errors Raised: 
// Description:   The Interval ID property gets the interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewSummary::get_IntervalID(long * pVal)
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
STDMETHODIMP CCOMProductViewSummary::put_IntervalID(long newVal)
{
	mIntervalID = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	SessionID
// Arguments:     pVal - the session id
// Return Value:  
// Errors Raised: 
// Description:   The SessionID property gets the session id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewSummary::get_SessionID(long * pVal)
{
	*pVal = (long) mSessionID;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	SessionID
// Arguments:     newVal - the session id
// Return Value:  
// Errors Raised: 
// Description:   The SessionID property sets the session id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewSummary::put_SessionID(long newVal)
{
	mSessionID = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	AccountID
// Arguments:     pVal - the account id
// Return Value:  
// Errors Raised: 
// Description:   The AccountID property gets the account id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewSummary::get_AccountID(long * pVal)
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
STDMETHODIMP CCOMProductViewSummary::put_AccountID(long newVal)
{
	mAcctID = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	ViewID
// Arguments:     pVal - the view id
// Return Value:  
// Errors Raised: 
// Description:   The ViewID property gets the view id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewSummary::get_ViewID(long * pVal)
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
STDMETHODIMP CCOMProductViewSummary::put_ViewID(long newVal)
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
STDMETHODIMP CCOMProductViewSummary::get_Value(VARIANT arIndex, VARIANT * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  _variant_t vtIndex ;

  // convert the index ...
  vtIndex = ConvertPropertyName (arIndex) ;

	return MTRowSetImpl<ICOMProductViewSummary, &IID_ICOMProductViewSummary, &LIBID_COMDBOBJECTSLib>::get_Value(vtIndex,pVal);
}

