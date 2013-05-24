// COMKiosk.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//		To build a separate proxy/stub DLL, 
//		run nmake -f COMKioskps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include "initguid.h"
#include "COMKiosk.h"

#include "COMKiosk_i.c"
#include "COMKioskGate.h"
#include "COMVendorKiosk.h"
#include "COMUserConfig.h"
#include "COMKioskAuth.h"
#include "COMSiteConfig.h"
#include "COMCredentials.h"
#include "COMAccountMapper.h"
#include "COMAccount.h"
#include "MTSiteCollection.h"
#include "MTProductCollection.h"
#include "MTProductPageMap.h"


CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
	OBJECT_ENTRY(CLSID_COMKioskGate, CCOMKioskGate)
	OBJECT_ENTRY(CLSID_COMVendorKiosk, CCOMVendorKiosk)
	OBJECT_ENTRY(CLSID_COMUserConfig, CCOMUserConfig)
	OBJECT_ENTRY(CLSID_COMKioskAuth, CCOMKioskAuth)
	OBJECT_ENTRY(CLSID_COMSiteConfig, CCOMSiteConfig)
	OBJECT_ENTRY(CLSID_COMCredentials, CCOMCredentials)
	OBJECT_ENTRY(CLSID_COMAccountMapper, CCOMAccountMapper)
	OBJECT_ENTRY(CLSID_COMAccount, CCOMAccount)
	OBJECT_ENTRY(CLSID_MTSiteCollection, CMTSiteCollection)
	OBJECT_ENTRY(CLSID_MTProductCollection, CMTProductCollection)
	OBJECT_ENTRY(CLSID_MTProductPageMap, CMTProductPageMap)
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


