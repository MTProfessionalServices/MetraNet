/**************************************************************************
 * @doc SHAREDSESSION
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
 ***************************************************************************/

#include <metra.h>

#include <mappedview.h>
#include <sharedsess.h>

#include <crc32.h>

#include <unknwn.h>							// IUnknown definition

/***************************** SharedSessionMappedViewHandle ***/

BOOL SharedSessionMappedViewHandle::InitializeMappedMemory(BOOL aReset)
{
	// don't do anything unless we're resetting
	if (!aReset)
		return TRUE;

	SharedSessionHeader * header = (SharedSessionHeader *) GetMemoryStart();
	header->InvalidateHeader();
	return TRUE;
}



/*************************************** SharedSessionHeader ***/

SharedSessionHeader *
SharedSessionHeader::Initialize(SharedSessionMappedViewHandle & arHandle,
																void * apMemStart,
																long aSessionPoolByteSize,
																long aPropPoolByteSize,
																long aSetPoolByteSize,
																long aSetNodePoolByteSize,
																long aObjectOwnerPoolByteSize,
																long aStringPoolByteSize,
																BOOL aForceReset /* = FALSE */ )
{
	BOOL needsReset;
	SharedSessionHeader * header = ValidHeader(apMemStart);
	if (header)
		needsReset = FALSE;
	else
		needsReset = TRUE;

	if (aForceReset)
		needsReset = TRUE;

	if (needsReset)
	{
		header = (SharedSessionHeader *)
			arHandle.AllocateSpace(sizeof(SharedSessionHeader));
		if (!header)
			return NULL;							// unable to allocate space

		if (!header->Init(arHandle, aSessionPoolByteSize, aPropPoolByteSize,
											aSetPoolByteSize, aSetNodePoolByteSize,
											aObjectOwnerPoolByteSize, aStringPoolByteSize))
			return NULL;
	}

	return header;
}

BOOL SharedSessionHeader::Init(SharedSessionMappedViewHandle & arHandle,
															 long aSessionPoolByteSize,
															 long aPropPoolByteSize,
															 long aSetPoolByteSize,
															 long aSetNodePoolByteSize,
															 long aObjectOwnerPoolByteSize,
															 long aStringPoolByteSize)
{
	//
	// initialize session pool
	//

	// allocate space
	void * mem = arHandle.AllocateSpace(aSessionPoolByteSize);
	if (!mem)
		return FALSE;

	if (!mSessionPool.Initialize(mem, aSessionPoolByteSize))
		return FALSE;

	// set all sessions as FREE_SESSIONs
	SharedSession * sessionStart = GetSessionStart();
	for (int i = 0; i < mSessionPool.GetSize(); i++)
	{
		SharedSession * sess = sessionStart	+ i;
		sess->SetSessionInfo(SharedSession::FREE_SESSION);
	}

	// initialize the hash table to look up sessions
	for (i = 0; i < UID_BUCKETS; i++)
	{
		mSessionLookup[i] = -1;
		mSessionLookupLocks[i] = 0;	// not locked
	}

	//
	// initialize property pool
	//

	// allocate space
	mem = arHandle.AllocateSpace(aPropPoolByteSize);
	if (!mem)
		return FALSE;

	if (!mPropPool.Initialize(mem, aPropPoolByteSize))
		return FALSE;

	// set all properties as FREE_PROPERTYs
//#if 0
	SharedPropVal * propStart = GetPropValStart();
	for (i = 0; i < mPropPool.GetSize(); i++)
	{
		SharedPropVal * prop = propStart + i;
//		prop->mType = SharedPropVal::FREE_PROPERTY;
		prop->SetFreeValue();
	}
//#endif

	//
	// initialize set pool
	//
	// TODO: is this safe?
	mem = arHandle.AllocateSpace(aSetPoolByteSize);
	if (!mem)
		return FALSE;

	mSetPool.Initialize(mem, aSetPoolByteSize);

	//
	// initialize set node pool
	//
	mem = arHandle.AllocateSpace(aSetNodePoolByteSize);
	if (!mem)
		return FALSE;

	mSetNodePool.Initialize(mem, aSetNodePoolByteSize);

	//
	// initialize the object owner pool
	//
	mem = arHandle.AllocateSpace(aObjectOwnerPoolByteSize);
	if (!mem)
		return FALSE;

	mObjectOwnerPool.Initialize(mem, aObjectOwnerPoolByteSize);


	long smallPoolSize = (2 * aStringPoolByteSize) / 12;
	long medPoolSize = (6 * aStringPoolByteSize) / 12;
	long largePoolSize = (4 * aStringPoolByteSize) / 12;

	//
	// small string pool
	//
	mem = arHandle.AllocateSpace(smallPoolSize);
	if (!mem)
		return FALSE;

	mSmallStringPool.Initialize(mem, smallPoolSize);

	//
	// medium string pool
	//
	mem = arHandle.AllocateSpace(medPoolSize);
	if (!mem)
		return FALSE;

	mMediumStringPool.Initialize(mem, medPoolSize);

	//
	// large string pool
	//
	mem = arHandle.AllocateSpace(largePoolSize);
	if (!mem)
		return FALSE;

	mLargeStringPool.Initialize(mem, largePoolSize);


	// set next owner ID arbitrarily.  Setting it
	// to a non zero value makes it easy to debug.
	mNextOwnerID = 1000;

	// NOTE: magic is set last so that it's only valid if the structure
	// was initialized correctly
	mMagic = SharedSessionHeader::MAGIC;

	return TRUE;
}


SharedSessionHeader *
SharedSessionHeader::Open(SharedSessionMappedViewHandle & arHandle)
{
	void * memStart = arHandle.GetMemoryStart();
	ASSERT(memStart);
	if (!memStart)
		return NULL;

	SharedSessionHeader * header = ValidHeader(memStart);
	return header;
}

void
SharedSessionHeader::InvalidateHeader()
{
	mMagic = SharedSessionHeader::MAGIC - 1;
}

const char * SharedSessionHeader::AllocateString(const char * apStr, long & arRef)
{
	int size = strlen(apStr) + 1;
	char * str = AllocateBytes(size, arRef);
	if (!str)
		return NULL;

	strcpy(str, apStr);
	return str;
}

void SharedSessionHeader::FreeString(long aRef)
{
	FreeStringRef(aRef);
}

const char * SharedSessionHeader::GetString(long aRef)
{
	const char * bytes = GetBytes(aRef);
	return bytes;
}


const wchar_t * SharedSessionHeader::AllocateWideString(const wchar_t * apStr,
																												long & arRef)
{
	int size = (wcslen(apStr) + 1) * sizeof(wchar_t);

	wchar_t * str = (wchar_t *) AllocateBytes(size, arRef);
	if (!str)
		return NULL;

	wcscpy(str, apStr);
	return str;
}

void SharedSessionHeader::FreeWideString(long aRef)
{
	FreeStringRef(aRef);
}

const wchar_t * SharedSessionHeader::GetWideString(long aRef)
{
	const char * bytes = GetBytes(aRef);
	return (const wchar_t *) bytes;
}

void SharedSessionHeader::AllocateExtraLargeWideString(long & arRef,
																											 const wchar_t * apStr)
{
	long firstSection = -1;

	LinkedString * previousLinkedString = NULL;

	// bytes left to store
	int remainingLength = wcslen(apStr) + 1;
	while (remainingLength > 0)
	{
		long ref;
		StringStruct<LARGE_STRING_MAX> * largeStr =
			mLargeStringPool.CreateElement(ref);


		if (!largeStr)
		{
			// whatever we've created so far should be consistent so
			// we can unwind it
			if (firstSection != -1)
				FreeExtraLargeWideString(firstSection);
			arRef = -1;
			return;
		}

		if (previousLinkedString)
		{
			// link the last chunk to this new chunk
			previousLinkedString->mNextPart = ref;
		}
		else
		{
			// must be the first section
			ASSERT(firstSection == -1);
			firstSection = ref;
		}

		LinkedString * linkedString = (LinkedString *) (char *) *largeStr;
		linkedString->mNextPart = -1;

		// number of bytes this chunk can hold
		const int sectionLength = LARGE_STRING_MAX - sizeof(long);

		if ((remainingLength * sizeof(wchar_t)) <= sectionLength)
		{
			// we can fit the rest of the string in here
			// the string will be null terminated
			wcscpy((wchar_t *) linkedString->mStr, apStr);
			remainingLength = 0;
		}
		else
		{
			// this won't be null terminated
			wcsncpy((wchar_t *) linkedString->mStr, apStr,
							sectionLength / sizeof(wchar_t));

			apStr += sectionLength / sizeof(wchar_t);
			remainingLength -= sectionLength / sizeof(wchar_t);
		}

		previousLinkedString = linkedString;
	}

	arRef = firstSection;
}

