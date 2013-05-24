#include <metra.h>
#include "OdbcConnection.h"
#include "OdbcResultSet.h"
#include "OdbcStatement.h"
#include "OdbcException.h"
#include "OdbcSessionTypeConversion.h"

#include <iostream>
using namespace std;

COdbcResultSet::COdbcResultSet(COdbcStatementBase* aStatement, const COdbcColumnMetadataVector& aMetadata)
	:
	mStatement(aStatement),
	mMetadata(aMetadata),
	mIsClosed(false)
{
}

COdbcResultSet::~COdbcResultSet()
{
	Close();
	// We don't own the metadata
	mMetadata.clear();
}

void COdbcResultSet::Close()
{
	if (mIsClosed) return;
	SQLRETURN sqlReturn;
	// We are not calling SQLCloseCursor because we want to avoid handling
	// the error that it raises when the cursor is not open
#ifdef BUILD_SQL_SERVER
	sqlReturn = ::SQLFreeStmt(mStatement->GetHandle(), SQL_CLOSE);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) 
		throw COdbcStatementException(mStatement->GetHandle());
#else
	// Not sure yet, but it is not clear that SQLFreeStmt is really closing
	// the cursor in Oracle (sigh).
	sqlReturn = ::SQLCloseCursor(mStatement->GetHandle());
#endif
	mIsClosed = true;
}



int COdbcResultSet::GetInteger(int aPos)
{
	SQLRETURN sqlReturn;
	SQLINTEGER indicator;
	int val;
	sqlReturn = ::SQLGetData(mStatement->GetHandle(), 
													 (SQLSMALLINT)aPos, 
													 SQL_C_LONG, 
													 &val, 
													 sizeof(val), 
													 &indicator);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(mStatement->GetHandle());
	SetWasNull(indicator == SQL_NULL_DATA);
	return indicator == SQL_NULL_DATA ? 0 : val;
}

__int64 COdbcResultSet::GetBigInteger(int aPos)
{
	SQLRETURN sqlReturn;
	SQLINTEGER indicator;

  __int64 out;
  SQL_NUMERIC_STRUCT val;

  sqlReturn = ::SQLGetData(mStatement->GetHandle(), 
													 (SQLSMALLINT)aPos, 
													 SQL_C_NUMERIC, // SQL_C_SBIGINT,
													 &val, 
													 sizeof(val), 
													 &indicator);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) 
    throw COdbcStatementException(mStatement->GetHandle());

  // Driver truncates (without rounding) the fractional part see MS KB article Q222831.

  // Check for overflow in case of Oracle?  not in -2^63..2^63-1

	SetWasNull(indicator == SQL_NULL_DATA);
	
	if(indicator == SQL_NULL_DATA)
			return 0;
	else
	{
		memcpy(&out, val.val, 8);  // little endian
    return val.sign == 0 ? -out : out;
	}
}

string COdbcResultSet::GetString(int aPos)
{
	static const int BUFSIZE = 256;

	SQLRETURN sqlReturn;
	SQLINTEGER indicator;
	string retVal;
	char val[BUFSIZE];
	bool moreData = true;

	while(moreData)
	{
		sqlReturn = ::SQLGetData(mStatement->GetHandle(), 
													 (SQLSMALLINT)aPos, 
													 SQL_C_CHAR, 
													 &val[0], 
													 BUFSIZE, 
													 &indicator);
		if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(mStatement->GetHandle());
		SetWasNull(indicator == SQL_NULL_DATA);

		if (indicator == SQL_NULL_DATA)
		{	
			retVal = "";
			moreData = false;
		}
		else
		{	
			retVal += val;
			moreData = (sqlReturn == SQL_SUCCESS_WITH_INFO && 
						(indicator == SQL_NO_TOTAL || indicator > BUFSIZE-1));
		}
	}
	return retVal;
}

double COdbcResultSet::GetDouble(int aPos)
{
	SQLRETURN sqlReturn;
	SQLINTEGER indicator;
	double val;
	sqlReturn = ::SQLGetData(mStatement->GetHandle(), 
													 (SQLSMALLINT)aPos, 
													 SQL_C_DOUBLE, 
													 &val, 
													 sizeof(val), 
													 &indicator);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(mStatement->GetHandle());
	SetWasNull(indicator == SQL_NULL_DATA);
	return indicator == SQL_NULL_DATA ? 0.0 : val;
}

COdbcTimestamp COdbcResultSet::GetTimestamp(int aPos)
{
	SQLRETURN sqlReturn;
	SQLINTEGER indicator;
	COdbcTimestamp val;
	sqlReturn = ::SQLGetData(mStatement->GetHandle(), 
													 (SQLSMALLINT)aPos, 
													 SQL_C_TYPE_TIMESTAMP, 
													 (SQLPOINTER) val.GetBuffer(), 
													 sizeof(*val.GetBuffer()), 
													 &indicator);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(mStatement->GetHandle());
	SetWasNull(indicator == SQL_NULL_DATA);
	return indicator == SQL_NULL_DATA ? COdbcTimestamp() : val;	
}

DATE COdbcResultSet::GetOLEDate(int aPos)
{
	SQLRETURN sqlReturn;
	SQLINTEGER indicator;
	TIMESTAMP_STRUCT ts;
	sqlReturn = ::SQLGetData(mStatement->GetHandle(), 
													 (SQLSMALLINT)aPos, 
													 SQL_C_TYPE_TIMESTAMP, 
													 (SQLPOINTER) &ts, 
													 sizeof(ts), 
													 &indicator);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(mStatement->GetHandle());
	SetWasNull(indicator == SQL_NULL_DATA);
  DATE dt = 0.0;
  if (indicator != SQL_NULL_DATA)
  {
    ::OdbcTimestampToOLEDate(&ts, &dt);
  }
	return dt;
}

