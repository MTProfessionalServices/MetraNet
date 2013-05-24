// MTUserProfile.cpp : Implementation of CMTUserProfile
#include "StdAfx.h"
#include <comdef.h>
#include "MTSiteConfig.h"
#include "MTUserProfile.h"
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <mtprogids.h>

using std::wstring;

/////////////////////////////////////////////////////////////////////////////
// CMTUserProfile
CMTUserProfile::CMTUserProfile()
: mInitialized(FALSE)
{
  // initialize the logger
	LoggerConfigReader configReader;
	mLogger.Init (configReader.ReadConfiguration("Core"), CORE_TAG);
}

CMTUserProfile::~CMTUserProfile()
{
  TearDown() ;
}

void CMTUserProfile::TearDown() 
{
}

STDMETHODIMP CMTUserProfile::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTUserProfile,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTUserProfile::Initialize(BSTR aHostName, BSTR aRelativePath, 
                                         BSTR aRelativeFile)
{
  VARIANT_BOOL secure=VARIANT_FALSE ;
  wstring wstrTagName, wstrTagValue ;
  _bstr_t profileName, profileValue ;
  _bstr_t relativePath ;
  HRESULT nRetVal ;

  // tear down the memory ...
  TearDown() ;

  // copy the parameters ...
  mHostName = aHostName ;
  mRelativePath = aRelativePath ;
  mRelativeFile = aRelativeFile ;

  try
	{
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

		VARIANT_BOOL checksumMatch;

    // create the config dir ...
    relativePath = mRelativePath.c_str() ;
    relativePath += "\\" ;
    relativePath += mRelativeFile.c_str() ;

    // read the configuration file ...
		MTConfigLib::IMTConfigPropSetPtr propSet = 
      config->ReadConfigurationFromHost(mHostName.c_str(), relativePath, secure, &checksumMatch);

    // read the user profile information out of the prop set ...
    if (propSet == NULL)
    {
      nRetVal = CORE_ERR_NO_PROP_SET ; 
      SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
        "MTUserProfile::Initialize", "No propset read");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Configuration file <%s> not read from host <%s>.", 
        relativePath, aHostName) ;
      return Error ("No propset read from host.", IID_IMTUserProfile, nRetVal) ;
    }
    // get the data section ...
    MTConfigLib::IMTConfigPropSetPtr mainSet = propSet->NextSetWithName("mtconfigdata");
    if (mainSet == NULL)
    {
      nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTUserProfile::Initialize",
        "Invalid data section for configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Invalid data section for configuration file <%s>.", relativePath) ;
      return Error ("Invalid data section for configuration file.", IID_IMTUserProfile, nRetVal) ;
    }
    
    // while we have more config info to read ...
    MTConfigLib::IMTConfigPropSetPtr profileSet ;
    while ((profileSet = mainSet->NextSetWithName("profileset")) != NULL)
    {
      profileName = profileSet->NextStringWithName("profile_name");
      profileValue = profileSet->NextStringWithName("profile_value");

      wstrTagName = profileName ;
      wstrTagValue = profileValue ;

      // Fill up the map
      mUserProfileMap[wstrTagName] = wstrTagValue;
    }

    // set the initialized flag ...
    mInitialized = TRUE ;
	}
	catch (_com_error err)
  {
    SetError(err.Error(), ERROR_MODULE, ERROR_LINE, "MTUserProfile::Initialize",
      "Caught error while reading user profile information.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"Caught error during the reading of configuration file <%s> on host <%s>.", 
      relativePath, mHostName.c_str()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
        "CreateSiteInfo() failed. Error Description = %s", (char*)err.Description()) ;
    return Error ("Unable to read configuration file.", IID_IMTUserProfile, err.Error()) ;
  }

	return S_OK;
}

STDMETHODIMP CMTUserProfile::GetValue(BSTR apTagName, BSTR * apTagValue)
{
	if (!mInitialized)
  {
    HRESULT nRetVal=CORE_ERR_NOT_INITIALIZED ; 
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTUserProfile::GetValue", "Unable to get user profile value.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("Unable to get user profile value", IID_IMTUserProfile, nRetVal) ;
  }
  // find the value in the map ...
	UserProfileCollIter it = mUserProfileMap.find(apTagName);
  if (it == mUserProfileMap.end())
  {
    // if the value we're looking for is "" then return ""
    wstring wstrTemp = apTagName ;
    if (wstrTemp.length() == 0)
    {
      *apTagValue = ::SysAllocString (L"") ;
    }
    // otherwise return an error ...
    else
    {
      
      HRESULT nRetVal = CORE_ERR_ITEM_NOT_FOUND ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
        "CMTUserProfile::GetValue", "Item not found in user profile information.") ;
      mLogger.LogVarArgs(LOG_ERROR,
        L"Tag name <%s> not found in the user profile information", apTagName);
      return Error ("Item not found in user profile information", IID_IMTUserProfile, nRetVal) ;
    }
  }
  else
  {
		wstring tagValue = (*it).second;
    *apTagValue = ::SysAllocString (tagValue.c_str()) ;
  }
	return S_OK;
}

