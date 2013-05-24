#ifndef __STRINGCONVERT_H__
#define __STRINGCONVERT_H__

#include "MTSQLConfig.h"

#include <string>
#include <unicode/unistr.h>

#ifndef WIN32
void WideStringToUTF8(std::string& utf8, const wchar_t * wideStart, const wchar_t * wideEnd);
void WideStringToUTF8(const std::wstring& wide, std::string& utf8);
void WideStringToUTF8(const wchar_t * wide, std::string& utf8);
#endif

MTSQL_DECL void UTF8ToWideString(std::wstring& wide, const char * utf8Start, const char * utf8End);
MTSQL_DECL void UTF8ToWideString(std::wstring& wide, const std::string& utf8);
MTSQL_DECL void UTF8ToWideString(std::wstring& wide, const char * utf8);

MTSQL_DECL void UTF8ToUnicodeString(UnicodeString& wide, const std::string& utf8);
MTSQL_DECL void UTF8ToUnicodeString(UnicodeString& wide, const char * utf8);
MTSQL_DECL void UnicodeStringToUTF8(const UChar * wide, std::string& utf8);
MTSQL_DECL void UnicodeStringToUTF8(const UnicodeString& wide, std::string& utf8);
MTSQL_DECL void UnicodeStringToUTF8(const UChar * wide, std::string& utf8);
MTSQL_DECL void UnicodeStringToUTF8(std::string& utf8, const UChar * wideStart, const UChar * wideEnd);

MTSQL_DECL void WideStringToUnicodeString(const std::wstring& wide, UnicodeString& utf16);
#endif
