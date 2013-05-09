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
 * $Header: C:\mt\development\SDK\localmodetest\test.cpp, 8, 7/29/2002 11:49:00 AM, David Blair$
 ***************************************************************************/

#include <metra.h>
//#include <mtcom.h>

// #include <comdef.h>
//#include <mtprogids.h>
#include <iostream>

#ifdef WIN32
#include <NTThreadLock.h>
#endif

//#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
//using namespace MTPipelineLib;

//#import <MTConfigLib.tlb>

#define MTSDK_DLL_EXPORT				// don't import or export anything
//#include <../include/sdkcon.h>

#include <../include/mtlocalmode.h>

#include <threadtest.h>

#include <sessionsconfig.h>

#include <stdio.h>

using std::cout;
using std::endl;

//static ComInitialize gComInitialize;

class LocalModeAutoSDK 
{
public:

	LocalModeAutoSDK()
	  :	mVerbose(FALSE),
		mMeter(mConfig)
	{ }

	int SimpleTest(int argc, char * * argv);




private:
	virtual BOOL TestMeterStore(const char* szFile);
	virtual BOOL TestRecord();
	virtual BOOL TestPlayback(char * szFile);
	virtual BOOL Setup(int argc, char ** argv);

	BOOL ReadTestSetup(const char * apTestFile);
	void PrintError(const char * prefix, const MTMeterError * err);
	MTMeterSession * CreateTestSession(MTMeterSession * apParent, TestSession & arSession);

private:

	TestSessions mTestSessions;

#ifdef WIN32
	NTThreadLock mLock;
#endif

  // configuration object - used to initialize the Metering SDK
	// with HTTP transport
	MTMeterFileConfig mConfig;

	// the entry point to the Metering SDK - all Metering objects
	// are created from here.
	MTMeter mMeter;

	BOOL mVerbose;
};

int LocalModeAutoSDK::SimpleTest(int argc, char * * argv)
{
	mVerbose = TRUE;

	if((argc > 1) && (0 == strcmp(argv[1], "testmeterstore")))
	{
		return TestMeterStore(argv[2]);
	}

	if (!Setup(argc, argv))
		return -1;
	
	if (!strcmp(argv[1], "record"))
		return TestRecord() ? 0 : -1;
	else
		return TestPlayback(argv[3]) ? 0 : -1;
}


