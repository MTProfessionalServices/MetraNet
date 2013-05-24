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
* 
***************************************************************************/
#include "StdAfx.h"
#include "COMDBObjects.h"
#include "MTFilter.h"
#include <DBConstants.h>
#include <DBMiscUtils.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>

// definition for summary rowset fields ...
FIELD_DEFINITION FILTER_ROWSET_FIELDS[] = 
{
  { DB_FILTER_NAME, DB_STRING_TYPE },
  { DB_FILTER_OPERATOR, DB_STRING_TYPE },
  { DB_FILTER_VALUE, DB_STRING_TYPE },
  { DB_FILTER_CRITERIA, DB_STRING_TYPE }
} ;


/////////////////////////////////////////////////////////////////////////////
// CMTFilter
CMTFilter::CMTFilter()
: mpRowset(NULL)
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("Database"), "MTFilter") ;
}

CMTFilter::~CMTFilter()
{
  TearDown() ;
}

STDMETHODIMP CMTFilter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTFilter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}
// ----------------------------------------------------------------
// Name:     	    Init
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   Creates and initializes MTInMemRowset
// ----------------------------------------------------------------

STDMETHODIMP CMTFilter::Init()
{
  // create and initialize in memory rowset ...
  if (!CreateAndInitializeRowset())
  {
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to create and initialize filter rowset.") ;
    return Error ("Unable to create and initialize filter rowset.", 
      IID_IMTFilter, E_FAIL) ;
  }

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	    TearDown
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   Internal Use Only
// ----------------------------------------------------------------

void CMTFilter::TearDown()
{
  if (mpRowset != NULL)
  {
    delete mpRowset ;
  }
}

// ----------------------------------------------------------------
// Name:     	    CreateAndInitializeRowset
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   Internal Use Only
// ----------------------------------------------------------------

BOOL CMTFilter::CreateAndInitializeRowset()
{
  BOOL bRetCode=TRUE ;
  int nNumFields ;

  // if the rowset is already allocated .. delete it ..
  TearDown() ;

  // create a nonSQL Rowset ...
  mpRowset = new DBInMemRowset ;
  if (mpRowset == NULL)
  {
    mLogger.LogVarArgs (LOG_ERROR, "Unable to allocate rowset. Error = <0x%x>.", 
      ::GetLastError()) ;
    bRetCode = FALSE ;
  }
  else
  {
    // iterate through the fields definition array ...
    nNumFields = (sizeof (FILTER_ROWSET_FIELDS) / sizeof (FIELD_DEFINITION)) ;
    for (int i=0 ; i < nNumFields && bRetCode == TRUE ; i++)
    {
      // add the field definition ...
      bRetCode = mpRowset->AddFieldDefinition (FILTER_ROWSET_FIELDS[i].FieldName, 
        FILTER_ROWSET_FIELDS[i].FieldType) ;
      if (bRetCode == FALSE)
      {
        mLogger.LogErrorObject (LOG_ERROR, mpRowset->GetLastError()) ;
        bRetCode = FALSE ;
      }
    }
  }

  return bRetCode ;
}

// ----------------------------------------------------------------
// Name:     	    Add
// Arguments:     aName - name for the field to filter on
//								aOperator - operator to apply to this field
//								aValue - value of property to filter on
//								aType		- value type. Following types are supported:
//													TYPE_STRING, TYPE_INTEGER, TYPE_FLOAT, TYPE_DATE
// Return Value:  
// Errors Raised: 
// Description:   Adds a new filter 
// ----------------------------------------------------------------


STDMETHODIMP CMTFilter::Add(BSTR aName, BSTR aOperator, BSTR aValue, MTPropertyType aType)
{
  wstring wstrFilterCriteria ;
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  _variant_t vtValue ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    // create the filter criteria ...
    wstrFilterCriteria = aName ;
    wstrFilterCriteria += L" " ;
    wstrFilterCriteria += aOperator ;
    wstrFilterCriteria += L" " ;

    // switch on the type ...
    switch (aType)
    {
    case TYPE_STRING:
      wstrFilterCriteria += L"N'" ;
      wstrFilterCriteria += ValidateString (aValue) ;
      wstrFilterCriteria += L"'" ;
      break ;

    case TYPE_INTEGER:
      wstrFilterCriteria += aValue ;
      break ;

    case TYPE_FLOAT:
      wstrFilterCriteria += aValue ;
      break ;

    case TYPE_DATE:
      wstrFilterCriteria += aValue ;
      break ;

    default:
      break ;
    }

    // add the new filter ...
    bRetCode = mpRowset->AddRow() ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to add a row to the filter list. Error = %x", nRetVal) ;
      return Error ("Unable to add a row to the filter list.", 
        IID_IMTFilter, nRetVal) ;
    }
    else
    {
      // add the name ...
      vtValue = aName ;
      bRetCode = mpRowset->AddFieldData (DB_FILTER_NAME, vtValue) ;
      if (bRetCode == FALSE)
      {
        const ErrorObject *pError = mpRowset->GetLastError() ;
        nRetVal = pError->GetCode() ;
        mLogger.LogVarArgs (LOG_ERROR,  
          "Unable to add property name to the filter list. Error = %x", nRetVal) ;
        return Error ("Unable to add filter name to the filter list.", 
          IID_IMTFilter, nRetVal) ;
      }
      else
      {
        // add the operator ...
        vtValue = aOperator ;
        bRetCode = mpRowset->AddFieldData (DB_FILTER_OPERATOR, vtValue) ;
        if (bRetCode == FALSE)
        {
          const ErrorObject *pError = mpRowset->GetLastError() ;
          nRetVal = pError->GetCode() ;
          mLogger.LogVarArgs (LOG_ERROR,  
            "Unable to add property name to the filter list. Error = %x", nRetVal) ;
          return Error ("Unable to add filter name to the filter list.", 
            IID_IMTFilter, nRetVal) ;
        }
        else
        {
          // add the value ...
          vtValue = aValue ;
          bRetCode = mpRowset->AddFieldData (DB_FILTER_VALUE, vtValue) ;
          if (bRetCode == FALSE)
          {
            const ErrorObject *pError = mpRowset->GetLastError() ;
            nRetVal = pError->GetCode() ;
            mLogger.LogVarArgs (LOG_ERROR,  
              "Unable to add property name to the filter list. Error = %x", nRetVal) ;
            return Error ("Unable to add filter name to the filter list.", 
              IID_IMTFilter, nRetVal) ;
          }
          else
          {
            // add the filter criteria ...
            vtValue = wstrFilterCriteria.c_str() ;
            bRetCode = mpRowset->AddFieldData (DB_FILTER_CRITERIA, vtValue) ;
            if (bRetCode == FALSE)
            {
              const ErrorObject *pError = mpRowset->GetLastError() ;
              nRetVal = pError->GetCode() ;
              mLogger.LogVarArgs (LOG_ERROR,  
                "Unable to add property name to the filter list. Error = %x", nRetVal) ;
              return Error ("Unable to add filter name to the filter list.", 
                IID_IMTFilter, nRetVal) ;
            }
          }
        }
      }
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Add() failed. Rowset not initialized. Error = %x", nRetVal) ;
    return Error ("Add() failed. Rowset not initialized", 
      IID_IMTFilter, nRetVal) ;
  }

  return S_OK;
}

