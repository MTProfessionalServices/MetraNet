// COMUsageCycleColl.cpp : Implementation of CCOMUsageCycleColl
#include "StdAfx.h"
#include "MTUsageServer.h"
#include "COMUsageCycleColl.h"

#include <mtprogids.h>
#include <DBConstants.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <MTUtil.h>
#include <DBMiscUtils.h>
#include <UsageServerConstants.h>
#undef min
#undef max
#include <DBSQLRowset.h>
#include <mttime.h>
#include <formatdbvalue.h>
#include <MTDate.h>

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <MTUsageCycle.tlb> 
using namespace MTUSAGECYCLELib ;

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageCycleColl
CCOMUsageCycleColl::CCOMUsageCycleColl()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[UsageCycleColl]") ;
}

CCOMUsageCycleColl::~CCOMUsageCycleColl()
{
}

STDMETHODIMP CCOMUsageCycleColl::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMUsageCycleColl,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CCOMUsageCycleColl::Init()
{
 	HRESULT nRetVal = S_OK ;

  try
  {
		if(mpRowset) delete mpRowset;
		mpRowset = new DBSQLRowset;
    // create the queryadapter ...
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    
    // initialize the queryadapter ...
    _bstr_t configPath = USAGE_SERVER_QUERY_DIR ;
    rowset->Init(configPath) ;
    
    // set the query tag ...
    _bstr_t queryTag = "__GET_USAGE_CYCLES__" ;
    rowset->SetQueryTag (queryTag) ;
    
		_variant_t currentTime = GetMTOLETime();
		std::wstring buffer;
		FormatValueForDB(currentTime, FALSE, buffer);
    rowset->AddParam (L"%%UTCDATE%%", buffer.c_str(), true);

    // execute the query ...
    rowset->Execute() ;

    // detach the allocated COM object ...
    mpRowset->PutRecordSet(_RecordsetPtr(IDispatchPtr(rowset->GetPopulatedRecordSet())));
  }    
  catch (_com_error e)
  {
    nRetVal = e.Error() ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to get usage cycles query. Error = %x", nRetVal) ;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
      (char*) e.Description()) ;
    return Error ("Unable to get usage cycles query.", 
      IID_ICOMUsageCycleColl, nRetVal) ;
  }

  return nRetVal ;
}

