/**************************************************************************
 * @doc SHAREDSESS
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
 * @index | SHAREDSESS
 ***************************************************************************/

#ifndef _SHAREDSESS_H
#define _SHAREDSESS_H

#include <mappedview.h>

#if defined(SHARED_SESSION_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class SharedSessionHeader;
class SharedSession;
class SharedSet;
class SharedSetNode;
class SharedPropVal;
class SharedObjectOwner;

typedef BOOL (*AllSessionFunc)(void * apArg, SharedSessionHeader * apHeader,
															 SharedSession * apSession);

typedef BOOL (*AllPropertyFunc)(void * apArg, SharedSessionHeader * apHeader,
																SharedPropVal * apProperty);

// declare for use in object values
struct IUnknown;

/*************************************** SharedSessionHeader ***/

// LinkedStrings are a series of StringStructs linked together.
// this is used to hold any string longer than the largest string pool
// entry
struct LinkedString
{
	// -1 if this is the last part of the string.
	long mNextPart;

	// the size is actually the remaining size of the StringStruct
	char mStr[1];
};

template <int SIZE>
class StringStruct
{
	friend FixedSizePool<StringStruct<SIZE> >;

public:
	union
	{
		// free chain
		long mNextFree;

		// buffer
		char mStr[SIZE];
	};

	operator char *()
	{ return mStr; }

private:
	// these methods are only used by FixedSizePool..
	long GetNextFree() const
	{ return mNextFree; }

	void SetNextFree(long aNext)
	{ mNextFree = aNext; }
};

class SharedSessionMappedViewHandle : public MappedViewHandle
{
protected:
	// reset the shared session header
	DllExport virtual BOOL InitializeMappedMemory(BOOL aReset);
};

class SharedSessionHeader
{
public:
	enum
	{
		MAGIC = 0xBEEDFEED,
		TINY_STRING_MAX = 16,				// NOTE: this value must match DECIMAL_SIZE
		SMALL_STRING_MAX = 32,
		MEDIUM_STRING_MAX = 128,
		LARGE_STRING_MAX = 512,
	};

private:
	enum
	{
		// number of hash buckets to search for
		// sessions with a given realid
		//	REAL_ID_BUCKETS = 29,

		// number of hash buckets to search for sessions with a given UID
		UID_BUCKETS = 3001,
	};

	long mMagic;								// = MAGIC

	// session pool
	FixedSizePool<SharedSession> mSessionPool;

	// hash table that into the session pool
	// to look up sessions by their real/database IDs
	//long mSessionLookup[REAL_ID_BUCKETS];

	// hash table that into the session pool
	// to look up sessions by their MSIX UIDs
	long mSessionLookup[UID_BUCKETS];

	// spin locks used to lock each bucket.
	// their values are 1 when locked, 0 when unlocked.
	// before traversing or modifying a list in mSessionLookup,
	// the corresponding lock must be acquired
	long mSessionLookupLocks[UID_BUCKETS];

	// property pool
	FixedSizePool<SharedPropVal> mPropPool;

	// set pool
	FixedSizePool<SharedSet> mSetPool;

	// set node pool
	FixedSizePool<SharedSetNode> mSetNodePool;

	// object owner pool
	FixedSizePool<SharedObjectOwner> mObjectOwnerPool;


	// pool of small strings
	FixedSizePool<StringStruct<SMALL_STRING_MAX> > mSmallStringPool;

	// pool of medium strings
	FixedSizePool<StringStruct<MEDIUM_STRING_MAX> > mMediumStringPool;

	// pool of large strings
	FixedSizePool<StringStruct<LARGE_STRING_MAX> > mLargeStringPool;


	// string pool
	long mStringPoolStart;

	// next owner ID
	int mNextOwnerID;

public:
	DllExport void ValidateChains();

	DllExport void FindInvalidChildren(long aParentId);

	/*
	 * Initialization
	 */
	DllExport static SharedSessionHeader * ValidHeader(void * apMemStart);

	DllExport static SharedSessionHeader *
	Initialize(SharedSessionMappedViewHandle & arHandle, void * apMemStart,
						 long aSessionPoolByteSize, long aPropPoolByteSize,
						 long aSetPoolByteSize,
						 long aSetNodePoolByteSize,
						 long aObjectOwnerPoolByteSize,
						 long aStringPoolByteSize, BOOL aForceReset = FALSE);

	DllExport BOOL Init(SharedSessionMappedViewHandle & arHandle,
											long aSessionPoolByteSize, long aPropPoolByteSize,
											long aSetPoolByteSize,
											long aSetNodePoolByteSize,
											long aObjectOwnerPoolByteSize,
											long aStringPoolByteSize);

	// connect to an existing shared memory file
	DllExport static SharedSessionHeader * Open(SharedSessionMappedViewHandle & arHandle);

