/**************************************************************************
* @doc DBSummaryView
* 
* @module  Encapsulation of a summary view|
* 
* This class encapsulates a summary view
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
* @index | DBSummaryView
***************************************************************************/

#include <metra.h>
#include <DBSummaryView.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <mtparamnames.h>
#include <LanguageList.h>

using namespace std;
typedef list<int> ListViewIDs;
typedef list<int>::iterator ListViewIDsIterator;

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName","QAGetUserName") no_namespace

//
//	@mfunc
//	Constructor. Initialize the appropriate data members.
//  @rdesc 
//  No return value
//
DBSummaryView::DBSummaryView() :
mpQueryAdapter(0),
mpUsageCycle(0)
{
}

//
//	@mfunc
//	Destructor. 
//  @rdesc 
//  No return value
//
DBSummaryView::~DBSummaryView()
{
  // release the interface ptrs ...
  if (mpQueryAdapter != NULL)
  {
    mpQueryAdapter->Release() ;
  }
  
  // release the instance to the usage cycle collection
  if (mpUsageCycle != NULL)
  {
    mpUsageCycle->ReleaseInstance();
  }
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBSummaryView::Init(const std::wstring &arViewType, const int &arViewID, 
                         const std::wstring &arName, const int &arDescriptionID) 
{
  // local variables
  BOOL bRetCode=TRUE ;
  
  // initialize the view ...
  bRetCode = DBView::Init (arViewType, arViewID, arName, arDescriptionID) ;
  if (bRetCode == FALSE)
  {
    SetError (DBView::GetLastError(),
      "Init() failed. Unable to initialize view.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  
  if (mpQueryAdapter == NULL)
  {
    try
    {
      // create the queryadapter ...
      IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
      
      // initialize the queryadapter ...
      queryAdapter->Init("\\Queries\\Database") ;
      
      // extract and detach the interface ptr ...
      mpQueryAdapter = queryAdapter.Detach() ;
    }
    catch (_com_error e)
    {
		    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBSummaryView::Init", 
          "Unable to initialize query adapter");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      		mLogger->LogVarArgs (LOG_ERROR, 
            "Init() failed. Error Description = %s", (char*)e.Description()) ;
          bRetCode = FALSE ;
    }
  }
  
  // get the instance to usage cycle collection pointer here
  // get the usage cycle collection ...
  if (mpUsageCycle == NULL)
  {
    mpUsageCycle= DBUsageCycleCollection::GetInstance() ;
    if (mpUsageCycle == NULL)
  		{
		    SetError (DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
          "DBSummaryView::Init", "Unable to get instance of the usage cycle collection") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
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
BOOL DBSummaryView::GetDisplayItems (const int &arAcctID, const int &arIntervalID,
                                     const std::wstring &arLangCode, DBSQLRowset * & arpRowset,long instanceID) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  
  // call GetDisplayItems with no query extension ...
  bRetCode = GetDisplayItems (arAcctID, arIntervalID, arLangCode, L" ", arpRowset,instanceID) ;
  
  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBSummaryView::GetDisplayItems (const int &arAcctID, 
                                     const int &arIntervalID,
                                     const std::wstring &arLangCode, 
                                     const std::wstring &arExtension,
                                     DBSQLRowset * & arpRowset,long instanceID) 
{
  // local variables ...
  BOOL bRetCode = TRUE ;
  DBSQLRowset *pRowset=NULL ;
  DBView *pView=NULL ;
  int nViewID ;
  
  // This list will contain only the IDs of views with type 'Product'
  ListViewIDs listProductViewIDs;

	MTAutoSingleton<MTPCHierarchyColl> mVHinstance;
	MTautoptr<MTPCViewHierarchy> aHierarchy;

  
	// get the language id
	std::wstring aTempStr(arLangCode);
	StrToLower(aTempStr);
	_bstr_t langkey = aTempStr.c_str();
  int nLangCode = 840 ; // default to english 
	MTAutoSingleton<CLanguageList> langList;
	const ReverseLanguageList& alist = langList->GetReverseLanguageList();
	ReverseLanguageListIterator iter = alist.find(langkey);
	if(iter == alist.end()) {
    mLogger->LogVarArgs (LOG_WARNING, "Unable to find language code in collection. Lang Code = %s",
			(const char*)langkey);
		return FALSE;
	}
	nLangCode = (*iter).second;


  // get an instance to the view collection ...
	try {
		aHierarchy = mVHinstance->GetAccHierarchy(arAcctID,arIntervalID,arLangCode.c_str());
	}
	catch(ErrorObject& err) {
    mLogger->LogErrorObject (LOG_ERROR, &err);
		SetError(&err);
		return FALSE;
	}

  
  // create a nonSQL Rowset ...
  arpRowset = new DBSQLRowset ;
  ASSERT (arpRowset) ;
  
  // initialize the rowset with the appropriate columns ...
  bRetCode = InitializeInMemRowset (arpRowset) ;
  if (bRetCode == FALSE)
  {
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, 
			  	"DBSummaryView::GetDisplayItems") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

	// populate line item summary views from the product catalog
	aHierarchy->PopulateInMemRowset(*arpRowset);
  
  // iterate over my children and get a line item for each child ...
  for (DBViewIDCollIter Iter = mChildViewList.begin();
			 Iter != mChildViewList.end();
			 Iter++)
  {
    // find the view ...
    nViewID = *Iter ;
    bRetCode = aHierarchy->FindView (nViewID, pView) ;
    if (bRetCode == FALSE)
    {
        SetError (aHierarchy->GetLastError(), 
          "GetDisplayItems() failed. Unable to find view.") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        return FALSE;
    }
    
    // populate the list with product view IDs
    // if its not a Product type, go the normal route.
    //if (0 != pView->GetViewType().compareTo(L"Product", RWWString::ignoreCase))
	if (0 != _wcsicmp(pView->GetViewType().c_str(), L"Product"))
    {
      // found the view ...
      // call summarize() ...
      bRetCode = pView->Summarize(arAcctID, arIntervalID, pRowset, arExtension) ;
      if (bRetCode == FALSE)
      {
        SetError (pView->GetLastError(), 
          "GetDisplayItems() failed. Unable to summarize view.") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        return FALSE ;
      }
      
      // insert the summarization into the nonSQLRowset ...
      bRetCode = InsertIntoInMemRowset (arpRowset, pRowset) ;
      if (bRetCode == FALSE)
      {
        SetError (pView->GetLastError(), 
          "GetDisplayItems() failed. Unable to insert into Rowset.") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        return FALSE ;
      }
      
      // get the record count ...
      int nRowCount = pRowset->GetRecordCount() ;
      if (nRowCount == 0)
      {
        bRetCode = InsertDefaultRowIntoInMemRowset (arpRowset, 
          nViewID, 
          pView->GetViewName(), 
          pView->GetViewDescriptionID(),
          pView->GetViewType(), 
          arAcctID, 
          arIntervalID) ;
      }
    }
    else
      listProductViewIDs.insert(listProductViewIDs.begin(), nViewID);
    
    // clean up the rowset ...
    delete pRowset ;
    pRowset = NULL ;
    pView = NULL ;
  }

	// case where we have no product views.  Exit
	if(listProductViewIDs.size() == 0) {
		// XXX
		return TRUE;
	}
  
  // ---------------------- FOR MPS PERFORMANCE --------------------------
  // iterate over the product view IDs
  // build the sql string containing the string with the following example 
  // "in (5, 2, 6, 7, 3, 4, 415, 481, 8, 429, 488, 435, 438)"
  std::wstring wstrIDsForSQLQuery; 
  wstrIDsForSQLQuery = L" in (";
  int iViewID;
  int index = 0;
  wchar_t wBuffer[20];
  int iSizeList = listProductViewIDs.size();
  
  ListViewIDsIterator itr;
  for (itr = listProductViewIDs.begin(); itr != listProductViewIDs.end(); ++itr)
  {
    iViewID = *itr;
    _itow (iViewID, wBuffer, 10);
    wstrIDsForSQLQuery += wBuffer;
    index++;
    // if it is not the end of the list, put a comma, otherwise get out.
    if (index != iSizeList)
      wstrIDsForSQLQuery += L", ";
  }
  wstrIDsForSQLQuery += L")";
  
  // initialize the access to the database ...
  DBAccess myDBAccess ;
  if (!myDBAccess.Init(L"\\Queries\\Database"))
  {
    SetError(myDBAccess.GetLastError(), 
			   "Init() failed. Unable to initialize database access layer");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  
  // create the query to get the items for the product ...
  std::wstring wstrCmd;
  wstrCmd = CreateProductViewSummarizeOptimizedQuery(arAcctID,  
    arIntervalID, 
    wstrIDsForSQLQuery,
		nLangCode);
  
  // create a SQL Rowset ...
  DBSQLRowset sqlRowset;
  
  // issue a query to get the items for the product ...
  if (!myDBAccess.ExecuteDisconnected (wstrCmd, sqlRowset))
  {
    SetError(myDBAccess.GetLastError(), 
      "Summarize() failed. Unable to execute database query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE;
  }
  
  // insert the summarization into the nonSQLRowset ...
	 bRetCode = InsertIntoInMemRowset (arpRowset, 
     &sqlRowset) ;
   if (bRetCode == FALSE)
   {
     SetError (pView->GetLastError(), 
       "GetDisplayItems() failed. Unable to insert into Rowset.") ;
     mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
     return FALSE ;
   }
   
   // check to see if that view ID is in the list of view IDs
   ListViewIDsIterator itr2;
   for (itr2 = listProductViewIDs.begin(); 
		 itr2 != listProductViewIDs.end(); 
     ++itr2)
     {
       _variant_t vtEOF;
       long lVal;
       while ((!sqlRowset.AtEOF()) && (bRetCode == TRUE))
       {
         sqlRowset.GetLongValue(_variant_t(L"ViewID"), lVal);
         if (lVal != *itr2) 
         {
           
           // find view on itr2
           // get pview
           // pass that in 
           // find the view ...
           bRetCode = aHierarchy->FindView (*itr2, pView) ;
           if (bRetCode == FALSE)
           {
          			SetError (aHierarchy->GetLastError(), 
                  "GetDisplayItems() failed. Unable to find view.") ;
                mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
                return FALSE;
           }
           
           bRetCode = InsertDefaultRowIntoInMemRowset (arpRowset, 
             nViewID, 
             pView->GetViewName(), 
             pView->GetViewDescriptionID(),
             pView->GetViewType(), 
             arAcctID, 
             arIntervalID) ;
         }
         bRetCode = sqlRowset.MoveNext();
       }
     }
     
     // clean up the rowset ...
     pView = NULL ;
     // ---------------------- FOR MPS PERFORMANCE --------------------------
     if(arpRowset->GetRecordCount() > 0)
	     	arpRowset->MoveFirst();
   return bRetCode ;
}

//
//	@mfunc
//	Create the product view summarize query. 
//  @rdesc 
//  The product view summarize query.
//
std::wstring 
DBSummaryView::CreateProductViewSummarizeOptimizedQuery(const int &arAcctID,
                                                        const int &arIntervalID, 
                                                        const std::wstring& arIDsForSQLQuery,
																												const int aLanguageCode)
{
  // local variables ...
  std::wstring wstrCmd ;
  _variant_t vtParam ;
  _bstr_t queryTag ;
  
  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;
    
    queryTag = "__GET_PRODUCT_VIEW_SUMMARIZE_OPTIMIZED__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;
    
    vtParam = (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam = (long) arIntervalID ;
    mpQueryAdapter->AddParam (MTPARAM_INTERVALID, vtParam) ;
    vtParam = arIDsForSQLQuery.c_str();
    mpQueryAdapter->AddParam (MTPARAM_VIEWIDS, vtParam) ;
    mpQueryAdapter->AddParam ("%%LANGID%%", (long)aLanguageCode) ;
    
    // get the query ...
    _bstr_t queryString ;    
    queryString = mpQueryAdapter->GetQuery() ;
    wstrCmd = (wchar_t*) queryString ;
  }
  catch (_com_error e)
  {
    wstrCmd = L"" ;
    SetError(e.Error(), 
      ERROR_MODULE, 
      ERROR_LINE, 
      "DBSummaryView::CreateProductViewSummarizeQuery", 
      "Unable to get __GET_PRODUCT_VIEW_SUMMARIZE__ query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
						"Unable to get query. Error Description = %s", (char*)e.Description()) ;
  }
  
  return wstrCmd ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBSummaryView::Summarize(const int &arAcctID, const int &arIntervalID,
                              DBSQLRowset * & arpRowset) 
{
  // local variables ...
  BOOL bRetCode = TRUE ;
  
  // call summarize ...
  bRetCode = Summarize (arAcctID, arIntervalID, arpRowset, L" ") ;
  
  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBSummaryView::Summarize(const int &arAcctID, const int &arIntervalID,
                              DBSQLRowset * & arpRowset,
                              const std::wstring &arExtension) 
{
  // local variables ...
  BOOL bRetCode = TRUE ;
  DBSQLRowset *pRowset=NULL ;
  DBView *pView=NULL ;
  int nViewID ;
  BOOL bFirstTime=TRUE ;

	MTAutoSingleton<MTPCHierarchyColl> mVHinstance;
	MTautoptr<MTPCViewHierarchy> aHierarchy;
  try {
		// The hardcoded language code actually doesn't matter here because we 
		// have already retrieved the PC ViewHierarchy and put in the cache 
		// in code higher up the call stack.  Hey, I know it isn't pretty but
		// if you had to inherit Kevin's code, you would be doing shit like this as well.
		aHierarchy= mVHinstance->GetAccHierarchy(arAcctID,arIntervalID,L"USD");
	}
	catch(ErrorObject& err) {
		SetError(&err);
		return FALSE;
	}

  // create a nonSQL Rowset ...
  arpRowset = new DBSQLRowset ;
  
  // iterate over my children and get a line item for each child ...
  for (DBViewIDCollIter Iter = mChildViewList.begin();
			 Iter != mChildViewList.end();
			 Iter++)
  {
    // find the view ...
    nViewID = *Iter ;
    bRetCode = aHierarchy->FindView (nViewID, pView) ;
    if (bRetCode == FALSE)
    {
      SetError (aHierarchy->GetLastError(),
        "Summarize() failed. Unable to find view.") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }
    // found the view ...
    else
    {
      // call summarize() ...
      bRetCode = pView->Summarize(arAcctID, arIntervalID, pRowset, arExtension) ;
      if (bRetCode == FALSE)
      {
        SetError (pView->GetLastError(),
          "Summarize() failed. Unable to summarize.") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        break ;
      }
      else
      {
        // if we have rows to be rolled up ... summarize into the InMemRowset ...
        if (pRowset->GetRecordCount() > 0)
        {
          // if this is the first time we are rolling up ... initialize the rowset ...
          if (bFirstTime == TRUE)
          {
            // initialize the rowset with the appropriate columns ...
            bRetCode = InitializeInMemRowsetForSummary (arpRowset,
              arAcctID, arIntervalID) ;
            bFirstTime = FALSE ;
          }
          
          if (bRetCode == TRUE)
          {
            pView = NULL ;
            bRetCode = SummarizeIntoInMemRowset (arpRowset, pRowset) ;
          }
        }
        // clean up the rowset ...
        delete pRowset ;
        pRowset = NULL ;
        
        if (bRetCode == FALSE)
        {
          break ;
        }
      }
    }
  }        
  
  return bRetCode ;
}
                              
                              //
