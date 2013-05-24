/**************************************************************************
 * @doc DBViewHierarchy
 * 
 * @module  Encapsulation of a view collection|
 *  
 * This class encapsulates a view collection
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
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
 * @index | DBViewHierarchy
 ***************************************************************************/

#include <metra.h>
#include <DBViewHierarchy.h>

#include <DBInMemRowset.h>
#include <MTUtil.h>

#include <mtprogids.h>
#include <DBSummaryView.h>
#include <DBProductView.h>
#include <DBDiscountView.h>
#include <DBDataAnalysisView.h>
#include <DBConstants.h>
#include <DBSQLRowset.h>
#include <mtglobal_msg.h>

#include <loggerconfig.h>
#include <DBUsageCycle.h>
#include <mtcomerr.h>
#include <SetIterate.h>
#include <RcdHelper.h>
#include <vector>
#include <stdutils.h>
#include <MTDec.h>
#include <NTRegistryIO.h>

using namespace std;


const char* pRCDQueryString = "config\\ViewInfo\\view_hierarchy.xml";

#include <ConfigDir.h>
// static definition ...
DBViewHierarchy * DBViewHierarchy::mpsViews = 0;
DWORD DBViewHierarchy::msNumRefs = 0 ;
NTThreadLock DBViewHierarchy::msLock ;

typedef struct  {
	wchar_t FieldName[30];
	DataTypeEnum FieldType;
	long length;
	bool bLookup;
} DisconnectedFieldDefs;

// definition for summary rowset fields ...
DisconnectedFieldDefs SummaryFields[] = 
{
  { DB_VIEW_ID, adInteger,-1,false},
  { DB_VIEW_NAME, adBSTR ,256,false},
  { DB_DESCRIPTION_ID, adInteger ,-1,false},
  { DB_VIEW_TYPE, adBSTR,256 ,false},
  { DB_AMOUNT, adDecimal ,-1,false},
  { DB_CURRENCY, adBSTR ,3,false},
  { DB_COUNT, adInteger ,-1,false},
  { DB_TAX_AMOUNT, adDecimal,-1 ,false},
  { DB_AMOUNT_WITH_TAX, adDecimal,-1,false},
  { DB_ACCOUNT_ID, adInteger,-1,true},
  { DB_INTERVAL_ID, adInteger,-1,true},
  { DB_INTERVAL_START, adDate,-1,true},
  { DB_INTERVAL_END, adDate,-1,true},
	{ DB_AGG_RATE,adBSTR,1,false},
	{ DB_SECONDPASS,adBSTR,1,false}
} ;

//
//	@mfunc
//	Constructor. Initialize the appropriate data members.
//  @rdesc 
//  No return value
//
DBView::DBView()
{
}

