// Subscription.cpp : Implementation of DLL Exports.

#include "StdAfx.h"
#include "resource.h"
#include "Subscription.h"
#include "Subscription_i.c"

class CSubscriptionModule : public CAtlDllModuleT< CSubscriptionModule >
{
public :
	DECLARE_LIBID(LIBID_SubscriptionLib)
	DECLARE_REGISTRY_APPID_RESOURCEID(IDR_SUBSCRIPTION, "{F100A019-E82D-4665-9043-2B43BBB83FC9}")
};

CSubscriptionModule _AtlModule;


// DLL Entry Point
extern "C" BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
{
	hInstance;
    return _AtlModule.DllMain(dwReason, lpReserved); 
}


// Used to determine whether the DLL can be unloaded by OLE
STDAPI DllCanUnloadNow(void)
{
    return _AtlModule.DllCanUnloadNow();
}


// Returns a class factory to create an object of the requested type
STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID* ppv)
{
    return _AtlModule.DllGetClassObject(rclsid, riid, ppv);
}


// DllRegisterServer - Adds entries to the system registry
STDAPI DllRegisterServer(void)
{
    // registers object, typelib and all interfaces in typelib
    HRESULT hr = _AtlModule.DllRegisterServer();
	return hr;
}


// DllUnregisterServer - Removes entries from the system registry
STDAPI DllUnregisterServer(void)
{
	HRESULT hr = _AtlModule.DllUnregisterServer();
	return hr;
}
