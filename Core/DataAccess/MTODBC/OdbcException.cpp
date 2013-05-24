#include "OdbcException.h"

#include <sqlext.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>

COdbcConnectionException::COdbcConnectionException(HDBC hConnection)
{
		SQLCHAR sqlstate [6];
		SQLINTEGER nativeErrorPtr;
		SQLCHAR messageText[1024];
		SQLSMALLINT messageLength;
		SQLRETURN sqlReturn = ::SQLGetDiagRecA(SQL_HANDLE_DBC, hConnection, 1, &sqlstate[0], &nativeErrorPtr, &messageText[0], 1024, &messageLength);
		ASSERT(sqlReturn == SQL_SUCCESS || sqlReturn == SQL_SUCCESS_WITH_INFO || sqlReturn == SQL_NO_DATA);
		if(sqlReturn == SQL_NO_DATA)
		{
			setMessage("No Message Detail");
		}
		else
		{
			setMessage((const char *)messageText);
			setSqlState(sqlstate);
		}
		setErrorCode(DB_ERR_ODBC_ERROR);
}


COdbcStatementException::COdbcStatementException(HSTMT hStmt)
{
		SQLCHAR sqlstate [6];
		SQLINTEGER nativeErrorPtr;
		SQLCHAR messageText[1024];
		SQLSMALLINT messageLength;
		SQLRETURN sqlReturn = ::SQLGetDiagRecA(SQL_HANDLE_STMT, hStmt, 1, &sqlstate[0], &nativeErrorPtr, &messageText[0], 1024, &messageLength);
		ASSERT(sqlReturn == SQL_SUCCESS || sqlReturn == SQL_SUCCESS_WITH_INFO || sqlReturn == SQL_NO_DATA);
		if(sqlReturn == SQL_NO_DATA)
		{
			setMessage("No Message Detail");
		}
		else
		{
			setMessage((const char *)messageText);
			setSqlState(sqlstate);
		}
		setErrorCode(DB_ERR_ODBC_ERROR);
}

COdbcDescriptorException::COdbcDescriptorException(SQLHDESC hDesc)
{
		SQLCHAR sqlstate [6];
		SQLINTEGER nativeErrorPtr;
		SQLCHAR messageText[1024];
		SQLSMALLINT messageLength;
		SQLRETURN sqlReturn = ::SQLGetDiagRecA(SQL_HANDLE_DESC, hDesc, 1, &sqlstate[0], &nativeErrorPtr, &messageText[0], 1024, &messageLength);
		ASSERT(sqlReturn == SQL_SUCCESS || sqlReturn == SQL_SUCCESS_WITH_INFO || sqlReturn == SQL_NO_DATA);
		if(sqlReturn == SQL_NO_DATA)
		{
			setMessage("No Message Detail");
		}
		else
		{
			setMessage((const char *)messageText);
			setSqlState(sqlstate);
		}
		setErrorCode(DB_ERR_ODBC_ERROR);
}

COdbcComException::COdbcComException(const _com_error& aError)
{
	string message;
	StringFromComError(message, "", aError);
	setMessage(message.c_str());

	setErrorCode(aError.Error());
}
