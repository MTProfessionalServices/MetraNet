#define NOMINMAX
#include <metra.h>
#include <time.h>
#include <string.h>
#include "StandardLibrary.h"
#include "MTDec.h"
#include "MTUtil.h"
#include "mttime.h"
#include "base64.h"

#include <boost/random/linear_congruential.hpp>
#include <boost/random/uniform_real.hpp>
#include <boost/random/variate_generator.hpp>
#include <boost/format.hpp>
#include <boost/scoped_array.hpp>
#include <boost/date_time/gregorian/gregorian_types.hpp>
#include <boost/algorithm/string/trim.hpp>

#include <math.h>

class WLenFunction : public PrimitiveFunctionImpl
{
public:

	WLenFunction()
	{
		mRetType = RuntimeValue::TYPE_INTEGER;
		mArgTypes.push_back(RuntimeValue::TYPE_WSTRING);
		mName = "len";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		if (sz != 1)
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }

		result->assignLong((long) wcslen(args[0]->getWStringPtr()));
	}
};

class LenFunction : public PrimitiveFunctionImpl
{
public:

	LenFunction()
	{
		mRetType = RuntimeValue::TYPE_INTEGER;
		mArgTypes.push_back(RuntimeValue::TYPE_STRING);
		mName = "len";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		if (sz != 1)
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }

		result->assignLong((long) strlen(args[0]->getStringPtr()));
	}
};

class WSubstrFunction : public PrimitiveFunctionImpl
{
public:

	WSubstrFunction()
	{
    mRetType = RuntimeValue::TYPE_WSTRING;

		mArgTypes.push_back(RuntimeValue::TYPE_WSTRING);
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);

		mName = "substr";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 3) 
    {
      throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to " + mName + " function");
    }

    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }
		long arg1 = args[1]->getLong();
		long arg2 = args[2]->getLong();

		if(arg2 < 0) throw MTSQLRuntimeErrorException("Invalid parameter passed to " + mName + " function");
		if(arg1 <= 0) 
		{
			long tmp;
			// Adjust the arguments to ignore the negative part the way substring in TSQL does...
			arg2 = (tmp = arg2+arg1-1) < 0 ? 0 : tmp;
			arg1 = 1;
		}
    long len = long(wcslen(args[0]->getWStringPtr()));
    // For backward compatibility handle arg2=npos.
    if (arg2==std::wstring::npos) arg2 = len;
    // Must take care of the case in which arg1+arg2-1 > len
    long toCopy = len+1-arg1 < arg2 ? len+1-arg1 : arg2;
    boost::scoped_array<wchar_t> buf(new wchar_t[toCopy+1]);
    memcpy(buf.get(), args[0]->getWStringPtr() + arg1 - 1, sizeof(wchar_t)*toCopy);
    buf[toCopy] = 0;
		result->assignWString(buf.get());
	}
};

class SubstrFunction : public PrimitiveFunctionImpl
{
public:

	SubstrFunction()
	{
    mRetType = RuntimeValue::TYPE_STRING;

		mArgTypes.push_back(RuntimeValue::TYPE_STRING);
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);

		mName = "substr";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 3) 
    {
      throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to " + mName + " function");
    }

    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }
		long arg1 = args[1]->getLong();
		long arg2 = args[2]->getLong();

		if(arg2 < 0) throw MTSQLRuntimeErrorException("Invalid parameter passed to " + mName + " function");
		if(arg1 <= 0) 
		{
			long tmp;
			// Adjust the arguments to ignore the negative part the way substring in TSQL does...
			arg2 = (tmp = arg2+arg1-1) < 0 ? 0 : tmp;
			arg1 = 1;
		}
    long len = long(strlen(args[0]->getStringPtr()));
    // For backward compatibility handle arg2=npos.
    if (arg2==std::string::npos) arg2 = len;
    // Must take care of the case in which arg1+arg2-1 > len
    long toCopy = len+1-arg1 < arg2 ? len+1-arg1 : arg2;
    boost::scoped_array<char> buf(new char[toCopy+1]);
    memcpy(buf.get(), args[0]->getStringPtr() + arg1 - 1, toCopy);
    buf[toCopy] = 0;
		result->assignString(buf.get());
	}
};

class WUpperFunction : public PrimitiveFunctionImpl
{
public:

	WUpperFunction()
	{
    mRetType = RuntimeValue::TYPE_WSTRING;

		mArgTypes.push_back(RuntimeValue::TYPE_WSTRING);

		mName = "upper";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }
    boost::scoped_array<wchar_t> buf(new wchar_t [wcslen(args[0]->getWStringPtr())+1]);
    wcscpy(buf.get(), args[0]->getWStringPtr());
    _wcsupr(buf.get());
		result->assignWString(buf.get());
	}
};

class UpperFunction : public PrimitiveFunctionImpl
{
public:

	UpperFunction()
	{
    mRetType = RuntimeValue::TYPE_STRING;

		mArgTypes.push_back(RuntimeValue::TYPE_STRING);

		mName = "upper";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }
    boost::scoped_array<char> buf(new char [strlen(args[0]->getStringPtr())+1]);
    strcpy(buf.get(), args[0]->getStringPtr());
    _strupr(buf.get());
    result->assignString(buf.get());
	}
};

