 /**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 2004 by MetraTech Corporation
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
 * Created by: Marc Guyott
 *
 * $Date: 9/10/2004 5:44:54 PM$
 * $Author: Marc Guyott$
 * $Revision: 1$
 ***************************************************************************/

#include <mtcom.h>
#include <mtprogids.h>
#include <BatchPlugInSkeleton.h>
#include <DBConstants.h>
#include <base64.h>
#include <MTUtil.h>
#include <propids.h>

#include <MTObjectCollection.h>
#include <AccHierarchiesShared.h>
#include <mttime.h>
#include <formatdbvalue.h>
#include <mtcomerr.h>
#include <MTTypeConvert.h>
#include <MTDate.h>
#include <MTSubInfo.h>

#include <OdbcException.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcResultSet.h>
#include <OdbcConnMan.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcResourceManager.h>

#include <vector>
using namespace std;

#import <MTEnumConfigLib.tlb> 

#import "MTProductCatalog.tlb" rename ("EOF", "RowsetEOF")
#import <GenericCollection.tlb>

#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")

typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcResultSet> COdbcResultSetPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;
typedef vector<MTPipelineLib::IMTSessionPtr> MTSessionArray;
typedef MTautoptr<MTSessionArray> MTSessionArrayPtr;

// Map used to check which sessions failed.
typedef std::map<long, MTSessionArrayPtr> AccountIDToSessionsMap;

#import <RowSetInterfacesLib.tlb> rename ("EOF", "RowsetILIBEOF")
using namespace RowSetInterfacesLib;

// Specify the default batch size to use for processing batch records.
#define DEFAULT_BCP_BATCH_SIZE 1250

// Specify the location of the file we will load our SQL statements from.
#define QUERY_ADAPTER_QUERY_PATH (L"\\Queries\\AccHierarchies")

// Generated using uuidgen.
CLSID CLSID_BATCHSUBSCRIPTION =  /* AD96AC6A-FD77-42d8-A6E7-3F6BAE7FD300 */
{
    0xAD96AC6A,
    0xFD77,
    0x42d8,
    {0xA6, 0xE7, 0x3F, 0x6B, 0xAE, 0x7F, 0xD3, 0x00} 
};

class ATL_NO_VTABLE BatchSubscriptionPlugIn : 
  public MTBatchPipelinePlugIn<BatchSubscriptionPlugIn, &CLSID_BATCHSUBSCRIPTION>
{
public:

  // Default Constructor
  BatchSubscriptionPlugIn()
  { }

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
  virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSetPtr);

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

  HRESULT GetSubscriptions(AccountIDToSessionsMap& sessionsMap,
                           MTPipelineLib::IMTSessionSetPtr& sessionSetPtr,
                           MTObjectCollection<MTPRODUCTCATALOGLib::IMTSubInfo>& indSubs,
                           MTObjectCollection<MTPRODUCTCATALOGLib::IMTSubInfo>& grpSubs);

  HRESULT ResolveBatch(AccountIDToSessionsMap& sessionsMap,
                       MTSessionArray& sessionArray,
                       MTPipelineLib::IMTSQLRowsetPtr& rowset,
                       MTObjectCollection<MTPRODUCTCATALOGLib::IMTSubInfo>& indSubs,
                       MTObjectCollection<MTPRODUCTCATALOGLib::IMTSubInfo>& grpSubs);
  template <class T>
  HRESULT InsertIntoTmpTable(AccountIDToSessionsMap& sessionsMap,
                             MTSessionArray& sessionArray,
                             T insertStmtPtr);

  HRESULT GenerateQueries(BOOL bIsOracle,
                          const char* stagingDBName);

private:

  long mlAccountIDID;
  long mlAccountEndDateID;
  long mlAccountStartDateID;
  long mlAccountTypeID;
  long mlActionTypeID;
  long mlAncestorAccountIDID;
  long mlCorporateAccountIDID;
  long mlApplyAccountTemplateID;
  long mlOperationID;
  long mcansubscribeID;
  long miscorporateID;
  long macc_type_id;
  long mb_CanParticipateInGSubID;

  MTPipelineLib::IMTLogPtr mLogger;
  bool                     mOkToLogDebugInfo;

  MTPipelineLib::IMTLogPtr mPerfLogger;
  bool                     mOkToLogPerfInfo;

  QUERYADAPTERLib::IMTQueryAdapterPtr       mQueryAdapter;
  MTENUMCONFIGLib::IEnumConfigPtr           mEnumConfig;
  MTPRODUCTCATALOGLib::IMTProductCatalogPtr mProductCatalog;

  MTAutoSingleton<COdbcResourceManager>                  mOdbcManager;
  boost::shared_ptr<COdbcConnectionCommand>              mConnectionCommand;     // For temp table manipulations.
  boost::shared_ptr<COdbcPreparedBcpStatementCommand>    mBcpInsertToTmpTableStmtCommand;
  boost::shared_ptr<COdbcPreparedInsertStatementCommand> mOracleArrayInsertToTmpTableStmtCommand;
  boost::shared_ptr<COdbcPreparedArrayStatementCommand>  mSqlArrayInsertToTmpTableStmtCommand;

  BOOL        mUseBcpFlag;
  int         mArraySize;
  BOOL        mIsOracle;
  bool        mbSessionsFailed;

  string mTmpTmplTableName;           // Set in GenerateQueries().
  string mTmpTmplTableFullName;       // Set in GenerateQueries().
  string mTagName;

  string  mTmpTmplTableCreateSQL;     // Set in GenerateQueries().
  string  mTmpTmplTableTruncateSQL;   // Set in GenerateQueries().
  string  mTmpTmplTableInsertSQL;     // Set in GenerateQueries().
  _bstr_t mTmpTmplTableGetResultsSQL; // Set in GenerateQueries().
  _bstr_t mTmpSubsTableGetResultsSQL; // Set in GenerateQueries().
  _bstr_t mTmpTmplTableSetTemplateIDSQL; // Set in GenerateQueries().
  
  
  __int64 mGetSubscriptionsTicks;
};

