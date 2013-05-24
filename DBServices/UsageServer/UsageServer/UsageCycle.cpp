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
#pragma warning( disable : 4786 )

#include <metralite.h>
#include <mtcom.h>
#include <comdef.h>
#include <adoutil.h>
#include <UsageCycle.h>
#include <DBConstants.h>
#include <time.h>
#include <DBSQLRowset.h>
#include <mtparamnames.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <MTUtil.h>
#include <DBMiscUtils.h>
#include <UsageServerConstants.h>
#include <MTUsageServer.h>
#include <mtcomerr.h>
#include <mttime.h>
#include <formatdbvalue.h>
#include <MTDate.h>
#include <stdutils.h>

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

#import <MTUsageServer.tlb> rename( "EOF", "RowsetEOF" )
using namespace MTUSAGESERVERLib ;

// @mfunc MTUsageCycle default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// Core Kiosk Gate class
MTUsageCycle::MTUsageCycle()
: mCycleType(-1), mInitialized(FALSE), mCycleID(-1),
mpQueryAdapter (NULL), mpUsageCyclePropCol(NULL)
{
	LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "UsageCycle") ;
}

// @mfunc MTUsageCycle destructor
// @parm 
// @rdesc This implementations is for the destructor of the 
// Core Kiosk Gate class
MTUsageCycle::~MTUsageCycle()
{
  // clear the usage interval collection ...
  mIntervalColl.clear() ;

	// disconnect from the database
  if (!DBAccess::Disconnect())
	{
		SetError (GetLastError(), "Unable to disconnect from database");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
	}
  // release the queryadapter ...
  if (mpQueryAdapter != NULL)
  {
    mpQueryAdapter->Release() ;
    mpQueryAdapter = NULL ;
  }
	if(mpUsageCyclePropCol) {
		mpUsageCyclePropCol->Release();
		mpUsageCyclePropCol = NULL;
	}
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL MTUsageCycle::Init ()
{
  // local variables ...
  BOOL bRetCode=TRUE ;

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
        SetError (DBAccess::GetLastError(), "Init() failed. Unable to initialize dbaccess layer.");
        mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
        bRetCode = FALSE ;
      }
    }
    catch (_com_error e)
    {
      //SetError(e) ;
      SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "MTUsageCycle::Init", 
        "Unable to initialize query adapter");
      mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, "Init() failed. Error Description = %s",
        (char*) e.Description()) ;
      bRetCode = FALSE ;
    }
  }
  
	return (bRetCode);
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL MTUsageCycle::Init(const long &arCycleType, ::ICOMUsageCyclePropertyColl * apPropColl)
{
	// local variables
	BOOL bRetCode = TRUE;
  HRESULT nRetVal=S_OK ;
  wstring wstrQueryExt ;
  _variant_t vtValue ;
  long dayOfMonth=0 ;
  long dayOfWeek=0 ;
  long firstDOM=0, secondDOM=0 ;
  long startDay=0, startMonth=0;
  long startYear=0 ;
  DBSQLRowset myRowset ;
  wstring wstrCmd ;
  wchar_t wstrTempNum[64] ;

  // call init ...
  bRetCode = Init() ;
  if (bRetCode == FALSE)
  {
    mInitialized = FALSE ;
    return bRetCode ;
  }

  // copy parameters ...
  mCycleType = arCycleType ;
	ASSERT(apPropColl);
	mpUsageCyclePropCol = apPropColl;
	mpUsageCyclePropCol->AddRef();


  // switch on the cycle type ...
  switch (mCycleType)
  {
  case UC_MONTHLY:
    // get the day of month out of the property collection ...
    vtValue = 
      ((MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *)apPropColl)->GetProperty (UCP_DAY_OF_MONTH) ;
    // get the day of month ...
    dayOfMonth = vtValue.lVal ;
    
    // create the where clause for the query to get the cycle id ...
    wstrQueryExt = L" and day_of_month = " ;
    wstrQueryExt += _itow (dayOfMonth, wstrTempNum, 10) ;
    break ;

  case UC_ON_DEMAND:
    break ;

  case UC_DAILY:
    break ;

  case UC_WEEKLY:
    // get the day of month out of the property collection ...
    vtValue = 
      ((MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *)apPropColl)->GetProperty (UCP_DAY_OF_WEEK) ;
    // get the day of month ...
    dayOfWeek = vtValue.lVal ;
    
    // create the where clause for the query to get the cycle id ...
    wstrQueryExt = L" and day_of_week = " ;
    wstrQueryExt += _itow (dayOfWeek, wstrTempNum, 10) ;
    break ;

  case UC_BI_WEEKLY:
    // get the start day out of the property collection ...
    vtValue = 
      ((MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *)apPropColl)->GetProperty (UCP_START_DAY) ;
    startDay = vtValue.lVal ;
    
    // create the where clause for the query to get the cycle id ...
    wstrQueryExt = L" and start_day = " ;
    wstrQueryExt += _itow (startDay, wstrTempNum, 10) ;
    
    // get the start month out of the property collection ...
    vtValue = 
      ((MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *)apPropColl)->GetProperty (UCP_START_MONTH) ;
    startMonth = vtValue.lVal ;
    
    // create the where clause for the query to get the cycle id ...
    wstrQueryExt += L" and start_month = " ;
    wstrQueryExt += _itow (startMonth, wstrTempNum, 10) ;
    
    // get the start year out of the property collection ...
    vtValue = 
      ((MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *)apPropColl)->GetProperty (UCP_START_YEAR) ;
    startYear = vtValue.lVal ;
    
    // create the where clause for the query to get the cycle id ...
    wstrQueryExt += L" and start_year = " ;
    wstrQueryExt += _itow (startYear, wstrTempNum, 10) ;

    break ;

  case UC_SEMI_MONTHLY:
    // get the first day of month out of the property collection ...
    vtValue = 
      ((MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *)apPropColl)->GetProperty (UCP_FIRST_DAY_OF_MONTH) ;
    firstDOM = vtValue.lVal ;
    
    // create the where clause for the query to get the cycle id ...
    wstrQueryExt += L" and first_day_of_month = " ;
    wstrQueryExt += _itow (firstDOM, wstrTempNum, 10) ;
    
    // get the second day of month out of the property collection ...
    vtValue = 
      ((MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *)apPropColl)->GetProperty (UCP_SECOND_DAY_OF_MONTH) ;
    secondDOM = vtValue.lVal ;
    
    // create the where clause for the query to get the cycle id ...
    wstrQueryExt += L" and second_day_of_month = " ;
    wstrQueryExt += _itow (secondDOM, wstrTempNum, 10) ;

    break ;

  case UC_QUARTERLY:
  case UC_SEMIANNUALLY:
  case UC_ANNUALLY:
    // get the start day out of the property collection ...
    vtValue = 
      ((MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *)apPropColl)->GetProperty (UCP_START_DAY) ;
    startDay = vtValue.lVal ;
    
    // create the where clause for the query to get the cycle id ...
    wstrQueryExt = L" and start_day = " ;
    wstrQueryExt += _itow (startDay, wstrTempNum, 10) ;
    
    // get the start month out of the property collection ...
    vtValue = 
      ((MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *)apPropColl)->GetProperty (UCP_START_MONTH) ;
    startMonth = vtValue.lVal ;
    
    // create the where clause for the query to get the cycle id ...
    wstrQueryExt += L" and start_month = " ;
    wstrQueryExt += _itow (startMonth, wstrTempNum, 10) ;
    break ;

  default:
    // get the cycle id out of the property collection ...
    // get the start month out of the property collection ...
    vtValue = 
      ((MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *)apPropColl)->GetProperty (UCP_CYCLE_ID) ;
    mCycleID = vtValue.lVal ;

    break ;
  }

  // do the query to get the cycle id ...
  if ((bRetCode == TRUE) && (mCycleID == -1))
  {
    // create the query to get the cycle id ...
    wstrCmd = CreateFindUsageCycleQuery (mCycleType, wstrQueryExt) ;
    
    // execute the query ...
    if (!DBAccess::Execute(wstrCmd, myRowset))
    {
      bRetCode = FALSE;
      SetError (GetLastError(), 
        "Init() failed. Unable to execute database query.") ;
      mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
													"Init() failed. Unable to get cycle id. Cycle Type = %d. Ext = %s",
													mCycleType, ascii(wstrQueryExt).c_str()) ;
    }
    
    // if we have data in the rowset ...
    if (myRowset.GetRecordCount() == 1)
    {
      // get the interval id
      myRowset.GetLongValue (_variant_t(DB_CYCLE_ID), mCycleID) ;
      
    }
    // otherwise ... ther are multiple cycle id's (should never happen)
    else
    {
      bRetCode = FALSE;
      if (myRowset.GetRecordCount() < 1)
      {
        SetError (DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE,
          "Init() failed. No cycle id's found.") ;
        mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
        mLogger.LogVarArgs (LOG_ERROR, 
          "Init() failed. No cycle id's found. Cycle Type = %d. Ext = %s",
          mCycleType, ascii(wstrQueryExt).c_str()) ;
      }
      else
      {
        SetError (DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE,
          "Init() failed. Multiple cycle id's found.") ;
        mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
        mLogger.LogVarArgs (LOG_ERROR, 
          "Init() failed. Multiple cycle id's found. Cycle Type = %d. Ext = %s",
          mCycleType, ascii(wstrQueryExt).c_str()) ;
      }
    }
  }

  if (bRetCode == TRUE)
  {
    // set the initialized flag ...
    mInitialized = TRUE ;
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
BOOL MTUsageCycle::CreateInterval (const BSTR apStartDate, const BSTR apEndDate, 
                                   BOOL &arIntervalExists)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring wstrCmd ;
  DBSQLRowset myRowset ;
  long nIntervalID=-1;

  // if we're not initialized ...
  arIntervalExists = FALSE ;
  if ((mInitialized == FALSE) || (mCycleID == -1))
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      "MTUsageCycle::CreateInterval") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    if (mCycleID == -1)
    {
      mLogger.LogThis (LOG_ERROR, 
        "CreateInterval() failed. Unable to create interval for unknown cycle") ;
    }
    return FALSE ;
  }
  // check to see if the usage interval exists ...
  wstrCmd = CreateFindUsageIntervalQuery (apStartDate, apEndDate, 
    mCycleID) ;

  // execute the query ...
  if (!DBAccess::Execute(wstrCmd, myRowset))
  {
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "CreateInterval() failed. Unable to execute database query") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "CreateInterval() failed. Unable to find usage intervals.") ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"CreateInterval() failed. Cycle ID = %d. StartDate = %s. EndDate = %s",
      mCycleID, apStartDate, apEndDate) ;
  }

  // if we we have a row ... the usage interval exists ... exit ...
  if (myRowset.GetRecordCount() != 0)
  {
    arIntervalExists = TRUE ;
    return TRUE ;
  }

  // interval doesnt exist ... create the interval ...
  bRetCode = CreateInterval (apStartDate, apEndDate) ;

  return bRetCode ;
}

