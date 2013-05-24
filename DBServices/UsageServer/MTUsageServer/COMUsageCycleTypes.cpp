// COMUsageCycleTypes.cpp : Implementation of CCOMUsageCycleTypes
#include "StdAfx.h"
#include <MTDate.h>
#include "MTUsageServer.h"
#include "COMUsageCycleTypes.h"
#include <mtprogids.h>
#include <DBConstants.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <DBMiscUtils.h>
#include <UsageServerConstants.h>
#include <mtparamnames.h>
#include <DBSQLRowset.h>
#include <mttime.h>
#include <formatdbvalue.h>

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <MTUsageCycle.tlb> 
using namespace MTUSAGECYCLELib ;

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageCycleTypes

CCOMUsageCycleTypes::CCOMUsageCycleTypes()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[UsageCycleTypes]") ;
}

CCOMUsageCycleTypes::~CCOMUsageCycleTypes()
{
}

STDMETHODIMP CCOMUsageCycleTypes::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMUsageCycleTypes,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CCOMUsageCycleTypes::AddAccount(long AccountID, 
                                             ::ICOMUsageCyclePropertyColl *apPropColl, 
                                             LPDISPATCH pRowset)
{
  HRESULT nRetVal=S_OK ;
  _bstr_t progID ;
  long UsageCycleTypeID ;
  _variant_t vtIndex ;
  _variant_t vtValue ;
  _bstr_t bstrProgID ;

  // if we're initialized ...
  if (mpRowset != NULL)
  {
    try
    {
      // get the cycle type and prog id from the rowset ...
      vtIndex = DB_CYCLE_TYPE_ID ;
      mpRowset->GetValue (vtIndex, vtValue) ;
      UsageCycleTypeID = vtValue.lVal ;
      vtIndex = DB_PROGID ;
      mpRowset->GetValue (vtIndex,vtValue) ;
      bstrProgID = vtValue.bstrVal ;
      // create the usage cycle com object ...
      MTUSAGECYCLELib::IMTUsageCyclePtr pUsageCycle ((LPCSTR)((char*)bstrProgID)) ;

      // call AddAccount on the COM object ...
      nRetVal = pUsageCycle->AddAccount (AccountID, 
        (MTUSAGECYCLELib::ICOMUsageCyclePropertyColl *)apPropColl, UsageCycleTypeID, pRowset) ;
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR,
          "AddAccount() failed. Unable to add account to usage cycle. Error = 0x%x",
          nRetVal) ;
        return Error ("Unable to add account to usage cycle.", 
          IID_ICOMUsageCycleTypes, nRetVal) ;
      }
    }
    catch (_com_error e)
    {
      nRetVal = e.Error() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "AddAccount() failed. Unable to add account to usage cycle. Error = %x", nRetVal) ;
      mLogger.LogVarArgs (LOG_ERROR, "AddAccount() failed. Error Description = %s",
        (char*) e.Description()) ;
      return Error ("Unable to add account to usage cycle. Caught error.", 
        IID_ICOMUsageCycleTypes, nRetVal) ;
    }
  }
  else
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "AddAccount() failed. Rowset not initialized.") ;
    nRetVal = DB_ERR_NOT_INITIALIZED ;
    return Error ("Unable to add account. No rowset.", 
      IID_ICOMUsageCycleTypes, nRetVal) ;
  }

  return nRetVal ;
}

