#include <metra.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <MSIXProperties.h>

#include <ExtendedProp.h>
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

#define TABLE_PREFIX L"t_ep_"
#define BACKUP_TABLE_PREFIX L"t_eb_"
#define ADD_EP_MAPPING L"__ADD_EP_MAPPING__"
#define DELETE_EP_MAPPING L"__DELETE_EP_MAPPING__"

#define CONFIG_DIR L"queries\\ProductCatalog"

using namespace std;

BOOL ExtendedPropCollection::Init(const wchar_t * apFilename /* = NULL */)
{
  const char * functionName = "ExtendedPropTableCollection::Init";

  BOOL retVal;
  
  MSIXDefCollection::DeleteAll();
  const wchar_t * dirName = L"ExtendedProp";
  if (apFilename)
  {
    std::wstring szTemp(dirName);
    szTemp += L"\\";
    szTemp += apFilename;
    // FAlSE indicates we are looking for a specific file
    retVal = MSIXDefCollection::Initialize(szTemp.c_str(), FALSE);
  }
  else
    retVal = MSIXDefCollection::Initialize(dirName);

  mCreator.haveBackup = FALSE;

  //
  // post initialization
  //
  list <CMSIXDefinition *>::iterator it;
  for ( it = GetDefList().begin(); it != GetDefList().end(); it++ )
  {
    CMSIXDefinition * def = *it;
    def->CalculateTableName(TABLE_PREFIX);

    //if (!Validate(def))
    //  return FALSE;
  }

  return retVal;
}


BOOL ExtendedPropCollection::CreateTables()
{
  // can reinit twice
  if (!mCreator.Init())
  {
    SetError(mCreator);
    return FALSE;
  }

  list <CMSIXDefinition *>::iterator it;
  for ( it = GetDefList().begin(); it != GetDefList().end(); it++ )
  {
    CMSIXDefinition * pDef = *it;
    
    // create the table
    if (!mCreator.SetupDatabase(*(pDef)))
    {
      SetError(mCreator);
      return FALSE;
    }

    std::wstring tablename(pDef->GetTableName());
    std::string checksum(pDef->GetChecksum());
    std::wstring type;
    
    const XMLNameValueMapDictionary * pdefattrs = pDef->GetAttributes();
    if (pdefattrs)
    {
      const XMLNameValueMapDictionary & defattrs = *pdefattrs;
      
      XMLNameValueMapDictionary::const_iterator findit = defattrs.find(L"kind");

      if (findit != defattrs.end())
        type = (findit->second).c_str();    
    }

    // TODO: a foreign key constraint must be set up between t_ep_map and t_principals
    // update t_ep_map with id_principle(kind), nm_ep_tablename(table_name), desc(?), core(N)
    ROWSETLib::IMTSQLRowsetPtr rs;
    
    try
    {
      HRESULT hr = rs.CreateInstance(MTPROGID_SQLROWSET);
      if (FAILED(hr))
        return FALSE;
      
      rs->Init(CONFIG_DIR);
      rs->SetQueryTag(ADD_EP_MAPPING);
      rs->AddParam("%%TYPE%%", type.c_str());
      rs->AddParam("%%TABLE_NAME%%", tablename.c_str());
      rs->Execute();
    }
    catch(_com_error& )
    {
      return FALSE;
    }

  }

  // false means they don't exist
  return UpdateChecksums(FALSE);
}


BOOL ExtendedPropCollection::MergeTables(const wchar_t* pColumnList, const wchar_t* pDefaultStr, const wchar_t* delimiter)
{
  // can reinit twice
  if (!mCreator.Init())
  {
    SetError(mCreator);
    return FALSE;
  }

  list <CMSIXDefinition *>::iterator it;
  for ( it = GetDefList().begin(); it != GetDefList().end(); it++ )
  {
    CMSIXDefinition * pDef = *it;

    // create the table
    if (!mCreator.MergeDatabase(*(pDef), pColumnList, pDefaultStr, delimiter))
    {
      SetError(mCreator);
      return FALSE;
    }
  }

  return TRUE;
}


