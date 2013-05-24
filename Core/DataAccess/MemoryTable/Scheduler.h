#ifndef __SCHEDULER_H__
#define __SCHEDULER_H__

#include "MetraFlowConfig.h"
#include "SpinLock.h"
#include "RecordModel.h"
#include "TypeCheckException.h"

#ifdef max
#undef max
#endif

#include <vector>
#include <set>
#include <limits>
#include <stdexcept>
// Pretty stupid, but we seem to require the archive includes
// before any serialization includes.
// #include <boost/archive/xml_woarchive.hpp>
// #include <boost/archive/xml_wiarchive.hpp>
#include <boost/cstdint.hpp>
#include <boost/format.hpp>
#include <boost/serialization/serialization.hpp>
#include <boost/serialization/string.hpp>
#include <boost/serialization/vector.hpp>
#include <boost/serialization/map.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/dynamic_bitset.hpp>

class CompositeDictionary;
class CompositeDefinition;
class OperatorArg;
class DesignTimeComposite;
class DesignTimeSortKey;

#define METRAFLOW_BATCH_SCHEDULER_GRAIN 1000

/////////////////////////////
// TODO List:
/////////////////////////////
// Distributed execution (done)
// Batch scheduling (done)
// Sort Merge Collector (done)
// Sort Merge Union (done)
// Group By (done)
// Running Total (done)
// Hierarchical Records
// Aggregate Rating prototype (done)
// MTSQL expression operator (done)
// Scripting interface (largely done maybe prototype)
// Cyclic graph type checking and execution
// Reimplement and remove MultiEndpoint (done)
// Build release version (done)
// Entire partitioning (done)
// Import/Export operators
// Sort (in progress)
////////////////////////////
// Longer term projects:
////////////////////////////
// Hash table spill over (hybrid hash join)

typedef std::size_t endpoint_t;
typedef std::size_t operator_set_t;
typedef std::size_t partition_t;
typedef std::size_t port_t;

typedef record_t MessagePtr;

class Endpoint;
class RemoteEndpoint;
class MPISendEndpoint;
class MPIRecvEndpoint;
class MPIService;
class Channel;
class RunTimeOperator;
class RunTimeOperatorActivation;
class Reactor;
class LinuxProcessor;
class RemoteProgressEngine;
class COdbcColumnMetadata;

class Port;
class PortCollection;
class DesignTimeOperator;
class DesignTimePlan;

// Parallel plan classes
class ParallelPartitionCompletions;
class ParallelPartition;
class ParallelDomain;
class ParallelPlan;

typedef std::map<partition_t,RunTimeOperatorActivation*> PartitionActivationMap;

typedef std::map<ParallelPartition*,RunTimeOperator*> PartitionOperatorMap;
typedef std::map<ParallelDomain*,PartitionOperatorMap*> DomainPartitionMap;

class AutoSanityCheck
{
public:
  AutoSanityCheck();
  ~AutoSanityCheck();
};

class CapacityChangeHandler
{
private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
  }  
public:
  // Local channel I/O
  virtual void OnRead(boost::int32_t prevCapacity, boost::int32_t newCapacity, Endpoint * source, Endpoint * target) =0;
  virtual void OnWrite(boost::int32_t prevCapacity, boost::int32_t newCapacity, Endpoint * source, Endpoint * target) =0;
  // Remote channel I/O (version 2)
  virtual void OnRead(MPIRecvEndpoint * target) =0;
  virtual void OnWrite(MPISendEndpoint * source) =0;
  virtual void OnReadCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, MPISendEndpoint * target) =0;
  virtual void OnWriteCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, MPIRecvEndpoint * source) =0;
  METRAFLOW_DECL virtual ~CapacityChangeHandler() {}
};

class Reactor : public CapacityChangeHandler
{
private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(CapacityChangeHandler);
  }  
public:
  virtual void RequestRead(RunTimeOperatorActivation * task, Endpoint * ep)=0;
  virtual void RequestWrite(RunTimeOperatorActivation * task, Endpoint * ep)=0;
  virtual void ReadChannel(Endpoint * ep, MessagePtr& m)=0;
  virtual void WriteChannel(Endpoint * ep, MessagePtr m, bool close)=0;
  virtual void Add(Endpoint * ep)=0;
  virtual void Add(Channel * c)=0;
  virtual void Start(const std::vector<RunTimeOperatorActivation *> & ops)=0;
  virtual void Stop()=0;
  virtual void DumpQueues(std::wostream& ostr)=0;
  virtual void DumpStatistics(std::ostream& ostr)=0;
  METRAFLOW_DECL virtual ~Reactor() {}
};

class MessagePtrQueue
{
private:
  // Singly linked list for queue. 
  MessagePtr mHead;
  MessagePtr mTail;
  // Statistics
  boost::int64_t mNumRead;
  volatile boost::int32_t mSize;
  boost::int64_t mPreviousNumRead;
  boost::int64_t mPreviousNumWritten;

#ifdef VALIDATE_QUEUE
  class Validator
  {
  private:
    const MessagePtrQueue& mQueue;
  public:
    Validator(const MessagePtrQueue& q)
      :
      mQueue(q)
    {
      mQueue.Validate();
    }

    ~Validator()
    {
      mQueue.Validate();
    }
  };
#else
  class Validator
  {
  public:
    Validator(const MessagePtrQueue& q)
    {
    }

    ~Validator()
    {
    }
  };
#endif

public:
  MessagePtrQueue()
    :
    mHead(NULL),
    mTail(NULL),
    mNumRead(0LL),
    mSize(0),
    mPreviousNumRead(0LL),
    mPreviousNumWritten(0LL)
  {
  }

  ~MessagePtrQueue()
  {
  }

  // Push all of these onto the argument.
  void Push(MessagePtrQueue& m)
  {
    Validator v1(*this);
    Validator v2(m);

    if (m.mHead != NULL)
    {
      if (mTail != NULL)
      {
        RecordMetadata::SetNext(mTail, m.mHead);
      }
      mTail = m.mTail;
      mSize += m.mSize;
      if (mHead == NULL)
      {
        mHead = m.mHead;
      }
      // Clear the source queue.
      m.mHead = NULL;
      m.mTail = NULL;
      m.mNumRead += m.mSize;
      m.mSize = 0;
    }
    else
    {
      // Do nothing if the source is empty
      ASSERT(m.mTail == NULL);
      ASSERT(m.mSize == 0);
    }
  }

  // Pop all of these onto the argument.
  void PushSome(MessagePtrQueue& m, boost::int32_t maxToPush)
  {
    Validator v1(*this);
    Validator v2(m);

    if (m.mSize > maxToPush) 
    {
      ASSERT(m.mHead != NULL);
      // Adjust sizes.
      mSize += maxToPush;
      m.mSize -= maxToPush;
      m.mNumRead += maxToPush;
      // First to be popped off is the head.
      MessagePtr first=m.mHead;
      // Scan to the maxToPush element; the last to be popped.
      MessagePtr last=m.mHead;
      while(--maxToPush > 0)
      {
        last = RecordMetadata::GetNext(last);
        ASSERT(last != NULL);
      }
      if(!(RecordMetadata::GetNext(last) != NULL))
      {
        throw std::runtime_error("RecordMetadata::GetNext(last) != NULL");
      }
      // Unlink from source. No need to change tail of source.
      m.mHead = RecordMetadata::GetNext(last);
      RecordMetadata::SetNext(last, NULL);
      // Link to this
      if (mTail != NULL)
      {
        RecordMetadata::SetNext(mTail, first);
      }
      mTail = last;
      if (mHead == NULL)
      {
        mHead = first;
      }
    }
    else
    {
      Push(m);
    }
  }

  MessagePtr Top()
  {
    return mHead;
  }
  MessagePtr Head()
  {
    return mHead;
  }
  MessagePtr Tail()
  {
    return mTail;
  }

  void Pop(MessagePtrQueue& m)
  {
    m.Push(*this);
  }

  void PopSome(MessagePtrQueue& m, boost::int32_t maxToPop)
  {
    m.PushSome(*this, maxToPop);
  }

  void Pop(MessagePtr& m)
  {
    Validator v1(*this);

    m = mHead;
    if(mHead != NULL)
    {
      mHead = RecordMetadata::GetNext(mHead);
      RecordMetadata::SetNext(m, NULL);
      mSize--;
      mNumRead++;
    }
    if(mHead == NULL)
    {
      ASSERT(mSize == 0);
      mTail = NULL;
    }
  }

  void Push(MessagePtr m)
  {
    Validator v1(*this);

    // Don't allow NULL to be pushed.
    ASSERT(m != NULL);
    // Only allow unlinked messages to be pushed
    ASSERT(RecordMetadata::GetNext(m) == NULL);
    // Append to the tail of the list
    if (mTail != NULL)
    {
      RecordMetadata::SetNext(mTail, m);
    }
    mTail = m;
    if (mHead == NULL)
    {
      ASSERT(mSize == 0);
      mHead = mTail;
    }
    mSize++;
  }
  boost::int32_t GetSize() const 
  { 
    return mSize; 
  }

  /**
   * Get the number of records read from the channel.
   */
  METRAFLOW_DECL boost::int64_t GetNumRead() const
  {
    return mNumRead;
  }

  /**
   * Get the number written to the channel.
   */
  METRAFLOW_DECL boost::int64_t GetNumWritten() const
  {
    return mNumRead+GetSize();
  }

  /**
   * Get the number of records previously read from the channel.
   */
  METRAFLOW_DECL boost::int64_t GetPreviousNumRead() const
  {
    return mPreviousNumRead;
  }

  /**
   * Get the number of records previously written to the channel.
   */
  METRAFLOW_DECL boost::int64_t GetPreviousNumWritten() const
  {
    return mPreviousNumWritten;
  }

  /**
   * Set the "previous" counts of number of records read and
   * written from the channel.
   */
  METRAFLOW_DECL void SetPreviousStatistics()
  {
    mPreviousNumRead = GetNumRead();
    mPreviousNumWritten = GetNumWritten();
  }

  // Debugging
  bool Validate() const
  {
    // Validate empty queue state.
    if (mHead == NULL ||
        mTail == NULL)
    {
      if (mHead == NULL && mTail == NULL && mSize == 0)
        return true;
      else
        return false;
    }
    // Count entries by scanning till null.
    // Validate that last node is the tail.
    MessagePtr it = mHead;
    boost::int32_t cnt = 1;
    while(RecordMetadata::GetNext(it) != NULL)
    {
      it = RecordMetadata::GetNext(it);
      cnt += 1;
    }
    if (cnt == mSize && it == mTail)
      return true;
    else 
      return false;
  }
};

class Endpoint
{
private:
  // Intrusive doubly linked list for queues in scheduler.
  // These values can be accessed from multiple threads and
  // therefore must be serialized (via mutexes in the schedulers).
  Endpoint * mNext;
  Endpoint * mPrev;

  // Intrusive circular doubly linked list for request sets to support "select" semantics on 
  // inputs for operators.  Only safe for access by the owning thread.
  Endpoint * mNextRequest;
  Endpoint * mPrevRequest;

  // Singly linked list for local queue. Only safe for access by the owning thread.
  MessagePtrQueue mLocalQueue;
  
  // This records which scheduler queue the endpoint is in.  As such
  // it is modified from multiple thread and therefore must be guarded
  // by the scheduler mutexes.
  boost::int32_t mPriority;

  // Should be allow local buffering/queuing of data?
  bool mLocallyBuffered;

  // The partition we are part of.  Currently not being modified.
  LinuxProcessor * mProcessor;

