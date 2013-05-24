// COMUsageIntervalColl.cpp : Implementation of CCOMUsageIntervalColl
#include "StdAfx.h"
#include "MTUsageServer.h"
#include "COMUsageIntervalColl.h"
#include <mtprogids.h>
#include <mtparamnames.h>
#include <DBConstants.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <DBUsageCycle.h>
#include <UsageInterval.h>
#include <MTUtil.h>
#include <MTDate.h>
#include <DBMiscUtils.h>
#include <UsageServerConstants.h>
#include <DBSQLRowset.h>

#undef min
#undef max

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <COMDBObjects.tlb> rename( "EOF", "RowsetEOF" )
#import <MTDataExporter.tlb> 
#import <MTUsageServer.tlb> rename( "EOF", "RowsetEOF" )
using namespace MTDATAEXPORTERLib ;

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageIntervalColl

CCOMUsageIntervalColl::CCOMUsageIntervalColl()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[UsageIntervalColl]") ;
}

CCOMUsageIntervalColl::~CCOMUsageIntervalColl()
{
}

STDMETHODIMP CCOMUsageIntervalColl::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMUsageIntervalColl,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CCOMUsageIntervalColl::get_Status(BSTR * pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CCOMUsageIntervalColl::put_Status(BSTR newVal)
{
  _variant_t vtValue, vtIndex ;
  HRESULT nRetVal=S_OK ;
  long nIntervalID=-1 ;
	ROWSETLib::IMTSQLRowsetPtr rowset ;

	try
  {
    // get the interval id ...
    vtIndex = DB_INTERVAL_ID ;
    mpRowset->GetValue (vtIndex, vtValue) ;
    nIntervalID = vtValue.lVal ;

    // create the rowset ...
    nRetVal = rowset.CreateInstance(MTPROGID_SQLROWSET);
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to create rowset. Unable to update usage interval status. Error = %x", nRetVal) ;
      return Error ("Unable to create rowset. Unable to update usage interval status.", 
        IID_ICOMUsageIntervalColl, nRetVal) ;
    }
    
    // initialize the queryadapter ...
    _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
    rowset->Init(configPath) ;

    // begin the transaction ...
    rowset->BeginTransaction() ;

    // set the query tag ...
    _bstr_t queryTag = "__UPDATE_USAGE_INTERVAL_STATUS__" ;
    rowset->SetQueryTag (queryTag) ;
    
    // set the parameter ...
    _variant_t vtParam = (long) nIntervalID ;
    rowset->AddParam (MTPARAM_INTERVALID, vtParam) ;
    vtParam = newVal ;
    rowset->AddParam (MTPARAM_STATUS, vtParam) ;

    // execute the query ...
    rowset->Execute() ;

    mLogger.LogVarArgs (LOG_DEBUG,"Changing Status of Interval %d to %s.", nIntervalID, (const char*)newVal);

    // if the status is 'E' then update the account to usage interval mapping 
    // for the interval ...
    wstring wstrStatus = newVal ;
    if (_wcsicmp(wstrStatus.c_str(), USAGE_INTERVAL_EXPIRED) == 0)
    {
      // set the query tag ...
      _bstr_t queryTag = "__UPDATE_ACCOUNT_USAGE_INTERVAL_STATUS__" ;
      rowset->SetQueryTag (queryTag) ;
      
      // set the parameter ...
      _variant_t vtParam = (long) nIntervalID ;
      rowset->AddParam (MTPARAM_INTERVALID, vtParam) ;
      
      // execute the query ...
      rowset->Execute() ;
    }
    // commit the transaction ...
    rowset->CommitTransaction() ;
  }
  catch (_com_error e)
  {
    // rollback the transaction ...
    rowset->RollbackTransaction() ;

    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to update usage interval status. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to update usage interval status.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }
  
  return nRetVal ;
}

