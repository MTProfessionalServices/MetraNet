/**************************************************************************
 * @doc XMLCONFIG
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 * $Header$
 ***************************************************************************/

#include <metra.h>
#include "xmlconfig.h"
#ifdef WIN32
#include <search.h>
#endif

#ifdef UNIX
#include <errno.h>
#endif

#include "MTUtil.h"
#include "MTTypeConvert.h"

#ifdef AUTO_ENUM_CONVERSION
#import <MTNameIDLib.tlb>
#import "MTEnumConfigLib.tlb"
#include <mtprogids.h>
#endif // AUTO_ENUM_CONVERSION

#include <stdutils.h>

#ifdef WIN32
#include "mtglobal_msg.h"
#else // WIN32

//
// MessageId: CORE_ERR_CONFIGURATION_PARSE_ERROR
//
// MessageText:
//
//  Parse error while reading a configuration file.
//
#define CORE_ERR_CONFIGURATION_PARSE_ERROR ((DWORD)0xE1100004L)

#endif // WIN32


#ifdef UNIX
#include <ctype.h>
#include <wchar.h>
#endif

#if 0
#ifdef WIN32
extern int errno;
#endif // WIN32
#endif

#include <algorithm>
using std::find_if;

#ifdef WIN32
template void destroyPtr(XMLConfigObject *);
#endif

/*
 * UNIX TODO:
 *
 * use case insensitive name comparisons.
 * generate mtglobal_msg.h to get the correct definition of error codes.
 * deal with enum conversion in a better way.
 */



/*************************************************** ValType ***/

// @cmember return a type from the Type enum.  If apType is NULL, return DEFAULT.
struct TypeKeyword
{
	const wchar_t * name;
	ValType::Type type;
};

static int TypeKeyCompare(const void *arg1, const void *arg2)
{
	TypeKeyword * typekey1 = (TypeKeyword *) arg1;
	TypeKeyword * typekey2 = (TypeKeyword *) arg2;
	// case insensitive
#ifdef WIN32
	return wcsicmp(typekey1->name, typekey2->name);
#else
	return wcscmp(typekey1->name, typekey2->name);
#endif // WIN32
}

ValType::Type ValType::GetType(const wchar_t * apType)
{
	if (!apType)
		return TYPE_DEFAULT;

  // Since we are using binary search, the following must be in 
  // increasing sort order.
	static TypeKeyword keywords[] =
	{
#ifdef WIN32
		{ L"BIGINT",				ValType::TYPE_BIGINTEGER		},
#endif
		{ L"BOOL",					ValType::TYPE_BOOLEAN		},
		{ L"BOOLEAN",				ValType::TYPE_BOOLEAN		},
#ifdef AUTO_ENUM_CONVERSION
		{ L"CODE",					ValType::TYPE_ID			},
#endif // AUTO_ENUM_CONVERSION
		{ L"DATETIME",			ValType::TYPE_DATETIME	},
#ifdef WIN32
		{ L"DECIMAL",				ValType::TYPE_DECIMAL		},
#endif
		{ L"DOUBLE",				ValType::TYPE_DOUBLE		},
#ifdef AUTO_ENUM_CONVERSION
		{ L"ENUM",					ValType::TYPE_ENUM			},
		{ L"ID",						ValType::TYPE_ID			},
#endif // AUTO_ENUM_CONVERSION
		{ L"INT",						ValType::TYPE_INTEGER		},
		{ L"INTEGER",				ValType::TYPE_INTEGER		},
		{ L"OPAQUE",				ValType::TYPE_OPAQUE		},
		{ L"STRING",				ValType::TYPE_STRING		},
		{ L"TIME",					ValType::TYPE_TIME			},
 	};

	TypeKeyword key = { apType, TYPE_UNKNOWN };

	TypeKeyword * result = (TypeKeyword *) bsearch((char *) &key, (char *) keywords,
		sizeof(keywords) / sizeof(keywords[0]),
		sizeof(keywords[0]),
		TypeKeyCompare);

	if (result)
		return result->type;
	else
		return TYPE_UNKNOWN;
}

/******************************************* XMLConfigObject ***/

XMLConfigObject::XMLConfigObject() : mpName(NULL) , mValueMap(NULL)
{ }

XMLConfigObject::~XMLConfigObject()
{
	if (mpName)
	{
		delete [] mpName;
		mpName = NULL;
	}
}

XMLConfigObject::XMLConfigObject(const char * apName)
	: mpName(NULL), mValueMap(NULL)
{
	SetName(apName);
}


#if 0
void XMLConfigObject::PutMap(XMLNameValueMap& aMap)
{
	mValueMap = NULL;
	mValueMap = new XMLNameValueMapDictionary;
	(*mValueMap) = (*aMap);
}
#endif


XMLConfigObject & XMLConfigObject::operator =(const XMLConfigObject & arOther)
{
	XMLUserObject::operator =(arOther);
	SetName(arOther.GetName());
	mValueMap = arOther.mValueMap;
	return *this;
}


const char * XMLConfigObject::GetName() const
{
	ASSERT(mpName);
	return mpName;
}

void XMLConfigObject::SetName(const char * apName)
{
	if (mpName)
	{
		delete [] mpName;
		mpName = NULL;
	}

	mpName = new char[strlen(apName) + 1];
	strcpy(mpName, apName);
}


void XMLConfigObject::ProcessOpenTag(MT_MD5_CTX* apMD5Context, 
																		 const char* apName,
																		 XMLNameValueMap& apAttributes)
{
	string stringValue;

	MT_MD5_Update(apMD5Context, 
								reinterpret_cast<unsigned char*>(const_cast<char*>(apName)), 
								strlen(apName));

	if ((&apAttributes))
	{
		// TODO: make sure this outputs attributes in the correct order
		// HACK: casting away const
		XMLNameValueMapDictionary::const_iterator it;
		for (it = apAttributes->begin(); it != apAttributes->end(); it++)
		{
			// TODO: this iterator is not very efficient - it returns the keys by value
			const XMLString & name = it->first;

			PreProcessCharacterData(stringValue, name);

			MT_MD5_Update(apMD5Context, 
										reinterpret_cast<unsigned char*>(const_cast<char*>(stringValue.c_str())), 
										stringValue.length());

			const XMLString & value = it->second;

			PreProcessCharacterData(stringValue, value);

			MT_MD5_Update(apMD5Context, 
										reinterpret_cast<unsigned char*>(const_cast<char*>(stringValue.c_str())), 
										stringValue.length());
			
		}
	}

}


