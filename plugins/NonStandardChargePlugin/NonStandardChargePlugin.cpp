#include <StdAfx.h>
#include <TransactionPlugInSkeleton.h>
#include <MTPipelineLib.h>
#include <stdio.h>
#include <AdapterLogging.h>
#include <DBAccess.h>
#include <mtparamnames.h>
#include <DBConstants.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>


#define CONFIG_DIR L"queries\\Database"

// #import <COMDBObjects.tlb> rename( "EOF", "RowsetEOF" )
#import "QueryAdapter.tlb" rename("GetUserName", "QAGetUserName") no_namespace
//{f5c1bab6-ed9d-4803-bbe4-6bd7d607deb4}

CLSID CLSID_NonStandardChargePlugin = {  
  0xf5c1bab6,
    0xed9d,
    0x4803,
  { 0xbb, 0xe4, 0x6b, 0xd7, 0xd6, 0x07, 0xde, 0xb4 }
};
//
class ATL_NO_VTABLE NonStandardChargePlugin
: public MTTransactionPlugIn<NonStandardChargePlugin, &CLSID_NonStandardChargePlugin >
//	public ObjectWithError
{
public:
		NonStandardChargePlugin();
protected:
  // Initialize the processor, looking up any necessary property IDs.
  // The processor can also use this time to do any other necessary initialization.
  virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                  MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);
  virtual HRESULT PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,
                                                      MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);
  
protected: // data
  NTLogger mLogger;
  MTPipelineLib::IMTLogPtr mLoggerPtr;

  long mInternalChargeId; 
  long mStatus;
  BOOL IsValidStatus(_bstr_t status);
  
  HRESULT UpdateStatus(__int64 requestId, const char* status, MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);
  
};
// this macro provides information to the plug-in skeleton on how the COM
// object should be registered, its CLSID, and its threading model.  If you are
// familiar with ATL COM objects, this macro basically provides all of the information
// to ATL so this class can act as a COM object
PLUGIN_INFO(CLSID_NonStandardChargePlugin, NonStandardChargePlugin,
            "MetraPipeline.NonStandardChargePlugin.1",
            "MetraPipeline.NonStandardChargePlugin", "Free")
            
            /////////////////////////////////////////////////////////////////////////////
            //PlugInConfigure
            /////////////////////////////////////////////////////////////////////////////
HRESULT NonStandardChargePlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                             MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                             MTPipelineLib::IMTNameIDPtr aNameID,
                                             MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  // grab an instance of the logger so we can use it in process sessions if
  // we need to 
  mQueryInitPath = "queries\\Database";
  mLoggerPtr = aLogger;
  // Declare the list of properties we will read from the XML configuration
  // When ProcessProperties is called, it loads the property Ids into the
  // variable that was passed 
  DECLARE_PROPNAME_MAP(inputs)
    DECLARE_PROPNAME("Status",&mStatus)
    DECLARE_PROPNAME("InternalChargeId",&mInternalChargeId)
  END_PROPNAME_MAP

    mStatus                    = aNameID->GetNameID("Status");
    mInternalChargeId          = aNameID->GetNameID("InternalChargeId");
  return ProcessProperties(inputs,aPropSet,aNameID,mLoggerPtr,/*PROCEDURE*/NULL);
}

// Constructor
// initialize the logger ...
NonStandardChargePlugin::NonStandardChargePlugin()
{
  LoggerConfigReader cfgRdr;
  mLogger.Init (cfgRdr.ReadConfiguration("NonStandardChargePlugin"), "[NonStandardChargePlugin]");
}



HRESULT NonStandardChargePlugin::UpdateStatus(__int64 requestId, const char* status, MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{
  // get the query
  _bstr_t queryTag;
  DBSQLRowset rowset;
  _variant_t vtParam;
  
  aTransactionRS->SetQueryTag("__UPDATE_PENDING_NS_REQUEST_STATUS__");
  
  vtParam = status;
  aTransactionRS->AddParam(L"%%STATUS%%", vtParam);
  vtParam = requestId;
  aTransactionRS->AddParam(L"%%REQUEST_ID%%", vtParam);  
  aTransactionRS->Execute();
  
  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT NonStandardChargePlugin::PlugInProcessSessionWithTransaction( MTPipelineLib::IMTSessionPtr aSession,
                                                                 MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{
  HRESULT nRetVal(S_OK);
  _bstr_t buffer;
  __int64 request_id = 0;
  
  try
  {
    
    _bstr_t status = aSession->GetStringProperty(mStatus);    
    request_id = aSession->GetLongLongProperty(mInternalChargeId);
    nRetVal = UpdateStatus(request_id, (const char*)status, aTransactionRS);
              char msg[256];
          sprintf(msg, 
                  "NonStandarCharge::PlugInProcessSessionWithTransaction. Updated Request id = %I64d", 
                  request_id);
          mLogger.LogThis(LOG_DEBUG, msg);
    // TODO: we can add this stuff later
      /*if (!SUCCEEDED(nRetVal))
      {
        aSession->SetLongProperty(ret, -1);
        return nRetVal;
      }
      
      if (status == _bstr_t("DENIED"))
      {
        nRetVal = S_FALSE;
        buffer = "Credit Request denied, nothing else to do, exiting...";
        mLogger.LogThis(LOG_DEBUG, (char*)buffer);
        aSession->SetLongProperty(ret, 0);
        return nRetVal;
      }
    }
    else
    {
      nRetVal = E_ABORT;
      buffer = " Invalid Status field: " +status;
      aSession->SetLongProperty(ret, -2);
      mLogger.LogThis(LOG_ERROR, (char*)buffer);
      return Error((char*)buffer, IID_IMTPipelinePlugIn, nRetVal);
    }*/
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return nRetVal;
}
BOOL NonStandardChargePlugin::IsValidStatus(_bstr_t status)
{
  return	(status == _bstr_t("A")) || 
          (status == _bstr_t("D")) ||
          (status == _bstr_t("P"));
}
