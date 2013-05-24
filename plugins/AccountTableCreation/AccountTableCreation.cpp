/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY -- PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Raju Matta
 *
 * $Date: 9/5/2002 5:44:54 PM$
 * $Author: Derek Young$
 * $Revision: 122$
 ***************************************************************************/

#include <mtcom.h>
#include <mtprogids.h>
#include <accountplugindefs.h>
#include <TransactionPlugInSkeleton.h>
#include <DBConstants.h>
#include <base64.h>
#include <MTUtil.h>
#include <UsageServerConstants.h>
#include <propids.h>
#include <mtglobal_msg.h>

#include <GenericCollection.h>
#include <MTObjectCollection.h>
#include <CoreAccountCreation.h>
#include <AccHierarchiesShared.h>
#include <corecapabilities.h>
#include <mttime.h>
#include <formatdbvalue.h>
#include <mtcomerr.h>
#include <MTTypeConvert.h>
#include <autherr.h>
#include <accounttypes.h>


#include <vector>
using namespace std;

// import the vendor kiosk tlb...
#import <COMKiosk.tlb> 
using namespace COMKIOSKLib;

#import <MTAccountUtils.tlb>
#import <MTEnumConfigLib.tlb> 

#import "MTProductCatalog.tlb" rename ("EOF", "RowsetEOF")
#import <GenericCollection.tlb>
#import <MTAuthCapabilities.tlb> rename ("EOF", "RowsetEOF")
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF")
#import <MTAccountStates.tlb> rename ("EOF", "RowsetEOF")

// generate using uuidgen
CLSID CLSID_ACCOUNTTABLECREATION = { /* 6bc17300-2296-11d3-ae6e-00c04f54fe3b */
    0x6bc17300,
    0x2296,
    0x11d3,
    {0xae, 0x6e, 0x00, 0xc0, 0x4f, 0x54, 0xfe, 0x3b} 
};

class ATL_NO_VTABLE AccountTableCreationPlugIn : 
  public MTTransactionPlugIn<AccountTableCreationPlugIn, &CLSID_ACCOUNTTABLECREATION>
{
public:

  AccountTableCreationPlugIn() : mEmptyString(""), bEncryptedPassword(false) {}

protected:
  // Initialize the processor, looking up any necessary property IDs.
  // The processor can also use this time to do any other necessary 
    // initialization.
  // NOTE: This method can be called any number of times in order to
  // refresh the initialization of the processor.
  virtual HRESULT PlugInConfigure(
    MTPipelineLib::IMTLogPtr aLogger,
    MTPipelineLib::IMTConfigPropSetPtr aPropSet,
    MTPipelineLib::IMTNameIDPtr aNameID,
    MTPipelineLib::IMTSystemContextPtr aSysContext);

  // Shutdown the processor.  The processor can release any resources
  // it no longer needs.
  virtual HRESULT PlugInShutdown();


virtual HRESULT 
  PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,
  MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);

  bool GetUsageCycleInfo(CoreAccountCreationParams& aParams,
                                                     MTPipelineLib::IMTSessionPtr aSession,
                                                     MTPipelineLib::IMTSecurityContextPtr secCtx);
  void GetPaymentInfo(CoreAccountCreationParams& aParams,
                                                   MTPipelineLib::IMTSessionPtr aSession,
                                                   MTPipelineLib::IMTSecurityContextPtr secCtx);

  void GetAncestorInfo(CoreAccountCreationParams& aParams,
                                                   MTPipelineLib::IMTSessionPtr aSession,
                                                   MTPipelineLib::IMTSecurityContextPtr secCtx);

  void GetAccountStateInfo(CoreAccountCreationParams& aParams,
                                                   MTPipelineLib::IMTSessionPtr aSession,
                                                   MTPipelineLib::IMTSecurityContextPtr secCtx);

  HRESULT CheckAccountMapperBusinessRules(CoreAccountCreationParams& aParams);

  void LoadUpdateProperties(CoreAccountCreationParams params,
                            MTPipelineLib::IMTSQLRowsetPtr aRowset,
                            MTExistingUpdateProperties& aExistingProps);

  void CheckManageAH(_bstr_t& path, MTPipelineLib::IMTSecurityContextPtr secCtx);

  void CheckAccountStateUpdate(CoreAccountCreationParams& params,
                            MTExistingUpdateProperties& aExistingProps,
                            MTPipelineLib::IMTSessionContextPtr pSessionContext,
                            MTPipelineLib::IMTSQLRowsetPtr pTransactionRS);

  void ValidateChangedProperties(CoreAccountCreationParams& params,
                            MTExistingUpdateProperties& aExistingProps);
  void CheckCycleChange(CoreAccountCreationParams& params,
                            MTExistingUpdateProperties& aExistingProps,
                            MTPipelineLib::IMTSecurityContextPtr& secContext);

 
  void CheckPaymentAuth(CoreAccountCreationParams& aParams,
      MTExistingUpdateProperties* aExistingProps,
      MTPipelineLib::IMTSecurityContextPtr& secCtx);


  HRESULT Add(MTPipelineLib::IMTSessionPtr aSession, MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);
  HRESULT Update(MTPipelineLib::IMTSessionPtr aSession, MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);
  HRESULT Delete(MTPipelineLib::IMTSessionPtr aSession, MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);

private:
  long mActionType;
  long mUserName;
  long mPassword;
  long mName_Space;
  long mLanguage;
  long mDayOfMonth;
  long mTariffName;
  long mTaxExempt;
  long mTimezoneID;
  long mAccountType;
  long mAccountID;
  long mAccountEndDate;
  long mOperation;
  long mAccountStatus;
  long mAccountStart;
  long mAccountEnd;
  long mDayOfWeek;
  long mFirstDayOfMonth;
  long mSecondDayOfMonth;
  long mStartDay;
  long mStartMonth;
  long mStartYear;
  long mIntervalSessionID;
  // controls whether an account can pay for another account
  long mBillable;
  // new with 3.0 account state support
  long mUsageCycleType;
  long mAccountStartDate;
  // payment redirection
  long mPayerAccountID;
  long mPayerLoginName;
  long mPayerNamespace;
  long mPayerStart;
  long mPayerEnd;
  // hierarchy support
  long mAncestorID;
	//only set in case this account
	//was moved
	long mOldAncestorID;
	//corporate account id
	long mCorporateAccountID;
  long mAncestorlogin;
  long mAncestorNameSpace;
  long mAncestorStart;
  long mAncestorEnd;
  long mIsFolder;
  long mApplyDSP;
  long mCurrency;
  long mFolder;
  
  //account types Kona addition
  long mcanbepayer;
  long mcansubscribe;
  long mcansyntheticroot;
  long mcanparticipateingsub;
  long misvisibleinhierarchy;
  long mcanhavetemplates;
  long miscorporate;
  long mLoginApplicationID;

  bool bEncryptedPassword;

  bool bApplyDSP;

  

  MTPipelineLib::IMTLogPtr mLogger;
  MTPipelineLib::IMTSecurityPtr mSecPtr;
  MTPipelineLib::IMTCompositeCapabilityPtr mPaymentCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mBillableCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mCreateCorporateAccountCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mCreateSubscriberCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mCreateCSRCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mManageAHCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mManageIndepAccCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mUpdateCSRCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mUpdateSubscriberCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mUpdateCorporateCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mMoveAccountCapability;

  MTACCOUNTSTATESLib::IMTAccountStateMetaDataPtr mMetaDataPtr;

  _bstr_t mEmptyString;
  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
  MTACCOUNTUTILSLib::IMTCreateAccountPtr mAccountUtilObj;
};


