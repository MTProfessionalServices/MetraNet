#ifndef _MUTEX_H_
#define _MUTEX_H_

#include <windows.h>

class ThreadMutex
{
private:
	CRITICAL_SECTION mCriticalSection;
	
public:
	ThreadMutex()
	{
		::InitializeCriticalSection(&mCriticalSection);
	}

	~ThreadMutex()
	{
		::DeleteCriticalSection(&mCriticalSection);
	}

	void Acquire()
	{
		::EnterCriticalSection(&mCriticalSection);
	}

	void Release()
	{
		::LeaveCriticalSection(&mCriticalSection); 
	}
};

class ThreadGuard
{
private:
	ThreadMutex& mMutex;
public:
	ThreadGuard(ThreadMutex& mutex) : mMutex(mutex)
	{
		mMutex.Acquire();
	}

	~ThreadGuard()
	{
		mMutex.Release();
	}
};

#endif
