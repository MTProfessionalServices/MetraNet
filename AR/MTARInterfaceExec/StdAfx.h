// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

#if !defined(AFX_STDAFX_H__82D6E035_652C_495A_8BF7_D48F328E5666__INCLUDED_)
#define AFX_STDAFX_H__82D6E035_652C_495A_8BF7_D48F328E5666__INCLUDED_

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

#include <comsvcs.h>
#include <comdef.h>
#include <comsvcs.h>
#include <metra.h>
#include <mtcomerr.h>
#include <MTUtil.h>
#include <mtglobal_msg.h>
#include <mtautocontext.h>
#include <autologger.h>
#include <ARInterfaceMethod.h>
#include <ARShared.h>


#import <msxml4.dll>
#import <MTARInterfaceLib.tlb>



void ARLog(const wchar_t* aMsg, MTLogLevel aLogLevel = LOG_DEBUG);
void ARLogMethod(ARInterfaceMethod aMethod, BSTR aInputDoc = NULL, bool isAREnabled = true);
void ARLogMethodSuccess(ARInterfaceMethod aMethod, BSTR aOutputDoc = NULL);
void ARLogMethodFailure(ARInterfaceMethod aMethod, _com_error & err);
HRESULT ReturnTranslatedARError( _com_error& err);



//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.


#endif // !defined(AFX_STDAFX_H__82D6E035_652C_495A_8BF7_D48F328E5666__INCLUDED)
