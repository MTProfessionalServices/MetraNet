#if 0 // deadcode ( deprecated obsolete dead legacy )

/**************************************************************************
* @doc DBProductViewItem
* 
* @module  Encapsulation for Database Sessions |
* 
* This class encapsulates the insertion or removal of Sessions from the 
* database. All access to Database Session should be done through this class.
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
* @index | DBProductViewItem
***************************************************************************/

#include <metra.h>
#include <mtprogids.h>
#include <mtparamnames.h>
#include <DBProductViewItem.h>
#include <DBProductView.h>
#include <DBDiscountView.h>
#include <DBViewHierarchy.h>
#include <DBMiscUtils.h>
#include <mtglobal_msg.h>
#include <MTUtil.h>
#include <loggerconfig.h>
#include <DBUsageCycle.h>
#include <reservedproperties.h>
#include <MTDec.h>
#include <tchar.h>

#undef max
#undef min

using namespace std;

// import the config loader ...
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

ProductViewInfoItem::~ProductViewInfoItem()
{ 
	delete mPvItem; 
	mPvItem = NULL; 
}

//
//	@mfunc
//	Constructor. Initialize the appropriate data members
//  @rdesc 
//  No return value
//
DBProductViewItem::DBProductViewItem(const int aDataBaseTypeID,
																		 const DbTypeInfoStruct& aDbTypeInfo)
: mIsInitialized(FALSE),
	mID(-1), 
	mParentID(-1),
	mpUsageCycle(NULL), 
	mDbTypeInfo(aDbTypeInfo), 
	mDbTypeID(aDataBaseTypeID)
{
  // intialize the tax values ...
  mTaxFederal.vt = VT_NULL ;
  mTaxState.vt = VT_NULL ;
  mTaxCounty.vt = VT_NULL ;
  mTaxLocal.vt = VT_NULL ;
  mTaxOther.vt = VT_NULL ;
}

//
//	@mfunc
//	Destructor
//  @rdesc 
//  No return value
//
DBProductViewItem::~DBProductViewItem()
{
  // tear down the allocated memory ...
  TearDown() ;
}

//
//	@mfunc
//	Deletes the allocated memory.
//  @rdesc 
//  No return value.
//
void DBProductViewItem::TearDown()
{
  // delete the allocated memory for the view property map ...
  for (DBViewPropCollIter Iter = mViewPropMap.begin(); Iter != mViewPropMap.end(); Iter++)
  {
    DBViewPropertyCollection *pPropColl = (*Iter).second ;
    delete pPropColl ;
  }
  mViewPropMap.clear() ;

//	mAccountUsageProps.TearDown();
  // delete the allocated memory for the session id ...
///  mSessionID.resize(0) ;
///  mParentSessionID.resize(0) ;

  // release reference to the collection ...
  if (mpUsageCycle != NULL)
  {
    mpUsageCycle->ReleaseInstance() ;
    mpUsageCycle = NULL ;
  }
  
  // reinitialize all the data members ...
  mIsInitialized  = FALSE ;
//  mID = -1 ;
//  mParentID = -1 ;
}

