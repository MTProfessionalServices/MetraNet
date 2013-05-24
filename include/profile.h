/**************************************************************************
 * @doc PROFILE
 *
 * @module |
 *
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
 *
 * @index | PROFILE
 ***************************************************************************/

#ifndef _PROFILE_H
#define _PROFILE_H

// FixedSizePool implementation
#include <mappedview.h>

// performance calls used by the profiling code
#include <perf.h>

#include <errobj.h>

#include <list>
using std::list;

const int UID_LENGTH = 16;

class MessageProfile;
class SessionProfile;
class ProfileDataReference;
class ProfileData;

/************************************** ProfileDataReference ***/

class ProfileDataReference : public virtual ObjectWithError
{
public:
	ProfileDataReference();
	virtual ~ProfileDataReference();

	BOOL Init();

	BOOL Init(const char * apFilename,
						const char * apSharename,
						long aSessionSlots,
						long aMessageSlots);


	ProfileData * operator ->() const
	{ return mpHeader; }

	MappedViewHandle * GetViewHandle() const
	{ return mpMappedView; }

private:
	// pointer to the share memory objects
	ProfileData * mpHeader;
	MappedViewHandle * mpMappedView;
};

/*********************************************** ProfileData ***/

class ProfileData
{
private:
	enum
	{
		MAGIC = 0xDADADA00,

		// number of hash buckets to search for sessions with a given UID
		UID_BUCKETS = 29,
	};

	long mMagic;

	// hash table into the message profile pool to
	// look up sessions by their unique IDs
	long mMessageProfileLookup[UID_BUCKETS];

	// message profile data
	FixedSizePool<MessageProfile> mMessageProfilePool;


	// hash table into the message profile pool to
	// look up sessions by their unique IDs
	long mSessionProfileLookup[UID_BUCKETS];

	// session profile data
	FixedSizePool<SessionProfile> mSessionProfilePool;

public:
	static ProfileData * Initialize(MappedViewHandle & arHandle,
																	void * apMemStart,
																	int aSessionSlots,
																	int aMessageSlots,
																	BOOL aForceReset /* = FALSE */ );

	SessionProfile * CreateSessionProfile(long & arRef,
																				const unsigned char apUID[],
																				int aServiceID, int aChildCount);

	MessageProfile * CreateMessageProfile(long & arRef,
																				const unsigned char apUID[]);


	void FindSessionProfile(const unsigned char * apUID,
													SessionProfile * * apSession);

	void FindMessageProfile(const unsigned char * apUID,
													MessageProfile * * apSession);

	SessionProfile * GetSessionProfile(int aSession) const;

	MessageProfile * GetMessageProfile(int aSession) const;

	// return a list of all message profiles
	void AllMessageProfiles(list<MessageProfile *> & arList);

	// return a list of all session profiles
	void AllSessionProfiles(list<SessionProfile *> & arList);

	BOOL Reset(MappedViewHandle & arHandle);

private:
	BOOL Init(MappedViewHandle & arHandle,
						int aSessionSlots,
						int aMessageSlots);

	static ProfileData * ValidHeader(void * apMemStart);

	void FindSessionProfile(const unsigned char * apUID,
													SessionProfile * * apSession,
													long * * apPrev,
													SessionProfile * * apPreviousSess);


	void FindMessageProfile(const unsigned char * apUID,
													MessageProfile * * apSession,
													long * * apPrev,
													MessageProfile * * apPreviousSess);


private:
	// return a number between 0 and UID_BUCKETS
	int HashUID(const unsigned char apUID[]);
};

/******************************************** MessageProfile ***/

class MessageProfile
{
public:
	// first, the session is treated as part of a message.
	// many sessions can be part of a message when doing
	// compoound processing.
	enum ProfileTag
	{
		FIRST_ENTERED = 0,
		PARSED_FOR_VALIDATION,
		VALIDATED,
		DELIVERED_TO_ROUTING_QUEUE,
		REMOVED_FROM_ROUTING_QUEUE,
		PARSED,

		// terminator - equal to number of fields defined
		TOTAL_COUNT
	};

private:
	union
	{
		// used to link free slots.  Used by FixedSizePool
		long mNextFree;

		struct
		{
			// all message specific performance data
			PerformanceTickCount mCounts[TOTAL_COUNT];

			// MSIX UID for this session.  Primary key used to lookup sessions.
			unsigned char mUID[UID_LENGTH];

