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

#include <PlugInSkeleton.h>
using std::string;
#include <strstream>
using std::istrstream;
#include <map>
using std::map;

#include "MTSQLInterpreter.h" 
#include "MTSQLSharedSessionInterface.h" 
#include "perflog.h"


// generate using uuidgen
CLSID CLSID_MTSQLInterpreter = { /* 7daac1f1-f80a-46a7-bea5-14a6a35216c3 */
    0x7daac1f1,
    0xf80a,
    0x46a7,
    {0xbe, 0xa5, 0x14, 0xa6, 0xa3, 0x52, 0x16, 0xc3}
  };

class ATL_NO_VTABLE MTSQLInterpreterPlugIn
	: public MTPipelinePlugIn<MTSQLInterpreterPlugIn, &CLSID_MTSQLInterpreter>
{
public:
	MTSQLInterpreterPlugIn() :
		mInterpreter(NULL),
		mEnv(NULL),
    mExe(NULL),
    mFactory(NULL)
	{ }

protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
																	MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();
	// We are session set aware so that handling of exceptions thrown by the
	// MTSQL interpreter can be passed on properly.
	virtual HRESULT PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet);
	// Do not call this!
	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession) 
	{
		return E_NOTIMPL;
	}

private:
	MTSQLInterpreter* mInterpreter;
	MTSQLExecutable* mExe;
	MTSQLSessionCompileEnvironment* mEnv;
	MTPipelineLib::IMTLogPtr mLogger;	
  MTSQLSharedSessionFactoryWrapper * mFactory;
};


PLUGIN_INFO(CLSID_MTSQLInterpreter, MTSQLInterpreterPlugIn,
						"MetraPipeline.MTSQLInterpreter.1", "MetraPipeline.MTSQLInterpreter", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTSQLInterpreterPlugIn::PlugInConfigure"
HRESULT MTSQLInterpreterPlugIn::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																								MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																								MTPipelineLib::IMTNameIDPtr aNameID,
																								MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	try {
		mLogger = aLogger;
		mEnv = new MTSQLSessionCompileEnvironment(aLogger, aNameID);
		mInterpreter = new MTSQLInterpreter(mEnv);
		_bstr_t program = aPropSet->NextStringWithName("Program");
		mExe = mInterpreter->analyze((const wchar_t *)program);
		if (NULL == mExe) 
		{
			string err("Error compiling program");
			return Error(err.c_str());
		}
    mExe->codeGenerate(mEnv);
    mFactory = new MTSQLSharedSessionFactoryWrapper();
	} catch (MTSQLException& ex) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(ex.toString().c_str()));
		return E_FAIL;
	}

	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT MTSQLInterpreterPlugIn::PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
		return hr;

	HRESULT errHr = S_OK;
  MTSQLSharedSessionWrapper wrapper;

  bool first = true;
  MTPipelineLib::IMTSessionPtr firstSession;
	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;

		try
		{
 		  if (first)
		  {
			  first = false;
        firstSession = session;
		  }
      mFactory->InitSession(session->SessionID, &wrapper);
			MTSQLSharedSessionRuntimeEnvironment<> renv(mLogger, &wrapper, firstSession);
			try {
				mExe->execCompiled(&renv);
			} catch (MTSQLUserException& uex) {
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(uex.toString().c_str()));
				// Set an error on the session and continue processing the session set
				session->MarkAsFailed(_bstr_t(uex.toString().c_str()), uex.GetHRESULT());
				errHr = uex.GetHRESULT();
			} catch (MTSQLException& ex) {
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(ex.toString().c_str()));
				// Set an error on the session and continue processing the session set
				session->MarkAsFailed(_bstr_t(ex.toString().c_str()), E_FAIL);
				errHr = E_FAIL;
			}
		}
		catch (_com_error & err)
		{
			_bstr_t message = err.Description();
			errHr = err.Error();
			session->MarkAsFailed(message.length() > 0 ? message : L"", errHr);
		}
	}
	if (FAILED(errHr))
		return PIPE_ERR_SUBSET_OF_BATCH_FAILED;
	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT MTSQLInterpreterPlugIn::PlugInShutdown()
{
	delete mInterpreter;
	delete mEnv;
  delete mFactory;
	return S_OK;
}
