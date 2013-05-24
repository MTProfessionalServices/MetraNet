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

#ifndef _ASYNCHTASK_H_
#define _ASYNCHTASK_H_

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF")

#include <AsyncQueue.h>

// An asynchronously executing task.
// The class T represents the request type of the task
template <class T> class CAsyncTask
{
private:
	CAsyncQueue<T>* mReceiveQueue;
	CAsyncQueue<T>* mCompletionQueue;

	HANDLE m_hExecuteThread;
	DWORD m_dwExecuteId;

	// Pull requests from the receive queue, process and then place request in
	// the completion queue.  Return when the receive queue has EndofStream.
	DWORD ExecuteTasks();
	// This guy calls ExecuteTasks on lpParameter
	// Requires:
	//    lpParamter is an instance of CAsyncTask<T>*
	static DWORD WINAPI ExecuteProc(LPVOID lpParameter);

	int mRequestsReceived;
	int mRequestsCompleted;
	MTPipelineLib::IMTLogPtr mLogger;

protected:
	// Override this method to do work
	virtual void ProcessRequest(T* aRequest)=0;

public:

	CAsyncTask(MTPipelineLib::IMTLogPtr aLogger);
	~CAsyncTask();

	virtual void StartProcessing();

	// Submit a request for processing.  This will block if the task is already busy.
	void SubmitTask(T* request);
	// Get the status of a completed request.  This will block if there are no completed requests.
	T* GetCompletedRequest();
	// Tell the task object that there are no more requests that will be submitted.
	// It will release resources in response to this call.
	virtual void FinishProcessing();

	// Wait for the thread to finish
	void Join(int timeout);

	// Is this thread currently alive and kicking?
	bool IsAlive();

	double GetEnqueueWaitMillis() const { return mReceiveQueue->GetEnqueueWaitMillis(); }
	double GetDequeueWaitMillis() const { return mCompletionQueue->GetDequeueWaitMillis(); }
};

template<class T> CAsyncTask<T>::CAsyncTask(MTPipelineLib::IMTLogPtr aLogger)
	:
	mLogger(aLogger),
	mReceiveQueue(NULL),
	mCompletionQueue(NULL),
	mRequestsReceived(0),
	mRequestsCompleted(0),
	m_hExecuteThread(NULL),
	m_dwExecuteId(0)
{
	mReceiveQueue = new CAsyncQueue<T>();
	mCompletionQueue = new CAsyncQueue<T>();

}

template<class T> CAsyncTask<T>::~CAsyncTask()
{
	if (IsAlive())
	{
		Join(0);
	}

	delete mReceiveQueue;
	delete mCompletionQueue;

	if(m_hExecuteThread != NULL) ::CloseHandle(m_hExecuteThread);
}

template<class T> void CAsyncTask<T>::StartProcessing()
{
	m_hExecuteThread = ::CreateThread( 
		NULL,                        // no security attributes 
		0,                           // use default stack size  
		ExecuteProc,                 // thread function 
		this,                        // argument to thread function 
		0,                           // use default creation flags 
		&m_dwExecuteId);              // returns the thread identifier 

	if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
	{
		wchar_t buffer[1024];
		swprintf(buffer, L"Started AsyncTask thread.  Thread Handle = %d; Thread Id = %d", 
						 m_hExecuteThread, 
						 m_dwExecuteId);
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
	}
}

template<class T> DWORD WINAPI CAsyncTask<T>::ExecuteProc(LPVOID lpParameter)
{
	try {
		return ((CAsyncTask<T>*)lpParameter)->ExecuteTasks();
	} catch(COdbcException& odbcException) {
		((CAsyncTask<T>*)lpParameter)->mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(odbcException.toString().c_str()));
		return -1;
	} catch(std::exception& stlException) {
		((CAsyncTask<T>*)lpParameter)->mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,_bstr_t(stlException.what()));
		return -2;
	} catch(_com_error& comerror) {
		((CAsyncTask<T>*)lpParameter)->mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, comerror.Description());
		return -3;
	}
}

template<class T> DWORD CAsyncTask<T>::ExecuteTasks()
{
	while(1)
	{
		if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"CAsyncTask<T> dequeuing request");
		}
		T* pRequest = mReceiveQueue->DequeueRequest();

		if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"CAsyncTask<T> successfully dequeued request");
		}

		if(CAsyncQueue<T>::EndOfStreamMarker==pRequest) 
		{
			if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
			{
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"CAsyncTask<T> enqueuing EndOfStream to completion queue");
			}

			mCompletionQueue->EnqueueRequest(pRequest);
			if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
			{
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"CAsyncTask<T> successfully enqueued EndOfStream to completion queue.  Exiting Thread with exit code 0");
			}
			return 0;
		}
		else
		{
			if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
			{
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"CAsyncTask<T> processing request");
			}

			ProcessRequest(pRequest);

			if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
			{
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"CAsyncTask<T> enqueuing task result to completion queue");
			}
			mCompletionQueue->EnqueueRequest(pRequest);
			if (mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG))
			{
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"CAsyncTask<T> successfully enqueued task result to completion queue.");
			}
			mRequestsCompleted += 1;
		}
	}
	return -1;
}

template<class T> void CAsyncTask<T>::SubmitTask(T* request)
{
	mReceiveQueue->EnqueueRequest(request);
	mRequestsReceived += 1;
}

template<class T> T* CAsyncTask<T>::GetCompletedRequest()
{
	return mCompletionQueue->DequeueRequest();
}

template<class T> void CAsyncTask<T>::FinishProcessing()
{
	mReceiveQueue->EndOfStream();
}

template<class T> void CAsyncTask<T>::Join(int timeout)
{
	if (m_hExecuteThread == NULL) return;
	ASSERT(timeout >= 0);
	DWORD dwReturn = ::WaitForSingleObject(m_hExecuteThread, (DWORD) timeout == 0 ? INFINITE : timeout);
}

template<class T> bool CAsyncTask<T>::IsAlive()
{
	if (NULL == m_hExecuteThread) return false;
	DWORD dwReturn = ::WaitForSingleObject(m_hExecuteThread, 0);
	return WAIT_OBJECT_0 != dwReturn;
}

#endif
