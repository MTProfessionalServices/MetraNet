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
// COMUserConfig.cpp : Implementation of CCOMUserConfig
// ---------------------------------------------------------------------------
#include "StdAfx.h"
#include "COMKiosk.h"
#include "COMUserConfig.h"
#include <mtglobal_msg.h>

#include <loggerconfig.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMUserConfig

// ---------------------------------------------------------------------------
// Description:   This is the default constructor for this object
// ---------------------------------------------------------------------------
CCOMUserConfig::CCOMUserConfig()
: mIsInitialized(FALSE)
{	
}

// ---------------------------------------------------------------------------
// Description:   This is the default destructor for this object
// ---------------------------------------------------------------------------
CCOMUserConfig::~CCOMUserConfig() 
{
  // uninitialize the instance
  mIsInitialized = FALSE;
}

STDMETHODIMP CCOMUserConfig::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMUserConfig,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ---------------------------------------------------------------------------
// Description:   This method will initialize the underlying C++ User Config
//                object.  The underlying C++ object basically initializes
//                itself with the databsase and the logger.
// Errors Raised: 0xE14000A - USER_CONFIG_INITIALIZATION_FAILED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMUserConfig::Initialize()
{
  // local variables ...
  string buffer;
  HRESULT hOK = S_OK;  
  
  // initialize the UserConfig server ...
  if (!mUserConfig.Initialize ())
  {
    // null the pointer 
    mIsInitialized = FALSE;
    hOK = USER_CONFIG_INITIALIZATION_FAILED;
	buffer = "Unable to initialize user config object";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMUserConfig, hOK) ;
  }
  else
  {
    mIsInitialized = TRUE ;
  }
  
  return (hOK);	
}

// ---------------------------------------------------------------------------
// Description:   This method will load the default user profile configuration
// Errors Raised: 0xE1400037 - KIOSK_ERR_LOADING_DEFAULT_USER_CONFIGURATION_FAILED
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMUserConfig::LoadDefaultUserConfiguration(BSTR ExtensionName)
{
  // local variables ...
  string buffer;
  HRESULT hOK = S_OK;  
  
  // initialize the UserConfig server ...
  if (!mUserConfig.LoadDefaultUserConfiguration (ExtensionName))
  {
    // null the pointer 
    mIsInitialized = FALSE;
    hOK = KIOSK_ERR_LOADING_DEFAULT_USER_CONFIGURATION_FAILED;
	buffer = "Unable to default user configuration";
    mLogger->LogThis (LOG_ERROR, buffer.c_str());
    return Error (buffer.c_str(), IID_ICOMUserConfig, hOK) ;
  }
  
  return (hOK);	
}

// ---------------------------------------------------------------------------
// Description:   This method, through the internal C++ user config object,
//                will create an internal map of the profile name value
//                pair. The login / namespace combination will yield the
//                profile values.
// Arguments:     Login - Login ID or username associated with an account
//                Name_Space - Namespace uniquely identifying an account 
// Errors Raised: 0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMUserConfig::GetConfigInfo(BSTR login, BSTR name_space)
{
  // local variables ...
  HRESULT hOK = S_OK;  

  if (mIsInitialized == TRUE)
  {
    // initialize the UserConfig server ...
    if (!mUserConfig.GetConfigInfo(login, name_space))
    {
      const ErrorObject *pError = mUserConfig.GetLastError() ;
      hOK = pError->GetCode() ;
      
      mLogger->LogVarArgs (LOG_ERROR,
        "Unable to get user configuration value. Error = <%x>", hOK);
      return Error ("Unable to get user configuration value.",
        IID_ICOMUserConfig, hOK) ;
    }
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to get user configuration value. User config not initialized. Error = <%x>", hOK);
    return Error ("Unable to get user configuration value. User config not initialized",
      IID_ICOMUserConfig, hOK) ;
  }

  return (hOK);	
}

