/**************************************************************************
 * @doc
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Carl Shimer
 *
 * This module provides a number of exported function for use by 
 * InstallShield
 *
 * $Date: 9/11/2002 9:31:38 AM$
 * $Author: Alon Becker$
 * $Revision: 24$
 */

// see installutil.h for list of exported functions

// need the full windows.h for WM_SETTINGCHANGE and SMTO_ABORTIFHUNG
#include <mtcom.h>
#include <windows.h>
#include <metralite.h>

#include <installutil.h>
#include <errobj.h>
#include <scmconfig.h>
#include <autoinstance.h>
#include <SetIterate.h>

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTConfigLib.tlb>
#include <mtcryptoapi.h>
#include <vector>
#include <string>

#include <iads.h>
#include <adshlp.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

// function called when DLL is loaded

BOOL WINAPI DllMain(HINSTANCE hDLL, DWORD dwReason, LPVOID lpReserved)
{
	return TRUE;
}


extern MTAutoInstance<InstallLogger> g_Logger;


ExportDefinition void InstCallConvention ReleaseResources()
{
	g_Logger.Destroy();

}

ExportDefinition DWORD InstCallConvention GetCurrentUnixTime()
{
	time_t ltime;
	time(&ltime);
  // COM 32BIT TIME_T
	return (DWORD) ltime;
}

//////////////////////////////////////////////////////////////////
// RegisterComServer
// Code from Microsoft
//////////////////////////////////////////////////////////////////

LONG InstCallConvention RegisterComServer(LPSTR lpszValue,BOOL bNoLogging)
{
  ComInitialize aInit;

	HANDLE hUnused = NULL;
  HINSTANCE hLib = ::LoadLibraryEx(lpszValue,hUnused,LOAD_WITH_ALTERED_SEARCH_PATH);
	HRESULT hr;
	FARPROC lpDllEntryPoint;

	if (hLib < (HINSTANCE)HINSTANCE_ERROR)
	{
    hr = FALSE;
		DWORD aError = ::GetLastError();
    if(!bNoLogging) {
      g_Logger->LogVarArgs(LOG_FATAL,"Failed to load %s; Error %d",lpszValue,aError);
		}
	}
	else {

		// Find the entry point.
		(FARPROC&)lpDllEntryPoint = GetProcAddress(hLib,_T("DllRegisterServer"));
    if (lpDllEntryPoint != NULL) {
			hr = (*lpDllEntryPoint)();
      if(SUCCEEDED(hr)) {
        if(!bNoLogging)
          g_Logger->LogVarArgs(LOG_INFO,"Successfully Registered %s",lpszValue);
      }
      else {
        if(!bNoLogging)
          g_Logger->LogVarArgs(LOG_FATAL,"Failed to Register %s, error %X",lpszValue,hr);
      }
    }
    else {
			// hr = FALSE;
      // if they don't have a DllRegisterServer entry point,
      // it isn't a COM object.  Just ignore the error.
      hr = S_OK;
    }

		if(hr == S_OK) hr = TRUE;
		else hr = FALSE;
	}
  FreeLibrary(hLib);
	return hr;
}

//////////////////////////////////////////////////////////////////
// RegisterComServer
// Code from Microsoft
//////////////////////////////////////////////////////////////////

