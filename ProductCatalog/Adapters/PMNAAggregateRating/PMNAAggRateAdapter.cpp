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
* $Header: PMNAAggRateAdapter.cpp, 9, 7/26/2002 5:55:14 PM, Raju Matta$
* 
***************************************************************************/

#include "StdAfx.h"
#include "PMNAAggRate.h"

#include <metra.h>
#include <mtglobal_msg.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <loggerconfig.h>
#include "PCCache.h"

#include "PMNAAggRateAdapter.h"
#include <PMNAAggregateCharge.h>

//
// To easily invoke the adapter, type the following:
//
// usm test /adapter:Metratech.PMNAAggRateAdapter.1 /extension:SystemConfig /config:AggregateCharges.xml /type:eop /interval:34270
//

STDMETHODIMP PMNAAggRateAdapter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IPMNAAggRateAdapter,
    &IID_IRecurringEventAdapter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}



PMNAAggRateAdapter::PMNAAggRateAdapter()
{ }

STDMETHODIMP PMNAAggRateAdapter::Initialize(BSTR eventName,
																					 BSTR configFile,
																					 IMTSessionContext* context, 
																					 VARIANT_BOOL limitedInit)
{
	try
	{
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration("Database"), "[PMNAAggRateAdapter]");

		mEventName = eventName;
		mSessionContext = context;

		// loads the standard metering settings
		mMeteringConfig.CreateInstance(__uuidof(MetraTech_UsageServer::MeteringConfig));
		mMeteringConfig->Load(configFile, 1000, PCCache::GetBatchSubmitTimeout(), false);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP PMNAAggRateAdapter::Execute(IRecurringEventRunContext* apRunContext,
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

			PMNAAggregateCharge pmnaAggregateCharge;
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
					HRESULT hr = pmnaAggregateCharge.RateForRecurringEvent(mMeteringConfig->SessionSetSize,
																																 mMeteringConfig->CommitTimeout,
																																 mMeteringConfig->FailImmediately,
																																 mEventName,
																																 (MTPRODUCTCATALOGLib::IRecurringEventRunContext *) apRunContext,
																																 &chargesGenerated,
																																 aggregateCharge);
					if (FAILED(hr))
						MT_THROW_COM_ERROR(hr);
					
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

//
// Reverses the adapter.
//
// By deleting the t_acc_usage/pv rows first, billing rerun has less work to do
// and should be much faster.
// In 4.0, billing rerun should be able to handle this and so replaced by reversemode_auto
STDMETHODIMP PMNAAggRateAdapter::Reverse(IRecurringEventRunContext * apRunContext, 
																			 BSTR * apDetails)
{
	
	
	return S_OK;
}

STDMETHODIMP PMNAAggRateAdapter::Shutdown()
{
	// nothing to do
	return S_OK;
}

STDMETHODIMP PMNAAggRateAdapter::get_SupportsScheduledEvents(VARIANT_BOOL* pRetVal)
{
	// end of period only
	*pRetVal = VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP PMNAAggRateAdapter::get_SupportsEndOfPeriodEvents(VARIANT_BOOL* pRetVal)
{
	// end of period only
	*pRetVal = VARIANT_TRUE;
	return S_OK;
}

STDMETHODIMP PMNAAggRateAdapter::get_Reversibility(ReverseMode* pRetVal)
{
	*pRetVal = ReverseMode_Auto;
	return S_OK;
}

STDMETHODIMP PMNAAggRateAdapter::get_AllowMultipleInstances(VARIANT_BOOL* pRetVal)
{
	// yes, more than one of this adapter can run at one time
	*pRetVal = VARIANT_TRUE;
	return S_OK;
}






// ********************************************************
// Non-adapter methods to be used by the Estimate.vbs script
// taken from s:/ProductCatalog/MTProductCatalog/ProductCatalog.cpp
// ********************************************************

STDMETHODIMP PMNAAggRateAdapter::RateAllAggregateCharges(long aUsageIntervalID, long aSessionSetSize)
{
	return Rate(aUsageIntervalID, NULL, true, aSessionSetSize);
}

/// NON COM - INTERNAL USE ONLY
// iterates over all aggregate charge priceable item templates who are not children
// calls MTAggregateCharge::Rate(aUsageIntervalID)
HRESULT PMNAAggRateAdapter::Rate(long aUsageIntervalID,
																 long aAccountID,
																 bool aWaitForCommit,
																 long aSessionSetSize)
{
	try {
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));

		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt(MTPROGID_MTSESSIONCONTEXT);

		//get all templates of PCENTITY_TYPE_AGGREGATE_CHARGE kind
		MTObjectCollection<IMTPriceableItem> CollTemplates;
		CollTemplates =  (IMTCollection*) reader->FindTemplatesByKind(
			((MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr) ctxt).GetInterfacePtr(),
			( MTPRODUCTCATALOGEXECLib::MTPCEntityType)PCENTITY_TYPE_AGGREGATE_CHARGE).GetInterfacePtr();

		long lNumTemplates;
		CollTemplates.Count(&lNumTemplates);
		for (int i = 1; i <= lNumTemplates; ++i) {
			//casts each template to IMTAggregateCharge*
			MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggregateCharge;
			MTPRODUCTCATALOGLib::IMTPriceableItemPtr pi;
			CollTemplates.Item(i, (IMTPriceableItem**) &pi);
			aggregateCharge = reinterpret_cast<IMTAggregateCharge*> (pi.GetInterfacePtr());
			
			//rates only parents (parents are responsible for calling Rate on children)
			if (aggregateCharge->GetParent() == NULL) 
			{
				PMNAAggregateCharge pmnaAggregateCharge;
				HRESULT hr = pmnaAggregateCharge.Rate(aUsageIntervalID, aSessionSetSize, aggregateCharge);
				if (FAILED(hr))
					throw new _com_error(hr);
			}
		}	
	}
	catch (_com_error & err)
	{	return LogAndReturnComError(mLogger,err);}

	return S_OK;
}