//
//	@mfunc
//	Destructor. 
//  @rdesc 
//  No return value
//
DBView::~DBView()
{
  // delet the allocated memory ...
  mChildViewList.clear() ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBView::InitializeInMemRowsetForSummary (DBSQLRowset * & arpRowset,
                                              const long &arAcctID,
                                              const long &arIntervalID)
{
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  long nIntervalID=-1 ;

	ASSERT(!"Fix me");

	/*
  // call initialize non sql rowset ...
  bRetCode = InitializeInMemRowset (arpRowset) ;

  // if we havent gotten an error yet ...
  if (bRetCode == TRUE)
  {
    // add a row into the rowset ...
    bRetCode = arpRowset->AddRow() ;
    if (bRetCode == FALSE)
    {
      SetError (arpRowset->GetLastError(),
        "InitializeInMemRowsetForSummary() failed. Unable to add row.") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  // if we havent gotten an error yet ...
  if (bRetCode == TRUE)
  {
    // initialize the columns in the rowset ...
    vtValue = (long) mID ;
    bRetCode = arpRowset->AddFieldData (DB_VIEW_ID, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError (arpRowset->GetLastError(),
        "InitializeInMemRowsetForSummary() failed. Unable to add view id field.") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {
      vtValue = mName.c_str() ;
      bRetCode = arpRowset->AddFieldData (DB_VIEW_NAME, vtValue) ;
      if (bRetCode == FALSE)
      {
        SetError (arpRowset->GetLastError(),
          "InitializeInMemRowsetForSummary() failed. Unable to add view name field.") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      }
      else
      {
        vtValue = DB_SUMMARY_VIEW ;
        bRetCode = arpRowset->AddFieldData (DB_VIEW_TYPE, vtValue) ;
        if (bRetCode == FALSE)
        {
          SetError (arpRowset->GetLastError(),
            "InitializeInMemRowsetForSummary() failed. Unable to add view type field.") ;
          mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        }
      }
    }
  }
  // if we havent gotten an error yet ...
  if (bRetCode == TRUE)
  {
    vtValue = (long) mDescriptionID ;
    bRetCode = arpRowset->AddFieldData (DB_DESCRIPTION_ID, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError (arpRowset->GetLastError(),
        "InitializeInMemRowsetForSummary() failed. Unable to add description id field.") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {
      vtValue.vt = VT_DECIMAL ;
      vtValue.decVal.scale = 0 ;
      vtValue.decVal.sign = 0 ;
      vtValue.decVal.Lo64 = 0 ;
      bRetCode = arpRowset->AddFieldData (DB_AMOUNT, vtValue) ;
      if (bRetCode == FALSE)
      {
        SetError (arpRowset->GetLastError(),
          "InitializeInMemRowsetForSummary() failed. Unable to add ammount field.") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      }
      else
      {
        vtValue = DB_CURRENCY ;
        bRetCode = arpRowset->AddFieldData (DB_CURRENCY, vtValue) ;
        if (bRetCode == FALSE)
        {
          SetError (arpRowset->GetLastError(),
            "InitializeInMemRowsetForSummary() failed. Unable to add currency field.") ;
          mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        }
        else
        {
          vtValue = (long) 0 ;
          bRetCode = arpRowset->AddFieldData (DB_COUNT, vtValue) ;
          if (bRetCode == FALSE)
          {
            SetError (arpRowset->GetLastError(),
              "InitializeInMemRowsetForSummary() failed. Unable to add count field.") ;
            mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
          }
        }
      }
    }
  }
  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    vtValue.vt = VT_DECIMAL ;
    vtValue.decVal.scale = 0 ;
    vtValue.decVal.sign = 0 ;
    vtValue.decVal.Lo64 = 0 ;
    bRetCode = arpRowset->AddFieldData (DB_TAX_AMOUNT, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError (arpRowset->GetLastError(),
        "InitializeInMemRowsetForSummary() failed. Unable to add tax amount field.") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {
      vtValue.vt = VT_DECIMAL ;
      vtValue.decVal.scale = 0 ;
      vtValue.decVal.sign = 0 ;
      vtValue.decVal.Lo64 = 0 ;
      bRetCode = arpRowset->AddFieldData (DB_AMOUNT_WITH_TAX, vtValue) ;
      if (bRetCode == FALSE)
      {
        SetError (arpRowset->GetLastError(),
          "InitializeInMemRowsetForSummary() failed. Unable to add amount with taxfield.") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      }
      else
      {
        vtValue = arAcctID ;
        bRetCode = arpRowset->AddFieldData (DB_ACCOUNT_ID, vtValue) ;
        if (bRetCode == FALSE)
        {
          SetError (arpRowset->GetLastError(),
            "InitializeInMemRowsetForSummary() failed. Unable to add account id field.") ;
          mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        }
        else
        {
          vtValue = arIntervalID ;
          bRetCode = arpRowset->AddFieldData (DB_INTERVAL_ID, vtValue) ;
          if (bRetCode == FALSE)
          {
            SetError (arpRowset->GetLastError(),
              "InitializeInMemRowsetForSummary() failed. Unable to add interval id field.") ;
            mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
          }
        }
      }
    }
  }

  // insert the interval start and end date ...
  if (bRetCode == TRUE)
  {
    // get a pointer to the usage cycle collection ...
    DATE dtStart, dtEnd ;
    DBUsageCycleCollection *pUsageCycle = DBUsageCycleCollection::GetInstance() ;
    if (pUsageCycle == NULL)
    {
      SetError(DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
        "DBView::InitializeInMemRowsetForSummary", "Unable to get usage cycle collection");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }

    // get the start and end time for the interval id ...
    bRetCode = pUsageCycle->GetIntervalStartAndEndDate (arIntervalID, 
      dtStart, dtEnd) ;
    if (bRetCode == FALSE)
    {
      mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get start and end date for interval = %d", nIntervalID) ;
    }

    // add the interval start and interval end ...
    vtValue = (_variant_t (dtStart,VT_DATE))  ;
    bRetCode = arpRowset->AddFieldData (DB_INTERVAL_START, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError(arpRowset->GetLastError(),
        "InitializeInMemRowsetForSummary() failed. Unable to add interval start.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {
      vtValue = (_variant_t (dtEnd, VT_DATE))  ;
      bRetCode = arpRowset->AddFieldData (DB_INTERVAL_END, vtValue) ;
      if (bRetCode == FALSE)
      {
        SetError(arpRowset->GetLastError(),
          "InitializeInMemRowsetForSummary() failed. Unable to add interval end.");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      }
    }
  }
  return bRetCode ;
	*/
	return TRUE;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBView::InitializeInMemRowset (DBSQLRowset * & arpRowset)
{
    // local variables 
  BOOL bRetCode=TRUE ;
  int nNumFields ;

	try {
  
		// initialize the disconnected rowset
		arpRowset->InitDisconnected();

		// iterate through the fields definition array ...
		nNumFields = (sizeof (SummaryFields) / sizeof (DisconnectedFieldDefs)) ;
		for (int i=0 ; i < nNumFields && bRetCode == TRUE ; i++)
		{
			// add the field definition ...
			arpRowset->AddColumnDefinition(SummaryFields[i].FieldName,
				SummaryFields[i].FieldType,SummaryFields[i].length);
		}
		arpRowset->OpenDisconnected();
	}
	catch(_com_error&) {
		SetError(::GetLastError(),ERROR_MODULE,ERROR_LINE,"InitializeInMemRowset","Unable to add field definition");
		mLogger->LogErrorObject (LOG_ERROR, GetLastError());
		return FALSE;
	}
  
  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBView::InsertIntoInMemRowset (DBSQLRowset * & arpDisplayRowset, 
                                    DBSQLRowset * apGeneratedRowset)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtIndex, vtValue ;
  std::wstring wstrName ;
  int nCount=0 ;
  long nIntervalID=-1 ;
  BOOL bRowAdded=FALSE;

	try {

		// iterate through the generated rowset and insert the columns into the 
		// display rowset ...
		for (int i=0; !apGeneratedRowset->AtEOF() && bRetCode == TRUE;
			i++, bRetCode = apGeneratedRowset->MoveNext()) {
			// set the row added flag
			bRowAdded = TRUE;

			arpDisplayRowset->AddRow();     // add a new row into the display rowset

			// get the number of columns in the row
			nCount = apGeneratedRowset->GetCount();
      
			// iterate through the columns 
			for (int j=0 ; j < nCount && bRetCode == TRUE; j++)
			{
				// initialize the variant 
				vtIndex = (long) j ;
      
				// get the name ...
				wstrName.resize(0) ;
				bRetCode = apGeneratedRowset->GetName (vtIndex, wstrName) ;
				if (bRetCode == FALSE)
				{
					SetError(apGeneratedRowset->GetLastError(),
						"InsertIntoInMemRowset() failed. Unable to get name.");
					mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
				}
				else
				{
					// get the value ...
					bRetCode = apGeneratedRowset->GetValue (vtIndex, vtValue) ;
					if (bRetCode == FALSE)
					{
						SetError(apGeneratedRowset->GetLastError(),
							"InsertIntoInMemRowset() failed. Unable to get value.");
						mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
					}
					else
					{
						// insert the name-value into the new row ...
						arpDisplayRowset->AddColumnData (wstrName.c_str(), vtValue) ;
						// if this is property is the interval id ... 
						if (_wcsicmp(wstrName.c_str(), DB_INTERVAL_ID) == 0)
						{
							nIntervalID = vtValue.lVal ;
            
							// insert the interval start and end date ...
							if ((bRetCode == TRUE) && (bRowAdded == TRUE))
							{
								// get a pointer to the usage cycle collection ...
								DATE dtStart, dtEnd ;
								MTAutoSingleton<DBUsageCycleCollection> pUsageCycle;
              
								// get the start and end time for the interval id ...
								bRetCode = pUsageCycle->GetIntervalStartAndEndDate (nIntervalID, 
									dtStart, dtEnd) ;
								if (bRetCode == FALSE)
								{
									mLogger->LogVarArgs (LOG_ERROR, 
										"Unable to get start and end date for interval = %d", nIntervalID) ;
									return FALSE;
								}
              
								// add the interval start and interval end ...
								vtValue = (_variant_t (dtStart, VT_DATE)) ;
								arpDisplayRowset->AddColumnData (DB_INTERVAL_START, vtValue) ;
								vtValue = (_variant_t (dtEnd, VT_DATE)) ;
								arpDisplayRowset->AddColumnData (DB_INTERVAL_END, vtValue) ;
							}
						}
					}
				}
			}
		}
	}
	catch(_com_error& e) {
		// Yeah baby!  I bet you like this cast!  Rock on.
		LogAndReturnComError(*((NTLogger*)(&mLogger)),e);
		bRetCode = FALSE;
	}

  return bRetCode;
}

BOOL DBView::InsertCurrentRowIntoInMemRowset (long aIntervalID,long aAccountID,
																							DBSQLRowset& arpRowset,
																							ROWSETLib::IMTSQLRowsetPtr apNewRowset)
{
	arpRowset.AddRow();     // add a new row into the display rowset

	// step 1: populate the in memory rowset with our data
	int nNumFields = (sizeof (SummaryFields) / sizeof (DisconnectedFieldDefs)) ;
	for (int i=0 ; i < nNumFields; i++) {
		if(!SummaryFields[i].bLookup) {
			arpRowset.AddColumnData(SummaryFields[i].FieldName,apNewRowset->GetValue(SummaryFields[i].FieldName));
		}
	}
	// step 2: populate the interval information correctly
	DATE start,end;
	MTAutoSingleton<DBUsageCycleCollection> UsageCycleCol;

	if(!UsageCycleCol->GetIntervalStartAndEndDate(aIntervalID,start,end)) {
		// XXX is this all we need here
		ASSERT(!"Why did this crash?");
		return FALSE;
	}
	else {
	
		arpRowset.AddColumnData(DB_ACCOUNT_ID,aAccountID);
		arpRowset.AddColumnData(DB_INTERVAL_ID,aIntervalID);
		arpRowset.AddColumnData(DB_INTERVAL_START,_variant_t(start,VT_DATE));
		arpRowset.AddColumnData(DB_INTERVAL_END,_variant_t(end,VT_DATE));
	}

	return TRUE;
}


//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBView::SummarizeIntoInMemRowset (DBSQLRowset * & arpDisplayRowset, 
                                               DBSQLRowset * apGeneratedRowset)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
  std::wstring wstrName ;
  std::wstring wstrCurrency ;
  MTDecimal nAmount ;
  MTDecimal nCurrAmt ;
  MTDecimal nAmountWithTax ;
  MTDecimal nCurrAmtWithTax ;
  MTDecimal nTaxAmount ;
  MTDecimal nCurrTaxAmt ;
  int nCount=0 ;

	ASSERT(0);
  /*
  // iterate through the generated rowset and summarize the amount into the
  // display rowset ...
  for (int i=0; !apGeneratedRowset->AtEOF() && bRetCode == TRUE; 
  i++, bRetCode = apGeneratedRowset->MoveNext())
  {
    // get the value of the amount ...
    vtValue = DB_AMOUNT ;
    bRetCode = apGeneratedRowset->GetDecimalValue (vtValue, nAmount) ;
    if (bRetCode == FALSE)
    {
      SetError(apGeneratedRowset->GetLastError(),
        "SummarizeIntoInMemRowset() failed. Unable to get amount value");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    // get the value of amount in the display rowset ...
    bRetCode = arpDisplayRowset->GetDecimalValue (vtValue, nCurrAmt) ;
    if (bRetCode == FALSE)
    {
      SetError(arpDisplayRowset->GetLastError(),
        "SummarizeIntoInMemRowset() failed. Unable to get current amount value.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    // add the new amopunt to the current amount ...
    nCurrAmt += nAmount ;
    
    // modify the amount in the display rowset ...
    vtValue = (DECIMAL) nCurrAmt ;
    bRetCode = arpDisplayRowset->ModifyFieldData (DB_AMOUNT, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError(arpDisplayRowset->GetLastError(), 
        "SummarizeIntoInMemRowset() failed. Unable to get amount");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }

    // get the value of the amount ...
    vtValue = DB_TAX_AMOUNT ;
    bRetCode = apGeneratedRowset->GetDecimalValue (vtValue, nTaxAmount) ;
    if (bRetCode == FALSE)
    {
      SetError(apGeneratedRowset->GetLastError(),
        "SummarizeIntoInMemRowset() failed. Unable to get tax amount value");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    // get the value of amount in the display rowset ...
    bRetCode = arpDisplayRowset->GetDecimalValue (vtValue, nCurrTaxAmt) ;
    if (bRetCode == FALSE)
    {
      SetError(arpDisplayRowset->GetLastError(),
        "SummarizeIntoInMemRowset() failed. Unable to get current tax amount value.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    // add the new amopunt to the current amount ...
    nCurrTaxAmt += nTaxAmount ;
    
    // modify the amount in the display rowset ...
    vtValue = (DECIMAL) nCurrTaxAmt ;
    bRetCode = arpDisplayRowset->ModifyFieldData (DB_TAX_AMOUNT, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError(arpDisplayRowset->GetLastError(), 
        "SummarizeIntoInMemRowset() failed. Unable to get tax amount");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }

        // get the value of the amount ...
    vtValue = DB_AMOUNT_WITH_TAX ;
    bRetCode = apGeneratedRowset->GetDecimalValue (vtValue, nAmountWithTax) ;
    if (bRetCode == FALSE)
    {
      SetError(apGeneratedRowset->GetLastError(),
        "SummarizeIntoInMemRowset() failed. Unable to get amount with tax value");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    // get the value of amount in the display rowset ...
    bRetCode = arpDisplayRowset->GetDecimalValue (vtValue, nCurrAmtWithTax) ;
    if (bRetCode == FALSE)
    {
      SetError(arpDisplayRowset->GetLastError(),
        "SummarizeIntoInMemRowset() failed. Unable to get current amount with tax value.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    // add the new amopunt to the current amount ...
    nCurrAmtWithTax += nAmountWithTax ;
    
    // modify the amount in the display rowset ...
    vtValue = (DECIMAL) nCurrAmtWithTax ;
    bRetCode = arpDisplayRowset->ModifyFieldData (DB_AMOUNT_WITH_TAX, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError(arpDisplayRowset->GetLastError(), 
        "SummarizeIntoInMemRowset() failed. Unable to get tax amount");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    // get the value of the count in the display rowset ...
    vtValue = DB_COUNT ;
    bRetCode = arpDisplayRowset->GetIntValue (vtValue, nCount) ;
    if (bRetCode == FALSE)
    {
      SetError(arpDisplayRowset->GetLastError(), 
        "SummarizeIntoInMemRowset() failed. Unable to get count");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    // increment the count ...
    nCount++ ;
    
    // modify the count in the display rowset ...
    vtValue = (long) nCount ;
    bRetCode = arpDisplayRowset->ModifyFieldData (DB_COUNT, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError(arpDisplayRowset->GetLastError(),
        "SummarizeIntoInMemRowset() failed. Unable to modify count");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    // get the value of the CURRENCY from the generated rowset...
    vtValue = DB_CURRENCY ;
    bRetCode = apGeneratedRowset->GetWCharValue (vtValue, wstrCurrency) ;
    if (bRetCode == FALSE)
    {
      SetError(arpDisplayRowset->GetLastError(),
        "SummarizeIntoInMemRowset() failed. Unable to get currency.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    // modify the CURRENCY in the display rowset ...
    vtValue = wstrCurrency.c_str()  ;
    bRetCode = arpDisplayRowset->ModifyFieldData (DB_CURRENCY, vtValue) ;
    if (bRetCode == FALSE)
    {
      SetError(arpDisplayRowset->GetLastError(),
        "SummarizeIntoInMemRowset() failed. Unable to modify currency.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
  }
	*/
  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBView::InsertDefaultRowIntoInMemRowset (DBSQLRowset * & arpRowset, 
    const int &arViewID, const std::wstring &arViewName, const int &arDescID, 
    const std::wstring &arViewType, const int &arAcctID, const int &arIntervalID)
{
  BOOL bRetCode=TRUE ;
  _variant_t vtValue ;
	
	try {

		// add a row into the rowset ...
		arpRowset->AddRow();

		// initialize the columns in the rowset ...
		vtValue = (long) arViewID ;
		arpRowset->AddColumnData (DB_VIEW_ID, vtValue);
		vtValue = arViewName.c_str() ;
		arpRowset->AddColumnData (DB_VIEW_NAME, vtValue) ;
		vtValue = arViewType.c_str() ;
		arpRowset->AddColumnData (DB_VIEW_TYPE, vtValue) ;
		vtValue = (long) arDescID ;
		arpRowset->AddColumnData (DB_DESCRIPTION_ID, vtValue) ;
		vtValue = 0.0 ;
		arpRowset->AddColumnData (DB_AMOUNT, vtValue) ;
		vtValue = DB_CURRENCY ;
		arpRowset->AddColumnData (DB_CURRENCY, vtValue) ;
		vtValue = (long) 0 ;
		arpRowset->AddColumnData (DB_COUNT, vtValue) ;
		vtValue = 0.0 ;
		arpRowset->AddColumnData (DB_TAX_AMOUNT, vtValue) ;
		vtValue = 0.0 ;
		arpRowset->AddColumnData (DB_AMOUNT_WITH_TAX, vtValue) ;
		vtValue = (long) arAcctID ;
		arpRowset->AddColumnData (DB_ACCOUNT_ID, vtValue) ;
		vtValue = (long) arIntervalID ;
		arpRowset->AddColumnData (DB_INTERVAL_ID, vtValue) ;

	// get a pointer to the usage cycle collection ...
		DATE dtStart, dtEnd;
		MTAutoSingleton<DBUsageCycleCollection> pUsageCycle;

		// get the start and end time for the interval id ...
		pUsageCycle->GetIntervalStartAndEndDate (arIntervalID, 
			dtStart, dtEnd) ;
		if (bRetCode == FALSE)
		{
			mLogger->LogVarArgs (LOG_ERROR, 
				"Unable to get start and end date for interval = %d", arIntervalID) ;
			return FALSE;
		}

		// add the interval start and interval end ...
		vtValue = (_variant_t (dtStart,VT_DATE))  ;
		arpRowset->AddColumnData (DB_INTERVAL_START, vtValue) ;
		vtValue = (_variant_t (dtEnd, VT_DATE))  ;
		arpRowset->AddColumnData (DB_INTERVAL_END, vtValue) ;
	}
	catch(_com_error& e) {
		LogAndReturnComError(*((NTLogger*)(&mLogger)),e);
		bRetCode = FALSE;
	}
  return bRetCode ;
}

//
// @mfunc
// LoadProducts Write all product views beneath this view to the database
// @rdesc
// Returns TRUE if write succeeded and all children succeded, FALSE otherwise
//
BOOL DBView::LoadProducts(DBViewHierarchy* apHierarchy, DBView* apParent)
{
	if (_wcsicmp(mType.c_str(), DB_PRODUCT_VIEW) == 0)
	{
		try
		{
			ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
			rowset->Init(L"\\Queries\\Database");
			rowset->SetQueryTag(L"__INSERT_VIEW_HIERARCHY__");
			rowset->AddParam(L"%%ID_VIEW%%", (long)mID);
			if(NULL != apParent && 
				 _wcsicmp(apParent->GetViewType().c_str(), DB_PRODUCT_VIEW) == 0)
			{
				rowset->AddParam(L"%%ID_VIEW_PARENT%%", (long)apParent->GetViewID());
			}
			else
			{
				// Roots are their own parent
				rowset->AddParam(L"%%ID_VIEW_PARENT%%", (long)mID);
			}
			rowset->Execute();
		}
		catch(_com_error & e)
		{
			LogAndReturnComError(*((NTLogger*)(&mLogger)),e);
			return FALSE;
		}
	}
	
	for (DBViewIDCollIter Iter = mChildViewList.begin();
			 Iter != mChildViewList.end();
			 Iter++)
	{
		// find the view ...
		int nViewID = *Iter ;
		DBView* pView;
		BOOL bRetCode;
		bRetCode = apHierarchy->FindView (nViewID, (DBView * &) pView) ;
		if (bRetCode == FALSE)
		{
			return FALSE;
		}
		bRetCode = pView->LoadProducts(apHierarchy, this);
		if (bRetCode == FALSE)
		{
			return FALSE;
		}
	}
	return TRUE;
}

//
//	@mfunc
//	Constructor. Initialize the appropriate data members.
//  @rdesc 
//  No return value
//
DBViewHierarchy::DBViewHierarchy()
: mObserverInitialized(FALSE)
{
	mViewColl = new DBViewColl();
}

//
//	@mfunc
//	Destructor. 
//  @rdesc 
//  No return value
//
DBViewHierarchy::~DBViewHierarchy()
{
	
  TearDown();
}

void DBViewHierarchy::TearDown(bool bDeleteCollecctionObj)
{
	mCollLock.Lock();

	for (DBViewCollIter Iter = mViewColl->begin();
			 Iter != mViewColl->end();
			 Iter++)
	{
		DBView* pView = Iter->second;
		delete pView ;
	}
 mViewColl->clear() ;
 if(bDeleteCollecctionObj) {
	delete mViewColl;
 }

 mCollLock.Unlock();
}



// ----------------------------------------------------------------
// Name:     			GetFileListFromRcd
// Return Value:  a List of files
// Raised Errors:
// Description:  return a list of view_hierarchy files to the init code 
// ----------------------------------------------------------------

RCDLib::IMTRcdFileListPtr DBViewHierarchy::GetFileListFromRcd()
{
	InitRcd();
	// look for all the view_hierarchy files and don't recurse
	return mRCD->RunQuery(pRCDQueryString,VARIANT_TRUE);
}

// ----------------------------------------------------------------
// Name:     			GetEnumFileList
// Arguments:     EnumFileList (std::vector)	- list of files retrieved from master file list
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY 
// ----------------------------------------------------------------

BOOL DBViewHierarchy::InitSummaryView(long aViewID,
																			const std::wstring& wstrViewName,
																			MTConfigLib::IMTConfigPropSetPtr& aProp,
																			vector<DBView *>& aList,
																			DBViewColl& aCol)
{
	// get additional properties from XML
	BOOL bRetCode =  TRUE;
	try {
		long nParentViewID = aProp->NextLongWithName("id_parent_view") ;
		std::wstring wstrViewType =  (const wchar_t*)_bstr_t(aProp->NextStringWithName("nm_view_type"));

		// allocate a new DBSummaryView object ...
		DBSummaryView* pDBSummaryView = new DBSummaryView ;
		ASSERT (pDBSummaryView) ;
		if (pDBSummaryView == NULL)
		{
			SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, 
				"DBViewHierarchy::Init") ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			return FALSE ;
		}

		// initialize the summary view object ...
		bRetCode = pDBSummaryView->Init(wstrViewType, aViewID, wstrViewName, aViewID) ;
		if (bRetCode == FALSE)
		{
			SetError (pDBSummaryView->GetLastError(),
				"Init() failed. Unable to initialize view.") ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			delete pDBSummaryView ;
		}
		else
		{
			// add the element to the view collection ...
			aCol[pDBSummaryView->GetViewID()] = pDBSummaryView ;
			aList.push_back (pDBSummaryView) ;

			// add the parent view id ... 
			pDBSummaryView->AddParentViewID(nParentViewID) ;
		}
		pDBSummaryView = NULL ;
	}
	catch(_com_error& err) {
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		bRetCode = FALSE;
	}
	return bRetCode;
}

