/**************************************************************************
* Copyright 2002 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* 
***************************************************************************/

#include <metra.h>
#include <CoreAccountCreation.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <mttime.h>
#include <MTDate.h>
#include <DataAccessDefs.h>
#include <MTUtil.h>
#include <OdbcConnMan.h>
#include <OdbcConnection.h>

using namespace RowSetInterfacesLib;

//
#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )
#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.tlb> inject_statement("using namespace mscorlib;")

// Constructor.
MTCoreAccountMgr::MTCoreAccountMgr(CoreAccountCreationParams& params)
  :   mParams(params),
      mbCreatedInsertDelta(false),
      mbCreatedDeleteDelta(false),
      mBaseTableName("t_dm_account")
{
    // Initialize materialized view manager.
    mpMvMgr = new MetraTech_DataAccess_MaterializedViews::IManagerPtr(__uuidof(MetraTech_DataAccess_MaterializedViews::Manager));
    mpMvMgr->Initialize();

    // Cache this result so that we don't need to do a COM interop each time.
    mIsMVSupportEnabled = (mpMvMgr->GetIsMetraViewSupportEnabled() == VARIANT_TRUE);

    // Create an instance of the stage table binding.
    if (mIsMVSupportEnabled)
    {
      // Get transactional delta table names.
      mInsertDeltaTableName = mpMvMgr->GenerateDeltaInsertTableName(mBaseTableName.c_str());
      mDeleteDeltaTableName = mpMvMgr->GenerateDeltaDeleteTableName(mBaseTableName.c_str());

      // Enable caching support.
      mpMvMgr->EnableCache(VARIANT_TRUE);

      // Prepare the base table bindings.
      mpMvMgr->AddInsertBinding(mBaseTableName.c_str(), mInsertDeltaTableName.c_str());
      mpMvMgr->AddDeleteBinding(mBaseTableName.c_str(), mDeleteDeltaTableName.c_str());
    }
}

// Update materialized views.
HRESULT MTCoreAccountMgr::UpdateMaterializedViews(RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset, long AccountID, bool bInsertMode)
{
    HRESULT hr = S_OK;
    SAFEARRAY* pSA = NULL;
    bool bSALocked = false;
    try
    {
      aRowset->ClearQuery();
      aRowset->UpdateConfigPath("queries\\AccountCreation");
      aRowset->SetQueryTag("__CREATE_ACCOUNT_DELTA_TABLE__");
      aRowset->AddParam("%%TABLE_NAME%%", mInsertDeltaTableName.c_str());
      aRowset->Execute();

      // Prepare the delta insert table for materialized view update.
      aRowset->ClearQuery();
      if (bInsertMode)
        aRowset->SetQueryTag("__INSERT_INTO_ACCOUNT_DELTA_TABLE__");
      else
        aRowset->SetQueryTag("__UPDATE_ACCOUNT_DELTA_TABLE__");
      aRowset->AddParam("%%TABLE_NAME%%", mBaseTableName.c_str());
      aRowset->AddParam("%%DELTA_TABLE_NAME%%", mInsertDeltaTableName.c_str());
      aRowset->AddParam("%%ID_ACC_LIST%%", AccountID);
      aRowset->Execute();
      mbCreatedInsertDelta = true;

      // Execute the matrerialized wiew update.
      // Create safe array of product view tables that were metered.
      SAFEARRAYBOUND sabound[1];
      sabound[0].lLbound = 0;
      sabound[0].cElements = 1;
      pSA = SafeArrayCreate(VT_BSTR, 1, sabound);
      if (pSA == NULL)
        MT_THROW_COM_ERROR(L"Unable to create safe arrary for materialized view update trigger list.");

      // Set data to the contents of the safe array.
      BSTR HUGEP *pbstrNames;
      if (!::SafeArrayAccessData(pSA, (void**)&pbstrNames))
      {
        // Set to true incase exception is thrown before we release.
        bSALocked = true;

        // All account moves affect our base table.
        _bstr_t _bstrName(mBaseTableName.c_str());
        pbstrNames[0] = ::SysAllocString(_bstrName);
        ::SafeArrayUnaccessData(pSA);
        bSALocked = false;
      }
      else
          MT_THROW_COM_ERROR(L"Unable to access safe array trigger data.");

      // Get the update query to execute for all materialized views that changed.
      _bstr_t _bstrQueriesToExecute;
      if (bInsertMode)
        _bstrQueriesToExecute = mpMvMgr->GetMaterializedViewInsertQuery(pSA);
      else
        _bstrQueriesToExecute = mpMvMgr->GetMaterializedViewUpdateQuery(pSA);

      // Free safe array.
      ::SafeArrayDestroy(pSA);
      pSA = NULL;

      // Execute the queries.
      if (!!_bstrQueriesToExecute)
      {
        aRowset->ClearQuery();
        HRESULT hr = aRowset->SetQueryString(_bstrQueriesToExecute);
        if (SUCCEEDED(hr))
          aRowset->Execute();
      }

      // Trunctate transactinal data tables.
      aRowset->ClearQuery();
      aRowset->SetQueryTag("__TRUNCATE_ACCOUNT_DELTA_TABLE__");
      aRowset->AddParam("%%TABLE_NAME%%", mInsertDeltaTableName.c_str());
      aRowset->Execute();

      aRowset->ClearQuery();
      aRowset->SetQueryTag("__TRUNCATE_ACCOUNT_DELTA_TABLE__");
      aRowset->AddParam("%%TABLE_NAME%%", mDeleteDeltaTableName.c_str());
      aRowset->Execute();
    }
    catch(...)
    {
      if (pSA)
      {
        if (bSALocked)
          ::SafeArrayUnaccessData(pSA);

        ::SafeArrayDestroy(pSA);
      }

      hr = E_FAIL;
    }

    return hr;
}

