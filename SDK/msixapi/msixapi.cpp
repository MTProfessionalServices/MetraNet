/**************************************************************************
 * @doc MSIXAPI
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
 * $Header: msixapi.cpp, 65, 11/14/2002 11:42:55 AM, Raju Matta$
 ***************************************************************************/

#include "metra.h"

#define USE_KEEP_ALIVE

// if a DLL is created from this lib, we want to export everything
#define MTSDK_DLL_EXPORT __declspec(dllexport)

#include <msixapi.h>

#include <sdk_msg.h>

#include <MTUtil.h>

#include <strstream>
#include <algorithm>
#include <stdutils.h>

#include "MTDecimalVal.h"

#include <lzo1x.h> // TODO: this is no longer used
#include <mtzlib.h>
#include <batchsupport.h>

#ifdef WIN32
#include <ConfigDir.h>  // for IsMSIXCompressionEnabled()
#endif

// NOTE: define this to get performance logging in the SDK.  If this
// is defined, the SDK needs to link with extra libraries
//#define MTSDK_PERFLOG

#ifdef MTSDK_PERFLOG
#include <perflog.h>
#define MTSDK_PerfLogActive() PerfLogActive()

#define MTSDK_MarkEnterRegion(regionName) MarkEnterRegion_(regionName)
#define MTSDK_MarkEnterRegion1(regionName, arg) MarkEnterRegion_(regionName, arg)

#define MTSDK_MarkExitRegion(regionName) MarkExitRegion_(regionName)
#define MTSDK_MarkExitRegion1(regionName, arg) MarkExitRegion_(regionName, arg)

class MTSDK_MarkRegion
{
public:
	MTSDK_MarkRegion(const char * regionName, const char * arg = 0)
		: mpRegionName(regionName),
			mpArg(arg)
	{ MTSDK_MarkEnterRegion1(mpRegionName, mpArg); }

	~MTSDK_MarkRegion()
	{ MTSDK_MarkExitRegion1(mpRegionName, mpArg); }

private:
	const char * mpRegionName;
	const char * mpArg;
};

#else 
#define MTSDK_PerfLogActive() (false)

#define MTSDK_MarkEnterRegion(regionName)
#define MTSDK_MarkEnterRegion1(regionName, arg)

#define MTSDK_MarkExitRegion(regionName)
#define MTSDK_MarkExitRegion1(regionName, arg)


class MTSDK_MarkRegion
{
public:
	MTSDK_MarkRegion(const char * regionName, const char * arg = 0)
	{ }

	~MTSDK_MarkRegion()
	{ }
};

#endif

using std::sort;
using std::istrstream;

template void destroyPtr(MeteringServer *);
template void destroyPtr(MSIXCommitSession *);

typedef	list<MSIXCommitSession *> CommitMessages;
typedef	list<MSIXCommitSession *>::iterator CommitMessagesIterator;

#define SDK_MESSAGE_NAME "sdk_msg.dll"

#ifdef UNIX

void InitializeCriticalSection(sema_t *s)
{
  sema_init(s, 1, USYNC_THREAD, NULL);
}
  
void DeleteCriticalSection(sema_t *s)
{
  sema_destroy(s);
}

void EnterCriticalSection(sema_t *s)
{
  sema_wait(s);
}

void LeaveCriticalSection(sema_t *s)
{
  sema_post(s);
}

#endif


/******************************************* MSIXNetMeterAPI ***/

MSIXNetMeterAPI::MSIXNetMeterAPI(NetStream * apNetStream,
																 const char * apProxyName /* = NULL */)
{
	SDK_LOG_DEBUG("MSIXNetMeterAPI::MSIXNetMeterAPI");

	InitializeCriticalSection(&mNetworkGuard);

	if (apProxyName)
		mProxyName = apProxyName;

	// Initializing the *base class* member variabe
	mpNetStream = apNetStream;

	// we define the user agent
	mpNetStream->SetUserAgent(METRATECH_SDK_USER_AGENT);
	// use the first host they pass us
	mCurrentHost = 0;

#ifdef WIN32
	// checks for the 'DisableMSIXCompression' registry key
	// assumes that compression is enabled if the key is not present
  mUseCompression = IsMSIXCompressionEnabled();
#else
	// compression is always disabled for the UNIX SDK
	mUseCompression = false;
#endif

}

MSIXNetMeterAPI::~MSIXNetMeterAPI()
{
	SDK_LOG_DEBUG("MSIXNetMeterAPI::~MSIXNetMeterAPI");

	DeleteCriticalSection(&mNetworkGuard);

	// Close deletes mpNetstream as well
	(void) Close();
	delete mpNetStream;
	mpNetStream = NULL;
	ASSERT(!mpNetStream);
}

BOOL MSIXNetMeterAPI::MeterFile(char * FileName) // MSIX ONLY
{
	SDK_LOG_DEBUG("MSIXNetMeterAPI::MeterFile");

	return FALSE;
}

BOOL MSIXNetMeterAPI::StreamObject(string & arBuffer, const MSIXObject & arObj)
{
	MTSDK_MarkRegion region("StreamObject");

	// NOTE: pretty printing adds a lot of overhead to the message, but is useful for
	// debugging. reenable it here if necessary.

	XMLWriter stringWrite;
	arObj.Output(stringWrite);

	const char * data;
	int len;
	stringWrite.GetData(&data, len);
	arBuffer = data;
	return TRUE;
}

MeteringSessionImp * MSIXNetMeterAPI::CreateSession(const char * apName,
                                                    BOOL IsChild)
{
	MSIXMeteringSessionImp * session = new MSIXMeteringSessionImp(this);

	session->SetName(apName);
	// give it a new UID
	session->GenerateUid();
	return session;
}

MeteringSessionSetImp * MSIXNetMeterAPI::CreateSessionSet()
{
	MeteringSessionSetImp * sessionset = new MeteringSessionSetImp(this);

	return sessionset;
}

