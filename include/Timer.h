#ifndef __TIMER_H__
#define __TIMER_H__

#include <metra.h>

class Timer
{
private:
  __int64 mTicks;
  __int64 mEvents;
public:
  Timer()
    :
    mTicks(0LL),
    mEvents(0LL)
  {
  }

  void Reset()
  {
    mTicks = 0LL;
    mEvents = 0LL;
  }

  void operator+= (__int64 ticks)
  {
    mTicks += ticks;
    mEvents += 1;
  }

  __int64 GetMilliseconds() const
  {
    LARGE_INTEGER freq;
    ::QueryPerformanceFrequency(&freq);
    return (1000LL*mTicks)/freq.QuadPart;
  }
  __int64 GetEvents() const
  {
    return mEvents;
  }
};

class ScopeTimer
{
private:
  LARGE_INTEGER mTick;
  Timer * mAccumulator;
public:
  ScopeTimer(Timer * accumulator)
    :
    mAccumulator(accumulator)
  {
    ::QueryPerformanceCounter(&mTick);
  }

  ~ScopeTimer()
  {
    LARGE_INTEGER tock;
    ::QueryPerformanceCounter(&tock);
    (*mAccumulator) += tock.QuadPart - mTick.QuadPart;
  }
};

#endif
