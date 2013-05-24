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

// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f MTYAACps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>
#include "MTYAAC.h"

#include "MTYAAC_i.c"
#include "IMTYAAC_i.c"
#include "YAAC.h"
#include "MTAccountTemplate.h"
#include "MTPaymentMgr.h"
#include "MTAncestorMgr.h"
#include "MTAccountHierarchySlice.h"
#include "MTPaymentSlice.h"
#include "MTPaymentAssociation.h"
#include "MTAccountTemplateSubscriptions.h"
#include "MTAccountTemplateSubscription.h"
#include "MTAccountTemplateProperty.h"
#include "MTAccountTemplateProperties.h"
#include "MTAccountCatalog.h"
#include "AccountMetaData.h"

namespace YAACLog {
	char pYAACLog[] = "YAAC";
};

MTAutoInstance<MTAutoLoggerImpl<YAACLog::pYAACLog> > mYAACLogger;

HRESULT returnYAACError(const _com_error& err)
{	
	ErrorObject* errObj = CreateErrorFromComError(err);
	mYAACLogger->LogErrorObject(errObj->IsUserError() ? LOG_DEBUG : LOG_ERROR, errObj);
	delete errObj;
	return ReturnComError(err);
}

HRESULT returnYAACError(const _com_error& err,const char* pStr,MTLogLevel aLogLevel)
{
	mYAACLogger->LogThis(aLogLevel,pStr);
	return ReturnComError(err);
}

HRESULT returnYAACError(const _com_error& err,const char* pStr,const char* pExtraInfo, MTLogLevel aLogLevel)
{
	string buffer;
	buffer = string(pStr) + string(pExtraInfo);  
	mYAACLogger->LogThis(aLogLevel,buffer.c_str());
	return ReturnComError(err);
}

HRESULT returnYAACError(const _com_error& err,const char* pError,MTYAACLib::IMTYAACPtr aYAAC,MTLogLevel aLogLevel)
{
	mYAACLogger->LogVarArgs(aLogLevel,"%s, Account is %d",pError,aYAAC->GetAccountID());
	return ReturnComError(err);
}


HRESULT LogYAACError(const char* pError,MTLogLevel aLogLevel)
{
	mYAACLogger->LogThis(aLogLevel,pError);
	return S_OK;
}

HRESULT LogYAACError(const char* pError,MTYAACLib::IMTYAACPtr aYAAC,MTLogLevel aLogLevel)
{
	mYAACLogger->LogVarArgs(aLogLevel,"%s, Account is %d",pError,aYAAC->GetAccountID());
	return S_OK;
}



CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_MTYAAC, CMTYAAC)
OBJECT_ENTRY(CLSID_MTAccountTemplate, CMTAccountTemplate)
OBJECT_ENTRY(CLSID_MTPaymentMgr, CMTPaymentMgr)
OBJECT_ENTRY(CLSID_MTAncestorMgr, CMTAncestorMgr)
OBJECT_ENTRY(CLSID_MTAccountHierarchySlice, CMTAccountHierarchySlice)
OBJECT_ENTRY(CLSID_MTPaymentSlice, CMTPaymentSlice)
OBJECT_ENTRY(CLSID_MTPaymentAssociation, CMTPaymentAssociation)
OBJECT_ENTRY(CLSID_MTAccountTemplateSubscriptions, CMTAccountTemplateSubscriptions)
OBJECT_ENTRY(CLSID_MTAccountTemplateSubscription, CMTAccountTemplateSubscription)
OBJECT_ENTRY(CLSID_MTAccountTemplateProperty, CMTAccountTemplateProperty)
OBJECT_ENTRY(CLSID_MTAccountTemplateProperties, CMTAccountTemplateProperties)
OBJECT_ENTRY(CLSID_MTAccountCatalog, CMTAccountCatalog)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTYAACLib);
        DisableThreadLibraryCalls(hInstance);
    }
    else if (dwReason == DLL_PROCESS_DETACH)
    {	CAccountMetaData::DeleteInstance();
      _Module.Term();
    }
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



