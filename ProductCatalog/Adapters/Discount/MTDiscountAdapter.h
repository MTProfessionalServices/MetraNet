/**************************************************************************
 * @doc MTDISCOUNTADAPTER
 *
 * Copyright 1998 - 2002 by MetraTech Corporation
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
 * Created by: 
 *
 * $Date: 9/11/2002 9:34:18 AM$
 * $Author: Alon Becker$
 * $Revision: 5$
 ***************************************************************************/


#pragma warning (disable : 4800)

#include <RecurringEventSkeleton.h>
#include <mtprogids.h>
#include <PCCache.h>
#include <ConfigDir.h>
#include <mtcomerr.h>
#include <loggerconfig.h>
#include <stdutils.h>
#include <DBMiscUtils.h>
#include <MTUtil.h>
#include <DataAccessDefs.h>


#include <set>
#include <map>

#import <RecurringEventAdapterLib.tlb> rename( "EOF", "RowsetEOF" )
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <MeterRowset.tlb> rename("EOF", "RowsetEOF")
#import <MTConfigLib.tlb> rename("EOF", "RowsetEOF")
#import <Counter.tlb> rename("EOF", "RowsetEOF")
#import <MTAuthLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTProductViewExec.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.UsageServer.tlb> inject_statement("using namespace mscorlib; using namespace ROWSETLib; using MTAuthInterfacesLib::IMTSessionContextPtr;")
//#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")
#import <MetraTech.DataAccess.MaterializedViews.tlb>




CLSID CLSID_MTDiscountAdapter = { // 52a61245-1351-44a3-b481-a5c62f86e21a
	0x52a61245,
	0x1351,
	0x44a3,
	{0xB4, 0x81, 0xA5, 0xC6, 0x2F, 0x86, 0xE2, 0x1A}
};


struct QueryParameters
{
  _bstr_t counters;         // %%COUNTERS%%
	_bstr_t outerJoins;       // %%COUNTER_USAGE_OUTER_JOINS%%
  _bstr_t adjustmentOuterJoins;             // %%COUNTER_ADJUSTMENT_OUTER_JOINS%%
  _bstr_t distributionAdjustmentOuterJoins; // %%COUNTER_DISTRIBUTION_ADJUSTMENT_OUTER_JOINS%%
	_bstr_t accUsageJoin;     // %%OPTIONAL_ACC_USAGE_JOIN%%
	_bstr_t infoLabel;        // %%INFO_LABEL%%

	_bstr_t groupExposeCounters;    // %%EXPOSE_COUNTERS%%
	_bstr_t groupSubSelect;         // %%COUNTERS_SUBSELECT%%
	_bstr_t distributionCounter;    // %%DISTRIBUTION_COUNTER%%
	_bstr_t distributionOuterJoins; // %%DISTRIBUTION_USAGE_OUTER_JOINS%%
	_bstr_t groupAccUsageFilter;    // %%ACC_USAGE_FILTER%%

	long interval;            // %%ID_INTERVAL%%

	long cpdCount;            // used to build %%INFO_LABEL%%
};

class AdjustmentParam
{
public:
  bool ChargeBased;
  _bstr_t AdjustmentTableName;
  _bstr_t ProductViewTableName;
  long ViewID;
};



void TruncateTempTable(ROWSETLib::IMTSQLRowsetPtr aRowset, BOOL aDebugMode, BOOL aIsOracle);

class AutoTruncate
{
public:
	AutoTruncate(ROWSETLib::IMTSQLRowsetPtr aRowset, BOOL aDebugMode, BOOL aIsOracle) 
		: mRowset(aRowset), mDebugMode(aDebugMode), mIsOracle(aIsOracle)
	{ }

	~AutoTruncate()
	{
		if (!mDebugMode)
			TruncateTempTable(mRowset, mDebugMode, mIsOracle);
	}
	
private:
	ROWSETLib::IMTSQLRowsetPtr mRowset;
	BOOL mDebugMode;
	BOOL mIsOracle;
};

