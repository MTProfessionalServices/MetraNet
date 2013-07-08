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

#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTRuleSetWriter.h"

#include <DataAccessDefs.h>

#include <SetIterate.h>

#include <mtprogids.h>
#include <mtautocontext.h>
#include <mtcomerr.h>
#include <mttime.h>
#include <formatdbvalue.h>
#include <stdutils.h>
#include <search.h>

#include <map>

using MTPRODUCTCATALOGLib::IMTRuleSetPtr;
using MTPRODUCTCATALOGLib::IMTRulePtr;
using MTPRODUCTCATALOGLib::IMTActionSetPtr;
using MTPRODUCTCATALOGLib::IMTAssignmentActionPtr;
using MTPRODUCTCATALOGLib::IMTConditionSetPtr;
using MTPRODUCTCATALOGLib::IMTSimpleConditionPtr;
using MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr;
using MTPRODUCTCATALOGLib::IMTConditionMetaDataPtr;
using MTPRODUCTCATALOGLib::IMTActionMetaDataPtr;
using MTPRODUCTCATALOGLib::IMTCollectionPtr;

#import "MTAuditDBWriter.tlb"
#import "MTAuditEvents.tlb"

/////////////////////////////////////////////////////////////////////////////
// CMTRuleSetWriter

STDMETHODIMP CMTRuleSetWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRuleSetWriter,
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRuleSetWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTRuleSetWriter::CanBePooled()
{
	return FALSE;
} 

void CMTRuleSetWriter::Deactivate()
{
	mpObjectContext.Release();
} 


//	 call rateRowset.SetQueryTag("__INSERT_RATE__")
//	 call rateRowset.AddParam("%%TABLE_NAME%%", tableName)
//	 call rateRowset.AddParam("%%ID_SCHED%%", rsID)
//	 call rateRowset.AddParam("%%COLUMNS%%", columns)
//	 call rateRowset.AddParam("%%ORDER%%", order)
//	 call rateRowset.AddParam("%%VALUES%%", values, true)
//	 call rateRowset.execute
//	 rateRowset.ClearQuery

//			InsertRates rateRowset, "t_pt_rateconn", rsID, 1, _
//			     rateConnColumns, _
//			     "'>', 20, " & basicid & ",0.50, 60, 0, 0, 10"


void AddColumn(std::wstring & arColumns, const wchar_t * apColumnName)
{
	if (arColumns.length() > 0)
		arColumns += L", ";

	arColumns += apColumnName;

#if 0
	arColumns += L"c_";
	arColumns += apPropName;
	if (aIsOperator)
		arColumns += L"_op";
#endif
}

int LookupIndex(std::map<std::wstring, int> & arOrder,
								const wchar_t * apName)
{
	std::map<std::wstring, int>::const_iterator findit =
		arOrder.find((const wchar_t * ) apName);

	if (findit == arOrder.end())
	{
		return -1;
	}

	return findit->second;
}


VARTYPE PropValTypeToVariantType(PropValType aType)
{
	switch (aType)
	{
	case PROP_TYPE_INTEGER:
		return VT_I4;
	case PROP_TYPE_BIGINTEGER:
		return VT_I8;
	case PROP_TYPE_DOUBLE:
		return VT_R8;
	case PROP_TYPE_STRING:
		// TODO: is this correct?
		return VT_BSTR;
	case PROP_TYPE_DATETIME:
		return VT_DATE;

	case PROP_TYPE_TIME:
		return VT_I4;

	case PROP_TYPE_BOOLEAN:
		return VT_BOOL;

	case PROP_TYPE_ENUM:
		// TODO: not yet supported
		ASSERT(0);
		return (VARTYPE) -1;

	case PROP_TYPE_DECIMAL:
		return VT_DECIMAL;

	case PROP_TYPE_UNKNOWN:
	case PROP_TYPE_DEFAULT:
	case PROP_TYPE_OPAQUE:
	case PROP_TYPE_SET:
	default:
		ASSERT(0);
		return (VARTYPE) -1;
	}
}


