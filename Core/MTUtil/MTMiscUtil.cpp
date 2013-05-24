/****************************************************************************
**	
**	FILENAME:		MTMiscUtil.cpp
**
**	MODULE:			MTUtil
**
**	CREATED BY:		Dimitri Panagiotou
**
**	MODIFIED BY:	Raju Matta	
**
**	DATE CREATED:	25-Aug-1998
**
**	DESCRIPTION:
**
**	This class only has STATIC functions.  Do NOT instantiate, it will
**	not work.
**
**	Misc Utility functions
**  - utilities to get and set environment variables
** 	- utilities to convert RWWString <--> ints/longs/doubles
**	- static wrappers around hash functions, needed by Rogue Dictionaries etc.
**
**	NOTES:
**	
**	The putEnv method should be used with care.  Most of the time, you 
**  don't want to change env. variables.
**	Some functions throw exceptions.  Look at the individual function specs.
**
****************************************************************************/

// includes

#include <MTUtil.h>
#include <global.h>
#include <mtmd5.h>
#include <math.h>

#include <iostream>

using std::cout;
using std::endl;

// constants

// globals

// code


/****************************************************************************
**
**  FUNCTION:		MTMiscUtil() - Constructor
**
**  ARGUMENTS:
**
**  RETURN VALUE:	none
**
**  SCOPE:			private
**
**  VIRTUAL:		no
**
**  STATIC:			no
**
**  CONST:			no
**
**  DESCRIPTION:
**
**  This is the Constructor for the class MTMiscUtil
**
****************************************************************************/

// Not defined


/****************************************************************************
**
**  FUNCTION:		~MTMiscUtil() - Destructor
**
**  ARGUMENTS:
**
**  RETURN VALUE:	none
**
**  SCOPE:			private
**
**  VIRTUAL:		yes
**
**  STATIC:			no
**
**  CONST:			no
**
**  DESCRIPTION:
**
**  This is the Destructor for the class MTMiscUtil
**
****************************************************************************/

// Not defined


/****************************************************************************
**
**  FUNCTION:		MTMiscUtil() - Copy Constructor
**
**  ARGUMENTS:		const MTMiscUtil& d
**						A reference to the object being copied
**
**  RETURN VALUE:	none
**
**  SCOPE:			private
**
**  VIRTUAL:		no
**
**  STATIC:			no
**
**  CONST:			no
**
**  DESCRIPTION:
**
**  This would have been the default Copy Constructor 
**  for the class MTMiscUtil. 
**	However, it has been removed so that it is never used.
**
****************************************************************************/

// Not defined


/****************************************************************************
**
**  FUNCTION:		operator=() - Assignment Operator
**
**  ARGUMENTS:		const MTMiscUtil& d
**						A reference to the object being assigned
**
**  RETURN VALUE:	const MTMiscUtil&
**
**  SCOPE:			private
**
**  VIRTUAL:		no
**
**  STATIC:			no
**
**  CONST:			no
**
**  DESCRIPTION:
**
**  This would have been the default Assignment operator for the class 
**  MTMiscUtil.
**	However, it has been removed so that it is never used.
**
****************************************************************************/

// Not defined


/****************************************************************************
**
**	FUNCTION:			getEnv
**
**	ARGUMENTS:			const RWWString& envVariableName
**							a string with the name of the environment variable
**						const RWWString& defaultValue
**							an optional string with the default value
**
**	RETURN VALUE:		const RWWString
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Returns a string with an environment variable value.
**  If the variable doesn't exist, it returns
**	the default value (if supplied, otherwise "").
**
****************************************************************************/
#ifdef UNIX // pertains more to retrieving UNIX env. variables
const std::wstring
MTMiscUtil::getEnv(const std::wstring& envVariableName, 
				   const std::wstring& defaultValue)
{
	// Make sure that the envVariableName is NOT null
	assert(envVariableName != L"");
	
	char* pEnvString = getenv(envVariableName);

	if (pEnvString == 0)
	{
		return defaultValue;
	}
	else
	{
		return pEnvString;
	}
}
#endif UNIX // pertains more to retrieving UNIX env. variables

