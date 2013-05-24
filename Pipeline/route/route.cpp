/**************************************************************************
 * @doc ROUTE
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
#include <mtcom.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTConfigLib.tlb"
#import "Rowset.tlb" rename ("EOF", "RowsetEOF") 

#include <route.h>
#include <mttime.h>
#include <mtcomerr.h>
#include <OdbcException.h>
#include <mtprogids.h>
#include <loggerconfig.h>
#include <routeconfig.h>
#include <mtglobal_msg.h>
#include <MSIX.h>
#include <propids.h>
#include <queue.h>
#include <tpstimer.h>
#include <hostname.h>
#include <autocritical.h>
#include <stageinfo.h>

// TODO: don't include sharedsess directly..
#include <sharedsess.h>

#include <pipemessages.h>
#include <makeunique.h>
#include <perflog.h>

#include <RowsetDefs.h>
/************************************************ StageQueue ***/

StageQueue::StageQueue()
{
	mFailure = E_FAIL;
}

void StageQueue::Init(const wchar_t * apName, BOOL aPrivate)
{
	mStageName = apName;
	std::wstring queueName = mStageName;
	queueName += L"Queue";
	MakeUnique(queueName);
	if (MessageQueue::Init(queueName.c_str(), aPrivate) && Open(MQ_SEND_ACCESS, MQ_DENY_NONE))
		mFailure = S_OK;
	else
		mFailure = GetLastError()->GetCode();
}

StageQueue::StageQueue(const wchar_t * apName, BOOL aPrivate)
{
	Init(apName, aPrivate);
}


/**************************************** SessionRouterState ***/

SessionRouterState::SessionRouterState()
	: mpBuffer(NULL),
		mBufferSize(0)
{ }

SessionRouterState::~SessionRouterState()
{
	if (mpBuffer)
	{
		delete [] mpBuffer;
		mpBuffer = NULL;
	}
}


BOOL SessionRouterState::Init()
{
	const char * functionName = "SessionRouterState::Init";
	//
	// create an unnamed event that will be signalled when a message is available
	//
	mMessageReadyEvent = ::CreateEvent(NULL, TRUE, FALSE, NULL);
	if (!mMessageReadyEvent)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	mpBuffer = new char[INITIAL_BUFFER_SIZE];
	mBufferSize = INITIAL_BUFFER_SIZE;

	return TRUE;
}

void SessionRouterState::DoubleBuffer()
{
	mBufferSize *= 2;
	ASSERT(mpBuffer);
	delete [] mpBuffer;
	mpBuffer = new char[mBufferSize];
	ASSERT(mpBuffer);
}


/********************************************* SessionRouter ***/

SessionRouter::SessionRouter()
	: mExitFlag(FALSE),
		mParseOnly(FALSE),
		mMaxSessions(-1),
    mSessionPercentUsed(-1.0)
{ }

SessionRouter::~SessionRouter()
{
	// let the thread die..
	Stop();
}

void SessionRouter::Stop()
{
  // Whack the database to indicate we are no longer online.
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(L"Queries\\Pipeline");
    rowset->SetQueryTag(L"__BRING_PIPELINE_OFFLINE__");
    rowset->AddParam(L"%%TX_MACHINE%%", _bstr_t(::GetNTHostName()));
    rowset->Execute();
  }
  catch(_com_error & err)
  {
    // Don't treat as a serious error, we're going down anyway.
    mLogger.LogThis(LOG_WARNING, (const wchar_t *)err.Description());
  }
  
	// next time the thread wakes up have it exit
	SetExitFlag();

	// wait for it to exit
	StopThread(INFINITE);
}

BOOL SessionRouter::Init(const ListenerInfo & arListenerInfo,
												 const PipelineInfo & arPipelineInfo,
												 const char * apMachineName,
												 const char * apQueueName,
												 BOOL aTransactionalQueue,
												 const MeterRoutes & arRoutes,
												 MTPipelineLib::IMTSessionServerPtr aSessionServer)
{
	const char * functionName = "SessionRouter::Init";

	// NOTE: this has to be done because this code is in a different DLL from
	// stage and therefore has a different copy of the static variables in PipelinePropIDs
	PipelinePropIDs::Init();

	mPipelineInfo = arPipelineInfo;

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[Router]");

  mDBParser.Init(arPipelineInfo, aSessionServer);

	// store the session server for future use
	mSessionServer = aSessionServer;

	//
	// initialize routes back to the listeners
	//
	if (!InitializeRoutes(arRoutes))
		return FALSE;

	//
	// init all stage queues
	//

	if (!CalculateServiceStages(arListenerInfo, arPipelineInfo))
		return FALSE;

	if (!InitQueues(arPipelineInfo))
		return FALSE;

	const wchar_t * machine = NULL;
	std::wstring longMachineName;
	if (apMachineName)
	{
		std::string machineStr(apMachineName);

		if (machineStr.length() > 0)
		{
			ASCIIToWide(longMachineName, machineStr.c_str(),
									machineStr.length());
			machine = longMachineName.c_str();
		}
	}

	ASSERT(apQueueName);
	std::string queue(apQueueName);

	std::wstring longQueueName;
	ASCIIToWide(longQueueName, queue.c_str(), queue.length());

	if (!InitRouterQueue(machine, longQueueName.c_str(), aTransactionalQueue))
		return FALSE;

  // Register this pipeline with the database.  This includes putting simple info
  // such as my hostname in the db.  More importantly, let the world know what services
  // I am prepared to process.
  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
  rowset->Init(L"Queries\\Pipeline");
  rowset->InitializeForStoredProc(L"UpsertPipeline");
  rowset->AddInputParameterToStoredProc(L"tx_machine", MTTYPE_W_VARCHAR, INPUT_PARAM, ::GetNTHostName());
  rowset->AddOutputParameterToStoredProc(L"id_pipeline", MTTYPE_INTEGER, OUTPUT_PARAM);
  rowset->ExecuteStoredProc();
  _variant_t val = rowset->GetParameterFromStoredProc("id_pipeline");
  mPipelineID = val.lVal;

  // Transaction timestamp for this change.
  _variant_t now = GetMTOLETime();
  _variant_t infinity = GetMaxMTOLETime();

  rowset->SetQueryTag(L"__DELETE_PIPELINE_SERVICES__");
  rowset->AddParam(L"%%ID_PIPELINE%%", mPipelineID);
  rowset->AddParam(L"%%TT_END%%", now);
  rowset->Execute();

  for(ServiceMap::const_iterator it = mServiceMap.begin();
      it != mServiceMap.end();
      it++)
  {
    rowset->SetQueryTag(L"__INSERT_PIPELINE_SERVICES__");
    rowset->AddParam(L"%%ID_PIPELINE%%", mPipelineID);
    rowset->AddParam(L"%%ID_SVC%%", (long) it->first);
    rowset->AddParam(L"%%TT_START%%", now);
    rowset->AddParam(L"%%TT_END%%", infinity);
    rowset->Execute();
  }

  rowset->SetQueryTag(L"__COALESE_PIPELINE_SERVICES__");
  rowset->AddParam(L"%%ID_PIPELINE%%", mPipelineID);
  rowset->Execute();

	//
	// initialize the session generator
	//
	if (!mGenerator.Init(arPipelineInfo, aSessionServer))
	{
		SetError(mGenerator);
		return FALSE;
	}

	//
	// initialize the flow control mechanism
	//
	// thresholds must be between 0.0 and 1.0
	if (!mFlowControl.Init(aSessionServer, arPipelineInfo.GetThresholdMin() / 100.0,
												 arPipelineInfo.GetThresholdMax() / 100.0,
												 arPipelineInfo.GetThresholdRejection() / 100.0))

	{
		SetError(mFlowControl);
		return FALSE;
	}

	if (arPipelineInfo.ProfileEnabled())
	{
		mCollectProfile = TRUE;

		if (!mProfile.Init(arPipelineInfo.GetProfileFile().c_str(),
											 arPipelineInfo.GetProfileShareName().c_str(),
											 arPipelineInfo.GetProfileSessions(),
											 arPipelineInfo.GetProfileMessages()))
		{
			SetError(mProfile);
			return FALSE;
		}
	}
	else
		mCollectProfile = FALSE;

	return TRUE;
}