			// link to the next item in the hash table (for
			// searching for sessions with a given UID)
			long mNextInBucket;
		};
	};

public:
	// initialize with the given session data
	void Init(const unsigned char apUID[]);

	// return TRUE if UIDs match
	BOOL UIDEquals(const unsigned char * apUID) const;

	// return the UID
	const unsigned char * GetUID() const;

	// set the time an event occurred to the current time
	void SetTime(ProfileTag aProfileTag);

	// set the time an event occurred to a given time
	void SetTime(ProfileTag aProfileTag, const PerformanceTickCount & aTime);

	// return the time an event occurred
	const PerformanceTickCount & GetTime(ProfileTag arTag) const;

	// return the number of performance counters stored
	static int GetMaxPerformanceCounters();

	// return the name for a given performance counter
	static const char * GetCounterName(ProfileTag aProfileTag);

	// set the next session in this bucket (used for hash lookups)
	void SetNextInBucket(long aNext);

	// get the next session in this bucket (used for hash lookups)
	long GetNextInBucket() const;

public:
	// these methods are only used by FixedSizePool..
	long GetNextFree() const
	{ return mNextFree; }

	void SetNextFree(long aNext)
	{ mNextFree = aNext; }
};

/******************************************** SessionProfile ***/

class SessionProfile
{
public:
	// once a message is split up, the session is profiled individually.
	enum ProfileTag
	{
		OBJECT_GENERATED = 0,
		DELIVERED_TO_STAGE,
		RECEIVED_AT_STAGE,
		PLACED_ON_READY_LIST,
		ABOUT_TO_BE_PROCESSED,
		PROCESSED,
		ABOUT_TO_BE_DELIVERED,

		// terminator - equal to number of fields defined
		TOTAL_COUNT,

		MAX_STAGES_PROFILED = 5,
	};

private:
	union
	{
		// used to link free slots.  Used by FixedSizePool
		long mNextFree;

		struct
		{
			PerformanceTickCount mCounts[MAX_STAGES_PROFILED][TOTAL_COUNT];

			// incremented as the session moves from stage
			// to stage.
			int mCurrentStage;

			// service ID of this session
			int mServiceID;

			// number of children in this session
			int mChildCount;

			// MSIX UID for this session.  Primary key used to lookup sessions.
			unsigned char mUID[UID_LENGTH];

			// link to the next item in the hash table (for
			// searching for sessions with a given UID)
			long mNextInBucket;
		};
	};

public:

	// initialize the structure with the given session info
	void Init(const unsigned char apUID[], int aServiceID, int aChildCount);

	// return TRUE if UIDs match
	BOOL UIDEquals(const unsigned char * apUID) const;

	// return the UID
	const unsigned char * GetUID() const;

	// set the time an event occurred within the current stage to the current time
	void SetTime(ProfileTag aProfileTag);

	// set the time an event occurred within the current stage to a given time
	void SetTime(ProfileTag aProfileTag, const PerformanceTickCount & aTime);

	// return the time an event occurred within the current stage
	const PerformanceTickCount & GetTime(ProfileTag arTag) const;

	// return the time an event occurred within any stage
	const PerformanceTickCount & GetTime(int aStage, ProfileTag arTag) const;

	// return the number of performance counters stored per stage
	static int GetMaxPerformanceCounters();

	// return the name for a given performance counter
	static const char * GetCounterName(ProfileTag aProfileTag);

	// start recording data for the next stage (return the new stage number)
	int GotoNextStage();

	// return the total number of stages where data was recorded
	int GetTotalStages() const;

	// set the next session in this bucket (used for hash lookups)
	void SetNextInBucket(long aNext);

	// get the next session in this bucket (used for hash lookups)
	long GetNextInBucket() const;

public:
	// these methods are only used by FixedSizePool..
	long GetNextFree() const
	{ return mNextFree; }

	void SetNextFree(long aNext)
	{ mNextFree = aNext; }
};

/********************************************** SharedAccess ***/

class SharedProfileAccess : public virtual ObjectWithError
{
public:
	SharedProfileAccess(ProfileDataReference & arObj)
		: mpHandle(arObj.GetViewHandle()), mAccessGranted(FALSE)
	{
		mAccessGranted = GainAccess();
	}

	~SharedProfileAccess()
	{
#if 0
		if (mAccessGranted)
			mpHandle->ReleaseAccess();
#endif
	}

	BOOL operator()()
	{ return mAccessGranted; }

private:
	BOOL GainAccess();

	BOOL mAccessGranted;
	MappedViewHandle * mpHandle;
};


#endif /* _PROFILE_H */
