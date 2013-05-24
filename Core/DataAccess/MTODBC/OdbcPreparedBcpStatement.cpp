// OdbcPreparedBcpStatement.cpp: implementation of the COdbcPreparedBcpStatement class.
//
//////////////////////////////////////////////////////////////////////

//#include "bcp.h"
#include <metra.h>
#include <math.h>
#include <MTUtil.h>
#include <base64.h>
#include "OdbcPreparedBcpStatement.h"
#include "OdbcConnection.h"
#include "OdbcStatementGenerator.h"
#include "OdbcStatement.h"
#include "OdbcResultSet.h"
#include "OdbcException.h"
#include "OdbcSessionTypeConversion.h"

/*
#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif
*/


//////////////////////////////////////////////////////////////////////
// Integer Binding 
//////////////////////////////////////////////////////////////////////

class COdbcBcpIntegerBinding : public COdbcBcpBinding
{
private:
	typedef struct tagOdbcBcpIntegerBinding
	{
		DBINDICATOR indicator;
		DBINT value;
	} OdbcBcpIntegerBinding;

	OdbcBcpIntegerBinding mBinding;
public:

	void Bind(HDBC hConnection, int pos)
	{
		RETCODE ret;
		ret = ::bcp_bind(hConnection, 
			(LPCBYTE) &mBinding, 
			sizeof(DBINDICATOR), 
			sizeof(DBINT), 
			NULL, // Non terminated
			0, 
			SQLINT4, 
			pos);
		ASSERT(SUCCEED == ret);
	}

	void SetInteger(int val) 
	{
		mBinding.indicator = 0;
		mBinding.value = val;
	}

	DBINT* GetIntegerRef() 
	{ 
		return &mBinding.value; 
	}

	// Clear all values
	void Clear() 
	{
		mBinding.indicator = SQL_NULL_DATA;
	}

	wstring GetAsWString()
	{
		if (mBinding.indicator == SQL_NULL_DATA)
			return L"<NULL>";

		wchar_t buf[50];
		long* data = GetIntegerRef();
		swprintf(buf, L"%li", *data);
		return buf;
	}


	COdbcBcpIntegerBinding(const COdbcColumnMetadata* metadata)
	{
		ASSERT(metadata->GetDataType() == eInteger);
		Clear();
	}

	~COdbcBcpIntegerBinding() {}
};

//////////////////////////////////////////////////////////////////////
// String Binding 
//////////////////////////////////////////////////////////////////////

class COdbcBcpStringBinding : public COdbcBcpBinding
{
private:
	typedef struct tagOdbcBcpStringBinding
	{
		DBINDICATOR indicator;
		CHAR value [1];
	} OdbcBcpStringBinding;

	OdbcBcpStringBinding* mBinding;

  int mAllocatedColumnSize;
	int mColumnSize;
  int mPosition;
  HDBC mConnection;

  void Bind()
  {
		RETCODE ret;
		ret = ::bcp_bind(mConnection, 
			(LPCBYTE) &mBinding->indicator, 
			sizeof(DBINDICATOR), 
			SQL_VARLEN_DATA, 
			(LPCBYTE) "", // Null terminated
			1, 
			SQLCHARACTER, 
			mPosition);
		ASSERT(SUCCEED == ret);
  }
public:

	void Bind(HDBC hConnection, int pos)
	{
    mConnection = hConnection;
    mPosition = pos;
    Bind();
	}

	void SetString(const string& val) 
	{
		string::size_type sz = val.size();
    SetString(val.c_str(), int(sz));
	}

