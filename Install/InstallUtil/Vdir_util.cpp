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
#include <installutil.h>

#include <adsiutil.h>

//////////////////////////////////////////////////////////
// CreateIISVdir
//
// Wrapper for reall IISvdir creation routine.  We must
// call Coinit / CoUnint on each call because we can not 
// assume that the libraries have been initialized.  this probably
// could be optimized with a ALLREADY_INITED flag, but I don't
// think the overhead is that much.
//////////////////////////////////////////////////////////


 LONG InstCallConvention CreateIISVdir(LPSTR lpszVdir, LPSTR lpszPath)
{
  MTVdir aVDir;
  HRESULT hr(S_OK);

  try {
    aVDir.CreateIISVdir(string(lpszVdir),string(lpszPath));
  }
  catch(_com_error e) {
    hr = E_FAIL;
  }

  return SUCCEEDED(hr) ? TRUE : FALSE;
}

//////////////////////////////////////////////////////////
// SetIISVdirPerms, wrapper
//////////////////////////////////////////////////////////

LONG InstCallConvention SetIISVdirPerms(LPSTR lpszVdir, LONG pSecParams)
{
  MTVdir aVDir;
  HRESULT hr(S_OK);

  try {
    aVDir.SetIISVdirPerms(string(lpszVdir), pSecParams);
  }
  catch(_com_error e) {
    hr = E_FAIL;
  }

  return SUCCEEDED(hr) ? TRUE : FALSE;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: DeleteIISVdir
// Description	    : 
// Return type		: LONG 
// Argument         : LPSTR lpszVdir
/////////////////////////////////////////////////////////////////////////////

LONG InstCallConvention DeleteIISVdir(LPSTR lpszVdir)
{
	MTVdir aVDir;
	HRESULT hr(S_OK);
	try {
		hr = aVDir.DeleteIISVdir(string(lpszVdir));
 
	}
	catch(_com_error e) {
		hr = e.Error();
	}
	return SUCCEEDED(hr) ? TRUE : FALSE;
}



/////////////////////////////////////////////////////////////////////////////
// Function name	: SetIISvDirBasicAuth
// Description	    : 
// Return type		: LONG 
// Argument         : LPSTR lpszVdir
/////////////////////////////////////////////////////////////////////////////

LONG InstCallConvention SetIISvDirBasicAuth(LPSTR lpszVdir)
{
	MTVdir aVDir;
	HRESULT hr(S_OK);
	try {
		hr = aVDir.SetBasicAuth(string(lpszVdir));
 
	}
	catch(...) {
		hr = E_FAIL;
	}
	return SUCCEEDED(hr) ? TRUE : FALSE;

}
