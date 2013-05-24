/**************************************************************************
 * @doc FEEDBACK
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

#include <feedback.h>

#include <routeconfig.h>
#include <loggerconfig.h>

#include <MSIX.h>

#include <mtprogids.h>
#include <msmqlib.h>
#include <queue.h>

#include <propids.h>

#include <mtglobal_msg.h>
#include <SetIterate.h>
#include <makeunique.h>

// TODO: don't include sharedsess directly..
#include <sharedsess.h>

/*************************************************** globals ***/

static BOOL StreamObject(std::string & arBuffer, const MSIXObject & arObj)
{
	XMLWriter stringWrite;
	arObj.Output(stringWrite);

	const char * data;
	int len;
	stringWrite.GetData(&data, len);
	arBuffer = data;
	return TRUE;
}

/******************************************* SessionFeedback ***/

SessionFeedback::SessionFeedback()
{ }

SessionFeedback::~SessionFeedback()
{
}

BOOL SessionFeedback::Init(const MeterRoutes & arRoutes, BOOL aPrivateQueues)
{
	const char * functionName = "SessionFeedback::Init";

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[Feedback]");

	HRESULT hr = mNameID.CreateInstance(MTPROGID_NAMEID);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	if (!InitializeRoutes(arRoutes, aPrivateQueues))
		return FALSE;

	return TRUE;
}

BOOL SessionFeedback::InitializeRoutes(const MeterRoutes & arRoutes, BOOL aPrivateQueues)
{
	// create a mapping from meter ID to meter ID
	MeterRouteQueueInfoList::const_iterator it;
	for (it = arRoutes.mQueueInfo.begin(); it != arRoutes.mQueueInfo.end();
			 ++it)
	{
		const MeterRouteQueueInfo & info = *it;

		const std::wstring & machineName = info.GetMachineName();
		std::wstring queueName = info.GetQueueName();
		MakeUnique(queueName);


		long meterID = mNameID->GetNameID(info.GetMeterName().c_str());

		MessageQueue & queue = mListenerQueueMap[meterID];

		ErrorObject * queueErr;
		if (!SetupQueue(queue, queueName.c_str(), machineName.c_str(),
										L"Feedback Queue", FALSE, TRUE,
										aPrivateQueues, FALSE,
										&queueErr))
		{
			SetError(queueErr);
			delete queueErr;
			mLogger.LogThis(LOG_ERROR, "Could not setup listener feedback queue");
			return FALSE;
		}
	}

	return TRUE;
}



