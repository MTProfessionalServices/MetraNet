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

#include <mtcom.h>
#include <comdef.h>
#include <adoutil.h>
#include <UsageInterval.h>
#include <DBConstants.h>
#include <time.h>
#include <DBSQLRowset.h>
#include <mtparamnames.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <MTUtil.h>
#include <UsageServerConstants.h>
#include <MTDate.h>

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

// @mfunc MTUsageInterval default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// Core Kiosk Gate class
MTUsageInterval::MTUsageInterval()
: mIntervalID(-1),  mInitialized(FALSE), mIntervalLength(-1),
mpQueryAdapter (NULL)
{
	LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "UsageInterval") ;
}

// @mfunc MTUsageInterval destructor
// @parm 
// @rdesc This implementations is for the destructor of the 
// Core Kiosk Gate class
MTUsageInterval::~MTUsageInterval()
{
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
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL MTUsageInterval::Init ()
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
        SetError (DBAccess::GetLastError(), "Init() failed. Unable to initialize dbaccess layer");
        mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
        bRetCode = FALSE ;
      }
    }
    catch (_com_error e)
    {
      //SetError(e) ;
      SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "MTUsageInterval::Init", 
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
BOOL MTUsageInterval::Init(BSTR apStartDate, BSTR apEndDate)
{
	// local variables
	BOOL bRetCode = TRUE;

  // call init ...
  bRetCode = Init() ;
  if (bRetCode == FALSE)
  {
    mInitialized = FALSE ;
    return bRetCode ;
  }

  // copy parameters ...
  mStartDate = apStartDate ;
  mEndDate = apEndDate ;

  // convert the start and end date to mtdate's 
  MTDate dtStartDate((char*)mStartDate);
  MTDate dtEndDate((char*)mEndDate);

  // if the date's aren't valid ...
  if ((!dtStartDate.IsValid()) || (!dtEndDate.IsValid()))
  {
    SetError (DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "MTUsageInterval::Init", "Init() failed. Invalid start and/or end dates.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_DEBUG, 
      "Interval start date = %s. Interval end date = %s.", 
      (char*)mStartDate, (char*)mEndDate) ;
    mInitialized = FALSE ;
    return FALSE  ;
  }

  // calculate the interval length ...
  mIntervalLength = dtEndDate - dtStartDate ;

  // set the initialized flag ...
  mInitialized = TRUE ;

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL MTUsageInterval::Exists(BOOL &arExists)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring wstrCmd ;
  DBSQLRowset myRowset ;

  // initialize arExists ...
  arExists = FALSE ;

  // if we're not initialized ...
  if (mInitialized == FALSE)
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      "MTUsageInterval::Exists") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  // create the query to find the usage interval ...
  wstrCmd = CreateFindUsageIntervalQuery (mStartDate, mEndDate) ;

  // execute the query ...
  if (!DBAccess::Execute(wstrCmd, myRowset))
  {
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "Init() failed. Unable to execute database query") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  // if we have data in the rowset ...
  if (!myRowset.AtEOF())
  {
    // get the interval id
    myRowset.GetLongValue (_variant_t(DB_INTERVAL_ID), mIntervalID) ;
  
    // set the exists flag ...
    arExists = TRUE ;
  }  
  // otherwise ...
  else
  {
    // clear the exists flag ...
    arExists = FALSE ;
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
BOOL MTUsageInterval::AccountExists(const long &arAccountID, BOOL &arExists)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring wstrCmd ;
  DBSQLRowset myRowset ;

  // initialize arExists ...
  arExists = FALSE ;

  // if we're not initialized ...
  if (mInitialized == FALSE)
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      "MTUsageInterval::AccountExists") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  // create the query to find the usage interval ...
  wstrCmd = CreateFindAccountUsageIntervalQuery (arAccountID, mIntervalID) ;

  // execute the query ...
  if (!DBAccess::Execute(wstrCmd, myRowset))
  {
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "Init() failed. Unable to execute database query") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  // if we have data in the rowset ...
  if (!myRowset.AtEOF())
  {
    // set the exists flag ...
    arExists = TRUE ;
  }  
  // otherwise ...
  else
  {
    // clear the exists flag ...
    arExists = FALSE ;
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
BOOL MTUsageInterval::AddAccount(const long &arAcctID)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring wstrCmd ;

  // if we're not initialized ...
  if ((mInitialized == FALSE) || (mIntervalID == -1))
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      "MTUsageInterval::AddAcount") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    if (mIntervalID == -1)
    {
      mLogger.LogThis (LOG_DEBUG, "Unable to add account to unknown interval") ;
    }
    return FALSE ;
  }