class WLowerFunction : public PrimitiveFunctionImpl
{
public:

	WLowerFunction()
	{
    mRetType = RuntimeValue::TYPE_WSTRING;

		mArgTypes.push_back(RuntimeValue::TYPE_WSTRING);

		mName = "lower";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }
    boost::scoped_array<wchar_t> buf(new wchar_t [wcslen(args[0]->getWStringPtr())+1]);
    wcscpy(buf.get(), args[0]->getWStringPtr());
    _wcslwr(buf.get());
		result->assignWString(buf.get());
	}
};

class LowerFunction : public PrimitiveFunctionImpl
{
public:

	LowerFunction()
	{
    mRetType = RuntimeValue::TYPE_STRING;

		mArgTypes.push_back(RuntimeValue::TYPE_STRING);

		mName = "lower";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }
    boost::scoped_array<char> buf(new char [strlen(args[0]->getStringPtr())+1]);
    strcpy(buf.get(), args[0]->getStringPtr());
    _strlwr(buf.get());
		result->assignString(buf.get());
	}
};

// This function implements Symmetric Arithmetic Rounding
// which is what SQL Server and Excel do.
class RoundFunction : public PrimitiveFunctionImpl
{
public:

	RoundFunction()
	{
    mRetType = RuntimeValue::TYPE_DECIMAL;

		mArgTypes.push_back(RuntimeValue::TYPE_DECIMAL);
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);

		mName = "round";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 2) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }

    try
    {
      MTDecimal dec(args[0]->getDec());
      result->assignDec(&(DECIMAL) dec.SymmetricArithmeticRound(args[1]->getLong()));
    } 
    catch(_com_error & e)
    {
      throw MTSQLComException(e.Error());
    }
	}
};

// This function implements Asymmetric Arithmetic Rounding
// which is what Java does.
class ARoundFunction : public PrimitiveFunctionImpl
{
public:

	ARoundFunction()
	{
    mRetType = RuntimeValue::TYPE_DECIMAL;

		mArgTypes.push_back(RuntimeValue::TYPE_DECIMAL);
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);

		mName = "around";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 2) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }

    try
    {
			if (args[0]->isNullRaw())
      {
				result->assignNull();
        return;
      }

      MTDecimal dec(args[0]->getDec());
      result->assignDec(&(DECIMAL) dec.AsymmetricArithmeticRound(args[1]->getLong()));
    } 
    catch(_com_error & e)
    {
      throw MTSQLComException(e.Error());
    }
	}
};

// This function implements so-called Banker's rounding (this is what
// comes out of the box with VarDecRnd and hence with MTDecimal).
class BRoundFunction : public PrimitiveFunctionImpl
{
public:

	BRoundFunction()
	{
    mRetType = RuntimeValue::TYPE_DECIMAL;

		mArgTypes.push_back(RuntimeValue::TYPE_DECIMAL);
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);

		mName = "bround";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 2) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }

    try
    {
			if (args[0]->isNullRaw())
      {
				result->assignNull();
        return;
      }

      MTDecimal dec(args[0]->getDec());
      result->assignDec(&(DECIMAL) dec.BankersRound(args[1]->getLong()));
    }
    catch(_com_error & e)
    {
      throw MTSQLComException(e.Error());
    }
	}
};

class FloorFunction : public PrimitiveFunctionImpl
{
public:

	FloorFunction()
	{
    mRetType = RuntimeValue::TYPE_DECIMAL;

		mArgTypes.push_back(RuntimeValue::TYPE_DECIMAL);
		mName = "floor";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function (floor)");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }


		if (args[0]->isNullRaw())
    {
			result->assignNull();
      return;
    }

		double flooredval = floor(args[0]->castToDouble().getDouble());
		MTDecimal dec( (long)flooredval );
		result->assignDec(&(DECIMAL) dec);
	}
};

class SquareFunction : public PrimitiveFunctionImpl
{
public:

	SquareFunction()
	{
		mRetType = RuntimeValue::TYPE_DECIMAL;

		mArgTypes.push_back(RuntimeValue::TYPE_DECIMAL);
		mName = "sqr";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function (sqr)");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }

		
		try
		{
			if (args[0]->isNullRaw())
      {
				result->assignNull();
        return;
      }

			double squareval = (args[0]->castToDouble().getDouble()) * (args[0]->castToDouble().getDouble());
			_variant_t val = squareval;
			MTDecimal dec(val);
			result->assignDec(&(DECIMAL) dec);
		}
		catch(_com_error & err)
		{
			throw MTSQLComException(err.Error());
		}
		catch (exception &e)
		{
			e;
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown STL exception.");
		}
		catch ( ... )
		{
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Overflow or invalid argument.");
		}	
	}
};

class SquareRootFunction : public PrimitiveFunctionImpl
{
public:

