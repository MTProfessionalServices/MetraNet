// AudioConfMeterTestLib.cpp : Implementation of DLL Exports.

#include "StdAfx.h"
#include "resource.h"
#include "AudioConfMeterTestLib.h"
#include "AudioConfMeterTestLib_i.c"

class CAudioConfMeterTestLibModule : public CAtlDllModuleT< CAudioConfMeterTestLibModule >
{
public :
	DECLARE_LIBID(LIBID_AudioConfMeterTestLibLib)
	DECLARE_REGISTRY_APPID_RESOURCEID(IDR_AUDIOCONFMETERTESTLIB, "{6BFEC15E-4CBF-4FDB-842F-DE22C8729C81}")
};

CAudioConfMeterTestLibModule _AtlModule;


#ifdef _MANAGED
#pragma managed(push, off)
#endif

// DLL Entry Point
extern "C" BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
{
	hInstance;
    return _AtlModule.DllMain(dwReason, lpReserved); 
}

#ifdef _MANAGED
#pragma managed(pop)
#endif




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

