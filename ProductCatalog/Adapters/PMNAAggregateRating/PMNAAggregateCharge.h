#ifndef __PMNAAGGREGATECHARGE_H_
#define __PMNAAGGREGATECHARGE_H_

#include <mtprogids.h>
#include <ProductViewCollection.h>
#include <MSIX.h>
#include <mttime.h>

#include <map>
#include <list>
#include <string>


#import <Rowset.tlb>               rename ("EOF", "RowsetEOF") 
#import <Counter.tlb> rename("EOF", "RowsetEOF") no_function_mapping
#import <MTProductCatalog.tlb>     rename("EOF", "RowsetEOF")
#import <MTProductCatalogExec.tlb> rename("EOF", "RowsetEOF")
#import <MTAuthLib.tlb>            rename("EOF", "RowsetEOF")
#import <mscorlib.tlb>             rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MeterRowset.tlb> rename("EOF", "RowsetEOF")
#import <MTNameIDLib.tlb> 

#import <MetraTech.UsageServer.tlb> inject_statement("using namespace mscorlib; using namespace ROWSETLib; using MTAuthInterfacesLib::IMTSessionContextPtr;")

//class IMTAggregateChargePtr;
//struct IRecurringEventRunContext;

typedef std::map<string, long> StringToLongMap;
typedef std::map<long, MTCOUNTERLib::IMTCounterPtr> LongToCounterMap;
typedef std::list<long> LongList;

using MTPRODUCTCATALOGLib::IMTAggregateChargePtr;
//using MTPRODUCTCATALOGLib::IRecurringEventRunContext;

/////////////////////////////////////////////////////////////////////////////
// CPMNAAggregateCharge
class PMNAAggregateCharge  
{
public:
	PMNAAggregateCharge();

	HRESULT Rate(long aUsageIntervalID,
							 long aSessionSetSize,
							 MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggregateCharge);

	HRESULT RateForRecurringEvent(long aSessionSetSize,
																long aCommitTimeout,
																VARIANT_BOOL aFailImmediately,
																BSTR aEventName,
																MTPRODUCTCATALOGLib::IRecurringEventRunContext* apRunContext,
																long * apChargesGenerated,
																IMTAggregateChargePtr aggregateCharge);

	//
	// INTERNAL USE ONLY
	//
	HRESULT GetRowsetForParent(long aUsageIntervalID, long aAccountID,
														 MTPRODUCTCATALOGLib::IRecurringEventRunContext* apRunContext,
														 /*[out]*/ BSTR * dropChildTable1Query,
														 /*[out]*/ BSTR * dropChildTable2Query,
														 IMTAggregateChargePtr aggregateCharge);


private:
	HRESULT RateInternal(long aUsageIntervalID, long aAccountID, bool aWaitForCommit,
											 long aSessionSetSize, long aCommitTimeout, bool aFailImmediately,
											 BSTR eventName, MTPRODUCTCATALOGLib::IRecurringEventRunContext* apRunContext,
											 long * apChargesGenerated,
											 IMTAggregateChargePtr aggregateCharge);

	HRESULT ExecuteQuery(ROWSETLib::IMTSQLRowset* apRowset, 
											 long aUsageIntervalID,
											 long aAccountID,
											 _bstr_t batchID,
											 bool aChild,
											 MTPRODUCTCATALOGLib::IRecurringEventRunContext* apRunContext,
											 _bstr_t & dropTable1Query,
											 _bstr_t & dropTable2Query,
											 IMTAggregateChargePtr aggregateCharge);

	HRESULT ProcessCounters(std::vector<std::string>& arCounterFormulas, 
													std::map<std::string, std::string>& arCountableProductViews,
													std::map<std::string, std::string>& arCountableProperties, 
													std::vector<std::string>& arCounterFormulaAliases,
													IMTAggregateChargePtr aggregateCharge);

	HRESULT GetProductViewProps(const char * apProductViewName,
															string& arTableName,
															vector<string>& arProperties);

	HRESULT MeterDirect(long sessionSetSize);

private:
	NTLogger mLogger;

	//map of CPD id's to counters associated with this aggregate charge
	LongToCounterMap mCounterMap;
};

#endif //__PMNAAGGREGATECHARGE_H_
