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

#ifndef __DBViewHierarchy_H
#define __DBViewHierarchy_H

#include <NTThreadLock.h>

#include <errobj.h>

#include <string>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <ConfigChange.h>
#include <CodeLookup.h>
#include <MTSingleton.h>
#include <vector>
#include <ProductViewCollection.h>
#include <MTDataAnalysisViewCollection.h>
#include <map>
#include <set>
#include <autoptr.h>

#import <RCD.tlb>
#import <MTConfigLib.tlb>
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

// forward declarations
class DBRowset;
class DBSummaryView;
class DBProductView;
class DBDiscountView;
class DBDataAnalysisView;
class DBViewHierarchy;

// definitions
const char * const PRESSVR_CONFIGDIR = "\\PresServer" ;
const char * const VIEW_HIERARCHY_FILE = "view_hierarchy.xml" ;

// disnable warning ...
#pragma warning( disable : 4275 4251)

class DBView ;

// typedefs ...


typedef std::map<int, DBView *>	DBViewColl ;
typedef std::map<int, DBView *>::iterator	DBViewCollIter;

typedef std::set<int> DBViewIDColl ;
typedef std::set<int>::iterator DBViewIDCollIter ;




class MTPCViewHierarchy;

// @class DBView
class DBView
: public virtual ObjectWithError
{
	friend MTPCViewHierarchy;
  // @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT DBView() ;
  // @cmember Destructor
  DLL_EXPORT virtual ~DBView() ;
  
  // @cmember Get the display items 
  DLL_EXPORT virtual BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
    const std::wstring &arLangCode, DBSQLRowset * & arpRowset,long instanceID = 0) = 0 ;
  DLL_EXPORT virtual BOOL GetDisplayItems (const int &arAcctID, const int &arIntervalID,
    const std::wstring &arLangCode, const std::wstring &arExtension, DBSQLRowset * & arpRowset,long instanceID = 0) = 0;
  // @cmember Summarize the contents of this view
  DLL_EXPORT virtual BOOL Summarize(const int &arAcctID, const int &arIntervalID,
    DBSQLRowset * & arpRowset, const std::wstring &arExtension) = 0 ;
  DLL_EXPORT virtual BOOL Summarize(const int &arAcctID, const int &arIntervalID,
    DBSQLRowset * & arpRowset) = 0 ;

  // @cmember Initialize the view
  DLL_EXPORT BOOL Init (const std::wstring &arViewType, const int &arViewID, 
    const std::wstring &arName, const int &arDescriptionID) ;
  // @cmember Get the type of view
  DLL_EXPORT std::wstring GetViewType() const ;
  // @cmember Get the view id 
  DLL_EXPORT int GetViewID() const ;
  // @cmember Get the view name
  DLL_EXPORT std::wstring GetViewName() const ;
  // @cmember Get the view description
  DLL_EXPORT int GetViewDescriptionID() const ;
  // @cmember Add a child view id to the list
  DLL_EXPORT void AddChildViewID (const int &arViewID) ;
  // @cmember Add a parent view id to the list
  DLL_EXPORT void AddParentViewID (const int &arViewID) ;
  // @cmember Check to see if the view id is a parent of the view
  DLL_EXPORT BOOL IsParentViewID (const int &arViewID) ;
  // @cmember Load the view (if it is a product) and its product children into the database
  DLL_EXPORT BOOL LoadProducts (DBViewHierarchy* apHierarchy, DBView *apParent) ;
  
  // @access Protected:
protected:
  // @cmember Initialize the non sql rowset 
  BOOL InitializeInMemRowset (DBSQLRowset * & arpRowset) ;
  // @cmember Initialize the non sql rowset for a summary
  BOOL InitializeInMemRowsetForSummary (DBSQLRowset * & arpRowset, 
    const long &arAcctID, const long &arIntervalID) ;
  // @cmember Insert the rowset into the non sql rowset
  BOOL InsertIntoInMemRowset (DBSQLRowset * & arpRowset, 
    DBSQLRowset * apNewRowset) ;
  static BOOL InsertCurrentRowIntoInMemRowset (long aIntervalID,long aAccountID,DBSQLRowset& arpRowset, 
    ROWSETLib::IMTSQLRowsetPtr apNewRowset) ;


  // @cmember Summarize the rowset into the non sql rowset
  BOOL SummarizeIntoInMemRowset (DBSQLRowset * & arpRowset, 
    DBSQLRowset * apNewRowset) ;
  BOOL InsertDefaultRowIntoInMemRowset (DBSQLRowset * & arpRowset, const int &arViewID,
    const std::wstring &arViewName, const int &arDescID, const std::wstring &arViewType,
    const int &arAcctID, const int &arIntervalID) ;
  
  // @cmember List of view ids for the children
  DBViewIDColl    mChildViewList ;
  // @cmember List of parent view ids 
  DBViewIDColl    mParentViewList ;
  // @cmember the view type 
  std::wstring    mType ;
  // @cmember the view id
  int             mID ;
  // @cmember the view name
  std::wstring    mName ;
  // @cmember the view description
  int             mDescriptionID ;
  
  // @access Private:
