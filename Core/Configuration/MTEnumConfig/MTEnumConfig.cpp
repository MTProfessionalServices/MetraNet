/**************************************************************************
* Copyright 1997-2000 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Boris Partensky
* $Header$
* 
***************************************************************************/


// MTEnumConfig.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f MTEnumConfigps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>
//#include <IMTEnumConfig_i.c>
#include "MTEnumConfig.h"


#include "IMTEnumConfig_i.c"
#include "MTEnumConfig_i.c"
//#include "EnumConfig.h"
#include "MTEnumType.h"
#include "MTEnumerator.h"
#include "MTEnumeratorCollection.h"
#include <MTConfigPropSet_i.c>
#include "MTEnumTypeCollection.h"
#include "MTEnumSpace.h"
#include "MTEnumSpaceCollection.h"


CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
	OBJECT_ENTRY(CLSID_EnumConfig, CEnumConfig)
	OBJECT_ENTRY(CLSID_MTEnumType, CMTEnumType)
	OBJECT_ENTRY(CLSID_MTEnumerator, CMTEnumerator)
	OBJECT_ENTRY(CLSID_MTEnumeratorCollection, CMTEnumeratorCollection)
	OBJECT_ENTRY(CLSID_MTEnumTypeCollection, CMTEnumTypeCollection)
	OBJECT_ENTRY(CLSID_MTEnumSpace, CMTEnumSpace)
	OBJECT_ENTRY(CLSID_MTEnumSpaceCollection, CMTEnumSpaceCollection)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTENUMCONFIGLib);
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