PLUGIN_INFO(CLSID_BATCHSUBSCRIPTION, 
            BatchSubscriptionPlugIn,
            "MetraPipeline.Subscription.1", 
            "MetraPipeline.Subscription", "Free")

/////////////////////////////////////////////////////////////////////////////
// BatchPlugInConfigure
/////////////////////////////////////////////////////////////////////////////
HRESULT
BatchSubscriptionPlugIn::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr           aLoggerPtr,
                                              MTPipelineLib::IMTConfigPropSetPtr aPropSetPtr,
                                              MTPipelineLib::IMTNameIDPtr        aNameIDPtr,
                                              MTPipelineLib::IMTSystemContextPtr aSysContextPtr)
{
  const char* procName = "BatchSubscriptionPlugIn::BatchPlugInConfigure";

  mLogger = aLoggerPtr;
  mOkToLogDebugInfo = ((mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG)) == VARIANT_TRUE);

  mPerfLogger = MTPipelineLib::IMTLogPtr(MTPROGID_LOG);
  mPerfLogger->Init("logging\\perflog", "[BatchSubscription]");
  mOkToLogPerfInfo = ((mPerfLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG)) == VARIANT_TRUE);

  mQueryAdapter.CreateInstance(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
  mQueryAdapter->Init(QUERY_ADAPTER_QUERY_PATH);

  if (aPropSetPtr->NextMatches(L"usebcpflag", MTPipelineLib::PROP_TYPE_BOOLEAN))
    mUseBcpFlag = aPropSetPtr->NextBoolWithName(L"usebcpflag") == VARIANT_TRUE;
  else
    mUseBcpFlag = TRUE;

  if (aPropSetPtr->NextMatches(L"batch_size", MTPipelineLib::PROP_TYPE_INTEGER))
    mArraySize = aPropSetPtr->NextLongWithName("batch_size");
  else
    mArraySize = DEFAULT_BCP_BATCH_SIZE;

  DECLARE_PROPNAME_MAP(inputs)
    DECLARE_PROPNAME("AccountID",            &mlAccountIDID)
    DECLARE_PROPNAME("AccountEndDate",       &mlAccountEndDateID)
    DECLARE_PROPNAME("AccountStartDate",     &mlAccountStartDateID)
    DECLARE_PROPNAME("AccountType",          &mlAccountTypeID)
    DECLARE_PROPNAME("ActionType",           &mlActionTypeID)
    DECLARE_PROPNAME("AncestorAccountID",    &mlAncestorAccountIDID)
    DECLARE_PROPNAME("CorporateAccountID",   &mlCorporateAccountIDID)
    DECLARE_PROPNAME("ApplyAccountTemplate", &mlApplyAccountTemplateID)
    DECLARE_PROPNAME("Operation",            &mlOperationID)
    DECLARE_PROPNAME("b_cansubscribe",       &mcansubscribeID)
    DECLARE_PROPNAME("b_IsCorporate",        &miscorporateID)
    DECLARE_PROPNAME("acc_type_id",          &macc_type_id)
    DECLARE_PROPNAME("b_CanParticipateInGSub", &mb_CanParticipateInGSubID)
  END_PROPNAME_MAP
    
  HRESULT hr = ProcessProperties(inputs, aPropSetPtr, aNameIDPtr, aLoggerPtr, procName);
  if (!SUCCEEDED(hr))
    return hr;

  PipelinePropIDs::Init();

  mTagName = GetTagName(aSysContextPtr);

  try
  {
    // get enum config pointer from system context
    mEnumConfig = aSysContextPtr->GetEnumConfig();
    _ASSERTE(mEnumConfig != NULL);

    mProductCatalog.CreateInstance(MTPROGID_MTPRODUCTCATALOG);
    _ASSERTE(mProductCatalog != NULL);
  }
  catch(_com_error& e)
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Failed to acquire the needed interfaces and/or capabilities");
    return ReturnComError(e);
  }

  COdbcConnectionInfo stageDBInfo  = COdbcConnectionManager::GetConnectionInfo("NetMeter");
  COdbcConnectionInfo stageDBEntry = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
  stageDBInfo.SetCatalog(stageDBEntry.GetCatalog().c_str());

  mIsOracle = (stageDBInfo.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);

  if (mIsOracle)
    mUseBcpFlag = FALSE;

  if (mOkToLogDebugInfo)
  {
    if (mUseBcpFlag)
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BatchSubscription will use BCP");
    else
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BatchSubscription will not use BCP");

    char tmpBuf[128];
    sprintf(tmpBuf, "BatchSubscription will use a batch size of %d", mArraySize);
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, tmpBuf);
  }

  // Use auto commit only if using BCP.
  //mConnection->SetAutoCommit(mUseBcpFlag ? true : false);


  GenerateQueries(mIsOracle, stageDBInfo.GetCatalog().c_str());

  // Prepare temp table insert query.
  std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpStatements;
  std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayStatements;
  std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertStatements;
  if (mUseBcpFlag)
  {
    COdbcBcpHints hints;
    // use minimally logged inserts.
    // TODO: this may only matter if database recovery model settings are correct.
    //       however, it won't hurt if they're not
    hints.SetMinimallyLogged(true);
    mBcpInsertToTmpTableStmtCommand = boost::shared_ptr<COdbcPreparedBcpStatementCommand>(
      new COdbcPreparedBcpStatementCommand(mTmpTmplTableFullName, hints));
    bcpStatements.push_back(mBcpInsertToTmpTableStmtCommand);
  } 
  else
  {
    if (mIsOracle)
    {
      mOracleArrayInsertToTmpTableStmtCommand = boost::shared_ptr<COdbcPreparedInsertStatementCommand> (
        new COdbcPreparedInsertStatementCommand(mTmpTmplTableName, mArraySize, true));
      insertStatements.push_back(mOracleArrayInsertToTmpTableStmtCommand);
    }
    else
    {
      mSqlArrayInsertToTmpTableStmtCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(
        new COdbcPreparedArrayStatementCommand(mTmpTmplTableInsertSQL, mArraySize, true));
      arrayStatements.push_back(mSqlArrayInsertToTmpTableStmtCommand);
    }
  }

  mConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
    new COdbcConnectionCommand(stageDBInfo,
                               COdbcConnectionCommand::TXN_AUTO,
                               bcpStatements.size() > 0,
                               bcpStatements,
                               arrayStatements,
                               insertStatements));

  mOdbcManager->RegisterResourceTree(mConnectionCommand);

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// BatchPlugInInitializeDatabase
/////////////////////////////////////////////////////////////////////////////
HRESULT
BatchSubscriptionPlugIn::BatchPlugInInitializeDatabase()
{
  const char* procName = "BatchSubscriptionPlugIn::BatchPlugInInitializeDatabase";
        BOOL  isOracle = FALSE;

  // This plug-in writes to the database so we should not allow retry.
  AllowRetryOnDatabaseFailure(FALSE);

  if (true)//!mIsOracle)
  {
    // Make sure our "temporary" tables exist and are empty.
    COdbcConnectionInfo stageDBInfo  = COdbcConnectionManager::GetConnectionInfo("NetMeter");
    COdbcConnectionInfo stageDBEntry = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
    stageDBInfo.SetCatalog(stageDBEntry.GetCatalog().c_str());
    COdbcConnectionPtr conn(new COdbcConnection(stageDBInfo));
    COdbcStatementPtr createTmpTableStmt = conn->CreateStatement();
    createTmpTableStmt->ExecuteUpdate(mTmpTmplTableCreateSQL);
    conn->CommitTransaction();
  }

  return S_OK;
}

