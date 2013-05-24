/**************************************************************************
 * @doc STDAFX
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | STDAFX
 ***************************************************************************/

#ifndef _STDAFX_H
#define _STDAFX_H

/*
 * common stdafx.h used for all COM objects
 */

// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

#if !defined(AFX_STDAFX_H__0119D8CB_307D_11D2_B5F5_00104B2B980B__INCLUDED_)
#define AFX_STDAFX_H__0119D8CB_307D_11D2_B5F5_00104B2B980B__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#define STRICT

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0500
#endif

#define _ATL_APARTMENT_THREADED


#include <atlbase.h>
//You may derive a class from CComModule and use it if you want to override
//something, but do not change the name of _Module
extern CComModule _Module;
#include <atlcom.h>
#include <windows.h>
#include <metralite.h>
#ifndef ASSERT
#include <crtdbg.h>
#define ASSERT _ASSERT
#define ASSERTE _ASSERTE
#endif

// #include <metra.h>

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__0119D8CB_307D_11D2_B5F5_00104B2B980B__INCLUDED)


#endif /* _STDAFX_H */
