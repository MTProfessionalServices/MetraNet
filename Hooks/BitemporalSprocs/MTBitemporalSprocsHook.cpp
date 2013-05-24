/**************************************************************************
 *
 * Copyright 2002 by MetraTech Corporation
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
 ***************************************************************************/

#include <metra.h>
#include <comdef.h>

#include <HookSkeleton.h>
#include <mtprogids.h>
#include <stdutils.h>
#include <ConfigDir.h>
#include <vector>
#include <AccHierarchiesShared.h>

#include <mtglobal_msg.h>

using namespace std;
#import <MTConfigLib.tlb>
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )

typedef struct ParamStruct_t {

  ParamStruct_t() : Nullable(false), bKey(false),bNonKeyComparison(false) {}

  _bstr_t paramName;
  _bstr_t genName;
  bool Nullable;
  bool bKey;
  bool bNonKeyComparison;
  _bstr_t type;
  _bstr_t length;
  _bstr_t tempVarName;
} ParamStruct;


CLSID CLSID_MTBitemporalSprocsHook = /*39ec1c3a-7ed8-43e9-9310-1a5f5a4ea458*/
{ 0x39ec1c3a, 
	0x7ed8, 
	0x43e9, 
	{ 0x93, 0x10, 0x1a, 0x5f, 0x5a, 0x4e, 0xa4, 0x58 } 
};


class ATL_NO_VTABLE MTBitemporalSprocsHook :
  public MTHookSkeleton<MTBitemporalSprocsHook,&CLSID_MTBitemporalSprocsHook>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var,long* pVal);

protected:
  // helper methods
  void BuildKeyComparisonString(vector<ParamStruct>&,_bstr_t& outputStr);
  void BuildPrimaryKeysNotNullString(vector<ParamStruct>&,_bstr_t& outputStr);
  void BuildSprocParamString(vector<ParamStruct>&,_bstr_t& outputStr);
  void BuildNonKeyComparisonString(vector<ParamStruct>&,_bstr_t& outputStr);
  void BuildTempVarStr(vector<ParamStruct>&,_bstr_t& outputStr);
  void BuildCommaParams(vector<ParamStruct>&,_bstr_t& commaInputParams,_bstr_t& paramsStr,_bstr_t& tempvarStr);
  void SQLServerTempVarAssignment(vector<ParamStruct>&,_bstr_t& outputStr);
  void BuildNonKeyNegativeComparisionStr(vector<ParamStruct>&,_bstr_t& outputStr);

  // generate the stored procedure
  void GenerateSproc(MTConfigLib::IMTConfigPropSetPtr pSet);

protected:
  bool bOracle;
};

HOOK_INFO(CLSID_MTBitemporalSprocsHook, MTBitemporalSprocsHook,
						"MetraHook.MTBitemporalSprocsHook.1", "MetraHook.MTBitemporalSprocsHook", "both")


/////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////
//MTBitemporalSprocsHook::ExecuteHook
/////////////////////////////////////////////////////////////////////////////