// This handles making sure the product catalog disassociates itself from
// the session context of the session set.
class AutoSetSessionContext
{
private:
  MTPRODUCTCATALOGLib::IMTProductCatalogPtr mProductCatalog;
public:
  AutoSetSessionContext(MTPipelineLib::IMTSessionContextPtr sessCtx, MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc)
    :
    mProductCatalog(pc)
  {
    mProductCatalog->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(sessCtx.GetInterfacePtr()));
  }
  ~AutoSetSessionContext()
  {
    MTPRODUCTCATALOGLib::IMTSessionContextPtr nullPtr;
    mProductCatalog->SetSessionContext(nullPtr);
  }
};

/////////////////////////////////////////////////////////////////////////////
// BatchPlugInProcessSessions
/////////////////////////////////////////////////////////////////////////////
HRESULT 
BatchSubscriptionPlugIn::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSetPtr)
{
  const char* procName = "BatchSubscriptionPlugIn::BatchPlugInProcessSessions";

  HRESULT hr = S_OK;

  LARGE_INTEGER freq;
  LARGE_INTEGER tick;
  LARGE_INTEGER tick2;

  if (mOkToLogPerfInfo)
  {
    // Initialize performance counters.
    mGetSubscriptionsTicks = 0;

    ::QueryPerformanceFrequency(&freq);
    ::QueryPerformanceCounter(&tick);
    ::QueryPerformanceCounter(&tick2);
  }

  // Clear map in preparation for new session set.
  AccountIDToSessionsMap sessionsMap;
  sessionsMap.clear();

  //
  SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
  hr = it.Init(aSessionSetPtr);
  if (FAILED(hr))
    return hr;

  mbSessionsFailed = false;

  MTPipelineLib::IMTSessionPtr firstSession = NULL;

  firstSession = it.GetNext();
  if (firstSession == NULL)
  {
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "No sessions found in the session set.");
      return S_OK;
  }

  MTPipelineLib::IMTSessionContextPtr sessCtx = firstSession->GetSessionContext();
  AutoSetSessionContext autoSetSessionContext(sessCtx, mProductCatalog);

  MTPipelineLib::IMTTransactionPtr mtTransactionPtr = NULL;
  ITransactionPtr                  transactionPtr   = NULL;

  // Get the txn from the first session in the set.
  mtTransactionPtr = GetTransaction(firstSession);
  if (mtTransactionPtr != NULL)
  {
    transactionPtr = mtTransactionPtr->GetTransaction();
    ASSERT(transactionPtr != NULL);
  }

  MTObjectCollection<MTPRODUCTCATALOGLib::IMTSubInfo> indSubs;
  MTObjectCollection<MTPRODUCTCATALOGLib::IMTSubInfo> grpSubs;

  hr = GetSubscriptions(sessionsMap, aSessionSetPtr, indSubs, grpSubs);
  if (FAILED(hr))
    return hr;

  if (mOkToLogPerfInfo)
  {
    LARGE_INTEGER tock;

    ::QueryPerformanceCounter(&tock);
    mGetSubscriptionsTicks += (tock.QuadPart - tick2.QuadPart);
  }

  long count;
  grpSubs.Count(&count);

  if (count > 0)
  {
    MTPRODUCTCATALOGLib::IMTRowSetPtr errorRs;

    MTPRODUCTCATALOGLib::IMTCollectionPtr grpSubsPtr;
    grpSubs.CopyTo((IMTCollection **)&grpSubsPtr);

    errorRs = mProductCatalog->SubscribeToGroups(grpSubsPtr, NULL, NULL,
                          _variant_t(reinterpret_cast<IUnknown*>(transactionPtr.GetInterfacePtr())));

    if (errorRs->GetRecordCount() > 0)
    {
      _variant_t value;

      long    id_acc = -1;
      wstring nm_acc;
      wstring err_desc;
      wstring message;

      while(errorRs->GetRowsetEOF().boolVal == VARIANT_FALSE)
      {
        try
        {
          value = errorRs->GetValue("id_acc");
          ASSERT((value.vt == VT_I2) || (value.vt == VT_I4));
          id_acc = long(value);

          value = errorRs->GetValue("accountname");
          ASSERT(value.vt == VT_BSTR);
          nm_acc = value.bstrVal;

          value = errorRs->GetValue("description");
          ASSERT(value.vt == VT_BSTR);
          err_desc = value.bstrVal;

          wchar_t numBuf[32];
          swprintf(numBuf, L"%ld", id_acc);

          message = L"Add ";
          message += nm_acc;
          message += L" (";
          message += numBuf;
          message += L") to group sub failed: ";
          message += err_desc;

          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message.c_str());

          // Mark the failed sessions.
          // Are there any sessions associated with current account?
          AccountIDToSessionsMap::iterator it = sessionsMap.find(id_acc);
          if (it != sessionsMap.end())
          {
            // There are, since we don't know exactly which failed, mark them all as failed.
            // Under normal conditions there should only be one.
            MTSessionArrayPtr sessionsArray = it->second;
            for (MTSessionArray::const_iterator it = sessionsArray->begin(); it != sessionsArray->end(); it++)
            {
              _bstr_t errDesc(message.c_str());
              MTPipelineLib::IMTSessionPtr session = *it;
              session->MarkAsFailed(errDesc.length() > 0 ? errDesc : L"", PIPE_ERR_INVALID_SESSION);
              mbSessionsFailed = true;
            }
          }
        }
        catch (_com_error& err)
        {
          _bstr_t message = err.Description();
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
          return ReturnComError(err);
        }

        errorRs->MoveNext();
      }
    }
  }

  indSubs.Count(&count);

  if (count > 0)
  {
    MTPRODUCTCATALOGLib::IMTRowSetPtr errorRs;

    MTPRODUCTCATALOGLib::IMTCollectionPtr indSubsPtr;
    indSubs.CopyTo((IMTCollection **)&indSubsPtr);

    errorRs = mProductCatalog->SubscribeAccounts(indSubsPtr, NULL, NULL,
                          _variant_t(reinterpret_cast<IUnknown*>(transactionPtr.GetInterfacePtr())));

    if (errorRs->GetRecordCount() > 0)
    {
      _variant_t value;

      long    id_acc = -1;
      wstring nm_acc;
      wstring err_desc;
      wstring message;

      while(errorRs->GetRowsetEOF().boolVal == VARIANT_FALSE)
      {
        try
        {
          value = errorRs->GetValue("id_acc");
          ASSERT((value.vt == VT_I2) || (value.vt == VT_I4));
          id_acc = long(value);

          value = errorRs->GetValue("accountname");
          ASSERT(value.vt == VT_BSTR);
          nm_acc = value.bstrVal;

          value = errorRs->GetValue("description");
          ASSERT(value.vt == VT_BSTR);
          err_desc = value.bstrVal;

          wchar_t numBuf[32];
          swprintf(numBuf, L"%ld", id_acc);

          message = L"Create individual sub for ";
          message += nm_acc;
          message += L" (";
          message += numBuf;
          message += L") failed: ";
          message += err_desc;

          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message.c_str());

          // Mark the failed sessions.
          // Are there any sessions associated with current account?
          AccountIDToSessionsMap::iterator it = sessionsMap.find(id_acc);
          if (it != sessionsMap.end())
          {
            // There are, since we don't know exactly which failed, mark them all as failed.
            // Under normal conditions there should only be one.
            MTSessionArrayPtr sessionsArray = it->second;
            for (MTSessionArray::const_iterator it = sessionsArray->begin(); it != sessionsArray->end(); it++)
            {
              _bstr_t errDesc(message.c_str());
              MTPipelineLib::IMTSessionPtr session = *it;
              session->MarkAsFailed(errDesc.length() > 0 ? errDesc : L"", PIPE_ERR_INVALID_SESSION);
              mbSessionsFailed = true;
            }
          }
        }
        catch (_com_error& err)
        {
          _bstr_t message = err.Description();
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
          return ReturnComError(err);
        }

        errorRs->MoveNext();
      }
    }
  }

  if (mOkToLogPerfInfo)
  {
    LARGE_INTEGER tock;

    ::QueryPerformanceCounter(&tock);

    // Overall performance statistic.
    char buf[256];
    long ms = (long) ((1000 * (tock.QuadPart - tick.QuadPart)) / freq.QuadPart);
    sprintf(buf, "BatchAccountTableCreationPlugIn::PlugInProcessSessions for %d records took %d milliseconds.", aSessionSetPtr->Count, ms);
    mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);

    // Get the two collections of subscriptions statistic.
    ms = (long) (1000 * mGetSubscriptionsTicks / freq.QuadPart);
    sprintf(buf, "BatchAccountTableCreationPlugIn::TruncateTmpTable took %d milliseconds.", ms);
    mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
  }

  if (mbSessionsFailed)
    return PIPE_ERR_SUBSET_OF_BATCH_FAILED;

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// BatchPlugInShutdown
/////////////////////////////////////////////////////////////////////////////
HRESULT
BatchSubscriptionPlugIn::BatchPlugInShutdown()
{
  const char* procName = "BatchSubscriptionPlugIn::BatchPlugInShutdown";

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// BatchPlugInShutdownDatabase
/////////////////////////////////////////////////////////////////////////////
HRESULT
BatchSubscriptionPlugIn::BatchPlugInShutdownDatabase()
{
  const char* procName = "BatchSubscriptionPlugIn::BatchPlugInShutdownDatabase";

  mOdbcManager->Reinitialize(mConnectionCommand);
  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// GetSubscriptions
/////////////////////////////////////////////////////////////////////////////
HRESULT 
BatchSubscriptionPlugIn::GetSubscriptions(AccountIDToSessionsMap& sessionsMap,
                                          MTPipelineLib::IMTSessionSetPtr& sessionSetPtr,
                                          MTObjectCollection<MTPRODUCTCATALOGLib::IMTSubInfo>& indSubs,
                                          MTObjectCollection<MTPRODUCTCATALOGLib::IMTSubInfo>& grpSubs)
{
  const char* procName = "BatchSubscriptionPlugIn::GetSubscriptions";

  HRESULT hr = S_OK;

  try
  {
    MTPipelineLib::IMTSessionPtr         curSession     = NULL;
    MTPipelineLib::IMTSQLRowsetPtr       rowset         = NULL;
    bool                                 isFirstSession = true;
    MTSessionArray sessionArray;

    SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
    hr = it.Init(sessionSetPtr);
    if (FAILED(hr))
      return hr;

    ITransactionPtr pITransaction;

    while (TRUE)
    {
      curSession = it.GetNext();
      if (curSession == NULL)
        break;

      if (isFirstSession)
      {
        // Get the rowset from the first session in the set.
        // This rowset is part of the transaction for this session set.
        rowset = curSession->GetRowset(QUERY_ADAPTER_QUERY_PATH);
      }

      sessionArray.push_back(curSession);

      // Resolves a chunk of sessions.
      if (sessionArray.size() >= (unsigned int) mArraySize)
      {
        ASSERT(sessionArray.size() == (unsigned int) mArraySize);

        hr = ResolveBatch(sessionsMap, sessionArray, rowset, indSubs, grpSubs);
        if (FAILED(hr))
          return hr;
      }
    }

    // resolves the last partial chunk if necessary
    if (sessionArray.size() > 0)
    {
      hr = ResolveBatch(sessionsMap, sessionArray, rowset, indSubs, grpSubs);
      if (FAILED(hr))
        return hr;
    }

    rowset = NULL;
    
  }
  catch(_com_error& err)
  {
    _bstr_t message = err.Description();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);

    return ReturnComError(err);
  }

  return (hr);
}

/////////////////////////////////////////////////////////////////////////////
// ResolveBatch
/////////////////////////////////////////////////////////////////////////////
HRESULT 
BatchSubscriptionPlugIn::ResolveBatch(AccountIDToSessionsMap& sessionsMap,
                                      MTSessionArray& sessionArray,
                                      MTPipelineLib::IMTSQLRowsetPtr& rowset,
                                      MTObjectCollection<MTPRODUCTCATALOGLib::IMTSubInfo>& indSubs,
                                      MTObjectCollection<MTPRODUCTCATALOGLib::IMTSubInfo>& grpSubs)
{
  HRESULT hr = S_OK;

  COdbcConnectionHandle connection(mOdbcManager, mConnectionCommand);

  // Truncate the temporary tables.  The truncate
  // syntax is the same for MS SQL Server and Oracle.

  COdbcStatementPtr truncateStmtPtr = connection->CreateStatement();
  truncateStmtPtr->ExecuteUpdate(mTmpTmplTableTruncateSQL);
  
  if(mUseBcpFlag)
    hr = InsertIntoTmpTable(sessionsMap, sessionArray, connection[mBcpInsertToTmpTableStmtCommand]);
  else if (IsOracle())
    hr = InsertIntoTmpTable(sessionsMap, sessionArray, connection[mOracleArrayInsertToTmpTableStmtCommand]);
  else
    hr = InsertIntoTmpTable(sessionsMap, sessionArray, connection[mSqlArrayInsertToTmpTableStmtCommand]);
  if (FAILED(hr))
    return hr;

  if (mbSessionsFailed)
  {
    sessionArray.clear();
    return S_OK;
  }

  rowset->Clear();
  rowset->SetQueryString(mTmpTmplTableSetTemplateIDSQL);
  rowset->Execute();

  if (mOkToLogDebugInfo)
  {
    _variant_t index;
    _variant_t value;

    index = (long)0;

    long id_acc       = -1;
    bool b_first_time = true;

    
    rowset->Clear();
    rowset->SetQueryString(mTmpTmplTableGetResultsSQL);
    rowset->Execute();

    string statusMsg;

    if (bool(rowset->RowsetEOF))
      statusMsg = "There were no accounts that did not have a template associated with them.";
    else
      statusMsg = "The following accounts did not have a template associated with them: ";

    while(!bool(rowset->RowsetEOF))
    {
      try
      {
        value = rowset->GetValue(index);
        ASSERT((value.vt == VT_I2) || (value.vt == VT_I4));
        id_acc = long(value);

        char numBuf[32];

        if (b_first_time)
        {
          b_first_time = false;
          sprintf(numBuf, "%d", id_acc);
          statusMsg += numBuf;
        }
        else
        {
          sprintf(numBuf, ", %d", id_acc);
          statusMsg += numBuf;
        }
      }
      catch (_com_error& err)
      {
        _bstr_t message = err.Description();
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
        return ReturnComError(err);
      }

      rowset->MoveNext();
    }

    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, statusMsg.c_str());
  }

  rowset->Clear();
  rowset->SetQueryString(mTmpSubsTableGetResultsSQL);
  rowset->Execute();

  _variant_t index;
  _variant_t value;

  DATE dt_min_date = getMinMTOLETime();

  long id_acc;
  long id_corporate;
  DATE dt_acc_start;
  DATE dt_acc_end;
  bool b_group;
  long id_group_sub;
  long id_po;

  while(!bool(rowset->RowsetEOF))
  {
    try
    {
      // Retrieve the account id (required).
      index = (long)0;
      value = rowset->GetValue(index);
      ASSERT((value.vt == VT_I2) || (value.vt == VT_I4));
      id_acc = long(value);

      // Retrieve the corporate account id (required).
      index = (long)1;
      value = rowset->GetValue(index);
      ASSERT((value.vt == VT_I2) || (value.vt == VT_I4));
      id_corporate = long(value);

      // Retrieve the account start date (required).
      index = (long)2;
      value = rowset->GetValue(index);
      ASSERT(value.vt == VT_DATE);
      dt_acc_start = value.date;

      // Retrieve the account end date (required).
      index = (long)3;
      value = rowset->GetValue(index);
      ASSERT(value.vt == VT_DATE);
      dt_acc_end = value.date;

      // Retrieve the product offering id (required).
      index = (long)4;
      value = long(rowset->GetValue(index));
      ASSERT((value.vt == VT_I2) || (value.vt == VT_I4));
      id_po = long(value);

      // Retrieve the group id (optional).
      index = (long)5;
      value = rowset->GetValue(index);
      ASSERT((value.vt == VT_I2) || (value.vt == VT_I4) || (value.vt == VT_NULL));
      if (value.vt == VT_NULL)
      {
        b_group      = false;
        id_group_sub = -1;
      }
      else
      {
        b_group      = true;
        id_group_sub = long(value);
      }

      if (b_group)
      {
        long id_sub;
        DATE dt_sub_start;
        DATE dt_sub_end;

        // Retrieve the subscription id (required for group subs).
        index = (long)6;
        value = rowset->GetValue(index);
        ASSERT((value.vt == VT_I2) || (value.vt == VT_I4));
        id_sub = long(value);

        // Retrieve the subscription start date (required for group subs).
        index = (long)7;
        value = rowset->GetValue(index);
        ASSERT(value.vt == VT_DATE);
        dt_sub_start = value.date;

        // Retrieve the subscription end date (required for group subs).
        index = (long)8;
        value = rowset->GetValue(index);
        ASSERT(value.vt == VT_DATE);
        dt_sub_end = value.date;

        // If the account start date is after the subscription
        // start date then the subscription start date for this
        // account will be the account start date.  The account
        // can not have subscribed to the subscription before
        // it existed.
        if (dt_acc_start > dt_sub_start)
          dt_sub_start = dt_acc_start;

        // If the subscription start date is after the account
        // end date then there is no need to subscribe this
        // account and we are done.  We execute this
        // code only if the subscription start date is before or
        // the same as the account end date.  (We check for
        // equality because the valid date range for accounts
        // is a closed-closed date range (meaning that the
        // account is valid starting with the start date and
        // through the end date).)
        if ((dt_acc_end == dt_min_date)
         || (dt_sub_start <= dt_acc_end))
        {
          if (dt_acc_end != dt_min_date)
          {
            if (dt_acc_end < dt_sub_end)
              dt_sub_end = dt_acc_end;
          }

          MTPRODUCTCATALOGLib::IMTSubInfoPtr subInfo;

          hr = subInfo.CreateInstance("MTProductCatalog.MTSubInfo");
          if (FAILED(hr))
            throw _com_error(hr);

          subInfo->PutAll(id_acc, id_corporate, id_sub,
                          dt_sub_start, MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE,
                          dt_sub_end,   MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE,
                          id_po, VARIANT_TRUE, id_group_sub);

          grpSubs.Add(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSubInfo*>(subInfo.GetInterfacePtr()));
        }
      }
      else
      {
        MTPRODUCTCATALOGLib::IMTSubInfoPtr subInfo;

        hr = subInfo.CreateInstance("MTProductCatalog.MTSubInfo");
        if (FAILED(hr))
          throw _com_error(hr);

        subInfo->PutAll(id_acc, id_corporate, (-1),
                        dt_acc_start, MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE,
                        dt_acc_end,   MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE,
                        id_po, VARIANT_FALSE, (-1));

        indSubs.Add(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSubInfo*>(subInfo.GetInterfacePtr()));
      }
    }
    catch (_com_error& err)
    {
      _bstr_t message = err.Description();
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, message);
      return ReturnComError(err);
    }

    rowset->MoveNext();
  }

  rowset->Clear();
  sessionArray.clear();

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// InsertIntoTmpTable
/////////////////////////////////////////////////////////////////////////////
template<class T> HRESULT
BatchSubscriptionPlugIn::InsertIntoTmpTable(AccountIDToSessionsMap& sessionsMap,
                                            MTSessionArray& sessionArray,
                                            T insertStmtPtr)
{
  HRESULT hr = S_OK;

  // Declare our current session pointer.
  MTPipelineLib::IMTSessionPtr curSession = 0;

  unsigned int i;
  for (i = 0; i < sessionArray.size(); i++)
  {
    curSession = sessionArray[i];

    try
    {
      long lAccountID = curSession->GetLongProperty(mlAccountIDID);

      VARIANT_BOOL bApplyAccountTemplate = curSession->GetBoolProperty(mlApplyAccountTemplateID);
      VARIANT_BOOL b_cansubscribe = curSession->GetBoolProperty(mcansubscribeID);
      VARIANT_BOOL b_CanParticipateInGSub = curSession->GetBoolProperty(mb_CanParticipateInGSubID);

       if ((b_cansubscribe == VARIANT_FALSE) && (b_CanParticipateInGSub == VARIANT_FALSE))
      {
        if (mOkToLogDebugInfo)
        {
          char errMsg[128];
          sprintf(errMsg, "The account type for %ld specifies that it can never subscribe to a product offering or participate in a group subscription, skipping this account.", lAccountID);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, errMsg);
        }
        continue;
      }

      if (bApplyAccountTemplate != VARIANT_TRUE)
      {
        if (mOkToLogDebugInfo)
        {
          char errMsg[128];
          sprintf(errMsg, "The ApplyAccountTemplate flag for account %ld has been set to false, skipping this account.", lAccountID);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, errMsg);
        }
        continue;
      }

      _bstr_t sAccountType = curSession->GetStringProperty(mlAccountTypeID);
      long lAccountType = curSession->GetLongProperty(macc_type_id);

      // Skip this session if this account is a system account.
      if (_wcsicmp((wchar_t*)sAccountType, L"SYSTEMACCOUNT") == 0)
      {
        if (mOkToLogDebugInfo)
        {
          char errMsg[128];
          sprintf(errMsg, "Account %ld is a system account, nothing to do.", lAccountID);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, errMsg);
        }
        continue;
      }

      _bstr_t sActionType = mEnumConfig->GetEnumeratorByID(
                                                      curSession->GetEnumProperty(mlActionTypeID));

      if ((_wcsicmp((wchar_t*)sActionType, L"ACCOUNT") != 0)
       && (_wcsicmp((wchar_t*)sActionType, L"BOTH")    != 0))
      {
        if (mOkToLogDebugInfo)
        {
          char errMsg[128];
          sprintf(errMsg, "The action for this account (%ld) is not ACCOUNT or BOTH, skipping this account.", lAccountID);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, errMsg);
        }
        continue;
      }

      long lAccountAncestorID = curSession->GetLongProperty(mlAncestorAccountIDID);
      
      VARIANT_BOOL b_iscorporate = curSession->GetBoolProperty(miscorporateID);
      if(b_iscorporate == VARIANT_TRUE)
      {
        if (mOkToLogDebugInfo)
        {
          char errMsg[128];
          sprintf(errMsg, "Account %ld is a corporate account, nothing to do.", lAccountID);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, errMsg);
        }
        continue;
      }

      long lCorporateAccountID = curSession->GetLongProperty(mlCorporateAccountIDID);

      _bstr_t sOperation = mEnumConfig->GetEnumeratorByID(curSession->GetEnumProperty(mlOperationID));
      
      if (sOperation.length() == 0)  // Blank, return error.
        MT_THROW_COM_ERROR("Blank Operation");

      if (_wcsicmp((wchar_t*)sOperation, L"Add") != 0)
        MT_THROW_COM_ERROR(MT_UNSUPPORTED_ACCOUNT_OPERATION, (const char*)sOperation);

      DATE accStartDate;

      if(curSession->PropertyExists(mlAccountStartDateID, MTPipelineLib::SESS_PROP_TYPE_DATE))
        accStartDate = curSession->GetOLEDateProperty(mlAccountStartDateID);
      else
        accStartDate = GetMTOLETime();

      DATE accEndDate;

      if (curSession->PropertyExists(mlAccountEndDateID, MTPipelineLib::SESS_PROP_TYPE_DATE))
        accEndDate = curSession->GetOLEDateProperty(mlAccountEndDateID);
      else
        accEndDate = getMinMTOLETime();

      TIMESTAMP_STRUCT tmpODBCTimestamp;

      // Set id_acc.  Required.
      insertStmtPtr->SetInteger(1, lAccountID);

      // Set id_ancestor.  Required.
      insertStmtPtr->SetInteger(2, lAccountAncestorID);

      // Set id_corporate.  Required.
      insertStmtPtr->SetInteger(3, lCorporateAccountID);

      // Set dt_acc_start.  Required.
      OLEDateToOdbcTimestamp(&accStartDate, &tmpODBCTimestamp);
      insertStmtPtr->SetDatetime(4, tmpODBCTimestamp);

      // Set dt_acc_end.  Required.
      OLEDateToOdbcTimestamp(&accEndDate, &tmpODBCTimestamp);
      insertStmtPtr->SetDatetime(5, tmpODBCTimestamp);

      // Set the accounttype. Required.
      insertStmtPtr->SetInteger(6, lAccountType);

      // Get array of sessions mapped to this accout id.
      AccountIDToSessionsMap::iterator it = sessionsMap.find(lAccountID);
      MTSessionArrayPtr sessionsArray;
      if (it == sessionsMap.end())
      {
        // Map entry not found, create sessions array and insert sessions.
        sessionsArray = new MTSessionArray;
        sessionsArray->push_back(curSession);

        // Insert sessions array into map.
        sessionsMap[lAccountID] = sessionsArray;
      }
      else
      {
        // This session is associated with account id that already has a mapping.
        sessionsArray = it->second;

     		// Loop through and check if session already exists.
        bool bFound = false;
        for (MTSessionArray::const_iterator it = sessionsArray->begin(); it != sessionsArray->end(); it++)
        {
	        if (curSession == *it)
          {
            bFound = true;
            break;
          }
        }

        // Add the session to array if it does not found.
        if (!bFound)
		      sessionsArray->push_back(curSession);
      }

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

  // Insert the records into the temp table.
  insertStmtPtr->ExecuteBatch();

  return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// GenerateQueries
