/**************************************************************************
 * @doc PROFILE
 *
 * Copyright 2000 by MetraTech Corporation
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
#include <profile.h>

#include <hashpjm.h>
#include <MTSingleton.h>

/******************************** singleton MappedViewHandle ***/
class MappedViewHandleWithInit : public MappedViewHandle
{
public:
	BOOL Init()
	{ return TRUE; }
};

typedef MTSingleton<MappedViewHandleWithInit> SingletonMappedViewHandle;

/************************************** ProfileDataReference ***/

ProfileDataReference::ProfileDataReference()
	: mpMappedView(NULL)
{
	// NOTE: don't initialize mpMappedView here.
	// there is a critical section involved, causing processes
	// do deadlock if initializing under DllMain.
}

ProfileDataReference::~ProfileDataReference()
{
	if (mpMappedView)
	{
		SingletonMappedViewHandle::ReleaseInstance();
		mpMappedView = NULL;
	}
}

BOOL ProfileDataReference::Init()
{
	if (!mpMappedView)
	{
		// use a singleton so you can use any number of ProfileDataReference
		// objects and only initialize it once
		mpMappedView = SingletonMappedViewHandle::GetInstance();
	}
	return TRUE;
}


BOOL ProfileDataReference::Init(const char * apFilename,
																const char * apSharename,
																long aSessionSlots,
																long aMessageSlots)
{
	const char * functionName = "ProfileDataReference::Init";

	Init();

	// TODO: this assumes that only 
	int totalSize = 
		MappedViewHandle::GetOverhead() +
		sizeof(ProfileData) +
		aSessionSlots * sizeof(SessionProfile) +
		aMessageSlots * sizeof(MessageProfile);

	mpMappedView = SingletonMappedViewHandle::GetInstance();

	DWORD err = mpMappedView->Open(apFilename, apSharename,
																 totalSize, FALSE);

	if (err != NO_ERROR)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// we've lost access to the mutex - get it back
	SharedProfileAccess access(*this);
	if (!access())
	{
		SetError(access);
		return FALSE;
	}

	long spaceAvail = mpMappedView->GetAvailableSpace() - sizeof(ProfileData);

	mpHeader =
		ProfileData::Initialize(
			*mpMappedView, mpMappedView->GetMemoryStart(),
			aSessionSlots,
			aMessageSlots,
			FALSE);

	if (!mpHeader)
	{
		// TODO: report error
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}
	return TRUE;
}

/*********************************************** ProfileData ***/


ProfileData *
ProfileData::Initialize(MappedViewHandle & arHandle,
												void * apMemStart,
												int aSessionSlots,
												int aMessageSlots,
												BOOL aForceReset /* = FALSE */ )
{
	BOOL needsReset;
	ProfileData * header = ValidHeader(apMemStart);
	if (header)
		needsReset = FALSE;
	else
		needsReset = TRUE;

	if (aForceReset)
		needsReset = TRUE;

	if (needsReset)
	{
		header = (ProfileData *)
			arHandle.AllocateSpace(sizeof(ProfileData));
		if (!header)
			return NULL;							// unable to allocate space

		if (!header->Init(arHandle, aSessionSlots, aMessageSlots))
			return NULL;
	}

	return header;
}

BOOL ProfileData::Init(MappedViewHandle & arHandle,
											 int aSessionSlots,
											 int aMessageSlots)
{
	//
	// initialize session profile pool
	//

	// allocate space
	int bytes = aSessionSlots * sizeof(SessionProfile);

	void * mem = arHandle.AllocateSpace(bytes);
	if (!mem)
		return FALSE;

	if (!mSessionProfilePool.Initialize(mem, bytes))
		return FALSE;

	//
	// initialize message profile pool
	//

	// allocate space
	bytes = aMessageSlots * sizeof(MessageProfile);
	mem = arHandle.AllocateSpace(bytes);
	if (!mem)
		return FALSE;

	if (!mMessageProfilePool.Initialize(mem, bytes))
		return FALSE;

	//
	// initialize the hash tables to look up sessions
	//
	for (int i = 0; i < UID_BUCKETS; i++)
	{
		mSessionProfileLookup[i] = -1;
		mMessageProfileLookup[i] = -1;
	}
	// NOTE: magic is set last so that it's only valid if the structure
	// was initialized correctly
	mMagic = MAGIC;

	return TRUE;
}

