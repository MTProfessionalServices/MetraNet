/**************************************************************************
 * @doc MSGRECEIVE
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
 * @index | MSGRECEIVE
 ***************************************************************************/

#ifndef _MSGRECEIVE_H
#define _MSGRECEIVE_H

#include <NTLogger.h>
#include <msmqlib.h>

struct PipelineProcessSession;
struct PipelineProcessSessionSet;
struct PipelineWaitProcessSessionSet;
struct PipelineSysCommand;
struct PipelineChildrenComplete;
struct PipelineSessionFailed;
struct PipelineSetFailed;
struct PipelineGroupComplete;

enum PipelineMessageID;

/*************************************** StageMessageHandler ***/

class StageMessageHandler: public virtual ObjectWithError
{
public:
	//
	// handlers - override to perform the appropriate action
	//
	virtual BOOL HandleProcessSession(const PipelineProcessSession & arMessage) = 0;
	virtual BOOL HandleWaitProcessSession(const PipelineProcessSession & arMessage) = 0;
	virtual BOOL HandleProcessSet(const PipelineProcessSessionSet & arMessage) = 0;
	virtual BOOL HandleWaitProcessSessionSet(
		const PipelineWaitProcessSessionSet & arMessage) = 0;
	virtual BOOL HandleSysCommand(const PipelineSysCommand & arMessage) = 0;
	virtual BOOL HandleChildrenComplete(const PipelineChildrenComplete & arMessage) = 0;
	virtual BOOL HandleSessionFailed(const PipelineSessionFailed & arMessage) = 0;
	virtual BOOL HandleSetFailed(const PipelineSetFailed & arMessage) = 0;
	virtual BOOL HandleGroupComplete(const PipelineGroupComplete & arMessage) = 0;
};

/************************************** StageMessageReceiver ***/

class StageMessageReceiver : public ObjectWithError
{
public:
	StageMessageReceiver();
	~StageMessageReceiver();

	BOOL ReceiveMessage();

	BOOL Init(StageMessageHandler * apHandler,
						NTLogger & arLogger, const char * apStageName,
						BOOL aPrivate);

	// remove all old messages from the queue
	BOOL FlushSystemMessages();

	int GetMessagesReceived() const;

private:
	// used by ReceiveMessage to look at the type of the next
	// message in the queue.
	BOOL PeekNextMessageType(PipelineMessageID * apMessageType,
													 DWORD aTimeoutMillis = INFINITE);

	void AddToMessagesReceived(int aCount = 1);

private:
	StageMessageHandler * mpHandler;

	// queue we listen to
	MessageQueue mListenQueue;

	// the name of the queue we listen on
	std::string mQueueName;

	// message logger
	NTLogger mLogger;

	// stats - messages received
	int mMessagesReceived;
};


#endif /* _MSGRECEIVE_H */
