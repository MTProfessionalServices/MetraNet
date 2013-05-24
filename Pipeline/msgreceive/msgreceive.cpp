/**************************************************************************
 * @doc MSGRECEIVE
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

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTConfigLib.tlb"

#include <msgreceive.h>
#include <makeunique.h>
#include <perflog.h>

#include <mtglobal_msg.h>

#include <pipemessages.h>


StageMessageReceiver::StageMessageReceiver() : mpHandler(NULL), mMessagesReceived(0)
{ }

StageMessageReceiver::~StageMessageReceiver()
{ }

BOOL StageMessageReceiver::Init(StageMessageHandler * apHandler,
																NTLogger & arLogger, const char * apStageName,
																BOOL aPrivate)
{
	mpHandler = apHandler;

	// copy the logger
	mLogger = arLogger;

	// create the name of the queue and the name of the next queue
	mQueueName = apStageName;
	mQueueName += "Queue";
	MakeUnique(mQueueName);

	// initialize the listening queue.
	std::wstring wideListenQueueName;
	BOOL converted = ASCIIToWide(wideListenQueueName,
															 mQueueName);
	ASSERT(converted);

	// create queue if necessary
	MessageQueueProps queueProps;

	std::wstring label(L"Queue for MetraTech Pipeline Stage ");
	std::wstring wideStageName;
	ASCIIToWide(wideStageName, apStageName, strlen(apStageName));
	label += wideStageName;

	queueProps.SetJournal(FALSE);

	// initialize and open
	if (!mListenQueue.Init(wideListenQueueName.c_str(), aPrivate)
			|| !mListenQueue.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE))
	{
		if (!mListenQueue.CreateQueue(wideListenQueueName.c_str(),
																 aPrivate, queueProps))
		{
			if (mListenQueue.GetLastError()->GetCode() != MQ_ERROR_QUEUE_EXISTS)
			{
				SetError(mListenQueue.GetLastError());
				return FALSE;
			}
			mLogger.LogThis(LOG_DEBUG, "Listen queue already exists");
		}
		else
			mLogger.LogThis(LOG_DEBUG, "Listen queue created sucessfully");

		// initialize and open
		if (!mListenQueue.Init(wideListenQueueName.c_str(), aPrivate)
				|| !mListenQueue.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE))
		{
			const ErrorObject * err = mListenQueue.GetLastError();
			std::string buffer;
			if (err->GetCode() == MQ_ERROR_SERVICE_NOT_AVAILABLE)
				buffer = "Could not initialize listen queue - "
					"message queue not running or not available";
			else
				buffer = "Could not initialize listen queue";

			SetError(err, buffer.c_str());
			return FALSE;
		}
	}

	return TRUE;
}

int StageMessageReceiver::GetMessagesReceived() const
{
	return mMessagesReceived;
}

void StageMessageReceiver::AddToMessagesReceived(int aCount /* = 1 */)
{
	mMessagesReceived += aCount;
}

