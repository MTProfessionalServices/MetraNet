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
* $Header: MTAggregateCharge.cpp, 38, 10/9/2002 5:36:06 PM, Derek Young$
* 
***************************************************************************/


#include "StdAfx.h"
#include "PMNAAggregateCharge.h"
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <DataAccessDefs.h>
#include <RowsetDefs.h>
#include <perflog.h>


using namespace MTPRODUCTCATALOGLib;


PMNAAggregateCharge::PMNAAggregateCharge()
{
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("ProductCatalog"), "[PMNAAggregateCharge]");
}


//rates all aggregate usage based on this template for a given interval
//waits for all sessions to commit
HRESULT PMNAAggregateCharge::Rate(long aUsageIntervalID, long aSessionSetSize, 
																	IMTAggregateChargePtr aggregateCharge) 
{
	return RateInternal(aUsageIntervalID, NULL, true, aSessionSetSize, NULL, false, NULL, NULL, NULL,
											aggregateCharge);
}


HRESULT PMNAAggregateCharge::RateForRecurringEvent(long aSessionSetSize,
																									 long aCommitTimeout,
																									 VARIANT_BOOL aFailImmediately,
																									 BSTR aEventName,
																									 IRecurringEventRunContext* apRunContext,
																									 long * apChargesGenerated, 
																									 IMTAggregateChargePtr aggregateCharge) 
{
	return RateInternal(NULL, NULL, true,
											aSessionSetSize, aCommitTimeout, aFailImmediately == VARIANT_TRUE ? true : false,
											aEventName, apRunContext, apChargesGenerated, aggregateCharge);
}

