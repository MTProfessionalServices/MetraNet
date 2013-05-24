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
#include <BatchPlugInSkeleton.h>
#include <DBConstants.h>
#include <base64.h>
#include <MTUtil.h>
#include <UsageServerConstants.h>
#include <propids.h>

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
#include <MTDate.h>

#include <OdbcException.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcResultSet.h>
#include <OdbcConnMan.h>
#include <OdbcSessionTypeConversion.h>

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

#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")
#import <MetraTech.DataAccess.MaterializedViews.tlb>
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.tlb> inject_statement("using namespace mscorlib;")

typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcResultSet> COdbcResultSetPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;

// Specify the default batch size to use for processing batch records.
#define DEFAULT_BCP_BATCH_SIZE 1250

// generate using uuidgen
CLSID CLSID_BATCHACCOUNTTABLECREATION =  /* 4BE42B38-3087-47c1-9E2A-C4AE38697F28 */
{
    0x4BE42B38,
    0x3087,
    0x47c1,
    {0x9E, 0x2A, 0xC4, 0xAE, 0x38, 0x69, 0x7F, 0x28} 
};

class ATL_NO_VTABLE BatchAccountTableCreationPlugIn : 
  public MTBatchPipelinePlugIn<BatchAccountTableCreationPlugIn, &CLSID_BATCHACCOUNTTABLECREATION>
{
public:

  // Default Constructor
  BatchAccountTableCreationPlugIn()
  : mEmptyString(""),
    mbEncryptedPassword(false),
    mTmpTableNum(0)
  {
      // Initialize materialized view manager.
      mMaterializedViewMgr = new MetraTech_DataAccess_MaterializedViews::IManagerPtr(__uuidof(MetraTech_DataAccess_MaterializedViews::Manager));
      mMaterializedViewMgr->Initialize();

      // Cache this result so that we don't need to do a COM interop each time.
      mIsMVSupportEnabled = (mMaterializedViewMgr->GetIsMetraViewSupportEnabled() == VARIANT_TRUE);
      if (mIsMVSupportEnabled)
      {
        // Enable caching.
        mMaterializedViewMgr->EnableCache(VARIANT_TRUE);

        // Initialize table name involved with Add Account for materialized view support.
        mBaseTableName = "t_dm_account";
        mDeltaTableName = mMaterializedViewMgr->GenerateDeltaInsertTableName(mBaseTableName.c_str());
            // use this temp table instead of a staging table, because the staging table
            // is processing batches, but we should run Materialized View insert on all
            // the newly created account in one shot.

        // Setup bindings.
        mMaterializedViewMgr->AddInsertBinding(mBaseTableName.c_str(), mDeltaTableName.c_str());
      }
  }

protected:

  // BatchPlugInConfigure() is called when the plug-in is being loaded.
  //
  // All COdbcExceptions are caught by the caller of this method.
  virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr           aLoggerPtr,
                                       MTPipelineLib::IMTConfigPropSetPtr aPropSetPtr,
                                       MTPipelineLib::IMTNameIDPtr        aNameIDPtr,
                                       MTPipelineLib::IMTSystemContextPtr aSysContextPtr);

  // BatchPlugInInitializeDatabase() is called after BatchPlugInConfigure() is called
  // when the plug-in is being loaded.  It may be called multiple times, especially
  // if the database connection is lost.  BatchPlugInShutdownDatabase() will always
  // be called before BatchPlugInInitializeDatabase() is called a second time.  
  //
  // All COdbcExceptions are caught by the caller of this method.
  virtual HRESULT BatchPlugInInitializeDatabase();

  // All COdbcExceptions are caught by the caller of this method.
  virtual HRESULT BatchPlugInProcessSessions(
                                       MTPipelineLib::IMTSessionSetPtr aSessionSetPtr);

  // BatchPlugInShutdown() is called when the plug-in is being shutdown.
  //
  // All COdbcExceptions are caught by the caller of this method.
  virtual HRESULT BatchPlugInShutdown();

  // BatchPlugInShutdownDatabase() is called after BatchPlugInShutdown() is called
  // when the plug-in is being shut down.  It is also called if a connection error
  // has occured in order to clean things up before attempting to reconnect.  It may
  // be called multiple times, especially if the database connection is lost.
  // BatchPlugInShutdownDatabase() will always be called after
  // BatchPlugInInitializeDatabase() has been called.  
  //
  // All COdbcExceptions are caught by the caller of this method.
  virtual HRESULT BatchPlugInShutdownDatabase();

private:
  
  HRESULT ResolveBatch(vector<MTPipelineLib::IMTSessionPtr>& sessionArray,
                       MTPipelineLib::IMTTransactionPtr pMTTransaction);
  template <class T>
  HRESULT InsertIntoTmpTable(vector<MTPipelineLib::IMTSessionPtr>& sessionArray,
                             COdbcConnectionPtr&                   bcpConnectionPtr,
                             T&                                    insertStmtPtr);

  HRESULT Add(MTPipelineLib::IMTSessionPtr& sessionPtr,
              CoreAccountCreationParams& params);

  void GetUsageCycleInfo(CoreAccountCreationParams&           aParams,
                         MTPipelineLib::IMTSessionPtr&         aSessionPtr,
                         MTPipelineLib::IMTSecurityContextPtr aSecCtxPtr);

  void GetPaymentInfo(CoreAccountCreationParams&           aParams,
                      MTPipelineLib::IMTSessionPtr&         aSessionPtr,
                      MTPipelineLib::IMTSecurityContextPtr aSecCtxPtr);

  void GetAncestorInfo(CoreAccountCreationParams&           aParams,
                       MTPipelineLib::IMTSessionPtr&         aSessionPtr,
                       MTPipelineLib::IMTSecurityContextPtr& aSecCtxPtr);

  void GetAccountStateInfo(CoreAccountCreationParams&           aParams,
                           MTPipelineLib::IMTSessionPtr&         aSessionPtr,
                           MTPipelineLib::IMTSecurityContextPtr& aSecCtxPtr);

  void CheckAccountMapperBusinessRules(CoreAccountCreationParams& aParams);

  void CheckManageAH(_bstr_t&                             aPath,
                     MTPipelineLib::IMTSecurityContextPtr& aSecCtxPtr);

  void CheckPaymentAuth(CoreAccountCreationParams&            aParams,
                        MTPipelineLib::IMTSecurityContextPtr& aSecCtxPtr);

  HRESULT GenerateQueries(const char* stagingDBName);
  
  void GeneratePaymentRecord(CoreAccountCreationParams& aParams,
                                                MTPipelineLib::IMTSessionPtr& aSessionPtr,
                                                MTPipelineLib::IMTSecurityContextPtr aSecCtxPtr);

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
  long mBillable;           // controls whether an account can pay for another account
  long mUsageCycleType;     // new with 3.0 account state support
  long mAccountStartDate;
  long mPayerAccountID;     // payment redirection
  long mPayerLoginName;
  long mPayerNamespace;
  long mPayerStart;
  long mPayerEnd;
  long mAncestorID;         // hierarchy support
  long mOldAncestorID;      // only set in case this account was moved
  long mCorporateAccountID;
  long mAncestorlogin;
  long mAncestorNameSpace;
  long mAncestorStart;
  long mAncestorEnd;
  long mIsFolder;
  long mApplyDSP;
  long mCurrency;
  bool mbEncryptedPassword;
  long mCanBePayerID;
  long mCanSubscribeID;
  long mCanHaveSyntheticRootID;
  long mCanParticipateInGSubID;
  long mIsVisibleInHierarchyID;
  long mCanHaveTemplatesID;
  long mIsCorporateID;
  long mLoginApplicationID;

  MTPipelineLib::IMTLogPtr mLogger;

  MTPipelineLib::IMTLogPtr mPerfLogger;
  bool                     mOkToLogPerfInfo;

  MTPipelineLib::IMTCompositeCapabilityPtr mPaymentCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mBillableCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mCreateCorporateAccountCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mCreateSubscriberCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mCreateCSRCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mManageAHCapability;
  MTPipelineLib::IMTCompositeCapabilityPtr mManageIndepAccCapability;

  QUERYADAPTERLib::IMTQueryAdapterPtr mQueryAdapter;

  AuditEventsLib::MTAuditEvent mDeniedAuditEvent;

  _bstr_t mEmptyString;
  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

  COdbcPreparedArrayStatementPtr mArrayInsertToTmpTableStmt;

  BOOL        mUseBcpFlag;
  int         mArraySize;

  BOOL        mbEnforceSameCorp;
  bool        mbSessionsFailed;

  int mTmpTableNum;
  std::string mTagName;
  string mTmpTableName;     // Set in GenerateQueries().
  string mTmpTableFullName; // Set in GenerateQueries().
  string mTmpTableIdxName;  // Set in GenerateQueries().

  string  mTmpTableCreateSQL;     // Set in GenerateQueries().
  string  mTmpTableInsertSQL;     // Set in GenerateQueries().
  string  mTmpTableTruncateSQL;   // Set in GenerateQueries().
  _bstr_t mTmpTableExecuteSQL;    // Set in BatchPlugInProcessSessions().
  _bstr_t mTmpTableGetResultsSQL; // Set in GenerateQueries().
  std::vector<std::string>  mTmpTableDropSQL;       // Set in GenerateQueries().

  __int64 mTruncateTableTicks;
  __int64 mDataValidationTicks;
  __int64 mBatchInsertSetupTicks;
  __int64 mBatchInsertExecutionTicks;
  __int64 mBatchUpdateExecutionTicks;
  __int64 mProcessResultsTicks;

  // Map used to check for primary key constraint
  typedef std::map<wstring, bool> PrimaryKeyMap;
	PrimaryKeyMap mPrimaryKeyMap;

  // Single instance of materialized views manager.
  MetraTech_DataAccess_MaterializedViews::IManagerPtr mMaterializedViewMgr;
  bool mIsMVSupportEnabled;
  string mBaseTableName;
  string mDeltaTableName;
  string mTruncateDeltaTable;
  string mCreatedAccountIdList;
};

PLUGIN_INFO(CLSID_BATCHACCOUNTTABLECREATION, 
            BatchAccountTableCreationPlugIn,
            "MetraPipeline.AccountTableCreation.1", 
            "MetraPipeline.AccountTableCreation", "Free")