// ----------------------------------------------------------------
// Name:     			GetEnumFileList
// Arguments:     EnumFileList (std::vector)	- list of files retrieved from master file list
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY 
// ----------------------------------------------------------------

BOOL DBViewHierarchy::InitProductView(long aViewID,
										 const std::wstring& wstrViewName,
										 MTConfigLib::IMTConfigPropSetPtr& aProp,
										 vector<DBView *>& aList,
										 CProductViewCollection& PVColl,
										 DBViewColl& aCol)
{
	BOOL bRetCode = TRUE;
	CMSIXDefinition *pProductView ;

	try {
		long nParentViewID = aProp->NextLongWithName("id_parent_view") ;
		std::wstring wstrViewType =  (const wchar_t*)_bstr_t(aProp->NextStringWithName("nm_view_type"));


		// allocate a new DBSummaryView object ...
		DBProductView* pDBProductView = new DBProductView ;
		ASSERT (pDBProductView) ;
		if (pDBProductView == NULL)
		{
			SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, 
				"DBViewHierarchy::Init") ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			return FALSE ;
		}

		// find the view in the product view collection ...
		bRetCode = PVColl.FindProductView (wstrViewName, pProductView) ;
		if (bRetCode == FALSE)
		{
			SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, 
				"DBViewHierarchy::Init");
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			mLogger->LogVarArgs (LOG_WARNING, "Unable to find product view %s in collection.",
				(const char*)ascii(wstrViewName).c_str()) ;
			delete pDBProductView ;

			// we logged the fact that we found an invalid view item so change bRetCode ...
			bRetCode = TRUE ;
		}
		// otherwise ... 
		else
		{
			// initialize the product view object ...
			bRetCode = pDBProductView->Init(wstrViewType, aViewID, wstrViewName,aViewID, pProductView) ;
			if (bRetCode == FALSE)
			{
				SetError (pDBProductView->GetLastError(),
					"Init() failed. Unable to initialize product view.") ;
				mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
				delete pDBProductView ;
			}
			else
			{
				// add the element to the view collection ...
				aCol[pDBProductView->GetViewID()] = pDBProductView ;
				aList.push_back (pDBProductView) ;

				// add the parent view id ... 
				pDBProductView->AddParentViewID(nParentViewID) ;
			}
		}
		pDBProductView = NULL ;
	}
	catch(_com_error& err) {
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		bRetCode = FALSE;
	}
	return bRetCode;
}

