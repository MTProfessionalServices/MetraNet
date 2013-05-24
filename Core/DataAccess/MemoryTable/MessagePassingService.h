#ifndef __MESSAGEPASSINGSERVICE_H__
#define __MESSAGEPASSINGSERVICE_H__

#include "Scheduler.h"
#include "mpi.h"
#include "LogAdapter.h"
#include "RecordSerialization.h"
#include <deque>
#include <boost/thread/mutex.hpp>
#include <boost/thread/condition.hpp>
#include <boost/thread/xtime.hpp>
#include <boost/cstdint.hpp>
#include <boost/dynamic_bitset.hpp>

/**
 * An overview of a potential approach to modeling the
 * the MPI service using existing MetraFlow scheduler concepts.
 *
 * A couple of basic ideas.  Extend the channel/endpoint model with
 * a new type of interthread channel which connects the computational
 * thread with the MPI service thread.  Actually I think we need two
 * types of channels: one for reading and one for writing.  
 *
 * There are a couple of interesting things about these channels.  The first
 * is that they are associated with 3 endpoints rather than 2.  The first endpoint
 * is a "normal" SingleEndpoint.  This is associated with the computational thread.
 * The MPI side of the channel has two endpoints.  
 * In the MPI_Send_Channel case one endpoint is for moving records through the channel
 * and into the MPI thread.  The second endpoint is for sending acks from the MPI thread
 * back into the computational thread. 
 *
 * This channel has a couple of other idiosynchrosies.  First is that it maintains
 * a size independent of its underlying queue.  The reason is that the size of this 
 * channel to the sender is equal to the number of unacked records which is likely to
 * be larger than the number of records in the actual transfer queue (since records will
 * be in flight to the receiver and waiting for acknowledgement).
 * This channel should also use a mutex/condition variable for synchronization since
 * we want to implement blocking semantics on senders when the communications resources 
 * (MPI buffers: default only 1 of them per channel) for the channel are full.
 */

class MessagePassingServiceHandler
{
public:
  virtual void OnRead(boost::int32_t endpoint) =0;
  virtual void OnWrite(boost::int32_t endpoint) =0;
  virtual void OnReadCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, boost::int32_t target) =0;
  virtual void OnWriteCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, boost::int32_t source) =0;
  virtual ~MessagePassingServiceHandler() {}  
};

// class MPISendChannel
// {
// private:
//   // We should probably use boost::mutex and condvar 
//   // to implement blocking on send.
//   MetraFlow::SpinLock mSpinLock;
//   // Written to by the sender
//   SingleEndpoint * mSource;
//   // Read from by the MPI service.  This pulls from the
//   // message queue, completes the write request but 
//   // does NOT decrement the reported size of the channel.
//   // This is done when the ack arrives.
//   MPISendDataEndpoint * mData;
//   // Acks written by the MPI service.  Decrement the
//   // size of the channel and reprioritize any pending
//   // write request.
//   MPISendAckEndpoint * mAck;

//   // Queue holds data for transfer from one thread to the other.
//   MessagePtrQueue mQueue;

//   // The number of unacked records.
//   boost::int32_t mSize;
// };

// Standard traits for a node type with a 
// public Next pointer.
template <class _T>
class StandardNodeTraits
{
public:
  typedef _T * pointer;
  static void SetNext(pointer node, pointer next)
  {
    node->Next = next;
  }
  static pointer GetNext(pointer node)
  {
    return node->Next;
  }
};

// Template intrusive fifo class
template <class _Node, class _NodeTraits = StandardNodeTraits<_Node> >
class IntrusiveFifo
{
private:
  // Singly linked list for queue. 
  typename _NodeTraits::pointer mHead;
  typename _NodeTraits::pointer mTail;
  // Statistics
  boost::int64_t mNumRead;
  volatile boost::int32_t mSize;
public:
  IntrusiveFifo()
    :
    mHead(NULL),
    mTail(NULL),
    mNumRead(0LL),
    mSize(0)
  {
  }

  ~IntrusiveFifo()
  {
  }

