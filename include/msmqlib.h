/**************************************************************************
 * @doc MSMQLIB
 *
 * @module |
 *
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
 *
 * @index | MSMQLIB
 ***************************************************************************/

#ifndef _MSMQLIB_H
#define _MSMQLIB_H

// message queue library
#include <transact.h>
#include <MQ.H>

// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )

#include <vector>
#include <string>

#include <errobj.h>

using std::vector;

class MessageQueue;

/******************************************** MSMessageProps ***/

template <class S, class PID>
class QueueProps
{
public:
	QueueProps();
	virtual ~QueueProps();

	S * GetProps()
	{ return &mProps; }

public:
	void ClearProperties();

protected:
	int GetPropIndex(PID aPropId) const;

	const PROPVARIANT * GetPropVariant(PID aPropId, VARTYPE aType) const;
	PROPVARIANT * CreatePropVariant(PID aPropId, VARTYPE aType);

	const short * GetShortProperty(PID aPropId) const;
	void SetShortProperty(PID aPropId, short aShort);

	void SetUCHARProperty(PID aPropId, UCHAR aUChar);
	const UCHAR * GetUCHARProperty(PID aPropId) const;

	void SetLongProperty(PID aPropId, long aLong);
	const long * GetLongProperty(PID aPropId, long & arLong) const;

	void SetULONGProperty(PID aPropId, ULONG aULong);
	const ULONG * GetULONGProperty(PID aPropId) const;

	void SetWideStringProperty(PID aPropId, const wchar_t * apWStr);
	const wchar_t * GetWideStringProperty(PID aPropId) const;

	void SetBytesProperty(PID aPropId, const UCHAR * apBytes, int aLen);
	const UCHAR * GetBytesProperty(PID aPropId) const;

private:
	S mProps;

	typedef vector<PID> PIDVector;
	typedef vector<PROPVARIANT> PROPVARIANTVector;

	PIDVector mPropIDs;
	PROPVARIANTVector mPropVariants;
};

inline bool operator ==(const PROPVARIANT & arLeft, const PROPVARIANT & arRight)
{
	ASSERT(0);
	return &arLeft == &arRight;
}

/***************************** QueueProps implementation ***/

template <class S, class PID>
QueueProps<S, PID>::QueueProps()
{
	mProps.aPropID = NULL;
	mProps.aPropVar = NULL;
	mProps.aStatus = NULL;
}

template <class S, class PID>
QueueProps<S, PID>::~QueueProps()
{ }

template <class S, class PID>
int QueueProps<S, PID>::GetPropIndex(PID aPropId) const
{
	ASSERT(mPropIDs.size() == mPropVariants.size());

	for (int i = 0; i < (int) mPropIDs.size(); i++)
	{
		if (mPropIDs[i] == aPropId)
			return i;
	}

	return -1;
}


template <class S, class PID>
const PROPVARIANT *
QueueProps<S, PID>::GetPropVariant(PID aPropId, VARTYPE aType) const
{
	int index = GetPropIndex(aPropId);
	ASSERT(index != -1);
	if (index == -1)
		return NULL;

	const PROPVARIANT * val = &mPropVariants[index];
	ASSERT(val);

	if (val->vt != aType)
		return NULL;

	return val;
}

template <class S, class PID>
PROPVARIANT *
QueueProps<S, PID>::CreatePropVariant(PID aPropId, VARTYPE aType)
{
	int index = GetPropIndex(aPropId);
	PROPVARIANT * val;
	if (index == -1)
	{
		PROPVARIANT temp;
		mPropVariants.push_back(temp);
		mPropIDs.push_back(aPropId);
		val = &mPropVariants.back();
	}
	else
		val = &mPropVariants[index];
	ASSERT(val);

	val->vt = aType;


	ASSERT(mPropVariants.size() == mPropIDs.size());
	ASSERT(mPropVariants.size() > 0);
	mProps.cProp = mPropVariants.size();
	mProps.aPropID = &mPropIDs[0];
	mProps.aPropVar = &mPropVariants[0];

	// TODO: move this
	// for now, the status field is unused.
	mProps.aStatus = NULL;

	return val;
}



template <class S, class PID>
void QueueProps<S, PID>::SetShortProperty(PID aPropId, short aShort)
{
	PROPVARIANT * val = CreatePropVariant(aPropId, VT_I2);
	val->iVal = aShort;
}

