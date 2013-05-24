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

// MTStdWeekly.cpp : Implementation of CMTStdWeekly
#include "StdAfx.h"
#include "MTStdUsageCycle.h"
#include "MTStdWeekly.h"
#include <MTUtil.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <DBConstants.h>
#include <UsageServerConstants.h>
#include <mtglobal_msg.h>
#include <mtcomerr.h>

#import <MTUsageServer.tlb> rename( "EOF", "RowsetEOF" )
using namespace MTUSAGESERVERLib;
using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTStdWeekly


CMTStdWeekly::CMTStdWeekly()
{
  //initializes the logger
  LoggerConfigReader cfgRdr;
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[MTWeekly]");
}

CMTStdWeekly::~CMTStdWeekly()
{
}

STDMETHODIMP CMTStdWeekly::InterfaceSupportsErrorInfo(REFIID riid)
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

STDMETHODIMP CMTStdWeekly::AddAccount(long aAccountID, 
                                     ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                     long aCycleType, LPDISPATCH pRowset)
{
	HRESULT nRetVal;
  _bstr_t startDate, endDate;
  long weekday;

  //gets and validates the usage cycle properties used for this cycle
  nRetVal = GetAndValidateProperty(apUCPropColl, weekday);
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs(LOG_ERROR, "AddAccount() failed. Unable to get and validate day of week property. Error = 0x%x",
											 nRetVal);
    return nRetVal;
  }

  try 
  {	
		MTDate today(MTDate::TODAY);

		//creates an interval in advance based on tomorrow's date.
		//this solves the GMT metering bug (CR4340)
		MTDate tomorrow = today + 1;
		DATE dtTomorrow;
		tomorrow.GetOLEDate(&dtTomorrow);	
    nRetVal = CreateInterval(_variant_t(dtTomorrow, VT_DATE), apUCPropColl, aCycleType);
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR,
        "AddAccount() failed. Unable to create advance weekly usage interval. Error = 0x%x",
        nRetVal) ;
      return nRetVal ;
    }

    //initializes the usage cycle object
    MTUSAGESERVERLib::ICOMUsageCyclePtr usageCycle(MTPROGID_USAGECYCLE);
    nRetVal = usageCycle->Init(aCycleType, (MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *) apUCPropColl);
    if (!SUCCEEDED(nRetVal)) 
    {
      mLogger.LogVarArgs(LOG_ERROR, "AddAccount() failed. Unable to initialize usage cycle. Error = 0x%x",
												 nRetVal);
			return nRetVal;
    }

		//calculates the start and end dates based on the today and the weekday
		CreateStartAndEndDate(today, weekday, startDate, endDate);
		
		//adds the account to the account usage interval mapping table
		nRetVal = usageCycle->AddAccount(startDate, endDate, aAccountID, pRowset);
		if (!SUCCEEDED(nRetVal)) 
    {
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

STDMETHODIMP CMTStdWeekly::UpdateAccount(long aAccountID, 
                                        ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                        long aCycleType, VARIANT aDate)
{
	HRESULT nRetVal;
  _bstr_t startDate, endDate;
  long weekday;

  //gets and validates the usage cycle properties used for this cycle
  nRetVal = GetAndValidateProperty(apUCPropColl, weekday);
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs(LOG_ERROR, 
      "UpdateAccount() failed. Unable to get and validate day of week property. Error = 0x%x",
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

		//calculates the start and end dates based on the today and the weekday
		MTDate today(MTDate::TODAY);
		CreateStartAndEndDate(today, weekday, startDate, endDate);
		
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

STDMETHODIMP CMTStdWeekly::CreateInterval(VARIANT aDate, 
                                         ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                         long aCycleType)
{
  HRESULT nRetVal=S_OK;
  _bstr_t startDate, endDate;
  long weekday;

  //gets and validates the property
  nRetVal = GetAndValidateProperty(apUCPropColl, weekday);
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs (LOG_ERROR, "CreateInterval() failed. Unable to get and validate day of week property. Error = 0x%x",
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
	CreateStartAndEndDate(today, weekday, startDate, endDate);

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

  return S_OK;
}


HRESULT CMTStdWeekly::GetAndValidateProperty (::ICOMUsageCyclePropertyColl *apUCPropColl,
                                               long &arWeekday)
{
  HRESULT nRetVal;
  _variant_t vtValue;

  try {

    //gets the day of week from the usage cycle property collection
    nRetVal = apUCPropColl->GetProperty (UCP_DAY_OF_WEEK, &vtValue);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;

  } catch(_com_error& e) {
		mLogger.LogVarArgs(LOG_ERROR, "COM ERROR = %s ", (char*) e.Description());
    return e.Error();
  }

  //validates the day of week
  arWeekday = vtValue.lVal;
  if ((arWeekday < 1) || (arWeekday > 7))
  {
    nRetVal = DB_ERR_INVALID_PARAMETER;
    mLogger.LogVarArgs (LOG_ERROR, "The day of week is out of range. weekday = %d", arWeekday);
    return DB_ERR_INVALID_PARAMETER;
  }
	
  return S_OK;
}

void CMTStdWeekly::CreateStartAndEndDate(const MTDate &arToday, const long &arWeekday,
																				 _bstr_t &arStartDate, _bstr_t &arEndDate)
{

	//The end date is the date of the next occurence of the day of week passed in.
	//The start date can be calculated by taking the end date and subtracting 6. 
	MTDate endDate = arToday;
	endDate.NextWeekday(arWeekday);
	MTDate startDate = endDate - 6;
 
  //copies the start and end dates to bstrs
	string startStr, endStr;
  startDate.ToString(STD_DATE_FORMAT, startStr);
  endDate.ToString(STD_DATE_FORMAT, endStr);
	arStartDate = startStr.c_str();
	arEndDate   = endStr.c_str();
}


STDMETHODIMP CMTStdWeekly::ComputeStartAndEndDate(DATE aReferenceDate,
																										::ICOMUsageCyclePropertyColl *apProperties,
																										DATE *arStartDate,
																										DATE *arEndDate)
{
	HRESULT nRetVal;

	try {
		//retrieves and validates the specific properties this adapter is interested in 
		long weekday;	
		nRetVal = GetAndValidateProperty(apProperties, weekday);
		if (!SUCCEEDED(nRetVal))
			return nRetVal;
		
		//calculates the start and end dates given the reference date
		MTDate referenceDate(aReferenceDate);
		_bstr_t bstrStartDate, bstrEndDate;
		CreateStartAndEndDate(referenceDate,
													weekday, 
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