protected:
  // @cmember the logging object 
	MTAutoInstance<MTAutoLoggerImpl<szDbObjectsTag,szDbObjectsDir> >	mLogger; 
  
} ;


#define CONVERT_INSTANCE_ID(a) (a > 0x40000000 ? a - 0x40000000 : a)

//////////////////////////////////////////////////////////////////////////////
// @class ViewHierarchyBase
//////////////////////////////////////////////////////////////////////////////

class ViewHierarchyBase :  public virtual ObjectWithError
{
public:
	virtual BOOL FindView (const int aViewID, DBView * & arpView) = 0;
	ViewHierarchyBase() {}
	virtual ~ViewHierarchyBase() {}
protected:
	// @cmember the logging object 
	MTAutoInstance<MTAutoLoggerImpl<szDbObjectsTag,szDbObjectsDir> >	mLogger;  // @cmember the thread lock

};

//////////////////////////////////////////////////////////////////////////////
// @class MTPCViewHierarchy
//////////////////////////////////////////////////////////////////////////////
typedef std::map<int,DBView*> PCAccountViewMap;

class MTPCHierarchyColl;

class MTPCViewHierarchy :
  public virtual ObjectWithError,
	public ViewHierarchyBase
{
public:
	MTPCViewHierarchy() : mPoSummaryRows(false),mIntervalID(0),mAccountID(0) {}
	~MTPCViewHierarchy();

	DLL_EXPORT BOOL Initialize(const long lAccountID,const long aIntervalID,const wchar_t* LanguageCode);
	DLL_EXPORT BOOL FindView (const int aViewID, DBView * & arpView);
	DLL_EXPORT BOOL PopulateInMemRowset(DBSQLRowset& arRowset);
protected:
	PCAccountViewMap mAccountViewCol;
	bool mPoSummaryRows;
	ROWSETLib::IMTSQLRowsetPtr mNoPoSummaryRowset;
	long mAccountID;
	long mIntervalID;
};

//////////////////////////////////////////////////////////////////////////////
//MTPCHierarchyColl
//////////////////////////////////////////////////////////////////////////////


typedef std::map< std::pair<long,long>,MTautoptr<MTPCViewHierarchy> > PCAccViewMap;
typedef std::map< long,long> PiToViewIDMap;
class DBViewHierarchy;

// this is a singleton class.  We can not use MTSingleton because of issues
// with static variables being declared in multiple Dlls.
class MTPCHierarchyColl 
{

public:
	friend  MTSingleton<MTPCHierarchyColl>;

	DLL_EXPORT MTautoptr<MTPCViewHierarchy> GetAccHierarchy(const long accountID,const long intervalID,const wchar_t* languageCode);
	DLL_EXPORT void ClearEntry(long accountID,long intervalID);
	DLL_EXPORT BOOL TranslateID(const long aViewID,long& aNewViewID);
	DLL_EXPORT void AddInstanceIdMapping(const long instanceID,const long viewID);

  // @cmember Destructor
	// We can't use the base class method since it must live in a single DLL!!
	DLL_EXPORT static MTPCHierarchyColl* GetInstance(); 
	DLL_EXPORT static void ReleaseInstance();


private:
	BOOL Init();
  MTPCHierarchyColl() {}
  virtual ~MTPCHierarchyColl();

protected:
	static NTThreadLock mLock;
	static MTPCHierarchyColl* mpsInstance;
	static DWORD msNumRefs;
	static PCAccViewMap mAccountMap;
	static DBViewHierarchy* pXmlViewHierarchy;
	static PiToViewIDMap mPiToViewIDMap;
};