void SharedSessionHeader::FreeExtraLargeWideString(long aRef)
{
	// walk the sections and free each part
	long ref = aRef;
	while (ref != -1)
	{
		StringStruct<LARGE_STRING_MAX> * largeStr =
			mLargeStringPool.GetElement(ref);

		LinkedString * linkedString = (LinkedString *) (char *) *largeStr;
		long nextPart = linkedString->mNextPart;
		mLargeStringPool.DeleteElement(ref);

		ref = nextPart;
	}
}

wchar_t * SharedSessionHeader::CopyExtraLargeWideString(long aRef)
{
	// first walk the sections and calculate the lengths
	long ref = aRef;
	int length = 0;
	while (ref != -1)
	{
		StringStruct<LARGE_STRING_MAX> * largeStr =
			mLargeStringPool.GetElement(ref);

		LinkedString * linkedString = (LinkedString *) (char *) *largeStr;

		if (linkedString->mNextPart == -1)
			// add 1 for null termination
			length += wcslen((wchar_t *) linkedString->mStr) + 1;
		else
			// the whole section contributes
			length += (LARGE_STRING_MAX - sizeof(long)) / sizeof(wchar_t);

		ref = linkedString->mNextPart;
	}

	// allocate a buffer large enough to hold the value
	wchar_t * buffer = new wchar_t[length];

	// current pointer into the buffer
	wchar_t * bufferPtr = buffer;

	// now walk the links again and copy the data
	ref = aRef;
	while (ref != -1)
	{
		StringStruct<LARGE_STRING_MAX> * largeStr =
			mLargeStringPool.GetElement(ref);

		LinkedString * linkedString = (LinkedString *) (char *) *largeStr;

		if (linkedString->mNextPart == -1)
			// string will be null terminated
			wcscpy(bufferPtr, (wchar_t *) linkedString->mStr);
		else
		{
			wcsncpy(bufferPtr, (wchar_t *) linkedString->mStr,
							(LARGE_STRING_MAX - sizeof(long)) / sizeof(wchar_t));
			bufferPtr += (LARGE_STRING_MAX - sizeof(long)) / sizeof(wchar_t);
		}
		ref = linkedString->mNextPart;
	}

	return buffer;
}


const char * SharedSessionHeader::GetBytes(long aRef)
{
	if (aRef == -1)
		return NULL;								// only error check we do

	// TODO: no way of knowing if it's really valid or not

	long medStart = mSmallStringPool.GetSize();
	long largeStart = medStart + mMediumStringPool.GetSize();

	// small string ref number are 0 -> sizeof(small pool)
	if (aRef < medStart)
	{
		StringStruct<SMALL_STRING_MAX> * smallStr = mSmallStringPool.GetElement(aRef);
		if (!smallStr)
			return NULL;
		return *smallStr;
	}
	// medium string ref number are
	// sizeof(small pool) -> sizeof(small pool) + sizeof(medium pool)
	else if (aRef < largeStart)
	{
		StringStruct<MEDIUM_STRING_MAX> * medStr
			= mMediumStringPool.GetElement(aRef - medStart);
		if (!medStr)
			return NULL;
		return *medStr;
	}
	// large string ref number are
	// sizeof(small pool) + sizeof(medium pool) ->
	//       sizeof(small pool) + sizeof(medium pool) + sizeof(large pool)
	else
	{
		ASSERT(aRef < largeStart + mLargeStringPool.GetSize());

		StringStruct<LARGE_STRING_MAX> * largeStr
			= mLargeStringPool.GetElement(aRef - largeStart);
		if (!largeStr)
			return NULL;
		return *largeStr;
	}

	ASSERT(0);
	return NULL;
}

char * SharedSessionHeader::AllocateBytes(long aSize, long & arRef)
{
	long ref;

	if (aSize < 0)
		return NULL;								// no deal
	if (aSize <= SMALL_STRING_MAX)
	{
		StringStruct<SMALL_STRING_MAX> * smallStr = mSmallStringPool.CreateElement(ref);
		// small string ref number are 0 -> sizeof(small pool)
		arRef = ref;

		if (!smallStr)
			return NULL;
		return *smallStr;
	}

	if (aSize <= MEDIUM_STRING_MAX)
	{
		StringStruct<MEDIUM_STRING_MAX> * medStr = mMediumStringPool.CreateElement(ref);
		// medium string ref number are
		// sizeof(small pool) -> sizeof(small pool) + sizeof(medium pool)
		arRef = mSmallStringPool.GetSize() + ref;

		if (!medStr)
			return NULL;
		return *medStr;
	}

	if (aSize <= LARGE_STRING_MAX)
	{
		StringStruct<LARGE_STRING_MAX> * largeStr = mLargeStringPool.CreateElement(ref);
		// large string ref number are
		// sizeof(small pool) + sizeof(medium pool) ->
		//       sizeof(small pool) + sizeof(medium pool) + sizeof(large pool)

		arRef = mSmallStringPool.GetSize() + mMediumStringPool.GetSize() + ref;

		if (!largeStr)
			return NULL;
		return *largeStr;
	}

	return NULL;									// string is too big!  sorry
}

void SharedSessionHeader::FreeStringRef(long aRef)
{
	ASSERT(aRef >= 0);

	long medStart = mSmallStringPool.GetSize();
	long largeStart = medStart + mMediumStringPool.GetSize();

	if (aRef < medStart)
		mSmallStringPool.DeleteElement(aRef);
	else if (aRef < largeStart)
		mMediumStringPool.DeleteElement(aRef - medStart);
	else
	{
		ASSERT(aRef < largeStart + mLargeStringPool.GetSize());
		mLargeStringPool.DeleteElement(aRef - largeStart);
	}
}


SharedSessionHeader * SharedSessionHeader::ValidHeader(void * apMemStart)
{
	if (apMemStart != NULL)
	{
		SharedSessionHeader * header = (SharedSessionHeader *) apMemStart;
		if (header->mMagic == MAGIC)
			return header;
	}
	return NULL;
}







SharedSession * SharedSessionHeader::GetSession(long aSessionId) const
{
	SharedSession * session = mSessionPool.GetElement(aSessionId);
	// try to validate the ref count
	if (session && (session->GetRefCount() > 10000 || session->GetRefCount() < 0))
		return NULL;
	return session;
}

SharedSet * SharedSessionHeader::GetSet(long aSetId) const
{
	SharedSet * set = mSetPool.GetElement(aSetId);
	// try to validate the ref count
	if (set && (set->GetRefCount() > 10000 || set->GetRefCount() < 0))
		return NULL;
	return set;
}

SharedSetNode * SharedSessionHeader::GetSetNode(long aSetId) const
{
	return mSetNodePool.GetElement(aSetId);
}

SharedObjectOwner * SharedSessionHeader::GetObjectOwner(long aObjectOwner) const
{
	return mObjectOwnerPool.GetElement(aObjectOwner);
}

SharedObjectOwner * SharedSessionHeader::CreateObjectOwner(long & arRef)
{
	SharedObjectOwner * owner = mObjectOwnerPool.CreateElement(arRef);
	return owner;
}

SharedSet * SharedSessionHeader::CreateSet(long & arRef)
{
	SharedSet * set = mSetPool.CreateElement(arRef);
	return set;
}

SharedSetNode * SharedSessionHeader::CreateSetNode(long & arRef)
{
	SharedSetNode * node = mSetNodePool.CreateElement(arRef);

	return node;
}

SharedPropVal * SharedSessionHeader::CreateProperty(long & arRef)
{
	SharedPropVal * newProp = mPropPool.CreateElement(arRef);

	return newProp;
}

// create a session and return its reference number
// add it into the hash table as well
SharedSession * SharedSessionHeader::CreateSession(long & arRef,
																									 const unsigned char * apUID)
{
	long dupID;
	SharedSession * duplicate = SharedSession::FindWithUID(this, dupID, apUID);
	if (duplicate && dupID != -1)
	{
		// a session with the same ID already exists in shared memory.
		// don't create a second one.
		// TODO: returning NULL here will currently be interpreted as
		// "out of memory" because we have no other way of signalling a
		// different error.
		return NULL;
	}

	SharedSession * sess = mSessionPool.CreateElement(arRef);
	if (!sess)
		return NULL;								// out of space

	ASSERT(sess->GetSessionInfo() == SharedSession::FREE_SESSION);

	sess->SetCurrentState(SharedSession::NEWLY_CREATED);

	// add to hash table, only if this isn't a test session
	if (apUID != NULL)
	{
		int bucket = HashUID(apUID);

		BOOL acquired = LockBucket(bucket);
		ASSERT(acquired);
		// atomically insert into this bucket
		while (TRUE)
		{
			long next = mSessionLookup[bucket];
			ASSERT(next != arRef);
			sess->SetNextInBucket(next);

			long testValue = ::InterlockedCompareExchange(&mSessionLookup[bucket],
																										arRef, next);
			if (testValue == next)
				break;

			// the bucket didn't hold what we expected - try again
		}
		UnlockBucket(bucket);
	}
	sess->SetUID(apUID);

	return sess;
}

