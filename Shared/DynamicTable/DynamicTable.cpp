/**************************************************************************
 * DYNAMICTABLE
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
#include <DynamicTable.h>
#include <mtcomerr.h>

#include <SharedDefs.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>

#include <DBAccess.h>

// for debugging
#include <iostream>
using namespace std;

// import the query adapter tlb
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace
#import <MetraTech.DataAccess.tlb> //inject_statement("using namespace mscorlib;")

char gDynamicTableLogTitle[] = "DynamicTable";

#define DYNAMIC_TABLE_QUERY_PATH L"\\Queries\\DynamicTable"

#define MTPARAM_DDL L"%%DDL%%"
#define MTPARAM_TABLE_NAME L"%%TABLE_NAME%%"
#define MTPARAM_BACKUP_TABLE_NAME L"%%BACKUP_TABLE_NAME%%"
#define MTPARAM_PK_NAME L"%%PK_NAME%%"
#define MTPARAM_PRIMARY_KEYS L"%%PRIMARY_KEYS%%"
#define MTPARAM_DDL_INNARDS L"%%DDL_INNARDS%%"
#define MTPARAM_FOREIGN_KEYS L"%%FOREIGN_KEYS%%"
#define MTPARAM_UNIQUE_KEYS L"%%UNIQUE_KEYS%%"
#define MTPARAM_TABLE_DESCRIPTION L"%%TABLE_DESCRIPTION%%"
#define MTPARAM_COLUMN_NAME L"%%COLUMN_NAME%%"
#define MTPARAM_COLUMN_DESCRIPTION L"%%COLUMN_DESCRIPTION%%"
#define MTPARAM_CREATE_TABLE_DESCRIPTION L"%%CREATE_TABLE_DESCRIPTION%%"
#define MTPARAM_CREATE_COLUMN_DESCRIPTION L"%%CREATE_COLUMN_DESCRIPTION%%"
#define MTPARAM_COLUMN_LIST L"%%CORE_COLUMN_LIST%%"
#define MTPARAM_QUOTED_COLUMN_LIST L"%%QUOTED_CORE_COLUMN_LIST%%"
#define MTPARAM_COLUMN_DEFAULT_NAMES L"%%COLUMN_DEFAULT_NAMES%%"
#define MTPARAM_COLUMN_DEFAULT_VALUES L"%%COLUMN_DEFAULT_VALUES%%"
#define MTPARAM_COLUMN_DEFAULT_DELIMITER L"%%COLUMN_DEFAULT_DELIMITER%%"

#define QUERY_TAG_EXEC_DDL L"__EXEC_DDL_DYNAMIC_TABLE__"
#define QUERY_TAG_DROP_TABLE L"__DROP_DYNAMIC_TABLE__"
#define QUERY_TAG_BACKUP_TABLE L"__BACKUP_DYNAMIC_TABLE__"
#define QUERY_TAG_CREATE_TABLE L"__CREATE_DYNAMIC_TABLE__"
#define QUERY_TAG_MERGE_TABLE L"__MERGE_DYNAMIC_TABLE__"
#define QUERY_TAG_CREATE_TABLE_DESCRIPTION L"__CREATE_DYNAMIC_TABLE_DESCRIPTION__"
#define QUERY_TAG_CREATE_COLUMN_DESCRIPTION L"__CREATE_DYNAMIC_COLUMN_DESCRIPTION__"

DynamicTableCreator::DynamicTableCreator()
	: mpQueryAdapter(NULL),
		mInitialized(FALSE)
{ }

DynamicTableCreator::~DynamicTableCreator()
{
	if (mpQueryAdapter != NULL)
	{
		mpQueryAdapter->Release();
		mpQueryAdapter = NULL;
	}
}

// -------------------------------------------------------------------------
// Description: Initialize the object.  Doesn't initialize again if called twice
// -------------------------------------------------------------------------
BOOL DynamicTableCreator::Init()
{
	const char * functionName = "DynamicTableCreator::Initialize";

	if (mInitialized)
		return TRUE;

	try
	{
		mCollection.Initialize();

		if (mpQueryAdapter)
		{
			mpQueryAdapter->Release();
			mpQueryAdapter = NULL;
		}

		// create the queryadapter
		IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);

		// initialize
		queryAdapter->Init(DYNAMIC_TABLE_QUERY_PATH);

		// extract and detach the interface ptr ...
		mpQueryAdapter = queryAdapter.Detach();
		_bstr_t dbtype = mpQueryAdapter->GetDBType() ;

		// oracle database?
		mIsOracle = (mtwcscasecmp(dbtype, ORACLE_DATABASE_TYPE) == 0);
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Unable to initialize dynamic table creator", err);
		SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
		/// TODO: log here?
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}
  
	mInitialized = TRUE;

	return TRUE;
}

// -------------------------------------------------------------------------
// Description: read a product view style file
// -------------------------------------------------------------------------

CMSIXDefinition * DynamicTableCreator::ReadDefFile(const char * apFilename)
{
	return mCollection.ReadDefFile(mCollection, apFilename, NULL);
}

// -------------------------------------------------------------------------
// Description: Create a query to generate a table, given a description.
// -------------------------------------------------------------------------

// CREATE TABLE %%TABLE_NAME%%
//    (%%DDL_INNARDS%%,
//       CONSTRAINT PK_%%TABLE_NAME%% PRIMARY KEY CLUSTERED (%%PRIMARY_KEYS%%)
//	       %%FOREIGN_KEYS%%)
BOOL DynamicTableCreator::AddColumnToQuery(
	const CMSIXProperties & arProp,
	std::wstring & arDDL,
	std::wstring & arForeignKeys,
	std::wstring & arKeyColumns,
  bool bConvertInternalTypes /*= true */)
{
	const char * functionName = "DynamicTableCreator::AddColumnToQuery";

	BOOL firstTime = (arDDL.length() == 0);

	if (!firstTime)
	{
		// newline is to make it more readable
		arDDL += L", \n";
	}
		
	// check to see if this property needs to be part of the key
	if (VARIANT_TRUE == arProp.GetPartOfKey())
	{
		if (arKeyColumns.length() > 0)
			arKeyColumns += L", ";
		arKeyColumns += arProp.GetColumnName();
	}

	// check to see if this property should be a foreign key
	if (arProp.GetReferenceTable().length() != 0)
	{
		// make sure the the user also specified the column name in the forign table
		if (arProp.GetRefColumn().length() == 0)
		{
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR,
							 ERROR_MODULE, ERROR_LINE, functionName,
							 "foreign column name not specified");
			return FALSE;
		}

		// generate the constraint
		arForeignKeys += L", ";
		arForeignKeys += L"FOREIGN KEY (";
		arForeignKeys += arProp.GetColumnName();
		arForeignKeys += L") REFERENCES ";
		arForeignKeys += arProp.GetReferenceTable();
		arForeignKeys += L" (";
		arForeignKeys += arProp.GetRefColumn();
		arForeignKeys += L")";
	}


	std::wstring dataType = arProp.GetDataType();

	// handle enum types
	if (bConvertInternalTypes && mtwcscasecmp(dataType.c_str(), W_DB_ENUM_STR) == 0)
		dataType = W_DB_INT_STR;

	if (bConvertInternalTypes && IsOracle())
	{
		if (mtwcscasecmp(dataType.c_str(), W_DB_DATETIME_STR) == 0)
			// datetime --> date
			dataType = W_DB_DATETIME_STR_ORACLE;
		else if ((mtwcscasecmp(dataType.c_str(), W_DB_NVARCHAR_STR) == 0) ||
	   			(0 == mtwcscasecmp(dataType.c_str(), W_DB_VARCHAR_STR)) )
			// nvarchar --> nvarchar2
			// varchar --> varchar2
			dataType = W_DB_NVARCHAR_STR_ORACLE;
	  else if (mtwcscasecmp(dataType.c_str(), W_DB_ENUM_STR) == 0)
      // int --> number(10)
			dataType = W_DB_INT_STR_ORACLE;
		else if (mtwcscasecmp(dataType.c_str(), W_DB_INT_STR) == 0)
			// int --> number(10) 
			dataType = W_DB_INT_STR_ORACLE;
		else if (mtwcscasecmp(dataType.c_str(), W_DB_BIGINT_STR) == 0)
			// bigint --> number(20)
			dataType = W_DB_BIGINT_STR_ORACLE;
	}

	arDDL += arProp.GetColumnName();
	arDDL += L" ";

	//set datatype to always be wide strings
	if(bConvertInternalTypes && 0 == mtwcscasecmp(dataType.c_str(), W_DB_VARCHAR_STR) )
	{
		if (!IsOracle())
			dataType = std::wstring(W_DB_NVARCHAR_STR);
	}
	//else if (0 == mtwcscasecmp(dataType.c_str(), W_DB_CHAR_STR) )
	//	dataType = std::wstring(W_DB_NCHAR_STR);

	arDDL += dataType;
	arDDL += L" ";

		// varchar or char
	if ((0 == mtwcscasecmp(dataType.c_str(), W_DB_VARCHAR_STR))
			|| (0 == mtwcscasecmp(dataType.c_str(), W_DB_CHAR_STR))
			|| (0 == mtwcscasecmp(dataType.c_str(), W_DB_NCHAR_STR))
			|| (0 == mtwcscasecmp(dataType.c_str(), W_DB_NVARCHAR_STR))
			|| (0 == mtwcscasecmp(dataType.c_str(), W_DB_NVARCHAR_STR_ORACLE)))
	{
		wchar_t tempNum[50]; // is that max enough

		long length = arProp.GetLength();
		arDDL += L"(";
		arDDL += _itow(length, tempNum, 10);
		arDDL += L") ";
	}

	// nullable?
	arDDL += arProp.GetRequiredConstraint();
	return TRUE;
}

