// OdbcMetadata.cpp: implementation of the COdbcMetadata class.
//
//////////////////////////////////////////////////////////////////////
#pragma warning( disable : 4786 ) 

//#include "bcp.h"
#include <metra.h>
#include <MTUtil.h>
#include <stdutils.h>
#include "OdbcMetadata.h"

/*
#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif
*/

#include "OdbcConnection.h"
#include "OdbcException.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

COdbcMetadata::COdbcMetadata(COdbcConnection* aConnection) :
	mConnection(aConnection)
{

}

COdbcMetadata::~COdbcMetadata()
{
	for(unsigned int i=0; i<mAllColumns.size(); i++)
	{
		COdbcColumnMetadata* tmp = mAllColumns[i];
		mAllColumns[i] = NULL;
		delete tmp;
	}
}

COdbcColumnMetadataVector COdbcMetadata::GetColumnMetadata(const string& arSchema, const string & arTable)
{
	COdbcColumnMetadataVector ret;

	static const int STR_LEN(128+1);
	static const int REM_LEN(254+1);
	/* Declare buffers for result set data */

	SQLCHAR       szCatalog[STR_LEN], szSchema[STR_LEN];
	SQLCHAR       szTableName[STR_LEN], szColumnName[STR_LEN];
	SQLCHAR       szTypeName[STR_LEN], szRemarks[REM_LEN];
	SQLCHAR       szColumnDefault[STR_LEN], szIsNullable[STR_LEN];
	SQLINTEGER    ColumnSize, BufferLength, CharOctetLength, OrdinalPosition;
	SQLSMALLINT   DataType, DecimalDigits, NumPrecRadix, Nullable;
	SQLSMALLINT   SQLDataType, DatetimeSubtypeCode;
	SQLHSTMT      hStmt;

	/* Declare buffers for bytes available to return */

	SQLINTEGER cbCatalog, cbSchema, cbTableName, cbColumnName;
	SQLINTEGER cbDataType, cbTypeName, cbColumnSize, cbBufferLength;
	SQLINTEGER cbDecimalDigits, cbNumPrecRadix, cbNullable, cbRemarks;
	SQLINTEGER cbColumnDefault, cbSQLDataType, cbDatetimeSubtypeCode, cbCharOctetLength;
	SQLINTEGER cbOrdinalPosition, cbIsNullable;

	SQLRETURN sqlReturn;

	BOOL isOracle = (mConnection->GetConnectionInfo().GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);

	std::string table;
	std::string schema;
	if (!isOracle)
	{
		mConnection->SetSchema(arSchema);
		table = arTable;
	}
	else
	{
		table = arTable;
		StrToUpper(table);
      schema = arSchema;
		StrToUpper(schema);
	}

	sqlReturn = ::SQLAllocHandle(SQL_HANDLE_STMT, mConnection->GetHandle(), &hStmt);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcConnectionException(mConnection->GetHandle());

	if (!isOracle)
	{
		// on SQL Server, temporary table (local and global) really exist in
		// TEMPDB.  in this case we override the schema
		const char * schemaptr;
		if (table.length() > 0 && table[0] == '#')
			schemaptr = "TEMPDB";
		else
			schemaptr = arSchema.c_str();

		sqlReturn = ::SQLColumnsA(hStmt, 
															(SQLCHAR*)schemaptr, SQL_NTS, 
															(SQLCHAR*)"dbo", SQL_NTS,
															(SQLCHAR*)table.c_str(), SQL_NTS, 
															NULL, 0);
	}
	else
	{
		sqlReturn = ::SQLColumnsA(hStmt, 
															NULL, 0,
															(SQLCHAR*)schema.c_str(), SQL_NTS, 
															(SQLCHAR*)table.c_str(), SQL_NTS, 
															NULL, 0);
	}

	if (sqlReturn == SQL_SUCCESS || sqlReturn == SQL_SUCCESS_WITH_INFO) {

	   /* Bind columns in result set to buffers */
		::SQLBindCol(hStmt, 1, SQL_C_CHAR, szCatalog, STR_LEN,&cbCatalog);
		::SQLBindCol(hStmt, 2, SQL_C_CHAR, szSchema, STR_LEN, &cbSchema);
		::SQLBindCol(hStmt, 3, SQL_C_CHAR, szTableName, STR_LEN,&cbTableName);
		::SQLBindCol(hStmt, 4, SQL_C_CHAR, szColumnName, STR_LEN, &cbColumnName);
		::SQLBindCol(hStmt, 5, SQL_C_SSHORT, &DataType, 0, &cbDataType);
		::SQLBindCol(hStmt, 6, SQL_C_CHAR, szTypeName, STR_LEN, &cbTypeName);
		::SQLBindCol(hStmt, 7, SQL_C_SLONG, &ColumnSize, 0, &cbColumnSize);
		::SQLBindCol(hStmt, 8, SQL_C_SLONG, &BufferLength, 0, &cbBufferLength);
		::SQLBindCol(hStmt, 9, SQL_C_SSHORT, &DecimalDigits, 0, &cbDecimalDigits);
		::SQLBindCol(hStmt, 10, SQL_C_SSHORT, &NumPrecRadix, 0, &cbNumPrecRadix);
		::SQLBindCol(hStmt, 11, SQL_C_SSHORT, &Nullable, 0, &cbNullable);
		::SQLBindCol(hStmt, 12, SQL_C_CHAR, szRemarks, REM_LEN, &cbRemarks);
		::SQLBindCol(hStmt, 13, SQL_C_CHAR, szColumnDefault, STR_LEN, &cbColumnDefault);
		::SQLBindCol(hStmt, 14, SQL_C_SSHORT, &SQLDataType, 0, &cbSQLDataType);
		::SQLBindCol(hStmt, 15, SQL_C_SSHORT, &DatetimeSubtypeCode, 0,
		  &cbDatetimeSubtypeCode);
		::SQLBindCol(hStmt, 16, SQL_C_SLONG, &CharOctetLength, 0, &cbCharOctetLength);
		::SQLBindCol(hStmt, 17, SQL_C_SLONG, &OrdinalPosition, 0, &cbOrdinalPosition);
		::SQLBindCol(hStmt, 18, SQL_C_CHAR, szIsNullable, STR_LEN, &cbIsNullable);
		while(TRUE) {
			sqlReturn = ::SQLFetch(hStmt);
			if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO && sqlReturn != SQL_NO_DATA) throw COdbcStatementException(hStmt);
			if (sqlReturn == SQL_SUCCESS || sqlReturn == SQL_SUCCESS_WITH_INFO){

//#define MT_USE_ORACLE9

#ifdef MT_USE_ORACLE9
				if (isOracle)
				{
					if (SQLDataType == SQL_WCHAR)
						SQLDataType = SQL_CHAR;
					else if (SQLDataType == SQL_WVARCHAR)
						SQLDataType = SQL_VARCHAR;
				}
#endif
				SQLINTEGER Precision=0;
				if (cbNumPrecRadix  > 0)
        {
					Precision = ColumnSize;
          ColumnSize = 0;
        }
				else
					NumPrecRadix = 0;

				// oracle will return SQL_CHAR or SQL_VARCHAR even when
				// the column type is NVARCHAR2.  We have to handle this case ourselves.
				
				//BP 8/3/2004: This doesn't seem to be an issue with Oracle 10 driver.
				//Leave it in place because it doesn't hurt
				if (SQLDataType == SQL_CHAR)
				{
					if (0 == strcmp((const char *) szTypeName, "NCHAR"))
						SQLDataType = SQL_WCHAR;
				}
				if (SQLDataType == SQL_VARCHAR)
				{
					if (0 == strcmp((const char *) szTypeName, "NVARCHAR2"))
						SQLDataType = SQL_WVARCHAR;
				}

				COdbcColumnMetadata *col = new COdbcColumnMetadata(
					SQLDataType, 
					OrdinalPosition, 
					cbColumnDefault>0 ? szColumnDefault : (SQLCHAR*)"",
					Nullable, 
					Precision, 
					cbDecimalDigits>0 ? DecimalDigits : 0, 
					BufferLength,
					ColumnSize,
					NumPrecRadix, 
					cbTypeName > 0 ? szTypeName : (SQLCHAR*)"", 
					cbColumnName > 0 ? szColumnName : (SQLCHAR*)"", 
					cbTableName > 0 ? szTableName : (SQLCHAR*)"");
					mAllColumns.push_back(col);
					ret.push_back(col);
			} else {
				break;
			}
	   }
	}

	::SQLFreeHandle(SQL_HANDLE_STMT, hStmt);
	return ret;
}
