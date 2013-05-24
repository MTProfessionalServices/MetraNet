/**************************************************************************
 * DBRSLOADER
 *
 * Copyright 1997-2001 by MetraTech Corp.
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") \
  no_function_mapping
#include <MTSessionBaseDef.h>
#include <PropGenerator.h>
#include <PropConstInfo.h>
#include <DerivedPropInfo.h>

#include <DBRSLoader.h>
#include <memory>

#import <MTProductCatalog.tlb> rename("EOF", "EOFX")
#include <autoptr.h>
#include <SetIterate.h>
#include <mtprogids.h>
#include <stdutils.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <mttime.h>
#include <formatdbvalue.h>
#include <optionalvariant.h>

using MTPipelineLib::IMTNameIDPtr;
using MTPipelineLib::IMTLogPtr;

using namespace MTPRODUCTCATALOGLib;
using namespace std;

#define PRODUCT_CATALOG_QUERY_PATH L"\\Queries\\ProductCatalog"

const wchar_t * OpToString(MTPRODUCTCATALOGLib::MTOperatorType aOp)
{
  const wchar_t * test;
  switch (aOp)
  {
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_EQUAL:
    test = L"equals"; break;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_NOT_EQUAL:
    test = L"not_equals"; break;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_GREATER:
    test = L"greater_than"; break;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_GREATER_EQUAL:
    test = L"greater_equal"; break;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_LESS:
    test = L"less_than"; break;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_LESS_EQUAL:
    test = L"less_equal"; break;

  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_LIKE:
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_LIKE_W:
  default:
    ASSERT(0);
    return NULL;
  }


  return test;
}

//yet another conversion routine
//to-from different flavors of the same bs
PropGenEnums::ConditionType OpToPCInfoOp(MTPRODUCTCATALOGLib::MTOperatorType& aOp)
{
  switch (aOp)
  {
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_EQUAL:
    return PropGenEnums::EQUAL;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_NOT_EQUAL:
    return PropGenEnums::NOT_EQUAL;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_GREATER:
    return PropGenEnums::GREAT_THAN;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_GREATER_EQUAL:
    return PropGenEnums::GREAT_EQUAL;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_LESS:
   return PropGenEnums::LESS_THAN;
  case MTPRODUCTCATALOGLib::OPERATOR_TYPE_LESS_EQUAL:
    return PropGenEnums::LESS_EQUAL;
  default:
    ASSERT(0);
    return PropGenEnums::UNKNOWN_CONDITION_TYPE;
  }

}

//yet another conversion routine
//to-from different flavors of the same bs
PropGenEnums::DataType TypeToPCInfoType(MTPRODUCTCATALOGLib::PropValType& type)
{
  /*
  DATATYPEUNKNOWN,
		DATATYPESTRING,
		DATATYPELONG,
		DATATYPEFLOAT,
		DATATYPEDOUBLE,
		DATATYPEBOOL,
		DATATYPETIME,
		DATATYPEDATETIME,
		DATATYPEENUM,
		DATATYPEDECIMAL,
		DATATYPELONGLONG,

    	PROP_TYPE_UNKNOWN = 0,
	PROP_TYPE_DEFAULT = 1,
	PROP_TYPE_INTEGER = 2,
	PROP_TYPE_DOUBLE = 3,
	PROP_TYPE_STRING = 4,
	PROP_TYPE_DATETIME = 5,
	PROP_TYPE_TIME = 6,
	PROP_TYPE_BOOLEAN = 7,
	PROP_TYPE_SET = 8,
	PROP_TYPE_OPAQUE = 9,
	PROP_TYPE_ENUM = 10,
	PROP_TYPE_DECIMAL = 11,
  PROP_TYPE_ASCII_STRING = 12,
  PROP_TYPE_UNICODE_STRING = 13,
  PROP_TYPE_BIGINTEGER = 14


  */
  switch (type)
  {
  case MTPRODUCTCATALOGLib::PROP_TYPE_UNKNOWN:
  case MTPRODUCTCATALOGLib::PROP_TYPE_DEFAULT:
    return PropGenEnums::DATATYPEUNKNOWN;
  case MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER:
    return PropGenEnums::DATATYPELONG;
  case MTPRODUCTCATALOGLib::PROP_TYPE_DOUBLE:
    return PropGenEnums::DATATYPEDOUBLE;
  case MTPRODUCTCATALOGLib::PROP_TYPE_STRING:
  case MTPRODUCTCATALOGLib::PROP_TYPE_ASCII_STRING:
  case MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING:
    return PropGenEnums::DATATYPESTRING;
  case MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME:
   return PropGenEnums::DATATYPEDATETIME;
  case MTPRODUCTCATALOGLib::PROP_TYPE_TIME:
    return PropGenEnums::DATATYPETIME;
  case MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN:
    return PropGenEnums::DATATYPEBOOL;
  case MTPRODUCTCATALOGLib::PROP_TYPE_ENUM:
    return PropGenEnums::DATATYPEENUM;
  case MTPRODUCTCATALOGLib::PROP_TYPE_DECIMAL:
    return PropGenEnums::DATATYPEDECIMAL;
  case MTPRODUCTCATALOGLib::PROP_TYPE_BIGINTEGER:
    return PropGenEnums::DATATYPELONGLONG;


  default:

    ASSERT(0);
    return PropGenEnums::DATATYPEUNKNOWN;
  }

}



