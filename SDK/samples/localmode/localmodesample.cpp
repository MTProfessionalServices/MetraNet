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
 * Created by: Derek Young
 * $Header: C:\mt\development\SDK\samples\localmode\localmodesample.cpp, 7, 7/29/2002 11:48:46 AM, David Blair$
 ***************************************************************************/


#include "mtsdk.h"
#include "sdk_msg.h"
#include <iostream>

#ifdef UNIX
#include <strings.h>
#endif


#include <stdio.h>


using std::cin;
using std::cout;
using std::endl;
using std::hex;
using std::dec;

class LocalModeSample 
{
public:

	LocalModeSample()
	  :	mVerbose(FALSE),
		mMeter(mConfig)
	{ }

	int SimpleTest(int argc, char * * argv);




private:
	virtual BOOL TestRecord();
	virtual BOOL TestPlayback(char * szFile);
	virtual BOOL Setup(int argc, char ** argv);
	void PrintError(const char * prefix, const MTMeterError * err);

private:


  // configuration object - used to initialize the Metering SDK
	// with HTTP transport
	MTMeterFileConfig mConfig;

	// the entry point to the Metering SDK - all Metering objects
	// are created from here.
	MTMeter mMeter;

	BOOL mVerbose;
};

int LocalModeSample::SimpleTest(int argc, char * * argv)
{
	mVerbose = TRUE;
	BOOL bStatus;

	if (!Setup(argc, argv))
		return -1;
	
	if (!strcmp(argv[1], "record"))
	{
		bStatus = TestRecord();
		cout << endl << "Session Recording " << (bStatus ? "Succeeded" : "Failed") << endl;
		return bStatus ? 0 : -1;
	}
	else
	{
		bStatus = TestPlayback(argv[3]);
		cout << endl << "Session Playback " << (bStatus ? "Succeeded" : "Failed") << endl;
		return bStatus ? 0 : -1;
	}
}


BOOL
LocalModeSample::Setup(int argc, char** argv)
{
	// 0				1				2                3      
	// LocalModeTest  record/playback autotestfile/host recordfile
	if (argc < 3)
	{
		cout << "usage: " << argv[0] << " record   recordfile <meterstore>" << endl;
		cout << "usage: " << argv[0] << " playback hostname   recordfile   <meterstore>" << endl;
		return FALSE;
	}


	// initialize the SDK
	if (!mMeter.Startup())
	{
		MTMeterError * err = mMeter.GetLastErrorObject();
		PrintError("Could not initialize the SDK: ", err);
		delete err;
		return FALSE;
	}

	char host[256];

	if (!strcmp (argv[1], "record"))
	{
		strcpy (host, "dummy");
		mConfig.SetMeterFile (argv[2]);		
		if (argv[3])
			mConfig.SetMeterStore (argv[3]);
	}
	else
	{
		strcpy (host, argv[2]);
		if (argv[4])
			mConfig.SetMeterStore (argv[4]);
	}

	

	if (!mConfig.AddServer(0,			// priority (highest)
					host,			// hostname
					80,				// port (default plaintext HTTP)
					FALSE,			// secure? (no)
					"",				// username
					""))			// password
	{
		MTMeterError * err = mMeter.GetLastErrorObject();
    PrintError("Could not set SDK configuration properties: ", err);
    delete err;
    return FALSE;
	}


	
	return TRUE;
}

BOOL
LocalModeSample::TestPlayback(char * szFile)
{
	if (!mMeter.MeterFile (szFile))
	{
			MTMeterError * err = mMeter.GetLastErrorObject();
			PrintError("Unable to meter file", err);
			delete err;
			return FALSE;
	}
	else 
		return TRUE;
};

BOOL
LocalModeSample::TestRecord()
{

  // read the user's account name
  cout << "Account Name: ";
  char accountname[256];
  cin.getline(accountname, sizeof(accountname));
  
  // read the description
  cout << "Transaction description: ";
  char desc[256];
  cin.getline(desc, sizeof(desc));
  
  // read the units
  cout << "Units (floating point number): ";
  float units;
  cin >> units;

  // service name is "metratech.com/TestService"
  MTMeterSession * session = mMeter.CreateSession("metratech.com/TestService");

  
  // set the session's time field to the current time.
  time_t t = time(NULL);
  
  // these property names have to match those on the server
  if (!session->InitProperty("AccountName", accountname)
    || !session->InitProperty("Description", desc)
    || !session->InitProperty("Units", units)
      || !session->InitProperty("Time", t, MTMeterSession::SDK_PROPTYPE_DATETIME))
  {
    MTMeterError * err = session->GetLastErrorObject();
	PrintError("InitProperty failed", err);
    delete session;
    delete err;
	return FALSE;
  }
  
  // send the session to the server
  if (!session->Close())
  {
    MTMeterError * err = session->GetLastErrorObject();
	PrintError("Close Failed", err);
    delete session;
    delete err;
	return FALSE;
  }
  

  // sessions created with CreateSession must be deleted.
  delete session;
  
  // success!
  return TRUE;

}



void LocalModeSample::PrintError(const char * prefix, const MTMeterError * err)
{
	cout << prefix << ": ";
	if (err)
	{
		int size = 0;
		err->GetErrorMessage((char *) NULL, size);
		char * buf = new char[size];
		err->GetErrorMessage(buf, size);

		cout << hex << err->GetErrorCode() << dec << ": " << buf << endl;
		delete buf;
	}
	else
		cout << "*UNKNOWN ERROR*" << endl;
}


int 
main (int argc, char* argv[])
{
	// 0				1		2				3            
	// localmodetest record		recordfile
	// localmodetest playback	host		 recordfile

	LocalModeSample test;
	return test.SimpleTest(argc, argv);
	

}