	void SetString(const char * val, int sz) 
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
      delete []  ((char*) mBinding);
      mAllocatedColumnSize = 2*mAllocatedColumnSize;
      if (mAllocatedColumnSize > mColumnSize)
      {
        mAllocatedColumnSize = mColumnSize;
      }
      else if (sz > mAllocatedColumnSize)
      {
        mAllocatedColumnSize = sz;
      }
      mBinding = (OdbcBcpStringBinding *) new char [sizeof(OdbcBcpStringBinding) + 
                                                    sizeof(DBCHAR)*mAllocatedColumnSize];
      Bind();
    }
		mBinding->indicator = sz;
		strcpy(&mBinding->value[0], val);
	}

	CHAR* GetStringRef() 
	{ 
		return &mBinding->value[0]; 
	}

	// Clear all values
	void Clear() 
	{
		mBinding->indicator = SQL_NULL_DATA;
		mBinding->value[0] = 0;
	}

	wstring GetAsWString()
	{	
		if (mBinding->indicator == SQL_NULL_DATA)
			return L"<NULL>";

		wstring str;
		CHAR* data = GetStringRef();
		ASCIIToWide(str, (const char *)data);
		return str;
	}

	COdbcBcpStringBinding(const COdbcColumnMetadata* metadata)
	{
		ASSERT(metadata->GetDataType() == eString);
		mColumnSize = metadata->GetColumnSize();
    mAllocatedColumnSize = mColumnSize < 16 ? mColumnSize : 16;
		mBinding = (OdbcBcpStringBinding *) new char [sizeof(OdbcBcpStringBinding) + 
                                                  sizeof(DBCHAR)*mAllocatedColumnSize];
		Clear();
	}

	~COdbcBcpStringBinding() 
	{
		delete [] ((char*) mBinding);	
	}
};

//////////////////////////////////////////////////////////////////////
// Decimal Binding 
//////////////////////////////////////////////////////////////////////

class COdbcBcpDecimalBinding : public COdbcBcpBinding
{
private:

	typedef struct tagOdbcBcpDecimalBinding
	{
		DBINDICATOR indicator;
		DBDECIMAL value;
	} OdbcBcpDecimalBinding;

	OdbcBcpDecimalBinding mBinding;

	SQLINTEGER mPrecision;
	SQLINTEGER mScale;
public:

	void Bind(HDBC hConnection, int pos)
	{
		RETCODE ret;
		ret = ::bcp_bind(hConnection, 
			(LPCBYTE) &mBinding.indicator, 
			sizeof(DBINDICATOR), 
			sizeof(DBDECIMAL), 
			NULL, // Non terminated
			0, 
			SQLDECIMAL, 
			pos);
		ASSERT(SUCCEED == ret);
	}

	void SetDecimal(const SQL_NUMERIC_STRUCT& val) 
	{
		mBinding.indicator = sizeof(DBDECIMAL);
		ASSERT(val.precision == mPrecision);
		ASSERT(val.scale == mScale);
		mBinding.value.precision = val.precision;
		mBinding.value.scale = val.scale;
		mBinding.value.sign = val.sign;
		memcpy(mBinding.value.val, val.val, sizeof(val.val));
	}

	void SetDecimal(const DECIMAL * val) 
	{
		mBinding.indicator = sizeof(DBDECIMAL);
    // DBDECIMAL and SQL_NUMERIC_STRUCT are just typedefs
    ::DecimalToOdbcNumeric(val, &mBinding.value);
	}

	DBDECIMAL* GetDecimalRef() 
	{ 
		return &mBinding.value; 
	}

	// Clear all values
	void Clear() 
	{
		mBinding.indicator = SQL_NULL_DATA;
	}

	wstring GetAsWString()
	{	
		if (mBinding.indicator == SQL_NULL_DATA)
			return L"<NULL>";

		DBDECIMAL* dbdecimal = GetDecimalRef();
		
		//convert to SQL_NUMERIC_STRUCT
		SQL_NUMERIC_STRUCT odbcNumeric;
		odbcNumeric.precision = dbdecimal->precision;
		odbcNumeric.scale = dbdecimal->scale;
		odbcNumeric.sign = dbdecimal->sign;
		memcpy(odbcNumeric.val, dbdecimal->val, sizeof(odbcNumeric.val));
		ASSERT(sizeof(odbcNumeric.val) == sizeof(dbdecimal->val));

		//convert to double
		double dVal = OdbcNumericToDouble(&odbcNumeric);
		
		//convert to string
		wchar_t buf[100];
		swprintf(buf, L"%f", dVal);
		return buf;
	}	

	COdbcBcpDecimalBinding(const COdbcColumnMetadata* metadata)
	{
		ASSERT(metadata->GetDataType() == eDecimal);
		mPrecision = metadata->GetPrecision();
		mScale = metadata->GetDecimalDigits();
		Clear();
	}

