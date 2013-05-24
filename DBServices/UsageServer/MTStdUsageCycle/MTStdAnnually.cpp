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

// MTStdAnnually.cpp : Implementation of CMTStdAnnually
#include "StdAfx.h"
#include "MTStdUsageCycle.h"
#include "MTStdAnnually.h"
#include <MTUtil.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <DBConstants.h>
#include <UsageServerConstants.h>
#include <mtglobal_msg.h>

#import <MTUsageServer.tlb> rename( "EOF", "RowsetEOF" )
using namespace MTUSAGESERVERLib;
using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTStdAnnually

CMTStdAnnually::CMTStdAnnually()
{
  //initializes the logger
  LoggerConfigReader cfgRdr;
  mLogger.Init(cfgRdr.ReadConfiguration("UsageServer"), "[MTAnnually]");
}

CMTStdAnnually::~CMTStdAnnually()
{
}

STDMETHODIMP CMTStdAnnually::InterfaceSupportsErrorInfo(REFIID riid)
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

STDMETHODIMP CMTStdAnnually::AddAccount(long aAccountID, 
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
    //initializes the usage cycle object
    MTUSAGESERVERLib::ICOMUsageCyclePtr usageCycle(MTPROGID_USAGECYCLE);
    nRetVal = usageCycle->Init(aCycleType, (MTUSAGESERVERLib::ICOMUsageCyclePropertyColl *) apUCPropColl);
    if (!SUCCEEDED(nRetVal)) 
    {
      mLogger.LogVarArgs(LOG_ERROR, "AddAccount() failed. Unable to initialize usage cycle. Error = 0x%x",
												 nRetVal);
			return nRetVal;
    }

		//calculates the start and end dates based on today, firstDay and secondDay
		MTDate today(MTDate::TODAY);
		CreateStartAndEndDate(today, month, day, startDate, endDate);
		
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

STDMETHODIMP CMTStdAnnually::UpdateAccount(long aAccountID, 
                                        ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                        long aCycleType, VARIANT aDate)
{
	HRESULT nRetVal = S_OK ;
  _bstr_t startDate, endDate ;
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
    else
    {
      //calculates the start and end dates based on today, firstDay and secondDay
      MTDate today(MTDate::TODAY);
      CreateStartAndEndDate(today, month, day, startDate, endDate);
      
      // add the account to the account to usage interval mapping table ...
      nRetVal = usageCycle->UpdateAccount(startDate, endDate, aAccountID, aDate) ;
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
  return nRetVal ;
}

STDMETHODIMP CMTStdAnnually::CreateInterval(VARIANT aDate, 
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
  if (aDate.vt == VT_BSTR) {
    _bstr_t bstrDate= aDate.bstrVal;
    today.SetDate((char*) bstrDate);
  }
  else if (aDate.vt == VT_DATE) {
    today.SetDate(aDate.date);
  }

	//creates the start and end dates
	CreateStartAndEndDate(today, month, day, startDate, endDate);

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


HRESULT CMTStdAnnually::GetAndValidateProperty (::ICOMUsageCyclePropertyColl *apUCPropColl,
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
    nRetVal = apUCPropColl->GetProperty (UCP_START_DAY, &vtValue);
    if (!SUCCEEDED(nRetVal))
      return nRetVal;
  } catch(_com_error& e) {
		mLogger.LogVarArgs(LOG_ERROR, "COM ERROR = %s ", (char*) e.Description());
    return e.Error();
  }
  arDay = vtValue.lVal;

  //validates the first day and second day
  if ((arMonth  < 1) || (arMonth  > 12) ||
			(arDay < 1) || (arDay > MTDate::GetDaysInMonth(arMonth, 1999))) //we don't care about leap year so a fixed year is ok
	{
    nRetVal = DB_ERR_INVALID_PARAMETER;
    mLogger.LogVarArgs (LOG_ERROR, "The month or day property is invalid. Month = %d, Day = %d",
												arMonth, arDay);
    return DB_ERR_INVALID_PARAMETER;
  }
	
  return S_OK;
}

void CMTStdAnnually::CreateStartAndEndDate(const MTDate &arToday, const long &arMonth,
																					 const long &arDay, _bstr_t &arStartDate, _bstr_t &arEndDate)
{
	MTDate startDate(arMonth, arDay, arToday.GetYear());
	MTDate endDate = startDate - 1;
	
	if (arToday >= startDate)
		endDate.AddYear();
	else
		startDate.SubtractYear();

  //copies the start and end dates to bstrs
	string startStr, endStr;
  startDate.ToString(STD_DATE_FORMAT, startStr);
  endDate.ToString(STD_DATE_FORMAT, endStr);
	arStartDate = startStr.c_str();
	arEndDate   = endStr.c_str();
}

STDMETHODIMP CMTStdAnnually::ComputeStartAndEndDate(DATE aReferenceDate,
																										::ICOMUsageCyclePropertyColl *apProperties,
																										DATE *arStartDate,
																										DATE *arEndDate)
{
	HRESULT nRetVal;

	//retrieves and validates the specific properties this adapter is interested in 
	long month, day;	
	nRetVal = GetAndValidateProperty(apProperties, month, day);
	if (!SUCCEEDED(nRetVal))
		return nRetVal;
 	
	//calculates the start and end dates given the reference date
	MTDate referenceDate(aReferenceDate);
	_bstr_t bstrStartDate, bstrEndDate;
	CreateStartAndEndDate(referenceDate,
												month,
												day,
												bstrStartDate,
												bstrEndDate);

	MTDate startDate((char*) bstrStartDate);
	MTDate endDate((char*) bstrEndDate);
	startDate.GetOLEDate(arStartDate);
	endDate.GetOLEDate(arEndDate);

	return S_OK;
}