// ----------------------------------------------------------------
// Name:     			GetEnumFileList
// Arguments:     EnumFileList (std::vector)	- list of files retrieved from master file list
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY 
// ----------------------------------------------------------------

BOOL DBViewHierarchy::InitDiscountView(long aID,
										 const std::wstring& wstrViewName,
										 MTConfigLib::IMTConfigPropSetPtr& aProp,
										 vector<DBView *>& aList,
										 CProductViewCollection& PVColl,
										 DBViewColl& aCol)
{
	BOOL bRetCode = TRUE;
	CMSIXDefinition *pProductView;
	try {
		long nParentViewID = aProp->NextLongWithName("id_parent_view") ;
		std::wstring wstrViewType =  (const wchar_t*)_bstr_t(aProp->NextStringWithName("nm_view_type"));

    // allocate a new DBDiscountView object ...
    DBDiscountView* pDBDiscountView = new DBDiscountView;
    ASSERT (pDBDiscountView) ;
    if (pDBDiscountView == NULL)
    {
      SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, 
        "DBViewHierarchy::Init") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return FALSE;
    }
    
    // find the view in the product view collection ...
    bRetCode = PVColl.FindProductView (wstrViewName, pProductView) ;
    if (bRetCode == FALSE)
    {
      SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, 
        "DBViewHierarchy::Init");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_WARNING, "Unable to find discount view %s in collection.",
        (const char*)ascii(wstrViewName).c_str()) ;
      delete pDBDiscountView ;

      // we logged the fact that we found an invalid view item so change bRetCode ...
      bRetCode = TRUE ;
    }
    // otherwise ... 
    else
    {
      // initialize the product view object ...
      bRetCode = pDBDiscountView->Init(wstrViewType, aID, wstrViewName, 
        aID, pProductView) ;
      if (bRetCode == FALSE)
      {
        SetError (pDBDiscountView->GetLastError(),
          "Init() failed. Unable to initialize discount view.") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        delete pDBDiscountView ;
      }
      else
      {
        // add the element to the view collection ...
        aCol[pDBDiscountView->GetViewID()] = pDBDiscountView ;
        aList.push_back (pDBDiscountView) ;

        // add the parent view id ... 
        pDBDiscountView->AddParentViewID(nParentViewID) ;
      }
    }
    pDBDiscountView = NULL ;
	}
	catch(_com_error& err) {
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		bRetCode = FALSE;
	}
	return bRetCode;
}

