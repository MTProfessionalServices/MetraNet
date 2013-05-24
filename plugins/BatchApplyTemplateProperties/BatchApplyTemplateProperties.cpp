/**************************************************************************
 * @doc BatchApplyTemplateProperties
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
 * Created by: Boris Partensky
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <BatchPlugInSkeleton.h>
#include <mtcomerr.h>

#include <MSIX.h>

#include <NTThreader.h>
#include <NTThreadLock.h>

#include <propids.h>
#include <mtglobal_msg.h>
#include <mtprogids.h>
#include <ConfigDir.h>

#include <OdbcTableWriter.h>

#include <autoptr.h>
#include <errutils.h>
#include <perfshare.h>
#include <perflog.h>

#import <MTEnumConfigLib.tlb> 
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <MTProductCatalogInterfacesLib.tlb> rename( "EOF", "RowsetEOF" )
#import <mscorlib.tlb> rename("_Module", "MSCORLIBModule") rename("ReportEvent", "MSReportEvent")
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib; using ROWSETLib::IMTSQLRowsetPtr; using ROWSETLib::IMTSQLRowset; using MTProductCatalogInterfacesLib::IMTPropertyMetaDataPtr; using MTProductCatalogInterfacesLib::IMTPropertyMetaData;") no_function_mapping
#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )
#import <MetraTech.DataAccess.tlb>

using namespace MetraTech_Pipeline;
//#import <MTConfigLib.tlb>

// generate using uuidgen
CLSID CLSID_BatchApplyTemplateProperties = { /* ccbf090d-7c32-4006-b065-940317c08d43 */
    0x4ea6fe6d,
    0x1e9c,
    0x43ae,
    {0x8a, 0xbb, 0xdd, 0x3c, 0x8e, 0x2b, 0x7d, 0x50}
  };


class TemplateProperty
{
private:
  _bstr_t mName;
  _variant_t mVal;
public:
  TemplateProperty(_bstr_t name, _variant_t val) : mName(name), mVal(val){};
  _bstr_t GetName() {return mName;}
  _variant_t GetValue() {return mVal;}
  
};

class ATL_NO_VTABLE BatchApplyTemplateProperties
	: public MTBatchPipelinePlugIn<BatchApplyTemplateProperties, &CLSID_BatchApplyTemplateProperties>
{
protected:
	virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																			MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																			MTPipelineLib::IMTNameIDPtr aNameID,
																			MTPipelineLib::IMTSystemContextPtr aSysContext);
	virtual HRESULT BatchPlugInInitializeDatabase();
	virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet);
	virtual HRESULT BatchPlugInShutdownDatabase();

private:
  HRESULT ParseConfigFile(MTPipelineLib::IMTConfigPropSetPtr& arPropSet);
  HRESULT GenerateQueries(const char* stageDBName);
	
  MTPipelineLib::IMTLogPtr mLogger;
  MTPipelineLib::IMTLogPtr mPerfLogger;
  MTPipelineLib::IMTNameIDPtr mNameID;
  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
  MTPipelineLib::IMTSystemContextPtr mSysContext;
  QUERYADAPTERLib::IMTQueryAdapterPtr       mQueryAdapter;

  int mArraySize;
  COdbcTableWriter* mTableWriter;
  std::string mCreateTempTableQuery;
  std::string mTempTableName;
  std::string mTmpTableFullName;
  std::string mTagName;
  BOOL mbOKLogDebug;

  long mOperationPropID;
  long mHierarchyStartDatePropID;
  long mAccountStartDatePropID;
  long mAncestorAccountIDPropID;
  long mAncestorNamePropID;
  long mAncestorNameSpacePropID;
  long mOldAncestorAccountIDPropID;

  long mAccountTypePropID;
  long mUserNamePropID;
  long mNameSpacePropID;
  long mServiceDefID;
  MetraTech_Pipeline::IServiceDefinitionPtr mServiceDef;
  MetraTech_Pipeline::IServiceDefinitionCollectionPtr mServiceDefs;

  void DumpTemplatePropRowset(ROWSETLib::IMTSQLRowsetPtr mRowset);

  bool PropertyExists(MTPipelineLib::IMTSessionPtr& session, long ID, IMTPropertyMetaDataPtr& propMeta);
  void BatchApplyTemplateProperties::SetSessionProperty(MTPipelineLib::IMTSessionPtr& session, long ID, IMTPropertyMetaDataPtr& propMeta, _variant_t val);
  void BatchApplyTemplateProperties::MarkSessionsWithMissingPropertiesAsFailed(MTPipelineLib::IMTSessionSetPtr& aSessionSetPtr);
  wstring BatchApplyTemplateProperties::MakeKey(_bstr_t& anc_name, _bstr_t& anc_namespace);
};

