// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

#if !defined(AFX_STDAFX_H__BF958CE8_CA5D_47BA_A39A_2E356256A5AB__INCLUDED_)
#define AFX_STDAFX_H__BF958CE8_CA5D_47BA_A39A_2E356256A5AB__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define STRICT
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif
#define _ATL_APARTMENT_THREADED

#include <atlbase.h>
//You may derive a class from CComModule and use it if you want to override
//something, but do not change the name of _Module
extern CComModule _Module;

#include <atlcom.h>
#include <autologger.h>
#include <metralite.h>

HRESULT returnHierarchyReportError(const _com_error &err);
HRESULT returnHierarchyReportError(const _com_error &err, const char *pStr, MTLogLevel aLogLevel = LOG_DEBUG);
HRESULT returnHierarchyReportError(REFCLSID clsid, REFGUID rguid, const char *pstrModule, const char *pstrMethod, const char *pstrDescription, MTLogLevel aLogLevel);

#import <MTProductView.tlb> rename ("EOF", "RowsetEOF")  no_function_mapping

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__BF958CE8_CA5D_47BA_A39A_2E356256A5AB__INCLUDED)