// GENERATE SQL QUERY FOR CREATING TABLE DESCRIPTION
std::wstring DynamicTableCreator::GenerateTableDescriptionQuery(const wchar_t * apTableName, const wchar_t * tableDescription)
{
  const char * functionName = "DynamicTableCreator::GenerateTableDescriptionQuery";
  std::wstring result = L"";

  mpQueryAdapter->ClearQuery();
  mpQueryAdapter->SetQueryTag(QUERY_TAG_CREATE_TABLE_DESCRIPTION);

  _variant_t vtParam = apTableName;
  mpQueryAdapter->AddParam(MTPARAM_TABLE_NAME, vtParam);

  vtParam = tableDescription;
  mpQueryAdapter->AddParam(MTPARAM_TABLE_DESCRIPTION, vtParam);

  vtParam = mpQueryAdapter->GetQuery();  
  mpQueryAdapter->ClearQuery();
  mpQueryAdapter->SetQueryTag(QUERY_TAG_EXEC_DDL);
    
  _variant_t dontValidate = true;
  if(mIsOracle)
  {
	mpQueryAdapter->AddParam(MTPARAM_DDL, vtParam);
  }
  else
  {
	mpQueryAdapter->AddParam(MTPARAM_DDL, vtParam, dontValidate);
  }
  
  result = mpQueryAdapter->GetQuery();
  mpQueryAdapter->ClearQuery();

  return result;
}