BOOL MTUsageCycle::CreateInterval (const BSTR apStartDate, const BSTR apEndDate)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring wstrCmd ;
  long nIntervalID=-1;


  // intialize the stored procedure ...
  if (!DBAccess::InitializeForStoredProc(L"InsertUsageIntervalInfo"))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Initialization of stored procedure failed");
    return FALSE;
  }
  
  // add the parameters ...
  _variant_t vtValue = apStartDate ;
  if (!DBAccess::AddParameterToStoredProc (L"dt_start", MTTYPE_VARCHAR, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  _bstr_t bstrEnd = apEndDate ;
  bstrEnd += L" 23:59:59" ;
  vtValue = bstrEnd ;
  if (!DBAccess::AddParameterToStoredProc (L"dt_end", MTTYPE_VARCHAR, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  vtValue = (long) mCycleID ;
  if (!DBAccess::AddParameterToStoredProc (L"id_usage_cycle", MTTYPE_INTEGER, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  if (!DBAccess::AddParameterToStoredProc (L"id_usage_interval", MTTYPE_INTEGER, OUTPUT_PARAM))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  
  // execute the stored procedure ...
  if (!DBAccess::ExecuteStoredProc())
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to execute stored procedure.");
    return FALSE;
  }
  
  // get the parameter ...
  if (!DBAccess::GetParameterFromStoredProc (L"id_usage_interval", vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to get parameter from stored procedure.");
    return FALSE;
  }
  nIntervalID = GetIntValue (vtValue);

  // insert the interval into the collection ...
  mIntervalColl.push_back(nIntervalID) ;

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL MTUsageCycle::AddAccount(const BSTR apStartDate, const BSTR apEndDate,
                              const long &arAcctID, LPDISPATCH pRowset)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring wstrCmd ;
  long nIntervalID=-1;
  long nDeterminedIntervalID=-1 ;
  DBSQLRowset myRowset;

  // if we're not initialized ...
  if ((mInitialized == FALSE) || (mCycleID == -1))
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      "MTUsageCycle::AddAcount") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    if (mCycleID == -1)
    {
      mLogger.LogThis (LOG_ERROR, "AddAccount() failed. Unable to add account to unknown cycle") ;
    }
    return FALSE ;
  }

  // create the find usage interval query ...
  wstrCmd = CreateFindUsageIntervalQuery (mCycleID) ;

  // execute the query ...
  if (!DBAccess::Execute(wstrCmd, myRowset))
  {
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "AddAccount() failed. Unable to execute database query") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  // if we have data in the rowset ...
  while (!myRowset.AtEOF())
  {
    // get the interval
    myRowset.GetLongValue (_variant_t(DB_INTERVAL_ID), nIntervalID) ;

    // insert the interval id into the list ...
    mIntervalColl.push_back(nIntervalID);
  
    // move to the next record ...
    if (!myRowset.MoveNext())
    {
      SetError (myRowset.GetLastError(),
        "AddAccount() failed. Unable to move to next row of rowset") ;
      mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }
  }

  // create an interval for the start date and end date ...
  BOOL bIntervalExists=FALSE ;
  bRetCode = CreateInterval (apStartDate, apEndDate, bIntervalExists) ;
  if (bRetCode == FALSE)
  {
    mLogger.LogVarArgs (LOG_ERROR, "AddAccount() failed. Unable to create usage interval.") ;
  }

  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
		ROWSETLib::IMTSQLRowsetPtr pSQLRowset(pRowset) ;
    BOOL bFirstTime=TRUE ;
    
    // for all the entries in the interval collection ...
    IntervalColl::iterator it;
		for (it = mIntervalColl.begin(); it != mIntervalColl.end(), bRetCode == TRUE; it++)
    {
      // get the interval id ...
      nIntervalID = *it;

      // set the dtermined interval id if it's not set ...
      if (nDeterminedIntervalID == -1)
      {
        nDeterminedIntervalID = nIntervalID ;
      }
      
      bRetCode = CreateAndExecuteInsertToAccountUsageIntervalQuery (arAcctID, 
        nIntervalID, pSQLRowset) ;
      if (bRetCode == TRUE && bFirstTime == TRUE)
      {
        bFirstTime = FALSE ;
        bRetCode = CreateAndExecuteInsertToAccountUsageCycleQuery (arAcctID, 
          mCycleID, pSQLRowset) ;
      }
    }
  }
  
  // add the interval to the property collection
  if (bRetCode == TRUE)
  {
    mpUsageCyclePropCol->AddProperty(_bstr_t("DeterminedIntervalID"),
      _variant_t(nDeterminedIntervalID));
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
BOOL MTUsageCycle::UpdateAccount(const BSTR apStartDate, const BSTR apEndDate,
                                 const long &arAcctID, 
                                 const _variant_t &arCurrentIntervalEndDate)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring wstrCmd ;
  long nIntervalID=-1;
  DBSQLRowset myRowset;

	
	_bstr_t bstrIntervalEndDate = (_bstr_t)arCurrentIntervalEndDate;


  // if we're not initialized ...
  if ((mInitialized == FALSE) || (mCycleID == -1))
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      "MTUsageCycle::UpdateAcount") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    if (mCycleID == -1)
    {
      mLogger.LogThis (LOG_ERROR, "Unable to update account to unknown cycle") ;
    }
    return FALSE ;
  }

	//creates the find usage interval query

	
	wstrCmd = CreateFindUsageIntervalByEndDateQuery(mCycleID, bstrIntervalEndDate);

	
  // execute the query ...
  if (!DBAccess::Execute(wstrCmd, myRowset))
  {
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "UpdateAccount() failed. Unable to find usage intervals") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  // if we have data in the rowset ...
  while (!myRowset.AtEOF())
  {
    // get the interval id
    myRowset.GetLongValue (_variant_t(DB_INTERVAL_ID), nIntervalID) ;

    // insert the interval id into the list ...
    mIntervalColl.push_back(nIntervalID);
  
    // move to the next record ...
    if (!myRowset.MoveNext())
    {
      SetError (myRowset.GetLastError(),
        "UpdateAccount() failed. Unable to move to next row of rowset") ;
      mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }
  }
  // if we don't have any usage intervals ...
  if (mIntervalColl.size() == 0)
  {
    // create an interval for the start date and end date ...
    bRetCode = CreateInterval (apStartDate, apEndDate) ;
    if (bRetCode == FALSE)
    {
      mLogger.LogVarArgs (LOG_ERROR, "UpdateAccount() failed. Unable to create usage interval.") ;
    }
  }

  //Now subtract the date because the rest of the queries in this method operate
	//on dt_effective
	MTDate endDate(string((const char*) (_bstr_t) arCurrentIntervalEndDate));
	endDate--;
	string dateTmp;
	endDate.ToString(STD_DATE_FORMAT, dateTmp);
	
	bstrIntervalEndDate = dateTmp.c_str();


  // remove the old entries from t_acc_usage_interval ...
  wstrCmd = CreateDeleteIntervalsFromAccUsageInterval (arAcctID, bstrIntervalEndDate) ;

  // execute the query ...
  if (!DBAccess::Execute(wstrCmd))
  {
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "UpdateAccount() failed. Unable to delete accout usage intervals records") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  // remove the old entries from t_acc_usage_interval ...
  wstrCmd = CreateDeletePreviousUpdatesFromAccUsageInterval (arAcctID) ;
  
  // execute the query ...
  if (!DBAccess::Execute(wstrCmd))
  {
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "UpdateAccount() failed. Unable to delete accout usage intervals records") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  // for all the intervals ...
  IntervalColl::iterator it;
	for (it = mIntervalColl.begin(); it != mIntervalColl.end(); it++)
	{
    // get the interval id ...
    nIntervalID = *it;

    // remove the old entries from t_acc_usage_interval ...
    wstrCmd = CreateUpdateAcctToIntervalMapping (arAcctID, nIntervalID, bstrIntervalEndDate) ;
    
    // execute the query ...
    if (!DBAccess::Execute(wstrCmd))
    {
      bRetCode = FALSE;
      SetError (GetLastError(), 
        "UpdateAccount() failed. Unable to delete accout usage intervals records") ;
      mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }

  // create the query to insert the account to the account usage interval table ...
  wstrCmd = CreateUpdateToAccountUsageCycleQuery (arAcctID, mCycleID) ;

  // execute the query ...
	if (!DBAccess::Execute(wstrCmd))
	{
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "AddAccount() failed. Unable to execute database query") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
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
BOOL MTUsageCycle::UpdateAccountToIntervalMapping()
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring wstrCmd ;
  long nAcctID=-1 ;
  DBSQLRowset myRowset ;
  long nIntervalID=-1;

  // if we're not initialized ...
  if ((mInitialized == FALSE))
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      "MTUsageCycle::AddAcount") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  // if the cycle id or interval id are not set ...
  if ((mCycleID == -1) || (mIntervalColl.size() == 0))
  {
    return TRUE ;
  }

	// for all the intervals ...
	IntervalColl::iterator it;
	for (it = mIntervalColl.begin(); it != mIntervalColl.end(); it++)
	{
		
		// get the interval id ...
		nIntervalID = *it;

		// create the query to update all accounts
		wstrCmd = CreateUpdateAccountToIntervalMappingQuery(mCycleID, nIntervalID);

		// execute the query ...
		if (!DBAccess::Execute(wstrCmd))
		{
			bRetCode = FALSE;
			SetError (GetLastError(), 
								"UpdateAccount() failed. Unable to execute database query") ;
			mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
		}
	}

  return bRetCode ;
}

wstring MTUsageCycle::CreateFindAccountsForCycleQuery (const long &arCycleID)
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__FIND_ACCOUNTS_BY_CYCLE_ID__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arCycleID ;
    mpQueryAdapter->AddParam (MTPARAM_CYCLEID, vtParam) ;

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
      "MTUsageCycle::CreateFindAccountsForCycleQuery", 
      "Unable to create __FIND_ACCOUNTS_BY_CYCLE_ID__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
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
wstring MTUsageCycle::CreateInsertUsageCycleQuery (const long &arCycleType,
																									 const long &arDayOfMonth,
																									 const BSTR aUsageCyclePeriodType) 
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__INSERT_USAGE_CYCLE__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arCycleType ;
    mpQueryAdapter->AddParam (MTPARAM_CYCLETYPE, vtParam) ;
    vtParam =  (long) arDayOfMonth ;
    mpQueryAdapter->AddParam (MTPARAM_DAYOFMONTH, vtParam) ;
    vtParam = aUsageCyclePeriodType ;
    mpQueryAdapter->AddParam (MTPARAM_PERIODTYPE, vtParam) ;
    
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
      "MTUsageCycle::CreateInsertUsageCycleQuery", 
      "Unable to create __INSERT_USAGE_CYCLE__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
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
wstring MTUsageCycle::CreateInsertToAccountUsageIntervalQuery (const long &arAcctID, 
      const long &arIntervalID)
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__INSERT_ACCOUNT_USAGE_INTERVAL__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam =  (long) arIntervalID ;
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
      "MTUsageCycle::CreateInsertToAccountUsageIntervalQuery", 
      "Unable to create __INSERT_ACCOUNT_USAGE_INTERVAL__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
  }
  return wstrCmd ;
}

