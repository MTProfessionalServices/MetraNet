// MTModule.cpp : Implementation of CMTModule
#include "StdAfx.h"

// MT specific stuff
#include <mtmodulereader.h>
#include "MTModule.h"
#include <mtcom.h>
#include <mtprogids.h>
#include "loggerconfig.h"
#include "modxmltags.h"
#include <string>

#include <ConfigDir.h>

using namespace std;

bool operator==(IMTModuleDescriptorPtr a,IMTModuleDescriptorPtr b) { return true; }

/////////////////////////////////////////////////////////////////////////////
// CMTModule


//////////////////////////////////////////////////////////////////////
//CMTModule
//////////////////////////////////////////////////////////////////////

CMTModule::CMTModule() : mpMainMod(NULL), mpVariantList(NULL), mRemoteHost(""), mFileName(""),mbAbsolutePath(false)
{
}

CMTModule::~CMTModule()
{
  for(unsigned int i=0;i<mSubModuleList.size();i++) 
    mSubModuleList[i].Release();

  if(mpVariantList) {
    delete[] mpVariantList;

  }

  // explicit descructors.. for debuging memory problems
#ifdef _DEBUG
  mModSpecific = 0;
  mpMainMod = 0;
  mFileName.~_bstr_t();
  mName.~_bstr_t();
  mConfigFile.~_bstr_t();
#endif

}

//////////////////////////////////////////////////////////////////////
//InterfaceSupportsErrorInfo
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTModule,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

//////////////////////////////////////////////////////////////////////
//get_Name
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::get_Name(BSTR * pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_FAIL;
  *pVal = mName.copy(); 
	return S_OK;
}

//////////////////////////////////////////////////////////////////////
//put_Name
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::put_Name(BSTR Val)
{
  ASSERT(_bstr_t(Val) != _bstr_t(""));
  if(_bstr_t(Val) == _bstr_t("")) return E_FAIL;
  mName = Val;
	return S_OK;
}


//////////////////////////////////////////////////////////////////////
//get__NewEnum
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::get__NewEnum(LPUNKNOWN * pVal)
{
  // step 1: validate input params
  if(!(pVal && mSubModuleList.size() > 0)) return E_FAIL;

  typedef CComObject<CComEnum<IEnumVARIANT, &IID_IEnumVARIANT, VARIANT,
  _Copy<VARIANT> > > enumvar;

	enumvar* pEnumVar = new enumvar;

  // step 2: delete the old list
  if(mpVariantList) delete[] mpVariantList;

  // step 3: create a list of variants
  unsigned int size = mSubModuleList.size();
  mpVariantList = new _variant_t[size];

  // step 4: initialize the variant list
  for(unsigned int i=0;i<size;i++) {
    IDispatch* pDisp;
    mSubModuleList[i].QueryInterface(IID_IDispatch,
      &pDisp);
    mpVariantList[i] = pDisp;
    pDisp->Release();
  }
 
  // step 5: initialize the  CCOmEnum
	HRESULT hr = pEnumVar->Init(mpVariantList, mpVariantList + size, NULL, AtlFlagCopy);

	if (SUCCEEDED(hr))
		hr = pEnumVar->QueryInterface(IID_IEnumVARIANT,
																	reinterpret_cast<void**>(pVal));

	if (FAILED(hr))
		delete pEnumVar;

	return hr;
}

//////////////////////////////////////////////////////////////////////
//GetSubModuleByIndex
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::GetSubModuleByIndex(long aIndex, IMTModule ** ppMod)
{
  HRESULT hr(E_FAIL);

  if(aIndex >= 0 && aIndex < (long)mSubModuleList.size()) {
    hr = GetSubModuleInternal(aIndex,ppMod) ? S_OK : E_FAIL;
  }
 
  return hr;
}