/****************************************************************************
**
**	FUNCTION:			putEnv
**
**	ARGUMENTS:			const RWWString& envVariableName
**							a string with the name of the environment variable
**						const RWWString& value
**							an optional string with the default value
**
**	RETURN VALUE:		const RWWString
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Use with care.  It is very rare that a program needs to alter 
**	its environment (usually to pass on to its child processes)
**	It returns its previous value, if any
**
**	If putenv fails, it throws UAExRunTime
**
****************************************************************************/
#ifdef UNIX //pertains more to retrieving UNIX env. variables
const std::wstring
MTMiscUtil::putEnv(const std::wstring& envVariableName, 
				   const std::wstring& value)
{
	// Make sure that the envVariableName is NOT null
	assert(envVariableName != L"");

	std::wstring oldVariableValue = getEnv(envVariableName, "");

	std::wstring envString = envVariableName + "=" + value;

	// Allocate memory on the heap for this new variable
	// We cannot use an automatic variable
	char* const pEnvString = new char[envString.length()+1];

	strcpy(pEnvString, envString.c_str());

	if (putenv(pEnvString) != 0)
	{
		// build and error object and throw exception
		cout << "Unable to set environment variable" << endl;
	}

	return(oldVariableValue);
}
#endif //pertains more to retrieving UNIX env. variables


/****************************************************************************
**
**	FUNCTION:			WstringToInt
**
**	ARGUMENTS:			const char *from
**							a string to be converted to the number
**
**	RETURN VALUE:		const int
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Converts a const char * to an int.
**	If the conversion cannot be performed, it throws UAExInvalidArgument.
**	If the converted string results in a number out of range, 
**  it throws UARangeExcp.
**
**  Make sure you need this and not stringToULong or stringToUInt etc.
**
****************************************************************************/
const int
MTMiscUtil::WStringToInt(const wchar_t* from)
{
#if 0
	cout << "Entering WStringToInt()" << endl;
#endif
	wchar_t* position;

	long tmp = wcstol(from, &position, 10);

	if (*position != 0)
	{
		cout << "Could not convert string to int" << endl;
		// create an error object and throw.
	}

	// check for out of range
	if ((tmp == LONG_MAX) || (tmp == LONG_MIN) ||
		(tmp > INT_MAX) || (tmp < INT_MIN))
	{
		cout << "Conversion of string to int out of range" << endl;
		// create an error object and throw
	}
#if 0
	cout << "Leaving WStringToInt()" << endl;
#endif
	return (const int) tmp;
}


/****************************************************************************
**
**	FUNCTION:			WstringToLong
**
**	ARGUMENTS:			const char *from
**							a string to be converted to the number
**
**	RETURN VALUE:		const long
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Converts a const char * to a long.
**	If the conversion cannot be performed, it throws UAExInvalidArgument.
**	If the converted string results in a number out of range, 
**  it throws UAExRange.
**
**  Make sure you need this and not WstringToULong or WstringToInt etc.
**
****************************************************************************/

const long
MTMiscUtil::WStringToLong(const wchar_t* from)
{
	wchar_t* position;

	long tmp = wcstol(from, &position, 10);

	if (*position != 0)
	{
		// create an error object and throw
		cout <<	"Could not convert string to long" << endl;
	}
		
	if ((tmp == LONG_MAX) || (tmp == LONG_MIN))
	{
		// create an error object and throw
		cout << "Conversion of string to long out of range" << endl;
	}

	return tmp;
}



/****************************************************************************
**
**	FUNCTION:			WstringToUInt
**
**	ARGUMENTS:			const char *from
**							a string to be converted to the number
**
**	RETURN VALUE:		const unsigned int
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Converts a const char * to an unsigned int.
**	If the conversion cannot be performed, it throws UAExInvalidArgument.
**	If the converted string results in a number out of range, 
**  it throws UAExRange.
**
**  Make sure you need this and not WstringToULong or WstringToUInt etc.
**
****************************************************************************/

const unsigned int
MTMiscUtil::WStringToUInt(const wchar_t* from)
{
	wchar_t* position;

	unsigned long tmp = wcstoul(from, &position, 10);

	if (*position != 0)
	{
		// create an error object and throw
		cout << "Could not convert string to unsigned int" << endl;
	}
		
	if ((tmp == ULONG_MAX) || (tmp > UINT_MAX))
	{
		// create an error object and throw
		cout << "Conversion of string to unsigned int out of range" << endl;
	}

	return (const unsigned int) tmp;
}