HRESULT
MTCoreAccountMgr::CreateAccount(RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset,
                                AccountOutputParams& outputParams)
{ 
  try
  {
  // The rowset should already be initialized,
  // specify stored procedure.
  aRowset->InitializeForStoredProc("AddNewAccount");

  _variant_t vtGUID;
  if(!MTMiscUtil::CreateGuidAsVariant(vtGUID))
  {
    return E_FAIL;
  }

  // encode the password using MD5
  string sEncodedStr;
  
    if(mParams.mAuthenticationType.lVal == METRANET_INTERNAL)
    {
      string passwordToBeHashed;
      wstring widePassword = _bstr_t(mParams.mPassword);
      WideStringToUTF8(widePassword, passwordToBeHashed);

      // Remove dependency on MTMiscUtil
      // FEAT-752 - Support active directory
      // Remove dependency on MetraTech_Security::PasswordManager
      MetraTech_Security::IAuthPtr auth;
      auth = new MetraTech_Security::IAuthPtr(__uuidof(MetraTech_Security::Auth));
      auth->Initialize(_bstr_t(mParams.mlogin), _bstr_t(mParams.mNameSpace));
      mParams.mPassword = auth->HashNewPassword(_bstr_t(passwordToBeHashed.c_str()));
    }

  aRowset->AddInputParameterToStoredProc("p_id_acc_ext", MTTYPE_VARBINARY,INPUT_PARAM,vtGUID);
  aRowset->AddInputParameterToStoredProc("p_acc_state",MTTYPE_VARCHAR,INPUT_PARAM,mParams.mAccountState);
  aRowset->AddInputParameterToStoredProc("p_acc_status_ext",MTTYPE_INTEGER,INPUT_PARAM,mParams.mAccountStateExt);
  
  PopulateAccountStartAndEnd(aRowset);

  aRowset->AddInputParameterToStoredProc("p_nm_login",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mlogin);
  aRowset->AddInputParameterToStoredProc("p_nm_space",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mNameSpace);
  aRowset->AddInputParameterToStoredProc("p_tx_password",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mPassword);
  aRowset->AddInputParameterToStoredProc("p_auth_type",MTTYPE_INTEGER,INPUT_PARAM,mParams.mAuthenticationType);
  aRowset->AddInputParameterToStoredProc("p_langcode",MTTYPE_VARCHAR,INPUT_PARAM,mParams.mLangCode);
  aRowset->AddInputParameterToStoredProc("p_profile_timezone",MTTYPE_INTEGER,INPUT_PARAM,mParams.mtimezoneID);
  aRowset->AddInputParameterToStoredProc("p_ID_CYCLE_TYPE",MTTYPE_INTEGER,INPUT_PARAM,mParams.mCycleType);

  PopulateUsageCycleInfo(aRowset);
  aRowset->AddInputParameterToStoredProc("p_billable",MTTYPE_VARCHAR,INPUT_PARAM,mParams.mBillable);
  PopulatePaymentInformation(aRowset);
  PopulateHierarchyInformation(aRowset);

  aRowset->AddInputParameterToStoredProc("p_acc_type",MTTYPE_VARCHAR,INPUT_PARAM,mParams.mAccountType);
  
  _bstr_t strApplyPolicy = mParams.mApplyDefaultSecurityPolicy ? "T" : "F";
  aRowset->AddInputParameterToStoredProc("p_apply_default_policy",MTTYPE_VARCHAR,INPUT_PARAM,strApplyPolicy);
  aRowset->AddInputParameterToStoredProc("p_systemdate",MTTYPE_DATE,INPUT_PARAM,GetMTOLETime());
  aRowset->AddInputParameterToStoredProc("p_enforce_same_corporation", MTTYPE_VARCHAR, INPUT_PARAM, mParams.bEnforceSameCorp ? "1" : "0");
  aRowset->AddInputParameterToStoredProc("p_account_currency", MTTYPE_W_VARCHAR, INPUT_PARAM, mParams.mCurrency);

  // Generate propfile id.
  MetraTech_DataAccess::IIdGenerator2Ptr idGen(__uuidof(MetraTech_DataAccess::IdGenerator));
  idGen->Initialize("id_profile", 1);
  aRowset->AddInputParameterToStoredProc("p_profile_id", MTTYPE_INTEGER, INPUT_PARAM, idGen->NextId);
  aRowset->AddInputParameterToStoredProc("p_login_app", MTTYPE_VARCHAR, INPUT_PARAM, mParams.mLoginApp);

  MetraTech_DataAccess::IIdGenerator2Ptr idGen2(__uuidof(MetraTech_DataAccess::IdGenerator));
  idGen2->Initialize("id_acc", 1);
  long accountID;
  
  if(mParams.mUseMashedId)
  {
	  accountID = idGen2->NextMashedId;
  }
  else
  {
	  accountID = idGen2->NextId;
  }

  aRowset->AddInputParameterToStoredProc("accountID", MTTYPE_INTEGER, INPUT_PARAM, accountID);
//aRowset->AddOutputParameterToStoredProc("accountID",MTTYPE_INTEGER,OUTPUT_PARAM);
  aRowset->AddOutputParameterToStoredProc("status",MTTYPE_INTEGER,OUTPUT_PARAM);
  aRowset->AddOutputParameterToStoredProc("p_hierarchy_path",MTTYPE_VARCHAR,OUTPUT_PARAM);
  aRowset->AddOutputParameterToStoredProc("p_currency",MTTYPE_W_VARCHAR,OUTPUT_PARAM);
  aRowset->AddOutputParameterToStoredProc("p_id_ancestor_out",MTTYPE_INTEGER,OUTPUT_PARAM);
  aRowset->AddOutputParameterToStoredProc("p_corporate_account_id",MTTYPE_INTEGER,OUTPUT_PARAM);
  aRowset->AddOutputParameterToStoredProc("p_ancestor_type_out", MTTYPE_VARCHAR, OUTPUT_PARAM);
  
  aRowset->ExecuteStoredProc();
  long status = aRowset->GetParameterFromStoredProc("status");
  outputParams.mAncestor_type = aRowset->GetParameterFromStoredProc("p_ancestor_type_out");
  if(status == 1) 
  {
    outputParams.mAccountID = accountID;
    outputParams.mHierarchyPath = aRowset->GetParameterFromStoredProc("p_hierarchy_path");
    _variant_t currency = aRowset->GetParameterFromStoredProc("p_currency");
    if(currency.vt == VT_BSTR) 
    {
      outputParams.mAncestorCurrency = _bstr_t(currency);
    }
    else 
    {
      outputParams.mAncestorCurrency = "";
    }
    //get ancestor id and set it in session, so that it could be used in other plugins
    outputParams.mNewAncestorID = aRowset->GetParameterFromStoredProc("p_id_ancestor_out");
    outputParams.mCorporationID = aRowset->GetParameterFromStoredProc("p_corporate_account_id");

    // Now process materialized views.
    HRESULT hr = S_OK;
    if (mIsMVSupportEnabled)
        hr = UpdateMaterializedViews(aRowset, outputParams.mAccountID, true);

    return hr;
  }
  else
  {
    ASSERT(status != 0);
    return ReturnComError(status);
  }
  }
  catch(exception * ex)
  {
    cout << "Error: " << ex->what() << endl;
    throw;
  }
}

