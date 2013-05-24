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

// MTStdOnDemand.cpp : Implementation of CMTStdOnDemand
#include "StdAfx.h"
#include "MTStdUsageCycle.h"
#include "MTStdOnDemand.h"
#include <loggerconfig.h>
#include <mtprogids.h>
#include <MTUtil.h>
#include <mtglobal_msg.h>
#include <DBConstants.h>
#include "MTStdDaily.h"

#import <MTUsageServer.tlb> rename( "EOF", "RowsetEOF" )
using namespace MTUSAGESERVERLib ;
using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTStdOnDemand

CMTStdOnDemand::CMTStdOnDemand()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[MTOnDemand]") ;
}

CMTStdOnDemand::~CMTStdOnDemand()
{
}



STDMETHODIMP CMTStdOnDemand::InterfaceSupportsErrorInfo(REFIID riid)
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

STDMETHODIMP CMTStdOnDemand::AddAccount(long aAccountID, 
                                        ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                       long aCycleType, LPDISPATCH pRowset)
{
	HRESULT nRetVal = S_OK ;
  _bstr_t startDate, endDate ;
  VARIANT_BOOL bEOF=FALSE, bExists=FALSE ;
  _variant_t vtEOF, vtExists ;

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
      CreateStartAndEndDate (dtIntervalDate, intervalStartDate, intervalEndDate) ;
      
      // call CreateInterval ...
      _variant_t vtDate = intervalStartDate ;
      nRetVal = CreateInterval (vtDate, apUCPropColl, aCycleType) ;
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR,
          "AddAccount() failed. Unable to create on-demand usage intervals. Error = 0x%x",
          nRetVal) ;
        return nRetVal ;
      }

      // create the start and end date from the day of month and
      // the current date ...
      MTDate dtCurrDate(MTDate::TODAY);
      CreateStartAndEndDate (dtCurrDate, startDate, endDate) ;
      
      // add the account to the account to usage cycle mapping table ...
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
  }

  return nRetVal;
}

STDMETHODIMP CMTStdOnDemand::UpdateAccount(long aAccountID, 
                                           ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                           long aCycleType, VARIANT aDate)
{
	HRESULT nRetVal = S_OK ;
  _bstr_t startDate, endDate ;
  VARIANT_BOOL bEOF=FALSE, bExists=FALSE ;
  _variant_t vtEOF, vtExists ;

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
      // create the interval start and end date from the day of month and
      // the current date ... 
      MTDate dtCurrentDate(MTDate::TODAY);
      CreateStartAndEndDate (dtCurrentDate, startDate, endDate) ;
      
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

  return nRetVal;
}

STDMETHODIMP CMTStdOnDemand::CreateInterval(VARIANT aDate, 
                                            ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                            long aCycleType)
{
  HRESULT nRetVal=S_OK ;
  _bstr_t startDate, endDate ;
  _variant_t vtExists ;
  BOOL bExists=FALSE ;

  if (aDate.vt == VT_BSTR)
  {
    // convert the date string to MTDate 
    _bstr_t bstrDate= aDate.bstrVal ;
    MTDate dtCurrDate((char*)bstrDate) ;

    // create the start and end dates ...
    CreateStartAndEndDate(dtCurrDate, startDate, endDate) ;
  }
  else if (aDate.vt == VT_DATE)
  {
    //converts variant date to MTDate
    MTDate dtCurrDate(aDate.date);
    
    // create the start and end dates ...
    CreateStartAndEndDate(dtCurrDate, startDate, endDate) ;
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

void CMTStdOnDemand::CreateStartAndEndDate (const MTDate &arToday, _bstr_t &arStartDate, _bstr_t &arEndDate)
{
  int nMonth = arToday.GetMonth();
  int nYear = arToday.GetYear();
  
  //creates the start date beginning on the 1st of the current month
  MTDate startDate(nMonth, 1, nYear);
  
  //creates the new end date ending on the last day of the current month
  MTDate endDate(nMonth, MTDate::END_OF_MONTH, nYear);
 

  //copies the start and end dates to bstrs
	string startStr, endStr;
  startDate.ToString(STD_DATE_FORMAT, startStr);
  endDate.ToString(STD_DATE_FORMAT, endStr);
	arStartDate = startStr.c_str();
	arEndDate   = endStr.c_str();
}

STDMETHODIMP CMTStdOnDemand::ComputeStartAndEndDate(DATE aReferenceDate,
																										::ICOMUsageCyclePropertyColl *apProperties,
																										DATE *arStartDate,
																										DATE *arEndDate)
{
	return E_NOTIMPL;
}

