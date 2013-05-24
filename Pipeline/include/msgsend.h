/**************************************************************************
 * @doc MSGSEND
 *
 * @module |
 *
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
 *
 * @index | MSGSEND
 ***************************************************************************/

#ifndef _MSGSEND_H
#define _MSGSEND_H

#include <NTLogger.h>
#include <msmqlib.h>
#include <map>

/*********************************** StageMessageTransmitter ***/

class StageMessageTransmitter : public ObjectWithError
{
public:
	StageMessageTransmitter();
	~StageMessageTransmitter();

	BOOL SendProcessSession(MTPipelineLib::IMTSessionPtr aSession, const char * apStageName);
	BOOL SendProcessSet(int aSetID, const unsigned char * aUID, const char * apStageName);
	BOOL SendParentReady(long aSessionId, const char * apStageName);
	BOOL SendGroupComplete(long aObjectOwnerID, const char * apStageName);
	BOOL SendSessionFailed(MTPipelineLib::IMTSessionPtr aSession,
												 const char * apStageName);
	BOOL SendSessionRestart(MTPipelineLib::IMTSessionPtr aSession,
													const char * apStageName);

	// call after the stage is ready to begin processing messages
	BOOL SendStageReadyMessage(int aStageID);

	const std::string & GetNextQueueName() const
	{ return mNextQueueName; }

	BOOL Init(NTLogger & arLogger, BOOL aPrivate);
	BOOL Init(NTLogger & arLogger, const char * apNextStageName, BOOL aPrivate);

	int GetMessagesSent();

private:
	void AddToMessagesSent(int aCount = 1);

	BOOL SendToSendQueue(QueueMessage & arMessage);
	BOOL SendToControlQueue(QueueMessage & arMessage);

	MessageQueue * GetStageQueue(const char * apStageName);
private:
	// the name of the queue we send messages to
	std::string mNextQueueName;

	// queue we send to
	MessageQueue mSendQueue;

	// master control queue
	MessageQueue mPipelineControlQueue;

	NTLogger mLogger;

	// stats - messages sent
	int mMessagesSent;

	BOOL mUsePrivateQueues;

	std::map<std::string, MessageQueue *> mStageQueues;
};

#endif /* _MSGSEND_H */
