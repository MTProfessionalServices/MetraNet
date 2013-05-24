// OdbcPreparedArrayStatement.cpp: implementation of the COdbcPreparedArrayStatement class.
//
//////////////////////////////////////////////////////////////////////

// Tell Windows not to provide MIN/MAX macros
#define NOMINMAX

#pragma warning( disable : 4786 ) 

//#include "bcp.h"
#include <metra.h>
#include <MTUtil.h>
#include <SqlUcode.h>
#include <base64.h>
#include <limits>
#include "OdbcPreparedArrayStatement.h"

#include "OdbcConnection.h"
#include "OdbcStatementGenerator.h"
#include "OdbcException.h"
#include "OdbcResultSet.h"
#include "OdbcSessionTypeConversion.h"

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#include <mtprogids.h>
#include <map>

using namespace QUERYADAPTERLib;


static void ProcessStatementError(SQLRETURN sqlReturn, HSTMT hStmt)
{
	if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)
		throw COdbcStatementException(hStmt);
}

class COdbcColumnArrayBinding
{
public:
	virtual void Bind(HSTMT hStmt, int pos) { ASSERT(FALSE); }
	virtual void SetInteger(int pos, int val) { ASSERT(FALSE); }
	virtual void SetString(int pos, const string& val) { ASSERT(FALSE); }
	virtual void SetString(int pos, const char * val, int length) { ASSERT(FALSE); }
	virtual void SetDouble(int pos, double val) { ASSERT(FALSE); }
	virtual void SetDatetime(int pos, const TIMESTAMP_STRUCT& val) { ASSERT(FALSE); }
	virtual void SetDatetime(int pos, const DATE * val) { ASSERT(FALSE); }
	virtual void SetDecimal(int pos, const SQL_NUMERIC_STRUCT& val) { ASSERT(FALSE); }
	virtual void SetDecimal(int pos, const DECIMAL * val) { ASSERT(FALSE); }
	virtual void SetBinary(int pos, const unsigned char* val, int length) { ASSERT(FALSE); }
	virtual void SetWideString(int pos, const wstring& val) { ASSERT(FALSE); }
	virtual void SetWideString(int pos, const wchar_t * val, int length) { ASSERT(FALSE); }
	virtual void SetBigInteger(int pos, __int64 val) { ASSERT(FALSE); }

	// Higher performance "reference accessors"
	virtual int* GetIntegerRef(int pos) { ASSERT(FALSE); return NULL; }
	virtual SQLCHAR* GetStringRef(int pos) { ASSERT(FALSE); return NULL; }
	virtual double* GetDoubleRef(int pos) { ASSERT(FALSE); return NULL; }
	virtual TIMESTAMP_STRUCT* GetDatetimeRef(int pos) { ASSERT(FALSE); return NULL; }
	virtual SQL_NUMERIC_STRUCT* GetDecimalRef(int pos) { ASSERT(FALSE); return NULL; }
	virtual unsigned char* GetBinaryRef(int pos) { ASSERT(FALSE); return NULL; }
	virtual wchar_t* GetWideCharRef(int pos) { ASSERT(FALSE); return NULL; }
	virtual __int64* GetBigIntegerRef(int pos) { ASSERT(FALSE); return NULL; }

	virtual wstring GetAsWString(int row) = 0;

	// Clear all values
	virtual void Clear() =0;

	virtual ~COdbcColumnArrayBinding() {}
};

//////////////////////////////////////////////////////////////////////
// Integer Binding 
//////////////////////////////////////////////////////////////////////

class COdbcColumnArrayIntegerBinding : public COdbcColumnArrayBinding
{
private:
	SQLINTEGER* mData;
	SQLINTEGER* mInd;
	int mSize;
public:
	void Bind(HSTMT hStmt, int pos);
	void SetInteger(int pos, int val);
	void Clear();
	wstring GetAsWString(int row);
	COdbcColumnArrayIntegerBinding(int size);
	~COdbcColumnArrayIntegerBinding();
};

COdbcColumnArrayIntegerBinding::COdbcColumnArrayIntegerBinding(int size) : mSize(size)
{
	mData = new SQLINTEGER [mSize];
	mInd = new SQLINTEGER [mSize];
	Clear();
}

COdbcColumnArrayIntegerBinding::~COdbcColumnArrayIntegerBinding()
{
	delete [] mData;
	delete [] mInd;
}

void COdbcColumnArrayIntegerBinding::SetInteger(int pos, int val)
{
	mData[pos] = val;
	mInd[pos] = 0;
}

void COdbcColumnArrayIntegerBinding::Bind(HSTMT hStmt, int pos)
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLBindParameter(hStmt, pos, 
		SQL_PARAM_INPUT, 
		SQL_C_LONG,
		SQL_INTEGER, 
		5, /* Column Size - ignored */
		0, /* Decimal Digits */
		mData, 
		0, 
		mInd);
	ProcessStatementError(sqlReturn, hStmt);
}

wstring COdbcColumnArrayIntegerBinding::GetAsWString(int row)
{
	wstring str;

	if(row < mSize)
	{
		if(mInd[row] == SQL_NULL_DATA)
			str	= L"<NULL>";
		else
		{
			wchar_t buf[50];
			int data = mData[row];
			swprintf(buf, L"%i", data);
			str = buf;
		}
	}
	else
	{	
		ASSERT(0); //out of bounds
	}

	return str;
}


void COdbcColumnArrayIntegerBinding::Clear()
{
	memset(mData, 0, mSize*sizeof(SQLINTEGER));
	// Set NULL indicators
	for(int i=0; i<mSize; i++)
	{
		mInd[i] = SQL_NULL_DATA;
	}
}

//////////////////////////////////////////////////////////////////////
// String Binding 
//////////////////////////////////////////////////////////////////////

class COdbcColumnArrayStringBinding : public COdbcColumnArrayBinding
{
private:
	SQLCHAR** mData;
	SQLINTEGER* mInd;
	int mSize;
   int mBufSize;
	SQLINTEGER mColumnSize;
  
  // we must save these because we might rebind due to
  // dynamic sizing of buffers.  We do this because
  // the column size in the database might be very pessimistically long
  // and we don't want to take up too much buffer space that we'll never
  // use.
  HSTMT mStmt;
  int mPosition;
  SQLINTEGER mAllocatedColumnSize;
  void Bind();
  void Alloc(SQLINTEGER newColumnSize);
public:
	void Bind(HSTMT hStmt, int pos);
	void SetString(int pos, const string& val);
	void SetString(int pos, const char * val, int length);
	void Clear();
	wstring GetAsWString(int row);
	COdbcColumnArrayStringBinding(int size, const COdbcParameterMetadata* metadata);
	~COdbcColumnArrayStringBinding();
};

COdbcColumnArrayStringBinding::COdbcColumnArrayStringBinding(int size, 
                                                             const COdbcParameterMetadata* metadata) 
  : 
  mSize(size), 
  mStmt(NULL),
  mPosition(0),
  mData(NULL),
  mInd(NULL),
  mAllocatedColumnSize(0)
{
	ASSERT(metadata->GetDataType() == eString);
  // For large objects the column size may come in negative.
	mColumnSize = metadata->GetColumnSize() > 0 ? metadata->GetColumnSize() : std::numeric_limits<SQLINTEGER>::max();
	mData = new SQLCHAR*[mSize];
  mData[0] = NULL;
	mInd = new SQLINTEGER [mSize];
  // Create buffer, no larger than 16 characters at first.  Will dynamically grow as needed.
  Alloc(mColumnSize < 16 ? mColumnSize : 16);
	Clear();
}

COdbcColumnArrayStringBinding::~COdbcColumnArrayStringBinding()
{
	delete [] mData[0];
	delete [] mData;
	delete [] mInd;
}

void COdbcColumnArrayStringBinding::Bind()
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLBindParameter(mStmt, mPosition, 
		SQL_PARAM_INPUT, 
		SQL_C_CHAR,
		mColumnSize > 4000 ? SQL_LONGVARCHAR : SQL_VARCHAR, 
		mColumnSize, /* Column Size */
		0, /* Decimal Digits */
		mData[0], /* Our buffer */
    mAllocatedColumnSize + 1, /* Buffer Offset to next in the array */
		mInd);
	ProcessStatementError(sqlReturn, mStmt);
}

void COdbcColumnArrayStringBinding::Alloc(SQLINTEGER newColumnSize)
{
  int newBufSize = (newColumnSize+1)*mSize;
  SQLCHAR * newBuffer = new SQLCHAR[newBufSize];
  if (mAllocatedColumnSize > 0)
  {
    // Move data to the new buffer.
    SQLCHAR * newData = newBuffer;
    SQLCHAR * oldData = mData[0];
    ASSERT(oldData != NULL);
    for(int i=0; i<mSize; i++)
    {
      memcpy(newData, oldData, (mAllocatedColumnSize+1)*sizeof(SQLCHAR));
      newData += (newColumnSize + 1);
      oldData += (mAllocatedColumnSize+1);
    }
    delete [] mData[0];
  }
  mAllocatedColumnSize = newColumnSize;
  mBufSize = sizeof(SQLCHAR)*(mAllocatedColumnSize + 1)*mSize;
	for(int j=0; j<mSize; j++)
	{
		mData[j] = newBuffer + j*(mAllocatedColumnSize+1);
	}
}

