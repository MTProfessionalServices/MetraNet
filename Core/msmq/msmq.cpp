/**************************************************************************
 * @doc MSMQ
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header$
 ***************************************************************************/

#include <metralite.h>
#include <msmqlib.h>

/***************************************** MessageQueueProps ***/

void MessageQueueProps::SetBasePriority(short aBasePriority)
{
	SetShortProperty(PROPID_Q_BASEPRIORITY, aBasePriority);
}

const short * MessageQueueProps::GetBasePriority() const
{
	return GetShortProperty(PROPID_Q_BASEPRIORITY);
}

void MessageQueueProps::SetJournal(BOOL aJournalOn)
{
	if (aJournalOn)
		SetUCHARProperty(PROPID_Q_JOURNAL, MQ_JOURNAL);
	else
		SetUCHARProperty(PROPID_Q_JOURNAL, MQ_JOURNAL_NONE);
}

BOOL MessageQueueProps::GetJournal(BOOL * apJournal) const
{
	const UCHAR * journal = GetUCHARProperty(PROPID_Q_JOURNAL);
	if (!journal)
		return FALSE;
	*apJournal = ((*journal) == MQ_JOURNAL);
	return TRUE;
}

void MessageQueueProps::SetJournalQuota(ULONG aQuota)
{
	SetULONGProperty(PROPID_Q_JOURNAL_QUOTA, aQuota);
}

const ULONG * MessageQueueProps::GetJournalQuota() const
{
	return GetULONGProperty(PROPID_Q_JOURNAL_QUOTA);
}

void MessageQueueProps::SetPathname(const wchar_t * apPathname)
{
	ASSERT(apPathname);
	SetWideStringProperty(PROPID_Q_PATHNAME, apPathname);
}

const wchar_t * MessageQueueProps::GetPathname() const
{
	return GetWideStringProperty(PROPID_Q_PATHNAME);
}


void MessageQueueProps::SetLabel(const wchar_t * apLabel)
{
	ASSERT(apLabel);
	SetWideStringProperty(PROPID_Q_LABEL, apLabel);
}

const wchar_t * MessageQueueProps::GetLabel() const
{
	return GetWideStringProperty(PROPID_Q_LABEL);
}


void MessageQueueProps::SetQuota(ULONG aQuota)
{
	SetULONGProperty(PROPID_Q_QUOTA, aQuota);
}

const ULONG * MessageQueueProps::GetQuota() const
{
	return GetULONGProperty(PROPID_Q_QUOTA);
}

void MessageQueueProps::SetTransactional(BOOL aIsTransactional)
{
	if (aIsTransactional)
		SetUCHARProperty(PROPID_Q_TRANSACTION, MQ_TRANSACTIONAL);
	else
		SetUCHARProperty(PROPID_Q_TRANSACTION, MQ_TRANSACTIONAL_NONE);
}

BOOL MessageQueueProps::GetTransactional(BOOL * apTransactional) const
{
	const UCHAR * transactional = GetUCHARProperty(PROPID_Q_TRANSACTION);
	if (!transactional)
		return FALSE;
	*apTransactional = ((*transactional) == MQ_TRANSACTIONAL);
	return TRUE;
}



/********************************************** QueueMessage ***/

void QueueMessage::SetJournal(int aValue)
{
	SetUCHARProperty(PROPID_M_JOURNAL, aValue);
}

const UCHAR * QueueMessage::GetJournal() const
{
	return GetUCHARProperty(PROPID_M_JOURNAL);
}


void QueueMessage::SetAcknowledge(int aValue)
{
	SetUCHARProperty(PROPID_M_ACKNOWLEDGE, aValue);
}

const UCHAR * QueueMessage::GetAcknowledge() const
{
	return GetUCHARProperty(PROPID_M_ACKNOWLEDGE);
}


void QueueMessage::SetAdminQueue(const MessageQueue & arQueue)
{
	SetAdminQueue(arQueue.GetFormatString().c_str());
}

void QueueMessage::SetAdminQueue(const wchar_t * apFormatName)
{
	ASSERT(apFormatName);
	SetWideStringProperty(PROPID_M_ADMIN_QUEUE, apFormatName);
}


const wchar_t * QueueMessage::GetAdminQueue() const
{
	return GetWideStringProperty(PROPID_M_ADMIN_QUEUE);
}