LONG InstCallConvention UnRegisterComServer(LPSTR lpszValue,BOOL bNoLogging)
{
  ComInitialize aInit;


  HINSTANCE hLib = LoadLibrary(lpszValue);
	HRESULT hr;
	FARPROC lpDllEntryPoint;

	if (hLib < (HINSTANCE)HINSTANCE_ERROR)
	{
    hr = FALSE;
    if(!bNoLogging)
      g_Logger->LogVarArgs(LOG_FATAL,"Failed to load %s",lpszValue);
	}
	else {

		// Find the entry point.
		(FARPROC&)lpDllEntryPoint = GetProcAddress(hLib,_T("DllUnregisterServer"));
    if (lpDllEntryPoint != NULL) {
			hr = (*lpDllEntryPoint)();
      if(SUCCEEDED(hr)) {
        if(!bNoLogging)
          g_Logger->LogVarArgs(LOG_INFO,"Successfully unRegistered %s",lpszValue);
      }
      else {
        if(!bNoLogging)
          g_Logger->LogVarArgs(LOG_FATAL,"Failed to unRegister %s, error %X",lpszValue,hr);
      }
    }
    else {
			// hr = FALSE;
      // if they don't have a DllUnregisterServer entry point,
      // it isn't a COM object.  Just ignore the error.
      hr = S_OK;
    }

		if(hr == S_OK) hr = TRUE;
		else hr = FALSE;
	}
  FreeLibrary(hLib);
	return hr;
}

//////////////////////////////////////////////////////////////////
// RegisterTypeLibrary
//////////////////////////////////////////////////////////////////

LONG InstCallConvention RegisterTypeLibrary(LPSTR szFile)
{
	ASSERT(szFile);
	if(!szFile) return FALSE;
	
	HRESULT hr;
	::ITypeLib* pTypeLib;

	try {
		_bstr_t aStr(szFile);
		hr = LoadTypeLib(aStr,&pTypeLib);
		if(SUCCEEDED(hr)) {
			
			wstring wFileName;
			ASCIIToWide(wFileName, szFile);

			hr = ::RegisterTypeLib(pTypeLib,const_cast<wchar_t*>((const wchar_t*)wFileName.c_str()),L"");
			pTypeLib->Release();
		}
	}
	catch(...) {
		hr = E_FAIL;
	}

	return SUCCEEDED(hr) ? TRUE : hr;
}

//////////////////////////////////////////////////////////////////
// UnregisterRegisterTypeLibrary
//////////////////////////////////////////////////////////////////

LONG InstCallConvention UnregisterRegisterTypeLibrary(LPSTR szFile)
{
	ASSERT(szFile);
	if(!szFile) return FALSE;

	HRESULT hr = S_OK;
	::ITypeLib* pTypeLib;

	try {
		_bstr_t aStr(szFile);
		hr = LoadTypeLib(aStr,&pTypeLib);
		
		if(SUCCEEDED(hr)) {
			TLIBATTR* aTibAttr,aCopy;
				
			if(SUCCEEDED(pTypeLib->GetLibAttr(&aTibAttr))) {

				memcpy(&aCopy,aTibAttr,sizeof(TLIBATTR));
				pTypeLib->ReleaseTLibAttr(aTibAttr);
				pTypeLib->Release();

				hr = ::UnRegisterTypeLib(aCopy.guid,
					aCopy.wMajorVerNum,
					aCopy.wMinorVerNum,
					aCopy.lcid,
					aCopy.syskind);

			}
			else {
				pTypeLib->Release();
			}
		}
	}
	catch(...) {
		hr = E_FAIL;
	}

	return SUCCEEDED(hr) ? TRUE : FALSE;
}



//////////////////////////////////////////////////////////////////
// StartService
//////////////////////////////////////////////////////////////////

LONG  InstCallConvention ServiceStart(LPSTR lpszValue)
{
	MTSCMConfig aConfigSCM(lpszValue);
	long retval;

	retval = aConfigSCM.Start();
	if(!retval) retval = aConfigSCM.GetLastErrorCode();

	return retval;
}

//////////////////////////////////////////////////////////////////
// StopService
//////////////////////////////////////////////////////////////////


LONG InstCallConvention ServiceStop(LPSTR lpszValue)
{
	long retval;
	MTSCMConfig aConfigSCM(lpszValue);

	retval = aConfigSCM.Stop();
	if(!retval) retval = aConfigSCM.GetLastErrorCode();

  return retval;
}