// ----------------------------------------------------------------
// Name:     	    Remove
// Arguments:     
// Return Value:  
// Errors Raised: Not Supported
// ----------------------------------------------------------------

STDMETHODIMP CMTFilter::Remove(long aIndex)
{
  HRESULT nRetVal=S_OK ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    // remove the filter at the specified index ...
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Remove() failed. Rowset not initialized. Error = %x", nRetVal) ;
    return Error ("Remove() failed. Rowset not initialized", 
      IID_IMTFilter, nRetVal) ;
  }

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	    Clear
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   Reinitialize filter
// ----------------------------------------------------------------

STDMETHODIMP CMTFilter::Clear()
{
  // call Init ...
  Init() ;

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	MoveNext
// Arguments:     
// Return Value:  
// Errors Raised: ???         - Unable to move to the next row of the rowset
//                0xE1500004L - Unable to move to the next row of the rowset
// Description:   The MoveNext method moves the cursor to the next row
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTFilter::MoveNext()
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
        IID_IMTFilter, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to move to the next record in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to move to the next row of the rowset", 
      IID_IMTFilter, nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	MoveFirst
// Arguments:     
// Return Value:  
// Errors Raised: ???         - Unable to move to the first row of the rowset
//                0xE1500004L - Unable to move to the first row of the rowset
// Description:   The MoveFirst method moves the cursor to the first row
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTFilter::MoveFirst()
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;

  // if we have a rowset ...
  if (mpRowset != NULL && mpRowset->GetRecordCount() > 0)
  {
    bRetCode = mpRowset->MoveFirst() ;
    if (bRetCode == FALSE)
    {
      const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to move to the first row of the rowset. Error = %x", nRetVal) ;
      return Error ("Unable to move to the first row of the rowset", 
        IID_IMTFilter, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to move to the first record in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to move to the first row of the rowset", 
      IID_IMTFilter, nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	MoveLast
// Arguments:     
// Return Value:  
// Errors Raised: ???         - Unable to move to the last row of the rowset
//                0xE1500004L - Unable to move to the last row of the rowset
// Description:   The MoveLast method moves the cursor to the last row
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTFilter::MoveLast()
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
        IID_IMTFilter, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to move to the last record in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to move to the last row of the rowset", 
      IID_IMTFilter, nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	Count
// Arguments:     pVal - The number of columns in the rowset
// Return Value:  The number of columns in the rowset
// Errors Raised: 0xE1500004L - Unable to get the column count of the rowset
// Description:   The Count property gets the number of columns in the 
//  rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTFilter::get_Count(long * pVal)
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
      IID_IMTFilter, nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	Name
// Arguments:     vtIndex - the specified column of the rowset
//                pVal - the name of the column
// Return Value:  the name of the column
// Errors Raised: 0xE1500004L - Unable to get the name of a column in the rowset
// Description:   The Name property gets the name of the specified column 
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTFilter::get_Name(VARIANT vtIndex, BSTR * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  wstring wstrName ;

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
        IID_IMTFilter, nRetVal) ;
    }
    *pVal = ::SysAllocString (wstrName.c_str()) ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get the name of a column in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the name of a column in the rowset", 
      IID_IMTFilter, nRetVal) ;
  }

	return (nRetVal);
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
STDMETHODIMP CMTFilter::get_Value(VARIANT arIndex, VARIANT * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  _variant_t vtIndex = arIndex;

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
        IID_IMTFilter, nRetVal) ;
    }
    *pVal = vtValue.Detach() ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get the value of a column in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the value of a column in the rowset", 
      IID_IMTFilter, nRetVal) ;
  }
  return (nRetVal) ;
}