BOOL SessionRouter::InitRouterQueue(const wchar_t * apMachine,
																		const wchar_t * apQueue,
																		BOOL aTransactionalQueue)
{
	ErrorObject * queueErr;

	mTransactional = aTransactionalQueue;

	std::wstring queueName(apQueue);
	MakeUnique(queueName);
	if (!SetupQueue(mRoutingQueue, queueName.c_str(), apMachine,
									L"Routing Queue", TRUE, FALSE, mPipelineInfo.UsePrivateQueues(),
									mTransactional, &queueErr))
	{
		SetError(queueErr);
		delete queueErr;
		mLogger.LogThis(LOG_ERROR, "Could not setup routing queue");
		return FALSE;
	}

	return TRUE;
}


BOOL SessionRouter::InitQueues(const PipelineInfo & arPipelineInfo)
{
	const char * functionName = "SessionRouter::InitQueues";

	//
	// init all stage queues
	//

	StageList::const_iterator it;
	for (it = arPipelineInfo.GetStages().begin();
			 it != arPipelineInfo.GetStages().end();
			 ++it)
	{
		const StageIDAndName & stage = *it;

		const string & stageName = stage.mStageName;

		wstring longStageName;
		ASCIIToWide(longStageName, stageName.c_str(), stageName.length());

		mLogger.LogVarArgs(LOG_DEBUG, "Initializing queue %s",
											 (const char *) stageName.c_str());

		StageQueue & queue = mStages[stage.mStageID];

		queue.Init(longStageName.c_str(), arPipelineInfo.UsePrivateQueues());

		if (!queue.QueueIsValid())
		{
			SetError(queue.GetFailureError(), ERROR_MODULE, ERROR_LINE,
							 functionName);
			mLogger.LogVarArgs(LOG_ERROR, "Unable to initialize queue %s: %lx",
												 stageName.c_str(),
												 queue.GetFailureError());
			return FALSE;
		}
	}

	return TRUE;
}


BOOL SessionRouter::InitializeRoutes(const MeterRoutes & arRoutes)
{
	MTPipelineLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);

	mLogger.LogThis(LOG_DEBUG, "Initializing routes back to listener queues");

	// create a mapping from format name to meter ID
	MeterRoutes * routes = const_cast<MeterRoutes *>(&arRoutes);
	MeterRouteQueueInfoList::iterator it;
	for (it = routes->mQueueInfo.begin(); it != routes->mQueueInfo.end(); ++it)
	{
		const MeterRouteQueueInfo & info = *it;

		MessageQueue queue;

		const std::wstring & machineName = info.GetMachineName();
		std::wstring queueName = info.GetQueueName();
		MakeUnique(queueName);

		const wchar_t * machine;
		if (machineName.length() > 0)
			machine = machineName.c_str();
		else
			machine = NULL;

		if (!queue.Init(queueName.c_str(), mPipelineInfo.UsePrivateQueues(), machine))
		{
			MessageQueueProps queueProps;
			queueProps.SetLabel(queueName.c_str());
			queueProps.SetJournal(FALSE);

			if(!queue.CreateQueue(queueName.c_str(), mPipelineInfo.UsePrivateQueues(), queueProps, machine))
			{
				SetError(queue);
				return FALSE;
			}
			if(!queue.Init(queueName.c_str(), mPipelineInfo.UsePrivateQueues(), machine))
			{
				SetError(queue);
				return FALSE;
			}
		}

		// create the mapping
		const std::wstring & formatName = queue.GetFormatString();

		long meterID = nameID->GetNameID(info.GetMeterName().c_str());
		ASSERT(meterID != -1);
		mRoutedMeterIDs.insert(meterID);

		wstring strFormatName = formatName;
		mFormatNameMap[strFormatName] = meterID;

		if (mLogger.IsOkToLog(LOG_DEBUG))
		{
			std::string asciiFormatName(ascii(formatName));
			mLogger.LogVarArgs(LOG_DEBUG, "Route %s to %s(%d)",
												 asciiFormatName.c_str(),
												 info.GetMeterName().c_str(),
												 meterID);
		}
	}

	return TRUE;
}

