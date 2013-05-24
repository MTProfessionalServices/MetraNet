#include "RemoteEndpoint.h"
#include "StringConvert.h"
#include <boost/format.hpp>

//#define DO_TIMING

#ifdef DO_TIMING
#define TIMER_TICK() \
    __asm { rdtsc }; \
    __asm { mov dword ptr [tick], eax }; \
    __asm { mov dword ptr [tick+4], edx }

#define TIMER_TOCK() \
    __asm { rdtsc }; \
    __asm { mov dword ptr [tock], eax }; \
    __asm { mov dword ptr [tock+4], edx }
#else
#define TIMER_TICK() tick = 0LL
#define TIMER_TOCK() tock = 0LL
#endif

///
// Ideas for improving performance of remote I/O
// 1) Use blocking sends
// 2) Eliminate buffering altogether on remote endpoints (local channels will do any necessary buffering).
// 3) Simplify buffering picture by only enabling it where ncessary.
// 4) A new non-buffered channel/endpoint abstraction that bypasses scheduler.
// 5) Use a single MPI tag/request to send all messages (reduce the amount of checking code in asynch case).
// 6) Barrier sync at start to avoid drift (this really shouldn't be necessary as things should resync).

//#define TRACE_REMOTE_ENDPOINTS 1
#define BLOCKING_REMOTE_WRITE 1

RemoteEndpoint::RemoteEndpoint(RunTimeOperatorActivation * op, const RecordMetadata& metadata, boost::int32_t tag)
  :
  Endpoint(op),
  mMetadata(metadata),
  mTag(tag),
  mIndex(0),
  mPartition(0),
  mRequest(MPI_REQUEST_NULL),
  mAckRequest(MPI_REQUEST_NULL),
  mIsClosed(false),
  mIsSchedulerWaiting(false)
{
  mNextRemote = mPrevRemote = this;
#ifdef TRACE_REMOTE_ENDPOINTS
  mLogger = MetraFlowLoggerManager::GetLogger("[RemoteEndpoint]");
#endif
}

void RemoteReadEndpoint::Start()
{
  ASSERT(GetLocalQueue().GetSize() == 0 && mRequest == MPI_REQUEST_NULL && false == mIsClosed);
  int ret = MPI_Irecv(mBuffer, mBufferLength, MPI_BYTE, mSource, GetTag(), MPI_COMM_WORLD, &mRequest);
#ifdef TRACE_REMOTE_ENDPOINTS
  mLogger->logWarning((boost::format("this=%p, mSize=%d, mIsClosed=%d, MPI_Irecv(?,?,MPI_BYTE,%d,%d)") %
                      this %
                      GetLocalQueue().GetSize() % 
                      (int) mIsClosed %
                      mSource %
                      GetTag()).str());
#endif
}

void RemoteReadEndpoint::Read(MessagePtr& m, CapacityChangeHandler & cch)
{
  SyncLocalQueue(cch);
  ASSERT(GetLocalQueue().GetSize() > 0);
  GetLocalQueue().Pop(m);
}

void RemoteReadEndpoint::Write(MessagePtr m, CapacityChangeHandler & cch)
{
  throw std::runtime_error("Not Implemented");
}

