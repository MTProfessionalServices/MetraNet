#include <metra.h>
#include <MTUtil.h>
#include "OdbcStatement.h"
#include "OdbcConnection.h"
#include "OdbcColumnMetadata.h"
#include "OdbcResultSet.h"
#include "OdbcException.h"

COdbcStatementBase::COdbcStatementBase(COdbcConnection* aConnection)
: mpConnection(aConnection)
{
	// Allocate simple garden variety SQL statement handle
	SQLRETURN sqlReturn = ::SQLAllocHandle(SQL_HANDLE_STMT, aConnection->GetHandle(), &mStmt);
	if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) 
	{
		throw COdbcConnectionException(aConnection->GetHandle());
	}
}

COdbcStatementBase::~COdbcStatementBase()
{
	if (mStmt != NULL)
	{
	  // It's not clear why, in Oracle, SQL_HANDLE_STMT throws an exception when a statment
	  // is freed after it's connection.
	  SQLRETURN sqlReturn = ::SQLFreeHandle(SQL_HANDLE_STMT, mStmt);

	  //SQLRETURN sqlReturn = ::SQLFreeHandle(SQL_HANDLE_DESC, mStmt);

	  //BP: Do not ASSERT if SQLFreeHandle failed:
	  //if CODBCConnection object goes out of scope before COdbcStatement object, 
	  //then it will clean up and close the connection before COdbcStatement has
	  //a chance to clear its' STMT, and SQLFreeHandle will return -2 (SQL_INVALID_STATEMENT).
	  //if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)
	  //	ASSERT(0);
	}
}

bool COdbcStatementBase::IsOracle()
{
	return mpConnection->GetConnectionInfo().IsOracle();
}

NTLogger* COdbcStatementBase::GetLogger()
{ 
	if (mpConnection)
		return mpConnection->GetLogger();
	else
		return NULL;
}

void COdbcStatementBase::LogStatementInfo(bool logAsError)
{
	NTLogger* logger = GetLogger();
	if (logger == NULL)
	{	ASSERT(0);
		return;
	}

	//log query
	string msg;
	
	if(logAsError)
		msg += "Error occurred in ";

	msg += "OdbcStatement: ";
	msg += mQuery.c_str();

	logger->LogThis(logAsError ? LOG_ERROR : LOG_DEBUG, msg.c_str());
}

void COdbcStatementBase::LogStatementInfoW(bool logAsError)
{
	NTLogger* logger = GetLogger();
	if (logger == NULL)
	{	ASSERT(0);
		return;
	}

	//log query
	wstring msg;
	
	if(logAsError)
		msg += L"Error occurred in ";

	msg += L"OdbcStatement: ";
	msg += mWideQuery.c_str();

	logger->LogThis(logAsError ? LOG_ERROR : LOG_DEBUG, msg.c_str());
}

COdbcStatement::COdbcStatement(COdbcConnection* aConnection) : COdbcStatementBase(aConnection)
{
}

COdbcStatement::~COdbcStatement()
{
	// Free up any metadata owned by the object
	for(unsigned int i=0; i<mAllMetadata.size(); i++)
	{
		COdbcColumnMetadata* tmp = mAllMetadata[i];
		mAllMetadata[i] = NULL;
		delete tmp;
	}
}

string COdbcStatement::GetColumnStringAttribute(SQLSMALLINT col, SQLUSMALLINT attr)
{
	const int DEFAULT_BUF_LENGTH(256);
	char defaultBuffer[DEFAULT_BUF_LENGTH];
	short bufLength;
	SQLRETURN sqlReturn = ::SQLColAttributeA(mStmt, col, attr, &defaultBuffer[0], DEFAULT_BUF_LENGTH, &bufLength, NULL);
	if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) ProcessError();
	if (bufLength == 0) return string("");

	if (bufLength > DEFAULT_BUF_LENGTH)
	{
		// Looks like there is a very long string, dynamically allocate a buffer and go get it.
		char* buf;
		buf = new char[bufLength+1];
		sqlReturn = ::SQLColAttributeA(mStmt, col, attr, buf, bufLength+1, &bufLength, NULL);
		if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)  ProcessError();
		string val(buf);
		delete [] buf;
		return val;
	}
	else
	{
		return string(defaultBuffer);
	}
}

int COdbcStatement::GetColumnIntegerAttribute(SQLSMALLINT col, SQLUSMALLINT attr)
{
	int val;
	SQLRETURN sqlReturn = ::SQLColAttributeA(mStmt, col, attr, NULL, 0, NULL, &val);
	if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)  ProcessError();
	return val;
}

