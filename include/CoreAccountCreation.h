#ifndef __COREACCOUNTCREATION_H__
#define __COREACCOUNTCREATION_H__
#pragma once

#include <errobj.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <autologger.h>
#include <RowsetDefs.h>
#include <stdutils.h>
#include <MTUtil.h>
#include <mtprogids.h>
#include <PCCache.h>

namespace
{
  char aCoreAccountCreationLogTitle[] = "CoreAccountCreation";
};

#import <rowsetinterfaceslib.tlb> rename ("EOF", "RowsetEOF") // no_namespace

// structure used for parameters to the 
// AddNewAccount stored procedure.  Note: 
// data types are in the format most useful for passing
// to MTSQLRowset 
  typedef enum
  {
    PAYMENTMAP_ACCOUNTVAL = 2,
    PAYMENTMAP_LOGINNAME = 4,
    PAYMENTMAP_NS = 8,
    PAYMENTMAP_STARTDATE = 16,
    PAYMENTMAP_ENDDATE = 32,
  } PaymentMapTypes;

  typedef enum
  {
    ANCESTORMAP_ANCESTOR = 2,
    ANCESTORMAP_LOGINNAME = 4,
    ANCESTORMAP_NS = 8,
    ANCESTORMAP_STARTDATE = 16,
    ANCESTORMAP_ENDDATE = 32,
  } AncestorMapTypes;

  typedef enum
  {
    STATEMAP_TYPE = 2,
    STATEMAP_STARTDATE = 4,
    STATEMAP_ENDDATE = 8,
  } AccountStateMap;

  typedef enum
  {
    METRANET_INTERNAL = 1,
    ACTIVE_DIRECTORY = 2
  } AuthenticationTypesMap;

class CoreAccountCreationParams
{
public:

  CoreAccountCreationParams()
  {
    // default all the variant_t properties to VT_NULL
    mAccountState.vt = VT_NULL;
    mAccountStateExt.vt = VT_NULL;
    mStateStart.vt = VT_NULL;
    mStateEnd.vt = VT_NULL;
    mlogin.vt = VT_NULL;
    mNameSpace.vt = VT_NULL;
    mPassword.vt = VT_NULL;
    mLangCode.vt = VT_NULL;
    mtimezoneID.vt = VT_NULL;
    mCycleType.vt = VT_NULL;
    mDayOfMonth.vt = VT_NULL;
    mDayOfWeek.vt = VT_NULL;
    mFirstDayOfMonth.vt = VT_NULL;
    mSecondDayOfMonth.vt = VT_NULL;
    mStartDay.vt = VT_NULL;
    mStartMonth.vt = VT_NULL;
    mStartYear.vt = VT_NULL;
    mBillable.vt = VT_NULL;
    mLoginApp.vt = VT_NULL;
    mPayerID.vt = VT_NULL;
    mPayerlogin.vt = VT_NULL;
    mPayerNamespace.vt = VT_NULL;
    mPayerStartDate.vt = VT_NULL;
    mPayerEndDate.vt = VT_NULL;
    mAncestorID.vt = VT_NULL;
    mAncestorLogon.vt = VT_NULL;
    mAncestorNamespace.vt = VT_NULL;
    mHierarchyStart.vt = VT_NULL;
    mHierarchyEnd.vt = VT_NULL;

    // default the dates to be NULL.  The allows them to be passed
    // to the stored procedure as NULL values.
    mStateStart.vt = VT_NULL;
    mStateEnd.vt = VT_NULL;

    mPayerStartDate.vt = VT_NULL;
    mPayerEndDate.vt = VT_NULL;

    mHierarchyStart.vt = VT_NULL;
    mHierarchyEnd.vt = VT_NULL;
    mCurrency.vt = VT_NULL;

    mAccountID = -1l;
    mAuthenticationType = METRANET_INTERNAL;

    mAccountStateMap = 0;
    mPaymentMap = 0;
    mAncestorMap = 0;
    mPasswordMap = 0;

    mCanBePayer = false;
    mCanSubscribe = false;
    mCanHaveSyntheticRoot = false;
    mCanParticipateInGSub = false;
    mCanHaveTemplates = false;
    mIsCorporate = false;
    mIsVisibleInHierarchy = false;

	  mUseMashedId = true;
  }

public: // account creation properties

  _variant_t mAccountState;
  _bstr_t    mAccountType;
  _variant_t mAccountStateExt;
  _variant_t mAuthenticationType;

