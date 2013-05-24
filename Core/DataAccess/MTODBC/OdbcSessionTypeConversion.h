#ifndef _ODBCSESSIONTYPECONVERSION_H_
#define _ODBCSESSIONTYPECONVERSION_H_

#include <time.h>
#include <odbcss.h>
#include <MTDec.h>
#include <OdbcType.h>
#include <string>

inline void OLEDateToOdbcTimestamp(const DATE* aDateVal, TIMESTAMP_STRUCT* aTimestampVal)
{
	SYSTEMTIME systemTime;
	::VariantTimeToSystemTime(*aDateVal, &systemTime);
	aTimestampVal->day = systemTime.wDay;
	aTimestampVal->month = systemTime.wMonth;
	aTimestampVal->year = systemTime.wYear;
	aTimestampVal->hour = systemTime.wHour;
	aTimestampVal->minute = systemTime.wMinute;
	aTimestampVal->second = systemTime.wSecond;
	aTimestampVal->fraction = systemTime.wMilliseconds;
}

inline void OdbcTimestampToOLEDate(const TIMESTAMP_STRUCT* aTimestampVal, DATE* aDateVal)
{
	SYSTEMTIME systemTime;
	systemTime.wDay = aTimestampVal->day;
	systemTime.wMonth = aTimestampVal->month;
	systemTime.wYear = aTimestampVal->year;
	systemTime.wHour = aTimestampVal->hour;
	systemTime.wMinute = aTimestampVal->minute;
	systemTime.wSecond = aTimestampVal->second;
	systemTime.wMilliseconds = (short)aTimestampVal->fraction;

	::SystemTimeToVariantTime(&systemTime, aDateVal);
}

inline void OdbcTimestampToTimet(const TIMESTAMP_STRUCT* aTimestampVal, time_t* aTimeT)
{
	struct tm timeTm;
	
	timeTm.tm_hour =aTimestampVal->hour;

	timeTm.tm_min = aTimestampVal->minute;
	timeTm.tm_sec = aTimestampVal->second;
	timeTm.tm_mday = aTimestampVal->day;
	timeTm.tm_mon = aTimestampVal->month - 1; // odbc months start from 1
	timeTm.tm_year = aTimestampVal->year-1900; // Year(current year minus 1900)
	timeTm.tm_wday = 0;
	timeTm.tm_isdst = 0;
	timeTm.tm_yday = 0;

	* aTimeT = mktime(&timeTm); 
	* aTimeT -= _timezone;
}

inline void TimetToOdbcTimestamp(const time_t* aTimeT, TIMESTAMP_STRUCT* aTimestampVal)
{
	struct tm * pTimeTm = gmtime(aTimeT);
	
	aTimestampVal->hour = pTimeTm->tm_hour;
	aTimestampVal->minute = pTimeTm->tm_min;
	aTimestampVal->second = pTimeTm->tm_sec;
	aTimestampVal->fraction = 0;

	aTimestampVal->day = pTimeTm->tm_mday;
	aTimestampVal->month = pTimeTm->tm_mon + 1;
	aTimestampVal->year = pTimeTm->tm_year + 1900;
}

class DecimalZero
{
private:
  DECIMAL mZero;
public:
  DecimalZero()
  {
    mZero.Lo64 = 0;
    mZero.Hi32 = 0;
    mZero.sign = 0;
    mZero.scale = METRANET_SCALE_MAX;
  }

  const DECIMAL * operator &() const { return &mZero; }
};
    

inline void DecimalToOdbcNumeric(const DECIMAL * decVal, SQL_NUMERIC_STRUCT * numericVal)
{
	static const int LOBYTES(8);
	static const int HIBYTES(4);
	static const int DECBYTES(12); // Num of bytes in a decimal.  Sum of lo and hi
	static const int NUMBYTES(16); // Num of bytes in a numeric
	static const int NUMERIC_SCALE(METRANET_SCALE_MAX); //scale we want in the OdbcNumeric

  DECIMAL tmp;

	// Normalize scale to NUMERIC_SCALE
		if(decVal->scale < NUMERIC_SCALE)
		{
			//adding a decimal of NUMERIC_SCALE, creates a decimal of that scale

    static const DecimalZero decZero;
    ::VarDecAdd((LPDECIMAL) decVal, (LPDECIMAL) &decZero, &tmp);

    decVal = &tmp;
		}
  else if (decVal->scale > NUMERIC_SCALE)
		{
			//round scale down to NUMERIC_SCALE
    ::VarDecRound((LPDECIMAL) decVal, NUMERIC_SCALE, &tmp);

    decVal = &tmp;
	}

	ASSERT(decVal->scale == NUMERIC_SCALE);


	numericVal->precision = METRANET_PRECISION_MAX;
	numericVal->scale = NUMERIC_SCALE;
	numericVal->sign = decVal->sign == DECIMAL_NEG ? 0 : 1;

	memcpy(numericVal->val, &decVal->Lo64, LOBYTES);
	memcpy(numericVal->val + LOBYTES, &decVal->Hi32, HIBYTES);
	memset(numericVal->val + DECBYTES, 0, NUMBYTES - DECBYTES);
}