BOOL MTUsageCycle::CreateAndExecuteInsertToAccountUsageIntervalQuery (const long &arAcctID, 
																																			const long &arIntervalID,
																																			ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
  BOOL bRetCode=TRUE ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
#if 0
    // set the query tag and initialize the parameter list ...
    arRowset->ClearQuery() ;

    queryTag = "__INSERT_ACCOUNT_USAGE_INTERVAL__" ;
    arRowset->SetQueryTag (queryTag) ;

    vtParam =  (long) arAcctID ;
    arRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam =  (long) arIntervalID ;
    arRowset->AddParam (MTPARAM_INTERVALID, vtParam) ;

    arRowset->Execute() ;
#else
    // initialize the stored procedure ...
    arRowset->InitializeForStoredProc ("InsertAcctToIntervalMapping") ;

    // add the parameters ...
    vtParam = arAcctID ;
    arRowset->AddInputParameterToStoredProc("id_acc", MTTYPE_INTEGER, INPUT_PARAM, vtParam) ;
    vtParam = arIntervalID;
    arRowset->AddInputParameterToStoredProc("id_interval", MTTYPE_INTEGER, INPUT_PARAM, vtParam) ;

    // execute the stored procedure ...
    arRowset->ExecuteStoredProc() ;
#endif
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, 
      "MTUsageCycle::CreateAndExecuteInsertToAccountUsageIntervalQuery", 
      "Unable to create and execute __INSERT_ACCOUNT_USAGE_INTERVAL__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
  }
  return bRetCode;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