PLUGIN_INFO(CLSID_ACCOUNTTABLECREATION, 
      AccountTableCreationPlugIn,
      "MetraPipeline.UpdateTableCreation.1", 
      "MetraPipeline.UpdateTableCreation", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT AccountTableCreationPlugIn::PlugInConfigure(
  MTPipelineLib::IMTLogPtr aLogger,
  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
  MTPipelineLib::IMTNameIDPtr aNameID,
  MTPipelineLib::IMTSystemContextPtr aSysContext)
{
    HRESULT hr = S_OK;
    const char* procName = "AccountTableCreationPlugIn::PlugInConfigure";

    mLogger = aLogger;
  mAccountUtilObj = MTACCOUNTUTILSLib::IMTCreateAccountPtr(MTPROGID_ACCOUNTUTILS);
  mAccountUtilObj->Initialize();

  mQueryInitPath = "queries\\AccountCreation";


    DECLARE_PROPNAME_MAP(inputs)
    DECLARE_PROPNAME("actiontype",&mActionType)
    DECLARE_PROPNAME("username",&mUserName)
    DECLARE_PROPNAME("password",&mPassword)
    DECLARE_PROPNAME("name_space",&mName_Space)
    DECLARE_PROPNAME("language",&mLanguage)
    DECLARE_PROPNAME("dayofmonth",&mDayOfMonth)
    DECLARE_PROPNAME("accounttype",&mAccountType)
    DECLARE_PROPNAME("taxexempt",&mTaxExempt)
    DECLARE_PROPNAME("timezoneID",&mTimezoneID)
    DECLARE_PROPNAME("accountID",&mAccountID)
    DECLARE_PROPNAME("usagecycletype",&mUsageCycleType)
    DECLARE_PROPNAME("accountstartdate",&mAccountStartDate)
    DECLARE_PROPNAME("accountenddate",&mAccountEndDate)
    DECLARE_PROPNAME("operation",&mOperation)
    DECLARE_PROPNAME("accountstatus",&mAccountStatus)
    DECLARE_PROPNAME("dayofweek",&mDayOfWeek)
    DECLARE_PROPNAME("firstdayofmonth",&mFirstDayOfMonth)
    DECLARE_PROPNAME("seconddayofmonth",&mSecondDayOfMonth)
    DECLARE_PROPNAME("startday",&mStartDay)
    DECLARE_PROPNAME("startmonth",&mStartMonth)
    DECLARE_PROPNAME("startyear",&mStartYear)
    // new with account hierarchies
    DECLARE_PROPNAME("billable",&mBillable)
    DECLARE_PROPNAME("PayerAccountID",&mPayerAccountID)
    DECLARE_PROPNAME("PayerLoginName",&mPayerLoginName)
    DECLARE_PROPNAME("PayerNamespace",&mPayerNamespace)
    DECLARE_PROPNAME("PayerStart",&mPayerStart)
    DECLARE_PROPNAME("PayerEnd",&mPayerEnd)
    DECLARE_PROPNAME("AncestorID",&mAncestorID)
		DECLARE_PROPNAME("OldAncestorAccountID",&mOldAncestorID)
		DECLARE_PROPNAME("CorporateAccountID",&mCorporateAccountID)
    DECLARE_PROPNAME("Ancestorlogin",&mAncestorlogin)
    DECLARE_PROPNAME("AncestorNameSpace",&mAncestorNameSpace)
    DECLARE_PROPNAME("AncestorStart",&mAncestorStart)
    DECLARE_PROPNAME("AncestorEnd",&mAncestorEnd)
    DECLARE_PROPNAME("folder",&mIsFolder)
    DECLARE_PROPNAME("ApplyDefaultSecurityPolicy",&mApplyDSP)
    DECLARE_PROPNAME("currency",&mCurrency)
    DECLARE_PROPNAME("folder",&mFolder)
    //new account type related properties
    DECLARE_PROPNAME("b_canbepayer", &mcanbepayer)
    DECLARE_PROPNAME("b_cansubscribe", &mcansubscribe)
    DECLARE_PROPNAME("b_cansyntheticroot", &mcansyntheticroot)
    DECLARE_PROPNAME("b_canparticipateingsub", &mcanparticipateingsub)
    DECLARE_PROPNAME("b_isvisibleinhierarchy", &misvisibleinhierarchy)
    DECLARE_PROPNAME("b_canhavetemplates", &mcanhavetemplates)
    DECLARE_PROPNAME("b_iscorporate", &miscorporate)
    DECLARE_PROPNAME("loginapplication", &mLoginApplicationID)
    END_PROPNAME_MAP
    
    hr = ProcessProperties(inputs,aPropSet,aNameID,aLogger,procName);
    if(!SUCCEEDED(hr))
    return hr;

  PipelinePropIDs::Init();

  // see if the password string has a trailing underscore
  wstring aTempStr = (const wchar_t*)_bstr_t(aNameID->GetName(mPassword));
  bEncryptedPassword = aTempStr[aTempStr.length()-1] == L'_';

  MTAUTHLib::IMTEnumTypeCapabilityPtr enumPtr;
    
  try
  {

    //get enum config pointer from system context
    mEnumConfig = aSysContext->GetEnumConfig();
    _ASSERTE(mEnumConfig != NULL);

    mSecPtr.CreateInstance(__uuidof(MTAUTHLib::MTSecurity));

    // get capabilities from the auth subsystem
    mPaymentCapability = mSecPtr->GetCapabilityTypeByName(MANAGE_PAYMENT_CAP)->CreateInstance();
    mBillableCapability = mSecPtr->GetCapabilityTypeByName(MANAGE_BILLABLE_CAP)->CreateInstance();
    mCreateCorporateAccountCapability = mSecPtr->GetCapabilityTypeByName(CREATE_CORPORATE_CAP)->CreateInstance();
    mCreateSubscriberCapability = mSecPtr->GetCapabilityTypeByName(CReATE_SUBSCRIBER_CAP)->CreateInstance();
    mCreateCSRCapability = mSecPtr->GetCapabilityTypeByName(CREATE_CSR_CAP)->CreateInstance();

    mManageAHCapability = mSecPtr->GetCapabilityTypeByName(MANAGE_HIERARCHY_CAP)->CreateInstance();
    enumPtr = mManageAHCapability->GetAtomicEnumCapability();
    enumPtr->SetParameter("WRITE");
    
    mManageIndepAccCapability = mSecPtr->GetCapabilityTypeByName(MANAGE_NON_HIER_ACCOUNTS_CAP)->CreateInstance();
    enumPtr = mManageIndepAccCapability->GetAtomicEnumCapability();
    enumPtr->SetParameter("WRITE");

    mUpdateCSRCapability = mSecPtr->GetCapabilityTypeByName(UPDATE_CSR_CAP)->CreateInstance();
    mUpdateSubscriberCapability = mSecPtr->GetCapabilityTypeByName(UPDATE_SUB_CAP)->CreateInstance();
    mUpdateCorporateCapability = mSecPtr->GetCapabilityTypeByName(UPDATE_CORPORATE_CAP)->CreateInstance();
    mMoveAccountCapability = mSecPtr->GetCapabilityTypeByName(MOVE_ACCOUNT_CAP)->CreateInstance();

    // cache an instance of the metadata object
    mMetaDataPtr.CreateInstance(__uuidof(MTACCOUNTSTATESLib::MTAccountStateMetaData));


  }
  catch(_com_error& e)
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Failed to get EnumConfig Interface pointer from SysContext");
    return ReturnComError(e);
  }

  return hr;
}

////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT 
AccountTableCreationPlugIn::PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,
                                                                MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{
    HRESULT hr = S_OK;
    _bstr_t sOperation;
    
  try
  {
    
    sOperation = mEnumConfig->GetEnumeratorByID(aSession->GetEnumProperty(mOperation));
    
    if (sOperation.length() == 0)  // blank, return error
        MT_THROW_COM_ERROR("Blank Operation");

    if (0 == _wcsicmp((wchar_t*)sOperation, L"Add"))
      hr = Add(aSession,aTransactionRS);
    else if (0 == _wcsicmp((wchar_t*)sOperation, L"Update"))
      hr = Update(aSession,aTransactionRS);
    else if (0 == _wcsicmp((wchar_t*)sOperation, L"Delete") ||
            (0 == _wcsicmp((wchar_t*)sOperation, L"NO-OP")))
      hr = Delete(aSession,aTransactionRS);
    else
    {
      MT_THROW_COM_ERROR(MT_UNSUPPORTED_ACCOUNT_OPERATION,(const char*)sOperation);
    }
  }
  catch (_com_error& e)
  {
      return ReturnComError(e);
  }

  return hr;
}


