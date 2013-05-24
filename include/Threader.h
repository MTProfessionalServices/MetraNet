/**************************************************************************
 * @doc THREADER
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
 * @index | THREADER
 ***************************************************************************/

#ifndef __THREADER_H
#define __THREADER_H

#include "MTSL_DLL.h"
// @class Threader (abstract class)
class MTSL_DLL_EXPORT Threader
{
// @access Public:
public:
  // @cmember
	// Constructor
  Threader () {};
  // @cmember
	// Destructor
  virtual ~Threader() {};

  // @cmember,mfunc This function will start the thread.
	//  @@rdesc
	//  Returns TRUE on successful starting of the thread. Otherwise, FALSE is returned.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
	virtual BOOL StartThread() = 0 ;
  // @cmember,mfunc This function will stop the thread.
  //  @@parm Time to wait for the thread to stop.
	//  @@rdesc
	//  Returns TRUE on successful stopping of the thread. Otherwise, FALSE is returned.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
	virtual BOOL StopThread     (const DWORD aTimeout)= 0;
  // @cmember,mfunc This function will wait for the thread to be signalled.
  //  @@parm Time to wait for the thread.
	//  @@rdesc
	//  Returns TRUE on successful wait of the thread. Otherwise, FALSE is returned.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
	virtual BOOL WaitForThread	(const DWORD aTimeout)= 0;
  // @cmember,mfunc This function will wait the specified time for the initialization 
  //  event to be signalled.
  //  @@parm Time to wait for the initialized event to be signalled.
	//  @@rdesc
	//  Returns TRUE if the initialization event is signalled. Otherwise, FALSE is returned.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class.
	virtual BOOL IsInitialized  (const DWORD aTimeout) const = 0;
  // @cmember,mfunc This function will check to see if the thread is running.
	//  @@rdesc
	//  Returns TRUE if the thread is running. Otherwise, FALSE is returned.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class.
	virtual BOOL IsRunning() = 0 ;
  // @cmember,mfunc This function will check to see if a stop was requested.
  //  @@parmopt Time to wait for the stop event to be signalled.
	//  @@rdesc
	//  Returns TRUE if a stop was requested. Otherwise, FALSE is returned.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
	virtual BOOL StopRequested  (const DWORD aTimeout_ms = 0) const = 0;

  // @cmember,mfunc This function will enter a critical section to force 
  //  serialization of the code.
	//  @@rdesc
	//  No return value
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
  virtual void ThreadLock()	  const = 0;
  // @cmember,mfunc This function will leave a critical section.
	//  @@rdesc
	//  No return value.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
	virtual void ThreadUnlock() const = 0;
	// @cmember,mfunc This function returns the error code from the thread.
	//  @@rdesc
	//  Returns the error code from the thread.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
	virtual DWORD ThreadReturnCode() const = 0 ;
  // @cmember,mfunc This pure virtual function is implemented by the object 
  //  that inherits this class. This function implements the logic for the thread.
	//  @@rdesc
	//  Returns the value which becomes the thread return code.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class.
	virtual int ThreadMain() = 0;	// object that inherits this class implements this method ...
// @access Protected:
protected:
  // @cmember,mfunc This function sets the initialization event.
	//  @@rdesc
	//  No return value.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
	virtual void	SetInitialized() = 0 ;
};

#endif //__THREADER_H