/////////////////////////////////////////////////////////////////////////////
HRESULT
BatchSubscriptionPlugIn::GenerateQueries(BOOL        bIsOracle,
                                         const char* stagingDBName)
{
  // Build the name of our "temporary" table.
  MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));
  mTmpTmplTableName = nameHash->GetDBNameHash(("tmp_batchsub_templates_" + mTagName).c_str());
  string schemaDots = mQueryAdapter->GetSchemaDots();

  mTmpTmplTableFullName = stagingDBName + schemaDots + mTmpTmplTableName.c_str();

  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__CREATE_BATCHSUB_TEMPLATES_TEMP_TABLE__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTmplTableFullName.c_str());
  mTmpTmplTableCreateSQL = mQueryAdapter->GetQuery();

  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__AH_TRUNCATE_TEMP_TABLE__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTmplTableFullName.c_str());
  mTmpTmplTableTruncateSQL = mQueryAdapter->GetQuery();

  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__INSERT_INTO_BATCHSUB_TEMPLATES_TEMP_TABLE__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTmplTableFullName.c_str());
  mTmpTmplTableInsertSQL = mQueryAdapter->GetQuery();

  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__GET_BATCHSUB_RESULTS_TEMPLATES_TEMP_TABLE__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTmplTableFullName.c_str());
  mTmpTmplTableGetResultsSQL = mQueryAdapter->GetQuery();

  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__GET_BATCHSUB_RESULTS_SUBSCRIPTIONS_TEMP_TABLE__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTmplTableFullName.c_str());
  mTmpSubsTableGetResultsSQL = mQueryAdapter->GetQuery();

  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__UPDATE_BATCHSUB_TEMPLATES_TEMP_TABLE_WITH_TEMPLATE_ID__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTmplTableFullName.c_str());
  mTmpTmplTableSetTemplateIDSQL = mQueryAdapter->GetQuery();

  return S_OK;
}
