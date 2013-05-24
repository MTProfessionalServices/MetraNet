// Rowset.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//		To build a separate proxy/stub DLL, 
//		run nmake -f Rowsetps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include "initguid.h"
#include "MTFilterItemImpl.h"

#include "Rowset.h"
#include "Rowset_i.c"

#include <rowsetinterfaces_i.c>
#include <MTFilter_i.c>
#include "MTInMemRowset.h"
#include "MTSQLRowset.h"
#include "MTXMLRowset.h"
#include "MTFilterImpl.h"



CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
	OBJECT_ENTRY(CLSID_MTInMemRowset, CMTInMemRowset)
	OBJECT_ENTRY(CLSID_MTSQLRowset, CMTSQLRowset)
	OBJECT_ENTRY(CLSID_MTXMLRowset, MTXMLRowset)
	OBJECT_ENTRY(CLSID_MTDataFilter, CMTFilter)
	OBJECT_ENTRY(CLSID_MTFilterItem, CMTFilterItem)
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


