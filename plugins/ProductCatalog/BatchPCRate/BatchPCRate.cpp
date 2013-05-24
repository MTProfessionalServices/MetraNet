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
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

// TODO:
//  - critical sections
//  - clean up timing code
//  - performance logging
//  - set pi instance ID
//  - clean up old rate input collection classes

#pragma warning( disable : 4786 ) 

#include <BatchPlugInSkeleton.h>
#include "SessServer.h"
#include <MTObjectOwnerBaseDef.h>
#include <MTSessionServerBaseDef.h>
#include <MTVariantSessionEnumBase.h>
#include <MTSessionSetDef.h>
#include <MTSessionDef.h>

#include <RSCache.h>
#include <RSIDLookup.h>
#include <RSIDCache.h>

#include <DBRSLoader.h>
#include <RateLookup.h>

#include <mtprogids.h>

#include <propids.h>
#include <MTUtil.h>

#include <mtcomerr.h>
#include <mttime.h>
#include <RateInterpreter.h>

//#include <MTSessionDef.h>



#include <limits.h>              // need this for _I64_MAX


#import <MTProductCatalog.tlb> rename("EOF", "EOFX")

using MTPRODUCTCATALOGLib::IMTProductCatalogPtr;
using MTPRODUCTCATALOGLib::IMTRuleSetPtr;
using MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr;
using MTPRODUCTCATALOGLib::IMTPriceableItemPtr;
using MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr;

using MTPipelineLib::IMTConfigPropSetPtr;
using MTPipelineLib::IMTConfigPropPtr;

#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcResultSet.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcConnMan.h>

#include <autoptr.h>
#include <stdutils.h>
#include <errutils.h>
#include <perflog.h>

typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;




// generate using uuidgen
CLSID CLSID_BatchPCRate = { /* 68df0d64-c2b0-4fff-bb83-502a1282d4ed */
    0x68df0d64,
    0xc2b0,
    0x4fff,
    {0xbb, 0x83, 0x50, 0x2a, 0x12, 0x82, 0xd4, 0xed}
  };

class ATL_NO_VTABLE BatchPCRatePlugIn
  : public MTBatchPipelinePlugIn<BatchPCRatePlugIn, &CLSID_BatchPCRate>
{
protected:
  // Initialize the processor, looking up any necessary property IDs.
  // The processor can also use this time to do any other necessary initialization.
  // NOTE: This method can be called any number of times in order to
  //  refresh the initialization of the processor.
  virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                       MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                       MTPipelineLib::IMTNameIDPtr aNameID,
                                       MTPipelineLib::IMTSystemContextPtr aSysContext);
  virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet);

  // Initialize the database connection and all statements.  It is safe
  // to call this multiple times (for example after a database connection
  // has failed).
  virtual HRESULT BatchPlugInInitializeDatabase();
  
  virtual HRESULT BatchPlugInShutdownDatabase();

  // lookup a PI template name given its ID.  This is used only
  // for error handling.
  void LookupPITemplateName(_bstr_t & arTemplateName,
                            int piTemplateID);

  virtual ~BatchPCRatePlugIn();
  BatchPCRatePlugIn();

private:
  HRESULT ResolveBatch(vector<MTautoptr<CMTSessionBase> >& aSessionArray);
  HRESULT ResolvePriceableItemTemplate(vector<MTautoptr<CMTSessionBase> >& aSessionArray);

  HRESULT PlugInProcessSessionPostQuery(CMTSessionBase* aSession, const RateInputs& aInputs, ParameterTable& aParamTable);
  virtual MTPipelineLib::IMTTransactionPtr BatchPCRatePlugIn::GetTransaction(CMTSessionBase* aSession);


  MTPipelineLib::IMTLogPtr mLogger;
  MTPipelineLib::IMTLogPtr mPerfLogger;
  CMTSessionServerBase* mpSessionServerBase;

  vector<ParameterTable> mParameterTables;

  // interface to the database
  RSIDLookup mLookup;

  // cached rate schedule IDs held between param table lookups
  RSIDCache * mpRSIDCache;

  // cache between priceable item template name/id
  // and priceable item information
  CompoundPICache mPICache;

  // object that performs the rating
  PCRater mRater;

  // rate schedule loader to use
  DBRSLoader mDBLoader;
  OptimizedRateScheduleLoader mRSLoader;

  long mTimestampPropID;
  long mPriceableItemNamePropID;
  long mAccountPropID;
  long mAccountPriceListPropID;

  long mPriceableItemTypePropID;
  long mPriceableItemTemplatePropID;
  long mSubscriptionPropID;

  long mUsageCycleID;

  int mArraySize;

  // if TRUE, then resolve subscription.  Otherwise assume that the subscription
  // has been resolved already.
  BOOL mResolveSub;

  // if TRUE, then check session parent/child relationships against the product
  // catalog.
  BOOL mCheckProductHierarchy;

  // if TRUE, evaluates rate schedule rules given input properties
  // otherwise just performs the rate schedule resolution
  BOOL mApplyRates;

  // Tag name of the stage/plugin
  _bstr_t mTagName;

  ITransactionPtr mTransaction;

  // reference to RSIDCache object
  IUnknownPtr mRSIDCacheRef;

  static NTThreadLock mCacheInitLock;

  __int64 mTotalRecords;
  double mTotalMillis;
  __int64 mTotalFetchTicks;
  __int64 mResolveRateSchedulesTicks;
  __int64 mResolvePriceableItemTemplateTicks;
  __int64 mPostQueryTicks;
  __int64 mTruncateTableTicks;
  __int64 mInsertTempTableTicks;
  __int64 mSelectRateSchedulesTicks;
};