	// trash the header to force a reinitialization
	DllExport void InvalidateHeader();

	/*
	 * pointer arithmetic
	 */
	DllExport
	SharedPropVal * GetPropValStart() const
	{
		return mPropPool.GetStart();
	}

	DllExport
	SharedSession * GetSessionStart() const
	{
		return mSessionPool.GetStart();
	}

	DllExport
	SharedSet * GetSetStart() const
	{
		return mSetPool.GetStart();
	}

	DllExport
	SharedSetNode * GetSetNodeStart() const
	{
		return mSetNodePool.GetStart();
	}

	DllExport
	SharedObjectOwner * GetSharedObjectOwnerStart() const
	{
		return mObjectOwnerPool.GetStart();
	}


	DllExport
	void SetStringPoolStart(void * mem)
	{ mStringPoolStart = PointerDiff(mem, this); }

	DllExport
	char * GetStringPoolStart() const
	{ return OffsetPointer<char, const SharedSessionHeader>(this, mStringPoolStart); }

	/*
	 * item retrieval
	 */

	inline SharedPropVal * GetProperty(long aPropertyId) const;

	DllExport
	SharedSet * GetSet(long aSetId) const;

	DllExport
	SharedSetNode * GetSetNode(long aNodeId) const;

	// NOTE: this does not do an AddRef to the session
	DllExport
	SharedSession * GetSession(long aSessionId) const;

	DllExport
	SharedObjectOwner * GetObjectOwner(long aObjectOwnerId) const;

	/*
	 * item creation
	 */
	DllExport
	SharedPropVal * CreateProperty(long & arRef);

	DllExport
	SharedSet * CreateSet(long & arRef);

	DllExport
	SharedSetNode * CreateSetNode(long & arRef);

	DllExport
	SharedSession * CreateSession(long & arRef, const unsigned char * apUID);

	DllExport
	SharedObjectOwner * CreateObjectOwner(long & arRef);

	/*
	 * item deletion
	 */
	DllExport
	long DeleteProp(long aPropId);

	DllExport
	void DeleteSession(long aRef);

	DllExport
	void DeleteSetNode(long aRef);

	DllExport
	void DeleteSet(long aRef);

	DllExport
	void DeleteObjectOwner(long aRef);

	/*
	 * hash table retrieval
	 */
	DllExport
	void FindSession(const unsigned char * apUID, SharedSession * * apSession);

	/*
	 * session iteration
	 */
	DllExport
	void AllSessions(AllSessionFunc apFunc, void * apArg);

	/*
	 * property iteration
	 */
	DllExport
	void AllProperties(AllPropertyFunc apFunc, void * apArg);

	/*
	 * owner functions
	 */
	DllExport
	int GetOwnerID();

	DllExport
	void ReleaseOwnerID(int aID);


	/*
	 * string methods
	 */
	// create a copy of an ASCII string
	DllExport
	const char * AllocateString(const char * apStr, long & arRef);

	// free the string
	DllExport
	void FreeString(long aRef);

	// return a string with the given ID
	DllExport
	const char * GetString(long aRef);


	// create a copy of a Unicode string
	DllExport
	const wchar_t * AllocateWideString(const wchar_t * apStr, long & arRef);

	// free the string
	DllExport
	void FreeWideString(long aRef);

	// return a copy of the string
	DllExport
	const wchar_t * GetWideString(long aRef);


	// create a copy of an extra long Unicode string
	DllExport
	void AllocateExtraLargeWideString(long & arRef, const wchar_t * apStr);

	// free the string
	DllExport
	void FreeExtraLargeWideString(long aRef);

	// allocate a buffer to hold a copy of the string and return it.
	// NOTE: the caller must free this buffer
	DllExport
	wchar_t * CopyExtraLargeWideString(long aRef);


public:

	void GetSessionPoolStats(FixedSizePoolStats & arStats) const
	{ mSessionPool.GetStats(arStats); }

	void GetPropPoolStats(FixedSizePoolStats & arStats) const
	{ mPropPool.GetStats(arStats); }

	void GetSetPoolStats(FixedSizePoolStats & arStats) const
	{ mSetPool.GetStats(arStats); }

	void GetSetNodePoolStats(FixedSizePoolStats & arStats) const
	{ mSetNodePool.GetStats(arStats); }

	void GetObjectOwnerPoolStats(FixedSizePoolStats & arStats) const
	{ mObjectOwnerPool.GetStats(arStats); }

	void GetSmallStringPoolStats(FixedSizePoolStats & arStats) const
	{ mSmallStringPool.GetStats(arStats); }

	void GetMediumStringPoolStats(FixedSizePoolStats & arStats) const
	{ mMediumStringPool.GetStats(arStats); }

