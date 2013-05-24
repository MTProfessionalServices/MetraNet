// MTSiteBranding.cpp : Implementation of CMTSiteBranding
#include "StdAfx.h"
#include <comdef.h>
#include "MTSiteConfig.h"
#include "MTSiteBranding.h"
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <mtprogids.h>
#include <mttime.h>

/////////////////////////////////////////////////////////////////////////////
// CMTSiteBranding
CMTSiteBranding::CMTSiteBranding()
: mInitialized(FALSE)
{
  // initialize the logger
	LoggerConfigReader configReader;
	mLogger.Init (configReader.ReadConfiguration("Core"), CORE_TAG);
}

CMTSiteBranding::~CMTSiteBranding()
{
  TearDown() ;
}

void CMTSiteBranding::TearDown() 
{
}

STDMETHODIMP CMTSiteBranding::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSiteBranding,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTSiteBranding::Initialize(BSTR aHostName, BSTR aRelativePath, 
                                         BSTR aRelativeFile, 
                                         BSTR aProviderName, BSTR aLanguage)
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
  mProviderName = aProviderName ;
  mLangCode = aLanguage ;
  mRelativePath = aRelativePath ;
  mRelativeFile = aRelativeFile ;

  try
	{
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

		VARIANT_BOOL checksumMatch;

    // create the config dir ...
    relativePath = mRelativePath.c_str() ;
    relativePath += mProviderName.c_str() ;
    relativePath += "\\" ;
    relativePath += mLangCode.c_str() ;
    relativePath += "\\" ;
    relativePath += mRelativeFile.c_str() ;

    // read the configuration file ...
		MTConfigLib::IMTConfigPropSetPtr propSet = 
      config->ReadConfigurationFromHost(mHostName.c_str(), relativePath, secure, &checksumMatch);

    // read the site configuration information out of the prop set ...
    if (propSet == NULL)
    {
      nRetVal = CORE_ERR_NO_PROP_SET ; 
      SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
        "MTSiteBranding::Initialize", "No propset read");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Configuration file <%s> not read from host <%s>.", 
        relativePath, aHostName) ;
      return Error ("No propset read from host.", IID_IMTSiteBranding, nRetVal) ;
    }
    // get the data section ...
    MTConfigLib::IMTConfigPropSetPtr mainSet = propSet->NextSetWithName("mtconfigdata");
    if (mainSet == NULL)
    {
      nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteBranding::Initialize",
        "Invalid data section for configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Invalid data section for configuration file <%s>.", relativePath) ;
      return Error ("Invalid data section for configuration file.", IID_IMTSiteBranding, nRetVal) ;
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
      mSiteConfigMap[wstrTagName] = wstrTagValue;
    }

    // set the initialized flag ...
    mInitialized = TRUE ;
	}
	catch (_com_error err)
  {
    SetError(err.Error(), ERROR_MODULE, ERROR_LINE, "MTSiteBranding::Initialize",
      "Caught error while reading site configuration information.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"Caught error during the reading of configuration file <%s> on host <%s>.", 
      relativePath, mHostName.c_str()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
        "Initialize() failed. Error Description = %s", (char*)err.Description()) ;
    return Error ("Unable to read configuration file.", IID_IMTSiteBranding, err.Error()) ;
  }

	return S_OK;
}

STDMETHODIMP CMTSiteBranding::GetValue(BSTR apTagName, BSTR * apTagValue)
{
	if (!mInitialized)
  {
    HRESULT nRetVal=CORE_ERR_NOT_INITIALIZED ; 
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTSiteBranding::GetValue", "Unable to get site configuration value.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("Unable to get site configuration value", IID_IMTSiteBranding, nRetVal) ;
  }
  // find the value in the map ...
	SiteConfigColl::iterator it = mSiteConfigMap.find(apTagName);
	if (it == mSiteConfigMap.end())
	{
    // if the value we're looking for is "" then return ""
    std::wstring wstrTemp = apTagName ;
    if (wstrTemp.empty())
    {
      *apTagValue = ::SysAllocString (L"") ;
    }
    // otherwise return an error ...
    else
    {
      
      HRESULT nRetVal = CORE_ERR_ITEM_NOT_FOUND ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
        "CMTSiteBranding::GetValue", "Item not found in site configuration information.") ;
      mLogger.LogVarArgs(LOG_ERROR,
        L"Tag name <%s> not found in the site configuration information", apTagName);
      return Error ("Item not found in site configuration information", IID_IMTSiteBranding, nRetVal) ;
    }
  }
  else
  {
    *apTagValue = ::SysAllocString ((it->second).c_str()) ;
  }
	return S_OK;
}

