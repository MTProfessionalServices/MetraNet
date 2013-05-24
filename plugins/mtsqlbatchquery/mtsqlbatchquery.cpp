/**************************************************************************
 * MTSQL
 *
 * Copyright 1997-2000 by MetraTech Corp.
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
 * Created by: David Blair
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <BatchPlugInSkeleton.h>
using std::string;
#include <strstream>
using std::istrstream;
#include <map>
using std::map;

#include "MTSQLInterpreter.h" 
#include "MTSQLInterpreterSessionInterface.h" 
#include "BatchQuery.h"
#include "perflog.h"


// generate using uuidgen
CLSID CLSID_MTSQLBatchQuery = { /* 317e7a0e-ab7c-454b-90c2-52a70d2d181d */
    0x317e7a0e,
    0xab7c,
    0x454b,
    {0x90, 0xc2, 0x52, 0xa7, 0x0d, 0x2d, 0x18, 0x1d}
  };

class ATL_NO_VTABLE MTSQLBatchQueryPlugIn
	: public MTBatchPipelinePlugIn<MTSQLBatchQueryPlugIn, &CLSID_MTSQLBatchQuery>
{
public:
	MTSQLBatchQueryPlugIn() :
		mInterpreter(NULL),
		mEnv(NULL)
	{ }

protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																			MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																			MTPipelineLib::IMTNameIDPtr aNameID,
																			MTPipelineLib::IMTSystemContextPtr aSysContext);
	virtual HRESULT BatchPlugInInitializeDatabase();
	virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet);
	virtual HRESULT BatchPlugInShutdownDatabase();

private:
	MTSQLInterpreter* mInterpreter;
	MTSQLExecutable* mExe;
  BatchQuery * mQuery;
	MTSQLSessionCompileEnvironment* mEnv;
	MTPipelineLib::IMTLogPtr mLogger;	
  MTPipelineLib::IMTNameIDPtr mNameID;
  _bstr_t mProgram;
  _bstr_t mTempTableName;
  _bstr_t mTagName;
};


PLUGIN_INFO(CLSID_MTSQLBatchQuery, MTSQLBatchQueryPlugIn,
						"MetraPipeline.MTSQLBatchQuery.1", "MetraPipeline.MTSQLBatchQuery", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTSQLBatchQueryPlugIn::BatchPlugInConfigure"
HRESULT MTSQLBatchQueryPlugIn::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																								MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																								MTPipelineLib::IMTNameIDPtr aNameID,
																								MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	try {
    mInterpreter = NULL;
    mExe = NULL;
    mQuery = NULL;
    mEnv = NULL;
		mLogger = aLogger;
    mNameID = aNameID;
		mProgram = aPropSet->NextStringWithName("Program");
    // TODO: set the table name for arguments.  Really doesn't have
    // to be a temp table; in fact it shouldn't be because of some DTC
    // strangeness we have seen.
    mTempTableName = aPropSet->NextStringWithName("TempTable");
    mTagName = GetTagName(aSysContext);
	} catch (MTSQLException& ex) 
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(ex.toString().c_str()));
		return E_FAIL;
	}
  

	return S_OK;
}

class RuntimeVector : public std::vector<MTSQLSessionRuntimeEnvironment<> * >
{
public:
  ~RuntimeVector()
  {
    for(unsigned int i=0; i<this->size(); i++)
    {
      delete this->operator[](i);
    }
  }
};


/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT MTSQLBatchQueryPlugIn::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
		return hr;

	HRESULT errHr = S_OK;

  // Create a runtime environment wrapper for each session.
  // Place the activation record for the runtime environment 
  // into a vector.
  RuntimeVector runtimes;
  std::vector<ActivationRecord* > activations;
  bool first = true;
  MTPipelineLib::IMTSessionPtr firstSession;
	MTPipelineLib::IMTTransactionPtr transaction;
	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;

		if (first)
		{
			first = false;

			// Get the txn from the first session in the set.
			// don't begin a new transaction unless 
			transaction = GetTransaction(session);

      firstSession = session;
		}

    MTSQLSessionRuntimeEnvironment<> * renv = new MTSQLSessionRuntimeEnvironment<>(mLogger, session, firstSession);
    runtimes.push_back(renv);
    activations.push_back(renv->getActivationRecord());
	}

  // Know just execute the query; it knows how to put the
  // results back into the sessions.
  try
  {
    ITransactionPtr mTransaction;
    if (transaction != NULL)
    {
      ITransactionPtr itrans = transaction->GetTransaction();
      ASSERT(itrans != NULL);
      mTransaction = itrans;
    }
    mQuery->ExecuteQuery(activations, mTransaction);
  }
  catch (MTSQLUserException& uex) 
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(uex.toString().c_str()));
    return uex.GetHRESULT();
  } 
  catch (MTSQLException& ex) 
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(ex.toString().c_str()));
    return E_FAIL;
  }
  return S_OK;
}

HRESULT MTSQLBatchQueryPlugIn::BatchPlugInInitializeDatabase()
{
  try {
    // this is a read-only plugin, so retry is safe
    AllowRetryOnDatabaseFailure(TRUE);

    // The only piece of database state we maintain is in the
    // BatchQuery object.  For paranoia sake (and simplicity of code), we recompile everything
    // though.
		mEnv = new MTSQLSessionCompileEnvironment(mLogger, mNameID);
		mInterpreter = new MTSQLInterpreter(mEnv);
    mInterpreter->setTempTable((const char *) mTempTableName, (const char *)mTagName);
		mExe = mInterpreter->analyze((const wchar_t *)mProgram);
		if (NULL == mExe) 
		{
			string err("Error compiling program");
			return Error(err.c_str());
		}
    mQuery = mInterpreter->analyzeQuery();
		if (NULL == mQuery) 
		{
			string err("Error transforming query");
			return Error(err.c_str());
		}
	} catch (MTSQLException& ex) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(ex.toString().c_str()));
		return E_FAIL;
	}
  return S_OK;
}

HRESULT MTSQLBatchQueryPlugIn::BatchPlugInShutdownDatabase()
{
	if (mInterpreter)
	{
		delete mInterpreter;
		mInterpreter = NULL;
	}

  mExe = NULL;

	if (mQuery)
	{
		delete mQuery;
		mQuery = NULL;
	}

	if (mEnv)
	{
		delete mEnv;
		mEnv = NULL;
	}

	return S_OK;
}