void XMLConfigObject::ProcessOpenTag(MT_MD5_CTX* apMD5Context, 
																		 const char* apName)
{
	// Open Tag
	MT_MD5_Update(apMD5Context, 
								reinterpret_cast<unsigned char*>(const_cast<char*>(apName)), 
								strlen(apName));

}


void XMLConfigObject::ProcessClosingTag(MT_MD5_CTX* apMD5Context, 
																				const char* apName)
{
	// Closing Tag
	MT_MD5_Update(apMD5Context, 
								reinterpret_cast<unsigned char*>(const_cast<char*>(apName)), 
								strlen(apName));

}


void XMLConfigObject::PreProcessCharacterData(string& value, 
																					 const XMLString & arString)
{

	XMLString escaped;

	if (EscapeXMLChars(escaped, arString.c_str(), FALSE))
		XMLStringToUtf8(value, escaped);
	else
		XMLStringToUtf8(value, arString.c_str());

}


/****************************************** XMLConfigNameVal ***/

const int XMLConfigNameVal::msTypeId = XMLObjectFactory::GetUserObjectId();

XMLConfigNameVal::XMLConfigNameVal()
	: mType(ValType::TYPE_UNKNOWN)
{
  mEmp.mEnumTypeVal = 0;
  mEmp.mpEnumTypeStr = NULL;
}

DllExportXmlConfig
XMLConfigNameVal::XMLConfigNameVal(const XMLConfigNameVal & arOther) 
	: mType(ValType::TYPE_UNKNOWN)
{
  mEmp.mEnumTypeVal = 0;
  mEmp.mpEnumTypeStr = NULL;

	*this = arOther;
}


XMLConfigNameVal::~XMLConfigNameVal()
{
	Clear();
}

XMLConfigNameVal & XMLConfigNameVal::operator =(const XMLConfigNameVal & arOther)
{
	XMLConfigObject::operator =(arOther);

	switch (arOther.GetPropType())
	{
		case ValType::TYPE_INTEGER:
			InitInt(arOther.GetInt());
			break;
		case ValType::TYPE_DOUBLE:
			InitDouble(arOther.GetDouble());
			break;
#ifdef WIN32
		case ValType::TYPE_DECIMAL:
			InitDecimal(arOther.GetDecimal());
			break;
		case ValType::TYPE_BIGINTEGER:
			InitBigInt(arOther.GetBigInt());
			break;
#endif
		case ValType::TYPE_DEFAULT:
			// TODO: I don't this this case should be called
			ASSERT(0);
			InitString(arOther.GetString().c_str());
			mType = ValType::TYPE_DEFAULT;
			break;
		case ValType::TYPE_STRING:
			InitString(arOther.GetString().c_str());
			break;										// no conversion (default = BSTR)
		case ValType::TYPE_OPAQUE:
			// TODO: I don't this this case should be called
			ASSERT(0);
			InitString(arOther.GetString().c_str());
			mType = ValType::TYPE_OPAQUE;
			break;
		case ValType::TYPE_DATETIME:
			InitDateTime(arOther.GetDateTime());
			break;
		case ValType::TYPE_BOOLEAN:
			InitBool(arOther.GetBool());
			break;
		case ValType::TYPE_TIME:
			InitTime(arOther.GetTime());
			break;
		case ValType::TYPE_ENUM:
			InitEnum(arOther);
			break;
		case ValType::TYPE_ID:
			InitID(arOther.GetID().c_str());
			break;
		case ValType::TYPE_UNKNOWN:
		default:
			ASSERT(0);
	}

	return *this;
}


ValType::Type XMLConfigNameVal::GetPropType() const
{ return mType; }

void XMLConfigNameVal::PutPropType(ValType::Type aType) { mType = aType; }


XMLConfigNameVal * XMLConfigNameVal::Create(const char * apName,
																						const wstring & arValue,
																						XMLNameValueMap& aValueMap,
																						BOOL aAutoConvertEnums /* = FALSE */)
{
#ifndef WIN32
	ASSERT(!aAutoConvertEnums);
#endif // WIN32

	// generate the new object and return it
	XMLConfigNameVal * nameVal = new XMLConfigNameVal;
	if (!nameVal->Init(apName, arValue, aValueMap, aAutoConvertEnums))
	{
		delete nameVal;
		return NULL;
	}
	return nameVal;
}