PLUGIN_INFO(CLSID_BatchApplyTemplateProperties, BatchApplyTemplateProperties,
						"MetraPipeline.ApplyTemplateProperties.1", "MetraPipeline.ApplyTemplateProperties", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT BatchApplyTemplateProperties::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																										MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																										MTPipelineLib::IMTNameIDPtr aNameID,
																										MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	HRESULT hr;
	mNameID = aNameID;
	mLogger = aLogger;
	mTableWriter = NULL;

	hr = mServiceDefs.CreateInstance(__uuidof(MetraTech_Pipeline::ServiceDefinitionCollection));
	if(FAILED(hr)) return hr;

	mEnumConfig = aSysContext->GetEnumConfig();
	mbOKLogDebug = mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);

	mPerfLogger = MTPipelineLib::IMTLogPtr(MTPROGID_LOG);
	mPerfLogger->Init("logging\\perflog", "[BatchApplyTemplateProperties]");
	mSysContext = aSysContext;

	// reads in the config file
	hr = ParseConfigFile(aPropSet);
	if (FAILED(hr))
		return hr;

	mQueryAdapter.CreateInstance(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
	mQueryAdapter->Init(L"\\Queries\\AccountCreation");

	// create a unique name based on the stage name and plug-in name
	mTagName = GetTagName(aSysContext);
	COdbcConnectionInfo stageDBEntry = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
	string stageDBName = stageDBEntry.GetCatalog();

	hr = GenerateQueries(stageDBName.c_str());
	if (FAILED(hr))
		return hr;
 	
	return S_OK;
}


HRESULT BatchApplyTemplateProperties::ParseConfigFile(MTPipelineLib::IMTConfigPropSetPtr& arPropSet) 
{
	HRESULT hr = S_OK;
	
	try 
  {
    mOperationPropID = mNameID->GetNameID(arPropSet->NextStringWithName("Operation"));
    mAccountStartDatePropID = mNameID->GetNameID(arPropSet->NextStringWithName("AccountStartDate"));
    mHierarchyStartDatePropID = mNameID->GetNameID(arPropSet->NextStringWithName("hierarchy_startdate"));
    mAncestorAccountIDPropID = mNameID->GetNameID(arPropSet->NextStringWithName("AncestorAccountID"));
    mAncestorNamePropID = mNameID->GetNameID(arPropSet->NextStringWithName("AncestorAccount"));
    mAncestorNameSpacePropID = mNameID->GetNameID(arPropSet->NextStringWithName("AncestorAccountNameSpace"));
    
    mOldAncestorAccountIDPropID = mNameID->GetNameID(arPropSet->NextStringWithName("OldAncestorAccountID"));
    mUserNamePropID = mNameID->GetNameID(arPropSet->NextStringWithName("username"));
    mNameSpacePropID = mNameID->GetNameID(arPropSet->NextStringWithName("Namespace"));
    mAccountTypePropID = mNameID->GetNameID(arPropSet->NextStringWithName("AccountTypeID"));

		mArraySize = 1000;

	}
	catch (_com_error& e) 
	{
		char buffer[1024];
		sprintf(buffer, "An exception was thrown while parsing the config file: %x, %s", 
						e.Error(), (const char*) _bstr_t(e.Description()));
		return Error(buffer);
	}

	return S_OK;
}


