// OdbcColumnMetadata.h: interface for the COdbcColumnMetadata class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ODBCCOLUMNMETADATA_H__DB03BFB1_B3FF_41E5_8E54_542A43806683__INCLUDED_)
#define AFX_ODBCCOLUMNMETADATA_H__DB03BFB1_B3FF_41E5_8E54_542A43806683__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#pragma warning( disable : 4251 )

#include <string>
#include <vector> 
using namespace std;

#include <sql.h>
#include <sqlext.h>
#include <sqltypes.h>

enum OdbcSqlDatatype {eInvalid, eInteger, eBigInteger, eString, eDecimal, eDouble, eDatetime, eBinary, eWideString};

// TODO: remove undefs
#if defined(MTODBC_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class DllExport COdbcParameterMetadata
{


protected: 	
	OdbcSqlDatatype mOdbcDataType;
	int mOrdinalPosition;
	bool mIsNullable;
	int mPrecision;
	int mDecimalDigits;
	int mColumnSize;
	int mPrecisionRadix; //radix used for precision and decimal digits, values are 0, 2, or 10

public:
	OdbcSqlDatatype GetDataType() const;
	int GetOrdinalPosition() const;
	bool IsNullable() const;
	int GetPrecision() const;
	int GetDecimalDigits() const;
	int GetColumnSize() const;
	int GetPrecisionRadix() const;
	COdbcParameterMetadata(SQLSMALLINT odbcDataType, 
					SQLINTEGER ordinalPosition, 
					SQLSMALLINT isNullable, 
					SQLINTEGER precision, 
					SQLSMALLINT decimalDigits, 
					SQLINTEGER columnSize,
					int precisionRadix = 0);
	COdbcParameterMetadata(OdbcSqlDatatype aDataType,
												 int ordinalPosition, 
												 bool isNullable, 
												 int precision, 
												 int decimalDigits, 
												 int columnSize,
												 int precisionRadix = 0);
	virtual ~COdbcParameterMetadata();
};

class DllExport COdbcColumnMetadata : public COdbcParameterMetadata
{
private:
	string mDefaultValue;
	int mDefaultBufferLength;
	string mTypeName;
	string mColumnName;
	string mTableName;

public:
	const string& GetDefaultValue() const;
	int GetDefaultBufferLength() const;
	const string& GetTypeName() const;
	const string& GetColumnName() const;
 	// Generate DDL fragment describing the column 	
  // that is appropriate to Microsoft SQL Server 2000 	
	string GetSQLServerDDL() const;  	
	
	const string& GetTableName() const;
	COdbcColumnMetadata(SQLSMALLINT odbcDataType, 
					SQLINTEGER ordinalPosition, 
					const SQLCHAR* defaultValue,
					SQLSMALLINT isNullable, 
					SQLINTEGER precision, 
					SQLSMALLINT decimalDigits, 
					SQLINTEGER defaultBufferLength,
					SQLINTEGER columnSize, 
					int precisionRadix,
					const SQLCHAR* typeName, 
					const SQLCHAR* columnName, 
					const SQLCHAR* tableName);

	COdbcColumnMetadata(OdbcSqlDatatype aDataType,
											int ordinalPosition, 
											const char * defaultValue,
											bool isNullable, 
											int precision, 
											int decimalDigits, 
											SQLINTEGER defaultBufferLength,
											int columnSize,
											int precisionRadix,
											const char * typeName, 
											const char * columnName, 
											const char * tableName,
											// this argument is here only to distinguish this contructor from the previous one
											bool aDummy);

	virtual ~COdbcColumnMetadata();
};

typedef vector<COdbcColumnMetadata*> COdbcColumnMetadataVector;
typedef vector<COdbcColumnMetadata*> COdbcTableMetadata;

#pragma warning( default : 4251 )

#endif // !defined(AFX_ODBCCOLUMNMETADATA_H__DB03BFB1_B3FF_41E5_8E54_542A43806683__INCLUDED_)