  // This is used as a static record of the operator associated
  // with this endpoint.
  RunTimeOperatorActivation * mOperator;

protected:
//   //
//   // Serialization support
//   //
//   friend class boost::serialization::access;
//   template<class Archive>
//   void serialize(Archive & ar, const unsigned int version) 
//   {
//     ar & BOOST_SERIALIZATION_NVP(mNext);
//     ar & BOOST_SERIALIZATION_NVP(mPrev);
//     ar & BOOST_SERIALIZATION_NVP(mNextRequest);
//     ar & BOOST_SERIALIZATION_NVP(mPrevRequest);
//     ar & BOOST_SERIALIZATION_NVP(mProcessor);
//     ar & BOOST_SERIALIZATION_NVP(mOperator);
//     ar & BOOST_SERIALIZATION_NVP(mPriority);
//   }  
public:
  Endpoint(RunTimeOperatorActivation * op, bool locallyBuffered=true)
    :
    mNext(NULL),
    mPrev(NULL),
    mNextRequest(NULL),
    mPrevRequest(NULL),
    mPriority(-1),
    mLocallyBuffered(locallyBuffered),
    mProcessor(NULL),
    mOperator(op)
  {
    mPrev = mNext = mNextRequest = mPrevRequest = this;
  }
  virtual ~Endpoint() {}
  Endpoint * Unlink()
  {
    if (mPrev != this)
    {
      mNext->mPrev = this->mPrev;
      mPrev->mNext = this->mNext;
      Endpoint * sav = this->mNext;
      this->mPrev = this->mNext = this;
      return sav;
    }
    if (mNext != this)
    {
      throw std::runtime_error("Invalid endpoint; mPrev == this && mNext != this");
    }
    return NULL;
  }
//   void Link(Endpoint * before)
//   {
//     this->mNext = before->mNext;
//     this->mPrev = before;
//     before->mNext->mPrev = this;
//     before->mNext = this;
//   }
  Endpoint * LinkBefore(Endpoint * after)
  {
    if (mPrev != this || mNext != this)
    {
      throw std::runtime_error("Invalid endpoint; already linked");
    }
    if (after == NULL)
    {
      return this;
    }
    this->mNext = after;
    this->mPrev = after->mPrev;
    after->mPrev->mNext = this;
    after->mPrev = this;
    return after;
  }
  Endpoint * Next() const
  {
    return this->mNext;
  }
  Endpoint * Prev() const 
  {
    return this->mPrev;
  }
  Endpoint * UnlinkRequest()
  {
    if (mPrevRequest != this)
    {
      mNextRequest->mPrevRequest = this->mPrevRequest;
      mPrevRequest->mNextRequest = this->mNextRequest;
      return this->mNextRequest;
    }
    return NULL;
  }
  void LinkRequest(Endpoint * before)
  {
    this->mNextRequest = before->mNextRequest;
    this->mPrevRequest = before;
    before->mNextRequest->mPrevRequest = this;
    before->mNextRequest = this;
  }
  Endpoint * NextRequest() const
  {
    return this->mNextRequest;
  }

  bool GetLocallyBuffered() const
  {
    return this->mLocallyBuffered;
  }

  /**
   * A queue of messages that is owned by this endpoint.  This
   * is not thread safe and may only be used by the thread that
   * owns the endpoint.
   */
  MessagePtrQueue& GetLocalQueue() { return mLocalQueue; }
  const MessagePtrQueue& GetLocalQueue() const { return mLocalQueue; }
  
  /**
   * The processor hangs off the endpoint so that a 
   * processor writing to an endpoint can figure out
   * if there is another processor that needs to have
   * scheduling information updated due to a read or write.
   */
  LinuxProcessor * GetProcessor() const
  {
    return mProcessor;
  }
  void SetProcessor(LinuxProcessor * processor)
  {
    mProcessor = processor;
  }

  boost::int32_t GetPriority() const
  {
    return mPriority;
  }
  void SetPriority(boost::int32_t priority)
  {
    mPriority = priority;
  }

  RunTimeOperatorActivation * GetOperator() const
  {
    return mOperator;
  }
  
  virtual void Start()
  {
  }
  virtual boost::int32_t GetSize() const =0;
  virtual bool IsSource() const =0;
  virtual endpoint_t GetIndex() const =0;
  virtual void SetIndex(endpoint_t index) =0;
  virtual partition_t GetPartition() const =0;
  virtual void SetPartition(partition_t index) =0;
  virtual void Read(MessagePtr& m, CapacityChangeHandler& pch) =0;
  virtual void Write(MessagePtr m, CapacityChangeHandler& pch) =0;
  virtual void SyncLocalQueue(CapacityChangeHandler & cch) =0;
};

/**
 * An endpoint participates in communication over channels.  Endpoints are 
 * read-only or write-only.  
 */
class SingleEndpoint : public Endpoint
{
private:
  Channel * mChannel;
  bool mIsSource;
  endpoint_t mIndex;
  partition_t mPartition;
//   //
//   // Serialization support
//   //
//   friend class boost::serialization::access;
//   template<class Archive>
//   void serialize(Archive & ar, const unsigned int version) 
//   {
//     ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(Endpoint);
//     ar & BOOST_SERIALIZATION_NVP(mChannel);
//     ar & BOOST_SERIALIZATION_NVP(mIsSource);
//     ar & BOOST_SERIALIZATION_NVP(mIndex);
//     ar & BOOST_SERIALIZATION_NVP(mPartition);
//   }  
//   METRAFLOW_DECL SingleEndpoint()
//     :
//     mChannel(NULL),
//     mIsSource(false),
//     mIndex(0),
//     mPartition(0)
//   {
//   }

public:
  static void * operator new (size_t sz)
  {
    // Ensure alginment on cache line boundary.  Add sizeof(void *) bytes
    // for original pointer, then align the returned structure to cacheline.
    size_t allocSz = sz + 127 + sizeof(void *);
    void * ptr = ::malloc(allocSz);
    unsigned char * aligned = reinterpret_cast<unsigned char *>(((reinterpret_cast<size_t>(ptr)+127) >> 7) << 7);
    *((void **)(aligned + sz)) = ptr;
    return aligned;
  }

  static void operator delete (void * p, size_t sz)
  {
    // Find stashed original pointer
    void * original = * reinterpret_cast<void **>((reinterpret_cast<unsigned char *>(p) + sz));
    ::free(original);
  }

  METRAFLOW_DECL void SetChannel(Channel * channel)
  {
    mChannel = channel;
  }
  METRAFLOW_DECL Channel * GetChannel()
  {
    return mChannel;
  }
  METRAFLOW_DECL const Channel * GetChannel() const
  {
    return mChannel;
  }

  METRAFLOW_DECL bool IsSource() const
  {
    return mIsSource;
  }
  METRAFLOW_DECL void SetSource(bool isSource) 
  {
    mIsSource = isSource;
  }

  METRAFLOW_DECL endpoint_t GetIndex() const
  {
    return mIndex;
  }
  METRAFLOW_DECL void SetIndex(endpoint_t index)
  {
    mIndex = index;
  }

  METRAFLOW_DECL partition_t GetPartition() const
  {
    return mPartition;
  }
  METRAFLOW_DECL void SetPartition(partition_t partition)
  {
    mPartition = partition;
  }

  /**
   * GetSize informs the caller of the current occupancy of the endpoint.
   * The scheduler uses this as the basis of prioritization.  The basic
   * heuristic is that reads from full channels are high priority and
   * writes to empty channels are high priority.
   */
  METRAFLOW_DECL boost::int32_t GetSize() const;

  METRAFLOW_DECL void Read(MessagePtr& m, CapacityChangeHandler & cch);
  METRAFLOW_DECL void Write(MessagePtr m, CapacityChangeHandler & cch);
  /**
   * If this is a read endpoint, this loads the local queue from
   * the channel.
   * If this is a write endpoint, this stores the contents of the local
   * queue to the channel.
   */
  METRAFLOW_DECL void SyncLocalQueue(CapacityChangeHandler & cch);

  METRAFLOW_DECL void DumpStatistics();

  METRAFLOW_DECL SingleEndpoint(Channel * channel, bool isSource, RunTimeOperatorActivation * op, bool locallyBuffered);
  METRAFLOW_DECL ~SingleEndpoint();
};

class MPISendEndpoint : public Endpoint
{
private:
  /**
   * The MPIService that provides messaging
   */
  MPIService * mService;
  bool mIsSource;
  endpoint_t mIndex;
  partition_t mPartition;

  boost::int32_t mEndpointIndex;
  partition_t mRemotePartition;
  boost::int32_t mTag;
  RecordMetadata mMetadata;
public:
  METRAFLOW_DECL MPISendEndpoint(RunTimeOperatorActivation * op, 
                                 MPIService * service,
                                 boost::int32_t endpointIndex,
                                 const RecordMetadata& metadata, 
                                 boost::int32_t tag, 
                                 boost::int32_t partition,
                                 bool locallyBuffered);
  METRAFLOW_DECL ~MPISendEndpoint();

  METRAFLOW_DECL boost::int32_t GetSize() const;
  METRAFLOW_DECL bool IsSource() const
  {
    return mIsSource;
  }
  METRAFLOW_DECL void SetSource(bool isSource) 
  {
    mIsSource = isSource;
  }

  METRAFLOW_DECL endpoint_t GetIndex() const
  {
    return mIndex;
  }
  METRAFLOW_DECL void SetIndex(endpoint_t index)
  {
    mIndex = index;
  }

  METRAFLOW_DECL partition_t GetPartition() const
  {
    return mPartition;
  }
  METRAFLOW_DECL void SetPartition(partition_t partition)
  {
    mPartition = partition;
  }

  METRAFLOW_DECL void Read(MessagePtr& m, CapacityChangeHandler& pch);
  METRAFLOW_DECL void Write(MessagePtr m, CapacityChangeHandler& pch);
  METRAFLOW_DECL void SyncLocalQueue(CapacityChangeHandler & cch);

  boost::int32_t GetEndpointIndex() const
  {
    return mEndpointIndex;
  }
  boost::int32_t GetRemotePartition() const
  {
    return mRemotePartition;
  }
  boost::int32_t GetTag() const
  {
    return mTag;
  }
  const RecordMetadata& GetMetadata() const
  {
    return mMetadata;
  }
};

class MPIRecvEndpoint : public Endpoint
{
private:
  /**
   * The MPIService that provides messaging
   */
  MPIService * mService;
  bool mIsSource;
  endpoint_t mIndex;
  partition_t mPartition;

  boost::int32_t mEndpointIndex;
  partition_t mRemotePartition;
  boost::int32_t mTag;
  RecordMetadata mMetadata;
public:
  METRAFLOW_DECL MPIRecvEndpoint(RunTimeOperatorActivation * op, 
                                 MPIService * service,
                                 boost::int32_t endpointIndex,
                                 const RecordMetadata& metadata, 
                                 boost::int32_t tag, 
                                 boost::int32_t partition);
  METRAFLOW_DECL ~MPIRecvEndpoint();

  METRAFLOW_DECL boost::int32_t GetSize() const;
  METRAFLOW_DECL bool IsSource() const
  {
    return mIsSource;
  }
  METRAFLOW_DECL void SetSource(bool isSource) 
  {
    mIsSource = isSource;
  }

  METRAFLOW_DECL endpoint_t GetIndex() const
  {
    return mIndex;
  }
  METRAFLOW_DECL void SetIndex(endpoint_t index)
  {
    mIndex = index;
  }

  METRAFLOW_DECL partition_t GetPartition() const
  {
    return mPartition;
  }
  METRAFLOW_DECL void SetPartition(partition_t partition)
  {
    mPartition = partition;
  }

  METRAFLOW_DECL void Read(MessagePtr& m, CapacityChangeHandler& pch);
  METRAFLOW_DECL void Write(MessagePtr m, CapacityChangeHandler& pch);
  METRAFLOW_DECL void SyncLocalQueue(CapacityChangeHandler & cch);

  boost::int32_t GetEndpointIndex() const
  {
    return mEndpointIndex;
  }
  boost::int32_t GetRemotePartition() const
  {
    return mRemotePartition;
  }
  boost::int32_t GetTag() const
  {
    return mTag;
  }
  const RecordMetadata& GetMetadata() const
  {
    return mMetadata;
  }
};

class IntraDomainChannelSpec
{
private:
  RunTimeOperatorActivation * mSourceOperator;
  port_t mSourcePort;
  RunTimeOperatorActivation * mTargetOperator;
  port_t mTargetPort;
  bool mLocallyBuffered;
  bool mBuffered;
public:
  IntraDomainChannelSpec(RunTimeOperatorActivation * sourceOperator, port_t sourcePort,
                         RunTimeOperatorActivation * targetOperator, port_t targetPort,
                         bool locallyBuffered, bool buffered)
    :
    mSourceOperator(sourceOperator),
    mSourcePort(sourcePort),
    mTargetOperator(targetOperator),
    mTargetPort(targetPort),
    mLocallyBuffered(locallyBuffered),
    mBuffered(buffered)
  {
  }
  RunTimeOperatorActivation * GetSourceOperator() const
  {
    return mSourceOperator;
  }
  port_t GetSourcePort() const
  {
    return mSourcePort;
  }
  RunTimeOperatorActivation * GetTargetOperator() const
  {
    return mTargetOperator;
  }
  port_t GetTargetPort() const
  {
    return mTargetPort;
  }
  bool GetLocallyBuffered() const
  {
    return mLocallyBuffered;
  }
  bool GetBuffered() const
  {
    return mBuffered;
  }
};

class InterDomainEndpointSpec
{
private:
  RunTimeOperatorActivation * mOperator;
  port_t mPort;
  RecordMetadata mMetadata;
  partition_t mRemotePartition;
  boost::int32_t mTag;
public:
  InterDomainEndpointSpec(RunTimeOperatorActivation * op, port_t port,
                              const RecordMetadata& metadata, partition_t remotePartition, 
                              boost::int32_t tag)
    :
    mOperator(op),
    mPort(port),
    mMetadata(metadata),
    mRemotePartition(remotePartition),
    mTag(tag)
  {
  }
  RunTimeOperatorActivation * GetOperator() const
  {
    return mOperator;
  }
  port_t GetPort() const
  {
    return mPort;
  }
  const RecordMetadata& GetMetadata() const
  {
    return mMetadata;
  }
  partition_t GetRemotePartition() const
  {
    return mRemotePartition;
  }
  boost::int32_t GetTag() const
  {
    return mTag;
  }
};

