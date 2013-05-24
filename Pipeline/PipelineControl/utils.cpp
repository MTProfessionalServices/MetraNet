/**************************************************************************
 * @doc UTILS
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

#include <StdAfx.h>
#include "controlutils.h"
#include <mtcryptoapi.h>
#include <batchsupport.h>
#include <MTUtil.h>

#include <mtglobal_msg.h>

_COM_SMARTPTR_TYPEDEF(ITransaction, __uuidof(ITransaction));

// TODO: move these routines to a more common place

HRESULT GetMessageBodyFromQueue(MessageQueue & arQueue,
																const wchar_t * apSessionID,
																string & arBody,
																int & arAppSpecific,
																PropertyCount & arPropCount)
{

	unsigned char * buffer;
	int bodyLen;
 	HRESULT hr = GetMessageBodyFromQueue(arQueue, apSessionID,
																			 &buffer, &bodyLen,
																			 arAppSpecific, arPropCount);
	if (FAILED(hr))
		return hr;

	arBody = "";
	arBody.append((const char *) buffer, bodyLen);

	delete [] buffer;
	buffer = NULL;

	return hr;
}

HRESULT GetMessageBodyFromQueue(MessageQueue & arQueue,
																const wchar_t * apSessionID,
																unsigned char * * apBody,
																int * apBodyLength,
																int & arAppSpecific,
																PropertyCount & arPropCount)
{
	//
	// iterate through the messages in the queue until we find the
	// one for the session ID passed in
	//
	QueueCursor cursor;
	if (!cursor.Init(arQueue))
		return HRESULT_FROM_WIN32(cursor.GetLastError()->GetCode());

	HRESULT hr = S_OK;
	QueueMessage message;
	for (int count = 0; ; count++)
	{
		message.ClearProperties();

		// get the label in order to find the UID
		// the label is only about 24 characters, so this should be plenty
		wchar_t labelBuffer[64];
		message.SetLabelLen(sizeof(labelBuffer));
		message.SetLabel(labelBuffer);

		// peek at the message
		if (!arQueue.Peek(message, cursor, (count == 0), 0))
		{
			const ErrorObject * err = arQueue.GetLastError();

			// if we timed out, we're at the end of the queue
			if (!err)
			{
				hr = PIPE_ERR_INVALID_SESSION;
				break;
			}

			// otherwise there was a problem
			hr = HRESULT_FROM_WIN32(err->GetCode());
			break;
		}

		if (0 == wcscmp(labelBuffer, apSessionID))
		{
			// now get the body of the message

			// have to supply some sort of buffer..
			unsigned char fakeBuffer[1];
			message.SetBody(fakeBuffer, sizeof(fakeBuffer));
			message.SetBodySize(sizeof(fakeBuffer));

			// this call should fail with MQ_ERROR_BUFFER_OVERFLOW
			if (!arQueue.Peek(message, cursor, TRUE, 0))
			{
				const ErrorObject * err = arQueue.GetLastError();

				// shouldn't be possible to timeout here
				if (!err)
				{
					hr = PIPE_ERR_INTERNAL_ERROR;
					break;
				}

				if (err->GetCode() != MQ_ERROR_BUFFER_OVERFLOW)
				{
					// shouldn't happen unless something's wrong with the queue
					//mLogger.LogVarArgs(LOG_ERROR, "Unexpected error returned from MSMQ peek: %x",
					//									 err->GetCode());
					hr = err->GetCode();
					//SetError(err);
					break;
				}
			}
			else
			{
				// the function should have failed
				hr = PIPE_ERR_INTERNAL_ERROR;

				//mLogger.LogVarArgs(LOG_ERROR, "Unexpected queue behaviour");

				//SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
				//				 "Unexpected routing queue behavior");
				break;
			}

			const ULONG * size = message.GetBodySize();
			ASSERT(size);
			int bufferSize = *size;
			message.ClearProperties();

			unsigned char * buffer = new unsigned char[bufferSize + 1];
			*apBody = buffer;

			// receive the body..
			message.SetBody((UCHAR *) buffer, bufferSize);

			// .. and the app specific long
			message.SetAppSpecificLong(0);

			// .. and the property count struct
			message.SetExtensionLen(sizeof(arPropCount));
			message.SetExtension((unsigned char *) &arPropCount, sizeof(arPropCount));

			// peek once again to get the contents of the body
			if (!arQueue.Peek(message, cursor, TRUE, 0))
			{
				const ErrorObject * err = arQueue.GetLastError();

				// shouldn't be possible to timeout here
				if (!err)
				{
					hr = PIPE_ERR_INTERNAL_ERROR;
					break;
				}

				// this time it's really an error
				//mLogger.LogVarArgs(LOG_ERROR, "Unexpected queue behaviour");
				//SetError(err);
				hr = err->GetCode();
				break;
			}
			// null terminate
			buffer[bufferSize] = '\0';
			*apBodyLength = bufferSize;

			// return the app specific long to the user
			const ULONG * appspecific = message.GetAppSpecificLong();
			ASSERT(appspecific);
			arAppSpecific = *appspecific;

			// NOTE: buffer must be deleted by the caller!
			break;
		}

		if (FAILED(hr))
			break;
	}

	return hr;
}


HRESULT RemoveFromQueue(MessageQueue & arQueue, const wchar_t * apSessionID,
												PIPELINECONTROLLib::IMTTransactionPtr aTxn)
{
	//
	// iterate through the messages in the queue until we find the
	// one for the session ID passed in
	//
	QueueCursor cursor;
	if (!cursor.Init(arQueue))
		return HRESULT_FROM_WIN32(cursor.GetLastError()->GetCode());

	HRESULT hr = S_OK;
	QueueMessage message;
	for (int count = 0; ; count++)
	{
		message.ClearProperties();

		// get the label in order to find the UID
		// the label is only about 24 characters, so this should be plenty
		wchar_t labelBuffer[64];
		message.SetLabelLen(sizeof(labelBuffer));
		message.SetLabel(labelBuffer);

		// peek at the message
		if (!arQueue.Peek(message, cursor, (count == 0), 0))
		{
			const ErrorObject * err = arQueue.GetLastError();

			// if we timed out, we're at the end of the queue
			if (!err)
			{
				hr = PIPE_ERR_INTERNAL_ERROR;
				break;
			}

			// otherwise there was a problem
			hr = HRESULT_FROM_WIN32(err->GetCode());
			break;
		}

		if (0 == wcscmp(labelBuffer, apSessionID))
		{
			BOOL receiveSuccess;
			if (aTxn != NULL)
			{
				// this operation must be part of a transaction

				IUnknownPtr unknownTxn = aTxn->GetTransaction();
				ITransactionPtr txn = unknownTxn;
				if (txn == NULL)
					return E_NOINTERFACE;			// QueryInterface must have failed
				QueueTransaction queueTxn(txn);

				receiveSuccess = arQueue.Receive(message, cursor, queueTxn, 0);
			}
			else
			{
				receiveSuccess = arQueue.Receive(message, cursor, 0);
			}

			if (!receiveSuccess)
			{
				const ErrorObject * err = arQueue.GetLastError();

				// shouldn't time out so there should be an error
				if (!err)
					hr = PIPE_ERR_INTERNAL_ERROR;

				// otherwise there was a problem
				hr = HRESULT_FROM_WIN32(err->GetCode());
			}

			break;
		}

		if (FAILED(hr))
			break;
	}

	return hr;
}

HRESULT SpoolMessage(MessageQueue & arMessageQueue,
										 const char * apMessage,
										 int aMessageLen,
										 const wchar_t * apUID, BOOL aExpress,
										 PropertyCount & arPropCount,
										 PIPELINECONTROLLib::IMTTransactionPtr aTxn)
{
	//
	// set up the queue message
	//
	QueueMessage sendme;
	MessageQueueProps props;
	BOOL bIsTransactional;
	//hacky... call this to just initialize internal variant
	props.SetTransactional(FALSE);
	if(!arMessageQueue.GetQueueProperties(props) || !props.GetTransactional(&bIsTransactional))
	{
		//mLogger.LogVarArgs(LOG_ERROR, "Unexpected error returned while querying for queue properties of %s",
		//												 (char*)_bstr_t(arMessageQueue.GetPathname()));
		return E_FAIL;
	}


	sendme.SetExpressDelivery(aExpress);

	// app specific long = service ID
	//sendme.SetAppSpecificLong(aServiceID);

	// set the label of the message to the base 64 version of the UID
	sendme.SetLabel(apUID);

	// body = the message
	sendme.SetBody((UCHAR *) apMessage, aMessageLen);

	// sets the extension (in this case, the property count struct)
	sendme.SetExtension((UCHAR *) &arPropCount, sizeof(arPropCount));

	sendme.SetPriority(PIPELINE_STANDARD_PRIORITY);

	if(bIsTransactional)
	{
		if (aTxn != NULL)
		{
			// this operation must be part of a transaction

			IUnknownPtr unknownTxn = aTxn->GetTransaction();
			ITransactionPtr txn = unknownTxn;
			if (txn == NULL)
				return E_NOINTERFACE;			// QueryInterface must have failed
			QueueTransaction queueTxn(txn);

			if (!arMessageQueue.Send(sendme, queueTxn))
			{
				// TODO: use the rest of the error
				return HRESULT_FROM_WIN32(arMessageQueue.GetLastError()->GetCode());
			}
		}
		else
		{
			//error: attempt to spool message to transactional queue with out a transaction object
			return E_FAIL;
		}
	}
	else
	{
		if (!arMessageQueue.Send(sendme))
		{
			// TODO: use the rest of the error
			return HRESULT_FROM_WIN32(arMessageQueue.GetLastError()->GetCode());
		}
	}

	return S_OK;
}



HRESULT DecryptMessage(const unsigned char * apMessage, int aMessageLength,
											 std::string & arDecrypted,
											 MetraTech_Pipeline_Messages::IMessageUtilsPtr aMessageUtils /* = NULL */)
{
	MetraTech_Pipeline_Messages::IMessageUtilsPtr messageUtils;
	if (aMessageUtils == NULL)
	{
		HRESULT hr = messageUtils.CreateInstance("MetraTech.Pipeline.Messages.MessageUtils");
		if (FAILED(hr))
			return hr;
		aMessageUtils = messageUtils;
	}

	// IsEncoded only needs to see the beginning of the string so
	// we construct a small version first

	int startLength;
	if (aMessageLength < 256)
		startLength = aMessageLength;
	else
		startLength = 256;

	wstring wstrBuffer;
	ASCIIToWide(wstrBuffer, (const char *) apMessage, startLength);

	if (aMessageUtils->IsEncoded(wstrBuffer.c_str()))
	{
		_bstr_t uid;
		_bstr_t messageUid;

		wstring wstrBuffer;
		ASCIIToWide(wstrBuffer, (const char *) apMessage, aMessageLength);

		_bstr_t decodedMessage = aMessageUtils->DecodeMessage(wstrBuffer.c_str(),
																												 uid.GetAddress(),
																												 messageUid.GetAddress());
		arDecrypted = (const char *) decodedMessage;
	}
	else
	{
		arDecrypted = std::string((const char *) apMessage, aMessageLength);
	}

	return S_OK;
}
