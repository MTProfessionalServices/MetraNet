#ifndef _RUNTIMEVALUE_H_
#define _RUNTIMEVALUE_H_

#include <math.h>
#include <string>
using namespace std;

#include "MTSQLConfig.h"

#include <comutil.h>

#include "MTSQLException.h"

class RuntimeValueProxy
{
private:
	int mRefCount;
	union InternalValue
	{
		string *mStrVal;
		wstring *mWStrVal;
	} mVal;

	enum Type { eStr, eWStr };
	Type mType;

public:
	RuntimeValueProxy(const char * val) : mType(eStr), mRefCount(1)
	{
		mVal.mStrVal = new string(val);
	}

	RuntimeValueProxy(const wchar_t * val) : mType(eWStr), mRefCount(1)
	{
		mVal.mWStrVal = new wstring(val);
	}


	~RuntimeValueProxy()
	{
		if(mType == eStr) delete mVal.mStrVal;
		if(mType == eWStr) delete mVal.mWStrVal;
	}

	void addRef() 
	{ 
		mRefCount++; 
	}
	void release() 
	{ 
		if(--mRefCount <= 0) delete this; 
	}
	int refCount() const
	{
		return mRefCount;
	}

	string* getString() 
	{ 
		return mVal.mStrVal; 
	}
	wstring* getWString() 
	{ 
		return mVal.mWStrVal; 
	}
};

//
// Open issues: do we support enumerated types in the runtime?
//              should we use _variant_t for the runtime type e.g. does it do cow?
//

class RuntimeValue
{
public:
enum BuiltinType {TYPE_INVALID=-1, TYPE_INTEGER, TYPE_DOUBLE, TYPE_STRING, TYPE_BOOLEAN, TYPE_DECIMAL, TYPE_DATETIME, TYPE_TIME, TYPE_ENUM, TYPE_WSTRING, TYPE_NULL, TYPE_BIGINTEGER, TYPE_BINARY};

private:
	static _variant_t NullVariant()
	{
		static _variant_t val;
		static bool init=false;
		if(false == init)
		{
			V_VT(&val) = VT_NULL;
			init = true;
		}
		return val;
	}

	
//private:
public:

  enum { MAX_TINY_STR_LEN = sizeof(DECIMAL)/sizeof(char)-1, MAX_TINY_BIN_LEN = sizeof(DECIMAL)/sizeof(unsigned char), MAX_TINY_WSTR_LEN = sizeof(DECIMAL)/sizeof(wchar_t)-1 };
	union InternalValue
	{
		long mLongVal;
		double mDoubleVal;
		bool mBoolVal;
		DATE mDateVal;
		long mTimeVal;
		long mEnumVal;
    __int64 mLongLongVal;
    DECIMAL mDecVal;
    char mTinyStrVal[MAX_TINY_STR_LEN+1];
    wchar_t mTinyWStrVal[MAX_TINY_WSTR_LEN+1];
    unsigned char mTinyBinaryVal[MAX_TINY_BIN_LEN];
		RuntimeValueProxy *mStrVal;
		RuntimeValueProxy *mWStrVal;
	} mVal;
	const InternalValue& getInternalValue() const
	{
		return mVal;
	}

	enum Type { eNull, eLong, eDouble, eBool, eStr, eDec, eDate, eTime, eEnum, eWStr, eLongLong, eTinyStr, eTinyWStr, eTinyBinary };
	Type mType;
	Type getType() const
	{
		return mType;
	}

	// copy on write 
	void cow()
	{
		if(mType == eStr && mVal.mStrVal->refCount() > 1)
		{
			RuntimeValueProxy* tmp = new RuntimeValueProxy(mVal.mStrVal->getString()->c_str());
			mVal.mStrVal->release();
			mVal.mStrVal = tmp;
		}
		if(mType == eWStr && mVal.mWStrVal->refCount() > 1)
		{
			RuntimeValueProxy* tmp = new RuntimeValueProxy(mVal.mWStrVal->getWString()->c_str());
			mVal.mWStrVal->release();
			mVal.mWStrVal = tmp;
		}
	}

	void copy(const RuntimeValue& val)
	{
    switch(val.getType())
    {
    case eNull:
		{
			mType = eNull;
      return;
		}
    case eStr:
		{
			mType = eStr;
			mVal.mStrVal = val.getInternalValue().mStrVal;
			mVal.mStrVal->addRef();
      return;
		}
		case eWStr:
		{
			mType = eWStr;
			mVal.mWStrVal = val.getInternalValue().mWStrVal;
			mVal.mWStrVal->addRef();
      return;
		}
    case eTinyStr:
		{
			mType = eTinyStr;
			memcpy(&mVal.mTinyStrVal[0], val.getInternalValue().mTinyStrVal, sizeof(InternalValue));
      return;
		}
		case eTinyWStr:
		{
			mType = eTinyWStr;
			memcpy(&mVal.mTinyWStrVal[0], val.getInternalValue().mTinyWStrVal, sizeof(InternalValue));
      return;
		}
		case eDec:
		{
			mType = eDec;
			mVal.mDecVal = val.getInternalValue().mDecVal;
      return;
		}
		case eLong:
		{
			mType = eLong;
			mVal.mLongVal = val.getInternalValue().mLongVal;
      return;
		}
		case eLongLong:
		{
			mType = eLongLong;
			mVal.mLongLongVal = val.getInternalValue().mLongLongVal;
      return;
		}
		case eBool:
		{
			mType = eBool;
			mVal.mBoolVal = val.getInternalValue().mBoolVal;
      return;
		}
		case eDouble:
		{
			mType = eDouble;
			mVal.mDoubleVal = val.getInternalValue().mDoubleVal;
      return;
		}
		case eDate:
		{
			mType = eDate;
			mVal.mDateVal = val.getInternalValue().mDateVal;
      return;
		}
		case eTime:
		{
			mType = eTime;
			mVal.mTimeVal = val.getInternalValue().mTimeVal;
      return;
		}
		case eEnum:
		{
			mType = eEnum;
			mVal.mEnumVal = val.getInternalValue().mEnumVal;
      return;
		}
		case eTinyBinary:
		{
			mType = eTinyBinary;
			memcpy(&mVal.mTinyBinaryVal[0], &val.getInternalValue().mTinyBinaryVal[0], MAX_TINY_BIN_LEN);
      return;
		}
    default:
      throw std::exception("Unknown MTSQL type");
    }
	}