void RemoteReadEndpoint::CompleteRemoteRequest(CapacityChangeHandler & cch)
{
  // Complete the outstanding request and send the
  // next if needed.
  boost::int32_t prevCapacity=GetSize();
  boost::int32_t localQueueSize = GetLocalQueue().GetSize();
  mRequest = MPI_REQUEST_NULL;
  boost::int32_t initialSize = mReceiveQueueSize;
  // Create a temporary queue.
  MPIMessagePtrQueue tmpQueue;
  boost::uint8_t * buf = mBuffer;
  boost::int32_t numRecords = *((boost::int32_t *)buf);
  buf += sizeof(boost::int32_t);
  for (boost::int32_t i = 0; i < numRecords; i++)
  {
    ASSERT(false == mIsClosed);
    MessagePtr m = mMetadata.Allocate();
    buf += mDeserializer.Deserialize(buf, m);
    // Make sure we don't get hosed from a linked list pointer
    // from the outside world!
    RecordMetadata::SetNext(m, NULL);
    if (mMetadata.IsEOF(m))
    {
      mIsClosed = true;
      tmpQueue.SetClosed(true);
    }
    tmpQueue.Push(m);
  }
  // Place temp queue on the queue of queues.
  mReceiveQueueSize += tmpQueue.GetSize();
  mReceiveQueue.push_front(tmpQueue);

#ifdef TRACE_REMOTE_ENDPOINTS
  mLogger->logWarning((boost::format("this=%p, mSize=%d, mIsClosed=%d, MPI_Irecv(?,?,MPI_BYTE,%d,%d) completed") % this % mReceiveQueueSize % (int) mIsClosed % mSource % GetTag()).str());
#endif
  ASSERT(mReceiveQueueSize > initialSize);
  cch.OnWriteCompletion(prevCapacity, GetSize(), this);
  if (false == mIsClosed && mRequest == MPI_REQUEST_NULL)
  {
    int ret = MPI_Irecv(mBuffer, mBufferLength, MPI_BYTE, mSource, GetTag(), MPI_COMM_WORLD, &mRequest);
#ifdef TRACE_REMOTE_ENDPOINTS
    mLogger->logWarning((boost::format("this=%p, mSize=%d, mIsClosed=%d, MPI_Irecv(?,?,MPI_BYTE,%d,%d)") % this % mReceiveQueueSize % (int) mIsClosed % mSource % GetTag()).str());
#endif
  }  
}

void RemoteReadEndpoint::CompleteAckRequest(CapacityChangeHandler & cch)
{
  mAckRequest = MPI_REQUEST_NULL;
  if (mAcks.size() > 0)
  {
    // Is there a pending ack to be sent?
    mAckBuffer.Credit = mAcks.back();
    mAcks.pop_back();
    int ret = MPI_Issend(&mAckBuffer, sizeof(mAckBuffer), MPI_BYTE, mSource, GetAckTag(), MPI_COMM_WORLD, &mAckRequest);
  }
}

bool RemoteReadEndpoint::IsWaitable() const
{
  // I am waitable if I am need to read another message and have an outstanding request
  return mRequest != MPI_REQUEST_NULL || mAckRequest != MPI_REQUEST_NULL;
}

void RemoteReadEndpoint::DumpStatistics(std::ostream& ostr)
{
}

RemoteReadEndpoint::RemoteReadEndpoint(RunTimeOperatorActivation * op, const RecordMetadata& metadata, boost::int32_t tag, boost::int32_t source)
  :
  RemoteEndpoint(op, metadata, tag),
  mSource(source),
  mReceiveQueueSize(0),
  mDeserializer(mMetadata),
  mBufferLength(0),
  mBuffer(NULL)
{
  mBufferLength = 128*1024;
  mBuffer = new boost::uint8_t [mBufferLength];
}

RemoteReadEndpoint::~RemoteReadEndpoint()
{
}

void RemoteReadEndpoint::SyncLocalQueue(CapacityChangeHandler& cch)
{
  // Move data from source queue to local queue.
  mReceiveQueueSize -= mReceiveQueue.back().GetSize();
  GetLocalQueue().Push(mReceiveQueue.back());
  mReceiveQueue.pop_back();
  
  // TODO: Remove or property interpret capacity parameters.
  cch.OnRead(0, 0, this);
  
  if (mAckRequest != MPI_REQUEST_NULL)
  {
    mAcks.push_front(GetLocalQueue().GetSize());
  }
  else
  {
    mAckBuffer.Credit = GetLocalQueue().GetSize();
    int ret = MPI_Issend(&mAckBuffer, sizeof(mAckBuffer), MPI_BYTE, mSource, GetAckTag(), MPI_COMM_WORLD, &mAckRequest);
  }
}

void RemoteWriteEndpoint::Read(MessagePtr& m, CapacityChangeHandler & cch)
{
  throw std::runtime_error("Not Implemented");
}

void RemoteWriteEndpoint::Write(MessagePtr m, CapacityChangeHandler & cch)
{
  ASSERT(!mIsClosed);
  GetLocalQueue().Push(m);
  if(mMetadata.IsEOF(m))
  {
    mIsClosed = true;
  }
  SyncLocalQueue(cch);
}