STDMETHODIMP CMTModule::GetSubModule(BSTR aName,::IMTModule** ppSubMod)
{
  _bstr_t aString;
  _bstr_t ModuleName(aName);
  ASSERT(ppSubMod);
  *ppSubMod = NULL;

  // step  1: walk through vector

  for(unsigned int i=0;i<mSubModuleList.size();i++) {
    aString = mSubModuleList[i]->GetName();
    if(_bstr_t(aString) ==ModuleName) {
      GetSubModuleInternal(i,ppSubMod);
      break;
    }
  }

  return (*ppSubMod != NULL) ? S_OK : E_FAIL;
}

//////////////////////////////////////////////////////////////////////
//get_SubModule
//////////////////////////////////////////////////////////////////////

BOOL CMTModule::GetSubModuleInternal(long index,::IMTModule** pReturnVal)
{
  ASSERT(index >= 0 && index < (long)mSubModuleList.size());
 
  IMTModuleDescriptorPtr aSubModule = mSubModuleList[index];
  BOOL bRetVal(FALSE);

  do {
    try {
      // step 2: if there is an inline submodule, use it.
      aSubModule->get_ModConfigInfo((MODULEREADERLib::IMTModule **)pReturnVal);

      // step 2a: set the path of the submodule
      (*pReturnVal)->put_ModuleDataPath(mFilePath);
      (*pReturnVal)->put_RemoteHost(mRemoteHost);
      bRetVal = TRUE;
      break;
    }
    catch(_com_error) {}

    // step 3: if we get this far, find the module name
    _bstr_t aModName = aSubModule->GetName();
    VARIANT_BOOL aBool;
    aSubModule->IsSubDir(&aBool);

    // we only handle the sub dir case for now
    _bstr_t FullyQualifiedModName;
      GetFullModName(aModName,FullyQualifiedModName);


    bRetVal = GetModuleInSubDir(FullyQualifiedModName,(MODULEREADERLib::IMTModule**)pReturnVal);
  } while(false);

  if(!bRetVal) *pReturnVal = NULL;
	return bRetVal;
}

//////////////////////////////////////////////////////////////////////
//GetModuleInSubDir
//////////////////////////////////////////////////////////////////////

BOOL CMTModule::GetModuleInSubDir(_bstr_t& aModName,MODULEREADERLib::IMTModule** ppMod)
{
  ASSERT(ppMod);
  if(!ppMod) return FALSE;

  BOOL bRetVal(FALSE);

  IMTModulePtr aModule(MTPROGID_MODULE);
  try {
    if(mRemoteHost != _bstr_t(""))
      aModule->PutRemoteHost(mRemoteHost);
			aModule->PutAbsolutePath(mbAbsolutePath);

    aModule->PutModuleDataFileName(aModName);
    aModule->Read();
    *ppMod = aModule.Detach();
    bRetVal = TRUE;
  }
  catch(_com_error) {}

  return bRetVal;

}

//////////////////////////////////////////////////////////////////////
//get_ConfigFile
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::get_ConfigFile(BSTR * pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_FAIL;
  *pVal = mConfigFile.copy();
	return S_OK;
}

//////////////////////////////////////////////////////////////////////
//put_ConfigFile
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::put_ConfigFile(BSTR pVal)
{
  ASSERT(_bstr_t(pVal) != _bstr_t(""));
  if(_bstr_t(pVal) == _bstr_t("")) return E_FAIL;
  mConfigFile = pVal;
	return S_OK;
}

//////////////////////////////////////////////////////////////////////
//get_ModuleSpecificInfo
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::get_ModuleSpecificInfo(::IMTConfigPropSet** pVal)
{
  ASSERT(pVal);
  if(mModSpecific == NULL) {
    *pVal = NULL;
    return E_FAIL;
  }
  *pVal = (::IMTConfigPropSet*)mModSpecific.GetInterfacePtr();
  // I need to Add ref here so when the user destroys the propset 
  // my pointer does not get nuked
	mModSpecific->Reset();
  mModSpecific.AddRef();
	return S_OK;
}
//////////////////////////////////////////////////////////////////////
//put_ModuleSpecificInfo
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::put_ModuleSpecificInfo(::IMTConfigPropSet* pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_FAIL;
  mModSpecific = pVal;
	return S_OK;
}