// GENERATE SQL QUERY FOR CREATING COLUMN DESCRIPTION
std::wstring DynamicTableCreator::GenerateColumnDescriptionQuery(const wchar_t * apTableName, const CMSIXProperties & arProp)
{
  const char * functionName = "DynamicTableCreator::GenerateColumnDescriptionQuery";
  std::wstring result = L"";
  if (arProp.GetDescription().c_str() != NULL && arProp.GetDescription().length() > 0)
  //if (arProp.GetDescription().length() > 0)
  {
    mpQueryAdapter->ClearQuery();
    mpQueryAdapter->SetQueryTag(QUERY_TAG_CREATE_COLUMN_DESCRIPTION);

    _variant_t vtParam = apTableName;
    mpQueryAdapter->AddParam(MTPARAM_TABLE_NAME, vtParam);
	vtParam = arProp.GetColumnName().c_str();
    mpQueryAdapter->AddParam(MTPARAM_COLUMN_NAME, vtParam);
	vtParam = arProp.GetDescription().c_str();
    mpQueryAdapter->AddParam(MTPARAM_COLUMN_DESCRIPTION, vtParam);	

    vtParam = mpQueryAdapter->GetQuery();  
    mpQueryAdapter->ClearQuery();
    mpQueryAdapter->SetQueryTag(QUERY_TAG_EXEC_DDL);
	
	_variant_t dontValidate = true;
	if(mIsOracle)
	{
		mpQueryAdapter->AddParam(MTPARAM_DDL, vtParam);
	}
	else
	{
		mpQueryAdapter->AddParam(MTPARAM_DDL, vtParam, dontValidate);
	}
  
	result = mpQueryAdapter->GetQuery();
    mpQueryAdapter->ClearQuery();
  }
  return result;
}