BOOL
LocalModeAutoSDK::Setup(int argc, char** argv)
{
	// 0				1				2                3      
	// LocalModeTest  record/playback autotestfile/host recordfile
	//                testmeterstore
	if (argc < 2)
	{
		cout << "usage: " << argv[0] << " record   filename.xml recordfile <meterstore>" << endl;
		cout << "usage: " << argv[0] << " playback hostname     recordfile <meterstore>" << endl;
		cout << "usage: " << argv[0] << " testmeterstore <meterstore>" << endl;
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

	char * host = "";
	if (!strcmp (argv[1], "record"))
	{
		if (!ReadTestSetup(argv[2]))
			return FALSE;
		strcpy (host, "dummy");
		mConfig.SetMeterFile (argv[3]);		
	}
	else
	{
		strcpy (host, argv[2]);
	}

	

	if (!mConfig.AddServer(0,			// priority (highest)
					host,			// hostname
					80,				// port (default plaintext HTTP)
					FALSE,			// secure? (no)
					"",				// username
					""))			// password
	{
		MTMeterError * err = mMeter.GetLastErrorObject();
		PrintError("ould not set SDK configuration properties: ", err);
		delete err;
		return FALSE;
	}

	if (argv[4])
		mConfig.SetMeterStore (argv[4]);

	
	return TRUE;
}

BOOL
LocalModeAutoSDK::TestPlayback(char * szFile)
{
	if (!mMeter.MeterFile (szFile))
	{
			MTMeterError * err = mMeter.GetLastErrorObject();
			PrintError("Unable to meter file", err);
			delete err;
			return false;
	}
	else 
		return TRUE;
};

BOOL LocalModeAutoSDK::TestMeterStore(const char* szFile)
{
	if((szFile == NULL) || (*szFile == 0))
		szFile = "test_meter_store";

	BOOL bRes = TRUE;

	{
		// create new meter store file
		remove(szFile);
		MTMeterStore mts(szFile);
		
		bRes = bRes && mts.MarkInProgress("aaaa");
		bRes = bRes && mts.IsInProgress("aaaa");

		bRes = bRes && mts.MarkInProgress("bbbb");
		bRes = bRes && mts.IsInProgress("bbbb");

		bRes = bRes && mts.MarkInProgress("cccc");
		bRes = bRes && mts.IsInProgress("cccc");

		bRes = bRes && mts.MarkComplete("aaaa");
		bRes = bRes && mts.IsComplete("aaaa");
		bRes = bRes && !mts.IsInProgress("aaaa");

		bRes = bRes && !mts.IsInProgress("eeee");
		bRes = bRes && !mts.IsComplete("eeee");

		// meter store is closed in MTMeterStore destructor.
	}

	{
		// open existing meter store file
		MTMeterStore mts(szFile);
		
		bRes = bRes && mts.IsComplete("aaaa");
		bRes = bRes && mts.IsInProgress("bbbb");
		bRes = bRes && mts.IsInProgress("cccc");

		bRes = bRes && mts.MarkComplete("bbbb");
		bRes = bRes && mts.IsComplete("bbbb");
		bRes = bRes && !mts.IsInProgress("bbbb");

		bRes = bRes && !mts.IsInProgress("eeee");
		bRes = bRes && !mts.IsComplete("eeee");

		// meter store is closed in MTMeterStore destructor.
	}

	if(bRes)
		cout << "meter store test successfull" << endl;
	else
		cout << "meter store test failed" << endl;

	return bRes;
}


BOOL
LocalModeAutoSDK::TestRecord()
{

#ifdef WIN32
	mLock.Lock();
#endif

	BOOL success = TRUE;

	// service name is "metratech.com/TestService"
	TestSessionList & list = mTestSessions.GetTestSessions();
	TestSessionListIterator sessit(list);
	while (sessit())
	{
		TestSession * test = sessit.key();

		MTMeterSession * session = CreateTestSession(NULL, *test);
		if (!session)
		{
			success = FALSE;
			break;
		}

		if (mVerbose)
			cout << "Closing session..." << endl;

		// send the session to the server
		if (!session->Close())
		{
			MTMeterError * err = session->GetLastErrorObject();
			delete session;
			PrintError("Unable to close session", err);
			delete err;

			//return -1; // DY
			success = FALSE;
			break;
		}

		if (mVerbose)
			cout << "Session closed." << endl;

		// sessions created with CreateSession must be deleted.
		delete session;
	}

#ifdef WIN32
	mLock.Unlock();
#endif
	return success;
}

MTMeterSession * LocalModeAutoSDK::CreateTestSession(MTMeterSession * apParent,
																						TestSession & arSession)
{
	if (mVerbose)
		cout << "Session has service name " << arSession.GetServiceName() << endl;

	MTMeterSession * session;
	if (apParent)
		session = apParent->CreateChildSession(arSession.GetServiceName());
	else
		session = mMeter.CreateSession(arSession.GetServiceName());

	if (!session)
		return NULL;

	// now set properties listed in the file
	TestPropList & inputs = arSession.GetInputProps();
	TestPropListIterator it(inputs);
	while (it())
	{
		TestProp * testProp = it.key();

		const RWCString & name = testProp->GetName();
		/*
		MTConfigLib::PropValType type = testProp->GetValType();
		_variant_t value = testProp->GetValue();
		*/

		ValType::Type type = testProp->GetPropType();
		
		if (mVerbose)
			cout << " Setting property " << name << endl;

		BOOL status;
		switch (type)
		{
		case ValType::TYPE_INTEGER:
			status = session->InitProperty(name, testProp->GetInt());
			break;
		case ValType::TYPE_DOUBLE:
			status = session->InitProperty(name, testProp->GetDouble());
			break;
		case ValType::TYPE_STRING:
			status = session->InitProperty(name, testProp->GetString().c_str());
			break;
		case ValType::TYPE_DATETIME:
			status = session->InitProperty(name, testProp->GetDateTime());
			break;

		case ValType::TYPE_TIME:
		case ValType::TYPE_BOOLEAN:
		  //		case ValType::TYPE_SET:
		case ValType::TYPE_DEFAULT:
		case ValType::TYPE_UNKNOWN:
		default:
			cout << "Unknown prop type for " << name << endl;
			break;
		}

		if (!status)
		{
			MTMeterError * err = session->GetLastErrorObject();
			PrintError("Error setting property ", err);
			delete err;
			return NULL;
		}
	}

	TestSessionListIterator childit(arSession.GetSubSessions());
	while (childit())
	{
		if (mVerbose)
			cout << "Creating child session..." << endl;
		TestSession * subsession = childit.key();
		MTMeterSession * childtest = CreateTestSession(session, *subsession);
		if (!childtest)
		{
			// TODO: is this OK to do?
			delete session;
			return NULL;
		}
	}

	return session;
}


BOOL LocalModeAutoSDK::ReadTestSetup(const char * apTestFile)
{
  //MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	TestSessionsReader testReader;
	// if (!testReader.ReadConfiguration(config, apTestFile, mTestSessions))
	 if (!testReader.ReadConfiguration(apTestFile, mTestSessions))
	{
		cout << "Unable to read test configuration " << apTestFile << endl;

		const ErrorObject * obj = testReader.GetLastError();
		if (obj)
			cout << "Details: " << obj->GetProgrammerDetail().c_str();

		return FALSE;
	}

	return TRUE;
}

void LocalModeAutoSDK::PrintError(const char * prefix, const MTMeterError * err)
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
	// localmodetest record		autotestfile recordfile
	// localmodetest playback	host		 recordfile

	LocalModeAutoSDK test;
	return test.SimpleTest(argc, argv);
	

}