STDMETHODIMP CCOMUsageCycleTypes::AccountNeedsUpdate(long AccountID, 
																										 ::ICOMUsageCyclePropertyColl *apPropColl,
																										 VARIANT_BOOL * apNeedsUpdate)
{
  HRESULT nRetVal=S_OK ;
  _bstr_t progID ;
  long UsageCycleTypeID ;
  _variant_t vtIndex ;
  _variant_t vtValue, vtParam ;
  wchar_t wstrTempNum[64] ;
  _bstr_t bstrProgID ;
  _variant_t vtDate ;
  long dayOfMonth=0 ;
  long dayOfWeek=0 ;
  long firstDOM=0, secondDOM=0 ;
  long startDay=0, startMonth=0;
  long startYear=0 ;
  BOOL bUpdatingAccount=FALSE;
  wstring wstrQueryExt ;

  // if we're initialized ...
  if (mpRowset != NULL)
  {
    try
    {
      // get the cycle type and prog id from the rowset ...
      vtIndex = DB_CYCLE_TYPE_ID ;
      mpRowset->GetValue (vtIndex,vtValue) ;
      UsageCycleTypeID = vtValue.lVal ;
      vtIndex = DB_PROGID ;
      mpRowset->GetValue (vtIndex,vtValue) ;
      bstrProgID = vtValue.bstrVal ;
    }
    catch (_com_error e)
    {
      nRetVal = e.Error() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "UpdateAccount() failed. Unable to get cycle type and prog id. Error = %x", nRetVal) ;
      mLogger.LogVarArgs (LOG_ERROR, "UpdateAccount() failed. Error Description = %s",
        (char*) e.Description()) ;
      return Error ("Unable to get cycle type and prog id. Caught error.", 
        IID_ICOMUsageCycleTypes, nRetVal) ;
    }

    // switch on the cycle type ...
    switch (UsageCycleTypeID)
    {
    case UC_MONTHLY:
      // get the day of month out of the property collection ...
      apPropColl->GetProperty (UCP_DAY_OF_MONTH, &vtValue) ;
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
      apPropColl->GetProperty (UCP_DAY_OF_WEEK, &vtValue) ;

      // get the day of month ...
      dayOfWeek = vtValue.lVal ;
      
      // create the where clause for the query to get the cycle id ...
      wstrQueryExt = L" and day_of_week = " ;
      wstrQueryExt += _itow (dayOfWeek, wstrTempNum, 10) ;
      break ;
      
    case UC_BI_WEEKLY:
      // get the start day out of the property collection ...
      apPropColl->GetProperty (UCP_START_DAY, &vtValue) ;
      startDay = vtValue.lVal ;
      
      // create the where clause for the query to get the cycle id ...
      wstrQueryExt = L" and start_day = " ;
      wstrQueryExt += _itow (startDay, wstrTempNum, 10) ;
      
      // get the start month out of the property collection ...
      apPropColl->GetProperty (UCP_START_MONTH, &vtValue) ;
      startMonth = vtValue.lVal ;
      
      // create the where clause for the query to get the cycle id ...
      wstrQueryExt += L" and start_month = " ;
      wstrQueryExt += _itow (startMonth, wstrTempNum, 10) ;
      
      // get the start year out of the property collection ...
      apPropColl->GetProperty (UCP_START_YEAR, &vtValue) ;
      startYear = vtValue.lVal ;
      
      // create the where clause for the query to get the cycle id ...
      wstrQueryExt += L" and start_year = " ;
      wstrQueryExt += _itow (startYear, wstrTempNum, 10) ;
      
      break ;
      
    case UC_SEMI_MONTHLY:
      // get the first day of month out of the property collection ...
      apPropColl->GetProperty (UCP_FIRST_DAY_OF_MONTH, &vtValue) ;
      firstDOM = vtValue.lVal ;
      
      // create the where clause for the query to get the cycle id ...
      wstrQueryExt += L" and first_day_of_month = " ;
      wstrQueryExt += _itow (firstDOM, wstrTempNum, 10) ;
      
      // get the second day of month out of the property collection ...
      apPropColl->GetProperty (UCP_SECOND_DAY_OF_MONTH, &vtValue) ;
      secondDOM = vtValue.lVal ;
      
      // create the where clause for the query to get the cycle id ...
      wstrQueryExt += L" and second_day_of_month = " ;
      wstrQueryExt += _itow (secondDOM, wstrTempNum, 10) ;
      
      break ;
      
    case UC_QUARTERLY:
    case UC_SEMIANNUALLY:
    case UC_ANNUALLY:
      // get the start day out of the property collection ...
      apPropColl->GetProperty (UCP_START_DAY, &vtValue) ;
      startDay = vtValue.lVal ;
      
      // create the where clause for the query to get the cycle id ...
      wstrQueryExt = L" and start_day = " ;
      wstrQueryExt += _itow (startDay, wstrTempNum, 10) ;
      
      // get the start month out of the property collection ...
      apPropColl->GetProperty (UCP_START_MONTH, &vtValue) ;
      startMonth = vtValue.lVal ;
      
      // create the where clause for the query to get the cycle id ...
      wstrQueryExt += L" and start_month = " ;
      wstrQueryExt += _itow (startMonth, wstrTempNum, 10) ;
      break ;
      
    default:
      bUpdatingAccount = TRUE ;      
      break ;
    }

    try
    {
      // get the usage interval end date for the account ...
			ROWSETLib::IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET) ;
      
      // initialize the rowset ...
      _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
      pRowset->Init(configPath) ;

      if (bUpdatingAccount == FALSE)
      {
        pRowset->SetQueryTag("__FIND_USAGE_CYCLE_BY_ACCOUNT__") ;
        
        vtParam =  (long) UsageCycleTypeID ;
        pRowset->AddParam (MTPARAM_CYCLETYPE, vtParam) ;
        vtParam =  (long) AccountID;
        pRowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
        vtParam =  wstrQueryExt.c_str() ;
        pRowset->AddParam (MTPARAM_EXT, vtParam) ;
        
        pRowset->Execute() ;
        
        _variant_t vtEOF = pRowset->GetRowsetEOF() ;
        
        if (vtEOF.boolVal == VARIANT_TRUE)
        {
          bUpdatingAccount = TRUE ;
        }
      }
    }
    catch (_com_error e)
    {
      nRetVal = e.Error() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "UpdateAccount() failed. Unable to get usage interval end date. Error = %x", nRetVal) ;
      mLogger.LogVarArgs (LOG_ERROR, "UpdateAccount() failed. Error Description = %s",
        (char*) e.Description()) ;
      return Error ("Unable to get usage interval end date. Caught error.", 
        IID_ICOMUsageCycleTypes, nRetVal) ;
    }

		// return it to the user
		*apNeedsUpdate = bUpdatingAccount ? VARIANT_TRUE : VARIANT_FALSE;
  }
  else
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "UpdateAccount() failed. Rowset not initialized.") ;
    nRetVal = DB_ERR_NOT_INITIALIZED ;
    return Error ("Unable to add account. No rowset.", 
      IID_ICOMUsageCycleTypes, nRetVal) ;
  }

  return nRetVal ;
}