HRESULT BatchApplyTemplateProperties::GenerateQueries(const char * stageDBName)
{
	// Build the name of our "temporary" table.
	MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));
	mTempTableName = nameHash->GetDBNameHash(("tmp_acctempl_props" + mTagName).c_str());
	string schemaDots = mQueryAdapter->GetSchemaDots();

	mTmpTableFullName = stageDBName + schemaDots + mTempTableName.c_str();

	// the base temp table create and insert queries
	//username and namespace properties are there only for debugging
  
	mQueryAdapter->ClearQuery();
	mQueryAdapter->SetQueryTag("__CREATE_APPLYTEMPLATEPROPS_TEMP_TABLE__");
	mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTempTableName.c_str());
	mCreateTempTableQuery = mQueryAdapter->GetQuery();

	return S_OK;
}

HRESULT BatchApplyTemplateProperties::BatchPlugInInitializeDatabase()
{
  // this is a read-only plugin, so retry is safe
  AllowRetryOnDatabaseFailure(FALSE);
  if (mTableWriter != NULL)
  {
    delete mTableWriter;
    mTableWriter = NULL;
  }

  mTableWriter = new COdbcTableWriter(mLogger, mNameID);
  mTableWriter->InitializeDatabase(
    mTempTableName, 
	mTmpTableFullName,
    mCreateTempTableQuery, 
    mArraySize);

  //set up temp table mappings, start with offset of 2
  //because offset 1 is reserved for requestid and is
  //implicitely set by OdbcTableWriter
  mTableWriter->AddTempTableColumnMapping(2, MTPipelineLib::SESS_PROP_TYPE_ENUM, mOperationPropID, true);
  //set in case of account creation operation
  mTableWriter->AddTempTableColumnMapping(3, MTPipelineLib::SESS_PROP_TYPE_DATE, mAccountStartDatePropID, false);
  //set in case of account update operation
  mTableWriter->AddTempTableColumnMapping(4, MTPipelineLib::SESS_PROP_TYPE_DATE, mHierarchyStartDatePropID, false);
  mTableWriter->AddTempTableColumnMapping(5, MTPipelineLib::SESS_PROP_TYPE_STRING, mAncestorNamePropID, false);
  mTableWriter->AddTempTableColumnMapping(6, MTPipelineLib::SESS_PROP_TYPE_STRING, mAncestorNameSpacePropID, false);
  mTableWriter->AddTempTableColumnMapping(7, MTPipelineLib::SESS_PROP_TYPE_LONG, mAncestorAccountIDPropID, false);
  //only set in case of update, and just for debugging purposes
  mTableWriter->AddTempTableColumnMapping(8, MTPipelineLib::SESS_PROP_TYPE_LONG, mOldAncestorAccountIDPropID, false);
  mTableWriter->AddTempTableColumnMapping(9, MTPipelineLib::SESS_PROP_TYPE_LONG, mAccountTypePropID, true);

  return S_OK;
}


HRESULT BatchApplyTemplateProperties::BatchPlugInShutdownDatabase()
{
	delete mTableWriter;
  mTableWriter = NULL;
	return S_OK;
}


