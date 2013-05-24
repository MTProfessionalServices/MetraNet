/**************************************************************************
 * @doc MAPPEDVIEW
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
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mappedview.h>

#include <makeunique.h>

#include <string>

/*********************************************** MappedViewHandle ***/

int MappedViewHandle::mPageSize = CalculatePageSize();

MappedViewHandle::MappedViewHandle() : mMutex(NULL), mFileMapping(NULL),
	mFileHandle(NULL), mTimeout(25000L),
	mpViewInfo(NULL), mCreatedFile(FALSE)
{ }

MappedViewHandle::~MappedViewHandle()
{
	Close();
}

int MappedViewHandle::CalculatePageSize()
{
	SYSTEM_INFO info;
	GetSystemInfo(&info);
	return info.dwPageSize;
}


void MappedViewHandle::Close()
{
	if (mpViewInfo)
	{
		// decrement the reference count
		// TODO: why doesn't this work?
		long decremented = InterlockedDecrement(&mpViewInfo->mRefCount);
		ASSERT(decremented >= 0);
		if (decremented == 0)
		{
			// we are the last to release from the memory
			// TODO: compute a signature of it for next time
		}
	}

	if (mMutex)
	{
		// make sure it's released.  CloseHandle can still leave the mutex held
		ReleaseMutex(mMutex);
		CloseHandle(mMutex);
		mMutex = NULL;
	}
	if (mpViewInfo)
	{
		UnmapViewOfFile(mpViewInfo);
		mpViewInfo = NULL;
	}
	if (mFileMapping)
	{
		CloseHandle(mFileMapping);
		mFileMapping = NULL;
	}
	if (mFileHandle != (HANDLE)0xFFFFFFFF && mFileHandle != NULL)
	{
		CloseHandle(mFileHandle);
		mFileHandle = NULL;
	}
}

DWORD MappedViewHandle::InitDacl(SECURITY_ATTRIBUTES & arSa, SECURITY_DESCRIPTOR & arSd)
{
	/*
	 * create a NULL security descriptor
	 * TODO: create a more restricted discretionary access control list.
	 */
	arSa.nLength = sizeof(SECURITY_ATTRIBUTES);
	arSa.bInheritHandle = TRUE;
	arSa.lpSecurityDescriptor = &arSd;
	if (!::InitializeSecurityDescriptor(&arSd, SECURITY_DESCRIPTOR_REVISION))
		return ::GetLastError();
	if (!::SetSecurityDescriptorDacl(&arSd, TRUE, (PACL)NULL, FALSE))
		return ::GetLastError();

	return ERROR_SUCCESS;
}

DWORD MappedViewHandle::InitMutex(const char * apMappingName)
{
	SECURITY_ATTRIBUTES sa;
	SECURITY_DESCRIPTOR sd;
	DWORD err = InitDacl(sa, sd);
	if (err != ERROR_SUCCESS)
		return err;

	/*
	 * create the mutex
	 */
	std::string mutexName(apMappingName);
	mutexName += "Mutex";

	MakeUnique(mutexName);
	// make this globally unique across terminal services sessions.
	mutexName.insert(0, "Global\\");

	mMutex = ::CreateMutex(&sa,			// security
												 FALSE,		// initially not owned
												 mutexName.c_str()); // mutex name
	if (mMutex == NULL)
		return ::GetLastError();

	DWORD waitResult;
	if (!WaitForAccess(mTimeout, &waitResult))   // five-second time-out interval
	{
		// Cannot get mutex ownership due to time-out.
		CloseHandle(mMutex);
		mMutex = NULL;
		return WAIT_TIMEOUT;
	}
	return ERROR_SUCCESS;
}


DWORD MappedViewHandle::Open(const char * apFilename,
														 const char * apMappingName,
														 DWORD aMaxSize,
														 BOOL aForceReset /* = FALSE */)
{
	if (mMutex != NULL)
		// already initialized - nothing to do
		return ERROR_SUCCESS;

	// initialize the mutex and take access of it
	DWORD err = InitMutex(apMappingName);
	if (err != ERROR_SUCCESS)
		return err;

	try
	{
		err = OpenInternal(apFilename, apMappingName, aMaxSize, aForceReset);
	}
	catch (...)
	{
		// TODO: use one of our internal errors
		err = ERROR_INVALID_DATA;
	}

	if (err != ERROR_SUCCESS)
	{
		Close();

		// only delete the file if we created it
		if (mCreatedFile)
			::DeleteFile(apFilename);
	}

	// Release ownership of the mutex object - we're done initializing
	ReleaseAccess();

	return err;
}


