/**************************************************************************
 * @doc LOCALMODE
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
 *
 ***************************************************************************/

#include <metra.h>

//#include <mtcom.h>

//#import <MTPipelineLib.tlb>



//using namespace MTPipelineLib;

//#import <MTConfigLib.tlb>


#define MTSDK_DLL_EXPORT __declspec(dllexport)
#include "mtsdk.h"
#include "mtlocalmode.h"
#include "MTMeterStore.h"

#include "sdk_msg.h"


BOOL MTFileMeterAPI::Init()
{
	return MSIXNetMeterAPI::Init();
}

BOOL MTFileMeterAPI::Close()
{
	if (mpMeterStore)
	{
		delete mpMeterStore;
		mpMeterStore = NULL;
	}
	return MSIXNetMeterAPI::Close();
}

void MTFileMeterAPI::SetMeterFile(char * szFileName)

{
  if (!szFileName || !strlen(szFileName)) {
		mLocal = FALSE;
  }  else {
		mLocal = TRUE;
  }
  mMeterFileName = szFileName;
}

void MTFileMeterAPI::SetMeterStore(char * szFileName)

{
	// BUG 3102/Blount: Check for null/empty string
	if (szFileName == NULL || !strlen(szFileName)) {
		return;
	}

	mpMeterStore = new MTMeterStore(szFileName);
}

BOOL MTMeterFileConfig::AddServer(int priority, const char * serverName,
																	int port, BOOL secure, const char * username,
																	const char * password)
{
	MeteringServer * server = new MeteringServer(serverName, port, secure, username, password);
	server->SetPriority (priority);
	mpAPI->AddHost(server);

	// error is already set by the MTMeterHTTPConfig object
	if (!MTMeterHTTPConfig::AddServer(priority, serverName, port, secure, username, password))
		return FALSE;
	
	return TRUE;
}

MTMeterFileConfig::MTMeterFileConfig()
{
	// no network version of API

#ifdef UNIX
	NetStream * netstream = new UnixNetStream;
#else
	NetStream * netstream = new Win32NetStream;
#endif

	mpAPI = new MTFileMeterAPI(netstream);
}

MTMeterFileConfig::~MTMeterFileConfig()
{
	// deleting mpAPI calls Close, so we don't need to call it explicitly
	delete mpAPI;
}

NetMeterAPI * MTMeterFileConfig::GetAPI()
{
	return mpAPI;
}

void MTMeterFileConfig::SetProxyData(string proxyData)
{
	mpAPI->SetProxyData(proxyData);
  MTMeterHTTPConfig::SetProxyData(proxyData);
}

void MTMeterFileConfig::SetMeterFile(char * FileName)

{
	mpAPI->SetMeterFile (FileName);
}


void MTMeterFileConfig::SetMeterStore(char * FileName)

{
	mpAPI->SetMeterStore (FileName);
}


MSIXMessage * MTFileMeterAPI::SendRequest(MSIXParser & arParser, MeteringServer & arServer,
																const MSIXMessage & arMessage)
{

	if (!mLocal)
		return MSIXNetMeterAPI::SendRequest (arParser, arServer, arMessage);

	// stream the object to an in-memory buffer
	string obj;

	StreamObject(obj, arMessage);
	

	// Dump the buffer to a file
	const char * szFileName = mMeterFileName.c_str();
	ofstream OutFile (szFileName, ios::app);

	// check for success
	//if (!OutFile.is_open())
	if (!OutFile.good())
	{
#ifdef UNIX
	  SetError (errno, ERROR_MODULE, ERROR_LINE, "SendRequest", "Unable to open output file");
#else
	  SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "SendRequest", "Unable to open output file");
#endif
		return NULL;
	}

	// Save the data
	OutFile << obj.c_str();
	if (!OutFile.good())
	{
#ifdef UNIX
		SetError (errno, ERROR_MODULE, ERROR_LINE, "SendRequest", "Unable to write to output file");
#else
		SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "SendRequest", "Unable to write to output file");
