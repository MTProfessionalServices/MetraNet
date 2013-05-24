/**************************************************************************
* ACCOUNTDEFCREATOR
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

// includes
#include <StdAfx.h>
#include <metra.h>
#include <comdef.h>
#include "AccountDefCreator.h"
#include <mtprogids.h>
#include <SetIterate.h>
#include <mtglobal_msg.h>
#include <mtparamnames.h>
#include <loggerconfig.h>
#include <DBMiscUtils.h>
#include <formatdbvalue.h>

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

using namespace std;

// -------------------------------------------------------------------------
//	@mfunc
//	Constructor. Initialize the data members.
//	@rdesc
//	No return value
AccountDefCreator::AccountDefCreator() :
mInitialized(FALSE)
{	
  // initialize the logger ...
  LoggerConfigReader cfgRdr;
  mLogger.Init (cfgRdr.ReadConfiguration("Account"), MTACCOUNT_TAG);
}

// -------------------------------------------------------------------------
//	@mfunc
//	Destructor
//	@rdesc
//	No return value
AccountDefCreator::~AccountDefCreator()
{ }

// -------------------------------------------------------------------------
// @mfunc Initialize
// @parm
// @rdesc This function is responsible for initializing the object
// Returns true or false depending on whether the function succeeded or not.  
BOOL 
AccountDefCreator::Initialize()
{
  if (mInitialized)
    return TRUE;
  
  BOOL bOK = TRUE;
  
  // local variables
  const char* procName = "AccountDefCreator::Initialize";
  configPath = ACCOUNT_CONFIG_PATH;
  
  // instantiate a query adapter object second
  try
  {
    // create the queryadapter ...
    IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
    
    // initialize the queryadapter ...
    queryAdapter->Init(configPath);
    
    // extract and detach the interface ptr ...
    _bstr_t dbtype = queryAdapter->GetDBType() ;
    mDBType = (wchar_t*) dbtype ;
  }
  catch (_com_error& e)
  {
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to initialize query adapter");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError());
    bOK = FALSE;
  }
  
  if (bOK)
    mInitialized = TRUE;
  return (bOK); 
}

// -------------------------------------------------------------------------
// @mfunc CreateTable
// @parm
// @rdesc
BOOL
AccountDefCreator::CreateTable (CMSIXDefinition & arDef)
{
  // create the ddl string
  wstring langRequest;
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    // log
    mLogger.LogVarArgs (LOG_INFO, "Creating table <%s>", 
      (const char*) _bstr_t(arDef.GetTableName().c_str()));
    
    if (!GenerateCreateTableQuery(arDef, langRequest))
      return (FALSE);
    rowset->Init((wchar_t *)configPath);
    rowset->SetQueryString(langRequest.c_str());
    rowset->Execute();
    
    // create foreign key relationships 
    if(!CreateForeignKeyRelationships(arDef)) {
      mLogger.LogThis(LOG_ERROR,"Failed to properly configure foreign key relationships for account view");
      return FALSE;
    }
    
    // create single indexes 
    if (!CreateSingleIndex(arDef)) {
      mLogger.LogThis(LOG_ERROR,"Failed to create single indexes");
      return FALSE;
    }
    
    // create compound indexes 
    if (!CreateCompositeIndex(arDef)) {
      mLogger.LogThis(LOG_ERROR,"Failed to create compound indexes");
      return FALSE;
    }
  }
  catch(_com_error& e)
  {
    MT_THROW_COM_ERROR(e.Error());
  }
  
  return (TRUE);
}

// -------------------------------------------------------------------------
// @mfunc CreateInsertStoredProc
// @parm
// @rdesc

// TODO: Need to support ORACLE
BOOL
AccountDefCreator::CreateInsertStoredProc (CMSIXDefinition & arDef)
{
  // create the ddl string
  wstring langRequest;
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    if (!GenerateCreateInsertStoredProcQuery(arDef, langRequest))
      return (FALSE);
    rowset->SetQueryString(langRequest.c_str());
    rowset->Execute();
  }
  catch(_com_error& e)
  {
    MT_THROW_COM_ERROR(e.Error());
  }
  
  return (TRUE);
}

// -------------------------------------------------------------------------
// @mfunc CreateUpdateStoredProc
// @parm
// @rdesc

// TODO: Need to support ORACLE GenerateCreateUpdateStoredProcQuery
BOOL
AccountDefCreator::CreateUpdateStoredProc (CMSIXDefinition & arDef)
{
  // create the ddl string
  wstring langRequest;
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    if (!GenerateCreateUpdateStoredProcQuery(arDef, langRequest))
      return (FALSE);
    rowset->SetQueryString(langRequest.c_str());
    rowset->Execute();
  }
  catch(_com_error& e)
  {
    MT_THROW_COM_ERROR(e.Error());
  }
  return TRUE;
}

// -------------------------------------------------------------------------
// @mfunc DropTable
// @parm
// @rdesc GenerateDropTableQuery
BOOL
AccountDefCreator::DropTable(CMSIXDefinition & arDef)
{
  // create the ddl string
  wstring langRequest;
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    if (!GenerateDropTableQuery(arDef, langRequest))
      return (FALSE);
    rowset->SetQueryString(langRequest.c_str());
    rowset->Execute();
  }
  catch(_com_error& e)
  {
    MT_THROW_COM_ERROR(e.Error());
  }
  return TRUE;
}

// -------------------------------------------------------------------------
// @mfunc DropInsertStoredProc
// @parm
// @rdesc GenerateDropInsertStoredProcQuery
BOOL
AccountDefCreator::DropInsertStoredProc(CMSIXDefinition & arDef)
{
  // create the ddl string
  wstring langRequest;
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    if (!GenerateDropInsertStoredProcQuery(arDef, langRequest))
      return (FALSE);
    rowset->SetQueryString(langRequest.c_str());
    rowset->Execute();
  }
  catch(_com_error& e)
  {
    MT_THROW_COM_ERROR(e.Error());
  }
  return TRUE;
}

// -------------------------------------------------------------------------
// @mfunc DropUpdateStoredProc
// @parm
// @rdesc GenerateDropUpdateStoredProcQuery
BOOL
AccountDefCreator::DropUpdateStoredProc(CMSIXDefinition & arDef)
{
  // create the ddl string
  wstring langRequest;
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    if (!GenerateDropUpdateStoredProcQuery(arDef, langRequest))
      return (FALSE);
    rowset->SetQueryString(langRequest.c_str());
    rowset->Execute();
  }
  catch(_com_error& e)
  {
    MT_THROW_COM_ERROR(e.Error());
  }
  return TRUE;
}

// -------------------------------------------------------------------------
// @mfunc InsertData
// @parm
// @rdesc
BOOL
AccountDefCreator::InsertData(CMSIXDefinition & arDef,
                              MTACCOUNTLib::IMTAccountPropertyCollection* mtptr,
                              VARIANT apRowset /* = vtMissing*/)
{
  // create the ddl string
  HRESULT hr(S_OK);
  wstring langRequest;
  ROWSETLib::IMTSQLRowsetPtr rowset;
  _variant_t vRowset;
  
  try 
  {
    if(!OptionalVariantConversion(apRowset,VT_DISPATCH,vRowset)) 
    {
      hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
      if(FAILED(hr))
        MT_THROW_COM_ERROR(hr);
      ASSERT (rowset != NULL);
      rowset->Init((wchar_t *)configPath);
    }
    else
      rowset = vRowset;

    ASSERT (rowset != NULL);
    
    if (!GenerateInsertDataQuery(arDef, mtptr, langRequest))
      return (FALSE);
    
    // initialize the database context
    rowset->SetQueryString(langRequest.c_str());
    rowset->Execute();
  }
  catch (_com_error& e)
  {
    MT_THROW_COM_ERROR(e.Error());
  }
  catch (...)
  {
    return FALSE;
  }
  
  return (TRUE);
}