//
//	@mfunc
//	Initialize the product view item object. Initialize the database context,
//  find the product in the view hierarchy, and save the session IDs.
//  @parm The view id
//  @parm The session ID
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
BOOL DBProductViewItem::Init(const DBPVIInitProperties &arInitProp,
														 ProductViewIdMap& apProductViewIDMap)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  BOOL bFound=FALSE ;
  DBView *pView=NULL ;
  DBViewPropertyCollection *pPropColl=NULL ;
  int nViewID=-1 ;
  unsigned char *pParentSessionID=NULL ;

  // tear down the allocated memory ...
	/// TODO: no longer necessary?
	TearDown() ;

	mAccountUsageProps = arInitProp;

  mViewID = arInitProp.GetPrimaryViewID() ;

  // iterate thru the view id's ...
  ;
  for (ViewIDCollIter ViewIter = ((DBPVIInitProperties &)arInitProp).GetViewIDCollection().begin();
			 ViewIter != ((DBPVIInitProperties &)arInitProp).GetViewIDCollection().end();
			 ViewIter++)
  {
    // get the view id ...
    nViewID = (*ViewIter) ;

		// find the product view 
		ProductViewIdMapIterator aIter = apProductViewIDMap.find(nViewID);
		if(aIter == apProductViewIDMap.end()) 
		{
			char buf[1024];
			sprintf(buf, "DBProductViewItem::Init() failed. Unable to find view with id <%d>", nViewID);
      SetError (DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBProductViewItem::Init", buf) ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			bRetCode = FALSE;
		}
    else
    {
			pView = aIter->second->mPvItem;
      // create a new view property collection ...
      pPropColl = new DBViewPropertyCollection (pView);
      ASSERT (pPropColl) ;
      if (pPropColl == NULL) 
      {
        mLogger->LogVarArgs (LOG_ERROR, 
          "Unable to allocate memory for view property collection.") ;
        bRetCode = FALSE ;
      }
      else
      {
        // insert it into the view ...
        mViewPropMap[nViewID] = pPropColl ;
      }
    }
  }
  
  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    // get an instance of the usage cycle collection ...
    mpUsageCycle = DBUsageCycleCollection::GetInstance() ;
    if (mpUsageCycle == NULL)
    {
      SetError(DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
        "DBProductViewItem::Init", "Unable to get usage cycle collection");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }

    // if we need to find the interval ...
    if (mAccountUsageProps.GetIntervalID() == -1)
    {
      // get the interval 
			int intervalID = mAccountUsageProps.GetIntervalID();
      bRetCode = 
				mpUsageCycle->GetIntervalAndTableSuffix (mAccountUsageProps.GetAccountID(), 
																								 mAccountUsageProps.GetTxnTime(),
        intervalID) ;
			mAccountUsageProps.SetIntervalID(intervalID);
      if (bRetCode == FALSE)
      {
        SetError (DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
          "DBProductViewItem::Init", "Init() failed. Unable to get interval") ;
        mLogger->LogVarArgs (LOG_ERROR,
          "Init() failed. Unable to get interval id for acct id = %d",
          mAccountUsageProps.GetAccountID()) ;
      } 
    }
  }
  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    // we're initialized now .. set the flag to indicate it ...
    mIsInitialized = TRUE ;
  }
  return bRetCode ;
}
//
//	@mfunc
//	Add the property name/value pair to the view item. Check to make sure the
//  name is valid, find the appropriate type to convert the value to, and
//  add the name/value pair into the view item
//  @parm The distinguished name
//  @parm The value
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
BOOL DBProductViewItem::AddProperty (const std::wstring &arName, const _variant_t &arValue,
                                     int arViewID)
{
  // local variables 
  BOOL bRetCode=TRUE ;

  // if we're not initialized ... exit ...
  if (mIsInitialized == FALSE)
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, 
      "DBProductViewItem::AddProperty");
    bRetCode = FALSE ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return bRetCode ;
  }

  // find the view in the collection ...
  DBViewPropCollIter Iter = mViewPropMap.find(arViewID) ;
  if (Iter == mViewPropMap.end())
  {
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBProductViewItem::AddProperty");
    mLogger->LogVarArgs (LOG_ERROR, 
      L"Unable to add property %s. Unable to find view with id = %d.",
      arName.c_str(), arViewID) ;
    bRetCode = FALSE ;
  }
  else
  {
    // add the property ...
		DBViewPropertyCollection *pPropColl = Iter->second;
    bRetCode = pPropColl->AddProperty(arName, arValue) ;
    if (bRetCode == FALSE)
    {
      SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
        "DBProductViewItem::AddProperty");
      mLogger->LogVarArgs (LOG_ERROR, 
        L"Unable to add property %s to view with id %d.",
        arName.c_str(), arViewID) ;
    }
  }
    
  return bRetCode ;
}

BOOL DBProductViewItem::AddReservedProperty (const std::wstring &arName, const _variant_t &arValue)
{
  BOOL bRetCode = TRUE ;

  //if (arName.compareTo(MT_AMOUNT_PROP, RWWString::ignoreCase) == 0)
  if (_wcsicmp(arName.c_str(), MT_AMOUNT_PROP) == 0)
  {
    mAmount = arValue ;
  }
  else if (_wcsicmp(arName.c_str(), MT_CURRENCY_PROP) == 0)
  {
    mCurrency = arValue ;
  }
  else if (_wcsicmp(arName.c_str(), MT_ACCOUNTID_PROP) == 0)
  {
    ;
  }
  else if (_wcsicmp(arName.c_str(), MT_TIMESTAMP_PROP) == 0)
  {
    ;
  }
  else if (_wcsicmp(arName.c_str(), MT_FEDTAX_PROP) == 0)
  {
    mTaxFederal = arValue ;
  }
  else if (_wcsicmp(arName.c_str(), MT_STATETAX_PROP) == 0)
  {
    mTaxState = arValue ;
  }
  else if (_wcsicmp(arName.c_str(), MT_COUNTYTAX_PROP) == 0)
  {
    mTaxCounty = arValue ;
  }
  else if (_wcsicmp(arName.c_str(), MT_LOCALTAX_PROP) == 0)
  {
    mTaxLocal = arValue ;
  }
  else if (_wcsicmp(arName.c_str(), MT_OTHERTAX_PROP) == 0)
  {
    mTaxOther = arValue ;
  }
  else
  {
    SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
      "DBProductViewItem::AddReservedProperty");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_DEBUG, 
      "Unable to add the %s property to the product view item. Svc ID = %d", 
      ascii(arName).c_str(), mAccountUsageProps.GetServiceID()) ;
    bRetCode = FALSE ;
  }
  return bRetCode ;
}