//////////////////////////////////////////////////////////////////
//AddSystemEnvironmentPath
//
// Sets a directory in the system path (the path used by all users of
// the machine).  It then broadcasts a WM_SETTINGSCHANGE message to all
// windows so that the environment change will take affect.  While explorer 
// and other system level components process this message, most apps will ignore it.
//////////////////////////////////////////////////////////////////



LONG InstCallConvention AddSystemEnvironmentPath(LPSTR lpszValue)
{
  DWORD retval = TRUE;
  TCHAR path[MAX_ENV];
  DWORD unused;
  DWORD type = REG_SZ;
  DWORD size = MAX_ENV;

  HKEY aKey;

  do {
    if(RegOpenKeyEx (HKEY_LOCAL_MACHINE, GLOBAL_ENVIRON, 0, KEY_ALL_ACCESS, &aKey) == 
        ERROR_SUCCESS) {

      if(RegQueryValueEx(aKey,REG_PATH_NAME,NULL,&type,(_TUCHAR*)&path[0],&size) == ERROR_SUCCESS) {
        if((_tcslen(path) + _tcslen(lpszValue)) > MAX_ENV) {
          retval = FALSE; 
          break;
        }

        if(_tcsstr(path,lpszValue) != NULL) break;
      
        // step 1: append the new path entry and write the registry value
        _tcscat(path,lpszValue);
        // step 2: write back to registry
        if(RegSetValueEx(aKey,REG_PATH_NAME,0,REG_EXPAND_SZ ,(_TUCHAR*)&path[0],_tcslen(path)) == ERROR_SUCCESS) {

            SendMessageTimeout(HWND_BROADCAST,
                WM_SETTINGCHANGE,
                0,
                (LPARAM) "Environment",
                SMTO_ABORTIFHUNG,5000,
                &unused);
            retval = TRUE;
        }
      }
    }
  } while(false);

  RegCloseKey(aKey);

  return retval;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: InstallService
// Description	    : 
// Return type		: BOOL 
// Argument         : LPSTR pService
// Argument         : LPSTR pServiceName
// Argument         : LPSTR pBinaryFile
// Argument         : LPSTR pDependencyList
// Argument         : LONG nNumDependencies
//
// Install a service.
/////////////////////////////////////////////////////////////////////////////

BOOL InstCallConvention InstallService(LPSTR pService,LPSTR pServiceName,LPSTR pBinaryFile,LPSTR pDependencyList)
{
	ASSERT(pService && pServiceName && pBinaryFile && pDependencyList);
	if(!(pService && pServiceName && pBinaryFile && pDependencyList)) return FALSE;

	MTSCMConfig aConfigSCM(pService);

	unsigned int len = strlen(pDependencyList);
	char * aStringWithNulls = new char [len+1];
	for(unsigned int i=0;i<len;i++) {
		aStringWithNulls[i] = (pDependencyList[i] != ' ') ? pDependencyList[i] : '\0';
	}
	aStringWithNulls[len] = '\0';
	

	BOOL bRetVal = aConfigSCM.InstallService(pServiceName,pBinaryFile,aStringWithNulls);
	delete [] aStringWithNulls;
	if(!bRetVal) {
		DWORD aError = ::GetLastError();
		g_Logger->LogVarArgs(LOG_FATAL,"InstallService: Failed to create service [%s]: error %d",pServiceName,aError);
	}
	return bRetVal;
}

BOOL InstCallConvention RemoveService(LPSTR pService)
{
	ASSERT(pService);
	if(!pService) return FALSE;
	
	MTSCMConfig aConfigSCM(pService);
	return aConfigSCM.DeleteService();
}

_COM_SMARTPTR_TYPEDEF(IADsContainer, __uuidof(IADsContainer));
_COM_SMARTPTR_TYPEDEF(IADsUser, __uuidof(IADsUser));

BOOL InstCallConvention InstallDbaccessKeys()
{
	ComInitialize aInit;

	IADsContainerPtr container;

	// determine computer name
	wstring adsipath(L"WinNT://");

	wchar_t buff[MAX_PATH];
	unsigned long aLen = MAX_PATH;
	GetComputerNameW(buff, &aLen);
	adsipath.append(buff);

	HRESULT hr = ADsGetObject(adsipath.c_str(),
														IID_IADsContainer,
														(void**) &container);
	if (FAILED(hr))
		return FALSE;

	string iusr;
	string iwam;

	VARIANT var;
	LPWSTR pszArray[] = { L"User" };
	DWORD dwNumber = sizeof(pszArray) / sizeof(LPWSTR);
	hr = ADsBuildVarArrayStr(pszArray, dwNumber, &var);
	if (FAILED(hr))
		return FALSE;

	hr = container->put_Filter(var);
	if (FAILED(hr))
		return FALSE;

	VariantClear(&var);

	IADsUserPtr user;

	SetIterator<IADsContainerPtr, IADsUserPtr> it;
	hr = it.Init(container);
	if (FAILED(hr))
		return FALSE;

	while (TRUE)
	{
		IADsUserPtr user = it.GetNext();
		if (user == NULL)
			break;

		BSTR rawname;
		hr = user->get_Name(&rawname);
		if (FAILED(hr))
			return FALSE;

		_bstr_t name(rawname, false);
		if (0 == strncmp(name, "IUSR_", 5))
		{
			// we found IUSR
			iusr = name;
		}
		else if (0 == strncmp(name, "IWAM_", 5))
		{
			// we found IWAM
			iwam = name;
		}

		if (iusr.length() > 0 && iwam.length() > 0)
			break;
	}

	if (iusr.length() <= 0 || iwam.length() <= 0)
		return FALSE;

	//printf("iusr = %s\n", iusr.c_str());
	//printf("iwam = %s\n", iwam.c_str());

	CMTCryptoAPI aCrypto;
	int result = aCrypto.CreateKeys("mt_dbaccess", TRUE, "dbaccess");
	if (result == 0) {
		result = aCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_DatabasePassword, "mt_dbaccess", TRUE, "dbaccess");
		if(result == 0) {
		
			std::vector<std::string> aVec;

			aVec.push_back(iusr);
			aVec.push_back(iwam);

			if (aCrypto.GrantKeyAccessRights(aVec)) {
				return TRUE;
			}
		}
	}

	return FALSE;
}