BOOL XMLConfigNameVal::Init(const char * apName,
														const wstring & arValue,
														XMLNameValueMap& aValueMap,
														BOOL aAutoConvertEnums /* = FALSE */)
{
#ifndef WIN32
	ASSERT(!aAutoConvertEnums);
#endif // WIN32

	const wchar_t * apType=NULL;
	XMLString val, ensp, entp;
	
	// NOTE: this really isn't efficient
	if((&aValueMap) != NULL) {

		static XMLString PTypeString(L"ptype");

		XMLNameValueMapDictionary::iterator it;
		it = aValueMap->find(PTypeString);
		if (it != aValueMap->end())
			apType = it->second.c_str();

		it = aValueMap->find(L"enumspace");
		if (it != aValueMap->end())
			ensp = it->second;
		
		it = aValueMap->find(L"enumtype");
		if (it != aValueMap->end())
			entp = it->second;
		
		size_t aNumEntries = aValueMap->size();
		if((apType && aNumEntries > 1) || (!apType && aNumEntries > 0)) {
			mValueMap = aValueMap;
		}
	}

	SetName(apName);

	ValType::Type type = ValType::GetType(apType);

	BOOL conversionValid = FALSE;
	BOOL boolConverted;
	long timeConverted;
	time_t dateTimeConverted;
	long longConverted;
	int intConverted;
	double doubleConverted;
#ifdef WIN32
	MTDecimalVal decimalConverted;
  __int64 int64Converted;
#endif
	switch (type)
	{
	case ValType::TYPE_INTEGER:
		conversionValid = ConvertToInteger(arValue, &intConverted);
		if (!conversionValid)
			return FALSE;
		InitInt(intConverted);
		break;
	case ValType::TYPE_DOUBLE:
		conversionValid = ConvertToDouble(arValue, &doubleConverted);
		if (!conversionValid)
			return FALSE;
		InitDouble(doubleConverted);
		break;
#ifdef WIN32
	case ValType::TYPE_DECIMAL:
		conversionValid = ConvertToDecimal(arValue, &decimalConverted);
		if (!conversionValid)
			return FALSE;
		InitDecimal(decimalConverted);
		break;
	case ValType::TYPE_BIGINTEGER:
		conversionValid = ConvertToBigInteger(arValue, &int64Converted);
		if (!conversionValid)
			return FALSE;
		InitBigInt(int64Converted);
		break;
#endif
	case ValType::TYPE_DEFAULT:
		// default = string
		type = ValType::TYPE_STRING;
		InitString(arValue.c_str());
		break;
	case ValType::TYPE_STRING:
		InitString(arValue.c_str());
		break;										// no conversion (default = BSTR)
	case ValType::TYPE_OPAQUE:
		InitString(arValue.c_str());
		break;										// no conversion
	case ValType::TYPE_DATETIME:
		// NOTE: DATETIME values are stored as Unix time!
		// conversion to DATE type is to complicated and expensive
		conversionValid = ConvertToDateTime(arValue, &dateTimeConverted);
		if (!conversionValid)
			return FALSE;
		InitDateTime(dateTimeConverted);
		break;
	case ValType::TYPE_BOOLEAN:
		conversionValid = ConvertToBoolean(arValue, &boolConverted);
		if (!conversionValid)
			return FALSE;						// conversion failed
		InitBool(boolConverted);
		break;
	case ValType::TYPE_TIME:
		conversionValid = ConvertToTime(arValue, &timeConverted);
		if (!conversionValid)
			return FALSE;
		InitTime(timeConverted);
		break;
#ifdef AUTO_ENUM_CONVERSION
	case ValType::TYPE_ENUM:
		if (aAutoConvertEnums)
		{
			conversionValid = ConvertToEnum(arValue, ensp, entp, &longConverted);
			if (!conversionValid)
				return FALSE;
		
      // convert to int for backward compatibility
      if(ensp.empty() && entp.empty())
      {
			  type = ValType::TYPE_INTEGER;
			  InitInt(longConverted);
      }
			else
        InitEnum(arValue.c_str(),(int)longConverted);
			
			/*
			if(!ensp.empty() && !entp.empty())
			{
				mValueMap->erase(L"enumspace");
				mValueMap->erase(L"enumtype");
			}
			*/
		}
		else
		{
			//if enumspace and enumtype are missing change ptype to ID
			if(ensp.empty() && entp.empty())
				InitID(arValue.c_str());
			else
			// no auto conversion - leave it as an enum
			// type left as TYPE_ENUM
			InitEnum(arValue.c_str());
		}
		break;
	case ValType::TYPE_ID:
		if (aAutoConvertEnums)
		{
			conversionValid = ConvertToEnum(arValue, ensp, entp, &longConverted);
			if (!conversionValid)
				return FALSE;
			// from now on, it's just an integer
			type = ValType::TYPE_INTEGER;
			InitInt(longConverted);

			if(!ensp.empty() && !entp.empty())
			{
				XMLNameValueMapDictionary::iterator it;

				it = mValueMap->find(L"enumspace");
				if (it != mValueMap->end())
				{
					mValueMap->erase(it);
				}

				it = mValueMap->find(L"enumtype");
				if (it != mValueMap->end())
				{
					mValueMap->erase(it);
				}
			}
		}
		else
		{
			//if enumspace and enumtype are missing change ptype to ID
			if(ensp.empty() && entp.empty())
				InitID(arValue.c_str());
			else
				// no auto conversion - leave it as an enum
				// type left as TYPE_ENUM
				InitEnum(arValue.c_str());
		}
		break;
#endif // AUTO_ENUM_CONVERSION
	case ValType::TYPE_UNKNOWN:
	default:
		return FALSE;
	}

	return TRUE;
}


void XMLConfigNameVal::Clear()
{
	if (mType == ValType::TYPE_STRING
			|| mType == ValType::TYPE_OPAQUE
			|| mType == ValType::TYPE_ID)
	{
		ASSERT(mpStringVal);
		delete mpStringVal;
		mpStringVal = NULL;
	}
	else if(mType == ValType::TYPE_ENUM && mEmp.mpEnumTypeStr != NULL) {
		delete mEmp.mpEnumTypeStr;
	}
#ifdef WIN32
	else if (mType == ValType::TYPE_DECIMAL)
	{
		ASSERT(mpDecimalVal);
		delete mpDecimalVal;
		mpDecimalVal = NULL;
	}
#endif
	mType = ValType::TYPE_UNKNOWN;
	mEmp.mEnumTypeVal = 0;
	mEmp.mpEnumTypeStr = NULL;

}


void XMLConfigNameVal::InitBool(BOOL aBoolVal)
{
	Clear();
	mType = ValType::TYPE_BOOLEAN, mBoolVal = aBoolVal;
}

void XMLConfigNameVal::InitDateTime(time_t aDateTimeVal)
{
	Clear();
	mType = ValType::TYPE_DATETIME, mDateTimeVal = aDateTimeVal;
}

void XMLConfigNameVal::InitDouble(double aDoubleVal)
{
	Clear();
	mType = ValType::TYPE_DOUBLE, mDoubleVal = aDoubleVal;
}

#ifdef WIN32
void XMLConfigNameVal::InitDecimal(const MTDecimalVal & arDecimalVal)
{
	if (mType == ValType::TYPE_DECIMAL)
		*mpDecimalVal = arDecimalVal;
	else
	{
		mpDecimalVal = new MTDecimalVal(arDecimalVal);
		mType = ValType::TYPE_DECIMAL;
	}
}
void XMLConfigNameVal::InitBigInt(__int64 aIntegerVal)
{
	Clear();
	mType = ValType::TYPE_BIGINTEGER, mBigIntegerVal = aIntegerVal;
}

#endif

void XMLConfigNameVal::InitInt(int aIntegerVal)
{
	Clear();
	mType = ValType::TYPE_INTEGER, mIntegerVal = aIntegerVal;
}

void XMLConfigNameVal::InitTime(int aTimeVal)
{
	Clear();
	mType = ValType::TYPE_TIME, mTimeVal = aTimeVal;
}

void XMLConfigNameVal::InitString(const wchar_t * apStringVal)
{
	if (mType == ValType::TYPE_STRING)
		*mpStringVal = apStringVal;
	else
	{
		mpStringVal = new wstring(apStringVal);
		mType = ValType::TYPE_STRING;
	}
}

void XMLConfigNameVal::InitEnum(const wchar_t * apStringVal)
{
	Clear();
	mEmp.mpEnumTypeStr = new wstring(apStringVal);
	mEmp.mEnumTypeVal = -1;
	mType = ValType::TYPE_ENUM;
}

void XMLConfigNameVal::InitEnum(const XMLConfigNameVal & arOther)
{
	Clear();
	const wstring* str = arOther.GetEnumStr();
	if (str == NULL || str->empty())
	{
		InitEnum(arOther.GetEnum());
	}
	else
	{
		InitEnum(arOther.GetEnumStr()->data(), arOther.GetEnum());
	}
}

