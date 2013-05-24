/**************************************************************************
 * @doc 
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
 * Created by: Raju Matta
 * $Header$
 *
 * @index | 
 ***************************************************************************/

#ifndef _MTSINGLETON_H_
#define _MTSINGLETON_H_

// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )

#include "NTThreadLock.h"
#include "MTUtil.h"
#include "autocritical.h"
// class definition
template <class T>
class MTSingleton
{
	public:
	
		DLL_EXPORT MTSingleton();
		DLL_EXPORT virtual ~MTSingleton();
	
		DLL_EXPORT static void ReleaseInstance();
		DLL_EXPORT static T* GetInstance();

		DLL_EXPORT DWORD GetRefCount() { return msNumRefs; }

	protected:
		static NTThreadLock mLock;

	private:
		static T* mpsInstance;
		static DWORD msNumRefs;
};

template <class T> DWORD MTSingleton<T>::msNumRefs = 0;
template <class T> T* MTSingleton<T>::mpsInstance = 0;
template <class T> NTThreadLock MTSingleton<T>::mLock;

/***************************** MTSingleton implementation ***/

template <class T>
MTSingleton<T>::MTSingleton()
{
}

template <class T>
MTSingleton<T>::~MTSingleton()
{
}

template <class T>
T* MTSingleton<T>::GetInstance()
{
    // local variables

	// enter the critical section
	mLock.Lock();

	// if the object does not exist..., create a new one
	if (mpsInstance == 0)
	{
	    mpsInstance = new T;
		if (!mpsInstance->Init())
		{
		  delete mpsInstance;
		  mpsInstance = 0;
		  return NULL;
		}
	}

	// if we got a valid pointer.. increment...
	if (mpsInstance != 0)
	{
	    msNumRefs++;
	}

	// leave the critical section...
	mLock.Unlock();

	return (mpsInstance);
}

template <class T>
void MTSingleton<T>::ReleaseInstance()
{
	// enter the critical section ...
	mLock.Lock();

	// decrement the reference counter
	if (mpsInstance != 0)
	{
		msNumRefs--;
		// assert here for 0 msNumRefs
	}

	// if the number of references is 0, delete the pointer
	if (msNumRefs == 0)
	{
		delete mpsInstance;
		mpsInstance = 0;
	}

	// leave the critical section ...
	mLock.Unlock();
}


#endif // _MTSINGLETON_H_