template <class S, class PID>
const short * QueueProps<S, PID>::GetShortProperty(PID aPropId) const
{
	const PROPVARIANT *	val = GetPropVariant(aPropId, VT_I2);
	if (!val)
		return NULL;

	return &val->iVal;
}



template <class S, class PID>
void QueueProps<S, PID>::SetUCHARProperty(PID aPropId, UCHAR aUChar)
{
	// UCHAR             bVal;      // VT_UI1
	PROPVARIANT * val = CreatePropVariant(aPropId, VT_UI1);
	val->bVal = aUChar;
}

template <class S, class PID>
const UCHAR * QueueProps<S, PID>::GetUCHARProperty(PID aPropId) const
{
	// UCHAR             bVal;      // VT_UI1
	const PROPVARIANT *	val = GetPropVariant(aPropId, VT_UI1);
	if (!val)
		return NULL;

	return &val->bVal;
}



//	void SetProperty(PID aPropId, VARIANT_BOOL aBool);

template <class S, class PID>
void QueueProps<S, PID>::SetLongProperty(PID aPropId, long aLong)
{
	// long              lVal;      // VT_I4
	PROPVARIANT * val = CreatePropVariant(aPropId, VT_I4);
	val->lVal = aLong;
}


template <class S, class PID>
const long * QueueProps<S, PID>::GetLongProperty(PID aPropId, long & arLong) const
{
	// long              lVal;      // VT_I4
	const PROPVARIANT *	val = GetPropVariant(aPropId, VT_I4);
	if (!val)
		return NULL;

	return &val->lVal;
}


template <class S, class PID>
void QueueProps<S, PID>::SetULONGProperty(PID aPropId, ULONG aULong)
{
	// ULONG             ulVal;     // VT_UI4
	PROPVARIANT * val = CreatePropVariant(aPropId, VT_UI4);
	val->ulVal = aULong;
}


template <class S, class PID>
const ULONG * QueueProps<S, PID>::GetULONGProperty(PID aPropId) const
{
	// ULONG             ulVal;     // VT_UI4
	const PROPVARIANT *	val = GetPropVariant(aPropId, VT_UI4);
	if (!val)
		return NULL;

	return &val->ulVal;
}


//void SetProperty(PID aPropId, LPSTR apStr);

template <class S, class PID>
void QueueProps<S, PID>::SetWideStringProperty(PID aPropId, const wchar_t * apWStr)
{
	// LPWSTR            pwszVal;   // VT_LPWSTR
	PROPVARIANT * val = CreatePropVariant(aPropId, VT_LPWSTR);
	// NOTE: casting away const
	val->pwszVal = const_cast<wchar_t *>(apWStr);
}


template <class S, class PID>
const wchar_t *
QueueProps<S, PID>::GetWideStringProperty(PID aPropId) const
{
	// LPWSTR            pwszVal;   // VT_LPWSTR
	const PROPVARIANT *	val = GetPropVariant(aPropId, VT_LPWSTR);
	if (!val)
		return NULL;

	return val->pwszVal;
}

template <class S, class PID>
void QueueProps<S, PID>::SetBytesProperty(PID aPropId,
																							const UCHAR * apBytes, int aLen)
{
	// CAUI1             caub;      // VT_VECTOR | VT_UI1
	PROPVARIANT * val = CreatePropVariant(aPropId, VT_VECTOR | VT_UI1);

	// NOTE: casting away const
	val->caub.cElems = aLen;
	val->caub.pElems = const_cast<UCHAR *>(apBytes);
}

template <class S, class PID>
const UCHAR *
QueueProps<S, PID>::GetBytesProperty(PID aPropId) const
{
	// CAUI1             caub;      // VT_VECTOR | VT_UI1
	const PROPVARIANT *	val = GetPropVariant(aPropId, VT_VECTOR | VT_UI1);
	if (!val)
		return NULL;

	return val->caub.pElems;
}

template <class S, class PID>
void QueueProps<S, PID>::ClearProperties()
{
	mPropIDs.resize(0);
	mPropVariants.resize(0);

	mProps.cProp = 0;
	mProps.aPropID = NULL;
	mProps.aPropVar = NULL;
}

/************************************************* MsgQProps ***/

