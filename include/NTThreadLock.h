/**************************************************************************
 * @doc NTTHREADLOCK
 * 
 * @module NT Thread Lock encapsulation |
 * 
 * This is thread lock class. A simple encapsulation for critical sections.
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | NTTHREADLOCK
 ***************************************************************************/

#ifndef __NTTHREADLOCK_H
#define __NTTHREADLOCK_H

// include files ...
#include "ThreadLock.h"
#include "MTSL_DLL.h"

#if defined(_MT)
// @class NTThreadLock (inherited from ThreadLock)
class NTThreadLock : public ThreadLock
{
// @access Public:
public:
  // @cmember
	// Constructor (initialize the critical section)
  MTSL_DLL_EXPORT NTThreadLock() ;
  // @cmember
	// Destructor (delete the critical section)
	MTSL_DLL_EXPORT virtual ~NTThreadLock()	;

  // @cmember,mfunc This function will encapsulate the NT specific enter critical 
  //  section system call.
	//  @@rdesc
	//  No return value.
  //  @@devnote
  //  This is an inherited function. 
	//  @@xref <c NTThreadLock>
	MTSL_DLL_EXPORT virtual void Lock()	;	
  // @cmember,mfunc This function will encapsulate the NT specific leave critical 
  //  section system call.
	//  @@rdesc
	//  No return value.
  //  @@devnote
  //  This is an inherited function. 
	//  @@xref <c NTThreadLock>
	MTSL_DLL_EXPORT virtual void Unlock() ;	

// @access Private:
private:
	// copying not allowed (can't copy a critical section)
	NTThreadLock(NTThreadLock &)
	{ }

	NTThreadLock & operator = (NTThreadLock &)
	{ }

  // @cmember Critical section data member ...
	CRITICAL_SECTION	mCriticalSection;
};

inline NTThreadLock::NTThreadLock()
{ 
  InitializeCriticalSection (&mCriticalSection); 
}

inline NTThreadLock::~NTThreadLock()
{ 
  DeleteCriticalSection (&mCriticalSection); 
}

inline void NTThreadLock::Lock() 
{
  EnterCriticalSection (&mCriticalSection); 
}

inline void NTThreadLock::Unlock()
{ 
  LeaveCriticalSection (&mCriticalSection); 
}

#else // !defined(_MT)

// null implementation for non-threaded processes ...

class MTSL_DLL_EXPORT NTThreadLock : public ThreadLock
{
public:
  NTThreadLock() 		{}
	~NTThreadLock()	  {}

	void Lock()	    {ASSERT(false);}
	void Unlock() 	{ASSERT(false);}
};
#endif // (_MT)

#endif // __NTTHREADLOCK_H
