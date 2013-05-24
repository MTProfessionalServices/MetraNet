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

#ifndef _MTUsageInterval_h_
#define _MTUsageInterval_h_

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

// forward declarations 
struct IMTQueryAdapter ;

class MTUsageInterval : public virtual ObjectWithError, public DBAccess
{
public:
  // @cmember Constructor
  DLL_EXPORT  MTUsageInterval();
  // @cmember Destructor
  virtual DLL_EXPORT ~MTUsageInterval();
  
  // @cmember Initialize the MTUsageInterval object
  DLL_EXPORT BOOL Init (BSTR apStartDate, BSTR apEndDate);
  // @cmember Add an account to the usage interval 
  DLL_EXPORT BOOL AddAccount (const long &arAcctID) ;
  // @cmember Check to see if the usage interval exists 
  DLL_EXPORT BOOL Exists(BOOL &arExists) ;
  // @cmember Check to see if the account exists in the usage interval
  DLL_EXPORT BOOL AccountExists(const long &arAccountID, BOOL &arExists) ;
  // @cmember Check to see if the usage interval is expired 
  DLL_EXPORT BOOL Expired (BSTR apDate, BOOL &arExpired) ;
  // @cmember Create a new usage interval
  DLL_EXPORT BOOL Create();
    
private:
  // @cmember Initialize the MTUsageInterval object
  BOOL Init ();
  // Copy Constructor
  MTUsageInterval (const MTUsageInterval& C);	
  // Assignment operator
  const MTUsageInterval& MTUsageInterval::operator=(const MTUsageInterval& rhs);
  
#if 1
  // @cmember Create the query to insert into the usage interval
  wstring CreateInsertUsageIntervalQuery (const wchar_t *apStartDate, 
																					const wchar_t *apEndDate) ;
#endif
  // @cmember Create the query to insert to the account usage interval
  wstring CreateInsertToAccountUsageIntervalQuery (const long &arAcctID, 
																									 const long &arIntervalID) ;
  // @cmember Create the query to find the usage interval
  wstring CreateFindUsageIntervalQuery (const wchar_t *apStartDate, 
																				const wchar_t *apEndDate) ;
  // @cmember Create the query to find the account in the usage interval
  wstring CreateFindAccountUsageIntervalQuery (const long &arAccountID,
																							 const long &arIntervalID) ;
  
  NTLogger mLogger ;
  // @cmember the query adapter 
  IMTQueryAdapter *     mpQueryAdapter ;
  // @cmember the initialized flag
  BOOL                  mInitialized ;
  // @cmember the interval id
  long                  mIntervalID ;
  // @cmember the start date
  _bstr_t               mStartDate ;
  // @cmember the end date
  _bstr_t               mEndDate ;
  // @cmember the interval length
  int                   mIntervalLength ;
  _bstr_t               mDBName ;
  _bstr_t               mServerName ;
  _bstr_t               mUserName ;
  _bstr_t               mPassword ;

};


#endif //_MTUsageInterval_h_

