/**************************************************************************
 * PARAMTABLE
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

#include <ParamTable.h>
#include <stdutils.h>

#define TABLE_PREFIX L"t_pt_"

using namespace std;

/************************************** ParamTableCollection ***/

BOOL ParamTableCollection::Init(const wchar_t * apFilename /* = NULL */)
{
	const char * functionName = "ParamTableCollection::Init";

	BOOL retVal;
	
	const wchar_t * dirName = L"ParamTable";
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


	//
	// post initialization
	//

	// can reinit twice
	if (!mCreator.Init())
	{
		SetError(mCreator);
		return FALSE;
	}

	list <CMSIXDefinition *>::iterator it;
	for ( it = GetDefList().begin(); it != GetDefList().end(); it++ )
	{
		CMSIXDefinition * def = *it;

		if (!Setup(*def))
			return FALSE;

		//if (!Validate(def))
		//  return FALSE;
	}

	return retVal;
}

BOOL ParamTableCollection::Setup(CMSIXDefinition & arDef)
{
	const char * functionName = "ParamTableCollection::Setup";

	arDef.CalculateTableName(TABLE_PREFIX);

	// compute the checksum by running MD5 on the SQL statement to create the table.
	// this doesn't change if things like whitespace change in the config file
	std::wstring query;
	if (!mCreator.GenerateCreateTableQuery(query, arDef, false))
	{
		SetError(mCreator);
		return FALSE;
	}
	
	std::string asciiQuery = ascii(query);
	std::string rwChecksum;
	if (!MTMiscUtil::ConvertStringToMD5(asciiQuery.c_str(), rwChecksum))
	{
		// should never fail
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to compute MD5 checksum");
		return FALSE;
	}

	// finally set the checksum
	arDef.SetChecksum(rwChecksum.c_str());

	return TRUE;
}

// make a pass through the definition
// 
#if 0
BOOL ParamTableCollection::MakeColumnsUnique(CMSIXDefinition & arDef)
{
	std::map<std::wstring> columnNames;


}
#endif

BOOL ParamTableCollection::CreateTables()
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
		// create the table
		if (!mCreator.SetupDatabase(*(*it)))
		{
			SetError(mCreator);
			return FALSE;
		}
	}

	return TRUE;
}

BOOL ParamTableCollection::DropTables()
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
		// create the table
		if (!mCreator.CleanupDatabase(*(*it)))
		{
			SetError(mCreator);
			return FALSE;
		}
	}

	return TRUE;
}


/***************************************** ParamTableCreator ***/



BOOL ParamTableCreator::Init()
{
	return DynamicTableCreator::Init();
}

BOOL ParamTableCreator::SetupDatabase(CMSIXDefinition & arDef)
{
	arDef.CalculateTableName(TABLE_PREFIX);

	std::vector<CMSIXProperties> additionalColumns;

	// add the primary key
	CMSIXProperties id;
	id.SetDN(L"id_sched");
	id.SetIsRequired(TRUE);
	id.SetPartOfKey(VARIANT_TRUE);
	id.SetPropertyType(CMSIXProperties::TYPE_INT32);
	id.SetDataType(L"int");
	id.SetColumnName(L"id_sched");
	/*id.SetReferenceTable(L"t_rsched");
	id.SetRefColumn(L"id_sched");*/
	additionalColumns.push_back(id);


	// add the order values
	CMSIXProperties order;
	order.SetDN(L"n_order");
	order.SetIsRequired(TRUE);
	order.SetPartOfKey(VARIANT_TRUE);
	order.SetPropertyType(CMSIXProperties::TYPE_INT32);
	order.SetDataType(L"int");
	order.SetColumnName(L"n_order");
	additionalColumns.push_back(order);

  // add the effective date values
	CMSIXProperties tt_start;
	tt_start.SetDN(L"tt_start");
	tt_start.SetIsRequired(TRUE);
	tt_start.SetPartOfKey(VARIANT_FALSE);
	tt_start.SetPropertyType(CMSIXProperties::TYPE_TIMESTAMP);
	tt_start.SetDataType(L"datetime");
	tt_start.SetColumnName(L"tt_start");
	additionalColumns.push_back(tt_start);

	CMSIXProperties tt_end;
	tt_end.SetDN(L"tt_end");
	tt_end.SetIsRequired(TRUE);
	tt_end.SetPartOfKey(VARIANT_FALSE);
	tt_end.SetPropertyType(CMSIXProperties::TYPE_TIMESTAMP);
	tt_end.SetDataType(L"datetime");
	tt_end.SetColumnName(L"tt_end");
	additionalColumns.push_back(tt_end);

	// add the audit id for rate changes
	CMSIXProperties audit;
	audit.SetDN(L"id_audit");
	audit.SetIsRequired(TRUE);
	audit.SetPartOfKey(VARIANT_TRUE);
	audit.SetPropertyType(CMSIXProperties::TYPE_INT32);
	audit.SetDataType(L"int");
	audit.SetColumnName(L"id_audit");
	additionalColumns.push_back(audit);

	return CreateTable(arDef, &additionalColumns);
}

BOOL ParamTableCreator::CleanupDatabase(CMSIXDefinition & arDef, const wchar_t * apTableName /*=NULL*/)
{
	arDef.CalculateTableName(TABLE_PREFIX);
	return DropTable(arDef, apTableName);
}
