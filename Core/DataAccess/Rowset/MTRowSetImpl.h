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
* Created by: 
* $Header: s:\Core\DataAccess\Rowset\MTRowSetImpl.h, 16, 7/26/2002 3:01:26 PM, Travis Gebhardt$
* 
***************************************************************************/
#ifndef __MTROWSETIMPL_H__
#define __MTROWSETIMPL_H__
#pragma once

#include "Rowset.h"
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <mtglobal_msg.h>
#include <mtcomerr.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

// short cut for returning COM errors
#define MTROWSETIMPLERROR(a,b) reinterpret_cast<CComCoClass<T,piid>*>(this)->Error(a,*piid,b)


	// move next errors
#define MoveNextError "Unable to move to the next row of the rowset"
#define MoveNextErrorDetail "Unable to move to the next row of the rowset. Error = %x"
	// move first
#define MoveFirstError "Unable to move to the first row of the rowset"
#define MoveFirstErrorDetail "Unable to move to the first row of the rowset. Error = %x"
	// move last
#define MoveLastError "Unable to move to the last row of the rowset"
#define MoveLastErrorDetail "Unable to move to the last row of the rowset. Error = %x"
	// count
#define CountError "Unable to get the column count of the rowset"
#define CountErrorDetail "Unable to get the column count of the rowset. Error = %x"
	// GetName
#define GetNameError "Unable to get the name of a column of the rowset"
#define GetNameErrorDetail "Unable to get the name of a column of the rowset. Error = %x"
	// GetValue
#define GetValueError "Unable to get the value of a column of the rowset"
#define GetValueErrorDetail "Unable to get the value of a column of the rowset. Error = %x"
	// GetType
#define GetTypeError "Unable to get the type of a column of the rowset"
#define GetTypeErrorDetail "Unable to get the type of a column of the rowset. Error = %x"
// get_recordCount
#define GetRecordCountErrorDetail "Unable to get the record count of the rowset. Error = %x"
#define GetRecordCountError "Unable to get the record count of the rowset."
// get_EOF
#define GetEofErrorDetail "Unable to get the state of the rowset. Error = %x"
#define GetEofError "Unable to get the state of the rowset."
// sort
#define SortErrorArgsDetail "Sort() failed. Invalid sort order. Sort Order Value = %x"
#define SortErrorArgs "Sort() failed. Invalid sort order."
#define SortErrorDetail "Sort() failed. Unable to sort the rowset. Error = %x"
#define SortError "Sort() failed. Unable to sort the rowset."
// getpagesize
#define GetPageSizeErrorDetail "Unable to get the page size of the rowset. Error = %x"
#define GetPageSizeError "Unable to get the page size of the rowset."
// putpagesize
#define PutPageSizeErrorDetail "Unable to put the page size of the rowset. Error = %x"
#define PutPageSizeError "Unable to put the page size of the rowset."
// getPageCount
#define GetPageCountErrorDetail "Unable to get the page count of the rowset. Error = %x"
#define GetPageCountError "Unable to get the page count of the rowset."
// GetCurrentPage
#define GetCurrentPageErrorDetail "Unable to get the current page of the rowset. Error = %x"
#define GetCurrentPageError "Unable to get the current page of the rowset."
//PutCurrentPage
#define PutCurrentPageErrorDetail "Unable to put the current page of the rowset. Error = %x"
#define PutCurrentPageError "Unable to put the current page of the rowset."
// Filter
#define FilterError "Failed to set filter criteria"


// forward declarations 
struct IMTQueryAdapter ;
class DBSQLRowset ;

template<class T,const IID* piid, const GUID* plibid>
class MTRowSetImpl : public IDispatchImpl<T,piid,plibid>
{
public:

	MTRowSetImpl() : mpRowset(NULL), mpQueryAdapter(NULL) {}
	virtual ~MTRowSetImpl();
// ----------------------------------------------------------------
// The EOF property gets the current status of the rowset cursor.
// ----------------------------------------------------------------
  STDMETHOD(get_EOF)(/*[out, retval]*/ VARIANT *pVal);
// ----------------------------------------------------------------
// The RecordCount property gets the number of rows in the rowset.
// ----------------------------------------------------------------
	STDMETHOD(get_RecordCount)(/*[out, retval]*/ long *pVal);
// ----------------------------------------------------------------
// The Type property gets the type for the specified column.
// ----------------------------------------------------------------
	STDMETHOD(get_Type)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ BSTR *pVal);