// -------------------------------------------------------------------------
// @mfunc UpdateData
// @parm
// @rdesc
BOOL
AccountDefCreator::UpdateData(CMSIXDefinition & arDef,
                              MTACCOUNTLib::IMTAccountPropertyCollection* mtptr,
                              VARIANT apRowset /* = vtMissing*/)
{
	 // create the ddl string
  HRESULT hr(S_OK);
  wstring langRequest;
  ROWSETLib::IMTSQLRowsetPtr rowset;
  _variant_t vRowset;
  
  try 
  {
    if(!OptionalVariantConversion(apRowset,VT_DISPATCH,vRowset)) 
    {
      hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
      if(FAILED(hr))
        MT_THROW_COM_ERROR(hr);
      ASSERT (rowset != NULL);
      rowset->Init((wchar_t *)configPath);
    }
    else
      rowset = vRowset;
    
    ASSERT (rowset != NULL);
    
    if (!GenerateUpdateDataQuery(arDef, mtptr, langRequest))
      return (FALSE);
    
    // initialize the database context
    rowset->SetQueryString(langRequest.c_str());
    rowset->Execute();
  }
  catch (_com_error& e)
  {
    MT_THROW_COM_ERROR(e.Error());
  }
  catch (...)
  {
    return FALSE;
  }
  
  return TRUE;
}

// -------------------------------------------------------------------------
// @mfunc GetData
// @parm
// @rdesc
BOOL
AccountDefCreator::GetData(CMSIXDefinition & arDef,
                           long arAccountID,
						   VARIANT apRowset,
                           map<wstring, _variant_t>& propcoll)
{
  // create the ddl string
  string buffer;
  wstring wstrName;
  wstring langRequest;
  ROWSETLib::IMTSQLRowsetPtr rowset;
  try
  {
	_variant_t vRowset;
	if (OptionalVariantConversion(apRowset,VT_DISPATCH,vRowset)) 
		rowset = vRowset;

	HRESULT hr;
	if (rowset == NULL)
	{
		hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
		if (FAILED(hr))
			MT_THROW_COM_ERROR(hr);
		ASSERT (rowset != NULL);
	    hr = rowset->Init((wchar_t *)configPath);
		if (FAILED(hr))
		{
			mLogger.LogThis(LOG_ERROR, "Init() failed. Unable to initialize database access layer");
			return hr;
		}
	}
	else
	{
	    hr = rowset->UpdateConfigPath((wchar_t *)configPath);
		if (FAILED(hr))
		{
			mLogger.LogThis(LOG_ERROR, "UpdateConfigPath() failed. Unable to update configuration path");
			return hr;
		}
	}

	const char* procName = "AccountDef::GetData";
    
    // msix properties stuff
    MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
    
    if (!GenerateGetDataQuery(arDef, arAccountID, langRequest))
		return (FALSE);
    rowset->SetQueryString(langRequest.c_str());
    rowset->Execute();
    
    // store the account ID in a buffer
    string rwAccountID;
    char accountID[10];
    ltoa(arAccountID, accountID, 10);
		rwAccountID = accountID;
    
    if (rowset->GetRecordCount() == 0)
    {
      buffer = "The account not found in the database for accountID <" + rwAccountID + ">";
      SetError(ACCOUNT_NOT_FOUND, 
        ERROR_MODULE, 
        ERROR_LINE, 
        procName, 
        buffer.c_str()) ;
      mLogger.LogThis (LOG_DEBUG, buffer.c_str());
      return (FALSE);
    }
    else if (rowset->GetRecordCount() > 1)
    {
      buffer = "More than one account was found for accountID <" + rwAccountID + ">";
      SetError(MORE_THAN_ONE_ACC, 
        ERROR_MODULE, 
        ERROR_LINE, 
        procName,
        buffer.c_str());
      mLogger.LogThis (LOG_ERROR, buffer.c_str()); 
      return (FALSE);
    }
    else
    {
			MSIXPropertiesList::iterator it;
			for (it = list.begin(); it != list.end(); ++it)
      {
				CMSIXProperties * prop = *it;

        long lValue = -99;
        _variant_t vtValue;
        _variant_t vtTemp;
        _bstr_t wstrValue = L"";
        _variant_t vtNull;
        vtNull.vt = VT_NULL;
        
        wstrName = prop->GetColumnName();
        
        // varchar, char, nvarchar, or, nchar
        if ((0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_VARCHAR_STR)) ||
            (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_CHAR_STR))    ||
            (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NVARCHAR_STR))||
            (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NCHAR_STR)) )
        {
          vtValue = rowset->GetValue(_variant_t(prop->GetColumnName().c_str()));
          if (V_VT(&vtValue) == VT_NULL || ((_bstr_t)vtValue).length() == 0)
            propcoll[wstrName] = vtNull;
          else
            propcoll[wstrName] = (_bstr_t)vtValue;
        }
        else if (	0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_INT_STR) ||
          0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_ENUM_STR))
        {
          vtTemp = rowset->GetValue(_variant_t(prop->GetColumnName().c_str()));
          if (V_VT(&vtTemp) == VT_NULL)
            propcoll[wstrName] = vtNull;
          else
            propcoll[wstrName] = (long)vtTemp;
        }
        else if (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_DATETIME_STR))
        {
          vtValue = rowset->GetValue(_variant_t(prop->GetColumnName().c_str()));
          propcoll[wstrName] = vtValue;
        }
        else if (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NUMERIC_STR))
        {
          vtValue = rowset->GetValue(_variant_t(prop->GetColumnName().c_str()));
          propcoll[wstrName] = vtValue;
        }
        else
        {
          mLogger.LogThis(LOG_ERROR, L"Unknown database datatype");
          return (FALSE);
        }
      }
    }
  }
  catch(_com_error& e)
  {
    MT_THROW_COM_ERROR(e.Error());
  }
  
  return (TRUE);
}