/****************************************************************************
**
**	FUNCTION:			WstringToULong
**
**	ARGUMENTS:			const char *from
**							a string to be converted to the number
**
**	RETURN VALUE:		const unsigned long
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Converts a const char * to a long.
**	If the conversion cannot be performed, it throws UAExInvalidArgument.
**	If the converted string results in a number out of range, 
**  it throws UAExRange.
**
**  Make sure you need this and not WstringToULong or WstringToInt etc.
**
****************************************************************************/

const unsigned long
MTMiscUtil::WStringToULong(const wchar_t* from)
{
	wchar_t* position;

	unsigned long tmp = wcstoul(from, &position, 10);

	if (*position != 0)
	{
		// create an error object and throw
		cout << "Could not convert string to unsigned long" << endl;
	}
		
	if (tmp == ULONG_MAX)
	{
		// create an error object and throw
		cout << "Conversion of string to unsigned long out of range" << endl;
	}

	return tmp;
}


/****************************************************************************
**
**	FUNCTION:			WstringToDouble
**
**	ARGUMENTS:			const char *from
**							a string to be converted to a double
**
**	RETURN VALUE:		const double
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Converts a const char * to a double.
**	If the conversion cannot be performed, it throws UAExInvalidArgument.
**	If the converted string results in a number out of range, 
**  it throws UAExRange.
**
****************************************************************************/

const double
MTMiscUtil::WStringToDouble(const wchar_t* from)
{
	wchar_t* position;

	double tmp = wcstod(from, &position);

	if (*position != 0)
	{
		// build an error object and throw
		cout << "Could not convert string to double" << endl;
	}
		
	if ((tmp == HUGE_VAL) || (tmp == -HUGE_VAL))
	{
		// build an error object and throw
		cout << "Conversion of string to double out of range" << endl;
	}

	return tmp;
}


/****************************************************************************
**
**	FUNCTION:			intToWString
**
**	ARGUMENTS:			const int from
**							a number to be converted to a string
**
**	RETURN VALUE:		const RWWString
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Converts a number to a string.
**	If the conversion cannot be performed, it throws UAExInvalidArgument.
**
**  Make sure you need this and not uintToWString etc.
**
****************************************************************************/

const std::wstring
MTMiscUtil::IntToWString(const int from)
{
	wchar_t tmp[100];
	
	if (swprintf(tmp, L"%d", from) < 0)
	{
		// build an error object and throw
		cout << "Could not convert int to string" << endl;
	}

	return (tmp);
}


/****************************************************************************
**
**	FUNCTION:			uintToWString
**
**	ARGUMENTS:			const unsigned int from
**							a number to be converted to a string
**
**	RETURN VALUE:		const RWWString
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Converts a number to a string.
**	If the conversion cannot be performed, it throws UAExInvalidArgument.
**
**  Make sure you need this and not uintToWString etc.
**
****************************************************************************/

const std::wstring
MTMiscUtil::UintToWString(const unsigned int from)
{
	wchar_t tmp[100];
	
	if (swprintf(tmp, L"%u", from) < 0)
	{
		// build an error object and throw
		cout << "Could not convert unsigned int to string" << endl;
	}

	return (tmp);
}



/****************************************************************************
**
**	FUNCTION:			longToWString
**
**	ARGUMENTS:			const long from
**							a number to be converted to a string
**
**	RETURN VALUE:		const RWWString
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Converts a number to a string.
**	If the conversion cannot be performed, it throws UAExInvalidArgument.
**
**  Make sure you need this and not uintToWString etc.
**
****************************************************************************/

const std::wstring
MTMiscUtil::LongToWString(const long from)
{
	wchar_t tmp[100];
	
	if (swprintf(tmp, L"%ld", from) < 0)
	{
		// build an error object and throw
		cout << "Could not convert long to string" << endl;
	}

	return (tmp);
}


/****************************************************************************
**
**	FUNCTION:			ulongToWString
**
**	ARGUMENTS:			const unsigned long from
**							a number to be converted to a string
**
**	RETURN VALUE:		const RWWString
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Converts a number to a string.
**	If the conversion cannot be performed, it throws UAExInvalidArgument.
**
**  Make sure you need this and not uintToWString etc.
**
****************************************************************************/

const std::wstring
MTMiscUtil::UlongToWString(const unsigned long from)
{
	wchar_t tmp[100];
	
	if (swprintf(tmp, L"%lu", from) < 0)
	{
		// build an error object and throw
		cout << "Could not convert unsigned long to string" << endl;
	}

	return (tmp);
}


