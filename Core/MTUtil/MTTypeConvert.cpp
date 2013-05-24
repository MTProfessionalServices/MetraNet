#include "MTTypeConvert.h"
#include "stdutils.h"

struct BOOLKeyword
{
	const wchar_t * name;
	BOOL value;
};

static int BOOLCompare(const void *arg1, const void *arg2)
{
	BOOLKeyword * typekey1 = (BOOLKeyword *) arg1;
	BOOLKeyword * typekey2 = (BOOLKeyword *) arg2;

	return mtwcscasecmp(typekey1->name, typekey2->name);
}

BOOL MTTypeConvert::ConvertToBoolean(const wstring & arValue, BOOL * apConverted)
{
	static BOOLKeyword keywords[] =
	{
		{ L"0",			FALSE		},
		{ L"1",			TRUE		},
		{ L"F",			FALSE		},
		{ L"FALSE",	FALSE		},
		{ L"N",			FALSE		},
		{ L"NO",		FALSE		},
		{ L"T",			TRUE		},
		{ L"TRUE",	TRUE		},
		{ L"Y",			TRUE		},
		{ L"YES",		TRUE		}
	};

	// bool value doesn't matter
	BOOLKeyword key = { arValue.c_str(), FALSE };

	// comparison function is case insensitive
	BOOLKeyword * result = (BOOLKeyword *) bsearch((char *) &key, (char *) keywords,
		sizeof(keywords) / sizeof(keywords[0]),
		sizeof(keywords[0]),
		BOOLCompare);

	if (result)
	{
		*apConverted = result->value;
		return TRUE;
	}
	else
		return FALSE;
}

#ifdef WIN32

_bstr_t MTTypeConvert::BoolToString(VARIANT_BOOL aBoolValue)
{
	if (aBoolValue)
		return "Y";
	else
		return "N";
}

VARIANT_BOOL MTTypeConvert::StringToBool(const _bstr_t& aStringValue)
{
	BOOL boolValue = FALSE;

	const wchar_t* wcharPtr = aStringValue;
	ConvertToBoolean(wcharPtr, &boolValue);
	
	if (boolValue)
		return VARIANT_TRUE;
	else
		return VARIANT_FALSE;
}

#endif
