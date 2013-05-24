// MTAccount.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f MTAccountps.mk in the project directory.

#include "StdAfx.h"

#include <comdef.h>

#include "resource.h"
#include <initguid.h>
#include "MTAccount.h"


#include "MTAccountAdapter_i.c"
#include "MTAccount_i.c"
#include "MTAccountProperty_i.c"
#include "MTAccountPropertyCollection_i.c"
#include "MTSearchResultCollection_i.c"

#include "MTAccountProperty.h"
#include "MTAccountPropertyCollection.h"
#include "MTSearchResultCollection.h"
#include "MTAccountFinder.h"
#include "MTAccountAdapter.h"
#include "MTLDAPAdapter.h"
#include "MTSQLAdapter.h"
#include "MTDB2Adapter.h"
#include "MTAccountServer.h"

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_MTLDAPAdapter, CMTLDAPAdapter)
OBJECT_ENTRY(CLSID_MTSQLAdapter, CMTSQLAdapter)
OBJECT_ENTRY(CLSID_MTDB2Adapter, CMTDB2Adapter)
OBJECT_ENTRY(CLSID_MTAccountProperty, CMTAccountProperty)
OBJECT_ENTRY(CLSID_MTAccountPropertyCollection, CMTAccountPropertyCollection)
OBJECT_ENTRY(CLSID_MTAccountServer, CMTAccountServer)
OBJECT_ENTRY(CLSID_MTSearchResultCollection, CMTSearchResultCollection)
OBJECT_ENTRY(CLSID_MTAccountFinder, CMTAccountFinder)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTACCOUNTLib);
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


