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

#include <metra.h>
#include <mtprogids.h>
#include <mtparamnames.h>
#include <DBUsageCycle.h>
#include <DBConstants.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <MTUtil.h>
#include <UsageServerConstants.h>
#include <mttime.h>

// static definition ...
DBUsageCycleCollection * DBUsageCycleCollection::mpsUsageCycle = 0;
DWORD DBUsageCycleCollection::msNumRefs = 0 ;
NTThreadLock DBUsageCycleCollection::msLock ;

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

//
//	@mfunc
//	Constructor. Initialize the data members.
//  @rdesc 
//  No return value
//
DBUsageCycleCollection::DBUsageCycleCollection()
: mpQueryAdapter(NULL)
{
}

//
//	@mfunc
//	Destructor
//  @rdesc 
//  No return value
//
DBUsageCycleCollection::~DBUsageCycleCollection()
{
  // delete the allocated memory ...
  TearDown() ;

  // release the interface ptrs ...
  if (mpQueryAdapter != NULL)
  {
    mpQueryAdapter->Release() ;
    mpQueryAdapter = NULL ;
  }

  mpsUsageCycle = NULL ;	
}

void DBUsageCycleCollection::TearDown() 
{
  // delete all the allocate memory ...
  DBUsageIntervalColl::iterator it;
	for (it = mUsageIntervalColl.begin(); it != mUsageIntervalColl.end(); it++)
		delete it->second;

  DBAcctUsageIntervalColl::iterator auiIt;
	for (auiIt = mAcctUsageIntervalColl.begin(); auiIt != mAcctUsageIntervalColl.end(); auiIt++)
		delete auiIt->second;

  mUsageIntervalColl.clear();
  mAcctUsageIntervalColl.clear();
}