void COdbcColumnArrayStringBinding::SetString(int pos, const string& val)
{
	string::size_type sz = val.size();
  SetString(pos, val.c_str(), int(sz));
}

void COdbcColumnArrayStringBinding::SetString(int pos, const char * val, int sz)
{
	if(sz > mColumnSize)
	{
		char buf[256];
		sprintf(buf, 
						"String parameter has maximum length %d and argument has length %d.", 
						mColumnSize, 
						sz);
		throw COdbcBindingException(buf);
	}
  else if (sz > mAllocatedColumnSize)
  {
    SQLINTEGER newColumnSize = 2*mAllocatedColumnSize;
    if (newColumnSize > mColumnSize)
    {
      newColumnSize = mColumnSize;
    }
    else if (sz > newColumnSize)
    {
      newColumnSize = sz;
    }
    // Realloc and rebind.
    Alloc(newColumnSize);
    Bind();
  }
	strcpy((char*)(mData[pos]), val);
	mInd[pos] = SQL_NTS;
}

void COdbcColumnArrayStringBinding::Bind(HSTMT hStmt, int pos)
{
  ASSERT(mStmt == NULL || mStmt == hStmt);
  ASSERT(mPosition == 0 || mPosition == pos);
  mStmt = hStmt;
  mPosition = pos;
  Bind();
}

void COdbcColumnArrayStringBinding::Clear()
{
  if (mData[0] != NULL)
    memset(mData[0], 0x0, mBufSize);
	// Set NULL indicators
	for(int i=0; i<mSize; i++)
	{
		mInd[i] = SQL_NULL_DATA;
	}
}

wstring COdbcColumnArrayStringBinding::GetAsWString(int row)
{
	wstring str;

	if(row < mSize)
	{
		if(mInd[row] == SQL_NULL_DATA)
			str	= L"<NULL>";
		else
		{
			SQLCHAR* data = mData[row];
			ASCIIToWide(str, (const char *)data);
		}
	}
	else
	{	
		ASSERT(0); //out of bounds
	}

	return str;
}


//////////////////////////////////////////////////////////////////////
// Decimal Binding 
//////////////////////////////////////////////////////////////////////

class COdbcColumnArrayDecimalBinding : public COdbcColumnArrayBinding
{
private:
	SQL_NUMERIC_STRUCT* mData;
	SQLINTEGER* mInd;
	int mSize;
	SQLINTEGER mPrecision;
	SQLINTEGER mScale;
public:
	void Bind(HSTMT hStmt, int pos);
	void SetDecimal(int pos, const SQL_NUMERIC_STRUCT& val);
	void SetDecimal(int pos, const DECIMAL * val);
	void SetBigInteger(int pos, __int64 val);
	void Clear();
	wstring GetAsWString(int row);
	COdbcColumnArrayDecimalBinding(int size, const COdbcParameterMetadata* metadata);
	~COdbcColumnArrayDecimalBinding();
};

COdbcColumnArrayDecimalBinding::COdbcColumnArrayDecimalBinding(int size, 
															 const COdbcParameterMetadata* metadata) : mSize(size)
{
	ASSERT(metadata->GetDataType() == eDecimal || metadata->GetDataType() == eBigInteger);
	mPrecision = metadata->GetPrecision();
	mScale = metadata->GetDecimalDigits();
	mData = new SQL_NUMERIC_STRUCT [mSize];
	mInd = new SQLINTEGER [mSize];
	Clear();
}

COdbcColumnArrayDecimalBinding::~COdbcColumnArrayDecimalBinding()
{
	delete [] mData;
	delete [] mInd;
}

void COdbcColumnArrayDecimalBinding::SetDecimal(int pos, const SQL_NUMERIC_STRUCT& val)
{
	ASSERT(val.precision == mPrecision);
	ASSERT(val.scale == mScale);
	mData[pos].precision = val.precision;
	mData[pos].scale = val.scale;
	mData[pos].sign = val.sign;
	memcpy(mData[pos].val, val.val, sizeof(val.val));

	mInd[pos] = 0;
}
void COdbcColumnArrayDecimalBinding::SetDecimal(int pos, const DECIMAL * val)
{
  // DECIMAL and SQL_NUMERIC_STRUCT are typedefs
  ::DecimalToOdbcNumeric(val, &mData[pos]);
	mInd[pos] = 0;
}

// Set a decimal binding with a bigint value.
// The Oracle/ODBC alliance doesn't seem to work correctly with
// int64 types.  The alternative is use the decimal binding
// and pass in an int64.
void COdbcColumnArrayDecimalBinding::SetBigInteger(int pos, __int64 val)
{
	mData[pos].precision = (BYTE)mPrecision;
	mData[pos].scale = 0;
	mData[pos].sign = val < 0 ? 0 : 1;

	// if negative flag is set, then store positive value.
	if (mData[pos].sign == 0)
		val = -val;

	memset(mData[pos].val, 0, sizeof(mData[pos].val));
	memcpy(mData[pos].val, &val, sizeof(val));

	mInd[pos] = 0;
}

void COdbcColumnArrayDecimalBinding::Bind(HSTMT hStmt, int pos)
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLBindParameter(hStmt, pos, 
		SQL_PARAM_INPUT, 
		SQL_C_NUMERIC,
		SQL_NUMERIC, 
		mPrecision, /* Column Size */
		(SQLSMALLINT) mScale, /* Decimal Digits */
		mData, 
		0, 
		mInd);

	SQLHDESC hDesc = NULL;
	sqlReturn = ::SQLGetStmtAttr(hStmt, SQL_ATTR_APP_PARAM_DESC, &hDesc, 0, NULL);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcStatementException(hStmt);

	// By default, the driver will assume a scale of 0.  We need to tell to use the configured scale.  This
	// code follows the MS KB article Q181254.
	sqlReturn = ::SQLSetDescField(hDesc, pos, SQL_DESC_TYPE, (SQLPOINTER) SQL_C_NUMERIC, 0);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
	sqlReturn = ::SQLSetDescField(hDesc, pos, SQL_DESC_PRECISION, (SQLPOINTER) mPrecision, 0);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
	sqlReturn = ::SQLSetDescField(hDesc, pos, SQL_DESC_SCALE, (SQLPOINTER) mScale, 0);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
	sqlReturn = ::SQLSetDescField(hDesc, pos, SQL_DESC_DATA_PTR, (SQLPOINTER) mData, 0);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);
	sqlReturn = ::SQLSetDescField(hDesc, pos, SQL_DESC_INDICATOR_PTR, (SQLPOINTER) mInd, 0);
	if (sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO) throw COdbcDescriptorException(hDesc);

	ProcessStatementError(sqlReturn, hStmt);
}

void COdbcColumnArrayDecimalBinding::Clear()
{
	memset(mData, 0x00, mSize*sizeof(SQL_NUMERIC_STRUCT));
	// Set NULL indicators
	for(int i=0; i<mSize; i++)
	{
		mInd[i] = SQL_NULL_DATA;
	}
}

wstring COdbcColumnArrayDecimalBinding::GetAsWString(int row)
{
	wstring str;

	if(row < mSize)
	{
		if(mInd[row] == SQL_NULL_DATA)
			str	= L"<NULL>";
		else
		{
			wchar_t buf[100];
			SQL_NUMERIC_STRUCT& data = mData[row];

			double dVal = OdbcNumericToDouble(&data);
			swprintf(buf, L"%f", dVal);
			str = buf;
		}
	}
	else
	{	
		ASSERT(0); //out of bounds
	}

	return str;
}


//////////////////////////////////////////////////////////////////////
// Datetime Binding 
//////////////////////////////////////////////////////////////////////

class COdbcColumnArrayDatetimeBinding : public COdbcColumnArrayBinding
{
private:
	TIMESTAMP_STRUCT* mData;
	SQLINTEGER* mInd;
	int mSize;
public:
	void Bind(HSTMT hStmt, int pos);
	void SetDatetime(int pos, const TIMESTAMP_STRUCT& val);
	void SetDatetime(int pos, const DATE * val);
	void Clear();
	wstring GetAsWString(int row);
	COdbcColumnArrayDatetimeBinding(int size, const COdbcParameterMetadata* metadata);
	~COdbcColumnArrayDatetimeBinding();
};

COdbcColumnArrayDatetimeBinding::COdbcColumnArrayDatetimeBinding(int size, 
															 const COdbcParameterMetadata* metadata) : mSize(size)
{
	ASSERT(metadata->GetDataType() == eDatetime);
	mData = new TIMESTAMP_STRUCT [mSize];
	mInd = new SQLINTEGER [mSize];
	Clear();
}

