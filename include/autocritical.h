/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
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
 * Created by: Carl Shimer
 * $Header$
 *
 *	This is a little utility class to make sure that your critical
 *	sections get automatically unlocked.  
 *
 *	The following 
 *
 *	{
 *	AutoCritical aCritical(&m_CriticalSection);
 *
 *	// protected code
 *	} 
 *
 *
 *	is essentially the same as (or should be the same as after massaged
 *	by an optimizing compiler)
 *
 *  { 
 *		EnterCriticalSection(&m_CriticalSection);
 *		// protected code
 *		LeaveCriticalSection(&m_CriticalSection);
 *  }
 *
 *  Note that when aCritical goes out of scope the critical section
 *  will be unlocked.
 * 
 *
 ***************************************************************************/
#ifndef __AUTOCRITICAL_H_
#define __AUTOCRITICAL_H_

#include <NTThreadLock.h>

class AutoCriticalSection {
public:
	AutoCriticalSection(NTThreadLock* pCritical) :
	  m_pCritical(pCritical) 
	{ m_pCritical->Lock();  }
	~AutoCriticalSection()
	{ m_pCritical->Unlock(); }
protected:
	NTThreadLock* m_pCritical;
};

// A templatized version of the above (we also use this with mutexes).
template<class T> class MT_Guard
{
protected:
  T * mMutex;
public:
  MT_Guard(T * mutex) : mMutex(mutex)
  {
    ASSERT(mMutex != NULL);
    mMutex->Lock();
  }
  
  ~MT_Guard()
  {
    mMutex->Unlock();
  }
};

#endif