//
//	@mfunc
//	Initialize the DBUsageCycleCollection. Read in all the usage intervals
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is saved in the mLastError data member.
//
BOOL DBUsageCycleCollection::Init()
{
  BOOL bRetCode=TRUE ;  
  BOOL bFound=TRUE ;
  int nIntervalID, nCycleID ;
  _variant_t vtStartDate, vtEndDate ;
  _variant_t vtValue ;
  DBUsageInterval *pUsageInterval=NULL ;
  DBAcctUsageInterval *pAcctUsageInterval=NULL ;
  std::wstring wstrStatus ;
  std::wstring wstrCmd ;
  DBSQLRowset myRowset ;
  int nNumAcctsCached=0 ;
  BOOL bOpenStatus=FALSE ;

  // if the query adapter isnt initialized ...
  if (mpQueryAdapter == NULL)
  {
    try
    {
      // create the queryadapter ...
      IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
      
      // initialize the queryadapter ...
      _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
      queryAdapter->Init(configPath) ;
      
      // extract and detach the interface ptr ...
      mpQueryAdapter = queryAdapter.Detach() ;

      // initialize the database access layer with the db config info read ...
      bRetCode = DBAccess::Init((wchar_t*)configPath) ;
      if (bRetCode == FALSE)
      {
        SetError (DBAccess::GetLastError(), "Init() failed. Unable to initialize dbaccess layer");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        bRetCode = FALSE ;
      }
    }
    catch (_com_error e)
    {
      //SetError(e) ;
      SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBUsageCycle::Init", 
        "Unable to initialize query adapter");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Init() failed. Error Description = %s", (char*)e.Description()) ;
      bRetCode = FALSE ;
    }
  }
  // if we havent hit an error yet ...
  if (bRetCode == TRUE) 
  {
    // create the query to get the usage intervals that havent been closed ...
    wstrCmd = CreateGetUsageIntervalsQuery() ;
    
    // execute a command to get info from the database ...
    bRetCode = DBAccess::Execute (wstrCmd, myRowset) ;
    if (bRetCode == FALSE)
    {
      SetError (DBAccess::GetLastError(),
        "Init() failed. Unable to execute database query.") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {
      // if we dont have any rows ...
      if (myRowset.GetRecordCount() == 0)
      {
        SetError(DB_ERR_NO_ROWS, ERROR_MODULE, ERROR_LINE, 
          "DBUsageCycleCollection::Init", "Unable to get usage intervals");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        bRetCode = FALSE ;
      }

      // iterate over all the records ...
      while (!myRowset.AtEOF() && bRetCode == TRUE)
      {
        // get the values ...
        myRowset.GetValue(_variant_t (DB_START_DATE), vtStartDate) ;
        myRowset.GetValue(_variant_t (DB_END_DATE), vtEndDate) ;
        myRowset.GetIntValue (_variant_t (DB_INTERVAL_ID), nIntervalID) ;
        myRowset.GetIntValue (_variant_t (DB_CYCLE_ID), nCycleID) ;
        myRowset.GetWCharValue (_variant_t (DB_STATUS), wstrStatus) ;

        // if the status is 'N' or 'O' ... set the status flag to true ...
        //if (((wstrStatus.compareTo (USAGE_INTERVAL_NEW, RWWString::ignoreCase)) == 0) ||
          //((wstrStatus.compareTo (USAGE_INTERVAL_OPEN, RWWString::ignoreCase)) == 0))
		if ((_wcsicmp(wstrStatus.c_str(), USAGE_INTERVAL_NEW) == 0) ||
			(_wcsicmp(wstrStatus.c_str(), USAGE_INTERVAL_OPEN) == 0))
        {
          bOpenStatus = TRUE ;
        }
        // otherwise, set the status flag to false ...
        else
        {
          bOpenStatus = FALSE ;
        }

        // convert the date's to time_t's ...
        time_t tStartDate, tEndDate ;

        TimetFromOleDate (&tStartDate, vtStartDate.date) ;
        TimetFromOleDate (&tEndDate, vtEndDate.date) ;

        // create a new UsageInterval object ...
        pUsageInterval = new DBUsageInterval (nIntervalID, tStartDate, 
          tEndDate, nCycleID, bOpenStatus) ;
        ASSERT (pUsageInterval) ;
        if (pUsageInterval == NULL)
        {
          SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, 
            "DBUsageCycleCollection::Init", "Unable to allocate memory");
          mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
          bRetCode = FALSE ;
        }
        else
        {
          // add the key/value pair into the map ...
          mUsageIntervalColl[nIntervalID] = pUsageInterval;
          pUsageInterval = NULL ;
        }
        // move to the next row ...
        bRetCode = myRowset.MoveNext() ;
      }
    }
  }
  // if we havent hit an error yet ...
  if (bRetCode == TRUE) 
  {
		// TODO: this code used to initialize the cache of accounts to usage intervals.
		// however, when using a database of many accounts, this take a long time to initialize.
		// The cache only holds 50 entries but this code will read at least one entry per account.
		// for now, the cache is not initialized.  eventually, this code should be removed.
#if 0
    // create the query to get the account to usage interval mapping ...
    wstrCmd = CreateGetAccountUsageIntervalsQuery() ;
    
    // execute a command to get info from the database ...
    bRetCode = DBAccess::Execute (wstrCmd, myRowset) ;
    if (bRetCode == FALSE)
    {
      SetError (DBAccess::GetLastError(),
        "Init() failed. Unable to execute database query.") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {
      // iterate over all the records ...
      while ((!myRowset.AtEOF()) && (bRetCode == TRUE)) 
      {
        // get the values ...
        myRowset.GetIntValue (_variant_t (DB_ACCOUNT_ID), nAcctID) ;
        myRowset.GetIntValue (_variant_t (DB_INTERVAL_ID), nIntervalID) ;
        myRowset.GetValue (_variant_t (DB_DATE_EFFECTIVE), vtValue) ;

        // try to find the account id in the map ...
        bFound = mAcctUsageIntervalColl.findValue (nAcctID, pAcctUsageInterval) ;
        if (bFound == TRUE)
        {
          // add the interval id to the acc usage interval ...
          pAcctUsageInterval->Add (nIntervalID, vtValue) ;
          pAcctUsageInterval = NULL ;
        }
        else if (nNumAcctsCached < MAX_CACHE_SIZE)
        {
          // create a new acc usage interval object ...
          nNumAcctsCached++ ;
          pAcctUsageInterval = new DBAcctUsageInterval ;

          // add the interval id to the acc usage interval ...
          pAcctUsageInterval->Add (nIntervalID, vtValue) ;
        
          // insert the key and value ...
          mAcctUsageIntervalColl.insertKeyAndValue (nAcctID, pAcctUsageInterval) ;
          pAcctUsageInterval = NULL ;
        }

        // move to the next row ...
        bRetCode = myRowset.MoveNext() ;
      }
    }
#endif
  }

  return bRetCode ;
}

