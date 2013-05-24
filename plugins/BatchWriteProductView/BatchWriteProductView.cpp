/**************************************************************************
 * @doc INSERTSESSION
 *
 * Copyright 2000 - 2006 by MetraTech Corporation
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


#include <BatchPlugInSkeleton.h>

#include <MSIX.h>

#include <NTThreader.h>
#include <NTThreadLock.h>

#include <propids.h>

#include <OdbcSessionManager.h>
#include <OdbcException.h>
#include <OdbcConnection.h>
#include <OdbcConnMan.h>
#include <mtprogids.h>
#include <perflog.h>

#include <autoptr.h>

typedef MTautoptr<IOdbcSessionManager> IOdbcSessionManagerPtr;

// generate using uuidgen
CLSID CLSID_BATCHWRITEPRODUCTVIEW = { /* 283bb0a0-d8e7-11d3-a3fd-00c04f484788 */
    0x64be8127,
    0xdb79,
    0x4b20,
    {0x88, 0x96, 0xdd, 0x12, 0xeb, 0xa2, 0x2f, 0x97}
  };


class ATL_NO_VTABLE BatchWriteProductView
	: public MTBatchPipelinePlugIn<BatchWriteProductView, &CLSID_BATCHWRITEPRODUCTVIEW>
{
protected:
	virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);
	virtual HRESULT BatchPlugInInitializeDatabase();
	virtual HRESULT BatchPlugInShutdownDatabase();
	virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet);

private:
	void WriteCompoundSession(__int64 aIdParent,
														MTPipelineLib::IMTSessionPtr aSession);

	HRESULT WriteSessions(MTPipelineLib::IMTSessionSetPtr aSet);

  static const std::string OdbcIntegrityViolation;

private:
	NTThreadLock mValuesLock;

private:
	// interface to the logging system
	MTPipelineLib::IMTLogPtr mLogger;
	MTPipelineLib::IMTLogPtr mPerfLogger;

	MTPipelineLib::IMTNameIDPtr mNameID;

	bool mbUseBcpFlag;
	bool mbStageOnly;
  VARIANT_BOOL mbUseSingleThreadedRouterFlag;
	_bstr_t mbstrStageDatabase;
	int mNumThreads;
	int mBatchSize;

	// Session write has the ability to write sessions to the database
	IOdbcSessionManagerPtr mRouter;

	__int64 mTotalRecords;
	double mTotalMillis;
	double mTotalWait;
	double mTotalSubmitWait;
	double mTotalWrite;
	double mTotalCommit;
	double mTotalApplyDefaults;
	double mTotalCheckRequired;

	double mTotalWriteSessionProperties;
};

const std::string BatchWriteProductView::OdbcIntegrityViolation("23000");


PLUGIN_INFO(CLSID_BATCHWRITEPRODUCTVIEW, BatchWriteProductView,
						"MetraPipeline.WriteProductView.1", "MetraPipeline.WriteProductView", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT BatchWriteProductView::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																										MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																										MTPipelineLib::IMTNameIDPtr aNameID,
																										MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	mTotalRecords = 0;
	mTotalMillis = 0.0;
	mTotalWait = 0.0;
	mTotalSubmitWait = 0.0;
	mTotalWrite = 0.0;
	mTotalCommit = 0.0;
	mTotalApplyDefaults = 0.0;
	mTotalCheckRequired = 0.0;

	mTotalWriteSessionProperties = 0.0;

	mNameID = aNameID;
	mLogger = aLogger;
	mPerfLogger = MTPipelineLib::IMTLogPtr(MTPROGID_LOG);
	mPerfLogger->Init("logging\\perflog", "[WriteProductView]");


	PipelinePropIDs::Init();

	// Default values for properties
	mbStageOnly = false;
	mbUseBcpFlag = false;
  mbUseSingleThreadedRouterFlag = VARIANT_TRUE;
	mbstrStageDatabase = _bstr_t("");
	mNumThreads = 1;
	mBatchSize = 1000; // 50000;  -- 50k too large for array inserts w/ oracle?

	if(aPropSet)
	{
		VARIANT_BOOL bDoesPropExist = VARIANT_FALSE;
		bDoesPropExist = aPropSet->NextMatches("usebcpflag", MTPipelineLib::PROP_TYPE_BOOLEAN);
		if (VARIANT_TRUE == bDoesPropExist)
		{
      mbUseBcpFlag = aPropSet->NextBoolWithName("usebcpflag") == VARIANT_TRUE ? true : false;
		}

		bDoesPropExist = aPropSet->NextMatches("usesinglethreadflag", MTPipelineLib::PROP_TYPE_BOOLEAN);
		if (VARIANT_TRUE == bDoesPropExist)
		{
			mbUseSingleThreadedRouterFlag = aPropSet->NextBoolWithName("usesinglethreadflag");
		}

		bDoesPropExist = aPropSet->NextMatches("stagedatabase", MTPipelineLib::PROP_TYPE_STRING);
		if (VARIANT_TRUE == bDoesPropExist)
		{
			mbstrStageDatabase = aPropSet->NextStringWithName("stagedatabase");
		}

		bDoesPropExist = aPropSet->NextMatches("stageonly", MTPipelineLib::PROP_TYPE_BOOLEAN);
		if (VARIANT_TRUE == bDoesPropExist)
		{
      mbStageOnly = aPropSet->NextBoolWithName("stageonly") == VARIANT_TRUE ? true : false;
		}

		bDoesPropExist = aPropSet->NextMatches("num_threads", MTPipelineLib::PROP_TYPE_INTEGER);
		if (VARIANT_TRUE == bDoesPropExist)
		{
			mNumThreads = aPropSet->NextLongWithName("num_threads");
		}

		bDoesPropExist = aPropSet->NextMatches("batch_size", MTPipelineLib::PROP_TYPE_INTEGER);
		if (VARIANT_TRUE == bDoesPropExist)
		{
			mBatchSize = aPropSet->NextLongWithName("batch_size");
		}
	}

	return S_OK;
}