STDMETHODIMP CCOMUsageIntervalColl::GetAccountUsageMap(LPDISPATCH * apAccountUsageMap)
{
	// local variables
  HRESULT nRetVal=S_OK ;
  _variant_t vtIndex, vtValue ;
  long nIntervalID ;

  try
  {
    // get the interval id ...
    vtIndex = DB_INTERVAL_ID ;
    mpRowset->GetValue (vtIndex,vtValue);
    nIntervalID = vtValue.lVal ;

		MTUSAGESERVERLib::ICOMAccountUsageMapPtr pCOMAccountUsageMap(__uuidof(MTUSAGESERVERLib::COMAccountUsageMap));
    pCOMAccountUsageMap->InitByIntervalID(nIntervalID);
		IDispatchPtr aTempDisp = pCOMAccountUsageMap;
		*apAccountUsageMap = aTempDisp.Detach();
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get account usage map for interval. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "GetAccountUsageMap() failed. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to get account usage map for interval.", 
        IID_ICOMUsageIntervalColl, nRetVal) ;
  }
  return nRetVal ;
}

STDMETHODIMP CCOMUsageIntervalColl::Init(BSTR aStatus)
{
 	HRESULT nRetVal = S_OK ;
  BOOL bRetCode=TRUE ;
  _bstr_t bstrStatus ;

  try
  {
    // create the queryadapter ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    
    // initialize the queryadapter ...
    _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
    rowset->Init(configPath) ;

    // if the status is null ...
    bstrStatus = aStatus ;
    if (bstrStatus.length() != 1)
    {
      // set the query tag ...
      _bstr_t queryTag = "__GET_USAGE_INTERVALS__" ;
      rowset->SetQueryTag (queryTag) ;
    }
    // otherwise ... we're getting the usage intervals of a particular 
    // status ...
    else
    {
      // set the query tag ...
      _bstr_t queryTag = "__GET_USAGE_INTERVALS_BY_STATUS__" ;
      rowset->SetQueryTag (queryTag) ;

      // set the parameter ...
      _variant_t vtParam = aStatus ;
      rowset->AddParam (MTPARAM_STATUS, vtParam) ;
    }
    
    // execute the query ...
    rowset->Execute() ;

    // detach the allocated COM object ...
		if(mpRowset) delete mpRowset;
		mpRowset = new DBSQLRowset;
    mpRowset->PutRecordSet(_RecordsetPtr(IDispatchPtr(rowset->GetPopulatedRecordSet())));
  }    
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get usage intervals by status. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to get usage interval by status.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }

  return nRetVal ;
}

STDMETHODIMP CCOMUsageIntervalColl::InitByStateAndPeriodType(BSTR aState, BSTR aPeriodType)
{
 	HRESULT nRetVal = S_OK ;
  BOOL bRetCode=TRUE ;
  _bstr_t bstrStatus ;

  try
  {
    // create the queryadapter ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    
    // initialize the queryadapter ...
    _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
    rowset->Init(configPath) ;

    // set the query tag ...
    _bstr_t queryTag = "__GET_USAGE_INTERVALS_BY_STATUS_AND_PERIOD_TYPE__" ;
    rowset->SetQueryTag (queryTag) ;
    
    // set the parameter ...
    _variant_t vtParam = aState ;
    rowset->AddParam (MTPARAM_STATUS, vtParam) ;
    vtParam = aPeriodType ;
    rowset->AddParam (MTPARAM_PERIODTYPE, vtParam) ;
    
    // execute the query ...
    rowset->Execute() ;

    // detach the allocated COM object ...
		if(mpRowset) delete mpRowset;
		mpRowset = new DBSQLRowset;
    mpRowset->PutRecordSet(_RecordsetPtr(IDispatchPtr(rowset->GetPopulatedRecordSet())));
  }    
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get usage intervals by status. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to get usage interval by status.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }

  return nRetVal ;
}