//
//	@mfunc
//	Get a pointer to the DBUsageCycleCollection
//  @rdesc 
//  Returns a pointer to the DBUsageCycleCollection or NULL if a DBUsageCycleCollection
//  could not be created.
//
DBUsageCycleCollection * DBUsageCycleCollection::GetInstance()
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  // enter the critical section ...
  msLock.Lock() ;

  // if we havent allocated a usage cycle collection yet ... do it now ...
  if (mpsUsageCycle == 0)  
  {
    // allocate a services collection instance ...
    mpsUsageCycle = new DBUsageCycleCollection ;

    // call init ...
    bRetCode = mpsUsageCycle->Init() ;

    // if we werent initialized successfully ...
    if (bRetCode == FALSE)
    {
      delete mpsUsageCycle ;
      mpsUsageCycle = NULL ;
    }
  }
  // if we got a valid instance increment reference ...
  if (mpsUsageCycle != 0)
  {
    msNumRefs++ ;
  }
  // leave the critical section ...
  msLock.Unlock() ;

  // return mpsServices ...
  return mpsUsageCycle ;
}

//
//	@mfunc
//	Release a pointer to the DBUsageCycleCollection
//  @rdesc 
//  No return value.
//
void DBUsageCycleCollection::ReleaseInstance()
{
  // enter the critical section ...
  msLock.Lock() ;

  // decrement the reference counter ...
  if (mpsUsageCycle != 0)
  {
    msNumRefs-- ;
  }

  // if the number of references is 0 ... delete the collection 
  if (msNumRefs == 0)
  {
    delete mpsUsageCycle ;
    mpsUsageCycle = NULL ;
  }

  // leave the critical section ...
  msLock.Unlock() ;
}