wstring MTUsageCycle::CreateFindUsageCycleQuery (const long &arCycleType,
																								 const wstring &arQueryExt) 
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__FIND_USAGE_CYCLE__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arCycleType ;
    mpQueryAdapter->AddParam (MTPARAM_CYCLETYPE, vtParam) ;
    vtParam =  arQueryExt.c_str();
    mpQueryAdapter->AddParam (MTPARAM_EXT, vtParam) ;

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
      "MTUsageCycle::CreateFindUsageCycleQuery", 
      "Unable to create __FIND_USAGE_CYCLE__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
  }
  return wstrCmd ;
}

wstring MTUsageCycle::CreateFindUsageIntervalQuery (const long &arCycleID) 
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {


    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__FIND_USAGE_INTERVAL_BY_CYCLE_ID__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arCycleID ;
    mpQueryAdapter->AddParam (MTPARAM_CYCLEID, vtParam) ;

		_variant_t currentTime = GetMTOLETime();
		std::wstring buffer;
		FormatValueForDB(currentTime, FALSE, buffer);
    mpQueryAdapter->AddParam (L"%%UTCDATE%%", buffer.c_str(), true);

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
      "MTUsageCycle::CreateFindUsageIntervalQuery", 
      "Unable to create __FIND_USAGE_INTERVAL_BY_CYCLE_ID__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
  }
  return wstrCmd ;
}

