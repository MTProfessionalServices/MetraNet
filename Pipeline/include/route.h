/**************************************************************************
 * @doc ROUTE
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
 * @index | ROUTE
 ***************************************************************************/

#ifndef _ROUTE_H
#define _ROUTE_H

#include <msmqlib.h>
#include <NTThreader.h>

#include <autohandle.h>

#include <routeconfig.h>
#include <pipelineconfig.h>
#include <listenerconfig.h>
#include <stageconfig.h>
#include <flow.h>
#include <generate.h>
#include <profile.h>
#include <pipemessages.h>
#include <dbparser.h>

#include <map>

using std::map;

#ifdef WIN32
#if defined(DEFINING_ROUTE) && !defined(DllExportRoute)
#define DllExportRoute __declspec(dllexport)
#else
#define DllExportRoute __declspec( dllimport )
#endif
#else // WIN32
#define DllExportRoute
#endif // WIN32


/************************************************ StageQueue ***/

class StageQueue : public MessageQueue
{
public:
	StageQueue(const wchar_t * apName, BOOL aPrivate);
	// needs a default constructor to go into the
	// collection.
	StageQueue();

	void Init(const wchar_t * apName, BOOL aPrivate);

	const wstring & GetStageName()
	{ return mStageName; }

	BOOL QueueIsValid()
	{ return SUCCEEDED(mFailure); }

	HRESULT GetFailureError()
	{ return mFailure; }

private:
	wstring mStageName;
	HRESULT mFailure;
};

typedef map<int, StageQueue> StageMap;

/**************************************** SessionRouterState ***/

class SessionRouterState : public ObjectWithError
{
	friend class SessionRouter;
public:
	DllExportRoute
	SessionRouterState();

	DllExportRoute
	~SessionRouterState();

	DllExportRoute
	BOOL Init();

private:
	void DoubleBuffer();

private:
	enum
	{
		INITIAL_BUFFER_SIZE = 4096,
	};

	// event used to decide when a message is ready
	AutoHANDLE mMessageReadyEvent;

	// current buffer for the body
	char * mpBuffer;

	// current size of the buffer
	int mBufferSize;
};

/********************************************* SessionRouter ***/

