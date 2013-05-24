/**************************************************************************
 * MTSESSIONFAILURES
 *
 * Copyright 1997-2000 by MetraTech Corporation
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

// MTSessionFailures.cpp : Implementation of CMTSessionFailures
#include "StdAfx.h"

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF")
#import <MTProductCatalogInterfacesLib.tlb> rename( "EOF", "RowsetEOF" )
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib;") \
     inject_statement("using ROWSETLib::IMTSQLRowsetPtr;") \
     inject_statement("using ROWSETLib::IMTSQLRowset;") \
     inject_statement("using MTProductCatalogInterfacesLib::IMTPropertyMetaDataPtr;") \
     inject_statement("using MTProductCatalogInterfacesLib::IMTPropertyMetaData;")

#import <MetraTech.Pipeline.ReRun.tlb> \
     inject_statement("using namespace mscorlib;") \
     inject_statement("using ROWSETLib::MTOperatorType;") \
     inject_statement("using namespace MTAUTHLib;")

#include "PipelineControl.h"
#include "MTSessionFailures.h"

#include <MTUtil.h>
#include <pipelineconfig.h>
#include <msmqlib.h>
#include <mtglobal_msg.h>
#include <sessionerr.h>
#include <MTSessionError.h>
#include <pipeconfigutils.h>
#include <loggerconfig.h>
#include <controlutils.h>
#include <rwcom.h>
#include <stdutils.h>
#include <mtcomerr.h>
#include <ConfigDir.h>
#include <UsageServerConstants.h>
#include <mtparamnames.h>
#include <DBConstants.h>
#include <MSIX.h>
#include <formatdbvalue.h>

using namespace ROWSETLib;

#define MTPARAM_SESSIONUID "%%SESSION_UID%%"

using COMMeterLib::ISessionPtr;
using COMMeterLib::ISessionSetPtr;
using COMMeterLib::IBatchPtr;

typedef pair <vector<unsigned char>, int> My_Pair;

/////////////////////////////////////////////////////////////////////////////
// CMTSessionFailures

STDMETHODIMP CMTSessionFailures::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSessionFailures,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTSessionFailures::CMTSessionFailures()
	: mSessionFailures(NULL)
{ }


HRESULT CMTSessionFailures::FinalConstruct()
{
	return Init();
}

void CMTSessionFailures::FinalRelease()
{ 
	if (mSessionFailures)
		delete mSessionFailures;
}


HRESULT CMTSessionFailures::Init()
{
  HRESULT hr = S_OK;
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[SessionFailures]");

	std::string configDir;
	if (!GetMTConfigDir(configDir))
		return Error("Configuration directory not set in registry");

	PipelineInfoReader pipelineReader;
	PipelineInfo pipelineInfo;
	// TODO: have to convert from one namespace to another
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
		return HRESULT_FROM_WIN32(pipelineReader.GetLastError()->GetCode());

	// chooses the appropriate strategy based on the queuing mode
	
	mIsOracle = (COdbcConnectionManager::GetConnectionInfo("NetMeter").GetDatabaseType() 
		== COdbcConnectionInfo::DBTYPE_ORACLE);

	if(PipelineInfo::PERSISTENT_DATABASE_QUEUE == pipelineInfo.GetHarnessType())
	{
		mSessionFailures = CMTSessionFailures::NewDBSessionFailures();
		/*if (mIsOracle)
				mSessionFailures = new DBSessionFailures<COdbcPreparedArrayStatement>;
			else
				mSessionFailures = new DBSessionFailures<COdbcPreparedBcpStatement>;
		*/
	}
	else
		mSessionFailures = new MSMQSessionFailures(pipelineInfo, &mLogger);

	return S_OK;
}

// create a COM object out of SessionErrorObject
HRESULT Initialize(CComObject<CMTSessionError> * apObj,
									 SessionErrorObject * apErr, BOOL aTakeOwnership = FALSE)
{
	apObj->SetSessionError(apErr, aTakeOwnership);
	return S_OK;
}