// ---------------------------------------------------------------------------
// Description:   This method will add an entry to the t_site_user,
//                t_localized_site, and t_profile tables through the
//                underlying C++ user config object.  First, the object
//                checks to see if an entry exists in the localized site
//                table for the language that is passed in.  If it does,
//                then it get the localized site ID back.  If it does not,
//                then it creates a new one and gets that new ID back.
//                After that, profile records are added to the t_profile
//                table for that login.  The unique profile ID is retrieved
//                from the t_current_id table, which stores the next
//                incremented ID for id_profile column.  With id_profile and
//                id_site, an entry is made into the t_site_user table.  All
//                this happens in a transaction and is considered as one
//                atomic unit of work. 
// Arguments:     Login - Login ID or username
//                Name_space - Uniquely identifies an account 
//                LangCode - Language Code (e.g. US for US-English, FR for
//                French)
//                Account ID - MetraTech generated account ID 
//                pRowset - A rowset object that manages transactions
// Return Value:  Uniquely generated account ID
// Errors Raised: 0xE14000F - KIOSK_ERR_ADDUSER_FAILED 
//                0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMUserConfig::Add(BSTR login, BSTR name_space, BSTR langCode, 
                                 long lAccID, long TimezoneID, LPDISPATCH pRowset)
{
  // local variables ...
  HRESULT hOK = S_OK;  
  
  if (mIsInitialized == TRUE)
  {
    // add the user config ...
    if (!mUserConfig.Add (login, name_space, langCode, lAccID, TimezoneID, pRowset))
    {
      mIsInitialized = FALSE;
      hOK = KIOSK_ERR_ADDUSER_FAILED;
      mLogger->LogVarArgs (LOG_ERROR,
        "Unable to add new user. Error = <%x>", hOK);
      return Error ("Unable to add new user",
        IID_ICOMUserConfig, hOK) ;
    }
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to add user. User config not initialized. Error = <%x>", hOK);
    return Error ("Unable to add user. User config not initialized",
      IID_ICOMUserConfig, hOK) ;
  }
  
  return (hOK);	
}


// ---------------------------------------------------------------------------
// Description:   This method will delete an entry from the t_site_user table
// Arguments:     Login - Login ID or username
//                Name_space - Uniquely identifies an account 
//                LangCode - Language Code (e.g. US for US-English, FR for
//                French)
//                Account ID - MetraTech generated account ID 
//                pRowset - A rowset object that manages transactions
// Return Value:  Uniquely generated account ID
// Errors Raised: 0xE14000F - KIOSK_ERR_ADDUSER_FAILED 
//                0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMUserConfig::Delete(BSTR login, BSTR name_space, BSTR langCode, 
									long lAccID, long TimezoneID, LPDISPATCH pRowset)
{
  // local variables ...
  HRESULT hOK = S_OK;  
  
  if (mIsInitialized == TRUE)
  {
    // add the user config ...
    if (!mUserConfig.Delete (login, name_space, langCode, lAccID, TimezoneID, pRowset))
    {
      mIsInitialized = FALSE;
      hOK = KIOSK_ERR_ADDUSER_FAILED;
      mLogger->LogVarArgs (LOG_ERROR,
        "Unable to add new user. Error = <%x>", hOK);
      return Error ("Unable to add new user",
        IID_ICOMUserConfig, hOK) ;
    }
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to add user. User config not initialized. Error = <%x>", hOK);
    return Error ("Unable to add user. User config not initialized",
      IID_ICOMUserConfig, hOK) ;
  }
  
  return (hOK);	
}



// ---------------------------------------------------------------------------
// Description:   This method updates the language for a login / namespace
//                combination.
// Arguments:     Login - Login ID or username
//                Name_space - Uniquely identifies an account 
//                LangCode - Language Code (e.g. US for US-English, FR for
//                French)
// Errors Raised: 0xE14000F - UPDATE_USER_LANGUAGE_FAILED 
//                0xE140002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMUserConfig::UpdateUserLanguage(BSTR login, BSTR name_space, BSTR langCode)
{
  // local variables ...
  HRESULT hOK = S_OK;  
  
  if (mIsInitialized == TRUE)
  {
    // add the user config ...
    if (!mUserConfig.UpdateUserLanguage (login, name_space, langCode))
    {
      hOK = UPDATE_USER_LANGUAGE_FAILED;
      mLogger->LogVarArgs (LOG_ERROR,
        "Unable to add new user. Error = <%x>", hOK);
      return Error ("Unable to add new user",
        IID_ICOMUserConfig, hOK) ;
    }
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to add user. User config not initialized. Error = <%x>", hOK);
    return Error ("Unable to add user. User config not initialized",
      IID_ICOMUserConfig, hOK) ;
  }
  
  return (hOK);	
}

// ---------------------------------------------------------------------------
// Description:   This method gets the value for a name from the t_profile
//                table.
// Arguments:     Tag name - Tag name such as bgColor
// Return Value:  Tag value from the database
// Errors Raised: 0xE1400003 - KIOSK_ERR_INVALID_PARAMETER 
//                0xE1400002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMUserConfig::GetValue(BSTR tagName, BSTR * tagValue)
{
  HRESULT hOK = S_OK;
  
  // check for null values
  if (tagName == NULL || tagValue == NULL)
  {
    hOK = KIOSK_ERR_INVALID_PARAMETER;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to get value. Error = <%x>", hOK);
    return Error ("Unable to get value",
      IID_ICOMUserConfig, hOK) ;
  }
  
  // check for the initialized flag
  if (mIsInitialized == TRUE)
  {
    _variant_t value;
    mUserConfig.GetUserConfigValue(tagName, value);
    _bstr_t bvalue(value);
    *tagValue = bvalue.copy();
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to get value. User config not initialized. Error = <%x>", hOK);
    return Error ("Unable to get value. User config not initialized",
      IID_ICOMUserConfig, hOK) ;
  }
  
  return (hOK);
}

