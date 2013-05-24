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
* Created by: Boris Partensky
* $Header$
* 
***************************************************************************/

// LocaleConfig.cpp : Implementation of CLocaleConfig
#include "StdAfx.h"
#include "MTLocaleConfig.h"
#include "LocaleConfig.h"
#include <SetIterate.h>
#include <RcdHelper.h>
#include <stdutils.h>
#include <MTLocalizedCollection.h>
#include <mtglobal_msg.h>

/////////////////////////////////////////////////////////////////////////////
// CLocaleConfig

STDMETHODIMP CLocaleConfig::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ILocaleConfig
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     			Localize
// Arguments:     BSTR name_space - locale space
//								BSTR lang_space - language space
//								BSTR fqn				-	localized string
//
// Return Value:  
// Errors Raised: 
// Description:   Creates a new MTLocalizedEntry object and adds it
//								to internal MTLocalizedCollection object
// ----------------------------------------------------------------

STDMETHODIMP CLocaleConfig::Localize(BSTR name_space, 
																		 BSTR	lang_code, 
																		 BSTR	fqnString, 
																		 BSTR localeEntry,
																		 VARIANT aExtension)
{
	HRESULT hr = S_OK;
	wchar_t *pSpace;
  wchar_t SpaceBuf[256];
	_variant_t vExtension = aExtension;
  int SpaceBufLen = sizeof(SpaceBuf)/sizeof(wchar_t);
  
	wchar_t seps[] = L"\\, /";
	
	_bstr_t bstrNameSpace = name_space;

	//Set first token in FQN as name space
	if(bstrNameSpace.length() == 0)
	{
		wcsncpy( SpaceBuf, (wchar_t *)_bstr_t(fqnString),  SpaceBufLen);
		//cut off first token and make it subdirectory
		pSpace = wcstok( SpaceBuf, seps);
		bstrNameSpace = _bstr_t(pSpace);
	}

	try
	{
		if(vExtension.vt != VT_ERROR)
		{
			mLookupLocalizedCollection->Add(vExtension.bstrVal, name_space, lang_code, fqnString, localeEntry);
			mWriteLocalizedCollection->Add(vExtension.bstrVal, name_space, lang_code, fqnString, localeEntry);
		}
		else
		{
			mLookupLocalizedCollection->Add(L"", name_space, lang_code, fqnString, localeEntry);
			mWriteLocalizedCollection->Add(L"", name_space, lang_code, fqnString, localeEntry);
		}
	}
	catch(_com_error& err)
	{
		mLogger.LogVarArgs(LOG_ERROR, 
											"Failed to set one of the properties, error <%s>",
											err.Description());
		return ReturnComError(err);
	}

	return hr;
}

// ----------------------------------------------------------------
// Name:     			Write
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   Writes internal MTLocalizedCollection to XML files
//								File names are constructed automatically from locale space
//								and language code for elements in this collection. Every entry
//								is put in to appropriate file
// ----------------------------------------------------------------

