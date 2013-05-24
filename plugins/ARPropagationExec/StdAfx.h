// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

#if !defined(AFX_STDAFX_H__D06882B4_8B07_47EC_99F3_EE04584F714E__INCLUDED_)
#define AFX_STDAFX_H__D06882B4_8B07_47EC_99F3_EE04584F714E__INCLUDED_

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

#include <metralite.h>
#include <comsvcs.h>
#include <comdef.h>
#include <mtprogids.h>
#include <mtcomerr.h>
#include <MTUtil.h>
#include <mtglobal_msg.h>
#include <mtautocontext.h>
#include <SetIterate.h>
#include <vector>
#include <string>

#import <msxml4.dll>
#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTARInterfaceLib.tlb"
#import "MTDataTypeLib.tlb"




//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__D06882B4_8B07_47EC_99F3_EE04584F714E__INCLUDED)
