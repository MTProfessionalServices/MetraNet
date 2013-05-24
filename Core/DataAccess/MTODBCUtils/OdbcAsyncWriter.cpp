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

#include <metra.h>
#include <propids.h>
#include <mtprogids.h>
#include <ProductViewCollection.h>
#include <MSIXDefinition.h>
#include <autoptr.h>

#include "OdbcAsyncWriter.h"
#include "OdbcSessionRouter.h"

#include "OdbcConnection.h"
#include "OdbcStatementGenerator.h"
#include "OdbcPreparedArrayStatement.h"
#include "OdbcException.h"
#include "OdbcMetadata.h"
#include "OdbcStatement.h"
#include "OdbcResultSet.h"
#include "OdbcIdGenerator.h"



//----------------------------------------------------------------------
ArrayWriterRequest* ArrayWriterQueue::EndOfStreamMarker = (ArrayWriterRequest*)0xffffffff;

ArrayWriterQueue::ArrayWriterQueue(HANDLE ahAbortEvent) :
	m_hAbortEvent(ahAbortEvent)
{
	mRequest = NULL;

	// Create the queue in an empty state - enqueue semaphore empty and dequeue semaphore full
	m_hEnqueueSemaphore = ::CreateSemaphore( 
    NULL,   // no security attributes
    1,   // initial count
    1,   // maximum count
    NULL);  // unnamed semaphore
	ASSERT(m_hEnqueueSemaphore != NULL);

	m_hDequeueSemaphore = ::CreateSemaphore( 
    NULL,   // no security attributes
    0,   // initial count
    1,   // maximum count
    NULL);  // unnamed semaphore
	ASSERT(m_hDequeueSemaphore != NULL);

	LARGE_INTEGER freq;
	::QueryPerformanceFrequency(&freq);
	m_qwTicksPerSec = freq.QuadPart;
	m_qwDequeueWaitTime = 0;
	m_qwEnqueueWaitTime = 0;
}

ArrayWriterQueue::~ArrayWriterQueue()
{
	::CloseHandle(m_hEnqueueSemaphore);
	::CloseHandle(m_hDequeueSemaphore);
}

ArrayWriterRequest* ArrayWriterQueue::DequeueRequest()
{
	// Wait until there is a request here, or abort signalled
	DWORD dwWaitResult;
	LARGE_INTEGER tick,tock;
	HANDLE waitObjects[] = {m_hDequeueSemaphore, m_hAbortEvent};

	::QueryPerformanceCounter(&tick);
	dwWaitResult = ::WaitForMultipleObjects(2, waitObjects, FALSE, INFINITE);
	::QueryPerformanceCounter(&tock);
	m_qwDequeueWaitTime += (tock.QuadPart -tick.QuadPart);
	
	// if abort signalled return NULL
	if(dwWaitResult == WAIT_OBJECT_0 + 1)
		return NULL;

	ASSERT(dwWaitResult == WAIT_OBJECT_0);
	ArrayWriterRequest * tmp = mRequest;
	mRequest = NULL;
	// Now it is ok for someone to enqueue
	BOOL bResult;
	bResult = ::ReleaseSemaphore(m_hEnqueueSemaphore, 1, NULL);
	ASSERT(bResult);
	return tmp;
}

void ArrayWriterQueue::EnqueueRequest(ArrayWriterRequest* request)
{
	// Wait until the current request is gone
	DWORD dwWaitResult;
	LARGE_INTEGER tick,tock;
	HANDLE waitObjects[] = {m_hEnqueueSemaphore, m_hAbortEvent};

	::QueryPerformanceCounter(&tick);
	dwWaitResult = ::WaitForMultipleObjects(2, waitObjects, FALSE, INFINITE);
	::QueryPerformanceCounter(&tock);
	m_qwEnqueueWaitTime += (tock.QuadPart -tick.QuadPart);

	// if abort signalled: return
	if(dwWaitResult == WAIT_OBJECT_0 + 1)
		return;

	ASSERT(dwWaitResult == WAIT_OBJECT_0);
	ASSERT(mRequest == NULL);
	mRequest = request;
	// Now it is ok for someone to dequeue
	BOOL bResult;
	bResult = ::ReleaseSemaphore(m_hDequeueSemaphore, 1, NULL);
	ASSERT(bResult);
}

void ArrayWriterQueue::EndOfStream()
{
	// Just place a reserved token on the queue
	EnqueueRequest(EndOfStreamMarker);
}

//----------------------------------------------------------------------
CAsyncColumnArrayWriter::CAsyncColumnArrayWriter(MTPipelineLib::IMTLogPtr aLogger, CRITICAL_SECTION* aCriticalSection)
	:
	mLogger(aLogger),
	mCriticalSection(aCriticalSection)
{
	m_hAbortEvent = ::CreateEvent(
		NULL,					// no security attributes
		TRUE,					// ManualReset (actually will never been reset, once signalled)
		FALSE,				// initially not-signalled
		NULL);				// unnamed
	ASSERT(m_hAbortEvent != NULL);

	mReceiveQueue = new ArrayWriterQueue(m_hAbortEvent);
	mCompletionQueue = new ArrayWriterQueue(m_hAbortEvent);

	mRequestsReceived = 0;
	mRequestsCompleted = 0;

	m_hExecuteThread = ::CreateThread( 
		NULL,                        // no security attributes 
		0,                           // use default stack size  
		ColumnArrayExecuteProc,       // thread function 
		this,                        // argument to thread function 
		0,                           // use default creation flags 
		&m_dwExecuteId);              // returns the thread identifier 
}