// -------------------------------------------------------------------------
// @mfunc GenerateCreateTableQuery
// @parm
// @rdesc Get the ddl information
// the 5 key pieces of information that are reqd. are
// 1) table name suffix
// 2) column names
// 3) datatype
// 4) length, if varchar or char
// 5) in_required field for figuring out if it should be NULL or NOT NULL
BOOL
AccountDefCreator::GenerateCreateTableQuery(CMSIXDefinition & arDef,
                                            wstring& langRequest)
{
  const char* procName = "AccountDefCreator::GenerateCreateTableQuery";
  
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
  // Build the inner string
  wstring wstrDDLInnards = L"";
  wstring wstrDataType = L"";
  wstring wstrKeyColumns = L"";
  BOOL bFirstTime = FALSE;
  
	MSIXPropertiesList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXProperties * prop = *it;
    wchar_t tempNum[50]; // is that max enough
    
    if (bFirstTime == TRUE)
    {
      wstrDDLInnards += L", ";
    }
    
    // check to see if this property needs to be part of the key with
    // id_acc
    if (VARIANT_TRUE == prop->GetPartOfKey())
    {
      wstrKeyColumns += L", ";
      wstrKeyColumns += prop->GetColumnName();
    }
    
    wstrDataType = prop->GetDataType();
    
    //handle Oracle DATETIME
    if (_wcsicmp(wstrDataType.c_str(), W_DB_DATETIME_STR) == 0)
    {
      if (_wcsicmp(mDBType.c_str(), ORACLE_DATABASE_TYPE) == 0)
      {
        wstrDataType = W_DB_DATETIME_STR_ORACLE;
      }
    }
    //handle enum types
    else if (_wcsicmp(wstrDataType.c_str(), W_DB_ENUM_STR) == 0)
    {
      wstrDataType = W_DB_INT_STR;
    }
    
    wstrDDLInnards += prop->GetColumnName();
    wstrDDLInnards += L" ";
    
    // varchar, char, nvarchar, or, nchar
    if ((0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_VARCHAR_STR)) ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_CHAR_STR))    ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NVARCHAR_STR))||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NCHAR_STR)) )
    {
			if (_wcsicmp(mDBType.c_str(), ORACLE_DATABASE_TYPE) == 0)
			{
        wstrDataType = W_DB_NVARCHAR_STR_ORACLE;
      }
		}

    wstrDDLInnards += wstrDataType;
    wstrDDLInnards += L" ";
    
    // varchar, char, nvarchar, or, nchar
    if ((0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_VARCHAR_STR)) ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_CHAR_STR))    ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NVARCHAR_STR))||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NCHAR_STR)) )
    {
			long length = prop->GetLength();
      wstrDDLInnards += L"(";
      wstrDDLInnards += _itow(length, tempNum, 10);
      wstrDDLInnards += L") ";
    }
    wstrDDLInnards += prop->GetRequiredConstraint();
    bFirstTime = TRUE;
  }
  
  // generate the Create Table query
  _bstr_t queryTag;
  _variant_t vtParam;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    queryTag = "__CREATE_ACCOUNT_VIEW_TABLE__";
    rowset->SetQueryTag(queryTag);
    
    vtParam = arDef.GetTableName().c_str();
    rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
    
    vtParam = wstrDDLInnards.c_str();
    rowset->AddParam(MTPARAM_DDL_INNARDS, vtParam);
    
    vtParam = wstrKeyColumns.c_str();
    rowset->AddParam(MTPARAM_KEY_COLUMNS, vtParam);
    
    langRequest = rowset->GetQueryString();
  }
  catch (_com_error& e)
  {
    langRequest = L"";
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
				  "Unable to get __CREATE_ACCOUNT_VIEW_TABLE__ query");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  return (TRUE);
}

                                            //
