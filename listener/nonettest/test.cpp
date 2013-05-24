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
 * $Header$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

#include <autosdklib.h>

#import <MTConfigLib.tlb>

//imported in nonet.h
//#import <MTEnumConfig.tlb>

#include <nonet.h>

#include <iostream>

using std::cout;
using std::endl;

ComInitialize gComInitialize;

class NoNetAutoSDK : public AutoSDKBase
{
public:
	NoNetAutoSDK(int aThreads, int aSerialCount, int aParallelCount)
	  : AutoSDKBase(aThreads, aSerialCount, aParallelCount, FALSE),
			mMeter(mConfig)
	{ }

	NoNetAutoSDK(BOOL aSSL = FALSE)
	  : AutoSDKBase(aSSL),
			mMeter(mConfig)
	{ }

	void TestStream(const char * apFilename);
	void GenerateUID();

	virtual BOOL Setup(int argc, char** argv);
	virtual BOOL Test();


	BOOL mDirectTest;
	BOOL mBatchTest;

protected:
	virtual MTMeter & GetMeter();
	virtual MTMeterConfig & GetMeterConfig();

	// set mTestFilename and configure the SDK objects appropriately
	virtual BOOL ConfigureSDK(int argc, char * argv[]);

private:
  // configuration object - used to initialize the Metering SDK
	// with HTTP transport
	MTMeterNoNetConfig mConfig;

	// the entry point to the Metering SDK - all Metering objects
	// are created from here.
	MTMeter mMeter;

	std::string mDirectBuffer;

	unsigned char * mBatchBuffer;
	int mBatchSize;
};


void NoNetAutoSDK::GenerateUID()
{
	string uid;
	MSIXUidGenerator::Generate(uid);

	cout << uid.c_str() << endl;
}



MTMeter & NoNetAutoSDK::GetMeter()
{
	return mMeter;
}

MTMeterConfig & NoNetAutoSDK::GetMeterConfig()
{
	return mConfig;
}


void Usage(const char * progname)
{
	cout << "usage: " << progname << " hostname filename.xml [threads serial parallel]"
			 << endl;
	cout << "usage: " << progname << " hostname filename.xml [threads serial parallel -b batchsize]"
			 << endl;
	cout << "usage: " << progname << " -uid"
			 << endl;
	cout << "usage: " << progname << " msixfile.xml"
			 << endl;
	cout << endl;
	cout << "      threads      - number of threads that should meter at one time." << endl;
	cout << "      serial       - number of sessions that should be metered in serial." << endl;
	cout << "      parallel     - number of sessions that should be metered in parallel." << endl;
	cout << "      batchsize    - number of sessions to add to each batch." << endl;
	cout << "      -uid         - generate a new unique ID (UID)" << endl;
	cout << "      msixfile.xml - raw MSIX file to meter" << endl;
	cout << endl << endl << "examples:" << endl << endl;
	cout << " meter without using ssl and with no username/password: " << endl;
	cout << "  " << progname << " myserver filename.xml" << endl;
	cout << " print out a UID " << endl;
	cout << "  " << progname << " -uid" << endl;
	cout << " meter straight MSIX " << endl;
	cout << "  " << progname << " mymsix.xml" << endl;

///	cout << "usage: " << progname << " hostname filename.xml port [ssl]"
///			 << endl;
}


BOOL
NoNetAutoSDK::ConfigureSDK(int argc, char * argv[])
{
	mDirectTest = FALSE;
	mBatchTest = FALSE;

	// 0         1        2       3      4
	// nonettest filename threads serial parallel
	if (argc == 5)
	{
		mDirectTest = TRUE;

		const char * host = "foo";
		const char * filename = argv[1];
		mTestFilename = filename;

		// initialize the SDK
		if (!mMeter.Startup())
		{
			MTMeterError * err = mMeter.GetLastErrorObject();
			PrintError("Could not initialize the SDK: ", err);
			delete err;
			return FALSE;
		}

		// TODO: can we get rid of this?
		mConfig.AddServer(0,			// priority (highest)
											host,			// hostname
											80,				// port (default plaintext HTTP)
											FALSE,			// secure? (no)
											"",				// username
											"");			// password

		return TRUE;
	}

	// 0         1  2        3       4      5
	// nonettest -b filename threads serial parallel
	if (argc == 6 && 0 == strcmp(argv[1], "-b"))
	{
		mBatchTest = TRUE;
		mDirectTest = FALSE;

		const char * host = "foo";
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

		// TODO: can we get rid of this?
		mConfig.AddServer(0,			// priority (highest)
											host,			// hostname
											80,				// port (default plaintext HTTP)
											FALSE,			// secure? (no)
											"",				// username
											"");			// password

		return TRUE;
	}

	// 0         1     2        3       4      5
	// nonettest integ filename threads serial parallel
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

	// TODO: can we get rid of this?
	mConfig.AddServer(0,			// priority (highest)
					host,			// hostname
					80,				// port (default plaintext HTTP)
					FALSE,			// secure? (no)
					"",				// username
					"");			// password

	return TRUE;
}


