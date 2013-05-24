/**************************************************************************
 * @doc ADDDEPENDS
 *
 * Copyright 2000 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <windows.h>
#include <iostream>

using std::cout;
using std::endl;
using std::hex;
using std::dec;


int main(int argc, char * argv[])
{
	SC_HANDLE schSCManager =
		::OpenSCManager(NULL, // local machine 
										NULL,				// ServicesActive database 
										SC_MANAGER_ALL_ACCESS);	// full access rights

  if (schSCManager == NULL)
	{
		DWORD err = ::GetLastError();
		cout << "Error opening SCM: " << hex << err << dec << endl;
		return -1;
	}

	SC_HANDLE schService = ::OpenService(schSCManager, "Pipeline", SERVICE_ALL_ACCESS);
	if (!schService)
	{
		DWORD err = ::GetLastError();
		cout << "Error opening SCM: " << hex << err << dec << endl;
		return -1;
	}

	const char * dependencies = "msmq\0mssqlserver\0PipelineCleanup\0\0";

	if (!::ChangeServiceConfig(
		schService,									// handle to service
		SERVICE_NO_CHANGE,					// type of service
		SERVICE_NO_CHANGE,					// when to start service
		SERVICE_NO_CHANGE,					// severity if service fails to start
		NULL,												// pointer to service binary file name
		NULL,												// pointer to load ordering group name
		NULL,												// pointer to variable to get tag identifier
		dependencies,								// pointer to array of dependency names
		NULL,												// pointer to account name of service
		NULL,												// pointer to password for service account
		NULL))											// pointer to display name
	{
		DWORD err = ::GetLastError();
		cout << "Error opening SCM: " << hex << err << dec << endl;
		return -1;
	}

	::CloseServiceHandle(schService);
	::CloseServiceHandle(schSCManager);

	cout << "Service dependencies modified." << endl;
	return 0;
}
