/**************************************************************************
 * @doc FIXEDPOOL
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
 * @index | FIXEDPOOL
 ***************************************************************************/

#ifndef _FIXEDPOOL_H
#define _FIXEDPOOL_H

// offset a pointer by the given number of bytes and return
// a pointer of a new type
template <class T, class P> T * OffsetPointer(P * ptr, long offset)
{
	return (T *) (((unsigned char *) ptr) + offset);
}

// return the different in bytes between ptr1 and ptr2
inline long PointerDiff(void * ptr1, void * ptr2)
{
	return (unsigned char *) ptr1 - (unsigned char *) ptr2;
}


/**************************************** FixedSizePoolStats ***/

struct FixedSizePoolStats
{
	long mSize;
	long mMaxAllocated;
	long mCurrentlyAllocated;
};

class SpinLock
{
private:
  union {
    double _dummy; // force 8 bytes alignment
    struct
    {
      volatile LONG mutex;
      LONG pad;
    };
  };
  enum { UNLOCKED = 0, LOCKED =1 };
public:
  SpinLock()
  {
  }

  void Init()
  {
    mutex = UNLOCKED;
    pad = 0xbaadf00d;
  }
 
  void Acquire()
  {
    int spinCount = 1;
    while(true)
    {
      if (UNLOCKED == ::InterlockedExchange(&mutex, LOCKED))
      {
        // Previously unlocked; now locked.  We got it!
        return;
      }

      // Spin with exponential backoff
      {__asm{_emit 0xf3};__asm {_emit 0x90}}
      for(volatile int q=0; q<spinCount; q++) {}
      spinCount <<= 1;
      if (spinCount > 1024)
      {
        // We are really contending hard! Yield to OS.
        ::Sleep(0);
        spinCount = 1;
      }
    }
  }

  void Release()
  {
    mutex = UNLOCKED;
  }
};


/********************************************* FixedSizePool ***/

template<class T>
class FixedSizePool
{
private:
  // Spin lock to protect list
  SpinLock mLock;

	// start of the pool of structures (offset from this)
	long mPoolStart;

	// number of structures that fit in this space
	long mPoolSize;

	// max number of structures that were ever allocated at one time.
	// this number is purely for statistics
	long mMaxAllocated;

	// current number of structures in the pool at this time.
	// purely for statistics.
	volatile long mCurrentlyAllocated;

  struct FreeListHeader
  {
    union
    {
      volatile __int64 mTaggedHeader;
      struct 
      {
        volatile long mTag;
        volatile long mFreeList;
      };
    };
  };

	// index to the first available free structure
  FreeListHeader mHeader;

public:
	// return a pointer to the start of the pool
	T * GetStart() const
	{
		return OffsetPointer<T, const unsigned char>
			((const unsigned char *) this, mPoolStart);
	}

	// return a pointer to the byte immediately after the pool
	T * GetEnd() const
	{
		GetStart() + GetSize();
	}

	// return the number of structures that will fit in this pool
	long GetSize() const
	{ return mPoolSize; }

	// return the max number of structures that were ever in the pool
	long GetMaxAllocated() const
	{ return mMaxAllocated; }

	// return the current number of structures in the pool
	long GetCurrentlyAllocated() const
	{ return mCurrentlyAllocated; }

	void GetStats(FixedSizePoolStats & arStats) const;

	// initialize the pool
	BOOL Initialize(void * apMem, long aByteSize);

	// return a pointer to the given element after
	// doing a range check
	T * GetElement(long aID) const
	{
		ASSERT(aID >= 0 && aID < mPoolSize);
		return GetStart() + aID;
	}

	// return a free structure within the pool
	T * CreateElement(long & arRef);

	// delete a structure from the pool
	void DeleteElement(long aRef);
};

template <class T>
void FixedSizePool<T>::GetStats(FixedSizePoolStats & arStats) const
{
	arStats.mSize = GetSize();
	arStats.mMaxAllocated = GetMaxAllocated();
	arStats.mCurrentlyAllocated = GetCurrentlyAllocated();
}

