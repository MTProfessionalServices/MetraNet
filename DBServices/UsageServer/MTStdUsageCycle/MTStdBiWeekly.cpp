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

// MTStdBiWeekly.cpp : Implementation of CMTStdBiWeekly
#include "StdAfx.h"
#include "MTStdUsageCycle.h"
#include "MTStdBiWeekly.h"
#include <MTUtil.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <DBConstants.h>
#include <UsageServerConstants.h>
#include <mtglobal_msg.h>
#include <mtcomerr.h>

#include "MTStdDaily.h"


#import <MTUsageServer.tlb> rename( "EOF", "RowsetEOF" )
using namespace MTUSAGESERVERLib;
using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTStdBiWeekly

CMTStdBiWeekly::CMTStdBiWeekly()
{
  //initializes the logger
  LoggerConfigReader cfgRdr;
  mLogger.Init(cfgRdr.ReadConfiguration("UsageServer"), "[MTStdBiWeekly]");
}

CMTStdBiWeekly::~CMTStdBiWeekly()
{
}

STDMETHODIMP CMTStdBiWeekly::InterfaceSupportsErrorInfo(REFIID riid)
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

STDMETHODIMP CMTStdBiWeekly::AddAccount(long aAccountID, 
                                        ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                        long aCycleType, LPDISPATCH pRowset)
{
  HRESULT nRetVal;
  _bstr_t startDate, endDate;
  long month, day, year;
  
  //gets and validates the usage cycle properties used for this cycle
  nRetVal = GetAndValidateProperty(apUCPropColl, month, day, year);
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
    // the current date ... we need to do this so the daily intervals are
    // created ahead of time ... bug 3245
    MTDate dtIntervalDate(MTDate::TODAY);
    _bstr_t intervalStartDate, intervalEndDate ;
    dtIntervalDate += nIntervalCreate ;
    nRetVal = CreateStartAndEndDate(dtIntervalDate, month, day, year, 
      intervalStartDate, intervalEndDate, apUCPropColl);
    if (!SUCCEEDED(nRetVal)) 
    {
      mLogger.LogVarArgs(LOG_ERROR, 
        "AddAccount() failed. Unable to create start and end dates. Error = 0x%x",
        nRetVal);
      return nRetVal;
    }
    
    // call CreateInterval ...
    _variant_t vtDate = intervalStartDate ;
    nRetVal = CreateInterval (vtDate, apUCPropColl, aCycleType) ;
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR,
        "AddAccount() failed. Unable to create biweekly usage intervals. Error = 0x%x",
        nRetVal) ;
      return nRetVal ;
    }

    //calculates the start and end dates based on today, firstDay and secondDay
    MTDate today(MTDate::TODAY);
    nRetVal = CreateStartAndEndDate(today, month, day, year, startDate, endDate, apUCPropColl);
    if (!SUCCEEDED(nRetVal)) 
    {
      mLogger.LogVarArgs(LOG_ERROR, 
        "AddAccount() failed. Unable to create start and end dates. Error = 0x%x",
        nRetVal);
      return nRetVal;
    }
    
    //initializes the usage cycle object
    MTUSAGESERVERLib::ICOMUsageCyclePtr usageCycle(MTPROGID_USAGECYCLE);
    nRetVal = usageCycle->Init(aCycleType, (MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *) apUCPropColl);
    if (!SUCCEEDED(nRetVal)) 
    {
      mLogger.LogVarArgs(LOG_ERROR, 
        "AddAccount() failed. Unable to initialize usage cycle. Error = 0x%x",
        nRetVal);
      return nRetVal;
    }

    //adds the account to the account usage interval mapping table
    nRetVal = usageCycle->AddAccount(startDate, endDate, aAccountID, pRowset);
    if (!SUCCEEDED(nRetVal)) 
    {
      mLogger.LogVarArgs(LOG_ERROR, 
        "AddAccount() failed. Unable to add account to usage cycle. Error = 0x%x",
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

STDMETHODIMP CMTStdBiWeekly::UpdateAccount(long aAccountID, 
                                           ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                           long aCycleType, VARIANT aDate)
{
  HRESULT nRetVal;
  _bstr_t startDate, endDate;
  long month, day, year;
  
  //gets and validates the usage cycle properties used for this cycle
  nRetVal = GetAndValidateProperty(apUCPropColl, month, day, year);
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs(LOG_ERROR, 
      "UpdateAccount() failed. Unable to get and validate properties. Error = 0x%x",
      nRetVal);
    return nRetVal;
  }
  
  try 
  {		
    //calculates the start and end dates based on today, firstDay and secondDay
    MTDate today(MTDate::TODAY);
    CreateStartAndEndDate(today, month, day, year, startDate, endDate, apUCPropColl);

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

STDMETHODIMP CMTStdBiWeekly::CreateInterval(VARIANT aDate, 
                                            ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                            long aCycleType)
{
  HRESULT nRetVal=S_OK;
  _bstr_t startDate, endDate;
  long month, day, year;
  
  //gets and validates the property
  nRetVal = GetAndValidateProperty(apUCPropColl, month, day, year);
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs (LOG_ERROR, "CreateInterval() failed. Unable to get and validate properties. Error = 0x%x",
      nRetVal);
    return nRetVal;
  }
  
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
  nRetVal = CreateStartAndEndDate(today, month, day, year, startDate, endDate, apUCPropColl);
  if (!SUCCEEDED(nRetVal)) {
    mLogger.LogVarArgs(LOG_ERROR, "CreateInterval() failed. Unable to create start and end dates. Error = 0x%x",
      nRetVal);
    return nRetVal;
  }
  
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
    mLogger.LogVarArgs(LOG_ERROR, "CreateInterval() failed. Error Description = %s", (char*) e.Description());
    return nRetVal;
  }
  
  return S_OK;
}


HRESULT CMTStdBiWeekly::GetAndValidateProperty (::ICOMUsageCyclePropertyColl *apUCPropColl,
                                                long& arMonth, long& arDay, long& arYear)
{
  HRESULT nRetVal;
  _variant_t vtValue;
  
  
  try {
    //gets the month from the usage cycle property collection
    nRetVal = apUCPropColl->GetProperty(UCP_START_MONTH, &vtValue);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    arMonth = vtValue.lVal;
    
    //gets the day from the usage cycle property collection
    nRetVal = apUCPropColl->GetProperty(UCP_START_DAY, &vtValue);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    arDay = vtValue.lVal;
    
    //gets the year from the usage cycle property collection
    nRetVal = apUCPropColl->GetProperty(UCP_START_YEAR, &vtValue);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
    arYear = vtValue.lVal;
    
  } catch(_com_error& e) {
    mLogger.LogVarArgs(LOG_ERROR, "COM ERROR = %s ", (char*) e.Description());
    return e.Error();
  }
  
  //validates the day, month, and year
  if ((arMonth  < 1) || (arMonth  > 12) ||
    (arYear < 1970) || (arYear > 2037) ||
    (arDay < 1) || (arDay > MTDate::GetDaysInMonth(arMonth, arYear)))
  {
    nRetVal = DB_ERR_INVALID_PARAMETER;
    mLogger.LogVarArgs (LOG_ERROR, "The month, day, or year property is invalid. Month = %d, Day = %d, Year = %d",
      arMonth, arDay, arYear);
    return DB_ERR_INVALID_PARAMETER;
  }
  
  return S_OK;
}

HRESULT CMTStdBiWeekly::CreateStartAndEndDate(const MTDate &arToday, const long &arMonth,
                                              const long &arDay, const long &arYear, 
                                              _bstr_t &arStartDate, _bstr_t &arEndDate, 
                                              ::ICOMUsageCyclePropertyColl *apUCPropColl)
{
  HRESULT nRetVal;
  
  MTDate reference(arMonth, arDay, arYear);
  time_t referenceTime = reference.GetSecondsSinceEpoch();
  time_t todayTime     = arToday.GetSecondsSinceEpoch();
  time_t diff          = todayTime - referenceTime;
  long   intervals     = (long) (diff / (MTDate::SECONDS_IN_DAY * 14));
  time_t startTime     = referenceTime + (intervals * (MTDate::SECONDS_IN_DAY * 14));
  
  MTDate startDate(startTime);
  if (!startDate.IsValid()) {
    mLogger.LogVarArgs(LOG_ERROR, "startDate is invalid!");
    return E_FAIL;
  }
  MTDate endDate = startDate + 13;
  
  
  //WARNING! This date should always correspond to the Queries.xml insert statements
  reference.SetDate(1, 1, 2000);
  
  referenceTime = reference.GetSecondsSinceEpoch();
  diff          = startTime - referenceTime;
  long cycle    = ((diff / MTDate::SECONDS_IN_DAY) % 14) + 1;  //1 - 14
  
  //TODO: remove this!!!
  //mLogger.LogVarArgs(LOG_DEBUG, "*** pstartmonth=%d, pstartday=%d, intervals=%d, istartday=%d, iendday=%d, cycle=%d",
  //									 arToday.GetMonth(),
  //									 arToday.GetDay(),
  //									 intervals,
  //									 startDate.GetDay(),
  //									 endDate.GetDay(),
  //									 cycle);
  
  
  //modifies the start month property to be 1, the year to be 1999 and the day to be between 1 - 14
  try {
    int startMonth = reference.GetMonth();
    _variant_t vtValue = (long) startMonth;
    nRetVal = apUCPropColl->ModifyProperty(UCP_START_MONTH, vtValue);
    if (!SUCCEEDED(nRetVal)) {
      mLogger.LogVarArgs (LOG_ERROR, "Unable to modify start month property. Error = 0x%x", nRetVal);
      return nRetVal;
    }
    int startDay = cycle;
    vtValue = (long) startDay;
    nRetVal = apUCPropColl->ModifyProperty(UCP_START_DAY, vtValue);
    if (!SUCCEEDED(nRetVal)) {
      mLogger.LogVarArgs (LOG_ERROR, "Unable to modify start day property. Error = 0x%x", nRetVal);
      return nRetVal;
    }
    int startYear = reference.GetYear();
    vtValue = (long) startYear;
    nRetVal = apUCPropColl->ModifyProperty(UCP_START_YEAR, vtValue);
    if (!SUCCEEDED(nRetVal)) {
      mLogger.LogVarArgs (LOG_ERROR, "Unable to modify start year property. Error = 0x%x", nRetVal);
      return nRetVal;
    }
  } catch(_com_error& e) {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to modify start month, day or year property. Error = 0x%x: %s", (char*)e.Description());
    return nRetVal;
  }
  
  //copies the start and end dates to bstrs
  string startStr, endStr;
  startDate.ToString(STD_DATE_FORMAT, startStr);
  endDate.ToString(STD_DATE_FORMAT, endStr);
  arStartDate = startStr.c_str();
  arEndDate   = endStr.c_str();
  
  return S_OK;
}


STDMETHODIMP CMTStdBiWeekly::ComputeStartAndEndDate(DATE aReferenceDate,
																										::ICOMUsageCyclePropertyColl *apProperties,
																										DATE *arStartDate,
																										DATE *arEndDate)
{
	HRESULT nRetVal;
	
	try {
		//retrieves and validates the specific properties this adapter is interested in 
		long month, day, year;	
		nRetVal = GetAndValidateProperty(apProperties, month, day, year);
		if (!SUCCEEDED(nRetVal))
			return nRetVal;
		
		//calculates the start and end dates given the reference date
		MTDate referenceDate(aReferenceDate);
		_bstr_t bstrStartDate, bstrEndDate;
		nRetVal = CreateStartAndEndDate(referenceDate,
																		month,
																		day,
																		year, 
																		bstrStartDate,
																		bstrEndDate, 
																		apProperties);
		
		if (!SUCCEEDED(nRetVal))
			return nRetVal;
		
		MTDate startDate((char*) bstrStartDate);
		MTDate endDate((char*) bstrEndDate);
		startDate.GetOLEDate(arStartDate);
		endDate.GetOLEDate(arEndDate);
	} catch (_com_error& err) {
		return ReturnComError(err);
	}

	return S_OK;
}




