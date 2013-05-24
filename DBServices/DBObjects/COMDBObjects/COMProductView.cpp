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
// COMProductView.cpp : Implementation of CCOMProductView
#include "StdAfx.h"
#include "COMDBObjects.h"
#include "COMProductView.h"
#include <DBViewHierarchy.h>
#include <DBRowset.h>
#include <DBConstants.h>
#include <DBProductView.h>
#include <DBProductViewProperty.h>
#include <errobj.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <DBMiscUtils.h>


#import <COMDBObjects.tlb> rename( "EOF", "RowsetEOF" )
_COM_SMARTPTR_TYPEDEF(IDispatch, __uuidof(IDispatch));

/////////////////////////////////////////////////////////////////////////////
// CCOMProductView

CCOMProductView::CCOMProductView()
: mpView(NULL),mAcctID(-1), 
  mViewID(-1), mIntervalID(-1)
{
}

CCOMProductView::~CCOMProductView()
{
  mpView = NULL ;
}

STDMETHODIMP CCOMProductView::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMProductView,
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
// Errors Raised: ???         - Unable to find view in view hierarchy.
//                ???         - Unable to get product view display items.
// Description:   The Init method initializes the product view rowset with the
//  specified view id, account id, and interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductView::Init(BSTR aLangCode, BSTR pQueryExtension)
{
  // local variables ...
  char* buffer = NULL;
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  const char* procName = "COMProductView::Init";
	long aInstanceID = 0;

  // copy the query extenstion ...
  mpQueryExtension = pQueryExtension ;
  mLangCode = aLangCode ;

	try {

		MTautoptr<MTPCViewHierarchy> aHierarchy = mVHinstance->GetAccHierarchy(mAcctID,mIntervalID,mLangCode.c_str());
		if(!aHierarchy) {
			mLogger->LogVarArgs (LOG_ERROR,  
				"Unable to get account view hierarchy for id_acc = %d and interval %d",mAcctID,mIntervalID);
				return Error("Failed to get account view hierarchy");
		}

		// translate the view ID if necessary
		if(mViewID < 0) {
			// more hackery... yum yum.  Because the ID is negative, we know it is a
			// priceable item instance ID!
			aInstanceID = -mViewID;
			if(!mVHinstance->TranslateID(mViewID,mViewID)) {
				mLogger->LogVarArgs(LOG_ERROR,"Unable to translate product catalog view id %d",mViewID);
				return Error("Unable to translate product catalog view id");
			}
		}

		bRetCode = aHierarchy->FindView (mViewID, (DBView * &) mpView) ;
		if (bRetCode == FALSE)
		{
			const ErrorObject *pError = aHierarchy->GetLastError() ;
			buffer = "Unable to find view in view hierarchy";
			mLogger->LogVarArgs(LOG_ERROR, "Unable to find view in view hierarchy for view ID <%d>", mViewID);
			return Error (buffer, IID_ICOMProductView, pError->GetCode()) ;
		}
		else
		{
			// get the display items ...
			bRetCode = mpView->GetDisplayItems(mAcctID, mIntervalID,mLangCode,
				mpQueryExtension, mpRowset,aInstanceID) ;
			if (bRetCode == FALSE)
			{
				const ErrorObject *pError = mpView->GetLastError() ;
				nRetVal = pError->GetCode() ;
				mLogger->LogVarArgs (LOG_ERROR,  
					"Unable to get product view display items. Error = %x", nRetVal) ;
				return Error ("Unable to get product view display items", 
					IID_ICOMProductView, nRetVal) ;
			}
		}
	}
	catch(ErrorObject& ) {
		return Error("Could not obtain account specific view hierarchy information");
	}
  return nRetVal;
}

