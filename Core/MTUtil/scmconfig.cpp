

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
 * $Date$
 * $Author$
 * $Revision$
 */

#include <metra.h>
#include <errobj.h>
#include <scmconfig.h>
#include <MTSingleton.h>
#include <string>

/////////////////////////////////////////////////////////////////
// MTSCMInstance section
/////////////////////////////////////////////////////////////////

MTSingleton<MTSCMInstance> g_SCMInstance;

MTSCMInstance::~MTSCMInstance()
{
	if(mHandle) {
		// close the service control manager
		CloseServiceHandle(mHandle);
		mHandle = NULL;
	}
}


BOOL MTSCMInstance::Init()
{
	// Open the SCM manager for full access
	mHandle = OpenSCManager(NULL,NULL,SC_MANAGER_ALL_ACCESS);
	return mHandle != NULL;
}

/////////////////////////////////////////////////////////////////
// MTSCMConfig section
/////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////
// Costructor
//
// obtains an instance and attempts to open the Service Control 
// Manager.
/////////////////////////////////////////////////////////////////

MTSCMConfig::MTSCMConfig(const char* ServiceName) : mServiceName(ServiceName), mError(0)
{
	mpInstance = g_SCMInstance.GetInstance();

	mServiceHandle = OpenServiceA(mpInstance->GetHandle(),mServiceName.c_str(),SC_MANAGER_ALL_ACCESS);
	if(!mServiceHandle) {
		mError = ::GetLastError();
	}
}


/////////////////////////////////////////////////////////////////
// Release instance of 
/////////////////////////////////////////////////////////////////

MTSCMConfig::~MTSCMConfig()
{
	::CloseServiceHandle(mServiceHandle);
	g_SCMInstance.ReleaseInstance();
	mpInstance = NULL;
}

/////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////

BOOL MTSCMConfig::Start()
{
	BOOL bRetVal = FALSE;
  BOOL bDone = FALSE;

	if(mpInstance && mServiceHandle) {
		bRetVal = StartService(mServiceHandle,0,NULL);
    if(bRetVal) {
      // Wait for action will set any error
      bRetVal = WaitForAction(TRUE);
    }
    else {
      DWORD error = ::GetLastError();
      bRetVal = (error == ERROR_SERVICE_ALREADY_RUNNING);
      if(!bRetVal)
      SetError(error,ERROR_MODULE, ERROR_LINE, "MTSCMConfig::Start()");

    }
	}
	return bRetVal;
}

/////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////