// ----------------------------------------------------------------
// Name:  InsertDefaults    
// Arguments:   pColumnList: list of columns seperated by a comma
//              pDefaultStr: list of defaults for extended property table. 
//                
// Return Value:  TRUE, FALSE
// Errors Raised: 
// Description:   This method is called after the extended property table is deleted and we must
// recreate all entries with the default values. It must start with a comma and NOT end with a comma in order 
// to not break the query.  The same is true with pColumnList
// ----------------------------------------------------------------


BOOL ExtendedPropCollection::InsertDefaults(const wchar_t* pColumnList,const wchar_t* pDefaultStr)
{
  list <CMSIXDefinition *>::iterator it;
  for ( it = GetDefList().begin(); it != GetDefList().end(); it++ )
  {
    CMSIXDefinition * pDef = *it;
    try {
      ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
      rs->Init(CONFIG_DIR);
      rs->SetQueryTag("__POPULATE_EXTENDEDPROP_TABLE_WITH_DEFAULTS__");
      rs->AddParam("%%EP_TABLE%%",pDef->GetTableName().c_str());
      rs->AddParam("%%EP_COLUMNLIST%%",pColumnList);
      rs->AddParam("%%DEFAULTS_VALUES%%",pDefaultStr,VARIANT_TRUE);
      XMLString kind = (*pDef->GetAttributes()->find(std::wstring(L"kind"))).second;
      rs->AddParam("%%KIND%%",kind.c_str());
      rs->Execute();
    }
    catch(_com_error&) {
      return FALSE;
    }
  }
  return TRUE;
}


BOOL ExtendedPropCollection::DropTable(const wchar_t * apTableName)
{
  
  ROWSETLib::IMTSQLRowsetPtr rs;

  try
  {
    HRESULT hr = rs.CreateInstance(MTPROGID_SQLROWSET);
    if (FAILED(hr))
      return FALSE;
    
    rs->Init(CONFIG_DIR);
    rs->SetQueryTag(DELETE_EP_MAPPING);
    
    rs->AddParam("%%TABLE_NAME%%", apTableName);
    rs->Execute();

    rs->ClearQuery();             
    rs->SetQueryTag("__DELETE_EXTENDED_PROP_CHECKSUM__");
    rs->AddParam("%%TABLENAME%%", apTableName);
    rs->Execute();  
  }
  catch(_com_error& )
  {
    return FALSE;
  }

  return TRUE;
}


BOOL ExtendedPropCollection::DropTables(const wchar_t * apTableName /* = NULL */)
{
  // can reinit twice
  if (!mCreator.Init())
  {
    SetError(mCreator);
    return FALSE;
  }
  
  if (apTableName)
  {
    CMSIXDefinition def;
    if (!mCreator.CleanupDatabase(def, apTableName))
      return FALSE;
    if (!DropTable(apTableName))
      return FALSE;
  }
  else
  {
  
    list <CMSIXDefinition *>::iterator it;
    for ( it = GetDefList().begin(); it != GetDefList().end(); it++ )
    {
      CMSIXDefinition * pDef = *it;

      // delete the table
      if (!mCreator.CleanupDatabase(*(pDef)))
      {
        SetError(mCreator);
        return FALSE;
      }

      std::wstring tablename(pDef->GetTableName());
      if (!DropTable(tablename.c_str()))
        return FALSE;
    }
  }

  return TRUE;
}


BOOL ExtendedPropCollection::BackupTables(const wchar_t * apTableName /* = NULL */)
{
  // can reinit twice
  if (!mCreator.Init())
  {
    SetError(mCreator);
    return FALSE;
  }

  if (apTableName)
  {
    CMSIXDefinition def;
    if (!mCreator.BackupDatabase(def, apTableName))
      return FALSE;
  }
  else
  {
    list <CMSIXDefinition *>::iterator it;
    for ( it = GetDefList().begin(); it != GetDefList().end(); it++ )
    {
      CMSIXDefinition * pDef = *it;
      if (!mCreator.BackupDatabase(*(pDef)))
      {
        SetError(mCreator);
        return FALSE;
      }
    }
  }

  return TRUE;
}


