/**************************************************************************
 * @doc MSGSEND
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

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF")
#import "MTConfigLib.tlb"

#include <msgsend.h>
#include <pipemessages.h>
#include <makeunique.h>
#include <stdutils.h>


StageMessageTransmitter::StageMessageTransmitter() : mMessagesSent(0)
{ }

StageMessageTransmitter::~StageMessageTransmitter()
{
	std::map<std::string, MessageQueue *>::iterator it;
	for (it = mStageQueues.begin(); it != mStageQueues.end(); it++)
	{
		MessageQueue * queue = it->second;
		ASSERT(queue);
		delete queue;
	}
	mStageQueues.clear();
}

static void MakeStageQueueName(std::wstring & arBuffer, const wchar_t * apStage)
{
	arBuffer = apStage;
	arBuffer += L"Queue";
	MakeUnique(arBuffer);
}

static void MakeStageQueueName(std::string & arBuffer, const char * apStage)
{
	arBuffer = apStage;
	arBuffer += "Queue";
	MakeUnique(arBuffer);
}

BOOL StageMessageTransmitter::Init(NTLogger & arLogger, BOOL aPrivate)
{
	mUsePrivateQueues = aPrivate;

	mLogger = arLogger;

 	// initialize the master control queue.
	MessageQueueProps queueProps;

	queueProps.SetLabel(L"Pipeline controller's queue");
	queueProps.SetJournal(FALSE);

	std::wstring controlQueueName(PIPELINE_CONTROL_QUEUE);
	MakeUnique(controlQueueName);
	if (!mPipelineControlQueue.CreateQueue(controlQueueName.c_str(),
																				 aPrivate, queueProps))
	{
		if (mPipelineControlQueue.GetLastError()->GetCode()
				!= MQ_ERROR_QUEUE_EXISTS)
		{
			SetError(mPipelineControlQueue.GetLastError());
			return FALSE;
		}
		mLogger.LogThis(LOG_DEBUG, "Control queue already exists");
	}
	else
		mLogger.LogThis(LOG_DEBUG, "Control queue created sucessfully");

	if (!mPipelineControlQueue.Init(controlQueueName.c_str(), aPrivate)
			|| !mPipelineControlQueue.Open(MQ_SEND_ACCESS, MQ_DENY_NONE))
	{
		SetError(mPipelineControlQueue.GetLastError(),
						 "Could not initialize control queue.");
		return FALSE;
	}

	return TRUE;
}

BOOL StageMessageTransmitter::Init(NTLogger & arLogger, const char * apNextStageName,
																	 BOOL aPrivate)
{
	if (!Init(arLogger, aPrivate))
		return FALSE;

	//
	// there is a stage next to send messages to
	//
	MakeStageQueueName(mNextQueueName, apNextStageName);

	std::wstring wideSendQueueName;
	BOOL converted = ASCIIToWide(wideSendQueueName,
															 mNextQueueName);
	ASSERT(converted);


	MessageQueueProps queueProps;

	std::wstring label(L"Queue for MetraTech Pipeline Stage ");
	std::wstring wideStageName;
	ASCIIToWide(wideStageName, apNextStageName,
							strlen(apNextStageName));
	label += wideStageName;

	queueProps.SetLabel(label.c_str());
	queueProps.SetJournal(FALSE);

	if (!mSendQueue.CreateQueue(wideSendQueueName.c_str(),
															aPrivate, queueProps))
	{
		if (mSendQueue.GetLastError()->GetCode()
				!= MQ_ERROR_QUEUE_EXISTS)
		{
			SetError(mSendQueue.GetLastError());
			return FALSE;
		}
		mLogger.LogThis(LOG_DEBUG, "Send queue already exists");
	}
	else
		mLogger.LogThis(LOG_DEBUG, "Send queue created sucessfully");

	if (!mSendQueue.Init(wideSendQueueName.c_str(), aPrivate)
			|| !mSendQueue.Open(MQ_SEND_ACCESS, MQ_DENY_NONE))
	{
		SetError(mSendQueue.GetLastError(),
						 "Could not initialize send queue.");
		return FALSE;
	}

	return TRUE;
}

void StageMessageTransmitter::AddToMessagesSent(int aCount /* = 1 */)
{
	mMessagesSent += aCount;
}