class MessageQueueProps : public QueueProps<MQQUEUEPROPS, QUEUEPROPID>
{
public:
	void SetPathname(const wchar_t * apPathname);
	const wchar_t * GetPathname() const;

	void SetBasePriority(short aBasePriority);
	const short * GetBasePriority() const;

	void SetJournal(BOOL aJournalOn);
	BOOL GetJournal(BOOL * apJournal) const;

	void SetJournalQuota(ULONG aQuota);
	const ULONG * GetJournalQuota() const;

	void SetLabel(const wchar_t * apLabel);
	const wchar_t * GetLabel() const;

	void SetQuota(ULONG aQuota);
	const ULONG * GetQuota() const;

	void SetTransactional(BOOL aIsTransactional);
	BOOL GetTransactional(BOOL * apIsTransactional) const;
};

/*********************************************** MsgQMessage ***/

class QueueMessage : public QueueProps<MQMSGPROPS, MSGPROPID>
{
public:
	void SetJournal(int aValue);
	const UCHAR * GetJournal() const;

	void SetAcknowledge(int aValue);
	const UCHAR * GetAcknowledge() const;

	void SetAdminQueue(const MessageQueue & arQueue);
	void SetAdminQueue(const wchar_t * apFormatName);
	const wchar_t * GetAdminQueue() const;


	void SetAppSpecificLong(long aValue);
	const ULONG * GetAppSpecificLong();

	void SetBody(const UCHAR * apBytes, int aLen);
	const UCHAR * GetBody() const;

	void SetBodySize(ULONG aLen);
	const ULONG * GetBodySize() const;

	void SetExtension(const UCHAR * apBytes, int aLen);
	void SetExtensionLen(ULONG aLen);
	const ULONG * GetExtensionLen() const;

	void SetExpressDelivery(BOOL aExpress);

	//void SetExtension();

	//void SetJournal();

	void SetLabel(const wchar_t * apLabel);
	const wchar_t * GetLabel() const;

	void SetLabelLen(ULONG aLen);
	const ULONG * GetLabelLen() const;

	void SetPriority(int aPriority);

	void SetTimeToBeReceived(ULONG aSeconds);
	const ULONG * GetTimeToBeReceived() const;

	void SetTimeToReachQueue(ULONG aSeconds);
	const ULONG * GetTimeToReachQueue() const;

	void SetTrace(BOOL aTraceOn);
	BOOL GetTrace(BOOL * apTrace) const;

	// read only properties
	BOOL GetArrivedTime(time_t * apArrivedTime) const;

	//void GetMessageId() const;

	//void GetSenderId();	void GetSenderIdType();

	BOOL GetSentTime(time_t * apSentTime) const;

	//void GetSourceMachineId();

	void SetResponseQueue(const MessageQueue & arQueue);
	void SetResponseQueue(const wchar_t * apFormatName);
	const wchar_t * GetResponseQueue() const;

	void SetResponseQueueLen(ULONG aLen);
	const ULONG * GetResponseQueueLen() const;
};

/*********************************************** QueueCursor ***/

class QueueCursor : public virtual ObjectWithError
{
public:
	QueueCursor();
	virtual ~QueueCursor();

	BOOL Init(MessageQueue & arQueue);
	void Close();

public:
	operator HANDLE() const
	{ return mCursor; }

private:
	// copying is not safe - disallowed
	QueueCursor(MessageQueue & arQueue);
	QueueCursor & operator = (QueueCursor & arQueue);

private:
	HANDLE mCursor;
};

/****************************************** QueueTransaction ***/

class QueueTransaction : public virtual ObjectWithError
{
public:
	QueueTransaction();
	QueueTransaction(ITransaction * apTxn);

	virtual ~QueueTransaction();

	BOOL Commit();
	BOOL Rollback();

	void Clear();

	operator ITransaction *()
	{ return mpTransaction; }

private:
	ITransaction * mpTransaction;
	BOOL mWeOwn;
};

/********************************************* AsynchContext ***/

class AsyncContext : private OVERLAPPED
{
public:
	AsyncContext(HANDLE aEvent = NULL);
	~AsyncContext();

	// set the event on which you will wait for asynchronous receives
	void SetEvent(HANDLE aEvent);