HRESULT PMNAAggregateCharge::RateInternal(long aUsageIntervalID,
																					long aAccountID,
																					bool aWaitForCommit,
																					long aSessionSetSize,
																					long aCommitTimeout,
																					bool aFailImmediately,
																					BSTR aEventName,
																					IRecurringEventRunContext* apRunContext,
																					long * apChargesGenerated,
																					IMTAggregateChargePtr aggregateCharge)
{
	MarkRegion region("AggregateCharge::RateInternal");

	try {

		if (apChargesGenerated)
			*apChargesGenerated = 0;

		IMTAggregateChargePtr thisPtr(aggregateCharge);

		MetraTech_UsageServer::IRecurringEventRunContextPtr runContext(apRunContext);

		// gets the usage interval id to operator on
		// either passed in explicitly or given by the event run context
		long intervalID = 0;
		if (apRunContext)
			intervalID = runContext->GetUsageIntervalID();
		else
			intervalID = aUsageIntervalID;


		//only rates if this is a template (not an instance)
		VARIANT_BOOL bTemplate;
		bTemplate = thisPtr->IsTemplate();
		if (bTemplate == VARIANT_FALSE) {
			mLogger.LogVarArgs(LOG_ERROR, "The Rate method must be called on a template priceable item!"); 
			return E_FAIL; 
		}


		METERROWSETLib::IMeterRowsetPtr meterRowset("MetraTech.MeterRowset");
		meterRowset->InitSDK("AggregateRatingServer");

		_bstr_t secondPassServiceDef = thisPtr->SecondPassServiceDefinition;

		meterRowset->InitForService((char*) secondPassServiceDef);

		// generates a batch ID 
		_bstr_t batchID = "";
		if (apRunContext)
		{
			MarkRegion region("CreateAdapterBatch");

			METERROWSETLib::IBatchPtr batch = meterRowset->CreateAdapterBatch(runContext->RunID,
																																				aEventName,
																																				thisPtr->Name);
			batchID = batch->GetUID();
		}
		else
		{
			batchID = meterRowset->GenerateBatchID();
		}


		//
		// executes the aggregation sproc and query
		//
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("queries\\ProductCatalog\\AggregateRating");

		//only parents can be rated (parents will recursively rate the children)
		if (thisPtr->GetParent()) {
			mLogger.LogVarArgs(LOG_ERROR, "The Rate method must be called on the parent of this priceable item!"); 
			return E_FAIL; 
		}

		std::vector<_bstr_t> dropTableQueries;
		_bstr_t dropTable1Query;
		_bstr_t dropTable2Query;
		MarkEnterRegion("ExecuteQuery");
		HRESULT hr;
		hr = ExecuteQuery((ROWSETLib::IMTSQLRowset*) rowset, intervalID, aAccountID, batchID, false, apRunContext,
											dropTable1Query, dropTable2Query, aggregateCharge);
		MarkExitRegion("ExecuteQuery");
		dropTableQueries.push_back(dropTable1Query);
		dropTableQueries.push_back(dropTable2Query);

		if (FAILED(hr)) {
			mLogger.LogVarArgs(LOG_ERROR, "ExecuteQuery failed! hr = %x", hr); 
			return hr;
		}

		// avoids metering when unnecessary
		MarkEnterRegion("CheckRecordCount");
		long meteredRecords  = (long) rowset->GetValue("meteredRecords");
		if (meteredRecords == 0)
		{
			mLogger.LogVarArgs(LOG_INFO, "No usage to rate, not metering to second pass.");
			if (apRunContext)
				runContext->RecordInfo("No usage to rate, not metering to second pass.");
			MarkExitRegion("CheckRecordCount");
			return S_OK;
		}
		MarkExitRegion("CheckRecordCount");
		

		//
		// invokes the children 
		// 

		//loops over children (if any) forcing them to execute their own query
		MTPRODUCTCATALOGLib::IMTCollectionPtr children = thisPtr->GetChildren();
		long childrenCount = children->Count;
		mLogger.LogVarArgs(LOG_DEBUG, "Aggregate charge is a parent of %d children.", childrenCount); 
		if (apRunContext)
		{
			_bstr_t msg = "Aggregate charge is a parent of ";
			msg += _bstr_t(childrenCount);
			msg += " children";
			runContext->RecordInfo(msg);
		}
		for(long i = 1; i <= childrenCount; i++) 
		{
			IMTAggregateChargePtr child = children->GetItem(i);

			_bstr_t msg = "Processing child aggregate charge '";
			msg += child->Name;
			msg += "' with template ID ";
			msg += _bstr_t(child->ID);
			mLogger.LogThis(LOG_DEBUG, (const char *) msg);
			if (apRunContext)
				runContext->RecordInfo(msg);

			// executes the aggregation sproc and query on the child
			BSTR bstrDropChildTable1Query;
			BSTR bstrDropChildTable2Query;

			HRESULT hr = GetRowsetForParent(intervalID, aAccountID, 
																			(MTPRODUCTCATALOGLib::IRecurringEventRunContext *) apRunContext,
																			&bstrDropChildTable1Query, &bstrDropChildTable2Query,
																			child);
			if (FAILED(hr))
			{
				mLogger.LogVarArgs(LOG_ERROR, "GetRowsetForParent failed!"); 
				throw new _com_error(hr);
			}

			_bstr_t dropChildTable1Query(bstrDropChildTable1Query, false);
			_bstr_t dropChildTable2Query(bstrDropChildTable2Query, false);
			dropTableQueries.push_back(dropChildTable1Query);
			dropTableQueries.push_back(dropChildTable2Query);
		}
		

		//
		// meters all the results
		//
		if (apRunContext)
		{
			_bstr_t msg = "Metering (direct-mode) results to second pass service definition '";
			msg += secondPassServiceDef;
			msg += "'";
			runContext->RecordInfo(msg);
		}
		mLogger.LogVarArgs(LOG_INFO, "Metering (direct-mode) results to second pass"); 

		hr = MeterDirect(aSessionSetSize);
		if (FAILED(hr))
			return hr;

		if (apRunContext)
			runContext->RecordInfo("Metering complete");

		//
		// drops the "temp" tables
		//
		if (apRunContext)
			runContext->RecordInfo("Dropping temporary aggregation tables");
		mLogger.LogThis(LOG_DEBUG, "Dropping temporary aggregation tables"); 
		ROWSETLib::IMTSQLRowsetPtr cleanupRowset(MTPROGID_SQLROWSET);
		cleanupRowset->Init("queries\\ProductCatalog\\AggregateRating");
		vector<_bstr_t>::iterator it = dropTableQueries.begin();
		while(it != dropTableQueries.end())
		{
			_bstr_t dropQuery = *it++;
			mLogger.LogVarArgs(LOG_DEBUG, "Dropping table: %s", (const char *) dropQuery); 
			cleanupRowset->SetQueryString(dropQuery);
			cleanupRowset->Execute();
			cleanupRowset->Clear();
		}
		
		//
		// waits until all sessions commit
		//
		if (aWaitForCommit) 
		{
			if (apRunContext)
			{
				_bstr_t msg = "Waiting for sessions to commit (timeout = ";
				msg += _bstr_t(aCommitTimeout);
				msg += " seconds)";
				runContext->RecordInfo(msg);
			}
			meterRowset->WaitForCommit(meteredRecords, aCommitTimeout);
		}

		if (apRunContext)
		{
			runContext->RecordInfo("All sessions have been committed");

			if (apChargesGenerated)
				*apChargesGenerated = meterRowset->CommittedSuccessCount;

			if (meterRowset->CommittedErrorCount > 0)
			{
				_bstr_t msg = _bstr_t(meterRowset->CommittedErrorCount);
				msg += " sessions failed during pipeline processing!";
				MT_THROW_COM_ERROR((const char *) msg);
			}
		}
	}	
	catch (_com_error & err)
	{ return LogAndReturnComError(mLogger, err); }

	return S_OK;
}