wstring MTUsageCycle::CreateFindUsageIntervalByEndDateQuery (const long &arCycleID,
																														 const BSTR apIntervalEndDate) 
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__FIND_USAGE_INTERVAL_BY_INTERVAL_END_DATE__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arCycleID ;
    mpQueryAdapter->AddParam (MTPARAM_CYCLEID, vtParam) ;
    vtParam =  apIntervalEndDate ;
    mpQueryAdapter->AddParam (MTPARAM_ENDDATE, vtParam) ;

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
      "MTUsageCycle::CreateFindUsageIntervalByEndDateQuery", 
      "Unable to create __FIND_USAGE_INTERVAL_BY_INTERVAL_END_DATE__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
  }
  return wstrCmd ;
}

wstring MTUsageCycle::CreateUpdateAcctToIntervalMapping (const long &arAcctID,
																												 const long &arIntervalID,
																												 const BSTR apIntervalEndDate) 
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__UPDATE_ACCT_TO_INTERVAL_MAP__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam =  (long) arIntervalID ;
    mpQueryAdapter->AddParam (MTPARAM_INTERVALID, vtParam) ;
    vtParam =  apIntervalEndDate ;
    mpQueryAdapter->AddParam (MTPARAM_ENDDATE, vtParam) ;

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
      "MTUsageCycle::CreateDeleteIntervalsFromAccUsageInterval", 
      "Unable to create __DELETE_INTERVALS_FROM_AUI__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
  }
  return wstrCmd ;
}

