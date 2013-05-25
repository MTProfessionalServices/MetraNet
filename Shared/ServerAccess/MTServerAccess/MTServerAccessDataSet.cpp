// MTServerAccessDataSet.cpp : Implementation of CMTServerAccessDataSet
#include "StdAfx.h"
#include "MTServerAccess.h"
#include "MTServerAccessDataSet.h"

#include <mtprogids.h>
#include <mtcomerr.h>
#include <ConfigDir.h>

#import <RCD.tlb>

#include <autocritical.h>
#include <SetIterate.h>
#include <RcdHelper.h>


// import the configloader tlb file
#import <MTConfigLib.tlb>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

using namespace MTConfigLib;

/////////////////////////////////////////////////////////////////////////////
// CMTServerAccessDataSet

STDMETHODIMP CMTServerAccessDataSet::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTServerAccessDataSet
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTServerAccessDataSet::ServerAccessDataList
CMTServerAccessDataSet::mServerAccessDataList;
BOOL CMTServerAccessDataSet::mServerListLoaded = FALSE;


STDMETHODIMP CMTServerAccessDataSet::InitializeFromLocation(BSTR aLocation)
{
	// NOTE: this method is no longer supported - the list is cached
	// so we don't provide the option to read it from a different location.
	return E_NOTIMPL;

}

