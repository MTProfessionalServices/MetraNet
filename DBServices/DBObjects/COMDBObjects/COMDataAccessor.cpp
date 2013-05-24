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
// COMDataAccessor.cpp : Implementation of CCOMDataAccessor
#include "StdAfx.h"
#include "COMDBObjects.h"
#include "COMDataAccessor.h"
#include <DBInMemRowset.h>
#include <DBViewHierarchy.h>
#include <DBUsageCycle.h>
#include <DBConstants.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <mtparamnames.h>
#include <mtglobal_msg.h>
#include <mtcomerr.h>
#include <UsageServerConstants.h>
#include <mttime.h>

// import the rowset tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
using namespace ROWSETLib  ;
#import <COMDBObjects.tlb> rename( "EOF", "RowsetEOF" )

FIELD_DEFINITION VIEW_COLLECTION_FIELDS[] =
{
	{ DB_VIEW_ID, DB_INTEGER_TYPE },
	{ DB_VIEW_NAME, DB_STRING_TYPE },
	{ DB_VIEW_TYPE, DB_STRING_TYPE },
  { DB_DESCRIPTION_ID, DB_INTEGER_TYPE }
} ;

/////////////////////////////////////////////////////////////////////////////
// CCOMDataAccessor

CCOMDataAccessor::CCOMDataAccessor()
: mpUsageCycle(NULL), mAcctID(-1), mIntervalID(-1), mLangCode("US")
{
    MetraTech_DataAccess_MaterializedViews::IManagerPtr mvm;
    mvm = new MetraTech_DataAccess_MaterializedViews::IManagerPtr(__uuidof(MetraTech_DataAccess_MaterializedViews::Manager));
    mvm->Initialize();
    mIsMVSupportEnabled = (mvm->GetIsMetraViewSupportEnabled() == VARIANT_TRUE);
}

CCOMDataAccessor::~CCOMDataAccessor()
{
  // release the instance ...
  if (mpUsageCycle != NULL)
  {
    mpUsageCycle->ReleaseInstance() ;
  }
} 