void SharedSessionHeader::ValidateChains()
{
	for (int i = 0; i < UID_BUCKETS; i++)
	{
		long nextId = mSessionLookup[i];
		int count = 0;
		while (nextId != -1)
		{
			SharedSession * current = GetSession(nextId);
			ASSERT(current->GetSessionInfo() != SharedSession::FREE_SESSION);

			long nextInBucket = current->GetNextInBucket();
			ASSERT(nextId != nextInBucket);
			nextId = nextInBucket;
			count++;
			ASSERT(count <= 10000);
		}
	}
}

void SharedSessionHeader::DeleteSession(long aRef)
{
	// NOTE: this doesn't delete the properties
	SharedSession * sess = GetSession(aRef);
	ASSERT(sess);

	if (sess->ObjectOwnerIsTemporary())
	{
		// the object owner ID is encoded.  If it's negative, it's a "temporary"
		// object owner that's owned by the session itself.  This is used in
		// cases where we need to generate a session outside of the context of
		// the pipeline.  We still need an object owner but the session has to clean
		// it up
		int objectOwnerID = sess->GetObjectOwnerID();
		SharedObjectOwner * owner = GetObjectOwner(objectOwnerID);
		owner->Release(this);
	}

	// delete from the hash table if this isn't a test session
	if (sess->GetUID() != NULL)
	{
		SharedSession * theSession;
		FindSession(sess->GetUID(), &theSession, TRUE);
		ASSERT(theSession == sess);
	}

#ifdef DEBUG
	// DEBUG only: trash the contents of the deleted session
	memset(sess, 0xFE, sizeof(SharedSession));
#endif


	sess->SetSessionInfo(SharedSession::FREE_SESSION);

	mSessionPool.DeleteElement(aRef);

	//ValidateChains();

//#ifdef DEBUG
	// DEBUG only: look for children that should have been deleted already
	// leaving children around like this leads to an inconsistent state
//	FindInvalidChildren(aRef);
//#endif


}


BOOL SharedSessionHeader::ReleaseChildScan(void * apArg, SharedSessionHeader * apHeader,
																					 SharedSession * apSession)
{
	long * parentId = (long *) apArg;
	if (apSession->GetParentID() == *parentId)
		apSession->Release(apHeader);

	// keep scanning
 	return TRUE;
}

void SharedSessionHeader::ReleaseChildren(long aParentId)
{
	AllSessions(ReleaseChildScan, &aParentId);
}


#ifdef DEBUG
BOOL SharedSessionHeader::InvalidChildScan(void * apArg, SharedSessionHeader * apHeader,
																					 SharedSession * apSession)
{
	long * parentId = (long *) apArg;
	if (apSession->GetParentID() == *parentId)
	{
		long thisId = apSession->GetSessionID(apHeader);
		ASSERT(0);
		return FALSE;
	}

	// keep scanning
 	return TRUE;
}

void SharedSessionHeader::FindInvalidChildren(long aParentId)
{
	AllSessions(InvalidChildScan, &aParentId);
}
#endif // DEBUG


void SharedSessionHeader::FindSession(const unsigned char * apUID,
																			SharedSession * * apSession)
{
	FindSession(apUID, apSession, FALSE);
}


BOOL SharedSessionHeader::LockBucket(int aBucket)
{
	// TODO: this currently waits forever

	// attempt to set the lock to 1, only if the value was 0
	while (::InterlockedCompareExchange(&mSessionLookupLocks[aBucket], 1, 0) != 0)
		// didn't get it - yield and then try again
		Sleep (0);

	return TRUE;
}

void SharedSessionHeader::UnlockBucket(int aBucket)
{
	// make sure we actually own the lock
	ASSERT(mSessionLookupLocks[aBucket] == 1);
	::InterlockedExchange(&mSessionLookupLocks[aBucket], 0);
}

void SharedSessionHeader::FindSession(const unsigned char * apUID,
																			SharedSession * * apSession,
																			BOOL aRemoveFromLookup)
{
	ASSERT(apUID != NULL);

	const int bucket = HashUID(apUID);
	BOOL acquired = LockBucket(bucket);
	// TODO: for now assume we get it
	ASSERT(acquired);

	SharedSession * prev = NULL;

	// now that we've locked the list we can traverse it
	long nextId = mSessionLookup[bucket];
	while (nextId != -1)
	{
		SharedSession * current = GetSession(nextId);
		ASSERT(current->GetSessionInfo() != SharedSession::FREE_SESSION);

		if (current->UIDEquals(apUID))
		{
			// found it.
			// remove it if necessary
			if (aRemoveFromLookup)
			{
				long next = current->GetNextInBucket();

				if (prev == NULL)
				{
					// first in the chain
					mSessionLookup[bucket] = next;
				}
				else
				{
#ifdef _DEBUG
					long nextid = prev->GetNextInBucket();
					SharedSession * testSess = GetSession(nextid);
					ASSERT(testSess == current);
#endif
					ASSERT(prev);
					prev->SetNextInBucket(next);
				}
			}

			*apSession = current;
			//ValidateChains();

			UnlockBucket(bucket);
			return;
		}
		prev = current;

		long nextInBucket = current->GetNextInBucket();
		ASSERT(nextId != nextInBucket);
		nextId = nextInBucket;
	}
	*apSession = NULL;

	//ValidateChains();
	UnlockBucket(bucket);
}


int SharedSessionHeader::HashUID(const unsigned char * apUID)
{
	// hashpjm from the Dragon Book
	unsigned h = 0, g;
	for (int i = 0; i < SharedSession::UID_LENGTH; i++)
	{
		h = (h << 4) + apUID[i];
		if (g = h & 0xF0000000)
		{
			h = h ^ (g >> 24);
			h = h ^ g;
		}
	}
	return h % UID_BUCKETS;
}


void SharedSessionHeader::AllSessions(AllSessionFunc apFunc, void * apArg)
{
	SharedSession * current = GetSessionStart();
	SharedSession * end = current + mSessionPool.GetSize();

	while (current < end)
	{
		if (current->GetSessionInfo() != SharedSession::FREE_SESSION)
		{
			if (!apFunc(apArg, this, current))
				break;
		}
		current++;
	}
}

void SharedSessionHeader::AllProperties(AllPropertyFunc apFunc, void * apArg)
{
	SharedPropVal * current = GetPropValStart();
	SharedPropVal * end = current + mPropPool.GetSize();

	while (current < end)
	{
		if (current->GetType() != SharedPropVal::FREE_PROPERTY)
		{
			if (!apFunc(apArg, this, current))
				break;
		}
		current++;
	}
}

int SharedSessionHeader::GetOwnerID()
{
	// generate a new ID
	return mNextOwnerID++;
}

void SharedSessionHeader::ReleaseOwnerID(int aID)
{
	// release everything related to this ID

	// TODO: release all sessions and sets with this ID
	// and then garbage collect.
}

long SharedSessionHeader::DeleteProp(long aPropId)
{
	SharedPropVal * prop = GetProperty(aPropId);
	long nextId = prop->GetNextProp();
	//prop->mType = SharedPropVal::FREE_PROPERTY;
	mPropPool.DeleteElement(aPropId);

	return nextId;
}

void SharedSessionHeader::DeleteSet(long aRef)
{
	mSetPool.DeleteElement(aRef);
}

void SharedSessionHeader::DeleteSetNode(long aRef)
{
	mSetNodePool.DeleteElement(aRef);
}

void SharedSessionHeader::DeleteObjectOwner(long aRef)
{
	mObjectOwnerPool.DeleteElement(aRef);
}


/************************************************* SharedSet ***/

SharedSet * SharedSet::Create(SharedSessionHeader * apHeader,
															long & arRef)
{
	SharedSet * set = apHeader->CreateSet(arRef);
	if (!set)
		return NULL;

	// no set members
	set->mFirstNode = -1;

	// a single reference - the one being returned
	set->mRefCount = 1;

	set->mCount = 0;

	// zero out the UID by default
	memset(set->mUID, 0x00, UID_LENGTH);
	return set;
}

int SharedSet::AddRef()
{
	return ::InterlockedIncrement((long *) &mRefCount);
}

int SharedSet::Release(SharedSessionHeader * apHeader)
{
	ASSERT(mRefCount > 0);
	long count = ::InterlockedDecrement((long *) &mRefCount);
	if (mRefCount == 0)
		Delete(apHeader);
	return count;
}

