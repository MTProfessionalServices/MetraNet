// COMAccountUsageMap.cpp : Implementation of CCOMAccountUsageMap
#include "StdAfx.h"
#include "MTUsageServer.h"
#include "COMAccountUsageMap.h"
#include <mtprogids.h>
#include <mtparamnames.h>
#include <DBConstants.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <DBMiscUtils.h>
#include <UsageServerConstants.h>
#include <DBSQLRowset.h>

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )

/////////////////////////////////////////////////////////////////////////////
// CCOMAccountUsageMap
CCOMAccountUsageMap::CCOMAccountUsageMap()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[AccountUsageMap]") ;
}

CCOMAccountUsageMap::~CCOMAccountUsageMap()
{
}

STDMETHODIMP CCOMAccountUsageMap::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMAccountUsageMap,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CCOMAccountUsageMap::get_Status(BSTR * pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CCOMAccountUsageMap::put_Status(BSTR newVal)
{
	 _variant_t vtValue, vtIndex ;
  HRESULT nRetVal=S_OK ;
  long nAccountID, nIntervalID;

	try
  {
    // get the account and interval id ...
    vtIndex = DB_INTERVAL_ID ;
    mpRowset->GetValue (vtIndex,vtValue) ;
    nIntervalID = vtValue.lVal ;
    vtIndex = DB_ACCOUNT_ID ;
    mpRowset->GetValue (vtIndex,vtValue) ;
    nAccountID = vtValue.lVal ;

    // create the queryadapter ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    
    // initialize the queryadapter ...
    _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
    rowset->Init(configPath) ;

    // set the query tag ...
    _bstr_t queryTag = "__UPDATE_ACCOUNT_USAGE_INTERVAL_STATUS__" ;
    rowset->SetQueryTag (queryTag) ;
    
    // set the parameter ...
    _variant_t vtParam = (long) nIntervalID ;
    rowset->AddParam (MTPARAM_INTERVALID, vtParam) ;
    vtParam = (long) nAccountID ;
    rowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam = newVal ;
    rowset->AddParam (MTPARAM_STATUS, vtParam) ;

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
      "Unable to get account usage interval update query. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to get account usage interval update query.", 
      IID_ICOMAccountUsageMap, nRetVal) ;
  }

  return nRetVal ;
}

STDMETHODIMP CCOMAccountUsageMap::InitByAccountID(long aAccountID)
{
 	HRESULT nRetVal = S_OK ;
  BOOL bRetCode=TRUE ;

  try
  {
    // create the queryadapter ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    
    // initialize the queryadapter ...
    _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
    rowset->Init(configPath) ;
    
    // set the query tag ...
    _bstr_t queryTag = "__GET_ACCOUNT_USAGE_FOR_ACCOUNT__" ;
    rowset->SetQueryTag (queryTag) ;

    // add the account id  ...
    _variant_t vtParam = (long) aAccountID ;
    rowset->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    
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
      "Unable to get account usage map by account id query. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to get account usage map by account id query.", 
      IID_ICOMAccountUsageMap, nRetVal) ;
  }

  return nRetVal ;
}

STDMETHODIMP CCOMAccountUsageMap::InitByIntervalID(long aIntervalID)
{
 	HRESULT nRetVal = S_OK ;
  BOOL bRetCode=TRUE ;

  try
  {
    // create the queryadapter ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    
    // initialize the queryadapter ...
    _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
    rowset->Init(configPath) ;
    
    // set the query tag ...
    _bstr_t queryTag = "__GET_ACCOUNT_USAGE_FOR_INTERVAL__" ;
    rowset->SetQueryTag (queryTag) ;

    // add the account id  ...
    _variant_t vtParam = (long) aIntervalID ;
    rowset->AddParam (MTPARAM_INTERVALID, vtParam) ;
    
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
      "Unable to get account usage map by interval id query. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to get account usage map by interval id query.", 
      IID_ICOMAccountUsageMap, nRetVal) ;
  }

  return nRetVal ;
}

