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
// COMAccount.cpp : Implementation of CCOMAccount
// ---------------------------------------------------------------------------
#include "StdAfx.h"
#include "COMKiosk.h"
#include "COMAccount.h"
#include <mtglobal_msg.h>

#include <loggerconfig.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMAccount

STDMETHODIMP CCOMAccount::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_ICOMAccount
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

// ---------------------------------------------------------------------------
// Description:   This is the default constructor for this object
// ---------------------------------------------------------------------------
CCOMAccount::CCOMAccount()
{	
  mIsInitialized = FALSE;
  mIsAccountInfoAvailable = FALSE;
}

// ---------------------------------------------------------------------------
// Description:   This is the default destructor for this object
// ---------------------------------------------------------------------------
CCOMAccount::~CCOMAccount() 
{
  mIsInitialized = FALSE;
  mIsAccountInfoAvailable = FALSE;
}

// ---------------------------------------------------------------------------
// Description:	This method initializes the underlying C++ account object
// Errors Raised: 0xE140002F - ACCOUNT_INITIALIZATION_FAILED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::Initialize()
{
  // local variables ...
  string buffer;
  HRESULT hOK = S_OK;  
  
  
  // initialize the account mapper object...
  if (!mAccount.Initialize ())
  {
    // null the pointer 
    mIsInitialized = FALSE;
    hOK = ACCOUNT_INITIALIZATION_FAILED;
		buffer = "Unable to initialize account object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMAccount, hOK) ;
  }
  else
  {
    mIsInitialized = TRUE;
  }
  
  return (hOK);	
}

// ---------------------------------------------------------------------------
// Description:   This method will add an entry to the t_account table.  It 
//                does that through the C++ account object. 
// Arguments:     AccountType - account type indicating Bill-To or Ship-To 
//                TariffID - tariff ID that the user is associated to
//                GeoCode - geocode value specific to a city/state/zip combo
//                used for rating.                 
//                TaxExemptFlag - Y or N flag for tax exempt purposes
//                TimezoneID - timezone ID unique to the user
//                TimezoneOffset - timezone offset corresponding to the 
//                timezone ID 
//                PaymentMethod - 1 --> None, 2 --> Credit Card 
//                pRowset - A rowset object that manages transactions
// Return Value:  Uniquely generated account ID
// Errors Raised: 0xE14000C - KIOSK_ERR_ADD_FAILED 
//                0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
//                0xE140018 - KIOSK_ERR_ACCOUNT_ALREADY_EXISTS 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::Add(	long aAccountStatus,
																LPDISPATCH pRowset, 
																long* pAcctID)
{
  // local variables ...
  long acctID;
  string buffer;
  HRESULT hOK = S_OK;  
  
  // check for mIsInitialized flag or the existence of the pointer
  if (mIsInitialized == TRUE)
  {
    if (!mAccount.Add (aAccountStatus, pRowset, acctID))
    {
		// null the pointer 
		mIsInitialized = FALSE;
        hOK = KIOSK_ERR_ADD_FAILED;
		buffer = "Unable to add new account";
        mLogger->LogThis (LOG_ERROR, buffer.c_str());
        return Error (buffer.c_str(), IID_ICOMAccount, hOK) ;
    }
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
	  buffer = "Account object not initialized";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMAccount, hOK) ;
  }
  
  *pAcctID = acctID ;
  
  // check to see if the account already exists
  if (acctID == -99)
  {
    // null the pointer 
    hOK = KIOSK_ERR_ACCOUNT_ALREADY_EXISTS;
	  buffer = "Account already exists";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMAccount, hOK) ;
  }
  
  return (hOK);	
}