void RemoteWriteEndpoint::DumpStatistics(std::ostream & ostr)
{
  std::string utf8Str;
  ::WideStringToUTF8(GetOperator()->GetName(), utf8Str);

  ostr << "\n\"RemoteWrite(" << utf8Str << "," << GetTag() << "," << GetDest() << ")\" " 
       << GetSize() << " " << GetNumWritten() << " " << mSerializeTicks << " " << mSerializeExecutions 
       << " " << mSendTicks << " " << mSendExecutions << " " << GetPriority();
}

void RemoteWriteEndpoint::SendMessages(MessagePtrQueue& q)
{
  // We only allow a single outstanding request.
  ASSERT(mRequest == MPI_REQUEST_NULL);
  ASSERT(q.GetSize() > 0);
  boost::int32_t queueSize = q.GetSize();
  boost::uint8_t * buf = mBuffer;
  boost::uint8_t * end = mBuffer+mBufferLength;

  // Make room for number of records at front.  We don't know
  // this yet.
  buf += sizeof(boost::int32_t);
  // Fill up buffer with available records.
  boost::int32_t messageRecords(0);
  for (boost::int32_t i = 0; i<queueSize; i++)
  {
    boost::uint8_t * nbuf = mSerializer.Serialize(q.Top(), buf, end);
    if (nbuf != NULL)
    {
      MessagePtr m;
      q.Pop(m);
      buf = nbuf;
      messageRecords += 1;
      mMetadata.Free(m);
    }
    else
    {
      break;
    }
  }

  // Place number of records at front of buffer.
  *((boost::int32_t *) mBuffer) = messageRecords;
  // Make a note of more stuff on the wire, decrement when ACK'd
  mWireRecords += messageRecords;

#ifdef DEBUG
  for(int i=0; i<64; i++)
  {
    if (mBuffer[mBufferLength + i] != 0xdb)
      throw std::runtime_error("Buffer overrun");
  }
#endif

  // TODO: Currently we don't handle records bigger than a single buffer.
  // TODO: Support fragmenting a record into multiple messages.
  ASSERT(messageRecords > 0);
  ASSERT(mWireRecords > 0);
  ASSERT(mBufferLength >= (buf-mBuffer));
  int ret = MPI_Issend(mBuffer, buf-mBuffer, MPI_BYTE, mDest, GetTag(), MPI_COMM_WORLD, &mRequest);
#ifdef TRACE_REMOTE_ENDPOINTS
  mLogger->logWarning((boost::format("this=%p, mSize=%d, mIsClosed=%d, MPI_Issend(?,?,MPI_BYTE,%d,%d)") % this % GetSendQueue().GetSize()+mWireRecords % (int) mIsClosed % mDest % GetTag()).str());
#endif

  // Start pumping ACKs if not already done.
  if (mAckRequest == MPI_REQUEST_NULL)
  {
    ret = MPI_Irecv(&mAckBuffer, sizeof(mAckBuffer), MPI_BYTE, mDest, GetAckTag(), MPI_COMM_WORLD, &mAckRequest);    
  }
}

boost::int32_t RemoteWriteEndpoint::GetSize() const
{
#ifdef BLOCKING_REMOTE_WRITE
  return GetLocalQueue().GetSize() + GetSendQueue().GetSize() + mWireRecords;
#else
  if (LinuxProcessor::GetWritePriority(std::numeric_limits<boost::int32_t>::max()) != 0)
  {
    throw std::runtime_error("LinuxProcessor::GetWritePriority(std::numeric_limits<boost::int32_t>::max()) != 0");
  }
  return 
    mRequest == MPI_REQUEST_NULL ? 
    GetLocalQueue().GetSize() + GetSendQueue().GetSize() + mWireRecords : 
    std::numeric_limits<boost::int32_t>::max();
#endif
}

void RemoteWriteEndpoint::CompleteRemoteRequest(CapacityChangeHandler & cch)
{
#ifdef BLOCKING_REMOTE_WRITE
  ASSERT(FALSE);
#else
  // Complete the outstanding request.
  // If we are blocked, then mark as unblocked.
  mRequest = MPI_REQUEST_NULL;
  if (GetPriority() != -1)
  {
    ASSERT(GetPriority() == 0);
    cch.OnReadCompletion(std::numeric_limits<boost::int32_t>::max(), GetSize(), this);
  }
#endif
}