int SessionRouter::PopFirstMessage(long pipelineID, vector<int>& aServiceIdsForMessage, int& meterID)
{
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init("Queries\\Pipeline");

	rowset->InitializeForStoredProc("PopFirstMessage");
	rowset->AddInputParameterToStoredProc("p_pipelineid", MTTYPE_INTEGER, INPUT_PARAM, pipelineID);
	rowset->AddInputParameterToStoredProc("p_systemtime", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());
	rowset->AddOutputParameterToStoredProc("p_messageid", MTTYPE_INTEGER, OUTPUT_PARAM);
	rowset->ExecuteStoredProc();

	// This rowset encodes a message with a list of service definition ids.
  // The rowset is a denormalized view of the data with (id_message, id_feedback) constant
  // over all records in the rowset and id_svc varying for each record in the rowset.
	if(rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
		return -1;

	int messageID = -1;

	while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
	{
		
		//TODO: hack for now!!! We need to figure out howto get conditional rowset from stored procedure
		//because EOF will crash if no rowset was returned. For now I cahnged PopFirstMessage stored procedure
		//to return null if no scheduel found
		_variant_t val = rowset->GetValue("id_message");
		if((long)val == -1)
			return -1;
		//message id, feedback queue is the same on all rows
		if(messageID < 0) 
    {
      messageID = (int)rowset->GetValue("id_message");
      val = rowset->GetValue("id_feedback");
      if (val.vt != VT_NULL)
      {
        meterID = (int) val;
      }
      else
      {
        meterID = -1;
      }
    }
		aServiceIdsForMessage.push_back((int)rowset->GetValue("id_svc"));
		//printf("pop> msgid:%i meterid:%i svcid:%i\n", messageID, meterID, (int)rowset->GetValue("id_svc"));
		rowset->MoveNext();
	}

	return messageID;
}

BOOL SessionRouter::RouteSessionFromDatabaseQueue(int * apSessionCount /* = NULL */)
{
	const char * functionName = "SessionRouter::RouteSessionFromDatabaseQueue";

  BOOL okToLog = mLogger.IsOkToLog(LOG_DEBUG);

  // TODO: Get a better solution for polling; should have some kind of flow control
  // that speeds up when there are sessions and slows down when there are not.
  ::Sleep(100);

  // Check for flow control.  
  if (!FlowControl())
    return FALSE;

	BOOL stopSignalled;
	if (StopRequested())
  {
		stopSignalled = TRUE;
  }
	else
	{
    stopSignalled = FALSE;
	}

	if (stopSignalled)
	{
		SetExitFlag();
		// no message was received - the thread was just told to stop
		return TRUE;
	}

	MarkRegion routeSessionRegion("RouteSession");

  // the stop event could have been signalled.  If so, don't attempt to
  // process anything
  if (StopRequested())
  {
    //arStopSignalled = TRUE;
    return TRUE;
  }

  try
  {
    // Check session server state and it changed from 0 to non-zero, update the
    // database.
    double capacity = mSessionServer->GetPercentUsed();
    
    if(mSessionPercentUsed == -1.0 ||
       (mSessionPercentUsed == 0.0 && capacity != 0.0) ||
       (mSessionPercentUsed != 0.0 && capacity == 0.0))
    {
      mSessionPercentUsed = capacity;
      // Make note of the fact that shared memory has gone from empty to non-empty
      ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
      rowset->Init(L"Queries\\Pipeline");
      rowset->SetQueryTag(L"__UPDATE_PIPELINE_PROCESSING__");
      rowset->AddParam(L"%%TX_MACHINE%%", ::GetNTHostName());
      rowset->AddParam(L"%%B_PROCESSING%%", mSessionPercentUsed != 0.0 ? 1 : 0);
      rowset->Execute();
    }

    // Check to see if there is a message to be routed.
    vector<int> serviceIdsForMessage;
    int meterID = -1;
    int messageID = PopFirstMessage(mPipelineID, serviceIdsForMessage, meterID);
    if (messageID != -1)
    {

      if (okToLog)
      {
        mLogger.LogVarArgs(LOG_DEBUG, "retrieved message ID %d", messageID);

        // Check for synchronous metering by looking for a meter ID
        if (meterID != -1)
        {
          // a meter ID was specified - make sure it's listed in route.xml
          std::set<int>::iterator it = mRoutedMeterIDs.find(meterID);
          if (it == mRoutedMeterIDs.end())
          {
            mLogger.LogVarArgs(LOG_ERROR, "No route back to feedback queue for meter ID %d found in routes.xml!", meterID);
            SetError(PIPE_ERR_ROUTING_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
            return FALSE;
          }
          mLogger.LogVarArgs(LOG_DEBUG, "Received session requiring response to meter %d",
                             meterID);
        }
      }

      // parse results into sessions server
      SessionObjectVector sessionObjects;
      ValidationData parsedData;
      unsigned char messageUID[16];
      MarkEnterRegion("ParseAndGenerate");
      // this structure holds some data parsed out of the message
      if (!mDBParser.Parse(messageID, serviceIdsForMessage, messageUID, sessionObjects, parsedData))
      {
        SetError(mDBParser);
        return FALSE;
      } 
      MarkExitRegion("ParseAndGenerate");

      // Note that in this context, "message" refers to what in the old world was the MSIX message.
      // Here the analogue of this is the message id.
      // BUG: We do not support having a single message with multiple root session types in it.  The reason for this
      // is that the messageUID is used as the unique identifier for root sessions sets created later on.
      // This bug is not unique to the 4.0 code and has existed since 3.0.
      memset(messageUID, 0, 16);
      ((long *) messageUID)[0] = messageID;

      MarkRegion routeMessageRegion("RouteMessage");

      if(sessionObjects.size() == 0)
      {
        // This is definitely a bit odd, but let's not treat it as an error.
        std::string uidStr;
        MSIXUidGenerator::Encode(uidStr, messageUID);
        mLogger.LogVarArgs(LOG_WARNING, "Skipping routing of empty message = %s", uidStr.c_str());
        return TRUE;
      }

      mLogger.LogVarArgs(LOG_DEBUG, "Routing %d sessions", sessionObjects.size());

      if (okToLog)
      {
        std::string uidStr;
        MSIXUidGenerator::Encode(uidStr, messageUID);
        mLogger.LogVarArgs(LOG_DEBUG, "Message ID = %s", uidStr.c_str());
      } 

      if (mParseOnly)
        // if only parsing, don't send process session messages
        return TRUE;

      BOOL ret = SendSessionsToServer(sessionObjects, parsedData, messageUID, meterID);

      if (!mFlowControl.ReevaluateFlow())
      {
        SetError(mFlowControl);
        return FALSE;
      }

      return ret;
    }
  }
  catch (COdbcException & err)
  {
    SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
             err.what());
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return FALSE;
  }
  catch (_com_error & err)
  {
    SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
             err.Description());
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return FALSE;
  }
  catch (std::exception & err)
  {
    SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
             err.what());
    mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    return FALSE;
  }
  // No message found
  return TRUE;
}