NTThreadLock BatchPCRatePlugIn::mCacheInitLock;

PLUGIN_INFO(CLSID_BatchPCRate, BatchPCRatePlugIn,
            "MetraPipeline.PCRate.1", "MetraPipeline.PCRate", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

BatchPCRatePlugIn::BatchPCRatePlugIn()
{
  mpSessionServerBase = NULL;
}

BatchPCRatePlugIn::~BatchPCRatePlugIn()
{
  if(mpSessionServerBase)
  {
    mpSessionServerBase->Release();
    mpSessionServerBase = NULL;
  }
}



#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "BatchPCRatePlugIn::PlugInConfigure"
HRESULT BatchPCRatePlugIn::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                                MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                                MTPipelineLib::IMTNameIDPtr aNameID,
                                                MTPipelineLib::IMTSystemContextPtr aSysContext)
{
//        <RateLookup>
//          <ParamTable>metratech.com/rateconn</ParamTable>
//        </RateLookup>
  HRESULT hr;
  mLogger = aLogger;
  mPerfLogger = MTPipelineLib::IMTLogPtr(MTPROGID_LOG);
  mPerfLogger->Init("logging\\perflog", "[PCRate]");

  // NOTE: this has to be done very early
  PipelinePropIDs::Init();

#if 1
  // These are not used anywhere so why do we query for them?  MG
  // Except for "batch_size". BB
  //
  // We query for them because they advance the pointer in the aPropSet
  // collection.  These are here for backward compatibility so that if
  // these entries are in older config files they will be appropriately
  // skipped.  MG

  BOOL useBcpFlag;
  if (aPropSet->NextMatches(L"usebcpflag", MTPipelineLib::PROP_TYPE_BOOLEAN))
    useBcpFlag = aPropSet->NextBoolWithName(L"usebcpflag") == VARIANT_TRUE;
  else
    useBcpFlag = TRUE;

  // Allow the user to set size of batch.
  if (aPropSet->NextMatches(L"batch_size", MTPipelineLib::PROP_TYPE_INTEGER))
    mArraySize = aPropSet->NextLongWithName("batch_size");
  else
    mArraySize = 1000;

  BOOL copyData;
  if (aPropSet->NextMatches(L"copydata", MTPipelineLib::PROP_TYPE_BOOLEAN))
    copyData = aPropSet->NextBoolWithName(L"copydata") == VARIANT_TRUE;
  else
    copyData = FALSE;
#endif

  if (aPropSet->NextMatches(L"ResolveSubscription", MTPipelineLib::PROP_TYPE_BOOLEAN))
    mResolveSub = aPropSet->NextBoolWithName(L"ResolveSubscription") == VARIANT_TRUE;
  else
    mResolveSub = TRUE;

  if (aPropSet->NextMatches(L"CheckProductHierarchy", MTPipelineLib::PROP_TYPE_BOOLEAN))
    mCheckProductHierarchy = aPropSet->NextBoolWithName(L"CheckProductHierarchy") == VARIANT_TRUE;
  else
    mCheckProductHierarchy = TRUE;

  if (aPropSet->NextMatches(L"ApplyRates", MTPipelineLib::PROP_TYPE_BOOLEAN))
    mApplyRates = aPropSet->NextBoolWithName(L"ApplyRates") == VARIANT_TRUE;
  else
    mApplyRates = TRUE;

  try {
    while (aPropSet->NextMatches(L"RateLookup", MTPipelineLib::PROP_TYPE_SET) == VARIANT_TRUE)
    {
      IMTConfigPropSetPtr rateLookup = aPropSet->NextSetWithName(L"RateLookup");
      ASSERT (rateLookup != NULL);

      _bstr_t paramTableName = rateLookup->NextStringWithName(L"ParamTable");

      if (rateLookup->NextMatches(L"WeightOnKey", MTPipelineLib::PROP_TYPE_STRING))
      {
        _bstr_t keyName = rateLookup->NextStringWithName(L"WeightOnKey");
        int weightOnKeyID = aNameID->GetNameID(keyName);

        _bstr_t buffer(L"Weighting the value of ");
        buffer += keyName;
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

        _bstr_t startAt = rateLookup->NextStringWithName(L"StartAt");
        long startAtID = aNameID->GetNameID(startAt);

        _bstr_t inSession = rateLookup->NextStringWithName(L"InSession");
        long inSessionID = aNameID->GetNameID(inSession);

        mParameterTables.push_back(ParameterTable(paramTableName, weightOnKeyID, startAtID, inSessionID));
      }
      else
      {
        mParameterTables.push_back(ParameterTable(paramTableName));
      }
    }
  } catch(std::exception& stlException) {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(stlException.what()));
    return E_FAIL;    
  }

  // Make sure we had at least one ratelookup
  if (0 == mParameterTables.size())
    return Error("No rate lookup sections found in product catalog rate plug-in");

  BOOL initParamTableCache;
  if (aPropSet->NextMatches(L"InitParamTableCache", MTPipelineLib::PROP_TYPE_BOOLEAN))
    initParamTableCache = aPropSet->NextBoolWithName(L"InitParamTableCache") == VARIANT_TRUE;
  else
    initParamTableCache = FALSE;

  // dynamically reads in property names; must be the same for all parameter tables.
  long accountCycleID = -1;
  if (aPropSet->NextMatches("properties", MTPipelineLib::PROP_TYPE_SET) == VARIANT_TRUE)
  {
    IMTConfigPropSetPtr propertiesset = aPropSet->NextSetWithName(L"properties");
    if (propertiesset == NULL)
      return Error("No properties found in the properties set");
    
    DECLARE_PROPNAME_MAP(inputs)
      DECLARE_PROPNAME_OPTIONAL("_Timestamp", &mTimestampPropID)
      DECLARE_PROPNAME_OPTIONAL("_PriceableItemName", &mPriceableItemNamePropID)
      DECLARE_PROPNAME_OPTIONAL("_AccountID", &mAccountPropID)
      DECLARE_PROPNAME_OPTIONAL("_AccountPriceList", &mAccountPriceListPropID)
      DECLARE_PROPNAME_OPTIONAL("_PriceableItemTypeID", &mPriceableItemTypePropID)
      DECLARE_PROPNAME_OPTIONAL("_PriceableItemTemplateID", &mPriceableItemTemplatePropID)
      DECLARE_PROPNAME_OPTIONAL("_SubscriptionID", &mSubscriptionPropID)
      DECLARE_PROPNAME_OPTIONAL("accountCycleID", &accountCycleID)
      DECLARE_PROPNAME_OPTIONAL("_UsageCycleID", &mUsageCycleID)
    END_PROPNAME_MAP
    
    hr = ProcessProperties(inputs, propertiesset, aNameID, aLogger, PROCEDURE);
    if (FAILED(hr))
      return hr;
  }
  else
  {
    mTimestampPropID = -1;
    mPriceableItemNamePropID = -1;
    mAccountPropID = -1;
    mAccountPriceListPropID = -1;
    mPriceableItemTypePropID = -1;
    mPriceableItemTemplatePropID = -1;
    mSubscriptionPropID = -1;
    mUsageCycleID = -1;
  }

  // supports deprecated reserved property name
  if (accountCycleID != -1)
    mUsageCycleID = accountCycleID;

  if (mTimestampPropID == -1)
    mTimestampPropID = aNameID->GetNameID(L"_Timestamp");

  if (mPriceableItemNamePropID == -1)
    mPriceableItemNamePropID = aNameID->GetNameID(L"_PriceableItemName");

  if (mAccountPropID == -1)
    mAccountPropID = aNameID->GetNameID(L"_AccountID");

  if (mAccountPriceListPropID == -1)
    mAccountPriceListPropID = aNameID->GetNameID(L"_AccountPriceList");

  if (mPriceableItemTypePropID == -1)
    mPriceableItemTypePropID = aNameID->GetNameID(L"_PriceableItemTypeID");

  if (mPriceableItemTemplatePropID == -1)
    mPriceableItemTemplatePropID = aNameID->GetNameID(L"_PriceableItemTemplateID");

  if (mSubscriptionPropID == -1)
    mSubscriptionPropID = aNameID->GetNameID(L"_SubscriptionID");

  if (mUsageCycleID == -1)
    mUsageCycleID = aNameID->GetNameID(L"_UsageCycleID");

  if (!mDBLoader.Init())
  {
    char* pErrMsg = "unable to initialize database rate schedule loader";

    // TODO: error handling!
    aLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, pErrMsg);
    return Error(pErrMsg);
  }

  mRater.SetLoader(&mRSLoader);

  // Get the tag for the temp table
  mTagName = GetTagName(aSysContext);

  if (initParamTableCache)
  {
    time_t now = GetMTTime();

    try
    {
      vector<ParameterTable>::iterator ptIt;
      for (ptIt = mParameterTables.begin(); ptIt != mParameterTables.end(); ++ptIt)
      {
        ParameterTable& table = *ptIt;

        char buffer[256];
        buffer[sizeof(buffer)-1] = '\0';
        _snprintf(buffer, sizeof(buffer)-1, "Preloading the rate schedule cache for parameter table ID: %d", table.GetParamTableID());
        aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

        int numRateScheds = mRater.InitRateSchedules(table.GetParamTableID(), now);
        if (numRateScheds < 0)
        {
          const ErrorObject* e = mRater.GetLastError();
          string msg = e->GetProgrammerDetail();
          _snprintf(buffer, sizeof(buffer)-1, "Unable to initialize the rate schedule cache for parameter table ID: %d, error: '%s'", table.GetParamTableID(), msg.c_str());
          aLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
          return Error(buffer);
        }

        if (numRateScheds == 1)
          _snprintf(buffer, sizeof(buffer)-1, "%d rate schedule was cached for parameter table ID: %d.", numRateScheds, table.GetParamTableID());
        else
          _snprintf(buffer, sizeof(buffer)-1, "%d rate schedules were cached for parameter table ID: %d.", numRateScheds, table.GetParamTableID());
        aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
      }
    }
    catch(std::exception& stlException)
    {
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, _bstr_t(stlException.what()));
      return E_FAIL;    
    }
  }

   mpSessionServerBase = CMTSessionServerBase::CreateInstance();
  
  mTotalRecords = 0;
  mTotalMillis = 0;
  mTotalFetchTicks = 0;
  mResolveRateSchedulesTicks = 0;
  mResolvePriceableItemTemplateTicks = 0;
  mPostQueryTicks = 0;
  mTruncateTableTicks = 0;
  mInsertTempTableTicks = 0;
  mSelectRateSchedulesTicks = 0;

  return S_OK;
}