HRESULT BatchWriteProductView::BatchPlugInInitializeDatabase()
{
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"BatchWriteProductView::BatchPlugInInitializeDatabase() started" );
	
	// this plugin writes to tables so retrying is not safe
	AllowRetryOnDatabaseFailure(FALSE);
	
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"creating new router" );
	
	COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");

  // Ignore the BCP flag for oracle.
	if (IsOracle())
		mbUseBcpFlag = false;

	if (mbstrStageDatabase == _bstr_t(""))
	{
    // Does not support materialized views.
  	mRouter = new COdbcSessionManager(info, mLogger, mNameID, mBatchSize, mNumThreads, mbUseBcpFlag);
	} 
	else
	{
		// Use all the same information except for the database/catalog name.
		// The database name is retrieved from servers.xml
		COdbcConnectionInfo stageEntry = COdbcConnectionManager::GetConnectionInfo(mbstrStageDatabase);
		COdbcConnectionInfo stageInfo(info);
		stageInfo.SetCatalog(stageEntry.GetCatalog().c_str());

    // Staged managers support materialized views.
    if (mbUseSingleThreadedRouterFlag)
        mRouter = new COdbcSimpleStagedSessionManager(info, stageInfo, mLogger, mNameID, mBatchSize,
                                                      mbUseBcpFlag, mbStageOnly);
    else
        mRouter = new COdbcStagedSessionManager(info, stageInfo, mLogger, mNameID, mBatchSize, mNumThreads,
                                                mbUseBcpFlag, mbStageOnly);
	}

	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"BatchWriteProductView::InitializeDatabase() succeeded" );
	return S_OK;
}


HRESULT BatchWriteProductView::BatchPlugInShutdownDatabase()
{
	mRouter = NULL;
	mTotalRecords = 0;

	return S_OK;
}


void BatchWriteProductView::WriteCompoundSession(__int64 aIdParent,
																								 MTPipelineLib::IMTSessionPtr aSession)
{
	__int64 id_sess;
	if (aIdParent == -1)
	{
		id_sess = mRouter->WriteSession(aSession);
		aSession->SetLongLongProperty(PipelinePropIDs::SessionIDCode(), id_sess);
	}
	else
	{
		id_sess = mRouter->WriteChildSession(aIdParent, aSession);
		aSession->SetLongLongProperty(PipelinePropIDs::SessionIDCode(), id_sess);
	}

	if (aSession->GetIsParent() == VARIANT_TRUE)
	{
		// add the descendants
		MTPipelineLib::IMTSessionSetPtr children = aSession->SessionChildren();

		SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
		HRESULT hr = it.Init(children);
		if (FAILED(hr))
		{
			ASSERT(0);
			//return hr;
		}

		while (TRUE)
		{
			MTPipelineLib::IMTSessionPtr child = it.GetNext();
			if (child == NULL)
				break;

			// write this with our knowledge of the parent ID
			WriteCompoundSession(id_sess, child);
		}
	}
}