HRESULT BatchApplyTemplateProperties::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
  //get service def id from first session and initialize service definition object
  SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
  HRESULT hr = it.Init(aSet);
  if (FAILED(hr)) return hr;

  bool bSessionsFailed = false;

  MTPipelineLib::IMTSessionPtr session = it.GetNext();
  ASSERT(session != NULL);
  long servicedefid = session->ServiceID;
  if(mServiceDefID != servicedefid)
  {
    mServiceDefID = servicedefid;
    mServiceDef = mServiceDefs->GetServiceDefinition(mNameID->GetName(mServiceDefID));
    ASSERT(mServiceDef != NULL);
  }

  map<long, vector<TemplateProperty> > TemplatePropMap;
  map<std::wstring, vector<TemplateProperty> > TemplatePropMapByNames;
  map<long, vector<TemplateProperty> >::const_iterator mapit;
  map<std::wstring, vector<TemplateProperty> >::const_iterator namemapit;
  vector<TemplateProperty> vTemplatePropsForAccount;
  //pipeline transaction will be extracted in TableWriter and stored until we need to execute SELECT statement
  MarkSessionsWithMissingPropertiesAsFailed(aSet);
  mTableWriter->InitializeFromSessionSet(aSet);

  try
  {
    mTableWriter->InsertIntoTempTable();
  }
  catch (_com_error& err)
  {
    if (err.Error() == PIPE_ERR_SUBSET_OF_BATCH_FAILED)
      bSessionsFailed = true;
    else
      throw;
  }

  ROWSETLib::IMTSQLRowsetPtr mRowset;
  hr = mRowset.CreateInstance(MTPROGID_SQLROWSET);
  if(FAILED(hr)) return hr;
  mRowset->Init("queries\\AccountCreation");

  mRowset->SetQueryTag("__RESOLVE_ACC_TEMPLATE_PROPS__");
  mRowset->AddParam("%%TEMPTABLE%%", mTmpTableFullName.c_str());
  mTableWriter->ExecuteRowsetSelectInDistributedTransaction(mRowset);

  if(mbOKLogDebug)
    DumpTemplatePropRowset(mRowset);

  while(!(bool)mRowset->RowsetEOF) 
  {
    long id_ancestor = (long)mRowset->GetValue("id_ancestor");
    _bstr_t anc_name = "";
    _bstr_t anc_namespace = "";
    _variant_t vAncName = mRowset->GetValue("nm_ancestor_name");
    _variant_t vAncNameSpace = mRowset->GetValue("nm_ancestor_name_space");
    if(V_VT(&vAncName) != VT_NULL)
      anc_name = (_bstr_t)vAncName;
    if(V_VT(&vAncNameSpace) != VT_NULL)
      anc_namespace = (_bstr_t)vAncNameSpace;

    _bstr_t propname = (_bstr_t)mRowset->GetValue("nm_prop");
    _variant_t propval = (_bstr_t)mRowset->GetValue("nm_value");
    wstring sKey = MakeKey(anc_name, anc_namespace);
    if(TemplatePropMap.find(id_ancestor) == TemplatePropMap.end())
    {
      vector<TemplateProperty> vector;
      vector.push_back(TemplateProperty(propname, propval));
      TemplatePropMap[id_ancestor] = vector;
      TemplatePropMapByNames.insert(make_pair( sKey, vector));
    }
    else
    {
      TemplatePropMap[id_ancestor].push_back(TemplateProperty(propname, propval));
      if( (V_VT(&vAncName) != VT_NULL) && (V_VT(&vAncNameSpace) != VT_NULL))
        TemplatePropMapByNames[sKey].push_back(TemplateProperty(propname, propval));
    }
    mRowset->MoveNext();
  }

  
  vector<MTPipelineLib::IMTSessionPtr> sessionVector = mTableWriter->GetSessionVector();

  //iterate over session vector, get account id property
  //if this account has properties in the map, then set them ONLY IF they were not set before

  for(unsigned int i = 0; i<sessionVector.size(); i++)
  {
    //skip sessions that have already been marked as failed by a plugin
    if(session->CompoundMarkedAsFailed == VARIANT_TRUE)
    {
      continue;
    }
    bool bResolveByAncestorID = false;
    long id_ancestor = -1;
    _bstr_t anc_name = "";
    _bstr_t anc_name_space = "";
    MTPipelineLib::IMTSessionPtr session = sessionVector[i];
    if(session->PropertyExists(mAncestorAccountIDPropID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)
    {
      id_ancestor = session->GetLongProperty(mAncestorAccountIDPropID);
      bResolveByAncestorID = true;
      mapit = TemplatePropMap.find(id_ancestor);
    }
    else
    {
      anc_name = session->GetStringProperty(mAncestorNamePropID);
      anc_name_space = session->GetStringProperty(mAncestorNameSpacePropID);
      wstring sKey = MakeKey(anc_name, anc_name_space);
      const wchar_t* key = sKey.c_str();
      namemapit = TemplatePropMapByNames.find(key);
    }
    if(bResolveByAncestorID == true)
    {
      if(mapit == TemplatePropMap.end())
      {
        if(mbOKLogDebug)
        {
          char buf[1024];
          sprintf(buf, "No templates were found to be applied to account with ancestor id <%d> (or template contained no properties)", id_ancestor);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
        }
        continue;
      }
    }
    else
    {
      if(namemapit == TemplatePropMapByNames.end())
      {
        if(mbOKLogDebug)
        {
          char buf[1024];
          sprintf(buf, "No templates were found to be applied to account with ancestor <%s> (or template contained no properties)", (char*)anc_name);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
        }
        continue;
      }

    }
    vector<TemplateProperty> props = bResolveByAncestorID ? (*mapit).second : (*namemapit).second;
    unsigned int size = props.size();
    for(unsigned int j = 0; j< size; j++)
    {
      _bstr_t propname = props[j].GetName();
      _variant_t propvalue = props[j].GetValue();
      IMTPropertyMetaDataPtr propMeta = (IMTPropertyMetaData*)mServiceDef->GetProperty(propname);
      if(propMeta != NULL)
      {
        if(PropertyExists(session, mNameID->GetNameID(propname), propMeta) == false)
          SetSessionProperty(session, mNameID->GetNameID(propname), propMeta, propvalue);

      }
      else
      {
        //it's not good at all: property which exist on template, does not exist in
        //service definition
        char buf[1024];
        sprintf(buf, "Property '%s' exists on account template, but not in service definition", (char*)propname);
        session->MarkAsFailed(buf, PIPE_ERR_APPLY_TEMPLATE_PROPS_FAILED);
        bSessionsFailed = true;
      }
    }
  }

  //PC.IMTPropertyMetaData propMeta = (PC.IMTPropertyMetaData)mServiceDef[name];

  if (bSessionsFailed)
    return PIPE_ERR_SUBSET_OF_BATCH_FAILED;

  //hacky - we need to clear sessionarray, we need to come up with better way to do this
  mTableWriter->Clear();

  return S_OK;
}

