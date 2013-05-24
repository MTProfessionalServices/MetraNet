// COMDiscountView.cpp : Implementation of CCOMDiscountView
#include "StdAfx.h"
#include "COMDBObjects.h"
#include "COMDiscountView.h"
#include <DBViewHierarchy.h>
#include <DBRowset.h>
#include <DBConstants.h>
#include <DBDiscountView.h>
#include <errobj.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <DBMiscUtils.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMDiscountView

CCOMDiscountView::CCOMDiscountView()
: mpDBViewHierarchy(NULL), mpView(NULL), mpRowset(NULL), mAcctID(-1), 
  mViewID(-1), mIntervalID(-1)
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("Database"), DBOBJECTS_TAG) ;
}

CCOMDiscountView::~CCOMDiscountView()
{
  // release the instance of the view collection ...
  if (mpDBViewHierarchy != NULL)
  {
    mpDBViewHierarchy->ReleaseInstance() ;
  }
  if (mpRowset != NULL)
  {
    delete mpRowset ;
  }
  // don't delete the view ... it doesnt belong to you ...
  mpView = NULL ;
}

STDMETHODIMP CCOMDiscountView::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMDiscountView
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


STDMETHODIMP CCOMDiscountView::Init(BSTR pQueryExtension)
{
  // local variables ...
  char* buffer = NULL;
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  const char* procName = "CCOMDiscountView::Init";

  // get a pointer to the view hierarchy collection ...
  if (mpDBViewHierarchy == NULL)
  {
    mpDBViewHierarchy = DBViewHierarchy::GetInstance(mAcctID,mIntervalID) ;
    if (mpDBViewHierarchy == NULL)
    {
	  buffer = "Unable to get view hierarchy instance";
      mLogger.LogVarArgs (LOG_ERROR, "Unable to get view hierarchy instance for account <%d> and interval <%d>", mAcctID, mIntervalID) ;
      return Error (buffer, IID_ICOMDiscountView, DB_ERR_NO_INSTANCE) ;
    }
  }
  // find the view ...
  bRetCode = mpDBViewHierarchy->FindView (mViewID, mpView) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mpDBViewHierarchy->GetLastError() ;
	buffer = "Unable to find view in view hierarchy"; 
    mLogger.LogVarArgs (LOG_ERROR, buffer);  
    return Error (buffer, IID_ICOMDiscountView, pError->GetCode()) ;
  }
  else
  {      
    // get the display items ...
    bRetCode = mpView->GetDisplayItems(mAcctID, mIntervalID, 
      mpRowset, pQueryExtension) ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpView->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to get product view display items. Error = %x", nRetVal) ;
      return Error ("Unable to get product view display items", 
        IID_ICOMDiscountView, nRetVal) ;
    }
  }
  return nRetVal;
}

STDMETHODIMP CCOMDiscountView::GetProperties(LPDISPATCH * pPropCollection)
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
    mLogger.LogThis (LOG_ERROR, 
      "Unable to create instance of the property collection COM object.") ;
    return Error ("Unable to create property collection COM object.", 
          IID_ICOMDiscountView, nRetVal) ;
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
      mLogger.LogThis (LOG_ERROR, 
        "Unable to get the interface for the property collection") ;
      return Error ("Unable to get the interface for the property collection.", 
        IID_ICOMDiscountView, nRetVal) ;
    }
    
    // set the account id 
    nRetVal = pCOMProperties->put_ViewID ((long) mViewID) ;
    if (!SUCCEEDED(nRetVal))
    {
      pCOMProperties->Release(); // release the object created by CoCreateInstance
      (*pPropCollection)->Release(); 
      pPropCollection = NULL ;
      mLogger.LogThis (LOG_ERROR, 
        "Unable to set view id in the property collection") ;
      return Error ("Unable to set view id in the property collection", 
          IID_ICOMDiscountView, nRetVal) ;
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
        mLogger.LogThis (LOG_ERROR, "Unable to initialize the property collection") ;
        return Error ("Unable to initialize the property collection", 
          IID_ICOMDiscountView, nRetVal) ;
      }
    }
  }
  // release the ref ...
  pCOMProperties->Release(); 

	return nRetVal;
}


STDMETHODIMP CCOMDiscountView::get_AccountID(long * pVal)
{
	*pVal = (long) mAcctID ;

	return S_OK;
}

STDMETHODIMP CCOMDiscountView::put_AccountID(long newVal)
{
	mAcctID = newVal ;

	return S_OK;
}

STDMETHODIMP CCOMDiscountView::get_ViewID(long * pVal)
{
	*pVal = mViewID ;

	return S_OK;
}

STDMETHODIMP CCOMDiscountView::put_ViewID(long newVal)
{
	mViewID = newVal ;

	return S_OK;
}

STDMETHODIMP CCOMDiscountView::get_IntervalID(long * pVal)
{
	*pVal = mIntervalID ;

	return S_OK;
}

STDMETHODIMP CCOMDiscountView::put_IntervalID(long newVal)
{
	mIntervalID = newVal ;

	return S_OK;
}