MTPRODUCTCATALOGLib::MTOperatorType DBOpToOp(_bstr_t opStr)
{
  MTPRODUCTCATALOGLib::MTOperatorType test;
  if (opStr == _bstr_t("<"))
    test = MTPRODUCTCATALOGLib::OPERATOR_TYPE_LESS;
  else if (opStr == _bstr_t("<="))
    test = MTPRODUCTCATALOGLib::OPERATOR_TYPE_LESS_EQUAL;
  else if (opStr == _bstr_t("="))
    test = MTPRODUCTCATALOGLib::OPERATOR_TYPE_EQUAL;
  else if (opStr == _bstr_t(">="))
    test = MTPRODUCTCATALOGLib::OPERATOR_TYPE_GREATER_EQUAL;
  else if (opStr == _bstr_t(">"))
    test = MTPRODUCTCATALOGLib::OPERATOR_TYPE_GREATER;
  else if (opStr == _bstr_t("!="))
    test = MTPRODUCTCATALOGLib::OPERATOR_TYPE_NOT_EQUAL;
  else
  {
    return MTPRODUCTCATALOGLib::OPERATOR_TYPE_NONE;
  }


  return test;
}

void DBRSLoader::InitMetaData(IMTParamTableDefinitionPtr aParamTableDef, ParamTableMetaData& aMD)
{

  //init conditions first
  SetIterator<MTPRODUCTCATALOGLib::IMTCollectionPtr, MTPRODUCTCATALOGLib::IMTConditionMetaDataPtr> conditionit;
  HRESULT hr = conditionit.Init(aParamTableDef->GetConditionMetaData());
  while (TRUE)
  {
    IMTConditionMetaDataPtr meta = conditionit.GetNext();
    if (meta == NULL)
      break;
    _bstr_t propName = meta->GetPropertyName();
    _bstr_t colName = meta->GetColumnName();
    MTPRODUCTCATALOGLib::PropValType type = meta->GetDataType();
    VARIANT_BOOL opperrule = meta->GetOperatorPerRule();
    VARIANT_BOOL required = meta->GetRequired();
    MTPRODUCTCATALOGLib::MTOperatorType op = meta->GetOperator();
    aMD.Conditions.push_back(ConditionMetaData(propName, colName, type, opperrule, required, op));

  }


  SetIterator<MTPRODUCTCATALOGLib::IMTCollectionPtr, MTPRODUCTCATALOGLib::IMTActionMetaDataPtr> actionit;
  hr = actionit.Init(aParamTableDef->GetActionMetaData());
  while (TRUE)
  {
    IMTActionMetaDataPtr meta = actionit.GetNext();
    if (meta == NULL)
      break;

    _bstr_t propName = meta->GetPropertyName();
    _bstr_t colName = meta->GetColumnName();
    MTPRODUCTCATALOGLib::PropValType type = meta->GetDataType();
    VARIANT_BOOL required = meta->GetRequired();
    aMD.Actions.push_back(ActionMetaData(propName, colName, type, required));

  }



}

/************************************************ DBRSLoader ***/

BOOL DBRSLoader::Init()
{
  const char * functionName = "DBRSLoader::Init";

  IMTProductCatalogPtr catalog("MetraTech.MTProductCatalog");
  mpCatalog = catalog;

  HRESULT hr = mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);
  if (FAILED(hr))
  {
    SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
             "Unable to initialize enum config object");
    return FALSE;
  }
  hr = mNameId.CreateInstance(MTPROGID_NAMEID);
  if (FAILED(hr))
  {
    SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
             "Unable to initialize nameid object");
    return FALSE;
  }

  if (FAILED(hr = mRuleSetFactory.Init(L"MTRuleSet.MTRuleSet.1"))
      || FAILED(hr = mRuleFactory.Init(L"MTRule.MTRule.1"))
      || FAILED(hr = mActionSetFactory.Init(L"MTActionSet.MTActionSet.1"))
      || FAILED(hr = mConditionSetFactory.Init(L"MTConditionSet.MTConditionSet.1"))
      || FAILED(hr = mActionFactory.Init(L"MTAssignmentAction.MTAssignmentAction.1"))
      || FAILED(hr = mConditionFactory.Init(L"MTSimpleCondition.MTSimpleCondition.1"))
      || FAILED(hr = mRuleSetEvaluatorFactory.Init(L"MetraTech.MTRuleSetEvaluator.1")))
  {
    SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
             "Unable to initialize class factory");
    return FALSE;
  }

  hr = mLogger.CreateInstance("MetraPipeline.MTLog.1");
  if (FAILED(hr))
  {
    SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
             "Unable to initialize nameid object");
    return FALSE;
  }

  mLogger->Init("logging", "[DBRSLoader]");

  return TRUE;
}

