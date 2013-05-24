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
 *
 */

#include <metra.h>
#include <mtcom.h>
#include <installutil.h>
#include <DBInstall.h>
#include <autoinstance.h>
#include <Description.h>

extern MTAutoInstance<InstallLogger> g_Logger;

////////////////////////////////////////////////////////////////////////////////
// Function name	: InstallDB
// Description	    : 
// Return type		: LONG InstCallConvention 
// Argument         : LPSTR adbPassword
// Argument         : LPSTR aDBServer
// Argument         : LPSTR aDBLoc
// Argument         : LPTSTR aDBTransactionLogLoc
// Argument         : LONG aDBSizeInMegs
// Argument         : LONG aLogSizeInMegs
////////////////////////////////////////////////////////////////////////////////

LONG InstCallConvention InstallDB(LPSTR adbPassword,
																	LPSTR aDBServer,
																	LPSTR aDBLoc,
																	LPTSTR aDBTransactionLogLoc,
																	LONG aDBSizeInMegs,
																	LONG aLogSizeInMegs,
																	LPCSTR szDbName,
																	LPCSTR szDbUserName,
																	LPCSTR szDbPassword
																	)
{
  ASSERT(adbPassword != NULL && aDBServer != NULL && aDBLoc != NULL && aDBSizeInMegs > 0 && aLogSizeInMegs > 0);
  CDBInstall_SQLServer aDbInstall(0);
  LONG retval;

	string aDbBackupLoc,aDbLogBackupLoc;

  string aDbDatFile = aDBLoc;
	aDbDatFile += DIR_SEP;
	aDbDatFile += szDbName;
  aDbDatFile += _T("_nmdbdata.dat");
	aDbBackupLoc = aDbDatFile;
	aDbBackupLoc += _T(".backup");

  string aDbLogFile = aDBTransactionLogLoc;
	aDbLogFile += DIR_SEP;
	aDbLogFile += szDbName;
  aDbLogFile += _T("_NMDBLog.dat");
	aDbLogBackupLoc = aDbLogFile;
	aDbLogBackupLoc += _T(".backup");

	string aDeviceName,aLogDeviceName;
	aDeviceName = szDbName;
	aDeviceName += "_NMDBData";
	aLogDeviceName = szDbName;
	aLogDeviceName += "_NMDBLog";


  retval = aDbInstall.Initialize("SA",
      adbPassword,
      szDbName,
      aDBServer,
      szDbUserName,
      szDbPassword,
      aDeviceName.c_str(),
      aDbDatFile.c_str(),
      aDBSizeInMegs,        // size of database in megabytes
      aLogDeviceName.c_str(),
      aDbLogFile.c_str(),
			aLogSizeInMegs,
      aDbBackupLoc.c_str(),
      aDbLogBackupLoc.c_str(),
			1000);
  if(retval) {
    if(aDbInstall.Install() &&
      aDbInstall.ChangeDBOwner() &&
      aDbInstall.InstallDBObjects())
      retval = TRUE;
		else
			retval = FALSE;
  }

  if(!retval) {
      retval = aDbInstall.GetLastErrorCode();
  }
  return retval;
}


////////////////////////////////////////////////////////////////////////////////
// Function name	: UninstallDB
// Description	    : 
// Return type		: BOOL InstCallConvention 
// Argument         : LPSTR adbPassword
// Argument         : LPSTR aDBServer
////////////////////////////////////////////////////////////////////////////////

BOOL InstCallConvention UninstallDB(LPSTR adbPassword,
																		LPSTR aDBServer,
																		LPCSTR szDatabaseName,
																		LPCSTR szUserName,
																		LPCSTR szPassword)
{
	ASSERT(adbPassword);
	if(!adbPassword) return FALSE;

	CDBInstall_SQLServer aDbInstall(0);
	LONG retval;

	string szDbDeviceName,szDbLogDeviceName;
	szDbDeviceName = szDatabaseName;
	szDbDeviceName += "_NMDBData";
	szDbLogDeviceName = szDatabaseName;
	szDbLogDeviceName += "_NMDBLog";


	retval = aDbInstall.Initialize("SA",
      adbPassword,
      szDatabaseName,
      aDBServer,
      szUserName,
      szPassword,
      szDbDeviceName.c_str(),
      "",				// ignored
      0,        // ignored
      szDbLogDeviceName.c_str(),
      "",				// ignored
			0,				// ignored
      "C:\\backup\\NMDBData.dat",
      "C:\\backup\\NMDBLog.dat",
	  1000);

	if(retval) {
		return aDbInstall.Uninstall();
	}
	return FALSE;
}


////////////////////////////////////////////////////////////////////////////////
// Function name	: InstallExtensionTables
// Description	    : 
// Return type		: BOOL InstCallConvention 
// Argument         : LPSTR ConfigDir
// Argument         : LPSTR InstallFile
////////////////////////////////////////////////////////////////////////////////