int SharedSet::GetRefCount() const
{
	return mRefCount;
}

void SharedSet::Delete(SharedSessionHeader * apHeader)
{
	long nextOffset = mFirstNode;

	// delete the chain of nodes
	while (nextOffset != -1)
	{
		SharedSetNode * node = apHeader->GetSetNode(nextOffset);
		ASSERT(node);

		nextOffset = node->mNextNode;

		node->Delete(apHeader);
	}

	// for debugging - make a deleted set easier to recognize
	mRefCount = -1;
	apHeader->DeleteSet(GetSetID(apHeader));
}

const SharedSetNode * SharedSet::AddToSet(SharedSessionHeader * apHeader,
																					long aSessionID)
{
	long id;
	SharedSetNode * node = apHeader->CreateSetNode(id);
	if (!node)
		return NULL;

	// insert into the set
	node->mNextNode = mFirstNode;
	mFirstNode = id;

	// pass the session into the newly created node.
	// this will also addref to the session
	SharedSession * sess = apHeader->GetSession(aSessionID);
	ASSERT(sess);
	node->SetSession(aSessionID, sess);

	// keep track of the count
	mCount++;

	return node;
}

const SharedSetNode * SharedSet::First(SharedSessionHeader * apHeader) const
{
	long nextOffset = mFirstNode;
	if (nextOffset == -1)
		return NULL;
	return apHeader->GetSetNode(nextOffset);
}


// get the UID of this set
const unsigned char * SharedSet::GetUID() const
{
	// length of array is UID_LENGTH
	for (int i = 0; i < UID_LENGTH; i++)
		if (mUID[i] != 0)
			return mUID;							// it's a valid UID			

	return NULL;									// all bytes 0 - empty UID
}

// set the UID of this set
void SharedSet::SetUID(const unsigned char * apUID)
{
	// length of array is UID_LENGTH
	if (apUID == NULL)
		memset(mUID, 0, UID_LENGTH); // all 0's in a UID is illegal
	else
		memcpy(mUID, apUID, UID_LENGTH);
}

// return TRUE if UIDs compare equal
BOOL SharedSet::UIDEquals(const unsigned char * apUID) const
{
	return 0 == memcmp(GetUID(), apUID, UID_LENGTH);
}

int SharedSet::GetCount() const
{
	return mCount;
}

/********************************************* SharedSetNode ***/

void SharedSetNode::SetSession(long aSessionID, SharedSession * apSession)
{
	ASSERT(apSession);
	apSession->AddRef();
	mID = aSessionID;
}


const SharedSetNode * SharedSetNode::Next(SharedSessionHeader * apHeader) const
{
	long nextOffset = mNextNode;
	if (nextOffset == -1)
		return NULL;
	return apHeader->GetSetNode(nextOffset);
}

void SharedSetNode::Delete(SharedSessionHeader * apHeader)
{
	SharedSession * sess = apHeader->GetSession(mID);
	ASSERT(sess);

	// release the session
	sess->Release(apHeader);

	// delete ourself
	apHeader->DeleteSetNode(GetSetNodeID(apHeader));
}


/********************************************* SharedPropVal ***/

void SharedPropVal::Init(long aNameId)
{
	mType = FREE_PROPERTY;
	mNameID = aNameId;
}

void SharedPropVal::Clear(SharedSessionHeader * apHeader)
{
	if (mType == ASCII_PROPERTY)
		apHeader->FreeString(mStringValID);
	else if (mType == UNICODE_PROPERTY)
		apHeader->FreeString(mStringValID);
	else if (mType == EXTRA_LARGE_STRING_PROPERTY)
		apHeader->FreeExtraLargeWideString(mStringValID);
	else if (mType == OBJECT_PROPERTY)
		ClearObjectVal();

	SetFreeValue();
}

void SharedPropVal::ClearObjectVal()
{
	ASSERT(mType == OBJECT_PROPERTY);

	if (mObjectVal.mpInterface != NULL)
	{
		long pid = ::GetCurrentProcessId();
		// only release the pointer if it was created in the same process ID.
		// this isn't guaranteed to be safe but it's safer
		if (pid == mObjectVal.mProcessID)
			mObjectVal.mpInterface->Release();
		mObjectVal.mpInterface = NULL;
	}
}

void SharedPropVal::SetDoubleValue(double aDoubleVal)
{
	mType = DOUBLE_PROPERTY;
	mDoubleVal = aDoubleVal;
}

double SharedPropVal::GetDoubleValue() const
{
	ASSERT(mType == DOUBLE_PROPERTY);
	return mDoubleVal;
}

void SharedPropVal::SetLongValue(long aLongVal)
{
	mType = LONG_PROPERTY;
	mLongVal = aLongVal;
}

long SharedPropVal::GetLongValue() const
{
	ASSERT(mType == LONG_PROPERTY);
	return mLongVal;
}

void SharedPropVal::SetOLEDateValue(double aDateProp)
{
	mType = OLEDATE_PROPERTY;
	mDoubleVal = aDateProp;
}

double SharedPropVal::GetOLEDateValue() const
{
	ASSERT(mType == OLEDATE_PROPERTY);
	return mDoubleVal;
}

void SharedPropVal::SetDateTimeValue(time_t aDateTime)
{
	mType = TIMET_PROPERTY;
	mTimeVal = aDateTime;
}

time_t SharedPropVal::GetDateTimeValue() const
{
	ASSERT(mType == TIMET_PROPERTY);
	return mTimeVal;
}

void SharedPropVal::SetTimeValue(long aTime)
{
	mType = TIME_PROPERTY;
	mLongVal = aTime;
}

long SharedPropVal::GetTimeValue() const
{
	ASSERT(mType == TIME_PROPERTY);
	return mLongVal;
}

void SharedPropVal::SetAsciiIDValue(int aID)
{
	mType = ASCII_PROPERTY;
	mLongVal = aID;
}

int SharedPropVal::GetAsciiIDValue() const
{
	ASSERT(mType == ASCII_PROPERTY);
	return mLongVal;
}

void SharedPropVal::SetUnicodeIDValue(int aID)
{
	mType = UNICODE_PROPERTY;
	mLongVal = aID;
}

int SharedPropVal::GetUnicodeIDValue() const
{
	ASSERT(mType == UNICODE_PROPERTY);
	return mLongVal;
}

void SharedPropVal::SetBooleanValue(BOOL aProp)
{
	mType = BOOL_PROPERTY;
	mBoolVal = aProp;
}

BOOL SharedPropVal::GetBooleanValue() const
{
	ASSERT(mType == BOOL_PROPERTY);
	return mBoolVal;
}

void SharedPropVal::SetEnumValue(long aEnumVal)
{
	mType = ENUM_PROPERTY;
	mEnumVal = aEnumVal;
}

long SharedPropVal::GetEnumValue() const
{
	ASSERT(mType == ENUM_PROPERTY);
	return mEnumVal;
}

void SharedPropVal::SetDecimalValue(const unsigned char * apDecimalVal)
{
	mType = DECIMAL_PROPERTY;
	memcpy(mDecimalVal, apDecimalVal, sizeof(mDecimalVal));
}

const unsigned char * SharedPropVal::GetDecimalValue() const
{
	ASSERT(mType == DECIMAL_PROPERTY);
	return mDecimalVal;
}

void SharedPropVal::SetTinyStringValue(const wchar_t * apStr)
{
	mType = TINYSTRING_PROPERTY;
	ASSERT(wcslen(apStr) < SharedSessionHeader::TINY_STRING_MAX / 2);
	wcscpy(mTinyString, apStr);
}

const wchar_t * SharedPropVal::GetTinyStringValue() const
{
	ASSERT(mType == TINYSTRING_PROPERTY);
	return mTinyString;
}

BOOL SharedPropVal::SetExtraLargeStringValue(SharedSessionHeader * apHeader,
																						 const wchar_t * apStr)
{
	mType = EXTRA_LARGE_STRING_PROPERTY;
	apHeader->AllocateExtraLargeWideString(mStringValID, apStr);
	return mStringValID != -1;
}

wchar_t * SharedPropVal::CopyExtraLargeStringValue(
	SharedSessionHeader * apHeader) const
{
	return apHeader->CopyExtraLargeWideString(mStringValID);
}

void SharedPropVal::SetObjectValue(IUnknown * apProp)
{
	// NOTE: NULL is allowable as an argument
	mType = OBJECT_PROPERTY;
	mObjectVal.mpInterface = apProp;
	if (apProp)
	{
		// mark the process ID if we're setting the object
		// to a non-null pointer
		mObjectVal.mProcessID = ::GetCurrentProcessId();
		mObjectVal.mpInterface->AddRef();
	}
}

