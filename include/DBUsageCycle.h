/**************************************************************************
 * @doc DBUsageCycle
 * 
 * @module  Encapsulation of the usage cycle|
 * 
 * This class encapsulates the usage cycle.
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
 * @index | DBUsageCycle
 ***************************************************************************/

#ifndef __DBUsageCycle_H
#define __DBUsageCycle_H

#include <DBAccess.h>
#include <DBRowset.h>
#include <errobj.h>
#include <string>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <NTLogger.h>
#include <NTThreadLock.h>
#include <MTUtil.h>
#include <map>
#include <list>

// disable warning ...
#pragma warning( disable : 4251 4275)

// defines ...
const int MAX_CACHE_SIZE=50 ;

// forward declarations 
struct IMTQueryAdapter ;

// forward declaration 
class DBUsageInterval ;
class DBAcctUsageInterval ;
class DBIntervalIDDateEffective ;

// typedefs ...
typedef std::list<DBIntervalIDDateEffective *> DBIntervalIDColl;
typedef std::map<int, DBUsageInterval *> DBUsageIntervalColl;
typedef std::map<int, DBAcctUsageInterval *> DBAcctUsageIntervalColl;

class DBUsageInterval
{
public:
  DLL_EXPORT DBUsageInterval (const int &arIntervalID, const time_t &arStartDate,
    const time_t &arEndDate,const int &arCycleID,
    const BOOL &arOpenStatus) ;
  DLL_EXPORT ~DBUsageInterval () {} ;
  DLL_EXPORT int GetCycleID() const 
  { return mCycleID ; } ;
  DLL_EXPORT time_t GetEndDate() const 
  { return mEndDate ; } ;
  DLL_EXPORT time_t GetStartDate() const 
  { return mStartDate ; } ;
  DLL_EXPORT BOOL IsTxnInInterval (const time_t &txnTime) 
  { return ((mStartDate <= txnTime && mEndDate >= txnTime) && mOpenStatus) ; } ;
  DLL_EXPORT BOOL IsCurrentInterval (const time_t &currTime)
  { return (mStartDate <= currTime && mEndDate >= currTime) ; } ;
private:
  DBUsageInterval() ;

  int         mIntervalID ;
  int         mCycleID ;
  time_t      mStartDate ;
  time_t      mEndDate ;
  BOOL        mOpenStatus ;
} ;

class DBIntervalIDDateEffective
{
public:
  DLL_EXPORT DBIntervalIDDateEffective(): mDateEffective(0), mIntervalID(0) {} ;
  DLL_EXPORT ~DBIntervalIDDateEffective() {} ;

  DLL_EXPORT void Init (const int &arIntervalID, const _variant_t &arValue) ;
  DLL_EXPORT BOOL IsEffective (const time_t &arCurrentTime) 
  { return (arCurrentTime > mDateEffective) ; } ;
  DLL_EXPORT long GetIntervalID () const
  { return mIntervalID ; } ;
private:
  long    mIntervalID ;
  time_t  mDateEffective ;
} ;

inline void DBIntervalIDDateEffective::Init (const int &arIntervalID, const _variant_t &arValue)
{
  // assign interval id ...
  mIntervalID = arIntervalID ;

  // assign date ...
  if (arValue.vt != VT_NULL)
  {
    TimetFromOleDate (&mDateEffective, arValue.date) ;
  }
}

class DBAcctUsageInterval
{
public:
  DLL_EXPORT DBAcctUsageInterval () : mNumHits(0), mInUse(FALSE) {};
  DLL_EXPORT ~DBAcctUsageInterval () ; 

  DLL_EXPORT void Add (const int &arIntervalID, const _variant_t &arValue) ;
  DLL_EXPORT DBIntervalIDColl& GetIntervalIDCollection()
  { return (mIntervalIDColl) ;} ;
  DLL_EXPORT int GetNumHits() const
  { return mNumHits ; }
  DLL_EXPORT void AddHit()
  { mNumHits++ ; }
  DLL_EXPORT void SetInUse()
  { mInUse = TRUE ; }
  DLL_EXPORT void ClearInUse()
  { mInUse = FALSE ; }
  DLL_EXPORT BOOL IsInUse() const
  { return mInUse ; }

private:
  DBIntervalIDColl        mIntervalIDColl ;
  int                     mNumHits ;
  BOOL                    mInUse ;
} ;

