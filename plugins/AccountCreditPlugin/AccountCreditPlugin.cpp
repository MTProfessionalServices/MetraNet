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
//{2BB23AC3-F22C-11d3-9597-00B0D025B121}

CLSID CLSID_AccountCreditPlugin = {  
  0x2BB23AC3,
    0xF22C,
    0x11d3,
  { 0x95, 0x97, 0x00, 0xb0, 0xd0, 0x25, 0xb1, 0x21 }
};
//
class ATL_NO_VTABLE AccountCreditPlugin
: public MTTransactionPlugIn<AccountCreditPlugin, &CLSID_AccountCreditPlugin >
//	public ObjectWithError
{
public:
		AccountCreditPlugin();
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

  long	mStatus, mRequestID, 
				ret, mCreditAmount;
  long mAuthFailurePropID;
  long mCreditRequestPVID;
  long mProductViewPropID;
  long mAccountIDPropID;
  long mDescriptionPropID;
  long mSubscriberAccountIDPropID;
  long mPayingAccountPropID;
  long mAuditEventIDPropID;
  long mSuccessAuditEventIDPropID;
  long mFailureAuditEventIDPropID;
  long mInternalCommentPropID;

  long mGuideIntervalIDPropID;
  long mIntervalIDPropID;

  BOOL IsValidStatus(_bstr_t status);
  
#ifdef DECIMAL_PLUGINS
  MTDecimal mCreditAmountValue;
#else
  double mCreditAmountValue;
#endif
  
  HRESULT UpdateStatus(__int64 id_sess, const char* status, MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);
  
};
// this macro provides information to the plug-in skeleton on how the COM
// object should be registered, its CLSID, and its threading model.  If you are
// familiar with ATL COM objects, this macro basically provides all of the information
// to ATL so this class can act as a COM object
PLUGIN_INFO(CLSID_AccountCreditPlugin, AccountCreditPlugin,
            "MetraPipeline.AccountCreditPlugin.1",
            "MetraPipeline.AccountCreditPlugin", "Free")
            
            /////////////////////////////////////////////////////////////////////////////
            //PlugInConfigure
            /////////////////////////////////////////////////////////////////////////////
HRESULT AccountCreditPlugin::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
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
    DECLARE_PROPNAME("RequestID",&mRequestID)
    DECLARE_PROPNAME("ReturnCode",&ret)
    DECLARE_PROPNAME("CreditAmount",&mCreditAmount)
    //DECLARE_PROPNAME("AuthFailure", &mAuthFailurePropID)
    //DECLARE_PROPNAME("metratech.com/AccountCreditRequest", &mCreditRequestPVID)
    //DECLARE_PROPNAME("_ProductView", &mProductViewPropID)
    //DECLARE_PROPNAME("_AccountID", &mAccountIDPropID)
    //DECLARE_PROPNAME("Description", &mDescriptionPropID)
    //DECLARE_PROPNAME("SubscriberAccountID", &mSubscriberAccountIDPropID)
  END_PROPNAME_MAP


  mAuthFailurePropID          = aNameID->GetNameID("_AuthFailure");
  mCreditRequestPVID          = aNameID->GetNameID("metratech.com/AccountCreditRequest");
  mProductViewPropID          = aNameID->GetNameID("_ProductViewID");
  mAccountIDPropID            = aNameID->GetNameID("_AccountID");
  mDescriptionPropID          = aNameID->GetNameID("Description");
  mSubscriberAccountIDPropID  = aNameID->GetNameID("SubscriberAccountID");
  mPayingAccountPropID        = aNameID->GetNameID("_PayingAccount");

  mAuditEventIDPropID         = aNameID->GetNameID("AuditEventID");
  mSuccessAuditEventIDPropID  = aNameID->GetNameID("SuccessAuditEventID");
  mFailureAuditEventIDPropID  = aNameID->GetNameID("FailureAuditEventID");
  mInternalCommentPropID      = aNameID->GetNameID("InternalComment");

  mGuideIntervalIDPropID      = aNameID->GetNameID("GuideIntervalID");
  mIntervalIDPropID           = aNameID->GetNameID("_IntervalID");

  return ProcessProperties(inputs,aPropSet,aNameID,mLoggerPtr,/*PROCEDURE*/NULL);
}

// Constructor
// initialize the logger ...
AccountCreditPlugin::AccountCreditPlugin()
{
  LoggerConfigReader cfgRdr;
  mLogger.Init (cfgRdr.ReadConfiguration("AccountCreditPlugin"), "[AccountCreditPlugin]");
}