BOOL DynamicTableCreator::GenerateCreateTableQuery(
	std::wstring & arQuery,
	CMSIXDefinition & arDef,
	std::vector<CMSIXProperties> * apAdditionalColumns /* = NULL */,
	const wchar_t * apTableName /* = NULL */,
  bool bConvertInternalTypes /* = true */)
{
	const char * functionName = "DynamicTableCreator::GenerateCreateTableQuery";

  // db name hasher
  MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));

  // ddl component clauses
	std::wstring ddl = L"";
	std::wstring foreignKeys = L"";
	std::wstring keyColumns = L"";
	std::wstring uniqueKeys = L"";
  std::wstring tableDescription = L"";
  std::wstring columnDescription = L"";

	// first time through don't add a comma
	BOOL firstTime = TRUE;

	// first step through any additional columns (like
	// primary keys, etc) that aren't included in the
	// definition itself
	if (apAdditionalColumns)
	{
		std::vector<CMSIXProperties>::const_iterator additionalit;
		for (additionalit = apAdditionalColumns->begin();
			additionalit != apAdditionalColumns->end();
			++additionalit)
		{
			const CMSIXProperties & prop = *additionalit;
			if (!AddColumnToQuery(prop, ddl, foreignKeys, keyColumns, bConvertInternalTypes))
				return FALSE;

			columnDescription += GenerateColumnDescriptionQuery(apTableName, prop);
			columnDescription += L"\n";
		}
	}

	// now add the columns from the definition
	//
	MSIXPropertiesList props = arDef.GetMSIXPropertiesList();
	MSIXPropertiesList::iterator it;
	for (it = props.begin(); it != props.end(); ++it)
	{
		CMSIXProperties * prop = *it;

		if (!AddColumnToQuery(*prop, ddl, foreignKeys, keyColumns, bConvertInternalTypes))
			return FALSE;

		columnDescription += GenerateColumnDescriptionQuery(apTableName, *prop);
		columnDescription += L"\n";
	}
	
	// Add unique key clauses
	//
	UniqueKeyList& ukList = arDef.GetUniqueKeyList();
   
	// foreach unique key...
	int i = 1;
	UniqueKeyList::iterator uk;  
	for ( uk = ukList.begin(); uk != ukList.end(); uk++ )
	{
		// start of unique cons clause
		uniqueKeys += L", ";
		if (mIsOracle)
         uniqueKeys += L"constraint " + (*uk)->GetName() + L" unique " + L"(";
		else
         uniqueKeys += L"constraint " + (*uk)->GetName() + L" unique nonclustered" + L"(";

		// foreach column in the unique key, build a csv list and add to clause
		vector<CMSIXProperties *> cols = (*uk)->GetColumnProperties();
		vector<CMSIXProperties *>::iterator col;
		std::wstring csv;
		for ( col = cols.begin(); col != cols.end(); col++ ) 
		{
			csv += (*col)->GetColumnName();
			if (col != (cols.end()-1))
				csv += L",";
		}
		
		// close the unique cons clause
		uniqueKeys += csv + L")\n";
	}