class InterDomainReadEndpointSpec : public InterDomainEndpointSpec
{
public:
  InterDomainReadEndpointSpec(RunTimeOperatorActivation * op, port_t port,
                              const RecordMetadata& metadata, partition_t remotePartition, 
                              boost::int32_t tag)
    :
    InterDomainEndpointSpec(op, port, metadata, remotePartition, tag)
  {
  }
};

class InterDomainWriteEndpointSpec : public InterDomainEndpointSpec
{
private:
  bool mLocallyBuffered;
public:
  InterDomainWriteEndpointSpec(RunTimeOperatorActivation * op, port_t port,
                              const RecordMetadata& metadata, partition_t remotePartition, 
                              boost::int32_t tag, bool locallyBuffered)
    :
    InterDomainEndpointSpec(op, port, metadata, remotePartition, tag)
  {
  }

  bool GetLocallyBuffered() const
  {
    return mLocallyBuffered;
  }
};

/**
 * A channel is a buffered unidirectional I/O channel between two endpoints.
 * A channel implements a FIFO queue of Messages.
 * We must be very careful to avoid cache bouncing and false sharing with these data structures.
 * Because the write activity on these members is so intense, it can be very
 * bad if they wind up on the same cache line as something else that does
 * a lot of writes.
 */
class Channel 
{
private:
  MetraFlow::SpinLock mSpinLock;

  SingleEndpoint * mSource;
  SingleEndpoint * mTarget;

  MessagePtrQueue mQueue;
  bool mBuffering;
//   //
//   // Serialization support
//   //
//   friend class boost::serialization::access;
//   template<class Archive>
//   void serialize(Archive & ar, const unsigned int version) 
//   {
//     ar & BOOST_SERIALIZATION_NVP(mSource);
//     ar & BOOST_SERIALIZATION_NVP(mTarget);
//     // Don't serialize any of the runtime data elements
//   }  

  void Init();
  
public:
  METRAFLOW_DECL static boost::int32_t GetMaxSize() { return 1024; }

public:
  METRAFLOW_DECL Channel(RunTimeOperatorActivation * sourceOperator, RunTimeOperatorActivation * targetOperator, bool locallyBuffered=true);
  METRAFLOW_DECL ~Channel();

  static void * operator new (size_t sz)
  {
    // Ensure alginment on cache line boundary.  Add sizeof(void *) bytes
    // for original pointer, then align the returned structure to cacheline.
    size_t allocSz = sz + 127 + sizeof(void *);
    void * ptr = ::malloc(allocSz);
    unsigned char * aligned = reinterpret_cast<unsigned char *>(((reinterpret_cast<size_t>(ptr)+127) >> 7) << 7);
    *((void **)(aligned + sz)) = ptr;
    return aligned;
  }

  static void operator delete (void * p, size_t sz)
  {
    // Find stashed original pointer
    void * original = * reinterpret_cast<void **>((reinterpret_cast<unsigned char *>(p) + sz));
    ::free(original);
  }

  void SetBuffering(bool buffering)
  {
    mBuffering = buffering;
  }

  bool GetBuffering() const
  {
    return mBuffering;
  }

  METRAFLOW_DECL void DumpStatistics();

  METRAFLOW_DECL boost::int64_t GetNumRead() const
  {
    return mQueue.GetNumRead();
  }

  METRAFLOW_DECL boost::int64_t GetNumWritten() const
  {
    return mQueue.GetNumWritten();
  }

  METRAFLOW_DECL boost::int64_t GetPreviousNumRead() const
  {
    return mQueue.GetPreviousNumRead();
  }

  METRAFLOW_DECL boost::int64_t GetPreviousNumWritten() const
  {
    return mQueue.GetPreviousNumWritten();
  }

  METRAFLOW_DECL void SetPreviousStatistics()
  {
    return mQueue.SetPreviousStatistics();
  }

  METRAFLOW_DECL boost::int32_t GetSize() const 
  { 
    boost::int32_t sz = mQueue.GetSize();
    return mBuffering || sz == 0 ?  sz : std::numeric_limits<boost::int32_t>::max();
  }
  METRAFLOW_DECL Endpoint * GetSource()
  {
    return mSource;
  }
  METRAFLOW_DECL Endpoint * GetTarget()
  {
    return mTarget;
  }
  METRAFLOW_DECL void Read(MessagePtr& m, CapacityChangeHandler& cch)
  {
    MetraFlow::SpinLock::Guard g(mSpinLock);
    const boost::int32_t sz(GetSize());
    mQueue.Pop(m);
    cch.OnRead(sz, GetSize(), mSource, mTarget);
  }
  METRAFLOW_DECL void Write(MessagePtr m, CapacityChangeHandler& cch)
  {
    MetraFlow::SpinLock::Guard g(mSpinLock);
    const boost::int32_t sz(GetSize());
    mQueue.Push(m);
    cch.OnWrite(sz, GetSize(), mSource, mTarget);
  }
  METRAFLOW_DECL void ReadAll(MessagePtrQueue& m, CapacityChangeHandler& cch)
  {
    MetraFlow::SpinLock::Guard g(mSpinLock);
    const boost::int32_t sz(GetSize());
    mQueue.PopSome(m, METRAFLOW_BATCH_SCHEDULER_GRAIN);
    cch.OnRead(sz, GetSize(), mSource, mTarget);
  }
  METRAFLOW_DECL void WriteAll(MessagePtrQueue& m, CapacityChangeHandler& cch)
  {
    MetraFlow::SpinLock::Guard g(mSpinLock);
    const boost::int32_t sz(GetSize());
    mQueue.Push(m);    
    cch.OnWrite(sz, GetSize(), mSource, mTarget);
  }
};

/**
 * An Operator exposes input and output ports that are connected up in a logical
 * plan.  It is possible for an operator to dynamically create ports in response
 * to configuration options.
 */
class Port
{
private:
  /** Design time operator containing this port. */
  DesignTimeOperator * mOperator;

  /** The name of port (for example "input") */
  std::wstring mName;

  /** True if the port is not required to be connected in the graph. */
  bool mIsOptional;

  /** 
   * True if this port defines a composite input or output parameter as
   * part of a composite definition.  Note that this port is not connected
   * in the composite definition flow (since it is an input or output). 
   */
  bool mIsCompositeParameter;

  /** The datatype flowing over the port.  Determined at type_check time. */
  RecordMetadata * mMetadata;

public:
  // Needed for serialization
  METRAFLOW_DECL Port()
    :
    mOperator(NULL),
    mName(L""),
    mIsOptional(false),
    mIsCompositeParameter(false),
    mMetadata(NULL)
  {
  }

  METRAFLOW_DECL Port(DesignTimeOperator * op, const std::wstring& name, bool isOptional)
    :
    mOperator(op),
    mName(name),
    mIsOptional(isOptional),
    mIsCompositeParameter(false),
    mMetadata(NULL)
  {
  }

  METRAFLOW_DECL ~Port()
  {
    delete mMetadata;
  }

  /** Get the wide string name of the port */
  std::wstring GetName() const
  {
    return mName;
  }

  /** Get the standard string name of the port. */
  std::string GetNameString() const;

  /** 
   * Get the full name of the port (includes operator name). 
   * Example: Operator: p Port: table
   */
  std::wstring GetFullName() const;

  bool IsOptional() const
  {
    return mIsOptional;
  }

  bool IsCompositeParameter() const
  {
    return mIsCompositeParameter;
  }

  DesignTimeOperator * GetOperator() const
  {
    return mOperator;
  }

  const RecordMetadata * GetMetadata() const
  {
    return mMetadata;
  }

  const LogicalRecord& GetLogicalMetadata() const
  {
    return mMetadata != NULL ? mMetadata->GetLogicalRecord() : LogicalRecord::Get();
  }

  void SetMetadata(RecordMetadata * metadata)
  {
    mMetadata = metadata;
  }

  void SetAsCompositeParameter()
  {
    mIsCompositeParameter = true;
  }
};

class PortCollection
{
private:
  std::vector<boost::shared_ptr<Port> > mPorts;
  std::map<boost::shared_ptr<Port> , port_t> mPortIndexIndex;
  std::map<std::wstring, boost::shared_ptr<Port> > mPortNameIndex;
  const DesignTimeOperator * mOperator;

  // Noncopyable
  PortCollection(const PortCollection& rhs)
  {
    ASSERT(FALSE);
  }
  PortCollection& operator =(const PortCollection& rhs)
  {
    ASSERT(FALSE);
  }

public:
  // Typedefs
  typedef std::vector<boost::shared_ptr<Port> >::iterator iterator;
  typedef std::vector<boost::shared_ptr<Port> >::const_iterator const_iterator;

public:
  PortCollection() 
    :
    mOperator(NULL)
  {
  }

  ~PortCollection()
  {
  }

  void SetOperator(const DesignTimeOperator * op)
  {
    mOperator = op;
  }

  METRAFLOW_DECL boost::shared_ptr<Port> operator [] (const std::wstring& name);
  METRAFLOW_DECL boost::shared_ptr<Port> operator [] (const std::wstring& name) const;

  boost::shared_ptr<Port> operator [] (port_t idx)
  {
    return mPorts[idx];
  }
  boost::shared_ptr<Port> operator [] (port_t idx) const
  {
    return mPorts[idx];
  }

  /** Get a pointer to the named port. */
  boost::shared_ptr<Port> getPort(const std::wstring& name)
  {
    return mPortNameIndex[name];
  }

  port_t index_of(boost::shared_ptr<Port> p) const 
  { 
    return mPortIndexIndex.find(p)->second; 
  }
  std::size_t size() const 
  { 
    return mPorts.size(); 
  }
  iterator begin() 
  {
    return mPorts.begin();
  }
  const_iterator begin() const
  {
    return mPorts.begin();
  }
  iterator end() 
  {
    return mPorts.end();
  }
  const_iterator end() const
  {
    return mPorts.end();
  }
  boost::shared_ptr<Port> back() 
  {
    return mPorts.back();
  }
  void insert(DesignTimeOperator * op, port_t idx, const std::wstring& name, bool isOptional)
  {
    boost::shared_ptr<Port> p (new Port(op, name, isOptional));
    mPorts.insert(mPorts.begin() + idx, p);
    mPortNameIndex[name] = p;
    mPortIndexIndex[p] = idx;
  }
  void push_back(DesignTimeOperator * op, const std::wstring& name, bool isOptional)
  {
    boost::shared_ptr<Port> p ( new Port(op, name, isOptional));
    mPorts.push_back(p);
    mPortNameIndex[name] = p;
    mPortIndexIndex[p] = mPorts.size()-1;
  }
  void push_back(boost::shared_ptr<Port> p, const std::wstring& name)
  {
    mPorts.push_back(p);
    mPortNameIndex[name] = p;
    mPortIndexIndex[p] = mPorts.size()-1;
  }
  void push_back(boost::shared_ptr<Port> p)
  {
    mPorts.push_back(p);
    mPortNameIndex[p->GetName()] = p;
    mPortIndexIndex[p] = mPorts.size()-1;
  }

  /** Does the given port name exist in the collection? */
  bool doesPortExist(const std::wstring& portName) const;

  /** Does the given port index exist in the collection? */
  bool doesPortExist(int portIndex) const;

};

class DesignTimeOperator
{
public:
  enum Mode { PARALLEL, SEQUENTIAL };

protected:
  /** The name of the operator */
  std::wstring mName;

  /** Input ports that accept connections. */
  PortCollection mInputPorts;

  /** Output ports that accept connections. */
  PortCollection mOutputPorts;

  /** Parallel or sequential */
  Mode mMode;

  /** Named partition constraint */
  std::wstring mPartitionConstraint;

  /** 
   * Operator arguments that have been collected (during dataflow_generate.g)
   * but have not been applied.  Before applying the collect args,
   * any variables referred to in the arg (e.g. numToPrint=$n) will be 
   * replaced with there literal value.
   */
  std::vector<OperatorArg*> mPendingArgs;

  /**
   * Check that the input metadata on the two ports is the same.  Throw
   * RecordTypeMismatchException if not.
   */
  void CheckMetadataSameType(boost::int32_t portA, boost::int32_t portB) const;

  /**
   * Check if sort keys are present and of sortable type.  Throw exception otherwise.
   */
  void CheckSortKeys(boost::int32_t portA, const std::vector<DesignTimeSortKey>& sortKeys) const;


public:
  /** Constructor */
  METRAFLOW_DECL DesignTimeOperator(const std::wstring& name=L"", 
                                    Mode mode = PARALLEL)
    :
    mName(name),
    mMode(mode)
  {
    mInputPorts.SetOperator(this);
    mOutputPorts.SetOperator(this);
  }

  /** Destructor */
  METRAFLOW_DECL virtual ~DesignTimeOperator();

