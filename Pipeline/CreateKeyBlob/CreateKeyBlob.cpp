/**************************************************************************
 * @doc CreateKeyBlob
 *
 * Copyright 1997 - 2001 by MetraTech Corporation
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
 * Created by: Chen He
 *
 * $Date: 9/11/2002 9:28:32 AM$
 * $Author: Alon Becker$
 * $Revision: 4$
 ***************************************************************************/

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif

#include <OBJBASE.H>
#include <mtcom.h>
#include <conio.h>

#include "MTUtil.h"
#include <metra.h>
#include <AdapterLogging.h>
#include <mtcryptoapi.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

#define CREATEKEYBLOBDRIVER_LOG_TAG	"[CreateKeyBlobDriver]"

ComInitialize gComInit;

class CreateKeyBlobDriver
{
public:
	CreateKeyBlobDriver();
	virtual ~CreateKeyBlobDriver();

  BOOL ParseArgs (int argc, char* argv[]);

	BOOL Execute();

private:
	NTLogger mLogger;
	CMTCryptoAPI mCrypto;
};


CreateKeyBlobDriver::CreateKeyBlobDriver()
{
	// initialize the logger ...
	LoggerConfigReader cfgRdr;
	mLogger.Init (cfgRdr.ReadConfiguration("CreateKeyBlobDriver"), 
								CREATEKEYBLOBDRIVER_LOG_TAG);
}

CreateKeyBlobDriver::~CreateKeyBlobDriver()
{
}


BOOL CreateKeyBlobDriver::ParseArgs(int argc, char* argv[])
{
	return TRUE;
}


BOOL CreateKeyBlobDriver::Execute()
{

	int result = mCrypto.CreateKeys("metratechpipeline", true, "pipeline");
	if (result == 0)
	{
      result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_ServiceDefProp, "metratechpipeline", TRUE, "pipeline");
  }
	
	if (result != 0)
	{
		char chrBuf[1024];
		sprintf(chrBuf, 
						"Unable to initialize crypto functions: %x: %s",
						result,
						mCrypto.GetCryptoApiErrorString());

		mLogger.LogThis (LOG_ERROR, chrBuf);

		return FALSE;
	}

	mLogger.LogThis (LOG_INFO, "Pipeline Keyblob created successfully.");
 
	return TRUE;
}


int main(int argc, char * argv[])
{
	CreateKeyBlobDriver createKeyBlobObj;

	if (!createKeyBlobObj.ParseArgs(argc, argv))
	{
	  return -1;
	}

	if (!createKeyBlobObj.Execute())
	{
	  return -1;
	}

	return 0;
}
