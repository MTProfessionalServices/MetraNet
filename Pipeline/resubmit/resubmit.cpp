/**************************************************************************
 * RESUBMIT
 *
 * Copyright 1997-2001 by MetraTech Corp.
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <resubmit.h>
#include <loggerconfig.h>
#include <queue.h>
#include <makeunique.h>
#import <MTConfigLib.tlb>
#include <pipelineconfig.h>
#include <pipemessages.h>
#include <mtprogids.h>

/****************************************** PipelineResubmit ***/

PipelineResubmit::PipelineResubmit()
{ }

PipelineResubmit::~PipelineResubmit()
{ }

BOOL PipelineResubmit::Init(const PipelineInfo & arPipelineInfo)
{
	const char * functionName = "PipelineResubmit::Init";

	// TODO: we don't always need send access
	BOOL sendAccess = TRUE;

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[Resubmit]");

	ErrorObject * queueErr;


	std::wstring queueName = arPipelineInfo.GetResubmitQueueName();
	MakeUnique(queueName);

	const std::wstring & machine = arPipelineInfo.GetResubmitQueueMachine();

	if (!SetupQueue(mResubmitQueue, queueName.c_str(), machine.c_str(),
									L"Resubmit queue",
									TRUE,					// journal
									sendAccess,				// send access
									arPipelineInfo.UsePrivateQueues(),	// private
									TRUE,				// transactional
									&queueErr))
	{
		SetError(queueErr);
		delete queueErr;
		mLogger.LogThis(LOG_ERROR, "Could not setup resubmit queue");
		return FALSE;
	}
	//
	// initialize the pipeline control object
	//
	mLogger.LogThis(LOG_DEBUG, "Initializing pipeline control object");
	HRESULT hr = mPipelineControl.CreateInstance(MTPROGID_PIPELINE);
	if (FAILED(hr))
	{
		// TODO: pass win32 or hresult?
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName,
			"Could not create an instance of " MTPROGID_PIPELINE);
		return FALSE;
	}
	

	//
	// initialize the helper to encrypt/compress errors
	//
	hr = mMessageUtils.CreateInstance("MetraTech.Pipeline.Messages.MessageUtils");
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}


BOOL PipelineResubmit::SpoolMessage(const char * apMessage,
																		const wchar_t * apUID,
																		PropertyCount & arPropCount,
																		QueueTransaction * apTran,
																		int aMessageLen /* = 0 */)
{
	const char * functionName = "PipelineResubmit::SpoolMessage";

	BOOL encrypt = FALSE;
	int messageLength = aMessageLen > 0 ? aMessageLen : strlen(apMessage);
	BOOL compress = messageLength + 1024 > (4 * 1024 * 1024);

	// TODO: we could check to see if encryption is required, but
	// that can slow down processing considerably since it requires a full
	// parse of the message.  I think we can just assume encryption is
	// not needed.
#if 0
	if (mPipelineControl->RequiresEncryption(apMessage) == VARIANT_TRUE)
		// encrypt the message so it doesn't end up on the queue in clear text
		encrypt = TRUE;
#endif


	const char * message;
	_bstr_t encoded;

	if (encrypt || compress)
	{
		encoded = mMessageUtils->EncodeMessage(apMessage, apUID,
																					 compress, encrypt);

		message = encoded;
		messageLength = encoded.length();
	}
	else
	{
		message = apMessage;
		// message length is already set
	}

	//
	// set up the queue message
	//
	QueueMessage sendme;
	sendme.ClearProperties();

	sendme.SetExpressDelivery(FALSE);

	// app specific long = service ID
	//sendme.SetAppSpecificLong(aServiceID);

	// set the label of the message to the base 64 version of the UID
	sendme.SetLabel(apUID);

	// body = the message
	sendme.SetBody((UCHAR *) message, messageLength);

	// sets the extension (in this case, the property count struct)
	sendme.SetExtension((UCHAR *) &arPropCount, sizeof(arPropCount));

	sendme.SetPriority(PIPELINE_STANDARD_PRIORITY);

	// TODO: could use acknowledgements as well or instead of the deadletter queue
	//sendme.SetAdminQueue(mAckQueue);
	//sendme.SetAcknowledge(MQMSG_ACKNOWLEDGMENT_NACK_REACH_QUEUE);

	// TODO: could use a time to reach queue setting
	//sendme.SetTimeToReachQueue(20 * 60);

	sendme.SetJournal(MQMSG_DEADLETTER);

	BOOL success;
	if (apTran)
	{
		success = mResubmitQueue.Send(sendme, *apTran);
		if (!success)
			SetError(mResubmitQueue);
	}
	else
	{
		success = mResubmitQueue.Send(sendme);
		if (!success)
			SetError(mResubmitQueue);
	}

	return success;
}