	SquareRootFunction()
	{
		mRetType = RuntimeValue::TYPE_DECIMAL;

		mArgTypes.push_back(RuntimeValue::TYPE_DECIMAL);
		mName = "sqrt";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function (sqrt)");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }

		
		try 
		{
			if (args[0]->isNullRaw())
      {
				result->assignNull();
        return;
      }

			double squarerootval = (args[0]->castToDouble().getDouble());

			if ( squarerootval < 0 )
				throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid argument(Argument cannot be negative).");

			squarerootval = sqrt(squarerootval);

			MTDecimal dec( _variant_t(squarerootval, VT_R8) );
		    result->assignDec(&(DECIMAL) dec);
		} 
		catch(_com_error & err)
		{
			throw MTSQLComException(err.Error());
		}
		catch (exception &e)
		{
			e;
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid argument(Argument cannot be negative) or Overflow error.");
		}
		catch ( ... )
		{
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown Error.");
		}	
	}
};

class CeilingFunction : public PrimitiveFunctionImpl
{
public:

	CeilingFunction()
	{
    mRetType = RuntimeValue::TYPE_DECIMAL;

		mArgTypes.push_back(RuntimeValue::TYPE_DECIMAL);
		mName = "ceiling";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function (ceiling)");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }

		double ceiledval = ceil(args[0]->castToDouble().getDouble());
		MTDecimal dec( (long)ceiledval );
		result->assignDec(&(DECIMAL) dec);
	}
};



class GetdateFunction : public PrimitiveFunctionImpl
{
public:

	GetdateFunction()
	{
    mRetType = RuntimeValue::TYPE_DATETIME;

		mName = "getdate";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 0) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

		DATE dateVal;
		time_t timeT=GetMTTime();
		struct tm * timeTm = ::localtime(&timeT);
		ASSERT(timeTm);
		::OleDateFromStructTm(&dateVal, timeTm);
		result->assignDatetime(dateVal);
	}
};

class GetutcdateFunction : public PrimitiveFunctionImpl
{
public:

	GetutcdateFunction()
	{
    mRetType = RuntimeValue::TYPE_DATETIME;

		mName = "getutcdate";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 0) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

		DATE dateVal;
		time_t timeT=time(0);
// 		time_t timeT=GetMTTime();
		struct tm * timeTm = ::gmtime(&timeT);
		ASSERT(timeTm);
		::OleDateFromStructTm(&dateVal, timeTm);
		result->assignDatetime(dateVal);
	}
};

class IntervaldaysFunction : public PrimitiveFunctionImpl
{
public:

	IntervaldaysFunction()
	{
    mRetType = RuntimeValue::TYPE_INTEGER;
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mName = "intervaldays";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 2) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }
    DATE left = args[0]->getDatetime();
    DATE right = args[1]->getDatetime();
    // This calculation assumes that we have closed datetime intervals
    // and that we "round up" to the next day.
    // E.g. intervaldays(1/1/2000, 1/1/2000) = 1
    // E.g. intervaldays(1/1/2000, 1/1/2000 11:59:59 PM) = 1
    // E.g. intervaldays(1/1/2000, 1/2/2000) = 2
		result->assignLong((long)(floor(right + 1.0) - floor(left)));
	}
};

class DateArithmetic
{
public:
  static const double daysPerWeek;
  static const double hoursPerDay;
  static const double minutesPerDay;
  static const double secondsPerDay;
  static const double millisecondsPerDay;
  
  static void AddSeconds(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignDatetime(dt->getDatetime() + incr->castToDouble().getDouble()/secondsPerDay);
  }
  static void AddMilliseconds(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignDatetime(dt->getDatetime() + incr->castToDouble().getDouble()/millisecondsPerDay);
  }
  static void AddDays(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignDatetime(dt->getDatetime() + incr->castToDouble().getDouble());
  }
  static void AddMinutes(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignDatetime(dt->getDatetime() + incr->castToDouble().getDouble()/minutesPerDay);
  }
  static void AddHours(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignDatetime(dt->getDatetime() + incr->castToDouble().getDouble()/hoursPerDay);
  }
  static void AddWeeks(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignDatetime(dt->getDatetime() + incr->castToDouble().getDouble()*daysPerWeek);
  }
  static void AddMonths(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    // Convert to Boost and then use the datetime library.
    SYSTEMTIME t;
    ::VariantTimeToSystemTime(dt->getDatetime(), &t);
    boost::gregorian::date boost_dt(t.wYear, t.wMonth, t.wDay);
    boost::gregorian::months m(incr->castToLong().getLong());
    boost_dt += m;
    t.wYear = boost_dt.year();
    t.wMonth = boost_dt.month();
    t.wDay = boost_dt.day();
    DATE tmp;
    ::SystemTimeToVariantTime(&t, &tmp);
    result->assignDatetime(tmp);
  }
  static void AddYears(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    // Convert to Boost and then use the datetime library.
    SYSTEMTIME t;
    ::VariantTimeToSystemTime(dt->getDatetime(), &t);
    boost::gregorian::date boost_dt(t.wYear, t.wMonth, t.wDay);
    boost::gregorian::years y(incr->castToLong().getLong());
    boost_dt += y;
    t.wYear = boost_dt.year();
    t.wMonth = boost_dt.month();
    t.wDay = boost_dt.day();
    DATE tmp;
    ::SystemTimeToVariantTime(&t, &tmp);
    result->assignDatetime(tmp);
  }
  static void SubtractSeconds(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignLong((long) ((dt->getDatetime() - incr->getDatetime())*secondsPerDay + 0.5));
  }
  static void SubtractMilliseconds(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignLong((long) ((dt->getDatetime() - incr->getDatetime())*millisecondsPerDay + 0.5));
  }
  static void SubtractDays(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignLong(long(dt->getDatetime()) - long(incr->getDatetime()));
  }
  static void SubtractMinutes(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignLong((long) ((dt->getDatetime() - incr->getDatetime())*minutesPerDay + 0.5));
  }
  static void SubtractHours(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignLong((long) ((dt->getDatetime() - incr->getDatetime())*hoursPerDay + 0.5));
  }
  static void SubtractWeeks(const RuntimeValue * dt, const RuntimeValue * incr, RuntimeValue * result)
  {
    result->assignLong((long) ((dt->getDatetime() - incr->getDatetime())/daysPerWeek + 0.5));
  }
};