ProfileData * ProfileData::ValidHeader(void * apMemStart)
{
	if (apMemStart != NULL)
	{
		ProfileData * header = (ProfileData *) apMemStart;
		if (header->mMagic == MAGIC)
			return header;
	}
	return NULL;
}


#if 0
SharedSessionHeader *
SharedSessionHeader::Open(MappedViewHandle & arHandle)
{
	void * memStart = arHandle.GetMemoryStart();
	ASSERT(memStart);
	if (!memStart)
		return NULL;

	SharedSessionHeader * header = ValidHeader(memStart);
	return header;
}
#endif



// create a session and return its reference number
// add it into the hash table as well
SessionProfile * ProfileData::CreateSessionProfile(long & arRef,
																									 const unsigned char apUID[],
																									 int aServiceID, int aChildCount)
{
	SessionProfile * profile = mSessionProfilePool.CreateElement(arRef);
	if (!profile)
		return NULL;								// out of space

	int bucket = HashUID(apUID);
	long next = mSessionProfileLookup[bucket];
	ASSERT(next != arRef);
	profile->SetNextInBucket(next);
	mSessionProfileLookup[bucket] = arRef;

	profile->Init(apUID, aServiceID, aChildCount);

	return profile;
}

// create a session and return its reference number
// add it into the hash table as well
MessageProfile * ProfileData::CreateMessageProfile(long & arRef,
																									 const unsigned char apUID[])
{
	MessageProfile * profile = mMessageProfilePool.CreateElement(arRef);
	if (!profile)
		return NULL;								// out of space

	int bucket = HashUID(apUID);
	long next = mMessageProfileLookup[bucket];
	ASSERT(next != arRef);
	profile->SetNextInBucket(next);
	mMessageProfileLookup[bucket] = arRef;

	profile->Init(apUID);

	return profile;
}

SessionProfile * ProfileData::GetSessionProfile(int aSession) const
{
	return mSessionProfilePool.GetElement(aSession);
}

MessageProfile * ProfileData::GetMessageProfile(int aSession) const
{
	return mMessageProfilePool.GetElement(aSession);
}

void ProfileData::FindSessionProfile(const unsigned char * apUID,
																		 SessionProfile * * apSession)
{
	SessionProfile * prevSess;
	long * prevIndex;
	FindSessionProfile(apUID, apSession, &prevIndex, &prevSess);
}



void ProfileData::FindMessageProfile(const unsigned char * apUID,
																		 MessageProfile * * apSession)
{
	MessageProfile * prevSess;
	long * prevIndex;
	FindMessageProfile(apUID, apSession, &prevIndex, &prevSess);
}



void ProfileData::FindSessionProfile(const unsigned char * apUID,
																		 SessionProfile * * apSession,
																		 long * * apPrev,
																		 SessionProfile * * apPreviousSess)
{
	ASSERT(apUID != NULL);

	const int bucket = HashUID(apUID);
	SessionProfile * prev = NULL;
	long nextId = mSessionProfileLookup[bucket];
	while (nextId != -1)
	{
		SessionProfile * current = GetSessionProfile(nextId);

		if (current->UIDEquals(apUID))
		{
			if (prev == NULL)
			{
				*apPrev = &mSessionProfileLookup[bucket];
				*apPreviousSess = NULL;
			}
			else
			{
#ifdef _DEBUG
				long nextid = prev->GetNextInBucket();
				SessionProfile * testSess = GetSessionProfile(nextid);
				ASSERT(testSess == current);
#endif
				*apPreviousSess = prev;
				*apPrev = NULL;
			}
			*apSession = current;
			return;
		}
		prev = current;

		long nextInBucket = current->GetNextInBucket();
		ASSERT(nextId != nextInBucket);
		nextId = nextInBucket;
	}
	*apSession = NULL;
	*apPrev = NULL;
	*apPreviousSess = NULL;
}

