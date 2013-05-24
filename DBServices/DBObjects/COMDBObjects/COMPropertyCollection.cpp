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
// COMPropertyCollection.cpp : Implementation of CCOMPropertyCollection
#include "StdAfx.h"
#include "COMDBObjects.h"
#include "COMPropertyCollection.h"
#include <DBRowset.h>
#include <DBViewHierarchy.h>
#include <DBProductView.h>
#include <DBDiscountView.h>
#include <DBDataAnalysisView.h>
#include <DBConstants.h>
#include <DBProperty.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>

// definition for view property fields ...
FIELD_DEFINITION VIEW_PROPERTY_FIELDS[] =
{
	{ DB_PROPERTY_NAME, DB_STRING_TYPE },
	{ DB_PROPERTY_TYPE, DB_STRING_TYPE },
	{ DB_COLUMN_NAME, DB_STRING_TYPE },
  { DB_ENUM_NAMESPACE, DB_STRING_TYPE },
  { DB_ENUM_ENUMERATION, DB_STRING_TYPE },
  { DB_FILTERABLE_FLAG, DB_STRING_TYPE },
  { DB_EXPORTABLE_FLAG, DB_STRING_TYPE }
} ;

/////////////////////////////////////////////////////////////////////////////
// CCOMPropertyCollection
CCOMPropertyCollection::CCOMPropertyCollection()
: mpRowset(NULL)
{
	mViewID = -1 ;
}

CCOMPropertyCollection::~CCOMPropertyCollection()
{
  if (mpRowset != NULL)
  {
    delete mpRowset ;
    mpRowset = NULL ;
  }
}

