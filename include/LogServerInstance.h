/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* $Header$
* 
* This is a simple class to lock an instance of the log server in memory
*
***************************************************************************/
#ifndef __LOGSERVERINSTANCE_H__
#define __LOGSERVERINSTANCE_H__

#include <NTLogServer.h>


class MTLogServerInstance {
public:
	MTLogServerInstance() {
		mpLogServer = NTLogServer::GetInstance() ;
	}
	~MTLogServerInstance() {
		mpLogServer->ReleaseInstance();
	}

private:
	NTLogServer *mpLogServer;
};
#endif //__LOGSERVERINSTANCE_H__