/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Travis Gebhardt
* $Header$
* 
***************************************************************************/

// MTStdSemiMonthly.cpp : Implementation of CMTStdSemiMonthly
#include "StdAfx.h"
#include "MTStdUsageCycle.h"
#include "MTStdSemiMonthly.h"
#include <MTUtil.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <DBConstants.h>
#include <UsageServerConstants.h>
#include <mtglobal_msg.h>
#include <ConfigDir.h>
#include <mtcomerr.h>
#include "MTStdDaily.h"

#import <MTUsageServer.tlb> rename( "EOF", "RowsetEOF" )
using namespace MTUSAGESERVERLib;
using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTStdSemiMonthly


CMTStdSemiMonthly::CMTStdSemiMonthly()
{
  //initializes the logger
  LoggerConfigReader cfgRdr;
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[MTSemiMonthly]");
}

CMTStdSemiMonthly::~CMTStdSemiMonthly()
{
}

STDMETHODIMP CMTStdSemiMonthly::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTUsageCycle
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

STDMETHODIMP CMTStdSemiMonthly::AddAccount(long aAccountID, 
                                           ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                           long aCycleType, LPDISPATCH pRowset)
{
  HRESULT nRetVal;
  _bstr_t startDate, endDate;
  long firstDay, secondDay;
  
  //gets and validates the usage cycle properties used for this cycle
  nRetVal = GetAndValidateProperty(apUCPropColl, firstDay, secondDay);
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs(LOG_ERROR, "AddAccount() failed. Unable to get and validate properties. Error = 0x%x",
      nRetVal);
    return nRetVal;
  }
  
  try 
  {
    // get the usage server config info ...
    long nIntervalCreate=-1 ;
    GetUsageServerConfigInfo (nIntervalCreate) ;
    
    // create the interval start and end date from the day of month and
    // the current date ... we need to do this so the intervals are
    // created ahead of time ... bug 3245
    MTDate dtIntervalDate(MTDate::TODAY);
    _bstr_t intervalStartDate, intervalEndDate ;
    dtIntervalDate += nIntervalCreate ;
    CreateStartAndEndDate (dtIntervalDate, firstDay, secondDay, intervalStartDate, intervalEndDate) ;
    
    // call CreateInterval ...
    _variant_t vtDate = intervalStartDate ;
    nRetVal = CreateInterval (vtDate, apUCPropColl, aCycleType) ;
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR,
        "AddAccount() failed. Unable to create semi-monthly usage intervals. Error = 0x%x",
        nRetVal) ;
      return nRetVal ;
    }




    //initializes the usage cycle object
    MTUSAGESERVERLib::ICOMUsageCyclePtr usageCycle(MTPROGID_USAGECYCLE);
    nRetVal = usageCycle->Init(aCycleType, (MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *) apUCPropColl);
    if (!SUCCEEDED(nRetVal)) {
      mLogger.LogVarArgs(LOG_ERROR, "AddAccount() failed. Unable to initialize usage cycle. Error = 0x%x",
        nRetVal);
      return nRetVal;
    }
    
    //calculates the start and end dates based on today, firstDay and secondDay
    MTDate today(MTDate::TODAY);
    CreateStartAndEndDate(today, firstDay, secondDay, startDate, endDate);
    
    //adds the account to the account usage interval mapping table
    nRetVal = usageCycle->AddAccount(startDate, endDate, aAccountID, pRowset);
    if (!SUCCEEDED(nRetVal)) {
      mLogger.LogVarArgs(LOG_ERROR, "AddAccount() failed. Unable to add account to usage cycle. Error = 0x%x",
        nRetVal);
      return nRetVal;
    }
  }
  catch (_com_error& e)
  {
    mLogger.LogVarArgs(LOG_ERROR, "AddAccount() failed. Unable to get usage cycle. Error = %x, %s",
      e.Error(), (char*) e.Description());
    return e.Error();
  }
  
  return S_OK;
  
}

STDMETHODIMP CMTStdSemiMonthly::UpdateAccount(long aAccountID, 
                                              ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                              long aCycleType, VARIANT aDate)
{
  HRESULT nRetVal=S_OK;
  _bstr_t startDate, endDate;
  long firstDay, secondDay;
  
  //gets and validates the usage cycle properties used for this cycle
  nRetVal = GetAndValidateProperty(apUCPropColl, firstDay, secondDay);
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs(LOG_ERROR, 
      "UpdateAccount() failed. Unable to get and validate properties. Error = 0x%x",
      nRetVal);
    return nRetVal;
  }
  
  try 
  {		
    //initializes the usage cycle object
    MTUSAGESERVERLib::ICOMUsageCyclePtr usageCycle(MTPROGID_USAGECYCLE);
    nRetVal = usageCycle->Init(aCycleType, 
      (MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *) apUCPropColl);
    if (!SUCCEEDED(nRetVal)) 
    {
      mLogger.LogVarArgs(LOG_ERROR, 
        "UpdateAccount() failed. Unable to initialize usage cycle. Error = 0x%x",
        nRetVal);
      return nRetVal;
    }
    
    //calculates the start and end dates based on today, firstDay and secondDay
    MTDate today(MTDate::TODAY);
    CreateStartAndEndDate(today, firstDay, secondDay, startDate, endDate);
    
    //adds the account to the account usage interval mapping table
    nRetVal = usageCycle->UpdateAccount(startDate, endDate, aAccountID, aDate);
    if (!SUCCEEDED(nRetVal)) 
    {
      mLogger.LogVarArgs(LOG_ERROR, 
        "UpdateAccount() failed. Unable to update account usage cycle. Error = 0x%x",
        nRetVal);
      return nRetVal;
    }
  }
  catch (_com_error& e)
  {
    mLogger.LogVarArgs(LOG_ERROR, 
      "UpdateAccount() failed. Unable to get usage cycle. Error = %x, %s",
      e.Error(), (char*) e.Description());
    return e.Error();
  }
  
  return S_OK;
}

