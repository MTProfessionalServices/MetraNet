/**************************************************************************
 * @doc DYNAMICTABLE
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 * @index | DYNAMICTABLE
 ***************************************************************************/

#ifndef _DYNAMICTABLE_H
#define _DYNAMICTABLE_H

#include <MSIXDefinition.h>
#include <autologger.h>
#include <vector>

#include <msixdefcollection.h>

// forward declaration
struct IMTQueryAdapter;

extern char gDynamicTableLogTitle[];


class DynamicTableCreator : public virtual ObjectWithError
{
public:
	DynamicTableCreator();
	virtual ~DynamicTableCreator();

	BOOL Init();

	BOOL GenerateCreateTableQuery(std::wstring & arQuery,
																CMSIXDefinition & arDef,
																std::vector<CMSIXProperties> * apAdditionalColumns = NULL,
																const wchar_t * apTableName = NULL,
                                bool bConvertInternalTypes = true);

	BOOL GenerateMergeTableQuery(std::wstring & arQuery,
															 CMSIXDefinition & arDef,
															 std::vector<CMSIXProperties> * apAdditionalColumns,
															 const wchar_t * apTableName,
															 const wchar_t * apBackupTableName,
															 const wchar_t* pColumnList,
															 const wchar_t* pDefaultStr,
															 const wchar_t* delimiter);

	BOOL GenerateDropTableQuery(std::wstring & arQuery,
															CMSIXDefinition & arDef,
															const wchar_t * apTableName = NULL);

	BOOL GenerateBackupTableQuery(std::wstring & arQuery,
																CMSIXDefinition & arDef,
																const wchar_t * apTableName = NULL,
																const wchar_t * apBackupTableName = NULL);

	// create the table with the given definition.
	// additional columns can be passed in in the second argument
	BOOL CreateTable(CMSIXDefinition & arDef,
									 std::vector<CMSIXProperties> * apAdditionalColumns = NULL,
									 const wchar_t * apTableName = NULL);

	BOOL MergeTable(CMSIXDefinition & arDef,
									std::vector<CMSIXProperties> * apAdditionalColumns,
									const wchar_t* pColumnList,
									const wchar_t* pDefaultStr,
									const wchar_t* delimiter);

	BOOL DropTable(CMSIXDefinition & arDef,
								 const wchar_t * apTableName = NULL);

	BOOL BackupTable(CMSIXDefinition & arDef,
								   const wchar_t * apTableName = NULL);

	CMSIXDefinition * ReadDefFile(const char * apFilename);

	BOOL IsOracle()
	{ return mIsOracle; }

protected:
	BOOL ExecuteQuery(const std::wstring &arConfigPath, const std::wstring & arQuery);

private:
	BOOL AddColumnToQuery(
		const CMSIXProperties & arProp,
		std::wstring & arDDL,
		std::wstring & arForeignKeys,
		std::wstring & arKeyColumns,
    bool bConvertInternalTypes = true);
	
  std::wstring GenerateTableDescriptionQuery(const wchar_t * apTableName, const wchar_t * tableDescription);
  std::wstring GenerateColumnDescriptionQuery(const wchar_t * apTableName, const CMSIXProperties & arProp);

private:
	IMTQueryAdapter* mpQueryAdapter;

	BOOL mInitialized;

	BOOL mIsOracle;

	MTAutoInstance<MTAutoLoggerImpl<gDynamicTableLogTitle> > mLogger;

	MSIXDefCollection mCollection;
};


#endif /* _DYNAMICTABLE_H */