	void GetLargeStringPoolStats(FixedSizePoolStats & arStats) const
	{ mLargeStringPool.GetStats(arStats); }


	// NOTE: for debugging only
	void GetLocksStats(const long * * apLocks, int & arLockCount) const
	{ *apLocks = mSessionLookupLocks; arLockCount = UID_BUCKETS; }

private:
	/*
	 * string primitives
	 */
	const char * GetBytes(long aRef);
	char * AllocateBytes(long aSize, long & arRef);
	void FreeStringRef(long aRef);

private:
	// find a session in the UID->session hash table.
	// if removeFromLookup is true, remove the session from the table as well
	void FindSession(const unsigned char * apUID, SharedSession * * apSession,
									 BOOL aRemoveFromLookup);

	// acquire a spin lock on the given bucket.
	// NOTE: this will return FALSE after a long timeout
	BOOL LockBucket(int bucket);

	// release a spin lock on the given bucket.
	void UnlockBucket(int bucket);

	int HashUID(const unsigned char * apUID);

	// release all children of a given parent
	void ReleaseChildren(long aParentId);

	// scan function used to release children after a parent is deleted
	static BOOL ReleaseChildScan(void * apArg, SharedSessionHeader * apHeader,
															 SharedSession * apSession);

#ifdef DEBUG
	static BOOL InvalidChildScan(void * apArg, SharedSessionHeader * apHeader,
															 SharedSession * apSession);
#endif // DEBUG

};

/*
 * item retrieval
 */


inline SharedPropVal * SharedSessionHeader::GetProperty(long aPropertyId) const
{
	return mPropPool.GetElement(aPropertyId);
}


/********************************************* SharedSession ***/

class SharedSession
{

public:
	friend FixedSizePool<SharedSession>;

public:
	enum
	{
		HASH_BUCKETS = 57,						// keep HASH_BUCKETS prime

		UID_LENGTH = 16,						// length of an MSIX UID in bytes

		// for mSessionInfo
		FREE_SESSION = 1,						// this slot is free - no session
		LOCKED_SESSION = 2,					// this session has been locked
		UNLOCKED_SESSION = 3,				// this session is not locked

		// for mEventMask
		NO_EVENTS = 0x00,						// no events need signalling
		BEFORE_SESSION_RELEASE = 0x01,// just before the session is released
		PROCESSING_COMPLETE = 0x02,	// just after processing has completed
		FEEDBACK = 0x04,						// send all session data after processing
	};

	enum SessionState
	{
		NEWLY_CREATED,							// session was just created
		IN_TRANSIT,									// session is being sent to a stage
		PROCESSING,									// session is being processed by a stage
		ROLLEDBACK,									// session was rolled back and must be restarted
		MARKED_AS_FAILED,						// session failed but parts of it have not yet completed
	};

private:
	// info on a free or used session.
	// used as a lock, free flag, etc.
	// TODO: can this be incorporated into the union?
	long mSessionInfo;

	union
	{
		long mNextFree;

		struct
		{
			// MSIX UID for this session.  Primary key used to lookup sessions.
			unsigned char mUID[UID_LENGTH];

			// official (server) ID number
			long mRealID;

			// link to the next item in the hash table (for
			// searching for sessions with a given realId)
			long mNextInBucket;

			// service ID
			long mServiceID;

			// parent ID
			long mParentID;

			// session set ID of child sessions
			long mChildSet;

			// ID of first property for the session
			long mFirstProperty[HASH_BUCKETS];

			// ID of the SharedObjectOwner that is interested in this
			// object.  -1 if not set.
			// The object owner ID is encoded.  If it's negative, it's a
			// "temporary" object owner that's owned by the session itself.
			// This is used in cases where we need to generate a session
			// outside of the context of the pipeline.  We still need an
			// object owner but the session has to clean it up
			int mObjectOwnerID;

			// number of outstanding references
			// to this session.  When this drops to
			// 0, the session can be released.
			int mRefCount;

			// union of the events clients are waiting for
			int mEventMask;

			// what state is the session in right now?
			SessionState mState;

			// what stage is currently in charge of this session?
			int mCurrentStage;
		};
	};

private:
	// these methods are only used by FixedSizePool..
	DllExport long GetNextFree() const;
	DllExport void SetNextFree(long aNext);

public:
	// create a new session.  The reference count will be 1.
	// apParentUID can be NULL if the session has no parent.
	DllExport static SharedSession * Create(SharedSessionHeader * apHeader, long & arRef,
																					const unsigned char * apUID,
																					const unsigned char * apParentUID
																					/* long aOwnerID */);