inline void OdbcNumericToDecimal(const SQL_NUMERIC_STRUCT * numericVal,  DECIMAL * decVal)
{
	static const int LOBYTES(8);
	static const int HIBYTES(4);
	static const int NUMERIC_SCALE(METRANET_SCALE_MAX); //scale we want in the DECIMAL
	
	decVal->scale = numericVal->scale;
	decVal->sign = (numericVal->sign == 0) ? DECIMAL_NEG : 0;

	memcpy(&decVal->Lo64, numericVal->val, LOBYTES);
	memcpy(&decVal->Hi32, numericVal->val + LOBYTES, HIBYTES);

	// normalize scale to NUMERIC_SCALE
	if (numericVal->scale != NUMERIC_SCALE)
	{
		MTDecimal mtdecVal(*decVal);

		if(decVal->scale < NUMERIC_SCALE)
		{
			//adding a decimal of NUMERIC_SCALE, creates a decimal of that scale
			
			DECIMAL decZero; //= 0.000000
			decZero.Lo64 = 0;
			decZero.Hi32 = 0;
			decZero.sign = 0;
			decZero.scale = NUMERIC_SCALE;

			mtdecVal = mtdecVal + decZero;
		}
		else	
		{
			//round scale down to NUMERIC_SCALE
			mtdecVal.Round(NUMERIC_SCALE);
		}

		decVal = &mtdecVal;
	}

	ASSERT(decVal->scale == NUMERIC_SCALE);
}

inline double OdbcNumericToDouble(SQL_NUMERIC_STRUCT * numericVal)
{
	//convert little endian value to int64
	__int64 int64Value = 0;
	__int64 lastVal = 1;
	for(int i=0;i<=15;i++)
	{
		int current = (int) numericVal->val[i];
		int LSD = current % 16; //Obtain LSD
		int MSD = current / 16; //Obtain MSD
				
		int64Value += lastVal * LSD; 
		lastVal = lastVal * 16; 
		int64Value += lastVal * MSD;
		lastVal = lastVal * 16; 
	}

	//divide value by scale
	int divisor = 1;
	for (i=0; i < numericVal->scale; i++)	
	{	divisor = divisor * 10;
	}

 	// fix up sign
	// NOTE: ODBC 3.0 requires 2 for negative, ODBC 3.5 requires 0,
	// so just test for positive
	if(numericVal->sign != 1)
	{	int64Value *= -1;
	}

	double retVal = (double) int64Value  / (double) divisor;

	return retVal;
}

inline void OdbcDecimalToDecimal(const COdbcDecimal & odbcDecVal,  DECIMAL * decVal)
{
	const SQL_NUMERIC_STRUCT * numericVal = odbcDecVal.GetBuffer();
  ::OdbcNumericToDecimal(numericVal, decVal);
}


// day = day of month, beginning at 1
// month = month of year, beginning at 1
// year = 4 digit year 
//
// Note: this only works for A.D. days in the Gregorian Calendar
inline long JulianDay(long day, long month, long year)
{
	// To compute, take the difference between the number of Julian Days
	long a = (14 - month)/12;
	long y = year + 4800 - a;
	long m = month + 12*a - 3;
	return day + (153*m + 2)/5 + 365*y + y/4 - y/100 + y/400 -32045;
}

// DBDATETIME.dtdays = number of days since 1/1/1900
// DBDATETIME.dttime = number of (1/300) sec since midnight
inline void OLEDateToBCPDatetime(const DATE * aDate, DBDATETIME * aDatetime)
{
	SYSTEMTIME systemTime;
	::VariantTimeToSystemTime(*aDate, &systemTime);

	const long julianDay1900 = JulianDay(1, 1, 1900);

	aDatetime->dtdays = JulianDay(systemTime.wDay, systemTime.wMonth, systemTime.wYear) - julianDay1900;
	aDatetime->dttime = 
		(300*60*60)*systemTime.wHour + 
		(300*60)*systemTime.wMinute + 
		(300)*systemTime.wSecond + 
		(300*systemTime.wMilliseconds)/1000;
}

inline void OdbcTimestampToBCPDatetime(const TIMESTAMP_STRUCT* aTimestamp, DBDATETIME * aDatetime)
{
	const long julianDay1900 = JulianDay(1, 1, 1900);

	aDatetime->dtdays = JulianDay(aTimestamp->day, aTimestamp->month, aTimestamp->year) - julianDay1900;
	aDatetime->dttime = 
		(300*60*60)*aTimestamp->hour + 
		(300*60)*aTimestamp->minute + 
		(300)*aTimestamp->second + 
		(300*aTimestamp->fraction)/1000;
}

inline std::string WideStringToString(const wchar_t* str)
{
	size_t size = ::wcstombs(NULL, str, ::wcslen(str));
	char * buf = new char [size+1];
	size = ::wcstombs(buf, str, ::wcslen(str));
	buf[size] = 0;
	// I don't know whether it is possible to get STL to take ownership of this
	// buffer rather than copy...
	std::string cvt(buf);
	delete [] buf;
	return cvt;
}

#endif
