/**************************************************************************
 * @doc TEST
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
 * $Header$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <installutil.h>
#include <iostream>
/*
#ifdef DEBUG
#include <mtcryptoapi.h>
#endif
*/

using std::cout;
using std::endl;

const char* CompareFlag = "-Compare";
const char* pComputefileChecksum = "-ComputeFileChecksum";
const char* LogFlag = "-Log";
const char* AddEnvironmentFlag = "-AddEnvironment";
const char* AddDefaultAccountFlag = "-AddDefaultAccount";
const char* pInstallService = "-InstallService";
const char* pListConfigSetOwnerData = "-ListConfigSetOwnerFiles";
const char* pStopService = "-StopService";
const char* pRegister = "-regsvr32";
const char* pModifyLogFile = "-ModifyLogFile";
const char* pUninstallDB = "-uninstallDB";
const char* pDeleteService = "-DeleteService";
const char* pInstallExtensionTables = "-InstExtDbTables";
const char* pUnInstallExtensionTables = "-UnInstExtDbTables";
const char* pUnregisterServer = "-UnRegister";
const char* pCreateVDir = "-CreateVDir";
const char* pRegTypeLib = "-RegTypeLib";
const char* pUnRegTypeLIb = "-UnRegtypeLib";
const char* pEncryptString ="-EncryptString";
const char* pInstallDbAccessCrypo = "-InstDbaccess_crypto";

