/**************************************************************************
 * @doc MAPPEDVIEW
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
 * Created by: Derek Young
 * $Header$
 *
 * @index | MAPPEDVIEW
 ***************************************************************************/

#ifndef _MAPPEDVIEW_H
#define _MAPPEDVIEW_H

#include <fixedpool.h>

#define MTMAGIC "MetraTech Shared File"

#ifdef MAPPED_VIEW_DEF
#define DLL_EXPORT_MAPPED __declspec(dllexport)
#else
#define DLL_EXPORT_MAPPED
#endif

/*
 * Shares simultaneous access to a memory mapped file,
 * and provide utilities to synchronize between them.
 */
// TODO: make this an ObjectWithError
class DLL_EXPORT_MAPPED MappedViewHandle
{
private:
	// structure at the beginning of the memory mapped area
	struct MappedViewInfo
	{
		void * mpEmpty;							// set to NULL
		char mMagic[sizeof(MTMAGIC) + 1]; // magic header
		DWORD mAllocated;						// number of bytes allocated
		DWORD mMaxSize;							// max size of this mapping
		long mRefCount;							// number of simultaneous users
	};

public:
	MappedViewHandle();
	~MappedViewHandle();

	// modify the default delay on the mutex
	void SetTimeout(DWORD aMillis)
	{ mTimeout = aMillis; }

	// open either an existing file or a new one
	DWORD Open(const char * apFilename, const char * apMappingName,
						 DWORD aMaxSize, BOOL aForceReset = FALSE);

	// close the file and clean up
	void Close();

	//DWORD Open(const char * apMappingName);

	// return the size in bytes of a virtual memory page
	static int GetPageSize()
	{ return mPageSize; }

	// wait for the mutex to become available
	void * WaitForAccess(DWORD aTimeout, DWORD * apWaitResult = NULL);
	// release access to the mutex
	void ReleaseAccess();

	// allocate a chunk of the memory mapped file
	void * AllocateSpace(int aSpace);

	// return the start of usable memory (after the header)
	void * GetMemoryStart() const;

	// return the number of bytes available
	int GetAvailableSpace() const;

	// return the total amount of space is bytes
	int GetTotalSpace() const;

	// return the number of bytes of overhead used by the mapped view class itself.
	// therefore, to get X bytes of free space you need to allocate the total
	// size as GetOverhead() + X
	static int GetOverhead();

	// reset the contents of the memory mapped file
	BOOL ResetMemory(DWORD aMaxSize);

	// return TRUE if this has already been initialized
	BOOL IsInitialized() const
	{ return mMutex != NULL; }

protected:
	// override to perform additional initialization,
	// but continue to call this version in derived version
	virtual BOOL InitializeMappedMemory(BOOL aReset);

private:
	//DWORD InternalInit(BOOL aCreatedFile, const char * apFilename,
	//BOOL aForceReset, const char * apMappingName);

	// query the operating system for the size of a page in bytes
	static int CalculatePageSize();


	DWORD InitDacl(SECURITY_ATTRIBUTES & arSa, SECURITY_DESCRIPTOR & arSd);
	DWORD InitMutex(const char * apMappingName);

	BOOL ValidHeader(DWORD aMaxSize);

	// the guts of Open
	DWORD OpenInternal(const char * apFilename, const char * apMappingName,
										 DWORD aMaxSize, BOOL aForceReset);

private:
	// size of a page in bytes
	static int mPageSize;

	// mutex to control access to the shared memory
	HANDLE mMutex;
	// timeout for mutex
	DWORD mTimeout;

	// handle created by CreateFileMapping
	HANDLE mFileMapping;

	// handle created by CreateFile
	HANDLE mFileHandle;

	// pointer to the header
	MappedViewInfo * mpViewInfo;

	BOOL mCreatedFile;
private:
#ifdef DEBUG
	// for debug builds, attempt to validate the shared memory
	void AssertValid() const;
#endif
};

#endif /* _MAPPEDVIEW_H */
