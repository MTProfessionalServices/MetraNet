// OdbcColumnMetadata.cpp: implementation of the COdbcColumnMetadata class.
//
//////////////////////////////////////////////////////////////////////
#pragma warning( disable : 4786 ) 

//#include "bcp.h"
#include <metra.h>
#include <SqlUcode.h>
#include "OdbcColumnMetadata.h"
#include "OdbcException.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

COdbcParameterMetadata::COdbcParameterMetadata(OdbcSqlDatatype aDataType,
																							 int ordinalPosition, 
																							 bool isNullable, 
																							 int precision, 
																							 int decimalDigits, 
																							 int columnSize,
																							 int precisionRadix)
	:
	mOdbcDataType(aDataType),
	mOrdinalPosition(ordinalPosition),
	mIsNullable(isNullable == SQL_NULLABLE ? true : false),
	mPrecision(precision),
	mDecimalDigits(decimalDigits), 
	mColumnSize(columnSize),
	mPrecisionRadix(precisionRadix)
{ }

COdbcParameterMetadata::COdbcParameterMetadata(SQLSMALLINT odbcDataType, 
																							 SQLINTEGER ordinalPosition, 
																							 SQLSMALLINT isNullable, 
																							 SQLINTEGER precision, 
																							 SQLSMALLINT decimalDigits, 
																							 SQLINTEGER columnSize,
																							 int precisionRadix)
	:
mOrdinalPosition(ordinalPosition),
mIsNullable(isNullable == SQL_NULLABLE ? true : false),
mPrecision(precision),
mDecimalDigits(decimalDigits), 
mColumnSize(columnSize),
mPrecisionRadix(precisionRadix)
{
	// Convert to enum
	switch(odbcDataType)
	{
	case SQL_INTEGER:
		mOdbcDataType = eInteger;
		break;
	case SQL_BIGINT:
		mOdbcDataType = eBigInteger;
		break;
	case SQL_TIMESTAMP:
	case SQL_TYPE_TIMESTAMP:
	case SQL_DATETIME:
		mOdbcDataType = eDatetime;
		break;
	case SQL_NUMERIC:
	case SQL_DECIMAL:
		// Oracle uses NUMBER for everything. If it's really a 10
		// digit integer, treat it as an integer.  If its 20 digits treat
    // as bigint otherwise treat as decimal.
		if (decimalDigits == 0 && precision <= 10)
			mOdbcDataType = eInteger;
		else if (decimalDigits == 0 && precision <= 20)
      mOdbcDataType = eBigInteger;
    else
			mOdbcDataType = eDecimal;
		break;
	case SQL_DOUBLE:
	case SQL_FLOAT:
	case SQL_REAL:
    mOdbcDataType = eDouble;
		break;
	case SQL_CHAR:
	case SQL_VARCHAR:
	case SQL_LONGVARCHAR:  // TEXT
		mOdbcDataType = eString;
		break;
	case SQL_BINARY:
	case SQL_VARBINARY:
		mOdbcDataType = eBinary;
		break;
	case SQL_WCHAR:
	case SQL_WVARCHAR:
	case SQL_WLONGVARCHAR:
		mOdbcDataType = eWideString;
		break;
	default:
	{
		mOdbcDataType = eInvalid;
		char buf [256];
		sprintf(buf, "Unsupported ODBC data type: %d", (long)odbcDataType);
		throw COdbcException(buf);
		break;
	}
	}
}

COdbcParameterMetadata::~COdbcParameterMetadata()
{
	// All pointers in mAllColumns will be freed
}

int COdbcParameterMetadata::GetColumnSize() const
{
	return mColumnSize;
}

int COdbcParameterMetadata::GetDecimalDigits() const
{
	return mDecimalDigits;
}

int COdbcParameterMetadata::GetPrecision() const
{
	return mPrecision;
}

bool COdbcParameterMetadata::IsNullable() const
{
	return mIsNullable;
}

int COdbcParameterMetadata::GetOrdinalPosition() const
{
	return mOrdinalPosition;
}

OdbcSqlDatatype COdbcParameterMetadata::GetDataType() const
{
	return mOdbcDataType;
}