void
MTCoreAccountMgr::PopulatePaymentInformation(
                                             RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset)
{
  _variant_t empty;
  empty.vt = VT_NULL;

  // if the payer is not specified pass we pass in the dfeault value NULL value
  aRowset->AddInputParameterToStoredProc("p_id_payer",MTTYPE_INTEGER,INPUT_PARAM,mParams.mPayerID);
  
  // the date range.  The variant may be NULL
  aRowset->AddInputParameterToStoredProc("p_payer_startdate",MTTYPE_DATE,INPUT_PARAM,mParams.mPayerStartDate);
  aRowset->AddInputParameterToStoredProc("p_payer_enddate",MTTYPE_DATE,INPUT_PARAM,mParams.mPayerEndDate);

  // payer login and namespace.  the default value is NULL
  aRowset->AddInputParameterToStoredProc("p_payer_login",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mPayerlogin);
  aRowset->AddInputParameterToStoredProc("p_payer_namespace",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mPayerNamespace);
}

void
MTCoreAccountMgr::PopulateAccountStartAndEnd(
                                             RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset)
{
  aRowset->AddInputParameterToStoredProc("p_acc_vtstart",MTTYPE_DATE,INPUT_PARAM,mParams.mStateStart);
  aRowset->AddInputParameterToStoredProc("p_acc_vtend",MTTYPE_DATE,INPUT_PARAM,mParams.mStateEnd);
}