// *** FOR INTERNAL USE ONLY ***
//called by a parent AggregateCharge on a child, returns a rowset to the parent in
//which the parent will meter as part of a compound session.
HRESULT PMNAAggregateCharge::GetRowsetForParent(long aUsageIntervalID, long aAccountID,
																								IRecurringEventRunContext* apRunContext,
																								BSTR * apDropChildTable1Query,
																								BSTR * apDropChildTable2Query,
																								IMTAggregateChargePtr aggregateCharge)
{
	HRESULT hr;
	try 
	{ 
		MetraTech_UsageServer::IRecurringEventRunContextPtr runContext(apRunContext);

		MTPRODUCTCATALOGLib::IMTAggregateChargePtr thisPtr = aggregateCharge;
		IMTPriceableItemTypePtr piType = thisPtr->PriceableItemType;
		_bstr_t secondPassProductView = piType->GetProductView();

		_bstr_t dropChildTable1Query;
		_bstr_t dropChildTable2Query;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("queries\\ProductCatalog\\AggregateRating");
		hr = ExecuteQuery((ROWSETLib::IMTSQLRowset*) rowset, aUsageIntervalID, aAccountID, "", true, apRunContext,
											dropChildTable1Query, dropChildTable2Query, aggregateCharge);
		*apDropChildTable1Query = dropChildTable1Query.copy();
		*apDropChildTable2Query = dropChildTable2Query.copy();

		if (FAILED(hr)) 
		{
			mLogger.LogVarArgs(LOG_ERROR, "ExecuteQuery failed! hr = %x", hr); 
			return hr;
		}

	}
	catch (_com_error & err)
	{ return LogAndReturnComError(mLogger,err); }
	
	return S_OK;
}


