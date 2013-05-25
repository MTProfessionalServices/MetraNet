/**************************************************************************
* @doc PRODUCTVIEWDEFCREATOR
*
* Copyright 2000 by MetraTech Corporation
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
#include <ProductViewDefCreator.h>
#include <ProductViewCollection.h>

#include <loggerconfig.h>
#include <SharedDefs.h>
#include <mtparamnames.h>
#include <mtprogids.h>

#include <stdutils.h>
#include <propids.h>
#include <OdbcConnMan.h>
#include <OdbcStagingTable.h>
#include <OdbcConnection.h>
#include <OdbcStatement.h>
#include <MTUtil.h>

typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;

// import the query adapter tlb
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

const wchar_t* PRODUCTVIEW_QUERY_PATH = L"\\Queries\\ProductView";


//	@mfunc
//	Constructor. Initialize the data members.
//	@rdesc
//	No return value
ProductViewDefCreator::ProductViewDefCreator() :
mpQueryAdapter(NULL),
mInitialized(FALSE)
{	
	// initialize the logger ...
	LoggerConfigReader cfgRdr;
	mLogger.Init (cfgRdr.ReadConfiguration(PRODUCT_VIEW_STR),
		PRODUCT_VIEW_TAG);
}

//	@mfunc
//	Destructor
//	@rdesc
//	No return value
ProductViewDefCreator::~ProductViewDefCreator()
{
	if (mpQueryAdapter != NULL)
	{
		mpQueryAdapter->Release();
		mpQueryAdapter = NULL;
	}

	mInitialized = FALSE;
}

// @mfunc Initialize
// @parm
// @rdesc This function is responsible for initializing the object
// Returns true or false depending on whether the function succeeded or not.  
BOOL 
ProductViewDefCreator::Initialize()
{
	BOOL bOK = TRUE;

	// check to see if the object is initialized.  IF so, then just return
	// TRUE, else initialize it
	if (mInitialized == TRUE)
	{
		return (TRUE) ;
	}

	// initialize the base class
	if (!Init())
		return FALSE;

	const char* procName = "ProductViewDefCreator::Initialize";

	// if we dont have a pointer to the query adapter 
	if (mpQueryAdapter == NULL)
	{
		// instantiate a query adapter object second
		try
		{
			// create the queryadapter ...
			IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);

			// initialize the queryadapter ...
			queryAdapter->Init(PRODUCTVIEW_QUERY_PATH);

			// extract and detach the interface ptr ...
			mpQueryAdapter = queryAdapter.Detach();

			// get the database type ...
			//   _bstr_t dbtype = mpQueryAdapter->GetDBType() ;
			// mDBType = (wchar_t*) dbtype ;
		}
		catch (_com_error e)
		{
			SetError(e.Error(), ERROR_MODULE, ERROR_LINE, procName,
				"Unable to initialize query adapter");
			mLogger.LogErrorObject (LOG_ERROR, GetLastError());
			bOK = FALSE;
		}
	}

	mInitialized = TRUE;

	return (bOK); 
}


//
// product view setup
//

// get the product view's key columns
void ProductViewDefCreator::GetKeyColumns(std::vector<CMSIXProperties> &keycols)
{
	// add the primary key
	CMSIXProperties id;
	id.SetDN(L"id_sess");
	id.SetIsRequired(TRUE);
	id.SetPartOfKey(VARIANT_TRUE);
	id.SetPropertyType(CMSIXProperties::TYPE_INT32);
	id.SetDataType(L"bigint");
	id.SetColumnName(L"id_sess");
  id.SetDescription(L"Required column. Unique ID for the session.");
	keycols.push_back(id);

	// add the usage interval column to support partitioning
	id.SetDN(L"id_usage_interval");
	id.SetIsRequired(TRUE);
	id.SetPartOfKey(VARIANT_TRUE);
	id.SetPropertyType(CMSIXProperties::TYPE_INT32);
	id.SetDataType(L"int");
	id.SetColumnName(L"id_usage_interval");
  id.SetDescription(L"Required column. Identifier for usage interval. Associated with t_usage_interval(id_interval) table. It's a partition column for usage partitioning.");
	keycols.push_back(id);  

}

// add the table and sprocs to the database for this product view
BOOL ProductViewDefCreator::SetupDatabase (CMSIXDefinition & arDef)
{
	std::vector<CMSIXProperties> additionalColumns;
	GetKeyColumns(additionalColumns);

	/* Moved this duplicated code to GetKeyColumns

	// add the primary key
	CMSIXProperties id;
	id.SetDN(L"id_sess");
	id.SetIsRequired(TRUE);
	id.SetPartOfKey(VARIANT_TRUE);
	id.SetPropertyType(CMSIXProperties::TYPE_INT32);
	id.SetDataType(L"int");
	id.SetColumnName(L"id_sess");

	// NOTE: the following two lines will create a foreign key to t_acc_usage.
	//       however, this creates a large performance overhead (especially when attempting
	//       to delete from t_acc_usage) and has been removed.
	//id.SetReferenceTable(L"t_acc_usage");
	//id.SetRefColumn(L"id_sess");
	additionalColumns.push_back(id);
	** end move dup code */

	// override the table name 
	std::wstring tableName(arDef.GetTableName());

	if (!CreateTable(arDef, &additionalColumns, tableName.c_str()))
		return FALSE;

	if (!CreateStagingTable(arDef))
	{
		// NOTE: we don't return an error here
	}

	return TRUE;
}


