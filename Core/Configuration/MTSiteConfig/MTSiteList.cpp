// MTSiteList.cpp : Implementation of CMTSiteList
#include "StdAfx.h"
#include <comdef.h>
#include "MTSiteConfig.h"
#include "MTSiteList.h"
#include "MTSite.h"
#include <loggerconfig.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <mttime.h>

using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTSiteList

CMTSiteList::CMTSiteList()
: mInitialized(FALSE), mSize(0), mCreateNewSite(FALSE)
{
  // initialize the logger
	LoggerConfigReader configReader;
	mLogger.Init (configReader.ReadConfiguration("Core"), CORE_TAG);
}

CMTSiteList::~CMTSiteList()
{
}

STDMETHODIMP CMTSiteList::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSiteList,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTSiteList::Initialize(BSTR aHostName, BSTR aRelativePath, BSTR aRelativeFile)
{
	  VARIANT_BOOL secure=VARIANT_FALSE ;
  std::wstring wstrTagName, wstrTagValue ;
  _bstr_t name, providerName, webURL;
  _bstr_t relativePath ;
  HRESULT nRetVal ;

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
    relativePath += mRelativeFile.c_str() ;

    // read the configuration file ...
		MTConfigLib::IMTConfigPropSetPtr propSet = 
      config->ReadConfigurationFromHost(mHostName.c_str(), relativePath, secure, &checksumMatch);

    // read the site configuration information out of the prop set ...
    if (propSet == NULL)
    {
      nRetVal = CORE_ERR_NO_PROP_SET ; 
      SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
        "MTSiteList::Initialize", "No propset read");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Configuration file <%s> not read from host <%s>.", 
        relativePath, aHostName) ;
      return Error ("No propset read from host.", IID_IMTSiteList, nRetVal) ;
    }
    // get the data section ...
    MTConfigLib::IMTConfigPropSetPtr mainSet = propSet->NextSetWithName("mtconfigdata");
    if (mainSet == NULL)
    {
      nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::Initialize",
        "Invalid data section for configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Invalid data section for configuration file <%s>.", relativePath) ;
      return Error ("Invalid data section for configuration file.", IID_IMTSiteList, nRetVal) ;
    }
    
    // while we have more config info to read ...
    MTConfigLib::IMTConfigPropSetPtr siteSet ;
    while ((siteSet = mainSet->NextSetWithName("site")) != NULL)
    {
      // get the values from the XMl file ...
      name = siteSet->NextStringWithName("name");
      webURL = siteSet->NextStringWithName("WebURL");
      providerName = siteSet->NextStringWithName("provider_name");

      // create the MTSite object to add into the list ...
      Add (name, providerName, webURL, VARIANT_FALSE) ;
      
      // set the initialized flag ...
      mInitialized = TRUE ;
    }
	}
	catch (_com_error err)
  {
    mInitialized = FALSE ;
    SetError(err.Error(), ERROR_MODULE, ERROR_LINE, "MTSiteList::Initialize",
      "Caught error while reading site configuration information.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"Caught error during the reading of configuration file <%s> on host <%s>.", 
      (wchar_t*)relativePath, mHostName.c_str()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
        "Initialize() failed. Error Description = %s", (char*)err.Description()) ;
    return Error ("Unable to read configuration file", IID_IMTSiteList, err.Error()) ;
  }

	return S_OK;

}

STDMETHODIMP CMTSiteList::get__NewEnum(LPUNKNOWN * pVal)
{
  HRESULT hr = S_OK;
  
  if (!mInitialized)
  {
    HRESULT nRetVal=CORE_ERR_NOT_INITIALIZED ; 
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTSiteList::get__NewEnum", "Unable to get enumerator.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("Unable to get enumerator", IID_IMTSiteList, nRetVal) ;
  }

  typedef CComObject<CComEnum<IEnumVARIANT, 
    &IID_IEnumVARIANT, VARIANT, _Copy<VARIANT> > > enumvar;
  
  enumvar* pEnumVar = new enumvar;
  ASSERT (pEnumVar);
  
  // Note: end pointer has to be one past the end of the list
  hr = pEnumVar->Init(&mSiteList[0], 
    &mSiteList[mSize - 1] + 1, 
    NULL, 
    AtlFlagCopy);
  
  if (SUCCEEDED(hr))
  {
    hr = pEnumVar->QueryInterface(IID_IEnumVARIANT, (void**)pVal);
  }
  
  if (FAILED(hr))
  {
    delete pEnumVar;
  }
  
  return hr;
}