struct OpKeyword
{
	const wchar_t * name;
	const wchar_t * canonicalName;
};

static int OpKeyCompare(const void *arg1, const void *arg2)
{
	OpKeyword * opkey1 = (OpKeyword *) arg1;
	OpKeyword * opkey2 = (OpKeyword *) arg2;
	// case insensitive
	return mtwcscasecmp(opkey1->name, opkey2->name);
}

std::wstring RuleSetOpToDBOp(const wchar_t * apOp)
{
	// NOTE: these must be sorted or bsearch won't work!
	static OpKeyword keywords[] =
	{
		L"!=", L"!=",
		L"<", L"<",
		L"<=", L"<=",
		L"=", L"=",
		L"==", L"=",
		L">", L">",
		L">=", L">=",
		L"equal", L"=",
		L"equals", L"=",
		L"great_equal", L">=",
		L"great_than", L">",
		L"greater_equal", L">=",
		L"greater_than", L">",
		L"less_equal", L"<=",
		L"less_than", L"<",
		L"not_equal", L"!=",
		L"not_equals", L"!=",
 	};

	OpKeyword key = { apOp, NULL };

	OpKeyword * result = (OpKeyword *) bsearch((char *) &key, (char *) keywords,
		sizeof(keywords) / sizeof(keywords[0]),
		sizeof(keywords[0]),
		OpKeyCompare);

	if (result)
		return result->canonicalName;

	MT_THROW_COM_ERROR(L"Invalid ruleset operation: %s", apOp);
	return L"";
}



