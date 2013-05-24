/**************************************************************************
 * @doc NTTHREADER
 * 
 * @module Thread encapsulation |
 * 
 * This is thread class. A simple encapsulation for threads.
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
 * @index | NTTHREADER
 ***************************************************************************/

#ifndef __NTTHREADER_H
#define __NTTHREADER_H

// include files ...
#include <process.h>
#include "Threader.h"
#include "MTSL_DLL.h"

// @class NTThreader (inherited from Threader)
class MTSL_DLL_EXPORT NTThreader : public Threader
{
// @access Public:
public:
  // @cmember
	// Constructor
	NTThreader ();
  // @cmember
	// Destructor
	virtual ~NTThreader();

  // @cmember Start the thread.
	//  @@xref <c Threader>
	virtual BOOL StartThread() ;
  // @cmember Stop the thread.
	//  @@xref <c Threader>
	virtual BOOL StopThread     (const DWORD timeout);
  // @cmember Wait for the thread.
	//  @@xref <c NTThreader>
	virtual BOOL WaitForThread	(const DWORD timeout);
  // @cmember Check to see if the threader class is initialized.
	//  @@xref <c Threader>
	virtual BOOL IsInitialized  (const DWORD timeout) const ;
  // @cmember Check to see if the thread is running.
	//  @@xref <c Threader>
	virtual BOOL IsRunning() ;
  // @cmember Check to see if a stop was requested.
	//  @@xref <c Threader>
	virtual BOOL StopRequested  (const DWORD timeout_ms = 0) const ;
  // @cmember Lock the thread lock.
	//  @@xref <c Threader>
  virtual void ThreadLock()	  const;
  // @cmember Unlock the thread lock.
	//  @@xref <c Threader>
	virtual void ThreadUnlock() const;
  // @cmember Get the thread return code.
	//  @@xref <c Threader>
  virtual DWORD	ThreadReturnCode() const ;
  // @cmember This pure virtual function is implemented by the object that inherits 
  //  this class. This function implements the logic for the thread.
	//  @@xref <c Threader>
	virtual int ThreadMain() = 0;	// object that inherits this class implements this method ...

  // @cmember Get the thread handle.
  HANDLE ThreadHandle() const ;
  // @cmember Get the thread address.
	unsigned int ThreadAddress() const ;	
  // @cmember Get the stop event handle.
	HANDLE StopEventHandle() const ; 	
// @access Protected:
protected:
  // @cmember Set the initialization event.
	//  @@xref <c Threader>
	virtual void	SetInitialized() ;
// @access Private:
private:
  // @cmember the thread return code
	DWORD                     mRetCode ;
  // @cmember the thread handle
	HANDLE          					mThreadHandle ;
  // @cmember the thread address
	unsigned int	          	mThreadAddr ;
  // @cmember the initialization event
	HANDLE				          	mInitEvent ;
  // @cmember the stop event
	HANDLE					          mStopEvent ;
  // @cmember the critical section
  mutable CRITICAL_SECTION  mLock;

private:
  // @cmember This is a helper function which wraps the ThreadMain() routine.
	static unsigned int __stdcall BootstrapThread (void *arg_list) ;
};

//
//	@mfunc
//	This function waits the specified amount of time for the initialization 
//  event to be signalled.
//	@parm The amount of time to wait
//  @rdesc 
//  Returns TRUE if the initialization event is signalled. Otherwise, FALSE is returned.
//  @devnote
//  This function is inherited from the Threader class.
// 
inline BOOL NTThreader::IsInitialized (const DWORD timeoutMs) const
{
  DWORD waitCode = ::WaitForSingleObject (mInitEvent, timeoutMs);

	return (waitCode == WAIT_OBJECT_0);
}
//
//	@mfunc
//	This function sets the initialization event.
//  @rdesc 
//  No return value.
//  @devnote
//  This function is inherited from the Threader class.
// 
inline void NTThreader::SetInitialized()
{
  ::SetEvent (mInitEvent);
}

//
//	@mfunc
//	This function checks to see if the thread is running.
//  @rdesc 
//  Returns TRUE if the thread is running. Otherwise, FALSE is returned.
//  @devnote
//  This function is inherited from the Threader class.
// 
inline BOOL NTThreader::IsRunning()
{
	if (mThreadAddr != 0)
	{
		return !WaitForThread (0);
	}
	else
	{
		return FALSE;
	}
}

//
//	@mfunc
//	This functions checks to see if a stop event is signalled. The stop event
//  is signalled when the StopThread() routine is called.
//	@parm The amount of time to wait 
//  @rdesc 
//  Returns TRUE if a stop was requested. Otherwise, FALSE is returned.
//  @devnote
//  This function is inherited from the Threader class.
// 
inline BOOL NTThreader::StopRequested (const DWORD timeoutMs) const
{
  DWORD waitCode = WaitForSingleObject (mStopEvent, timeoutMs);
  
  return (waitCode == WAIT_OBJECT_0);
}

//
//	@mfunc
//	This function returns the thread return code.
//  @rdesc 
//  Returns the mRetCode data member.
//  @devnote
//  This function is inherited from the Threader class.
// 
inline DWORD NTThreader::ThreadReturnCode() const
{
	return mRetCode;
}

//
//	@mfunc
//	This function returns the thread handle.
//  @rdesc 
//  Returns the mThreadHandle data member
//  @devnote
//  This function is inherited from the Threader class.
// 
inline HANDLE NTThreader::ThreadHandle() const
{
	return mThreadHandle;
}

//
//	@mfunc
//	This function returns the thread address
//  @rdesc 
//  Returns the mThreadAddr data member
//  @devnote
//  This function is inherited from the Threader class.
// 
inline unsigned int NTThreader::ThreadAddress() const
{
	return mThreadAddr;
}

//
//	@mfunc
//	This function returns the handle to the stop event
//  @rdesc 
//  Returns the mStopEvent data member
//  @devnote
//  This function is inherited from the Threader class.
// 
inline HANDLE NTThreader::StopEventHandle()  const
{
	return mStopEvent;
}; 

//
//	@mfunc
//	This functions enters the critical section
//  @rdesc 
//  No return value
//  @devnote
//  This function is inherited from the Threader class.
// 
inline void NTThreader::ThreadLock() const
{
	EnterCriticalSection (&mLock);
}

//
//	@mfunc
//	This functions leaves the critical section
//  @rdesc 
//  No return value
//  @devnote
//  This function is inherited from the Threader class.
// 
inline void NTThreader::ThreadUnlock() const
{
	LeaveCriticalSection (&mLock);
}

#endif //__NTTHREADER_H
