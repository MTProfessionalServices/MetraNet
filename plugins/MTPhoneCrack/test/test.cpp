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

#include "test.h"

#include "MTUtil.h"

#include <metra.h>

#include <SetIterate.h>
#include <mtcomerr.h>

unsigned char PARENT_ID[16] =	"ParentID";
unsigned char REAL_ID[16] = "SessionID";

#define SERVICE_ID	5


class ArgumentMap
{
public:
	_bstr_t argument;
	_bstr_t property;

	// needs the == to be placed in the vector
	bool operator ==(const ArgumentMap & arMap) const
	{
		return argument == arMap.argument && property == arMap.property;
	}
};


void Test1(char* filename, char* numLoop)
{
	char fn[256];

	if (filename == NULL || strlen(filename) == 0)
	{
		printf("Missing input configure file name");
		return;
	}
	else
	{
		strcpy(fn, filename);
	}

	int loopCount;

	if (numLoop == NULL || strlen(numLoop) == 0)
	{
		loopCount = 1;
	}
	else
	{
		loopCount = atol(numLoop);
	}

	// session server
//	IMTSessionServerPtr sessionServer(__uuidof(MTSessionServer));
	IMTSessionServerPtr sessionServer("MetraPipeline.MTSessionServer.1");

	/*
	 * initialize system context object
	 */
	IMTSystemContextPtr sysContext("MetraPipeline.MTSystemContext.1");

	sessionServer->Init("c:\\temp\\sessions.bin", "PipelineSessionView",
											10 * 1024 * 1024);

	IMTLogPtr MTLog(sysContext);

	MTLog->Init("logging", "[PlugIn]");

	// set to operate on
	MTPipelineLib::IMTSessionSetPtr set = sessionServer->CreateSessionSet();

	MTPipelineLib::IMTNameIDPtr idlookup = sysContext;

	// 1.
	long propid;
	MTPipelineLib::IMTSessionPtr session = sessionServer->CreateSession(REAL_ID, SERVICE_ID);

	propid = idlookup->GetNameID(_bstr_t("Login_ID"));
	//session->SetBSTRProperty(propid, _bstr_t("demo"));
	session->SetBSTRProperty(propid, _bstr_t("demo"));
	cout << "Session id: " << session->GetSessionID() << " PropID: " << propid;
	cout << ", value: " << session->GetBSTRProperty(propid) << endl;

	// 2.
	propid	= idlookup->GetNameID(_bstr_t("IP_Address"));
	session->SetBSTRProperty(propid, _bstr_t("mt"));
	cout << "Session id: " << session->GetSessionID()  << " PropID: " << propid;
	cout << ", value: " << session->GetBSTRProperty(propid) << endl;

	set->AddSession(session->GetSessionID(), -1);

	cout << endl;

	//===================================================================================
	/*
	 * read the processor configuration
	 */
	IMTConfigPtr config("MetraTech.MTConfig.1");
	VARIANT_BOOL flag;

	MTPipelineLib::IMTConfigPropSetPtr propset =
		config->ReadConfiguration(_bstr_t(fn), 
															&flag);

	MTPipelineLib::IMTConfigPropSetPtr mainSet = propset->NextSetWithName("mtconfigdata");

	long version = mainSet->NextLongWithName("version");

	MTPipelineLib::IMTConfigPropSetPtr subset = mainSet->NextSetWithName("processor");

	_bstr_t name = subset->NextStringWithName("name");
	_bstr_t progid = subset->NextStringWithName("progid");

	cout << "processor: " << name << " [" << progid << ']' << endl;
	cout << "configuration version: " << version << endl;


	// inputs
	vector<ArgumentMap> inputVector;
	MTPipelineLib::IMTConfigPropSetPtr inputs = subset->NextSetWithName("inputs");
	MTPipelineLib::IMTConfigPropSetPtr input;
	while ((input = inputs->NextSetWithName("input")) != NULL)
	{
		ArgumentMap map;
		map.argument = input->NextStringWithName("argument");
		map.property = input->NextStringWithName("property");
		inputVector.append(map);
	}
	// fit to size
	inputVector.resize(inputVector.length());

	for (int i = 0; i < (int) inputVector.length(); i++)
	{
		const ArgumentMap & map = inputVector[i];
		cout << "input: " << map.argument << " -> " << map.property << endl;
	}

	// outputs
	vector<ArgumentMap> outputVector;
	MTPipelineLib::IMTConfigPropSetPtr outputs = subset->NextSetWithName("outputs");
	MTPipelineLib::IMTConfigPropSetPtr output;
	while ((output = outputs->NextSetWithName("output")) != NULL)
	{
		ArgumentMap map;
		map.argument = output->NextStringWithName("argument");
		map.property = output->NextStringWithName("property");
		outputVector.append(map);
	}
	// fit to size
	outputVector.resize(outputVector.size());

	for (i = 0; i < (int) outputVector.size(); i++)
	{
		const ArgumentMap & map = outputVector[i];
		cout << "output: " << map.argument << " -> "
				 << map.property << endl;
	}


	MTPipelineLib::IMTConfigPropSetPtr configdata = subset->NextSetWithName("configdata");

	//=================== end of read in the configuration file ====================

	cout << "About to Load Pluging" << endl;


	// Start the processor
	MTPipelineLib::IMTPipelinePlugInPtr plugIn("MTPipeline.PhoneCrack.1");

	cout << "about Configure plugin" << endl;

	// initialize the processor
	plugIn->Configure(sysContext, configdata);

	cout << "after Configure" << endl;

	long starttime, endtime, elapseTime;

	cout << "Calling GetTickCount() for starttime" << endl;
	starttime = GetTickCount();
	
	BOOL successFlag = TRUE;
	for (i = 0; i < loopCount; i++)
	{
		try
		{
			cout << "Calling ProcessSessions()" << endl;

			plugIn->ProcessSessions(set);

			cout << "Called ProcessSessions() successfully" << endl;
		}
		catch (_com_error err)
		{
			cout << "_com_error thrown: " << endl;
			cout << " HRESULT: " << hex << err.Error() << dec << endl;
			cout << " Message: " << err.ErrorMessage() << endl;

			_bstr_t desc(err.Description());
			_bstr_t src(err.Source());

			char* ptr;
			ptr = desc;
			if (ptr)
				cout << "  Description: " << ptr << endl;
			ptr = src;
			if (ptr)
				cout << "  Source: " << ptr << endl;
			successFlag = FALSE;
		}

	}

	if (successFlag == FALSE)
		return;

	cout << "Calling GetTickCount() for endtime" << endl;
	endtime = GetTickCount();

	elapseTime = endtime - starttime;

//---- done with propGenProcessor's ProcessSessions
	// --- post check ---

	cout << "After ProcessSessions" << endl;

	long sessid = idlookup->GetNameID(_bstr_t("SessionID"));

	long pdid = idlookup->GetNameID(_bstr_t("MTAccount_ID"));

	cout << "id: " << session->GetSessionID() << ", pdid: " << pdid << endl;

	//cout << session->GetLongProperty(pdid) << endl;

	SetIterator<IMTSessionSetPtr, IMTSessionPtr> it;
	HRESULT hr = it.Init(set);
	if (FAILED(hr))
	  throw hr;

	while (TRUE)
	{
		IMTSessionPtr session = it.GetNext();
		if (session == NULL)
		    break;

		long id = session->GetSessionID();

		_bstr_t value = session->GetLongProperty(pdid);
		cout << "real ID: " << id << ", value: " << value << endl;
	}

#if 0
	IUnknown * unk = set->Get_NewEnum();

	IEnumVARIANTPtr ienum(unk);

	unk->Release();

	HRESULT hr;

	const int CHUNKSIZE = 10;
	VARIANT rgvar[CHUNKSIZE] = { 0 };
	do
	{
		ULONG cFetched;

		hr = ienum->Next(CHUNKSIZE, rgvar, &cFetched);
		if (FAILED(hr))
			throw hr;

		// if (hr == S_OK )
		//    cFetched = CHUNKSIZE;
		for( ULONG i = 0; i < cFetched; i++ )
		{
			// Do something with rgvar[i]
			_variant_t var(rgvar[i]);
			//IUnknown * unk = (IUnknown *) var;

			MTPipelineLib::IMTSessionPtr session(var);

			long id = session->GetSessionID();

			_bstr_t value = session->GetLongProperty(pdid);
			cout << "real ID: " << id << ", value: " << value << endl;

			VariantClear(&rgvar[i]);

		}
	}
	while (hr == S_OK);
#endif

	string timeStr;
	double single = elapseTime / loopCount;

	int sec = elapseTime / 1000;
	MTFormatTime(sec, timeStr);

	cout << endl;

	cout << "*********************************************" << endl;

	cout << "* Loop count: " << loopCount << endl;
	cout << "* Total Elapse time: " << timeStr << " (" << elapseTime << "ms" << ")" << endl;
	cout << "* Single Elapse time: " << single << "ms" << endl;

	cout << "*********************************************" << endl;

}

int main(int argc, char** argv)
{
	::CoInitialize(NULL);

	try
	{
		Test1(argv[1], argv[2]);
	}
	catch (HRESULT hr)
	{
		cout << "Error! " << hex << hr << dec << endl;
	}
	catch (_com_error err)
	{
		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc(err.Description());
		_bstr_t src(err.Source());

		char* ptr;
		ptr = desc;
		if (ptr)
			cout << "  Description: " << ptr << endl;
		ptr = src;
		if (ptr)
			cout << "  Source: " << ptr << endl;
	}
	catch (...)
	{
		cout << "everything else " << endl;
	}

	::CoUninitialize();

	return 0;

}
