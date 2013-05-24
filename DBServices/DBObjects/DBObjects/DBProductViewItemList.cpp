#if 0 // deadcode ( deprecated obsolete dead legacy )

/**************************************************************************
* @doc DBProductViewItemList
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
* @index | DBProductViewItemList
***************************************************************************/

#include <metra.h>
#include <DBProductViewItemList.h>
#include <DBProductViewItem.h>
#include <DBUsageCycle.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <DBMiscUtils.h>
#include <DBProductView.h>
#include <DBDiscountView.h>

#include <mtprogids.h>

using namespace std;

//
//	@mfunc
//	Constructor. Initialize the appropriate data members
//  @rdesc 
//  No return value
//
DBProductViewItemList::DBProductViewItemList()
: mIsInitialized(FALSE), mIntervalID(-1), mpRoot (NULL),
mpUsageCycle(NULL), mAcctID (-1)
{
}

//
//	@mfunc
//	Destructor
//  @rdesc 
//  No return value
//
DBProductViewItemList::~DBProductViewItemList()
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
void DBProductViewItemList::TearDown()
{
  // delete all the allocate memory ...
  for (DBProductViewItemCollIter Iter = mPVIColl.begin(); Iter != mPVIColl.end(); Iter++)
  {
    DBProductViewItem *pPVI = Iter->second ;
    delete pPVI ;
  }
  mPVIColl.clear() ;

  // release the instance of the usage cycle collection ...
  if (mpUsageCycle != NULL)
  {
    mpUsageCycle->ReleaseInstance() ;
  }
  // clear root ...
  mpRoot = NULL ;
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
BOOL DBProductViewItemList::Init(const time_t &arTxnTime, const int &arAcctID)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  std::wstring wstrTxnTime ;
  
  // tear down the allocated memory ...
  TearDown() ;
  mTxnTime = arTxnTime ;
  mAcctID = arAcctID ;

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
      bRetCode = FALSE ;
    }
    else
    {
      // get the interval
      bRetCode = mpUsageCycle->GetIntervalAndTableSuffix (mAcctID, mTxnTime,
        mIntervalID) ;
      if (bRetCode == FALSE)
      {
        SetError (DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
        "DBProductViewItem::Init", "Init() failed. Unable to get interval id") ;
        mLogger->LogVarArgs (LOG_ERROR, 
          "Init() failed. Unable to get interval id for acct id = %d",
          mAcctID) ;
      } 
    }
    if (bRetCode == TRUE)
    {
      // we're initialized now .. set the flag to indicate it ...
      mIsInitialized = TRUE ;
    }
  }

  return bRetCode ;
}

