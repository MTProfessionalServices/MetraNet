/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* 
***************************************************************************/

// MTAuth.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f MTAuthps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>
#include "MTAuth.h"
#include <autologger.h>
#include "IMTAuth_i.c"
#include "MTAuth_i.c"
#include "IMTSecurity_i.c"
#include "MTCompositeCapabilityBase.h"
#include "MTCompositeCapabilityType.h"
#include "MTAtomicCapabilityType.h"

#include "MTPathCapability.h"
//#include "MTAccessTypeCapability.h"
#include "MTLoginContext.h"
#include "MTSecurityContext.h"
#include "MTPrincipalPolicy.h"
#include "MTRole.h"
#include "MTSecurity.h"
#include "MTAtomicCapabilityBase.h"
#include "MTPathParameter.h"
#include "MTSessionContext.h"
#include "MTEnumTypeCapability.h"
#include "MTDecimalCapability.h"
#include "MTStringCollectionCapability.h"

namespace AuthLog {
	char pAuthLog[] = "MTAuth";
};

MTAutoInstance<MTAutoLoggerImpl<AuthLog::pAuthLog> > mLogger;

HRESULT WINAPI _This(void* pv,REFIID iid,void** ppvObject,DWORD)
{
  ATLASSERT(iid == IID_NULL);
  *ppvObject = pv;
  return S_OK;
}

HRESULT LogAndReturnAuthError(const _com_error& err)
{	
	ErrorObject* errObj = CreateErrorFromComError(err);
	mLogger->LogErrorObject(errObj->IsUserError() ? LOG_DEBUG : LOG_ERROR, errObj);
	delete errObj;
	return ReturnComError(err);
}

HRESULT LogAndReturnAuthError(const _com_error& err,const char* pStr)
{
	mLogger->LogThis(LOG_ERROR,pStr);
	return ReturnComError(err);
}

HRESULT LogAuthError(const char* pStr)
{
	mLogger->LogThis(LOG_ERROR,pStr);
	return S_OK;
}


HRESULT LogAuthDebug(const char* pStr)
{
	mLogger->LogThis(LOG_DEBUG,pStr);
	return S_OK;
}

HRESULT LogAuthInfo(const char* pStr)
{
	mLogger->LogThis(LOG_INFO,pStr);
	return S_OK;
}
HRESULT LogAuthWarning(const char* pStr)
{
	mLogger->LogThis(LOG_WARNING,pStr);
	return S_OK;
}

bool ValidateBooleanTag(_bstr_t& aTag)
{
  return  (stricmp((char*)aTag, "Y") == 0 ||
          stricmp((char*)aTag, "N") == 0);
}




VARIANT_BOOL ConvertBooleanTag(_bstr_t& aTag)
{
  return  (stricmp((char*)aTag, "Y") == 0 ) ? VARIANT_TRUE : VARIANT_FALSE;
}


const wchar_t * OpToString(MTOperatorType aOp)
{
	const wchar_t * test;
	switch (aOp)
	{
	case OPERATOR_TYPE_EQUAL:
		test = L"="; break;
	case OPERATOR_TYPE_NOT_EQUAL:
		test = L"!="; break;
	case OPERATOR_TYPE_GREATER:
		test = L">"; break;
	case OPERATOR_TYPE_GREATER_EQUAL:
		test = L">="; break;
	case OPERATOR_TYPE_LESS:
		test = L"<"; break;
	case OPERATOR_TYPE_LESS_EQUAL:
		test = L"<="; break;

	case OPERATOR_TYPE_LIKE:
	case OPERATOR_TYPE_LIKE_W:
	default:
		// TODO:
		ASSERT(0);
		return NULL;
	}

	return test;
}

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
OBJECT_ENTRY(CLSID_MTCompositeCapabilityBase, CMTCompositeCapabilityBase)
OBJECT_ENTRY(CLSID_MTPathCapability, CMTPathCapability)
OBJECT_ENTRY(CLSID_MTDecimalCapability, CMTDecimalCapability)
OBJECT_ENTRY(CLSID_MTEnumTypeCapability, CMTEnumTypeCapability)
OBJECT_ENTRY(CLSID_MTLoginContext, CMTLoginContext)
OBJECT_ENTRY_NON_CREATEABLE(CMTSecurityContext)
OBJECT_ENTRY(CLSID_MTAtomicCapabilityType, CMTAtomicCapabilityType)
OBJECT_ENTRY(CLSID_MTCompositeCapabilityType, CMTCompositeCapabilityType)
//OBJECT_ENTRY_NON_CREATEABLE(CMTPrincipalPolicy)
OBJECT_ENTRY(CLSID_MTPrincipalPolicy, CMTPrincipalPolicy)
OBJECT_ENTRY_NON_CREATEABLE(CMTRole)
OBJECT_ENTRY(CLSID_MTSecurity, CMTSecurity)
OBJECT_ENTRY(CLSID_MTAtomicCapabilityBase, CMTAtomicCapabilityBase)
OBJECT_ENTRY(CLSID_MTPathParameter, CMTPathParameter)
OBJECT_ENTRY(CLSID_MTSessionContext, CMTSessionContext)
OBJECT_ENTRY(CLSID_MTStringCollectionCapability, CMTStringCollectionCapability)