// 3.0 chages here - compare with SendRequest methods, see why it is not getting called
BOOL MSIXNetMeterAPI::CommitSessionSet(
		const MeteringSessionSetImp & arSessionSet,
		MSIXTimestamp aTimestamp,
		const char * apUpdateId) // MSIX
{
	const char* procName = "MSIXNetMeterAPI::CommitSessionSet";
	MTSDK_MarkRegion region("CommitSessionSet");
	
	// keep track of the first server
	MeteringServer * server, * first;
	server = first = CurrentMeteringServer();
	if (!server)
	{
		SetError(MT_ERR_NO_HOSTS, ERROR_MODULE, ERROR_LINE, procName);
		return FALSE;
	}

	SDK_LOG_INFO("First server: %s", server->GetName());

	MSIXMessage * response = NULL;

	// create the parser on the stack for threading
	MSIXParser parser(NETMETER_PARSE_BUFFER_SIZE);
	parser.Init();
	// after one use, the parser will need to be restarted
	BOOL parserNeedsRestart = FALSE;

	// result of the operation
	ErrorObject::ErrorCode resultCode = 0;
	string detailMessage;
   MSIXMessage *result = NULL;
   MSIXSessionRefList::const_iterator it;
   const MSIXSessionRefList &sessionList = arSessionSet.GetSessions();

	do
	{
      if (arSessionSet.IsFastMode()) 
      {
         string str = arSessionSet.GetBuffer();
         result = SendRequest(parser, *server, str);
      }
      else
      {
		   MSIXMessage* message = CreateMessageWrapper(
			   NULL, 
			   apUpdateId,
			   arSessionSet.GetTransactionID(),
			   arSessionSet.GetListenerTransactionID(),
			   arSessionSet.GetSessionContext(),
			   arSessionSet.GetSessionContextUserName(),
			   arSessionSet.GetSessionContextPassword(),
			   arSessionSet.GetSessionContextNamespace());

		   string messageID;
		   char batchID[32];
		   arSessionSet.GetSessionSetID(batchID);
		   messageID = batchID;
		   // GetSessionSetID strips of the trailing two ==
		   messageID += "==";
		   message->SetUid(messageID.c_str());

		   for (it = sessionList.begin(); it != sessionList.end(); it++)
		   {
			   // NOTE: we know it's an MSIXMeteringSessionImp because
			   // we create all the objects of type MeteringSessionImp
			   MSIXMeteringSessionImp * rootSess = static_cast<MSIXMeteringSessionImp *>(*it);

			   MSIXSessionRefList compoundList;
			   rootSess->SessionsForUpdate(compoundList, MSIXMeteringSessionImp::COMMITTED);

			   MeteringServer * lastServer = rootSess->GetLastRecipient();

			   // NOTE: sessions are sorted depth first
			   MSIXSessionRefList::iterator sessit;
			   for (sessit = compoundList.begin(); sessit != compoundList.end(); sessit++)
			   {
				   MSIXMeteringSessionImp * sess = static_cast<MSIXMeteringSessionImp *>(*sessit);

				   // commit this session
				   sess->SetCommit(TRUE);

				   // if we're resending to the same server as last time, set the
				   // "insert" flag to update.
				   if (lastServer != NULL && *lastServer == *server)
					   sess->SetInsertHint(MSIXSession::Update);
				   else
					   sess->SetInsertHint(MSIXSession::Insert);

				   message->AddToBody(sess);
				   sess->SetLastRecipient(server);
			   }
		   }

		   // if this is the second time around the loop or later the parser
		   // must be restarted.
		   if (parserNeedsRestart)
			   parser.Restart();
   		
		   //EnterCriticalSection(&mNetworkGuard);
		   result = SendRequest(parser, *server, *message);

		   delete message;
		   message = NULL;
      }
		//LeaveCriticalSection(&mNetworkGuard);

		if (!result)
		{
			if (!GetLastError())
				// not sure what the cause is, so generate this error
				SetError(MT_ERR_BAD_HTTP_RESPONSE, ERROR_MODULE, ERROR_LINE, procName);
			return FALSE;
		}

		// breaks the result message into a collection of status messages (one per session)
		MSIXSessionStatusMap arStatusMap;
		if (!GetStatusFromMessage(result, arStatusMap, resultCode, detailMessage))
		{
			// get rid of this as soon as possible
			delete result;
			if (resultCode == 0) // no error was returned from the server
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, procName);

			return FALSE;
		}

		// we should come in here only and only if there is listener validation
		// errors
		if (resultCode != 0)
		{
			SetError(resultCode, ERROR_MODULE, ERROR_LINE, procName);
			mpLastError->GetProgrammerDetail() = detailMessage;

			// was any feedback received at all?
			if (arStatusMap.size() > 0)
			{
				MTSDK_MarkRegion region("HandleResponse");
				for (it = sessionList.begin(); it != sessionList.end(); it++)
				{
					MSIXMeteringSessionImp * session = static_cast<MSIXMeteringSessionImp *>(*it);

					// gets the original session's UID
					std::string uid = (session->GetUid()).GetUid();
						
					// is there a session status object associated with this UID?
					MSIXSessionStatusMap::iterator findIt = arStatusMap.find(uid);

					if (findIt != arStatusMap.end())
					{
						// error returned for this session
						MSIXSessionStatus * sessionStatus = findIt->second;
						ErrorObject errObj(sessionStatus->GetCode(),
														 	ERROR_MODULE, ERROR_LINE, procName);
						errObj.SetProgrammerDetail(
							ascii(sessionStatus->GetStatusMessage()).c_str());
						session->SetError(&errObj);
					}	
					
					//This code retrieves the list of child sessions for the parent session.
					//Searches the error for the Childs in the arStatusMap object.
					//If filnds, sets the error in the child object
					const MSIXSessionRefList & childsessionList = session->GetChildSessions();
					MSIXSessionRefList::const_iterator childit;
					for (childit = childsessionList.begin(); childit != childsessionList.end(); childit++)
					{
						MSIXMeteringSessionImp * childsession = static_cast<MSIXMeteringSessionImp *>(*childit);
						std::string childuid = (childsession->GetUid()).GetUid();

						// is there a session status object associated with this UID?
						MSIXSessionStatusMap::iterator findChildIt = arStatusMap.find(childuid);

						if (findChildIt != arStatusMap.end())
						{
							// error returned for this session
							MSIXSessionStatus * childsessionStatus = findChildIt->second;
							ErrorObject errObjChild(childsessionStatus->GetCode(),
														 		ERROR_MODULE, ERROR_LINE, procName);
							errObjChild.SetProgrammerDetail(
								ascii(childsessionStatus->GetStatusMessage()).c_str());
							childsession->SetError(&errObjChild);
						}	
					}
				}
			}

			delete result;
			return FALSE;
		}

		// this is set to true if at least one session failed.
		BOOL someErrors = FALSE;

		// NOTE: because of the following optimization we can't detect the error
		// case in which every session in the set has requested a response and
		// didn't get one back.

		// was any feedback received at all?
		if (arStatusMap.size() > 0)
		{
			MTSDK_MarkRegion region("HandleResponse");
			for (it = sessionList.begin(); it != sessionList.end(); it++)
			{
				MSIXMeteringSessionImp * session = static_cast<MSIXMeteringSessionImp *>(*it);

				// was feedback requested?
				if (session->GetRequestResponse())
				{
					// gets the original session's UID
					std::string uid = (session->GetUid()).GetUid();
					
					// is there a session status object associated with this UID?
					MSIXSessionStatusMap::iterator findIt = arStatusMap.find(uid);
					if (findIt == arStatusMap.end())
					{
						// feedback was requested, but not received!
						delete result;
						SetError(MT_ERR_RESPONSE_MISSING, ERROR_MODULE, ERROR_LINE, procName);
						return FALSE;
					}
					else
					{
						// wrap the session in an imp
						MSIXSession * responseSession = (*findIt).second->DetachSession();
						if (responseSession)
						{
							MSIXMeteringSessionImp * responseImp = new MSIXMeteringSessionImp(this);				
						
							responseImp->Copy(responseSession);
							delete responseSession;

							// associates the response with the original session
							session->SetResults(responseImp);
						}
						else
						{
							// error returned for this session
							someErrors = TRUE;
							MSIXSessionStatus * sessionStatus = findIt->second;
							ErrorObject errObj(sessionStatus->GetCode(),
																 ERROR_MODULE, ERROR_LINE, procName);
							errObj.SetProgrammerDetail(
								ascii(sessionStatus->GetStatusMessage()).c_str());
							session->SetError(&errObj);
              SetError(&errObj); // Doing this on purpose, to make sure that if we only have one failed session,
                                 // the sessionset will contain the failed session error, and not the generic one.
						}
					}
				}
			}
		}

		delete result;

    // Here we will set a general error on the session set, indicating that one or more sessions failed.
    // The client is responsible for iterating the sessions and finding out what happened to each one.
    // The exception is if this session set contains only one session. In this case, the session set error
    // will contain the session's failure.
		if (someErrors)
		{
      if (sessionList.size() > 1) // Otherwise we will just keep the session error
			  SetError(MT_ERR_SESSION_SET_FAILED, ERROR_MODULE, ERROR_LINE, procName);
			return FALSE;
		}

		return TRUE;

		// TODO: Fix multiserver sessionset transmission
#if 0
		// message didn't go through - go to the next server

		server = NextMeteringServer(first);
#endif

	} while (server != NULL);

	//if (!response)
		// NOTE: SendRequest calls set error!
	//return FALSE;

	//ASSERT(server != NULL);				// otherwise response would have been NULL

	ClearError();

	return TRUE;
}


BOOL MSIXNetMeterAPI::ToXML(
	const MeteringSessionSetImp & arSessionSet,
	MSIXTimestamp aTimestamp,
	const char * apUpdateId,
	std::string & arBuffer) // MSIX
{
	const MSIXSessionRefList & sessionList = arSessionSet.GetSessions();

	MSIXMessage* message = CreateMessageWrapper(
		NULL, 
		apUpdateId, 
		arSessionSet.GetTransactionID(),
		arSessionSet.GetListenerTransactionID(),
		arSessionSet.GetSessionContext(),
		arSessionSet.GetSessionContextUserName(),
		arSessionSet.GetSessionContextPassword(),
		arSessionSet.GetSessionContextNamespace());

	string messageID;
	char batchID[32];
	arSessionSet.GetSessionSetID(batchID);
	messageID = batchID;
	// GetSessionSetID strips of the trailing two ==
	messageID += "==";
	message->SetUid(messageID.c_str());

	MSIXSessionRefList::const_iterator it;
	for (it = sessionList.begin(); it != sessionList.end(); it++)
	{
		// NOTE: we know it's an MSIXMeteringSessionImp because
		// we create all the objects of type MeteringSessionImp
		MSIXMeteringSessionImp * rootSess = static_cast<MSIXMeteringSessionImp *>(*it);

		MSIXSessionRefList compoundList;
		rootSess->SessionsForUpdate(compoundList, MSIXMeteringSessionImp::COMMITTED);

		// NOTE: sessions are sorted depth first
		MSIXSessionRefList::iterator sessit;
		for (sessit = compoundList.begin(); sessit != compoundList.end(); sessit++)
		{
			MeteringSessionImp * sess = static_cast<MeteringSessionImp *>(*sessit);

			// commit this session
			sess->SetCommit(TRUE);

			sess->SetInsertHint(MSIXSession::Insert);

			message->AddToBody(sess);
		}
	}

	StreamObject(arBuffer, *message);

	return TRUE;
}

// define this to use compression
//#define USE_COMPRESSION

BOOL MSIXNetMeterAPI::CompressSessionSet(list<MSIXMessage *> & arMessages,
																		unsigned char * * apSetBuffer,
																		int & arSetLen) // MSIX
{
	// stream each session into separate XML messages
	// and calculate the largest possible size of the compressed message

	// start with the size of the header
	int estimatedSize = sizeof(MTMSIXBatchHeader);

	list<string> buffers;
	std::list<MSIXMessage *>::iterator it;
	for (it = arMessages.begin(); it != arMessages.end(); ++it)
	{
		MSIXMessage * message = *it;

		string buffer;
		StreamObject(buffer, *message);

		int originalSize = buffer.length();
		// estimated size based on worst case.
#ifdef USE_COMPRESSION
		int estimatedCompressedLen = originalSize + originalSize / 64 + 16 + 3;
#else
		int estimatedCompressedLen = originalSize;
#endif
		estimatedSize += sizeof(MTMSIXMessageHeader) + estimatedCompressedLen;

		buffers.push_back(buffer);
	}

	// create the buffer
	ASSERT(apSetBuffer);

	unsigned char * pointer = *apSetBuffer = new unsigned char[estimatedSize];

#ifdef USE_COMPRESSION
	// initialize the compressor
	if (lzo_init() != LZO_E_OK)
	{
		// TODO:
		ASSERT(0);
		//printf("lzo_init() failed !!!\n");
		//return 4;
		return FALSE;
	}

	// compressor needs temporary memory
	unsigned char * wrkmem = new unsigned char[LZO1X_1_MEM_COMPRESS];
#endif

	// initialize the header
	MTMSIXBatchHelper * header = MTMSIXBatchHelper::InitializeHeader(pointer,
																																	 arMessages.size());


	// generate a unique SessionSet ID
	std::string uidString;
	MSIXUidGenerator::Generate(uidString);
	MSIXUidGenerator::Decode(header->GetUIDBuffer(), uidString);

	// add each message
	pointer = pointer + sizeof(MTMSIXBatchHeader);

	std::list<string>::iterator bufferit;
	for (bufferit = buffers.begin(); bufferit != buffers.end(); ++bufferit)
	{
		const string & buffer = *bufferit;

		int originalSize = buffer.length();

		// compressed bytes go right after the header
		unsigned char * destination = pointer + sizeof(MTMSIXMessageHeader);

		int compressionType;
#ifdef USE_COMPRESSION
		compressionType = MTMSIX_COMPRESS_LZO;
		unsigned int compressedLen = originalSize + originalSize / 64 + 16 + 3;

		int r = lzo1x_1_compress((const unsigned char *) buffer.c_str(),buffer.length(),
														 destination, &compressedLen, wrkmem);
		if (r != LZO_E_OK)
		{
			delete [] wrkmem;
			wrkmem = NULL;

			// TODO:
			ASSERT(0);
			return FALSE;
		}
#else
		compressionType = MTMSIX_COMPRESS_NONE;
		unsigned int compressedLen = originalSize;
		ASSERT(originalSize == (int) buffer.length());
		memcpy(destination, (const unsigned char *) buffer.c_str(), originalSize);
#endif


		MTMSIXMessageHelper * messageHeader =
			MTMSIXMessageHelper::InitializeHeader(pointer,
																						buffer.length(), // original size
																						compressedLen, // compressed size
																						compressionType,
																						FALSE);	// not encrypted

		pointer += sizeof(MTMSIXMessageHeader) + compressedLen;
	}

#ifdef USE_COMPRESSION
	delete [] wrkmem;
	wrkmem = NULL;
#endif

	int realLen = pointer - *apSetBuffer;
	ASSERT(realLen <= estimatedSize);

	arSetLen = realLen;

	return TRUE;
}