COdbcColumnArrayDatetimeBinding::~COdbcColumnArrayDatetimeBinding()
{
	delete [] mData;
	delete [] mInd;
}

void COdbcColumnArrayDatetimeBinding::SetDatetime(int pos, const TIMESTAMP_STRUCT& val)
{
	mData[pos].day = val.day;
	mData[pos].month = val.month;
	mData[pos].year = val.year;
	mData[pos].hour = val.hour;
	mData[pos].minute = val.minute;
	mData[pos].second = val.second;
	mData[pos].fraction = val.fraction;

	mInd[pos] = 0;
}

void COdbcColumnArrayDatetimeBinding::SetDatetime(int pos, const DATE * val)
{
  ::OLEDateToOdbcTimestamp(val, &mData[pos]);
	mInd[pos] = 0;
}

void COdbcColumnArrayDatetimeBinding::Bind(HSTMT hStmt, int pos)
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLBindParameter(hStmt, pos, 
		SQL_PARAM_INPUT, 
		SQL_C_TYPE_TIMESTAMP,
		SQL_TIMESTAMP, 
///		22, 
		23, 
		3, 
		mData, 
		0, 
		mInd);
	ProcessStatementError(sqlReturn, hStmt);
}

void COdbcColumnArrayDatetimeBinding::Clear()
{
	memset(mData, 0, mSize*sizeof(TIMESTAMP_STRUCT));
	// Set NULL indicators
	for(int i=0; i<mSize; i++)
	{
		mInd[i] = SQL_NULL_DATA;
	}
}

wstring COdbcColumnArrayDatetimeBinding::GetAsWString(int row)
{
	wstring str;

	if(row < mSize)
	{
		if(mInd[row] == SQL_NULL_DATA)
			str	= L"<NULL>";
		else
		{
			time_t timeT;
			string timeStr;
			TIMESTAMP_STRUCT& timeStruc = mData[row];
			
			//convert to wstring in 3 easy steps
			OdbcTimestampToTimet(&timeStruc, &timeT);
			MTFormatISOTime(timeT, timeStr);
			ASCIIToWide(str, timeStr);
		}
	}
	else
	{	
		ASSERT(0); //out of bounds
	}

	return str;
}


//////////////////////////////////////////////////////////////////////
// Double Binding 
//////////////////////////////////////////////////////////////////////

class COdbcColumnArrayDoubleBinding : public COdbcColumnArrayBinding
{
private:
	double* mData;
	SQLINTEGER* mInd;
	int mSize;
public:
	void Bind(HSTMT hStmt, int pos);
	void SetDouble(int pos, double val);
	void Clear();
	wstring GetAsWString(int row);
	COdbcColumnArrayDoubleBinding(int size, const COdbcParameterMetadata* metadata);
	~COdbcColumnArrayDoubleBinding();
};

COdbcColumnArrayDoubleBinding::COdbcColumnArrayDoubleBinding(int size, 
															 const COdbcParameterMetadata* metadata) : mSize(size)
{
	ASSERT(metadata->GetDataType() == eDouble);
	mData = new double [mSize];
	mInd = new SQLINTEGER [mSize];
	Clear();
}

COdbcColumnArrayDoubleBinding::~COdbcColumnArrayDoubleBinding()
{
	delete [] mData;
	delete [] mInd;
}

void COdbcColumnArrayDoubleBinding::SetDouble(int pos, double val)
{
	mData[pos] = val;
	mInd[pos] = 0;
}

void COdbcColumnArrayDoubleBinding::Bind(HSTMT hStmt, int pos)
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLBindParameter(hStmt, pos, 
		SQL_PARAM_INPUT, 
		SQL_C_DOUBLE,
		SQL_DOUBLE, 
		15, 
		0, 
		mData, 
		0, 
		mInd);
	ProcessStatementError(sqlReturn, hStmt);
}

void COdbcColumnArrayDoubleBinding::Clear()
{
	memset(mData, 0, mSize*sizeof(double));
	// Set NULL indicators
	for(int i=0; i<mSize; i++)
	{
		mInd[i] = SQL_NULL_DATA;
	}
}

wstring COdbcColumnArrayDoubleBinding::GetAsWString(int row)
{
	wstring str;

	if(row < mSize)
	{
		if(mInd[row] == SQL_NULL_DATA)
			str	= L"<NULL>";
		else
		{
			wchar_t buf[100];
			double data = mData[row];
			swprintf(buf, L"%f", data);
			str = buf;
		}
	}
	else
	{	
		ASSERT(0); //out of bounds
	}

	return str;
}


//////////////////////////////////////////////////////////////////////
// Binary Binding 
//////////////////////////////////////////////////////////////////////

class COdbcColumnArrayBinaryBinding : public COdbcColumnArrayBinding
{
private:
	SQLCHAR** mData;
	SQLINTEGER* mInd;
	int mSize;
   int mBufSize;
	SQLINTEGER mColumnSize;
public:
	void Bind(HSTMT hStmt, int pos);
	void SetBinary(int pos, const unsigned char* val, int length);
	void Clear();
	wstring GetAsWString(int row);
	COdbcColumnArrayBinaryBinding(int size, const COdbcParameterMetadata* metadata);
	~COdbcColumnArrayBinaryBinding();
};

COdbcColumnArrayBinaryBinding::COdbcColumnArrayBinaryBinding(int size, 
															 const COdbcParameterMetadata* metadata) : mSize(size)
{
	ASSERT(metadata->GetDataType() == eBinary);
	mColumnSize = metadata->GetColumnSize();
   mBufSize = (mColumnSize+1)*mSize;
	mData = new SQLCHAR* [mSize];
	mData[0] = new SQLCHAR[mBufSize];
	for(int j=1; j<mSize; j++)
	{
		mData[j] = mData[0] + j*(mColumnSize+1);
	}
	mInd = new SQLINTEGER [mSize];
	Clear();
}

COdbcColumnArrayBinaryBinding::~COdbcColumnArrayBinaryBinding()
{
	delete [] mData[0];
	delete [] mData;
	delete [] mInd;
}

void COdbcColumnArrayBinaryBinding::SetBinary(int pos, const unsigned char* val, int length)
{
	if(length > mColumnSize)
	{
		char buf[256];
		sprintf(buf, 
						"String parameter has maximum length %d and argument has length %d.", 
						mColumnSize, 
						length);
		throw COdbcBindingException(buf);
	}
	memcpy((char*)(mData[pos]), val, length);
	mInd[pos] = length;
}

void COdbcColumnArrayBinaryBinding::Bind(HSTMT hStmt, int pos)
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLBindParameter(hStmt, pos, 
		SQL_PARAM_INPUT, 
		SQL_C_BINARY,
		SQL_VARBINARY, 
		mColumnSize, /* Column Size */
		0, /* Decimal Digits */
		mData[0], 
		mColumnSize + 1, 
		mInd);
	ProcessStatementError(sqlReturn, hStmt);
}

void COdbcColumnArrayBinaryBinding::Clear()
{
	memset(mData[0], 0, mBufSize*sizeof(SQLCHAR));
	// Set NULL indicators
	for(int i=0; i<mSize; i++)
	{
		mInd[i] = SQL_NULL_DATA;
	}
}

wstring COdbcColumnArrayBinaryBinding::GetAsWString(int row)
{
	wstring wstr;

	if(row < mSize)
	{
		if(mInd[row] == SQL_NULL_DATA)
			wstr	= L"<NULL>";
		else
		{
			string str;
			SQLCHAR* data = mData[row];

			rfc1421encode_nonewlines(data, mInd[row], str);
			ASCIIToWide(wstr, str);
		}
	}
	else
	{	
		ASSERT(0); //out of bounds
	}

	return wstr;
}

//////////////////////////////////////////////////////////////////////
// Wide Char Binding 
//////////////////////////////////////////////////////////////////////

class COdbcColumnArrayWideStringBinding : public COdbcColumnArrayBinding
{
private:
	wchar_t** mData;
	SQLINTEGER* mInd;
	int mSize; // # of rows
	SQLINTEGER mColumnSize; // col width
   int mBufSize;  // rows * col * sizeof(wchar_t) width

  // we must save these because we might rebind due to
  // dynamic sizing of buffers.  We do this because
  // the column size in the database might be very pessimistically long
  // and we don't want to take up too much buffer space that we'll never
  // use.
  HSTMT mStmt;
  int mPosition;
  SQLINTEGER mAllocatedColumnSize;
  void Bind();
  void Alloc(SQLINTEGER newColumnSize);
public:
	void Bind(HSTMT hStmt, int pos);
	void SetWideString(int pos, const wstring& val);
	void SetWideString(int pos, const wchar_t * val, int length);
	void Clear();
	wstring GetAsWString(int row);
	COdbcColumnArrayWideStringBinding(int size, const COdbcParameterMetadata* metadata);
	~COdbcColumnArrayWideStringBinding();
};