CAsyncColumnArrayWriter::~CAsyncColumnArrayWriter()
{
	delete mReceiveQueue;
	delete mCompletionQueue;

	::CloseHandle(m_hExecuteThread);
	::CloseHandle(m_hAbortEvent);
}


DWORD WINAPI CAsyncColumnArrayWriter::ColumnArrayExecuteProc(LPVOID lpParameter)
{
	try {
		return ((CAsyncColumnArrayWriter*)lpParameter)->ExecuteBatches();
	} catch(COdbcException& odbcException) {
		((CAsyncColumnArrayWriter*)lpParameter)->mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(odbcException.toString().c_str()));
		return -1;
	} catch(std::exception& stlException) {
		((CAsyncColumnArrayWriter*)lpParameter)->mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(stlException.what()));
		return -2;
	} catch(_com_error& comerror) {
		((CAsyncColumnArrayWriter*)lpParameter)->mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, comerror.Description());
		return -3;
	}
}

DWORD CAsyncColumnArrayWriter::ExecuteBatches()
{
	while(1)
	{
		ArrayWriterRequest* pRequest = mReceiveQueue->DequeueRequest();

		//DequeueRequest returns NULL when aborting
		if(pRequest == NULL)
		{	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"CAsyncColumnArrayWriter is aborting");
			return 0;
		}

		if(ArrayWriterQueue::EndOfStreamMarker==pRequest) 
		{
			mCompletionQueue->EnqueueRequest(pRequest);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"CAsyncColumnArrayWriter is shutting down (received EOS)");
			return 0;
		}
		else
		{
			// The ODBC driver for SQL only supports a single active statement per connection
			// so we must wrap this in a critical section.  Unfortunately this really eliminates
			// the potential for anything but double buffering in the writer.  It looks like we
			// have to use OLE-DB to get around this problem (though I'm not sure even the OLEDB 
			// won't have this limitation.
			::EnterCriticalSection(mCriticalSection); 
			try {
				pRequest->ClearException();
				int numRows = pRequest->GetTask()->ExecuteBatch();
				pRequest->SetWritten(numRows);
			} catch (COdbcException& ex) {
				pRequest->SetException(COdbcExceptionPtr(new COdbcException(ex)));
			} catch(_com_error& comerror) {
				pRequest->SetException(COdbcExceptionPtr(new COdbcComException(comerror)));
			}
#ifndef _DEBUG
			catch(...) {
				pRequest->SetException(COdbcExceptionPtr(new COdbcException("unknown exception occurred")));
			}
#endif

			::LeaveCriticalSection(mCriticalSection);

			mCompletionQueue->EnqueueRequest(pRequest);
			mRequestsCompleted += 1;
		}
	}
	return -1;
}

void CAsyncColumnArrayWriter::ExecuteBatch(ArrayWriterRequest* request)
{
	mReceiveQueue->EnqueueRequest(request);
	mRequestsReceived += 1;
}

//can return NULL (when aborting)
ArrayWriterRequest* CAsyncColumnArrayWriter::GetCompletedRequest()
{
	return mCompletionQueue->DequeueRequest();
}

// complete all queued requests and shut down
void CAsyncColumnArrayWriter::FinishProcessing()
{
	mReceiveQueue->EndOfStream();
}

// shut down ASAP
void CAsyncColumnArrayWriter::Abort()
{
	//set event
	SetEvent(m_hAbortEvent);

	//wait for thread to finish
	Join(0);
}


void CAsyncColumnArrayWriter::Join(int timeout)
{
	ASSERT(timeout >= 0);
	DWORD dwReturn = ::WaitForSingleObject(m_hExecuteThread, (DWORD) timeout == 0 ? INFINITE : timeout);
}

bool CAsyncColumnArrayWriter::IsAlive()
{
	DWORD dwReturn = ::WaitForSingleObject(m_hExecuteThread, 0);
	return WAIT_OBJECT_0 != dwReturn;
}


//----------------------------------------------------------------------
// COdbcAsyncWriterProxy 

COdbcAsyncWriterProxy::COdbcAsyncWriterProxy(MTPipelineLib::IMTLogPtr aLogger, CRITICAL_SECTION* aCriticalSection, COdbcSessionRouter* aRouter)
	: mAsyncWriter(aLogger, aCriticalSection),
		mLogger(aLogger)
{
	mRequest.SetTask(aRouter);
}

COdbcAsyncWriterProxy::~COdbcAsyncWriterProxy()
{
	mAsyncWriter.Abort();
	delete mRequest.GetTask();
	mRequest.SetTask(NULL);
}