COdbcDecimal COdbcResultSet::GetDecimal(int aPos)
{
	SQLRETURN sqlReturn;
	SQLINTEGER indicator;
	COdbcDecimal val;
	// Of course, I am ignoring my own warning about casting away the constness of
	// the underlying SQL_NUMERIC_STRUCT buffer.  That is because it is the right thing
	// to do :-)
	
	// By default, the driver will assume a scale of 0.  We need to tell to use the configured scale.  This
	// code follows the MS KB article Q222831.
	SQLHDESC hDesc = NULL;
	sqlReturn = ::SQLGetStmtAttr(mStatement->GetHandle(), SQL_ATTR_APP_ROW_DESC, &hDesc, 0, NULL);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)
		throw COdbcStatementException(mStatement->GetHandle());
	
	sqlReturn = ::SQLSetDescField(hDesc, aPos, SQL_DESC_TYPE, (SQLPOINTER) SQL_C_NUMERIC, 0);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)
		throw COdbcDescriptorException(hDesc);
	
	sqlReturn = ::SQLSetDescField(hDesc, aPos, SQL_DESC_PRECISION, (SQLPOINTER) METRANET_PRECISION_MAX, 0);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)
		throw COdbcDescriptorException(hDesc);
	
	sqlReturn = ::SQLSetDescField(hDesc, aPos, SQL_DESC_SCALE, (SQLPOINTER) METRANET_SCALE_MAX, 0);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)
		throw COdbcDescriptorException(hDesc);

	sqlReturn = ::SQLGetData(mStatement->GetHandle(), 
													 (SQLSMALLINT)aPos, 

// If the TargetType argument is an SQL_C_NUMERIC data type,
// the default precision (driver-defined) and default scale (0), 
// as set in the SQL_DESC_PRECISION and SQL_DESC_SCALE fields of
// the ARD, are used for the data. If any default precision or 
// scale is not appropriate, the application should explicitly set
// the appropriate descriptor field by a call to SQLSetDescField
// or SQLSetDescRec. It can set the SQL_DESC_CONCISE_TYPE field to
// SQL_C_NUMERIC and call SQLGetData with a TargetType argument of
// SQL_ARD_TYPE, which will cause the precision and scale values in
// the descriptor fields to be used.        -- MSDN
													 SQL_ARD_TYPE,

													 (SQLPOINTER) val.GetBuffer(), 
													 sizeof(*val.GetBuffer()), 
													 &indicator);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(mStatement->GetHandle());
	SetWasNull(indicator == SQL_NULL_DATA);
	// Return zero if null
	return  indicator == SQL_NULL_DATA ? COdbcDecimal() : val;	
}


vector<unsigned char> COdbcResultSet::GetBinary(int aPos)
{
	static const int BUFSIZE = 256;

	SQLRETURN sqlReturn;
	SQLINTEGER indicator;
	vector<BYTE> retVal;
	BYTE val[BUFSIZE];
	bool moreData = true;

	while(moreData)
	{
		sqlReturn = ::SQLGetData(mStatement->GetHandle(), 
													 (SQLSMALLINT)aPos, 
													 SQL_C_BINARY, 
													 &val[0], 
													 BUFSIZE, 
													 &indicator);
		if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(mStatement->GetHandle());
		SetWasNull(indicator == SQL_NULL_DATA);

		if (indicator == SQL_NULL_DATA)
		{	
			moreData = false;
		}
		else
		{	
			int numBytes = __min(indicator, BUFSIZE);
			for(SQLINTEGER i = 0; i<numBytes; i++)
			{
				retVal.push_back(val[i]);
			}

			moreData = (sqlReturn == SQL_SUCCESS_WITH_INFO && 
									(indicator == SQL_NO_TOTAL || indicator > BUFSIZE));
		}
	}

	return retVal;
}


wstring COdbcResultSet::GetWideString(int aPos)
{
	static const int BUFSIZE = 256;
	
	SQLRETURN sqlReturn;
	SQLINTEGER indicator;
	wstring retVal;
	wchar_t val[BUFSIZE];
	bool moreData = true;

	while(moreData)
	{
		sqlReturn = ::SQLGetData(mStatement->GetHandle(), 
														 (SQLSMALLINT)aPos, 
														 SQL_C_WCHAR, 
														 &val[0], 
														 BUFSIZE*sizeof(wchar_t), 
														 &indicator);
		if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(mStatement->GetHandle());
		SetWasNull(indicator == SQL_NULL_DATA);

		if (indicator == SQL_NULL_DATA)
		{	
			retVal = L"";
			moreData = false;
		}
		else
		{	
			retVal += val;
			moreData = (sqlReturn == SQL_SUCCESS_WITH_INFO && 
									(indicator == SQL_NO_TOTAL || indicator > BUFSIZE-1));
		}
	}
	return retVal;
}

// Move cursor to the next row.  The cursor is initially
// positioned just before the first row.
bool COdbcResultSet::Next()
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLFetch(mStatement->GetHandle());
	if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO && sqlReturn != SQL_NO_DATA) throw COdbcStatementException(mStatement->GetHandle());
	return sqlReturn != SQL_NO_DATA;
}

