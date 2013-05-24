/**************************************************************************
 * @doc METRA
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
 * $Header$
 *
 * @index | METRA
 ***************************************************************************/

#ifndef _METRA_H
#define _METRA_H

#ifdef _DEBUG
#define BIN_POSTFIX "d"
#else
#define BIN_POSTFIX ""
#endif

// this disables the level 4 warning generated for while (1)
#pragma warning( disable : 4127)
// this disables the warning
//   access-declarations are deprecated; member using-declarations provide a
//   better alternative
// roguewave generates tons of these warnings
#pragma warning( disable : 4516)

#ifdef WIN32
#define DIR_SEP "\\"
#else
#define DIR_SEP "//"
#endif
#ifdef WIN32

// only want this header brought in one time
#pragma once

#define HTTP_DIR_SEP "/"

/**************************************************** Win32 types ***/

// use windows types for our type definitions
// we define WIN32_LEAN_AND_MEAN to cut out a lot of
// the includes that we won't need

// bring in newest features
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x500
#endif

// limit what we drag in from windows.h
#define WIN32_LEAN_AND_MEAN

//
// The following windows.h modules are not required to compile
// the MetraTech software.
//

#define NOGDICAPMASKS						// - CC_*, LC_*, PC_*, CP_*, TC_*, RC_
#define NOVIRTUALKEYCODES				// - VK_*
#define NOWINSTYLES							// - WS_*, CS_*, ES_*, LBS_*, SBS_*, CBS_*
#define NOSYSMETRICS						// - SM_*
#define NOMENUS									// - MF_*
#define NOICONS									// - IDI_*
#define NOKEYSTATES							// - MK_*
#define NOSYSCOMMANDS						// - SC_*
#define NORASTEROPS							// - Binary and Tertiary raster ops
#define NOSHOWWINDOW						// - SW_*
#define OEMRESOURCE							// - OEM Resource values
#define NOATOM									// - Atom Manager routines
#define NOCLIPBOARD							// - Clipboard routines
#define NOCTLMGR								// - Control and Dialog routines
#define NODRAWTEXT							// - DrawText() and DT_*
#define NOMB										// - MB_* and MessageBox()
#define NOMEMMGR								// - GMEM_*, LMEM_*, GHND, LHND, associated routines
#define NOMETAFILE							// - typedef METAFILEPICT
#define NOSCROLL								// - SB_* and scrolling routines
#define NOSOUND									// - Sound driver routines
#define NOWH										// - SetWindowsHook and WH_*
#define NOWINOFFSETS						// - GWL_*, GCL_*, associated routines
#define NOCOMM									// - COMM driver routines
#define NOKANJI									// - Kanji support stuff.
#define NOHELP									// - Help engine interface.
#define NOPROFILER							// - Profiler interface.
#define NODEFERWINDOWPOS				// - DeferWindowPos routines
#define NOMCX										// - Modem Configuration Extensions

//
// MetraTech code requires the following modules from windows.h
//
//#define NOKERNEL								// - All KERNEL defines and routines
//#define NOUSER									// - All USER defines and routines
//#define NONLS										// - All NLS defines and routines
//#define NOSERVICE								// - All Service Controller routines, SERVICE_ equates, etc.
//#define NOOPENFILE							// - OpenFile(), OemToAnsi, AnsiToOem, and OF_*
//#define NOMINMAX								// - Macros min(a,b) and max(a,b)

//
// The following modules are required as side effects of COM/OLE
//
//#define NOTEXTMETRIC						// - typedef TEXTMETRIC and associated routines
//#define NOMSG										// - typedef MSG and associated routines
//#define NOGDI										// - All GDI defines and routines
//#define NOCOLOR									// - Screen colors
//#define NOWINMESSAGES
// - for some reason ATL needs WM_QUIT in VS.NET 2003

#include <windows.h>

// if you want to use unicode, you must #define _UNICODE and UNICODE
#if (defined(UNICODE) && !defined(_UNICODE)) || (!defined(UNICODE) && defined(_UNICODE))
#error Both UNICODE and _UNICODE must be defined.
#endif

#pragma warning( disable : 4786 )

#endif // WIN32

/***************************************************** Unix types ***/

/* BOOL type */
#ifndef BOOL
typedef int BOOL;
#endif /* BOOL */

/* true and false */
#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef NULL
#define NULL 0
#endif


/********************************************************* Common ***/

#ifndef ASSERT

#ifndef WIN32

/* use assert from assert.h unless it's already been defined. */
#include <assert.h>
#define ASSERT assert

#else // WIN32

/* ASSERT is defined by MFC as well. */
#include <crtdbg.h>
#define ASSERT _ASSERT
#define ASSERTE _ASSERTE

#endif // WIN32

#endif // ASSERT


#ifdef WIN32_DEPRECATED_CHECKS

#define ASSERT_VALID_HEAP_POINTER(p) ASSERT(_CrtIsValidHeapPointer(p))

#define ASSERT_VALID_READ_POINTER(p, size) \
   ASSERT(_CrtIsValidPointer(p, size, FALSE);

#define ASSERT_VALID_POINTER(p, size) \
   ASSERT(_CrtIsValidPointer(p, size, TRUE));

// valid modes are
//  _CRTDBG_MODE_DEBUG - Writes the message to an output debug string.
//  _CRTDBG_MODE_FILE -  Writes the message to a user-supplied file handle.
//  _CRTDBG_MODE_WNDW -  Creates a message box to display the message along 
//                       with the Abort, Retry, and Ignore buttons.

#define SET_ASSERT_MODE(mode) _CrtSetReportMode(_CRT_ASSERT, mode)

#else // WIN32

// weak versions of the macros
#define ASSERT_VALID_HEAP_POINTER(p) ASSERT(p != NULL)
#define ASSERT_VALID_READ_POINTER(p, size) ASSERT(p != NULL);
#define ASSERT_VALID_POINTER(p, size) ASSERT(p != NULL);

#define SET_ASSERT_MODE(mode)
#endif // WIN32


// Defines global operator new to use the debug hooks

#ifdef _DEBUG
#define MT_DEBUG_NEW new( _NORMAL_BLOCK, __FILE__, __LINE__)
//  Replace _NORMAL_BLOCK with _CLIENT_BLOCK if you want the
// allocations to be of _CLIENT_BLOCK type
#endif // _DEBUG

/* return the company name */
inline const char * GetCompanyName()
{
	return "MetraTech";
}

#ifdef WIN32
#define MT_TPL_ARGS(typearg) typearg
#define MT_TPL_ARGS_COMPLEX(typearg, container) typearg
#endif

#ifdef UNIX
#include <metraunix.h>
#define MT_TPL_ARGS(typearg) typearg,allocator
#define MT_TPL_ARGS_COMPLEX(typearg, container) typearg, container<typearg, allocator>, allocator
#endif // UNIX

// Oracle treats empty string as NULL. Define strig to use as substiutution to get around this issue.
#define MTEmptyString	_bstr_t(" ")

#endif /* _METRA_H */
