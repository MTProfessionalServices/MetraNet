/**************************************************************************
 * @doc
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
 * Created by: Carl Shimer
 *
 * This module provides a number of exported function for use by 
 * InstallShield
 *
 * $Date$
 * $Author$
 * $Revision$
 */

#include <metra.h>
#include <mtcom.h>
#include <comdef.h>
#include <objbase.h>
#include <installutil.h>
#include <autoinstance.h>
#include <AccountTools.h>

extern MTAutoInstance<InstallLogger> g_Logger;

//////////////////////////////////////////////////////////////////
// AddAccount
// Top level DLL interface function for Installshield
//////////////////////////////////////////////////////////////////

LONG InstCallConvention AddAccount(LPSTR pAccountName,LPSTR pPassword, LPSTR pNameSpace,LPSTR pLanguage,LONG aDayOfMonth, LPSTR pAccountType) 
{
	if(pAccountName == NULL || pPassword == NULL || pNameSpace == NULL || pLanguage == NULL || pAccountType == NULL) {
		ASSERT(!"Invalid arguments.");
		return FALSE;
	}
  BOOL retval;
  try {
		string aStr(pAccountName);
		MTAccountTools aAccountTools(pAccountName);
		aAccountTools.GetErrorString();
		_bstr_t	bstrAccountType;
		bstrAccountType = pAccountType;
		retval = aAccountTools.AddDefaultAccount(string(pPassword),
			string(pNameSpace),
			string(pLanguage),
			aDayOfMonth,
			"Monthly",
			0, 0, 0, 0, 0, 0,
			bstrAccountType);
		if(!retval) {
			g_Logger->LogThis(LOG_ERROR,aAccountTools.GetErrorString());
		}
  }
  catch(...) {
		g_Logger->LogVarArgs(LOG_FATAL,"Caught unknown exception attempting to create account %s",
			pAccountName);
    retval = FALSE;
		// Can no longer throw exception from DLL exported function
// #ifdef _DEBUG
// 	throw;
// #endif
  }
  return retval;
}


//////////////////////////////////////////////////////////////////
// AddAccountWithCycle
// Top level DLL interface function for Installshield
//////////////////////////////////////////////////////////////////

LONG InstCallConvention AddAccountWithCycle(LPSTR pAccountName,LPSTR pPassword, LPSTR pNameSpace,LPSTR pLanguage,
																	 LONG aDayOfMonth, LPSTR pUCT)
{
	if(pAccountName == NULL || pPassword == NULL || pNameSpace == NULL || 
			pLanguage == NULL || pUCT == NULL) {
		ASSERT(!"Invalid arguments.");
		return FALSE;
	}
  BOOL retval;

  try {
		string aStr(pAccountName);
		MTAccountTools aAccountTools(pAccountName);
		aAccountTools.GetErrorString();
    
		retval = aAccountTools.AddDefaultAccount(string(pPassword),
			string(pNameSpace),
			string(pLanguage),
			aDayOfMonth,
			_bstr_t(pUCT));
		if(!retval) {
			g_Logger->LogThis(LOG_ERROR,aAccountTools.GetErrorString());
		}
  }
  catch(...) {
		g_Logger->LogVarArgs(LOG_FATAL,"Caught unknown exception attempting to create account %s",
			pAccountName);
    retval = FALSE;
		// Can no longer throw exception from DLL exported function
// #ifdef _DEBUG
// 	throw;
// #endif
  }
  return retval;
}

LONG InstCallConvention AddAccountMappings(LPSTR pAccountName ,LPSTR pNameSpace,LONG aAccountID) 
{
	BOOL retval(FALSE);

	try {
		string aStr(pAccountName);
		MTAccountTools aAccountTools(pAccountName);

		retval = aAccountTools.AddAccountMapping(string(pNameSpace),aAccountID);
		if(!retval) {
			g_Logger->LogThis(LOG_ERROR,aAccountTools.GetErrorString());
		}
	}
	catch(...) {
		g_Logger->LogVarArgs(LOG_FATAL,"Caught unknown exception attempting to add account mapping for account %s",
			pAccountName);
    retval = FALSE;
		// Can no longer throw exception from DLL exported function
// #ifdef _DEBUG
// 	throw;
// #endif
	}

	return retval;
}