  /** Get the standard wide string version of the operator name. */
  std::wstring GetName() const
  {
    return mName;
  }

  /** Get the standard string version of the operator name. */
  std::string GetNameString() const;

  void SetName(const std::wstring& name)
  {
    mName = name;
  }

  Mode GetMode() const
  {
    return mMode;
  }

  void SetMode(Mode mode)
  {
    mMode = mode;
  }

  /**
   * Name of the partition constraint that restricts the set of partitions on which
   * the operator is to execute.
   */
  std::wstring GetPartitionConstraint() const
  {
    return mPartitionConstraint;
  }

  /**
   * Name of the partition constraint that restricts the set of partitions on which
   * the operator is to execute.
   */
  void SetPartitionConstraint(const std::wstring& partitionConstraint)
  {
    mPartitionConstraint = partitionConstraint;
  }

  const PortCollection& GetInputPorts() const
  {
    return mInputPorts;
  }

  const PortCollection& GetOutputPorts() const
  {
    return mOutputPorts;
  }

  PortCollection& GetInputPorts() 
  {
    return mInputPorts;
  }

  PortCollection& GetOutputPorts() 
  {
    return mOutputPorts;
  }

  /** Return a port pointer for named output port */
  boost::shared_ptr<Port> getOutputPort(const std::wstring& name)
  {
    return mOutputPorts.getPort(name);
  }

  /** Return a port pointer for output port identified by name or number */
  boost::shared_ptr<Port> getOutputPort(const std::wstring& name,
                                        int number)
  {
    if (name.size() > 0)
    {
      return mOutputPorts.getPort(name);
    }
    return mOutputPorts[number];
  }
  
  /** Return a port pointer for named input port */
  boost::shared_ptr<Port> getInputPort(const std::wstring& name)
  {
    return mInputPorts.getPort(name);
  }

  /** Return a port pointer for input port identified by name or number */
  boost::shared_ptr<Port> getInputPort(const std::wstring& name,
                                       int number)
  {
    if (name.size() > 0)
    {
      return mInputPorts.getPort(name);
    }
    return mInputPorts[number];
  }

  /** 
   * Check that the input metadata types are acceptable and determine 
   * produced metadata types.
   */
  METRAFLOW_DECL virtual void type_check() =0;

  METRAFLOW_DECL virtual RunTimeOperator * code_generate(partition_t maxPartition) =0;

  /** 
   * Given an operator argument that may contain variable references,
   * resolve these references and apply the argument to the operator.
   * To resolve variables in the argument, we use environmental
   * variables, command line arguments, and intrinsic args.
   *
   * @param arg       argument to handle
   */
  void handleUnresolvedArg(const OperatorArg& arg);

  /** 
   * Given an operator argument that may contain variable references,
   * resolve these references and apply the argument to the operator.
   *
   * @param arg       argument to handle
   * @param vars      variables (defined by the placeholder operator).
   *                  At this point, these variables are all literals.
   *                  We use these variables to resolve variables encountered
   *                  in the pending arguments. We also use environmental
   *                  variables, command line arguments, and intrinsic args.
   */
  void handleUnresolvedArg(const OperatorArg& arg,
                           std::vector<OperatorArg *>&vars);

  /**
   * Handle the given argument describing the operator behavior.
   * This argument should have no variable references.
   */
  virtual void handleArg(const OperatorArg& arg) = 0;

  /**
   * Handle the mode argument. If incorrectly specified, a DataflowException
   * is thrown. This arguments should have no variable references.
   */
  void handleModeArg(const OperatorArg& arg);

  /**
   * Handle the partitionConstraint argument. If incorrectly specified, 
   * a DataflowException is thrown.
   */
  void handlePartitionConstraintArg(const OperatorArg& arg);

  /** 
   * Handle an unrecognized argument by throwing a DataflowException.
   * This argument should have no variable references.
   */
  void handleUnrecognizedArg(const OperatorArg& arg);

  /** 
   * Handle arguments that are common to all operators.  If an argument is 
   * either unknown of incorrectly specified, a DataflowException is thrown. 
   * This argument should have no variable references.
   */
  void handleCommonArg(const OperatorArg& arg);

  /** 
   * Make a clone of the initial state of an operator.
   * This is the state after operator arguments have been specified.
   * This clone is used as part of expanding a composite.
   * If a composite takes variable parameters (ranges), then 
   * the number of input/outputs to the composite instance depend
   * on usage.  This clone method takes the number of additional inputs/
   * outputs needed by the clone.  For DesignTimeOperators with fixed
   * inputs/outputs these numbers can be ignored (should be 0).  
   * Otherwise, the clone must contain this additional number of 
   * input and output ports. 
   * <p>
   * This clone method also takes the composite arguments that were specified.  
   * A composite argument can be used to specify an argument value to be 
   * used by an operator contained inside the composite.  When cloning
   * the value of the composite argument is used to specify the cloned operators
   * argument.
   *
   * @param name           name of new operator
   * @param compositeArgs  arguments to the composite.
   * @param nExtraInputs   number of extra inputs needed
   * @param nExtraOutputs  number of extra outputs needed
   */
  virtual DesignTimeOperator* clone(
                            const std::wstring& name,
                            std::vector<OperatorArg*>& compositeArgs,
                            int nExtraInputs, 
                            int nExtraOutputs) const = 0;
  /** 
   * Clone the pending arguments of this operator adding the argument
   * to the given clone operator.
   *
   * @param clonedOp  the operator to add the cloned pending args to.
   */
  void clonePendingArgs(DesignTimeOperator& clonedOp) const;

  /** 
   * Apply the pending arguments.  Before the pending arguments are
   * applied, we resolve any variables in the arguments with literals.
   * This method can also 
   *
   * @param vars      variables defined by the placeholder operator.
   *                  At this point, these variables are all literals.
   *                  We use these variables to resolve variables encountered
   *                  in the pending arguments. We also use environmental
   *                  variables.
   */
  void applyPendingArgs(std::vector<OperatorArg *>&vars);

  /**
   * The method only has meaning if the operator can have multiple input ports.
   * Is a single occurrence of an input port namde "input" rather
   * than "input(0)"?
   */
  virtual bool isSimplifiedInputNamingUsed() { return false; }

  /**
   * Add the given operator argument to the vector of pending
   * arguments.  The strategy behing having pending arguments is
   * to delay apply the arguments to the operator until we ready
   * to resolve variables referred to in the argument.
   */
  void addPendingArg(OperatorArg *arg);

  /** Returns printable version of operator.  For debugging. */
  std::string dump() const;
};

class DesignTimeChannel
{
private:
  boost::shared_ptr<Port> mSource;
  boost::shared_ptr<Port> mTarget;
  bool mBuffered;

public:
  METRAFLOW_DECL DesignTimeChannel()
    :
    mBuffered(true)
  {
  }

  METRAFLOW_DECL DesignTimeChannel(boost::shared_ptr<Port> source, boost::shared_ptr<Port> target, bool buffered=true)
    :
    mSource(source),
    mTarget(target),
    mBuffered(buffered)
  {
  }

  METRAFLOW_DECL ~DesignTimeChannel()
  {
  }

  boost::shared_ptr<Port> GetSource()
  {
    return mSource;
  }

  void SetSource(boost::shared_ptr<Port> source)
  {
    mSource = source;
  }

  boost::shared_ptr<Port> GetTarget()
  {
    return mTarget;
  }

  void SetTarget(boost::shared_ptr<Port> target)
  {
    mTarget = target;
  }

  bool GetLocallyBuffered() const
  {
    return mBuffered;
  }

  void SetLocallyBuffered(bool buffered)
  {
    mBuffered = buffered;
  }

  /** Return true if the channel references the given operator. */
  bool isReferencing(const DesignTimeOperator *op);
};

/**
 * A connected graph of operators.  The operators are connected
 * by input and output ports, through channels.
 */
class DesignTimePlan
{
private:
  /** Used to detect circular references. */
  enum Color { UNDISCOVERED, DISCOVERED, VISITED };

  /** 
   * The operators in the plan.  
   * This is list due to deletions that occur during composite expansion.
   */
  std::list<DesignTimeOperator *> mOperators; 

  /** 
   * The channels (arrows between operators) in the plan.  
   * This is list due to deletions that occur during composite expansion.
   */
  std::list<DesignTimeChannel *> mChannels;

  std::map<boost::shared_ptr<Port>, DesignTimeChannel *> mPortToChannel;

  std::set<std::string> mPartitioners;
  std::set<std::string> mCollectors;

  /**
   * Partition lists may be used to constrain operators to execute on a subset
   * of the available partitions in a program.  A program may refer to these
   * subsets by a logical name and the definition of the logical name is then
   * bound at runtime.
   */
  std::map<std::wstring, std::vector<boost::int32_t> > mPartitionListDefinitions;

  /** Name of the plan (composite name or step name) */
  std::wstring mName;

  /**
   * True if this plan is currently being expanded.
   * Used to detect a circular reference to the plan (through
   * composites).
   */
  bool mIsExpansionInProgress;

  /** 
   * A map of composite placeholder/output port name to actual 
   * operator/output port in the subgraph.
   * To the script writer, there is a notion a composite instance. But this 
   * is replaced with a subgraph. This map describes how a composite
   * placeholder output port referenced in the script is replaced with the 
   * actual operator/port in the subgraph. Used for --typecheck output.
   * The key is operator(portname).
   */
  std::map<std::wstring, boost::shared_ptr<Port> > mPlaceholderOutputMap;

private:
  /** Return the channel that references this port. */
  DesignTimeChannel * channel(boost::shared_ptr<Port> p) const
  {
    std::map<boost::shared_ptr<Port>, DesignTimeChannel*>::const_iterator it = mPortToChannel.find(p);
    return it == mPortToChannel.end() ? NULL : it->second;
  }

  bool IsOperatorAdded(DesignTimeOperator * op);
  void CheckOperatorAdded(DesignTimeOperator * op);
  void CheckOperatorNotAdded(DesignTimeOperator * op);
  bool isPartitioner(DesignTimeOperator * op);
  bool isCollector(DesignTimeOperator * op);
  
  /**
   * Check that for the given operation, the required inputs have been
   * specified and determine the metadata types of all the input and output
   * operations.
   *
   * @param op  operation to check.
   * @param color  map holding visited-state of all operations in the plan.
   *               all operations.
   */
  void type_check(DesignTimeOperator * op, 
                  std::map<DesignTimeOperator*, Color> & color);
  
  /**
   * Add to the plan all the operators that are in the given composite defn.
   * The names of the added operator are prepended with the given prefix.
   * Also fills in a map of the newly created operators indexed by name.
   *
   * @param placeholderOp  a reference to a composite that will be replaced
   *                    with the expanded subgraph.
   * @param prefix      what to prepended to the new operator names (ends in !).
   * @param nameToOpMap create map of new operator name to new operator
   * @param defn        definition of the composite we are expanding.
   */
  void cloneCompositeOperators(
                       DesignTimeComposite& placeholderOp, 
                       std::wstring prefix,
                       std::map<std::wstring, DesignTimeOperator*> &nameToOpMap,
                       const CompositeDefinition& defn);
  
  /**
   * Add to the plan all the arrows that are in the given composite definition.
   *
   * @param prefix      prefix that was added to the cloned operators (ends in !).
   * @param nameToOpMap map of new operator name to new operator
   * @param defn        definition of the composite we are expanding.
   */
  void cloneCompositeArrows(
                       std::wstring prefix,
                       std::map<std::wstring, DesignTimeOperator*> &nameToOpMap,
                       const CompositeDefinition& defn);

  /**
   * Count the dynamic input/output ports that are
   * connected to the placeholder composite.  These dynamic parameter ports
   * connect to operators in the composite. This method creates a map
   * of composite operator name to referenced dynamic parameters by
   * the placeholder. (This is used as part of cloning composite operators).
   *
   * @param ports    input or output ports of a placeholder composite.
   * @param isInput  true if input ports
   * @param defn     composite definition
   * @param countMap place to store map from composite operator name to 
   *                 dynamic parameter count.
   */
  void countDynamicParameterReferences(
                        PortCollection& ports,
                        bool isInput,
                        const CompositeDefinition& defn,
                        std::map<std::wstring, int> &countMap);

  /**
   * Given that we have expanded a reference to composite with a clone
   * of the operators and arrows in the composite definition, we now
   * wire in the subgraph.  In the plan referencing the composite, there
   * is a placeholder DesignTimeComposite operator.  The arrows pointing to
   * this placeholder op are "redirected" to point to the subgraph.  Likewise
   * with outputs from the placeholder op.  The placeholder op is deleted.
   *
   * @param placeholderOp  a reference to a composite that will be replaced
   *                       with the expanded subgraph.
   * @param prefix      prefix that was added to the cloned operators (ends in !).
   * @param nameToOpMap map of new operator name to new operator
   * @param defn        definition of the composite we are expanding.
   */
  void wireUpComposite(DesignTimeComposite& placeholderOp, 
                       std::wstring prefix,
                       std::map<std::wstring, DesignTimeOperator*> &nameToOpMap,
                       CompositeDefinition& defn);