COdbcColumnArrayWideStringBinding::COdbcColumnArrayWideStringBinding(int size, 
                                                                     const COdbcParameterMetadata* metadata) 
  : 
  mSize(size),
  mData(NULL),
  mInd(NULL),
  mColumnSize(0),
  mBufSize(0),
  mStmt(NULL),
  mPosition(0),
  mAllocatedColumnSize(0)
{
	ASSERT(metadata->GetDataType() == eWideString);
	mColumnSize = metadata->GetColumnSize() > 0 ? metadata->GetColumnSize() : std::numeric_limits<SQLINTEGER>::max()-1;
	mData = new wchar_t*[mSize]; // offsets into buffer; one per row
  mData[0] = NULL;
	mInd = new SQLINTEGER [mSize];
  Alloc(mColumnSize < 16 ? mColumnSize : 16);
	Clear();
}

COdbcColumnArrayWideStringBinding::~COdbcColumnArrayWideStringBinding()
{
	delete [] mData[0];
	delete [] mData;
	delete [] mInd;
}

void COdbcColumnArrayWideStringBinding::Bind()
{
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLBindParameter(mStmt, mPosition, 
																 SQL_PARAM_INPUT, 
																 SQL_C_WCHAR,
																 mColumnSize > 2000 ? SQL_WLONGVARCHAR : SQL_WVARCHAR, 
																 mColumnSize, // Column Size 
																 0, // Decimal Digits 
																 mData[0], 
																 (mAllocatedColumnSize + 1)*sizeof(wchar_t), // per column buffer size
																 mInd);
	ProcessStatementError(sqlReturn, mStmt);
}

void COdbcColumnArrayWideStringBinding::Alloc(SQLINTEGER newColumnSize)
{
  int newBufSize = (newColumnSize+1)*mSize;
  wchar_t * newBuffer = new wchar_t[newBufSize];
  if (mAllocatedColumnSize > 0)
  {
    // Move data to the new buffer.
    wchar_t * newData = newBuffer;
    wchar_t * oldData = mData[0];
    ASSERT(oldData != NULL);
    for(int i=0; i<mSize; i++)
    {
      memcpy(newData, oldData, (mAllocatedColumnSize+1)*sizeof(wchar_t));
      newData += (newColumnSize + 1);
      oldData += (mAllocatedColumnSize+1);
    }
    delete [] mData[0];
  }
  mAllocatedColumnSize = newColumnSize;
  mBufSize = sizeof(wchar_t)*(mAllocatedColumnSize + 1)*mSize;
	for(int j=0; j<mSize; j++)
	{
		mData[j] = newBuffer + j*(mAllocatedColumnSize+1);
	}
}

void COdbcColumnArrayWideStringBinding::SetWideString(int pos, const wstring& val)
{
	wstring::size_type sz = val.size();
	if(sz > (wstring::size_type)mColumnSize)
	{
		char buf[256];
		sprintf(buf, 
						"Wide string parameter has maximum length %d characters and argument has length %d characters.", 
						mColumnSize, 
						sz);
		throw COdbcBindingException(buf);
	}
  else if (sz > wstring::size_type(mAllocatedColumnSize))
  {
    SQLINTEGER newColumnSize = 2*mAllocatedColumnSize;
    if (newColumnSize > mColumnSize)
    {
      newColumnSize = mColumnSize;
    }
    else if (sz > wstring::size_type(newColumnSize))
    {
      newColumnSize = sz;
    }
    // Realloc and rebind.
    Alloc(newColumnSize);
    Bind();
  }
	wcscpy(mData[pos], val.c_str());
	mInd[pos] = SQL_NTS;
}
void COdbcColumnArrayWideStringBinding::SetWideString(int pos, const wchar_t * val, int length)
{
	if(length > mColumnSize)
	{
		char buf[256];
		sprintf(buf, 
			"Wide string parameter has maximum length %d and argument has length %d.", 
			mColumnSize, 
			length);
		throw COdbcBindingException(buf);
	}
  else if (length > mAllocatedColumnSize)
  {
    SQLINTEGER newColumnSize = 2*mAllocatedColumnSize;
    if (newColumnSize > mColumnSize)
    {
      newColumnSize = mColumnSize;
    }
    else if (length > newColumnSize)
    {
      newColumnSize = length;
    }
    // Realloc and rebind.
    Alloc(newColumnSize);
    Bind();
  }

  wcsncpy(mData[pos], val, length);
  *(mData[pos] + length) = 0;  // null terminate the string
	mInd[pos] = SQL_NTS;
}
void COdbcColumnArrayWideStringBinding::Bind(HSTMT hStmt, int pos)
{
  mStmt = hStmt;
  mPosition = pos;
  Bind();
}

void COdbcColumnArrayWideStringBinding::Clear()
{
  if (mData[0] != NULL)
    memset(mData[0], 0x0, mBufSize);
	// Set NULL indicators
	for(int i=0; i<mSize; i++)
	{
		mInd[i] = SQL_NULL_DATA;
}
}

wstring COdbcColumnArrayWideStringBinding::GetAsWString(int row)
{
	wstring str;

	if(row < mSize)
	{
		if(mInd[row] == SQL_NULL_DATA)
			str	= L"<NULL>";
		else
		{
			wchar_t* data = mData[row];
			str = data;
		}
	}
	else
	{	
		ASSERT(0); //out of bounds
	}

	return str;
}

//////////////////////////////////////////////////////////////////////
// BigInteger Binding 
//////////////////////////////////////////////////////////////////////

class COdbcColumnArrayBigIntegerBinding : public COdbcColumnArrayBinding
{
private:
	__int64* mData;
	SQLINTEGER* mInd;
	int mSize;
public:
	void Bind(HSTMT hStmt, int pos);
	void SetBigInteger(int pos, __int64 val);
	void Clear();
	wstring GetAsWString(int row);
	COdbcColumnArrayBigIntegerBinding(int size);
	~COdbcColumnArrayBigIntegerBinding();
};

COdbcColumnArrayBigIntegerBinding::COdbcColumnArrayBigIntegerBinding(int size) : mSize(size)
{
	mData = new __int64 [mSize];
	mInd = new SQLINTEGER [mSize];
	Clear();
}

COdbcColumnArrayBigIntegerBinding::~COdbcColumnArrayBigIntegerBinding()
{
	delete [] mData;
	delete [] mInd;
}

void COdbcColumnArrayBigIntegerBinding::SetBigInteger(int pos, __int64 val)
{
	mData[pos] = val;
	mInd[pos] = 0;
}

void COdbcColumnArrayBigIntegerBinding::Bind(HSTMT hStmt, int pos)
{
	// Oracle/ODBC doens't seem to like integer bindings larger than
	// 32 bits.  So this may not work.  Use the decimal binding
	// instead.
	SQLRETURN sqlReturn;
	sqlReturn = ::SQLBindParameter(hStmt, pos, 
		SQL_PARAM_INPUT, 
		SQL_C_SBIGINT,
		SQL_BIGINT,
		5, /* Column Size - ignored */
		0, /* Decimal Digits */
		mData, 
		0, 
		mInd);
	ProcessStatementError(sqlReturn, hStmt);
}

wstring COdbcColumnArrayBigIntegerBinding::GetAsWString(int row)
{
	wstring str;

	if(row < mSize)
	{
		if(mInd[row] == SQL_NULL_DATA)
			str	= L"<NULL>";
		else
		{
			wchar_t buf[50];
			__int64 data = mData[row];
			swprintf(buf, L"%I64d", data);
			str = buf;
		}
	}
	else
	{	
		ASSERT(0); //out of bounds
	}

	return str;
}


void COdbcColumnArrayBigIntegerBinding::Clear()
{
	memset(mData, 0, mSize*sizeof(__int64));
	// Set NULL indicators
	for(int i=0; i<mSize; i++)
	{
		mInd[i] = SQL_NULL_DATA;
	}
}


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

COdbcPreparedArrayStatement *
COdbcPreparedArrayStatement::CreateStatement(COdbcConnection* pConnection,
																						 int maxArraySize, const string& queryString, bool aBind)
{
	return new COdbcPreparedArrayStatement(pConnection, maxArraySize, queryString, true, aBind);
}

COdbcPreparedArrayStatement *
COdbcPreparedArrayStatement::CreateStatement(COdbcConnection* pConnection,
																						 int maxArraySize, const wstring& queryString, bool aBind)
{
	return new COdbcPreparedArrayStatement(pConnection, maxArraySize, queryString, true, aBind);
}

COdbcPreparedArrayStatement *
COdbcPreparedArrayStatement::CreateStatementFromFile(COdbcConnection* pConnection,
																										 int maxArraySize, const char * apQueryDirectory,
																										 const char * apQueryTag, bool aBind)
{
	return new COdbcPreparedArrayStatement(pConnection, maxArraySize, apQueryDirectory, apQueryTag, aBind);
}


