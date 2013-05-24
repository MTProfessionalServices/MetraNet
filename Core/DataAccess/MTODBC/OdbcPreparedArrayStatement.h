// OdbcPreparedArrayStatement.h: interface for the COdbcPreparedArrayStatement class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ODBCPREPAREDARRAYSTATEMENT_H__3B4E55BA_8A61_4B12_864D_C9F8BE64BEB4__INCLUDED_)
#define AFX_ODBCPREPAREDARRAYSTATEMENT_H__3B4E55BA_8A61_4B12_864D_C9F8BE64BEB4__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define ODBC_TRACK_PERFORMANCE 1

#include <sql.h>
#include <sqlext.h>
#include <sqltypes.h>

#include <vector>
#include <string>
#include <map>
using namespace std;

#include "OdbcColumnMetadata.h"
#include "OdbcStatement.h"

// TODO: remove undefs
#if defined(MTODBC_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class COdbcColumnArrayBinding;
class COdbcConnection;
class COdbcResultSet;
class COdbcPreparedResultSet;
class COdbcRowArrayResultSet;

struct COdbcResultSetType
{ 
	OdbcSqlDatatype dataType;
	int             columnSize;
};


class COdbcPreparedArrayStatement : public COdbcStatementBase
{
private:

	// For by-index references to parameter bindings
	vector<COdbcColumnArrayBinding*> mBindings;

	// Cache the result set metadata in case we are executed multiple times
	COdbcColumnMetadataVector mMetadata;

	// Size of array allocated.  Runtime error to exceed this.
	int mMaxArraySize;
	// Size currently configured in the HDBC.
	int mCurrentArraySize;
	// Size currently filled in.
	int mCurrentArrayPos;

	SQLUSMALLINT* mStatusPtr;
	SQLUSMALLINT mParamsProcessed;

	// map of query parameter names to positions
	typedef std::multimap<std::string, int> NamePositionMap;
	NamePositionMap mPositionMap;

	// the query's tag if available
	std::string mQueryTag;


public:
	DllExport int GetMaxArraySize() const;

	DllExport void SetInteger(int columnPos, int val);
	DllExport void SetBigInteger(int columnPos, __int64 val);
	DllExport void SetString(int columnPos, const string& val);
	DllExport void SetString(int columnPos, const char * val, int length);
	DllExport void SetDouble(int columnPos, double val);
	DllExport void SetDecimal(int columnPos, const SQL_NUMERIC_STRUCT& val);
	DllExport void SetDecimal(int columnPos, const DECIMAL * val);
	DllExport void SetDatetime(int columnPos, const TIMESTAMP_STRUCT& val);
	DllExport void SetDatetime(int columnPos, const DATE * val);
	DllExport void SetBinary(int columnPos, const unsigned char* val, int length);
	DllExport void SetWideString(int columnPos, const wstring& val);
	DllExport void SetWideString(int columnPos, const wchar_t * val, int length);

	// these set methods take a tag in the query instead of a positional value
	// for example SetInteger("%%ID%%", 123);
	// they can only be used after Load runs
	DllExport void SetInteger(const char * apTag, int val);
	DllExport void SetBigInteger(const char * apTag, __int64 val);
	DllExport void SetString(const char * apTag, const string& val);
	DllExport void SetDouble(const char * apTag, double val);
	DllExport void SetDecimal(const char * apTag, const SQL_NUMERIC_STRUCT& val);
	DllExport void SetDatetime(const char * apTag, const TIMESTAMP_STRUCT& val);
	DllExport void SetBinary(const char * apTag, const unsigned char* val, int length);
	DllExport void SetWideString(const char * apTag, const wstring& val);

  // Rowset metadata access.  For efficiencies sake don't call this
  // if one is going to call ExecuteQuery.  This will cause extra round trips
  // to the database.
	DllExport const COdbcColumnMetadataVector& GetMetadata();

	// Initialize state for new batch
	DllExport void BeginBatch();
	// Queue up the current set of parameters and stage a new row
	DllExport void AddBatch();
	// Execute the current batch update and reinitialize
	DllExport int ExecuteBatch();
	// Return the number of rows currently in the batch
	DllExport int BatchCount();
	// Clean up any remaining batch resources
	DllExport int Finalize();
	// Execute a read 
	DllExport COdbcPreparedResultSet* ExecuteQuery();
	// Execute a read 
	DllExport COdbcRowArrayResultSet* ExecuteQueryRowBinding();
	    
	// load the query from a query file.
	// (throws _com_error)
	DllExport void Load(const char * apQueryDirectory, const char * apQueryTag);

