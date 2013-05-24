/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR

* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header: MTAggRateAdapter.cpp, 9, 7/26/2002 5:55:14 PM, Raju Matta$
* 
***************************************************************************/

#include <metra.h>
#include <mtglobal_msg.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <loggerconfig.h>
#include "PCCache.h"

#include "MTAggRateAdapter.h"

//
// To easily invoke the adapter, type the following:
//
// usm test /adapter:Metratech.MTAggRateAdapter.1 /extension:SystemConfig /config:AggregateCharges.xml /type:eop /interval:34270
//


MTAggRateAdapter::MTAggRateAdapter()
{ }

STDMETHODIMP MTAggRateAdapter::Initialize(BSTR eventName,
																					 BSTR configFile,
																					 IMTSessionContext* context, 
																					 VARIANT_BOOL limitedInit)
{
	try
	{
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration("Database"), "[MTAggRateAdapter]");

		mEventName = eventName;
		mSessionContext = context;

		// loads the standard metering settings
		mMeteringConfig.CreateInstance(__uuidof(MetraTech_UsageServer::MeteringConfig));
		mMeteringConfig->Load(configFile, 1000, PCCache::GetBatchSubmitTimeout(), false);

		// loads the standard MetraFlow settings
		mMetraFlowConfig.CreateInstance(__uuidof(MetraTech_UsageServer::MetraFlowConfig));
		mMetraFlowConfig->Load(configFile);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP MTAggRateAdapter::Execute(IRecurringEventRunContext* apRunContext,
 																			 BSTR* apDetails)
{
	try
	{
		MetraTech_UsageServer::IRecurringEventRunContextPtr runContext(apRunContext);

		// gets all templates of aggregate charge kind
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));
		MTObjectCollection<IMTPriceableItem> CollTemplates;
		CollTemplates =  
			(IMTCollection*) reader->FindTemplatesByKind(
				((MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr) mSessionContext).GetInterfacePtr(),
				(MTPRODUCTCATALOGEXECLib::MTPCEntityType) PCENTITY_TYPE_AGGREGATE_CHARGE).GetInterfacePtr();

		// iterates over all aggregate charge templates
		bool failure = false;
		_com_error * firstError = NULL;
		long totalCharges = 0;
		long lNumTemplates;
		CollTemplates.Count(&lNumTemplates);
		for (int i = 1; i <= lNumTemplates; ++i) 
		{
			// casts each template to IMTAggregateCharge*
			MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggregateCharge;
			MTPRODUCTCATALOGLib::IMTPriceableItemPtr pi;
			CollTemplates.Item(i, (IMTPriceableItem**) &pi);

			aggregateCharge = reinterpret_cast<IMTAggregateCharge*> (pi.GetInterfacePtr());
			
			// rates only parents
			// NOTE: parents are responsible for calling Rate on their children
			if (aggregateCharge->GetParent() == NULL) 
			{
				_bstr_t msg = "Processing aggregate charge '";
				msg += pi->Name;
				msg += "' with template ID ";
				msg += _bstr_t(pi->ID);
				runContext->RecordInfo(msg);
				mLogger.LogThis(LOG_INFO, (const char *) msg);

				long chargesGenerated = 0;
				try
				{
					aggregateCharge->RateRemoteForRecurringEvent(mMeteringConfig->SessionSetSize,
                                                       mMeteringConfig->CommitTimeout,
                                                       mMeteringConfig->FailImmediately,
                                                       mEventName,
                                                       (MTPRODUCTCATALOGLib::IRecurringEventRunContext *) apRunContext,
                                                       reinterpret_cast<MTPRODUCTCATALOGLib::IMetraFlowConfig *>(mMetraFlowConfig.GetInterfacePtr()),
                                                       &chargesGenerated);
				} 
				catch (_com_error & err)
				{
					if (mMeteringConfig->FailImmediately)
						throw;
					else
					{
						string msg;
						StringFromComError(msg, "A failure occurred while processing an aggregate charge template", err);
						runContext->RecordWarning(_bstr_t(msg.c_str()));

						// continues on for now, but will fail the adapter ultimately
						failure = true;
						
						// makes a copy of the first exception to save for later
						if (firstError == NULL)
							firstError = new _com_error(err);
					}
				}
				
				totalCharges += chargesGenerated;
			}
		}	

		if (failure)
		{
			_com_error err(*firstError);
			delete firstError;
			throw err;
		}

		_bstr_t details;
		details += _bstr_t(totalCharges);
		details += " aggregate charges generated";
		*apDetails = details.copy();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP MTAggRateAdapter::Reverse(IRecurringEventRunContext * apRunContext, 
																			 BSTR * apDetails)
{
	// we're "auto reverse" so we don't have to implement this and nothing should call this
	return E_NOTIMPL;
}

STDMETHODIMP MTAggRateAdapter::CreateBillingGroupConstraints(long intervalID,
                                                             long materializationID)
{
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init("queries\\ProductCatalog");
	rowset->SetQueryTag("__CREATE_AGGREGATE_ADAPTER_BILLING_GROUP_CONSTRAINTS__");
	rowset->AddParam("%%ID_USAGE_INTERVAL%%", intervalID);
	rowset->AddParam("%%ID_MATERIALIZATION%%", materializationID);
	
	rowset->Execute();

	return S_OK;
}

STDMETHODIMP MTAggRateAdapter::SplitReverseState(long parentRunID,
																									long parentBillingGroupID,
																									long childRunID,
																									long childBillingGroupID)
{
	// we're "auto reverse" so we don't have to implement this and nothing should call this
	return E_NOTIMPL;
}


STDMETHODIMP MTAggRateAdapter::Shutdown()
{
	// nothing to do
	return S_OK;
}

STDMETHODIMP MTAggRateAdapter::get_SupportsScheduledEvents(VARIANT_BOOL* pRetVal)
{
	// end of period only
	*pRetVal = VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP MTAggRateAdapter::get_SupportsEndOfPeriodEvents(VARIANT_BOOL* pRetVal)
{
	// end of period only
	*pRetVal = VARIANT_TRUE;
	return S_OK;
}

STDMETHODIMP MTAggRateAdapter::get_Reversibility(ReverseMode* pRetVal)
{
	*pRetVal = ReverseMode_Auto;
	return S_OK;
}

STDMETHODIMP MTAggRateAdapter::get_AllowMultipleInstances(VARIANT_BOOL* pRetVal)
{
	// yes, more than one of this adapter can run at one time
	*pRetVal = VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP MTAggRateAdapter::get_BillingGroupSupport(BillingGroupSupportType* pRetVal)
{
  *pRetVal = BillingGroupSupportType_Account;
	return S_OK;
}

STDMETHODIMP MTAggRateAdapter::get_HasBillingGroupConstraints(VARIANT_BOOL* pRetVal)
{
	*pRetVal = VARIANT_TRUE;
	return S_OK;
}