BOOL SessionRouter::RouteSession(SessionRouterState & arState,
																 int * apSessionCount /* = NULL */)
{
	const char * functionName = "SessionRouter::RouteSession";

	QueueMessage receiveme;

	// receive the app specific long (service ID) ..
	receiveme.SetAppSpecificLong(0);
	// .. and the response queue ID (format name)
	//    "public queues require at least 44 unicode characters.
	//     private queues require at least 54"
	wchar_t formatNameBuff[64];
	receiveme.SetResponseQueueLen(sizeof(formatNameBuff));
	receiveme.SetResponseQueue(formatNameBuff);

	// should be plently of room for the label (the UID)
	wchar_t labelBuff[128];
	receiveme.SetLabelLen(sizeof(labelBuff) - 1);
	receiveme.SetLabel(labelBuff);

	BOOL stopSignalled;
	if (StopRequested())
		stopSignalled = TRUE;
	else
	{
		if (!ReceiveMessage(arState, receiveme, stopSignalled))
			return FALSE;
	}

	if (stopSignalled)
	{
		SetExitFlag();
		// no message was received - the thread was just told to stop
		return TRUE;
	}

	MarkRegion routeSessionRegion("RouteSession");
	// zero terminate the label
	const ULONG * labelSize = receiveme.GetLabelLen();
	labelBuff[*labelSize] = L'\0';
	mLogger.LogVarArgs(LOG_DEBUG, L"Received message labeled %s", labelBuff);

	const ULONG * size = receiveme.GetBodySize();
	unsigned long bufferSize = *size;

	// null terminate the body
	arState.mpBuffer[bufferSize] = '\0';

	// figure out the service ID
	const ULONG * appspecific = receiveme.GetAppSpecificLong();
	int serviceId = *appspecific;

	// figure out the response queue format name if there is one
	const ULONG * respQueueLen = receiveme.GetResponseQueueLen();
	ASSERT(respQueueLen);

	ASSERT(*respQueueLen < sizeof(formatNameBuff));

	int meterID;
	if (*respQueueLen > 0)
	{
		// a response queue was specified - make sure it's one of the
		// queue listed in route.xml
		formatNameBuff[*respQueueLen] = L'\0';

		std::wstring formatName(formatNameBuff);

		FormatNameMap::iterator it = mFormatNameMap.find(formatName);
		if (it == mFormatNameMap.end())
		{
			SetError(PIPE_ERR_ROUTING_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}
		meterID = it->second;
		mLogger.LogVarArgs(LOG_DEBUG, "Received session requiring response to meter %d",
											 meterID);
	}
	else
		meterID = -1;


	//checks to make sure extension information is present
	//if it isn't then we just log a warning and don't check for overflows
	const ULONG * pExtensionLen = receiveme.GetExtensionLen();		
	if (!pExtensionLen || (*pExtensionLen == 0)) {
		_bstr_t label;
		const ULONG * labelSize = receiveme.GetLabelLen();
		if (!labelSize || (*labelSize == 0)) //makes sure the label exists
			label = "NO UID";
		else {
			labelBuff[*labelSize] = '\0';
			label = labelBuff;
		}
		mLogger.LogVarArgs(LOG_WARNING, "Property count information was not found in session (%s).", (const char *) label);
		mLogger.LogThis(LOG_WARNING, "Bypassing shared memory overflow check!");
	} 

	//checks for potential shared memory overflow based on property count info from the listener
	else
	{
		BOOL overflow;
		if (!mFlowControl.IsOverflow(mPipelineInfo, mPropCount, overflow))
		{
			SetError(mFlowControl);
			return FALSE;
		}

		if (overflow)
		{
			_bstr_t label;
			const ULONG * labelSize = receiveme.GetLabelLen();
			if (!labelSize || (*labelSize == 0)) //makes sure the label exists
				label = "NO UID";
			else {
				labelBuff[*labelSize] = '\0';
				label = labelBuff;
			}
			std::wstring errMsg;
			errMsg += L"Cannot fit session (";
			errMsg += (const wchar_t *)label;
			errMsg += L") into shared memory! Perhaps shared memory size should be increased.";
			SetError(PIPE_ERR_ROUTING_ERROR, ERROR_MODULE, ERROR_LINE, functionName, ascii(errMsg).c_str());
			return FALSE;
		}
	}

// PERFORMANCE TWEAK
#if 1
	if (!RouteMessage(arState.mpBuffer,bufferSize, meterID, apSessionCount))
		return FALSE;
#endif

	return TRUE;
}


BOOL SessionRouter::ReceiveMessage(
	SessionRouterState & arState,
	QueueMessage & arMessage, BOOL & arStopSignalled)
{
	const char * functionName = "SessionRouter::ReceiveMessage";

	// unless the stop event is signalled, we only care about a message being ready
	arStopSignalled = FALSE;

	// asynchronous context
	AsyncContext context(arState.mMessageReadyEvent);

	while (TRUE)
	{
		// don't start accepting messages from the queue until the pipeline is
		// ready to start accepting them.
		// NOTE: if the exit event is signalled, FlowControl will return TRUE
		// even if the pipeline isn't ready.  we check to see if a stop was
		// requested immediately afterwards to handle this.

		//mLogger.LogThis(LOG_DEBUG, "About to flow control");
		if (!FlowControl())
			return FALSE;

		// the stop event could have been signalled.  If so, don't attempt to
		// receive a message.
		if (StopRequested())
		{
			arStopSignalled = TRUE;
			return TRUE;
		}

		// provide a large buffer when reading the message.
		// if the buffer is too small, double it and try again
		arMessage.SetBodySize(arState.mBufferSize);

		// have to supply some sort of buffer..
		arMessage.SetBody((unsigned char *) arState.mpBuffer, arState.mBufferSize);

		//provides a buffer for the property count struct
		arMessage.SetExtensionLen(sizeof(mPropCount));
		arMessage.SetExtension((unsigned char *) &mPropCount, sizeof(mPropCount));

		BOOL recvSucceeded;

		recvSucceeded = mRoutingQueue.Receive(arMessage, context);

		// even successes can return an error
		const ErrorObject * err = mRoutingQueue.GetLastError();
		DWORD code = err ? err->GetCode() : 0;
		if (recvSucceeded && code == 0)
		{
			// if the receive succeeded with a success code,
			// the message was there and the buffer was big enough
			return TRUE;
		}

		if (!recvSucceeded)
		{
			if (code == MQ_ERROR_BUFFER_OVERFLOW)
			{
				// a message was there, but our buffer isn't big enough to
				// handle it.  Double the size of the buffer for next time,
				// even though there's no guarantee that we'll get the
				// same one (another process might take it).
				arState.DoubleBuffer();
				continue;									// try again
			}
			else
			{
				// something else went wrong - return an error
				SetError(err);
				return FALSE;
			}
		}

		// the receive succeeded, but there was an informational code.
		// we expect it to be MQ_INFORMATION_OPERATION_PENDING.
		ASSERT(recvSucceeded);
		if (code != MQ_INFORMATION_OPERATION_PENDING)
		{
			// hmm.. it shouldn't be anything else.
			SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 "Unexpected information code returned from asynchronous receive call");
			return FALSE;
		}

		if (StopRequested())
		{
			arStopSignalled = TRUE;
			return TRUE;
		}

		enum
		{
			MESSAGE_READY_EVENT = 0,
			STOP_EVENT,
			EVENT_COUNT,							// terminator
		};

		HANDLE waitEvents[EVENT_COUNT];
		waitEvents[MESSAGE_READY_EVENT] = arState.mMessageReadyEvent;
		waitEvents[STOP_EVENT] = StopEventHandle();

		DWORD waitResult = WaitForMultipleObjects(EVENT_COUNT, // number of handles
																							waitEvents, // pointer to the object-handles
																							FALSE, // wait flag (wait for any of them)
																							INFINITE); // time-out interval (in millis)


		if (waitResult == WAIT_FAILED)
		{
			// TODO: pass win32 or hresult?
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
							 "Error while waiting for ready event or stop event");
			return FALSE;
		}

		// event is the index of the first event that fired
		int event = waitResult - WAIT_OBJECT_0;

		switch (event)
		{
		case STOP_EVENT:
			// stop event.

			// if only the stop event was signaled, return now.  otherwise we've
			// just pulled a message off the queue so we have to deal with it
			if (WAIT_OBJECT_0 != ::WaitForSingleObject(waitEvents[MESSAGE_READY_EVENT], 0))
			{
				// there is no message ready, just the stop event
				arStopSignalled = TRUE;
				return TRUE;
			}

			// NOTE: FALL THROUGH to handle the message ready event as well
			//       (exit flag will still be set)

		case MESSAGE_READY_EVENT:
			// reset it for next time
			::ResetEvent(arState.mMessageReadyEvent);
			if (context.Succeeded())
			{
				// if the receive succeeded with a success code,
				// the message was there and the buffer was big enough
				return TRUE;
			}
			else
			{
				code = context.GetError();
				if (code == MQ_ERROR_BUFFER_OVERFLOW)
				{
					// a message was there, but our buffer isn't big enough to
					// handle it.  Double the size of the buffer for next time,
					// even though there's no guarantee that we'll get the
					// same one (another process might take it).
					mLogger.LogThis(LOG_DEBUG, "Doubling message buffer size");
					arState.DoubleBuffer();
					continue;									// try again
				}
				else
				{
					// something else went wrong - return an error
					// NOTE: this could be MQ_INFORMATION_OPERATION_PENDING if a remote message
					// queue server is down.
					// in this case the event is signalled but the code returned is still operation pending.
					SetError(err);
					return FALSE;
				}
			}
		default:
			ASSERT(0);
			SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
							 "Unknown return from WaitForMultipleObjects");
			return FALSE;
		}

		// should have either returned or continued before this
		ASSERT(0);
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
}