	// return the event on which you will wait for asynchronous receives
	HANDLE GetEvent() const
	{
		return hEvent;
	}

	// simplification of GetEvent
	operator HANDLE ()
	{ return GetEvent(); }

	// return TRUE if the message was successfully received
	BOOL Succeeded() const;

	// if there was an error, return it
	// TODO: avoid passing an HRESULT
	HRESULT GetError() const;

private:
	//friend MessageQueue
	OVERLAPPED * operator &()
	{ return this; }

	friend MessageQueue;
};

/********************************************** MessageQueue ***/

class MessageQueue : public virtual ObjectWithError
{
public:
	MessageQueue();
	MessageQueue(const MessageQueue & queue);

	virtual ~MessageQueue();

	MessageQueue & operator = (const MessageQueue & queue);

	BOOL Init(const wchar_t * apQueueName, BOOL aPrivate,
						const wchar_t * apMachineName = NULL);

	BOOL InitJournal(const wchar_t * apQueueName, BOOL aPrivate,
									 const wchar_t * apMachineName = NULL);

	BOOL CreateQueue(const wchar_t * apQueueName, BOOL aPrivate,
									 MessageQueueProps & arQueueProps,
									 const wchar_t * apMachineName = NULL);

	BOOL DeleteQueue(const wchar_t* apQueueName,BOOL aPrivate,const wchar_t * apMachineName = NULL);

	BOOL GetQueueProperties(MessageQueueProps & arQueueProps);

	/*
		MQ_PEEK_ACCESS
		Messages can only be looked at. They cannot be removed from the queue.

		MQ_SEND_ACCESS
		Messages can only be sent to the queue.

		MQ_RECEIVE_ACCESS
		Messages can be looked at and removed from of the queue.
		Whether a message is removed from the queue or looked at depends on
		the dwAction parameter of MQReceiveMessage. 


		MQ_DENY_NONE
		Default. The queue is available to everyone. This setting must be
		used if dwAccess is set to MQ_SEND_ACCESS.

		MQ_DENY_RECEIVE_SHARE
	*/

	BOOL Open(DWORD aAccess, DWORD aShareMode);
	BOOL Close();

	BOOL Delete();

	// NOTE: can't use the name SendMessage because windows.h already
	// #defines that to something else.

	BOOL Send(QueueMessage & arMessage);

	// send message as part of a larger transaction
	BOOL Send(QueueMessage & arMessage, QueueTransaction & arTran);

	// --- synchronous peak/receive without a cursor --
	// receive without a cursor
	// returns FALSE if the operation times out
	BOOL Receive(QueueMessage & arMessage, DWORD aTimeoutMillis = INFINITE);

	// receive without a cursor, within a transaction
	// returns FALSE if the operation times out
	BOOL Receive(QueueMessage & arMessage, QueueTransaction & arTran,
							 DWORD aTimeoutMillis = INFINITE);

	// peek without a cursor
	// returns FALSE if the operation times out
	BOOL Peek(QueueMessage & arMessage, DWORD aTimeoutMillis = INFINITE);

	// --- synchronous peak/receive with a cursor --
	// receive with a cursor
	// returns FALSE if the operation times out
	BOOL Receive(QueueMessage & arMessage, const QueueCursor & arCursor,
							 DWORD aTimeoutMillis = INFINITE);

	// receive with a cursor, within a transaction
	// returns FALSE if the operation times out
	BOOL Receive(QueueMessage & arMessage, const QueueCursor & arCursor,
							 QueueTransaction & arTran, DWORD aTimeoutMillis = INFINITE);

	// peek with a cursor
	// returns FALSE if the operation times out
	BOOL Peek(QueueMessage & arMessage, const QueueCursor & arCursor, BOOL aFirst,
						DWORD aTimeoutMillis = INFINITE);

	// peek with a cursor, within a transaction
	// returns FALSE if the operation times out
	BOOL Peek(QueueMessage & arMessage, const QueueCursor & arCursor, BOOL aFirst,
						QueueTransaction & arTran, DWORD aTimeoutMillis = INFINITE);

	// --- asynchronous peak/receive without a cursor --
	// receive asynchronously without a cursor
	BOOL Receive(QueueMessage & arMessage,
							 AsyncContext & arContext, DWORD aTimeoutMillis = INFINITE);