void XMLConfigNameVal::InitEnum(const int& aIntegerVal)
{
	Clear();
	mEmp.mEnumTypeVal = aIntegerVal;
	mEmp.mpEnumTypeStr = NULL;
	mType = ValType::TYPE_ENUM;
}


void XMLConfigNameVal::InitEnum(const wchar_t * apStringVal,const int& aIntegerVal)
{
	Clear();
	mEmp.mEnumTypeVal = aIntegerVal;
	mEmp.mpEnumTypeStr = new wstring(apStringVal);
	mType = ValType::TYPE_ENUM;
}


void XMLConfigNameVal::InitID(const wchar_t * apStringVal)
{
	Clear();
	mpStringVal = new wstring(apStringVal);
	mType = ValType::TYPE_ID;
}


BOOL XMLConfigNameVal::GetBool() const
{
	ASSERT(mType == ValType::TYPE_BOOLEAN);
	return mBoolVal;
}

time_t XMLConfigNameVal::GetDateTime() const
{
	ASSERT(mType == ValType::TYPE_DATETIME);
	return mDateTimeVal;
}

double XMLConfigNameVal::GetDouble() const
{
	ASSERT(mType == ValType::TYPE_DOUBLE);
	return mDoubleVal;
}

#ifdef WIN32
const MTDecimalVal & XMLConfigNameVal::GetDecimal() const
{
	ASSERT(mType == ValType::TYPE_DECIMAL);
	return *mpDecimalVal;
}

__int64 XMLConfigNameVal::GetBigInt() const
{
	ASSERT(mType == ValType::TYPE_BIGINTEGER);
	return mBigIntegerVal;
}

#endif
int XMLConfigNameVal::GetInt() const
{
	ASSERT(mType == ValType::TYPE_INTEGER);
	return mIntegerVal;
}

const wstring & XMLConfigNameVal::GetString() const
{
	ASSERT(mType == ValType::TYPE_STRING);
	ASSERT(mpStringVal);
	return *mpStringVal;
}

const int & XMLConfigNameVal::GetEnum() const
{
	ASSERT(mType == ValType::TYPE_ENUM);
	ASSERT(mEmp.mEnumTypeVal);
	return mEmp.mEnumTypeVal;
}

const wstring * XMLConfigNameVal::GetEnumStr() const
{
	ASSERT(mType == ValType::TYPE_ENUM);
	return mEmp.mpEnumTypeStr;
}

const wstring & XMLConfigNameVal::GetID() const
{
	ASSERT(mType == ValType::TYPE_ID);
	ASSERT(mpStringVal);
	return *mpStringVal;
}

int XMLConfigNameVal::GetTime() const
{
	ASSERT(mType == ValType::TYPE_TIME);
	return mTimeVal;
}

BOOL XMLConfigNameVal::ConvertToDateTime(const wstring & arValue, time_t * apConverted)
{
	//if (!arValue.isAscii())
	//return FALSE;
	return ::MTParseISOTime(ascii(arValue).c_str(), apConverted);
}

BOOL XMLConfigNameVal::ConvertToBoolean(const wstring & arValue, BOOL * apConverted)
{
	return MTTypeConvert::ConvertToBoolean(arValue, apConverted);
}

BOOL XMLConfigNameVal::ConvertToDouble(const wstring & arValue, double * apConverted)
{
	wchar_t * end;
	*apConverted = wcstod(arValue.c_str(), &end);
	if (end != arValue.c_str() + arValue.length())
		return FALSE;
	return TRUE;
}

#ifdef WIN32
BOOL XMLConfigNameVal::ConvertToDecimal(const wstring & arValue,
																				MTDecimalVal * apConverted)
{
	return apConverted->SetValue(arValue.c_str());
}

BOOL XMLConfigNameVal::ConvertToBigInteger(const wstring & arValue, __int64 * apConverted)
{
	wchar_t * end;
	*apConverted = _wcstoi64(arValue.c_str(), &end, 10);
	if (end != arValue.c_str() + arValue.length())
		return FALSE;
	return TRUE;
}
#endif

BOOL XMLConfigNameVal::ConvertToInteger(const wstring & arValue, int * apConverted)
{
	wchar_t * end;
	*apConverted = wcstol(arValue.c_str(), &end, 10);
	if (end != arValue.c_str() + arValue.length())
		return FALSE;
	return TRUE;
}

BOOL XMLConfigNameVal::ConvertToTime(const wstring & arValue, long * apConverted)
{
//	if (!arValue.isAscii())
//		return FALSE;

	*apConverted = ::MTConvertTime(ascii(arValue));
	return (*apConverted != -1);
}

#ifdef AUTO_ENUM_CONVERSION
BOOL XMLConfigNameVal::ConvertToEnum(const wstring & arValue, const wstring & arSpace, const wstring & arType, long * apConverted)
{
	int code = 0;
	
	_bstr_t bstrSpace(arSpace.c_str());
	_bstr_t bstrType(arType.c_str());
	_bstr_t bstrValue(arValue.c_str());
	_bstr_t bstrFQN;

	if (!arSpace.empty() && !arType.empty())
	{
		MTENUMCONFIGLib::IEnumConfigPtr enumConfig;
		HRESULT hr = enumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);
		if (FAILED(hr))
			return FALSE;

		try
		{
			bstrFQN = enumConfig->GetFQN(bstrSpace, bstrType, bstrValue);
		}
		catch (_com_error &)
		{
			// TODO: more error checking
			return FALSE;
		}
	}


	MTNAMEIDLib::IMTNameIDPtr nameID;

	// TODO: this will cause a lot of creation/deletions.
	//       we can't hold onto a reference and allow it to
	//       be deleted in a static destructor since CCodeLookup
	//       holds onto references to other DLLs that may have been
	//       unloaded at that time

	HRESULT hr = nameID.CreateInstance(MTPROGID_NAMEID);
	if (FAILED(hr))
		return FALSE;
	
	try
	{	
		if(!bstrFQN)
			code = nameID->GetNameID(arValue.c_str());
		else
			code = nameID->GetNameID((const wchar_t *) bstrFQN);
	}
	catch (_com_error &)
	{
		// TODO: more error checking
		return FALSE;
	}

	*apConverted = code;
	return TRUE;
}
#endif // AUTO_ENUM_CONVERSION

BOOL XMLConfigNameVal::FormatDateTime(time_t aDateTime, string & arFormatted)
{
	::MTFormatISOTime(aDateTime, arFormatted);
	return TRUE;
}

BOOL XMLConfigNameVal::FormatInteger(int aInt, string & arFormatted)
{
	char buffer[50];
	sprintf(buffer, "%d", aInt);
	arFormatted = buffer;
	return TRUE;
}

