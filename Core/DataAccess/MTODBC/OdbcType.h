#ifndef _ODBCTYPE_H_
#define _ODBCTYPE_H_
#include <metralite.h>
#include <autoptr.h>
#include <sql.h>
#include <SharedDefs.h>
// TODO: remove undefs
#if defined(MTODBC_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif


// Simple wrapper around a SQL_NUMERIC_STRUCT that does copy on write
// optimization so that we can just pass these puppies around by value.
class COdbcDecimal
{
private:
	MTautoptr<SQL_NUMERIC_STRUCT> mData;

	void cow()
	{
		// TODO: Copy only if this is a shared pointer
		MTautoptr<SQL_NUMERIC_STRUCT> tmp(new SQL_NUMERIC_STRUCT);
		tmp->precision = mData->precision;
		tmp->scale = mData->scale;
		tmp->sign = mData->sign;
		memcpy(tmp->val, mData->val, SQL_MAX_NUMERIC_LEN);
		mData = tmp;
	}
public:
	// Default constructor initializes to zero
	DllExport COdbcDecimal() 
	{
		mData = MTautoptr<SQL_NUMERIC_STRUCT>(new SQL_NUMERIC_STRUCT);
		mData->precision = METRANET_PRECISION_MAX;
		mData->scale = METRANET_SCALE_MAX;
		mData->sign = 1;
		memset(mData->val, 0, sizeof(mData->val));
	}

	DllExport COdbcDecimal(const COdbcDecimal& dec)
	{
		mData = dec.mData;
	}

	DllExport explicit COdbcDecimal(SQL_NUMERIC_STRUCT* val, bool bCopy)
	{
		if (bCopy)
		{
			mData = MTautoptr<SQL_NUMERIC_STRUCT>(new SQL_NUMERIC_STRUCT);
			memcpy(mData.GetObject(), val, sizeof(SQL_NUMERIC_STRUCT));
		}
		else
		{
			mData = MTautoptr<SQL_NUMERIC_STRUCT>(val);
		}
	}

	DllExport COdbcDecimal& operator=(const COdbcDecimal& dec)
	{
		mData = dec.mData;
		return *this;
	}

	DllExport bool operator==(const COdbcDecimal& dec) const
	{
		return 0 == memcmp(mData.GetObject(), dec.mData.GetObject(), sizeof(SQL_NUMERIC_STRUCT));
	}

	// DON'T BE CASTING AWAY CONSTNESS!  THIS IS A SHARED BUFFER.
	// To modify, use the setters...
	DllExport const SQL_NUMERIC_STRUCT* GetBuffer() const
	{
		return mData.GetObject();
	}

	DllExport SQLCHAR GetPrecision() const 
	{ 
		return mData->precision; 
	}
	DllExport SQLSCHAR GetScale() const 
	{ 
		return mData->scale; 
	}
	DllExport SQLCHAR GetSign() const 
	{ 
		return mData->sign; 
	}
	DllExport const SQLCHAR*  GetVal() const 
	{ 
		return &mData->val[0]; 
	}

	DllExport void SetPrecision(SQLCHAR precision) 
	{ 
		cow(); 
		mData->precision = precision; 
	}
	DllExport void SetScale(SQLSCHAR scale) 
	{ 
		cow(); 
		mData->scale = scale; 
	}
	DllExport void SetSign(SQLCHAR sign)
	{
		ASSERT(sign == 0 || sign == 1);
		cow();
		mData->sign = sign;
	}
	DllExport void SetVal(const SQLCHAR* val)
	{
		cow();
		memcpy(mData->val, val, SQL_MAX_NUMERIC_LEN);
	}
};

class COdbcTimestamp
{
private:
	MTautoptr<TIMESTAMP_STRUCT> mData;

	void cow()
	{
		// TODO: Copy only if this is a shared pointer
		MTautoptr<TIMESTAMP_STRUCT> tmp(new TIMESTAMP_STRUCT);
		tmp->day = mData->day;
		tmp->month = mData->month;
		tmp->year = mData->year;
		tmp->hour = mData->hour;
		tmp->minute = mData->minute;
		tmp->second = mData->second;
		tmp->fraction = mData->fraction;
		mData = tmp;
	}
public:
	DllExport COdbcTimestamp()
	{
		mData = MTautoptr<TIMESTAMP_STRUCT>(new TIMESTAMP_STRUCT);
		mData->day = 1;
		mData->month = 1;
		mData->year = 1970;
		mData->hour = 0;
		mData->minute = 0;
		mData->second = 0;
		mData->fraction = 0;
	}


	DllExport COdbcTimestamp(const COdbcTimestamp& val)
	{
		mData = val.mData;
	}

	// Attach to the pointer and take ownership of it
	DllExport explicit COdbcTimestamp(TIMESTAMP_STRUCT* val, bool bCopy) 
	{
		if(bCopy)
		{
			mData = MTautoptr<TIMESTAMP_STRUCT>(new TIMESTAMP_STRUCT);
			memcpy(mData.GetObject(), val, sizeof(TIMESTAMP_STRUCT));
		}
		else
		{
			mData = MTautoptr<TIMESTAMP_STRUCT>(val);
		}
	}

	DllExport COdbcTimestamp& operator=(const COdbcTimestamp& dec)
	{
		mData = dec.mData;
		return *this;
	}

	DllExport bool operator==(const COdbcTimestamp& dec) const
	{
		return 0 == memcmp(mData.GetObject(), dec.mData.GetObject(), sizeof(TIMESTAMP_STRUCT));
	}

	// DON'T BE CASTING AWAY CONSTNESS!  THIS IS A SHARED BUFFER.
	// To modify, use the setters...
	DllExport const TIMESTAMP_STRUCT* GetBuffer() const
	{
		return mData.GetObject();
	}

	DllExport operator const TIMESTAMP_STRUCT&()
	{
		return *(mData.GetObject());
	}

	DllExport SQLSMALLINT GetYear() const
	{
		return mData->year;
	}
	DllExport SQLUSMALLINT GetMonth() const
	{
		return mData->month;
	}
	DllExport SQLUSMALLINT GetDay() const
	{
		return mData->day;
	}
	DllExport SQLUSMALLINT GetHour() const
	{  
		return mData->hour;
	}
	DllExport SQLUSMALLINT GetMinute() const
	{
		return mData->minute;
	}
	DllExport SQLUSMALLINT GetSecond() const
	{
		return mData->second;
	}
	DllExport SQLUINTEGER GetFraction() const
	{
		return mData->fraction;
	}
	
	DllExport void SetYear(SQLSMALLINT year)
	{
		cow();
		mData->year = year;
	}
	DllExport void SetMonth(SQLUSMALLINT month)
	{
		cow();
		mData->month = month;
	}
	DllExport void SetDay(SQLUSMALLINT day)
	{
		cow();
		mData->day = day;
	}
	DllExport void SetHour(SQLUSMALLINT hour)
	{
		cow();
		mData->hour = hour;
	}
	DllExport void SetMinute(SQLUSMALLINT minute)
	{  
		cow();
		mData->minute = minute;
	}
	DllExport void SetSecond(SQLUSMALLINT second)
	{
		cow();
		mData->second = second;
	}
	DllExport void SetFraction(SQLUINTEGER fraction)
	{
		cow();
		mData->fraction = fraction;
	}
};

#endif