BOOL StageMessageReceiver::PeekNextMessageType(PipelineMessageID * apMessageType,
																							 DWORD aTimeoutMillis /* = INFINITE */)
{
	// first we peek at the message so we know what type to receive
	QueueMessage peek;

	// get the app specific part
	peek.SetAppSpecificLong(0);

	// peek at the message
	if (!mListenQueue.Peek(peek, aTimeoutMillis))
		// TODO: could be an error as well
		return FALSE;								// nothing in there

	const ULONG * type = peek.GetAppSpecificLong();
	ASSERT(type);
	*apMessageType = (PipelineMessageID) *type;
	return TRUE;
}
BOOL StageMessageReceiver::ReceiveMessage()
{
	const char * functionName = "StageMessageReceiver::ReceiveMessage";

	MarkRegion region("ReceiveMessage");

	// TODO: we assume that we're able to receive the message here.
	// this may not be the case.
	AddToMessagesReceived();

	// the message body will hold different information depending on its
	// type.  We set up to read any message type, then call the appropriate handler
	PipelineProcessSession *processSession;
	PipelineProcessSessionSet *processSet;
	PipelineWaitProcessSessionSet *waitProcessSet;
	PipelineSysCommand *sysCommand;
	PipelineSessionFailed *sessionFailed;
	PipelineSetFailed *setFailed;
	PipelineChildrenComplete *childrenComplete;
	PipelineGroupComplete *groupComplete;

	QueueMessage receiveme;
  UCHAR msgBuf[255];
  PipelineMessageID messageType;

  receiveme.SetAppSpecificLong(0);
  receiveme.SetBody(msgBuf, 255);

  if(mListenQueue.Receive(receiveme))
  {
    const ULONG * type = receiveme.GetAppSpecificLong();
	  ASSERT(type);
	  messageType = (PipelineMessageID) *type;

    switch (messageType)
	  {
	    case PIPELINE_SYSTEM_COMMAND:
		    //
		    // high priority system message
		    //
        sysCommand = (PipelineSysCommand *)msgBuf;  
		    if (!mpHandler->HandleSysCommand(*sysCommand))
		    {
			    SetError(*mpHandler);
			    return FALSE;
		    }
		    return TRUE;

	    case PIPELINE_PROCESS_SESSION:
		    //
		    // process a single session that exists in the shared memory
		    //
		    processSession = (PipelineProcessSession *)msgBuf;
		    if (!mpHandler->HandleProcessSession(*processSession))
		    {
			    SetError(*mpHandler);
			    return FALSE;
		    }
		    return TRUE;

	    case PIPELINE_WAIT_PROCESS_SESSION:
		    //
		    // only the start stage handles this message.
		    // it means wait until the session goes to a ready state (all children complete),
		    // then process it like PIPELINE_PROCESS_SESSION_SET
		    //
		    // read the body of the message
		    processSession = (PipelineProcessSession *)msgBuf;
		    if (!mpHandler->HandleWaitProcessSession(*processSession))
		    {
			    SetError(*mpHandler);
			    return FALSE;
		    }
		    return TRUE;

	    case PIPELINE_PROCESS_SESSION_SET:
		    //
		    // process a set of sessions that exist in the shared memory
		    //  
        processSet = (PipelineProcessSessionSet *)msgBuf;
		    if (!mpHandler->HandleProcessSet(*processSet))
		    {
			    SetError(*mpHandler);
			    return FALSE;
		    }
		    return TRUE;

	    case PIPELINE_WAIT_PROCESS_SESSION_SET:
		    //
		    // process a set of sessions that exist in the shared memory
		    // only after a group of sessions has completed
		    //
        waitProcessSet = (PipelineWaitProcessSessionSet *)msgBuf;
		    if (!mpHandler->HandleWaitProcessSessionSet(*waitProcessSet))
		    {
			    SetError(*mpHandler);
			    return FALSE;
		    }
		    return TRUE;

	    case PIPELINE_SESSION_FAILED:
		    //
		    // a session has failed and must be restarted or abandoned
		    //

		    // read the body of the message
  
        sessionFailed = (PipelineSessionFailed *)msgBuf;
        if (!mpHandler->HandleSessionFailed(*sessionFailed))
		    {
			    SetError(*mpHandler);
			    return FALSE;
		    }
		    return TRUE;

	    case PIPELINE_SET_FAILED:
		    //
		    // a set has failed and must be restarted or abandoned
		    //

        setFailed = (PipelineSetFailed *)msgBuf;
        if (!mpHandler->HandleSetFailed(*setFailed))
		    {
			    SetError(*mpHandler);
			    return FALSE;
		    }
		    return TRUE;

	    case PIPELINE_CHILDREN_COMPLETE:
		    //
		    // all children of a compound are completed
		    //
        childrenComplete = (PipelineChildrenComplete *)msgBuf;
		    if (!mpHandler->HandleChildrenComplete(*childrenComplete))
		    {
			    SetError(*mpHandler);
			    return FALSE;
		    }
		    return TRUE;

	    case PIPELINE_GROUP_COMPLETE:
		    //
		    // all sessions within a group have completed
		    //
        groupComplete = (PipelineGroupComplete *)msgBuf;
		    if (!mpHandler->HandleGroupComplete(*groupComplete))
		    {
			    SetError(*mpHandler);
			    return FALSE;
		    }
		    return TRUE;

	    default:
		    SetError(PIPE_ERR_BAD_MESSAGE, ERROR_MODULE, ERROR_LINE, functionName,
						     "Unknown message type.");
		    return FALSE;
	  }
  }
  else
  {
    SetError(mListenQueue.GetLastError());
    return FALSE;
  }
}



BOOL StageMessageReceiver::FlushSystemMessages()
{
	while (TRUE)
	{
		PipelineMessageID messageType;
		// this will wait until the next message arrives, then look at the message type
		// NOTE: peeking and removing the message aren't an atomic action!
		if (!PeekNextMessageType(&messageType, 0))
			break;

		// flush out all system messages (only)
		PipelineSysCommand sysCommand;

		if (messageType == PIPELINE_SYSTEM_COMMAND)
		{
			QueueMessage receiveme;
			receiveme.SetBody((UCHAR *) &sysCommand, sizeof(sysCommand));
			if (!mListenQueue.Receive(receiveme))
			{
				SetError(mListenQueue.GetLastError());
				return FALSE;
			}

			switch (sysCommand.mCommand)
			{
			case PipelineSysCommand::REFRESH_INIT:
				mLogger.LogThis(LOG_INFO, "Removed REFRESH_INIT command from queue");
				break;
			case PipelineSysCommand::EXIT:
				mLogger.LogThis(LOG_INFO, "Removed EXIT command from queue");
				break;
			default:
				mLogger.LogThis(LOG_ERROR, "Removed unknown system command from queue");
				break;
			}
		}
		else
			// if there are non system messages in the queue, leave them
			break;
	}
	return TRUE;
}