  /**
   * Delete all channels that reference that given operator.  This
   * method is used as part of expanding a composite reference.
   * All references to a placeholder DesignTimeComposite operator are removed.
   *
   * @param op  The operator that may referenced by channels.
   */
  void deleteChannelsReferencingOp(const DesignTimeOperator *op);

public:
  /** Constructor */
  METRAFLOW_DECL DesignTimePlan();

  /** Destructor */
  METRAFLOW_DECL ~DesignTimePlan();

  /** Add an operator to the plan */
  METRAFLOW_DECL void push_back(DesignTimeOperator * op);

  /** Add a channel to the plan. */
  METRAFLOW_DECL void push_back(DesignTimeChannel * ch);

  /**
   * Replace all references to composites with the actual sub-graphs
   * defined by the composites.
   *
   * @param compositeDictionary  dictionary defining the composites.
   */
  METRAFLOW_DECL void expandComposites(CompositeDictionary &dictionary);

  /**
   * Add a named partition list to the plan.
   * @param partitionLists The named partition lists to add to the design time plan.
   */
  METRAFLOW_DECL void add_partition_lists(const std::map<std::wstring, std::vector<boost::int32_t> >& partitionLists);

  /**
   * Check that all the operations in the plan have the required inputs
   * and determine the metadata types of all the input and output operation
   * ports.
   *
   * @param isContinueOnError  if true will keep checking operations even after
   *                           the first error is encountered, otherwise will 
   *                           stop checking.
   */
  METRAFLOW_DECL void type_check(bool isContinueOnError=false);

  /**
   * Produce the run-time plan.
   *
   * @param parallelPlan  Contains the produced run-time plan.
   */
  METRAFLOW_DECL void code_generate(ParallelPlan& parallelPlan);

  /** 
   * Set the name of the plan. This is either the step name 
   * or the composite name.  This name is used for error reporting.
   *
   * @param name  Plan name.
   */
  METRAFLOW_DECL void setName(const std::wstring& name);

  /** Get the name of the plan */
  std::wstring getName() const;

  /**
   * Create a description of the datatypes flowing over the arrows.
   * This is a list of operator/output-ports to associated datatype.
   * Basically the data flowing left to right over the arrow.
   * The list is written to output.
   */
  void describeDatatypeFlow(std::wostream& output) const;

  /**
   * Verify that all ports (inputs and outputs) in the plan are connect.
   * Throws an exception an unconnected port is encountered.
   * Although detection of unconnected ports is an inherent part
   * of type_checking, this logic is isolated in this method so
   * that it can be called prior to type_checking.  This is so that
   * we can report unconnected ports prior to the expansion of composites.
   * This simplifies error reporting.
   */
  METRAFLOW_DECL void verifyAllPortsConnected();

  /** Returns printable version of operator.  For debugging. */
  METRAFLOW_DECL std::string dump() const;
};

/**
 * A task performs work by sending and receiving messages over its endpoints.
 * A tasks initiates receives by setting up the set of its input endpoints on
 * which it is prepared to handle messages.  A task initiates sends by setting
 * up the set of its output endpoints on which it wishes to send data.  Each of
 * these sets can vary in size and membership.  Empty recieve sets and send sets
 * are valid.
 */

class RunTimeOperator
{
private:
  RunTimeOperator * mNext;
  RunTimeOperator * mPrev;
public:
  void Unlink()
  {
    mNext->mPrev = mPrev;
    mPrev->mNext = mNext;
  }
  void Link(RunTimeOperator * before)
  {
    this->mNext = before->mNext;
    this->mPrev = before;
    before->mNext->mPrev = this;
    before->mNext = this;
  }
  void LinkBefore(RunTimeOperator * after)
  {
    this->mNext = after;
    this->mPrev = after->mPrev;
    after->mPrev->mNext = this;
    after->mPrev = this;
  }
  RunTimeOperator * Next() const
  {
    return this->mNext;
  }
  RunTimeOperator * Prev() const 
  {
    return this->mPrev;
  }

protected:
  std::wstring mName;

  METRAFLOW_DECL RunTimeOperator()
    :
    mNext(NULL),
    mPrev(NULL)
  {
  }

private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mNext);
    ar & BOOST_SERIALIZATION_NVP(mPrev);
    ar & BOOST_SERIALIZATION_NVP(mName);
  } 

public:
  // Create the operator in runtime mode.
  METRAFLOW_DECL RunTimeOperator(const std::wstring& name);

  virtual METRAFLOW_DECL ~RunTimeOperator();

  virtual METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition) =0;

  METRAFLOW_DECL const wchar_t * GetName() const
  {
    return mName.c_str();
  }

};

class RunTimeOperatorActivation
{
protected:
  boost::uint64_t mTicksInOperator;
  boost::uint64_t mExecutions;

  // Endpoints connected to Input and output ports
  std::vector<Endpoint *> mInputs;
  std::vector<Endpoint *> mOutputs;

  // Reactor
  Reactor * mReactor;

  // Partition configuration
  partition_t mPartition;

  // Index of this partition within the list of partitions on which the operator's activations are executing
  std::size_t mPartitionIndex;

  virtual void AddInput(Channel * channel)
  {
    mInputs.push_back(channel->GetTarget());
  }
  virtual void AddOutput(Channel * channel)
  {
    mOutputs.push_back(channel->GetSource());
  }

  void RequestRead(boost::int32_t port);
  void RequestWrite(boost::int32_t port);
  void Read(MessagePtr & m, Endpoint * ep);
  void Write(MessagePtr m, Endpoint * ep, bool close=false);

public:
  METRAFLOW_DECL RunTimeOperatorActivation(Reactor * reactor, partition_t partition);

  virtual METRAFLOW_DECL ~RunTimeOperatorActivation();

  partition_t GetPartition() const
  {
    return mPartition;
  }
  
  std::size_t GetPartitionIndex() const
  {
    return mPartitionIndex;
  }
  
  void SetPartitionIndex(std::size_t partitionIndex) 
  {
    mPartitionIndex = partitionIndex;
  }
  
  void SetReactor(Reactor * reactor)
  {
    mReactor = reactor;
  }

  virtual METRAFLOW_DECL const wchar_t * GetName() const =0;

  // Graph Building Interfaces
  METRAFLOW_DECL virtual void SetInput(port_t port, Channel * channel)
  {
    if(port >= mInputs.size()) mInputs.resize(port+1);
    mInputs[port] = channel->GetTarget();
  }
  METRAFLOW_DECL virtual void SetInput(port_t port, Endpoint * endpoint)
  {
    if(port >= mInputs.size()) mInputs.resize(port+1);
    mInputs[port] = endpoint;
  }
  METRAFLOW_DECL virtual Endpoint * GetInput(port_t port)
  {
    return mInputs[port];
  }
  METRAFLOW_DECL port_t GetNumInputs() const
  {
    return mInputs.size();
  }
  METRAFLOW_DECL virtual void SetOutput(port_t port, Channel * channel)
  {
    if(port >= mOutputs.size()) mOutputs.resize(port+1);
    mOutputs[port] = channel->GetSource();
  }
  METRAFLOW_DECL virtual void SetOutput(port_t port, Endpoint * endpoint)
  {
    if(port >= mOutputs.size()) mOutputs.resize(port+1);
    mOutputs[port] = endpoint;
  }
  METRAFLOW_DECL virtual Endpoint * GetOutput(port_t port)
  {
    return mOutputs[port];
  }
  METRAFLOW_DECL port_t GetNumOutputs() const
  {
    return mOutputs.size();
  }
  METRAFLOW_DECL const std::vector<Endpoint*>& GetInputs() const
  {
    return mInputs;
  }

  void UpdateExecutionStatistics(boost::uint64_t ticks)
  {
    mTicksInOperator += ticks;
    mExecutions += 1LL;
  }
  boost::uint64_t GetOperatorTicks() const
  {
    return mTicksInOperator;
  }
  boost::uint64_t GetOperatorExecutions() const
  {
    return mExecutions;
  }

  //
  // Execution interface
  //

  /**
   * Start processing event
   */
  virtual void Start() {}

  /**
   * I/O event
   */
  virtual void HandleEvent(Endpoint * in) =0;

  /**
   * Complete processing event
   */
  virtual void Complete() {}
};

template <class _T>
class RunTimeOperatorActivationImpl : public RunTimeOperatorActivation
{
private:
  std::wstring mName;
protected:
  const _T * mOperator;
public:
  RunTimeOperatorActivationImpl(Reactor * reactor, partition_t partition, const _T * op)
    :
    RunTimeOperatorActivation(reactor, partition),
    mName((boost::wformat(L"%1%(%2%)") % op->GetName() % partition).str()),
    mOperator(op)
  {
  }

  ~RunTimeOperatorActivationImpl()
  {
  }

  METRAFLOW_DECL const wchar_t * GetName() const
  {
    return mName.c_str();
  }
};

  // The endpoint state machine.
  // A read endpoint handles three events: 
  // RequestRead
  // ReadChannel
  // WriteChannel
  // A write endpoint handles three events:
  // RequestWrite
  // ReadChannel
  // WriteChannel
  //
  // The endpoint may be in one of several states.
  // Disabled, Enabled_0, Enabled_1, Enabled_2, ... , Enabled_N
  // The Disabled state is a read endpoint that the operator has no request on.
  // The Enabled_0 state is a read endpoint that the operator has a request on 
  // but is empty.
  // The Enabled_1 state is a read endpoint that the operator has a request on
  // but has 1 element in the associated channel.
  // The Enabled_i state is a read endpoint that the operator has a request on
  // but has between 2^i and 2^{i+1}-1 elements in the associated channel.
  // Reads in higher states have higher priority.
  // Similarly, write endpoints in the same set of states.
  // Writes in higher states have lower priority.

  // Remote endpoints are handled a bit differently.  
  // Remote channels are implemented with MPI and a channel is represented as an MPI tag.
  // The connected remote read endpoint and remote write endpoint are connected by virtue of
  // of the value of an associated tag.  All MPI communication is done with non-blocking synchronous
  // MPI messages.  This means that the write endpoint will be able to implement effective flow control.
  // Remote write endpoints have queues with states much like the local write endpoint case (priorities
  // and such).
  // Remote read endpoints have no queuing.  Requests to read from them go directly to non-blocking MPI
  // synchronous read requests.  WriteChannel events for remote read endpoints map to the completion
  // of the associated MPI read request. One subtle thing to note about remote read endpoints is that 
  // it is possible for an MPI read to be outstanding even if there is no read request on the endpoint.  Consider
  // the following: Request Read on all inputs (some of which are local and some of which are remote), Complete
  // Read on local input (cancelling requests on remote endpoints).  At this point the MPI request still exists.
  // Note that this is essentially the same as a queue of one element on the remote read endpoint.
  //
  // Remote write endpoints continue to have queuing.  Requests to read from them go directly to non-blocking MPI
  // synchronous read requests.  WriteChannel events for remote read endpoints map to the completion
  // of the associated MPI read request.

  // The implementation simply stores endpoints in a collection of doubly linked lists each list
  // corresponding to one of the states above so that the scheduler can quickly find endpoints 
  // to process.
  // The other issue to deal with is to guarantee that an operator is not invoked concurrently.
  // Another gotcha is that when a read or write to a channel occurs and it results in 
  // reprioritization, that reprioritization effects both endpoints; these endpoints may be
  // in different schedulers!  This fact scares me quite a bit; in effect we may have to
  // take 2 locks for every read/write (3 if you count the lock on the channel itself). 
  // One lock is taken for the scheduler on each end of the channel and 1 lock on the channel.
  // Furthermore, preventing deadlock implies that we must establish a global lock order and that 
  // may be hard to respect (in practice I haven't had a problem with this yet).
  // This scheduling algorithm owes a lot to Ingo Molnar's O(1) scheduler for Linux.
  // The unique aspect of this scheduling problem seems to be frequency with which processes
  // are reprioritized.
class LinuxProcessor : public Reactor
{
private:
  // The spin lock protects mReadBitmask, mReadQueue, mWriteBitmask, mWriteQueue, mDisabled, mNumRunning, mNumEnabled.
  // It also protects the mNext, mPriority and mOperator members of each Endpoint owned by this Processor.
  // We could get more concurrency with finer grain locking but I am concerned about the overhead.
  MetraFlow::SpinLock mLock;
  partition_t mPartition;
  Endpoint * mDisabled;
  boost::uint32_t mReadBitmask;
  Endpoint * mReadQueue[32];
  boost::uint32_t mWriteBitmask;
  Endpoint * mWriteQueue[32];
  // The number of requests that may be run.  mNumRunning = Sum_{i>0} Length(mReadQueue[i]) + Length(mWriteQueue[i])
  // Only modified when lock is held
  boost::int32_t mNumRunning;
  // The number of requests that are pending or being serviced.
  // Only modified by the thread of control of the processor.
  // mNumEnabled = Sum_{i} Length(mReadQueue[i]) + Length(mWriteQueue[i])
  boost::int32_t mNumEnabled;