STDMETHODIMP CMTSiteBranding::SetValue(BSTR aTagName, BSTR aTagValue)
{
	if (!mInitialized)
  {
    HRESULT nRetVal=CORE_ERR_NOT_INITIALIZED ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTSiteBranding::SetValue", "Unable to set site configuration value.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("Unable to set site configuration value", IID_IMTSiteBranding, nRetVal) ;
  }

  // check for the key in the profile map -- wstrTagName is the key
  // if it does not exist, then insert a new key value pair
  // else update the value by first deleting the record and then inserting
  // a new one
  if (mSiteConfigMap.count(aTagName) > 0)
  {
    mSiteConfigMap.erase(aTagName);
    mSiteConfigMap[aTagName] = aTagValue == NULL ? L"" : _bstr_t(aTagValue);
  }
  else
  {
    // ignore if the value is "" ... if the value we're setting isnt "" then return error ...
    std::wstring wstrTemp = aTagName ;
    if (!wstrTemp.empty())
    {
      HRESULT nRetVal = CORE_ERR_ITEM_NOT_FOUND ;
      SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
        "CMTSiteBranding::SetValue", "Item not found in site configuration information.") ;
      mLogger.LogVarArgs(LOG_ERROR,
        L"Tag name <%s> not found in the site configuration information", aTagName);
      return Error ("Item not found in site configuration information", IID_IMTSiteBranding, nRetVal) ;
    }
  }

	return S_OK;
}

STDMETHODIMP CMTSiteBranding::CommitChanges()
{
  _bstr_t profileName, profileValue ;
  _bstr_t relativePath ;
  VARIANT_BOOL secure=VARIANT_FALSE ;

	if (!mInitialized)
  {
    HRESULT nRetVal=CORE_ERR_NOT_INITIALIZED ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTSiteBranding::CommitChanges", "Unable to commit site configuration changes.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("Unable to commit site configuration changes", IID_IMTSiteBranding, nRetVal) ;
  }

  try
  {
    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    MTConfigLib::IMTConfigPropSetPtr propSet;
    
    // TODO: should this always be xmlconfig?
    propSet = config->NewConfiguration("xmlconfig");

    // add the mtconfigdata section ...
    if (SetSiteConfigData(propSet) == FALSE)
    {
      HRESULT nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteBranding::CommitChanges",
        "Invalid data section for configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Invalid data section for configuration file <%s>.", relativePath) ;
      return Error ("Invalid data section for configuration file.", IID_IMTSiteBranding, nRetVal) ;
    }

    // create the relative path ...
    relativePath = mRelativePath.c_str() ;
    relativePath += mProviderName.c_str() ;
    relativePath += "\\" ;
    relativePath += mLangCode.c_str() ;
    relativePath += "\\" ;
    relativePath += mRelativeFile.c_str() ;
    
    // write the propset out ...
    propSet->WriteToHost(mHostName.c_str(), relativePath, L"", L"",
      secure, VARIANT_TRUE);
  }
	catch (_com_error err)
  {
    SetError(err.Error(), ERROR_MODULE, ERROR_LINE, "MTSiteBranding::CommitChanges",
      "Caught error while writing site configuration information.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"Caught error during the writing of configuration file <%s> on host <%s>.", relativePath, 
      mHostName) ;
    mLogger.LogVarArgs (LOG_ERROR, 
        "CommitChanges() failed. Error Description = %s", (char*)err.Description()) ;
  }
	return S_OK;
}

BOOL CMTSiteBranding::SetMTSysHeader(MTConfigLib::IMTConfigPropSetPtr aPropSet)
{
	if (aPropSet == NULL)
	{
    HRESULT nRetVal = CORE_ERR_NO_PROP_SET ; 
    SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
      "MTSiteBranding::SetMTSysHeader", "No propset to write header to");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    return FALSE; 
	}

	// insert header information: effective date, timeout value etc.
	IMTConfigPropSetPtr header = aPropSet->InsertSet("mtsysconfigdata");
	if (header == NULL)
	{
    HRESULT nRetVal = CORE_ERR_INVALID_HEADER ;
    SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteBranding::SetMTSysHeader",
      "Unable to insert header to configuration file.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    return FALSE ;
	}

  // insert the effective date, timeout and configfiletype ...
	time_t ltime = GetMTTime() - (60 * 60 * 24);
	header->InsertProp("effective_date", MTConfigLib::PROP_TYPE_DATETIME, ltime);

	_variant_t var = (long) 30;

	header->InsertProp("timeout" , MTConfigLib::PROP_TYPE_INTEGER, var);

	header->InsertProp("configfiletype", MTConfigLib::PROP_TYPE_STRING, "CONFIG_DATA");

	return TRUE;
}

BOOL CMTSiteBranding::SetSiteConfigData(MTConfigLib::IMTConfigPropSetPtr aPropSet)
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
	SiteConfigColl::iterator it;
	for (it = mSiteConfigMap.begin(); it != mSiteConfigMap.end(); ++it)
  {
    // insert a new profile_set ...
    IMTConfigPropSetPtr configdata = mtconfigdata->InsertSet("profileset");

    // insert the profile_name and profile_value ...
    _variant_t var = it->first.c_str() ;
    configdata->InsertProp("profile_name" , MTConfigLib::PROP_TYPE_STRING, var);
    var = it->second.c_str() ;
    configdata->InsertProp("profile_value" , MTConfigLib::PROP_TYPE_STRING, var);
  }

  return TRUE ;
}

