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
//      run nmake -f MTHierarchyReportsps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>
#include "MTHierarchyReports.h"

#include "MTHierarchyReports_i.c"
#include "ReportManager.h"
#include "MPSRenderInfo.h"
#include "HierarchyReportLevel.h"
#include "MPSReportInfo.h"
#include "PayerSlice.h"
#include "PayeeSlice.h"
#include "PayerAndPayeeSlice.h"
#include "UsageIntervalSlice.h"
#include "DateRangeSlice.h"
#include "UsageDetailQuery.h"
#include "SessionSlice.h"
#include "SessionChildrenSlice.h"
#include "PriceableItemInstanceSlice.h"
#include "PriceableItemTemplateSlice.h"
#include "PriceableItemTemplateWithInstanceSlice.h"
#include "UsageSummaryQuery.h"

#include <mtcomerr.h>
#include "SliceFactory.h"
#include "DescendentPayeeSlice.h"
#include "RootSessionSlice.h"
#include "AllSessionSlice.h"
#include "IntersectionTimeSlice.h"
#include "SliceLexer.h"
#include "ReportHelper.h"
#include "QueryParams.h"
#include "ProductViewSlice.h"

//////////////////////////////////////////////////////////////////////////////
//  Error Logging                                                           //
//////////////////////////////////////////////////////////////////////////////
namespace HierarchyReportLog {
	char pHierarchyReportLog[] = "Hierarchy Report Manager";
};

MTAutoInstance<MTAutoLoggerImpl<HierarchyReportLog::pHierarchyReportLog> > mHierarchyReportLogger;

HRESULT returnHierarchyReportError(const _com_error& err)
{	
	ErrorObject * errObj = CreateErrorFromComError(err);
	mHierarchyReportLogger->LogErrorObject(errObj->IsUserError() ? LOG_DEBUG : LOG_ERROR, errObj);
	return ReturnComError(err);
}

HRESULT returnHierarchyReportError(const _com_error &err, const char *pStr, MTLogLevel aLogLevel)
{
	mHierarchyReportLogger->LogThis(aLogLevel,pStr);
	return ReturnComError(err);
}

HRESULT returnHierarchyReportError(REFCLSID clsid, REFGUID rguid, const char *pstrModule, const char *pstrMethod, const char *pstrDescription, MTLogLevel aLogLevel)
{
  //Create an error info object
  ICreateErrorInfoPtr spCEI;
  IErrorInfoPtr spEI;
  _bstr_t strError;
  LPOLESTR lpsz = 0;


  strError = _bstr_t(pstrModule) + _bstr_t(L"::") + _bstr_t(pstrMethod) + _bstr_t(L" -- ") + _bstr_t(pstrDescription);
  
  //Log the error
  mHierarchyReportLogger->LogThis(aLogLevel, (const char *)strError);


  //Create an error object
  CreateErrorInfo(&spCEI);

  spCEI->SetDescription(strError);

  ProgIDFromCLSID(clsid, &lpsz);

  if(lpsz)
    spCEI->SetSource(lpsz);
  
  spCEI->SetGUID(rguid);
  
  spEI = spCEI;

  return ReturnComError(_com_error(spEI));
}

/////////////////////////////////////////////////////////////////////////////

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_ReportManager, CReportManager)
OBJECT_ENTRY(CLSID_MPSRenderInfo, CMPSRenderInfo)
OBJECT_ENTRY(CLSID_HierarchyReportLevel, CHierarchyReportLevel)
OBJECT_ENTRY(CLSID_MPSReportInfo, CMPSReportInfo)
OBJECT_ENTRY(CLSID_PayerSlice, CPayerSlice)
OBJECT_ENTRY(CLSID_PayeeSlice, CPayeeSlice)
OBJECT_ENTRY(CLSID_PayerAndPayeeSlice, CPayerAndPayeeSlice)
OBJECT_ENTRY(CLSID_UsageIntervalSlice, CUsageIntervalSlice)
OBJECT_ENTRY(CLSID_DateRangeSlice, CDateRangeSlice)
OBJECT_ENTRY(CLSID_UsageDetailQuery, CUsageDetailQuery)
OBJECT_ENTRY(CLSID_SessionSlice, CSessionSlice)
OBJECT_ENTRY(CLSID_SessionChildrenSlice, CSessionChildrenSlice)
OBJECT_ENTRY(CLSID_PriceableItemInstanceSlice, CPriceableItemInstanceSlice)
OBJECT_ENTRY(CLSID_PriceableItemTemplateSlice, CPriceableItemTemplateSlice)
OBJECT_ENTRY(CLSID_PriceableItemTemplateWithInstanceSlice, CPriceableItemTemplateWithInstanceSlice)
OBJECT_ENTRY(CLSID_UsageSummaryQuery, CUsageSummaryQuery)
OBJECT_ENTRY(CLSID_SliceFactory, CSliceFactory)
OBJECT_ENTRY(CLSID_DescendentPayeeSlice, CDescendentPayeeSlice)
OBJECT_ENTRY(CLSID_RootSessionSlice, CRootSessionSlice)
OBJECT_ENTRY(CLSID_AllSessionSlice, CAllSessionSlice)
OBJECT_ENTRY(CLSID_IntersectionTimeSlice, CIntersectionTimeSlice)
OBJECT_ENTRY(CLSID_SliceLexer, CSliceLexer)
OBJECT_ENTRY(CLSID_ReportHelper, CReportHelper)
OBJECT_ENTRY(CLSID_ProductViewSlice, CProductViewSlice)
OBJECT_ENTRY(CLSID_QueryParams, CQueryParams)

END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTHIERARCHYREPORTSLib);
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