BOOL XMLConfigNameVal::FormatDouble(double aDouble, string & arFormatted)
{
	char buffer[50];
	sprintf(buffer, "%f", aDouble);
	arFormatted = buffer;
	return TRUE;
}

#ifdef WIN32
BOOL XMLConfigNameVal::FormatDecimal(const MTDecimalVal & arDecimal,
																		 string & arFormatted)
{
	char buffer[256];
	int len = sizeof(buffer);
	if (!arDecimal.Format(buffer, len))
		return FALSE;							// has to be smaller

	arFormatted = buffer;
	return TRUE;
}

BOOL XMLConfigNameVal::FormatBigInteger(__int64 aInt, string & arFormatted)
{
	char buffer[50];
	sprintf(buffer, "%I64d", aInt);
	arFormatted = buffer;
	return TRUE;
}
#endif

BOOL XMLConfigNameVal::FormatTime(long aTime, string & arFormatted)
{
	::MTFormatTime(aTime, arFormatted);
	return TRUE;
}

int XMLConfigNameVal::GetTypeId() const
{
	return msTypeId;
}

#if 0
BOOL XMLConfigNameVal::FormatValue(const _variant_t & arVar,
																	 ValType::Type aType, string & arStr)
{
	_bstr_t bstr;
	try
	{
		switch (aType)
		{
		case ValType::TYPE_BOOLEAN:
			if ((VARIANT_BOOL) arVar == VARIANT_TRUE)
				arStr = "TRUE";
			else
				arStr = "FALSE";
			break;
		case ValType::TYPE_TIME:
			FormatTime((long) arVar, arStr);
			break;
		case ValType::TYPE_DATETIME:
			FormatDateTime((time_t) arVar, arStr);
			break;
		case ValType::TYPE_OPAQUE:
			bstr = arVar;
			arStr = (const char *) bstr;
			break;
		default:
			// TODO: will this modify arVar?
			bstr = arVar;
			arStr = (const char *) bstr;
			break;
		}
		return TRUE;
	}
	catch (_com_error)
	{
		return FALSE;
	}
}
#endif

BOOL XMLConfigNameVal::FormatValue(string & arStr) const
{
	switch (mType)
	{
	case ValType::TYPE_BOOLEAN:
		if (mBoolVal)
			arStr = "TRUE";
		else
			arStr = "FALSE";
		break;
	case ValType::TYPE_TIME:
		FormatTime(mTimeVal, arStr);
		break;
	case ValType::TYPE_DATETIME:
		FormatDateTime(mDateTimeVal, arStr);
		break;
	case ValType::TYPE_INTEGER:
		FormatInteger(mIntegerVal, arStr);
		break;
	case ValType::TYPE_DOUBLE:
		FormatDouble(mDoubleVal, arStr);
		break;

	case ValType::TYPE_ENUM:
		if(mEmp.mpEnumTypeStr) {
			arStr = ascii(*mEmp.mpEnumTypeStr);
		}
		else {
			FormatInteger(mEmp.mEnumTypeVal,arStr);
		}
		break;
#ifdef WIN32
	case ValType::TYPE_DECIMAL:
		ASSERT(mpDecimalVal);
		FormatDecimal(*mpDecimalVal, arStr);
		break;
	case ValType::TYPE_BIGINTEGER:
		FormatBigInteger(mBigIntegerVal, arStr);
		break;
#endif
	case ValType::TYPE_OPAQUE:
		// FALL THROUGH - handled the same way as strings
	default:
		// TODO: will this modify arVar?
		ASSERT(mpStringVal);
		arStr = ascii(*mpStringVal);
		break;
	}
	return TRUE;
}


BOOL XMLConfigNameVal::FormatValue(wstring & arStr) const
{
	string asc;
	switch (mType)
	{
	case ValType::TYPE_BOOLEAN:
		if (mBoolVal)
			arStr = L"TRUE";
		else
			arStr = L"FALSE";
		break;
	case ValType::TYPE_TIME:
		FormatTime(mTimeVal, asc);
		ASCIIToWide(arStr, asc);
		break;
	case ValType::TYPE_DATETIME:
		FormatDateTime(mDateTimeVal, asc);
		ASCIIToWide(arStr, asc);
		break;
	case ValType::TYPE_INTEGER:
		FormatInteger(mIntegerVal, asc);
		ASCIIToWide(arStr, asc);
		break;
	case ValType::TYPE_DOUBLE:
		FormatDouble(mDoubleVal, asc);
		ASCIIToWide(arStr, asc);
		break;
	case ValType::TYPE_ENUM:
		if(mEmp.mpEnumTypeStr) {
			arStr = mEmp.mpEnumTypeStr->c_str();
		}
		else {
			FormatInteger(mEmp.mEnumTypeVal,asc);
			ASCIIToWide(arStr, asc);
		}
		break;
#ifdef WIN32
	case ValType::TYPE_DECIMAL:
		ASSERT(mpDecimalVal);
		FormatDecimal(*mpDecimalVal, asc);
		ASCIIToWide(arStr, asc);
		break;
	case ValType::TYPE_BIGINTEGER:
		FormatBigInteger(mBigIntegerVal, asc);
		ASCIIToWide(arStr, asc);
		break;
#endif
	case ValType::TYPE_OPAQUE:
		// FALL THROUGH - handled the same way as strings
	default:
		// TODO: will this modify arVar?
		ASSERT(mpStringVal);
		arStr = *mpStringVal;
		break;
	}
	return TRUE;
}

XMLNameValueMapDictionary* XMLConfigNameVal::CreateValueMapDictionary()
{
	return new XMLNameValueMapDictionary;
}