// ----------------------------------------------------------------
// The Value property gets the value for the specified column.
// ----------------------------------------------------------------
	STDMETHOD(get_Value)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ VARIANT *pVal);
// ----------------------------------------------------------------
// The Name property gets the name for the specified column.
// ----------------------------------------------------------------
	STDMETHOD(get_Name)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ BSTR *pVal);
// ----------------------------------------------------------------
// The Count property gets the number of columns in the rowset.
// ----------------------------------------------------------------
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
// ----------------------------------------------------------------
// The MoveFirst method moves to the first row of the rowset.
// ----------------------------------------------------------------
	STDMETHOD(MoveFirst)();
// ----------------------------------------------------------------
// The MoveNext method moves to the next row of the rowset.
// ----------------------------------------------------------------
	STDMETHOD(MoveNext)();
// ----------------------------------------------------------------
// The MoveLast method moves to the last row of the rowset.
// ----------------------------------------------------------------
	STDMETHOD(MoveLast)();
  STDMETHOD(Sort)(BSTR aPropertyName, MTSortOrder aSortOrder) ;

	// ----------------------------------------------------------------
	// The CurrentPage property gets the current page of the cursor.
	// ----------------------------------------------------------------
  STDMETHOD(get_CurrentPage)(/*[out, retval]*/ long *pVal);
	// ----------------------------------------------------------------
	// The CurrentPage property sets the current page of the cursor.
	// ----------------------------------------------------------------
	STDMETHOD(put_CurrentPage)(/*[in]*/ long newVal);
	// ----------------------------------------------------------------
	// The PageCount property gets the number of pages in the rowset.
	// ----------------------------------------------------------------
	STDMETHOD(get_PageCount)(/*[out, retval]*/ long *pVal);
	// ----------------------------------------------------------------
	// The PageSize property gets the current page size.
	// ----------------------------------------------------------------
	STDMETHOD(get_PageSize)(/*[out, retval]*/ long *pVal);
	// ----------------------------------------------------------------
	// The PageSize property sets the page size.
	// ----------------------------------------------------------------
	STDMETHOD(put_PageSize)(/*[in]*/ long newVal);

	STDMETHOD(putref_Filter)(IMTDataFilter* pFilter);
	STDMETHOD(get_Filter)(IMTDataFilter** pFilter);

	STDMETHOD(ResetFilter)();
	STDMETHOD(get_ValueNoLog)(VARIANT vtIndex, /*[out, retval]*/ VARIANT *pVal);

	STDMETHOD(ApplyExistingFilter)();

  STDMETHOD(RemoveRow)();

protected: // methods
	HRESULT SetFilterString(_bstr_t& aFilterStr);

protected: // data
	DBSQLRowset *         mpRowset ;
	QUERYADAPTERLib::IMTQueryAdapter         *mpQueryAdapter ;
	ROWSETLib::IMTDataFilterPtr mFilter;
private:
	MTAutoInstance<MTAutoLoggerImpl<szMTRowSetImplTag,szDbObjectsDir> >	mLogger; 
};


// import the config loader ...
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

template<class T,const IID* piid, const GUID* plibid>
MTRowSetImpl<T,piid,plibid>::~MTRowSetImpl()
{

	if (mpRowset != NULL)
  {
    delete mpRowset ;
    mpRowset = NULL ;
  }
  // delete the query adapter ...
  if (mpQueryAdapter != NULL)
  {
    mpQueryAdapter->Release() ;
    mpQueryAdapter = NULL ;
  }
}

