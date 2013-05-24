#ifndef __MULTIPLEXER_H__
#define __MULTIPLEXER_H__

#include "Scheduler.h"
#include <vector>

// A first (likely naive) stab at identifying a notion of 
// an input multiplexer that encapsulates useful patterns of
// consuming input.  The obvious examples of this are 
// 1) Nondeterministic merge with round robin fairness
// 2) Deterministic round robin merge
// 3) Deterministic sort merge
//
// We want this object to make the logic for reading from
// multiple inputs reusable without making any assumptions
// about how the outputs will be handled (e.g. we may have
// a collector that merges the inputs into a single output 
// stream or we may have something like running total
// or hash join that keeps the inputs under the management of
// the multiplexer separate).
//
// For efficiency, I want to use templates for this and define
// a "concept" for multiplexers and then allow operators that 
// need these to incorporate them as template parameters.
class NonDeterministicInputMultiplexer
{
private:
  Endpoint * mNextRead;
public:
  NonDeterministicInputMultiplexer()
    :
    mNextRead(NULL)
  {
  }

  ~NonDeterministicInputMultiplexer()
  {
  }

  void Start(std::vector<Endpoint *>::iterator _Begin,
             std::vector<Endpoint *>::iterator _End)
  {
    for(std::vector<Endpoint *>::iterator it = _Begin;
        it != _End;
        it++)
    {
      if ((it + 1) != _End)
        (*(it + 1))->LinkRequest(*it);
    }
    mNextRead = *_Begin;
  }

  void RequestRead(Reactor * reactor, RunTimeOperatorActivation * op)
  {
    reactor->RequestRead(op, mNextRead);
  }

  void OnRead(Endpoint * ep)
  {
    // For fairness, the highest priority read will be the next one.
    // (or will it be the previous one)
    mNextRead = ep->NextRequest();
  }

  bool OnEOF(Endpoint * ep)
  {
    // For fairness, the highest priority read will be the next one.
    // (or will it be the previous one).  UnlinkRequest returns NextRequest()
    // if valid, otherwise NULL.
    mNextRead = ep->UnlinkRequest();
    return mNextRead == NULL;
  }

  bool IsEOF() const
  {
    return mNextRead == NULL;
  }
};

#endif
