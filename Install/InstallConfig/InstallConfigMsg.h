// **************************************************************************

// Error and information messages for InstallConfig

// **************************************************************************

#ifndef __INSTALLCONFIGMSG_H_
#define __INSTALLCONFIGMSG_H_

//
//          00 - Success
//          01 - Informational
//          10 - Warning
//          11 - Error
//


enum enumErrorType
{
	eLocalApp,
	eWin32,
	eCOM,
	eMetraTech
};

const UINT LOCAL_ER_MAX		= 40;
const UINT LOCAL_MSGLEN_MAX	= 80;

const UINT kSEVERITY_SUCCESS= 00;
const UINT kSEVERITY_INFO	= 01;
const UINT kSEVERITY_WARN	= 02;
const UINT kSEVERITY_ERROR	= 03;


const char kMessage [LOCAL_ER_MAX][LOCAL_MSGLEN_MAX] = {
	{"Local MetraTech Application Error -- See MTLog.txt"}, 
	{"System path + new path > maximum path length (1023 chars)"},
	{"DBInstall::CDBInstall_SQLServer.Initialize() -- Error Code returned"},
	{"DBInstall::CDBInstall_Oracle.Initialize() -- Error Code returned"},
	{"DBInstall::CDBInstall_SQLServer or CDBInstall_Oracle class not initialized"},
	{"DBInstall::Install() -- Error Code returned"},
	{"DBInstall::InstallDBObjects() -- Error Code returned"},
	{"DBInstall::Uninstall() -- Error Code returned"},
	{"InstallUtil::InstallDescriptionTable failed -- See MT log file"},
	{"InstallUtil::AddAccount failed -- See MT log file"},
	{"InstallUtil::AddAccountMappings failed -- See MT log file"},
	{"InstallUtil::InstallExtensionTables failed -- See MT log file"},
	{"InstallUtil::UninstallExtensionTables failed -- See MT log file"},
	{"InstallUtil::InstallDbaccessKeys failed -- See MT log file"},
	{"MTSCMConfig::StopService failed -- set MT log file"},
	{""}
	};


const char LOCAL_ER_METRATECH						= 0000;
const char LOCAL_ER_MAX_PATH_LENGTH_EXCEEDED		= LOCAL_ER_METRATECH + 1;
const char LOCAL_ER_DBINSTALL_SQL_INITIALIZE_FAILED = LOCAL_ER_METRATECH + 2;
const char LOCAL_ER_DBINSTALL_ORA_INITIALIZE_FAILED = LOCAL_ER_METRATECH + 3;
const char LOCAL_ER_DBINSTALL_NOT_INITIALIZED		= LOCAL_ER_METRATECH + 4;
const char LOCAL_ER_DBINSTALL_CREATE_FAILED			= LOCAL_ER_METRATECH + 5;
const char LOCAL_ER_DBINSTALL_SCHEMA_FAILED			= LOCAL_ER_METRATECH + 6;
const char LOCAL_ER_DBINSTALL_DELETE_FAILED			= LOCAL_ER_METRATECH + 7;
const char LOCAL_ER_INSTALLUTIL_DESC_TBL_FAILED		= LOCAL_ER_METRATECH + 8;
const char LOCAL_ER_INSTALLUTIL_ADDACCT_FAILED		= LOCAL_ER_METRATECH + 9;
const char LOCAL_ER_INSTALLUTIL_ADDACCTMAP_FAILED	= LOCAL_ER_METRATECH + 10;
const char LOCAL_ER_INSTALLUTIL_INSTALLEXT_FAILED	= LOCAL_ER_METRATECH + 11;
const char LOCAL_ER_INSTALLUTIL_UNINSTALLEXT_FAILED	= LOCAL_ER_METRATECH + 12;
const char LOCAL_ER_INSTALLUTIL_ENCRYPTDB_FAILED	= LOCAL_ER_METRATECH + 13;
const char LOCAL_ER_MTSCMCONFIG_STOPSERVICE_FAILED	= LOCAL_ER_METRATECH + 14;


#endif //__INSTALLCONFIGMSG_H_
