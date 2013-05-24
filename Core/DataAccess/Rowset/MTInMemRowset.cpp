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
* $Header$
* 
***************************************************************************/
// MTInMemRowset.cpp : Implementation of CMTInMemRowset
#include "StdAfx.h"
#include "Rowset.h"
#include "MTInMemRowset.h"
#include <DBInMemRowset.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>

/////////////////////////////////////////////////////////////////////////////
// CMTInMemRowset
CMTInMemRowset::CMTInMemRowset()
: mpRowset(NULL) 
{
}

CMTInMemRowset::~CMTInMemRowset()
{
  if (mpRowset != NULL)
  {
    delete mpRowset ;
  }
}

STDMETHODIMP CMTInMemRowset::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTInMemRowset,
    &IID_IMTRowSet
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
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   The Init method initializes the in-memory rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::Init()
{
  // local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we've already allocated one ... delete it ...
  if (mpRowset != NULL)
  {
    delete mpRowset ;
    mpRowset = NULL ;
  }

  mpRowset = new DBInMemRowset ;
  if (mpRowset == NULL)
  {
    nRetVal = ::GetLastError() ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to allocate a rowset. Error = %x", nRetVal) ;
  }

  return ((nRetVal)) ;
}

// ----------------------------------------------------------------
// Name:     	AddColumnDefinition
// Arguments:     apName - The name of the column
//                apType - The type of the column
// Return Value:  
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The AddColumnDefinition method adds a column of the type 
//  specified to the definition of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::AddColumnDefinition(BSTR apName, BSTR apType)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    bRetCode = mpRowset->AddFieldDefinition(apName, apType) ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger->LogVarArgs (LOG_ERROR,  
        L"Unable to add column definition to the rowset. Name = %s. Type = %s. Error = %x", 
        apName, apType, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
        L"Unable to add column definition to the rowset. Name = %s. Type = %s. Error = %x", 
        apName, apType, nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	ModifyColumnData
// Arguments:     apName - The name of the column to modify
//                aValue - The value of the column data
// Return Value:  
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The ModifyColumnData modifies the specified column. It replaces
//  the current value of the column with the new value.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::ModifyColumnData(BSTR apName, VARIANT aValue)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    bRetCode = mpRowset->ModifyFieldData(apName, aValue) ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger->LogVarArgs (LOG_ERROR,  
        L"Unable to modify the column data in the rowset. Name = %s. Error = %x", 
        apName, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      L"Unable to modify the column data in the rowset. Name = %s. Error = %x", 
      apName, nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	AddColumnData
// Arguments:     apName - The name of the column 
//                aValue - The value of the data
// Return Value:  
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The AddColumnData method adds the specified data to the
//  specified column of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::AddColumnData(BSTR apName, VARIANT aValue)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    bRetCode = mpRowset->AddFieldData(apName, aValue) ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger->LogVarArgs (LOG_ERROR,  
        L"Unable to add the column data in the rowset. Name = %s. Error = %x", 
        apName, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      L"Unable to add the column data in the rowset. Name = %s. Error = %x", 
      apName, nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	AddRow