STDMETHODIMP CLocaleConfig::Write()
{
  HRESULT nRet = S_OK;

  try
  {
    if (mbReadOnly)
    {
      char buf[255];
      sprintf(buf,"Can only write to a single extension, use Initialize(\"Extensionname\")");
      mLogger.LogThis(LOG_ERROR, buf);
      return Error(buf , IID_ILocaleConfig, E_FAIL);
    }
    
    //////////////////////////////////////////////////////////////////////////////
    // variables
    
    BOOL bFileExists = FALSE;
    BOOL bKeyExists = FALSE;
    _variant_t name, value, lang;
    _bstr_t map_key;
    _bstr_t full_path = L"";
    _bstr_t prev_full_path = L"";
    
    MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    MTConfigLib::IMTConfigPtr NewConfig(MTPROGID_CONFIG);
    MTConfigLib::IMTConfigPropSet* pSet = NULL;
    
    MTConfigLib::IMTConfigPropSetPtr confSet;
    MTConfigLib::IMTConfigPropSetPtr NewConfSet;
    
    MTConfigLib::IMTConfigPropSetPtr NameSpaceSet;
    MTConfigLib::IMTConfigPropSetPtr NewNameSpaceSet;
    
    MTConfigLib::IMTConfigPropSetPtr LocaleSet;
    MTConfigLib::IMTConfigPropSetPtr NewLangSet;
    MTConfigLib::IMTConfigPropSetPtr NewLocaleSet;
    MTConfigLib::IMTConfigPropSetPtr subset;
    MTConfigLib::IMTConfigPropPtr prop;
    
    MTConfigLib::IMTConfigAttribSetPtr pAttrib(MTPROGID_CONFIG_ATTRIB_SET);
    
    //	RCDLib::IMTRcdFileListPtr aFileList;
    //	FileLookupSet aLookupSet;
    
    // end variables
    //////////////////////////////////////////////////////////////////////////////
    
    
    MTConfigLib::IMTConfigAttribSetPtr pPtypeAttrib(MTPROGID_CONFIG_ATTRIB_SET);
    pPtypeAttrib->Initialize();
    pPtypeAttrib->AddPair(PTYPE_TAG_NAME, PTYPE_VALUE_TAG_NAME);
    
    
    // get a list of files by extension that we are trying to write
    //aFileList = RunQueryByExtension(_bstr_t(mrwExtension));
    //BuildLookupSet(aLookupSet,aFileList);
    
    int size = mWriteLocalizedCollection->GetSize();
    
    mLogger.LogThis(LOG_DEBUG, "Writing Localization collection to files...");
    
    //for (int i=0; i < size; )
    mWriteLocalizedCollection->Begin();
    BOOL cond = FALSE;
    while(!mWriteLocalizedCollection->End())
    {
      //TLOCALECONFIGLib::IMTLocalizedEntryPtr pEntryPtr = NULL;
      confSet = config->NewConfiguration(CONFIG_TAG_NAME);
      //nRet = mLocalizedCollection->get_Item(++i, &varEnum);
      
      //nRet = varEnum.pdispVal->QueryInterface(IID_IMTLocalizedEntry, (void**)&pEntryPtr);
      //varEnum.Clear();
      
      //if(!SUCCEEDED(nRet))
      //	return nRet;
      
      _bstr_t bstrNamespace = mWriteLocalizedCollection->GetNamespace();
      
      //Create  this entry in Global namespace if namespace property is empty
      _bstr_t bstrLanguageCode = mWriteLocalizedCollection->GetLanguageCode();
      _bstr_t bstrFQN = mWriteLocalizedCollection->GetFQN();
      _bstr_t bstrLocalizedString = mWriteLocalizedCollection->GetLocalizedString();
      _bstr_t	bstrExtension = mWriteLocalizedCollection->GetExtension();
      
      //See if extension property is set on LocalizedEntry object
      //If it's not, then take extension from Config object
      if(bstrExtension.length() == 0)
        bstrExtension = mrwExtension.c_str();
      if(bstrExtension.length() > 0)
        full_path = GetFilePath(bstrNamespace, bstrLanguageCode, bstrExtension);
      else
        return Error("Extension must be set before writing localized collection!");
      
      map_key = _wcslwr(full_path);
      // this value is TRUE only if the file has allready been read and is the the write list
      bKeyExists = FindKey(map_key);
      
      //See if file already exist, if yes and not in the map then create property set
      // and add it to the map
      if (prev_full_path != full_path) 
      {
        try 
        {
          prev_full_path = full_path;
          confSet = NULL;
          
          nRet = ReadConfiguration(full_path,(IMTConfigPropSet **)&confSet);
          
          if(!SUCCEEDED(nRet)) 
          {
            nRet = S_OK;
            confSet = NULL;
          }
        }
        // this is OK... it means the file does not exist on disk
        catch(_com_error&) {}
      }
      
      //new file and no entry in map
      if(confSet == NULL && !bKeyExists)
      {
        confSet = config->NewConfiguration(CONFIG_TAG_NAME);
        name = bstrFQN;
        value = bstrLocalizedString;
        lang =bstrLanguageCode;
        confSet->InsertProp(LANGUAGE_TAG_NAME,  MTConfigLib::PROP_TYPE_STRING, lang);
        
        //create namespace set
        pAttrib->Initialize();
        pAttrib->AddPair(NAMESPACE_NAME_TAG_NAME, bstrNamespace);
        NameSpaceSet = confSet->InsertSet(NAMESPACE_TAG_NAME);
        NameSpaceSet->put_AttribSet(pAttrib);
        
        LocaleSet = NameSpaceSet->InsertSet(LOCALE_ENTRY_TAG_NAME);
        
        LocaleSet->InsertProp(LOCALE_NAME_TAG_NAME,  MTConfigLib::PROP_TYPE_STRING, name);
        LocaleSet->InsertProp(LOCALE_VALUE_TAG_NAME,  MTConfigLib::PROP_TYPE_STRING, value);
        MTConfigLib::IMTConfigPropSet* pSet = (MTConfigLib::IMTConfigPropSet*)confSet.Detach();
        
        mPropSetColl.insert(PropSetColl::value_type((wchar_t*)map_key, pSet));
      }
      else if (confSet != NULL && !bKeyExists)
      {
        //extract interface pointer and add it to the collection
        lang = bstrLanguageCode;
        MTConfigLib::IMTConfigPropSetPtr set = MTConfigLib::IMTConfigPropSetPtr(confSet);
        MTConfigLib::IMTConfigPropSet* pSet = (MTConfigLib::IMTConfigPropSet*)set.Detach();
        mPropSetColl.insert(PropSetColl::value_type((wchar_t*)map_key, pSet));
      }
      
      NewConfSet = NewConfig->NewConfiguration(CONFIG_TAG_NAME);
      lang = bstrLanguageCode;
      NewConfSet->InsertProp(LANGUAGE_TAG_NAME,  MTConfigLib::PROP_TYPE_STRING, lang);
      
      //create namespace set
      pAttrib->Initialize();
      pAttrib->AddPair(NAMESPACE_NAME_TAG_NAME, bstrNamespace);
      NewNameSpaceSet = NewConfSet->InsertSet(NAMESPACE_TAG_NAME);
      NewNameSpaceSet->put_AttribSet(pAttrib);
      
      PropSetColl::iterator it = mPropSetColl.find((const wchar_t*)map_key);
      
      if (it == mPropSetColl.end())
      {
        mLogger.LogThis(LOG_ERROR, "Iterator passed collection end!");
        return E_FAIL;
      }
      
      MTConfigLib::IMTConfigPropSet* pSet = NULL;
      pSet = (MTConfigLib::IMTConfigPropSet*) ((*it).second);
      confSet = MTConfigLib::IMTConfigPropSetPtr(pSet);
      
      if (confSet == NULL)
      {
        mLogger.LogThis(LOG_ERROR, "Failed retrieving PropSet pointer from collection!");
        return E_FAIL;
      }
      
      name = bstrFQN;
      value = bstrLocalizedString;
      
      NewLocaleSet =	config->NewConfiguration(LOCALE_ENTRY_TAG_NAME);
      
      NewLocaleSet->InsertProp(LOCALE_NAME_TAG_NAME,  MTConfigLib::PROP_TYPE_STRING, name);
      NewLocaleSet->InsertProp(LOCALE_VALUE_TAG_NAME,  MTConfigLib::PROP_TYPE_STRING, value);
      
      nRet = confSet->Reset();
      
      confSet->NextStringWithName(LANGUAGE_TAG_NAME);
      
      NameSpaceSet = confSet->NextSetWithName(NAMESPACE_TAG_NAME);
      
      if (NameSpaceSet == NULL)
      {
        char buffer[256];
        _bstr_t file = (wchar_t*)(*it).first.c_str();
        sprintf(buffer, "<locale_space> set not found in file %s", (const char*)file );
        mLogger.LogVarArgs(LOG_ERROR, buffer);
        return Error ((const char*)buffer, IID_ILocaleConfig, E_FAIL);
      }
      
      BOOL bPutNew = FALSE;
      while((LocaleSet = NameSpaceSet->NextSetWithName(LOCALE_ENTRY_TAG_NAME)) != NULL)
      {
        _bstr_t bstrLocaleName = LocaleSet->NextStringWithName(LOCALE_NAME_TAG_NAME);
        
        wstring sLocaleName = _wcslwr(bstrLocaleName);
        wstring sNewLocaleName = _wcslwr((wchar_t*)bstrFQN);
        
        if (sLocaleName.compare(sNewLocaleName) == 0)
        {
          subset = NewNameSpaceSet->InsertSet(LOCALE_ENTRY_TAG_NAME);
          nRet = NewLocaleSet->Reset();
          nRet = subset->AddSubSet(NewLocaleSet);
          bPutNew = TRUE;
        }
        else
        {
          nRet = LocaleSet->Reset();
          subset = NewNameSpaceSet->InsertSet(LOCALE_ENTRY_TAG_NAME);
          nRet = subset->AddSubSet(LocaleSet);
        }
      }
      
      if (!bPutNew)
      {
        subset = NewNameSpaceSet->InsertSet(LOCALE_ENTRY_TAG_NAME);
        nRet = NewLocaleSet->Reset();
        nRet = subset->AddSubSet(NewLocaleSet);
        bPutNew = TRUE;
      }
      //replace map item
      
      mPropSetColl.erase(it);
      MTConfigLib::IMTConfigPropSet* pNewSet = (MTConfigLib::IMTConfigPropSet*)NewConfSet.Detach();
      mPropSetColl.insert(PropSetColl::value_type((wchar_t*)map_key, pNewSet));
      if(!SUCCEEDED(nRet))
      {
        _bstr_t buffer = L"Unable to write Configuration set";
        mLogger.LogThis(LOG_ERROR,(const char*)buffer);
        return Error ((const char*)buffer, IID_ILocaleConfig, nRet);
      }
      
      mWriteLocalizedCollection->Next();
  }
  if(!WriteCollection())
  {
    _bstr_t buffer = L"Failed to write collection to file!";
    mLogger.LogThis(LOG_ERROR,(const char*)buffer);
    return Error ((const char*)buffer, IID_ILocaleConfig, nRet);
  }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
		
  return nRet;
}

// ----------------------------------------------------------------
// Name:     			GetFilePath
// Arguments:    
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

_bstr_t CLocaleConfig::GetFilePath(BSTR name_space, BSTR lang, BSTR aExtension)
{
	_bstr_t bstrNameSpace = name_space;
	_bstr_t parsedDir;
	_bstr_t parsedFileName;
	_bstr_t bstrExtension = aExtension;
	
	if (bstrNameSpace.length() == 0)
			bstrNameSpace = "Global";
	
	wchar_t *pFile;
  wchar_t FileBuf[256];
  int FileBufLen = sizeof(FileBuf)/sizeof(wchar_t);
  
	wchar_t seps[] = L"\\, /";
	
	
	wcsncpy( FileBuf, (wchar_t *)bstrNameSpace,  FileBufLen);
	
	//cut off first token and make it subdirectory
	pFile = wcstok( FileBuf, seps);

	//see if the extension was passed in, if it wasn't then
	//assume mrwExtension
	if (bstrExtension.length() == 0)
		parsedDir = mrwExtension.c_str();
	else
	{
		parsedDir = bstrExtension;
	}

	::CreateDirectoryA(parsedDir, NULL);

	parsedDir +=	L"\\config\\";
	
	::CreateDirectoryA(parsedDir, NULL);

	parsedDir+="localization\\";

	::CreateDirectoryA(parsedDir, NULL);

	parsedDir +=  _bstr_t(pFile);

	::CreateDirectoryA(parsedDir, NULL);

	
	return (parsedDir + L"\\" + GetFileName(name_space, lang));
}

// ----------------------------------------------------------------
// Name:     			GetFileName
// Arguments:    
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

_bstr_t CLocaleConfig::GetFileName(BSTR name_space, BSTR lang)
{
	_bstr_t bstrNameSpace = name_space;
	_bstr_t parsedDir;
	_bstr_t parsedFileName;
	
	if (bstrNameSpace.length() == 0)
			bstrNameSpace = "Global";
	
	wchar_t *pFile;
  wchar_t FileBuf[256];
  int FileBufLen = sizeof(FileBuf)/sizeof(wchar_t);
  
	wchar_t seps[] = L"\\, /";
	
	
	wcsncpy( FileBuf, (wchar_t *)bstrNameSpace,  FileBufLen);
	
	pFile = wcstok( FileBuf, seps);

	
	//convert '/' and '\' to '_' and compose a file name
	while( pFile != NULL)
	{
		parsedFileName += _bstr_t(pFile);
		pFile = wcstok( NULL, seps);
		if (pFile)
			parsedFileName += L"_";
	}

	return (parsedFileName + L"_" + lang + L".xml");
}


// ----------------------------------------------------------------
// Name:     			FindKey
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

BOOL CLocaleConfig::FindKey(BSTR aKey)
{
	_bstr_t key = _bstr_t(aKey);
	PropSetColl::iterator it;
	if (mPropSetColl.size() == 0)
		return FALSE;
	else
	{
		it = mPropSetColl.find((const wchar_t*)key);
		return (it != mPropSetColl.end());
	}
}

// ----------------------------------------------------------------
// Name:     			WriteCollection
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

BOOL CLocaleConfig::WriteCollection()
{
  BOOL ret = TRUE;
    
  try
  {
    HRESULT nRet = S_OK;
    MTConfigLib::IMTConfigPropSet* pSet = NULL;
    MTConfigLib::IMTConfigPropSetPtr pSetPtr = NULL;
    PropSetColl::iterator it;
    
    int size = mPropSetColl.size();
    
    if (size == 0)
      return TRUE;
    
    mLogger.LogVarArgs(LOG_DEBUG, "About to write %i items", size);
    
    for(it=mPropSetColl.begin(); it != mPropSetColl.end();)
    {
      wstring fileName = (*it).first.c_str();
      try
      {
        pSet = (MTConfigLib::IMTConfigPropSet*)((*it++).second);
        
        nRet = WriteConfiguration((wchar_t*)fileName.c_str(),(IMTConfigPropSet **)&pSet);
        
        if (FAILED(nRet))
          return FALSE;
        pSet->Release();
      }
      catch (_com_error& err)
      {
        mLogger.LogVarArgs(LOG_ERROR, "Error occured writing Locale collection to file <%s>, Error description <%s>",
          (const char*)_bstr_t(fileName.c_str()), (const char*)err.Description());
        return FALSE;
      }
    }
    //clear the map
    mPropSetColl.clear();
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }

	return ret;
}

// ----------------------------------------------------------------
// Name:     			Load
// Arguments:     BSTR name_space		-		locale space
//								BSTR lang_code		-		language code
// Return Value:  
// Errors Raised: 
// Description:   Creates internal collection for specified locale space
//									and language code
// ----------------------------------------------------------------

/*
1. Get Locale Master file
2. Open every file in name_space subdir
3. If lang Code on file matches the one passed - create Localized entry for
		every entry in the file and add it to IMTLocalizedCollection
*/
STDMETHODIMP CLocaleConfig::Load(BSTR name_space, BSTR lang_code)
{
  HRESULT hr = S_OK;	
  LocalFileList files;
  try
  {
    
  /*
  wchar_t *pNameSpace;
  wchar_t NameSpaceBuf[256];
  int NameSpaceBufLen = sizeof(NameSpaceBuf)/sizeof(wchar_t);
  wchar_t seps[]   = L"\\";
    */
    
    wstring wsNameSpace = _wcslwr(_bstr_t(name_space));
    wstring wsParsedNameSpace;
    wstring wsParsedLangCode;
    wstring wsLangCode = _wcsupr(_bstr_t(lang_code));
    
    hr = PopulateFileList(_bstr_t(mrwExtension.c_str()),files,_bstr_t(wsLangCode.c_str()),_bstr_t(wsNameSpace.c_str()));
    if(SUCCEEDED(hr)) 
    {
      hr = LoadCollectionFromFileVector(files);
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return hr;
}

// ----------------------------------------------------------------
// Name:     			GetLocalizedString
// Arguments:     BSTR fqn					-		fqn
//								BSTR lang_code		-		language code
// Return Value:  BSTR*							-		localized string
// Errors Raised: 
// Description:   returns a localized string for specified FQN and lang code
// ----------------------------------------------------------------


STDMETHODIMP CLocaleConfig::GetLocalizedString(BSTR fqn, BSTR lang_code, BSTR *str)
{

	HRESULT nRet = S_OK;
	
	mLookupLocalizedCollection->Find(fqn, lang_code, str);

	return nRet;
}

// ----------------------------------------------------------------
// Name:     			SetLocalizedString
// Arguments:     BSTR fqn					-		locale space
//								BSTR lang_code		-		language code
//								BSTR newval				-		new localized string
// Return Value:  
// Errors Raised: 
// Description:   Changes localized string for existing MTLoclaizedEntry
//								ATTENTION:		Do not use this method to create localized entries,
//															Use Localize() instead	
// ----------------------------------------------------------------

STDMETHODIMP CLocaleConfig::SetLocalizedString(BSTR fqn, BSTR lang_code, BSTR newval)
{
  HRESULT nRet = S_OK;
  try
  {
    wstring wsFQN = _wcslwr(_bstr_t(fqn));
    wstring wsFetchedFQN;
    wstring wsLangCode = _wcsupr(_bstr_t(lang_code));
    wstring wsFetchedLangCode;
    _bstr_t bstrValue = newval;
    
    mLookupLocalizedCollection->Begin();
    while(!mLookupLocalizedCollection->End())
    {
      _bstr_t bstrFQN = mLookupLocalizedCollection->GetFQN();
      _bstr_t bstrLangCode = mLookupLocalizedCollection->GetLanguageCode();
      _bstr_t bstrExtension = mLookupLocalizedCollection->GetExtension();
      _bstr_t bstrNamespace = mLookupLocalizedCollection->GetNamespace();
      
      wsFetchedFQN = _wcslwr(bstrFQN);
      wsFetchedLangCode = _wcsupr(bstrLangCode);
      
      if(	wsFQN.compare(wsFetchedFQN) == 0 &&
        wsLangCode.compare(wsFetchedLangCode) == 0 )
      {
        mLookupLocalizedCollection->Add(bstrExtension, bstrNamespace, bstrLangCode, bstrFQN, bstrValue);
        mWriteLocalizedCollection->Add(bstrExtension, bstrNamespace, bstrLangCode, bstrFQN, bstrValue);
        return nRet;
      }
      mLookupLocalizedCollection->Next();
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
	//mLogger.LogVarArgs(LOG_DEBUG, "Localized Entry \"%s\" not found in the collection, nothing to update!", 
	//								(const char*)wsFQN.c_str());
	//nRet = S_FALSE;
	//return Error("Entry not found in collection, nothing to update!", IID_ILocaleConfig, nRet);
	return S_OK;
}

STDMETHODIMP CLocaleConfig::Clear()
{
	mLookupLocalizedCollection->Clear();
	mWriteLocalizedCollection->Clear();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			Initialize
// Arguments:     VARIANT config_dir (OPTIONAL) - configuration dir
//								VARIANT host (OPTIONAL)				-	Host Name 
// Return Value:  
// Errors Raised: 
// Description:   Sets config dir and host for Loclization files location
//								Following rules apply:
//
//								1.	If host_name is set, all reading and writing
//										of localized strings will happen remotely from/to
//										this host's relative dir == root_dir.
//
//								2.	If host name is not set but root_dir is,
//										all reading and writing of localized strings
//										will be local from/to root_dir\Localization
//
//								3.	If none of these two parameters are set,
//										objects are initialized in read-only mode
//										from MTConfigDir
// ----------------------------------------------------------------

STDMETHODIMP CLocaleConfig::Initialize(VARIANT aExtension, VARIANT host_name)
{
	HRESULT hr = S_OK;
	_variant_t varHost = host_name;
	_variant_t varConfig = aExtension;

	mrwExtensionDir = "";
  GetExtensionsDir(mrwExtensionDir);
	
	if	(host_name.vt == VT_ERROR || 
			(_bstr_t(varHost) == _bstr_t(""))) // host was not set
	{
		if	(aExtension.vt == VT_ERROR || 
			(_bstr_t(varConfig) == _bstr_t(""))) // config root was not set
		{
			mrwExtension = "";
			mbReadOnly = TRUE;
			mLogger.LogThis(LOG_DEBUG, "Initializing with all extensions, READ ONLY Mode!");
		}
		else
		{
			mrwExtension = mrwExtensionDir + "\\";
			mrwExtension += (const char*)_bstr_t(varConfig);
			mbReadOnly = FALSE;
		}
	}
	else //host was set
	{
		mHost = _bstr_t(varHost);
		mrwExtension = "";
	}
	return hr;
}



// ----------------------------------------------------------------
// Name:     			ReadConfiguration
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

/*
Figure out if need to read configuration from host or not
and read configuration
File should be a relative path including Localization subdir
if file is NULL, then  read master file
*/
HRESULT CLocaleConfig::ReadConfiguration(BSTR file,::IMTConfigPropSet**	pSet)
{
	HRESULT ret = S_OK;
	VARIANT_BOOL secure = VARIANT_FALSE;
	VARIANT_BOOL checksumMatch;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	_bstr_t bstrFile;
	_bstr_t bstrFullPath;
	BOOL bLogDebug = FALSE;
	
	ASSERT(file);
	_bstr_t pInputFile(file);
	
	
	/*
	if(mrwExtension.length() == 0) {
		return Error("ReadConfiguration only is for reading from extensions, Use Initialize(\"extension\") first");
		}
	*/
	
		//bstrFullPath =  mrwExtension + L"\\config\\" + LOCALE_SUBDIR + L"\\" + pInputFile;
	bstrFullPath =  pInputFile;
		
		
		//If host variable is set, then set full path to relative dir + file
		//else to mrwConfigDir + file
		// if file == NULL, assume master file
	if(mHost.length() > 0)
	{
		if(bLogDebug) 
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Reading file \"%s\" from %s",
				(const char*)bstrFullPath, (const char*)mHost );
		}
		
		try
		{
			MTConfigLib::IMTConfigPropSetPtr ptr;
			ptr = config->ReadConfigurationFromHost(mHost, bstrFullPath, secure, &checksumMatch);
			if(bLogDebug)
				mLogger.LogVarArgs(LOG_DEBUG, "Done.");
			(*pSet) = (IMTConfigPropSet *)ptr.Detach();
		}
		catch(_com_error& err)
		{
			return ReturnComError(err);
		}
	}
	else
	{
		if(bLogDebug) 
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Reading file \"%s\" locally",
					(const char*)bstrFullPath);
		}
		try 
		{
			MTConfigLib::IMTConfigPropSetPtr ptr;
			ptr = config->ReadConfiguration(bstrFullPath, &checksumMatch);
			if(bLogDebug)
				mLogger.LogVarArgs(LOG_DEBUG, "Done.");
					(*pSet) = (IMTConfigPropSet *)ptr.Detach();
		}
		catch(_com_error err) 
		{
			return ReturnComError(err);
		}
	}
		return ret;
}

// ----------------------------------------------------------------
// Name:     			WriteConfiguration
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------


HRESULT CLocaleConfig::WriteConfiguration(BSTR file,::IMTConfigPropSet**	pSet)
{
	HRESULT ret = S_OK;
	VARIANT_BOOL secure = VARIANT_FALSE;
	_bstr_t bstrFile(file);
	
	_bstr_t bstrFullPath(file);
	
	//HACK: to ensure that Initialize method was called first
	/*
	if(mrwExtension.length() == 0) 
	{
		return Error("WriteConfiguration only is for writing to extensions, Use Initialize(\"extension\") first");
	}
	*/
	
	//If host variable is set, then set full path to relative dir + file
	if(mHost.length() > 0) 
	{
		mLogger.LogVarArgs(LOG_DEBUG, "Writing remotely to %s", (const char*)mHost );
		
		try 
		{
			MTConfigLib::IMTConfigPropSetPtr ptr(MTPROGID_CONFIG_PROPERTY_SET);
			ptr = (MTConfigLib::IMTConfigPropSet*) (*pSet);
			ret = ptr->WriteToHost(mHost, bstrFullPath, L"", L"", secure, VARIANT_TRUE);
			return ret;
		}
		catch(_com_error& err) 
		{
			mLogger.LogVarArgs(LOG_ERROR, "Failed to write Configuration Set to host \"%s\", file \"%s\", error <%s>", 
				(const char*)mHost, (const char*)bstrFullPath, (const char*)err.Description());
			return ReturnComError(err);
		}
	}
	else 
	{
		try 
		{
			MTConfigLib::IMTConfigPropSetPtr ptr = (*pSet);
			ret = ptr->Write(bstrFullPath);
			return ret;
		}
		catch(_com_error& err) 
		{
			mLogger.LogVarArgs(LOG_ERROR, "Failed to write Configuration Set to file \"%s\", error <%s>", 
				(const char*)bstrFullPath, (const char*)err.Description());
			return ReturnComError(err);
		}
	}
}

// ----------------------------------------------------------------
// Name:     			LoadCollectionFromFileVector
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

HRESULT CLocaleConfig::LoadCollectionFromFileVector(LocalFileList& files)
{
#ifdef PERFORMANCE_DEBUG
	mLogger.LogThis(LOG_DEBUG, "In LoadCollectionFromFileVector(LocalFileList& files)");
	time_t startTime = time(NULL);
#endif
	//iterate through file names vector, open each file, create localized entry collection
	_bstr_t bstrLangCode, bstrNameSpace;

	HRESULT hr  = S_OK;
	
	//Clear Localized Collection
	mLookupLocalizedCollection->Clear();

	// query for the "this" pointer in the localizedCollection.
	CMTLocalizedCollection* pDirectCol = NULL;
	mLookupLocalizedCollection->QueryInterface(IID_NULL,(void**)&pDirectCol);
	if(!pDirectCol) 
	{
		mLogger.LogThis(LOG_DEBUG,"Warning: Couldn't get direct C++ interface");
	}

	int size = files.size();
		mLogger.LogVarArgs(LOG_DEBUG, "Loading collection from file vector (<%i> elements)", size);

	for (int i=0; i < size;)
	{
		MTConfigLib::IMTConfigPropSetPtr aPropSet = files.at(i++);
		// need to reset the propset because we are starting are processing at the top
		aPropSet->Reset();

		try
		{
			
			bstrLangCode = aPropSet->NextStringWithName(LANGUAGE_TAG_NAME);
			
			MTConfigLib::IMTConfigPropSetPtr NameSpaceSet = aPropSet->NextSetWithName(NAMESPACE_TAG_NAME);

			if(NameSpaceSet == NULL)
			{
				mLogger.LogThis(LOG_ERROR, "locale_space set does not exist");
				return Error("Failed reading file", IID_ILocaleConfig, E_FAIL);
			}

			//GetNamespace name and set name space property of collection entry
			MTConfigLib::IMTConfigAttribSetPtr pAttrib = NameSpaceSet->GetAttribSet();
						
			if (pAttrib == NULL)
			{	
				mLogger.LogThis (LOG_ERROR,
							"Unable to get attrib set for enum_space tag");
				return Error ("Unable to get attrib set for <namespace> tag!",
						IID_ILocaleConfig, hr);
			}
			
			bstrNameSpace = pAttrib->GetAttrValue(NAMESPACE_NAME_TAG_NAME);
			int num = 0;
			MTConfigLib::IMTConfigPropSetPtr subSet;

			while((subSet = NameSpaceSet->NextSetWithName(LOCALE_ENTRY_TAG_NAME)) != NULL)
			{
				
				_bstr_t bstrLocaleName = subSet->NextStringWithName(LOCALE_NAME_TAG_NAME);
				_bstr_t bstrLocaleValue = subSet->NextStringWithName(LOCALE_VALUE_TAG_NAME);
				/*
				entry.CreateInstance(MTPROGID_LOCALE_ENTRY);
				
				entry->PutNamespace(bstrNameSpace);
				entry->PutLanguageCode(bstrNameSpace);
				entry->Putfqn(bstrNameSpace);
				entry->PutLocalizedString(bstrNameSpace);
				*/

				// if for some reason we can't go through the C++ interface use COM.  it is a bit slower.
				if(!pDirectCol) {
					//add entry to collection
					//pass empty string for extension
					mLookupLocalizedCollection->Add(L"", bstrNameSpace, bstrLangCode, bstrLocaleName, bstrLocaleValue);
				}
				else 
				{
					// go through C++.  This is faster
					//pass empty string for extension
					CMTLocalizedEntry* pEntry = new CMTLocalizedEntry(L"", bstrNameSpace, bstrLangCode, bstrLocaleName, bstrLocaleValue);
					pDirectCol->InsertEntryIntoCollection(bstrLocaleName,bstrLangCode,pEntry);
				}
				
			}
		}
		catch (_com_error err)
		{
			files.clear();
			return (ReturnComError(err));
		}

	}
	mLogger.LogVarArgs(LOG_DEBUG, "Done.(Loaded %i items into Collection)", (int)mLookupLocalizedCollection->GetSize());
	files.clear();
#ifdef PERFORMANCE_DEBUG
	time_t now = time(NULL);
	long seconds = now - startTime;
	mLogger.LogThis(LOG_DEBUG, "Exiting LoadCollectionFromFileVector(LocalFileList& files)");
	mLogger.LogVarArgs(LOG_DEBUG, "Spent <%d> seconds in it", seconds);
#endif

	return hr;
}

// ----------------------------------------------------------------
// Name:     			get_Count
// Arguments:     
// Return Value:  long*				-		number of items in internal collection
// Errors Raised: 
// Description:   Returns number of items in internal collection
// ----------------------------------------------------------------

STDMETHODIMP CLocaleConfig::get_Count(long * pVal)
{
	mWriteLocalizedCollection->get_Count(pVal);
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			LoadLanguage
// Arguments:     BSTR lang_code		-		language code
// Return Value:  
// Errors Raised: 
// Description:   Creates internal collection for specified
//								language code
// ----------------------------------------------------------------

STDMETHODIMP CLocaleConfig::LoadLanguage(BSTR lang_code)
{
	HRESULT hr = S_OK;	
	
	LocalFileList files;
  try
  {
    hr = PopulateFileList(_bstr_t(mrwExtension.c_str()),files,_bstr_t(lang_code),_bstr_t(""));
    
    if(SUCCEEDED(hr)) 
    {
      return LoadCollectionFromFileVector(files);
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
	return hr;	
}


// ----------------------------------------------------------------
// Name:     			IsLeaf
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------
// note: this is not a member function
bool IsLeaf(MTConfigLib::IMTConfigPropSetPtr& aPropSet)
{
	ASSERT(aPropSet != NULL);

	bool bResult = (aPropSet->NextWithName(LOCALE_FILE_TAG) == NULL) ? true : false;
	aPropSet->Reset();
	return bResult;
}


// ----------------------------------------------------------------
// Name:     			PopulateFileList
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------


HRESULT CLocaleConfig::PopulateFileList(_bstr_t& aPath,LocalFileList& aList,_bstr_t& szLanguageCode,_bstr_t& szLocalSpace)
{
#ifdef PERFORMANCE_DEBUG
	mLogger.LogThis(LOG_DEBUG, "In PopulateFileList(_bstr_t& aPath,LocalFileList& aList,_bstr_t& szLanguageCode,_bstr_t& szLocalSpace)");
	time_t startTime = time(NULL);
#endif

	
  HRESULT hr = S_OK;

  try
  {
    MTConfigLib::IMTConfigPropSetPtr aPropSet;
    MTConfigLib::IMTConfigPtr aConfig(MTPROGID_CONFIG);
    VARIANT_BOOL vUnusedChecksum;
    // step 2: run query for files.  if aPath is nothing, we are reading all the enumerated types.
    // otherwise, a path is interpreted as an extension
    RCDLib::IMTRcdFileListPtr aFileList = RunQueryByExtension(aPath);
    
    // step 3: verify that we found configuration
    if(aFileList->GetCount() == 0) 
    {
      hr = Error("No localization files found that match query",IID_ILocaleConfig, E_FAIL);
    }
    else 
    {
      
      SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
      hr = it.Init(aFileList);
      if(FAILED(hr)) return hr;
      
      while (TRUE) 
      {
        
        _variant_t aVariant= it.GetNext();
        _bstr_t afile = aVariant;
        if(afile.length() == 0) break;
        
        aPropSet = aConfig->ReadConfiguration(afile,&vUnusedChecksum);
        
        _bstr_t aLanguageCode = aPropSet->NextStringWithName(LANGUAGE_TAG_NAME);
        _bstr_t aLocalSpace;
        bool bLocalSpaceMatch = false;
        try 
        {
          aLocalSpace = aPropSet->NextSetWithName(NAMESPACE_TAG_NAME)->GetAttribSet()->GetAttrValue("name");
          unsigned int len = szLocalSpace.length();
          if(len == 0 || _wcsnicmp(szLocalSpace,aLocalSpace,len) == 0) 
          {
            bLocalSpaceMatch = true;
          }
        }
        catch(_com_error& e) 
        {
          return ReturnComError(e);
        }
        
        //check if this locale space and language
        //match the expected file name
        _bstr_t bstrExpectedFileName = GetSubDirs(afile) + GetFileName(aLocalSpace, aLanguageCode);
        if(wcsicmp((wchar_t*)afile, (wchar_t*)bstrExpectedFileName))
        {
          char buf[1024];
          sprintf(buf, "LocaleSpace <%s>, Language Code <%s> have to reside in <%s>, not <%s>",
            (char*)aLocalSpace, (char*)aLanguageCode, (char*)bstrExpectedFileName, (char*)afile);
          mLogger.LogThis(LOG_ERROR, buf);
          return Error(buf , IID_ILocaleConfig, MTLOCALECONFIG_FILE_NAME_MISMATCH);
        }
        
        //want to load everything
        if ((szLanguageCode.length() == 0) && (szLocalSpace.length() == 0)){
          aList.push_back(aPropSet);
        }
        // partial load - only for spacified locale space and language code
        else if(	(_wcsicmp((wchar_t*)szLanguageCode, (wchar_t*)aLanguageCode) == 0) && bLocalSpaceMatch) 
        {
          aList.push_back(aPropSet);
        }
      }
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
      

#ifdef PERFORMANCE_DEBUG
	time_t now = time(NULL);
	long seconds = now - startTime;
	mLogger.LogThis(LOG_DEBUG, "Exiting PopulateFileList(_bstr_t& aPath,LocalFileList& aList,_bstr_t& szLanguageCode,_bstr_t& szLocalSpace)");
	mLogger.LogVarArgs(LOG_DEBUG, "Spent <%d> seconds in it", seconds);
#endif
	return hr;
}

// ----------------------------------------------------------------
// Name:     			InitializeWithFileName
// Arguments:     BSTR filename						-		master file name
//								BSTR host (OPTIONAL)		-		host name
// Return Value:  
// Errors Raised: 
// Description:   Set master file name and optionaly host name to
//								load localization files from
// ----------------------------------------------------------------

STDMETHODIMP CLocaleConfig::InitializeWithFileName(BSTR filename,BSTR host)
{
	ASSERT("!This method is not supported anymore");
	return E_NOTIMPL;
	/*
	ASSERT(filename && host);
	if(!(filename && host)) return E_POINTER;

	//relative or full path and masterfile name
	mLocalePath = filename;
	mHost = host;
	mbInitWithFileName = TRUE;
	return S_OK;
	*/
}

// ----------------------------------------------------------------
// Name:     			get_LocalizedCollection
// Arguments:     
//								IMTLocalizedCollection**		-		internal collection
// Return Value:  
// Errors Raised: 
// Description:   Return internal localized collection
// ----------------------------------------------------------------

STDMETHODIMP CLocaleConfig::get_LocalizedCollection(IMTLocalizedCollection **pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;
	*pVal = NULL;

	*pVal = (IMTLocalizedCollection *)mLookupLocalizedCollection.GetInterfacePtr();
	
	if(*pVal) {
		(*pVal)->AddRef();
		return S_OK;
	}
		
	return E_FAIL;
}

// ----------------------------------------------------------------
// Name:     			GetSubDirs
// Arguments:     
// Return Value:  
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

#pragma warning(disable:4018)
_bstr_t CLocaleConfig::GetSubDirs(BSTR file)
{
	_bstr_t name = file;
	wchar_t seps[] = L"\\, /";
	wchar_t *pFile;
	wchar_t FileBuf[256];
	std::vector<wchar_t*> tokens;
	_bstr_t subdirs;
	int FileBufLen = sizeof(FileBuf)/sizeof(wchar_t);

	wcsncpy( FileBuf, (wchar_t *)name,  FileBufLen);
  
	pFile = wcstok( FileBuf, seps);

	while( pFile != NULL )   
	{
		
		tokens.push_back(pFile);
		pFile = wcstok( NULL, seps );
	}

	for (int i  = 0; i < tokens.size()-1; i++ )
	{
		subdirs += _bstr_t(tokens.at(i)) + "\\";
	}

	return subdirs;
      
}
#pragma warning(default:4018)


// ----------------------------------------------------------------
// Name:     			InitRCD
// Arguments:     none
// Return Value:  none
// Errors Raised: none
// Description:   Inits copy of RCD
// ----------------------------------------------------------------

void CLocaleConfig::InitRCD()
{
  try
  {
    if(!mbRCDInit) 
    {
      mRCD = RCDLib::IMTRcdPtr(MTPROGID_RCD);
      mRCD->Init();
      mbRCDInit = true;
    }
  }
  catch(_com_error& e)
  {
    MT_THROW_COM_ERROR(e.Error());
  }
}

// ----------------------------------------------------------------
// Name:     			RunQueryByExtension
// Arguments:     extension name (may be "" to indicate all extensions)
// Return Value:  aRcdFileList smart pointer
// Description:   Returns a filelist from the appropriate query
// ----------------------------------------------------------------


RCDLib::IMTRcdFileListPtr CLocaleConfig::RunQueryByExtension(_bstr_t& aExtension)
{
	// step 1: init RCD
  RCDLib::IMTRcdFileListPtr aFileList;
    
  try
  {
    InitRCD();
    
    const _bstr_t aQueryString("config\\localization\\*.xml");
    if(aExtension.length() == 0) 
    {
      aFileList = mRCD->RunQuery(aQueryString,VARIANT_TRUE);
    }
    else 
    {
      aFileList = mRCD->RunQueryInAlternateFolder(aQueryString,VARIANT_TRUE,aExtension);
    }
  }
  catch(_com_error& e)
  {
    MT_THROW_COM_ERROR(e.Error());
  }

	return aFileList;
}

void CLocaleConfig::BuildLookupSet(FileLookupSet& aSet, RCDLib::IMTRcdFileListPtr& aFileList)
{

	SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
	it.Init(aFileList);
	while (TRUE) {

		_variant_t aVariant= it.GetNext();
		_bstr_t afile = aVariant;
		if(afile.length() == 0) break;

		wstring aInsert((const wchar_t*)afile);
		aSet.insert(aInsert);
	}
}


