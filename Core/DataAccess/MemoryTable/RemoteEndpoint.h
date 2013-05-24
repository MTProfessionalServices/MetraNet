#ifndef __REMOTEENDPOINT_H__
#define __REMOTEENDPOINT_H__

#include "mpi.h"
#include "Scheduler.h"
#include "LogAdapter.h"

/**
 * A RemoteReadEndpoint is a readable connection to a remote operator.  
 */

class RemoteEndpoint : public Endpoint
{
private:
  // Intrusive circular doubly linked list for remote (MPI) requests.
  RemoteEndpoint * mNextRemote;
  RemoteEndpoint * mPrevRemote;
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

  RemoteEndpoint * UnlinkRemote()
  {
    if (mPrevRemote != this)
    {
      mNextRemote->mPrevRemote = this->mPrevRemote;
      mPrevRemote->mNextRemote = this->mNextRemote;
      return this->mNextRemote;
    }
    return NULL;
  }
  RemoteEndpoint * LinkRemote(RemoteEndpoint * after)
  {
    if (after == NULL)
    {
      mPrevRemote = mNextRemote = this;
      return this;
    }
    this->mNextRemote = after;
    this->mPrevRemote = after->mPrevRemote;
    after->mPrevRemote->mNextRemote = this;
    after->mPrevRemote = this;
    return after;
  }
  RemoteEndpoint * NextRemote() const
  {
    return this->mNextRemote;
  }

protected:
  class AckMessage
  {
  public:
    boost::int32_t Credit;
  };

  RecordMetadata mMetadata;
  // MPI address information
  boost::int32_t mTag;
  endpoint_t mIndex;
  partition_t mPartition;
  MPI_Request mRequest;
  MPI_Request mAckRequest;
  // Buffer for sending and receiving acks.
  AckMessage mAckBuffer;
  // Has EOF been seen on this endpoint?
  bool mIsClosed;
  // Should the scheduler be waiting for a request
  // to complete?
  // Constraint (mIsSchedulerWaiting == false || mRequest != MPI_REQUEST_NULL)
  bool mIsSchedulerWaiting;
  MetraFlowLoggerPtr mLogger;
public:
  METRAFLOW_DECL RemoteEndpoint(RunTimeOperatorActivation * op, const RecordMetadata& metadata, boost::int32_t tag);

  void SetTag(boost::int32_t tag)
  {
    mTag = tag;
  }
  boost::int32_t GetTag()
  {
    return mTag;
  }
  boost::int32_t GetAckTag()
  {
    return MPI_TAG_UB - mTag - 1;
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

  MPI_Request GetRequest() 
  {
    return mRequest;
  }
  void SetRequest(const MPI_Request& r) 
  {
    mRequest = r;
  }
  MPI_Request GetAckRequest() 
  {
    return mAckRequest;
  }
  void SetAckRequest(const MPI_Request& r) 
  {
    mAckRequest = r;
  }
  virtual void CompleteRemoteRequest(CapacityChangeHandler &) =0;
  virtual void CompleteAckRequest(CapacityChangeHandler &) =0;

  // Network I/O strategy methods
  METRAFLOW_DECL bool IsSchedulerWaiting() const
  {
    return mIsSchedulerWaiting;
  }
  METRAFLOW_DECL void IsSchedulerWaiting(bool isSchedulerWaiting)
  {
    mIsSchedulerWaiting = isSchedulerWaiting;
  }
  virtual bool IsWaitable() const =0;
  virtual void DumpStatistics(std::ostream& ostr) =0;
};



class RemoteReadEndpoint : public RemoteEndpoint
{
private:

  class MPIMessagePtrQueue : public MessagePtrQueue
  {
  private:
    bool mIsClosed;
  public:
    MPIMessagePtrQueue()
      :
      MessagePtrQueue(),
      mIsClosed(false)
    {
    }

    bool IsClosed() const
    {
      return mIsClosed;
    }
    void SetClosed(bool isClosed)
    {
      mIsClosed = isClosed;
    }
  };

  boost::int32_t mSource;
  // Reciever side queuing. The receiver implements queuing and sends
  // acks back to the sender for each processed message.
  // Thus we assume there is exactly on ack per message.
  std::deque<MPIMessagePtrQueue> mReceiveQueue;
  boost::int32_t mReceiveQueueSize;

