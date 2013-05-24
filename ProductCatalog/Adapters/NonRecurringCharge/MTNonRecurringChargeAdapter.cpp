
#pragma warning (disable : 4800)

#include <metra.h>
#include <MTDate.h>
#include <RecurringEventSkeleton.h>
#include <mtprogids.h>
#include <AdapterLogging.h>
#include <mtparamnames.h>
#include <mtcomerr.h>
#include <mttime.h>
#include <formatdbvalue.h>
#include <PCCache.h>
#include <DataAccessDefs.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import "MeterRowset.tlb" rename( "EOF", "RowsetEOF" )
#import <RecurringEventAdapterLib.tlb> rename( "EOF", "RowsetEOF" )
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MTAuthLib.tlb> rename ("EOF", "RowsetEOF")
#import <MetraTech.UsageServer.tlb> inject_statement("using namespace mscorlib;") inject_statement("using namespace ROWSETLib;") inject_statement("using MTAuthInterfacesLib::IMTSessionContextPtr;")


#define NONRECURRINGCHARGE_ADAPTER_CONFIG_PATH "\\Queries\\ProductCatalog"
#define NONRECURRINGCHARGE_LOG_TAG	"[NonRecurringChargeAdapter]"

using namespace std;

CLSID CLSID_MTNonRecurringChargeAdapter =  // {242A4D0D-2814-4f0e-8D4D-C3E0771FC864}
	{ 0x242a4d0d, 0x2814, 0x4f0e, { 0x8d, 0x4d, 0xc3, 0xe0, 0x77, 0x1f, 0xc8, 0x64 } };


class ATL_NO_VTABLE MTNonRecurringChargeAdapter 
	: public MTRecurringEventSkeleton<MTNonRecurringChargeAdapter, &CLSID_MTNonRecurringChargeAdapter>
{
	public:
	//IRecurringEventAdapter
	STDMETHOD(Initialize)(BSTR eventName,
												BSTR configFile, 
												IMTSessionContext* context, 
												VARIANT_BOOL limitedInit);

	STDMETHOD(Execute)(IRecurringEventRunContext* context, 
										 BSTR* detail);

	STDMETHOD(Reverse)(IRecurringEventRunContext* context, 
										 BSTR* detail);

  STDMETHOD(CreateBillingGroupConstraints)(long intervalID, long materializationID);

  STDMETHOD(SplitReverseState)(long parentRunID, 
                               long parentBillingGroupID,
                               long childRunID, 
                               long childBillingGroupID);

	STDMETHOD(Shutdown)();
	STDMETHOD(get_SupportsScheduledEvents)(VARIANT_BOOL* pRetVal);
	STDMETHOD(get_SupportsEndOfPeriodEvents)(VARIANT_BOOL* pRetVal);
	STDMETHOD(get_Reversibility)(ReverseMode* pRetVal);
	STDMETHOD(get_AllowMultipleInstances)(VARIANT_BOOL* pRetVal);

	STDMETHOD(get_BillingGroupSupport)(BillingGroupSupportType* pRetVal); 
	STDMETHOD(get_HasBillingGroupConstraints)(VARIANT_BOOL* pRetVal); 

	MTNonRecurringChargeAdapter();
	virtual ~MTNonRecurringChargeAdapter();
	
private:
	
	void MeterRowset(_bstr_t aServiceDef,
									 ROWSETLib::IMTSQLRowsetPtr pRowset, 
									 RECURRINGEVENTADAPTERLib::IRecurringEventRunContextPtr context);


	// error logging
	NTLogger mLogger;

	ROWSETLib::IMTSQLRowsetPtr mpRowset;

	long mSequence;

	MetraTech_UsageServer::IMeteringConfigPtr mMeteringConfig;

	// for batch diagnostic
	long	mMetered;
	long	mErrors;
};

PLUGIN_INFO(CLSID_MTNonRecurringChargeAdapter, MTNonRecurringChargeAdapter,"Metratech.MTNonRecurringChargeAdapter.1", "Metratech.MTNonRecurringChargeAdapter", "Free")

