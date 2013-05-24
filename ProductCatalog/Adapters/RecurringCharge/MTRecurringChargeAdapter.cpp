// MTRecurringChargeAdapter.cpp : Implementation of CMTRecurringChargeAdapter
#include "StdAfx.h"

#pragma warning(disable: 4297)  // disable warning "function assumed not to throw an exception but does"

#include "RecurringChargeAdapter.h"
#include <mtprogids.h>
#include <PCCache.h>
#import "MeterRowset.tlb" rename( "EOF", "RowsetEOF" )
#include <mtcomerr.h>
#import <RecurringChargeAdapter.tlb> rename("EOF", "RCEOF")
#include "MTRecurringChargeAdapter.h"
#include <loggerconfig.h>



#define RECUR_CHARGE_LOG_TAG	"[RCAdapter]"

/////////////////////////////////////////////////////////////////////////////
// CMTRecurringChargeAdapter

STDMETHODIMP CMTRecurringChargeAdapter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IRecurringEventAdapter2
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

//
//
//////////////////////////////////////////////////////////

STDMETHODIMP CMTRecurringChargeAdapter::Initialize (BSTR eventName,
																										BSTR configFile, 
																										IMTSessionContext* context, 
																										VARIANT_BOOL limitedInit)
{


	try
	{  
		HRESULT hr=S_OK ;

		LoggerConfigReader cfgRdr;
		mLogger.Init (cfgRdr.ReadConfiguration("RecurringChargeAdapter"), RECUR_CHARGE_LOG_TAG);

		m_ConfigPath = CONFIG_DIR;

		// loads the standard metering settings
		mMeteringConfig.CreateInstance(__uuidof(MetraTech_UsageServer::MeteringConfig));
		mMeteringConfig->Load(configFile, 1000, PCCache::GetBatchSubmitTimeout(), false);

		return hr;
	}
	catch (_com_error e)
	{
		mLogger.LogVarArgs(LOG_ERROR, "COM exception 0x%08h caught in CMTRecurringChargeAdapter::Initialize.", e.Error());
		return e.Error();
	}
	return S_OK;
}

HRESULT CMTRecurringChargeAdapter::ReportError( const char* str_errmsg , HRESULT hr)
{
	mLogger.LogThis (LOG_ERROR, str_errmsg);
	return Error (str_errmsg, IID_IRecurringEventAdapter, hr ) ;
}


//
//
//////////////////////////////////////////////////////////

STDMETHODIMP CMTRecurringChargeAdapter::Execute(IRecurringEventRunContext* apContext,
																								BSTR* detail)
{
	HRESULT hr = S_OK;
	try 
	{
		MetraTech_UsageServer::IRecurringEventRunContextPtr context(apContext);
		long intervalID = context->GetUsageIntervalID();
    long billingGroupID = context->GetBillingGroupID();

		// clear counters.
		mMetered = 0;
		mErrors = 0;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET) ;
		rowset->Init(m_ConfigPath);
		rowset->SetQueryTag("__GET_RECUR_CHARGE_TYPES__");	
		rowset->Execute();
		
		wchar_t buffer[512];

		int types = 0;
		_com_error * firstError = NULL;
		while (rowset->GetRowsetEOF().boolVal != VARIANT_TRUE)
		{
			long	typeID = rowset->GetValue("id_pi");
      //Retrieving kind to determine type of charge generation
      MTPCEntityType kind = static_cast<MTPCEntityType>((long)rowset->GetValue("n_kind"));
			_bstr_t serviceDef = rowset->GetValue("nm_servicedef");

			try
			{
				MeterRCType(context, serviceDef, typeID, kind, intervalID, billingGroupID);
			}
			catch (_com_error & e)
			{
				if (mMeteringConfig->FailImmediately)
					throw;
				else
				{
					string msg;
					StringFromComError(msg, "A failure occurred while processing a recurring charge", e);
					mLogger.LogThis(LOG_ERROR, msg.c_str());
					context->RecordWarning(_bstr_t(msg.c_str()));
					
					// makes a copy of the first exception to save for later
					if (firstError == NULL)
						firstError = new _com_error(e);
				}
			}

			rowset->MoveNext();
			types++;
		}

		// rethrows the first error encountered after all processing has completed
		// this generates as many charges as possible
		if (firstError)
		{
			_com_error err(*firstError);
			delete firstError;
			throw err;
		}

		wsprintf(buffer, L"%d sessions metered for %d recurring charge types", mMetered, types);
		_bstr_t bstrBuffer(buffer);
		*detail = bstrBuffer.copy();
	}
	catch(_com_error & err)
	{
		return LogAndReturnComError(mLogger, err);
	}

	// CORE-1133, mErrors is the count of trapped errors, fail the batch when greater then zero.
	if (mErrors > 0)
	{
	  mLogger.LogVarArgs(LOG_DEBUG, " %d Errors have occurred during metering of recurring charges, these where not caught as a com_error, failing the adapter.", mErrors);
	  // doing mt_throw_com_error causes the adapter to fail properly. mErrors is the MeterErrorCount
      MT_THROW_COM_ERROR("%d Errors have occurred during metering of recurring charges, these where not caught as a com_error, failing the adapter.",mErrors); 
	}
	return S_OK;
}