void XMLConfigNameVal::RealOutput(XMLWriter & arWriter) 
{
	/* <name [ptype="type"]>value</name> */

	const wchar_t * ptype;
	switch (mType)
	{
	case ValType::TYPE_INTEGER:
		ptype = L"INTEGER";
		break;
	case ValType::TYPE_DOUBLE:
		ptype = L"DOUBLE";
		break;
#ifdef WIN32
	case ValType::TYPE_DECIMAL:
		ptype = L"DECIMAL";
		break;
	case ValType::TYPE_BIGINTEGER:
		ptype = L"BIGINT";
		break;
#endif
	case ValType::TYPE_STRING:
		ptype = NULL;								// default
		break;
	case ValType::TYPE_DATETIME:
		ptype = L"DATETIME";
		break;
	case ValType::TYPE_TIME:
		ptype = L"TIME";
		break;
	case ValType::TYPE_BOOLEAN:
		ptype = L"BOOL";
		break;
	case ValType::TYPE_OPAQUE:
		ptype = L"OPAQUE";
		break;
	case ValType::TYPE_ENUM:
		ptype = L"ENUM";
		break;
	case ValType::TYPE_ID:
		ptype = L"ID";
		break;
	default:
	case ValType::TYPE_UNKNOWN:
	case ValType::TYPE_DEFAULT:
		// should never happen
		ASSERT(0);
		ptype = NULL;
		break;
	}

	if (ptype)
	{
		if(!mValueMap) {
			mValueMap = CreateValueMapDictionary();
		}

		XMLString xmlName(L"ptype");
		XMLString xmlValue(ptype);

		(*mValueMap)[xmlName] = xmlValue;

	}

	if((XMLNameValueMapDictionary *)mValueMap != NULL && (mValueMap->size() > 0)) {
		arWriter.OutputOpeningTag(GetName(),mValueMap);
	}
	else {
		arWriter.OutputOpeningTag(GetName());
	}

// TRISH changed from char* to unicode so that
  // the string data will go through the unicode to UTF-8 
  // convertion
  //string formatted;
  wstring formatted;

	BOOL success = FormatValue(formatted);
	// TODO: handle error cases
	ASSERT(success);

	arWriter.OutputCharacterData(formatted);


	arWriter.OutputClosingTag(GetName());
}

void XMLConfigNameVal::ProcessSubSet(MT_MD5_CTX* apMD5Context)
{
	/* <name [ptype="type"]>value</name> */
	const wchar_t * ptype;

	switch (mType)
	{
	case ValType::TYPE_INTEGER:
		ptype = L"INTEGER";
		break;
	case ValType::TYPE_DOUBLE:
		ptype = L"DOUBLE";
		break;
#ifdef WIN32
	case ValType::TYPE_DECIMAL:
		ptype = L"DECIMAL";
		break;
	case ValType::TYPE_BIGINTEGER:
		ptype = L"BIGINT";
		break;
#endif
	case ValType::TYPE_STRING:
		ptype = NULL;								// default
		break;
	case ValType::TYPE_DATETIME:
		ptype = L"DATETIME";
		break;
	case ValType::TYPE_TIME:
		ptype = L"TIME";
		break;
	case ValType::TYPE_BOOLEAN:
		ptype = L"BOOL";
		break;
	case ValType::TYPE_OPAQUE:
		ptype = L"OPAQUE";
		break;
	case ValType::TYPE_ENUM:
		ptype = L"ENUM";
		break;
	case ValType::TYPE_ID:
		ptype = L"ID";
		break;
	default:
	case ValType::TYPE_UNKNOWN:
	case ValType::TYPE_DEFAULT:
		// should never happen
		ASSERT(0);
		ptype = NULL;
		break;
	}

/*#ifdef WIN32
		XMLNameValueMap attrs(new XMLNameValueMapDictionary(RWWString::hash));
#else // WIN32
		XMLNameValueMap attrs(new XMLNameValueMapDictionary(UnixHashFunc));
#endif // WIN32*/

	if (ptype)
	{
		if(!mValueMap) {
			mValueMap = CreateValueMapDictionary();
		}

		XMLString xmlName(L"ptype");
		XMLString xmlValue(ptype);

		(*mValueMap)[xmlName] = xmlValue;
	}

	const char* name = GetName();

	if((XMLNameValueMapDictionary *)mValueMap != NULL && (mValueMap->size() > 0))
	{
		ProcessOpenTag(apMD5Context, name, mValueMap);
	}
	else 
	{
		ProcessOpenTag(apMD5Context, name);
	}
	
	// process data element
	wstring formatted;

	BOOL success = FormatValue(formatted);
	// TODO: handle error cases
	ASSERT(success);

	string stringValue;

	PreProcessCharacterData(stringValue, formatted);

	MT_MD5_Update(apMD5Context, 
								reinterpret_cast<unsigned char*>(const_cast<char*>(stringValue.c_str())), 
								stringValue.length());

	// Closing Tag
	ProcessClosingTag(apMD5Context, name);
	
}

/****************************************** XMLConfigPropSet ***/

const int XMLConfigPropSet::msTypeId = XMLObjectFactory::GetUserObjectId();

int XMLConfigPropSet::GetTypeId() const
{
	return msTypeId;
}


XMLConfigPropSet::~XMLConfigPropSet()
{
	// delete everything in the list
	//for_each(mList.begin(), mList.end(), destroyPtr<XMLConfigObject>);
	XMLConfigObjectIterator it;
	for (it = mList.begin(); it != mList.end(); it++)
	{
		XMLConfigObject * xmlConfigObject = *it;
		delete xmlConfigObject;
	}
	mList.clear();
}


//////////////////////////////////////////////////////////////////////////////////////
// Function name	: XMLConfigPropSet::TopLevelOutput
// Description	    : 
// Return type		: void 
// Argument         : XMLWriter & arWriter
// Argument         : const char* pCheckSum
//////////////////////////////////////////////////////////////////////////////////////

void XMLConfigPropSet::TopLevelOutput(XMLWriter & arWriter,const char* pCheckSum)
{
	arWriter.OutputStandardHeader();
	if(pCheckSum) {
		arWriter.OutputInstruction(CHECKSUM_NAME,pCheckSum);
	}
#if 0
	if(mDtd) {
		mDtd->Output(arWriter);
	}
	Output(arWriter);
#endif
	if(!mDtd) {
	  Output(arWriter);
	}
	else
	  {
	    mDtd->Output(arWriter);
	    Output(arWriter);
	  }
}


void XMLConfigPropSet::Output(XMLWriter & arWriter) const
{
	if(mValueMap && (mValueMap->size() > 0)) {
		arWriter.OutputOpeningTag(GetName(),mValueMap);
	}
	else {
		arWriter.OutputOpeningTag(GetName());
	}


	XMLConfigObjectList::const_iterator it;
	const XMLConfigObjectList & contents = GetContents();
	for (it = contents.begin(); it != contents.end(); it++)
	{
		XMLConfigObject * obj = *it;
		obj->Output(arWriter);
	}

	arWriter.OutputClosingTag(GetName());
}