	void release()
	{
		if(mType == eStr) 
		{
			mVal.mStrVal->release();
		}
		else if(mType == eWStr) 
		{
			mVal.mWStrVal->release();
		}
	}

	RuntimeValue(const char * val)
	{
    std::size_t len = strlen(val);
    if (len <= MAX_TINY_STR_LEN)
    {
      mType = eTinyStr;
      memcpy(&mVal.mTinyStrVal[0], val, len+1);
    }
    else
    {
      mType = eStr;
      mVal.mStrVal = new RuntimeValueProxy(val);
    }
	}

	RuntimeValue(const string& val)
  {
    std::size_t len = val.size();
    if (len <= MAX_TINY_STR_LEN)
    {
      mType = eTinyStr;
      memcpy(&mVal.mTinyStrVal[0], val.c_str(), len+1);
    }
    else
    {
			mType = eStr;
			mVal.mStrVal = new RuntimeValueProxy(val.c_str());
    }
  }

	RuntimeValue(const wchar_t * val)
	{
    std::size_t len = wcslen(val);
    if (len <= MAX_TINY_WSTR_LEN)
    {
      mType = eTinyWStr;
      memcpy(&mVal.mTinyWStrVal[0], val, (len+1)*sizeof(wchar_t));
    }
    else
    {
      mType = eWStr;
      mVal.mWStrVal = new RuntimeValueProxy(val);
    }
	}

	RuntimeValue(const wstring& val)
  {
    std::size_t len = val.size();
    if (len <= MAX_TINY_WSTR_LEN)
    {
      mType = eTinyWStr;
      memcpy(&mVal.mTinyWStrVal[0], val.c_str(), (len+1)*sizeof(wchar_t));
    }
    else
    {
			mType = eWStr;
			mVal.mWStrVal = new RuntimeValueProxy(val.c_str());
    }
  }

	RuntimeValue(const DECIMAL& val)
		{
			mType = eDec;
			mVal.mDecVal = val;
		}

	RuntimeValue(const DECIMAL * val)
	{
		mType = eDec;
		mVal.mDecVal = *val;
	}

	RuntimeValue(long val, Type ty)
	{
		mType = ty;
		switch(mType)
		{
		case eLong:
			mVal.mLongVal = val;
			break;
		case eTime:
			mVal.mTimeVal = val;
			break;
		case eEnum:
			mVal.mEnumVal = val;
			break;
		default:
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid type in constructor of RuntimeValue");
		}
	}

	RuntimeValue(double val, bool isDouble)
	{
		if (isDouble)
		{
			mType = eDouble;
			mVal.mDoubleVal = val;
		}
		else
		{
			mType = eDate;
			mVal.mDateVal = val;
		}
	}

	RuntimeValue(bool val)
	{
		mType = eBool;
		mVal.mBoolVal = val;
	}

	RuntimeValue(__int64 val, Type ty)
	{
		mType = ty;
		switch(mType)
		{
		case eLongLong:
			mVal.mLongLongVal = val;
			break;
		default:
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid type in constructor of RuntimeValue");
		}
	}

	RuntimeValue(const unsigned char * begin, const unsigned char * end)
	{
    if (begin + MAX_TINY_BIN_LEN == end)
    {
      mType = eTinyBinary;
      memcpy(mVal.mTinyBinaryVal, begin, end - begin);
    }
    else
    {
      throw std::runtime_error ("Invalid Binary value of length != 16");
    }
	}

public:

	// Unfortuantely this is needed for map<>
	RuntimeValue()
	{
		mType = eNull;
	}

	RuntimeValue(const RuntimeValue& val)
	{
		copy(val);
	}

	// Factory Interfaces for creating RuntimeValues
	static RuntimeValue createNull()
	{
		return RuntimeValue();
	}
	static RuntimeValue createDouble(double val)
	{
		return RuntimeValue(val, true);
	}

	static RuntimeValue createDatetime(DATE val)
	{
		return RuntimeValue(val, false);
	}

	static RuntimeValue createLong(long val)
	{
		return RuntimeValue(val, eLong);
	}

	static RuntimeValue createLongLong(__int64 val)
	{
		return RuntimeValue(val, eLongLong);
	}

	static RuntimeValue createBinary(const unsigned char * begin, const unsigned char * end)
	{
		return RuntimeValue(begin, end);
	}

	static RuntimeValue createTime(long val)
	{
		return RuntimeValue(val, eTime);
	}
	
	static RuntimeValue createEnum(long val)
	{
		return RuntimeValue(val, eEnum);
	}

	static RuntimeValue createString(const string& val)
	{
		return RuntimeValue(val);
	}

	static RuntimeValue createWString(const string& val);

	static RuntimeValue createWString(const wstring& val)
	{
		return RuntimeValue(val);
	}

	static RuntimeValue createDec(const DECIMAL& val)
	{
		return RuntimeValue(val);
	}

	static RuntimeValue createBool(bool val)
	{
	  return RuntimeValue(val);
	}

  void assignNull()
  {
    release();
    mType = eNull;
  }

  void assignLong(long val)
  {
    release();
    mType = eLong;
    mVal.mLongVal = val;
  }

  void assignLongLong(__int64 val)
  {
    release();
    mType = eLongLong;
    mVal.mLongLongVal = val;
  }

