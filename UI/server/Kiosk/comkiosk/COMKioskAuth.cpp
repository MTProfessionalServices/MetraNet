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
* Created by: Raju Matta 
* $Header$
* 
***************************************************************************/
// ---------------------------------------------------------------------------
// COMKioskAuth.cpp : Implementation of CCOMKioskAuth
// ---------------------------------------------------------------------------
#include "StdAfx.h"
#include "COMKiosk.h"
#include "COMKioskAuth.h"
#include "AuthTicket.h"
#include <mtglobal_msg.h>

#include <MTUtil.h>

#include <loggerconfig.h>

#import <COMKiosk.tlb>


/////////////////////////////////////////////////////////////////////////////
// CCOMKioskAuth

// ---------------------------------------------------------------------------
// Description:   This is the default constructor for this object
// ---------------------------------------------------------------------------
CCOMKioskAuth::CCOMKioskAuth()
{	
	mIsInitialized = FALSE;
	mbAuthValue = FALSE;
}

// ---------------------------------------------------------------------------
// Description:   This is the default constructor for this object
// ---------------------------------------------------------------------------
CCOMKioskAuth::~CCOMKioskAuth() 
{
	mIsInitialized = FALSE;
	mbAuthValue = FALSE;
}

STDMETHODIMP CCOMKioskAuth::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMKioskAuth,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ---------------------------------------------------------------------------
// Description:	This method initializes the underlying C++ Kiosk Auth object
// Errors Raised: 0xE1400008 - KIOSK_AUTHENTICATOR_INITIALIZATION_FAILED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMKioskAuth::Initialize()
{
	// local variables ...
	HRESULT hOK = S_OK;  
	string buffer;
	mIsInitialized = TRUE;  

	// initialize the Kiosk Authenticator object ...
	if (!mKioskAuth.Initialize()) 
	{
		mIsInitialized = FALSE;
		hOK = KIOSK_AUTHENTICATOR_INITIALIZATION_FAILED;
		buffer = "Kiosk Authenticator object cannot be initialized";
		mLogger->LogThis (LOG_ERROR, buffer.c_str());
		return Error (buffer.c_str(), IID_ICOMKioskAuth, hOK) ;
	}

	return (hOK);	
}