// ----------------------------------------------------------------
// Name:     			GetEnumFileList
// Arguments:     EnumFileList (std::vector)	- list of files retrieved from master file list
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY 
// ----------------------------------------------------------------

BOOL DBViewHierarchy::InitDataAnalysisView(long aID,
											 const std::wstring& wstrViewName,
											 MTConfigLib::IMTConfigPropSetPtr& aProp,
											 vector<DBView *>& aList,
											 MTDataAnalysisViewColl& DAViewColl,
											 DBViewColl& aCol)
{
	BOOL bRetCode = TRUE;
	MTDataAnalysisView *pDataAnalysisView=NULL;
	try 
  {
		long nParentViewID = aProp->NextLongWithName("id_parent_view") ;
		std::wstring wstrViewType =  (const wchar_t*)_bstr_t(aProp->NextStringWithName("nm_view_type"));

		// allocate a new DBDataAnalysisView object ...
		DBDataAnalysisView* pDBDataAnalysisView = new DBDataAnalysisView ;
		ASSERT (pDBDataAnalysisView) ;
		if (pDBDataAnalysisView == NULL)
		{
			SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, 
				"DBViewHierarchy::Init") ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			return FALSE ;
		}
  
		// find the view in the dataanalysis view collection ...
		bRetCode = DAViewColl.FindView (wstrViewName, pDataAnalysisView) ;
		if (bRetCode == FALSE)
		{
			SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, 
				"DBViewHierarchy::Init");
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			mLogger->LogVarArgs (LOG_WARNING, "Unable to find data analysis view %s in collection.",
				(const char*)ascii(wstrViewName).c_str()) ;
			delete pDBDataAnalysisView ;

			// we logged the fact that we found an invalid view item so change bRetCode ...
			bRetCode = TRUE ;
		}
		// otherwise ... 
		else
		{
			// initialize the product view object ...
			bRetCode = pDBDataAnalysisView->Init(wstrViewType, aID, wstrViewName, 
				aID, pDataAnalysisView) ;
			if (bRetCode == FALSE)
			{
				SetError (pDBDataAnalysisView->GetLastError(),
					"Init() failed. Unable to initialize data analysis view.") ;
				mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
				delete pDBDataAnalysisView ;
			}
			else
			{
				// add the element to the view collection ...
				aCol[pDBDataAnalysisView->GetViewID()] = pDBDataAnalysisView ;
				aList.push_back (pDBDataAnalysisView) ;

				// add the parent view id ... 
				pDBDataAnalysisView->AddParentViewID(nParentViewID) ;
			}
		}
		pDBDataAnalysisView = NULL ;
	}
	catch(_com_error& err) {
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		bRetCode = FALSE;
	}