	~COdbcBcpDecimalBinding() {}
};

//////////////////////////////////////////////////////////////////////
// Datetime Binding 
//////////////////////////////////////////////////////////////////////

class COdbcBcpDatetimeBinding : public COdbcBcpBinding
{
private:
	typedef struct tagOdbcBcpDatetimeBinding
	{
		DBINDICATOR indicator;
		DBDATETIME value;
	} OdbcBcpDatetimeBinding;

	OdbcBcpDatetimeBinding mBinding;
public:

	void Bind(HDBC hConnection, int pos)
	{
		RETCODE ret;
		ret = ::bcp_bind(hConnection, 
			(LPCBYTE) &mBinding.indicator, 
			sizeof(DBINDICATOR), 
			sizeof(DBDATETIME), 
			NULL, // Non terminated
			0, 
			SQLDATETIME, 
			pos);
		ASSERT(SUCCEED == ret);
	}

	void SetDatetime(const TIMESTAMP_STRUCT& val) 
	{
		// dtdays = number of days since Jan 1, 1900
		// dttime = number of (1/300 sec) since midnight
		mBinding.indicator = sizeof(DBDATETIME);
		OdbcTimestampToBCPDatetime(&val, &mBinding.value);
	}

	void SetDatetime(const DATE * val) 
	{
    static const double num300thsInDay(24*60*60*300);

		// dtdays = number of days since Jan 1, 1900
		// dttime = number of (1/300 sec) since midnight
		mBinding.indicator = sizeof(DBDATETIME);
    double tmp = floor(*val);
    mBinding.value.dtdays = (DBINT) (tmp-2.0);
    mBinding.value.dttime = (ULONG) (num300thsInDay*(*val - tmp) + 0.5);
	}

	DBDATETIME* GetDatetimeRef() 
	{ 
		return &mBinding.value; 
	}

	// Clear all values
	void Clear() 
	{
		mBinding.indicator = SQL_NULL_DATA;
		mBinding.value.dtdays = 0;
		mBinding.value.dttime = 0;
	}

	wstring GetAsWString()
	{	
		if (mBinding.indicator == SQL_NULL_DATA)
			return L"<NULL>";

		wchar_t buf[100];
		DBDATETIME* dbtime = GetDatetimeRef();
		
		//TODO implement real conversion
		//not a big deal currently, since only used for debug traces.
		int sec = dbtime->dttime / 300;
		int min = (sec / 60) % 60;
		int hr = sec / (60*60);
		sec = sec % 60;
		swprintf(buf, L"%d-%02d:%02d:%02d", dbtime->dtdays, hr, min, sec);
		return buf;
	}	

	COdbcBcpDatetimeBinding(const COdbcColumnMetadata* metadata)
	{
		ASSERT(metadata->GetDataType() == eDatetime);
		Clear();
	}

	~COdbcBcpDatetimeBinding() {}
};

//////////////////////////////////////////////////////////////////////
// Double Binding 
//////////////////////////////////////////////////////////////////////

class COdbcBcpDoubleBinding : public COdbcBcpBinding
{
private:

	// Note that it is important that the indicator and value be
	// continguous in memory.  It appears that memory is being allocated
	// on 8 byte boundaries and that doubles are also 8 byte boundary 
	// aligned.  So by default, there is 4 bytes of padding between indicator
	// and value.  Here we put four bytes of dummy padding up front to
	// guarantee the correct layout.
#pragma pack(push, 1)
	typedef struct tagOdbcBcpDoubleBinding
	{
		char dummy[4];
		DBINDICATOR indicator;
		DBFLT8 value;
	} OdbcBcpDoubleBinding;

	OdbcBcpDoubleBinding mBinding;
#pragma pack(pop)

public:

	void Bind(HDBC hConnection, int pos)
	{
		RETCODE ret;
		ret = ::bcp_bind(hConnection, 
			(LPCBYTE) &mBinding.indicator, 
			sizeof(DBINDICATOR), 
			sizeof(DBFLT8), 
			NULL, // Non terminated
			0, 
			SQLFLT8, 
			pos);
		ASSERT(SUCCEED == ret);
	}