const double DateArithmetic::daysPerWeek(7);
const double DateArithmetic::hoursPerDay(24);
const double DateArithmetic::minutesPerDay(60*DateArithmetic::hoursPerDay);
const double DateArithmetic::secondsPerDay(60*DateArithmetic::minutesPerDay);
const double DateArithmetic::millisecondsPerDay(DateArithmetic::secondsPerDay*1000);

class WDateaddFunctionBase : public PrimitiveFunctionImpl
{
protected:
  WDateaddFunctionBase()
  {
  }

public:

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		if(sz != 3) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }
		if(0 == wcscmp(args[0]->getWStringPtr(), L"s") ||  0 == wcscmp(args[0]->getWStringPtr(), L"ss"))
		{
      DateArithmetic::AddSeconds(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"ms"))
		{
      DateArithmetic::AddMilliseconds(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"d") || 0 == wcscmp(args[0]->getWStringPtr(), L"dd"))
		{
      DateArithmetic::AddDays(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"mi") || 0 == wcscmp(args[0]->getWStringPtr(), L"n"))
		{
      DateArithmetic::AddMinutes(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"hh"))
		{
      DateArithmetic::AddHours(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"wk") || 0 == wcscmp(args[0]->getWStringPtr(), L"ww"))
		{
      DateArithmetic::AddWeeks(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"mm") || 0 == wcscmp(args[0]->getWStringPtr(), L"m"))
		{
      DateArithmetic::AddMonths(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"yy") || 0 == wcscmp(args[0]->getWStringPtr(), L"yyyy"))
		{
      DateArithmetic::AddYears(args[2], args[1], result);
		}
		else
		{
			throw MTSQLRuntimeErrorException((boost::format("Invalid argument '%1%' to function dateadd") % args[0]->getStringPtr()).str());
		}
	}
};

class WDateaddFunction : public WDateaddFunctionBase
{
public:
	WDateaddFunction()
	{
    mRetType = RuntimeValue::TYPE_DATETIME;
		mArgTypes.push_back(RuntimeValue::TYPE_WSTRING);
		mArgTypes.push_back(RuntimeValue::TYPE_DECIMAL);
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mName = "dateadd";
	}
};

class WDateaddIntegerFunction : public WDateaddFunctionBase
{
public:
	WDateaddIntegerFunction()
	{
    mRetType = RuntimeValue::TYPE_DATETIME;
		mArgTypes.push_back(RuntimeValue::TYPE_WSTRING);
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mName = "dateadd";
	}
};

class DateaddFunctionBase : public PrimitiveFunctionImpl
{
protected:
	DateaddFunctionBase()
	{
	}

public:

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		if(sz != 3) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }
		if(0 == strcmp(args[0]->getStringPtr(), "s") || 0 == strcmp(args[0]->getStringPtr(), "ss"))
		{
      DateArithmetic::AddSeconds(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "ms"))
		{
      DateArithmetic::AddMilliseconds(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "d") || 0 == strcmp(args[0]->getStringPtr(), "dd"))
		{
      DateArithmetic::AddDays(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "mi") || 0 == strcmp(args[0]->getStringPtr(), "n"))
		{
      DateArithmetic::AddMinutes(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "hh"))
		{
      DateArithmetic::AddHours(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "wk") || 0 == strcmp(args[0]->getStringPtr(), "ww"))
		{
      DateArithmetic::AddWeeks(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "mm") || 0 == strcmp(args[0]->getStringPtr(), "m"))
		{
      DateArithmetic::AddMonths(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "yy") || 0 == strcmp(args[0]->getStringPtr(), "yyyy"))
		{
      DateArithmetic::AddYears(args[2], args[1], result);
		}
		else
		{
			throw MTSQLRuntimeErrorException((boost::format("Invalid argument '%1%' to function dateadd") % args[0]->getStringPtr()).str());
		}
	}
};