//
//
BOOL 
AccountDefCreator::CreateForeignKeyRelationships(CMSIXDefinition & arDef)
{
  const char* procName = "AccountDefCreator::CreateForeignKeyRelationships";
  
  // step 1: initialize the property list
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
  int aFkIndex = 1;
  
  // step 2: iterate through the columns
	MSIXPropertiesList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXProperties * prop = *it;
    
    // step 4: only if a foreign name was specified
    CMSIXProperties* pProp = prop;
    if(prop->GetReferenceTable().length() != 0) {
      
      // step 5: make sure the the user also specified the column name in the forign table
      if(prop->GetRefColumn().length() == 0) {
        SetError(FALSE,ERROR_MODULE, ERROR_LINE, procName,"foreign column name not specified");
        return FALSE;
      }
      
      try 
      {
        _variant_t vtParam;
        
        ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
        rowset->Init((wchar_t *)configPath);
        rowset->SetQueryTag("__ADD_ACCOUNT_VIEW_FK__");
        
        
        vtParam = arDef.GetTableName().c_str();
        rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
        
        _bstr_t aFkName = arDef.GetTableName().c_str();
        aFkName += "_FK";
        char aTemp[100];
        _itoa(aFkIndex++,aTemp,10);
        aFkName += aTemp;
        vtParam = aFkName;
        rowset->AddParam(MTPARAM_AV_FKNAME, vtParam);
        
        vtParam = prop->GetColumnName().c_str();
        rowset->AddParam(MTPARAM_AV_COLUMNNAME, vtParam);
        
        vtParam = prop->GetReferenceTable().c_str();
        rowset->AddParam(MTPARAM_AV_FOREIGNTABLE, vtParam);
        
        vtParam = prop->GetRefColumn().c_str();
        rowset->AddParam(MTPARAM_AV_FOREIGN_COLUMN, vtParam);
        
        rowset->Execute();
      }
      catch(_com_error& e) {
        _bstr_t aErrorStr;
        if(e.Description().length() == 0) 
          aErrorStr = "Unable to run the __ADD_ACCOUNT_VIEW_FK__ query";
        SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,aErrorStr);
        mLogger.LogErrorObject(LOG_ERROR, GetLastError());
        return FALSE;
      }
    }
  }
  
  return TRUE;
}

//
//
//
BOOL 
AccountDefCreator::CreateSingleIndex(CMSIXDefinition & arDef)
{
  const char* procName = "AccountDefCreator::CreateSingleIndex";
  
  // step 1: initialize the property list
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
	MSIXPropertiesList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXProperties * prop = *it;

    CMSIXProperties* pProp = prop;
    if(prop->GetSingleIndex() == VARIANT_TRUE) 
    {
      try 
      {
        _variant_t vtParam;
        
        ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
        rowset->Init((wchar_t *)configPath);
        rowset->SetQueryTag("__ADD_ACCOUNT_VIEW_SINGLE_INDEX__");
        vtParam = arDef.GetTableName().c_str();
        rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
        
        wstring wstrTruncatedName = prop->GetColumnName().substr(0,4);
        vtParam = wstrTruncatedName.c_str();
        rowset->AddParam(MTPARAM_INDEX_SUFFIX, vtParam);
        
        vtParam = prop->GetColumnName().c_str();
        rowset->AddParam(MTPARAM_INDEX_COLUMNS, vtParam);
        
        rowset->Execute();
        
      }
      catch(_com_error& e) 
      {
        _bstr_t aErrorStr;
        if(e.Description().length() == 0) 
          aErrorStr = "Unable to run the __ADD_ACCOUNT_VIEW_SINGLE_INDEX__ query";
        SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,aErrorStr);
        mLogger.LogErrorObject(LOG_ERROR, GetLastError());
        return FALSE;
      }
    }
  }
  
  return TRUE;
}

//
//
//
BOOL 
AccountDefCreator::CreateCompositeIndex(CMSIXDefinition & arDef)
{
  BOOL bFirstTime = FALSE;
  BOOL bCreateIndex = FALSE;
  wstring wstrIndexColumns = L"";
  wstring wstrIndexSuffix = L"";
  wstring wstrTruncatedName = L"";
  const char* procName = "AccountDefCreator::CreateCompositeIndex";
  
  // step 1: initialize the property list
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
  // build the list of indexes here
  // if there is just one index that is declared as composite, then create
  // it as single index
	MSIXPropertiesList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXProperties * prop = *it;

    CMSIXProperties* pProp = prop;
    if(((prop->GetSingleCompositeIndex() == VARIANT_TRUE)) ||
      (prop->GetCompositeIndex() == VARIANT_TRUE))
    {
		    bCreateIndex = TRUE;
        
        if (bFirstTime == TRUE)
        {
          wstrIndexSuffix += L"_";
          wstrIndexColumns += L", ";
        }
        
				// Truncate by getting the leading 4 characters
        wstrTruncatedName = prop->GetColumnName().substr(0, 4);
        
        wstrIndexSuffix += wstrTruncatedName;
        wstrIndexColumns += prop->GetColumnName();
        
        bFirstTime = TRUE;
    }
  }
  
  // no need to create indexes. just return
  if (bCreateIndex == FALSE)
    return TRUE;
  
  mLogger.LogVarArgs(LOG_DEBUG, "Index --> <%s>", 
    (const char*) _bstr_t(wstrIndexColumns.c_str()));
  mLogger.LogVarArgs(LOG_DEBUG, "Suffix --> <%s>", 
    (const char*) _bstr_t(wstrIndexSuffix.c_str()));
  //CREATE INDEX %%TABLE_NAME%%_%%INDEX_SUFFIX%%_ind ON 
  //authors (%%INDEX_COLUMNS%%) 
  
  try 
  {
    _variant_t vtParam;
    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    rowset->SetQueryTag("__ADD_ACCOUNT_VIEW_COMPOSITE_INDEX__");
    
    vtParam = arDef.GetTableName().c_str();
    rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
    
    vtParam = wstrIndexSuffix.c_str(); 
    rowset->AddParam(MTPARAM_INDEX_SUFFIX, vtParam);
    
    vtParam = wstrIndexColumns.c_str(); 
    rowset->AddParam(MTPARAM_INDEX_COLUMNS, vtParam);
    
    rowset->Execute();
    
    
  }
  catch(_com_error& e) {
    _bstr_t aErrorStr;
    if(e.Description().length() == 0) 
      aErrorStr = "Unable to run the __ADD_ACCOUNT_VIEW_COMPOSITE_INDEX__ query";
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,aErrorStr);
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return FALSE;
  }
  
  return TRUE;
}