// ----------------------------------------------------------------
// Name:     	GetChildrenSummary
// Arguments:     pView - the product view children summary rowset
// Return Value:  the product view children summary rowset
// Errors Raised: ???         - Unable to get session id out of product view item
//                ???         - Unable to create product view summary COM object
//                ???         - Unable to get the interface for the product view summary.
//                ???         - Unable to set account id in product view summary
//                ???         - Unable to set view id in product view summary
//                ???         - Unable to set interval id in product view summary
//                ???         - Unable to set session id in product view summary
//                ???         - Unable to initialize product view summary
// Description:   The GetChildrenSummary method gets the product view children summary 
//  rowset for the specified view id, account id, interval id, and session id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductView::GetChildrenSummary(LPDISPATCH * pView)
{
  BOOL bRetCode=TRUE ;
  int nSessionID ;

	try {
		bRetCode = mpRowset->GetIntValue (DB_SESSION_ID, nSessionID) ;
		if (bRetCode == FALSE)
		{
			const ErrorObject *pError = mpRowset->GetLastError() ;
			long nRetVal = pError->GetCode() ;
			mLogger->LogVarArgs (LOG_ERROR,  
				"Unable to get session id out of product view item. Error = %x", nRetVal) ;
			return Error ("Unable to get session id out of product view item", 
				IID_ICOMProductView, nRetVal) ;
		}

		COMDBOBJECTSLib::ICOMProductViewSummaryPtr pCOMProductViewSummary(__uuidof(COMProductViewSummary));
		pCOMProductViewSummary->PutAccountID(mAcctID);
		pCOMProductViewSummary->PutViewID(mViewID);
		pCOMProductViewSummary->PutIntervalID(mIntervalID);
		pCOMProductViewSummary->PutSessionID(nSessionID);
    pCOMProductViewSummary->Init(_bstr_t(mLangCode.c_str())) ;
		*pView = IDispatchPtr(pCOMProductViewSummary).Detach();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	Sort
// Arguments:     aPropertyName - the property name to sort on
//                aSortOrder - the sort order
// Return Value:  
// Errors Raised: 80040005  - Sort() failed. Invalid property name
//                80040005  - Sort() failed. Invalid sort order
//                ???       - Sort() failed. Unable to sort the rowset
// Description:   The Sort method sorts the product view rowset by the
//  property name passed in the direction passed.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductView::Sort(BSTR aPropertyName, ::MTSortOrder aSortOrder)
{
  DBProductViewProperty *pProperty=NULL ;
  std::wstring wstrSortString ;
  std::wstring wstrPropertyName ;
  std::wstring wstrViewType ;

  // get the view type ...
  wstrPropertyName = aPropertyName ;
  wstrViewType = mpView->GetViewType() ;
  //if (wstrViewType.compareTo (DB_DATAANALYSIS_VIEW, RWWString::ignoreCase) != 0)
  if (_wcsicmp(wstrViewType.c_str(), DB_DATAANALYSIS_VIEW) != 0)
  {
    // remove the c_ if present ...
    //int index = wstrPropertyName.index (L"c_", 0, RWWString::ignoreCase) ;
    unsigned int index = wstrPropertyName.find(L"c_", 0);
    if (index == 0)
    {
      // remove the c_ ...
      wstrPropertyName = wstrPropertyName.erase (0, 2) ;
    }
	else
    {
		index = wstrPropertyName.find(L"C_", 0);
		if (index == 0)
			wstrPropertyName = wstrPropertyName.erase(0, 2);
    }
  }
  // validate the property name for the product view ...
  BOOL bRetCode = mpView->FindProperty (wstrPropertyName, pProperty) ;
  if (bRetCode == FALSE)
  {
    mLogger->LogVarArgs (LOG_ERROR,  
        L"Sort() failed. Invalid property name. Name = %s", aPropertyName) ;
    return Error ("Sort() failed. Invalid property name", 
      IID_ICOMProductView, E_FAIL) ;
  }
  wstrSortString = pProperty->GetColumnName() ;


	return MTRowSetImpl<ICOMProductView, &IID_ICOMProductView, &LIBID_COMDBOBJECTSLib>::Sort(
		const_cast<wchar_t*>((const wchar_t*)wstrSortString.c_str()),aSortOrder);
}

// ----------------------------------------------------------------
// Name:     	Refresh
// Arguments:    
// Return Value:  
// Description:   Refresh method refreshes the internal DBRowset object
// ----------------------------------------------------------------

STDMETHODIMP CCOMProductView::Refresh()
{
  // apply the filter criteria ...
  BOOL bRetCode = mpRowset->Refresh() ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mpRowset->GetLastError() ;
    HRESULT nRetVal = pError->GetCode() ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Refresh() failed. Unable to refresh the rowset. Error = %x", nRetVal) ;
    return Error ("Refresh() failed. Unable to refresh the rowset", 
      IID_ICOMProductViewChild, nRetVal) ;
  }

  return S_OK ;
}


// ----------------------------------------------------------------
// Name:     	GetProperties
// Arguments:     pPropCollection - the property collection
// Return Value:  the property collection    
// Errors Raised: ??? - Unable to create property collection COM object.
//                ??? - Unable to get the interface for the property collection
//                ??? - Unable to set view id in the property collection
//                ??? - Unable to initialize the property collection
// Description:   The GetProperties method gets the property collection 
//  for the specified view id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductView::GetProperties(LPDISPATCH * pPropCollection)
{
	try {
		COMDBOBJECTSLib::ICOMPropertyCollectionPtr pCOMProperties(__uuidof(COMPropertyCollection));
		pCOMProperties->PutViewID(mViewID);
		pCOMProperties->Init();
		IDispatchPtr pDisp = pCOMProperties;
		*pPropCollection = pDisp.Detach();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	AccountID
// Arguments:     pVal - the account id
// Return Value:  
// Errors Raised: 
// Description:   The AccountID property gets the account id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductView::get_AccountID(long * pVal)
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
STDMETHODIMP CCOMProductView::put_AccountID(long newVal)
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
STDMETHODIMP CCOMProductView::get_ViewID(long * pVal)
{
	*pVal = mViewID;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	ViewID
// Arguments:     newVal - the view id
// Return Value:  
// Errors Raised: 
// Description:   The ViewID property sets the view id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductView::put_ViewID(long newVal)
{
	mViewID = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	IntervalID
// Arguments:     pVal - the interval id
// Return Value:  
// Errors Raised: 
// Description:   The Interval ID property gets the interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductView::get_IntervalID(long * pVal)
{
	*pVal = mIntervalID;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	IntervalID
// Arguments:     newVal - the interval id
// Return Value:  
// Errors Raised: 
// Description:   The Interval ID property gets the interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductView::put_IntervalID(long newVal)
{
	mIntervalID = newVal;
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
STDMETHODIMP CCOMProductView::get_Value(VARIANT arIndex, VARIANT * pVal)
{
  _variant_t vtValue ;
  _variant_t vtIndex ;

  // get the view type ...
  std::wstring wstrType = mpView->GetViewType () ;
  //if (wstrType.compareTo (DB_DATAANALYSIS_VIEW, RWWString::ignoreCase) != 0) {
  if (_wcsicmp(wstrType.c_str(), DB_DATAANALYSIS_VIEW) != 0) {
    // convert the index ...
    vtIndex = ConvertPropertyName (arIndex) ;
  }
  else {
    vtIndex = arIndex ;
  }

	return MTRowSetImpl<ICOMProductView, &IID_ICOMProductView, &LIBID_COMDBOBJECTSLib>::get_Value(vtIndex,pVal);
}



// ----------------------------------------------------------------
// Name:     	get_PopulatedRecordSet
// Arguments:     apFilterObj - IMTFilter object
// Return Value:  
// Description:   The Filter method filters the internal DBRowset 
//								object based on criteria passed in  apFilterObject param (IMTFilter)
// ----------------------------------------------------------------

STDMETHODIMP CCOMProductView::get_PopulatedRecordSet(IDispatch** pDisp)
{
	ASSERT(pDisp);
	if(!pDisp) return E_POINTER;
	HRESULT hr = S_OK;

	try 
  {
		_RecordsetPtr aRecordSet = ((DBSQLRowset *)mpRowset)->GetRecordsetPtr();
		hr = aRecordSet.QueryInterface(IID_IDispatch,(void**)pDisp);
	}
	catch(_com_error& e) 
  {
		return ReturnComError(e);
	}
	return S_OK;
}