class DateaddFunction : public DateaddFunctionBase
{
public:

	DateaddFunction()
	{
    mRetType = RuntimeValue::TYPE_DATETIME;
		mArgTypes.push_back(RuntimeValue::TYPE_STRING);
		mArgTypes.push_back(RuntimeValue::TYPE_DECIMAL);
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mName = "dateadd";
	}
};

class DateaddIntegerFunction : public DateaddFunctionBase
{
public:

	DateaddIntegerFunction()
	{
    mRetType = RuntimeValue::TYPE_DATETIME;
		mArgTypes.push_back(RuntimeValue::TYPE_STRING);
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mName = "dateadd";
	}
};

class WDatediffFunction : public PrimitiveFunctionImpl
{
public:

	WDatediffFunction()
	{
    mRetType = RuntimeValue::TYPE_INTEGER;
		mArgTypes.push_back(RuntimeValue::TYPE_WSTRING);
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mName = "datediff";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		if(sz != 3) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }
		if(0 == wcscmp(args[0]->getWStringPtr(), L"s") || 0 == wcscmp(args[0]->getWStringPtr(), L"ss"))
		{
      DateArithmetic::SubtractSeconds(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"ms"))
		{
      DateArithmetic::SubtractMilliseconds(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"d") || 0 == wcscmp(args[0]->getWStringPtr(), L"dd"))
		{
      DateArithmetic::SubtractDays(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"mi") || 0 == wcscmp(args[0]->getWStringPtr(), L"n"))
		{
      DateArithmetic::SubtractMinutes(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"hh"))
		{
      DateArithmetic::SubtractHours(args[2], args[1], result);
		}
		else if(0 == wcscmp(args[0]->getWStringPtr(), L"wk") || 0 == wcscmp(args[0]->getWStringPtr(), L"ww"))
		{
      DateArithmetic::SubtractWeeks(args[2], args[1], result);
		}
		else
		{
			throw MTSQLRuntimeErrorException(
        (boost::format("Invalid argument '%1%' to function datediff") % args[0]->castToString().getStringPtr()).str());
		}
	}
};

class DatediffFunction : public PrimitiveFunctionImpl
{
public:

	DatediffFunction()
	{
    mRetType = RuntimeValue::TYPE_INTEGER;
		mArgTypes.push_back(RuntimeValue::TYPE_STRING);
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mName = "datediff";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result)
	{
		if(sz != 3) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }
		if(0 == strcmp(args[0]->getStringPtr(), "s") || 0 == strcmp(args[0]->getStringPtr(), "ss"))
		{
      DateArithmetic::SubtractSeconds(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "ms"))
		{
      DateArithmetic::SubtractMilliseconds(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "d") || 0 == strcmp(args[0]->getStringPtr(), "dd"))
		{
      DateArithmetic::SubtractDays(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "mi") || 0 == strcmp(args[0]->getStringPtr(), "n"))
		{
      DateArithmetic::SubtractMinutes(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "hh"))
		{
      DateArithmetic::SubtractHours(args[2], args[1], result);
		}
		else if(0 == strcmp(args[0]->getStringPtr(), "wk") || 0 == strcmp(args[0]->getStringPtr(), "ww"))
		{
      DateArithmetic::SubtractWeeks(args[2], args[1], result);
		}
		else
		{
			throw MTSQLRuntimeErrorException((boost::format("Invalid argument '%1%' to function datediff") % args[0]->getStringPtr()).str());
		}
	}
};

class RandFunction : public PrimitiveFunctionImpl
{
private:
  // Define a uniform random number distribution which produces "double"
  // values between 0 and 1 (0 inclusive, 1 exclusive).
  boost::minstd_rand mGenerator;
  boost::uniform_real<> mUniformDistribution;
  boost::variate_generator<boost::minstd_rand&, boost::uniform_real<> > mUni;

public:

	RandFunction()
    :
    mGenerator(42u),
    mUniformDistribution(0,1),
    mUni(mGenerator, mUniformDistribution)
	{
    mRetType = RuntimeValue::TYPE_DOUBLE;
		mName = "rand";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 0) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    double val = mUni();
    result->assignDouble(val);
	}
};

class IntegerHashFunction : public PrimitiveFunctionImpl
{
private:

public:

	IntegerHashFunction()
	{
    mRetType = RuntimeValue::TYPE_INTEGER;
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mName = "hash";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    boost::uint32_t state = (boost::uint32_t) args[0]->getLong();

    // Take one of Jenkins mixing functions and make sure all the
    // arithmetic is mod 2^31 so we don't create negative numbers.
    // This preserves reversiblility.

        state += (state << 12);
        state &= 0x7fffffff;

        state ^= (state >> 22);

        state += (state << 4);
        state &= 0x7fffffff;

        state ^= (state >> 9);

        state += (state << 10);
        state &= 0x7fffffff;

        state ^= (state >> 2);

        state += (state << 7);
        state &= 0x7fffffff;

        state ^= (state >> 12);

    result->assignLong((boost::int32_t) state);
	}
};

