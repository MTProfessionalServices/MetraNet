/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by:  Raju Matta
* $Header: c:\development35\UI\server\Kiosk\comkiosk\COMCredentials.cpp, 25, 7/26/2002 5:54:33 PM, Raju Matta$
* 
***************************************************************************/
// ---------------------------------------------------------------------------
// COMCredentials.cpp : Implementation of CCOMCredentials
// ---------------------------------------------------------------------------
#include "StdAfx.h"
#include "COMKiosk.h"
#include "COMCredentials.h"
#include <mtglobal_msg.h>

#include <loggerconfig.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMCredentials

// ---------------------------------------------------------------------------
// Description:   This is the default constructor for this object
// ---------------------------------------------------------------------------
CCOMCredentials::CCOMCredentials()
{	
    HRESULT hOK = S_OK;

	mIsInitialized = TRUE;

	if (!mCredentials.Initialize())
	{
		// null the pointer 
		mIsInitialized = FALSE;
		hOK = CREDENTIALS_INITIALIZATION_FAILED;
		mLogger->LogVarArgs (LOG_ERROR,
							"Credentials object cannot be initialized. Error = <%x>", hOK);
	}
}

// ---------------------------------------------------------------------------
// Description:   This is the default destructor for this object
// ---------------------------------------------------------------------------
CCOMCredentials::~CCOMCredentials() 
{
	// uninitialize the instance
	mIsInitialized = FALSE;
}

STDMETHODIMP CCOMCredentials::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMCredentials,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ---------------------------------------------------------------------------
// Description:	This property method gets the LoginID property 
// Errors Raised: 0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMCredentials::get_LoginID(BSTR * pVal)
{
  HRESULT hOK = S_OK;
  
  // TODO: Add your implementation code here
  if (mIsInitialized == TRUE)
  {
    *pVal = SysAllocString(mCredentials.GetLoginName().c_str());
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to get login id. Credentials not initialized. Error = <%x>", hOK);
    return Error ("Unable to get login id. Credentials not initialized.",
      IID_ICOMCredentials, hOK) ;
  }
    
	return (hOK);
}

// ---------------------------------------------------------------------------
// Description:	This property method sets the LoginID property 
// Errors Raised: 0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMCredentials::put_LoginID(BSTR newVal)
{
  HRESULT hOK = S_OK;
  
  // check for mIsInitialized flag or the existence of the pointer
  if (mIsInitialized == TRUE)
  {
    _bstr_t sLoginName = newVal;
    mCredentials.SetLoginName((wchar_t*)sLoginName);
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to put login id. Credentials not initialized. Error = <%x>", hOK);
    return Error ("Unable to put login id. Credentials not initialized.",
      IID_ICOMCredentials, hOK) ;
  }
  
	return (hOK);
}

// ---------------------------------------------------------------------------
// Description:	This property method gets the NameSpace property 
// Errors Raised: 0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMCredentials::get_Name_Space(BSTR * pVal)
{
	HRESULT hOK = S_OK;

	// check for mIsInitialized flag or the existence of the pointer
  if (mIsInitialized == TRUE)
  {
    *pVal = SysAllocString(mCredentials.GetName_Space().c_str());
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to get namespace. Credentials not initialized. Error = <%x>", hOK);
    return Error ("Unable to get namespace. Credentials not initialized.",
      IID_ICOMCredentials, hOK) ;
  }

	return (hOK);
}

// ---------------------------------------------------------------------------
// Description:	This property method sets the NameSpace property 
// Errors Raised: 0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMCredentials::put_Name_Space(BSTR newVal)
{
	HRESULT hOK = S_OK;

	// check for mIsInitialized flag or the existence of the pointer
  if (mIsInitialized == TRUE)
  {
    _bstr_t sNameSpace = newVal;
    mCredentials.SetName_Space((wchar_t*)sNameSpace);
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to put namespace. Credentials not initialized. Error = <%x>", hOK);
    return Error ("Unable to put namespace. Credentials not initialized.",
      IID_ICOMCredentials, hOK) ;
  }

	return (hOK);
}

// ---------------------------------------------------------------------------
// Description:	This property method gets the Certificate property.  Not
//              implemented for this release
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMCredentials::get_Certificate(BSTR * pVal)
{
	return E_NOTIMPL;
}