HRESULT PMNAAggregateCharge::ExecuteQuery(ROWSETLib::IMTSQLRowset* apRowset,
																				 long aUsageIntervalID, long aAccountID,
																				 _bstr_t batchID,
																				 bool aChild,
																				 IRecurringEventRunContext* apRunContext,
																				 _bstr_t & dropTable1Query,
																				 _bstr_t & dropTable2Query,
																					IMTAggregateChargePtr aggregateCharge)
{
	HRESULT hr;
	bool bIsOracle = FALSE;
	unsigned int i;
	std::string logBuffer;

	_variant_t vt_null;
	vt_null.ChangeType(VT_NULL);
	
	try	{
		MetraTech_UsageServer::IRecurringEventRunContextPtr runContext(apRunContext);
		ROWSETLib::IMTSQLRowsetPtr rowset(apRowset);

		_bstr_t dbtype = rowset->GetDBType() ;

		// oracle database?
		bIsOracle = (mtwcscasecmp(dbtype, ORACLE_DATABASE_TYPE) == 0);
		

		// extracts useful information from the counters
		std::vector<std::string> counterFormulas, counterFormulaAliases;
		std::map<std::string, std::string> countableProductViews, countableProperties;
		mLogger.LogThis(LOG_DEBUG, "Processing aggregate counters");
		hr = ProcessCounters(counterFormulas, 
												 countableProductViews,
												 countableProperties,
												 counterFormulaAliases,
												 aggregateCharge);
		if (FAILED(hr))
			return hr;


		//
		// counter formulas, counter formula aliases
		//
		std::string paramCounterFormulas;
		std::string paramCounterFormulaAliases;
		for (i = 0; i < counterFormulas.size(); i++)
		{
			paramCounterFormulas += ", " + counterFormulas[i];
			paramCounterFormulaAliases += ", tp2." + counterFormulaAliases[i];
		}

		// NOTE: uses LogThis instead of LogVarArgs because the latter cannot 
		// correctly log large strings
		logBuffer = "COUNTER_FORMULAS = \"" + paramCounterFormulas + "\"";
		mLogger.LogThis(LOG_DEBUG, logBuffer.c_str());
		logBuffer = "COUNTER_FORMULAS_ALIASES = \"" + paramCounterFormulaAliases + "\"";
		mLogger.LogThis(LOG_DEBUG, logBuffer.c_str()); 


		//
		// countable outer joins and countable view id's
		//
		std::string paramCountableJoins;
		std::string paramCountableViewIDs;
		std::map<std::string, std::string>::iterator pvIt;
		for (pvIt = countableProductViews.begin(); pvIt != countableProductViews.end(); ++pvIt)
		{
			if (pvIt != countableProductViews.begin())
				paramCountableViewIDs += ", ";
			paramCountableViewIDs += pvIt->second;

			paramCountableJoins += " LEFT OUTER JOIN ";
			paramCountableJoins += pvIt->first;  //the actual countable's product view
			paramCountableJoins += " ON ";
			paramCountableJoins += pvIt->first;
			paramCountableJoins += ".id_sess = au.id_sess ";

		}

		logBuffer = "COUNTABLE_OJOINS = \"" + paramCountableJoins + "\"";
		mLogger.LogThis(LOG_DEBUG, logBuffer.c_str()); 
		mLogger.LogVarArgs(LOG_DEBUG, "COUNTABLE_VIEWIDS = \"%s\"", paramCountableViewIDs.c_str());


		//
		// countable properties
		//
		std::string paramCountableProperties;
		for (std::map<std::string, std::string>::iterator it = countableProperties.begin();
				 it != countableProperties.end(); ++it)
		{
			paramCountableProperties += ", ";
			paramCountableProperties += it->first;  // original table/column name: "t_pv_songdownloads_temp.blah"
			paramCountableProperties += " as ";
			paramCountableProperties += it->second; // unique countable alias: "countable_1"
		}
		logBuffer = "COUNTABLE_PROPERTIES = \"" + paramCountableProperties + "\"";
		mLogger.LogThis(LOG_DEBUG, logBuffer.c_str()); 


		//
		// first pass product view table
		//
		std::string paramFirstPassTable;
		_bstr_t firstPassProductView = aggregateCharge->FirstPassProductView;
		std::vector<std::string> firstPassColumns;
		hr = GetProductViewProps((char*) firstPassProductView, paramFirstPassTable, firstPassColumns);
		if (FAILED(hr))
			return hr;
		mLogger.LogVarArgs(LOG_DEBUG, "FIRST_PASS_PV_TABLE = \"%s\"", paramFirstPassTable.c_str());
		

		//
		// first pass product view properties
		//
		std::string paramFirstPassPropsAliased;
		for (i = 0; i < firstPassColumns.size(); i++) 
		{
			paramFirstPassPropsAliased += ", firstpasspv.";
			paramFirstPassPropsAliased += firstPassColumns[i];
			paramFirstPassPropsAliased += " as ";
			paramFirstPassPropsAliased += firstPassColumns[i];
		}

		logBuffer = "FIRST_PASS_PV_PROPERTIES_ALIASED = \"" + paramFirstPassPropsAliased + "\"";
		mLogger.LogThis(LOG_DEBUG, logBuffer.c_str()); 


		//
    // first pass product view's view ID
		//
		long paramFirstPassViewID;
		MTNAMEIDLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);
		paramFirstPassViewID = nameid->GetNameID(firstPassProductView);
		mLogger.LogVarArgs(LOG_DEBUG, "FIRST_PASS_PV_VIEWID = \"%d\"", paramFirstPassViewID);


		//
		// account filter
		//
		std::string paramAccountFilter;
		char buffer[256];
		if (aAccountID) {
			paramAccountFilter = "and au.id_acc = ";
			sprintf(buffer, "%d", aAccountID);
			paramAccountFilter += buffer;
		}
		mLogger.LogVarArgs(LOG_DEBUG, "ACCOUNT_FILTER = \"%s\"", paramAccountFilter.c_str());


		//
		// usage interval ID
		//
		long paramUsageInterval = aUsageIntervalID;
		mLogger.LogVarArgs(LOG_DEBUG, "USAGE_INTERVAL = \"%d\"", paramUsageInterval);


		//
		// aggregate charge's template ID
		//
		long paramTemplateID = 	aggregateCharge->ID;
		mLogger.LogVarArgs(LOG_DEBUG, "TEMPLATE_ID = \"%d\"", paramTemplateID);


		//
		// compound ordering 
		//
		std::string paramCompoundOrdering;
		if (aChild) 
			// this ordering is required to work with MeterRowset's compound support 
			paramCompoundOrdering = "au.id_parent_sess, ";
		else
			paramCompoundOrdering = "au.id_sess, ";
		mLogger.LogVarArgs(LOG_DEBUG, "COMPOUND_ORDERING = \"%s\"", paramCompoundOrdering.c_str());


		//
		// decodes the batch ID to binary
		//
		std::string paramBatchID; 
		if (batchID.length() > 0) // only parents have batch IDs
		{
			unsigned char uid[16];
			MSIXUidGenerator::Decode(uid, (const char *) batchID);

			// converts batch ID to a binary literal (taken from MeterRowset::ConvertSessionIDToString)
			wstring wstrString;
			wchar_t sessionID[16];
			wchar_t * wchrFormat = L"%02X";
			wstrString += L"0x"; 
			for (int i=0; i < 16; i++)
			{
				swprintf(sessionID, wchrFormat, (int)*(uid+i));
				wstrString += sessionID ;
			}
			
			paramBatchID = (const char *) _bstr_t(wstrString.c_str());
		}


		//
		// sets up the stored procedure (this is ugly!)
		//
		rowset->Clear();
		rowset->InitializeForStoredProc("MTSP_RATE_AGGREGATE_CHARGE");


		// input parameters
		rowset->AddInputParameterToStoredProc("input_RUN_ID",
																					MTTYPE_INTEGER,
																					INPUT_PARAM,
																					apRunContext ? _variant_t(runContext->RunID) : vt_null);

		rowset->AddInputParameterToStoredProc("input_USAGE_INTERVAL",
																					MTTYPE_INTEGER,
																					INPUT_PARAM,
																					_variant_t(paramUsageInterval));
		rowset->AddInputParameterToStoredProc("input_TEMPLATE_ID",
																					MTTYPE_INTEGER,
																					INPUT_PARAM,
																					_variant_t(paramTemplateID));
		rowset->AddInputParameterToStoredProc("input_FIRST_PASS_PV_VIEWID", 
																					MTTYPE_INTEGER,
																					INPUT_PARAM,
																					_variant_t(paramFirstPassViewID));
		rowset->AddInputParameterToStoredProc("input_FIRST_PASS_PV_TABLE",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramFirstPassTable.c_str()));
		rowset->AddInputParameterToStoredProc("input_COUNTABLE_VIEWIDS",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCountableViewIDs.c_str()));
		rowset->AddInputParameterToStoredProc("input_COUNTABLE_OJOINS",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCountableJoins.c_str()));
		rowset->AddInputParameterToStoredProc("input_1STPASSPV_PROPS_ALIASED",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramFirstPassPropsAliased.c_str()));
		rowset->AddInputParameterToStoredProc("input_COUNTABLE_PROPERTIES",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCountableProperties.c_str()));
		rowset->AddInputParameterToStoredProc("input_COUNTER_FORMULAS",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCounterFormulas.c_str()));
		rowset->AddInputParameterToStoredProc("input_ACCOUNT_FILTER",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramAccountFilter.c_str()));
		rowset->AddInputParameterToStoredProc("input_COMPOUND_ORDERING",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCompoundOrdering.c_str()));
		rowset->AddInputParameterToStoredProc("input_COUNTER_FORMULAS_ALIASES",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					_variant_t(paramCounterFormulaAliases.c_str()));
		rowset->AddInputParameterToStoredProc("input_BATCHUID",
																					MTTYPE_VARCHAR,
																					INPUT_PARAM,
																					(batchID.length() > 0) ? _variant_t(paramBatchID.c_str()) : vt_null);

		// output parameters
		rowset->AddOutputParameterToStoredProc("output_SQLStmt_SELECT", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("output_SQLStmt_DROPTMPTBL1", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("output_SQLStmt_DROPTMPTBL2", MTTYPE_VARCHAR, OUTPUT_PARAM);
		rowset->AddOutputParameterToStoredProc("return_code", MTTYPE_INTEGER, OUTPUT_PARAM);

		if (apRunContext)
			runContext->RecordInfo("Executing the aggregation stored procedure");
		mLogger.LogThis(LOG_DEBUG, "Executing the aggregation stored procedure"); 

		rowset->ExecuteStoredProc();	

		// checks for failure
		_variant_t status = rowset->GetParameterFromStoredProc("return_code");
		if ((status == vt_null) || ((long) status == -1))
		{
			mLogger.LogThis(LOG_ERROR, "The aggregation stored procedure failed!");
			return E_FAIL;
		}

		if (apRunContext)
			runContext->RecordInfo("Aggregation stored procedure completed successfully");

		// the stored procedure returns 3 queries for us to execute:
		//    1) the final aggregation query (goes against temp tables created by the sproc)
		//    2) drop a temp table
		//    3) drop another temp table
    _bstr_t aggregationQuery = rowset->GetParameterFromStoredProc("output_SQLStmt_SELECT");
		dropTable1Query = rowset->GetParameterFromStoredProc("output_SQLStmt_DROPTMPTBL1");
		dropTable2Query = rowset->GetParameterFromStoredProc("output_SQLStmt_DROPTMPTBL2");


		// NOTE: this query is only used to check if any results were generated (TOP 1) for the parent,
		//       if null, no children will be executed
		rowset->Clear();
		rowset->SetQueryString(aggregationQuery);
		rowset->ExecuteConnected();

	}	catch (_com_error & err)
	{ return LogAndReturnComError(mLogger,err); }

	return S_OK;
}