class COdbcColumnBinding
{
public:
	virtual void Bind(HSTMT hStmt, int pos)=0;
	virtual bool WasNull() const =0;
	virtual int GetInteger()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as an integer");
	}
	virtual __int64 GetBigInteger()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a big integer");
	}
	virtual string GetString()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a string");
	}
	virtual double GetDouble()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a double");
	}

	virtual COdbcTimestamp GetTimestamp()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a timestamp");
	}

	virtual DATE GetOLEDate()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a OLE date");
	}

	virtual COdbcDecimal GetDecimal()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a decimal");
	}

	virtual const SQL_NUMERIC_STRUCT * GetDecimalBuffer()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a decimal");
	}

	virtual vector<unsigned char> GetBinary()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a binary");
	}
	virtual const unsigned char * GetBinaryBuffer()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a binary");
	}
	virtual wstring GetWideString()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a wide string");
	}
	virtual const wchar_t* GetWideStringBuffer()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a wide string buffer");
	}
	virtual void* GetRawData() 
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as raw data");
	}
	virtual const char* GetStringBuffer()
	{
		ASSERT(false);
		throw COdbcException("Unable to retrieve column value as a string buffer");
	}
	virtual ~COdbcColumnBinding() {}
};

class COdbcIntegerColumnBinding : public COdbcColumnBinding
{
private:
	SQLINTEGER mData;
	SQLINTEGER mInd;
public:
	COdbcIntegerColumnBinding(COdbcColumnMetadata* aMetadata) : mData(0), mInd(SQL_NULL_DATA) 
	{
		ASSERT(aMetadata->GetDataType() == eInteger);
	}

	void Bind(HSTMT hStmt, int pos)
	{
		SQLRETURN sqlReturn;
		sqlReturn = ::SQLBindCol(hStmt, pos, SQL_C_SLONG, &mData, sizeof(mData), &mInd);
		if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 
	}

	int GetInteger() 
	{ 
		return mInd == SQL_NULL_DATA ? 0 : mData; 
	}

	bool WasNull() const
	{
		return mInd == SQL_NULL_DATA;
	}

	~COdbcIntegerColumnBinding() 
	{
	}
};

class COdbcBigIntegerColumnBinding : public COdbcColumnBinding
{
private:
	__int64 mData;
	SQLINTEGER mInd;
public:
	COdbcBigIntegerColumnBinding(COdbcColumnMetadata* aMetadata) : mData(0LL), mInd(SQL_NULL_DATA) 
	{
		ASSERT(aMetadata->GetDataType() == eBigInteger);
	}

	void Bind(HSTMT hStmt, int pos)
	{
		SQLRETURN sqlReturn;
		sqlReturn = ::SQLBindCol(hStmt, pos, SQL_C_SBIGINT, &mData, sizeof(mData), &mInd);
		if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 
	}

	__int64 GetBigInteger() 
	{ 
    return mInd == SQL_NULL_DATA ? 0LL : mData;
	}


	bool WasNull() const
	{
		return mInd == SQL_NULL_DATA;
	}

	~COdbcBigIntegerColumnBinding() 
	{
	}
};

class COdbcStringColumnBinding : public COdbcColumnBinding
{
private:
	SQLCHAR* mData;
	SQLINTEGER mInd;
	int mSize;
public:
	COdbcStringColumnBinding(COdbcColumnMetadata* aMetadata) : mData(NULL), mInd(SQL_NULL_DATA) 
	{
		// Leave room for null terminator
    // BUG: It isn't too important right now to support reading truly huge
    // strings/clobs, so I punt and use a reasonable fixed size buffer.
    mSize = aMetadata->GetColumnSize() < (1024*128-1) ? (aMetadata->GetColumnSize()+1) : 1024*128;
		mData = new SQLCHAR [mSize];
	}

	void Bind(HSTMT hStmt, int pos)
	{
		SQLRETURN sqlReturn;
		sqlReturn = ::SQLBindCol(hStmt, pos, SQL_C_CHAR, mData, mSize, &mInd);
		if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 
	}

	string GetString() 
	{ 
		return mInd == SQL_NULL_DATA ? "" : string((const char*)mData);
	}

	const char* GetStringBuffer() 
	{ 
		return reinterpret_cast<const char*>(mData);
	}

	bool WasNull() const
	{
		return mInd == SQL_NULL_DATA;
	}

	~COdbcStringColumnBinding() 
	{
		delete [] mData;
	}
};

class COdbcDoubleColumnBinding : public COdbcColumnBinding
{
private:
	SQLDOUBLE mData;
	SQLINTEGER mInd;
public:
	COdbcDoubleColumnBinding(COdbcColumnMetadata* aMetadata) : mData(0.0), mInd(SQL_NULL_DATA) 
	{
	}

	void Bind(HSTMT hStmt, int pos)
	{
		SQLRETURN sqlReturn;
		sqlReturn = ::SQLBindCol(hStmt, pos, SQL_C_DOUBLE, &mData, sizeof(mData), &mInd);
		if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 
	}

  int GetInteger()
  {
    return mInd == SQL_NULL_DATA ? 0 : (int) mData;
  }

  __int64 GetBigInteger()
  {
    return mInd == SQL_NULL_DATA ? 0LL : (__int64) mData;
  }

  COdbcDecimal GetDecimal()
  {
    if (mInd == SQL_NULL_DATA) return COdbcDecimal();
    DECIMAL decVal;
		HRESULT hr = VarDecFromR8(mData, &decVal);
    if (FAILED(hr)) throw COdbcComException(hr);
    COdbcDecimal odbcDec;
    ::DecimalToOdbcNumeric(&decVal, const_cast<SQL_NUMERIC_STRUCT *>(odbcDec.GetBuffer()));
    return odbcDec;
  }