//////////////////////////////////////////////////////////////////////
//Read
//////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE " CMTModule::Read()"
STDMETHODIMP CMTModule::Read()
{
  HRESULT hr(S_OK);
	_bstr_t aTempStr;

  try {
    ASSERT(mFileName != bstr_t(""));

    IMTConfigPtr config(MTPROGID_CONFIG);
    VARIANT_BOOL checksumMatch;

    // we don't really care if the checksum matches or not.
     IMTConfigPropSetPtr aPropset;

    if(mRemoteHost == _bstr_t("")) {
		std::string aConfigDir;

			// if it isn't an absolute path, use the configuration directory
			if(!(bool)mbAbsolutePath) {
				if(GetMTConfigDir(aConfigDir)) {
					aTempStr = aConfigDir.c_str();
					aTempStr += mFileName;
				}
				else {
					mLogger->LogThis(LOG_ERROR,PROCEDURE ": Failed to find configuration directory.");
					hr = E_FAIL;
				}
			}
			else {
				aTempStr = mFileName;
			}
			if(SUCCEEDED(hr)) {

				aPropset = config->ReadConfiguration(aTempStr, &checksumMatch);
			}
    }
    else {
      aPropset = config->ReadConfigurationFromHost(mRemoteHost,mFileName,VARIANT_FALSE,&checksumMatch);
    }

    if(!ProcessModuleFile(aPropset)) {
     hr = HRESULT_FROM_WIN32(GetLastErrorCode());
    }
  }
  catch (_com_error err)
	{
    hr = err.Error();
    mLogger->LogVarArgs(LOG_ERROR,PROCEDURE ": failed to read module file: error [%d] [%s]",hr,
      err.Description() != _bstr_t("") ? (char*)err.Description() : "no detailed error");
	}
	return hr;
}

//////////////////////////////////////////////////////////////////////
//ReadSet
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::ReadSet(::IMTConfigPropSet * pSet)
{
  IMTConfigPropSetPtr propSet(pSet);
  HRESULT hr(S_OK);

  if(!ProcessModuleFile(propSet,false)) {
    hr = E_FAIL;
  }
  return hr;
}

//////////////////////////////////////////////////////////////////////
//put_ModDescriptor
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::put_ModDescriptor(IMTModuleDescriptor * ppSubMod)
{
	ASSERT(ppSubMod);
  if(!ppSubMod) return E_FAIL;
  _bstr_t aString;
  _bstr_t aSubModString;
  MODULEREADERLib::IMTModulePtr aModPointer;


  IMTModuleDescriptorPtr aModDescriptor(ppSubMod);
  aSubModString = aModDescriptor->GetName();

  // step 1: verify that the sub module does not exist.  If it does, free the existing
  // entry and delete it from the vector
	vector<IMTModuleDescriptorPtr>::iterator it;
	it = mSubModuleList.begin();
  while (it != mSubModuleList.end()) {
    aString = (*it)->GetName();
    if(aSubModString == aString) {
      mLogger->LogVarArgs(LOG_WARNING,"Duplicate module %s found in module %s",(char*)_bstr_t(aString),(char*)mName);
      (*it).Release();
      mSubModuleList.erase(it);
      break;
    }
		++it;
  }

  // step 2: add the submodule, bumping the ref count
  mSubModuleList.insert(mSubModuleList.begin(), aModDescriptor);
  HRESULT hr(S_OK);

  // step 3: if our module descriptor points to another module, we need to verify that it
  // exists or create it.
  try {
    aModPointer = aModDescriptor->GetModConfigInfo();

    VARIANT_BOOL aSubDir;
    aModDescriptor->IsSubDir(&aSubDir);

    if(aSubDir == VARIANT_TRUE) {

      // get the module name
      aString = aModPointer->GetName();
      _bstr_t FullyQualifiedModName;

      GetFullModName(aString,FullyQualifiedModName);
      // we must specify the file name we will use in case we need it for later
      try {
      aModPointer->PutModuleDataFileName(FullyQualifiedModName);
      } 
      catch(_com_error e) {
        hr = e.Error();
      }
    }
  }
  // we can ignore any error here if the submodule does not exist
  catch(_com_error) {}

 	return hr;
}