BOOL
NoNetAutoSDK::Setup(int argc, char** argv)
{
	mDirectTest = FALSE;
	mBatchTest = FALSE;

	// TODO: this is a hack to read the args like this

	// 0         1        2       3      4
	// nonettest filename threads serial parallel
	if (argc == 5)
	{
		mDirectTest = TRUE;
		mTestFilename = argv[1];
	}
	// 0         1  2        3       4      5
	// nonettest -b filename threads serial parallel
	else if (argc == 6 && 0 == strcmp(argv[1], "-b"))
	{
		mBatchTest = TRUE;
		mDirectTest = FALSE;
		mTestFilename = argv[2];
	}

	if (mDirectTest)
	{
		FILE * file = fopen(mTestFilename.c_str(), "r");
		if (!file)
		{
			cout << "Unable to open file" << endl;
			return FALSE;
		}

		char buffer[4096];
		while (TRUE)
		{
			int nread = fread(buffer, sizeof(char), sizeof(buffer), file);
			if (nread < 0)
			{
				fclose(file);
				cout << "Error reading file" << endl;
				return FALSE;
			}

			mDirectBuffer.append(buffer, nread);

			if (nread < sizeof(buffer))
				break;
		}

		fclose(file);
		return ConfigureSDK(argc, argv);
	}
	else if (mBatchTest)
	{
		FILE * file = fopen(mTestFilename.c_str(), "rb");
		if (!file)
		{
			cout << "Unable to open file" << endl;
			return FALSE;
		}

		if (fseek(file, 0, SEEK_END) != 0)
		{
			fclose(file);
			cout << "Unable to seek to end of file" << endl;
			return FALSE;
		}

		long size = ftell(file);

		if (fseek(file, 0, SEEK_SET) != 0)
		{
			fclose(file);
			cout << "Unable to seek to beginning of file" << endl;
			return FALSE;
		}


		mBatchBuffer = new unsigned char[size];
		mBatchSize = size;

		int nread = fread(mBatchBuffer, sizeof(char), size, file);
		if (nread < 0)
		{
			fclose(file);
			cout << "Error reading file" << endl;
			return FALSE;
		}

		fclose(file);
		return ConfigureSDK(argc, argv);
	}
	else
		// TODO: fix this case
		return AutoSDKBase::Setup(argc, argv);
}


BOOL
NoNetAutoSDK::Test()
{
	if (!mDirectTest && !mBatchTest)
	{
		return AutoSDKBase::Test();
	}
	else
	{
		if (mDirectTest)
		{
			std::string outputBuffer;
			if (!mConfig.HandleStream(mDirectBuffer, outputBuffer))
				cout << "HandleStream returned an error" << endl;
			else
			{
//			cout << "--- Result --- " << endl;
//			cout << outputBuffer << endl;
			}
			return TRUE;
		}
		else
			return FALSE;
	}
}


void NoNetAutoSDK::TestStream(const char * apFilename)
{
	// initialize the SDK
	if (!mMeter.Startup())
	{
		cout << "Could not initialize the SDK: " << endl;
		return;
	}

	mConfig.AddServer(0,			// priority (highest)
					"foo",			// hostname (doesn't matter)
					80,				// port (default plaintext HTTP)
					FALSE,			// secure? (no)
					"",				// username
					"");			// password

	FILE * file = fopen(apFilename, "r");
	if (!file)
	{
		cout << "Unable to open file" << endl;
		return;
	}

	std::string bufferStr;

	char buffer[4096];
	while (TRUE)
	{
    int nread = fread(buffer, sizeof(char), sizeof(buffer), file);
		if (nread < 0)
		{
			fclose(file);
			cout << "Error reading file" << endl;
      return;
    }

		bufferStr.append(buffer, nread);

    if (nread < sizeof(buffer))
      break;
	}

	fclose(file);

//	cout << "Testing buffer: " << bufferStr.c_str();

	std::string outputBuffer;
	if (!mConfig.HandleStream(bufferStr, outputBuffer))
		cout << "HandleStream returned an error" << endl;
	else
	{
		cout << "--- Result --- " << endl;
		cout << outputBuffer.c_str() << endl;
	}
}

int 
main (int argc, char* argv[])
{
	// 0       1     2        3       4      5
	// nonettest integ filename threads serial parallel

	// 0         1  2        3       4      5
	// nonettest -b filename threads serial parallel

	if (argc == 2)
	{
		NoNetAutoSDK test;

		if (0 == strcmp(argv[1], "-uid"))
			test.GenerateUID();
		else
			test.TestStream(argv[1]);
	}
	else if (argc == 5)
	{
		int threads = atoi(argv[2]);
		int serial = atoi(argv[3]);
		int parallel = atoi(argv[4]);

		NoNetAutoSDK test(threads, serial, parallel);
		test.RunTest(argc, argv);
	}
	else if (argc == 6 && 0 == strcmp(argv[1], "-b"))
	{
		int threads = atoi(argv[3]);
		int serial = atoi(argv[4]);
		int parallel = atoi(argv[5]);

		NoNetAutoSDK test(threads, serial, parallel);
		test.RunTest(argc, argv);
	}
	else if (argc > 3)
	{
		int threads = atoi(argv[3]);
		int serial = atoi(argv[4]);
		int parallel = atoi(argv[5]);

		NoNetAutoSDK test(threads, serial, parallel);
		test.RunTest(argc, argv);
	}
	else
	{
		NoNetAutoSDK test;
		return test.SimpleTest(argc, argv);
	}

	return 0;
}