BOOL SessionRouter::FlowControl()
{
	const char * functionName = "SessionRouter::FlowControl";

	if (mFlowControl.CanAcceptSessions())
		return TRUE;

	mLogger.LogThis(LOG_DEBUG, "Must wait for sessions");

	enum
	{
		ACCEPT_SESSIONS_EVENT = 0,
		STOP_EVENT,
		EVENT_COUNT,							// terminator
	};

	HANDLE waitEvents[EVENT_COUNT];
	waitEvents[ACCEPT_SESSIONS_EVENT] = mFlowControl.GetAcceptSessionsEvent();
	waitEvents[STOP_EVENT] = StopEventHandle();

	mLogger.LogThis(LOG_DEBUG, "Waiting for sessions to drain out");

	DWORD waitResult = ::WaitForMultipleObjects(EVENT_COUNT, // number of handles
																							waitEvents, // pointer to the object-handles
																							FALSE, // wait flag (wait for any of them)
																							INFINITE); // time-out interval (in millis)

	if (waitResult == WAIT_FAILED)
	{
		// TODO: pass win32 or hresult?
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName,
						 "Error while waiting for ready event or stop event");
		return FALSE;
	}

	// event is the index of the first event that fired
	int event = waitResult - WAIT_OBJECT_0;
	switch (event)
	{
	case STOP_EVENT:
		// stop event.
		return TRUE;

	case ACCEPT_SESSIONS_EVENT:
		// we can now start accepting sessions again
		mLogger.LogThis(LOG_DEBUG, "Ready to start accepting sessions again.");
		return TRUE;

	default:
		ASSERT(0);
		SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 "Unknown return from WaitForMultipleObjects");
		return FALSE;
	}

}

BOOL NullID(unsigned char * apID)
{
	static unsigned char nullUID[16] = { 0x00 };

	return (0 == memcmp(nullUID, apID, sizeof(nullUID)));
}

void SessionRouter::CalculateSessionDepths(SessionObjectVector & arSessions,
																					 std::vector<int> & arDepths, int & arMaxDepth)
{
	// set all values to -1 (means depth is not known)
	arDepths.resize(arSessions.size(), -1);

	for (int i = 0; i < (int) arSessions.size(); i++)
	{
		MTPipelineLib::IMTSessionPtr session = arSessions[i];

		// walk up until we find the root
		int depth = 0;
		while (session->GetParentID() != -1)
		{
			session = mSessionServer->GetSession(session->GetParentID());
			depth++;
		}

		arDepths[i] = depth;

		if (depth > arMaxDepth)
			arMaxDepth = depth;
	}
}

// This routine checks for a condition outlined in ESR-3602
// and references by Derek in bug not of RouteSessionFromDatabaseQueue()
// If an illegal relationship where a single t_message is 
// associated with multiple root t_session_set instances
// where there are different service types, we return true
// to allow the router to ignore the message, as this is illegal. 
bool SessionRouter::ContainsMixedSessionRootTypes(SessionObjectVector & arSessions, std::vector<int> & arDepths)
{
    long last_svc_type = 0;
    long root_session_cnt = 0;
	for (int i = 0; i < (int) arSessions.size(); i++)
	{
        // Check all root sessions
        if(0 == arDepths[i])
        {
          MTPipelineLib::IMTSessionPtr session = arSessions[i];
          ++ root_session_cnt;
          long cur_svc_type = session->GetServiceID();
		  //mLogger.LogVarArgs(LOG_DEBUG, "@i=%d root_session_cnt=%d  last_svc_type=%ld cur_svc_type=%ld",i, root_session_cnt, last_svc_type, cur_svc_type);
          if(root_session_cnt > 1 && last_svc_type != cur_svc_type)
          {
            // Caught a bad mix
			//mLogger.LogVarArgs(LOG_DEBUG, "@i=%d root_session_cnt=%d  last_svc_type=%ld cur_svc_type=%ld", i, root_session_cnt, last_svc_type, cur_svc_type);
            return true;
          }
          // Save it for next root session check
          last_svc_type = cur_svc_type;
        }
	}
    return false;
}
void SessionRouter::AssignSessionOwnership(
	MTPipelineLib::IMTObjectOwnerPtr aOwner,
	const std::map<int, MTPipelineLib::IMTSessionSetPtr> & arStageToSetMap,
	int aSessionCount, int aLevel,
	BOOL aFeedbackRequested)
{
	// currently the end of the chain
	MTPipelineLib::IMTObjectOwnerPtr lastOwner = aOwner;

	std::map<int, MTPipelineLib::IMTSessionSetPtr>::const_iterator it;
	int i;
	for (i = 0, it = arStageToSetMap.begin(); it != arStageToSetMap.end(); it++, i++)
	{
		int stageID = it->first;
		if (i == 0)
		{
			if (aLevel == 0)
			{
				// synchronous metering feedback required at level zero
				MTPipelineLib::IMTSessionSetPtr sessionSet = it->second;
				// first object owner in the chain.  here the session count matters

				if (aFeedbackRequested)
				{
					aOwner->InitForSendFeedback(aSessionCount, sessionSet->Getid());

					mLogger.LogVarArgs(LOG_DEBUG,
														 "feedback on set %d after %d sessions at level %d",
														 sessionSet->Getid(), aSessionCount, aLevel);
				}
				else
				{
					aOwner->InitForCompleteProcessing(aSessionCount, sessionSet->Getid());

					mLogger.LogVarArgs(LOG_DEBUG,
														 "complete processing on set %d after %d "
														 "sessions at level %d",
														 sessionSet->Getid(), aSessionCount, aLevel);
				}
			}
			else
			{
				// first object owner in the chain.  here the session count matters
				aOwner->InitForNotifyStage(aSessionCount, stageID);

				mLogger.LogVarArgs(LOG_DEBUG,
													 "stage %d watching %d sessions at level %d", stageID,
													 aSessionCount, aLevel);
			}
		}
		else
		{
			// because there's more than one stage we need to add another
			// object owner to the chain.
			MTPipelineLib::IMTObjectOwnerPtr nextOwner = mSessionServer->CreateObjectOwner();

			if (aLevel == 0)
			{
				// synchronous metering feedback required at level zero
				MTPipelineLib::IMTSessionSetPtr sessionSet = it->second;
				// total count of 0
				nextOwner->InitForSendFeedback(0, sessionSet->Getid());

				mLogger.LogVarArgs(LOG_DEBUG,
													 "feedback on set %d after %d sessions at level %d",
													 sessionSet->Getid(), aSessionCount, aLevel);

			}
			else
			{
				// total count of 0
				nextOwner->InitForNotifyStage(0, stageID);

				mLogger.LogVarArgs(LOG_DEBUG,
													 "stage %d watching %d sessions at level %d", stageID,
													 aSessionCount, aLevel);
			}

			// link it in
			// NOTE: this adds a reference to "nextOwner"
			lastOwner->PutNextObjectOwnerID(nextOwner->Getid());


			lastOwner = nextOwner;

		}
	}
}