// ----------------------------------------------------------------
// Name:     	MoveNext
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   The MoveNext method moves the cursor to the next row
//  of the rowset.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::MoveNext()
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
      mLogger->LogVarArgs (LOG_ERROR,MoveNextErrorDetail,nRetVal);
			return MTROWSETIMPLERROR(MoveNextError,nRetVal);
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,MoveNextErrorDetail, nRetVal);
		return MTROWSETIMPLERROR(MoveNextError,nRetVal);
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	MoveFirst
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   The MoveFirst method moves the cursor to the first row
//  of the rowset.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::MoveFirst()
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    bRetCode = mpRowset->MoveFirst();
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError();
      nRetVal = pError->GetCode();
      mLogger->LogVarArgs (LOG_ERROR,MoveFirstErrorDetail,nRetVal);
			return MTROWSETIMPLERROR(MoveFirstError,nRetVal);
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,MoveFirstErrorDetail, nRetVal);
		return MTROWSETIMPLERROR(MoveFirstError,nRetVal);
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	MoveLast
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   The MoveLast method moves the cursor to the last row
//  of the rowset.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::MoveLast()
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
      mLogger->LogVarArgs (LOG_ERROR,MoveLastErrorDetail,nRetVal) ;
			return MTROWSETIMPLERROR(MoveLastError,nRetVal);
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,MoveLastErrorDetail,nRetVal);
		return MTROWSETIMPLERROR(MoveLastError,nRetVal);
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	Count
// Arguments:     pVal - The number of columns in the rowset
// Return Value:  The number of columns in the rowset
// Errors Raised: 
// Description:   The Count property gets the number of columns in the 
//  rowset.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::get_Count(long * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    *pVal = mpRowset->GetCount();
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,CountErrorDetail,nRetVal);
		return MTROWSETIMPLERROR(CountError,nRetVal);
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	Name
// Arguments:     vtIndex - the specified column of the rowset
//                pVal - the name of the column
// Return Value:  the name of the column
// Errors Raised: 
// Description:   The Name property gets the name of the specified column 
//  of the rowset.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::get_Name(VARIANT vtIndex, BSTR * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  std::wstring wstrName ;

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
      mLogger->LogVarArgs (LOG_ERROR,GetNameErrorDetail,nRetVal);
			return MTROWSETIMPLERROR(GetNameError,nRetVal);
    }
    else
    {
      *pVal = ::SysAllocString (wstrName.c_str()) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,GetNameErrorDetail,nRetVal);
		return MTROWSETIMPLERROR(GetNameError,nRetVal);
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	Value
// Arguments:     vtIndex - the specified column of the rowset
//                pVal - the value of the column
// Return Value:  the value of the column
// Errors Raised: 
// Description:   The Value property gets the value of the specified column 
//  of the rowset.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::get_Value(VARIANT vtIndex, VARIANT * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;

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
      mLogger->LogVarArgs (LOG_WARNING,GetValueErrorDetail,nRetVal);

      // get the requested index ...
      _variant_t vtTemp ;
      if (vtIndex.vt == (VT_BYREF | VT_VARIANT))
      {
        vtTemp = vtIndex.pvarVal ;
      }
      else
      {
        vtTemp = vtIndex ;
      }
      if (vtTemp.vt == VT_BSTR)
      {
        _bstr_t columnName = vtTemp.bstrVal ;
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %s", (char*)columnName) ;
      }
      else if (vtTemp.vt == VT_I2)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)vtTemp.iVal) ;
      }
      else if (vtTemp.vt == VT_I4)
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Value requested = %x", (int)vtTemp.iVal) ;
      }
      else
      {
        mLogger->LogVarArgs (LOG_WARNING,  "Unknown value requested. Type = %x", (int)vtTemp.vt) ;
      }
    }
    // copy the value ...
    *pVal = vtValue.Detach() ;

		if (FAILED(nRetVal))
			return MTROWSETIMPLERROR(GetValueError,nRetVal);
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,GetValueErrorDetail,nRetVal);
		return MTROWSETIMPLERROR(GetValueError,nRetVal);
  }
  return (nRetVal) ;
}


template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::get_ValueNoLog(VARIANT vtIndex, /*[out, retval]*/ VARIANT *pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    // if the type of the variant is BYREF and a VARIANT ... pass the variant within
    // the variant ... when passing a variant from VBScript it encapsulates the 
    // variant value within a Variant data type ...
    if (vtIndex.vt == (VT_BYREF | VT_VARIANT))
    {
      bRetCode = mpRowset->GetValue (vtIndex.pvarVal, vtValue,false) ;
    }
    // otherwise ... pass the variant itself 
    else
    {
      bRetCode = mpRowset->GetValue (vtIndex, vtValue,false) ;
    }
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;

    }
    // copy the value ...
    *pVal = vtValue.Detach() ;

  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
		return MTROWSETIMPLERROR(GetValueError,nRetVal);
  }

	if (FAILED(nRetVal))
		return MTROWSETIMPLERROR(GetValueError,nRetVal);

  return (nRetVal) ;
}