BOOL DBProductViewItemList::Init(const DBPVIInitProperties &arInitProp)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  std::wstring wstrTxnTime ;
  
  // tear down the allocated memory ...
  TearDown() ;

  // copy the parameters out of the property class ...
  mAcctID = arInitProp.GetAccountID();
  mTxnTime = arInitProp.GetTxnTime();
  mIntervalID = arInitProp.GetIntervalID() ;
  
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
      bRetCode = FALSE ;
    }
    else
    {
      // if we don't have the interval id ...
      if (mIntervalID == -1)
      {
        // get the interval 
        bRetCode = mpUsageCycle->GetIntervalAndTableSuffix (mAcctID, mTxnTime,
          mIntervalID) ;
        if (bRetCode == FALSE)
        {
          SetError (DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
            "DBProductViewItem::Init", "Init() failed. Unable to get interval") ;
          mLogger->LogVarArgs (LOG_ERROR, 
            "Init() failed. Unable to get interval id for acct id = %d",
            mAcctID) ;
        } 
      }
    }
    if (bRetCode == TRUE)
    {
      // we're initialized now .. set the flag to indicate it ...
      mIsInitialized = TRUE ;
    }
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
BOOL DBProductViewItemList::AddItem(DBProductViewItem *apItem)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  std::wstring parentUID ;

  // if we're not initialized ... exit ...
  if (mIsInitialized == FALSE) 
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, 
      "DBProductViewItemList::AddItem");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
  else if (apItem == NULL)
  {
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBProductViewItemList::AddItem");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }
  else
  {
    // get the parent uid from the item ...
    parentUID = apItem->GetParentUID() ;
		DBProductViewItem *pParent = NULL;
    // if we have a parent .. find it in the list ...
    if (!parentUID.empty())
    {
      DBProductViewItemCollIter PVIIter = mPVIColl.find (parentUID) ;
      if (PVIIter == mPVIColl.end())
      {
        SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
          "DBProductViewItemList::AddItem");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        return bRetCode ;
      }
      else
      {
				pParent = PVIIter->second;

        // set the parent of the item ...
        apItem->SetParentItem (pParent) ;

        // add the item to the parent ...
        pParent->AddChildItem (apItem) ;
      }
    }
    else
    {
      pParent = NULL ;
    }
    // add the item to the list ...
    mPVIColl[apItem->GetUID()] = apItem ;

    // if we dont have a parent then we are the root ...
    if (pParent == NULL)
    {
      mpRoot = apItem ;
    }
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
BOOL DBProductViewItemList::CommitItems(ROWSETLib::IMTSQLRowsetPtr &arpRowset)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  ROWSETLib::IMTSQLRowsetPtr rowset(arpRowset) ;

  // if we're not initialized ... exit ...
  if (mIsInitialized == FALSE)
  {
    SetError(DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE, 
      "DBProductViewItemList::CommitItems");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  else
  {
    try
    {
      // add the compound ...
      bRetCode = AddCompound (arpRowset, NULL, mpRoot) ;
    }
    catch (_com_error e)
    {
      bRetCode = FALSE ;

      SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "DBProductViewItemList::CommitItems") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs(LOG_ERROR, "CommitItems() failed. Error = %s", (char*)e.Description()) ; 
    }
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
BOOL DBProductViewItemList::AddCompound (ROWSETLib::IMTSQLRowsetPtr & arpRowset, 
                                         DBProductViewItem *apParentItem,
                                         DBProductViewItem *apItem)
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // add the item to the database ...
  ASSERT (apItem) ;
  bRetCode = AddItemToDB (arpRowset, apParentItem, apItem) ;
  if (bRetCode == FALSE)
  {
    mLogger->LogVarArgs (LOG_ERROR, "Unable to add view item with id = %s",
      ascii(apItem->GetUID()).c_str()) ;
    return bRetCode ;
  }

  // iterate through the children for the item ...
  for (DBChildItemCollIter Iter = apItem->GetChildList().begin(); 
			 Iter !=  apItem->GetChildList().end(); 
			 Iter++)
  {
    // find the item in the list ...
    DBProductViewItemCollIter PVIIter = mPVIColl.find (*Iter) ;
    if (PVIIter == mPVIColl.end())
    {
      SetError (DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
        "DBProductViewItemList::AddCompound", 
        "AddCompound() failed. Unable to find item.") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
		DBProductViewItem *pChildItem = PVIIter->second;
    // call addcompound to add the item ...
    bRetCode = AddCompound (arpRowset, apItem, pChildItem) ;
    if (bRetCode == FALSE)
    {
      mLogger->LogVarArgs (LOG_ERROR, "Unable to add child view item with id = %s",
        ascii(pChildItem->GetUID()).c_str()) ;
      return bRetCode ;
    }
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
BOOL DBProductViewItemList::AddItemToDB (ROWSETLib::IMTSQLRowsetPtr & arpRowset,
                                         DBProductViewItem *apParentItem,
                                         DBProductViewItem *apItem)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  int nSessionID ;
  std::wstring wstrTableName ;
  DBViewPropertyCollection *pPropColl=NULL ;
///  DBAccountUsageInfo acctUsageInfo ;

  // set the parent session id ...
  if (apParentItem != NULL)
  {
    apItem->SetParentSessionID (apParentItem->GetSessionID()) ;
  }
  // get the parameters for the stored procedure ...
  apItem->ExecAccountUsageStoredProcAndGetID(arpRowset, 
    mIntervalID, nSessionID) ;

  // set the session id ...
  apItem->SetSessionID (nSessionID) ;
  
  // iterate thru the views of the view item ...
	for (DBViewPropCollIter Iter = apItem->GetViewPropertyMap().begin();
			 Iter != apItem->GetViewPropertyMap().end() && (bRetCode == TRUE);
			 Iter++)
  {
    // get the view property collection ...
    pPropColl = Iter->second ;
    
    // get the table name ...
    wstrTableName = pPropColl->GetTableName() ;

    // get the data to insert to the product view for this item ...
    bRetCode = apItem->ExecuteInsertProductViewData (arpRowset, 
      wstrTableName, pPropColl) ;
  }

  return bRetCode ;
}

#endif // deadcode ( deprecated obsolete dead legacy )