BOOL InstCallConvention InstallExtensionTables(LPSTR ConfigDir,LPSTR InstallFile)
{
	BOOL bRetVal = FALSE;
	ComInitialize aComInit;
	try {
		// step 1: create an CDBInstall_Extension class

		CDBInstall_Extension aExtension(ConfigDir,InstallFile,"");

		// step 2: Initialize
		bRetVal = aExtension.Initialize();
		if(bRetVal) {
			bRetVal = aExtension.Install();
		}

	}
	catch(...) {
		// want to catch any errors because we are going back up to installshield
		bRetVal = FALSE;
	}
	return bRetVal;
}

////////////////////////////////////////////////////////////////////////////////
// Function name	: UnInstallExtensionTables
// Description	    : 
// Return type		: BOOL InstCallConvention 
// Argument         : LPSTR ConfigDir
// Argument         : LPSTR UninstallFile
////////////////////////////////////////////////////////////////////////////////

BOOL InstCallConvention UnInstallExtensionTables(LPSTR ConfigDir,LPSTR UninstallFile)
{
	BOOL bRetVal = FALSE;
	ComInitialize aComInit;
	try {
		// step 1: create an CDBInstall_Extension class

		CDBInstall_Extension aExtension(ConfigDir,"",UninstallFile);

		// step 2: Initialize
		bRetVal = aExtension.Initialize();
		if(bRetVal) {
			bRetVal = aExtension.Uninstall();
		}

	}
	catch(...) {
		// want to catch any errors because we are going back up to installshield
 		bRetVal = FALSE;
	}
	return bRetVal;
}


////////////////////////////////////////////////////////////////////////////////
// Function name	: InstallOracle
// Description	    : 
// Return type		: BOOL InstCallConvention 
// Argument         : LPSTR pPassWord
// Argument         : LPSTR pDataSource
// Argument         : LPSTR pLocation
// Argument         : LONG aSize
////////////////////////////////////////////////////////////////////////////////

BOOL InstCallConvention InstallOracle(LPSTR pPassWord,
																			LPSTR pDataSource,
																			LPSTR pLocation,
																			LONG aSize,
																			LPCSTR szDatabaseName,
																			LPCSTR szUsername,
																			LPCSTR szPassword)
{
	BOOL bRetVal = FALSE;
	ComInitialize aComInit;

	try {
		CDBInstall_Oracle aOracleInstall;

		bRetVal = aOracleInstall.Initialize("system",
			pPassWord,			// password
			szDatabaseName,			// dbname
			pDataSource,		// datasource name
			szUsername,				// dbuser
			szPassword,				// userpassword
			pLocation,			// datadevice location
			aSize,					// datadevice size
			1000						// timeoutvalue
			);

		if(bRetVal) {
			 if(aOracleInstall.Install() &&
				 aOracleInstall.InstallDBObjects()) {
				bRetVal = TRUE;
			 }
			 else {
				bRetVal = FALSE;
			 }
		}
	}
	catch(...) {
		// want to catch any errors because we are going back up to installshield
		bRetVal = FALSE;
	}

	return bRetVal;
}


BOOL InstCallConvention UninstallOracle(LPSTR pPassWord,
																				LPSTR pDataSource,
																				LPCSTR szDatabaseName,
																				LPCSTR szUserName,
																				LPCSTR szPassword)
{
	BOOL bRetVal = FALSE;
	ComInitialize aComInit;

	try {
		CDBInstall_Oracle aOracleInstall;

		bRetVal = aOracleInstall.Initialize("system",
			pPassWord,			// password
			szDatabaseName,			// dbname
			pDataSource,		// datasource name
			szUserName,				// dbuser
			szPassword,				// userpassword
			"",							// datadevice location
			0,							// datadevice size
			1000						// timeoutvalue
			);

		if(bRetVal) {
			bRetVal = aOracleInstall.Uninstall();
		}
	}
	catch(...) {
		// want to catch any errors because we are going back up to installshield
		bRetVal = FALSE;
	}

	return bRetVal;
}



BOOL InstCallConvention InstallDescriptionTable()
{
	BOOL bRetVal = FALSE;
	static const char* pFuncName = "InstallDescriptionTable:";
	ComInitialize aComInit;

	Description desc;
	if(desc.Init()) {
		if(desc.LoadDescription()) {
			bRetVal  = TRUE;
		}
		else {
			g_Logger->LogVarArgs(LOG_ERROR,"%s failed LoadDescription.",pFuncName);
		}
	}
	else {
		g_Logger->LogVarArgs(LOG_ERROR,"%s failed Init.",pFuncName);
	}
	return bRetVal;
}

