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
// COMProductViewChild.cpp : Implementation of CCOMProductViewChild
#include "StdAfx.h"
#include "COMDBObjects.h"
#include "COMProductViewChild.h"
#include <DBViewHierarchy.h>
#include <DBProductView.h>
#include <DBProductViewProperty.h>
#include <DBRowset.h>
#include <DBConstants.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <DBMiscUtils.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMProductViewChild

CCOMProductViewChild::CCOMProductViewChild()
: mpView(NULL), mAcctID(-1), 
  mViewID(-1), mSessionID(-1), mIntervalID(-1)
{
}

CCOMProductViewChild::~CCOMProductViewChild()
{
  // don't delete the view ... it doesnt belong to you ...
  mpView = NULL ;
}

STDMETHODIMP CCOMProductViewChild::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMProductViewChild,
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
//                ???         - Unable to get product view child display items.
// Description:   The Init method initializes the product view child rowset with the
//  specified view id, account id, session id, and interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewChild::Init(BSTR aLangCode, BSTR pQueryExtension)
{
  // local variables ...
  char* buffer = NULL;
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;

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

		// find the view ...
		bRetCode = aHierarchy->FindView (mViewID, (DBView * &) mpView) ;
		if (bRetCode == FALSE)
		{
			const ErrorObject *pError = aHierarchy->GetLastError() ;
			buffer = "Unable to find view in view hierarchy";
			mLogger->LogVarArgs (LOG_ERROR,  
				"Unable to find view in view hierarchy for view ID <%d>", mViewID) ;
			return Error ("Unable to find view in view hierarchy", 
				IID_ICOMProductView, pError->GetCode()) ;
		}
		else
		{      
			// get the display items ...
			bRetCode = mpView->GetDisplayItems(mAcctID, mIntervalID, mSessionID, 
				mLangCode, mpQueryExtension, mpRowset) ;
			if (bRetCode == FALSE)
			{
				const ErrorObject *pError = mpView->GetLastError() ;
				nRetVal = pError->GetCode() ;
				mLogger->LogVarArgs (LOG_ERROR,  
					"Unable to get product view child display items. Error = %x", nRetVal) ;
				return Error ("Unable to get product view child display items", 
					IID_ICOMProductView, nRetVal) ;
			}
		}
	}
	catch(ErrorObject& ) {
		return Error("Could not obtain account specific view hierarchy information");
	}
  return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	Sort
// Arguments:     aPropertyName - the property name to sort on
//                aSortOrder - the sort order
// Return Value:  
// Errors Raised: 80040005  - Sort() failed. Invalid property name
//                80040005  - Sort() failed. Invalid sort order
//                ???       - Sort() failed. Unable to sort the rowset
// Description:   The Sort method sorts the product view child rowset by the
//  property name passed in the direction passed.
// ----------------------------------------------------------------

STDMETHODIMP CCOMProductViewChild::Sort(BSTR aPropertyName, ::MTSortOrder aSortOrder)
{
  DBProductViewProperty *pProperty=NULL ;
  std::wstring wstrSortString ;
  std::wstring wstrPropertyName ;

  // remove the c_ if present ...
  wstrPropertyName = aPropertyName ;
  int index = wstrPropertyName.find (L"c_", 0) ;
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
  // validate the property name for the product view ...
  BOOL bRetCode = mpView->FindProperty (wstrPropertyName, pProperty) ;
  if (bRetCode == FALSE)
  {
    mLogger->LogVarArgs (LOG_ERROR,  
        L"Sort() failed. Invalid property name. Name = %s", aPropertyName) ;
    return Error ("Sort() failed. Invalid property name", 
      IID_ICOMProductView, E_FAIL) ;
  }
  // construct the sort string ... rst.Sort = "au_lname ASC, au_fname ASC"
  wstrSortString = pProperty->GetColumnName() ;

	return MTRowSetImpl<ICOMProductViewChild, &IID_ICOMProductViewChild, &LIBID_COMDBOBJECTSLib>::Sort(
		const_cast<wchar_t*>((const wchar_t*)wstrSortString.c_str()),aSortOrder);

}