	// create a new session.  The reference count will be 1.
	// aParentID can be -1 if the session has no parent.
	DllExport static SharedSession * Create(SharedSessionHeader * apHeader, long & arRef,
																					const unsigned char * apUID,
																					long aParentID
																					/* long aOwnerID */);

	// increase the reference count.  Must be matched with Release.
	// returns the new ref count (for debugging).
	DllExport int AddRef();

	// release a reference to the session and delete it
	// if there are no more references outstanding
	// returns the new ref count (for debugging)
	DllExport int Release(SharedSessionHeader * apHeader);

	// force the session to be deleted.  Any existing references
	// to it will become invalid.  Used to purge lost sessions.
	// NOTE: don't use this function without good reason!
	DllExport void DeleteForcefully(SharedSessionHeader * apHeader);


	// return the current reference count (for debugging)
	DllExport int GetRefCount() const;

	// indicate that the processing on this session is complete.
	// the return flag is TRUE if all processing on this group of sessions is complete
	DllExport void MarkComplete(SharedSessionHeader * apHeader,
															BOOL & arGroupComplete);

	// mark the parent of this session as failed
	DllExport void MarkRootAsFailed(SharedSessionHeader * apHeader);

	// lookup a session by its MSIX UID.
	// this does a hashtable search so it's fairly quick
	DllExport static SharedSession * FindWithUID(SharedSessionHeader * apHeader,
																							 long & arRef,
																							 const unsigned char * apUID);

	// get the index of this session
	DllExport long GetSessionID(SharedSessionHeader * apHeader) const;

	// get the service ID of this session
	DllExport long GetServiceID() const;

	// set the service ID of the current service
	DllExport void SetServiceID(long aService);

	// get the database ID of this session
	DllExport long GetRealID() const;

	// set the database ID of this session
	DllExport void SetRealID(long aRealID);

	// get the object owner ID of this session
	DllExport long GetObjectOwnerID() const;

	//  set the object owner ID of this session
	DllExport void SetObjectOwnerID(long aRealID);

	// return TRUE if the object owner is managed by the session
	// and needs to be deleted when the session is deleted
	DllExport BOOL ObjectOwnerIsTemporary() const;

	// set the UID of this session
	DllExport void SetUID(const unsigned char * apUID);

	// return TRUE if the UID equals the argument
	DllExport BOOL UIDEquals(const unsigned char * apUID) const;

	// get the UID of this session
	DllExport const unsigned char * GetUID() const;

	// get the parent ID of this session
	DllExport long GetParentID() const;

	// set the parent ID of this session and adds 
  // this session to the parent's child set.
  // Requires that the parent id of the session is currently -1.
	DllExport void SetParentID(SharedSessionHeader * apHeader,
                             long parentID);

	// get the session's state/info flags
	DllExport long GetSessionInfo() const;

	// set the session's state/info flags
	DllExport void SetSessionInfo(long aSessionInfo);

	// set the next session in this bucket (used for hash lookups)
	DllExport void SetNextInBucket(long aNext);

	// get the next session in this bucket (used for hash lookups)
	DllExport long GetNextInBucket() const;

	// get property of a session by name
	DllExport const SharedPropVal *
	GetReadablePropertyWithID(SharedSessionHeader * apHeader,
														long aNameId) const;

	// get property of a session by name that can be further modified
	DllExport SharedPropVal * GetWriteablePropertyWithID(SharedSessionHeader * apHeader,
																											 long aNameId) const;

	// add a property to a session
	DllExport SharedPropVal * AddProperty(SharedSessionHeader * apHeader,
																				long & arRef, long aNameId);

	// return TRUE if this session is a parent session
	DllExport BOOL IsParent() const;

	// return session set ID of the set that holds the children
	DllExport long GetChildSetID() const;

	// add a child to this session
	DllExport BOOL AddChild(SharedSessionHeader * apHeader, long aChildID);

	// enumerate through properties
	DllExport void GetProps(const SharedSessionHeader * apHeader,
													const SharedPropVal * * apFirst,
													int * apHashBucket) const;
	DllExport void GetNextProp(const SharedSessionHeader * apHeader,
														 const SharedPropVal * * apProp,
														 int * apHashBucket) const;

	// delete all props associated with a session
	DllExport void DeleteProps(SharedSessionHeader * apHeader);

	// retrieve the current state of the session
	DllExport SessionState GetCurrentState() const;

	// retrieve the current state of the session
	DllExport void SetCurrentState(SessionState aState);

	// retrieve the current state of the session
	DllExport int GetCurrentOwnerStage() const;

	// set the current state of the session
	DllExport void SetCurrentOwnerStage(int aStageID);

	// add one or more events to the list of events the session
	// is registered for.
	DllExport void AddEvents(int aEventCodes);

	// remove one or more events from the list of event that the
	// session is registered for.
	DllExport void RemoveEvents(int aEventCodes);