// -------------------------------------------------------------------------
// @mfunc GenerateCreateInsertStoredProcQuery
// @parm
// @rdesc Get the ddl information
// the 5 key pieces of information that are reqd. are
// 1) table name suffix
// 2) column names
// 3) datatype
// 4) length, if varchar or char
// 5) in_required field for figuring out if it should be NULL or NOT NULL
BOOL
AccountDefCreator::GenerateCreateInsertStoredProcQuery(CMSIXDefinition & arDef,
                                                       wstring& langRequest)
{
  const char* procName = "AccountDefCreator::GenerateCreateInsertStoredProcQuery";
  
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
  // Build the inner string
  wstring wstrInputs = L" ";
  wstring wstrColumnNames = L" ";
  wstring wstrColumnValues = L" ";
  BOOL bFirstTime = FALSE;
  
	MSIXPropertiesList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXProperties * prop = *it;

    wchar_t tempNum[50]; // is that max enough
    
    if (bFirstTime == TRUE)
    {
      wstrInputs += L", ";
      wstrColumnNames += L", ";
      wstrColumnValues += L", ";
    }
    
    // create the inputs to stored proc string
    wstrInputs += L"@";
    wstrInputs += prop->GetColumnName();
    wstrInputs += L" ";
    wstrInputs += prop->GetDataType();
    
    // varchar or char
    if ((0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_VARCHAR_STR)) ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_CHAR_STR))    ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NVARCHAR_STR))||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NCHAR_STR)))
    {
		    long length = prop->GetLength();
        wstrInputs += L"(";
        wstrInputs += _itow(length, tempNum, 10);
        wstrInputs += L")";
    }
    
    // 
    wstrColumnNames += prop->GetColumnName();
    
    // 
    wstrColumnValues += L"@";
    wstrColumnValues += prop->GetColumnName();
    
    bFirstTime = TRUE;
  }
  
  // generate the Create Table query
  _bstr_t queryTag;
  _variant_t vtParam;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    rowset->SetQueryTag("__CREATE_INSERT_PROC__");
    vtParam = arDef.GetTableName().c_str();
    rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
    
    vtParam = wstrInputs.c_str();
    rowset->AddParam(MTPARAM_INPUTS, vtParam);
    
    vtParam = wstrColumnNames.c_str();
    rowset->AddParam(MTPARAM_COLUMN_NAMES, vtParam);
    
    vtParam = wstrColumnValues.c_str();
    rowset->AddParam(MTPARAM_COLUMN_VALUES, vtParam);
    
    langRequest = rowset->GetQueryString();
  }
  catch (_com_error& e)
  {
    langRequest = L"";
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
				  "Unable to get __CREATE_INSERT_PROC__ query");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  return (TRUE);
}

// -------------------------------------------------------------------------
// @mfunc GenerateCreateUpdateStoredProcQuery
// @parm
// @rdesc Get the ddl information
// the 5 key pieces of information that are reqd. are
// 1) table name suffix
// 2) column names
// 3) datatype
// 4) length, if varchar or char
// 5) in_required field for figuring out if it should be NULL or NOT NULL
BOOL
AccountDefCreator::GenerateCreateUpdateStoredProcQuery(CMSIXDefinition & arDef,
                                                       wstring& langRequest)
{
  const char* procName = "AccountDefCreator::GenerateCreateUpdateStoredProcQuery";
  
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
  // Build the inner string
  wstring wstrInputs = L" ";
  wstring wstrColumnNamesValues = L" ";
  BOOL bFirstTime = FALSE;
  
	MSIXPropertiesList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXProperties * prop = *it;

    wchar_t tempNum[50]; // is that max enough
    
    if (bFirstTime == TRUE)
    {
      wstrInputs += L", ";
      wstrColumnNamesValues += L", ";
    }
    
    // create the inputs to stored proc string
    wstrInputs += L"@";
    wstrInputs += prop->GetColumnName();
    wstrInputs += L" ";
    wstrInputs += prop->GetDataType();
    
    // varchar, char, nvarchar, or, nchar
    if ((0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_VARCHAR_STR)) ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_CHAR_STR))    ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NVARCHAR_STR))||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NCHAR_STR)) )
    {
      long length = prop->GetLength();
      wstrInputs += L"(";
      wstrInputs += _itow(length, tempNum, 10);
      wstrInputs += L")";
    }
    
    // 
    wstrColumnNamesValues += prop->GetColumnName();
    wstrColumnNamesValues += L" = @";
    wstrColumnNamesValues += prop->GetColumnName();
    
    bFirstTime = TRUE;
  }
  
  // generate the Create Table query
  _bstr_t queryTag;
  _variant_t vtParam;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    rowset->SetQueryTag("__CREATE_UPDATE_PROC__");

    vtParam = arDef.GetTableName().c_str();
    rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
    
    vtParam = wstrInputs.c_str();
    rowset->AddParam(MTPARAM_INPUTS, vtParam);
    
    vtParam = wstrColumnNamesValues.c_str();
    rowset->AddParam(MTPARAM_COLUMN_NAME_COLUMN_VALUE, vtParam);
    
    langRequest = rowset->GetQueryString();
  }
  catch (_com_error& e)
  {
    langRequest = L"";
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to get __CREATE_UPDATE_PROC__ query");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  
  
  return (TRUE);
}