void ProfileData::FindMessageProfile(const unsigned char * apUID,
																		 MessageProfile * * apSession,
																		 long * * apPrev,
																		 MessageProfile * * apPreviousSess)
{
	ASSERT(apUID != NULL);

	const int bucket = HashUID(apUID);
	MessageProfile * prev = NULL;
	long nextId = mMessageProfileLookup[bucket];
	while (nextId != -1)
	{
		MessageProfile * current = GetMessageProfile(nextId);

		if (current->UIDEquals(apUID))
		{
			if (prev == NULL)
			{
				*apPrev = &mMessageProfileLookup[bucket];
				*apPreviousSess = NULL;
			}
			else
			{
#ifdef _DEBUG
				long nextid = prev->GetNextInBucket();
				MessageProfile * testSess = GetMessageProfile(nextid);
				ASSERT(testSess == current);
#endif
				*apPreviousSess = prev;
				*apPrev = NULL;
			}
			*apSession = current;
			return;
		}
		prev = current;

		long nextInBucket = current->GetNextInBucket();
		ASSERT(nextId != nextInBucket);
		nextId = nextInBucket;
	}
	*apSession = NULL;
	*apPrev = NULL;
	*apPreviousSess = NULL;
}

// This function is a helper function for traversing the hash table
//
// TODO: this probably makes more sense as a member, but MSVC 6.0 seems
// to generate a lot of internal compiler errors when that is done.
template<int BUCKETS, class T>
void AllProfiles(list<T *> & arList, FixedSizePool<T> & arPool, long apHashTable[])
{
	for (int i = 0; i < BUCKETS; i++)
	{
		int index = apHashTable[i];
		if (index == -1)
			continue;									// nothing in this bucket

		T * profile = NULL;
		while (index != -1)
		{
			profile = arPool.GetElement(index);
			ASSERT(profile);
			arList.push_back(profile);
			index = profile->GetNextInBucket();
		}
	}
}



void ProfileData::AllMessageProfiles(list<MessageProfile *> & arList)
{
	// TODO: the compiler should be able to deduce the second argument
	// but it generates an internal compiler error if the argument
	// is left off
	AllProfiles<UID_BUCKETS, MessageProfile>(arList,
		mMessageProfilePool, mMessageProfileLookup);
}


void ProfileData::AllSessionProfiles(list<SessionProfile *> & arList)
{
	// TODO: the compiler should be able to deduce the second argument
	// but it generates an internal compiler error if the argument
	// is left off
	AllProfiles<UID_BUCKETS, SessionProfile>(arList,
		mSessionProfilePool, mSessionProfileLookup);
}


BOOL ProfileData::Reset(MappedViewHandle & arHandle)
{
	int sessions = mSessionProfilePool.GetSize();
	int messages = mMessageProfilePool.GetSize();

	// reset the contents of the memory mapped file
	if (!arHandle.ResetMemory(arHandle.GetTotalSpace() + arHandle.GetOverhead()))
		return FALSE;


	return Init(arHandle, sessions, messages);
}

int ProfileData::HashUID(const unsigned char apUID[])
{
	unsigned int hash = HashData(apUID, UID_LENGTH);
	return hash % UID_BUCKETS;
}

/*************************************** SharedProfileAccess ***/

BOOL SharedProfileAccess::GainAccess()
{
	const char * functionName = "SharedProfileAccess::GainAccess";

	DWORD result;
	// 25 second timeout
	if (mpHandle->WaitForAccess(25000, &result) != NULL)
		return TRUE;

	SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, functionName);
	return FALSE;
}

/******************************************** MessageProfile ***/

void MessageProfile::Init(const unsigned char apUID[])
{
	memcpy(mUID, apUID, UID_LENGTH);

	// clear the counts
	for (int i = 0; i < TOTAL_COUNT; i++)
		mCounts[i].QuadPart = -1;
}

const unsigned char * MessageProfile::GetUID() const
{
	return mUID;
}

BOOL MessageProfile::UIDEquals(const unsigned char * apUID) const
{
	return 0 == memcmp(GetUID(), apUID, UID_LENGTH);
}

void MessageProfile::SetTime(ProfileTag aProfileTag)
{
	ASSERT(aProfileTag >= 0 && aProfileTag < TOTAL_COUNT);
	GetCurrentPerformanceTickCount(&mCounts[aProfileTag]);
}

void MessageProfile::SetTime(ProfileTag aProfileTag, const PerformanceTickCount & aTime)
{
	ASSERT(aProfileTag >= 0 && aProfileTag < TOTAL_COUNT);
	mCounts[aProfileTag].QuadPart = aTime.QuadPart;
}

const PerformanceTickCount & MessageProfile::GetTime(ProfileTag aProfileTag) const
{
	ASSERT(aProfileTag >= 0 && aProfileTag < TOTAL_COUNT);
	return mCounts[aProfileTag];
}

