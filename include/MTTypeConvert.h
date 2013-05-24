#if !defined _MTTYPECONVERT_H
#define _MTTYPECONVERT_H

#include <metra.h>
#include <string>

#ifdef WIN32
#include <comdef.h>
#endif

using std::wstring;

class MTTypeConvert
{
public:
	static BOOL ConvertToBoolean(const wstring & arValue, BOOL * apConverted);

#ifdef WIN32
	static _bstr_t      BoolToString(VARIANT_BOOL aBoolValue);
	static VARIANT_BOOL StringToBool(const _bstr_t& aStringValue);
#endif

};

#endif