void BatchApplyTemplateProperties::MarkSessionsWithMissingPropertiesAsFailed(MTPipelineLib::IMTSessionSetPtr& aSessionSetPtr)
{
  SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSessionSetPtr);
  bool bFail = false;
	if (FAILED(hr))
		return MT_THROW_COM_ERROR(hr);
	
	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;
    if(session->PropertyExists(mAncestorAccountIDPropID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_FALSE)
    {
      bFail = (session->PropertyExists(mAncestorNamePropID, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE) ||
              (session->PropertyExists(mAncestorNameSpacePropID, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE);
    }
    if(bFail)
    {
      _bstr_t ancestorid = mNameID->GetName(mAncestorAccountIDPropID);
      _bstr_t ancestorname = mNameID->GetName(mAncestorNamePropID);
      _bstr_t ancestornamespace = mNameID->GetName(mAncestorNameSpacePropID);
      char buf[1024];
      sprintf(buf, "Either '%s' or a combination of '%s' and '%s' properties has to exist in session before template properties can be applied.", 
        (char*)ancestorid, (char*)ancestorname, (char*)ancestornamespace);
      session->MarkAsFailed(buf, PIPE_ERR_MISSING_PROP_NAME);
    }
	}
}

void BatchApplyTemplateProperties::DumpTemplatePropRowset(ROWSETLib::IMTSQLRowsetPtr mRowset)
{
  bool atleastone = false;
  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,"Resolved following account template properties:");
  while(!(bool)mRowset->RowsetEOF) 
  {
    atleastone = true;
    _bstr_t buf;
    _variant_t id_ancestor = mRowset->GetValue("id_ancestor");
    _variant_t id_old_ancestor = mRowset->GetValue("id_old_ancestor");
    _bstr_t propname = (_bstr_t)mRowset->GetValue("nm_prop");
    _variant_t propval = (_bstr_t)mRowset->GetValue("nm_value");
    buf = "Account Ancestor ID: ";
    buf += (_bstr_t)id_ancestor;
    buf += "; ";
    buf += "Old Account Ancestor ID: ";
    if(V_VT(&id_old_ancestor) == VT_NULL)
      buf += "NULL";
    else
      buf += (_bstr_t)id_old_ancestor;
    buf += "; ";
    buf += "Template Property Name: ";
    buf += (_bstr_t)propname;
    buf += "; ";
    buf += "Template Property Value: ";
    if(V_VT(&propval) == VT_NULL)
      buf += "NULL";
    else
      buf += (_bstr_t)propval;
    buf += "; ";
    mRowset->MoveNext();
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
  }
  if(atleastone)
    mRowset->MoveFirst();
}

