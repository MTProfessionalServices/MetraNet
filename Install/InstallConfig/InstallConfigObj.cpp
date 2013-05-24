// InstallConfigObj.cpp : Implementation of CInstallConfigObj
#include "StdAfx.h"

#include <DBInstall.h>
#include <installutil.h>
#include <Description.h>
#include <scmconfig.h>

#include "InstallConfig.h"
#include "InstallConfigObj.h"
#include <comdef.h>
#include <winerror.h>




/////////////////////////////////////////////////////////////////////////////
// CInstallConfigObj

CInstallConfigObj::CInstallConfigObj()
{
	pDBInstall_SQL		= NULL;
	pDBInstall_Oracle	= NULL;
}



CInstallConfigObj::~CInstallConfigObj()
{
	if (pDBInstall_SQL != NULL)
	{
	
		delete pDBInstall_SQL;
		pDBInstall_SQL = NULL;
	}

	if (pDBInstall_Oracle != NULL)
	{
	
		delete pDBInstall_Oracle;
		pDBInstall_Oracle = NULL;
	}
}




STDMETHODIMP CInstallConfigObj::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IInstallConfigObj
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}




/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::AddSystemEnvironmentPath
 *
 *	Params: 
 *		BSTR	bstrAppPath	:	(In) A BSTR containing the application path to be added 
 *										to the existing system path environment variable.
 *
 *	Comments:
 *		This method adds the specifed path to the system path environment variable.
 *		
 *		
 */
STDMETHODIMP CInstallConfigObj::AddSystemEnvironmentPath(BSTR bstrAppPath)
{
	HRESULT hr = S_OK;
	_bstr_t bsAppPath (bstrAppPath, 1);

	HKEY	m_hKey		= NULL;
	DWORD	dwError		= 0;
	DWORD	dwType		= 0;
	DWORD	dwResult;

	char	sSysPath[kMAX_PATH_LEN]	= _T("");
	DWORD	cbPath		= kMAX_PATH_LEN;

	if (bstrAppPath == NULL) 
	{
		hr = SetErrorInfo(eCOM, E_POINTER, kSEVERITY_ERROR, _T("CInstallConfigObj::AddSystemEnvironmentPath"));
		return hr;
	}

	if ( lstrcmp((char*)bsAppPath, "") == 0 )
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddSystemEnvironmentPath (empty string parameter)"));
		return hr;
	}
		
	try
	{

		dwError = ::RegOpenKeyEx(HKEY_LOCAL_MACHINE,
							kREGKEY_SYS_ENVIRON_PATH,
							0,	// Reserved
							(KEY_READ | KEY_WRITE),
							&m_hKey);
		if (dwError != ERROR_SUCCESS)
		{
			hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::AddSystemEnvironmentPath (RegOpenKeyEx)"));
			return hr;
		}

		dwError = RegQueryValueEx(m_hKey,
							"Path",
							0,	// Reserved
							&dwType,
							(LPBYTE)sSysPath,
							&cbPath); 
		if (dwError != ERROR_SUCCESS)
		{
			hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::AddSystemEnvironmentPath (RegQueryValueEx)"));
			return hr;
		}

		//*** Make sure the new env path is not already in the system path variable ***
		if (_tcsstr(sSysPath, (char*)bsAppPath) != NULL) 
			return S_OK;

		if (lstrlen(sSysPath) + lstrlen((char*)bsAppPath) > kMAX_PATH_LEN)
		{
			hr = SetErrorInfo(eLocalApp, LOCAL_ER_MAX_PATH_LENGTH_EXCEEDED, kSEVERITY_ERROR, 
									_T("CInstallConfigObj::AddSystemEnvironmentPath"));
			return hr;
		}

		//*** Path must have trailing ';' *** 
		if (sSysPath[lstrlen(sSysPath) - 1] != ';')
		{
			lstrcat(sSysPath, ";");
		}
		lstrcat(sSysPath, (char*)bsAppPath);

		//*** Set the new system path ***
        dwError = RegSetValueEx(m_hKey,
							"Path",
							0,
							dwType,
							(LPBYTE)sSysPath,
							lstrlen(sSysPath));
		if (dwError != ERROR_SUCCESS)
		{
			hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::AddSystemEnvironmentPath (RegSetValueEx)"));
			return hr;
		}

		//*** Notify the operating system to refresh all apps ***
		SendMessageTimeout(HWND_BROADCAST,
                WM_SETTINGCHANGE,
                0,
                (LPARAM) "Environment",
                SMTO_ABORTIFHUNG,
				5000,
                &dwResult);

	} // End of try block
	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR,  _T("CInstallConfigObj::AddSystemEnvironmentPath"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR,  _T("CInstallConfigObj::AddSystemEnvironmentPath"));
	}
	return hr;
} // End of AddSystemEnvironmentPath





/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::DeleteSystemEnvironmentPath
 *
 *	Params: 
 *		BSTR	bstrAppPath	:	(In) A BSTR containing the application path to be deleted 
 *										from the existing system path environment variable.
 *
 *	Comments:
 *		This method removes the specifed path from the system path environment variable.
 *		
 *		
 */