return bRetCode;

}


BOOL DBViewHierarchy::ReadAllConfigFiles(CCodeLookup* apLookup,
																				 DBDataAnalysisView *pDBDataAnalysisView,
																				 MTDataAnalysisViewColl& DAViewColl,
																				 CProductViewCollection& PVColl,
																				 vector<DBView *>& dbViewList)
{
	BOOL bRetCode = TRUE;
	VARIANT_BOOL flag;
	long aIndex = 0;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
	// get the list of view hierarchy files
	RCDLib::IMTRcdFileListPtr aFileList = GetFileListFromRcd();


	if(aFileList->GetCount() == 0) 
  {
		const char* szLogMsg = "no enumerated type configuration found";
		mLogger->LogThis(LOG_ERROR,szLogMsg);
		return FALSE;
	}

	if(FAILED(it.Init(aFileList))) return FALSE;

	while(TRUE) 
  {
		// step 4: iterate through the list, reading the XML
		_variant_t aVariant= it.GetNext();
		_bstr_t afile = aVariant;
		if(afile.length() == 0) break;

		MTConfigLib::IMTConfigPropSetPtr confSet = config->ReadConfiguration(afile, &flag);


		 // get the config data ...
		MTConfigLib::IMTConfigPropPtr viewprop = confSet->NextWithName("view_hierarchy");

		// handle case of empty view hierarchy file
		if(viewprop->GetPropType() == MTConfigLib::PROP_TYPE_SET) {

			MTConfigLib::IMTConfigPropSetPtr viewset = viewprop->GetPropValue();
			MTConfigLib::IMTConfigPropSetPtr subset ;
			_bstr_t bstrViewType ;
			_bstr_t bstrViewName ;
			std::wstring wstrViewName ;
			std::wstring wstrViewType ;
			int nViewID, nDescID, nParentViewID ;

			// read in the xml config file ...
			while (((subset = viewset->NextSetWithName("view")) != NULL) && (bRetCode == TRUE))
			{
				// read in the current view's data ...
				nViewID = subset->NextLongWithName("id_view") ;
				nParentViewID = subset->NextLongWithName("id_parent_view") ;
				bstrViewType = subset->NextStringWithName("nm_view_type") ;
				subset->Reset();

				// Get the bstrViewName from the id_view
				
				// bstrViewName = subset->NextStringWithName("nm_view_name") ;
				if(!apLookup->GetValue(nViewID, wstrViewName))
				{
					const ErrorObject * err = apLookup->GetLastError();
					SetError(err);
				}
				// make the rest code happy
				bstrViewName = wstrViewName.c_str();

				// change the nDescID to nViewID
				nDescID = nViewID;
  
				// try to find the service in the current list ...
				DBViewCollIter DBVIter = mViewColl->find(nViewID);
  
				// if we didnt find it ... add it to the view list ...
				if (DBVIter == mViewColl->end())
				{
					// if its a summary view ... create and initialize the summary view object ...
					bRetCode = TRUE ;
					wstrViewType = (wchar_t *) bstrViewType ;
					//       wstrViewName = (wchar_t *) bstrViewName ;
					if (_wcsicmp(wstrViewType.c_str(), DB_SUMMARY_VIEW) == 0)
					{
						bRetCode = InitSummaryView(nViewID,wstrViewName,subset,dbViewList,*mViewColl);
					}
					// else if its a product view ... create and initialize the product view object ...
					else if (_wcsicmp(wstrViewType.c_str(), DB_PRODUCT_VIEW) == 0)
					{
						bRetCode = InitProductView(nViewID,wstrViewName,subset,dbViewList,mPVColl,*mViewColl);
					}
					// else if its a discount view ... create and initialize the discount view object ...
					else if (_wcsicmp(wstrViewType.c_str(), DB_DISCOUNT_VIEW) == 0)
					{
						bRetCode = InitDiscountView(nViewID,wstrViewName,subset,dbViewList,mPVColl,*mViewColl);
					}
					// else if its a discount view ... create and initialize the discount view object ...
					else if (_wcsicmp(wstrViewType.c_str(), DB_DATAANALYSIS_VIEW) == 0)
					{
						bRetCode = InitDataAnalysisView(nViewID,wstrViewName,subset,dbViewList,DAViewColl,*mViewColl);
					}
					// else we have an unknown view type ...
					else
					{
						SetError(DB_ERR_INCORRECT_TYPE, ERROR_MODULE, ERROR_LINE, "DBViewHierarchy::Init");
						mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
						mLogger->LogVarArgs (LOG_WARNING, "Invalid view type %s for view %s.",
								(char*)bstrViewName, (char*)bstrViewName) ;
						bRetCode = FALSE ;
					}
					if(!bRetCode) {
						return bRetCode;
					}
				}
				// the view is already in the collection ...
				else
				{
					  DBView *pDBView = DBVIter->second;
					// add the parent view id ... 
					pDBView->AddParentViewID(nParentViewID) ;
				}
			}
		}
	}
	return bRetCode;
}