#endif
		return NULL;
	}

	
	// Dummy up a response to keep the SDK happy

	MSIXMessage * resp = new MSIXMessage;

	resp->SetCurrentTimestamp();
	resp->SetVersion(L"1.0");
	resp->GenerateUid();
	
	// TODO: don't hardcode this hostname!
	resp->SetEntity(L"metratech.com");

	// delete anything in the body
	resp->DeleteBody(TRUE);

	MSIXStatus * status = new MSIXStatus;
	status->SetCode(0);

	resp->AddToBody(status);


	return resp;
}

BOOL MTFileMeterAPI::MeterFile (char * szFileName)

{
	// open file which must exist
	ifstream InFile (szFileName, ios::in);

	string Buffer;
	string Line;

	// if (!InFile.is_open())
	if (!InFile.good())
	{
		SDK_LOG_DEBUG ("Unable to open meter file.");
#ifdef UNIX
		SetError (errno, ERROR_MODULE, ERROR_LINE, "MeterFile");
#else
		SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "MeterFile");
#endif
		return FALSE;
	}

	MSIXParser parser(NETMETER_PARSE_BUFFER_SIZE);
	parser.Init();

	
	ErrorObject::ErrorCode resultCode = 0;
	string detailMessage;
	MSIXSessionStatusMap arStatusMap;

	while (GetNextSession (InFile, Buffer))
	{
		// Convert to a message object
		parser.Restart();
		MSIXMessage * pMsg = ParseResults (parser, Buffer.c_str(), Buffer.length());
		if (pMsg == NULL)
			return FALSE;

		// Get the UID
		const MSIXUid arUID =  pMsg->GetUid();
	
		string rwUID = arUID.GetUid();

		MeteringServer * server = CurrentMeteringServer();
		
		// check to see if we already processed this message
		if (mpMeterStore != NULL)
			if (mpMeterStore->IsComplete(rwUID.c_str()) 
					|| mpMeterStore->IsInProgress(rwUID.c_str()))
			{
				goto GetNext;
			}
			
		// Send it

		parser.Restart();
		MSIXMessage * result;
		if (NULL == (result = MSIXNetMeterAPI::SendRequest (parser, *server, *pMsg)))
		{
			delete pMsg;
			return FALSE;
		}

//		MSIXSessionList & arSessionList;

		if (!GetStatusFromMessage(result, arStatusMap, resultCode, detailMessage))
				resultCode = MT_ERR_PARSE_ERROR;

		// TODO: arStatusMap memory must be reclaimed
		
			// HACK!!
/*
			if (arStatusList.entries() == 1)
			{
				// HACK!! match responses to their correct sessions
				//&& arSessionList.entries() == 1)
				//{
				MeteringSessionImp * imp = (MeteringSessionImp *) arSessionList.first();

				MSIXSessionStatus * status = arStatusList.first();
				MSIXSession * responseSession = status->DetachSession();
				if (responseSession)
				{

					MSIXMeteringSessionImp * session = new MSIXMeteringSessionImp(this);

					// TODO: this might not be safe..
					MSIXSession * msixSession = session;
					*msixSession = *responseSession;

					imp->SetResults(session);


					delete responseSession;
				}
			}
*/
			// get rid of this as soon as possible
			delete result;

		if (resultCode != 0)
		{
			// server has returned an error
			SetError(resultCode, ERROR_MODULE, ERROR_LINE, "MTFileMeterAPI::SendRequest");
			mpLastError->GetProgrammerDetail() = detailMessage;
			return FALSE;
		}

/*
		else
		{
			// SendRequest should have set the error if this is the case
			resultCode = 0;
			const ErrorObject * errobj = GetLastError();
			if (errobj)
				resultCode = errobj->GetCode();

			if (!resultCode)
			{
				// not sure what the cause is, so generate this error
				resultCode = MT_ERR_BAD_HTTP_RESPONSE;
			}
		}

*/

		// Mark it done
		if (mpMeterStore != NULL)
			mpMeterStore->MarkComplete(rwUID.c_str());
		
GetNext:
		delete pMsg;
		
	}

	return TRUE;
}