// ---------------------------------------------------------------------------
// Description:   Get the account ID property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_AccountID(long *pVal)
{
    *pVal = mAccountID;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Set the account ID property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_AccountID(long newVal)
{
    mAccountID = newVal;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Get the tariff name property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_TariffName(BSTR *pVal)
{
    *pVal = mTariffName.copy();
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Set the tariff name property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_TariffName(BSTR newVal)
{
    mTariffName = newVal;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Get the geocode property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_GeoCode(long *pVal)
{
    *pVal = mGeoCode;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Set the geocode property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_GeoCode(long newVal)
{
    mGeoCode = newVal;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Get the tax exempt string
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_TaxExempt(BSTR *pVal)
{
    *pVal = mTaxExempt.copy();
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Set the tax exempt string
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_TaxExempt(BSTR newVal)
{
    mTaxExempt = newVal;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Get the timezone ID
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_TimezoneID(long *pVal)
{
    *pVal = mTimezoneID;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Set the timezone ID
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_TimezoneID(long newVal)
{
    mTimezoneID = newVal;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Get the timezone offset
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_TimezoneOffset(double *pVal)
{
    *pVal = mTimezoneOffset;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Set the timezone offset
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_TimezoneOffset(double newVal)
{
    mTimezoneOffset = newVal;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Get the payment method
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_PaymentMethod(long *pVal)
{
    *pVal = mPaymentMethod;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Set the payment method
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_PaymentMethod(long newVal)
{
    mPaymentMethod = newVal;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Get the start date
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_StartDate(VARIANT *pVal)
{
    *pVal = mStartDate;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Set the start date
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_StartDate(VARIANT newVal)
{
    mStartDate = newVal;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Get the end date
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_EndDate(VARIANT *pVal)
{
    *pVal = mEndDate;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Set the end date
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_EndDate(VARIANT newVal)
{
    mEndDate = newVal;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Get the currency property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_Currency(BSTR *pVal)
{
    *pVal = mCurrency.copy();
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Set the currency property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_Currency(BSTR newVal)
{
    mCurrency = newVal;
	return S_OK;
}


// ---------------------------------------------------------------------------
// Description:   This method is used to get account information from the
//                database.  It gets called from the account resolution
//                plugin within the pipeline.  Different errors are raise on
//                different conditions that occur within the database.  For
//                a login/namespace combination, there is always going to be
//                one account in the t_account table.
// Arguments:     Login - Login ID or user name to be created
//                Name_Space - Namespace to be created
// Return Value:  None
// Errors Raised: 0xE14001B - KIOSK_ERR_ACCOUNT_NOT_FOUND 
//                0xE14001C - KIOSK_ERR_MORE_THAN_ONE_ACC 
//                0xE140019 - KIOSK_ERR_GET_ACCOUNT_INFO_FAILED 
//                0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::GetAccountInfo(BSTR Login, BSTR Name_Space)
{
  	// local variables ...
 	HRESULT hOK = S_OK;  
	string buffer;
	long returncode = 0;
	string strLogin = (const char*) _bstr_t(Login);
	string strName_Space = (const char*) _bstr_t(Name_Space);
  	
  	// check for mIsInitialized flag or the existence of the pointer
  	if (mIsInitialized == TRUE)
  	{
    	returncode = mAccount.GetAccountInfo (Login, Name_Space);
      switch (returncode)
      {
        // no rows found
      case -99:
        hOK = KIOSK_ERR_ACCOUNT_NOT_FOUND;
        buffer = "No accounts were found for login <" + strLogin +
          "> and namespace <" + strName_Space.c_str() + ">";
        mLogger->LogThis (LOG_WARNING, buffer.c_str());
        return Error (buffer.c_str(), IID_ICOMAccount, hOK);
        break;
        
        // more than one row found
      case -100:
        hOK = KIOSK_ERR_MORE_THAN_ONE_ACC;
        buffer = "More than one account was found for login <" + strLogin +
          "> and namespace <" + strName_Space.c_str() + ">";
        mLogger->LogThis (LOG_ERROR, buffer.c_str());
        return Error (buffer.c_str(), IID_ICOMAccount, hOK);
        break;
        
        // failure
      case -1:
        hOK = KIOSK_ERR_GET_ACCOUNT_INFO_FAILED;
        buffer = "Retrieval of account information failed for login <" + strLogin +
          "> and namespace <" + strName_Space + ">";
        mLogger->LogThis (LOG_ERROR, buffer.c_str());
        return Error (buffer.c_str(), IID_ICOMAccount, hOK);
        break;
        
        // success
      case 0:
        put_TimezoneOffset(mAccount.GetTimezoneOffset());
        put_TimezoneID(mAccount.GetTimezoneID());
        put_TaxExempt((_bstr_t)mAccount.GetTaxExempt().c_str());
        put_GeoCode(mAccount.GetGeoCode());
        put_TariffName((_bstr_t)mAccount.GetTariffName().c_str());
        put_AccountID(mAccount.GetAccountID());
        put_PaymentMethod(mAccount.GetPaymentMethod());
        put_StartDate(mAccount.GetStartDate());
        put_EndDate(mAccount.GetEndDate());
        put_TariffID(mAccount.GetTariffID());
        put_Currency((_bstr_t)mAccount.GetCurrency().c_str());
        put_AccountCycleID(mAccount.GetAccountCycleID());
        break;
        
      default:
        break;
      }
    }
  	else
  	{
    	hOK = KIOSK_ERR_NOT_INITIALIZED;
		  buffer = "Unable to get account information. Account object not initialized";
    	mLogger->LogThis (LOG_ERROR, buffer.c_str());
    	return Error (buffer.c_str(), IID_ICOMAccount, hOK) ;
  	}

	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Get the tariff ID property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_TariffID(long *pVal)
{
    *pVal = mTariffID;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Set the tariff ID property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_TariffID(long newVal)
{
    mTariffID = newVal;
	return S_OK;
}


// ---------------------------------------------------------------------------
// Description:   This method is used to get account information from the
//                database.  It gets called from the account resolution
//                plugin within the pipeline.  Different errors are raise on
//                different conditions that occur within the database.  The
//                only difference between the method GetAccountInfo is that
//                it takes in the login/namespace combination, as opposed to
//                the account ID.
// Arguments:     Login - Login ID or user name to be created
//                Name_Space - Namespace to be created
// Return Value:  None
// Errors Raised: 0xE14001B - KIOSK_ERR_ACCOUNT_NOT_FOUND 
//                0xE14001C - KIOSK_ERR_MORE_THAN_ONE_ACC 
//                0xE140019 - KIOSK_ERR_GET_ACCOUNT_INFO_FAILED 
//                0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::GetAccountInfoForAccountID(long AccountID)
{
 	// local variables ...
 	HRESULT hOK = S_OK;  
	string buffer;
	long returncode;

	char strAccountID[12];
	sprintf_s(strAccountID, sizeof(strAccountID), "%ld", AccountID);
	string sAccountID = strAccountID;
  	
  	// check for mIsInitialized flag or the existence of the pointer
  	if (mIsInitialized == TRUE)
  	{
    	returncode = mAccount.GetAccountInfo (AccountID);
		switch (returncode)
		{
		    // no rows found
		  	case -99:
			  	hOK = KIOSK_ERR_ACCOUNT_NOT_FOUND;
				  buffer = string("No accounts were found for accountID <") +
				  sAccountID + ">";
        		mLogger->LogThis (LOG_WARNING, buffer.c_str());
				return Error (buffer.c_str(), IID_ICOMAccount, hOK);
				break;

		    // more than one row found
		  	case -100:
			  	hOK = KIOSK_ERR_MORE_THAN_ONE_ACC;
				  buffer = string("More than one account was found for accountID  <") +
				  sAccountID + ">";
        		mLogger->LogThis (LOG_ERROR, buffer.c_str());
				return Error (buffer.c_str(), IID_ICOMAccount, hOK);
				break;

			// failure
		  	case -1:
			  	hOK = KIOSK_ERR_GET_ACCOUNT_INFO_FAILED;
				  buffer = string("Retrieval of account information failed for accountID <") +
				  sAccountID + ">";
        		mLogger->LogThis (LOG_ERROR, buffer.c_str());
				return Error (buffer.c_str(), IID_ICOMAccount, hOK);
				break;

			// success
		  	case 0:
			  	put_TimezoneOffset(mAccount.GetTimezoneOffset());
			  	put_TimezoneID(mAccount.GetTimezoneID());
				put_TaxExempt((_bstr_t)mAccount.GetTaxExempt().c_str());
				put_GeoCode(mAccount.GetGeoCode());
				put_TariffName((_bstr_t)mAccount.GetTariffName().c_str());
				put_AccountID(mAccount.GetAccountID());
				put_PaymentMethod(mAccount.GetPaymentMethod());
				put_StartDate(mAccount.GetStartDate());
				put_EndDate(mAccount.GetEndDate());
				put_TariffID(mAccount.GetTariffID());
				
				put_Currency((_bstr_t)mAccount.GetCurrency().c_str());
				put_AccountCycleID(mAccount.GetAccountCycleID());
				break;
		  
		  	default:
				break;
		}
  	}
  	else
  	{
    	hOK = KIOSK_ERR_NOT_INITIALIZED;
		  buffer = "Unable to get account information. Account object not initialized";
    	mLogger->LogThis (LOG_ERROR, buffer.c_str());
    	return Error (buffer.c_str(), IID_ICOMAccount, hOK) ;
  	}

	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   The C++ object underneath has a member function that gets
//                called to get the actual value.
// Return Value:  An integer flag value indicating if it is active or not
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::IsActiveAccount(int* flag)
{
	(*flag)	= mAccount.IsActiveAccount();
	return S_OK;
}


// ---------------------------------------------------------------------------
// Description:   The C++ object underneath has a member function that gets
//                called to get the actual value.
// Return Value:  An integer flag value indicating if it is active or not
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::Update(BSTR Login,
                                 BSTR Namespace,
								 VARIANT AccountEndDate,
								 long alAccountStatus)
{
  	// local variables ...
  	HRESULT hOK = S_OK;  
  	string buffer;

  	// check for mIsInitialized flag or the existence of the pointer
  	if (mIsInitialized == TRUE)
  	{
    	if (!mAccount.Update (Login, Namespace, AccountEndDate.bstrVal, 
    	                      alAccountStatus))
		{
			buffer = "Unable to update account information";
			mLogger->LogThis (LOG_ERROR, buffer.c_str());
    		return Error (buffer.c_str(), IID_ICOMAccount, hOK) ;
		}
  	}
  	else
  	{
    	hOK = KIOSK_ERR_NOT_INITIALIZED;
		  buffer = "Unable to update account. Account object not initialized";
    	mLogger->LogThis (LOG_ERROR, buffer.c_str());
    	return Error (buffer.c_str(), IID_ICOMAccount, hOK) ;
  	}
	return S_OK;
}


// ---------------------------------------------------------------------------
// Description:   Get the account Cycle ID property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::get_AccountCycleID(long *pVal)
{
  *pVal = mAccountCycleID;
	return S_OK;
}


// ---------------------------------------------------------------------------
// Description:   Set the account Cycle ID property
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMAccount::put_AccountCycleID(long newVal)
{
  mAccountCycleID = newVal;
	return S_OK;
}

