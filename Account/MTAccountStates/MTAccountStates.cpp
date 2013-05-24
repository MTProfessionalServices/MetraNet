/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"
#include <metralite.h>
#include "resource.h"
#include <initguid.h>
#include "MTAccountStates.h"

#include "MTAccountStateInterface_i.c"
#include "MTAccountStates_i.c"

#include "MTAccountStateManager.h"
#include "MTAccountStateInterface.h"
#include "Suspended.h"
#include "PendingActiveApproval.h"
#include "Active.h"
#include "PendingFinalBill.h"
#include "Closed.h"
#include "Archived.h"
#include "MTAccountStateMetaData.h"
#include "MTState.h"


CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_MTAccountStateManager, CMTAccountStateManager)
OBJECT_ENTRY(CLSID_Suspended, CSuspended)
OBJECT_ENTRY(CLSID_PendingActiveApproval, CPendingActiveApproval)
OBJECT_ENTRY(CLSID_Active, CActive)
OBJECT_ENTRY(CLSID_PendingFinalBill, CPendingFinalBill)
OBJECT_ENTRY(CLSID_Closed, CClosed)
OBJECT_ENTRY(CLSID_Archived, CArchived)
OBJECT_ENTRY(CLSID_MTAccountStateMetaData, CMTAccountStateMetaData)
OBJECT_ENTRY(CLSID_MTState, CMTState)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTACCOUNTSTATESLib);
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