STDMETHODIMP CCOMUsageCycleTypes::UpdateAccount(long AccountID, 
                                                ::ICOMUsageCyclePropertyColl *apPropColl)
{
  HRESULT nRetVal=S_OK ;
  _bstr_t progID ;
  long UsageCycleTypeID ;
  _variant_t vtIndex ;
  _variant_t vtValue, vtParam ;
  _bstr_t bstrProgID ;
  _variant_t vtDate ;

	VARIANT_BOOL needsUpdate;
	HRESULT hr = AccountNeedsUpdate(AccountID, apPropColl, &needsUpdate);
	if (FAILED(hr))
		return hr;

	if (needsUpdate != VARIANT_TRUE)
		return S_OK;								// nothing to do

  // if we're initialized ...
  if (mpRowset != NULL)
  {
    try
    {
      // get the cycle type and prog id from the rowset ...
      vtIndex = DB_CYCLE_TYPE_ID ;
      mpRowset->GetValue (vtIndex,vtValue) ;
      UsageCycleTypeID = vtValue.lVal ;
      vtIndex = DB_PROGID ;
      mpRowset->GetValue (vtIndex,vtValue) ;
      bstrProgID = vtValue.bstrVal ;
    }
    catch (_com_error e)
    {
      nRetVal = e.Error() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "UpdateAccount() failed. Unable to get cycle type and prog id. Error = %x", nRetVal) ;
      mLogger.LogVarArgs (LOG_ERROR, "UpdateAccount() failed. Error Description = %s",
        (char*) e.Description()) ;
      return Error ("Unable to get cycle type and prog id. Caught error.", 
        IID_ICOMUsageCycleTypes, nRetVal) ;
    }


    try
    {
      // get the usage interval end date for the account ...
			ROWSETLib::IMTSQLRowsetPtr pRowset(MTPROGID_SQLROWSET) ;
      

      // initialize the rowset ...
      _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
      pRowset->Init(configPath) ;

      // set the query tag ...
      pRowset->SetQueryTag(L"__GET_INTERVAL_END_DATE__") ;
      
      // add the account id ...
      vtValue = AccountID ;
      pRowset->AddParam (MTPARAM_ACCOUNTID, vtValue) ;
      
			_variant_t currentTime = GetMTOLETime();
			std::wstring buffer;
			FormatValueForDB(currentTime, FALSE, buffer);
			pRowset->AddParam (L"%%UTCDATE%%", buffer.c_str(), true);

      // execute the query ...
      pRowset->Execute() ;
      
      // get the date ...
      vtValue = L"EndDate" ;
      vtDate = pRowset->GetValue(vtValue) ;

			//fixes the overlapping interval problem by adding one to the end date
			MTDate endDate(string((const char*) (_bstr_t) vtDate));
			endDate++;
			string dateTmp;
			endDate.ToString(STD_DATE_FORMAT, dateTmp);
			vtDate = dateTmp.c_str();

    }
    catch (_com_error e)
    {
      nRetVal = e.Error() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "UpdateAccount() failed. Unable to get usage interval end date. Error = %x", nRetVal) ;
      mLogger.LogVarArgs (LOG_ERROR, "UpdateAccount() failed. Error Description = %s",
        (char*) e.Description()) ;
      return Error ("Unable to get usage interval end date. Caught error.", 
        IID_ICOMUsageCycleTypes, nRetVal) ;
    }

		try
		{
			// create the usage cycle com object ...
			MTUSAGECYCLELib::IMTUsageCyclePtr pUsageCycle ((LPCSTR)((char*)bstrProgID)) ;
        
        // call CreateInterval to make sure the interval's are created ...
			nRetVal = pUsageCycle->CreateInterval (vtDate, 
																						 (MTUSAGECYCLELib::ICOMUsageCyclePropertyColl *)apPropColl, UsageCycleTypeID) ;
			if (!SUCCEEDED(nRetVal))
			{
				mLogger.LogVarArgs (LOG_ERROR,
														"UpdateAccount() failed. Unable to create interval. Error = 0x%x",
														nRetVal) ;
				return Error ("Unable to create interval.", 
											IID_ICOMUsageCycleTypes, nRetVal) ;
			}
			// call UpdateAccount on the COM object ...
			nRetVal = pUsageCycle->UpdateAccount (AccountID, 
																						(MTUSAGECYCLELib::ICOMUsageCyclePropertyColl *)apPropColl, UsageCycleTypeID, vtDate) ;
			if (!SUCCEEDED(nRetVal))
			{
				mLogger.LogVarArgs (LOG_ERROR,
														"UpdateAccount() failed. Unable to update account to usage cycle. Error = 0x%x",
														nRetVal) ;
				return Error ("Unable to add account to usage cycle.", 
											IID_ICOMUsageCycleTypes, nRetVal) ;
			}
		}
		catch (_com_error e)
		{
			nRetVal = e.Error() ;
			mLogger.LogVarArgs (LOG_ERROR,  
													"UpdateAccount() failed. Unable to update account's usage cycle. Error = %x", nRetVal) ;
			mLogger.LogVarArgs (LOG_ERROR, "UpdateAccount() failed. Error Description = %s",
													(char*) e.Description()) ;
			return Error ("Unable to update account's usage cycle. Caught error.", 
										IID_ICOMUsageCycleTypes, nRetVal) ;
		}
	}
  else
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "UpdateAccount() failed. Rowset not initialized.") ;
    nRetVal = DB_ERR_NOT_INITIALIZED ;
    return Error ("Unable to add account. No rowset.", 
      IID_ICOMUsageCycleTypes, nRetVal) ;
  }

  return nRetVal ;
}


STDMETHODIMP CCOMUsageCycleTypes::Init()
{
 	HRESULT nRetVal = S_OK ;
  BOOL bRetCode=TRUE ;

  try
  {
		if(mpRowset) delete mpRowset;
		mpRowset = new DBSQLRowset;
    // create the queryadapter ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    
    // initialize the rowset ...
    _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
    rowset->Init(configPath) ;
    
    // set the query tag ...
    _bstr_t queryTag = "__GET_USAGE_CYCLE_TYPES__" ;
    rowset->SetQueryTag (queryTag) ;
    
    // execute the query ...
    rowset->Execute() ;

    // if we have more than one record ... detach the com object ...
    if (rowset->GetRecordCount() > 0)
    {
      // detach the allocated COM object ...
	    mpRowset->PutRecordSet(_RecordsetPtr(IDispatchPtr(rowset->GetPopulatedRecordSet())));
    }
  }    
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get usage cycle types query. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to usage cycle types query.", 
      IID_ICOMUsageCycleTypes, nRetVal) ;
    bRetCode = FALSE ;
  }

  return nRetVal ;
}

