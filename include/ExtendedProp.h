#ifndef _EXTENDEDPROPTABLE_H
#define _EXTENDEDPROPTABLE_H

#include <DynamicTable.h>
#include <msixdefcollection.h>


class ExtendedPropCreator : public DynamicTableCreator
{
public:
	BOOL haveBackup;

	BOOL Init();

	BOOL SetupDatabase(CMSIXDefinition & arDef);
	BOOL MergeDatabase(CMSIXDefinition & arDef, const wchar_t* pColumnList, const wchar_t* pDefaultStr, const wchar_t* delimiter);
	BOOL CleanupDatabase(CMSIXDefinition & arDef, const wchar_t * apTableName = NULL);
	BOOL BackupDatabase(CMSIXDefinition & arDef, const wchar_t * apTableName = NULL);
}; 


class ExtendedPropCollection : public MSIXDefCollection
{
public:
	BOOL Init(const wchar_t * apFilename = NULL);


	BOOL CreateTables();

	BOOL MergeTables(const wchar_t* pColumnList, const wchar_t* pDefaultStr, const wchar_t* delimiter);

	BOOL DropTables(const wchar_t * apTableName = NULL);

	BOOL BackupTables(const wchar_t * apTableName = NULL);

	// alreadyExists flag should be TRUE if the checksum exists in the database
	// and should be updated, or FALSE if it should be created
	BOOL UpdateChecksums(BOOL aAlreadyExists = TRUE);
	BOOL InsertDefaults(const wchar_t* pColumnList,const wchar_t* pDefaultStr);


private:
	BOOL DropTable(const wchar_t * apTableName);

	ExtendedPropCreator mCreator;
};



#endif /* _EXTENDEDPROPTABLE_H */