	double GetDouble() 
	{ 
		return mInd == SQL_NULL_DATA ? 0.0 : mData; 
	}

	bool WasNull() const
	{
		return mInd == SQL_NULL_DATA;
	}

	~COdbcDoubleColumnBinding() 
	{
	}
};

class COdbcDecimalColumnBinding : public COdbcColumnBinding
{
private:
	SQL_NUMERIC_STRUCT mData;
	SQLINTEGER mInd;
	SQLINTEGER mPrecision;
	SQLINTEGER mScale;
public:
	COdbcDecimalColumnBinding(COdbcColumnMetadata* aMetadata) : mInd(SQL_NULL_DATA) 
	{
		ASSERT(aMetadata->GetDataType() == eDecimal || 
           aMetadata->GetDataType() == eInteger || 
           aMetadata->GetDataType() == eBigInteger);
		mPrecision = aMetadata->GetPrecision();
		mScale = aMetadata->GetDecimalDigits();
	}

	void Bind(HSTMT hStmt, int pos)
	{
		SQLRETURN sqlReturn;
		sqlReturn = ::SQLBindCol(hStmt, pos, SQL_C_NUMERIC, &mData, sizeof(mData), &mInd);
		if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 

		SQLHDESC hDesc = NULL;
		sqlReturn = ::SQLGetStmtAttr(hStmt, SQL_ATTR_APP_ROW_DESC, &hDesc, 0, NULL);
		if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt);

	  // By default, the driver will assume a scale of 0.  We need to tell to use the configured scale.  This
	  // code follows the MS KB article Q222831.
		sqlReturn = ::SQLSetDescField(hDesc, pos, SQL_DESC_TYPE, (SQLPOINTER) SQL_C_NUMERIC, 0);
		if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
		sqlReturn = ::SQLSetDescField(hDesc, pos, SQL_DESC_PRECISION, (SQLPOINTER) mPrecision, 0);
		if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
		sqlReturn = ::SQLSetDescField(hDesc, pos, SQL_DESC_SCALE, (SQLPOINTER) mScale, 0);
		if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
		sqlReturn = ::SQLSetDescField(hDesc, pos, SQL_DESC_DATA_PTR, (SQLPOINTER) &mData, 0);
		if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);

#ifndef BUILD_SQL_SERVER
		sqlReturn = ::SQLSetDescField(hDesc, pos, SQL_DESC_INDICATOR_PTR, (SQLPOINTER) &mInd, 0);
		if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
#endif
	}

  int GetInteger()
  {
    if (mInd == SQL_NULL_DATA) return 0;

    DECIMAL decVal;
    long intVal;
    OdbcNumericToDecimal(&mData, &decVal);
		HRESULT hr = VarI4FromDec(&decVal, &intVal);
		if(FAILED(hr)) throw COdbcComException(hr);
    return intVal;
  }

  __int64 GetBigInteger()
  {
    if (mInd == SQL_NULL_DATA) return 0LL;

    DECIMAL decVal;
    __int64 int64Val;
    OdbcNumericToDecimal(&mData, &decVal);
		HRESULT hr = VarI8FromDec(&decVal, &int64Val);
		if(FAILED(hr)) throw COdbcComException(hr);
    return int64Val;
  }

  double GetDouble()
  {
    if (mInd == SQL_NULL_DATA) return 0.0;

    DECIMAL decVal;
    double dblVal;
    OdbcNumericToDecimal(&mData, &decVal);
		HRESULT hr = VarR8FromDec(&decVal, &dblVal);
		if(FAILED(hr)) throw COdbcComException(hr);
    return dblVal;
  }

	COdbcDecimal GetDecimal() 
	{ 
		// Return a copy of the buffer
		return mInd == SQL_NULL_DATA ? COdbcDecimal() : COdbcDecimal(&mData,true); 
	}

	const SQL_NUMERIC_STRUCT * GetDecimalBuffer() 
	{ 
		// Return a copy of the buffer
		return &mData;
	}

	bool WasNull() const
	{
		return mInd == SQL_NULL_DATA;
	}

	~COdbcDecimalColumnBinding() 
	{
	}
};

class COdbcTimestampColumnBinding : public COdbcColumnBinding
{
private:
	TIMESTAMP_STRUCT mData;
	SQLINTEGER mInd;
public:
	COdbcTimestampColumnBinding(COdbcColumnMetadata* aMetadata) : mInd(SQL_NULL_DATA) 
	{
	}

	void Bind(HSTMT hStmt, int pos)
	{
		SQLRETURN sqlReturn;
		sqlReturn = ::SQLBindCol(hStmt, pos, SQL_C_TYPE_TIMESTAMP, &mData, sizeof(mData), &mInd);
		if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 
	}

	COdbcTimestamp GetTimestamp() 
	{ 
		// Return a copy of the buffer
		return mInd == SQL_NULL_DATA ? COdbcTimestamp() : COdbcTimestamp(&mData,true); 
	}

	DATE GetOLEDate() 
	{ 
    DATE dt(0.0);
    if (mInd != SQL_NULL_DATA)
    {
      ::OdbcTimestampToOLEDate(&mData, &dt);
    }
		return dt;
	}

	bool WasNull() const
	{
		return mInd == SQL_NULL_DATA;
	}

