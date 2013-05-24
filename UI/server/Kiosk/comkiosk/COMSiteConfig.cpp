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
// COMSiteConfig.cpp : Implementation of CCOMSiteConfig
// ---------------------------------------------------------------------------
#include "StdAfx.h"
#include "COMKiosk.h"
#include "COMSiteConfig.h"
#include <mtglobal_msg.h>

#include <loggerconfig.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMSiteConfig

// ---------------------------------------------------------------------------
// Description:   This is the default constructor for this object
// ---------------------------------------------------------------------------
CCOMSiteConfig::CCOMSiteConfig()
{
}

// ---------------------------------------------------------------------------
// Description:   This is the default destructor for this object
// ---------------------------------------------------------------------------
CCOMSiteConfig::~CCOMSiteConfig()
{
}

STDMETHODIMP CCOMSiteConfig::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMSiteConfig,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ---------------------------------------------------------------------------
// Description:   This builds the local map or name value profile pair
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMSiteConfig::GetConfigInfo(BSTR nameSpace, BSTR langCode)
{
	// local variables ...
	HRESULT hOK = S_OK;

	// initialize the SiteConfig server ...
	if (!mSiteConfig.GetConfigInfo (nameSpace, langCode))
	{
		mIsInitialized = FALSE;
		hOK = SITE_CONFIG_INITIALIZATION_FAILED;
		mLogger->LogVarArgs (LOG_ERROR,
      "Unable to get site configuration information. Error = <%x>", hOK);
    return Error ("Unable to get site configuration information.",
      IID_ICOMSiteConfig, hOK) ;
	}

	return (hOK);
}

// ---------------------------------------------------------------------------
// Description:   This method gets the profile value back for a specific
//                profile tag
// Arguments:     Tag Name - Tag name such as bgColor (for background color)
// Return Value:  Profile Value (such as White)
// Errors Raised: 0xE140003 - KIOSK_ERR_INVALID_PARAMETER 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMSiteConfig::GetValue(BSTR tagName, BSTR * tagValue)
{
  HRESULT hOK = S_OK;
  
  // check for null values
  if (tagName == NULL)
  {
    hOK = KIOSK_ERR_INVALID_PARAMETER;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to get site config value. Error = <%x>", hOK);
    return (hOK);
  }
  
  wstring value;
  
  // get the site config value ...
  if (!mSiteConfig.GetSiteConfigValue(tagName, value))
  {
    hOK = KIOSK_ERR_ITEM_NOT_FOUND ;
    mLogger->LogVarArgs (LOG_ERROR, "Unable to get site config. Error = <%x>", hOK) ;
    return Error ("Unable to get site configuration value.",
      IID_ICOMSiteConfig, hOK) ;
  }
  else
  {
    *tagValue = SysAllocString(value.c_str());
  }
  return (hOK);
}

// ---------------------------------------------------------------------------
// Description:   This method sets the profile value back for a specific
//                profile tag
// Arguments:     Tag Name - Tag name such as bgColor (for background color)
//                Tag Value - Tag value such as White 
// Errors Raised: 0xE140003 - KIOSK_ERR_INVALID_PARAMETER 
// ---------------------------------------------------------------------------
STDMETHODIMP CCOMSiteConfig::SetValue(BSTR tagName, BSTR tagValue)
{
	HRESULT hOK = S_OK;
  
  // check for null values
  if (tagName == NULL || tagValue == NULL)
  {
    hOK = KIOSK_ERR_INVALID_PARAMETER;
    mLogger->LogVarArgs (LOG_ERROR,
      "Unable to set site config value. Error = <%x>", hOK);
    return Error ("Unable to set site configuration value.",
      IID_ICOMSiteConfig, hOK) ;
  }
  // set the site config value ...
  if (!mSiteConfig.SetSiteConfigValue(tagName, tagValue))
  {
    hOK = KIOSK_ERR_SETTING_SITE_CONFIG_FAILED;
    mLogger->LogVarArgs (LOG_ERROR,
      L"Unable to set site config value <%s> for name <%s>. Error = <%x>",
      tagValue, tagName, hOK);
    return Error ("Unable to set site configuration value.",
      IID_ICOMSiteConfig, hOK) ;
  }

	return (hOK);
}

