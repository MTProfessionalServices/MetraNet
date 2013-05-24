// MTUIPerfMon.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f MTUIPerfMonps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>
#include "MTUIPerfMon.h"

#include "MTUIPerfMon_i.c"
#include "TimerManager.h"
#include <mtcomerr.h>

//////////////////////////////////////////////////////////////////////////////
//  Error Logging                                                           //
//////////////////////////////////////////////////////////////////////////////
namespace UIPerfMonLog {
	char pUIPerfMonLog[] = "UI Performance Manager";
};

MTAutoInstance<MTAutoLoggerImpl<UIPerfMonLog::pUIPerfMonLog> > mUIPerfMonLogger;

HRESULT returnUIPerfMonError(const _com_error& err)
{	
	ErrorObject * errObj = CreateErrorFromComError(err);
	mUIPerfMonLogger->LogErrorObject(errObj->IsUserError() ? LOG_DEBUG : LOG_ERROR, errObj);
	return ReturnComError(err);
}

HRESULT returnUIPerfMonError(const _com_error &err, const char *pStr, MTLogLevel aLogLevel)
{
	mUIPerfMonLogger->LogThis(aLogLevel,pStr);
	return ReturnComError(err);
}
//////////////////////////////////////////////////////////////////////////////

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_TimerManager, CTimerManager)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTUIPERFMONLib);
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