time_t DBRSLoader::GetLastModified(int aScheduleID)
{
#if 0
  char filename[1024];
  sprintf(filename, "%s\\Schedule%d.xml", mRootDir.c_str(), aScheduleID);

  // use the file modification date
  struct _stat statBuffer;

  // get file info
  if (_stat(filename, &statBuffer) != 0)
  {
    // unable to get file modification time
    // TODO:
    ASSERT(0);
    return NULL;
  }

  return statBuffer.st_mtime;
#endif
  ASSERT(0);
  return 0;
}

// create a rate schedule with the ruleset evaluator created
// and modification date initialized.
CachedRateSchedulePropGenerator * DBRSLoader::CreateRateSchedule(int    aParamTableID,
                                                                 time_t aModifiedAt)
{
  CachedRateSchedulePropGenerator * schedule = new CachedRateSchedulePropGenerator(aModifiedAt, aParamTableID);

  //RuleSetEvaluator is ONLY used by RuleSetReader for MCM display purposes and
  //is NEVER used during rating.
  //Create it on demand instead/
  //HRESULT hr = schedule->mEvaluator.CreateInstance("MetraTech.MTRuleSetEvaluator.1");
  //if (FAILED(hr))
  //{
  //  delete schedule;
  //  return NULL;
  //}


  return schedule;
}

CachedRateSchedule* DBRSLoader::LoadRateSchedule(int    aParamTableID,
                                                 int    aScheduleID,
                                                 time_t aModifiedAt)
{
  //MTPRODUCTCATALOGLib::MTPipelineLib::IMTRuleSetPtr ruleset = mRuleSetFactory.CreateInstance();
  MTautoptr<PropGenRuleSet> ruleset = new PropGenRuleSet;

  // populate the CachedRateSchedulePropGenerator object
  CachedRateSchedulePropGenerator* rawSchedule = CreateRateSchedule(aParamTableID,
                                                                    aModifiedAt);
  if (!rawSchedule)
  {
    // TODO:
    ASSERT(0);
    return NULL;                // unable to create a schedule
  }

  // TODO: clean up error handling here
  std::auto_ptr<CachedRateSchedule> schedule(rawSchedule);

  // load it into a ruleset
  if (!LoadRateScheduleToRuleSet(ruleset, aParamTableID, aScheduleID, rawSchedule))
    return NULL;

   if(rawSchedule->IsIndexed() == FALSE)
   {
     //IMTRuleSetEvaluatorPtr eval = schedPtr->GetEvaluator();
     // configure the evaluator based on the rules we just loaded
     //eval->Configure((MTPipelineLib::IMTRuleSet*)(ruleset.GetInterfacePtr()));
     PropGenerator* pPropGen = rawSchedule->GetPropGen();
     pPropGen->Configure(mLogger, mNameId, ruleset);
   }

  return schedule.release();
}

BOOL DBRSLoader::LoadRateScheduleToRuleSet(//MTPRODUCTCATALOGLib::MTPipelineLib::IMTRuleSetPtr       aRuleset,
                                           PropGenRuleSet*     apRuleset,
                                           int                 aParamTableID,
                                           int                 aScheduleID,
                                           CachedRateSchedulePropGenerator* apSchedule)
{
  try
  {
    IMTProductCatalogPtr catalog(mpCatalog);
    IMTParamTableDefinitionPtr paramTableDef = catalog->GetParamTableDefinition(aParamTableID);

    _variant_t vtNull;
    vtNull.ChangeType(VT_NULL);

    return LoadRateScheduleToRuleSet(apRuleset, paramTableDef, aScheduleID, apSchedule, vtNull);
  }
  catch (_com_error & err)
  {
    // TODO:
    ErrorObject * errobj = CreateErrorFromComError(err);
    SetError(errobj, "Unable to load rate schedule");
    return FALSE;
  }
  return TRUE;
}