class ParseGuidFunction : public PrimitiveFunctionImpl
{
private:
  boost::uint8_t * mLUT;
public:

	ParseGuidFunction()
    :
    mLUT(NULL)
	{
    mRetType = RuntimeValue::TYPE_BINARY;
		mArgTypes.push_back(RuntimeValue::TYPE_WSTRING);
		mName = "parse_guid";
    mLUT = new boost::uint8_t [std::numeric_limits<wchar_t>::max() - std::numeric_limits<wchar_t>::min() + 1];
    memset(mLUT, -1, std::numeric_limits<wchar_t>::max() - std::numeric_limits<wchar_t>::min() + 1);
    mLUT += std::numeric_limits<wchar_t>::min();
    mLUT[L'0'] = 0;
    mLUT[L'1'] = 1;
    mLUT[L'2'] = 2;
    mLUT[L'3'] = 3;
    mLUT[L'4'] = 4;
    mLUT[L'5'] = 5;
    mLUT[L'6'] = 6;
    mLUT[L'7'] = 7;
    mLUT[L'8'] = 8;
    mLUT[L'9'] = 9;
    mLUT[L'a'] = 10;
    mLUT[L'b'] = 11;
    mLUT[L'c'] = 12;
    mLUT[L'd'] = 13;
    mLUT[L'e'] = 14;
    mLUT[L'f'] = 15;
    mLUT[L'A'] = 10;
    mLUT[L'B'] = 11;
    mLUT[L'C'] = 12;
    mLUT[L'D'] = 13;
    mLUT[L'E'] = 14;
    mLUT[L'F'] = 15;
	}

  ~ParseGuidFunction()
  {
    mLUT -= std::numeric_limits<wchar_t>::min();
    delete [] mLUT;
  }

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    boost::uint8_t buf[16];
    boost::uint8_t * bufptr = &buf[0];
    
    // Pattern of hex digits with dash delimiter: 8,4,4,4,12
    const wchar_t * str = args[0]->getWStringPtr();
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (*str++ != L'-') throw MTSQLRuntimeErrorException("invalid guid format");
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (*str++ != L'-') throw MTSQLRuntimeErrorException("invalid guid format");
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (*str++ != L'-') throw MTSQLRuntimeErrorException("invalid guid format");
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (*str++ != L'-') throw MTSQLRuntimeErrorException("invalid guid format");
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr = mLUT[*str++];
    if (mLUT[*str] == 0xff) throw MTSQLRuntimeErrorException("invalid guid format");
    *bufptr++ |= (mLUT[*str++]) << 4;

    result->assignBinary(&buf[0], bufptr);
	}
};

class PrintGuidFunction : public PrimitiveFunctionImpl
{
private:
  wchar_t * mLUT;
public:

	PrintGuidFunction()
    :
    mLUT(NULL)
	{
    mRetType = RuntimeValue::TYPE_WSTRING;
		mArgTypes.push_back(RuntimeValue::TYPE_BINARY);
		mName = "print_guid";
    mLUT = new wchar_t [16];
    mLUT[0] = '0';
    mLUT[1] = '1';
    mLUT[2] = '2';
    mLUT[3] = '3';
    mLUT[4] = '4';
    mLUT[5] = '5';
    mLUT[6] = '6';
    mLUT[7] = '7';
    mLUT[8] = '8';
    mLUT[9] = '9';
    mLUT[10] = 'a';
    mLUT[11] = 'b';
    mLUT[12] = 'c';
    mLUT[13] = 'd';
    mLUT[14] = 'e';
    mLUT[15] = 'f';
	}

  ~PrintGuidFunction()
  {
    delete [] mLUT;
  }

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

    wchar_t buf[37];
    wchar_t * bufptr=&buf[0];
    // Pattern of hex digits with dash delimiter: 8,4,4,4,12
    const boost::uint8_t * str = args[0]->getBinaryPtr();
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = L'-';
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = L'-';
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = L'-';
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = L'-';
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr++ = mLUT[((*str) & 0xf0) >> 4];
    *bufptr++ = mLUT[(*str++) & 0x0f];
    *bufptr = 0;
    result->assignWString(buf);
	}
};

class NewGuidFunction : public PrimitiveFunctionImpl
{
private:

public:

	NewGuidFunction()
	{
    mRetType = RuntimeValue::TYPE_BINARY;
		mName = "uuidgen";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 0) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    UUID uuid;
    ::UuidCreate(&uuid);
    
    result->assignBinary(reinterpret_cast<const boost::uint8_t*>(&uuid), reinterpret_cast<const boost::uint8_t*>(&uuid + 1));
	}
};

class DayFunction : public PrimitiveFunctionImpl
{
private:

public:

	DayFunction()
	{
    mRetType = RuntimeValue::TYPE_INTEGER;
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mName = "day";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    SYSTEMTIME t;
    ::VariantTimeToSystemTime(args[0]->getDatetime(), &t);
    result->assignLong(t.wDay);
	}
};