template <class T>
BOOL FixedSizePool<T>::Initialize(void * apMem, long aByteSize)
{
  // Initialize Spin lock to unlocked
  mLock.Init();

	// offset to data
	mPoolStart = PointerDiff(apMem, this);

	// number of structures we can fit
	mPoolSize = aByteSize / sizeof(T);

	// initialize set pool to all free structures
	T * start = GetStart();

	// establish free list links
	for (int i = 0; i < mPoolSize - 1; i++)
	{
		T * elem = start + i;
		// next free is the next structure
		elem->SetNextFree(i + 1);
	}

	// end of list
	start[i].SetNextFree(-1);

	// first free index
	mHeader.mFreeList = 0;

	// haven't allocated more than 0
	mMaxAllocated = 0;

	// currently an empty pool
	mCurrentlyAllocated = 0;

	return TRUE;
}

template <class T>
T * FixedSizePool<T>::CreateElement(long & arRef)
{
// 	T * elem = NULL;
//   mLock.Acquire();

//   arRef = mFreeList;
//   if (arRef == -1) 
//   {
//     mLock.Release();
//     return NULL;
//   }
//   elem = GetElement(arRef);
//   mFreeList = elem->GetNextFree();
//   if (mFreeList < 0 || mFreeList >= mPoolSize)
//   {
//     throw std::exception("Invalid pointer");
//   }
//   mLock.Release();


// 	// one more in the pool
// 	ASSERT(mCurrentlyAllocated >= 0);
// 	long nowAllocated = ::InterlockedIncrement(&mCurrentlyAllocated);

// 	// update the max 
//   // NOTE: this may not be atomic and therefore is possibly slightly inaccurate
// 	if (mCurrentlyAllocated > mMaxAllocated)
// 		mMaxAllocated = mCurrentlyAllocated;

// 	return elem;
	T * elem = NULL;

  DWORD dwTag = ::GetCurrentThreadId();
again:
  volatile __int64 * target = &mHeader.mTaggedHeader;

  // Hmmm.  Does this write require a memory barrier?
  mHeader.mTag = dwTag;  
  long tmp = arRef = mHeader.mFreeList;
  if (arRef == -1) 
  {
    return NULL;
  }
  elem = GetElement(arRef);
  long next = elem->GetNextFree();

  unsigned char zf;
  __asm {
  // Move old value into edx, eax
    mov eax, dwTag
    mov edx, tmp
  // Move new value into edx, eax
    mov ebx, dwTag
    mov ecx, next
  // compare and exchange the target and store the result
    mov esi, [target]
    lock cmpxchg8b qword ptr [esi]
    setz zf
      };

  if (0 == zf) goto again;

// 	// one more in the pool
  // Must keep track of allocated for flow control
	ASSERT(mCurrentlyAllocated >= 0);
	long nowAllocated = ::InterlockedIncrement(&mCurrentlyAllocated);

	// update the max 
  // NOTE: this may not be atomic and therefore is possibly slightly inaccurate
	if (mCurrentlyAllocated > mMaxAllocated)
		mMaxAllocated = mCurrentlyAllocated;

	return elem;
}

template <class T>
void FixedSizePool<T>::DeleteElement(long aRef)
{
// 	ASSERT(aRef >= 0 && aRef < mPoolSize);
// 	T * elem = GetElement(aRef);
// 	ASSERT(elem);

//   mLock.Acquire();
//   elem->SetNextFree(mFreeList);
//   mFreeList = aRef;
//   mLock.Release();

// 	// one less in the pool
// 	long nowAllocated = ::InterlockedDecrement(&mCurrentlyAllocated);
// 	ASSERT(nowAllocated >= 0);
	ASSERT(aRef >= 0 && aRef < mPoolSize);
	T * elem = GetElement(aRef);

	ASSERT(elem);
again:
  long next = mHeader.mFreeList;
  volatile long * target = &mHeader.mFreeList;
  unsigned char zf;
  elem->SetNextFree(next);
  __asm
    {
      mov eax, next
      mov ebx, aRef
      mov esi, [target]
      lock cmpxchg dword ptr [esi], ebx
      setz zf
        }
  if (0 == zf) goto again;

	// one less in the pool
	long nowAllocated = ::InterlockedDecrement(&mCurrentlyAllocated);
	ASSERT(nowAllocated >= 0);
}


#endif /* _FIXEDPOOL_H */
