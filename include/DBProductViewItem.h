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

#ifndef __DBProductViewItem_H
#define __DBProductViewItem_H

#include <DBAccess.h>
#include <DBSessionProperty.h>
#include <DBProductViewProperty.h>
#include <DBViewHierarchy.h>
#include <errobj.h>
#include <DBConstants.h>
#include <DBMiscUtils.h>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <map>
#include <vector>

// disable warning ...
#pragma warning( disable : 4251 4275)

// forward declarations 
class DBProductView ;
class DBViewHierarchy ;
class DBUsageCycleCollection ;
class DBViewPropertyCollection ;

// import the rowset tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
using namespace ROWSETLib;

// ----------------------------------------------------------------
// Object:   	ProductViewInfoItem
// Description:  	simple container of a ProductviewDef and a DBProductView
// ----------------------------------------------------------------

class ProductViewInfoItem {
public:
	ProductViewInfoItem() : mpDef(NULL), mPvItem(NULL) {}
	ProductViewInfoItem(CMSIXDefinition* apDef) : mpDef(apDef) {}
	DLL_EXPORT ~ProductViewInfoItem();

	CMSIXDefinition* mpDef;
	DBProductView* mPvItem;
};

typedef struct  {
	int aSqlID;
	int aOracleID;
} DbTypeInfoStruct;

typedef std::map<int,ProductViewInfoItem*> ProductViewIdMap;
typedef std::map<int,ProductViewInfoItem*>::iterator ProductViewIdMapIterator;


// typedefs ...
typedef std::map<std::wstring, DBSessionProperty *>	DBPropColl;
typedef std::map<std::wstring, DBSessionProperty *>::iterator	DBPropCollIter ;

typedef std::map<int, DBViewPropertyCollection *>	DBViewPropColl;
typedef std::map<int, DBViewPropertyCollection *>::iterator	DBViewPropCollIter ;

typedef std::vector<std::wstring> DBChildItemColl ;
typedef std::vector<std::wstring>::iterator DBChildItemCollIter ;

typedef std::vector<int> ViewIDColl ;
typedef std::vector<int>::iterator ViewIDCollIter ;

class DBPVIInitProperties
{
public:
  DLL_EXPORT DBPVIInitProperties();
  DLL_EXPORT ~DBPVIInitProperties() ;

  DLL_EXPORT void SetTxnTime(const time_t &arTxnTime)
  { mTxnTime = arTxnTime ; }
  DLL_EXPORT void SetAccountID(int arAccountID)
  { mAcctID = arAccountID ; }
  DLL_EXPORT void SetServiceID(int arSvcID)
  { mSvcID = arSvcID ; } 
  DLL_EXPORT void SetProductID(int arProdID)
  { mProdID = arProdID ; }
  DLL_EXPORT void SetIntervalID(int arIntervalID)
  { mIntervalID = arIntervalID ; }
	DLL_EXPORT void SetNameSpaceID(int arNameSpaceID)
	{ mNameSpaceID = arNameSpaceID; }
  DLL_EXPORT void SetPIInstanceID(int aInstanceID)
  { mPIInstanceID = aInstanceID; }
  DLL_EXPORT void SetPITemplateID(int aTemplateID)
  { mPITemplateID = aTemplateID; }
  DLL_EXPORT void SetPOID(int aPOID)
  { mPOID = aPOID; }

  DLL_EXPORT void SetSessionID(const unsigned char * const apSessionID) ;
  DLL_EXPORT void SetViewID(int arViewID, BOOL bPrimaryViewID=FALSE);
  DLL_EXPORT void SetParentSessionID(const unsigned char * const apSessionID) ;
	DLL_EXPORT void SetBatchID(const unsigned char * const apBatchID);

	DLL_EXPORT const unsigned char * GetSessionUID() const;
	DLL_EXPORT const unsigned char * GetParentSessionUID() const;
	DLL_EXPORT const unsigned char * GetBatchUID() const;


