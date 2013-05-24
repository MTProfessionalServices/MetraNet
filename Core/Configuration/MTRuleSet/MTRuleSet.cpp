// MTRuleSet.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//		To build a separate proxy/stub DLL, 
//		run nmake -f MTRuleSetps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include "initguid.h"
#include "MTRuleSet.h"

#include "MTRuleSet_i.c"
#include "IMTRuleSet_i.c"
#include "MTRuleSetDef.h"
#include "MTRule.h"
#include "MTCondition.h"
#include "MTAssignmentAction.h"
#include "MTSimpleCondition.h"
#include "MTConditionSet.h"
#include "MTActionSet.h"


CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
	OBJECT_ENTRY(CLSID_MTRule, CMTRule)
	OBJECT_ENTRY(CLSID_MTRuleSet, CMTRuleSet)
	OBJECT_ENTRY(CLSID_MTCondition, CMTCondition)
	OBJECT_ENTRY(CLSID_MTAssignmentAction, CMTAssignmentAction)
	OBJECT_ENTRY(CLSID_MTSimpleCondition, CMTSimpleCondition)
	OBJECT_ENTRY(CLSID_MTConditionSet, CMTConditionSet)
	OBJECT_ENTRY(CLSID_MTActionSet, CMTActionSet)
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