DWORD MappedViewHandle::OpenInternal(const char * apFilename,
														 const char * apMappingName,
														 DWORD aMaxSize,
														 BOOL aForceReset)
{
	mCreatedFile = FALSE;

	std::string mappingName(apMappingName);
	MakeUnique(mappingName);

	// make this globally unique across terminal services sessions.
	mappingName.insert(0, "Global\\");

	/*
	 * has it already been created in a state where we can open it?
	 */
	mFileMapping = ::OpenFileMapping(FILE_MAP_ALL_ACCESS, // access mode 
																	 TRUE, // inherit flag 
																	 // pointer to name of file-mapping object 
																	 mappingName.c_str());
	BOOL alreadyOpen;

	if (mFileMapping)
	{
		mCreatedFile = FALSE;
		// we don't know what the file handle is or whether there is one
		mFileHandle = NULL;
		alreadyOpen = TRUE;
	}
	else
	{
		alreadyOpen = FALSE;

		/*
		 * create a NULL security descriptor
		 * TODO: create a more restricted discretionary access control list.
		 */
		SECURITY_ATTRIBUTES sa;
		SECURITY_DESCRIPTOR sd;
		DWORD err = InitDacl(sa, sd);
		if (err != ERROR_SUCCESS)
		{
			Close();
			return err;
		}

		/*
		 * create the file if requested
		 */

		if (apFilename)
		{

			mFileHandle =
				::CreateFile(apFilename,
										 GENERIC_READ | GENERIC_WRITE,	// access
										 FILE_SHARE_READ | FILE_SHARE_WRITE,	// share
										 &sa,					// security
										 OPEN_ALWAYS, // creation distribution
										 FILE_ATTRIBUTE_NORMAL | FILE_FLAG_RANDOM_ACCESS, // flags
										 NULL); // template
			if (mFileHandle == (HANDLE)0xFFFFFFFF)
			{
				DWORD err = ::GetLastError();
				Close();
				return err;
			}
			else
				// if it didn't exist, we own it
				mCreatedFile = (::GetLastError() != ERROR_ALREADY_EXISTS);
		}
		else
			// no file underneath
			mFileHandle = (HANDLE)0xFFFFFFFF;

		// attempt to trim the file to the correct size in case its
		// size was changed.
		if (!mCreatedFile)
		{
			BOOL setFileSize = TRUE;
			DWORD currentSize = ::GetFileSize(mFileHandle, NULL);
			if (currentSize != aMaxSize)
			{
				DWORD setFileRet = ::SetFilePointer(
					mFileHandle,					// handle to file
					aMaxSize,							// bytes to move pointer
					NULL,									// bytes to move pointer (high)
					FILE_BEGIN);					// starting point

				if (setFileRet != ((DWORD)-1))
					setFileSize = ::SetEndOfFile(mFileHandle);
				else
					setFileSize = FALSE;

				if (!setFileSize)
				{
					DWORD err = ::GetLastError();
					Close();
					if (mCreatedFile)
						::DeleteFile(apFilename);
					return err;
				}
			}
		}

		mFileMapping =
			::CreateFileMapping(mFileHandle,	// handle to file to map
													&sa,		// optional security attributes
													PAGE_READWRITE, // protection
													0, // max size high (assume always 0)
													aMaxSize,
													mappingName.c_str());

		if (!mFileMapping)
		{
			DWORD err = ::GetLastError();
			Close();

			if (mCreatedFile)
				::DeleteFile(apFilename);

			return err;
		}
	}

	/*
	 * map the file into memory
	 */
	mpViewInfo = (MappedViewInfo *)
		::MapViewOfFile(mFileMapping,	// mapping object
										FILE_MAP_WRITE, // access mode
										0,			// offset high
										0,			// offset low
										0);		// number of bytes (0 = all)

	if (mpViewInfo == NULL)
	{
		DWORD err = ::GetLastError();

		Close();
		if (mCreatedFile)
			::DeleteFile(apFilename);
		return err;
	}

	/*
	 * see if this is a new mapping by detecting the cookie.
	 * if so, initialize a MappingHeapInfo segment at the beginning
	 * with the MappingHeapInfo segment at the end.
	 *
	 * since the initialization is performed within the mutex
	 * lock, it's done atomically.  The memory will be either fully
	 * initialized, or not at all.
	 */
	BOOL validHeader = ValidHeader(aMaxSize);
	int refCount = mpViewInfo->mRefCount;

	if (!alreadyOpen && refCount > 0)
	{
		// someone didn't decrement the ref count! the memory
		// could be corrupted, so reset it all.

		// TODO: log this event! it was caused by a crash or
		// invalid shutdown.
		validHeader = FALSE;
	}
	else if (validHeader && aForceReset && refCount > 0)
	{
		// can't reset the memory if it's already in use
		// TODO: this should be one of our error codes
		return ERROR_SHARING_VIOLATION;
	}

	if (!validHeader || aForceReset)
	{
		// reset from scratch
		if (!ResetMemory(aMaxSize))
			throw;									// initialization failed
		// TODO: handle the error more cleanly
	}
	else
	{
		// already initialized and valid

		// notify others that we're using the memory
		::InterlockedIncrement(&mpViewInfo->mRefCount);

		if (!InitializeMappedMemory(FALSE))
			// initialization failed
			throw;
	}

#ifdef DEBUG
	AssertValid();
#endif // DEBUG

 return NO_ERROR;
}