	DLL_EXPORT std::wstring GetSessionID() const 
  { return mSessionID ; }
  DLL_EXPORT const time_t GetTxnTime() const
  { return mTxnTime ; }
  DLL_EXPORT const int GetAccountID() const 
  { return mAcctID ; }
  DLL_EXPORT const int GetServiceID() const 
  { return mSvcID ; }
  DLL_EXPORT const int GetPrimaryViewID() const 
  { return mPrimaryViewID; }
  DLL_EXPORT ViewIDColl & GetViewIDCollection() 
  { return mViewColl ; }
  DLL_EXPORT std::wstring GetParentSessionID() const 
  { return mParentSessionID ; }
  DLL_EXPORT const int GetProductID() const 
  { return mProdID ; }
  DLL_EXPORT const int GetIntervalID() const 
  { return mIntervalID ; }
	DLL_EXPORT const int GetNameSpaceID() const
	{ return mNameSpaceID; }
  DLL_EXPORT int GetPIInstanceID() const 
  { return mPIInstanceID ; }
  DLL_EXPORT int GetPITemplateID() const 
  { return mPITemplateID ; }
  DLL_EXPORT int GetPOID() const 
  { return mPOID ; }

private:
  time_t  mTxnTime ;
  int     mAcctID ;
  int     mSvcID ;
  int     mProdID ;
  int     mIntervalID ;
  int     mPrimaryViewID ;
	int			mNameSpaceID;
	int			mPIInstanceID;
	int			mPITemplateID;
	int			mPOID;
	std::wstring mSessionID ;
	std::wstring mBatchID ;
	std::wstring mParentSessionID ;
  ViewIDColl mViewColl ;
  unsigned char mpSessionUID[DB_SESSIONID_SIZE] ;
  unsigned char mpParentSessionUID[DB_SESSIONID_SIZE] ;
  unsigned char mpBatchUID[DB_SESSIONID_SIZE] ;
};

inline DBPVIInitProperties::DBPVIInitProperties()
	: mTxnTime(0),
		mAcctID(-1),
		mSvcID(-1), 
    mProdID(-1),
		mIntervalID(-1),
		mNameSpaceID(-1),
		mPIInstanceID(-1),
		mPITemplateID(-1),
		mPOID(-1)
{
	memset(mpSessionUID, 0, DB_SESSIONID_SIZE);
	memset(mpParentSessionUID, 0, DB_SESSIONID_SIZE);
	memset(mpBatchUID, 0, DB_SESSIONID_SIZE);
} 

inline DBPVIInitProperties::~DBPVIInitProperties()
{ }

inline void DBPVIInitProperties::SetViewID(int arViewID, BOOL bPrimaryViewID)
{ 
  mViewColl.push_back(arViewID) ; 
  if (bPrimaryViewID == TRUE)
  {
    mPrimaryViewID = arViewID ;
  }
}

inline void DBPVIInitProperties::SetSessionID(const unsigned char * const apSessionID)
{
  // convert the session id to a string ...
  mSessionID = ConvertSessionIDToString (apSessionID) ;

  // make copies of the session id's
//  mpSessionUID = new unsigned char [DB_SESSIONID_SIZE] ;
//  ASSERT (mpSessionUID) ;
  memcpy (mpSessionUID, apSessionID, DB_SESSIONID_SIZE) ;

  return ;
}

inline void DBPVIInitProperties::SetParentSessionID(const unsigned char * const apParentSessionID)
{
  // convert the session id to a string ...
  if (apParentSessionID != NULL)
  {
    mParentSessionID = ConvertSessionIDToString (apParentSessionID) ;

    // make copies of the session id's
    memcpy (mpParentSessionUID, apParentSessionID, DB_SESSIONID_SIZE) ;
  }

  return ;
}

inline void DBPVIInitProperties::SetBatchID(const unsigned char * const apBatchID)
{
	if (apBatchID != NULL)
	{
		// convert the batch id to a string ...
		mBatchID = ConvertSessionIDToString (apBatchID);

		// make copies of the batch id's
		memcpy (mpBatchUID, apBatchID, DB_SESSIONID_SIZE) ;
	}
}

inline const unsigned char * DBPVIInitProperties::GetSessionUID() const 
{
	for (int i = 0; i < DB_SESSIONID_SIZE; i++)
		if (mpSessionUID[i] != 0)
			return mpSessionUID;							// it's a valid UID

	return NULL;
}

inline const unsigned char * DBPVIInitProperties::GetParentSessionUID() const 
{
	for (int i = 0; i < DB_SESSIONID_SIZE; i++)
		if (mpParentSessionUID[i] != 0)
			return mpParentSessionUID;							// it's a valid UID

	return NULL;
}