STDMETHODIMP CInstallConfigObj::DeleteSystemEnvironmentPath(BSTR bstrAppPath)
{
	HRESULT hr = S_OK;
	_bstr_t bsAppPath (bstrAppPath, 1);

	HKEY	m_hKey		= NULL;
	DWORD	dwError		= 0;
	DWORD	dwType		= 0;
	DWORD	dwResult;

	char	sSysPath[kMAX_PATH_LEN]	= _T("");
	char	sNewPath[kMAX_PATH_LEN]	= _T("");
	DWORD	cbPath		= kMAX_PATH_LEN;

	LPTSTR	pSubStr		= NULL;
	INT		nOffset;

	if (bstrAppPath == NULL) 
	{
		hr = SetErrorInfo(eCOM, E_POINTER, kSEVERITY_ERROR, _T("CInstallConfigObj::DeleteSystemEnvironmentPath"));
		return hr;
	}

	if ( lstrcmp((char*)bsAppPath, "") == 0 )
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::DeleteSystemEnvironmentPath (empty string parameter)"));
		return hr;
	}
		
	try
	{

		dwError = ::RegOpenKeyEx(HKEY_LOCAL_MACHINE,
							kREGKEY_SYS_ENVIRON_PATH,
							0,	// Reserved
							(KEY_READ | KEY_WRITE),
							&m_hKey);
		if (dwError != ERROR_SUCCESS)
		{
			hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::DeleteSystemEnvironmentPath (RegOpenKeyEx)"));
			return hr;
		}

		dwError = RegQueryValueEx(m_hKey,
							"Path",
							0,	// Reserved
							&dwType,
							(LPBYTE)sSysPath,
							&cbPath); 
		if (dwError != ERROR_SUCCESS)
		{
			hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::DeleteSystemEnvironmentPath (RegQueryValueEx)"));
			return hr;
		}

		//*** Locate the path to be removed in the system path ***
		pSubStr = _tcsstr(sSysPath, (char*)bsAppPath);
		if (pSubStr == NULL) 
			return S_OK;			// Path not in system path

		nOffset = pSubStr - sSysPath;
		lstrcpyn(sNewPath, sSysPath, nOffset+1);
		nOffset += lstrlen((char*)bsAppPath);
		lstrcat(sNewPath, sSysPath+nOffset);


		//*** Set the new system path ***
        dwError = RegSetValueEx(m_hKey,
							"Path",
							0,
							dwType,
							(LPBYTE)sNewPath,
							lstrlen(sNewPath));
		if (dwError != ERROR_SUCCESS)
		{
			hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::DeleteSystemEnvironmentPath (RegSetValueEx)"));
			return hr;
		}

		//*** Notify the operating system to refresh all apps ***
		SendMessageTimeout(HWND_BROADCAST,
                WM_SETTINGCHANGE,
                0,
                (LPARAM) "Environment",
                SMTO_ABORTIFHUNG,
				5000,
                &dwResult);

	} // End of try block
	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR,  _T("CInstallConfigObj::DeleteSystemEnvironmentPath"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR,  _T("CInstallConfigObj::DeleteSystemEnvironmentPath"));
	}
	return hr;
} // End of DeleteSystemEnvironmentPath




/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::InitializeDBOperations_SQL
 *
 *	Params: 
 *		BSTR	bstrAdminID			: (In)	UserID of DB Admin or privileged user
 *		BSTR	bstrAdminPwd 		: (In)	Password of DB Admin or privileged user
 *		BSTR	bstrDBName 			: (In)	Name of SQL Server database to be created
 *		BSTR	bstrDBMSHost 		: (In)	Computer hosting the SQL Server DBMS
 *		BSTR	bstrUserID 			: (In)	UserID of initial dbo user
 *		BSTR	bstrUserPwd 		: (In)	Password of initial dbo user
 *		BSTR	bstrDataDeviceName	: (In)	Name of SQL Server data device -- without path or extension
 *		BSTR	bstrDataDevicePath 	: (In)	Full path to SQL Server data device -- including file name
 *		INT		nDataDeviceSize		: (In)	Initial size in MB of SQL Server data device 
 *		BSTR	bstrLogDeviceName 	: (In)	Name of SQL Server log device -- without path or extension
 *		BSTR	bstrLogDevicePath 	: (In)	Full path to SQL Server log device -- including file name
 *		INT		nLogDeviceSize		: (In)	Initial size in MB of SQL Server log device 
 *		BSTR	bstrDataBackupPath 	: (In)	Full path to data backup device -- including extension(.backup)
 *		BSTR	bstrLogBackupPath 	: (In)	Full path to log backup device -- including extension(.backup)
 *		INT		nTimeout			: (In)	Timeout in milliseconds
 *
 *	Comments:
 *		InitializeDBOperations_SQL(...) sets up the class structures needed by the DBInstall library.
 *		
 *		
 */