BOOL DBRSLoader::LoadRateScheduleToRuleSet(//MTPRODUCTCATALOGLib::MTPipelineLib::IMTRuleSetPtr              aRuleset,
                                           PropGenRuleSet* apRuleset,
                                           IMTParamTableDefinitionPtr aParamTableDef,
                                           int                        aScheduleID,
                                           CachedRateSchedulePropGenerator*        apSchedule,
                                           VARIANT                    aRefDate)
{
  BOOL retVal = FALSE;

  try
  {
    //set refdate used to retrieve previous versions of the ruleset
    _variant_t vtRefDate;
    wstring strRefDate;
    if(!OptionalVariantConversion(aRefDate,VT_DATE,vtRefDate))
    {
      vtRefDate = GetMTOLETime();
    }
    FormatValueForDB(vtRefDate,FALSE,strRefDate);

    MTPipelineLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);

    rowset->Init(PRODUCT_CATALOG_QUERY_PATH);

    rowset->SetQueryTag("__GET_PARAM_TABLE_VALUES__");
    rowset->AddParam("%%TABLE_NAME%%", (const wchar_t *) aParamTableDef->GetDBTableName());
    rowset->AddParam("%%REFDATE%%",strRefDate.c_str(),VARIANT_TRUE);

    _variant_t param;
    param = (long) aScheduleID;
    rowset->AddParam("%%SCHEDULE%%", param);

    rowset->Execute();

    ParamTableMetaData md;
    InitMetaData(aParamTableDef, md);

    retVal = LoadRateScheduleToRuleSetFromRowSet(rowset,
                                                 apRuleset,
                                                 aParamTableDef,
                                                 &md,
                                                 aScheduleID,
                                                 apSchedule);
    rowset->Clear();
  }
  catch(ErrorObject localError)
  {
    // TODO:
    ASSERT(0);
    return FALSE;
  }

  return retVal;
}


BOOL DBRSLoader::LoadRateSchedules(int                 aParamTableID,
                                   time_t              aModifiedAt,
                                   RATESCHEDULEVECTOR& aRateSchedInfo)
{
  BOOL retVal = FALSE;

  try
  {
    IMTProductCatalogPtr catalog(mpCatalog);
    IMTParamTableDefinitionPtr paramTableDef = catalog->GetParamTableDefinition(aParamTableID);

    retVal = LoadRateSchedulesToRuleSets(aParamTableID, paramTableDef,
                                           aModifiedAt, aRateSchedInfo);
  }
  catch(ErrorObject localError)
  {
    // TODO:
    ASSERT(0);
    retVal = FALSE;
  }
  /*
  catch(_com_error& err)
  {
    // TODO:
    //ErrorObject * errobj = CreateErrorFromComError(err);
    //SetError(errobj, "Unable to load rate schedules");
    //retVal = FALSE;
  }
  */

  return retVal;
}

// NOTE: this method will throw COM errors!
BOOL DBRSLoader::LoadRateSchedulesToRuleSets(
                            int                                             aParamTableID,
                            MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef,
                            time_t                                          aModifiedAt,
                            RATESCHEDULEVECTOR&                             aRateSchedInfo)
{
  BOOL retVal = TRUE;

  MTPipelineLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);

  rowset->Init(PRODUCT_CATALOG_QUERY_PATH);

  rowset->SetQueryTag("__GET_ALL_PARAM_TABLE_VALUES__");
  rowset->AddParam("%%TABLE_NAME%%", (const wchar_t *) aParamTableDef->GetDBTableName());

  rowset->Execute();
  
  int                 schedID  = -1;
  CachedRateSchedulePropGenerator* schedPtr = 0;
  // while not at "end of rowset"...
  int rscount = 0;
  ParamTableMetaData md;
  InitMetaData(aParamTableDef, md);
  while (!((bool)(rowset->GetRowsetEOF())))
  {
    schedID = rowset->GetValue("id_sched");
   

    
    // populate the CachedRateSchedule object
    schedPtr = CreateRateSchedule(aParamTableID, aModifiedAt);
    if (schedPtr == 0)
    {
      retVal = FALSE; // unable to create a schedule
      break;
    }

    //MTPRODUCTCATALOGLib::IMTRuleSetPtr ruleset = mRuleSetFactory.CreateInstance();
    MTautoptr<PropGenRuleSet> ruleset = new PropGenRuleSet;


    retVal = LoadRateScheduleToRuleSetFromRowSet(rowset,
                                                 &ruleset,
                                                 aParamTableDef,
                                                 &md,
                                                 schedID,
                                                 schedPtr);
    //cout << "done loading rs " << schedID << "; rs count " << ++rscount << endl;
    if (!retVal)
    {
      delete(schedPtr);
      break;
    }

    //CR 12855 - if this is an aggregate RS, do not initialize 
    // this rule set, only indexed_rules (space optimization task).
    if(schedPtr->IsIndexed() == FALSE)
    {
     //IMTRuleSetEvaluatorPtr eval = schedPtr->GetEvaluator();
     // configure the evaluator based on the rules we just loaded
     //eval->Configure((MTPipelineLib::IMTRuleSet*)(ruleset.GetInterfacePtr()));
     PropGenerator* pPropGen = schedPtr->GetPropGen();
     pPropGen->Configure(mLogger, mNameId, ruleset);
    }

    aRateSchedInfo.push_back(RateScheduleInfo(schedID, schedPtr));
  }

  return retVal;
}