COdbcPreparedArrayStatement::COdbcPreparedArrayStatement(COdbcConnection* aConnection, int aMaxArraySize, const string& aTableName, bool aBind) 
: 
COdbcStatementBase(aConnection),
mMaxArraySize(aMaxArraySize), 
mCurrentArraySize(aMaxArraySize), 
mCurrentArrayPos(0)
{
  std::auto_ptr<COdbcPreparedArrayStatement> stmt(aConnection->PrepareStatement("SELECT * FROM " + aConnection->GetConnectionInfo().GetCatalogPrefix() + aTableName));
  const COdbcColumnMetadataVector& v(stmt->GetMetadata());
  
  // Create the insert statement.
	string paramList;
	string valuesList;
	for(unsigned int i=0; i<v.size(); i++)
	{
		if(i>0)
		{
			paramList += ", ";
			valuesList += ", ";
		}
		paramList += v[i]->GetColumnName();
		valuesList += "?";
		// Either there is no table name (e.g. Oracle) or it should be the name of the table
		// whose insert statement we are generating.
		ASSERT (v[i]->GetTableName() == "" || stricmp(v[i]->GetTableName().c_str(), aTableName.c_str()));
	}

	std::string insertStmt = "insert into " + aConnection->GetConnectionInfo().GetCatalogPrefix() 
    + aTableName + " (" + paramList + ") values (" + valuesList + ")";

	// prepare the statement but don't bind the parameters (we'll do that)
	Prepare(insertStmt, false);

	if (aBind)
		Bind(v);

	// Having set up bindings, num params should be valid
	ASSERT(GetNumParams() == v.size());
}

COdbcPreparedArrayStatement::COdbcPreparedArrayStatement(COdbcConnection* aConnection, int aMaxArraySize, const string& aQueryString, bool dummy, bool aBind) 
: 
COdbcStatementBase(aConnection),
mMaxArraySize(aMaxArraySize), 
mCurrentArraySize(aMaxArraySize), 
mCurrentArrayPos(0)
{
	// prepare the statement and bind the parameters
	Prepare(aQueryString, aBind);
}


//another constructor for a wide string query..
COdbcPreparedArrayStatement::COdbcPreparedArrayStatement(COdbcConnection* aConnection, int aMaxArraySize, const wstring& aQueryString, bool dummy, bool aBind) 
: 
COdbcStatementBase(aConnection),
mMaxArraySize(aMaxArraySize), 
mCurrentArraySize(aMaxArraySize), 
mCurrentArrayPos(0)
{
	// prepare the statement and bind the parameters
	PrepareW(aQueryString, aBind);
}

// constructor for use by subclasses (no query passed in)
COdbcPreparedArrayStatement::COdbcPreparedArrayStatement(COdbcConnection* pConnection,
																												 int maxArraySize)
	: COdbcStatementBase(pConnection),
		mMaxArraySize(maxArraySize), 
		mCurrentArraySize(maxArraySize), 
		mCurrentArrayPos(0),
		mStatusPtr(NULL)
{ }

// load the query from a query file
COdbcPreparedArrayStatement::COdbcPreparedArrayStatement(COdbcConnection* pConnection, int maxArraySize, const char * apQueryDirectory, const char * apQueryTag, bool aBind)
	: COdbcStatementBase(pConnection),
		mMaxArraySize(maxArraySize), 
		mCurrentArraySize(maxArraySize), 
		mCurrentArrayPos(0),
		mStatusPtr(NULL)
{
	// load the query
	Load(apQueryDirectory, apQueryTag);
	// prepare the query and bind to the arguments
	Prepare(mQuery, aBind);
}

COdbcPreparedArrayStatement::~COdbcPreparedArrayStatement()
{
	delete [] mStatusPtr;

	for(unsigned int i=0; i<mBindings.size(); i++)
	{
		delete mBindings.at(i);
		mBindings.at(i) = NULL;
	}	

	for(i=0; i<mMetadata.size(); i++)
	{
		delete mMetadata[i];
		mMetadata[i] = NULL;
	}
}

void COdbcPreparedArrayStatement::PrepareW(const wstring & aQuery, bool aBind)
{
	//store the query for easier debugging
	mWideQuery = aQuery;

	// Status array
	mStatusPtr = new SQLUSMALLINT[mMaxArraySize];
	mParamsProcessed = 0;

	SQLRETURN sqlReturn;
	sqlReturn = ::SQLSetStmtAttr(mStmt, SQL_ATTR_PARAM_BIND_TYPE, (void *)SQL_PARAM_BIND_BY_COLUMN, 0);
	ProcessError(sqlReturn);

	sqlReturn = ::SQLSetStmtAttr(mStmt, SQL_ATTR_PARAMSET_SIZE, (void *)mCurrentArraySize, 0);
	ProcessError(sqlReturn);

	sqlReturn = ::SQLSetStmtAttr(mStmt, SQL_ATTR_PARAM_STATUS_PTR, mStatusPtr, 0);
	ProcessError(sqlReturn);

	sqlReturn = ::SQLSetStmtAttr(mStmt, SQL_ATTR_PARAMS_PROCESSED_PTR, &mParamsProcessed, 0);
	ProcessError(sqlReturn);

	sqlReturn = ::SQLPrepareW(mStmt, (SQLWCHAR *)aQuery.c_str(), SQL_NTS);
	ProcessError(sqlReturn);

	if (aBind)
	{
		SQLSMALLINT numParams;
		sqlReturn = ::SQLNumParams(mStmt, &numParams);
		ProcessError(sqlReturn);
	
		SQLSMALLINT i;
		vector<COdbcParameterMetadata*> parameterMetadata;
		for (i = 1; i<=numParams; i++)
		{
			parameterMetadata.push_back(GetParameterMetadata(i));
		}
		BindParameters(parameterMetadata);

		// free the meta data so we don't leak
		for (i = 0; i < numParams; i++)
		{
			delete parameterMetadata[i];
			parameterMetadata[i] = NULL;
		}

		// Having set up bindings, num params should be valid
		ASSERT(numParams >= 0 && GetNumParams() == (unsigned int)numParams);
	}

#ifdef ODBC_TRACK_PERFORMANCE
	LARGE_INTEGER freq;
	::QueryPerformanceFrequency(&freq);
	mTicksPerSec = freq.QuadPart;
	mTotalTicks = 0;
#endif
}

void COdbcPreparedArrayStatement::Prepare(const string & aQuery, bool aBind)
{
	//store the query for easier debugging
	mQuery = aQuery;

	// Status array
	mStatusPtr = new SQLUSMALLINT[mMaxArraySize];
	mParamsProcessed = 0;

	SQLRETURN sqlReturn;
	sqlReturn = ::SQLSetStmtAttr(mStmt, SQL_ATTR_PARAM_BIND_TYPE, (void *)SQL_PARAM_BIND_BY_COLUMN, 0);
	ProcessError(sqlReturn);

	sqlReturn = ::SQLSetStmtAttr(mStmt, SQL_ATTR_PARAMSET_SIZE, (void *)mCurrentArraySize, 0);
	ProcessError(sqlReturn);

	sqlReturn = ::SQLSetStmtAttr(mStmt, SQL_ATTR_PARAM_STATUS_PTR, mStatusPtr, 0);
	ProcessError(sqlReturn);

	sqlReturn = ::SQLSetStmtAttr(mStmt, SQL_ATTR_PARAMS_PROCESSED_PTR, &mParamsProcessed, 0);
	ProcessError(sqlReturn);

	sqlReturn = ::SQLPrepareA(mStmt, (SQLCHAR *)aQuery.c_str(), SQL_NTS);
	ProcessError(sqlReturn);

	if (aBind)
	{
		SQLSMALLINT numParams;
		sqlReturn = ::SQLNumParams(mStmt, &numParams);
		ProcessError(sqlReturn);
	
		SQLSMALLINT i;
		vector<COdbcParameterMetadata*> parameterMetadata;
		for (i = 1; i<=numParams; i++)
		{
			parameterMetadata.push_back(GetParameterMetadata(i));
		}
		BindParameters(parameterMetadata);

		// free the meta data so we don't leak
		for (i = 0; i < numParams; i++)
		{
			delete parameterMetadata[i];
			parameterMetadata[i] = NULL;
		}

		// Having set up bindings, num params should be valid
		ASSERT(numParams >= 0 && GetNumParams() == (unsigned int)numParams);
	}

#ifdef ODBC_TRACK_PERFORMANCE
	LARGE_INTEGER freq;
	::QueryPerformanceFrequency(&freq);
	mTicksPerSec = freq.QuadPart;
	mTotalTicks = 0;
#endif
}

unsigned int COdbcPreparedArrayStatement::GetNumParams() const 
{
	return mBindings.size();
}

int COdbcPreparedArrayStatement::GetMaxArraySize() const
{
	return mMaxArraySize;
}