STDMETHODIMP CCOMProductViewChild::Refresh ()
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
STDMETHODIMP CCOMProductViewChild::GetProperties(LPDISPATCH * pPropCollection)
{
	// local variables
  HRESULT nRetVal=S_OK ;
  ICOMPropertyCollection *pCOMProperties;

	// create a summary view object ...
  nRetVal = CoCreateInstance (CLSID_COMPropertyCollection, NULL, CLSCTX_INPROC_SERVER,
    IID_ICOMPropertyCollection, (void **) pPropCollection) ;
  if (!SUCCEEDED(nRetVal))
  {
    pPropCollection = NULL ;
    mLogger->LogThis (LOG_ERROR, 
      "Unable to create instance of the property collection COM object.") ;
    return Error ("Unable to create property collection COM object.", 
          IID_ICOMProductViewChild, nRetVal) ;
  }
  else
  {
    // do a queryinterface to get the interface ...
    nRetVal = (*pPropCollection)->QueryInterface (IID_ICOMPropertyCollection, 
      reinterpret_cast<void**>(&pCOMProperties)) ;
    if (!SUCCEEDED(nRetVal))
    {
      (*pPropCollection)->Release(); // release the object created by CoCreateInstance
      pPropCollection = NULL ;
      mLogger->LogThis (LOG_ERROR, 
        "Unable to get the interface for the property collection") ;
      return Error ("Unable to get the interface for the property collection.", 
        IID_ICOMProductViewChild, nRetVal) ;
    }
    
    // set the account id 
    nRetVal = pCOMProperties->put_ViewID ((long) mViewID) ;
    if (!SUCCEEDED(nRetVal))
    {
      pCOMProperties->Release(); // release the object created by CoCreateInstance
      (*pPropCollection)->Release(); 
      pPropCollection = NULL ;
      mLogger->LogThis (LOG_ERROR, 
        "Unable to set view id in the property collection") ;
      return Error ("Unable to set view id in the property collection", 
          IID_ICOMProductViewChild, nRetVal) ;
    }
    else
    {
      // call init ...
      nRetVal = pCOMProperties->Init() ;
      if (!SUCCEEDED(nRetVal))
      {
        pCOMProperties->Release(); // release the object created by CoCreateInstance
        (*pPropCollection)->Release(); 
        pPropCollection = NULL ;
        mLogger->LogThis (LOG_ERROR, "Unable to initialize the property collection") ;
        return Error ("Unable to initialize the property collection", 
          IID_ICOMProductViewChild, nRetVal) ;
      }
    }
  }
  // release the ref ...
  pCOMProperties->Release(); 

	return nRetVal;
}
  
// ----------------------------------------------------------------
// Name:     	IntervalID
// Arguments:     pVal - the interval id
// Return Value:  
// Errors Raised: 
// Description:   The Interval ID property gets the interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewChild::get_IntervalID(long * pVal)
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
STDMETHODIMP CCOMProductViewChild::put_IntervalID(long newVal)
{
	mIntervalID = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	AccountID
// Arguments:     pVal - the account id
// Return Value:  
// Errors Raised: 
// Description:   The AccountID property gets the account id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewChild::get_AccountID(long * pVal)
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
STDMETHODIMP CCOMProductViewChild::put_AccountID(long newVal)
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
STDMETHODIMP CCOMProductViewChild::get_ViewID(long * pVal)
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
STDMETHODIMP CCOMProductViewChild::put_ViewID(long newVal)
{
	mViewID = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	SessionID
// Arguments:     pVal - the session id
// Return Value:  
// Errors Raised: 
// Description:   The SessionID property gets the session id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewChild::get_SessionID(long * pVal)
{
	*pVal = mSessionID;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	SessionID
// Arguments:     newVal - the session id
// Return Value:  
// Errors Raised: 
// Description:   The SessionID property sets the session id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMProductViewChild::put_SessionID(long newVal)
{
	mSessionID = newVal;
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
STDMETHODIMP CCOMProductViewChild::get_Value(VARIANT arIndex, VARIANT * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  _variant_t vtIndex ;

  // convert the index ...
  vtIndex = ConvertPropertyName (arIndex) ;
	
	return MTRowSetImpl<ICOMProductViewChild, &IID_ICOMProductViewChild, &LIBID_COMDBOBJECTSLib>::get_Value(vtIndex,pVal);
}


STDMETHODIMP CCOMProductViewChild::get_PopulatedRecordSet(IDispatch** pDisp)
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