STDMETHODIMP CCOMDataAccessor::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMDataAccessor,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     	AccountID
// Arguments:     pVal - the account id
// Return Value:  
// Errors Raised: 
// Description:   The Account ID property gets the account id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMDataAccessor::get_AccountID(long * pVal)
{
	*pVal = (long) mAcctID;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	AccountID
// Arguments:     newVal - the account id
// Return Value:  
// Errors Raised: 
// Description:   The Account ID property sets the account id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMDataAccessor::put_AccountID(long newVal)
{
	mAcctID = (int) newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	IntervalID
// Arguments:     pVal - the interval id
// Return Value:  
// Errors Raised: 
// Description:   The Interval ID property gets the interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMDataAccessor::get_IntervalID(long * pVal)
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
STDMETHODIMP CCOMDataAccessor::put_IntervalID(long newVal)
{
	mIntervalID = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	LanguageCode
// Arguments:     newVal - the language code
// Return Value:  
// Errors Raised: 
// Description:   The LanguageCode property sets the language code..
// ----------------------------------------------------------------
STDMETHODIMP CCOMDataAccessor::put_LanguageCode(BSTR newVal)
{
	mLangCode = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	GetSummaryView
// Arguments:     pQueryExtenstion - The query extenstion to add to the query
//                pView - the summary view rowset
// Return Value:  the summary view rowset 
// Errors Raised: 0xE1500008L - Unable to get usage cycle collection.
//                ???         - Unable to create summary view COM object
//                ???         - Unable to get the interface for the summary view.
//                ???         - Unable to set the account id in the summary view.
//                ???         - Unable to set the interval id in the summary view.
//                ???         - Unable to initialize summary view.
// Description:   The GetSummaryView method gets the sumary view rowset for the 
//  specified account id and interval id.
// ----------------------------------------------------------------

_COM_SMARTPTR_TYPEDEF(IDispatch, __uuidof(IDispatch));

STDMETHODIMP CCOMDataAccessor::GetSummaryView(BSTR pQueryExtension, LPDISPATCH * pView)
{
  // local variables
  HRESULT nRetVal=S_OK ;

    // get an instance to the usage cycle collection ...
  if (mpUsageCycle == NULL)
  {
    mpUsageCycle = DBUsageCycleCollection::GetInstance() ;
    if (mpUsageCycle == NULL)
    {
      mLogger->LogThis (LOG_ERROR, "Unable to get usage cycle collection.") ;
      return Error ("Unable to get usage cycle collection", 
        IID_ICOMDataAccessor, DB_ERR_NO_INSTANCE) ;
    }
  }

	try {
		// clear any cached entries when we get the summary view
		mVHinstance->ClearEntry(mAcctID,mIntervalID);

		MTautoptr<MTPCViewHierarchy> aHierarchy = mVHinstance->GetAccHierarchy(mAcctID,mIntervalID,mLangCode);
		if(!aHierarchy) {
			mLogger->LogVarArgs (LOG_ERROR,  
				"Unable to get account view hierarchy for id_acc = %d and interval %d",mAcctID,mIntervalID);
				return Error("Failed to get account view hierarchy");
		}

		COMDBOBJECTSLib::ICOMSummaryViewPtr pCOMSummaryView(__uuidof(COMSummaryView));
		pCOMSummaryView->PutAccountID(mAcctID);
		pCOMSummaryView->PutIntervalID(mIntervalID);
    nRetVal = pCOMSummaryView->Init(mLangCode, pQueryExtension);
		IDispatchPtr aDispTemp = pCOMSummaryView;
		*pView = aDispTemp.Detach();
		
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return nRetVal;
}

// ----------------------------------------------------------------
// Name:     	GetProductView
// Arguments:     aViewID - the view id
//                pQueryExtenstion - The query extenstion to add to the query
// Return Value:  the product view rowset 
// Errors Raised: 0xE1500008L - Unable to get usage cycle collection.
//                ???         - Unable to create product view COM object.
//                ???         - Unable to get the interface for the product view.
//                ???         - Unable to set the account id in the product view.
//                ???         - Unable to set the interval id in the product view.
//                ???         - Unable to set the view id in the product view.
//                ???         - Unable to initialize product view.
// Description:   The GetProductView method gets the product view rowset for the 
//  specified view id, account id and interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMDataAccessor::GetProductView(long aViewID, BSTR pQueryExtension, LPDISPATCH * pView)
{
	// local variables
  HRESULT nRetVal=S_OK ;

	try {
		COMDBOBJECTSLib::ICOMProductViewPtr pCOMProductView(__uuidof(COMProductView));
		pCOMProductView->PutAccountID(mAcctID);
		pCOMProductView->PutIntervalID(mIntervalID);
		pCOMProductView->PutViewID(aViewID);
    nRetVal = pCOMProductView->Init(mLangCode, pQueryExtension) ;
		IDispatchPtr aDispTemp = pCOMProductView;
		*pView = aDispTemp.Detach();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	return nRetVal;
}

// ----------------------------------------------------------------
// Name:     	GetProductViewItem
// Arguments:     aViewID - the view id
//                aSessionID - the session id
//                pQueryExtenstion - The query extenstion to add to the query
// Return Value:  the product view item rowset 
// Errors Raised: 0xE1500008L - Unable to get usage cycle collection.
//                ???         - Unable to get the interface for the product view item .
//                ???         - Unable to set the account id in the product view.item
//                ???         - Unable to set the interval id in the product view.item
//                ???         - Unable to set the view id in the product view.item
//                ???         - Unable to set the view id in the product view.item
//                ???         - Unable to initialize product view.item
//                ???         - Unable to create product view item COM object.
// Description:   The GetProductViewItem method gets the product view item rowset for the 
//  specified view id, account id, session id and interval id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMDataAccessor::GetProductViewItem(long aViewID, long aSessionID, LPDISPATCH * pView)
{
  // local variables
  HRESULT nRetVal=S_OK ;

	try {
		COMDBOBJECTSLib::ICOMProductViewItemPtr pCOMProductViewItem(__uuidof(COMProductViewItem));
		pCOMProductViewItem->PutAccountID(mAcctID);
		pCOMProductViewItem->PutIntervalID(mIntervalID);
		pCOMProductViewItem->PutViewID(aViewID);
		pCOMProductViewItem->PutSessionID(aSessionID);
    nRetVal = pCOMProductViewItem->Init(mLangCode) ;
		IDispatchPtr aDispTemp = pCOMProductViewItem;
		*pView = aDispTemp.Detach();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	return nRetVal;
}

// ----------------------------------------------------------------
// Name:     	GetLocaleTranslator
// Arguments:     pLocale - the locale translator
// Return Value:  the locale translator    
// Errors Raised: ???       - Unable to create locale translator COM object.
//                ???       - Unable to initialize locale translator.
// Description:   The GetLocaleTranslator method creates a locale translator 
//  for the specified language code.
// ----------------------------------------------------------------
STDMETHODIMP CCOMDataAccessor::GetLocaleTranslator(LPDISPATCH * pLocale)
{
	// local variables
  HRESULT nRetVal=S_OK ;

	try {
		if(mLocaleTranslator) {
			// QI plus add ref
			IDispatchPtr aDispTemp = mLocaleTranslator;
			*pLocale = aDispTemp.Detach();
			
		}
		else {
			mLocaleTranslator.CreateInstance(__uuidof(COMLocaleTranslator));
			mLocaleTranslator->Init(mLangCode);
			// QI plus add ref
			IDispatchPtr aDispTemp = mLocaleTranslator;
			*pLocale = aDispTemp.Detach();
		}
	}
	catch(_com_error& err) {
    mLogger->LogThis (LOG_ERROR, "Unable to initialize locale translator") ;
		return ReturnComError(err);
	}

	return nRetVal;
}

// ----------------------------------------------------------------
// Name:     	GetUsageInterval
// Arguments:     pUsageInterval - the usage interval rowset
// Return Value:  the usage interval rowset
// Errors Raised: ??? - Unable to get usage intervals by account id.
// Description:   The GetUsageInterval method gets the usage interval 
//  rowset for the specified account id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMDataAccessor::GetUsageInterval(LPDISPATCH * pUsageInterval)
{
  HRESULT nRetVal = S_OK ;
  BOOL bRetCode=TRUE ;
  _variant_t vtParam ;

  try
  {
    // create the queryadapter ...
    IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    
    // initialize the queryadapter ...
    _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
    rowset->Init(configPath) ;

    // set the query tag ...
    _bstr_t queryTag = mIsMVSupportEnabled ? "__GET_USAGE_INTERVALS_BY_ACCOUNTID_AND_DATE_DATAMART__"
                                           : "__GET_USAGE_INTERVALS_BY_ACCOUNTID_AND_DATE__";
    rowset->SetQueryTag (queryTag) ;

    // get the gmtime of the server ...
    char gmTimeString[MAX_PATH] ;
    time_t currTime = GetMTTime() ;
    struct tm *gmTime = gmtime (&currTime) ;
    strftime (gmTimeString, MAX_PATH, "%m/%d/%Y %H:%M:%S", gmTime) ;
    _bstr_t bstrTime = gmTimeString ;

    // add the parameters ...
    vtParam = (long) mAcctID ;
    rowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam = bstrTime ;
    rowset->AddParam (MTPARAM_DATE, vtParam) ;
      
    // execute the query ...
    rowset->Execute() ;

    // detach the allocated COM object ...
    *pUsageInterval = rowset.Detach() ;
  }    
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get usage intervals by account id. Error = %x", nRetVal) ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "GetUsageInterval() failed. Error Description = %s", (char*)e.Description()) ;
    return Error ("Unable to get usage intervals by account id.", 
          IID_ICOMDataAccessor, nRetVal) ;

  }
	return nRetVal;
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
STDMETHODIMP CCOMDataAccessor::GetProperties(long ViewID, LPDISPATCH * pPropCollection)
{
	// local variables
  HRESULT nRetVal=S_OK ;

	try {
		COMDBOBJECTSLib::ICOMPropertyCollectionPtr pCOMProperties(__uuidof(COMPropertyCollection));
		pCOMProperties->PutViewID(ViewID);
		pCOMProperties->Init();
		IDispatchPtr aDispTemp = pCOMProperties;
		*pPropCollection = aDispTemp.Detach();

	}
	catch(_com_error& err) {
    mLogger->LogThis (LOG_ERROR, "Unable to initialize the property collection") ;
		return ReturnComError(err);
	}
	return nRetVal;
}


// ----------------------------------------------------------------
// Name:     	GetViewCollection
// Arguments:     pViewCollection - the view collection
// Return Value:  the view collection    
// Errors Raised: ???         - Unable to initialize the rowset for the view collection
//                ???         - Unable to add field definition to the view collection.
//                ???         - Unable to add row to the view collection.
//                ???         - Unable to add view id to the view collection.
//                ???         - Unable to add view type to the view collection.
//                ???         - Unable to add view description id to the view collection.
//                ???         - Unable to create view collection.
// Description:   The GetViewCollection method creates a rowset containing all the view's
//  in the view hierarchy configuration file.
// ----------------------------------------------------------------
STDMETHODIMP CCOMDataAccessor::GetViewCollection(LPDISPATCH * pViewCollection)
{
	return E_NOTIMPL;
}

STDMETHODIMP CCOMDataAccessor::GetInternalPVID(long viewID,long* InternalPVID)
{
	ASSERT(InternalPVID);
	if(viewID > 0) {
		*InternalPVID = viewID;
	}
	else {
		if(!mVHinstance->TranslateID(viewID,*InternalPVID)) {
			return Error("Unable to determine product view ID from product catalog ID");
		}
	}
	return S_OK;
}