HRESULT CMTServerAccessDataSet::Initialize(IMTConfigPropSetPtr aPropSet)
{
	MTConfigLib::IMTConfigPropPtr propPtr;
	MTConfigLib::IMTConfigAttribSetPtr attribSet;

	// get the server set
	IMTConfigPropSetPtr serverSet = aPropSet->NextSetWithName(SERVER_TAG) ;

	// check for null set
	if (serverSet == NULL)
		return Error ("Failed to find server set");
		
		// read the server set
	BOOL passwordNotEncrypted = FALSE;
	while (serverSet != NULL)
	{
		_bstr_t servername;
		_bstr_t servertype;
		long numretries;
		long timeout;
		long priority;
		long secure;
		long portnumber;
		_bstr_t username;
		_bstr_t password;
		long DTCenabled;
		_bstr_t dbname;
		_bstr_t datasource;
		_bstr_t dbdriver;
		_bstr_t dbtype;

		servertype = serverSet->NextStringWithName(SERVER_TYPE_TAG);

		if (serverSet->NextMatches(SERVER_NAME_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
			servername = serverSet->NextStringWithName(SERVER_NAME_TAG);
		else
			servername = "";

		if (serverSet->NextMatches(DATABASE_NAME_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
			dbname = serverSet->NextStringWithName(DATABASE_NAME_TAG);
		else
			dbname = "";

		if (serverSet->NextMatches(DATASOURCE_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
			datasource = serverSet->NextStringWithName(DATASOURCE_TAG);
		else
			datasource = "";

		if (serverSet->NextMatches(DATABASE_DRIVER_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
			dbdriver = serverSet->NextStringWithName(DATABASE_DRIVER_TAG);
		else
			dbdriver = "";

		if (serverSet->NextMatches(DATABASE_TYPE_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
			dbtype = serverSet->NextStringWithName(DATABASE_TYPE_TAG);
		else
			dbtype = "";

		if (serverSet->NextMatches(NUM_RETRIES_TAG, PROP_TYPE_INTEGER) == VARIANT_TRUE)
			numretries = serverSet->NextLongWithName(NUM_RETRIES_TAG);
		else
			numretries = 0;
				
		if (serverSet->NextMatches(TIMEOUT_TAG, PROP_TYPE_INTEGER) == VARIANT_TRUE)
			timeout = serverSet->NextLongWithName(TIMEOUT_TAG);
		else
			timeout = 30;

		if (serverSet->NextMatches(PRIORITY_TAG, PROP_TYPE_INTEGER) == VARIANT_TRUE)
			priority = serverSet->NextLongWithName(PRIORITY_TAG);
		else
			priority = 0;

		if (serverSet->NextMatches(SECURE_TAG, PROP_TYPE_INTEGER) == VARIANT_TRUE)
			secure = serverSet->NextLongWithName(SECURE_TAG);
		else
			secure = 0;

		if (serverSet->NextMatches(PORT_NUMBER_TAG, PROP_TYPE_INTEGER) == VARIANT_TRUE)
			portnumber = serverSet->NextLongWithName(PORT_NUMBER_TAG);
		else
			portnumber = 80;

		if (serverSet->NextMatches(USER_NAME_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
			username = serverSet->NextStringWithName(USER_NAME_TAG);
		else
			username = "";


		if (serverSet->NextMatches(PASSWORD_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
		{
			// get the password
			// it will be encrypted="TRUE".  for backward compatibility, the
			// missing attribset will also be supported.
			propPtr = serverSet->NextWithName(PASSWORD_TAG);
			attribSet = propPtr->GetAttribSet();
			if (attribSet == NULL)
			{
				//passwordNotEncrypted = TRUE;
				//password = propPtr->GetValueAsString();

        // if password is unencrypted, throw an error
        mLogger.LogThis(LOG_ERROR, "All passwords must be encrypted");
        return E_FAIL;
			}
			else
			{
				_variant_t vtValue = attribSet->GetAttrValue("encrypted");
				if ((0 == _wcsicmp(vtValue.bstrVal, L"TRUE")) ||
						(0 == _wcsicmp(vtValue.bstrVal, L"T")) ||
						(0 == _wcsicmp(vtValue.bstrVal, L"YES")) ||
						(0 == _wcsicmp(vtValue.bstrVal, L"Y")))
				{
					// ------------------------------------------------------
					// the password coming back here is encrypted password.  
					// we need to decrypt it.
					// base64 decode and decrypt the password property that is 
					// coming in to this function
					_bstr_t bstrEncryptedPassword = propPtr->GetValueAsString();
					std::string sPlainText((const char *)bstrEncryptedPassword);
					if (!Decrypt(sPlainText))
					{
						mLogger.LogThis (LOG_ERROR, 
														 "Failed to decrypt the password buffer") ;
						return E_FAIL;
					}
					password = sPlainText.c_str();
					// ------------------------------------------------------
				}
				else if ((0 == _wcsicmp(vtValue.bstrVal, L"FALSE")) ||
						(0 == _wcsicmp(vtValue.bstrVal, L"F")) ||
						(0 == _wcsicmp(vtValue.bstrVal, L"NO")) ||
						(0 == _wcsicmp(vtValue.bstrVal, L"N")))
				{
					//password = propPtr->GetValueAsString();

          // if password is unencrypted, throw an error
          mLogger.LogThis(LOG_ERROR, "All passwords must be encrypted");
          return E_FAIL;
				}
				else
				{
					MT_THROW_COM_ERROR("Invalid Password Attribute Value in servers.xml");
				}
			}
		}
		else
			password = "";

		if (serverSet->NextMatches(DTC_ENABLED_TAG, PROP_TYPE_INTEGER) == VARIANT_TRUE)
			DTCenabled = serverSet->NextLongWithName(DTC_ENABLED_TAG);
		else
			DTCenabled = 1;

		Add(servertype, servername, numretries, timeout, priority, secure,
				portnumber, username, password, DTCenabled, dbname, datasource, dbdriver, dbtype);

		serverSet = aPropSet->NextSetWithName(SERVER_TAG);
	}

	if (passwordNotEncrypted)
		mLogger.LogThis(LOG_DEBUG, "At least one password not encrypted in servers.xml file");

	return S_OK;
}

	
STDMETHODIMP CMTServerAccessDataSet::Initialize()
{
	if (mServerListLoaded)
		// the cache is already loaded
		return S_OK;

	// lock the server list
	AutoCriticalSection lock(&mLock);

	mServerAccessDataList.clear();

	// TODO: Add your implementation code here
	HRESULT hr = S_OK;
    VARIANT_BOOL flag;
	string aConfigDir;
	_bstr_t bstrServersXMLFile; 
	MTConfigLib::IMTConfigPropPtr propPtr;
	MTConfigLib::IMTConfigAttribSetPtr attribSet;
	const char* procName = "CMTServerAccessDataSet::Initialize";

	try
	{
        // initialize the _com_ptr_t ...
        MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

		// get the config dir...
		if(GetMTConfigDir(aConfigDir)) 
		{
			// 
			bstrServersXMLFile = aConfigDir.c_str();
			bstrServersXMLFile += SERVER_ACCESS_CONFIG_PATH;
			bstrServersXMLFile += DIR_SEP;
			bstrServersXMLFile += SERVERS_XML_FILE;
		}
		else 
		{
			mLogger.LogThis(LOG_ERROR, "Failed to find configuration directory.");
			return Error("Failed to find configuration directory");
		}
    
	    // read the server set
		mLogger.LogVarArgs(LOG_DEBUG, "Reading configuration from <%s>", (const char*) bstrServersXMLFile);
	    MTConfigLib::IMTConfigPropSetPtr aPropSet = 
		  config->ReadConfiguration(bstrServersXMLFile, &flag) ;


			hr = Initialize(aPropSet);

			//Read Servers.xml from extensions
			RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
			aRCD->Init();
			RCDLib::IMTRcdFileListPtr aFileList = aRCD->RunQuery("config\\serveraccess\\servers.xml",VARIANT_TRUE);
			SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
			hr = it.Init(aFileList);
			if (FAILED(hr)) MT_THROW_COM_ERROR(hr);
			while (TRUE)
			{
				_variant_t aVariant= it.GetNext();
				_bstr_t afile = aVariant;
				if(afile.length() == 0) break;
				mLogger.LogVarArgs(LOG_DEBUG, "Reading configuration from <%s>", (const char*) afile);
				IMTConfigPropSetPtr aXmlFile = config->ReadConfiguration(afile,&flag);
				hr = Initialize(aXmlFile);
				if FAILED(hr)
				{
				  mLogger.LogVarArgs(LOG_ERROR, "Failed reading configuration from <%s>", (const char*) afile);
				  MT_THROW_COM_ERROR(hr);
				}
			}
			
	
	}
	catch (_com_error& e)
	{
		return (ReturnComError(e));
	}

	mServerListLoaded = TRUE;
	return hr;
}

HRESULT CMTServerAccessDataSet::Add(BSTR ServerType, 
																		BSTR ServerName,
																		long NumRetries, 
																		long Timeout, 
																		long Priority, 
																		long Secure,
																		long PortNumber,
																		BSTR UserName,
																		BSTR Password,
																		long DTCenabled,
																		BSTR dbname,
																		BSTR datasource,
																		BSTR dbdriver,
																		BSTR dbtype)
{
  try
  {
    _bstr_t sServerType = ServerType;
    _bstr_t sServerName =  ServerName;
    _bstr_t sUserName = UserName;
    _bstr_t sPassword = Password;
    _bstr_t dbName = dbname;
    _bstr_t dataSource = datasource;
    _bstr_t dbDriver = dbdriver;
    _bstr_t dbType = dbtype;
    
    MTSERVERACCESSLib::IMTServerAccessDataPtr p(__uuidof(MTSERVERACCESSLib::MTServerAccessData));
    
    p->ServerType = sServerType;
    p->ServerName = sServerName;
    p->NumRetries = NumRetries;
    p->Timeout = Timeout;
    p->Priority = Priority;
    p->Secure = Secure;
    p->PortNumber = PortNumber;
    p->UserName = sUserName;
    p->Password = sPassword;
    p->DTCenabled = DTCenabled;
    p->DatabaseName = dbName;
    p->DataSource = dataSource;
    p->DatabaseDriver = dbDriver;
    p->DatabaseType = dbType;
    
    _variant_t vPtr = p.GetInterfacePtr();
    
    mServerAccessDataList.push_back(vPtr);
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }

	return S_OK;
}

STDMETHODIMP CMTServerAccessDataSet::get_Count(long *pVal)
{
	(*pVal) = mServerAccessDataList.size();
  return S_OK;
}

STDMETHODIMP CMTServerAccessDataSet::get__NewEnum(LPUNKNOWN *pVal)
{
	 HRESULT hr = S_OK;

	typedef CComObject<CComEnum<IEnumVARIANT, 
	  &IID_IEnumVARIANT, VARIANT, _Copy<VARIANT> > > enumvar;

	enumvar* pEnumVar = new enumvar;
	ASSERT (pEnumVar);
	int size = mServerAccessDataList.size();

	// Note: end pointer has to be one past the end of the list
	if (size == 0)
	{
		hr = pEnumVar->Init(NULL,
							NULL, 
							NULL, 
							AtlFlagCopy);
	}
	else
	{
		hr = pEnumVar->Init(&mServerAccessDataList[0], 
							&mServerAccessDataList[size - 1] + 1, 
							NULL, 
							AtlFlagCopy);
	}

	if (SUCCEEDED(hr))
		hr = pEnumVar->QueryInterface(IID_IEnumVARIANT, (void**)pVal);

	if (FAILED(hr))
		delete pEnumVar;

	return hr;
}

STDMETHODIMP CMTServerAccessDataSet::get_Item(long aIndex, VARIANT *pVal)
{
	if (!pVal)
		return E_POINTER;
  
	pVal->vt = VT_UNKNOWN;
	pVal->punkVal = NULL;

	if ((aIndex < 1) || (aIndex > (long)mServerAccessDataList.size()))
		return E_INVALIDARG;

	::VariantClear(pVal);
	::VariantCopy(pVal, &mServerAccessDataList.at(aIndex - 1));

  return S_OK;
}

STDMETHODIMP CMTServerAccessDataSet::FindAndReturnObject(BSTR ServerType, 
                                                         IMTServerAccessData **pVal)
{
  if (pVal == NULL)
    return E_POINTER;
  HRESULT hr = S_OK;
  *pVal = NULL;
  try
  {
		FindAndReturnObjectInternal(ServerType, pVal);
		if(!*pVal) 
		{
			_bstr_t bstrServerType(ServerType);
			char buf[256];
			sprintf(buf, "Server set '%s' not found", (char*)bstrServerType);
      hr = Error(buf);
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  
  return hr;
}

STDMETHODIMP CMTServerAccessDataSet::FindAndReturnObjectIfExists(BSTR ServerType, 
                                                         IMTServerAccessData **pVal)
{
  if (pVal == NULL)
    return E_POINTER;
  HRESULT hr = S_OK;
  *pVal = NULL;
  try
  {
		FindAndReturnObjectInternal(ServerType, pVal);
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  
  return hr;
}

void CMTServerAccessDataSet::FindAndReturnObjectInternal(BSTR ServerType, 
																												 IMTServerAccessData **pVal)
{
	*pVal = NULL;
	ServerAccessDataList::const_iterator itr = mServerAccessDataList.begin();
	_bstr_t bstrServerType(ServerType);
	while (itr != mServerAccessDataList.end())
	{
		MTSERVERACCESSLib::IMTServerAccessDataPtr p = *itr;
		ASSERT(p != NULL);
		if (stricmp(p->ServerType, (char*)bstrServerType) == 0)
		{
			(*pVal) = reinterpret_cast<IMTServerAccessData*>(p.Detach());
			break;
		}
		itr++;
	}
}

// 
//
//
BOOL 
CMTServerAccessDataSet::Decrypt(std::string& arStr)
{
	// step 1: obtain the handle to the current thread
	HANDLE hThread = ::GetCurrentThread();
	BOOL bError = TRUE;
	HANDLE hToken = INVALID_HANDLE_VALUE;
	
	do {
		
		// step 2: get the thread token
		bError = ::OpenThreadToken(hThread,TOKEN_QUERY | TOKEN_IMPERSONATE,TRUE,&hToken);
		if(!bError) {
			DWORD Error = ::GetLastError();
			// I think we get this error because we don't always have a security access token.  For instance,
			// we get this error when running the pipeline or usageservermaintainance.  Probably
			// the only place where we have an access token is when running under the context of IIS.
			if(Error != ERROR_NO_TOKEN) {
				mLogger.LogVarArgs(LOG_ERROR,"failed to open thread token: Error %d",Error);
				break;
			}
		}
		
		// step 3: revert to self
		if(hToken != INVALID_HANDLE_VALUE) {
			if(!::RevertToSelf()) {
				mLogger.LogThis(LOG_WARNING,"Failed to revert to self.");
			}
		}
		
		// step 4: attempt decryption
		
		if(!mbCryptoInitialized) {
			// do the crypto stuff here
			int result = mCrypto.CreateKeys("mt_dbaccess", TRUE, "dbaccess");
			if (result == 0) {
				result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_DatabasePassword, "mt_dbaccess", TRUE, "dbaccess");
				if(result == 0) {
					mbCryptoInitialized = true;
					bError = TRUE;
				}
				else {
					mLogger.LogThis(LOG_ERROR,"failed in mCrypto::Initialize");
					const char * errStr = mCrypto.GetCryptoApiErrorString();
					mLogger.LogThis(LOG_ERROR, errStr);
					bError = FALSE;
				}
			}
			else {
				mLogger.LogThis(LOG_ERROR,"Failed in CMTCryptoAPI::CreateKeys");
				const char * errStr = mCrypto.GetCryptoApiErrorString();
				mLogger.LogThis(LOG_ERROR, errStr);
				bError = FALSE;
			}
		}
		if(mbCryptoInitialized) {
			bError = mCrypto.Decrypt(arStr) == 0 ? TRUE : FALSE;
			if (!bError)
			{
				const char * errStr = mCrypto.GetCryptoApiErrorString();
				mLogger.LogThis(LOG_ERROR, errStr);
			}
		}
	} while(false);
	
	// step 5: revert token and clean up
	if(hThread != INVALID_HANDLE_VALUE && hToken != INVALID_HANDLE_VALUE) {
		if(!SetThreadToken(NULL,hToken)) {
			mLogger.LogVarArgs(LOG_ERROR,"SetThreadToken call failed; Error %d",::GetLastError());
		}
		::CloseHandle(hToken);
	}
	return bError;
}
