/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
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
 ***************************************************************************/

#ifndef _MTUsageCycle_h_
#define _MTUsageCycle_h_

#ifdef WIN32
// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
// NOTE: compiler complains because even though the class is
// dll exported, the map cannot be dll exported.  hence the 
// warning
#pragma warning( disable : 4251 )
#endif //  WIN32

//	All the includes
#include <errobj.h>
#include <DBAccess.h>
#include <NTLogger.h>
#include <MTUtil.h>
#include <list>

using std::list;

typedef list<long> IntervalColl;

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
// forward declarations 
struct IMTQueryAdapter ;
struct ICOMUsageCyclePropertyColl ;

class MTUsageCycle : public virtual ObjectWithError, public DBAccess
{
public:
  // @cmember Constructor
  DLL_EXPORT  MTUsageCycle();
  // @cmember Destructor
  virtual DLL_EXPORT ~MTUsageCycle();
  
  // @cmember Initialize the MTUsageCycle object
  DLL_EXPORT BOOL Init (const long &arCycleType, ICOMUsageCyclePropertyColl * apPropColl);
  // @cmember Add an account to the account to usage cycle mapping
  DLL_EXPORT BOOL AddAccount (const BSTR apStartDate, const BSTR apEndDate,
    const long &arAcctID, LPDISPATCH pRowset) ;
  // @cmember Update an account to the account to usage cycle mapping
  DLL_EXPORT BOOL UpdateAccount (const BSTR apStartDate, const BSTR apEndDate,
    const long &arAcctID, const _variant_t &arDate) ;
  // @cmember Create a usage interval for the usage cycle 
  DLL_EXPORT BOOL CreateInterval (const BSTR apStartDate, const BSTR apEndDate) ;
  DLL_EXPORT BOOL CreateInterval (const BSTR apStartDate, const BSTR apEndDate, 
    BOOL &arIntervalExists) ;
  DLL_EXPORT BOOL UpdateAccountToIntervalMapping() ;
      
private:
  // @cmember Initialize the MTUsageCycle object
  BOOL Init ();
  // Copy Constructor
  MTUsageCycle (const MTUsageCycle& C);	
  // Assignment operator
  const MTUsageCycle& MTUsageCycle::operator=(const MTUsageCycle& rhs);
  
  // @cmember Create the query to insert into the usage cycle
  wstring CreateInsertUsageCycleQuery (const long &arCycleType, 
																			 const long &arDayOfMonth,
																			 const BSTR aUsageCyclePeriodType) ;
  // @cmember Create the query to insert to the account usage cycle
  wstring CreateInsertToAccountUsageCycleQuery (const long &arAcctID, 
																								const long &arCycleID) ;
  // @cmember Create the query to insert to the account usage cycle
  wstring CreateUpdateToAccountUsageCycleQuery (const long &arAcctID, 
																								const long &arCycleID) ;
  // @cmember Create the query to insert to the account usage cycle
  wstring CreateInsertToAccountUsageIntervalQuery (const long &arAcctID, 
																									 const long &arIntervalID) ;
  // @cmember Create the query to insert into the usage interval
  wstring CreateInsertUsageIntervalQuery (const wchar_t *apStartDate, 
																					const wchar_t *apEndDate, 
																					const long &arUsageCycleID) ;
  // @cmember Create the query to find the usage cycle
  wstring CreateFindUsageCycleQuery (const long &arCycleType,
																		 const wstring &arQueryExt) ;
  wstring CreateFindUsageIntervalQuery (const long &arCycleID) ;
	
  // @cmember Create the query to insert into the usage interval
  wstring CreateInsertUsageIntervalQuery (const wchar_t *apStartDate, 
																					const wchar_t *apEndDate) ;
  // @cmember Create the query to find the usage interval
  wstring CreateFindUsageIntervalQuery (const wchar_t *apStartDate, 
																				const wchar_t *apEndDate,
																				const long &arCycleID) ;
  wstring CreateFindAccountsForCycleQuery (const long &arCycleID) ;
  wstring CreateFindUsageIntervalByEndDateQuery (const long &arCycleID,
																								 const BSTR apIntervalEndDate) ;
  wstring CreateDeleteIntervalsFromAccUsageInterval (const long &arAcctID,
																										 const BSTR apIntervalEndDate) ;
  wstring CreateDeletePreviousUpdatesFromAccUsageInterval (const long &arAcctID) ;
  wstring CreateUpdateAcctToIntervalMapping (const long &arAcctID,
																						 const long &arIntervalID,
																						 const BSTR apIntervalEndDate)  ;

	wstring CreateUpdateAccountToIntervalMappingQuery(int aCycleID, int aIntervalID);



  BOOL CreateAndExecuteInsertToAccountUsageCycleQuery (const long &arAcctID, 
    const long &arCycleID, ROWSETLib::IMTSQLRowsetPtr &arRowset) ;
  BOOL CreateAndExecuteInsertToAccountUsageIntervalQuery (const long &arAcctID, 
    const long &arIntervalID, ROWSETLib::IMTSQLRowsetPtr &arRowset) ;

  NTLogger mLogger ;
  // @cmember the query adapter 
  IMTQueryAdapter *     mpQueryAdapter ;
	ICOMUsageCyclePropertyColl* mpUsageCyclePropCol;
  // @cmember the initialized flag
  BOOL                  mInitialized ;
  // @cmember the cycle type
  long                  mCycleType ;
  wstring             mColumnNames ;
  wstring             mColumnValues ;
  // @cmember the usage cycle id
  long                  mCycleID ;
  IntervalColl          mIntervalColl ;
};



#endif //_MTUsageCycle_h_