	void SetDouble(double val) 
	{
		mBinding.indicator = sizeof(DBFLT8);
		mBinding.value = val;
	}

	DBFLT8* GetDoubleRef() 
	{ 
		return &mBinding.value; 
	}

	// Clear all values
	void Clear() 
	{
		mBinding.indicator = SQL_NULL_DATA;
		mBinding.value = 0;
	}

	wstring GetAsWString()
	{
		if (mBinding.indicator == SQL_NULL_DATA)
			return L"<NULL>";

		wchar_t buf[100];
		double* data = GetDoubleRef();
		swprintf(buf, L"%f", *data);
		return buf;
	}


	COdbcBcpDoubleBinding(const COdbcColumnMetadata* metadata)
	{
		ASSERT(metadata->GetDataType() == eDouble);
		Clear();
	}

	~COdbcBcpDoubleBinding() {}
};

//////////////////////////////////////////////////////////////////////
// Binary Binding 
//////////////////////////////////////////////////////////////////////

class COdbcBcpBinaryBinding : public COdbcBcpBinding
{
private:
	typedef struct tagOdbcBcpBinaryBinding
	{
		DBINDICATOR indicator;
		BYTE value[1];
	} OdbcBcpBinaryBinding;

	OdbcBcpBinaryBinding* mBinding;

	int mColumnSize;
public:

	void Bind(HDBC hConnection, int pos)
	{
		RETCODE ret;
		ret = ::bcp_bind(hConnection, 
			(LPCBYTE) &mBinding->indicator, 
			sizeof(DBINDICATOR), 
			SQL_VARLEN_DATA, 
			NULL, // Non terminated
			0, 
			SQLVARBINARY, 
			pos);
		ASSERT(SUCCEED == ret);
	}

	void SetBinary(const unsigned char* val, int length) 
	{
		if(length > mColumnSize)
		{
			char buf[256];
			sprintf(buf, 
							"Binary parameter has maximum length %d and argument has length %d.", 
							mColumnSize, 
							length);
			throw COdbcBindingException(buf);
		}
		mBinding->indicator = length;
		memcpy(&mBinding->value[0], val, length);
	}

	// Clear all values
	void Clear() 
	{
		mBinding->indicator = SQL_NULL_DATA;
		mBinding->value[0] = 0;
	}

	wstring GetAsWString()
	{	
		if (mBinding->indicator == SQL_NULL_DATA)
			return L"<NULL>";

		wstring wstr;
		string str;

		BYTE* data = &mBinding->value[0];
		int length = mBinding->indicator;

		rfc1421encode_nonewlines(data, length, str);
		ASCIIToWide(wstr, str);
		return wstr;
	}

	COdbcBcpBinaryBinding(const COdbcColumnMetadata* metadata)
	{
		ASSERT(metadata->GetDataType() == eBinary);
		mColumnSize = metadata->GetColumnSize();
		mBinding = (OdbcBcpBinaryBinding *) new char [sizeof(OdbcBcpBinaryBinding) + sizeof(BYTE)*mColumnSize];
		Clear();
	}

	~COdbcBcpBinaryBinding() 
	{
		delete [] ((char*) mBinding);
	}
};

//////////////////////////////////////////////////////////////////////
// Wide String Binding 
//////////////////////////////////////////////////////////////////////

class COdbcBcpWideStringBinding : public COdbcBcpBinding
{
private:
	typedef struct tagOdbcBcpWideStringBinding
	{
		DBINDICATOR indicator;
		WCHAR value [1];
	} OdbcBcpWideStringBinding;

	OdbcBcpWideStringBinding* mBinding;

	int mColumnSize;
  int mAllocatedColumnSize;
  HDBC mConnection;
  int mPosition;
  void Bind()
  {
		RETCODE ret;
		ret = ::bcp_bind(mConnection, 
			(LPCBYTE) &mBinding->indicator, 
			sizeof(DBINDICATOR), 
			SQL_VARLEN_DATA, 
			(LPBYTE) L"", // Null terminated
			2, 
			SQLNCHAR, 
			mPosition);
		ASSERT(SUCCEED == ret);
  }
public:

	void Bind(HDBC hConnection, int pos)
	{
    mConnection = hConnection;
    mPosition = pos;
    Bind();
	}

	void SetWideString(const wstring& val) 
	{
		wstring::size_type sz = val.size();
		if(sz > (wstring::size_type)mColumnSize)
		{
			char buf[256];
			sprintf(buf, 
							"Wide string parameter has maximum length %d and argument has length %d.", 
							mColumnSize, 
							sz);
			throw COdbcBindingException(buf);
		}
    else if (sz > (wstring::size_type)mAllocatedColumnSize)
    {
      delete []  ((char*) mBinding);
      mAllocatedColumnSize = 2*mAllocatedColumnSize;
      if (mAllocatedColumnSize > mColumnSize)
      {
        mAllocatedColumnSize = mColumnSize;
      }
      else if (sz > (wstring::size_type)mAllocatedColumnSize)
      {
        mAllocatedColumnSize = sz;
      }
      mBinding = (OdbcBcpWideStringBinding *) new char [sizeof(OdbcBcpWideStringBinding) + 
                                                        sizeof(WCHAR)*mAllocatedColumnSize];
      Bind();
    }
		mBinding->indicator = sizeof(WCHAR)*sz;
		wcscpy(&mBinding->value[0], val.c_str());
	}

	void SetWideString(const wchar_t * val, int length)
	{
		wstring::size_type sz = length;
		if(sz > (wstring::size_type)mColumnSize)
		 sz = mColumnSize;
    if (sz > (wstring::size_type)mAllocatedColumnSize)
    {
      delete []  ((char*) mBinding);
      mAllocatedColumnSize = 2*mAllocatedColumnSize;
      if (mAllocatedColumnSize > mColumnSize)
      {
        mAllocatedColumnSize = mColumnSize;
      }
      else if (sz > (wstring::size_type)mAllocatedColumnSize)
      {
        mAllocatedColumnSize = sz;
      }
      mBinding = (OdbcBcpWideStringBinding *) new char [sizeof(OdbcBcpWideStringBinding) + 
                                                        sizeof(WCHAR)*mAllocatedColumnSize];
      Bind();
    }
		mBinding->indicator = sizeof(WCHAR)*sz;
		wcsncpy(&mBinding->value[0], val, sz+1);
	}

	WCHAR* GetWideStringRef() 
	{ 
		return &mBinding->value[0]; 
	}

	// Clear all values
	void Clear() 
	{
		mBinding->indicator = SQL_NULL_DATA;
		mBinding->value[0] = 0;
	}

	wstring GetAsWString()
	{
		if (mBinding->indicator == SQL_NULL_DATA)
			return L"<NULL>";

		wchar_t* data = GetWideStringRef();
		return data;
	}


	COdbcBcpWideStringBinding(const COdbcColumnMetadata* metadata)
	{
		ASSERT(metadata->GetDataType() == eWideString);
		mColumnSize = metadata->GetColumnSize();
    mAllocatedColumnSize = mColumnSize < 16 ? mColumnSize : 16;
		mBinding = (OdbcBcpWideStringBinding *) new char [sizeof(OdbcBcpWideStringBinding) + 
                                                      sizeof(WCHAR)*mAllocatedColumnSize];
		Clear();
	}

	~COdbcBcpWideStringBinding() 
	{
		delete [] ((char*) mBinding);	
	}
};

//////////////////////////////////////////////////////////////////////
// BigInteger Binding 
//////////////////////////////////////////////////////////////////////

class COdbcBcpBigIntegerBinding : public COdbcBcpBinding
{
private:
	// Note that it is important that the indicator and value be
	// continguous in memory.  It appears that memory is being allocated
	// on 8 byte boundaries and that __int64 are also 8 byte boundary 
	// aligned.  So by default, there is 4 bytes of padding between indicator
	// and value.  Here we put four bytes of dummy padding up front to
	// guarantee the correct layout.
#pragma pack(push, 1)
	typedef struct tagOdbcBcpBigIntegerBinding
	{
		char dummy[4];
		DBINDICATOR indicator;
		__int64 value;
	} OdbcBcpBigIntegerBinding;

