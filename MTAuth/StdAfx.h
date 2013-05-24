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

#if !defined(AFX_STDAFX_H__73d3e87d_8231_4eeb_93f0_4691a3311af9__INCLUDED_)
#define AFX_STDAFX_H__73d3e87d_8231_4eeb_93f0_4691a3311af9__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define STRICT
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif
#define _ATL_APARTMENT_THREADED


#include <atlbase.h>
extern CComModule _Module;
#include <atlcom.h>


#include <comdef.h>
#include <metra.h>

#include <mtcom.h>


#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <RowsetDefs.h>
#include <mtprogids.h>
#include <MTObjectCollection.h>
#include <MTTypeConvert.h>
#include <MTTypeConvert.h>
#include <MTUtil.h>
#include <MTAuth.h>
#include <base64.h>
#include <mttime.h>
#include <ConfigChange.h>
#include <comsingleton.h>
#include <autocritical.h>
#include <MTDate.h>
#include <corecapabilities.h>
#include <AccHierarchiesShared.h>
#include <formatdbvalue.h>
#include <autherr.h>
#include <stdutils.h>
#include <MTDec.h>
#include <PathRegEx.h>
#include <classobject.h>
#include <Auth.h>

#import <msxml4.dll>

//#include <IMTAuth_i.c>
HRESULT WINAPI _This(void*,REFIID,void**,DWORD);

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

//#import <COMKiosk.tlb> rename ("EOF", "RowsetEOF")


#import <MTAuth.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

//#import <MTAuthLib.tlb> rename ("EOF", "RowsetEOF")

#import <MTAuthExec.tlb> rename ("EOF", "RowsetEOF")
#import <MTYAAC.tlb> rename ("EOF", "RowsetEOF") 
#import <MTAuthCapabilities.tlb> rename ("EOF", "RowsetEOF")
#import <MTYAACExec.tlb> rename ("EOF", "RowsetEOF")
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <AuditEventsLib.tlb>
#import <MTEnumConfigLib.tlb>
#import <COMKiosk.tlb> rename ("EOF", "RowsetEOF")
#import <comticketagent.tlb> rename ("EOF", "RowsetEOF")

//#import <MTSessionContextLib.tlb>

#include <set>
#include <vector>
#include <map>
#include <string>

#define CONFIG_DIR "Queries\\Auth"

HRESULT LogAndReturnAuthError(const _com_error& err);

HRESULT LogAndReturnAuthError(const _com_error& err,const char* pStr);

HRESULT LogAuthError(const char* pStr);

HRESULT LogAuthWarning(const char* pStr);

HRESULT LogAuthDebug(const char* pStr);

HRESULT LogAuthInfo(const char* pStr);

bool ValidateBooleanTag(_bstr_t& aTag);

bool ValidatePolicyTypeTag(_bstr_t& aTag);

VARIANT_BOOL ConvertBooleanTag(_bstr_t& aTag);


const wchar_t * OpToString(MTOperatorType aOp);
MTOperatorType StringToOp(_bstr_t opStr);


STDMETHODIMP CheckPrincipalAuth2Auth(IMTSessionContext *aCtx, IMTSecurityPrincipal *aPrincipal, char* aUmbrellaAccessLevel);
STDMETHODIMP CheckAndAuditPrincipalAuth2Auth(IMTSessionContext *aCtx, IMTSecurityPrincipal *aPrincipal, char* aUmbrellaAccessLevel);
STDMETHODIMP CheckGlobalAuth2Auth(IMTSessionContext *aCtx);

//You may derive a class from CComModule and use it if you want to override
//something, but do not change the name of _Module

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !definedAFX_STDAFX_H__73d3e87d_8231_4eeb_93f0_4691a3311af9__INCLUDED_)