inline const unsigned char * DBPVIInitProperties::GetBatchUID() const 
{
	for (int i = 0; i < DB_SESSIONID_SIZE; i++)
		if (mpBatchUID[i] != 0)
			return mpBatchUID;							// it's a valid UID

	return NULL;

}



class DBViewPropertyCollection
{
public:
  DBViewPropertyCollection(DBView *pView) ;
  ~DBViewPropertyCollection() ;
  BOOL AddProperty (const std::wstring &arName, const _variant_t &arValue) ;
  std::wstring GetTableName() ;
  DBPropColl & GetViewPropertyCollection()
  { return mPropColl ; }
private:
  DBViewPropertyCollection() ;

  DBPropColl    mPropColl ;
  DBView *      mpView ;
	MTAutoInstance<MTAutoLoggerImpl<szDbObjectsTag,szDbObjectsDir> >	mLogger;  // @cmember the thread lock
} ;

// @class DBProductViewItem
class DBProductViewItem :
public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBProductViewItem(const int aDataBaseTypeID,const DbTypeInfoStruct& aDbTypeInfo) ;
  // @cmember Destructor
  DLL_EXPORT ~DBProductViewItem() ;

  // @cmember Initialize the DBProductViewItem object
  DLL_EXPORT BOOL Init(const DBPVIInitProperties &arInitProp,ProductViewIdMap& apProductViewIDMap) ;
  // @cmember Add a property to the DBProductViewItem
  DLL_EXPORT BOOL AddProperty (const std::wstring &arName, const _variant_t &arValue,
    int arViewID) ;
  DLL_EXPORT BOOL AddReservedProperty (const std::wstring &arName, const _variant_t &arValue) ;
  // @cmember Commit the item to the database 
  DLL_EXPORT BOOL CommitItem(ROWSETLib::IMTSQLRowsetPtr &arpRowset) ;
  DLL_EXPORT DBViewPropColl & GetViewPropertyMap() 
  { return mViewPropMap; }
  // @cmember Get the account usage query
  DLL_EXPORT BOOL ExecAccountUsageStoredProcAndGetID(ROWSETLib::IMTSQLRowsetPtr & arpRowset, 
    const long &arIntervalID, int &arSessionID) ;
  // @cmember Get the product view query
  DLL_EXPORT BOOL ExecuteInsertProductViewData(ROWSETLib::IMTSQLRowsetPtr & arpRowset,
	  const std::wstring &arTableName,
    DBViewPropertyCollection *pPropColl) ;
  // @cmember Get the session id
  DLL_EXPORT int GetSessionID () const ;
  // @cmember Get the view id 
  DLL_EXPORT int GetViewID() const ;

  // @cmember Get the uid
  DLL_EXPORT std::wstring GetUID() const ;
  // @cmember Get the parent uid 
  DLL_EXPORT std::wstring GetParentUID() const ;

  // @cmember Set the parent item
  DLL_EXPORT void SetParentItem(const DBProductViewItem *apItem) ;
  // @cmember Add a child item to the parent
  DLL_EXPORT void AddChildItem (const DBProductViewItem *apItem) ;
  // @cmember Set the session id 
  DLL_EXPORT void SetSessionID(int arSessionID) ;
  // @cmember Set the parent session id 
  DLL_EXPORT void SetParentSessionID(int arSessionID) ;
  // @cmember Get the child list
  DLL_EXPORT DBChildItemColl& GetChildList() ;
