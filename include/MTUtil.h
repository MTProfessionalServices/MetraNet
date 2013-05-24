/****************************************************************************
**
**	FILENAME:		MTUtil.h
**
**	MODULE:			MTUtil
**
**	CREATED BY:		Derek Young, Raju Matta
**
**	MODIFIED BY:	
**
**	DATE CREATED:	24-Apr-1997
**
**	DESCRIPTION:
**
**	This class only has STATIC functions.  Do NOT instantiate, it 
**	will not work.
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
**	Some of these functions and ideas were "stolen" and modified from 
**	the CTP AT&T project (dimitri).
**
****************************************************************************/

#if !defined _MTUTIL_H
#define _MTUTIL_H

#include <time.h>

#ifdef WIN32
#include <comdef.h> 
#endif

#ifdef UNIX
#include <metra.h>
typedef unsigned int UINT;
#endif

#include <string>

using std::wstring;
using std::string;

int HashBytes(const unsigned char * apBytes, int aLen);

/**
 * Convert a string hh:mm:ss into number of seconds since midnight
 */
long MTConvertTime(const string& at);

/**
 * Convert number of seconds since midnight into hh:mm:ss.
 */
void MTFormatTime(long aTimeOfDay, string & arFormatted);

const char * GetIt();

// convert from ISO time string (like 1994-11-05T08:15:30Z) to
// a long Unix time value
BOOL MTParseISOTime(const char * apTimeString, time_t * apTime);

// convert from a unix time to an ISO time string

void MTFormatISOTime(time_t aTime, string & arBuffer);

#ifdef UNIX

BOOL ASCIIToWide(wstring & arWstring, const char * apAscii, int aLen = -1,
								 int aCodePage = 0);
#else  // UNIX
BOOL ASCIIToWide(wstring & arWstring, const char * apAscii, int aLen = -1,
								 int aCodePage = CP_ACP);
#endif

BOOL ASCIIToWide(wstring & arWstring, const string & arStr);

BOOL WideStringToUTF8(const wstring & arWide, string & arUTF);
BOOL WideStringToMultiByte(const wstring & arWide, string & arMultibyte, UINT aCodePage);


//the following methods have been deprecated by MTDate
//see MTDate::MTDate(DATE&) and MTDate::GetOLEDate(DATE*) for details
#ifdef _WIN32
void OleDateFromTimet(DATE * apOleDate, time_t aTime);
void TimetFromOleDate(time_t * apTime, DATE aDate);
void OleDateFromStructTm(DATE * apOleDate, struct tm * aTimeTm);
void StructTmFromOleDate(struct tm * apTime, DATE aDate);
#endif

// IP address as a string
void EncodeIPAddress(const unsigned char * apIPBytes, std::string & arIP);

// convert string back to bytes
BOOL DecodeIPAddress(const char * apIPString, unsigned char * apIPBytes);




// file access utility
BOOL CheckFile(std::string aFilename);

void ParseFilename(std::string aFilename, std::string& filePath, std::string& filename);

BOOL CheckDirectory(std::string aDirName);

void PathNameSuffix(std::string& aPath);

// check if this is a file
BOOL IsFile(std::string aFilename);

// check if this is a directory
BOOL IsDirectory(std::string aFilename);

void RemoveDirSuffix(std::string& aDirName);
void FormatFileName(std::string& aFileName);

// scanne through a string to replace TAB with SPACE
BOOL StringFormat(std::string aInputString, std::string& aOutputString);

// data posting

#ifdef _WIN32
HRESULT MTPostData(std::string aHostName, std::string aRelativePath,
								std::string aFilename, 
								std::string aUsername, std::string aPassword,
								BOOL aSecure);
#endif

// defines for exporting dll ...
#undef DLL_EXPORT
#define DLL_EXPORT		__declspec (dllexport)
#ifdef _WIN32
#include <imagehlp.h>
#endif

class MTStackTrace
{
public:
#ifdef _WIN32
	static BOOL CurrentContext(LPCONTEXT apContext);

	static void GenerateStackTrace();

	static BOOL GenerateExceptionReport(std::string & arTrace,
															 const LPCONTEXT apContext);
	static int __cdecl _tprintf(const char * format, ...);

private:
	static void NtStackTrace();

	static BOOL GetLogicalAddress(PVOID addr, PSTR szModule, DWORD len,
																DWORD& section, DWORD& offset);

	static void ImagehlpStackWalk(PCONTEXT pContext);
	static BOOL InitImagehlpFunctions();


	static long Filter(LPCONTEXT apContext, LPCONTEXT apSourceContext);

	static BOOL mGotContext;