void QueueMessage::SetAppSpecificLong(long aValue)
{
	SetULONGProperty(PROPID_M_APPSPECIFIC, aValue);
}

const ULONG * QueueMessage::GetAppSpecificLong()
{
	return GetULONGProperty(PROPID_M_APPSPECIFIC);
}

void QueueMessage::SetBody(const UCHAR * apBytes, int aLen)
{
	ASSERT(apBytes);
	SetBytesProperty(PROPID_M_BODY, apBytes, aLen);
}

void QueueMessage::SetBodySize(ULONG aLen)
{
	SetULONGProperty(PROPID_M_BODY_SIZE, aLen);
}

void QueueMessage::SetExtension(const UCHAR * apBytes, int aLen)
{
	ASSERT(apBytes);
	SetBytesProperty(PROPID_M_EXTENSION, apBytes, aLen);
}

void QueueMessage::SetExtensionLen(ULONG aLen)
{
	SetULONGProperty(PROPID_M_EXTENSION_LEN, aLen);
}

const UCHAR * QueueMessage::GetBody() const
{
	return GetBytesProperty(PROPID_M_BODY);
}

const ULONG * QueueMessage::GetBodySize() const
{
	return GetULONGProperty(PROPID_M_BODY_SIZE);
}

const ULONG * QueueMessage::GetExtensionLen() const
{
	return GetULONGProperty(PROPID_M_EXTENSION_LEN);
}


void QueueMessage::SetExpressDelivery(BOOL aExpress)
{
	UCHAR express = aExpress ? MQMSG_DELIVERY_EXPRESS : MQMSG_DELIVERY_RECOVERABLE;
	SetUCHARProperty(PROPID_M_DELIVERY, express);
}


void QueueMessage::SetLabel(const wchar_t * apLabel)
{
	ASSERT(apLabel);
	SetWideStringProperty(PROPID_M_LABEL, apLabel);
}

const wchar_t * QueueMessage::GetLabel() const
{
	return GetWideStringProperty(PROPID_M_LABEL);
}


void QueueMessage::SetLabelLen(ULONG aLen)
{
	SetULONGProperty(PROPID_M_LABEL_LEN, aLen);
}

const ULONG * QueueMessage::GetLabelLen() const
{
	return GetULONGProperty(PROPID_M_LABEL_LEN);
}



void QueueMessage::SetResponseQueue(const MessageQueue & arQueue)
{
	SetResponseQueue(arQueue.GetFormatString().c_str());
}

void QueueMessage::SetResponseQueue(const wchar_t * apFormatName)
{
	ASSERT(apFormatName);
	SetWideStringProperty(PROPID_M_RESP_QUEUE, apFormatName);
}

const wchar_t * QueueMessage::GetResponseQueue() const
{
	return GetWideStringProperty(PROPID_M_RESP_QUEUE);
}


void QueueMessage::SetResponseQueueLen(ULONG aLen)
{
	SetULONGProperty(PROPID_M_RESP_QUEUE_LEN, aLen);
}

const ULONG * QueueMessage::GetResponseQueueLen() const
{
	return GetULONGProperty(PROPID_M_RESP_QUEUE_LEN);
}


void QueueMessage::SetPriority(int aPriority)
{
	// 7->0
	UCHAR pri = (UCHAR) aPriority;
	SetUCHARProperty(PROPID_M_PRIORITY, pri);
}


void QueueMessage::SetTimeToBeReceived(ULONG aSeconds)
{
	SetULONGProperty(PROPID_M_TIME_TO_BE_RECEIVED, aSeconds);
}

const ULONG * QueueMessage::GetTimeToBeReceived() const
{
	return GetULONGProperty(PROPID_M_TIME_TO_BE_RECEIVED);
}


void QueueMessage::SetTimeToReachQueue(ULONG aSeconds)
{
	SetULONGProperty(PROPID_M_TIME_TO_REACH_QUEUE, aSeconds);
}

const ULONG * QueueMessage::GetTimeToReachQueue() const
{
	return GetULONGProperty(PROPID_M_TIME_TO_REACH_QUEUE);
}


void QueueMessage::SetTrace(BOOL aTraceOn)
{
	UCHAR trace = aTraceOn ? MQMSG_SEND_ROUTE_TO_REPORT_QUEUE : MQMSG_TRACE_NONE;
	SetUCHARProperty(PROPID_M_TRACE, trace);
}