class ATL_NO_VTABLE MTDiscountAdapter 
	: public MTRecurringEventSkeleton<MTDiscountAdapter, &CLSID_MTDiscountAdapter>
{
public: 
	MTDiscountAdapter();

	//IRecurringEventAdapter2
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

	void CalculateDiscounts(MTPRODUCTCATALOGLib::IMTDiscountPtr aDiscount,
													MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr aDiscountType);
	
	void CalculateSimpleDiscount(long aIntervalID,
															 QueryParameters & queryParams,
															 MTPRODUCTCATALOGLib::IMTDiscountPtr aDiscount,
															 MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr aDiscountType);
	void CalculateGroupDiscount(long aIntervalID,
															QueryParameters & queryParams,
															MTPRODUCTCATALOGLib::IMTDiscountPtr aDiscount,
															MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr aDiscountType);


	void ProcessCounters(MTPRODUCTCATALOGLib::IMTDiscountPtr aDiscount,
											 QueryParameters & queryParams);


	_bstr_t GenerateAdjustmnetJoins(std::map<long, AdjustmentParam> & adjustmentParams);


	HRESULT AllCountersAreSet(MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr & PIType,
														MTPRODUCTCATALOGLib::IMTDiscountPtr & PI,
														BOOL* aRet);

	void PrepareTempTable(long aIntervalID,
												long aTemplateID,
												bool aIsGroupDiscount,
												ROWSETLib::IMTSQLRowsetPtr aRowset);
	void AddTempTableInsertionParams(ROWSETLib::IMTSQLRowsetPtr aRowset,
																	 const char * apTableName);

	void MeterRowset(MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr aDiscountType,
									 long aIntervalID,
									 ROWSETLib::IMTSQLRowsetPtr aRowset,
									 long & aSuccessfulSessions,
									 _bstr_t aSequence);

	void ExecuteSummaryQuery(const QueryParameters & aParams,
													 ROWSETLib::IMTSQLRowsetPtr aRowset);
	void ExecuteGroupSummaryQuery(const QueryParameters & aParams,
																ROWSETLib::IMTSQLRowsetPtr aRowset);
	void ExecuteProportionalDistributionQuery(const QueryParameters & aParams,
																						ROWSETLib::IMTSQLRowsetPtr aRowset);
  // Shared by MetraFlow pass 2 and legacy pass 2 calculations.
	void ExecuteSingleAccountDistributionQuery(ROWSETLib::IMTSQLRowsetPtr aRowset);
	void ExecuteFinalGroupDiscountQuery(ROWSETLib::IMTSQLRowsetPtr aRowset);

  // Methods for the new MetraFlow shared discount pass 2 queries.
  void GroupDiscountSecondPassMetraFlow(ROWSETLib::IMTSQLRowsetPtr aRowset);
  void GroupDiscountMeterSecondPassMetraFlow(ROWSETLib::IMTSQLRowsetPtr aRowset, 
                                             long aIntervalID, 
                                             MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr aDiscountType);
  void ExecuteProportionalDistributionQueryMetraFlow(ROWSETLib::IMTSQLRowsetPtr aRowset);
  
	_bstr_t ConstructInfoLabel(const _bstr_t aDiscountName,
														 const _bstr_t aDiscountDisplayName,
														 long aDiscountID,
														 long aNumCPDs);

	HRESULT ParseConfigFile(_bstr_t & arConfigFile);

  MTAuthInterfacesLib::IMTSessionContextPtr mCtx;

	// overrides %%%TEMP_TABLE_PREFIX%%% so that we use
	// permanent tables in SQL Server (not so easy to do in Oracle)
	// NOTE: strictly for debugging
	template<class T> void OverrideTempTablePrefix(T query) 
	{
		if (mDebugTempTables && !mIsOracle)
			query->AddParam("%%%TEMP_TABLE_PREFIX%%%", "");
	}


private:
	NTLogger mLogger;
	QUERYADAPTERLib::IMTQueryAdapterPtr mQueryAdapter;

	bool mIsOracle;
	bool mIsEndOfPeriod;

	MetraTech_UsageServer::IRecurringEventRunContextPtr mRunContext;
	MetraTech_UsageServer::IMeteringConfigPtr mMeteringConfig;
	MetraTech_UsageServer::IMetraFlowConfigPtr mMetraFlowConfig;
	bstr_t mEventName;

	BOOL mProcessSimpleDiscounts;
	BOOL mProcessGroupDiscounts;

	BOOL mSingleDiscountMode;
	long mSingleTemplateID;

	BOOL mDebugTempTables;

	long mTotalDiscounts;

	bool mbUseMaterializedViews;
	MetraTech_DataAccess_MaterializedViews::IManagerPtr mMaterializedViewMgr;
};

PLUGIN_INFO(CLSID_MTDiscountAdapter,
						MTDiscountAdapter,
						"Metratech.MTDiscountAdapter.1",
						"Metratech.MTDiscountAdapter",
						"Free")

