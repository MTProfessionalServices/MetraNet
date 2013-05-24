// Counter.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f Counterps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>

#include "Counter.h"
#include "MTCounter.h"
#include "MTCounterType.h"
#include "MTCounterParameter.h"
#include "MTCounterParameterPredicate.h"


#include "Counter_i.c"


CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_MTCounter, CMTCounter)
OBJECT_ENTRY(CLSID_MTCounterParameter, CMTCounterParameter)
OBJECT_ENTRY(CLSID_MTCounterType, CMTCounterType)
OBJECT_ENTRY(CLSID_MTCounterParameterPredicate, CMTCounterParameterPredicate)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTCOUNTERLib);
        DisableThreadLibraryCalls(hInstance);
    }
    else if (dwReason == DLL_PROCESS_DETACH)
		{
       _Module.Term();
		}
    return TRUE;    // ok
}

/////////////////////////////////////////////////////////////////////////////
// Used to determine whether the DLL can be unloaded by OLE

STDAPI DllCanUnloadNow(void)
{
    return (_Module.GetLockCount()==0) ? S_OK : S_FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// Returns a class factory to create an object of the requested type

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID* ppv)
{
    return _Module.GetClassObject(rclsid, riid, ppv);
}

/////////////////////////////////////////////////////////////////////////////
// DllRegisterServer - Adds entries to the system registry

STDAPI DllRegisterServer(void)
{
    // registers object, typelib and all interfaces in typelib
    return _Module.RegisterServer(TRUE);
}

/////////////////////////////////////////////////////////////////////////////
// DllUnregisterServer - Removes entries from the system registry

STDAPI DllUnregisterServer(void)
{
    return _Module.UnregisterServer(TRUE);
}

const wchar_t * OpToString(MTOperatorType aOp)
{
	const wchar_t * test;
	switch (aOp)
	{
	case OPERATOR_TYPE_EQUAL:
		test = L"="; break;
	case OPERATOR_TYPE_NOT_EQUAL:
		test = L"!="; break;
	case OPERATOR_TYPE_GREATER:
		test = L">"; break;
	case OPERATOR_TYPE_GREATER_EQUAL:
		test = L">="; break;
	case OPERATOR_TYPE_LESS:
		test = L"<"; break;
	case OPERATOR_TYPE_LESS_EQUAL:
		test = L"<="; break;

	case OPERATOR_TYPE_LIKE:
	case OPERATOR_TYPE_LIKE_W:
	default:
		// TODO:
		ASSERT(0);
		return NULL;
	}

	return test;
}

MTOperatorType StringToOp(_bstr_t opStr)
{
	MTOperatorType test;
	if (opStr == _bstr_t("<"))
		test = OPERATOR_TYPE_LESS;
	else if (opStr == _bstr_t("<="))
		test = OPERATOR_TYPE_LESS_EQUAL;
	else if (opStr == _bstr_t("="))
		test = OPERATOR_TYPE_EQUAL;
	else if (opStr == _bstr_t(">="))
		test = OPERATOR_TYPE_GREATER_EQUAL;
	else if (opStr == _bstr_t(">"))
		test = OPERATOR_TYPE_GREATER;
	else if (opStr == _bstr_t("!="))
		test = OPERATOR_TYPE_NOT_EQUAL;
	else
		ASSERT(0);

	return test;
}

// method used when querying for IID_NULL
HRESULT WINAPI _This(void* pv,REFIID iid,void** ppvObject,DWORD)
{
  ATLASSERT(iid == IID_NULL);
  *ppvObject = pv;
  return S_OK;
}