void COdbcPreparedArrayStatement::Bind(COdbcColumnMetadataVector cols)
{
	// Allocate a binding for each column and bind to the statement
	mBindings.clear();
	mBindings.reserve(cols.size());
	mBindings.assign(cols.size(), NULL);

	for(unsigned int i=0; i<cols.size(); i++)
	{
		COdbcColumnArrayBinding* binding = COdbcPreparedArrayStatement::Create(cols[i]);
		binding->Bind(mStmt, cols[i]->GetOrdinalPosition());
		mBindings.at(cols[i]->GetOrdinalPosition()-1) = binding;
	}
}

void COdbcPreparedArrayStatement::BindParameters(vector<COdbcParameterMetadata*> aParameterMetadata)
{
	// Allocate a binding for each column and bind to the statement
	mBindings.clear();
	mBindings.reserve(aParameterMetadata.size());
	mBindings.assign(aParameterMetadata.size(), NULL);

	for(unsigned int i=0; i<aParameterMetadata.size(); i++)
	{
		COdbcColumnArrayBinding* binding = COdbcPreparedArrayStatement::Create(aParameterMetadata[i]);
		binding->Bind(mStmt, aParameterMetadata[i]->GetOrdinalPosition());
		mBindings.at(aParameterMetadata[i]->GetOrdinalPosition()-1) = binding;
	}
}

COdbcParameterMetadata* COdbcPreparedArrayStatement::GetParameterMetadata(SQLSMALLINT i)
{
	SQLRETURN sqlReturn;
	SQLSMALLINT sqlDataType;
	SQLUINTEGER sqlParameterSize;
	SQLSMALLINT sqlDecimalDigits;
	SQLSMALLINT sqlIsNullable;
	sqlReturn = ::SQLDescribeParam(mStmt, i, &sqlDataType, &sqlParameterSize, &sqlDecimalDigits, &sqlIsNullable);
	ProcessError(sqlReturn);

	return new COdbcParameterMetadata(sqlDataType, i, sqlIsNullable, sqlParameterSize, sqlDecimalDigits, sqlParameterSize, 0);
}

void COdbcPreparedArrayStatement::SetInteger(int columnPos, int val)
{
	mBindings.at(columnPos-1)->SetInteger(mCurrentArrayPos, val);
}

void COdbcPreparedArrayStatement::SetString(int columnPos, const string& val)
{
	if (IsOracle() && val == "")
		mBindings.at(columnPos-1)->SetString(mCurrentArrayPos, (const char*) MTEmptyString, MTEmptyString.length());
	else
		mBindings.at(columnPos-1)->SetString(mCurrentArrayPos, val);
}

void COdbcPreparedArrayStatement::SetString(int columnPos, const char * val, int length)
{
	if (val && IsOracle() && val[0] == '\0')
		mBindings.at(columnPos-1)->SetString(mCurrentArrayPos, MTEmptyString, MTEmptyString.length());
	else
		mBindings.at(columnPos-1)->SetString(mCurrentArrayPos, val, length);
}

void COdbcPreparedArrayStatement::SetDouble(int columnPos, double val)
{
	mBindings.at(columnPos-1)->SetDouble(mCurrentArrayPos, val);
}

void COdbcPreparedArrayStatement::SetDecimal(int columnPos, const SQL_NUMERIC_STRUCT& val)
{
	mBindings.at(columnPos-1)->SetDecimal(mCurrentArrayPos, val);
}

void COdbcPreparedArrayStatement::SetDecimal(int columnPos, const DECIMAL * val)
{
	mBindings.at(columnPos-1)->SetDecimal(mCurrentArrayPos, val);
}

void COdbcPreparedArrayStatement::SetDatetime(int columnPos, const TIMESTAMP_STRUCT& val)
{
	mBindings.at(columnPos-1)->SetDatetime(mCurrentArrayPos, val);
}

void COdbcPreparedArrayStatement::SetDatetime(int columnPos, const DATE * val)
{
	mBindings.at(columnPos-1)->SetDatetime(mCurrentArrayPos, val);
}

void COdbcPreparedArrayStatement::SetBinary(int columnPos, const unsigned char* val, int length)
{
	mBindings.at(columnPos-1)->SetBinary(mCurrentArrayPos, val, length);
}

void COdbcPreparedArrayStatement::SetWideString(int columnPos, const wstring& val)
{
	if (IsOracle() && val == L"")
		mBindings.at(columnPos-1)->SetWideString(mCurrentArrayPos, (wchar_t*) MTEmptyString, MTEmptyString.length());
	else
		mBindings.at(columnPos-1)->SetWideString(mCurrentArrayPos, val);
}
void COdbcPreparedArrayStatement::SetWideString(int columnPos, const wchar_t * val, int length)
{
	if (val && IsOracle() && wcscmp(val, L"") == 0)
		mBindings.at(columnPos-1)->SetWideString(mCurrentArrayPos, MTEmptyString, MTEmptyString.length());
	else
		mBindings.at(columnPos-1)->SetWideString(mCurrentArrayPos, val, length);
}
void COdbcPreparedArrayStatement::SetBigInteger(int columnPos, __int64 val)
{
	mBindings.at(columnPos-1)->SetBigInteger(mCurrentArrayPos, val);
}

COdbcColumnArrayBinding* COdbcPreparedArrayStatement::Create(const COdbcParameterMetadata* metadata)
{
	switch(metadata->GetDataType())
	{
	case eInteger:
		return new COdbcColumnArrayIntegerBinding(GetMaxArraySize());
		break;
	case eBigInteger:
    // Oracle ODBC doesn't seem to support big integer parameters, so
    // treat as decimal (native rep) and convert.
		return mpConnection->GetConnectionInfo().IsOracle() ?
      static_cast<COdbcColumnArrayBinding*>(new COdbcColumnArrayDecimalBinding(GetMaxArraySize(), metadata)) :
      static_cast<COdbcColumnArrayBinding*>(new COdbcColumnArrayBigIntegerBinding(GetMaxArraySize()));
		break;
	case eString:
		return new COdbcColumnArrayStringBinding(GetMaxArraySize(), metadata);
		break;
	case eDecimal:
		return new COdbcColumnArrayDecimalBinding(GetMaxArraySize(), metadata);
		break;
	case eDatetime:
		return new COdbcColumnArrayDatetimeBinding(GetMaxArraySize(), metadata);
		break;
	case eDouble:
		return new COdbcColumnArrayDoubleBinding(GetMaxArraySize(), metadata);
		break;
	case eBinary:
		return new COdbcColumnArrayBinaryBinding(GetMaxArraySize(), metadata);
		break;
	case eWideString:
		return new COdbcColumnArrayWideStringBinding(GetMaxArraySize(), metadata);
		break;
	default:
		ASSERT(FALSE);
		break;
	}
	return NULL;
}

void COdbcPreparedArrayStatement::ClearBindings()
{
	mCurrentArrayPos = 0;

	for(unsigned int i=0; i<mBindings.size(); i++)
	{
		mBindings.at(i)->Clear();
	}
}

const COdbcColumnMetadataVector& COdbcPreparedArrayStatement::GetMetadata()
{
	if (mMetadata.size() == 0)
	{
		SQLSMALLINT nCols;
		SQLRETURN sqlReturn;
		sqlReturn = ::SQLNumResultCols(mStmt, &nCols);
		ProcessError(sqlReturn);
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

			mMetadata.push_back(new COdbcColumnMetadata(odbcDataType, 
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
				));
		}
	}
  return mMetadata;
}

// Initialize state for new batch
void COdbcPreparedArrayStatement::BeginBatch()
{
	ClearBindings();	
}

void COdbcPreparedArrayStatement::AddBatch()
{
	mCurrentArrayPos++;
}

void COdbcPreparedArrayStatement::InternalExecute()
{
	// If we have parameters, adjust the size of the array handed to ODBC so that it
	// reflects the actual number of parameters set.
	if (GetNumParams() > 0)
	{
		
		// relieves us of the call of AddBatch if the max array size is 1
		if (mMaxArraySize == 1)
			mCurrentArrayPos = 1;
		
		// mCurrentArrayPos should be pointing just beyond the last populated row
		if (mCurrentArrayPos > mMaxArraySize) ASSERT(FALSE);

		// If no parameters are set then exit since there is nothing to execute
		if (mCurrentArrayPos == 0) 
		{
			mParamsProcessed = 0;
      ClearBindings();
			return;
		}

		// Do the adjustment
		if(mCurrentArraySize != mCurrentArrayPos)
		{
			mCurrentArraySize = mCurrentArrayPos;
			SQLRETURN sqlReturn = ::SQLSetStmtAttr(mStmt, SQL_ATTR_PARAMSET_SIZE, (void *)(mCurrentArraySize), 0);
			ProcessError(sqlReturn);

			// rebind again after changed array size
			// (Oracle Driver requires it)
			for(unsigned int col=0; col<mBindings.size(); col++)
			{
				COdbcColumnArrayBinding* binding = mBindings.at(col);
				binding->Bind(mStmt, col+1);
			}
		}
	}
	else
	{
		ASSERT(mCurrentArrayPos == 0);
	}

#ifdef ODBC_TRACK_PERFORMANCE
	LARGE_INTEGER tick;
	LARGE_INTEGER tock;
	::QueryPerformanceCounter(&tick);
#endif

	SQLRETURN sqlReturn = ::SQLExecute(mStmt);

#ifdef ODBC_TRACK_PERFORMANCE
	::QueryPerformanceCounter(&tock);
	mTotalTicks += tock.QuadPart - tick.QuadPart;
#endif

  if (mMaxArraySize == 1)
    ProcessError(sqlReturn);

 	// failed array inserts return warning instead of error, so THROW_ON_WARNING
  else ProcessError(sqlReturn, THROW_ON_WARNING);
  
	ClearBindings();
}