	static std::string mTrace;

#endif

#ifdef _WIN32
	// Make typedefs for some IMAGEHLP.DLL functions so that we can use them
	// with GetProcAddress
	typedef BOOL (__stdcall * SYMINITIALIZEPROC)( HANDLE, LPSTR, BOOL );
	typedef BOOL (__stdcall *SYMCLEANUPPROC)( HANDLE );

	typedef BOOL (__stdcall * STACKWALKPROC)
		( DWORD, HANDLE, HANDLE, LPSTACKFRAME, LPVOID,
			PREAD_PROCESS_MEMORY_ROUTINE,PFUNCTION_TABLE_ACCESS_ROUTINE,
			PGET_MODULE_BASE_ROUTINE, PTRANSLATE_ADDRESS_ROUTINE );

	typedef LPVOID (__stdcall *SYMFUNCTIONTABLEACCESSPROC)( HANDLE, DWORD );

	typedef DWORD (__stdcall *SYMGETMODULEBASEPROC)( HANDLE, DWORD );

	typedef BOOL (__stdcall *SYMGETSYMFROMADDRPROC)
		( HANDLE, DWORD, PDWORD, PIMAGEHLP_SYMBOL );

	typedef BOOL (__stdcall *SYMENUMERATEMODULESPROC)
		(HANDLE,PSYM_ENUMMODULES_CALLBACK,PVOID);                               
		

	static SYMINITIALIZEPROC _SymInitialize;
	static SYMCLEANUPPROC _SymCleanup;
	static STACKWALKPROC _StackWalk;
	static SYMFUNCTIONTABLEACCESSPROC _SymFunctionTableAccess;
	static SYMGETMODULEBASEPROC _SymGetModuleBase;
	static SYMGETSYMFROMADDRPROC _SymGetSymFromAddr;
	static SYMENUMERATEMODULESPROC _SymEnumerateModules;


#endif

};



// class declaration

class MTMiscUtil
{
	public:

		//
		// Deal with environment variables
		//
		// The variable name should never be null.
		//

		// Note: If the variable exists but its value is null, 
		// getEnv() will return "", NOT the default value.
		// This is designed in order to accomodate variables whose 
		// mere setting is enough.
		static const std::wstring GetEnv ( const std::wstring& envVariableName, 
										const std::wstring& defaultValue = L"");

		// Throw MTExRunTime if putenv fails.
		static const std::wstring PutEnv (	const std::wstring& envVariableName,
										const std::wstring& value);

		//
		// Conversion routines
		//

		// Throw MTExInvalidArgument if could not convert to specified type
		// Throw MTExRange if resulting number is out of range
		static const int WStringToInt(const wchar_t* from);
		static const long WStringToLong(const wchar_t* from);
		static const unsigned int WStringToUInt(const wchar_t* from);
		static const unsigned long WStringToULong(const wchar_t* from);
		static const double WStringToDouble(const wchar_t* from);
		

		// Throw UAExInvalidArgument if conversion cannot be performed
		static const std::wstring IntToWString(const int from);
		static const std::wstring UintToWString(const unsigned int from);
		static const std::wstring LongToWString(const long from);
		static const std::wstring UlongToWString(const unsigned long from);
		static const std::wstring DoubleToWString(const double from);


		//
		// Hash functions (required by Rogue classes)
		//
		static unsigned hashFunction(const std::wstring& s);
		static unsigned hashInt(const int& i);

  
		// Convert regular string to MD5 hash
		static BOOL ConvertStringToMD5(const char* apString, std::string& arHash);
		//
		// Unique filenames
		//

		// This throws exceptions thrown by Uuid
		// The prefix should never be null
		static const std::wstring 
		MakeUniqueFilename(const std::wstring& path = L"/tmp",
						   const std::wstring& prefix = L"tmp.",
						   const std::wstring& suffix = L"");

		// DirName, BaseName
		static const std::wstring GetDirName(const std::wstring& filename);
		static const std::wstring GetBaseName(const std::wstring& filename);

#ifdef WIN32
		static const _bstr_t GetString(const _variant_t& arValue);
		static bool CreateGuidAsVariant(_variant_t& vtValue);
    static bool GuidToString(_variant_t& vtGuid,_bstr_t& outputVal);
#endif

	protected:

	private:

		//
		// WARNING: The following member functions are not defined
		//

		// Constructor
		MTMiscUtil();

		// Destructor
		virtual ~MTMiscUtil();

		// Copy constructor
		MTMiscUtil(const MTMiscUtil& d);

		// Assignment operator
		const MTMiscUtil& operator=(const MTMiscUtil& d);

};


#endif



