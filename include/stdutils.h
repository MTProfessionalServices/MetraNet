/**************************************************************************
 * @doc STDUTILS
 *
 * @module |
 *
 *
 * Copyright 2000 by MetraTech Corporation
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
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | STDUTILS
 ***************************************************************************/

#ifndef _STDUTILS_H
#define _STDUTILS_H

#include <string>
#include <algorithm>
#include <functional>
#include <iostream>
using std::copy;
using std::string;
using std::wstring;


#ifdef WIN32
#define mtstrcasecmp stricmp
#define mtwcscasecmp wcsicmp
#else

// FIXME: wchar.h is not coming in when I include it
// #include <wchar.h>
extern wint_t towupper(wint_t);
extern wint_t towlower(wint_t);

#define mtstrcasecmp strcasecmp
#define mtwcscasecmp strwcasecmp
#endif

/*
 * C++ std lib or STL utilities
 */

// case insensitive string or wstring comparison not provided by C++ stdlib
#ifdef WIN32
template <class T>
int strcasecmp(const T & arS1, const T & arS2)
{
  typename T::const_iterator p = arS1.begin(),
		p2 = arS2.begin();
 
  while (p != arS1.end() && p2 != arS2.end())
	{
    if (tolower(*p) != tolower(*p2))
			return tolower(*p) < tolower(*p2) ? -1: 1;
		++p; ++p2;
  }

  return arS2.size() - arS1.size();
}
#endif

#ifdef UNIX
// template <class T> int strcasecmp(const T & arS1, const T & arS2);
template <class T>
int strcasecmp(const T & arS1, const T & arS2)
{
  typename T::const_iterator p = arS1.begin(),
		p2 = arS2.begin();

  while (p != arS1.end() && p2 != arS2.end())
	{
    if (tolower(*p) != tolower(*p2))
			return tolower(*p) < tolower(*p2) ? -1: 1;
		++p; ++p2;
  }

  return arS2.size() - arS1.size();
}

inline int strcasecmp(const char *arS1, const char *arS2)
{
	return strcasecmp(std::string(arS1), std::string(arS2));
}

inline int strwcasecmp(const wchar_t *arS1, const wchar_t *arS2)
{
	return strcasecmp(std::wstring(arS1), std::wstring(arS2));
}

#endif
 

inline void StrToLower(string& arInVal)
{
	for(string::iterator iter = arInVal.begin();iter != arInVal.end();iter++) {
		*iter = (char) tolower(*iter);
	}
}

inline void StrToLower(wstring& arInVal)
{
	for(wstring::iterator iter = arInVal.begin();iter != arInVal.end();iter++) {
		*iter = towlower(*iter);
	}
}

inline void StrToUpper(string& arInVal)
{
	for(string::iterator iter = arInVal.begin();iter != arInVal.end();iter++) {
		*iter = (char) toupper(*iter);
	}
}

inline void StrToUpper(wstring& arInVal)
{
	for(wstring::iterator iter = arInVal.begin();iter != arInVal.end();iter++) {
		*iter = towupper(*iter);
	}
}

#ifdef WIN32

//
// case insensitive find
//
template <class T>
inline typename T::size_type strfind(const T & source,
														const T & pattern,
														typename T::size_type offset = 0)
{
	// TODO: do the copy and lower in one fell swoop
	T lwrSource = source;
	T lwrPattern = pattern;
	StrToLower(lwrSource);
	StrToLower(lwrPattern);

	return lwrSource.find(lwrPattern, offset);
}

inline string::size_type strfind(const char * source,
																 const char * pattern,
																 string::size_type offset = 0)
{
	return strfind(string(source), string(pattern), offset);
}

inline string::size_type strfind(const wchar_t * source,
																 const wchar_t * pattern,
																 string::size_type offset = 0)
{
	return strfind(wstring(source), wstring(pattern), offset);
}

inline string::size_type strfind(const string & source,
																 const char * pattern,
																 string::size_type offset = 0)
{
	return strfind(source, string(pattern), offset);
}

inline string::size_type strfind(const wstring & source,
																 const wchar_t * pattern,
																 string::size_type offset = 0)
{
	return strfind(source, wstring(pattern), offset);
}
										 
#endif


// NOTE: this function will convert wstring to string or vice-versa, but
// non ascii wide characters are truncated!

inline string ascii(const wstring & arSource)
{
	// NOTE: this isn't really the fastest way to do a string conversion, but
	// it's convenient
	string buffer;
	wstring::const_iterator it;
	for (it = arSource.begin(); it != arSource.end(); it++)
		buffer += (char)*it;
	return buffer;
}

class mtstring : public string {

public:
	mtstring(): string() {}
	mtstring(string& aStr) : string(aStr) {}
	mtstring(const mtstring& aStr) : string(aStr) {}
	mtstring(const string& aStr) : string(aStr) {}
	mtstring(const char* aStr) : string(aStr) {}

	operator const char*() const
	{
		return c_str();
	}

	void tolower() { StrToLower(*this); }
	void toupper() { StrToUpper(*this); }

};


class mtwstring : public wstring {

public:
	mtwstring() : wstring() {}
	mtwstring(const mtwstring& aStr) : wstring(aStr) {}
	mtwstring(const wchar_t* aStr) : wstring(aStr) {}

	operator const wchar_t*() const
	{
		return c_str();
	}

	operator const string() const
	{
		return ascii(c_str());
	}

	void tolower() { StrToLower(*this); }
	void toupper() { StrToUpper(*this); }
};

template<class TVec>
void Tokenize(TVec& aTokenizedList,const mtstring& aStr)
{
#ifdef WIN32
	TVec::size_type aCurrentPos = 0;
	TVec::size_type aLoc;
#elif UNIX
	// mef: gcc seems to be unhappy with TVec::size_type
	long aCurrentPos = 0;
	long aLoc;
#endif

	while((aLoc = aStr.find("\\",aCurrentPos)) != string::npos) {
		string& aSubStr = aStr.substr(aCurrentPos,aLoc-aCurrentPos);
		aTokenizedList.push_back(aSubStr);
		aCurrentPos = aLoc + 1;
	}
	string& aSubStr = aStr.substr(aCurrentPos,aStr.length()-aCurrentPos);
	aTokenizedList.push_back(aSubStr);
}
// used to delete elements for a vector
// 
// for example:
// vector<X *> mylist;
// for_each(mylist.begin(), mylist.end(), destroy<X *>)
//
template<class T> void destroyPtr(T * apPtr)
{ delete apPtr; }

// push the contents of one container into another
#ifdef WIN32
template<class SRCIT, class DEST>
void inline push_back(SRCIT item, SRCIT end, DEST dest)
{
	for (; item != end; ++item)
		dest.push_back(*item);
}
#elif UNIX
template<class SRCIT, class DEST>
void inline push_back(SRCIT item, SRCIT end, DEST dest);
#endif


// Pass this in as the third template argument to a map or multimap with a string 
// key to make the key evaluation case insensitive
template <class T>
class basic_string_less_nocase : public std :: binary_function<T, T, bool> 
{
public:
	bool operator()(const T& x, const T& y) const
	{
		return (strcasecmp(x, y) < 0) ? true : false;		
	}
};

typedef basic_string_less_nocase<string> string_less_nocase;
typedef basic_string_less_nocase<wstring> wstring_less_nocase;


//////////////////////////////////////////////////////////////////////////////
// helper conversion routines


BOOL ConvertStringToMD5(const char* apString, string& arHash);


#endif /* _STDUTILS_H */