// MSIX, since it relates to MSIX parsing
BOOL MSIXNetMeterAPI::GetStatusFromMessage(MSIXMessage * apMessage,
																					 MSIXSessionStatusMap & arStatusMap, // used for new style status
																					 ErrorObject::ErrorCode & arCode, // used for old style status
																					 string & arMessage)              // used for old style status
{
	const char* procName = "MSIXNetMeterAPI::GetStatusFromMessage";
	MSIXObjectVector & contents = apMessage->GetContents();

	// these values must be set to something.  If they're not, the response
	// hasn't been understood
	arCode = MT_ERR_PARSE_ERROR;
	arMessage = "Unrecognized server response";

	for (int i = 0; i < (int) contents.size(); i++)
	{
		MSIXObject * obj = contents[i];
		ASSERT(obj);

		// is it an old style status message?
		MSIXStatus* stat = NULL;
		stat = ConvertUserObject(obj, stat);
		if (stat)
		{
			arCode = stat->GetCode();
			arMessage = ascii(stat->GetMessage()).c_str();
			return TRUE;
		}

		// then it must be a new style sessionstatus message
		MSIXSessionStatus * sessStat = NULL;
		sessStat = ConvertUserObject(obj, sessStat);
		if (!sessStat)
			return FALSE;

		// NOTE: this overwrites the previous error
		arCode = sessStat->GetCode();
		arMessage = ascii(sessStat->GetStatusMessage()).c_str();

		std::string uid = sessStat->GetUid().GetUid();
		if (uid.length() == 0)
		{
			// gets the response session's UID 
			MSIXSession * session = sessStat->GetSession();
			if (session)
				uid = (session->GetUid()).GetUid();

			if (uid.length() == 0)
			{
				ASSERT(arCode != 0);
				// is we still don't have a UID, there might be only
				// one request, and there's an error
				SetError(arCode, ERROR_MODULE, ERROR_LINE, procName, arMessage.c_str());
				return FALSE;
			}
		}

		ASSERT(uid.length() > 0);

		// stores session status in a map based on UID
		arStatusMap[uid] = sessStat;
	}

	return TRUE;
}



MSIXMessage * MSIXNetMeterAPI::CreateMessageWrapper(
	MSIXObject * apBody,
	const char * apUpdateId,
	const char * apTransactionID,
	const char * apListenerTransactionID,
	const char* apSessionContext,
	const char* apUserName,
	const char* apPassword,
	const char* apNamespace) // Just MSIX
{
	SDK_LOG_DEBUG("MSIXNetMeterAPI::CreateMessageWrapper");

	MSIXMessage * message = new MSIXMessage();
	message->SetCurrentTimestamp();
	message->SetVersion(L"2.0");
	message->GenerateUid();

	std::wstring wideEntity;
	ASCIIToWide(wideEntity, apUpdateId, strlen(apUpdateId));
	message->SetEntity(wideEntity.c_str());

	std::wstring wideTransactionID;
	ASCIIToWide(wideTransactionID, apTransactionID, strlen(apTransactionID));
	message->SetTransactionID(wideTransactionID.c_str());

	std::wstring wideListenerTransactionID;
	ASCIIToWide(wideListenerTransactionID, apListenerTransactionID, strlen(apListenerTransactionID));
	message->SetListenerTransactionID(wideListenerTransactionID.c_str());

	// ------- 3.0 work ----------
	std::wstring wideSessionContext;
	ASCIIToWide(wideSessionContext, apSessionContext, strlen(apSessionContext));
	message->SetSessionContext(wideSessionContext.c_str());

	std::wstring wideUserName;
	ASCIIToWide(wideUserName, apUserName, strlen(apUserName));
	message->SetSessionContextUserName(wideUserName.c_str());

	std::wstring widePassword;
	ASCIIToWide(widePassword, apPassword, strlen(apPassword));
	message->SetSessionContextPassword(widePassword.c_str());

	std::wstring wideNamespace;
	ASCIIToWide(wideNamespace, apNamespace, strlen(apNamespace));
	message->SetSessionContextNamespace(wideNamespace.c_str());
	// ------- 3.0 work ----------

	// important - we want to be able to delete the message without
	// deleting the contents
	message->DeleteBody(FALSE);
	if (apBody)
	{
		// finally, add the object to the body of the message
		message->AddToBody(apBody);
	}
	return message;
}


// NOTE: this function must call SetError if there's a problem
MSIXMessage * MSIXNetMeterAPI::SendRequest(MSIXParser & arParser,
														 MeteringServer & arServer,
														 const MSIXMessage & arMessage)
{
	const char* procName = "MSIXNetMeterAPI::SendRequest";
	MTSDK_MarkRegion region("SendRequest");

	SDK_LOG_INFO("POSTing to host %s", arServer.GetName());

	// stream the object to an in-memory buffer
	// do this before we begin the POST
	string obj;
	StreamObject(obj, arMessage);

   return SendRequest(arParser, arServer, obj);
	
}

MSIXMessage * MSIXNetMeterAPI::ParseResults(MSIXParser & arParser, const char * apInput, unsigned int aLen)
{
	MTSDK_MarkRegion region("ParseResults");

	//cout << "Results: " << apInput << endl;
	const char* procName = "MSIXNetMeterAPI::ParseResults";

	SDK_LOG_DEBUG("MSIXNetMeterAPI::ParseResults");

	int bufferSize = aLen;

	XMLObject * results = NULL;
	if (!arParser.ParseFinal(apInput, bufferSize, &results))
	{
		int code, line, column;
		long byte;
		const char * message;
		arParser.GetErrorInfo(code, message, line, column, byte);
			
		SDK_LOG_INFO("Parse failed: %s, line %d, col %d", message, line, column);

		// TODO: set programmer error
		SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, procName);
		results = NULL;
	}

	// NOTE: the parser needs to be restarted after this
	if (results)
	{
		MSIXMessage *obj = NULL;		
		obj = ConvertUserObject(results, obj);
		return obj;
	}
	else
		return NULL;
}

