/**************************************************************************
 * @doc RECEIPT
 *
 * Copyright 2000 by MetraTech Corporation
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
#include <receipt.h>
#include <makeunique.h>
#include <queue.h>

#include <MSIX.h>

SessionReceipt::SessionReceipt()
{ }

SessionReceipt::~SessionReceipt()
{ }

BOOL SessionReceipt::Init(const wchar_t * apMachineName,
													const wchar_t * apQueueName,
													const wchar_t * apFailedReceiptMachine,
													const wchar_t * apFailedQueueName,
													BOOL aPrivate)
{
	ErrorObject * queueErr;

	std::wstring queueName(apQueueName);
	MakeUnique(queueName);
	if (!SetupQueue(mReceiptQueue, queueName.c_str(), apMachineName,
									L"Audit queue", FALSE, TRUE, aPrivate, FALSE,
									&queueErr))
	{
		SetError(queueErr);
		delete queueErr;
		mLogger.LogThis(LOG_ERROR, "Could not setup audit queue");
		return FALSE;
	}

	queueName = apFailedQueueName;
	MakeUnique(queueName);
	if (!SetupQueue(mFailedReceiptQueue, queueName.c_str(), apFailedReceiptMachine,
									L"Failed audit queue", FALSE, TRUE, aPrivate,
									TRUE,					// transactional
									&queueErr))
	{
		SetError(queueErr);
		delete queueErr;
		mLogger.LogThis(LOG_ERROR, "Could not setup failed audit queue");
		return FALSE;
	}

	return TRUE;
}

BOOL SessionReceipt::SendReceiptOfSuccess(MTPipelineLib::IMTSessionPtr aSession,
																					BOOL aExpress)
{
	const char * functionName = "SessionReceipt::SendReceipt";

	// get the UID from the session object
	// TODO: don't hardcode length
	unsigned char uidBytes[16];
	aSession->GetUID(uidBytes);

	// TODO: is the service ID used?
	long serviceID = aSession->GetServiceID();

	return SendReceiptInternal(uidBytes, FALSE, NULL, aExpress, serviceID);
}

BOOL SessionReceipt::SendReceiptOfSuccess(MTPipelineLib::IMTSessionSetPtr aSet,
																					BOOL aExpress)
{
	const char * functionName = "SessionReceipt::SendReceipt";

	// get the UID from the session object
	// TODO: don't hardcode length
	unsigned char uidBytes[16];
	aSet->GetUID(uidBytes);

	// TODO: is the service ID used?
	long serviceID = -1;

	return SendReceiptInternal(uidBytes, FALSE, NULL, aExpress, serviceID);
}

BOOL SessionReceipt::SendReceiptOfError(MTPipelineLib::IMTSessionPtr aSession,
																				QueueTransaction & arTran, BOOL aExpress)
{
	const char * functionName = "SessionReceipt::SendReceipt";

	// get the UID from the session object
	// TODO: don't hardcode length
	unsigned char uidBytes[16];
	aSession->GetUID(uidBytes);

	// TODO: is the service ID used?
	long serviceID = aSession->GetServiceID();

	return SendReceiptInternal(uidBytes, TRUE, &arTran, aExpress, serviceID);
}

BOOL SessionReceipt::SendReceiptOfError(MTPipelineLib::IMTSessionSetPtr aSet,
																				QueueTransaction & arTran, BOOL aExpress)
{
	const char * functionName = "SessionReceipt::SendReceipt";

	// get the UID from the session object
	// TODO: don't hardcode length
	unsigned char uidBytes[16];
	aSet->GetUID(uidBytes);

	// TODO: is the service ID used?
	long serviceID = -1;

	return SendReceiptInternal(uidBytes, TRUE, &arTran, aExpress, serviceID);
}

BOOL SessionReceipt::SendReceiptInternal(unsigned char * apUID,
																				 BOOL aFailed,
																				 QueueTransaction * apTran,
																				 BOOL aExpress,
																				 long aServiceID)
{
	const char * functionName = "SessionReceipt::SendReceiptInternal";

	string asciiUID;

	// encode it to ASCII
	MSIXUidGenerator::Encode(asciiUID, apUID);

	// convert to a wide string..
	std::wstring wideUID;
	ASCIIToWide(wideUID, asciiUID.c_str(), asciiUID.length());

	// set up the queue message
	QueueMessage sendme;
	sendme.ClearProperties();

	sendme.SetExpressDelivery(aExpress);

	// app specific long = service ID
	sendme.SetAppSpecificLong(aServiceID);

	// set the label of the message to the base 64 version of the UID
	sendme.SetLabel(wideUID.c_str());

	// message has no body.  Just the label..

	if (!aFailed)
	{
		mLogger.LogVarArgs(LOG_DEBUG, "Sending receipt for successful set or session %s",
											 (const char *) asciiUID.c_str());

		if (!mReceiptQueue.Send(sendme))
		{
			SetError(mReceiptQueue);
			return FALSE;
		}
	}
	else
	{
		mLogger.LogVarArgs(LOG_DEBUG, "Sending receipt for failed set or session %s",
											 (const char *) asciiUID.c_str());

		// NOTE: we really don't need a full transaction for this - could use
		// a "single session transaction"
		if (!mFailedReceiptQueue.Send(sendme, *apTran))
		{
			SetError(mFailedReceiptQueue);
			return FALSE;
		}
	}

	return TRUE;
}

