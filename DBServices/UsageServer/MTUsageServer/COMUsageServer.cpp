// COMUsageServer.cpp : Implementation of CCOMUsageServer

#include "StdAfx.h"
#include <mtcom.h>
#include <comdef.h>
#include "MTUsageServer.h"
#include "COMUsageServer.h"
#include <metra.h>

#include <loggerconfig.h>
#include <DBConstants.h>
#include <mtprogids.h>
#include <mtparamnames.h>
#include <DataAccessDefs.h>
#include <DBViewHierarchy.h>
#include <DBUsageCycle.h>
#include <mtglobal_msg.h>
#include <DBConstants.h>
#include <DBMiscUtils.h>
#include <ConfigDir.h>
#include <mttime.h>
#include <formatdbvalue.h>
#include <MTDate.h>

// odbc stuff
#include <OdbcConnection.h>
#include <OdbcType.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcConnection.h>
#include <OdbcConnMan.h>
#include <OdbcException.h>
#include <autoptr.h>

using std::map;
using std::vector;
using std::wstring;

using namespace std;

typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcTableInsertStatement> COdbcTableInsertStatementPtr;

// import the config loader ...
#import <MTConfigLib.tlb> 
using namespace MTConfigLib;

#import <MTUsageCycle.tlb> rename ("EOF", "RowsetEOF")
#import <MTUsageServer.tlb> rename ("EOF", "RowsetEOF")
#import <MTDataExporter.tlb> no_namespace


/////////////////////////////////////////////////////////////////////////////
// CCOMUsageServer

CCOMUsageServer::CCOMUsageServer()
{
  LoggerConfigReader cfgRdr;
  
  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[UsageServer]");
}

CCOMUsageServer::~CCOMUsageServer()
{
}