// ---------------------------------------------------------------------------
// Description:	This method authenticates the credentials object that gets
//              passed in to it.  The credentials object could contain
//              either a combination of login/password/namespace or a
//              ticket.  The COMCredentials object contains those
//              attributes.   
// Arguments:     LPDISPATCH - A Credentials object that needs
//                authentication  
// Return Value:  A boolean value to indicate if the Credentials object is
//                authentic or not.  For the database authentication piece a
//                bunch of errors are returned and they are listed below.
// Errors Raised: 0xE140034 - ACCOUNT_PASSWORD_INCORRECT 
//                0xE140030 - ACCOUNT_NOT_FOUND_IN_ACCOUNT_TABLES 
//                0xE140031 - ACCOUNT_IN_PENDING_STATE 
//                0xE140032 - ACCOUNT_IN_INACTIVE_STATE 
//                0xE140033 - ACCOUNT_IN_UNKNOWN_STATE 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMKioskAuth::IsAuthentic(LPDISPATCH pCredentials,
										VARIANT_BOOL *bAuthValue)
{
	// local variables ...
	HRESULT hOK = S_OK;  
  ICOMCredentials *pCOMCred;
	string buffer;
  
  // Add an entry in the t_user_credentials table
  if (mIsInitialized == FALSE)
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED; 
	  buffer = "Unable to verify authenticity. Authenticator not initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMKioskAuth, hOK) ;
  }

  //	----------------------- Credentials stuff --------------------------
  
  // get the interface for the com credentials ...
	hOK = pCredentials->QueryInterface (IID_ICOMCredentials, (void **) &pCOMCred);
  if (!SUCCEEDED(hOK))
  {
	  buffer = "Unable to get com credential interface";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMKioskAuth, hOK) ;
  }
  BSTR login;
  BSTR pwd;
  BSTR name_space;
  BSTR ticket;

  // Cast the pCredential Dispatch pointer to a pointer to the interface
  // This is done so that the credentials object can be ripped apart
  pCOMCred->get_LoginID(&login);
  pCOMCred->get_Pwd(&pwd);
  pCOMCred->get_Name_Space(&name_space);
  pCOMCred->get_Ticket(&ticket);

  // copy the parameters ... dont need to do a SysFreeString ... the 
  // _bstr_t will do one when it's destructed ...
  _bstr_t bstrLogin (login,false) ;
  _bstr_t bstrPwd (pwd,false) ;
  _bstr_t bstrNamespace (name_space,false) ;
  _bstr_t bstrTicket(ticket,false);

  if (bstrTicket.length()!=0)
  {
	  CAuthenticationTicket AuthTicket;
    if (!AuthTicket.Initialize())
    {
      hOK = KIOSK_ERR_NOT_INITIALIZED; 
    	buffer = "Unable to Initialize ticket authentication";
      mLogger->LogThis (LOG_ERROR, buffer.c_str());
      *bAuthValue = VARIANT_FALSE;
      return Error (buffer.c_str(), IID_ICOMKioskAuth, hOK) ;
    }

	  wstring sTicketAccountID(L"");
	  wstring sTicketNamespace(L"");
    wstring sResolvedAccountID(L"");

		wstring sTicketLoggedInAs(L"");
		wstring sTicketApplicationName(L"");

    _bstr_t bstrResolvedAccountId;
		_bstr_t bstrResolvedLoggedInAs;
		_bstr_t bstrResolvedApplicationName;

		if (AuthTicket.GetAccountIdentifier(bstrTicket,sTicketAccountID,sTicketNamespace,sTicketLoggedInAs,sTicketApplicationName))
	  {
      //Check to see if we need to map account identifier to a different namespace
      if (sTicketNamespace.compare(bstrNamespace)!=0)
      {
        try
        {
		      // Resolve the actual username and namespace through the account mapper table
          COMKIOSKLib::ICOMAccountMapperPtr accountMapper(MTPROGID_ACCOUNT_MAPPER);
          accountMapper->Initialize();

          BSTR AccountID;
          accountMapper->MapAccountIdentifier(sTicketAccountID.c_str(), sTicketNamespace.c_str(), bstrNamespace, &AccountID);

          //_bstr_t temp(sTicketAccountID);
		      //_bstr_t temp("demo");

		      //pCOMCred->put_Name_Space(temp);
		      //pCOMCred->put_LoginID(AccountID);
          bstrResolvedAccountId=_bstr_t(AccountID);
          *bAuthValue = VARIANT_TRUE;
        }
        catch (_com_error e)
        {
          *bAuthValue = VARIANT_FALSE;
          return Error ("Unable to map account identifier", IID_ICOMKioskAuth, e.Error());
        }
      }
      else
      {
        bstrResolvedAccountId=_bstr_t(sTicketAccountID.c_str());
        *bAuthValue = VARIANT_TRUE;
      }

      //Verify account exists
      BOOL bAccountExists;
      
      bAccountExists=mKioskAuth.AccountExists(bstrResolvedAccountId, bstrNamespace);

      if (bAccountExists)
      {
	      pCOMCred->put_LoginID(bstrResolvedAccountId);
      }
      else
      {
				*bAuthValue = VARIANT_FALSE ;
				return hOK;
      }

			bstrResolvedLoggedInAs			= _bstr_t(sTicketLoggedInAs.c_str());
			bstrResolvedApplicationName = _bstr_t(sTicketApplicationName.c_str());

			pCOMCred->put_LoggedInAs(bstrResolvedLoggedInAs);
			pCOMCred->put_ApplicationName(bstrResolvedApplicationName);
	  }
    else
    {
      //Unable to authenticate ticket; nothing else to be done
      *bAuthValue = VARIANT_FALSE ;
    }
  }
  else
  {
      //Not using ticket authentication, authenticate using password
	  hOK = mKioskAuth.IsAuthentic (bstrLogin, bstrPwd, bstrNamespace);
    if (SUCCEEDED(hOK))
    {
      *bAuthValue = VARIANT_TRUE ;
    }
  }

  // release the ref ...
  pCOMCred->Release() ;

	return hOK;	
}