BOOL QueueMessage::GetTrace(BOOL * apTrace) const
{
	const UCHAR * trace = GetUCHARProperty(PROPID_M_TRACE);
	if (!trace)
		return FALSE;
	*apTrace = ((*trace) == MQMSG_SEND_ROUTE_TO_REPORT_QUEUE);
	return TRUE;
}


// read only properties
BOOL QueueMessage::GetArrivedTime(time_t * apTime) const
{
	const ULONG * arrived = GetULONGProperty(PROPID_M_ARRIVEDTIME);
	if (!arrived)
		return FALSE;
	*apTime = *arrived;
	return TRUE;
}


BOOL QueueMessage::GetSentTime(time_t * apTime) const
{
	const ULONG * sent = GetULONGProperty(PROPID_M_SENTTIME);
	if (!sent)
		return FALSE;
	*apTime = *sent;
	return TRUE;
}


/********************************************** MessageQueue ***/

MessageQueue::MessageQueue() : mHandle(NULL)
{
}

MessageQueue::MessageQueue(const MessageQueue & queue)
{
	mHandle = NULL;
	*this = queue;
}

MessageQueue & MessageQueue::operator = (const MessageQueue & queue)
{
	// only defined when the other queue has not been initialized
	ASSERT((QUEUEHANDLE) queue == NULL);
	ASSERT(mHandle == NULL);
	return *this;
}


MessageQueue::~MessageQueue()
{
	if (mHandle != NULL)
	{
		Close();
		mHandle = NULL;
	}
}


BOOL MessageQueue::InitJournal(const wchar_t * apQueueName, BOOL aPrivate,
															 const wchar_t * apMachineName /* = NULL */)
{
	return FormatName(apQueueName, apMachineName, aPrivate, TRUE);
}


BOOL MessageQueue::Init(const wchar_t * apQueueName, BOOL aPrivate,
												const wchar_t * apMachineName /* = NULL */)
{
	return FormatName(apQueueName, apMachineName, aPrivate, FALSE);
}


BOOL MessageQueue::FormatName(const wchar_t * apQueueName,
															const wchar_t * apMachineName,
															BOOL aPrivate, BOOL aJournal)
{
	ASSERT(apQueueName);
	wchar_t buffer[256];


	if (aPrivate && apMachineName)
	{
		// direct remote connection
		swprintf(buffer, L"DIRECT=OS:%s\\PRIVATE$\\%s%s",
						 apMachineName, apQueueName,
						 aJournal ? L";JOURNAL" : L"");
		mFormatString = buffer;
		return TRUE;
	}

	if (!apMachineName)
		apMachineName = L".";

	if (aPrivate)
		swprintf(buffer, L"%s\\private$\\%s", apMachineName, apQueueName);
	else
		swprintf(buffer, L"%s\\%s", apMachineName, apQueueName);

	// "public queues require at least 44 unicode characters.
	//  private queues require at least 54"
	WCHAR szFormatNameBuffer[128];
	DWORD dwFormatNameBufferLength = sizeof(szFormatNameBuffer) /
		sizeof(szFormatNameBuffer[0]);


	HRESULT hr = ::MQPathNameToFormatName(buffer, szFormatNameBuffer,
																				&dwFormatNameBufferLength);

	if (FAILED(hr))
	{
		mFormatString.resize(0);
		SetError(hr, ERROR_MODULE, ERROR_LINE, "MessageQueue::Init");
		return FALSE;
	}

	mFormatString = szFormatNameBuffer;
	if (aJournal)
		mFormatString += L";JOURNAL";
	return TRUE;
}



BOOL MessageQueue::Open(DWORD aAccess, DWORD aShareMode)
{
	HRESULT hr = ::MQOpenQueue(mFormatString.c_str(),
														 aAccess, aShareMode,
														 &mHandle);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, "MessageQueue::Open");
		return FALSE;
	}
	return TRUE;
}

BOOL MessageQueue::Close()
{
	HRESULT hr = ::MQCloseQueue(mHandle);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, "MessageQueue::Close");
		return FALSE;
	}

	// TODO: should this be done even if FAILED(hr)?
	mHandle = NULL;
	return TRUE;
}