BOOL DBRSLoader::LoadRateScheduleToRuleSetFromRowSet(
                                        MTPipelineLib::IMTSQLRowsetPtr aRowset,
                                        PropGenRuleSet* aRuleset, //MTPRODUCTCATALOGLib::MTPipelineLib::IMTRuleSetPtr                  aRuleset,
                                        MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr aParamTableDef,
                                        ParamTableMetaData* apMD,
                                        int                            aScheduleID,
                                        CachedRateSchedulePropGenerator*            apSchedule)
{
  try
  {
    HRESULT hr = S_OK;

    _bstr_t indexedPropName = aParamTableDef->GetIndexedProperty();
    BOOL index = (indexedPropName.length() > 0);

    CachedRateSchedule::IndexedRulesVector* indexedRules;
    if (index)
    {
      indexedRules = new CachedRateSchedule::IndexedRulesVector;
    }
    else
      indexedRules = NULL;

    //MTPRODUCTCATALOGLib::MTPipelineLib::IMTRuleSetPtr indexedRuleset;
    MTautoptr<PropGenRuleSet> indexedRuleset;


    _variant_t startValue;
    _variant_t endValue;

    if (index)
    {
      startValue = (_variant_t) MTDecimal(0L);
      endValue = (_variant_t) MTDecimal(0L);
    }

    _variant_t indexValue;

    //offset of the rule within a rate schedule. Starts with 0
    //we need this to pass to PropConstInfo ctor()
    int pcid = 1;
    while (!((bool)(aRowset->GetRowsetEOF())))
    {
      // Break out of loop at EOF or when the schedule id changes...
      if (aScheduleID != (int)(aRowset->GetValue("id_sched")))
        break;
      _variant_t val;
      
      // this rule
      //MTPipelineLib::IMTRulePtr rule = mRuleFactory.CreateInstance();
      MTautoptr<PropGenRule> rule(new PropGenRule);
      
      // this rule in the indexed ruleset
      //MTPipelineLib::IMTRulePtr indexedRule;
      MTautoptr<PropGenRule> indexedRule;

      // basically the same as conditions, but without the condition
      // in the indexed column
      // IMTConditionSetPtr indexedConditions;
      MTautoptr<vector<ConditionTriplet*> >  indexedConditions;

      if (index)
      {
        //indexedRule = mRuleFactory.CreateInstance(); 
        indexedRule = new PropGenRule;
        //indexedConditions = mConditionSetFactory.CreateInstance();
        indexedConditions = new vector<ConditionTriplet*>();
      }

      //IMTActionSetPtr actions = mActionSetFactory.CreateInstance();
      //IMTConditionSetPtr conditions = mConditionSetFactory.CreateInstance();
      MTautoptr<vector<const DerivedPropInfo*> >  actions = new vector<const DerivedPropInfo*>();
      MTautoptr<vector<ConditionTriplet*> >  conditions = new vector<ConditionTriplet*>();
      //
      // conditions
      //
      //cout << aParamTableDef->GetConditionMetaData()->GetCount() << endl;
      const vector<ConditionMetaData>* condmd = apMD->GetConditions();
      for(vector<ConditionMetaData>::const_iterator it = condmd->begin(); it != condmd->end(); it++)
      {
        const ConditionMetaData* meta = &*it;

        // property name
        _bstr_t propName = meta->GetPropertyName();
        // derive the column name
        _bstr_t colName = meta->GetColumnName();

        MTPRODUCTCATALOGLib::PropValType type = meta->GetDataType();

        val = aRowset->GetValue(colName);

        // remember the value if this is the condition we're indexing on
        // TODO: indexed properties should always be required
        if (index && 0 == mtwcscasecmp(propName, indexedPropName))
          indexValue = val;

        if (V_VT(&val) != VT_NULL)
        {
          MTPRODUCTCATALOGLib::MTOperatorType op;
          if (meta->GetOperatorPerRule() == VARIANT_TRUE)
          {
            // the operator is in the table itself

            // TODO: encapsulate this!
            // we have to figure out the unique suffix appended to the column name
            // in order to put the same suffix on the operator.
            // TODO: this is kind of a hack

            wchar_t opColumnName[256];
            _bstr_t suffix = "";
            wchar_t genColumnName[256];
            wsprintf(genColumnName, L"c_%s", (wchar_t*)propName);
            unsigned int len = _bstr_t(genColumnName).length();

            if (colName.length() > len)
            {
              suffix = (const wchar_t *) colName + len;
            }

            wsprintf(opColumnName, L"c_%s_op%s", (wchar_t*)propName, (wchar_t*)suffix);

            // the operator is in the table itself
            //_bstr_t opColName = colName;
            //opColName += _bstr_t(L"_op");

            _variant_t conditionVal = aRowset->GetValue(opColumnName);
            if (V_VT(&conditionVal) == VT_NULL)
            {
              std::string buffer("The operator for property ");
              buffer += meta->GetPropertyName();
              buffer += " is NULL but the value itself is not";
              SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE,
                buffer.c_str());
              return FALSE;
            }
            _bstr_t opStr = conditionVal;

            op = DBOpToOp(opStr);
            if(op == MTPRODUCTCATALOGLib::OPERATOR_TYPE_NONE)
            {
              char buf[256];
              sprintf(buf, "'%s', found in column '%s' is not a valid operator", (char*)opStr, (char*)_bstr_t(opColumnName));
              ErrorObject * errobj = CreateErrorFromComError(E_FAIL);
              SetError(errobj, buf);
              return FALSE;
            }
          }
          else //meta->GetOperatorPerRule() == VARIANT_TRUE
            op = (MTPRODUCTCATALOGLib::MTOperatorType) meta->GetOperator();
          long nameid = mNameId->GetNameID(propName);
          PropGenEnums::ConditionType pcinfocondition =  OpToPCInfoOp(op);
          PropGenEnums::DataType pcinfotype =  TypeToPCInfoType(type);

          if (type == MTPRODUCTCATALOGLib::PROP_TYPE_ENUM)
          {
            //just a note:
            //nothing special needs to be done for enums - before it used
            //to convert to the string just to pass it down to Propgenerator, where
            //it would be converted to long again. we are eliminating this step.
            //This means that we don't have to worry about enum space/enum type from metadata.
            ;
          }
          else if (type == MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN)
          {
            ASSERT(V_VT(&val) == VT_BSTR);
            //make sure it's in correct format (someone might manually put 'Y' or 'N' instead)
            ASSERT(!strcmp((char*)val.bstrVal, "1") || !strcmp((char*)val.bstrVal, "0") );
            ChangeToBool(val);
          }

          ConditionTriplet* condition = 
            ConditionTripletLibrary::GetInstance()->Add(nameid, pcinfocondition, val, (MTPipelineLib::PropValType)type);

          conditions->push_back(condition);

          // if it's not the indexed column...
          if (index && 0 != mtwcscasecmp(propName, indexedPropName))
            indexedConditions->push_back(condition);
        }
        //V_VT(&val) != VT_NULL
        else
        {
          // verify that this condition is optional
          if (meta->GetRequired() == VARIANT_TRUE)
          {
            std::string buffer("The condition property ");
            buffer += propName;
            buffer += " is required but NULL in the database";
            SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE,
              buffer.c_str());
            return FALSE;
          }
        }
      }
      
      //
      // actions
      //
      const vector<ActionMetaData>* actionmd = apMD->GetActions();
      for(vector<ActionMetaData>::const_iterator it = actionmd->begin(); it != actionmd->end(); it++)
      {
        const ActionMetaData* meta = &*it;
        // property name
        _bstr_t propName = meta->GetPropertyName();

        // derive the column name
        _bstr_t colName = meta->GetColumnName();
        long nameid = mNameId->GetNameID(propName);

        MTPRODUCTCATALOGLib::PropValType type = meta->GetDataType();

        val = aRowset->GetValue(colName);

        if (V_VT(&val) != VT_NULL)
        {
          if (type == MTPRODUCTCATALOGLib::PROP_TYPE_ENUM)
          {
            //just a note:
            //nothing special needs to be done for enums - before it used
            //to convert to the string just to pass it down to Propgenerator, where
            //it would be converted to long again. we are eliminating this step.
            //This means that we don't have to worry about enum space/enum type from metadata.
            ;
          }
          else if (type == MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN)
          {
            ASSERT(V_VT(&val) == VT_BSTR);
            //make sure it's in correct format (someone might manually put 'Y' or 'N' instead)
            ASSERT(!strcmp((char*)val.bstrVal, "1") || !strcmp((char*)val.bstrVal, "0") );
            ChangeToBool(val);
          }
          const DerivedPropInfo* action  = 
            DerivedPropInfoLibrary::GetInstance()->Add(nameid, (MTPipelineLib::PropValType)type, val);
            //new DerivedPropInfo(nameid, (MTPipelineLib::PropValType)type, val);
            
          actions->push_back(action);
        }
        //V_VT(&val) != VT_NULL
        else
        {
          // verify that this action is optional
          if (meta->GetRequired() == VARIANT_TRUE)
          {
            std::string buffer("The action property ");
            buffer += propName;
            buffer += " is required but NULL in the database";
            SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE,
                     buffer.c_str());
            return FALSE;
          }
        }
      }
      if (index)
      {
        indexedRule->PutConditions(indexedConditions);
        indexedRule->PutActions(actions);

        BOOL firstTime = (indexedRuleset == NULL);

        if (firstTime || indexValue != endValue)
        {
          if (firstTime)
          {
            // 0 - current value
            endValue = indexValue;
          }
          else
          {
            // add the current ruleset to the index
            //IMTRuleSetEvaluatorPtr eval = mRuleSetEvaluatorFactory.CreateInstance();
            //eval->Configure(reinterpret_cast<MTPipelineLib::IMTRuleSet *>(indexedRuleset.GetInterfacePtr()));
            PropGenerator* pPropGen = new PropGenerator();
            pPropGen->Configure(mLogger, mNameId, indexedRuleset);
            indexedRules->push_back(IndexedRulesPropGenerator::Create(startValue, endValue, pPropGen));

            // move on to the next value
            startValue = endValue;
            endValue = indexValue;
          }

          // create the next ruleset that will be added to the index
          //indexedRuleset = mRuleSetFactory.CreateInstance();
          indexedRuleset = new PropGenRuleSet();
        }
        if (indexedConditions->size() == 0)
          // no additional conditions - only actions
          // that means these are default rules
          indexedRuleset->PutDefaultActions(actions);
        else
          // other wise it's a complete rule - conditions and actions
          indexedRuleset->Add(indexedRule);
      }

      if (conditions->size() != 0)
      {
        rule->PutConditions(conditions);
        rule->PutActions(actions);

        aRuleset->Add(rule);
      }
      else
      {
        // no conditions - the actions always match.
        // in this case, the actions are the default actions and
        // only the first set matters.  Additional actions are ignored
        // (they would never match)
        aRuleset->PutDefaultActions(actions);
        // Add(rule) is never called - no rules

        // commented out so that the default action can be in the middle of condition/action list
        //break;
      }

      aRowset->MoveNext(); //Go on to the next rule
      pcid++;
    } //while
    if (index)
    {
      // add the last ruleset to the index
      if (indexedRuleset != NULL)
      {
        // TODO: indexValue might be NULL, meaning infinity

        //IMTRuleSetEvaluatorPtr eval = mRuleSetEvaluatorFactory.CreateInstance();

        // cast across namespace
        //eval->Configure(reinterpret_cast<MTPipelineLib::IMTRuleSet *>(indexedRuleset.GetInterfacePtr()));
        //BP TODO: pass imtnameid and logger pointers from somewhere
        PropGenerator* pPropGen = new PropGenerator();
        pPropGen->Configure(mLogger, mNameId, indexedRuleset);


        // NOTE: last value end is equal to begin.
        // this large decimal is used to represent infinity.
        indexedRules->push_back(IndexedRulesPropGenerator::Create(startValue, 
                                                                  V_VT(&indexValue) == VT_NULL ? MTDecimal("999999999999999999.999999") : endValue, 
                                                                  pPropGen));
        
      }
      int count = indexedRules->size();
      apSchedule->SetIndex(indexedRules);
    }
    //if (index)
  }
  catch(ErrorObject aLocalError)
  {
    char errStr[1024];
    sprintf(errStr, "Caught ErrorObject: %s, %s(%d) %s(error code: %X)", 
            aLocalError.GetModuleName(),
            aLocalError.GetFunctionName(),
            aLocalError.GetLineNumber(),
            aLocalError.GetProgrammerDetail().c_str(),
            aLocalError.GetCode());
    cout << errStr <<endl;

    return FALSE;
  }
  
  return TRUE;
}