// ---------------------------------------------------------------------------
// Description:	This property method sets the Certificate property.  Not
//              implemented for this release
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMCredentials::put_Certificate(BSTR newVal)
{
	return E_NOTIMPL;
}

// ---------------------------------------------------------------------------
// Description:	This property method gets the NameSpace property 
// Errors Raised: 0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMCredentials::get_Pwd(BSTR * pVal)
{
  HRESULT hOK = S_OK;
  
  // TODO: Add your implementation code here
  if (mIsInitialized == TRUE)
  {
    *pVal = SysAllocString(mCredentials.GetPwd().c_str());
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogThis (LOG_ERROR, "Unable to get password. Credentials not initialized");
    return Error ("Unable to get password. Credentials not initialized.",
      IID_ICOMCredentials, hOK) ;
  }

	return (hOK);
}

// ---------------------------------------------------------------------------
// Description:	This property method sets the NameSpace property 
// Errors Raised: 0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMCredentials::put_Pwd(BSTR newVal)
{
  HRESULT hOK = S_OK;
  
  // check for mIsInitialized flag or the existence of the pointer
  if (mIsInitialized == TRUE)
  {
	// validate the password 
	// check for special characters - ASCII codes from 33 to 126
	//string strPassword = (const char *) _bstr_t(newVal);

#if 0 // no more checking for non ascii characters
	for (unsigned int i = 0; i < strPassword.size(); i++)
	{
	    char charPassword = strPassword.at(i); 
		int asciiCharPassword = int(charPassword);
		if ((asciiCharPassword < 33) || (asciiCharPassword > 126))
		{
		  mLogger->LogThis (LOG_ERROR, 
						   "Password contains characters other than printable ascii characters");
		  return Error ("Password contains characters other than printable ascii characters",
						IID_ICOMCredentials, E_FAIL) ;
		}
	}
#endif // no more checking for non ascii characters
	
   _bstr_t sPW = newVal;
    mCredentials.SetPwd(sPW);
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogThis (LOG_ERROR, "Unable to put password. Credentials not initialized");
    return Error ("Unable to put password. Credentials not initialized.",
      IID_ICOMCredentials, hOK) ;
  }
  
  return (hOK);
}

// ---------------------------------------------------------------------------
// Description:	This property method gets the Ticket property 
// Errors Raised: 0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMCredentials::get_Ticket(BSTR *pVal)
{
  HRESULT hOK = S_OK;
  
  if (mIsInitialized == TRUE)
  {
    *pVal = SysAllocString(mCredentials.GetTicket().c_str());
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogThis (LOG_ERROR, "Unable to get ticket. Credentials not initialized");
    return Error ("Unable to get ticket. Credentials not initialized.",
      IID_ICOMCredentials, hOK) ;
  }

	return (hOK);
}

// ---------------------------------------------------------------------------
// Description:	This property method puts the Ticket property 
// Errors Raised: 0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMCredentials::put_Ticket(BSTR newVal)
{
  HRESULT hOK = S_OK;
  
  // check for mIsInitialized flag or the existence of the pointer
  if (mIsInitialized == TRUE)
  {
    _bstr_t sTicket = newVal;
    mCredentials.SetTicket((wchar_t*)sTicket);
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogThis (LOG_ERROR, "Unable to put ticket. Credentials not initialized");
    return Error ("Unable to put ticket. Credentials not initialized.",
      IID_ICOMCredentials, hOK) ;
  }
  
  return (hOK);
}

STDMETHODIMP CCOMCredentials::get_LoggedInAs(BSTR *pVal)
{
	*pVal = mLoggedInAs.copy();
	return S_OK;
}

STDMETHODIMP CCOMCredentials::put_LoggedInAs(BSTR newVal)
{
	mLoggedInAs = newVal;	
	return S_OK;
}

STDMETHODIMP CCOMCredentials::get_ApplicationName(BSTR *pVal)
{
	*pVal = mApplicationName.copy();
	return S_OK;
}

STDMETHODIMP CCOMCredentials::put_ApplicationName(BSTR newVal)
{
	mApplicationName = newVal;
	return S_OK;
}