BOOL MTFileMeterAPI::GetNextSession (ifstream & InFile, string & Buffer)
{
	#define _msix_tag_size 6

	char char_buf;
	char tag_buf[6];
	string strTag, strChar;
	long n_open_msix = 0; // Use this long to count the number of msix tags that were detected before we found a closing msix tag

	// Init the output buffer
	Buffer = "";

	// Find the start tag
	while (!InFile.eof())
	{
		//	InFile >> Line;
		InFile.get(char_buf);
		strChar = char_buf;

		if (strChar == "<")
		{
			InFile.get(tag_buf, _msix_tag_size);
			strTag = tag_buf;
			
			// We found an opening msix tag. From now on we will accumulate the stream on the return buffer,
			// until we find a closing msix tag. We will also look for possible compound sessions by checking for
			// nested opening msix tags. If we find such tag, we will use n_open_msix as a counting queue, so we
			// know which closing msix tag actually closes the top level message.
			if (strTag == "msix>") 
			{
				n_open_msix++;
				Buffer += strChar;
				Buffer += strTag;
				break;
			}
			// TODO: figure out what to do here - do we want to be picky about what is in the file?
			else
			{
				
			}
		}
	}

	// See if we're done
	if (InFile.eof())
		return FALSE;

	// Find the end tag
	while (!InFile.eof())
	{
		
		InFile.get(char_buf);
		strChar = char_buf;

		Buffer += strChar;

		if (strChar == "<")
		{
			InFile.get(tag_buf, _msix_tag_size+1);
			strTag = tag_buf;
			
			// First let's detect a closing msix tag
			if (strTag == "/msix>") 
			{
				n_open_msix--;

				// If the stack is empty, we have our whole message.
				if (n_open_msix == 0)
				{
					Buffer += strTag;
					break;
				}
			}
			else if (strncmp(tag_buf, "msix>*", 5) == 0)
			{
				//We have a compound session. Add this msix count to the stack
				n_open_msix++;
			}
		
			Buffer += strTag;

		}
	}
	
	return TRUE;
}

BOOL MTFileMeterAPI::CommitSessionSet(
		const MeteringSessionSetImp & arSessionSet,
		MSIXTimestamp aTimestamp,
		const char * apUpdateId)
{
	// First of all, check if we are using localmode - if so, return false if transaction id or session context are set
	if (mLocal)
	{
		if (strlen(arSessionSet.GetTransactionID()) 
				|| strlen(arSessionSet.GetSessionContext())
				|| strlen(arSessionSet.GetSessionContextUserName())
				|| strlen(arSessionSet.GetSessionContextPassword())
				|| strlen(arSessionSet.GetSessionContextNamespace()))
		{
			SetError(MT_ERR_LOCALMODE_NOSUPPORT_SC_TI, ERROR_MODULE, ERROR_LINE, "MSIXNetMeterAPI::CommitSessionSet");
			return FALSE;
		}
	}
	return MSIXNetMeterAPI::CommitSessionSet(arSessionSet, aTimestamp, apUpdateId);
}

BOOL MTFileMeterAPI::MarkAsFailed()
{
	return FALSE;
}

BOOL MTFileMeterAPI::MarkAsDismissed()
{
	return FALSE;
}

BOOL MTFileMeterAPI::MarkAsActive()
{
	return FALSE;
}

BOOL MTFileMeterAPI::MarkAsCompleted()
{
	return FALSE;
}

BOOL MTFileMeterAPI::MarkAsBackout()
{
	return FALSE;
}

BOOL MTFileMeterAPI::UpdateMeteredCount()
{
	return FALSE;
}