// ----------------------------------------------------------------
// Name:     	Type
// Arguments:     vtIndex - the specified column of the rowset
//                pVal - the type of the column
// Return Value:  the type of the column
// Errors Raised: 0xE1500004L - Unable to get the type of a column in the rowset
// Description:   The Type property gets the type of the specified column 
//  of the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTFilter::get_Type(VARIANT vtIndex, BSTR * pVal)
{
	// local variables ...
  HRESULT nRetVal=S_OK ;  
  BOOL bRetCode=TRUE ;
  wstring wstrName ;

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
        IID_IMTFilter, nRetVal) ;
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
      IID_IMTFilter, nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	RecordCount
// Arguments:     pVal - the number of rows
// Return Value:  the number of rows
// Errors Raised: 0xE1500004L - Unable to get the record count of the rowset
// Description:   The RecordCount property gets the number of rows 
//  in the rowset.
// ----------------------------------------------------------------
STDMETHODIMP CMTFilter::get_RecordCount(long * pVal)
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
      IID_IMTFilter, nRetVal) ;
  }

	return (nRetVal);
}

// ----------------------------------------------------------------
// Name:     	EOF
// Arguments:     pVal - the status of the rowset cursor
// Return Value:  the status of the rowset cursor
// Errors Raised: 0xE1500004L - Unable to get the state of the rowset.
// Description:   The EOF property gets the status of the rowset cursor.
// ----------------------------------------------------------------
STDMETHODIMP CMTFilter::get_EOF(VARIANT * pVal)
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
      IID_IMTFilter, nRetVal) ;
  }

	return (nRetVal);
}