BOOL MappedViewHandle::ResetMemory(DWORD aMaxSize)
{
	// all new! initialize
	memset(mpViewInfo, 0, sizeof(MappedViewInfo));

	mpViewInfo->mpEmpty = NULL;
	strcpy(mpViewInfo->mMagic, MTMAGIC);

	mpViewInfo->mAllocated = sizeof(MappedViewInfo);
	mpViewInfo->mMaxSize = aMaxSize;

	// so far we are the only user
	mpViewInfo->mRefCount = 1;

	// perform additional initialization
	return InitializeMappedMemory(TRUE);
}


BOOL MappedViewHandle::ValidHeader(DWORD aMaxSize)
{
	return (mpViewInfo->mMaxSize == aMaxSize
					&& mpViewInfo->mpEmpty == NULL
					&& 0 == strcmp(mpViewInfo->mMagic, MTMAGIC));
}


BOOL MappedViewHandle::InitializeMappedMemory(BOOL aReset)
{
	return TRUE;
}

void * MappedViewHandle::WaitForAccess(DWORD aTimeout, DWORD * apWaitResult /* = NULL */)
{
	DWORD waitResult =
		::WaitForSingleObject(mMutex,   // handle of mutex
													aTimeout);
	if (apWaitResult)
		*apWaitResult = waitResult;

	if (waitResult == WAIT_OBJECT_0 || waitResult == WAIT_ABANDONED)
		return OffsetPointer<void, MappedViewInfo>(mpViewInfo, sizeof(MappedViewInfo));
	else
		return NULL;
}

void MappedViewHandle::ReleaseAccess()
{
	::ReleaseMutex(mMutex);
}

int MappedViewHandle::GetAvailableSpace() const
{
	return mpViewInfo->mMaxSize - mpViewInfo->mAllocated;
}

int MappedViewHandle::GetTotalSpace() const
{
	return mpViewInfo->mMaxSize - sizeof(MappedViewInfo);
}

int MappedViewHandle::GetOverhead()
{
	return sizeof(MappedViewInfo);
}

void * MappedViewHandle::AllocateSpace(int aSpace)
{
	// user must have access!

	if (mpViewInfo->mAllocated + aSpace > mpViewInfo->mMaxSize)
	{
		// don't have enough space
		return NULL;
	}

	unsigned char * start =
		OffsetPointer<unsigned char, MappedViewInfo>(mpViewInfo, mpViewInfo->mAllocated);

	// increase the amount of allocated space
	mpViewInfo->mAllocated += aSpace;

#ifdef DEBUG
	// make sure this space is really available and has an identifiable value
	memset(start, 0xDB, aSpace);
#endif

#ifdef DEBUG
	AssertValid();
#endif // DEBUG

	return start;
}

void * MappedViewHandle::GetMemoryStart() const
{
	return OffsetPointer<void, MappedViewInfo>(mpViewInfo, sizeof(MappedViewInfo));
}


#ifdef DEBUG
void MappedViewHandle::AssertValid() const
{
	ASSERT(mpViewInfo);
	ASSERT_VALID_POINTER(mpViewInfo, sizeof(MappedViewInfo));
	ASSERT(mpViewInfo->mpEmpty == NULL && 0 == strcmp(mpViewInfo->mMagic, MTMAGIC));
	ASSERT(mPageSize > 0 && mPageSize == CalculatePageSize());
	ASSERT(mpViewInfo->mMaxSize > 0);
	ASSERT(mpViewInfo->mAllocated <= mpViewInfo->mMaxSize);

	// TODO: assert refcount?
}
#endif // DEBUG