/*
 * This algorithm is a little tricky.
 *
 * Each batch that enters the system can be made up of many different
 * types of sessions.  Some of these sessions might be related to each
 * other with a parent child relationship.  Others are unrelated.  The
 * goal of this design is to handle processing a batch of sessions in
 * the correct order and allow the client to optionally get a response
 * message holding the resulting value of each session with the batch.
 * This design will allow additional flexibility including unlimited
 * nesting of parents and children (aka "N-deep processing").
 * 
 * The rule for parent child processing is that children complete
 * processing before their parents.  The pipeline must guarantee that
 * children have completed even if they were processed by different
 * stages.
 *
 * In this design, an "object owner" tracks a group of sessions.  When
 * all sessions watched by an object owner are complete, a message is
 * sent to any number of interested stages.
 *
 * When a batch is received by the router, it's parsed completely so
 * all sessions are entered into shared memory.  Sessions are then
 * sorted by depth.  Sessions with no parents have a depth of zero.
 * Sessions with parents have a depth of 1, etc.  All sessions at a
 * given level are assigned to an object owner.  These sessions are
 * then arranged by service ID into session sets, one set per service.
 *
 * The sessions have now been arranged into groups, each owned by an
 * object owner, and session sets, each holding a single service def.
 * For example, assume the following hierarchy comes in, with the
 * letter representing the service and the number representing the
 * session ID:
 *
 *   A1        A5
 *  / \       /  \
 * B2  B3    D6  C7
 *      \
 *      C4
 *
 * The sessions are grouped as following.  Parenthesis are used to
 * represent session sets.
 *
 * level 0, group #1:  (A1, A5)
 * level 1, group #2:  (B2, B3) (D6) (C7)
 * level 2, group #3:  (C4)
 *
 * Each session set is now sent to the correct stage, according to the
 * service to stage map.  The session sets at the lowest level are
 * sent for immediate processing.  Sessions at each level up are sent
 * for processing starting when the group at the level below it has
 * completely finished.
 *
 * stage A: process session set (A1, A5) after group #2 has completed
 * stage B: process session set (B2, B3) after group #3 has completed
 * stage D: process session set (D6) after group #3 has completed 
 * stage C: process session set (C7) after group #3 has completed
 * stage C: process session set (C4) immediately
 *
 * The sessions are then processed by the stages.  After each group is
 * finished a notification is sent to each stage listed at the level
 * above.
 *
 * group #3: notify stages B, C, D
 * group #2: notify stage A
 *
 * Sessions are processed bottom up.  Because object owners track
 * groups at the session level, session sets can be subdivided if
 * necessary (for example, due to stage forking).
 *
 * To handle synchronous metering, the sessions at the top most level
 * are also assigned an object owner.  When that stage receives a
 * response that the group of sessions are complete, the entire batch
 * must be complete and a message can be send back to the client.
 *
 * Areas for improvement:
 *
 * This algorithm does not always generate the optimal order.  In the
 * example above, C4 and C7 could have been processed together because
 * C7 does not depend on C4.  This could be fixed after the initial
 * coding.  It's only an issue when there are sessions of the same
 * service definition at different levels.
 */ 

BOOL SessionRouter::RouteMessage(const char * apMessage,unsigned long bufferSize, int aMeterID,
																 int * apSessionCount)
{
	const char * functionName = "SessionRouter::RouteMessage";

	MarkRegion routeMessageRegion("RouteMessage");

	SessionObjectVector sessionObjects;


	unsigned char batchUID[16];
	memset(batchUID, 0x00, sizeof(batchUID));
	

	MarkEnterRegion("ParseAndGenerate");

	// this structure holds some data parsed out of the message
	ValidationData parsedData;
	if (!mGenerator.ParseAndGenerate(apMessage, bufferSize,sessionObjects, &mFlowControl,
																	 batchUID, apSessionCount, parsedData))
	{
		SetError(mGenerator);
		return FALSE;
	}

	MarkExitRegion("ParseAndGenerate");

	mLogger.LogVarArgs(LOG_DEBUG, "Routing %d sessions", sessionObjects.size());

	BOOL okToLog = mLogger.IsOkToLog(LOG_DEBUG);

	if (okToLog)
	{
		std::string uidStr;
		MSIXUidGenerator::Encode(uidStr, batchUID);
		mLogger.LogVarArgs(LOG_DEBUG, "Batch ID = %s", uidStr.c_str());
	}

	if (mParseOnly)
		// if only parsing, don't send process session messages
		return TRUE;

  return SendSessionsToServer(sessionObjects, parsedData, batchUID, aMeterID);
}

