// OdbcPreparedBcpStatement.h: interface for the COdbcPreparedBcpStatement class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ODBCPREPAREDBCPSTATEMENT_H__D3C89C7D_9736_485C_9344_3F72C51AF41E__INCLUDED_)
#define AFX_ODBCPREPAREDBCPSTATEMENT_H__D3C89C7D_9736_485C_9344_3F72C51AF41E__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <sql.h>
#include <sqlext.h>
#include <sqltypes.h>
#include <odbcss.h>

#include <vector>
#include <string>
#include <map>
using namespace std;

#include "OdbcColumnMetadata.h"

// TODO: remove undefs
#if defined(MTODBC_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class COdbcConnection;
class NTLogger;

class DllExport COdbcBcpBinding
{
protected:
	typedef int DBINDICATOR;
public:
	virtual void Bind(HDBC hDbc, int pos) =0;
	virtual void SetInteger(int val) { ASSERT(FALSE); }
	virtual void SetBigInteger(__int64 val) { ASSERT(FALSE); }
	virtual void SetString(const string& val) { ASSERT(FALSE); }
	virtual void SetString(const char * val, int length) { ASSERT(FALSE); }
	virtual void SetDouble(double val) { ASSERT(FALSE); }
	virtual void SetDatetime(const TIMESTAMP_STRUCT& val) { ASSERT(FALSE); }
	virtual void SetDatetime(const DATE * val) { ASSERT(FALSE); }
	virtual void SetDecimal(const SQL_NUMERIC_STRUCT& val) { ASSERT(FALSE); }
	virtual void SetDecimal(const DECIMAL * val) { ASSERT(FALSE); }
	virtual void SetBinary(const unsigned char* val, int length) { ASSERT(FALSE); }
	virtual void SetWideString(const wstring& val) { ASSERT(FALSE); }
	virtual void SetWideString(const wchar_t * val, int length) { ASSERT(FALSE); }

	// Higher performance "reference accessors"
	virtual DBINT* GetIntegerRef() { ASSERT(FALSE); return NULL; }
	// Can't use DBCHAR because it gets typedef'd to wchar_t with UNICODE
	virtual CHAR* GetStringRef() { ASSERT(FALSE); return NULL; }
	virtual DBFLT8* GetDoubleRef() { ASSERT(FALSE); return NULL; }
	virtual DBDATETIME* GetDatetimeRef() { ASSERT(FALSE); return NULL; }
	virtual DBDECIMAL* GetDecimalRef() { ASSERT(FALSE); return NULL; }
	virtual DBVARYBIN* GetBinaryRef() { ASSERT(FALSE); return NULL; }
	virtual WCHAR* GetWideStringRef() { ASSERT(FALSE); return NULL; }
	virtual __int64* GetBigIntegerRef() { ASSERT(FALSE); return NULL; }

	virtual wstring GetAsWString() = 0;

	// Clear all values
	virtual void Clear() =0;

	virtual ~COdbcBcpBinding() {}
};

class COdbcBcpHints
{
private:
	vector<string> mOrder;
	bool mMinimallyLogged;
	bool mFireTriggers;
public:
	// Default Hints are for fully logged inserts with no ordering and
	// no firing of triggers.
	DllExport COdbcBcpHints();

	DllExport virtual ~COdbcBcpHints();

	// Hint that asks BCP to minimally log inserts.  This will
	// take a table level lock.  Minimal logging also requires that
	// all non-clustered indices are dropped or that the the table is empty.
	// Furthermore, the database into which the BCP is insert must have
	// BULK_LOGGED recovery mode.  The current code does not check for this
	// nor does it reset the recovery mode itself.  Checking would be a nice additional
	// feature.  
	DllExport bool GetMinimallyLogged() const;
	DllExport void SetMinimallyLogged(bool aMinimallyLogged);

	// Set whether triggers will be fired after inserts.  Particularly useful when
	// inserting into an updatable view.
	DllExport bool GetFireTriggers() const;
	DllExport void SetFireTriggers(bool aFireTriggers);

	// Hint that tells BCP what the order of the incoming
	// data stream is.  Currently assumes that order is ascending.
	// TODO: Handle desceding order.
	const vector<string>& GetOrder() const;
	// Append a column to the list of order by keys.
	DllExport void AddOrder(const string& aColumn);
};

class COdbcPreparedBcpStatement  
{
private:
	// For by-index references
	COdbcBcpBinding* * mBindings;
	unsigned int mBindingCount;

	// Number of rows currently in the batch (processed by bcp_sendrow)
	int mBatchCount;

	// For by-name references
	map<string, COdbcBcpBinding*> mHashBindings;

	COdbcConnection * mConnection;
	string mTableName;


public:
	DllExport void SetInteger(int columnPos, int val);
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
	DllExport void SetBigInteger(int columnPos, __int64 val);

	DllExport void SetInteger(const string& columnName, int val);
	DllExport void SetString(const string& columnName, const string& val);
	DllExport void SetDouble(const string& columnName, double val);
	DllExport void SetDecimal(const string& columnName, const SQL_NUMERIC_STRUCT& val);
	DllExport void SetDatetime(const string& columnName, const TIMESTAMP_STRUCT& val);
	DllExport void SetBinary(const string& columnName, const unsigned char* val, int length);
	DllExport void SetWideString(const string& columnName, const wstring& val);
	DllExport void SetWideString(const string& columnName, const wchar_t * val, int length);
	DllExport void SetBigInteger(const string& columnName, __int64 val);

