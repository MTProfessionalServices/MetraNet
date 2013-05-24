/**************************************************************************
 * @doc AUTOSDK
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
 *
 * $Date: 7/26/2002 1:34:13 PM$
 * $Author: Derek Young$
 * $Revision: 22$
 ***************************************************************************/

#include <metra.h>

#include <autosdklib.h>

#include <iostream>
using namespace std;

#ifdef WIN32
  ComInitialize gComInitialize;
#endif

class AutoSDK : public AutoSDKBase
{
public:
	AutoSDK(int aThreads, int aSerialCount, int aParallelCount, BOOL aSSL)
	  : AutoSDKBase(aThreads, aSerialCount, aParallelCount, aSSL),
			mMeter(mConfig)
	{ }

	AutoSDK(BOOL aSSL = FALSE)
	  : AutoSDKBase(aSSL),
			mMeter(mConfig)
	{ }

protected:
	virtual MTMeter & GetMeter();
	virtual MTMeterConfig & GetMeterConfig();

	// set mTestFilename and configure the SDK objects appropriately
	virtual BOOL ConfigureSDK(int argc, char * argv[]);

private:
	// configuration object - used to initialize the Metering SDK
	// with HTTP transport
	MTMeterHTTPConfig mConfig;

	// the entry point to the Metering SDK - all Metering objects
	// are created from here.
	MTMeter mMeter;
};


MTMeter & AutoSDK::GetMeter()
{
	return mMeter;
}

MTMeterConfig & AutoSDK::GetMeterConfig()
{
	return mConfig;
}


void Usage(const char * progname)
{
	cout << "usage: " << progname << " hostname filename.xml [ssl threads serial parallel username password]"
			 << endl;
	cout << "usage: " << progname << " hostname filename.xml [ssl threads serial parallel -b batchsize]"
			 << endl;
	cout << endl;
	cout << "      ssl       - if equal to the string ssl, use https.  Otherwise use http." << endl;
	cout << "      threads   - number of threads that should meter at one time." << endl;
	cout << "      serial    - number of sessions that should be metered in serial." << endl;
	cout << "      parallel  - number of sessions that should be metered in parallel." << endl;
	cout << "      username  - http username." << endl;
	cout << "      password  - http password." << endl;
	cout << "      batchsize - number of sessions to add to each batch." << endl;
	cout << endl << endl << "examples:" << endl << endl;
	cout << " meter without using ssl and with no username/password: " << endl;
	cout << "  " << progname << " myserver filename.xml" << endl;
	cout << " meter using ssl: " << endl;
	cout << "  " << progname << " myserver filename.xml ssl" << endl;
	cout << " meter using no ssl, but with a username and password: " << endl;
	cout << "  " << progname << " myserver filename.xml no 0 1 0 user pass" << endl;
	cout << " meter using no ssl, but with a username and password: " << endl;
	cout << "  " << progname << " myserver filename.xml no 0 1 0 user pass" << endl;

///	cout << "usage: " << progname << " hostname filename.xml port [ssl]"
///			 << endl;
}

BOOL
AutoSDK::ConfigureSDK(int argc, char * argv[])
{
	// 0       1     2        3       4       5      6         7   8
	// autosdk integ filename ssl     threads serial parallel	[-b  batchsize]
	// autosdk integ filename port    ssl

	if (argc < 3)
	{
		Usage(argv[0]);
		return FALSE;
	}

	const char * host = argv[1];
	const char * filename = argv[2];

	mTestFilename = filename;

	// initialize the SDK
	if (!mMeter.Startup())
	{
		MTMeterError * err = mMeter.GetLastErrorObject();
		PrintError("Could not initialize the SDK: ", err);
		delete err;
		return FALSE;
	}

	int port;
	if (mSSL)
		port = 443;
	else
		port = 80;

	if (argc == 4)
	{
		// port listed
		port = atoi(argv[3]);
		cout << "Connecting on port " << port << endl;
	}

	char* username = "";
	char* password = "";

	if (argc == 9 && 0 != strcmp(username, "-b"))
	{

		username = argv[7];
		password = argv[8];
	}

	if (!mConfig.AddServer(
				0,					// priority (highest)
				host,				// hostname
				port,				// port
				mSSL,				// secure?
				username,		// username
				password))	// password
	{
		MTMeterError * err = mMeter.GetLastErrorObject();
		PrintError("Could not set SDK configuration properties: ", err);
		delete err;
		return FALSE;
	}

	return TRUE;
}


int 
main (int argc, char* argv[])
{
	// 0       1     2        3      4       5      6        7   8
	// autosdk integ filename ssl    threads serial parallel [-b 100]
	// autosdk integ filename port   ssl

	BOOL ssl = FALSE;
	if (argc > 3)
		ssl = (0 == strcmp(argv[3], "ssl"));

	if (argc == 7 || argc == 9)
	{
		int threads = atoi(argv[4]);
		int serial = atoi(argv[5]);
		int parallel = atoi(argv[6]);

		AutoSDK test(threads, serial, parallel, ssl);

		if (argc == 9)
		{
			if (0 == strcmp(argv[7], "-b"))
			{
				int batchsize = atoi(argv[8]);
				test.SetBatchSize(batchsize);
			}
		}
		test.RunTest(argc, argv);
	}
	else
	{
		AutoSDK test(ssl);
		return test.SimpleTest(argc, argv);
	}

	return 0;
}