	// prepare the meta data for the result set.  This means the code
	// will no longer ask the database for this information.  The meta data will
	// be limited.  It only specifies the type, column size, and number of columns.
	DllExport void SetResultSetTypes(COdbcResultSetType * apDataTypes, int aColumns);


protected:
	// Prepare a parametrized query for inserting into a table.
	COdbcPreparedArrayStatement(COdbcConnection* pConnection, int maxArraySize, const string& tableName, bool aBind);
private:
	COdbcPreparedArrayStatement(COdbcConnection* pConnection, int maxArraySize, const string& queryString, bool dummy, bool aBind);
	COdbcPreparedArrayStatement(COdbcConnection* pConnection, int maxArraySize, const wstring& queryString, bool dummy, bool aBind);
	// load the query from a query file
	COdbcPreparedArrayStatement(COdbcConnection* pConnection, int maxArraySize, const char * apQueryDirectory, const char * apQueryTag, bool aBind);

public:
	// factory methods
	DllExport static COdbcPreparedArrayStatement * CreateStatement(COdbcConnection* pConnection, int maxArraySize, const string& queryString, bool aBind);
	//overloaded for wide strings
	DllExport static COdbcPreparedArrayStatement * CreateStatement(COdbcConnection* pConnection, int maxArraySize, const wstring& queryString, bool aBind);
	DllExport static COdbcPreparedArrayStatement * CreateStatementFromFile(COdbcConnection* pConnection, int maxArraySize, const char * apQueryDirectory, const char * apQueryTag, bool aBind);

	DllExport virtual ~COdbcPreparedArrayStatement();

protected:
	// constructor for use by subclasses (no query passed in)
	COdbcPreparedArrayStatement(COdbcConnection* pConnection, int maxArraySize);

	// statement preparation only (binding must still be done)
	// if second argument is true, bind parameters
	void Prepare(const string & query, bool bind);
	void PrepareW(const wstring & query, bool bind);

	// wrapper around exec
	void InternalExecute();

	// Implementation details that might be useful to subclasses
	const vector<COdbcColumnArrayBinding*>& GetBindings() const { return mBindings; }
	int GetCurrentArraySize() const { return mCurrentArraySize; }

	// Set up internal bindings
	virtual void Bind(COdbcColumnMetadataVector cols);

	// The number of parameters of the query
	unsigned int GetNumParams() const;

	// Clear all bindings
	void ClearBindings();

public:
	// set up internal bindings.
	// NOTE: this is public so code can bind automatically
	DllExport virtual void BindParameters(vector<COdbcParameterMetadata*> aParameterMetadata);

	// These access methods are public to allow code to batch up large session sets.
	int GetArraySize() const { return mMaxArraySize; }
	int GetCurrentArrayPos() const { return mCurrentArrayPos; }

private:
	COdbcParameterMetadata* GetParameterMetadata(SQLSMALLINT i);

	COdbcColumnArrayBinding* Create(const COdbcParameterMetadata* metadata);

	string GetColumnStringAttribute(SQLSMALLINT col, SQLUSMALLINT attr);
	int GetColumnIntegerAttribute(SQLSMALLINT col, SQLUSMALLINT attr);
	
	enum ErrorThreshold {THROW_ON_WARNING, THROW_ON_ERROR};
	void ProcessError(SQLRETURN sqlReturn, ErrorThreshold threshold = THROW_ON_ERROR);
	virtual void LogStatementInfo(bool logAsError);


#ifdef ODBC_TRACK_PERFORMANCE
private:
	__int64 mTicksPerSec;
	__int64 mTotalTicks;
public:
	DllExport double GetTotalExecuteMillis();
#endif
};

class COdbcTableInsertStatement : public COdbcPreparedArrayStatement
{
private:
	// For by-name references
	map<string, COdbcColumnArrayBinding*> mHashBindings;
protected:
	virtual void Bind(COdbcColumnMetadataVector cols);
public:
	DllExport static COdbcTableInsertStatement * CreateTableInsertStatement(COdbcConnection* pConnection, int maxArraySize, const string& tableName, bool aBind);
private:
	COdbcTableInsertStatement(COdbcConnection* pConnection, int maxArraySize, const string& tableName, bool aBind);

public:
	DllExport void SetInteger(const string& columnName, int val);
	DllExport void SetBigInteger(const string& columnName, __int64 val);
	DllExport void SetString(const string& columnName, const string& val);
	DllExport void SetDouble(const string& columnName, double val);
	DllExport void SetDecimal(const string& columnName, const SQL_NUMERIC_STRUCT& val);
	DllExport void SetDatetime(const string& columnName, const TIMESTAMP_STRUCT& val);
	DllExport void SetBinary(const string& columnName, const unsigned char* val, int length);
	DllExport void SetWideString(const string& columnName, const wstring& val);
	DllExport void SetWideString(const string& columnName, const wchar_t * val, int length);
};

#endif // !defined(AFX_ODBCPREPAREDARRAYSTATEMENT_H__3B4E55BA_8A61_4B12_864D_C9F8BE64BEB4__INCLUDED_)