//////////////////////////////////////////////////////////////////////////////
// @class DBViewCollection
//////////////////////////////////////////////////////////////////////////////

	class DBViewHierarchy : 
	public ViewHierarchyBase,
  public ConfigChangeObserver,
	private MTSingleton<DBViewHierarchy>
{
  // @access Public:
public:
  // @cmember Get a pointer to the DBServiceCollection.
  DLL_EXPORT static DBViewHierarchy * GetInstance();
  // @cmember Release the pointer to the DBServiceCollection
  DLL_EXPORT static void ReleaseInstance() ;
  
  DLL_EXPORT virtual void ConfigurationHasChanged() ;

  DLL_EXPORT DBViewColl& GetViewCollection() 
	{ 
		ASSERT(mViewColl);
		return *mViewColl; 
	}
	DLL_EXPORT BOOL FindView (const int aViewID, DBView * & arpView);
	CProductViewCollection& GetPVColl() { return mPVColl; }

	// @access Protected:
protected:  
	void TearDown(bool bDeleteCollecctionObj = true);


  // @cmember Initialize the DBViewHierarchy object
  BOOL Init();

  // @cmember Constructor.
  DBViewHierarchy() ;
  // @cmember Destructor
  virtual ~DBViewHierarchy() ;
  // @access Private:
private:

	// helper functions for init
	RCDLib::IMTRcdFileListPtr GetFileListFromRcd();
	
	BOOL InitSummaryView(long aID,
											 const std::wstring& wstrViewName,
											 MTConfigLib::IMTConfigPropSetPtr& aProp,
											 std::vector<DBView *>& aList,
											 DBViewColl& aCol);

	BOOL InitProductView(long aID,
											 const std::wstring& wstrViewName,
											 MTConfigLib::IMTConfigPropSetPtr& aProp,
											 std::vector<DBView *>& aList,
											 CProductViewCollection& pvColl,
											 DBViewColl& aCol);


	BOOL InitDiscountView(long aID,
											 const std::wstring& wstrViewName,
											 MTConfigLib::IMTConfigPropSetPtr& aProp,
											 std::vector<DBView *>& aList,
											 CProductViewCollection& PVColl,
											 DBViewColl& aCol);

	BOOL InitDataAnalysisView(long aID,
											 const std::wstring& wstrViewName,
											 MTConfigLib::IMTConfigPropSetPtr& aProp,
											 std::vector<DBView *>& aList,
											 MTDataAnalysisViewColl& DAViewColl,
											 DBViewColl& aCol);

	BOOL ReadAllConfigFiles(CCodeLookup* apCodeLookup,
												 DBDataAnalysisView *pDBDataAnalysisView,
												 MTDataAnalysisViewColl& DAViewColl,
												 CProductViewCollection& PVColl,
												 std::vector<DBView *>& dbViewList);


	inline void InitRcd();



  // @cmember the pointer to the DBViewHierarchy object.
  static DBViewHierarchy *       mpsViews ;
  // @cmember the number of references to this collection
  static DWORD                    msNumRefs ;
	static NTThreadLock msLock;
	
	RCDLib::IMTRcdPtr mRCD;
	CProductViewCollection mPVColl;
  ConfigChangeObservable mObservable;
  BOOL            mObserverInitialized ;

	DBViewColl* mViewColl;
  // @cmember the threadlock 
  NTThreadLock  mCollLock ;
} ;

//
//	@mfunc
//	Add the view id to the child list
//  @rdesc 
//  No return value
//
inline void DBView::AddChildViewID (const int &arViewID)
{
  mChildViewList.insert(arViewID) ;
}

//
//	@mfunc
//	Add the view id to the parent list
//  @rdesc 
//  No return value
//
inline void DBView::AddParentViewID (const int &arViewID)
{
  mParentViewList.insert(arViewID) ;
}

//
//	@mfunc
//	Check to see if the view id is a parent of the view
//  @rdesc 
//  TRUE if the view id is a parent. Otherwise, FALSE is returned.
//
inline BOOL DBView::IsParentViewID(const int &arViewID)
{
  return mParentViewList.end() != mParentViewList.find(arViewID) ;
}

//
//	@mfunc
//	Get the view type. 
//  @rdesc 
//  The view type.
//
inline std::wstring DBView::GetViewType() const 
{
  return mType ;
}

//
//	@mfunc
//	Get the view description. 
//  @rdesc 
//  The view description.
//
inline int DBView::GetViewDescriptionID() const 
{
  return mDescriptionID ;
}

//
//	@mfunc
//	Get the view id. 
//  @rdesc 
//  The view id.
//
inline int DBView::GetViewID() const 
{
  return mID ;
}

//
//	@mfunc
//	Get the view name. 
//  @rdesc 
//  The view name.
//
inline std::wstring DBView::GetViewName() const 
{
  return mName ;
}

//
//	@mfunc
//	Initialize the view
//  @rdesc 
//  Returns TRUE
//
inline BOOL DBView::Init(const std::wstring &arViewType, const int &arViewID, 
    const std::wstring &arName, const int &arDescriptionID) 
{
  // initialize the type, id and name 
  mType = arViewType ;
  mID = arViewID ;
  mName = arName ;
  mDescriptionID = arDescriptionID ;
  
  return TRUE ;
}

// reenable warning ...
#pragma warning( default : 4275 4251)

#endif 