STDMETHODIMP CCOMUsageServer::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_ICOMUsageServer,
  };
  for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
  {
    if (InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

STDMETHODIMP CCOMUsageServer::GetUsageIntervals(BSTR aStatus, LPDISPATCH * apUsageIntervals)
{
  // local variables
  HRESULT nRetVal=S_OK;
  ICOMUsageIntervalColl *pCOMUsageIntervalColl;
  
  // create a usage interval collection object ...
  nRetVal = CoCreateInstance (CLSID_COMUsageIntervalColl, NULL, CLSCTX_INPROC_SERVER,
    IID_ICOMUsageIntervalColl, (void **) apUsageIntervals);
  if (!SUCCEEDED(nRetVal))
  {
    apUsageIntervals = NULL;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create usage interval collection. Error = <%x>", 
      nRetVal);
    return Error ("Unable to create usage interval collection.", 
      IID_ICOMUsageServer, nRetVal);
  }
  else
  {
    // do a queryinterface to get the interface ...
    nRetVal = (*apUsageIntervals)->QueryInterface (IID_ICOMUsageIntervalColl, 
      reinterpret_cast<void**>(&pCOMUsageIntervalColl));
    if (!SUCCEEDED(nRetVal))
    {
      (*apUsageIntervals)->Release(); // release the object created by CoCreateInstance
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get the interface for the usage interval collection");
      return Error ("Unable to get the interface for the usage interval collection.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // call init ...
    nRetVal = pCOMUsageIntervalColl->Init(aStatus);
    if (!SUCCEEDED(nRetVal))
    {
      pCOMUsageIntervalColl->Release(); // release the object created by CoCreateInstance
      (*apUsageIntervals)->Release(); // release the object created by CoCreateInstance
      mLogger.LogVarArgs (LOG_ERROR, "Unable to initialize usage interval collection.");
      return Error ("Unable to initialize usage interval collection.", 
        IID_ICOMUsageServer, nRetVal);
    }
  }
  // release the ref ...
  pCOMUsageIntervalColl->Release(); 
  return nRetVal;
}


STDMETHODIMP CCOMUsageServer::GetUsageCycles(LPDISPATCH * apUsageCycleColl)
{
  // local variables
  HRESULT nRetVal=S_OK;
  ICOMUsageCycleColl *pCOMUsageCycleColl;
  
  // create a usage cycle object ...
  nRetVal = CoCreateInstance (CLSID_COMUsageCycleColl, NULL, CLSCTX_INPROC_SERVER,
    IID_ICOMUsageCycleColl, (void **) apUsageCycleColl);
  if (!SUCCEEDED(nRetVal))
  {
    apUsageCycleColl = NULL;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create usage cycle collection.");
    return Error ("Unable to create usage cycle collection.", 
      IID_ICOMUsageServer, nRetVal);
  }
  else
  {
    // do a queryinterface to get the interface ...
    nRetVal = (*apUsageCycleColl)->QueryInterface (IID_ICOMUsageCycleColl, 
      reinterpret_cast<void**>(&pCOMUsageCycleColl));
    if (!SUCCEEDED(nRetVal))
    {
      (*apUsageCycleColl)->Release(); // release the object created by CoCreateInstance
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get the interface for the usage cycle collection");
      return Error ("Unable to get the interface for the usage cycle collection.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // call init ...
    nRetVal = pCOMUsageCycleColl->Init();
    if (!SUCCEEDED(nRetVal))
    {
      pCOMUsageCycleColl->Release(); // release the object created by CoCreateInstance
      (*apUsageCycleColl)->Release(); 
      mLogger.LogVarArgs (LOG_ERROR, "Unable to initialize usage cycle collection.");
      return Error ("Unable to initialize usage cycle collection.", 
        IID_ICOMUsageServer, nRetVal);
    }
  }
  // release the ref ...
  pCOMUsageCycleColl->Release(); 

  return nRetVal;
}

STDMETHODIMP CCOMUsageServer::GetUsageCycleTypes(LPDISPATCH * apUsageCycleTypes)
{
  // local variables
  HRESULT nRetVal=S_OK;
  ICOMUsageCycleTypes *pCOMUsageCycleTypes;
  
  // create a usage cycle type object ...
  nRetVal = CoCreateInstance (CLSID_COMUsageCycleTypes, NULL, CLSCTX_INPROC_SERVER,
    IID_ICOMUsageCycleTypes, (void **) apUsageCycleTypes);
  if (!SUCCEEDED(nRetVal))
  {
    apUsageCycleTypes = NULL;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create usage cycle type collection.");
    return Error ("Unable to create usage cycle type collection.", 
      IID_ICOMUsageServer, nRetVal);
  }
  else
  {
    // do a queryinterface to get the interface ...
    nRetVal = (*apUsageCycleTypes)->QueryInterface (IID_ICOMUsageCycleTypes, 
      reinterpret_cast<void**>(&pCOMUsageCycleTypes));
    if (!SUCCEEDED(nRetVal))
    {
      (*apUsageCycleTypes)->Release(); // release the object created by CoCreateInstance
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get the interface for the usage cycle types collection");
      return Error ("Unable to get the interface for the usage cycle types collection.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // call init ...
    nRetVal = pCOMUsageCycleTypes->Init();
    if (!SUCCEEDED(nRetVal))
    {
      pCOMUsageCycleTypes->Release(); // release the object created by CoCreateInstance
      (*apUsageCycleTypes)->Release(); 
      mLogger.LogVarArgs (LOG_ERROR, "Unable to initialize usage cycle type collection.");
      return Error ("Unable to initialize usage cycle type collection.", 
        IID_ICOMUsageServer, nRetVal);
    }
  }
  // release the ref ...
  pCOMUsageCycleTypes->Release(); 

  return nRetVal;
}

STDMETHODIMP CCOMUsageServer::GetAccountUsageMap(long aAccountID, 
                                                 LPDISPATCH * apAccountUsageMap)
{
  // local variables
  HRESULT nRetVal=S_OK;
  ICOMAccountUsageMap *pAcctMap;
  
  // create a account usage map object ...
  nRetVal = CoCreateInstance (CLSID_COMAccountUsageMap, NULL, CLSCTX_INPROC_SERVER,
    IID_ICOMAccountUsageMap, (void **) apAccountUsageMap);
  if (!SUCCEEDED(nRetVal))
  {
    apAccountUsageMap = NULL;
    mLogger.LogVarArgs (LOG_ERROR, "Unable to create account usage map.");
    return Error ("Unable to create account usage map.", 
      IID_ICOMUsageServer, nRetVal);
  }
  else
  {
    // do a queryinterface to get the interface ...
    nRetVal = (*apAccountUsageMap)->QueryInterface (IID_ICOMAccountUsageMap, 
      reinterpret_cast<void**>(&pAcctMap));
    if (!SUCCEEDED(nRetVal))
    {
      (*apAccountUsageMap)->Release(); // release the object created by CoCreateInstance
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get the interface for the account usage map");
      return Error ("Unable to get the interface for the account usage map.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // call init ...
    nRetVal = pAcctMap->InitByAccountID(aAccountID);
    if (!SUCCEEDED(nRetVal))
    {
      pAcctMap->Release(); // release the object created by CoCreateInstance
      (*apAccountUsageMap)->Release(); 
      mLogger.LogVarArgs (LOG_ERROR, "Unable to initialize account usage map.");
      return Error ("Unable to initialize account usage map.", 
        IID_ICOMUsageServer, nRetVal);
    }
  }
  // release the ref ...
  pAcctMap->Release(); 

  return nRetVal;
}

HRESULT CCOMUsageServer::GetIntervalStateStringForDatabase (MTUsageIntervalState aState, _bstr_t &aStateString)
{
  HRESULT nRetVal=S_OK;

  switch (aState)
  {
  case INTERVAL_STATE_NEW:
    aStateString= USAGE_INTERVAL_NEW;
    break;
  case INTERVAL_STATE_OPEN:
    aStateString= USAGE_INTERVAL_OPEN;
    break;
  case INTERVAL_STATE_PENDING_SOFT_CLOSE:
    aStateString= USAGE_INTERVAL_PENDING_SOFT_CLOSE;
    break;
  case INTERVAL_STATE_SOFT_CLOSE:
    aStateString= USAGE_INTERVAL_SOFT_CLOSED;
    break;
  case INTERVAL_STATE_PENDING_HARD_CLOSE:
    aStateString= USAGE_INTERVAL_PENDING_HARD_CLOSE;
    break;
  case INTERVAL_STATE_HARD_CLOSE:
    aStateString= USAGE_INTERVAL_HARD_CLOSED;
    break;


    default:
      aStateString="";
		//mLogger.LogVarArgs(LOG_ERROR, "CCOMUsageServer::AddPCIntervals: cycle type ID '%d' is not supported!", cycleTypeID);
		  return E_FAIL;
  }


  return nRetVal;
}



HRESULT CCOMUsageServer::GetUsageIntervalCollection (const _bstr_t &arState, 
                                                     const _bstr_t &arPeriodType,
                                                     ICOMUsageIntervalColl * & arpUIColl)
{
  // local variables ...
  LPDISPATCH pDispUIColl=NULL;
  HRESULT nRetVal=S_OK;

  try
  {
    // create a usage interval collection object ...
    nRetVal = CoCreateInstance (CLSID_COMUsageIntervalColl, NULL, CLSCTX_INPROC_SERVER,
      IID_ICOMUsageIntervalColl, (void **) &pDispUIColl);
    if (!SUCCEEDED(nRetVal))
    {
      pDispUIColl = NULL;
      mLogger.LogVarArgs (LOG_ERROR, "Unable to create usage interval collection.");
      return Error ("Unable to create usage interval collection.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // do a queryinterface to get the interface ...
    nRetVal = pDispUIColl->QueryInterface (IID_ICOMUsageIntervalColl, 
      reinterpret_cast<void**>(&arpUIColl));
    if (!SUCCEEDED(nRetVal))
    {
      pDispUIColl->Release(); // release the object created by CoCreateInstance
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get the interface for the usage interval collection");
      return Error ("Unable to get the interface for the usage interval collection.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // initialize the usage interval collection by status and usage cycle period type ...
    nRetVal = arpUIColl->InitByStateAndPeriodType (arState, arPeriodType);
    if (!SUCCEEDED(nRetVal))
    {
      pDispUIColl->Release();
      arpUIColl->Release();
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to initialize usage interval collection. State = %s. PeriodType = %s. Error = %x.", 
        (char*)arState, (char*)arPeriodType, nRetVal);
      return Error ("Unable to initialize usage interval collection.", 
        IID_ICOMUsageServer, nRetVal);
    }
    // release the ref ...
    pDispUIColl->Release();
    pDispUIColl = NULL;
  }
  catch (_com_error e)
  {
    if (pDispUIColl != NULL)
    {
      pDispUIColl->Release();
    }
    if (arpUIColl != NULL)
    {
      arpUIColl->Release();
    }
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to create usage interval collection. State = %s. PeriodType = %s. Error = %x.", 
      (char*)arState, (char*)arPeriodType, nRetVal);
    mLogger.LogVarArgs (LOG_ERROR, "DoRecurringEvent() failed. Error Description = %s",
      (char*) e.Description());
    return Error ("Unable to create usage interval collection.", 
      IID_ICOMUsageServer, nRetVal);
  }
  return nRetVal;
}    

HRESULT CCOMUsageServer::ReadRecurringEventFile (const _bstr_t &arPeriodTag, 
                                                 const _bstr_t &arEventPeriod,
                                                 const long &arIntervalID,
                                                 const _bstr_t &arState, 
                                                 const _bstr_t &arPeriodType,
                                                 const wstring &arCycleType,
																								 ROWSETLib::IMTSQLRowsetPtr &arRowset,
                                                 CycleTypeAdapterColl &arPerAccount,
                                                 CycleTypeAdapterColl &arPerInterval,
                                                 long &arNumGroups)
{
  // local variables ...
  BOOL bEventsToProcess=FALSE;
  AdapterInfo *pAdapterInfo=NULL;
  _variant_t vtIndex, vtValue, vtParam;
  HRESULT nRetVal=S_OK;
  long nRunID=-1;
  IMTDataExporterPtr  dataExporterV1;  //deprecated interface
  IMTDataExporter2Ptr dataExporterV2;

  // config loader smart pointers ...
  arNumGroups = 0;
  MTConfigLib::IMTConfigPropSetPtr propSet;
  MTConfigLib::IMTConfigPropSetPtr periodset;
  MTConfigLib::IMTConfigPropSetPtr eventset;
  MTConfigLib::IMTConfigPropSetPtr subset;
  MTConfigLib::IMTConfigPropSetPtr adapterSet;
  _bstr_t adapter, configFile, name;
  wstring billingCycle;
  
  try
  {
    // create the propset ...
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

    // get the config directory ...
    string rwcConfigDir;
    VARIANT_BOOL checksumMatch;
    
    if (!GetMTConfigDir(rwcConfigDir))
    {
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get configuration directory. State = %s. PeriodType = %s. Error = %x.", 
        (char*)arState, (char*)arPeriodType, nRetVal);
      return Error ("Unable to get configuration directory.", 
        IID_ICOMUsageServer, E_FAIL);
    }
    _bstr_t bstrConfigFile = rwcConfigDir.c_str();
    bstrConfigFile += USAGE_SERVER_CONFIG_DIR;
    bstrConfigFile += "\\";
    bstrConfigFile += RECURRING_EVENT_FILE;
    
    // read the configuration file ...
    propSet = config->ReadConfiguration(bstrConfigFile, &checksumMatch);
  }
  catch (_com_error e)
  {
    nRetVal = e.Error();
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to read recurring event configuration file. State = %s. PeriodType = %s. Error = %x.", 
      (char*)arState, (char*)arPeriodType, nRetVal);
    mLogger.LogVarArgs (LOG_ERROR, "DoRecurringEvent() failed. Error Description = %s",
      (char*) e.Description());
    return Error ("Unable to read recurring event configuration file.", 
      IID_ICOMUsageServer, nRetVal);
  }
  
  try
  {
    // read the associated period type's set (BILLING or TIME) ...
    while ((periodset = propSet->NextSetWithName(arPeriodTag)) != NULL)
    {
      
      // get the attribute ...
      billingCycle = periodset->GetAttribSet()->GetAttrValue("uct");

      // if this is cycle type or the default cycle type ...
      if ((_wcsicmp(arCycleType.c_str(), billingCycle.c_str()) == 0)|| 
        (_wcsicmp(billingCycle.c_str(), UC_DEFAULT_STR) == 0) )
      {
        try
        {
          // read the appropriate event period ...
          eventset = periodset->NextSetWithName(arEventPeriod);
          if (eventset != NULL)
          {
            bEventsToProcess = TRUE;
          }
          else
          {
            bEventsToProcess = FALSE;
          }
        }
        catch (_com_error e)
        {
          // no events for this period ... 
          bEventsToProcess = FALSE;
        }
        
        // if we have events to process ...
        if (bEventsToProcess == TRUE)
        {
          long cycleTypeGroups=0;
          
					//TODO: can these guys be allocated statically? delete is never called on them
			
          //creates cycle type adapter collections

          CycleTypeAdapterInfo *pCycleTypePerAccount  = new CycleTypeAdapterInfo;
          CycleTypeAdapterInfo *pCycleTypePerInterval = new CycleTypeAdapterInfo;

          if (!pCycleTypePerAccount || !pCycleTypePerInterval) {
            mLogger.LogVarArgs (LOG_ERROR,  
																"Unable to create cycle type adapter info for interval = %d. Error = %x", 
																arIntervalID, nRetVal);

						//TODO: why is this a continue?
            continue;
          }
          
          // read the list of groups ...
          while (((subset = eventset->NextSetWithName(TAG_GROUP)) != NULL))
          {
            AdapterColl groupPerAccount;
            AdapterColl groupPerInterval;
            
            // increment cycleTypeGroups ... reset arNumGroups if necessary ...
            cycleTypeGroups++;
            if (cycleTypeGroups > arNumGroups)
            {
              arNumGroups = cycleTypeGroups;
            }
            
            // read in the XML config file name
            while ((adapterSet = subset->NextSetWithName(TAG_ADAPTER_SET)) != NULL)
            {
              // get the adapter, name and the config file ...
              adapter = adapterSet->NextStringWithName (TAG_ADAPTER);
              name = adapterSet->NextStringWithName (TAG_ADAPTER_NAME);
              
              try
              {
                configFile = adapterSet->NextStringWithName (TAG_CONFIG_FILE);
              }
              catch (_com_error e)
              {
                configFile = " ";
              }
              
              // create the recurring event adapter ...
              try
              {
                // initialize the stored procedure ...
                arRowset->InitializeForStoredProc ("InsertRecurringEventRun");
                
                // add the parameters ...
                vtParam = (long) arIntervalID;
                arRowset->AddInputParameterToStoredProc("id_interval", MTTYPE_INTEGER, INPUT_PARAM, vtParam);
                vtParam = name;
                arRowset->AddInputParameterToStoredProc("tx_adapter_name", MTTYPE_VARCHAR, INPUT_PARAM, vtParam);
                vtParam = adapter;
                arRowset->AddInputParameterToStoredProc("tx_adapter_method", MTTYPE_VARCHAR, INPUT_PARAM, vtParam);
                vtParam = configFile;
                arRowset->AddInputParameterToStoredProc("tx_config_file", MTTYPE_VARCHAR, INPUT_PARAM, vtParam);
                vtParam = GetMTOLETime();
                arRowset->AddInputParameterToStoredProc("system_date", MTTYPE_DATE, INPUT_PARAM, vtParam);
                arRowset->AddOutputParameterToStoredProc("id_run", MTTYPE_INTEGER, OUTPUT_PARAM);
                
                arRowset->ExecuteStoredProc();
                
                // get the recurring event run id ...
                _variant_t vtValue = arRowset->GetParameterFromStoredProc ("id_run");
                nRunID = vtValue.lVal;
                
                // log a debug message ...
                mLogger.LogVarArgs (LOG_DEBUG, "Creating adapter '%s' <%s> for usage interval <%d>.",
                  (char*)name,(char*)adapter, arIntervalID);
                
								//creates the adapter object and identifies the version of the interface which is implemented
								long nAdapterInterfaceVersion = 2;
                nRetVal = dataExporterV2.CreateInstance((char*)adapter);
                if (FAILED(nRetVal))
                {
									nAdapterInterfaceVersion = 1;
									nRetVal = dataExporterV1.CreateInstance((char*)adapter);
									if (FAILED(nRetVal))
									{
										mLogger.LogVarArgs (LOG_ERROR,  
																				"Unable to create data export adapter with id = %s. Error = %x", 
																				(char*) adapter, nRetVal);

										//TODO: why is this a continue?
										continue;
									}
                }
								mLogger.LogVarArgs(LOG_DEBUG, "Adapter %s implements version %d of the adapter interface",
																	 (char*) adapter, nAdapterInterfaceVersion);

								//initializes the adapter 
								mLogger.LogVarArgs(LOG_DEBUG, "Initialized adapter <%s> for usage interval <%d>.", (char*) name, arIntervalID);

								if (nAdapterInterfaceVersion >= 2) {  //handles version 2 adapters
									dataExporterV2->Initialize(configFile);
									
									// insert the adapter and adapter info into the collection ...
									pAdapterInfo = new AdapterInfo(dataExporterV2, name, nRunID, adapter, configFile);
									if (!pAdapterInfo) {
										mLogger.LogVarArgs (LOG_ERROR, "Unable to create adapter info for adapter = %s and interval = %d. Error = %x", 
																				(char*) name, arIntervalID, nRetVal);
										continue;  //TODO: why is this a continue?
									}

									//adds the adapter to the appropriate group collection
									if (dataExporterV2->GetPerInterval() == VARIANT_TRUE)
										groupPerInterval.push_back(pAdapterInfo);
									else
									{
										mLogger.LogVarArgs(LOG_DEBUG,
																				"Performance warning: adapter <%s> supports version 2 but is marked as per account",
																				(char*) name);
										groupPerAccount.push_back(pAdapterInfo);
									}

								} else {  //handles version 1 adapters
									dataExporterV1->Initialize(configFile);
									
									// insert the adapter and adapter info into the collection ...
									pAdapterInfo = new AdapterInfo(dataExporterV1, name, nRunID);
									if (!pAdapterInfo) {
										mLogger.LogVarArgs (LOG_ERROR, "Unable to create adapter info for adapter = %s and interval = %d. Error = %x", 
																				(char*) name, arIntervalID, nRetVal);
										continue;  //TODO: why is this a continue?
									}

									mLogger.LogVarArgs(LOG_DEBUG,
																		 "Performance warning: adapter <%s> supports version 1 only",
																		 (char*) name);
									//adds the adapter to the appropriate group collection
									groupPerAccount.push_back(pAdapterInfo);
								}

                pAdapterInfo = NULL;
              }
              catch (_com_error e)
              {
                nRetVal = e.Error();
                mLogger.LogVarArgs (LOG_ERROR,  
                  "Unable to create data export adapter with id = %s. Error = %x", 
                  (char*) adapter, nRetVal);
                _bstr_t errMsg = e.Description(); 
                mLogger.LogVarArgs (LOG_ERROR, 
                  "Adapter <%s> Initialize() failed for interval <%d>. Error Description = %s",
                  (char*) name, arIntervalID, (char*) errMsg);

								//TODO: should this return?

              }
              catch (...)
              {
                mLogger.LogVarArgs (LOG_ERROR,  
                  "Unable to create data export adapter with id = %s.", 
                  (char*) adapter);
                mLogger.LogVarArgs (LOG_ERROR, 
                  "Adapter <%s> Initialize() failed for interval <%d>. Unhandled exception.",
                  (char*) name, arIntervalID);

								//TODO: should this return?
              }
            }

            //inserts the group collections into the cycle type collections

						//*** TODO: if the group collection is empty can we not add it?
            pCycleTypePerAccount->AddAdapterColl(groupPerAccount);
            pCycleTypePerInterval->AddAdapterColl(groupPerInterval);
          }

          //inserts the cycle type collections into the final mega collections which will be returned
          arPerAccount[billingCycle] = pCycleTypePerAccount;
          arPerInterval[billingCycle] = pCycleTypePerInterval;
        }
      }
    }   
  }
  catch (_com_error e)
  {
    nRetVal = e.Error();
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to read recurring event configuration file. State = %s. PeriodType = %s. Error = %x.", 
      (char*)arState, (char*)arPeriodType, nRetVal);
    mLogger.LogVarArgs (LOG_ERROR, "DoRecurringEvent() failed. Error Description = %s",
      (char*) e.Description());
    return Error ("Unable to read recurring event configuration file.", 
      IID_ICOMUsageServer, nRetVal);
  }
  return nRetVal;
}

HRESULT CCOMUsageServer::UpdateUsageIntervalStatus (const _bstr_t &arNextState, 
                                                    const long &arIntervalID, 
                                                    ICOMUsageIntervalColl * & arpUIColl) 
{
  // local variables ...
  HRESULT nRetVal=S_OK;

  try
  {
    // update the usage interval status ...
    nRetVal = arpUIColl->put_Status (arNextState);
    if (nRetVal != S_OK)
    {
      if (arpUIColl != NULL)
      {
        arpUIColl->Release();
        arpUIColl = NULL;
      }
      mLogger.LogVarArgs (LOG_ERROR,  
        "Unable to update status for interval = %d. Error = %x", 
        arIntervalID, nRetVal);
      return Error ("Unable to update status for interval.", 
        IID_ICOMUsageServer, nRetVal);
    }
  }
  catch (_com_error e)
  {
    if (arpUIColl != NULL)
    {
      arpUIColl->Release();
      arpUIColl = NULL;
    }
    nRetVal = e.Error();
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to update status for interval = %d. Error = %x", 
      arIntervalID, nRetVal);
    return Error ("Unable to update status for interval.", 
      IID_ICOMUsageServer, nRetVal);
  }
  return nRetVal;
}

HRESULT CCOMUsageServer::GetAccountUsageMapForInterval (const long &arIntervalID,
                                                        ICOMUsageIntervalColl * & arpUIColl,
                                                        ICOMAccountUsageMap * & arpAcctMap)
{
  // local variables ...
  HRESULT nRetVal=S_OK;
  LPDISPATCH pDispAcctMap=NULL;

  try
  {
    // null out the ptrs ...
    pDispAcctMap = NULL;
    
    nRetVal = arpUIColl->GetAccountUsageMap (&pDispAcctMap);
    if (!SUCCEEDED(nRetVal))
    {
      if (arpUIColl != NULL)
      {
        arpUIColl->Release();
        arpUIColl = NULL;
      }
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get account map for interval = %d. Error = %x.", 
        arIntervalID, nRetVal);
      return Error ("Unable to get the account usage map.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // do a queryinterface to get the interface ...
    nRetVal = pDispAcctMap->QueryInterface (IID_ICOMAccountUsageMap, 
      reinterpret_cast<void**>(&arpAcctMap));
    if (!SUCCEEDED(nRetVal))
    {
      if (pDispAcctMap != NULL)
      {
        pDispAcctMap->Release();
        pDispAcctMap = NULL;
      }
      if (arpUIColl != NULL)
      {
        arpUIColl->Release();
        arpUIColl = NULL;
      }
      mLogger.LogVarArgs(LOG_ERROR, 
        "Unable to get the interface for the account map. Error = %x.", nRetVal);
      return Error ("Unable to get the interface for the account map.", 
        IID_ICOMUsageServer, nRetVal);
    }
    // release the ref to account map ...
    pDispAcctMap->Release();
    pDispAcctMap = NULL;
  }
  catch (_com_error e)
  {
    if (arpUIColl != NULL)
    {
      arpUIColl->Release();
      arpUIColl = NULL;
    }
    if (pDispAcctMap != NULL)
    {
      pDispAcctMap->Release();
      pDispAcctMap = NULL;
    }
    if (arpAcctMap != NULL)
    {
      arpAcctMap->Release();
      arpAcctMap = NULL;
    }
    nRetVal = e.Error();
    mLogger.LogVarArgs (LOG_ERROR,  
      "Unable to create account map for interval = %d. Error = %x", arIntervalID, nRetVal);
    mLogger.LogVarArgs (LOG_ERROR, "DoRecurringEvent() failed. Error Description = %s",
      (char*) e.Description());
    return Error ("Unable to create account map.", 
      IID_ICOMUsageServer, nRetVal);
  }
  return nRetVal;
}

HRESULT CCOMUsageServer::InvokeAdapterExportData (CycleTypeAdapterColl &arCycleTypeAdapterColl, 
                                                  wstring &arCycleType, ROWSETLib::IMTSQLRowsetPtr &arRowset,
                                                  const long &arAcctID, const long &arIntervalID,
																									COMDBOBJECTSLib::ICOMSummaryViewPtr &arpSummaryView,
                                                  const long &arGroupNum)
{
  // local variables ...
  HRESULT nRetVal=S_OK;
  IMTDataExporterPtr  dataExporterV1;
  IMTDataExporter2Ptr dataExporterV2;
  _bstr_t name;
  _bstr_t queryTag;
  _variant_t vtParam;
  
  mLogger.LogVarArgs(LOG_DEBUG, 
		"Entering InvokeAdapterExportData with account <%d> interval <%d>", 
		arAcctID, arIntervalID);
	
  // find the adapter collection ...
  CycleTypeAdapterCollIter it = arCycleTypeAdapterColl.find (arCycleType);
  if (it != arCycleTypeAdapterColl.end())
  {
		CycleTypeAdapterInfo *pCycleTypeAdapterInfo=(*it).second;
		
		mLogger.LogVarArgs(LOG_DEBUG, 
			"Before Iterator with account <%d> interval <%d>", 
			arAcctID, arIntervalID);
		
    // get the adapter list ...  
		AdapterColl& adapterColl = pCycleTypeAdapterInfo->GetAdapterColl (arGroupNum);
    for (AdapterCollIter Iter = adapterColl.begin(); Iter != adapterColl.end(); Iter++)
    {
			mLogger.LogVarArgs(LOG_DEBUG, 
				"Inside Iterator with account <%d> interval <%d>", 
				arAcctID, arIntervalID);
			
      // get a ptr to the data exporter in the list ...
      AdapterInfo *pAdapterInfo = (*Iter);
      if (pAdapterInfo->IsSuccessful())
      {
				mLogger.LogVarArgs(LOG_DEBUG, 
					"Adapter info is successful for account <%d> interval <%d>", 
					arAcctID, arIntervalID);
				
				if (pAdapterInfo->GetVersion() >= 2)
					dataExporterV2 = pAdapterInfo->GetAdapterV2();
				else
					dataExporterV1 = pAdapterInfo->GetAdapterV1();

        name = pAdapterInfo->GetAdapterName();
				
				mLogger.LogVarArgs(LOG_DEBUG, "Adapter name is <%s>", (const char*) name);
        
        // call the data exporter ...
        try
        {
          // insert a row into the recurring event acct log ... clear the query ... 
          arRowset->ClearQuery();
          arRowset->BeginTransaction();
          
          queryTag = "__INSERT_TO_RECURRING_EVENT_ACCT_LOG__";
          arRowset->SetQueryTag (queryTag);
          
          vtParam = (long) arAcctID;
          arRowset->AddParam (MTPARAM_ACCOUNTID, vtParam);
          vtParam = (long) pAdapterInfo->GetRecurringEventRunID();
          arRowset->AddParam (MTPARAM_RUNID, vtParam);
          
          arRowset->Execute();
          
          // call export data ...
					if (pAdapterInfo->GetVersion() >= 2)
						dataExporterV2->ExportData(arpSummaryView);
					else
						dataExporterV1->ExportData(arpSummaryView);

          // commit the transaction ...
          arRowset->CommitTransaction();
        }
        catch (_com_error e)
        {
          nRetVal = e.Error();
          mLogger.LogVarArgs (LOG_ERROR,  
															"Unable to export data for account = %d, interval = %d. Error = %x", 
															arAcctID, arIntervalID, nRetVal);
          mLogger.LogVarArgs (LOG_ERROR,  
															"ExportData() failed for %s. Error Description = %s", 
															(char*)pAdapterInfo->GetAdapterName(), (char*)e.Description());
          pAdapterInfo->MarkAsFailed();
          arRowset->RollbackTransaction();
        }
        catch (...)
        {
          mLogger.LogVarArgs (LOG_ERROR,  
															"Unable to export data for account = %d, interval = %d and adapter = %s. Error = %x", 
															arAcctID, arIntervalID, (char*)pAdapterInfo->GetAdapterName(), nRetVal);
          pAdapterInfo->MarkAsFailed();
          arRowset->RollbackTransaction();
        }
      }
			else
			{
				mLogger.LogVarArgs(LOG_DEBUG, 
													 "Adapter info is NOT successful for account <%d> interval <%d>", 
													 arAcctID, arIntervalID);
			}
			
      // move back to first record ...
			if (arpSummaryView->GetRecordCount() > 0)
				arpSummaryView->MoveFirst();
    }
  }
	
  mLogger.LogVarArgs(LOG_DEBUG, 
										 "Leaving InvokeAdapterExportData with account <%d> interval <%d>", 
										 arAcctID, arIntervalID);

  return S_OK;
}

HRESULT CCOMUsageServer::InvokeAdapterExportComplete (CycleTypeAdapterColl &arCycleTypeAdapterColl, 
                                                      wstring &arCycleType, ROWSETLib::IMTSQLRowsetPtr &arRowset, 
                                                      const long &arIntervalID,
                                                      const long &arGroupNum)
{
  // local variables ...
  HRESULT nRetVal=S_OK;
  IMTDataExporterPtr  dataExporterV1;
  IMTDataExporter2Ptr dataExporterV2;
  _bstr_t name;
  _bstr_t queryTag;
  _variant_t vtParam;
  
  // find the adapter collection ...
  CycleTypeAdapterCollIter it = arCycleTypeAdapterColl.find (arCycleType);
  if (it != arCycleTypeAdapterColl.end())
  {
		CycleTypeAdapterInfo *pCycleTypeAdapterInfo=(*it).second;

    // get the adapter list ...  
    AdapterColl& adapterColl = pCycleTypeAdapterInfo->GetAdapterColl (arGroupNum);
    for (AdapterCollIter Iter = adapterColl.begin(); Iter != adapterColl.end(); Iter++)
    {
      // get the adapter info ...
      AdapterInfo *pAdapterInfo = (*Iter);
			if (pAdapterInfo->GetVersion() >= 2)
				dataExporterV2 = pAdapterInfo->GetAdapterV2();
			else
				dataExporterV1 = pAdapterInfo->GetAdapterV1();
      name = pAdapterInfo->GetAdapterName();

      if (pAdapterInfo->IsSuccessful())
      {
        try
        {
          // log a debug message ...
          mLogger.LogVarArgs (LOG_DEBUG, 
            "Completing export for adapter <%s> for usage interval <%d>.",
            (char*)name, arIntervalID);
          
          // call the export complete ...
					if (pAdapterInfo->GetVersion() >= 2)
						dataExporterV2->ExportComplete();
					else
						dataExporterV1->ExportComplete();

					try
					{
						// update the recurring event log ...
						arRowset->Clear();
						
						arRowset->BeginTransaction();
						
						// remove the entries from the recurring event acct log ...
						queryTag = "__REMOVE_RECURRING_EVENT_ACCT_LOG__";
						arRowset->SetQueryTag (queryTag);
						
						vtParam = (long) pAdapterInfo->GetRecurringEventRunID();
						arRowset->AddParam (MTPARAM_RUNID, vtParam);
						
						arRowset->Execute();
						
						// update the entry in the recurring event run log ...
						queryTag = "__UPDATE_RECURRING_EVENT_LOG__";
						arRowset->SetQueryTag (queryTag);
						
						vtParam = (long) pAdapterInfo->GetRecurringEventRunID();
						arRowset->AddParam (MTPARAM_RUNID, vtParam);
						
						arRowset->Execute();
						
						arRowset->CommitTransaction();
					}
					catch (_com_error e)
					{
						mLogger.LogVarArgs (LOG_ERROR,  
																"Unable to remove recurring event run log info for interval = %d and adapter = %s. Error = %x", 
																arIntervalID, (char*)pAdapterInfo->GetAdapterName(), nRetVal);
						arRowset->RollbackTransaction();
					}
        }
        catch (_com_error e)
        {
          nRetVal = e.Error();
          mLogger.LogVarArgs (LOG_ERROR,  
            "Unable to complete export data for interval = %d. Error = %x", 
            arIntervalID, nRetVal);
          mLogger.LogVarArgs (LOG_ERROR,
            "ExportComplete() failed for %s. Error Description = %s",
            (char*)pAdapterInfo->GetAdapterName(), (char*)e.Description());
        }
        catch (...)
        {
          mLogger.LogVarArgs (LOG_ERROR,  
            "Unable to complete export data for interval = %d. Error = %x", 
            arIntervalID, nRetVal);
          mLogger.LogVarArgs (LOG_ERROR,
            "ExportComplete() failed for %s. Unhandled exception.",
            (char*)pAdapterInfo->GetAdapterName());
        }
      }

      delete pAdapterInfo;
    }
  }
  return S_OK;
}


HRESULT CCOMUsageServer::InvokeAdapterExecute(CycleTypeAdapterColl &arPerInterval, 
																							wstring &arCycleType, ROWSETLib::IMTSQLRowsetPtr &arRowset, 
																							const long &arIntervalID,
																							const long &arGroupNum)
{
  HRESULT nRetVal=S_OK;
  IMTDataExporter2Ptr dataExporterV2;
  _bstr_t name;
  _bstr_t queryTag;
  _variant_t vtParam;
  
  //gets the collection of groups for the specified cycle type
  CycleTypeAdapterCollIter it = arPerInterval.find(arCycleType);
  if (it != arPerInterval.end())
  {
		CycleTypeAdapterInfo *pCycleTypePerInterval=(*it).second;

    //gets the collection of adapters fot the particular group   
    AdapterColl& adapterColl = pCycleTypePerInterval->GetAdapterColl (arGroupNum);
    for (AdapterCollIter Iter = adapterColl.begin(); Iter != adapterColl.end(); Iter++)
    {
      // get the adapter info ...
      AdapterInfo *pAdapterInfo = (*Iter);
      name = pAdapterInfo->GetAdapterName();
      dataExporterV2 = pAdapterInfo->GetAdapterV2();

      if (pAdapterInfo->IsSuccessful()) {
				try {
					mLogger.LogVarArgs (LOG_DEBUG, 
															"Executing adapter <%s> exactly once for usage interval <%d>.",
															(char*) name, arIntervalID);
          

					dataExporterV2->Execute(arIntervalID);
        }
        catch (_com_error e) {
          nRetVal = e.Error();
          mLogger.LogVarArgs(LOG_ERROR,
														 "Execute() failed for adapter %s on interval <%d>. Unhandled COM exception. Error = %x: %s",
														 (char*) name, arIntervalID, nRetVal, (char*) e.Description());
					pAdapterInfo->MarkAsFailed();
        }
				catch (...) {
          mLogger.LogVarArgs(LOG_ERROR,
														 "Execute() failed for adapter %s on interval <%d>. Unhandled non-COM exception.",
														 (char*) name, arIntervalID);
					pAdapterInfo->MarkAsFailed();
				}

      }
			
    }
  }
  return S_OK;
}


STDMETHODIMP CCOMUsageServer::DoRecurringEvent(BSTR aUsageCyclePeriodType, MTRecurringEvent aEvent)
{
  _bstr_t bstrState, bstrNextState;
  _bstr_t bstrEventPeriod;
  _bstr_t bstrPeriodType;
  _bstr_t bstrPeriodTag;
  wstring wstrPeriodType (aUsageCyclePeriodType);
	COMDBOBJECTSLib::ICOMSummaryViewPtr pSummaryView;
  HRESULT nRetVal=S_OK;
  _variant_t vtIntervalEOF, vtEOF;
  _variant_t vtIndex, vtValue, vtParam;
  long nAcctID, nIntervalID;
  ICOMAccountUsageMap * pAcctMap=NULL;
  ICOMUsageIntervalColl * pUIColl=NULL ;
  _bstr_t queryTag;
  DBUsageCycleCollection *pUsageCycle=NULL;
  wstring billingCycleType;
  wstring defaultCycleType (UC_DEFAULT_STR);
  long groupNum=0;
  long numGroups=0;
  
  // if the period is beginning set the status to 'N' ...
  if (aEvent == EVENT_PERIOD_BEGIN)
  {
    bstrState = USAGE_INTERVAL_NEW;
    bstrNextState = USAGE_INTERVAL_OPEN;
    bstrEventPeriod = TAG_EVENT_PERIOD_BEGINNING;
  }
  // else if the period is end set the status to 'E' ...
  else if (aEvent == EVENT_PERIOD_SOFT_CLOSE)
  {
    bstrState = USAGE_INTERVAL_EXPIRED;
    bstrNextState = USAGE_INTERVAL_CLOSED;
    bstrEventPeriod = TAG_EVENT_PERIOD_SOFT_CLOSE;
  }
  // else if the period is end set the status to 'S' ...
  else if (aEvent == EVENT_PERIOD_HARD_CLOSE)
  {
    bstrState = USAGE_INTERVAL_SHUTDOWN;
    bstrNextState = USAGE_INTERVAL_HARD_CLOSED;
    bstrEventPeriod = TAG_EVENT_PERIOD_HARD_CLOSE;
  }
  // otherwise, 
  else
  {
    mLogger.LogVarArgs (LOG_ERROR,  
      "Invalid recurring event type. Type = %d", (long) aEvent);
    return Error ("Invalid recurring event type.", 
      IID_ICOMUsageServer, E_FAIL);
  }
  
  // if the period type is billing ...
  if ((_wcsicmp(wstrPeriodType.c_str(), USAGE_CYCLE_PERIOD_BILLING)) == 0)
  {
    bstrPeriodType = USAGE_CYCLE_PERIOD_BILLING;
    bstrPeriodTag = TAG_PERIOD_TYPE_BILLING;
  }
  // else if period type is time ...
  else if ((_wcsicmp(wstrPeriodType.c_str(), USAGE_CYCLE_PERIOD_TIME)) == 0)
  {
    bstrPeriodType = USAGE_CYCLE_PERIOD_TIME;
    bstrPeriodTag = TAG_PERIOD_TYPE_TIME;
  }
  // otherwise ..
  else
  {
    mLogger.LogVarArgs (LOG_ERROR,  
      "Invalid recurring event period type. Period Type = %s", ascii(wstrPeriodType).c_str());
    return Error ("Invalid recurring event period type.", 
      IID_ICOMUsageServer, E_FAIL);
  }
  
  // start the try ...
  try
  {
    // create the rowset ....
		ROWSETLib::IMTSQLRowsetPtr rowset (MTPROGID_SQLROWSET);
    
    // intialize the rowset ...
    rowset->Init(USAGE_SERVER_QUERY_DIR);
    
    // initialize the usage interval collection ...
    GetUsageIntervalCollection (bstrState, bstrPeriodType, pUIColl);

    // while we have usage intervals to iterate thru ...
    pUIColl->get_EOF(&vtIntervalEOF);
    while (vtIntervalEOF.boolVal == VARIANT_FALSE)
    {
      // get the interval id ...
      vtIndex = DB_INTERVAL_ID;
      pUIColl->get_Value (vtIndex, &vtValue);
      nIntervalID = vtValue.lVal;

      // get the cycle type ...
      vtIndex = DB_CYCLE_TYPE;
      pUIColl->get_Value (vtIndex, &vtValue);
      billingCycleType = vtValue.bstrVal;

      // log a debug message ...
      mLogger.LogVarArgs (LOG_DEBUG, "Processing %s for usage interval <%d>.",
        (char*)bstrEventPeriod, nIntervalID);

      //reads the recurring event configuration file and populates the two adapter collections
			CycleTypeAdapterColl perAccountAdapters;
			CycleTypeAdapterColl perIntervalAdapters;
      ReadRecurringEventFile (bstrPeriodTag, bstrEventPeriod, nIntervalID, 
															bstrState, bstrPeriodType, billingCycleType,
															rowset, perAccountAdapters, perIntervalAdapters, numGroups);

      // update usage interval status ...
      UpdateUsageIntervalStatus (bstrNextState, nIntervalID, pUIColl);

			// log a debug message ...
      mLogger.LogVarArgs (LOG_DEBUG, 
        "Processing recurring events for usage interval <%d>.",
        nIntervalID);

			// check to see if either the default adapters or the type requested to
			// be run has any per account adapters
			BOOL havePerAccountAdapters = FALSE;

			CycleTypeAdapterCollIter test = perAccountAdapters.find(billingCycleType);
			if (test != perAccountAdapters.end() && (*test).second->CountAdapters() > 0)
			{
				mLogger.LogVarArgs(LOG_DEBUG,
													 "%d per account adapters for the given billing cycle type",
													 (*test).second->CountAdapters());
				havePerAccountAdapters = TRUE;
			}

			test = perAccountAdapters.find(defaultCycleType);
			if (test != perAccountAdapters.end() && (*test).second->CountAdapters() > 0)
			{
				mLogger.LogVarArgs(LOG_DEBUG,
													 "%d per account adapters for the default billing cycle type",
													 (*test).second->CountAdapters());
				havePerAccountAdapters = TRUE;
			}

			if (havePerAccountAdapters)
			{
				// get the account usage map ...
				// NOTE: this method is expensive and is only necessary if we have perAccountAdapters
				GetAccountUsageMapForInterval (nIntervalID, pUIColl, pAcctMap);
			}

      try
      {
        // for each group ...
        for (groupNum=0; groupNum < numGroups; groupNum++)
        {
					//starts the account loop only if there are perAccount adapters
					if (havePerAccountAdapters)
          {

						mLogger.LogVarArgs(LOG_DEBUG,
															 "At least one per account adapter in use");

						// while we still have accounts to export data for
						ASSERT(pAcctMap);
						pAcctMap->get_EOF(&vtEOF);
						BOOL bEmptyRowset = TRUE;

						while (vtEOF.boolVal == VARIANT_FALSE)
            {
							// get the account id ...
							bEmptyRowset = FALSE;
							vtIndex = DB_ACCOUNT_ID;
							pAcctMap->get_Value (vtIndex, &vtValue);
							nAcctID = vtValue.lVal;
            
							// create a data accessor object and get the summary view for it ...
							COMDBOBJECTSLib::ICOMDataAccessorPtr dataAccessor (MTPROGID_DATAACCESSOR);
							
							// add the interval and account id as properties ...
							dataAccessor->PutAccountID (nAcctID);
							dataAccessor->PutIntervalID (nIntervalID);
							
							// get the singleton's 
							if (pUsageCycle == NULL)
							{
								pUsageCycle = DBUsageCycleCollection::GetInstance();
							}
							
							// get the summary view ... 
							pSummaryView = dataAccessor->GetSummaryView(L"");
							
							// invoke ExportData on the default billing cycle adapter list...
							InvokeAdapterExportData (perAccountAdapters, defaultCycleType, rowset,
																			 nAcctID, nIntervalID, pSummaryView, groupNum);
							
							// invoke ExportData on the billing cycle adapter list ...
							InvokeAdapterExportData (perAccountAdapters, billingCycleType, rowset,
																			 nAcctID, nIntervalID, pSummaryView, groupNum);
							
							// release the summary view ...
							pSummaryView.Release();
							
							// move to the next record in the list ...
							pAcctMap->MoveNext();
							pAcctMap->get_EOF(&vtEOF);
						}

						// move back to first account ...
						ASSERT(pAcctMap);
						if(!bEmptyRowset)
							pAcctMap->MoveFirst();
					}
					else
          {
						mLogger.LogVarArgs(LOG_DEBUG,
															 "No per account adapters in use");
          }
					
          //invokes the ExportComplete method for per acount adapters
          InvokeAdapterExportComplete(perAccountAdapters, defaultCycleType, rowset, nIntervalID, groupNum);
          InvokeAdapterExportComplete(perAccountAdapters, billingCycleType, rowset, nIntervalID, groupNum);

					//invokes the Execute method for per interval adapters
          InvokeAdapterExecute(perIntervalAdapters, defaultCycleType, rowset, nIntervalID, groupNum);
          InvokeAdapterExecute(perIntervalAdapters, billingCycleType, rowset, nIntervalID, groupNum);

          //invokes the ExportComplete method for per interval adapters
          InvokeAdapterExportComplete(perIntervalAdapters, defaultCycleType, rowset, nIntervalID, groupNum);
          InvokeAdapterExportComplete(perIntervalAdapters, billingCycleType, rowset, nIntervalID, groupNum);
        }

				// release all the allocated stuff...
				if (pAcctMap)
				{
					pAcctMap->Release();
					pAcctMap = NULL;
				}
      }
      catch (_com_error e)
      {
        if (pAcctMap != NULL)
        {
          pAcctMap->Release();
          pAcctMap = NULL;
        }
        nRetVal = e.Error();
        mLogger.LogVarArgs (LOG_ERROR, "Unable to run recurring event for interval = %d. Error = %x",
          nIntervalID, nRetVal);
        mLogger.LogVarArgs (LOG_ERROR, "DoRecurringEvent() failed. Error Description = %s",
          (char*) e.Description());
      }
      try
      {
        // update the usage interval status ...
        UpdateUsageIntervalStatus (bstrNextState, nIntervalID, pUIColl);
      }
      catch (_com_error e)
      {
        if (pUIColl != NULL)
        {
          pUIColl->Release();
          pUIColl = NULL;
        }
        if (pUsageCycle != NULL)
        {
          DBUsageCycleCollection::ReleaseInstance();
          pUsageCycle = NULL;
        }
        nRetVal = e.Error();
        return Error ("Unable to update status for interval.", 
          IID_ICOMUsageServer, nRetVal);
      }
      // move to the next record ...
      pUIColl->MoveNext();
      pUIColl->get_EOF(&vtIntervalEOF);
    }
  }
  catch (_com_error e)
  {
    nRetVal = e.Error();
    if (pAcctMap != NULL)
    {
      pAcctMap->Release();
      pAcctMap = NULL;
    }
    if (pUIColl != NULL)
    {
      pUIColl->Release();
      pUIColl = NULL;
    }
    if (pUsageCycle != NULL)
    {
      DBUsageCycleCollection::ReleaseInstance();
      pUsageCycle = NULL;
    }
    mLogger.LogVarArgs (LOG_ERROR, "Unable to run recurring event for interval = %d. Error = %x",
      nIntervalID, nRetVal);
    mLogger.LogVarArgs (LOG_ERROR, "DoRecurringEvent() failed. Error Description = %s",
      (char*) e.Description());
    return Error ("Unable to run recurring event.", 
      IID_ICOMUsageServer, nRetVal);
  }
  
  if (pUIColl != NULL)
  {
    pUIColl->Release();
  }
  if (pUsageCycle != NULL)
  {
    DBUsageCycleCollection::ReleaseInstance();
    pUsageCycle = NULL;
  }
  return S_OK;
}

STDMETHODIMP CCOMUsageServer::RerunRecurringEvent(long aRunID, VARIANT_BOOL aFullRun)
{
	ROWSETLib::IMTSQLRowsetPtr rowset;
  HRESULT nRetVal=S_OK;
  _variant_t vtEOF, vtParam;
  _bstr_t queryTag;
  long nIntervalID=0, nAcctID=0;
  _bstr_t name, progID, adapter;
  vector<long> acctList;
  IMTDataExporterPtr  dataExporterV1;
  IMTDataExporter2Ptr dataExporterV2;
  LPDISPATCH pDispAcctMap=NULL;
  ICOMAccountUsageMap * pAcctMap=NULL;
  DBUsageCycleCollection *pUsageCycle=NULL;
  BOOL bDataExport=TRUE;
	BOOL bExecute = TRUE;

	COMDBOBJECTSLib::ICOMSummaryViewPtr pSummaryView;
  _variant_t vtValue;
  _bstr_t configFile;
  
  try
  {
    // create the rowset ...
    nRetVal = rowset.CreateInstance (MTPROGID_SQLROWSET);
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, "Unable to create instance of MTSQLRowset. Error = %x",
        nRetVal);
      return Error ("Unable to create instance of MTSQLRowset.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // initialize the rowset ...
    nRetVal = rowset->Init(USAGE_SERVER_QUERY_DIR);
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, "Unable to initialize MTSQLRowset. Error = %x",
        nRetVal);
      return Error ("Unable to initialize MTSQLRowset.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // get the info for the run id ...
    queryTag = "__GET_RECURRING_EVENT_RUN_INFO__";
    rowset->SetQueryTag(queryTag);
    
    // add the run id as a parameter ...
    vtParam = aRunID;
    rowset->AddParam (MTPARAM_RUNID, vtParam);
    
    // execute the query ...
    rowset->Execute();
    
    // if we have no information for the run id ...
    if (rowset->GetRecordCount() == 0)
    {
      // return error ...
      rowset.Release();
      nRetVal = DB_ERR_NO_ROWS;
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get recurring event run info for run id = %d. Error = %x",
        aRunID, nRetVal);
      return Error ("Unable to get recurring event run info for run id.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // get the prog id, interval id and adapter name ...
    progID = rowset->GetValue(DB_PROGID);
    nIntervalID = rowset->GetValue(DB_INTERVAL_ID);
    name = rowset->GetValue(DB_ADAPTER_NAME);
    configFile = rowset->GetValue(DB_CONFIG_FILE);
    
    // if we are not doing a full run ... 
    if (aFullRun == VARIANT_FALSE)
    {
      // get the accounts that have been processed for the run
      queryTag = "__GET_ACCOUNTS_FOR_RUN__";
      rowset->SetQueryTag(queryTag);
      
      // add the run id as a parameter ...
      vtParam = aRunID;
      rowset->AddParam (MTPARAM_RUNID, vtParam);
      
      // execute the query ...
      rowset->Execute();
      
      // iterate thru the rowset and add each account into the acctlist ...
      vtEOF = rowset->GetRowsetEOF();
      while (vtEOF.boolVal == VARIANT_FALSE)
      {
        // get the account id ...
        nAcctID = rowset->GetValue(DB_ACCOUNT_ID);
        
        // add it to the list ...
        acctList.push_back(nAcctID);
        
        // move to the next record ...
        rowset->MoveNext();
        vtEOF = rowset->GetRowsetEOF();
      }
    }
    // otherwise ... we're doing a full run 
    else
    {
      // remove all the accounts that have been processed ...
      queryTag = "__REMOVE_ACCOUNTS_FOR_RUN__";
      rowset->SetQueryTag(queryTag);
      
      // add the run id as a parameter ...
      vtParam = aRunID;
      rowset->AddParam (MTPARAM_RUNID, vtParam);
      
      // execute the query ...
      rowset->Execute();
    }
  }
  catch (_com_error e)
  {
    rowset.Release();
    mLogger.LogVarArgs (LOG_ERROR, "Unable to initialize recurring event rerun for run = %d. Error = %x",
      nIntervalID, nRetVal);
    mLogger.LogVarArgs (LOG_ERROR, "RerunRecurringEvent() failed. Error Description = %s",
      (char*) e.Description());
    return Error ("Unable to initialize recurring event rerun.", 
      IID_ICOMUsageServer, nRetVal);
  }
  
  // create the recurring event adapter ...
	long nAdapterInterfaceVersion;
  try
  {
    // log a debug message ...
    mLogger.LogVarArgs (LOG_DEBUG, "Creating adapter <%s> for usage interval <%d>.",
      (char*)name, nIntervalID);
    
		//creates the adapter object and identifies the version of the interface which is implemented
		nAdapterInterfaceVersion = 2;
		nRetVal = dataExporterV2.CreateInstance((char*)progID);
		if (FAILED(nRetVal))
		{
			nAdapterInterfaceVersion = 1;
			nRetVal = dataExporterV1.CreateInstance((char*)progID);
			if (FAILED(nRetVal))
			{
				mLogger.LogVarArgs (LOG_ERROR, "Unable to create data export adapter with id = %s. Error = %x", (char*) progID, nRetVal);
				return Error ("Unable to create data export adapter", IID_ICOMUsageServer, nRetVal);
			}
		}
		mLogger.LogVarArgs(LOG_DEBUG, "Adapter %s implements version %d of the adapter interface",
											 (char*) progID, nAdapterInterfaceVersion);

    
    //initializes the adapter
		if (nAdapterInterfaceVersion >= 2)
			dataExporterV2->Initialize(configFile);
		else
			dataExporterV1->Initialize(configFile);
    mLogger.LogVarArgs (LOG_DEBUG, "Initialized adapter <%s> for usage interval <%d>.", (char*)name, nIntervalID);
  }
  catch (_com_error e)
  {
    rowset.Release();
    nRetVal = e.Error();
    _bstr_t errMsg = e.Description(); 
    mLogger.LogVarArgs(LOG_ERROR, "Adapter <%s> Initialize() failed. Error Description = %s",
											 (char*)name, (char*) errMsg);
    return Error ("Data export adapter Initialize() failed.", IID_ICOMUsageServer, nRetVal);
  }
  catch (...)
  {
    rowset.Release();
    mLogger.LogVarArgs(LOG_ERROR, "Adapter <%s> Initialize() failed. Unhandled exception.", (char*) name);
    return Error ("Data export adapter Initialize() failed.", IID_ICOMUsageServer, nRetVal);
  }
  
	//is the adapter a per interval adapter?
	VARIANT_BOOL bPerIntervalAdapter = VARIANT_FALSE;
	if (nAdapterInterfaceVersion >= 2)
		bPerIntervalAdapter = dataExporterV2->GetPerInterval();

 	if (bPerIntervalAdapter == VARIANT_FALSE) {

		try
		{
			// create a account usage map object ...
			nRetVal = CoCreateInstance (CLSID_COMAccountUsageMap, NULL, CLSCTX_INPROC_SERVER,
																	IID_ICOMAccountUsageMap, (void **) &pDispAcctMap);
			if (!SUCCEEDED(nRetVal))
			{
				rowset.Release();
				mLogger.LogVarArgs (LOG_ERROR, "Unable to create account usage map. Error = %x", nRetVal);
				return Error ("Unable to create account usage map.", 
											IID_ICOMUsageServer, nRetVal);
			}
			else
			{
				// do a queryinterface to get the interface ...
				nRetVal = pDispAcctMap->QueryInterface (IID_ICOMAccountUsageMap, 
																								reinterpret_cast<void**>(&pAcctMap));
				if (!SUCCEEDED(nRetVal))
				{
					rowset.Release();
					pDispAcctMap->Release(); // release the object created by CoCreateInstance
					mLogger.LogVarArgs (LOG_ERROR, 
															"Unable to get the interface for the account usage map. Error = %x", nRetVal);
					return Error ("Unable to get the interface for the account usage map.", 
												IID_ICOMUsageServer, nRetVal);
				}
				// release the dispatch interface ...
				pDispAcctMap->Release();
				pDispAcctMap = NULL;
      
      // call init ...
				nRetVal = pAcctMap->InitByIntervalID(nIntervalID);
				if (!SUCCEEDED(nRetVal))
				{
					rowset.Release();
					pDispAcctMap->Release(); // release the object created by CoCreateInstance
					pAcctMap->Release(); // release the object created by CoCreateInstance
					mLogger.LogVarArgs (LOG_ERROR, 
															"Unable to initialize account usage map. Error = %x", nRetVal);
					return Error ("Unable to initialize account usage map.", 
												IID_ICOMUsageServer, nRetVal);
				}
			}
		}
		catch (_com_error e)
		{
			if (pDispAcctMap != NULL)
			{
				pDispAcctMap->Release();
				pDispAcctMap = NULL;
			}
			if (pAcctMap != NULL)
			{
				pAcctMap->Release();
				pAcctMap = NULL;
			}
			rowset.Release();
			nRetVal = e.Error();
			mLogger.LogVarArgs (LOG_ERROR,  
													"Unable to initialize account usage map for interval <%d>. Error = %x", 
													nIntervalID, nRetVal);
			_bstr_t errMsg = e.Description(); 
			mLogger.LogVarArgs (LOG_ERROR, "Error Description = %s", (char*) errMsg);
			return Error ("Unable to initialize account usage map.", 
										IID_ICOMUsageServer, nRetVal);
		}
  
		try
		{
			// for each account ...
			pAcctMap->get_EOF(&vtEOF);
			while (vtEOF.boolVal == VARIANT_FALSE)
			{
				// get the account id ...
				pAcctMap->get_Value (((_variant_t)DB_ACCOUNT_ID), &vtValue);
				nAcctID = vtValue.lVal;
      
				// if the account is not present in the acct list ...
				vector<long>::const_iterator it;
				bool found = false;
				for (it = acctList.begin(); it != acctList.end(); it++)
					if (*it == nAcctID)
						found = true;

				if (!found)
				{
					if (pUsageCycle == NULL)
					{
						pUsageCycle = DBUsageCycleCollection::GetInstance();
					}
        
					// create a data accessor object and get the summary view for it ...
					COMDBOBJECTSLib::ICOMDataAccessorPtr dataAccessor (MTPROGID_DATAACCESSOR);
        
					// add the interval and account id as properties ...
					dataAccessor->PutAccountID (nAcctID);
					dataAccessor->PutIntervalID (nIntervalID);
        
        // get the summary view ... 
					pSummaryView = dataAccessor->GetSummaryView(L"");
        
					// call the data exporter ...
					try
					{
						// insert a row into the recurring event acct log ... clear the query ... 
						rowset->ClearQuery();
						rowset->BeginTransaction();
          
						queryTag = "__INSERT_TO_RECURRING_EVENT_ACCT_LOG__";
						rowset->SetQueryTag (queryTag);
          
						vtParam = (long) nAcctID;
						rowset->AddParam (MTPARAM_ACCOUNTID, vtParam);
						vtParam = (long) aRunID;
						rowset->AddParam (MTPARAM_RUNID, vtParam);
          
						rowset->Execute();
          
						//exports the data to the adapter
						if (nAdapterInterfaceVersion >= 2)
							dataExporterV2->ExportData(pSummaryView);
						else
							dataExporterV1->ExportData(pSummaryView);

						// commit the transaction ...
						rowset->CommitTransaction();
					}
					catch (_com_error e)
					{
						nRetVal = e.Error();
						mLogger.LogVarArgs (LOG_ERROR,  
																"Unable to export data for account = %d, interval = %d. Error = %x", 
																nAcctID, nIntervalID, nRetVal);
						mLogger.LogVarArgs (LOG_ERROR,  
																"ExportData() failed for %s. Error Description = %s", 
																(char*)name, (char*)e.Description());
						bDataExport = TRUE;
						rowset->RollbackTransaction();
					}
					catch (...)
					{
						mLogger.LogVarArgs (LOG_ERROR,  
																"Unable to export data for account = %d, interval = %d and adapter = %s. Error = %x", 
																nAcctID, nIntervalID, (char*)name, nRetVal);
						bDataExport = TRUE;
						rowset->RollbackTransaction();
					}
				}
				// move to the next row ...
				pAcctMap->MoveNext();
				pAcctMap->get_EOF(&vtEOF);
			}
		}
		catch (_com_error e)
		{
			if (pAcctMap != NULL)
			{
				pAcctMap->Release();
				pAcctMap = NULL;
			}
			if (pUsageCycle != NULL)
			{
				DBUsageCycleCollection::ReleaseInstance();
				pUsageCycle = NULL;
			}
    
		}
		// clear the acct list ...
		acctList.clear();
  
		// release the account map ...
		if (pAcctMap != NULL)
		{
			pAcctMap->Release();
			pAcctMap = NULL;
		}
		if (pUsageCycle != NULL)
		{
			DBUsageCycleCollection::ReleaseInstance();
			pUsageCycle = NULL;
		}

  } else {
		//otherwise the adapter is a per interval adapter so perform the Execute method

		try {
			mLogger.LogVarArgs(LOG_DEBUG, "Executing adapter <%s> exactly once for usage interval <%d>.", (char*) progID, nIntervalID);
			dataExporterV2->Execute(nIntervalID);
		}
		catch (_com_error& e) {
			nRetVal = e.Error();
			mLogger.LogVarArgs(LOG_ERROR,
												 "Execute() failed for adapter %s on interval <%d>. Unhandled COM exception. Error = %x: %s",
												 (char*) progID, nIntervalID, nRetVal, (char*) e.Description());
			bExecute = FALSE;
		}
		catch (...) {
			mLogger.LogVarArgs(LOG_ERROR,
												 "Execute() failed for adapter %s on interval <%d>. Unhandled non-COM exception.",
												 (char*) progID, nIntervalID);
			bExecute = FALSE;
		}
	}

	//if the ExportData or Execute methods succeeded then perform the ExportComplete
  if ((bDataExport == TRUE) || (bExecute == TRUE)) {

		try {
			
			// log a debug message ...
			mLogger.LogVarArgs (LOG_DEBUG, 
													"Completing export for adapter <%s> for usage interval <%d>.",
													(char*)name, nIntervalID);
      
			// call the export complete ...
			if (nAdapterInterfaceVersion >= 2)
				dataExporterV2->ExportComplete();
			else
				dataExporterV1->ExportComplete();

			try
			{
				// update the recurring event log ...
				rowset->Clear();
				
				rowset->BeginTransaction();
				
				// remove the entries from the recurring event acct log ...
				queryTag = "__REMOVE_RECURRING_EVENT_ACCT_LOG__";
				rowset->SetQueryTag (queryTag);
				
				vtParam = (long) aRunID;
				rowset->AddParam (MTPARAM_RUNID, vtParam);
				
				rowset->Execute();
				
				// update the entry in the recurring event run log ...
				queryTag = "__UPDATE_RECURRING_EVENT_LOG__";
				rowset->SetQueryTag (queryTag);

				vtParam = (long) aRunID;
				rowset->AddParam (MTPARAM_RUNID, vtParam);

				rowset->Execute();
				
				rowset->CommitTransaction();
			}
			catch (_com_error e)
			{
				mLogger.LogVarArgs (LOG_ERROR,  
														"Unable to remove recurring event run log info for account = %d, interval = %d and adapter = %s. Error = %x", 
														nAcctID, nIntervalID, (char*)name, nRetVal);
				rowset->RollbackTransaction();
			}
		}
		catch (_com_error e)
		{
			nRetVal = e.Error();
			mLogger.LogVarArgs (LOG_ERROR,  
													"Unable to complete export data for interval = %d. Error = %x", 
													nIntervalID, nRetVal);
			mLogger.LogVarArgs (LOG_ERROR,
													"ExportComplete() failed for %s. Error Description = %s",
													(char*) progID, (char*)e.Description());
		}
		catch (...)
		{
			mLogger.LogVarArgs (LOG_ERROR,  
													"Unable to complete export data for interval = %d. Error = %x", 
													nIntervalID, nRetVal);
			mLogger.LogVarArgs (LOG_ERROR,
													"ExportComplete() failed for %s. Unhandled exception.",
													(char*) progID);
		}
	}

  // release the rowset and data exporter ...
  rowset.Release();
	
  return S_OK;
}

//adds Product Catalog interval data to t_pc_interval between the given
//start and end dates (inclusive)
STDMETHODIMP CCOMUsageServer::AddPCIntervals(DATE aStart, DATE aEnd) {
	try {

		//inits rowsets
		ROWSETLib::IMTSQLRowsetPtr cycleTypeRowset(MTPROGID_SQLROWSET);
		ROWSETLib::IMTSQLRowsetPtr cycleRowset(MTPROGID_SQLROWSET);
		ROWSETLib::IMTSQLRowsetPtr MaxIdRowset(MTPROGID_SQLROWSET);
		cycleTypeRowset->Init(USAGE_SERVER_QUERY_DIR);
		cycleRowset->Init(USAGE_SERVER_QUERY_DIR);
		MaxIdRowset->Init(USAGE_SERVER_QUERY_DIR);

		COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);

		long BatchSize = 200;
		COdbcTableInsertStatementPtr InsertStatement = odbcConnection->PrepareInsertStatement("t_pc_interval",200);
		COdbcPreparedArrayStatement* pInsertStatemnt = InsertStatement;

		long BatchCounter = 0;
		unsigned long IntervalCounter;
		MaxIdRowset->SetQueryString("select max(id_interval) from t_pc_interval");
		MaxIdRowset->Execute();
		_variant_t maxval = MaxIdRowset->GetValue(0l);
		if(maxval.vt == VT_NULL) {
			IntervalCounter = 1;
		}
		else {
			IntervalCounter = (long)maxval + 1;
		}

		// figure out the current ID we should use



		//converts and validates the dates passed in
		MTDate startDate = aStart;
		if (!startDate.IsValid()) {
			mLogger.LogThis(LOG_ERROR, "The start date passed into AddPCIntervals is not valid!");
			return E_FAIL;
		}
		MTDate endDate = aEnd;
		if (!endDate.IsValid()) {
			mLogger.LogThis(LOG_ERROR, "The end date passed into AddPCIntervals is not valid!");
			return E_FAIL;
		}
		mLogger.LogVarArgs(LOG_INFO, "Adding new PC interval data between [%d/%d/%d, %d/%d/%d]",
											 startDate.GetMonth(), startDate.GetDay(), startDate.GetYear(),
											 endDate.GetMonth(), endDate.GetDay(), endDate.GetYear());

		//gets all usage cycle types
		cycleTypeRowset->Init(USAGE_SERVER_QUERY_DIR);
		cycleTypeRowset->SetQueryTag("__GET_USAGE_CYCLE_TYPES__");
		cycleTypeRowset->Execute();

		//creates an adapter for each usage cycle type
		map<long, MTUSAGECYCLELib::IMTUsageCyclePtr> cycleTypeAdapters;
		while(cycleTypeRowset->GetRowsetEOF().boolVal == VARIANT_FALSE) {		
			//gets the prog id of the cycle's adapter 
			_variant_t val = cycleTypeRowset->GetValue("ProgID");
			_bstr_t adapterProgId(val);
			mLogger.LogVarArgs(LOG_DEBUG, "Creating adapter '%s'", (char*) adapterProgId);

			//gets the prog id of the cycle's adapter 
			long typeID = cycleTypeRowset->GetValue("CycleTypeID");
			
			//creates the cycle adapter
			MTUSAGECYCLELib::IMTUsageCyclePtr adapter((const char*)adapterProgId);
			cycleTypeAdapters[typeID] = adapter;
			cycleTypeRowset->MoveNext();
		}

		//gets all usage cycles
		cycleRowset->SetQueryTag("__GET_ALL_USAGE_CYCLES__");
		cycleRowset->Execute();

		mLogger.LogVarArgs(LOG_INFO, "Computing PC intervals (this may take several minutes)...");

		//iterates over all cycles
		DATE dtToday;
		_variant_t vtIndex, vtValue;
		while(cycleRowset->GetRowsetEOF().boolVal == VARIANT_FALSE) {		
			
      vtIndex = "id_usage_cycle";
      long cycleID = cycleRowset->GetValue(vtIndex);

			//skips over discontinued cycles
			if ((cycleID == 1) ||     //on-demand
					(cycleID == 457) ||   //quarterly, Jan end-of-month
					(cycleID == 485) ||   //quarterly, Feb end-of-month
					(cycleID == 513)) {   //quarterly, Mar end-of-month
				mLogger.LogVarArgs(LOG_DEBUG, "Skipping discontinued cycle %d", cycleID);
				cycleRowset->MoveNext();
				continue;
			}

      vtIndex = "id_cycle_type";
      long cycleTypeID = cycleRowset->GetValue(vtIndex);

			//populates the property collection
			MTUSAGESERVERLib::ICOMUsageCyclePropertyCollPtr properties("MTUsageServer.COMUsageCyclePropertyColl.1");
      switch (cycleTypeID) {
      case UC_MONTHLY:
        properties->AddProperty(UCP_DAY_OF_MONTH, cycleRowset->GetValue("day_of_month"));
        break;

      case UC_ON_DEMAND:
        break;
      case UC_DAILY:
        break;
        
      case UC_WEEKLY:
        properties->AddProperty(UCP_DAY_OF_WEEK, cycleRowset->GetValue("day_of_week"));
        break;
        
      case UC_BI_WEEKLY:
        properties->AddProperty(UCP_START_DAY, cycleRowset->GetValue("start_day"));
        properties->AddProperty(UCP_START_MONTH, cycleRowset->GetValue("start_month"));
        properties->AddProperty(UCP_START_YEAR, cycleRowset->GetValue("start_year"));
        break;
        
      case UC_SEMI_MONTHLY:
        properties->AddProperty(UCP_FIRST_DAY_OF_MONTH, cycleRowset->GetValue("first_day_of_month"));
        properties->AddProperty(UCP_SECOND_DAY_OF_MONTH, cycleRowset->GetValue("second_day_of_month"));
        break;
        
      case UC_QUARTERLY:
      case UC_SEMIANNUALLY:
      case UC_ANNUALLY:
        properties->AddProperty(UCP_START_DAY, cycleRowset->GetValue("start_day"));
        properties->AddProperty(UCP_START_MONTH, cycleRowset->GetValue("start_month"));
        break;
        
      default:
				mLogger.LogVarArgs(LOG_ERROR, "CCOMUsageServer::AddPCIntervals: cycle type ID '%d' is not supported!", cycleTypeID);
				return E_FAIL;
      }

			//computes all intervals for this cycle between the start and end dates
			DATE dtIntervalStart, dtIntervalEnd;
			MTDate today = startDate;
			while(today <= endDate) {
				
				//computes the interval's start and end dates based on "today"
				today.GetOLEDate(&dtToday);
				cycleTypeAdapters[cycleTypeID]->ComputeStartAndEndDate(dtToday, 
																															 (MTUSAGECYCLELib::ICOMUsageCyclePropertyCollPtr) properties,
																															 &dtIntervalStart,
																															 &dtIntervalEnd);
				
				//gets the interval's start and end dates
				MTDate intervalStart = dtIntervalStart;
				MTDate intervalEnd   = dtIntervalEnd;

				//prevents intervals from starting before the start date passed in
				//this is important in order to prevent duplicates arising from successive invocations
				if (intervalStart >= startDate) {
					string strIntervalStart, strIntervalEnd;
					intervalStart.ToString(STD_DATE_FORMAT, strIntervalStart);
					intervalEnd.ToString(STD_DATE_FORMAT, strIntervalEnd);

					//the interval's end date should be the very end of the day
					strIntervalEnd += " 23:59:59";

					if(BatchCounter == BatchSize) {
						pInsertStatemnt->ExecuteBatch();
						BatchCounter = 0;
					}
					if(BatchCounter == 0) {
						pInsertStatemnt->BeginBatch();
					}

					pInsertStatemnt->SetInteger(1,IntervalCounter++);
					pInsertStatemnt->SetInteger(2,cycleID);
					pInsertStatemnt->SetDatetime(3,intervalStart.GetODBCDate());
					pInsertStatemnt->SetDatetime(4,intervalEnd.GetODBCDateAtEndOfDate());
					pInsertStatemnt->AddBatch();
					BatchCounter++;

					/*

					//inserts the interval
					insertRowset->Clear();
					insertRowset->SetQueryTag("__INSERT_PC_INTERVAL__");
					insertRowset->AddParam("%%ID_CYCLE%%", cycleID);
					insertRowset->AddParam("%%DT_START%%", strIntervalStart.c_str());
					insertRowset->AddParam("%%DT_END%%", strIntervalEnd.c_str());
					insertRowset->Execute();
					*/
				}

				//increments the reference date to one day past the end of the last interval
				today = intervalEnd + 1;
			}
			cycleRowset->MoveNext();
		}
		// clean up any outstanding inserts
		pInsertStatemnt->ExecuteBatch();

	} 
  catch (_com_error& e) {
		mLogger.LogVarArgs(LOG_ERROR, "A COM exception occured in AddPCIntervals! error %x", e.Error());
		return E_FAIL;
	}
  catch(COdbcException& e) {
    string err = e.toString();
    mLogger.LogVarArgs(LOG_ERROR,err.c_str());
    return Error(err.c_str());
  }
	
	return S_OK;
}

STDMETHODIMP CCOMUsageServer::SetUsageIntervalState(long aIntervalID, MTUsageIntervalState aNewState)
{

 	ROWSETLib::IMTSQLRowsetPtr rowset;
  HRESULT nRetVal=S_OK;

  _variant_t vtParam;
  _bstr_t bstrState;

  try
  {
    //Convert the interval state enum to a string to be used in the database
    nRetVal=GetIntervalStateStringForDatabase(aNewState,bstrState);
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, "SetUsageIntervalState: Invalid state argument (%d) passed for interval state. Error = %x",
        aNewState, nRetVal);
      return Error ("SetUsageIntervalState: Invalid state argument passed.", 
        IID_ICOMUsageServer, nRetVal);
    }


    // create the rowset ...
    nRetVal = rowset.CreateInstance (MTPROGID_SQLROWSET);
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, "Unable to create instance of MTSQLRowset. Error = %x",
        nRetVal);
      return Error ("Unable to create instance of MTSQLRowset.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // initialize the rowset ...
    nRetVal = rowset->Init(USAGE_SERVER_QUERY_DIR);
    if (!SUCCEEDED(nRetVal))
    {
      mLogger.LogVarArgs (LOG_ERROR, "Unable to initialize MTSQLRowset. Error = %x",
        nRetVal);
      return Error ("Unable to initialize MTSQLRowset.", 
        IID_ICOMUsageServer, nRetVal);
    }
    
    // get the info for the run id ...
    //queryTag = ;
    rowset->SetQueryTag("__UPDATE_USAGE_INTERVAL_STATUS__");
    
    // add the run id as a parameter ...
    vtParam = (long) aIntervalID ;
    rowset->AddParam (MTPARAM_INTERVALID, vtParam) ;
    vtParam = bstrState ;
    rowset->AddParam (MTPARAM_STATUS, vtParam) ;

    
    // execute the query ...
    rowset->Execute();
    
    /*
    // if we have no information for the run id ...
    if (rowset->GetRecordCount() == 0)
    {
      // return error ...
      rowset.Release();
      nRetVal = DB_ERR_NO_ROWS;
      mLogger.LogVarArgs (LOG_ERROR, 
        "Unable to get recurring event run info for run id = %d. Error = %x",
        aRunID, nRetVal);
      return Error ("Unable to get recurring event run info for run id.", 
        IID_ICOMUsageServer, nRetVal);
    }
    */
	}
  catch (_com_error& e)
  {
		mLogger.LogVarArgs(LOG_ERROR, "A COM exception occured in SetUsageIntervalState! error %x", e.Error());
		return E_FAIL;
	}

	return nRetVal;
}

STDMETHODIMP CCOMUsageServer::InvokeAdapterForInterval(BSTR aProgId, BSTR aDisplayName, long aIntervalID, BSTR aConfigFile)
{


  // local variables ...
  HRESULT hr=S_OK ;
  //UserParameters myArgs ;
  //long nAcctID, nIntervalID ;
  _variant_t vtEOF ;

  _bstr_t bstrProgId(aProgId);
  _bstr_t bstrDisplayName(aDisplayName);
  _bstr_t bstrConfigFile(aConfigFile);

	//adapters may implement one out of two versions of the adapter interface
	IMTDataExporterPtr  adapter1;
	IMTDataExporter2Ptr adapter2;


  try
  {
    //Create component for reporting status to t_recurring_event_run table
    MTUSAGESERVERLib::IMTEventRunStatusPtr EventStatus("MetraTech.MTEventRunStatus.1");

    //Create the adapter we are going to run
    hr = adapter2.CreateInstance((char *)bstrProgId);
    long nAdapterInterfaceVersion = 2;

    //perhaps the adapter only implements version 1 of the interface
    if (FAILED(hr))
    {
      string buffer;
      buffer = "InvokeAdapterForInterval: Unable to create instance of component [";
      buffer += (char *)bstrProgId;
      buffer += "]. The component id is either invalid or this adapter does not support Version 2 of the adapter interface and is not a per interval adapter.";
      
   		mLogger.LogThis(LOG_ERROR,buffer.c_str());
      return Error (buffer.c_str());
    }
    
    //determines if the adpater is per interval
    VARIANT_BOOL bPerInterval = VARIANT_FALSE;
    if (nAdapterInterfaceVersion >= 2)
      bPerInterval = adapter2->GetPerInterval();
		if (bPerInterval != VARIANT_TRUE)
    {
      string buffer;
      buffer = "InvokeAdapterForInterval: Unable to invoke component [";
      buffer += (char *)bstrProgId;
      buffer += "]. This adapter is not a per interval adapter. GetPerInterval returned FALSE.";
      
   		mLogger.LogThis(LOG_ERROR,buffer.c_str());
      return Error (buffer.c_str());
    }
    // call the Init method ...
    //cout << "INFO: Calling Initialize() method of recurring event adapter "  <<
    //  endl << "      with config filename = " << configFile.c_str() << endl ;
	

    long nEventRunId;
    nEventRunId = EventStatus->Start(aIntervalID, bstrDisplayName, bstrProgId, bstrConfigFile);


		try
		{
  		adapter2->Initialize(bstrConfigFile);
		}
		catch (_com_error & e)
		{
		  string buffer = "InvokeAdapterForInterval: Error calling Initialize method on adapter: ";
		  buffer += e.Description();
      mLogger.LogThis(LOG_ERROR,buffer.c_str());
			return Error (buffer.c_str());
		}

		try 
		{
			adapter2->Execute(aIntervalID);
		}
		catch (_com_error & e) 
		{
		  string buffer = "InvokeAdapterForInterval: Error calling Execute method on adapter: ";
		  buffer += e.Description();
      mLogger.LogThis(LOG_ERROR,buffer.c_str());
			return Error (buffer.c_str());
		}

		try 
		{
			adapter2->ExportComplete();
		}
		catch (_com_error & e) 
		{
		  string buffer = "InvokeAdapterForInterval: Error calling ExportComplete method on adapter: ";
		  buffer += e.Description();
      mLogger.LogThis(LOG_ERROR,buffer.c_str());
			return Error (buffer.c_str());
		}

    EventStatus->End(nEventRunId, 0,"");

  }
  catch (_com_error e)
  {
    return e.Error();
  }
  catch(...)
  {
    string buffer = "InvokeAdapterForInterval: Unhandled exception while running adapter: ";
	  buffer += bstrProgId;
    buffer += "(";
    buffer += bstrDisplayName;
    buffer += ")";
    mLogger.LogThis(LOG_ERROR,buffer.c_str());
		return Error (buffer.c_str());
  }

	return S_OK;
}



