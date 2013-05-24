#ifndef __ODBCRESULTSET_H__
#define __ODBCRESULTSET_H__

#include <vector>
using namespace std;

#include <comutil.h>
#include "OdbcColumnMetadata.h"
#include "OdbcType.h"

// TODO: remove undefs
#if defined(MTODBC_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class COdbcStatementBase;
class COdbcColumnBinding;

class COdbcResultSet
{
protected:
	COdbcStatementBase* mStatement;
	COdbcColumnMetadataVector mMetadata;
	bool mWasNull;
	bool mIsClosed;

	void SetWasNull(bool wasNull) 
	{
		mWasNull = wasNull;
	}
	
public:
	DllExport COdbcResultSet(COdbcStatementBase* aStatment, const COdbcColumnMetadataVector& aMetadata);
	DllExport virtual ~COdbcResultSet();

	DllExport virtual int GetInteger(int aPos);
	DllExport virtual __int64 GetBigInteger(int aPos);
	DllExport virtual string GetString(int aPos);
	DllExport virtual double GetDouble(int aPos);
	DllExport virtual COdbcTimestamp GetTimestamp(int aPos);
	DllExport virtual DATE GetOLEDate(int aPos);
	DllExport virtual COdbcDecimal GetDecimal(int aPos);
	DllExport virtual vector<unsigned char> GetBinary(int aPos);
	DllExport virtual wstring GetWideString(int aPos);

	// Tells whether the previously read column was a null
	DllExport virtual bool WasNull() const { return mWasNull; }

	// Move cursor to the next row.  The cursor is initially
	// positioned just before the first row.
	DllExport virtual bool Next();

	DllExport void Close();

	virtual const COdbcColumnMetadataVector& GetMetadata() const 
	{
		return mMetadata;
	}
};

// Result set from a prepared query
class COdbcPreparedResultSet : public COdbcResultSet
{
protected:
	vector<COdbcColumnBinding*> mBindings;
	int mLastPos;
public:
	DllExport COdbcPreparedResultSet(COdbcStatementBase* aStatment, const COdbcColumnMetadataVector& aMetadata);
	DllExport virtual ~COdbcPreparedResultSet();

	DllExport virtual int GetInteger(int aPos);
	DllExport virtual __int64 GetBigInteger(int aPos);
	DllExport virtual string GetString(int aPos);
	DllExport virtual double GetDouble(int aPos);
	DllExport virtual COdbcTimestamp GetTimestamp(int aPos);
	DllExport virtual DATE GetOLEDate(int aPos);
	DllExport virtual COdbcDecimal GetDecimal(int aPos);
	DllExport virtual vector<unsigned char> GetBinary(int aPos);
	DllExport virtual wstring GetWideString(int aPos);

	// These accessors give us the underlying buffer (avoiding data copies that may
	// hit the heap).
	DllExport virtual const SQL_NUMERIC_STRUCT * GetDecimalBuffer(int aPos);
	DllExport virtual const unsigned char * GetBinaryBuffer(int aPos);
	DllExport virtual const wchar_t* GetWideStringBuffer(int aPos);

	// Tells whether the previously read column was a null
	DllExport virtual bool WasNull() const; 

	// Move cursor to the next row.  The cursor is initially
	// positioned just before the first row.
	DllExport virtual bool Next();

	// Advance to the next result set for a batch SELECT
	DllExport virtual bool NextResultSet();

public:
	void ClearBindings();
};

class COdbcRowArrayResultSet : public COdbcResultSet
{
protected:
  // The underlying data buffer stores all of the 
  // data in the front and all of the null indicators after.
  std::vector<std::size_t> mOffsets;
  std::size_t mNullIndicatorOffset;
  unsigned char * mBuffer;
  int mLastPos;
  std::size_t mBufferSize;
  std::size_t mArraySize;
  SQLUSMALLINT * mRowStatus;
  SQLUINTEGER mRowsFetched;
  typedef __int64 (COdbcRowArrayResultSet::*BigIntegerGetter) (int);
  BigIntegerGetter mBigIntegerGetter;
	__int64 GetBigIntegerSQLServer(int aPos);
	__int64 GetBigIntegerOracle(int aPos);
public:
	DllExport COdbcRowArrayResultSet(COdbcStatementBase* aStatment, const COdbcColumnMetadataVector& aMetadata);
	DllExport virtual ~COdbcRowArrayResultSet();
  DllExport bool Next();
  DllExport bool NextResultSet();
  DllExport const unsigned char * GetDataBuffer();
  DllExport std::size_t GetNullOffset();
  DllExport std::size_t GetDataOffset(int aPos);
	DllExport virtual int GetInteger(int aPos);
	DllExport virtual __int64 GetBigInteger(int aPos);
	DllExport virtual string GetString(int aPos);
	DllExport virtual double GetDouble(int aPos);
	DllExport virtual COdbcTimestamp GetTimestamp(int aPos);
	DllExport virtual DATE GetOLEDate(int aPos);
	DllExport virtual COdbcDecimal GetDecimal(int aPos);
	DllExport virtual vector<unsigned char> GetBinary(int aPos);
	DllExport virtual wstring GetWideString(int aPos);

	// Tells whether the previously read column was a null
	DllExport virtual bool WasNull() const; 

  // These accessors give us the underlying buffer (avoiding data copies that may
  // hit the heap).
  DllExport virtual const SQL_NUMERIC_STRUCT * GetDecimalBuffer(int aPos);
	DllExport virtual const unsigned char * GetBinaryBuffer(int aPos);
	DllExport virtual const wchar_t* GetWideStringBuffer(int aPos);
	DllExport virtual const char* GetStringBuffer(int aPos);
};

class COdbcOracleResultSet : public COdbcResultSet
{
public:
	DllExport COdbcOracleResultSet(COdbcStatementBase* aStatement, const COdbcColumnMetadataVector& aMetadata)
		:	COdbcResultSet(aStatement, aMetadata) {};
	DllExport virtual ~COdbcOracleResultSet() {};

	DllExport virtual string GetString(int aPos);
	DllExport virtual wstring GetWideString(int aPos);
};

class COdbcOracleRowArrayResultSet : public COdbcRowArrayResultSet
{
public:
	DllExport COdbcOracleRowArrayResultSet(COdbcStatementBase* aStatment, const COdbcColumnMetadataVector& aMetadata)
		:	COdbcRowArrayResultSet(aStatment, aMetadata) {};
	DllExport virtual ~COdbcOracleRowArrayResultSet() {};

	DllExport virtual string GetString(int aPos);
	DllExport virtual wstring GetWideString(int aPos);
	DllExport virtual const wchar_t* GetWideStringBuffer(int aPos);
	DllExport virtual const char* GetStringBuffer(int aPos);
};

class COdbcOraclePreparedResultSet : public COdbcPreparedResultSet
{
public: 
	DllExport COdbcOraclePreparedResultSet(COdbcStatementBase* aStatment, const COdbcColumnMetadataVector& aMetadata)
		:	COdbcPreparedResultSet(aStatment, aMetadata) {};
	DllExport virtual ~COdbcOraclePreparedResultSet(){};

	DllExport virtual string GetString(int aPos);
	DllExport virtual wstring GetWideString(int aPos);
	DllExport virtual const wchar_t* GetWideStringBuffer(int aPos);
};

#endif

