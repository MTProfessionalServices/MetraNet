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
* Created by: Kevin Fitzgerald
* $Header$
* 
***************************************************************************/

// MTStdMonthly.cpp : Implementation of CMTStdMonthly
#include "StdAfx.h"
#include "MTStdUsageCycle.h"
#include "MTStdMonthly.h"
#include <loggerconfig.h>
#include <mtprogids.h>
#include <MTUtil.h>
#include <mtglobal_msg.h>
#include <DBConstants.h>
#include <UsageServerConstants.h>
#include <mtparamnames.h>
#include <DataAccessDefs.h>
#include <mtcomerr.h>

#include "MTStdDaily.h"

#import <MTUsageServer.tlb> rename( "EOF", "RowsetEOF" )
using namespace MTUSAGESERVERLib;
using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTStdMonthly

CMTStdMonthly::CMTStdMonthly()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[MTMonthly]") ;
}

CMTStdMonthly::~CMTStdMonthly()
{
}

STDMETHODIMP CMTStdMonthly::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTUsageCycle,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTStdMonthly::GetAndValidateProperty (::ICOMUsageCyclePropertyColl *apUCPropColl,
                                               long &arDayOfMonth)
{
  HRESULT nRetVal=S_OK ;
  _variant_t vtValue ;

  try
  {
    // get the day of month from the usage cycle prop collection ...
    nRetVal = apUCPropColl->GetProperty (UCP_DAY_OF_MONTH, &vtValue) ;
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "GetAndValidateProperty() failed. Unable to get day of month property. Error = 0x%x",
        nRetVal) ;
      return nRetVal ;
    }
  }
  catch(_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "GetAndValidateProperty() failed. Unable to get day of month property. Error = 0x%x",
      nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "AddAccount() failed. Error Description = %s", (char*)e.Description()) ;
    return nRetVal ;
  }
  // validate the day of month ...
  arDayOfMonth = vtValue.lVal ;
  if ((arDayOfMonth < 1) || (arDayOfMonth > MTDate::MAX_DAYS_IN_MONTH))
  {
    nRetVal = DB_ERR_INVALID_PARAMETER ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "GetAndValidateProperty() failed. Invalid day of month. Day of Month = %d. Error = 0x%x",
      arDayOfMonth, nRetVal) ;
    arDayOfMonth = 0 ;
    return nRetVal ;
  }

  return S_OK ;
}

STDMETHODIMP CMTStdMonthly::AddAccount(long aAccountID, 
                                       ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                       long aCycleType, LPDISPATCH pRowset)
{
	HRESULT nRetVal = S_OK ;
  _bstr_t startDate, endDate ;
  VARIANT_BOOL bEOF=FALSE, bExists=FALSE ;
  _variant_t vtEOF, vtExists ;
  long dayOfMonth=0 ;

  // get and validate the property ...
  nRetVal = GetAndValidateProperty (apUCPropColl, dayOfMonth) ;
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "AddAccount() failed. Unable to get and validate day of month property. Error = 0x%x",
      nRetVal) ;
    return nRetVal ;
  }

  try
  {
    // initialize the usage cycle object ...
    MTUSAGESERVERLib::ICOMUsageCyclePtr usageCycle(MTPROGID_USAGECYCLE) ;
    nRetVal = usageCycle->Init(aCycleType, 
      (MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *) apUCPropColl) ;
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "AddAccount() failed. Unable to initialize usage cycle. Error = 0x%x",
        nRetVal) ;
    }
    else
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
      CreateStartAndEndDate (dtIntervalDate, dayOfMonth, intervalStartDate, intervalEndDate) ;
      
      // call CreateInterval ...
      _variant_t vtDate = intervalStartDate ;
      nRetVal = CreateInterval (vtDate, apUCPropColl, aCycleType) ;
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR,
          "AddAccount() failed. Unable to create monthly usage intervals. Error = 0x%x",
          nRetVal) ;
        return nRetVal ;
      }

      // create the start and end date from the day of month and
      // the current date ...
      MTDate dtCurrDate(MTDate::TODAY) ;
      CreateStartAndEndDate (dtCurrDate, dayOfMonth, startDate, endDate) ;
      
      // add the account ...
      nRetVal = usageCycle->AddAccount(startDate, endDate, aAccountID, pRowset) ;
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR,
          "AddAccount() failed. Unable to add account to usage cycle. Error = 0x%x",
          nRetVal) ;
      }
    }
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "AddAccount() failed. Unable to get usage cycle. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "AddAccount() failed. Error Description = %s",
      (char*) e.Description()) ;
    return nRetVal ;
  }
  return nRetVal;
}