//TODO: Move to Utils
void DBRSLoader::ChangeToBool(_variant_t& aVal)
{
  _bstr_t bstrVal = (_bstr_t) aVal;
  aVal.ChangeType(VT_BOOL);
  // We ALWAYS store booleans as 1 and 0 in msixdef tables
  aVal = (strcmp((char*)bstrVal, "1") == 0) ? VARIANT_TRUE : VARIANT_FALSE;
  return;
}


// transforms a PropGenRuleSet into an IMTRuleSet
BOOL DBRSLoader::LoadRateScheduleToRuleSet(MTPRODUCTCATALOGLib::IMTRuleSetPtr comRuleset,
                                           IMTParamTableDefinitionPtr aParamTableDef,
                                           int                        aScheduleID,
                                           CachedRateSchedulePropGenerator*        apSchedule,
                                           VARIANT                    aRefDate)
{

  try
  {
    PropGenRuleSet ruleset;
    if (!LoadRateScheduleToRuleSet(&ruleset, aParamTableDef, aScheduleID, apSchedule, aRefDate))
			return FALSE;

		// iterates over the natvie ruleset's rules
		const vector<ConditionTriplet*>* conditions;
		const vector<const DerivedPropInfo*>* actions;
		const vector<MTautoptr<PropGenRule> >* rules = ruleset.GetRules();
		for(vector<MTautoptr<PropGenRule> >::const_iterator it = rules->begin(); it != rules->end(); it++)
		{
			const PropGenRule* rule = &*it;

			MTPipelineLib::IMTRulePtr comRule = mRuleFactory.CreateInstance();
			comRuleset->Add((MTPRODUCTCATALOGLib::IMTRulePtr) comRule);

			
			// converts conditions
			conditions = rule->GetConditions();
			if (conditions)
			{
				MTPipelineLib::IMTConditionSetPtr comConditions = mConditionSetFactory.CreateInstance();

				for(vector<ConditionTriplet*>::const_iterator it = conditions->begin(); it != conditions->end(); it++)
				{
					const ConditionTriplet* condition = *it;

					MTPipelineLib::IMTSimpleConditionPtr comCondition = mConditionFactory.CreateInstance();
					ConvertConditionToCom(condition, aParamTableDef, comCondition);

					comConditions->Add(comCondition);
				}

				comRule->Conditions = comConditions;
			}

			// converts actions
			actions = rule->GetActions();
			if (actions)
			{
				MTPipelineLib::IMTActionSetPtr comActions = mActionSetFactory.CreateInstance();

				for(vector<const DerivedPropInfo*>::const_iterator it = actions->begin(); it != actions->end(); it++)
				{
					const DerivedPropInfo* action = *it;
					
					MTPipelineLib::IMTAssignmentActionPtr comAction = mActionFactory.CreateInstance();
					ConvertActionToCom(action, aParamTableDef, comAction);

					comActions->Add(comAction);
				}

				comRule->Actions = comActions;
			}
		}

		// converts default actions
		const vector<const DerivedPropInfo*>* defaultActions;
		defaultActions = ruleset.GetDefaultActions();
		if (defaultActions)
		{
			MTPipelineLib::IMTActionSetPtr comDefaultActions = mActionSetFactory.CreateInstance();

			for(vector<const DerivedPropInfo*>::const_iterator it = defaultActions->begin(); it != defaultActions->end(); it++)
			{
				const DerivedPropInfo* defaultAction = *it;
				
				MTPipelineLib::IMTAssignmentActionPtr comDefaultAction = mActionFactory.CreateInstance();
				ConvertActionToCom(defaultAction, aParamTableDef, comDefaultAction);

				comDefaultActions->Add(comDefaultAction);
			}

			comRuleset->DefaultActions = (MTPRODUCTCATALOGLib::IMTActionSetPtr) comDefaultActions;
		}

    return TRUE;
  }
  catch(ErrorObject localError)
  {
    // TODO:
    ASSERT(0);
    return FALSE;
  }
}