STDMETHODIMP CMTSiteList::Add(BSTR aName, BSTR aProviderName, BSTR aRelativeURL,
                              VARIANT_BOOL aNewSiteFlag)
{
  HRESULT nRetVal = S_OK;
	CComObject<CMTSite>* pNewSite;
  BSTR name=NULL, relativeURL=NULL, providerName=NULL;
  BOOL bSiteMatch=FALSE ;
  IMTSite *pSite=NULL ;
  LPDISPATCH pDisp=NULL ;
  
  // iterate through the list and see if we have a site with the same name, 
  // provider name or relative URL ...
  for (unsigned int i = 0; i < mSiteList.size() && bSiteMatch == FALSE; i++) 
  {
    pDisp = NULL;
    pDisp = mSiteList[i].pdispVal;
    nRetVal = pDisp->QueryInterface(IID_IMTSite, (void**)&pSite);
    if (FAILED(nRetVal))
    {
      return nRetVal;
    }
    ASSERT (pSite);
    
    pSite->get_Name(&name);
    pSite->get_ProviderName(&providerName);
    pSite->get_RelativeURL(&relativeURL);
    
    // release the site ...
    pSite->Release() ;    
    
    // if any of the things match ... exit ...
    if (((_bstr_t)name == (_bstr_t)aName) || 
      ((_bstr_t)providerName == (_bstr_t)aProviderName) || 
      ((_bstr_t)relativeURL == (_bstr_t)aRelativeURL))
    {
      bSiteMatch = TRUE ;
    }
    // release the BSTR's ...
    if (name != NULL)
    {
      ::SysFreeString (name) ;
      name = NULL ;
    }
    if (providerName != NULL)
    {
      ::SysFreeString (providerName) ;
      providerName = NULL ;
    }
    if (relativeURL != NULL)
    {
      ::SysFreeString (relativeURL) ;
      relativeURL = NULL ;
    }
  }
  // if we dont have a site match ...
  if (bSiteMatch == FALSE)
  {
    nRetVal = CComObject<CMTSite>::CreateInstance(&pNewSite);
    ASSERT(SUCCEEDED(nRetVal));
    
    pNewSite->Initialize(aName, aProviderName, aRelativeURL, aNewSiteFlag);
    
    nRetVal = pNewSite->QueryInterface(IID_IDispatch, (void**)&pDisp);
    if (FAILED(nRetVal))
    {
      return nRetVal;
    }
    
    // create a variant
    CComVariant var;
    var.vt = VT_DISPATCH;
    var.pdispVal = pDisp;
    
    // append data
    mSiteList.push_back(var);
    mSize++;
  }
  else
  {
    nRetVal = CORE_ERR_DUPLICATE_VALUE ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTSiteList::Add", "Unable to add duplicate site.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"Site configuration values. Name = <%s>. ProviderName = <%s>. RelativeURL = <%s>.",
      aName, aProviderName, aRelativeURL) ;
    return Error ("Unable to add duplicate site.", IID_IMTSiteList, nRetVal) ;
  }

	return nRetVal;
}

STDMETHODIMP CMTSiteList::get_Count(long * pVal)
{
	if (!pVal)
  {
		return E_POINTER;
  }

	*pVal = mSize;

	return S_OK;
}

STDMETHODIMP CMTSiteList::get_Item(long aIndex, VARIANT * pVal)
{
	if (pVal == NULL)
  {
		return E_POINTER;
  }

	VariantInit(pVal);
	pVal->vt = VT_UNKNOWN;
	pVal->punkVal = NULL;

	if ((aIndex < 1) || (aIndex > mSize))
  {
		return E_INVALIDARG;
  }

	VariantCopy(pVal, &mSiteList[aIndex-1]);

	return S_OK;
}


