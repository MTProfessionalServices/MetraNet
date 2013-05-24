// PhoneLookup.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//		To build a separate proxy/stub DLL, 
//		run nmake -f PhoneLookupps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include "initguid.h"
#include "PhoneLookup.h"

#include "PhoneLookup_i.c"
#include "PhoneNumberParser.h"
#include "MTPhoneDevice.h"
#include "MTEnumPhoneDevices.h"
#include "MTCountry.h"
#include "MTEnumCountries.h"
#include "MTRegion.h"
#include "MTEnumRegions.h"
#include "MTExchange.h"
#include "MTEnumExchanges.h"


CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
	OBJECT_ENTRY(CLSID_PhoneNumberParser, CPhoneNumberParser)
	OBJECT_ENTRY(CLSID_MTPhoneDevice, CMTPhoneDevice)
	OBJECT_ENTRY(CLSID_MTEnumPhoneDevices, CMTEnumPhoneDevices)
	OBJECT_ENTRY(CLSID_MTCountry, CMTCountry)
	OBJECT_ENTRY(CLSID_MTEnumCountries, CMTEnumCountries)
	OBJECT_ENTRY(CLSID_MTRegion, CMTRegion)
	OBJECT_ENTRY(CLSID_MTEnumRegions, CMTEnumRegions)
	OBJECT_ENTRY(CLSID_MTExchange, CMTExchange)
	OBJECT_ENTRY(CLSID_MTEnumExchanges, CMTEnumExchanges)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
	if (dwReason == DLL_PROCESS_ATTACH)
	{
		_Module.Init(ObjectMap, hInstance);
		DisableThreadLibraryCalls(hInstance);
	}
	else if (dwReason == DLL_PROCESS_DETACH)
		_Module.Term();
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
	_Module.UnregisterServer();
	return S_OK;
}


