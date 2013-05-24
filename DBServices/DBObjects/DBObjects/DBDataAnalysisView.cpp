/**************************************************************************
 * @doc DBDataAnalysisView
 * 
 * @module  Encapsulation of a single data analysis view|
 * 
 * This class encapsulates the properties of a single data analysis view.
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
 * @index | DBDataAnalysisView
 ***************************************************************************/

#include <metra.h>
#include <mtprogids.h>
#include <mtparamnames.h>
#include <DBDataAnalysisView.h>
#include <DBProductViewProperty.h>
#include <DBConstants.h>
#include <DBSQLRowset.h>
#include <DBInMemRowset.h>
#include <DBMiscUtils.h>
#include <mtglobal_msg.h>
#include <DBUsageCycle.h>
#include <MTDataAnalysisView.h>
#include <CodeLookup.h>

// import the query adapter tlb ...
#import <QueryAdapter.tlb> no_namespace rename("GetUserName", "GetUserNameQA")

//
//	@mfunc
//	Constructor. Initialize the appropriate data members.
//  @rdesc 
//  No return value
//
DBDataAnalysisView::DBDataAnalysisView()
{
}

//
//	@mfunc
//	Destructor. 
//  @rdesc 
//  No return value
//
DBDataAnalysisView::~DBDataAnalysisView()
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
BOOL DBDataAnalysisView::Init(const std::wstring &arViewType, const int &arViewID, 
                         const std::wstring &arName, const int &arDescriptionID,
                         MTDataAnalysisView *pDataAnalysisView) 
{
  // local variables
  BOOL bRetCode=TRUE ;
  std::wstring wstrName ;
  std::wstring wstrColumn ;
  std::wstring wstrType ;
	CMSIXProperties::PropertyType msixPropType;
  int nDesc=0 ;
  DBProductViewProperty *pDBProperty=NULL ;
  std::wstring wstrEnumNamespace, wstrEnumEnumeration, wstrFQN ;

  // initialize the view ...
  bRetCode = DBView::Init (arViewType, arViewID, arName, arDescriptionID) ;
  if (bRetCode == FALSE)
  {
    SetError(DBView::GetLastError(), 
      "Init() failed. Unable to initialize data analysis view");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  
  // copy the data members out of the data analysis view ...
  ASSERT (pDataAnalysisView) ;
  mQueryTag = pDataAnalysisView->GetQueryTag() ;
  
  // create the code lookup object ...
  CCodeLookup *pCodeLookup = CCodeLookup::GetInstance() ;
  if (pCodeLookup == NULL)
  {
    SetError(DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, "DBDataAnalysisView::Init", 
      "Init() failed. Unable to get code lookup singleton.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE;
  }

  // get the data analysis view properties iterator ...
  
  // iterate through the properties ...
  for (DataAnalysisViewPropColl::iterator Iter = pDataAnalysisView->GetPropertyList().begin();
				 Iter != pDataAnalysisView->GetPropertyList().end() && bRetCode == TRUE;
				 Iter++)
  {
    // create a new product view property ...
    pDBProperty = new DBProductViewProperty ;
    ASSERT (pDBProperty) ;
    if (pDBProperty == NULL)
    {
      bRetCode = FALSE ;
      SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBDataAnalysisView::Init") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    
    // get the data analysis view property and copy the parameters ...
		MTDataAnalysisViewProp *pProp = Iter->second;
    wstrName = pProp->GetName() ;
    wstrColumn = pProp->GetColumnName() ;
    wstrType = pProp->GetType() ;
		msixPropType = pProp->GetMSIXType();

    if (_wcsicmp(wstrType.c_str(), DB_ENUM_TYPE) == 0)
    {
      // get the namespace and enumeration ...
      wstrEnumNamespace = pProp->GetEnumNamespace() ;
      wstrEnumEnumeration = pProp->GetEnumEnumeration() ;
    }

    // get the description id ... create the string then get it ...
    wstrFQN = arName ;
    wstrFQN += L"/" ;
    wstrFQN += wstrName ;
    if (!pCodeLookup->GetEnumDataCode(wstrFQN.c_str(), nDesc))
    {
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "DBDataAnalysisView::Init");
      mLogger->LogErrorObject (LOG_WARNING, GetLastError()) ;
      mLogger->LogVarArgs (LOG_WARNING, "Unable to get code lookup id for string = %s.",
        ascii(wstrFQN).c_str()) ;
      nDesc = -1;
    }
    
    // initialize the product view object ...
    bRetCode = pDBProperty->Init(wstrName, wstrColumn, wstrType, 
																 msixPropType,
																 nDesc,
																 VARIANT_TRUE, VARIANT_TRUE, VARIANT_TRUE) ;
    if (bRetCode == FALSE)
    {
      SetError(pDBProperty->GetLastError(), 
        "Init() failed. Unable to initialize data analysis view property");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {
      // do a find to see id the property exists ...
      if (mPropColl.count (wstrName) > 0)
      {
        mLogger->LogVarArgs (LOG_ERROR, 
          L"Found duplicate property with name = %s in data analysis view with name = %s.", 
          wstrName.c_str(), mName.c_str()) ;
        bRetCode = FALSE ;
      }
      else
      {
        // add the element to the view collection ...
        mPropColl[pDBProperty->GetName()] = pDBProperty ;
        
        // if this property is an enum type ...
        if (_wcsicmp(wstrType.c_str(), DB_ENUM_TYPE) == 0)
        {
          // add the enum specific values to the property ...
          pDBProperty->SetEnumNamespace (wstrEnumNamespace) ;
          pDBProperty->SetEnumEnumeration (wstrEnumEnumeration) ;
          pDBProperty->SetEnumColumnName(mNumEnums) ;
          
          // add the enum to the clauses
          AddEnumToQuery(wstrColumn, wstrColumn) ;
        }
        else
        {
          AddToSelectClause(wstrColumn, wstrColumn) ;
        }
      }
    }
  }

  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    try
    {
      // create the queryadapter ...
      IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
      
      // initialize the queryadapter ...
      mConfigPath = pDataAnalysisView->GetConfigPath().c_str();
      queryAdapter->Init(mConfigPath) ;
      
      // extract and detach the interface ptr ...
      mpQueryAdapter = queryAdapter.Detach() ;
    }
    catch (_com_error e)
    {
      //SetError(e) ;
      SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBDataAnalysisView::Init", 
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
BOOL DBDataAnalysisView::GetDisplayItems (const int &arAcctID, const int &arIntervalID,
                                          const std::wstring &arLangCode, DBSQLRowset * & arpRowset,long instanceID) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // call GetDisplayItems with no extension ...
  GetDisplayItems (arAcctID, arIntervalID, L" ", arpRowset,instanceID) ;

  return bRetCode ;
}

BOOL DBDataAnalysisView::GetDisplayItems (const int &arAcctID, const int &arIntervalID,
    const std::wstring &arLangCode, const std::wstring &arExtension, DBSQLRowset * & arpRowset,long instanceID) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  std::wstring wstrCmd;

  // create a SQL Rowset ...
  arpRowset = new DBSQLRowset ;
  ASSERT (arpRowset) ;
  if (arpRowset == NULL)
  {
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBDataAnalysisView::GetDisplayItems") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  
  // initialize the access to the database ...
  DBAccess myDBAccess ;
  bRetCode = myDBAccess.Init((wchar_t*)mConfigPath) ;
  if (bRetCode == FALSE)
  {
    SetError(myDBAccess.GetLastError(), 
      "Init() failed. Unable to initialize database access layer");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return bRetCode ;
  }
  // get the language id ...
  std::wstring wstrKey = arLangCode ;
  int nLangCode = 840 ; // default to english 
  StrToLower(wstrKey) ;
  LangCodeCollIter langiter = mLangCodeColl.find (wstrKey) ;
  if (langiter == mLangCodeColl.end())
  {
    mLogger->LogVarArgs (LOG_WARNING, "Unable to find language code in collection. Lang Code = %s",
      ascii(wstrKey).c_str()) ;
  }
	else
	{
		nLangCode = langiter->second;
	}
  
  // lock the threadlock to create and execute the query ...
  mLock.Lock() ;
  
  // create the query to get the items for the view ...
  wstrCmd = CreateDataAnalyisViewItemsQuery (mQueryTag, arAcctID, arIntervalID, 
    arExtension, nLangCode) ;
  mLock.Unlock() ;
  
  // issue a query to get the items for the product ...
  bRetCode = myDBAccess.ExecuteDisconnected (wstrCmd, (DBSQLRowset &) *arpRowset) ;
  if (bRetCode == FALSE)
  {
    SetError(myDBAccess.GetLastError(), 
      "GetDisplayItems() failed. Unable to execute database query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
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
BOOL DBDataAnalysisView::Summarize(const int &arAcctID, const int &arIntervalID,
                              DBSQLRowset * & arpRowset) 
{
  // set the error ...
  SetError(DB_ERR_UNSUPPORTED_FUNCTION, ERROR_MODULE, ERROR_LINE, 
      "DBDataAnalysisView::Summarize");
  mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;

  return FALSE ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBDataAnalysisView::Summarize(const int &arAcctID, const int &arIntervalID,
                              DBSQLRowset * & arpRowset,
                              const std::wstring &arExtension) 
{
  // set the error ...
  SetError(DB_ERR_UNSUPPORTED_FUNCTION, ERROR_MODULE, ERROR_LINE, 
      "DBDataAnalysisView::Summarize");
  mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;

  return FALSE ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBDataAnalysisView::GetDisplayItemDetail(const int &arAcctID, const int &arIntervalID,
    const int &arSessionID, const std::wstring &arLangCode, DBSQLRowset * & arpRowset) 
{
  // set the error ...
  SetError(DB_ERR_UNSUPPORTED_FUNCTION, ERROR_MODULE, ERROR_LINE, 
      "DBDataAnalysisView::GetDisplayItemDetail");
  mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;

  return FALSE ;
}

std::wstring DBDataAnalysisView::CreateDataAnalyisViewItemsQuery(const std::wstring &arQueryTag,
          const int &arAcctID, const int &arIntervalID, const std::wstring &arExtension,
          const int &arLangCode)
{
  // local variables ...
  std::wstring wstrCmd, wstrWhereClause ;
  _variant_t vtParam ;
  _bstr_t queryTag ;

  try
  {
    // replace the lang code in the where clause ...
    wstrWhereClause = ReplaceLangCode (arLangCode, mWhereClause) ;

    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = arQueryTag.c_str() ;
    
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam = mSelectClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_SELECTCLAUSE, vtParam) ;
    vtParam = wstrWhereClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_WHERECLAUSE, vtParam) ;
    vtParam = mFromClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_FROMCLAUSE, vtParam) ;
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
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBDataAnalysisView::CreateDiscountViewItemsQuery", 
      "Unable to get DataAnalysisView query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, "Unable to get query for tag %s", 
      ascii(arQueryTag).c_str()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "CreateDiscountViewItemsQuery() failed. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}