class MonthFunction : public PrimitiveFunctionImpl
{
private:

public:

	MonthFunction()
	{
    mRetType = RuntimeValue::TYPE_INTEGER;
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mName = "month";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    SYSTEMTIME t;
    ::VariantTimeToSystemTime(args[0]->getDatetime(), &t);
    result->assignLong(t.wMonth);
	}
};

class YearFunction : public PrimitiveFunctionImpl
{
private:

public:

	YearFunction()
	{
    mRetType = RuntimeValue::TYPE_INTEGER;
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mName = "year";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    SYSTEMTIME t;
    ::VariantTimeToSystemTime(args[0]->getDatetime(), &t);
    result->assignLong(t.wYear);
	}
};

class DecimalCompareFunction : public PrimitiveFunctionImpl
{
private:

public:

	DecimalCompareFunction()
	{
    mRetType = RuntimeValue::TYPE_BOOLEAN;
    mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mArgTypes.push_back(RuntimeValue::TYPE_DECIMAL);
		mArgTypes.push_back(RuntimeValue::TYPE_DECIMAL);
		mName = "compare";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 3) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

    switch(args[0]->getLong())
    {
    case 0:
      RuntimeValue::Equals(args[1], args[2], result);
      break;
    case 1:
      RuntimeValue::NotEquals(args[1], args[2], result);
      break;
    case 2:
      RuntimeValue::LessThan(args[1], args[2], result);
      break;
    case 3:
      RuntimeValue::LessThanEquals(args[1], args[2], result);
      break;
    case 4:
      RuntimeValue::GreaterThan(args[1], args[2], result);
      break;
    case 5:
      RuntimeValue::GreaterThanEquals(args[1], args[2], result);
      break;
    }
 	}
};

class IntegerCompareFunction : public PrimitiveFunctionImpl
{
private:

public:

	IntegerCompareFunction()
	{
    mRetType = RuntimeValue::TYPE_BOOLEAN;
    mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mName = "compare";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 3) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

    switch(args[0]->getLong())
    {
    case 0:
      RuntimeValue::Equals(args[1], args[2], result);
      break;
    case 1:
      RuntimeValue::NotEquals(args[1], args[2], result);
      break;
    case 2:
      RuntimeValue::LessThan(args[1], args[2], result);
      break;
    case 3:
      RuntimeValue::LessThanEquals(args[1], args[2], result);
      break;
    case 4:
      RuntimeValue::GreaterThan(args[1], args[2], result);
      break;
    case 5:
      RuntimeValue::GreaterThanEquals(args[1], args[2], result);
      break;
    }
 	}
};

class EnumCompareFunction : public PrimitiveFunctionImpl
{
private:

public:

	EnumCompareFunction()
	{
    mRetType = RuntimeValue::TYPE_BOOLEAN;
    mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mArgTypes.push_back(RuntimeValue::TYPE_ENUM);
		mArgTypes.push_back(RuntimeValue::TYPE_ENUM);
		mName = "compare";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 3) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

    switch(args[0]->getLong())
    {
    case 0:
      RuntimeValue::Equals(args[1], args[2], result);
      break;
    case 1:
      RuntimeValue::NotEquals(args[1], args[2], result);
      break;
    case 2:
      RuntimeValue::LessThan(args[1], args[2], result);
      break;
    case 3:
      RuntimeValue::LessThanEquals(args[1], args[2], result);
      break;
    case 4:
      RuntimeValue::GreaterThan(args[1], args[2], result);
      break;
    case 5:
      RuntimeValue::GreaterThanEquals(args[1], args[2], result);
      break;
    }
 	}
};

class DatetimeCompareFunction : public PrimitiveFunctionImpl
{
private:

public:

	DatetimeCompareFunction()
	{
    mRetType = RuntimeValue::TYPE_BOOLEAN;
    mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mArgTypes.push_back(RuntimeValue::TYPE_DATETIME);
		mName = "compare";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 3) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

    switch(args[0]->getLong())
    {
    case 0:
      RuntimeValue::Equals(args[1], args[2], result);
      break;
    case 1:
      RuntimeValue::NotEquals(args[1], args[2], result);
      break;
    case 2:
      RuntimeValue::LessThan(args[1], args[2], result);
      break;
    case 3:
      RuntimeValue::LessThanEquals(args[1], args[2], result);
      break;
    case 4:
      RuntimeValue::GreaterThan(args[1], args[2], result);
      break;
    case 5:
      RuntimeValue::GreaterThanEquals(args[1], args[2], result);
      break;
    }
 	}
};

class BigintCompareFunction : public PrimitiveFunctionImpl
{
private:

public:

	BigintCompareFunction()
	{
    mRetType = RuntimeValue::TYPE_BOOLEAN;
    mArgTypes.push_back(RuntimeValue::TYPE_INTEGER);
		mArgTypes.push_back(RuntimeValue::TYPE_BIGINTEGER);
		mArgTypes.push_back(RuntimeValue::TYPE_BIGINTEGER);
		mName = "compare";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 3) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