// ---------------------------------------------------------------------------
// Description:   This method sets the value for a name in the t_profile
//                table.
// Arguments:     Tag name - Tag name such as bgColor
//                Tag value - Tag value such as White
// Errors Raised: 0xE1400011 - KIOSK_ERR_SETTING_USER_CONFIG_FAILED 
//                0xE1400002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMUserConfig::SetValue(BSTR tagName, BSTR tagValue)
{
  HRESULT hOK = S_OK;
  
  // check for null values
  if (tagName == NULL || tagValue == NULL)
  {
    hOK = KIOSK_ERR_INVALID_PARAMETER;
    return (hOK);
  }
  
  // invoke the method on the core object
  // check for the initialized flag
  if (mIsInitialized == TRUE)
  {
    if (!mUserConfig.SetUserConfigValue(tagName, tagValue))
    {
      hOK = KIOSK_ERR_SETTING_USER_CONFIG_FAILED; 
      mLogger->LogVarArgs (LOG_ERROR,
        "Unable to set user config value <%s> for name <%s>. Error = <%x>", 
        (const char*)tagValue, (const char*)tagName, hOK);
      return Error ("Unable to set value.",
        IID_ICOMUserConfig, hOK) ;
    }
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to set value. User config not initialized. Error = <%x>", hOK);
    return Error ("Unable to set value. User config not initialized",
      IID_ICOMUserConfig, hOK) ;
  }
  
  return (hOK);
}

// ---------------------------------------------------------------------------
// Description:   This gets back the language code property
// Errors Raised: 0xE1400002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMUserConfig::get_LanguageCode(BSTR * pVal)
{
  HRESULT hOK = S_OK;
  
  // check for mIsInitialized flag or the existence of the pointer
  if (mIsInitialized == TRUE)
  {
    *pVal = SysAllocString(mUserConfig.GetLangCode().c_str());
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to get language code. User config not initialized. Error = <%x>", hOK);
    return Error ("Unable to get language code. User config not initialized",
      IID_ICOMUserConfig, hOK) ;
  }
  
  return (hOK);  
}

// ---------------------------------------------------------------------------
// Description:   This gets back the account ID property
// Errors Raised: 0xE1400002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMUserConfig::get_AccountID(long * pVal)
{
  HRESULT hOK = S_OK;
  
  // check for the initialized flag
  if (mIsInitialized == TRUE)
  {
    *pVal = mUserConfig.GetAccountID();
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to get account id. User config not initialized. Error = <%x>", hOK);
    return Error ("Unable to get account id. User config not initialized",
      IID_ICOMUserConfig, hOK) ;
  }
  
  return (hOK);  
}

// ---------------------------------------------------------------------------
// Description:   This method gets the data from the user tables for an
//                account.
// Return Value:  LPDISPATCH - An InMemRowset object consisting of the user
//                information 
// Errors Raised: 0xE1400011 - KIOSK_ERR_GET_ACCOUNT_INFO_FAILED 
//                0xE1400002 - KIOSK_ERR_NOT_INITIALIZED 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMUserConfig::GetUserAccountInfo(LPDISPATCH * pInterface)
{
  // local variables ...
  HRESULT hOK = S_OK;
  ROWSETLib::IMTInMemRowsetPtr pRowSet;
  pRowSet = 0;
  
  if (mIsInitialized == TRUE)
  {
    pRowSet = mUserConfig.GetUserAccountInfo();
    
    if (pRowSet == 0)
    {
      hOK = KIOSK_ERR_GET_ACCOUNT_INFO_FAILED;
      mLogger->LogVarArgs (LOG_ERROR,
        "Unable to get account info. Error = <%x>", hOK);
      return Error ("Unable to get user account info.",
        IID_ICOMUserConfig, hOK) ;
    }
    else
    {
      *pInterface = pRowSet.Detach();
    }
  }
  else
  {
    hOK = KIOSK_ERR_NOT_INITIALIZED;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to get user account info. User config not initialized. Error = <%x>", hOK);
    return Error ("Unable to get user account info. User config not initialized",
      IID_ICOMUserConfig, hOK) ;
  }
  
  return (hOK);
}