HRESULT BatchWriteProductView::WriteSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	MarkRegion region("WriteSessions");

	HRESULT hr = S_OK;
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;

	LARGE_INTEGER freq;
	LARGE_INTEGER tick;
	LARGE_INTEGER tock;
	::QueryPerformanceFrequency(&freq);
	
	::QueryPerformanceCounter(&tick);

	int parentsFound = 0;
	try
	{
		// get the DTC txn to be joined
		// The DTC txn is owned by the MTObjectOwner and shared among all sessions in the session set.
		MTPipelineLib::IMTTransactionPtr transaction;

		//write all sessions to intermediate storage

		hr = it.Init(aSet);
		if (FAILED(hr))
			return hr;
		while (TRUE)
		{
			MTPipelineLib::IMTSessionPtr session = it.GetNext();
			if (session == NULL)
				break;

			// is this either an atomic session or a root-most parent?
			if (session->GetParentID() == -1)
			{
				if (parentsFound == 0)
				{
					// Get the txn from the first session in the set.
					transaction = session->GetTransaction(VARIANT_TRUE);

					// pass in transaction to be used for batch 
					// and give objects an opportunity to (re)intialize batch state
					mRouter->BeginBatch(transaction);

				}
		
				parentsFound++;


				// recursively write the sessions to the router, top down
				WriteCompoundSession(-1, session);
			}
		}

		if (parentsFound > 0)
		{
			//send batch to final storage
			mRouter->ExecuteBatch();
	
			//free up resources (can throw exceptions)
			mRouter->FinalizeBatch(true);
		}
	}
	catch(COdbcBindingException& ex)
	{
		//free up resources (not throwing exceptions)
		mRouter->FinalizeBatch(false);

		//return failure, no need to tear database connection 
		//and stuff.
		return Error((const wchar_t *)_bstr_t(ex.what()));
	}
	catch(COdbcException& ex) 
	{	
		//free up resources (not throwing exceptions)
		mRouter->FinalizeBatch(false);

    if(ex.getSqlState() == OdbcIntegrityViolation)
    {
      // Check if subset of batch failed.
      if (ex.getErrorCode() == PIPE_ERR_SUBSET_OF_BATCH_FAILED)
        return PIPE_ERR_SUBSET_OF_BATCH_FAILED;

      // Special case RI constraints.  It is pretty safe to say
      // that these shouldn't require a connection reset.  Furthermore,
      // we still haven't been able to resolve the DTC enlistment failures
      // that are triggered by connection resets, so not reset in this case
      return Error((const wchar_t *)_bstr_t(ex.what()));
    }
    else
    {
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BatchWriteProductView::WriteSessions caught exception."
                         " Calling FinalizeBatch() and rethrowing exception");

      // Rethrow caught exception
      throw ex;
    }
	}

	if (parentsFound > 0)
	{
		::QueryPerformanceCounter(&tock);
		char buf[2048];
		long numRecords = (long) (mRouter->GetTotalRecords()-mTotalRecords);
		sprintf(buf, "BatchWriteProductView::PlugInProcessSessions for %d records took %d milliseconds"
						"\n\tWaitForCompletion %g ms"
						"\n\tWaitForSubmit %g ms"
						"\n\tSessionWrite %g ms"
						"\n\t\tCheckRequired %g ms"
						"\n\t\tApplyDefaults %g ms"
						"\n\t\tWrite Session Properties %g ms"
						"\n\tCommit %g ms", numRecords, 
						(long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart), 
						mRouter->GetTotalCompletionWaitMillis() - mTotalWait, 
						mRouter->GetTotalSubmitWaitMillis() - mTotalSubmitWait, 
						mRouter->GetTotalWriteSessionMillis() - mTotalWrite, 
						mRouter->GetTotalCheckRequiredMillis() - mTotalCheckRequired, 
						mRouter->GetTotalApplyDefaultsMillis() - mTotalApplyDefaults, 
						mRouter->GetTotalWriteSessionPropertiesMillis() - mTotalWriteSessionProperties, 						
						mRouter->GetTotalCommitMillis() - mTotalCommit);
		mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
		mTotalRecords = mRouter->GetTotalRecords();
		mTotalWait = mRouter->GetTotalCompletionWaitMillis();
		mTotalWrite = mRouter->GetTotalWriteSessionMillis();
		mTotalSubmitWait = mRouter->GetTotalSubmitWaitMillis();
		mTotalCommit = mRouter->GetTotalCommitMillis();
		mTotalCheckRequired = mRouter->GetTotalCheckRequiredMillis();
		mTotalWriteSessionProperties = mRouter->GetTotalWriteSessionPropertiesMillis();
		mTotalApplyDefaults = mRouter->GetTotalApplyDefaultsMillis();

		sprintf(buf, "BatchWriteProductView::SQLExecute for %d records took %g milliseconds",
						numRecords, mRouter->GetTotalExecuteMillis() - mTotalMillis);
		mTotalMillis = mRouter->GetTotalExecuteMillis();
		mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
	}
	else
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,
											 "Write product view used with child sessions - no action taken");
	}

	return hr;
}

HRESULT BatchWriteProductView::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	HRESULT hr = S_OK;
	
	try 
	{
		hr = WriteSessions(aSet);
	}
	catch(_com_error& comerror)
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, comerror.Description());
		hr = ReturnComError(comerror);
	}
	
	return hr;
}



