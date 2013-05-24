#include <metra.h>
#include <MTDecimalVal.h>
#include <MTUtil.h>
#include <stdutils.h>

MTDecimalVal::MTDecimalVal(const MTDecimalVal & arDecimalVal)
{
	*this = arDecimalVal;
}


MTDecimalVal & MTDecimalVal::operator = (const MTDecimalVal & arDecimalVal)
{
	mValue = arDecimalVal.mValue;
	return *this;
}


BOOL MTDecimalVal::SetValue(double doubleVal)
{
	wchar_t buf[40];

	// print in "0.1234567890" form
#ifdef WIN32
	_snwprintf(buf, 40, L"%01.10f", doubleVal);
#else
	swprintf(buf, 40, L"%01.10f", doubleVal);
#endif

	mValue = buf;
	
	return TRUE;
}


BOOL MTDecimalVal::SetValue(long longVal)
{
	wchar_t buf[40];

	// print in "123.0000000000" form
#ifdef WIN32
	_snwprintf(buf, 40, L"%ld.0000000000", longVal);
#else
	swprintf(buf, 40, L"%ld.0000000000", longVal);
#endif

	mValue = buf;
	
	return TRUE;

}

BOOL MTDecimalVal::SetValue(const char* strValue)
{
	std::wstring wstr;
	if(!ASCIIToWide(wstr, strValue))
		return false;

	return SetValue(wstr.c_str());
}


BOOL MTDecimalVal::SetValue(const wchar_t* strValue)
{
	mValue = strValue;

	// check that passed string contains only digits.
	if(mValue.find_first_not_of(L"0123456789-.") != wstring::npos)
	{
		mValue = L"0";
		return FALSE;
	}

	return TRUE;
}



// fractionalValPart must be in units of 10^-10.
// Since 10 decimal digits won't fit in 4 bytes,
// fractionalValPart must be of type long long (8 bytes).
// lowFixedValPart contains the 9 least significant digits
// of the integral part and fits in a long.
BOOL MTDecimalVal::SetValue(long hiFixedValPart, long lowFixedValPart, long long fractionalValPart)
{
	bool bNegative = false;

	mValue = L"0";

	// check, that all parts have the same sign
	// for positive number all parts must be positive.
	if((hiFixedValPart >= 0) && (lowFixedValPart >= 0) && (fractionalValPart >= 0))
	{
		// do nothing
		;
	}
	else
	// for negative number all parts must be negative.
	if((hiFixedValPart <= 0) && (lowFixedValPart <= 0) && (fractionalValPart <= 0))
	{
		// make all parts positive
		hiFixedValPart = -hiFixedValPart;
		lowFixedValPart = -lowFixedValPart;
		fractionalValPart = -fractionalValPart;
		bNegative = true;
	}
	else
	{
		// we don't process mixed parts
		return FALSE;
	}

	// check parts' limits
	if((lowFixedValPart > 999999999) || (fractionalValPart > 9999999999))
		return false;

	// sprintf the value!
	wchar_t buf[40];

	// if hi part is specified, use it! 
	if(hiFixedValPart != 0)
	{

#ifdef WIN32
	  _snwprintf(buf, 40, L"%d%09d.%010d", hiFixedValPart, lowFixedValPart, fractionalValPart);
#else
	  swprintf(buf, 40, L"%d%09d.%010d", hiFixedValPart, lowFixedValPart, fractionalValPart);
#endif
	}
	else
	{
		// high fixed part is 0, don't use it (and don't pad it with 0s)
#ifdef WIN32
	  _snwprintf(buf, 40, L"%d.%010d", lowFixedValPart, fractionalValPart);
#else
	  swprintf(buf, 40, L"%d.%010d", lowFixedValPart, fractionalValPart);
#endif
	}

	mValue = std::wstring(bNegative ? L"-" : L"") + buf;
 
	return TRUE;
}



BOOL MTDecimalVal::Format(char * buffer, int & bufferSize) const
{
	int required = mValue.length() + 1;
	if (bufferSize == 0)
	{
		bufferSize = required;
		return TRUE;
	}

	if (!buffer)
		return FALSE;

	std::string val = ascii(mValue);
	strncpy(buffer, val.c_str(), bufferSize);
	if (bufferSize >= required)
		buffer[required] = '\0';

	return TRUE;
}

BOOL MTDecimalVal::Format(wchar_t * buffer, int & bufferSize) const
{
	int required = mValue.length() + 1;
	if (bufferSize == 0)
	{
		bufferSize = required;
		return TRUE;
	}

	if (!buffer)
		return FALSE;

	if (bufferSize <= required)
		wcsncpy(buffer, mValue.c_str(), bufferSize);
	else
	{
		wcscpy(buffer, mValue.c_str());
		if (bufferSize >= required)
			buffer[required] = L'\0';
	}

	return TRUE;
}