// -------------------------------------------------------------------------
// @mfunc GenerateInsertDataQuery
// @parm
// @rdesc Get the ddl information
// the 5 key pieces of information that are reqd. are
// 1) table name suffix
// 2) column names
// 3) datatype
// 4) length, if varchar or char
// 5) in_required field for figuring out if it should be NULL or NOT NULL
BOOL
AccountDefCreator::GenerateInsertDataQuery(CMSIXDefinition & arDef,
                                           MTACCOUNTLib::IMTAccountPropertyCollection* mtptr,
                                           wstring& langRequest)
{
  const char* procName = "AccountDefCreator::GenerateInsertDataQuery";
  
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
  
  std::map<_bstr_t, _variant_t> PropColl;
  std::map<_bstr_t, _variant_t>::iterator mapit;
  
  SetIterator<MTACCOUNTLib::IMTAccountPropertyCollectionPtr, 
    MTACCOUNTLib::IMTAccountPropertyPtr> setit;
  HRESULT hr = setit.Init(mtptr);
  if (FAILED(hr))
    return hr;
  
  
  while (TRUE)
  {
    MTACCOUNTLib::IMTAccountPropertyPtr accprop = setit.GetNext();
    if (accprop == NULL)
		    break;
    _bstr_t bstrName = accprop->GetName();
    _variant_t vValue = accprop->GetValue();
    PropColl[bstrName] = vValue;
  }
  
  
  // Build the inner string
  wstring wstrColumnNames, wstrColumnValues ;
  wstrColumnNames = L"ID_ACC ";
  mapit = PropColl.find(_bstr_t("ID_ACC"));
  
  if(mapit == PropColl.end())
  {
    mLogger.LogVarArgs(LOG_ERROR, L"Value for account ID not found");
    return (FALSE);
  }
  _variant_t value = mapit->second;
  
  wchar_t tempNum[50]; // is that max enough
  long lValue = (long) value;
  wstrColumnValues += _itow(lValue, tempNum, 10);
  
  BOOL bFirstTime = FALSE;
  
	MSIXPropertiesList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXProperties * prop = *it;

    _variant_t var = _bstr_t("");
    
    wstring wstrDN = prop->GetDN();
		StrToUpper(wstrDN);
    //mLogger.LogVarArgs(LOG_DEBUG, L"Looking for <%s>", prop->GetColumnName());
    mapit = PropColl.find(wstrDN.c_str());
    
    if (mapit == PropColl.end()) 
    {
      if (prop->GetIsRequired())
      {
        mLogger.LogVarArgs(LOG_ERROR, L"Value for <%s> not found", prop->GetColumnName().c_str());
        return (FALSE);
      }
      else
        continue;
    }
    var = mapit->second;
    
    // add the , to the column names and values ...
    wstrColumnNames += L", " ;
    wstrColumnValues += L", " ;
    
    // create the inputs to stored proc string
    wstrColumnNames += prop->GetColumnName();
    
    // varchar, char, nvarchar, or, nchar
    if ((0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_VARCHAR_STR)) ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_CHAR_STR))    ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NVARCHAR_STR))||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NCHAR_STR)) )
    {
      
      // TODO: there was a crash here.  checking for VT_NULL and
      // VT_EMPTY fixes it.  It could use further investigation.
      if (V_VT(&var) == VT_NULL || V_VT(&var) == VT_EMPTY)
      {
        wstrColumnValues += L"NULL";
      }
      else
      {
        wstring wstrValue = (const wchar_t*) _bstr_t (var.bstrVal);
        wstring wstrValidatedStringValue = ValidateString(wstrValue);
        
        if (wstrValidatedStringValue.length() == 0 || 
          var.vt == VT_NULL || 
          var.vt == VT_EMPTY)
        {
          wstrColumnValues += L"NULL";		
        }
        else
        {
          wstrColumnValues += L"N'";
          wstrColumnValues += wstrValidatedStringValue;
          wstrColumnValues += L"'";
        }
      }
    }
    else if (	0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_INT_STR) ||
      0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_ENUM_STR))
    {
      if (var.vt == VT_NULL || var.vt == VT_EMPTY)
      {
        wstrColumnValues += L"NULL";		
      }
      else
      {
        long lValue = var.lVal;
        wstrColumnValues += _itow(lValue, tempNum, 10);
      }
    }
    else if (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NUMERIC_STR))
    {
// HACKERY
      if(var.vt == VT_DECIMAL)
        var.ChangeType(VT_R8);
//END HACKERY

      double dblValue = var.dblVal;
      char strValue[50];
      sprintf(strValue,"%lf", dblValue);
      wstrColumnValues += _bstr_t(strValue);
    }
    else if (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_DATETIME_STR))
    {
      wstring strDate;

      var.ChangeType(VT_DATE);

      if(!FormatValueForDB(var, FALSE, strDate))
        return FALSE;

      wstrColumnValues += strDate.c_str();
    }
    else
    {
      mLogger.LogThis(LOG_ERROR, L"Unknown database datatype");
      return (FALSE);
    }
    
    bFirstTime = TRUE;
  }
  
  // generate the Create Table query
  _bstr_t queryTag;
  _variant_t vtParam, vtValue;
  vtValue = (VARIANT_BOOL) VARIANT_TRUE ;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    rowset->SetQueryTag("__INSERT_ACCOUNT_DATA__");
    
    vtParam = arDef.GetTableName().c_str();
    rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
    
    vtParam = wstrColumnNames.c_str();
    rowset->AddParam(MTPARAM_COLUMNNAMES, vtParam);
    
    vtParam = wstrColumnValues.c_str();
    rowset->AddParam(MTPARAM_COLUMNVALUES, vtParam, vtValue);
    
    langRequest = rowset->GetQueryString();
    
  }
  catch (_com_error& e)
  {
    langRequest = L"";
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to get __INSERT_ACCOUNT_DATA__ query");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  return (TRUE);
}

