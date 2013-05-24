/**************************************************************************
 * @doc PRODUCTVIEWDEFCREATOR
 *
 * @module |
 *
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
 *
 * @index | PRODUCTVIEWDEFCREATOR
 ***************************************************************************/

#ifndef _PRODUCTVIEWDEFCREATOR_H
#define _PRODUCTVIEWDEFCREATOR_H

#include <MSIXDefinition.h>
#include <DynamicTable.h>

#include <string>
using std::string;
using std::wstring;

class ProductViewDefCreator : public DynamicTableCreator
{
private:
	ProductViewDefCreator(const ProductViewDefCreator &c);
	ProductViewDefCreator& operator=(const ProductViewDefCreator& rhs);

public:
	ProductViewDefCreator();
	virtual ~ProductViewDefCreator();

	// @cmember Initialize the Product View Definition object
	BOOL Initialize ();

	// add the table and sprocs to the database for this product view
	BOOL SetupDatabase (CMSIXDefinition & arDef);

	// drop the table and sprocs for this product view
	BOOL CleanupDatabase (CMSIXDefinition & arDef);

	// method to create ddl (needed by usage server)
	BOOL GenerateCreateTableQuery(CMSIXDefinition & arDef, wstring & langRequest, bool bConvertInternalTypes = true);

	// method to create stored procedures used to insert into the product views
	BOOL InsertIntoPVLog(CMSIXDefinition & arDef);

	// method to create stored procedures used to insert into the product views
	BOOL UpdatePVLog(const char* arProductViewName, const char* arChecksum);

	// method to create stored procedures used to insert into the product views
	BOOL DeleteFromPVLog(CMSIXDefinition & arDef);

  	// method to create stored procedures used to insert into the product views
	BOOL GenerateInsertIntoPVLogQuery(const wstring &arProductViewName,
																		const string & arChecksum,
																		wstring & arlangRequest);

	// method to create stored procedures used to insert into the product views
	BOOL GenerateUpdatePVLogQuery(const char * arProductViewName,
																const char * arChecksum,
																wstring & arlangRequest);

	// method to create stored procedures used to insert into the product views
	BOOL GenerateDeleteFromPVLogQuery(const wstring & arProductViewName,
																		wstring & arlangRequest);


private:

	// create the staging table
	BOOL CreateStagingTable(CMSIXDefinition & arDef);

	// drop the staging table, if it exists
	BOOL DropStagingTable(CMSIXDefinition & arDef);

	// adds product view key columns to a vector of CMSIXProperties.
	void GetKeyColumns(std::vector<CMSIXProperties> &keycols);

private:
	NTLogger mLogger;

	IMTQueryAdapter* mpQueryAdapter;
	wstring mDBType;

	BOOL mInitialized;
};




#endif /* _PRODUCTVIEWDEFCREATOR_H */