// alreadyExists flag should be TRUE if the checksum exists in the database
// and should be updated, or FALSE if it should be created
BOOL ExtendedPropCollection::UpdateChecksums(BOOL aAlreadyExists /* = TRUE */)
{
  // can reinit twice
  if (!mCreator.Init())
  {
    SetError(mCreator);
    return FALSE;
  }

  list <CMSIXDefinition *>::iterator it;
  for ( it = GetDefList().begin(); it != GetDefList().end(); it++ )
  {
    CMSIXDefinition * pDef = *it;
    
    std::wstring tablename(pDef->GetTableName());
    std::string checksum(pDef->GetChecksum());

    ROWSETLib::IMTSQLRowsetPtr rs;
    
    try
    {
      HRESULT hr = rs.CreateInstance(MTPROGID_SQLROWSET);
      if (FAILED(hr))
        return FALSE;

      rs->Init(CONFIG_DIR);
      rs->ClearQuery();

      if (aAlreadyExists)
      {
        rs->SetQueryTag("__UPDATE_EXTENDED_PROP_CHECKSUM__");
      }
      else
      {
        // add checksum to the t_object_history
        rs->SetQueryTag("__ADD_EXTENDED_PROP_CHECKSUM__");
      }

      rs->AddParam("%%TABLENAME%%", tablename.c_str());
      rs->AddParam("%%CHECKSUM%%", checksum.c_str());
      rs->Execute();
    }
    catch(_com_error& )
    {
      return FALSE;
    }
  }
    
  return TRUE;
}

BOOL ExtendedPropCreator::Init()
{
  return DynamicTableCreator::Init();
}

BOOL ExtendedPropCreator::SetupDatabase(CMSIXDefinition & arDef)
{
  arDef.CalculateTableName(TABLE_PREFIX);

  // add the primary key
  std::vector<CMSIXProperties> additionalColumns;

  CMSIXProperties id;
  id.SetDN(L"id_prop");
  id.SetIsRequired(TRUE);
  id.SetPartOfKey(VARIANT_TRUE);
  id.SetPropertyType(CMSIXProperties::TYPE_INT32);
  id.SetDataType(L"int");
  id.SetColumnName(L"id_prop");
  id.SetReferenceTable(L"t_base_props");
  id.SetRefColumn(L"id_prop");
  additionalColumns.push_back(id);

  return CreateTable(arDef, &additionalColumns);
}

BOOL ExtendedPropCreator::MergeDatabase(CMSIXDefinition & arDef, const wchar_t* pColumnList, const wchar_t* pDefaultStr, const wchar_t* delimiter)
{
  arDef.CalculateBackupTableName(BACKUP_TABLE_PREFIX);

  // add the primary key
  std::vector<CMSIXProperties> additionalColumns;

  CMSIXProperties id;
  id.SetDN(L"id_prop");
  id.SetIsRequired(TRUE);
  id.SetPartOfKey(VARIANT_TRUE);
  id.SetPropertyType(CMSIXProperties::TYPE_INT32);
  id.SetDataType(L"int");
  id.SetColumnName(L"id_prop");
  id.SetReferenceTable(L"t_base_props");
  id.SetRefColumn(L"id_prop");
  additionalColumns.push_back(id);

  if (haveBackup)
  {
    return MergeTable(arDef, &additionalColumns, pColumnList, pDefaultStr, delimiter);
  }
  return TRUE;
}

BOOL ExtendedPropCreator::CleanupDatabase(CMSIXDefinition & arDef, const wchar_t * apTableName /*=NULL*/)
{
  arDef.CalculateTableName(TABLE_PREFIX);
  return DropTable(arDef, apTableName);
}

BOOL ExtendedPropCreator::BackupDatabase(CMSIXDefinition & arDef, const wchar_t * apTableName /*=NULL*/)
{
  haveBackup = TRUE;
  arDef.CalculateBackupTableName(BACKUP_TABLE_PREFIX);
  return BackupTable(arDef, apTableName);
}
