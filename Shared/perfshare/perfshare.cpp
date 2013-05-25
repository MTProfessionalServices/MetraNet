/**************************************************************************
 * PERFSHARE
 *
 * Copyright 1997-2001 by MetraTech Corp.
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

#include <metra.h>

#include <perfshare.h>

PerfShare::~PerfShare()
{
	if (mpStats)
	{
		BOOL ret = UnmapViewOfFile(mpStats);
		ASSERT(ret);
		mpStats = NULL;
	}
}

BOOL PerfShare::Init()
{
	const char * functionName = "PerfShared::Init";

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

	std::wstring shareName(L"MTPerfShare");
	// make this globally unique across terminal services sessions.
	shareName.insert(0, L"Global\\");

	// try to open the view first - if it exists, use it
	hMapFile = ::OpenFileMapping(FILE_MAP_ALL_ACCESS, // Read/write permission. 
															 FALSE,	// Do not inherit the name
															 shareName.c_str());
 
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
																 shareName.c_str()); // Name of mapping object. 
 
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
	mpStats = (SharedStats *) address;
	if (!mpStats->IsValid())
	{
		mpStats->Init();
		// initialize it
	}

	return TRUE;
}

void SharedStats::Init()
{
	memset(this, 0x00, sizeof(*this));
	mMagic = SharedStats::MAGIC;
}

void SharedStats::UpdateSessionsRated(int aCount)
{
	UpdateValue(&mSessionsRated, aCount);
}

void SharedStats::UpdateSessionsRouted(int aCount)
{
	UpdateValue(&mSessionsRouted, aCount);
}

void SharedStats::UpdateSessionsQueued(int aCount)
{
	UpdateValue(&mSessionsQueued, aCount);
}

void SharedStats::UpdateValue(LONG * apValue, int aCount)
{
	// keep trying to update the value until we succeed
	while (TRUE)
	{
		DWORD current = *apValue;
		DWORD newValue = current + aCount;

		DWORD initial = ::InterlockedCompareExchange(apValue, newValue, current);
		if (initial == current)
			break;
	}
}

void SharedStats::SetTiming(enum Timing aTiming, int aValue)
{
	ASSERT((int) aTiming < (int) TIMING_COUNT);
	LONG * pvalue = &mMiscTimings[(int) aTiming];

	// no interlocked function is needed.  assignment is atomic
	*pvalue = aValue;
}
