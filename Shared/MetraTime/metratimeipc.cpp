/**************************************************************************
 * METRATIMEIPC
 *
 * Copyright 1997-2002 by MetraTech Corp.
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
 ***************************************************************************/

#include <StdAfx.h>
#include "metratimeipc.h"

MetraTimeIPC::~MetraTimeIPC()
{
	Reset();
}

BOOL MetraTimeIPC::Init()
{
	const char * functionName = "MetraTimeIPC::Init";

	// Note that this needs to be created in the global kernel object
	// namespace because some of our apps run as services and some (e.g.
	// the client) run as applications that might be in a terminal services
	// session.
	const wchar_t * sharedFileName = L"Global\\MTMetraTimeIPC";

	HANDLE hMapFile;

	SECURITY_ATTRIBUTES sa;
	SECURITY_DESCRIPTOR sd;

	// create a NULL security descriptor
	sa.nLength = sizeof(SECURITY_ATTRIBUTES);
	sa.bInheritHandle = TRUE;
	sa.lpSecurityDescriptor = &sd;
	if (!::InitializeSecurityDescriptor(&sd, SECURITY_DESCRIPTOR_REVISION)
		|| !::SetSecurityDescriptorDacl(&sd, TRUE, (PACL)NULL, FALSE))
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// try to open the view first - if it exists, use it
	hMapFile = ::OpenFileMapping(FILE_MAP_ALL_ACCESS, // Read/write permission. 
															 FALSE,	// Do not inherit the name
															 sharedFileName);
 
	BOOL weCreated;
	if (!hMapFile) 
	{
		// couldn't open it so try to create it
		int size = 4096;

		hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, // Current file handle. 
																 &sa,	// Default security. 
																 PAGE_READWRITE, // Read/write permission. 
																 0,	// Max. object size. 
																 size,	// size
																 sharedFileName); // Name of mapping object. 
 
		if (hMapFile == NULL) 
		{ 
			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
			return FALSE;
		}
		weCreated = TRUE;
	}
	else
		weCreated = FALSE;

	ASSERT(hMapFile);
	mMapHandle = hMapFile;

	void * address = ::MapViewOfFile(hMapFile, // Handle to mapping object. 
																	 FILE_MAP_ALL_ACCESS,	// Read/write permission. 
																	 0,	// Max. object size. 
																	 0,	// Size of hFile. 
																	 0); // Map entire file. 

	if (address == NULL)
	{ 
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// TODO: there could be a race condition here
	mpData = (MetraTimeParams *) address;
	if (!mpData->IsValid())
	{
		mpData->Init();
		// initialize it
	}

	return TRUE;
}

void MetraTimeIPC::Reset()
{
	if (mpData)
	{
		BOOL ret = UnmapViewOfFile(mpData);
		ASSERT(ret);
		mpData = NULL;
	}
}

void MetraTimeParams::Init()
{
	memset(this, 0x00, sizeof(*this));
	mMagic = MetraTimeParams::MAGIC;
}

void MetraTimeParams::SetOffset(long offset)
{
	mOffset = offset;
}

void MetraTimeParams::SetTimeRoll(BOOL roll)
{
	mTimeRoll = roll;
}

long MetraTimeParams::GetOffset() const
{
	return (long) mOffset;
}

BOOL MetraTimeParams::GetTimeRoll() const
{
	return (BOOL) mTimeRoll;
}