// converts a native (C++) condition to a COM condition
void DBRSLoader::ConvertConditionToCom(const ConditionTriplet* condition,
																			 IMTParamTableDefinitionPtr aParamTableDef,
																			 MTPipelineLib::IMTSimpleConditionPtr comCondition)
{
	MTPRODUCTCATALOGLib::IMTConditionMetaDataPtr metadata = LookupConditionMetadata(condition->GetPropNameID(), aParamTableDef);

	comCondition->PropertyName = metadata->GetPropertyName();
	comCondition->Test = condition->GetComCondition();
	comCondition->ValueType = condition->GetComDataType();

	if (condition->GetType() == PropGenEnums::DATATYPEENUM)
	{
		comCondition->EnumSpace = metadata->EnumSpace;
		comCondition->EnumType  = metadata->EnumType;
		comCondition->Value = mEnumConfig->GetEnumeratorByID(condition->GetComValue());
	}
	else
		comCondition->Value = condition->GetComValue();

}


// converts a native action to a COM action
void DBRSLoader::ConvertActionToCom(const DerivedPropInfo* action,
																		IMTParamTableDefinitionPtr aParamTableDef,
																		MTPipelineLib::IMTAssignmentActionPtr comAction)
{
	MTPRODUCTCATALOGLib::IMTActionMetaDataPtr metadata = LookupActionMetadata(action->GetDerivedPropNameID(), aParamTableDef);

	comAction->PropertyName = metadata->GetPropertyName();
	comAction->PropertyType = action->GetComValueType();

	if (action->GetValueType() == PropGenEnums::DATATYPEENUM)
	{
		comAction->EnumSpace = metadata->EnumSpace;
		comAction->EnumType  = metadata->EnumType;
		comAction->PropertyValue = mEnumConfig->GetEnumeratorByID(action->GetComValue());
	}
	else
		comAction->PropertyValue = action->GetComValue(); 

}