STDMETHODIMP CMTStdSemiMonthly::CreateInterval(VARIANT aDate, 
                                               ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                               long aCycleType)
{
  HRESULT nRetVal=S_OK;
  _bstr_t startDate, endDate;
  long firstDay, secondDay;
  
  //gets and validates the property
  nRetVal = GetAndValidateProperty(apUCPropColl, firstDay, secondDay);
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs (LOG_ERROR, "CreateInterval() failed. Unable to get and validate properties. Error = 0x%x",
      nRetVal);
    return nRetVal;
  }
  
  //gets the usage server creation info
  long creationDays = -1;
  GetUsageServerConfigInfo(creationDays);
  
  // for each interval creation day ... we will iterate thru the last 
  // interval creation days to make sure that the intervals are created ...
  for (int i = creationDays; i >= 0; i--) {
    
    //converts the date string or a variant date to an MTDate
    MTDate today;
    if (aDate.vt == VT_BSTR) {
      _bstr_t bstrDate= aDate.bstrVal;
      today.SetDate((char*) bstrDate);
    }
    else if (aDate.vt == VT_DATE) {
      today.SetDate(aDate.date);
    }
    
    //creates the start and end dates
    CreateStartAndEndDate(today, firstDay, secondDay, startDate, endDate);
    
    try {
      //initializes the usage cycle object
      MTUSAGESERVERLib::ICOMUsageCyclePtr usageCycle(MTPROGID_USAGECYCLE);
      nRetVal = usageCycle->Init(aCycleType, 
        (MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *) apUCPropColl);
      if (!SUCCEEDED(nRetVal)) {
        mLogger.LogVarArgs (LOG_ERROR, 
          "CreateInterval() failed. Unable to initialize usage cycle. Error = 0x%x",
          nRetVal);
        return nRetVal;
      }
      
      //creates the interval
      nRetVal = usageCycle->CreateInterval(startDate, endDate);
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR,
          "CreateInterval() failed. Unable to create usage interval. Error = 0x%x",
          nRetVal);
        return nRetVal;
      }
    }
    catch (_com_error & e) {
      nRetVal = e.Error();
      mLogger.LogVarArgs(LOG_ERROR, "CreateInterval() failed. Unable to get usage cycle. Error = %x", nRetVal);
      mLogger.LogVarArgs (LOG_ERROR, "CreateInterval() failed. Error Description = %s", (char*) e.Description());
      return nRetVal;
    }
  }
  
  return S_OK;
}


HRESULT CMTStdSemiMonthly::GetAndValidateProperty (::ICOMUsageCyclePropertyColl *apUCPropColl,
                                                   long& arFirstDay, long& arSecondDay)
{
  HRESULT nRetVal;
  _variant_t vtValue;
  
  //gets the first day from the usage cycle property collection
  try 
  {
    nRetVal = apUCPropColl->GetProperty(UCP_FIRST_DAY_OF_MONTH, &vtValue);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
  } 
  catch(_com_error& e) 
  {
    mLogger.LogVarArgs(LOG_ERROR, "COM ERROR = %s ", (char*) e.Description());
    return e.Error();
  }
  arFirstDay = vtValue.lVal;
  
  
  //gets the second day from the usage cycle property collection
  try 
  {
    nRetVal = apUCPropColl->GetProperty (UCP_SECOND_DAY_OF_MONTH, &vtValue);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
  } 
  catch(_com_error& e) 
  {
    mLogger.LogVarArgs(LOG_ERROR, "COM ERROR = %s ", (char*) e.Description());
    return e.Error();
  }
  arSecondDay = vtValue.lVal;
  
  //validates the first day and second day are in range
  if ((arFirstDay  < 1) || (arFirstDay  > (MTDate::MAX_DAYS_IN_MONTH - 1))) {
		mLogger.LogVarArgs(LOG_ERROR, "The first day must be between 1 and 30 inclusive. first day = %d", arFirstDay);
		return DB_ERR_INVALID_PARAMETER;
	}
	if ((arSecondDay < 2) || (arSecondDay > MTDate::MAX_DAYS_IN_MONTH)) {
		mLogger.LogVarArgs(LOG_ERROR, "The second day must be between 1 and 31 inclusive. second day = %d", arSecondDay);
		return DB_ERR_INVALID_PARAMETER;
	}

	//validates that the first day is less than the second day
	if (arFirstDay >= arSecondDay) {
		mLogger.LogVarArgs(LOG_ERROR,
											 "The first day must be less than the second day. "
											 "first day = %d, second day = %d", arFirstDay, arSecondDay);
		return DB_ERR_INVALID_PARAMETER;
	}
	
	return S_OK;
}