BOOL MTSCMConfig::WaitForAction(BOOL bStart)
{
  BOOL bGuard=FALSE;
  BOOL bRetVal = TRUE;
  DWORD running_state = (bStart == TRUE) ? SERVICE_START_PENDING : SERVICE_STOP_PENDING;
  DWORD done_state = (bStart == TRUE) ? SERVICE_RUNNING : SERVICE_STOPPED;
  SERVICE_STATUS aStatus;


  do {
    QueryServiceStatus(mServiceHandle,&aStatus);
    ::Sleep(1000);

    if(aStatus.dwCurrentState == done_state) {
			if(aStatus.dwWin32ExitCode != NO_ERROR) {
				DWORD retval = (aStatus.dwWin32ExitCode == ERROR_SERVICE_SPECIFIC_ERROR) ? 
					aStatus.dwServiceSpecificExitCode : aStatus.dwWin32ExitCode;
				SetError(retval,ERROR_MODULE, ERROR_LINE, "MTSCMConfig::WaitForAction()");
			}
			bGuard = TRUE;
    }
  }while(!bGuard);

  return bRetVal;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: MTSCMConfig::StopDependentServices
// Description	  : Stop all dependent services of the current service
// Return type		: BOOL 
/////////////////////////////////////////////////////////////////////////////

const int gNumEnumArrayEntries = 50;

BOOL MTSCMConfig::StopDependentServices()
{
	BOOL bRetVal;
	DWORD dBytesNeeded;
	DWORD aNumReturned;

	// have to choose something for the size!
	ENUM_SERVICE_STATUS aEnumArray[gNumEnumArrayEntries];

	// step 1: get the list of dependent services
	bRetVal = EnumDependentServices(mServiceHandle,
		SERVICE_ACTIVE, // all active services
		&aEnumArray[0],
		gNumEnumArrayEntries*sizeof(gNumEnumArrayEntries),
		&dBytesNeeded,
		&aNumReturned);

	if(bRetVal) {
		// step 2: enumerate through the services and stop them

		for(unsigned int i=0;i<aNumReturned;i++) {
			_bstr_t ServiceName;
			ServiceName = aEnumArray[i].lpServiceName;

			MTSCMConfig aService(ServiceName);
			bRetVal = aService.Stop();
			if(!bRetVal) break;
		}
	}

	return bRetVal;
}

/////////////////////////////////////////////////////////////////
//Stop
//
// Sends the stop message to the SCM and waits for it to finish
/////////////////////////////////////////////////////////////////

BOOL MTSCMConfig::Stop()
{
	// if the service does not exist, return TRUE
	BOOL bRetVal = mError == ERROR_SERVICE_DOES_NOT_EXIST;

	if(!bRetVal) {
		if(mpInstance && mServiceHandle) {

			bRetVal = StopDependentServices();

			if(bRetVal) {

				SERVICE_STATUS aServiceStatus;

				bRetVal = ControlService(mServiceHandle,SERVICE_CONTROL_STOP,&aServiceStatus);
				if(bRetVal) {
					bRetVal = WaitForAction(FALSE);
				}

				else {
					// if the service does not exist or is not started, do not return an error
					DWORD error = ::GetLastError();
					bRetVal = (error == ERROR_SERVICE_NOT_ACTIVE ||
									 error == ERROR_SERVICE_DOES_NOT_EXIST);

					if(!bRetVal) {
						SetError(error,ERROR_MODULE, ERROR_LINE, "MTSCMConfig::Stop");
					}
				}
			}
		}
	}
	
	return bRetVal;
}

/////////////////////////////////////////////////////////////////
// Delete Service
//
// This function does not fail if the service does NOT exist.
/////////////////////////////////////////////////////////////////

BOOL MTSCMConfig::DeleteService()
{
	BOOL bRetVal = TRUE;
	// step 1: open the specific service

	if(mServiceHandle != NULL) {
		// step 2: delete the service
		bRetVal = ::DeleteService(mServiceHandle);
		::CloseServiceHandle(mServiceHandle);
		mServiceHandle = NULL;
	}

	return bRetVal;
}

/////////////////////////////////////////////////////////////////
// InstallService
/////////////////////////////////////////////////////////////////


BOOL MTSCMConfig::InstallService(const char* pServiceName,
																 const char* pBinFile,
																 const char* pDependencyList)
{
	BOOL bRetVal;

	// step 2: delete the service if it allready existed
	bRetVal = DeleteService();


		// step 3: create the new service
	if(bRetVal) {

		SC_HANDLE schService =
			::CreateServiceA(
				mpInstance->GetHandle(), // SCManager database
				mServiceName.c_str(),							  // name of service
				pServiceName,							  // service name to display
				SERVICE_ALL_ACCESS,				  // desired access
				SERVICE_WIN32_OWN_PROCESS, // service type
				SERVICE_DEMAND_START,			// start type
				SERVICE_ERROR_NORMAL,			// error control type
				pBinFile,									// service's binary
				NULL,											// no load ordering group
				NULL,											// no tag identifier
				pDependencyList,					// no dependencies
				NULL,											// LocalSystem account
				NULL);										// no password

		if(!schService)
			bRetVal = FALSE;

		::CloseServiceHandle(schService);
	}

	return bRetVal;
}