STDMETHODIMP CMTRecurringChargeAdapter::Reverse(IRecurringEventRunContext* context, 
																								 BSTR* detail)
{
	// we're "auto reverse" so we don't have to implement this
	return E_NOTIMPL;
}

STDMETHODIMP CMTRecurringChargeAdapter::Shutdown()
{
	// nothing to do
	return S_OK;
}

STDMETHODIMP CMTRecurringChargeAdapter::CreateBillingGroupConstraints(long intervalID, long materializationID)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTRecurringChargeAdapter::SplitReverseState(long parentRunID, 
                                                          long parentBillingGroupID,
                                                          long childRunID, 
                                                          long childBillingGroupID)
{
	// nothing to do
	return E_NOTIMPL;
}

STDMETHODIMP CMTRecurringChargeAdapter::get_SupportsScheduledEvents(VARIANT_BOOL* pRetVal)
{
	// end of period only
	*pRetVal = VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP CMTRecurringChargeAdapter::get_SupportsEndOfPeriodEvents(VARIANT_BOOL* pRetVal)
{
	// end of period only
	*pRetVal = VARIANT_TRUE;
	return S_OK;
}

STDMETHODIMP CMTRecurringChargeAdapter::get_Reversibility(ReverseMode* pRetVal)
{
	// all we do is meter batches - that can be reversed automatically
  if (pRetVal == NULL) return E_POINTER;
	*pRetVal = ReverseMode_Auto;
	return S_OK;
}

STDMETHODIMP CMTRecurringChargeAdapter::get_AllowMultipleInstances(VARIANT_BOOL* pRetVal)
{
	// yes, more than one of this adapter can run at one time
  if (pRetVal == NULL) return E_POINTER;
	*pRetVal = VARIANT_TRUE;
	return S_OK;
}

STDMETHODIMP CMTRecurringChargeAdapter::get_BillingGroupSupport(BillingGroupSupportType* pRetVal)
{
  if (pRetVal == NULL) return E_POINTER;
  *pRetVal = BillingGroupSupportType_Account;
  return S_OK;
}

STDMETHODIMP CMTRecurringChargeAdapter::get_HasBillingGroupConstraints(VARIANT_BOOL* pRetVal)
{
  if (pRetVal == NULL) return E_POINTER;
  *pRetVal = VARIANT_FALSE;
  return S_OK;
}


void CMTRecurringChargeAdapter::MeterRCType(
	MetraTech_UsageServer::IRecurringEventRunContextPtr context,
	const _bstr_t& aServiceDef, long lTypeID, MTPCEntityType kind, long lIntervalID, long lBillingGroupID)
{
	mLogger.LogVarArgs(LOG_DEBUG, "RecurringChargeAdapter is about to meter in recurring charge %d for interval %d and billing group %d into service %s", lTypeID, lIntervalID, lBillingGroupID, LPCSTR(aServiceDef));

	// TODO: Get the progid into the product catalog somewhere to allow custom charge generators.
	RECURRINGCHARGEADAPTERLib::IMTChargeGeneratorPtr chargeGenerator;
  if (kind == PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
	{
		chargeGenerator.CreateInstance(__uuidof(RECURRINGCHARGEADAPTERLib::MTUDChargeGenerator));
	}
	else
	{
		chargeGenerator.CreateInstance(__uuidof(RECURRINGCHARGEADAPTERLib::MTFlatChargeGenerator));
	}

	ROWSETLib::IMTSQLRowsetPtr rowset;
	wchar_t buffer[256];
	_com_error * firstError = NULL;


	//
	// arrears case
	//
	try
	{
		rowset = chargeGenerator->GetArrearsCharges(lTypeID, lIntervalID, lBillingGroupID, context->RunID, m_ConfigPath);

		if ((rowset->GetRowsetEOF()).boolVal == VARIANT_FALSE)
		{
			// create the meter rowset
			METERROWSETLib::IMeterRowsetPtr meterRowset("MetraTech.MeterRowset.1");
			meterRowset->SessionSetSize = mMeteringConfig->SessionSetSize;
			meterRowset->InitSDK(L"RecurringChargeServer");
			wsprintf(buffer, L"Arrears - %d", lTypeID);

			// create batch
			METERROWSETLib::IBatchPtr batch =
				meterRowset->CreateAdapterBatch(context->GetRunID(),
																				"RecurringCharges", buffer);
			_bstr_t batchID = batch->GetUID();
			meterRowset->InitForService(aServiceDef);
			meterRowset->AddCommonProperty("_intervalID", METERROWSETLib::MTC_DT_INT, _variant_t(lIntervalID));

			wsprintf(buffer, L"About to meter in ARREARS recurring charges of type %d.", lTypeID);
			context->RecordInfo(buffer);

			mLogger.LogVarArgs(LOG_DEBUG, "About to meter in ARREARS recurring charges of type %d.", lTypeID);

			meterRowset->MeterRowset((METERROWSETLib::IMTSQLRowsetPtr)rowset);

			// wait for all sessions to be committed.
			long metered = meterRowset->MeteredCount;
			meterRowset->WaitForCommit(metered, mMeteringConfig->CommitTimeout);

			if (meterRowset->CommittedErrorCount > 0)
			{
				_bstr_t msg = _bstr_t(meterRowset->CommittedErrorCount);
				msg += " sessions failed during pipeline processing!";
				MT_THROW_COM_ERROR((const char *) msg);
			}

			mLogger.LogVarArgs(LOG_DEBUG, "Successfully metered in ARREARS recurring charges of type %d.", lTypeID);

			wsprintf(buffer, L"Successfully metered in ARREARS recurring charges of type %d.", lTypeID);
			context->RecordInfo(buffer);

			mMetered += metered;
			mErrors += meterRowset->MeterErrorCount;
		}
		else
		{
			wsprintf(buffer, L"There are no ARREARS recurring charges of type %d.", lTypeID);
			context->RecordInfo(buffer);
			mLogger.LogVarArgs(LOG_DEBUG, "There are no ARREARS recurring charges of type %d.", lTypeID);
		}
	}
	catch (_com_error & e)
	{
		if (mMeteringConfig->FailImmediately)
			throw;
		
		// makes a copy of the first exception to save for later; continues processing
		firstError = new _com_error(e);
	}


	//
	// advance case
	//
	try
	{
		wsprintf(buffer, L"Executing advance recurring charge query for interval %d and type %d...",
						 lIntervalID, lTypeID);
		context->RecordInfo(buffer);

		mLogger.LogVarArgs(LOG_INFO, "Executing advance recurring charge query for interval %d and type %d...",
											 lIntervalID, lTypeID);

		rowset = chargeGenerator->GetAdvanceCharges(lTypeID, lIntervalID, lBillingGroupID, context->RunID, m_ConfigPath);

		if ((rowset->GetRowsetEOF()).boolVal == VARIANT_FALSE)
		{
			// create the meter rowset
			METERROWSETLib::IMeterRowsetPtr meterRowset("MetraTech.MeterRowset.1");
			
			meterRowset->SessionSetSize = mMeteringConfig->SessionSetSize;

			meterRowset->InitSDK(L"RecurringChargeServer");

			wsprintf(buffer, L"Advance - %d", lTypeID);
			// create batch
			METERROWSETLib::IBatchPtr batch =
				meterRowset->CreateAdapterBatch(context->GetRunID(),
																				"RecurringCharges", buffer);

			_bstr_t batchID = batch->GetUID();

			meterRowset->InitForService(aServiceDef);
			meterRowset->AddCommonProperty("_intervalID", METERROWSETLib::MTC_DT_INT, _variant_t(lIntervalID));

			wsprintf(buffer, L"About to meter in ADVANCE recurring charges of type %d.", lTypeID);
			context->RecordInfo(buffer);

			mLogger.LogVarArgs(LOG_DEBUG, "About to meter in ADVANCE recurring charges of type %d.", lTypeID);

			meterRowset->MeterRowset((METERROWSETLib::IMTSQLRowsetPtr)rowset);

			// wait for all sessions to be committed.
			long metered = meterRowset->MeteredCount;
			meterRowset->WaitForCommit(metered, mMeteringConfig->CommitTimeout);

			if (meterRowset->CommittedErrorCount > 0)
			{
				_bstr_t msg = _bstr_t(meterRowset->CommittedErrorCount);
				msg += " sessions failed during pipeline processing!";
				MT_THROW_COM_ERROR((const char *) msg);
			}

			mLogger.LogVarArgs(LOG_DEBUG, "Successfully metered in ADVANCE recurring charges of type %d.", lTypeID);

			wsprintf(buffer, L"Successfully metered in ADVANCE recurring charges of type %d.", lTypeID);
			context->RecordInfo(buffer);

			mMetered += metered;
			mErrors += meterRowset->MeterErrorCount;
		}
		else
		{
			wsprintf(buffer, L"There are no ADVANCE recurring charges of type %d.", lTypeID);
			context->RecordInfo(buffer);
			mLogger.LogVarArgs(LOG_DEBUG, "There are no ADVANCE recurring charges of type %d.", lTypeID);
		}
	}
	catch (_com_error & e)
	{
		if (mMeteringConfig->FailImmediately)
			throw;
		
		// makes a copy of the first exception to save for later; continues processing
		if (!firstError)
			firstError = new _com_error(e);
	}

	// rethrows the first error encountered after all processing has completed
	// this generates as many charges as possible
	if (firstError)
	{
		_com_error err(*firstError);
		delete firstError;
		throw err;
	}
} 