	DBINT* GetIntegerRef(int columnPos);
	CHAR* GetStringRef(int columnPos);
	DBFLT8* GetDoubleRef(int columnPos);
	DBDATETIME* GetDatetimeRef(int columnPos);
	DBDECIMAL* GetDecimalRef(int columnPos);
	WCHAR* GetWideStringRef(int columnPos);
	__int64* GetBigIntegerRef(int columnPos);

	// Initialize state for new batch
	DllExport void BeginBatch();
	// Queue up the current set of parameters and stage a new row
	DllExport void AddBatch();
	// Execute the current batch and reinitialize
	DllExport int ExecuteBatch();
	// Return the number of rows currently in the batch
	DllExport int BatchCount();
	// Clean up any remaining batch resources
	DllExport int Finalize();

	// Generate a prepared BCP statement for inserting into a table; don't export c'tor.  Only used by connection.
	COdbcPreparedBcpStatement(COdbcConnection* pConnection, const string& aTableName, const COdbcBcpHints& aHints);
	DllExport virtual ~COdbcPreparedBcpStatement();

	NTLogger* GetLogger();
	
	DllExport COdbcConnection* GetConnection()
	{
		return mConnection;
	}

private:
	// Set up internal bindings
	void Bind(COdbcColumnMetadataVector cols);
	COdbcBcpBinding* Create(const COdbcColumnMetadata* metadata);
	void ClearBindings();
	void ProcessError();
	void LogStatementInfo(bool logAsError);
};

inline void COdbcPreparedBcpStatement::SetInteger(int columnPos, int val)
{
	mBindings[columnPos-1]->SetInteger(val);
}

inline void COdbcPreparedBcpStatement::SetString(int columnPos, const string& val)
{
	mBindings[columnPos-1]->SetString(val);
}

inline void COdbcPreparedBcpStatement::SetString(int columnPos, const char * val, int length)
{
	mBindings[columnPos-1]->SetString(val, length);
}

inline void COdbcPreparedBcpStatement::SetDouble(int columnPos, double val)
{
	mBindings[columnPos-1]->SetDouble(val);
}

inline void COdbcPreparedBcpStatement::SetDecimal(int columnPos, const SQL_NUMERIC_STRUCT& val)
{
	mBindings[columnPos-1]->SetDecimal(val);
}

inline void COdbcPreparedBcpStatement::SetDecimal(int columnPos, const DECIMAL * val)
{
	mBindings[columnPos-1]->SetDecimal(val);
}

inline void COdbcPreparedBcpStatement::SetDatetime(int columnPos, const TIMESTAMP_STRUCT& val)
{
	mBindings[columnPos-1]->SetDatetime(val);
}

inline void COdbcPreparedBcpStatement::SetDatetime(int columnPos, const DATE * val)
{
	mBindings[columnPos-1]->SetDatetime(val);
}

inline void COdbcPreparedBcpStatement::SetBinary(int columnPos, const unsigned char* val, int length)
{
	mBindings[columnPos-1]->SetBinary(val, length);
}

inline void COdbcPreparedBcpStatement::SetWideString(int columnPos, const wstring& val)
{
	mBindings[columnPos-1]->SetWideString(val);
}

inline void COdbcPreparedBcpStatement::SetWideString(int columnPos, const wchar_t * val, int length)
{
	mBindings[columnPos-1]->SetWideString(val, length);
}

inline void COdbcPreparedBcpStatement::SetBigInteger(int columnPos, __int64 val)
{
	mBindings[columnPos-1]->SetBigInteger(val);
}

inline DBINT* COdbcPreparedBcpStatement::GetIntegerRef(int columnPos)
{
	return mBindings[columnPos-1]->GetIntegerRef();
}

inline CHAR* COdbcPreparedBcpStatement::GetStringRef(int columnPos)
{
	return mBindings[columnPos-1]->GetStringRef();
}

inline DBFLT8* COdbcPreparedBcpStatement::GetDoubleRef(int columnPos)
{
	return mBindings[columnPos-1]->GetDoubleRef();
}

inline DBDATETIME* COdbcPreparedBcpStatement::GetDatetimeRef(int columnPos)
{
	return mBindings[columnPos-1]->GetDatetimeRef();
}

inline DBDECIMAL* COdbcPreparedBcpStatement::GetDecimalRef(int columnPos)
{
	return mBindings[columnPos-1]->GetDecimalRef();
}

inline WCHAR* COdbcPreparedBcpStatement::GetWideStringRef(int columnPos)
{
	return mBindings[columnPos-1]->GetWideStringRef();
}

inline __int64* COdbcPreparedBcpStatement::GetBigIntegerRef(int columnPos)
{
	return mBindings[columnPos-1]->GetBigIntegerRef();
}
inline int COdbcPreparedBcpStatement::BatchCount()
{
	return mBatchCount;
}



#endif // !defined(AFX_ODBCPREPAREDBCPSTATEMENT_H__D3C89C7D_9736_485C_9344_3F72C51AF41E__INCLUDED_)
