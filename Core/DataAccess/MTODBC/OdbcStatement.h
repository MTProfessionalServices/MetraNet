#ifndef __ODBCSTATEMENT_H__
#define __ODBCSTATEMENT_H__

#include <metra.h>
#include <sql.h>
#include <sqlext.h>
#include <sqltypes.h>

#include <string>
#include <vector>
using namespace std;

// TODO: remove undefs
#if defined(MTODBC_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class COdbcResultSet;
class COdbcConnection;
class COdbcColumnMetadata;
class NTLogger;

// Base class of methods that wraps ODBC calls.
class COdbcStatementBase
{
protected:
	HSTMT mStmt;
	COdbcConnection* mpConnection;
	std::string mQuery;
	std::wstring mWideQuery;

public:

	DllExport COdbcStatementBase(COdbcConnection* aConnection);

	DllExport virtual ~COdbcStatementBase();

	DllExport HSTMT GetHandle() const
	{
		return mStmt;
	}

	DllExport COdbcConnection* GetConnection() const
	{
		return mpConnection;
	}

	inline DllExport bool IsOracle();

	NTLogger* GetLogger();

	// log all info about this statement to log (use for debugging or error)
	// overrides in derived classes should call base class first
	DllExport virtual void LogStatementInfo(bool logAsError);
	DllExport virtual void LogStatementInfoW(bool logAsError);
};

class COdbcStatement : public COdbcStatementBase
{
private:
	vector<COdbcColumnMetadata*> mAllMetadata;

	string GetColumnStringAttribute(SQLSMALLINT col, SQLUSMALLINT attr);
	int GetColumnIntegerAttribute(SQLSMALLINT col, SQLUSMALLINT attr);

	void ProcessSuccessWithInfoA(bool bSuccessOnly = false);
	void ProcessSuccessWithInfoW(bool bSuccessOnly = false);
	void ProcessError();
	void ProcessErrorW();
	
public:
	DllExport COdbcStatement(COdbcConnection* pConnection);
	DllExport virtual ~COdbcStatement();

	DllExport COdbcResultSet* ExecuteQuery(const string& queryString);
	DllExport COdbcResultSet* ExecuteQueryW(const wstring& wideQueryString);
	DllExport int ExecuteUpdate(const string& queryString);
	DllExport int ExecuteUpdateW(const wstring& wideQueryString);
};

#endif

