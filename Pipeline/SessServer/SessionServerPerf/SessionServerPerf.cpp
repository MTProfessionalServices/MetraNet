/**************************************************************************
 * @doc SESSIONSERVERPERF
 *
 * Copyright 2004 by MetraTech Corporation
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
 * Created by:  Boris Boruchovich
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "stdafx.h"
#include <objbase.h.>

#include "PerfTimer.h"

#define ASSERT(x) {}
using namespace std;

#include <SetIterate.h>
#include "mtprogids.h"
#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping

static class ComInit
{
	public:
		ComInit()
		{
	   		//----- Initialize COM.
			CoInitializeEx(NULL, COINIT_MULTITHREADED);
		}
		~ComInit()
		{
			//----- Uninitialize COM.
			CoUninitialize();
		}
} gComInit;

//----- To avoid char to wide char conversion define MTPROGID_SESSION_SERVER as wide char
//current: #define MTPROGID_SESSION_SERVER 	"MetraPipeline.MTSessionServer.1"
//new: #define MTPROGID_SESSION_SERVER 	L"MetraPipeline.MTSessionServer.1"

//----- Single instance vars used for timing.
static PerfTimer gTM;
double gdTime = 0;

//----- Dump to console.
#define LOG(text) (cout<<text##"\r\n")

//------ Start and stop timer
#define START_TIMER()  gTM.Start();
#define END_TIMER(text) gdTime = gTM.Time();\
cout << text << ", time: " << gdTime << " ms\r\n";

//----- Name of memory mapped file to hold session state.
const wchar_t* gpszMemoryMapFilename = L"SessionServerPerfMap.data";

//----- Name of file mapping to use when accessing shared memory.
const wchar_t* gpszMemoryMapSharename = L"SessionServerPerfSharename";

//----- Total size (in bytes) of the shared memory file.
const long glMemoryMapTotalSize = (40 * 1024 * 1024); // 40MB

//----- Size of session set to create.
const long glNumberOfSessionInSet = 10240;

//----- Application main entry point.
int _tmain(int /* argc */, _TCHAR* /* argv[] */)
{
	//-----
	LOG("\n\n\n");
	LOG("SessionServer Performance Test");
	LOG("------------------------------");

	START_TIMER()
	END_TIMER("Finished Timer test");

	//----- Initialize the session server.
	LOG("Initializing SessionServer...");
	START_TIMER();

	MTPipelineLib::IMTSessionServerPtr sessionServer(MTPROGID_SESSION_SERVER);
	sessionServer->Init(gpszMemoryMapFilename,
						gpszMemoryMapSharename,
						glMemoryMapTotalSize);
	END_TIMER("Initialized SessionServer");

	//----- Create session set.
	LOG("Creating 10K entries Session Set...");
	START_TIMER();

	MTPipelineLib::IMTSessionSetPtr sessionSet = sessionServer->CreateSessionSet();

	//----- Populate sessionset with 10K session.
	long lPropertyID = 99;
	_variant_t decValue;
//	long lValue;
	string strValue;
	unsigned char uid[16];
	int serviceID = 100;
	for(long i = 0; i < glNumberOfSessionInSet; i++)
	{
		//----- Generate a new ID every time..
		_ltoa(i, (char*) uid, 10);
		decValue = i;
//		lValue = i;
//		strValue = (char*) uid;

		//----- Create a session with one decimal property value set.
		MTPipelineLib::IMTSessionPtr aSession = sessionServer->CreateSession(uid, serviceID);
		aSession->SetDecimalProperty(lPropertyID, decValue);
//		aSession->SetLongProperty(lPropertyID, lValue);
//		aSession->SetStringProperty(lPropertyID, strValue.c_str());

		sessionSet->AddSession(aSession->GetSessionID(), aSession->GetServiceID());
	}
	END_TIMER("Created session set");

	//----- Now loop through the session set and sum up all the decimal values.
	LOG("Iterating over session set...");

	char szNumber[16];

	__int64 lTotal = 0;
	string strOutput("Done with iteration, sum total: ");
	START_TIMER();

	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(sessionSet);
	if (FAILED(hr))
	{
		LOG("Unable to initialize session set iterator");
		return 1;
	}

	MTPipelineLib::IMTSessionPtr aSession;
	while ((aSession = it.GetNext()) != NULL)
	{
		if (aSession->PropertyExists(lPropertyID, MTPipelineLib::SESS_PROP_TYPE_DECIMAL))
		//if (aSession->PropertyExists(lPropertyID, MTPipelineLib::SESS_PROP_TYPE_LONG))
//		if (aSession->PropertyExists(lPropertyID, MTPipelineLib::SESS_PROP_TYPE_STRING))
		{
			decValue = aSession->GetDecimalProperty(lPropertyID);
//			lValue = aSession->GetLongProperty(lPropertyID);
//			strValue = aSession->GetStringProperty(lPropertyID);
			lTotal += (int) decValue;
//			lTotal += lValue;
//			lTotal += strValue[0];
		}
		else
			break;
	}

	strOutput += _i64toa(lTotal, szNumber, 10);
	END_TIMER(strOutput.c_str());

	//----- Done
	LOG("Done with test");
	return 0;
}

//-- EOF --