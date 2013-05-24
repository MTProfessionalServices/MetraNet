	
// MTAggregateCharge.h : Declaration of the CMTAggregateCharge

#ifndef __MTAGGREGATECHARGE_H_
#define __MTAGGREGATECHARGE_H_

#include "resource.h"       // main symbols
#include "MTProductCatalog.h"
#include "MTPriceableItem.h"
#include <mtprogids.h>
#include <ProductViewCollection.h>

#include <map>
#include <list>
#include <string>

//using MTPRODUCTCATALOGLib::IMTProductCatalogPtr;
using MTPRODUCTCATALOGLib::IMTPriceableItemPtr;
using MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr;
using MTPRODUCTCATALOGLib::IMTAggregateChargePtr;

typedef std::map<string, long> StringToLongMap;
typedef std::map<long, MTPRODUCTCATALOGLib::IMTCounterPtr> LongToCounterMap;
typedef std::list<long> LongList;

#import <MetraTech.UsageServer.tlb> inject_statement("using namespace mscorlib;") inject_statement("using namespace ROWSETLib;") inject_statement("using MTAuthInterfacesLib::IMTSessionContextPtr;")

/////////////////////////////////////////////////////////////////////////////
// CMTAggregateCharge
class ATL_NO_VTABLE CMTAggregateCharge : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAggregateCharge, &CLSID_MTAggregateCharge>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAggregateCharge, &IID_IMTAggregateCharge, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPriceableItem
{
public:
	CMTAggregateCharge()	{
		m_pUnkMarshaler = NULL;
	}

	DECLARE_REGISTRY_RESOURCEID(IDR_MTAGGREGATECHARGE)
		DECLARE_GET_CONTROLLING_UNKNOWN()

		DECLARE_PROTECT_FINAL_CONSTRUCT()

		BEGIN_COM_MAP(CMTAggregateCharge)
		COM_INTERFACE_ENTRY(IMTAggregateCharge)
  	COM_INTERFACE_ENTRY(IMTPriceableItem)
		COM_INTERFACE_ENTRY(IMTPCBase)
		COM_INTERFACE_ENTRY(IDispatch)
		COM_INTERFACE_ENTRY(ISupportErrorInfo)
		COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
		END_COM_MAP()


	HRESULT FinalConstruct();

	void FinalRelease() {
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTPriceableItem
public:
	DEFINE_MT_PRICABLE_ITEM_METHODS
	virtual void CopyNonBaseMembersTo(IMTPriceableItem* apTarget);

// IMTAggregateCharge
public:
	bool IsValidCounterPropertyDefinitionID(long lCounterPropertyDefinitionID);

	STDMETHOD(get_Cycle)(/*[out, retval]*/ IMTPCCycle* *pVal);
	STDMETHOD(GetCounter)(long aCPDId, /*[out, retval]*/IMTCounter **ppCounter);
	STDMETHOD(SetCounter)(long aCPDId, IMTCounter *pCounter);
	STDMETHOD(get_RemovedCounters)(/*[out, retval]*/ IMTCollection** pVal);
	STDMETHOD(Rate)(long aUsageIntervalID, long aSessionSetSize);
	STDMETHOD(RateAccount)(long aUsageIntervalID, long aAccountID);
	STDMETHOD(RateAccountAsynch)(long aUsageIntervalID, long aAccountID);

	STDMETHOD(RateForRecurringEvent)(long aSessionSetSize,
																	 long aCommitTimeout,
																	 VARIANT_BOOL aFailImmediately,
																	 BSTR aEventName,
																	 IRecurringEventRunContext* apRunContext,
																	 long * apChargesGenerated);

	STDMETHOD(RateRemoteForRecurringEvent)(long aSessionSetSize,
                                         long aCommitTimeout,
                                         VARIANT_BOOL aFailImmediately,
                                         BSTR aEventName,
                                         IRecurringEventRunContext* apRunContext,
                                         IMetraFlowConfig * apMetraFlowConfig,
                                         long * apChargesGenerated);

	STDMETHOD(get_FirstPassProductView)(BSTR* pVal);
	STDMETHOD(get_SecondPassServiceDefinition)(BSTR* pVal);


	//
	// INTERNAL USE ONLY
	//
	STDMETHOD(GetRowsetForParent)(long aUsageIntervalID, long aAccountID,
																IRecurringEventRunContext* apRunContext,
																/*[out]*/ BSTR * dropChildTable1Query,
																/*[out]*/ BSTR * dropChildTable2Query,
																/*[out, retval]*/ ::IMTSQLRowset** apRowset);

	STDMETHOD(RemovePVRecords)(long aUsageIntervalID, long aAccountID,
														 IRecurringEventRunContext* apRunContext);

//CMTPCBase override
	virtual void OnSetSessionContext(IMTSessionContext* apSessionContext);


private:
	NTLogger mLogger;

	//map of CPD id's to counters associated with this aggregate charge
	LongToCounterMap mCounterMap;

	//list of counter IDs that WERE associated with this aggregate charge
	//but were updated and have to be removed on 'Save'
	LongList mOldCounters;

private:
	HRESULT RateInternal(long aUsageIntervalID, long aAccountID, bool aWaitForCommit,
											 long aSessionSetSize, long aCommitTimeout, bool aFailImmediately,
											 BSTR eventName, IRecurringEventRunContext* apRunContext,
											 long * apChargesGenerated);

	HRESULT RateInternal2(long aUsageIntervalID, long aAccountID, bool aWaitForCommit,
											 long aSessionSetSize, long aCommitTimeout, bool aFailImmediately,
											 BSTR eventName, IRecurringEventRunContext* apRunContext, IMetraFlowConfig * apMetraFlowConfig,
											 long * apChargesGenerated);

	HRESULT ExecuteQuery(ROWSETLib::IMTSQLRowset* apRowset, 
											 long aUsageIntervalID,
											 long aAccountID,
											 bool aChild,
											 IRecurringEventRunContext* apRunContext,
											 _bstr_t & dropTable1Query,
											 _bstr_t & dropTable2Query);

	HRESULT ProcessCounters(std::vector<std::string>& arCounterFormulas, 
													std::map<std::string, std::string>& arCountableProductViews,
													std::map<std::string, std::string>& arCountableProperties, 
													std::vector<std::string>& arCounterFormulaAliases);

	HRESULT GetProductViewProps(const char * apProductViewName,
															string& arTableName,
															vector<string>& arProperties);
};

#endif //__MTAGGREGATECHARGE_H_