void RemoteWriteEndpoint::CompleteAckRequest(CapacityChangeHandler & cch)
{
  boost::int32_t prevCapacity = GetSize();
  mAckRequest = MPI_REQUEST_NULL;
  mWireRecords -= mAckBuffer.Credit;
#ifdef BLOCKING_REMOTE_WRITE
  if (GetPriority() != -1)
#else
  if (GetPriority() != -1 && mRequest == MPI_REQUEST_NULL)
#endif
  {
    // We only recalculate priority if there is an outstanding write request.
    cch.OnReadCompletion(prevCapacity, GetSize(), this);
  }
  // More ACKs to reap
  if (mWireRecords > 0)
  {
    int ret = MPI_Irecv(&mAckBuffer, sizeof(mAckBuffer), MPI_BYTE, mDest, GetAckTag(), MPI_COMM_WORLD, &mAckRequest);
  }
}

bool RemoteWriteEndpoint::IsWaitable() const
{
  // I am waitable if I am capable of sending another message but 
  // can't becuase my current request hasn't completed.
  return mRequest != MPI_REQUEST_NULL || mAckRequest != MPI_REQUEST_NULL;
}

RemoteWriteEndpoint::RemoteWriteEndpoint(RunTimeOperatorActivation * op, const RecordMetadata& metadata, boost::int32_t tag, boost::int32_t dest)
  :
  RemoteEndpoint(op, metadata, tag),
  mDest(dest),
  mWireRecords(0),
  mBuffer(NULL),
  mBufferLength(0),
  mSerializer(mMetadata),
  mSerializeTicks(0LL),
  mSerializeExecutions(0LL),
  mSendTicks(0LL),
  mSendExecutions(0LL)
{
  mBufferLength = 128*1024;
#ifdef DEBUG
  mBuffer = new boost::uint8_t [mBufferLength + 64];
  memset(mBuffer + mBufferLength, 0xdb, 64);
#else
  mBuffer = new boost::uint8_t [mBufferLength];
#endif
}

RemoteWriteEndpoint::~RemoteWriteEndpoint()
{
  delete [] mBuffer;
}