	// test to see if the session is registered for all the
	// given events
	DllExport BOOL TestForEvents(int aEventCodes) const;

	// return the union of all the events the session is registered for.
	DllExport int GetAllEvents() const;

	// for debugging only: dump a session and its properties
	DllExport void DumpSession(SharedSessionHeader * apHeader);

private:
	// internals of both versions of Create()
	static SharedSession * CreateInternal(SharedSessionHeader * apHeader,
																				long & arRef, const unsigned char * apUID,
																				long aParentId /* long aOwnerID */);

	// hash a property ID
	static int HashKey(long aNameId);

	// get property of a session by name
	SharedPropVal * GetPropertyWithID(SharedSessionHeader * apHeader,
																		long aNameId) const;


	// delete the session and everything associated with it
	void Delete(SharedSessionHeader * apHeader);

	// internally used by GetNextProp and GetProps
	void NextProp(const SharedSessionHeader * apHeader,
								const SharedPropVal * * apProp,
								int * apHashBucket) const;
};

/************************************************* SharedSet ***/

class DllExport SharedSet
{
	friend FixedSizePool<SharedSet>;

public:
	enum
	{
		UID_LENGTH = 16							// length of an MSIX UID in bytes
	};

public:
	union
	{
		long mNextFree;

		struct
		{
			// MSIX UID for this set.  initially set to NULL but
			// can be overridden.
			unsigned char mUID[UID_LENGTH];

			// service ID of sessions within this set
			long mServiceID;

			// index of first node in this set
			long mFirstNode;

			// unique identifier identifying the owner of this session.
			// each client can garbage collect sessions belonging to it 
			// using this identifier
			int mOwnerID;

			// number of outstanding references
			// to this session.  When this drops to
			// 0, the session can be released.
			int mRefCount;

			// number of clients waiting for activity in this session
			int mWaitingCount;

			// union of the events clients are waiting for
			int mEventMask;

			// count of session in the set.  used for quick count computation
			short int mCount;
		};
	};

private:
	// these methods are only used by FixedSizePool..
	long GetNextFree() const
	{ return mNextFree; }

	void SetNextFree(long aNext)
	{ mNextFree = aNext; }

public:
	// create a new set.  the reference count will be 1
	static SharedSet * Create(SharedSessionHeader * apHeader,
																long & arRef);

	// increase the reference count.  Must be matched with Release.
	// returns the new ref count (for debugging).
	int AddRef();

	// release a reference to the set and delete it
	// if there are no more references outstanding
	// returns the new ref count (for debugging)
	int Release(SharedSessionHeader * apSessionHeader);

	// return the current reference count (for debugging)
	int GetRefCount() const;

	// add an empty property to the set
	const SharedSetNode * AddToSet(SharedSessionHeader * apHeader, long aSessionID);

	// return the first property in the set
	const SharedSetNode * First(SharedSessionHeader * apHeader) const;

	// set the UID of this session
	void SetUID(const unsigned char * apUID);

	// return TRUE if the UID equals the argument
	BOOL UIDEquals(const unsigned char * apUID) const;

	// get the UID of this session
	const unsigned char * GetUID() const;

	// get the ID of the set
	long GetSetID(SharedSessionHeader * apHeader)
	{ return this - apHeader->GetSetStart(); }

	int GetCount() const;

private:
	void Delete(SharedSessionHeader * apSessions);
};

/***************************************** SharedObjectOwner ***/

// these objects are used to track the state of groups of objects (currently
// only sessions).  After the entire group of objects change state,
// a message is sent to a stage.
// this is used for synchronous processing and compound handling.

class SharedObjectOwner
{
	friend FixedSizePool<SharedObjectOwner>;

public:
	enum ActionType
	{
		// perform no action
		OBJECT_OWNER_NO_ACTION,
		// send a message to a stage
		OBJECT_OWNER_NOTIFY_STAGE,
		// send feedback to the listener
		OBJECT_OWNER_SEND_FEEDBACK,
		// check for errors, clean up sessions, etc.
		OBJECT_OWNER_COMPLETE_PROCESSING,
	};

private:
	union
	{
		long mNextFree;

		struct
		{
			// total number of objects we "own".  this count doesn't change
			// after it's initially set.
			long mTotalCount;
			// this count is initially set to mTotalCount.  When
			// it drops to zero, an event is fired, going to the stage specified
			// in mOwnerStage.
			long mWaitingCount;

			// if true, an error has occurred in at least one member of the group
			BOOL mErrorFlag;

			// typed union that holds different data depending on the action required
			ActionType mActionType;

			union
			{
				// stage waiting for events on this group.  When mWaitingCount
				// drops to zero, a message is sent to this stage.
				long mOwnerStage;

