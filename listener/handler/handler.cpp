/**************************************************************************
 * @doc HANDLER
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
 * $Date: 10/11/2002 5:52:02 PM$
 * $Author: Derek Young$
 * $Revision: 97$
 ***************************************************************************/


#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>

#import "MTConfigLib.tlb"
#include <handler.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
using namespace MTConfigLib;
#import "Rowset.tlb" rename ("EOF", "RowsetEOF") 

#include <mtprogids.h>
#include <sdk_msg.h>
#include <MSIX.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>
#include <reservedproperties.h>
#include <makeunique.h>
#include <ConfigDir.h>
#include <xmlconfig.h>
#include <pipemessages.h>
#include <batchsupport.h>
#include <pipelineconfig.h>
#include <queue.h>
#include <MTMSIXUnicodeConversion.h>
#include <tpstimer.h>
#include <autocritical.h>
#include <perflog.h>
#include <RowsetDefs.h>
#include <hostname.h>

/*************************************************** globals ***/



static BOOL StreamObject(string & arBuffer, const MSIXObject & arObj)
{
	XMLWriter stringWrite;
	arObj.Output(stringWrite);

	const char * data;
	int len;
	stringWrite.GetData(&data, len);
	arBuffer = data;
	return TRUE;
}

void CreateMessageWrapper(MSIXMessage * apMessage)
{
	apMessage->SetCurrentTimestamp();
	apMessage->SetVersion(L"1.0");
	apMessage->GenerateUid();
	// TODO: don't hardcode this hostname!
	apMessage->SetEntity(L"metratech.com");

	// NOTE: be sure to call DeleteBody with the correct argument
}

/********************************************** MeterHandler ***/

MeterHandler::MeterHandler() : mpMessageHandler(NULL)
{ } 

MeterHandler::~MeterHandler()
{
	if (mpMessageHandler)
	{
		delete mpMessageHandler;
		mpMessageHandler = NULL;
	}

	mFeedbackQueue.Stop();

	UnregisterListenerWithDB();

	::CoUninitialize();
}

// upserts into the t_listener table to show that this listener is now online 
void MeterHandler::RegisterListenerWithDB()
{
  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
  rowset->Init(L"Queries\\Pipeline");
  rowset->InitializeForStoredProc(L"UpsertListener");
  rowset->AddInputParameterToStoredProc(L"tx_machine", MTTYPE_W_VARCHAR, INPUT_PARAM, ::GetNTHostName());
  rowset->AddOutputParameterToStoredProc(L"id_listener", MTTYPE_INTEGER, OUTPUT_PARAM);
  rowset->ExecuteStoredProc();
}

// updates the t_listener table to show that this listener is now offline
void MeterHandler::UnregisterListenerWithDB()
{
  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
  rowset->Init(L"Queries\\Pipeline");
  rowset->SetQueryTag(L"__BRING_LISTENER_OFFLINE__");
  rowset->AddParam(L"%%TX_MACHINE%%", ::GetNTHostName());
  rowset->Execute();
}