BOOL MessageQueue::Delete()
{
	HRESULT hr = ::MQDeleteQueue(mFormatString.c_str());
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, "MessageQueue::Delete");
		return FALSE;
	}
	return TRUE;
}

BOOL MessageQueue::Send(QueueMessage & arMessage)
{
	MQMSGPROPS * props = arMessage.GetProps();
	ASSERT(props);

	ASSERT(mHandle);
	// last param for transactions only
	HRESULT hr = ::MQSendMessage(mHandle, props, NULL);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, "MessageQueue::Send");
		return FALSE;
	}
	return TRUE;
}

BOOL MessageQueue::Send(QueueMessage & arMessage, QueueTransaction & arTran)
{
	MQMSGPROPS * props = arMessage.GetProps();
	ASSERT(props);

	ASSERT(mHandle);
	// pass in transaction object
	HRESULT hr = ::MQSendMessage(mHandle, props, arTran);
	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, "MessageQueue::Send");
		return FALSE;
	}
	return TRUE;
}

// TODO: need to pass the Transaction object into more of these

// receive without a cursor
// returns FALSE if the operation times out
BOOL MessageQueue::Receive(QueueMessage & arMessage,
													 DWORD aTimeoutMillis /* = INFINITE */)
{
	return ReceiveInternal(arMessage, MQ_ACTION_RECEIVE, NULL, aTimeoutMillis);
}

// receive without a cursor, within a transaction
// returns FALSE if the operation times out
BOOL MessageQueue::Receive(QueueMessage & arMessage,
													 QueueTransaction & arTran,
													 DWORD aTimeoutMillis /* = INFINITE */)
{
	return ReceiveInternal(arMessage, MQ_ACTION_RECEIVE, NULL, aTimeoutMillis, NULL,
												 arTran);
}


// peek without a cursor
// returns FALSE if the operation times out
BOOL MessageQueue::Peek(QueueMessage & arMessage, DWORD aTimeoutMillis /* = INFINITE */)
{
	return ReceiveInternal(arMessage, MQ_ACTION_PEEK_CURRENT,
												 NULL,	// no cursor
												 aTimeoutMillis);
}

// receive with a cursor
// returns FALSE if the operation times out
BOOL MessageQueue::Receive(QueueMessage & arMessage, const QueueCursor & arCursor,
													 DWORD aTimeoutMillis /* = INFINITE */)
{
	return ReceiveInternal(arMessage, MQ_ACTION_RECEIVE, arCursor, aTimeoutMillis);
}

// receive with a cursor
// returns FALSE if the operation times out
BOOL MessageQueue::Receive(QueueMessage & arMessage, const QueueCursor & arCursor,
													 QueueTransaction & arTran,
													 DWORD aTimeoutMillis /* = INFINITE */)
{
	return ReceiveInternal(arMessage, MQ_ACTION_RECEIVE, arCursor,
												 aTimeoutMillis, NULL, arTran);
}

// peek with a cursor
// returns FALSE if the operation times out
BOOL MessageQueue::Peek(QueueMessage & arMessage, const QueueCursor & arCursor,
												BOOL aFirst, DWORD aTimeoutMillis /* = INFINITE */)
{
	return ReceiveInternal(arMessage,
												 aFirst ? MQ_ACTION_PEEK_CURRENT : MQ_ACTION_PEEK_NEXT,
												 arCursor, aTimeoutMillis);
}

// peek with a cursor, within a transaction
// returns FALSE if the operation times out
BOOL MessageQueue::Peek(QueueMessage & arMessage, const QueueCursor & arCursor,
												BOOL aFirst, QueueTransaction & arTran,
												DWORD aTimeoutMillis /* = INFINITE */)
{
	return ReceiveInternal(arMessage,
												 aFirst ? MQ_ACTION_PEEK_CURRENT : MQ_ACTION_PEEK_NEXT,
												 arCursor, aTimeoutMillis, NULL, arTran);
}


// asynchronous receive without a cursor
BOOL MessageQueue::Receive(QueueMessage & arMessage, AsyncContext & arContext,
													 DWORD aTimeoutMillis /* = INFINITE */)
{
	return ReceiveInternal(arMessage, MQ_ACTION_RECEIVE,
												 NULL, aTimeoutMillis, &arContext);
}