#if 0
  // create the query to insert the account to the account usage interval table ...
  wstrCmd = CreateInsertToAccountUsageIntervalQuery (arAcctID, mIntervalID) ;

  // execute the query ...
	if (!DBAccess::Execute(wstrCmd))
	{
    bRetCode = FALSE;
    SetError (GetLastError(), 
      "AddToAccountUsageInterval() failed. Unable to execute database query") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
	}
#else
  // intialize the stored procedure ...
  if (!DBAccess::InitializeForStoredProc(L"InsertAcctToIntervalMapping"))
  {
    SetError(DBAccess::GetLastError());
	    mLogger.LogThis (LOG_ERROR, "Initialization of stored procedure failed");
		return FALSE;
  }

  // add the parameters ...
  _variant_t vtValue = (long) arAcctID ;
  if (!DBAccess::AddParameterToStoredProc (L"id_acc", MTTYPE_INTEGER, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
	    mLogger.LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
		return FALSE;
  }
  vtValue = (long) mIntervalID ;
  if (!DBAccess::AddParameterToStoredProc (L"id_interval", MTTYPE_INTEGER, INPUT_PARAM, vtValue))
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
#endif

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL MTUsageInterval::Expired (BSTR apDate, BOOL &arExpired)
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // initialize arExpired ...
  arExpired = FALSE ;

  // if we're not initialized ...
  if (mInitialized == FALSE)
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      "MTUsageInterval::Exists") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  // convert the date to a mtdate ...
  _bstr_t bstrDate = apDate ;

  MTDate dtCurrDate((char*) bstrDate);
  MTDate dtEndDate((char*) mEndDate);

  // if the date's aren't valid ...
  if ((!dtCurrDate.IsValid()) || (!dtEndDate.IsValid()))
  {
    SetError (DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "MTUsageInterval::Expired", "Expired() failed. Invalid current and/or end dates.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_DEBUG, 
      "Current date = %s. Interval end date = %s.", 
      (char*)bstrDate, (char*)mEndDate) ;
    return FALSE  ;
  }
  // check to see if the current date is > than the end date ...
  if (dtCurrDate > dtEndDate)
  {
    arExpired = TRUE ;
  }
  // otherwise ...
  else
  {
    arExpired = FALSE ;
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
wstring MTUsageInterval::CreateInsertToAccountUsageIntervalQuery (const long &arAcctID, 
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
      "MTUsageInterval::CreateInsertToAccountUsageIntervalQuery", 
      "Unable to create __INSERT_ACCOUNT_USAGE_INTERVAL__ query");
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
wstring MTUsageInterval::CreateFindUsageIntervalQuery (const wchar_t *apStartDate, 
																											 const wchar_t *apEndDate) 
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
      "MTUsageInterval::CreateFindUsageIntervalQuery", 
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
wstring MTUsageInterval::CreateFindAccountUsageIntervalQuery (const long &arAccountID, 
																															const long &arIntervalID) 
{
  wstring wstrCmd ;
  _bstr_t queryTag ;
  _variant_t vtParam ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__FIND_ACCOUNT_USAGE_INTERVAL__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam =  (long) arAccountID ;
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
      "MTUsageInterval::CreateFindAccountUsageIntervalQuery", 
      "Unable to create __FIND_ACCOUNT_USAGE_INTERVAL__ query");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
  }
  return wstrCmd ;
}


#if 1
//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL MTUsageInterval::Create()
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring wstrCmd ;
  BOOL bExists=FALSE ;
  DBSQLRowset myRowset ;

  // if we're not initialized ...
  if (mInitialized == FALSE)
  {
    SetError (DB_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      "MTUsageInterval::Create") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  // create the query to add the usage interval to the database ...
  wstrCmd = CreateInsertUsageIntervalQuery (mStartDate, mEndDate);
  
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
      "Create() failed. Unable to get usage interval id.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return bRetCode ;
  }

  // get the interval id ...
  myRowset.GetLongValue (_variant_t(DB_INTERVAL_ID), mIntervalID) ;

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
wstring MTUsageInterval::CreateInsertUsageIntervalQuery (const wchar_t *apStartDate,
																												 const wchar_t *apEndDate) 
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
#endif
