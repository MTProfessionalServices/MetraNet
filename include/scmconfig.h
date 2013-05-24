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


#ifndef __SCMCONFIG_H_
#define __SCMCONFIG_H_
	
#include <string>

class MTSCMInstance {
private:

public:
	MTSCMInstance() : mHandle(NULL) {}
	~MTSCMInstance();
	BOOL Init();

	// if Init works, GetHandle will return a valid result
	SC_HANDLE GetHandle() { return mHandle; }

protected:
	SC_HANDLE mHandle;
};

class MTSCMConfig : public ObjectWithError {


public:
	MTSCMConfig(const char* ServiceName);
	~MTSCMConfig();

	BOOL Start();
  BOOL WaitForAction(BOOL bStart=TRUE);
	BOOL InstallService(const char* pServiceName,const char* pBinFile,const char* pDependencyList);
	BOOL DeleteService();
	BOOL Stop();
	BOOL StopDependentServices();

protected:
	SC_HANDLE mServiceHandle;
	std::string mServiceName;
  MTSCMInstance* mpInstance;
	DWORD mError;
};


#endif // __SCMCONFIG_H_