#ifndef __SPINLOCK_H__
#define __SPINLOCK_H__

#pragma warning(disable : 4793)

#ifdef WIN32
#include "metra.h"
#else
#include "metralite.h"
#endif
#include <boost/cstdint.hpp>

namespace MetraFlow
{
  class SpinLock
  {
  public:
    typedef class SpinLockGuard Guard;
  private:
    volatile boost::uint32_t mutex;
    boost::uint32_t mTotalSleep;
    boost::int64_t mTotalSpin;
    enum { UNLOCKED = 0, LOCKED =1 };
  public:
    SpinLock()
      :
      mutex(UNLOCKED),
      mTotalSleep(0),
      mTotalSpin(0)
    {
    }

    void Lock();
    void Unlock()
    {
      mutex = UNLOCKED;
    }
  };

  class SpinLockGuard
  {
  private:
    SpinLock & mLock;
  public:
    SpinLockGuard(SpinLock& lock)
      :
      mLock(lock)
    {
      mLock.Lock();
    }
    ~SpinLockGuard()
    {
      mLock.Unlock();
    }
  };



  inline void SpinLock::Lock()
  {
#ifdef WIN32
    boost::uint32_t spinCount = 1;
  again:
    volatile boost::uint32_t * target = &mutex;
    boost::uint8_t zf;
    __asm
      {
        mov eax, 0
          mov ebx, 1
          mov esi, [target]
          lock cmpxchg dword ptr [esi], ebx
          setz zf
          }
    if (zf) return;

    // Spin with exponential backoff
    {__asm{_emit 0xf3};__asm {_emit 0x90}}
    for(volatile boost::uint32_t q=0; q<spinCount; q++) 
    {
    }
    spinCount <<= 1;
    if (spinCount > 1024)
    {
      ::Sleep(0);
      spinCount = 1;
    }
    goto again;
#else
    // TODO: Implement
    mutex = 1;
#endif
  }
}

#endif