  void assignDecimal(const DECIMAL * val)
  {
    release();
    mType = eDec;
		mVal.mDecVal = *val;
  }
  // Bad developer: I haven't been consistent about using
  // Decimal and Dec in my function names...
  void assignDec(const DECIMAL * val)
  {
    assignDecimal(val);
  }

  void assignDouble(double val)
  {
    release();
    mType = eDouble;
		mVal.mDoubleVal = val;
  }

  void assignDatetime(DATE val)
  {
    release();
    mType = eDate;
		mVal.mDateVal = val;
  }

  void assignBool(bool val)
  {
    release();
    mType = eBool;
		mVal.mBoolVal = val;
  }

  void assignTime(long val)
  {
    release();
    mType = eTime;
		mVal.mTimeVal = val;
  }

  void assignEnum(long val)
  {
    release();
    mType = eEnum;
		mVal.mEnumVal = val;
  }

  void assignString(const char * val)
  {
    release();
    std::size_t len = strlen(val);
    if (len <= MAX_TINY_STR_LEN)
    {
      mType = eTinyStr;
      memcpy(&mVal.mTinyStrVal[0], val, (len+1));
    }
    else
    {
			mType = eStr;
			mVal.mStrVal = new RuntimeValueProxy(val);
    }
  }

  void assignString(const std::string& val)
  {
    release();
    std::size_t len = val.size();
    if (len <= MAX_TINY_STR_LEN)
    {
      mType = eTinyStr;
      memcpy(&mVal.mTinyStrVal[0], val.c_str(), len+1);
    }
    else
    {
			mType = eStr;
			mVal.mStrVal = new RuntimeValueProxy(val.c_str());
    }
  }

  void assignWString(const wchar_t * val)
  {
    release();
    std::size_t len = wcslen(val);
    if (len <= MAX_TINY_WSTR_LEN)
    {
      mType = eTinyWStr;
      memcpy(&mVal.mTinyWStrVal[0], val, (len+1)*sizeof(wchar_t));
    }
    else
    {
			mType = eWStr;
			mVal.mWStrVal = new RuntimeValueProxy(val);
    }
  }

  void assignWString(const std::wstring& val)
  {
    release();
    std::size_t len = val.size();
    if (len <= MAX_TINY_WSTR_LEN)
    {
      mType = eTinyWStr;
      memcpy(&mVal.mTinyWStrVal[0], val.c_str(), (len+1)*sizeof(wchar_t));
    }
    else
    {
			mType = eWStr;
			mVal.mWStrVal = new RuntimeValueProxy(val.c_str());
    }
  }

  void assignBinary(const unsigned char * begin, const unsigned char * end)
  {
    if (begin + MAX_TINY_BIN_LEN == end)
    {
      release();
      mType = eTinyBinary;
      memcpy(mVal.mTinyBinaryVal, begin, end - begin);
    }
    else
    {
      throw std::runtime_error("Invalid BINARY value of length != 16");
    }
  }

	RuntimeValue& operator= (const RuntimeValue& val)
	{
		// TODO: protect properly against x = x
		release();
		copy(val);
		return *this;
	}

	RuntimeValue isNull() const
	{
		return mType == eNull; 
	}

	bool isNullRaw() const
	{
		return mType == eNull; 
	}

	void isNull(RuntimeValue * ret) const
	{
    ret->assignBool(mType == eNull);
	}

  static bool CanCompare(const RuntimeValue * lhs, const RuntimeValue * rhs)
  {
    return lhs->getType() == rhs->getType() ||
      (lhs->getType() == eTinyStr && rhs->getType() == eStr) ||
      (lhs->getType() == eStr && rhs->getType() == eTinyStr) ||
      (lhs->getType() == eTinyWStr && rhs->getType() == eWStr) ||
      (lhs->getType() == eWStr && rhs->getType() == eTinyWStr);
  }

