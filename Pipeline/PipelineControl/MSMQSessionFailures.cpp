/**************************************************************************
 * MSMQSESSIONFAILURES
 *
 * Copyright 1997-2004 by MetraTech Corporation
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
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF")
#import <MTProductCatalogInterfacesLib.tlb> rename( "EOF", "RowsetEOF" )
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib;") \
     inject_statement("using ROWSETLib::IMTSQLRowsetPtr;") \
     inject_statement("using ROWSETLib::IMTSQLRowset;") \
     inject_statement("using MTProductCatalogInterfacesLib::IMTPropertyMetaDataPtr;") \
     inject_statement("using MTProductCatalogInterfacesLib::IMTPropertyMetaData;")

#import <MetraTech.Pipeline.ReRun.tlb> \
      inject_statement("using namespace mscorlib;") \
      inject_statement("using ROWSETLib::MTOperatorType;") \
      inject_statement("using namespace MTAUTHLib;")


#include "PipelineControl.h"
#include "MTSessionFailures.h"

#include <MTUtil.h>
#include <pipelineconfig.h>
#include <msmqlib.h>
#include <mtglobal_msg.h>
#include <sessionerr.h>
#include <MTSessionError.h>
#include <pipeconfigutils.h>
#include <loggerconfig.h>
#include <controlutils.h>
#include <rwcom.h>
#include <stdutils.h>
#include <mtcomerr.h>
#include <ConfigDir.h>
#include <UsageServerConstants.h>
#include <mtparamnames.h>
#include <DBConstants.h>
#include <MSIX.h>
#include <formatdbvalue.h>

using namespace ROWSETLib;

#define MTPARAM_SESSIONUID "%%SESSION_UID%%"

using COMMeterLib::ISessionPtr;
using COMMeterLib::ISessionSetPtr;
using COMMeterLib::IBatchPtr;

typedef pair <vector<unsigned char>, int> My_Pair;



MSMQSessionFailures::MSMQSessionFailures(PipelineInfo & pipelineInfo, NTLogger * logger)
	: mLogger(logger), mUtilsInitialized(FALSE)
{
	mMachineName = pipelineInfo.GetErrorQueueMachine();
	mQueueName = pipelineInfo.GetErrorQueueName();

	mUsePrivateQueues = pipelineInfo.UsePrivateQueues();

	mResubmitQueueName = pipelineInfo.GetResubmitQueueName();
	mResubmitQueueMachine = pipelineInfo.GetResubmitQueueMachine();
}

HRESULT MSMQSessionFailures::Refresh(ErrorObjectList& failures)
{
	// initialize the error queue
	MessageQueue errorQueue;
	HRESULT hr = InitErrorQueue(errorQueue);
	if (FAILED(hr))
		return hr;

	//
	// iterate through all messages in the queue and generate MTSessionError
	// objects out of them.
	//
	QueueCursor cursor;
	if (!cursor.Init(errorQueue))
		return HRESULT_FROM_WIN32(cursor.GetLastError()->GetCode());

	hr = S_OK;
	QueueMessage message;
	for (int count = 0; ; count++)
	{
		message.ClearProperties();

		// we need to know the body size
		message.SetBodySize(0);

		// have to supply some sort of buffer..
		unsigned char fakeBuffer[1];
		message.SetBody(fakeBuffer, sizeof(fakeBuffer));


		// this call should fail with MQ_ERROR_BUFFER_OVERFLOW
		// wait for 3 seconds max so we can recheck the exit flag
		if (!errorQueue.Peek(message, cursor, (count == 0), 0))
		{
			const ErrorObject * err = errorQueue.GetLastError();

			// if we timed out, we're at the end of the queue
			if (!err)
				break;

			if (err->GetCode() != MQ_ERROR_BUFFER_OVERFLOW)
			{
				// shouldn't happen unless something's wrong with the queue
				hr = HRESULT_FROM_WIN32(err->GetCode());
				break;
			}
		}
		else
		{
			// the function should have failed
			hr = PIPE_ERR_INTERNAL_ERROR;
			break;
		}

		const ULONG * size = message.GetBodySize();
		int bufferSize = *size;

		char * body = new char[bufferSize + 1];

		message.ClearProperties();

		// get the label in order to find the UID
		// the label is only about 24 characters, so this should be plenty
		wchar_t labelBuffer[64];
		message.SetLabelLen(sizeof(labelBuffer));
		message.SetLabel(labelBuffer);

		// receive the body..
		message.SetBody((UCHAR *) body, bufferSize);

		// peek at the same message again
		if (!errorQueue.Peek(message, cursor, TRUE, 0))
		{
			// we just peeked at it, so if this call fails something's wrong
			delete body;
			const ErrorObject * err = errorQueue.GetLastError();
			hr = HRESULT_FROM_WIN32(err->GetCode());
			break;
		}

		// null terminate
		body[bufferSize] = '\0';

		hr = HandleErrorMessage(labelBuffer, body, bufferSize + 1, failures);

		delete body;
		if (FAILED(hr))
			break;
	}

	return hr;
}


HRESULT MSMQSessionFailures::ResubmitSuspendedMessage(BSTR sessionID)
{
	// it was lost - no record exists in the error queue.
	// don't remove from error queue.  remove from routing queue
	HRESULT hr = S_OK;
	PIPELINECONTROLLib::IMTTransactionPtr aTxn("PipelineTransaction.MTTransaction");
	aTxn->Begin("ResubmitSuspendedMessage", aTxn->GetDefaultTimeout());
	try
	{
		hr = InternalResubmitSession(sessionID, FALSE, TRUE, aTxn);
		if(SUCCEEDED(hr))
			return aTxn->Commit();
		else
		{
			mLogger->LogVarArgs(LOG_ERROR, "Exception caught trying to resubmit lost session '%s': '%x'; Attempting to rollback transaction.",
				(const char *) _bstr_t(sessionID), hr);
			aTxn->Rollback();
			mLogger->LogThis(LOG_ERROR,"Transaction rolled back");
			return hr;
		}
	}
	catch (_com_error & e)
	{ 
		mLogger->LogVarArgs(LOG_ERROR, "Exception caught trying to resubmit lost session '%s': '%x'; Attempting to rollback transaction.",
			(const char *) _bstr_t(sessionID), hr);
		aTxn->Rollback();
		mLogger->LogThis(LOG_ERROR,"Transaction rolled back");
		return ReturnComError(e); 
	}
	catch(...)
	{
		mLogger->LogVarArgs(LOG_ERROR, "Unexpected Win32 error caught trying to resubmit lost session '%s'; Attempting to rollback transaction.",
			(const char *) _bstr_t(sessionID));
		aTxn->Rollback();
		mLogger->LogThis(LOG_ERROR,"Transaction rolled back");
		return E_FAIL; 
	}
}


HRESULT MSMQSessionFailures::DeleteSuspendedMessage(BSTR sessionID)
{
	// delete from routing queue journal only
	// NO transaction is used (routing queue operations can't be made
	// transactional)
	HRESULT hr = InternalAbandonSession(sessionID, FALSE, TRUE, NULL);
	if (FAILED(hr))
	{
		mLogger->LogThis(LOG_WARNING, "Unable to delete suspended transaction");

		// NOTE: we intentionally return S_OK because if the
		// session couldn't be deleted from the queue, then it's already
		// deleted (most likely).
		return S_OK;
	}

	return S_OK;
}

SessionErrorObject * MSMQSessionFailures::FindError(const wchar_t * apLabel)
{
	// initialize the error queue
	MessageQueue errorQueue;
	HRESULT hr = InitErrorQueue(errorQueue);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	//
	// iterate through all messages in the queue
	//
	QueueCursor cursor;
	if (!cursor.Init(errorQueue))
		MT_THROW_COM_ERROR(HRESULT_FROM_WIN32(cursor.GetLastError()->GetCode()));

	if (!mUtilsInitialized)
	{
		hr = InitializeMessageUtils();
		if (FAILED(hr))
			MT_THROW_COM_ERROR(hr);
	}


	SessionErrorObject * errObj = new SessionErrorObject;
	hr = S_OK;
	QueueMessage message;
	for (int count = 0; ; count++)
	{
		message.ClearProperties();

		// we need to know the body size
		message.SetBodySize(0);

		// have to supply some sort of buffer..
		unsigned char fakeBuffer[1];
		message.SetBody(fakeBuffer, sizeof(fakeBuffer));

		// get the label in order to find the UID
		// the label is only about 24 characters, so this should be plenty
		wchar_t labelBuffer[64];
		message.SetLabelLen(sizeof(labelBuffer));
		message.SetLabel(labelBuffer);

		// this call should fail with MQ_ERROR_BUFFER_OVERFLOW
		// wait for 3 seconds max so we can recheck the exit flag
		if (!errorQueue.Peek(message, cursor, (count == 0), 0))
		{
			const ErrorObject * err = errorQueue.GetLastError();

			// if we timed out, we're at the end of the queue
			if (!err)
				break;

			if (err->GetCode() != MQ_ERROR_BUFFER_OVERFLOW)
			{
				// shouldn't happen unless something's wrong with the queue
				hr = HRESULT_FROM_WIN32(err->GetCode());
				break;
			}
		}
		else
		{
			// the function should have failed
			hr = PIPE_ERR_INTERNAL_ERROR;
			break;
		}

		//
		// if the label matches, decode the object.  otherwise
		// skip to the next message
		//
		if (0 != wcscmp(labelBuffer, apLabel))
			continue;


		const ULONG * size = message.GetBodySize();
		int bufferSize = *size;

		char * body = new char[bufferSize + 1];

		message.ClearProperties();

		// receive the body..
		message.SetBody((UCHAR *) body, bufferSize);

		// peek at the same message again
		if (!errorQueue.Peek(message, cursor, TRUE, 0))
		{
			// we just peeked at it, so if this call fails something's wrong
			delete body;
			const ErrorObject * err = errorQueue.GetLastError();
			hr = HRESULT_FROM_WIN32(err->GetCode());
			break;
		}

		// null terminate
		// TODO: don't need to null terminate?
		body[bufferSize] = '\0';

		if (!errObj->Decode((const unsigned char *) body, bufferSize))
		{
			HRESULT hr = errObj->GetLastError()->GetCode();
			delete body;
			MT_THROW_COM_ERROR(hr);
		}

		// the message is could still be encrypted and/or compressed.
		const char * rawMessage;
		int rawMessageLength;

		errObj->GetMessage(&rawMessage, rawMessageLength);

		// decrypt and/or decompress
		std::string buffer;

		hr = DecryptMessage((const unsigned char *) rawMessage,
												rawMessageLength, buffer, mMessageUtils);

		if (SUCCEEDED(hr))
			// set the message back again
			errObj->SetMessage(buffer.c_str(), buffer.length());
	}

	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);

	return errObj;
}

HRESULT MSMQSessionFailures::SaveXMLMessage(BSTR sessionID,
																						const char * apMessage,
																						GENERICCOLLECTIONLib::IMTCollectionPtr childrenToDelete)
{
	MetraTech_Pipeline_Messages::IFailedMSIXMessageUtilsPtr messageUtils;
			
	GUID guid = __uuidof(MetraTech_Pipeline_Messages::FailedMSIXMessageUtils);
	messageUtils = MetraTech_Pipeline_Messages::IFailedMSIXMessageUtilsPtr(guid);
	
	messageUtils->SaveFailedTransactionMessage(sessionID, apMessage);

	return S_OK;
}

bool MSMQSessionFailures::HasSavedXMLMessage(BSTR sessionID, PIPELINECONTROLLib::IMTTransactionPtr txn)
{
	MetraTech_Pipeline_Messages::IFailedMSIXMessageUtilsPtr messageUtils;
	
	GUID guid = __uuidof(MetraTech_Pipeline_Messages::FailedMSIXMessageUtils);
	if (txn != NULL)
		messageUtils = txn->CreateObjectWithTransactionByCLSID(&guid);
	else
		messageUtils = MetraTech_Pipeline_Messages::IFailedMSIXMessageUtilsPtr(guid);
	
	return (messageUtils->HasSavedFailedTransactionMessage(sessionID) == VARIANT_TRUE);
}

HRESULT MSMQSessionFailures::LoadXMLMessage(BSTR sessionID,
																						std::string & arMessage,
																						PIPELINECONTROLLib::IMTTransactionPtr txn)
{
	MetraTech_Pipeline_Messages::IFailedMSIXMessageUtilsPtr messageUtils;
	GUID guid = __uuidof(MetraTech_Pipeline_Messages::FailedMSIXMessageUtils);
	if (txn != NULL)
		messageUtils = txn->CreateObjectWithTransactionByCLSID(&guid);
	else
		messageUtils = MetraTech_Pipeline_Messages::IFailedMSIXMessageUtilsPtr(guid);
	
	_bstr_t message = messageUtils->LoadFailedTransactionMessage(sessionID);
	arMessage = (const char * ) message;

	return S_OK;
}

HRESULT MSMQSessionFailures::DeleteSavedXMLMessage(BSTR sessionID, PIPELINECONTROLLib::IMTTransactionPtr txn)
{
	MetraTech_Pipeline_Messages::IFailedMSIXMessageUtilsPtr messageUtils;
	
	GUID guid = __uuidof(MetraTech_Pipeline_Messages::FailedMSIXMessageUtils);
	if (txn != NULL)
		messageUtils = txn->CreateObjectWithTransactionByCLSID(&guid);
	else
		messageUtils = MetraTech_Pipeline_Messages::IFailedMSIXMessageUtilsPtr(guid);
	
	messageUtils->DeleteFailedTransactionMessage(sessionID);

	return S_OK;
}


HRESULT MSMQSessionFailures::HandleErrorMessage(const wchar_t * apLabel,
																								const char * apBody,
																								int aBodySize,
																								ErrorObjectList & failures)
{
	SessionErrorObject * errObj = new SessionErrorObject;

	if (!errObj->Decode((const unsigned char *) apBody, aBodySize))
	{
		HRESULT hr = errObj->GetLastError()->GetCode();
		delete errObj;
		return hr;
	}

	failures.push_back(errObj);

	return S_OK;
}

HRESULT MSMQSessionFailures::InitErrorQueue(MessageQueue & arQueue)
{
	// initialize the error queue
	return InitQueue(arQueue, mMachineName.c_str(), mQueueName.c_str());
}

HRESULT MSMQSessionFailures::InitQueue(MessageQueue & arQueue,
																			const wchar_t * apMachine,
																			const wchar_t * apQueueName)
{
	if (wcslen(apMachine) == 0)
		apMachine = NULL;

	if (!arQueue.Init(apQueueName, mUsePrivateQueues, apMachine)
			|| !arQueue.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE))
		return HRESULT_FROM_WIN32(arQueue.GetLastError()->GetCode());

	return S_OK;
}

HRESULT MSMQSessionFailures::RemoveFromErrorQueue(const wchar_t * apSessionID,
																								 PIPELINECONTROLLib::IMTTransactionPtr aTxn)
{
	// initialize the error queue
	MessageQueue errorQueue;
	HRESULT hr = InitErrorQueue(errorQueue);
	if (FAILED(hr))
		return hr;

	return RemoveFromQueue(errorQueue, apSessionID, aTxn);
}


HRESULT MSMQSessionFailures::RemoveFromAuditQueue(const wchar_t * apMachine,
																								 const wchar_t * apQueueName,
																								 const wchar_t * apSessionID)
{
	// initialize the audit queue
	MessageQueue auditQueue;

	if (wcslen(apMachine) == 0)
		apMachine = NULL;

	// use the journal, not the routing queue itself
	if (!auditQueue.InitJournal(apQueueName, mUsePrivateQueues, apMachine)
			|| !auditQueue.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE))
		return HRESULT_FROM_WIN32(auditQueue.GetLastError()->GetCode());

	// no transaction
	return RemoveFromQueue(auditQueue, apSessionID, NULL);
}

HRESULT MSMQSessionFailures::InternalResubmitSession(
	BSTR sessionID,
	BOOL aRemoveFromError,
	BOOL aRemoveFromRQ,
	PIPELINECONTROLLib::IMTTransactionPtr aTxn)
{
	// NOTE: mark the database first because it's possible to resubmit it
	// and have it fail again before marking it.
	// we only mark it by UID.  Since the UIDs are the same, all records
	// (including the new failure) will be marked with the new status.
	// this makes it seem to disappear.
	_bstr_t bstrID(sessionID);
	HRESULT hr = MarkFailure(sessionID, STATE_RESUBMITTED, aTxn);
	if (FAILED(hr))
	{
		mLogger->LogVarArgs(LOG_ERROR, "Unable to mark failure as resubmitted for session %s",
											 (const char *) bstrID);
		return hr;
	}

	// delete the record the suspended transaction, (if there is any)
	ROWSETLib::IMTSQLRowsetPtr changeRowset(MTPROGID_SQLROWSET);
	// use a directory that uses OLEDB
	changeRowset->Init("\\Queries\\AccountCreation");
	// the query itself is in the main Database directory
	changeRowset->UpdateConfigPath("\\Queries\\Database");
	changeRowset->SetQueryTag("__DELETE_SUSPENDED_TXN_BY_UID__");
	changeRowset->AddParam(MTPARAM_SESSIONUID, bstrID);

	if (aTxn != NULL)
		changeRowset->JoinDistributedTransaction((ROWSETLib::IMTTransaction *) aTxn.GetInterfacePtr());

	changeRowset->Execute();


	BOOL removed = FALSE;
	if (aRemoveFromRQ)
	{
		// get a copy of the original message
		int appSpecific;

		// this searches the audit queue (journal of the routing queue)
		// to find the message
		mLogger->LogThis(LOG_DEBUG, "Enumerating all routing queues");

		ErrorObject error;
		RoutingQueueList queues;
		if (!GetAllRoutingQueues(queues, error))
			return error.GetCode();

		mLogger->LogVarArgs(LOG_DEBUG, "%d routing queues found", queues.size());

		hr = S_OK;

		RoutingQueueList::const_iterator it;
		for (it = queues.begin(); it != queues.end(); it++)
		{
			RoutingQueueInfo info = *it;

			mLogger->LogVarArgs(LOG_DEBUG, "Searching queue: %s:%s for session %s",
												 ascii(info.GetMachineName()).c_str(),
												 ascii(info.GetQueueName()).c_str(),
												 (const char *) bstrID);

			MessageQueue auditQueue;

			const wchar_t * machine;
			if (info.GetMachineName().length() == 0)
				machine = NULL;
			else
				machine = info.GetMachineName().c_str();

			// use the journal, not the routing queue itself
			if (!auditQueue.InitJournal(info.GetQueueName().c_str(),
																	mUsePrivateQueues, machine)
					|| !auditQueue.Open(MQ_RECEIVE_ACCESS, MQ_DENY_NONE))
				return HRESULT_FROM_WIN32(auditQueue.GetLastError()->GetCode());

			// property count structure
			PropertyCount propCount;

			unsigned char * body;
			int bodyLength;
			hr = GetMessageBodyFromQueue(auditQueue, bstrID, &body, &bodyLength,
																	 appSpecific, propCount);

			if (SUCCEEDED(hr))
			{
				mLogger->LogVarArgs(LOG_DEBUG, "Session read from queue: %s:%s",
													 ascii(info.GetMachineName()).c_str(),
													 ascii(info.GetQueueName()).c_str());
				// remove the message from the queue now that we have the copy
				// TODO: the read and remove could be done more efficiently
				// BP: Since this is a journal queue, it does not support transactional remove
				//always specify transaction as NULL
				hr = RemoveFromQueue(auditQueue, bstrID, NULL);
				if (FAILED(hr))
				{
					// this is bad, but for now we print the error and
					// continue to resubmit the session
					mLogger->LogThis(LOG_ERROR, "Unable to remove session from audit queue");
				}

				// drop it back into the routing queue
				MessageQueue routingQueue;
				if (!routingQueue.Init(info.GetQueueName().c_str(),
															 mUsePrivateQueues, machine)
						|| !routingQueue.Open(MQ_SEND_ACCESS, MQ_DENY_NONE))
				{
					mLogger->LogThis(LOG_ERROR, "Unable to open routing queue to resubmit message");
					return HRESULT_FROM_WIN32(routingQueue.GetLastError()->GetCode());
				}


				hr = SpoolMessage(routingQueue, (const char *) body, bodyLength,
													bstrID, FALSE, propCount, aTxn);
				if (FAILED(hr))
				{
					_bstr_t qname = routingQueue.GetFormatString().c_str();
					mLogger->LogVarArgs(LOG_INFO, "Unable to resubmit session '%s' to '%s' queue", (const char*)bstrID, (const char*)qname);
					mLogger->LogVarArgs(LOG_INFO, "Logging body of failed message with id '%s'", (const char*)bstrID);
					mLogger->LogVarArgs(LOG_INFO, "Message Body: %s", (const char*)body);
					return hr;
				}
				else
				{
					_bstr_t qname = routingQueue.GetFormatString().c_str();
					mLogger->LogVarArgs(LOG_INFO, "Session '%s' successfully resubmitted to '%s' queue", (const char*)bstrID, (const char*)qname);
					removed = TRUE;
					break;								// don't try the other queues
				}
			}
			else
			{
				mLogger->LogVarArgs(LOG_DEBUG, "Session not in queue: %X", hr);
				continue;
			}
		}
	}

	if (SUCCEEDED(hr) && aRemoveFromError)
	{
		// now remove it from the error queue
		hr = RemoveFromErrorQueue(bstrID, aTxn);
		if (FAILED(hr))
		{
			mLogger->LogVarArgs(LOG_ERROR, "Unable to delete message %s from error queue",
												 (const char *) bstrID);
			return hr;
		}

		mLogger->LogVarArgs(LOG_DEBUG, "Message %s deleted from error queue",
											 (const char *) bstrID);
	}

	if (!removed && aRemoveFromRQ)
		MT_THROW_COM_ERROR(L"Session not found", IID_IMTSessionFailures, E_INVALIDARG);

	return S_OK;
}


HRESULT MSMQSessionFailures::InternalAbandonSession(BSTR sessionID, BOOL aDeleteError,
																									 BOOL aDeleteFromRQ,
																									 PIPELINECONTROLLib::IMTTransactionPtr aTxn)
{
	// delete the SessionError struct from the error queue,
	// then remove the session from the journal queue
	_bstr_t bstrID(sessionID);
	
	mLogger->LogVarArgs(LOG_INFO, "Abandoning session %s", (const char *) bstrID);

	if (aDeleteError)
	{
		mLogger->LogVarArgs(LOG_INFO, "Removing %s from error queue", (const char *) bstrID);
		HRESULT hr = RemoveFromErrorQueue(bstrID, aTxn);
		if (FAILED(hr))
		{
			mLogger->LogVarArgs(LOG_ERROR, "Session %s not found in error queue",
												 (const char *) bstrID);
			return hr;
		}
	}

	if (aDeleteFromRQ)
	{
		if (!aDeleteError)
		{
			mLogger->LogVarArgs(LOG_DEBUG, "Deleting %s from suspended transaction list", (const char *) bstrID);

			// delete the record the suspended transaction, (if there is any)
			ROWSETLib::IMTSQLRowsetPtr changeRowset(MTPROGID_SQLROWSET);
			// use a directory that uses OLEDB
			changeRowset->Init("\\Queries\\AccountCreation");
			// the query itself is in the main Database directory
			changeRowset->UpdateConfigPath("\\Queries\\Database");
			changeRowset->SetQueryTag("__DELETE_SUSPENDED_TXN_BY_UID__");
			changeRowset->AddParam(MTPARAM_SESSIONUID, bstrID);

			if (aTxn != NULL)
				changeRowset->JoinDistributedTransaction((ROWSETLib::IMTTransaction *) aTxn.GetInterfacePtr());

			changeRowset->Execute();
		}

		mLogger->LogThis(LOG_DEBUG, "Enumerating all routing queues");

		ErrorObject error;
		RoutingQueueList queues;
		if (!GetAllRoutingQueues(queues, error))
			return error.GetCode();

		mLogger->LogVarArgs(LOG_DEBUG, "%d routing queues found", queues.size());

		if (mLogger->IsOkToLog(LOG_DEBUG))
		{
			RoutingQueueList::const_iterator it;
			for (it = queues.begin(); it != queues.end(); it++)
			{
				RoutingQueueInfo info = *it;
				mLogger->LogVarArgs(LOG_DEBUG, "Routing queue: %s:%s",
													 ascii(info.GetMachineName()).c_str(),
													 ascii(info.GetQueueName()).c_str());
			}
		}

		HRESULT hr;
		RoutingQueueList::const_iterator it;
		for (it = queues.begin(); it != queues.end(); it++)
		{
			RoutingQueueInfo info = *it;

			mLogger->LogVarArgs(LOG_DEBUG, "Attempting removal from queue: %s:%s",
												 ascii(info.GetMachineName()).c_str(),
												 ascii(info.GetQueueName()).c_str());

			// NOTE: this can't be made transactional
			ASSERT(aTxn == NULL);
			hr = RemoveFromAuditQueue(info.GetMachineName().c_str(),
																info.GetQueueName().c_str(),
																bstrID);
			if (SUCCEEDED(hr))
			{
				mLogger->LogVarArgs(LOG_DEBUG, "Session removed from queue: %s:%s",
													 ascii(info.GetMachineName()).c_str(),
													 ascii(info.GetQueueName()).c_str());
				// no need to look anymore
				break;
			}
			else
				mLogger->LogVarArgs(LOG_DEBUG, "Session not in queue: %X", hr);
		}

		if (FAILED(hr))
		{
			std::string buffer("Unable to locate session ");
			buffer += (const char *) bstrID;
			buffer += " in any routing queue";

			mLogger->LogVarArgs(LOG_ERROR, buffer.c_str());
			// not fatal - the session has successfully been abandoned because
			// it no longer exists in the router queue or audit queue
			if (aDeleteError)
				return S_FALSE;
			else
				MT_THROW_COM_ERROR(buffer.c_str());
		}
	}

	if (aDeleteError)
	{
		HRESULT hr = MarkFailure(sessionID, STATE_DELETED, aTxn);
		if (FAILED(hr))
		{
			mLogger->LogVarArgs(LOG_ERROR, "Unable to mark failure as deleted for session %s",
												 (const char *) bstrID);
			return hr;
		}
	}

	return S_OK;
}


HRESULT MSMQSessionFailures::RetrieveErrorObject(const wchar_t * apLabel,
																								SessionErrorObject& arError)
{
	// initialize the error queue
	MessageQueue errorQueue;
	HRESULT hr = InitErrorQueue(errorQueue);
	if (FAILED(hr))
		return hr;

	unsigned char * body;
	int bodyLength;
	int appSpecific;
	PropertyCount propCount;

	hr = GetMessageBodyFromQueue(errorQueue, apLabel,
															 &body, &bodyLength,
															 appSpecific, propCount);

	if (!arError.Decode(body, bodyLength))
	{
		HRESULT hr = arError.GetLastError()->GetCode();
		delete [] body;
		return hr;
	}

	delete [] body;

	return S_OK;
}


HRESULT MSMQSessionFailures::InitializeMessageUtils()
{
	if (mUtilsInitialized)
		return S_OK;

	HRESULT hr = mMessageUtils.CreateInstance("MetraTech.Pipeline.Messages.MessageUtils");
	if (FAILED(hr))
		return hr;

	mUtilsInitialized = TRUE;
	return S_OK;
}


HRESULT MSMQSessionFailures::MarkFailure(const wchar_t * apUID,
																				 FailedSessionState aState,
																				 PIPELINECONTROLLib::IMTTransactionPtr aTxn)
{
	const char * state;
	switch (aState)
	{
	case STATE_DELETED:
	  state = "D"; break;
	case STATE_RESUBMITTED:
		state = "R"; break;
	default:
		ASSERT(0);
		return E_INVALIDARG;
	}

	try
	{
		ROWSETLib::IMTSQLRowsetPtr changeRowset(MTPROGID_SQLROWSET);
		// use a directory that uses OLEDB
		changeRowset->Init("\\Queries\\AccountCreation");
		// the query itself is in the main Database directory
		changeRowset->UpdateConfigPath("\\Queries\\Database");
		changeRowset->SetQueryTag("__UPDATE_SYSTEM_FAILURES_BY_UID__");


		changeRowset->AddParam(MTPARAM_SESSIONUID, apUID);
		changeRowset->AddParam(MTPARAM_STATE, state);

		if (aTxn != NULL)
			changeRowset->JoinDistributedTransaction((ROWSETLib::IMTTransaction *) aTxn.GetInterfacePtr());

		changeRowset->Execute();
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return TRUE;
}