void SharedPropVal::GetObjectValue(IUnknown * * apVal) const
{
	ASSERT(mType == OBJECT_PROPERTY);
	if (mObjectVal.mpInterface)
	{
		long pid = ::GetCurrentProcessId();
		if (pid == mObjectVal.mProcessID)
		{
			*apVal = mObjectVal.mpInterface;
			(*apVal)->AddRef();
		}
		else
		{
			// the value was set from a different process!
			ASSERT(0);
			*apVal = NULL;
		}
	}
	else
		*apVal = NULL;
}

void SharedPropVal::SetLongLongValue(__int64 aLongLongVal)
{
	mType = LONGLONG_PROPERTY;
	mLongLongVal = aLongLongVal;
}

__int64 SharedPropVal::GetLongLongValue() const
{
	ASSERT(mType == LONGLONG_PROPERTY);
	return mLongLongVal;
}

// TODO: this does a shallow copy of string values
void SharedPropVal::CopyValue(const SharedPropVal * apOrig)
{
	//propVal->mType = apOrig->GetType();

	switch(apOrig->GetType())
	{
	case SharedPropVal::OLEDATE_PROPERTY:
		SetOLEDateValue(apOrig->GetOLEDateValue());
		break;

	case SharedPropVal::DOUBLE_PROPERTY:
		SetDoubleValue(apOrig->GetDoubleValue());
		break;

	case SharedPropVal::TIMET_PROPERTY:
		SetDateTimeValue(apOrig->GetDateTimeValue());
		break;

	case SharedPropVal::TIME_PROPERTY:
		SetTimeValue(apOrig->GetTimeValue());
		break;

	case SharedPropVal::LONG_PROPERTY:
		SetLongValue(apOrig->mLongVal);
		break;

	case SharedPropVal::ASCII_PROPERTY:
		SetAsciiIDValue(apOrig->GetAsciiIDValue());
		break;

	case SharedPropVal::UNICODE_PROPERTY:
		SetUnicodeIDValue(apOrig->GetUnicodeIDValue());
		break;

	case SharedPropVal::BOOL_PROPERTY:
		SetBooleanValue(apOrig->GetBooleanValue());
		break;

	case SharedPropVal::ENUM_PROPERTY:
		SetEnumValue(apOrig->GetEnumValue());
		break;

	case SharedPropVal::LONGLONG_PROPERTY:
		SetLongLongValue(apOrig->mLongLongVal);
		break;

	case SharedPropVal::FREE_PROPERTY:
	default:
		ASSERT(0);
	}
}

/********************************************* SharedSession ***/


/*
 * creation/deletion methods
 */

SharedSession * SharedSession::Create(SharedSessionHeader * apHeader, long & arRef,
																			const unsigned char * apUID,
																			const unsigned char * apParentUID
																			/* long aOwnerID */)
{
	long parentId;
	if (apParentUID != NULL)
	{
		SharedSession * parent = FindWithUID(apHeader, parentId, apParentUID);
		// for now, parent MUST already exist
		ASSERT(parent && parentId != -1);
	}
	else
		parentId = -1;

	SharedSession * returnSess = CreateInternal(apHeader, arRef, apUID, parentId);

	return returnSess;
}

SharedSession * SharedSession::Create(SharedSessionHeader * apHeader,
																			long & arRef,
																			const unsigned char * apUID,
																			long aParentId
																			/* long aOwnerID */)
{
	SharedSession * returnSess = CreateInternal(apHeader, arRef, apUID, aParentId);
	return returnSess;
}


SharedSession * SharedSession::CreateInternal(SharedSessionHeader * apHeader,
																							long & arRef,
																							const unsigned char * apUID,
																							long aParentId
																							/* long aOwnerID */)
{
	SharedSession * sess = apHeader->CreateSession(arRef, apUID);
	if (!sess)
		return NULL;

	// currently unlocked
	// TODO: should it start out as locked?
	sess->mSessionInfo = UNLOCKED_SESSION;
	sess->mParentID = aParentId;
	sess->mChildSet = -1;

	// currently nothing watching this session
	sess->mObjectOwnerID = -1;

	// currently one reference
	sess->mRefCount = 1;

	// no events to wait for
	sess->mEventMask = NO_EVENTS;

	// no properties
	for (int i = 0; i < HASH_BUCKETS; i++)
		sess->mFirstProperty[i] = -1;


	if (aParentId != -1)
	{
		SharedSession * parent = apHeader->GetSession(aParentId);
		if (!parent)
			return NULL;							// sorry - parent doesn't exist

		if (!parent->AddChild(apHeader, arRef))
		{
			// unable to add the child!  delete the session
			sess->Delete(apHeader);
			return NULL;
		}
	}

	return sess;
}

int SharedSession::AddRef()
{
	long count = ::InterlockedIncrement((long *) &mRefCount);
	return count;
}

int SharedSession::Release(SharedSessionHeader * apHeader)
{
	ASSERT(mRefCount > 0);

	long count = ::InterlockedDecrement((long *) &mRefCount);
	if (count == 0)
		Delete(apHeader);

	return count;
}


void SharedSession::DeleteForcefully(SharedSessionHeader * apHeader)
{
	// NOTE: this ignores the reference count.  use with caution!
	Delete(apHeader);
}

int SharedSession::GetRefCount() const
{
	return mRefCount;
}

void SharedSession::Delete(SharedSessionHeader * apHeader)
{
	DeleteProps(apHeader);

	if (mChildSet != -1)
	{
		// release our reference to the set of children
		SharedSet * childSet = apHeader->GetSet(mChildSet);
		childSet->Release(apHeader);
	}
	apHeader->DeleteSession(GetSessionID(apHeader));
}

SharedSession * SharedSession::FindWithUID(SharedSessionHeader * apHeader,
																					 long & arRef, const unsigned char * apUID)
{
	ASSERT(apUID);
	SharedSession * sess;
	apHeader->FindSession(apUID, &sess);
	if (!sess)
		return NULL;								// doesn't exist

	ASSERT(sess->UIDEquals(apUID));

	arRef = sess->GetSessionID(apHeader);
	return sess;
}


/*
 * property methods
 */

void SharedSession::DeleteProps(SharedSessionHeader * apHeader)
{
	// delete all properties
	for (int i = 0; i < HASH_BUCKETS; i++)
	{
		int propId = mFirstProperty[i];

		// unlink them all from the list
		while (propId != -1)
		{
			SharedPropVal * propVal = apHeader->GetProperty(propId);
			ASSERT(propVal);
			propVal->Clear(apHeader);
			propId = apHeader->DeleteProp(propId);
		}

		// empty the hash table
		mFirstProperty[i] = -1;
	}
}


void SharedSession::NextProp(const SharedSessionHeader * apHeader,
														 const SharedPropVal * * apProp,
														 int * apHashBucket) const
{
	for (/* */; *apHashBucket < HASH_BUCKETS;
			 (*apHashBucket)++)
	{
		long propId = mFirstProperty[*apHashBucket];
		if (propId != -1)
		{
			*apProp = apHeader->GetProperty(propId);
			// Get the all the apProps
			return;
		}
	}
	*apProp = NULL;
	*apHashBucket = -1;
}

// enumerate through properties
void SharedSession::GetProps(const SharedSessionHeader * apHeader,
														 const SharedPropVal * * apFirst,
														 int * apHashBucket) const
{
	ASSERT(apFirst != NULL && apHashBucket != NULL);

	// find the first bucket with a property in it, and
	// return the prop and the bucket
	*apHashBucket = 0;

	NextProp(apHeader, apFirst, apHashBucket);
}


void SharedSession::GetNextProp(const SharedSessionHeader * apHeader,
																const SharedPropVal * * apProp,
																int * apHashBucket) const
{
	if (*apProp == NULL)
		return;											// at end of list

	long propId = (*apProp)->GetNextProp();
	if (propId != -1)
	{
		*apProp = apHeader->GetProperty(propId);
		return;
	}

	// find next bucket that has a property
	(*apHashBucket)++;

	NextProp(apHeader, apProp, apHashBucket);
}


// debugging only
#include <iostream>

using std::cout;
using std::endl;

