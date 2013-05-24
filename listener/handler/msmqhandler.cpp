/**************************************************************************
 * @doc MSMQHANDLER
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
 * Created by: Travis Gebhardt
 *
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

#import "MTConfigLib.tlb"
#include <handler.h>
using namespace MTConfigLib;

#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <queue.h>
#include <MTMSIXUnicodeConversion.h>
#include <autocritical.h>
#include <perflog.h>


BOOL MSMQMessageHandler::Initialize(MeterHandler * meterHandler,
																		const ListenerInfo & listenerInfo,
																		const PipelineInfo & pipelineInfo)
{
	if (!MessageHandler::Initialize(meterHandler, listenerInfo, pipelineInfo))
		return FALSE;

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[msmqhandler]");

	// initializes the interface to the routing queue
	if (!mRoutingQueue.Init(listenerInfo, pipelineInfo))
	{
		SetError(mRoutingQueue.GetLastError());
		mLogger.LogThis(LOG_ERROR, "Unable to initialize routing queue");
		return FALSE;
	}

	// initializes the parser for validation
	mParser.SetValidateOnly(TRUE);
	if (!mParser.InitForValidate(pipelineInfo))
	{
		SetError(mParser.GetLastError());
		mLogger.LogThis(LOG_ERROR, "Unable to initialize MSIX parser for validation");
		return FALSE;
	}

	// initializes the compressor/encryptor
	try
	{
		HRESULT hr = mMessageUtils.CreateInstance("MetraTech.Pipeline.Messages.MessageUtils");
		if (FAILED(hr))
		{
			SetError(hr, ERROR_MODULE, ERROR_LINE, "MSMQMessageHandler::Initialize");
			mLogger.LogVarArgs(LOG_ERROR, "Unable to create MetraTech.Pipeline.Messages.MessageUtils: %d", hr);
			return FALSE;
		}
	}
	catch (_com_error & e)
	{
		ErrorObject * err = CreateErrorFromComError(e);
		SetError(err);
		mLogger.LogThis(LOG_ERROR, "Unable to initialize crypto functions");
		delete err;
		return FALSE;
	}

	return TRUE;
}



// NOTE: must be reentrant
BOOL MSMQMessageHandler::HandleMessage(const char * apMessage, string & arOutput,
																			 BOOL aParseOnly, BOOL & arCompleteImmediately,
																			 void * apArg, 
																			 BOOL & requestCompleted,
																			 ValidationData & validationData)
{
	const char * functionName = "MSMQMessageHandler::HandleMessage";

	MarkRegion region("HandleStream");

	BOOL success = TRUE;

	requestCompleted = FALSE;
	
	PropertyCount propCount;
	propCount.total = 0;
	propCount.smallStr = 0;
	propCount.mediumStr = 0;
	propCount.largeStr = 0;
	validationData.mpPropCount = &propCount;

	try
	{
		MarkEnterRegion("ConvertToAscii");

		MTMSIXUnicodeConversion ConversionObj(apMessage);
		const char* pTemporaryStream = ConversionObj.ConvertToASCII();

		MarkExitRegion("ConvertToAscii");


		MarkEnterRegion("ValidateMSIX");

		BOOL requiresFeedback;
		BOOL requiresEncryption = FALSE;
		BOOL isRetry;

		success = ValidateMSIXMessage(pTemporaryStream,
																	strlen(pTemporaryStream),
																	validationData,
																	requiresEncryption);
		requiresFeedback = validationData.mRequiresFeedback;
		isRetry = validationData.mIsRetry;


		MarkExitRegion("ValidateMSIX");

		if (success)
		{
			if (validationData.mHasServiceDefWithEncryptedProp)
				requiresEncryption = TRUE;

			arCompleteImmediately = !requiresFeedback;

			// TODO: is this needed?
			MSIXUidGenerator generator;

			std::string uidStr = validationData.mMessageID;

			wstring wideUid;
			ASCIIToWide(wideUid, uidStr);

			// compress if the message is close to 4MB
			BOOL requiresCompression = strlen(pTemporaryStream) + 1024 > (4 * 1024 * 1024);

			const char * message;
			int messageLen;

			_bstr_t encodedMessage;

			BOOL recreateBatch = requiresEncryption || requiresCompression;

			if (recreateBatch)
			{
				MarkRegion encodeRegion("EncodeMessage");

				encodedMessage =
					mMessageUtils->EncodeMessage(pTemporaryStream,
																			 uidStr.c_str(),
																			 requiresCompression,
																			 requiresEncryption);

				message = (const char *) encodedMessage;
				messageLen = encodedMessage.length();

				if (success)
				{
					if (requiresCompression && mLogger.IsOkToLog(LOG_DEBUG))
					{
						mLogger.LogVarArgs(LOG_DEBUG,
															 "Message compressed from %d bytes to %d bytes (%.0f%%)",
															 strlen(pTemporaryStream), messageLen,
															 ((double) messageLen / (double) strlen(pTemporaryStream)) * 100.0);
					}

				}
			}
			else
			{
				message = pTemporaryStream;
				messageLen = strlen(pTemporaryStream);
			}

			BOOL sendToPipeline = TRUE;

			if (success && requiresFeedback)
			{
				if (!mMeterHandler->PrepareForFeedback(uidStr.c_str(), uidStr.c_str(), apArg, isRetry,
																							 requestCompleted, sendToPipeline))
				{
					SetError(mMeterHandler->GetLastError());
					success = FALSE;
				}
			}
			//property counts needed by router to prevent overflow of session.bin
			//since this is normally counted in ValidateSession just fill with zeros

			if (success && sendToPipeline)
			{
				MarkRegion spoolRegion("SpoolMessage");

				if (!mRoutingQueue.SpoolMessage(message,
																				wideUid.c_str(),
																				FALSE,
																				requiresFeedback,
																				mMeterHandler->GetFeedbackQueue(),
																				propCount,
																				messageLen))
				{
					SetError(mRoutingQueue.GetLastError());
					success = FALSE;
				}
			}
		}
	}
	catch (_com_error & err)
	{
		success = FALSE;
		string buffer;
		StringFromComError(buffer, "Error handling message", err);
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
	}


	return success;

}

BOOL MSMQMessageHandler::ValidateMSIXMessage(const char * apMSIXStream,
																						 int aLen,
																						 ValidationData & arValidationData,
																						 BOOL & arRequiresEncryption)
{
	// TODO: for now this has to be single threaded
	AutoCriticalSection lockit(&mParserLock);

	if (!mParser.SetupParser())
	{
		SetError(mParser);
		return FALSE;
	}

	ISessionProduct** results = NULL;
	if (!mParser.Validate(apMSIXStream, aLen, results, arValidationData))
	{
		SetError(mParser);
		return FALSE;
	}

	return TRUE;
}



/********************************************** RoutingQueue ***/

