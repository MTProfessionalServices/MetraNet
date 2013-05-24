// MTStdUsageCycle.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f MTStdUsageCycleps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>
#include "MTStdUsageCycle.h"

#include "MTUsageCycle_i.c"
#include "MTStdUsageCycle_i.c"
#include "MTStdMonthly.h"
#include "MTStdOnDemand.h"
#include "MTStdDaily.h"
#include "MTStdWeekly.h"
#include "MTStdBiWeekly.h"
#include "MTStdSemiMonthly.h"
#include "MTStdQuarterly.h"
#include "MTStdSemiAnnually.h"
#include "MTStdAnnually.h"


CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_MTStdMonthly, CMTStdMonthly)
OBJECT_ENTRY(CLSID_MTStdOnDemand, CMTStdOnDemand)
OBJECT_ENTRY(CLSID_MTStdDaily, CMTStdDaily)
OBJECT_ENTRY(CLSID_MTStdWeekly, CMTStdWeekly)
OBJECT_ENTRY(CLSID_MTStdBiWeekly, CMTStdBiWeekly)
OBJECT_ENTRY(CLSID_MTStdSemiMonthly, CMTStdSemiMonthly)
OBJECT_ENTRY(CLSID_MTStdQuarterly, CMTStdQuarterly)
OBJECT_ENTRY(CLSID_MTStdSemiAnnually, CMTStdSemiAnnually)
OBJECT_ENTRY(CLSID_MTStdAnnually, CMTStdAnnually)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTSTDUSAGECYCLELib);
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
    return _Module.UnregisterServer(TRUE);
}


