/**************************************************************************
 * @doc 
 * 
 * @module  Test class that abstracts a session thread |
 * 
 * This class is used to test an individual session.
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
 * Created by: 
 * $Header$
 *
 * @index | 
 ***************************************************************************/

#ifndef _SERVICESTHREAD_H_
#define _SERVICESTHREAD_H_

#include <wtypes.h>
#include <NTThreader.h>
#include <NTThreadLock.h>
#include "TestArgs.h"

class ServicesThread : public NTThreader
{
	public:
		ServicesThread() ;
		virtual ~ServicesThread() ;

		virtual int ThreadMain () ;

		BOOL Init(TestArgs myArgs) ;

	private:
		TestArgs        mArgs ;
};


#endif // _SERVICESTHREAD_H_
