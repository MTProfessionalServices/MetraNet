/**************************************************************************
 * @doc HANDLER
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
 * @index | HANDLER
 ***************************************************************************/

#ifndef _HANDLER_H
#define _HANDLER_H

#include <errobj.h>
#include <listenerconfig.h>
#include <pipelineconfig.h>
#include <routeconfig.h>
#include <MSIX.h>
#include <msmqlib.h>
#include <ServicesCollection.h>
#include <NTThreader.h>
#include <NTThreadLock.h>
#include <mtcryptoapi.h>
#include <ConfigChange.h>
#include <profile.h>
#include <pipemessages.h>
#include <sharedsess.h>
#include <autohandle.h>
#include <queueflag.h>
#include <genparser.h>
#import <MTEnumConfigLib.tlb>
#import <MTNameIDLib.tlb>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent")
#import <MetraTech.Pipeline.Messages.tlb> inject_statement("using namespace mscorlib;")

class MTMSIXBatchHelper;
class MTMSIXMessageHelper;

using std::string;

class CompletionInfo
{
public:
	void * mHookArgument;
	long mTimestamp;
	int mTimeout;
	string mOutput;

	bool StillActive() const
	{ return mHookArgument != NULL; }

	bool HaveOutput() const
	{ return mOutput.length() > 0; }
};

class RoutingQueue : public ObjectWithError
{
public:
	BOOL Init(const ListenerInfo & arListenerInfo,
						const PipelineInfo & arPipelineInfo);

	BOOL SpoolMessage(const char * apMessage,
										const wchar_t * apUID, BOOL aExpress,
										BOOL aFeedbackRequested,
										const MessageQueue & arFeedbackQueue,
										PropertyCount & arPropCount,
										int aMessageLen = 0);

private:
	MessageQueue mQueue;

	// object that holds an event indicating it's OK to send messages to the queue.
	QueueFlag mQueueFlag;

	// TODO: could use acknowledgements instead of dead letter queue
	// queue for acknowledgements
	//MessageQueue mAckQueue;
};

class FeedbackQueue
	: public ObjectWithError,
		public NTThreader
{
public:
	typedef void (*Hook)(const char * apUID, const char * apMessage, void * apArg);

public:
	FeedbackQueue();
	virtual ~FeedbackQueue();

	BOOL Init(Hook apHook, const ListenerInfo & arListenerInfo,
						const MeterRoutes & arRoutes,
						BOOL aPrivateQueues);

	const MessageQueue & GetMessageQueue() const
	{ return mQueue; }

	// thread to listen for feedback messages
	virtual int ThreadMain();

	void Stop();

	BOOL PrepareForFeedback(const char * externalMessageID,
													const char * internalMessageID,
													void * apArg,
																 int aTimeoutMillis, BOOL & arIsCompleted,
																 BOOL & arIsRetry);

private:
	BOOL WaitForFeedback();

	BOOL HandleFeedback(const char * apMessage, const char * apLabel);

	BOOL TimeoutResponses();

	BOOL RemoveMessageID(const std::string  & uid);

	void SetExitFlag()
	{ mExitFlag = TRUE; }

	BOOL GetExitFlag() const
	{ return mExitFlag; }

private:
	typedef map<string, CompletionInfo *> MessageIDMap;
	typedef map<string, string> FirstAttemptMessageIDMap;

	// machine/queue name
	std::wstring mMachineName;
	std::wstring mQueueName;

	// queue we wait for feedback messages on
	MessageQueue mQueue;

	// when true, exit the thread
	BOOL mExitFlag;

	NTLogger mLogger;

	NTLogger mMSIXLogger;

	// map of internal (DB) message IDs to opaque message status
	MessageIDMap mMessageIDMap;

	// map of external (MSIX client generated) message IDs to internal message ID of first attempt
	FirstAttemptMessageIDMap mFirstAttemptMessageIDMap;

	// lock to protect mFirstAttemptMessageIDMap and mMessageIDMap (the only state that is
  // accessed from PrepareForFeedback).
	NTThreadLock mLock;

	// hook called when we get feedback about a session
	Hook mHook;

	// growable buffer to temporarily hold feedback messages as they are received
	char * mMessageBuffer;
	int mMessageBufferSize;
};

class MeterHandler;
class SpoolInfo
{
public:
	MeterHandler * mpHandler;

	MTMSIXMessageHeader * mpMessage;
	// TODO: size
	wchar_t mUID[40];

	int mCount;
};


//
// abstract base class used for message handling
//
// MeterHandler->HandleStream dispatches messages to HandleMessage
// HandleStream contains all feedback related code and other general
// stream handling functionality. HandleMessage, in contrast, deals directly
// with the underlying mechanincs of a particular queueing metaphor.
//
// Two concrete MessageHandler's currently exist: 
//   - MSMQMessageHandler
//   - DBMessageHanlder
class MessageHandler : public ObjectWithError
{
public:
	virtual BOOL Initialize(MeterHandler * meterHandler,
													const ListenerInfo & listenerInfo,
													const PipelineInfo & pipelineInfo)
	{ mMeterHandler = meterHandler; return TRUE;}