				// session set that will require feedback.
				long mFeedbackOnSessionSet;
			};

			struct Transaction
			{
				// pointer to IMTTransaction interface
				IUnknown * mpTransaction;
				// process ID is stored along with IUknown pointer
				// so we are less likely to crash when a new processing
				// tried to read this value
				long mProcessID;

				// ID of the string containing the transaction ID (cookie)
				// -1 if not set
				long mTransactionID;
			} mTransaction;

			struct SessionContext
			{
				// pointer to IMTSessionContext interface
				IUnknown * mpSessionContext;
				// process ID is stored along with IUnknown pointer
				// so we are less likely to crash when a new processing
				// tried to read this value
				long mProcessID;

				// ID of the extra large string containing the
				// serialized session context.
				// -1 if not set
				long mSerializedContextID;

				// ID of the string containing the username
				// -1 if not set
				long mUsernameID;

				// ID of the string containing the username
				// -1 if not set
				long mPasswordID;

				// ID of the string containing the username
				// -1 if not set
				long mNamespaceID;
			} mSessionContext;

			struct RSIDCacheRef
			{
				// pointer to RSIDCache object
				IUnknown * mpRSIDCache;
				// process ID is stored along with IUnknown pointer
				// so we are less likely to crash when a new processing
				// tried to read this value
				long mProcessID;
			} mRSIDCache;

			// ID of the next SharedObjectOwner that is interested in this
			// object.  -1 if not set.  this allows SharedObjectOwners to be
			// chained together when more than one stage is interested in a group
			// being completed.
			int mNextObjectOwnerID;

			// number of outstanding references
			// to this object  When this drops to
			// 0, the object can be released.
			int mRefCount;

      // Allow synchronization on the object owner.  This is how we deal
      // with the fact that it is illegal to have concurrency within a transaction.
      // Today that concurrency can occur when one has a compound with multiple
      // service types as children (think conference connections and features).
      // We must prevent stages for these children from executing concurrently
      // on the same session set.  Luckily, the "root" object owner of the compound
      // is already a well-define place that we can synchronize on (note that the
      // "root" object owner is where the transaction is managed, so it is pretty
      // clear that this is the correct synchronization boundary).
      //
      // That said, there are many problems with this implementation:
      // 1) it is not multi-process safe (nor does it really NEED to be)
      // 2) there are no NT synchronization primitives that can be safely
      // placed in shared memory (CRITICAL_SECTIONs) are intrinsically single
      // process and mutex HANDLEs are not valid across process boundaries.
      // 
      // The approach we take is to use a critical section.  It must be initialized
      // by the process that is going to use the CS (the cmdstage process).  Note that
      // initialization occurs after creation (done by pipesvc) hence the CS cannot be
      // initialized in a c'tor.  CS initialization is made thread safe by allocating
      // CRITICAL_SECTION structures on the heap and doing an atomic pointer swap in.
      struct LockRef
      {
        CRITICAL_SECTION * mpCriticalSection;
        long mProcessID;
      } mLock;
		};
	};

public:
	long GetTotalCount() const
	{ return mTotalCount; }

	long GetWaitingCount() const
	{ return mWaitingCount; }

	// return true if the waiting count has dropped to zero
	BOOL IsComplete() const
	{ return GetWaitingCount() == 0; }

	// reduce the waiting count by 1 and return true if the resulting
	// count is 0
	DllExport BOOL DecrementWaitingCount();

	DllExport void InitForNotifyStage(int aTotalCount, int aOwnerStage);

	DllExport void InitForSendFeedback(SharedSessionHeader * apHeader,
																		 int aTotalCount, int aSetID);

	DllExport void InitForCompleteProcessing(SharedSessionHeader * apHeader,
																					 int aTotalCount, int aSetID);

	ActionType GetActionType() const
	{ return mActionType; }

	// get the index of a session
	long GetID(SharedSessionHeader * apHeader)
	{ return this - apHeader->GetSharedObjectOwnerStart(); }

	// get the owner stage (only for action type OBJECT_OWNER_NOTIFY_STAGE)
	DllExport long GetOwnerStageID() const;

	// get the session set that needs feedback or needs to complete processing
	// (only for action type OBJECT_OWNER_SEND_FEEDBACK or
	// OBJECT_OWNER_COMPLETE_PROCESSING)
	DllExport long GetSessionSetID() const;

	// get the owner stage
	long GetNextObjectOwnerID() const
	{ return mNextObjectOwnerID; }

	// get the owner stage
	DllExport void SetNextObjectOwnerID(SharedSessionHeader * apHeader, int aNext);

	// increase the reference count.  Must be matched with Release.
	// returns the new ref count (for debugging).
	DllExport int AddRef();