void SharedSession::DumpSession(SharedSessionHeader * apHeader)
{
	cout << "Session " << GetSessionID(apHeader) << " service " << GetServiceID() << endl;
	const SharedPropVal * propVal = NULL;
	//GetProps(apHeader, &propVal, &hashBucket);
	for (int i = 0; i < HASH_BUCKETS; i++)
	{
		cout << "hash bucket " << i << endl;

		long propId = mFirstProperty[i];
		while (propId != -1)
		{
			propVal = apHeader->GetProperty(propId);

			cout << " Prop " << propVal->GetNameID();

			SharedPropVal::Type type = propVal->GetType();
			switch (type)
			{
			case SharedPropVal::OLEDATE_PROPERTY:
				cout << " OLEDATE_PROPERTY"; break;
			case SharedPropVal::TIMET_PROPERTY:
				cout << " TIMET_PROPERTY"; break;
			case SharedPropVal::TIME_PROPERTY:
				cout << " TIME_PROPERTY"; break;
			case SharedPropVal::ASCII_PROPERTY:
				cout << " ASCII_PROPERTY"; break;
			case SharedPropVal::UNICODE_PROPERTY:
				cout << " UNICODE_PROPERTY"; break;
			case SharedPropVal::LONG_PROPERTY:
				cout << " LONG_PROPERTY"; break;
			case SharedPropVal::DOUBLE_PROPERTY:
				cout << " DOUBLE_PROPERTY"; break;
			case SharedPropVal::BOOL_PROPERTY:
				cout << " BOOL_PROPERTY"; break;
			case SharedPropVal::LONGLONG_PROPERTY:
				cout << " LONGLONG_PROPERTY"; break;
			default:
				cout << " *UNKNOWN*"; break;
			}
			cout << endl;

			propId = propVal->GetNextProp();
		}
	}
}


SharedPropVal *
SharedSession::GetPropertyWithID(SharedSessionHeader * apHeader,
																 long aNameId) const
{
	// search the hash table
 	int hash = HashKey(aNameId);
	long propId = mFirstProperty[hash];
	while (propId != -1)
	{
		SharedPropVal * prop = apHeader->GetProperty(propId);
		if (prop->GetNameID() == aNameId)
			return prop;

		propId = prop->GetNextProp();
	}
	return NULL;
}



//
// NOTE: GetWriteablePropertyWithID and GetReadablePropertyWithID
//       are now the same.  They're kept separate though
//       in case they have different implementations in the future.
//
SharedPropVal *
SharedSession::GetWriteablePropertyWithID(SharedSessionHeader * apHeader,
																				 long aNameId) const
{
	SharedPropVal * val = GetPropertyWithID(apHeader, aNameId);
	return val;
}

const SharedPropVal *
SharedSession::GetReadablePropertyWithID(SharedSessionHeader * apHeader,
																				 long aNameId) const
{
	SharedPropVal * val = GetPropertyWithID(apHeader, aNameId);
	return val;
}



SharedPropVal *
SharedSession::AddProperty(SharedSessionHeader * apHeader,
													 long & arRef, long aNameId)
{
	SharedPropVal * newProp = apHeader->CreateProperty(arRef);
	if (!newProp)
		return NULL;

	newProp->Init(aNameId);

	ASSERT(aNameId>0);
	//newProp->mNameID = aNameId;
	//newProp->mCopyOnWrite = aCopyOnWrite;
	//newProp->mOriginalCopy = -1;

	//
	// link into the property hash table
	//
	int hash = HashKey(aNameId);

	newProp->SetNextProp(mFirstProperty[hash]);
	mFirstProperty[hash] = arRef;

	return newProp;
}

/*
 * accessors/mutators
 */

void SharedSession::MarkComplete(SharedSessionHeader * apHeader,
																 BOOL & arGroupComplete)
{
///
#if 0
	// TODO: could add signalling to this call
	if (mParentID != -1)
	{
		SharedSession * parent = apHeader->GetSession(mParentID);
		arOutstandingChildren = parent->DecreaseOutstandingChildren();
	}
	else
	{
		// session has no parent, so set OutstandingChildren to 0
		arOutstandingChildren = 0;
	}
#else
	int ownerid = GetObjectOwnerID();
	if (ownerid != -1)
	{
		SharedObjectOwner * owner = apHeader->GetObjectOwner(ownerid);
		ASSERT(owner);
		arGroupComplete = owner->DecrementWaitingCount();
	}
	else
		arGroupComplete = FALSE;
#endif
}

void SharedSession::MarkRootAsFailed(SharedSessionHeader * apHeader)
{
	if (mParentID == -1)
	{
		SetCurrentState(MARKED_AS_FAILED);
		// also flag this at at the object owner level
		int ownerid = GetObjectOwnerID();
		if (ownerid != -1)
		{
			SharedObjectOwner * owner = apHeader->GetObjectOwner(ownerid);
			ASSERT(owner);
			owner->FlagError();
		}
	}
	else
	{
		// recurse up the tree
		SharedSession * parent = apHeader->GetSession(mParentID);
		ASSERT(parent);
		parent->MarkRootAsFailed(apHeader);
	}
}


long SharedSession::GetNextFree() const
{
	return mNextFree;
}

void SharedSession::SetNextFree(long aNext)
{
	mNextFree = aNext;
}

long SharedSession::GetSessionID(SharedSessionHeader * apHeader) const
{
	return this - apHeader->GetSessionStart();
}

	// get the service ID of this session
long SharedSession::GetServiceID() const
{
	return mServiceID;
}

// SharedSession::set the service ID of the current service
void SharedSession::SetServiceID(long aService)
{
	mServiceID = aService;
}

// get the database ID of this session
long SharedSession::GetRealID() const
{
	return mRealID;
}

// set the database ID of this session
void SharedSession::SetRealID(long aRealID)
{
	mRealID = aRealID;
}

long SharedSession::GetObjectOwnerID() const
{
	// the object owner ID is encoded.  If it's negative, it's a "temporary"
	// object owner that's owned by the session itself.  This is used in
	// cases where we need to generate a session outside of the context of
	// the pipeline.  We still need an object owner but the session has to clean
	// it up

	if (mObjectOwnerID < -1)
		// for example, 0 is encoded as -2, 1 as -3, ...
		return (- mObjectOwnerID) - 2;
	else
		return mObjectOwnerID;
}

void SharedSession::SetObjectOwnerID(long aID)
{
	// the object owner ID is encoded.  If it's negative, it's a "temporary"
	// object owner that's owned by the session itself.  This is used in
	// cases where we need to generate a session outside of the context of
	// the pipeline.  We still need an object owner but the session has to clean
	// it up
	// for example, 0 is encoded as -2, 1 as -3, ...
	mObjectOwnerID = aID;
}

BOOL SharedSession::ObjectOwnerIsTemporary() const
{
	return (mObjectOwnerID < -1);
}

// get the UID of this session
const unsigned char * SharedSession::GetUID() const
{
	// TODO: it sucks we have to validate the UID this way all the time.  is there a
	// better way?  maybe a test session flag?

	// length of array is UID_LENGTH
	for (int i = 0; i < UID_LENGTH; i++)
		if (mUID[i] != 0)
			return mUID;							// it's a valid UID			

	return NULL;									// all bytes 0 - empty UID
}

// set the UID of this session
void SharedSession::SetUID(const unsigned char * apUID)
{
	// length of array is UID_LENGTH
	if (apUID == NULL)
		memset(mUID, 0, UID_LENGTH); // all 0's in a UID is illegal
	else
		memcpy(mUID, apUID, UID_LENGTH);
}


BOOL SharedSession::UIDEquals(const unsigned char * apUID) const
{
	return 0 == memcmp(GetUID(), apUID, UID_LENGTH);
}


void SharedSession::SetParentID(SharedSessionHeader * apHeader, long parentID)
{
  ASSERT(mParentID == -1);
  // Get my index
  long thisID = GetSessionID(apHeader);
  // Find the parent so that we can add this to the child set
  SharedSession * parent = apHeader->GetSession(parentID);
  ASSERT(parent != NULL);
  parent->AddChild(apHeader, thisID);
  mParentID = parentID;
}

// get the parent ID of this session
long SharedSession::GetParentID() const
{
	return mParentID;
}

// get the session's state/info flags
long SharedSession::GetSessionInfo() const
{
	return mSessionInfo;
}

// set the session's state/info flags
void SharedSession::SetSessionInfo(long aSessionInfo)
{
	mSessionInfo = aSessionInfo;
}

// set the next session in this bucket (used for hash lookups)
void SharedSession::SetNextInBucket(long aNext)
{
	mNextInBucket = aNext;
}

// get the next session in this bucket (used for hash lookups)
long SharedSession::GetNextInBucket() const
{
	return mNextInBucket;
}

// return TRUE if this session is a parent session
BOOL SharedSession::IsParent() const
{
	return mChildSet != -1;
}

// return session set ID of the set that holds the children
long SharedSession::GetChildSetID() const
{
	return mChildSet;
}

// add a child to this session
BOOL SharedSession::AddChild(SharedSessionHeader * apHeader,
														 long aChildID)
{
	SharedSet * childSet;
	if (mChildSet == -1)
	{
		// first child
		childSet = SharedSet::Create(apHeader, mChildSet);
		if (childSet == NULL)
			return FALSE;
	}
	else
	{
		childSet = apHeader->GetSet(mChildSet);
		if (!childSet)
			return FALSE;
	}

	childSet->AddToSet(apHeader, aChildID);

	return TRUE;
}


