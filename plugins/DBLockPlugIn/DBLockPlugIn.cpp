/**************************************************************************
 * DBLockPlugIn
 *
 * Copyright 1997-2005 by MetraTech Corp.
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

// g. cieplik CR 15945 add odbc to get oracle connection
#include <OdbcConnection.h>
#include <OdbcConnMan.h>
#include <RowsetDefs.h>

// generate using uuidgen
CLSID CLSID_Lock = { /* 9dbf95fa-0118-4b3e-8a1b-abc20e15c1a8 */
    0x9dbf95fa,
    0x0118,
    0x4be3,
    {0x8a, 0x1b, 0xab, 0xc2, 0x0e, 0x15, 0xc1, 0xa8}
  };

class ATL_NO_VTABLE LockPlugIn
	: public MTPipelinePlugIn<LockPlugIn, &CLSID_Lock>
{
public:
	LockPlugIn() 
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
	MTPipelineLib::IMTLogPtr mLogger;	
  int mLockType;
  _bstr_t mResource;
  _bstr_t mLockMode;
  _bstr_t mLockOwner;
  int mLockTimeout;
};


PLUGIN_INFO(CLSID_Lock, LockPlugIn,
						"MetraPipeline.DBLockPlugIn.1", "MetraPipeline.DBLockPlugIn", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "LockPlugIn::PlugInConfigure"
HRESULT LockPlugIn::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																								MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																								MTPipelineLib::IMTNameIDPtr aNameID,
																								MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  mLogger = aLogger;

  // Yuck.  For backward compatibility I am reading these values as
  // strings and then casting.
  _bstr_t bstrType = aPropSet->NextStringWithName("locktype");
  mLockType = atoi((const char *) bstrType);
  mResource = aPropSet->NextStringWithName("resource");
  
  if(mLockType == 1) 
  {
    mLockMode = aPropSet->NextStringWithName("lockmode");
  }
  mLockOwner = aPropSet->NextStringWithName("lockowner");
  
  if(mLockType == 1)
  {
    _bstr_t bstrTimeout = aPropSet->NextStringWithName("locktimeout");
    mLockTimeout = atoi((const char *) bstrTimeout);
  }

  return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT LockPlugIn::PlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSet);
	if (FAILED(hr))
		return hr;

	HRESULT errHr = S_OK;

  // g. cieplik CR 15945 get oracle info
  COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter"); 
  bool mIsOracle = netMeter.IsOracle();

  bool first = true;
  MTPipelineLib::IMTSessionPtr firstSession;
  MTPipelineLib::IMTSQLRowsetPtr rowset;
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
        rowset = firstSession->GetRowset(L"Queries\\Database");
		  }

	  // create oracle lock
	  if (mIsOracle)
	  {
		if (mLockType == 1)
			{
				mLockMode = "ALLOCATE";

				// g. cieplik CR 15945 the "timeout" property is configured to be millseconds for SqlServer, convert to seconds for Oracle, default to 10 secs
			    if ((mLockTimeout = mLockTimeout / 1000)  <= 0) mLockTimeout = 10;
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Creating Lock for Oracle.");
				rowset->InitializeForStoredProc("dblock");
				rowset->AddInputParameterToStoredProc ("p_lockname", MTTYPE_VARCHAR, INPUT_PARAM, mResource);
				rowset->AddInputParameterToStoredProc ("p_timeout", MTTYPE_INTEGER, INPUT_PARAM, mLockTimeout);
				rowset->AddInputParameterToStoredProc ("p_lockmode", MTTYPE_VARCHAR, INPUT_PARAM, mLockMode);
				rowset->AddOutputParameterToStoredProc ("p_result", MTTYPE_INTEGER, OUTPUT_PARAM);
		  
				rowset->ExecuteStoredProc();
				long status = -999;		
				status = rowset->GetParameterFromStoredProc("p_result");

				switch(status)
				{
					case 0:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Lock was successfully granted synchronously");
						break;
					case 1:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Lock request timed out");
						session->MarkAsFailed(L"Lock request timed out", E_FAIL);
						errHr = E_FAIL;
						break;
					case 2:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Lock request was chosen as a deadlock victim.");
						session->MarkAsFailed(L"Lock request was chosen as a deadlock victim.", E_FAIL);
						errHr = E_FAIL;
						break;
					case 3:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Lock request had parameter error");
						session->MarkAsFailed(L"Lock request had parameter error", E_FAIL);
						errHr = E_FAIL;
						break;
					case 4:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Lock request already owned.");
						session->MarkAsFailed(L"Lock request already owned.", E_FAIL);
						errHr = E_FAIL;
						break;
					case 5:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Illegal Lock Handle.");
						session->MarkAsFailed(L"Illegal Lock Handle.", E_FAIL);
						errHr = E_FAIL;
						break;
					default:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Unknown value returned from lock request");
						session->MarkAsFailed(L"Unknown value returned from lock request", E_FAIL);
						errHr = E_FAIL;
					break;
				}
			}
		else if (mLockType == 2)
			{
				mLockTimeout = 0;
				mLockMode = "RELEASE";
	  			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Releasing Lock for Oracle.");
				rowset->InitializeForStoredProc("dblock");
				rowset->AddInputParameterToStoredProc ("p_lockname", MTTYPE_VARCHAR, INPUT_PARAM, mResource);
				rowset->AddInputParameterToStoredProc ("p_timeout", MTTYPE_INTEGER, INPUT_PARAM, mLockTimeout);
				rowset->AddInputParameterToStoredProc ("p_lockmode", MTTYPE_VARCHAR, INPUT_PARAM, mLockMode);
				rowset->AddOutputParameterToStoredProc ("p_result", MTTYPE_INTEGER, OUTPUT_PARAM);

				rowset->ExecuteStoredProc();
				long status = -999;		
				status = rowset->GetParameterFromStoredProc("p_result");
		
				switch(status)
				{
					case 0:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Lock was released successfully.");
						break;
					case 3:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Lock request had parameter error.");
						session->MarkAsFailed(L"Lock request had parameter error", E_FAIL);
						errHr = E_FAIL;
						break;
					case 4:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Do not own lock specified by id or lockhandle");
						session->MarkAsFailed(L"Do not own lock specified by id or lockhandle.", E_FAIL);
						errHr = E_FAIL;
						break;
					case 5:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Illegal Lock Handle.");
						session->MarkAsFailed(L"Illegal Lock Handle.", E_FAIL);
						errHr = E_FAIL;
						break;
					default:
						mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Unknown value returned from lock request.");
						session->MarkAsFailed(L"Unknown value returned from lock request.", E_FAIL);
						errHr = E_FAIL;
					break;
				}		
			}
	  }
	  else
	  {
	  // create sql server lock
      if (mLockType == 1)
      {
        wchar_t queryBuffer [1024];
        wsprintf(queryBuffer,
                 L"DECLARE @result int\n"
                 L"EXEC @result = sp_getapplock @Resource = '%s', @LockMode = '%s', @LockOwner = '%s', @LockTimeout = %d \n"
                 L"select @result",
                 (const wchar_t *)mResource, (const wchar_t *)mLockMode, (const wchar_t *)mLockOwner, mLockTimeout);

        rowset->SetQueryString(queryBuffer);
        rowset->Execute();
        long status = -999;
        if(!bool(rowset->RowsetEOF))
        {
          rowset->MoveFirst();
          status = (long) rowset->GetValue(0L);
        }

        switch(status)
        {
        case 0:
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Lock was successfully granted synchronously");
          break;
        case 1:
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Lock was granted successfully after waiting for other incompatible locks to be released");
          break;
        case -1:
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Lock request timed out");
          session->MarkAsFailed(L"Lock request timed out", E_FAIL);
          errHr = E_FAIL;
          break;
        case -2:
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Lock request was cancelled");
          session->MarkAsFailed(L"Lock request was cancelled", E_FAIL);
          errHr = E_FAIL;
          break;
        case -3:
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Lock request was chosen as a deadlock victim");
          session->MarkAsFailed(L"Lock request was chosen as a deadlock victim", E_FAIL);
          errHr = E_FAIL;
          break;
        case -999:
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Error requesting lock");
          session->MarkAsFailed(L"Error requesting lock", E_FAIL);
          errHr = E_FAIL;
          break;
        }
      }
      else if (mLockType == 2)
      {
        wchar_t queryBuffer [1024];
        wsprintf(queryBuffer,
                 L"DECLARE @result int\n"
                 L"EXEC @result = sp_releaseapplock @Resource = '%s', @LockOwner = '%s'\n"
                 L"select @result",
                 (const wchar_t *)mResource, (const wchar_t *)mLockOwner);

        rowset->SetQueryString(queryBuffer);
        rowset->Execute();
        long status = -999;
        if(!bool(rowset->RowsetEOF))
        {
          rowset->MoveFirst();
          status = (long) rowset->GetValue(0L);
        }

        switch(status)
        {
        case 0:
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Lock was successfully released");
          break;
        case -999:
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, L"Error releasing lock");
          session->MarkAsFailed(L"Error releasing lock", E_FAIL);
          errHr = E_FAIL;
          break;
        }
      }
	  // catch the error
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

HRESULT LockPlugIn::PlugInShutdown()
{
	return S_OK;
}