//
//	@mfunc
//	
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is stored in the mLastError data member.
//
BOOL DBProductViewItem::CommitItem(ROWSETLib::IMTSQLRowsetPtr & arpRowset)
{
  // local variables ...
  BOOL bRetCode=TRUE, bRetCode2=TRUE ;
  _variant_t vtAmount ;
  _variant_t vtCurrency ;
  std::wstring wstrParentUID ;
  std::wstring wstrViewType ;
  std::wstring wstrTableName ;
  DBView *pView=NULL ;
  DBViewPropertyCollection *pPropColl=NULL ;
  ROWSETLib::IMTSQLRowsetPtr rowset(arpRowset) ;

  // if we're not initialized ... exit ...
  if (mIsInitialized == FALSE)
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, "DBProductViewItem::CommitItem");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  try
  {
    // convert the txn time to a string ...
    std::wstring wstrTxnTime ;
    wstrTxnTime = GetTxnTimeStringFromTimet(mAccountUsageProps.GetTxnTime()) ;
    
    if ((mParentID == -1) && (mAccountUsageProps.GetParentSessionID().length() == 0))
    {
      // setup and execute the stored procedure ...
      bRetCode = ExecAccountUsageStoredProcedure(arpRowset);
/// mpSessionUID, 
///        mAcctID, mViewID, mIntervalID, mParentID, mSvcID, wstrTxnTime, mAmount, 
///        mCurrency.bstrVal, mTaxFederal, mTaxState, mTaxCounty, mTaxLocal, mTaxOther,
///																								 mpBatchUID) ;
    }
    else
    {
      if (mAccountUsageProps.GetParentSessionID().length() != 0)
      {
        // setup and execute the stored procedure ...
        bRetCode = ExecAccountUsageParentUIDStoredProcedure(arpRowset);
				/// wstrTxnTime passed in!
///mpSessionUID, 
///          mAcctID, mViewID, mIntervalID, mpParentSessionUID, mSvcID, wstrTxnTime, mAmount, 
///          mCurrency.bstrVal, mTaxFederal, mTaxState, mTaxCounty, mTaxLocal, mTaxOther,
///																														mpBatchUID) ;
      }
      else if (mParentID != -1)
      {
        // setup and execute the stored procedure ...
        bRetCode = ExecAccountUsageParentIDStoredProcedure(arpRowset);
///				, mpSessionUID, 
///          mAcctID, mViewID, mIntervalID, mParentID, mSvcID, wstrTxnTime, mAmount, 
///          mCurrency.bstrVal, mTaxFederal, mTaxState, mTaxCounty, mTaxLocal, mTaxOther,
///																													 mpBatchUID) ;
      }
    }
    
    // get the session id from the stored procedure ...
    _variant_t vtValue ;
    vtValue = rowset->GetParameterFromStoredProc (L"id_sess") ;
    mID = vtValue.lVal ;
    
    // if the session id is -99 there was an error ...
    if (mID == -99)
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
        "DBProductViewItem::CommitItem", "Unable to get valid session id");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    
    // iterate thru the views ...
    for (DBViewPropCollIter Iter = mViewPropMap.begin();
				 Iter != mViewPropMap.end() && (bRetCode == TRUE);
				 Iter++)
    {
      // get the view property collection ...
      pPropColl = Iter->second ;
      
      // get the table name ...
      wstrTableName = pPropColl->GetTableName() ;
      
      // create the command to insert into the product view table ...
      bRetCode = CreateAndExecuteInsertToProductViewQuery(arpRowset, wstrTableName,
        mID, pPropColl) ;
    }
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;

		string errorString;
		StringFromComError(errorString, "CommitItem Failed", e);

    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "DBProductViewItem::CommitItem",
							errorString.c_str()) ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs(LOG_ERROR, "CommitItem() failed. Error = %s", (char*)e.Description()) ; 
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBProductViewItem::ExecAccountUsageStoredProcAndGetID(ROWSETLib::IMTSQLRowsetPtr & arpRowset, 
    const long &arIntervalID, int &arSessionID)
{
  BOOL bRetCode=TRUE ;
  ROWSETLib::IMTSQLRowsetPtr rowset(arpRowset)  ;

  // get the txn time string from the time ...
//  RWWString wstrTxnTime = GetTxnTimeStringFromTimet(mAccountUsageProps.GetTxnTime()) ;

	// set the interval ID to the one passed in
	mAccountUsageProps.SetIntervalID(arIntervalID);

  // call the Account Usage store proc ...
  bRetCode = ExecAccountUsageStoredProcedure(arpRowset);

//// TODO: arInterval passed in!!!!


  // get the session id from the stored procedure ...
  if (bRetCode == TRUE)
  {
    _variant_t vtValue ;
    vtValue = rowset->GetParameterFromStoredProc (L"id_sess") ;
    arSessionID = vtValue.lVal ;
    
    // if the session id is -99 there was an error ...
    if (arSessionID == -99)
    {
      bRetCode = FALSE ;
      SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
        "DBProductViewItem::ExecAccountUsageStoredProcAndGetID", "Unable to get valid session id");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }

  return bRetCode;
}


