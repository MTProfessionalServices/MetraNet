/**************************************************************************
 * @doc ADOUtils
 *
 * @module  utility functions for ADO
 *
 * This module contains headers for utility functions for ADO that make for easier
 * query generation and error handling
 *
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Navdip Bhachech
 * $Header$
 *
 * @index | ADOUtils
 ***************************************************************************/
#ifndef _adoutil_h_
#define _adoutil_h_

#include <stdio.h>
#include <tchar.h>
#include <list>
#include <string>
#include <comdef.h>

// import the ADO typelibrary - to allow easy syntax for ADO
#pragma warning( disable : 4146 )
#import <..\ThirdParty\ADO\msado15.dll> no_namespace rename( "EOF", "adoEOF" )
#pragma warning( default : 4146 )



// commented out due to bugs this generated in streaming classes
//using namespace std ;

// used to define func argument defaults
#define EMPTY_TCHAR _T("")
#define DEFAULT_DATABASENAME _T("NetMeter")
#define DEFAULT_SERVERTYPE _T("{SQL Server}")

// The quiet version, no logging, just catch the exception
#define TRY_CATCH_COM_ALL_Q( f ) try              \
                  {                             \
                      f;                        \
                  }                             \
                  catch( _com_error )           \
                  {                             \
                  }                             \
                  catch(...)                    \
                  {                             \
                  }

// utility variables for callers of ADO functions
// Need two distinct "empty" VARIANTs and BSTR for various Methods
// these are defined here for convinience, despite the fact that
// this is a header file
// @globalv
//extern _variant_t  vtEmpty (DISP_E_PARAMNOTFOUND, VT_ERROR);
// @globalv
//extern _variant_t  vtEmpty2(DISP_E_PARAMNOTFOUND, VT_ERROR);
// @globalv
//extern _bstr_t     bstrEmpty(L"");

// a string list of errors to display
typedef std::list<std::wstring> LISTADOERROR;

// COM error handling function that returns COM errors in a list
__declspec(dllexport) void GetCOMError( _com_error & arComError, LISTADOERROR & arListADOError, _ConnectionPtr & arConnectionPtr);

// ADO error handling function that gets all ADo errors in a list
__declspec(dllexport) void GetADOError(LISTADOERROR & arListADOError, _ConnectionPtr & arConnectionPtr);

#if 0
// converts a char into a wstring
__declspec(dllexport) int CharToWString(std::wstring & arWstring, const char * apChar, int aLen = -1);

// converts from OLE date time to regular time
__declspec(dllexport) BOOL TmFromOleDate(DATE aDateSrc, struct tm & arTmDest) ;

// converts from regular time to OLE date time
__declspec(dllexport) BOOL OleDateFromTm(WORD aYear, WORD aMonth, WORD aDay,
	WORD aHour, WORD aMinute, WORD aSecond, DATE & arDateDest);

__declspec(dllexport) BOOL GetNewID(const wchar_t* field, long& id);

// converts a string database type into a variant enum type
__declspec(dllexport) BOOL CrackPropertyType(int & aTypeInt, const std::wstring aStrType);

//  cracks variants into user displayable strings
__declspec(dllexport) BOOL CrackStrVariant(std::wstring & arCrackedString, const _variant_t & arVariantToCrack);

// gets textual description of ADO types
__declspec(dllexport) std::wstring GetType( const int aADOType );
#endif

#endif