// ----------------------------------------------------------------
// Description:   Resubmit a failed session, without any modification,
//                back into the pipeline.  The session is taken from the routing
//                queue journal and placed back on the routing queue.
// Arguments:     sessionID - base64 encoded ID of session to be resubmitted.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionFailures::ResubmitSession(BSTR sessionID)
{
	try
	{
		MetraTech_Pipeline_ReRun::IBulkFailedTransactionsPtr bulkFailed;

    GUID guid = __uuidof(MetraTech_Pipeline_ReRun::BulkFailedTransactions);
		bulkFailed = MetraTech_Pipeline_ReRun::IBulkFailedTransactionsPtr(guid);

		bulkFailed->ResubmitSession(sessionID);
		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

// ----------------------------------------------------------------
// Description:   Resubmit a session marked as lost by the auditor.  The session
//                is retrieved from the routing queue journal and placed back on the
//                routing queue.
// Arguments:     sessionID - base64 encoded ID of session to be resubmitted.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionFailures::ResubmitLostSession(BSTR messageID)
{
	try
	{
		return mSessionFailures->ResubmitSuspendedMessage(messageID);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(mLogger, err);
	}
}

// ----------------------------------------------------------------
// Description:   Login to provide security credentials for some operations
// Arguments:     login - username to login as
//                login_namespace - namespace of the user
//                password - password of the user
// ----------------------------------------------------------------

STDMETHODIMP CMTSessionFailures::Login(BSTR login, BSTR login_namespace,
																			 BSTR password)
{
	try
	{
		MTPipelineLibExt::IMTLoginContextPtr loginObj(MTPROGID_MTLOGINCONTEXT);
		mSessionContext = loginObj->Login(login, login_namespace, password);
		return S_OK;
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(mLogger, err); }
}

// ----------------------------------------------------------------
// Description:   Pass in a session context that has already been created by a login call.
// Arguments:     session_context - a session context object previously
//                retrieved by a Login call.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionFailures::put_SessionContext(
	IMTSessionContext * apSessionContext)
{
	try
	{
		mSessionContext = apSessionContext;
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(mLogger, err); }

	return S_OK;
}




// ----------------------------------------------------------------
// Description:   Permanently delete a failed session.  No record of the
//                session will remain on the system.
// Arguments:     sessionID - base64 encoded ID of session to be abandoned.
//                txn - optional MTTransaction object.  If an MTTransaction
//                      object is passed in this method will be transactional.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionFailures::AbandonSession(
	BSTR sessionID,
	/*[in, optional]*/ VARIANT txn)
{
	// delete from error queue only
	try
	{
		PIPELINECONTROLLib::IMTTransactionPtr mttran;
		if (_variant_t(txn) != vtMissing)
		{
			if (V_VT(&txn) == (VT_VARIANT | VT_BYREF))
				// dereference (this is how VBScript would pass it)
				mttran = _variant_t(txn.pvarVal);
			else if (V_VT(&txn) == (VT_DISPATCH | VT_BYREF))
				// dereference (this is how VB would pass it)
				mttran = _variant_t(*(txn.ppdispVal));
			else
				mttran = _variant_t(txn);

			if (mttran == NULL)
				return Error("Invalid transaction object");
		}
		else
			mttran = NULL;


		MetraTech_Pipeline_ReRun::IBulkFailedTransactionsPtr bulkFailed;

    GUID guid = __uuidof(MetraTech_Pipeline_ReRun::BulkFailedTransactions);
		if (mttran != NULL)
			bulkFailed = mttran->CreateObjectWithTransactionByCLSID(&guid);
		else
			bulkFailed = MetraTech_Pipeline_ReRun::IBulkFailedTransactionsPtr(guid);

		bulkFailed->DeleteSession(sessionID);
		return S_OK;
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(mLogger, err); }
}


// ----------------------------------------------------------------
// Description:   Deletes a suspended message. 
// No error needs to exist for the session to be deleted.
// Arguments:     messageID - pre 4.0: base64 encoded GUID of the messages to be abandoned.
//                             >= 4.0: the integral message ID
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionFailures::AbandonLostSession(BSTR messageID)
{
	try
	{
		return mSessionFailures->DeleteSuspendedMessage(messageID);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(mLogger, err);
	}
}


// ----------------------------------------------------------------
// Description:   Retrieve the list of failed sessions again.  Enumeration over this
//                object will then have the current list of failed sessions.
// Arguments:
// Errors Raised: PIPE_ERR_INTERNAL_ERROR, if the queue is in an inconsistent state.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionFailures::Refresh()
{
	try
	{
		// clear any current errors
		ClearErrors();

		HRESULT hr = mSessionFailures->Refresh(mErrorObjects);

		if (FAILED(hr))
			ClearErrors();

		return hr;
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(mLogger, err); 
	}
}


//
// automation methods
//
STDMETHODIMP CMTSessionFailures::get_Count(/*[out, retval]*/ long *pVal)
{
	return GetCountOnSTL(mErrorObjects, pVal);
}


STDMETHODIMP CMTSessionFailures::get_Item(VARIANT aIndex, /*[out, retval]*/ VARIANT *pVal)
{
	try
	{
		_variant_t var(aIndex);
		// "dereference" the variant if necessary
		if (V_VT(&var) == (VT_VARIANT | VT_BYREF))
			var = var.pvarVal;

		if (V_VT(&var) == VT_BSTR || V_VT(&var) == (VT_BSTR | VT_BYREF))
		{
			std::wstring id = (const wchar_t *) (_bstr_t) var;

      SessionErrorObject * errObj = mSessionFailures->FindError(id.c_str());

			CComObject<CMTSessionError> * obj;
			HRESULT hr = CComObject<CMTSessionError>::CreateInstance(&obj);
			if (FAILED(hr))
				return hr;


			// the MTSessionError object will take ownership of the SessionErrorObject
			// so we don't need to delete it.
			hr = Initialize(obj, errObj, TRUE);
			if (FAILED(hr))
			{
				delete obj;
				return hr;
			}

			// objects are created with a ref count of 0.  this will add 1
			IDispatch * idisp;
			hr = obj->QueryInterface(IID_IDispatch, (void**) &idisp);

			_variant_t result(idisp, false);
			*pVal = result.Detach();

			return S_OK;

		}
		else
		{
			long index = var;

			return GetItemOnSTL<CMTSessionError, SessionErrorObject,
				ErrorObjectList>(mErrorObjects, index, pVal);
		}
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(mLogger, err); }
}