// ---------------------------------------------------------------------------
// Description:	  This method adds an entry to the t_user_credentials table
//                using the C++ Kiosk Auth object.
// Arguments:     Login - Login that the password needs to be changed for
//                Password - Password associated with the login
//                Name_Space - Namespace that uniquely identifies the login  
//                LPDISPATCH - A Rowset object that maintains transactions
// Errors Raised: 0xE14000F - KIOSK_ERR_ADDUSER_FAILED 
//                0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMKioskAuth::AddUser(BSTR login, BSTR pwd, BSTR name_space, LPDISPATCH pRowset)
{
	// local variables ...
	HRESULT hOK = S_OK;  

	// Add an entry in the t_user_credentials table
	if (mIsInitialized == TRUE)
	{
    if (!mKioskAuth.AddUser(login, pwd, name_space, pRowset))
    {
      hOK = KIOSK_ERR_ADDUSER_FAILED;
      mLogger->LogVarArgs (LOG_ERROR,
        "Unable to add user. Error = <%x>", hOK);
      return Error ("Unable to add user.", IID_ICOMKioskAuth, hOK) ;
    }
  }
	else
	{
		hOK = KIOSK_ERR_NOT_INITIALIZED; 
		mLogger->LogVarArgs (LOG_ERROR,
							"Unable to add user. Authenticator not initialized. Error = <%x>", hOK);
    return Error ("Unable to add user. Authenticator not initialized.",
      IID_ICOMKioskAuth, hOK) ;
	}

	return (hOK);	
}

// ----------------------------------------------------------------------------
// *****Obsolete****
//
// Name:     	  HashString 
//
// Arguments:     StringToBeHashed  
//
// Return Value:  Returns the MD5 hash value. 
//
// Errors Raised:
//     Unable to hash the concatenated string.
//
// Description:   
//   The MetraTech account username for ConferenceExpress users is a hash
// ----------------------------------------------------------------
STDMETHODIMP CCOMKioskAuth::HashString(BSTR StringToBeHashed, 
									BSTR* HashedString)
{
  HRESULT hr = S_OK;

  try
  {
    // check if object is initialized or not
    if (mIsInitialized != TRUE)
    {
			hr = KIOSK_ERR_NOT_INITIALIZED; 
    	return Error ("Unable to hash string. Authenticator not initialized.",
										IID_ICOMKioskAuth, hr) ;
		}

    string rwStringToBeHashed;
    WideStringToUTF8(StringToBeHashed, rwStringToBeHashed);

  	mLogger->LogVarArgs (LOG_DEBUG, "Before Hashing = <%s>", rwStringToBeHashed);

  	string rwHashedString;

  	if (!MTMiscUtil::ConvertStringToMD5(rwStringToBeHashed.c_str(), rwHashedString))
  	{
  		hr = CREDITCARDACCOUNT_ERR_HASHING_FAILED;
  		return Error("Unable to hash string", IID_ICOMKioskAuth, hr);
  	}

  	_bstr_t bstrHashedString = rwHashedString.c_str();
  	mLogger->LogVarArgs (LOG_DEBUG, "After Hashing = <%s>", rwHashedString);
  	
  	*HashedString = bstrHashedString.copy();
  }
  catch (_com_error e)
  {
    string buffer = "Exception occurred while generating the hash string."; 
    mLogger->LogThis(LOG_ERROR, buffer.c_str()); 
    return Error(buffer.c_str(), IID_ICOMKioskAuth, hr);
  }

	return S_OK;
}