  // Messages to ack.  Right now we only support one ack in flight
  // at any time.  So we queue pending acks locally.
  // Note also that we make a simplifying assumption and send (or queue) the
  // ack as the message is moved onto the local queue.  This is a slightly early
  // but is off by a small constant amount.
  std::deque<boost::int32_t> mAcks;

  RecordDeserializer mDeserializer;
  // Serialization Buffer
  boost::int32_t mBufferLength;
  boost::uint8_t * mBuffer;

public:
  boost::int32_t GetSource() const
  {
    return mSource;
  }
  void SetSource(boost::int32_t source) 
  {
    mSource = source;
  }
  bool IsSource() const
  {
    return false;
  }
  boost::int32_t GetSize() const
  {
    return mReceiveQueueSize + GetLocalQueue().GetSize();
  }
  boost::int64_t GetNumRead() const
  {
    return mReceiveQueueSize + GetLocalQueue().GetNumRead();
  }
  boost::int64_t GetNumWritten() const
  {
    return GetLocalQueue().GetNumWritten();
  }

  METRAFLOW_DECL void Start();

  METRAFLOW_DECL void Read(MessagePtr& m, CapacityChangeHandler & cch);
  METRAFLOW_DECL void Write(MessagePtr m, CapacityChangeHandler & cch);
  METRAFLOW_DECL void SyncLocalQueue(CapacityChangeHandler& cch);

  METRAFLOW_DECL void CompleteRemoteRequest(CapacityChangeHandler & cch);
  METRAFLOW_DECL void CompleteAckRequest(CapacityChangeHandler &);
  METRAFLOW_DECL bool IsWaitable() const;
  METRAFLOW_DECL void DumpStatistics(std::ostream & ostr);

  METRAFLOW_DECL RemoteReadEndpoint(RunTimeOperatorActivation * op, const RecordMetadata& metadata, boost::int32_t tag, boost::int32_t source);
  METRAFLOW_DECL ~RemoteReadEndpoint();
};


/**
 * A RemoteReadEndpoint is a readable connection to a remote operator.  
 */
class RemoteWriteEndpoint : public RemoteEndpoint
{
private:
  boost::int32_t mDest;
  // Sender side queuing.
  MessagePtrQueue mSendQueue;
  MessagePtrQueue& GetSendQueue()
  {
    return mSendQueue;
  }
  const MessagePtrQueue& GetSendQueue() const
  {
    return mSendQueue;
  }

  // Number of records on the wire.
  boost::int32_t mWireRecords;

  // Serialization Buffer
  boost::uint8_t * mBuffer;
  boost::int32_t mBufferLength;
  RecordSerializer mSerializer;

  // Performance statistics
  boost::uint64_t mSerializeTicks;
  boost::uint64_t mSerializeExecutions;
  boost::uint64_t mSendTicks;
  boost::uint64_t mSendExecutions;

  void SendMessages(MessagePtrQueue& q);

public:
  METRAFLOW_DECL boost::int32_t GetDest() const
  {
    return mDest;
  }
  METRAFLOW_DECL void SetDest(boost::int32_t dest) 
  {
    mDest = dest;
  }

  METRAFLOW_DECL void CompleteRemoteRequest(CapacityChangeHandler& cch);
  METRAFLOW_DECL void CompleteAckRequest(CapacityChangeHandler &);
  METRAFLOW_DECL bool IsWaitable() const;

  bool IsSource() const
  {
    return true;
  }
  METRAFLOW_DECL boost::int32_t GetSize() const;
  boost::int64_t GetNumRead() const
  {
    return GetLocalQueue().GetNumRead();
  }
  boost::int64_t GetNumWritten() const
  {
    return GetLocalQueue().GetNumWritten() - mWireRecords;
  }

  METRAFLOW_DECL void Read(MessagePtr& m, CapacityChangeHandler & cch);
  METRAFLOW_DECL void Write(MessagePtr m, CapacityChangeHandler & cch);
  METRAFLOW_DECL void SyncLocalQueue(CapacityChangeHandler& cch);

  METRAFLOW_DECL void DumpStatistics(std::ostream & ostr);

  METRAFLOW_DECL RemoteWriteEndpoint(RunTimeOperatorActivation * op, const RecordMetadata& metadata, boost::int32_t tag, boost::int32_t dest);
  METRAFLOW_DECL ~RemoteWriteEndpoint();
};

#endif