	virtual BOOL HandleMessage(const char * apMessage, std::string & arOutput,
														 BOOL aParseOnly, BOOL & arCompleteImmediately,
														 void * apArg,
														 BOOL & requestCompleted,
														 ValidationData & validationData) = 0;

protected:
	MeterHandler * mMeterHandler;
	NTLogger mLogger;
};


//
// processes messages and places them on the MSMQ-based routing queue
//
class MSMQMessageHandler : public MessageHandler
{
public:
	BOOL Initialize(MeterHandler * meterHandler,
									const ListenerInfo & listenerInfo,
									const PipelineInfo & pipelineInfo);

	BOOL HandleMessage(const char * apMessage, std::string & arOutput,
										 BOOL aParseOnly, BOOL & arCompleteImmediately,
										 void * apArg,
										 BOOL & requestCompleted,
										 ValidationData & validationData);

private:
	BOOL ValidateMSIXMessage(const char * apMSIXStream,
													 int aLen,
													 ValidationData & arValidationData,
													 BOOL & arRequiresEncryption);


private:
	RoutingQueue mRoutingQueue;

	// parser for validation only - no generation 
	PipelineMSIXParser<NullSessionBuilder> mParser;

	// lock to protect mParser during Validate
	NTThreadLock mParserLock;

	// utility class to compress/encrypt messages
	MetraTech_Pipeline_Messages::IMessageUtilsPtr mMessageUtils;
};



//
// processes messages and places them into the database queue
//
template<class _InsertStmt>
class DBMessageHandler : public MessageHandler
{
public:
	BOOL Initialize(MeterHandler * meterHandler,
									const ListenerInfo & listenerInfo,
									const PipelineInfo & pipelineInfo);

	BOOL HandleMessage(const char * apMessage, std::string & arOutput,
										 BOOL aParseOnly, BOOL & arCompleteImmediately,
										 void * apArg,
										 BOOL & requestCompleted,
										 ValidationData & validationData);

private:
	BOOL ValidateMSIXMessage(const char * apMSIXStream, int aLen,
													 DBSessionProduct<_InsertStmt>** results,
													 ValidationData & arValidationData,
													 BOOL & arRequiresEncryption);


private:
	// fast parser used to parse messages and insert the results into t_svc tables
	PipelineMSIXParser<DBSessionBuilder<_InsertStmt>  > mParser;

	// lock to protect mParser during Validate
	NTThreadLock mParserLock;
};




// NOTE: this class has to be used in multithreaded situations!
class MeterHandler : public ObjectWithError
{
public:
	MeterHandler();
	virtual ~MeterHandler();

	BOOL Init(FeedbackQueue::Hook apHook);

	void Clear();

	// handle any incoming MSIX and create an output message to return.
	// This call must be reentrant
	BOOL HandleStream(const char * apMessage, std::string & arOutput,
										BOOL aParseOnly, BOOL & arCompleteImmediately,
										void * apArg);

	// return a reference to the lock used to protect initialization
	NTThreadLock & GetInitLock()
	{ return mInitLock; }


	//
	// internal callbacks for use by concrete MessageHandlers
	// 
	BOOL PrepareForFeedback(const char * externalMessageID,
													const char * internalMessageID,
																 void * apArg,
																 BOOL isRetry,
																 BOOL & arIsCompleted,
																 BOOL & arSendToPipeline);

	const MessageQueue & GetFeedbackQueue()
	{ return mFeedbackQueue.GetMessageQueue(); }

private:
	BOOL InitInternal(FeedbackQueue::Hook apHook);

	BOOL ValidateMSIXMessage(const char * apMSIXStream, int aLen,
													 ValidationData & arValidationData,
													 BOOL & arRequiresEncryption);

	// keeps the t_listener table in sync
	void RegisterListenerWithDB();
	void UnregisterListenerWithDB();

private:
	// methods used during profiling
	MessageProfile * StartProfile(const char * apMessage, const MSIXSession * apSession,
																const PerformanceTickCount & arEnteredTickCount,
																const PerformanceTickCount & arParsedTickCount);

private:
	// used for encryption of sensitive fields
  CMTCryptoAPI mCrypto;

	// information for routing messages to and from the pipeline
	MeterRoutes mRouteInfo;

	// queue we're reading responses from
	FeedbackQueue mFeedbackQueue;

	NTLogger mLogger;

	NTLogger mMSIXLogger;

	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

	// name ID so we can ensure that the singleton stays around
	MTNAMEIDLib::IMTNameIDPtr mNameID;

	// default timeout used when 
	int mDefaultFeedbackTimeout;

	// listener configuration
	ListenerInfo mListenerInfo;

	// lock to protect Init method (it's not threadsafe)
	NTThreadLock mInitLock;

	MessageHandler * mpMessageHandler;

};
#endif /* _HANDLER_H */