	~COdbcTimestampColumnBinding() 
	{
	}
};

class COdbcBinaryColumnBinding : public COdbcColumnBinding
{
private:
	SQLCHAR* mData;
	SQLINTEGER mInd;
	int mSize;
public:
	COdbcBinaryColumnBinding(COdbcColumnMetadata* aMetadata) : mData(NULL), mInd(SQL_NULL_DATA) 
	{
		// Leave room for null terminator
		mData = new SQLCHAR [mSize = (aMetadata->GetColumnSize()+1)];
	}

	void Bind(HSTMT hStmt, int pos)
	{
		SQLRETURN sqlReturn;
		sqlReturn = ::SQLBindCol(hStmt, pos, SQL_C_BINARY, mData, mSize, &mInd);
		if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 
	}

	vector<unsigned char> GetBinary() 
	{ 
		if (mInd == SQL_NULL_DATA)
		{
			return vector<unsigned char>();
		}
		else
		{
			ASSERT(mInd >= 0);
			vector <unsigned char> ret;
			for (SQLINTEGER i=0; i<mInd; i++)
			{
				ret.push_back(mData[i]);
			}
			return ret;
		}
	}

	const unsigned char * GetBinaryBuffer() 
	{ 
    return reinterpret_cast<const unsigned char *>(mData);
	}

	bool WasNull() const
	{
		return mInd == SQL_NULL_DATA;
	}

	~COdbcBinaryColumnBinding() 
	{
		delete [] mData;
	}
};

class COdbcWideStringColumnBinding : public COdbcColumnBinding
{
private:
	SQLWCHAR* mData;
	SQLINTEGER mInd;
	int mSize;
public:
	COdbcWideStringColumnBinding(COdbcColumnMetadata* aMetadata) : mData(NULL), mInd(SQL_NULL_DATA) 
	{
		// Leave room for null terminator
		// BUG: It isn't too important right now to support reading truly huge
		// strings/clobs, so I punt and use a reasonable fixed size buffer.
		mSize = (aMetadata->GetColumnSize()) < (1024*64-1) ? (aMetadata->GetColumnSize()+1) : 1024*64;
		mData = new SQLWCHAR [mSize];
	}

	void Bind(HSTMT hStmt, int pos)
	{
		SQLRETURN sqlReturn;
		sqlReturn = ::SQLBindCol(hStmt, pos, SQL_C_WCHAR, mData, mSize*sizeof(SQLWCHAR), &mInd);
		if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 
	}

	wstring GetWideString() 
	{ 
		return mInd == SQL_NULL_DATA ? L"" : wstring((const wchar_t*)mData);
	}

	const wchar_t* GetWideStringBuffer() 
	{ 
		return reinterpret_cast<const wchar_t*>(mData);
	}

	void* GetRawData() 
	{ 
		return reinterpret_cast<void*>(mData);
	}

	bool WasNull() const
	{
		return mInd == SQL_NULL_DATA;
	}

	~COdbcWideStringColumnBinding() 
	{
		delete [] mData;
	}
};

COdbcPreparedResultSet::COdbcPreparedResultSet(COdbcStatementBase* aStatement, const COdbcColumnMetadataVector& aMetadata)
	:
	COdbcResultSet(aStatement, aMetadata),
	mLastPos(0)
{
  const bool isOracle (aStatement->GetConnection()->GetConnectionInfo().IsOracle());

	// Set up bindings for all columns; for efficiency does this
	// need to move into the statement so that there is one set of
	// column bindings per statement?
	ClearBindings();
	mBindings.reserve(aMetadata.size());
	mBindings.assign(aMetadata.size(), NULL);

	for(unsigned int i=0; i<aMetadata.size(); i++)
	{
		COdbcColumnBinding* binding=NULL;
		switch(aMetadata[i]->GetDataType())
		{
		case eInteger:
		{
			binding = new COdbcIntegerColumnBinding(aMetadata[i]);
			break;
		}
		case eBigInteger:
		{
			binding = isOracle ? 
        static_cast<COdbcColumnBinding*>(new COdbcDecimalColumnBinding(aMetadata[i])) : 
        static_cast<COdbcColumnBinding*>(new COdbcBigIntegerColumnBinding(aMetadata[i]));
			break;
		}
		case eString:
		{
			binding = new COdbcStringColumnBinding(aMetadata[i]);
			break;
		}
		case eDouble:
		{
			binding = new COdbcDoubleColumnBinding(aMetadata[i]);
			break;
		}
		case eDecimal:
		{
			binding = new COdbcDecimalColumnBinding(aMetadata[i]);
			break;
		}
		case eDatetime:
		{
			binding = new COdbcTimestampColumnBinding(aMetadata[i]);
			break;
		}
		case eBinary:
		{
			binding = new COdbcBinaryColumnBinding(aMetadata[i]);
			break;
		}
		case eWideString:
		{
			binding = new COdbcWideStringColumnBinding(aMetadata[i]);
			break;
		}
		default:
			ASSERT(false);
			break;
		}
		binding->Bind(mStatement->GetHandle(), aMetadata[i]->GetOrdinalPosition());
		mBindings.at(aMetadata[i]->GetOrdinalPosition()-1) = binding;
	}
}

COdbcPreparedResultSet::~COdbcPreparedResultSet()
{
	ClearBindings();
}

void COdbcPreparedResultSet::ClearBindings()
{
	for (int i = 0; i < (int) mBindings.size(); i++)
	{
		delete mBindings[i];
		mBindings[i] = NULL;
	}
	mBindings.clear();
}