BOOL DBUsageCycleCollection::GetIntervalFromCollection(const time_t &arTxnTime, 
    DBAcctUsageInterval * const apAcctUsageInterval,
    int &arIntervalID)
{
  DBUsageInterval *pUsageInterval=NULL ;
  DBIntervalIDDateEffective *pIntervalIDDateEffective=NULL ;
  BOOL foundCurrent = FALSE;
  int nIntervalID;
  int currentIntervalID;
  
  // iterate through the list ...
	DBIntervalIDColl::iterator it;
  for (it = apAcctUsageInterval->GetIntervalIDCollection().begin();
			 it != apAcctUsageInterval->GetIntervalIDCollection().end();
			 it++)
  {
    // get the interval id to date effective  ...
    pIntervalIDDateEffective = *it;

    // if the account to interval mapping isnt effective yet ... continue
    if (!pIntervalIDDateEffective->IsEffective(arTxnTime))
      continue;

    // get the interval id ...
    nIntervalID = pIntervalIDDateEffective->GetIntervalID() ;
    
    // find the interval id in the interval id map ...
		DBUsageIntervalColl::iterator findIt;
    findIt = mUsageIntervalColl.find(nIntervalID);
		if (findIt != mUsageIntervalColl.end()) 
    {
			pUsageInterval = findIt->second;
      // checks to see if the transaction's time is contained in this interval
      if (pUsageInterval->IsTxnInInterval(arTxnTime))
      {
        arIntervalID = nIntervalID ;
				return TRUE;
      } else {
        // check to see if this is the current interval ...
        time_t currTime = GetMTTime();
        if (pUsageInterval->IsCurrentInterval(currTime))
        {
          currentIntervalID = nIntervalID;
					foundCurrent = TRUE;
        }
      }
    } else {
			char buffer[1024];
			sprintf(buffer,
							"Unable to find usage interval %d in t_usage_interval "
							"referenced by t_acc_usage_interval!", nIntervalID);
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
							 "DBUsageCycleCollection::GetIntervalFromCollection",
							 buffer);
      mLogger->LogThis(LOG_ERROR, buffer);

			// logs the transaction time
			struct tm *gmTime = gmtime(&arTxnTime);
			struct tm *localTime = localtime (&arTxnTime) ;
			mLogger->LogVarArgs(LOG_ERROR, "Transaction time (GMT): %s", asctime(gmTime));
			mLogger->LogVarArgs(LOG_ERROR, "Transaction time (local): %s", asctime(localTime));
    }
  }
	
  // if we didnt find a usage interval then
	// use the current interval if that was found
	if (foundCurrent)
	{
		arIntervalID = currentIntervalID;
	}
	else
	{
		
		// an interval should have been found at this point!
		SetError (DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
							"DBUsageCycleCollection::GetIntervalFromCollection",
							"Transaction time was not contained in any usage interval and "
							"there was no current interval to fail back on.");
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		
		// logs the transaction time
		struct tm *gmTime = gmtime(&arTxnTime);
		struct tm *localTime = localtime (&arTxnTime) ;
		mLogger->LogVarArgs(LOG_ERROR, "Transaction time (GMT): %s", asctime(gmTime));
		mLogger->LogVarArgs(LOG_ERROR, "Transaction time (local): %s", asctime(localTime));
		
		return FALSE;
	}

	return TRUE;
}


