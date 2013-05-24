/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/
#ifndef _ODBCASYNCWRITER_H
#define _ODBCASYNCWRITER_H

#include <OdbcException.h>
#include "OdbcSessionRouter.h"

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF")


typedef MTautoptr<COdbcException> COdbcExceptionPtr;

//----------------------------------------------------------------------
class ArrayWriterRequest
{
private:
	int mWritten;
	COdbcSessionRouter* mTask;
	COdbcExceptionPtr mException;
public:
	ArrayWriterRequest()
		: mWritten(0),
			mException(NULL)
	{
	}

	int GetWritten() { return mWritten; }
	void SetWritten(int written) { mWritten = written; }

	COdbcSessionRouter* GetTask() { return mTask; }
	void SetTask(COdbcSessionRouter* task) { mTask = task; }

	COdbcExceptionPtr GetException() { return mException; }
	void SetException(const COdbcExceptionPtr& exception) { mException = exception; }
	void ClearException() { mException = NULL; }
};

//----------------------------------------------------------------------
class ArrayWriterQueue
{
private:
	ArrayWriterRequest* mRequest;
	HANDLE m_hEnqueueSemaphore;	//owned
	HANDLE m_hDequeueSemaphore;	//owned
	HANDLE m_hAbortEvent;				//passed in

	__int64 m_qwDequeueWaitTime;
	__int64 m_qwEnqueueWaitTime;
	__int64 m_qwTicksPerSec;


public:
	ArrayWriterQueue(HANDLE ahAbortEvent);
	~ArrayWriterQueue();

	ArrayWriterRequest* DequeueRequest();
	void EnqueueRequest(ArrayWriterRequest* request);
	void EndOfStream();

	double GetEnqueueWaitMillis() const { return (1000.0*m_qwEnqueueWaitTime)/m_qwTicksPerSec; }
	double GetDequeueWaitMillis() const { return (1000.0*m_qwDequeueWaitTime)/m_qwTicksPerSec; }

	static ArrayWriterRequest* EndOfStreamMarker;
};


//----------------------------------------------------------------------
class CAsyncColumnArrayWriter
{
private:
	ArrayWriterQueue* mReceiveQueue;
	ArrayWriterQueue* mCompletionQueue;

	HANDLE m_hExecuteThread;
	DWORD m_dwExecuteId;

	HANDLE m_hAbortEvent; //event signalled when aborting

	DWORD ExecuteBatches();
	static DWORD WINAPI ColumnArrayExecuteProc(LPVOID lpParameter);

	int mRequestsReceived;
	int mRequestsCompleted;
	MTPipelineLib::IMTLogPtr mLogger;

	CRITICAL_SECTION* mCriticalSection;

	// Wait for the thread to finish
	void Join(int timeout);

public:

	CAsyncColumnArrayWriter(MTPipelineLib::IMTLogPtr aLogger, CRITICAL_SECTION* aCriticalSection);
	~CAsyncColumnArrayWriter();

	void ExecuteBatch(ArrayWriterRequest* request);
	ArrayWriterRequest* GetCompletedRequest();
	
	// complete all queued requests and shut down
	void FinishProcessing();

	// shut down ASAP
	void Abort();

	// Is this thread currently alive and kicking?
	bool IsAlive();

	double GetEnqueueWaitMillis() const { return mReceiveQueue->GetEnqueueWaitMillis(); }
	double GetDequeueWaitMillis() const { return mCompletionQueue->GetDequeueWaitMillis(); }
};

//----------------------------------------------------------------------
// Bundles up the writer and the request for the special case
// when there is a 1-1 correspondence between them.
class COdbcAsyncWriterProxy
{
private:
	CAsyncColumnArrayWriter mAsyncWriter;
	ArrayWriterRequest mRequest;
	MTPipelineLib::IMTLogPtr mLogger;

public:
	COdbcAsyncWriterProxy(MTPipelineLib::IMTLogPtr aLogger, CRITICAL_SECTION* aCriticalSection, COdbcSessionRouter* aRouter);
	~COdbcAsyncWriterProxy();

	COdbcSessionRouter* GetRouter() 
	{ 
		return mRequest.GetTask(); 
	}
	
	void ExecuteBatch() 
	{
		mAsyncWriter.ExecuteBatch(&mRequest);
	}

	ArrayWriterRequest* GetCompletedRequest()
	{
		ArrayWriterRequest* pRequest = mAsyncWriter.GetCompletedRequest();
		ASSERT(pRequest == &mRequest);
		return pRequest;
	}

	__int64 WriteSession(MTPipelineLib::IMTSessionPtr aSession)
	{
		return GetRouter()->WriteSession(aSession);
	}
	
	__int64 WriteChildSession(__int64 aParentId,
															 MTPipelineLib::IMTSessionPtr aSession)
	{
		return GetRouter()->WriteChildSession(aParentId, aSession);
	}

	double GetEnqueueWaitMillis() const { return mAsyncWriter.GetEnqueueWaitMillis(); }
	double GetDequeueWaitMillis() const { return mAsyncWriter.GetDequeueWaitMillis(); }
};

#endif
