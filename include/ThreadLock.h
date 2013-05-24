/**************************************************************************
 * @doc THREADLOCK
 * 
 * @module Thread Lock encapsulation |
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
 * @index | THREADLOCK
 ***************************************************************************/

#ifndef __THREADLOCK_H
#define __THREADLOCK_H

#include "MTSL_DLL.h"

// @class ThreadLock (abstract class)
class MTSL_DLL_EXPORT ThreadLock
{
// @access Public:
public:
  // @cmember
	// Constructor
  ThreadLock() {};
  // @cmember
	// Destructor
  virtual ~ThreadLock()	{};

  // @cmember,mfunc This function will encapsulate the OS specific enter critical 
  //  section system call.
	//  @@rdesc
	//  No return value.
  //  @@devnote 
  //  This is a pure virtual function that is implemented by the class
  //  that inherits from this class. 
	virtual void Lock()	=0 ;
  // @cmember,mfunc This function will encapsulate the OS specific leave critical 
  //  section system call.
	//  @@rdesc
	//  No return value.
  //  @@devnote 
  //  This is a pure virtual function that is implemented by the class
  //  that inherits from this class. 
	virtual void Unlock() =0 ;	
};

#endif // __THREADLOCK_H