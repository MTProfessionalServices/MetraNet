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

// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

#if !defined(AFX_STDAFX_H__4715E8C2_364F_4E5F_BBDA_338FE020F0D3__INCLUDED_)
#define AFX_STDAFX_H__4715E8C2_364F_4E5F_BBDA_338FE020F0D3__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define STRICT
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif
#define _ATL_APARTMENT_THREADED
#include <Auth.h>
#include <mtglobal_msg.h>
#include <atlbase.h>
#include <metra.h>
#include <mtcom.h>
#include <comdef.h>
#include <comutil.h>
#include <mtcomerr.h>
#include <autologger.h>
#import <msxml4.dll>
#import <MTYAAC.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <MTYAACExec.tlb> rename ("EOF", "RowsetEOF") 
#import <MTAccountStates.tlb> rename ("EOF", "RowsetEOF") 
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <GenericCollection.tlb>
#import <MTAuthCapabilities.tlb> rename ("EOF", "RowsetEOF") 
#import <MTAuthExec.tlb> rename ("EOF", "RowsetEOF") 
#import <COMKiosk.tlb> rename ("EOF", "RowsetEOF")
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <MTEnumConfigLib.tlb>
#import <MTConfigLib.tlb>
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib") rename ("_Stream", "_StreamCorlib")
#import <MetraTech.Accounts.Ownership.tlb> inject_statement("using namespace mscorlib;")  //no_function_mapping
#import <IMTAccountType.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MetraTech.Accounts.Type.tlb> inject_statement("using namespace mscorlib; using MTAccountTypeLib::IMTAccountTypePtr;") rename ("EOF", "RowsetEOF") no_function_mapping
#import <PipelineTransaction.tlb>
#include <NTLogger.h>
#include <formatdbvalue.h>
#include <optionalvariant.h>
#include <mttime.h>
#include <AccHierarchiesShared.h>
#include <corecapabilities.h>
#include <MTAccountStatesDefs.h>

_COM_SMARTPTR_TYPEDEF(IDispatch,__uuidof(IDispatch));

#define CTXCAST(ctxobject) reinterpret_cast<MTYAACLib::IMTSessionContext *>(ctxobject.GetInterfacePtr())
#define CTXCASTTOAUTH(ctxobject) reinterpret_cast<MTAUTHLib::IMTSessionContext *>(ctxobject.GetInterfacePtr())


HRESULT LogYAACError(const char* pError,MTLogLevel aLogLevel = LOG_DEBUG);
HRESULT LogYAACError(const char* pError,MTYAACLib::IMTYAACPtr aYAAC,MTLogLevel aLogLevel = LOG_DEBUG);

HRESULT returnYAACError(const _com_error& err);
HRESULT returnYAACError(const _com_error& err,const char* pStr,MTLogLevel aLogLevel = LOG_DEBUG);
HRESULT returnYAACError(const _com_error& err,const char* pStr,const char* pExtraInfo, MTLogLevel aLogLevel = LOG_DEBUG);
HRESULT returnYAACError(const _com_error& err,const char* pError,MTYAACLib::IMTYAACPtr aYAAC,MTLogLevel aLogLevel = LOG_DEBUG);

HRESULT WINAPI _This(void*,REFIID,void**,DWORD);


//You may derive a class from CComModule and use it if you want to override
//something, but do not change the name of _Module
extern CComModule _Module;
#include <atlcom.h>

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__4715E8C2_364F_4E5F_BBDA_338FE020F0D3__INCLUDED)