// @mfunc InsertIntoPVLog
// @parm
// @rdesc
BOOL
ProductViewDefCreator::InsertIntoPVLog (CMSIXDefinition & arDef)
{
	wstring langRequest; 
#if 0
	// create the ddl string
	langRequest = L"insert into t_product_view_log values (";
	langRequest += L"N'";
	langRequest += arDef.GetName();
	langRequest += L"', 1, '";

	wstring wstrChecksum = _bstr_t(arDef.GetChecksum());
	langRequest += wstrChecksum;
	langRequest += L"')";;
#else
	// get the insert into product view log query ...
	GenerateInsertIntoPVLogQuery (arDef.GetName(), arDef.GetChecksum(), langRequest) ;
#endif

	// execute the language request
	return ExecuteQuery(PRODUCTVIEW_QUERY_PATH, langRequest);
}

// @mfunc GenerateInsertIntoPVLogQuery
// @parm
// @rdesc
BOOL
ProductViewDefCreator::GenerateInsertIntoPVLogQuery (const wstring & arProductViewName, 
																	  const string & arChecksum,
																	  wstring & arlangRequest)
{
	try
	{
		// generate the query
		_bstr_t queryString;
		_variant_t vtParam;

		mpQueryAdapter->ClearQuery();
		mpQueryAdapter->SetQueryTag(L"__INSERT_INTO_PV_LOG__");

		vtParam = arProductViewName.c_str();
		mpQueryAdapter->AddParam(MTPARAM_PV_NAME, vtParam);

		vtParam = arChecksum.c_str();
		mpQueryAdapter->AddParam(MTPARAM_PV_CHECKSUM, vtParam);

		arlangRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error e)
	{
		SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
			"ProductViewDefCreator::GenerateInsertIntoPVLogQuery",
			"Unable to generate insert into product view log query");
		return FALSE;
	}

	return (TRUE);
}


// @mfunc UpdatePVLog
// @parm
// @rdesc
BOOL
ProductViewDefCreator::UpdatePVLog (const char* arProductViewName,
												const char* arChecksum)
{
	// create the ddl string
	wstring langRequest; 
#if 0
	langRequest = L"update t_product_view_log set tx_checksum = '";
	wstring wstrChecksum = _bstr_t(arChecksum);
	langRequest += wstrChecksum;
	langRequest += L"', id_revision = id_revision + 1 where nm_product_view = '";;
	langRequest += _bstr_t(arProductViewName);
	langRequest += L"'";
#else
	// get the update product view log query ...
	GenerateUpdatePVLogQuery (arProductViewName, arChecksum, langRequest) ;
#endif

	// execute the language request
	return ExecuteQuery(PRODUCTVIEW_QUERY_PATH, langRequest);
}

// @mfunc UpdatePVLog
// @parm
// @rdesc
BOOL
ProductViewDefCreator::GenerateUpdatePVLogQuery(const char * arProductViewName, 
																const char * arChecksum, 
																wstring & arlangRequest)
{
	try
	{
		// generate the query
		_bstr_t queryString;
		_variant_t vtParam;

		mpQueryAdapter->ClearQuery();
		mpQueryAdapter->SetQueryTag(L"__UPDATE_PV_LOG__");

		vtParam = arProductViewName ;
		mpQueryAdapter->AddParam(MTPARAM_PV_NAME, vtParam);

		vtParam = arChecksum;
		mpQueryAdapter->AddParam(MTPARAM_PV_CHECKSUM, vtParam);

		arlangRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error e)
	{
		SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
			"ProductViewDefCreator::GenerateUpdatePVLogQuery",
			"Unable to generate update product view log query");
		return FALSE;
	}

	return (TRUE);
}


// @mfunc DeleteFromPVLog
// @parm
// @rdesc
BOOL
ProductViewDefCreator::DeleteFromPVLog (CMSIXDefinition & arDef)
{
	// create the ddl string
	wstring langRequest; 
#if 0
	langRequest = L"delete from t_product_view_log where nm_product_view = N'";
	langRequest += arDef.GetName();
	langRequest += L"'";
#else
	// get the update product view log query ...
	GenerateDeleteFromPVLogQuery (arDef.GetName(), langRequest) ;
#endif
	// execute the language request
	return ExecuteQuery(PRODUCTVIEW_QUERY_PATH, langRequest);
}