  static void Equals(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
  {
		// Implement ANSI null behavior
		if(lhs->mType == eNull || rhs->getType() == eNull) 
    {
      ret->assignNull();
      return;
    }

		if(!CanCompare(lhs, rhs)) 
    {
      ret->assignBool(false);
      return ;
    }

		switch(lhs->mType)
		{
		case eLong:
			ret->assignBool(lhs->getLong() == rhs->getLong());
      return;
		case eLongLong:
			ret->assignBool(lhs->getLongLong() == rhs->getLongLong());
      return;
		case eBool:
			ret->assignBool(lhs->getBool() == rhs->getBool());
      return;
		case eDouble:
			ret->assignBool(lhs->getDouble() == rhs->getDouble());
      return;
		case eTinyStr:
		case eStr:
			ret->assignBool(0 == strcmp(lhs->getStringPtr(), rhs->getStringPtr()));
      return;
		case eTinyWStr:
		case eWStr:
			ret->assignBool(0 == wcscmp(lhs->getWStringPtr(), rhs->getWStringPtr()));
      return;
		case eDec:
			ret->assignBool(VARCMP_EQ == VarDecCmp((LPDECIMAL) &lhs->getDec(), (LPDECIMAL) &rhs->getDec()));
      return;
		case eDate:
    {
      static const double eps(0.000000000000001);
      double a = lhs->getDatetime();
      double b = rhs->getDatetime();
      if (a!=b)
      {
        double relativeError = (fabs(b) > fabs(a)) ? fabs((a - b) / b) : fabs((a - b) / a);
        ret->assignBool(relativeError <= eps);
      }
      else
      {
        ret->assignBool(true);
      }
      return;
    }
		case eTime:
			ret->assignBool(lhs->getTime() == rhs->getTime());
      return;
		case eEnum:
			ret->assignBool(lhs->getEnum() == rhs->getEnum());
      return;
		case eTinyBinary:
			ret->assignBool(memcmp(lhs->getBinaryPtr(), rhs->getBinaryPtr(), MAX_TINY_BIN_LEN) == 0);
      return;
		}
    throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown MTSQL type");
  }

	RuntimeValue operator==(const RuntimeValue& val) const
	{
    RuntimeValue ret;
    Equals(this, &val, &ret);
    return ret;
	}

  static void GreaterThan(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
  {
		// Implement ANSI null behavior
		if(lhs->mType == eNull || rhs->getType() == eNull) 
    {
      ret->assignNull();
      return;
    }

		if(!CanCompare(lhs, rhs)) 
    {
      ret->assignBool(false);
      return ;
    }

		switch(lhs->mType)
		{
		case eLong:
			ret->assignBool(lhs->getLong() > rhs->getLong());
      return;
		case eLongLong:
			ret->assignBool(lhs->getLongLong() > rhs->getLongLong());
      return;
		case eBool:
			ret->assignBool(lhs->getBool() > rhs->getBool());
      return;
		case eDouble:
			ret->assignBool(lhs->getDouble() > rhs->getDouble());
      return;
		case eTinyStr:
		case eStr:
			ret->assignBool(0  < strcmp(lhs->getStringPtr(), rhs->getStringPtr()));
      return;
		case eTinyWStr:
		case eWStr:
			ret->assignBool(0  < wcscmp(lhs->getWStringPtr(), rhs->getWStringPtr()));
      return;
		case eDec:
    {
      int result = VarDecCmp((LPDECIMAL) &lhs->getDec(), (LPDECIMAL) &rhs->getDec());
			ret->assignBool(VARCMP_GT == result);
      return;
    }
		case eDate:
			// TODO: fix dates prior to December 30, 1899
			ret->assignBool(lhs->getDatetime() > rhs->getDatetime());
      return;
		case eTime:
			ret->assignBool(lhs->getTime() > rhs->getTime());
      return;
		case eEnum:
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid operation '>' on Enum type");
		case eTinyBinary:
			ret->assignBool(0 < memcmp(lhs->getBinaryPtr(), rhs->getBinaryPtr(), MAX_TINY_BIN_LEN));
      return;
		}
    throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown MTSQL type");
  }

	RuntimeValue operator>(const RuntimeValue& val) const
	{
    RuntimeValue ret;
    GreaterThan(this, &val, &ret);
    return ret;
	}

  static void LessThan(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
  {
		// Implement ANSI null behavior
		if(lhs->mType == eNull || rhs->getType() == eNull) 
    {
      ret->assignNull();
      return;
    }

		if(!CanCompare(lhs, rhs)) 
    {
      ret->assignBool(false);
      return ;
    }

		switch(lhs->mType)
		{
		case eLong:
			ret->assignBool(lhs->getLong() < rhs->getLong());
      return;
		case eLongLong:
			ret->assignBool(lhs->getLongLong() < rhs->getLongLong());
      return;
		case eBool:
			ret->assignBool(lhs->getBool() < rhs->getBool());
      return;
		case eDouble:
			ret->assignBool(lhs->getDouble() < rhs->getDouble());
      return;
		case eTinyStr:
		case eStr:
			ret->assignBool(0 > strcmp(lhs->getStringPtr(), rhs->getStringPtr()));
      return;
		case eTinyWStr:
		case eWStr:
			ret->assignBool(0 > wcscmp(lhs->getWStringPtr(), rhs->getWStringPtr()));
      return;
		case eDec:
    {
      int result = VarDecCmp((LPDECIMAL) &lhs->getDec(), (LPDECIMAL) &rhs->getDec());
			ret->assignBool(VARCMP_LT == result);
      return;
    }
		case eDate:
			// TODO: fix dates prior to December 30, 1899
			ret->assignBool(lhs->getDatetime() < rhs->getDatetime());
      return;
		case eTime:
			ret->assignBool(lhs->getTime() < rhs->getTime());
      return;
		case eEnum:
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid operation '<' on Enum type");
		case eTinyBinary:
			ret->assignBool(0 > memcmp(lhs->getBinaryPtr(), rhs->getBinaryPtr(), MAX_TINY_BIN_LEN));
      return;
		}
    throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown MTSQL type");
  }

	RuntimeValue operator<(const RuntimeValue& val) const
	{
    RuntimeValue ret;
    LessThan(this, &val, &ret);
    return ret;
	}

  static void GreaterThanEquals(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
  {
		// Implement ANSI null behavior
		if(lhs->mType == eNull || rhs->getType() == eNull) 
    {
      ret->assignNull();
      return;
    }

		if(!CanCompare(lhs, rhs)) 
    {
      ret->assignBool(false);
      return ;
    }

		switch(lhs->mType)
		{
		case eLong:
			ret->assignBool(lhs->getLong() >= rhs->getLong());
      return;
		case eLongLong:
			ret->assignBool(lhs->getLongLong() >= rhs->getLongLong());
      return;
		case eBool:
			ret->assignBool(lhs->getBool() >= rhs->getBool());
      return;
		case eDouble:
			ret->assignBool(lhs->getDouble() >= rhs->getDouble());
      return;
		case eTinyStr:
		case eStr:
			ret->assignBool(0 <= strcmp(lhs->getStringPtr(), rhs->getStringPtr()));
      return;
		case eTinyWStr:
		case eWStr:
			ret->assignBool(0 <= wcscmp(lhs->getWStringPtr(), rhs->getWStringPtr()));
      return;
		case eDec:
    {
      int result = VarDecCmp((LPDECIMAL) &lhs->getDec(), (LPDECIMAL) &rhs->getDec());
			ret->assignBool(VARCMP_GT == result || VARCMP_EQ == result);
      return;
    }
		case eDate:
			// TODO: fix dates prior to December 30, 1899
			ret->assignBool(lhs->getDatetime() >= rhs->getDatetime());
      return;
		case eTime:
			ret->assignBool(lhs->getTime() >= rhs->getTime());
      return;
		case eEnum:
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid operation '>=' on Enum type");
		case eTinyBinary:
			ret->assignBool(0 <= memcmp(lhs->getBinaryPtr(), rhs->getBinaryPtr(), MAX_TINY_BIN_LEN));
      return;
		}
    throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown MTSQL type");
  }

	RuntimeValue operator>=(const RuntimeValue& val) const
	{
    RuntimeValue ret;
    GreaterThanEquals(this, &val, &ret);
    return ret;
	}

  static void LessThanEquals(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
  {
		// Implement ANSI null behavior
		if(lhs->mType == eNull || rhs->getType() == eNull) 
    {
      ret->assignNull();
      return;
    }

		if(!CanCompare(lhs, rhs)) 
    {
      ret->assignBool(false);
      return ;
    }

		switch(lhs->mType)
		{
		case eLong:
			ret->assignBool(lhs->getLong() <= rhs->getLong());
      return;
		case eLongLong:
			ret->assignBool(lhs->getLongLong() <= rhs->getLongLong());
      return;
		case eBool:
			ret->assignBool(lhs->getBool() <= rhs->getBool());
      return;
		case eDouble:
			ret->assignBool(lhs->getDouble() <= rhs->getDouble());
      return;
		case eTinyStr:
		case eStr:
			ret->assignBool(0 >= strcmp(lhs->getStringPtr(), rhs->getStringPtr()));
      return;
		case eTinyWStr:
		case eWStr:
			ret->assignBool(0 >= wcscmp(lhs->getWStringPtr(), rhs->getWStringPtr()));
      return;
		case eDec:
    {
      int result = VarDecCmp((LPDECIMAL) &lhs->getDec(), (LPDECIMAL) &rhs->getDec());
			ret->assignBool(VARCMP_LT == result || VARCMP_EQ == result);
      return;
    }
		case eDate:
			// TODO: fix dates prior to December 30, 1899
			ret->assignBool(lhs->getDatetime() <= rhs->getDatetime());
      return;
		case eTime:
			ret->assignBool(lhs->getTime() <= rhs->getTime());
      return;
		case eEnum:
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid operation '<=' on Enum type");
		case eTinyBinary:
			ret->assignBool(0 >= memcmp(lhs->getBinaryPtr(), rhs->getBinaryPtr(), MAX_TINY_BIN_LEN));
      return;
		}
    throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown MTSQL type");
  }

	RuntimeValue operator<=(const RuntimeValue& val) const
	{
    RuntimeValue ret;
    LessThanEquals(this, &val, &ret);
    return ret;
	}

  static void NotEquals(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
  {
		// Implement ANSI null behavior
		if(lhs->mType == eNull || rhs->getType() == eNull) 
    {
      ret->assignNull();
      return;
    }

		if(!CanCompare(lhs, rhs)) 
    {
      ret->assignBool(false);
      return ;
    }

		switch(lhs->mType)
		{
		case eLong:
			ret->assignBool(lhs->getLong() != rhs->getLong());
      return;
		case eLongLong:
			ret->assignBool(lhs->getLongLong() != rhs->getLongLong());
      return;
		case eBool:
			ret->assignBool(lhs->getBool() != rhs->getBool());
      return;
		case eDouble:
			ret->assignBool(lhs->getDouble() != rhs->getDouble());
      return;
		case eTinyStr:
		case eStr:
			ret->assignBool(0 != strcmp(lhs->getStringPtr(), rhs->getStringPtr()));
      return;
		case eTinyWStr:
		case eWStr:
			ret->assignBool(0 != wcscmp(lhs->getWStringPtr(), rhs->getWStringPtr()));
      return;
		case eDec:
			ret->assignBool(VARCMP_EQ != VarDecCmp((LPDECIMAL) &lhs->getDec(), (LPDECIMAL) &rhs->getDec()));
      return;
		case eDate:
			ret->assignBool(lhs->getDatetime() != rhs->getDatetime());
      return;
		case eTime:
			ret->assignBool(lhs->getTime() != rhs->getTime());
      return;
		case eEnum:
			ret->assignBool(lhs->getEnum() != rhs->getEnum());
      return;
		case eTinyBinary:
			ret->assignBool(0 != memcmp(lhs->getBinaryPtr(), rhs->getBinaryPtr(), MAX_TINY_BIN_LEN));
      return;
		}
    throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown MTSQL type");
  }

	RuntimeValue operator!=(const RuntimeValue& val) const
	{
    RuntimeValue ret;
    NotEquals(this, &val, &ret);
    return ret;
	}

	~RuntimeValue()
	{
		if(mType == eStr) mVal.mStrVal->release();
		if(mType == eWStr) mVal.mWStrVal->release();
	}

	_variant_t getVariant() const
	{
		switch(mType)
		{
		case eLong:
			return _variant_t(getLong());
		case eLongLong:
			return _variant_t(getLongLong());
		case eBool:
			return _variant_t(getBool());
		case eDouble:
			return _variant_t(getDouble());
		case eTinyStr:
		case eStr:
			return _variant_t(_bstr_t(getStringPtr()));
		case eTinyWStr:
		case eWStr:
			return _variant_t(_bstr_t(getWStringPtr()));
		case eDec:
			return _variant_t(getDec());
		case eDate:
			return _variant_t(getDatetime(), VT_DATE);
		case eTime:
			return _variant_t(getTime());
		case eEnum:
			return _variant_t(getEnum());
		case eTinyBinary:
			throw std::runtime_error("Invalid cast of BINARY to variant");
		case eNull:
			return NullVariant();
		}
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type converting RuntimeValue to _variant_t");
	}

	long getLong() const
	{
		return mVal.mLongVal;
	}

	__int64 getLongLong() const
	{
		return mVal.mLongLongVal;
	}

	bool getBool() const
	{
		return mVal.mBoolVal;
	}

	double getDouble() const
	{
		return mVal.mDoubleVal;
	}

	DATE getDatetime() const
	{
		return mVal.mDateVal;
	}

	long getTime() const
	{
		return mVal.mTimeVal;
	}

	long getEnum() const
	{
		return mVal.mEnumVal;
	}

	const DECIMAL& getDec() const 
	{ 
		// The string can't be modified, so don't copy
		return mVal.mDecVal; 
	}

	const long * getLongPtr() const
	{
		return &mVal.mLongVal;
	}
	const __int64 * getLongLongPtr() const
	{
		return &mVal.mLongLongVal;
	}
	const bool * getBoolPtr() const
	{
		return &mVal.mBoolVal;
	}
	const double * getDoublePtr() const
	{
		return &mVal.mDoubleVal;
	}
	const DATE * getDatetimePtr() const
	{
		return &mVal.mDateVal;
	}
	const long * getTimePtr() const
	{
		return &mVal.mTimeVal;
	}
	const long * getEnumPtr() const
	{
		return &mVal.mEnumVal;
	}
	const char * getStringPtr() const 
	{ 
		return mType == eStr ? mVal.mStrVal->getString()->c_str() : mVal.mTinyStrVal; 
	}
	const wchar_t * getWStringPtr() const 
	{ 
		return mType == eWStr ? mVal.mWStrVal->getWString()->c_str() : mVal.mTinyWStrVal; 
	}
	const DECIMAL* getDecPtr() const 
	{ 
		return &mVal.mDecVal; 
	}
	const unsigned char * getBinaryPtr() const 
	{ 
		return &mVal.mTinyBinaryVal[0]; 
	}

	RuntimeValue castToLong() const { RuntimeValue ret; castToLong(&ret); return ret; }
	RuntimeValue castToLongLong() const { RuntimeValue ret; castToLongLong(&ret); return ret; }
	RuntimeValue castToDouble() const { RuntimeValue ret; castToDouble(&ret); return ret; }
	RuntimeValue castToString() const { RuntimeValue ret; castToString(&ret); return ret; }
	RuntimeValue castToWString() const { RuntimeValue ret; castToWString(&ret); return ret; }
	RuntimeValue castToDec() const { RuntimeValue ret; castToDec(&ret); return ret; }
	RuntimeValue castToBool() const { RuntimeValue ret; castToBool(&ret); return ret; }
	RuntimeValue castToDatetime() const { RuntimeValue ret; castToDatetime(&ret); return ret; }
	RuntimeValue castToTime() const { RuntimeValue ret; castToTime(&ret); return ret; }
	RuntimeValue castToBinary() const { RuntimeValue ret; castToBinary(&ret); return ret; }
	MTSQL_DECL void castToLong(RuntimeValue * ret) const ;
	MTSQL_DECL void castToLongLong(RuntimeValue * ret) const ;
	MTSQL_DECL void castToDouble(RuntimeValue * ret) const ;
	MTSQL_DECL void castToString(RuntimeValue * ret) const ;
	MTSQL_DECL void castToWString(RuntimeValue * ret) const ;
	MTSQL_DECL void castToDec(RuntimeValue * ret) const ;
	MTSQL_DECL void castToBool(RuntimeValue * ret) const ;
	MTSQL_DECL void castToDatetime(RuntimeValue * ret) const ;
	MTSQL_DECL void castToTime(RuntimeValue * ret) const ;
	MTSQL_DECL void castToBinary(RuntimeValue * ret) const ;
// 	RuntimeValue castToEnum(IMTNameID * nameID) const ;

	// String Operator
	static RuntimeValue StringPlus(const RuntimeValue& lhs, const RuntimeValue& rhs)
	{
    RuntimeValue ret;
    StringPlus(&lhs, &rhs, &ret);
    return ret;
	}

	// String Operator
	static RuntimeValue WStringPlus(const RuntimeValue& lhs, const RuntimeValue& rhs)
	{
    RuntimeValue ret;
    WStringPlus(&lhs, &rhs, &ret);
    return ret;
	}

	MTSQL_DECL static void StringPlus(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret);
	MTSQL_DECL static void WStringPlus(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret);

	MTSQL_DECL static RuntimeValue StringLike(const RuntimeValue& lhs, const RuntimeValue& rhs);
	MTSQL_DECL static RuntimeValue WStringLike(const RuntimeValue& lhs, const RuntimeValue& rhs);
	static bool WildcardMatch(const char * pattern, const char * str);
	static bool WildcardMatch(const wchar_t * pattern, const wchar_t * str);

	// Arithmetic Operators
	static RuntimeValue DoublePlus(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createDouble(lhs.getDouble()+rhs.getDouble());
	}

	static RuntimeValue DoubleMinus(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createDouble(lhs.getDouble()-rhs.getDouble());
	}

	static RuntimeValue DoubleTimes(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createDouble(lhs.getDouble()*rhs.getDouble());
	}

	static RuntimeValue DoubleDivide(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createDouble(lhs.getDouble()/rhs.getDouble());
	}

	static RuntimeValue DoubleUnaryMinus(RuntimeValue lhs)
	{
		return (lhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createDouble(-lhs.getDouble());
	}

	static void DoublePlus(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eDouble;
    ret->mVal.mDoubleVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getDouble()+rhs->getDouble();
	}

	static void DoubleTimes(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eDouble;
    ret->mVal.mDoubleVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getDouble()*rhs->getDouble();
	}

	static void DoubleMinus(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eDouble;
    ret->mVal.mDoubleVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getDouble()-rhs->getDouble();
	}

	static void DoubleDivide(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eDouble;
    ret->mVal.mDoubleVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getDouble()/rhs->getDouble();
	}

	static void DoubleUnaryMinus(RuntimeValue * lhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw()) ? eNull : eDouble;
    ret->mVal.mDoubleVal = (lhs->isNullRaw()) ? 0 : -lhs->getDouble();
	}

	static RuntimeValue LongPlus(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLong(lhs.getLong()+rhs.getLong());
	}

	static RuntimeValue LongMinus(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLong(lhs.getLong()-rhs.getLong());
	}

	static RuntimeValue LongTimes(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLong(lhs.getLong()*rhs.getLong());
	}

	static RuntimeValue LongDivide(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLong(lhs.getLong()/rhs.getLong());
	}

	static RuntimeValue LongModulus(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLong(lhs.getLong()%rhs.getLong());
	}

	static RuntimeValue LongUnaryMinus(RuntimeValue lhs)
	{
		return (lhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLong(-lhs.getLong());
	}
	
	static void LongPlus(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eLong;
    ret->mVal.mLongVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getLong()+rhs->getLong();
	}

	static void LongTimes(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eLong;
    ret->mVal.mLongVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getLong()*rhs->getLong();
	}

	static void LongMinus(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eLong;
    ret->mVal.mLongVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getLong()-rhs->getLong();
	}

	static void LongDivide(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eLong;
    ret->mVal.mLongVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getLong()/rhs->getLong();
	}

	static void LongModulus(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eLong;
    ret->mVal.mLongVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getLong()%rhs->getLong();
	}

	static void LongUnaryMinus(RuntimeValue * lhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw()) ? eNull : eLong;
    ret->mVal.mLongVal = (lhs->isNullRaw()) ? 0 : -lhs->getLong();
	}

	static RuntimeValue DecimalPlus(RuntimeValue lhs, RuntimeValue rhs)
	{
		if (lhs.isNullRaw() || rhs.isNullRaw()) return RuntimeValue::createNull();
	  DECIMAL ret; 
	  HRESULT hr = VarDecAdd((LPDECIMAL)&lhs.getDec(), (LPDECIMAL)&rhs.getDec(), &ret); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
	  return RuntimeValue::createDec(ret); 
	}

	static RuntimeValue DecimalMinus(RuntimeValue lhs, RuntimeValue rhs)
	{
		if (lhs.isNullRaw() || rhs.isNullRaw()) return RuntimeValue::createNull();
	  DECIMAL ret; 
	  HRESULT hr = VarDecSub((LPDECIMAL)&lhs.getDec(), (LPDECIMAL)&rhs.getDec(), &ret); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
	  return RuntimeValue::createDec(ret); 
	}

	static RuntimeValue DecimalTimes(RuntimeValue lhs, RuntimeValue rhs)
	{
		if (lhs.isNullRaw() || rhs.isNullRaw()) return RuntimeValue::createNull();
	  DECIMAL ret; 
	  HRESULT hr = VarDecMul((LPDECIMAL)&lhs.getDec(), (LPDECIMAL)&rhs.getDec(), &ret); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
	  return RuntimeValue::createDec(ret); 
	}

	static RuntimeValue DecimalDivide(RuntimeValue lhs, RuntimeValue rhs)
	{
		if (lhs.isNullRaw() || rhs.isNullRaw()) return RuntimeValue::createNull();
	  DECIMAL ret; 
	  DECIMAL rnd;
	  HRESULT hr = VarDecDiv((LPDECIMAL)&lhs.getDec(), (LPDECIMAL)&rhs.getDec(), &ret); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
	  // Round the result to the correct number of digits.
	  // TODO: Here we are using 6 digits of precision like MTDecimal.  This is NOT
	  // the same as T-SQL
	  hr = VarDecRound(&ret, 6, &rnd); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
	  return RuntimeValue::createDec(rnd); 
	}

	static RuntimeValue DecimalUnaryMinus(RuntimeValue lhs)
	{
		if (lhs.isNullRaw()) return RuntimeValue::createNull();
	  DECIMAL ret; 
	  HRESULT hr = VarDecNeg((LPDECIMAL)&lhs.getDec(), &ret); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
	  return RuntimeValue::createDec(ret); 
	}
	
	static void DecimalPlus(RuntimeValue *lhs, RuntimeValue * rhs, RuntimeValue * result)
	{
		if (lhs->isNullRaw() || rhs->isNullRaw()) 
    {
      result->assignNull();
      return;
    }
	  DECIMAL ret; 
	  HRESULT hr = VarDecAdd((LPDECIMAL)&lhs->getDec(), (LPDECIMAL)&rhs->getDec(), &ret); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
	  result->assignDecimal(&ret);
	}

	static void DecimalMinus(RuntimeValue *lhs, RuntimeValue * rhs, RuntimeValue * result)
	{
		if (lhs->isNullRaw() || rhs->isNullRaw()) 
    {
      result->assignNull();
      return;
    }
	  DECIMAL ret; 
	  HRESULT hr = VarDecSub((LPDECIMAL)&lhs->getDec(), (LPDECIMAL)&rhs->getDec(), &ret); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
	  result->assignDecimal(&ret);
	}

	static void DecimalTimes(RuntimeValue *lhs, RuntimeValue * rhs, RuntimeValue * result)
	{
		if (lhs->isNullRaw() || rhs->isNullRaw()) 
    {
      result->assignNull();
      return;
    }
	  DECIMAL ret; 
	  HRESULT hr = VarDecMul((LPDECIMAL)&lhs->getDec(), (LPDECIMAL)&rhs->getDec(), &ret); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
    result->assignDecimal(&ret);
	}

	static void DecimalDivide(RuntimeValue *lhs, RuntimeValue * rhs, RuntimeValue * result)
	{
		if (lhs->isNullRaw() || rhs->isNullRaw()) 
    {
      result->assignNull();
      return;
    }
	  DECIMAL ret; 
	  DECIMAL rnd;
	  HRESULT hr = VarDecDiv((LPDECIMAL)&lhs->getDec(), (LPDECIMAL)&rhs->getDec(), &ret); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
	  // Round the result to the correct number of digits.
	  // TODO: Here we are using 6 digits of precision like MTDecimal.  This is NOT
	  // the same as T-SQL
	  hr = VarDecRound(&ret, 6, &rnd); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
	  result->assignDecimal(&ret);
	}

	static void DecimalUnaryMinus(RuntimeValue *lhs, RuntimeValue * result)
	{
		if (lhs->isNullRaw()) 
    {
      result->assignNull();
      return;
    }
	  DECIMAL ret; 
	  HRESULT hr = VarDecNeg((LPDECIMAL)&lhs->getDec(), &ret); 
	  if (!SUCCEEDED(hr)) throw MTSQLComException(hr);
	  result->assignDecimal(&ret);
	}
	
	static RuntimeValue LongLongPlus(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLongLong(lhs.getLongLong()+rhs.getLongLong());
	}

	static RuntimeValue LongLongMinus(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLongLong(lhs.getLongLong()-rhs.getLongLong());
	}

	static RuntimeValue LongLongTimes(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLongLong(lhs.getLongLong()*rhs.getLongLong());
	}

	static RuntimeValue LongLongDivide(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLongLong(lhs.getLongLong()/rhs.getLongLong());
	}

	static RuntimeValue LongLongModulus(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLongLong(lhs.getLongLong()%rhs.getLongLong());
	}

	static RuntimeValue LongLongUnaryMinus(RuntimeValue lhs)
	{
		return (lhs.isNullRaw()) ? 
			RuntimeValue::createNull() : 
			RuntimeValue::createLongLong(-lhs.getLongLong());
	}
	
	static void LongLongPlus(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eLongLong;
    ret->mVal.mLongLongVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getLongLong()+rhs->getLongLong();
	}

	static void LongLongTimes(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eLongLong;
    ret->mVal.mLongLongVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getLongLong()*rhs->getLongLong();
	}

	static void LongLongMinus(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eLongLong;
    ret->mVal.mLongLongVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getLongLong()-rhs->getLongLong();
	}

	static void LongLongDivide(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eLongLong;
    ret->mVal.mLongLongVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getLongLong()/rhs->getLongLong();
	}

	static void LongLongModulus(RuntimeValue * lhs, RuntimeValue * rhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw() || rhs->isNullRaw()) ? eNull : eLongLong;
    ret->mVal.mLongLongVal = (lhs->isNullRaw() || rhs->isNullRaw()) ? 0 : lhs->getLongLong()%rhs->getLongLong();
	}

	static void LongLongUnaryMinus(RuntimeValue * lhs, RuntimeValue * ret)
	{
    ret->mType = (lhs->isNullRaw()) ? eNull : eLongLong;
    ret->mVal.mLongLongVal = (lhs->isNullRaw()) ? 0 : -lhs->getLongLong();
	}

	// Bitwise operators
	static RuntimeValue BitwiseAnd(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() :
			RuntimeValue::createLong(lhs.getLong()&rhs.getLong());
	}

	static RuntimeValue BitwiseOr(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() :
			RuntimeValue::createLong(lhs.getLong()|rhs.getLong());
	}

	static RuntimeValue BitwiseXor(RuntimeValue lhs, RuntimeValue rhs)
	{
		return (lhs.isNullRaw() || rhs.isNullRaw()) ? 
			RuntimeValue::createNull() :
			RuntimeValue::createLong(lhs.getLong()^rhs.getLong());
	}

	static RuntimeValue BitwiseNot(RuntimeValue lhs)
	{
		return (lhs.isNullRaw()) ? 
			RuntimeValue::createNull() :
			RuntimeValue::createLong(~lhs.getLong());
	}

	static void BitwiseAndLong(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
	{
    if(lhs->isNullRaw() || rhs->isNullRaw())
    {
      ret->assignNull();
    }
    else
    {
      ret->assignLong(lhs->getLong() & rhs->getLong());
    }
	}

	static void BitwiseOrLong(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
	{
    if(lhs->isNullRaw() || rhs->isNullRaw())
    {
      ret->assignNull();
    }
    else
    {
      ret->assignLong(lhs->getLong() | rhs->getLong());
    }
	}

	static void BitwiseXorLong(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
	{
    if(lhs->isNullRaw() || rhs->isNullRaw())
    {
      ret->assignNull();
    }
    else
    {
      ret->assignLong(lhs->getLong() ^ rhs->getLong());
    }
	}

	static void BitwiseNotLong(const RuntimeValue * val, RuntimeValue * ret)
	{
    if(val->isNullRaw())
    {
      ret->assignNull();
    }
    else
    {
      ret->assignLong(~(val->getLong()));
    }
	}

	static void BitwiseAndLongLong(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
	{
    if(lhs->isNullRaw() || rhs->isNullRaw())
    {
      ret->assignNull();
    }
    else
    {
      ret->assignLongLong(lhs->getLongLong() & rhs->getLongLong());
    }
	}

	static void BitwiseOrLongLong(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
	{
    if(lhs->isNullRaw() || rhs->isNullRaw())
    {
      ret->assignNull();
    }
    else
    {
      ret->assignLongLong(lhs->getLongLong() | rhs->getLongLong());
    }
	}

	static void BitwiseXorLongLong(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
	{
    if(lhs->isNullRaw() || rhs->isNullRaw())
    {
      ret->assignNull();
    }
    else
    {
      ret->assignLongLong(lhs->getLongLong() ^ rhs->getLongLong());
    }
	}

	static void BitwiseNotLongLong(const RuntimeValue * val, RuntimeValue * ret)
	{
    if(val->isNullRaw())
    {
      ret->assignNull();
    }
    else
    {
      ret->assignLongLong(~val->getLongLong());
    }
	}

};

#endif