//////////////////////////////////////////////////////////////////////
//Write
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::Write()
{
  HRESULT hr(S_OK);

  try {
    ASSERT(!!mFileName && (mFileName != bstr_t("")));
    if(!mFileName || mFileName ==  bstr_t("")) throw _com_error(E_FAIL);

		_bstr_t aFileName;

    // step 1: verify that the directory specified in the file name path exists
    if(!CreateDirPath(mFileName,aFileName)) throw _com_error(GetLastErrorCode());

    IMTConfigPtr config(MTPROGID_CONFIG);
    
    // we don't really care if the checksum matches or not.
    IMTConfigPropSetPtr propSet = config->NewConfiguration(MAIN_MOD_TAG);
    if(!WriteModuleFile(propSet)) {
     hr = HRESULT_FROM_WIN32(GetLastErrorCode());
    }
    else {
      if(mRemoteHost == _bstr_t("")) { 
        propSet->Write(aFileName);
      }
      else {
        propSet->WriteToHost(mRemoteHost,aFileName,_bstr_t(""),_bstr_t(""),VARIANT_FALSE,VARIANT_FALSE);
      }
    }
  }
  catch (_com_error err)
	{
    hr = HRESULT_FROM_WIN32(err.Error());
	}
	return hr;
}


//////////////////////////////////////////////////////////////////////
//WriteSet
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::WriteSet(::IMTConfigPropSet * pSet)
{
  ASSERT(pSet);
  if(!pSet) return E_FAIL;
  HRESULT hr(S_OK);

  MTConfigLib::IMTConfigPropSetPtr aPropset(pSet);

  if(!WriteModuleFile(aPropset)) {
    hr = HRESULT_FROM_WIN32(GetLastErrorCode());
  }

  return hr;
}

//////////////////////////////////////////////////////////////////////
//get_ModuleDataFileName
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::get_ModuleDataFileName(BSTR * pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_POINTER;
  *pVal = mFileName.copy();
	return S_OK;
}

//////////////////////////////////////////////////////////////////////
//put_ModuleDataFileName
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::put_ModuleDataFileName(BSTR newVal)
{
  ASSERT(_bstr_t(newVal) != _bstr_t(""));
  if(_bstr_t(newVal) == _bstr_t("")) return E_FAIL;
  
  // step 1: set the file name
  mFileName = newVal;

  // step 2: compute the directory

  std::string aStr((char*)mFileName);
  unsigned int length = aStr.find_last_of('\\', aStr.length());
  if(length != string::npos) {
    strncpy(mFilePath, aStr.c_str(), length);
  }
  else {
    mFilePath = ".\\";
  }

	return S_OK;
}

//////////////////////////////////////////////////////////////////////
//put_RemoteHost
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::put_RemoteHost(BSTR newVal)
{
  mRemoteHost = newVal;
	return S_OK;
}

//////////////////////////////////////////////////////////////////////
//get_RemoteHost
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::get_RemoteHost(BSTR* pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_POINTER;
  *pVal = mRemoteHost.copy();
	return S_OK;
}

//////////////////////////////////////////////////////////////////////
//get_Count
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::get_Count(long * pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_POINTER;
  *pVal = mSubModuleList.size();
	return S_OK;
}