inline void DBViewHierarchy::InitRcd()	
{
	if(mRCD == NULL) {
			mRCD = RCDLib::IMTRcdPtr(MTPROGID_RCD);
			mRCD->Init();
	}
}
																				


//
//	@mfunc
//	Initialize the view collection
//  @rdesc 
//  No return value
//

BOOL DBViewHierarchy::Init()
{
	const char * functionName = "DBViewHierarchy::Init";


  // local variables
  BOOL bRetCode=TRUE, bRetCode2=TRUE ;
  DBDataAnalysisView *pDBDataAnalysisView=NULL ;
  MTDataAnalysisViewColl DAViewColl ;
  
  DBView *pDBView ;

	// make sure the RCD is up
	InitRcd();

  // create dbview list so we know the order of the product views coming out of 
  // the view hierarchy.xml file ...
  vector<DBView *> dbViewList ;

	// Create a codelookup object, since it is singleton.
	CCodeLookup * apLookup = CCodeLookup::GetInstance();
	// initialize the ccodelookup;
	if(!(apLookup))
	{
    mLogger->LogThis (LOG_ERROR, 
      "Unable to initialize codelookup object.") ;
    return FALSE ;
	}

  // call initialize of the product view collection ...
  bRetCode = mPVColl.Initialize() ;
  if (bRetCode == FALSE)
  {
    mLogger->LogThis (LOG_ERROR, 
      "Unable to initialize product view collection from configuration files.") ;
    mLogger->LogErrorObject (LOG_ERROR, mPVColl.GetLastError()) ;
		apLookup->ReleaseInstance();
    return FALSE ;
  }
  // call initialize of the data analysis view collection ...
  bRetCode = DAViewColl.Init() ;
  if (bRetCode == FALSE)
  {
    mLogger->LogThis (LOG_ERROR, 
      "Unable to initialize data analysis view collection from configuration files.") ;
		apLookup->ReleaseInstance();
    return FALSE ;
  }
  try
  {
		bRetCode = ReadAllConfigFiles(apLookup,pDBDataAnalysisView,DAViewColl,mPVColl,dbViewList);
  }
  catch (_com_error e)
  {
    //SetError (e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "DBViewHierarchy::Init") ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Init() failed. Error Description = %s", (char*)e.Description()) ;
    bRetCode = FALSE ;
  }
  // if we havent gotten an error yet ...
  if (bRetCode == TRUE)
  {
    int nCurrentViewID ;

    // for all the entries in the map ... add their child views ...
    for (vector<DBView *>::iterator Iter = dbViewList.begin();
					 Iter != dbViewList.end() && bRetCode == TRUE;
					 Iter++)
    {
      // get the current view ...
      pDBView = *Iter ;
      
      // get the current view id ...
      nCurrentViewID = pDBView->GetViewID() ;

      // iterate through the list and find all the children of this view ...
      for (vector<DBView *>::iterator ViewIter = dbViewList.begin();
					 ViewIter != dbViewList.end();
					 ViewIter++)
      {
        // get the view entry ...
        DBView *pDBViewEntry = *ViewIter ;

        // check to see if the current view id is a parent of this view ...
        if (pDBViewEntry->IsParentViewID(nCurrentViewID) == TRUE)
        {
          // add the view as a child of the current view ...
          pDBView->AddChildViewID (pDBViewEntry->GetViewID()) ;
        }
      }
      pDBView = NULL ;
    }
  }

  // clear the dbViewList ...
  dbViewList.clear() ;

  // if we havent initialized the observer yet ...
  if (mObserverInitialized == FALSE)
  {
    if (!mObservable.Init())
    {
      mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Unable to initialize Observer.") ;
      bRetCode = FALSE ;
    }
    else
    {    
      mObservable.AddObserver(*this);
      
      if (!mObservable.StartThread())
      {
        mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Unable to start Observer Thread.") ;
        bRetCode = FALSE ;
      }
      else
      {
        mObserverInitialized = TRUE ;
      }
    }
  }
	apLookup->ReleaseInstance();
  return bRetCode ;
}

