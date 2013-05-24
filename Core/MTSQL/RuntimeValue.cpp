#include <MTUtil.h>
#include <RuntimeValue.h>
#include <mtprogids.h>
#include <RuntimeValueCast.h>
#include <boost/scoped_array.hpp>
#include <boost/format.hpp>

#import <MTEnumConfig.tlb>
#import <NameID.tlb>

RuntimeValue RuntimeValue::createWString(const string& val)
{
  wstring wval;
  ::ASCIIToWide(wval, (const char *)val.c_str(), -1, CP_UTF8);
  return RuntimeValue(wval);
}

bool RuntimeValue::WildcardMatch(const char * pat, const char * str) 
{
   int i;
   BOOL star = FALSE;

loopStart:
   for (i = 0; str[i]; i++) {
      switch (pat[i]) {
         case '%':
            star = true;
            str += i, pat += i;
            do { ++pat; } while (*pat == '%');
            if (!*pat) return true;
            goto loopStart;
         default:
// We are doing case sensitive matching.
//             if (mapCaseTable[str[i]] != mapCaseTable[pat[i]])
            if (str[i] != pat[i])
               goto starCheck;
            break;
      } /* endswitch */
   } /* endfor */
   while (pat[i] == '%') ++i;
   return (!pat[i]);

starCheck:
   if (!star) return false;
   str++;
   goto loopStart;
}

bool RuntimeValue::WildcardMatch(const wchar_t * pat, const wchar_t * str) 
{
   int i;
   BOOL star = FALSE;

loopStart:
   for (i = 0; str[i]; i++) {
      switch (pat[i]) {
         case L'%':
            star = true;
            str += i, pat += i;
            do { ++pat; } while (*pat == L'%');
            if (!*pat) return true;
            goto loopStart;
         default:
// We are doing case sensitive matching.
//             if (mapCaseTable[str[i]] != mapCaseTable[pat[i]])
            if (str[i] != pat[i])
               goto starCheck;
            break;
      } /* endswitch */
   } /* endfor */
   while (pat[i] == L'%') ++i;
   return (!pat[i]);

starCheck:
   if (!star) return false;
   str++;
   goto loopStart;
}


//  ostream& operator<<(ostream& str, const RuntimeValue& val) 
//  {
//  	switch(val.getType())
//  	{
//  	case RuntimeValue::eLong:
//  		str << val.getLong();
//  		break;
//  	case RuntimeValue::eBool:
//  		str << val.getBool();
//  		break;
//  	case RuntimeValue::eDouble:
//  		str << val.getDouble();
//  		break;
//  	case RuntimeValue::eStr:
//  		str << val.getString();
//  		break;
//  	case RuntimeValue::eDec:
//  		str << "Not yet implemented";
//  		break;
//  	case RuntimeValue::eDate:
//  		str << "Not yet implemented";
//  		break;
//  	}
//  	return str;
//  }