// -------------------------------------------------------------------------
// @mfunc GenerateUpdateDataQuery
// @parm
// @rdesc Get the ddl information
// the 5 key pieces of information that are reqd. are
// 1) table name suffix
// 2) column names
// 3) datatype
// 4) length, if varchar or char
// 5) in_required field for figuring out if it should be NULL or NOT NULL
BOOL
AccountDefCreator::GenerateUpdateDataQuery(CMSIXDefinition & arDef,
                                           MTACCOUNTLib::IMTAccountPropertyCollection* mtptr,
                                           wstring& langRequest)
{
  const char* procName = "AccountDefCreator::GenerateUpdateDataQuery";
  
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
  map<wstring, _variant_t> PropColl;
  
  // ------------------------ populate the local hash dictionary ----
  // iterate through the collection 
  SetIterator<MTACCOUNTLib::IMTAccountPropertyCollectionPtr, 
    MTACCOUNTLib::IMTAccountPropertyPtr> setit;
  HRESULT hr = setit.Init(mtptr);
  if (FAILED(hr))
    return hr;
  
  while (TRUE)
  {
    MTACCOUNTLib::IMTAccountPropertyPtr accprop = setit.GetNext();
    if (accprop == NULL)
		    break;
    
    // perform the operation
    try 
    {
      _bstr_t name;
      _variant_t value;
      _bstr_t datatype;
      _bstr_t columnname;
      
      name = accprop->GetName();
      wstring wstrName(name);
      value = accprop->GetValue();
      PropColl[wstrName] = value; 
    }
    catch (_com_error& e)
    {
			string buffer("Unable to iterate");
			SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, buffer.c_str());
			mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
			return (FALSE);
    }	
  }
  
  
  // Build the inner string
  wstring wstrInputs ;
  wstring wstrWhereClause;
  wchar_t tempNum[64] ;
  
	map<wstring, _variant_t>::const_iterator mapit = PropColl.find(L"ID_ACC");
  if (mapit == PropColl.end())
  {
    mLogger.LogVarArgs(LOG_ERROR, L"Value for account ID not found");
    return (FALSE);
  }
  
  //start WHERE clause with account id
  wstrWhereClause =		L"ID_ACC = ";
  _bstr_t temp = (*mapit).second;
  wstrWhereClause +=	(const wchar_t*)temp;
  
  //
  BOOL bFirstTime = TRUE;
  BOOL bPartOfKey = FALSE;
  
	MSIXPropertiesList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXProperties * prop = *it;
		wstring wstrDN = prop->GetDN();
		StrToUpper(wstrDN);
		mapit = PropColl.find(wstrDN);
    if (mapit == PropColl.end())
    {
      if (prop->GetIsRequired())
      {
        mLogger.LogVarArgs(LOG_ERROR, 
          L"Value for <%s> not found", prop->GetColumnName().c_str());
        return (FALSE);
      }
      else
        continue;
    }

		_variant_t value((*mapit).second);
    
    //if this property is a part of key, then it's not supposed to be
    //in SET clause, but on WHERE clause
    bPartOfKey = (prop->GetPartOfKey() == VARIANT_TRUE );
    
    if(bPartOfKey)
      wstrWhereClause += L" AND ";
    
		if (bFirstTime == FALSE && !bPartOfKey)
    {
      if(wstrInputs.length() > 0)
        wstrInputs += L", ";
    }
    
    if(bPartOfKey)
    {
      wstrWhereClause += prop->GetColumnName();
      wstrWhereClause += L" = ";
    }
    else	
    {
      wstrInputs += prop->GetColumnName();
      wstrInputs += L" = ";
    }
    
    
    // varchar, char, nvarchar, or, nchar
    if ((0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_VARCHAR_STR)) ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_CHAR_STR))    ||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NVARCHAR_STR))||
        (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NCHAR_STR)) )
    {
      // Check for null string
      wstring wstrValidatedStringValue;
      if (value.vt != VT_NULL && value.vt != VT_EMPTY)
      {
        wstrValidatedStringValue = ValidateString((const wchar_t*) _bstr_t (value.bstrVal));
      }
      
      // if the length is 0 or the variant value is NULL or EMPTY
      if (wstrValidatedStringValue.length() == 0)
      {
        wstrInputs += L"NULL";		
      }
      else
      {
        if(bPartOfKey)
        {
          wstrWhereClause += L"N'";
          wstrWhereClause += wstrValidatedStringValue;
          wstrWhereClause += L"'";
        }
        else
        {
          wstrInputs += L"N'";
          wstrInputs += wstrValidatedStringValue;
          wstrInputs += L"'";
        }
      }
    }
    else if (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_INT_STR) ||
      0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_ENUM_STR))
    {
      // check to see if the value is either of type NULL or EMPTY
      // if it is, then need to replace it with NULL rather than some
      // garbage value
      
      // We are doing this extra check (value.bstrVal) for an empty string
      // because there is no way to VT_EMPTY or a VT_NULL from a pipeline 
      // session
      _bstr_t bstrVal = value;
      if ((value.vt == VT_NULL) || (value.vt == VT_EMPTY) || (bstrVal.length() == 0))
        wstrInputs += L"NULL";
      else 
      {
        long lValue = value.lVal;
        if(bPartOfKey)
          wstrWhereClause += _itow(lValue, tempNum, 10);
        else
          wstrInputs += _itow(lValue, tempNum, 10);
      }
    }
    else if (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_NUMERIC_STR))
    {
// HACKERY
      if(value.vt == VT_DECIMAL)
        value.ChangeType(VT_R8);
//END HACKERY

      double dblValue = value.dblVal;
      char strValue[50];
      sprintf(strValue,"%lf", dblValue);
      
      if(bPartOfKey)
        wstrWhereClause += _bstr_t(strValue);
      else
        wstrInputs += _bstr_t(strValue);
    }
    else if (0 == _wcsicmp(prop->GetDataType().c_str(), W_DB_DATETIME_STR))
    {
      if(bPartOfKey)
      {
        wstring strDate;

        value.ChangeType(VT_DATE);

        if(!FormatValueForDB(value, FALSE, strDate))
          return FALSE;

        wstrWhereClause += strDate.c_str();
        }
      else
      {
        wstring strDate;
        value.ChangeType(VT_DATE);
        if(!FormatValueForDB(value, FALSE, strDate))
          return FALSE;
        
        wstrInputs += strDate.c_str();
      }
    }
    else
    {
      mLogger.LogThis(LOG_ERROR, L"Unknown database datatype");
      return (FALSE);
    }
    
    bFirstTime = FALSE;
  }
  
  // generate the Create Table query
  _bstr_t queryTag;
  _variant_t vtParam, vtValue;
  vtValue = (VARIANT_BOOL) VARIANT_TRUE ;
  
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    rowset->SetQueryTag("__UPDATE_ACCOUNT_DATA__");
    
    vtParam = arDef.GetTableName().c_str();
    rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
    
    vtParam = wstrInputs.c_str();
    rowset->AddParam(MTPARAM_COLUMN_NAME_COLUMN_VALUE, vtParam, vtValue);
    
    vtParam = wstrWhereClause.c_str();
    rowset->AddParam(MTPARAM_WHERE_CLAUSE, vtParam);
    
    langRequest = rowset->GetQueryString();
  }
  catch (_com_error& e)
  {
    langRequest = L"";
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
				  "Unable to get __UPDATE_ACCOUNT_DATA__ query");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  return (TRUE);
}

