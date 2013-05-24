/**************************************************************************
 * @doc MTLocalMode
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
 *
 * @index | MTLocalMode
 ***************************************************************************/


#ifndef _MTLocalMode_H
#define _MTLocalMode_H

#include <stdio.h>
#include <fstream>

#include <mtsdk.h>

#ifdef UNIX //Yet another hack.
#include <ios> //need the class ios defined for RW stuff.
#define __RWDEF_H__ //eliminate where they define it.
#endif

#include <msixapi.h>

#include "MTMeterStore.h"

using namespace std;

class MTFileMeterAPI : public MSIXNetMeterAPI
{
public:
	/*
	 * generic NetMeter API interface
	 */
	
	MTFileMeterAPI(NetStream * apNet) : MSIXNetMeterAPI(apNet), mpMeterStore(NULL), mLocal (FALSE)
		
	{ }
	virtual ~MTFileMeterAPI()
	{ 
		if (mpMeterStore)
			delete mpMeterStore;
	}

	virtual BOOL Init();
	virtual BOOL Close();
	virtual BOOL MTFileMeterAPI::CommitSessionSet(const MeteringSessionSetImp & arSessionSet,
													MSIXTimestamp aTimestamp, 
													const char * apUpdateId);
	
	BOOL MeterFile (char * szFileName);
	void SetMeterFile (char * szFileName);
	void SetMeterStore (char * szFileName);

	virtual BOOL MarkAsFailed();
	virtual BOOL MarkAsDismissed();
	virtual BOOL MarkAsActive();
	virtual BOOL MarkAsCompleted();
	virtual BOOL MarkAsBackout();
	virtual BOOL UpdateMeteredCount();

protected:

	virtual BOOL MTFileMeterAPI::GetNextSession (ifstream & InFile, string & Buffer);
	virtual MSIXMessage * SendRequest(MSIXParser & arParser,
																		MeteringServer & arServer,
	 																		const MSIXMessage & arMessage);

	string mMeterFileName;
	MTMeterStore * mpMeterStore;
	BOOL mLocal;
};

#endif /* _MTLocalMode_H */