STDMETHODIMP CCOMPropertyCollection::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMPropertyCollection,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     	ViewID
// Arguments:     pVal - the view id
// Return Value:  
// Errors Raised: 
// Description:   The ViewID property gets the view id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMPropertyCollection::get_ViewID(long * pVal)
{
	*pVal = mViewID ;

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	ViewID
// Arguments:     newVal - the view id
// Return Value:  
// Errors Raised: 
// Description:   The ViewID property sets the view id.
// ----------------------------------------------------------------
STDMETHODIMP CCOMPropertyCollection::put_ViewID(long newVal)
{
	mViewID = newVal ;

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	Init
// Arguments:     
// Return Value:  
// Errors Raised: 0xE1500008L - Unable to get view hierarchy.
//                ???         - Unable to find view in view hierarchy.
//                0xE1500007L - Unable to get property collection for summary view
//                0xE1500003L - Unable to get property collection for unknown view type
// Description:   The Init method initializes the property collection 
//  rowset for the specified view id. Each row in the rowset contains
//  the property name, property type and property column name.
// ----------------------------------------------------------------
STDMETHODIMP CCOMPropertyCollection::Init()
{
	BOOL bRetCode=TRUE ;
	HRESULT nRetVal=S_OK ;
	DBViewHierarchy *pViewHierarchy=NULL ;
	DBView *pView=NULL ;
	DBProductView *pProductView=NULL ;
  DBDiscountView *pDiscountView=NULL ;
  DBDataAnalysisView *pDataAnalysisView=NULL ;
	DBProductViewProperty *pProperty=NULL ;
	std::wstring wstrType ;
	char* buffer = NULL;

	// get a pointer to the view hierarchy ...
	//pViewHierarchy = DBViewHierarchy::GetInstance(mAcctID,mIntervalID) ;

	//ASSERT(!"This could is broken because we don't handle the view hierarchy properly");
	//pViewHierarchy = NULL;
	// get a pointer to the view hierarchy ...
	// XXX FIX THIS!! XXX
	// XXX This is broken!!! XXX
	pViewHierarchy = DBViewHierarchy::GetInstance();
	if (pViewHierarchy == NULL)
	{
	  buffer = "Unable to get instance of DBViewHierarchy";
		mLogger->LogVarArgs (LOG_ERROR, buffer); 
    return Error (buffer, IID_ICOMPropertyCollection, DB_ERR_NO_INSTANCE) ;
	}
	else
	{
		// find the view ...
		MTAutoSingleton<MTPCHierarchyColl> mVHinstance;
		mVHinstance->TranslateID(mViewID,mViewID);

		bRetCode = pViewHierarchy->FindView (mViewID, pView) ;
		if (bRetCode == FALSE)
		{
			const ErrorObject *pError = pViewHierarchy->GetLastError() ;
			mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to find view in view hierarchy for view ID <%d>", mViewID) ;
      return Error ("Unable to find view in view hierarchy", 
        IID_ICOMPropertyCollection, pError->GetCode()) ;
		}
		else
		{
			// if its a summary view ...
			wstrType = pView->GetViewType() ;
			//if (wstrType.compareTo (DB_SUMMARY_VIEW, RWWString::ignoreCase) == 0)
			if (_wcsicmp(wstrType.c_str(), DB_SUMMARY_VIEW) == 0)
			{
        pViewHierarchy->ReleaseInstance() ;
				nRetVal = DB_ERR_INCORRECT_TYPE ;
				mLogger->LogVarArgs (LOG_ERROR,  
          "Unable to get property collection for summary view. Error = %x", nRetVal) ;
        return Error ("Unable to get property collection for summary view", 
          IID_ICOMPropertyCollection, nRetVal) ;
			}
			// else if its a product view ...
			//else if (wstrType.compareTo (DB_PRODUCT_VIEW, RWWString::ignoreCase) == 0)
			else if (_wcsicmp(wstrType.c_str(), DB_PRODUCT_VIEW) == 0)
			{
				// initialize the property collection ...
				bRetCode = InitializePropertyCollection () ;

				// if we havent hit an error yet ...
				if (bRetCode == TRUE)
				{
					// add the account usage properties that are generic ...
					bRetCode = AddAccountUsageProperties(wstrType) ;
					if (bRetCode == TRUE)
					{
            // get the property list ...
            pProductView = (DBProductView *) pView ;

            // iterate thru the property list and add the properties ...
            bRetCode = TRUE ;
            for (DBProductViewPropCollIter Iter = pProductView->GetPropertyList().begin(); 
								 Iter != pProductView->GetPropertyList().end() && bRetCode == TRUE;
								 Iter++)
            {
              // get the property ...
              pProperty = (*Iter).second ;

              // add the property ...
              bRetCode = AddProperty (pProperty, wstrType) ;
            }
            // iterate thru the reserved property list and add the properties ...
            for (DBProductViewPropCollIter ResvdIter = pProductView->GetReservedPropertyList().begin();
								 ResvdIter != pProductView->GetReservedPropertyList().end() && bRetCode == TRUE;
								 ResvdIter++)
            {
              // get the property ...
              pProperty = (*ResvdIter).second ;
              
              // add the property ...
              bRetCode = AddProperty (pProperty, wstrType) ;
            }
					}
				}
			}
      // else if its a discount view ...
			//else if (wstrType.compareTo (DB_DISCOUNT_VIEW, RWWString::ignoreCase) == 0)
			else if (_wcsicmp(wstrType.c_str(), DB_DISCOUNT_VIEW) == 0)
			{
				// initialize the property collection ...
				bRetCode = InitializePropertyCollection () ;

				// if we havent hit an error yet ...
				if (bRetCode == TRUE)
				{
					// add the account usage properties that are generic ...
					bRetCode = AddAccountUsageProperties(wstrType) ;
					if (bRetCode == TRUE)
					{
            // get the property list ...
            pDiscountView = (DBDiscountView *) pView ;

            // iterate thru the property list and add the properties ...
            bRetCode = TRUE ;
            for (DBProductViewPropCollIter Iter = pDiscountView->GetPropertyList().begin();
								 Iter != pDiscountView->GetPropertyList().end() && bRetCode == TRUE;
								 Iter++)
            {
              // get the property ...
              pProperty = (*Iter).second ;

              // add the property ...
              bRetCode = AddProperty (pProperty, wstrType) ;
            }
					}
				}
			}
      // else if its a data analysis view ...
			//else if (wstrType.compareTo (DB_DATAANALYSIS_VIEW, RWWString::ignoreCase) == 0)
			else if (_wcsicmp(wstrType.c_str(), DB_DATAANALYSIS_VIEW) == 0)
			{
				// initialize the property collection ...
				bRetCode = InitializePropertyCollection () ;

				// if we havent hit an error yet ...
				if (bRetCode == TRUE)
				{
          // get the property list ...
          pDataAnalysisView = (DBDataAnalysisView *) pView ;
          
          // iterate thru the property list and add the properties ...
          bRetCode = TRUE ;
          for (DBProductViewPropCollIter Iter = pDataAnalysisView->GetPropertyList().begin();
							 Iter != pDataAnalysisView->GetPropertyList().end() && bRetCode == TRUE;
							 Iter++)
          {
            // get the property ...
            pProperty = (*Iter).second ;
            
            // add the property ...
            bRetCode = AddProperty (pProperty, wstrType) ;
          }
				}
			}
			else
			{
        pViewHierarchy->ReleaseInstance() ;
				nRetVal = DB_ERR_INVALID_PARAMETER ;
				mLogger->LogVarArgs (LOG_ERROR,  
          "Unable to get property collection for unknown view type %s. Error = %x", 
          ascii(wstrType.c_str()), nRetVal) ;
        return Error ("Unable to get property collection for unknown view type", 
          IID_ICOMPropertyCollection, nRetVal) ;
			}
		}
	}
  if (pViewHierarchy != NULL)
  {
    pViewHierarchy->ReleaseInstance() ;
  }

	return (nRetVal) ;
}

BOOL CCOMPropertyCollection::AddRow (const std::wstring &arName, const std::wstring &arType,
                                     const std::wstring &arColumnName, 
                                     const std::wstring &arEnumNamespace,
                                     const std::wstring &arEnumEnumeration,
                                     const BOOL &arFilterable,
                                     const BOOL &arExportable) 
{
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  _variant_t vtValue ;

  // add a new row into the rowset ...
	bRetCode = mpRowset->AddRow() ;
	if (bRetCode == FALSE)
	{
		const ErrorObject *pError = mpRowset->GetLastError() ;
    nRetVal = pError->GetCode() ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to add a row to the property collection. Error = %x", nRetVal) ;
    return Error ("Unable to add a row to the property collection", 
      IID_ICOMPropertyCollection, nRetVal) ;
	}
	else
	{
		// add the property name, column name and property type ...
		vtValue = arName.c_str() ;
		bRetCode = mpRowset->AddFieldData (DB_PROPERTY_NAME, vtValue) ;
		if (bRetCode == FALSE)
		{
			const ErrorObject *pError = mpRowset->GetLastError() ;
			nRetVal = pError->GetCode() ;
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to add property name to the property collection. Error = %x", nRetVal) ;
      return Error ("Unable to add property name to the property collection", 
        IID_ICOMPropertyCollection, nRetVal) ;
		}
		else
		{
			vtValue = arType.c_str() ;
			bRetCode = mpRowset->AddFieldData (DB_PROPERTY_TYPE, vtValue) ;
			if (bRetCode == FALSE)
			{
				const ErrorObject *pError = mpRowset->GetLastError() ;
				nRetVal = pError->GetCode() ;
        mLogger->LogVarArgs (LOG_ERROR,  
          "Unable to add property type to the property collection. Error = %x", nRetVal) ;
        return Error ("Unable to add property type to the property collection", 
          IID_ICOMPropertyCollection, nRetVal) ;
			}
			else
			{
				vtValue = arColumnName.c_str() ;
				bRetCode = mpRowset->AddFieldData (DB_COLUMN_NAME, vtValue) ;
				if (bRetCode == FALSE)
				{
					const ErrorObject *pError = mpRowset->GetLastError() ;
					nRetVal = pError->GetCode() ;
          mLogger->LogVarArgs (LOG_ERROR,  
            "Unable to add column name to the property collection. Error = %x", nRetVal) ;
          return Error ("Unable to add column name to the property collection", 
            IID_ICOMPropertyCollection, nRetVal) ;
				}
        else
        {
          vtValue = arEnumNamespace.c_str();
          bRetCode = mpRowset->AddFieldData (DB_ENUM_NAMESPACE, vtValue) ;
          if (bRetCode == FALSE)
          {
            const ErrorObject *pError = mpRowset->GetLastError() ;
            nRetVal = pError->GetCode() ;
            mLogger->LogVarArgs (LOG_ERROR,  
              "Unable to add column name to the property collection. Error = %x", nRetVal) ;
            return Error ("Unable to add enum type flag to the property collection", 
              IID_ICOMPropertyCollection, nRetVal) ;
          }
          else
          {
            vtValue = arEnumEnumeration.c_str() ;
            bRetCode = mpRowset->AddFieldData (DB_ENUM_ENUMERATION, vtValue) ;
            if (bRetCode == FALSE)
            {
              const ErrorObject *pError = mpRowset->GetLastError() ;
              nRetVal = pError->GetCode() ;
              mLogger->LogVarArgs (LOG_ERROR,  
                "Unable to add column name to the property collection. Error = %x", nRetVal) ;
              return Error ("Unable to add enum type flag to the property collection", 
                IID_ICOMPropertyCollection, nRetVal) ;
            }
            else
            {
              if (arFilterable == TRUE)
              {
                vtValue = L"Y" ;
              }
              else
              {
                vtValue = L"N" ;
              }
              bRetCode = mpRowset->AddFieldData (DB_FILTERABLE_FLAG, vtValue) ;
              if (bRetCode == FALSE)
              {
                const ErrorObject *pError = mpRowset->GetLastError() ;
                nRetVal = pError->GetCode() ;
                mLogger->LogVarArgs (LOG_ERROR,  
                  "Unable to add column name to the property collection. Error = %x", nRetVal) ;
                return Error ("Unable to add filterable flag to the property collection", 
                  IID_ICOMPropertyCollection, nRetVal) ;
              }
              else
              {
                if (arExportable == TRUE)
                {
                  vtValue = L"Y" ;
                }
                else
                {
                  vtValue = L"N" ;
                }
                bRetCode = mpRowset->AddFieldData (DB_EXPORTABLE_FLAG, vtValue) ;
                if (bRetCode == FALSE)
                {
                  const ErrorObject *pError = mpRowset->GetLastError() ;
                  nRetVal = pError->GetCode() ;
                  mLogger->LogVarArgs (LOG_ERROR,  
                    "Unable to add column name to the property collection. Error = %x", nRetVal) ;
                  return Error ("Unable to add exportable flag to the property collection", 
                    IID_ICOMPropertyCollection, nRetVal) ;
                }
              }
            }
          }
        }
			}
		}
	}
  return bRetCode ;
}



BOOL CCOMPropertyCollection::AddAccountUsageProperties(const std::wstring &arType)
{
	BOOL bRetCode=TRUE ;
	_variant_t vtValue ;

  // add the account id row ...
  bRetCode = AddRow (DB_ACCOUNT_ID, MTPROP_TYPE_INTEGER, DB_ACCOUNT_ID, L" ", L" ", 
    FALSE, FALSE) ;
  
  // if we havent hit an error ...
  if (bRetCode == TRUE)
  {
    bRetCode = AddRow (DB_TIMESTAMP, MTPROP_TYPE_DATE, DB_TIMESTAMP, L" ", L" ", 
      TRUE, TRUE) ;
  }
  // if we havent hit an error ...
  if (bRetCode == TRUE)
  {
    bRetCode = AddRow (DB_SESSION_ID, MTPROP_TYPE_INTEGER, DB_SESSION_ID, L" ", L" ",
      FALSE, FALSE) ;
  }
  // if we havent hit an error ...
  if (bRetCode == TRUE)
  {
    bRetCode = AddRow (DB_VIEW_ID, MTPROP_TYPE_INTEGER, DB_VIEW_ID, L" ", L" ",
      FALSE, FALSE) ;
  }
  // if we havent hit an error ...
  //if ((bRetCode == TRUE) && (arType.compareTo (DB_DISCOUNT_VIEW, RWWString::ignoreCase) != 0))
  if ((bRetCode == TRUE) && (_wcsicmp(arType.c_str(), DB_DISCOUNT_VIEW) != 0))
  {
    bRetCode = AddRow (DB_AMOUNT, MTPROP_TYPE_DECIMAL, DB_AMOUNT, L" ", L" ", 
      TRUE, TRUE) ;
  }
  // if we havent hit an error ...
  if (bRetCode == TRUE)
  {
    bRetCode = AddRow (DB_CURRENCY, MTPROP_TYPE_STRING, DB_CURRENCY, L" ", L" ",
      TRUE, TRUE) ;
  }
	return bRetCode ;
}

BOOL CCOMPropertyCollection::AddProperty (DBProductViewProperty *pProperty,
                                          const std::wstring &arViewType)
{
	BOOL bRetCode=TRUE ;
	std::wstring wstrType ;
	std::wstring wstrName ;
  std::wstring wstrColumnName ;
  std::wstring wstrEnumNamespace = L" ";
  std::wstring wstrEnumEnumeration = L" ";
  _variant_t vtValue ;
  BOOL bDataAnalysisView=FALSE ;
  
  // only add the properties that are user visible ...
  if (!pProperty->GetUserVisible())
  {
    return TRUE ;
  }
  // set data analysis view flag ...
  //if (arViewType.compareTo (DB_DATAANALYSIS_VIEW, RWWString::ignoreCase) == 0)
  if (_wcsicmp(arViewType.c_str(), DB_DATAANALYSIS_VIEW) == 0)
  {
    bDataAnalysisView = TRUE ;
  }

  // get the property name ...
  wstrName = pProperty->GetName() ;

  if ((_wcsicmp(wstrName.c_str(), DB_AMOUNT) == 0) && 
    (bDataAnalysisView == FALSE))
  {
    ;
  }
  else if ((_wcsicmp(wstrName.c_str(), DB_CURRENCY) == 0) && 
    (bDataAnalysisView == FALSE))
  {
    ;
  }
  else
  {
    // if this property isnt the tax amount ...
    if (_wcsicmp(wstrName.c_str(), DB_TAX_AMOUNT) != 0)
    {
      // get the column name and property type ...
      wstrName = pProperty->GetColumnName() ;
      if (pProperty->IsEnumType() == FALSE)
      {
        if (bDataAnalysisView == FALSE)
        {
          wstrColumnName = L"pv." ;
        }
        wstrColumnName += pProperty->GetColumnName() ;
      }
      else
      {
        wstrColumnName = pProperty->GetEnumColumnName() ;
      }
    }
    // otherwise ... this is the tax amount ...
    else
    {
      wstrColumnName = pProperty->GetColumnName() ;
    }
    CMSIXProperties::PropertyType nType = pProperty->GetMSIXType() ;
    switch (nType)
    {
    case CMSIXProperties::TYPE_STRING:
      wstrType = MTPROP_TYPE_STRING ;
      break ;

    case CMSIXProperties::TYPE_WIDESTRING:
      wstrType = MTPROP_TYPE_UNISTRING ;
      break ;

    case CMSIXProperties::TYPE_INT32:
      wstrType = MTPROP_TYPE_INTEGER ;
      break ;

    case CMSIXProperties::TYPE_INT64:
      wstrType = MTPROP_TYPE_BIGINTEGER ;
      break ;

    case CMSIXProperties::TYPE_TIMESTAMP:
      wstrType = MTPROP_TYPE_DATE ;
      break ;

    case CMSIXProperties::TYPE_FLOAT:
      wstrType = MTPROP_TYPE_FLOAT ;
      break ;

    case CMSIXProperties::TYPE_DOUBLE:
      wstrType = MTPROP_TYPE_DOUBLE ;
      break ;

    case CMSIXProperties::TYPE_NUMERIC:
      wstrType = MTPROP_TYPE_DECIMAL ;
      break ;

    case CMSIXProperties::TYPE_DECIMAL:
      wstrType = MTPROP_TYPE_DECIMAL ;
      break ;

    case CMSIXProperties::TYPE_ENUM:
      pProperty->GetEnumInformation(wstrEnumNamespace, wstrEnumEnumeration) ;
      wstrType = MTPROP_TYPE_ENUM ;
      break ;

    case CMSIXProperties::TYPE_BOOLEAN:
      wstrType = MTPROP_TYPE_BOOLEAN ;
      break ;

    default:
      wstrType = MTPROP_TYPE_UNKNOWN ;
      break ;
    }
    // add the row ... pass the column name as the name ...
    bRetCode = AddRow (wstrName, wstrType, wstrColumnName, 
      wstrEnumNamespace, wstrEnumEnumeration, pProperty->GetFilterable(), pProperty->GetExportable()) ;
  }

  // report the error if we found one ...
  if (bRetCode == FALSE)
  {
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to add row with name = %s and type = %s",
      ascii(wstrName.c_str()), ascii(wstrType.c_str())) ;
  }

	return bRetCode ;
}

BOOL CCOMPropertyCollection::InitializePropertyCollection ()
{
		// local variables
	BOOL bRetCode=TRUE ;
	int nNumFields ;
	HRESULT nRetVal ;

	// allocate a new rowset
	mpRowset = new DBInMemRowset ;
	ASSERT (mpRowset) ;

	// iterate through the fields definition array ...
	nNumFields = (sizeof (VIEW_PROPERTY_FIELDS) / sizeof (FIELD_DEFINITION)) ;
	for (int i=0 ; i < nNumFields && bRetCode == TRUE ; i++)
	{
		// add the field definition ...
		bRetCode = mpRowset->AddFieldDefinition (VIEW_PROPERTY_FIELDS[i].FieldName,
			VIEW_PROPERTY_FIELDS[i].FieldType) ;
		if (bRetCode == FALSE)
		{
			const ErrorObject *pError = mpRowset->GetLastError() ;
      nRetVal = pError->GetCode() ;
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to initialize the property collection. Error = %x", nRetVal) ;
      return Error ("Unable to initialize the property collection", 
        IID_ICOMPropertyCollection, nRetVal) ;
		}
	}

	return bRetCode ;
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
STDMETHODIMP CCOMPropertyCollection::MoveNext()
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
      return Error ("Unable to move to the next row of the rowset", 
        IID_ICOMPropertyCollection, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to move to the next record in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to move to the next row of the rowset", 
      IID_ICOMPropertyCollection, nRetVal) ;
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
STDMETHODIMP CCOMPropertyCollection::MoveFirst()
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
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to move to the first row of the rowset. Error = %x", nRetVal) ;
      return Error ("Unable to move to the first row of the rowset", 
        IID_ICOMPropertyCollection, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to move to the first record in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to move to the first row of the rowset", 
      IID_ICOMPropertyCollection, nRetVal) ;
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
STDMETHODIMP CCOMPropertyCollection::MoveLast()
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
      return Error ("Unable to move to the last row of the rowset", 
        IID_ICOMPropertyCollection, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to move to the last record in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to move to the last row of the rowset", 
      IID_ICOMPropertyCollection, nRetVal) ;
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
STDMETHODIMP CCOMPropertyCollection::get_Count(long * pVal)
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
    return Error ("Unable to get the column count of the rowset", 
      IID_ICOMPropertyCollection, nRetVal) ;
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
STDMETHODIMP CCOMPropertyCollection::get_Name(VARIANT vtIndex, BSTR * pVal)
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
      return Error ("Unable to get the name of a column in the rowset", 
        IID_ICOMPropertyCollection, nRetVal) ;
    }
    *pVal = ::SysAllocString (wstrName.c_str()) ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get the name of a column in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the name of a column in the rowset", 
      IID_ICOMPropertyCollection, nRetVal) ;
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
STDMETHODIMP CCOMPropertyCollection::get_Value(VARIANT vtIndex, VARIANT * pVal)
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
      mLogger->LogVarArgs (LOG_ERROR,  
        "Unable to get the value of a column of the rowset. Error = %x", nRetVal) ;
      return Error ("Unable to get the value of a column in the rowset", 
        IID_ICOMPropertyCollection, nRetVal) ;
    }
    *pVal = vtValue.Detach() ;
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger->LogVarArgs (LOG_ERROR,  
      "Unable to get the value of a column in the rowset. Error = %x", nRetVal) ;
    return Error ("Unable to get the value of a column in the rowset", 
      IID_ICOMPropertyCollection, nRetVal) ;
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
STDMETHODIMP CCOMPropertyCollection::get_Type(VARIANT vtIndex, BSTR * pVal)
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
      return Error ("Unable to get the type of a column in the rowset", 
        IID_ICOMPropertyCollection, nRetVal) ;
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
    return Error ("Unable to get the type of a column in the rowset", 
      IID_ICOMPropertyCollection, nRetVal) ;
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
STDMETHODIMP CCOMPropertyCollection::get_RecordCount(long * pVal)
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
    return Error ("Unable to get the record count of the rowset", 
      IID_ICOMPropertyCollection, nRetVal) ;
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
STDMETHODIMP CCOMPropertyCollection::get_EOF(VARIANT * pVal)
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
    return Error ("Unable to get the state of the rowset", 
      IID_ICOMPropertyCollection, nRetVal) ;
  }

	return (nRetVal);
}