BOOL SessionFeedback::RequiresFeedback(MTPipelineLib::IMTSessionPtr aSession)
{
	// TODO: should be GetEvents
	int events = aSession->Getevents();

	if ((events & SharedSession::FEEDBACK) == 0)
		return FALSE;								// no feedback necessary

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

MTPipelineLib::IMTSessionPtr
FindFailedSession(MTPipelineLib::IMTSessionPtr aSession)
{
	// find the error code and error string for this session.
	// NOTE: if this is a compound session the error might be
	// a child.

	if (aSession->PropertyExists(PipelinePropIDs::ErrorCodeCode(), MTPipelineLib::SESS_PROP_TYPE_LONG))
		return aSession;
	else
	{
		MTPipelineLib::IMTSessionSetPtr descendants = aSession->SessionChildren();
		
		SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
		HRESULT hr = it.Init(descendants);
		if (FAILED(hr))
		{
			ASSERT(0);
			return NULL;
		}

		MTPipelineLib::IMTSessionPtr firstSession;
		while (TRUE)
		{
			MTPipelineLib::IMTSessionPtr session = it.GetNext();
			if (session == NULL)
				break;

			if (session->PropertyExists(PipelinePropIDs::ErrorCodeCode(), MTPipelineLib::SESS_PROP_TYPE_LONG))
				return session;
		}
	}

	return NULL;
}


BOOL SessionFeedback::SendFeedback(const vector<MTPipelineLib::IMTSessionSetPtr> & arSessionSets,
																	 BOOL aError, BOOL aExpress)
{
	const char * functionName = "SessionFeedback::SendFeedback";

	BOOL includeResponseUIDs = TRUE;
	// TODO: for now, if this session was metered individually, send it back individually
	if (arSessionSets.size() == 0 && arSessionSets[0]->GetCount() == 1)
		includeResponseUIDs = FALSE;

	MSIXMessage msixMessage;
	CreateMessageWrapper(&msixMessage);

	// delete everything in the body
	msixMessage.DeleteBody(TRUE);

	// NOTE: the listener we respond to is marked in each session in the set.
	//       we verify that they all agree.
	long meterID = -1;

	for (int set = 0; set < (int) arSessionSets.size(); set++)
	{
		SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
		HRESULT hr = it.Init(arSessionSets[set]);
		if (FAILED(hr))
		{
			SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}

		BOOL result = TRUE;
		while (TRUE)
		{
			MTPipelineLib::IMTSessionPtr session = it.GetNext();
			if (session == NULL)
				break;

			long thisMeterID = session->GetLongProperty(PipelinePropIDs::FeedbackMeterID());
			if (meterID == -1)
				meterID = thisMeterID;
			else
				ASSERT(meterID == thisMeterID);

			HRESULT sessionErrorCode;

			// generate a session status message
			MSIXSessionStatus * status = new MSIXSessionStatus;


			if (aError)
			{
				MTPipelineLib::IMTSessionPtr failedSession = FindFailedSession(session);
				if (failedSession)
				{
					sessionErrorCode = failedSession->GetLongProperty(PipelinePropIDs::ErrorCodeCode());

					status->SetCode(sessionErrorCode);
					status->SetStatusMessage(
						MSIXString((const wchar_t *)
											 failedSession->GetStringProperty(PipelinePropIDs::ErrorStringCode())));
				}
				else
				{
					sessionErrorCode = PIPE_ERR_CANNOT_AUTO_RESUBMIT;
					status->SetCode(sessionErrorCode);
					status->SetStatusMessage(MSIXString((const wchar_t *)
																							L"Sessions within the session set have failed"));
				}
			}
			else
			{
				sessionErrorCode = S_OK;
			}

			// get the external UID generated by the SDK from the session object
			std::wstring wideUID;
			wideUID = (wchar_t *) _bstr_t(session->GetStringProperty(PipelinePropIDs::ExternalSessionIDCode()));

			// create a UID object with it
			MSIXUid uidObject;
			uidObject.Init(wideUID.c_str());

			// need the UID to identify which session this refers to
			if (includeResponseUIDs)
				status->SetUid(uidObject);

			// add to the overall message
			// NOTE: the msixMessage object takes ownership of the status
			//  so we don't need to delete it
			msixMessage.AddToBody(status);

			// if success, add the session itself
			if (sessionErrorCode == 0)
			{
				// generate an MSIX session
				MSIXSession * msixSession = new MSIXSession;
				// once the session is attached, we don't have to delete it
				status->AttachSession(msixSession);

				// set the service name
				std::string mystring = mNameID->GetName(session->GetServiceID());
				std::string serviceName;
				serviceName = _strlwr((char *)mystring.c_str());
				msixSession->SetName(serviceName.c_str());

				// assign the MSIX object the correct UID
				msixSession->SetUid(uidObject);

				// copy the properties from the session object
				if (!GenerateMSIXSession(session, *msixSession))
					return FALSE;
			}
		}
	}

	ASSERT(meterID != -1);
	mLogger.LogVarArgs(LOG_DEBUG, "Session feedback being sent to meter with ID=%d",
										 meterID);

	ListenerQueueMap::iterator it = mListenerQueueMap.find(meterID);
	if (it == mListenerQueueMap.end())
	{
		// no routing queue with that ID!
		SetError(PIPE_ERR_ROUTING_ERROR, ERROR_MODULE, ERROR_LINE,
						 functionName);
		return FALSE;
	}

	MessageQueue & queue = it->second;

	// stream the session
	std::string message;
	StreamObject(message, msixMessage);

	// set up the queue message
	QueueMessage sendme;
	sendme.ClearProperties();

	sendme.SetExpressDelivery(aExpress);

	// app specific long = service ID
	//sendme.SetAppSpecificLong(aServiceID);

	// get the UID from the session set
	// NOTE: each session set in the group should have the same UID
	unsigned char uidBytes[16];
	arSessionSets[0]->GetUID(uidBytes);
	string asciiUID;

	// encode it to ASCII
	MSIXUidGenerator::Encode(asciiUID, uidBytes);

	// convert to a wide string
	std::wstring wideUID;
	ASCIIToWide(wideUID, asciiUID.c_str(), asciiUID.length());

	// set the label of the message to the base 64 version of the UID
	sendme.SetLabel(wideUID.c_str());

	// body = the message
	sendme.SetBody((UCHAR *) message.c_str(), message.length());

	mLogger.LogVarArgs(LOG_DEBUG, "Sending feedback response for %s to meter %ld",
										 (const char *) asciiUID.c_str(), meterID);

	if (!queue.Send(sendme))
	{
		SetError(queue.GetLastError());
		return FALSE;
	}

	return TRUE;
}


BOOL SessionFeedback::GenerateMSIXSession(MTPipelineLib::IMTSessionPtr aSession,
																					MSIXSession & arMSIX)
{
	const char * functionName = "SessionFeedback::GenerateMSIXSession";
	time_t timeVal;
	long longVal;
	__int64 int64Val;
	_bstr_t stringVal;
	MSIXString msixStringVal;
	double doubleVal;
	VARIANT_BOOL boolVal;
	DECIMAL decVal;

	SetIterator<MTPipelineLib::IMTSessionPtr, MTPipelineLib::IMTSessionPropPtr> it;
	HRESULT hr = it.Init(aSession);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	while (TRUE)
	{
		MTPipelineLib::IMTSessionPropPtr prop = it.GetNext();
		if (prop == NULL)
			break;

		_bstr_t name = prop->GetName();
		MTPipelineLib::MTSessionPropType type = prop->Gettype();
		long nameid = prop->GetNameID();

		
		

		BOOL addSuccess=true;

		//mLogger.LogVarArgs(LOG_DEBUG, "Adding property %s to feedback session",
		//(const char *) name);

		switch (type)
		{
		case MTPipelineLib::SESS_PROP_TYPE_DATE:
			timeVal = aSession->GetDateTimeProperty(nameid);
			addSuccess = arMSIX.AddTimestampProperty(name, timeVal);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_TIME:
			longVal = aSession->GetTimeProperty(nameid);	
			// NOTE: casted to int
			addSuccess = arMSIX.AddProperty(name, (int) longVal);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_STRING:
			stringVal = aSession->GetBSTRProperty(nameid);
			msixStringVal = (const wchar_t *) stringVal;
			addSuccess = arMSIX.AddProperty(name, msixStringVal);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_LONG:
			longVal = aSession->GetLongProperty(nameid);
			// NOTE: casted to int
			addSuccess = arMSIX.AddProperty(name, (int) longVal);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
			int64Val = aSession->GetLongLongProperty(nameid);
			// NOTE: casted to int
			addSuccess = arMSIX.AddInt64Property(name, int64Val);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
			doubleVal = aSession->GetDoubleProperty(nameid);
			addSuccess = arMSIX.AddProperty(name, doubleVal);
			break;

		case MTPipelineLib::SESS_PROP_TYPE_BOOL:
			boolVal = aSession->GetBoolProperty(nameid);
			addSuccess = arMSIX.AddBooleanProperty(name,
																						 (boolVal == VARIANT_TRUE) ? TRUE : FALSE);

			break;

		case MTPipelineLib::SESS_PROP_TYPE_ENUM:
		{
			// TODO: it would be nice to get the string, not the number here,
			// but the string will work fine for now.  Also, have to watch the overhead
			// of the enum config object
      try
      {
			MTPipelineLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
			_bstr_t value =
				enumConfig->GetEnumeratorValueByID(aSession->GetEnumProperty(nameid));
			addSuccess = arMSIX.AddProperty(name, value);
      }
      catch(_com_error & err)
      {
        SetError(err.Error(), ERROR_MODULE, ERROR_LINE, functionName);
        return FALSE;
      }
			break;
		}
		case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
		{
			decVal = aSession->GetDecimalProperty(nameid);
			MTDecimal dv = decVal;
			// NOTE: casted to int
			addSuccess = arMSIX.AddProperty(name, dv.Format().c_str());
			break;
		}

		// ignore object properties
		case MTPipelineLib::SESS_PROP_TYPE_OBJECT:
			break;

		default:
			ASSERT(0);
		}

		ASSERT(addSuccess);
		if (!addSuccess)
		{
			SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}
	}

	return TRUE;
}

