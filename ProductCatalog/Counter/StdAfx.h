// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

#if !defined(AFX_STDAFX_H__2155936F_3E6C_4DBF_AEC3_28A79C137D11__INCLUDED_)
#define AFX_STDAFX_H__2155936F_3E6C_4DBF_AEC3_28A79C137D11__INCLUDED_

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

#include <comdef.h>
#include <metra.h>
#include "resource.h"       // main symbols
#include <mtcom.h>
#include <mtglobal_msg.h>
#include <mtprogids.h>
#include <MTDec.h>
#include "OperatorType.h"

//#include <Counter.h>
#include <QueryAdapter.h>
#include <GenericCollection.h>
#include <MTObjectCollection.h>
#include <stdutils.h>
#include <DBMiscUtils.h>
#include <MTUtil.h>
#include <mtcomerr.h>

#include <PCCache.h>
#include <MTPCBase.h>
//STL
#include <set>
#include <map>

#include <mtglobal_msg.h>

#include <MSIXDefinition.h>
#include "mtprogids.h"
#include <autocritical.h>


#define CONFIG_DIR L"queries\\ProductCatalog"
#define DYNAMICALLY_GENERATE_VIEWS

#import <MTProductView.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTProductViewExec.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTEnumConfigLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTProductCatalogExec.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <Counter.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

const wchar_t * OpToString(MTOperatorType aOp);
MTOperatorType StringToOp(_bstr_t opStr);

HRESULT WINAPI _This(void*,REFIID,void**,DWORD);


using namespace std;

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__2155936F_3E6C_4DBF_AEC3_28A79C137D11__INCLUDED)