// @access Private:
private:
  // @cmember Tear down the allocate memory
  void TearDown() ;
  // @cmember 
  BOOL CreateAndExecuteInsertToProductViewQuery(ROWSETLib::IMTSQLRowsetPtr &arpRowset,
	  const std::wstring &arTableName, int arID, 
    DBViewPropertyCollection *pPropColl) ;

  // @cmember
  BOOL ExecAccountUsageStoredProcedure
    (ROWSETLib::IMTSQLRowsetPtr &arpRowset);

  BOOL ExecAccountUsageParentIDStoredProcedure
    (ROWSETLib::IMTSQLRowsetPtr &arpRowset);

  BOOL ExecAccountUsageParentUIDStoredProcedure
    (ROWSETLib::IMTSQLRowsetPtr &arpRowset) ;

	BOOL AccountUsageSprocInit(const wchar_t * apSproc,
														 ROWSETLib::IMTSQLRowsetPtr aRowset);

  // @cmember the initialize flag
  BOOL                    mIsInitialized ;
  // @cmember the pointer to the usage cycle collection
  DBUsageCycleCollection *mpUsageCycle ;
  // @cmember the view id 
  int                     mViewID ;
  // @cmember the parent session id ...
  int                     mParentID ;
  // @cmember the database session id
  int                     mID ;
  // @cmember the amount 
  _variant_t              mAmount ;
  // @cmember the currency
  _variant_t              mCurrency ;

	DBPVIInitProperties mAccountUsageProps;

#if 0
  // @cmember the transaction time
  time_t                  mTxnTime ;
  // @cmember the account id
  int                     mAcctID ;
  // @cmember the service id
  int                     mSvcID ;
  // @cmember the product id
  int                     mProdID ;
  // @cmember the interval id 
  int                     mIntervalID ;
	// TODO: primary view ID?
	// TODO: namespace ID?
	// priceable item instance ID
	int										  mPIInstanceID;
	// priceable item type ID
	int										  mPITemplateID;
	// product offering ID
	int										  mPOID;
  // @cmember the session ID
	std::wstring               mSessionID ;
	std::wstring							  mBatchID;
  // @cmember the parent session ID
	std::wstring               mParentSessionID ;
	// TODO: mViewColl
  unsigned char *         mpSessionUID ;
  unsigned char *         mpParentSessionUID ;
  unsigned char *         mpBatchUID ;
#endif

  _variant_t              mTaxFederal ;
  _variant_t              mTaxState ;
  _variant_t              mTaxCounty ;
  _variant_t              mTaxLocal ;
  _variant_t              mTaxOther ;

  DBViewPropColl          mViewPropMap ;
  // @cmember the child item list
  DBChildItemColl         mChildList ;
  // @cmember the parent item 
  const DBProductViewItem *     mpParentItem ;
  // @cmember the query adapter 
  int							mDbTypeID;
	DbTypeInfoStruct mDbTypeInfo;

  // @cmember the logging object
	MTAutoInstance<MTAutoLoggerImpl<szDbObjectsTag,szDbObjectsDir> >	mLogger;  // @cmember the thread lock

} ;

//
//	@mfunc
//	Get the session id
//  @rdesc 
//  Return the mID data member
//
inline int DBProductViewItem::GetSessionID() const 
{
  return mID ;
}

//
//	@mfunc
//	Set the session id
//  @rdesc 
//  No return value
//
inline void DBProductViewItem::SetSessionID(int arSessionID)
{
  mID = arSessionID ;
}

//
//	@mfunc
//	Set the parent session id
//  @rdesc 
//  No return value
//
inline void DBProductViewItem::SetParentSessionID(int arSessionID)
{
  mParentID = arSessionID ;
}

//
//	@mfunc
//	Get the child list
//  @rdesc 
//  The child list
//
inline DBChildItemColl& DBProductViewItem::GetChildList()
{
  return mChildList ;
}


//
//	@mfunc
//	Get the session id
//  @rdesc 
//  Return the mID data member
//
inline std::wstring DBProductViewItem::GetUID() const
{
  return (mAccountUsageProps.GetSessionID()) ;
}

//
//	@mfunc
//	Get the session id
//  @rdesc 
//  Return the mID data member
//
inline std::wstring DBProductViewItem::GetParentUID() const
{
  return (mAccountUsageProps.GetParentSessionID()) ;
}


//
//	@mfunc
//	Get the session id
//  @rdesc 
//  Return the mID data member
//
inline void DBProductViewItem::SetParentItem(const DBProductViewItem *apItem)
{
  mpParentItem = apItem ;
}

//
//	@mfunc
//	Get the session id
//  @rdesc 
//  Return the mID data member
//
inline void DBProductViewItem::AddChildItem (const DBProductViewItem *apItem)
{
  mChildList.push_back(apItem->GetUID()) ;
}

// disable warning ...
#pragma warning( default : 4251 4275 )


#endif // __DBProductViewItem_H