/////////////////////////////////////////////////////////////////////////////
// BatchPlugInConfigure
/////////////////////////////////////////////////////////////////////////////
HRESULT
BatchAccountTableCreationPlugIn::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr           aLoggerPtr,
                                                      MTPipelineLib::IMTConfigPropSetPtr aPropSetPtr,
                                                      MTPipelineLib::IMTNameIDPtr        aNameIDPtr,
                                                      MTPipelineLib::IMTSystemContextPtr aSysContextPtr)
{
  const char* procName = "BatchAccountTableCreationPlugIn::BatchPlugInConfigure";

  mLogger = aLoggerPtr;
  mTagName = GetTagName(aSysContextPtr);

  mPerfLogger = MTPipelineLib::IMTLogPtr(MTPROGID_LOG);
  mPerfLogger->Init("logging\\perflog", "[BatchAccountTableCreation]");

	mOkToLogPerfInfo = ((mPerfLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG)) == VARIANT_TRUE);

  mQueryAdapter.CreateInstance(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
  mQueryAdapter->Init("queries\\AccountCreation");

	// Get the drop table query.
  if (mIsMVSupportEnabled)
  {
    // Create the tables.
    mQueryAdapter->SetQueryTag("__CREATE_ACCOUNT_DELTA_TABLE__");
    mQueryAdapter->AddParam("%%TABLE_NAME%%", mDeltaTableName.c_str());

    ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	  rs->Init("queries\\AccountCreation");
    rs->SetQueryString(mQueryAdapter->GetQuery());
    rs->Execute();

    // Get the truncate query.
    mQueryAdapter->SetQueryTag("__TRUNCATE_ACCOUNT_DELTA_TABLE__");
    mQueryAdapter->AddParam("%%TABLE_NAME%%", mDeltaTableName.c_str());
    mTruncateDeltaTable = mQueryAdapter->GetQuery() + "\n";
  }

  if (aPropSetPtr->NextMatches(L"usebcpflag", MTPipelineLib::PROP_TYPE_BOOLEAN))
    mUseBcpFlag = aPropSetPtr->NextBoolWithName(L"usebcpflag") == VARIANT_TRUE;
  else
    mUseBcpFlag = TRUE;

  if (aPropSetPtr->NextMatches(L"batch_size", MTPipelineLib::PROP_TYPE_INTEGER))
    mArraySize = aPropSetPtr->NextLongWithName("batch_size");
  else
    mArraySize = DEFAULT_BCP_BATCH_SIZE;

  if (IsOracle())
    mUseBcpFlag = FALSE;

  if (mUseBcpFlag)
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BatchAccountTableCreation will use BCP");
  else
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BatchAccountTableCreation will not use BCP");

  char tmpBuf[128];
  sprintf(tmpBuf, "BatchAccountTableCreation will use a batch size of %d", mArraySize);
  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, tmpBuf);

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
  DECLARE_PROPNAME("b_canbepayer", &mCanBePayerID)
  DECLARE_PROPNAME("b_cansubscribe", &mCanSubscribeID)
  DECLARE_PROPNAME("b_cansyntheticroot", &mCanHaveSyntheticRootID)
  DECLARE_PROPNAME("b_canparticipateingsub", &mCanParticipateInGSubID)
  DECLARE_PROPNAME("b_isvisibleinhierarchy", &mIsVisibleInHierarchyID)
  DECLARE_PROPNAME("b_canhavetemplates", &mCanHaveTemplatesID)
  DECLARE_PROPNAME("b_iscorporate", &mIsCorporateID)
  DECLARE_PROPNAME("loginapplication", &mLoginApplicationID)

  END_PROPNAME_MAP
    
  HRESULT hr = ProcessProperties(inputs, aPropSetPtr, aNameIDPtr, aLoggerPtr, procName);
  if (!SUCCEEDED(hr))
    return hr;

  PipelinePropIDs::Init();

  // See if the password string has a trailing underscore (is encrypted).
  wstring aTempStr = (const wchar_t*)_bstr_t(aNameIDPtr->GetName(mPassword));
  mbEncryptedPassword = aTempStr[aTempStr.length()-1] == L'_';

  try
  {
    //get enum config pointer from system context
    mEnumConfig = aSysContextPtr->GetEnumConfig();
    _ASSERTE(mEnumConfig != NULL);

    MTPipelineLib::IMTSecurityPtr securityPtr;
    securityPtr.CreateInstance(__uuidof(MTAUTHLib::MTSecurity));

    // get capabilities from the auth subsystem
    mPaymentCapability = securityPtr->GetCapabilityTypeByName(MANAGE_PAYMENT_CAP)->CreateInstance();
    mBillableCapability = securityPtr->GetCapabilityTypeByName(MANAGE_BILLABLE_CAP)->CreateInstance();
    mCreateCorporateAccountCapability = securityPtr->GetCapabilityTypeByName(CREATE_CORPORATE_CAP)->CreateInstance();
    mCreateSubscriberCapability = securityPtr->GetCapabilityTypeByName(CReATE_SUBSCRIBER_CAP)->CreateInstance();
    mCreateCSRCapability = securityPtr->GetCapabilityTypeByName(CREATE_CSR_CAP)->CreateInstance();

    MTAUTHLib::IMTEnumTypeCapabilityPtr enumPtr;

    mManageAHCapability = securityPtr->GetCapabilityTypeByName(MANAGE_HIERARCHY_CAP)->CreateInstance();
    enumPtr = mManageAHCapability->GetAtomicEnumCapability();
    enumPtr->SetParameter("WRITE");
    
    mManageIndepAccCapability = securityPtr->GetCapabilityTypeByName(MANAGE_NON_HIER_ACCOUNTS_CAP)->CreateInstance();
    enumPtr = mManageIndepAccCapability->GetAtomicEnumCapability();
    enumPtr->SetParameter("WRITE");

    mDeniedAuditEvent = AuditEventsLib::AUDITEVENT_ACCOUNT_CREATE_DENIED;

    COdbcConnectionInfo netMeterInfo = COdbcConnectionManager::GetConnectionInfo("NetMeter");
    COdbcConnectionInfo stageDBEntry = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
    COdbcConnectionInfo stageDBInfo(netMeterInfo);
    stageDBInfo.SetCatalog(stageDBEntry.GetCatalog().c_str());
    GenerateQueries(stageDBInfo.GetCatalog().c_str());
  }
  catch(_com_error& e)
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Failed to acquire the needed interfaces and/or capabilities");
    return ReturnComError(e);
  }

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// BatchPlugInInitializeDatabase
/////////////////////////////////////////////////////////////////////////////
HRESULT BatchAccountTableCreationPlugIn::BatchPlugInInitializeDatabase()
{
  const char* procName = "BatchAccountTableCreationPlugIn::BatchPlugInInitializeDatabase";

  // This plug-in writes to the database so we should not allow retry.
  AllowRetryOnDatabaseFailure(FALSE);

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// BatchPlugInProcessSessions
/////////////////////////////////////////////////////////////////////////////
HRESULT 
BatchAccountTableCreationPlugIn::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSetPtr)
{
  const char* procName = "BatchAccountTableCreationPlugIn::BatchPlugInProcessSessions";

  MTPipelineLib::IMTSessionPtr         curSession     = NULL;
  MTPipelineLib::IMTSQLRowsetPtr       rowset         = NULL;
  bool                                 isFirstSession = true;
  int                                  curRecordCount = 0;
  vector<MTPipelineLib::IMTSessionPtr> sessionArray;

  mbSessionsFailed = false;

  LARGE_INTEGER freq;
  LARGE_INTEGER tick;

  if (mOkToLogPerfInfo)
  {
    // resets performance counters
    mTruncateTableTicks = 0;
    mDataValidationTicks = 0;
    mBatchInsertSetupTicks = 0;
    mBatchInsertExecutionTicks = 0;
    mBatchUpdateExecutionTicks = 0;
    mProcessResultsTicks = 0;

    ::QueryPerformanceFrequency(&freq);
    ::QueryPerformanceCounter(&tick);
  }

  SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
  HRESULT hr = it.Init(aSessionSetPtr);
  if (FAILED(hr))
    return hr;

  // Clear key map; not to mix keys from previous sets.
  mPrimaryKeyMap.clear();

  //
  mbEnforceSameCorp = (PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE);

  // Reset the created account list.
  mCreatedAccountIdList = "";

  MTPipelineLib::IMTTransactionPtr pMTTransaction;

  while (TRUE)
  {
    curSession = it.GetNext();
    if (curSession == NULL)
      break;

    if (isFirstSession)
    {

      isFirstSession = false;

      // Get the rowset from the first session in the set.
      // This rowset is part of the transaction for this session set.
      rowset = curSession->GetRowset("queries\\AccountCreation");
      // Get the txn from the first session in the set.  Call after GetRowset, since
      // GetRowset forces it to be created if it hasn't yet.
      pMTTransaction = GetTransaction(curSession);
    }

    curRecordCount++;
    sessionArray.push_back(curSession);

    // Resolves a chunk of sessions.
    if (sessionArray.size() >= (unsigned int) mArraySize)
    {
      ASSERT(sessionArray.size() == (unsigned int) mArraySize);

      hr = ResolveBatch(sessionArray, pMTTransaction);
      if (FAILED(hr))
        return hr;

      rowset->Clear();
      sessionArray.clear();
    }
  }

  // resolves the last partial chunk if necessary
  if (sessionArray.size() > 0)
  {
    hr = ResolveBatch(sessionArray, pMTTransaction);
    if (FAILED(hr))
      return hr;

    rowset->Clear();
    sessionArray.clear();
  }

  //-----
  // Start of Materialized View processing.
  //-----

  // Is materialize view support enabled?
  if (mIsMVSupportEnabled && mCreatedAccountIdList.length() > 0)
  {
    // Generate delta table for materialized view update.
    mQueryAdapter->ClearQuery();
    mQueryAdapter->SetQueryTag("__INSERT_INTO_ACCOUNT_DELTA_TABLE__");
    mQueryAdapter->AddParam("%%TABLE_NAME%%", mBaseTableName.c_str());
    mQueryAdapter->AddParam("%%DELTA_TABLE_NAME%%", mDeltaTableName.c_str());
    mQueryAdapter->AddParam("%%ID_ACC_LIST%%", mCreatedAccountIdList.c_str());
    string PopulateDeltaTableSQL = mQueryAdapter->GetQuery() + "\n";

    // Create safe array of product view tables that were metered.
    SAFEARRAYBOUND sabound[1];
    sabound[0].lLbound = 0;
    sabound[0].cElements = 1;
    SAFEARRAY* pSA = SafeArrayCreate(VT_BSTR, 1, sabound);
    if (pSA == NULL)
      MT_THROW_COM_ERROR("Unable to create safe arrary for materialized view insert trigger list.");

    // Try - Catch, to make sure safe arrays are cleaned up.
    bool bSALocked = false;
    try
    {
      // Set data to the contents of the safe array.
      BSTR HUGEP *pbstrNames;
      if (!::SafeArrayAccessData(pSA, (void**)&pbstrNames))
      {
        // Set to true incase exception is thrown before we release.
        bSALocked = true;

        // Account Add affects the base table.
        _bstr_t _bstrName(mBaseTableName.c_str());
        pbstrNames[0] = ::SysAllocString(_bstrName);
        ::SafeArrayUnaccessData(pSA);
        bSALocked = false;
      }
      else
		    MT_THROW_COM_ERROR("Unable to access safe array trigger data.");

      // Get query to execute for all materialized views that changed due to
      // changes made to t_pv_* tables.
      _bstr_t _bstrQueriesToExecute(mMaterializedViewMgr->GetMaterializedViewInsertQuery(pSA));

      // Free safe array.
      ::SafeArrayDestroy(pSA);
      pSA = NULL;

      // Execute the queries.
      if (!!_bstrQueriesToExecute)
      {
        // First, trunncate the delta table.
        _bstr_t _bstrExecuteSQL = "begin\n";

        // Populate temp delta table query.
        _bstrExecuteSQL += PopulateDeltaTableSQL.c_str();

        // Update materialized view query.
        _bstrExecuteSQL += "\n";
        _bstrExecuteSQL += _bstrQueriesToExecute;

        // append the truncate queries.
        _bstrExecuteSQL += "\n";
        _bstrExecuteSQL += mTruncateDeltaTable.c_str();

        // Done
        _bstrExecuteSQL += "end;";

        // Execute query.
        rowset->Clear();
        rowset->SetQueryString(_bstrExecuteSQL);
        rowset->Execute();
      }
    }
    catch (...)
    {
      if (pSA)
      {
        if (bSALocked)
          ::SafeArrayUnaccessData(pSA);

        ::SafeArrayDestroy(pSA);
      }

      // Release rowset.
      rowset = NULL;

      throw; // pass exception.
    }
  }

  //-----
  // End of Materialized View processing.
  //-----

  // Release rowset.
  rowset = NULL;

  if (mOkToLogPerfInfo)
  {
    LARGE_INTEGER tock;

    ::QueryPerformanceCounter(&tock);

    // Overall performance statistic.
    char buf[256];
    long ms = (long) ((1000 * (tock.QuadPart - tick.QuadPart)) / freq.QuadPart);
    sprintf(buf, "BatchAccountTableCreationPlugIn::PlugInProcessSessions for %d records took %d milliseconds.", curRecordCount, ms);
    mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buf));

    // Truncating the temporary table statistic.
    ms = (long) (1000 * mTruncateTableTicks / freq.QuadPart);
    sprintf(buf, "BatchAccountTableCreationPlugIn::TruncateTmpTable took %d milliseconds.", ms);
    mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buf));

    // Data validation and user access permissions validation statistics.
    ms = (long) (1000 * mDataValidationTicks / freq.QuadPart);
    sprintf(buf, "BatchAccountTableCreationPlugIn::DataAndUserValidation for %d records took %d milliseconds", curRecordCount, ms);
    mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buf));

    // Inserting the data into the temporary table statistic.
    ms = (long) (1000 * mBatchInsertSetupTicks / freq.QuadPart);
    sprintf(buf, "BatchAccountTableCreationPlugIn::BatchInsertSetup for %d records took %d milliseconds.", curRecordCount, ms);
    mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buf));

    // Inserting the data into the temporary table statistic.
    ms = (long) (1000 * mBatchInsertExecutionTicks / freq.QuadPart);
    sprintf(buf, "BatchAccountTableCreationPlugIn::InsertIntoTmpTable for %d records took %d milliseconds.", curRecordCount, ms);
    mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buf));

    // Batch update SQL query performance statistic.
    ms = (long) (1000 * mBatchUpdateExecutionTicks / freq.QuadPart);
    sprintf(buf, "BatchAccountTableCreationPlugIn::BatchUpdateExecution for %d records took %d milliseconds.", curRecordCount, ms);
    mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buf));

    // Fetching and processing the batch execution results statistic.
    ms = (long) (1000 * mProcessResultsTicks / freq.QuadPart);
    sprintf(buf, "BatchAccountTableCreationPlugIn::ProcessResults for %d records took %d milliseconds.", curRecordCount, ms);
    mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buf));
  }

  if (mbSessionsFailed)
    return PIPE_ERR_SUBSET_OF_BATCH_FAILED;

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// BatchPlugInShutdown
/////////////////////////////////////////////////////////////////////////////
HRESULT BatchAccountTableCreationPlugIn::BatchPlugInShutdown()
{
  const char* procName = "BatchAccountTableCreationPlugIn::BatchPlugInShutdown";
  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// BatchPlugInShutdownDatabase
/////////////////////////////////////////////////////////////////////////////
HRESULT BatchAccountTableCreationPlugIn::BatchPlugInShutdownDatabase()
{
  const char* procName = "BatchAccountTableCreationPlugIn::BatchPlugInShutdownDatabase";

  mArrayInsertToTmpTableStmt = NULL;

  return S_OK;
}

class TempTableAutoCreate
{
private:
  COdbcConnectionPtr mBcpConnection;
  string mTmpTableCreateSQL;
public:
	TempTableAutoCreate(COdbcConnectionPtr conn, const string & create, std::vector<std::string> & drop, BOOL isOracle)
    :
    mBcpConnection(conn),
    mTmpTableCreateSQL(create)
  {
      // Make sure our "temporary" table exists and is empty.
      COdbcStatementPtr createTmpTableStmt = mBcpConnection->CreateStatement();
      createTmpTableStmt->ExecuteUpdate(mTmpTableCreateSQL);

	  // In case of oracle, drop the table created during the previous execution of this plugin.
	  // We will check for 4 previous attempts.  Not needed in case of SQL Server as a "real" temp
	  // table is used, which is cleaned up by the database.
	  if (isOracle)
	  {
		  for (std::vector<std::string>::size_type i = 0; i < drop.size(); i++)
		  {
			  createTmpTableStmt->ExecuteUpdate(drop[i]);
		  }
	  }
  }

  ~TempTableAutoCreate()
  {
  }
};

class AutoLeaveTransaction
{
private:
  COdbcConnectionPtr mBcpConnection;
public:
  AutoLeaveTransaction(COdbcConnectionPtr conn, MTPipelineLib::IMTTransactionPtr pMTTransaction) 
  {
    if (pMTTransaction != NULL)
    {
      ITransactionPtr pITransaction;

      pITransaction = pMTTransaction->GetTransaction();
      ASSERT(pITransaction != NULL);
      mBcpConnection = conn;
      mBcpConnection->JoinTransaction(pITransaction);
    }
  }

  ~AutoLeaveTransaction()
  {
    if (mBcpConnection) 
    {
      try
      {
        mBcpConnection->LeaveTransaction();
      }
      catch (COdbcException & ex)
      {
        string what = ex.what();
        throw ex;
      }
      catch(...)
      {
      }
    }
  }
};

/////////////////////////////////////////////////////////////////////////////
// ResolveBatch
/////////////////////////////////////////////////////////////////////////////

#define IDX_ID_REQUEST      1
#define IDX_STATUS          2
#define IDX_ID_ACCOUNT      3
#define IDX_ANCESTOR_OUT    4
#define IDX_CORPORATION     5
#define IDX_HIERARCHY_PATH  6
#define IDX_ACC_TYPE        7
#define IDX_NM_SPACE        8
#define IDX_ANCESTOR_TYPE   9

HRESULT 
BatchAccountTableCreationPlugIn::ResolveBatch(vector<MTPipelineLib::IMTSessionPtr>& sessionArray,
                                              MTPipelineLib::IMTTransactionPtr pMTTransaction)
{
  LARGE_INTEGER tick;

  try
  {
    if (mOkToLogPerfInfo)
      ::QueryPerformanceCounter(&tick);

    COdbcConnectionInfo netMeterInfo = COdbcConnectionManager::GetConnectionInfo("NetMeter");
	COdbcConnectionInfo netMeterStageInfo = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
	
    COdbcConnectionPtr             mBcpConnection;  // For doing the actual BCPing.
    mBcpConnection = new COdbcConnection(netMeterInfo);

    GenerateQueries(netMeterStageInfo.GetCatalog().c_str());

    // Use auto commit only if using BCP.
    mBcpConnection->SetAutoCommit(true);//mUseBcpFlag ? true : false);
    COdbcPreparedBcpStatementPtr   mBcpInsertToTmpTableStmt;

    HRESULT      hr               = S_OK;
    unsigned     sessionsResolved = 0;

    // Make sure that the temp table is both created and deleted.
    // TODO: Handle lost connectivity since we don't want to throw in d'tor.
	// for oracle, we are using a global temporary table, no need to drop and
	// recreate it at this point.  Yes, this will not allow multi-stage account creation,
	// but to support multi-stage account creation we will have a pipeline API that would clean up
	// resources after a session set is completed.  When that is done, we can change this code
	// to use real tables with a unique name, similar to the sql server implementation.
    TempTableAutoCreate ttac(mBcpConnection, mTmpTableCreateSQL, mTmpTableDropSQL, IsOracle());

    // Prepare temp table insert query.
    if (mUseBcpFlag)
    {
      COdbcBcpHints hints;
      // use minimally logged inserts.
      // TODO: this may only matter if database recovery model settings are correct.
      //       however, it won't hurt if they're not
      hints.SetMinimallyLogged(true);

      mBcpInsertToTmpTableStmt = mBcpConnection->PrepareBcpInsertStatement(mTmpTableName, hints);
    } 
    else
    {
      if (IsOracle())
        mArrayInsertToTmpTableStmt = mBcpConnection->PrepareInsertStatement(mTmpTableName, mArraySize);
      else
        mArrayInsertToTmpTableStmt = mBcpConnection->PrepareStatement(mTmpTableInsertSQL, mArraySize);
    }

    if (mOkToLogPerfInfo)
    {
      LARGE_INTEGER tock;

      ::QueryPerformanceCounter(&tock);
      mTruncateTableTicks += (tock.QuadPart - tick.QuadPart);
    }

    // Insert sessions' arguments into the temp table.
    if(mUseBcpFlag)
      hr = InsertIntoTmpTable(sessionArray, mBcpConnection, mBcpInsertToTmpTableStmt);
    else
      hr = InsertIntoTmpTable(sessionArray, mBcpConnection, mArrayInsertToTmpTableStmt);
    if (FAILED(hr))
      return hr;

    if (mUseBcpFlag)
    {
      mBcpInsertToTmpTableStmt->Finalize();
      mBcpInsertToTmpTableStmt = NULL;
    }
    else
    {
      mArrayInsertToTmpTableStmt = NULL;
    }

    // Should we finalize here?  This may be necessary to release locks.

    if (mOkToLogPerfInfo)
      ::QueryPerformanceCounter(&tick);

    if (mbSessionsFailed)
      return S_OK;

    // The rest of the work is going to be done in the DTC transaction (BCPs
    // really don't know how to play DTC (or true txns in general).
    // TODO: Handle lost connectivity since we don't want to throw in d'tor.
    AutoLeaveTransaction alt (mBcpConnection, pMTTransaction);
    // Get the results.
    // Execute the batch update.
    COdbcStatementPtr stmt = mBcpConnection->CreateStatement();
    stmt->ExecuteUpdateW((const wchar_t *)mTmpTableExecuteSQL);
    
    COdbcResultSetPtr rs = stmt->ExecuteQueryW((const wchar_t *)mTmpTableGetResultsSQL);
  
    if (mOkToLogPerfInfo)
    {
      LARGE_INTEGER tock;

      ::QueryPerformanceCounter(&tock);
      mBatchUpdateExecutionTicks += (tock.QuadPart - tick.QuadPart);

      ::QueryPerformanceCounter(&tick);
    }

    // Declare our current session pointer.
    MTPipelineLib::IMTSessionPtr curSession = 0;

    BOOL       allSessionsSucceeded = TRUE;

    long    id_request, id_account, id_ancestor_out, id_corporation;
    _bstr_t hierarchy_path, acc_type, nm_space;

    // Loop over result set setting properties into individual sessions.
    while(rs->Next())
    {
      try
      {
        _bstr_t ancestor_type;

        // Retrieve the session's identifier from the current row.
        id_request = rs->GetInteger(IDX_ID_REQUEST);
        ASSERT(!rs->WasNull());

        curSession = sessionArray[id_request];

        int status = rs->GetInteger(IDX_STATUS);

        // If the value is not NULL then we have an error!
        if (!rs->WasNull())
        {
          char        LogBuf[1024];
          HRESULT     errorCode;
          IErrorInfo* errorInfo = 0;

          errorCode = (HRESULT)status;

          acc_type = rs->GetString(IDX_ACC_TYPE).c_str();
          ASSERT(!rs->WasNull());

          nm_space = rs->GetWideString(IDX_NM_SPACE).c_str();
          ASSERT(!rs->WasNull());

          ancestor_type = rs->GetString(IDX_ANCESTOR_TYPE).c_str();

          switch (errorCode)
          {
            // If the account type and namespace mismatch then return
            // a parameterized message.
            //
            // MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH ((DWORD)0xE2FF0044L)
          case MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH :
            sprintf(LogBuf, 
                    "Accounts of type '%s' are not allowed in namespace '%s'. Please choose an appropriate account type or namespace",
                    (const char*)acc_type,
                    (const char*)nm_space);
            Error(LogBuf,
                  IID_IMTPipelinePlugIn, 
                  errorCode);
            GetErrorInfo(0, &errorInfo);
            throw _com_error(errorCode, errorInfo);

            // An account in the hierarchy cannot belong to the system namespace.
            //
            // MT_ACCOUNT_NAMESPACE_AND_HIERARCHY_MISMATCH ((DWORD)0xE2FF0045L)
          case MT_ACCOUNT_NAMESPACE_AND_HIERARCHY_MISMATCH :
            sprintf(LogBuf, 
                    "Accounts in the '%s' namespace are not allowed in a hierarchy", 
                    (const char*)nm_space);
            Error(LogBuf,
                  IID_IMTPipelinePlugIn, 
                  errorCode);
            GetErrorInfo(0, &errorInfo);
            throw _com_error(errorCode, errorInfo);

          case MT_ANCESTOR_OF_INCORRECT_TYPE :
             MT_THROW_COM_ERROR(MT_ANCESTOR_OF_INCORRECT_TYPE, (char *)acc_type, (char *)ancestor_type);

          default:
            MT_THROW_COM_ERROR(errorCode);
          }
        }

        id_account = rs->GetInteger(IDX_ID_ACCOUNT);
        ASSERT(!rs->WasNull());
        curSession->SetLongProperty(mAccountID, id_account);


        // Add account ID to the list of accounts for which 
        // we will execute materialized view update.
        if (mIsMVSupportEnabled)
        {
          char AccountID[64];
          if (mCreatedAccountIdList.size() > 0)
		        sprintf(AccountID, ", %d", id_account);
          else
		        sprintf(AccountID, "%d", id_account);

          mCreatedAccountIdList += AccountID;
        }

        id_ancestor_out = rs->GetInteger(IDX_ANCESTOR_OUT);

        // Set the ancestor id if it is not already set in the session.
        if(curSession->PropertyExists(mAncestorID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_FALSE)
          curSession->SetLongProperty(mAncestorID, id_ancestor_out);

        id_corporation = rs->GetInteger(IDX_CORPORATION);
        ASSERT(!rs->WasNull());
        curSession->SetLongProperty(mCorporateAccountID, id_corporation);

        hierarchy_path = rs->GetString(IDX_HIERARCHY_PATH).c_str();
        ASSERT(!rs->WasNull());

        acc_type = rs->GetString(IDX_ACC_TYPE).c_str();
        ASSERT(!rs->WasNull());

        // Check if the account has the capabililty to add accounts to the hierarchy at this path.
        if (wcscmp((const wchar_t*)acc_type, ACCOUNT_TYPE_SYSTEM) != 0)
        {
          MTPipelineLib::IMTSecurityContextPtr secCtx = curSession->GetSessionContext()->GetSecurityContext();

          try
          {
            CheckManageAH(hierarchy_path, secCtx);
          }
          catch (_com_error& err)
          {
            if (err.Error() == MTAUTH_ACCESS_DENIED)
            {
              AuditAuthFailures(err,
                                mDeniedAuditEvent,
                                secCtx->AccountID, 
                                AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                                -1); 
            }

            throw;  // Re-throw the current exception.
          }
        }
      }
      catch (_com_error& err)
      {
        _bstr_t message = err.Description();
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);

        if (curSession != 0)
        {
          curSession->MarkAsFailed(message.length() > 0 ? message : L"", err.Error());
          mbSessionsFailed = true;
        }
        else
        {
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "The current session pointer was not set.");
          return err.Error();
        }
      }

      curSession = 0;
    }
  }
  catch (COdbcException & ex)
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, ex.what());
    return E_FAIL;
  }

  if (mOkToLogPerfInfo)
  {
    LARGE_INTEGER tock;

    ::QueryPerformanceCounter(&tock);
    mProcessResultsTicks += (tock.QuadPart - tick.QuadPart);
  }
  
  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// InsertIntoTmpTable