void RemoteWriteEndpoint::SyncLocalQueue(CapacityChangeHandler& cch) 
{
#ifdef BLOCKING_REMOTE_WRITE
  // Do synchronous blocking writes.
  // We only allow a single outstanding request.
  ASSERT(mRequest == MPI_REQUEST_NULL);
  boost::uint64_t tick, tock;
  MessagePtrQueue & q(GetLocalQueue());
  ASSERT(q.GetSize() > 0);
  while(q.GetSize() > 0)
  {
    TIMER_TICK();
    boost::int32_t queueSize = q.GetSize();
    boost::uint8_t * buf = mBuffer;
    boost::uint8_t * end = mBuffer+mBufferLength;

    // Make room for number of records at front.  We don't know
    // this yet.
    buf += sizeof(boost::int32_t);
    // Fill up buffer with available records.
    boost::int32_t messageRecords(0);
    for (boost::int32_t i = 0; i<queueSize; i++)
    {
      boost::uint8_t * nbuf = mSerializer.Serialize(q.Top(), buf, end);
      if (nbuf != NULL)
      {
        MessagePtr m;
        q.Pop(m);
        buf = nbuf;
        messageRecords += 1;
        mMetadata.Free(m);
      }
      else
      {
        break;
      }
    }

    // Place number of records at front of buffer.
    *((boost::int32_t *) mBuffer) = messageRecords;
    // Make a note of more stuff on the wire, decrement when ACK'd
    mWireRecords += messageRecords;

#ifdef DEBUG
    for(int i=0; i<64; i++)
    {
      if (mBuffer[mBufferLength + i] != 0xdb)
        throw std::runtime_error("Buffer overrun");
    }
#endif
    TIMER_TOCK();
    mSerializeTicks += (tock-tick);
    mSerializeExecutions += 1;

    // TODO: Currently we don't handle records bigger than a single buffer.
    // TODO: Support fragmenting a record into multiple messages.
    TIMER_TICK();
    
    ASSERT(messageRecords > 0);
    ASSERT(mWireRecords > 0);
    ASSERT(mBufferLength >= (buf-mBuffer));
    int ret = MPI_Send(mBuffer, buf-mBuffer, MPI_BYTE, mDest, GetTag(), MPI_COMM_WORLD);
    TIMER_TOCK();
    
    mSendTicks += (tock-tick);
    mSendExecutions += 1;

#ifdef TRACE_REMOTE_ENDPOINTS
    mLogger->logWarning((boost::format("this=%p, mSize=%d, mIsClosed=%d, MPI_Issend(?,?,MPI_BYTE,%d,%d)") % this % GetSendQueue().GetSize()+mWireRecords % (int) mIsClosed % mDest % GetTag()).str());
#endif
  }

    // Start pumping ACKs if not already done.
  if (mAckRequest == MPI_REQUEST_NULL)
  {
    int ret = MPI_Irecv(&mAckBuffer, sizeof(mAckBuffer), MPI_BYTE, mDest, GetAckTag(), MPI_COMM_WORLD, &mAckRequest);    
  }
#else
  // We signal the scheduler that we are blocked whenever
  // there is a request.  Thus if we get here, the request
  // must be NULL in the "normal" case.  If we there is a forced
  // write due to a channel flush we may get here even if there is
  // an active request.  In that case we wait for the current request
  // and then proceed.
  if (mRequest != MPI_REQUEST_NULL)
  {
    MPI_Status status;
    int ret = MPI_Wait(&mRequest, &status);
    CompleteRemoteRequest(cch);
  }
  ASSERT(mRequest == MPI_REQUEST_NULL);
  MessagePtrQueue & q(GetLocalQueue());
  ASSERT(q.GetSize() > 0);
  while(q.GetSize() > 0)
  {
    boost::int32_t queueSize = q.GetSize();
    boost::uint8_t * buf = mBuffer;
    boost::uint8_t * end = mBuffer+mBufferLength;

    // Make room for number of records at front.  We don't know
    // this yet.
    buf += sizeof(boost::int32_t);
    // Fill up buffer with available records.
    boost::int32_t messageRecords(0);
    for (boost::int32_t i = 0; i<queueSize; i++)
    {
      boost::uint8_t * nbuf = mSerializer.Serialize(q.Top(), buf, end);
      if (nbuf != NULL)
      {
        MessagePtr m;
        q.Pop(m);
        buf = nbuf;
        messageRecords += 1;
        mMetadata.Free(m);
      }
      else
      {
        break;
      }
    }

    // Place number of records at front of buffer.
    *((boost::int32_t *) mBuffer) = messageRecords;
    // Make a note of more stuff on the wire, decrement when ACK'd
    mWireRecords += messageRecords;

#ifdef DEBUG
    for(int i=0; i<64; i++)
    {
      if (mBuffer[mBufferLength + i] != 0xdb)
        throw std::runtime_error("Buffer overrun");
    }
#endif

    // TODO: Currently we don't handle records bigger than a single buffer.
    // TODO: Support fragmenting a record into multiple messages.
    ASSERT(messageRecords > 0);
    ASSERT(mWireRecords > 0);
    ASSERT(mBufferLength >= (buf-mBuffer));
    ASSERT(mRequest == MPI_REQUEST_NULL);
    if (q.GetSize() > 0)
    {
      int ret = MPI_Send(mBuffer, buf-mBuffer, MPI_BYTE, mDest, GetTag(), MPI_COMM_WORLD);
    }
    else
    {
      int ret = MPI_Isend(mBuffer, buf-mBuffer, MPI_BYTE, mDest, GetTag(), MPI_COMM_WORLD, &mRequest);
    }
#ifdef TRACE_REMOTE_ENDPOINTS
    mLogger->logWarning((boost::format("this=%p, mSize=%d, mIsClosed=%d, MPI_Issend(?,?,MPI_BYTE,%d,%d)") % this % GetSendQueue().GetSize()+mWireRecords % (int) mIsClosed % mDest % GetTag()).str());
#endif
  }

  ASSERT(GetLocalQueue().GetSize() == 0);

    // Start pumping ACKs if not already done.
  if (mAckRequest == MPI_REQUEST_NULL)
  {
    int ret = MPI_Irecv(&mAckBuffer, sizeof(mAckBuffer), MPI_BYTE, mDest, GetAckTag(), MPI_COMM_WORLD, &mAckRequest);    
  }
#endif
  // TODO: Remove capacity indicators or make them meaningful (e.g. track
  // how much is on the wire).
  cch.OnWrite(GetLocalQueue().GetSize()-1, GetLocalQueue().GetSize(), this);
}