STDMETHODIMP CMTSessionFailures::get__NewEnum(/*[out, retval]*/ LPUNKNOWN *pVal)
{
	return
		GetNewEnumOnSTL<CMTSessionError,
		SessionErrorObject>(GetUnknown(),
												mErrorObjects, pVal);
}


template void destroyPtr(SessionErrorObject *);
void CMTSessionFailures::ClearErrors()
{
	for_each(mErrorObjects.begin(), mErrorObjects.end(), destroyPtr<SessionErrorObject>);
	mErrorObjects.clear();
}


HRESULT CMTSessionFailures::SaveXMLMessage(BSTR aSessionID,
																					 const char * apMessage,
																					 GENERICCOLLECTIONLib::IMTCollectionPtr childrenToDelete)
{
	try
	{
		MTautoptr<ISessionFailuresStrategy> sessionFailures = 
			CMTSessionFailures::NewDBSessionFailures();

		sessionFailures->SaveXMLMessage(aSessionID, apMessage, childrenToDelete);
	}
	catch (_com_error & err)
	{ 
		LoggerConfigReader configReader;
		NTLogger logger;
		logger.Init(configReader.ReadConfiguration("logging"), "[SessionFailures]");
		return LogAndReturnComError(logger, err);
	}

	return S_OK;
}

HRESULT CMTSessionFailures::LoadXMLMessage(BSTR aSessionID,
																					 std::string & arMessage,
																					 PIPELINECONTROLLib::IMTTransactionPtr txn)
{
	try
	{
		MTautoptr<ISessionFailuresStrategy> sessionFailures = 
			CMTSessionFailures::NewDBSessionFailures();

		sessionFailures->LoadXMLMessage(aSessionID, arMessage, txn);
	}
	catch (_com_error & err)
	{
		LoggerConfigReader configReader;
		NTLogger logger;
		logger.Init(configReader.ReadConfiguration("logging"), "[SessionFailures]");
		return LogAndReturnComError(logger, err);
	}

	return S_OK;
}


BOOL CMTSessionFailures::HasSavedXMLMessage(BSTR aSessionID,
																						PIPELINECONTROLLib::IMTTransactionPtr txn)
{
	MTautoptr<ISessionFailuresStrategy> sessionFailures = 
		CMTSessionFailures::NewDBSessionFailures();

	return sessionFailures->HasSavedXMLMessage(aSessionID, txn);
}


HRESULT CMTSessionFailures::DeleteSavedXMLMessage(BSTR aSessionID,
																									PIPELINECONTROLLib::IMTTransactionPtr txn)
{
	try
	{
		MTautoptr<ISessionFailuresStrategy> sessionFailures = 
			CMTSessionFailures::NewDBSessionFailures();

		sessionFailures->DeleteSavedXMLMessage(aSessionID, txn);
	}
	catch (_com_error & err)
	{
		LoggerConfigReader configReader;
		NTLogger logger;
		logger.Init(configReader.ReadConfiguration("logging"), "[SessionFailures]");
		return LogAndReturnComError(logger, err);
	}

	return S_OK;
}


// static method to determine whether DB Queue mode is enabled
// NOTE: needed by a few static methods, otherwise use the mDBQueuesUsed field
bool CMTSessionFailures::IsDBQueueModeEnabled()
{
	PipelineInfoReader pipelineReader;
	PipelineInfo pipelineInfo;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	std::string configDir;
	if (!GetMTConfigDir(configDir))
		MT_THROW_COM_ERROR("Configuration directory not set in registry");

	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
		MT_THROW_COM_ERROR(HRESULT_FROM_WIN32(pipelineReader.GetLastError()->GetCode()));

  return (PipelineInfo::PERSISTENT_DATABASE_QUEUE == pipelineInfo.GetHarnessType());
}


// static method to return template expanded DBSessionFailures class and
// chooses the appropriate strategy based on the queuing mode
ISessionFailuresStrategy* CMTSessionFailures::NewDBSessionFailures()
{
	ISessionFailuresStrategy* sessionFailures;
	bool isOracle = (COdbcConnectionManager::GetConnectionInfo("NetMeter").GetDatabaseType() 
		== COdbcConnectionInfo::DBTYPE_ORACLE);

	if (IsDBQueueModeEnabled())
		if (isOracle)
			sessionFailures = new DBSessionFailures<COdbcPreparedArrayStatement>(TRUE);
		else
			sessionFailures = new DBSessionFailures<COdbcPreparedBcpStatement>(FALSE);
	else
		sessionFailures = new MSMQSessionFailures;

	return sessionFailures;
}