// XXX: remove the hardcoded types


void
MTCoreAccountMgr::PopulateUsageCycleInfo(
                                         RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset)
{
  _variant_t empty;
  empty.vt = VT_NULL;

  // careful, on Update cycle type can be null if no change was made
  if (mParams.mCycleType != empty)
  {
    switch((long)mParams.mCycleType) {
    case 1: // monthly
    {
 //We don't need to do anything special for monthly
      break;
    }
    case 2: // On-demand
    {
      MT_THROW_COM_ERROR("On demand not supported");
    }
    case 3: // daily
      
      break;
    case 4: // weekly
      if (((long)mParams.mDayOfWeek < 1) || ((long)mParams.mDayOfWeek  > 7))
      {
        MT_THROW_COM_ERROR("The day of week is out of range. weekday = %d", (long)mParams.mDayOfWeek);
      }
      break;
    case 5: // bi-weekly
      //validates the day, month, and year
      if (((long)mParams.mStartMonth  < 1l) || ((long)mParams.mStartMonth  > 12l) ||
          ((long)mParams.mStartYear < 1970l) || ((long)mParams.mStartYear > 2037) ||
          ((long)mParams.mStartDay < 1) || 
          ((long)mParams.mStartDay > MTDate::GetDaysInMonth((long)mParams.mStartMonth,(long)mParams.mStartYear)))
      {
        MT_THROW_COM_ERROR("The month, day, or year property is invalid. Month = %d, Day = %d, Year = %d",
                           (long)mParams.mStartMonth, (long)mParams.mStartDay, (long)mParams.mStartYear);
      }
      break;
    case 6: // Semi-montly     
      if((long)mParams.mFirstDayOfMonth >= (long)mParams.mSecondDayOfMonth) {
        MT_THROW_COM_ERROR("The first day must be less than the second day. "
                           "first day = %d, second day = %d",  (long)mParams.mFirstDayOfMonth,(long)mParams.mSecondDayOfMonth);
      }
      break;
    case 7: // Quarterly
    {
      if((long)mParams.mStartDay < 1) {
        MT_THROW_COM_ERROR("The start day property is not in the range of [1 - 31]. StartDay = %d",(long)mParams.mStartDay);
      }
      if((long)mParams.mStartMonth < 1 || (long)mParams.mStartMonth > 12) {
        MT_THROW_COM_ERROR("The start month property is not in the range of [1 - 12]. StartMonth = %d",(long)mParams.mStartMonth);
      }

      // normalize the start month to be a value between 1 and 3
      mParams.mStartMonth = (long) mParams.mStartMonth % 3;
      if ((long) mParams.mStartMonth == 0) 
      {
        mParams.mStartMonth = 3;
      }
    }
    break;

    case 8: // Anually
    case 9: // Semi-annually
      //validates the day & month
      if (((long)mParams.mStartMonth  < 1) || ((long)mParams.mStartMonth  > 12) ||
          ((long)mParams.mStartDay < 1) || 
          //we don't care about leap year so a fixed year is ok
          ((long)mParams.mStartDay > MTDate::GetDaysInMonth((long)mParams.mStartMonth, 1999))) 
      {
        MT_THROW_COM_ERROR("The month or day property is invalid. Month = %d, Day = %d",
                           (long)mParams.mStartMonth, (long)mParams.mStartDay);
      }
      break;
    default:
      MT_THROW_COM_ERROR("unknown usage cycle type");
    }
  }

  aRowset->AddInputParameterToStoredProc("p_DAY_OF_MONTH",MTTYPE_INTEGER,INPUT_PARAM,mParams.mDayOfMonth);
  aRowset->AddInputParameterToStoredProc("p_DAY_OF_WEEK",MTTYPE_INTEGER,INPUT_PARAM,mParams.mDayOfWeek);
  aRowset->AddInputParameterToStoredProc("p_FIRST_DAY_OF_MONTH",MTTYPE_INTEGER,INPUT_PARAM,mParams.mFirstDayOfMonth);
  aRowset->AddInputParameterToStoredProc("p_SECOND_DAY_OF_MONTH",MTTYPE_INTEGER,INPUT_PARAM,mParams.mSecondDayOfMonth);
  aRowset->AddInputParameterToStoredProc("p_START_DAY",MTTYPE_INTEGER,INPUT_PARAM,mParams.mStartDay);
  aRowset->AddInputParameterToStoredProc("p_START_MONTH",MTTYPE_INTEGER,INPUT_PARAM,mParams.mStartMonth);
  aRowset->AddInputParameterToStoredProc("p_START_YEAR",MTTYPE_INTEGER,INPUT_PARAM,mParams.mStartYear);
}

