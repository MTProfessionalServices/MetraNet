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

#ifndef _ProductViewTHREAD_H_
#define _ProductViewTHREAD_H_

#include <wtypes.h>
#include <NTThreader.h>
#include <NTThreadLock.h>
#include "TestArgs.h"

class ProductViewThread : public NTThreader
{
	public:
		ProductViewThread() ;
		virtual ~ProductViewThread() ;

		virtual int ThreadMain () ;

		BOOL Init(TestArgs myArgs) ;

	private:
		TestArgs        mArgs ;
};


#endif // _ProductViewTHREAD_H_