// ======= Begin Performance changes ============== //
MSIXMessage* MSIXNetMeterAPI::SendRequest(MSIXParser & arParser,
														MeteringServer & arServer,
														string obj)
{
   const char* procName = "MSIXNetMeterAPI::SendRequest";
	MTSDK_MarkRegion region("SendRequest");

	SDK_LOG_INFO("POSTing to host %s", arServer.GetName());

	char httpHeaders[256];
	char ** message;
	unsigned long messageLen;
	std::auto_ptr<unsigned char> outerCompressedMessagePtr;

	if (mUseCompression)
	{
		char * originalMessage = (char *) obj.c_str();
		unsigned long originalMessageLen = strlen(originalMessage);
		unsigned long compressedMessageLen = MTZLib::RecommendCompressedBufferSize(originalMessageLen);
		
		// allocate the compression buffer
		// unlike the originalMessage buffer we are responsible for cleaning this up ourselves!
		std::auto_ptr<unsigned char> compressedMessagePtr(new unsigned char[compressedMessageLen]);
		
		int ret = MTZLib::Compress(compressedMessagePtr.get(), &compressedMessageLen, 
															 (const unsigned char *) originalMessage, originalMessageLen);
		if (ret != Z_OK)
		{
			SDK_LOG_DEBUG("Error compressing data via zlib: %d", ret);
			SetError(MT_ERR_COMPRESS_BUFFER_OVERRUN, ERROR_MODULE, ERROR_LINE, procName);
			return NULL;
		}
		
		// generates the request's HTTP headers
		sprintf(httpHeaders, 
						"Content-Type: application/x-metratech-xml\n"
						"Content-Length: %d\n"
						"Content-Encoding: gzip\n"
						"Content-Length-Uncompressed: %d\n",
						compressedMessageLen, originalMessageLen);

		char * tmp = (char *) compressedMessagePtr.get();
		message = &tmp;
		messageLen = compressedMessageLen;

		// lets outerCompressedMessage autoptr handle compressedMessage's lifetime
		outerCompressedMessagePtr = compressedMessagePtr;
	}
	else
	{
		// NOTE: compression via the UNIX SDK is not yet supported
		// just send the old, standard HTTP headers (no content encoding)
		// one can manually disable MSIX compression via the
		// optional 'DisableCompression' registry key
		char * tmp = (char *) obj.c_str();
		message = &tmp;
		messageLen = strlen(*message);
		
		sprintf(httpHeaders, 
						"Content-Type: application/x-metratech-xml\n"
						"Content-Length: %d\n", messageLen);

	}
	

	// **** START OF NON-MSIX SPECIFIC STUFF - LIKELY MOVE TO ANOTHER METHOD ON THE BASE CLASS NETMETERAPI ****
	NetStreamConnection * conn = arServer.GetFreeConnection(mpNetStream, httpHeaders, METERING_SDK_SCRIPT);

	// could happen if the server/script is down
	if (!conn)
	{
		SetError(arServer.GetLastError());
		arServer.ReleaseConnection(conn);
		return NULL;
	}
	ASSERT(conn);

	// clear the sent bytes.  This is necessary for keep alive
	conn->ClearBytesProcessed();

	// send out the request
	if (!conn->SendBytes(*message, messageLen))
	{
		SetError(conn->GetLastError());
		arServer.ReleaseConnection(conn);
		return NULL;
	}

	if (!conn->EndRequest())
	{
		// use MT_ERR_AUTHORIZATION_FAILURE_BAD_CREDENTIALS.  authorization could 
		// fail because of bad credentials.
#ifdef WIN32
		if (conn->GetLastError()->GetCode() == ERROR_INTERNET_FORCE_RETRY)
		{
			SetError(MT_ERR_AUTHORIZATION_FAILURE_BAD_CREDENTIALS, 
							 ERROR_MODULE, 
							 ERROR_LINE, 
							 procName);
		}
		else
#endif
			SetError(conn->GetLastError());
		
		arServer.ReleaseConnection(conn);
		return NULL;
	}

	HttpResponse response = conn->GetResponse();
	if (!response.IsSuccessful())
	{
		SetError(MT_ERR_BAD_HTTP_RESPONSE, ERROR_MODULE, ERROR_LINE, procName);
		arServer.ReleaseConnection(conn);
		return NULL;
	}

	SDK_LOG_INFO("Parsing results");

	string responseBuffer;
	char buffer[4096];
	int size = 0;
	do
	{
		if (!conn->ReceiveBytes(buffer, sizeof(buffer) - 1, &size))
		{
			SetError(conn->GetLastError());
			arServer.ReleaseConnection(conn);
			return NULL;
		}
		responseBuffer.append(buffer, size);
	} while (size > 0);
	// *** END OF NON-MSIX SPECIFIC STUFF ****

	MSIXMessage * result = ParseResults(arParser, responseBuffer.c_str(), responseBuffer.length());

	arServer.ReleaseConnection(conn);


	// NOTE: parser must be restarted after this
	// NOTE: ParseResults calls seterror if necessary
	return result;
}

// ======= End Performance changes ============== //
/************************************ SOAPNetMeterAPI ***/

SOAPNetMeterAPI::SOAPNetMeterAPI(NetStream * apNetStream,
																 const char * apProxyName /* = NULL */)
																 // : mpNetStream(apNetStream) = can't instantiate base class members this way
{
	SDK_LOG_DEBUG("SOAPNetMeterAPI::SOAPNetMeterAPI");

	InitializeCriticalSection(&mNetworkGuard);

	if (apProxyName)
		mProxyName = apProxyName;

	// Initializing the *base class* member variabe
	mpNetStream = apNetStream;

	// we define the user agent
	mpNetStream->SetUserAgent(METRATECH_SDK_USER_AGENT);
	// use the first host they pass us
	mCurrentHost = 0;
}

SOAPNetMeterAPI::~SOAPNetMeterAPI()
{
	SDK_LOG_DEBUG("SOAPNetMeterAPI::~SOAPNetMeterAPI");

	DeleteCriticalSection(&mNetworkGuard);

	// Close deletes mpNetstream as well
	(void) Close();
   //if (mpNetStream)
	//{
	//	delete mpNetStream;
	//	mpNetStream = NULL;
	//}
	//ASSERT(!mpNetStream);
}

BOOL SOAPNetMeterAPI::StreamObject(string & arBuffer, const MeteringBatchImp & arObj)
{
	MTSDK_MarkRegion region("SOAP::StreamObject");

	// NOTE: pretty printing adds a lot of overhead to the message, but is 
	// useful for debugging. reenable it here if necessary

	// TODO: Make the serialization a little more elegant
	XMLWriter stringWrite;
	
	// Create buffer for conversion purposes
	char cvBuffer[256];

	// if not set, set it to some default values
	// Serialize batch properties
	sprintf(cvBuffer, "%d", arObj.GetBatchID());
	stringWrite.OutputSimpleAggregate("ID", cvBuffer);	// 1
	stringWrite.OutputSimpleAggregate("Name", arObj.GetName());	// 2
	stringWrite.OutputSimpleAggregate("Namespace", arObj.GetNameSpace());	// 3
	stringWrite.OutputSimpleAggregate("Status", arObj.GetStatus());	// 4

	// Outputing date
	string str1;
	MTFormatISOTime((long) arObj.GetCreationDate(), str1);
	stringWrite.OutputSimpleAggregate("CreationDate", str1.c_str()); // 5
	stringWrite.OutputSimpleAggregate("Source", arObj.GetSource());	// 6
	sprintf(cvBuffer, "%d", arObj.GetCompletedCount());											
	stringWrite.OutputSimpleAggregate("CompletedCount", cvBuffer);	// 8
	sprintf(cvBuffer, "%d", arObj.GetExpectedCount());
	stringWrite.OutputSimpleAggregate("ExpectedCount", cvBuffer);	// 9
	sprintf(cvBuffer, "%d", arObj.GetFailureCount());
	stringWrite.OutputSimpleAggregate("FailureCount", cvBuffer); // 10
	stringWrite.OutputSimpleAggregate("SequenceNumber", arObj.GetSequenceNumber());	// 11
	stringWrite.OutputSimpleAggregate("Comment", arObj.GetComment());	// 14
	
	// Outputing date
	string str2;
	MTFormatISOTime((long) arObj.GetSourceCreationDate(), str2);
	stringWrite.OutputSimpleAggregate("SourceCreationDate", str2.c_str()); // 15
	
	// Outputing date
	string str3;
	MTFormatISOTime((long) arObj.GetCompletionDate(), str3);
	stringWrite.OutputSimpleAggregate("CompletionDate", str3.c_str()); // 16

	sprintf(cvBuffer, "%d", arObj.GetMeteredCount());
	stringWrite.OutputSimpleAggregate("MeteredCount", cvBuffer); // 18

	const char * data;
	int len;
	stringWrite.GetData(&data, len);
	arBuffer = data;
	return TRUE;
}

BOOL SOAPNetMeterAPI::GeneratePropertyStream(string & arBuffer, const MeteringBatchImp & arObj, int arMethodType)
{
	MTSDK_MarkRegion region("SOAP::GeneratePropertyStream");

	// NOTE: pretty printing adds a lot of overhead to the message, but is useful for
	// debugging. reenable it here if necessary

	XMLWriter stringWrite;
	
	// Serialize batch properties
	if (arMethodType == SOAP_CALL_LOADBYNAME)
	{
		stringWrite.OutputSimpleAggregate("Name", arObj.GetName());			
		stringWrite.OutputSimpleAggregate("Namespace", arObj.GetNameSpace());
		stringWrite.OutputSimpleAggregate("SequenceNumber", arObj.GetSequenceNumber());
	}
	else if (arMethodType == SOAP_CALL_LOADBYUID) 
	{
		stringWrite.OutputSimpleAggregate("UID", arObj.GetUID());
	}
	else if (arMethodType == SOAP_CALL_LOADBYID) 
	{
		// Create buffer for conversion purposes
		char cvBuffer[256];
		// Serialize batch properties
		sprintf(cvBuffer, "%d", arObj.GetBatchID());
		stringWrite.OutputSimpleAggregate("ID", cvBuffer);
	}
	else if ((arMethodType == SOAP_CALL_MARKASFAILED) ||
					 (arMethodType == SOAP_CALL_MARKASDISMISSED) ||
					 (arMethodType == SOAP_CALL_MARKASBACKOUT) ||
					 (arMethodType == SOAP_CALL_MARKASACTIVE) ||
					 (arMethodType == SOAP_CALL_MARKASCOMPLETED))
	{
		stringWrite.OutputSimpleAggregate("UID", arObj.GetUID());
		stringWrite.OutputSimpleAggregate("Comment", arObj.GetComment());
	}
	else if (arMethodType == SOAP_CALL_UPDATEMETEREDCOUNT)
	{
		stringWrite.OutputSimpleAggregate("UID", arObj.GetUID());
		// Create buffer for conversion purposes
		char cvBuffer[256];
		// Serialize batch properties
		sprintf(cvBuffer, "%d", arObj.GetMeteredCount());
		stringWrite.OutputSimpleAggregate("MeteredCount", cvBuffer);
	}
	else
	{
		// TODO: record error
	}

	const char * data;
	int len;
	stringWrite.GetData(&data, len);
	arBuffer = data;
	return TRUE;
}