HRESULT BatchPCRatePlugIn::ResolvePriceableItemTemplate(
  vector<MTautoptr<CMTSessionBase> >& aSessionArray)
{
  MarkRegion region("ResolvePITemplate");

  BOOL errorsFound = FALSE;

  vector<MTautoptr<CMTSessionBase> >::const_iterator sessionIt;
  for (sessionIt = aSessionArray.begin();
       sessionIt != aSessionArray.end();
       sessionIt++)
  {
    CMTSessionBase* session = (CMTSessionBase*)&(*sessionIt);

    // true if this session has a parent
    BOOL sessionIsChild = (session->get_ParentID() != -1);

    bool piFound = true;
    const SubPI * piInfo = 0;
    if (session->PropertyExists(mPriceableItemTemplatePropID,
                                MTPipelineLib::SESS_PROP_TYPE_LONG))
    {
      int piTemplateID;
      piTemplateID =
        session->GetLongProperty(mPriceableItemTemplatePropID);

      try
      {
        piInfo = mPICache.FindPITemplate(piTemplateID);

        if (!piInfo)
        {
          session->MarkAsFailed(_bstr_t("Unable to find priceable item template"),
                                DISP_E_EXCEPTION);
          errorsFound = TRUE;
          piFound = false;
        }
      }
      catch (_com_error & err)
      {
        string buffer;
        StringFromComError(buffer,
                           "Unable to find priceable item template", err);
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer.c_str());

        session->MarkAsFailed(_bstr_t(buffer.c_str()),
                              DISP_E_EXCEPTION);
        errorsFound = TRUE;
        piFound = false;
      }

      if (piFound)
      {
        session->SetLongProperty(mPriceableItemTypePropID, piInfo->GetTypeID());
      }
    }
    else
    {
      // CAREFUL.  We are using SessionBase here and it returns a BSTR * with COM
      // copy semantics (caller frees) so just attach the _bstr_t and don't assign
      // since the latter is a memory leak.
      _bstr_t piName(session->GetStringProperty(mPriceableItemNamePropID), false);

      try
      {
        piInfo = mPICache.FindPITemplate(piName);

        if (!piInfo)
        {
          session->MarkAsFailed(_bstr_t("Unable to find priceable item template"),
                                DISP_E_EXCEPTION);
          errorsFound = TRUE;
        piFound = false;
        }
      }
      catch (_com_error & err)
      {
        string buffer;
        StringFromComError(buffer,
                           "Unable to find priceable item template", err);
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer.c_str());

        session->MarkAsFailed(_bstr_t(buffer.c_str()),
                              DISP_E_EXCEPTION);
        errorsFound = TRUE;
        piFound = false;
      }

      if (piFound)
      {
        session->SetLongProperty(mPriceableItemTemplatePropID,
                                 piInfo->GetTemplateID());
        session->SetLongProperty(mPriceableItemTypePropID,
                                 piInfo->GetTypeID());
      }
    }

    if (piFound)
    {
      // verify the hierarchy
      if (mCheckProductHierarchy && sessionIsChild && !piInfo->IsChild())
      {
        session->MarkAsFailed(_bstr_t("Parent priceable item rated as a child"),
                              PIPE_ERR_PI_HIERARCHY);
        errorsFound = TRUE;
        continue;
      }
      if (mCheckProductHierarchy && !sessionIsChild && piInfo->IsChild())
      {
        session->MarkAsFailed(_bstr_t("Child priceable rated with no parent"),
                              PIPE_ERR_PI_HIERARCHY);
        errorsFound = TRUE;
        continue;
      }
    }

  }

  if (errorsFound)
    return Error(L"Unable to resolve priceable item template for at least one session",
                 IID_IMTPipelinePlugIn, PIPE_ERR_SUBSET_OF_BATCH_FAILED);
  else
    return S_OK;
}