STDMETHODIMP CMTSiteList::CommitChanges()
{
  _bstr_t relativePath ;
  VARIANT_BOOL secure=VARIANT_FALSE ;

  if (!mInitialized)
  {
    HRESULT nRetVal=CORE_ERR_NOT_INITIALIZED ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTSiteList::CommitChanges", "Unable to commit site configuration changes.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("Unable to commit site configuration changes", IID_IMTSiteList, nRetVal) ;
  }

  try
  {
    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    MTConfigLib::IMTConfigPropSetPtr propSet;
    
    // TODO: should this always be xmlconfig?
    propSet = config->NewConfiguration("xmlconfig");
    // add the mtconfigdata section ...
    if (SetSiteData(propSet) == FALSE)
    {
      HRESULT nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::CommitChanges",
        "Invalid data section for configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Invalid data section for configuration file <%s>.", relativePath) ;
      return Error ("Invalid data section for configuration file.", IID_IMTSiteList, nRetVal) ;
    }

    // create the relative path ...
    relativePath = mRelativePath.c_str() ;
    relativePath += mRelativeFile.c_str() ;

    // write the propset out ...
    propSet->WriteToHost(mHostName.c_str(), relativePath, L"", L"",
      secure, VARIANT_TRUE);
  }
	catch (_com_error err)
  {
    SetError(err.Error(), ERROR_MODULE, ERROR_LINE, "MTSiteList::CommitChanges",
      "Caught error while writing site configuration information.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"Caught error during the writing of configuration file <%s> on host <%s>.", relativePath, 
      mHostName) ;
    mLogger.LogVarArgs (LOG_ERROR, 
        "CommitChanges() failed. Error Description = %s", (char*)err.Description()) ;
    return Error ("Unable to write configuration file.", IID_IMTSiteList, err.Error()) ;
  }

  // iterate through the list and create the new configuration tree hierarchy for any new sites ...
  if (mCreateNewSite == TRUE)
  {
    CreateNewSite() ;
  }

	return S_OK;
}

BOOL CMTSiteList::CreateNewSite()
{
  BSTR providerName=NULL ;
  VARIANT_BOOL newSiteFlag=VARIANT_FALSE ;
  LPDISPATCH pDisp=NULL ;
  HRESULT nRetVal=S_OK ;
  IMTSite *pSite=NULL ;

	if (!mInitialized)
  {
    HRESULT nRetVal=CORE_ERR_NOT_INITIALIZED ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTSiteList::CreateNewSite", "Unable to create new site configuration.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("Unable to create new site configuration", IID_IMTSiteList, nRetVal) ;
  }

  // iterate through the site objects ...
  for (unsigned int i = 0; i < mSiteList.size(); i++) 
  {
    pDisp = NULL;
    pDisp = mSiteList[i].pdispVal;
    nRetVal = pDisp->QueryInterface(IID_IMTSite, (void**)&pSite);
    if (FAILED(nRetVal))
    {
      return nRetVal;
    }
    ASSERT (pSite);
    
    pSite->get_NewSite(&newSiteFlag);
    pSite->get_ProviderName(&providerName);
    
    // release the site ...
    pSite->Release() ;

    // if this is a new site ...
    if (newSiteFlag == VARIANT_TRUE)
    {
      // create new site with localized_site.xml file ...
      CreateLocalizedSiteInfo(providerName) ;
      
      // create new site with site.xml file ...
      CreateSiteInfo(providerName) ;      
      
      // free the provider name ...
      if (providerName != NULL)
      {
        ::SysFreeString (providerName) ;
        providerName = NULL ;
      }
    }
  }
	return S_OK;
}