BOOL MeterHandler::Init(FeedbackQueue::Hook apHook)
{
	const char * functionName = "MeterHandler::Init";

	try
	{

		//
		// initialize the logger
		//
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration("logging"), "[Handler]");

		//
		// initialize the logger where failures are logged
		//
		mMSIXLogger.Init(configReader.ReadConfiguration("logging\\msix\\"), "[MSIX]");

		if (!InitInternal(apHook))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to initialize handler");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			return FALSE;
		}
	}
	catch(_com_error & e)
	{
		mLogger.LogVarArgs(LOG_ERROR, "COM exception caught while initializing handler: %s", (const char *) e.Description());
		SetError(e.Error(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}

BOOL MeterHandler::InitInternal(FeedbackQueue::Hook apHook)
{
	const char * functionName = "MeterHandler::InitInternal";

	//
	// make sure COM is initialized since we might be in a wierd
	// context here
	//
	HRESULT hr = ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
	if (FAILED(hr))
		return FALSE;

	//
	// get the configuration directory
	//
	std::string configDir;
	if (!GetMTConfigDir(configDir))
	{
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	//
	// cache the name ID object
	//
 	hr = mNameID.CreateInstance(MTPROGID_NAMEID);
	if(!SUCCEEDED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to create name ID object");
		mLogger.LogThis(LOG_ERROR, "Unable to create Enum Config Object");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}

	//
	// cache the enum config object
	//
 	hr = mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);
	if(!SUCCEEDED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unable to create enum config object");
		mLogger.LogThis(LOG_ERROR, "Unable to create Enum Config Object");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}


	//
	// read the listener configuration file
	//
	IMTConfigPtr config(MTPROGID_CONFIG);

	ListenerInfoReader listenerReader;

	if (!listenerReader.ReadConfiguration(config, configDir.c_str(), mListenerInfo))
	{
		SetError(listenerReader.GetLastError());
		return FALSE;
	}


	PipelineInfoReader pipelineReader;
	PipelineInfo pipelineInfo;

	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
	{
		SetError(pipelineReader);
		return FALSE;
	}

	//
	// read the routing information file
	//
	MeterRouteReader routeReader;
	if (!routeReader.ReadConfiguration(config, configDir.c_str(), mRouteInfo))
	{
		SetError(routeReader.GetLastError());
		return FALSE;
	}


	//
	// initialize the interface to the feedback/response queue
	//
	if (!mFeedbackQueue.Init(apHook, mListenerInfo, mRouteInfo,
													 pipelineInfo.UsePrivateQueues()))
	{
		SetError(mFeedbackQueue.GetLastError());
		return FALSE;
	}

	//
	// set the default pipeline timeout
	//
	int defTimeout = mListenerInfo.GetDefaultFeedbackTimeout();
	if (defTimeout > 0)
	{
		mLogger.LogVarArgs(LOG_DEBUG, "Feedback timeout set to %d seconds",
											 defTimeout);
		mDefaultFeedbackTimeout = defTimeout * 1000;
	}
	else
	{
		mLogger.LogVarArgs(LOG_DEBUG, "Feedback timeout set to default %d seconds",
											 DEFAULT_FEEDBACK_TIMEOUT);
		mDefaultFeedbackTimeout = DEFAULT_FEEDBACK_TIMEOUT * 1000;
	}


	//
	// registers the listener with the database (just informational for now)
	//

	// NOTE: this must be done before initialization of the DBHandler 
	// (specifically the DBSessionBuilder) since it retrieves this ID 
	RegisterListenerWithDB();


	//
	// constructs the appropriate message handler
	//
	// 

	// determine the database vendor
	COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
	bool isOracle = (info.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);

	if(PipelineInfo::PERSISTENT_DATABASE_QUEUE == pipelineInfo.GetHarnessType())
	{
		if (isOracle)
			mpMessageHandler = new DBMessageHandler<COdbcPreparedArrayStatement>;
		else
			mpMessageHandler = new DBMessageHandler<COdbcPreparedBcpStatement>;
	}
	else
		mpMessageHandler = new MSMQMessageHandler;

	if (!mpMessageHandler->Initialize(this, mListenerInfo, pipelineInfo))
	{
		SetError(mpMessageHandler->GetLastError());
		return FALSE;
	}

	return TRUE;
}


// NOTE: must be reentrant
BOOL MeterHandler::HandleStream(const char * apMessage, string & arOutput,
																BOOL aParseOnly, BOOL & arCompleteImmediately,
																void * apArg)
{
	if (mMSIXLogger.IsOkToLog(LOG_DEBUG))
		mMSIXLogger.LogThis(LOG_DEBUG, apMessage);

	ValidationData validationData;
	BOOL requestCompleted = FALSE;
  BOOL success = TRUE;
	if (!mpMessageHandler->HandleMessage(apMessage, arOutput, aParseOnly, arCompleteImmediately, apArg,
																			 requestCompleted, validationData))
	{
		success = FALSE;
      mMSIXLogger.LogThis(LOG_ERROR, apMessage);
		SetError(mpMessageHandler->GetLastError());
	}

	// the request has already been completed, feedback has been sent
	if (requestCompleted)
		return success;


	// attempts to determine the version of the sdk used if possible
	float sdkVersion = 1.1f;
	if (validationData.mSDKVersion[0] != '\0')
	{
		// at least the version number was identified
		char * strend;
		double version = strtod(validationData.mSDKVersion, &strend);
		if (strend == validationData.mSDKVersion + strlen(validationData.mSDKVersion))
			sdkVersion = (float) version;
	}


	//
	// sends response (success or failure) back to client
	//
	MarkRegion responseRegion("PrepareResponse");
	
	ErrorObject::ErrorCode error;
	std::wstring messageBuffer;
	const wchar_t * errMessage = NULL;
	
	if (success)
		error = 0;
	else
	{
		const ErrorObject * errObj = mpMessageHandler->GetLastError();
		error = errObj->GetCode();
		const std::string & buffer = errObj->GetProgrammerDetail().c_str();
		ASCIIToWide(messageBuffer, buffer.c_str(), buffer.length());
		errMessage = messageBuffer.c_str();
	}

	//
	// generates response for validation errors
	//
	if (validationData.mErrors.size() > 0 && sdkVersion >= 2.0)
	{
		// individual errors for each validation failure
		MSIXMessage resp;
		CreateMessageWrapper(&resp);
		
		// delete the contents of the body
		resp.DeleteBody(TRUE);
		
		map<string, ErrorObject>::const_iterator it;
		for (it = validationData.mErrors.begin(); it != validationData.mErrors.end(); ++it)
		{
			const string & errorUID = it->first;
			const ErrorObject * errObj = &it->second;
			
			if (!success)
				mLogger.LogErrorObject(LOG_ERROR, errObj);
			
			MSIXSessionStatus * status = new MSIXSessionStatus();
			
			error = errObj->GetCode();
			const std::string & buffer = errObj->GetProgrammerDetail().c_str();
			ASCIIToWide(messageBuffer, buffer.c_str(), buffer.length());
			errMessage = messageBuffer.c_str();
			
			status->SetCode(error);
			if (errMessage)
				status->SetStatusMessage(MSIXString(errMessage));
			
			wstring wstrErrorUID;
			ASCIIToWide(wstrErrorUID, errorUID.c_str(), errorUID.length());
			MSIXUid uidErrorUid;
			uidErrorUid.Init(wstrErrorUID);
			
			status->SetUid(uidErrorUid);
			
			resp.AddToBody(status);
		}
		
		return StreamObject(arOutput, resp);
	}


	//
	// handles the success case or non-validation failures
	//
	if (!success)
	{
		if (GetLastErrorCode() == MT_ERR_SERVER_BUSY)
			// waiting for the routing queue to empty is not a true error
			// log as warning instead so Ops won't get paged
			mLogger.LogErrorObject(LOG_WARNING, GetLastError());
		else
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
	}
		
	MSIXMessage resp;
	CreateMessageWrapper(&resp);
	
	// don't delete anything in the body
	resp.DeleteBody(FALSE);
	
	MSIXStatus status;
	status.SetCode(error);
	if (errMessage && sdkVersion > 1.0)
		status.SetMessage(errMessage);
	
	resp.AddToBody(&status);
	
	return StreamObject(arOutput, resp);
}


BOOL MeterHandler::PrepareForFeedback(const char * externalMessageID,
																			const char * internalMessageID,
																						 void * apArg,
																						 BOOL isRetry,
																						 BOOL & arIsCompleted,
																						 BOOL & arSendToPipeline)
{
	MarkRegion prepareRegion("PrepareForFeedback");
	
	BOOL haveRecord;
	if (!mFeedbackQueue.PrepareForFeedback(externalMessageID, internalMessageID, apArg,
																								mDefaultFeedbackTimeout,
																								arIsCompleted, haveRecord))
	{
		SetError(mFeedbackQueue.GetLastError());
		return FALSE;
	}
		
	// never send to the pipeline again if this is a retry or we
	// are already waiting for a response
	if (isRetry)
		mLogger.LogVarArgs(LOG_DEBUG, "Message is a retry of a previous attempt");
	
	if (haveRecord)
		mLogger.LogVarArgs(LOG_DEBUG, "Feedback found for previous attempt");
	else
		mLogger.LogVarArgs(LOG_DEBUG, "No feedback found for previous attempt");

	if (isRetry || haveRecord)
		arSendToPipeline = FALSE;
	else
		arSendToPipeline = TRUE;


	if (arSendToPipeline)
		mLogger.LogVarArgs(LOG_DEBUG, "Message not being resent to pipeline");

	return TRUE;
}





/********************************************* FeedbackQueue ***/

FeedbackQueue::FeedbackQueue()
	: mExitFlag(FALSE),
		mHook(NULL),
		mMessageBuffer(NULL)
{ }
		

FeedbackQueue::~FeedbackQueue()
{
	// let the thread die..
	Stop();

	if (mMessageBuffer)
		delete [] mMessageBuffer;
}

BOOL FeedbackQueue::Init(Hook apHook,
												 const ListenerInfo & arListenerInfo,
												 const MeterRoutes & arRoutes,
												 BOOL aPrivateQueues)
{
	const char * functionName = "FeedbackQueue::Init";

	mHook = apHook;

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[Feedback]");

	mMSIXLogger.Init(configReader.ReadConfiguration("logging\\msix\\"), "[MSIX]");

	// what is the queue name?
	// find the queue in the routing information based on our
	// meter name.

	const std::string & metername = arListenerInfo.GetMeterName();

	const MeterRouteQueueInfo * info = NULL;
	MeterRouteQueueInfoList::const_iterator it;

	for (it = arRoutes.mQueueInfo.begin(); it != arRoutes.mQueueInfo.end(); ++it)
	{
		const MeterRouteQueueInfo & val = *it;
		std::string comparename = val.GetMeterName();
		if (comparename == metername)
		{
			info = &val;
			break;
		}
	}
	if (!info)
	{
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Meter name not found in route.xml file");
		return FALSE;
	}

	mMachineName = info->GetMachineName();
	mQueueName = info->GetQueueName();

	MakeUnique(mQueueName);

	const wchar_t * machine;
	if (mMachineName.length() > 0)
		machine = mMachineName.c_str();
	else
		machine = NULL;


	// allocates initial 2kb message buffer
 	mMessageBufferSize = 2048;  
	mMessageBuffer = new char[mMessageBufferSize + 1];

	ErrorObject * err;
	if (!SetupQueue(mQueue, mQueueName.c_str(), machine,
									L"Feedback Queue",	// label
									FALSE,					// journal
									FALSE,					// send access
									aPrivateQueues,	// private
									FALSE,				// not transactional
									&err))
	{
		SetError(err);
		delete err;
		return FALSE;
	}

	if (!StartThread())
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}

void FeedbackQueue::Stop()
{
	if (!IsRunning())
		return;

	// next time the thread wakes up have it exit
	mLogger.LogThis(LOG_DEBUG, "Signalling WaitForFeedback thread to exit");
	SetExitFlag();

	// wait for it to exit
	StopThread(INFINITE);
}

int FeedbackQueue::ThreadMain()
{
	if (!WaitForFeedback())
	{
		mLogger.LogThis(LOG_FATAL, "WaitForFeedback thread has exited with error!");
		mLogger.LogErrorObject(LOG_FATAL, GetLastError());
	}
	else
		mLogger.LogThis(LOG_DEBUG, "WaitForFeedback thread has exited with no error");

	return 0;
}


BOOL FeedbackQueue::WaitForFeedback()
{
	const char * functionName = "FeedbackQueue::WaitForFeedback";
	mLogger.LogThis(LOG_DEBUG, "Starting WaitForFeedback thread");

	wchar_t labelBuff[128];

	while (!GetExitFlag())
	{
		QueueMessage receiveme;
		receiveme.SetBody((UCHAR *) mMessageBuffer, mMessageBufferSize);
		receiveme.SetBodySize(0);
		receiveme.SetLabelLen(sizeof(labelBuff) - 1);
		receiveme.SetLabel(labelBuff);

		if (!mQueue.Receive(receiveme, 3 * 1000))
		{
			const ErrorObject * err = mQueue.GetLastError();

			// if we timed out, recheck the exit flag
			if(!TimeoutResponses())
				return FALSE;

			if (!err)
				continue;

			if (err->GetCode() == MQ_ERROR_BUFFER_OVERFLOW)
			{
				// the pre-allocated buffer was too small to hold the message
				// so let's double the buffer and try again!
				// NOTE: we may not get the same message on the second try for some reason
				// but this won't matter anymore (see ES1852 for more details)
				int newSize = mMessageBufferSize * 2;
				mLogger.LogVarArgs(LOG_DEBUG, "Doubling size of feedback message buffer from %d to %d bytes and trying again",
													 mMessageBufferSize, newSize);
				
				mMessageBufferSize = newSize;
				delete [] mMessageBuffer;
				mMessageBuffer = new char[mMessageBufferSize + 1];

				continue;
			}
			else
			{
				// shouldn't happen unless something's wrong with the queue

				// gets and null terminates the label
				// if receive fails, labelSize may not always be reliable so we are extra careful
				std::string asciiLabel; 
				try
				{
					const ULONG * labelSize = receiveme.GetLabelLen();
					ASSERT(labelSize);
					labelBuff[*labelSize] = '\0';
					std::wstring wideLabel(labelBuff);
					asciiLabel = ascii(wideLabel);
				}
				catch (...)
				{
					asciiLabel = "????????????????????";
				}

				mLogger.LogVarArgs(LOG_ERROR, "Failure receiving body of feedback message: label='%s'; bufferSize=%d",
													 asciiLabel.c_str(), mMessageBufferSize);
				SetError(err);
				return FALSE;
			}
		}

		// gets and null terminates the label
		const ULONG * labelSize = receiveme.GetLabelLen();
		ASSERT(labelSize);
		labelBuff[*labelSize] = '\0';
		std::wstring wideLabel(labelBuff);
		std::string asciiLabel = ascii(wideLabel);

		// null terminates the message with the actual message size
		const ULONG * size = receiveme.GetBodySize();
		int actualMessageSize = *size;
		mMessageBuffer[actualMessageSize] = '\0';


		BOOL result = HandleFeedback(mMessageBuffer, asciiLabel.c_str()); 
		// TODO: what do we do if the result is false?
		if (!result && mLogger.IsOkToLog(LOG_ERROR))
		{
			mLogger.LogVarArgs(LOG_ERROR, "Unable to handle feedback message for %s", 
												 (const char *) asciiLabel.c_str());
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		}
	}

	return TRUE;
}


BOOL FeedbackQueue::HandleFeedback(const char * apMessage, const char * apLabel)
{
	MarkRegion feedbackRegion("HandleFeedback");
	const char * functionName = "FeedbackQueue::HandleFeedback";

	mLogger.LogVarArgs(LOG_DEBUG, "Handling feedback for message %s", apLabel);

	// lookup the UID in the map of UIDs we're waiting for
	string uid(apLabel);
	CompletionInfo * arg;
  BOOL result;

  do
  {
    AutoCriticalSection acs(&mLock);
    MessageIDMap::iterator it = mMessageIDMap.find(uid);
    if (it == mMessageIDMap.end())
    {
      result = FALSE;
      arg = NULL;
    }
    else
    {
      result = TRUE;
      arg = it->second;
    }
  } while(false);

	if (!result)
	{
		mLogger.LogVarArgs(LOG_ERROR, "Not expecting feedback for message %s", apLabel);
		SetError(PIPE_ERR_ROUTING_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// we don't need the parser to maintain a buffer since we
	// have the entire string
	MSIXParser parser(0);
	if (!parser.Init())
	{
		SetError(parser.GetLastError());
		return FALSE;
	}

	MarkEnterRegion("ParseResponse");
	// NOTE: results has to be deleted later
	XMLObject * results;
	BOOL success = TRUE;
	if (!parser.ParseFinal(apMessage, strlen(apMessage), &results))
	{
		// TODO: fix this!
		const ErrorObject * err = parser.GetLastError();
		const std::string & details = err->GetProgrammerDetail().c_str();

		mLogger.LogVarArgs(LOG_DEBUG, "Parse error: %s", (const char *) details.c_str());

		// TODO: use the error from the parser or use our own?
		SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 "Unparsable message returned from Pipeline");
		//SetError(parser.GetLastError());
		success = FALSE;
	}
	MarkExitRegion("ParseResponse");

	//
	// the message returned from the pipeline is either a sessionstatus record
	// or a msix record with several sessionstatus records contained within.
	//
	MSIXSessionStatus * status = NULL;

	// either a pointer to the msix record returned from the pipeline
	// or a pointer to a generated status message
	MSIXMessage * resp = NULL;

	// holder for the message, if we receive an individual sessionstatus record
	MSIXMessage generatedMessage;

	if (success)
	{
		status = ConvertUserObject<MSIXSessionStatus>(results, status);
		if (status)
		{
			CreateMessageWrapper(&generatedMessage);

			// delete the status message in the body - it's on the heap
			generatedMessage.DeleteBody(TRUE);

			// add the status
			generatedMessage.AddToBody(status);

			resp = &generatedMessage;
		}
		else
		{
			resp = ConvertUserObject<MSIXMessage>(results, resp);
			if (!resp)
			{
				// not a recognized message!

				// not the best error, but it will do.  It's really a valid message
				// or fragment of a message that is of an incorrect type.
				SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
								 "Unrecognized message returned from Pipeline");
				success = FALSE;
			}
		}
	}

	// if we don't have a status object (for example, parse error)
	// generate our own to hold the error
	MSIXSessionStatus fallbackStatus;

	if (!success)
	{
		const ErrorObject * obj = GetLastError();
		fallbackStatus.SetCode(obj->GetCode());

		if (obj->GetProgrammerDetail().length() > 0)
		{
			std::wstring wideDetail;
			ASCIIToWide(wideDetail, obj->GetProgrammerDetail());

			fallbackStatus.SetStatusMessage(wideDetail);
		}

		CreateMessageWrapper(&generatedMessage);

		// DON'T delete the status message in the body - it's on the stack
		generatedMessage.DeleteBody(FALSE);

		// add our fallback status
		generatedMessage.AddToBody(&fallbackStatus);

		resp = &generatedMessage;
	}

	MarkEnterRegion("StreamResponse");

	std::string output;
	StreamObject(output, *resp);

	MarkExitRegion("StreamResponse");

	mMSIXLogger.LogThis(LOG_DEBUG, "Session feedback");
	mMSIXLogger.LogThis(LOG_DEBUG, output.c_str());

	// no longer need the parsed representation of the results
	delete results;

	if (!arg->StillActive())
	{
		ASSERT(!arg->HaveOutput());
		arg->mOutput = output;
//		mLogger.LogVarArgs(LOG_WARNING, "Discarding feedback for %s since it has already timed out", apLabel);
//		if(!RemoveSessionID((std::string) uid.c_str()))
//			return FALSE;
	}
	else
	{
		ASSERT(mHook);
		ASSERT(arg->mHookArgument);
		mHook(uid.c_str(), output.c_str(), arg->mHookArgument);

		if(!RemoveMessageID((std::string) uid.c_str()))
			return FALSE;
	}

	return TRUE;
}

BOOL FeedbackQueue::PrepareForFeedback(const char * externalMessageID,
																			 const char * internalMessageID,
																			 void * apArg,
																							int aTimeoutMillis,
																							BOOL & arCompleted,
																							BOOL & arIsRetry)
{
	mLogger.LogVarArgs(LOG_DEBUG, "Preparing for feedback on message (extID='%s'; intID='%s') with timeout of %d",
										 externalMessageID, internalMessageID, aTimeoutMillis);

	AutoCriticalSection acs(&mLock);

	std::string uid; // internal message ID of first synchronous attempt

	// looks up the external MSIX message ID (SDK generated) to find the internal message ID
	// of the first synchronous attempt (if any). The MSIX message ID is always the same for a retry
	// but the DB message ID is not. This mapping is important to make sure synchronous
	// retries are correctly matched up with their respective feedback.
	// NOTE: synchronous feedback coming back from the pipeline is only labeled with the internal message ID
	FirstAttemptMessageIDMap::iterator firstIt = mFirstAttemptMessageIDMap.find(externalMessageID);
	if (firstIt == mFirstAttemptMessageIDMap.end())
	{
		// this is the very first attempt... so let's remember it
		mFirstAttemptMessageIDMap[externalMessageID] = internalMessageID;
		uid = internalMessageID;
	}
	else
		uid = firstIt->second;


	MessageIDMap::iterator it = mMessageIDMap.find(uid);
	if (it != mMessageIDMap.end())
	{
		CompletionInfo * completion = it->second;

		// if the hook argument is not null then the client is retrying while
		// an outstanding connection is still active
		if (completion->StillActive())
		{
			// TODO: fix this
			ASSERT(0);
		}

		if (completion->HaveOutput())
		{
			// the output is waiting for us already
			mHook(internalMessageID, completion->mOutput.c_str(), apArg);
			arCompleted = TRUE;

			// clean up the completion info
			mMessageIDMap.erase(uid);
			mFirstAttemptMessageIDMap.erase(externalMessageID);
			delete completion;
		}
		else
		{
			// still not complete - reset the timer
			completion->mTimestamp = GetTickCount();
			completion->mTimeout = aTimeoutMillis;
			completion->mHookArgument = apArg;
			arCompleted = FALSE;
		}

		arIsRetry = TRUE;
	}
	else
	{
		CompletionInfo * completion = new CompletionInfo;
		completion->mHookArgument = apArg;
		completion->mTimestamp = GetTickCount();
		completion->mTimeout = aTimeoutMillis;
		mMessageIDMap[uid] = completion;
		arCompleted = FALSE;
		arIsRetry = FALSE;
	}

	return TRUE;
}




BOOL
FeedbackQueue::TimeoutResponses()
{
  AutoCriticalSection acs(&mLock);
	long currenttime = GetTickCount();
	string uid;
	CompletionInfo * completion;

	MessageIDMap::iterator it;
	it = mMessageIDMap.begin();
	while (it != mMessageIDMap.end())
	{
		uid = it->first;
		completion = it->second;

		if (completion->mTimeout != -1
				&& completion->mTimestamp < (currenttime - completion->mTimeout))
		{
			MarkRegion timeoutRegion("TimeoutResponse");

			MSIXMessage resp;
			CreateMessageWrapper(&resp);
			resp.DeleteBody(FALSE);
			MSIXSessionStatus status;
			status.SetCode(MT_ERR_SYN_TIMEOUT);
			status.SetStatusMessage(wstring(L"feedback timeout"));
			resp.AddToBody(&status);
			std::string output;
			StreamObject(output, resp);
			ASSERT(mHook);
			ASSERT(completion->mHookArgument);
			mHook(uid.c_str(), output.c_str(), completion->mHookArgument);

			// the argument to the hook is no longer valid.
			// we'll get a new argument if the client retries.
			completion->mHookArgument = NULL;

			completion->mTimeout = -1;

			mLogger.LogVarArgs(LOG_WARNING, "Feedback timeout. Waiting indefinitely for response to %s after timeout", uid.c_str());
			mLogger.LogVarArgs(LOG_DEBUG, "Currently waiting for %d responses", mMessageIDMap.size());
		}
		else
			// move to the next element
			++it;
	}
	return TRUE;
}

BOOL FeedbackQueue::RemoveMessageID(const std::string & arUid)
{
	string uid(arUid);

	CompletionInfo * arg;
  std::size_t sz = 0;
  do
  {
    AutoCriticalSection acs(&mLock);
    MessageIDMap::iterator it = mMessageIDMap.find(uid);
    if (it == mMessageIDMap.end())
    {
      mLogger.LogVarArgs(LOG_ERROR, "Message %s is not found in the map", uid);
      return FALSE;
    }

    arg = it->second;

    delete arg;
    mMessageIDMap.erase(uid);
    sz = mMessageIDMap.size();
  } while(false);

	mLogger.LogVarArgs(LOG_DEBUG, "No longer waiting for %s.", uid.c_str());
	mLogger.LogVarArgs(LOG_DEBUG, "Currently waiting for %d responses", sz);

	return TRUE;
}
