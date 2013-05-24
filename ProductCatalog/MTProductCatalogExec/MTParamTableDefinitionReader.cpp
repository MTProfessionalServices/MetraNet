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

#include <metra.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalogExec.h"
#include "MTParamTableDefinitionReader.h"
#include <mtautocontext.h>
#include <ParamTable.h>
#include <mtglobal_msg.h>
#include <DefaultToVariant.h>

using MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr;
using MTPRODUCTCATALOGLib::IMTConditionMetaDataPtr;
using MTPRODUCTCATALOGLib::IMTActionMetaDataPtr;

#define MTPROGID_PARAM_TABLE_DEFINITION L"MetraTech.MTParamTableDefinition.1"
#define MTPROGID_CONDITION_METADATA L"MetraTech.MTConditionMetaData.1"
#define MTPROGID_ACTION_METADATA L"MetraTech.MTActionMetaData.1"

/////////////////////////////////////////////////////////////////////////////
// CMTParamTableDefinitionReader

STDMETHODIMP CMTParamTableDefinitionReader::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTParamTableDefinitionReader
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

HRESULT CMTParamTableDefinitionReader::Activate()
{
  HRESULT hr = GetObjectContext(&mpObjectContext);
  if (SUCCEEDED(hr))
    return S_OK;
  return hr;
} 

BOOL CMTParamTableDefinitionReader::CanBePooled()
{
  return FALSE;
} 

void CMTParamTableDefinitionReader::Deactivate()
{
  mpObjectContext.Release();
} 

#define FIND_PARAM_TABLE_BY_NAME L"__FIND_PARAM_TABLE_BY_NAME__"
#define FIND_PARAM_TABLE_BY_ID L"__FIND_PARAM_TABLE_BY_ID__"