	OdbcBcpBigIntegerBinding mBinding;
#pragma pack(pop)
public:

	void Bind(HDBC hConnection, int pos)
	{
		RETCODE ret;
		ret = ::bcp_bind(hConnection, 
			(LPCBYTE) &mBinding.indicator, 
			sizeof(DBINDICATOR), 
			sizeof(__int64), 
			NULL, // Non terminated
			0, 
			SQLINT8, 
			pos);
		ASSERT(SUCCEED == ret);
	}

	void SetBigInteger(__int64 val) 
	{
		mBinding.indicator = sizeof(__int64);
		mBinding.value = val;
	}

	__int64* GetBigIntegerRef() 
	{ 
		return &mBinding.value; 
	}

	// Clear all values
	void Clear() 
	{
		mBinding.indicator = SQL_NULL_DATA;
	}

	wstring GetAsWString()
	{
		if (mBinding.indicator == SQL_NULL_DATA)
			return L"<NULL>";

		wchar_t buf[50];
		__int64* data = GetBigIntegerRef();
		swprintf(buf, L"%I64d", *data);
		return buf;
	}


	COdbcBcpBigIntegerBinding(const COdbcColumnMetadata* metadata)
	{
		ASSERT(metadata->GetDataType() == eBigInteger);
		Clear();
	}

	~COdbcBcpBigIntegerBinding() {}
};


COdbcBcpHints::COdbcBcpHints()
	:
	mMinimallyLogged(false),
	mFireTriggers(false)
{
}

COdbcBcpHints::~COdbcBcpHints()
{
}

bool COdbcBcpHints::GetMinimallyLogged() const
{
	return mMinimallyLogged;
}

void COdbcBcpHints::SetMinimallyLogged(bool aMinimallyLogged)
{
	mMinimallyLogged = aMinimallyLogged;
}

bool COdbcBcpHints::GetFireTriggers() const
{
	return mFireTriggers;
}

void COdbcBcpHints::SetFireTriggers(bool aFireTriggers)
{
	mFireTriggers = aFireTriggers;
}

const vector<string>& COdbcBcpHints::GetOrder() const
{
	return mOrder;
}

void COdbcBcpHints::AddOrder(const string& aColumn)
{
	mOrder.push_back(aColumn);
}

///////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

COdbcPreparedBcpStatement::COdbcPreparedBcpStatement(COdbcConnection* pConnection, const string& aTableName, const COdbcBcpHints& aHints) :
	mBindings(0),
	mBindingCount(0),
	mConnection(pConnection),
	mTableName(aTableName),
	mBatchCount(0)
{
	RETCODE ret;

	// TODO: Check for BCP enabled connection

	// Could use a temp file for error log.
	// The NULL data file is here because we will copy from program variables
	//ret = bcp_init(hConnection, "NetMeter.dbo.t_test_bcp", NULL, "c:\\temp\\bcp.log", DB_IN);
	ret = ::bcp_initA(mConnection->GetHandle(), aTableName.c_str(), NULL, NULL, DB_IN);
	if(SUCCEED != ret)
	{
		GetLogger()->LogVarArgs(LOG_ERROR, "bcp_init failed");
		ProcessError();
	}

	/*** For the moment don't use FIRE_TRIGGERS since it is supposed to prevent minimal logging (though I
			 haven't seen that in practice).
	ret = ::bcp_control(mConnection->GetHandle(), BCPHINTSA, "FIRE_TRIGGERS");
	if(SUCCEED != ret)
	{
		// Make a valiant attempt to get some info...
		throw COdbcConnectionException(mConnection->GetHandle());
	}

	ret = ::bcp_control(mConnection->GetHandle(), BCPHINTSA, "ORDER(id_sess asc)");
	if(SUCCEED != ret)
	{
		// Make a valiant attempt to get some info...
		throw COdbcConnectionException(mConnection->GetHandle());
	}
	*/

	// TODO:  if minimally logged, check to make sure that the database recovery mode is
	// ok (e.g. bulk logged or simple)

	string hints;

	if (aHints.GetMinimallyLogged())
	{
		if (hints.size() > 0) hints += ", ";
		hints += "TABLOCK";
	}

	if (aHints.GetFireTriggers())
	{
		if (hints.size() > 0) hints += ", ";
		hints += "FIRE_TRIGGERS";
	}

	for (unsigned int i=0; i<aHints.GetOrder().size(); i++)
	{
		if (hints.size() > 0) hints += ", ";
		if (i==0) hints += "ORDER(";
		hints += aHints.GetOrder()[i];
		hints += " asc";
		if (i+1 == aHints.GetOrder().size()) hints += ")";
	}

	if (hints.size() > 0)
	{
		// Cast away constness.  Silly bcp_control is not const correct.
		ret = ::bcp_control(mConnection->GetHandle(), BCPHINTSA, (SQLPOINTER) hints.c_str());
		if(SUCCEED != ret)
		{
			GetLogger()->LogVarArgs(LOG_ERROR, "bcp_control failed");
			ProcessError();
		}
	}

/*
	COdbcStatementGenerator gen(pConnection);
	gen.SetTable(aTableName.c_str());
	Bind(gen.GetColumns());
*/

	COdbcStatement* stmt = mConnection->CreateStatement();
	COdbcResultSet* rs = stmt->ExecuteQuery("SET FMTONLY ON SELECT * FROM " + aTableName + " SET FMTONLY OFF");
	Bind(rs->GetMetadata());
	delete rs;
	delete stmt;
}

