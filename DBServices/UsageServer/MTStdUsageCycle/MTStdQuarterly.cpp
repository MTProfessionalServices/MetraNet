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

// MTStdQuarterly.cpp : Implementation of CMTStdQuarterly
#include "StdAfx.h"
#include "MTStdUsageCycle.h"
#include "MTStdQuarterly.h"
#include <MTUtil.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <DBConstants.h>
#include <UsageServerConstants.h>
#include <mtglobal_msg.h>
#include <mtcomerr.h>
#include "MTStdDaily.h"

#import <MTUsageServer.tlb> rename( "EOF", "RowsetEOF" )
using namespace MTUSAGESERVERLib ;
using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTStdQuarterly

CMTStdQuarterly::CMTStdQuarterly()
{
  //initializes the logger
  LoggerConfigReader cfgRdr;
  mLogger.Init(cfgRdr.ReadConfiguration("UsageServer"), "[MTStdQuarterly]");
}

CMTStdQuarterly::~CMTStdQuarterly()
{
}

STDMETHODIMP CMTStdQuarterly::InterfaceSupportsErrorInfo(REFIID riid)
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

STDMETHODIMP CMTStdQuarterly::AddAccount(long aAccountID, 
                                         ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                         long aCycleType, LPDISPATCH pRowset)
{
  HRESULT nRetVal;
  _bstr_t startDate, endDate;
  long month, day;
  
  //gets and validates the usage cycle properties used for this cycle
  nRetVal = GetAndValidateProperty(apUCPropColl, month, day);
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
		CreateStartAndEndDate (dtIntervalDate, month, day, intervalStartDate, intervalEndDate, apUCPropColl) ;
    
    // call CreateInterval ...
		_variant_t vtDate = intervalStartDate ;
		nRetVal = CreateInterval (vtDate, apUCPropColl, aCycleType) ;
		if (!SUCCEEDED(nRetVal))
		{
			mLogger.LogVarArgs (LOG_ERROR,
													"AddAccount() failed. Unable to create quarterly usage intervals. Error = 0x%x",
													nRetVal) ;
			return nRetVal ;
		}
		

    //calculates the start and end dates based on the start month and day 
		MTDate today(MTDate::TODAY);
    nRetVal = CreateStartAndEndDate(today, month, day, startDate, endDate, apUCPropColl);
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

STDMETHODIMP CMTStdQuarterly::UpdateAccount(long aAccountID, 
                                            ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                            long aCycleType, VARIANT aDate)
{
  HRESULT nRetVal=S_OK;
  _bstr_t startDate, endDate;
  long month, day;
  
  //gets and validates the usage cycle properties used for this cycle
  nRetVal = GetAndValidateProperty(apUCPropColl, month, day);
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs(LOG_ERROR, 
      "UpdateAccount() failed. Unable to get and validate properties. Error = 0x%x",
      nRetVal);
    return nRetVal;
  }
  
  try 
  {		
    //calculates the start and end dates based on today, month and day
    MTDate today(MTDate::TODAY);
    CreateStartAndEndDate(today, month, day, startDate, endDate, apUCPropColl);

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

STDMETHODIMP CMTStdQuarterly::CreateInterval(VARIANT aDate, 
                                             ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                             long aCycleType)
{
  HRESULT nRetVal=S_OK;
  _bstr_t startDate, endDate;
  long month, day;
  
  //gets and validates the property
  nRetVal = GetAndValidateProperty(apUCPropColl, month, day);
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs (LOG_ERROR, "CreateInterval() failed. Unable to get and validate properties. Error = 0x%x",
      nRetVal);
    return nRetVal;
  }
  
  //converts the date string or a variant date to an MTDate
  MTDate today;
  if (aDate.vt == VT_BSTR) 
  {
    _bstr_t bstrDate= aDate.bstrVal;
    today.SetDate((char*) bstrDate);
  }
  else if (aDate.vt == VT_DATE) 
  {
    today.SetDate(aDate.date);
  }
  
  //creates the start and end dates
  nRetVal = CreateStartAndEndDate(today, month, day, startDate, endDate, apUCPropColl);
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
    
    //creates the new interval
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


HRESULT CMTStdQuarterly::GetAndValidateProperty (::ICOMUsageCyclePropertyColl *apUCPropColl,
                                                 long& arMonth, long& arDay)
{
  HRESULT nRetVal;
  _variant_t vtValue;
  
  //gets the month from the usage cycle property collection
  try {
    nRetVal = apUCPropColl->GetProperty(UCP_START_MONTH, &vtValue);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
  } catch(_com_error& e) {
    mLogger.LogVarArgs(LOG_ERROR, "COM ERROR = %s ", (char*) e.Description());
    return e.Error();
  }
  arMonth = vtValue.lVal;
  
  
  //gets the day from the usage cycle property collection
  try {
    nRetVal = apUCPropColl->GetProperty(UCP_START_DAY, &vtValue);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
  } catch(_com_error& e) {
    mLogger.LogVarArgs(LOG_ERROR, "COM ERROR = %s ", (char*) e.Description());
    return e.Error();
  }
  arDay = vtValue.lVal;
  
  //validates the month property
  if ((arMonth  < 1) || (arMonth  > 12)) {
    mLogger.LogVarArgs(LOG_ERROR, "The start month property is not in the range of [1 - 12]. StartMonth = %d", arMonth);
    return DB_ERR_INVALID_PARAMETER;
  }
		
	//validates the day property
	if ((arDay  < 1) || (arDay  > MTDate::MAX_DAYS_IN_MONTH)) { 
    mLogger.LogVarArgs(LOG_ERROR, "The start day property is not in the range of [1 - 31]. StartDay = %d", arDay);
    return DB_ERR_INVALID_PARAMETER;
  }
  
  return S_OK;
}

HRESULT CMTStdQuarterly::CreateStartAndEndDate(const MTDate &arToday, const long &arMonth,
                                               const long &arDay, _bstr_t &arStartDate, _bstr_t &arEndDate,
                                               ::ICOMUsageCyclePropertyColl *apUCPropColl)
{
  HRESULT nRetVal;
  //The start date is calculated in the following manner. The current
  //month is subtracted from firstMonth. If this number is < 0 then
  //add 12 to it. This number represents the amount of months that have
  //passed by since the start of the first quarter. Dividing this by 3
  //gives the current quarter (0, 1, 2, 3). If this divides evenly then we
  //must check the day of month. So if the number modulus 3 equals 0 then
  //we check the day. If the current day of month is < firstDay,
  //then subtract 1 to the calculated quarter.
  // 
  //Now we have enough information to calculate the start date and end
  //date of a quarter. The start date is the date specified by
  //firstDay/firstMonth plus 3 times the current quarter in months. The
  //end date is the start date plus 3 months minus 1 day.
  
  //Care must be taken to correctly wrap day, month and year values
  //(i.e. if month > 13 then month = 1). Note that quarter can be -1 in
  //the last calculation.
  
	long day = arDay;

	//constructs the start date with the day passed in
  MTDate startDate(arMonth, day, arToday.GetYear());
  
  //how many months have passed since the beginning
  //of the given fiscal year
  int offset = arToday.GetMonth() - arMonth;

	//if the start month has not been reached, then assume it is in the past (last year)
  if (offset < 0) {
    offset += 12;
		startDate.SubtractYear();
  }

  //deduces the quarter.  We need to figure out what arDay is for this month.  
  //  E.g. if arDay is 29, but this month is Feb, we need to do our calculations with 28.
  long tempDay = min(arToday.GetDaysInMonth(), (int)day); 
  int quarter = offset / 3;
  if ((offset % 3 == 0) && (arToday.GetDay() < tempDay))
    quarter--;


  //the start date of the interval
  startDate.AddMonth(3 * quarter);
  //Correct for weirdness in adding 3 months -- 2/28 + 3 months might actually be 5/31
  startDate.SetDay(min(startDate.GetDaysInMonth(), (int)day));
  
	//the end date of the interval (3 months after the start date)
  MTDate endDate = startDate;
  endDate.AddMonth(3);
  //Correct for weirdness in adding 3 months -- 2/28 + 3 months might actually be 5/31
  endDate.SetDay(min(endDate.GetDaysInMonth(), (int)day));
  endDate--;
  
//   mLogger.LogVarArgs (LOG_DEBUG, 
//											"*** startmonth=%d, startday=%d, offset=%d, quarter=%d, istartmonth=%d, iendmonth=%d",
//											arMonth, arDay, offset, quarter, startDate.GetMonth(), endDate.GetMonth());
  
  //modifies the start month property to be between January and March (1-3)
  try {

		//Month: 1  2  3  4  5  6  7  8  9 10 11 12
		//mod%3: 1  2  0  1  2  0  1  2  0 1  2  0
    int startMonth = startDate.GetMonth() % 3;

		//corrects for the startMonth's that are zero
		//mod%3: 1  2  0  1  2  0  1  2  0  1  2  0
		//final: 1  2  3  1  2  3  1  2  3  1  2  3
		if (startMonth == 0)
			startMonth = 3;
		_variant_t vtValue = (long) startMonth;
    nRetVal = apUCPropColl->ModifyProperty(UCP_START_MONTH, vtValue);
    if (!SUCCEEDED(nRetVal)) {
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to modify start month property. Error = 0x%x",
        nRetVal);
      return nRetVal;
    }
  } catch(_com_error& e) {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to modify start month property. Error = 0x%x: %s",
      (char*)e.Description());
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

STDMETHODIMP CMTStdQuarterly::ComputeStartAndEndDate(DATE aReferenceDate,
																										::ICOMUsageCyclePropertyColl *apProperties,
																										DATE *arStartDate,
																										DATE *arEndDate)
{
	HRESULT nRetVal;

	try {
		//retrieves and validates the specific properties this adapter is interested in 
		long month, day;	
		nRetVal = GetAndValidateProperty(apProperties, month, day);
		if (!SUCCEEDED(nRetVal))
			return nRetVal;
		
		//calculates the start and end dates given the reference date
		MTDate referenceDate(aReferenceDate);
		_bstr_t bstrStartDate, bstrEndDate;
		nRetVal = CreateStartAndEndDate(referenceDate,
																		month, 
																		day,
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
