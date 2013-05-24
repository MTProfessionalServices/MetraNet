// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently,
// but are changed infrequently

#pragma once

#ifndef STRICT
#define STRICT
#endif

// Modify the following defines if you have to target a platform prior to the ones specified below.
// Refer to MSDN for the latest info on corresponding values for different platforms.
#ifndef WINVER				// Allow use of features specific to Windows 95 and Windows NT 4 or later.
#define WINVER 0x0400		// Change this to the appropriate value to target Windows 98 and Windows 2000 or later.
#endif

#ifndef _WIN32_WINNT		// Allow use of features specific to Windows NT 4 or later.
#define _WIN32_WINNT 0x0400	// Change this to the appropriate value to target Windows 2000 or later.
#endif						

#ifndef _WIN32_WINDOWS		// Allow use of features specific to Windows 98 or later.
#define _WIN32_WINDOWS 0x0410 // Change this to the appropriate value to target Windows Me or later.
#endif

#ifndef _WIN32_IE			// Allow use of features specific to IE 4.0 or later.
#define _WIN32_IE 0x0400	// Change this to the appropriate value to target IE 5.0 or later.
#endif

#define _ATL_APARTMENT_THREADED
#define _ATL_NO_AUTOMATIC_NAMESPACE

#define _ATL_CSTRING_EXPLICIT_CONSTRUCTORS	// some CString constructors will be explicit

// turns off ATL's hiding of some common and often safely ignored warning messages
#define _ATL_ALL_WARNINGS


#include "resource.h"
#include <atlbase.h>
#include <atlcom.h>

using namespace ATL;

//includes for all files in MTProductcatalog
#include <metralite.h>
#include <mtglobal_msg.h>
#include <PCCache.h>
#import <MTNameIDLib.tlb> 
#import <Counter.tlb> rename("EOF", "RowsetEOF") no_function_mapping
#import "MTProductCatalogExec.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import "GenericCollection.tlb" 
#include "MTPCBase.h"
#import <MTEnumConfigLib.tlb> no_function_mapping
#include <corecapabilities.h>
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <PipelineTransaction.tlb>
#include <autherr.h>
#include <optionalvariant.h>


#define CHECKCAP(CAP_NAME) \
MTAuthInterfacesLib::IMTCompositeCapabilityPtr _capability = \
PCCache::GetSecurityFactory()->GetCapabilityTypeByName(CAP_NAME)->CreateInstance(); \
MTAuthInterfacesLib::IMTSecurityContextPtr _ctxt = GetSecurityContext(); \
if (_ctxt == NULL) \
  MT_THROW_COM_ERROR("No security context. Has ProductCatalog's SetSessionContext been called?"); \
_ctxt->CheckAccess(_capability); \