BOOL RoutingQueue::Init(const ListenerInfo & arListenerInfo,
												const PipelineInfo & arPipelineInfo)
{
	const string machineStr = arListenerInfo.GetRouteToMachine();
	const string & queue = arListenerInfo.GetRouteToQueue();

	wstring longMachineName;
	const wchar_t * machine;
	if (machineStr.length() > 0)
	{
		ASCIIToWide(longMachineName, machineStr.c_str(),
								machineStr.length());
		machine = longMachineName.c_str();
	}
	else
		machine = NULL;

	wstring longQueueName;
	ASCIIToWide(longQueueName, queue.c_str(), queue.length());

	// make it unique to support multiple concurrent setups
///	MakeUnique(longQueueName);

	ErrorObject * err;
	if (!SetupQueue(mQueue, longQueueName.c_str(), machine,
									L"Routing Queue",	// label
									TRUE,					// journal
									TRUE,					// send access
									arPipelineInfo.UsePrivateQueues(),	// private
									FALSE,
									&err))
	{
		SetError(err);
		delete err;
		return FALSE;
	}

	if (!mQueueFlag.Init())
	{
		SetError(mQueueFlag);
		return FALSE;
	}

	return TRUE;
}

BOOL RoutingQueue::SpoolMessage(const char * apMessage,
																const wchar_t * apUID, BOOL aExpress,
																BOOL aFeedbackRequested,
																const MessageQueue & arFeedbackQueue,
																PropertyCount & arPropCount,
																int aMessageLen /* = 0 */)
{
	const char * functionName = "RoutingQueue::SpoolMessage";

	if (!mQueueFlag.WaitToSend(1 * 60 * 1000))
	{
		SetError(MT_ERR_SERVER_BUSY, ERROR_MODULE, ERROR_LINE, functionName,
						 "Timeout waiting for routing queue to empty");
		return FALSE;
	}

	//
	// set up the queue message
	//
	QueueMessage sendme;
	sendme.ClearProperties();

	// PERFORMANCE TWEAK ONLY!
	//aExpress = TRUE;
	sendme.SetExpressDelivery(aExpress);

	// app specific long = service ID
	//sendme.SetAppSpecificLong(aServiceID);

	// set the label of the message to the base 64 version of the UID
	sendme.SetLabel(apUID);

	// body = the message
	if (aMessageLen == 0)
		aMessageLen = strlen(apMessage);
	sendme.SetBody((UCHAR *) apMessage, aMessageLen);

	// sets the extension (in this case, the property count struct)
	sendme.SetExtension((UCHAR *) &arPropCount, sizeof(arPropCount));

	if (aFeedbackRequested)
		sendme.SetResponseQueue(arFeedbackQueue);

	if (aFeedbackRequested)
		sendme.SetPriority(PIPELINE_SYNCHRONOUS_PRIORITY);
	else
		sendme.SetPriority(PIPELINE_STANDARD_PRIORITY);

	// TODO: could use acknowledgements as well or instead of the deadletter queue
	//sendme.SetAdminQueue(mAckQueue);
	//sendme.SetAcknowledge(MQMSG_ACKNOWLEDGMENT_NACK_REACH_QUEUE);

	// TODO: could use a time to reach queue setting
	//sendme.SetTimeToReachQueue(20 * 60);

	sendme.SetJournal(MQMSG_DEADLETTER);

	if (!mQueue.Send(sendme))
	{
		SetError(mQueue.GetLastError());
		return FALSE;
	}

	return TRUE;
}