#if 0
/*		
		if (!firstTime)
		{
			// newline is to make it more readable
			ddl += L", \n";
		}
		
		// check to see if this property needs to be part of the key
		if (VARIANT_TRUE == prop->GetPartOfKey())
		{
			if (keyColumns.length() > 0)
				keyColumns += L", ";
		  keyColumns += prop->GetColumnName();
		}

		// check to see if this property should be a foreign key
		if (prop->GetReferenceTable().length() != 0)
		{
			// make sure the the user also specified the column name in the forign table
			if (prop->GetRefColumn().length() == 0)
			{
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR,
								 ERROR_MODULE, ERROR_LINE, functionName,
								 "foreign column name not specified");
				return FALSE;
			}

			// generate the constraint
			foreignKeys += L", ";
			foreignKeys += L"FOREIGN KEY (";
			foreignKeys += prop->GetColumnName();
			foreignKeys += L") REFERENCES ";
			foreignKeys += prop->GetReferenceTable();
			foreignKeys += L" (";
			foreignKeys += prop->GetRefColumn();
			foreignKeys += L")";
		}


		std::wstring dataType = prop->GetDataType();

		if (IsOracle())
		{
			// oracle treats date time values differently
			if (mtwcscasecmp(dataType.c_str(), W_DB_DATETIME_STR) == 0)
				dataType = W_DB_DATETIME_STR_ORACLE;
			else if (mtwcscasecmp(dataType.c_str(), W_DB_NVARCHAR_STR) == 0)
				dataType = W_DB_NVARCHAR_STR_ORACLE;
		}

		// handle enum types
		if (mtwcscasecmp(dataType.c_str(), W_DB_ENUM_STR) == 0)
		  dataType = W_DB_INT_STR;

		ddl += prop->GetColumnName();
		ddl += L" ";

		ddl += dataType;
		ddl += L" ";

		// varchar or char
		if ((0 == mtwcscasecmp(dataType.c_str(), W_DB_VARCHAR_STR))
				|| (0 == mtwcscasecmp(dataType.c_str(), W_DB_CHAR_STR))
				|| (0 == mtwcscasecmp(dataType.c_str(), W_DB_NCHAR_STR))
				|| (0 == mtwcscasecmp(dataType.c_str(), W_DB_NVARCHAR_STR))
				|| (0 == mtwcscasecmp(dataType.c_str(), W_DB_NVARCHAR_STR_ORACLE)))
		{
			wchar_t tempNum[50]; // is that max enough

			long length = prop->GetLength();
			ddl += L"(";
			ddl += _itow(length, tempNum, 10);
			ddl += L") ";
		}

		//  nullable?
		ddl += prop->GetRequiredConstraint();

		firstTime = FALSE;
	}
	*/ 