STDMETHODIMP CCOMUsageCycleColl::CreateInterval(VARIANT aDate)
{
  // local variables ...
  HRESULT nRetVal=S_OK ;
  _variant_t vtIndex, vtValue ;
  _bstr_t bstrProgID ;
  long nUsageCycleTypeID;
  MTDate dtCurrent(GetMTTime()) ;

  // if we have a rowset ...
  if (mpRowset != NULL)
  {
    try
    {
      // if the type of the variant is VT_BSTR ... convert it directly to a mtdate ...
      if (aDate.vt == VT_BSTR)
      {
        _bstr_t bstrDate = aDate.bstrVal ;
        MTDate dtConvert (string((const char*)bstrDate)) ;
        dtCurrent = dtConvert ;
      }
      else if (aDate.vt == VT_DATE)
      {
        // convert variant dates to MTDate's ...
        MTDate dtConvert (aDate.date) ;
        dtCurrent = dtConvert ;
      }

      // create the usage cycle property collection ...
      ::ICOMUsageCyclePropertyColl *pUCPropColl=NULL;
      nRetVal = CoCreateInstance (CLSID_COMUsageCyclePropertyColl, NULL, CLSCTX_INPROC_SERVER,
        IID_ICOMUsageCyclePropertyColl, (void **) &pUCPropColl) ;
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR, "Unable to create usage cycle property collection. Error = <%x>", 
          nRetVal) ;
        return Error ("Unable to create usage cycle property collection.", 
          IID_ICOMUsageCycleColl, nRetVal) ;
      }

      // get the prog id of the usage cycle object ...
      vtIndex = DB_PROGID ;
      mpRowset->GetValue (vtIndex,vtValue) ;
      bstrProgID = vtValue.bstrVal ;
      vtIndex = DB_CYCLE_TYPE_ID ;
      mpRowset->GetValue (vtIndex,vtValue) ;
      nUsageCycleTypeID = vtValue.lVal ;

      // switch on the cycle type id ...
      switch (nUsageCycleTypeID)
      {
      case UC_MONTHLY:
        // get the day of month out of the rowset ...
        vtIndex = UCP_DAY_OF_MONTH ;
        mpRowset->GetValue (vtIndex,vtValue);
        
        // add the day of month into the usage cycle property collection ...
        pUCPropColl->AddProperty (UCP_DAY_OF_MONTH, vtValue) ;
        break ;

      case UC_ON_DEMAND:
        break ;
        
      case UC_DAILY:
        break ;
        
      case UC_WEEKLY:
        // get the day of week out of the rowset ...
        vtIndex = UCP_DAY_OF_WEEK ;
        mpRowset->GetValue (vtIndex,vtValue) ;
        
        // add the day of month into the usage cycle property collection ...
        pUCPropColl->AddProperty (UCP_DAY_OF_WEEK, vtValue) ;
        break ;
        
      case UC_BI_WEEKLY:
        // get the start day out of the rowset ...
        vtIndex = UCP_START_DAY ;
        mpRowset->GetValue (vtIndex,vtValue);
        
        // add the start day into the usage cycle property collection ...
        pUCPropColl->AddProperty (UCP_START_DAY, vtValue) ;

        // get the start month out of the rowset ...
        vtIndex = UCP_START_MONTH ;
        mpRowset->GetValue (vtIndex,vtValue) ;
        
        // add the start month into the usage cycle property collection ...
        pUCPropColl->AddProperty (UCP_START_MONTH, vtValue) ;

        // get the start year out of the rowset ...
        vtIndex = UCP_START_YEAR ;
        mpRowset->GetValue (vtIndex,vtValue);
        
        // add the start year into the usage cycle property collection ...
        pUCPropColl->AddProperty (UCP_START_YEAR, vtValue) ;
        break ;
        
      case UC_SEMI_MONTHLY:
        // get the first day of month out of the rowset ...
        vtIndex = UCP_FIRST_DAY_OF_MONTH ;
        mpRowset->GetValue (vtIndex,vtValue);
        
        // add the first day of month into the usage cycle property collection ...
        pUCPropColl->AddProperty (UCP_FIRST_DAY_OF_MONTH, vtValue) ;

        // get the second day of month out of the rowset ...
        vtIndex = UCP_SECOND_DAY_OF_MONTH ;
        mpRowset->GetValue(vtIndex,vtValue);
        
        // add the second day of month into the usage cycle property collection ...
        pUCPropColl->AddProperty (UCP_SECOND_DAY_OF_MONTH, vtValue) ;
        break ;
        
      case UC_QUARTERLY:
      case UC_SEMIANNUALLY:
      case UC_ANNUALLY:
        // get the start day out of the rowset ...
        vtIndex = UCP_START_DAY ;
        mpRowset->GetValue (vtIndex,vtValue);
        
        // add the start day into the usage cycle property collection ...
        pUCPropColl->AddProperty (UCP_START_DAY, vtValue) ;

        // get the start month out of the rowset ...
        vtIndex = UCP_START_MONTH ;
        mpRowset->GetValue (vtIndex,vtValue);
        
        // add the start month into the usage cycle property collection ...
        pUCPropColl->AddProperty (UCP_START_MONTH, vtValue) ;
        break ;
        
      default:
        // get the cycle id out of the rowset ...
        vtIndex = UCP_CYCLE_ID ;
        mpRowset->GetValue (vtIndex,vtValue);
        
        // add the start day into the usage cycle property collection ...
        pUCPropColl->AddProperty (UCP_CYCLE_ID, vtValue) ;
        
        break ;
      }
      
      // create the appropriate usage cycle object ...
      MTUSAGECYCLELib::IMTUsageCyclePtr pUsageCycle ((LPCSTR)((char*)bstrProgID)) ;
      
      // call create interval ...
      nRetVal = pUsageCycle->CreateInterval (aDate, 
        (MTUSAGECYCLELib::ICOMUsageCyclePropertyColl *) pUCPropColl, nUsageCycleTypeID ) ;
      if (!SUCCEEDED(nRetVal))
      {
        mLogger.LogVarArgs (LOG_ERROR,  
          "Unable to create interval for usage cycle. Error = %x", nRetVal) ;
        return Error ("Unable to create interval for usage cycle.", 
          IID_ICOMUsageCycleColl, nRetVal) ;
      }
    }    
    catch (_com_error e)
    {
      nRetVal = e.Error() ;
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to get usage cycles query. Error = %x", nRetVal) ;
      mLogger.LogVarArgs (LOG_ERROR, "Unable to create query. Error Description = %s",
        (char*) e.Description()) ;
      return Error ("Unable to get usage cycles query.", 
        IID_ICOMUsageCycleColl, nRetVal) ;
    }
  }
  else
  {
    nRetVal = DB_ERR_NO_ROWS ;
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to create interval for usage cycle. No rowset. Error = %x", nRetVal) ;
    return Error ("Unable to create interval for usage cycle. No rowset.", 
      IID_ICOMUsageCycleColl, nRetVal) ;
  }

  return nRetVal ;
}