HRESULT AccountCreditPlugin::UpdateStatus(__int64 id_sess, const char* status, MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{
  // get the query
  _bstr_t queryTag;
  DBSQLRowset rowset;
  _variant_t vtParam;
  
  aTransactionRS->SetQueryTag("__FIND_PENDING_RECORD__");
  
  // add the parameters ...
  vtParam = id_sess;
  aTransactionRS->AddParam(MTPARAM_SESSIONID, vtParam);
  
  aTransactionRS->Execute();
  
  if (aTransactionRS->GetRecordCount() ==	0)
  {
    const char *errmsg = "AccountCreditPlugin::UpdateStatus. Unable to find record with PENDING status";
    mLogger.LogThis(LOG_ERROR, errmsg);
    return Error(errmsg, IID_IMTPipelinePlugIn, ACCOUNTCREDIT_REQUESTRECORD_NOT_FOUND);
  }
  
  aTransactionRS->Clear();  
  aTransactionRS->SetQueryTag("__UPDATE_REQUEST_STATUS__");
  
  // add parameters
  vtParam = status;
  aTransactionRS->AddParam(MTPARAM_CREDIT_REQUEST_STATUS, vtParam);
  vtParam = id_sess;
  aTransactionRS->AddParam(MTPARAM_SESSIONID, vtParam);
  vtParam = (DECIMAL) mCreditAmountValue;
  aTransactionRS->AddParam(MTPARAM_CREDIT_AMOUNT, vtParam);
  
  aTransactionRS->Execute();
  
  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT AccountCreditPlugin::PlugInProcessSessionWithTransaction( MTPipelineLib::IMTSessionPtr aSession,
                                                                 MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{
  HRESULT nRetVal(S_OK);
  _bstr_t buffer;
  __int64 request_id = 0;
  
  try
  {
    
    _bstr_t status = aSession->GetStringProperty(mStatus);
    bool bDenied = _wcsicmp((wchar_t*)status, L"DENIED") == 0;
    
#ifdef DECIMAL_PLUGINS
    mCreditAmountValue =  aSession->GetDecimalProperty(mCreditAmount);
#else
    mCreditAmountValue =  aSession->GetDoubleProperty(mCreditAmount);
#endif
    
    //CR 4825
    //Invert amount
    mCreditAmountValue = (mCreditAmountValue>0) ? (-mCreditAmountValue) : mCreditAmountValue;
    
    request_id = aSession->GetLongLongProperty(mRequestID);
    

    //By default, set the audit event to the success message.  If the stage fails, the audit plug-in
    // does not execute.
    aSession->SetLongProperty(mAuditEventIDPropID, aSession->GetLongProperty(mSuccessAuditEventIDPropID));

    bool bNotEnoughAuth = false;
    
    if(aSession->PropertyExists(mAuthFailurePropID, MTPipelineLib::SESS_PROP_TYPE_BOOL) == VARIANT_TRUE)
      bNotEnoughAuth = aSession->GetBoolProperty(mAuthFailurePropID) == VARIANT_TRUE;


    /////////////////////////////////////////////////////////////
    //If the auth check failed, make a new credit request, audit the new request, and throw an error.
    if(bNotEnoughAuth || bDenied) 
    {
        //If there is no request ID, make a new credit request -- Otherwise just throw the error
        if(bNotEnoughAuth && request_id > 0LL) 
        {
          char errmsg[256];
          sprintf(errmsg, 
                  "AccountCreditPlugin::PlugInProcessSessionWithTransaction. Session context lacked sufficient auth capabilities to approve or deny the adjustment request with id = %I64d", 
                  request_id);
          mLogger.LogThis(LOG_ERROR, errmsg);
          return Error(errmsg, IID_IMTPipelinePlugIn, MTAUTH_ACCESS_DENIED);
          
        }          

        //Make the new request by modifying the product view ID and fill any necessary properties for the 
        //credit request product view
        aSession->SetLongProperty(mProductViewPropID, mCreditRequestPVID);
        if(aSession->PropertyExists(mInternalCommentPropID, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
          aSession->SetStringProperty(mDescriptionPropID, aSession->GetStringProperty(mInternalCommentPropID));
        aSession->SetLongProperty(mSubscriberAccountIDPropID, aSession->GetLongProperty(mAccountIDPropID));
        aSession->SetStringProperty(mStatus, bDenied ? status : "PENDING");

        //Account ID 123 is needed for id_acc in t_acc_usage for account
        // credit requests.
        aSession->SetLongProperty(mPayingAccountPropID, 123);

        // if Guide Interval ID property exists then we set it on the credit request
        if(aSession->PropertyExists(mGuideIntervalIDPropID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)
        {
          aSession->SetLongProperty(mGuideIntervalIDPropID, aSession->GetLongProperty(mGuideIntervalIDPropID));
        }

        //Set the audit events
        aSession->SetLongProperty(mAuditEventIDPropID, aSession->GetLongProperty(mFailureAuditEventIDPropID));
    }
    else
    {
      // If we pass the auth check and the user specified an Interval ID to guide to
      // then we move the GuideIntervalID value into _IntervalID
      if(aSession->PropertyExists(mGuideIntervalIDPropID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)
      {
        aSession->SetLongProperty(mIntervalIDPropID, aSession->GetLongProperty(mGuideIntervalIDPropID));
      }
    }
    
    /////////////////////////////////////////////////////////////

    if(request_id < 0LL)
    {
      mLogger.LogThis(LOG_DEBUG, "Not a request-based credit.");
      aSession->SetLongProperty(ret, 0);
      return nRetVal;
    }
    
    if (IsValidStatus(status))
    {
      aTransactionRS->UpdateConfigPath(CONFIG_DIR);
      buffer =	"Updating account credit request status to "+status+
        ", request id_sess == "+_bstr_t(request_id);
      mLogger.LogThis(LOG_DEBUG, (char*)buffer);
      //update account credit request record
      nRetVal = UpdateStatus(request_id, (const char*)status, aTransactionRS);
      
      if (!SUCCEEDED(nRetVal))
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
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return nRetVal;
}
BOOL AccountCreditPlugin::IsValidStatus(_bstr_t status)
{
  return	(status == _bstr_t("APPROVED")) || 
          (status == _bstr_t("DENIED")) ||
          (status == _bstr_t("PENDING"));
}
