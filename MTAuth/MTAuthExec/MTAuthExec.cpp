// MTAuthExec.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f MTAuthExecps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>
#include "MTAuthExec.h"

#include "MTAuthExec_i.c"
#include "MTPrincipalPolicyReader.h"
#include "MTSecurityContextReader.h"
#include "MTCompositeCapabilityTypeReader.h"
#include "MTAtomicCapabilityTypeReader.h"
#include "MTCompositeCapabilityTypeWriter.h"
#include "MTAtomicCapabilityTypeWriter.h"
#include "MTSecurityReader.h"
#include "MTPrincipalPolicyWriter.h"
#include "MTAccessTypeCapabilityWriter.h"
#include "MTPathCapabilityWriter.h"
#include "MTRoleReader.h"
#include "MTRoleWriter.h"
#include "MTCapabilityWriter.h"
#include "MTEnumTypeCapabilityWriter.h"
#include "MTDecimalCapabilityWriter.h"
#include "MTBatchAuthCheckReader.h"


MTOperatorType StringToOp(_bstr_t opStr)
{
	MTOperatorType test;
	if (opStr == _bstr_t("<"))
		test = OPERATOR_TYPE_LESS;
	else if (opStr == _bstr_t("<="))
		test = OPERATOR_TYPE_LESS_EQUAL;
	else if (opStr == _bstr_t("="))
		test = OPERATOR_TYPE_EQUAL;
	else if (opStr == _bstr_t(">="))
		test = OPERATOR_TYPE_GREATER_EQUAL;
	else if (opStr == _bstr_t(">"))
		test = OPERATOR_TYPE_GREATER;
	else if (opStr == _bstr_t("!="))
		test = OPERATOR_TYPE_NOT_EQUAL;
	else
		ASSERT(0);

	return test;
}

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_MTPrincipalPolicyReader, CMTPrincipalPolicyReader)
OBJECT_ENTRY(CLSID_MTSecurityContextReader, CMTSecurityContextReader)
OBJECT_ENTRY(CLSID_MTCompositeCapabilityTypeReader, CMTCompositeCapabilityTypeReader)
OBJECT_ENTRY(CLSID_MTAtomicCapabilityTypeReader, CMTAtomicCapabilityTypeReader)
OBJECT_ENTRY(CLSID_MTCompositeCapabilityTypeWriter, CMTCompositeCapabilityTypeWriter)
OBJECT_ENTRY(CLSID_MTAtomicCapabilityTypeWriter, CMTAtomicCapabilityTypeWriter)
OBJECT_ENTRY(CLSID_MTSecurityReader, CMTSecurityReader)
OBJECT_ENTRY(CLSID_MTPrincipalPolicyWriter, CMTPrincipalPolicyWriter)
OBJECT_ENTRY(CLSID_MTAccessTypeCapabilityWriter, CMTAccessTypeCapabilityWriter)
OBJECT_ENTRY(CLSID_MTPathCapabilityWriter, CMTPathCapabilityWriter)
OBJECT_ENTRY(CLSID_MTRoleReader, CMTRoleReader)
OBJECT_ENTRY(CLSID_MTRoleWriter, CMTRoleWriter)
OBJECT_ENTRY(CLSID_MTCapabilityWriter, CMTCapabilityWriter)
OBJECT_ENTRY(CLSID_MTEnumTypeCapabilityWriter, CMTEnumTypeCapabilityWriter)
OBJECT_ENTRY(CLSID_MTDecimalCapabilityWriter, CMTDecimalCapabilityWriter)
OBJECT_ENTRY(CLSID_MTBatchAuthCheckReader, CMTBatchAuthCheckReader)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTAUTHEXECLib);
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