// asynchronous peek without a cursor
BOOL MessageQueue::Peek(QueueMessage & arMessage, AsyncContext & arContext,
												DWORD aTimeoutMillis /* = INFINITE */)
{
	return ReceiveInternal(arMessage, MQ_ACTION_PEEK_CURRENT,
												 NULL, aTimeoutMillis, &arContext);
}

// asynchronous receive with a cursor
BOOL MessageQueue::Receive(QueueMessage & arMessage, const QueueCursor & arCursor,
												AsyncContext & arContext, DWORD aTimeoutMillis /* = INFINITE */)
{
	return ReceiveInternal(arMessage, MQ_ACTION_RECEIVE,
												arCursor, aTimeoutMillis, &arContext);
}

// asynchronous peek with a cursor
BOOL MessageQueue::Peek(QueueMessage & arMessage, const QueueCursor & arCursor,
												AsyncContext & arContext, BOOL aFirst,
												DWORD aTimeoutMillis /* = INFINITE */)
{
	return ReceiveInternal(arMessage, aFirst ? MQ_ACTION_PEEK_CURRENT : MQ_ACTION_PEEK_NEXT,
												 arCursor, aTimeoutMillis, &arContext);
}



BOOL MessageQueue::ReceiveInternal(QueueMessage & arMessage, DWORD aAction,
																	 HANDLE aCursor,
																	 DWORD aTimeoutMillis,
																	 OVERLAPPED * apOverlapped /* = NULL */,
																	 ITransaction * apTran /* = NULL */)
{
	MQMSGPROPS * props = arMessage.GetProps();
	ASSERT(props);

	ASSERT(mHandle);

	// Receive the message
	HRESULT hr = ::MQReceiveMessage(
		mHandle,										// IN:     Queue handle
		aTimeoutMillis,							// IN:     Timeout
		aAction,										// IN:     Read operation
		props,											// IN/OUT: Message properties to receive
		apOverlapped,								// IN/OUT: Asynchronous overlap struct if desired
		NULL,												// IN:     No callback
		aCursor,										// IN:     cursor
		apTran);										// IN:     Not part of a transaction

	// if the operation timed out, don't store the error but return FALSE
	if (hr == MQ_ERROR_IO_TIMEOUT)
	{
		// in this case, getlasterror will return NULL
		ClearError();
		return FALSE;
	}

	// always store the result in asynchronous mode (even successes)
	if (FAILED(hr) || apOverlapped)
		SetError(hr, ERROR_MODULE, ERROR_LINE, "MessageQueue::Receive");

	if (FAILED(hr))
		return FALSE;

	return TRUE;
}

BOOL MessageQueue::GetQueueProperties(MessageQueueProps & arQueueProps)
{
	const char * functionName = "MessageQueue::GetQueueProperties";

	MQQUEUEPROPS * props = arQueueProps.GetProps();

	HRESULT hr = ::MQGetQueueProperties(
		mFormatString.c_str(),
		props);

	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}



BOOL MessageQueue::CreateQueue(const wchar_t * apQueueName, BOOL aPrivate,
															 MessageQueueProps & arQueueProps,
															 const wchar_t * apMachineName /* = NULL */)
{
	// Set the PROPID_Q_PATHNAME property.

	wchar_t buffer[256];

	if (!apMachineName)
		apMachineName = L".";

	if (aPrivate)
		swprintf(buffer, L"%s\\private$\\%s", apMachineName, apQueueName);
	else
		swprintf(buffer, L"%s\\%s", apMachineName, apQueueName);

	arQueueProps.SetPathname(buffer);

	SECURITY_DESCRIPTOR securityDescriptor;
	if (!InitializeSecurityDescriptor(&securityDescriptor, SECURITY_DESCRIPTOR_REVISION)
		|| !SetSecurityDescriptorDacl(&securityDescriptor, TRUE, (PACL)NULL, FALSE))
	{
		HRESULT err = HRESULT_FROM_WIN32(::GetLastError());
		SetError(err, ERROR_MODULE, ERROR_LINE, "MessageQueue::CreateQueue");
		return FALSE;
	}

	// "public queues require at least 44 unicode characters.
	//  private queues require at least 54"
	WCHAR szFormatNameBuffer[128];
  DWORD dwFormatNameBufferLength(sizeof(szFormatNameBuffer)/sizeof(WCHAR));

	MQQUEUEPROPS * props = arQueueProps.GetProps();

	HRESULT hr = ::MQCreateQueue(
		&securityDescriptor,				//Security
		props,											//Queue properties
		szFormatNameBuffer,					//Output: Format Name
		&dwFormatNameBufferLength);		//Output: Format Name len

	if (FAILED(hr))
	{
		mFormatString.resize(0);
		SetError(hr, ERROR_MODULE, ERROR_LINE, "MessageQueue::CreateQueue");
		return FALSE;
	}

	mFormatString = szFormatNameBuffer;
	return TRUE;
}

