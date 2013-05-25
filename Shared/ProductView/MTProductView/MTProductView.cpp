// MTProductView.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//		To build a separate proxy/stub DLL, 
//		run nmake -f MTProductViewps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include "initguid.h"
#include <MTProductView.h>

#include <MTProductView_i.c>
#include "MTProductViewDef.h"
#include "MTProductViewOps.h"
#include "ProductView.h"
#include "ProductViewProperty.h"
#include "ProductViewUniqueKey.h"

#include <mtcomerr.h>
#include "ProductViewCatalog.h"

//////////////////////////////////////////////////////////////////////////////
//  Error Logging                                                           //
//////////////////////////////////////////////////////////////////////////////
namespace ProductViewLog {
	char pProductViewLog[] = "MTProductView";
};

MTAutoInstance<MTAutoLoggerImpl<ProductViewLog::pProductViewLog> > mProductViewLogger;

HRESULT returnProductViewError(const _com_error& err)
{	
	ErrorObject * errObj = CreateErrorFromComError(err);
	mProductViewLogger->LogErrorObject(errObj->IsUserError() ? LOG_DEBUG : LOG_ERROR, errObj);
	return ReturnComError(err);
}

HRESULT returnProductViewError(const _com_error &err, const char *pStr, MTLogLevel aLogLevel)
{
	mProductViewLogger->LogThis(aLogLevel,pStr);
	return ReturnComError(err);
}

HRESULT returnProductViewError(REFCLSID clsid, REFGUID rguid, const char *pstrModule, const char *pstrMethod, const char *pstrDescription, MTLogLevel aLogLevel)
{
  //Create an error info object
  ICreateErrorInfoPtr spCEI;
  IErrorInfoPtr spEI;
  _bstr_t strError;
  LPOLESTR lpsz = 0;


  strError = _bstr_t(pstrModule) + _bstr_t(L"::") + _bstr_t(pstrMethod) + _bstr_t(L" -- ") + _bstr_t(pstrDescription);
  
  //Log the error
  mProductViewLogger->LogThis(aLogLevel, (const char *)strError);


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


CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
	OBJECT_ENTRY(CLSID_MTProductViewDef, CMTProductViewDef)
	OBJECT_ENTRY(CLSID_MTProductViewOps, CMTProductViewOps)
	OBJECT_ENTRY(CLSID_ProductView, CProductView)
	OBJECT_ENTRY(CLSID_ProductViewProperty, CProductViewProperty)
	OBJECT_ENTRY(CLSID_ProductViewCatalog, CProductViewCatalog)
	OBJECT_ENTRY(CLSID_ProductViewUniqueKey, CProductViewUniqueKey)
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