/////////////////////////////////////////////////////////////////////////////
// MTNonRecurringChargeAdapter

MTNonRecurringChargeAdapter::MTNonRecurringChargeAdapter()
{ }

MTNonRecurringChargeAdapter::~MTNonRecurringChargeAdapter()
{ }


// ----------------------------------------------------------------
// Name:     			Initialize
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   Initialize Config directory, DB Access and a Query Adapter
// ----------------------------------------------------------------

STDMETHODIMP MTNonRecurringChargeAdapter::Initialize (BSTR eventName, 
																											BSTR aConfigFile,
																											IMTSessionContext* context,
																											VARIANT_BOOL limitedInit)
{
	try
	{
		// logger init
		LoggerConfigReader cfgRdr;
		mLogger.Init (cfgRdr.ReadConfiguration("NonRecurringChargeAdapter"), NONRECURRINGCHARGE_LOG_TAG);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET) ;
		rowset->Init(NONRECURRINGCHARGE_ADAPTER_CONFIG_PATH);
		mpRowset = rowset;

		// loads the standard metering settings
		mMeteringConfig.CreateInstance(__uuidof(MetraTech_UsageServer::MeteringConfig));
		mMeteringConfig->Load(aConfigFile, 1000, PCCache::GetBatchSubmitTimeout(), false);

		mSequence = 0;

		return S_OK;
	}
	catch (_com_error& err)
	{
		return LogAndReturnComError(mLogger, err);
	}
}
// ----------------------------------------------------------------
// Name:     			Execute
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------
STDMETHODIMP MTNonRecurringChargeAdapter::Execute(IRecurringEventRunContext* apContext, 
																									BSTR* detail)
{
	HRESULT hr = S_OK;
	
	char buffer[512];
	try
	{
		RECURRINGEVENTADAPTERLib::IRecurringEventRunContextPtr context = apContext;

		// clear counters.
		mMetered = 0;
		mErrors = 0;

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc( __uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));

		// <SetupFilter>
		ROWSETLib::IMTDataFilterPtr aFilter(__uuidof(ROWSETLib::MTDataFilter));
		aFilter->Add("Kind", ROWSETLib::OPERATOR_TYPE_EQUAL, MTPRODUCTCATALOGLib::PCENTITY_TYPE_NON_RECURRING);
		// </SetupFilter>

		// Get only nonrecurring charges, by calling GetPriceableItemTypes with proper filter
		_variant_t aFilterVar = aFilter;
		MTPRODUCTCATALOGLib::IMTCollectionPtr PITypeColl = pc->GetPriceableItemTypes(aFilterVar);

		std::wstring start_buffer, end_buffer;
		BOOL bSuccess;

		bSuccess = FormatValueForDB(_variant_t(context->StartDate, VT_DATE), false, start_buffer);
		bSuccess = bSuccess && FormatValueForDB(_variant_t(context->EndDate, VT_DATE), false, end_buffer);
		ASSERT(bSuccess);

		bool isOracle = (wcsicmp((const wchar_t *)mpRowset->GetDBType(), ORACLE_DATABASE_TYPE) == 0);

		for (int i = 1; i <= PITypeColl->Count; i++)
		{
			MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr PIType = PITypeColl->GetItem(i);

			long lTypeID = PIType->ID;

			// Preprocess the group subscription participations and the
			// subscription data into a temp table.
			mpRowset->SetQueryTag("__TRUNCATE_NRC_SUBSCRIPTIONS__");
			mpRowset->Execute();
			mpRowset->SetQueryTag("__PREPROCESS_GROUP_SUBSCRIPTION_PARTICIPATIONS_FOR_NRC__");
      mpRowset->AddParam (L"%%INTO_CLAUSE%%", isOracle ? L"" : L"INTO #tmp_nrc_gsubmember");
      mpRowset->AddParam (L"%%INSERT_INTO_CLAUSE%%", isOracle ? L"INSERT INTO tmp_nrc_gsubmember" : L"");
			mpRowset->Execute();
			mpRowset->SetQueryTag("__PREPROCESS_INDIVIDUAL_SUBSCRIPTIONS_FOR_NRC__");
			mpRowset->Execute();

			// Collect all possible NRCs for this PIType into a temp table.
			mpRowset->SetQueryTag("__TRUNCATE_NRC_CANDIDATES__");
			mpRowset->Execute();
			mpRowset->SetQueryTag("__GET_NRC_CANDIDATES__");
			mpRowset->AddParam ("%%TYPEID%%", lTypeID);
      mpRowset->AddParam (L"%%INTO_CLAUSE%%", isOracle ? L"" : L"INTO #tmp_nrcs");
      mpRowset->AddParam (L"%%INSERT_INTO_CLAUSE%%", isOracle ? L"INSERT INTO tmp_nrcs" : L"");
			mpRowset->Execute();
			mpRowset->SetQueryTag("__INDEX_NRC_CANDIDATES__");
			mpRowset->Execute();
			

			//execute main query for sub
			mpRowset->SetQueryTag("__GET_NON_RECUR_CHARGES_FOR_SUB__");
			mpRowset->AddParam ("%%DT_START%%", start_buffer.c_str(), VARIANT_TRUE);
			mpRowset->AddParam ("%%DT_END%%", end_buffer.c_str(), VARIANT_TRUE);
			mpRowset->ExecuteConnected();

			if (mpRowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
			{
				sprintf(buffer, "There are subscription %s of type %d.", (char*)PIType->ServiceDefinition, lTypeID);
				mLogger.LogVarArgs(LOG_DEBUG, buffer);
				context->RecordInfo(buffer);

				MeterRowset(PIType->ServiceDefinition, mpRowset, apContext);
			}
			else
			{
				sprintf(buffer, "There are no subscription %s of type %d.", (char*)PIType->ServiceDefinition, lTypeID);
				mLogger.LogVarArgs(LOG_DEBUG, buffer);
				context->RecordInfo(buffer);
			}


			// execute main query for unsub
			mpRowset->SetQueryTag("__GET_NON_RECUR_CHARGES_FOR_UNSUB__");
			mpRowset->AddParam ("%%DT_START%%", start_buffer.c_str(), VARIANT_TRUE);
			mpRowset->AddParam ("%%DT_END%%", end_buffer.c_str(), VARIANT_TRUE);
			mpRowset->ExecuteConnected();

			if (mpRowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
			{
				sprintf(buffer, "There are unsubscription %s of type %d.", (char*)PIType->ServiceDefinition, lTypeID);
				mLogger.LogVarArgs(LOG_DEBUG, buffer);
				context->RecordInfo(buffer);

				MeterRowset(PIType->ServiceDefinition, mpRowset, apContext);
			}
			else
			{
				sprintf(buffer, "There are no unsubscription %s of type %d.", (char*)PIType->ServiceDefinition, lTypeID);
				mLogger.LogVarArgs(LOG_DEBUG, buffer);
				context->RecordInfo(buffer);
			}

		}

		sprintf(buffer, "%d sessions metered", mMetered);
		_bstr_t bstrBuffer(buffer);
		*detail = bstrBuffer.copy();
	}
	catch(_com_error& e)
	{
		return LogAndReturnComError(mLogger, e);
	}

	return hr;
}


STDMETHODIMP MTNonRecurringChargeAdapter::Reverse(IRecurringEventRunContext* context, 
																								 BSTR* detail)
{
	// TODO: Can we really autoreverse?
	// we're "auto reverse" so we don't have to implement this
	return E_NOTIMPL;
}

STDMETHODIMP MTNonRecurringChargeAdapter::CreateBillingGroupConstraints(long intervalID, 
                                                                        long materializationID)
{
	// scheduled adapters don't have billing group support
	return E_NOTIMPL;
}

STDMETHODIMP MTNonRecurringChargeAdapter::SplitReverseState(long parentRunID,
																									long parentBillingGroupID,
																									long childRunID,
																									long childBillingGroupID)
{
	// we're "auto reverse" so we don't have to implement this
	return E_NOTIMPL;
}


STDMETHODIMP MTNonRecurringChargeAdapter::Shutdown()
{
	// nothing to do
	return S_OK;
}


STDMETHODIMP MTNonRecurringChargeAdapter::get_SupportsScheduledEvents(VARIANT_BOOL* pRetVal)
{
	*pRetVal = VARIANT_TRUE;
	return S_OK;
}


STDMETHODIMP MTNonRecurringChargeAdapter::get_SupportsEndOfPeriodEvents(VARIANT_BOOL* pRetVal)
{
	// scheduled only
	*pRetVal = VARIANT_FALSE;
	return S_OK;
}


STDMETHODIMP MTNonRecurringChargeAdapter::get_Reversibility(ReverseMode* pRetVal)
{
	// all we do is meter batches - that can be reversed automatically
	*pRetVal = ReverseMode_Auto;
	return S_OK;
}


STDMETHODIMP MTNonRecurringChargeAdapter::get_AllowMultipleInstances(VARIANT_BOOL* pRetVal)
{
	// yes, more than one of this adapter can run at one time
	*pRetVal = VARIANT_TRUE;
	return S_OK;
}

STDMETHODIMP MTNonRecurringChargeAdapter::get_BillingGroupSupport(BillingGroupSupportType* pRetVal)
{
	return E_NOTIMPL;
}

STDMETHODIMP MTNonRecurringChargeAdapter::get_HasBillingGroupConstraints(VARIANT_BOOL* pRetVal)
{
	return E_NOTIMPL;
}




// ----------------------------------------------------------------
// Name:     			MeterRowset
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------
// throws

void MTNonRecurringChargeAdapter::MeterRowset(_bstr_t ServiceDef,
																							ROWSETLib::IMTSQLRowsetPtr pRowset, 
																							RECURRINGEVENTADAPTERLib::IRecurringEventRunContextPtr context)
{
	ASSERT(pRowset->GetRowsetEOF().boolVal == VARIANT_FALSE);

	METERROWSETLib::IMeterRowsetPtr meterRowset("MetraTech.MeterRowset.1");
		
	meterRowset->InitSDK(L"NonRecurringChargesServer");

	//Set up service def
	meterRowset->InitForService(ServiceDef);
	mSequence++;
	_bstr_t strSequenceNumber(mSequence);
	METERROWSETLib::IBatchPtr batch = meterRowset->CreateAdapterBatch(context->GetRunID(), "NonRecurringCharges", strSequenceNumber);

	meterRowset->SessionSetSize = mMeteringConfig->SessionSetSize;
		
	mLogger.LogVarArgs(LOG_DEBUG, "created batch %s", (const char *) batch->UID);

	// meter rowset 
	meterRowset->MeterRowset((METERROWSETLib::IMTSQLRowsetPtr)pRowset);

	// wait for one hour for all sessions to be committed.
	meterRowset->WaitForCommit(meterRowset->MeteredCount, mMeteringConfig->CommitTimeout);

	long lastMetered = meterRowset->MeteredCount;
	long lastErrors = meterRowset->MeterErrorCount;

	mMetered += lastMetered;
	mErrors += lastErrors;

	char buffer[512];
	sprintf(buffer, "MeterRowset: %d sessions metered, %d errors. Total %d, %d errors.", 
					lastMetered, lastErrors, mMetered, mErrors);
	mLogger.LogVarArgs(LOG_DEBUG, buffer);
	context->RecordInfo(buffer);

	if (meterRowset->CommittedErrorCount > 0)
	{
		_bstr_t msg = _bstr_t(meterRowset->CommittedErrorCount);
		msg += " sessions failed during pipeline processing!";
		MT_THROW_COM_ERROR((const char *) msg);
	}

	if (meterRowset->MeterErrorCount > 0)
	{
		_bstr_t msg = _bstr_t(meterRowset->MeterErrorCount);
		msg += " sessions failed to be metered!";
		MT_THROW_COM_ERROR((const char *) msg);
	}
}
