// MTRecurringChargeAdapter.h : Declaration of the CMTRecurringChargeAdapter

#ifndef __MTRECURRINGCHARGEADAPTER_H_
#define __MTRECURRINGCHARGEADAPTER_H_

#include "resource.h"       // main symbols

#include "NTLogger.h"
#include <PCCache.h>

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" ) 
const TCHAR CONFIG_DIR[] = _T("queries\\ProductCatalog");

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MTAuthLib.tlb> rename ("EOF", "RowsetEOF")
#import <MetraTech.UsageServer.tlb> inject_statement("using namespace mscorlib;") inject_statement("using namespace ROWSETLib;") inject_statement("using MTAuthInterfacesLib::IMTSessionContextPtr;")

/////////////////////////////////////////////////////////////////////////////
// CMTRecurringChargeAdapter
class ATL_NO_VTABLE CMTRecurringChargeAdapter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRecurringChargeAdapter, &CLSID_MTRecurringChargeAdapter>,
	public ISupportErrorInfo,
	public IDispatchImpl<IRecurringEventAdapter2, &IID_IRecurringEventAdapter2, &LIBID_RECURRINGCHARGEADAPTERLib>
{
public:
	CMTRecurringChargeAdapter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTRECURRINGCHARGEADAPTER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTRecurringChargeAdapter)
	COM_INTERFACE_ENTRY(IRecurringEventAdapter2)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

public:

	STDMETHOD(Initialize)(BSTR eventName, BSTR configFile, 
                        IMTSessionContext* context, 
                        VARIANT_BOOL limitedInit);
	STDMETHOD(Execute)(
		IRecurringEventRunContext* context, 
		BSTR* detail);

	STDMETHOD(Reverse)(IRecurringEventRunContext* context, 
										 BSTR* detail);

	STDMETHOD(Shutdown)();
  STDMETHOD(CreateBillingGroupConstraints)(long intervalID, long materializationID);
  STDMETHOD(SplitReverseState)(long parentRunID, 
                               long parentBillingGroupID,
                               long childRunID, 
                               long childBillingGroupID);
	STDMETHOD(get_SupportsScheduledEvents)(VARIANT_BOOL* pRetVal);
	STDMETHOD(get_SupportsEndOfPeriodEvents)(VARIANT_BOOL* pRetVal);
	STDMETHOD(get_Reversibility)(ReverseMode* pRetVal);
	STDMETHOD(get_AllowMultipleInstances)(VARIANT_BOOL* pRetVal);
	STDMETHOD(get_BillingGroupSupport)(BillingGroupSupportType* pRetVal);
	STDMETHOD(get_HasBillingGroupConstraints)(VARIANT_BOOL* pRetVal);

private:
	HRESULT ReportError( const char* str_errmsg , HRESULT hr);
	void MeterRCType(MetraTech_UsageServer::IRecurringEventRunContextPtr context,
									 const _bstr_t& aServiceDef, long lTypeID, MTPCEntityType kind, long lIntervalID, long lBillingGroupID);

	MetraTech_UsageServer::IMeteringConfigPtr mMeteringConfig;

	NTLogger mLogger;
	_bstr_t m_ConfigPath ;

	// for batch diagnostic
	long	mMetered;
	long	mErrors;
};



#endif //__MTRECURRINGCHARGEADAPTER_H_
