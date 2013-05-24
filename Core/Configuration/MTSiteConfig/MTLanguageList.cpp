// MTLanguageList.cpp : Implementation of CMTLanguageList
#include "StdAfx.h"
#include <comdef.h>
#include "MTSiteConfig.h"
#include "MTLanguageList.h"
#include "MTLanguage.h"
#include <loggerconfig.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>

/////////////////////////////////////////////////////////////////////////////
// CMTLanguageList

CMTLanguageList::CMTLanguageList()
: mInitialized(FALSE), mSize(0)
{
  // initialize the logger
	LoggerConfigReader configReader;
	mLogger.Init (configReader.ReadConfiguration("Core"), CORE_TAG);
}

CMTLanguageList::~CMTLanguageList()
{
}


STDMETHODIMP CMTLanguageList::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTLanguageList,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTLanguageList::Initialize(BSTR aHostName, BSTR aRelativePath, BSTR aRelativeFile)
{
	VARIANT_BOOL secure=VARIANT_FALSE ;
  std::wstring wstrTagName, wstrTagValue ;
  _bstr_t name, description ;
  _bstr_t relativePath ;
  HRESULT nRetVal ;

  // copy the parameters ...
  mHostName = aHostName ;

  try
	{
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

		VARIANT_BOOL checksumMatch;

    // create the config dir ...
    relativePath = aRelativePath ;
    relativePath += aRelativeFile ;

    // read the configuration file ...
		MTConfigLib::IMTConfigPropSetPtr propSet = 
      config->ReadConfigurationFromHost(mHostName.c_str(), relativePath, secure, &checksumMatch);

    // read the site configuration information out of the prop set ...
    if (propSet == NULL)
    {
      nRetVal = CORE_ERR_NO_PROP_SET ; 
      SetError(CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
        "MTLanguageList::Initialize", "No propset read");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Configuration file <%s> not read from host <%s>.", 
        relativePath, aHostName) ;
      return Error ("No propset read from host.", IID_IMTLanguageList, nRetVal) ;
    }
    // get the data section ...
    MTConfigLib::IMTConfigPropSetPtr mainSet = propSet->NextSetWithName("mtconfigdata");
    if (mainSet == NULL)
    {
      nRetVal = CORE_ERR_INVALID_DATA_SECTION ;
      SetError(nRetVal, ERROR_MODULE, ERROR_LINE, "MTLanguageList::Initialize",
        "Invalid data section for configuration file.");
      mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
      mLogger.LogVarArgs (LOG_ERROR, 
        L"Invalid data section for configuration file <%s>.", relativePath) ;
      return Error ("Invalid data section for configuration file.", IID_IMTLanguageList, nRetVal) ;
    }
    
    // while we have more config info to read ...
    MTConfigLib::IMTConfigPropSetPtr siteSet ;
    while ((siteSet = mainSet->NextSetWithName("language")) != NULL)
    {
      // get the values from the XMl file ...
      name = siteSet->NextStringWithName("name");
      description = siteSet->NextStringWithName("description");

      // create the MTLanguage object to add into the list ...
      Add (name, description) ;

      // set the initialized flag ...
      mInitialized = TRUE ;
    }
	}
	catch (_com_error err)
  {
    mInitialized = FALSE ;
    SetError(err.Error(), ERROR_MODULE, ERROR_LINE, "MTLanguageList::Initialize",
      "Caught error while reading site configuration information.");
    mLogger.LogErrorObject(LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"Caught error during the reading of configuration file <%s> on host <%s>.", 
      relativePath, mHostName.c_str()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
        "Initialize() failed. Error Description = %s", (char*)err.Description()) ;
    return Error ("Unable to read configuration file.", IID_IMTLanguageList, err.Error()) ;
  }

	return S_OK;

}