void RuntimeValue::StringPlus(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
{
  if(lhs->isNullRaw() || rhs->isNullRaw())
  {
    ret->assignNull();
  }
  else
  {
    std::size_t l = strlen(lhs->getStringPtr());
    std::size_t r = strlen(rhs->getStringPtr());
    boost::scoped_array<char> buf(new char [l + r + 1]);
    memcpy(buf.get(), lhs->getStringPtr(), l);
    memcpy(buf.get()+l, rhs->getStringPtr(), r);
    *(buf.get() + l + r) = 0;
    ret->assignString(buf.get());
  }
}

void RuntimeValue::WStringPlus(const RuntimeValue * lhs, const RuntimeValue * rhs, RuntimeValue * ret)
{
  if(lhs->isNullRaw() || rhs->isNullRaw())
  {
    ret->assignNull();
  }
  else
  {
    std::size_t l = wcslen(lhs->getWStringPtr());
    std::size_t r = wcslen(rhs->getWStringPtr());
    boost::scoped_array<wchar_t> buf(new wchar_t [l + r + 1]);
    memcpy(buf.get(), lhs->getWStringPtr(), sizeof(wchar_t)*l);
    memcpy(buf.get()+l, rhs->getWStringPtr(), sizeof(wchar_t)*r);
    *(buf.get() + l + r) = 0;
    ret->assignWString(buf.get());
  }
}

RuntimeValue RuntimeValue::StringLike(const RuntimeValue& lhs, const RuntimeValue& rhs)
{
  if (lhs.isNullRaw() || rhs.isNullRaw()) return RuntimeValue::createNull();

  const char* toMatch = lhs.getStringPtr();
  const char* pattern = rhs.getStringPtr();
  return RuntimeValue::createBool(WildcardMatch(pattern, toMatch));
}

RuntimeValue RuntimeValue::WStringLike(const RuntimeValue& lhs, const RuntimeValue& rhs)
{
  if (lhs.isNullRaw() || rhs.isNullRaw()) return RuntimeValue::createNull();

  const wchar_t * toMatch = lhs.getWStringPtr();
  const wchar_t * pattern = rhs.getWStringPtr();
  return RuntimeValue::createBool(WildcardMatch(pattern, toMatch));
}


void RuntimeValue::castToLong(RuntimeValue * ret) const 
{
	switch(mType)
	{
	case eLong:
		ret->assignLong(getLong());
    return;
	case eBool:
		ret->assignLong(getBool() ? 1L : 0L);
    return;
	case eDouble:
		ret->assignLong((long)getDouble());
    return;
	case eTinyStr:
	case eStr:
	{
		long lVal;
		sscanf(getStringPtr(), "%d", &lVal);
		ret->assignLong(lVal);
    return;
	}
	case eTinyWStr:
	case eWStr:
	{
		long lVal;
		swscanf(getWStringPtr(), L"%d", &lVal);
		ret->assignLong(lVal);
    return;
	}
	case eDec:
	{
		long lVal;
		HRESULT hr = VarI4FromDec((LPDECIMAL)&getDec(), &lVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignLong(lVal);
    return;
	}
	case eDate:
	{
		long lVal;
		HRESULT hr = VarI4FromDate(getDatetime(), &lVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignLong(lVal);
    return;
	}
	case eTime:
	{
		ret->assignLong(getTime());
    return;
	}
	case eEnum:
	{
		ret->assignLong(getEnum());
    return;
	}
	case eNull:
	{
		ret->assignNull();
    return;
	}
	case eLongLong:
	{
    ret->assignLong((long) getLongLong());
    return;
  }
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}

void RuntimeValue::castToDouble(RuntimeValue * ret) const 
{
	switch(mType)
	{
	case eLong:
		ret->assignDouble((double)getLong());
    return;
	case eBool:
		ret->assignDouble(getBool() ? 1.0 : 0.0);
    return;
	case eDouble:
		ret->assignDouble(getDouble());
    return;
	case eTinyStr:
	case eStr:
	{
		double dVal;
		const char * buf = getStringPtr();
		sscanf(buf, "%lE", &dVal);
		ret->assignDouble(dVal);
    return;
	}
	case eTinyWStr:
	case eWStr:
	{
		double dVal;
		const wchar_t * buf = getWStringPtr();
		swscanf(buf, L"%lE", &dVal);
		ret->assignDouble(dVal);
    return;
	}
	case eDec:
	{
		double dVal;
		HRESULT hr = VarR8FromDec((LPDECIMAL)&getDec(), &dVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDouble(dVal);
    return;
	}
	case eDate:
	{
		double dVal;
		HRESULT hr = VarR8FromDate(getDatetime(), &dVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDouble(dVal);
    return;
	}
	case eTime:
	{
		ret->assignDouble((double)getTime());
    return;
	}
	case eEnum:
	{
		ret->assignDouble((double)getEnum());
    return;
	}
	case eNull:
	{
		ret->assignNull();
    return;
	}
	case eLongLong:
	{
    ret->assignDouble((double) getLongLong());
    return;
  }
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}

void RuntimeValue::castToString(RuntimeValue * ret) const 
{
	char buf[64];
	switch(mType)
	{
	case eLong:
	{
		sprintf(buf, "%d", getLong());
		ret->assignString(buf);
    return;
	}
	case eBool:
	{
		ret->assignString(getBool() ? "true" : "false");
    return;
	}
	case eDouble:
	{
		sprintf(buf, "%E", getDouble());
		ret->assignString(buf);
    return;
	}
	case eTinyStr:
	case eStr:
	{
		ret->assignString(getStringPtr());
    return;
	}
	case eTinyWStr:
	case eWStr:
	{
		string utf;
    ::WideStringToUTF8(getWStringPtr(), utf);
    ret->assignString(utf);
    return;
	}
	case eDec:
	{
		BSTR bstrVal;
		LPDECIMAL decPtr = (LPDECIMAL)&getDec();
		HRESULT hr = VarBstrFromDec(decPtr, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		// Use a _bstr_t to delete the BSTR
		_bstr_t bstrtVal(bstrVal, false);
		ret->assignString((const char *)bstrtVal);
    return;
	}
	case eDate:
	{
		BSTR bstrVal;
		HRESULT hr = VarBstrFromDate(getDatetime(), LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		// Use a _bstr_t to delete the BSTR
		_bstr_t bstrtVal(bstrVal);
		ret->assignString((const char *)bstrtVal);
    return;
	}
	case eTime:
	{
    std::string strTime;
    ::MTFormatTime(getTime(), strTime);
		ret->assignString(strTime);
    return;
	}
	case eEnum:
	{
		try {
			MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig(MTPROGID_ENUM_CONFIG);
			try {
				_bstr_t bstrVal = aEnumConfig->GetEnumeratorByID(getEnum());
				ret->assignString((const char *)bstrVal);
        return;
			} catch (_com_error e2) {
				char buf [256];
				sprintf(buf, "Failed to find enumerator for enum id = %d", getEnum());
				throw MTSQLRuntimeErrorException(buf);
			}
		} catch (_com_error e) {
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Error Creating MTEnumConfig object for CAST");
		}
	}
	case eNull:
	{
		ret->assignNull();
    return;
	}
	case eLongLong:
	{
		sprintf(buf, "%I64d", getLongLong());
		ret->assignString(buf);
    return;
  }
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}

void RuntimeValue::castToWString(RuntimeValue * ret) const 
{
	wchar_t buf[64];
	switch(mType)
	{
	case eLong:
	{
		swprintf(buf, L"%d", getLong());
		ret->assignWString(buf);
    return;
	}
	case eBool:
	{
		ret->assignWString(getBool() ? L"true" : L"false");
    return;
	}
	case eDouble:
	{
		swprintf(buf, L"%E", getDouble());
		ret->assignWString(buf);
    return;
	}
	case eTinyStr:
	case eStr:
	{
		wstring str;
    ::ASCIIToWide(str, getStringPtr());
    ret->assignWString(str.c_str());
    return;
	}
	case eTinyWStr:
	case eWStr:
	{
		ret->assignWString(getWStringPtr());
    return;
	}
	case eDec:
	{
		BSTR bstrVal;
		LPDECIMAL decPtr = (LPDECIMAL)&getDec();
		HRESULT hr = VarBstrFromDec(decPtr, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		// Use a _bstr_t to delete the BSTR
		_bstr_t bstrtVal(bstrVal, false);
		ret->assignWString((const wchar_t *)bstrtVal);
    return;
	}
	case eDate:
	{
		BSTR bstrVal;
		HRESULT hr = VarBstrFromDate(getDatetime(), LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		// Use a _bstr_t to delete the BSTR
		_bstr_t bstrtVal(bstrVal);
		ret->assignWString((const wchar_t *)bstrtVal);
    return;
	}
	case eTime:
	{
    std::string strTime;
    ::MTFormatTime(getTime(), strTime);
    wstring wstr;
    ASCIIToWide(wstr, strTime);
		ret->assignWString(wstr);
    return;
	}
	case eEnum:
	{
		try {
			MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig(MTPROGID_ENUM_CONFIG);
			try {
				_bstr_t bstrVal = aEnumConfig->GetEnumeratorByID(getEnum());
				ret->assignWString((const wchar_t *)bstrVal);
        return;
			} catch (_com_error e2) {
				char buf [256];
				sprintf(buf, "Failed to find enumerator for enum id = %d", getEnum());
				throw MTSQLRuntimeErrorException(buf);
			}
		} catch (_com_error e) {
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Error Creating MTEnumConfig object for CAST");
		}
	}
	case eNull:
	{
		ret->assignNull();
    return;
	}
	case eLongLong:
	{
		swprintf(buf, L"%I64d", getLongLong());
		ret->assignWString(buf);
    return;
	}
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}

void RuntimeValue::castToDec(RuntimeValue * ret) const 
{
	DECIMAL decVal;
	switch(mType)
	{
	case eLong:
	{
		HRESULT hr = VarDecFromI4(getLong(), &decVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDec(&decVal);
    return;
	}
	case eBool:
	{
		HRESULT hr = VarDecFromI4(getBool() ? 1L : 0L, &decVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDec(&decVal);
    return;
	}
	case eDouble:
	{
		HRESULT hr = VarDecFromR8(getDouble(), &decVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDec(&decVal);
    return;
	}
	case eTinyStr:
	case eStr:
	{
		_bstr_t bStr(getStringPtr());
		HRESULT hr = VarDecFromStr(bStr, LOCALE_SYSTEM_DEFAULT, 0, &decVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDec(&decVal);
    return;
	}
	case eTinyWStr:
	case eWStr:
	{
		_bstr_t bStr(getWStringPtr());
		HRESULT hr = VarDecFromStr(bStr, LOCALE_SYSTEM_DEFAULT, 0, &decVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDec(&decVal);
    return;
	}
	case eDec:
	{
		ret->assignDec(getDecPtr());
    return;
	}
	case eDate:
	{
		HRESULT hr = VarDecFromDate(getDatetime(), &decVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDec(&decVal);
    return;
	}
	case eTime:
	{
		HRESULT hr = VarDecFromI4(getTime(), &decVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDec(&decVal);
    return;
	}
	case eEnum:
	{
		HRESULT hr = VarDecFromI4(getEnum(), &decVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDec(&decVal);
    return;
	}
	case eNull:
	{
		ret->assignNull();
    return;
	}
	case eLongLong:
	{
		HRESULT hr = VarDecFromI4((long) getLongLong(), &decVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDec(&decVal);
    return;
	}
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}

void RuntimeValue::castToBool(RuntimeValue * ret) const 
{
	switch(mType)
	{
	case eLong:
	{
		ret->assignBool(getLong() != 0L);
    return;
	}
	case eBool:
	{
		ret->assignBool(getBool());
    return;
	}
	case eDouble:
	{
		ret->assignBool(getDouble() != 0);
    return;
	}
	case eTinyStr:
	case eStr:
	{
		if (0 == stricmp(getStringPtr(), "true")) 
      ret->assignBool(true);
		else if (0 == stricmp(getStringPtr(), "false"))
      ret->assignBool(false);
    else
      throw MTSQLRuntimeErrorException((boost::format("Cannot convert string value '%1%' to BOOLEAN") % getStringPtr()).str());
    return;
	}
	case eTinyWStr:
	case eWStr:
	{
		if (0 == wcsicmp(getWStringPtr(), L"true"))
      ret->assignBool(true);
		else if (0 == wcsicmp(getWStringPtr(), L"false"))
      ret->assignBool(false);
		else 
      throw MTSQLRuntimeErrorException((boost::format("Cannot convert string value N'%1%' to BOOLEAN") % castToString().getStringPtr()).str());
    return;
	}
	case eDec:
	{
		DECIMAL zero;
		memset(&zero, 0, sizeof(DECIMAL));
		ret->assignBool(VARCMP_EQ != VarDecCmp((LPDECIMAL)&getDec(), &zero));
    return;
	}
	case eDate:
	{
		VARIANT_BOOL boolVal;
		HRESULT hr = VarBoolFromDate(getDatetime(), &boolVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignBool(boolVal==VARIANT_TRUE ? true : false);
    return;
	}
	case eTime:
	{
		ret->assignBool(getTime() != 0L);
    return;
	}
	case eEnum:
	{
		ret->assignBool(getEnum() != 0L);
    return;
	}
	case eNull:
	{
		ret->assignNull();
    return;
	}
	case eLongLong:
	{
		ret->assignBool(getLongLong() != 0LL);
    return;
	}
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}
}

void RuntimeValue::castToDatetime(RuntimeValue * ret) const 
{
	DATE dateVal;
	switch(mType)
	{
	case eLong:
	{
		HRESULT hr = VarDateFromI4(getLong(), &dateVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDatetime(dateVal);
    return;
	}
	case eBool:
	{
		HRESULT hr = VarDateFromI4(getBool() ? 1L : 0L, &dateVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDatetime(dateVal);
    return;
	}
	case eDouble:
	{
		HRESULT hr = VarDateFromR8(getDouble(), &dateVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDatetime(dateVal);
    return;
	}
	case eTinyStr:
	case eStr:
	{
		_bstr_t bStr(getStringPtr());
		HRESULT hr = VarDateFromStr(bStr, LOCALE_SYSTEM_DEFAULT, 0, &dateVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDatetime(dateVal);
    return;
	}
	case eTinyWStr:
	case eWStr:
	{
		_bstr_t bStr(getWStringPtr());
		HRESULT hr = VarDateFromStr(bStr, LOCALE_SYSTEM_DEFAULT, 0, &dateVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDatetime(dateVal);
    return;
	}
	case eDec:
	{
		HRESULT hr = VarDateFromDec((LPDECIMAL)&getDec(), &dateVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDatetime(dateVal);
    return;
	}
	case eDate:
	{
		ret->assignDatetime(getDatetime());
    return;
	}
	case eTime:
	{
		DATE dateVal;
		//NOTE: OleDateFromTimet returns GMT time
		//is this OK?
		OleDateFromTimet(&dateVal, getTime());
		ret->assignDatetime(dateVal);
    return;
	}
	case eEnum:
	{
		HRESULT hr = VarDateFromI4(getEnum(), &dateVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDatetime(dateVal);
    return;
	}
	case eNull:
	{
		ret->assignNull();
    return;
	}
	case eLongLong:
	{
		HRESULT hr = VarDateFromI4((long)getLongLong(), &dateVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignDatetime(dateVal);
    return;
	}
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}

void RuntimeValue::castToTime(RuntimeValue * ret) const 
{
	switch(mType)
	{
	case eLong:
	{
		ret->assignTime(getLong());
    return;
	}
	case eBool:
	{
		ret->assignTime(getBool() ? 1L : 0L);
    return;
	}
	case eDouble:
	{
		ret->assignTime((long)getDouble());
    return;
	}
	case eTinyStr:
	case eStr:
	{
		long tempTime = ::MTConvertTime(getStringPtr());
		ret->assignTime(tempTime);
    return;
	}
	case eTinyWStr:
	case eWStr:
	{
    string utf8;
    WideStringToUTF8(getWStringPtr(), utf8);
		long tempTime =  ::MTConvertTime(utf8);
		ret->assignTime(tempTime);
    return;
	}
	case eDec:
	{
		long lVal;
		HRESULT hr = VarI4FromDate(getDatetime(), &lVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignTime(lVal);
    return;
	}
	case eDate:
	{
    // DATE representation is that the fractional part represents
    // time as the fractional number of days.
    static const long secondsInDay(60*60*24);
    
    long tempTime = (long)(getDatetime() * secondsInDay + 0.5);
		ret->assignTime(tempTime);
    return;
	}
	case eTime:
	{
		ret->assignTime(getTime());
    return;
	}
	case eEnum:
	{
		ret->assignTime(getEnum());
    return;
	}
	case eNull:
	{
		ret->assignNull();
    return;
	}
	case eLongLong:
	{
		ret->assignTime((long) getLongLong());
    return;
	}
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}

void RuntimeValue::castToLongLong(RuntimeValue * ret) const 
{
	switch(mType)
	{
	case eLong:
		ret->assignLongLong((__int64) getLong());
    return;
	case eBool:
		ret->assignLongLong(getBool() ? 1LL : 0LL);
    return;
	case eDouble:
		ret->assignLongLong((__int64)getDouble());
    return;
	case eTinyStr:
	case eStr:
	{
		__int64 lVal;
		sscanf(getStringPtr(), "%I64d", &lVal);
		ret->assignLongLong(lVal);
    return;
	}
	case eTinyWStr:
	case eWStr:
	{
		__int64 lVal;
		swscanf(getWStringPtr(), L"%I64d", &lVal);
		ret->assignLongLong(lVal);
    return;
	}
	case eDec:
	{
		__int64 lVal;
		HRESULT hr = VarI8FromDec((LPDECIMAL)&getDec(), &lVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignLongLong(lVal);
    return;
	}
	case eDate:
	{
		__int64 lVal;
		HRESULT hr = VarI8FromDate(getDatetime(), &lVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		ret->assignLongLong((__int64)lVal);
    return;
	}
	case eTime:
	{
		ret->assignLongLong((__int64)getTime());
    return;
	}
	case eEnum:
	{
		ret->assignLongLong((__int64)getEnum());
    return;
	}
	case eNull:
	{
		ret->assignNull();
    return;
	}
	case eLongLong:
		ret->assignLongLong(getLongLong());
    return;
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}

void RuntimeValue::castToBinary(RuntimeValue * ret) const 
{
  unsigned char buf[MAX_TINY_BIN_LEN];
	memset(&buf[0], 0, MAX_TINY_BIN_LEN);

	switch(mType)
	{
	case eLong:
  {
    long val = getLong();
    buf[MAX_TINY_BIN_LEN - 4] = ((unsigned char *) &val)[3];
    buf[MAX_TINY_BIN_LEN - 3] = ((unsigned char *) &val)[2];
    buf[MAX_TINY_BIN_LEN - 2] = ((unsigned char *) &val)[1];
    buf[MAX_TINY_BIN_LEN - 1] = ((unsigned char *) &val)[0];
		ret->assignBinary(&buf[0], &buf[0] + MAX_TINY_BIN_LEN);
    return;
  }
	case eBool:
  {
    buf[MAX_TINY_BIN_LEN - 1] = getBool() ? 0x01 : 0x00;
		ret->assignBinary(&buf[0], &buf[0] + MAX_TINY_BIN_LEN);
    return;
  }
	case eDouble:
  {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value conversion");
  }
	case eTinyStr:
	case eStr:
	{
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value conversion");
	}
	case eTinyWStr:
	case eWStr:
	{
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value conversion");
	}
	case eDec:
	{
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value conversion");
	}
	case eDate:
	{
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value conversion");
	}
	case eTime:
	{
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value conversion");
	}
	case eEnum:
	{
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value conversion");
	}
	case eNull:
	{
		ret->assignNull();
    return;
	}
	case eLongLong:
  {
    __int64 val = getLongLong();
    buf[MAX_TINY_BIN_LEN - 8] = ((unsigned char *) &val)[7];
    buf[MAX_TINY_BIN_LEN - 7] = ((unsigned char *) &val)[6];
    buf[MAX_TINY_BIN_LEN - 6] = ((unsigned char *) &val)[5];
    buf[MAX_TINY_BIN_LEN - 5] = ((unsigned char *) &val)[4];
    buf[MAX_TINY_BIN_LEN - 4] = ((unsigned char *) &val)[3];
    buf[MAX_TINY_BIN_LEN - 3] = ((unsigned char *) &val)[2];
    buf[MAX_TINY_BIN_LEN - 2] = ((unsigned char *) &val)[1];
    buf[MAX_TINY_BIN_LEN - 1] = ((unsigned char *) &val)[0];
		ret->assignBinary(&buf[0], &buf[0] + MAX_TINY_BIN_LEN);
    return;
  }
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}


class NameIDImpl
{
public:
  NAMEIDLib::IMTNameIDPtr NameID;
  NameIDImpl()
    :
    NameID(__uuidof(NAMEIDLib::MTNameID))
  {
  }
};

class EnumConfigImpl
{
public:
  MTENUMCONFIGLib::IEnumConfigPtr EnumConfig;
  EnumConfigImpl()
    :
    EnumConfig(__uuidof(MTENUMCONFIGLib::EnumConfig))
  {
  }
};

NameIDProxy::NameIDProxy()
  :
  mImpl(new NameIDImpl()),
  mEnumConfigImpl(NULL)
{
}

NameIDProxy::~NameIDProxy()
{
  delete mImpl;
  delete mEnumConfigImpl;
}

NameIDImpl* NameIDProxy::GetNameID()
{
  return mImpl;
}

EnumConfigImpl* NameIDProxy::GetEnumConfig()
{
  // EnumConfig is quite expensive to create (and not too frequently used) so we do a lazy initialization.
  if (mEnumConfigImpl == NULL)
    mEnumConfigImpl = new EnumConfigImpl();
  return mEnumConfigImpl;
}

void RuntimeValueCast::ToEnum(RuntimeValue * target, const RuntimeValue * source,  NameIDImpl * nameID )
{
	switch(source->getType())
	{
	case RuntimeValue::eLong:
	{
		target->assignEnum(source->getLong());
    return;
	}
	case RuntimeValue::eBool:
	{
		target->assignEnum(source->getBool() ? 1L : 0L);
    return;
	}
	case RuntimeValue::eDouble:
	{
		target->assignEnum((long)source->getDouble());
    return;
	}
	case RuntimeValue::eTinyStr:
	case RuntimeValue::eStr:
	{
		try {
			_bstr_t FQN(source->getStringPtr());
			long id = (long) nameID->NameID->GetNameID((const wchar_t *)FQN);
			target->assignEnum(id);
      return;
		} catch (_com_error e) {
        throw MTSQLInternalErrorException(__FILE__, __LINE__, "Error in CAST of string to ENUM");
		}
	}
	case RuntimeValue::eTinyWStr:
	case RuntimeValue::eWStr:
	{
		try {
			long id = (long) nameID->NameID->GetNameID(source->getWStringPtr());
			target->assignEnum(id);
      return;
		} catch (_com_error e) {
        throw MTSQLInternalErrorException(__FILE__, __LINE__, "Error in CAST of string to ENUM");
		}
	}
	case RuntimeValue::eDec:
	{
		long lVal;
		HRESULT hr = VarI4FromDec(const_cast<DECIMAL*>(source->getDecPtr()), &lVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		target->assignEnum(lVal);
    return;
	}
	case RuntimeValue::eDate:
	{
		long lVal;
		HRESULT hr = VarI4FromDate(source->getDatetime(), &lVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		target->assignEnum(lVal);
    return;
	}
	case RuntimeValue::eTime:
	{
		target->assignEnum(source->getTime());
    return;
	}
	case RuntimeValue::eEnum:
	{
		target->assignEnum(source->getEnum());
    return;
	}
	case RuntimeValue::eNull:
	{
		target->assignNull();
    return;
	}
	case RuntimeValue::eLongLong:
	{
		target->assignEnum((long) source->getLongLong());
    return;
	}
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}

void RuntimeValueCast::ToString(RuntimeValue * target, const RuntimeValue * source, EnumConfigImpl * enumConfig)
{
	char buf[64];
	switch(source->mType)
	{
	case RuntimeValue::eLong:
	{
		sprintf(buf, "%d", source->getLong());
		target->assignString(buf);
    return;
	}
	case RuntimeValue::eBool:
	{
		target->assignString(source->getBool() ? "true" : "false");
    return;
	}
	case RuntimeValue::eDouble:
	{
		sprintf(buf, "%E", source->getDouble());
		target->assignString(buf);
    return;
	}
	case RuntimeValue::eTinyStr:
	case RuntimeValue::eStr:
	{
		target->assignString(source->getStringPtr());
    return;
	}
	case RuntimeValue::eTinyWStr:
	case RuntimeValue::eWStr:
	{
		string utf;
    ::WideStringToUTF8(source->getWStringPtr(), utf);
    target->assignString(utf);
    return;
	}
	case RuntimeValue::eDec:
	{
		BSTR bstrVal;
		LPDECIMAL decPtr = (LPDECIMAL)&source->getDec();
		HRESULT hr = VarBstrFromDec(decPtr, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		// Use a _bstr_t to delete the BSTR
		_bstr_t bstrtVal(bstrVal, false);
		target->assignString((const char *)bstrtVal);
    return;
	}
	case RuntimeValue::eDate:
	{
		BSTR bstrVal;
		HRESULT hr = VarBstrFromDate(source->getDatetime(), LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		// Use a _bstr_t to delete the BSTR
		_bstr_t bstrtVal(bstrVal);
		target->assignString((const char *)bstrtVal);
    return;
	}
	case RuntimeValue::eTime:
	{
    std::string strTime;
    ::MTFormatTime(source->getTime(), strTime);
		target->assignString(strTime);
    return;
	}
	case RuntimeValue::eEnum:
	{
		try {
			try {
				_bstr_t bstrVal = enumConfig->EnumConfig->GetEnumeratorByID(source->getEnum());
				target->assignString((const char *)bstrVal);
        return;
			} catch (_com_error e2) {
				char buf [256];
				sprintf(buf, "Failed to find enumerator for enum id = %d", source->getEnum());
				throw MTSQLRuntimeErrorException(buf);
			}
		} catch (_com_error e) {
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Error Creating MTEnumConfig object for CAST");
		}
	}
	case RuntimeValue::eNull:
	{
		target->assignNull();
    return;
	}
	case RuntimeValue::eLongLong:
	{
		sprintf(buf, "%I64d", source->getLongLong());
		target->assignString(buf);
    return;
  }
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}

void RuntimeValueCast::ToWString(RuntimeValue * target, const RuntimeValue * source, EnumConfigImpl * enumConfig)
{
	wchar_t buf[64];
	switch(source->mType)
	{
	case RuntimeValue::eLong:
	{
		swprintf(buf, L"%d", source->getLong());
		target->assignWString(buf);
    return;
	}
	case RuntimeValue::eBool:
	{
		target->assignWString(source->getBool() ? L"true" : L"false");
    return;
	}
	case RuntimeValue::eDouble:
	{
		swprintf(buf, L"%E", source->getDouble());
		target->assignWString(buf);
    return;
	}
	case RuntimeValue::eTinyStr:
	case RuntimeValue::eStr:
	{
		wstring str;
    ::ASCIIToWide(str, source->getStringPtr());
    target->assignWString(str.c_str());
    return;
	}
	case RuntimeValue::eTinyWStr:
	case RuntimeValue::eWStr:
	{
		target->assignWString(source->getWStringPtr());
    return;
	}
	case RuntimeValue::eDec:
	{
		BSTR bstrVal;
		LPDECIMAL decPtr = (LPDECIMAL)&source->getDec();
		HRESULT hr = VarBstrFromDec(decPtr, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		// Use a _bstr_t to delete the BSTR
		_bstr_t bstrtVal(bstrVal, false);
		target->assignWString((const wchar_t *)bstrtVal);
    return;
	}
	case RuntimeValue::eDate:
	{
		BSTR bstrVal;
		HRESULT hr = VarBstrFromDate(source->getDatetime(), LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
		if(FAILED(hr)) throw MTSQLComException(hr);
		// Use a _bstr_t to delete the BSTR
		_bstr_t bstrtVal(bstrVal);
		target->assignWString((const wchar_t *)bstrtVal);
    return;
	}
	case RuntimeValue::eTime:
	{
    std::string strTime;
    ::MTFormatTime(source->getTime(), strTime);
    wstring wstr;
    ASCIIToWide(wstr, strTime);
		target->assignWString(wstr);
    return;
	}
	case RuntimeValue::eEnum:
	{
		try {
			try {
				_bstr_t bstrVal = enumConfig->EnumConfig->GetEnumeratorByID(source->getEnum());
				target->assignWString((const wchar_t *)bstrVal);
        return;
			} catch (_com_error e2) {
				char buf [256];
				sprintf(buf, "Failed to find enumerator for enum id = %d", source->getEnum());
				throw MTSQLRuntimeErrorException(buf);
			}
		} catch (_com_error e) {
			throw MTSQLInternalErrorException(__FILE__, __LINE__, "Error Creating MTEnumConfig object for CAST");
		}
	}
	case RuntimeValue::eNull:
	{
		target->assignNull();
    return;
	}
	case RuntimeValue::eLongLong:
	{
		swprintf(buf, L"%I64d", source->getLongLong());
		target->assignWString(buf);
    return;
	}
	case RuntimeValue::eTinyBinary:
	{
    static const wchar_t hexDigits[16] = {L'0', L'1', L'2', L'3', L'4', L'5', L'6', L'7', L'8', L'9', L'A', L'B', L'C', L'D', L'E', L'F'};

    const unsigned char * val = source->getBinaryPtr();

    wchar_t * bufit = buf;
    *bufit++ = L'0';
    *bufit++ = L'x';
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    *bufit++ = hexDigits[(*val & 0xF0)>>4];
    *bufit++ = hexDigits[(*val++ & 0x0F)];
    // Null terminate
    *bufit++ = 0;
		target->assignWString(buf);
    return;
	}
	default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid Runtime Value type");
	}			
}