#endif

	// Generate the Create Table query 
	//
	try
	{
		// hash the pk name to comply with 30 char limit
		wstring name(L"pk_");
		name += arDef.GetTableName().c_str();
		wstring hashedname = nameHash->GetDBNameHash(name.c_str());
		wstring createTableDescription = GenerateTableDescriptionQuery(arDef.GetTableName().c_str(), arDef.GetDescription().c_str());  
		
		mpQueryAdapter->ClearQuery();    
		mpQueryAdapter->SetQueryTag(QUERY_TAG_CREATE_TABLE);

		_variant_t vtParam;

		// use the table name passed in if provided
		if (apTableName)
			vtParam = apTableName;
		else
			vtParam = arDef.GetTableName().c_str();

		mpQueryAdapter->AddParam(MTPARAM_TABLE_NAME, vtParam);

		vtParam = ddl.c_str();
		mpQueryAdapter->AddParam(MTPARAM_DDL_INNARDS, vtParam);


    vtParam = hashedname.c_str();
		mpQueryAdapter->AddParam(MTPARAM_PK_NAME, vtParam);
    
    vtParam = keyColumns.c_str();
		mpQueryAdapter->AddParam(MTPARAM_PRIMARY_KEYS, vtParam);

		vtParam = foreignKeys.c_str();
		mpQueryAdapter->AddParam(MTPARAM_FOREIGN_KEYS, vtParam);

		vtParam = uniqueKeys.c_str();
		mpQueryAdapter->AddParam(MTPARAM_UNIQUE_KEYS, vtParam);
		
		_variant_t dontValidate = true;
		vtParam = createTableDescription.c_str();
		mpQueryAdapter->AddParam(MTPARAM_CREATE_TABLE_DESCRIPTION, vtParam, dontValidate);

		vtParam = (L"\n" + columnDescription).c_str();  
		mpQueryAdapter->AddParam(MTPARAM_CREATE_COLUMN_DESCRIPTION, vtParam, dontValidate);

		arQuery = mpQueryAdapter->GetQuery();    
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Unable to generate create table query", err);
		SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
		/// TODO: log here?
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}

	return TRUE;
}

BOOL DynamicTableCreator::GenerateMergeTableQuery(
	std::wstring & arQuery,
	CMSIXDefinition & arDef,
	std::vector<CMSIXProperties> * apAdditionalColumns,
	const wchar_t * apTableName,
	const wchar_t * apBackupTableName,
	const wchar_t * pColumnList,
	const wchar_t * pDefaultStr,
	const wchar_t * delimiter)
{
	const char * functionName = "DynamicTableCreator::GenerateMergeTableQuery";
	std::wstring columnList = L"";
	std::wstring quotedColumnList = L"";

	// first time through don't add a comma
	BOOL firstTime = TRUE;

	// Step through any additional columns (primary keys, etc) that aren't included in the
	// definition itself
	if (apAdditionalColumns)
	{
		std::vector<CMSIXProperties>::const_iterator additionalit;
		for (additionalit = apAdditionalColumns->begin();
			additionalit != apAdditionalColumns->end();
			++additionalit)
		{
			const CMSIXProperties & prop = *additionalit;
			if (firstTime) {
				firstTime = FALSE;
			} else {
				columnList += L",";
				quotedColumnList += L",";
			}
			columnList += prop.GetColumnName();
			quotedColumnList += L"'" + prop.GetColumnName() + L"'";
		}
	}
	StrToLower(quotedColumnList);

	try
	{
		mpQueryAdapter->ClearQuery();    
		mpQueryAdapter->SetQueryTag(QUERY_TAG_MERGE_TABLE);

		_variant_t vtParam;

		// use the table name passed in if provided
		if (apTableName)
			vtParam = apTableName;
		else
			vtParam = arDef.GetTableName().c_str();
		mpQueryAdapter->AddParam(MTPARAM_TABLE_NAME, vtParam);

		if (apBackupTableName)
			vtParam = apBackupTableName;
		else
			vtParam = arDef.GetBackupTableName().c_str();
		mpQueryAdapter->AddParam(MTPARAM_BACKUP_TABLE_NAME, vtParam);

		vtParam = columnList.c_str();
		mpQueryAdapter->AddParam(MTPARAM_COLUMN_LIST, vtParam);

		vtParam = quotedColumnList.c_str();
		mpQueryAdapter->AddParam(MTPARAM_QUOTED_COLUMN_LIST, vtParam, VARIANT_TRUE);

		vtParam = pColumnList;
		mpQueryAdapter->AddParam(MTPARAM_COLUMN_DEFAULT_NAMES, vtParam);

		vtParam = pDefaultStr;
		mpQueryAdapter->AddParam(MTPARAM_COLUMN_DEFAULT_VALUES, vtParam);

		vtParam = delimiter;
		mpQueryAdapter->AddParam(MTPARAM_COLUMN_DEFAULT_DELIMITER, vtParam);

		arQuery = mpQueryAdapter->GetQuery();
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Unable to generate merge table query", err);
		SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
		/// TODO: log here?
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}

	return TRUE;
}