MTPRODUCTCATALOGLib::IMTConditionMetaDataPtr DBRSLoader::LookupConditionMetadata(long propNameID,
																																								 IMTParamTableDefinitionPtr aParamTableDef)
{
  SetIterator<MTPRODUCTCATALOGLib::IMTCollectionPtr, MTPRODUCTCATALOGLib::IMTConditionMetaDataPtr> it;
  HRESULT hr = it.Init(aParamTableDef->GetConditionMetaData());

  // TODO: do something better than a linear lookup!
  while (TRUE)
  {
    IMTConditionMetaDataPtr metadata = it.GetNext();
    if (metadata == NULL)
      return NULL;

		long metadataNameID = mNameId->GetNameID(metadata->GetPropertyName());
		if (propNameID == metadataNameID)
			return metadata;
	}
}


MTPRODUCTCATALOGLib::IMTActionMetaDataPtr DBRSLoader::LookupActionMetadata(long propNameID,
																																					 IMTParamTableDefinitionPtr aParamTableDef)
{
  SetIterator<MTPRODUCTCATALOGLib::IMTCollectionPtr, MTPRODUCTCATALOGLib::IMTActionMetaDataPtr> it;
  HRESULT hr = it.Init(aParamTableDef->GetActionMetaData());

  // TODO: do something better than a linear lookup!
  while (TRUE)
  {
    IMTActionMetaDataPtr metadata = it.GetNext();
    if (metadata == NULL)
      return NULL;

		long metadataNameID = mNameId->GetNameID(metadata->GetPropertyName());
		if (propNameID == metadataNameID)
			return metadata;
	}
}

