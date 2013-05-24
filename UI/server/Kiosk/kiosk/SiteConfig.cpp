/**************************************************************************
 * @doc
 *
 * Copyright 1998 by MetraTech
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
 *	SiteConfig.cpp :
 *	------------------
 *	This is the implementation of the SiteConfig class.
 ***************************************************************************/


// All the includes
// ADO includes
#include <StdAfx.h>
#include <metra.h>
#include <comdef.h>
#include <adoutil.h>

// Local includes
#include <SiteConfig.h>
#include <loggerconfig.h>
#include <ConfigDir.h>

// import the config loader tlb
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

// @mfunc CSiteConfig default constructor
// @parm
// @rdesc This implementations is for the default constructor of the
// Core Kiosk Gate class
DLL_EXPORT
CSiteConfig::CSiteConfig()
{
}

DLL_EXPORT
CSiteConfig::~CSiteConfig()
{
  TearDown() ;
}

void CSiteConfig::TearDown()
{
  mLock.Lock() ;
  mSiteProfileMap.clear() ;
  mLock.Unlock() ;
}

// @mfunc Initialize
// @parm Language code
// @parm Login ID
// @rdesc This function is responsible for initializing the object
// by getting values from the database. 	It creates the language
// request and does the connect to the database and executes the query.
// Returns true or false depending on whether the function succeeded
// or not.
DLL_EXPORT BOOL
CSiteConfig::GetConfigInfo(const wstring &arProviderName, 
                           const wstring &arLangCode)
{
  string strConfigDir ;
  _bstr_t profileName, profileValue ;
  wstring wstrTagName, wstrTagValue ;
  BOOL bRetCode=TRUE ;

  // free the allocated memory ...
  TearDown() ;

  // start the try ...
  try
  {
    // initialize the _com_ptr_t ...
    CONFIGLOADERLib::IMTConfigLoaderPtr configLoader(MTPROGID_CONFIGLOADER);
    

    // copy the provider name and langcode ...
    mLock.Lock() ;
    mProviderName = arProviderName ;
    mLangCode = arLangCode ;
    mLock.Unlock() ;

    // initialize the configLoader ...
		string aExtensionDir;
		GetExtensionsDir(aExtensionDir);
		_bstr_t aSiteConfigDir = aExtensionDir.c_str();
		aSiteConfigDir += DIR_SEP;
		aSiteConfigDir += (const wchar_t*)mProviderName.c_str();
		aSiteConfigDir += NEW_MPSSITECONFIG_DIR;
		aSiteConfigDir += (const wchar_t*)mLangCode.c_str();

    configLoader->InitWithPath(aSiteConfigDir) ;

    
		// open the config file ...
    CONFIGLOADERLib::IMTConfigPropSetPtr configSet = 
      configLoader->GetEffectiveFile("", LOCALIZED_SITE_CONFIG);

	// check for the null existence of the object
	if (configSet == NULL)
	{
	  mLogger->LogVarArgs (LOG_ERROR, 
						  "Unable to create configuration set for provider <%s>", 
						  _bstr_t(arProviderName.c_str()));
	  mLogger->LogVarArgs (LOG_ERROR, 
						  "GetEffectiveFile on localized_site.xml file for language <%s>failed", 
						  _bstr_t(arLangCode.c_str()));
	  mLogger->LogThis (LOG_ERROR, 
					   "Could be because the effective date is ahead of the current GMT time");
	  return (FALSE);
	}

    // while we have more config info to read ...

    CONFIGLOADERLib::IMTConfigPropSetPtr groupSet ;
    CONFIGLOADERLib::IMTConfigPropSetPtr profileSet ;
	while ((groupSet = configSet->NextSetWithName("group")) != NULL)
	{
		while ((profileSet = groupSet->NextSetWithName("profileset")) != NULL)
		{
		  profileName = profileSet->NextStringWithName("profile_name");
		  profileValue = profileSet->NextStringWithName("profile_value");

		  wstrTagName = profileName ;
		  wstrTagValue = profileValue ;

		  // Fill up the map
		  mLock.Lock() ;
		  mSiteProfileMap[wstrTagName] = wstrTagValue;
		  mLock.Unlock() ;
		}
	}
  }
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "CSiteConfig::Initialize");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
  }

  // if we havent initialized the observer yet ...
  if (mObserverInitialized == FALSE)
  {
    if (!mObservable.Init())
    {
      mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Unable to initialize Observer.") ;
      bRetCode = FALSE ;
    }
    else
    {    
      mObservable.AddObserver(*this);
      
      if (!mObservable.StartThread())
      {
        mLogger->LogVarArgs (LOG_ERROR, "Init() failed. Unable to start Observer Thread.") ;
        bRetCode = FALSE ;
      }
      else
      {
        mObserverInitialized = TRUE ;
      }
    }
  }

  return (bRetCode);
}


// @mfunc GetSiteConfigValue
// @parm tag name
// @rdesc returns the corresponding value from the map
DLL_EXPORT BOOL
CSiteConfig::GetSiteConfigValue (const wstring &arTagName,
								 wstring &arValue)
{
  BOOL bRetCode=TRUE ;
  // get the value for the specified tag ...
  mLock.Lock() ;
	Profile::iterator it = mSiteProfileMap.find(arTagName);
	if (it == mSiteProfileMap.end())
		bRetCode = FALSE;
	else
		arValue = it->second;
  mLock.Unlock() ;
	if (bRetCode == FALSE)
	{
		mLogger->LogVarArgs(LOG_ERROR,
							 L"Tag name <%s> not found in the map", arTagName.c_str());
		return FALSE;
	}

  return TRUE;
}

//	@mfunc SetSiteConfigValue
//	@parm Tag Name
//	@parm Tag Value
//	@rdesc Find the associated string tag value in the Profile Map
//	This function sets the value for a profile name.
//	For eg:  "black" for "bgcolor"
//	Set the map with the appropriate values.
//	If the key does not exist, enter a new key and value pair
//	else update the existing value for the key by first deleting
//	it and then inserting a new value.
DLL_EXPORT BOOL
CSiteConfig::SetSiteConfigValue (const wstring &arTagName,
									const wstring &arTagValue)
{
	// check for the key in the profile map -- wstrTagNameType is the key
	// if it does not exist, then insert a new key value pair
	// else update the value by first deleting the record and then inserting
	// a new one
  mLock.Lock() ;
	if (mSiteProfileMap.count(arTagName) == 0)
	{
		mSiteProfileMap[arTagName] = arTagValue;
	}
	else
	{
		mSiteProfileMap.erase(arTagName);
		mSiteProfileMap[arTagName] = arTagValue;
	}
  mLock.Unlock() ;

	return (TRUE);
}

//
//	@mfunc
//	Update the configuration.
//  @rdesc 
//  No return value
//
void CSiteConfig::ConfigurationHasChanged()
{
   // get the critical section
  mLock.Lock() ;

  // initialize the collection ...
  GetConfigInfo(mProviderName, mLangCode);

  // release the critical section
  mLock.Unlock() ;  

  return ;
}
