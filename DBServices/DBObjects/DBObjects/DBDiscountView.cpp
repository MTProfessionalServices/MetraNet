/**************************************************************************
 * @doc DBDiscountView
 * 
 * @module  Encapsulation of a single discount view|
 * 
 * This class encapsulates the properties of a single discount view.
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
 * @index | DBDiscountView
 ***************************************************************************/

#include <metra.h>
#include <mtprogids.h>
#include <mtparamnames.h>
#include <DBDiscountView.h>
#include <DBProductViewProperty.h>
#include <DBConstants.h>
#include <DBSQLRowset.h>
#include <DBInMemRowset.h>
#include <DBMiscUtils.h>
#include <mtglobal_msg.h>
#include <DBUsageCycle.h>
#include <CodeLookup.h>

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

//
//	@mfunc
//	Constructor. Initialize the appropriate data members.
//  @rdesc 
//  No return value
//
DBDiscountView::DBDiscountView()
{
  mSelectClause.resize(0) ;
}

//
//	@mfunc
//	Destructor. 
//  @rdesc 
//  No return value
//
DBDiscountView::~DBDiscountView()
{
  // release the interface ptrs ...
  if (mpQueryAdapter != NULL)
  {
    mpQueryAdapter->Release() ;
    mpQueryAdapter = NULL ;
  }
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBDiscountView::Init(const std::wstring &arViewType, const int &arViewID, 
                         const std::wstring &arName, const int &arDescriptionID,
                         CMSIXDefinition *pPV) 
{
  // local variables
  BOOL bRetCode=TRUE ;
  std::wstring wstrName ;
  std::wstring wstrColumn ;
  std::wstring wstrType ;
	CMSIXProperties::PropertyType msixType;
  std::wstring wstrDefault ;
  int nDesc=0 ;
  VARIANT_BOOL vbUserVisible=VARIANT_TRUE ;
  VARIANT_BOOL vbFilterable=VARIANT_TRUE ;
  VARIANT_BOOL vbExportable=VARIANT_TRUE ;
  VARIANT_BOOL vbIsRequired=VARIANT_TRUE ;
  VARIANT_BOOL vbEnumType=VARIANT_FALSE ;
  DBProductViewProperty *pDBProperty=NULL ;
  CMSIXProperties *pPVProp=NULL ;
  std::wstring wstrFQN ;

  // initialize the view ...
  bRetCode = DBView::Init (arViewType, arViewID, arName, arDescriptionID) ;
  if (bRetCode == FALSE)
  {
    SetError(DBView::GetLastError(), 
      "Init() failed. Unable to initialize discount view");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  // create the code lookup object ...
  CCodeLookup *pCodeLookup = CCodeLookup::GetInstance() ;
  if (pCodeLookup == NULL)
  {
    SetError(DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, "DBProductView::Init", 
      "Init() failed. Unable to get code lookup singleton.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE;
  }
  
  // copy the data members out of the discount view ...
  ASSERT (pPV) ;
  mTableName = pPV->GetTableName() ;
  
  // get the discount view properties iterator ...

	MSIXPropertiesList::iterator it;
	for (it = pPV->GetMSIXPropertiesList().begin();
			 it != pPV->GetMSIXPropertiesList().end() && bRetCode == TRUE;
			 ++it)
	{
    // create a new discount view property ...
    pDBProperty = new DBProductViewProperty ;
    ASSERT (pDBProperty) ;
    if (pDBProperty == NULL)
    {
      bRetCode = FALSE ;
      SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBDiscountView::Init") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    
    // get the discount view property and copy the parameters ...
    pPVProp = *it;
    wstrName = pPVProp->GetDN() ;
    wstrColumn = pPVProp->GetColumnName() ;
    wstrType = pPVProp->GetDataType();
		msixType = pPVProp->GetPropertyType();
    vbUserVisible = pPVProp->GetUserVisible() ;
    vbFilterable = pPVProp->GetFilterable() ;
    vbExportable = pPVProp->GetExportable() ;
		wstrDefault = pPVProp->GetDefault();
		vbIsRequired = pPVProp->GetIsRequired();		

    // get the description id ... create the string then get it ...
    wstrFQN = arName ;
    wstrFQN += L"/" ;
    wstrFQN += wstrName ;
    if (!pCodeLookup->GetEnumDataCode(wstrFQN.c_str(), nDesc))
    {
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "DBDiscountView::Init");
      mLogger->LogErrorObject (LOG_WARNING, GetLastError()) ;
      mLogger->LogVarArgs (LOG_WARNING, "Unable to get code lookup id for string = %s.",
        ascii(wstrFQN).c_str()) ;
      nDesc = -1;
    }
    
    // initialize the summary view object ...
    bRetCode = pDBProperty->Init(wstrName, wstrColumn, wstrType,
																 msixType,
																 nDesc,
																 vbUserVisible, vbFilterable, vbExportable, _variant_t(), vbIsRequired) ;
    if (bRetCode == FALSE)
    {
      SetError(pDBProperty->GetLastError(), 
        "Init() failed. Unable to initialize discount view property");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {
      // do a find to see id the property exists ...
		if (mPropColl.count (wstrName) > 0)
      {
        mLogger->LogVarArgs (LOG_ERROR, 
          L"Found duplicate property with name = %s in discount view with name = %s.", 
          wstrName.c_str(), mName.c_str()) ;
        bRetCode = FALSE ;
        delete pDBProperty ;
        pDBProperty = NULL ;
      }
      else
      {
        // add the element to the view collection ...
        mPropColl[pDBProperty->GetName()] = pDBProperty ;
        
        // if this property is user visible ...add the column name and 
        // property name to the select clause ...
        if (vbUserVisible == VARIANT_TRUE)
        {
          AddToSelectClause(wstrColumn, wstrColumn) ;
        }
      }
    }
  }
  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    // create a new discount view property ...
    pDBProperty = new DBProductViewProperty ;
    ASSERT (pDBProperty) ;
    if (pDBProperty == NULL)
    {
      bRetCode = FALSE ;
      SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBDiscountView::Init") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {      
      // get the description id for amount ...
      if (!pCodeLookup->GetEnumDataCode(DB_CURRENCY_FQN, nDesc))
      {
        SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "DBProductView::Init");
        mLogger->LogErrorObject (LOG_WARNING, GetLastError()) ;
        mLogger->LogVarArgs (LOG_WARNING, L"Unable to get code lookup id for string = %s.",
          DB_CURRENCY_FQN) ;
        nDesc = -1;
      }

      // initialize the property object ...
      bRetCode = pDBProperty->Init(DB_CURRENCY, DB_CURRENCY, DB_STRING_TYPE,
																	 CMSIXProperties::TYPE_STRING,
																	 nDesc, VARIANT_TRUE, VARIANT_TRUE, VARIANT_TRUE, _variant_t(), vbIsRequired) ;
      if (bRetCode == FALSE)
      {
        SetError(pDBProperty->GetLastError(), 
          "Init() failed. Unable to initialize discount view property");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      }
      else
      {
        // do a find to see id the property exists ...
        if (mResvdPropColl.count (DB_CURRENCY) > 0 || 
          mPropColl.count (DB_CURRENCY) > 0)
        {
          delete pDBProperty ;
          pDBProperty = NULL ;
        }
        else
        {
          // add the element to the view collection ...
          mResvdPropColl[pDBProperty->GetName()] = pDBProperty ;
        }
      }
    }
  }
  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    // create a new discount view property ...
    pDBProperty = new DBProductViewProperty ;
    ASSERT (pDBProperty) ;
    if (pDBProperty == NULL)
    {
      bRetCode = FALSE ;
      SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBDiscountView::Init") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {      
      // get the description id for amount ...
      if (!pCodeLookup->GetEnumDataCode(DB_INTERVAL_ID_FQN, nDesc))
      {
        SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "DBDiscountView::Init");
        mLogger->LogErrorObject (LOG_WARNING, GetLastError()) ;
        mLogger->LogVarArgs (LOG_WARNING, L"Unable to get code lookup id for string = %s.",
          DB_INTERVAL_ID_FQN) ;
        nDesc = -1;
      }

      // initialize the property object ...
      bRetCode = pDBProperty->Init(DB_INTERVAL_ID, DB_INTERVAL_ID, DB_INTEGER_TYPE,
																	 CMSIXProperties::TYPE_INT32,
																	 nDesc, VARIANT_TRUE, VARIANT_FALSE, VARIANT_FALSE, _variant_t(), vbIsRequired) ;
      if (bRetCode == FALSE)
      {
        SetError(pDBProperty->GetLastError(), 
          "Init() failed. Unable to initialize discount view property");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      }
      else
      {
        // do a find to see id the property exists ...
        if (mResvdPropColl.count (DB_INTERVAL_ID) > 0 || 
          mPropColl.count (DB_INTERVAL_ID) > 0)
        {
          delete pDBProperty ;
          pDBProperty = NULL ;
        }
        else
        {
          // add the element to the view collection ...
          mResvdPropColl[pDBProperty->GetName()] = pDBProperty ;
        }
      }
    }
  }
  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    // create a new discount view property ...
    pDBProperty = new DBProductViewProperty ;
    ASSERT (pDBProperty) ;
    if (pDBProperty == NULL)
    {
      bRetCode = FALSE ;
      SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBDiscountView::Init") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {
      // get the description id for amount ...
      if (!pCodeLookup->GetEnumDataCode(DB_TIMESTAMP_FQN, nDesc))
      {
        SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "DBDiscountView::Init");
        mLogger->LogErrorObject (LOG_WARNING, GetLastError()) ;
        mLogger->LogVarArgs (LOG_WARNING, L"Unable to get code lookup id for string = %s.",
          DB_TIMESTAMP_FQN) ;
        nDesc = -1;
      }

      // initialize the property object ...
      bRetCode = pDBProperty->Init(DB_TIMESTAMP, DB_TIMESTAMP, DB_DATE_TYPE, 
																	 CMSIXProperties::TYPE_TIMESTAMP,
																	 nDesc, VARIANT_TRUE, VARIANT_TRUE, VARIANT_TRUE, _variant_t() , vbIsRequired);
      if (bRetCode == FALSE)
      {
        SetError(pDBProperty->GetLastError(), 
								 "Init() failed. Unable to initialize discount view property");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      }
      else
      {
        // do a find to see id the property exists ...
        if (mResvdPropColl.count (DB_TIMESTAMP) > 0 || 
          mPropColl.count (DB_TIMESTAMP) > 0)
        {
          delete pDBProperty ;
          pDBProperty = NULL ;
        }
        else
        {
          // add the element to the view collection ...
          mResvdPropColl[pDBProperty->GetName()] = pDBProperty ;
        }
      }
    }
  }
  // release the code lookup instance ...
  if (pCodeLookup != NULL)
  {
    pCodeLookup->ReleaseInstance() ;
    pCodeLookup = NULL ;
  }

  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    try
    {
      // create the queryadapter ...
      IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
      
      // initialize the queryadapter ...
      mConfigPath = "\\Queries\\Database" ;
      queryAdapter->Init(mConfigPath) ;
      
      // extract and detach the interface ptr ...
      mpQueryAdapter = queryAdapter.Detach() ;
    }
    catch (_com_error e)
    {
      //SetError(e) ;
      SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBDiscountView::Init", 
        "Unable to initialize query adapter");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Init() failed. Error Description = %s", (char*)e.Description()) ;
      bRetCode = FALSE ;
    }
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
BOOL DBDiscountView::GetDisplayItems (const int &arAcctID, const int &arIntervalID,
                                     const std::wstring &agrLangCode, DBSQLRowset * & arpRowset,long instanceID ) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // call GetDisplayItems with no extension ...
  GetDisplayItems (arAcctID, arIntervalID,agrLangCode, L" ", arpRowset,instanceID) ;

  return bRetCode ;
}