//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBProductViewItem::ExecuteInsertProductViewData(ROWSETLib::IMTSQLRowsetPtr & arpRowset,
                                                 const std::wstring &arTableName,
                                                 DBViewPropertyCollection *pPropColl)
{
  BOOL bRetCode=TRUE ;
  
  // create the insert query to the product view table ...
  bRetCode = CreateAndExecuteInsertToProductViewQuery(arpRowset, arTableName, 
    mID, pPropColl) ;
  
  return bRetCode;
}

//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBProductViewItem::ExecAccountUsageStoredProcedure
(ROWSETLib::IMTSQLRowsetPtr &arpRowset) 
{
	if (!AccountUsageSprocInit(L"InsertAccountUsage", arpRowset))
		return FALSE;

  // execute the stored procedure ...
  arpRowset->ExecuteStoredProc() ;

	return TRUE;
}

BOOL DBProductViewItem::ExecAccountUsageParentIDStoredProcedure
(ROWSETLib::IMTSQLRowsetPtr &arpRowset)
{
	if (!AccountUsageSprocInit(L"InsertAcctUsageWithID", arpRowset))
		return FALSE;

  // execute the stored procedure ...
  arpRowset->ExecuteStoredProc() ;

  return TRUE ;
}


BOOL DBProductViewItem::ExecAccountUsageParentUIDStoredProcedure
(ROWSETLib::IMTSQLRowsetPtr &arpRowset)
{
	if (!AccountUsageSprocInit(L"InsertAcctUsageWithUID",arpRowset))
		return FALSE;

  SAFEARRAYBOUND saboundParent[1] ;
  SAFEARRAY * pSAParent;
  saboundParent[0].lLbound = 0 ;
  saboundParent[0].cElements = 16 ;
  
  // create the safe arrary ...
  pSAParent = SafeArrayCreate (VT_UI1, 1, saboundParent) ;
  if (pSAParent == NULL)
  {
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, 
      "DBProductViewItem::ExecAccountUsageParentUIDStoredProcedure", 
      "Unable to create parent safe arrary");
    return FALSE ;
  }

  unsigned char * uidData;
  // set uidData to the contents of the safe array ...
  ::SafeArrayAccessData(pSAParent, (void **)&uidData);
  
  // put the items into the safe array ...
  memcpy (uidData, mAccountUsageProps.GetParentSessionUID(), DB_SESSIONID_SIZE) ;
  
  // Release lock on safe array
  ::SafeArrayUnaccessData(pSAParent);

  // assign the safe array to the variant ...
	_variant_t vtValue;
  vtValue.vt = (VT_ARRAY | VT_UI1);
  vtValue.parray = pSAParent ;

	/// different
  arpRowset->AddInputParameterToStoredProc (L"uid_parent_sess", MTTYPE_VARBINARY, INPUT_PARAM, vtValue) ;


  // execute the stored procedure ...
  arpRowset->ExecuteStoredProc() ;

  return TRUE ;
}