HRESULT MTBitemporalSprocsHook::ExecuteHook(VARIANT var,long* pVal)
{
  try {

    ROWSETLib::IMTSQLRowsetPtr rs(__uuidof(ROWSETLib::MTSQLRowset));
    rs->Init("queries\\database");
    _bstr_t dbType = rs->GetDBType();
    bOracle = (dbType == _bstr_t("{Oracle}")) ? true : false;


    mLogger.LogThis(LOG_INFO,"Create bitemporal stored procedures....");

    MTConfigLib::IMTConfigPtr configPtr(MTPROGID_CONFIG);
    string configDir;
    GetMTConfigDir(configDir);

    _bstr_t pathStr = configDir.c_str();
    pathStr += "\\bitemporal\\bitemporal_sprocs.xml";
    VARIANT_BOOL vbCheckSumMatch;

    MTConfigLib::IMTConfigPropSetPtr propsetPtr = 
       configPtr->ReadConfiguration(pathStr,&vbCheckSumMatch);

    MTConfigLib::IMTConfigPropSetPtr tableSetPtr;
    while((tableSetPtr = propsetPtr->NextSetWithName("sprocdef")) != NULL) {
      GenerateSproc(tableSetPtr);
    }

    mLogger.LogThis(LOG_INFO,"Done generating bitemporal stored procedures.");

    // recompile the MetraTech stored procedures
    if(bOracle) {
      mLogger.LogThis(LOG_INFO,"Recompiling Metratech Stored procedures....");
      rs->InitializeForStoredProc("RecompileMetratech");
      rs->ExecuteStoredProc();
      mLogger.LogThis(LOG_INFO,"Done recompiling stored procedures.");
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return S_OK;
}



void MTBitemporalSprocsHook::GenerateSproc(MTConfigLib::IMTConfigPropSetPtr pSet)
{
   MTConfigLib::IMTConfigAttribSetPtr sprocAttrs = pSet->GetAttribSet();
   bool bSingleRecord = false;
   try {
     bSingleRecord = sprocAttrs->GetAttrValue("singleRecord") == _bstr_t("Y") ? true : false;
   }
   catch(_com_error&) {}

  _bstr_t tableNameStr = pSet->NextStringWithName("tablename");
  _bstr_t bitemporalTableName = pSet->NextStringWithName("bitemporal_table");
  _bstr_t sprocName = pSet->NextStringWithName("name");
  _bstr_t subscription = pSet->NextStringWithName("subscription");

  vector<ParamStruct> params;

  MTConfigLib::IMTConfigPropSetPtr keysPtr = pSet->NextSetWithName("params");
  MTConfigLib::IMTConfigPropPtr currentProp;
  while((currentProp = keysPtr->NextWithName("param")) != NULL) {
    MTConfigLib::IMTConfigAttribSetPtr attribSet = currentProp->GetAttribSet();

    ParamStruct paramInfo;

    // get required properties
    paramInfo.paramName = attribSet->GetAttrValue("name");
    if(bOracle) {
      paramInfo.genName = "p_" + paramInfo.paramName;
      paramInfo.tempVarName = "temp_" + paramInfo.paramName;
    }
    else {
      paramInfo.genName = "@p_" + paramInfo.paramName;
      paramInfo.tempVarName = "@temp_" + paramInfo.paramName;

    }
    paramInfo.type = attribSet->GetAttrValue("type");

    // optional values
    try {
      paramInfo.length = attribSet->GetAttrValue("length");
    }
    catch(_com_error&) {}
    try {
      paramInfo.Nullable = attribSet->GetAttrValue("nullable") == _bstr_t("Y") ? true : false;
    }
    catch(_com_error&) {}
    try {
      paramInfo.bKey = attribSet->GetAttrValue("key") == _bstr_t("Y") ? true : false;
    }
    catch(_com_error&) {}
    try {
      paramInfo.bNonKeyComparison = attribSet->GetAttrValue("ChangeKey") == _bstr_t("Y") ? true : false;
    }
    catch(_com_error&) {}


    params.push_back(paramInfo);
  }

  _bstr_t comparisonStr;
  _bstr_t sprocParamStr;
  _bstr_t KeyComparisonStr;
  _bstr_t tempVarStr;
  _bstr_t commaParams,commaTempVars,commaInputParams;
  _bstr_t nonKeyNegativeComparisionStr;
  _bstr_t primaryKeysNotNullStr;

  BuildKeyComparisonString(params,KeyComparisonStr);
  BuildPrimaryKeysNotNullString(params, primaryKeysNotNullStr);
  BuildSprocParamString(params,sprocParamStr);
  BuildNonKeyComparisonString(params,comparisonStr);
  
  if(comparisonStr.length() == 0) {
    comparisonStr = KeyComparisonStr;
  }

  BuildTempVarStr(params,tempVarStr);
  BuildCommaParams(params,commaInputParams,commaParams,commaTempVars);
  BuildNonKeyNegativeComparisionStr(params,nonKeyNegativeComparisionStr);

  ROWSETLib::IMTSQLRowsetPtr rs(__uuidof(ROWSETLib::MTSQLRowset));
  rs->Init(ACC_HIERARCHIES_QUERIES);
  rs->SetQueryTag("__BITEMPORAL_TEMPLATE__");
  rs->AddParam("%%PROCNAME%%",sprocName);
  rs->AddParam("%%PARAMS%%",sprocParamStr);
  rs->AddParam("%%TEMP_VARIABLES%%",tempVarStr);
  rs->AddParam("%%TABLENAME%%",tableNameStr);
  rs->AddParam("%%COMPARISIONSTR%%",comparisonStr);
  rs->AddParam("%%HISTORYTABLE%%",bitemporalTableName);
  rs->AddParam("%%KEY_COMPARISION%%",KeyComparisonStr);
  rs->AddParam("%%COMMA_PARAMS%%",commaParams);
  rs->AddParam("%%COMMA_TEMPVARS%%",commaTempVars);
  rs->AddParam("%%COMMA_INPUT_PARAMS%%",commaInputParams);
  rs->AddParam(" %%NON_KEY_COMPARISION%%",nonKeyNegativeComparisionStr);
  rs->AddParam("%%SUBSCRIPTION%%",subscription);

  if(bOracle) {
    if(bSingleRecord) {
      rs->AddParam("%%ENDDATE_PARAM%%","realenddate");
    }
    else {
      rs->AddParam("%%ENDDATE_PARAM%%","dbo.subtractsecond(realenddate)");
    }
  }
  else {
    if(bSingleRecord) {
      rs->AddParam("%%ENDDATE_PARAM%%","@realenddate");
    }
    else {
      rs->AddParam("%%ENDDATE_PARAM%%","dbo.subtractsecond(@realenddate)");
    }
  }
  
  if(!bOracle) {
    _bstr_t tempvarAssignmentStr;
    SQLServerTempVarAssignment(params,tempvarAssignmentStr);
    rs->AddParam("%%COMMA_TEMPVARS_ASSIGNMENT_SQLSERVER%%	",tempvarAssignmentStr);

    rs->AddParam("%%PRIMARY_KEYS_NOT_NULL%%",primaryKeysNotNullStr); // CR 14491 - Primary keys can not be null only on SQL Server
  }
  
  // do this statement first to make sure the stored procedure is valid
	// the query log has it anyway. no need to log it twice

  if(!bOracle) {
    ROWSETLib::IMTSQLRowsetPtr dropRS(__uuidof(ROWSETLib::MTSQLRowset));
    dropRS->Init("queries\\database");
    dropRS->SetQueryTag("__SILENT_DROP_PROCEDURE__");
    dropRS->AddParam("%%PROC_NAME%%",sprocName);
    // ignore the results; this may fail
    dropRS->raw_Execute();

  }
  
  rs->Execute();
  

}

void MTBitemporalSprocsHook::BuildNonKeyNegativeComparisionStr(vector<ParamStruct>& params,_bstr_t& outputStr)
{
  vector<ParamStruct>::iterator it = params.begin();
  while(it != params.end()) {
    ParamStruct& refParam = (*it);
    if(refParam.bNonKeyComparison && !refParam.bKey) {
      outputStr += " ";
      outputStr += refParam.paramName;
      outputStr += " <> ";
      outputStr += refParam.genName;
    }
    it++;
  }
  if(outputStr.length() != 0) {
    outputStr = " AND " + outputStr;
  }
}


void MTBitemporalSprocsHook::SQLServerTempVarAssignment(vector<ParamStruct>& params,_bstr_t& outputStr)
{
 vector<ParamStruct>::iterator it = params.begin();
  while(it != params.end()) {
    ParamStruct& refParam = (*it);
    outputStr += refParam.tempVarName;
    outputStr += " = " + refParam.paramName;
    it++;
    if(it != params.end()) {
      outputStr += ",\n";
    }
    else {
      outputStr += "\n";
    }
  }
}


void MTBitemporalSprocsHook::BuildCommaParams(vector<ParamStruct>& params,
                                              _bstr_t& commaInputParamsStr,
                                              _bstr_t& paramStr,
                                              _bstr_t& tempvarStr)
{
 vector<ParamStruct>::iterator it = params.begin();
  while(it != params.end()) {
    ParamStruct& refParam = (*it);
    paramStr += refParam.paramName;
    tempvarStr += refParam.tempVarName;
    commaInputParamsStr += refParam.genName;
    it++;
    if(it != params.end()) {
      paramStr += ",";
      tempvarStr += ",";
      commaInputParamsStr += ",";
    }
  }
}
 

void MTBitemporalSprocsHook::BuildTempVarStr(vector<ParamStruct>& params,_bstr_t& outputStr)
{
  vector<ParamStruct>::iterator it = params.begin();
  while(it != params.end()) {
    ParamStruct& refParam = (*it);
    if(bOracle) {
      outputStr += refParam.tempVarName;
      outputStr += " ";
      if(refParam.type == _bstr_t("int32")) {
        outputStr += "integer;";
      }
      else if(refParam.type == _bstr_t("date")) {
        outputStr += "date;";
      }
      else if(refParam.type == _bstr_t("binary")) {
        outputStr += "raw(" + refParam.length + ");";
      }
      else if(refParam.type == _bstr_t("char")) {
        outputStr += "varchar2(" + refParam.length + ");";
      }
    }
    else {
      outputStr += "declare " + refParam.tempVarName;
      outputStr += " ";
      if(refParam.type == _bstr_t("int32")) {
        outputStr += "int";
      }
      else if(refParam.type == _bstr_t("date")) {
        outputStr += "datetime";
      }
      else if(refParam.type == _bstr_t("binary")) {
        outputStr += "varbinary(" + refParam.length + ")";
      }
      else if(refParam.type == _bstr_t("char")) {
        outputStr += "varchar(" + refParam.length + ")";
      }
    }
    outputStr += "\n";

    it++;
  }
}


void MTBitemporalSprocsHook::BuildKeyComparisonString(vector<ParamStruct>& params,_bstr_t& outputStr)
{
  bool bAndSpecified;
  vector<ParamStruct>::iterator it = params.begin();
  bAndSpecified = false;
  while(it != params.end()) {
    ParamStruct& refParam = (*it);
    if(refParam.bKey) {
      if(refParam.Nullable) {
        outputStr += "((" + refParam.paramName;
        outputStr += " = " + refParam.genName;
        outputStr += ") OR (" + refParam.paramName;
        outputStr += " is NULL AND " + refParam.genName;
        outputStr += " is null))";
      }
      else {
        outputStr += refParam.paramName;
        outputStr += " = ";
        outputStr += refParam.genName;
      }
      it++;
      bAndSpecified = true;
      outputStr += " AND ";
    }
    else {
      it++;
    }
  }
  if(bAndSpecified) {
    wstring temp = outputStr;
    temp.erase(temp.length() - 5,5);
    outputStr = temp.c_str();
  }
}

void MTBitemporalSprocsHook::BuildPrimaryKeysNotNullString(vector<ParamStruct>& params, _bstr_t& outputStr)
{
  //Sample output string:  ((@temp_id_sub is not null) AND (@temp_id_po is not null))
  vector<ParamStruct>::iterator it = params.begin();
  bool isPossibleCompoundKey = false;
  outputStr += "(";

  // find the first key param, and build the not null string
  while(it != params.end())
  {
    ParamStruct& refParam = (*it);
    if(refParam.bKey) 
    {
      if(isPossibleCompoundKey)
      {
        outputStr += " AND ";
      }
      outputStr += "(";
      outputStr += "@temp_" + refParam.paramName;
      outputStr += " is not null";
      outputStr += ")";
      isPossibleCompoundKey = true;
    }
    it++;
  }

  outputStr += ")";
}

void MTBitemporalSprocsHook::BuildSprocParamString(vector<ParamStruct>& params,_bstr_t& outputStr)
{
  vector<ParamStruct>::iterator it = params.begin();
  while(it != params.end()) {
    ParamStruct& refParam = (*it);
    if(bOracle) {
      outputStr += refParam.genName;
      outputStr += " IN ";
      if(refParam.type == _bstr_t("int32")) {
        outputStr += "integer";
      }
      else if(refParam.type == _bstr_t("date")) {
        outputStr += "date";
      }
      else if(refParam.type == _bstr_t("binary")) {
        outputStr += "raw";
      }
      else if(refParam.type == _bstr_t("char")) {
        outputStr += "varchar2";
      }
    }
    else {
      outputStr += refParam.genName;
      outputStr += " ";
      if(refParam.type == _bstr_t("int32")) {
        outputStr += "int";
      }
      else if(refParam.type == _bstr_t("date")) {
        outputStr += "datetime";
      }
      else if(refParam.type == _bstr_t("binary")) {
        outputStr += "varbinary(" + refParam.length + ")";
      }
      else if(refParam.type == _bstr_t("char")) {
        outputStr += "varchar(" + refParam.length + ")";
      }
    }
    it++;
    if(it != params.end()) {
      outputStr += ",\n";
    }
    else {
      outputStr += ",";
    }
  }
}

void MTBitemporalSprocsHook::BuildNonKeyComparisonString(vector<ParamStruct>& params,_bstr_t& outputStr)
{
  vector<ParamStruct>::iterator it = params.begin();
  bool bAndSpecified = false;

  while(it != params.end()) {
    ParamStruct& refParam = (*it);
    if(refParam.bNonKeyComparison) {
      if(refParam.Nullable) {
        outputStr += "((" + refParam.paramName;
        outputStr += " = " + refParam.genName;
        outputStr += ") OR (" + refParam.paramName;
        outputStr += " is NULL AND " + refParam.genName;
        outputStr += " is null))";
      }
      else {
        outputStr += refParam.paramName;
        outputStr += " = ";
        outputStr += refParam.genName;
      }
      it++;
      bAndSpecified = true;
      outputStr += " AND ";
    }
    else {
      it++;
    }
  }
  if(bAndSpecified) {
    wstring temp = outputStr;
    temp.erase(temp.length() - 5,5);
    outputStr = temp.c_str();
  }
}