// refresh checksum
void XMLConfigPropSet::ChecksumRefresh(string& pCheckSum)
{
	MT_MD5_CTX MD5Context;

	// generatedChecksum checksum value generated
	char generatedChecksum[MT_MD5_DIGEST_LENGTH+1];
	memset(generatedChecksum, 0, sizeof(generatedChecksum));

  // 128 bits as 16 x 8 bit bytes.
  unsigned char rawDigest[MT_MD5_DIGEST_LENGTH];

	const char* name = GetName();

	// Initialize MD5
	MT_MD5_Init(&MD5Context);
	
	if((XMLNameValueMapDictionary *)mValueMap != NULL && (mValueMap->size() > 0))
	{
		ProcessOpenTag(&MD5Context, name, mValueMap);
	}
	else 
	{
		ProcessOpenTag(&MD5Context, name);
	}
	
	// Walk through the tree
	// Walk through the tree
	XMLConfigObjectList::const_iterator it;
	const XMLConfigObjectList & contents = GetContents();
	for (it = contents.begin(); it != contents.end(); it++)
	{
		XMLConfigObject * obj = *it;
	
		obj->ProcessSubSet(&MD5Context);
	}

	// Closing Tag
	ProcessClosingTag(&MD5Context, name);

	MT_MD5_Final(rawDigest, &MD5Context);

  // Convert from 16 x 8 bits to 32 hex characters.
  for(int count = 0; count < (MT_MD5_DIGEST_LENGTH); count++)
  {
		sprintf(&generatedChecksum[count*2], "%02x", rawDigest[count] );
  }

	pCheckSum = generatedChecksum;

}

void XMLConfigPropSet::ProcessSubSet(MT_MD5_CTX* apMD5Context)
{
	const char* name = GetName();

	if((XMLNameValueMapDictionary *)mValueMap != NULL && (mValueMap->size() > 0))
	{
		ProcessOpenTag(apMD5Context, name, mValueMap);
	}
	else 
	{
		ProcessOpenTag(apMD5Context, name);
	}
	
	// Walk through the tree
	// Walk through the tree
	XMLConfigObjectList::const_iterator it;
	const XMLConfigObjectList & contents = GetContents();
	for (it = contents.begin(); it != contents.end(); it++)
	{
		XMLConfigObject * obj = *it;
	
		obj->ProcessSubSet(apMD5Context);
	}

	// Closing Tag
	ProcessClosingTag(apMD5Context, name);
}


// @mfunc Add an object to this list of configuration objects.
//  When the XMLConfigPropSet object is deleted, the object
//  added to the set will be deleted too.  The object isn't copied,
//  it's pointer is added to the list directly.
void XMLConfigPropSet::AddConfigObject(XMLConfigObject * apObject)
{
	mList.push_back(apObject);
}

XMLConfigPropSet::XMLConfigObjectList & XMLConfigPropSet::GetContents()
{
	return mList;
}

const XMLConfigPropSet::XMLConfigObjectList & XMLConfigPropSet::GetContents() const
{
	return mList;
}


BOOL XMLConfigPropSet::AddContents(XMLObjectVector & arContents)
{
	for (int i = 0; i < (int) arContents.GetEntries(); i++)
	{
		XMLObject * obj = arContents[i];

		// last argument is a dummy - it supplies the type
		XMLConfigPropSet * propSet = NULL;
		propSet = ConvertUserObject(obj, propSet);
		if (propSet)
		{
			AddConfigObject(propSet);

			// remove it so that it doesn't get
			// deleted after this function returns
			//it.remove();

			//obj = it();

			// TODO: // don't increment the iterator because we just removed the current element

			continue;
		}

		XMLConfigNameVal * nameVal = NULL;
		nameVal = ConvertUserObject(obj, nameVal);
		if (nameVal)
		{
			AddConfigObject(nameVal);
			// remove it so that it doesn't get
			// deleted after this function returns
			//it.remove();

			//obj = it();
			// TODO: // don't increment the iterator because we just removed the current element


			continue;
		}

		XMLData * data = XMLData::Data(obj);
		// TODO: this data is outside of a name/value container, but
		// still inside the property set.  It could contain human readable
		// text that doesn't contribute to the configuration.
		// In the future it could be saved along with the object so
		// that it could be printed again.  For now we just silently ignore it.

		if (!data)
		{
			// if it's not data, a name value pair, or a property set, then who knows
			// what it is.
			return FALSE;
		}
		else
			delete data;							// delete it so we don't leak

		// next element
		// this increment is skipped if the current element was removed from the list
		//obj = it();
		//if (!obj)
		//break;
	}

	// we removed all items, so don't delete anything from the list
	arContents.RemoveAll();

	return TRUE;
}


/************************************ XMLConfigObjectFactory ***/

// @cmember constructor
XMLConfigObjectFactory::XMLConfigObjectFactory()
#ifdef WIN32
	: mAutoConvertEnums(TRUE)
#else // WIN32
	: mAutoConvertEnums(FALSE)
#endif // WIN32
{ }


XMLObject * XMLConfigObjectFactory::CreateData(const char * apData, int aLen,BOOL bCdataSection)
{
#if 0
	// ignore whitespace - return NULL if the string is made up
	// of whitespace only
	BOOL allspace = TRUE;
	for (int i = 0; i < aLen; i++)
	{
		int ch = ((unsigned char *) apData)[i];
		if (!isspace(ch))
		{
			allspace = FALSE;
			break;
		}
	}
	if (allspace)
		return NULL;
#endif

	return XMLObjectFactory::CreateData(apData, aLen,bCdataSection);
}


XMLObject * XMLConfigObjectFactory::CreateAggregate(
	const char * apName,
	XMLNameValueMap& apAttributes,
	XMLObjectVector & arContents)
{
	const char * functionName = "XMLConfigObjectFactory::CreateAggregate";

	// is this a "simple" aggregate -
	//  matching tags filled only with character data?
	// if so, convert to an XMLConfigNameVal with the character data as the value.

	XMLObject * obj = NULL;
	if (DataOnly(arContents))
	{
		// only data inside.
		// combine the character data into a single string
		XMLString data;
		XMLAggregate::GetDataContents(data, arContents);



		// convert to rw string
		wstring value = data;
		XMLConfigNameVal * nameval = XMLConfigNameVal::Create(apName,
																													value,
																													apAttributes,
																													mAutoConvertEnums);
		if (!nameval)
		{
			string error = "Unable to parse contents of tag ";
			error += apName;
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, error.c_str());
		}

		obj = nameval;
	}
	else
	{
		// not just character data inside - construct a property set if possible
		XMLConfigPropSet * propSet = new XMLConfigPropSet(apName);
		if (!propSet)
		{
			string error = "Unable to parse contents of tag ";
			error += apName;
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, error.c_str());

			return NULL;
		}

		// add contents will delete everything from the list that
		// we don't want to be destroyed by xmlparser
		BOOL validContents = propSet->AddContents(arContents);

		// add the attributes
		propSet->PutMap(apAttributes);

		if (!validContents)
		{
			delete propSet;
			propSet = NULL;

			string error = "Unable to parse contents of tag ";
			error += apName;
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, error.c_str());
		}

		obj = propSet;
	}
	return obj;
}