wstring MTUsageCycle::CreateDeleteIntervalsFromAccUsageInterval (const long &arAcctID,
                                                                   const BSTR apIntervalEndDate) 
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__DELETE_INTERVALS_FROM_AUI__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam =  apIntervalEndDate ;
    mpQueryAdapter->AddParam (MTPARAM_ENDDATE, vtParam) ;

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
      "MTUsageCycle::CreateDeleteIntervalsFromAccUsageInterval", 
      "Unable to create __DELETE_INTERVALS_FROM_AUI__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
  }
  return wstrCmd ;
}


wstring MTUsageCycle::CreateDeletePreviousUpdatesFromAccUsageInterval (const long &arAcctID) 
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__DELETE_PREVIOUS_UPDATES_FROM_AUI__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arAcctID ;
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
      "MTUsageCycle::CreateDeletePreviousUpdatesFromAccUsageInterval", 
      "Unable to create __DELETE_PREVIOUS_UPDATES_FROM_AUI__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
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
wstring MTUsageCycle::CreateInsertUsageIntervalQuery (
      const wchar_t *apStartDate, const wchar_t *apEndDate,const long &arUsageCycleID) 
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__INSERT_USAGE_INTERVAL__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  apStartDate ;
    mpQueryAdapter->AddParam (MTPARAM_STARTDATE, vtParam) ;
    vtParam =  apEndDate ;
    mpQueryAdapter->AddParam (MTPARAM_ENDDATE, vtParam) ;
    vtParam =  (long) arUsageCycleID ;
    mpQueryAdapter->AddParam (MTPARAM_CYCLEID, vtParam) ;

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
      "MTUsageInterval::CreateInsertUsageIntervalQuery", 
      "Unable to create __INSERT_USAGE_INTERVALS__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
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
wstring MTUsageCycle::CreateFindUsageIntervalQuery (const wchar_t *apStartDate, 
																										const wchar_t *apEndDate,
																										const long &arCycleID) 
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__FIND_USAGE_INTERVAL__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  apStartDate ;
    mpQueryAdapter->AddParam (MTPARAM_STARTDATE, vtParam) ;
    vtParam =  apEndDate ;
    mpQueryAdapter->AddParam (MTPARAM_ENDDATE, vtParam) ;
    vtParam =  arCycleID ;
    mpQueryAdapter->AddParam (MTPARAM_CYCLEID, vtParam) ;

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
      "MTUsageCycle::CreateFindUsageIntervalQuery", 
      "Unable to create __FIND_USAGE_INTERVAL__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
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
wstring MTUsageCycle::CreateInsertToAccountUsageCycleQuery (const long &arAcctID, 
																														const long &arCycleID)
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__INSERT_ACCOUNT_USAGE_CYCLE__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam =  (long) arCycleID ;
    mpQueryAdapter->AddParam (MTPARAM_CYCLEID, vtParam) ;

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
      "MTUsageCycle::CreateInsertToAccountUsageCycleQuery", 
      "Unable to create __INSERT_ACCOUNT_USAGE_CYCLE__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
  }
  return wstrCmd ;
}