    switch(args[0]->getLong())
    {
    case 0:
      RuntimeValue::Equals(args[1], args[2], result);
      break;
    case 1:
      RuntimeValue::NotEquals(args[1], args[2], result);
      break;
    case 2:
      RuntimeValue::LessThan(args[1], args[2], result);
      break;
    case 3:
      RuntimeValue::LessThanEquals(args[1], args[2], result);
      break;
    case 4:
      RuntimeValue::GreaterThan(args[1], args[2], result);
      break;
    case 5:
      RuntimeValue::GreaterThanEquals(args[1], args[2], result);
      break;
    }
 	}
};

class BinaryBase64EncodeFunction : public PrimitiveFunctionImpl
{
private:

public:

	BinaryBase64EncodeFunction()
	{
    mRetType = RuntimeValue::TYPE_STRING;
    mArgTypes.push_back(RuntimeValue::TYPE_BINARY);
		mName = "base64";
	}

	void execute(const RuntimeValue** args, int sz, RuntimeValue * result) 
	{
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");
    
    std::string asciiResult;
    rfc1421encode(args[0]->getBinaryPtr(), 16, asciiResult);
    result->assignString(asciiResult);
	}
};

class TrimFunction : public PrimitiveFunctionImpl
{
private:

public:

	TrimFunction()
	{
		mRetType = RuntimeValue::TYPE_STRING;

		mArgTypes.push_back(RuntimeValue::TYPE_STRING);

		mName = "trim";
	}

	void execute(const RuntimeValue **args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }

	result->assignString(boost::algorithm::trim_copy<std::string>(args[0]->getStringPtr()));
	}
};

class WTrimFunction : public PrimitiveFunctionImpl
{
private:

public:

	WTrimFunction()
	{
		mRetType = RuntimeValue::TYPE_WSTRING;

		mArgTypes.push_back(RuntimeValue::TYPE_WSTRING);

		mName = "trim";
	}

	void execute(const RuntimeValue **args, int sz, RuntimeValue * result)
	{
		// Should have these runtime check optional(this should
		// be validated by semantic analysis)
		if(sz != 1) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Incorrect number of arguments passed to primitive function");

    for(int i = 0; i < sz; i++)
    {
      if (args[i]->isNullRaw())
      {
        result->assignNull();
        return;
      }
    }

	result->assignWString(boost::algorithm::trim_copy<std::wstring>(args[0]->getWStringPtr()));

	}
};

StandardLibrary::StandardLibrary()
{
	mFunctions.push_back(new WLenFunction());
	mFunctions.push_back(new WSubstrFunction());
	mFunctions.push_back(new WUpperFunction());
	mFunctions.push_back(new WLowerFunction());
	mFunctions.push_back(new LenFunction());
	mFunctions.push_back(new SubstrFunction());
	mFunctions.push_back(new UpperFunction());
	mFunctions.push_back(new LowerFunction());

	mFunctions.push_back(new RoundFunction());
	mFunctions.push_back(new FloorFunction());
	mFunctions.push_back(new CeilingFunction());
	mFunctions.push_back(new GetdateFunction());
	mFunctions.push_back(new GetutcdateFunction());
	mFunctions.push_back(new SquareFunction());
	mFunctions.push_back(new SquareRootFunction());
	mFunctions.push_back(new IntervaldaysFunction());
	mFunctions.push_back(new DateaddFunction());
	mFunctions.push_back(new DateaddIntegerFunction());
	mFunctions.push_back(new DatediffFunction());
	mFunctions.push_back(new WDateaddFunction());
	mFunctions.push_back(new WDateaddIntegerFunction());
	mFunctions.push_back(new WDatediffFunction());
	mFunctions.push_back(new ARoundFunction());
	mFunctions.push_back(new BRoundFunction());
	mFunctions.push_back(new RandFunction());
	mFunctions.push_back(new IntegerHashFunction());
	mFunctions.push_back(new ParseGuidFunction());
	mFunctions.push_back(new PrintGuidFunction());
	mFunctions.push_back(new NewGuidFunction());
	mFunctions.push_back(new DayFunction());
	mFunctions.push_back(new MonthFunction());
	mFunctions.push_back(new YearFunction());
	mFunctions.push_back(new DecimalCompareFunction());
	mFunctions.push_back(new IntegerCompareFunction());
	mFunctions.push_back(new EnumCompareFunction());
	mFunctions.push_back(new DatetimeCompareFunction());
	mFunctions.push_back(new BigintCompareFunction());
	mFunctions.push_back(new BinaryBase64EncodeFunction());

	mFunctions.push_back(new TrimFunction());
	mFunctions.push_back(new WTrimFunction());
}

StandardLibrary::~StandardLibrary()
{
	// delete all of the function in the library
	while(mFunctions.size() > 0)
	{
		delete mFunctions.back();
		mFunctions.pop_back();
	}
}

std::vector<PrimitiveFunction*> StandardLibrary::getFunctions() const 
{
	return mFunctions;
}

void StandardLibrary::load()
{
	// No-op since this is not yet dynamically loaded
}



