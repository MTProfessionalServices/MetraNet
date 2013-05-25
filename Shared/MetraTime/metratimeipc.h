/**************************************************************************
 * @doc METRATIMEIPC
 *
 * @module |
 *
 *
 * Copyright 2002 by MetraTech Corporation
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | METRATIMEIPC
 ***************************************************************************/

#ifndef _METRATIMEIPC_H
#define _METRATIMEIPC_H

#include <errobj.h>
#include <autohandle.h>

#ifdef WIN32
// only include this header one time
#pragma once
#endif

class MetraTimeParams
{
private:
	enum
	{
		// just a unique number
		MAGIC = 0xB1AAC9BB
	};


public:
	void SetOffset(long offset);
	void SetTimeRoll(BOOL roll);

	long GetOffset() const;
	BOOL GetTimeRoll() const;


	BOOL IsValid()
	{ return mMagic == MAGIC; }

	//
	// setup
	//
	void Init();

private:
	unsigned long mMagic;
	LONG mOffset;
	LONG mTimeRoll;
};

class MetraTimeIPC : public ObjectWithError
{
public:
	MetraTimeIPC()
		: mpData(NULL)
	{ }

	~MetraTimeIPC();

	BOOL Init();
	void Reset();

	// get stats meant for update
	MetraTimeParams & GetWriteableData()
	{ return *mpData; }
	
	// get stats meant only for reading
	const MetraTimeParams & GetReadOnlyData() const
	{ return *mpData; }

private:
	AutoHANDLE mMapHandle;

	MetraTimeParams * mpData;
};

#endif /* _METRATIMEIPC_H */