BOOL SessionRouter::SendSessionsToServer(SessionObjectVector & sessionObjects,
										 ValidationData & parsedData,
										 unsigned char batchUID[16],
										 int aMeterID)
{
	BOOL okToLog = mLogger.IsOkToLog(LOG_DEBUG);
	BOOL feedbackRequested = (aMeterID != -1);

	MarkEnterRegion("DecideOwner");
	// determine the depth of each session we have
	std::vector<int> sessionDepths;
	int maxDepth = -1;
	CalculateSessionDepths(sessionObjects, sessionDepths, maxDepth);
	ASSERT(maxDepth != -1);

	mLogger.LogVarArgs(LOG_DEBUG, "Maximum depth of relationships: %d", maxDepth);
	
	if(ContainsMixedSessionRootTypes(sessionObjects, sessionDepths))
	{
		// Report this error, as this is an illegal organization
		// and this message must have a new t_message instance created for it.
		std::string uidStr;
		MSIXUidGenerator::Encode(uidStr, batchUID);
		mLogger.LogVarArgs(LOG_ERROR, "Multiple unrelated root session types are illegal in a single message, ignoring messageid = %s", uidStr.c_str());
		return TRUE; // Return true to just ignore.
	}
	
	// create an owner for each group of sessions
	std::vector<int> objectOwnerIds;
	std::vector<MTPipelineLib::IMTObjectOwnerPtr> objectOwners;

	for (int i = 0; i <= maxDepth; i++)
	{
		MTPipelineLib::IMTObjectOwnerPtr owner = mSessionServer->CreateObjectOwner();
		// make the object live even after the COM object wrapper goes away
		(void) owner->IncreaseSharedRefCount();
		objectOwners.push_back(owner);
		objectOwnerIds.push_back(owner->Getid());
		if (okToLog)
			mLogger.LogVarArgs(LOG_DEBUG, "Sessions at level %d belong to group %d",
			i, objectOwnerIds[i]);
	}


	// map between a stage and the set of sessions that are to go to that stage
	typedef std::map<int, MTPipelineLib::IMTSessionSetPtr> StageToSetMap;
	// this map is maintained at each level of the relationship
	std::vector<StageToSetMap> stageToSetMaps;
	stageToSetMaps.resize(maxDepth + 1);

	// count of sessions at each level
	std::vector<int> sessionCount;
	// initially 0
	sessionCount.resize(maxDepth + 1, 0);

	BOOL success = TRUE;


	// sending a group of sessions

	// set of sessions in a batch to a single stage
	MTPipelineLib::IMTSessionSetPtr sessionSet;

	// commonly everything will go to the same stage.  we keep track
	// of the stage of the previous message in the list.  If it's the same
	// as the current one then sessionSet has already been setup
	int lastStageID = -1;

	for (int i = 0; i < (int) sessionObjects.size(); i++)
	{
		MTPipelineLib::IMTSessionPtr sessionObj = sessionObjects[i];

		int sessionDepth = sessionDepths[i];

		// this session belongs to the object owner at it's appropriate level
		// if the owner is NULL, we're not watching these sessions
		MTPipelineLib::IMTObjectOwnerPtr objectOwner = objectOwners[sessionDepth];

		if (objectOwner != NULL)
			sessionObj->PutObjectOwnerID(objectOwner->Getid());

		// one more session at this level
		++sessionCount[sessionDepth];

		if (aMeterID != -1)
		{
			//
			// the listener is requesting feedback about this session
			//

			// NOTE: we set the meter ID on the sessions that need feedback.
			// however, we don't set the SharedSession::FEEDBACK event.

			// hold the meter ID in the session as a property
			sessionObj->SetLongProperty(PipelinePropIDs::FeedbackMeterID(), aMeterID);
		}

		int serviceID = sessionObj->GetServiceID();
		int stageID;
		if (!GetStageForService(serviceID, stageID))
		{
			mLogger.LogThis(LOG_ERROR, "Unable to route session");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
			success = FALSE;
		}

		if (success)
		{
			// find or create the session set
			//  look up the set within this level
			StageToSetMap & stageToSetMap = stageToSetMaps[sessionDepth];
			sessionSet = stageToSetMap[stageID];
			if (sessionSet == NULL)
			{
				sessionSet = mSessionServer->CreateSessionSet();
				// NOTE: batchUID can be all zeros
				sessionSet->SetUID(batchUID);
				stageToSetMap[stageID] = sessionSet;
			}


			// increase the refcount so that the session will stay resident until the
			// end of the pipeline.  without this line, the session would disappear when
			// the COM object is released.
			(void) sessionObj->IncreaseSharedRefCount();

			sessionSet->AddSession(sessionObj->GetSessionID(),
				sessionObj->GetServiceID());

			if (okToLog)
			{
				_bstr_t sessionID = sessionObj->GetUIDAsString();
				_bstr_t sessionSetID = sessionSet->GetUIDAsString();

				mLogger.LogVarArgs(LOG_DEBUG, "Adding session %s to set %s",
					(const char *) sessionID, (const char *) sessionSetID);
			}
		}
	}

	//
	// initialize the object owners.
	// the object owner at each level points to all the stages at the level above.
	// level 0 is a special case.  It sends messages to the first stage in its own level.
	//

	// handle levels 1 and above
	int level;
	for (level = 1; level < maxDepth + 1; level++)
	{
		MTPipelineLib::IMTObjectOwnerPtr owner = objectOwners[level];
		int count = sessionCount[level];
		StageToSetMap & stageToSetMap = stageToSetMaps[level - 1];

		AssignSessionOwnership(owner, stageToSetMap, count, level, feedbackRequested);
	}

	AssignSessionOwnership(objectOwners[0], stageToSetMaps[0], sessionCount[0], 0,
		feedbackRequested);

	//
	// associates the transaction with the owner of the set
	//
	if (parsedData.mTransactionID[0] != '\0')
		objectOwners[0]->PutTransactionID(parsedData.mTransactionID);

	//
	// pass session context information into the object owner, if it exists
	//
	if (parsedData.mContextUsername[0] != '\0'
		&& parsedData.mContextPassword[0] != '\0'
		&& parsedData.mContextNamespace[0] != '\0')
	{
		// TODO: set username, password, namespace in object owner
		objectOwners[0]->PutSessionContextUserName(parsedData.mContextUsername);
		objectOwners[0]->PutSessionContextPassword(parsedData.mContextPassword);
		objectOwners[0]->PutSessionContextNamespace(parsedData.mContextNamespace);
	}

	if (parsedData.mpSessionContext)
	{
		// TODO: set username, password, namespace in object owner
		objectOwners[0]->PutSerializedSessionContext(parsedData.mpSessionContext);
	}

	MarkExitRegion("DecideOwner");

	// Clean out the object owner vector.  It is unsafe to hold these references past this
	// point because it is possible for the pipeline to finish with a message between the point
	// that we send message and the point we exit the procedure.  If we are still holding references
	// when we exit, it will cause this method
	// to invoke the object owner d'tor.  This is unsafe because pipeline.exe stores process 
	// local info in the object owner (transaction pointer, critical section, etc.) and if we
	// perform the delete we'll generate an access violation.
	objectOwners.clear();

	//
	// finally, send out the messages.
	// for each level, send out each set, saying to wait for
	// the group at the next level.  The last level doesn't need to
	// wait for anything.
	//

	MarkEnterRegion("SendMessages");
	// do all levels except the lowest
	for (level = 0; level < maxDepth; level++)
	{
		// wait for the next level
		int ownerID = objectOwnerIds[level + 1];
		StageToSetMap & stageToSetMap = stageToSetMaps[level];

		StageToSetMap::iterator it;
		for (it = stageToSetMap.begin(); it != stageToSetMap.end(); it++)
		{
			sessionSet = it->second;
			int stageID = it->first;

			mLogger.LogVarArgs(LOG_DEBUG,
				"Sending wait for group %d and "
				"process session set %d to stage %d",
				ownerID, sessionSet->Getid(), stageID);

			if (!RouteStartMessage(sessionSet, stageID, batchUID, ownerID))
				success = FALSE;
		}
	}

	// now the lowest level
	StageToSetMap::iterator it;
	StageToSetMap & stageToSetMap = stageToSetMaps[maxDepth];
	for (it = stageToSetMap.begin(); it != stageToSetMap.end(); it++)
	{
		sessionSet = it->second;
		int stageID = it->first;

		mLogger.LogVarArgs(LOG_DEBUG,
			"Sending process session set %d to stage %d",
			sessionSet->Getid(), stageID);

		if (!RouteStartMessage(sessionSet, stageID, batchUID))
			success = FALSE;
	}

	MarkExitRegion("SendMessages");
	mLogger.LogThis(LOG_DEBUG, "Routing complete");
	return success;
}


BOOL SessionRouter::RouteStartMessage(MTPipelineLib::IMTSessionSetPtr aSessionSet,
																			int aStageID, unsigned char * apBatchUID,
																			int aWaitForGroup)
{
	const char * functionName = "SessionRouter::RouteStartMessage";

	//
	// set up the structure sent in the message
	//

	// increase the refcount so that the session set will stay resident until the
	// end of the pipeline.  without this line, the session would disappear when
	// the COM object is released.
	(void) aSessionSet->IncreaseSharedRefCount();

	// the object owner also holds a reference to the set
//	(void) aSessionSet->IncreaseSharedRefCount();

	long setID = aSessionSet->Getid();

	struct PipelineProcessSessionSet processSessionSet;
	struct PipelineWaitProcessSessionSet waitProcessSessionSet;

	// should processing wait for a group of sessions to complete processing?
	if (aWaitForGroup != -1)
	{
		// process after group completes
		waitProcessSessionSet.mSetID = setID;
		memcpy(waitProcessSessionSet.mSetUID, apBatchUID, 16);
		waitProcessSessionSet.mObjectOwnerID = aWaitForGroup;
	}
	else
	{
		// immediately process
		processSessionSet.mSetID = setID;
		memcpy(processSessionSet.mSetUID, apBatchUID, 16);
	}

	// TODO: should add a batch ID here or something?
	//aSession->GetUID(processSession.mUID);

	//
	// set up the queue message
	//
	QueueMessage sendme;
	sendme.ClearProperties();

	sendme.SetExpressDelivery(TRUE);
	sendme.SetPriority(PIPELINE_STANDARD_PRIORITY);

	if (aWaitForGroup != -1)
	{
		sendme.SetAppSpecificLong(PIPELINE_WAIT_PROCESS_SESSION_SET);
		sendme.SetBody((UCHAR *) &waitProcessSessionSet, sizeof(waitProcessSessionSet));
	}
	else
	{
		sendme.SetAppSpecificLong(PIPELINE_PROCESS_SESSION_SET);
		sendme.SetBody((UCHAR *) &processSessionSet, sizeof(processSessionSet));
	}

	//
	// choose either the queue or the default queue
	//
	StageMap::iterator it = mStages.find(aStageID);
	if (it == mStages.end())
	{
		SetError(PIPE_ERR_ROUTING_ERROR, ERROR_MODULE, ERROR_LINE,
						 functionName);
		return FALSE;
	}

	StageQueue * queue = &it->second;

	if (!queue->Send(sendme))
	{
		mLogger.LogVarArgs(LOG_ERROR,
											 "error sending message to queue "
											 "(set %d)", setID);

		SetError(*queue);
		return FALSE;
	}

	mLogger.LogVarArgs(LOG_DEBUG, "message (set %d) sent successfully to stage %s",
										 setID,
										 (const char *) (ascii(queue->GetStageName()).c_str()));

	return TRUE;
}