	// release a reference to the session and delete it
	// if there are no more references outstanding
	// returns the new ref count (for debugging)
	DllExport int Release(SharedSessionHeader * apHeader);

	// flag that at least one session within the group has failed
	DllExport void FlagError();

	// return true if any session within the group has failed
	DllExport BOOL GetErrorFlag() const;

	// set the transaction pointer.  If the transaction pointer
	// has already been set, this method returns FALSE
	DllExport BOOL SetTransaction(IUnknown * apTran);

	// return a reference to the transaction, doing an addref on the returned value.
	// the returned value may be null.
	DllExport void GetTransaction(IUnknown * * apTran) const;

	// sets the transaction ID (cookie).  If the transaction ID
	// has already been set, this method returns FALSE
	DllExport BOOL SetTransactionID(SharedSessionHeader * apHeader, const char * apTransactionID );

	// returns the transaction ID or NULL if not set
	DllExport const char * GetTransactionID(SharedSessionHeader * apHeader) const;

	// set the session context pointer.  If the session context
	// has already been set, this method returns FALSE.
	DllExport BOOL SetSessionContext(IUnknown * apContext);

	// return a reference to the session context, doing an addref on the returned value.
	// the returned value may be null.
	DllExport void GetSessionContext(IUnknown * * apContext) const;

	// set the serialized session context.  if the session context
	// has already been set, this method returns FALSE.
	DllExport BOOL SetSerializedSessionContext(SharedSessionHeader * apHeader,
																						 const wchar_t * apContext);

	// return true if we know the serialized session context.
	DllExport BOOL IsSerializedSessionContextSet();

	// return the serialized session context or NULL if not set.
	// NOTE: the caller must delete this buffer
	DllExport wchar_t * CopySerializedSessionContext(
		SharedSessionHeader * apHeader) const;

	// set the session context credentials (username, password, namespace).
	// if the credentials have already been set, this method returns FALSE.
	DllExport BOOL SetSessionContextCredentials(
		SharedSessionHeader * apHeader,
		const char * apUsername, const char * apPassword, const char * apNamespace);

	// return the session context credentials.  returns FALSE if they
	// haven't been set.
	DllExport BOOL GetSessionContextCredentials(
		SharedSessionHeader * apHeader,
		const char * * apUsername, const char * * apPassword,
		const char * * apNamespace) const;

	// set the session context user name
	// if the user name has already been set (either by calling this method or
	//SetSessionContextCredentials), this method will return false
	DllExport BOOL SetSessionContextUserName(
		SharedSessionHeader * apHeader,
		const char * apUsername);

	// set the session context password
	// if the password has already been set (either by calling this method or
	//SetSessionContextCredentials), this method will return false
	DllExport BOOL SetSessionContextPassword(
		SharedSessionHeader * apHeader,
		const char * apPassword);

	// set the session context namespace
	// if the namespace has already been set (either by calling this method or
	//SetSessionContextCredentials), this method will return false
	DllExport BOOL SetSessionContextNamespace(
		SharedSessionHeader * apHeader,
		const char * apNamespace);

	// get the session context user name or NULL
	//if it hasn't been set yet
	DllExport const char * GetSessionContextUserName(
		SharedSessionHeader * apHeader) const;

	// get the session context user name or NULL
	//if it hasn't been set yet
	DllExport const char * GetSessionContextPassword(
		SharedSessionHeader * apHeader) const;


	// get the session context user name or NULL
	//if it hasn't been set yet
	DllExport const char * GetSessionContextNamespace(
		SharedSessionHeader * apHeader) const;

	// return a reference to the rate schedule ID cache,
	// doing an addref on the returned value.
	// the returned value may be null.
	DllExport void GetRSIDCache(IUnknown * * apCache) const;

	// set the transaction pointer.  If the transaction pointer
	// has already been set, this method returns FALSE
	DllExport BOOL SetRSIDCache(IUnknown * apTran);


	// create an object and initialize the ref count
	static DllExport SharedObjectOwner * Create(SharedSessionHeader * apHeader);	

  // Synchronization interface
  DllExport BOOL InitLock();
  DllExport void Lock();
  DllExport void Unlock();
private:
	// delete all object owners chained together
	void Delete(SharedSessionHeader * apHeader);

	// these methods are only used by FixedSizePool..
	long GetNextFree() const
	{ return mNextFree; }

	void SetNextFree(long aNext)
	{ mNextFree = aNext; }
};

/********************************************* SharedSetNode ***/

class DllExport SharedSetNode
{
	friend SharedSet;
	friend FixedSizePool<SharedSetNode>;

	union
	{
		long mNextFree;

		struct
		{
			long mID;
			// TODO: do we need service ID?
			//long mServiceID;
			long mNextNode;
		};
	};

private:
	// these methods are only used by FixedSizePool..
	long GetNextFree() const
	{ return mNextFree; }