HRESULT BatchPCRatePlugIn::ResolveBatch(vector<MTautoptr<CMTSessionBase> >& aSessionArray)
{
  MarkRegion region("ResolveBatch");
  bool bAtLeastOneSessionFailed = false;
  // First get the priceable item template
  LARGE_INTEGER tick, tock;

  try
  {

    HRESULT hr;
    ::QueryPerformanceCounter(&tick);

    hr = ResolvePriceableItemTemplate(aSessionArray);

    ::QueryPerformanceCounter(&tock);
    mResolvePriceableItemTemplateTicks += (tock.QuadPart - tick.QuadPart);
    if (!SUCCEEDED(hr)) return hr;

    ::QueryPerformanceCounter(&tick);
    // An associative array of (paramter table, session) to RateInputs
    //  ScoredRateInputSet rateInputsArray(mParameterTables);

    vector<int> requestIDs;
    requestIDs.reserve(aSessionArray.size());

    ASSERT(mpRSIDCache);

    MarkEnterRegion("AddRequests");
    vector<MTautoptr<CMTSessionBase> >::iterator it;
    int i = 0;
    for (it = aSessionArray.begin(); it != aSessionArray.end(); ++it)
    {
      CMTSessionBase* session = &(*it);

      int cycleID = session->GetLongProperty(mUsageCycleID);
      int defaultPL = session->GetLongProperty(mAccountPriceListPropID);
      long piTemplateID = session->GetLongProperty(mPriceableItemTemplatePropID);

      // If we are resolving a subscription, we must have an account.  If we are not resolving
      // a subscription, then we must have a subscription.
      long accountID = mResolveSub ? session->GetLongProperty(mAccountPropID) : -1;
      long subID = mResolveSub ? -1 : session->GetLongProperty(mSubscriptionPropID);

      time_t now = session->GetDateTimeProperty(mTimestampPropID);

      int requestID = mpRSIDCache->AddRequest(&mPICache, piTemplateID,
        accountID, cycleID,
        defaultPL, (unsigned long) now, subID);

      requestIDs.push_back(requestID);
    }
    MarkExitRegion("AddRequests");

    // lookup all results
    MarkEnterRegion("Lookup");
    mpRSIDCache->Lookup(&mPICache, &mLookup, mTransaction);
    MarkExitRegion("Lookup");

    MarkEnterRegion("EvaluateRules");
    int missingEntries = 0;
    int noRates = 0;
    vector<ParameterTable>::iterator ptIt;

    try
    {
      for (ptIt = mParameterTables.begin(); ptIt != mParameterTables.end(); ++ptIt)
      {
        ParameterTable & table = *ptIt;
        int paramTableID = table.GetParamTableID();

        for (int i = 0; i < (int) aSessionArray.size(); i++)
        {
          CMTSessionBase* session = &aSessionArray[i];
          
          if(session->get_CompoundMarkedAsFailed())
          {
            continue;
          }

          int requestID = requestIDs[i];
          long piTemplateID = session->GetLongProperty(mPriceableItemTemplatePropID);
          const RateInputs * rateInputs =
            mpRSIDCache->GetResults(requestID, piTemplateID, paramTableID);
          if (!rateInputs)
        {
          missingEntries++;

          int defaultPL =
            aSessionArray[i]->GetLongProperty(mAccountPriceListPropID);

          int accountID = aSessionArray[i]->GetLongProperty(mAccountPropID);

          long now = (long) aSessionArray[i]->GetDateTimeProperty(mTimestampPropID);

          string strDate;
          MTFormatISOTime(now, strDate);

          _bstr_t piTemplateName;
          LookupPITemplateName(piTemplateName, piTemplateID);

          _bstr_t paramTableName = table.GetParamTableName();


          char buffer[1024];
          buffer[sizeof(buffer)-1] = '\0';
          _snprintf(buffer, sizeof(buffer)-1, "No rate schedules found for request #%d"
            " - account ID: %d (default PL=%d), pi template: %s, param table: %s, date: %s",
            requestID, accountID,
            defaultPL,
            (const char *) piTemplateName,
            (const char *) paramTableName,
            strDate.c_str());

          // NOTE: don't log this error because the pipeline will.
          aSessionArray[i]->MarkAsFailed(_bstr_t(buffer), PIPE_ERR_NO_RATE_SCHEDULES);
        }
          else
        {
          hr = PlugInProcessSessionPostQuery(session, *rateInputs, table);
          if (FAILED(hr))
          {
            if(hr == E_FAIL)
              bAtLeastOneSessionFailed = true;
            else
              noRates++;
          }
        }
        }
      }
    }
    catch(std::exception& stlException)
    {
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, _bstr_t(stlException.what()));
      return E_FAIL;    
    }
    MarkExitRegion("EvaluateRules");

    if (missingEntries > 0)
    {
      wchar_t buffer[256];
      swprintf(buffer, L"%d rate schedules not found", missingEntries);
      return Error(buffer, IID_IMTPipelinePlugIn, PIPE_ERR_SUBSET_OF_BATCH_FAILED);
    }

    if (noRates > 0)
    {
      wchar_t buffer[256];
      swprintf(buffer, L"no rates found for %d schedules", noRates);
      return Error(buffer, IID_IMTPipelinePlugIn, PIPE_ERR_SUBSET_OF_BATCH_FAILED);
    }

    //error other than no rates
    if(bAtLeastOneSessionFailed)
    {
      wchar_t buffer[256];
      swprintf(buffer, L"Internal error encountered during rating");
      return Error(buffer, IID_IMTPipelinePlugIn, PIPE_ERR_SUBSET_OF_BATCH_FAILED);
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }


  return S_OK;
}