BOOL DBDiscountView::GetDisplayItems (const int &arAcctID, const int &arIntervalID,
                                     const std::wstring &arLangCode, const std::wstring &arExtension,
                                     DBSQLRowset * & arpRowset,long instanceID ) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  std::wstring wstrCmd;

  // get the usage cycle collection ...
  DBUsageCycleCollection *pUsageCycle= DBUsageCycleCollection::GetInstance() ;
  if (pUsageCycle == NULL)
  {
    SetError (DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
      "DBDiscountView::GetDisplayItems", "Unable to get instance of the usage cycle collection") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  
  // create a SQL Rowset ...
  arpRowset = new DBSQLRowset ;
  ASSERT (arpRowset) ;
  if (arpRowset == NULL)
  {
    pUsageCycle->ReleaseInstance() ;
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBDiscountView::GetDisplayItems") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  

	// create the query to get the items for the view ...
	wstrCmd = CreateDiscountViewItemsQuery (arAcctID,  arIntervalID, 
		 mTableName, arExtension) ;
	mLock.Unlock() ;
  
  // initialize the access to the database ...
  DBAccess myDBAccess ;
  bRetCode = myDBAccess.Init((wchar_t*)mConfigPath) ;
  if (bRetCode == FALSE)
  {
    pUsageCycle->ReleaseInstance() ;
    SetError(myDBAccess.GetLastError(), 
      "Init() failed. Unable to initialize database access layer");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return bRetCode ;
  }
  // issue a query to get the items for the product ...
  bRetCode = myDBAccess.ExecuteDisconnected (wstrCmd, (DBSQLRowset &) *arpRowset) ;
  if (bRetCode == FALSE)
  {
    SetError(myDBAccess.GetLastError(), 
      "GetDisplayItems() failed. Unable to execute database query(2)");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  // release the usage cycle collection ...
  if (pUsageCycle != NULL)
  {
    pUsageCycle->ReleaseInstance() ;
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
BOOL DBDiscountView::Summarize(const int &arAcctID, const int &arIntervalID,
                              DBSQLRowset * & arpRowset) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // call Summarize with no extension ...
  Summarize (arAcctID, arIntervalID,arpRowset, L" ") ;

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBDiscountView::Summarize(const int &arAcctID, const int &arIntervalID,
                              DBSQLRowset * & arpRowset,
                              const std::wstring &arExtension) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  std::wstring wstrCmd;

  // get the usage cycle collection ...
  DBUsageCycleCollection *pUsageCycle= DBUsageCycleCollection::GetInstance() ;
  if (pUsageCycle == NULL)
  {
    SetError (DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
      "DBDiscountView::Summarize", "Unable to get instance of the usage cycle collection") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  // create a SQL Rowset ...
  arpRowset = new DBSQLRowset ;
  ASSERT (arpRowset) ;
  if (arpRowset == NULL)
  {
    pUsageCycle->ReleaseInstance() ;
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBDiscountView::Summarize") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

	// lock the threadlock to create and execute the query ...
	mLock.Lock() ;
	// create the query to get the items for the product ...
	wstrCmd = CreateDiscountViewSummarizeQuery (arAcctID,  arIntervalID,
		mTableName, mID, mName, mType, mDescriptionID, arExtension) ;
	mLock.Unlock() ;

  // initialize the access to the database ...
  DBAccess myDBAccess ;
  bRetCode = myDBAccess.Init((wchar_t*)mConfigPath) ;
  if (bRetCode == FALSE)
  {
    pUsageCycle->ReleaseInstance() ;
    SetError(myDBAccess.GetLastError(), 
      "Init() failed. Unable to initialize database access layer");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return bRetCode ;
  }
	// issue a query to get the items for the product ...
	bRetCode = myDBAccess.ExecuteDisconnected (wstrCmd, (DBSQLRowset &) *arpRowset) ;
	if (bRetCode == FALSE)
	{
		SetError(myDBAccess.GetLastError(), 
			"Summarize() failed. Unable to execute database query");
		mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
	}
  // release the usage cycle collection ...
  if (pUsageCycle != NULL)
  {
    pUsageCycle->ReleaseInstance() ;
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
BOOL DBDiscountView::GetDisplayItemDetail(const int &arAcctID, const int &arIntervalID,
                                         const int &arSessionID, const std::wstring &arLangCode,
                                         DBSQLRowset * & arpRowset) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  std::wstring wstrCmd;

  // get the usage cycle collection ...
  DBUsageCycleCollection *pUsageCycle= DBUsageCycleCollection::GetInstance() ;
  if (pUsageCycle == NULL)
  {
    SetError (DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
      "DBDiscountView::GetDisplayItems", "Unable to get instance of the usage cycle collection") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  
  // create a SQL Rowset ...
  arpRowset = new DBSQLRowset ;
  ASSERT (arpRowset) ;
  if (arpRowset == NULL)
  {
    pUsageCycle->ReleaseInstance() ;
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, 
      "DBDiscountView::GetDisplayItemDetail") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  // lock the threadlock to create and execute the query ...
  mLock.Lock() ;
  // create the query to get the items for the product ...
  wstrCmd = CreateDiscountViewItemDetailQuery (arAcctID,  arIntervalID,
      arSessionID, mTableName) ;
  mLock.Unlock() ;
  
  // initialize the access to the database ...
  DBAccess myDBAccess ;
  bRetCode = myDBAccess.Init((wchar_t*)mConfigPath) ;
  if (bRetCode == FALSE)
  {
    pUsageCycle->ReleaseInstance() ;
    SetError(myDBAccess.GetLastError(), 
      "Init() failed. Unable to initialize database access layer");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return bRetCode ;
  }
  // issue a query to get the items for the product ...
  bRetCode = myDBAccess.ExecuteDisconnected (wstrCmd, (DBSQLRowset &) *arpRowset) ;
  if (bRetCode == FALSE)
  {
    SetError(myDBAccess.GetLastError(), 
      "GetDisplayItemDetail() failed. Unable to execute database query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  // release the usage cycle collection ...
  if (pUsageCycle != NULL)
  {
    pUsageCycle->ReleaseInstance() ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	Create the discount view summarize query. 
//  @rdesc 
//  The discount view summarize query.
//
std::wstring DBDiscountView::CreateDiscountViewSummarizeQuery(const int &arAcctID,
          const int &arIntervalID, 
          const std::wstring &arPDTableName,const int &arViewID, 
          const std::wstring &arViewName, const std::wstring &arViewType, 
          const int &arDescriptionID, const std::wstring &arExtension)
{
  // local variables ...
  std::wstring wstrCmd ;
  _variant_t vtParam ;
  _bstr_t queryTag ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__GET_DISCOUNT_VIEW_SUMMARIZE__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam = (long) arViewID ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWID, vtParam) ;
    vtParam = arViewName.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWNAME, vtParam) ;
    vtParam = arViewType.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWTYPE, vtParam) ;
    vtParam = (long) arDescriptionID ;
    mpQueryAdapter->AddParam (MTPARAM_DESCID, vtParam) ;
    vtParam = arPDTableName.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_TABLENAME, vtParam) ;
    vtParam = (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam = (long) arIntervalID ;
    mpQueryAdapter->AddParam (MTPARAM_INTERVALID, vtParam) ;
    vtParam = arExtension.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_EXT, vtParam, VARIANT_TRUE) ;
        
    // get the query ...
    _bstr_t queryString ;    
    queryString = mpQueryAdapter->GetQuery() ;
    wstrCmd = (wchar_t*) queryString ;
  }
  catch (_com_error e)
  {
    wstrCmd = L"" ;
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBDiscountView::CreateDiscountViewSummarizeQuery", 
      "Unable to get __GET_PRODUCT_VIEW_SUMMARIZE__ query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to create query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}

std::wstring DBDiscountView::CreateDiscountViewItemsQuery(const int &arAcctID,
          const int &arIntervalID, 
          const std::wstring &arPDTableName, const std::wstring &arExtension)
{
  // local variables ...
  std::wstring wstrCmd ;
  _variant_t vtParam ;
  _bstr_t queryTag ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__GET_DISCOUNT_VIEW_ITEMS_EXT__" ;
    
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam = mSelectClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_SELECTCLAUSE, vtParam) ;
    vtParam = arPDTableName.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_TABLENAME, vtParam) ;
    vtParam = (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam = (long) arIntervalID ;
    mpQueryAdapter->AddParam (MTPARAM_INTERVALID, vtParam) ;
    vtParam = arExtension.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_EXT, vtParam, VARIANT_TRUE) ;
            
    // get the query ...
    _bstr_t queryString ;
    queryString = mpQueryAdapter->GetQuery () ;
    wstrCmd = (wchar_t*) queryString ;
  }
  catch (_com_error e)
  {
    wstrCmd = L"" ;
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBDiscountView::CreateDiscountViewItemsQuery", 
      "Unable to get __GET_DISCOUNT_VIEW_ITEMS_EXT__ query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to create query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}

//
//	@mfunc
//	Create the discount view items query. 
//  @rdesc 
//  The discount view items query.
//
std::wstring DBDiscountView::CreateDiscountViewItemDetailQuery(const int &arAcctID,
          const int &arIntervalID, const int &arSessionID, 
          const std::wstring &arPDTableName)
{
  // local variables ...
  std::wstring wstrCmd ;
  _variant_t vtParam ;
  _bstr_t queryTag ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__GET_DV_ITEM_DETAIL__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam = mSelectClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_SELECTCLAUSE, vtParam) ;
    vtParam = arPDTableName.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_TABLENAME, vtParam) ;
    vtParam = (long) arSessionID ;
    mpQueryAdapter->AddParam (MTPARAM_SESSIONID, vtParam) ;
    vtParam = (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam = (long) arIntervalID ;
    mpQueryAdapter->AddParam (MTPARAM_INTERVALID, vtParam) ;
            
    // get the query ...
    _bstr_t queryString ;
    queryString = mpQueryAdapter->GetQuery () ;
    wstrCmd = (wchar_t*) queryString ;
  }
  catch (_com_error e)
  {
    wstrCmd = L"" ;
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, 
      "DBDiscountView::CreateDiscountViewItemDetailQuery", 
      "Unable to get __GET_DV_ITEM_DETAIL__ query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to create query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}