COdbcResultSet* COdbcStatement::ExecuteQueryW(const wstring& wideQueryString)
{
  COdbcColumnMetadataVector v;

	mWideQuery = wideQueryString;

	SQLRETURN sqlReturn = ::SQLExecDirectW(mStmt, (SQLWCHAR *)wideQueryString.c_str(), SQL_NTS);
		if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)  ProcessErrorW();
	SQLSMALLINT nCols;
	sqlReturn = ::SQLNumResultCols(mStmt, &nCols);
	if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)  ProcessErrorW();
	for (SQLSMALLINT i=1; i<=nCols; i++)
	{
		string columnName = GetColumnStringAttribute(i, SQL_DESC_NAME);
		string tableName = GetColumnStringAttribute(i, SQL_DESC_TABLE_NAME);
		string catalogName = GetColumnStringAttribute(i, SQL_DESC_SCHEMA_NAME);
		int isNullable = GetColumnIntegerAttribute(i, SQL_DESC_NULLABLE);
		int numPrecisionRadix = GetColumnIntegerAttribute(i, SQL_DESC_NUM_PREC_RADIX);
		int precision = GetColumnIntegerAttribute(i, SQL_DESC_PRECISION);
		int scale = GetColumnIntegerAttribute(i, SQL_DESC_SCALE);
		string typeName = GetColumnStringAttribute(i, SQL_DESC_TYPE_NAME);
		int odbcDataType = GetColumnIntegerAttribute(i, SQL_DESC_TYPE);
		int defaultBufferLength = GetColumnIntegerAttribute(i, SQL_DESC_OCTET_LENGTH);
		int columnSize = GetColumnIntegerAttribute(i, SQL_DESC_LENGTH);
		bool hasFixPrecAndScale = GetColumnIntegerAttribute(i, SQL_DESC_FIXED_PREC_SCALE)==SQL_TRUE ? true : false;
		if (hasFixPrecAndScale)
		{
			precision = columnSize;
		}

		COdbcColumnMetadata* metadata = new COdbcColumnMetadata(odbcDataType, 
					i, 
					(SQLCHAR*)"",
					isNullable, 
					precision, 
					scale, 
					defaultBufferLength,
					columnSize,
					numPrecisionRadix,
					(SQLCHAR*)typeName.c_str(), 
					(SQLCHAR*)columnName.c_str(), 
					(SQLCHAR*)tableName.c_str()
			);

		v.push_back(metadata);
		mAllMetadata.push_back(metadata);
	}

	if (IsOracle())
		return new COdbcOracleResultSet(this, v);
	else
		return new COdbcResultSet(this, v);
}

COdbcResultSet* COdbcStatement::ExecuteQuery(const string& queryString)
{
  COdbcColumnMetadataVector v;

	mQuery = queryString;

	SQLRETURN sqlReturn = ::SQLExecDirectA(mStmt, (SQLCHAR *)queryString.c_str(), SQL_NTS);
	if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)  ProcessError();
	SQLSMALLINT nCols;
	sqlReturn = ::SQLNumResultCols(mStmt, &nCols);
	if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)  ProcessError();
	for (SQLSMALLINT i=1; i<=nCols; i++)
	{
		string columnName = GetColumnStringAttribute(i, SQL_DESC_NAME);
		string tableName = GetColumnStringAttribute(i, SQL_DESC_TABLE_NAME);
		string catalogName = GetColumnStringAttribute(i, SQL_DESC_SCHEMA_NAME);
		int isNullable = GetColumnIntegerAttribute(i, SQL_DESC_NULLABLE);
		int numPrecisionRadix = GetColumnIntegerAttribute(i, SQL_DESC_NUM_PREC_RADIX);
		int precision = GetColumnIntegerAttribute(i, SQL_DESC_PRECISION);
		int scale = GetColumnIntegerAttribute(i, SQL_DESC_SCALE);
		string typeName = GetColumnStringAttribute(i, SQL_DESC_TYPE_NAME);
		int odbcDataType = GetColumnIntegerAttribute(i, SQL_DESC_TYPE);
		int defaultBufferLength = GetColumnIntegerAttribute(i, SQL_DESC_OCTET_LENGTH);
		int columnSize = GetColumnIntegerAttribute(i, SQL_DESC_LENGTH);
		bool hasFixPrecAndScale = GetColumnIntegerAttribute(i, SQL_DESC_FIXED_PREC_SCALE)==SQL_TRUE ? true : false;
		if (hasFixPrecAndScale)
		{
			precision = columnSize;
		}

		COdbcColumnMetadata* metadata = new COdbcColumnMetadata(odbcDataType, 
					i, 
					(SQLCHAR*)"",
					isNullable, 
					precision, 
					scale, 
					defaultBufferLength,
					columnSize,
					numPrecisionRadix,
					(SQLCHAR*)typeName.c_str(), 
					(SQLCHAR*)columnName.c_str(), 
					(SQLCHAR*)tableName.c_str()
			);

		v.push_back(metadata);
		mAllMetadata.push_back(metadata);
	}

	if (IsOracle())
		return new COdbcOracleResultSet(this, v);
	else
		return new COdbcResultSet(this, v);
}