BOOL DBProductViewItem::AccountUsageSprocInit(const wchar_t * apSproc,
																							ROWSETLib::IMTSQLRowsetPtr aRowset)
{
  std::wstring wstrSprocName = apSproc;

  // intialize the stored procedure ...
  aRowset->InitializeForStoredProc(wstrSprocName.c_str());

	//
	// 
  // add the parameters ...
  SAFEARRAYBOUND sabound[1] ;
  SAFEARRAY * pSA;
  sabound[0].lLbound = 0 ;
  sabound[0].cElements = 16 ;
  
  // create the safe arrary ...
  pSA = SafeArrayCreate (VT_UI1, 1, sabound) ;
  if (pSA == NULL)
  {
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, 
      "DBProductViewItem::ExecAccountUsageStoredProcedure", 
      "Unable to create safe arrary");
    return FALSE ;
  }
  // set uidData to the contents of the safe array ...
  unsigned char * uidData;
  ::SafeArrayAccessData(pSA, (void **)&uidData);
  
  // put the items into the safe array ...
  memcpy (uidData, mAccountUsageProps.GetSessionUID(), DB_SESSIONID_SIZE) ;
  
  // Release lock on safe array
  ::SafeArrayUnaccessData(pSA);

  // assign the safe array to the variant ...
  _variant_t vtValue ;

  vtValue.vt = (VT_ARRAY | VT_UI1);
  vtValue.parray = pSA ;

	//BP this change was not needed
	//aRowset->AddInputParameterToStoredProc("@RETURN_VALUE", MTTYPE_INTEGER, RETVAL_PARAM, 0l);

  aRowset->AddInputParameterToStoredProc (L"tx_UID", MTTYPE_VARBINARY, INPUT_PARAM, vtValue) ;

  vtValue = (long) mAccountUsageProps.GetAccountID() ;
  aRowset->AddInputParameterToStoredProc (L"id_acc", MTTYPE_INTEGER, INPUT_PARAM, vtValue) ;

	/// TODO: verify this
  vtValue = (long) mViewID ;
  aRowset->AddInputParameterToStoredProc(L"id_view", MTTYPE_INTEGER, INPUT_PARAM, vtValue) ;

  vtValue = (long) mAccountUsageProps.GetIntervalID() ;
  aRowset->AddInputParameterToStoredProc(L"id_usage_interval", MTTYPE_INTEGER, INPUT_PARAM, vtValue) ;

	// TODO: is this common?
  vtValue = (long) mParentID ;
  aRowset->AddInputParameterToStoredProc(L"id_parent_sess", MTTYPE_INTEGER, INPUT_PARAM, vtValue) ;

  vtValue = (long) mAccountUsageProps.GetServiceID() ;
  aRowset->AddInputParameterToStoredProc(L"id_svc", MTTYPE_INTEGER, INPUT_PARAM, vtValue) ;

	// TODO: txntime

  // get the txn time string from the time ...
  std::wstring wstrTxnTime = GetTxnTimeStringFromTimet(mAccountUsageProps.GetTxnTime()) ;

  vtValue = wstrTxnTime.c_str();
  aRowset->AddInputParameterToStoredProc(L"dt_session", MTTYPE_VARCHAR, INPUT_PARAM, vtValue) ;

  vtValue = mAmount ;
  aRowset->AddInputParameterToStoredProc(L"amount", MTTYPE_DECIMAL, INPUT_PARAM, vtValue) ;

  vtValue = mCurrency ;
  aRowset->AddInputParameterToStoredProc(L"am_currency", MTTYPE_VARCHAR, INPUT_PARAM, vtValue) ;

  if (mTaxFederal.vt == VT_NULL)
  {
    aRowset->AddInputParameterToStoredProc(L"tax_federal", MTTYPE_DECIMAL, INPUT_PARAM, mTaxFederal) ;
  }
  else
  {
    vtValue = (double) mTaxFederal ;
    aRowset->AddInputParameterToStoredProc(L"tax_federal", MTTYPE_DECIMAL, INPUT_PARAM, vtValue) ;
  }
  if (mTaxState.vt == VT_NULL)
  {
    aRowset->AddInputParameterToStoredProc(L"tax_state", MTTYPE_DECIMAL, INPUT_PARAM, mTaxState) ;
  }
  else
  {
    vtValue = (double) mTaxState ;
    aRowset->AddInputParameterToStoredProc(L"tax_state", MTTYPE_DECIMAL, INPUT_PARAM, vtValue) ;
  }
  if (mTaxCounty.vt == VT_NULL)
  {
    aRowset->AddInputParameterToStoredProc(L"tax_county", MTTYPE_DECIMAL, INPUT_PARAM, mTaxCounty) ;
  }
  else
  {
    vtValue = (double) mTaxCounty ;
    aRowset->AddInputParameterToStoredProc(L"tax_county", MTTYPE_DECIMAL, INPUT_PARAM, vtValue) ;
  }
  if (mTaxLocal.vt == VT_NULL)
  {
    aRowset->AddInputParameterToStoredProc(L"tax_local", MTTYPE_DECIMAL, INPUT_PARAM, mTaxLocal) ;
  }
  else
  {
    vtValue = (double) mTaxLocal ;
    aRowset->AddInputParameterToStoredProc(L"tax_local", MTTYPE_DECIMAL, INPUT_PARAM, vtValue) ;
  }
  if (mTaxOther.vt == VT_NULL)
  {
    aRowset->AddInputParameterToStoredProc(L"tax_other", MTTYPE_DECIMAL, INPUT_PARAM, mTaxOther) ;
  }
  else
  {
    vtValue = (double) mTaxOther ;
    aRowset->AddInputParameterToStoredProc(L"tax_other", MTTYPE_DECIMAL, INPUT_PARAM, vtValue) ;
  }
  
	_variant_t vtNull;
	vtNull.vt = VT_NULL;



	const unsigned char * batchid = mAccountUsageProps.GetBatchUID();
	if (batchid)
	{
		SAFEARRAY * pBatchSA;
  
		// create the safe arrary ...
		pBatchSA = SafeArrayCreate (VT_UI1, 1, sabound);
		if (pBatchSA == NULL)
		{
			SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, 
								"DBProductViewItem::ExecAccountUsageStoredProcedure", 
								"Unable to create safe arrary");
			return FALSE ;
		}
		// set uidData to the contents of the safe array ...
		::SafeArrayAccessData(pBatchSA, (void **)&uidData);
  
		// put the items into the safe array ...
		memcpy(uidData, batchid, DB_SESSIONID_SIZE);
  
		// Release lock on safe array
		::SafeArrayUnaccessData(pBatchSA);

		// assign the safe array to the variant ...
		vtValue.vt = (VT_ARRAY | VT_UI1);
		vtValue.parray = pBatchSA ;

		aRowset->AddInputParameterToStoredProc(L"tx_batch", MTTYPE_VARBINARY, INPUT_PARAM, vtValue);
	}
	else
		aRowset->AddInputParameterToStoredProc(L"tx_batch", MTTYPE_VARBINARY, INPUT_PARAM, vtNull);


	if (mAccountUsageProps.GetPOID() == -1)
		aRowset->AddInputParameterToStoredProc(L"id_prod", MTTYPE_INTEGER, INPUT_PARAM, vtNull);
	else
		aRowset->AddInputParameterToStoredProc(L"id_prod", MTTYPE_INTEGER, INPUT_PARAM, 
																					 (long) mAccountUsageProps.GetPOID());

	if (mAccountUsageProps.GetPIInstanceID() == -1)
		aRowset->AddInputParameterToStoredProc(L"id_pi_instance", MTTYPE_INTEGER, INPUT_PARAM, vtNull);
	else
		aRowset->AddInputParameterToStoredProc(L"id_pi_instance", MTTYPE_INTEGER, INPUT_PARAM, 
																					 (long) mAccountUsageProps.GetPIInstanceID());

	if (mAccountUsageProps.GetPITemplateID() == -1)
		aRowset->AddInputParameterToStoredProc(L"id_pi_template", MTTYPE_INTEGER, INPUT_PARAM, vtNull);
	else
		aRowset->AddInputParameterToStoredProc(L"id_pi_template", MTTYPE_INTEGER, INPUT_PARAM, 
																					 (long) mAccountUsageProps.GetPITemplateID());

  // add the output parameter ...
  aRowset->AddOutputParameterToStoredProc(L"id_sess", MTTYPE_INTEGER, OUTPUT_PARAM) ;




  return TRUE ;
}