// Commit Batch for v3.5 - check strings
// We will send a batch message to a web service using the SOAP protocol
BOOL SOAPNetMeterAPI::CommitBatch(
		MeteringBatchImp & arBatch,
		int aAction)
{	
	const char* procName = "SOAPNetMeterAPI::CommitBatch";
	MTSDK_MarkRegion region("SOAP::CommitBatch");
	
	SDK_LOG_INFO("Start save/update batch process");

	// keep track of the first server
	MeteringServer * server, * first;
	server = first = CurrentMeteringServer();
	string result = "";
	BOOL bRequestSucess = FALSE;
	if (!server)
	{
		SetError(MT_ERR_NO_HOSTS, ERROR_MODULE, ERROR_LINE, procName);
		return FALSE;
	}

	do
	{
		// Clear any possible errors that might have been set by the attempt on 
		// the previous server
		ClearError();

		SDK_LOG_INFO("First server: %s", server->GetName());

		// result of the operation
		ErrorObject::ErrorCode resultCode = 0;
		string detailMessage;

		string soapMsg;
		string batchMsg;

		// Step 1 - Create XML SOAP Message - Either stream the batch object for 
		// creation/update or send request to retrieve server properties
		soapMsg = XML_HEADER;
		soapMsg += SOAP_ENVELOPE_HEADER;
		soapMsg += SOAP_BODY_HEADER;
		
		// For create we actually serialize the batch object. The soap message 
		// is slightly different...
		if (aAction == SOAP_CALL_CREATE) 
		{			
			soapMsg += SOAP_CREATE_METHOD;
			soapMsg += SOAP_BATCH_LISTENER_HEADER;
			StreamObject(batchMsg, arBatch);
			soapMsg += batchMsg;
			soapMsg += SOAP_BATCH_LISTENER_TRAILER;
			soapMsg += SOAP_CREATE_METHOD_TRAILER;
		}
		// For the LoadByX methods, we just serialize parameters 
		// (name/namespace or UID).
		else if (aAction == SOAP_CALL_LOADBYNAME) 
		{
			soapMsg += SOAP_LOADBYNAME_METHOD_HEADER;
			GeneratePropertyStream(batchMsg, arBatch, aAction);
			soapMsg += batchMsg;
			soapMsg += SOAP_LOADBYNAME_METHOD_TRAILER;
		}
		else if (aAction == SOAP_CALL_LOADBYUID) 
		{
			soapMsg += SOAP_LOADBYUID_METHOD_HEADER;
			GeneratePropertyStream(batchMsg, arBatch, aAction);
			soapMsg += batchMsg;
			soapMsg += SOAP_LOADBYUID_METHOD_TRAILER;
		}
		else if (aAction == SOAP_CALL_MARKASFAILED) 
		{
			soapMsg += SOAP_MARKASFAILED_METHOD_HEADER;
			GeneratePropertyStream(batchMsg, arBatch, aAction);
			soapMsg += batchMsg;
			soapMsg += SOAP_MARKASFAILED_METHOD_TRAILER;
		}
		else if (aAction == SOAP_CALL_MARKASDISMISSED) 
		{
			soapMsg += SOAP_MARKASDISMISSED_METHOD_HEADER;
			GeneratePropertyStream(batchMsg, arBatch, aAction);
			soapMsg += batchMsg;
			soapMsg += SOAP_MARKASDISMISSED_METHOD_TRAILER;
		}
		else if (aAction == SOAP_CALL_MARKASACTIVE) 
		{
			soapMsg += SOAP_MARKASACTIVE_METHOD_HEADER;
			GeneratePropertyStream(batchMsg, arBatch, aAction);
			soapMsg += batchMsg;
			soapMsg += SOAP_MARKASACTIVE_METHOD_TRAILER;
		}
		else if (aAction == SOAP_CALL_MARKASCOMPLETED) 
		{
			soapMsg += SOAP_MARKASCOMPLETED_METHOD_HEADER;
			GeneratePropertyStream(batchMsg, arBatch, aAction);
			soapMsg += batchMsg;
			soapMsg += SOAP_MARKASCOMPLETED_METHOD_TRAILER;
		}
		else if (aAction == SOAP_CALL_MARKASBACKOUT) 
		{
			soapMsg += SOAP_MARKASBACKOUT_METHOD_HEADER;
			GeneratePropertyStream(batchMsg, arBatch, aAction);
			soapMsg += batchMsg;
			soapMsg += SOAP_MARKASBACKOUT_METHOD_TRAILER;
		}
		else if (aAction == SOAP_CALL_UPDATEMETEREDCOUNT) 
		{
			soapMsg += SOAP_UPDATEMETEREDCOUNT_METHOD_HEADER;
			GeneratePropertyStream(batchMsg, arBatch, aAction);
			soapMsg += batchMsg;
			soapMsg += SOAP_UPDATEMETEREDCOUNT_METHOD_TRAILER;
		}

		soapMsg += SOAP_BODY_TRAILER;
		soapMsg += SOAP_ENVELOPE_TRAILER;

		// Step 2 - call SendRequest or similar method - probably need to create one
		result = SendRequest(*server, soapMsg.c_str(), aAction);
	
		if (!result.length())
		{
			if (!GetLastError())
			{
				// not sure what the cause is, so generate this error
				SetError(MT_ERR_BAD_HTTP_RESPONSE,ERROR_MODULE,ERROR_LINE,procName); 
				return FALSE;
			}
			else
				return FALSE;
		}
		else
		{
			bRequestSucess = TRUE;
		

			// Step 3 - Acknoledge batch creation and parse response.
			SDK_LOG_INFO("Batch creation/update request submitted, parsing response.");

			XMLConfigParser parser(NETMETER_PARSE_BUFFER_SIZE);
			parser.Init();

			XMLObject * objBatchResponse;
			if (!parser.ParseFinal(result.c_str(), result.length(), &objBatchResponse))
			{
				delete objBatchResponse;
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, procName);
				return FALSE;
			}

			// Call a method that will use the XMLObject with the response to take 
			// appropiate action.
			// There are 3 possibilities: Batch Creation, Save and Refresh.
			// -If this is a batch creation call, it should set the batchID in 
			// arBatch if the save was sucessfull. Otherwise just set the error.
			// -If this is a batch save, do nothing except handling errors.
			// -If this was a refresh call, then set the arBatch properties 
			// according to the values in the XML Object
			if (!UpdateBatchWithResponse(arBatch, objBatchResponse, aAction))
			{
				delete objBatchResponse;
				// UpdateBatchWithResponse should set the errors
				return FALSE;
			}

			delete objBatchResponse;
			// message didn't go through - go to the next server
		}

		// Try next server...
		server = NextMeteringServer(first);

		// ... but only if the response didn't come at all. If we got a response 
		// but it just failed, we should handle the error.
	} while ((!bRequestSucess) && (server != NULL));

	if (!bRequestSucess)
	{
		// Then we exited because the request failed for all servers...
		SetError(MT_ERR_NO_HOSTS, ERROR_MODULE, ERROR_LINE, procName);
		return FALSE;
	}

	return TRUE;
}

string SOAPNetMeterAPI::StripSOAPException(string aStrSOAPException)
{
	// we have to strip of everything that starts with Fusion log because
	// there is the Fusion Log Viewer stuff that we are not interested in
	// showing it the user
	int start = aStrSOAPException.find("Fusion log");
	if (start != -1)
	{		
		int end = aStrSOAPException.length() - start;
		return aStrSOAPException.erase(start, end);
	}
	else
		return aStrSOAPException;
}

long SOAPNetMeterAPI::ExtractMTErrorCode(string aStrStrippedException)
{
	// If it is MT message, there is code encapsulated in it
	// --------------------------------------------------------
	// MetraTech Error Code [E4020001]! Batch with name [xxx], 
	// namespace [MT] and sequence [xxx] already exists in the 
	// database
	// --------------------------------------------------------
	int start = 0;
	start = aStrStrippedException.find_first_not_of("MetraTech Error Code [");

	//printf("Stripped Exception = %s\n", aStrStrippedException.c_str());
	//printf("start = %d\n", start);

	//int find_first_not_of = aStrStrippedException.find_first_not_of("MetraTech Error Code [");
	//printf("find_first_not_of = %d\n", find_first_not_of);

	if (start == 23)
	{		
		string strErrorCode = aStrStrippedException.substr(start-1, 8);
		//printf("Error Code (String) = %s\n", strErrorCode.c_str());
		char* pStopStr;
		unsigned long val = strtoul(strErrorCode.c_str(),&pStopStr,16);
		return (long) val;
	}
	else
		return 0; // there was no MT error code
}