BOOL MTUsageCycle::CreateAndExecuteInsertToAccountUsageCycleQuery (const long &arAcctID, 
																																	 const long &arCycleID, 
																																	 ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
  BOOL bRetCode=TRUE ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    arRowset->ClearQuery() ;

    queryTag = "__INSERT_ACCOUNT_USAGE_CYCLE__" ;
    arRowset->SetQueryTag (queryTag) ;

    vtParam =  (long) arAcctID ;
    arRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam =  (long) arCycleID ;
    arRowset->AddParam (MTPARAM_CYCLEID, vtParam) ;

    arRowset->Execute() ;
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, 
      "MTUsageCycle::CreateAndExecuteInsertToAccountUsageCycleQuery", 
      "Unable to create and execute __INSERT_ACCOUNT_USAGE_CYCLE__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
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
wstring MTUsageCycle::CreateUpdateToAccountUsageCycleQuery (const long &arAcctID, 
																														const long &arCycleID)
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__UPDATE_ACCOUNT_USAGE_CYCLE__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam =  (long) arCycleID ;
    mpQueryAdapter->AddParam (MTPARAM_CYCLEID, vtParam) ;

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
      "MTUsageCycle::CreateUpdateToAccountUsageCycleQuery", 
      "Unable to create __UPDATE_ACCOUNT_USAGE_CYCLE__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
  }
  return wstrCmd ;
}