BOOL InstCallConvention EncryptString(LPCSTR src,LPSTR dest,ULONG len)
{
	ComInitialize aInit;

	CMTCryptoAPI aCrypto;
	int result = aCrypto.CreateKeys("mt_dbaccess", TRUE, "dbaccess");
	if (result == 0) {
		result = aCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_DatabasePassword, "mt_dbaccess", TRUE, "dbaccess");
		if(result == 0) {
			// encrypt the string and stuff in the output buffer
			std::string aStr(src);
			if(aCrypto.Encrypt(aStr) == 0 && aStr.length() < len) {
				strncpy(dest,aStr.c_str(),aStr.length()+1);
				return TRUE;
			}
		}
	}
	return FALSE;
}

BOOL InstCallConvention DecryptString(LPCSTR src,LPSTR dest,ULONG len)
{
#ifdef DEBUG
	ASSERT(src && dest);
	if(!(src && dest)) return FALSE;

	ComInitialize aInit;

		CMTCryptoAPI aCrypto;
		int result = aCrypto.CreateKeys("mt_dbaccess", TRUE, "dbaccess");
		if (result == 0) {
			  result = aCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_DatabasePassword, "mt_dbaccess", TRUE, "dbaccess");
				if(result != 0) {
					return FALSE;
				}
			}
			else {
				return FALSE;
			}
		string arStr = src;
		if(aCrypto.Decrypt(arStr) == 0) {
			if(arStr.length() < len) {
				strcpy(dest,arStr.c_str());
			}
			else {
				strncpy(dest,arStr.c_str(),len);
			}
			return TRUE;
		}
		else {
			return FALSE;
		}
#else
return FALSE;
#endif
}