// ----------------------------------------------------------------
// Name:     	Type
// Arguments:     vtIndex - the specified column of the rowset
//                pVal - the type of the column
// Return Value:  the type of the column
// Errors Raised: 
// Description:   The Type property gets the type of the specified column 
//  of the rowset.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::get_Type(VARIANT vtIndex, BSTR * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;  
  BOOL bRetCode=TRUE ;
  std::wstring wstrName ;

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
      mLogger->LogVarArgs (LOG_ERROR,GetTypeErrorDetail,nRetVal);
    }
    else
    {
      *pVal = ::SysAllocString (wstrName.c_str()) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,GetTypeErrorDetail,nRetVal);
		return MTROWSETIMPLERROR(GetTypeError,nRetVal);
  }

	if (FAILED(nRetVal))
		return MTROWSETIMPLERROR(GetValueError,nRetVal);

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	RecordCount
// Arguments:     pVal - the number of rows
// Return Value:  the number of rows
// Errors Raised: 
// Description:   The RecordCount property gets the number of rows 
//  in the rowset.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::get_RecordCount(long * pVal)
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
    mLogger->LogVarArgs (LOG_ERROR,GetRecordCountErrorDetail, nRetVal) ;
		return MTROWSETIMPLERROR(GetRecordCountError,nRetVal);
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	EOF
// Arguments:     pVal - the status of the rowset cursor
// Return Value:  the status of the rowset cursor
// Errors Raised: 
// Description:   The EOF property gets the status of the rowset cursor.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::get_EOF(VARIANT * pVal)
{
  // local variables ...
  HRESULT nRetVal=S_OK ;
  _variant_t vtValue ;

	// if we have a rowset ...
  if (mpRowset != NULL)
  {
    BOOL bRetCode = mpRowset->AtEOF() ;
    if (bRetCode == FALSE)
    {
      vtValue = VARIANT_FALSE ;
    }
    else
    {
      vtValue = VARIANT_TRUE ;
    }
    *pVal = vtValue.Detach() ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,GetEofErrorDetail, nRetVal);
		return MTROWSETIMPLERROR(GetEofError,nRetVal);
  }

	if (FAILED(nRetVal))
		return MTROWSETIMPLERROR(GetValueError,nRetVal);

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
// Description:   The Sort method sorts the product view rowset by the
//  property name passed in the direction passed.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::Sort(BSTR aPropertyName, ::MTSortOrder aSortOrder)
{
  std::wstring wstrSortString ;

  // construct the sort string ... rst.Sort = "[au_lname] ASC, [au_fname] ASC"
  // Add [] in case property name contains space(s)
  wstrSortString = L"[";
  wstrSortString.append(aPropertyName);
  wstrSortString.append(L"]");

  // validate the sort order ...
  switch (aSortOrder)
  {
  case ::SORT_ASCENDING:
    wstrSortString.append (L" ASC") ;
    break ;

  case ::SORT_DESCENDING:
    wstrSortString.append (L" DESC") ;
    break ;

  default:
    mLogger->LogVarArgs (LOG_ERROR,SortErrorArgsDetail, aSortOrder) ;
		return MTROWSETIMPLERROR(SortErrorArgs,E_FAIL);
    break ;
  }
  // sort the recordset ...
  BOOL bRetCode = mpRowset->Sort (wstrSortString.c_str()) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = mpRowset->GetLastError();
    HRESULT nRetVal = pError->GetCode();
    mLogger->LogVarArgs (LOG_ERROR,SortErrorDetail,nRetVal);
		return MTROWSETIMPLERROR(SortError,nRetVal);
  }
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	PageSize
// Arguments:     pVal - the page size of the rowset
// Return Value:  the page size of the rowset
// Errors Raised: 
// Description:   The PageSize property gets the page size value.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::get_PageSize(long * pVal)
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
    nRetVal = DB_ERR_NO_ROWS;
    mLogger->LogVarArgs(LOG_ERROR,GetPageSizeErrorDetail,nRetVal);
		return MTROWSETIMPLERROR(GetPageSizeError,nRetVal);
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	PageSize
// Arguments:     pVal - the new page size of the rowset
// Return Value:  
// Errors Raised: 
// Description:   The PageSize property sets the page size value.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::put_PageSize(long newVal)
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
    mLogger->LogVarArgs (LOG_ERROR,PutPageSizeErrorDetail, nRetVal);
		return MTROWSETIMPLERROR(PutPageSizeError,nRetVal);
  }

	return (nRetVal);
}