/****************************************************************************
**
**	FUNCTION:			doubleToWString
**
**	ARGUMENTS:			const double
**							a double to be converted to a string
**
**	RETURN VALUE:		const RWWString
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Converts a double to a string.
**	If the conversion cannot be performed, it throws UAExInvalidArgument.
**
****************************************************************************/

const std::wstring
MTMiscUtil::DoubleToWString(const double from)
{
	wchar_t tmp[100];
	
	if (swprintf(tmp, L"%lf", from) < 0)
	{
		// create an error object and throw
		cout << "Could not convert double to string" << endl;
	}

	return (tmp);
}



/****************************************************************************
**
**	FUNCTION:			hashFunction
**
**	ARGUMENTS:			const RWWString& s
**							arg whose hash value is to be calculated
**
**	RETURN VALUE:		static unsigned
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Calculate the hash value of a given RWWString.
**	To be used in Rogue HashDictionaries etc.
**
****************************************************************************/

/*unsigned 
MTMiscUtil::hashFunction(const std::wstring& s)
{
	return (s.hash());
}*/  
//AR: did not know what to do with this one, temporarily commented out.


/****************************************************************************
**
**	FUNCTION:			makeUniqueFilename
**
**	ARGUMENTS:			const char* path
**							optional path to be prepended.
**						const char* prefix
**							optional file prefix (default: tmp)
**						const char* suffix
**							optional file suffix (default: "")
**
**	RETURN VALUE:		const RWWString
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes 
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Create a temporary UNIQUE filename.
**  Make sure you trap the exceptions thrown by Uuid
**
****************************************************************************/
#ifdef UNIX // more specific to UNIX
const std::wstring 
MTMiscUtil::MakeUniqueFilename(const std::wstring& path,
							   const std::wstring& prefix,
							   const std::wstring& suffix)
{
	// Make sure that at least the prefix is not null
	assert(prefix != L"");

	wchar_t* tmpName = ::tempnam(0, 0);
	
	std::wstring s(tmpName);
	free (tmpName);
	
	// Strip automatically provided pre-path
	s = getBaseName(s);
	
	// Make sure path always ends in a /

	s = path.strip(std::wstring::trailing, '/') + "/" + prefix + s + suffix;

	return(s);
}
#endif // more specific to UNIX

/****************************************************************************
**
**	FUNCTION:			getDirName
**
**	ARGUMENTS:			const RWWString& filename
**							the filename
**
**	RETURN VALUE:		const RWWString
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes 
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**  Returns the dirname of a filename.
**	If the filename has not directory component, it is assumed to be
**	in the current directory and "." is returned.
**	If the filename passed in is in relative form, or if it contains ..,
**	it is NOT expanded, the directory path is returned as is.
**	The returned string will never end in '/'
**
****************************************************************************/

const std::wstring 
MTMiscUtil::GetDirName(const std::wstring& filename)
{

	int idx;

	idx = filename.find_last_of('/', filename.length()-1);

	if (idx == NULL)
	{
		return (L".");
	}
	else
	{
		return (filename.substr(0, idx));
	}
}



/****************************************************************************
**
**	FUNCTION:			getBaseName
**
**	ARGUMENTS:			const RWWString& filename
**							the filename
**
**	RETURN VALUE:		const RWWString
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes 
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**  Returns the basename of a filename.
**	If the filename has not directory component, the entire pathname is 
**	returned. 
**
****************************************************************************/

const std::wstring 
MTMiscUtil::GetBaseName(const std::wstring& filename)
{
	int idx;
	idx = filename.find_last_of('/', filename.length()-1);

	if (idx == NULL)
	{
		return (filename);
	}
	else
	{
		return (filename.substr(idx+1, (filename.length() - 1)));
	}
}

/****************************************************************************
**
**	FUNCTION:			hashInt
**
**	ARGUMENTS:			const int& i
**							arg whose hash value is to be calculated
**
**	RETURN VALUE:		static unsigned
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**	
**	Calculate the hash value of a given int.
**	To be used in Rogue HashDictionaries etc.
**
****************************************************************************/
unsigned 
MTMiscUtil::hashInt(const int& i)
{
	unsigned hID;
	hID = i;
	return hID;
}