SharedSession::SessionState SharedSession::GetCurrentState() const
{
	return mState;
}

// retrieve the current state of the session
void SharedSession::SetCurrentState(SessionState aState)
{
	mState = aState;
}

// retrieve the current state of the session
int SharedSession::GetCurrentOwnerStage() const
{
	return mCurrentStage;
}

void SharedSession::SetCurrentOwnerStage(int aStageID)
{
	mCurrentStage = aStageID;
}

void SharedSession::AddEvents(int aEventCodes)
{
	mEventMask |= aEventCodes;
}

void SharedSession::RemoveEvents(int aEventCodes)
{
	mEventMask &= ~aEventCodes;
}

BOOL SharedSession::TestForEvents(int aMask) const
{
	return ((mEventMask & aMask) == aMask);
}

int SharedSession::GetAllEvents() const
{
	return mEventMask;
}

int SharedSession::HashKey(long aNameId)
{
	return aNameId % HASH_BUCKETS;
}

/***************************************** SharedObjectOwner ***/

SharedObjectOwner * SharedObjectOwner::Create(SharedSessionHeader * apHeader)
{
	long id;
	SharedObjectOwner * owner = apHeader->CreateObjectOwner(id);
	if (!owner)
		return NULL;
	owner->mRefCount = 1;
	owner->mErrorFlag = FALSE;
	owner->mTransaction.mpTransaction = NULL;
	owner->mTransaction.mProcessID = -1;
	owner->mTransaction.mTransactionID = -1;

	owner->mRSIDCache.mProcessID  = -1;
	owner->mRSIDCache.mpRSIDCache = NULL;

	owner->mSessionContext.mpSessionContext = NULL;
	owner->mSessionContext.mProcessID = -1;
	owner->mSessionContext.mSerializedContextID = -1;
	owner->mSessionContext.mUsernameID = -1;
	owner->mSessionContext.mPasswordID = -1;
	owner->mSessionContext.mNamespaceID = -1;

	owner->mNextObjectOwnerID = -1;
	owner->mActionType = OBJECT_OWNER_NO_ACTION;

  owner->mLock.mpCriticalSection = 0;
  owner->mLock.mProcessID = -1;

	return owner;
}


void SharedObjectOwner::InitForNotifyStage(int aTotalCount, int aOwnerStage)
{
	mActionType = OBJECT_OWNER_NOTIFY_STAGE;
	mTotalCount = mWaitingCount = aTotalCount;
	mOwnerStage = aOwnerStage;
	mErrorFlag = FALSE;
	mNextObjectOwnerID = -1;
}

void SharedObjectOwner::InitForSendFeedback(SharedSessionHeader * apHeader,
																						int aTotalCount, int aSetID)
{
	mActionType = OBJECT_OWNER_SEND_FEEDBACK;
	mTotalCount = mWaitingCount = aTotalCount;

	// we hold a reference so bump the count
	mFeedbackOnSessionSet = aSetID;

	SharedSet * set = apHeader->GetSet(aSetID);
	(void) set->AddRef();

	mErrorFlag = FALSE;
	mNextObjectOwnerID = -1;
}

void SharedObjectOwner::InitForCompleteProcessing(SharedSessionHeader * apHeader,
																									int aTotalCount, int aSessionSetID)
{
	mActionType = OBJECT_OWNER_COMPLETE_PROCESSING;
	mTotalCount = mWaitingCount = aTotalCount;
	mFeedbackOnSessionSet = aSessionSetID;

	SharedSet * set = apHeader->GetSet(aSessionSetID);
	(void) set->AddRef();

	mErrorFlag = FALSE;
	mNextObjectOwnerID = -1;
}

BOOL SharedObjectOwner::DecrementWaitingCount()
{
	ASSERT(mWaitingCount > 0);

	long count = ::InterlockedDecrement((long *) &mWaitingCount);
	return count == 0;
}

long SharedObjectOwner::GetOwnerStageID() const
{
	ASSERT(mActionType == OBJECT_OWNER_NOTIFY_STAGE);
	return mOwnerStage;
}

long SharedObjectOwner::GetSessionSetID() const
{
	ASSERT(mActionType == OBJECT_OWNER_SEND_FEEDBACK
				 || mActionType == OBJECT_OWNER_COMPLETE_PROCESSING);
	return mFeedbackOnSessionSet;
}

void SharedObjectOwner::SetNextObjectOwnerID(SharedSessionHeader * apHeader, int aNext)
{
	SharedObjectOwner * nextOwner = apHeader->GetObjectOwner(aNext);
	// we now hold a reference to this
	nextOwner->AddRef();
	mNextObjectOwnerID = aNext;
}

void SharedObjectOwner::FlagError()
{
	mErrorFlag = TRUE;
}

BOOL SharedObjectOwner::GetErrorFlag() const
{
	return mErrorFlag;
}

BOOL SharedObjectOwner::SetTransaction(IUnknown * apTran)
{
	if (mTransaction.mpTransaction)
	{
		mTransaction.mpTransaction->Release();
		mTransaction.mpTransaction = NULL;
		mTransaction.mProcessID = -1;
	}

	long testValue = ::InterlockedCompareExchange((long *) &mTransaction.mpTransaction,
																								(long) apTran, 0);
	if (testValue != 0)
		// the pointer has already been set
		// this isn't allowed unless the transaction is being cleared
		return FALSE;

	// transaction can be set to NULL
	if (apTran)
	{
		apTran->AddRef();							// we now hold a reference
		mTransaction.mProcessID = ::GetCurrentProcessId();
	}
	else
		mTransaction.mProcessID = -1;
	return TRUE;
}

void SharedObjectOwner::GetTransaction(IUnknown * * apTran) const
{
	if (mTransaction.mProcessID == -1)
	{
		// must be null or something's wrong
		*apTran = NULL;

	}
	else
	{
		// NOTE: this isn't perfect, but it can help us avoid calling addref
		// on a transaction from another process
		if (mTransaction.mProcessID != ::GetCurrentProcessId())
			*apTran = NULL;
		else
		{
			*apTran = mTransaction.mpTransaction;
			if (*apTran)
				(*apTran)->AddRef();
		}
	}

}

BOOL SharedObjectOwner::SetTransactionID(SharedSessionHeader * apHeader, const char * apTransactionID)
{
	// the id has already been set
	if (mTransaction.mTransactionID != -1)
		return false; 

	if (!apHeader->AllocateString(apTransactionID, mTransaction.mTransactionID))
		return false;

	return true;
}

const char * SharedObjectOwner::GetTransactionID(SharedSessionHeader * apHeader) const
{
	// the id hasn't been set yet
	if (mTransaction.mTransactionID == -1)
		return NULL;

	return apHeader->GetString(mTransaction.mTransactionID);
}

BOOL SharedObjectOwner::SetSessionContext(IUnknown * apContext)
{
	if (mSessionContext.mpSessionContext)
	{
		mSessionContext.mpSessionContext->Release();
		mSessionContext.mpSessionContext = NULL;
	}

	long testValue = ::InterlockedCompareExchange(
		(long *) &mSessionContext.mpSessionContext,
		(long) apContext, 0);
	if (testValue != 0)
		// the pointer has already been set
		// this isn't allowed unless the transaction is being cleared
		return FALSE;
	if (apContext)
	{
		apContext->AddRef();							// we now hold a reference
		mSessionContext.mProcessID = ::GetCurrentProcessId();
	}
	else
		mSessionContext.mProcessID = -1;
	return TRUE;
}

void SharedObjectOwner::GetSessionContext(IUnknown * * apContext) const
{
	if (mSessionContext.mProcessID == -1)
	{
		// must be null or something's wrong
		*apContext = NULL;
	}
	else
	{
		// NOTE: this isn't perfect, but it can help us avoid calling addref
		// on a sessioncontext from another process
		if (mSessionContext.mProcessID != ::GetCurrentProcessId())
			*apContext = NULL;
		else
		{
			*apContext = mSessionContext.mpSessionContext;
			if (*apContext)
				(*apContext)->AddRef();
		}
	}
}


BOOL SharedObjectOwner::SetSerializedSessionContext(
	SharedSessionHeader * apHeader, const wchar_t * apContext)
{
	mSessionContext.mSerializedContextID = -1;
	apHeader->AllocateExtraLargeWideString(
		mSessionContext.mSerializedContextID, apContext);
	return mSessionContext.mSerializedContextID != -1;
}

BOOL SharedObjectOwner::IsSerializedSessionContextSet()
{
	return (mSessionContext.mSerializedContextID != -1);
}