//
//	@mfunc
//	
//  @rdesc 
//  
//
BOOL DBProductViewItem::CreateAndExecuteInsertToProductViewQuery(ROWSETLib::IMTSQLRowsetPtr &arpRowset, 
            const std::wstring &arTableName, int arID, 
            DBViewPropertyCollection *pPropColl)
{
  std::wstring wstrCmd ;
  std::wstring wstrValue ;
  std::wstring wstrTemp ;
  DBSessionProperty *pProperty=NULL ;
  _variant_t Data ;
  _TCHAR tstr[255] ;
  DATE tdate;
	struct tm tmDest;
  BOOL bFirstTime=TRUE ;
  ROWSETLib::IMTSQLRowsetPtr rowset(arpRowset) ;

  _variant_t vtParam ;
  _bstr_t queryTag ;

  // initialize the parameter list ...
  rowset->ClearQuery() ;
  
  queryTag = "__INSERT_TO_PRODUCT_VIEW__" ;
  rowset->SetQueryTag (queryTag) ;
  
  vtParam = arTableName.c_str() ;
  rowset->AddParam (MTPARAM_TABLENAME, vtParam) ;

	bool bIsOracle = (mDbTypeID == mDbTypeInfo.aOracleID);

  // loop through the properties and add the column names and values ...
  for (DBPropCollIter Iter = pPropColl->GetViewPropertyCollection().begin() ;
			 Iter != pPropColl->GetViewPropertyCollection().end();
			 Iter++)
  {
    // get a ptr to the current value ...
    pProperty = Iter->second ;
    
    // add the commas after the data already written ...
    if (bFirstTime == FALSE)
    {
      wstrCmd += L", " ;
      wstrValue += L", " ;
    }
    // this is the first time through ... set the flag to false now ...
    else
    {
      bFirstTime = FALSE ;
    }
    // insert the column name into the wstrCmd string ...
    wstrCmd += pProperty->GetColumnName() ;
    
    // insert the data value into the wstrCmdValue string ...
    Data = pProperty->GetDataValue() ;

    unsigned long type = pProperty->GetType() ;
		CMSIXProperties::PropertyType msixType = pProperty->GetMSIXType();

		//handles non-required properties without default values
		if (Data.vt == VT_EMPTY)
			type = VT_EMPTY;


		//For Oracle, always format string properties as wide strings,
		//because columns are always created as wide in our impl of DynamicTable
		if(bIsOracle && type == VT_LPSTR)
			type = VT_BSTR;

    //TODO: always switch on MSIXType
		switch (type) {
		case VT_EMPTY:
			wstrValue += L"NULL" ;
			break;
    case VT_I2:
      _stprintf(tstr, _T("%hd"),V_I2(&Data));
      wstrValue += tstr;
      break;
    case VT_I4:
      _stprintf(tstr, _T("%d"),V_I4(&Data));
      wstrValue += tstr;
      break;
    case VT_R4:
      _stprintf(tstr, _T("%.16e"),V_R8(&Data));
      wstrValue += tstr;
      break;
    case VT_R8:
      _stprintf(tstr, _T("%.16e"),V_R8(&Data));
      wstrValue += tstr ;
      break;
		case VT_DECIMAL:
		{
			MTDecimal decVal((DECIMAL)(Data));
      //_stprintf(tstr, _T("%.16e"),V_R8(&Data));
			std::string ascVal = decVal.Format();
			std::wstring wideStr;
			ASCIIToWide(wideStr, ascVal.c_str(), ascVal.length());
      wstrValue += wideStr ;
      break;
		}
    //NOTE: the below case will never be evaluated to true in case
		//of Oracle
		case VT_LPSTR:
      wstrValue += L"'" ;
      wstrTemp = V_BSTR (&Data) ;
      if (wstrTemp.length() == 0)
      {
        wstrTemp = L" " ;
      }
      wstrValue += ValidateString (wstrTemp) ;
      wstrValue += L"'" ;
      break ;
    case VT_BSTR:
			//need to identify properties that
			//are actually booleans in MSIXDEF
			//Those are narrow strings
			//Remove the below check when all the strings are made WIDE in the
			//database
			if(msixType == CMSIXProperties::TYPE_BOOLEAN)
				wstrValue += L"'" ;
			else
				wstrValue += L"N'" ;
      wstrTemp = V_BSTR (&Data) ;
      if (wstrTemp.length() == 0)
      {
        wstrTemp = L" ";
      }
      wstrValue += ValidateString (wstrTemp) ;
      wstrValue += L"'" ;
      break ;

    case VT_DATE:
      if (Data.vt == VT_DATE)
      {
        tdate = Data.date ;
        StructTmFromOleDate(&tmDest, tdate);
        wcsftime(tstr, 255, _T("%Y-%m-%d %H:%M:%S"), &tmDest);
        
        // if we are writing to an Oracle database ... 
        if (bIsOracle)
        {
          wstrValue += L"TO_DATE('" ;
          wstrValue += tstr ;
          wstrValue += L"', 'YYYY-MM-DD HH24:MI:SS')" ;
        }
        else
        {
          wstrValue += L"'" ;
          wstrValue += tstr ;
          wstrValue += L"'" ;
        }
      }
      else
      {
        // if we are writing to an Oracle database ... 
        if (bIsOracle)
        {
          wstrValue += L"TO_DATE('" ;
          wstrTemp = V_BSTR (&Data) ;
          wstrValue += ValidateString (wstrTemp) ;
          wstrValue += L"', 'YYYY-MM-DD HH24:MI:SS')" ;
        }
        else
        {
          wstrValue += L"'" ;
          wstrTemp = V_BSTR (&Data) ;
          wstrValue += ValidateString (wstrTemp) ;
          wstrValue += L"'" ;
        }
      }
      break ;
      
    default:
      SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
        "DBProductViewItem::CreateAndExecuteInsertToProductViewQuery");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      wstrCmd = L"" ;
      return FALSE;
      break ;
    }
  }

  // initialize the parameter list ...
  _variant_t vtValue = (VARIANT_BOOL) VARIANT_TRUE ;
  vtParam = wstrCmd.c_str() ;
  rowset->AddParam (MTPARAM_COLUMNNAMES, vtParam) ;
  vtParam = (long) arID ;
  rowset->AddParam (MTPARAM_SESSIONID, vtParam) ;
  vtParam = wstrValue.c_str() ;
  rowset->AddParam (MTPARAM_COLUMNVALUES, vtParam, VARIANT_TRUE) ;
  
  // execute the query ...
  rowset->Execute() ;

  return TRUE ;
}