COdbcPreparedBcpStatement::~COdbcPreparedBcpStatement()
{
	mHashBindings.clear();
	for(unsigned int i=0; i<mBindingCount; i++)
	{
		COdbcBcpBinding* tmp = mBindings[i];
		mBindings[i] = NULL;
		delete tmp;
	}
	delete [] mBindings;
}

void COdbcPreparedBcpStatement::Bind(COdbcColumnMetadataVector cols)
{
	// Allocate a binding for each column and bind to the statement
	if (mBindings != 0)
	{
		mHashBindings.clear();
		for(unsigned int i=0; i<mBindingCount; i++)
		{
			COdbcBcpBinding* tmp = mBindings[i];
			mBindings[i] = NULL;
			delete tmp;
		}

		delete [] mBindings;
	}

	mBindings = new COdbcBcpBinding * [cols.size()];

	for(unsigned int i=0; i<cols.size(); i++)
	{
		COdbcBcpBinding* binding = COdbcPreparedBcpStatement::Create(cols[i]);
		binding->Bind(mConnection->GetHandle(), cols[i]->GetOrdinalPosition());
		mBindings[cols[i]->GetOrdinalPosition()-1] = binding;
		mHashBindings[cols[i]->GetColumnName()] = binding;
	}
	mBindingCount = (unsigned int) cols.size();
}

COdbcBcpBinding* COdbcPreparedBcpStatement::Create(const COdbcColumnMetadata * metadata)
{
	switch(metadata->GetDataType())
	{
	case eInteger:
		return new COdbcBcpIntegerBinding(metadata);
		break;
	case eString:
		return new COdbcBcpStringBinding(metadata);
		break;
	case eDecimal:
		return new COdbcBcpDecimalBinding(metadata);
		break;
	case eDatetime:
		return new COdbcBcpDatetimeBinding(metadata);
		break;
	case eDouble:
		return new COdbcBcpDoubleBinding(metadata);
		break;
	case eBinary:
		return new COdbcBcpBinaryBinding(metadata);
		break;
	case eWideString:
		return new COdbcBcpWideStringBinding(metadata);
		break;
	case eBigInteger:
		return new COdbcBcpBigIntegerBinding(metadata);
		break;
	default:
		ASSERT(FALSE);
		break;
	}
	return NULL;
}

void COdbcPreparedBcpStatement::ClearBindings()
{
	mBatchCount = 0;
	for(unsigned int i=0; i<mBindingCount; i++)
	{
		mBindings[i]->Clear();
	}
}

// Initialize state for new batch
void COdbcPreparedBcpStatement::BeginBatch()
{
	ClearBindings();
}