// -------------------------------------------------------------------------
// Description: Generate the query to drop a table
// -------------------------------------------------------------------------

BOOL DynamicTableCreator::GenerateDropTableQuery(std::wstring & arQuery,
																								 CMSIXDefinition & arDef,
																								 const wchar_t * apTableName /* = NULL */)
{
	const char * functionName = "DynamicTableCreator::GenerateDropTableQuery";

/// log here

// IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = object_id(
// 'dbo.%%TABLE_NAME%%')) DROP TABLE 
// dbo.%%TABLE_NAME%%

	try
	{
		mpQueryAdapter->ClearQuery();
		mpQueryAdapter->SetQueryTag(QUERY_TAG_DROP_TABLE);

		// use the table name passed in if provided
		_variant_t vtParam;
		if (apTableName)
			vtParam = apTableName;
		else
			vtParam = arDef.GetTableName().c_str();

		mpQueryAdapter->AddParam(MTPARAM_TABLE_NAME, vtParam);

		arQuery = mpQueryAdapter->GetQuery();
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Unable to generate drop table query", err);
		SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
		/// TODO: log here?
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}

	return TRUE;
}

// -------------------------------------------------------------------------
// Description: Generate the query to backup a table
// -------------------------------------------------------------------------
BOOL DynamicTableCreator::GenerateBackupTableQuery(std::wstring & arQuery,
																								   CMSIXDefinition & arDef,
																								   const wchar_t * apTableName /* = NULL */,
																								   const wchar_t * apBackupTableName /* = NULL */)
{
	const char * functionName = "DynamicTableCreator::GenerateBackupTableQuery";

	// IF EXISTS (SELECT * FROM SYSOBJECTS WHERE id = object_id('dbo.%%TABLE_NAME%%'))
	// SELECT * INTO dbo.%%BACKUP_TABLE_NAME%% FROM dbo.%%TABLE_NAME%%

	try
	{
		mpQueryAdapter->ClearQuery();
		mpQueryAdapter->SetQueryTag(QUERY_TAG_BACKUP_TABLE);

		// use the table names passed in if provided
		_variant_t vtParam;
		if (apTableName)
			vtParam = apTableName;
		else
			vtParam = arDef.GetTableName().c_str();
		mpQueryAdapter->AddParam(MTPARAM_TABLE_NAME, vtParam);

		_variant_t vtParamB;
		if (apBackupTableName)
			vtParamB = apBackupTableName;
		else
			vtParamB = arDef.GetBackupTableName().c_str();
		mpQueryAdapter->AddParam(MTPARAM_BACKUP_TABLE_NAME, vtParamB);

		arQuery = mpQueryAdapter->GetQuery();
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Unable to generate backup table query", err);
		SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
		/// TODO: log here?
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}

	return TRUE;
}

// -------------------------------------------------------------------------
// Description: Create a table
// -------------------------------------------------------------------------
BOOL
DynamicTableCreator::CreateTable(
	CMSIXDefinition & arDef,
	std::vector<CMSIXProperties> * apAdditionalColumns /* = NULL */,
	const wchar_t * apTableName /* = NULL */)
{
  // create the ddl string
	std::wstring query;

	if (!apTableName)
		apTableName = arDef.GetTableName().c_str();
  

	// log
///	mLogger.LogVarArgs(LOG_INFO, "Creating table <%s>", 
///										 (const char*) _bstr_t(GetTableName()));

  if (!GenerateCreateTableQuery(query, arDef, apAdditionalColumns, apTableName))
    return FALSE;
  
  // execute the query
	return ExecuteQuery(DYNAMIC_TABLE_QUERY_PATH, query.c_str());
}