STDMETHODIMP CCOMDiscountView::MoveNext()
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    bRetCode = mpRowset->MoveNext() ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to move to the next row of the rowset. Error = %x", nRetVal) ;
      return Error ("Unable to move to the next row of the rowset", 
        IID_ICOMDiscountView, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to move to the next record in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to move to the next row of the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::MoveFirst()
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we have a rowset ...
  if (mpRowset != NULL && mpRowset->GetRecordCount()>0)
  {
    bRetCode = mpRowset->MoveFirst() ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to move to the first row of the rowset. Error = %x", nRetVal) ;
      return Error ("Unable to move to the first row of the rowset", 
        IID_ICOMDiscountView, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to move to the first record in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to move to the first row of the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::MoveLast()
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    bRetCode = mpRowset->MoveLast() ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to move to the last row of the rowset. Error = %x", nRetVal) ;
      return Error ("Unable to move to the last row of the rowset", 
        IID_ICOMDiscountView, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to move to the last record in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to move to the last row of the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::get_Count(long * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    *pVal = mpRowset->GetCount() ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get the column count of the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the column count of the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::get_Name(VARIANT vtIndex, BSTR * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  RWWString wstrName ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    // if the type of the variant is BYREF and a VARIANT ... pass the variant within
    // the variant ... when passing a variant from VBScript it encapsulates the 
    // variant value within a Variant data type ...
    if (vtIndex.vt == (VT_BYREF | VT_VARIANT))
    {
      bRetCode = mpRowset->GetName (vtIndex.pvarVal, wstrName) ;
    }
    // otherwise ... pass the variant itself 
    else
    {
      bRetCode = mpRowset->GetName (vtIndex, wstrName) ;
    }
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to get the name of a column of the rowset. Error = %x", nRetVal) ;
      return Error ("Unable to get the name of a column in the rowset", 
        IID_ICOMDiscountView, nRetVal) ;
    }
    *pVal = ::SysAllocString (wstrName.c_str()) ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get the name of a column in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the name of a column in the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::get_Value(VARIANT arIndex, VARIANT * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  _variant_t vtIndex ;

  // convert the index ...
  vtIndex = ConvertPropertyName (arIndex) ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    // if the type of the variant is BYREF and a VARIANT ... pass the variant within
    // the variant ... when passing a variant from VBScript it encapsulates the 
    // variant value within a Variant data type ...
    if (vtIndex.vt == (VT_BYREF | VT_VARIANT))
    {
      bRetCode = mpRowset->GetValue (vtIndex.pvarVal, vtValue) ;
    }
    // otherwise ... pass the variant itself 
    else
    {
      bRetCode = mpRowset->GetValue (vtIndex, vtValue) ;
    }
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to get the value of a column of the rowset. Error = %x", nRetVal) ;
      return Error ("Unable to get the value of a column in the rowset", 
        IID_ICOMDiscountView, nRetVal) ;
    }
    *pVal = vtValue.Detach() ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get the value of a column in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the value of a column in the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }
  return (nRetVal) ;
}

STDMETHODIMP CCOMDiscountView::get_Type(VARIANT vtIndex, BSTR * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;  
  BOOL bRetCode=TRUE ;
  RWWString wstrName ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    // if the type of the variant is BYREF and a VARIANT ... pass the variant within
    // the variant ... when passing a variant from VBScript it encapsulates the 
    // variant value within a Variant data type ...
    if (vtIndex.vt == (VT_BYREF | VT_VARIANT))
    {
      bRetCode = mpRowset->GetType (vtIndex.pvarVal, wstrName) ;
    }
    // otherwise ... pass the variant itself 
    else
    {
      bRetCode = mpRowset->GetType (vtIndex, wstrName) ;
    }
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to get the type of a column of the rowset. Error = %x", nRetVal) ;
      return Error ("Unable to get the type of a column in the rowset", 
        IID_ICOMDiscountView, nRetVal) ;
    }
    else
    {
      *pVal = ::SysAllocString (wstrName.c_str()) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get the type of a column in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the type of a column in the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::get_RecordCount(long * pVal)
{
  // local variables ...
  HRESULT nRetVal=S_OK ;

	// if we have a rowset ...
  if (mpRowset != NULL)
  {
    *pVal = mpRowset->GetRecordCount() ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get the record count of the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the record count of the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::get_EOF(VARIANT * pVal)
{
  // local variables ...
  HRESULT nRetVal=S_OK ;
  _variant_t vtValue ;
  BOOL bEOF ;

	// if we have a rowset ...
  if (mpRowset != NULL)
  {
    bEOF = mpRowset->AtEOF() ;
    if (bEOF == TRUE)
    {
      vtValue = (VARIANT_BOOL) VARIANT_TRUE ;
    }
    else
    {
      vtValue = (VARIANT_BOOL) VARIANT_FALSE ;
    }
    *pVal = vtValue.Detach() ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get the state of the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the state of the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::get_PageSize(long * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;

	// if we have a rowset ...
  if (mpRowset != NULL)
  {
    *pVal = mpRowset->GetPageSize() ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get the page size of the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the page size of the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::put_PageSize(long newVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;

	// if we have a rowset ...
  if (mpRowset != NULL)
  {
    mpRowset->SetPageSize(newVal) ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to put the page size of the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to put the page size of the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::get_PageCount(long * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;

	// if we have a rowset ...
  if (mpRowset != NULL)
  {
    *pVal = mpRowset->GetPageCount() ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get the page count of the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the page count of the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::get_CurrentPage(long * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;

	// if we have a rowset ...
  if (mpRowset != NULL)
  {
    *pVal = mpRowset->GetPage() ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get the current page of the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the current page of the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CCOMDiscountView::put_CurrentPage(long newVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;

	// if we have a rowset ...
  if (mpRowset != NULL)
  {
    mpRowset->GoToPage(newVal) ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to put the current page of the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to put the current page of the rowset", 
      IID_ICOMDiscountView, nRetVal) ;
  }

	return (nRetVal);
}