//
//	@mfunc
//	Find the interval id for the account
//  @rdesc 
//
BOOL DBUsageCycleCollection::GetIntervalAndTableSuffix (const int &arAcctID, 
    const time_t &arTxnTime, int &arIntervalID)
{
  // local variables 
  BOOL bRetCode=TRUE ;
  DBAcctUsageInterval *pAcctUsageInterval=NULL ;
  DBUsageInterval *pUsageInterval=NULL ;

  // try to find the account id in the map ...
  msLock.Lock() ;
	DBAcctUsageIntervalColl::iterator findIt;
	findIt = mAcctUsageIntervalColl.find(arAcctID);
  if (findIt != mAcctUsageIntervalColl.end())
  {
		pAcctUsageInterval = findIt->second;

    // add a hit to this entry in the cache ...
    pAcctUsageInterval->AddHit() ;
    pAcctUsageInterval->SetInUse() ;
    msLock.Unlock() ;

		if(!GetIntervalFromCollection(arTxnTime,pAcctUsageInterval,arIntervalID))
			return FALSE;

    // clear the in use flag and null out ptr ...
    pAcctUsageInterval->ClearInUse() ;
    pAcctUsageInterval = NULL ;
  }
  // we didnt find the account in the map ... find the least recently used item ...
  else
  {
    std::wstring wstrCmd ;
    DBSQLRowset myRowset ;
    BOOL bFound = FALSE ;
    int nAcctID = -1 ;
    BOOL bOpenStatus=FALSE ;
    _variant_t vtValue ;

    // set bRetCode to TRUE ...
    bRetCode = TRUE ;

    // if we have the maximum number of elements in the cache ... find one to remove ...
    int nItems = mAcctUsageIntervalColl.size();
    if (nItems >= MAX_CACHE_SIZE)
    {
      // initialize the acct id and hits ...
      int nNumHits = -1 ;
      int nItemHits = 0;
      
      // iterate through the collection and find the least recently used item ...
      // get the iterator ...
      DBAcctUsageIntervalColl::iterator it;
			for (it = mAcctUsageIntervalColl.begin(); it != mAcctUsageIntervalColl.end(); it++)
      {
        // get the current item ...
        pAcctUsageInterval = it->second;
        
        // if this item has less hits than the ...
        nItemHits = pAcctUsageInterval->GetNumHits() ;
        if ((!pAcctUsageInterval->IsInUse()) && ((nItemHits < nNumHits) || (nNumHits == -1)))
        {
          nNumHits = nItemHits ;
          nAcctID = it->first;
          bFound = TRUE ;
        }
      }
      
      // if we found the least recently used item ...
      if (bFound == TRUE)
      {
        // remove the item from the collection ...
        mAcctUsageIntervalColl.erase(nAcctID);
      }
    }
    // if we havent hit an error yet ... get the interval id for the account
    if (bRetCode == TRUE)
    {
      // create the query to get the account to usage interval mapping ...
      wstrCmd = CreateGetAccountUsageIntervalByAccountQuery(arAcctID) ;
      
      // execute a command to get info from the database ...
      bRetCode = DBAccess::ExecuteDisconnected (wstrCmd, myRowset) ;
      if (bRetCode == FALSE)
      {
        SetError (DBAccess::GetLastError(),
          "GetIntervalAndTableSuffix() failed. Unable to execute database query.") ;
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      }
      else
      {
        // if there are no records in the rowset then the account to usage 
        // interval mapping doesnt exist ...
        if (myRowset.GetRecordCount() > 0)
        {
          pAcctUsageInterval = NULL ;
          while ((!myRowset.AtEOF()) && (bRetCode == TRUE))
          {
            // get the values ...
            myRowset.GetIntValue (_variant_t (DB_ACCOUNT_ID), nAcctID) ;
            myRowset.GetIntValue (_variant_t (DB_INTERVAL_ID), arIntervalID) ;
            myRowset.GetValue (_variant_t (DB_DATE_EFFECTIVE), vtValue) ;
            
            // if we havent found the account to usage interval mapping yet ...
            if (pAcctUsageInterval == NULL)
            {
              // try to find the account id in the map ...
							DBAcctUsageIntervalColl::iterator findIt;
							findIt = mAcctUsageIntervalColl.find(nAcctID);
							//bFound = mAcctUsageIntervalColl.findValue (nAcctID, pAcctUsageInterval) ;
              if (findIt != mAcctUsageIntervalColl.end())
              {
								pAcctUsageInterval = findIt->second;
                // add the interval id to the acc usage interval ...
                pAcctUsageInterval->Add (arIntervalID, vtValue) ;
              }
              else
              {
                // create a new acc usage interval object ...
                pAcctUsageInterval = new DBAcctUsageInterval ;
                ASSERT(pAcctUsageInterval) ;
                
                // add the interval id to the acc usage interval ...
                pAcctUsageInterval->Add (arIntervalID, vtValue) ;
                
                // insert the key and value ...
                mAcctUsageIntervalColl[nAcctID] = pAcctUsageInterval;
              }
            }
            // otherwise ... we have already found the account ...
            else
            {
              // add the interval id to the acc usage interval ...
              pAcctUsageInterval->Add (arIntervalID, vtValue) ;
            }

            // try to find the usage interval in the cache ...
						
						DBUsageIntervalColl::iterator findIt;
						findIt = mUsageIntervalColl.find(arIntervalID);

            // interval not found ... refresh the cache ...
						if (findIt == mUsageIntervalColl.end()) 
            {
              // get the interval by id ...
              bRetCode = GetUsageIntervalByID (arIntervalID) ;
              if (bRetCode == FALSE)
              {
                mLogger->LogVarArgs (LOG_ERROR, "Unable to get usage interval with id = %d.",
                  arIntervalID) ;
              }
            }
            // move to the next row ...
            bRetCode = myRowset.MoveNext() ;
          }
          // if we have an acct usage interval ...
          if (pAcctUsageInterval != NULL)
          {
            // add a hit to this element of the cache ...
            pAcctUsageInterval->AddHit() ;

						if (!GetIntervalFromCollection(arTxnTime, pAcctUsageInterval, arIntervalID))
							return FALSE;
            
          }
          else
          {
            mLogger->LogVarArgs (LOG_ERROR, 
              "Unable to find the account to usage interval mapping for account = %d",
              arAcctID) ;
            bRetCode = FALSE ;
          }
        }
      }
    }
    // unlock the critical section ...
    msLock.Unlock() ;
  }


  return bRetCode ;
}