STDMETHODIMP CInstallConfigObj::InitializeDBOperations_SQL
						(BSTR bstrAdminID, BSTR bstrAdminPwd, 
						BSTR bstrDBName, BSTR bstrDBMSHost, BSTR bstrUserID, BSTR bstrUserPwd, 
						BSTR bstrDataDeviceName, BSTR bstrDataDevicePath, INT nDataDeviceSize,
						BSTR bstrLogDeviceName, BSTR bstrLogDevicePath, INT nLogDeviceSize,
						BSTR bstrDataBackupPath, BSTR bstrLogBackupPath, INT nTimeout, INT IsStaging)
{
	HRESULT hr = S_OK;
	LONG	lResult;

	_bstr_t bsAdminID (bstrAdminID, 1);
	_bstr_t bsAdminPwd (bstrAdminPwd, 1);
	_bstr_t bsDBName (bstrDBName, 1);
	_bstr_t bsDBMSHost (bstrDBMSHost, 1);
	_bstr_t bsUserID (bstrUserID, 1);
	_bstr_t bsUserPwd (bstrUserPwd, 1);
	_bstr_t bsDataDeviceName (bstrDataDeviceName, 1);
	_bstr_t bsDataDevicePath (bstrDataDevicePath, 1);
	_bstr_t bsLogDeviceName (bstrLogDeviceName, 1);
	_bstr_t bsLogDevicePath (bstrLogDevicePath, 1);
	_bstr_t bsDataBackupPath (bstrDataBackupPath, 1);
	_bstr_t bsLogBackupPath (bstrLogBackupPath, 1);

	if (bstrAdminID	== NULL || 
		bstrAdminPwd == NULL || 
		bstrDBName == NULL || 
		bstrDBMSHost == NULL || 
		bstrUserID == NULL || 
		bstrUserPwd == NULL || 
		bstrDataDeviceName == NULL || 
		bstrDataDevicePath == NULL || 
		bstrLogDeviceName == NULL || 
		bstrLogDevicePath == NULL || 
		bstrDataBackupPath == NULL || 
		bstrLogBackupPath == NULL) 
	{
		hr = SetErrorInfo(eCOM, E_POINTER, kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_SQL"));
		return hr;
	}

	if (lstrcmp((char*)bsAdminID, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_SQL (Admin ID)"));
		return hr;
	}

	if (lstrcmp((char*)bsDBName, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_SQL (Database Name)"));
		return hr;
	}

	if (lstrcmp((char*)bsDBMSHost, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_SQL (DBMS Host Computer Name)"));
		return hr;
	}

	if (lstrcmp((char*)bsUserID, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_SQL (Initial User ID)"));
		return hr;
	}
		
	try
	{
		pDBInstall_SQL = new CDBInstall_SQLServer (IsStaging);

		lResult = pDBInstall_SQL->Initialize(
			(char*)bsAdminID,
			bsAdminPwd,
			bsDBName,
			bsDBMSHost,
			bsUserID,
			bsUserPwd,
			bsDataDeviceName,
			bsDataDevicePath,
			nDataDeviceSize,        
			bsLogDeviceName,
			bsLogDevicePath,
			nLogDeviceSize,
			bsDataBackupPath,
			bsLogBackupPath,
			nTimeout);

		if (!lResult)
		{
			lResult = pDBInstall_SQL->GetLastErrorCode();
			hr = SetErrorInfo(eMetraTech, lResult, 
				kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_SQL"));
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR,  
				_T("CInstallConfigObj::InitializeDBOperations_SQL"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR,  
				_T("CInstallConfigObj::InitializeDBOperations_SQL"));
	}

	return hr;
} // End of InitializeDBOperations_SQL






/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::InitializeDBOperations_Oracle
 *
 *	Params: 
 *		BSTR	bstrAdminID			: (In)	UserID of DB Admin or privileged user
 *		BSTR	bstrAdminPwd 		: (In)	Password of DB Admin or privileged user
 *		BSTR	bstrTblSpaceName	: (In)	Name of Oracle Tablespace to be created
 *		BSTR	bstrDSN 			: (In)	Data Source Name pointing to the Oracle DBMS
 *		BSTR	bstrUserID 			: (In)	UserID of initial dbo user
 *		BSTR	bstrUserPwd 		: (In)	Password of initial dbo user
 *		INT		nTimeout			: (In)	Timeout in milliseconds
 *
 *	Comments:
 *		InitializeDBOperations_Oracle(...) sets up the class structures needed by the DBInstall library.
 *		
 *		
 */
STDMETHODIMP CInstallConfigObj::InitializeDBOperations_Oracle
						(BSTR bstrAdminID, BSTR bstrAdminPwd, 
						BSTR bstrTblSpaceName, BSTR bstrDSN, BSTR bstrUserID, BSTR bstrUserPwd, INT nTimeout)
{
	HRESULT hr = S_OK;
	LONG	lResult;

	_bstr_t bsAdminID (bstrAdminID, 1);
	_bstr_t bsAdminPwd (bstrAdminPwd, 1);
	_bstr_t bsTblSpaceName (bstrTblSpaceName, 1);
	_bstr_t bsDSN (bstrDSN, 1);
	_bstr_t bsUserID (bstrUserID, 1);
	_bstr_t bsUserPwd (bstrUserPwd, 1);

	if (bstrAdminID	== NULL || 
		bstrAdminPwd == NULL || 
		bstrTblSpaceName == NULL || 
		bstrDSN == NULL || 
		bstrUserID == NULL || 
		bstrUserPwd == NULL)
	{
		hr = SetErrorInfo(eCOM, E_POINTER, kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_Oracle"));
		return hr;
	}

	if (lstrcmp((char*)bsAdminID, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_Oracle (Admin ID)"));
		return hr;
	}

	if (lstrcmp((char*)bsTblSpaceName, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_Oracle (Tablespace Name)"));
		return hr;
	}

	if (lstrcmp((char*)bsDSN, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_Oracle (ODBC DSN)"));
		return hr;
	}

	if (lstrcmp((char*)bsUserID, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_Oracle (Initial User ID)"));
		return hr;
	}
		
	try
	{
		pDBInstall_Oracle = new CDBInstall_Oracle ();

		lResult = pDBInstall_Oracle->Initialize(
			(char*)bsAdminID,
			bsAdminPwd,
			bsTblSpaceName,
			bsDSN,
			bsUserID,
			bsUserPwd,
			"",
			0,
			nTimeout);

		if (!lResult)
		{
			lResult = pDBInstall_Oracle->GetLastErrorCode();
			hr = SetErrorInfo(eMetraTech, lResult, 
				kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_Oracle"));
		}

		lResult = pDBInstall_Oracle->InitDbAccess();
		if (!lResult)
		{
			lResult = pDBInstall_Oracle->GetLastErrorCode();
			hr = SetErrorInfo(eMetraTech, lResult, 
				kSEVERITY_ERROR, _T("CInstallConfigObj::InitializeDBOperations_Oracle"));
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR,  
				_T("CInstallConfigObj::InitializeDBOperations_Oracle"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR,  
				_T("CInstallConfigObj::InitializeDBOperations_Oracle"));
	}

	return hr;
} // End of InitializeDBOperations_Oracle




/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::InstallDatabase
 *
 *	Params: 
 *
 *	Comments:
 *		InstallDatabase() creates the full database devices and initial dbo user for either
 *		the MetraTech core database or a separate Payment Server database.  InstallDatabase 
 *		is used only to create SQL Server databases.  
 *		
 */
STDMETHODIMP CInstallConfigObj::InstallDatabase()
{
	HRESULT hr = S_OK;
	LONG	lResult;

	if (pDBInstall_SQL == NULL && pDBInstall_Oracle == NULL)
	{
		hr = SetErrorInfo(eLocalApp, LOCAL_ER_DBINSTALL_NOT_INITIALIZED, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDatabase"));
		return hr;
	}

	try
	{
		lResult = pDBInstall_SQL->Install();

		if (lResult)
			lResult = pDBInstall_SQL->ChangeDBOwner();

		if (!lResult)
		{
			lResult = pDBInstall_SQL->GetLastErrorCode();
			hr = SetErrorInfo(eMetraTech, lResult, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDatabase"));
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR,  _T("CInstallConfigObj::InstallDatabase"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR,  _T("CInstallConfigObj::InstallDatabase"));
	}

	return hr;
} // End of InstallDatabase


/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::InstallDatabase
 *
 *	Params: 
 *
 *	Comments:
 *		InstallDatabase() creates the full database devices and initial dbo user for either
 *		the MetraTech core database or a separate Payment Server database.  InstallDatabase 
 *		is used only to create SQL Server databases.  
 *		
 */
STDMETHODIMP CInstallConfigObj::InstallDatabase_WithoutDropDB()
{
	HRESULT hr = S_OK;
	LONG	lResult;

	if (pDBInstall_SQL == NULL && pDBInstall_Oracle == NULL)
	{
		hr = SetErrorInfo(eLocalApp, LOCAL_ER_DBINSTALL_NOT_INITIALIZED, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDatabase"));
		return hr;
	}

	try
	{
		lResult = pDBInstall_SQL->Install_withoutDropDB();

		if (lResult)
			lResult = pDBInstall_SQL->ChangeDBOwner();

		if (!lResult)
		{
			lResult = pDBInstall_SQL->GetLastErrorCode();
			hr = SetErrorInfo(eMetraTech, lResult, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDatabase"));
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR,  _T("CInstallConfigObj::InstallDatabase"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR,  _T("CInstallConfigObj::InstallDatabase"));
	}

	return hr;
} // End of InstallDatabase


/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::InstallCoreDBSchema
 *
 *	Params: 
 *
 *	Comments:
 *		This method causes the schema for the core MetraTech database to be installed
 *		in the database created by the call to CInstallConfigObj::InstallDatabase(...)
 *		
 *		
 */
STDMETHODIMP CInstallConfigObj::InstallCoreDBSchema()
{
	HRESULT hr = S_OK;
	LONG	lResult;
	_bstr_t	bsDBMS;

	if (pDBInstall_SQL == NULL && pDBInstall_Oracle == NULL)
	{
		hr = SetErrorInfo(eLocalApp, LOCAL_ER_DBINSTALL_NOT_INITIALIZED, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallCoreDBSchema"));
		return hr;
	}

	try
	{
		if (pDBInstall_SQL != NULL)
		{
			bsDBMS = _T("(SQL Server)");
			lResult = pDBInstall_SQL->InstallDBObjects();
			if (!lResult)
			{
				lResult = pDBInstall_SQL->GetLastErrorCode();
				hr = SetErrorInfo(eMetraTech, lResult, kSEVERITY_ERROR, lstrcat(_T("CInstallConfigObj::InstallCoreDBSchema : "), (char*)bsDBMS));
			}
		}
		else
		{
			bsDBMS = _T("(Oracle)");
			lResult = pDBInstall_Oracle->InstallDBObjects();
			if (!lResult)
			{
				lResult = pDBInstall_Oracle->GetLastErrorCode();
				hr = SetErrorInfo(eMetraTech, lResult, kSEVERITY_ERROR, lstrcat(_T("CInstallConfigObj::InstallCoreDBSchema : "), (char*)bsDBMS));
			}
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR, lstrcat(_T("CInstallConfigObj::InstallCoreDBSchema : "), (char*)bsDBMS));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, lstrcat(_T("CInstallConfigObj::InstallCoreDBSchema : "), (char*)bsDBMS));
	}

	return hr;
} // End of InstallCoreDBSchema





/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::InstallDBDescriptionTable
 *
 *	Params: 
 *
 *	Comments:
 *		This method wraps the InstallDescriptionTable () method of the InstallUtil.dll
 *		library.
 *		
 *		
 */
STDMETHODIMP CInstallConfigObj::InstallDBDescriptionTable()
{
	HRESULT hr = S_OK;
	BOOL	bResult;

	try
	{
		bResult = InstallDescriptionTable();

		if (!bResult)
		{
			hr = SetErrorInfo(eLocalApp, LOCAL_ER_INSTALLUTIL_DESC_TBL_FAILED, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDBDescriptionTable"));
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDBDescriptionTable"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDBDescriptionTable"));
	}

	return hr;
} // End of InstallDBDescriptionTable






/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::AddDBAccount
 *
 *	Params: 
 *		BSTR	bstrAccountName		: (In)	Account Name
 *		BSTR	bstrPassword 		: (In)	Account Password 
 *		BSTR	bstrNameSpace 		: (In)	Namespace of Account
 *		BSTR	bstrLanguage 		: (In)	Language for Account
 *		LONG	nDayOfMonth 		: (In)	Day of the Month of Account Creation
 *		BSTR	bstrAccountType		: (In)  Type of Account
 *
 *	Comments:
 *		This method wraps the AddAccount () method of the InstallUtil.dll
 *		library.
 *		
 */
STDMETHODIMP CInstallConfigObj::AddDBAccount (BSTR bstrAccountName, BSTR bstrPassword, 
											  BSTR bstrNameSpace, BSTR bstrLanguage, LONG nDayOfMonth, BSTR bstrAccountType)
{
	HRESULT hr = S_OK;
	BOOL	bResult;
	_bstr_t bsAccountName (bstrAccountName, 1);
	_bstr_t bsPassword (bstrPassword, 1);
	_bstr_t bsNameSpace (bstrNameSpace, 1);
	_bstr_t bsLanguage (bstrLanguage, 1);
	_bstr_t bsAccountType (bstrAccountType, 1);


	if (bstrAccountName == NULL || 
		bstrPassword == NULL || 
		bstrNameSpace == NULL || 
		bstrAccountType == NULL ||
		bstrLanguage == NULL) 
	{
		hr = SetErrorInfo(eCOM, E_POINTER, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccount"));
		return hr;
	}

	if (lstrcmp((char*)bsAccountName, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccount (Account Name)"));
		return hr;
	}

	if (lstrcmp((char*)bsPassword, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccount (Account Password)"));
		return hr;
	}

	if (lstrcmp((char*)bsNameSpace, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccount (Account Namespace)"));
		return hr;
	}

	if (lstrcmp((char*)bsLanguage, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccount (Language)"));
		return hr;
	}

	if (lstrcmp((char*)bsAccountType, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccount (Account Type)"));
		return hr;
	}
	try
	{
		bResult = AddAccount(bsAccountName, bsPassword, bsNameSpace, bsLanguage, nDayOfMonth, bsAccountType);

		if (!bResult)
		{
			hr = SetErrorInfo(eLocalApp, LOCAL_ER_INSTALLUTIL_ADDACCT_FAILED, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccount"));
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccount"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccount"));
	}

	return hr;
} // End of AddDBAccount







/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::AddDBAccountWithCycle
 *
 *	Params: 
 *		BSTR	bstrAccountName		: (In)	Account Name
 *		BSTR	bstrPassword 		: (In)	Account Password 
 *		BSTR	bstrNameSpace 		: (In)	Namespace of Account
 *		BSTR	bstrLanguage 		: (In)	Language for Account
 *		LONG	nDayOfMonth 		: (In)	Day of the Month of Account Creation
 *		BSTR	bstrUCT				: (In)  Usage Cycle Interval
 *
 *	Comments:
 *		This method wraps the AddAccountWithCycle () method of the InstallUtil.dll
 *		library.
 *		
 */
STDMETHODIMP CInstallConfigObj::AddDBAccountWithCycle (BSTR bstrAccountName, BSTR bstrPassword, 
											  BSTR bstrNameSpace, BSTR bstrLanguage, 
											  LONG nDayOfMonth, BSTR bstrUCT)
{
	HRESULT hr = S_OK;
	BOOL	bResult;
	_bstr_t bsAccountName (bstrAccountName, 1);
	_bstr_t bsPassword (bstrPassword, 1);
	_bstr_t bsNameSpace (bstrNameSpace, 1);
	_bstr_t bsLanguage (bstrLanguage, 1);
	_bstr_t bsUCT (bstrUCT, 1);



	if (bstrAccountName == NULL || 
		bstrPassword == NULL || 
		bstrNameSpace == NULL || 
		bstrLanguage == NULL ||
		bstrUCT == NULL)
	{
		hr = SetErrorInfo(eCOM, E_POINTER, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountWithCycle"));
		return hr;
	}

	if (lstrcmp((char*)bsAccountName, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountWithCycle (Account Name)"));
		return hr;
	}

	if (lstrcmp((char*)bsPassword, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountWithCycle (Account Password)"));
		return hr;
	}

	if (lstrcmp((char*)bsNameSpace, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountWithCycle (Account Namespace)"));
		return hr;
	}

	if (lstrcmp((char*)bsLanguage, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountWithCycle (Language)"));
		return hr;
	}

	if (lstrcmp((char*)bsUCT, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountWithCycle (Usage Cycle)"));
		return hr;
	}
		
	try
	{
		bResult = AddAccountWithCycle(bsAccountName, bsPassword, bsNameSpace, bsLanguage, nDayOfMonth, bsUCT);

		if (!bResult)
		{
			hr = SetErrorInfo(eLocalApp, LOCAL_ER_INSTALLUTIL_ADDACCT_FAILED, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountWithCycle"));
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountWithCycle"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountWithCycle"));
	}

	return hr;
} // End of AddDBAccountWithCycle






/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::AddDBAccountMappings
 *
 *	Params: 
 *		BSTR	bstrAccountName		: (In)	Account Name
 *		BSTR	bstrNameSpace 		: (In)	Namespace of Account
 *		LONG	nAccountID 			: (In)	Beginning Account ID number
 *
 *	Comments:
 *		This method wraps the AddAccountMappings () method of the InstallUtil.dll
 *		library.
 *		
 */
STDMETHODIMP CInstallConfigObj::AddDBAccountMappings(BSTR bstrAccountName, BSTR bstrNameSpace, LONG nAccountID)
{
	HRESULT hr = S_OK;
	BOOL	bResult;
	_bstr_t bsAccountName (bstrAccountName, 1);
	_bstr_t bsNameSpace (bstrNameSpace, 1);

	if (bstrAccountName == NULL || 
		bstrNameSpace == NULL)
	{
		hr = SetErrorInfo(eCOM, E_POINTER, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountMappings"));
		return hr;
	}

	if (lstrcmp((char*)bsAccountName, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountMappings (Account Name)"));
		return hr;
	}

	if (lstrcmp((char*)bsNameSpace, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountMappings (Account Namespace)"));
		return hr;
	}
		
	try
	{
		bResult = AddAccountMappings(bsAccountName, bsNameSpace, nAccountID);

		if (!bResult)
		{
			hr = SetErrorInfo(eLocalApp, LOCAL_ER_INSTALLUTIL_ADDACCTMAP_FAILED, kSEVERITY_ERROR, _T("CInstallConfigObj::AddDBAccountMappings"));
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR,  _T("CInstallConfigObj::AddDBAccountMappings"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR,  _T("CInstallConfigObj::AddDBAccountMappings"));
	}

	return hr;
} // End of AddDBAccountMappings







/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::InstallDBExtensionTables
 *
 *	Params: 
 *		BSTR	bstrPath			: (In)	Path to the target extension's  config file
 *		BSTR	bstrConfigFile		: (In)	Name of the extension's config file
 *
 *	Comments:
 *		This method wraps the InstallExtensionTables () method of the InstallUtil.dll
 *		library.
 *		
 */
STDMETHODIMP CInstallConfigObj::InstallDBExtensionTables(BSTR bstrPath, BSTR bstrConfigFile)
{
	HRESULT hr = S_OK;
	BOOL	bResult;
	_bstr_t bsPath (bstrPath, 1);
	_bstr_t bsConfigFile (bstrConfigFile, 1);

	if (bstrPath == NULL || 
		bstrConfigFile == NULL)
	{
		hr = SetErrorInfo(eCOM, E_POINTER, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDBExtensionTable"));
		return hr;
	}

	if (lstrcmp((char*)bsPath, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDBExtensionTable (Config file path)"));
		return hr;
	}

	if (lstrcmp((char*)bsConfigFile, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDBExtensionTable (Config file name)"));
		return hr;
	}
		
		
	try
	{
		bResult = InstallExtensionTables(bsPath, bsConfigFile);

		if (!bResult)
		{
			hr = SetErrorInfo(eLocalApp, LOCAL_ER_INSTALLUTIL_INSTALLEXT_FAILED, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDBExtensionTable"));
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDBExtensionTable"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::InstallDBExtensionTable"));
	}

	return hr;
} // End of InstallDBExtensionTable





/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::UninstallDBExtensionTables
 *
 *	Params: 
 *		BSTR	bstrPath			: (In)	Path to the target extension's uninstall config file
 *		BSTR	bstrUninstallFile	: (In)	Name of the extension's uninstall config file
 *
 *	Comments:
 *		This method wraps the UnInstallExtensionTables () method of the InstallUtil.dll
 *		library.
 *		
 */
STDMETHODIMP CInstallConfigObj::UninstallDBExtensionTables(BSTR bstrPath, BSTR bstrConfigFile)
{
	HRESULT hr = S_OK;
	BOOL	bResult;
	_bstr_t bsPath (bstrPath, 1);
	_bstr_t bsConfigFile (bstrConfigFile, 1);

	if (bstrPath == NULL || 
		bstrConfigFile == NULL)
	{
		hr = SetErrorInfo(eCOM, E_POINTER, kSEVERITY_ERROR, _T("CInstallConfigObj::UninstallDBExtensionTables"));
		return hr;
	}

	if (lstrcmp((char*)bsPath, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::UninstallDBExtensionTables (Config file path)"));
		return hr;
	}

	if (lstrcmp((char*)bsConfigFile, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::UninstallDBExtensionTables (Config file name)"));
		return hr;
	}
		
		
	try
	{
		bResult = InstallExtensionTables(bsPath, bsConfigFile);  // Also uninstalls the Extension tables

		if (!bResult)
		{
			hr = SetErrorInfo(eLocalApp, LOCAL_ER_INSTALLUTIL_UNINSTALLEXT_FAILED, kSEVERITY_ERROR, _T("CInstallConfigObj::UninstallDBExtensionTables"));
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR, _T("CInstallConfigObj::UninstallDBExtensionTables"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::UninstallDBExtensionTables"));
	}

	return hr;
} // End of UninstallDBExtensionTables






/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::UninstallDatabase
 *
 *	Params: 
 *
 *	Comments:
 *		UninstallDatabase() deletes the full MetraTech core database, including platform
 *		extension schema if any is present on the database.  
 *		
 */
STDMETHODIMP CInstallConfigObj::UninstallDatabase()
{
	HRESULT hr = S_OK;
	LONG	lResult;
	_bstr_t	bsDBMS;

	if (pDBInstall_SQL == NULL && pDBInstall_Oracle == NULL)
	{
		hr = SetErrorInfo(eLocalApp, LOCAL_ER_DBINSTALL_NOT_INITIALIZED, kSEVERITY_ERROR, _T("CInstallConfigObj::UninstallDatabase"));
		return hr;
	}

	try
	{
		if (pDBInstall_SQL != NULL)
		{
			bsDBMS = _T("(SQL Server)");
			lResult = pDBInstall_SQL->Uninstall();
			if (!lResult)
			{
				lResult = pDBInstall_SQL->GetLastErrorCode();
				hr = SetErrorInfo(eMetraTech, lResult, kSEVERITY_ERROR, lstrcat(_T("CInstallConfigObj::UninstallDatabase : "), (char*)bsDBMS));
			}
		}
		else
		{
			bsDBMS = _T("(Oracle)");

			lResult = pDBInstall_Oracle->DropDBObjects();
			if (!lResult)
			{
				lResult = pDBInstall_Oracle->GetLastErrorCode();
				hr = SetErrorInfo(eMetraTech, lResult, kSEVERITY_ERROR, lstrcat(_T("CInstallConfigObj::UninstallDatabase : "), (char*)bsDBMS));
			}
		}

	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR,  lstrcat(_T("CInstallConfigObj::UninstallDatabase : "), (char*)bsDBMS));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR,  lstrcat(_T("CInstallConfigObj::UninstallDatabase : "), (char*)bsDBMS));
	}

	return hr;
} // End of UninstallDatabase






/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::EncryptDBAccessKeys
 *
 *	Params: 
 *
 *	Comments:
 *		This method wraps the InstallDbaccessKeys() method of the InstallUtil.dll
 *		library.
 *		
 *		
 */
STDMETHODIMP CInstallConfigObj::EncryptDBAccessKeys()
{
	HRESULT hr = S_OK;
	BOOL	bResult;

	try
	{
		bResult = InstallDbaccessKeys();

		if (!bResult)
		{
			hr = SetErrorInfo(eLocalApp, LOCAL_ER_INSTALLUTIL_ENCRYPTDB_FAILED, kSEVERITY_ERROR, _T("CInstallConfigObj::EncryptDBAccessKeys"));
		}
	} // End of try ...

	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR, _T("CInstallConfigObj::EncryptDBAccessKeys"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR, _T("CInstallConfigObj::EncryptDBAccessKeys"));
	}

	return hr;
}






/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::SetErrorInfo
 *	Param: 
 *		UINT	unType		(In)	1=Local application error (see InstallConfigMsg.h)
 *									2=Win32 error.  Will be formatted with system msg file and 
 *											converted into an HResult.
 *									3=COM error.  Will be formatted with system msg file.
 *									4=MetraTech error code.
 *
 *		DWORD	dwError	:	(In)	Contains the error code.  This value could be a Win32 error, 
 *									a COM error, or an error code that is local to this application.	 			
 *
 *		UINT	unSeverity  (In)	A severity code provided for locally generated or Win32 errors. 
 *									Each of these will be formed into HResults for IErrorInfo
 *
 *		LPTSTR	pszErrMsg	(In)	Local message to be appended to any formatted messages. 
 *
 *	Comment:
 *		This method sets the IErrorInfo structures for passing error information back to the caller.
 *		
 */
HRESULT CInstallConfigObj::SetErrorInfo(enumErrorType unType, DWORD dwError, UINT unSeverity, LPTSTR pszErrMsg)
{
	USES_CONVERSION;			// Declarations for Unicode Macros -- see below

	const char szApplicationName [] = _T("InstallConfig");

	LONG	nLen = 0;
	LPVOID	pszFormatMsg = NULL;
	LPTSTR	pszErrorMsg = NULL;
	char	szError [30] = _T("");

	HRESULT				hRes;
	HRESULT				hr = E_FAIL;
	
	// *** Figure out the size of the buffer needed for the complete error message ***
	if (unType == eWin32 || unType == eCOM)
	{
		FormatMessage(
			FORMAT_MESSAGE_ALLOCATE_BUFFER | 
			FORMAT_MESSAGE_FROM_SYSTEM | 
			FORMAT_MESSAGE_IGNORE_INSERTS, 
			NULL, 
			dwError, 
			0, 
			(LPTSTR)&pszFormatMsg, 
			0, 
			NULL);
		
		// *** Start computing the buffer needed to hold all parts of the error msg ***
		nLen = 30;										// <-- Account for szError 
		if (pszFormatMsg != NULL)
			nLen += lstrlen((LPTSTR)pszFormatMsg);		// <-- the string from FormatMessage
	}
	else
	if  (unType == eLocalApp)
	{	// *** This is a local app error -- defined in the InstallConfigMsg.h file ***
		if (dwError < LOCAL_ER_MAX)
		{
			nLen += lstrlen(kMessage[dwError]);
		}
	}
	else
	if  (unType == eMetraTech)
	{	// *** This is a local MetraTech error code -- Not defined in the InstallConfigMsg.h file ***
		nLen += lstrlen(kMessage[LOCAL_ER_METRATECH]);
	}

	nLen += lstrlen(pszErrMsg);							// <-- the caller's string
	nLen += 20;											// <-- just for a formatting buffer


	// *** Assemble the complete error message ***
	if (unType == eLocalApp || unType == eWin32 || unType == eMetraTech)  // Local,Win32,or MetraTech error--make HResult
	{
		hRes = MAKE_HRESULT(unSeverity, FACILITY_ITF, dwError);
	}
	else
		hRes = dwError;

	wsprintf(szError, "(%X)", hRes);

	pszErrorMsg = (LPTSTR)LocalAlloc(LPTR, nLen);		// Get buffer for the whole deal
	if (pszErrorMsg != NULL)
	{
		lstrcpy(pszErrorMsg, pszErrMsg);
		lstrcat(pszErrorMsg, " : ");
		lstrcat(pszErrorMsg, szError);
		lstrcat(pszErrorMsg, " : ");
		if (pszFormatMsg != NULL)
		{
			lstrcat(pszErrorMsg, (LPTSTR)pszFormatMsg);
			LocalFree(pszFormatMsg);
		}

		if (unType == eLocalApp)						// Local app error
		{
			if (dwError < LOCAL_ER_MAX)
			{
				lstrcat(pszErrorMsg, kMessage[dwError]); 
			}
		}

		if (unType == eMetraTech)						// MetraTech error code
		{
			lstrcat(pszErrorMsg, kMessage[LOCAL_ER_METRATECH]); 
		}

		hr = AtlReportError(CLSID_InstallConfigObj, pszErrorMsg, IID_IInstallConfigObj, hRes);

		LocalFree(pszErrorMsg);
	}	

	return hr;

} // End of SetErrorInfo()


/////////////////////////////////////////////////////////////////////////////////////////////
/*
 *	Function: CInstallConfigObj::StopService
 *
 *	Params: 
 *		BSTR	bstrServiceName	:	(In) A BSTR containing the service name of the service to be
 *                                   stopped
 *
 *	Comments:
 *		This method will stop the service specified.
 *		
 */
STDMETHODIMP CInstallConfigObj::StopService(BSTR ServiceName)
{
	HRESULT hr = S_OK;
    long  retval;

	_bstr_t bsServiceName (ServiceName, 1);

	if (ServiceName == NULL)
	{
		hr = SetErrorInfo(eCOM, E_POINTER, kSEVERITY_ERROR, _T("CInstallConfigObj::UninstallDBExtensionTables"));
		return hr;
	}

	if (lstrcmp((char*)bsServiceName, "") == 0)
	{
		hr = SetErrorInfo(eCOM, E_INVALIDARG, kSEVERITY_ERROR, _T("CInstallConfigObj::UninstallDBExtensionTables (Config file path)"));
		return hr;
	}
		
	try
	{


		MTSCMConfig aConfigSCM((char*)bsServiceName);

	    retval = aConfigSCM.Stop();

	    if(!retval)
		{
			retval = aConfigSCM.GetLastErrorCode();
			hr = SetErrorInfo(eLocalApp, LOCAL_ER_MTSCMCONFIG_STOPSERVICE_FAILED, kSEVERITY_ERROR,
				               _T("CInstallConfigObj::StopService (MTSCMConfig->StopService)"));
			return hr;
		}

 	} // End of try block
	catch(_com_error e)
	{
		hr = SetErrorInfo(eCOM, e.Error(), kSEVERITY_ERROR,  _T("CInstallConfigObj::StopService"));
	}
	catch(...)
	{
		DWORD	dwError;
		dwError = GetLastError();
		hr = SetErrorInfo(eWin32, dwError, kSEVERITY_ERROR,  _T("CInstallConfigObj::StopService"));
	}
	return hr;
} // End of StopService