// @mfunc DeleteFromPVLog
// @parm
// @rdesc
BOOL
ProductViewDefCreator::GenerateDeleteFromPVLogQuery(const wstring & arProductViewName,
																	 wstring & arlangRequest)
{
	try
	{
		// generate the query
		_bstr_t queryString;
		_variant_t vtParam;

		mpQueryAdapter->ClearQuery();
		mpQueryAdapter->SetQueryTag(L"__DELETE_FROM_PV_LOG__");

		vtParam = arProductViewName.c_str();
		mpQueryAdapter->AddParam(MTPARAM_PV_NAME, vtParam);

		arlangRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error e)
	{
		SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
			"ProductViewDefCreator::GenerateDeleteFromPVLogQuery",
			"Unable to generate delete product view log query");
		return FALSE;
	}

	return (TRUE);
}

BOOL ProductViewDefCreator::GenerateCreateTableQuery(CMSIXDefinition & arDef, 
      																               wstring & langRequest,
                                                     bool bConvertInternalTypes /* = true */)
{
	std::vector<CMSIXProperties> additionalColumns;
	GetKeyColumns(additionalColumns);

	/* moved this duplicated code to GetKeyColumns
	// add the primary key
	CMSIXProperties id;
	id.SetDN(L"id_sess");
	id.SetIsRequired(TRUE);
	id.SetPartOfKey(VARIANT_TRUE);
	id.SetPropertyType(CMSIXProperties::TYPE_INT32);
	id.SetDataType(L"int");
	id.SetColumnName(L"id_sess");
	id.SetReferenceTable(L"t_acc_usage");
	id.SetRefColumn(L"id_sess");
	additionalColumns.push_back(id);
	** end move dup code */

	// override the table name
	std::wstring tableName(arDef.GetTableName());

	std::wstring buffer;
	if (!DynamicTableCreator::GenerateCreateTableQuery(buffer, arDef, &additionalColumns,
		                                                 tableName.c_str(), bConvertInternalTypes))
		return FALSE;

	langRequest = buffer.c_str();
	return TRUE;
}

//
// product view removal
//

// @mfunc DropTable
// @parm
// @rdesc

// drop the table and sprocs for this product view
BOOL ProductViewDefCreator::CleanupDatabase (CMSIXDefinition & arDef)
{
	std::wstring tableName(arDef.GetTableName());
	BOOL success = TRUE;

	if (!DropStagingTable(arDef))
	{
		mLogger.LogThis(LOG_DEBUG, "Unable to drop staging database table");
		// NOTE: we don't set success = false
	}

	if (!DropTable(arDef, tableName.c_str()))
	{
		mLogger.LogThis(LOG_ERROR, "Unable to drop product view table");
		success = FALSE;
	}

	return success;
}

BOOL ProductViewDefCreator::CreateStagingTable(CMSIXDefinition & arDef)
{
  string tableName = string(ascii(arDef.GetTableName()));

  COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
  COdbcConnectionPtr conn = new COdbcConnection(info);

	COdbcStagingTable table(conn, tableName, "");

  string ddl = table.GetCreateStageTableQuery();
  wstring wddl;
  ASCIIToWide(wddl, ddl);
  return ExecuteQuery(L"\\Queries\\DynamicTable", wddl);
}

BOOL ProductViewDefCreator::DropStagingTable(CMSIXDefinition & arDef)
{
	try
	{
		COdbcConnectionInfo netmeterInfo = COdbcConnectionManager::GetConnectionInfo("NetMeter");

		COdbcConnectionInfo stageEntry =
			COdbcConnectionManager::GetConnectionInfo("NetMeterStage");

		COdbcConnectionInfo stageInfo(netmeterInfo);
		stageInfo.SetCatalog(stageEntry.GetCatalog().c_str());

		COdbcConnectionPtr stageConnection = new COdbcConnection(stageInfo);

		string tableName = ascii(arDef.GetTableName());

		string drop = "IF EXISTS (select * from sysobjects where name = '"
			+ tableName + "') DROP TABLE " + tableName;

		COdbcStatementPtr createTempTable = stageConnection->CreateStatement();
		createTempTable->ExecuteUpdate(drop);
		stageConnection->CommitTransaction();
	}
	catch(COdbcException& ex)
	{
		mLogger.LogVarArgs(LOG_DEBUG, "Unable to drop database table: %s",
			ex.what());

		SetError (E_FAIL, ERROR_MODULE, ERROR_LINE, 
			ex.what());
		return FALSE;
	}

	return TRUE;
}