BOOL DBUsageCycleCollection::GetIntervalStartAndEndDate (const int &arIntervalID, 
    DATE &arStartDate, DATE &arEndDate)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  DBUsageInterval *pUsageInterval=NULL ;
  time_t startDate, endDate ;
  
  // find the interval id in the interval id map ...
  msLock.Lock() ;
	DBUsageIntervalColl::iterator findIt;
	findIt = mUsageIntervalColl.find(arIntervalID);
  if (findIt != mUsageIntervalColl.end()) 
  {
		pUsageInterval = findIt->second;
    // unlock the critical section ...
    msLock.Unlock() ;

    // get the start and end time out of the usage interval ...
    startDate = pUsageInterval->GetStartDate() ;
    endDate = pUsageInterval->GetEndDate() ;

    // convert the start and end time to DATE's ...
    OleDateFromTimet (&arStartDate, startDate) ;
    OleDateFromTimet (&arEndDate, endDate) ;
  }
  else
  {
    // get the interval by id ...
    bRetCode = GetUsageIntervalByID (arIntervalID) ;
    if (bRetCode == FALSE)
    {
      mLogger->LogVarArgs (LOG_ERROR, "Unable to get usage interval with id = %d.",
        arIntervalID) ;
    }
    // otherwise the cache was refreshed ... get the usage interval ...
    else
    {
			DBUsageIntervalColl::iterator findIt;
			findIt = mUsageIntervalColl.find(arIntervalID);
      if (findIt != mUsageIntervalColl.end()) 
      {
				pUsageInterval = findIt->second;
        // get the start and end time out of the usage interval ...
        startDate = pUsageInterval->GetStartDate() ;
        endDate = pUsageInterval->GetEndDate() ;
        
        // convert the start and end time to DATE's ...
        OleDateFromTimet (&arStartDate, startDate) ;
        OleDateFromTimet (&arEndDate, endDate) ;
      }
      else
      {
        mLogger->LogVarArgs (LOG_ERROR, 
          "Unable to get usage interval with id = %d after cache refresh.",
          arIntervalID) ;
      }
    }
    // unlock the critical section ...
    msLock.Unlock() ;
  }

  return bRetCode ;
}
//
//	@mfunc
//	Get the usage interval by id 
//  @rdesc 
//  No return value.
//
//*************************************************************************
// Call this routine with the critical section locked ...
//*************************************************************************
//
BOOL DBUsageCycleCollection::GetUsageIntervalByID (const int &arIntervalID)
{
  // local variables ...
  std::wstring wstrCmd ;
  std::wstring wstrStatus ;
  DBSQLRowset myRowset ;
  BOOL bRetCode=TRUE ;
  DBUsageInterval *pUsageInterval=NULL ;
  int nCycleID=-1 ;
  int nIntervalID=-1 ;
  BOOL bFound=FALSE ;
  _variant_t vtStartDate ;
  _variant_t vtEndDate ;
  BOOL bOpenStatus=FALSE ;

  // create the query to get the account to usage interval mapping ...
  wstrCmd = CreateGetUsageIntervalByIDQuery(arIntervalID) ;
  
  // execute a command to get info from the database ...
  bRetCode = DBAccess::ExecuteDisconnected (wstrCmd, myRowset) ;
  if (bRetCode == FALSE)
  {
    SetError (DBAccess::GetLastError(),
      "GetUsageIntervalByID() failed. Unable to execute database query.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  else
  {
    // if there are no records in the rowset then the account to usage 
    // interval mapping doesnt exist ...
    if (myRowset.GetRecordCount() == 0)
    {
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
        "DBUsageCycleCollection::GetUsageIntervalByID", 
        "No usage interval found.");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      bRetCode = FALSE ;
    }
    // otherwise ... get the info from the database ...
    else
    {
      // get the values ...
      myRowset.GetValue(_variant_t (DB_START_DATE), vtStartDate) ;
      myRowset.GetValue(_variant_t (DB_END_DATE), vtEndDate) ;
      myRowset.GetIntValue (_variant_t (DB_INTERVAL_ID), nIntervalID) ;
      myRowset.GetIntValue (_variant_t (DB_CYCLE_ID), nCycleID) ;
      myRowset.GetWCharValue (_variant_t (DB_STATUS), wstrStatus) ;
      
      // if the status is 'N' or 'O' ... set the status flag to true ...
      //if (((wstrStatus.compareTo (USAGE_INTERVAL_NEW, RWWString::ignoreCase)) == 0) ||
        //((wstrStatus.compareTo (USAGE_INTERVAL_OPEN, RWWString::ignoreCase)) == 0))
	  if ((_wcsicmp(wstrStatus.c_str(), USAGE_INTERVAL_NEW) == 0) ||
		  (_wcsicmp(wstrStatus.c_str(), USAGE_INTERVAL_OPEN) == 0))
      {
        bOpenStatus = TRUE ;
      }
      // otherwise, set the status flag to false ...
      else
      {
        bOpenStatus = FALSE ;
      }
      
      // convert the date's to time_t's ...
      time_t tStartDate, tEndDate ;
      
      TimetFromOleDate (&tStartDate, vtStartDate.date) ;
      TimetFromOleDate (&tEndDate, vtEndDate.date) ;
      
      // create a new UsageInterval object ...
      pUsageInterval = new DBUsageInterval (nIntervalID, tStartDate, 
        tEndDate, nCycleID, bOpenStatus) ;
      ASSERT (pUsageInterval) ;
      if (pUsageInterval == NULL)
      {
        SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, 
          "DBUsageCycleCollection::GetUsageIntervalByID", "Unable to allocate memory");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        bRetCode = FALSE ;
      }
      else
      {
        // add the key/value pair into the map ...          
        mUsageIntervalColl[nIntervalID] = pUsageInterval;
        pUsageInterval = NULL ;
      }

    }
  }
  return bRetCode ;
}