BOOL SOAPNetMeterAPI::UpdateBatchWithResponse(MeteringBatchImp & arBatch, 
																							XMLObject * apResponse, 
																							int aAction)
{
	const char* procName = "SOAPNetMeterAPI::UpdateBatchWithResponse";

	// Do dynamic casting
	XMLConfigNameVal * nameval = NULL;
	XMLConfigPropSet * soap_envelope = NULL;
	XMLConfigPropSet * soap_body = NULL;
	XMLConfigPropSet * soap_response = NULL;
	XMLConfigPropSet * soap_result = NULL;

	XMLConfigPropSet::XMLConfigObjectIterator it;
  XMLConfigPropSet::XMLConfigObjectIterator endit; 
	XMLConfigPropSet::XMLConfigObjectIterator itinternal; 
	XMLConfigPropSet::XMLConfigObjectIterator enditinternal; 

	soap_envelope = ConvertUserObject<XMLConfigPropSet>(apResponse, soap_envelope);
	if (soap_envelope->IsNameVal())
	{
		SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, procName);
		return FALSE;
	}

	// Grab envelope contents, expect it to be another propset (body)
	it = soap_envelope->GetContents().begin();
	soap_body = (*it)->AsPropSet();
	if (soap_body->IsNameVal())
	{
		SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, procName);
		return FALSE;
	}

	// Now we will check if an error was returned. Expect "soap:Fault" as the 
	// tag name inside 
	it = soap_body->GetContents().begin();
	XMLConfigObject * error_check = *it;
	if (0 == mtstrcasecmp(error_check->GetName(), SOAP_FAULT_TAG))
	{
		XMLConfigPropSet * soap_fault = (*it)->AsPropSet();
		
		it = soap_fault->GetContents().begin();
		endit = soap_fault->GetContents().end();
		
		string xml_error_string = "";

		while (it != endit)
		{
			XMLConfigObject * xml_fault_property = *it++;
			// we are only interested in the fault string, since there is no
			// real error code coming back
			if (0 == mtstrcasecmp(xml_fault_property->GetName(), SOAP_FAULTSTRING_TAG))
			{
				xml_error_string = ascii((xml_fault_property->AsNameVal())->GetString()).c_str();
				break;
			}
		}
		unsigned long resultCode = 0;
		const ErrorObject * errobj = GetLastError();

		if (errobj)
			resultCode = errobj->GetCode();

		//if (!resultCode)
		//	resultCode = MT_ERR_BAD_HTTP_RESPONSE; 

		// the SOAP exception is going to be huge, so strip it.
		// it might be wrapped with soap exception and we dont want to bubble
		// that all the way upto the user
		if (!resultCode)
		{
			string strStrippedSOAPException = StripSOAPException(xml_error_string);

			// extract the error code from this message
			long lngMTErrorCode = ExtractMTErrorCode(strStrippedSOAPException);
			if (lngMTErrorCode == 0)
				resultCode = MT_ERR_BAD_HTTP_RESPONSE; 
			 else
				resultCode = lngMTErrorCode; 
		
			SetError(resultCode, ERROR_MODULE, ERROR_LINE, procName);
			mpLastError->GetProgrammerDetail() = strStrippedSOAPException.c_str();
			return FALSE;
		}
	}

	// If we got here, then the response contains no error. Go ahead and try
	// to parse it.
	// There are 2 types of responses.
	// - One can contain objects
	// - One will contain plain properties
	// If the body has 2 elements, then this response contains a serialized
	// object. We expect it for Load calls.
	// Otherwise there are only properties. We expect a response with 
	// properties only for CreateOrUpdate
	long nElements = soap_body->GetContents().size();

	if (nElements == 1) // Simple response
	{
		// Grab body contents, expect it to be another propset (soap response)
		it = soap_body->GetContents().begin();
		XMLConfigObject * responsetype = *it;
		string methodname = responsetype->GetName();
		
		//if (0 == mtstrcasecmp(methodname, MARKASFAILED_RESPONSE_TAG))
		if (methodname == MARKASFAILED_RESPONSE_TAG)
		{
			arBatch.SetStatus("F");
			return TRUE;
		}
		else if (methodname == MARKASDISMISSED_RESPONSE_TAG)
		{
			arBatch.SetStatus("D");
			return TRUE;
		}
		else if (methodname == MARKASCOMPLETED_RESPONSE_TAG)
		{
			arBatch.SetStatus("C");
			return TRUE;
		}
		else if (methodname == MARKASACTIVE_RESPONSE_TAG)
		{
			arBatch.SetStatus("A");
			return TRUE;
		}
		else if (methodname == MARKASBACKOUT_RESPONSE_TAG)
		{
			arBatch.SetStatus("B");
			return TRUE;
		}
		else if (methodname == UPDATEMETEREDCOUNT_RESPONSE_TAG)
			return TRUE;
		else
			soap_response = (*it)->AsPropSet();
	}
	else if (nElements == 2) // Response with object
	{
		it = soap_body->GetContents().begin();
		*it++;
		soap_response = (*it)->AsPropSet();
	}
	else // Shouldn't get here - throw error with malformed response. TODO
	{
		SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, procName);
		return FALSE;
	}

	if (soap_response->IsNameVal())
	{
		SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, procName);
		return FALSE;
	}

	// At this point we can expect soap_response to contain the batch properties
	// We will examine each property and act accordingly
	it = soap_response->GetContents().begin();
	endit = soap_response->GetContents().end();

	// At this point, should be able to iterate the propset and retrieve the 
	// values you need.
	while (it != endit)
	{
		XMLConfigObject * xmlobj = *it++;

		// Check properties and retrieve values
		if (0 == mtstrcasecmp(xmlobj->GetName(), CREATE_RESULT_TAG))
		{
			string xmlvalue = ascii((xmlobj->AsNameVal())->GetString()).c_str();
			arBatch.SetUID(xmlvalue.c_str());
			return TRUE;
    }
		else if ((0 == mtstrcasecmp(xmlobj->GetName(), LOADBYNAME_RESULT_TAG)) ||
						 (0 == mtstrcasecmp(xmlobj->GetName(), LOADBYUID_RESULT_TAG)))
		{
			// at this point the xmlobj->GetName() is LoadByNameResult
			soap_result = (*soap_response->GetContents().begin())->AsPropSet();

			itinternal = soap_result->GetContents().begin();
			enditinternal = soap_result->GetContents().end();

			while (itinternal != enditinternal)
			{
				XMLConfigObject * xmlobj2 = *itinternal++;

				if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_NAME_TAG))
				{
					string xmlvalue = ascii((xmlobj2->AsNameVal())->GetString()).c_str();
					arBatch.SetName(xmlvalue.c_str());		
				}
				else if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_NAMESPACE_TAG))
				{
					string xmlvalue = ascii((xmlobj2->AsNameVal())->GetString()).c_str();
					arBatch.SetNameSpace(xmlvalue.c_str());				
				}
				else if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_STATUS_TAG))
				{
					string xmlvalue = ascii((xmlobj2->AsNameVal())->GetString()).c_str();
					arBatch.SetStatus(xmlvalue.c_str());		
				}
				else if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_SOURCE_TAG))
				{
					string xmlvalue = ascii((xmlobj2->AsNameVal())->GetString()).c_str();
					arBatch.SetSource(xmlvalue.c_str());		
				}
				else if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_COMPLETEDCOUNT_TAG))
				{
					string xmlvalue = ascii((xmlobj2->AsNameVal())->GetString()).c_str();
					arBatch.SetCompletedCount(atoi(xmlvalue.c_str()));
				}
				else if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_EXPECTEDCOUNT_TAG))
				{
					string xmlvalue = ascii((xmlobj2->AsNameVal())->GetString()).c_str();
					arBatch.SetExpectedCount(atoi(xmlvalue.c_str()));
				}
				else if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_FAILURECOUNT_TAG))
				{
					string xmlvalue = ascii((xmlobj2->AsNameVal())->GetString()).c_str();
					arBatch.SetFailureCount(atoi(xmlvalue.c_str()));		
				}
				else if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_SEQUENCENUMBER_TAG))
				{
					string xmlvalue = ascii((xmlobj2->AsNameVal())->GetString()).c_str();
					arBatch.SetSequenceNumber(xmlvalue.c_str());
				}
				else if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_SOURCECREATIONDATE_TAG))
				{
					string xmlvalue = ascii((xmlobj2->AsNameVal())->GetString()).c_str();
					time_t apConverted;
					MTParseISOTime(xmlvalue.c_str(), &apConverted);
					arBatch.SetSourceCreationDate(apConverted);
				}
				else if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_CREATIONDATE_TAG))
				{
					string xmlvalue = ascii((xmlobj2->AsNameVal())->GetString()).c_str();
					time_t apConverted;
					MTParseISOTime(xmlvalue.c_str(), &apConverted);
					arBatch.SetCreationDate(apConverted);
				}
				else if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_UID_TAG))
				{
					string xmlvalue = ascii((xmlobj2->AsNameVal())->GetString()).c_str();
					arBatch.SetUID(xmlvalue.c_str());		
				}
				else if (0 == mtstrcasecmp(xmlobj2->GetName(), BATCH_ID_TAG))
				{
					// dont do anything
					;
				}
			}
		}
		else
		{
			SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, procName);
			return FALSE;
		}

	}

	return TRUE;
}


// POST soap request and parse response.
string SOAPNetMeterAPI::SendRequest(MeteringServer & arServer, const char * arMessage, int aAction)
{
	MTSDK_MarkRegion region("SOAP::SendRequest");

	// NOTE: this function must call SetError if there's a problem
	SDK_LOG_DEBUG("MSIXNetMeterAPI::BeginBatch");

	SDK_LOG_INFO("POSTing to host %s", arServer.GetName());

	// stream the object to an in-memory buffer
	// do this before we begin the POST
	string obj = arMessage;

	SDK_LOG_INFO("Streamed object:\n%s", arMessage);

	SDK_LOG_INFO("Performing POST");

	char dataBuffer[256];

	string soapmethod = "";
	switch(aAction)
	{
		case SOAP_CALL_CREATE:
			soapmethod = "Create";
			break;
		case SOAP_CALL_LOADBYNAME:
			soapmethod = "LoadByName";
			break;
		case SOAP_CALL_LOADBYUID:
			soapmethod = "LoadByUID";
			break;
		case SOAP_CALL_MARKASFAILED:
			soapmethod = "MarkAsFailed";
			break;
		case SOAP_CALL_MARKASDISMISSED:
			soapmethod = "MarkAsDismissed";
			break;
		case SOAP_CALL_MARKASACTIVE:
			soapmethod = "MarkAsActive";
			break;
		case SOAP_CALL_MARKASBACKOUT:
			soapmethod = "MarkAsBackout";
			break;
		case SOAP_CALL_MARKASCOMPLETED:
			soapmethod = "MarkAsCompleted";
			break;
		case SOAP_CALL_UPDATEMETEREDCOUNT:
			soapmethod = "UpdateMeteredCount";
			break;
	}
	
	sprintf(dataBuffer, "SoapAction: \"http://metratech.com/webservices/%s\"\n" 
			"Content-Type: text/xml; charset=\"UTF-8\"\n" 
			"Content-Length: %d\n", soapmethod.c_str(), strlen(arMessage));

	NetStreamConnection * conn = arServer.GetFreeConnection(mpNetStream, dataBuffer, SOAP_SDK_SCRIPT);
	if (!conn)
	{
		// could happen if the server/script is down
		SetError(arServer.GetLastError());
		arServer.ReleaseConnection(conn);
		return "";
	}
	ASSERT(conn);

	string rs = "";
	
	// Method streams the message and gets a response. 
	// No protocols or de-serialization involved, just the basic stream in/out.
	SubmitNetRequest(conn, arMessage, rs);

	arServer.ReleaseConnection(conn);
	
	return rs;
}

MeteringBatchImp * SOAPNetMeterAPI::CreateBatch(NetMeterAPI * apMsixAPI)
{
	// Creating a new batch object and returning it.
	// UID will be generated when client calls "Save" on this object.

	MeteringBatchImp * batch = new MeteringBatchImp(this, apMsixAPI);
	return batch;
}