XMLObject * XMLConfigObjectFactory::CreateEntity(const char *apcontext,
					  const char *apbase,
					  const char *apsystemId,
					  const char *appublicId)
{
	wstring aWideStr;
	ASCIIToWide(aWideStr, apsystemId);
	return new XMLEntity(aWideStr);
}




// is every item in here character data?
BOOL XMLConfigObjectFactory::DataOnly(const XMLObjectVector & arContents)
{
	for (int i = 0; i < (int) arContents.GetEntries(); i++)
	{
		XMLObject * obj = arContents[i];
		XMLData * data = XMLData::Data(obj);
		if (!data)
			return FALSE;
	}
	return TRUE;
}

/******************************************* XMLConfigParser ***/
XMLConfigParser::XMLConfigParser(int aBufferSize)
// : mBufferSize(aBufferSize)
{
	// tell the parser how to construct MSIX objects
	SetObjectFactory(&mFactory);
}

XMLConfigParser::~XMLConfigParser()
{
}


XMLConfigPropSet * XMLConfigParser::ParseFile(const char * apFilename)
{
	const char * functionName = "XMLConfigParser::ParseFile";

	FILE * inputfile = fopen(apFilename, "r");
	if (!inputfile)
	{
		string error(apFilename);
		error += ": ";
		error += strerror(errno);
		SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
						 functionName, error.c_str());
		return NULL;
	}

	XMLConfigPropSet * results = ParseFile(inputfile);
	if (!results)
	{
		string & proginfo = mpLastError->GetProgrammerDetail();
		if (proginfo.length() > 0)
		{
			proginfo.insert(0, ": ");
			proginfo.insert(0, apFilename);
		}
	}

	fclose(inputfile);
	return results;
}


XMLConfigPropSet * XMLConfigParser::ParseFile(FILE * apFile)
{
	const char * functionName = "XMLConfigParser::ParseFile";

	XMLObject * results = NULL;

	char buffer[4096];
	while (TRUE)
	{
    int nread = fread(buffer, sizeof(char), sizeof(buffer), apFile);
		if (nread < 0)
		{
			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, strerror(errno));
			return NULL;
    }

		BOOL result;
		if (nread < sizeof(buffer))
			result = ParseFinal(buffer, nread, &results);
		else
			result = Parse(buffer, nread);

		if (!result)
		{
			// supply detailed parse error info
			int code;
			const char * message;
			int line;
			int column;
			long byte;

			GetErrorInfo(code, message, line, column, byte);

			char buffer[20];
			string errormsg = "Parse error: ";
			errormsg += message;
			errormsg += ": line ";
			sprintf(buffer, "%d", line);
			errormsg += buffer;
			errormsg += ", column ";
			sprintf(buffer, "%d", column);
			errormsg += buffer;
			errormsg += ", byte 0x";
			sprintf(buffer, "%d", byte);
			errormsg += buffer;

			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, errormsg.c_str());
			return NULL;
		}

    if (nread < sizeof(buffer))
      break;
  }
	XMLConfigPropSet * propset = NULL;
	XMLConfigNameVal* pNameVal = NULL;

	if((pNameVal = ConvertUserObject(results, pNameVal)) && 
		pNameVal->GetPropType() == ValType::TYPE_STRING) {
			propset = new XMLConfigPropSet(pNameVal->GetName());
			delete results;
	}
	else {
		// NOTE: second argument is not used - it's just here to help sun's compiler deduce the
		// type.
		propset = ConvertUserObject(results, propset);
		if (!propset)
		{
			delete results;

			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName, "Invalid result type");
			return NULL;
		}
	}




#if 0
	if(mDtd) {
		mDtd->PutSetName(propset->GetName());
		propset->PutEntity(mDtd);
	}

	return propset;
#endif
	if(!mDtd) {
	  return propset;
	} 
	mDtd->PutSetName(propset->GetName());
	propset->PutEntity(mDtd);
	return propset;
}


XMLConfigNameVal * NextVal(XMLConfigPropSet::XMLConfigObjectIterator & arIt,
													 XMLConfigPropSet::XMLConfigObjectIterator & arEndIt)
{
	while (arIt != arEndIt)
	{
		XMLConfigObject * obj = *arIt++;

		XMLConfigNameVal * nameVal = NULL;
		nameVal = ConvertUserObject(obj, nameVal);
		if (nameVal)
			return nameVal;
	}
	return NULL;
}


XMLConfigObject * NextWithName(const char * apName,
															 XMLConfigPropSet::XMLConfigObjectIterator & arIt,
															 XMLConfigPropSet::XMLConfigObjectIterator & arEndIt)
{
	while (arIt != arEndIt)
	{
		XMLConfigObject * obj = *arIt++;

		if (0 == (mtstrcasecmp(obj->GetName(), apName)))
			return obj;
	}
	return NULL;
}


XMLConfigNameVal * NextValWithName(const char * apName,
																	 XMLConfigPropSet::XMLConfigObjectIterator & arIt,
																	 XMLConfigPropSet::XMLConfigObjectIterator & arEndIt)
{
	for (XMLConfigNameVal * obj = NextVal(arIt, arEndIt); obj; obj = NextVal(arIt, arEndIt))
	{
		if (0 == (mtstrcasecmp(obj->GetName(), apName)))
			return obj;
	}
	return NULL;
}

BOOL NextStringWithName(const char * apName,
												XMLConfigPropSet::XMLConfigObjectIterator & arIt,
												XMLConfigPropSet::XMLConfigObjectIterator & arEndIt,
												string & arString)
{
	for (XMLConfigNameVal * nameVal = NextValWithName(apName, arIt, arEndIt); nameVal;
			 nameVal = NextValWithName(apName, arIt, arEndIt))
	{
		if (nameVal->GetPropType() == ValType::TYPE_STRING)
		{
			arString = ascii(nameVal->GetString());
			return TRUE;
		}
	}
	return FALSE;
}

XMLConfigPropSet * NextSetWithName(const char * apName,
																	 XMLConfigPropSet::XMLConfigObjectIterator & arIt,
																	 XMLConfigPropSet::XMLConfigObjectIterator & arEndIt)
{
	for (XMLConfigObject * obj = NextWithName(apName, arIt, arEndIt); obj;
			 obj = NextWithName(apName, arIt, arEndIt))
	{
		XMLConfigPropSet * propset = NULL;
		propset = ConvertUserObject(obj, propset);
		if (propset)
			return propset;
	}
	return NULL;
}