void
MTCoreAccountMgr::PopulateHierarchyInformation(
                                               RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset)
{
  _variant_t empty;
  empty.vt = VT_NULL;

  // pass in a NULL ancestor ID if not specified by the caller
  aRowset->AddInputParameterToStoredProc("p_id_ancestor",MTTYPE_INTEGER,INPUT_PARAM,mParams.mAncestorID);
  
  // ancestor start and end; can be NULL    
  aRowset->AddInputParameterToStoredProc("p_hierarchy_start",MTTYPE_DATE,INPUT_PARAM,mParams.mHierarchyStart);
  aRowset->AddInputParameterToStoredProc("p_hierarchy_end",MTTYPE_DATE,INPUT_PARAM,mParams.mHierarchyEnd);

  aRowset->AddInputParameterToStoredProc("p_ancestor_name",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mAncestorLogon);

  aRowset->AddInputParameterToStoredProc("p_ancestor_namespace",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mAncestorNamespace);
}

HRESULT
MTCoreAccountMgr::UpdateAccount(RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset,
                                AccountOutputParams& outputParams)
{
  _bstr_t buffer;
  HRESULT hr(S_OK);
  try
  {
    // Do some materialized view preprocessing.
    if (mIsMVSupportEnabled)
    {
      aRowset->UpdateConfigPath("queries\\AccountCreation");
      aRowset->ClearQuery();
      aRowset->SetQueryTag("__CREATE_ACCOUNT_DELTA_TABLE__");
      aRowset->AddParam("%%TABLE_NAME%%", mDeleteDeltaTableName.c_str());
      aRowset->Execute();

      // Prepare the delta delete table for materialized view update.
      aRowset->ClearQuery();
      aRowset->SetQueryTag("__UPDATE_ACCOUNT_DELTA_TABLE__");
      aRowset->AddParam("%%TABLE_NAME%%", mBaseTableName.c_str());
      aRowset->AddParam("%%DELTA_TABLE_NAME%%", mDeleteDeltaTableName.c_str());
      aRowset->AddParam("%%ID_ACC_LIST%%", mParams.mAccountID);
      aRowset->Execute();
      mbCreatedDeleteDelta = true;
    }

    if(mParams.mAuthenticationType.lVal == METRANET_INTERNAL)
    {
      string sEncodedStr;
      string passwordToBeHashed;
      wstring widePassword = _bstr_t(mParams.mPassword);
      WideStringToUTF8(widePassword, passwordToBeHashed);

      // Remove dependency on MTMiscUtil
      MetraTech_Security::IAuthPtr auth;
      auth = new MetraTech_Security::IAuthPtr(__uuidof(MetraTech_Security::Auth));
      auth->Initialize(_bstr_t(mParams.mlogin), _bstr_t(mParams.mNameSpace));
      mParams.mPassword = auth->HashNewPassword(_bstr_t(passwordToBeHashed.c_str()));
    }
    _variant_t vtEmpty;
    vtEmpty.vt = VT_NULL;
    
    aRowset->ClearQuery();
    aRowset->InitializeForStoredProc("UpdateAccount");
    aRowset->AddInputParameterToStoredProc("p_loginname",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mlogin);
    aRowset->AddInputParameterToStoredProc("p_namespace",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mNameSpace);
    aRowset->AddInputParameterToStoredProc("p_id_acc",MTTYPE_INTEGER,INPUT_PARAM,mParams.mAccountID);
    aRowset->AddInputParameterToStoredProc("p_acc_state",MTTYPE_VARCHAR,INPUT_PARAM,mParams.mAccountState);
    aRowset->AddInputParameterToStoredProc("p_acc_state_ext",MTTYPE_INTEGER,INPUT_PARAM,mParams.mAccountStateExt);
    aRowset->AddInputParameterToStoredProc("p_acc_statestart",MTTYPE_DATE,INPUT_PARAM,mParams.mStateStart);
    aRowset->AddInputParameterToStoredProc("p_tx_password",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mPassword);
    aRowset->AddInputParameterToStoredProc("p_ID_CYCLE_TYPE",MTTYPE_INTEGER,INPUT_PARAM,mParams.mCycleType);

    PopulateUsageCycleInfo(aRowset);

    aRowset->AddInputParameterToStoredProc("p_id_payer",MTTYPE_INTEGER,INPUT_PARAM,mParams.mPayerID);
    aRowset->AddInputParameterToStoredProc("p_payer_login",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mPayerlogin);
    aRowset->AddInputParameterToStoredProc("p_payer_namespace",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mPayerNamespace);
    aRowset->AddInputParameterToStoredProc("p_payer_startdate",MTTYPE_DATE,INPUT_PARAM,mParams.mPayerStartDate);
    aRowset->AddInputParameterToStoredProc("p_payer_enddate",MTTYPE_DATE,INPUT_PARAM,mParams.mPayerEndDate);
    aRowset->AddInputParameterToStoredProc("p_id_ancestor",MTTYPE_INTEGER,INPUT_PARAM,mParams.mAncestorID);
    aRowset->AddInputParameterToStoredProc("p_ancestor_name",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mAncestorLogon);
    aRowset->AddInputParameterToStoredProc("p_ancestor_namespace",MTTYPE_W_VARCHAR,INPUT_PARAM,mParams.mAncestorNamespace);
    aRowset->AddInputParameterToStoredProc("p_hierarchy_movedate",MTTYPE_DATE,INPUT_PARAM,mParams.mHierarchyStart);
    aRowset->AddInputParameterToStoredProc("p_systemdate",MTTYPE_DATE,INPUT_PARAM,GetMTOLETime());
    aRowset->AddInputParameterToStoredProc("p_billable",MTTYPE_VARCHAR,INPUT_PARAM,mParams.mBillable);
    aRowset->AddInputParameterToStoredProc("p_enforce_same_corporation", MTTYPE_VARCHAR, INPUT_PARAM, mParams.bEnforceSameCorp ? "1" : "0");
    aRowset->AddInputParameterToStoredProc("p_account_currency", MTTYPE_W_VARCHAR, INPUT_PARAM, V_VT(&mParams.mCurrency) == VT_NULL ? "" : mParams.mCurrency);
    aRowset->AddOutputParameterToStoredProc("p_status",MTTYPE_INTEGER,OUTPUT_PARAM);
    aRowset->AddOutputParameterToStoredProc("p_cyclechanged",MTTYPE_INTEGER,OUTPUT_PARAM);
    aRowset->AddOutputParameterToStoredProc("p_newcycle",MTTYPE_INTEGER,OUTPUT_PARAM);
    aRowset->AddOutputParameterToStoredProc("p_accountID",MTTYPE_INTEGER,OUTPUT_PARAM);
    aRowset->AddOutputParameterToStoredProc("p_hierarchy_path",MTTYPE_VARCHAR,OUTPUT_PARAM);
    aRowset->AddOutputParameterToStoredProc("p_old_id_ancestor_out",MTTYPE_INTEGER,OUTPUT_PARAM);
    aRowset->AddOutputParameterToStoredProc("p_id_ancestor_out",MTTYPE_INTEGER,OUTPUT_PARAM);
    aRowset->AddOutputParameterToStoredProc("p_corporate_account_id",MTTYPE_INTEGER,OUTPUT_PARAM);
    aRowset->AddOutputParameterToStoredProc("p_ancestor_type", MTTYPE_VARCHAR, OUTPUT_PARAM);
    aRowset->AddOutputParameterToStoredProc("p_acc_type", MTTYPE_VARCHAR, OUTPUT_PARAM);
    
    aRowset->ExecuteStoredProc();
    hr = (HRESULT) aRowset->GetParameterFromStoredProc("p_status");
    outputParams.mAncestor_type = aRowset->GetParameterFromStoredProc("p_ancestor_type");
    if (hr == 1)
    {
      hr = S_OK;
      outputParams.mbUsageCycleChanged = aRowset->GetParameterFromStoredProc("p_cyclechanged");
      outputParams.mNewUsageCycleID = aRowset->GetParameterFromStoredProc("p_newcycle");
      outputParams.mAccountID = aRowset->GetParameterFromStoredProc("p_accountID");
      outputParams.mHierarchyPath = aRowset->GetParameterFromStoredProc("p_hierarchy_path");
      //old ancestor id
      outputParams.mOldAncestorID = aRowset->GetParameterFromStoredProc("p_old_id_ancestor_out");
      //new ancestor id
      outputParams.mNewAncestorID = aRowset->GetParameterFromStoredProc("p_id_ancestor_out");
      //corporate account id
      outputParams.mCorporationID = aRowset->GetParameterFromStoredProc("p_corporate_account_id");
  
      // Now process materialized views.
      if (mIsMVSupportEnabled)
          hr = UpdateMaterializedViews(aRowset, mParams.mAccountID, false);
    }
  }
  catch (_com_error& e)
  {
    return ReturnComError(e);
  }
  return hr;
}

/*
  try
  {
    // ---------------------------------------------------------------------
  }
  catch (_com_error& e)
  {
    return ReturnComError(e);
  }

  return hr;
}
*/