  bool mStopFlag;

  // Performace tracking
  boost::uint64_t mOperatorReadTicks;
  boost::uint64_t mOperatorReadExecutions;
  boost::uint64_t mOperatorWriteTicks;
  boost::uint64_t mOperatorWriteExecutions;
  boost::uint64_t mTestTicks;
  boost::uint64_t mTestExecutions;
  boost::uint64_t mWaitTicks;
  boost::uint64_t mWaitExecutions;

  bool IsPending(Endpoint * ep) const 
  { 
    return ep->GetPriority() >= 0;
  }

  void CheckQueueInvariants();
  void CheckIsRemoteInvariants(Endpoint * ep);
  void CheckIsNotRemoteInvariants(Endpoint * ep);

  void EnqueueReadRequest(Endpoint * ep, boost::int32_t priority)
  {
    if (priority > 0) mNumRunning++;
    mNumEnabled++;
    mDisabled = ep->Unlink();
    mReadQueue[priority] = ep->LinkBefore(mReadQueue[priority]);
    mReadBitmask |= ((boost::uint32_t)1 << priority);
    ep->SetPriority(priority);
  }

  void ClearReadRequest(Endpoint * ep)
  {
    boost::int32_t priority(ep->GetPriority());
    if (priority > 0)
      mNumRunning--;
    mReadQueue[priority] = ep->Unlink();
    if (NULL == mReadQueue[priority])
      mReadBitmask &= ~((boost::uint32_t)1 << priority);
    mDisabled = ep->LinkBefore(mDisabled);
    ep->SetPriority(-1);
    mNumEnabled--;
  }

  void ReprioritizeReadRequest(Endpoint * ep, boost::int32_t prevPriority, boost::int32_t newPriority)
  {
    mReadQueue[prevPriority] = ep->Unlink();
    if (NULL == mReadQueue[prevPriority])
      mReadBitmask &= ~((boost::uint32_t)1 << prevPriority);
    ep->SetPriority(newPriority);
    mReadQueue[newPriority] = ep->LinkBefore(mReadQueue[newPriority]);
    mReadBitmask |= ((boost::uint32_t)1 << newPriority);
    if (prevPriority == 0)
      mNumRunning++;
  }

  void EnqueueWriteRequest(Endpoint * ep, boost::int32_t priority)
  {
    if (priority > 0) mNumRunning++;
    mNumEnabled++;
    mDisabled = ep->Unlink();
    mWriteQueue[priority] = ep->LinkBefore(mWriteQueue[priority]);
    mWriteBitmask |= ((boost::uint32_t)1 << priority);
    ep->SetPriority(priority);
  }

  void ClearWriteRequest(Endpoint * ep)
  {
    boost::int32_t priority(ep->GetPriority());
    if (priority > 0)
      mNumRunning--;
    mWriteQueue[priority] = ep->Unlink();
    if (NULL == mWriteQueue[priority])
      mWriteBitmask &= ~((boost::uint32_t)1 << priority);
    mDisabled = ep->LinkBefore(mDisabled);
    ep->SetPriority(-1);
    mNumEnabled--;
  }

  void ReprioritizeWriteRequest(Endpoint * ep, boost::int32_t prevPriority, boost::int32_t newPriority)
  {
    mWriteQueue[prevPriority] = ep->Unlink();
    if (NULL == mWriteQueue[prevPriority])
      mWriteBitmask &= ~((boost::uint32_t)1 << prevPriority);
    ep->SetPriority(newPriority);
    mWriteQueue[newPriority] = ep->LinkBefore(mWriteQueue[newPriority]);
    mWriteBitmask |= ((boost::uint32_t)1 << newPriority);
    if (prevPriority == 0)
      mNumRunning++;
  }

//   //
//   // Serialization support
//   //
//   friend class boost::serialization::access;
//   template<class Archive>
//   void serialize(Archive & ar, const unsigned int version)
//   {
//     ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(Reactor);
//     ar & BOOST_SERIALIZATION_NVP(mPartition);
//     ar & BOOST_SERIALIZATION_NVP(mDisabled);
//     ar & BOOST_SERIALIZATION_NVP(mReadQueue);
//     ar & BOOST_SERIALIZATION_NVP(mWriteQueue);
//     ar & BOOST_SERIALIZATION_NVP(mNumRunning);
//     ar & BOOST_SERIALIZATION_NVP(mNumEnabled);
//   } 
protected:
  METRAFLOW_DECL void InternalRequestRead(RunTimeOperatorActivation * task, Endpoint * ep);
  METRAFLOW_DECL void InternalRequestWrite(RunTimeOperatorActivation * task, Endpoint * ep);

  // HACK: Flag set during initialization so the batch policy
  // can pass write requests through to the core scheduler.
  bool mIsStarting;

  void InternalLinkDisabled(Endpoint * ep)
  {
    ep->SetPriority(-1);
    mDisabled = ep->LinkBefore(mDisabled);
  }

  void InternalUnlinkDisabled(Endpoint * ep)
  {
    if (ep->GetPriority() != -1)
    {
      throw std::runtime_error("Trying to unlink endpoint from Disabled when Priority != -1");
    }
    mDisabled = ep->Unlink();
  }

public:
  METRAFLOW_DECL LinuxProcessor(partition_t partition=0);
  METRAFLOW_DECL virtual ~LinuxProcessor();

  static void * operator new (size_t sz)
  {
    // Ensure alginment on cache line boundary.  Add sizeof(void *) bytes
    // for original pointer, then align the returned structure to cacheline.
    size_t allocSz = sz + 127 + sizeof(void *);
    void * ptr = ::malloc(allocSz);
    unsigned char * aligned = reinterpret_cast<unsigned char *>(((reinterpret_cast<size_t>(ptr)+127) >> 7) << 7);
    *((void **)(aligned + sz)) = ptr;
    return aligned;
  }

  static void operator delete (void * p, size_t sz)
  {
    // Find stashed original pointer
    void * original = * reinterpret_cast<void **>((reinterpret_cast<unsigned char *>(p) + sz));
    ::free(original);
  }

  METRAFLOW_DECL void Start(const std::vector<RunTimeOperatorActivation *> & ops);
  METRAFLOW_DECL void Stop();
  // Load up the set of all open files.
  METRAFLOW_DECL void Add(Endpoint * ep);
  METRAFLOW_DECL void Add(Channel * c);
  METRAFLOW_DECL void OnRead(boost::int32_t prevCapacity, boost::int32_t newCapacity, Endpoint * source, Endpoint * target);
  METRAFLOW_DECL void OnWrite(boost::int32_t prevCapacity, boost::int32_t newCapacity, Endpoint * source, Endpoint * target);
  METRAFLOW_DECL void OnRead(MPIRecvEndpoint * target);
  METRAFLOW_DECL void OnWrite(MPISendEndpoint * source);
  METRAFLOW_DECL void OnReadCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, MPISendEndpoint * target);
  METRAFLOW_DECL void OnWriteCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, MPIRecvEndpoint * source);

  // Strategy the processor uses to run an operator.
  METRAFLOW_DECL virtual void ScheduleOperator(RunTimeOperatorActivation * task, Endpoint * ep)=0;

  // These two methods are part of the magic heuristic of the scheduler.
  // For a given channel capacity sz these tell us the priority of a 
  // read or write to that channel.
  static boost::int32_t GetReadPriority(boost::int32_t sz)
  {
    boost::int32_t rawPriority = sz;
    boost::int32_t off;
    unsigned char zf;
#ifdef WIN32
    __asm { bsr eax, dword ptr [rawPriority] };
    __asm { mov dword ptr [off], eax }; 
    __asm { setz zf };
#else
    __asm__ ("bsrl %2, %%eax\n\t"
             "movl %%eax, %0\n\t" 
             "setzb %1\n\t"
             : "=r"(off), "=r"(zf)
             : "r"(rawPriority)
             : "%eax");
#endif
    return zf ? 0 : off+1;
  }

  static boost::int32_t GetWritePriority(boost::int32_t sz)
  {
    return 31 - GetReadPriority(sz);
  }

  // Debugging interfaces
  METRAFLOW_DECL void DumpQueues(std::wostream& ostr);
  METRAFLOW_DECL void DumpStatistics(std::ostream& ostr);
  boost::uint64_t GetOperatorReadTicks() const { return mOperatorReadTicks; }
  boost::uint64_t GetOperatorReadExecutions() const { return mOperatorReadExecutions; }
  boost::uint64_t GetOperatorWriteTicks() const { return mOperatorWriteTicks; }
  boost::uint64_t GetOperatorWriteExecutions() const { return mOperatorWriteExecutions; }
  boost::uint64_t GetTestTicks() const { return mTestTicks; }
  boost::uint64_t GetTestExecutions() const { return mTestExecutions; }
  boost::uint64_t GetWaitTicks() const { return mWaitTicks; }
  boost::uint64_t GetWaitExecutions() const { return mWaitExecutions; }
};

class LowLatencyScheduler : public LinuxProcessor
{
public:
  static void * operator new (size_t sz)
  {
    // Ensure alginment on cache line boundary.  Add sizeof(void *) bytes
    // for original pointer, then align the returned structure to cacheline.
    size_t allocSz = sz + 127 + sizeof(void *);
    void * ptr = ::malloc(allocSz);
    unsigned char * aligned = reinterpret_cast<unsigned char *>(((reinterpret_cast<size_t>(ptr)+127) >> 7) << 7);
    *((void **)(aligned + sz)) = ptr;
    return aligned;
  }

  static void operator delete (void * p, size_t sz)
  {
    // Find stashed original pointer
    void * original = * reinterpret_cast<void **>((reinterpret_cast<unsigned char *>(p) + sz));
    ::free(original);
  }

  METRAFLOW_DECL LowLatencyScheduler(partition_t partition=0)
    :
    LinuxProcessor(partition)
  {
  }

  METRAFLOW_DECL ~LowLatencyScheduler()
  {
  }

  // Called by the scheduler when the operator is allowed to run.
  void ScheduleOperator(RunTimeOperatorActivation * task, Endpoint * ep)
  {
    task->HandleEvent(ep);
  }
  // Called by the operator to read and write channels.
  void RequestRead(RunTimeOperatorActivation * task, Endpoint * ep)
  {
    InternalRequestRead(task, ep);
  }
  void RequestWrite(RunTimeOperatorActivation * task, Endpoint * ep)
  {
    InternalRequestWrite(task, ep);
  }
  void WriteChannel(Endpoint * ep, MessagePtr m, bool close)
  {
    ep->Write(m, *this);
  }
  void ReadChannel(Endpoint * ep, MessagePtr& m)
  {
    ep->Read(m, *this);
  }
};

// There is at least one somewhat subtle issue with batch scheduling that I haven't
// really thought enough about yet.  If I pick an operator to schedule,
// I do that by picking ONE endpoint that is enabled (in the case of non-deterministic
// reads there may in fact be multiple enable endpoints, but I think we can ignore that?).
// As I process, the operator may generate read and write requests on different inputs
// and outputs.  For the case of inputs, my current thinking is that for read requests that
// can be satisfied by the local queues, these read requests are handled and disposed of
// within the BatchSchedulingPolicy.  On the other hand, writes requests may be generated
// and these may or may not have a corresponding write request in the scheduler itself.  
// Think of the case in which I have a switch operator:
//           ------------>
// ------>
//           ------------> (called because this is enabled).
//
// During processing this operator, I may generate multiple write requests to each of the outputs.
// For the case of the write request that existed when our policy object was called, we
// can swallow all of the internally generated write requests.  For the other output, we must generate
// a write request before we can flush our local queues.
// The other thing to be concerned about is the possibility that the basic scheduling
// heuristic is defeated by batching.  Consider the operator above and suppose that 
// the scheduler picks this operator with a high priority write on the bottom output.  Suppose
// that the channel above is actually very full and that the operator writes one record
// to the bottom channel and then writes the rest of the batch to the top.  At this point,
// the operator makes a request to read on the bottom (still high priority) and yields
// back to the scheduler.  To the scheduler it looks like this operator only wants to do
// high priority writes, however the lion's share of work it is doing is really low priority.
// One way of looking at the underlying issue is that we are currently assinging priorities
// to individual read and write requests and what we really need to do when batch scheduling is
// to assign priorities to operators.  While it is perfectly clear how to assign a priority to
// an individual I/O, it is much less clear how to define operator priority.  Moreover, there is
// an additional subtle issue which is that today the priority on different read requests are
// used to select non-deterministic reads; that is a nice property that we'd like to keep.
//
// Here is a possible solution.
// The scheduler continues to see the world in terms of scheduling endpoints.  Endpoints are
// associated with FIFO channels (of "infinite" capacity) but also have local queues.  Operators
// only read from local/endpoint queues.  Local queues (at least write queues) are assumed
// to have finite capacity.  Operators are given a timeslice in which they
// run until either read blocked (reading from empty local read queue) or write blocked (writing
// to a full local write queue).  At this point they yield to the scheduler.
// The scheduler essentially schedules local read queue loads and local write queue stores (both
// of these loads/stores are to corresponding channels in the SMP case).  Priority is assigned to
// read queue loads and write queue stores the way it is today (based on channel size).  After performing
// a read queue load or write queue store, the scheduler schedules the corresponding operator until it
// blocks again.  
//
// One thing to consider here is that when an operator yields, there may be stuff in its write queues.
// There may be implications to leaving that data in there!  On the other hand, if we proactively store
// local write queues before they are full we may be defeating the scheduling algorithm.  Hmm.....
// One possibility is that we "schedule" the local write queue stores; but the problem is that if 
// the scheduler schedules these stores they may not unblock the operator.  Could be that we want to
// be prepared for that.  
//
// For the moment I am punting on this issue except for the special case of EOF on local write channels.
// These I am proactively storing as there is really no issue with bypassing the scheduler this one time.
class BatchScheduler : public LinuxProcessor
{
private:
  // The current endpoint we are scheduling.
  Endpoint * mEndpoint;
  // A list of endpoints that need to be sync'd.  The only
  // case that I have right now is a local write channel that
  // is at EOF.  These sync's bypass the scheduler so must
  // be used carefully.
  Endpoint * mPendingSyncs;
public:
  static void * operator new (size_t sz)
  {
    // Ensure alginment on cache line boundary.  Add sizeof(void *) bytes
    // for original pointer, then align the returned structure to cacheline.
    size_t allocSz = sz + 127 + sizeof(void *);
    void * ptr = ::malloc(allocSz);
    unsigned char * aligned = reinterpret_cast<unsigned char *>(((reinterpret_cast<size_t>(ptr)+127) >> 7) << 7);
    *((void **)(aligned + sz)) = ptr;
    return aligned;
  }

