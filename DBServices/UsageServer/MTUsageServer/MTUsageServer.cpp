// MTUsageServer.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//		To build a separate proxy/stub DLL, 
//		run nmake -f MTUsageServerps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include "initguid.h"
#include "MTUsageServer.h"

#undef min
#undef max

#include "MTUsageServer_i.c"
#include "COMUsageInterval.h"
#include "COMUsageIntervalColl.h"
#include "COMAccountUsageMap.h"
#include "COMUsageCycle.h"
#include "COMUsageCycleTypes.h"
#include "COMUsageServer.h"
#include "COMUsageCycleColl.h"
#include "COMUsageCyclePropertyColl.h"
#include "MTUsageServerMaintenance.h"
#include "MTEventRunStatus.h"


CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
	OBJECT_ENTRY(CLSID_COMUsageInterval, CCOMUsageInterval)
	OBJECT_ENTRY(CLSID_COMUsageIntervalColl, CCOMUsageIntervalColl)
	OBJECT_ENTRY(CLSID_COMAccountUsageMap, CCOMAccountUsageMap)
	OBJECT_ENTRY(CLSID_COMUsageCycle, CCOMUsageCycle)
	OBJECT_ENTRY(CLSID_COMUsageCycleTypes, CCOMUsageCycleTypes)
	OBJECT_ENTRY(CLSID_COMUsageServer, CCOMUsageServer)
	OBJECT_ENTRY(CLSID_COMUsageCycleColl, CCOMUsageCycleColl)
	OBJECT_ENTRY(CLSID_COMUsageCyclePropertyColl, CCOMUsageCyclePropertyColl)
	OBJECT_ENTRY(CLSID_MTUsageServerMaintenance, CMTUsageServerMaintenance)
	OBJECT_ENTRY(CLSID_MTEventRunStatus, CMTEventRunStatus)
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