// -------------------------------------------------------------------------
// @mfunc GenerateGetDataQuery
// @parm
// @rdesc Get the ddl information
// the 5 key pieces of information that are reqd. are
// 1) table name suffix
// 2) column names
// 3) datatype
// 4) length, if varchar or char
// 5) in_required field for figuring out if it should be NULL or NOT NULL
BOOL
AccountDefCreator::GenerateGetDataQuery(CMSIXDefinition & arDef,
                                        long arAccountID, wstring& langRequest)
{
  const char* procName = "AccountDefCreator::GenerateGetDataQuery";
  
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
  wstring wstrInputs;
  
  // Build the inner string
  BOOL bFirstTime = FALSE;
  
	MSIXPropertiesList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXProperties * prop = *it;
    if (bFirstTime == TRUE)
      wstrInputs += L", ";
    
    // create the inputs to query string
    wstrInputs += prop->GetColumnName();
    bFirstTime = TRUE;
  }
  
  // generate the Create Table query
  _bstr_t queryTag;
  _variant_t vtParam;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    
    if (0 == _wcsicmp(arDef.GetName().c_str(), L"metratech.com/internal"))
      queryTag = "__GET_INTERNAL_ACCOUNT_DATA__";
    else
      queryTag = "__GET_ACCOUNT_DATA__";

    rowset->SetQueryTag(queryTag);
    
    vtParam = wstrInputs.c_str();
    rowset->AddParam(MTPARAM_COLUMN_NAMES, vtParam);
    
    vtParam = arDef.GetTableName().c_str();
    rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
    
    vtParam = arAccountID;
    rowset->AddParam(MTPARAM_ACCOUNT_ID, vtParam);
    
    langRequest = rowset->GetQueryString();
  }
  catch (_com_error& e)
  {
    langRequest = L"";
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
				  "Unable to get __GET_ACCOUNT_DATA__ query");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  return (TRUE);
}

// -------------------------------------------------------------------------
// @mfunc GenerateDropTableQuery
// @parm
// @rdesc Get the ddl information
// the 5 key pieces of information that are reqd. are
// 1) table name suffix
// 2) column names
// 3) datatype
// 4) length, if varchar or char
// 5) in_required field for figuring out if it should be NULL or NOT NULL
// The language request should look something like this:
// IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = object_id('dbo.
// %%PRODUCT_VIEW_NAME%%_%%TABLE_SUFFIX%%') and sysstat & 0xf = 3) 
// DROP TABLE dbo.%%PRODUCT_VIEW_NAME%%_%%TABLE_SUFFIX%%
BOOL
AccountDefCreator::GenerateDropTableQuery(CMSIXDefinition & arDef,
                                          wstring& langRequest)
{
  const char* procName = "AccountDefCreator::GenerateDropTableQuery";
  
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
  // generate the Create Table query
  _bstr_t queryTag;
  _variant_t vtParam;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    rowset->SetQueryTag( "__DROP_ACCOUNT_VIEW_TABLE__");
    
    vtParam = arDef.GetTableName().c_str();
    rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
    
    langRequest = rowset->GetQueryString();
  }
  catch (_com_error& e)
  {
    langRequest = L"";
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
				  "Unable to get _DROP_ACCOUNT_VIEW_TABLE__ query");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  return (TRUE);
}

// -------------------------------------------------------------------------
// @mfunc GenerateDropInsertStoredProcQuery
// @parm
// @rdesc Get the ddl information
// the 5 key pieces of information that are reqd. are
// 1) table name suffix
// 2) column names
// 3) datatype
// 4) length, if varchar or char
// 5) in_required field for figuring out if it should be NULL or NOT NULL
// The language request should look something like this:
// IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = object_id('dbo.
// Insert_%%ACCOUNT_VIEW_NAME%%') and sysstat & 0xf = 3) 
// DROP TABLE dbo.Insert_%%ACCOUNT_VIEW_NAME%%
BOOL
AccountDefCreator::GenerateDropInsertStoredProcQuery(CMSIXDefinition & arDef,
                                                     wstring& langRequest)
{
  const char* procName = "AccountDefCreator::GenerateDropInsertStoredProcQuery";
  
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
  // generate the Create Table query
  _bstr_t queryTag;
  _variant_t vtParam;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    rowset->SetQueryTag("__DROP_INSERT_PROC__");
    
    vtParam = arDef.GetTableName().c_str();
    rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
    
    langRequest = rowset->GetQueryString();
  }
  catch (_com_error& e)
  {
    langRequest = L"";
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
				  "Unable to get _DROP_ACCOUNT_VIEW_TABLE__ query");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  return (TRUE);
}

// -------------------------------------------------------------------------
// @mfunc GenerateDropUpdateStoredProcQuery
// @parm
// @rdesc Get the ddl information
// the 5 key pieces of information that are reqd. are
// 1) table name suffix
// 2) column names
// 3) datatype
// 4) length, if varchar or char
// 5) in_required field for figuring out if it should be NULL or NOT NULL
// The language request should look something like this:
// IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = object_id('dbo.
// Insert_%%ACCOUNT_VIEW_NAME%%') and sysstat & 0xf = 3) 
// DROP TABLE dbo.Insert_%%ACCOUNT_VIEW_NAME%%
BOOL
AccountDefCreator::GenerateDropUpdateStoredProcQuery(CMSIXDefinition & arDef,
                                                     wstring& langRequest)
{
  const char* procName = "AccountDefCreator::GenerateDropUpdateStoredProcQuery";
  
  MSIXPropertiesList list = arDef.GetMSIXPropertiesList();
  
  // generate the Create Table query
  _bstr_t queryTag;
  _variant_t vtParam;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init((wchar_t *)configPath);
    rowset->SetQueryTag("__DROP_UPDATE_PROC__");

    vtParam = arDef.GetTableName().c_str();
    rowset->AddParam(MTPARAM_ACCOUNT_VIEW_NAME, vtParam);
    
    langRequest = rowset->GetQueryString();
  }
  catch (_com_error& e)
  {
    langRequest = L"";
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
				  "Unable to get _DROP_ACCOUNT_VIEW_TABLE__ query");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  return (TRUE);
}