  static void operator delete (void * p, size_t sz)
  {
    // Find stashed original pointer
    void * original = * reinterpret_cast<void **>((reinterpret_cast<unsigned char *>(p) + sz));
    ::free(original);
  }

  METRAFLOW_DECL BatchScheduler(partition_t partition=0);
  METRAFLOW_DECL ~BatchScheduler();
  METRAFLOW_DECL void ScheduleOperator(RunTimeOperatorActivation * task, Endpoint * ep);
  METRAFLOW_DECL void RequestRead(RunTimeOperatorActivation * task, Endpoint * ep);
  METRAFLOW_DECL void RequestWrite(RunTimeOperatorActivation * task, Endpoint * ep);
  METRAFLOW_DECL void WriteChannel(Endpoint * ep, MessagePtr m, bool close);
  METRAFLOW_DECL void ReadChannel(Endpoint * ep, MessagePtr& m);
};

/**
 * A parallel plan executes by implementing a number of reactors
 * each executing on its own thread.  Each reactor owns a number of
 * operators and the endpoints attached to them.  The only way operators
 * in different reactors communicate is by channels crossing reactors (hence
 * channels may not be owned by a particular reactor).  
 */
class ParallelPartition
{
private:
  Reactor * mReactor;
  partition_t mPartition;
  std::vector<RunTimeOperatorActivation *> mActivations;

  METRAFLOW_DECL ParallelPartition();

public:
  METRAFLOW_DECL ParallelPartition(partition_t partition);
  METRAFLOW_DECL ~ParallelPartition();

  partition_t GetPartition() const
  {
    return mPartition;
  }

  Reactor * GetReactor()
  {
    return mReactor; 
  }
  /**
   * Add the operator to the partition.
   * @param op The operator to add
   * @param ops Reference to a mapping of partitions to the RunTimeOperatorActivations that they contain.
   * @param partitionIndex The position of this partition in the list of partitions in which op is being added.
   */
  void AddOperator(RunTimeOperator * op,
                   PartitionActivationMap & ops,
                   std::size_t partitionIndex);

  // Run the partition
  void InternalStart(ParallelPartitionCompletions& completions);   

  void Stop();

  // Grab statistics (don't take any locks)
  void DumpStatistics(std::ostream & ostr);
};

// Represents a single machine with potentially many partitions.
// Channels can connect partitions within a domain.
class ParallelDomain
{
private:
  // Reactors and partition
  std::map<partition_t, ParallelPartition *> mPartitions;
  // Channels
  std::vector<Channel *> mChannels;
  std::vector<IntraDomainChannelSpec *> mChannelSpecs;
  std::vector<InterDomainReadEndpointSpec *> mRemoteReadSpecs;
  std::vector<InterDomainWriteEndpointSpec *> mRemoteWriteSpecs;

  // MPI Service and associated endpoints
  MPIService * mMessageService;
  std::vector<MPISendEndpoint*> mMpiSendEndpoints;
  std::vector<MPIRecvEndpoint*> mMpiRecvEndpoints;

  partition_t mPartitionStart;
  partition_t mPartitionEnd;

  METRAFLOW_DECL ParallelDomain();

  // "Database" containing operators, channels, endpoints and reactors
  void InsertChannel(Channel * c);
//   Channel * CreateChannel(ParallelPartition * source, ParallelPartition * target);
  METRAFLOW_DECL void CreateChannel(IntraDomainChannelSpec * spec);
  METRAFLOW_DECL void CreateRemoteReadEndpoint(InterDomainReadEndpointSpec * spec);
  METRAFLOW_DECL void CreateRemoteWriteEndpoint(InterDomainWriteEndpointSpec * spec);

public:

  void Connect(RunTimeOperatorActivation * sourceOperator, port_t sourcePort,
               RunTimeOperatorActivation * targetOperator, port_t targetPort,
               bool locallyBuffered, bool buffered)
  {
    mChannelSpecs.push_back(new IntraDomainChannelSpec(sourceOperator, sourcePort,
                                                       targetOperator, targetPort,
                                                       locallyBuffered, buffered));
    CreateChannel(mChannelSpecs.back());
  }
  void ConnectRemoteRead(RunTimeOperatorActivation * op, port_t port, const RecordMetadata& metadata,
                         partition_t remotePartition, boost::int32_t tag)
  {
    mRemoteReadSpecs.push_back(new InterDomainReadEndpointSpec(op, port, metadata, remotePartition, tag));
    CreateRemoteReadEndpoint(mRemoteReadSpecs.back());
  }
  void ConnectRemoteWrite(RunTimeOperatorActivation * op, port_t port, const RecordMetadata& metadata,
                          partition_t remotePartition, boost::int32_t tag, bool locallyBuffered)
  {
    mRemoteWriteSpecs.push_back(new InterDomainWriteEndpointSpec(op, port, metadata, remotePartition, tag, locallyBuffered));
    CreateRemoteWriteEndpoint(mRemoteWriteSpecs.back());
  }
 
  METRAFLOW_DECL ParallelDomain(partition_t partitionStart, partition_t partitionEnd);
  METRAFLOW_DECL ~ParallelDomain();
  void AddOperator(RunTimeOperator * op, 
                   const boost::dynamic_bitset<>& partitionMask,
                   PartitionActivationMap & ops);
  METRAFLOW_DECL void Start();
};

// class ParallelPlan
// {
// private:
//   boost::int32_t mParallelism;
//   boost::int32_t mTag;
//   // Indexing for the structure the operators into domains and their partitions.
//   std::vector<boost::shared_ptr<ParallelDomain> > mDomains;
//   std::vector<DomainPartitionMap *> mOperatorSets;


//   /**
//    * Connect a set of upstream operators to downstream operators.  Assuming
//    * one instance per reactor and no cross-reactor communication.
//    */ 
//   void ConnectStraightLine(ParallelDomain * domain, 
//                            const PartitionOperatorMap& upstream, boost::int32_t outputPort,
//                            const PartitionOperatorMap& downstream, boost::int32_t inputPort,
//                            bool locallyBuffered, const RecordMetadata & metadata);

//   /**
//    * Connect a sequential partitioner to a upstream operator.
//    */
//   void ConnectSequentialBroadcast(ParallelDomain * upstreamDomain,
//                                   const PartitionOperatorMap& upstream,
//                                   ParallelDomain * downstreamDomain,
//                                   const PartitionOperatorMap& downstream,
//                                   port_t inputPort,
//                                   bool locallyBuffered,
//                                   const RecordMetadata & metadata);
//   /**
//    * Connect an upstream operator to a downstream sequential collector.
//    */
//   void ConnectSequentialCollect(ParallelDomain * upstreamDomain,
//                                 const PartitionOperatorMap& upstream,
//                                 ParallelDomain * downstreamDomain,
//                                 const PartitionOperatorMap& downstream,
//                                 port_t outputPort,
//                                 bool locallyBuffered,
//                                 const RecordMetadata & metadata);

//   /**
//    * Connect a set of upstream operators to downstream operators.  Assuming
//    * one instance per reactor and crossbar (complete bipartite) communication.
//    * TODO: This is actually not the "correct" interface since in this model, 
//    * the input and output ports are the "parallel" versions; hence really don't
//    * correspond to an ordinary endpoint.  
//    */ 
//   void ConnectCrossbar(ParallelDomain * upstreamDomain,
//                        const PartitionOperatorMap& upstream,
//                        ParallelDomain * downstreamDomain,
//                        const PartitionOperatorMap& downstream,
//                        bool locallyBuffered, 
//                        const RecordMetadata & metadata);

// public:
//   METRAFLOW_DECL ParallelPlan(boost::int32_t parallelism, bool multipleDomains=false);
//   METRAFLOW_DECL ~ParallelPlan();

//   /**
//    * Get the channel that connected to output port upPort of  partiton upPart of upOp.
//    */
// //   METRAFLOW_DECL Channel * GetOutputChannel(operator_set_t upOp, port_t upPort, partition_t upPart);

//   METRAFLOW_DECL operator_set_t AddOperator(DesignTimeOperator * op);

//   METRAFLOW_DECL void ConnectStraightLine(operator_set_t upstream, boost::int32_t outputPort,
//                                           operator_set_t downstream, boost::int32_t inputPort,
//                                           bool locallyBuffered, const RecordMetadata & metadata);

//   METRAFLOW_DECL void ConnectSequentialBroadcast(operator_set_t upstream,
//                                                  operator_set_t downstream,
//                                                  port_t inputPort,
//                                                  bool locallyBuffered,
//                                                  const RecordMetadata & metadata);

//   METRAFLOW_DECL void ConnectSequentialCollect(operator_set_t upstream,
//                                                operator_set_t downstream,
//                                                port_t outputPort,
//                                                bool locallyBuffered,
//                                                const RecordMetadata & metadata);

//   METRAFLOW_DECL void ConnectCrossbar(operator_set_t upstream,
//                                       operator_set_t downstream,
//                                       bool locallyBuffered,
//                                       const RecordMetadata & metadata);

//   METRAFLOW_DECL void Dump(std::ostream & ostr) const;

//   const std::vector<boost::shared_ptr<ParallelDomain> >& GetDomains() const
//   {
//     return mDomains;
//   }

//   boost::int32_t GetParallelism() const
//   {
//     return mParallelism;
//   }
// };

class StraightLineChannelSpec2
{
private:
  operator_set_t mUpstream;
  boost::int32_t mOutputPort;
  operator_set_t mDownstream;
  boost::int32_t mInputPort;
  bool mLocallyBuffered;
  bool mBuffered;
  RecordMetadata mMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_NVP(mUpstream);
    ar & BOOST_SERIALIZATION_NVP(mOutputPort);
    ar & BOOST_SERIALIZATION_NVP(mDownstream);
    ar & BOOST_SERIALIZATION_NVP(mInputPort);
    ar & BOOST_SERIALIZATION_NVP(mLocallyBuffered);
    ar & BOOST_SERIALIZATION_NVP(mBuffered);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  }  

  METRAFLOW_DECL StraightLineChannelSpec2()
    :
    mUpstream(0),
    mOutputPort(0),
    mDownstream(0),
    mInputPort(0),
    mLocallyBuffered(false)
  {
  }
public:
  METRAFLOW_DECL StraightLineChannelSpec2(operator_set_t upstream, boost::int32_t outputPort,
                                          operator_set_t downstream, boost::int32_t inputPort,
                                          bool locallyBuffered, bool buffered, const RecordMetadata & metadata)
    :
    mUpstream(upstream),
    mOutputPort(outputPort),
    mDownstream(downstream),
    mInputPort(inputPort),
    mLocallyBuffered(locallyBuffered),
    mBuffered(buffered),
    mMetadata(metadata)
  {
  }

  METRAFLOW_DECL ~StraightLineChannelSpec2() {}

  operator_set_t GetUpstream() const { return mUpstream; }
  boost::int32_t GetOutputPort() const { return mOutputPort; }
  operator_set_t GetDownstream() const { return mDownstream; }
  boost::int32_t GetInputPort() const { return mInputPort; }
  bool GetLocallyBuffered() const { return mLocallyBuffered; }
  bool GetBuffered() const { return mBuffered; }
};