MeteringSessionImp * SOAPNetMeterAPI::CreateSession(const char * apName,
                                                    BOOL IsChild)
{
	MSIXMeteringSessionImp * session = new MSIXMeteringSessionImp(this);

	session->SetName(apName);
	// give it a new UID
	session->GenerateUid();
	return session;
}

MeteringSessionSetImp * SOAPNetMeterAPI::CreateSessionSet()
{
	MeteringSessionSetImp * sessionset = new MeteringSessionSetImp(this);

	return sessionset;
}

MeteringBatchImp * SOAPNetMeterAPI::Refresh(const char * apUID, NetMeterAPI * apMsixAPI)
{
	MeteringBatchImp * batch = new MeteringBatchImp(this, apMsixAPI);
	batch->SetUID(apUID);
	if (CommitBatch(*batch, SOAP_CALL_LOADBYUID))
		return batch;
	else
		return NULL;
}

MeteringBatchImp * SOAPNetMeterAPI::LoadBatchByName(const char * apName, const char * apNamespace, const char* apSequenceNumber, NetMeterAPI * apMsixAPI)
{
	MeteringBatchImp * batch = new MeteringBatchImp(this, apMsixAPI);
	batch->SetName(apName);
	batch->SetNameSpace(apNamespace);
	batch->SetSequenceNumber(apSequenceNumber);
	if (CommitBatch(*batch, SOAP_CALL_LOADBYNAME))
		return batch;
	else
		return NULL;
}

MeteringBatchImp * SOAPNetMeterAPI::LoadBatchByUID(const char * apUID, NetMeterAPI * apMsixAPI)
{
	MeteringBatchImp * batch = new MeteringBatchImp(this, apMsixAPI);
	batch->SetUID(apUID);
	if (CommitBatch(*batch, SOAP_CALL_LOADBYUID))
		return batch;
	else
		return NULL;
}

BOOL SOAPNetMeterAPI::MarkAsFailed(const char * apUID, const char* apComment, NetMeterAPI * apMsixAPI)
{
	MeteringBatchImp * batch = new MeteringBatchImp(this, apMsixAPI);
	batch->SetComment(apComment);
	batch->SetUID(apUID);
	if (CommitBatch(*batch, SOAP_CALL_MARKASFAILED))
		return TRUE;
	else
		return FALSE;
}

BOOL SOAPNetMeterAPI::MarkAsDismissed(const char * apUID, const char* apComment, NetMeterAPI * apMsixAPI)
{
	MeteringBatchImp * batch = new MeteringBatchImp(this, apMsixAPI);
	batch->SetComment(apComment);
	batch->SetUID(apUID);
	if (CommitBatch(*batch, SOAP_CALL_MARKASDISMISSED))
		return TRUE;
	else
		return FALSE;
}

BOOL SOAPNetMeterAPI::MarkAsActive(const char * apUID, const char* apComment, NetMeterAPI * apMsixAPI)
{
	MeteringBatchImp * batch = new MeteringBatchImp(this, apMsixAPI);
	batch->SetComment(apComment);
	batch->SetUID(apUID);
	if (CommitBatch(*batch, SOAP_CALL_MARKASACTIVE))
		return TRUE;
	else
		return FALSE;
}

BOOL SOAPNetMeterAPI::MarkAsCompleted(const char * apUID, const char* apComment, NetMeterAPI * apMsixAPI)
{
	MeteringBatchImp * batch = new MeteringBatchImp(this, apMsixAPI);
	batch->SetComment(apComment);
	batch->SetUID(apUID);
	if (CommitBatch(*batch, SOAP_CALL_MARKASCOMPLETED))
		return TRUE;
	else
		return FALSE;
}

BOOL SOAPNetMeterAPI::MarkAsBackout(const char * apUID, const char* apComment, NetMeterAPI * apMsixAPI)
{
	MeteringBatchImp * batch = new MeteringBatchImp(this, apMsixAPI);
	batch->SetComment(apComment);
	batch->SetUID(apUID);
	if (CommitBatch(*batch, SOAP_CALL_MARKASBACKOUT))
		return TRUE;
	else
		return FALSE;
}

BOOL SOAPNetMeterAPI::UpdateMeteredCount(const char * apUID, int aMeteredCount, NetMeterAPI * apMsixAPI)
{
	MeteringBatchImp * batch = new MeteringBatchImp(this, apMsixAPI);
	batch->SetUID(apUID);
	batch->SetMeteredCount(aMeteredCount);

	if (CommitBatch(*batch, SOAP_CALL_UPDATEMETEREDCOUNT))
		return TRUE;
	else
		return FALSE;
}

/*
MeteringSessionImp * SOAPNetMeterAPI::CreateSession(const char * apName,
                                                    BOOL IsChild)
{
	MSIXMeteringSessionImp * session = new MSIXMeteringSessionImp(this);

	session->SetName(apName);
	// give it a new UID
	session->GenerateUid();
	return session;
}
*/

// We will override the Close method since it does more than we would like, 
// for the SOAP API.  In particular we do not want to close the stream, 
// since it might be shared with another instance of NetMeterAPI.
BOOL SOAPNetMeterAPI::Close()
{
	SDK_LOG_DEBUG("SOAPNetMeterAPI::Close");
	return TRUE;
}

/************************************ MSIXMeteringSessionImp ***/

MSIXMeteringSessionImp::MSIXMeteringSessionImp(NetMeterAPI * apAPI) // MSIX
	: MeteringSessionImp(apAPI)
{
	mpLastSentTo = NULL;
}

MSIXMeteringSessionImp::~MSIXMeteringSessionImp() // MSIX
{ }


MeteringServer * MSIXMeteringSessionImp::GetLastRecipient() const // MSIX
{
	return mpLastSentTo;
}

void MSIXMeteringSessionImp::SetLastRecipient(MeteringServer * apServer) // MSIX
{
	mpLastSentTo = apServer;
}


/*********************************************** MeteringSDK ***/
// Feels like this should be on some other file - not *MSIX*API.CPP
MTMeter::MTMeter(MTMeterConfig & arConfig) : mpConfig(&arConfig)
{
	SDK_LOG_DEBUG("MTMeter::MTMeter");

	mpErrObj = NULL;
	mpAPI = NULL;
	mpSoapAPI = NULL;
}

MTMeter::~MTMeter()
{
	SDK_LOG_DEBUG("MTMeter::~MTMeter");

	delete mpErrObj;
	mpErrObj = NULL;
}

BOOL MTMeter::Startup()
{
	const char* procName = "MTMeter::Startup";

	mpAPI = mpConfig->GetAPI();
	mpSoapAPI = mpConfig->GetSoapAPI();
	ASSERT(mpAPI);
	ASSERT(mpSoapAPI);

	SDK_LOG_DEBUG("MTMeter::Startup");

#ifdef WIN32
	// allow user to read messages from the message DLL.
	if (!ErrorObject::AddModule(SDK_MESSAGE_NAME))
	{
		DWORD err = ::GetLastError();
		// TODO:

		SetError(MT_ERR_MESSAGE_MODULE_NOT_FOUND,
						 ERROR_MODULE, ERROR_LINE, procName);
		//return FALSE;
	}
#endif

	// initialize
	// TODO: call seterror
	if (!mpAPI->Init())
	{
		// TODO:
		//SetError(mpAPI->GetLastError());
		return FALSE;
	}

	// Initialize - todo: handle error
	if (!mpSoapAPI->Init())
	{
		return FALSE;
	}

	return TRUE;
}

BOOL MTMeter::Shutdown()
{
	SDK_LOG_DEBUG("MTMeter::Shutdown");

	// TODO: is this check correct?
	if (!mpAPI)
	{
		// not initialized
		// TODO:
		//SetError(MT_ERR_NOT_INITIALIZED,
		//ERROR_MODULE, ERROR_LINE, "MTMeter::Close");
		return FALSE;
	}

	if (!mpAPI->Close())
	{
		// TODO:
		//SetError(mpAPI->GetLastError());
		return FALSE;
	}

#ifdef WIN32
	// NOTE: error ignored: nothing can be done
	(void) ErrorObject::FreeMessageModules();
#endif

	return TRUE;
}

MTMeterSession * MTMeter::CreateSession(const char * apName)
{
	SDK_LOG_DEBUG("MTMeter::CreateSession");
	MeteringSessionSetImp * sessionSet = mpAPI->CreateSessionSet();
	StandaloneMeteringSessionImp * standAlone = new StandaloneMeteringSessionImp(sessionSet);
	if (!standAlone->CreateSession(apName))
	{
		delete standAlone;
		return NULL;
	}
	return standAlone;
}


MTMeterSessionSet * MTMeter::CreateSessionSet()
{
	SDK_LOG_DEBUG("MTMeter::CreateSessionSet");
	return mpAPI->CreateSessionSet();
}


MTMeterBatch * MTMeter::CreateBatch()
{
	SDK_LOG_DEBUG("MTMeter::CreateBatch");
	return mpSoapAPI->CreateBatch(mpAPI);
}

MTMeterBatch * MTMeter::Refresh(const char * apUID)
{
	SDK_LOG_DEBUG("MTMeter::Refresh");

	MTMeterBatch* pBatch = mpSoapAPI->LoadBatchByUID(apUID, mpAPI);
	if (pBatch == NULL)
	{
		SetError(mpSoapAPI->GetLastError());
		return NULL;
	}
	else
		return pBatch;
}

MTMeterBatch * MTMeter::LoadBatchByName(const char * apName, const char * apNameSpace, const char * apSequenceNumber)
{
	SDK_LOG_DEBUG("MTMeter::LoadBatchByName");

	MTMeterBatch* pBatch = mpSoapAPI->LoadBatchByName(apName, apNameSpace, apSequenceNumber, mpAPI);
	if (pBatch == NULL)
	{
		SetError(mpSoapAPI->GetLastError());
		return NULL;
	}
	else
		return pBatch;
}