wstring MTUsageCycle::CreateUpdateAccountToIntervalMappingQuery(int aCycleID, int aIntervalID)
{
  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery();
    mpQueryAdapter->SetQueryTag("__UPDATE_ACCOUNT_TO_INTERVAL_MAPPING__");

    mpQueryAdapter->AddParam (MTPARAM_CYCLEID, (long) aCycleID);
    mpQueryAdapter->AddParam (MTPARAM_INTERVALID, (long) aIntervalID);

    return (const wchar_t *) mpQueryAdapter->GetQuery();
  }
  catch (_com_error & err)
  {
		ErrorObject * errObj = CreateErrorFromComError(err);
		SetError(errObj);
		delete errObj;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
		return L"";
  }
}


#if 0
//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL MTUsageCycle::Exists(BOOL &arExists)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring wstrCmd ;
  DBSQLRowset myRowset ;
  long nIntervalID=-1;

  // initialize arExists ...
  arExists = FALSE ;

  // if we're not initialized ...
  if (mInitialized == FALSE)
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      "MTUsageCycle::Exists") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  wstrCmd = CreateFindUsageCycleQuery (mCycleType, mDayOfMonth) ;

  // execute the query ...
  if (!DBAccess::Execute(wstrCmd, myRowset))
  {
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "Exists() failed. Unable to execute database query") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  // if we have data in the rowset ...
  while (!myRowset.AtEOF())
  {
    // get the interval id
    myRowset.GetLongValue (_variant_t(DB_CYCLE_ID), mCycleID) ;

    // move to the next record ...
    myRowset.MoveNext() ;
  }
  wstrCmd = CreateFindUsageIntervalByCycleIDQuery (mCycleID) ;

  // execute the query ...
  if (!DBAccess::Execute(wstrCmd, myRowset))
  {
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "Init() failed. Unable to execute database query") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  // if we have data in the rowset ...
  while (!myRowset.AtEOF())
  {
    // get the interval id and bucket id ... 
    myRowset.GetLongValue (_variant_t(DB_INTERVAL_ID), nIntervalID) ;

    // insert the interval id into the list ...
    mIntervalColl.insert (nIntervalID) ;
  
    // set the exists flag ...
    arExists = TRUE ;

    // move to the next record ...
    if (!myRowset.MoveNext())
    {
      SetError (myRowset.GetLastError(),
        "Exists() failed. Unable to move to next row of rowset") ;
      mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
      return FALSE ;
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
BOOL MTUsageCycle::Create(const BSTR aUsageCyclePeriodType)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring wstrCmd ;
  BOOL bExists=FALSE ;
  DBSQLRowset myRowset ;
  int nBucketID=-1 ;

  // if we're not initialized ...
  if (mInitialized == FALSE)
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      "MTUsageCycle::Create") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  // create the query to add the usage cycle to the database ...
  wstrCmd = CreateInsertUsageCycleQuery (mCycleType, mDayOfMonth, 
    aUsageCyclePeriodType) ;
  
  // execute the query ...
  if (!DBAccess::Execute(wstrCmd, myRowset))
  {
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "Create() failed. Unable to execute database query") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  // if we dont have any rows ...
  if (myRowset.GetRecordCount() == 0)
  {
    bRetCode = FALSE;
    SetError (DB_ERR_NO_ROWS, ERROR_MODULE, ERROR_LINE, 
      "Create() failed. Unable to get usage cycle id.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return bRetCode ;
  }

  // get the interval id ...
  myRowset.GetLongValue (_variant_t(DB_CYCLE_ID), mCycleID) ;

  // intialize the stored procedure ...
  if (!DBAccess::InitializeForStoredProc(L"InsertUsageCycleInfo"))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Initialization of stored procedure failed");
    return FALSE;
  }
  
  // add the parameters ...
  _variant_t vtValue = (long) mCycleType ;
  if (!DBAccess::AddParameterToStoredProc (L"id_cycle_type", MTTYPE_INTEGER, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  vtValue = (long) mDayOfMonth ;
  if (!DBAccess::AddParameterToStoredProc (L"dom", MTTYPE_INTEGER, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  vtValue = aUsageCyclePeriodType ;
  if (!DBAccess::AddParameterToStoredProc (L"period_type", MTTYPE_VARCHAR, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  if (!DBAccess::AddParameterToStoredProc (L"id_usage_cycle", MTTYPE_INTEGER, OUTPUT_PARAM))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  
  // execute the stored procedure ...
  if (!DBAccess::ExecuteStoredProc())
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to execute stored procedure.");
    return FALSE;
  }
  
  // get the parameter ...
  if (!DBAccess::GetParameterFromStoredProc (L"id_usage_cycle", vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis (LOG_ERROR, "Unable to execute stored procedure.");
    return FALSE;
  }
  mCycleID = GetIntValue (vtValue);

  return bRetCode ;
}
#endif

