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

#if !defined(AFX_STDAFX_H__2A725641_1158_403D_A249_8A7E96CE8646__INCLUDED_)
#define AFX_STDAFX_H__2A725641_1158_403D_A249_8A7E96CE8646__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define STRICT
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif
#define _ATL_APARTMENT_THREADED

#include <atlbase.h>
#include "MTYAACExec.h"
#include <comutil.h>
#include <comip.h>
#include <comdef.h>
#include <mtx.h>
#include <mtautocontext.h>
#include <mtcomerr.h>
#include <DataAccessDefs.h>
#include <RowsetDefs.h>
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#include <mtprogids.h>
#include <formatdbvalue.h>
#include <optionalvariant.h>
#include <AccHierarchiesShared.h>
#include <mtglobal_msg.h>
#include <adoutil.h>
#include <mttime.h>
#include "accountbatchhelper.h"

#import <MTYAAC.tlb> rename ("EOF", "RowsetEOF") 
#import <MTYAACExec.tlb> rename ("EOF", "RowsetEOF") 
#import <MTProductCatalogExec.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

//You may derive a class from CComModule and use it if you want to override
//something, but do not change the name of _Module
extern CComModule _Module;
#include <atlcom.h>

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__2A725641_1158_403D_A249_8A7E96CE8646__INCLUDED)
