/**************************************************************************
 * @doc OBJECTPOOL
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
 * @index | OBJECTPOOL
 ***************************************************************************/

#ifndef _OBJECTPOOL_H
#define _OBJECTPOOL_H

/******************************************* ObjectPoolStats ***/

struct ObjectPoolStats
{
	// number of structures that fit in this space
	long mSize;

	// max number of structures that were ever allocated at one time.
	// this number is purely for statistics
	long mMaxAllocated;

	// current number of structures in the pool at this time.
	// purely for statistics.
	long mCurrentlyAllocated;
};

/************************************************ ObjectPool ***/

template<class T, int N>
class ObjectPool
{
private:
	struct Holder
	{
		T mValue;
		Holder * mpNextFree;
	};

public:
	ObjectPool()
	{
		Initialize();
	}

	// return the number of structures that will fit in this pool
	long GetSize() const
	{ return mStats.mSize; }

	// return the max number of structures that were ever in the pool
	long GetMaxAllocated() const
	{ return mStats.mMaxAllocated; }

	// return the current number of structures in the pool
	long GetCurrentlyAllocated() const
	{ return mStats.mCurrentlyAllocated; }

	void GetStats(ObjectPoolStats & arStats) const;

#if 0
	// return a pointer to the given element after
	// doing a range check
	T * GetElement(long aID) const
	{
		ASSERT(aID >= 0 && aID < mPoolSize);
		return GetStart() + aID;
	}
#endif

	// return a free structure within the pool
	T * CreateElement();

	// delete a structure from the pool
	BOOL DeleteElement(T * apObj);

private:
	// initialize the pool
	void Initialize();

private:
	ObjectPoolStats mStats;

	Holder mElements[N];

	// index to the first available free structure
  // Also uses a tag to deal with the ABA problem.
  struct FreeListHeader
  {
    union
    {
      volatile __int64 mTaggedHeader;
      struct 
      {
        volatile long mTag;
        Holder * volatile mFreeList;
      };
    };
  };

	// index to the first available free structure
  FreeListHeader mHeader;
};

template <class T, int N>
void ObjectPool<T,N>::GetStats(ObjectPoolStats & arStats) const
{
	arStats.mSize = GetSize();
	arStats.mMaxAllocated = GetMaxAllocated();
	arStats.mCurrentlyAllocated = GetCurrentlyAllocated();
}

template <class T, int N>
void ObjectPool<T,N>::Initialize()
{
	mStats.mSize = N;
	// haven't allocated more than 0
	mStats.mMaxAllocated = 0;
	// currently an empty pool
	mStats.mCurrentlyAllocated = 0;
	
	// establish free list links
	for (int i = 0; i < mStats.mSize - 1; i++)
	{
		Holder * elem = mElements + i;
		// next free is the next structure
		elem->mpNextFree = elem + 1;
	}

	// end of list
	mElements[i].mpNextFree = NULL;

	// first free index
	mHeader.mFreeList = mElements;
}

template <class T, int N>
T * ObjectPool<T,N>::CreateElement()
{
	Holder * elem = NULL;
	Holder * nextFree = NULL;
  DWORD dwTag = ::GetCurrentThreadId();
again:
    volatile __int64 * target = &mHeader.mTaggedHeader;

    // Set tag to make sure we are the last in
    mHeader.mTag = dwTag;  

		// find the next free structure and attempt to get it
		nextFree = mHeader.mFreeList;
		if (!nextFree)
			return NULL;								// none free!

		elem = nextFree;
		Holder * next = elem->mpNextFree;

    unsigned char zf;
    __asm {
    // Move old value into edx, eax
    mov eax, dwTag
    mov edx, nextFree
    // Move new value into edx, eax
    mov ebx, dwTag
    mov ecx, next
    // compare and exchange the target and store the result
    mov esi, [target]
    lock cmpxchg8b qword ptr [esi]
    setz zf
    };

    if (0 == zf) goto again;

	// TODO: make these thread safe
	// one more in the pool
	mStats.mCurrentlyAllocated++;

	if (mStats.mCurrentlyAllocated > mStats.mMaxAllocated)
		mStats.mMaxAllocated = mStats.mCurrentlyAllocated;

	return &elem->mValue;
}

template <class T, int N>
BOOL ObjectPool<T,N>::DeleteElement(T * apObj)
{
	ASSERT(apObj);

	if (!apObj)
		return FALSE;

	// cast! CAREFUL: this can be really unsafe if the struct changes
	Holder * holder = (Holder *) apObj;

	// did the object come from the pool?
	// TODO: check if it's at the right byte boundary
	if (holder < mElements || holder >= mElements + N)
		return FALSE;

again:
  Holder * next = mHeader.mFreeList;
  Holder * volatile * target = &mHeader.mFreeList;
  unsigned char zf;
  holder->mpNextFree = next;
  __asm
    {
      mov eax, next
      mov ebx, holder
      mov esi, [target]
      lock cmpxchg dword ptr [esi], ebx
      setz zf
        }
  if (0 == zf) goto again;

	// one less in the pool
	::InterlockedDecrement(&mStats.mCurrentlyAllocated);

	return TRUE;
}


#endif /* _OBJECTPOOL_H */
