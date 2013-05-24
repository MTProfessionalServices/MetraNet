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
//      run nmake -f MTAuthCapabilitiesps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>
#include "MTAuthCapabilities.h"

#include "IMTCapabilities_i.c"
#include "MTAuthCapabilities_i.c"
#include "IMTAuth_i.c"

//#include "MTAuth_i.c"
#include "MTManageAH.h"
#include "MTApplicationLogOnCapability.h"
#include "MTManageGlobalAuth.h"
#include "MTAllCapability.h"
#include "MTViewOnlineBillCapability.h"
#include "MTIssueCreditCapability.h"
#include "CMTCreateCorporateAccountCapability.h"
#include "CMTUpdateCorporateAccountCapability.h"
#include "MTCreateCSRCapability.h"
#include "MTUpdateCSRCapability.h"
#include "MTCreateSubscriberCapability.h"
#include "MTUpdateSubscriberCapability.h"
#include "MTCreateFolderCapability.h"
#include "MTUpdateFolderCapability.h"
#include "MTMoveAccountCapability.h"
#include "MTMoveFolderCapability.h"
#include "MTManagePaymentCapability.h"
#include "MTManageBillableCapability.h"
#include "MTCreateGroupSubCapability.h"
#include "MTUpdateGroupSubCapability.h"
#include "MTAddMemberToGroupSubCapability.h"
#include "MTModifyGroupSubMemberCapability.h"
#include "MTCreateSubscriptionCapability.h"
#include "MTUpdateSubscriptionCapability.h"
#include "MTICBSubscriptionCapability.h"
#include "MTICBGroupSubscriptionCapability.h"
#include "MTManageSubscriberAuthCapability.h"
#include "MTManageCSRAuthCapability.h"
#include "MTViewSubscriptionsCapability.h"
#include "MTViewGroupSubCapability.h"
#include "MTManageNHAccounts.h"
#include "MTImpersonateUserCapability.h"
#include "MTUpdAccFromActiveToSuspendedCapability.h"
#include "MTUpdAccFromSuspendedToActiveCapability.h"
#include "MTUpdAccFromActiveToClosedCapability.h"
#include "MTDeleteSubscriptionCapability.h"
#include "MTUpdAccFromPendingFinalBillToActiveCapability.h"
#include "MTSelfSubscribe.h"
#include "MTUpdateFailedTransactions.h"


CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_MTManageAHCapability, CMTManageAHCapability)
OBJECT_ENTRY(CLSID_MTApplicationLogOnCapability, CMTApplicationLogOnCapability)
OBJECT_ENTRY(CLSID_MTManageGlobalAuthCapability, CMTManageGlobalAuthCapability)
OBJECT_ENTRY(CLSID_MTAllCapability, CMTAllCapability)
OBJECT_ENTRY(CLSID_MTViewOnlineBillCapability, CMTViewOnlineBillCapability)
OBJECT_ENTRY(CLSID_MTIssueCreditCapability, CMTIssueCreditCapability)
OBJECT_ENTRY(CLSID_CMTCreateCorporateAccountCapability, CCMTCreateCorporateAccountCapability)
OBJECT_ENTRY(CLSID_CMTUpdateCorporateAccountCapability, CCMTUpdateCorporateAccountCapability)
OBJECT_ENTRY(CLSID_MTCreateCSRCapability, CMTCreateCSRCapability)
OBJECT_ENTRY(CLSID_MTUpdateCSRCapability, CMTUpdateCSRCapability)
OBJECT_ENTRY(CLSID_MTCreateSubscriberCapability, CMTCreateSubscriberCapability)
OBJECT_ENTRY(CLSID_MTUpdateSubscriberCapability, CMTUpdateSubscriberCapability)
OBJECT_ENTRY(CLSID_MTCreateFolderCapability, CMTCreateFolderCapability)
OBJECT_ENTRY(CLSID_MTUpdateFolderCapability, CMTUpdateFolderCapability)
OBJECT_ENTRY(CLSID_MTMoveAccountCapability, CMTMoveAccountCapability)
OBJECT_ENTRY(CLSID_MTMoveFolderCapability, CMTMoveFolderCapability)
OBJECT_ENTRY(CLSID_MTManagePaymentCapability, CMTManagePaymentCapability)
OBJECT_ENTRY(CLSID_MTManageBillableCapability, CMTManageBillableCapability)
OBJECT_ENTRY(CLSID_MTCreateGroupSubCapability, CMTCreateGroupSubCapability)
OBJECT_ENTRY(CLSID_MTUpdateGroupSubCapability, CMTUpdateGroupSubCapability)
OBJECT_ENTRY(CLSID_MTAddMemberToGroupSubCapability, CMTAddMemberToGroupSubCapability)
OBJECT_ENTRY(CLSID_MTModifyGroupSubMemberCapability, CMTModifyGroupSubMemberCapability)
OBJECT_ENTRY(CLSID_MTCreateSubscriptionCapability, CMTCreateSubscriptionCapability)
OBJECT_ENTRY(CLSID_MTUpdateSubscriptionCapability, CMTUpdateSubscriptionCapability)
OBJECT_ENTRY(CLSID_MTICBSubscriptionCapability, CMTICBSubscriptionCapability)
OBJECT_ENTRY(CLSID_MTICBGroupSubscriptionCapability, CMTICBGroupSubscriptionCapability)
OBJECT_ENTRY(CLSID_MTManageSubscriberAuthCapability, CMTManageSubscriberAuthCapability)
OBJECT_ENTRY(CLSID_MTManageCSRAuthCapability, CMTManageCSRAuthCapability)
OBJECT_ENTRY(CLSID_MTViewSubscriptionsCapability, CMTViewSubscriptionsCapability)
OBJECT_ENTRY(CLSID_MTViewGroupSubCapability, CMTViewGroupSubCapability)
OBJECT_ENTRY(CLSID_MTUpdAccFromSuspendedToActiveCapability, CMTUpdAccFromSuspendedToActiveCapability)
OBJECT_ENTRY(CLSID_MTUpdAccFromActiveToSuspendedCapability, CMTUpdAccFromActiveToSuspendedCapability)
OBJECT_ENTRY(CLSID_MTUpdAccFromActiveToClosedCapability, CMTUpdAccFromActiveToClosedCapability)
OBJECT_ENTRY(CLSID_MTManageNHAccounts, CMTManageNHAccounts)
OBJECT_ENTRY(CLSID_MTImpersonateUserCapability, CMTImpersonateUserCapability)
OBJECT_ENTRY(CLSID_MTDeleteSubscriptionCapability, CMTDeleteSubscriptionCapability)
OBJECT_ENTRY(CLSID_MTUpdAccFromPendingFinalBillToActiveCapability, CMTUpdAccFromPendingFinalBillToActiveCapability)
OBJECT_ENTRY(CLSID_MTSelfSubscribe, CMTSelfSubscribe)
OBJECT_ENTRY(CLSID_MTUpdateFailedTransactions, CMTUpdateFailedTransactions)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTAUTHCAPABILITIESLib);
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




