/**************************************************************************
 * @doc NONET
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

// #import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

#import <MTConfigLib.tlb>

#include <nonet.h>

#include <iostream>
using namespace std;

void CompletionHook(const char * apUID, const char * apMessage, void * apArg);


BOOL NoNetNetMeterAPI::Init()
{
	if (!mInitialized)
	{
		mInitialized = TRUE;
		return mHandler.Init(CompletionHook);
	}
	return TRUE;
}

BOOL NoNetNetMeterAPI::Close()
{
	return TRUE;
}


void MTMeterNoNetConfig::AddServer(int priority, const char * serverName,
																	 int port, BOOL secure, const char * username,
																	 const char * password)
{
	MeteringServer * server = new MeteringServer(serverName, port, secure,
																							 username, password);
	mpAPI->AddHost(server);
}


MTMeterNoNetConfig::MTMeterNoNetConfig()
{
	// no network version of API

	Win32NetStream * netstream = new Win32NetStream;

	mpAPI = new NoNetNetMeterAPI(netstream);
}

MTMeterNoNetConfig::~MTMeterNoNetConfig()
{
	// deleting mpAPI calls Close, so we don't need to call it explicitly
	delete mpAPI;
}

NetMeterAPI * MTMeterNoNetConfig::GetAPI()
{
	return mpAPI;
}

// Need to implement this here since it is a pure virtual function on the base class. Do not use.
NetMeterAPI * MTMeterNoNetConfig::GetSoapAPI()
{
	// NOTE: this fakes out the SDK even though we don't do any soap stuff
	return mpAPI;
}

BOOL MTMeterNoNetConfig::HandleStream(const std::string & message, std::string & output)
{
	return mpAPI->HandleStream(message, output);
}


BOOL NoNetNetMeterAPI::HandleStream(const std::string & message, std::string & output)
{
	BOOL completeImmediately;
	return mHandler.HandleStream(message.c_str(), output, FALSE, completeImmediately, NULL);
}


MSIXMessage * NoNetNetMeterAPI::SendRequest(MSIXParser & arParser,
																						MeteringServer & arServer,
																						const MSIXMessage & arMessage)
{
	// stream the object to an in-memory buffer
	// do this before we begin the POST
	string obj;
	StreamObject(obj, arMessage);

	const char * streamedObj = obj.c_str();

	//SDK_LOG_INFO("Streamed object:\n%s", streamedObj);


	std::string output;

	BOOL completeImmediately;
	if (!mHandler.HandleStream(streamedObj, output, FALSE, completeImmediately, NULL))
		return NULL;

	MSIXMessage * result = ParseResults(arParser, output);


	return result;
}


MSIXMessage * NoNetNetMeterAPI::ParseResults(MSIXParser & arParser,
																						 const std::string & arResults)
{
	SDK_LOG_DEBUG("MSIXNetMeterAPI::ParseResults");

	// TODO: error check

	XMLObject * results;
	MSIXMessage * obj = NULL;

	if (arParser.ParseFinal(arResults.c_str(), arResults.length(), &results))
		obj = ConvertUserObject(results, obj);

	return obj;
}


void CompletionHook(const char * apUID, const char * apMessage, void * apArg)
{
	cout << "-- Completion hook called: --" << endl;
	cout << "UID: " << apUID << endl;
	cout << "Message:" << endl;
	cout << apMessage << endl;
	cout.flush();
}
