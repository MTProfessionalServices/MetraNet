/**************************************************************************
* @doc DBMiscUtils
* 
* @module  Miscellaneous utility functions |
* 
* This file contains miscellaneous utility functions to be used by the
* database classes.
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
* Created by: Kevin Fitzgerald
* $Header$
*
* @index | DBMiscUtils
***************************************************************************/

#ifndef __DBMISCUTILS_H
#define __DBMISCUTILS_H

#include "DBMiscStlUtils.h"
#include <comutil.h>
#include <string>
#include <mttime.h>

inline std::wstring CreatePrintableRefID (unsigned char *apSessionID)
{
  // call STL version ...
  std::wstring wstrString(CreatePrintableRefID_STL(apSessionID).c_str()) ;
  return wstrString ;
}


inline std::wstring ConvertSessionIDToString (const unsigned char *const apSessionID)
{
  std::wstring wstrString ;
  wchar_t sessionID[DB_SESSIONID_SIZE+1] ;

  // convert the session id to a string ...
  wstrString += L"0x" ; 
  for (int i=0 ; i < DB_SESSIONID_SIZE; i++)
  {
    wsprintf(sessionID, L"%02X", (int)*(apSessionID+i)) ;
    wstrString += sessionID ;
  }

  return wstrString ;
}

inline _variant_t ConvertPropertyName (const _variant_t &arIndex)
{
  _variant_t vtIndex ;
  
  // copy the index ...
  if (arIndex.vt == (VT_BYREF | VT_VARIANT))
  {
    vtIndex = arIndex.pvarVal ;
  }
  // otherwise ... pass the variant itself 
  else
  {
    vtIndex = arIndex ;
  }

  // if the type is VT_BSTR ... fix the property name ...
  if (vtIndex.vt == VT_BSTR)
  {
    // get the string ...
    std::wstring wstrName = vtIndex.bstrVal ;

    // TO BE REMOVED FOR GENESIS 
    // if it doesnt contains a c_ ...
    //int index = wstrName.index (L"c_", 0, std::wstring::ignoreCase) ;
	// if (index == RW_NPOS)

	if ( (wcsstr(wstrName.c_str(), L"c_") == NULL) && (wcsstr(wstrName.c_str(), L"C_") == NULL))
    {
      // if it's one of oure reserved properties ... ignore it ...
      if (_wcsicmp(DB_AMOUNT, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_CURRENCY, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_TAX_AMOUNT, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_AMOUNT_WITH_TAX, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_INTERVAL_ID, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_ACCOUNT_ID, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_VIEW_ID, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_TIMESTAMP, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_SESSION_TYPE, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_SESSION_ID, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_VIEW_NAME, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_VIEW_TYPE, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_COUNT, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_DESCRIPTION_ID, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_INTERVAL_START, wstrName.c_str()) == 0)
      {
        ;
      }
	  else if (_wcsicmp(DB_INTERVAL_END, wstrName.c_str()) == 0)
      {
        ;
      }
			// XXX WTF is this shit?  this code blows.
			else if (_wcsicmp(DB_AGG_RATE, wstrName.c_str()) == 0){
				;
			}
			// XXX I still aggree with the above comment six months later.  I think KDF should
			// be dragged through the streets and beaten senseless by all of the poor 
			// developers who have to maintain his shit.
			else if (_wcsicmp(DB_SECONDPASS, wstrName.c_str()) == 0){
				;
			}
      else
      {
        // add c_ to the property name ...
        wstrName.insert(0, L"c_") ;
        vtIndex = wstrName.c_str();
      }
    }
  }
  
  return vtIndex ;
}


inline std::wstring ValidateString (const std::wstring &arString)
{
  if (arString.length() == 0)
  {
	  std::wstring wstrString = L"" ;
    return wstrString ;
  }
	// only convert quotes if necessary
	if (arString.find(L'\'') == std::string::npos)
		return arString;

  std::wstring wstrString ;
 
  // go through the string and determine if there are any single quotes(') in it ...
  // if there are double them up ...
  for (unsigned int i=0 ; i < arString.length() ; i++)
  {
    if (arString[i] == '\'')
    {
      wstrString += L"''" ;
    }
    else
    {
      wstrString += arString[i] ;
    }
  }
  if (wstrString.length() == 0)
  {
    wstrString = L" " ;
  }
  return wstrString ;
}

inline std::wstring GetDateTimeString ()
{
  // local variables ...
  std::wstring wstrString ;
  time_t sysTime ;
  struct tm *gmTime ;
  wchar_t timeStr[MAX_PATH] ;

  // get the current time ...
  sysTime = GetMTTime();

  // convert the time to GMT ...
  gmTime = gmtime (&sysTime) ;

  // convert the time to a string ...
  wcsftime (timeStr, MAX_PATH, L"%Y-%m-%d %H:%M:%S", gmTime) ;
  wstrString = timeStr ;

  return wstrString ;
}

//
//	@mfunc
//	Get the txn time 
//  @rdesc 
//  Return the txn time in string form
//
inline std::wstring GetTxnTimeStringFromTimet(const time_t &arTxnTime) 
{
  std::wstring wstrTxnTime ;

  // convert the txn time to a string ...
  wchar_t buffer[40];
  struct tm * tempTime = gmtime((time_t *) &arTxnTime);
  wcsftime(buffer, sizeof(buffer), L"%Y-%m-%d %H:%M:%S", tempTime);
  wstrTxnTime = buffer;

  return wstrTxnTime ;
}

inline long GetIntValue (const _variant_t &arValue)
{
  long nValue = 0 ;

  switch (arValue.vt)
  {
		case VT_I2:
      nValue = arValue.iVal ;
      break ;

		case VT_I4:
      nValue = arValue.lVal ;
      break ;

		case VT_R4:
      nValue = (long) arValue.fltVal ;
      break ;

		case VT_R8:
      nValue = (long) arValue.dblVal ;
      break ;

		case VT_DECIMAL:
      {
        DECIMAL decValue = arValue.decVal ;
        nValue = (long) decValue.Lo32 ;
      }
      break ;

    default:
      nValue = -1 ;
      break ;
  }
  return nValue ;
}

#endif 
