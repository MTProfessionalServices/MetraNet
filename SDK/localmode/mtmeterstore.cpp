/**************************************************************************
 * @doc MTMeterStore
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
 ***************************************************************************/

#include <metra.h>
#include "MTMeterStore.h"
#include <fstream>

using namespace std;


BOOL MTMeterStore::MarkComplete (const char * szKey)

{
	if(!ReadMap())
		return false;

	return SetMap(szKey, Complete);
}

BOOL MTMeterStore::IsComplete (const char * szKey)
{
	if(!ReadMap())
		return false;

	StatusMap::iterator it = mmapStatus.find(szKey);

	return (it != mmapStatus.end()) && (it->second == Complete);
}

BOOL MTMeterStore::MarkInProgress (const char * szKey)

{
	if(!ReadMap())
		return false;

	return SetMap(szKey, InProgress);
}

BOOL MTMeterStore::IsInProgress (const char * szKey)

{
	if(!ReadMap())
		return false;

	StatusMap::iterator it = mmapStatus.find(szKey);

	return (it != mmapStatus.end()) && (it->second == InProgress);
}

BOOL MTMeterStore::ReadMap()
{
	// if file is open, then it is already loaded
	if(mFile)
		return TRUE;

	try 
	{
		// read the file into memory and keep it open. Hopefully it is open in exclusive mode.
		mFile = fopen(mFileName.c_str(), "a+");

		if(!mFile)
			return FALSE;

		fseek(mFile, 0, SEEK_SET);

		while(!feof(mFile))
		{
			char key[100];
			int status = 0;
			key[0] = 0;

			if(fscanf(mFile, "%99s %d\n", key, &status) == 2)
			{
				mmapStatus[key] = Status(status);
			}
		}
	}
	catch(...)
	{
		return FALSE;
	}

	return TRUE;
}

BOOL MTMeterStore::SetMap(const char *key, Status status)
{
	BOOL bRes = TRUE;

	mmapStatus[key] = status;

	bRes = bRes && (fprintf(mFile, "%s %d\n", key, status) > 0);
	bRes &= bRes && (EOF != fflush(mFile));

	return bRes;
}