BOOL CMTSiteList::CreateLocalizedSiteInfo(BSTR aProviderName)
{
  _bstr_t profileName, profileValue ;
  _bstr_t relativePath, siteName ;
  VARIANT_BOOL secure=VARIANT_FALSE ;
  HRESULT nRetVal=S_OK ;
  list<wstring> siteList;

  // read the default site configuration file ...
  try
  {
    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    
    VARIANT_BOOL checksumMatch;
    
    // create the config dir ...
    relativePath = mRelativePath.c_str() ;
    relativePath += "default\\site.xml" ;
    
    // read the configuration file ...
    MTConfigLib::IMTConfigPropSetPtr propSet = 
      config->ReadConfigurationFromHost(mHostName.c_str(), relativePath, secure, &checksumMatch);
    
    // read the site configuration information out of the prop set ...
    if (propSet == NULL)
    {
      nRetVal = CORE_ERR_NO_PROP_SET ; 
      SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
        "MTSiteList::CreateLocalizedSiteInfo", "No propset read");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Configuration file <%s> not read from host <%s>.", 
        relativePath, mHostName.c_str()) ;
      return Error ("No propset read from host.", IID_IMTSiteList, nRetVal) ;
    }
    // get the data section ...
    MTConfigLib::IMTConfigPropSetPtr mainSet = propSet->NextSetWithName("mtconfigdata");
    if (mainSet == NULL)
    {
      nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateLocalizedSiteInfo",
        "Invalid data section for configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Invalid data section for configuration file <%s>.", relativePath) ;
      return Error ("Invalid data section for configuration file.", IID_IMTSiteList, nRetVal) ;
    }
    MTConfigLib::IMTConfigPropSetPtr sitesSet = mainSet->NextSetWithName("localized_sites");
    if (sitesSet == NULL)
    {
      nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateLocalizedSiteInfo",
        "Invalid data section for configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Invalid localized site for configuration file <%s>.", relativePath) ;
      return Error ("Invalid localized site for configuration file.", IID_IMTSiteList, nRetVal) ;
    }

    // get the localized sites ...
    MTConfigLib::IMTConfigPropSetPtr siteSet ;
    while ((siteSet = sitesSet->NextSetWithName("localized_site")) != NULL)
    {
      // read the values out of the default propset ...
      siteName = siteSet->NextStringWithName("site_name");

      // insert the value into the list ...
      siteList.push_back ((const wchar_t *) siteName) ;
    }
  }
  catch (_com_error err)
  {
    SetError(err.Error(), ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateLocalizedSiteInfo",
      "Caught error while reading site configuration information.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"Caught error during the reading of configuration file <%s> on host <%s>.", 
      relativePath, mHostName.c_str()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
        "CreateLocalizedSiteInfo() failed. Error Description = %s", (char*)err.Description()) ;
    return Error ("Unable to read configuration file.", IID_IMTSiteList, err.Error()) ;
  }

  // for every language in the list ...
  list<wstring>::iterator it;
	for (it = siteList.begin(); it != siteList.end(); ++it)
	{
    // get the site name ...
    siteName = (*it).c_str();

    try
    {
      MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
      
      VARIANT_BOOL checksumMatch;
      
      // create the config dir ...
      relativePath = mRelativePath.c_str() ;
      relativePath += "default\\" ;
      relativePath += siteName ;
      relativePath += "\\localized_site.xml" ;
      
      // read the configuration file ...
      MTConfigLib::IMTConfigPropSetPtr propSet = 
        config->ReadConfigurationFromHost(mHostName.c_str(), relativePath, secure, &checksumMatch);
      
      // read the site configuration information out of the prop set ...
      if (propSet == NULL)
      {
        nRetVal = CORE_ERR_NO_PROP_SET ; 
        SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
          "MTSiteList::CreateLocalizedSiteInfo", "No propset read");
        mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
        mLogger.LogVarArgs (LOG_ERROR, 
          L"Configuration file <%s> not read from host <%s>.", 
          relativePath, mHostName.c_str()) ;
        return Error ("No propset read from host.", IID_IMTSiteList, nRetVal) ;
      }
      // get the data section ...
      MTConfigLib::IMTConfigPropSetPtr mainSet = propSet->NextSetWithName("mtconfigdata");
      if (mainSet == NULL)
      {
        nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
        SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateLocalizedSiteInfo",
          "Invalid data section for configuration file.");
        mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
        mLogger.LogVarArgs (LOG_ERROR, 
          L"Invalid data section for configuration file <%s>.", relativePath) ;
        return Error ("Invalid data section for configuration file.", IID_IMTSiteList, nRetVal) ;
      }
      
      MTConfigLib::IMTConfigPtr newConfig(MTPROGID_CONFIG);
      MTConfigLib::IMTConfigPropSetPtr newPropSet;
      
      // TODO: should this always be xmlconfig?
      newPropSet = newConfig->NewConfiguration("xmlconfig");
      
      // add the mtsysdata section ...
      if (SetMTSysHeader(newPropSet) == FALSE)
      {
        HRESULT nRetVal = CORE_ERR_INVALID_HEADER ;
        SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateNewSite",
          "Invalid header on configuration file.");
        mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
        mLogger.LogVarArgs (LOG_ERROR, 
          L"Invalid header for configuration file <%s>.", relativePath) ;
        return Error ("Invalid header on configuration file.", IID_IMTSiteList, nRetVal) ;
      }
      
      // insert the mtconfig data section ...
      IMTConfigPropSetPtr mtconfigdata = newPropSet->InsertSet("mtconfigdata");
      if (mtconfigdata == NULL)
      {
        HRESULT nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
        SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateNewSite",
          "Unable to insert data section to configuration file.");
        mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
        return FALSE ;
      }
      
      // while we have more config info to read ...
      MTConfigLib::IMTConfigPropSetPtr profileSet ;
      while ((profileSet = mainSet->NextSetWithName("profileset")) != NULL)
      {
        // read the values out of the default propset ...
        profileName = profileSet->NextStringWithName("profile_name");
        profileValue = profileSet->NextStringWithName("profile_value");
        
        // write the values into the new propset ...
        IMTConfigPropSetPtr configdata = mtconfigdata->InsertSet("profileset");
        
        // insert the profile_name and profile_value ...
        _variant_t var = profileName ;
        configdata->InsertProp("profile_name" , MTConfigLib::PROP_TYPE_STRING, var);
        var = profileValue ;
        configdata->InsertProp("profile_value" , MTConfigLib::PROP_TYPE_STRING, var);      
      }
      
      // create the relative path ...
      relativePath = mRelativePath.c_str() ;
      relativePath += aProviderName ;
      relativePath += "\\" ;
      relativePath += siteName ;
      relativePath += "\\localized_site.xml" ;
      
      // write the propset out ...
      newPropSet->WriteToHost(mHostName.c_str(), relativePath, L"", L"",
        secure, VARIANT_TRUE);
    }
    catch (_com_error err)
    {
      SetError(err.Error(), ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateLocalizedSiteInfo",
        "Caught error while reading site configuration information.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Caught error during the reading of configuration file <%s> on host <%s>.", 
        relativePath, mHostName.c_str()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        "CreateLocalizedSiteInfo() failed. Error Description = %s", (char*)err.Description()) ;
      return Error ("Unable to read configuration file.", IID_IMTSiteList, err.Error()) ;
    }
  }
  return TRUE;
}