/****************************************************************************
**
**	FUNCTION:			ConvertStringToMD5
**
**	ARGUMENTS:			const char* String
**							String to be hashed to MD5
**
**	RETURN VALUE:		void
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:
**
****************************************************************************/
BOOL  
MTMiscUtil::ConvertStringToMD5 (const char* apString, std::string& arHash)
{
	char GeneratedChecksum[MT_MD5_DIGEST_LENGTH * 2 + 1];
	MT_MD5_CTX MD5Context;

	// Initialize MD5
	MT_MD5_Init(&MD5Context);

	// update
	MT_MD5_Update(&MD5Context, (unsigned char*) apString, strlen((char*)apString));

	// 128 bits as 16 x 8 bit bytes.
	unsigned char rawDigest[MT_MD5_DIGEST_LENGTH];

	// final
	MT_MD5_Final(rawDigest, &MD5Context);

	// Convert from 16 x 8 bits to 32 hex characters.
	for(int count = 0; count < MT_MD5_DIGEST_LENGTH; count++)
	{
	    sprintf( &GeneratedChecksum[count*2], "%02x", rawDigest[count] );
  }

	// set arHash
	arHash = GeneratedChecksum;

	return TRUE;
}

/****************************************************************************
**
**	FUNCTION:			GetString
**
**	ARGUMENTS:			const char* String
**							String to be hashed to MD5
**
**	RETURN VALUE:		void
**
**	SCOPE:				public
**
**	VIRTUAL:			no
**
**	STATIC:				yes
**
**	CONST:				no (since it is static)
**
**	DESCRIPTION:        This is to fix bug number 4510
**
**
**    MTSQL Rowset stores emty strings as NULL values in Oracle
**    This behavior is different from MS SQL Server, where empty strings are 
**    stored as empty strings.
**
**    [kdf - 1/3/2000] After doing some research into the problem, we see 
**    different behavior for Oracle and SQL Server with respect to '' (null 
**    strings). On Oracle, the null string are inserted as null into the 
**    database. When the value is selected back from the database, it's variant 
**    type is VT_NULL which causes problems for the UI and some backend 
**    components. 
**    
**    For the backend components a GetString function could be used to 
**    return a null string when the variant's type is VT_NULL or the 
**    actual string when the variant contains a string.
**
**    _variant_t vtValue = rowset->GetValue() ;
**    bstrVal = GetString(vtValue) ;
**
****************************************************************************/
#ifdef WIN32
const _bstr_t  
MTMiscUtil::GetString (const _variant_t& arValue)
{
	if (arValue.vt == VT_NULL)
		return "" ;
	else
		return arValue.bstrVal ;
}


bool MTMiscUtil::CreateGuidAsVariant(_variant_t& vtValue)
{
  SAFEARRAYBOUND saboundParent[1] ;
  SAFEARRAY * pSAParent;
  saboundParent[0].lLbound = 0 ;
  saboundParent[0].cElements = 16 ;
  
  // create the safe arrary ...
  pSAParent = SafeArrayCreate (VT_UI1, 1, saboundParent) ;
  if (pSAParent == NULL)
  {
		return false;
  }

  unsigned char * uidData;
  // set uidData to the contents of the safe array ...
  ::SafeArrayAccessData(pSAParent, (void **)&uidData);

	GUID newGUID;
	HRESULT hr = ::CoCreateGuid(&newGUID);
	if(FAILED(hr)) {
		// this is not likely to fail
		return false;
	}
  
	// copy the GUID value into the safe array
  memcpy (uidData,&newGUID, 16) ;
  
  // Release lock on safe array
  ::SafeArrayUnaccessData(pSAParent);

  // assign the safe array to the variant
  vtValue.vt = (VT_ARRAY | VT_UI1);
  vtValue.parray = pSAParent ;

	return true;
}

bool MTMiscUtil::GuidToString(_variant_t& vtGuid,_bstr_t& outputVal)
{
  if(vtGuid.vt == (VT_ARRAY | VT_UI1)) {
    // looks like a guid.  we will give it the ole college try.
    unsigned char* uidData;

    SAFEARRAY* pSafeArray = vtGuid.parray;
    ::SafeArrayAccessData(pSafeArray,(void**)&uidData);
    GUID newGUID;
    memcpy(&newGUID,uidData,16);
    ::SafeArrayUnaccessData(pSafeArray);

    wchar_t tempbuff[100];

    int len = ::StringFromGUID2(newGUID,&(tempbuff[0]),40);
    if(len == 0) {
      return false;
    }
    outputVal = tempbuff;
    return true;
  }
  return false;
}

#endif

