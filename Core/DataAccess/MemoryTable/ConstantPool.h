#ifndef __CONSTANT_POOL_H__
#define __CONSTANT_POOL_H__

#include "metralite.h"
#include <boost/thread/mutex.hpp>

#include "MetraFlowConfig.h"
#include "SpinLock.h"

class RegionAllocator
{
private:
  // Regions
  struct Region
  {
    struct Region * mNext;
    unsigned char * mCommitted;
    unsigned char * mEnd;
    unsigned char * mPreviousCommitted;
  };

  struct Region * CreateRegion(struct Region * next)
  {
    struct Region * tmp = (struct Region *) ::malloc(1024*1024);
    tmp->mNext = next;
    tmp->mCommitted = (unsigned char *) (tmp + 1);
    tmp->mEnd = ((unsigned char *)tmp) + 1024*1024;
    tmp->mPreviousCommitted = NULL;
    return tmp;
  }


  // Region list
  struct Region * mHead;
  boost::mutex mLock;
public:
  METRAFLOW_DECL RegionAllocator();
  METRAFLOW_DECL ~RegionAllocator();

  METRAFLOW_DECL void * nonserialized_malloc(size_t sz);
  METRAFLOW_DECL void * malloc(size_t sz);
  METRAFLOW_DECL void free(void * ptr);
  // The only free that we can really do; free the last
  // allocated chunk of memory.
  METRAFLOW_DECL void free_last();
};

class CacheParameters
{
public:
  enum { _CacheLineSizeLog2 = 7, _CacheLineSize = 128, _HashSentinelPosition=_CacheLineSize/(2*sizeof (unsigned int)) - 1, _BufferSize = 1024*1024, _CacheLineEntries = _CacheLineSize/sizeof(boost::int64_t), _LastEntry = _CacheLineEntries-1 };
};

class WideStringConstantPool
{
private:
  struct Node
  {
    struct Node * mNext;
    wchar_t * GetStringBuffer()
    {
      return (wchar_t *) (this + 1);
    }
  };

  enum { SIZE=1024*1024 };

  struct Node * mTable[SIZE];

  static unsigned int hashfunc(const unsigned char * s, int len);
  
  RegionAllocator mAllocator;

  WideStringConstantPool();
  ~WideStringConstantPool();

  static MetraFlow::SpinLock sLock;
  static WideStringConstantPool * pool;
  static int sNumRefs;

public:
  METRAFLOW_DECL static WideStringConstantPool* GetInstance();
  METRAFLOW_DECL static void ReleaseInstance();
  METRAFLOW_DECL wchar_t * GetWideStringConstant(const wchar_t * val);
  METRAFLOW_DECL wchar_t * GetWideStringConstant(const wchar_t * val, int strLen);
};


#endif