int COdbcPreparedResultSet::GetInteger(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetInteger();
}


__int64 COdbcPreparedResultSet::GetBigInteger(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetBigInteger();
}

string COdbcPreparedResultSet::GetString(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetString();
}

double COdbcPreparedResultSet::GetDouble(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetDouble();
}

COdbcTimestamp COdbcPreparedResultSet::GetTimestamp(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetTimestamp();
}

DATE COdbcPreparedResultSet::GetOLEDate(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetOLEDate();
}

COdbcDecimal COdbcPreparedResultSet::GetDecimal(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetDecimal();
}

const SQL_NUMERIC_STRUCT * COdbcPreparedResultSet::GetDecimalBuffer(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetDecimalBuffer();
}

vector<unsigned char> COdbcPreparedResultSet::GetBinary(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetBinary();
}

const unsigned char * COdbcPreparedResultSet::GetBinaryBuffer(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetBinaryBuffer();
}

wstring COdbcPreparedResultSet::GetWideString(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetWideString();
}

const wchar_t* COdbcPreparedResultSet::GetWideStringBuffer(int aPos)
{
	return mBindings[mLastPos=(aPos-1)]->GetWideStringBuffer();
}

bool COdbcPreparedResultSet::WasNull() const 
{ 
	return mBindings[mLastPos]->WasNull(); 
}

// Move cursor to the next row.  The cursor is initially
// positioned just before the first row.
bool COdbcPreparedResultSet::Next()
{
	return COdbcResultSet::Next();
}

bool COdbcPreparedResultSet::NextResultSet()
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLMoreResults(mStatement->GetHandle());
	if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO && sqlReturn != SQL_NO_DATA) throw COdbcStatementException(mStatement->GetHandle());
	return sqlReturn != SQL_NO_DATA;
}

COdbcRowArrayResultSet::COdbcRowArrayResultSet(COdbcStatementBase* aStatement, const COdbcColumnMetadataVector& aMetadata)
  :
	COdbcResultSet(aStatement, aMetadata),
	mLastPos(0),
  mArraySize(1),
  mBuffer(NULL),
  mNullIndicatorOffset(0),
  mRowStatus(NULL),
  mRowsFetched(0),
  mBigIntegerGetter(NULL)
{
  mRowStatus = new SQLUSMALLINT [mArraySize];
  bool isOracle(aStatement->GetConnection()->GetConnectionInfo().IsOracle());
  mBigIntegerGetter = 
    isOracle ? 
    &COdbcRowArrayResultSet::GetBigIntegerOracle : 
    &COdbcRowArrayResultSet::GetBigIntegerSQLServer;

  // First calculate data offsets for each column.
  // TODO: Worry about alignment.
  std::vector<SQLINTEGER> bufferSizes;
	for(unsigned int i=0; i<aMetadata.size(); i++)
	{
    mOffsets.push_back(i==0 ? 0 : mOffsets[i-1] + std::size_t(bufferSizes[i-1]));
		switch(aMetadata[i]->GetDataType())
		{
		case eInteger:
		{
      bufferSizes.push_back(sizeof(SQLINTEGER));
			break;
		}
		case eBigInteger:
		{
      if (isOracle)
      {
        bufferSizes.push_back(sizeof(SQL_NUMERIC_STRUCT));
      }
      else
      {
        bufferSizes.push_back(sizeof(__int64));
      }
			break;
		}
		case eString:
		{
      bufferSizes.push_back(sizeof(SQLCHAR)*(aMetadata[i]->GetColumnSize() + 1));
			break;
		}
		case eDouble:
		{
      bufferSizes.push_back(sizeof(SQLDOUBLE));
			break;
		}
		case eDecimal:
		{
      bufferSizes.push_back(sizeof(SQL_NUMERIC_STRUCT));
			break;
		}
		case eDatetime:
		{
			bufferSizes.push_back(sizeof(TIMESTAMP_STRUCT));
			break;
		}
		case eBinary:
		{
      bufferSizes.push_back(sizeof(SQLCHAR)*aMetadata[i]->GetColumnSize());
			break;
		}
		case eWideString:
		{
      bufferSizes.push_back(sizeof(SQLWCHAR)*(aMetadata[i]->GetColumnSize() + 1));
			break;
		}
		default:
			ASSERT(false);
			break;
		}
  }

  mBufferSize = mOffsets.back() + bufferSizes.back() + sizeof(SQLLEN)*aMetadata.size();
  mBuffer = new unsigned char [mArraySize * mBufferSize];
  mNullIndicatorOffset = mOffsets.back() + bufferSizes.back();

  HSTMT hStmt = aStatement->GetHandle();

  // Tweak the statement for row binding.
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLSetStmtAttr(hStmt, SQL_ATTR_ROW_BIND_TYPE, (void *)mBufferSize, 0);
  if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 

	sqlReturn = ::SQLSetStmtAttr(hStmt, SQL_ATTR_ROW_ARRAY_SIZE, (void *)mArraySize, 0);
  if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 

	sqlReturn = ::SQLSetStmtAttr(hStmt, SQL_ATTR_ROW_STATUS_PTR, mRowStatus, 0);
  if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 

	sqlReturn = ::SQLSetStmtAttr(hStmt, SQL_ATTR_ROWS_FETCHED_PTR, &mRowsFetched, 0);
  if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 

  if (mArraySize > 1 && !isOracle)
  {
    sqlReturn = ::SQLSetStmtAttr(hStmt, SQL_SOPT_SS_CURSOR_OPTIONS, (SQLPOINTER)SQL_CO_FFO, 0);
    if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 
  }

    // Now go through again and actually bind (we now have
    // the buffer and knowledge of the null indicators.
	for(unsigned int i=0; i<aMetadata.size(); i++)
	{
    SQLSMALLINT odbcType;
		switch(aMetadata[i]->GetDataType())
		{
		case eInteger:
		{
      odbcType = SQL_C_SLONG;
			break;
		}
		case eBigInteger:
		{
      if (isOracle)
      {
        odbcType = SQL_C_NUMERIC;
      }
      else
      {
        odbcType = SQL_C_SBIGINT;
      }
			break;
		}
		case eString:
		{
      odbcType = SQL_C_CHAR;
			break;
		}
		case eDouble:
		{
      odbcType = SQL_C_DOUBLE;
			break;
		}
		case eDecimal:
		{
      odbcType = SQL_C_NUMERIC;
			break;
		}
		case eDatetime:
		{
      odbcType = SQL_C_TYPE_TIMESTAMP;
			break;
		}
		case eBinary:
		{
      odbcType = SQL_C_BINARY;
			break;
		}
		case eWideString:
		{
      odbcType = SQL_C_WCHAR;
			break;
		}
		default:
			ASSERT(false);
			break;
		}    
    SQLRETURN sqlReturn;
    sqlReturn = ::SQLBindCol(hStmt, aMetadata[i]->GetOrdinalPosition(), odbcType, 
                             mBuffer + mOffsets[i], bufferSizes[i], 
                             &((SQLLEN *)(mBuffer + mNullIndicatorOffset))[i]);
    if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt); 

    if (aMetadata[i]->GetDataType() == eDecimal)
    {
      int precision = aMetadata[i]->GetPrecision();
      int scale = aMetadata[i]->GetDecimalDigits();
      SQLHDESC hDesc = NULL;
      sqlReturn = ::SQLGetStmtAttr(hStmt, SQL_ATTR_APP_ROW_DESC, &hDesc, 0, NULL);
      if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt);

      // By default, the driver will assume a scale of 0.  We need to tell to use the configured scale.  This
      // code follows the MS KB article Q222831.
      sqlReturn = ::SQLSetDescField(hDesc, aMetadata[i]->GetOrdinalPosition(), 
                                    SQL_DESC_TYPE, (SQLPOINTER) SQL_C_NUMERIC, 0);
      if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
      sqlReturn = ::SQLSetDescField(hDesc, aMetadata[i]->GetOrdinalPosition(), 
                                    SQL_DESC_PRECISION, (SQLPOINTER) precision, 0);
      if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
      sqlReturn = ::SQLSetDescField(hDesc, aMetadata[i]->GetOrdinalPosition(), 
                                    SQL_DESC_SCALE, (SQLPOINTER) scale, 0);
      if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
      sqlReturn = ::SQLSetDescField(hDesc, aMetadata[i]->GetOrdinalPosition(), 
                                    SQL_DESC_DATA_PTR, (SQLPOINTER) (mBuffer + mOffsets[i]), 0);
      if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
    }
  }
}