BOOL CMTSiteList::CreateSiteInfo(BSTR aProviderName)
{
  _bstr_t relativePath ;
  VARIANT_BOOL secure=VARIANT_FALSE ;
  HRESULT nRetVal=S_OK ;

  try
  {
    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    
    VARIANT_BOOL checksumMatch;
    
    // create the config dir ...
    relativePath = mRelativePath.c_str() ;
    relativePath += "default\\site.xml" ;
    
    // read the configuration file ...
    MTConfigLib::IMTConfigPropSetPtr propSet = 
      config->ReadConfigurationFromHost(mHostName.c_str(), relativePath, secure, &checksumMatch);
    
    // read the site configuration information out of the prop set ...
    if (propSet == NULL)
    {
      nRetVal = CORE_ERR_NO_PROP_SET ; 
      SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
        "MTSiteList::CreateSiteInfo", "No propset read");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Configuration file <%s> not read from host <%s>.", 
        relativePath, mHostName.c_str()) ;
      return Error ("No propset read from host.", IID_IMTSiteList, nRetVal) ;
    }
    // get the data section ...
    MTConfigLib::IMTConfigPropSetPtr mainSet = propSet->NextSetWithName("mtconfigdata");
    if (mainSet == NULL)
    {
      nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateSiteInfo",
        "Invalid data section for configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Invalid data section for configuration file <%s>.", relativePath) ;
      return Error ("Invalid data section for configuration file.", IID_IMTSiteList, nRetVal) ;
    }
    
    MTConfigLib::IMTConfigPtr newConfig(MTPROGID_CONFIG);
    MTConfigLib::IMTConfigPropSetPtr newPropSet;
    
    // TODO: should this always be xmlconfig?
    newPropSet = newConfig->NewConfiguration("xmlconfig");
    
    // add the mtsysdata section ...
    if (SetMTSysHeader(newPropSet) == FALSE)
    {
      HRESULT nRetVal = CORE_ERR_INVALID_HEADER ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateSiteInfo",
        "Invalid header on configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Invalid header for configuration file <%s>.", relativePath) ;
      return Error ("Invalid header on configuration file.", IID_IMTSiteList, nRetVal) ;
    }
    
    // insert the mtconfig data section ...
    IMTConfigPropSetPtr mtconfigdata = newPropSet->InsertSet("mtconfigdata");
    if (mtconfigdata == NULL)
    {
      HRESULT nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateSiteInfo",
        "Unable to insert data section to configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }
    
    // read the site config info ...
    MTConfigLib::IMTConfigPropSetPtr siteSet ;
    siteSet = mainSet->NextSetWithName("site_config") ;
    if (siteSet == NULL)
    {
      HRESULT nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateSiteInfo",
        "Unable to insert data section to configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }

    // read the values out of the default propset ...
    _bstr_t providerName = siteSet->NextStringWithName("provider_name");
    _bstr_t relativeURL = siteSet->NextStringWithName("URL");
    _bstr_t description = siteSet->NextStringWithName("description");
    _bstr_t authMethod = siteSet->NextStringWithName("auth_method");
    _bstr_t accMapper = siteSet->NextStringWithName("acc_mapper");
    
    // write the values into the new propset ...
    IMTConfigPropSetPtr configdata = mtconfigdata->InsertSet("site_config");
    
    // insert the profile_name and profile_value ...
    _variant_t var = providerName ;
    configdata->InsertProp("provider_name" , MTConfigLib::PROP_TYPE_STRING, var);
    var = relativeURL ;
    configdata->InsertProp("URL" , MTConfigLib::PROP_TYPE_STRING, var);
    var = description ;
    configdata->InsertProp("description" , MTConfigLib::PROP_TYPE_STRING, var);
    var = authMethod ;
    configdata->InsertProp("auth_method" , MTConfigLib::PROP_TYPE_STRING, var);
    var = accMapper ;
    configdata->InsertProp("acc_mapper" , MTConfigLib::PROP_TYPE_STRING, var);

    // read the site config info ...
    MTConfigLib::IMTConfigPropSetPtr localizedSiteSet ;
    localizedSiteSet = mainSet->NextSetWithName("localized_sites") ;
    if (localizedSiteSet == NULL)
    {
      HRESULT nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateSiteInfo",
        "Unable to insert data section to configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }

    // write the values into the new propset ...
    IMTConfigPropSetPtr siteconfigdata = mtconfigdata->InsertSet("localized_sites");

    // while we have more config info to read ...
    _bstr_t siteName ;
    MTConfigLib::IMTConfigPropSetPtr localizedSite;
    while ((localizedSite = localizedSiteSet->NextSetWithName("localized_site")) != NULL)
    {
      // read the values out of the default propset ...
      siteName = localizedSite->NextStringWithName("site_name");
      
      // write the values into the new propset ...
      IMTConfigPropSetPtr localizedconfigdata = siteconfigdata->InsertSet("localized_site");
      
      // insert the profile_name and profile_value ...
      _variant_t var = siteName ;
      localizedconfigdata->InsertProp("site_name" , MTConfigLib::PROP_TYPE_STRING, var);
    }

    // create the relative path ...
    relativePath = mRelativePath.c_str() ;
    relativePath += aProviderName ;
    relativePath += "\\site.xml" ;
    
    // write the propset out ...
    newPropSet->WriteToHost(mHostName.c_str(), relativePath, L"", L"",
      secure, VARIANT_TRUE);
  }
  catch (_com_error err)
  {
    SetError(err.Error(), ERROR_MODULE, ERROR_LINE, "MTSiteList::CreateSiteInfo",
      "Caught error while reading site configuration information.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"Caught error during the reading of configuration file <%s> on host <%s>.", 
      relativePath, mHostName.c_str()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
        "CreateSiteInfo() failed. Error Description = %s", (char*)err.Description()) ;
    return Error ("Unable to read configuration file.", IID_IMTSiteList, err.Error()) ;
  }
  return TRUE ;
}


BOOL CMTSiteList::SetMTSysHeader(MTConfigLib::IMTConfigPropSetPtr aPropSet)
{
	if (aPropSet == NULL)
	{
    HRESULT nRetVal = CORE_ERR_NO_PROP_SET ; 
    SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
      "MTSiteList::SetMTSysHeader", "No propset to write header to");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    return FALSE; 
	}

	// insert header information: effective date, timeout value etc.
	IMTConfigPropSetPtr header = aPropSet->InsertSet("mtsysconfigdata");
	if (header == NULL)
	{
    HRESULT nRetVal = CORE_ERR_INVALID_HEADER ;
    SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::SetMTSysHeader",
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

BOOL CMTSiteList::SetSiteData(MTConfigLib::IMTConfigPropSetPtr aPropSet)
{
	IMTSite* pSite=NULL;
	LPDISPATCH pDisp = NULL;
  HRESULT hr=S_OK ;
  BSTR name=NULL, providerName=NULL, relativeURL=NULL;
  VARIANT_BOOL newSiteFlag=VARIANT_FALSE ;

  if (aPropSet == NULL)
  {
    HRESULT nRetVal = CORE_ERR_NO_PROP_SET ; 
    SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
      "MTSiteList::SetSiteData", "No propset to write header to");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    return FALSE; 
  }
  
  IMTConfigPropSetPtr mtconfigdata = aPropSet->InsertSet("mtconfigdata");
  
  if (mtconfigdata == NULL)
  {
    HRESULT nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
    SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTSiteList::SetSiteData",
      "Unable to insert data section to configuration file.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  // iterate through the map and insert all the data ...
  for (unsigned int i = 0; i < mSiteList.size(); i++) 
	{
    pDisp = NULL;
    pDisp = mSiteList[i].pdispVal;
    hr = pDisp->QueryInterface(IID_IMTSite, (void**)&pSite);
    if (FAILED(hr))
    {
      return FALSE;
    }
    ASSERT (pSite);

    // get the contents of the site ...
    pSite->get_Name(&name);
    pSite->get_ProviderName(&providerName);
    pSite->get_RelativeURL(&relativeURL);
    pSite->get_NewSite(&newSiteFlag) ;

    // if this is a new site ... set the new site flag ...
    if (newSiteFlag == VARIANT_TRUE)
    {
      mCreateNewSite = TRUE ;
    }

    // release the com object ...
    pSite->Release() ;
   
    // insert a new site ...
    IMTConfigPropSetPtr configdata = mtconfigdata->InsertSet("site");

    // insert the name, webURL and provider_name ...    
    configdata->InsertProp("name" , MTConfigLib::PROP_TYPE_STRING, name);
    configdata->InsertProp("WebURL" , MTConfigLib::PROP_TYPE_STRING, relativeURL);
    configdata->InsertProp("provider_name" , MTConfigLib::PROP_TYPE_STRING, providerName);

    // release the BSTR's ...
    if (name != NULL)
    {
      ::SysFreeString (name) ;
      name = NULL ;
    }
    if (providerName != NULL)
    {
      ::SysFreeString (providerName) ;
      providerName = NULL ;
    }
    if (relativeURL != NULL)
    {
      ::SysFreeString (relativeURL) ;
      relativeURL = NULL ;
    }
  }

  return TRUE ;
}

STDMETHODIMP CMTSiteList::Remove(BSTR aName, BSTR aProviderName, BSTR aRelativeURL)
{
  HRESULT nRetVal = S_OK;
  BSTR name=NULL, relativeURL=NULL, providerName=NULL;
  BOOL bSiteMatch=FALSE ;
  IMTSite *pSite=NULL ;
  LPDISPATCH pDisp=NULL ;
  
  // iterate through the list and see if we have a site with the same name, 
  // provider name or relative URL ...
  for (unsigned int i = 0; i < mSiteList.size() && bSiteMatch == FALSE; i++) 
  {
    pDisp = NULL;
    pDisp = mSiteList[i].pdispVal;
    nRetVal = pDisp->QueryInterface(IID_IMTSite, (void**)&pSite);
    if (FAILED(nRetVal))
    {
      return nRetVal;
    }
    ASSERT (pSite);
    
    pSite->get_Name(&name);
    pSite->get_ProviderName(&providerName);
    pSite->get_RelativeURL(&relativeURL);
    
    // release the site ...
    pSite->Release() ;    
    
    // if any of the things match ... remove the item and exit ...
    if (((_bstr_t)name == (_bstr_t)aName) || 
      ((_bstr_t)providerName == (_bstr_t)aProviderName) || 
      ((_bstr_t)relativeURL == (_bstr_t)aRelativeURL))
    {
      bSiteMatch = TRUE ;
      mSiteList.erase (mSiteList.begin() + i);
      mSize-- ;
    }
    // release the BSTR's ...
    if (name != NULL)
    {
      ::SysFreeString (name) ;
      name = NULL ;
    }
    if (providerName != NULL)
    {
      ::SysFreeString (providerName) ;
      providerName = NULL ;
    }
    if (relativeURL != NULL)
    {
      ::SysFreeString (relativeURL) ;
      relativeURL = NULL ;
    }
  }

	return nRetVal;
}