/////////////////////////////////////////////////////////////////////////////
// Add
/////////////////////////////////////////////////////////////////////////////
HRESULT 
AccountTableCreationPlugIn::Add(MTPipelineLib::IMTSessionPtr aSession, MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{
  // local variables ...
    HRESULT hr = S_OK;
    
  //enum types description ids
  long lTimezoneID, lUsageCycleType, lAccountStatus;
  _bstr_t sUsageCycleType, sAccountType, sActionType;
  
   
  _bstr_t username;
  _bstr_t password;
  _bstr_t name_space;
  _bstr_t language;
  _bstr_t taxexempt;
  
  AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_ACCOUNT_CREATE_DENIED;
  MTPipelineLib::IMTSecurityContextPtr secCtx = aSession->GetSessionContext()->GetSecurityContext();

  try
  {
    CoreAccountCreationParams params;
		params.bEnforceSameCorp =  PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE;

 
    // actiontype, required
    sActionType = mEnumConfig->GetEnumeratorByID(aSession->GetEnumProperty(mActionType));

		//Do nothing if action type is contact because all we need to do is update account extension
    // data, not other account data.
    if ((0 == _wcsicmp((wchar_t*)sActionType, L"contact")))  // ok
      return (S_OK);

    //read in the account type specific properties into the params structure.  These have to
    //exist.
    params.mCanBePayer = (aSession->GetBoolProperty(mcanbepayer) == VARIANT_TRUE);
    params.mCanSubscribe = (aSession->GetBoolProperty(mcansubscribe) == VARIANT_TRUE);
    params.mCanHaveSyntheticRoot = (aSession->GetBoolProperty(mcansyntheticroot) == VARIANT_TRUE);
    params.mCanParticipateInGSub = (aSession->GetBoolProperty(mcanparticipateingsub) == VARIANT_TRUE);
    params.mCanHaveTemplates = (aSession->GetBoolProperty(mcanhavetemplates) == VARIANT_TRUE);
    params.mIsCorporate = (aSession->GetBoolProperty(miscorporate) == VARIANT_TRUE);
    params.mIsVisibleInHierarchy = (aSession->GetBoolProperty(misvisibleinhierarchy) == VARIANT_TRUE);

    // username, required
    params.mlogin = aSession->GetStringProperty(mUserName);
    
    // name_space, required
    params.mNameSpace = aSession->GetStringProperty(mName_Space);
      
    // password, required
    if(bEncryptedPassword)
    {
      params.mPassword = aSession->DecryptEncryptedProp(mPassword);
    }
    else
    {
      params.mPassword = aSession->GetStringProperty(mPassword);
    }

		//currency, only required if the canBePayer is true
    if (aSession->PropertyExists(mCurrency, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
    {
		  _bstr_t currencyStr = aSession->GetStringProperty(mCurrency);
		  params.mCurrency = currencyStr;
    }
    if (params.mCanBePayer &&
       (aSession->PropertyExists(mCurrency, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE))
    {
      string strCurrencyError = "Missing required property, currency for account with login=" + _bstr_t(params.mlogin);
      MT_THROW_COM_ERROR(strCurrencyError.c_str());
    }

    // language, required
    language = mEnumConfig->GetEnumeratorByID(aSession->GetEnumProperty(mLanguage));
    if (language.length() == 0) {
      MT_THROW_COM_ERROR(MT_NO_LANGUAGE_SPECIFIED);
    }
    params.mLangCode = language;

    // account type, required
    params.mAccountType = aSession->GetStringProperty(mAccountType);

    // timezone ID, required
    lTimezoneID = aSession->GetEnumProperty(mTimezoneID);
    params.mtimezoneID = atol(mEnumConfig->GetEnumeratorValueByID(lTimezoneID));




    //Accountstatus, required
    lAccountStatus = aSession->GetEnumProperty(mAccountStatus);

    // isFolder, not required
    bool isFolder = false;
    if (aSession->PropertyExists(mIsFolder, MTPipelineLib::SESS_PROP_TYPE_BOOL))
    { isFolder = (aSession->GetBoolProperty(mIsFolder) == VARIANT_TRUE);
    }

    // initialize account state, if accountstartdate and accountenddate are specified
    GetAccountStateInfo(params,aSession,secCtx);

    // applyDefaultSecurityPolicy, not required.
    if(aSession->PropertyExists(mApplyDSP, MTPipelineLib::SESS_PROP_TYPE_BOOL)) 
    {
        bApplyDSP =aSession->GetBoolProperty(mApplyDSP) == VARIANT_TRUE ? true : false;
    }
    params.mApplyDefaultSecurityPolicy = bApplyDSP;

   
    // get the usage cycle information from the session
    // only required if CanBePayer is true
    if (params.mCanBePayer)
    {
      lUsageCycleType = aSession->GetEnumProperty(mUsageCycleType);
      sUsageCycleType = mEnumConfig->GetEnumeratorByID(lUsageCycleType);

      if(!GetUsageCycleInfo(params,aSession,secCtx))
      {
        MT_THROW_COM_ERROR(MT_USAGE_CYCLE_INFO_REQUIRED);
      }
    }


    GetPaymentInfo(params,aSession,secCtx);

    // if the payer is not specified and account can never be a self payer and account can exist
    // in the disconnected state, set the payer to be -1
    if ((params.mPayerID.vt == VT_NULL) &&
        ((params.mPayerlogin.vt == VT_NULL) || (params.mPayerNamespace.vt == VT_NULL)) &&
        (params.mCanHaveSyntheticRoot))
    {
      params.mPayerID = -1;
      params.mPaymentMap |= PAYMENTMAP_ACCOUNTVAL;
    }


    GetAncestorInfo(params,aSession,secCtx);

    if (((params.mAncestorLogon.vt == VT_NULL) && (params.mAncestorNamespace.vt != VT_NULL))
        ||
        ((params.mAncestorLogon.vt != VT_NULL) && (params.mAncestorNamespace.vt == VT_NULL)))
    {
       MT_THROW_COM_ERROR("Incomplete ancestor information provided, either ancestor login or namespace is missing.");
    }

    // if neither the ancestor id nor the [login,namespace] is specified then set the id to be 1 or -1
    if ((params.mAncestorID.vt == VT_NULL) &&
        ((params.mAncestorLogon.vt == VT_NULL) && (params.mAncestorNamespace.vt == VT_NULL)))
    {
      if (params.mCanHaveSyntheticRoot == true)
      {
        params.mAncestorID = -1; //synthetic root
        params.mAncestorMap |= ANCESTORMAP_ANCESTOR;
      }
      else
      {
        params.mAncestorID = 1; //root
        params.mAncestorMap |= ANCESTORMAP_ANCESTOR;
      }
    }  

      //login application - only valid for system accounts.
    if (_wcsicmp((wchar_t*)params.mAccountType, ACCOUNT_TYPE_SYSTEM) == 0)
    {
      if (aSession->PropertyExists(mLoginApplicationID, MTPipelineLib::SESS_PROP_TYPE_ENUM) == VARIANT_TRUE)
      {
        _bstr_t loginApplication;
        loginApplication = mEnumConfig->GetEnumeratorByID(aSession->GetEnumProperty(mLoginApplicationID));
        params.mLoginApp = loginApplication;
      }
      else
      {
        string strError = "Missing required property, LoginApplication";
        MT_THROW_COM_ERROR(strError.c_str());
      }
    }
   
    // Check create capability based on type.
    // For now, checks are hardcoded.
    //AR: In a future release, create metadata to specify the capability to check while creating
    // an account of a specific type. Note, we are losing the ablity to check for capabilities to create
    // folders and independent accounts

	if (_wcsicmp((wchar_t*)params.mAccountType, ACCOUNT_TYPE_SYSTEM) != 0)
    { 
      if (params.mIsCorporate)
        secCtx->CheckAccess(mCreateCorporateAccountCapability);
      else
        secCtx->CheckAccess(mCreateSubscriberCapability);
    }
    else 
      secCtx->CheckAccess(mCreateCSRCapability);



    // check account mapper business rules
    hr = CheckAccountMapperBusinessRules(params);
    if(FAILED(hr)) {
      return hr;
    }

    // IMPORTANT: null out the the payment start date and the hierarchy
    // start date.  The stored procedure will always pick up the date 
    // from the account start date.  While it is not technically safe
    // to change the type of the variant (you could leak a BSTR for instance)
    // in this case it should be ok because we are encapsulating an 8 byte value that
    // is part of the variant union.
    params.mPayerStartDate.vt = VT_NULL;
    params.mPayerEndDate.vt = VT_NULL;
    params.mHierarchyStart.vt = VT_NULL;
    params.mHierarchyEnd.vt = VT_NULL;

    CheckPaymentAuth(params,NULL,secCtx);

     MTCoreAccountMgr aAccountMgr(params);
		RowSetInterfacesLib::IMTSQLRowsetPtr accountRS = reinterpret_cast<RowSetInterfacesLib::IMTSQLRowset*>(aTransactionRS.GetInterfacePtr());
    AccountOutputParams outputParams;
    hr = aAccountMgr.CreateAccount(accountRS,outputParams);

    // verify that the currency is correct.
    if(SUCCEEDED(hr)) {

      aSession->SetLongProperty(mAccountID,outputParams.mAccountID);

			//set ancestor id if it wasn't in session already	
			if(aSession->PropertyExists(mAncestorID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_FALSE) 
			{
				aSession->SetLongProperty(mAncestorID, outputParams.mNewAncestorID);
			}

			//set corporation id, which was resolved in stored proc
			aSession->SetLongProperty(mCorporateAccountID,outputParams.mCorporationID);
   
      // check if the account has the capabililty to add accounts to the hierarchy at this path.
    if (_wcsicmp((wchar_t*)params.mAccountType, ACCOUNT_TYPE_SYSTEM) != 0)  
        CheckManageAH(outputParams.mHierarchyPath, secCtx);
    }
		else
		{
			char LogBuf[1024];

			switch (hr)
			{
				// if account type and namespace mismatch, return parameterized
				// message
				// MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH ((DWORD)0xE2FF0044L)
				case MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH:
	        sprintf(LogBuf, 
									"Account with type '%s' and namespace '%s' not allowed. Please choose an appropriate type or namespace", 
									(const char*)_bstr_t(params.mAccountType),
									(const char*)_bstr_t(params.mNameSpace));
					return Error(LogBuf,
											 IID_IMTPipelinePlugIn, 
											 hr);

				// An account in the hierarchy cannot be of system namespace
				// MT_ACCOUNT_NAMESPACE_AND_HIERARCHY_MISMATCH ((DWORD)0xE2FF0045L)
				case MT_ACCOUNT_NAMESPACE_AND_HIERARCHY_MISMATCH:
	        sprintf(LogBuf, 
									"Accounts with namespace '%s' not allowed in the hierarchy", 
									(const char*)_bstr_t(params.mNameSpace));
					return Error(LogBuf,
											 IID_IMTPipelinePlugIn, 
											 hr);

					case ACCOUNTMAPPER_ERR_ALREADY_EXISTS:
	        sprintf(LogBuf, 
									"Accounts '%s' already exists in '%s' namespace", 
									(const char*)_bstr_t(params.mlogin), (const char*)_bstr_t(params.mNameSpace));
					return Error(LogBuf,
											 IID_IMTPipelinePlugIn, 
											 hr);

          case MT_ANCESTOR_OF_INCORRECT_TYPE:
                 MT_THROW_COM_ERROR(MT_ANCESTOR_OF_INCORRECT_TYPE, (char *)params.mAccountType, (char *)outputParams.mAncestor_type);
					
			  default:
					MT_THROW_COM_ERROR(hr);
			}
		}
  }
  catch(_com_error& e)
  {
    AuditAuthFailures(e, deniedEvent, secCtx->AccountID, 
                      AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                      -1); 

    return ReturnComError(e);
  } 
  return (hr);
}

/////////////////////////////////////////////////////////////////////////////
// Update
/////////////////////////////////////////////////////////////////////////////
HRESULT 
AccountTableCreationPlugIn::Update(MTPipelineLib::IMTSessionPtr aSession, MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{
  // local variables ...
  HRESULT hr = S_OK;
    
  //enum types description ids
  _bstr_t sUsageCycleType, sAccountType, sActionType;

  MTPipelineLib::IMTSecurityContextPtr secCtx = aSession->GetSessionContext()->GetSecurityContext();
  AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_ACCOUNT_UPDATE_DENIED;
  long accountID = -1;

  try
  {
    CoreAccountCreationParams params;
		params.bEnforceSameCorp =  PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE;

		//see if we are trying to update account currency
		//if we are, then we need to validate that it matches payer currency
		//validation is done in CreatePaymentRecord stored proc

		if(aSession->PropertyExists(mCurrency, MTPipelineLib::SESS_PROP_TYPE_STRING))
		{
			_bstr_t currencyStr = aSession->GetStringProperty(mCurrency);
			params.mCurrency = currencyStr;
		}


    // actiontype
    sActionType = mEnumConfig->GetEnumeratorByID(aSession->GetEnumProperty(mActionType));
    
    //Do nothing if action type is contact
    // TODO: Is this correct in 3.0
    if ((0 == _wcsicmp((wchar_t*)sActionType, L"contact")))  // ok
      return (S_OK);

      params.mAccountType = aSession->GetStringProperty(mAccountType);
 
    //read in the account type specific properties into the params structure.  These have to
    //exist.
    params.mCanBePayer = (aSession->GetBoolProperty(mcanbepayer) == VARIANT_TRUE);
    params.mCanSubscribe = (aSession->GetBoolProperty(mcansubscribe) == VARIANT_TRUE);
    params.mCanHaveSyntheticRoot = (aSession->GetBoolProperty(mcansyntheticroot) == VARIANT_TRUE);
    params.mCanParticipateInGSub = (aSession->GetBoolProperty(mcanparticipateingsub) == VARIANT_TRUE);
    params.mCanHaveTemplates = (aSession->GetBoolProperty(mcanhavetemplates) == VARIANT_TRUE);
    params.mIsCorporate = (aSession->GetBoolProperty(miscorporate) == VARIANT_TRUE);
    params.mIsVisibleInHierarchy = (aSession->GetBoolProperty(misvisibleinhierarchy) == VARIANT_TRUE);

    //
    // Algorithm:
    // 1. Find all of the properties in the session and place them in the params structure.
    // 2. Make sure all required groups of properties are present.
    // 3. Then find all the properties for the account from the database.
    // 4. Null out properties that did not change
    // 5. Make sure bad updates are prevented early enough!
    // 6. Check for capabilities.
    // 7. Do the update.
    // 8. Check results.

    // find properties
    if(aSession->PropertyExists(mUserName, MTPipelineLib::SESS_PROP_TYPE_STRING)) {
      params.mlogin = aSession->GetStringProperty(mUserName);
    }
    if(aSession->PropertyExists(mName_Space, MTPipelineLib::SESS_PROP_TYPE_STRING)) {
      params.mNameSpace = aSession->GetStringProperty(mName_Space);
    }
    if(aSession->PropertyExists(mAccountID, MTPipelineLib::SESS_PROP_TYPE_LONG)) {
      params.mAccountID = aSession->GetLongProperty(mAccountID);
    }

    if(aSession->PropertyExists(mPassword, MTPipelineLib::SESS_PROP_TYPE_STRING)) {
      // password
      if(bEncryptedPassword) {
        params.mPassword = aSession->DecryptEncryptedProp(mPassword);
      }
      else {
        params.mPassword = aSession->GetStringProperty(mPassword);
      }
    }

    // get the usage cycle information from the session
    GetUsageCycleInfo(params,aSession,secCtx);

    GetPaymentInfo(params,aSession,secCtx);

    GetAncestorInfo(params,aSession,secCtx);

    GetAccountStateInfo(params,aSession,secCtx);
    //step 1 completed.

        ///////////////////////////////////////////////////////////////////////////////////////////
    // check for property groupings
    ///////////////////////////////////////////////////////////////////////////////////////////

    // account state.  We require the new state and the start date are both set
    //ok, the way it was being done earlier (the commented out code) is more correct..
    //There are times when the start date is passed in with no state passed in.  This is one
    // specific case I am going to ignore
    /*begin old correct code*/
   /* if(params.mAccountStateMap != 0 && 
      params.mAccountStateMap != (STATEMAP_TYPE | STATEMAP_STARTDATE | STATEMAP_ENDDATE))
    {
      MT_THROW_COM_ERROR(MT_PARTIAL_ACCOUNT_STATE_INFO);
    } */
    /*end old correct code*/

    if (params.mAccountStateMap != 0 &&
        params.mAccountStateMap == STATEMAP_STARTDATE) //so only startdate is specified
    {
      params.mAccountStateMap = 0;
    }
    else if (params.mAccountStateMap != 0 && params.mAccountStateMap != (STATEMAP_TYPE | STATEMAP_STARTDATE | STATEMAP_ENDDATE))
    {
      MT_THROW_COM_ERROR(MT_PARTIAL_ACCOUNT_STATE_INFO);
    } 

    // if changing the password, require login,namespace,and new password
    if(params.mPassword.vt != VT_NULL)
    {

      if(params.mlogin.vt == VT_NULL || params.mNameSpace.vt == VT_NULL) 
      {
        MT_THROW_COM_ERROR(MT_PARTIAL_INFO_ON_PASSWORD_CHANGE);
      }

      hr = CheckAccountMapperBusinessRules(params);
      if(FAILED(hr)) 
      {
        return hr;
      }
    }

    // check for payment property groupings.  we need both the namespace and login OR the account ID
    if(params.mPaymentMap != 0 && 
         params.mPaymentMap != (PAYMENTMAP_ACCOUNTVAL | PAYMENTMAP_STARTDATE) &&
         params.mPaymentMap != (PAYMENTMAP_ACCOUNTVAL | PAYMENTMAP_STARTDATE | PAYMENTMAP_ENDDATE) &&
         params.mPaymentMap != (PAYMENTMAP_LOGINNAME | PAYMENTMAP_NS | PAYMENTMAP_STARTDATE) &&
         params.mPaymentMap != (PAYMENTMAP_LOGINNAME | PAYMENTMAP_NS | PAYMENTMAP_STARTDATE | PAYMENTMAP_ENDDATE)
      )
    {   
		MT_THROW_COM_ERROR("Partial information specified for payment redirection. Need new payer information and payment startdate");
    }

    if(params.mAncestorMap != 0 && 
      params.mAncestorMap != (ANCESTORMAP_ANCESTOR | ANCESTORMAP_STARTDATE) &&
      params.mAncestorMap != (ANCESTORMAP_ANCESTOR | ANCESTORMAP_STARTDATE | ANCESTORMAP_ENDDATE) &&
      params.mAncestorMap != (ANCESTORMAP_LOGINNAME | ANCESTORMAP_NS | ANCESTORMAP_STARTDATE) && 
      params.mAncestorMap != (ANCESTORMAP_LOGINNAME | ANCESTORMAP_NS | ANCESTORMAP_STARTDATE | ANCESTORMAP_ENDDATE)
      )
    {
		MT_THROW_COM_ERROR("Partial information specified to change account hierarchy location.  Need new ancestor information and hierarchy startdate");
    }

    //step 2 completed.

    MTExistingUpdateProperties existingProperties;

    // now we hit the database to get the existing properties
    LoadUpdateProperties(params,aTransactionRS,existingProperties);
    
    //step 3 completed.

    ValidateChangedProperties(params,existingProperties);
    //step 4 completed.


    // make sure no one is trying to change account type
    if(_wcsicmp(params.mAccountType,existingProperties.mAccType) != 0)
    {
      MT_THROW_COM_ERROR("Changing the account type is not supported.");
    }

    // make sure you are not trying to change the ancestor to -1 for an account whose type does not allow you to do so
    if ((params.mAncestorID.vt != VT_NULL) &&(long)params.mAncestorID == -1 && !params.mCanHaveSyntheticRoot)
    {
      MT_THROW_COM_ERROR("Only accounts whose type supports synthetic roots, can set the ancestor to the synthetic root, -1");
    }

    // make sure you are not tryint to chagne the payer to -1 for an account whose type does not allow you to do so
    if ((params.mPayerID.vt != VT_NULL) && (long)params.mPayerID == -1 && !params.mCanHaveSyntheticRoot)
    {
      MT_THROW_COM_ERROR("Only accounts whose type supports synthetic roots, can set the ancestor to the synthetic root, -1");
    }

    // copy the account ID property
    params.mAccountID = existingProperties.mAccountID;
    accountID = params.mAccountID;


    // Check create capability based on type.
	if (_wcsicmp((wchar_t*)params.mAccountType, ACCOUNT_TYPE_SYSTEM) != 0)
    { 
      if (params.mIsCorporate)
        secCtx->CheckAccess(mUpdateCorporateCapability);
      else
        secCtx->CheckAccess(mUpdateSubscriberCapability);

      CheckManageAH(existingProperties.mHierarchyPath, secCtx);
    }
    else 
      secCtx->CheckAccess(mUpdateCSRCapability);
    
     


    // check if the user has capability to make someone billable, payer etc
    CheckPaymentAuth(params,&existingProperties,secCtx);

    // if we are changing the billing cycle, check if that is possible.
    CheckCycleChange(params,existingProperties,secCtx);


    // check the account state.  The code will do the operation if necessary
    CheckAccountStateUpdate(params,existingProperties,aSession->GetSessionContext(),aTransactionRS);


    // do the account update (calls updateAccount stored procedure. )
    MTCoreAccountMgr aAccountMgr(params);
    AccountOutputParams outputParams;
    RowSetInterfacesLib::IMTSQLRowsetPtr accountRS = reinterpret_cast<RowSetInterfacesLib::IMTSQLRowset*>(aTransactionRS.GetInterfacePtr());
    hr = aAccountMgr.UpdateAccount(accountRS,outputParams);
    if(SUCCEEDED(hr)) {

      // time for fun with the auth subsystem!!! Yay.  We can safely do this after the stored procedure
      // because the transaction will roll back on failure.

      // umbrella check on the account hierarchy.  Check the path to make sure it is kosher. 
      if (_wcsicmp((wchar_t*)params.mAccountType, ACCOUNT_TYPE_SYSTEM) != 0)
       { 
        CheckManageAH(outputParams.mHierarchyPath,secCtx);
       }

      aSession->SetLongProperty(mAccountID,outputParams.mAccountID);

			//set old ancestor id in session in case this account was moved.
			//Just for convenience
			aSession->SetLongProperty(mOldAncestorID,outputParams.mOldAncestorID);

			//if new account ancestor id wasn't already in the session
			//set it there
			if(aSession->PropertyExists(mAncestorID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_FALSE) 
			{
				aSession->SetLongProperty(mAncestorID, outputParams.mNewAncestorID);
			}

			//set corporation id, which was resolved in stored proc
			aSession->SetLongProperty(mCorporateAccountID,outputParams.mCorporationID);

    }
		else
    {
      if (hr == MT_ANCESTOR_OF_INCORRECT_TYPE)
         MT_THROW_COM_ERROR(MT_ANCESTOR_OF_INCORRECT_TYPE, (char *)(params.mAccountType), (char *)(outputParams.mAncestor_type));
      else
			   MT_THROW_COM_ERROR(hr);
    }
  }
  catch(_com_error& e)
  {
    AuditAuthFailures(e, deniedEvent, secCtx->AccountID, 
                      AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                      accountID); 
	  char buffer[1024];
		sprintf(buffer, "An exception was thrown in Update: %x, %s", 
						e.Error(), (const char*) _bstr_t(e.Description()));

    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
	
    return ReturnComError(e);
  } 
  return (hr);
}



void AccountTableCreationPlugIn::ValidateChangedProperties(CoreAccountCreationParams& params,
                            MTExistingUpdateProperties& aExistingProps)
{
  _variant_t vtNULL;
  vtNULL.vt = VT_NULL;
  bool bClearPayment = false;
  bool bClearAncestor = false;

  // the purpose of this method is to NULL out any parameters that were passed in
  // through the service definition but did not actually change.  God... web services rock!
  if(params.mCycleType.vt != VT_NULL && 
    (long)params.mCycleType == aExistingProps.mCycleType && 
    params.mDayOfMonth == aExistingProps.mDayOfMonth && 
    params.mDayOfWeek == aExistingProps.mDayOfWeek && 
    params.mFirstDayOfMonth == aExistingProps.mFirstDayOfMonth && 
    params.mSecondDayOfMonth == aExistingProps.mSecondDayOfMonth && 
    params.mStartDay == aExistingProps.mStartDay && 
    params.mStartMonth == aExistingProps.mStartMonth && 
    params.mStartYear == aExistingProps.mStartYear) {

    params.mCycleType = vtNULL;
  }
  switch(params.mAncestorMap) {
  case ANCESTORMAP_ANCESTOR | ANCESTORMAP_STARTDATE:
    if((long)params.mAncestorID == aExistingProps.mAncestor && 
      params.mHierarchyStart == aExistingProps.mAncestorStart)
    {
      bClearAncestor = true;
    }
  
    break;
  case ANCESTORMAP_ANCESTOR | ANCESTORMAP_STARTDATE | ANCESTORMAP_ENDDATE:
    if((long)params.mAncestorID == aExistingProps.mAncestor && 
      params.mHierarchyStart == aExistingProps.mAncestorStart && 
      params.mHierarchyEnd == aExistingProps.mAncestorEnd) {
      bClearAncestor = true;
    }
    break;
	case ANCESTORMAP_LOGINNAME | ANCESTORMAP_NS | ANCESTORMAP_STARTDATE:
	//BP: If we are updating ancestor on a corporation (move corporate account)
	//aExistingProps.mAncestorLogon and aExistingProps.mAncestorNS properties
	//will be null, because ancestor is a root. Check for it. Fix the previous typos
	//while we are here
	{
		if(V_VT(&aExistingProps.mAncestorLogin) != VT_NULL && V_VT(&aExistingProps.mAncestorNS) != VT_NULL)
		{
			if(_bstr_t(params.mAncestorLogon) == _bstr_t(aExistingProps.mAncestorLogin) && 
				_bstr_t(params.mAncestorNamespace) == _bstr_t(aExistingProps.mAncestorNS) && 
      params.mHierarchyStart == aExistingProps.mAncestorStart) 
			{
				bClearAncestor = true;
			}
		}
    break;
	}
  case ANCESTORMAP_LOGINNAME | ANCESTORMAP_NS | ANCESTORMAP_STARTDATE | ANCESTORMAP_ENDDATE:
	{
		if(V_VT(&aExistingProps.mAncestorLogin) != VT_NULL && V_VT(&aExistingProps.mAncestorNS) != VT_NULL)
		{
			if(_bstr_t(params.mAncestorLogon) == _bstr_t(aExistingProps.mAncestorLogin) && 
				_bstr_t(params.mAncestorNamespace) == _bstr_t(aExistingProps.mAncestorNS) && 
				params.mHierarchyStart == aExistingProps.mAncestorStart && 
				params.mHierarchyEnd == aExistingProps.mAncestorEnd) 
			{
				bClearAncestor = true;
			}
		}
    break;
	}
  default:
    bClearAncestor = false;
  }
  if(bClearAncestor) {
    params.mAncestorID = vtNULL;
    params.mHierarchyStart = vtNULL;
    params.mHierarchyEnd = vtNULL;
    params.mAncestorNamespace = vtNULL;
    params.mAncestorLogon = vtNULL;
  }

  switch(params.mPaymentMap) {
    case PAYMENTMAP_ACCOUNTVAL | PAYMENTMAP_STARTDATE:
      if((long)params.mPayerID == (long)aExistingProps.mPayer && 
        params.mPayerStartDate == aExistingProps.mPayerStart)
      {
        bClearPayment = true;
      }
 
    break;
    case PAYMENTMAP_ACCOUNTVAL | PAYMENTMAP_STARTDATE | PAYMENTMAP_ENDDATE:
      if((long)params.mPayerID == (long)aExistingProps.mPayer && 
        params.mPayerStartDate == aExistingProps.mPayerStart &&
        params.mPayerEndDate == aExistingProps.mPayerEnd) {
        bClearPayment = true;
      }
    break;
    case PAYMENTMAP_LOGINNAME | PAYMENTMAP_NS | PAYMENTMAP_STARTDATE:
      if(_bstr_t(params.mPayerlogin) == _bstr_t(aExistingProps.mPayerLogin) && 
        _bstr_t(params.mPayerNamespace) == _bstr_t(aExistingProps.mPayerNS) && 
        params.mPayerStartDate == aExistingProps.mPayerStart) {
        bClearPayment = true;
      }
    break;
    case PAYMENTMAP_LOGINNAME | PAYMENTMAP_NS | PAYMENTMAP_STARTDATE | PAYMENTMAP_ENDDATE:
      if(_bstr_t(params.mPayerlogin) == _bstr_t(aExistingProps.mPayerLogin) && 
        _bstr_t(params.mPayerNamespace) == _bstr_t(aExistingProps.mPayerNS) && 
        params.mPayerStartDate == aExistingProps.mPayerStart && 
        params.mPayerEndDate == aExistingProps.mPayerEnd) {
        bClearPayment = true;
      }
    break;
    default:
      bClearPayment = false;
  }
  if(bClearPayment) {
    params.mPayerID = vtNULL;
    params.mPayerlogin = vtNULL;
    params.mPayerNamespace = vtNULL;
    params.mPayerStartDate = vtNULL;
    params.mPayerEndDate = vtNULL;
    
  }
}



void AccountTableCreationPlugIn::CheckAccountStateUpdate(CoreAccountCreationParams& params,
                            MTExistingUpdateProperties& aExistingProps,
                            MTPipelineLib::IMTSessionContextPtr pSessionContext,
                            MTPipelineLib::IMTSQLRowsetPtr pTransactionRS)
{
  if(params.mAccountState.vt != VT_NULL && params.mStateStart.vt != VT_NULL && 
    wcscmp(_bstr_t(params.mAccountState),aExistingProps.mAccState) != 0) {
    // okey dokey.  looks like we want to do a state change


    MTACCOUNTSTATESLib::IMTAccountStateManagerPtr stateMgr(__uuidof(MTACCOUNTSTATESLib::MTAccountStateManager));

    stateMgr->Initialize(aExistingProps.mAccountID,aExistingProps.mAccState);

    stateMgr->GetStateObject()->ChangeState(
      reinterpret_cast<MTACCOUNTSTATESLib::IMTSessionContext*>(pSessionContext.GetInterfacePtr()), 
      reinterpret_cast<MTACCOUNTSTATESLib::IMTSQLRowset*>(pTransactionRS.GetInterfacePtr()),
      params.mAccountID,
      -1,
      _bstr_t(params.mAccountState),
      params.mStateStart,
      params.mStateEnd);
  }
}

void  AccountTableCreationPlugIn::CheckManageAH(_bstr_t& path, MTPipelineLib::IMTSecurityContextPtr secCtx)
{
  MTAUTHLib::IMTPathCapabilityPtr pathPtr = mManageAHCapability->GetAtomicPathCapability();
  pathPtr->SetParameter(path,MTAUTHLib::SINGLE);
  secCtx->CheckAccess(mManageAHCapability);
}


void AccountTableCreationPlugIn::LoadUpdateProperties(CoreAccountCreationParams params,
                                                      MTPipelineLib::IMTSQLRowsetPtr aRowset,
                                                      MTExistingUpdateProperties& aExistingProps)
{
  aRowset->UpdateConfigPath("queries\\AccountCreation");

  if((long)params.mAccountID > 0l)
  {
    aRowset->SetQueryTag("__FIND_PROPERTIES_ON_UPDATE_BY_ACCOUNTID__");
    aRowset->AddParam("%%ID_ACC%%",params.mAccountID);
  }
  else
  {
    aRowset->SetQueryTag("__FIND_PROPERTIES_ON_UPDATE__");
    if(params.mNameSpace.vt == VT_NULL)
    {
      MT_THROW_COM_ERROR("namespace required.");  
    }
    aRowset->AddParam("%%NAMESPACE%%",params.mNameSpace);
    if(params.mlogin.vt == VT_NULL)
    {
      MT_THROW_COM_ERROR("login name required.");  
    }
    aRowset->AddParam("%%LOGINNAME%%",params.mlogin);
  }


  _variant_t vtPayStartDateTemp = params.mPayerStartDate.vt != VT_NULL ? params.mPayerStartDate : GetMTOLETime();
  _variant_t vtHierarchyStartTemp = params.mHierarchyStart.vt != VT_NULL ? params.mHierarchyStart : GetMTOLETime();
  _variant_t vtStateStartTemp = params.mStateStart.vt != VT_NULL ? params.mStateStart : GetMTOLETime();

  wstring paymentStart,hierarchyStart,stateStart;
  FormatValueForDB(vtPayStartDateTemp,FALSE,paymentStart);
  FormatValueForDB(vtHierarchyStartTemp,FALSE,hierarchyStart);
  FormatValueForDB(vtStateStartTemp,FALSE,stateStart);

  aRowset->AddParam("%%ANCESTORDATE%%",hierarchyStart.c_str(),VARIANT_TRUE);
  aRowset->AddParam("%%PAYMENTDATE%%",paymentStart.c_str(),VARIANT_TRUE);
  aRowset->AddParam("%%STATEDATE%%",stateStart.c_str(),VARIANT_TRUE);

  
  aRowset->Execute();

  if(aRowset->GetRecordCount() > 0) 
  {

    if(aRowset->GetRecordCount() != 1)
    {
      MT_THROW_COM_ERROR("More than one row found per account");  
    }

    // get the data.  God, I love this shit.  Nothing as exciting or as interesting as account update.
    aExistingProps.mAccountID = aRowset->GetValue(0l);
    if (_variant_t(aRowset->GetValue(1l)).vt != VT_NULL)
      aExistingProps.mUsageCycle = aRowset->GetValue(1l);
    else  aExistingProps.mUsageCycle = -1;
    aExistingProps.mAncestor = aRowset->GetValue(2l);
    aExistingProps.mAncestorLogin = aRowset->GetValue(3l);
    aExistingProps.mAncestorNS = aRowset->GetValue(4l);
    aExistingProps.mAncestorStart = aRowset->GetValue(5l);
    aExistingProps.mAncestorEnd = aRowset->GetValue(6l);
    aExistingProps.mPayer = aRowset->GetValue(7l);
    if (_variant_t(aRowset->GetValue(8l)).vt != VT_NULL)
      aExistingProps.mPayerLogin = aRowset->GetValue(8l);
    else
      aExistingProps.mPayerLogin = _bstr_t("");
    if (_variant_t(aRowset->GetValue(9l)).vt != VT_NULL)
      aExistingProps.mPayerNS = aRowset->GetValue(9l);
    else
      aExistingProps.mPayerNS = _bstr_t(""); 
    aExistingProps.mPayerStart = aRowset->GetValue(10l);
    aExistingProps.mPayerEnd = aRowset->GetValue(11l);
    aExistingProps.mAccType = aRowset->GetValue(12l);
    if (_variant_t(aRowset->GetValue(13l)).vt != VT_NULL)
      aExistingProps.mCorporateAccount = aRowset->GetValue(13l);
    else
      aExistingProps.mCorporateAccount = -1;
    aExistingProps.mHierarchyPath = aRowset->GetValue(14l);
    aExistingProps.mAccState = aRowset->GetValue(15l);
    if (_variant_t(aRowset->GetValue(16l)).vt != VT_NULL)
      aExistingProps.mCycleType = aRowset->GetValue(16l);
    else
      aExistingProps.mCycleType = -1;
    aExistingProps.mDayOfMonth = aRowset->GetValue(17l);
    aExistingProps.mDayOfWeek = aRowset->GetValue(18l);
    aExistingProps.mFirstDayOfMonth = aRowset->GetValue(19l);
    aExistingProps.mSecondDayOfMonth = aRowset->GetValue(20l);
    aExistingProps.mStartDay = aRowset->GetValue(21l);
    aExistingProps.mStartMonth = aRowset->GetValue(22l);
    aExistingProps.mStartYear = aRowset->GetValue(23l);
    if (_variant_t(aRowset->GetValue(24l)).vt != VT_NULL)
    {
      _bstr_t isFolder = aRowset->GetValue(24l);
      aExistingProps.mIsFolder = (MTTypeConvert::StringToBool(isFolder) == VARIANT_TRUE);
    }
    aExistingProps.mBillable = aRowset->GetValue(25l);

    // normalize values to long
    if(aExistingProps.mDayOfMonth.vt != VT_NULL) {
      aExistingProps.mDayOfMonth = (long)aExistingProps.mDayOfMonth;
    }
    if(aExistingProps.mDayOfWeek.vt != VT_NULL) {
      aExistingProps.mDayOfWeek = (long)aExistingProps.mDayOfWeek;
    }
    if(aExistingProps.mFirstDayOfMonth.vt != VT_NULL) {
      aExistingProps.mFirstDayOfMonth = (long)aExistingProps.mFirstDayOfMonth;
    }
    if(aExistingProps.mSecondDayOfMonth.vt != VT_NULL) {
      aExistingProps.mSecondDayOfMonth = (long)aExistingProps.mSecondDayOfMonth;
    }
    if(aExistingProps.mSecondDayOfMonth.vt != VT_NULL) {
      aExistingProps.mSecondDayOfMonth = (long)aExistingProps.mSecondDayOfMonth;
    }
    if(aExistingProps.mStartDay.vt != VT_NULL) {
      aExistingProps.mStartDay = (long)aExistingProps.mStartDay;
    }
    if(aExistingProps.mStartMonth.vt != VT_NULL) {
      aExistingProps.mStartMonth = (long)aExistingProps.mStartMonth;
    }
    if(aExistingProps.mStartYear.vt != VT_NULL) {
      aExistingProps.mStartYear = (long)aExistingProps.mStartYear;
    }


  }
  else {
    MT_THROW_COM_ERROR("Failed to find account properties during account update");
  }

}



HRESULT AccountTableCreationPlugIn::CheckAccountMapperBusinessRules(CoreAccountCreationParams& aParams)
{
  //-------------------------------------------------------------------------------
  // check for password and username to be not more than 40 characters
  if (_bstr_t(aParams.mlogin).length() > 40) {
    MT_THROW_COM_ERROR("Username greater than 40 characters -- Please restrict to 40 or less.");
  }

  long passwordLen = _bstr_t(aParams.mPassword).length();

  if (passwordLen > 40) {
    MT_THROW_COM_ERROR("Password greater than 40 characters -- Please restrict to 40 or less.");
  }
  if(passwordLen == 0) {
    MT_THROW_COM_ERROR("Blank Password");
  }

  if(_bstr_t(aParams.mNameSpace).length() == 0) {
      MT_THROW_COM_ERROR("Blank namespace");
  }
 
  if(_bstr_t(aParams.mNameSpace).length() > 40) {
	MT_THROW_COM_ERROR("Namespace - greater than 40 characters -- Please restrict to 40 or less.");
  }


  return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//GetUsageCycleInfo
/////////////////////////////////////////////////////////////////////////////


bool AccountTableCreationPlugIn::GetUsageCycleInfo(CoreAccountCreationParams& aParams,
                                                   MTPipelineLib::IMTSessionPtr aSession,
                                                   MTPipelineLib::IMTSecurityContextPtr secCtx)
{
  if(aSession->PropertyExists(mUsageCycleType,MTPipelineLib::SESS_PROP_TYPE_ENUM))
  {

    _bstr_t aUCT = mEnumConfig->GetEnumeratorValueByID(aSession->GetEnumProperty(mUsageCycleType));
    aParams.mCycleType = atol(aUCT);

    switch((long)aParams.mCycleType)
    {
      case 1: // monthly
        aParams.mDayOfMonth = aSession->GetLongProperty(mDayOfMonth);
        break;
      case 2: // On-demand
        break;
      case 3: // daily
        break;
      case 4: // weekly
        {
          _bstr_t bstrDayOfWeek = mEnumConfig->GetEnumeratorValueByID(aSession->GetEnumProperty(mDayOfWeek));
          aParams.mDayOfWeek = atol(bstrDayOfWeek);
          break;
        }
      case 5: // bi-weekly
        {
          aParams.mStartDay = aSession->GetLongProperty(mStartDay);
          _bstr_t bstrStartMonth = mEnumConfig->GetEnumeratorValueByID(aSession->GetEnumProperty(mStartMonth));
          aParams.mStartMonth = atol(bstrStartMonth);
          aParams.mStartYear = aSession->GetLongProperty(mStartYear);
          break;
        }
      case 6: // Semi-montly
        aParams.mFirstDayOfMonth = aSession->GetLongProperty(mFirstDayOfMonth);
        aParams.mSecondDayOfMonth = aSession->GetLongProperty(mSecondDayOfMonth);
        break;
      case 7: // Quarterly
      case 8: // Anually
      case 9: // SemiAnnually
        {
          aParams.mStartDay = aSession->GetLongProperty(mStartDay);
          _bstr_t bstrStartMonth = mEnumConfig->GetEnumeratorValueByID(aSession->GetEnumProperty(mStartMonth));
          aParams.mStartMonth = atol(bstrStartMonth);
        break;
        }
      default:
        ASSERT(!"unknown usage cycle type");
    }
    return true;
  }
  else
  {
    // no usage cycle information found in session
    return false;
  }
}

/////////////////////////////////////////////////////////////////////////////
// GetPaymentInfo
/////////////////////////////////////////////////////////////////////////////

void AccountTableCreationPlugIn::GetPaymentInfo(CoreAccountCreationParams& aParams,
                                                 MTPipelineLib::IMTSessionPtr aSession,
                                                 MTPipelineLib::IMTSecurityContextPtr secCtx)
{
  
  //an account type that cannot be a payer, can never be billable.
  if (!aParams.mCanBePayer)
  {
      aSession->SetBoolProperty(mBillable, VARIANT_FALSE);
      aParams.mBillable = "N";
  }
  else
  {
      if (aSession->PropertyExists(mBillable, MTPipelineLib::SESS_PROP_TYPE_BOOL) == VARIANT_TRUE)
        aParams.mBillable = (aSession->GetBoolProperty(mBillable) == VARIANT_TRUE) ? "Y" : "N";
  }

  if(aSession->PropertyExists(mPayerAccountID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE) {
      aParams.mPayerID = aSession->GetLongProperty(mPayerAccountID);
      aParams.mPaymentMap |= PAYMENTMAP_ACCOUNTVAL;
  }
  if(aParams.mPayerID.vt == VT_NULL) {
    if(aSession->PropertyExists(mPayerLoginName, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE) {
      aParams.mPayerlogin = aSession->GetStringProperty(mPayerLoginName);
      aParams.mPaymentMap |= PAYMENTMAP_LOGINNAME;
    }
    if(aSession->PropertyExists(mPayerNamespace, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE) {
      aParams.mPayerNamespace = aSession->GetStringProperty(mPayerNamespace);
      aParams.mPaymentMap |= PAYMENTMAP_NS;
    }
  }
  if(aSession->PropertyExists(mPayerStart, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE) {
    aParams.mPayerStartDate = aSession->GetOLEDateProperty(mPayerStart);
    aParams.mPayerStartDate.vt = VT_DATE;
    aParams.mPaymentMap |= PAYMENTMAP_STARTDATE;
  }
  if(aSession->PropertyExists(mPayerEnd, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE) {
    aParams.mPayerEndDate = aSession->GetOLEDateProperty(mPayerEnd);
    aParams.mPayerEndDate.vt = VT_DATE;
    aParams.mPaymentMap |= PAYMENTMAP_ENDDATE;
  }


}

void AccountTableCreationPlugIn::CheckPaymentAuth(CoreAccountCreationParams& aParams,
                                                  MTExistingUpdateProperties* aExistingProps,
                                                  MTPipelineLib::IMTSecurityContextPtr& secCtx)
{
   // if we are creating someone who can pay for other accounts, check the capability
    if(aExistingProps)
    {
      if (aParams.mBillable.vt != VT_NULL)
      {
        _bstr_t newBillable(aParams.mBillable);
        if(_bstr_t(aExistingProps->mBillable) != newBillable && 
          newBillable == _bstr_t("Y"))
        {
          secCtx->CheckAccess(mBillableCapability); 
        }
      }
  
    }
    
    else
    {
      if(_bstr_t(aParams.mBillable) == _bstr_t("Y")) {
        secCtx->CheckAccess(mBillableCapability); 
    }
 

    // if the payer ID OR the payerlogin name and namespace are specified, then check the payment capability
    if((aParams.mPaymentMap & PAYMENTMAP_ACCOUNTVAL) || 
      (aParams.mPaymentMap & (PAYMENTMAP_LOGINNAME|PAYMENTMAP_NS)))
    {

      if(aExistingProps == NULL || (aExistingProps && ((aParams.mPaymentMap & PAYMENTMAP_ACCOUNTVAL) && 
          aExistingProps->mPayer != (long)aParams.mPayerID)  ||
          ((aParams.mPaymentMap & (PAYMENTMAP_LOGINNAME|PAYMENTMAP_NS)) && 
            ((_bstr_t(aParams.mPayerlogin) != _bstr_t(aExistingProps->mPayerLogin)) || 
            (_bstr_t(aParams.mPayerNamespace) != _bstr_t(aExistingProps->mPayerLogin))))) ) {
        secCtx->CheckAccess(mPaymentCapability);
      }
    }
  }
}


/////////////////////////////////////////////////////////////////////////////
// GetAncestorInfo
/////////////////////////////////////////////////////////////////////////////

void AccountTableCreationPlugIn::GetAncestorInfo(CoreAccountCreationParams& aParams,
                                                   MTPipelineLib::IMTSessionPtr aSession,
                                                   MTPipelineLib::IMTSecurityContextPtr secCtx)
{
  if(aSession->PropertyExists(mAncestorID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE) {
      aParams.mAncestorID = aSession->GetLongProperty(mAncestorID);
      aParams.mAncestorMap |= ANCESTORMAP_ANCESTOR;
  }
  if(aParams.mAncestorID.vt == VT_NULL) {
    if(aSession->PropertyExists(mAncestorlogin, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE) {
      aParams.mAncestorLogon = aSession->GetStringProperty(mAncestorlogin);
        aParams.mAncestorMap |= ANCESTORMAP_LOGINNAME;
    }
    if(aSession->PropertyExists(mAncestorNameSpace, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE) {
      aParams.mAncestorNamespace = aSession->GetStringProperty(mAncestorNameSpace);
        aParams.mAncestorMap |= ANCESTORMAP_NS;
    }
  }
  if(aSession->PropertyExists(mAncestorStart, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE) {
    aParams.mHierarchyStart = aSession->GetOLEDateProperty(mAncestorStart);
    aParams.mHierarchyStart.vt = VT_DATE;
      aParams.mAncestorMap |= ANCESTORMAP_STARTDATE;
  }
  if(aSession->PropertyExists(mAncestorEnd, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE) {
    aParams.mHierarchyEnd = aSession->GetOLEDateProperty(mAncestorEnd);
    aParams.mHierarchyEnd.vt = VT_DATE;
    aParams.mAncestorMap |= ANCESTORMAP_ENDDATE;
  }

  if (aParams.mAncestorID.vt != VT_NULL && (long(aParams.mAncestorID) == -1l) && !aParams.mCanHaveSyntheticRoot)
  {
    MT_THROW_COM_ERROR(MT_ANCESTOR_INVALID_SYNTHETIC_ROOT);
  }

}

void AccountTableCreationPlugIn::GetAccountStateInfo(CoreAccountCreationParams& aParams,
                                                 MTPipelineLib::IMTSessionPtr aSession,
                                                 MTPipelineLib::IMTSecurityContextPtr secCtx)
{
  if(aSession->PropertyExists(mAccountStatus, MTPipelineLib::SESS_PROP_TYPE_ENUM)) {
    long lAccountStatus = aSession->GetEnumProperty(mAccountStatus);
    aParams.mAccountState = _variant_t(mEnumConfig->GetEnumeratorValueByID(lAccountStatus));
    aParams.mAccountStateMap |= STATEMAP_TYPE;
  }

  if(aSession->PropertyExists(mAccountStartDate, MTPipelineLib::SESS_PROP_TYPE_DATE)) {
    aParams.mStateStart = aSession->GetOLEDateProperty(mAccountStartDate);
    aParams.mStateStart.vt = VT_DATE;
    aParams.mAccountStateMap |= STATEMAP_STARTDATE;
  }
  if(aSession->PropertyExists(mAccountEndDate, MTPipelineLib::SESS_PROP_TYPE_DATE)) {
    aParams.mStateEnd = aSession->GetOLEDateProperty(mAccountEndDate);
    aParams.mStateEnd.vt = VT_DATE;
    aParams.mAccountStateMap |= STATEMAP_ENDDATE;
  }
}


void AccountTableCreationPlugIn::CheckCycleChange(CoreAccountCreationParams& params,
                          MTExistingUpdateProperties& aExistingProps,
                          MTPipelineLib::IMTSecurityContextPtr& secContext)
{
  if(params.mCycleType.vt != VT_NULL && (long)params.mCycleType != aExistingProps.mCycleType) {
    // if the cycle type does not match, check the product catalog

    MTPRODUCTCATALOGLib::IMTProductCatalogPtr ProdCatPtr(__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
    ProdCatPtr->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(secContext.GetInterfacePtr()));
    MTPRODUCTCATALOGLib::IMTPCAccountPtr PCAccountPtr;

    PCAccountPtr = ProdCatPtr->GetAccount(aExistingProps.mAccountID);

    if (PCAccountPtr->CanChangeBillingCycles() != VARIANT_TRUE)
    {
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Can't change user's billing cycle");
      MT_THROW_COM_ERROR(MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE);
    }
  }
}


/////////////////////////////////////////////////////////////////////////////
// Delete
/////////////////////////////////////////////////////////////////////////////
HRESULT 
AccountTableCreationPlugIn::Delete(MTPipelineLib::IMTSessionPtr aSession, MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{
  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////
HRESULT 
AccountTableCreationPlugIn::PlugInShutdown()
{
  return S_OK;
}