BOOL MessageQueue::DeleteQueue(const wchar_t* apQueueName,BOOL aPrivate, const wchar_t * apMachineName /* = NULL */)
{
wchar_t buffer[256];


	if (!apMachineName)
		apMachineName = L".";

	if (aPrivate)
		swprintf(buffer, L"%s\\private$\\%s", apMachineName, apQueueName);
	else
		swprintf(buffer, L"%s\\%s", apMachineName, apQueueName);

	wchar_t format_buffer[256];
	unsigned long alen = 256;
	
	HRESULT hr;
	do {
	hr = MQPathNameToFormatName(buffer,format_buffer,&alen);
	if(FAILED(hr)) break;
	hr = ::MQDeleteQueue(format_buffer);
	} while(false);


	if(FAILED(hr)) {
		mFormatString.resize(0);
		SetError(hr, ERROR_MODULE, ERROR_LINE, "MessageQueue::DeleteQueue");
		return FALSE;		
	}
	return TRUE;
}

/*********************************************** QueueCursor ***/

QueueCursor::QueueCursor() : mCursor(NULL)
{ }

QueueCursor::~QueueCursor()
{
	if (mCursor)
		Close();
}

BOOL QueueCursor::Init(MessageQueue & arQueue)
{
	HRESULT hr = ::MQCreateCursor(arQueue,
																&mCursor);

	if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, "MessageQueue::CreateQueue");
		return FALSE;
	}
	return TRUE;
}

void QueueCursor::Close()
{
	if (mCursor)
	{
		(void) ::MQCloseCursor(mCursor);
		mCursor = NULL;
	}
}

/****************************************** QueueTransaction ***/

QueueTransaction::QueueTransaction()
{
	mWeOwn = TRUE;
	HRESULT hr = ::MQBeginTransaction(&mpTransaction);
	if (FAILED(hr))
		SetError(hr, ERROR_MODULE, ERROR_LINE, "QueueTransaction::QueueTransaction");
	else
		ClearError();
}

QueueTransaction::QueueTransaction(ITransaction * apTxn)
{
	mWeOwn = FALSE;
	mpTransaction = apTxn;
	mpTransaction->AddRef();
	ClearError();
}


BOOL QueueTransaction::Commit()
{
	HRESULT hr = mpTransaction->Commit(0,0,0);
  if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, "QueueTransaction::Commit");
		return FALSE;
	}

	Clear();
	return TRUE;
}

BOOL QueueTransaction::Rollback()
{
	HRESULT hr = mpTransaction->Abort(0, 0, 0);
  if (FAILED(hr))
	{
		SetError(hr, ERROR_MODULE, ERROR_LINE, "QueueTransaction::Commit");
		return FALSE;
	}

	Clear();
	return TRUE;
}

void QueueTransaction::Clear()
{
	if (mpTransaction)
	{
		mpTransaction->Release();
		mpTransaction = NULL;
	}
}

QueueTransaction::~QueueTransaction()
{
	if (mWeOwn)
	{
		// it must be explicitly committed
		if (mpTransaction)
			(void) Rollback();
	}
	else
		// just release the reference to the transaction
		Clear();
}

/********************************************* AsynchContext ***/

AsyncContext::AsyncContext(HANDLE aEvent /* = NULL */)
{
	// internal is the error code - clear it initially
	Internal = -1;
	hEvent = aEvent;
}

AsyncContext::~AsyncContext()
{
#if 0
	if (hEvent)
	{
		::CloseHandle(hEvent);
		hEvent = NULL;
	}
#endif
}

void AsyncContext::SetEvent(HANDLE aEvent)
{
	hEvent = aEvent;
}

BOOL AsyncContext::Succeeded() const
{
	return (Internal == 0);
}

HRESULT AsyncContext::GetError() const
{
	return (HRESULT) Internal;
}