HRESULT PMNAAggregateCharge::GetProductViewProps(const char * apProductViewName,
																								 std::string& arTableName,
																								 std::vector<std::string>& arProperties)
{
	
	try {
		CProductViewCollection productViews;
		productViews.Initialize();

		CMSIXDefinition * pv = NULL;
		if (!productViews.FindProductView((wchar_t*) _bstr_t(apProductViewName), pv))
		{
			// TODO: better error handling
			mLogger.LogVarArgs(LOG_ERROR, 
												 "Product view <%s> not found", apProductViewName);
			return E_FAIL;
		}

		arTableName = ascii(pv->GetTableName());

		MSIXPropertiesList props = pv->GetMSIXPropertiesList();
		MSIXPropertiesList::iterator it;
		for (it = props.begin(); it != props.end(); ++it)
		{
			CMSIXProperties * prop = *it;
			string columnName = ascii(prop->GetColumnName()); //converts from wchar_t
			arProperties.push_back(columnName);
		}
	}	catch (_com_error & err)
	{ return LogAndReturnComError(mLogger,err); }
	
	return S_OK;
}



HRESULT PMNAAggregateCharge::ProcessCounters(std::vector<std::string>& arCounterFormulas, 
																						 std::map<std::string, std::string>& arCountableProductViews, // <pv name, pv nameid>
																						 std::map<std::string, std::string>& arCountableProperties,
																						 std::vector<std::string>& arCounterFormulaAliases,
																						 IMTAggregateChargePtr aggregateCharge)
{
	try {

		//gets this aggregate charge's cpd collection
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr piType = aggregateCharge->PriceableItemType;
		MTPRODUCTCATALOGLib::IMTCollectionPtr cpdColl = piType->GetCounterPropertyDefinitions();

		MTNAMEIDLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);

		//iterates through the template's CPD collection 
		long nCPDCount =  cpdColl->Count;
		mLogger.LogVarArgs(LOG_DEBUG, "CPD count = %d", nCPDCount);
		long countableIndex = 0;
		for (int counterIndex = 1; counterIndex <= nCPDCount; counterIndex++) {
			MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd = cpdColl->GetItem(counterIndex);
			MTPRODUCTCATALOGLib::IMTCounterPtr counter = aggregateCharge->GetCounter(cpd->GetID());

			if(counter == NULL) {
				mLogger.LogVarArgs(LOG_ERROR, "CPD with ID %d does not have a counter associated with it!", cpd->GetID());
				return E_FAIL;  //TODO: what to do?
			}

			//aliases the counter to the output property found in the CPD
			string alias = "c_";  //column prefix in productview
			alias += (char*) _bstr_t(cpd->ServiceDefProperty); 
			counter->Alias = _bstr_t(alias.c_str());
			arCounterFormulaAliases.push_back(alias);
			
			//gets the counter's parameter collection
			MTPRODUCTCATALOGLib::IMTCollectionPtr paramColl = counter->Parameters;
			long nParamCount = paramColl->Count;


			std::string formula = (char*) _bstr_t(counter->GetFormula(MTPRODUCTCATALOGLib::VIEW_SQL));

			//
			// iterates through param collection for the current counter
			//
			for (int paramIndex = 1; paramIndex <= nParamCount; paramIndex++) {
				MTCOUNTERLib::IMTCounterParameterPtr param = paramColl->GetItem(paramIndex);

				//if a parameter is just a constant, then don't do anything
				if (param->GetKind() == PARAM_CONST)
					continue;
				
				//if the product view has not yet been added, then lookup info and add it
				std::string tableName = (char*) _bstr_t(param->ProductViewTable);
				std::map<std::string, std::string>::iterator findit;
				findit = arCountableProductViews.find(tableName);
				if (findit == arCountableProductViews.end()) {

					//calculates view id of the countable's product view
					long nViewID = nameid->GetNameID(param->ProductViewName);
					char viewID[256];
					sprintf(viewID, "%d", nViewID);

					arCountableProductViews[tableName] = viewID;
				}
				
				// generates a unique countable alias
				std::string columnName = (char*) _bstr_t(param->GetColumnName());
				std::string originalTableColumn = tableName + "." + columnName;
				char countableAlias[64];
				sprintf(countableAlias, "countable_%d", countableIndex++);
				arCountableProperties[originalTableColumn] = countableAlias;
				std::string aliasedTableColumn = "tp2.";
				aliasedTableColumn += countableAlias;

				// replaces the orginal table/column name of the parameter
				// in the formula with the unique countable alias  
				std::string::size_type pos = 0;
				while(true)
				{
					pos = formula.find(originalTableColumn);
					if (pos == std::string::npos) // no more instances found
						break;
					formula.replace(pos, originalTableColumn.length(), aliasedTableColumn); 
				}
			}

			arCounterFormulas.push_back(formula);
		} 
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(mLogger,err); }
	
	return S_OK;
}



// invokes a variant of Billing Rerun's Resubmit to directly meter svc data
HRESULT PMNAAggregateCharge::MeterDirect(long sessionSetSize)
{
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init("queries\\ProductCatalog\\AggregateRating");

	rowset->InitializeForStoredProc("AggMeter_ConfAll");
	rowset->AddInputParameterToStoredProc("message_size", MTTYPE_INTEGER, INPUT_PARAM, _variant_t(sessionSetSize));
  rowset->AddInputParameterToStoredProc("system_date", MTTYPE_VARCHAR, INPUT_PARAM, GetMTOLETime());
	rowset->AddOutputParameterToStoredProc("return_code", MTTYPE_INTEGER, OUTPUT_PARAM);

	rowset->ExecuteStoredProc();	
	
	// checks for failure
	_variant_t vt_null;
	vt_null.ChangeType(VT_NULL);

	_variant_t status = rowset->GetParameterFromStoredProc("return_code");
	if ((status == vt_null) || ((long) status != 0))
	{
		mLogger.LogThis(LOG_ERROR, "Aggregate rating direct metering failed!");
		return E_FAIL;
	}

	return S_OK;
}
