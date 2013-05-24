/**************************************************************************
 * @doc DBProductViewItem
 * 
 * @module  Encapsulation for Database Sessions |
 * 
 * This class encapsulates the insertion or removal of Sessions from the 
 * database. All access to Session should be done through this class.
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

#ifndef __DBProductViewItemList_H
#define __DBProductViewItemList_H

#include <DBAccess.h>
#include <DBSessionProperty.h>
#include <errobj.h>
#include <string>
#include <map>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <DBProductViewItem.h>

// disable warning ...
#pragma warning( disable : 4251 4275)

// import the rowset tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
using namespace ROWSETLib ;

// forward declaration
class DBUsageCycleCollection ;

// typedefs ...
typedef std::map<std::wstring, DBProductViewItem *>	DBProductViewItemColl;
typedef std::map<std::wstring, DBProductViewItem *>::iterator	DBProductViewItemCollIter;

// @class DBProductViewItem
class DBProductViewItemList :
public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBProductViewItemList() ;
  // @cmember Destructor
  DLL_EXPORT ~DBProductViewItemList() ;

  // @cmember Initialize the DBProductViewItem object
  DLL_EXPORT BOOL Init(const time_t &arTxnTime, const int &arAcctID) ;
  DLL_EXPORT BOOL Init(const DBPVIInitProperties &arInitProp) ;

  // @cmember Add the item to the list
  DLL_EXPORT BOOL AddItem(DBProductViewItem * apItem) ;
  // @cmember Commit the item to the database 
  DLL_EXPORT BOOL CommitItems(ROWSETLib::IMTSQLRowsetPtr &arpRowset) ;

// @access Private:
private:
  // @cmember add the item to the database
  BOOL AddItemToDB(ROWSETLib::IMTSQLRowsetPtr &arpRowset, DBProductViewItem *apParentItem,
    DBProductViewItem *apItem) ;
  // @cmember add the compound to the database
  BOOL AddCompound(ROWSETLib::IMTSQLRowsetPtr &arpRowset, DBProductViewItem *apParentItem,
    DBProductViewItem *apItem) ;
  // @cmember Tear down the allocate memory
  void TearDown() ;

  // @cmember the initialize flag
  BOOL                    mIsInitialized ;
  // @cmember the interval id 
  int                     mIntervalID ;
  int                     mAcctID ;
  // @cmember the loggin object 
	MTAutoInstance<MTAutoLoggerImpl<szDbObjectsTag,szDbObjectsDir> >	mLogger;  // @cmember the thread lock
  // @cmember the product view item collection
  DBProductViewItemColl   mPVIColl ;
  // @cmember the txn time 
  time_t                  mTxnTime ;
  // @cmember the pointer to the usage cycle collection
  DBUsageCycleCollection *mpUsageCycle ;
  // @cmember the root of the list
  DBProductViewItem       *mpRoot ;
} ;


// disable warning ...
#pragma warning( default : 4251 4275 )


#endif // __DBProductViewItem_H