HRESULT BatchPCRatePlugIn::PlugInProcessSessionPostQuery(
  CMTSessionBase* aSession,
  const RateInputs& aInputs,
  ParameterTable& aParameterTable)
{
  // TODO: set product offering ID if it's not -1?
//  if (po != -1)
//    aSession->SetLongProperty(PipelinePropIDs::ProductOfferingIDCode(), po);

  if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
  {
    wchar_t buffer[256];

    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Rate schedule resolution:");

    swprintf(buffer, L"ICB rate schedule: %d", aInputs.mICBScheduleID);
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

    swprintf(buffer, L"Product offering rate schedule: %d", aInputs.mPOScheduleID);
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

    swprintf(buffer, L"Default account rate schedule: %d",
             aInputs.mDefaultAccountScheduleID);
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
  }

  if (mApplyRates)
  {
    if (!aParameterTable.IsWeightedRate())
    {
      // normal rating
      BOOL bSuccess;
      PCRater::RateUsed rateUsed;

      try
      {
        //bSuccess = mRater.Rate(aSession, aInputs, rateUsed);
        bSuccess = mRater.Rate(aSession, aInputs, rateUsed);
      }
      catch (_com_error err)
      {
        if (err.Error() == PIPE_ERR_INVALID_PROPERTY)
        {
          aSession->MarkAsFailed(err.Description(), PIPE_ERR_INVALID_PROPERTY);
          return PIPE_ERR_INVALID_PROPERTY;
        }
        else
        {
          aSession->MarkAsFailed(err.Description(), err.Error());
          return ReturnComError(err);
        }
      }
      catch(MTException& e) 
      {
        _bstr_t buffer = e.what();
        aSession->MarkAsFailed(buffer, (HRESULT)e);
        return (HRESULT)e;
      }

      if (!bSuccess)
      {
        _bstr_t paramTableName = aParameterTable.GetParamTableName();

        //CR 12905: it's not nesessarily PIPE_ERR_NO_RULES_MATCH
        //check error object
        const ErrorObject* e = mRater.GetLastError();

        // Make sure the error is logged
        if (e != NULL)
        {
            string errorMessage = "BatchPCRatePlugIn::PlugInProcessSessionPostQuery(): " + e->GetProgrammerDetail();
            mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, errorMessage.c_str());
        }

        //PIPE_ERR_INTERNAL_ERROR is set by Rate() and WeightedRate() for rating specific errors
        if(e != NULL && e->GetCode() != PIPE_ERR_INTERNAL_ERROR)
        {
          char buffer[1024];
          buffer[sizeof(buffer)-1] = '\0';
          string msg = e->GetProgrammerDetail();
          _snprintf(buffer, sizeof(buffer)-1, "Error rating session: '%s'", msg.c_str());
          aSession->MarkAsFailed(_bstr_t(buffer), E_FAIL);
          return E_FAIL;
        }
        else
        {
          int defaultPL = aSession->GetLongProperty(mAccountPriceListPropID);

          wchar_t buffer[1024];
          int i;
          i  = swprintf( buffer, L"No rules matched on rate schedules for this paramtable: ");
          if (aInputs.mICBScheduleID!=-1)
            i += swprintf( buffer + i, L"ICB Rate Schedule [%d] ", aInputs.mICBScheduleID);
          if (aInputs.mPOScheduleID!=-1)
            i += swprintf( buffer + i, L"PO Rate Schedule [%d] ", aInputs.mPOScheduleID);
          if (aInputs.mDefaultAccountScheduleID!=-1)
            i += swprintf( buffer + i, L"Default Account Pricelist [%d] Rate Schedule [%d] ", defaultPL, aInputs.mDefaultAccountScheduleID);

          int accountID = aSession->GetLongProperty(mAccountPropID);

          long now = (long) aSession->GetDateTimeProperty(mTimestampPropID);
          string strDate;
          MTFormatISOTime(now, strDate);
          _bstr_t bstrDate = strDate.c_str();

          long piTemplateID = aSession->GetLongProperty(mPriceableItemTemplatePropID);

          _bstr_t piTemplateName;
          LookupPITemplateName(piTemplateName, piTemplateID);


          i += swprintf(buffer + i, L" - account ID: %d (default PL=%d), pi template: %s, param table: %s, date: %s",
            accountID, defaultPL, (const wchar_t *) piTemplateName,
            (const wchar_t *) paramTableName,
            (const wchar_t *) bstrDate);
          aSession->MarkAsFailed(buffer, PIPE_ERR_NO_RULES_MATCH);
          return PIPE_ERR_NO_RULES_MATCH;
        }

        
      }

      if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
      {
        wchar_t buffer[256];

        switch (rateUsed)
        {
        case PCRater::RATE_USED_ICB:
          swprintf(buffer, L"ICB rate schedule used: %d", aInputs.mICBScheduleID);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
          break;
        case PCRater::RATE_USED_PO:
          swprintf(buffer, L"Product offering rate schedule used: %d", aInputs.mPOScheduleID);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
          break;
        case PCRater::RATE_USED_DEFAULT_ACCOUNT:
          swprintf(buffer, L"Default account rate schedule used: %d",
                   aInputs.mDefaultAccountScheduleID);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
          break;
        default:
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
                             L"Unknown rate schedule used!");
          break;
        }
      }
    }
    else
    {
      MTDecimal start = aSession->GetDecimalProperty(aParameterTable.GetStartAtID());
      MTDecimal insession = aSession->GetDecimalProperty(aParameterTable.GetInSessionID());
      MTDecimal end = start + insession;
      
      // weighted rating
      BOOL bSuccess;
      CachedRateSchedule::IndexedRulesVector splitResults;

      try
      {
        bSuccess = mRater.WeightedRate(aSession, aInputs,
                                       aParameterTable.GetWeightOnKeyID(),
                                       start, end, splitResults);
      }
      catch (_com_error err)
      {
        if (err.Error() == PIPE_ERR_INVALID_PROPERTY)
        {
          aSession->MarkAsFailed(err.Description(), PIPE_ERR_INVALID_PROPERTY);
          return PIPE_ERR_INVALID_PROPERTY;
        }
        else
        {
          aSession->MarkAsFailed(err.Description(), err.Error());
          return ReturnComError(err);
        }
      }

      if (!bSuccess)
      {

        //CR 12905: it's not nesessarily PIPE_ERR_NO_RULES_MATCH
        //check error object
        const ErrorObject* e = mRater.GetLastError();

        // Make sure the error is logged
        if (e != NULL)
        {
            string errorMessage = "BatchPCRatePlugIn::PlugInProcessSessionPostQuery(): " + e->GetProgrammerDetail();
            mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, errorMessage.c_str());
        }

        //PIPE_ERR_INTERNAL_ERROR is set by Rate() and WeightedRate() for rating specific errors
        if(e != NULL && e->GetCode() != PIPE_ERR_INTERNAL_ERROR)
        {
          char buffer[1024];
          buffer[sizeof(buffer)-1] = '\0';
          string msg = e->GetProgrammerDetail();
          _snprintf(buffer, sizeof(buffer)-1, "Error rating session: '%s'", msg.c_str());
          aSession->MarkAsFailed(_bstr_t(buffer), E_FAIL);
          return E_FAIL;
        }
        else
        {

          std::string err;
          std::string msg;
          std::string prefix = "None of the aggregate rating conditions matched: ";
          StringFromError(err, prefix.c_str(), mRater.GetLastError() );
          msg = prefix + mRater.GetLastError()->GetProgrammerDetail();
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, msg.c_str());

          aSession->MarkAsFailed(_bstr_t(msg.c_str()), PIPE_ERR_NO_RULES_MATCH);
          return PIPE_ERR_NO_RULES_MATCH;
        }
      }
      
      if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
      {
        char buffer[512];
        buffer[sizeof(buffer)-1] = '\0';
        for (int i = 0; i < (int) splitResults.size(); i++)
        {
          MTautoptr<IndexedRules>  indexEntry = splitResults[i];
          MTDecimal start = indexEntry->mStart;
          MTDecimal end = indexEntry->mEnd;
          
          _snprintf(buffer, sizeof(buffer)-1, "  range: %s to %s", start.Format().c_str(),
                  end.Format().c_str());
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
        }
        
        MTDecimal rate = aSession->GetDecimalProperty(aParameterTable.GetWeightOnKeyID());
        
        _snprintf(buffer, sizeof(buffer)-1, "resulting rate: %s", rate.Format().c_str());
        
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
      }
    }
  }

  return S_OK;
}