STDMETHODIMP CMTLanguageList::get__NewEnum(LPUNKNOWN * pVal)
{
  HRESULT hr = S_OK;
  
  if (!mInitialized)
  {
    HRESULT nRetVal=CORE_ERR_NOT_INITIALIZED ; 
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTLanguageList::get__NewEnum", "Unable to get enumerator.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return Error ("Unable to get enumerator", IID_IMTLanguageList, nRetVal) ;
  }

  typedef CComObject<CComEnum<IEnumVARIANT, 
    &IID_IEnumVARIANT, VARIANT, _Copy<VARIANT> > > enumvar;
  
  enumvar* pEnumVar = new enumvar;
  ASSERT (pEnumVar);

  // if we dont have any items in the list ...
  if (mSize == 0)
  {
    hr = pEnumVar->Init(NULL, NULL, NULL, AtlFlagCopy);
  }
  // otherwise ... initialize the enumerator with the items in the list ...
  else
  {
    hr = pEnumVar->Init(&mLanguageList[0], &mLanguageList[mSize - 1] + 1, 
                        NULL, AtlFlagCopy);
  }
   
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

STDMETHODIMP CMTLanguageList::Add(BSTR aName, BSTR aDescription)
{
  HRESULT nRetVal = S_OK;
	CComObject<CMTLanguage>* pNewLang;
  BSTR name=NULL, description=NULL, providerName=NULL;
  BOOL bLangMatch=FALSE ;
  IMTLanguage *pLang=NULL ;
  LPDISPATCH pDisp=NULL ;
  
  // iterate through the list and see if we have a site with the same name, 
  // provider name or relative URL ...
  for (unsigned int i = 0; i < mLanguageList.size() && bLangMatch == FALSE; i++) 
  {
    pDisp = NULL;
    pDisp = mLanguageList[i].pdispVal;
    nRetVal = pDisp->QueryInterface(IID_IMTLanguage, (void**)&pLang);
    if (FAILED(nRetVal))
    {
      return nRetVal;
    }
    ASSERT (pLang);
    
    pLang->get_Name(&name);
    pLang->get_Description(&description);
    
    // release the site ...
    pLang->Release() ;    
    
    // if any of the things match ... exit ...
    if (((_bstr_t)name == (_bstr_t)aName) || 
      ((_bstr_t)description == (_bstr_t)aDescription))
    {
      bLangMatch = TRUE ;
    }
    // release the BSTR's ...
    if (name != NULL)
    {
      ::SysFreeString (name) ;
      name = NULL ;
    }
    if (providerName != NULL)
    {
      ::SysFreeString (description) ;
      description = NULL ;
    }
  }
  // if we dont have a site match ...
  if (bLangMatch == FALSE)
  {
    nRetVal = CComObject<CMTLanguage>::CreateInstance(&pNewLang);
    ASSERT(SUCCEEDED(nRetVal));
    
    pNewLang->Initialize(aName, aDescription);
    
    nRetVal = pNewLang->QueryInterface(IID_IDispatch, (void**)&pDisp);
    if (FAILED(nRetVal))
    {
      return nRetVal;
    }
    
    // create a variant
    CComVariant var;
    var.vt = VT_DISPATCH;
    var.pdispVal = pDisp;
    
    // append data
    mLanguageList.push_back(var);
    mSize++;
  }
  else
  {
    nRetVal = CORE_ERR_DUPLICATE_VALUE ;
    SetError (nRetVal, ERROR_MODULE, ERROR_LINE,
      "CMTLanguageList::Add", "Unable to add duplicate site.") ;
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger.LogVarArgs (LOG_ERROR, 
      L"Site configuration values. Name = <%s>. Description = <%s>",
      aName, aDescription) ;
    return Error ("Unable to add duplicate langauge.", IID_IMTLanguageList, nRetVal) ;
  }

	return nRetVal;
}

STDMETHODIMP CMTLanguageList::get_Count(long * pVal)
{
	if (!pVal)
  {
		return E_POINTER;
  }

	*pVal = mSize;

	return S_OK;
}

STDMETHODIMP CMTLanguageList::get_Item(long aIndex, VARIANT * pVal)
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

	VariantCopy(pVal, &mLanguageList[aIndex-1]);

	return S_OK;
}


