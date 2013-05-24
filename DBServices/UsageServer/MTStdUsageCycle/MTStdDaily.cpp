// MTStdDaily.cpp : Implementation of CMTStdDaily
#include "StdAfx.h"
#include "MTStdUsageCycle.h"
#include "MTStdDaily.h"
#include <loggerconfig.h>
#include <mtprogids.h>
#include <MTUtil.h>
#include <mtglobal_msg.h>
#include <DBConstants.h>
#include <mtcomerr.h>
#include <ConfigDir.h>

#import <MTUsageServer.tlb> rename( "EOF", "RowsetEOF" )
using namespace MTUSAGESERVERLib ;
using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTStdDaily

CMTStdDaily::CMTStdDaily()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[MTDaily]") ;
}

CMTStdDaily::~CMTStdDaily()
{
}

STDMETHODIMP CMTStdDaily::InterfaceSupportsErrorInfo(REFIID riid)
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


STDMETHODIMP CMTStdDaily::AddAccount(long aAccountID, 
                                     ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                     long aCycleType, LPDISPATCH pRowset)
{
	HRESULT nRetVal = S_OK ;
  _bstr_t startDate, endDate ;
  long nIntervalCreate=-1 ;

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
      GetUsageServerConfigInfo (nIntervalCreate) ;

      // create the interval start and end date from the day of month and
      // the current date ... we need to do this so the daily intervals are
      // created ahead of time ... bug 3245
      MTDate dtIntervalDate(MTDate::TODAY);
      dtIntervalDate += nIntervalCreate ;
      CreateStartAndEndDate (dtIntervalDate, startDate, endDate) ;

      // call CreateInterval ...
      _variant_t vtDate = startDate ;
      nRetVal = CreateInterval (vtDate, apUCPropColl, aCycleType) ;
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR,
          "AddAccount() failed. Unable to create daily usage intervals. Error = 0x%x",
          nRetVal) ;
      }
      else
      {
        // create the interval start and end date from the day of month and
        // the current date ... 
        MTDate dtCurrentDate(MTDate::TODAY);
        CreateStartAndEndDate (dtCurrentDate, startDate, endDate) ;
        
        // add the account to the account to usage interval mapping table ...
        nRetVal = usageCycle->AddAccount(startDate, endDate, aAccountID, pRowset) ;
        if (!SUCCEEDED(nRetVal))
        {
          mLogger.LogVarArgs (LOG_ERROR,
            "AddAccount() failed. Unable to add account to usage cycle. Error = 0x%x",
            nRetVal) ;
        }
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

STDMETHODIMP CMTStdDaily::UpdateAccount(long aAccountID, 
                                        ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                        long aCycleType, VARIANT aDate)
{
	HRESULT nRetVal = S_OK ;
  _bstr_t startDate, endDate ;
  long nIntervalCreate=-1 ;

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
      // get the usage server config info ...
      GetUsageServerConfigInfo (nIntervalCreate) ;

      // create the interval start and end date from the day of month and
      // the current date ... we need to do this so the daily intervals are
      // created ahead of time ..
      _bstr_t dateString (aDate.bstrVal) ;
      MTDate dtIntervalDate((char*)dateString);
      dtIntervalDate += nIntervalCreate ;
      CreateStartAndEndDate (dtIntervalDate, startDate, endDate) ;

      // call CreateInterval ...
      _variant_t vtDate = startDate ;
      nRetVal = CreateInterval (vtDate, apUCPropColl, aCycleType) ;
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR,
          "AddAccount() failed. Unable to create daily usage intervals. Error = 0x%x",
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


STDMETHODIMP CMTStdDaily::CreateInterval(VARIANT aDate, 
                                         ::ICOMUsageCyclePropertyColl *apUCPropColl,
                                         long aCycleType)
{
  HRESULT nRetVal=S_OK ;
  _bstr_t startDate, endDate ;
  long nIntervalCreate=-1 ;

  // get the usage server creation info
  GetUsageServerConfigInfo (nIntervalCreate) ;

  // for each interval creation day ... we will iterate thru the last 
  // interval creation days to make sure that the intervals are created ...
  for (int i=nIntervalCreate; i >= 0; i--)
  {
    if (aDate.vt == VT_BSTR)
    {
      // convert the date string to MTDate's 
      _bstr_t bstrDate= aDate.bstrVal ;
      MTDate dtCurrDate ((char*)bstrDate) ;

      // subtract the day from dtCurrDate ...
      dtCurrDate -= i ;
      
      // create the start and end dates ...
      CreateStartAndEndDate (dtCurrDate, startDate, endDate) ;
    }
    else if (aDate.vt == VT_DATE)
    {
      // convert variant dates to MTDate's ...
      MTDate dtCurrDate(aDate.date);

      // subtract the day from dtCurrDate ...
      dtCurrDate -= i ;

      // create the start and end dates ...
      CreateStartAndEndDate (dtCurrDate, startDate, endDate) ;
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
  }

  return nRetVal ;
}

void CMTStdDaily::CreateStartAndEndDate (const MTDate &arToday, 
    _bstr_t &arStartDate, _bstr_t &arEndDate)
{
  //copies the start and end dates to bstr
	string startStr;
  arToday.ToString(STD_DATE_FORMAT, startStr);
	arStartDate = startStr.c_str();
	arEndDate   = arStartDate;
}

BOOL GetUsageServerConfigInfo(long &arIntervalCreate)
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
    NTLogger logger ;
    LoggerConfigReader cfgRdr ;
    
    // initialize the logger ...
    logger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[GetUsageServerInfo]") ;

    nRetVal = e.Error() ;
    errMsg = L"Unable to get usage server config info. Error = " ;
    errMsg += _itow (nRetVal, wstrTempNum, 10) ;
    errMsg += L". Error Description = " ;
    errMsg += e.Description() ;
    errMsg += L"." ;
    logger.LogVarArgs (LOG_ERROR, (char*)errMsg) ;
  }
  return bRetCode ;
}


STDMETHODIMP CMTStdDaily::ComputeStartAndEndDate(DATE aReferenceDate,
																								 ::ICOMUsageCyclePropertyColl *apProperties,
																								 DATE *arStartDate,
																								 DATE *arEndDate)
{
	try {

		MTDate referenceDate(aReferenceDate);
		_bstr_t bstrStartDate, bstrEndDate;
		
		CreateStartAndEndDate(referenceDate,
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
