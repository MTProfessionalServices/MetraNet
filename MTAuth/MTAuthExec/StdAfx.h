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

#if !defined(AFX_927484fe_19c7_4827_b5a5_6ab410c07827_INCLUDED_)
#define AFX_927484fe_19c7_4827_b5a5_6ab410c07827_INCLUDED_

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
#include <comdef.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <mtparamnames.h>
#include <mtprogids.h>
#include <mtx.h>
#include <MTObjectCollection.h>
#include <MTUtil.h>
#include <mtglobal_msg.h>
#include <mtautocontext.h>
#include <MTTypeConvert.h>
#include <RowsetDefs.h>
//#include <PropertiesBase.h>
#include <MTTypeConvert.h>
#include <MTUtil.h>
#include <RowsetDefs.h>
#include <formatdbvalue.h>
#include <PCCache.h>
#include <PathRegEx.h>

#include <classobject.h>


#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <GenericCollection.tlb> 
#import <AuditEventsLib.tlb> 
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTAuthExec.tlb> rename ("EOF", "RowsetEOF")
#import <MTAuthCapabilities.tlb> rename ("EOF", "RowsetEOF")

#include <accountbatchhelper.h>

#include <map>

using namespace std;


#define CONFIG_DIR "Queries\\Auth"

MTOperatorType StringToOp(_bstr_t opStr);


//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_927484fe_19c7_4827_b5a5_6ab410c07827_INCLUDED_)