STDMETHODIMP CMTStdMonthly::UpdateAccount(long aAccountID, 
                                          ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                          long aCycleType, VARIANT aCurrentIntervalEndDate)
{
	HRESULT nRetVal = S_OK ;
  _bstr_t startDate, endDate ;
  VARIANT_BOOL bEOF=FALSE, bExists=FALSE ;
  _variant_t vtEOF, vtExists ;
  long dayOfMonth=0 ;

  // get and validate the property ...
  nRetVal = GetAndValidateProperty (apUCPropColl, dayOfMonth) ;
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "UpdateAccount() failed. Unable to get and validate day of month property. Error = 0x%x",
      nRetVal) ;
    return nRetVal ;
  }

  try
  {
    // initialize the usage cycle object ...
    MTUSAGESERVERLib::ICOMUsageCyclePtr usageCycle(MTPROGID_USAGECYCLE) ;
    nRetVal = usageCycle->Init(aCycleType, 
      (MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *) apUCPropColl) ;
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "UpdateAccount() failed. Unable to initialize usage cycle. Error = 0x%x",
        nRetVal) ;
    }
    // if we havent hit an error yet ...
    if (SUCCEEDED(nRetVal))
    {
      // create the start and end date from the day of month and
      // the current date ...
      MTDate dtCurrDate(MTDate::TODAY) ;
      CreateStartAndEndDate (dtCurrDate, dayOfMonth, startDate, endDate) ;

      // update the account ...
      nRetVal = usageCycle->UpdateAccount(startDate, endDate, aAccountID, aCurrentIntervalEndDate) ;
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR,
          "UpdateAccount() failed. Unable to update account usage cycle. Error = 0x%x",
          nRetVal) ;
      }
    }
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "UpdateAccount() failed. Unable to get usage cycle. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "UpdateAccount() failed. Error Description = %s",
      (char*) e.Description()) ;
  }

  return nRetVal;
}

STDMETHODIMP CMTStdMonthly::CreateInterval(VARIANT aDate, 
                                           ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                           long aCycleType)
{
  HRESULT nRetVal=S_OK ;
  _bstr_t startDate, endDate ;
  long dayOfMonth=0 ;

  //gets and validates the property
  nRetVal = GetAndValidateProperty (apUCPropColl, dayOfMonth) ;
  if (!SUCCEEDED(nRetVal))
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "CreateInterval() failed. Unable to get and validate day of month property. Error = 0x%x",
      nRetVal) ;
    return nRetVal ;
  }

  if (aDate.vt == VT_BSTR)
  {
    //converts the date string to an MTDate 
    _bstr_t bstrDate= aDate.bstrVal ;
    MTDate dtCurrDate ((char*)bstrDate) ;

    //creates the start and end dates
    CreateStartAndEndDate (dtCurrDate, dayOfMonth, startDate, endDate) ;
  }
  else if (aDate.vt == VT_DATE)
  {
    // convert variant dates to MTDate's ...
    MTDate dtCurrDate(aDate.date) ;
    
    // create the start and end dates ...
    CreateStartAndEndDate (dtCurrDate, dayOfMonth, startDate, endDate) ;
  }
  try
  {
    // initialize the usage cycle object ...
    MTUSAGESERVERLib::ICOMUsageCyclePtr usageCycle(MTPROGID_USAGECYCLE) ;
    nRetVal = usageCycle->Init(aCycleType, 
      (MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *) apUCPropColl) ;
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "CreateInterval() failed. Unable to initialize usage cycle. Error = 0x%x",
        nRetVal) ;
    }
    else
    {
      // create the interval ...
      nRetVal = usageCycle->CreateInterval(startDate, endDate) ;
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR,
          "CreateInterval() failed. Unable to create usage interval. Error = 0x%x",
          nRetVal) ;
      }
    }
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "CreateInterval() failed. Unable to get usage cycle. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "CreateInterval() failed. Error Description = %s",
      (char*) e.Description()) ;
  }

  return nRetVal ;
}

void CMTStdMonthly::CreateStartAndEndDate (const MTDate &arToday, const long &arDayOfMonth,
																					 _bstr_t &arStartDate, _bstr_t &arEndDate)
{

	//sets the endDate to the closing day of the current month
	MTDate endDate = arToday;
  endDate.SetDay(arDayOfMonth);

	//sets the starting day to the closing day.
	MTDate startDate = endDate;

	//if we are before the closing day then we just need to
	//  rewind the starting date by a month.
  //Otherwise the starting date is fine and we need to fast foward 
  //  the ending date ahead one month
	if (arToday <= endDate) {
		startDate.SubtractMonth();
    startDate.SetDay(arDayOfMonth);
  }
	else{
		endDate.AddMonth();
  }

  //Now move the start day forward one day so that there's no overlap with the previous cycle.
  startDate++;

  //copies the start and end dates to bstrs
	string startStr, endStr;
  startDate.ToString(STD_DATE_FORMAT, startStr);
  endDate.ToString(STD_DATE_FORMAT, endStr);
	arStartDate = startStr.c_str();
	arEndDate   = endStr.c_str();
}


STDMETHODIMP CMTStdMonthly::ComputeStartAndEndDate(DATE aReferenceDate,
																										::ICOMUsageCyclePropertyColl *apProperties,
																										DATE *arStartDate,
																										DATE *arEndDate)
{
	HRESULT nRetVal;

	try {
		//retrieves and validates the specific properties this adapter is interested in 
		long dayOfMonth;	
		nRetVal = GetAndValidateProperty(apProperties, dayOfMonth);
		if (!SUCCEEDED(nRetVal))
			return nRetVal;
		
		//calculates the start and end dates given the reference date
		MTDate referenceDate(aReferenceDate);
		_bstr_t bstrStartDate, bstrEndDate;
		CreateStartAndEndDate(referenceDate,
													dayOfMonth, 
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