// -------------------------------------------------------------------------
// Description: Merge data from a backup table into the main table
// -------------------------------------------------------------------------
BOOL
DynamicTableCreator::MergeTable(
	CMSIXDefinition & arDef,
	std::vector<CMSIXProperties> * apAdditionalColumns,
  const wchar_t* pColumnList,
  const wchar_t* pDefaultStr,
  const wchar_t* delimiter)
{
  std::wstring query;

  if (arDef.GetTableName().empty())
    return FALSE;
  const wchar_t* apTableName = arDef.GetTableName().c_str();
  if (arDef.GetBackupTableName().empty())
    return FALSE;
  const wchar_t* apBackupTableName = arDef.GetBackupTableName().c_str();

  if (!GenerateMergeTableQuery(query, arDef, apAdditionalColumns, apTableName, apBackupTableName, pColumnList, pDefaultStr, delimiter))
    return FALSE;

  if (!ExecuteQuery(DYNAMIC_TABLE_QUERY_PATH, query.c_str()))
    return FALSE;

  // Drop the backup table now that we're done with it
  if (!GenerateDropTableQuery(query, arDef, apBackupTableName))
    return FALSE;

  return ExecuteQuery(DYNAMIC_TABLE_QUERY_PATH, query.c_str());
}

// -------------------------------------------------------------------------
// Description: Drop a table
// -------------------------------------------------------------------------
BOOL DynamicTableCreator::DropTable(CMSIXDefinition & arDef,
																		const wchar_t * apTableName /* = NULL */)
{
  // create the ddl string
	std::wstring query;

	if (!apTableName)
		apTableName = arDef.GetTableName().c_str();

	// log
///	mLogger.LogVarArgs(LOG_INFO, "Dropping table <%s>", 
///										 (const char*) _bstr_t(GetTableName()));

  if (!GenerateDropTableQuery(query, arDef, apTableName))
    return FALSE;
  
  // execute the query
	return ExecuteQuery(DYNAMIC_TABLE_QUERY_PATH, query.c_str());
}

// -------------------------------------------------------------------------
// Description: Backup the data in a table before we drop it
// -------------------------------------------------------------------------
BOOL
DynamicTableCreator::BackupTable(CMSIXDefinition & arDef, const wchar_t * apTableName /* = NULL */)
{
  const wchar_t *apBackupTableName;
  std::wstring query;

  if (!apTableName)
    apTableName = arDef.GetTableName().c_str();
  if (arDef.GetBackupTableName().empty())
    return FALSE;
  apBackupTableName = arDef.GetBackupTableName().c_str();

  if (!GenerateBackupTableQuery(query, arDef, apTableName, apBackupTableName))
    return FALSE;

  return ExecuteQuery(DYNAMIC_TABLE_QUERY_PATH, query.c_str());
}

// -------------------------------------------------------------------------
// Description: Execute a query
// -------------------------------------------------------------------------
BOOL DynamicTableCreator::ExecuteQuery(const wstring & arConfigPath, const wstring & arQuery)
{
	DBAccess dbAccess;
	BOOL success = TRUE;

	// initialize the database context
	if (!dbAccess.Init(arConfigPath))
	{
		SetError(dbAccess.GetLastError());
		mLogger->LogThis(LOG_ERROR, "Database initialization failed");
		success = FALSE;
	}

	if (success)
	{
		if (!dbAccess.Execute(arQuery))
		{
			SetError(dbAccess.GetLastError());
			mLogger->LogThis(LOG_ERROR, "Database execution failed");
			success = FALSE;
		}

		// always disconnect from the database
		if (!dbAccess.Disconnect())
		{
			SetError(dbAccess.GetLastError());
			mLogger->LogThis(LOG_ERROR, "Database disconnect failed");
			success = FALSE;
		}
	}

	return success;
}
