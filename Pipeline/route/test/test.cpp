/**************************************************************************
 * @doc TEST
 *
 * Copyright 1999 by MetraTech Corporation
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

#include <metra.h>
#include <mtcom.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTConfigLib.tlb"

#include <mtprogids.h>
#include <route.h>
#include <tpstimer.h>

#include <ConfigDir.h>

#include <iostream>
using namespace std;

ComInitialize gComInitialize;

class RouteTest : public NTThreader
{
public:
	int Test(int argc, char * argv[]);

	int ThreadMain();

	BOOL Init();

	void RouteMessageTest(const char * apFile, int aRepeatCount);

	void Startup(int aThreads);

private:
	static void ThreadFunc(void * apArg);
	

private:
	// timing info
	DWORD initialTicks;
	DWORD finalTicks;

	int mCount;

	NTThreadLock mLock;

private:
	SessionRouter router;

	MTPipelineLib::IMTSessionServerPtr sessionServer;
};


void PrintError(const char * apStr, const ErrorObject * obj)
{
	cout << apStr << ": " << hex << obj->GetCode() << dec << endl;
	string message;
	obj->GetErrorMessage(message, true);
	cout << message.c_str() << "(";
	const std::string & detail = obj->GetProgrammerDetail().c_str();
	cout << detail.c_str() << ')' << endl;

	if (strlen(obj->GetModuleName()) > 0)
		cout << " module: " << obj->GetModuleName() << endl;
	if (strlen(obj->GetFunctionName()) > 0)
		cout << " function: " << obj->GetFunctionName() << endl;
	if (obj->GetLineNumber() != -1)
		cout << " line: " << obj->GetLineNumber() << endl;

	char * theTime = ctime(obj->GetErrorTime());
	cout << " time: " << theTime << endl;
}


BOOL RouteTest::Init()
{
	// hold onto a name ID to speed up startup
	MTPipelineLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);

	ListenerInfoReader listenerReader;

	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		cout << "Configuration directory not set in the registry." << endl;
		return FALSE;
	}


	ListenerInfo listenerInfo;
	if (!listenerReader.ReadConfiguration(config, configDir.c_str(), listenerInfo))
	{
		cout << "could not read listener info" << endl;
		return FALSE;
	}


	PipelineInfoReader pipelineReader;
	PipelineInfo pipelineInfo;
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		cout << "could not read pipeline info" << endl;
		return FALSE;
	}


	MeterRoutes routeInfo;

	MeterRouteReader routeReader;
	if (!routeReader.ReadConfiguration(config, configDir.c_str(), routeInfo))
	{
		cout << "Unable to initialize route info" << endl;
		return FALSE;
	}


	// initialize the session server
	HRESULT hr = sessionServer.CreateInstance(MTPROGID_SESSION_SERVER);
	if (FAILED(hr))
	{
		cout << "Unable to initialize session server" << endl;
		return FALSE;
	}

	sessionServer->Init((const char *) pipelineInfo.GetSharedSessionFile().c_str(),
											(const char *) pipelineInfo.GetShareName().c_str(),
											pipelineInfo.GetSharedFileSize());


	const char * machine = NULL;
	const char * queue = "routingqueue";

	if (!router.Init(listenerInfo, pipelineInfo, machine, queue, FALSE, routeInfo, sessionServer))
	{
		PrintError("Unable to initialize router", router.GetLastError());
		return FALSE;
	}

	return TRUE;
}


int RouteTest::Test(int argc, char * argv[])
{
	const int THREADS = 1;
	for (int i = 0; i < THREADS; i++)
		StartThread();

	::Sleep(INFINITE);

	return 0;
}

void RouteTest::ThreadFunc(void * apArg)
{
	RouteTest * test = (RouteTest *) apArg;

	test->ThreadMain();

}

void RouteTest::Startup(int aThreads)
{
	router.SetParseOnly(TRUE);
//	router.SetParseOnly(FALSE);

	mCount = 0;
	initialTicks = 0;
	finalTicks = 0;

//	mLock.Init();

	for (int i = 0; i < aThreads; i++)
	{
		unsigned long hand = _beginthread(ThreadFunc, 0, this);

		cout << "Started thread " << hand << endl;
	}


	Sleep(INFINITE);
}


int RouteTest::ThreadMain()
{
	SessionRouterState state;
	if (!state.Init())
	{
			cout << "Unable to init router state" << endl;
			PrintError("Unable to init router state", state.GetLastError());
	}

#if 1
//	DWORD initialTicks;
//	DWORD finalTicks;

	static TimingInfo * gTimingInfo = new TimingInfo(10000);

	while (TRUE)
	{
		int count = 0;
		if (!router.RouteSession(state, &count))
		{
			cout << "Unable to route session" << endl;
			PrintError("Unable to route session", router.GetLastError());
			return FALSE;
		}


		gTimingInfo->AddTransactions(count);

#if 0
		mLock.Lock();
		if (mCount++ == 0)
			initialTicks = ::GetTickCount();

		const int period = 100;
		if (mCount > 0 && mCount % period == 0)
		{
			int ops = period;
			finalTicks = ::GetTickCount();



			printf("Sessions: %d\n", ops);
			printf("Ticks: %d\n", (finalTicks - initialTicks));
			printf("Seconds: %f\n", (finalTicks - initialTicks) / 1000.0);
			printf("Sessions/sec: %f\n", (((double)ops) / ((finalTicks - initialTicks) / 1000.0)));

			initialTicks = ::GetTickCount();
		}

		mLock.Unlock();
#endif

	}

#if 0
	finalTicks = ::GetTickCount();

	//int ops = 300;

	printf("Sessions: %d\n", ops);
	printf("Ticks: %d\n", (finalTicks - initialTicks));
	printf("Seconds: %f\n", (finalTicks - initialTicks) / 1000.0);
	printf("Sessions/sec: %f\n", (((double)ops) / ((finalTicks - initialTicks) / 1000.0)));
#endif

#else
	if (!router.RouteSessions())
	{
		cout << "Unable to route sessions" << endl;
	}

#endif


	return 0;
}

void RouteTest::RouteMessageTest(const char * apFile, int aRepeatCount)
{
	cout << "Processing." << endl;

	FILE * in = NULL;
	if (apFile)
	{
		in = fopen(apFile, "r");
		if (!in)
		{
			perror(apFile);
			return;
		}
		cout << "Input file name: " << apFile << endl;
	}

	std::string input;
	char buf[1024];
	while (1)
	{
		int nread = fread(buf, sizeof(char), sizeof(buf), in);
		if (nread == 0)
			break;
		input.append(buf, nread);
	}

	fclose(in);




	DWORD initialTicks = ::GetTickCount();

	int ops = aRepeatCount;

	for (int i = 0; i < ops; i++)
	{
		if (!router.RouteMessage(input.c_str(),input.length(), -1))
		{
			cout << "Unable to route message" << endl;
			return;
		}
	}

	DWORD finalTicks = ::GetTickCount();

	//int ops = 300;

	printf("Sessions: %d\n", ops);
	printf("Ticks: %d\n", (finalTicks - initialTicks));
	printf("Seconds: %f\n", (finalTicks - initialTicks) / 1000.0);
	printf("Sessions/sec: %f\n", (((double)ops) / ((finalTicks - initialTicks) / 1000.0)));
}


int main(int argc, char * argv[])
{
	try
	{
		RouteTest test;
		if (!test.Init())
			return 0;

		if (argc == 4 && 0 == strcmp(argv[1], "-message"))
		{
			// cmdroute -message foo.msix 10
			// 0        1        2        3
			int count = atoi(argv[3]);
			const char * filename = argv[2];
			test.RouteMessageTest(filename, count);
			return 0;
		}


		//return test.Test(argc, argv);
		//return Test(argc, argv);
		//test.ThreadMain();

		// cmdroute 10
		int threadcount = 1;
		if (argc == 2)
		{
			threadcount = atoi(argv[1]);
		}
		test.Startup(threadcount);
	}
	catch (_com_error & err)
	{
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
	return 0;
}
