/**************************************************************************
 * @doc MTMeterStore
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
 * @index | MTMeterStore
 ***************************************************************************/

#ifndef _MTMeterStore_H
#define _MTMeterStore_H

#include <mtsdk.h>
#include <string>
#include <map>
#include "errobj.h"

class MTMeterStore 
{
public:
	/*
	 * generic MeterStore interface
	 */

	MTMeterStore (const char * szFile)
		: mFileName (szFile), mFile(NULL)
	{ }

	virtual ~MTMeterStore()
	{
		if(mFile)
			fclose(mFile);

		mFile = NULL;
	}

	virtual BOOL MarkComplete(const char * Key);
	virtual BOOL MarkInProgress(const char * Key);
	virtual BOOL IsComplete(const char * Key);
	virtual BOOL IsInProgress(const char * Key);

private:
	enum Status 
	{
		Unknown = 0,
		InProgress = 1,
		Complete = 2
	};

	typedef std::map<std::string, int> StatusMap;

	std::string	mFileName;
	FILE*		mFile;
	StatusMap	mmapStatus;

	BOOL ReadMap();
	BOOL SetMap(const char *key, Status status);
};


#endif /* _MTMeterStore_H */