wchar_t * SharedObjectOwner::CopySerializedSessionContext(
	SharedSessionHeader * apHeader) const
{
	if (mSessionContext.mSerializedContextID == -1)
		return NULL;
	return apHeader->CopyExtraLargeWideString(
		mSessionContext.mSerializedContextID);
}

BOOL SharedObjectOwner::SetSessionContextCredentials(
	SharedSessionHeader * apHeader,
	const char * apUsername, const char * apPassword, const char * apNamespace)
{
	if (mSessionContext.mUsernameID != -1
			|| mSessionContext.mPasswordID != -1
			|| mSessionContext.mNamespaceID != -1)
		// already set
		return FALSE; 

	if (!apHeader->AllocateString(apUsername, mSessionContext.mUsernameID))
		return false;

	if (!apHeader->AllocateString(apPassword, mSessionContext.mPasswordID))
		return false;

	if (!apHeader->AllocateString(apNamespace, mSessionContext.mNamespaceID))
		return false;

	return true;
}



BOOL SharedObjectOwner::GetSessionContextCredentials(
	SharedSessionHeader * apHeader,
	const char * * apUsername, const char * * apPassword,
	const char * * apNamespace) const
{
	if (mSessionContext.mUsernameID == -1
			|| mSessionContext.mPasswordID == -1
			|| mSessionContext.mNamespaceID == -1)
		// not set
		return FALSE;

	ASSERT(apUsername);
	ASSERT(apPassword);
	ASSERT(apNamespace);
	*apUsername = apHeader->GetString(mSessionContext.mUsernameID);
	*apPassword = apHeader->GetString(mSessionContext.mPasswordID);
	*apNamespace = apHeader->GetString(mSessionContext.mNamespaceID);
	return FALSE;
}

BOOL SharedObjectOwner::SetSessionContextUserName(
	SharedSessionHeader * apHeader,
	const char * apUsername)
{
	if (mSessionContext.mUsernameID != -1)
		// already set
		return FALSE; 

	if (!apHeader->AllocateString(apUsername, mSessionContext.mUsernameID))
		return false;

	return true;
}
const char* SharedObjectOwner::GetSessionContextUserName(
	SharedSessionHeader * apHeader) const
{
	if (mSessionContext.mUsernameID == -1)
		// not set
		return NULL;

	return apHeader->GetString(mSessionContext.mUsernameID);
}
BOOL SharedObjectOwner::SetSessionContextPassword(
	SharedSessionHeader * apHeader,
	const char * apPassword)
{
	if (mSessionContext.mPasswordID != -1)
		// already set
		return FALSE; 

	if (!apHeader->AllocateString(apPassword, mSessionContext.mPasswordID))
		return false;

	return true;
}

const char* SharedObjectOwner::GetSessionContextPassword(
	SharedSessionHeader * apHeader) const
{
	if (mSessionContext.mPasswordID == -1)
		// not set
		return NULL;

	return apHeader->GetString(mSessionContext.mPasswordID);
}


BOOL SharedObjectOwner::SetSessionContextNamespace(
	SharedSessionHeader * apHeader,
	const char * apNamespace)
{
	if (mSessionContext.mNamespaceID != -1)
		// already set
		return FALSE; 

	if (!apHeader->AllocateString(apNamespace, mSessionContext.mNamespaceID))
		return false;

	return true;
}

const char* SharedObjectOwner::GetSessionContextNamespace(
	SharedSessionHeader * apHeader) const
{
	if (mSessionContext.mNamespaceID == -1)
		// not set
		return NULL;
	return apHeader->GetString(mSessionContext.mNamespaceID);
}


BOOL SharedObjectOwner::SetRSIDCache(IUnknown * apCache)
{
	if (mRSIDCache.mpRSIDCache)
	{
		if (mRSIDCache.mProcessID == ::GetCurrentProcessId())
			mRSIDCache.mpRSIDCache->Release();
		mRSIDCache.mpRSIDCache = NULL;
		mRSIDCache.mProcessID = -1;
	}

	long testValue = ::InterlockedCompareExchange((long *) &mRSIDCache.mpRSIDCache,
																								(long) apCache, 0);
	if (testValue != 0)
		// the pointer has already been set
		// this isn't allowed unless the cache is being cleared
		return FALSE;

	// transaction can be set to NULL
	if (apCache)
	{
		apCache->AddRef();							// we now hold a reference
		mRSIDCache.mProcessID = ::GetCurrentProcessId();
	}
	else
		mRSIDCache.mProcessID = -1;
	return TRUE;
}

void SharedObjectOwner::GetRSIDCache(IUnknown * * apCache) const
{
	if (mRSIDCache.mProcessID == -1)
	{
		// must be null or something's wrong
		*apCache = NULL;
	}
	else
	{
		// NOTE: this isn't perfect, but it can help us avoid calling addref
		// on a transaction from another process
		if (mRSIDCache.mProcessID != ::GetCurrentProcessId())
			*apCache = NULL;
		else
		{
			*apCache = mRSIDCache.mpRSIDCache;
			if (*apCache)
				(*apCache)->AddRef();
		}
	}

}


int SharedObjectOwner::AddRef()
{
	return ::InterlockedIncrement((long *) &mRefCount);
}

int SharedObjectOwner::Release(SharedSessionHeader * apHeader)
{
	ASSERT(mRefCount > 0);
	long count = ::InterlockedDecrement((long *) &mRefCount);
	if (mRefCount == 0)
	{
		// delete this guy and everything chained to it
		Delete(apHeader);
	}
	return count;
}

void SharedObjectOwner::Delete(SharedSessionHeader * apHeader)
{
	// walk the chain of object owners and delete them all
	mRefCount = -1;								// for debugging
	long objectID = GetID(apHeader);
	int nextID = GetNextObjectOwnerID();

	if (mSessionContext.mSerializedContextID != -1)
	{
		apHeader->FreeExtraLargeWideString(mSessionContext.mSerializedContextID);
		mSessionContext.mSerializedContextID = -1;
	}

	SetRSIDCache(0);

	if (mTransaction.mpTransaction)
	{
		mTransaction.mpTransaction->Release();
		mTransaction.mpTransaction = NULL;
	}
	if (mTransaction.mTransactionID != -1)
		apHeader->FreeString(mTransaction.mTransactionID);

	//free Session Context credentials
	if(mSessionContext.mUsernameID != -1)
		apHeader->FreeString(mSessionContext.mUsernameID);
	if(mSessionContext.mPasswordID != -1)
		apHeader->FreeString(mSessionContext.mPasswordID);
	if(mSessionContext.mNamespaceID != -1)
		apHeader->FreeString(mSessionContext.mNamespaceID);

  if(mSessionContext.mpSessionContext != NULL)
    SetSessionContext(NULL);

	if (mActionType == OBJECT_OWNER_SEND_FEEDBACK
			|| mActionType == OBJECT_OWNER_COMPLETE_PROCESSING)
	{
		SharedSet * set = apHeader->GetSet(mFeedbackOnSessionSet);
		(void) set->Release(apHeader);
	}

  if (mLock.mpCriticalSection != 0)
  {
    ::DeleteCriticalSection(mLock.mpCriticalSection);
    delete [] (char *) mLock.mpCriticalSection;
    mLock.mpCriticalSection = 0;
    mLock.mProcessID = -1;
  }

	apHeader->DeleteObjectOwner(objectID);

	if (nextID != -1)
	{
		SharedObjectOwner * next = apHeader->GetObjectOwner(nextID);
		// this will recursively delete all elements chained together
		next->Release(apHeader);
	}
}

BOOL SharedObjectOwner::InitLock()
{
  // If the critical section is not set,
  // initialize the critical section offline and then atomic
  // swap the pointer in.
  if(mLock.mpCriticalSection == 0)
  {
    CRITICAL_SECTION * cs = (CRITICAL_SECTION *) new char [sizeof(CRITICAL_SECTION)];
    ::InitializeCriticalSection(cs);
    long testValue = ::InterlockedCompareExchange((long *) &mLock.mpCriticalSection,
																								(long) cs, 0);
    if (testValue != 0)
    {
      // the pointer has already been set by some one else.
      // clean up and leave.
      ::DeleteCriticalSection(cs);
      delete [] (char *) cs;
      return mLock.mProcessID == ::GetCurrentProcessId();
    }
    
    // We successfully set the critical section; set the process id as a marker
    mLock.mProcessID = ::GetCurrentProcessId();
    return TRUE;
  }
  else
  {
    return mLock.mProcessID == ::GetCurrentProcessId();
  }
}

void SharedObjectOwner::Lock()
{
  ::EnterCriticalSection(mLock.mpCriticalSection);
}

void SharedObjectOwner::Unlock()
{
  ::LeaveCriticalSection(mLock.mpCriticalSection);
}