int COdbcPreparedArrayStatement::ExecuteBatch()
{
	InternalExecute();

	int numRows=0;

	numRows += mParamsProcessed;

#ifdef BUILD_SQL_SERVER
	// Loop over the status ptr and catch any problems
	for (SQLUSMALLINT j = 0; j<mParamsProcessed; j++)
	{
		if (mStatusPtr[j] != SQL_PARAM_SUCCESS && mStatusPtr[j] != SQL_PARAM_SUCCESS_WITH_INFO)
		{
			throw COdbcStatementException(mStmt);
		}
	}
#endif
	return numRows;
}

int COdbcPreparedArrayStatement::BatchCount()
{
	return mCurrentArrayPos;
}

int COdbcPreparedArrayStatement::Finalize()
{
	return 0;
}

string COdbcPreparedArrayStatement::GetColumnStringAttribute(SQLSMALLINT col, SQLUSMALLINT attr)
{
	SQLRETURN sqlReturn;
	const int DEFAULT_BUF_LENGTH(256);
	char defaultBuffer[DEFAULT_BUF_LENGTH];
	short bufLength;
	sqlReturn = ::SQLColAttributeA(mStmt, col, attr, &defaultBuffer[0], DEFAULT_BUF_LENGTH, &bufLength, NULL);
	ProcessError(sqlReturn);
	if (bufLength == 0) return string("");

	if (bufLength > DEFAULT_BUF_LENGTH)
	{
		// Looks like there is a very long string, dynamically allocate a buffer and go get it.
		char* buf;
		buf = new char[bufLength+1];
		sqlReturn = ::SQLColAttributeA(mStmt, col, attr, buf, bufLength+1, &bufLength, NULL);
		ProcessError(sqlReturn);
		string val(buf);
		delete [] buf;
		return val;
	}
	else
	{
		return string(defaultBuffer);
	}
}

int COdbcPreparedArrayStatement::GetColumnIntegerAttribute(SQLSMALLINT col, SQLUSMALLINT attr)
{
	SQLRETURN sqlReturn;
	int val;
	sqlReturn = ::SQLColAttributeA(mStmt, col, attr, NULL, 0, NULL, &val);
	ASSERT(sqlReturn == SQL_SUCCESS || sqlReturn == SQL_SUCCESS_WITH_INFO);
	return val;
}

void COdbcPreparedArrayStatement::SetResultSetTypes(COdbcResultSetType * apDataTypes,
																										int aColumns)
{
	for (int i = 1; i <= aColumns; i++)
	{
		mMetadata.push_back(new COdbcColumnMetadata(apDataTypes[i - 1].dataType,
																								i, 
																								(const char *)"",
																								true, // nullable
																								-1, // precision
																								-1, // scale
																								-1,	// default buffer length
																								apDataTypes[i - 1].columnSize, // column size
																								0, //precision Radix
																								(const char *)"",	// typename,
																								(const char *)"",	// column name,
																								(const char * )"",	// tablename
																								false)); // dummy argument
	}
}

COdbcPreparedResultSet* COdbcPreparedArrayStatement::ExecuteQuery()
{
	InternalExecute();

	// make sure metadata is populated
	GetMetadata();

	// Return result set based on database type.
	if (mpConnection->GetConnectionInfo().IsOracle())
		return new COdbcOraclePreparedResultSet(this, mMetadata);
	else
		return new COdbcPreparedResultSet(this, mMetadata);
}

COdbcRowArrayResultSet* COdbcPreparedArrayStatement::ExecuteQueryRowBinding()
{
  GetMetadata();
  COdbcRowArrayResultSet * rs = new COdbcRowArrayResultSet(this, mMetadata);
  InternalExecute();
  return rs;
}

#ifdef ODBC_TRACK_PERFORMANCE
double COdbcPreparedArrayStatement::GetTotalExecuteMillis()
{
	return ((1000.0*mTotalTicks)/mTicksPerSec);
}
#endif


COdbcTableInsertStatement *
COdbcTableInsertStatement::CreateTableInsertStatement(COdbcConnection* pConnection, int maxArraySize, const string& tableName, bool aBind)
{
	return new COdbcTableInsertStatement(pConnection, maxArraySize, tableName, aBind);
}

COdbcTableInsertStatement::COdbcTableInsertStatement(COdbcConnection* pConnection, int maxArraySize, const string& tableName, bool aBind)
	: COdbcPreparedArrayStatement(pConnection, maxArraySize, tableName, aBind)
{
}

void COdbcTableInsertStatement::Bind(COdbcColumnMetadataVector cols)
{
	COdbcPreparedArrayStatement::Bind(cols);
	mHashBindings.clear();
	for(unsigned int i=0; i<cols.size(); i++)
	{
		COdbcColumnArrayBinding* binding = GetBindings()[cols[i]->GetOrdinalPosition()-1];
		mHashBindings[cols[i]->GetColumnName()] = binding;
	}
}

void COdbcTableInsertStatement::SetInteger(const string& columnName, int val)
{
	mHashBindings[columnName]->SetInteger(GetCurrentArrayPos(), val);
}

void COdbcTableInsertStatement::SetString(const string& columnName, const string& val)
{
	if (IsOracle() && val == "")
		mHashBindings[columnName]->SetString(GetCurrentArrayPos(), (const char*) MTEmptyString, MTEmptyString.length());
	else
		mHashBindings[columnName]->SetString(GetCurrentArrayPos(), val);
}

void COdbcTableInsertStatement::SetDouble(const string& columnName, double val)
{
	mHashBindings[columnName]->SetDouble(GetCurrentArrayPos(), val);
}

void COdbcTableInsertStatement::SetDecimal(const string& columnName, const SQL_NUMERIC_STRUCT& val)
{
	mHashBindings[columnName]->SetDecimal(GetCurrentArrayPos(), val);
}

void COdbcTableInsertStatement::SetDatetime(const string& columnName, const TIMESTAMP_STRUCT& val)
{
	mHashBindings[columnName]->SetDatetime(GetCurrentArrayPos(), val);
}

void COdbcTableInsertStatement::SetBinary(const string& columnName, const unsigned char* val, int length)
{
	mHashBindings[columnName]->SetBinary(GetCurrentArrayPos(), val, length);
}

void COdbcTableInsertStatement::SetWideString(const string& columnName, const wstring& val)
{
	if (IsOracle() && val == L"")
		mHashBindings[columnName]->SetWideString(GetCurrentArrayPos(), (const wchar_t*) MTEmptyString, MTEmptyString.length());
	else
		mHashBindings[columnName]->SetWideString(GetCurrentArrayPos(), val);
}
void COdbcTableInsertStatement::SetWideString(const string & columnName, const wchar_t * val, int length)
{
	if (val && IsOracle() && wcscmp(val, L"") == 0)
		mHashBindings[columnName]->SetWideString(GetCurrentArrayPos(), MTEmptyString, MTEmptyString.length());
	else
		mHashBindings[columnName]->SetWideString(GetCurrentArrayPos(), val, length);
}
void COdbcTableInsertStatement::SetBigInteger(const string& columnName, __int64 val)
{
	mHashBindings[columnName]->SetBigInteger(GetCurrentArrayPos(), val);
}


//////////////////////////////////////////////////////////////////////
// query adapter integration
//////////////////////////////////////////////////////////////////////