class SessionRouter : public ObjectWithError,
											public NTThreader
{
public:
	DllExportRoute
	SessionRouter();

	DllExportRoute
	virtual ~SessionRouter();

	DllExportRoute
	BOOL Init(const ListenerInfo & arListenerInfo,
						const PipelineInfo & arPipelineInfo,
						const char * apMachineName,
						const char * apQueueName,
						BOOL aTransactionalQueue,
						const MeterRoutes & arRoutes,
						MTPipelineLib::IMTSessionServerPtr aSessionServer);

	DllExportRoute
	BOOL RouteStartMessage(MTPipelineLib::IMTSessionPtr aSession,
												 int aStageID);

	DllExportRoute
	BOOL RouteStartMessage(MTPipelineLib::IMTSessionSetPtr aSessionSet,
												 int aStageID, unsigned char * apBatchUID,
												 int aWaitForGroup = -1);

	DllExportRoute
	static unsigned int __stdcall BootstrapThreadEx (void *arg_list);

	DllExportRoute
	virtual int ThreadMain();

	DllExportRoute
	void Stop();

public:
	// loop endlessly, routing sessions
	DllExportRoute
	BOOL RouteSessions();

	// route a single session
	DllExportRoute
	BOOL RouteSession(SessionRouterState & arState, int * apSessionCount = NULL);


	// set the max number of sessions routed before the thread exits
	DllExportRoute
	void SetMaxSessions(int aSessions)
	{ mMaxSessions = aSessions; }


	// send a new message to the correct stage
	// NOTE: this method is public for test drivers
	// don't use it directly
	DllExportRoute
	BOOL RouteMessage(const char * apMessage,unsigned long bufferSize, int aMeterID,
										int * apSessionCount = NULL);

private:
	// prepare to route messages to and from the listener queues
	BOOL InitializeRoutes(const MeterRoutes & arRoutes);
	BOOL InitRouterQueue(const wchar_t * apMachine, const wchar_t * apQueue,
											 BOOL aTransactionalQueue);
	BOOL InitQueues(const PipelineInfo & arPipelineInfo);

	// receive the message from the queue
	BOOL ReceiveMessage(SessionRouterState & arState,
											QueueMessage & arMessage, BOOL & arStopSignalled);

	BOOL GetStageForService(int aServiceID, int & arStageID);

	BOOL CalculateServiceStages(const ListenerInfo & arListenerInfo,
															const PipelineInfo & arPipelineInfo);

	// wait until the pipeline is ready to start receiving sessions
	BOOL FlowControl();

	// double the size of the message buffer
	void DoubleBuffer(SessionRouterState & arState);


	void SetExitFlag()
	{ mExitFlag = TRUE; }

	BOOL GetExitFlag() const
	{ return mExitFlag; }

	// calculate how deep within a parent/child relationship tree each
	// session is.
	void CalculateSessionDepths(SessionObjectVector & arSessions,
															std::vector<int> & arDepths, int & arMaxDepth);

    // This is called after CalculateSessionDepths() to check for 
    // ESR-3602 condition
    bool SessionRouter::ContainsMixedSessionRootTypes(SessionObjectVector & arSessions, std::vector<int> & arDepths);
	
	void AssignSessionOwnership(
		MTPipelineLib::IMTObjectOwnerPtr aOwner,
		const std::map<int, MTPipelineLib::IMTSessionSetPtr> & arStageToSetMap,
		int aSessionCount, int aLevel, BOOL aFeedbackRequested);

  int PopFirstMessage(long pipelineID, vector<int>& aServiceIdsForSchedule, int& meterID);
  BOOL RouteSessionFromDatabaseQueue(int * apSessionCount = NULL);
  BOOL SendSessionsToServer(SessionObjectVector & arSessions,
                            ValidationData & parsedData,
                            unsigned char batchUID[16],
                            int aMeterID);
// ESR-3497 port ESR-3208 from 6.0.2 to 6.1.1
  void ReleaseMessages(void);

private:
  double mSessionPercentUsed;

	typedef map<int, int> ServiceMap;

	typedef map<wstring, int> FormatNameMap;

  DBParserSharedSession mDBParser;

	// logger
	NTLogger mLogger;

	// pipeline info object
	PipelineInfo mPipelineInfo;

	// buffer for the extension (which happens to be the prop count)
	PropertyCount mPropCount;

	// if TRUE, exit the thread asap
	BOOL mExitFlag;

	// map of service ID to stage ID
	ServiceMap mServiceMap;

	// map of queue format name to stage ID
	FormatNameMap mFormatNameMap;

	// set of meterIDs that have been routed
	std::set<int> mRoutedMeterIDs; 

	// queue where a listener sends messages
	MessageQueue mRoutingQueue;

	// if true, the queue is transactional
	BOOL mTransactional;

	// map of stage IDs to queues
	StageMap mStages;

	// parse the message and generate the object before routing
	PipelineObjectGenerator mGenerator;

	// flow control valve to keep the pipeline from overloading itself
	PipelineFlowControl mFlowControl;

	// used when profiling the system
	ProfileDataReference mProfile;

	// session server - used to generate session sets
	MTPipelineLib::IMTSessionServerPtr mSessionServer;

	// if TRUE, profile
	BOOL mCollectProfile;

	// used for debugging memory leaks, this is the max number of sessions
	// routed before the thread exits
	int mMaxSessions;

  // Identifies this pipeline server's registration information in the database
  long mPipelineID;

public:
	//
	// test parameters
	//
	// DO NOT SET IN NORMAL OPERATION
	//

	// if TRUE, don't actually generate a session in shared memory
	void SetParseOnly(BOOL aParseOnly)
	{ mParseOnly = aParseOnly; }

private:
	//
	// test parameters
	//
	// DO NOT SET IN NORMAL OPERATION
	//

	// if TRUE, don't actually generate a session in shared memory
	BOOL mParseOnly;

private:
	static unsigned int IntHashKey(const int & arKey)
	{ return ((arKey ^ 0xA5A5A5) << 16) ^ arKey; }
};

#endif /* _ROUTE_H */
