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

#if !defined(AFX_STDAFX_H__8751B14D_23C3_4C7F_B987_EF6BD3553EE3__INCLUDED_)
#define AFX_STDAFX_H__8751B14D_23C3_4C7F_B987_EF6BD3553EE3__INCLUDED_

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
#include "ModuleGlobal.h"
#include <PCCache.h>
#include "pcexecincludes.h"
#include "mtautocontext.h"
#include <mtglobal_msg.h>
#include "MTProductCatalog.h"
#include <optionalvariant.h>

#import "MTProductView.tlb" rename ("EOF", "RowsetEOF") 
#import "MTProductViewExec.tlb" rename ("EOF", "RowsetEOF") 
#import <MTProductCatalogInterfacesLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")

const wchar_t * OpToString(MTOperatorType aOp);
MTOperatorType StringToOp(_bstr_t opStr);



//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.



#endif // !defined(AFX_STDAFX_H__8751B14D_23C3_4C7F_B987_EF6BD3553EE3__INCLUDED)