class SequentialCollectChannelSpec2
{
private:
  operator_set_t mUpstream;
  boost::int32_t mOutputPort;
  operator_set_t mDownstream;
  boost::int32_t mInputPort;
  bool mLocallyBuffered;
  boost::int32_t mTag;
  RecordMetadata mMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_NVP(mUpstream);
    ar & BOOST_SERIALIZATION_NVP(mOutputPort);
    ar & BOOST_SERIALIZATION_NVP(mDownstream);
    ar & BOOST_SERIALIZATION_NVP(mInputPort);
    ar & BOOST_SERIALIZATION_NVP(mLocallyBuffered);
    ar & BOOST_SERIALIZATION_NVP(mTag);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  }  

  METRAFLOW_DECL SequentialCollectChannelSpec2()
    :
    mUpstream(0),
    mOutputPort(0),
    mDownstream(0),
    mInputPort(0),
    mLocallyBuffered(false),
    mTag(0)
  {
  }
public:
  METRAFLOW_DECL SequentialCollectChannelSpec2(operator_set_t upstream, boost::int32_t outputPort,
                                       operator_set_t downstream, boost::int32_t inputPort,
                                       bool locallyBuffered, const RecordMetadata & metadata,
                                       boost::int32_t tag)
    :
    mUpstream(upstream),
    mOutputPort(outputPort),
    mDownstream(downstream),
    mInputPort(inputPort),
    mLocallyBuffered(locallyBuffered),
    mTag(tag),
    mMetadata(metadata)
  {
  }

  METRAFLOW_DECL ~SequentialCollectChannelSpec2() {}

  operator_set_t GetUpstream() const { return mUpstream; }
  boost::int32_t GetOutputPort() const { return mOutputPort; }
  operator_set_t GetDownstream() const { return mDownstream; }
  boost::int32_t GetInputPort() const { return mInputPort; }
  bool GetLocallyBuffered() const { return mLocallyBuffered; }
  boost::int32_t GetTag() const { return mTag; }
  const RecordMetadata& GetMetadata() const { return mMetadata; }
  
};

class SequentialBroadcastChannelSpec2
{
private:
  operator_set_t mUpstream;
  boost::int32_t mOutputPort;
  operator_set_t mDownstream;
  boost::int32_t mInputPort;
  bool mLocallyBuffered;
  boost::int32_t mTag;
  RecordMetadata mMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_NVP(mUpstream);
    ar & BOOST_SERIALIZATION_NVP(mOutputPort);
    ar & BOOST_SERIALIZATION_NVP(mDownstream);
    ar & BOOST_SERIALIZATION_NVP(mInputPort);
    ar & BOOST_SERIALIZATION_NVP(mLocallyBuffered);
    ar & BOOST_SERIALIZATION_NVP(mTag);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  }  

  METRAFLOW_DECL SequentialBroadcastChannelSpec2()
    :
    mUpstream(0),
    mOutputPort(0),
    mDownstream(0),
    mInputPort(0),
    mLocallyBuffered(false),
    mTag(0)
  {
  }
public:
  METRAFLOW_DECL SequentialBroadcastChannelSpec2(operator_set_t upstream, boost::int32_t outputPort,
                                       operator_set_t downstream, boost::int32_t inputPort,
                                       bool locallyBuffered, const RecordMetadata & metadata,
                                       boost::int32_t tag)
    :
    mUpstream(upstream),
    mOutputPort(outputPort),
    mDownstream(downstream),
    mInputPort(inputPort),
    mLocallyBuffered(locallyBuffered),
    mTag(tag),
    mMetadata(metadata)
  {
  }

  METRAFLOW_DECL ~SequentialBroadcastChannelSpec2() {}

  operator_set_t GetUpstream() const { return mUpstream; }
  boost::int32_t GetOutputPort() const { return mOutputPort; }
  operator_set_t GetDownstream() const { return mDownstream; }
  boost::int32_t GetInputPort() const { return mInputPort; }
  bool GetLocallyBuffered() const { return mLocallyBuffered; }
  boost::int32_t GetTag() const { return mTag; }
  const RecordMetadata& GetMetadata() const { return mMetadata; }
  
};

/// A Bipartite channel connects two sets of
/// operators using a bipartite graph.  Each 
/// channel is assigned a unique identifier (MPI tag)
/// and the base tag is stored with the spec.  There
/// are M*N channels created from this spec and they are
/// indexed by the upstream source index and the downstream
/// target index (where the index is within the subset of
/// partitions that the channel is connecting).
/// Note that an implicit assumption with Bipartite channels is that 
/// they are connecting port 0 of both their source and target.
/// This makes them different from sequential collect and broadcast.
class BipartiteChannelSpec2
{
private:
  operator_set_t mUpstream;
  boost::int32_t mOutputPort;
  operator_set_t mDownstream;
  boost::int32_t mInputPort;
  bool mLocallyBuffered;
  boost::int32_t mTag;
  RecordMetadata mMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_NVP(mUpstream);
    ar & BOOST_SERIALIZATION_NVP(mOutputPort);
    ar & BOOST_SERIALIZATION_NVP(mDownstream);
    ar & BOOST_SERIALIZATION_NVP(mInputPort);
    ar & BOOST_SERIALIZATION_NVP(mLocallyBuffered);
    ar & BOOST_SERIALIZATION_NVP(mTag);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  }  

  METRAFLOW_DECL BipartiteChannelSpec2()
    :
    mUpstream(0),
    mOutputPort(0),
    mDownstream(0),
    mInputPort(0),
    mLocallyBuffered(false),
    mTag(0)
  {
  }
public:
  METRAFLOW_DECL BipartiteChannelSpec2(operator_set_t upstream, boost::int32_t outputPort,
                                       operator_set_t downstream, boost::int32_t inputPort,
                                       bool locallyBuffered, const RecordMetadata & metadata,
                                       boost::int32_t tag)
    :
    mUpstream(upstream),
    mOutputPort(outputPort),
    mDownstream(downstream),
    mInputPort(inputPort),
    mLocallyBuffered(locallyBuffered),
    mTag(tag),
    mMetadata(metadata)
  {
  }

  METRAFLOW_DECL ~BipartiteChannelSpec2() {}

  operator_set_t GetUpstream() const { return mUpstream; }
  boost::int32_t GetOutputPort() const { return mOutputPort; }
  operator_set_t GetDownstream() const { return mDownstream; }
  boost::int32_t GetInputPort() const { return mInputPort; }
  bool GetLocallyBuffered() const { return mLocallyBuffered; }
  boost::int32_t GetTag() const { return mTag; }
  const RecordMetadata& GetMetadata() const { return mMetadata; }
  
};

class ParallelPlan
{
private:
  // Total number of partitions
  boost::int32_t mNumPartitions;
  // Total number of domains
  boost::int32_t mNumDomains;
  // Vector of length mNumPartitions; gives domain assigment of every partition
  std::vector<boost::int32_t> mPartitionDomains;
  // Operators in the plan
  std::vector<RunTimeOperator *> mOperators;
  // Which partitions is a given operator in?
  std::vector<boost::dynamic_bitset<> > mOperatorPartitionMask;
  // Channel constructors: two graph topologies supported today
  std::vector<StraightLineChannelSpec2> mStraightLineChannels;
  std::vector<SequentialBroadcastChannelSpec2> mSequentialBroadcastChannels;
  std::vector<SequentialCollectChannelSpec2> mSequentialCollectChannels;
  std::vector<BipartiteChannelSpec2> mBipartiteChannels;
  // Tag counter for labeling MPI endpoints
  boost::int32_t mTag;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void save(Archive & ar, const unsigned int version) const
  {
    std::vector<std::string> masks;
    for(std::vector<boost::dynamic_bitset<> >::const_iterator it=mOperatorPartitionMask.begin();
        it != mOperatorPartitionMask.end();
        ++it)
    {
      std::string tmp;
      boost::to_string(*it, tmp);
      masks.push_back(tmp);
    }

    ar & BOOST_SERIALIZATION_NVP(mNumPartitions);
    ar & BOOST_SERIALIZATION_NVP(mNumDomains);
    ar & BOOST_SERIALIZATION_NVP(mPartitionDomains);
    ar & BOOST_SERIALIZATION_NVP(mOperators);
    ar & BOOST_SERIALIZATION_NVP(masks);
    ar & BOOST_SERIALIZATION_NVP(mStraightLineChannels);
    ar & BOOST_SERIALIZATION_NVP(mSequentialBroadcastChannels);
    ar & BOOST_SERIALIZATION_NVP(mSequentialCollectChannels);
    ar & BOOST_SERIALIZATION_NVP(mBipartiteChannels);
    ar & BOOST_SERIALIZATION_NVP(mTag);
  }  
  template<class Archive>
  void load(Archive & ar, const unsigned int version) 
  {
    std::vector<std::string> masks;
    ar & BOOST_SERIALIZATION_NVP(mNumPartitions);
    ar & BOOST_SERIALIZATION_NVP(mNumDomains);
    ar & BOOST_SERIALIZATION_NVP(mPartitionDomains);
    ar & BOOST_SERIALIZATION_NVP(mOperators);
    ar & BOOST_SERIALIZATION_NVP(masks);
    ar & BOOST_SERIALIZATION_NVP(mStraightLineChannels);
    ar & BOOST_SERIALIZATION_NVP(mSequentialBroadcastChannels);
    ar & BOOST_SERIALIZATION_NVP(mSequentialCollectChannels);
    ar & BOOST_SERIALIZATION_NVP(mBipartiteChannels);
    ar & BOOST_SERIALIZATION_NVP(mTag);

    for(std::vector<std::string >::const_iterator it=masks.begin();
        it != masks.end();
        ++it)
    {
      mOperatorPartitionMask.push_back(boost::dynamic_bitset<>(*it));
    }
  }  
  BOOST_SERIALIZATION_SPLIT_MEMBER()

  METRAFLOW_DECL ParallelPlan()
    :
    mNumPartitions(0),
    mNumDomains(0),
    mTag(0)
  {
  }
public:
  METRAFLOW_DECL ParallelPlan(boost::int32_t parallelism, bool multipleDomains=false);
  METRAFLOW_DECL ~ParallelPlan();

  METRAFLOW_DECL operator_set_t AddOperator(DesignTimeOperator * op, 
                                            const std::map<std::wstring, std::vector<boost::int32_t> > & partitionLists);

  METRAFLOW_DECL void ConnectStraightLine(operator_set_t upstream, boost::int32_t outputPort,
                                          operator_set_t downstream, boost::int32_t inputPort,
                                          bool locallyBuffered, bool buffered, const RecordMetadata & metadata);

  METRAFLOW_DECL void ConnectSequentialBroadcast(operator_set_t upstream,
                                                 operator_set_t downstream,
                                                 port_t inputPort,
                                                 bool locallyBuffered,
                                                 const RecordMetadata & metadata);

  METRAFLOW_DECL void ConnectSequentialCollect(operator_set_t upstream,
                                               operator_set_t downstream,
                                               port_t outputPort,
                                               bool locallyBuffered,
                                               const RecordMetadata & metadata);

  METRAFLOW_DECL void ConnectCrossbar(operator_set_t upstream,
                                      operator_set_t downstream,
                                      bool locallyBuffered,
                                      const RecordMetadata & metadata);

  boost::int32_t GetParallelism() const
  {
    return mNumPartitions;
  }

  boost::int32_t GetNumDomains() const
  {
    return mNumDomains;
  }

  METRAFLOW_DECL boost::shared_ptr<ParallelDomain> GetDomain(boost::int32_t domainNumber);
};

inline boost::int32_t SingleEndpoint::GetSize() const
{
  return GetChannel()->GetSize(); 
}

inline void SingleEndpoint::Read(MessagePtr& m, CapacityChangeHandler & cch)
{
  GetChannel()->Read(m, cch);
}

inline void SingleEndpoint::Write(MessagePtr m, CapacityChangeHandler & cch)
{
  GetChannel()->Write(m, cch);
}

inline void SingleEndpoint::SyncLocalQueue(CapacityChangeHandler & cch)
{
  if (IsSource())
    GetChannel()->WriteAll(GetLocalQueue(), cch);
  else
    GetChannel()->ReadAll(GetLocalQueue(), cch);
}

inline void RunTimeOperatorActivation::RequestRead(boost::int32_t port)
{
  mReactor->RequestRead(this, mInputs[port]);
}

inline void RunTimeOperatorActivation::RequestWrite(boost::int32_t port)
{
  mReactor->RequestWrite(this, mOutputs[port]);
}

inline void RunTimeOperatorActivation::Read(MessagePtr & m, Endpoint * ep)
{
  mReactor->ReadChannel(ep, m);
}

inline void RunTimeOperatorActivation::Write(MessagePtr m, Endpoint * ep, bool close)
{
  mReactor->WriteChannel(ep, m, close);
}

#endif