END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTAUTHLib);
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

STDMETHODIMP CheckPrincipalAuth2Auth(IMTSessionContext *aCtx, IMTSecurityPrincipal *aPrincipal, char* aUmbrellaAccessLevel)
{
  MTAUTHLib::IMTSessionContextPtr ctx = aCtx;
  MTAUTHLib::IMTSecurityContextPtr secctx = ctx->SecurityContext;
  MTAUTHLib::IMTSecurityPrincipalPtr principal = aPrincipal;
  AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
  
  MTAUTHLib::IMTSecurityPtr security(__uuidof(MTAUTHLib::MTSecurity));
  MTAUTHLib::IMTCompositeCapabilityPtr manageah = 
    security->GetCapabilityTypeByName(MANAGE_HIERARCHY_CAP)->CreateInstance();
  
  //capabilities that we check depend on the principal type we are trying to manage
  switch((MTSecurityPrincipalType)principal->PrincipalType)
  {
  case(ROLE_PRINCIPAL):
    //check global auth
    deniedEvent = AuditEventsLib::AUDITEVENT_ROLE_UPDATE_DENIED;
    secctx->CheckAccess(security->GetCapabilityTypeByName(MANAGE_GLOBALAUTH_CAP)->CreateInstance());
    break;
  case(CSR_ACCOUNT_PRINCIPAL):
    //check CSR auth
    deniedEvent = AuditEventsLib::AUDITEVENT_CSRAUTH_UPDATE_DENIED;
    secctx->CheckAccess(security->GetCapabilityTypeByName(MANAGECSRAUTH_CAP)->CreateInstance());
    break;
  case(SUBSCRIBER_ACCOUNT_PRINCIPAL):
    {
      deniedEvent = AuditEventsLib::AUDITEVENT_SUBAUTH_UPDATE_DENIED;
      
      //in case of subscriber check umbrella capability first
      MTYAACLib::IMTYAACPtr acc = principal;
      ASSERT (acc != NULL);
      
      MTAUTHLib::IMTPathCapabilityPtr pathcap = manageah->GetAtomicPathCapability();
      MTAUTHLib::IMTEnumTypeCapabilityPtr enumcap = manageah->GetAtomicEnumCapability();
      ASSERT (pathcap != NULL && enumcap != NULL);
      pathcap->SetParameter(acc->HierarchyPath, MTAUTHLib::SINGLE);
      //TODO: do we need to check read here and then check WRITE once more
      //when trying to modify roles or capabilities? 
      enumcap->SetParameter(aUmbrellaAccessLevel);
      secctx->CheckAccess(manageah);
      secctx->CheckAccess(security->GetCapabilityTypeByName(MANAGESUBAUTH_CAP)->CreateInstance());
      break;
    }
  default:
    ASSERT(0);
  }
  
  return S_OK;
}

STDMETHODIMP CheckAndAuditPrincipalAuth2Auth(IMTSessionContext *aCtx, IMTSecurityPrincipal *aPrincipal, char* aUmbrellaAccessLevel)
{
  MTAUTHLib::IMTSessionContextPtr ctx = aCtx;
  MTAUTHLib::IMTSecurityContextPtr secctx = ctx->SecurityContext;
  MTAUTHLib::IMTSecurityPrincipalPtr principal = aPrincipal;
  AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;

  try
  {
    CheckPrincipalAuth2Auth(aCtx, aPrincipal, aUmbrellaAccessLevel);
  }
  catch (_com_error& err)
  {
    AuditEventsLib::MTAuditEntityType entityType;
    if (principal->PrincipalType == ROLE_PRINCIPAL)
    { entityType = AuditEventsLib::AUDITENTITY_TYPE_ROLE;
    }
    else
    { entityType = AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT;
    }
    AuditAuthFailures(err, deniedEvent, ctx->AccountID, 
                      entityType,
                      principal->ID);

    throw err;
  }

  return S_OK;
}


STDMETHODIMP CheckGlobalAuth2Auth(IMTSessionContext *aCtx)
{
  MTAUTHLib::IMTSessionContextPtr ctx = aCtx;
  MTAUTHLib::IMTSecurityContextPtr secctx = ctx->SecurityContext;
  MTAUTHLib::IMTSecurityPtr security(__uuidof(MTAUTHLib::MTSecurity));
  secctx->CheckAccess(security->GetCapabilityTypeByName(MANAGE_GLOBALAUTH_CAP)->CreateInstance());
  return S_OK;
}