STDMETHODIMP CMTUserProfile::SetValue(BSTR aTagName, BSTR aTagValue)
{
	if (!mInitialized)
  {
    HRESULT nRetVal=CORE_ERR_NOT_INITIALIZED ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTUserProfile::SetValue", "Unable to set user profile value.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("Unable to set user profile value", IID_IMTUserProfile, nRetVal) ;
  }

  // check for the key in the profile map -- wstrTagName is the key
  // if it does not exist, then insert a new key value pair
  // else update the value by first deleting the record and then inserting
  // a new one
  if (mUserProfileMap.count(aTagName) > 0)
  {
    mUserProfileMap.erase(aTagName);
    mUserProfileMap[aTagName] = aTagValue;
  }
  else
  {
    // ignore if the value is "" ... if the value we're setting isnt "" then return error ...
    wstring wstrTemp = aTagName ;
    if (wstrTemp.length() != 0)
    {
      HRESULT nRetVal = CORE_ERR_ITEM_NOT_FOUND ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
        "CMTUserProfile::SetValue", "Item not found in user profile information.") ;
      mLogger.LogVarArgs(LOG_ERROR,
        L"Tag name <%s> not found in the user profile information", aTagName);
      return Error ("Item not found in user profile information", IID_IMTUserProfile, nRetVal) ;
    }
  }

	return S_OK;
}

STDMETHODIMP CMTUserProfile::CommitChanges()
{
  _bstr_t profileName, profileValue ;
  _bstr_t relativePath ;
  VARIANT_BOOL secure=VARIANT_FALSE ;

	if (!mInitialized)
  {
    HRESULT nRetVal=CORE_ERR_NOT_INITIALIZED ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTUserProfile::CommitChanges", "Unable to commit user profile changes.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("Unable to commit user profile changes", IID_IMTUserProfile, nRetVal) ;
  }

  try
  {
    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    MTConfigLib::IMTConfigPropSetPtr propSet;
    
    // TODO: should this always be xmlconfig?
    propSet = config->NewConfiguration("xmlconfig");

    // add the mtconfigdata section ...
    if (SetUserProfileData(propSet) == FALSE)
    {
      HRESULT nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTUserProfile::CommitChanges",
        "Invalid data section for configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Invalid data section for configuration file <%s>.", relativePath) ;
      return Error ("Invalid data section for configuration file.", IID_IMTUserProfile, nRetVal) ;
    }

    // create the relative path ...
    relativePath = mRelativePath.c_str() ;
    relativePath += "\\" ;
    relativePath += mRelativeFile.c_str() ;
    
    // write the propset out ...
    propSet->WriteToHost(mHostName.c_str(), relativePath, L"", L"",
      secure, VARIANT_TRUE);
  }
	catch (_com_error err)
  {
    SetError(err.Error(), ERROR_MODULE, ERROR_LINE, "MTUserProfile::CommitChanges",
      "Caught error while writing user profile information.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"Caught error during the writing of configuration file <%s> on host <%s>.", relativePath, 
      mHostName) ;
    mLogger.LogVarArgs (LOG_ERROR, 
        "CreateSiteInfo() failed. Error Description = %s", (char*)err.Description()) ;
  }
	return S_OK;
}

BOOL CMTUserProfile::SetUserProfileData(MTConfigLib::IMTConfigPropSetPtr aPropSet)
{
  if (aPropSet == NULL)
  {
    HRESULT nRetVal = CORE_ERR_NO_PROP_SET ; 
    SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
      "MTSiteBranding::SetSiteConfigData", "No propset to write header to");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    return FALSE; 
  }
  
  IMTConfigPropSetPtr mtconfigdata = aPropSet->InsertSet("mtconfigdata");
  
  if (mtconfigdata == NULL)
  {
    HRESULT nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
    SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteBranding::SetSiteConfigData",
      "Unable to insert data section to configuration file.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  // iterate through the map and insert all the data ...
  for (UserProfileCollIter Iter = mUserProfileMap.begin(); Iter != mUserProfileMap.end(); Iter++)
  {
    // insert a new profile_set ...
    IMTConfigPropSetPtr configdata = mtconfigdata->InsertSet("profileset");

    // insert the profile_name and profile_value ...
    _variant_t var = (*Iter).first.c_str() ;
    configdata->InsertProp("profile_name" , MTConfigLib::PROP_TYPE_STRING, var);
    var = (*Iter).second.c_str() ;
    configdata->InsertProp("profile_value" , MTConfigLib::PROP_TYPE_STRING, var);
  }

  return TRUE ;
}