DBViewPropertyCollection::DBViewPropertyCollection(DBView *apView)
 : mpView(apView) 
{
}

DBViewPropertyCollection::~DBViewPropertyCollection()
{
  DBSessionProperty *pProp=NULL ;
  // delete all the allocate memory ...
	for (DBPropCollIter Iter = mPropColl.begin(); Iter != mPropColl.end(); Iter++)
  {
    pProp = Iter->second ;
    delete pProp ;
  }
  mPropColl.clear() ;
}

std::wstring DBViewPropertyCollection::GetTableName ()
{
  std::wstring wstrTableName ;
  std::wstring wstrViewType ;

  // get the table name ...
  wstrViewType = mpView->GetViewType() ;
  //if (wstrViewType.compareTo (DB_PRODUCT_VIEW, RWWString::ignoreCase) == 0)
  if (_wcsicmp(wstrViewType.c_str(), DB_PRODUCT_VIEW) == 0)
  {
    wstrTableName = ((DBProductView *) mpView)->GetTableName() ;
  }
  else if (_wcsicmp(wstrViewType.c_str(), DB_DISCOUNT_VIEW) == 0)
  {
    wstrTableName = ((DBDiscountView *) mpView)->GetTableName() ;
  }
  else
  {
    mLogger->LogVarArgs (LOG_ERROR, 
      L"Invalid view type %s for view with name %s.",
      wstrViewType.c_str(), mpView->GetViewName().c_str()) ;
  }
  return wstrTableName ;
}