int COdbcStatement::ExecuteUpdate(const string& queryString)
{
	mQuery = queryString;

	SQLRETURN sqlReturn = ::SQLExecDirectA(mStmt, (SQLCHAR *)queryString.c_str(), SQL_NTS);
	if (sqlReturn == SQL_NO_DATA)
    return 0;
  else if (sqlReturn == SQL_SUCCESS_WITH_INFO)
    ProcessSuccessWithInfoA();
  else if (sqlReturn == SQL_SUCCESS)
    ProcessSuccessWithInfoA(true);
  else
    ProcessError();

	SQLINTEGER rowCount;
	sqlReturn = ::SQLRowCount(mStmt, &rowCount);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)
    ProcessError();

  // Close any open cursors.
  ::SQLFreeStmt(mStmt, SQL_CLOSE);

  // Return row count.
  return rowCount;
}

int COdbcStatement::ExecuteUpdateW(const wstring& wideQueryString)
{
	mWideQuery = wideQueryString;

	SQLRETURN sqlReturn = ::SQLExecDirectW(mStmt, (SQLWCHAR *)wideQueryString.c_str(), SQL_NTS);
 	if (sqlReturn == SQL_NO_DATA)
    return 0;
  else if (sqlReturn == SQL_SUCCESS_WITH_INFO)
    ProcessSuccessWithInfoW();
  else if (sqlReturn == SQL_SUCCESS)
    ProcessSuccessWithInfoW(true);
  else
    ProcessErrorW();

	SQLINTEGER rowCount;
	sqlReturn = ::SQLRowCount(mStmt, &rowCount);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)
    ProcessErrorW();

  // Close any open cursors.
  ::SQLFreeStmt(mStmt, SQL_CLOSE);

  // Return row count.
	return rowCount;
}

void COdbcStatement::ProcessSuccessWithInfoA(bool bSuccessOnly /* = false */)
{
  // Log info.
  SQLCHAR sqlstate[6];
	SQLINTEGER nativeErrorPtr;
	SQLCHAR messageText[1024];
	SQLSMALLINT messageLength;
  SQLRETURN sqlReturn = ::SQLGetDiagRecA(SQL_HANDLE_STMT, mStmt, 1, &sqlstate[0], &nativeErrorPtr, &messageText[0], 1024, &messageLength);
  if (sqlReturn == SQL_SUCCESS)
  {
	  NTLogger* logger = GetLogger();
	  if (logger)
    {
      if (bSuccessOnly)
        logger->LogVarArgs(LOG_INFO, "OBDC returned success, but there is info: '%s'.", messageText);
      else
        logger->LogVarArgs(LOG_INFO, "OBDC returned success with info: '%s'.", messageText);
    }
    else
    {
      ASSERT(false);
    }
  }
}
void COdbcStatement::ProcessSuccessWithInfoW(bool bSuccessOnly /* = false */)
{
  // Log info.
  SQLWCHAR sqlstate[6];
	SQLINTEGER nativeErrorPtr;
	SQLWCHAR messageText[1024];
	SQLSMALLINT messageLength;
  SQLRETURN sqlReturn = ::SQLGetDiagRecW(SQL_HANDLE_STMT, mStmt, 1, &sqlstate[0], &nativeErrorPtr, &messageText[0], 1024, &messageLength);
  if (sqlReturn == SQL_SUCCESS)
  {
	  NTLogger* logger = GetLogger();
	  if (logger)
    {
      if (bSuccessOnly)
        logger->LogVarArgs(LOG_INFO, L"OBDC returned success, but there is info: '%s'.", messageText);
      else
        logger->LogVarArgs(LOG_INFO, L"OBDC returned success with info: '%s'.", messageText);
    }
    else
    {
      ASSERT(false);
    }
  }
}


void COdbcStatement::ProcessError()
{
	//log query and throw exception
	LogStatementInfo(true);
	throw COdbcStatementException(mStmt);
}
void COdbcStatement::ProcessErrorW()
{
	//log query and throw exception
	LogStatementInfoW(true);
	throw COdbcStatementException(mStmt);
}