COdbcRowArrayResultSet::~COdbcRowArrayResultSet()
{
  delete [] mBuffer;
  delete [] mRowStatus;
  
}

int COdbcRowArrayResultSet::GetInteger(int aPos)
{
  mLastPos = aPos;
  return *((const int *) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]));
}

__int64 COdbcRowArrayResultSet::GetBigIntegerSQLServer(int aPos)
{
  mLastPos = aPos;
  if(WasNull())
    return 0;
  else
  {
    return *((__int64 *)(mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]));
  }
}

__int64 COdbcRowArrayResultSet::GetBigIntegerOracle(int aPos)
{
  mLastPos = aPos;
  __int64 out;
  if(WasNull())
    return 0;
  else
  {
    SQL_NUMERIC_STRUCT * data((SQL_NUMERIC_STRUCT *)(mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]));
    memcpy(&out, data->val, 8);
    return out;
  }
}

__int64 COdbcRowArrayResultSet::GetBigInteger(int aPos)
{
  return (this->*mBigIntegerGetter)(aPos);
}

string COdbcRowArrayResultSet::GetString(int aPos)
{
  mLastPos = aPos;
  return string(WasNull() ?
                "" :
                (const char *) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]));
}

double COdbcRowArrayResultSet::GetDouble(int aPos)
{
  mLastPos = aPos;
  return *((const double *) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]));
}

COdbcTimestamp COdbcRowArrayResultSet::GetTimestamp(int aPos)
{
  mLastPos = aPos;
  return COdbcTimestamp((TIMESTAMP_STRUCT *) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]), true);
}

DATE COdbcRowArrayResultSet::GetOLEDate(int aPos)
{
  mLastPos = aPos;
  DATE dt(0.0);
  if (!WasNull())
  {
    ::OdbcTimestampToOLEDate((const TIMESTAMP_STRUCT *) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]), &dt);
  }
  return dt;
}

COdbcDecimal COdbcRowArrayResultSet::GetDecimal(int aPos)
{
  mLastPos = aPos;
  return COdbcDecimal((SQL_NUMERIC_STRUCT *) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]), true);
}

vector<unsigned char> COdbcRowArrayResultSet::GetBinary(int aPos)
{
  mLastPos = aPos;
  SQLLEN ind(*((const SQLLEN *)(mBuffer + mBufferSize*mArraySize + mNullIndicatorOffset + sizeof(SQLLEN)*(mLastPos-1))));
  if (ind == SQL_NULL_DATA) return vector <unsigned char>();

  vector <unsigned char> ret;
  for (SQLINTEGER i=0; i<ind; i++)
  {
    ret.push_back(*(mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1] + i));
  }
  return ret;
}