void COdbcPreparedArrayStatement::Load(const char * apQueryDirectory, const char * apQueryTag)
{
	mPositionMap.clear();
	mQuery.resize(0);
	mQueryTag = apQueryTag;
	// load the query
	IMTQueryCachePtr queryCache(MTPROGID_QUERYCACHE);

	queryCache->Init(apQueryDirectory);

	_bstr_t queryBstr = queryCache->GetQueryString(apQueryDirectory, apQueryTag);
	string query(queryBstr);

	// map names to positional locations
	size_t pos = 0;
	size_t previousEnd = 0;
	size_t len = query.length();
	int paramNumber = 1;
	// for each named parameter found
	while (pos < len && pos != string::npos)
	{
		size_t begin = pos = query.find("%%", pos);
		if (pos == string::npos)
			break;

		// add in the query text before the parameter
		mQuery.append(query, previousEnd, pos - previousEnd);

		pos += 2;
		if (pos > len || (pos = query.find("%%", pos)) == string::npos)
			throw COdbcException("Unterminated substitution variable");

		// from the beginning of the first %% to the end of the last
		string name = query.substr(begin, pos - begin + 2);

		// remember the position
		mPositionMap.insert(make_pair(name, paramNumber));

		// move past the string we just found
		pos += 2;
		previousEnd = pos;

		// replace the parameter with a ?
		mQuery += '?';

		// next parameter
		paramNumber++;
	}

	// add in remaining query text
	mQuery.append(query, previousEnd, len - previousEnd);
}

//////////////////////////////////////////////////////////////////////
// by name parameter access
//////////////////////////////////////////////////////////////////////

// NOTE: these methods are almost all identical.  When changing one, change
// them all equivalently.
void COdbcPreparedArrayStatement::SetInteger(const char * apTag, int val)
{
	// find the list of positions that this tag refers to
	pair<NamePositionMap::const_iterator, NamePositionMap::const_iterator> itpair =
		mPositionMap.equal_range(apTag);

	if (itpair.first == itpair.second) 
	{
		char buffer[1024]; 
		sprintf(buffer, "Parameter %s not found in query %s!", apTag, mQueryTag.c_str());
		throw COdbcException(buffer);
	}
	
	NamePositionMap::const_iterator it;
	for (it = itpair.first; it != itpair.second; ++it)
	{
		// set the parameter value at this position
		int pos = it->second;
		COdbcPreparedArrayStatement::SetInteger(pos, val);
	}
}

void COdbcPreparedArrayStatement::SetString(const char * apTag, const string& val)
{
	// find the list of positions that this tag refers to
	pair<NamePositionMap::const_iterator, NamePositionMap::const_iterator> itpair =
		mPositionMap.equal_range(apTag);

	if (itpair.first == itpair.second) 
	{
		char buffer[1024]; 
		sprintf(buffer, "Parameter %s not found in query %s!", apTag, mQueryTag.c_str());
		throw COdbcException(buffer);
	}

	NamePositionMap::const_iterator it;
	for (it = itpair.first; it != itpair.second; ++it)
	{
		// set the parameter value at this position
		int pos = it->second;
		COdbcPreparedArrayStatement::SetString(pos, val);
	}
}

void COdbcPreparedArrayStatement::SetDouble(const char * apTag, double val)
{
	// find the list of positions that this tag refers to
	pair<NamePositionMap::const_iterator, NamePositionMap::const_iterator> itpair =
		mPositionMap.equal_range(apTag);

	if (itpair.first == itpair.second) 
	{
		char buffer[1024]; 
		sprintf(buffer, "Parameter %s not found in query %s!", apTag, mQueryTag.c_str());
		throw COdbcException(buffer);
	}

	NamePositionMap::const_iterator it;
	for (it = itpair.first; it != itpair.second; ++it)
	{
		// set the parameter value at this position
		int pos = it->second;
		COdbcPreparedArrayStatement::SetDouble(pos, val);
	}
}

void COdbcPreparedArrayStatement::SetDecimal(const char * apTag, const SQL_NUMERIC_STRUCT& val)
{
	// find the list of positions that this tag refers to
	pair<NamePositionMap::const_iterator, NamePositionMap::const_iterator> itpair =
		mPositionMap.equal_range(apTag);

	if (itpair.first == itpair.second) 
	{
		char buffer[1024]; 
		sprintf(buffer, "Parameter %s not found in query %s!", apTag, mQueryTag.c_str());
		throw COdbcException(buffer);
	}

	NamePositionMap::const_iterator it;
	for (it = itpair.first; it != itpair.second; ++it)
	{
		// set the parameter value at this position
		int pos = it->second;
		COdbcPreparedArrayStatement::SetDecimal(pos, val);
	}
}

void COdbcPreparedArrayStatement::SetDatetime(const char * apTag, const TIMESTAMP_STRUCT& val)
{
	// find the list of positions that this tag refers to
	pair<NamePositionMap::const_iterator, NamePositionMap::const_iterator> itpair =
		mPositionMap.equal_range(apTag);

	if (itpair.first == itpair.second) 
	{
		char buffer[1024]; 
		sprintf(buffer, "Parameter %s not found in query %s!", apTag, mQueryTag.c_str());
		throw COdbcException(buffer);
	}

	NamePositionMap::const_iterator it;
	for (it = itpair.first; it != itpair.second; ++it)
	{
		// set the parameter value at this position
		int pos = it->second;
		COdbcPreparedArrayStatement::SetDatetime(pos, val);
	}
}

void COdbcPreparedArrayStatement::SetBinary(const char * apTag, const unsigned char* val, int length)
{
	// find the list of positions that this tag refers to
	pair<NamePositionMap::const_iterator, NamePositionMap::const_iterator> itpair =
		mPositionMap.equal_range(apTag);

	if (itpair.first == itpair.second) 
	{
		char buffer[1024]; 
		sprintf(buffer, "Parameter %s not found in query %s!", apTag, mQueryTag.c_str());
		throw COdbcException(buffer);
	}

	NamePositionMap::const_iterator it;
	for (it = itpair.first; it != itpair.second; ++it)
	{
		// set the parameter value at this position
		int pos = it->second;
		COdbcPreparedArrayStatement::SetBinary(pos, val, length);
	}
}

void COdbcPreparedArrayStatement::SetWideString(const char * apTag, const wstring& val)
{
	// find the list of positions that this tag refers to
	pair<NamePositionMap::const_iterator, NamePositionMap::const_iterator> itpair =
		mPositionMap.equal_range(apTag);

	if (itpair.first == itpair.second) 
	{
		char buffer[1024]; 
		sprintf(buffer, "Parameter %s not found in query %s!", apTag, mQueryTag.c_str());
		throw COdbcException(buffer);
	}

	NamePositionMap::const_iterator it;
	for (it = itpair.first; it != itpair.second; ++it)
	{
		// set the parameter value at this position
		int pos = it->second;
		COdbcPreparedArrayStatement::SetWideString(pos, val);
	}
}

void COdbcPreparedArrayStatement::SetBigInteger(const char * apTag, __int64 val)
{
	// find the list of positions that this tag refers to
	pair<NamePositionMap::const_iterator, NamePositionMap::const_iterator> itpair =
		mPositionMap.equal_range(apTag);

	if (itpair.first == itpair.second) 
	{
		char buffer[1024]; 
		sprintf(buffer, "Parameter %s not found in query %s!", apTag, mQueryTag.c_str());
		throw COdbcException(buffer);
	}
	
	NamePositionMap::const_iterator it;
	for (it = itpair.first; it != itpair.second; ++it)
	{
		// set the parameter value at this position
		int pos = it->second;
		COdbcPreparedArrayStatement::SetBigInteger(pos, val);
	}
}

void COdbcPreparedArrayStatement::ProcessError(SQLRETURN sqlReturn, ErrorThreshold threshold /*= THROW_ON_ERROR*/ )
{
	bool hasError = false;

	if(threshold == THROW_ON_WARNING )
	{	
		//error if sqlReturn is an error or a warning (SQL_SUCCESS_WITH_INFO)
		if(sqlReturn != SQL_SUCCESS)
			hasError = true;
	}
	else //threshold == THROW_ON_ERROR
	{
		//error if sqlReturn is an error
		if(sqlReturn != SQL_SUCCESS && sqlReturn != SQL_SUCCESS_WITH_INFO)
			hasError = true;
	}

	if (hasError)
	{
		COdbcStatementException ex(mStmt);
		LogStatementInfo(true);
		throw ex; //COdbcStatementException(mStmt);
	}
}

// logs statement and bindings
// for error reporting and debugging
void COdbcPreparedArrayStatement::LogStatementInfo(bool logAsError)
{
	//first log base class info (query)
	COdbcStatementBase::LogStatementInfo(logAsError);
	
	//log bindings if debug level
	NTLogger* logger = GetLogger();
	if (logger == NULL)
	{	ASSERT(0);
		return;
	}

	if(logger->IsOkToLog(LOG_DEBUG))
	{
		wchar_t buf[100];

		for(int row = 0; row < mCurrentArrayPos; row++)
		{
			wstring strRow;
			logger->LogThis(LOG_DEBUG, mQuery.c_str());

			for(unsigned int col=0; col<mBindings.size(); col++)
			{
				COdbcColumnArrayBinding* binding = mBindings.at(col);
				wstring value = binding->GetAsWString(row);
				if(strRow.size() > 0)
					strRow += L", ";
				strRow += value;
			}

			swprintf(buf, L"binding %d: ", row);
			strRow = buf + strRow;

			logger->LogThis(LOG_DEBUG, strRow.c_str());
		}
	}
}