	// peek asynchronously without a cursor
	BOOL Peek(QueueMessage & arMessage,
						AsyncContext & arContext, DWORD aTimeoutMillis = INFINITE);

	// --- asynchronous peak/receive with a cursor --
	// receive asynchronously with a cursor
	BOOL Receive(QueueMessage & arMessage, const QueueCursor & arCursor,
							 AsyncContext & arContext, DWORD aTimeoutMillis = INFINITE);

	// peek asynchronously with a cursor
	BOOL Peek(QueueMessage & arMessage, const QueueCursor & arCursor,
						AsyncContext & arContext, BOOL aFirst,
						DWORD aTimeoutMillis = INFINITE);



	const std::wstring & GetFormatString() const
	{ return mFormatString; }

	operator QUEUEHANDLE() const
	{ return mHandle; }

private:

	BOOL FormatName(const wchar_t * apQueueName,
									const wchar_t * apMachineName,
									BOOL aPrivate, BOOL aJournal);

	// used by both all version of Peek and Receive
	BOOL ReceiveInternal(QueueMessage & arMessage, DWORD aAction,
											 HANDLE aCursor, DWORD aTimeoutMillis,
											 OVERLAPPED * apOverlapped = NULL,
											 ITransaction * apTran = NULL);

private:
	std::wstring mFormatString;
	QUEUEHANDLE mHandle;
};


/*

MSMQ uses three property structures: MQQUEUEPROPS for queue properties,
 MQMSGPROPS for message properties, and MQQMPROPS for Queue Manager properties.
 All three structures have the following four members:

  A count (cProp), indicating how many properties are supplied. This is a double word
        member field (DWORD) included in all three property structures.

  An array of PROPID values (aPropID) identifying which properties are specified for
        the call. MSMQ uses three different property identifiers:
           QUEUEPROPID, MSGPROPID, and QMPROPID.
        These identifiers are used for MSMQ queue properties,
        message properties, and Queue Manager properties, respectively.
        These identifiers are all of type PROPID.

	An array of PROPVARIANT structures (aPropVar) containing the values of the properties.
        Position i in this array is the value of the property whose identifier
        (PROPID value) is in position i in its respective aPropID array.

	An array of HRESULT values (aStatus) returned by MSMQ. Position i in this array is a
        reported status code of the property whose identifier and value are in position
        i in the arrays discussed earlier. This array is optional.

typedef struct  tagMQQUEUEPROPS
{
   DWORD               cProp;
   QUEUEPROPID     aPropID[];
   PROPVARIANT    aPropVar[];
   HRESULT         aStatus[];
} MQQUEUEPROPS;

*/

/*

struct    MQtagPROPVARIANT  {
    VARTYPE vt;                    // value tag
    WORD wReserved1;
    WORD wReserved2;
    WORD wReserved3;
    union   {
			UCHAR             bVal;      // VT_UI1
			short             iVal;      // VT_I2
			USHORT            uiVal;     // VT_UI2
			VARIANT_BOOL      bool;      // VT_BOOL
			long              lVal;      // VT_I4
			ULONG             ulVal;     // VT_UI4
			SCODE             scode;     //
			DATE              date;      // VT_DATE
			CLSID  _RPC_FAR  *puuid;     // VT_CLSID
			BLOB              blob;      // VT_BLOB
			LPOLESTR          bstrVal;   //
			LPSTR             pszVal;    // VT_LPSTR
			LPWSTR            pwszVal;   // VT_LPWSTR
			CAUI1             caub;      // VT_VECTOR | VT_UI1
			CAI2              cai;       // VT_VECTOR | VT_I2
			CAUI2             caus;      // VT_VECTOR | VT_UI2
			CABOOL            cabool;    // VT_VECTOR | VT_BOOL
			CAI4              cal;       // VT_VECTOR | VT_I4
			CAUI4             caul;      // VT_VECTOR | VT_UI4
			CACLSID           cauuid;    // VT_VECTOR | VT_CLSID
			CABSTR            cabstr;    // VT_VECTOR | VT_BSTR
			CALPWSTR          calpwstr;  // VT_VECTOR | VT_LPWSTR
			CAPROPVARIANT   capropvar;   //
   };                      
};

typedef struct MQtagPROPVARIANT PROPVARIANT;

 */


#endif /* _MSMQLIB_H */