// Arguments:     
// Return Value:  
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The AddRow method adds a row to the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::AddRow()
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    bRetCode = mpRowset->AddRow() ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to add a row to the rowset. Error = %x", nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to add a row to the rowset. Error = %x", nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	MoveNext
// Arguments:     
// Return Value:  
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The MoveNext method moves the cursor to the next row
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::MoveNext()
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
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to move to the next row of the rowset. Error = %x", nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to move to the next record in the rowset. Error = %x", nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	MoveFirst
// Arguments:     
// Return Value:  
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The MoveFirst method moves the cursor to the first row
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::MoveFirst()
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    bRetCode = mpRowset->MoveFirst() ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to move to the first row of the rowset. Error = %x", nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to move to the first record in the rowset. Error = %x", nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	MoveLast
// Arguments:     
// Return Value:  
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The MoveLast method moves the cursor to the last row
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::MoveLast()
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
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to move to the last row of the rowset. Error = %x", nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to move to the last record in the rowset. Error = %x", nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	Count
// Arguments:     pVal - The number of columns in the rowset
// Return Value:  The number of columns in the rowset
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The Count property gets the number of columns in the 
//  rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::get_Count(long * pVal)
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
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get the column count of the rowset. Error = %x", nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	Name
// Arguments:     vtIndex - the specified column of the rowset
//                pVal - the name of the column
// Return Value:  the name of the column
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The Name property gets the name of the specified column 
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::get_Name(VARIANT vtIndex, BSTR * pVal)
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
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to get the name of a column of the rowset. Error = %x", nRetVal) ;
    }
    else
    {
      *pVal = ::SysAllocString (wstrName.c_str()) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get the name of a column in the rowset. Error = %x", nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	Value
// Arguments:     vtIndex - the specified column of the rowset
//                pVal - the value of the column
// Return Value:  the value of the column
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The Value property gets the value of the specified column 
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::get_Value(VARIANT vtIndex, VARIANT * pVal)
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
      mLogger->LogVarArgs (LOG_WARNING,
        "Unable to get the value of a column of the rowset. Error = %x", nRetVal) ;
    }
    //else
    //{
      *pVal = vtValue.Detach() ;
    //}
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get the value of a column in the rowset. Error = %x", nRetVal) ;
  }
  return (nRetVal) ;
}

// ----------------------------------------------------------------
// Name:     	Type
// Arguments:     vtIndex - the specified column of the rowset
//                pVal - the type of the column
// Return Value:  the type of the column
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The Type property gets the type of the specified column 
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::get_Type(VARIANT vtIndex, BSTR * pVal)
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
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to get the type of a column of the rowset. Error = %x", nRetVal) ;
    }
    else
    {
      *pVal = ::SysAllocString (wstrName.c_str()) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get the type of a column in the rowset. Error = %x", nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	RecordCount
// Arguments:     pVal - the number of rows
// Return Value:  the number of rows
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The RecordCount property gets the number of rows 
//  in the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::get_RecordCount(long * pVal)
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
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get the record count of the rowset. Error = %x", nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	EOF
// Arguments:     pVal - the status of the rowset cursor
// Return Value:  the status of the rowset cursor
// Errors Raised: 0xE1500004L - no rows are present in the rowset
// Description:   The EOF property gets the status of the rowset cursor.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::get_EOF(VARIANT * pVal)
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
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get the state of the rowset. Error = %x", nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CMTInMemRowset::Sort(BSTR aPropertyName, MTSortOrder aSortOrder)
{
  return S_OK ;
}

// ----------------------------------------------------------------
// Name:     	PageSize
// Arguments:     pVal - the page size of the rowset
// Return Value:  the page size of the rowset
// Errors Raised: 
// Description:   The PageSize property gets the page size value.
// ----------------------------------------------------------------
STDMETHODIMP CMTInMemRowset::get_PageSize(long * pVal)
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
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get the page size of the rowset. Error = %x", nRetVal) ;
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
STDMETHODIMP CMTInMemRowset::put_PageSize(long newVal)
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
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to put the page size of the rowset. Error = %x", nRetVal) ;
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
STDMETHODIMP CMTInMemRowset::get_PageCount(long * pVal)
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
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get the page count of the rowset. Error = %x", nRetVal) ;
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
STDMETHODIMP CMTInMemRowset::get_CurrentPage(long * pVal)
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
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get the current page of the rowset. Error = %x", nRetVal) ;
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
STDMETHODIMP CMTInMemRowset::put_CurrentPage(long newVal)
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
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to put the current page of the rowset. Error = %x", nRetVal) ;
  }

	return (nRetVal);
}

STDMETHODIMP CMTInMemRowset::putref_Filter(IMTDataFilter* pFilter)
{
	return E_NOTIMPL;
}
STDMETHODIMP CMTInMemRowset::get_Filter(IMTDataFilter** pFilter)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTInMemRowset::ResetFilter()
{
	return E_NOTIMPL;
}


STDMETHODIMP CMTInMemRowset::ApplyExistingFilter()
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTInMemRowset::get_ValueNoLog(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ VARIANT *pVal)
{
	return E_NOTIMPL;
}


STDMETHODIMP CMTInMemRowset::RemoveRow()
{
  return E_NOTIMPL;
}