bool BatchApplyTemplateProperties::PropertyExists(MTPipelineLib::IMTSessionPtr& session, long ID, IMTPropertyMetaDataPtr& propMeta)
{
  bool bExists = false;

  switch (propMeta->DataType)
  {
  case MTPipelineLib::PROP_TYPE_INTEGER:
    bExists = session->PropertyExists(ID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE;
    break;
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  case MTPipelineLib::PROP_TYPE_DECIMAL:
    bExists = session->PropertyExists(ID, MTPipelineLib::SESS_PROP_TYPE_DECIMAL) == VARIANT_TRUE;
    break;
  case MTPipelineLib::PROP_TYPE_STRING:
    bExists = session->PropertyExists(ID, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE;
    break;
  case MTPipelineLib::PROP_TYPE_DATETIME:
    bExists = session->PropertyExists(ID, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE;
    break;
  case MTPipelineLib::PROP_TYPE_TIME:
    bExists = session->PropertyExists(ID, MTPipelineLib::SESS_PROP_TYPE_TIME) == VARIANT_TRUE;
    break;
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
    bExists = session->PropertyExists(ID, MTPipelineLib::SESS_PROP_TYPE_BOOL) == VARIANT_TRUE;
    break;
  case MTPipelineLib::PROP_TYPE_ENUM:
    bExists = session->PropertyExists(ID, MTPipelineLib::SESS_PROP_TYPE_ENUM) == VARIANT_TRUE;
    break;
  default:
    ASSERT(false);
  }
  return bExists;

}

void BatchApplyTemplateProperties::SetSessionProperty(MTPipelineLib::IMTSessionPtr& session, long ID, IMTPropertyMetaDataPtr& propMeta, _variant_t val)
{
  bool bExists = false;

  switch (propMeta->DataType)
  {
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    session->SetLongProperty(ID, (long)val);
    break;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  case MTPipelineLib::PROP_TYPE_DECIMAL:
    session->SetDecimalProperty(ID, val);
    break;
  case MTPipelineLib::PROP_TYPE_STRING:
    session->SetBSTRProperty(ID, (_bstr_t)val);
    break;
  case MTPipelineLib::PROP_TYPE_DATETIME:
    session->SetOLEDateProperty(ID, (DATE)val);
    break;
  case MTPipelineLib::PROP_TYPE_TIME:
    ASSERT(false);
    break;
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
     VARIANT_BOOL bVal = ((_wcsicmp((wchar_t*)(_bstr_t)val, L"1") == 0) || 
				(_wcsicmp((wchar_t*)(_bstr_t)val, L"T") == 0) || 
				(_wcsicmp((wchar_t*)(_bstr_t)val, L"true") == 0)) ? VARIANT_TRUE : VARIANT_FALSE;
    session->SetBoolProperty(ID, bVal);
    break;
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
		session->SetEnumProperty(ID, (long)val);
    break;
  }
  default:
    ASSERT(false);
  }

}

wstring BatchApplyTemplateProperties::MakeKey(_bstr_t& anc_name, _bstr_t& anc_namespace)
{
  wchar_t buf[1024];
  wsprintf(buf, L"%s_%s", (wchar_t*)anc_name, (wchar_t*)anc_namespace);
  return wstring(buf);
}

