// InstallConfigObj.h : Declaration of the CInstallConfigObj

#ifndef __INSTALLCONFIGOBJ_H_
#define __INSTALLCONFIGOBJ_H_

#include "resource.h"       // main symbols
#include "InstallConfigMsg.h"
#include <DBInstall.h>


// **************************************************************************
//						Global Contants and Vars
// **************************************************************************

const char	kREGKEY_SYS_ENVIRON_PATH []	= 
			"SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment";

const INT	kMAX_PATH_LEN = 1023;

// **************************************************************************





/////////////////////////////////////////////////////////////////////////////
// CInstallConfigObj
class ATL_NO_VTABLE CInstallConfigObj : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CInstallConfigObj, &CLSID_InstallConfigObj>,
	public ISupportErrorInfo,
	public IDispatchImpl<IInstallConfigObj, &IID_IInstallConfigObj, &LIBID_INSTALLCONFIGLib>
{
public:
	CInstallConfigObj();
	~CInstallConfigObj();

DECLARE_REGISTRY_RESOURCEID(IDR_INSTALLCONFIGOBJ)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CInstallConfigObj)
	COM_INTERFACE_ENTRY(IInstallConfigObj)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IInstallConfigObj
public:
	STDMETHOD(AddSystemEnvironmentPath)( /*[in]*/ BSTR bstrAppPath);
	STDMETHOD(DeleteSystemEnvironmentPath)( /*[in]*/ BSTR bstrAppPath);
	STDMETHOD(InitializeDBOperations_SQL)
		(BSTR bstrAdminID, BSTR bstrAdminPwd, 
		BSTR bstrDBName, BSTR bstrDBMSHost, BSTR bstrUserID, BSTR bstrUserPwd, 
		BSTR bstrDataDeviceName, BSTR bstrDataDevicePath, INT nDataDeviceSize,
		BSTR bstrLogDeviceName, BSTR bstrLogDevicePath, INT nLogDeviceSize,
		BSTR bstrDataBackupPath, BSTR bstrLogBackupPath, INT nTimeout, INT IsStaging);

	STDMETHOD(InitializeDBOperations_Oracle)
		(BSTR bstrAdminID, BSTR bstrAdminPwd, 
		BSTR bstrTblSpaceName, BSTR bstrDSN, BSTR bstrUserID, BSTR bstrUserPwd, INT nTimeout);

	STDMETHOD(InstallDatabase)();
	STDMETHOD(InstallDatabase_WithoutDropDB)();
	STDMETHOD(InstallCoreDBSchema)();
	STDMETHOD(InstallDBDescriptionTable)();
	STDMETHOD(AddDBAccount)(BSTR bstrAccountName, BSTR bstrPassword, BSTR bstNameSpace, BSTR bstrLanguage, 
									LONG nDayOfMonth, BSTR bstrAccountType);
	STDMETHOD(AddDBAccountWithCycle)(BSTR bstrAccountName, BSTR bstrPassword, BSTR bstNameSpace, BSTR bstrLanguage, 
									LONG nDayOfMonth, BSTR bstrUCT);
	STDMETHOD(AddDBAccountMappings)(BSTR bstrAccountName, BSTR bstrNameSpace, LONG nAccountID);
	STDMETHOD(InstallDBExtensionTables)(BSTR bstrPath, BSTR bstrConfigFile);
	STDMETHOD(UninstallDBExtensionTables)(BSTR bstrPath, BSTR bstrConfigFile);
	STDMETHOD(UninstallDatabase)();
	STDMETHOD(EncryptDBAccessKeys)();
    STDMETHOD(StopService)(BSTR ServiceName);

private:
	HRESULT SetErrorInfo(enumErrorType unType, DWORD dwError, UINT unSeverity, LPTSTR pszErrorMsg);

private:
	CDBInstall_SQLServer*	pDBInstall_SQL;
	CDBInstall_Oracle*		pDBInstall_Oracle;

};

#endif //__INSTALLCONFIGOBJ_H_