int  COdbcParameterMetadata::GetPrecisionRadix() const
{
	return mPrecisionRadix;
}


COdbcColumnMetadata::COdbcColumnMetadata(SQLSMALLINT odbcDataType, 
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
																				 const SQLCHAR* tableName) 
	:
	COdbcParameterMetadata(odbcDataType, ordinalPosition, isNullable, precision, decimalDigits, columnSize, precisionRadix),
mDefaultValue((const char *)defaultValue),
mDefaultBufferLength(defaultBufferLength),
mTypeName((const char *)typeName), 
mColumnName((const char *)columnName), 
mTableName((const char *)tableName)
{
}

COdbcColumnMetadata::COdbcColumnMetadata(OdbcSqlDatatype aDataType,
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
																				 bool)
	: COdbcParameterMetadata(aDataType, ordinalPosition,
													 isNullable, precision, decimalDigits,
													 columnSize, precisionRadix),
	mDefaultValue((const char *)defaultValue),
	mDefaultBufferLength(defaultBufferLength),
	mTypeName((const char *)typeName), 
	mColumnName((const char *)columnName), 
	mTableName((const char *)tableName)
{ 
}

COdbcColumnMetadata::~COdbcColumnMetadata()
{
	// All pointers in mAllColumns will be freed
}

const string& COdbcColumnMetadata::GetTableName() const
{
	return mTableName;
}

const string& COdbcColumnMetadata::GetColumnName() const
{
	return mColumnName;
}

const string& COdbcColumnMetadata::GetTypeName() const
{
	return mTypeName;
}

int COdbcColumnMetadata::GetDefaultBufferLength() const
{
	return mDefaultBufferLength;
}

const string& COdbcColumnMetadata::GetDefaultValue() const
{
	return mDefaultValue;
}  

string COdbcColumnMetadata::GetSQLServerDDL() const 
{ 	
	string ddl(GetColumnName()); 	
	ddl += " ";  	
	switch (mOdbcDataType) 	
	{ 	
	  case eString: 	
	  { 		
		  char buf[256]; 		
		  sprintf(buf, "%s(%d)", GetTypeName().c_str(), GetColumnSize()); 		
		  ddl += buf; 	
	  } 		
	  break;

	  case eDecimal: 	
	  { 		
		  char buf[256]; 		
		  sprintf(buf, "%s(%d, %d)", GetTypeName().c_str(), GetPrecision(), GetDecimalDigits()); 		
		  ddl += buf; 	
	  } 		
	  break; 	

	  case eInteger: 		
	  case eBigInteger: 		
    case eDouble: 		
    {
   		// Oracle uses NUMBER for everything. If it's really a 10
  		// digit integer, treat it as an integer.  Otherwise bigints 
	  	// and non-integers are treated as decimal.
   		if (GetDecimalDigits() == 0 && GetPrecision() <= 10
          && _stricmp(GetTypeName().c_str(), "DECIMAL") == 0) // ODBC returns "DECIMAL"
      {
        char buf[256]; 		
		    sprintf(buf, "%s(%d, %d)", GetTypeName().c_str(), GetPrecision(), GetDecimalDigits()); 		
		    ddl += buf; 	
      }
      else
		    ddl += GetTypeName(); 		
    }
	  break;

	  case eDatetime: 		
		  ddl += GetTypeName(); 		
		  break; 	
	  case eBinary: 	
	  { 		
		  char buf[256]; 		
		  sprintf(buf, "%s(%d)", GetTypeName().c_str(), GetColumnSize()); 		
		  ddl += buf; 	
	  } 		
	  break; 	

	  case eWideString: 	
	  { 		
		  char buf[256]; 		
		  sprintf(buf, "%s(%d)", GetTypeName().c_str(), GetColumnSize()); 		
		  ddl += buf; 	
	  } 		
	  break; 	
	}  	

	if (IsNullable()) 	
	{ 		
		ddl += " NULL"; 	
	} 	
	else 	
	{ 		
		ddl += " NOT NULL"; 	
	} 	
	return ddl; 
}