  // Push all of these onto the argument.
  void Push(IntrusiveFifo& m)
  {
    if (m.mHead != NULL)
    {
      if (mTail != NULL)
      {
        _NodeTraits::SetNext(mTail, m.mHead);
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
  void PushSome(IntrusiveFifo& m, boost::int32_t maxToPush)
  {
    if (m.mSize > maxToPush) 
    {
      ASSERT(m.mHead != NULL);
      // Adjust sizes.
      mSize += maxToPush;
      m.mSize -= maxToPush;
      m.mNumRead += maxToPush;
      // First to be popped off is the head.
      typename _NodeTraits::pointer first=m.mHead;
      // Scan to the maxToPush element; the last to be popped.
      typename _NodeTraits::pointer last=m.mHead;
      while(--maxToPush > 0)
      {
        last = _NodeTraits::GetNext(last);
        ASSERT(last != NULL);
      }
      if(!(_NodeTraits::GetNext(last) != NULL))
      {
        throw std::runtime_error("_NodeTraits::GetNext(last) != NULL");
      }
      // Unlink from source. No need to change tail of source.
      m.mHead = _NodeTraits::GetNext(last);
      _NodeTraits::SetNext(last, NULL);
      // Link to this
      if (mTail != NULL)
      {
        _NodeTraits::SetNext(mTail, first);
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

  typename _NodeTraits::pointer Top()
  {
    return mHead;
  }

  void Pop(IntrusiveFifo& m)
  {
    m.Push(*this);
  }

  void PopSome(IntrusiveFifo& m, boost::int32_t maxToPop)
  {
    m.PushSome(*this, maxToPop);
  }

  void Pop(typename _NodeTraits::pointer& m)
  {
    m = mHead;
    if(mHead != NULL)
    {
      mHead = _NodeTraits::GetNext(mHead);
      _NodeTraits::SetNext(m, NULL);
      mSize--;
      mNumRead++;
    }
    if(mHead == NULL)
    {
      ASSERT(mSize == 0);
      mTail = NULL;
    }
  }

  void Push(typename _NodeTraits::pointer m)
  {
    ASSERT(NULL != m);
    ASSERT(NULL == _NodeTraits::GetNext(m));
    // Append to the tail of the list
    if (mTail != NULL)
    {
      _NodeTraits::SetNext(mTail, m);
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
  boost::int64_t GetNumRead() const
  {
    return mNumRead;
  }

  boost::int64_t GetNumWritten() const
  {
    return mNumRead+GetSize();
  }
};

// Encapsulates the data model specific 
// aspects of messaging.  
// Goal is to eventually make a template parameter out of this.
// Assumptions: there are 3 storage data structures for data:
// client, shared and internal.
// client storage is the data structure appropraite for client apps.  It is
// assumed that client storage objects will only be accessed on the client thread.
// internal storage is the data structure for the service (e.g. temporary buffer to hold data during
// serialization and deserialization).  It is assumed that the internal storage object
// will only be accessed by the service thread.
// shared storage is the data structure used for synchronized transfer of data
// between client storage and internal storage.  It is assumed that shared storage
// will be accessed under protection of some external synchronization mechanism.
//
// TODO (low priority): This class doesn't quite abstract enough stuff.  It has
// responsibility for "serialization" but it has a baked in
// assumption that the target of serialization is a byte array.
// This should be abstracted out in order for us to glue in general
// MPI data types as a target for example.
class RecordReadDataModel;
class RecordWriteDataModel;

class RecordDataModel
{
public:
  typedef RecordReadDataModel read_model;
  typedef RecordWriteDataModel write_model;
};

// This class does reads of messages from MPI and produces
// MetraFlow records in fifos.
class RecordReadDataModel
{
public:
  // Concepts:
  // Assume shared_message_queue has  methods
  // Push(client_message_queue& );
  // boost::int32_t GetSize() const;
  // void PopSome(client_message_queue&, boost::int32_t );
  // Assume internal_message_queue has methods
  // Push(shared_message_queue& );
  // Pop(shared_messge_queue& );
  // At the moment none of these has to be concurrent as the
  // service provides synchronized access as appropriate.
  typedef MessagePtrQueue client_message_queue;
  typedef MessagePtrQueue shared_message_queue;
  typedef MessagePtrQueue internal_message_queue;
private:
  RecordMetadata mMetadata;
  RawBufferDearchive mArchive;
  // Place to store partially read message between Deserialize calls
  MessagePtr mMessage;
  bool mIsClosed;

public:
  METRAFLOW_DECL RecordReadDataModel(const RecordMetadata& metadata);
  METRAFLOW_DECL ~RecordReadDataModel();
  // Has a closure indicator been seen.
  // It seems like this is required in order for
  // the service to shutdown cleanly?  Perhaps not,
  // it might be better to rely on the client to shut
  // the service down explicitly?  On the read side I think
  // we really need a concept of closure for otherwise we
  // will be creating requests that will never be granted.
  METRAFLOW_DECL bool IsClosed() const;
  // Read the data from the supplied buffer and write it to the target queue.
  METRAFLOW_DECL void Deserialize(boost::uint8_t * start, boost::uint8_t * end, internal_message_queue & target);
  // Number of units in a message passing buffer.  Used so service can
  // implement flow control.
  METRAFLOW_DECL boost::int32_t RecordCount(const boost::uint8_t * buf) const;
};

// This class MetraFlow records in fifos, serializes
// and does MPI sends.
class RecordWriteDataModel
{
public:
  // Concepts:
  // Assume shared_message_queue has  methods
  // Push(client_message_queue& );
  // boost::int32_t GetSize() const;
  // void PopSome(client_message_queue&, boost::int32_t );
  // Assume internal_message_queue has methods
  // Push(shared_message_queue& );
  // Pop(shared_messge_queue& );
  // At the moment none of these has to be concurrent as the
  // service provides synchronized access as appropriate.
  typedef MessagePtrQueue client_message_queue;
  typedef MessagePtrQueue shared_message_queue;
  typedef MessagePtrQueue internal_message_queue;
private:
  RecordMetadata mMetadata;
  RawBufferArchive mArchive;
  internal_message_queue mSendQueue;
  bool mIsClosed;

public:
  METRAFLOW_DECL RecordWriteDataModel(const RecordMetadata& metadata);
  METRAFLOW_DECL ~RecordWriteDataModel();
  // Has a closure indicator been seen.
  // It seems like this is required in order for
  // the service to shutdown cleanly?  Perhaps not,
  // it might be better to rely on the client to shut
  // the service down explicitly?  On the read side I think
  // we really need a concept of closure for otherwise we
  // will be creating requests that will never be granted.
  METRAFLOW_DECL bool IsClosed() const;
  // Is it OK to load this guy?
  METRAFLOW_DECL bool CanPush() const;
  // Load the contents of the shared object into our internal
  // state and clear out the source.
  METRAFLOW_DECL void Push(shared_message_queue& q);
  // Write contents to the supplied buffer.  Report the number of 
  // units copied.
  METRAFLOW_DECL boost::uint8_t * Serialize(boost::uint8_t * start, boost::uint8_t * end);
  // Number of units in a message passing buffer.  Used so service can
  // implement flow control.
  METRAFLOW_DECL boost::int32_t RecordCount(const boost::uint8_t * buf) const;
};

class PointerAdapter;
class BufferedPointerAdapter;

// This can serve as a client write queue for message passing.
class StaticArrayAdapter
{
public:
  enum { SIZE = 32*1024 };
  typedef boost::uint32_t type;
  type payload[SIZE];

  StaticArrayAdapter()
  {
  }
  ~StaticArrayAdapter()
  {
  }
  void Push(PointerAdapter& b);
  void Pop(PointerAdapter& b);
};

// This can serve as a service internal queue for message passing.
class HeapArrayAdapter
{
public:
  enum { SIZE = 32*1024 };
  typedef boost::uint32_t type;
  type * payload;

  HeapArrayAdapter()
    :
    payload(NULL)
  {
  }
  ~HeapArrayAdapter()
  {
  }
  void Pop(BufferedPointerAdapter& b);
};

// We could use the traits pattern here...
// This can serve as a client, internal or shared queue
class PointerAdapter
{
public:
  enum { SIZE = 32*1024 };
  typedef boost::uint32_t type;

  type * payload;
  PointerAdapter()
    :
    payload(NULL)
  {
  }
  PointerAdapter(type * p)
    :
    payload(p)
  {
  }
  ~PointerAdapter()
  {
  }
  boost::int32_t GetSize() const
  {
    return payload == NULL ? 0 : 1;
  }
  void Push(PointerAdapter& b)
  {
    ASSERT(payload == NULL);
    payload = b.payload;
    b.payload = NULL;
  }
  void PopSome(PointerAdapter& b, boost::int32_t )
  {
    ASSERT(b.payload == NULL);
    b.payload = payload;
    payload = NULL;
  }
  void Pop(PointerAdapter& b)
  {
    ASSERT(b.payload == NULL);
    b.payload = payload;
    payload = NULL;
  }
  void Push(StaticArrayAdapter& b)
  {
    payload = &b.payload[0];
  }
  void PopSome(StaticArrayAdapter& b, boost::int32_t )
  {
//     memcpy(&b.payload[0],payload, SIZE*sizeof(type));
    b.payload[0] = payload[0];
    payload = NULL;
  }
};

// We could use the traits pattern here...
// This can serve as a client, internal or shared queue
class BufferedPointerAdapter
{
public:
  enum { SIZE = 32*1024 };
  typedef boost::uint32_t type;

  std::deque<type *> payload;
  BufferedPointerAdapter()
  {
  }
  ~BufferedPointerAdapter()
  {
  }
  boost::int32_t GetSize() const
  {
    return payload.size();
  }
  void Push(PointerAdapter& b)
  {
    payload.push_front(b.payload);
    b.payload = NULL;
  }
  void PopSome(PointerAdapter& b, boost::int32_t )
  {
    ASSERT(b.payload==NULL);
    b.payload = payload.back();
    payload.pop_back();
  }
  void Pop(PointerAdapter& b)
  {
    ASSERT(b.payload==NULL);
    b.payload = payload.back();
    payload.pop_back();
  }
};

inline void StaticArrayAdapter::Push(PointerAdapter& b)
{
//   memcpy(&payload[0], b.payload, SIZE*sizeof(type));
  payload[0] = b.payload[0];
  b.payload = NULL;
}
inline void StaticArrayAdapter::Pop(PointerAdapter& b)
{
  ASSERT(b.payload==NULL);
  b.payload = &payload[0];
}  

inline void HeapArrayAdapter::Pop(BufferedPointerAdapter& b)
{
  ASSERT(b.payload.size() == 0 || b.payload.front()[0] == payload[0]+1);
  b.payload.push_front(payload);
  payload = NULL;
}  

class StaticArrayWriteDataModel;
class StaticArrayReadDataModel;

class StaticArrayDataModel
{
public:
  typedef StaticArrayReadDataModel read_model;
  typedef StaticArrayWriteDataModel write_model;
};

/**
 * Useful for testing
 */
class StaticArrayWriteDataModel
{
public:
  // This one has to have storage for the write case (a place
  // for clients to put data).
  typedef StaticArrayAdapter client_message_queue;
  typedef PointerAdapter shared_message_queue;
  typedef PointerAdapter internal_message_queue;
private:
  internal_message_queue mSendQueue;
  bool mIsClosed;
  boost::uint32_t mExpected;
public:
  StaticArrayWriteDataModel()
    :
    mIsClosed(false),
    mExpected(0xffffffff)
  {
  }
  ~StaticArrayWriteDataModel()
  {
  }
  // Has a closure indicator been seen.
  // It seems like this is required in order for
  // the service to shutdown cleanly?  Perhaps not,
  // it might be better to rely on the client to shut
  // the service down explicitly?  On the read side I think
  // we really need a concept of closure for otherwise we
  // will be creating requests that will never be granted.
  bool IsClosed() const
  {
    return mIsClosed;
  }
  // Is it OK to load this guy?
  bool CanPush() const
  {
    return mSendQueue.GetSize() == 0;
  }
  // Load the contents of the shared object into our internal
  // state and clear out the source.
  void Push(shared_message_queue& q)
  {
    mSendQueue.Push(q);
  }
  // Write contents to the supplied buffer.  Clear internal queue to make room for more data.
  // Report the final buffer position.
  METRAFLOW_DECL boost::uint8_t * Serialize(boost::uint8_t * start, boost::uint8_t * end)
  {
  // Debug check against expected
  if (mExpected != 0xffffffff)
  {
    ASSERT(mSendQueue.payload[0] == mExpected);
  }
  else
  {
    // Catch you next time through
    mExpected = mSendQueue.payload[0];
    
  }
  mExpected -= 1;

  ASSERT(mIsClosed == false);
//     memcpy(start, mSendQueue.payload, PointerAdapter::SIZE*sizeof(PointerAdapter::type));
  *((boost::uint32_t *)start) = *((boost::uint32_t *)mSendQueue.payload);
    if(mSendQueue.payload[0] == 0)
    {
      mIsClosed = true;
    }
    // "Pop" off the send queue to complete the request and unblock writers.  Should this be more abstract?
    mSendQueue.payload = NULL;
    return start + PointerAdapter::SIZE*sizeof(PointerAdapter::type);
  }
  // Number of units in a message passing buffer.  Used so service can
  // implement flow control.
  METRAFLOW_DECL boost::int32_t RecordCount(const boost::uint8_t * buf) const
  {
    return buf != NULL ? 1 : 0;
  }
};

/**
 * Useful for testing
 */
class StaticArrayReadDataModel
{
public:
  typedef PointerAdapter client_message_queue;
  // This must be buffered.
  typedef BufferedPointerAdapter shared_message_queue;
  // This one has to have storage for the read case.
  typedef HeapArrayAdapter internal_message_queue;
private:
  bool mIsClosed;
  boost::uint32_t mExpected;
public:
  StaticArrayReadDataModel()
    :
    mIsClosed(false),
    mExpected(0xffffffff)
  {
  }
  ~StaticArrayReadDataModel()
  {
  }
  // Has a closure indicator been seen.
  // It seems like this is required in order for
  // the service to shutdown cleanly?  Perhaps not,
  // it might be better to rely on the client to shut
  // the service down explicitly?  On the read side I think
  // we really need a concept of closure for otherwise we
  // will be creating requests that will never be granted.
  bool IsClosed() const
  {
    return mIsClosed;
  }
  // Read the data from the supplied buffer and write it to the target queue.
  METRAFLOW_DECL void Deserialize(boost::uint8_t * start, boost::uint8_t * end, internal_message_queue & target)
  {
  // Debug check against expected
  if (mExpected != 0xffffffff)
  {
    ASSERT(*((boost::uint32_t *)start) == mExpected);
  }
  else
  {
    // Catch you next time through
    mExpected = *((boost::uint32_t *)start);
    
  }
  mExpected -= 1;

    ASSERT(target.payload == NULL);
    target.payload = new internal_message_queue::type[internal_message_queue::SIZE];
//     memcpy(target.payload, start, PointerAdapter::SIZE*sizeof(PointerAdapter::type));
    *((boost::uint32_t *)target.payload) = *((boost::uint32_t *)start);
    ASSERT(mIsClosed == false);
    if (target.payload[0] == 0)
    {
        mIsClosed = true;
    }
  }
  // Number of units in a message passing buffer.  Used so service can
  // implement flow control.
  METRAFLOW_DECL boost::int32_t RecordCount(const boost::uint8_t * buf) const
  {
    return buf != NULL ? 1 : 0;
  }
};

class ReadEndpointDescriptor
{
public:
  RecordDataModel::read_model Metadata;
  boost::int32_t Tag;
  boost::int32_t Partition;

  ReadEndpointDescriptor(const RecordDataModel::read_model& metadata,
                     boost::int32_t tag,
                     boost::int32_t partition)
    :
    Metadata(metadata),
    Tag(tag),
    Partition(partition)
  {
  }
  
//   EndpointDescriptor()
//     :
//     Tag(-1),
//     Partition(-1)
//   {
//   }
};

class WriteEndpointDescriptor
{
public:
  RecordDataModel::write_model Metadata;
  boost::int32_t Tag;
  boost::int32_t Partition;

  WriteEndpointDescriptor(const RecordDataModel::write_model& metadata,
                     boost::int32_t tag,
                     boost::int32_t partition)
    :
    Metadata(metadata),
    Tag(tag),
    Partition(partition)
  {
  }
  
//   EndpointDescriptor()
//     :
//     Tag(-1),
//     Partition(-1)
//   {
//   }
};

/**
 * A message request is a fifo queue of MessagePtr together with
 * a target endpoint.
 */
class MessageRequest : public RecordDataModel::write_model::shared_message_queue
{
public:
  MessageRequest * Next;
  boost::int32_t Endpoint;
  MessageRequest()
    :
    Next(NULL),
    Endpoint(-1)
  {
  }
  ~MessageRequest()
  {
  }
};

/**
 * The write message architecture assumes that there are two thread roles: client and service.
 * The first role is the client that produceds records to be sent.  The client
 * has a local queue to store such records (today in an Endpoint).  This queue
 * is owned by the client thread and is not shared with the service.
 * The second queue is the request queue.  This is shared between the client and service.
 * It is currently protected by a service global mutex (an coarse grained locking architecture that favors a single
 * client).
 * The third queue is an internal send queue within the service.  The service pulls from
 * this queue to process requests.  
 *
 * The rationale behind having three queues is that the shared queue is only used for
 * a quick message exchange (some simple pointer swizzling) and this should
 * reduce contention.  Note that we should probably get the intermediate queue into its
 * own cache line.
 */
class MessagePassingReadEndpoint
{
private:
  // Index of this endpoint in array.
  std::size_t mIndex;

  // Source of the read, target of the ack.
  boost::int32_t mTag;
  boost::int32_t mPartition;

  // Serialization Buffer
  boost::uint8_t * mBuffer;
  boost::int32_t mBufferLength;

  // Outstanding requests
  MPI_Request& mRequest;
  MPI_Request& mAckRequest;

  // Buffer for sending and receiving acks.
  boost::int32_t mAckBuffer;

  // Messages to ack.  Right now we only support one ack in flight
  // at any time.  So we queue pending acks locally.
  // Note also that we make a simplifying assumption and send (or queue) the
  // ack as the message is moved onto the local queue.  This is a slightly early
  // but is off by a small constant amount.
  std::deque<boost::int32_t> mAcks;

  // Amount of data remaining unack'd
  boost::int32_t mUnacked;

  // Have I seen EOF
  bool mLastMessageSeen;

  // Storage and serialization for data we are passing.
  RecordDataModel::read_model mDataModel;

  // Performance statistics
  boost::uint64_t mDeserializeTicks;
  boost::uint64_t mDeserializeExecutions;
  boost::uint64_t mRecvTicks;
  boost::uint64_t mRecvExecutions;

  boost::int32_t GetTag() const
  {
    return mTag;
  }
  boost::int32_t GetAckTag() const
  {
    return MPI_TAG_UB - mTag - 1;
  }

public:
  METRAFLOW_DECL MessagePassingReadEndpoint(const RecordDataModel::read_model& metadata, 
                                            MPI_Request& request, 
                                            MPI_Request& mAckRequest,
                                            std::size_t idx, 
                                            boost::int32_t tag, 
                                            boost::int32_t dest);
  METRAFLOW_DECL ~MessagePassingReadEndpoint();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void CompleteRemoteRequest(RecordDataModel::read_model::internal_message_queue& q, MPI_Status& status);
  METRAFLOW_DECL void CompleteAckRequest(bool& isClosed);
  METRAFLOW_DECL void ProcessAckRequest(boost::int32_t credit);
  METRAFLOW_DECL void DumpStatistics(std::ostream& ostr);

  std::size_t GetIndex() const
  {
    return mIndex;
  }
};

class MessagePassingWriteEndpoint
{
private:
  // Intrusive singly linked list
  MessagePassingWriteEndpoint * mNext;

  // Index of this endpoint in array.
  std::size_t mIndex;

  // Target of the write, source of the ack.
  boost::int32_t mTag;
  boost::int32_t mPartition;

  // Wire records, where the meaning of "record"
  // is determined by the RecordDataModel.
  boost::int32_t mWireRecords;

  // Serialization Buffer
  boost::uint8_t * mBuffer;
  boost::int32_t mBufferLength;

  // Outstanding requests
  MPI_Request& mRequest;
  MPI_Request& mAckRequest;

  // Buffer for sending and receiving acks.
  boost::int32_t mAckBuffer;

  // Have we processed our last message
  bool mLastMessageSeen;

  // Storage and serialization for data we are passing.
  RecordDataModel::write_model mDataModel;

  // Performance statistics
  boost::uint64_t mSerializeTicks;
  boost::uint64_t mSerializeExecutions;
  boost::uint64_t mSendTicks;
  boost::uint64_t mSendExecutions;

  boost::int32_t GetTag() const
  {
    return mTag;
  }
  boost::int32_t GetAckTag() const
  {
    return MPI_TAG_UB - mTag - 1;
  }

public:
  METRAFLOW_DECL MessagePassingWriteEndpoint(const RecordDataModel::write_model& metadata, 
                                             MPI_Request& request, 
                                             MPI_Request& mAckRequest,
                                             std::size_t idx, 
                                             boost::int32_t tag, 
                                             boost::int32_t dest);
  METRAFLOW_DECL ~MessagePassingWriteEndpoint();

  // Singly linked list interface.
  MessagePassingWriteEndpoint * GetNext() const
  {
    return mNext;
  }
  void SetNext(MessagePassingWriteEndpoint * next)
  {
    mNext = next;
  }

  // A write request made from the outside world.
  METRAFLOW_DECL void OnWriteRequest(RecordDataModel::write_model::shared_message_queue& q);
  // A request to process queued requests.
  METRAFLOW_DECL void ProcessWriteRequest();
  // Receipt of an ack for a previous write.
  METRAFLOW_DECL void CompleteAckRequest(bool& isClosed);
  // A previous write completed.
  METRAFLOW_DECL void CompleteRemoteRequest(bool & stillWorking);

  std::size_t GetIndex() const
  {
    return mIndex;
  }

  boost::int32_t GetWireRecords() const 
  {
    return mWireRecords;
  }
  METRAFLOW_DECL void DumpStatistics(std::ostream & ostr);
};

// An active object that encapsulates the interdomain communication.
// This is currently only safe for a single client partition within
// the domain.
class MessagePassingService
{
private:
  /**
   * The service has a collection of read endpoints and write endpoints
   * that are registered with it.  The service runs a progress routine that
   * waits/tests an underlying MPI communicator for message completion and 
   * polls input write queues for requests.
   *
   * The messaging assumes:
   * 1) Reads on endpoints are done in a loop with target side buffering.
   * 2) Writes are only done when a client makes a request and provides
   * the data.  The service serializes the records into a service managed buffer
   * and then makes an asynchronous request.
   *
   * Right now we are using condition variables for synchronization with the
   * client because we feel there is a real need for blocking/yielding in the client.
   * Without such yielding, rate matching between different partitions seems unreliable and
   * ad-hoc at best.
   */

  /**
   * The following state is the request interface between
   * the service and clients.  This is thread safe with implementation
   * provided by a condition variable.  
   * TODO: We really only want blocking on the write queue.  We could
   * implement a thread safe non-blocking read queue if the overhead of
   * the condvar becomes an issue.
   * TODO: Get the info for these message queues onto their own cache lines.
   * The current model is probably OK with the two threads we are currently
   * supporting.
   */
  MessageRequest * mWriteRequest;
  std::vector<boost::int32_t> mReadAckBuffer;
  std::vector<RecordDataModel::read_model::shared_message_queue> mReadRequest;

  MetraFlow::SpinLock mQueueGuard;
//   boost::timed_mutex mQueueGuard;
//   boost::condition mQueueCondVar;


  /**
   * The internal state of the engine.  The engine has exclusive access to
   * this stuff (buffers and MPI_Requests).
   */
  boost::dynamic_bitset<> mReadClosedMask;
  boost::dynamic_bitset<> mWriteClosedMask;

  /**
   * Requests for read, writes, read acks and write acks.
   * Also the last request is a generalized request that is used
   * as a doorbell for clients to let us know when there are records
   * written. TODO: Is it OK and performant to have a single generalized request?
   */
  std::vector<MPI_Request> requests;
  std::vector<int> indices;
  std::vector<MPI_Status> status;

  // Request policy
  // Each write endpoint gets two requests: one for writing and one for reading acks.
  // Each read endpoint gets two requests: one for reaing and one for writing acks.
  // MPI_Testsome wants requests in a contiguous buffer so we allocate them that way
  // (it is good about skipping of NULL requests).  In the common case all requests are
  // non-null so there isn't any loss in performance here either.
  //
  // What remains is to associate a completion routine with each request.

  // Endpoints
  std::vector<MessagePassingReadEndpoint*> mReadEndpoints;
  std::vector<MessagePassingWriteEndpoint*> mWriteEndpoints;
  std::vector<MessageRequest*> mWriteRequests;

  // Flag to indicate when we are about enter waitsome.
  // This flag should be set after starting a valid generalized
  // request that will be used to wakeup the wait.
  bool mWakeupRequired;

  // Flag to request that the service stop.
  // TODO: Use a generalized request to make
  // sure that we come out of an MPIWait.
  bool mStopRequest;
  
  // Performance counters
  boost::uint64_t mTestsomeTicks;
  boost::uint64_t mTestsomeRequests;
  boost::uint64_t mTestsomeExecutions;
  boost::uint64_t mWaitsomeTicks;
  boost::uint64_t mWaitsomeRequests;
  boost::uint64_t mWaitsomeExecutions;
  boost::uint64_t mCompletionTicks;
  boost::uint64_t mCompletionExecutions;
  boost::uint64_t mTransferRequestsTicks;
  boost::uint64_t mTransferRequestsExecutions;
  boost::uint64_t mProcessWriteRequestTicks;
  boost::uint64_t mProcessWriteRequestExecutions;
  boost::uint64_t mProcessReadAckRequestTicks;
  boost::uint64_t mProcessReadAckRequestExecutions;
  boost::uint64_t mMoveToSharedQueuesTicks;
  boost::uint64_t mMoveToSharedQueuesExecutions;
  boost::uint64_t mSendQueueWaitTicks;
  boost::uint64_t mSendQueueWaitExecutions;

  MetraFlowLoggerPtr mLogger;

  MessageRequest * GetRequest(boost::int32_t source);
  void ReleaseRequest(MessageRequest * r);
public:
  /**
   * Initialize the message passing service so that it will process
   * these endpoints.
   * TODO: Create our own communicator to be a good library citizen.
   */
  METRAFLOW_DECL MessagePassingService(const std::vector<ReadEndpointDescriptor>& readEndpoints, 
                                       const std::vector<WriteEndpointDescriptor>& writeEndpoints);
  METRAFLOW_DECL ~MessagePassingService();

  /**
   * The following comprises the internal service handler routine.
   */
  METRAFLOW_DECL void Run(MessagePassingServiceHandler & handler);

  /**
   * Request that this service stop.
   */
  METRAFLOW_DECL void Stop();
  

  /**
   * The following comprise the client interface to the service.  These
   * are thread safe and may (should) be called from a different thread
   * from that running the underlying service handler routine.
   *
   * Clients are expected to send on one target at a time (Send/SendAck)
   * but are expected to be able handle receiving all queued stuff in one
   * call (ReceiveAll/ReceiveAllAcks).
   *
   * TODO: Implement Receive single and SendAll interfaces (not used by MetraFlow today).
   */

  // Send a queue worth of messages from the source.  This may block if there 
  // is a message in flight.
  METRAFLOW_DECL void Send(boost::int32_t endpoint, 
                           RecordDataModel::write_model::client_message_queue& data,
                           MessagePassingServiceHandler & handler);
  // Receive a message from service.  This never blocks but may return 0 records.
  // If the last call to SyncBufferSize indicated that this endpoint had size > 0,
  // then we are guaranteed to return messages (perhaps less than size).  Note that
  // in general this method has a maximum number of messages that it will deliver
  // (flow control considerations).  The reason is that from the point of view of
  // flow control, a record is consumed as soon as it is Recv'd.  Too much buffering
  // within the receiver will defeat flow control.  This could be changed by adding
  // a method for a client to mark records as consumed but I don't see a compelling need
  // for the added complexity.
  METRAFLOW_DECL void Recv(boost::int32_t endpoint, 
                           RecordDataModel::read_model::client_message_queue& data, 
                           MessagePassingServiceHandler & handler);

  /**
   * The following can be read without taking a lock.  That means a reader outside of
   * service thread may see an underestimate of the actual size.  What this means is that 
   * the value read by this method may have changed (decremented) prior to the OnReadCompletion event
   * being fired.
   *
   * We are treating send FIFOs as having a finite capacity of 5000 records
   */
  boost::int32_t GetWriteSize(boost::int32_t endpoint) const
  {
    boost::int32_t tmp = mWriteEndpoints[endpoint]->GetWireRecords();
    return //tmp > 1000 ? 
      //std::numeric_limits<boost::int32_t>::max() : 
      tmp;
  }
  /**
   * The following can be read without taking a lock.  That means a reader outside of
   * service thread may see an overestimate of the actual size.  What this means is that 
   * the value read by this method may have changed (incremented) prior to the OnWriteCompletion event
   * being fired.
   */
  boost::int32_t GetReadSize(boost::int32_t endpoint) const
  {
    return mReadRequest[endpoint].GetSize();
  }
  METRAFLOW_DECL void DumpStatistics(std::ostream & ostr);
};

#endif
