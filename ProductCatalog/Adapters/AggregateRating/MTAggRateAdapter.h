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
* $Header$
* 
***************************************************************************/

// MTAggRateAdapter.h : Declaration of the CMTAggRateAdapter

#ifndef __MTAGGRATEADAPTER_H_
#define __MTAGGRATEADAPTER_H_

#include <RecurringEventSkeleton.h>
#include <NTLogger.h>
#include <MTObjectCollection.h>

#import <MTProductCatalog.tlb>     rename("EOF", "RowsetEOF")
#import <MTProductCatalogExec.tlb> rename("EOF", "RowsetEOF")
#import <MTAuthLib.tlb>            rename("EOF", "RowsetEOF")
#import <Rowset.tlb>               rename ("EOF", "RowsetEOF") 
#import <mscorlib.tlb>             rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")

#import <MetraTech.UsageServer.tlb> inject_statement("using namespace mscorlib; using namespace ROWSETLib; using MTAuthInterfacesLib::IMTSessionContextPtr;")

using MTPRODUCTCATALOGLib::IMTProductCatalogPtr;
using MTAuthInterfacesLib::IMTSessionContextPtr;


CLSID CLSID_MTAggRateAdapter = { // d200fd7b-5471-4710-a433-34b7a86b469d
	0xd200fd7b,
	0x5471,
	0x4710,
	{0xA4, 0x33, 0x34, 0xB7, 0xA8, 0x6B, 0x46, 0x9D}
};


class ATL_NO_VTABLE MTAggRateAdapter 
	: public MTRecurringEventSkeleton<MTAggRateAdapter, &CLSID_MTAggRateAdapter>
{

public:
	MTAggRateAdapter();

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

private:
	NTLogger mLogger;
	MetraTech_UsageServer::IMeteringConfigPtr mMeteringConfig;
	MetraTech_UsageServer::IMetraFlowConfigPtr mMetraFlowConfig;
	IMTSessionContextPtr mSessionContext;
	_bstr_t mEventName;
};


PLUGIN_INFO(CLSID_MTAggRateAdapter,
						MTAggRateAdapter,
						"Metratech.MTAggRateAdapter.1",
						"Metratech.MTAggRateAdapter",
						"Free")



#endif 