inline DBAcctUsageInterval::~DBAcctUsageInterval()
{
  DBIntervalIDColl::iterator it;
  for (it = mIntervalIDColl.begin(); it != mIntervalIDColl.end(); it++)
    delete *it;
	
  mIntervalIDColl.clear(); 
} 

inline void DBAcctUsageInterval::Add (const int &arIntervalID, const _variant_t &arValue) 
{ 
  // allocate a new 
  DBIntervalIDDateEffective *pIntervalIDDateEffective = new DBIntervalIDDateEffective ;
  ASSERT (pIntervalIDDateEffective) ;

  // initialize it ...
  pIntervalIDDateEffective->Init (arIntervalID, arValue) ;

  // add it to the collection ...
  mIntervalIDColl.push_back(pIntervalIDDateEffective) ; 
}

// @class DBUsageCycle
class DBUsageCycleCollection :
  public DBAccess,
  public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Get a pointer to the DBUsageCycleCollection.
  DLL_EXPORT static DBUsageCycleCollection * GetInstance() ;
  // @cmember Release the pointer to the DBUsageCycleCollection
  DLL_EXPORT static void ReleaseInstance() ;
  // @cmember Get the interval id and the table suffix
  DLL_EXPORT BOOL GetIntervalAndTableSuffix (const int &arAcctID, 
    const time_t &arTxnTime, int &arIntervalID);
  // @cmember Get the table suffix by interval id 
  DLL_EXPORT BOOL GetIntervalStartAndEndDate (const int &arIntervalID, 
    DATE &arStartDate, DATE &arEndDate) ;
	BOOL GetIntervalFromCollection(const time_t &arTxnTime,DBAcctUsageInterval * const apAcctUsageInterval,int &arIntervalID);

// @access Protected:
protected:  
  // @cmember Initialize the DBServicesCollection object
  BOOL Init() ;
  // @cmember Constructor.
  DBUsageCycleCollection() ;
  // @cmember Destructor
	virtual ~DBUsageCycleCollection() ;
// @access Private:
private:
  void TearDown() ;

  BOOL GetUsageIntervalByID (const int &arIntervalID) ;
  // @cmember create the get open usage intervals query 
  std::wstring CreateGetUsageIntervalsQuery() ;
  // @cmember create the get account usage interval query 
  std::wstring CreateGetAccountUsageIntervalsQuery() ;
  // @cmember create the get account usage interval query 
  std::wstring CreateGetAccountUsageIntervalByAccountQuery(const int &arAcctID) ;
  // @cmember create the get usage interval by id query 
  std::wstring CreateGetUsageIntervalByIDQuery(const int &arIntervalID) ;

  // @cmember the pointer to the DBUsageCycleCollection object.
  static DBUsageCycleCollection * mpsUsageCycle ;
  // @cmember the number of references to this collection
  static DWORD                    msNumRefs ;
  // @cmember the threadlock 
  static NTThreadLock             msLock ;
  // @cmember the loggin object 
	MTAutoInstance<MTAutoLoggerImpl<szDbObjectsUsageTag,szDbObjectsDir> >	mLogger;  // @cmember the thread lock
  // @cmember the query adapter 
  IMTQueryAdapter *               mpQueryAdapter ;
  // @cmember the usage interval collection
  DBUsageIntervalColl             mUsageIntervalColl ;
  // @cmember the account to usage interval mapping
  DBAcctUsageIntervalColl         mAcctUsageIntervalColl ;
} ;

inline DBUsageInterval::DBUsageInterval(const int &arIntervalID, 
    const time_t &arStartDate, const time_t &arEndDate,
    const int &arCycleID, const BOOL &arOpenStatus)
: mIntervalID (arIntervalID), mStartDate(arStartDate), mEndDate(arEndDate),
mCycleID(arCycleID), mOpenStatus(arOpenStatus) 
{
}

// reenable warning ...
#pragma warning( default : 4251 4275)

#endif
