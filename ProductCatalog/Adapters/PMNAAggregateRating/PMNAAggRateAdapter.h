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

// PMNAAggRateAdapter.h : Declaration of the PMNAAggRateAdapter

#ifndef __PMNAAGGRATEADAPTER_H_
#define __PMNAAGGRATEADAPTER_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <MTObjectCollection.h>

#import <MTProductCatalog.tlb>     rename("EOF", "RowsetEOF")
#import <MTProductCatalogExec.tlb> rename("EOF", "RowsetEOF")
#import <MTAuthLib.tlb>            rename("EOF", "RowsetEOF")
#import <Rowset.tlb>               rename ("EOF", "RowsetEOF") 
#import <mscorlib.tlb>             rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")

#import <MetraTech.UsageServer.tlb> inject_statement("using namespace mscorlib; using namespace ROWSETLib; using MTAuthInterfacesLib::IMTSessionContextPtr;")

//#import <PMNAAggRate.tlb> rename("EOF", "RCEOF")
//#include "PMNAAggRate.h"


using MTPRODUCTCATALOGLib::IMTProductCatalogPtr;
using MTAuthInterfacesLib::IMTSessionContextPtr;

class ATL_NO_VTABLE PMNAAggRateAdapter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<PMNAAggRateAdapter, &CLSID_PMNAAggRateAdapter>,
	public ISupportErrorInfo,
	public IDispatchImpl<IPMNAAggRateAdapter, &IID_IPMNAAggRateAdapter, &LIBID_PMNAAGGRATELib>
{

public:
	PMNAAggRateAdapter();


DECLARE_REGISTRY_RESOURCEID(IDR_PMNAAGGRATEADAPTER)

DECLARE_PROTECT_FINAL_CONSTRUCT()


BEGIN_COM_MAP(PMNAAggRateAdapter)
	COM_INTERFACE_ENTRY(IPMNAAggRateAdapter)
	COM_INTERFACE_ENTRY(IRecurringEventAdapter)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

public:


	STDMETHOD(Initialize)(BSTR eventName,
												BSTR configFile, 
												IMTSessionContext* context, 
												VARIANT_BOOL limitedInit);

	STDMETHOD(Execute)(IRecurringEventRunContext* context, 
										 BSTR* detail);
	
	STDMETHOD(Reverse)(IRecurringEventRunContext* context, 
										 BSTR* detail);
	
	STDMETHOD(Shutdown)();
	STDMETHOD(get_SupportsScheduledEvents)(VARIANT_BOOL* pRetVal);
	STDMETHOD(get_SupportsEndOfPeriodEvents)(VARIANT_BOOL* pRetVal);
	STDMETHOD(get_Reversibility)(ReverseMode* pRetVal);
	STDMETHOD(get_AllowMultipleInstances)(VARIANT_BOOL* pRetVal);

	STDMETHOD(RateAllAggregateCharges)(long aUsageIntervalID, long aSessionSetSize);

private:

	HRESULT Rate(long aUsageIntervalID,
							 long aAccountID,
							 bool aWaitForCommit,
							 long aSessionSetSize);


private:
	NTLogger mLogger;
	MetraTech_UsageServer::IMeteringConfigPtr mMeteringConfig;
	IMTSessionContextPtr mSessionContext;
	_bstr_t mEventName;
};

#endif 
