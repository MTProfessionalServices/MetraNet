/**************************************************************************
 * @doc CMDSTAGE
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
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#define _WIN32_DCOM
#include <windows.h>


#include <metra.h>

#include <mtcom.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTConfigLib.tlb"

#include <harness.h>

#include <multi.h>
#include <mtprogids.h>
#include <domainname.h>
#include <pluginconfig.h>
#include <mtglobal_msg.h>
#include <ConfigDir.h>
#include <makeunique.h>
#include <multiinstance.h>
#include <mtcomerr.h>
#include <LogServerInstance.h>
#include <autoptr.h>
#include <PipelineApplication.h>

ComInitialize gComInitialize;

HANDLE gMessagePumpEventHandle;

class StageExecutable : public PipelineApplication
{
public:
	int Run();
	BOOL ParseArgs(int argc, char * argv[]);
	void Usage();

private:
	BOOL mTestInit;
	BOOL mTestStartup;
	BOOL mMaxSessions;
	BOOL mRunAutoTests;
	BOOL mStartAsleep;

	std::string mRouteFrom;
	std::string mConfigPath;
	std::list<std::string> mStageNames;

	const char * mpLogin;
	const char * mpPassword;
	const char * mpDomain;
};

void PrintError(NTLogger& logger, const char * apStr, const ErrorObject * obj)
{
  if (obj)
  {
 	  char errText[1024];
    sprintf(errText, "%s: %X", apStr, obj->GetCode());
    logger.LogThis(LOG_FATAL, errText);

    // Log error.
   	string message;
	  obj->GetErrorMessage(message, true);
    string logText = message;
    logText += " (" + obj->GetProgrammerDetail() + ")";
    logger.LogThis(LOG_FATAL, logText.c_str());

    // Output error.
	  cout << errText << endl;
    cout << logText << endl;
	  cout << message;
  
	  const std::string & detail = obj->GetProgrammerDetail().c_str();
	  cout << "(" << detail << ')' << endl;
	  if (strlen(obj->GetModuleName()) > 0)
		  cout << " module: " << obj->GetModuleName() << endl;
	  if (strlen(obj->GetFunctionName()) > 0)
		  cout << " function: " << obj->GetFunctionName() << endl;
	  if (obj->GetLineNumber() != -1)
		  cout << " line: " << obj->GetLineNumber() << endl;
  	
    char * theTime = ctime(obj->GetErrorTime());
	  cout << " time: " << theTime << endl;
  }
  else
      cout << apStr << endl;
}

int StageExecutable::Run()
{
	// we don't actually log here but we do test it out
	NTLogger logger;
	LoggerConfigReader configReader;
	if (!logger.Init(configReader.ReadConfiguration("logging"), "[cmdstage]"))
	{
		cout << "Unable to log messages - check logging configuration" << endl;
		return -1;
	}


	if (mpLogin)
		cout << "Login is " << mpLogin << endl;

	if (mTestInit)
		cout << "Testing only initialization." << endl;
	if (mTestStartup)
		cout << "Testing only system startup." << endl;
	if (mMaxSessions != -1)
		cout << "Testing only " << mMaxSessions << " messages." << endl;

	if (mRouteFrom.length() > 0)
		cout << "Forcing routing from queue " << mRouteFrom << endl;

	MultiInstanceSetup multiSetup;
	if (!multiSetup.SetupMultiInstance(mpLogin, mpPassword, mpDomain))
	{
		PrintError(logger, "Multi-instance setup failed", multiSetup.GetLastError());
		return -1;
	}

	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		cout << "Configuration directory not set in the registry." << endl;
		return -1;
	}

	// lock an instance of the logserver in memory
	MTLogServerInstance aInstance;

	if (mpLogin)
		cout << "Configuration directory: " << configDir << endl;


	time_t startTime = time(NULL);

	try
	{
		cout << "View log file for more information." << endl;
		cout << "Initializing stage harness..." << endl;
    PipelineStageHarnessFactory stageFactory;
    MTautoptr<PipelineStageHarnessBase> stage(stageFactory.Create(configDir.c_str(), mStageNames, mStartAsleep));
		if (!stage)
		{
			PrintError(logger, "Unable to initialize", stageFactory.GetLastError());
			return -1;
		}

		// return if only testing the initialization code
		if (mTestInit)
			return 0;

		if (!stage->PrepareStage(mRouteFrom.c_str(), mRunAutoTests))
		{
			PrintError(logger, "Unable to prepare stage.  Error code", stage->GetLastError());
			return -1;
		}

		// return if only testing the startup code
		if (mTestStartup)
		{
			time_t now = time(NULL);
			__int64 seconds = now - startTime;
			cout << "Uptime: " << seconds << " seconds." << endl;
			return 0;
		}

		if (!stage->MainLoop(mMaxSessions))
		{
			PrintError(logger, "Stage main loop failed", stage->GetLastError());
			return -1;
		}

		return 0;
	}
	catch (_com_error & err)
	{
		std::string buffer;
		StringFromComError(buffer, "Stage failure", err);

		logger.LogThis(LOG_FATAL, buffer.c_str());

		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;


		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "  Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "  Source: " << (const char *) src << endl;
		return -1;
	}

	catch (...)
	{
		logger.LogThis(LOG_FATAL, "Caught ... - unexpected failure");
#ifdef DEBUG
		throw;
#else // DEBUG
		return -1;
#endif //DEBUG
	}
}

void StageExecutable::Usage()
{
	cout << "stage name required." << endl;
	cout << "usage: cmdstage stage-name [-routefrom queuename] [-testinit] [-teststart]"
		" [-test n] [-login name] [-password password] [-domain domain]" << endl;
	cout << "  -routefrom forces routing from the specified queue." << endl;
	cout << "  -testinit performs initialization, then quits (for memory leak testing)."
			 << endl;
	cout << "  -teststart performs all startup code then quits (for memory leak testing)."
			 << endl;
	cout << "  -test n processes only n sessions, where n is an integer (for " << endl;
	cout << "        memory leak testing)." << endl;
	cout << "  -login causes the stage to impersonate the given user, for" << endl;
	cout << "        multi-instance use." << endl;
	cout << "  -password give the password for -login.  For multi-instance use." << endl;
	cout << "  -domain give the domain for -login.  For multi-instance use." << endl;
}

BOOL StageExecutable::ParseArgs(int argc, char * argv[])
{
	if (argc < 2)
		return FALSE;

//	mStageName = argv[1];


	mTestStartup = FALSE;
	mTestInit = FALSE;
	const char * login = NULL;
	const char * password = NULL;
	const char * domain = NULL;

	mRunAutoTests = TRUE;
	mStartAsleep = FALSE;

	// negative means test forever
	mMaxSessions = -1;
	int i = 1;
	while (i < argc)
	{
		//cout << "additional argument: " << argv[i] << endl;
		if (0 == strcmp(argv[i], "-teststart"))
			mTestStartup = TRUE;
		else if (0 == strcmp(argv[i], "-testinit"))
			mTestInit = TRUE;
		else if (0 == strcmp(argv[i], "-test"))
		{
			i++;
			if (i >= argc)
			{
				cout << "number of test sessions required after -test" << endl;
				return FALSE;
			}
			mMaxSessions = atoi(argv[i]);
		}
		else if (0 == strcmp(argv[i], "-noauto"))
			mRunAutoTests = FALSE;
		else if (0 == strcmp(argv[i], "-sleep"))
			mStartAsleep = TRUE;
		else if (0 == strcmp(argv[i], "-routefrom"))
		{
			i++;
			if (i >= argc)
			{
				cout << "routing queue required after -routefrom" << endl;
				return FALSE;
			}
			mRouteFrom = argv[i];
		}
		else if (0 == strcmp(argv[i], "-login"))
		{
			i++;
			if (i >= argc)
			{
				cout << "login name required after -login" << endl;
				return FALSE;
			}
			login = argv[i];
		}
		else if (0 == strcmp(argv[i], "-password"))
		{
			i++;
			if (i >= argc)
			{
				cout << "password required after -password" << endl;
				return FALSE;
			}
			password = argv[i];
		}
		else if (0 == strcmp(argv[i], "-domain"))
		{
			i++;
			if (i >= argc)
			{
				cout << "domain required after -domain" << endl;
				return FALSE;
			}
			domain = argv[i];
		}
		else if (argv[i][0] != '-')
		{
			std::string name(argv[i]);
			mStageNames.push_back(name);
		}
    else
    {
      cout << "unrecognized command line option: " << argv[i] << endl;
				return FALSE;
    }
		i++;
	}

	mpLogin = login;
	mpPassword = password;
	mpDomain = domain;
	return TRUE;
}


//
// NOTE: this thread is used to read windows messages correctly.
// some versions of oleaut32 create a hidden window that doesn't read
// from the message queue.  See Microsoft Knowledge Base article
// "PRB: Oleaut32 Hidden Window Blocks Apps Broadcasting Messages"
// for info and this code.
//
DWORD WINAPI MessagePump(LPVOID pInputParam)
{
	HRESULT hr = S_OK;
	// Initialize COM with Mutithreaded.
	//hr = CoInitializeEx(NULL,COINIT_MULTITHREADED);

	VARIANT var, var1;

	VariantInit(&var);
	VariantInit(&var1);
	BSTR str = SysAllocString(L"Test");
	var.vt = VT_BSTR;
	var.bstrVal = str;

	// This will create a hidden window in this thread.
	hr = VariantChangeType(&var, &var, 0, VT_I2);

	// Set the global event.
	SetEvent(gMessagePumpEventHandle);

	VariantClear(&var);
	VariantClear(&var1);

	MSG msg;

	// msg-pump.
	while (GetMessage(&msg, NULL, 0, 0))
	{
		// This was the message -- time to work.
		if ( msg.message == WM_USER+1)
		{
			// When done:
      break;
		}
		else
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

	//CoUninitialize();
	return 0;
}



BOOL StartMessagePump(DWORD & arThreadID, HANDLE & arThread)
{
	// Create a global Event.
	gMessagePumpEventHandle = CreateEvent(NULL, FALSE, FALSE, NULL);
	if (gMessagePumpEventHandle == NULL)
		return FALSE;

	// Spin the secondary thread.
	arThread = CreateThread(NULL, 0,(LPTHREAD_START_ROUTINE) MessagePump,
												 0, 0, &arThreadID);
	if (arThread == NULL)
		return FALSE;

	DWORD ret;
	// Wait until the event is set in the secondary thread.
	ret = WaitForSingleObject(gMessagePumpEventHandle, INFINITE);
	if (ret != WAIT_OBJECT_0)
		return FALSE;

	::CloseHandle(gMessagePumpEventHandle);

	return TRUE;
}


int main(int argc, char * argv[])
{
	DWORD dwThreadID;
	HANDLE hThread;

	if (!StartMessagePump(dwThreadID, hThread))
	{
		cout << "Unable to start message pump thread" << endl;
		return -1;
	}

	StageExecutable executable;
	if (!executable.ParseArgs(argc, argv))
	{
		executable.Usage();
		return 1;
	}

	int val = executable.Run();

	// Clean up the message pump thread.
	PostThreadMessage(dwThreadID, WM_USER + 1, 0, 0);
	WaitForSingleObject(hThread, INFINITE);
	CloseHandle(hThread);

	return val;
}