//if not found returns NULL
STDMETHODIMP CMTParamTableDefinitionReader::FindByName(IMTSessionContext* apCtxt, 
                                                       BSTR name,
                                                       IMTParamTableDefinition **def)
{
  MTAutoContext context(mpObjectContext);

  if (!def)
    return E_POINTER;

  *def = NULL;

  try
  {
    if (!apCtxt)
      return E_POINTER;

    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    ROWSETLib::IMTSQLRowsetPtr rs;
    hr = rs.CreateInstance(MTPROGID_SQLROWSET);
    if (FAILED(hr))
      return hr;

    rs->Init(CONFIG_DIR);
    rs->SetQueryTag(FIND_PARAM_TABLE_BY_NAME);
    rs->AddParam("%%NAME%%", name);
    rs->AddParam(L"%%ID_LANG%%", languageID);
    rs->Execute();

    if (rs->GetRowsetEOF().boolVal == VARIANT_TRUE)
    {
      //not found
      context.Complete();
      *def = NULL;
      return S_FALSE; 
    }

    PopulatePrimaryDataByRowset(apCtxt, rs, def);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTParamTableDefinitionReader::FindByID(IMTSessionContext* apCtxt, long id, IMTParamTableDefinition **table)
{
  MTAutoContext context(mpObjectContext);

  if (!table)
    return E_POINTER;

  *table = NULL;

  try
  {
    if (!apCtxt)
      return E_POINTER;

    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    ROWSETLib::IMTSQLRowsetPtr rs;
    hr = rs.CreateInstance(MTPROGID_SQLROWSET);
    if (FAILED(hr))
      return hr;

    rs->Init(CONFIG_DIR);
    rs->SetQueryTag(FIND_PARAM_TABLE_BY_ID);
    rs->AddParam("%%ID%%", id);
    rs->AddParam(L"%%ID_LANG%%", languageID);

    rs->Execute();

    if (rs->GetRowsetEOF().boolVal == VARIANT_TRUE)
    {
      // TODO:
      ASSERT(0);
      return Error("Parameter table not found");
    }

    PopulatePrimaryDataByRowset(apCtxt, rs, table);
  }
  catch(_com_error& e)
  { return ReturnComError(e); }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTParamTableDefinitionReader::LoadSecondaryData(IMTSessionContext* apCtxt, IMTParamTableDefinition * apParamTblDef)
{
  // read the secondary data from the xml file
  if (PCCache::GetLogger().IsOkToLog(LOG_DEBUG))
  {
    IMTParamTableDefinitionPtr paramTblDef = apParamTblDef;
    PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "Loading secondary data for parameter table: %s",
                                   (char*)paramTblDef->GetName());
  }

  return ReadFromFile(apParamTblDef);
}



//
// private implementation
//
void CMTParamTableDefinitionReader::PopulatePrimaryDataByRowset(IMTSessionContext* apCtxt,
                                                                ROWSETLib::IMTSQLRowsetPtr rowset,
                                                                IMTParamTableDefinition ** apParamTblDef)
{
    // create the object
    IMTParamTableDefinitionPtr paramTable(__uuidof(MTParamTableDefinition));

    //set the session context
    paramTable->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

    // populate the ID
    _variant_t val;
    val = rowset->GetValue("id_paramtable");
    long id = val;
    paramTable->ID = id;

    // ... and the name
    val = rowset->GetValue("nm_name");
    paramTable->Name = MTMiscUtil::GetString(val);

    // ... and the table Name
    val = rowset->GetValue("nm_instance_tablename");
    paramTable->DBTableName = MTMiscUtil::GetString(val);

    // the rest of the data will be loaded on demand by a call to LoadSecondaryData()

    *apParamTblDef = (IMTParamTableDefinition *) paramTable.Detach();
}


BOOL AttributeTrue(const XMLNameValueMapDictionary & arMap, const wchar_t * apName,
                   BOOL aDefault = FALSE)
{
  XMLNameValueMapDictionary::const_iterator findit = arMap.find(apName);

  if (findit == arMap.end())
    // not set at all
    return aDefault;

  const std::wstring & val = findit->second;
  if (val == L"Y" || val == L"y")
    return TRUE;

  // TODO: what if val is not Y/y
  //       throw an exception?
  return FALSE;
}

std::wstring AttributeValue(const XMLNameValueMapDictionary & arMap,
                            const wchar_t * apName)
{
  XMLNameValueMapDictionary::const_iterator findit = arMap.find(apName);

  if (findit == arMap.end())
    // not set at all
    return L"";

  return findit->second;
}

MTPRODUCTCATALOGLib::PropValType
PropertyTypeToPropValType(CMSIXProperties::PropertyType aType)
{
  switch(aType)
  {
  case CMSIXProperties::TYPE_STRING:
  case CMSIXProperties::TYPE_WIDESTRING:
    return MTPRODUCTCATALOGLib::PROP_TYPE_STRING;

  case CMSIXProperties::TYPE_INT32:
    return MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER;

  case CMSIXProperties::TYPE_INT64:
    return MTPRODUCTCATALOGLib::PROP_TYPE_BIGINTEGER;

  case CMSIXProperties::TYPE_TIMESTAMP:
    return MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME;

  case CMSIXProperties::TYPE_FLOAT:
  case CMSIXProperties::TYPE_DOUBLE:
    return MTPRODUCTCATALOGLib::PROP_TYPE_DOUBLE;

  case CMSIXProperties::TYPE_NUMERIC:
  case CMSIXProperties::TYPE_DECIMAL:
    return MTPRODUCTCATALOGLib::PROP_TYPE_DECIMAL;

  case CMSIXProperties::TYPE_ENUM:
    return MTPRODUCTCATALOGLib::PROP_TYPE_ENUM;

  case CMSIXProperties::TYPE_BOOLEAN:
    return MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN;

  case CMSIXProperties::TYPE_TIME:
    return MTPRODUCTCATALOGLib::PROP_TYPE_TIME;

  default:
    // TODO:
    ASSERT(0);
    return MTPRODUCTCATALOGLib::PROP_TYPE_UNKNOWN;
  }
}

// TODO: move this to a more common place
MTOperatorType DBOpToOp(_bstr_t opStr)
{
  MTOperatorType test;
  if (opStr == _bstr_t("<") || opStr == _bstr_t("less_than"))
    test = OPERATOR_TYPE_LESS;
  else if (opStr == _bstr_t("<=") || opStr == _bstr_t("less_equal"))
    test = OPERATOR_TYPE_LESS_EQUAL;
  else if (opStr == _bstr_t("=") || opStr == _bstr_t("equals") || opStr == _bstr_t("equal"))
    test = OPERATOR_TYPE_EQUAL;
  else if (opStr == _bstr_t(">=") || opStr == _bstr_t("greater_equal"))
    test = OPERATOR_TYPE_GREATER_EQUAL;
  else if (opStr == _bstr_t(">") || opStr == _bstr_t("greater_than"))
    test = OPERATOR_TYPE_GREATER;
  else if (opStr == _bstr_t("!=") || opStr == _bstr_t("not_equ"))
    test = OPERATOR_TYPE_NOT_EQUAL;
  else
    test = (MTOperatorType) -1;

  return test;
}

// read from a file and populate the object
// loads all secondary members:
//   - DisplayName
//   - ActionHeader 
//   - ConditionHeader
//   - HelpUrl 
//   - IndexedProperty
//   - Conditions
//   - Actions
HRESULT CMTParamTableDefinitionReader::ReadFromFile(IMTParamTableDefinition *def)
{
  try
  {
    IMTParamTableDefinitionPtr paramTable(def);
    DefaultConversion conversionObj;


    // the name will be passed in as metratech.com/rateconn
    // convert this to metratech.com\rateconn.msixdef
    std::wstring filename(paramTable->GetName());
    filename += L".msixdef";
    std::wstring::size_type where = filename.find(L'/');
    if (where != std::wstring::npos)
      filename.replace(where, 1, L"\\");

    ParamTableCollection tableCollection;
    if (!tableCollection.Init(filename.c_str()))
    {
      const ErrorObject * obj = tableCollection.GetLastError();
      // TODO: log the error
      std::wstring buffer(L"Unable to read parameter table ");
      buffer += filename;
      return Error(buffer.c_str(), IID_IMTParamTableDefinitionReader, obj->GetCode());
    }

    MSIXDefCollection::MSIXDefinitionList & deflist = tableCollection.GetDefList();
    ASSERT(deflist.size() > 0);
    CMSIXDefinition * msixdef = deflist.front();
    ASSERT(msixdef);

    // tableName is now loaded as a primary property from the database
    // no need to set it again
    //    paramTable->PutDBTableName(msixdef->GetTableName().c_str());

    const XMLNameValueMapDictionary * pdefattrs = msixdef->GetAttributes();
    if (pdefattrs)
    {
      const XMLNameValueMapDictionary & defattrs = *pdefattrs;

      // indexed_property="Counter1"
      // name of the indexed property
      std::wstring value = AttributeValue(defattrs, L"indexed_property");
      if (value.length() > 0)
        paramTable->PutIndexedProperty(value.c_str());

      // help_url="http://www.metratech.com"
      value = AttributeValue(defattrs, L"help_url");
      if (value.length() > 0)
        paramTable->PutHelpURL(value.c_str());

      // condition_header="Conditions"
      value = AttributeValue(defattrs, L"condition_header");
      if (value.length() > 0)
        paramTable->PutConditionHeader(value.c_str());

      // action_header="Actions"
      value = AttributeValue(defattrs, L"action_header");
      if (value.length() > 0)
        paramTable->PutActionHeader(value.c_str());

      // display_name="Rate connection"
      value = AttributeValue(defattrs, L"display_name");
      if (value.length() > 0)
        paramTable->PutDisplayName(value.c_str());
    }

    MSIXPropertiesList props = msixdef->GetMSIXPropertiesList();

    MSIXPropertiesList::iterator itr;
    for (itr = props.begin(); itr != props.end(); ++itr)
    {
      CMSIXProperties * prop = *itr;

      // condition or action?
      const XMLNameValueMapDictionary * pattributes = prop->GetAttributes();
      if (!pattributes)
      {
        // TODO:
        ASSERT(0);
        return Error("property not a condition or action");
      }

      const XMLNameValueMapDictionary & attributes = *pattributes;

      if (AttributeTrue(attributes, L"condition"))
      {
        IMTConditionMetaDataPtr condition = paramTable->AddConditionMetaData();
        _bstr_t propName = prop->GetDN().c_str();
        condition->PutPropertyName(propName);
        condition->PutColumnName(prop->GetColumnName().c_str());

        MTPRODUCTCATALOGLib::PropValType type =
          PropertyTypeToPropValType(prop->GetPropertyType());

        if (type == MTPRODUCTCATALOGLib::PROP_TYPE_UNKNOWN)
        {
          ASSERT(0);
          return Error("unknown property type");
        }

        condition->PutDataType(type);
        if (type == MTPRODUCTCATALOGLib::PROP_TYPE_ENUM)
        {
          condition->PutEnumType(prop->GetEnumEnumeration().c_str());
          condition->PutEnumSpace(prop->GetEnumNamespace().c_str());
        }

        XMLNameValueMapDictionary::const_iterator findit;
        // OperatorPerRule and Operator
        if (AttributeTrue(attributes, L"operator_per_rule"))
          condition->PutOperatorPerRule(VARIANT_TRUE);
        else
        {
          condition->PutOperatorPerRule(VARIANT_FALSE);

          findit = attributes.find(L"column_operator");

          if (findit == attributes.end())
          {
            std::wstring buffer(L"column operator not specified for property ");
            buffer += prop->GetDN();

            return Error(buffer.c_str());
          }

          const std::wstring & val = findit->second;

          MTPRODUCTCATALOGLib::MTOperatorType optype =
            (MTPRODUCTCATALOGLib::MTOperatorType)DBOpToOp(val.c_str());
          if (optype == (MTPRODUCTCATALOGLib::MTOperatorType) -1)
          {
            std::wstring buffer(L"Invalid operator: ");
            buffer += val.c_str();
            return Error(buffer.c_str(), IID_IMTParamTableDefinitionReader,
                         CORE_ERR_CONFIGURATION_PARSE_ERROR);
          }

          condition->PutOperator(optype);
        }

        // DisplayName
        findit = attributes.find(L"display_name");

        if (findit == attributes.end())
          condition->PutDisplayName(condition->GetPropertyName());
        else
        {
          const std::wstring & val = findit->second;
          condition->PutDisplayName(val.c_str());
        }

        // Filterable
        // if not found it will be true
        if (AttributeTrue(attributes, L"filterable", TRUE))
          condition->PutFilterable(VARIANT_TRUE);
        else
          condition->PutFilterable(VARIANT_FALSE);

        // required
        if (prop->GetIsRequired())
          condition->PutRequired(VARIANT_TRUE);
        else
          condition->PutRequired(VARIANT_FALSE);

        // Length
        condition->PutLength(prop->GetLength());

        // Default value
        _bstr_t strDefaultValue = prop->GetDefault().c_str();
        _variant_t vtDefaultValue; // vt_empty
        if(strDefaultValue.length() != 0)
        {
          if(!conversionObj.ConvertDefaultStrToVariant(*prop,vtDefaultValue))
            MT_THROW_COM_ERROR(MTPC_INVALID_PROPERTY_DEFAULT_VALUE, (const char*)propName, (const char*) strDefaultValue);
        }
        condition->PutDefaultValue(vtDefaultValue);

        // TODO: DisplayOperator
      }
      else if (AttributeTrue(attributes, L"operator"))
      {
        //BOOL nextIsOp = TRUE;

      }
      else if (AttributeTrue(attributes, L"action"))
      {
        IMTActionMetaDataPtr action = paramTable->AddActionMetaData();
        _bstr_t propName = prop->GetDN().c_str();
        action->PutPropertyName(propName);
        action->PutColumnName(prop->GetColumnName().c_str());

        MTPRODUCTCATALOGLib::PropValType type =
          PropertyTypeToPropValType(prop->GetPropertyType());

        if (type == MTPRODUCTCATALOGLib::PROP_TYPE_UNKNOWN)
        {
          ASSERT(0);
          return Error("unknown property type");
        }

        action->PutDataType(type);
        if (type == MTPRODUCTCATALOGLib::PROP_TYPE_ENUM)
        {
          action->PutEnumType(prop->GetEnumEnumeration().c_str());
          action->PutEnumSpace(prop->GetEnumNamespace().c_str());
        }

        // DisplayName
        XMLNameValueMapDictionary::const_iterator findit;
        findit = attributes.find(L"display_name");

        if (findit == attributes.end())
          action->PutDisplayName(action->GetPropertyName());
        else
        {
          const std::wstring & val = findit->second;
          action->PutDisplayName(val.c_str());
        }

        // required
        if (prop->GetIsRequired())
          action->PutRequired(VARIANT_TRUE);
        else
          action->PutRequired(VARIANT_FALSE);

        // Length
        action->PutLength(prop->GetLength());

        // Default value
        _bstr_t strDefaultValue = prop->GetDefault().c_str();
        _variant_t vtDefaultValue; // vt_empty
        if(strDefaultValue.length() != 0)
        {
          if(!conversionObj.ConvertDefaultStrToVariant(*prop,vtDefaultValue))
            MT_THROW_COM_ERROR(MTPC_INVALID_PROPERTY_DEFAULT_VALUE, (const char*)propName, (const char*) strDefaultValue);
        }
        action->PutDefaultValue(vtDefaultValue);
      }
      else
      {
        // TODO:
        ASSERT(0);
        return Error("unknown property type");
      }
    }
  }
  catch (_com_error & err)
  {

    return ReturnComError(err);
  }

  return S_OK;
}




STDMETHODIMP CMTParamTableDefinitionReader::FindAsRowset(IMTSessionContext* apCtxt, IMTSQLRowset **apRowset)
{
  ROWSETLib::IMTSQLRowsetPtr rs;
  
  HRESULT hr = rs.CreateInstance(MTPROGID_SQLROWSET);
  _ASSERTE(SUCCEEDED(hr));

  MTAutoContext context(mpObjectContext);

  try
  {
    if (!apCtxt)
      return E_POINTER;

    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    rs->Init(CONFIG_DIR);
    rs->SetQueryTag("__GET_PARAM_TABLES__"); 
    rs->AddParam(L"%%ID_LANG%%", languageID);
    rs->Execute();
    
    (*apRowset) = (IMTSQLRowset*)rs.Detach(); 

  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }

  context.Complete();
  
  return S_OK;
}

