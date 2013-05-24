#ifndef __ASYNCQUEUE_H__
#define __ASYNCQUEUE_H__

// Lightweight queue of finite depth 1.
// Implementation is based on semaphore for synchronization.  When used
// in process, this could probably be based on a critical section for better
// performance.
// Attempts to enqueue a request when the queue is full will block forever.
// Attempts to dequeue a request when the queue is empty will block forever.
// BEWARE DEADLOCKS :-)
//
// The class T represents the message type that the queue manages
#include <vector>

template<class T> class CAsyncQueue
{
private:
	T* mRequest;
	HANDLE m_hEnqueueSemaphore;
	HANDLE m_hDequeueSemaphore;

	__int64 m_qwDequeueWaitTime;
	__int64 m_qwEnqueueWaitTime;
	__int64 m_qwTicksPerSec;


public:
	CAsyncQueue();
	~CAsyncQueue();

	T* DequeueRequest();
	void EnqueueRequest(T* request);
	void EndOfStream();

	double GetEnqueueWaitMillis() const { return (1000.0*m_qwEnqueueWaitTime)/m_qwTicksPerSec; }
	double GetDequeueWaitMillis() const { return (1000.0*m_qwDequeueWaitTime)/m_qwTicksPerSec; }

	static T* EndOfStreamMarker;
  // Wait for one of the queues to empty for enqueue.
  // Treat queues as a circular buffer starting at queues[offset].  This
  // allows one to achieve a type of round robin balancing.
  static unsigned int EnqueueRequest(const std::vector<CAsyncQueue<T> *>& queues, unsigned int offset, T* request);
};

template<class T> T* CAsyncQueue<T>::EndOfStreamMarker = (T*)0xffffffff;

template<class T> CAsyncQueue<T>::CAsyncQueue()
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

template<class T> CAsyncQueue<T>::~CAsyncQueue()
{
	::CloseHandle(m_hEnqueueSemaphore);
	::CloseHandle(m_hDequeueSemaphore);
}

template<class T> T* CAsyncQueue<T>::DequeueRequest()
{
	// Wait until there is a request here
	DWORD dwWaitResult;
	LARGE_INTEGER tick,tock;
	::QueryPerformanceCounter(&tick);
	dwWaitResult = ::WaitForSingleObject(m_hDequeueSemaphore, INFINITE);
	::QueryPerformanceCounter(&tock);
	m_qwDequeueWaitTime += (tock.QuadPart -tick.QuadPart);
	ASSERT(dwWaitResult == WAIT_OBJECT_0);
	T * tmp = mRequest;
	mRequest = NULL;
	// Now it is ok for someone to enqueue
	BOOL bResult;
	bResult = ::ReleaseSemaphore(m_hEnqueueSemaphore, 1, NULL);
	ASSERT(bResult);
	return tmp;
}

template<class T> void CAsyncQueue<T>::EnqueueRequest(T* request)
{
	// Wait until the current request is gone
	DWORD dwWaitResult;
	LARGE_INTEGER tick,tock;
	::QueryPerformanceCounter(&tick);
	dwWaitResult = ::WaitForSingleObject(m_hEnqueueSemaphore, INFINITE);
	::QueryPerformanceCounter(&tock);
	m_qwEnqueueWaitTime += (tock.QuadPart -tick.QuadPart);
	ASSERT(dwWaitResult == WAIT_OBJECT_0);
	ASSERT(mRequest == NULL);
	mRequest = request;
	// Now it is ok for someone to dequeue
	BOOL bResult;
	bResult = ::ReleaseSemaphore(m_hDequeueSemaphore, 1, NULL);
	ASSERT(bResult);
}

template<class T> void CAsyncQueue<T>::EndOfStream()
{
	// Just place a reserved token on the queue
	EnqueueRequest(EndOfStreamMarker);
}

template<class T> unsigned int CAsyncQueue<T>::EnqueueRequest(const std::vector<CAsyncQueue<T> *>& queues, unsigned int offset, T* request)
{
	DWORD dwWaitResult;
  HANDLE handles[MAXIMUM_WAIT_OBJECTS];
  unsigned int j=0;
  for(unsigned int i=offset; i<queues.size(); i++, j++)
  {
    handles[j] = queues[i]->m_hEnqueueSemaphore;
  }
  for(unsigned int i=0; i<offset; i++, j++)
  {
    handles[j] = queues[i]->m_hEnqueueSemaphore;
  }
  
	dwWaitResult = ::WaitForMultipleObjects(queues.size(), &handles[0], FALSE, INFINITE);
  unsigned int idx=0;
  if (dwWaitResult >= WAIT_OBJECT_0 && dwWaitResult < WAIT_OBJECT_0 + queues.size() - offset)
    idx = dwWaitResult + offset - WAIT_OBJECT_0;
  else if (dwWaitResult >= WAIT_OBJECT_0 + queues.size() - offset && dwWaitResult < WAIT_OBJECT_0 + queues.size())
    idx = dwWaitResult + offset - WAIT_OBJECT_0 - queues.size();
  else
    return -1;

	ASSERT(queues[idx]->mRequest == NULL);
  queues[idx]->mRequest = request;
	BOOL bResult;
	bResult = ::ReleaseSemaphore(queues[idx]->m_hDequeueSemaphore, 1, NULL);
	ASSERT(bResult);
  return idx;
}
#endif