BOOL SessionRouter::RouteSessions()
{
	const char * functionName = "SessionRouter::RouteSessions";

	SessionRouterState state;
	if (!state.Init())
	{
		SetError(state);
		return FALSE;
	}

	static TimingInfo * gTimingInfo = new TimingInfo(3000);

	int count = 0;
	while (!GetExitFlag() && (mMaxSessions == -1 || count < mMaxSessions))
	{
		try
		{
			int sessionCount = 0;
			if(PipelineInfo::PERSISTENT_DATABASE_QUEUE == mPipelineInfo.GetHarnessType())
			{
				// With the database, we will make a point to attempt recovery in case we lose connectivity.
				// In particular, in a cluster environment failover may happen and all will be well.
				BOOL success = FALSE;
				int retrySleep=100;
				static const int halfMaxRetry(5000);

				while(success==FALSE)
				{
				  success = RouteSessionFromDatabaseQueue(&sessionCount);
				  
				  if (!success)
				  {
					  char msg[256];
					  sprintf(msg, "RouteSessionFromDatabaseQueue failed. Retrying in %d milliseconds", retrySleep);

					mLogger.LogThis(LOG_WARNING, msg);
					mLogger.LogErrorObject(LOG_WARNING, GetLastError());

					// Increase retry sleep time up to max of 5 seconds...
					// retry sleep will reset once we get a successful connection
		            ::Sleep(retrySleep);
		            retrySleep = retrySleep < halfMaxRetry ? 2*retrySleep : 2*halfMaxRetry;
				  }
				}
			}
			else
			{
				BOOL success = RouteSession(state, &sessionCount);
				if (!success)
				{
				  mLogger.LogThis(LOG_ERROR, "RouteSessions failed");
				  mLogger.LogErrorObject(LOG_ERROR, GetLastError());

				  // if MSMQ is gone, routing sessions will never succeed, so exit.
				  // otherwise we'll log errors infinitely.
				  // NOTE: operation pending is returned when a remote message
				  // queue is down.
				  if (GetLastError()->GetCode() == MQ_ERROR_SERVICE_NOT_AVAILABLE
					  || GetLastError()->GetCode() == MQ_INFORMATION_OPERATION_PENDING)
				  {
					mLogger.LogThis(LOG_FATAL, "Message queue server detected to be down - shutting down.");
					return FALSE;
				  }
				}
			}

			gTimingInfo->AddTransactions(sessionCount);
			count++;
		}
		catch (_com_error & err)
		{
			if (err.Error() == PIPE_ERR_SHARED_OBJECT_FAILURE)
				mLogger.LogThis(LOG_ERROR, "RouteSessions failed: shared object failure.  continuing");
			else
				// something else we're not prepared for - don't continue
				throw;
		}
	}

	return TRUE;
}

unsigned int __stdcall SessionRouter::BootstrapThreadEx (void *arg_list)
{
	NTThreader	*const pObject = (NTThreader *) arg_list;

//  if (pObject->mRetCode == ERROR_SUCCESS)
//	{
		//
		// Run Thread's Main loop, provided by consumer object
		//
//		pObject->mRetCode = 
	(void ) pObject->ThreadMain();
//	}

		_endthreadex (TRUE); //(pObject->mRetCode);

		return TRUE; //pObject->mRetCode;
}

int SessionRouter::ThreadMain()
{
	const char * functionName = "SessionRouter::ThreadMain";

	::SetThreadPriority(::GetCurrentThread(), THREAD_PRIORITY_BELOW_NORMAL);

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
      rowset->Init(L"Queries\\Pipeline");
	  rowset->SetQueryString("select id_acc from t_account_mapper where 1 = 0");
	  rowset->Execute();

		if (!RouteSessions())
		{
			mLogger.LogThis(LOG_FATAL, "RouteSessions failed fatally");
			mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		}
	}
	catch (_com_error & err)
	{
		std::wstring str = err.ErrorMessage();

		_bstr_t descBstr = err.Description();
		const char * desc = descBstr;
		std::string descString(desc ? desc : "");

		mLogger.LogVarArgs(LOG_ERROR,
											 "RouteSession thread failed: _com_error: %lx (%s) (%s)",
											 err.Error(), (const char *) ascii(str).c_str(),
											 (const char *) descString.c_str());

		SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName);
	}

	mLogger.LogThis(LOG_DEBUG, "Router thread exiting");
	return 0;
}



BOOL SessionRouter::GetStageForService(int aServiceID, int & arStageID)
{
	const char * functionName = "SessionRouter::GetStageForService";
	ServiceMap::iterator it = mServiceMap.find(aServiceID);
	if (it == mServiceMap.end())
	{
		arStageID = -1;
		char buffer[256];
		sprintf(buffer, "No stage is configured to accept service ID %d", aServiceID);

		SetError(PIPE_ERR_CONFIGURATION_ERROR, ERROR_MODULE, ERROR_LINE,
						 functionName, buffer);

		return FALSE;
	}

	arStageID = it->second;

	return TRUE;
}

BOOL SessionRouter::CalculateServiceStages(const ListenerInfo & arListenerInfo,
																					 const PipelineInfo & arPipelineInfo)
{
	const char * functionName = "SessionRouter::CalculateServiceStages";
	// for each service listed in the listener configuration,
	// map service ID to stage ID

	ListenerInfo::StageNameMap::const_iterator it;

	for (it = arListenerInfo.GetStages().begin();
			 it != arListenerInfo.GetStages().end();
			 ++it)
	{
		int svcid = it->first;
		const StageMapInfo & mapInfo = it->second;

		// get the stage ID for this stage name
		int stageID = arPipelineInfo.GetStageID(mapInfo.GetName());
		if (stageID == -1)
		{
			mLogger.LogVarArgs(LOG_ERROR, "Stage %s not found in list of stages",
												 mapInfo.GetName());
			mLogger.LogVarArgs(LOG_ERROR, "Stage %s exists in servicetostagemap.xml but is not a pipeline stage or is missing",
												 mapInfo.GetName());
			// service should exist since it was translated from a service name
			SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName);
			return FALSE;
		}

		// add the mapping
		mServiceMap[svcid] = stageID;
	}
	return TRUE;
}