int StageMessageTransmitter::GetMessagesSent()
{
	return mMessagesSent;
}

BOOL StageMessageTransmitter::SendToSendQueue(QueueMessage & arMessage)
{
	if (!mSendQueue.Send(arMessage))
	{
		SetError(mSendQueue.GetLastError());
		return FALSE;
	}

	AddToMessagesSent();
	return TRUE;
}

BOOL StageMessageTransmitter::SendToControlQueue(QueueMessage & arMessage)
{
	if (!mPipelineControlQueue.Send(arMessage))
	{
		SetError(mPipelineControlQueue.GetLastError());
		return FALSE;
	}

	AddToMessagesSent();
	return TRUE;
}


BOOL StageMessageTransmitter::SendProcessSession(MTPipelineLib::IMTSessionPtr aSession,
																								 const char * apStageName)
{
	// send a message to the pipeline
	struct PipelineProcessSession processSession;
	processSession.mSessionID = aSession->GetSessionID();

	// TODO: don't hardcode this length
	unsigned char uid[16];
	aSession->GetUID(uid);
	memcpy(processSession.mUID, uid, sizeof(uid));

	QueueMessage sendme;

	sendme.ClearProperties();

	sendme.SetPriority(PIPELINE_STANDARD_PRIORITY);
	sendme.SetExpressDelivery(TRUE);

	sendme.SetAppSpecificLong(PIPELINE_PROCESS_SESSION);

	sendme.SetBody((UCHAR *) &processSession, sizeof(processSession));

	std::string stageName(apStageName);	

	if (!stageName.empty())
	{
		MessageQueue * queue = GetStageQueue(stageName.c_str());
		if (!queue)
			return FALSE;
	
		if (!queue->Send(sendme))
		{
			SetError(queue->GetLastError());
			return FALSE;
		}

		AddToMessagesSent();
		return TRUE;
	}
	else
		return SendToSendQueue(sendme);
}

BOOL StageMessageTransmitter::SendProcessSet(int aSetID,
																						 const unsigned char * aUID,
																						 const char * apStageName)
{
	// send a message to the pipeline
	struct PipelineProcessSessionSet processSessionSet;
	// set both the set ID and unique ID
	// TODO: why isn't this GetID?
	processSessionSet.mSetID = aSetID;
	memcpy(processSessionSet.mSetUID, aUID, 16);

	QueueMessage sendme;

	sendme.ClearProperties();

	sendme.SetPriority(PIPELINE_STANDARD_PRIORITY);
	sendme.SetExpressDelivery(TRUE);

	sendme.SetAppSpecificLong(PIPELINE_PROCESS_SESSION_SET);

	sendme.SetBody((UCHAR *) &processSessionSet, sizeof(processSessionSet));

	std::string stageName(apStageName);	
	if (!stageName.empty())
	{
		MessageQueue * queue = GetStageQueue(stageName.c_str());
		if (!queue)
			return FALSE;
	
		if (!queue->Send(sendme))
		{
			SetError(queue->GetLastError());
			return FALSE;
		}

		AddToMessagesSent();
		return TRUE;
	}
	else
		return SendToSendQueue(sendme);
}

BOOL StageMessageTransmitter::SendParentReady(long aSessionId, const char * apStageName)
{
	// send a message to the pipeline
	struct PipelineChildrenComplete childrenComplete;
	childrenComplete.mSessionID = aSessionId;


	MessageQueue * queue = GetStageQueue(apStageName);
	if (!queue)
		return FALSE;

	QueueMessage sendme;

	sendme.ClearProperties();

	sendme.SetPriority(PIPELINE_STANDARD_PRIORITY);
	sendme.SetExpressDelivery(TRUE);

	sendme.SetAppSpecificLong(PIPELINE_CHILDREN_COMPLETE);

	sendme.SetBody((UCHAR *) &childrenComplete, sizeof(childrenComplete));

	if (!queue->Send(sendme))
	{
		SetError(*queue);
		return FALSE;
	}

	AddToMessagesSent();

	return TRUE;
}