STDMETHODIMP CCOMUsageIntervalColl::ExportByTimePeriod(BSTR aExportMethod, 
                                                       VARIANT aStartDate, 
                                                       VARIANT aEndDate)
{
  long nIntervalID=-1, nAcctID=-1 ;
  ICOMAccountUsageMap *pCOMAccountUsageMap=NULL ;
	COMDBOBJECTSLib::ICOMSummaryViewPtr pSummaryView ;
  LPDISPATCH pDispatch=NULL ;
  _variant_t vtIndex, vtValue, vtEOF ;
  HRESULT nRetVal=S_OK ;
  MTDATAEXPORTERLib::IMTDataExporterPtr dataExporter ;

  // if we dont have a rowset ...
  if (mpRowset == NULL)
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to export usage data. Error = %x", nRetVal) ;
    return Error ("Unable to export usage data. No rowset.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }

  try
  {
    // get the interval id ...
    vtIndex = DB_INTERVAL_ID ;
    mpRowset->GetValue (vtIndex,vtValue) ;
    nIntervalID = vtValue.lVal ;
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to export usage data. No usage interval. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "ExportByTimePeriod() failed. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to export usage data. No usage interval.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }

  // create the GLMethod COM object ...
  try
  {
     nRetVal = dataExporter.CreateInstance (aExportMethod) ;
     if (!SUCCEEDED(nRetVal))
     {
       mLogger.LogVarArgs (LOG_ERROR,  
         "Unable to export usage data. Unable to create data exporter. Error = %x", nRetVal) ;
       return Error ("Unable to export usage data. Unable to create data exporter.", 
         IID_ICOMUsageIntervalColl, nRetVal) ;
     }
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to export usage data. Unable to create data exporter. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "ExportByTimePeriod() failed. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to export usage data. Unable to create data exporter.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }
  // get the account usage map for this interval ...
  try
  {
    nRetVal = GetAccountUsageMap (&pDispatch) ;
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get the account usage map. Error = %x.", nRetVal) ;
      return Error ("Unable to get the account usage map.", 
        IID_ICOMUsageIntervalColl, nRetVal) ;
    }

    // do a queryinterface to get the interface ...
    nRetVal = pDispatch->QueryInterface (IID_ICOMAccountUsageMap, 
      reinterpret_cast<void**>(&pCOMAccountUsageMap)) ;
    if (!SUCCEEDED(nRetVal))
    {
      pDispatch->Release(); // release the object created by CoCreateInstance
      mLogger.LogVarArgs(LOG_ERROR, 
        "Unable to get the interface for the account usage map. Error = %x.", nRetVal) ;
      return Error ("Unable to get the interface for the account usage map.", 
        IID_ICOMUsageIntervalColl, nRetVal) ;
    }
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to export usage data. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "ExportByTimePeriod() failed. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to export usage data.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }

  // get the start and end date ...
  _bstr_t bstrStartDate, bstrEndDate ;
  _bstr_t bstrQueryExtension ;
  if (aStartDate.vt == VT_BSTR)
  {
    // convert the date string to MTDate's 
    bstrStartDate = aStartDate.bstrVal ;
  }
  else if (aStartDate.vt == VT_DATE)
  {
    // convert variant dates to MTDate's ...
    MTDate dtStartDate (aStartDate.date) ;
		string strStartDate;
		dtStartDate.ToString(STD_DATE_FORMAT, strStartDate);

    // copy the date to the bstr ...
    bstrStartDate = strStartDate.c_str() ;
  }
  if (aEndDate.vt == VT_BSTR)
  {
    // convert the date string to MTDate's 
    bstrEndDate = aEndDate.bstrVal ;
  }
  else if (aEndDate.vt == VT_DATE)
  {
    // convert variant dates to MTDate's ...
    MTDate dtEndDate (aEndDate.date) ;
		string strEndDate;
		dtEndDate.ToString(STD_DATE_FORMAT, strEndDate);

    // copy the date to the bstr ...
    bstrEndDate = strEndDate.c_str() ;
  }

  // create the string to get the usage information for ...
  bstrQueryExtension = "and au.dt_crt > '" ;
  bstrQueryExtension += bstrStartDate ;
  bstrQueryExtension += "' and au.dt_crt < '" ;
  bstrQueryExtension += bstrEndDate ;
  bstrQueryExtension += " 23:59:59'" ;

  try
  {
    // while we still have accounts to export data for ...
    pCOMAccountUsageMap->get_EOF(&vtEOF) ;
    while (vtEOF.boolVal == VARIANT_FALSE)
    {
      // get the account id ...
      vtIndex = DB_ACCOUNT_ID ;
      pCOMAccountUsageMap->get_Value (vtIndex, &vtValue) ;
      nAcctID = vtValue.lVal ;

      // create a data accessor object and get the summary view for it ...
      COMDBOBJECTSLib::ICOMDataAccessorPtr dataAccessor (MTPROGID_DATAACCESSOR) ;

      // add the interval and account id as properties ...
      dataAccessor->PutAccountID (nAcctID) ;
      dataAccessor->PutIntervalID (nIntervalID) ;

      // get the summary view ...
      pSummaryView = dataAccessor->GetSummaryView (bstrQueryExtension) ;

      // call the data exporter ...
      nRetVal = dataExporter->ExportData (pSummaryView) ;
      if (!SUCCEEDED(nRetVal))
      {
        pDispatch->Release(); // release the object created by CoCreateInstance
        mLogger.LogVarArgs(LOG_ERROR, 
          "Data export adapter unable to export data. Error = %x.", nRetVal) ;
        return Error ("Data export adapter unable to export data.", 
          IID_ICOMUsageIntervalColl, nRetVal) ;
      }
      // move to the next row ...
      pCOMAccountUsageMap->MoveNext() ;

      pCOMAccountUsageMap->get_EOF(&vtEOF) ;
    }
  }
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to export usage data. Unable to get usage information. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "ExportByTimePeriod() failed. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to export usage data. Unable to get usage information.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }

	return S_OK;
}

STDMETHODIMP CCOMUsageIntervalColl::get_Expired(VARIANT aDate, VARIANT *pVal)
{
	MTUsageInterval ui ;
  _variant_t vtExpired ;
  BOOL bRetCode=TRUE ;
  _bstr_t startDate, endDate, bstrDate ;
  BOOL bExpired=FALSE ;
  _variant_t vtStart, vtEnd ;

  if (aDate.vt == VT_BSTR)
  {
    // convert the date string to MTDate's 
    bstrDate = aDate.bstrVal ;
  }
  else if (aDate.vt == VT_DATE)
  {
    // convert variant dates to MTDate's ...
    MTDate dtCurrDate (aDate.date) ;
		string strCurrDate;
		dtCurrDate.ToString(STD_DATE_FORMAT, strCurrDate);

    // copy the date to the bstr ...
    bstrDate = strCurrDate.c_str() ;
  }
  // get the start and end date ...
	try
  {
    // get the start date ...
    _variant_t vtIndex = DB_START_DATE ;
    mpRowset->GetValue (vtIndex,vtStart) ;

    // get the end date ...
    vtIndex = DB_END_DATE ;
    mpRowset->GetValue (vtIndex, vtEnd) ;
  }
  catch (_com_error e)
  {
    HRESULT nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get start and end date for usage interval. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "get_Expired() failed. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to get start and end date for usage interval.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }

  // if either date's are empty ...
  if ((vtStart.vt == VT_EMPTY) || (vtEnd.vt == VT_EMPTY))
  {
    HRESULT nRetVal = E_FAIL ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get start and end date for usage interval.") ;
    return Error ("Unable to get start and end date for usage interval.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }

  // convert the variant date's to bstr dates ...
  MTDate dtStartDate (vtStart.date) ;
  MTDate dtEndDate (vtEnd.date) ;
	string strStartDate;
	string strEndDate;
	dtStartDate.ToString(STD_DATE_FORMAT, strStartDate);
	dtEndDate.ToString(STD_DATE_FORMAT, strEndDate);

  startDate = strStartDate.c_str() ;
  endDate = strEndDate.c_str() ;

  // initialize the usage interval ...
  bRetCode = ui.Init (startDate, endDate) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = ui.GetLastError() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Expired() failed. Unable to initialize usage interval.") ;
    return Error ("Expired() failed. Unable to initialize usage interval.", 
      IID_ICOMUsageIntervalColl, pError->GetCode()) ;
  }

  // check to see if the usage interval is expired ...
  bRetCode = ui.Expired (bstrDate, bExpired) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = ui.GetLastError() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Expired() failed. Unable to check usage interval for expiration.") ;
    return Error ("Expired() failed. Unable to check usage interval for expiration.", 
      IID_ICOMUsageIntervalColl, pError->GetCode()) ;
  }

  // return the result ...
  if (bExpired == TRUE)
  {
    vtExpired = (VARIANT_BOOL) VARIANT_TRUE ;
  }
  else
  {
    vtExpired = (VARIANT_BOOL) VARIANT_FALSE ;
  }

  *pVal = vtExpired.Detach() ;

  return S_OK ;
}

STDMETHODIMP CCOMUsageIntervalColl::get_Closed(VARIANT aDate, VARIANT *pVal)
{
	MTUsageInterval ui ;
  _variant_t vtClosed ;
  BOOL bRetCode=TRUE ;
  _bstr_t startDate, endDate, bstrDate ;
  BOOL bClosed=FALSE ;
  _variant_t vtStart, vtEnd ;

  if (aDate.vt == VT_BSTR)
  {
    // convert the date string to MTDate's 
    bstrDate = aDate.bstrVal ;
  }
  else if (aDate.vt == VT_DATE)
  {
    // convert variant dates to MTDate's ...
    MTDate dtCurrDate (aDate.date) ;
		string strCurrDate;
		dtCurrDate.ToString(STD_DATE_FORMAT, strCurrDate);

    // copy the date to the bstr ...
    bstrDate = strCurrDate.c_str() ;
  }
  // get the start and end date ...
	try
  {
    // get the start date ...
    _variant_t vtIndex = DB_START_DATE ;
    mpRowset->GetValue (vtIndex, vtStart) ;

    // get the end date ...
    vtIndex = DB_END_DATE ;
    mpRowset->GetValue (vtIndex, vtEnd) ;
  }
  catch (_com_error e)
  {
    HRESULT nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get start and end date for usage interval. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "get_Closed() failed. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to get start and end date for usage interval.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }

  // if either date's are empty ...
  if ((vtStart.vt == VT_EMPTY) || (vtEnd.vt == VT_EMPTY))
  {
    HRESULT nRetVal = E_FAIL ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get start and end date for usage interval.") ;
    return Error ("Unable to get start and end date for usage interval.", 
      IID_ICOMUsageIntervalColl, nRetVal) ;
  }

  // convert the variant date's to bstr dates ...
  MTDate dtStartDate (vtStart.date) ;
  MTDate dtEndDate (vtEnd.date) ;
	string strStartDate;
	string strEndDate;
	dtStartDate.ToString(STD_DATE_FORMAT, strStartDate);
	dtEndDate.ToString(STD_DATE_FORMAT, strEndDate);

  startDate = strStartDate.c_str() ;
  endDate = strEndDate.c_str() ;

  // initialize the usage interval ...
  bRetCode = ui.Init (startDate, endDate) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = ui.GetLastError() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "get_Closed() failed. Unable to initialize usage interval.") ;
    return Error ("get_Closed() failed. Unable to initialize usage interval.", 
      IID_ICOMUsageIntervalColl, pError->GetCode()) ;
  }

  // check to see if the usage interval is expired ...
  bRetCode = ui.Expired (bstrDate, bClosed) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pError = ui.GetLastError() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "get_Closed() failed. Unable to check usage interval for closure.") ;
    return Error ("get_Closed() failed. Unable to check usage interval for closure.", 
      IID_ICOMUsageIntervalColl, pError->GetCode()) ;
  }

  // return the result ...
  if (bClosed == TRUE)
  {
    vtClosed = (VARIANT_BOOL) VARIANT_TRUE ;
  }
  else
  {
    vtClosed = (VARIANT_BOOL) VARIANT_FALSE ;
  }

  *pVal = vtClosed.Detach() ;

  return S_OK ;
}