//
//	@mfunc
//	Get an instance of the view collection.
//  @rdesc 
//  Returns a pointer to the view collection or NULL if a view collection
//  could not be created.
//
DBViewHierarchy * DBViewHierarchy::GetInstance()
{
	// make this method synchronized
	AutoCriticalSection cs(&msLock);

  // local variables ...
  BOOL bRetCode=TRUE ;

  // if we havent allocated a view collection yet ... do it now ...
  if (mpsViews == 0)  
  {
    // allocate a view collection instance ...
    mpsViews = new DBViewHierarchy;

    // call init ...
    bRetCode = mpsViews->Init();

    // if we werent initialized successfully ...
    if (bRetCode == FALSE)
    {
      delete mpsViews ;
			mpsViews = 0;
    }
  }
  // if we got a valid instance increment reference ...
  if (mpsViews != 0)
  {
    msNumRefs++ ;
  }

  // return mpsViews ...
  return mpsViews ;
}

//
//	@mfunc
//	Release an instance of the view collection
//  @rdesc 
//  No return value.
//
void DBViewHierarchy::ReleaseInstance()
{
	// Make this method synchronized
	AutoCriticalSection cs(&msLock);

  // decrement the reference counter ...
  if (mpsViews != 0)
  {
    msNumRefs-- ;
  }

  // if the number of references is 0 ... delete the collection 
  if (msNumRefs == 0)
  {
    delete mpsViews ;
    mpsViews = NULL ;
  }
}



//
//	@mfunc
//	Update the configuration.
//  @rdesc 
//  No return value
//
void DBViewHierarchy::ConfigurationHasChanged()
{
  // local variables ...

  // get the critical section
  msLock.Lock() ;

  // delete the allocated memory ...
  TearDown() ;

  // initialize the collection ...
  Init() ;

  // release the critical section
  msLock.Unlock() ;  

  return ;
}


//
//	@mfunc
//	Find the associated service in the DBViewHierarchy
//  @parm The service id to find
//  @parm The pointer to the DBView object
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is saved in the mLastError data member.
//

BOOL DBViewHierarchy::FindView (const int arViewID, DBView * & arpView)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  
  // null out the view ptr ...
  arpView = NULL ;
  
  // find the element ...
  mCollLock.Lock() ;

	DBViewCollIter DBVIter = mViewColl->find(arViewID);
	if (DBVIter == mViewColl->end()) 
  {
		SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "DBViewHierarchy::FindView");
		mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    // Create a codelookup object, since it is singleton.
    CCodeLookup *pCodeLookup = CCodeLookup::GetInstance();
    // initialize the ccodelookup;
    if (pCodeLookup == NULL)
    {
  		mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to find view with id = %d in view hierarchy configuration file. Please look in the t_enum_data table for the view name.", arViewID) ;
    }
    // otherwise ... get the name of the view ...
    else
    {
      // get the name of the view ...
      std::wstring wstrValue ;
      if (!pCodeLookup->GetValue (arViewID, wstrValue))
      {
        mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to find view with id = %d in view hierarchy configuration file. Please look in the t_enum_data table for the view name.", arViewID) ;
      }
      else
      {
        mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to find view with name = %s in view hierarchy configuration file.", 
        ascii(wstrValue).c_str()) ;
      }

      // release the code lookup object ...
      pCodeLookup->ReleaseInstance() ;
    }
		bRetCode = FALSE ;
	}
	else
	{
		arpView = DBVIter->second;
	}
  mCollLock.Unlock() ;
  return bRetCode ;
}

