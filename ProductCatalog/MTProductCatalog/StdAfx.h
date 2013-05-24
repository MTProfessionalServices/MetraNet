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
* $Header$
* 
***************************************************************************/

// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

#if !defined(AFX_STDAFX_H__7FEA82BD_8737_4FEF_98FA_BF40B5B12188__INCLUDED_)
#define AFX_STDAFX_H__7FEA82BD_8737_4FEF_98FA_BF40B5B12188__INCLUDED_

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

//includes for all files in MTProductcatalog
#include <metralite.h>
#include <mtglobal_msg.h>
#include <PCCache.h>
#import <MeterRowset.tlb> rename("EOF", "RowsetEOF")
#import <MTNameIDLib.tlb> 
#import <Counter.tlb> rename("EOF", "RowsetEOF") no_function_mapping
#import "MTProductCatalogExec.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import "GenericCollection.tlb" 
#import <MTEnumConfigLib.tlb> no_function_mapping
#import <MTUsageServer.tlb> rename ("EOF", "RowsetEOF")
#import <MTUsageCycle.tlb> rename ("EOF", "RowsetEOF")
#include "MTPCBase.h"
#include <corecapabilities.h>
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <PipelineTransaction.tlb>
#include <autherr.h>
#include <optionalvariant.h>
#import <MTProductCatalogInterfacesLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")


#define CHECKCAP(CAP_NAME) \
MTAuthInterfacesLib::IMTCompositeCapabilityPtr _capability = \
PCCache::GetSecurityFactory()->GetCapabilityTypeByName(CAP_NAME)->CreateInstance(); \
MTAuthInterfacesLib::IMTSecurityContextPtr _ctxt = GetSecurityContext(); \
if (_ctxt == NULL) \
  MT_THROW_COM_ERROR("No security context. Has ProductCatalog's SetSessionContext been called?"); \
_ctxt->CheckAccess(_capability); \


//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__7FEA82BD_8737_4FEF_98FA_BF40B5B12188__INCLUDED)