int main(int argc, char** argv)
{
	if(argc < 2) {
		cout << "Usage: " << argv[0] << " " << CompareFlag << " OldFile NewFile" << endl;
		cout << "Usage: " << argv[0] << " " << pComputefileChecksum << " filename " << endl;
		cout << "Usage: " << argv[0] << " " << LogFlag << " Message" << endl;
		cout << "Usage: " << argv[0] << " " << pModifyLogFile << " FileName LogFileLocation loglevel" << endl;
    cout << "Usage: " << argv[0] << " " << AddEnvironmentFlag << " Path" << endl;
		cout << "usage: " << argv[0] << " " << AddDefaultAccountFlag << " AccountName Password Namespace Language DayOfMonth Account Type" << endl;
		cout << "usage: " << argv[0] << " " << pInstallService << " ServiceName FormalServiceName BinaryFile [List of Dependencies]" << endl;
		cout << "Usage: " << argv[0] << " " << pStopService << " service-name" << endl;
		cout << "Usage: " << argv[0] << " " << pRegister << " dll-name" << endl;
		cout << "Usage: " << argv[0] << " " << pRegTypeLib << " typelib-name" << endl;
		cout << "Usage: " << argv[0] << " " << pUnRegTypeLIb << " typelib-name" << endl;
		cout << "usage: " << argv[0] << " " << pUnregisterServer << " dll-name" << endl;
		cout << "usage: " << argv[0] << " " << pUninstallDB << " password dbserver" << endl;
		cout << "usage: " << argv[0] << " " << pDeleteService << " servicename" << endl;
		cout << "usage: " << argv[0] << " " << pInstallExtensionTables << " Path FileName" << endl;
		cout << "usage: " << argv[0] << " " << pUnInstallExtensionTables << " Path FileName" << endl;
		cout << "usage: " << argv[0] << " " << pListConfigSetOwnerData << " Path" << endl;
		cout << "usage: " << argv[0] << " " << pCreateVDir << " vdir_name path" << endl;
		cout << "usage: " << argv[0] << " " << pEncryptString << " string" << endl;
		cout << "usage: " << argv[0] << " " << pInstallDbAccessCrypo <<  endl;
		return 1;
	}
	else {
		if(stricmp(argv[1],pComputefileChecksum) == 0) {
			if(argc < 3) {
				cout << "not enough arguments." << endl;
				return 1;
			}
			else {
				char buff[100];
				BOOL result = ComputeChecksumOnFile(argv[2],buff,100);
				if(!result) {
					cout << "could not compute checksum" << endl;
					return -1;
				}
				else {
					cout << buff << endl;
				}
			}
		}

		else if(stricmp(argv[1],CompareFlag) == 0) {
			if(argc < 4) {
				cout << "Not enough arguments." << endl;
				return 1;
			}
			else {
				BOOL result = PerformChecksumOnFiles(argv[2],argv[3]);
				if(result) {
					cout << "Files are identical." << endl;
				}
				else {
					cout << "Checksum failed." << endl;
					return -1;
				}
			}
		}
	
		else if(stricmp(argv[1],LogFlag) == 0) {
			LogInstallMsg(argv[2],LOG_INFO);
			ReleaseResources();
		}
		else if(stricmp(argv[1],pModifyLogFile) == 0) {
			if(argc < 5) {
				cout << "Not enough arguments" << endl;
				return 1;
			}
			else {
				if(ModifyLogFile(argv[2],argv[3],atoi(argv[4]))) {
					cout << "successfully modified " << argv[2] << endl;
				}
				else {
					cout << "Failed to modify " << argv[2] << endl;
					return -1;
				}
			}
		}
    else if(stricmp(argv[1],AddEnvironmentFlag) == 0) {
      AddSystemEnvironmentPath(argv[2]);
    }
		else if(stricmp(argv[1],AddDefaultAccountFlag) == 0) {
			if(argc < 8) {
				cout << "Not enough arguments." << endl;
				return 1;
			}
			else {
				AddAccount(argv[2],argv[3],argv[4],argv[5],atoi(argv[6]), argv[7]);
			}
		}
		else if(stricmp(argv[1],pInstallService) == 0) {
			if(argc < 5) {
				cout << "Not enough arguments." << endl;
				return 1;
			}
			else {
				BOOL bRetVal;
				if(argc >= 6) {
					bRetVal = InstallService(argv[2],argv[3],argv[4],argv[5]);
				}
				else {
					bRetVal = InstallService(argv[2],argv[3],argv[4],NULL);
				}
				if(!bRetVal) {
					cout << "InstallService failed with error " << ::GetLastError << endl;
					return -1;
				}
				else {
					cout << "Successfully created the " << argv[2] << " service.";
				}
			}
		}
		else if(stricmp(argv[1],pStopService) == 0) {
			if(argc < 3) {
				cout << "Not enough arguments." << endl;
				return 1;
			}
			if(!ServiceStop(argv[2])) {
				cout << "Failed to stop the " << argv[2] << " service" << endl;
				return -1;
			}
			else {
				cout << "Successfully stopped the " << argv[2] << " service" << endl;
			}
		}
		else if(stricmp(argv[1],pDeleteService) == 0) {
			if(argc < 3) {
				cout << "Not enough arguments." << endl;
				return 1;
			}
			else {
				if(RemoveService(argv[2])) {
					cout << "Successfully removed service " << argv[2] << endl;
				}
				else {
					cout << "failed to delete service " << argv[2] << endl;
					return 1;
				}
			}
		}
		else if(stricmp(argv[1],pRegister) == 0) {
			if(argc < 3) {
				cout << "Not enough arguments." << endl;
				return 1;
			}
			else {
				if(RegisterComServer(argv[2],TRUE)) {
					cout << "Successfully registered " << argv[2] << endl;
				}
			else {
					cout << "Failed to register " << argv[2] << endl;
					return -1;
				}
			}
		}
		else if(stricmp(argv[1],pRegTypeLib) == 0) {
			if(argc < 3) {
				cout << "Not enough arguments." << endl;
				return 1;
			}
			else {
				if(RegisterTypeLibrary(argv[2])) {
					cout << "Successfully registered type library." << endl;
				}
				else {
					cout << "failed to register type library." << endl;
					return -1;
				}
			}
		}
		else if(stricmp(argv[1],pUnRegTypeLIb) == 0) {
			if(argc < 3) {
				cout << "Not enough arguments." << endl;
				return 1;
			}
			else {
				if(UnregisterRegisterTypeLibrary(argv[2])) {
					cout << "Successfully unregistered type library." << endl;
				}
				else {
					cout << "failed to unregister type library." << endl;
					return -1;
				}
			}
		}
		else if(stricmp(argv[1],pUnregisterServer) == 0) {
			if(argc < 3) {
				cout << "Not enough arguments." << endl;
				return 1;
			}
			else {
				if(UnRegisterComServer(argv[2],TRUE)) {
					cout << "Successfully unregistered " << argv[2] << endl;
				}
			else {
					cout << "Failed to unregister " << argv[2] << endl;
					return -1;
				}
			}

		}
		else if(stricmp(argv[1],pInstallExtensionTables) == 0) {
			if(argc < 4) {
				cout << "Not enough arguments" << endl;
				return 1;
			}
			else {
				if(!InstallExtensionTables(argv[2],argv[3])) {
					cout << "Failed to install extensions tables." << endl;
					return -1;
				}
				else {
					cout << "Successfully installed extensions tables." << endl;
				}
			}

		}
		else if(stricmp(argv[1],pUnInstallExtensionTables) == 0) {
			if(argc < 4) {
				cout << "Not enough arguments" << endl;
				return 1;
			}
			else {
				UnInstallExtensionTables(argv[2],argv[3]);
			}

		}

		else if(stricmp(argv[1],pUninstallDB) == 0) {
			if(argc < 4) {
				cout << "Not enough arguments." << endl;						
				return 1;
			}
			else {
				try {
					if(UninstallDB(argv[2],argv[3],argv[4],argv[5],argv[6])) {
						cout << "Successfully uninstalled the database";
					}
					else
						return -1;						
//					else {

	//				}
				}
				catch(...)
				{
					cout << "Caught error attempting to uninstall the database." << endl;
					return -1;
				}


			}
		}
		else if(stricmp(argv[1],pCreateVDir) == 0) {

			
			if(argc < 4) {
				cout << "not enough arguments." << endl;
				return 1;
			}
			if(CreateIISVdir(argv[2],argv[3])) {
				cout << "Successfully created " << argv[2]  << " virtual directory" << endl;
			}
			else {
				cout << "Failed to create virtual directory." << endl;
				return -1;
			}
		}
	else if(stricmp(argv[1],pEncryptString) == 0) {
		if(argc < 3) {
			cout << "not enough arguments" << endl;
			return 1;
		}
		else {
			char szdestBuf[1024];
			if(EncryptString(argv[2],szdestBuf,1024)) {
				cout << "encrypted string: " << szdestBuf << endl;
			}
			else {
				cout << "failed to encrypt string";
				return -1;
			}
		}
	}
	else if(stricmp(argv[1],pInstallDbAccessCrypo) == 0) {
		if(InstallDbaccessKeys()) {
			cout << "successfully installed the dbaccess.xml crypto keys.";
		}
		else {
			cout << "failed to install the dbaccess.xml crypto keys." << endl;
			return -1;
		}
	}

	else if(stricmp(argv[1],"-decrypt") == 0) {
		if(argc < 3) {
			cout << "not enough arguments." << endl;
			return 1;
		}
		else {
			char buff[1024];
			if(DecryptString(argv[2],buff,1024)) {
				cout << "decrypted string is " << buff << endl;
			}
			else {
				cout << "failed to decrypt stfing." << endl;
				return -1;
			}
		}
	}
	else {
		cout << "Unknown command. " << endl;
		return 1;
		}
}

	return 0;
}