int MessageProfile::GetMaxPerformanceCounters()
{
	return TOTAL_COUNT;
}

const char * MessageProfile::GetCounterName(ProfileTag aProfileTag)
{
	const char * names[] =
	{
		"First Entered",						// FIRST_ENTERED = 0,
		"Parsed For Validation",								// VALIDATED,
		"Validated",								// VALIDATED,
		"Delivered to routing queue",	// DELIVERED_TO_ROUTING_QUEUE,
		"Removed from routing queue",	// REMOVED_FROM_ROUTING_QUEUE,
		"Parsed",										// PARSED,
	};

	ASSERT(sizeof(names) / sizeof(names[0]) == TOTAL_COUNT);

	ASSERT(aProfileTag >= 0 && aProfileTag < TOTAL_COUNT);
	if (aProfileTag >= 0 && aProfileTag < TOTAL_COUNT)
		return names[aProfileTag];
	else
		return NULL;
}

void MessageProfile::SetNextInBucket(long aNext)
{
	mNextInBucket = aNext;
}

long MessageProfile::GetNextInBucket() const
{
	return mNextInBucket;
}

/******************************************** SessionProfile ***/

void SessionProfile::Init(const unsigned char apUID[], int aServiceID, int aChildCount)
{
	mCurrentStage = 0;

	// clear timers
	for (int i = 0; i < MAX_STAGES_PROFILED; i++)
		for (int j = 0; j < TOTAL_COUNT; j++)
			mCounts[i][j].QuadPart = -1;

	memcpy(mUID, apUID, UID_LENGTH);

	mServiceID = aServiceID;
	mChildCount = aChildCount;
}


const unsigned char * SessionProfile::GetUID() const
{
	return mUID;
}

BOOL SessionProfile::UIDEquals(const unsigned char * apUID) const
{
	return 0 == memcmp(GetUID(), apUID, UID_LENGTH);
}

void SessionProfile::SetTime(ProfileTag aProfileTag)
{
	ASSERT(aProfileTag >= 0 && aProfileTag < TOTAL_COUNT);
	GetCurrentPerformanceTickCount(&mCounts[mCurrentStage][aProfileTag]);
}

void SessionProfile::SetTime(ProfileTag aProfileTag, const PerformanceTickCount & aTime)
{
	ASSERT(aProfileTag >= 0 && aProfileTag < TOTAL_COUNT);
	mCounts[mCurrentStage][aProfileTag].QuadPart = aTime.QuadPart;
}

const PerformanceTickCount & SessionProfile::GetTime(ProfileTag aProfileTag) const
{
	ASSERT(aProfileTag >= 0 && aProfileTag < TOTAL_COUNT);
	return mCounts[mCurrentStage][aProfileTag];
}

const PerformanceTickCount &
SessionProfile::GetTime(int aStage, ProfileTag aProfileTag) const
{
	ASSERT(aProfileTag >= 0 && aProfileTag < TOTAL_COUNT);
	return mCounts[aStage][aProfileTag];
}

int SessionProfile::GetMaxPerformanceCounters()
{
	return TOTAL_COUNT;
}

const char * SessionProfile::GetCounterName(ProfileTag aProfileTag)
{
	const char * names[] =
	{
		"Object Generated",					// OBJECT_GENERATED,
		"Delivered to stage",				// DELIVERED_TO_STAGE,
		"Received at stage",				// RECEIVED_AT_STAGE,
		"Placed on ready list",			// PLACED_ON_READY_LIST,
		"About to be processed",		// ABOUT_TO_BE_PROCESSED,
		"Processed",								// PROCESSED,
		"About to be delivered",		// ABOUT_TO_BE_DELIVERED,
	};

	ASSERT(sizeof(names) / sizeof(names[0]) == TOTAL_COUNT);

	ASSERT(aProfileTag >= 0 && aProfileTag < TOTAL_COUNT);
	if (aProfileTag >= 0 && aProfileTag < TOTAL_COUNT)
		return names[aProfileTag];
	else
		return NULL;
}

int SessionProfile::GotoNextStage()
{
	return ++mCurrentStage;
}

int SessionProfile::GetTotalStages() const
{
	return mCurrentStage + 1;
}

void SessionProfile::SetNextInBucket(long aNext)
{
	mNextInBucket = aNext;
}

long SessionProfile::GetNextInBucket() const
{
	return mNextInBucket;
}