void CMTStdSemiMonthly::CreateStartAndEndDate(const MTDate &arToday, const long &arFirstDay,
                                              const long &arSecondDay, _bstr_t &arStartDate, _bstr_t &arEndDate)
{
  //The end date is firstDayOfMonth of the current month if the date is
  //between secondDayOfMonth of the previous month and firstDayOfMonth of
  //the current month. The start date is the day after secondDayOfMonth of
  //the previous month.
  //
  //The end date is secondDayOfMonth of the current month if the
  //date is between firstDayOfMonth of the current month and
  //secondDayOfMonth of the current month. The start date is the day after
  //firstDayOfMonth of the current month.
  //
  //The end date is fistDayOfMonth of the next month if the
  //date is between secondDayOfMonth of the current month and
  //firstDayOfMonth of the next month. The start date is the day after
  //secondDayOfMonth of the current month.
  
  MTDate endDate = arToday;
  MTDate startDate = arToday;
  
  endDate.SetDay(arFirstDay);
  //handles last month's day2 to this month's day1 interval
  if (arToday <= endDate) { 
    startDate.SubtractMonth();
    startDate.SetDay(arSecondDay);
    startDate++;
  } else {
    endDate.SetDay(arSecondDay);
    //handles this month's day1 to this month's day2 interval
    if (arToday <= endDate) {
      startDate.SetDay(arFirstDay);
      startDate++;
    } else {
      //handles this month's day2 to next month's day1 interval
      startDate.SetDay(arSecondDay);
      startDate++;
      endDate.AddMonth();
      endDate.SetDay(arFirstDay);
    }
  }
  
  //copies the start and end dates to bstrs
  string startStr, endStr;
  startDate.ToString(STD_DATE_FORMAT, startStr);
  endDate.ToString(STD_DATE_FORMAT, endStr);
  arStartDate = startStr.c_str();
  arEndDate   = endStr.c_str();
}


//taken from MTStdDaily 
BOOL CMTStdSemiMonthly::GetUsageServerConfigInfo(long &arIntervalCreate)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HRESULT nRetVal=S_OK ;
  wchar_t wstrTempNum[64] ;
  string configDir ;
  _bstr_t bstrConfigDir ;
  _bstr_t errMsg ;
  MTConfigLib::IMTConfigPropSet *pPropSet=NULL ;
  
  // get the MT config dir ...
  GetMTConfigDir (configDir) ;
  arIntervalCreate = 0 ;
  
  try
  {
    // create the config com object ...
    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    MTConfigLib::IMTConfigPropSetPtr propset ;
    VARIANT_BOOL flag;
    
    // create the configuration file  to read ...
    bstrConfigDir = configDir.c_str() ;
    bstrConfigDir += "\\UsageServer\\usageserver.xml" ;
    
    // read the configuration ...
    propset = config->ReadConfiguration(bstrConfigDir, &flag);
    
    MTConfigLib::IMTConfigPropSetPtr usSet = 
      propset->NextSetWithName("usageserver_config");
    
    // get the usage server config info ...
    arIntervalCreate = usSet->NextLongWithName("interval_create") ;
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    errMsg = L"Unable to get usage server config info. Error = " ;
    errMsg += _itow (nRetVal, wstrTempNum, 10) ;
    errMsg += L". Error Description = " ;
    errMsg += e.Description() ;
    errMsg += L"." ;
    mLogger.LogVarArgs (LOG_ERROR, (char*)errMsg) ;
  }
  return bRetCode ;
}

STDMETHODIMP CMTStdSemiMonthly::ComputeStartAndEndDate(DATE aReferenceDate,
																										::ICOMUsageCyclePropertyColl *apProperties,
																										DATE *arStartDate,
																										DATE *arEndDate)
{
	HRESULT nRetVal;

	try {
		//retrieves and validates the specific properties this adapter is interested in 
		long dayOfMonth, dayOfMonth2;	
		nRetVal = GetAndValidateProperty(apProperties, dayOfMonth, dayOfMonth2);
		if (!SUCCEEDED(nRetVal))
			return nRetVal;
		
		//calculates the start and end dates given the reference date
		MTDate referenceDate(aReferenceDate);
		_bstr_t bstrStartDate, bstrEndDate;
		CreateStartAndEndDate(referenceDate,
													dayOfMonth, 
													dayOfMonth2,
													bstrStartDate,
													bstrEndDate);
		
		MTDate startDate((char*) bstrStartDate);
		MTDate endDate((char*) bstrEndDate);
		startDate.GetOLEDate(arStartDate);
		endDate.GetOLEDate(arEndDate);
	} catch (_com_error& err) {
		return ReturnComError(err);
	}
	

	return S_OK;
}