BOOL DBViewPropertyCollection::AddProperty (const std::wstring &arName, 
                                                   const _variant_t &arValue)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DBSessionProperty *pSessionProperty ;
  DBProductViewProperty *pProperty ;
  std::wstring wstrViewType ;
  BOOL bFound=FALSE ;

  // convert it to the appropriate type and try to find the property ...
  wstrViewType = mpView->GetViewType() ;
  if (_wcsicmp(wstrViewType.c_str(), DB_PRODUCT_VIEW) == 0)
  {
    bFound = ((DBProductView *) mpView)->FindProperty (arName, pProperty) ;
  }
  else if (_wcsicmp(wstrViewType.c_str(), DB_DISCOUNT_VIEW) == 0)
  {
    bFound = ((DBDiscountView *) mpView)->FindProperty (arName, pProperty) ;
  }
  else
  {
    mLogger->LogVarArgs (LOG_ERROR, 
      L"Unable to add property %s. Invalid view type %s for view with name %s.",
      arName.c_str(), wstrViewType.c_str(), mpView->GetViewName().c_str()) ;
    bRetCode = FALSE ;
  }
  // if we found the property ... add it into the view property collection ...
  if (bFound == TRUE)
  {
    // create a session property ...
    pSessionProperty = new DBSessionProperty ;
    ASSERT (pSessionProperty) ;
    
    // initialize the Session Property ... this will convert the value
    // to the appropriate type for the database ...
    bRetCode = pSessionProperty->Init (pProperty->GetName(), 
      pProperty->GetColumnName(), arValue, pProperty->GetType(), pProperty->GetMSIXType()) ;
    if (bRetCode == TRUE)
    {
      // insert the name/value pair into the session ...
      mPropColl[pSessionProperty->GetName()] =  pSessionProperty ;
    }
  }

  return bRetCode ;
}

#endif // deadcode ( deprecated obsolete dead legacy )
