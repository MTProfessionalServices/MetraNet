/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"

#include <SetIterate.h>
#include <DynamicTable.h>
#include "AccountMetaData.h"
#include <autocritical.h>
#include <mtprogids.h>
#include "DataAccessDefs.h"

#import <RCD.tlb>
#import <MetraTech.Accounts.Type.tlb> inject_statement("using namespace mscorlib;")
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

//TODO move to common place!!
static MTPRODUCTCATALOGLib::PropValType
PropertyTypeToPropValType(CMSIXProperties::PropertyType aType)
{
	switch(aType)
	{
	case CMSIXProperties::TYPE_STRING:
    return MTPRODUCTCATALOGLib::PROP_TYPE_ASCII_STRING;

	case CMSIXProperties::TYPE_WIDESTRING:
		return MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING;

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

	default:
		ASSERT(0);
		return MTPRODUCTCATALOGLib::PROP_TYPE_UNKNOWN;
	}
}

//Static Members
NTThreadLock CAccountMetaData::mAccessLock;
CAccountMetaData* CAccountMetaData::mpInstance = NULL;

///////////////////////////////////////////////////////////////////////
// CAccountMetaData 
///////////////////////////////////////////////////////////////////////
CAccountMetaData::CAccountMetaData()
  : CSQLFinderMetaData(L"acc")
{
  LoadMetaData();
}
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
CAccountMetaData::~CAccountMetaData()
{
}
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
void CAccountMetaData::LoadMetaData()
{
  // Add the hard-coded properties
  AddProperties();

  // Add the hard-coded tables
  AddTables();
  LoadAccountExtensions();
}
////////////////////////////////////////////////////////////////////////////
//the only way to construct the CAccountMetaData
CAccountMetaData* CAccountMetaData::GetInstance()
{
  if (mpInstance == NULL) 
  {
    // only enter the critical section if not yet created
    // (to avoid needless locking)
    AutoCriticalSection lockCriticalSection(&mAccessLock);

    if (mpInstance == NULL)
    { 
      mpInstance = new CAccountMetaData;
    }
  }

  return mpInstance;
}
////////////////////////////////////////////////////////////////////////////
void CAccountMetaData::DeleteInstance()
{
  delete mpInstance;
  mpInstance = NULL;
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddProperties()                                         //
//  Description : Add the properties for the account finder.              //
//  Inputs      : none                                                    //
//  Outputs     : none                                                    //
//////////////////////////////////////////////////////////////////////////// 
void CAccountMetaData::AddProperties()
{
  AddProperty(L"_AccountID",           L"acc",            L"id_acc",       MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"AccountTypeID",        L"acc",            L"id_type",       MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"AccountType",          L"acctype",        L"name",     MTPRODUCTCATALOGLib::PROP_TYPE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"username",             L"accmap",         L"nm_login",     MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"name_space",           L"accmap",         L"nm_space",     MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");
  // FEAT-752 - Support active directory 
  AddProperty(L"AuthenticationType",   L"credentials",    L"authentication_type", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"_NameSpaceType",       L"ns",             L"tx_typ_space", MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");
  
  //internal use only, for authorization
  AddProperty(L"_CorporateAccountID",  L"anccorpfilter",  L"id_ancestor",  MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");

  AddProperty(L"AccountStatus",        L"accstate",       L"status",       MTPRODUCTCATALOGLib::PROP_TYPE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"accountstartdate",     L"accstate",       L"vt_start",     MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"accountenddate",       L"accstate",       L"vt_end",       MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, L"[CORE_ACCOUNT_PROPERTIES]");
  
  AddProperty(L"PayerID",              L"accpr",          L"id_payer",     MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"Payment_StartDate",    L"accpr",          L"vt_start",     MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"Payment_EndDate",      L"accpr",          L"vt_end",       MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"PayerAccount",         L"accprmap",       L"nm_login",     MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"PayerAccountNS",       L"accprmap",       L"nm_space",     MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"_PayerAccountNSType",  L"prns",           L"tx_typ_space", MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");
  
  AddProperty(L"StartMonth",           L"uc",             L"start_month",         MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"StartDay",             L"uc",             L"start_day",           MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"StartYear",            L"uc",             L"start_year",          MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"FirstDayOfMonth",      L"uc",             L"first_day_of_month",  MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"SecondDayOfMonth",     L"uc",             L"second_day_of_month", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"DayOfMonth",           L"uc",             L"day_of_month",        MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"DayOfWeek",            L"uc",             L"day_of_week",         MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");

  AddProperty(L"AncestorAccountID",    L"ancparent",      L"id_ancestor",    MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");     //parent
  AddProperty(L"AncestorAccount",      L"ancparentmap",   L"nm_login",       MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");      //parent
  AddProperty(L"AncestorAccountNS",    L"ancparentmap",   L"nm_space",       MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");      //parent
  AddProperty(L"HasChildren",          L"ancparent",      L"b_children",     MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"Hierarchy_StartDate",  L"ancparent",      L"vt_start",       MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, L"[CORE_ACCOUNT_PROPERTIES]");    //date under parent 
  AddProperty(L"Hierarchy_EndDate",    L"ancparent",      L"vt_end",         MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, L"[CORE_ACCOUNT_PROPERTIES]");    //date under parent
  AddProperty(L"_HierarchyAccountID",  L"ancfilter",      L"id_ancestor",    MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");     //any ancestor (not just parent), filter only
  AddProperty(L"_HierarchyAccount",    L"ancfiltermap",   L"nm_login",       MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");      //any ancestor (not just parent), filter only
  AddProperty(L"_HierarchyAccountNS",  L"ancfiltermap",   L"nm_space",       MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");      //any ancestor (not just parent), filter only

  AddProperty(L"_CorporateAccountID",  L"anccorpfilter",  L"id_ancestor",    MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, L"[CORE_ACCOUNT_PROPERTIES]");     //internal use only, for authorization

  AddProperty(L"Invoice",  L"inv",  L"invoice_string", MTPRODUCTCATALOGLib::PROP_TYPE_UNICODE_STRING, L"[CORE_ACCOUNT_PROPERTIES]");  //only for filter

  //BP TODO: Seems like the number, names and types of properties in t_account_type are still early in the works
  //After main Account Types implementation is done we need to come back here and touch them up
  AddProperty(L"CanSubscribe",        L"acctype",        L"b_CanSubscribe",       MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN,  L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"CanBePayer",        L"acctype",        L"b_CanBePayer",       MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN,  L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"CanHaveSyntheticRoot",        L"acctype",        L"b_CanHaveSyntheticRoot",       MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN,  L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"CanParticipateInGSub",        L"acctype",        L"b_CanParticipateInGSub",       MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN,  L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"IsVisibleInHierarchy",        L"acctype",        L"b_IsVisibleInHierarchy",       MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN,  L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"CanHaveTemplates",        L"acctype",        L"b_CanHaveTemplates",       MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN,  L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"IsCorporate",        L"acctype",        L"b_IsCorporate",       MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN,  L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"AccountTypeName",        L"acctype",        L"name",       MTPRODUCTCATALOGLib::PROP_TYPE_STRING,  L"[CORE_ACCOUNT_PROPERTIES]");

  AddProperty(L"BillingGroupID",        L"billgroupmember",        L"id_billgroup",       MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER,  L"[CORE_ACCOUNT_PROPERTIES]");
  AddProperty(L"PricelistName",        L"plnamebp",        L"nm_name",       MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER,  L"[CORE_ACCOUNT_PROPERTIES]");
}
////////////////////////////////////////////////////////////////////////////
//  Function    : AddTables()                                             //
//  Description : Add the tables for the account finder.                  //
//  Inputs      : none                                                    //
//  Outputs     : none                                                    //
//////////////////////////////////////////////////////////////////////////// 
void CAccountMetaData::AddTables()
{
  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
  rowset->Init(ACC_HIERARCHIES_QUERIES);

  _bstr_t dbType = rowset->GetDBType();
  bool isOracle = (mtwcscasecmp(dbType, ORACLE_DATABASE_TYPE) == 0);

  AddTable(L"t_account",             L"acc");
  AddTable(L"t_account_mapper",      L"accmap",        L"id_acc = acc.id_acc", CSQLFinderMetaDataTable::NO_FLAGS, L"", L"");
  AddTable(L"t_vw_user_credentials", L"credentials",   L"nm_login = accmap.nm_login AND credentials.nm_space = accmap.nm_space", CSQLFinderMetaDataTable::OUTER_JOIN, L"accmap");
  AddTable(L"t_namespace",           L"ns",            L"nm_space = accmap.nm_space", CSQLFinderMetaDataTable::NO_FLAGS, L"accmap");        //depends on accmap
  AddTable(L"t_account_state",       L"accstate",      L"id_acc = acc.id_acc",                   CSQLFinderMetaDataTable::DATE_JOIN);
  AddTable(L"t_payment_redirection", L"accpr",         L"id_payee = acc.id_acc",                 CSQLFinderMetaDataTable::DATE_JOIN);
  AddTable(L"t_account_mapper",      L"accprmap",      L"id_acc = accpr.id_payer",  CSQLFinderMetaDataTable::NO_FLAGS, L"accpr", L""); //depends on accpr
  AddTable(L"t_namespace",           L"prns",          L"nm_space = accprmap.nm_space and prns.tx_typ_space = ns.tx_typ_space");
  AddTable(L"t_acc_usage_cycle",     L"accuc",         L"id_acc = acc.id_acc", CSQLFinderMetaDataTable::OUTER_JOIN);
  AddTable(L"t_usage_cycle",         L"uc",            L"id_usage_cycle = accuc.id_usage_cycle", CSQLFinderMetaDataTable::OUTER_JOIN, L"accuc"); //depends on accuc
  AddTable(L"t_account_ancestor",    L"ancparent",     L"id_descendent = acc.id_acc and ancparent.num_generations = 1", CSQLFinderMetaDataTable::OUTER_JOIN | CSQLFinderMetaDataTable::DATE_JOIN);
  AddTable(L"t_account_mapper",      L"ancparentmap",  L"id_acc = ancparent.id_ancestor and ancparentmap.nm_space = accmap.nm_space", CSQLFinderMetaDataTable::OUTER_JOIN | CSQLFinderMetaDataTable::NO_FLAGS,  L"ancparent,accmap", L""); //depends on ancparent,accmap
  AddTable(L"t_account_ancestor",    L"ancfilter",     L"id_descendent = acc.id_acc",            CSQLFinderMetaDataTable::DATE_JOIN | CSQLFinderMetaDataTable::FILTER_ONLY);
  AddTable(L"t_account_mapper",      L"ancfiltermap",  L"id_acc = ancfilter.id_ancestor",        CSQLFinderMetaDataTable::FILTER_ONLY,              L"ancfilter", L""); //depends on ancfilter
  AddTable(L"t_account_ancestor",    L"anccorpfilter", L"id_descendent = acc.id_acc",            CSQLFinderMetaDataTable::DATE_JOIN | CSQLFinderMetaDataTable::FILTER_ONLY,    L"plname");
  AddTable(L"t_invoice",             L"inv",           L"id_acc = acc.id_acc",                   CSQLFinderMetaDataTable::EXISTS_JOIN | CSQLFinderMetaDataTable::FILTER_ONLY);
  AddTable(L"t_account_type",        L"acctype",       L"id_type = acc.id_type");
  AddTable(L"t_billgroup_member",    L"billgroupmember", L"id_acc = acc.id_acc", CSQLFinderMetaDataTable::FILTER_ONLY);
  AddTable(L"t_av_internal",        L"plname",       L"id_acc = acc.id_acc");
  AddTable(L"t_base_props",    L"plnamebp", L"id_prop = plname.c_pricelist", CSQLFinderMetaDataTable::OUTER_JOIN, L"plname");
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// load meta data for account extensions (t_av_internal, t_av_contact, t_av_...)
// throws errors if fatal, but if loading one extension fails, others will still be tried
void CAccountMetaData::LoadAccountExtensions()
{
  MTConfigLib::IMTConfigPtr aConfig(MTPROGID_CONFIG);

  //initialize msixdefCollection to use when loading up account view config files
  MSIXDefCollection msixdefCollection;
  if (!msixdefCollection.Initialize(L"AccountView"))
    MT_THROW_COM_ERROR("Error loading account views");
 
  //load mappings of account types to account views
  //bp
  MetraTech_Accounts_Type::IAccountTypeReaderPtr atreader
    (__uuidof(MetraTech_Accounts_Type::AccountTypeReader));
  //TODO: it's OK if this is only used from MAM while finding accounts.
  //But we are likely to run into DTC transaction blocking issues if ever run from pipeline
  //If this becomes an issue, then we need to either pass transaction here and use BYOT or
  //read from files.
  ROWSETLib::IMTSQLRowsetPtr rs = atreader->GetAccountTypeViewMappingsAsRowset();
  set<wstring> temp;
  set<wstring>::iterator temp_it;
  map<wstring, vector<wstring> >::iterator mapping_it;
  while(!bool(rs->RowsetEOF))
  {
    wstring at = (wchar_t*)(_bstr_t)rs->GetValue("name");
    wstring av = (wchar_t*)(_bstr_t)rs->GetValue("TableName");
    temp_it = temp.find(av);
    if(temp_it == temp.end())
    {
      temp.insert(av);
      mAccountViewList.push_back(av);
    }
    mAccountTypeMappings[at].push_back(av);
    rs->MoveNext();
  }
  
  // find AccountAdapters.xml
  RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
  aRCD->Init();
  RCDLib::IMTRcdFileListPtr aFileList = aRCD->RunQuery("config\\AccountType\\*.xml", VARIANT_TRUE);

  if(aFileList->GetCount() == 0)
  {
    MT_THROW_COM_ERROR( "CAccountMetaData::LoadAccountExtensions: can not find any configuration files");
  }
  
  //interate over all AccountAdapters.xml
  SetIterator<RCDLib::IMTRcdFileListPtr, CComVariant> it;
  if(FAILED(it.Init(aFileList)))
    MT_THROW_COM_ERROR(E_FAIL);

  //keep track of account views - don't load them more than once
  set<_bstr_t> loadedaccviews;
  //BP TODO:
  //If we change account type implementation to NOT have t_av_internal mappings stored in account type configuration files (like we decided in the meeting on 10-29)
  //then we need to change the code below to load t_av_internal separately.
  while(true) 
  {
    CComVariant var = it.GetNext();

    _bstr_t afile = var;
    if((afile.length() == 0) || (var.vt != VT_BSTR)) 
    {
      //done
      break;
    }

    //iterate over all adapters in AccountAdapters.xml file
    VARIANT_BOOL aCheckSumMatch;
    MTConfigLib::IMTConfigPropSetPtr aPropSet = aConfig->ReadConfiguration(afile,&aCheckSumMatch);
    MTConfigLib::IMTConfigPropSetPtr accounttypePropSet = aPropSet->NextSetWithName("AccountType");
    if(accounttypePropSet == NULL)
      MT_THROW_COM_ERROR("File '%s' located in AccountType folder is not an account type file", (char*)afile);
    MTConfigLib::IMTConfigPropSetPtr accountviewPropSet = accounttypePropSet->NextSetWithName("AccountViews");
    if(accountviewPropSet == NULL)
      MT_THROW_COM_ERROR("File '%s' located in AccountType folder is not an account type file", (char*)afile);
    MTConfigLib::IMTConfigPropSetPtr aAdapterSet = accountviewPropSet->NextSetWithName("AdapterSet");
    while (aAdapterSet != NULL)
    {
      _bstr_t configFile = aAdapterSet->NextStringWithName("configfile");

      if(loadedaccviews.find(configFile) != loadedaccviews.end())
      {
        aAdapterSet = accountviewPropSet->NextSetWithName("AdapterSet");
        continue;
      }
      else
        loadedaccviews.insert(configFile);

       
      // if adapter has has a account view config file, load it's meta data
      if(configFile.length() != 0)
      { 
        if (!LoadAccountExtension(msixdefCollection, configFile))
        {
          //log error on failure but try next extension
          _bstr_t msg = "Error loading account extension: " + configFile;
          LogYAACError(msg, LOG_ERROR);
        }
      }
      aAdapterSet = accountviewPropSet->NextSetWithName("AdapterSet");
    }
  }
}
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// load meta data for one account extensions
// returns true if extension could be loaded without errors
bool CAccountMetaData::LoadAccountExtension(MSIXDefCollection& coll, const _bstr_t& configFile)
{
  bool retVal = true;
  
  _bstr_t msg = "Loading account extension: " + configFile;
  LogYAACError(msg, LOG_DEBUG);

  // look for file and load definition
  CMSIXDefinition * accDef;
  if (!coll.FindDefinition((const wchar_t*)configFile, accDef)
      || accDef == NULL)
  { 
    LogYAACError("File not found", LOG_ERROR);
    return false;
  }
       
  // get table info
	accDef->CalculateTableName(L"t_av_");
  _bstr_t tableName = accDef->GetTableName().c_str();

  // add table meta data, 
  // where table name and alias are the same and always outer join on id_acc
  AddTable(tableName, new CSQLFinderMetaDataTable((const wchar_t*)tableName,
                                                  (const wchar_t*)tableName,
                                                  L"id_acc = acc.id_acc",
                                                  CSQLFinderMetaDataTable::OUTER_JOIN));

  MSIXPropertiesList properties = accDef->GetMSIXPropertiesList();

	MSIXPropertiesList::iterator it;
	for (it = properties.begin(); it != properties.end(); ++it)
	{
		CMSIXProperties * prop = *it;
    
    // get msix properties
    _bstr_t propName = prop->GetDN().c_str();
    _bstr_t columnName = prop->GetColumnName().c_str();
    MTPRODUCTCATALOGLib::PropValType type = PropertyTypeToPropValType(prop->GetPropertyType());
    _bstr_t enumSpace = prop->GetEnumNamespace().c_str();
    _bstr_t enumType = prop->GetEnumEnumeration().c_str();

    // check for duplicates
    if (GetPropMetaDataSet()->Exist(propName))
    {
      MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr existingPropMeta;
      existingPropMeta = GetPropMetaDataSet()->Item[propName];

      _bstr_t msg = "Warning: duplicate property '" + propName + "'. Property already exists in ";
      msg += existingPropMeta->DBTableName;
      msg += "and will be ignored for " + tableName;
      LogYAACError(msg, LOG_WARNING);

      retVal = false;

      //ignore this property but try to load others
      continue;
    }

    // add property meta data
    MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta;
    propMeta = GetPropMetaDataSet()->CreateMetaData(propName);
    propMeta->DBTableName = tableName;
    propMeta->DBColumnName = columnName;
    propMeta->PropertyGroup = "[ACCOUNT_EXTENSION_PROPERTIES]";
    propMeta->DataType = type;
    propMeta->EnumSpace = enumSpace;
    propMeta->EnumType = enumType;
  }

  return retVal;
}

MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr CAccountMetaData::GetPropertyMetaDataSet(const wstring& aPropertyGroup)
{
  if(aPropertyGroup == L"")
  {
    //By default, return ALL ACCOUNT PROPERTIES
    MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr propMetaDataSet;
    long i = 0;
    propMetaDataSet.CreateInstance(MTPROGID_MTPROPERTY_METADATASET);

    //Get the properties that match
    for(i = 1; i <= GetPropMetaDataSet()->Count; i++ )
    {
      MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta = GetPropMetaDataSet()->Item[i];

      if((_wcsicmp((wchar_t *)propMeta->PropertyGroup, (wchar_t *)(L"[CORE_ACCOUNT_PROPERTIES]")) == 0) ||
         (_wcsicmp((wchar_t *)propMeta->PropertyGroup, (wchar_t *)(L"[ACCOUNT_EXTENSION_PROPERTIES]")) == 0))
      {
        MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr newPropMeta = propMetaDataSet->CreateMetaData(propMeta->Name);

        newPropMeta->DBTableName = propMeta->DBTableName;
        newPropMeta->DBColumnName = propMeta->DBColumnName;
        newPropMeta->PropertyGroup = propMeta->PropertyGroup;
        newPropMeta->DataType = propMeta->DataType;
        newPropMeta->EnumSpace = propMeta->EnumSpace;
        newPropMeta->EnumType = propMeta->EnumType;
      }
    }
    return propMetaDataSet;

  //Property Group Specified
  } else {
    
    //Check if all properties requested
    if(_wcsicmp((wchar_t *)aPropertyGroup.c_str(), (wchar_t *)(L"[ALL_PROPERTIES]")) == 0)
      return GetPropMetaDataSet();
    else
    {

      MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr propMetaDataSet;
      long i = 0;
      propMetaDataSet.CreateInstance(MTPROGID_MTPROPERTY_METADATASET);

      //Get the properties that match
      for(i = 1; i <= GetPropMetaDataSet()->Count; i++ )
      {
        MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta = GetPropMetaDataSet()->Item[i];
        
        //Fix for compare problem.
        _bstr_t strGroup = aPropertyGroup.c_str();

        if(_wcsicmp((wchar_t *)propMeta->PropertyGroup, (wchar_t *)strGroup) == 0)
        {
          MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr newPropMeta = propMetaDataSet->CreateMetaData(propMeta->Name);

          newPropMeta->DBTableName = propMeta->DBTableName;
          newPropMeta->DBColumnName = propMeta->DBColumnName;
          newPropMeta->PropertyGroup = propMeta->PropertyGroup;
          newPropMeta->DataType = propMeta->DataType;
          newPropMeta->EnumSpace = propMeta->EnumSpace;
          newPropMeta->EnumType = propMeta->EnumType;
        }
      }

      return propMetaDataSet;
    }
  }
}


MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr CAccountMetaData::GetPropertyMetaData(const wstring& aPropertyName,
                                                                                  CSQLFinderMetaDataTable** apTable)
{
  MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta = GetPropMetaDataSet()->GetItem(aPropertyName.c_str());

  //if table provided, look up table
  if (apTable)
  {
    (*apTable) = GetTable((const wchar_t*)propMeta->DBTableName);
  }

  return propMeta;
}

wstring CAccountMetaData::GetMAMStateFilterClause()
{
  wstring filterClause;
  
  //get the state of the states
  MTACCOUNTSTATESLib::IMTAccountStateManagerPtr stateMgr("MTAccountStates.MTAccountStateManager");
  
  //for all states
  static const wchar_t* accountStates[] = { PENDING_ACTIVE_APPROVAL,
                                            ACTIVE,
                                            SUSPENDED,
                                            PENDING_FINAL_BILL,
                                            CLOSED,
                                            ARCHIVED
                                          };

  for (int i = 0; i < sizeof(accountStates)/sizeof(accountStates[0]); i++)
  { 
    const wchar_t* stateString = accountStates[i];

    MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr stateObj;
    stateMgr->Initialize(-99, stateString);
    stateObj = stateMgr->GetStateObject();
    
    stateObj->Initialize();

    //if state can be visible in mam, add it to clause
    if( stateObj->CanBeVisibleInMAM() )
    { if (!filterClause.empty())
        filterClause += L", ";
      
      filterClause += L"\'";
      filterClause += stateString;
      filterClause += L"\'";
    }
  }
  return filterClause;
}


const vector<wstring>& CAccountMetaData::GetAccountViewTablesForType(const wstring& aTypeName) const
{
  map<wstring, vector<wstring> >::const_iterator it = mAccountTypeMappings.find(aTypeName);
  return it->second;
}
const vector<wstring>& CAccountMetaData::GetCommonAccountViewTables(const wstring& aAccountViewTable)
{
  map<wstring, vector<wstring> >::const_iterator it = mCommonAccountViewTables.find(aAccountViewTable);
  if(it == mCommonAccountViewTables.end())
  {
    MetraTech_Accounts_Type::IAccountTypeReaderPtr atreader
      (__uuidof(MetraTech_Accounts_Type::AccountTypeReader));
    //TODO: it's OK if this is only used from MAM while finding accounts.
    //But we are likely to run into DTC transaction blocking issues if ever run from pipeline
    //If this becomes an issue, then we need to either pass transaction here and use BYOT or
    //read from files.
    ROWSETLib::IMTSQLRowsetPtr rs = atreader->GetCommonAccountViewTables(aAccountViewTable.c_str());
    AutoCriticalSection lockCriticalSection(&mAccessLock);
    while(!bool(rs->RowsetEOF))
    {
      wstring av = (wchar_t*)(_bstr_t)rs->GetValue("TableName");
      wstring key = aAccountViewTable;
      mCommonAccountViewTables[key].push_back(av);
      rs->MoveNext();
    }
  }
  return mCommonAccountViewTables[aAccountViewTable];
}

const map<wstring, vector<wstring> >& CAccountMetaData::GetAccountTypeMappings() const
{
  return mAccountTypeMappings;
}

const vector<wstring>& CAccountMetaData::GetAllAccountViewTables() const
{
  return mAccountViewList;
}

