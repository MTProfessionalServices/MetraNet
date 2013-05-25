/**************************************************************************
 * @doc SKELETON
 *
 * Copyright 2000 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

// Skeleton.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//		To build a separate proxy/stub DLL, 
//		run nmake -f Skeletonps.mk in the project directory.


#include "StdAfx.h"
//#include "resource.h"
#include "initguid.h"
//#include "Skeleton.h"

#include <atlimpl.cpp>

//#include "MTPipelinePlugIn_i.c"

// Filter out ATL registration Warning from compiler.
#pragma warning(disable:4996)

extern _ATL_OBJMAP_ENTRY * _ObjectMap;


CComModule _Module;

// PLUGIN_OBJECT_MAP defines this for you
extern _ATL_OBJMAP_ENTRY * _PlugInObjectMap;

/*
 * simplified version of RegisterClassHelper
 */
HRESULT WINAPI RegisterPlugInClassHelper(HINSTANCE hinst, const CLSID& clsid,
																				 LPCTSTR lpszProgID,
																				 LPCTSTR lpszVerIndProgID, LPCTSTR lpszModel)
{
	static const TCHAR szProgID[] = _T("ProgID");
	static const TCHAR szVIProgID[] = _T("VersionIndependentProgID");
	static const TCHAR szIPS32[] = _T("InprocServer32");
	static const TCHAR szThreadingModel[] = _T("ThreadingModel");
	USES_CONVERSION;
	HRESULT hRes = S_OK;

	TCHAR szModule[_MAX_PATH];
	GetModuleFileName(hinst, szModule, _MAX_PATH);

	LPOLESTR lpOleStr;
	StringFromCLSID(clsid, &lpOleStr);
	LPTSTR lpsz = OLE2T(lpOleStr);

	LPTSTR szDesc = _T("");
	hRes =
#if _MSC_VER >= 1200
		CComModule::RegisterProgID
#else
		AtlRegisterProgID
#endif
		(lpsz, lpszProgID, szDesc);

	if (hRes == S_OK)
	{
		hRes = 
#if _MSC_VER >= 1200
		CComModule::RegisterProgID
#else
		AtlRegisterProgID
#endif
		  (lpsz, lpszVerIndProgID, szDesc);
	}

	LONG lRes = ERROR_SUCCESS;
	if (hRes == S_OK)
	{
		CRegKey key;
		LONG lRes = key.Open(HKEY_CLASSES_ROOT, _T("CLSID"));
		if (lRes == ERROR_SUCCESS)
		{
			lRes = key.Create(key, lpsz);
			if (lRes == ERROR_SUCCESS)
			{
				key.SetValue(szDesc);
				key.SetKeyValue(szProgID, lpszProgID);
				key.SetKeyValue(szVIProgID, lpszVerIndProgID);

				key.SetKeyValue(szIPS32, szModule);
				if (lpszModel != NULL)
					key.SetKeyValue(szIPS32, lpszModel, szThreadingModel);

			}
		}
	}
	CoTaskMemFree(lpOleStr);
	if (lRes != ERROR_SUCCESS)
		hRes = HRESULT_FROM_WIN32(lRes);
	return hRes;
}





/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point


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
	return _Module.RegisterServer(FALSE);
}

/////////////////////////////////////////////////////////////////////////////
// DllUnregisterServer - Removes entries from the system registry

STDAPI DllUnregisterServer(void)
{
	_Module.UnregisterServer();
	return S_OK;
}


extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
	if (dwReason == DLL_PROCESS_ATTACH)
	{
		_Module.Init(_PlugInObjectMap, hInstance);
		DisableThreadLibraryCalls(hInstance);
	}
	else if (dwReason == DLL_PROCESS_DETACH)
		_Module.Term();
	return TRUE;    // ok
}