BOOL StageMessageTransmitter::SendGroupComplete(long aObjectOwnerID,
																								const char * apStageName)
{
	// send a message to the pipeline
	struct PipelineGroupComplete groupComplete;
	groupComplete.mObjectOwnerID = aObjectOwnerID;

	MessageQueue * queue = GetStageQueue(apStageName);
	if (!queue)
		return FALSE;

	QueueMessage sendme;

	sendme.ClearProperties();

	sendme.SetPriority(PIPELINE_STANDARD_PRIORITY);
	sendme.SetExpressDelivery(TRUE);

	sendme.SetAppSpecificLong(PIPELINE_GROUP_COMPLETE);

	sendme.SetBody((UCHAR *) &groupComplete, sizeof(groupComplete));

	if (!queue->Send(sendme))
	{
		SetError(*queue);
		return FALSE;
	}

	AddToMessagesSent();

	return TRUE;
}


BOOL StageMessageTransmitter::SendSessionFailed(MTPipelineLib::IMTSessionPtr aSession,
																								const char * apStageName)
{
	MessageQueue * queue = GetStageQueue(apStageName);
	if (!queue)
		return FALSE;

	struct PipelineSessionFailed sessionFailed;
	sessionFailed.mSessionID = aSession->GetSessionID();

	QueueMessage sendme;

	sendme.ClearProperties();

	sendme.SetPriority(PIPELINE_STANDARD_PRIORITY);
	sendme.SetExpressDelivery(TRUE);

	sendme.SetAppSpecificLong(PIPELINE_SESSION_FAILED);

	sendme.SetBody((UCHAR *) &sessionFailed, sizeof(sessionFailed));

	if (!queue->Send(sendme))
	{
		SetError(queue->GetLastError());
		return FALSE;
	}

	AddToMessagesSent();

	// TODO: better error handling
	return TRUE;
}

BOOL StageMessageTransmitter::SendSessionRestart(MTPipelineLib::IMTSessionPtr aSession,
																								 const char * apStageName)
{
	MessageQueue * queue = GetStageQueue(apStageName);
	if (!queue)
		return FALSE;

	struct PipelineProcessSession processSession;
	processSession.mSessionID = aSession->GetSessionID();

	QueueMessage sendme;

	sendme.ClearProperties();

	sendme.SetPriority(PIPELINE_STANDARD_PRIORITY);
	sendme.SetExpressDelivery(TRUE);

	sendme.SetAppSpecificLong(PIPELINE_PROCESS_SESSION);

	sendme.SetBody((UCHAR *) &processSession, sizeof(processSession));

	if (!queue->Send(sendme))
	{
		SetError(*queue);
		return FALSE;
	}

	AddToMessagesSent();

	// TODO: better error handling
	return TRUE;
}


BOOL StageMessageTransmitter::SendStageReadyMessage(int aStageID)
{
	mLogger.LogThis(LOG_DEBUG, "Sending message reporting stage is ready");

	QueueMessage sendme;

	sendme.ClearProperties();

	sendme.SetPriority(PIPELINE_SYSTEM_PRIORITY);
	sendme.SetExpressDelivery(TRUE);

	sendme.SetAppSpecificLong(PIPELINE_STAGE_STATUS);

	PipelineStageStatus status;
	status.mStageID = aStageID;
	status.mStatus = PipelineStageStatus::PIPELINE_STAGE_READY;
	sendme.SetBody((UCHAR *) &status, sizeof(status));

	return SendToControlQueue(sendme);
}

MessageQueue * StageMessageTransmitter::GetStageQueue(const char * apStageName)
{
	std::string lowerName(apStageName);
	StrToLower(lowerName);

	std::map<std::string, MessageQueue *>::iterator it;
	it = mStageQueues.find(lowerName);
	if (it == mStageQueues.end())
	{
		MessageQueue * queue = new MessageQueue;
		mStageQueues[lowerName] = queue;
		
		std::wstring wideName;
		ASCIIToWide(wideName, apStageName);
		MakeStageQueueName(wideName, wideName.c_str());

		if (!queue->Init(wideName.c_str(), mUsePrivateQueues)
				|| !queue->Open(MQ_SEND_ACCESS, MQ_DENY_NONE))
		{
			SetError(queue->GetLastError());
			return NULL;
		}
		return queue;
	}
	else
	{
		MessageQueue * queue = mStageQueues[lowerName];
		ASSERT(queue);
		return queue;
	}
}