STDMETHODIMP CMTRuleSetWriter::UpdateWithID(IMTSessionContext* apCtxt, long aRSID, IMTParamTableDefinition *apParamTable, IMTRuleSet *apRules)
{
	MTAutoContext context(mpObjectContext);

	HRESULT hr = S_OK;
	try
	{
    //With current rate auditing, update is no different than create
		hr = CreateWithID(apCtxt, aRSID, apParamTable, apRules);
		if (FAILED(hr))
			return hr;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTRuleSetWriter::CreateWithID(IMTSessionContext* apCtxt, 
																						long aRSID,
																						IMTParamTableDefinition *apParamTable,
																						IMTRuleSet *apRules)
{
	MTAutoContext context(mpObjectContext);

	try
	{
    IMTRuleSetPtr rules(apRules);

    // clean up the ruleset before writing into database
    CleanUpRuleset(rules);

    // for converting enums into IDs
    MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    BOOL isOracle = (mtwcscasecmp(rowset->GetDBType(), ORACLE_DATABASE_TYPE) == 0);

    IMTParamTableDefinitionPtr paramTable(apParamTable);
    _bstr_t paramTableName = paramTable->GetDBTableName();

      // Get start date and end date for new ruleset
    _variant_t vtStartDate = GetMTOLETime();
    _variant_t vtEndDate   = GetMaxMTOLETime();

    wstring dt_start,dt_end;
    FormatValueForDB(vtStartDate,FALSE,dt_start);
    FormatValueForDB(vtEndDate,FALSE,dt_end);

    //Set end date for previous entries - for update
    rowset->SetQueryTag(L"__SET_ENDDATE_FOR_CURRENT_RATES__");
    rowset->AddParam(L"%%TABLE_NAME%%", paramTableName);
    rowset->AddParam(L"%%ID_SCHED%%", aRSID);
    rowset->AddParam(L"%%TT_START%%", dt_start.c_str(),VARIANT_TRUE);
    rowset->Execute();

    //Retrieve the pricelist id
    rowset->SetQueryTag(L"__GET_PRICELIST_INFO_FROM_RATESCHEDULE_ID___");
    rowset->AddParam(L"%%ID_SCHED%%", aRSID);
    rowset->Execute();
    long idPricelist = rowset->GetValue("id_pricelist");    //Used for entry into audit table
    _variant_t vtValue = rowset->GetValue("nm_name");
    _bstr_t bstrPriceListName = "";
    if(vtValue.vt != VT_NULL)
      bstrPriceListName = vtValue.bstrVal;    

    // Auditing - audit the rule update now so we can retrieve the audit id
    char buffer[1024];
    sprintf(buffer,"Price List: %s, Price List Id: %d, ParamTable: %s, Rate Schedule Id: %d", (char *) bstrPriceListName, idPricelist, (char *) paramTable->GetName(),aRSID);
    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
    MTAUDITDBWRITERLib::IAuditEventPtr pAuditEvent(__uuidof(MTAUDITEVENTSLib::AuditEvent));

    pAuditEvent->PutEventId(1402); //AuditEventsLib::AUDITEVENT_RS_RULE_UPDATE
    pAuditEvent->PutUserId(pContext->AccountID);
    pAuditEvent->PutEntityTypeId(2); //AuditEventsLib::AUDITENTITY_TYPE_PRODCAT
    pAuditEvent->PutEntityId(aRSID);
    pAuditEvent->PutDetails(buffer);
    pAuditEvent->PutSuccess(VARIANT_TRUE);

    MTAUDITDBWRITERLib::IAuditDBWriterPtr pAuditWriter(__uuidof(MTAUDITDBWRITERLib::AuditDBWriter));
    pAuditWriter->Write(pAuditEvent);

    long idAudit;
    idAudit = pAuditEvent->GetAuditId();
 
		//
		// generate a list of columns like this:
		//  c_duration_op, c_duration, c_Rate, c_MTI, c_MinCharge, c_MinUOM, c_SetupCharge
		//
		// also, figure out the order of everything
		//
		std::vector<std::wstring> conditionNameOrder;
		std::vector<bool> rowLevelOp;

		std::vector<std::wstring> actionNameOrder;

		// buffer to hold the columns string, as described above
		std::wstring defaultActionColumns, columns;



		SetIterator<IMTCollectionPtr, IMTConditionMetaDataPtr> conditionit;
		HRESULT hr = conditionit.Init(paramTable->GetConditionMetaData());
		if (FAILED(hr))
		{
			// TODO:
			ASSERT(0);
		}
	
		int numConditions = 0;
		while (TRUE)
		{
			IMTConditionMetaDataPtr condition = conditionit.GetNext();
			if (condition == NULL)
				break;

			if (condition->GetOperatorPerRule() == VARIANT_TRUE)
			{
				// we have to figure out the unique suffix appended to the column name
				// in order to put the same suffix on the operator.
				// TODO: this is kind of a hack
				_bstr_t columnName = condition->GetColumnName();
				_bstr_t generatedColName = L"c_";
				generatedColName += condition->GetPropertyName();
				_bstr_t operatorColName = L"c_";
				operatorColName += condition->GetPropertyName();

				// operators end in _op
				operatorColName += "_op";

				if (columnName.length() > generatedColName.length())
				{
					_bstr_t suffix = (const wchar_t *) columnName + generatedColName.length();
					operatorColName += suffix;
				}

				AddColumn(columns, operatorColName);
				rowLevelOp.push_back(true);
			}
			else
				rowLevelOp.push_back(false);

			AddColumn(columns, condition->GetColumnName());
			conditionNameOrder.push_back((const wchar_t *) condition->GetPropertyName());
			numConditions++;
		}

		SetIterator<IMTCollectionPtr, IMTActionMetaDataPtr> actionit;
		hr = actionit.Init(paramTable->GetActionMetaData());
		if (FAILED(hr))
		{
			// TODO:
			ASSERT(0);
		}

		while (TRUE)
		{
			IMTActionMetaDataPtr action = actionit.GetNext();
			if (action == NULL)
				break;

			AddColumn(columns, action->GetColumnName());
			AddColumn(defaultActionColumns, action->GetColumnName());
			actionNameOrder.push_back((const wchar_t *) action->GetPropertyName());
		}

		// order is incremented for each rule
		long order = 0;
		std::wstring defaultValues, values;
		
		if (numConditions != 0)
		{
			//
			// for each rule...
			//
			SetIterator<IMTRuleSetPtr, IMTRulePtr> it;
			hr = it.Init(rules);
			if (FAILED(hr))
			{
				// TODO:
				ASSERT(0);
			}
	
			while (TRUE)
			{
				IMTRulePtr rule = it.GetNext();
				if (rule == NULL)
					break;

				values.resize(0);

				IMTConditionSetPtr conditions = rule->GetConditions();

				FormatConditions(values,
												 conditions,
												 conditionNameOrder,
												 rowLevelOp,
												 enumConfig,
												 isOracle);

				IMTActionSetPtr actions = rule->GetActions();

				FormatActions(values,
											actions,
											actionNameOrder,
											enumConfig,
											isOracle);


        rowset->SetQueryTag(L"__INSERT_RATE__");
        rowset->AddParam(L"%%TABLE_NAME%%", paramTableName);
        rowset->AddParam(L"%%ID_SCHED%%", aRSID);
        rowset->AddParam(L"%%TT_START%%", dt_start.c_str(),VARIANT_TRUE);
        rowset->AddParam(L"%%TT_END%%", dt_end.c_str(),VARIANT_TRUE);
        rowset->AddParam(L"%%ID_AUDIT%%", idAudit);
        rowset->AddParam(L"%%COLUMNS%%", columns.c_str());
        rowset->AddParam(L"%%ORDER%%", order++);
        rowset->AddParam(L"%%VALUES%%", values.c_str(), true);

        rowset->Execute();
			}
		}

		// process default actions if there is any
		IMTActionSetPtr defaultActions = rules->GetDefaultActions();
		if (numConditions == 0 || (defaultActions != NULL && defaultActions->GetCount() != 0))
		{
			// no conditions - there must be default actions
			//IMTActionSetPtr actions = rules->GetDefaultActions();
			if (defaultActions == NULL)
				MT_THROW_COM_ERROR("default actions expected");

			FormatActions(defaultValues,
										defaultActions,
										actionNameOrder,
										enumConfig,
										isOracle);

			rowset->SetQueryTag(L"__INSERT_RATE__");
			rowset->AddParam(L"%%TABLE_NAME%%", paramTableName);
			rowset->AddParam(L"%%ID_SCHED%%", aRSID);
			rowset->AddParam(L"%%TT_START%%", dt_start.c_str(),VARIANT_TRUE);
			rowset->AddParam(L"%%TT_END%%", dt_end.c_str(),VARIANT_TRUE);
			rowset->AddParam(L"%%ID_AUDIT%%", idAudit);
      rowset->AddParam(L"%%COLUMNS%%", defaultActionColumns.c_str());
			
			rowset->AddParam(L"%%ORDER%%", order++);
			rowset->AddParam(L"%%VALUES%%", defaultValues.c_str(), true);

			rowset->Execute();
		}

		rowset->Clear();

		rowset->InitializeForStoredProc("recursive_inherit_sub_by_rsch");
		rowset->AddInputParameterToStoredProc("v_id_rsched", MTTYPE_INTEGER, INPUT_PARAM, aRSID);
		rowset->ExecuteStoredProc();

	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}

void CMTRuleSetWriter::CleanUpRuleset(IMTRuleSetPtr aRules)
{
	// If there is a rule with no conditions, set the default
	//   actions to the actions in this rule.
	// If there are multiple rules with no conditions,
	//   throw a user error (invalid ruleset)
	// In the future, do additional checks/verifications.

	//
	// for each rule...
	//
	SetIterator<IMTRuleSetPtr, IMTRulePtr> it;
	HRESULT hr = it.Init(aRules);
	if (FAILED(hr))
	{
		MT_THROW_COM_ERROR(IID_IMTRuleSetWriter, hr, "Unable to initialize iterator");
	}

	BOOL haveEmptyActionRule = FALSE;
	int ruleIndex = 1;
	while (TRUE)
	{
		IMTRulePtr rule = it.GetNext();
		if (rule == NULL)
			break;

		IMTConditionSetPtr conditionSet = rule->GetConditions();
		if (conditionSet->GetCount() == 0)
		{
			if (haveEmptyActionRule)
			{
				// TODO: create an error message for this!
				MT_THROW_COM_ERROR("More than one rule with no conditions.");
			}

			IMTActionSetPtr actionSet = rule->GetActions();
			IMTActionSetPtr defaultActions = aRules->GetDefaultActions();
			if (defaultActions != NULL)
			{
				// TODO: create an error message for this!
				MT_THROW_COM_ERROR("Default actions exist along with a rule with no conditions.");
			}

			aRules->PutDefaultActions(actionSet);

			aRules->Remove(ruleIndex);
			ruleIndex++;
			
			haveEmptyActionRule = TRUE;
		}
	}
}

void CMTRuleSetWriter::FormatConditions(std::wstring & arValues,
																				IMTConditionSetPtr aConditions,
																				const std::vector<std::wstring> & arConditionNameOrder,
																				const std::vector<bool> & arRowLevelOp,
																				MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig,
																				BOOL aIsOracle)
{
	std::vector<std::wstring>::const_iterator conditionit;
	int index;

	std::wstring value;
	for (index = 0, conditionit = arConditionNameOrder.begin();
			 conditionit != arConditionNameOrder.end(); index++, conditionit++)
	{
		const std::wstring & name = *conditionit;
		// TODO: this won't handle NULL conditions
		IMTSimpleConditionPtr condition;
		try
		{
			condition = aConditions->GetItem(name.c_str());
		}
		catch (_com_error & err)
		{
			long errCode = err.Error();
			condition = NULL;
#if 0
			// TODO: if it's required..
			std::wstring buffer(L"Condition ");
			buffer += name;
			buffer += L" not found in rule set";
			MT_THROW_COM_ERROR(IID_IMTRuleSetWriter, err.Error(), buffer.c_str());
#endif
		}

		if (condition)
		{
			// if using a row level operator, insert the value of the operator now
			if (arRowLevelOp[index])
			{
				// insert the operator
				_bstr_t opStr = RuleSetOpToDBOp(condition->GetTest()).c_str();
				_variant_t op = opStr;

				if (!FormatValueForDB(op, aIsOracle, value))
				{
					// TODO:
					ASSERT(0);
					MT_THROW_COM_ERROR("Unable to format value!");
				}

				if (arValues.length() > 0)
					arValues += L", ";
				arValues += value;
			}

			if (condition->GetValueType() == MTPRODUCTCATALOGLib::PROP_TYPE_ENUM)
			{
				long enumid = aEnumConfig->GetID(condition->GetEnumSpace(),
																				 condition->GetEnumType(),
																				 (_bstr_t) condition->GetValue());
				// the enum ID is passed into the database
				wchar_t buffer[100];
				swprintf(buffer, L"%d", enumid);
				value = buffer;
			}
      else if (condition->GetValueType() == MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME)
      {
        // This comes out as a time_t represented as VT_I4 and we need to convert to DATE
        _variant_t val = condition->GetValue();
        if (val.vt != VT_EMPTY)
        {
          DATE dtVal;
          ::OleDateFromTimet(&dtVal, (time_t) val);
          if (!FormatValueForDB(_variant_t(dtVal, VT_DATE), aIsOracle, value))
          {
            // TODO:
            ASSERT(0);
            MT_THROW_COM_ERROR("Unable to format value!");
          }        
        }
        else
        {
          value = L"NULL";
        }
      }
			else
			{
        _variant_t val = condition->GetValue();
        val.ChangeType(PropValTypeToVariantType((PropValType) condition->GetValueType()));
				if (!FormatValueForDB(val, aIsOracle, value))
				{
					// TODO:
					ASSERT(0);
					MT_THROW_COM_ERROR("Unable to format value!");
				}
			}
		}
		else
		{
			// condition not found - if it's optional, just add NULL to the query
			// TODO: verify that it's optional
			value = L"NULL";
			//if condition not found and operator is at row level, insert NULL
			//for operator as well
			if (arRowLevelOp[index])
				value += L", NULL";
		}

		if (arValues.length() > 0)
			arValues += L", ";
		arValues += value;
	}
}


void CMTRuleSetWriter::FormatActions(std::wstring & arValues,
																		 IMTActionSetPtr aActions,
																		 const std::vector<std::wstring> & arActionNameOrder,
																		 MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig,
																		 BOOL aIsOracle)
{
	std::wstring value;

	// TODO: temporary
	int actions = aActions->GetCount();

	std::vector<std::wstring>::const_iterator actionit;
	int index;
	for (index = 0, actionit = arActionNameOrder.begin();
			 actionit != arActionNameOrder.end(); index++, actionit++)
	{
		const std::wstring & name = *actionit;
		// TODO: this won't handle NULL conditions

		IMTAssignmentActionPtr action;
		try
		{
			action = aActions->GetItem(name.c_str());
		}
		catch (_com_error & err)
		{
			long errCode = err.Error();
			action = NULL;
#if 0
			// TODO: if it's required
			std::wstring buffer(L"Action ");
			buffer += name;
			buffer += L" not found in rule set";

			MT_THROW_COM_ERROR(IID_IMTRuleSetWriter, err.Error(), buffer.c_str());
#endif
		}

		if (action)
    {
			if (action->GetPropertyType() == MTPRODUCTCATALOGLib::PROP_TYPE_ENUM)
			{
        _variant_t val = action->GetPropertyValue();
        if (val.vt != VT_EMPTY)
        {
          long enumid = aEnumConfig->GetID(action->GetEnumSpace(),
                                           action->GetEnumType(),
                                           (_bstr_t) val);
          // the enum ID is passed into the database
          wchar_t buffer[100];
          swprintf(buffer, L"%d", enumid);
          value = buffer;
        }
        else
        {
          value = L"NULL";
        }
			}
      else if (action->GetPropertyType() == MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME)
      {
        // This comes out as a time_t represented as VT_I4 and we need to convert to DATE
        _variant_t val = action->GetPropertyValue();
		if (val.vt == VT_DATE)
		{
          if (!FormatValueForDB(val, aIsOracle, value))
          {
            // TODO:
            ASSERT(0);
            MT_THROW_COM_ERROR("Unable to format value!");
          }   
		}
		else if (val.vt == VT_I8)
		{
	      DATE tdate = (double)val;
		  if (tdate == 0)
		  {
			value = L"NULL";
		  }
		  else
		  {
			if (!FormatValueForDB(_variant_t(tdate, VT_DATE), aIsOracle, value))
			{
				// TODO:
				ASSERT(0);
				MT_THROW_COM_ERROR("Unable to format value!");
			} 
		  }
		}
        else if (val.vt != VT_EMPTY)
        {
          DATE dtVal;
          ::OleDateFromTimet(&dtVal, (time_t) val);
          if (!FormatValueForDB(_variant_t(dtVal, VT_DATE), aIsOracle, value))
          {
            // TODO:
            ASSERT(0);
            MT_THROW_COM_ERROR("Unable to format value!");
          }   
        }
        else
        {
          value = L"NULL";
        }
      }
			else
			{
        _variant_t val = action->GetPropertyValue();
        val.ChangeType(PropValTypeToVariantType((PropValType) action->GetPropertyType()));
				if (!FormatValueForDB(val, aIsOracle, value))
				{
					// TODO:
					ASSERT(0);
					MT_THROW_COM_ERROR("Unable to format value!");
				}
			}
    }
		else
		{
			// action not found - if it's optional, just add NULL to the query
			// TODO: verify that it's optional
			value = L"NULL";
		}

		if (arValues.length() > 0)
			arValues += L", ";
		arValues += value;
	}
}