// ----------------------------------------------------------------
// Name:     	PageCount
// Arguments:     pVal - the number of pages in the rowset
// Return Value:  the number of pages in the rowset
// Errors Raised: 
// Description:   The PageCount property gets the number of pages 
//  in the rowset.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::get_PageCount(long * pVal)
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
    mLogger->LogVarArgs (LOG_ERROR,GetPageCountErrorDetail,nRetVal);
		return MTROWSETIMPLERROR(GetPageCountError,nRetVal);
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	CurrentPage
// Arguments:     pVal - the current page of the cursor in the rowset
// Return Value:  the current page of the cursor in the rowset
// Errors Raised: 
// Description:   The CurrentPage property gets the current page
//  of the cursor in the rowset.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::get_CurrentPage(long * pVal)
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
    mLogger->LogVarArgs (LOG_ERROR,GetCurrentPageErrorDetail, nRetVal) ;
		return MTROWSETIMPLERROR(GetCurrentPageError,nRetVal);
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	CurrentPage
// Arguments:     pVal - the page to set 
// Return Value:  
// Errors Raised: 
// Description:   The CurrentPage property sets the current page
//  of the cursor in the rowset.
// ----------------------------------------------------------------
template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::put_CurrentPage(long newVal)
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
    mLogger->LogVarArgs (LOG_ERROR,PutCurrentPageErrorDetail, nRetVal);
		return MTROWSETIMPLERROR(PutCurrentPageError,nRetVal);
  }

	return (nRetVal);
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::putref_Filter(::IMTDataFilter* pFilter)
{
	ASSERT(pFilter);
	if(!pFilter) return E_POINTER;
	HRESULT hr = S_OK;

	try {
		if(!mpRowset) {
			return MTROWSETIMPLERROR("Rowset does not exist.  Did you forget to call Init or Execute()?",E_FAIL);
		}

		// set the filter string
		mFilter = ROWSETLib::IMTDataFilterPtr(pFilter);
		// this next line tells the filter to generate itself as an ADO filter.
		mFilter->PutIsWhereClause(VARIANT_FALSE);
		hr = SetFilterString(mFilter->GetFilterString());
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return hr;
}

template<class T,const IID* piid, const GUID* plibid>
HRESULT MTRowSetImpl<T,piid,plibid>::SetFilterString(_bstr_t& aFilterStr)
{
	if(!mpRowset->SetFilterString(aFilterStr)) {
			mLogger->LogThis(LOG_ERROR,FilterError);
			return MTROWSETIMPLERROR(FilterError,E_FAIL);
	}
	if(aFilterStr.length() == 0) {
		mLogger->LogThis(LOG_WARNING,"filter object contains an empty filter");
	}
	return S_OK;
}



template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::get_Filter(::IMTDataFilter** pFilter)
{
	ASSERT(pFilter);
	if(!pFilter) return E_POINTER;

	try {
		// get the filter object if it exists, otherwise return NULL.  The method
		// should always succeed
		if(mFilter) {
			mFilter->AddRef();
			*pFilter = reinterpret_cast<::IMTDataFilter*>(mFilter.GetInterfacePtr());
		}
		else {
			*pFilter = NULL;
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}




template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::ResetFilter()
{
	mpRowset->ResetFilter();
	return S_OK;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::ApplyExistingFilter()
{
	HRESULT hr = S_OK;
	try {
		// step 1: if the existing filter does not exist, exit
		if(mFilter) {
			// step 2: set the filter string
			hr = SetFilterString(mFilter->GetFilterString());
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return hr;
}

template<class T,const IID* piid, const GUID* plibid>
STDMETHODIMP MTRowSetImpl<T,piid,plibid>::RemoveRow()
{
  try {
    mpRowset->RemoveRow();
  }
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
  return S_OK;
}

#endif //__MTROWSETIMPL_H__