//
//	@mfunc
//	Create the query to 
//  @rdesc 
//  The database query
//
std::wstring DBUsageCycleCollection::CreateGetUsageIntervalsQuery()
{
  std::wstring wstrCmd ;
  _bstr_t queryTag ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__GET_USAGE_INTERVALS__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

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
      "DBUsageCycleCollection::CreateGetUsageIntervalsQuery", 
      "Unable to get query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}

//
//	@mfunc
//	Create the query to 
//  @rdesc 
//  The database query
//
std::wstring DBUsageCycleCollection::CreateGetAccountUsageIntervalsQuery()
{
  std::wstring wstrCmd ;
  _bstr_t queryTag ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__GET_ACCOUNT_USAGE_INTERVALS__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

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
      "DBUsageCycleCollection::CreateGetAccountUsageIntervalsQuery", 
      "Unable to get query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}

//
//	@mfunc
//	Create the query to 
//  @rdesc 
//  The database query
//
std::wstring DBUsageCycleCollection::CreateGetAccountUsageIntervalByAccountQuery(const int &arAcctID)
{
  std::wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__GET_ACCOUNT_USAGE_INTERVAL_BY_ACCT__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam = (long) arAcctID;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;

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
      "DBUsageCycleCollection::CreateGetAccountUsageIntervalByAccountQuery", 
      "Unable to get query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}

std::wstring DBUsageCycleCollection::CreateGetUsageIntervalByIDQuery(const int &arIntervalID) 
{
  std::wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__GET_USAGE_INTERVAL_BY_ID__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

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
      "DBUsageCycleCollection::CreateGetUsageIntervalByIDQuery", 
      "Unable to get query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}