	void SetNextFree(long aNext)
	{ mNextFree = aNext; }

public:
	// return a pointer to the next node in the list
	const SharedSetNode * Next(SharedSessionHeader * apHeader) const;

	// get the index of a session
	long GetSetNodeID(SharedSessionHeader * apHeader)
	{ return this - apHeader->GetSetNodeStart(); }

	long GetID() const
	{ return mID; }

private:
	void Delete(SharedSessionHeader * apHeader);

	void SetSession(long aSessionID, SharedSession * apSession);
};



/********************************************* SharedPropVal ***/

class DllExport SharedPropVal
{
	friend FixedSizePool<SharedPropVal>;
public:
	enum Type
	{
		FREE_PROPERTY,

		OLEDATE_PROPERTY,
		TIMET_PROPERTY,

		TIME_PROPERTY,

		ASCII_PROPERTY,
		UNICODE_PROPERTY,

		LONG_PROPERTY,
		DOUBLE_PROPERTY,

		BOOL_PROPERTY,

		ENUM_PROPERTY,

		DECIMAL_PROPERTY,

		TINYSTRING_PROPERTY,

		OBJECT_PROPERTY,

		EXTRA_LARGE_STRING_PROPERTY,

    LONGLONG_PROPERTY
	};

	enum
	{
		// NOTE: this size is hardcoded to the size of
		// DECIMAL.  An ASSERT is used to verify that the
		// size is correct.
		DECIMAL_SIZE = 16
	};
private:
	union
	{
		long mNextFree;

		struct
		{
			// name of this property
			long mNameID;

			enum Type mType;
			union
			{
				double mDoubleVal;
				long mLongVal;
				BOOL mBoolVal;
				long mStringValID;
				long mEnumVal;
        time_t mTimeVal;
				unsigned char mDecimalVal[DECIMAL_SIZE];
				// NOTE: this value should be exactly the same size as mDecimalVal
				wchar_t mTinyString[DECIMAL_SIZE/2];
				struct ObjectVal
				{
					IUnknown * mpInterface;
					// process ID is stored along with IUknown pointer
					// so we are less likely to crash when an old property is left
					// around
					long mProcessID;
				} mObjectVal;
        __int64 mLongLongVal;
			};

			long mNextProp;
		};
	};

private:
	// these methods are only used by FixedSizePool..
	long GetNextFree() const
	{ return mNextFree; }

	void SetNextFree(long aNext)
	{ mNextFree = aNext; }

public:
	//void Init();
	void Init(long aNameId);

	Type GetType() const
	{ return mType; }

	long GetNameID() const
	{ return mNameID; }

	void SetFreeValue()
	{ mType = FREE_PROPERTY; }

	void SetDoubleValue(double aDoubleVal);
	double GetDoubleValue() const;

	void SetLongValue(long aLongVal);
	long GetLongValue() const;

	void SetOLEDateValue(double aDateProp);
	double GetOLEDateValue() const;

	void SetDateTimeValue(time_t aDateTime);
	time_t GetDateTimeValue() const;

	void SetTimeValue(long aTime);
	long GetTimeValue() const;

	void SetAsciiIDValue(int aID);
	int GetAsciiIDValue() const;

	void SetUnicodeIDValue(int aID);
	int GetUnicodeIDValue() const;

	void SetBooleanValue(BOOL aProp);
	BOOL GetBooleanValue() const;

	void SetEnumValue(long aLongVal);
	long GetEnumValue() const;

	void SetDecimalValue(const unsigned char * apDecimalVal);
	const unsigned char * GetDecimalValue() const;

	void SetTinyStringValue(const wchar_t * apStr);
	const wchar_t * GetTinyStringValue() const;

	BOOL SetExtraLargeStringValue(SharedSessionHeader * apHeader,
																const wchar_t * apStr);
	wchar_t * CopyExtraLargeStringValue(SharedSessionHeader * apHeader) const;

	void SetObjectValue(IUnknown * aProp);
	// return a reference to the object, doing an addref on the returned value
	void GetObjectValue(IUnknown * * apVal) const;

	void SetLongLongValue(__int64 aLongLongVal);
	__int64 GetLongLongValue() const;

	// set the type/value based on another property
	void CopyValue(const SharedPropVal * apOrig);

	// get the next property in the chain
	long GetNextProp() const
	{ return mNextProp; }

	// set the next property in the chain
	void SetNextProp(long aNextId)
	{ mNextProp = aNextId; }

	// release any string memory associated with the structure
	// and set the type to free
	void Clear(SharedSessionHeader * apHeader);

	// clear an object value (called by Clear())
	void ClearObjectVal();
};

#endif /* _SHAREDSESS_H */