// Queue up the current set of parameters and stage a new row
void COdbcPreparedBcpStatement::AddBatch()
{
	RETCODE ret = ::bcp_sendrow(mConnection->GetHandle());
	if(SUCCEED != ret)
	{
		GetLogger()->LogVarArgs(LOG_ERROR, "bcp_sendrow failed");
		ProcessError();
	}

	mBatchCount++;

	// Clear all of the current bindings
	for(unsigned int i=0; i<mBindingCount; i++)
	{
		mBindings[i]->Clear();
	}

}


// Execute the current batch and reinitialize
int COdbcPreparedBcpStatement::ExecuteBatch()
{
	// Done with the batch
	int batchNumRows = ::bcp_batch(mConnection->GetHandle());

	if (batchNumRows == -1)
	{
		GetLogger()->LogVarArgs(LOG_ERROR, "bcp_batch failed");
		ProcessError();
	}

	ClearBindings();

	return batchNumRows;
}

// Clean up any remaining batch resources
int COdbcPreparedBcpStatement::Finalize()
{
	int batchNumRows = ::bcp_done(mConnection->GetHandle());
	ASSERT(batchNumRows >= 0);
	return batchNumRows;
}

void COdbcPreparedBcpStatement::SetInteger(const string& columnName, int val)
{
	mHashBindings[columnName]->SetInteger(val);
}

void COdbcPreparedBcpStatement::SetString(const string& columnName, const string& val)
{
	mHashBindings[columnName]->SetString(val);
}

void COdbcPreparedBcpStatement::SetDouble(const string& columnName, double val)
{
	mHashBindings[columnName]->SetDouble(val);
}

void COdbcPreparedBcpStatement::SetDecimal(const string& columnName, const SQL_NUMERIC_STRUCT& val)
{
	mHashBindings[columnName]->SetDecimal(val);
}

void COdbcPreparedBcpStatement::SetDatetime(const string& columnName, const TIMESTAMP_STRUCT& val)
{
	mHashBindings[columnName]->SetDatetime(val);
}

void COdbcPreparedBcpStatement::SetBinary(const string& columnName, const unsigned char* val, int length)
{
	mHashBindings[columnName]->SetBinary(val, length);
}

void COdbcPreparedBcpStatement::SetWideString(const string& columnName, const wstring& val)
{
	mHashBindings[columnName]->SetWideString(val);
}

void COdbcPreparedBcpStatement::SetWideString(const string & columnName, const wchar_t * val, int length)
{
	mHashBindings[columnName]->SetWideString(val, length);
}

void COdbcPreparedBcpStatement::SetBigInteger(const string& columnName, __int64 val)
{
	mHashBindings[columnName]->SetBigInteger(val);
}

NTLogger* COdbcPreparedBcpStatement::GetLogger()
{ 
	if (mConnection)
		return mConnection->GetLogger();
	else
		return NULL;
}

void COdbcPreparedBcpStatement::ProcessError()
{
	//log info about this statement (as error)
	LogStatementInfo(true);
	
	//throw the error	
	throw COdbcConnectionException(mConnection->GetHandle());
}

// logs statement and last binding
// for error reporting and debugging
void COdbcPreparedBcpStatement::LogStatementInfo(bool logAsError)
{
	NTLogger* logger = GetLogger();
	if (logger == NULL)
	{	ASSERT(0);
		return;
	}

	//log table
	if(logAsError)
		logger->LogVarArgs(LOG_ERROR, "Error occurred in PreparedBcpStatement for table %s", mTableName.c_str());
	else
		logger->LogVarArgs(LOG_DEBUG, "PreparedBcpStatement for table %s", mTableName.c_str());

	//log last binding
	wstring strRow;

	for( map<string, COdbcBcpBinding*>::iterator it = mHashBindings.begin();
			 it != mHashBindings.end();
			 ++ it)
	{
		string colName = it->first;
		wstring wcolName;
		ASCIIToWide(wcolName, colName);

		COdbcBcpBinding* binding = it->second;
		wstring value = binding->GetAsWString();
		if(strRow.size() > 0)
			strRow += L", ";
		strRow += wcolName;
		strRow += L"=";
		strRow += value;
	}

	strRow = L"last binding: " + strRow;

	if (logAsError)
		logger->LogThis(LOG_ERROR, strRow.c_str());
	else
		logger->LogThis(LOG_DEBUG, strRow.c_str());
}