  _variant_t mAccountID;
  _variant_t mStateStart;
  _variant_t mStateEnd;
  _variant_t mlogin;
  _variant_t mNameSpace;
  _variant_t mPassword;
  _variant_t mLangCode;
  _variant_t mtimezoneID;
  _variant_t mCycleType;
  _variant_t mDayOfMonth;
  _variant_t mDayOfWeek;
  _variant_t mFirstDayOfMonth;
  _variant_t mSecondDayOfMonth;
  _variant_t mStartDay;
  _variant_t mStartMonth;
  _variant_t mStartYear;
  _variant_t mBillable;

  _variant_t mLoginApp; //specifies the application a system account is going to log into.
  // specifies if payment redirection is configured
  _variant_t mPayerID;
  _variant_t mPayerlogin;
  _variant_t mPayerNamespace;
  _variant_t mPayerStartDate;
  _variant_t mPayerEndDate;

  // specifies if the account is in the hierarchy
  bool       bUsingHierarchy;
  _variant_t mAncestorID;
  _variant_t mAncestorLogon;
  _variant_t mAncestorNamespace;
  _variant_t mHierarchyStart;
  _variant_t mHierarchyEnd;
  bool       mApplyDefaultSecurityPolicy;

  // property map.  Basically, a bitmap of what properties were specified by the user
  long       mAccountStateMap;
  long       mPaymentMap;
  long       mAncestorMap;
  long       mPasswordMap;

  bool       bEnforceSameCorp;  // Not used by BatchAccountCreation.
  _variant_t mCurrency;

  // properties related to account types.
  bool      mCanBePayer;
  bool      mCanSubscribe;
  bool      mCanHaveSyntheticRoot;
  bool      mCanParticipateInGSub;
  bool      mCanHaveTemplates;
  bool      mIsCorporate;
  bool      mIsVisibleInHierarchy;

  bool		mUseMashedId;
};

typedef struct
{
  long       mAccountID;
  bool       mbUsageCycleChanged;
  long       mNewUsageCycleID;
  _bstr_t    mHierarchyPath;
  _variant_t mAncestorCurrency;
  long       mOldAncestorID;
  long       mNewAncestorID;
  long       mCorporationID;
  _bstr_t    mAncestor_type;
} AccountOutputParams;

typedef struct
{
  long       mAccountID;
  long       mUsageCycle;
  long       mAncestor;
  _variant_t mAncestorLogin;
  _variant_t mAncestorNS;
  _variant_t mAncestorStart;
  _variant_t mAncestorEnd;
  long       mPayer;
  _bstr_t    mPayerLogin;
  _bstr_t    mPayerNS;
  _variant_t mPayerStart;
  _variant_t mPayerEnd;
  _bstr_t    mAccType;
  long       mCorporateAccount;
  _bstr_t    mHierarchyPath;
  _bstr_t    mAccState;
  long       mCycleType;
  _variant_t mDayOfMonth;
  _variant_t mDayOfWeek;
  _variant_t mFirstDayOfMonth;
  _variant_t mSecondDayOfMonth;
  _variant_t mStartDay;
  _variant_t mStartMonth;
  _variant_t mStartYear;
  bool       mIsFolder;
  _variant_t mBillable;
} MTExistingUpdateProperties;

// Import Materialized View type libs.
#import <MetraTech.DataAccess.MaterializedViews.tlb>

//
class MTCoreAccountMgr
{
public:

  MTCoreAccountMgr(CoreAccountCreationParams& params);

  HRESULT CreateAccount(RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset,AccountOutputParams&);
  HRESULT UpdateAccount(RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset,AccountOutputParams&);

private:

  MTAutoInstance<MTAutoLoggerImpl<aCoreAccountCreationLogTitle> > mLogger;

  // Memberes required for materialized view support
  MetraTech_DataAccess_MaterializedViews::IManagerPtr mpMvMgr;
  bool mIsMVSupportEnabled;
  string mBaseTableName;
  string mInsertDeltaTableName;
  string mDeleteDeltaTableName;
  bool mbCreatedInsertDelta;
  bool mbCreatedDeleteDelta;

private:

  // Method required for materialized view support.
  HRESULT UpdateMaterializedViews(RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset, long AccountID, bool bInsertMode);

protected:

  void PopulateAccountStartAndEnd(RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset);
  void PopulateUsageCycleInfo(RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset);
  void PopulatePaymentInformation(RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset);
  void PopulateHierarchyInformation(RowSetInterfacesLib::IMTSQLRowsetPtr& aRowset);

  CoreAccountCreationParams& mParams;
};

#endif //__COREACCOUNTCREATION_H__