wstring COdbcRowArrayResultSet::GetWideString(int aPos)
{
  mLastPos = aPos;
  return wstring(WasNull() ?
                 L"" :
                 (const wchar_t *) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]));
}

const SQL_NUMERIC_STRUCT * COdbcRowArrayResultSet::GetDecimalBuffer(int aPos)
{
  mLastPos = aPos;
  return (const SQL_NUMERIC_STRUCT *) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]);
}

const unsigned char * COdbcRowArrayResultSet::GetBinaryBuffer(int aPos)
{
  mLastPos = aPos;
  return (const unsigned char *) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]);
}

const wchar_t* COdbcRowArrayResultSet::GetWideStringBuffer(int aPos)
{
  mLastPos = aPos;
  return (const wchar_t *) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]);
}

const char* COdbcRowArrayResultSet::GetStringBuffer(int aPos)
{
  mLastPos = aPos;
  return (const char *) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]);
}

bool COdbcRowArrayResultSet::WasNull() const
{
  return SQL_NULL_DATA == *((const SQLLEN *)(mBuffer + mBufferSize*mArraySize + mNullIndicatorOffset + sizeof(SQLLEN)*(mLastPos-1)));
}

// Move cursor to the next row.  The cursor is initially
// positioned just before the first row.
bool COdbcRowArrayResultSet::Next()
{
  mArraySize += 1;
  if (mArraySize < mRowsFetched)
  {
    return true;
  }
  else
  {
    SQLRETURN sqlReturn;
    sqlReturn = ::SQLFetch(mStatement->GetHandle());
    mArraySize = 0;
    if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO && sqlReturn != SQL_NO_DATA) throw COdbcStatementException(mStatement->GetHandle());
    return sqlReturn != SQL_NO_DATA;  
  }
}

bool COdbcRowArrayResultSet::NextResultSet()
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLMoreResults(mStatement->GetHandle());
	if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO && sqlReturn != SQL_NO_DATA) throw COdbcStatementException(mStatement->GetHandle());
	return sqlReturn != SQL_NO_DATA;
}

const unsigned char * COdbcRowArrayResultSet::GetDataBuffer()
{
  return mBuffer + mBufferSize*mArraySize;
}

std::size_t COdbcRowArrayResultSet::GetNullOffset()
{
  return mNullIndicatorOffset;
}

std::size_t COdbcRowArrayResultSet::GetDataOffset(int pos)
{
  ASSERT(pos >= 1);
  return mOffsets[pos-1];
}

//--------------------------------- Oracle ---------------------------
// Oracle treats empty space as NULL, so we write in a special
// character in place and need to strip it on retrieval.
//--------------------------------------------------------------------
string COdbcOracleResultSet::GetString(int aPos)
{
	string retVal = COdbcResultSet::GetString(aPos);
	if (retVal == (char*) MTEmptyString)
		return "";
	else
		return retVal;
}

wstring COdbcOracleResultSet::GetWideString(int aPos)
{
	wstring retVal = COdbcResultSet::GetWideString(aPos);
	if (retVal == (wchar_t*) MTEmptyString)
		return L"";
	else
		return retVal;
}

string COdbcOraclePreparedResultSet::GetString(int aPos)
{
	const char* val = mBindings[mLastPos=(aPos-1)]->GetStringBuffer();
	if (val == NULL || strcmp(val, MTEmptyString) == 0)
		return "";
	else
		return val;
}

wstring COdbcOraclePreparedResultSet::GetWideString(int aPos)
{
	const wchar_t* val = mBindings[mLastPos=(aPos-1)]->GetWideStringBuffer();
	if (val == NULL || wcscmp(val, MTEmptyString) == 0)
		return L"";
	else
		return val;
}

const wchar_t* COdbcOraclePreparedResultSet::GetWideStringBuffer(int aPos)
{
	wchar_t* val = (wchar_t*) mBindings[mLastPos=(aPos-1)]->GetRawData();
	if (val && wcscmp(val, MTEmptyString) == 0)
		wcscpy(val, L"");

	return val;
}

string COdbcOracleRowArrayResultSet::GetString(int aPos)
{
	mLastPos = aPos;
	const char* val = (const char*) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]);
	if (WasNull() || strcmp(val, MTEmptyString) == 0)
		return "";
	else
		return val;
}

wstring COdbcOracleRowArrayResultSet::GetWideString(int aPos)
{
	mLastPos = aPos;
	const wchar_t* val = (const wchar_t*) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]);
	if (WasNull() || wcscmp(val, MTEmptyString) == 0)
		return L"";
	else
		return val;
}

const wchar_t* COdbcOracleRowArrayResultSet::GetWideStringBuffer(int aPos)
{
	mLastPos = aPos;
	wchar_t* val = (wchar_t*) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]);
	if (!WasNull() && wcscmp(val, MTEmptyString) == 0)
		wcscpy(val, L"");

	return val;
}

const char* COdbcOracleRowArrayResultSet::GetStringBuffer(int aPos)
{
	mLastPos = aPos;
	char* val = (char*) (mBuffer + mBufferSize*mArraySize + mOffsets[aPos-1]);
	if (!WasNull() && strcmp(val, MTEmptyString) == 0)
		val[0] = '\0';  

	return val;
}