MTMeterBatch * MTMeter::LoadBatchByUID(const char * apUID)
{
	SDK_LOG_DEBUG("MTMeter::LoadBatchByUID");

	MTMeterBatch* pBatch = mpSoapAPI->LoadBatchByUID(apUID, mpAPI);
	if (pBatch == NULL)
	{
		SetError(mpSoapAPI->GetLastError());
		return NULL;
	}
	else
		return pBatch;
}

unsigned long MTMeter::GetLastError() const
{
	if (!mpErrObj)
		return 0;
	return mpErrObj->GetCode();
}

MTMeterError * MTMeter::GetLastErrorObject() const
{
	if (!mpErrObj)
		return NULL;

	// copy it and return a new one
	MeteringErrorImp * imp = new MeteringErrorImp(mpErrObj);
	return imp;
}

void MTMeter::SetError(
	unsigned long aCode, const char * apModule,
	int aLine, const char * apProcedure)
{
	ErrorObject::ErrorCode code = (ErrorObject::ErrorCode) aCode;

	if (!mpErrObj)
		mpErrObj = new ErrorObject(code, apModule, aLine, apProcedure);
	else
		mpErrObj->Init(code, apModule, aLine, apProcedure);
}

void MTMeter::SetError(const ErrorObject * apError)
{
	if (!mpErrObj)
		mpErrObj = new ErrorObject(*apError);
	else
		*mpErrObj = *apError;
}



BOOL MTMeter::MeterFile (char * FileName)
{
    BOOL bRes = mpAPI->MeterFile(FileName);
	const ErrorObject * pError = mpAPI->GetLastError();
	if (pError)
		SetError (pError);
	return bRes;
}


char* MTMeter::GenerateNewSessionUID()
{
	string newUID;
	gGenerator.Generate(newUID);
	char* pNewGUID = new char[newUID.length()+1];
	strncpy(pNewGUID,newUID.c_str(),newUID.length());
	pNewGUID[newUID.length()] = '\0';
	return pNewGUID;
}

/***************************************** MTMeterHTTPConfig ***/

// Again, feels like this should be on some other file - not *MSIX*API.CPP

MTMeterHTTPConfig::MTMeterHTTPConfig(const char * apProxyName /* = NULL */,
																		 Protocol aProt /* = MSIX_PROTOCOL */)
{
	// NOTE: protocol is ignored

	// windows version of netstream
#ifdef WIN32
	Win32NetStream * netstream = new Win32NetStream;


#else
	UnixNetStream * netstream = new UnixNetStream;
#endif

	// NOTE: NetStream::Init is called by MSIXNetMeterAPI::Init()

	// MSIX version of API
	mpAPI = new MSIXNetMeterAPI(netstream, apProxyName);
	// SOAP version of API - mostly 3.5 changes, for handling batches
	mpSoapAPI = new SOAPNetMeterAPI(netstream, apProxyName);

	mpErrObj = NULL;

}

MTMeterHTTPConfig::~MTMeterHTTPConfig()
{
	// deleting mpAPI calls Close, so we don't need to call it explicitly
	delete mpAPI;
	delete mpSoapAPI;

	// NOTE: even if SDK logging is on, we don't close the stream.
	// it's up to the user of the SDK to manage the stream.
	delete mpErrObj;
	mpErrObj = NULL;
}

unsigned long MTMeterHTTPConfig::GetLastError() const
{
	if (!mpErrObj)
		return 0;
	return mpErrObj->GetCode();
}

MTMeterError * MTMeterHTTPConfig::GetLastErrorObject() const
{
	if (!mpErrObj)
		return NULL;

	// copy it and return a new one
	MeteringErrorImp * imp = new MeteringErrorImp(mpErrObj);
	return imp;
}

void MTMeterHTTPConfig::SetError(
	unsigned long aCode, const char * apModule,
	int aLine, const char * apProcedure)
{
	ErrorObject::ErrorCode code = (ErrorObject::ErrorCode) aCode;

	if (!mpErrObj)
		mpErrObj = new ErrorObject(code, apModule, aLine, apProcedure);
	else
		mpErrObj->Init(code, apModule, aLine, apProcedure);
}

void MTMeterHTTPConfig::SetError(const ErrorObject * apError)
{
	if (!mpErrObj)
		mpErrObj = new ErrorObject(*apError);
	else
		*mpErrObj = *apError;
}

NetMeterAPI * MTMeterHTTPConfig::GetAPI()
{
	return mpAPI;
}

// This has to be a little specific to SOAP, but it makes everything else simpler.
// Unfortunally we need to use 2 protocols, so we will have 2 instances of NetMeterAPI:
// one handling SOAP, the other handling MSIX calls.
NetMeterAPI * MTMeterHTTPConfig::GetSoapAPI()
{
	return mpSoapAPI;
}

BOOL MTMeterHTTPConfig::AddServer(int aPriority, 
																	const char * apHostName,
																	int aPort, 
																	BOOL aSecure, 
																	const char * apUsername,
																	const char * apPassword)
{
	const char* procName = "MTMeterHTTPConfig::AddServer";

	// set error here for blank hostname
	if (0 == mtstrcasecmp(apHostName, ""))
	{
		SetError(MT_ERR_BLANK_HOST_SPECIFIED, 
						 ERROR_MODULE, 
						 ERROR_LINE, 
						 procName);
		return FALSE;
	}

	// set error here for port <= 0 
	if (aPort <= 0)
	{
		SetError(MT_ERR_INCORRECT_PORT_SPECIFIED, 
						 ERROR_MODULE, 
						 ERROR_LINE, 
						 procName);
		return FALSE;
	}

	// NOTE: don't log the username/password for security reasons
	SDK_LOG_DEBUG("MTMeterHTTPConfig::AddServer(%s, %d, %d)", apHostName,
								aPort, aSecure);
	SDK_LOG_INFO("Host added: %s", apHostName);

	MeteringServer * server = new MeteringServer(apHostName, aPort, aSecure,
																							 apUsername, apPassword);

	server->SetPriority (aPriority);
	mpSoapAPI->AddHost(server);
	mpAPI->AddHost(server);

	return TRUE;
}


// @mfunc
// Set the duration in milliseconds that the operation will wait
// before timing out.
// @parm maximum timeout, in milliseconds
void MTMeterHTTPConfig::SetConnectTimeout(int aTimeout)
{
	SDK_LOG_DEBUG("MTMeterHTTPConfig::SetConnectTimeout(%d)", aTimeout);

	mpAPI->SetConnectTimeout(aTimeout);
}

// @mfunc
// Return the timeout in milliseconds.
// @rdesc timeout, in milliseconds
int MTMeterHTTPConfig::GetConnectTimeout() const
{
	SDK_LOG_DEBUG("MTMeterHTTPConfig::GetConnectTimeout");

	return mpAPI->GetConnectTimeout();
}


// @mfunc
// Set the number of retries to make before giving up.
// @parm the max number of retries requested.
void MTMeterHTTPConfig::SetConnectRetries(int aRetries)
{
	SDK_LOG_DEBUG("MTMeterHTTPConfig::SetConnectRetries(%d)", aRetries);

	mpAPI->SetConnectRetries(aRetries);
}

// @mfunc
// Get the number of retries
// @rdesc the max number of retries requested
int MTMeterHTTPConfig::GetConnectRetries() const
{
	SDK_LOG_DEBUG("MTMeterHTTPConfig::GetConnectRetries");

	return mpAPI->GetConnectRetries();
}

void MTMeterHTTPConfig::SetProxyData(string proxyData)
{
	mpAPI->SetProxyData(proxyData);
  mpSoapAPI->SetProxyData(proxyData);
}

string MTMeterHTTPConfig::GetProxyData() const
{
	return mpAPI->GetProxyData();
}

// ------------------------- MTDecimalValue -----------------------------

MTDecimalValue::~MTDecimalValue()
{
	if (mOwned)
		delete mpDecimalVal;
	mpDecimalVal = NULL;
}

MTDecimalValue::MTDecimalValue(MTDecimalVal * apVal, BOOL aOwned)
	: mpDecimalVal(apVal),
		mOwned(aOwned)
{ }

MTDecimalValue::MTDecimalValue(const MTDecimalVal * apVal,
															 BOOL aOwned)
	: mOwned(aOwned)
{
	ASSERT(!aOwned);
	mpDecimalVal = const_cast<MTDecimalVal *>(apVal);
}

BOOL MTDecimalValue::SetValue(double doubleVal)
{
	return mpDecimalVal->SetValue(doubleVal);
}

BOOL MTDecimalValue::SetValue(long longVal)
{
	return mpDecimalVal->SetValue(longVal);
}

BOOL MTDecimalValue::SetValue(const char * apStr)
{
	return mpDecimalVal->SetValue(apStr);
}

BOOL MTDecimalValue::SetValue(const wchar_t * apStr)
{
	return mpDecimalVal->SetValue(apStr);
}

BOOL MTDecimalValue::SetValue(long hiFixedValPart,
															long lowFixedValPart, int fractionalValPart)
{
	return mpDecimalVal->SetValue(hiFixedValPart, lowFixedValPart, fractionalValPart);
}

BOOL MTDecimalValue::Format(char * buffer, int & bufferSize)
{
	return mpDecimalVal->Format(buffer, bufferSize);
}

BOOL MTDecimalValue::Format(wchar_t * buffer, int & bufferSize)
{
	return mpDecimalVal->Format(buffer, bufferSize);
}

MTDecimalValue * MTDecimalValue::Create()
{
	MTDecimalVal * p = new MTDecimalVal;

	MTDecimalValue * wrapper = new MTDecimalValue(p, TRUE);
	return wrapper;
}

MTDecimalValue::MTDecimalValue()
{
	mpDecimalVal = new MTDecimalVal;
	mOwned = TRUE;
}

