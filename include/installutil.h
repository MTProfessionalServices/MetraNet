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
 * $Date$
 * $Author$
 * $Revision$
 */


#ifndef __INSTALL_UTIL_H_
#define __INSTALL_UTIL_H_

#define WIN32_LEAN_AND_MEAN
#include <comdef.h>
#include "tchar.h"

// ADSI & IIS stuff
#include <errobj.h>
#include <mtcom.h>
#include <NTLogger.h>

//#define InstCallConvention _stdcall
#define InstCallConvention WINAPI
#define ExportDefinition __declspec(dllexport)
//#define ExportDefinition
extern "C" {

// list of exported function prototypes
// 
// the format for an Installshield extension function is
// LONG  APIENTRY  YourFunction (HWND hwnd, LPLONG lpIValue, LPSTR lpszValue);
//
// 
// Functions in this file will return TRUE for success, FALSE for failure.  They
// may also return higher values.



ExportDefinition LONG InstCallConvention AddSystemEnvironmentPath(LPSTR lpszValue);
ExportDefinition LONG InstCallConvention AddAccount(LPSTR,LPSTR,LPSTR,LPSTR,LONG, LPSTR);
ExportDefinition LONG InstCallConvention AddAccountWithCycle(LPSTR,LPSTR,LPSTR,LPSTR,LONG,LPSTR pUCT);
ExportDefinition LONG InstCallConvention AddAccountMappings(LPSTR,LPSTR,LONG);

// virtual directory support
ExportDefinition LONG InstCallConvention CreateIISVdir(LPSTR lpszVdir,LPSTR lpszPath);
ExportDefinition LONG InstCallConvention SetIISVdirPerms(LPSTR lpszVdir,LONG pSecParams);
ExportDefinition LONG InstCallConvention DeleteIISVdir(LPSTR lpszVdir);
ExportDefinition LONG InstCallConvention SetIISvDirBasicAuth(LPSTR lpszVdir);


ExportDefinition LONG InstCallConvention RegisterComServer(LPSTR lpszValue,BOOL);
ExportDefinition LONG InstCallConvention UnRegisterComServer(LPSTR lpszValue,BOOL);
ExportDefinition LONG InstCallConvention RegisterTypeLibrary(LPSTR szFile);
ExportDefinition LONG InstCallConvention UnregisterRegisterTypeLibrary(LPSTR szFile);


ExportDefinition LONG InstCallConvention ServiceStart(LPSTR lpszValue);
ExportDefinition LONG InstCallConvention ServiceStop(LPSTR lpszValue);
ExportDefinition LONG InstCallConvention GetListOfSQLServers(LPSTR lpszValue,DWORD len,LPLONG lpIValue);
ExportDefinition LONG InstCallConvention InstallDB(LPSTR adbPassword,LPSTR aDBServer,LPSTR aDBLoc,LPTSTR aDBTransactionLogLoc,
                                     LONG aDBSizeInMegs,LONG aLogSizeInMegs,LPCSTR,LPCSTR,LPCSTR);
ExportDefinition BOOL InstCallConvention  InstallExtensionTables(LPSTR ConfigDir,LPSTR InstallFile);
ExportDefinition BOOL InstCallConvention  UnInstallExtensionTables(LPSTR ConfigDir,LPSTR UninstallFile);
ExportDefinition BOOL InstCallConvention  InstallDescriptionTable();

ExportDefinition BOOL InstCallConvention UninstallDB(LPSTR adbPassword,LPSTR aDBServer,LPCSTR,LPCSTR,LPCSTR);
ExportDefinition LONG InstCallConvention CreateBuckets();
ExportDefinition BOOL InstCallConvention ConvertEnumData();

// Logging
ExportDefinition BOOL InstCallConvention LogInstallMsg(LPSTR Message,DWORD level);
ExportDefinition BOOL InstCallConvention ModifyLogFile(LPSTR,LPSTR,int);


ExportDefinition BOOL InstCallConvention InstallService(LPSTR pService,LPSTR pServiceName,LPSTR pBinaryFile,LPSTR pDependencyList); 
ExportDefinition BOOL InstCallConvention RemoveService(LPSTR);

// ownerlist support
ExportDefinition BOOL InstCallConvention GetMTOwnerID(LPLONG pValue);
ExportDefinition BOOL InstCallConvention GetUserOwnerID(LPLONG pValue);

ExportDefinition BOOL InstCallConvention InitializeOwnerList(LONG aOwner,LPCSTR aConfigDir);
ExportDefinition BOOL InstCallConvention GetNextOwnerItem(LPSTR aItem);
ExportDefinition void InstCallConvention CloseOwnerList();
ExportDefinition void InstCallConvention GetNumberOfOwnerItems(LPLONG pValue);

ExportDefinition BOOL InstCallConvention GetReferenceDataPath(LPSTR aPath);

// repository support
ExportDefinition BOOL InstCallConvention GetConfigSetVersion(LPCSTR,LPCSTR,LPCSTR,LPCSTR,LPCSTR,LPCSTR,LPSTR);

ExportDefinition BOOL InstCallConvention CheckOut(LPCSTR,LPCSTR,LPCSTR,LPCSTR,LPCSTR,LPCSTR,LONG,LPSTR);
ExportDefinition BOOL InstCallConvention CheckIn(LPCSTR,LPCSTR,LPCSTR,LPCSTR,LPCSTR,LPCSTR,LONG);
ExportDefinition BOOL InstCallConvention Deploy(LPCSTR,LPCSTR,LPCSTR,LPCSTR,LPCSTR,LPCSTR,LPCSTR,LONG);
ExportDefinition BOOL InstCallConvention RemoveDeployedConfigSet(LPCSTR,LPCSTR,LPCSTR,LPCSTR,const LONG,LPCSTR,LPCSTR);
ExportDefinition BOOL InstCallConvention RemoveConfigSetFromRep(LPCSTR,LPCSTR,LPCSTR,LPCSTR,const LONG,LPCSTR,LPCSTR);
ExportDefinition BOOL InstCallConvention RemoveAllDeployedConfigSetFiles(LPCSTR,LPCSTR,LPCSTR,const LONG,LPCSTR,LPCSTR);

ExportDefinition BOOL InstCallConvention CreateConfigSets(::IUnknown*,LPCSTR,LONG,LPCSTR,LPCSTR);
ExportDefinition BOOL InstCallConvention CreateConfigSet(LPCSTR,long,LPCSTR,LPCSTR);

// clean up support
ExportDefinition void InstCallConvention ReleaseResources();

// oracle DB support
ExportDefinition BOOL InstCallConvention InstallOracle(LPSTR,LPSTR,LPSTR,LONG,LPCSTR,LPCSTR,LPCSTR);
ExportDefinition BOOL InstCallConvention UninstallOracle(LPSTR,LPSTR,LPCSTR,LPCSTR,LPCSTR);

// checksum support
ExportDefinition BOOL InstCallConvention PerformChecksumOnFiles(LPSTR,LPSTR);
ExportDefinition BOOL InstCallConvention ComputeChecksumOnFile(LPCSTR,LPSTR,LONG);

// UNIX time
ExportDefinition DWORD InstCallConvention GetCurrentUnixTime();

// encrypt property: only for V1.3 security fixes.  This should be removed after W2K integration
BOOL InstCallConvention EncryptString(LPCSTR,LPSTR,ULONG);
BOOL InstCallConvention InstallDbaccessKeys();
BOOL InstCallConvention DecryptString(LPCSTR,LPSTR,ULONG);
}




// FACILITY_WIN32
#define GET_REAL_RESULT(x) x = (HRESULT_FACILITY(x) == FACILITY_WIN32) ? x = HRESULT_CODE(x) : x; 

// registry stuff
#define GLOBAL_ENVIRON "SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment"
#define REG_PATH_NAME "Path"
#define MAX_ENV 1024


// helper class and methods
class InstallLogger : public NTLogger {
public:
  virtual ~InstallLogger();
  BOOL Init();
protected:
	ComInitialize mComInit;
};



#endif // __INSTALL_UTIL_H_