void BatchPCRatePlugIn::LookupPITemplateName(_bstr_t & arTemplateName,
                                             int piTemplateID)
{
  const SubPI * piInfo = mPICache.FindPITemplate(piTemplateID);
  ASSERT(piInfo);
  if (!piInfo)
    MT_THROW_COM_ERROR("Unable to retrieve priceable item template name");

  arTemplateName = piInfo->GetName();
}



HRESULT BatchPCRatePlugIn::BatchPlugInInitializeDatabase()
{
  // this is a read-only plugin, so retry is safe
  AllowRetryOnDatabaseFailure(TRUE);

  mLookup.Initialize(mLogger, mResolveSub ? true : false, (const char *) mTagName);

  return S_OK;
}


HRESULT BatchPCRatePlugIn::BatchPlugInShutdownDatabase()
{
  mLookup.Shutdown();

  return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// BatchPlugInProcessSessions
/////////////////////////////////////////////////////////////////////////////
HRESULT BatchPCRatePlugIn::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet)
{
  MarkRegion region("BatchPCRate");

  mResolveRateSchedulesTicks = 0;
  mResolvePriceableItemTemplateTicks = 0;
  mPostQueryTicks = 0;
  mTruncateTableTicks = 0;
  mInsertTempTableTicks = 0;
  mSelectRateSchedulesTicks = 0;

  CMTSessionSetBase* pSsBase;
  CMTSessionSet* pSs;
  HRESULT hr;

  hr = aSessionSet->QueryInterface(IID_NULL,(void**)&pSs);
  if(FAILED(hr)) 
  {
    ASSERT(false);
  }
  pSs->GetSessionSet(&pSsBase);
  ASSERT(pSsBase != NULL);
  
  __int64 currentFetchTicks = mTotalFetchTicks;

  LARGE_INTEGER freq;
  LARGE_INTEGER tick;
  LARGE_INTEGER tock;
  ::QueryPerformanceFrequency(&freq);
  
  ::QueryPerformanceCounter(&tick);

  // get the DTC txn to be joined
  // The DTC txn is owned by the MTObjectOwner and shared among all sessions in the session set.
  // if null, no transaction has been started yet.
  MTPipelineLib::IMTTransactionPtr transaction;
  mTransaction = NULL;
  bool first = true;

  int totalRecords=0;
  vector<MTautoptr<CMTSessionBase> > sessionArray;
  long pos = 0;
  //SetIterator<CMTSessionSetBase*, CMTSession*> it;
  std::auto_ptr<CMTVariantSessionEnumBase> it(pSsBase->get__NewEnum());

  
  //seems like First() is needed
  bool more = true;
  CMTSessionBase* raw = NULL;
  
  while (more == true)
  {
    MTautoptr<CMTSessionBase> session;
    
    if (first)
    {
      //BP TODO: if we fail in First() after addref was done - we leak shared session. Unlikely though
      more = it->First(pos, &raw);
      if (more)
      {
        session = raw;
        // Save the session so we can pass around sets for processing
        sessionArray.push_back(session);
      }
      else
        break;

      first = false;

      // Get the txn from the first session in the set.
      // don't begin a new transaction unless 
      transaction = GetTransaction(&session);

      if (transaction != NULL)
      {
        ITransactionPtr itrans = transaction->GetTransaction();
        ASSERT(itrans != NULL);
        mTransaction = itrans;
      }

      // get the rate schedule cache from the object owner

      // work up to the root session
      //careful here. This code seems confusing
      //but this is because GetSession() does AddRef().
      //We only want to assign to an autoptr if GetSession()
      //was actually called. Otherwise - either premature release or leak
      CMTSessionBase* root = session;
      MTautoptr<CMTSessionBase> rootPtr;
      while (root->get_ParentID() != -1)
      {
        root = mpSessionServerBase->GetSession(root->get_ParentID());
        rootPtr = root;
      }

      int objectOwnerID = root->get_ObjectOwnerID();

      ASSERT(objectOwnerID != -1);
      if (objectOwnerID == -1)
        // should never happen
        return Error("Invalid object owner");

      // getting and setting the rate schedule ID is protected in a
      // critical section.  More than one stage could be trying to access
      // this object at one time.
      {
        AutoCriticalSection autolock(&mCacheInitLock);

        MTautoptr<CMTObjectOwnerBase> objectOwner =
          mpSessionServerBase->GetObjectOwner(objectOwnerID);

        // The call to get_RSIDCache() has already AddRef'd.
        mRSIDCacheRef.Attach(objectOwner->get_RSIDCache(), false);

        if (mRSIDCacheRef == 0)
        {
          // doesn't exist yet - create it
          RSIDCache * cache = new RSIDCache();

          // magically transform into a COM object
          mRSIDCacheRef = cache;

          mpRSIDCache = cache;

          objectOwner->put_RSIDCache(cache);
        }
        else
        {
          mpRSIDCache = (RSIDCache *) (IUnknown *) mRSIDCacheRef;
        }
      }
    }//first
    else
    {
      //BP TODO: if we fail in Next() after addref was done - we leak shared session
      more = it->Next(pos, &raw);
      if(more)
      {
      session = raw;
      // Save the session so we can pass around sets for processing
      sessionArray.push_back(session);
      }
    }
    totalRecords++;

    
    // If we have a full array of stuff, do the exectue
    if (sessionArray.size() >= (unsigned int) mArraySize)
    {
      ASSERT(sessionArray.size() == (unsigned int) mArraySize);
      HRESULT hr;
      hr = ResolveBatch(sessionArray);
      if (!SUCCEEDED(hr)) return hr;
      sessionArray.clear();
    }
    
  }// while

  // Process any stragglers
  if(sessionArray.size() > 0)
  {
    HRESULT hr;
    hr = ResolveBatch(sessionArray);
    if (!SUCCEEDED(hr)) return hr;
  }

  // Commit, print timings and general cleanup
  mTransaction = NULL;
  mRSIDCacheRef = NULL;
  mpRSIDCache = NULL;

  ::QueryPerformanceCounter(&tock);

  char buf[1024];
  buf[sizeof(buf) - 1] = '\0';
  _snprintf(buf, sizeof(buf)-1, "BatchPCRate::PlugInProcessSessions for %d records took %d milliseconds\n"
          "\tResolvePriceableItemTemplate %g ms\n"
          "\tResolveRateSchedules %g ms\n"
          "\t\tTruncate Table %g ms\n"
          "\t\tInsert Temp Table %g ms\n"
          "\t\tSelect Rate Schedules %g ms\n"
          "\tRateCalculation %g ms", 
          totalRecords, 
          (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart),
          (double) ((1000.0*(mResolvePriceableItemTemplateTicks))/freq.QuadPart),
          (double) ((1000.0*(mResolveRateSchedulesTicks))/freq.QuadPart),
          (double) ((1000.0*(mTruncateTableTicks))/freq.QuadPart),
          (double) ((1000.0*(mInsertTempTableTicks))/freq.QuadPart),
          (double) ((1000.0*(mSelectRateSchedulesTicks))/freq.QuadPart),
          (double) ((1000.0*(mPostQueryTicks))/freq.QuadPart)
    );

  mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));

#if 0
  sprintf(buf, "BatchPCRate::SQLExecute for %d records took %g milliseconds", 
          totalRecords, mStatement->GetTotalExecuteMillis() - mTotalMillis);
  mTotalMillis = mStatement->GetTotalExecuteMillis();
  mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
#endif    

  return S_OK;
}

MTPipelineLib::IMTTransactionPtr BatchPCRatePlugIn::GetTransaction(CMTSessionBase* aSession)
{
  // has a transaction already been started?
  // Take care not AddRef when attaching to raw COM pointer.
  MTPipelineLib::IMTTransactionPtr tran(aSession->GetTransaction(false), false);

  if (tran != NULL)
  {
    // yes
    ITransactionPtr itrans = tran->GetTransaction();
    if (itrans != NULL)
      return tran;
    else
      return NULL;
  }

  // is the transaction ID set in the session?  If so we're working on
  // an external transaction
  _bstr_t txnID = aSession->GetTransactionID();
  if (txnID.length() > 0)
  {
    // join the transaction
    tran = aSession->GetTransaction(true);

    ITransactionPtr itrans = tran->GetTransaction();
    if (itrans != NULL)
      return tran;
    else
      return NULL;
  }

  // no transaction
  return NULL;
}