/////////////////////////////////////////////////////////////////////////////
template<class T> HRESULT
BatchAccountTableCreationPlugIn::InsertIntoTmpTable(vector<MTPipelineLib::IMTSessionPtr>& sessionArray,
                                                    COdbcConnectionPtr&                   bcpConnectionPtr,
                                                    T&                                    insertStmtPtr)
{
  HRESULT hr = S_OK;

  LARGE_INTEGER tick;
  LARGE_INTEGER tick2;

  if (mOkToLogPerfInfo)
    ::QueryPerformanceCounter(&tick);

  // Declare our current session pointer.
  MTPipelineLib::IMTSessionPtr curSession = 0;

  _bstr_t sOperation;

  unsigned int uiArraySize = sessionArray.size();

  MetraTech_DataAccess::IIdGenerator2Ptr idProfileGenerator(__uuidof(MetraTech_DataAccess::IdGenerator));
  idProfileGenerator->Initialize("id_profile", uiArraySize);
  MetraTech_DataAccess::IIdGenerator2Ptr idAccGenerator(__uuidof(MetraTech_DataAccess::IdGenerator));
  idAccGenerator->Initialize("id_acc", uiArraySize);

  for (unsigned int i = 0; i < uiArraySize; i++)
  {
    curSession = sessionArray[i];

    try
    {
      // Define this here so that it is reinitialized
      // each iteration through the loop.
      CoreAccountCreationParams inputParams;
      
      sOperation = mEnumConfig->GetEnumeratorByID(curSession->GetEnumProperty(mOperation));
      
      if (sOperation.length() == 0)  // Blank, return error.
        MT_THROW_COM_ERROR("Blank Operation");

      if (_wcsicmp((wchar_t*)sOperation, L"Add") != 0)
        MT_THROW_COM_ERROR(MT_UNSUPPORTED_ACCOUNT_OPERATION, (const char*)sOperation);

      _bstr_t sActionType = mEnumConfig->GetEnumeratorByID(curSession->GetEnumProperty(mActionType));

      // Do nothing if action type is contact because all we need to
      // do is update account extension data, not other account data.
      if ((0 == _wcsicmp((wchar_t*)sActionType, L"contact")))
        continue;

      if (mOkToLogPerfInfo)
        ::QueryPerformanceCounter(&tick2);

      hr = Add(curSession, inputParams);

      if (hr == PIPE_ERR_SUBSET_OF_BATCH_FAILED)
        continue;

      if (FAILED(hr))
        return hr;

      if (mOkToLogPerfInfo)
      {
        LARGE_INTEGER tock;

        ::QueryPerformanceCounter(&tock);
        mDataValidationTicks += (tock.QuadPart - tick2.QuadPart);
        mBatchInsertSetupTicks -= (tock.QuadPart - tick2.QuadPart);
      }

      string           tmpString;
      wstring          tmpWideString;
      TIMESTAMP_STRUCT tmpODBCTimestamp;

      // Set id_request (internal ID used to match up results).  Required.
      insertStmtPtr->SetInteger(1, i);

      // Set id_acc_ext.  Optional.
      //
      // Let the database set this.  It is quicker and easier.
#if 0
      _variant_t vtGUID;
      if (!MTMiscUtil::CreateGuidAsVariant(vtGUID))
      {
        // throw appropriate error.
      }

      _bstr_t bstrGUID;
      if (!MTMiscUtil::GuidToString(vtGUID, bstrGUID)
      {
        // throw appropriate error.
      }

      insertStmtPtr->SetBinary(2, (const unsigned char*)((char*)bstrGUID), bstrGUID.length());
#endif

      // Set acc_state.  Required.
      tmpString = _bstr_t(inputParams.mAccountState);
      insertStmtPtr->SetString(3, tmpString);

      // Set acc_status_ext.  Optional.
      //
      // This was ignored in the original code.
#if 0
      if (inputParams.mAccountStateExt.vt != VT_NULL)
        insertStmtPtr->SetInteger(4, long(inputParams.mAccountStateExt));
#endif

      // Set acc_vtstart.  Optional.
      if (inputParams.mStateStart.vt == VT_DATE)
      {
        OLEDateToOdbcTimestamp(&(inputParams.mStateStart.date), &tmpODBCTimestamp);
        insertStmtPtr->SetDatetime(5, tmpODBCTimestamp);
      }

      // Set acc_vtend.  Optional.
      if (inputParams.mStateEnd.vt == VT_DATE)
      {
        OLEDateToOdbcTimestamp(&(inputParams.mStateEnd.date), &tmpODBCTimestamp);
        insertStmtPtr->SetDatetime(6, tmpODBCTimestamp);
      }

      // Set nm_login.  Required.
      tmpWideString = _bstr_t(inputParams.mlogin);
      insertStmtPtr->SetWideString(7, tmpWideString);

      // Set nm_space.  Required.
      tmpWideString = _bstr_t(inputParams.mNameSpace);
      insertStmtPtr->SetWideString(8, tmpWideString);

      // Set tx_password.  Required.
      string sEncodedStr;
      string passwordToBeHashed;

      tmpWideString = _bstr_t(inputParams.mPassword);
      WideStringToUTF8(tmpWideString.c_str(), passwordToBeHashed);

      // Remove dependency on MTMiscUtil
      if (inputParams.mAuthenticationType.llVal == METRANET_INTERNAL)
      {
        // FEAT-752 - Support active directory
        // Remove dependency on MetraTech_Security::PasswordManager
        MetraTech_Security::IAuthPtr auth;
        auth = new MetraTech_Security::IAuthPtr(__uuidof(MetraTech_Security::Auth));
        auth->Initialize(_bstr_t(inputParams.mlogin), _bstr_t(inputParams.mNameSpace));
        sEncodedStr = auth->HashNewPassword(_bstr_t(passwordToBeHashed.c_str()));

        tmpWideString = _bstr_t(sEncodedStr.c_str());
      }

      insertStmtPtr->SetWideString(9, tmpWideString);
      
      // Set langcode.  Required.
      tmpString = _bstr_t(inputParams.mLangCode);
      insertStmtPtr->SetString(10, tmpString);

      // Set profile_timezone.  Required.
      insertStmtPtr->SetInteger(11, long(inputParams.mtimezoneID));

      // Set id_cycle_type.  Optional.
       if (inputParams.mCycleType.vt != VT_NULL)
      {
        insertStmtPtr->SetInteger(12, long(inputParams.mCycleType));

        // Set day_of_month.  Some of day_of_month, day_of_week, first_day_of_month,
        // second_day_of_month, start_day, start_month and start_year are required.
        if (inputParams.mDayOfMonth.vt != VT_NULL)
           insertStmtPtr->SetInteger(13, long(inputParams.mDayOfMonth));

        // Set day_of_week.  Some of day_of_month, day_of_week, first_day_of_month,
        // second_day_of_month, start_day, start_month and start_year are required.
        if (inputParams.mDayOfWeek.vt != VT_NULL)
          insertStmtPtr->SetInteger(14, long(inputParams.mDayOfWeek));

        // Set first_day_of_month.  Some of day_of_month, day_of_week, first_day_of_month,
        // second_day_of_month, start_day, start_month and start_year are required.
        if (inputParams.mFirstDayOfMonth.vt != VT_NULL)
          insertStmtPtr->SetInteger(15, long(inputParams.mFirstDayOfMonth));

        // Set second_day_of_month.  Some of day_of_month, day_of_week, first_day_of_month,
        // second_day_of_month, start_day, start_month and start_year are required.
        if (inputParams.mSecondDayOfMonth.vt != VT_NULL)
          insertStmtPtr->SetInteger(16, long(inputParams.mSecondDayOfMonth));

        // Set start_day.  Some of day_of_month, day_of_week, first_day_of_month,
        // second_day_of_month, start_day, start_month and start_year are required.
        if (inputParams.mStartDay.vt != VT_NULL)
          insertStmtPtr->SetInteger(17, long(inputParams.mStartDay));

        // Set start_month.  Some of day_of_month, day_of_week, first_day_of_month,
        // second_day_of_month, start_day, start_month and start_year are required.
        if (inputParams.mStartMonth.vt != VT_NULL)
          insertStmtPtr->SetInteger(18, long(inputParams.mStartMonth));

        // Set start_year.  Some of day_of_month, day_of_week, first_day_of_month,
        // second_day_of_month, start_day, start_month and start_year are required.
        if (inputParams.mStartYear.vt != VT_NULL)
          insertStmtPtr->SetInteger(19, long(inputParams.mStartYear));
      }

      // Set billable.  Required.
      tmpString = _bstr_t(inputParams.mBillable);
      insertStmtPtr->SetString(20, tmpString);

      // Set id_payer.  Optional.
      if (inputParams.mPayerID.vt != VT_NULL)
        insertStmtPtr->SetInteger(21, long(inputParams.mPayerID));

      // Set payer_startdate.  Optional.
      if (inputParams.mPayerStartDate.vt == VT_DATE)
      {
        OLEDateToOdbcTimestamp(&(inputParams.mPayerStartDate.date), &tmpODBCTimestamp);
        insertStmtPtr->SetDatetime(22, tmpODBCTimestamp);
      }

      // Set payer_enddate.  Optional.
      if (inputParams.mPayerEndDate.vt == VT_DATE)
      {
        OLEDateToOdbcTimestamp(&(inputParams.mPayerEndDate.date), &tmpODBCTimestamp);
        insertStmtPtr->SetDatetime(23, tmpODBCTimestamp);
      }

      // Set payer_login.  Optional.
      if (inputParams.mPayerlogin.vt != VT_NULL)
      {
        tmpWideString = _bstr_t(inputParams.mPayerlogin);
        insertStmtPtr->SetWideString(24, tmpWideString);
      }

      // Set payer_namespace.  Optional.
      if (inputParams.mPayerNamespace.vt != VT_NULL)
      {
        tmpWideString = _bstr_t(inputParams.mPayerNamespace);
        insertStmtPtr->SetWideString(25, tmpWideString);
      }

      // Set id_ancestor.  Optional.
      if (inputParams.mAncestorID.vt != VT_NULL)
        insertStmtPtr->SetInteger(26, long(inputParams.mAncestorID));

      // Set hierarchy_start.  Optional.
      if (inputParams.mHierarchyStart.vt == VT_DATE)
      {
        OLEDateToOdbcTimestamp(&(inputParams.mHierarchyStart.date), &tmpODBCTimestamp);
        insertStmtPtr->SetDatetime(27, tmpODBCTimestamp);
      }

      // Set hierarchy_end.  Optional.
      if (inputParams.mHierarchyEnd.vt == VT_DATE)
      {
        OLEDateToOdbcTimestamp(&(inputParams.mHierarchyEnd.date), &tmpODBCTimestamp);
        insertStmtPtr->SetDatetime(28, tmpODBCTimestamp);
      }

      // Set ancestor_name.  Optional.
      if (inputParams.mAncestorLogon.vt != VT_NULL)
      {
        tmpWideString = _bstr_t(inputParams.mAncestorLogon);
        insertStmtPtr->SetWideString(29, tmpWideString);
      }

      // Set ancestor_namespace.  Optional.
      if (inputParams.mAncestorNamespace.vt != VT_NULL)
      {
        tmpWideString = _bstr_t(inputParams.mAncestorNamespace);
        insertStmtPtr->SetWideString(30, tmpWideString);
      }

      // Set acc_type.  Required.
      tmpString = inputParams.mAccountType;
      insertStmtPtr->SetString(31, tmpString);

      // Set apply_default_policy.  Required.
      tmpString = inputParams.mApplyDefaultSecurityPolicy ? "T" : "F";
      insertStmtPtr->SetString(32, tmpString);

      // Set account_currency.  Optional for account that are never payers.
      if (inputParams.mCurrency.vt != VT_NULL)
      {
        tmpWideString = _bstr_t(inputParams.mCurrency);
        insertStmtPtr->SetWideString(33, tmpWideString);
      }

      // Set id_profile.  Required.
      insertStmtPtr->SetInteger(34, idProfileGenerator->NextId);

      // set login_app. Optional.
      if (inputParams.mLoginApp.vt!= VT_NULL)
      {
        tmpString = _bstr_t(inputParams.mLoginApp);
        insertStmtPtr->SetString(35, tmpString);
      }
      // Set id_acc.  Required.
      insertStmtPtr->SetInteger(46, idAccGenerator->NextMashedId);

	  insertStmtPtr->AddBatch();
    }
    catch (_com_error & err)
    {
      _bstr_t message = err.Description();
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
      curSession->MarkAsFailed(message.length() > 0 ? message : L"", err.Error());
      mbSessionsFailed = true;
    }
    catch(...)
    {
      insertStmtPtr->ExecuteBatch();
      throw;
    }
  }

  if (mOkToLogPerfInfo)
  {
    LARGE_INTEGER tock;

    ::QueryPerformanceCounter(&tock);
    mBatchInsertSetupTicks += (tock.QuadPart - tick.QuadPart);

    ::QueryPerformanceCounter(&tick);
  }

  // Insert the records into the temp table.
  insertStmtPtr->ExecuteBatch();

  if (mOkToLogPerfInfo)
  {
    LARGE_INTEGER tock;

    ::QueryPerformanceCounter(&tock);
    mBatchInsertExecutionTicks += (tock.QuadPart - tick.QuadPart);
  }

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// Add
/////////////////////////////////////////////////////////////////////////////
HRESULT 
BatchAccountTableCreationPlugIn::Add(MTPipelineLib::IMTSessionPtr& sessionPtr,
                                     CoreAccountCreationParams& params)
{
  const char* procName = "BatchAccountTableCreationPlugIn::Add";

  HRESULT hr = S_OK;

  MTPipelineLib::IMTSecurityContextPtr secCtx = sessionPtr->GetSessionContext()->GetSecurityContext();

  try
  {
    //read in the account type specific properties into the params structure.
    params.mCanBePayer = (sessionPtr->GetBoolProperty(mCanBePayerID) == VARIANT_TRUE);
    params.mCanSubscribe = (sessionPtr->GetBoolProperty(mCanSubscribeID) == VARIANT_TRUE);
    params.mCanHaveSyntheticRoot = (sessionPtr->GetBoolProperty(mCanHaveSyntheticRootID) == VARIANT_TRUE);
    params.mCanParticipateInGSub = (sessionPtr->GetBoolProperty(mCanParticipateInGSubID) == VARIANT_TRUE);
    params.mCanHaveTemplates = (sessionPtr->GetBoolProperty(mCanHaveTemplatesID) == VARIANT_TRUE);
    params.mIsCorporate = (sessionPtr->GetBoolProperty(mIsCorporateID) == VARIANT_TRUE);
    params.mIsVisibleInHierarchy = (sessionPtr->GetBoolProperty(mIsVisibleInHierarchyID) == VARIANT_TRUE);

    
    //check for required properties when adding an account, if not there, throw appropriate error.
    //note that the usual way of doing this is by marking the properties as required on the
    //service def and letting the listener check this.  Accountcreation is special as the servicedef
    //is shared between create and update and depending on the type of account you are creating or the
    //operation, some properties may be required under certain condtions and not others.

    //username
    if (sessionPtr->PropertyExists(mUserName, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
    {
      string strError = "Missing required property, username";
      MT_THROW_COM_ERROR(strError.c_str());
    }
    else
      params.mlogin = sessionPtr->GetStringProperty(mUserName);

    // name_space
    if (sessionPtr->PropertyExists(mName_Space, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
    {
      string strError = "Missing required property, name_space";
      MT_THROW_COM_ERROR(strError.c_str());
    }
    else
      params.mNameSpace = sessionPtr->GetStringProperty(mName_Space);

    // password
    if (sessionPtr->PropertyExists(mPassword, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
    {
      string strError = "Missing required property, password";
      MT_THROW_COM_ERROR(strError.c_str());
    }
    else
    {
      if (mbEncryptedPassword)
        params.mPassword = sessionPtr->DecryptEncryptedProp(mPassword);
      else
        params.mPassword = sessionPtr->GetStringProperty(mPassword);
    }
    //-----
    // Make sure the set does not violate the primary key constraint
    // which is composed of login and namespace values.
    // The query checks the constraint against the database, but not
    // if the duplicate entry is in the batch. Let's add the keys to a lookup
    // map to check if we pass the constaraint.
    //-----
    wstring wstrPrimaryKey = _bstr_t(params.mlogin) + L"_" + _bstr_t(params.mNameSpace);

    // Convert to upper case.
    std::transform(wstrPrimaryKey.begin(), wstrPrimaryKey.end(), wstrPrimaryKey.begin(), towupper);

    // Check key constraint.
    PrimaryKeyMap::iterator it = mPrimaryKeyMap.find(wstrPrimaryKey);
    if (it == mPrimaryKeyMap.end())
      // Not found, insert into map.
      mPrimaryKeyMap[wstrPrimaryKey] = true;
    else
    {
      // Duplicate key found in session set.
      string strErrorText = "Duplicate accounts found in the session set, login=" + _bstr_t(params.mlogin);
      strErrorText += ", namespace=" + _bstr_t(params.mNameSpace);

      MT_THROW_COM_ERROR(strErrorText.c_str());
    }

    if (sessionPtr->PropertyExists(mCurrency, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
        params.mCurrency = sessionPtr->GetStringProperty(mCurrency);
   
    // however, currency is required if an account is ever going to be a payer.
    if (params.mCanBePayer &&
        (sessionPtr->PropertyExists(mCurrency, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE))
    {
      string strCurrencyError = "Missing required property, currency for account with login=" + _bstr_t(params.mlogin);
      MT_THROW_COM_ERROR(strCurrencyError.c_str());
    }
  
    // initialize account state
    GetAccountStateInfo(params, sessionPtr, secCtx);

    // accounttype
    if (sessionPtr->PropertyExists(mAccountType, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
    {
      string strError = "Missing required property, AccountType";
      MT_THROW_COM_ERROR(strError.c_str());
    }
    else
      params.mAccountType = sessionPtr->GetStringProperty(mAccountType);


    if (sessionPtr->PropertyExists(mApplyDSP, MTPipelineLib::SESS_PROP_TYPE_BOOL))
      params.mApplyDefaultSecurityPolicy = (sessionPtr->GetBoolProperty(mApplyDSP) == VARIANT_TRUE ? true : false);

    // start and endates for the account
    //
    // don't specify the account creation start and end date right now

    // language
    _bstr_t language;

    language = mEnumConfig->GetEnumeratorByID(sessionPtr->GetEnumProperty(mLanguage));
    if (language.length() == 0)
      MT_THROW_COM_ERROR(MT_NO_LANGUAGE_SPECIFIED);
    else
      params.mLangCode = language;

    // timezone ID
    if (sessionPtr->PropertyExists(mTimezoneID, MTPipelineLib::SESS_PROP_TYPE_ENUM) == VARIANT_FALSE)
    {
      string strError = "Missing required property, TimezoneID";
      MT_THROW_COM_ERROR(strError.c_str());
    }
    else
      params.mtimezoneID = atol(mEnumConfig->GetEnumeratorValueByID(sessionPtr->GetEnumProperty(mTimezoneID)));

    GetUsageCycleInfo(params, sessionPtr, secCtx);
    GetPaymentInfo(params, sessionPtr, secCtx);
    GetAncestorInfo(params, sessionPtr, secCtx);

    //login application - only valid for system accounts.
    if (_wcsicmp((wchar_t*)params.mAccountType, L"SystemAccount") == 0)
    {
      if (sessionPtr->PropertyExists(mLoginApplicationID, MTPipelineLib::SESS_PROP_TYPE_ENUM) == VARIANT_TRUE)
      {
        _bstr_t loginApplication;
        loginApplication = mEnumConfig->GetEnumeratorByID(sessionPtr->GetEnumProperty(mLoginApplicationID));
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

    if (wcscmp(params.mAccountType,ACCOUNT_TYPE_SYSTEM) != 0)
    { 
      if (params.mIsCorporate)
        secCtx->CheckAccess(mCreateCorporateAccountCapability);
      else
        secCtx->CheckAccess(mCreateSubscriberCapability);
    }
    else 
      secCtx->CheckAccess(mCreateCSRCapability);
    
    //else if (wcscmp(params.mAccountType, ACCOUNT_TYPE_IND) == 0)
      //secCtx->CheckAccess(mManageIndepAccCapability);

    CheckAccountMapperBusinessRules(params);

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

    CheckPaymentAuth(params, secCtx);
  }
  catch(_com_error& err)
  {
    if (err.Error() == MTAUTH_ACCESS_DENIED)
    {
      AuditAuthFailures(err,
                        mDeniedAuditEvent,
                        secCtx->AccountID, 
                        AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
                        -1);
    }

 	  char buffer[1024];
		sprintf(buffer, "An exception was thrown in Add: %x, %s", 
						err.Error(), (const char*) _bstr_t(err.Description()));

    _bstr_t message(buffer);
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
    sessionPtr->MarkAsFailed(message.length() > 0 ? message : L"", err.Error());
    mbSessionsFailed = true;
    return PIPE_ERR_SUBSET_OF_BATCH_FAILED;
  }

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// CheckManageAH
/////////////////////////////////////////////////////////////////////////////
void
BatchAccountTableCreationPlugIn::CheckManageAH(_bstr_t& aPath,
                                               MTPipelineLib::IMTSecurityContextPtr& aSecCtxPtr)
{
  MTAUTHLib::IMTPathCapabilityPtr pathPtr = mManageAHCapability->GetAtomicPathCapability();
  pathPtr->SetParameter(aPath,MTAUTHLib::SINGLE);
  aSecCtxPtr->CheckAccess(mManageAHCapability);
}

/////////////////////////////////////////////////////////////////////////////
// CheckAccountMapperBusinessRules
/////////////////////////////////////////////////////////////////////////////
void
BatchAccountTableCreationPlugIn::CheckAccountMapperBusinessRules(CoreAccountCreationParams& aParams)
{
  // Check for password and username to be not more than 40 characters.

  if (_bstr_t(aParams.mlogin).length() > 40)
    MT_THROW_COM_ERROR("Username greater than 40 characters -- Please restrict to 40 or less.");

  long passwordLen = _bstr_t(aParams.mPassword).length();

  //if (passwordLen > 40)
  //  MT_THROW_COM_ERROR("Password greater than 40 characters -- Please restrict to 40 or less.");

  if (passwordLen == 0)
    MT_THROW_COM_ERROR("Blank Password");

  if (_bstr_t(aParams.mNameSpace).length() == 0)
    MT_THROW_COM_ERROR("Blank namespace");

  if (_bstr_t(aParams.mNameSpace).length() > 40)
	MT_THROW_COM_ERROR("Namespace greater than 40 characters -- Please restrict to 40 or less.");
}

/////////////////////////////////////////////////////////////////////////////
//GetUsageCycleInfo
/////////////////////////////////////////////////////////////////////////////

void
BatchAccountTableCreationPlugIn::GetUsageCycleInfo(CoreAccountCreationParams& aParams,
                                                   MTPipelineLib::IMTSessionPtr& aSessionPtr,
                                                   MTPipelineLib::IMTSecurityContextPtr aSecCtxPtr)
{
  
  if (aParams.mCanBePayer)
  {
    if (aSessionPtr->PropertyExists(mUsageCycleType, MTPipelineLib::SESS_PROP_TYPE_ENUM))
    {
      _variant_t empty;
      empty.vt = VT_NULL;

      _bstr_t aUCT = mEnumConfig->GetEnumeratorValueByID(aSessionPtr->GetEnumProperty(mUsageCycleType));
      aParams.mCycleType = atol(aUCT);

      switch(long(aParams.mCycleType))
      {
        case 1: // Monthly
          aParams.mDayOfMonth = aSessionPtr->GetLongProperty(mDayOfMonth);
          break;

        case 2: // On-Demand
          MT_THROW_COM_ERROR("On demand not supported");
          break;

        case 3: // Daily
          break;

        case 4: // Weekly
          {
            _bstr_t bstrDayOfWeek = mEnumConfig->GetEnumeratorValueByID(aSessionPtr->GetEnumProperty(mDayOfWeek));
            aParams.mDayOfWeek = atol(bstrDayOfWeek);

            if ((long(aParams.mDayOfWeek) < 1)
            || (long(aParams.mDayOfWeek) > 7))
              MT_THROW_COM_ERROR("The day of week is out of range. weekday = %d", long(aParams.mDayOfWeek));
          }
          break;

        case 5: // Bi-Weekly
          {
            aParams.mStartDay = aSessionPtr->GetLongProperty(mStartDay);
            _bstr_t bstrStartMonth = mEnumConfig->GetEnumeratorValueByID(aSessionPtr->GetEnumProperty(mStartMonth));
            aParams.mStartMonth = atol(bstrStartMonth);
            aParams.mStartYear = aSessionPtr->GetLongProperty(mStartYear);

            // Validate the day, month, and year.
            if ((long(aParams.mStartMonth) < 1)
            || (long(aParams.mStartMonth) > 12)
            || (long(aParams.mStartYear) < 1970)
            || (long(aParams.mStartYear) > 2037)
            || (long(aParams.mStartDay) < 1)
            || (long(aParams.mStartDay) > MTDate::GetDaysInMonth(long(aParams.mStartMonth),
                                                                  long(aParams.mStartYear))))
            {
              MT_THROW_COM_ERROR("The month, day, or year property is invalid. Month = %d, Day = %d, Year = %d",
                                                                              long(aParams.mStartMonth),
                                                                              long(aParams.mStartDay),
                                                                              long(aParams.mStartYear));
            }
          }
          break;

        case 6: // Semi-Montly
          aParams.mFirstDayOfMonth = aSessionPtr->GetLongProperty(mFirstDayOfMonth);
          aParams.mSecondDayOfMonth = aSessionPtr->GetLongProperty(mSecondDayOfMonth);
          if (long(aParams.mFirstDayOfMonth) >= long(aParams.mSecondDayOfMonth))
          {
            MT_THROW_COM_ERROR("The first day must be less than the second day.  first day = %d, second day = %d",
                                                                        long(aParams.mFirstDayOfMonth),
                                                                        long(aParams.mSecondDayOfMonth));
          }
          break;

        case 7: // Quarterly
          {
            aParams.mStartDay = aSessionPtr->GetLongProperty(mStartDay);
            _bstr_t bstrStartMonth = mEnumConfig->GetEnumeratorValueByID(aSessionPtr->GetEnumProperty(mStartMonth));
            aParams.mStartMonth = atol(bstrStartMonth);
            
            if (long(aParams.mStartDay) < 1)
            {
              MT_THROW_COM_ERROR("The start day property is not in the range of [1 - 31]. StartDay = %d",
                                                                                (long)aParams.mStartDay);
            }

            if ((long(aParams.mStartMonth) < 1)
            || (long(aParams.mStartMonth) > 12))
            {
              MT_THROW_COM_ERROR("The start month property is not in the range of [1 - 12]. StartMonth = %d",
                                                                              (long)aParams.mStartMonth);
            }

            // Normalize the start month to be a value between 1 and 3.
            aParams.mStartMonth = long(aParams.mStartMonth) % 3;
            if (long(aParams.mStartMonth) == 0) 
            {
              aParams.mStartMonth = 3;
            }
          }
          break;

        case 8: // Anually
        case 9: // Semiannually
          {
            aParams.mStartDay = aSessionPtr->GetLongProperty(mStartDay);
            _bstr_t bstrStartMonth = mEnumConfig->GetEnumeratorValueByID(aSessionPtr->GetEnumProperty(mStartMonth));
            aParams.mStartMonth = atol(bstrStartMonth);

            // Validate the first day and second day.

            if ((long(aParams.mStartMonth)  < 1)
            || (long(aParams.mStartMonth)  > 12)
            || (long(aParams.mStartDay) < 1)
                                            // We don't care about leap year so a fixed year is ok.
            || (long(aParams.mStartDay) > MTDate::GetDaysInMonth((long)aParams.mStartMonth, 1999))) 
            {
              MT_THROW_COM_ERROR("The month or day property is invalid. Month = %d, Day = %d",
                                                                      long(aParams.mStartMonth),
                                                                      long(aParams.mStartDay));
            }
          }
          break;

        default:
          MT_THROW_COM_ERROR("Unknown usage cycle type");
          break;
      }

      return;
    }
    MT_THROW_COM_ERROR(MT_USAGE_CYCLE_INFO_REQUIRED);
  }
  
  else
  {
     if (aSessionPtr->PropertyExists(mUsageCycleType, MTPipelineLib::SESS_PROP_TYPE_ENUM))
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, "Account being metered cannot be a payer, UsageCycleID will be ignored");
  }
}

/////////////////////////////////////////////////////////////////////////////
// GetPaymentInfo
/////////////////////////////////////////////////////////////////////////////
void
BatchAccountTableCreationPlugIn::GetPaymentInfo(CoreAccountCreationParams& aParams,
                                                MTPipelineLib::IMTSessionPtr& aSessionPtr,
                                                MTPipelineLib::IMTSecurityContextPtr aSecCtxPtr)
{
  // The billable flag value is useful and required only if the account can ever be a payer.
  // If the account can never be a payer, this flag will always be false.

  if (aParams.mCanBePayer)
  {
    aParams.mBillable = (aSessionPtr->GetBoolProperty(mBillable) == VARIANT_TRUE) ? "Y" : "N";
  }
  else
  {
    //gsm account
    aParams.mBillable = "N";
    aSessionPtr->SetBoolProperty(mBillable, VARIANT_FALSE);
  }

  GeneratePaymentRecord(aParams, aSessionPtr, aSecCtxPtr);

  //Check for missing payer..
  //make sure that for an account that can never be a payer, a valid payer is specified
  //make sure that for an account that can be a payer and that is not billable, a valid payer is specified
  //commenting out the checks.. the queries do this very nicely in batch.
 /* if (!aParams.mCanHaveSyntheticRoot)
  {
    if (!aParams.mCanBePayer)
    {
      if( (aParams.mPayerID.vt == VT_NULL) &&
          ((aParams.mPayerlogin.vt == VT_NULL) || (aParams.mPayerNamespace.vt == VT_NULL)))
          MT_THROW_COM_ERROR(MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER);
    }
    if (aParams.mCanBePayer && (wcscmp(_bstr_t(aParams.mBillable),_bstr_t("N")) == 0))
    {
      if( (aParams.mPayerID.vt == VT_NULL) &&
          ((aParams.mPayerlogin.vt == VT_NULL) || (aParams.mPayerNamespace.vt == VT_NULL)))
          MT_THROW_COM_ERROR(MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER);
    }
  }*/
  
}

void BatchAccountTableCreationPlugIn::GeneratePaymentRecord(CoreAccountCreationParams& aParams,
                                                MTPipelineLib::IMTSessionPtr& aSessionPtr,
                                                MTPipelineLib::IMTSecurityContextPtr aSecCtxPtr)
{
 if (aSessionPtr->PropertyExists(mPayerAccountID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)
  {
      aParams.mPayerID = aSessionPtr->GetLongProperty(mPayerAccountID);
      aParams.mPaymentMap |= PAYMENTMAP_ACCOUNTVAL;
  }

  if (aParams.mPayerID.vt == VT_NULL)
  {
    if (aSessionPtr->PropertyExists(mPayerLoginName, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
    {
      aParams.mPayerlogin = aSessionPtr->GetStringProperty(mPayerLoginName);
      aParams.mPaymentMap |= PAYMENTMAP_LOGINNAME;
    }

    if (aSessionPtr->PropertyExists(mPayerNamespace, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
    {
      aParams.mPayerNamespace = aSessionPtr->GetStringProperty(mPayerNamespace);
      aParams.mPaymentMap |= PAYMENTMAP_NS;
    }
  }

  if (aSessionPtr->PropertyExists(mPayerStart, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE)
  {
    aParams.mPayerStartDate = aSessionPtr->GetOLEDateProperty(mPayerStart);
    aParams.mPayerStartDate.vt = VT_DATE;
    aParams.mPaymentMap |= PAYMENTMAP_STARTDATE;
  }

  if (aSessionPtr->PropertyExists(mPayerEnd, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE)
  {
    aParams.mPayerEndDate = aSessionPtr->GetOLEDateProperty(mPayerEnd);
    aParams.mPayerEndDate.vt = VT_DATE;
    aParams.mPaymentMap |= PAYMENTMAP_ENDDATE;
  }

  if ( (aParams.mPayerID.vt == VT_NULL) &&
          ((aParams.mPayerlogin.vt == VT_NULL) || (aParams.mPayerNamespace.vt == VT_NULL)) &&
          (aParams.mCanHaveSyntheticRoot))
  {
    //ok, payer is not specified, but the account can have synthetic root.. make the payer the synthetic
    //root, i.e -1
    aParams.mPayerID = -1;
    aParams.mPaymentMap |= PAYMENTMAP_ACCOUNTVAL;
  }
}
 

/////////////////////////////////////////////////////////////////////////////
// CheckPaymentAuth
/////////////////////////////////////////////////////////////////////////////
void
BatchAccountTableCreationPlugIn::CheckPaymentAuth(CoreAccountCreationParams& aParams,
                                                  MTPipelineLib::IMTSecurityContextPtr& aSecCtxPtr)
{
    // If we are creating someone who can pay for other accounts, check the capability.
    if (_bstr_t(aParams.mBillable) == _bstr_t("Y"))
        aSecCtxPtr->CheckAccess(mBillableCapability); 

    // If the payer ID OR the payerlogin name AND namespace are specified, then check the payment capability.
    if ((aParams.mPaymentMap & PAYMENTMAP_ACCOUNTVAL)
     || (aParams.mPaymentMap & (PAYMENTMAP_LOGINNAME|PAYMENTMAP_NS)))
    {
      aSecCtxPtr->CheckAccess(mPaymentCapability);
    }
}

/////////////////////////////////////////////////////////////////////////////
// GetAncestorInfo
/////////////////////////////////////////////////////////////////////////////
void
BatchAccountTableCreationPlugIn::GetAncestorInfo(CoreAccountCreationParams& aParams,
                                                 MTPipelineLib::IMTSessionPtr& aSessionPtr,
                                                 MTPipelineLib::IMTSecurityContextPtr& aSecCtxPtr)
{
  if (aSessionPtr->PropertyExists(mAncestorID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)
  {
      aParams.mAncestorID = aSessionPtr->GetLongProperty(mAncestorID);
      aParams.mAncestorMap |= ANCESTORMAP_ANCESTOR;
  }

  if (aParams.mAncestorID.vt == VT_NULL)
  {
    if (aSessionPtr->PropertyExists(mAncestorlogin, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
    {
      aParams.mAncestorLogon = aSessionPtr->GetStringProperty(mAncestorlogin);
      aParams.mAncestorMap |= ANCESTORMAP_LOGINNAME;
    }

    if (aSessionPtr->PropertyExists(mAncestorNameSpace, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
    {
      aParams.mAncestorNamespace = aSessionPtr->GetStringProperty(mAncestorNameSpace);
        aParams.mAncestorMap |= ANCESTORMAP_NS;
    }
    if (((aParams.mAncestorLogon.vt == VT_NULL) && (aParams.mAncestorNamespace.vt != VT_NULL))
        ||
        ((aParams.mAncestorLogon.vt != VT_NULL) && (aParams.mAncestorNamespace.vt == VT_NULL)))
    {
       MT_THROW_COM_ERROR("Incomplete ancestor information provided, either ancestor login or namespace is missing.");
    }
  }

  // if neither the ancestor id nor the [login,namespace] is specified then set the id to be 1 or -1
  if ((aSessionPtr->PropertyExists(mAncestorID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_FALSE) &&
      ((aSessionPtr->PropertyExists(mAncestorlogin, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE) &&
       (aSessionPtr->PropertyExists(mAncestorNameSpace, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE))
       )
  {
    if (aParams.mCanHaveSyntheticRoot == true)
    {
      aParams.mAncestorID = -1; //synthetic root
      aParams.mAncestorMap |= ANCESTORMAP_ANCESTOR;
    }
    else
    {
      aParams.mAncestorID = 1; //root
      aParams.mAncestorMap |= ANCESTORMAP_ANCESTOR;
    }
  }

  if (aSessionPtr->PropertyExists(mAncestorStart, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE)
  {
    aParams.mHierarchyStart = aSessionPtr->GetOLEDateProperty(mAncestorStart);
    aParams.mHierarchyStart.vt = VT_DATE;
    aParams.mAncestorMap |= ANCESTORMAP_STARTDATE;
  }
  if (aSessionPtr->PropertyExists(mAncestorEnd, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE)
  {
    aParams.mHierarchyEnd = aSessionPtr->GetOLEDateProperty(mAncestorEnd);
    aParams.mHierarchyEnd.vt = VT_DATE;
    aParams.mAncestorMap |= ANCESTORMAP_ENDDATE;
  }

}

/////////////////////////////////////////////////////////////////////////////
// GetAccountStateInfo
/////////////////////////////////////////////////////////////////////////////
void
BatchAccountTableCreationPlugIn::GetAccountStateInfo(CoreAccountCreationParams& aParams,
                                                     MTPipelineLib::IMTSessionPtr& aSessionPtr,
                                                     MTPipelineLib::IMTSecurityContextPtr& aSecCtxPtr)
{
  if (aSessionPtr->PropertyExists(mAccountStatus, MTPipelineLib::SESS_PROP_TYPE_ENUM) == VARIANT_TRUE)
  {
    long lAccountStatus = aSessionPtr->GetEnumProperty(mAccountStatus);
    aParams.mAccountState = _variant_t(mEnumConfig->GetEnumeratorValueByID(lAccountStatus));
    aParams.mAccountStateMap |= STATEMAP_TYPE;
  }
  else
  {
    string strError = "Missing required property, AccountStatus";
    MT_THROW_COM_ERROR(strError.c_str());
  }

  if (aSessionPtr->PropertyExists(mAccountStartDate, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE)
  {
    aParams.mStateStart = aSessionPtr->GetOLEDateProperty(mAccountStartDate);
    aParams.mStateStart.vt = VT_DATE;
    aParams.mAccountStateMap |= STATEMAP_STARTDATE;
  }

  if (aSessionPtr->PropertyExists(mAccountEndDate, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE)
  {
    aParams.mStateEnd = aSessionPtr->GetOLEDateProperty(mAccountEndDate);
    aParams.mStateEnd.vt = VT_DATE;
    aParams.mAccountStateMap |= STATEMAP_ENDDATE;
  }
}

/////////////////////////////////////////////////////////////////////////////
// NormalizePropertiesOnAccountType
/////////////////////////////////////////////////////////////////////////////
//voiid
//BatchAccountTableCreationPlugIn::NormalizePropertiesOnAccountType(CoreAccountCreationParams&   aParams,
//MTPipelineLib::IMTSessionPtr& aSessionPtr,
//bool bFolder)
//{
  // SFH: If its a CSR, return, right away.  No normalization required.

  //check to see if canbeparent is true.. if this account cannot be a parent
  // then folder should be false, ancestor info should be nulled out.

 /* if (!aParams.mCanBeParent)
  {
    aSessionPtr->SetBoolProperty(mIsFolder, VARIANT_FALSE);
	
   _variant_t vtEmpty;
    vtEmpty.vt = VT_NULL;

    aParams.mHierarchyStart.vt = VT_NULL;
    aParams.mHierarchyEnd.vt = VT_NULL;
    aParams.mAncestorLogon = vtEmpty;
    aParams.mAncestorNamespace = vtEmpty;
    aParams.mAncestorID.vt = VT_NULL;
    aParams.mPayerID.vt = VT_NULL;
    aParams.mPayerlogin = vtEmpty;
    aParams.mPayerNamespace = vtEmpty;
    aParams.mPayerStartDate.vt = VT_NULL;
    aParams.mPayerEndDate.vt = VT_NULL;
  }*/
//}

// TODO: All of the queries in this routine need to be parameterized
//       and moved into R:\config\Queries\AccountCreation\CommonQueries.xml.
HRESULT BatchAccountTableCreationPlugIn::GenerateQueries(const char* stagingDBName)
{
  char buf[1024];
  MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));

  if (IsOracle())
  {
	  // Build the name of our global temporary table.
	  sprintf(buf, "tmp_argcreateacct_%d", mTmpTableNum);
	  mTmpTableName = nameHash->GetDBNameHash((buf + mTagName).c_str());
	  string schemaDots = mQueryAdapter->GetSchemaDots();
	  mTmpTableFullName = stagingDBName + schemaDots + mTmpTableName.c_str();

	  sprintf(buf, "idx_argcreateacct_%d", mTmpTableNum);
	  mTmpTableIdxName = nameHash->GetDBNameHash((buf + mTagName).c_str());
	  mTmpTableNum++;
  }
  else
  {
    // Build the name of our "temporary" table.
    char buf[1024];
    sprintf(buf, "#tmp_create_account_%d", mTmpTableNum);
    mTmpTableName = buf;

    mTmpTableFullName = mTmpTableName;
    sprintf(buf, "idx_tmp_create_account_%d", mTmpTableNum);
    mTmpTableIdxName = buf;
    mTmpTableNum++;
  }

  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__CREATE_BATCH_ACCOUNT_TEMP_TABLE__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTableName.c_str());
  mQueryAdapter->AddParam("%%TMP_TABLE_IDX_NAME%%", mTmpTableIdxName.c_str());
  mTmpTableCreateSQL = mQueryAdapter->GetQuery();

  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__INSERT_INTO_BATCH_ACCOUNT_TEMP_TABLE__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTableName.c_str());
  mTmpTableInsertSQL = mQueryAdapter->GetQuery();

  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__TRUNCATE_TEMP_TABLE__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTableName.c_str());
  mTmpTableTruncateSQL = mQueryAdapter->GetQuery();

  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__GET_RESULTS_FROM_BATCH_ACCOUNT_TEMP_TABLE__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTableName.c_str());
  mTmpTableGetResultsSQL = mQueryAdapter->GetQuery();

  mTmpTableDropSQL.clear();
  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__DROP_TEMP_TABLE__");
  if (!IsOracle())
  {
	mQueryAdapter->AddParam("%%TABLE_NAME%%", mTmpTableName.c_str());
	mTmpTableDropSQL.push_back((char *)(mQueryAdapter->GetQuery()));
  }
  else
  {
	  /* build a vector for drop temp table queries */
	for (int i = mTmpTableNum-2; i>mTmpTableNum-6; i--)
	{
		mQueryAdapter->ClearQuery();
		mQueryAdapter->SetQueryTag("__DROP_TEMP_TABLE__");
		if (i >= 0)
		{
			sprintf(buf, "tmp_argcreateacct_%d", i);
			mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", nameHash->GetDBNameHash((buf + mTagName).c_str()));
		    mTmpTableDropSQL.push_back((char *)(mQueryAdapter->GetQuery()));
		}
	}
  }

  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__EXECUTE_BATCH_ACCOUNT_TABLE_CREATION__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTableName.c_str());
  mQueryAdapter->AddParam("%%ENFORCE_SAME_CORPORATION%%", mbEnforceSameCorp ? "1" : "0");
  mTmpTableExecuteSQL = mQueryAdapter->GetQuery();
  return S_OK;
}

//-- EOF --