//////////////////////////////////////////////////////////////////////
//get_Item
//////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::get_Item(long aIndex, VARIANT * pVal)
{
  ASSERT(aIndex >= 0);
  if(aIndex < 0 || aIndex >= (long)mSubModuleList.size()) return E_FAIL;

  _variant_t aVariant = (IDispatch*)mSubModuleList[aIndex];

	::VariantClear(pVal);
  ::VariantCopy(pVal,&aVariant);
  return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTModule::get_ModuleDataPath
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : BSTR* pVal
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::get_ModuleDataPath(BSTR* pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_POINTER;
  *pVal = mFilePath.copy();
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTModule::put_ModuleDataPath
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : BSTR newVal
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::put_ModuleDataPath(BSTR newVal)
{
  mFilePath = newVal;
	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTModule::get_AbsolutePath
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : VARIANT_BOOL *pVal
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::get_AbsolutePath(VARIANT_BOOL *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_FAIL;
	*pVal = mbAbsolutePath;
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTModule::put_AbsolutePath
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : VARIANT_BOOL newVal
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTModule::put_AbsolutePath(VARIANT_BOOL newVal)
{
	mbAbsolutePath = newVal;
	return S_OK;
}

STDMETHODIMP CMTModule::RemoveAllSubModules()
{

	mSubModuleList.resize(0);

#ifdef _DEBUG
	unsigned int NumEntries = mSubModuleList.size();
	ASSERT(NumEntries == 0);
#endif
	return S_OK;
}



//////////////////////////////////////////////////////////////////////
//ProcessModuleFile
//////////////////////////////////////////////////////////////////////

#define HANDLE_ERR(a,b) \
  if(a == NULL) { \
    aString = b; \
    break; \
  } \


#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTModule::ProcessModuleFile()"
BOOL CMTModule::ProcessModuleFile(IMTConfigPropSetPtr& aPropset,bool FromFile)
{
  BOOL bRetVal(FALSE);
  std::string aString;
  _variant_t aSetQuery;

  if(mpMainMod) mpMainMod->Release();


  try {
    do {

      HANDLE_ERR(aPropset,"Bad Propset.");

      MTConfigLib::IMTConfigPropSetPtr mainSet;
      if(FromFile) {
        mainSet = aPropset;
      }
      else {
        mainSet = aPropset->NextSetWithName(MAIN_MOD_TAG);
        HANDLE_ERR(mainSet,"missing " MAIN_MOD_TAG "set");
      }

      mName = mainSet->NextStringWithName(MOD_NAME_TAG);

      aSetQuery = mainSet->NextMatches(SUB_MODULES_TAG,MTConfigLib::PROP_TYPE_SET);
      if(aSetQuery) {

        MTConfigLib::IMTConfigPropSetPtr subSet = mainSet->NextSetWithName(SUB_MODULES_TAG);
        HANDLE_ERR(subSet,"Missing subset " SUB_MODULES_TAG);

        MTConfigLib::IMTConfigPropSetPtr currentSubset = subSet->NextSetWithName(SUB_MODULE_TAG);

        while(currentSubset != NULL) {
          if(!ProcessSubset(currentSubset)) break;

          currentSubset = subSet->NextSetWithName(SUB_MODULE_TAG);
        }
      }

      aSetQuery = mainSet->NextMatches(MODULE_CONFIG_FILE_TAG,MTConfigLib::PROP_TYPE_STRING);

      if(aSetQuery) {

        MTConfigLib::IMTConfigPropPtr ConfigFileLocation = mainSet->NextWithName(MODULE_CONFIG_FILE_TAG);
        HANDLE_ERR(ConfigFileLocation,"Missing Config file " MODULE_CONFIG_FILE_TAG);

        mConfigFile = _variant_t((IUnknown *) ConfigFileLocation->GetPropValue(),true);
      }

      mModSpecific = mainSet->NextSetWithName(MODULE_SPECIFIC_TAG);
      // since we are keeping around mModSpecific, we need to bump the ref count
     // int foo = mModSpecific.GetInterfacePtr()->AddRef();
      //mModSpecific.AddRef();

      bRetVal = TRUE;
    } while(false);

  } catch(_com_error e) {
    SetError(e.Error(),
						  ERROR_MODULE, 
						  ERROR_LINE, PROCEDURE,e.Description());
  }
  
  if(!bRetVal && FromFile) {
    if(!GetLastError()) {
    	  SetError(::GetLastError(), 
						  ERROR_MODULE, 
						  ERROR_LINE, PROCEDURE,aString.c_str());
    }
	    mLogger->LogErrorObject(LOG_ERROR, GetLastError());
  }
  mpMainMod.Attach(aPropset.Detach());

return bRetVal;
}

//////////////////////////////////////////////////////////////////////
// WriteModuleFile
//////////////////////////////////////////////////////////////////////

BOOL CMTModule::WriteModuleFile(IMTConfigPropSetPtr& aPropset)
{
	std::string aString;


  // we allready have the top level tag, we just need to create the sub tags

  //  bstr_t mName;
  // bstr_t mConfigFile;
  BOOL bRetVal(FALSE);
    _variant_t aVariant = mName;
  _bstr_t bName,bOrgType;

  try {
    do {

      HANDLE_ERR(aPropset,"Invalid propset");

  
      // insert the name
      aPropset->InsertProp(MOD_NAME_TAG,MTConfigLib::PROP_TYPE_STRING,aVariant);

      // create the submodules tag
      if(mSubModuleList.size() != 0) {
        MTConfigLib::IMTConfigPropSetPtr aSubModules = aPropset->InsertSet(SUB_MODULES_TAG);
        HANDLE_ERR(aSubModules,"Couldn't create " SUB_MODULES_TAG " tag");

        // enumerate through the sub modules
        for(unsigned int i=0;i<mSubModuleList.size();i++) {
          bName = mSubModuleList[i]->GetName();
          bOrgType = mSubModuleList[i]->GetOrgType();

          MTConfigLib::IMTConfigPropSetPtr aSubModule = aSubModules->InsertSet(SUB_MODULE_TAG);

          aVariant = bName;
          aSubModule->InsertProp(SUB_MODULE_NAME_TAG,MTConfigLib::PROP_TYPE_STRING,aVariant);
          aVariant = bOrgType;
          aSubModule->InsertProp(SUB_MOD_ORG_TAG,MTConfigLib::PROP_TYPE_STRING,aVariant);

          if(bOrgType == _bstr_t("inline")) {

            try {
              IMTModulePtr aInlineModule = mSubModuleList[i]->GetModConfigInfo();
              // if we got this far, create a new subset
              MTConfigLib::IMTConfigPropSetPtr aInlineModuleSet= aSubModule->InsertSet(MAIN_MOD_TAG);

              aInlineModule->WriteSet((MODULEREADERLib::IMTConfigPropSet*)aInlineModuleSet.GetInterfacePtr());
            }
            catch(_com_error) {}
          }
        }
      }

      // set the config file tag
      // this bizarre syntax is due to the fact that _bstr_t defines a NOT operator but
      // the compiler finds an ambiguity in the logical AND operator.  We want to find if mConfigFile
      // contains a valid string.  The double nots result in if(mConfigFile && comparison) functionality.
      if(!(!(_bstr_t)mConfigFile) && (mConfigFile != _bstr_t(""))) {
        aVariant = mConfigFile;
        aPropset->InsertProp(MODULE_CONFIG_FILE_TAG,MTConfigLib::PROP_TYPE_STRING,aVariant);
      }

      // set the module specific info, recursive function
      if(mModSpecific != NULL ) {
        // make sure that the mod specific propset is set to the beginning
        mModSpecific->Reset();
        MTConfigLib::IMTConfigPropSetPtr aSpecificSet = aPropset->InsertSet(MODULE_SPECIFIC_TAG);
        aSpecificSet->AddSubSet(mModSpecific);
      }


      bRetVal = TRUE;
    } while(false);
  } 

  catch(_com_error e) {
    SetError(e.Error(),
						ERROR_MODULE, 
						ERROR_LINE, PROCEDURE,e.Description());
  }
  if(!bRetVal) {
    if(!GetLastError()) {
    	  SetError(::GetLastError(), 
						  ERROR_MODULE, 
						  ERROR_LINE, PROCEDURE,aString.c_str());
    }
	    mLogger->LogErrorObject(LOG_ERROR, GetLastError());
  }

  return bRetVal;
}

//////////////////////////////////////////////////////////////////////
//ProcessSubset
//////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "CMTModule::ProcessModuleFile()"
BOOL CMTModule::ProcessSubset(IMTConfigPropSetPtr& aPropset)
{
  ASSERT(aPropset != NULL);
  if(aPropset == NULL) {
    SetError(::GetLastError(),
						  ERROR_MODULE, 
              ERROR_LINE, PROCEDURE,"Bad Propset pointer");
  }

  IMTModuleDescriptorPtr aSubModule(MTPROGID_MODDESCRIPT);
  _bstr_t SubModName,OrgType;

  SubModName = aPropset->NextStringWithName(SUB_MODULE_NAME_TAG);
  OrgType = aPropset->NextStringWithName(SUB_MOD_ORG_TAG);

  aSubModule->PutName(SubModName);
  aSubModule->PutOrgType(OrgType);

  IMTModulePtr aModule(MTPROGID_MODULE);
  try {
    aModule->ReadSet((MODULEREADERLib::IMTConfigPropSet*)aPropset.GetInterfacePtr());
    aSubModule->PutModConfigInfo(aModule.GetInterfacePtr());
  }
    // we don't care if this fails... just means we don't have an inline module
  catch(_com_error) {}

  //aSubModule.AddRef();
  mSubModuleList.insert(mSubModuleList.begin(), aSubModule);
  return true;
}


#define START_CHAR 48
#define STOP_CHAR 122

#define MOD_NUM 9
#define START_MOD_NUM 48

void CMTModule::GetFullModName(_bstr_t& aName,_bstr_t& aOutputFileName)
{

	std::string aStr((char*)mFileName);
  char aDirSep;
  std::string aDirSepStr;

  char* pRawName = aName;
  char ProcessedName[MAX_PATH];
  for(unsigned int i=0,j=0;i<strlen(pRawName) && i<MAX_PATH;i++,j++) {
    if((int)pRawName[i] >= START_CHAR && (int)pRawName[i] <= STOP_CHAR)
      ProcessedName[j] = pRawName[i];
    else {
      ProcessedName[j] =  (pRawName[i] % MOD_NUM) + START_MOD_NUM;
    }
  }
  ProcessedName[j++] = '\0';


  // decide if we are using Web based or file based
 // if(mRemoteHost == _bstr_t("")) {
  //}
 // else {
 //   aDirSep = '/';
 // }
    aDirSep = '\\';
  aDirSepStr = aDirSep;

  unsigned int length = aStr.find_last_of(aDirSep, aStr.length());
  strncpy(aOutputFileName, aStr.c_str(), length);
  //aOutputFileName = aStr.remove(aStr.last(aDirSep));

  aOutputFileName += (const char*)aDirSepStr.c_str();
  aOutputFileName += ProcessedName;
  aOutputFileName += (const char*)aDirSepStr.c_str();
  aOutputFileName += ProcessedName;
  aOutputFileName += MOD_FILE_NAME_POSTFIX;
}

BOOL CMTModule::CreateDirPath(const _bstr_t& aFullName,_bstr_t& aFileName)
{

  // only create the path if we are writing on the local disk

  if(mRemoteHost == _bstr_t("")) {

	  std::string aStr((char*)aFullName);
	  _bstr_t aDirectory;

    //_bstr_t aDirectory = aStr.remove(aStr.last('\\'));
	  unsigned int length;
	  length = aStr.find_last_of('\\', aStr.length());
	  if (length != string::npos)
		  strncpy(aDirectory, aStr.c_str(), length);


		if(!(bool)mbAbsolutePath) {
			std::string aConfigDir;
			GetMTConfigDir(aConfigDir);
			aDirectory += aConfigDir.c_str();
			aFileName = aConfigDir.c_str() + aFullName;
		}
		else {
			aFileName = aFullName;
		}

    if(aDirectory != _bstr_t("")) {

      if(::CreateDirectory(aDirectory,NULL) == 0) {

        DWORD error = ::GetLastError();
        if(error != ERROR_ALREADY_EXISTS) {
          char buff[100+MAX_PATH];
          sprintf(buff,"Failed to create the %s directory",buff);
          SetError(::GetLastError(),
						      ERROR_MODULE, 
						      ERROR_LINE, "CMTModule::CreateDirPath",buff);
          mLogger->LogErrorObject(LOG_ERROR, GetLastError());
          return FALSE;
        }
      }
    }
  }
	else {
		aFileName = aFullName;
	}
  return TRUE;
}

