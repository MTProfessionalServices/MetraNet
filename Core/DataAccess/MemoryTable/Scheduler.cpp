#include "mpi.h"
#include "Scheduler.h"
#include "LogAdapter.h"
#include "MessagePassingService.h"
#include "TypeCheckException.h"
#include "CompositeDictionary.h"
#include "DesignTimeComposite.h"
#include "SortMergeCollector.h"
#include "ArgEnvironment.h"

#ifdef WIN32
#include "MTUtil.h"
#include "SEHException.h"
#include <eh.h>
#else
#include "StringConvert.h"
#endif

#include <boost/noncopyable.hpp>
#include <boost/format.hpp>
#include <boost/bind.hpp>
#include <boost/thread/thread.hpp>
#include <boost/thread/mutex.hpp>
#include <boost/thread/condition.hpp>
#include <boost/thread/xtime.hpp>
#include <boost/algorithm/string/predicate.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>

#include <set>
#include <iostream>
#include <sstream>
#include <stdexcept>

#ifdef _DEBUG
// #define CHECK_QUEUE_INVARIANTS(x) (x)->CheckQueueInvariants()
// #define CHECK_IS_REMOTE_INVARIANTS(x, y) (x)->CheckIsRemoteInvariants(y)
// #define CHECK_IS_NOT_REMOTE_INVARIANTS(x, y) (x)->CheckIsNotRemoteInvariants(y)
#define CHECK_QUEUE_INVARIANTS(x)
#define CHECK_IS_REMOTE_INVARIANTS(x, y)
#define CHECK_IS_NOT_REMOTE_INVARIANTS(x, y)
#else
#define CHECK_QUEUE_INVARIANTS(x)
#define CHECK_IS_REMOTE_INVARIANTS(x, y)
#define CHECK_IS_NOT_REMOTE_INVARIANTS(x, y)
#endif

#define DO_TIMING
#define TIME_BETWEEN_REPORTS_IN_SEC 300

#ifdef DO_TIMING
// #define TIMER_TICK() \
//     __asm { rdtsc }; \
//     __asm { mov dword ptr [tick], eax }; \
//     __asm { mov dword ptr [tick+4], edx }

// #define TIMER_TOCK() \
//     __asm { rdtsc }; \
//     __asm { mov dword ptr [tock], eax }; \
//     __asm { mov dword ptr [tock+4], edx }
#define TIMER_TICK() ::QueryPerformanceCounter((LARGE_INTEGER *) &tick)
#define TIMER_TOCK() ::QueryPerformanceCounter((LARGE_INTEGER *) &tock)
#else
#define TIMER_TICK() tick = 0LL
#define TIMER_TOCK() tock = 0LL
#endif

/**
 * This class binds the MessagePassingService to the MetraFlow 
 * Scheduler.
 *
 */
class MPIService : public MessagePassingServiceHandler
{
private:
  MessagePassingService * mService;
  boost::thread * mServiceThread;
  std::vector<MPIRecvEndpoint*> mMpiRecvEndpoints;
  std::vector<MPISendEndpoint*> mMpiSendEndpoints;
  CapacityChangeHandler * mScheduler;
  static void Run(MessagePassingService * messagePassingService, MessagePassingServiceHandler& handler);
public:
  MPIService(CapacityChangeHandler * scheduler);
  ~MPIService();
  void Start(const std::vector<MPIRecvEndpoint*>& mpiRecvEndpoints, 
             const std::vector<MPISendEndpoint*>& mpiSendEndpoints);
  void Stop();
  void Join();
  // Callback interface for the service.
  void OnRead(boost::int32_t endpoint);
  void OnWrite(boost::int32_t endpoint);
  void OnReadCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, boost::int32_t target);
  void OnWriteCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, boost::int32_t source);

  // Service interface for the client/scheduler.
  void Send(MPISendEndpoint * endpoint);
  void Recv(MPIRecvEndpoint * endpoint);
  boost::int32_t GetSize(const MPISendEndpoint * endpoint) const;
  boost::int32_t GetSize(const MPIRecvEndpoint * endpoint) const;

  // Dump statistics
  void DumpStatistics(std::ostream& ostr)
  {
    mService->DumpStatistics(ostr);
  }
};

MPIService::MPIService(CapacityChangeHandler * scheduler)
  :
  mService(NULL),
  mServiceThread(NULL),
  mScheduler(scheduler)
{
}

MPIService::~MPIService()
{
  if (mServiceThread)
  {
    mServiceThread->join();
  }
  delete mServiceThread;
  delete mService;
}

void MPIService::Run(MessagePassingService * messagePassingService, MessagePassingServiceHandler& handler)
{
  int myid;
  MPI_Comm_rank(MPI_COMM_WORLD, &myid);
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger((boost::format("[MPIService(%1%)]") % myid).str());
#ifdef WIN32
  _set_se_translator(&SEHException::TranslateStructuredExceptionHandlingException);
#endif
  // TODO: Perhaps we should use Boost Test execution_monitor here.  This has some
  // good code for handling MS structured exceptions as well as code for handling
  // signals under Unix (though perhaps not in a multi-threaded environment).
  try
  {
    logger->logInfo("MPIService starting");
    messagePassingService->Run(handler);
    logger->logInfo("MPIService shutting down");
  }
  catch(std::exception & e)
  {    
    logger->logError(e.what());
    return;
  }
#ifdef WIN32
  catch(SEHException & e)
  {    
    logger->logError(e.what());
    logger->logError(e.callStack());
    return;
  }
#endif
  catch(...)
  {
    logger->logError("Unknown exception");
    return;
  }
}

void MPIService::Start(const std::vector<MPIRecvEndpoint*>& mpiRecvEndpoints, 
                       const std::vector<MPISendEndpoint*>& mpiSendEndpoints)
{
  // Save a copy of the MPIEndpoints for callbacks.
  mMpiRecvEndpoints = mpiRecvEndpoints;
  mMpiSendEndpoints = mpiSendEndpoints;

  // Create descriptors from MPIEndpoints.  
  std::vector<ReadEndpointDescriptor> readEndpoints;
  std::vector<WriteEndpointDescriptor> writeEndpoints;
  
  for(std::vector<MPIRecvEndpoint*>::const_iterator it=mMpiRecvEndpoints.begin();
      it != mMpiRecvEndpoints.end();
      ++it)
  {
    readEndpoints.push_back(ReadEndpointDescriptor((*it)->GetMetadata(), (*it)->GetTag(), (*it)->GetRemotePartition()));
  }
  for(std::vector<MPISendEndpoint*>::const_iterator it=mMpiSendEndpoints.begin();
      it != mMpiSendEndpoints.end();
      ++it)
  {
    writeEndpoints.push_back(WriteEndpointDescriptor((*it)->GetMetadata(), (*it)->GetTag(), (*it)->GetRemotePartition()));
  }

  // The Message Passing Service
  mService = new MessagePassingService (readEndpoints, writeEndpoints);
  boost::function0<void> threadFunc = boost::bind(&MPIService::Run, mService, boost::ref(*this));
  mServiceThread = new boost::thread (threadFunc);
}

void MPIService::Stop()
{
   mService->Stop();
}

void MPIService::Join()
{
  if (mServiceThread)
  {
    mServiceThread->join();
  }
  delete mServiceThread;
  mServiceThread = NULL;
}

void MPIService::OnRead(boost::int32_t endpoint)
{
  mScheduler->OnRead(mMpiRecvEndpoints[endpoint]);
}

void MPIService::OnWrite(boost::int32_t endpoint)
{
  mScheduler->OnWrite(mMpiSendEndpoints[endpoint]);
}

void MPIService::OnReadCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, boost::int32_t target)
{
  mScheduler->OnReadCompletion(prevCapacity, newCapacity, mMpiSendEndpoints[target]);
}

void MPIService::OnWriteCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, boost::int32_t source)
{
  mScheduler->OnWriteCompletion(prevCapacity, newCapacity, mMpiRecvEndpoints[source]);
}

void MPIService::Send(MPISendEndpoint * endpoint)
{
  mService->Send(endpoint->GetEndpointIndex(), endpoint->GetLocalQueue(), *this);
}

void MPIService::Recv(MPIRecvEndpoint * endpoint)
{
  mService->Recv(endpoint->GetEndpointIndex(), endpoint->GetLocalQueue(), *this);
}

boost::int32_t MPIService::GetSize(const MPISendEndpoint * endpoint) const
{
  return mService->GetWriteSize(endpoint->GetEndpointIndex());
}

boost::int32_t MPIService::GetSize(const MPIRecvEndpoint * endpoint) const
{
  return mService->GetReadSize(endpoint->GetEndpointIndex());
}

MPISendEndpoint::MPISendEndpoint(RunTimeOperatorActivation * op, 
                                 MPIService * service,
                                 boost::int32_t endpointIndex,
                                 const RecordMetadata& metadata, 
                                 boost::int32_t tag, 
                                 boost::int32_t partition,
                                 bool locallyBuffered)
  :
  Endpoint(op, locallyBuffered),
  mService(service),
  mIsSource(true),
  mIndex(-1),
  mPartition(-1),
  mEndpointIndex(endpointIndex),
  mRemotePartition(partition),
  mTag(tag),
  mMetadata(metadata)
{
}

MPISendEndpoint::~MPISendEndpoint()
{
}

boost::int32_t MPISendEndpoint::GetSize() const
{
  return mService->GetSize(this);
}

void MPISendEndpoint::Read(MessagePtr& m, CapacityChangeHandler& pch)
{
  ASSERT(FALSE);
}

void MPISendEndpoint::Write(MessagePtr m, CapacityChangeHandler& pch)
{
  GetLocalQueue().Push(m);
  mService->Send(this);
}

void MPISendEndpoint::SyncLocalQueue(CapacityChangeHandler & cch)
{
  mService->Send(this);
}

MPIRecvEndpoint::MPIRecvEndpoint(RunTimeOperatorActivation * op, 
                                 MPIService * service,
                                 boost::int32_t endpointIndex,
                                 const RecordMetadata& metadata, 
                                 boost::int32_t tag, 
                                 boost::int32_t partition)
  :
  Endpoint(op),
  mService(service),
  mIsSource(false),
  mIndex(-1),
  mPartition(-1),
  mEndpointIndex(endpointIndex),
  mRemotePartition(partition),
  mTag(tag),
  mMetadata(metadata)
{
}

MPIRecvEndpoint::~MPIRecvEndpoint()
{
}

boost::int32_t MPIRecvEndpoint::GetSize() const
{
  return mService->GetSize(this);
}

void MPIRecvEndpoint::Read(MessagePtr& m, CapacityChangeHandler& pch)
{
  // Really need to expose this as a RecvOne from service.
  ASSERT(FALSE);
}

void MPIRecvEndpoint::Write(MessagePtr m, CapacityChangeHandler& pch)
{
  ASSERT(FALSE);
}

void MPIRecvEndpoint::SyncLocalQueue(CapacityChangeHandler & cch)
{
  mService->Recv(this);
}

static boost::mutex sGlobalLock;

std::wstring Port::GetFullName() const
{
  std::wstring result = L"";

  if (mOperator)
  {
    result = L"Operator: " + mOperator->GetName() + L"/";
  }

  result = result + L"Port: " + mName;

  return result;
}

std::string Port::GetNameString() const
{
  std::string s;
  ::WideStringToUTF8(mName, s);
  return s;
}

boost::shared_ptr<Port> PortCollection::operator [] (const std::wstring& name)
{
  if (mPortNameIndex.end() == mPortNameIndex.find(name))
  {
    if (mOperator != NULL)
    {
      std::string msg;
      ::WideStringToUTF8((boost::wformat(L"Port '%1%' of operator '%2%' does not exist") % name % mOperator->GetName()).str(), msg);
      throw std::logic_error(msg);
    }
    else
    {
      std::string msg;
      ::WideStringToUTF8((boost::wformat(L"Port '%1%' does not exist") % name).str(), msg);
      throw std::logic_error(msg);
    }
  }
  return mPortNameIndex.find(name)->second;
}

boost::shared_ptr<Port> PortCollection::operator [] (const std::wstring& name) const
{
  if (mPortNameIndex.end() == mPortNameIndex.find(name))
  {
    if (mOperator != NULL)
    {
      std::string msg;
      ::WideStringToUTF8((boost::wformat(L"Port '%1%' of operator '%2%' does not exist") % name % mOperator->GetName()).str(), msg);
      throw std::logic_error(msg);
    }
    else
    {
      std::string msg;
      ::WideStringToUTF8((boost::wformat(L"Port '%1%' does not exist") % name).str(), msg);
      throw std::logic_error(msg);
    }
  }
  return mPortNameIndex.find(name)->second;
}

bool PortCollection::doesPortExist(const std::wstring& portName) const
{
  return (mPortNameIndex.end() != mPortNameIndex.find(portName));
}

bool PortCollection::doesPortExist(int portIndex) const
{
  return (portIndex >= 0 && portIndex < (int) mPorts.size());
}

Channel::Channel(RunTimeOperatorActivation * sourceOperator, RunTimeOperatorActivation * targetOperator, bool locallyBuffered)
  :
  mSource(NULL),
  mTarget(NULL),
  mBuffering(true)
{
  mSource = new SingleEndpoint(NULL, true, sourceOperator, locallyBuffered);
  mTarget = new SingleEndpoint(NULL, false, targetOperator, locallyBuffered);
  mSource->SetChannel(this);
  mTarget->SetChannel(this);
}  

Channel::~Channel()
{
  delete mSource;
  delete mTarget;
}

void Channel::Init()
{
  mSource->SetChannel(this);
  mSource->SetSource(true);
  mTarget->SetChannel(this);
  mTarget->SetSource(false);
}

void Channel::DumpStatistics()
{
  mSource->DumpStatistics();
  {
    boost::mutex::scoped_lock lk(sGlobalLock);
    std::cout << mQueue.GetNumRead() << "->" << mQueue.GetNumWritten();
  }
  mTarget->DumpStatistics();
  {
    boost::mutex::scoped_lock lk(sGlobalLock);
    std::cout << std::endl;
  }
//   mSpinLock.DumpStatistics();
}

SingleEndpoint::SingleEndpoint(Channel * channel, bool isSource, RunTimeOperatorActivation * op, bool locallyBuffered)
  :
  Endpoint(op, locallyBuffered),
  mChannel(channel),
  mIsSource(isSource),
  mIndex(-1)
{
}

SingleEndpoint::~SingleEndpoint()
{
}

void SingleEndpoint::DumpStatistics()
{
  boost::mutex::scoped_lock lk(sGlobalLock);
  std::cout << "(" << mIndex << "," << mPartition << ")";
}

RunTimeOperator::RunTimeOperator(const std::wstring& name)
  :
  mNext(NULL),
  mPrev(NULL),
  mName(name)
{
}

RunTimeOperator::~RunTimeOperator()
{
}

RunTimeOperatorActivation::RunTimeOperatorActivation(Reactor * reactor, partition_t partition)
  :
  mTicksInOperator(0LL),
  mExecutions(0LL),
  mReactor(reactor),
  mPartition(partition),
  mPartitionIndex(0)
{
}

RunTimeOperatorActivation::~RunTimeOperatorActivation()
{
}

LinuxProcessor::LinuxProcessor(partition_t partition)
  :
  mPartition(partition),
  mDisabled(NULL),
  mReadBitmask(0),
  mWriteBitmask(0),
  mNumRunning(0),
  mNumEnabled(0),
  mStopFlag(false),
  mOperatorReadTicks(0),
  mOperatorReadExecutions(0),
  mOperatorWriteTicks(0),
  mOperatorWriteExecutions(0),
  mTestTicks(0),
  mTestExecutions(0),
  mWaitTicks(0),
  mWaitExecutions(0)
{
  for(std::size_t i=0; i<sizeof(mReadQueue)/sizeof(Endpoint*); i++)
  {
    mReadQueue[i] = NULL;
  }
  for(std::size_t i=0; i<sizeof(mWriteQueue)/sizeof(Endpoint*); i++)
  {
    mWriteQueue[i] = NULL;
  }
}

LinuxProcessor::~LinuxProcessor()
{
//   sGlobalLock.Lock();
//   std::cout << "LinuxProcessor(" << mPartition << ") ";
//   sGlobalLock.Unlock();
//   mLock.DumpStatistics();
}

void LinuxProcessor::Add(Endpoint * ep)
{
  mDisabled = ep->LinkBefore(mDisabled);
  ep->SetPartition(mPartition);
  ep->SetProcessor(this);
}

void LinuxProcessor::Add(Channel * c)
{
  Add(c->GetSource());
  Add(c->GetTarget());
}

void LinuxProcessor::CheckQueueInvariants()
{
  // Validate that mNumEnabled is correct
  boost::int32_t numEnabled (0);
  for(std::size_t i=0; i<sizeof(mReadQueue)/sizeof(Endpoint*); i++)
  {
    if (mReadQueue[i] != NULL)
    {
      Endpoint * iter = mReadQueue[i];
      do
      {
        numEnabled += 1;
        if(i != (std::size_t) iter->GetPriority())
        {
          throw std::runtime_error("Endpoint::GetPriority() incorrect");
        }
        // Read isn't enabled.  Either Channel size or internal buffer size is 0.
        // This is not a safe check because we are not guaranteed to
        // be holding the channel lock.  That means that the channel
        // could be getting modified already but has not been able
        // to change the priority of this endpoint.
//         if (i != GetReadPriority(iter->GetSize()))
//         {
//           throw std::runtime_error("Read Endpoint on incorrect queue");
//         }
        iter = iter->Next();
      } while (iter != mReadQueue[i]);
    }
  }
  for(std::size_t i=0; i<sizeof(mWriteQueue)/sizeof(Endpoint*); i++)
  {
    if (mWriteQueue[i] != NULL)
    {
      Endpoint * iter = mWriteQueue[i];
      do
      {
        numEnabled += 1;
        if(i != (std::size_t) iter->GetPriority())
        {
          throw std::runtime_error("Endpoint::GetPriority() incorrect");
        }
        // This is not a safe check because we are not guaranteed to
        // be holding the channel lock.  That means that the channel
        // could be getting modified already but has not been able
        // to change the priority of this endpoint.
//         if (i != GetWritePriority(iter->GetSize()))
//         {
//           throw std::runtime_error("Write Endpoint on incorrect queue");
//         }
        iter = iter->Next();
      } while (iter != mWriteQueue[i]);
    }
  }

  if(numEnabled != mNumEnabled)
  {
    throw std::runtime_error("numEnabled != mNumEnabled");
  }
}

void LinuxProcessor::DumpQueues(std::wostream& ostr)
{
  mLock.Lock();
  // Print out the state of the queues
  for(std::size_t i=0; i<sizeof(mReadQueue)/sizeof(Endpoint*); i++)
  {
    if (mReadQueue[i] != NULL)
    {
      ostr << L"mReadQueue(" << i << L"):" << std::endl;
      Endpoint * iter = mReadQueue[i];
      do
      {
        ostr << iter->GetOperator()->GetName() << L"::input(" << iter->GetIndex() << L")" << std::endl;
        iter = iter->Next();        
      } while (iter != mReadQueue[i]);
    }
  }
  for(std::size_t i=0; i<sizeof(mWriteQueue)/sizeof(Endpoint*); i++)
  {
    if (mWriteQueue[i] != NULL)
    {
      ostr << L"mWriteQueue(" << i << L"):" << std::endl;
      Endpoint * iter = mWriteQueue[i];
      do
      {
        ostr << iter->GetOperator()->GetName() << L"::output(" << iter->GetIndex() << L")" << std::endl;
        iter = iter->Next();        
      } while (iter != mWriteQueue[i]);
    }
  }
  mLock.Unlock();
}

void LinuxProcessor::DumpStatistics(std::ostream& ostr)
{
  ostr << "\nCounter Partition TotalTicks TotalExecutions";
  ostr << "\n\"OperatorRead\" " << mPartition << " " << this->GetOperatorReadTicks()
       << " " << this->GetOperatorReadExecutions();
  ostr << "\n\"OperatorWrite\" " << mPartition << " " << this->GetOperatorWriteTicks()
       << " " << this->GetOperatorWriteExecutions();
  ostr << "\n\"Testsome\" " << mPartition << " " << this->GetTestTicks()
       << " " << this->GetTestExecutions();
  ostr << "\n\"Waitsome\" " << mPartition << " " << this->GetWaitTicks()
       << " " << this->GetWaitExecutions();
}

void LinuxProcessor::OnRead(boost::int32_t prevCapacity, boost::int32_t newCapacity, Endpoint * source, Endpoint * target)
{
  boost::int32_t prevWritePriority(GetWritePriority(prevCapacity));
  boost::int32_t newWritePriority(GetWritePriority(newCapacity));
  if (prevWritePriority != newWritePriority)
  {
    // We must contact the other end and change up the priority of any pending
    // write.
    // Take locks on the owner of the other end.  Do this in the right order
    LinuxProcessor * sourceProcessor = source->GetProcessor();
    if (sourceProcessor == this)
    {
      mLock.Lock();
    }
    else if(sourceProcessor < this)
    {
      sourceProcessor->mLock.Lock();
      this->mLock.Lock();
    }
    else
    {
      this->mLock.Lock();
      sourceProcessor->mLock.Lock();
    }
    
    // If the source has a pending request, adjust priority if it hasn't
    // already seen the new channel capacity.
    if (sourceProcessor->IsPending(source))
    {
      ASSERT(prevWritePriority == source->GetPriority() || newWritePriority == source->GetPriority());
      if (prevWritePriority == source->GetPriority())
        sourceProcessor->ReprioritizeWriteRequest(source, prevWritePriority, newWritePriority);
    }

    // Clear the target request
    Endpoint * iter = target;
    do
    {
      ClearReadRequest(iter);
      iter = iter->NextRequest();
    } while(iter != target);

    CHECK_QUEUE_INVARIANTS(this);

    this->mLock.Unlock();

    // TODO: I think we can shorten the duration of this lock and release
    // before clearing requests.
    if (sourceProcessor != this)
    {
      CHECK_QUEUE_INVARIANTS(sourceProcessor);
      sourceProcessor->mLock.Unlock();
    }
  }
  else
  {
    // Simply cancel the current read
    mLock.Lock();
    Endpoint * iter = target;
    do
    {
      ClearReadRequest(iter);
      iter = iter->NextRequest();
    } while(iter != target);
    CHECK_QUEUE_INVARIANTS(this);
    mLock.Unlock();
  }
}

void LinuxProcessor::OnRead(MPIRecvEndpoint * target)
{
  ASSERT(target != NULL);
  ASSERT(this == target->GetProcessor());

  // Simply cancel the current read
  mLock.Lock();
  Endpoint * iter = target;
  do
  {
    ClearReadRequest(iter);
    iter = iter->NextRequest();
  } while(iter != target);

  CHECK_QUEUE_INVARIANTS(this);
  mLock.Unlock();
}

void LinuxProcessor::OnReadCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, MPISendEndpoint * source)
{
  ASSERT(prevCapacity >= newCapacity);
  ASSERT(source != NULL);
  ASSERT(this == source->GetProcessor());

  boost::int32_t prevWritePriority(GetWritePriority(prevCapacity));
  boost::int32_t newWritePriority(GetWritePriority(newCapacity));
  if (prevWritePriority != newWritePriority)
  {
    // We must "wake up" the other end
    // Take locks on the owner of the other end.  Do this in the right order
    LinuxProcessor * sourceProcessor = source->GetProcessor();
    if (sourceProcessor != this)
    {
      throw std::runtime_error("sourceProcessor != this");
    }
    mLock.Lock();
    // If the source has a pending request, adjust priority if it hasn't
    // already seen the new channel capacity.
    if (sourceProcessor->IsPending(source))
    {
      // TODO: Understand why the following assertion is not true.
      //ASSERT(prevWritePriority == source->GetPriority() || newWritePriority == source->GetPriority());
      // I have seen the following: prevCapacity=300/prevWritePriority=22
      // newCapacity=100/newWritePriority=24
      // source->GetPriority()=23
      // ANSWER: This is a small bug.  The issue here is that this value is coming from mWireRecords
      // deep inside of the MessagePassingService.  That value is NOT being updated under the lock
      // in the Send method but rather after data is put on the wire.  So what happens is this:
      // There are 200 records on the wire
      // the client has sent info in and then calls GetSize() retrieving 200 and setting priority to 23
      // The message service puts the data on the wire making mWireRecords=300
      // Then the data hits the wire, mWireRecords is increased.
      // The message service receives acks for 200 records.
      // BOOM!
      if (newWritePriority != source->GetPriority())
        sourceProcessor->ReprioritizeWriteRequest(source, source->GetPriority(), newWritePriority);
    }
    mLock.Unlock();
  }
}
void LinuxProcessor::InternalRequestRead(RunTimeOperatorActivation * task, Endpoint * ep)
{
  mLock.Lock();

  Endpoint * iter = ep;
  do
  {
    // Note that we don't have a lock on the channel,
    // so the channel may be getting written to as we
    // speak.  The thing to be careful of is a bit more
    // subtle than you might initially think.  The problem
    // isn't that we settle on a priority that is an underestimate
    // but rather the opposite.  Here is what can happen:
    // As we execute this code, a channel may have been written
    // to and be changing priority.  When we establish our
    // priority by reading below we may be seeing the new priority
    // and may be putting our request at the higher priority rather
    // than the lower one.

    // Put the operator onto the read ready queue.  Read the
    // current size of the channel to understand the (current)
    // priority of the read.
    boost::int32_t idx = GetReadPriority(iter->GetSize());

    EnqueueReadRequest(iter, idx);
    iter = iter->NextRequest();
  } while(iter != ep);
  CHECK_QUEUE_INVARIANTS(this);
  mLock.Unlock();
}

void LinuxProcessor::OnWrite(boost::int32_t prevCapacity, boost::int32_t newCapacity, Endpoint * source, Endpoint * target)
{
  boost::int32_t prevReadPriority(GetReadPriority(prevCapacity));
  boost::int32_t newReadPriority(GetReadPriority(newCapacity));

  if (prevReadPriority != newReadPriority)
  {
    // We must "wake up" the other end
    // Take locks on the owner of the other end.  Do this in the right order
    LinuxProcessor * targetProcessor = target->GetProcessor();
    if (targetProcessor == this)
    {
      mLock.Lock();
    }
    else if(targetProcessor < this)
    {
      targetProcessor->mLock.Lock();
      this->mLock.Lock();
    }
    else
    {
      this->mLock.Lock();
      targetProcessor->mLock.Lock();
    }
    
    // If the target has a pending request, adjust priority
    if (targetProcessor->IsPending(target))
    {
      ASSERT(prevReadPriority == target->GetPriority() || newReadPriority == target->GetPriority());
      if (prevReadPriority == target->GetPriority())
        targetProcessor->ReprioritizeReadRequest(target, prevReadPriority, newReadPriority);
    }

    // Clear the entire source request (which may involve multiple endpoints).
    Endpoint * iter = source;
    do
    {
      ClearWriteRequest(iter);
      iter = iter->NextRequest();
    } while(iter != source);
    CHECK_QUEUE_INVARIANTS(this);
    this->mLock.Unlock();
    if (targetProcessor != this)
    {
      CHECK_QUEUE_INVARIANTS(targetProcessor);
      targetProcessor->mLock.Unlock();
    }
  }
  else
  {
    // Simply cancel the current request (which may be compound).
    mLock.Lock();
    Endpoint * iter = source;
    do
    {
      ClearWriteRequest(iter);
      iter = iter->NextRequest();
    } while(iter != source);
    CHECK_QUEUE_INVARIANTS(this);
    mLock.Unlock();
  }
}
void LinuxProcessor::OnWrite(MPISendEndpoint * source)
{
  ASSERT(source != NULL);
  ASSERT(this == source->GetProcessor());

  mLock.Lock();

  // Simply cancel the current request (which may be compound).
  Endpoint * iter = source;
  do
  {
    ClearWriteRequest(iter);
    iter = iter->NextRequest();
  } while(iter != source);

  CHECK_QUEUE_INVARIANTS(this);
  mLock.Unlock();
}
void LinuxProcessor::OnWriteCompletion(boost::int32_t prevCapacity, boost::int32_t newCapacity, MPIRecvEndpoint * target)
{
  ASSERT(newCapacity >= prevCapacity);
  ASSERT(target != NULL);
  ASSERT(this == target->GetProcessor());

  boost::int32_t prevReadPriority(GetReadPriority(prevCapacity));
  boost::int32_t newReadPriority(GetReadPriority(newCapacity));

  if (prevReadPriority != newReadPriority)
  {
    // We must "wake up" the other end
    // Take locks on the owner of the other end.  Do this in the right order
    LinuxProcessor * targetProcessor = target->GetProcessor();
    if (targetProcessor != this)
    {
      throw std::runtime_error("targetProcessor != this");
    }
    
    // If the target has a pending request, adjust priority
    mLock.Lock();
    if (targetProcessor->IsPending(target))
    {
      //TODO: Understand.  The following assertion appear to not be true.  Make sure this is OK.
      //ASSERT(prevReadPriority == target->GetPriority() || newReadPriority == target->GetPriority());
      if (newReadPriority != target->GetPriority())
        targetProcessor->ReprioritizeReadRequest(target, target->GetPriority(), newReadPriority);
    }
    mLock.Unlock();
  }
}
void LinuxProcessor::InternalRequestWrite(RunTimeOperatorActivation * task, Endpoint * ep)
{
  mLock.Lock();
  Endpoint * iter = ep;
  do
  {
    // Note that we don't have a lock on the channel,
    // so the channel may be getting read from as we
    // speak.  The thing to be careful of is a bit more
    // subtle than you might initially think.  The problem
    // isn't that we settle on a priority that is an underestimate
    // but rather the opposite.  Here is what can happen:
    // As we execute this code, a channel may have been read from
    // and be changing priority.  When we establish our
    // priority by reading below we may be seeing the new priority
    // and may be putting our request at the higher priority rather
    // than the lower one.

    // Put the operator onto the read ready queue.  Read the
    // current size of the channel to understand the (current)
    // priority of the read.
    boost::int32_t idx = GetWritePriority(iter->GetSize());

    EnqueueWriteRequest(iter, idx);
    iter = iter->NextRequest();
  } while(ep != iter);
  CHECK_QUEUE_INVARIANTS(this);
  mLock.Unlock();
}

void LinuxProcessor::Start(const std::vector<RunTimeOperatorActivation*> & ops)
{
  boost::int64_t numWaits(0LL);

  MetraFlowLoggerPtr logger = 
    MetraFlowLoggerManager::GetLogger((boost::format("[DataflowScheduler(%1%)]") % 
                                       mPartition).str());

  // Initialize operators and endpoints
  mIsStarting = true;
  for(std::vector<RunTimeOperatorActivation *>::const_iterator it = ops.begin();
      it != ops.end();
      it++)
  {
    // Start all endpoints.
    for(std::vector<Endpoint *>::const_iterator eit = (*it)->GetInputs().begin();
        eit != (*it)->GetInputs().end();
        eit++)
    {
      (*eit)->Start();
    }

    // Start the operator.
    (*it)->Start();
  }
  mIsStarting = false;

  Endpoint * ep = NULL;

  // Minimum number of iterations for Testsome.  If things
  // start backing up we can increase this value to spend more
  // time pumping the network.
  boost::int32_t minTestsomeIters=1;

  // We will write warnings in the log if memory is dangerously low.
  bool hasMemoryWarningBeenIssued = false;
  boost::uint64_t memoryHighwater = 15;
  boost::uint64_t memoryLowwater = 12;
   
  while(!mStopFlag && (mNumEnabled > 0))
  {
    // Check the amount of available memory.
    MEMORYSTATUSEX statex;
    statex.dwLength = sizeof(MEMORYSTATUSEX);
    ::GlobalMemoryStatusEx(&statex);
    boost::uint64_t remainingMemory = (100LL*statex.ullAvailVirtual)/statex.ullTotalVirtual;

    // Should we log that memory is too low?
    if (!hasMemoryWarningBeenIssued && remainingMemory <= memoryLowwater)
    {
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ParallelPartion]");
        logger->logWarning((boost::format("MetraFlow is in danger of running out of memory: %1% percent left.")
			    % remainingMemory).str());
        hasMemoryWarningBeenIssued = true;
    }

    // Should we log that memory is now ok?
    if (hasMemoryWarningBeenIssued && remainingMemory > memoryHighwater)
    {
      MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ParallelPartion]");
      logger->logInfo((boost::format("MetraFlow available memory is now above: %1% percent.")
			  % remainingMemory).str());
      hasMemoryWarningBeenIssued = false;
    }

    mLock.Lock();

    // Find the highest priority scheduled read by looking
    // at the priority bitmap.
    boost::uint32_t bmsk = mReadBitmask;
    boost::int32_t off;
    unsigned char zf;
#ifdef WIN32
    __asm { bsr eax, dword ptr [bmsk] };
    __asm { setz zf };      
    __asm { mov dword ptr [off], eax }; 
#else
    __asm__ ("bsrl %2, %%eax\n\t"
             "setzb %1\n\t"
             "movl %%eax, %0\n\t" 
             : "=r"(off), "=r"(zf)
             : "r"(bmsk)
             : "%eax");
#endif
    if (!zf && off > 0) 
    {
      ep = mReadQueue[off];
      mLock.Unlock();
      // Don't hold lock while processing (it only protects the queues).  
      // The operator will call back in when it is done reading and when
      // it decides on its next I/O.  We always process reads
      // ahead of writes ("demand driven scheduling").
      ASSERT(ep != NULL);
      RunTimeOperatorActivation * op = ep->GetOperator();
      ASSERT(op != NULL);
//         std::string utf8Name;
//         ::WideStringToUTF8(op->GetName(), utf8Name);
//         logger->logDebug((boost::format("read(%1%,%2%)") % utf8Name % off).str());

      // Danger: stepping on a core/processor (dynamic clock speed changes) and context
      // switching to a different processor can hose these numbers (clock ticks can be different on different
      // cpus).
      boost::uint64_t tick;
      boost::uint64_t tock;
      TIMER_TICK();
      ScheduleOperator(op, ep);
      TIMER_TOCK();
      op->UpdateExecutionStatistics(tock - tick);
      mOperatorReadTicks += (tock-tick);
      mOperatorReadExecutions += 1;
      continue;
    }

    // Lock still held here!
    bmsk = mWriteBitmask;
#ifdef WIN32
    __asm { bsr eax, dword ptr [bmsk] };
    __asm { setz zf };      
    __asm { mov dword ptr [off], eax }; 
#else
    __asm__ ("bsrl %2, %%eax\n\t"
             "setzb %1\n\t"
             "movl %%eax, %0\n\t" 
             : "=r"(off), "=r"(zf)
             : "r"(bmsk)
             : "%eax");
#endif
    if (!zf && off > 0) 
    {
      ep = mWriteQueue[off];
      mLock.Unlock();
      if (off <= 16)
      {
        // The only thing we have available to us is to write to a full channel.
        // This can happen for two reasons.  The first and most important reason
        // is that some other thread or process is running slow and not feeding
        // us quickly enough.  The problem is that we can't just run ahead blindly
        // chewing up memory in this case; we really need to wait or we'll run out
        // memory buffering up stuff waiting for the slow poke.  To get a measure of
        // how much tolerance we have to plow forward, we check available memory (right
        // now since we are 32 bit, we only worry about virtual memory and discount the concern about paging).
        // Note that we do run on some systems with impoverished memory.  In particular for such systems
        // running x64 we get 4GB of virtual and a few MetraFlow processes can swamp physical memory.
        // Therefore our heuristic is based of the minimim of available virtual and 100-memoryload.
        //
        // Note that we are neglecting the 2nd case which is a directed cycle that requires
        // buffering due to uneven data distribution.  The behavior implemented will slow these down,
        // but for the moment we treat these programs as outliers.
        MEMORYSTATUSEX statex;
        statex.dwLength = sizeof(MEMORYSTATUSEX);
        ::GlobalMemoryStatusEx(&statex);
        boost::uint64_t percentAvail = (100LL*statex.ullAvailVirtual)/statex.ullTotalVirtual;
        if (percentAvail + statex.dwMemoryLoad > 100LL)
          percentAvail = 100 - statex.dwMemoryLoad;

        if (percentAvail >= 25)
        {
          ::Sleep(1);
        }
        else if (percentAvail > 20 && percentAvail < 25)
        {
          ::Sleep(25 - boost::uint32_t(percentAvail));
        }
        else if (percentAvail > 15 && percentAvail <= 20)
        {
          ::Sleep(10*(20 - boost::uint32_t(percentAvail)) + 5);
        }
        else if (percentAvail > 10 && percentAvail <= 15)
        {
          ::Sleep(100*(15 - boost::uint32_t(percentAvail)) + 55);
        }
        else if (percentAvail < 10)
        {
          // Sleep and implement finite buffering.  This may cause
          // livelock.
          logger->logWarning((boost::format("Sleeping: percentAvail %1%, max write priority=%2%") % percentAvail % off).str());
          ::Sleep(1000);
          continue;
        }
      }
      ASSERT(ep != NULL);
      RunTimeOperatorActivation * op = ep->GetOperator();
      ASSERT(op != NULL);
      boost::uint64_t tick;
      boost::uint64_t tock;
      TIMER_TICK();      
      ScheduleOperator(op, ep);
      TIMER_TOCK();      
      op->UpdateExecutionStatistics(tock - tick);
      mOperatorWriteTicks += (tock-tick);
      mOperatorWriteExecutions += 1;
      continue;
    }
    mLock.Unlock();

    // Nothing processed, yield so that the outside
    // world gets scheduled.
    numWaits++;
#ifdef WIN32
    ::Sleep(0);
#endif
  }

  for(std::vector<RunTimeOperatorActivation *>::const_iterator it = ops.begin();
      it != ops.end();
      it++)
  {
    // Send completion event to all operators.
    (*it)->Complete();
  }
}

void LinuxProcessor::Stop()
{
  mStopFlag = true;
}

DesignTimePlan::DesignTimePlan()
  : mName(L"main"),
    mIsExpansionInProgress(false)
{
  mPartitioners.insert("class DesignTimeHashPartitioner");
  mPartitioners.insert("class DesignTimeOraclePartitioner");
  mPartitioners.insert("class DesignTimeRoundRobinPartitioner");
  mPartitioners.insert("class DesignTimeBroadcastPartitioner");
  mPartitioners.insert("class DesignTimeRangePartitioner");

  mCollectors.insert("class DesignTimeNondeterministicCollector");
  mCollectors.insert("class DesignTimeSortMergeCollector");
}

DesignTimePlan::~DesignTimePlan()
{
  for(std::list<DesignTimeOperator *>::iterator it = mOperators.begin();
      it != mOperators.end();
      it++)
  {
    delete *it;
  }

  for(std::list<DesignTimeChannel *>::iterator it = mChannels.begin();
      it != mChannels.end();
      it++)
  {
    delete *it;
  }
}

bool DesignTimePlan::IsOperatorAdded(DesignTimeOperator * op)
{
  for(std::list<DesignTimeOperator *>::iterator it = mOperators.begin();
      it != mOperators.end();
      it++)
  {
    if (*it == op)
    {
      return true;
    }
  }
  return false;
}

void DesignTimePlan::CheckOperatorAdded(DesignTimeOperator * op)
{
  bool ret = IsOperatorAdded(op);
  if (!ret)
  {
    std::wstring msg = (boost::wformat(L"Operator '%1%' not added yet") % op->GetName()).str();
    std::string utf8Msg;
    ::WideStringToUTF8(msg, utf8Msg);
    throw std::logic_error(utf8Msg);
  }
}

void DesignTimePlan::CheckOperatorNotAdded(DesignTimeOperator * op)
{
  bool ret = IsOperatorAdded(op);
  if (ret)
  {
    std::wstring msg = (boost::wformat(L"Operator '%1%' already added") % op->GetName()).str();
    std::string utf8Msg;
    ::WideStringToUTF8(msg, utf8Msg);
    throw std::logic_error(utf8Msg);
  }
}

void DesignTimePlan::push_back(DesignTimeOperator * op)
{
  CheckOperatorNotAdded(op);
  mOperators.push_back(op);
}

void DesignTimePlan::push_back(DesignTimeChannel * ch)
{
  CheckOperatorAdded(ch->GetSource()->GetOperator());
  CheckOperatorAdded(ch->GetTarget()->GetOperator());
  if (mPortToChannel.end() != mPortToChannel.find(ch->GetSource()))
  {
    std::wstring msg (L"Cannot create channel connecting port '");
    msg += ch->GetSource()->GetName();
    msg += L"' of operator '";
    msg += ch->GetSource()->GetOperator()->GetName();
    msg += L"' to port '";
    msg += ch->GetTarget()->GetName();
    msg += L"' of operator '";
    msg += ch->GetTarget()->GetOperator()->GetName();
    msg += L"' since there is existing channel connecting port '";
    ch = mPortToChannel.find(ch->GetSource())->second;
    msg += ch->GetSource()->GetName();
    msg += L"' of operator '";
    msg += ch->GetSource()->GetOperator()->GetName();
    msg += L"' to port '";
    msg += ch->GetTarget()->GetName();
    msg += L"' of operator '";
    msg += ch->GetTarget()->GetOperator()->GetName();

    std::string utf8Msg;
    ::WideStringToUTF8(msg, utf8Msg);
    throw std::logic_error(utf8Msg);
  }
  if (mPortToChannel.end() != mPortToChannel.find(ch->GetTarget()))
  {
    std::wstring msg (L"Cannot create channel connecting port '");
    msg += ch->GetSource()->GetName();
    msg += L"' of operator '";
    msg += ch->GetSource()->GetOperator()->GetName();
    msg += L"' to port '";
    msg += ch->GetTarget()->GetName();
    msg += L"' of operator '";
    msg += ch->GetTarget()->GetOperator()->GetName();
    msg += L"' since there is existing channel connecting port '";
    ch = mPortToChannel.find(ch->GetTarget())->second;
    msg += ch->GetSource()->GetName();
    msg += L"' of operator '";
    msg += ch->GetSource()->GetOperator()->GetName();
    msg += L"' to port '";
    msg += ch->GetTarget()->GetName();
    msg += L"' of operator '";
    msg += ch->GetTarget()->GetOperator()->GetName();

    std::string utf8Msg;
    ::WideStringToUTF8(msg, utf8Msg);
    throw std::logic_error(utf8Msg);
  }
  mChannels.push_back(ch);
  mPortToChannel[ch->GetSource()] = ch;
  mPortToChannel[ch->GetTarget()] = ch;
}

void DesignTimePlan::type_check(
                  DesignTimeOperator * op,
                  std::map<DesignTimeOperator*, DesignTimePlan::Color> & color)
{
    // If verbose is on, typecheck flow is written to standard out.
    bool isVerboseOn = (getenv("METRAFLOW_TYPECHECK") != NULL);

    if (color[op] == UNDISCOVERED)
    {
      color[op] = DISCOVERED;
      if ((op)->GetInputPorts().size() > 0)
      {
          // Depth first search.
        for(PortCollection::iterator pit=(op)->GetInputPorts().begin();
            pit != (op)->GetInputPorts().end();
            pit++)
        {
          DesignTimeChannel * ch = channel(*pit);
          if (ch != NULL)
          {
            boost::shared_ptr<Port> source = ch->GetSource();
            DesignTimeOperator * sourceOp = source->GetOperator();

            // Since we assume directed acyclical-graphs currently,
            // an input port should never lead to an operation we
            // are in the process of examining (marked as DISCOVERED
            // but not yet marked as VISITED).
            if (color[sourceOp] == DISCOVERED)
            {
              color[op] = VISITED;
              throw SingleOperatorException(*op, L"A circle has been detected in the graph.  The flow cannot have a circular loop.");
            }

            if (color[sourceOp] == UNDISCOVERED)
            {
              type_check(sourceOp, color);
            }

            if (NULL == (*pit)->GetMetadata() && !(*pit)->IsOptional())
            {
              color [op] = VISITED;
              throw PortHasNoMetadataSourceException(*op, *sourceOp, *(*pit));
            }
          }
          else if (!(*pit)->IsOptional())
          {
            color [op] = VISITED;
            throw PortUnconnectedException(*op, *(*pit), true);
          }
        }
      }

      // All the operations dependencies are type checked so we can type 
      // type check the operation itself.  If an error occurs, consider
      // the operation as visited.
      try
      {
        if (isVerboseOn)
        {
          boost::wformat fmt(L"\nTypecheck Operator: %1%");
          fmt % op->GetName();
          std::string printStr;
          ::WideStringToUTF8(fmt.str(), printStr);
          std::cout << printStr.c_str() << std::endl;
        }

        (op)->type_check();
      }
      catch (std::exception)
      {
        color [op] = VISITED;
        throw;
      }

      // Copy record formats to attached input ports
      for(PortCollection::const_iterator pit=(op)->GetOutputPorts().begin();
          pit != (op)->GetOutputPorts().end();
          pit++)
      {
        if (NULL == (*pit)->GetMetadata() && !(*pit)->IsOptional())
        {
          color [op] = VISITED;
          throw PortHasNoMetadataException(*op, *(*pit));
        }

        if (isVerboseOn)
        {
          boost::wformat fmt(L"    Port: %1%");
          fmt % (*pit)->GetName();
          std::string printStr;
          ::WideStringToUTF8(fmt.str(), printStr);
          std::cout << printStr.c_str() << std::endl;
        }

        DesignTimeChannel * ch = channel(*pit);
        if (ch != NULL)
        {
          boost::shared_ptr<Port> target = ch->GetTarget();
          target->SetMetadata(new RecordMetadata(*((*pit)->GetMetadata())));

          if (isVerboseOn)
          {
             std::wstring field;
             for(int i=0; i<(*pit)->GetMetadata()->GetNumColumns(); i++)
             {
               field = (*pit)->GetMetadata()->GetColumn(i)->GetName();
               boost::wformat fmt(L"        %1%");
               fmt % field;
               std::string printStr;
               ::WideStringToUTF8(fmt.str(), printStr);
               std::cout << printStr.c_str() << std::endl;
             }
          }
        }
        else if (!(*pit)->IsOptional())
        {
          color [op] = VISITED;

          // TODO: ALLAN: should this be removed?
          boost::mutex::scoped_lock lk(sGlobalLock);

          throw PortUnconnectedException(*op, *(*pit), false);
        }
      }

      color [op] = VISITED;
    }
}

void DesignTimePlan::type_check(bool isContinueOnError)
{
  std::map<DesignTimeOperator *, Color> color;

  // Mark all the operation in the plan as undiscovered.
  for(std::list<DesignTimeOperator *>::iterator opit=mOperators.begin();
      opit != mOperators.end();
      opit++)
  {
    color[*opit] = UNDISCOVERED;
  }

  // TODO: Support cyclic graphs (presumably by some kind of Hindley-Milner like
  // type inference algorithm).

  // Check every operation in the plan
  for(std::list<DesignTimeOperator *>::iterator opit=mOperators.begin();
      opit != mOperators.end();
      opit++)
  {
    try
    {
      type_check(*opit, color);
    }
    catch(std::exception)
    {
      // If we are producing annotation of the script, then we will
      // not stop on errors so that we can provide as much annotation
      // as possible.  Otherwise, we rethrow the exception and stop
      // type-checking.
      if (!isContinueOnError)
      {
        throw;
      }
    }
  }
}

void DesignTimePlan::verifyAllPortsConnected()
{
  for(std::list<DesignTimeOperator *>::iterator opit=mOperators.begin();
      opit != mOperators.end();
      opit++)
  {
    DesignTimeOperator *op = *opit;

    for(PortCollection::const_iterator pit=(op)->GetOutputPorts().begin();
        pit != (op)->GetOutputPorts().end();
        pit++)
    {
      DesignTimeChannel * ch = channel(*pit);
      if (ch == NULL && !(*pit)->IsOptional() && !(*pit)->IsCompositeParameter())
      {
        throw PortUnconnectedException(*op, *(*pit), false);
      }
    }

    for(PortCollection::const_iterator pit=(op)->GetInputPorts().begin();
        pit != (op)->GetInputPorts().end();
        pit++)
    {
      DesignTimeChannel * ch = channel(*pit);
      if (ch == NULL && !(*pit)->IsOptional() && !(*pit)->IsCompositeParameter())
      {
        throw PortUnconnectedException(*op, *(*pit), false);
      }
    }
  }
}

void DesignTimePlan::expandComposites(CompositeDictionary &dictionary)
{
  // Check if we have hit a circular reference.
  if (mIsExpansionInProgress)
  {
    throw CircularCompositeReferenceException(mName);
  }

  // Look for all the placeholder composites in the plan.
  DesignTimeComposite* placeholderOp;
  for(std::list<DesignTimeOperator *>::iterator opit=mOperators.begin();
      opit != mOperators.end(); 
      )
  {
    DesignTimeOperator *op = *opit;

    placeholderOp = dynamic_cast<DesignTimeComposite*>(op);

    // Skip if not a DesignTimeComposite
    if (!placeholderOp)
    {
      opit++;
      continue;
    }

    // Find the composite in the dictionary.
    CompositeDefinition* defn = 
          dictionary.getDefinition(placeholderOp->getCompositeDefinitionName());
    ASSERT (defn != NULL);

    // Expand the composite's plan in the dictionary
    // since the composite may refer to other composite.
    // defn->expand(dictionary);

    // A temporary map of that will contain the cloned operators.
    // We will use this map in the cloning of the arrows.
    std::map<std::wstring, DesignTimeOperator*> nameToOpMap;
    std::wstring prefix = placeholderOp->GetName() + L"!";

    cloneCompositeOperators(*placeholderOp, prefix, nameToOpMap, *defn);

    cloneCompositeArrows(prefix, nameToOpMap, *defn);

    wireUpComposite(*placeholderOp, prefix, nameToOpMap, *defn);

    deleteChannelsReferencingOp(placeholderOp);

    // Finally delete the placeholder composite.
    delete placeholderOp;
    opit = mOperators.erase(opit);
  }

  // We are done expanding this plan
  mIsExpansionInProgress = false;
}

void DesignTimePlan::countDynamicParameterReferences(
                        PortCollection& ports,
                        bool isInput,
                        const CompositeDefinition& defn,
                        std::map<std::wstring, int> &countMap)
{
  std::wstring compositeOpName;

  // Iterate thru the placeholder ports
  // looking for instances of dynamic range parameters.
  
  for(PortCollection::iterator it=ports.begin(); it != ports.end(); it++)
  {
    boost::shared_ptr<Port> port = *it;

    if (defn.isInstanceOfRangeParameter(port->GetName(), isInput, 
                                        compositeOpName))
    {
      int count = 0;
      if (countMap.find(compositeOpName) != countMap.end())
      {
        count = countMap.find(compositeOpName)->second;
      }
      count++;
      countMap[compositeOpName] = count;
    }
  }
}

void DesignTimePlan::cloneCompositeOperators(
                       DesignTimeComposite& placeholderOp, 
                       std::wstring prefix,
                       std::map<std::wstring, DesignTimeOperator*> &nameToOpMap,
                       const CompositeDefinition& defn)
{
  // We need to count the dynamic input/output ports that were
  // connected to the placeholder.  These dymanic parameter ports
  // connect to operators in the composite. We need to provide these
  // additional port counts when we clone the operators in 
  // the composite.  The operator in the composite does not have
  // these additional ports since it is use-dependent.
 
  // Map of composite operator name to count of dynamic inputs/outputs
  std::map<std::wstring, int> extraInputs;
  std::map<std::wstring, int> extraOutputs;

  countDynamicParameterReferences(placeholderOp.GetInputPorts(),
                                  true, defn, extraInputs);
  countDynamicParameterReferences(placeholderOp.GetOutputPorts(),
                                  false, defn, extraOutputs);

  // Clone the composite operators
  DesignTimePlan& compositePlan = defn.getDesignTimePlan();

  for(std::list<DesignTimeOperator *>::iterator 
      opit=compositePlan.mOperators.begin();
      opit != compositePlan.mOperators.end();
      opit++)
  {
    DesignTimeOperator *op = *opit;
    std::wstring opName = op->GetName();

    // See if the cloned operator will need additional input/outputs
    // due to dynamic parameters. 
    int moreInputs = 0;
    int moreOutputs = 0;
    
    if (extraInputs.find(opName) != extraInputs.end())
    {
      moreInputs = extraInputs.find(opName)->second;
    }

    if (extraOutputs.find(opName) != extraOutputs.end())
    {
      moreOutputs = extraOutputs.find(opName)->second;
    }

    
    // Clone the operator.  The clone method also applies
    // any pending arguments to the clone.
    DesignTimeOperator *clone = op->clone(prefix + opName,
                                          placeholderOp.getArgs(),
                                          moreInputs, moreOutputs);
    push_back(clone);
    nameToOpMap[clone->GetName()] = clone;
  }
}
  
void DesignTimePlan::cloneCompositeArrows(
                       std::wstring prefix,
                       std::map<std::wstring, DesignTimeOperator*> &nameToOpMap,
                       const CompositeDefinition& defn)
{
  DesignTimePlan& compositePlan = defn.getDesignTimePlan();

  for(std::list<DesignTimeChannel *>::iterator 
      it = compositePlan.mChannels.begin();
      it != compositePlan.mChannels.end();
      it++)
  {
    DesignTimeChannel *ch = *it;
    // Given that this arrow is of the form: op1/"input" -> op2/"output"
    // The new arrow is of the form: prefix!op1/"input" -> prefix!op2/"output"
    // We need to find: prefix!op1

    // Get the operator source of the old arrow
    boost::shared_ptr<Port>sourcePort = ch->GetSource();
    DesignTimeOperator *sourceOp = sourcePort->GetOperator();

    // Get the operator source for the new arrow
    DesignTimeOperator *newSourceOp = nameToOpMap[prefix+sourceOp->GetName()];

    // Get the port source for the new arrow
    std::wstring sourcePortName = sourcePort->GetName();
    boost::shared_ptr<Port> newSourcePort 
                                = newSourceOp->getOutputPort(sourcePortName);
    ASSERT(newSourcePort != NULL);

    // Get the operator target of the old arrow
    boost::shared_ptr<Port>targetPort = ch->GetTarget();
    DesignTimeOperator *targetOp = targetPort->GetOperator();

    // Get the operator target for the new arrow
    DesignTimeOperator *newTargetOp = nameToOpMap[prefix+targetOp->GetName()];

    // Get the port target for the new arrow
    std::wstring targetPortName = targetPort->GetName();
    boost::shared_ptr<Port> newTargetPort 
                                = newTargetOp->getInputPort(targetPortName);
    ASSERT(newTargetPort != NULL);

    DesignTimeChannel* newCh = new DesignTimeChannel(
                                               newSourcePort,
                                               newTargetPort,
                                               ch->GetLocallyBuffered());
    push_back(newCh);
  }
}

void DesignTimePlan::wireUpComposite(
                       DesignTimeComposite& placeholderOp, 
                       std::wstring prefix,
                       std::map<std::wstring, DesignTimeOperator*> &nameToOpMap,
                       CompositeDefinition& defn)
{
  // Iterate thru the placeholder composite op's inputs.
  for(PortCollection::iterator pit=placeholderOp.GetInputPorts().begin();
      pit != placeholderOp.GetInputPorts().end();
      pit++)
  {
    DesignTimeChannel * ch = channel(*pit);
    if (ch != NULL)
    {
      // The source will be re-connected to the expanded sub-graph.
      boost::shared_ptr<Port>sourcePort = ch->GetSource();

      // The target port will be replace with a sub-graph port.
      boost::shared_ptr<Port>targetPort = ch->GetTarget();
      std::wstring targetPortName = targetPort->GetName();

      // Erase both of these ports from the mPortToChannel map.
      // When we add the new arrow, we will have two new entries
      mPortToChannel.erase(sourcePort);
      mPortToChannel.erase(targetPort);

      // The target port name is found by taking the placeholder
      // port name and looking this up in the definition.
      std::wstring newTargetOpName;
      std::wstring newPortName;
      defn.getInputPortParam(targetPortName,
                             &(placeholderOp.GetInputPorts()),
                             newTargetOpName, newPortName);

      DesignTimeOperator *newTargetOp = nameToOpMap[prefix+newTargetOpName];

      boost::shared_ptr<Port>newTargetPort = 
                                    newTargetOp->getInputPort(newPortName);
      if (newTargetPort == NULL)
      {
        throw CompositeUndefPortException(placeholderOp, **pit, newPortName);
      }

      DesignTimeChannel* newCh = new DesignTimeChannel(
                                               sourcePort,
                                               newTargetPort,
                                               ch->GetLocallyBuffered());
      push_back(newCh);
    }
  }

  for(PortCollection::iterator pit=placeholderOp.GetOutputPorts().begin();
      pit != placeholderOp.GetOutputPorts().end();
      pit++)
  {
    DesignTimeChannel * ch = channel(*pit);
    if (ch != NULL)
    {
      // The target will be re-connected to the expanded sub-graph.
      boost::shared_ptr<Port>targetPort = ch->GetTarget();

      // The source port will be replace with a sub-graph port.
      boost::shared_ptr<Port>sourcePort = ch->GetSource();
      std::wstring sourcePortName = sourcePort->GetName();

      // Erase both of these ports from the mPortToChannel map.
      // When we add the new arrow, we will have two new entries
      mPortToChannel.erase(sourcePort);
      mPortToChannel.erase(targetPort);

      // The source port name is found by taking the placeholder
      // port name and looking this up in the definition.
      std::wstring newSourceOpName;
      std::wstring newPortName;
      defn.getOutputPortParam(sourcePortName, newSourceOpName, newPortName);

      DesignTimeOperator *newSourceOp = nameToOpMap[prefix+newSourceOpName];

      boost::shared_ptr<Port>newSourcePort = 
                                    newSourceOp->getOutputPort(newPortName);
      if (newSourcePort == 0)
      {
        throw CompositeUndefPortException(placeholderOp, **pit, newPortName);
      }

      DesignTimeChannel* newCh = new DesignTimeChannel(
                                               newSourcePort,
                                               targetPort,
                                               ch->GetLocallyBuffered());

      // Record the relationship between the placeholder output port
      // and actual output port.
      mPlaceholderOutputMap[placeholderOp.GetName() + L"(\"" + 
                            sourcePort->GetName()+ L"\")"] = newSourcePort;

      push_back(newCh);
    }
  }
}

void DesignTimePlan::deleteChannelsReferencingOp(const DesignTimeOperator* op)
{
  for(std::list<DesignTimeChannel *>::iterator 
      it = mChannels.begin();
      it != mChannels.end(); )
  {
    DesignTimeChannel *ch = *it;
    if (ch->isReferencing(op))
    {
      it = mChannels.erase(it);
      delete ch;
    }
    else
    {
      it++;
    }
  }
}

// TODO: This is not right to have hard coded classes.  This should be 
// done via RTTI, polymorphism or methods in the operator interface.
bool DesignTimePlan::isPartitioner(DesignTimeOperator * op)
{
  const char * opType = typeid(*op).name();
  return mPartitioners.find(opType) != mPartitioners.end();
}

// TODO: This is not right to have hard coded classes.  This should be 
// done via RTTI, polymorphism or methods in the operator interface.
bool DesignTimePlan::isCollector(DesignTimeOperator * op)
{
  const char * opType = typeid(*op).name();
  return mCollectors.find(opType) != mCollectors.end();
}

void DesignTimePlan::add_partition_lists(const std::map<std::wstring, std::vector<boost::int32_t> >& partitionLists)
{
  mPartitionListDefinitions = partitionLists;
}

void DesignTimePlan::code_generate(ParallelPlan& parallelPlan)
{
  std::map<DesignTimeOperator *, operator_set_t> mOpToParallelOp;
  for(std::list<DesignTimeOperator *>::iterator it = mOperators.begin();
      it != mOperators.end();
      it++)
  {
    try
    {
      mOpToParallelOp[*it] = parallelPlan.AddOperator(*it, mPartitionListDefinitions);
    }
    catch(...)
    {
      throw SingleOperatorException(*(*it), L"An unexpected error occurred generating run time code for this operator.");
    }
  }

  for(std::list<DesignTimeChannel *>::iterator it = mChannels.begin();
      it != mChannels.end();
      it++)
  {
    DesignTimeOperator *source = (*it)->GetSource()->GetOperator();
    DesignTimeOperator *target = (*it)->GetTarget()->GetOperator();

    if (isPartitioner(source) || isCollector(target))
    {
      if (source->GetMode() == DesignTimeOperator::SEQUENTIAL)
      {
        parallelPlan.ConnectSequentialBroadcast(mOpToParallelOp[source], 
                                                mOpToParallelOp[target], 
                                                target->GetInputPorts().index_of((*it)->GetTarget()),
                                                (*it)->GetLocallyBuffered(),
                                                *(*it)->GetTarget()->GetMetadata());
      }
      else if (target->GetMode() == DesignTimeOperator::SEQUENTIAL)
      {
        parallelPlan.ConnectSequentialCollect(mOpToParallelOp[source], 
                                              mOpToParallelOp[target], 
                                              source->GetOutputPorts().index_of((*it)->GetSource()),
                                              (*it)->GetLocallyBuffered(),
                                              *(*it)->GetTarget()->GetMetadata());
      }
      else
      {
        if (!isCollector(target))
          throw ParallelPartitionerConnectException(*source, *target);

        if (!isPartitioner(source))
          throw ParallelCollectorConnectException(*source, *target);

        parallelPlan.ConnectCrossbar(mOpToParallelOp[source], 
                                     mOpToParallelOp[target], 
                                     (*it)->GetLocallyBuffered(),
                                     *(*it)->GetTarget()->GetMetadata());
      }
    }
    else
    {
      if (parallelPlan.GetParallelism() > 1 &&
          source->GetMode() == DesignTimeOperator::SEQUENTIAL &&
          target->GetMode() == DesignTimeOperator::PARALLEL)
      {
        throw SeqToParallelConnectException(*source, *target);
      }
      else if(parallelPlan.GetParallelism() > 1 &&
              source->GetMode() == DesignTimeOperator::PARALLEL &&
              target->GetMode() == DesignTimeOperator::SEQUENTIAL)
      {
        throw ParallelToSeqConnectException(*source, *target);
      }
      else if(parallelPlan.GetParallelism() > 1 &&
              source->GetPartitionConstraint() != target->GetPartitionConstraint())
      {
        throw ParallelToSeqConnectException(*source, *target);
      }
      parallelPlan.ConnectStraightLine(mOpToParallelOp[source], 
                                       source->GetOutputPorts().index_of((*it)->GetSource()), 
                                       mOpToParallelOp[target], 
                                       target->GetInputPorts().index_of((*it)->GetTarget()),
                                       (*it)->GetLocallyBuffered(),
                                       target->GetInputPorts().size() > 1 ? true : false, 
                                       *(*it)->GetTarget()->GetMetadata());
    }
  }
}

void DesignTimePlan::setName(const std::wstring &name)
{
  mName = name;
}

std::wstring DesignTimePlan::getName() const
{
  return mName;
}

bool DesignTimeChannel::isReferencing(const DesignTimeOperator *op)
{
  if (GetTarget()->GetOperator() == op ||
      GetSource()->GetOperator() == op)
  {
    return true;
  }

  return false;
}

std::string DesignTimePlan::dump() const
{
  std::stringstream out;

  out << "DesignTimePlan: \n";

  for(std::list<DesignTimeOperator *>::const_iterator it = mOperators.begin();
      it != mOperators.end();
      it++)
  {
    DesignTimeOperator *op = *it;
    out << op->dump() << "\n";
    op->dump();
  }

  return out.str();
}

DesignTimeOperator::~DesignTimeOperator()
{
  for(std::vector<OperatorArg *>::iterator 
      it = mPendingArgs.begin();
      it != mPendingArgs.end();
      it++)
  {
    delete *it;
  }
}

void DesignTimeOperator::addPendingArg(OperatorArg *arg)
{
  mPendingArgs.push_back(arg);
}

void DesignTimeOperator::handleModeArg(const OperatorArg &arg)
{
  if (!arg.is(L"mode", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    return;
  }

  std::wstring value = arg.getStringValue();

  if (!boost::algorithm::iequals(L"\"sequential\"", value.c_str()) && 
      !boost::algorithm::iequals(L"\"parallel\"", value.c_str()))
  {
    throw DataflowInvalidArgumentValueException(
                arg.getValueLine(),
                arg.getValueColumn(),
                arg.getFilename(),
                GetName(),
                L"mode",
                value,
                L"Expected \"sequential\" or \"parallel\"");
  }

  if (boost::algorithm::iequals(L"\"sequential\"", value.c_str()))
  {
    SetMode(DesignTimeOperator::SEQUENTIAL);
  }
}

void DesignTimeOperator::handlePartitionConstraintArg(const OperatorArg &arg)
{
  if (!arg.is(L"partitionConstraint", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    return;
  }
  SetPartitionConstraint(arg.getStringValue().substr(1, arg.getStringValue().size()-2));
}

void DesignTimeOperator::handleUnrecognizedArg(const OperatorArg &arg)
{
  throw DataflowInvalidArgumentException(
                arg.getValueLine(),
                arg.getValueColumn(),
                arg.getFilename(),
                GetName(),
                arg.getName());
}

void DesignTimeOperator::handleCommonArg(const OperatorArg &arg)
{
  if (arg.is(L"mode", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    handleModeArg(arg);
  }
  else if (arg.is(L"partitionConstraint", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    handlePartitionConstraintArg(arg);
  }
  else
  {
    handleUnrecognizedArg(arg);
  }
}

void DesignTimeOperator::clonePendingArgs(
                          DesignTimeOperator& clonedOp) const
{
  for (std::vector<OperatorArg*>::const_iterator 
       it = mPendingArgs.begin(); 
       it != mPendingArgs.end(); it++)
  {
    OperatorArg* clonedArg = new OperatorArg(*(*it));
    clonedOp.addPendingArg(clonedArg);
  }
}

void DesignTimeOperator::applyPendingArgs(
                          std::vector<OperatorArg *> &placeholderVars)
{
  for (std::vector<OperatorArg*>::const_iterator 
       it = mPendingArgs.begin(); 
       it != mPendingArgs.end(); it++)
  {
    handleUnresolvedArg(*(*it), placeholderVars);
  }
}

void DesignTimeOperator::handleUnresolvedArg(
                                    const OperatorArg& arg,
                                    std::vector<OperatorArg *> &placeholderVars)
{
  ArgEnvironment* argEnvironment = ArgEnvironment::getActiveEnvironment();
  bool found = false;

  // Before applying the argument, we have to resolve any
  // referenced variables in the argument.  We first check if the
  // variable is defined in passed in placeholderVars.  If not,
  // we try to resolve using environmental variables.

  // Note that is possible for a single pending argument to lead
  // to multiple arguments to handle.  See OPERATOR_ARG_TYPE_VARIABLE
  // case below.

  switch (arg.getType())
  {
    case OPERATOR_ARG_TYPE_STRING:
      // Example: s:select[baseQuery="SELECT $a"]

      if (!arg.isThereAnEmbeddedArg())
      {
        handleArg(arg);
      }
      else
      {
        const std::vector<std::wstring> embeddedArgs = arg.getEmbeddedArgs();
        OperatorArg tailoredArg(arg);
        
        // For each embedded argument, attempt to find
        // a replacement for it.

        for (unsigned int i=0; i<embeddedArgs.size(); i++)
        {
          std::wstring replacementValue = argEnvironment->getValue(
                                                  embeddedArgs[i],
                                                  placeholderVars);
          tailoredArg.replaceEmbeddedArg(embeddedArgs[i], replacementValue);
        }

        handleArg(tailoredArg);
      }
      break;

    case OPERATOR_ARG_TYPE_VARIABLE:
      // Example: s:select[mode=$b]
      
      // Loop through the placeholder variables looking for the
      // parameter.  It may occur more than once. If it does
      // we will handle the argument multiple times!
      for (std::vector<OperatorArg*>::iterator i=placeholderVars.begin();
           i != placeholderVars.end(); i++)
      {
        OperatorArg* placeholderDefinedArg = *i;
 
        if (placeholderDefinedArg->getName().compare(arg.getName()) == 0)
        {
          // Before handling the argument, we need the name of the
          // argument to match the true operator argument name.
          // For example, if this operator was specified as
          // "print[numToPrint=@myCompArg]" and arg's name is "myCompArg",
          // then we must handle this argument, but change the name
          // to "numToPrint" -- this is what the operator understands.
          OperatorArg tailoredArg(*placeholderDefinedArg);
            tailoredArg.setName(arg.getStringValue());
            handleArg(tailoredArg);
            found = true;
        }
      }

      if (!found)
      {
        // Unfortunately, the placeholder for the composite
        // didn't define the argument.  We need to now check
        // our environment for the value to use.  We want to form
        // an OperatorArg whose type matches the definition.

        OperatorArg* newArg = argEnvironment->getValueAsOperatorArg(
                                                            arg.getName(),
                                                            arg.getVarType());
        if (newArg != NULL)
        {
          newArg->setName(arg.getStringValue());
          handleArg(*newArg);
          delete (newArg);
          return;
        }
      }
      break;

    default:
      handleArg(arg);
  }
}

std::string DesignTimeOperator::GetNameString() const
{
  std::string opName;
  ::WideStringToUTF8(mName, opName);
  return opName;
}

void DesignTimeOperator::handleUnresolvedArg(const OperatorArg& arg)
{
  std::vector<OperatorArg *> emptyVarList;
  handleUnresolvedArg(arg, emptyVarList);
}

std::string DesignTimeOperator::dump() const
{
  std::stringstream out;

  std::string name;
  ::WideStringToUTF8(GetName(), name);
  out << "Operator: " << name << "\n";

  for(PortCollection::const_iterator pit=GetInputPorts().begin();
      pit != GetInputPorts().end();
      pit++)
  {
    boost::shared_ptr<Port> port = *pit;

    std::string name;
    ::WideStringToUTF8(port->GetName(), name);
    out << "  Input: " << name << "\n";
  }

  for(PortCollection::const_iterator pit=GetOutputPorts().begin();
      pit != GetOutputPorts().end();
      pit++)
  {
    boost::shared_ptr<Port> port = *pit;

    std::string name;
    ::WideStringToUTF8(port->GetName(), name);
    out << "  Output: " << name << "\n";
  }

  return out.str();
}

void DesignTimeOperator::CheckMetadataSameType(boost::int32_t portA, boost::int32_t portB) const
{
  if (!mInputPorts[portA]->GetMetadata()->LogicalEquals(*mInputPorts[portB]->GetMetadata()))
    throw RecordTypeMismatchException(*this, *mInputPorts[portA], *mInputPorts[portB]);
}

void DesignTimeOperator::CheckSortKeys(boost::int32_t portA, const std::vector<DesignTimeSortKey>& sortKeys) const
{
  const RecordMetadata * input = mInputPorts[portA]->GetMetadata();
  for(std::vector<DesignTimeSortKey>::const_iterator it = sortKeys.begin();
      it != sortKeys.end();
      ++it)
  {
    if(!input->HasColumn(it->GetSortKeyName()))
    {
      throw MissingFieldException(*this, *mInputPorts[portA], it->GetSortKeyName());
    }
    if (!mInputPorts[portA]->GetMetadata()->GetColumn(it->GetSortKeyName())->IsSortable())
    {
      throw std::runtime_error("Unsupported data type for sort key.  Currently only BOOLEAN, DATETIME, INTEGER and BIGINT can be used.");
    }
  }
}

void DesignTimePlan::describeDatatypeFlow(std::wostream& output) const
{
  std::wstring stepName = L"";

  // We prefix the operations with the step the operator
  // belongs to.  We use no name for the main step.
  if (mName.compare(L"main") != 0)
  {
    stepName = mName + L":";;
  }

  std::map<std::wstring, std::wstring> portDataMap;

  // Iterate through all the arrows in the plan, reporting datatypes
  for(std::list<DesignTimeChannel *>::const_iterator it = mChannels.begin();
      it != mChannels.end();
      it++)
  {
    DesignTimeOperator* op = (*it)->GetSource()->GetOperator();
    if (!op)
    {
      continue;
    }

    const boost::shared_ptr<Port> port = (*it)->GetSource();
    if (!port)
    {
      continue;
    }
    
    std::wstring portName = stepName + op->GetName() + L"(\"" + 
                           port->GetName() + L"\")";
    portDataMap[portName] = port->GetMetadata()->getDescription();
  }

  // Add to our results, all the composite placeholder output dataflows.
  // Keep in mind that the composite placeholder is removed and replaced
  // with the sub-graph. So these dataflows are really conceptual.
  for(std::map<std::wstring, boost::shared_ptr<Port>>::const_iterator 
      it = mPlaceholderOutputMap.begin();
      it != mPlaceholderOutputMap.end();
      it++)
  {
    const boost::shared_ptr<Port> port = (*it).second;
    
    portDataMap[stepName + (*it).first] = port->GetMetadata()->getDescription();
  }

  // Write the our results to standard output
  for (std::map<std::wstring, std::wstring>::const_iterator 
        it = portDataMap.begin(); it != portDataMap.end(); it++)
  {
    output << (*it).first << L"\n" << (*it).second << L"\n" << std::endl;
  }
}

// This class allows threads within a domain to communicate about 
// their completion status.  The model is that the ParallelDomain 
// starts the ParallelPartition threads and passes them a shared
// ParallelPartitionCompletions structure.  The ParallelDomain uses the condition
// variable to wait on ParallelPartitions to record completion information
// and notify.  When the ParallelDomain sees an error, it tells all of the 
// ParallelPartitions to shut down (in the current implementation this means
// that they should just stop scheduling).
class ParallelPartitionCompletions : private boost::noncopyable
{
public:
  boost::timed_mutex guard;
  boost::condition condvar;
  std::map<ParallelPartition*, boost::int32_t> exitcodes;
  std::map<ParallelPartition*, std::string> messages;
};

// ParallelPlan::ParallelPlan(boost::int32_t parallelism, bool multipleDomains)
//   :
//   mParallelism(parallelism),
//   mTag(0)
// {
//   if (multipleDomains)
//   {
//     for(int i=0; i<parallelism; i++)
//     {
//       mDomains.push_back(boost::shared_ptr<ParallelDomain>(new ParallelDomain(i,i)));
//     }
//   }
//   else
//   {
//     mDomains.push_back(boost::shared_ptr<ParallelDomain>(new ParallelDomain(0, parallelism-1)));
//   }
// }

// ParallelPlan::~ParallelPlan()
// {
//   for(std::size_t i=0; i<mOperatorSets.size(); i++)
//   {
//     for(DomainPartitionMap::iterator it = mOperatorSets[i]->begin();
//         it != mOperatorSets[i]->end();
//         it++)
//     {
//       delete it->second;
//     }
//     delete mOperatorSets[i];
//   }
// }

// // Channel * ParallelPlan::GetOutputChannel(operator_set_t upOp, port_t upPort, partition_t upPart)
// // {
// //   RunTimeOperator * upstream = mOperatorSets[upOp][upPart];
// //   return reinterpret_cast<SingleEndpoint *>(upstream->GetOutput(upPort))->GetChannel();
// // }

// operator_set_t ParallelPlan::AddOperator(DesignTimeOperator * op)
// {
//   DomainPartitionMap * parallelOps = new DomainPartitionMap();

//   for(std::vector<boost::shared_ptr<ParallelDomain> >::iterator it = mDomains.begin();
//       it != mDomains.end(); 
//       it++)
//   {
//     parallelOps->insert(std::pair<ParallelDomain*,PartitionOperatorMap*>(it->get(), new PartitionOperatorMap()));
//     (*it)->AddOperator(op, *parallelOps->find(it->get())->second, mParallelism);
//   }  
//   mOperatorSets.push_back(parallelOps);
//   return mOperatorSets.size() - 1;
// }

// void ParallelPlan::ConnectStraightLine(operator_set_t upstream, boost::int32_t outputPort,
//                                        operator_set_t downstream, boost::int32_t inputPort,
//                                        bool locallyBuffered, const RecordMetadata & metadata)
// {
//   for (DomainPartitionMap::const_iterator upstreamIt = mOperatorSets[upstream]->begin();
//        upstreamIt != mOperatorSets[upstream]->end();
//        upstreamIt++)
//   {
//     DomainPartitionMap::const_iterator downstreamIt = mOperatorSets[downstream]->find(upstreamIt->first);
//     ConnectStraightLine(upstreamIt->first,
//                         *upstreamIt->second, outputPort, 
//                         *downstreamIt->second, inputPort,
//                         locallyBuffered, metadata);
//   }
// }

// void ParallelPlan::ConnectStraightLine(ParallelDomain * domain,
//                                        const PartitionOperatorMap& upstream, boost::int32_t outputPort,
//                                        const PartitionOperatorMap& downstream, boost::int32_t inputPort,
//                                        bool locallyBuffered, const RecordMetadata & metadata)
// {
//   ASSERT (upstream.size() == downstream.size());
//   for(PartitionOperatorMap::const_iterator upstreamIt = upstream.begin();
//     upstreamIt != upstream.end();
//     upstreamIt++)
//   {
//     PartitionOperatorMap::const_iterator downstreamIt = downstream.find(upstreamIt->first);
//     ASSERT(downstreamIt != downstream.end());
//     domain->Connect(upstreamIt->second, outputPort, downstreamIt->second, inputPort, locallyBuffered);
//   }
// }

// void ParallelPlan::ConnectCrossbar(operator_set_t upstream,
//                                    operator_set_t downstream,
//                                    bool locallyBuffered,
//                                    const RecordMetadata & metadata)
// {
//   for (DomainPartitionMap::const_iterator upstreamIt = mOperatorSets[upstream]->begin();
//        upstreamIt != mOperatorSets[upstream]->end();
//        upstreamIt++)
//   {
//     for(DomainPartitionMap::const_iterator downstreamIt = mOperatorSets[downstream]->begin();
//         downstreamIt != mOperatorSets[downstream]->end();
//         downstreamIt++)
//     {
//       ConnectCrossbar(upstreamIt->first, *upstreamIt->second, 
//                       downstreamIt->first, *downstreamIt->second,
//                       locallyBuffered, metadata);
//     }
//   }
// }

// void ParallelPlan::ConnectCrossbar(ParallelDomain * upstreamDomain,
//                                    const PartitionOperatorMap& upstream,
//                                    ParallelDomain * downstreamDomain,
//                                    const PartitionOperatorMap& downstream,
//                                    bool locallyBuffered,
//                                    const RecordMetadata & metadata)
// {
//   for(PartitionOperatorMap::const_iterator downstreamIt = downstream.begin();
//     downstreamIt != downstream.end();
//     downstreamIt++)
//   {
//     for(PartitionOperatorMap::const_iterator upstreamIt = upstream.begin();
//         upstreamIt != upstream.end();
//         upstreamIt++)
//     {
//       // Intra domain connection.  
//       if (upstreamDomain == downstreamDomain)
//       {
//         upstreamDomain->Connect(
//           upstreamIt->second, downstreamIt->first->GetPartition(),
//           downstreamIt->second, upstreamIt->first->GetPartition(), locallyBuffered);
//       }
//       else
//       {
//         // Inter domain connection.  
//         upstreamDomain->ConnectRemoteWrite(upstreamIt->second, downstreamIt->first->GetPartition(),
//                                            metadata, downstreamIt->first->GetPartition(), mTag);
//         downstreamDomain->ConnectRemoteRead(downstreamIt->second, upstreamIt->first->GetPartition(),
//                                            metadata, upstreamIt->first->GetPartition(), mTag);
//         mTag += 1;
//       }
//     }
//   }
// }

// void ParallelPlan::ConnectSequentialBroadcast(operator_set_t upstream,
//                                               operator_set_t downstream,
//                                               port_t inputPort,
//                                               bool locallyBuffered,
//                                               const RecordMetadata & metadata)
// {
//   std::size_t upstreamOps = 0;

//   for (DomainPartitionMap::const_iterator upstreamIt = mOperatorSets[upstream]->begin();
//        upstreamIt != mOperatorSets[upstream]->end();
//        upstreamIt++)
//   {
//     upstreamOps += upstreamIt->second->size();

//     for(DomainPartitionMap::const_iterator downstreamIt = mOperatorSets[downstream]->begin();
//         downstreamIt != mOperatorSets[downstream]->end();
//         downstreamIt++)
//     {
//       ConnectSequentialBroadcast(upstreamIt->first, *upstreamIt->second, 
//                                  downstreamIt->first, *downstreamIt->second,
//                                  inputPort, locallyBuffered, metadata);
//     }
//   }

//   ASSERT(upstreamOps == 1);
// }

// void ParallelPlan::ConnectSequentialBroadcast(ParallelDomain * upstreamDomain,
//                                               const PartitionOperatorMap& upstream,
//                                               ParallelDomain * downstreamDomain,
//                                               const PartitionOperatorMap& downstream,
//                                               port_t inputPort,
//                                               bool locallyBuffered,
//                                               const RecordMetadata & metadata)
// {
//   for(PartitionOperatorMap::const_iterator downstreamIt = downstream.begin();
//       downstreamIt != downstream.end();
//       downstreamIt++)
//   {
//     for(PartitionOperatorMap::const_iterator upstreamIt = upstream.begin();
//         upstreamIt != upstream.end();
//         upstreamIt++)
//     {
//       // Intra domain connection.  
//       if (upstreamDomain == downstreamDomain)
//       {
//         upstreamDomain->Connect(
//           upstreamIt->second, downstreamIt->first->GetPartition(),
//           downstreamIt->second, inputPort, locallyBuffered);
//       }
//       else
//       {
//         // Inter domain connection.  
//         upstreamDomain->ConnectRemoteWrite(upstreamIt->second, downstreamIt->first->GetPartition(),
//                                            metadata, downstreamIt->first->GetPartition(), mTag);
//         downstreamDomain->ConnectRemoteRead(downstreamIt->second, inputPort,
//                                             metadata, upstreamIt->first->GetPartition(), mTag);
//         mTag += 1;
//       }
//     }
//   }
// }

// void ParallelPlan::ConnectSequentialCollect(operator_set_t upstream,
//                                             operator_set_t downstream,
//                                             port_t outputPort,
//                                             bool locallyBuffered,
//                                             const RecordMetadata & metadata)
// {
//   for (DomainPartitionMap::const_iterator upstreamIt = mOperatorSets[upstream]->begin();
//        upstreamIt != mOperatorSets[upstream]->end();
//        upstreamIt++)
//   {
//     std::size_t downstreamOps = 0;

//     for(DomainPartitionMap::const_iterator downstreamIt = mOperatorSets[downstream]->begin();
//         downstreamIt != mOperatorSets[downstream]->end();
//         downstreamIt++)
//     {
//       downstreamOps += downstreamIt->second->size();
//       ConnectSequentialCollect(upstreamIt->first, *upstreamIt->second, 
//                                downstreamIt->first, *downstreamIt->second,
//                                outputPort, locallyBuffered, metadata);
//     }

//     ASSERT(downstreamOps == 1);
//   }
// }

// void ParallelPlan::ConnectSequentialCollect(ParallelDomain * upstreamDomain,
//                                             const PartitionOperatorMap& upstream,
//                                             ParallelDomain * downstreamDomain,
//                                             const PartitionOperatorMap& downstream,
//                                             port_t outputPort,
//                                             bool locallyBuffered,
//                                             const RecordMetadata & metadata)
// {
//   for(PartitionOperatorMap::const_iterator downstreamIt = downstream.begin();
//       downstreamIt != downstream.end();
//       downstreamIt++)
//   {
//     for(PartitionOperatorMap::const_iterator upstreamIt = upstream.begin();
//         upstreamIt != upstream.end();
//         upstreamIt++)
//     {
//       // Intra domain connection.  
//       if (upstreamDomain == downstreamDomain)
//       {
//         upstreamDomain->Connect(
//           upstreamIt->second, outputPort,
//           downstreamIt->second, upstreamIt->first->GetPartition(), locallyBuffered);
//       }
//       else
//       {
//         // Inter domain connection.  
//         upstreamDomain->ConnectRemoteWrite(upstreamIt->second, outputPort,
//                                            metadata, downstreamIt->first->GetPartition(), mTag);
//         downstreamDomain->ConnectRemoteRead(downstreamIt->second, upstreamIt->first->GetPartition(),
//                                             metadata, upstreamIt->first->GetPartition(), mTag);
//         mTag += 1;
//       }
//     }
//   }
// }

// void ParallelPlan::Dump(std::ostream & ostr) const
// {
// //   // Print out partition by partition
// //   for(std::size_t p = 0; p<mDomains.size(); p++)
// //   {
// //     ostr << "Partition(" << p << ")" << std::endl;
// //     const std::vector<RunTimeOperator *> & ops = mReactorToOperator.find(mReactors[p])->second;
// //     for(std::vector<RunTimeOperator *>::const_iterator oit = ops.begin();
// //         oit != ops.end();
// //         oit++)
// //     {
// //       ostr << (*oit)->GetName() << "(" << p << ")" << std::endl;
// //       ostr << "inputs(";
// //       for(port_t port = 0; port < (*oit)->GetNumInputs(); port++)
// //       {
// //         if(port > 0) ostr << ", ";
// //         ostr << std::hex << (*oit)->GetInput(port);
// //       }
// //       ostr << ")" << std::endl;
// //       ostr << "outputs(";
// //       for(port_t port = 0; port < (*oit)->GetNumOutputs(); port++)
// //       {
// //         if(port > 0) ostr << ", ";
// //         ostr << std::hex << (*oit)->GetOutput(port);
// //       }
// //       ostr << ")" << std::endl;
// //     }
// //   }
// }

ParallelPlan::ParallelPlan(boost::int32_t parallelism, bool multipleDomains)
  :
  mNumPartitions(parallelism),
  mNumDomains(multipleDomains ? parallelism : 1),
  mTag(0)
{
  // Initialize domain map
  if (multipleDomains)
  {
    // One partition per domain case.
    for (boost::int32_t i=0; i<mNumPartitions; i++)
    {
      mPartitionDomains.push_back(i);
    }
  }
  else
  {
    // All partitions in 1 domain.
    for (boost::int32_t i=0; i<mNumPartitions; i++)
    {
      mPartitionDomains.push_back(0);
    }    
  }
}

ParallelPlan::~ParallelPlan()
{
  for(std::vector<RunTimeOperator *>::iterator it = mOperators.begin();
      it != mOperators.end();
      ++it)
  {
    delete *it;
  }
}

operator_set_t ParallelPlan::AddOperator(DesignTimeOperator * op, 
                                         const std::map<std::wstring, std::vector<boost::int32_t> > & partitionLists)
{

  if (op->GetMode() == DesignTimeOperator::PARALLEL)
  {
    boost::dynamic_bitset<> partitionMap(mNumPartitions);
    if (op->GetPartitionConstraint().size() > 0)
    {
      std::map<std::wstring, std::vector<boost::int32_t> >::const_iterator partitionList = partitionLists.find(op->GetPartitionConstraint());
      if (partitionLists.end() == partitionList)
      {
        throw SingleOperatorException(*op, 
                                      (boost::wformat(L"Referenced partition constraint '%1%' not defined") %
                                       op->GetPartitionConstraint()).str());
      }
      for(std::vector<boost::int32_t>::const_iterator it = partitionList->second.begin();
          it != partitionList->second.end();
          ++it)
      {
        partitionMap.set(*it);
      }
    }
    else
    {
      partitionMap.flip();
    }
    mOperators.push_back(op->code_generate(partitionMap.count())); 
    mOperatorPartitionMask.push_back(partitionMap);
  }
  else
  {
    mOperators.push_back(op->code_generate(1));
    boost::dynamic_bitset<> partitionMap(mNumPartitions);
    partitionMap.set(0);
    mOperatorPartitionMask.push_back(partitionMap);
  }

  return mOperators.size() - 1;
}

void ParallelPlan::ConnectStraightLine(operator_set_t upstream, boost::int32_t outputPort,
                                        operator_set_t downstream, boost::int32_t inputPort,
                                        bool locallyBuffered, bool buffered, const RecordMetadata & metadata)
{
  if (mOperatorPartitionMask[upstream] != mOperatorPartitionMask[downstream])
    throw std::logic_error("Cannot connect straight line unless operators are in same partitions");
  mStraightLineChannels.push_back(StraightLineChannelSpec2(upstream, outputPort, downstream, inputPort, locallyBuffered, buffered, metadata));
}

void ParallelPlan::ConnectSequentialBroadcast(operator_set_t upstream,
                                               operator_set_t downstream,
                                               port_t inputPort,
                                               bool locallyBuffered,
                                               const RecordMetadata & metadata)
{
  mSequentialBroadcastChannels.push_back(SequentialBroadcastChannelSpec2(upstream, 0, downstream, inputPort, locallyBuffered, metadata, mTag));
  mTag += mOperatorPartitionMask[upstream].count()*mOperatorPartitionMask[downstream].count(); 
}

void ParallelPlan::ConnectSequentialCollect(operator_set_t upstream,
                                             operator_set_t downstream,
                                             port_t outputPort,
                                             bool locallyBuffered,
                                             const RecordMetadata & metadata)
{
  mSequentialCollectChannels.push_back(SequentialCollectChannelSpec2(upstream, outputPort, downstream, 0, locallyBuffered, metadata, mTag));
  mTag += mOperatorPartitionMask[upstream].count()*mOperatorPartitionMask[downstream].count(); 
}

void ParallelPlan::ConnectCrossbar(operator_set_t upstream,
                                    operator_set_t downstream,
                                    bool locallyBuffered,
                                    const RecordMetadata & metadata)
{
  mBipartiteChannels.push_back(BipartiteChannelSpec2(upstream, 0, downstream, 0, locallyBuffered, metadata, mTag));
  mTag += mOperatorPartitionMask[upstream].count()*mOperatorPartitionMask[downstream].count(); 
}

boost::shared_ptr<ParallelDomain> ParallelPlan::GetDomain(boost::int32_t domainNumber)
{
  if (domainNumber >= mNumDomains)
    throw std::logic_error("Invalid domain");

  // Right now we assume that all partitions in a domain are consecutive
  partition_t partitionStart = std::numeric_limits<partition_t>::max();
  partition_t partitionEnd = std::numeric_limits<partition_t>::min();
  for(partition_t p = 0; p<mPartitionDomains.size(); ++p)
  {
    if(mPartitionDomains[p] == domainNumber)
    {
      if (p < partitionStart)
        partitionStart = p;
      if (p > partitionEnd)
        partitionEnd = p;
    }
  }
  boost::shared_ptr<ParallelDomain> domain = boost::shared_ptr<ParallelDomain>(new ParallelDomain(partitionStart, partitionEnd));

  std::vector<PartitionActivationMap> ops;

  // First generate all operator activations in this domain.
  for(std::vector<RunTimeOperator*>::iterator it = mOperators.begin();
      it != mOperators.end();
      ++it)
  {
    ops.push_back(PartitionActivationMap());
    domain->AddOperator(*it, mOperatorPartitionMask[it-mOperators.begin()], ops.back());
  }

  // Generate all intradomain channels 
  for(std::vector<StraightLineChannelSpec2>::iterator it = mStraightLineChannels.begin();
      it != mStraightLineChannels.end();
      ++it)
  {
    for(std::size_t pos = mOperatorPartitionMask[it->GetUpstream()].find_first();
        pos != boost::dynamic_bitset<>::npos;
        pos = mOperatorPartitionMask[it->GetUpstream()].find_next(pos))
    {
      if (domainNumber == mPartitionDomains[pos])
      {
        domain->Connect(
          ops[it->GetUpstream()][pos], it->GetOutputPort(),
          ops[it->GetDownstream()][pos], it->GetInputPort(),
          it->GetLocallyBuffered(), it->GetBuffered());
      }
    }
  }

  for(std::vector<SequentialCollectChannelSpec2>::iterator it = mSequentialCollectChannels.begin();
      it != mSequentialCollectChannels.end();
      ++it)
  {
    // Sequential collect scenario, the downstream must be in exactly one partition.
    std::size_t downstreamPartition = mOperatorPartitionMask[it->GetDownstream()].find_first();
    if(boost::dynamic_bitset<>::npos != mOperatorPartitionMask[it->GetDownstream()].find_next(downstreamPartition))
    {
      throw std::logic_error("A sequential operator can only be assigned to a single partition");
    }

    // There are mOperatorPartitionMask[it->GetUpstream()].count()*mOperatorPartitionMask[it->GetDownstream()].count()
    // runtime channels corresponding to this one bipartite channel spec.
    // They are all assigned a unique number that serves as the MPI tag.  When the spec was created a single
    // base tag value was allocated.  Here we assign numbers sequentially for each of the runtime channels as they
    // are enumerated.  This enumeration is the same in all domains so the two ends (MPI endpoints) of a cross domain
    // channel will share the same MPI tag value.
    boost::int32_t tagOffset=0;
    for(std::size_t upstreamPartition = mOperatorPartitionMask[it->GetUpstream()].find_first();
        upstreamPartition != boost::dynamic_bitset<>::npos;
        upstreamPartition = mOperatorPartitionMask[it->GetUpstream()].find_next(upstreamPartition))
    {
      if (mPartitionDomains[upstreamPartition] == domainNumber)
      {
        if(mPartitionDomains[downstreamPartition] == domainNumber)
        {
          domain->Connect(
            ops[it->GetUpstream()][upstreamPartition], it->GetOutputPort(),
            ops[it->GetDownstream()][downstreamPartition], upstreamPartition,
            it->GetLocallyBuffered(), true);
        }
        else
        {
          domain->ConnectRemoteWrite(ops[it->GetUpstream()][upstreamPartition], 
                                     it->GetOutputPort(),
                                     it->GetMetadata(), downstreamPartition, it->GetTag() + tagOffset,
                                     it->GetLocallyBuffered());
        }
      }
      else if (mPartitionDomains[downstreamPartition] == domainNumber)
      {
        domain->ConnectRemoteRead(ops[it->GetDownstream()][downstreamPartition], upstreamPartition,
                                  it->GetMetadata(), upstreamPartition, it->GetTag() + tagOffset);
      }
      tagOffset += 1;
    }
  }
  for(std::vector<SequentialBroadcastChannelSpec2>::iterator it = mSequentialBroadcastChannels.begin();
      it != mSequentialBroadcastChannels.end();
      ++it)
  {
    std::size_t upstreamPartition = mOperatorPartitionMask[it->GetUpstream()].find_first();
    if (boost::dynamic_bitset<>::npos != mOperatorPartitionMask[it->GetUpstream()].find_next(upstreamPartition))
    {
      throw std::logic_error("A sequential operator can only be assigned to a single partition");
    }

    // There are mOperatorPartitionMask[it->GetUpstream()].count()*mOperatorPartitionMask[it->GetDownstream()].count()
    // runtime channels corresponding to this one bipartite channel spec.
    // They are all assigned a unique number that serves as the MPI tag.  When the spec was created a single
    // base tag value was allocated.  Here we assign numbers sequentially for each of the runtime channels as they
    // are enumerated.  This enumeration is the same in all domains so the two ends (MPI endpoints) of a cross domain
    // channel will share the same MPI tag value.
    boost::int32_t tagOffset=0;
    for(std::size_t downstreamPartition = mOperatorPartitionMask[it->GetDownstream()].find_first();
        downstreamPartition != boost::dynamic_bitset<>::npos;
        downstreamPartition = mOperatorPartitionMask[it->GetDownstream()].find_next(downstreamPartition))
    {
      if (mPartitionDomains[upstreamPartition] == domainNumber)
      {
        if(mPartitionDomains[downstreamPartition] == domainNumber)
        {
          domain->Connect(
            ops[it->GetUpstream()][upstreamPartition], downstreamPartition,
            ops[it->GetDownstream()][downstreamPartition], it->GetInputPort(),
            it->GetLocallyBuffered(), true);
        }
        else
        {
          domain->ConnectRemoteWrite(ops[it->GetUpstream()][upstreamPartition], 
                                     downstreamPartition,
                                     it->GetMetadata(), downstreamPartition, it->GetTag() + tagOffset,
                                     it->GetLocallyBuffered());
        }
      }
      else if (mPartitionDomains[downstreamPartition] == domainNumber)
      {
        domain->ConnectRemoteRead(ops[it->GetDownstream()][downstreamPartition], it->GetInputPort(),
                                  it->GetMetadata(), upstreamPartition, it->GetTag() + tagOffset);
      }
      tagOffset += 1;
    }
  }
  for(std::vector<BipartiteChannelSpec2>::iterator it = mBipartiteChannels.begin();
      it != mBipartiteChannels.end();
      ++it)
  {
    // There are mOperatorPartitionMask[it->GetUpstream()].count()*mOperatorPartitionMask[it->GetDownstream()].count()
    // runtime channels corresponding to this one bipartite channel spec.
    // They are all assigned a unique number that serves as the MPI tag.  When the spec was created a single
    // base tag value was allocated.  Here we assign numbers sequentially for each of the runtime channels as they
    // are enumerated.  This enumeration is the same in all domains so the two ends (MPI endpoints) of a cross domain
    // channel will share the same MPI tag value.
    boost::int32_t tagOffset=0;
    port_t upstreamPort=0;
    for(std::size_t upstreamPartition = mOperatorPartitionMask[it->GetUpstream()].find_first();
        upstreamPartition != boost::dynamic_bitset<>::npos;
        upstreamPartition = mOperatorPartitionMask[it->GetUpstream()].find_next(upstreamPartition))
    {
      port_t downstreamPort=0;
      for(std::size_t downstreamPartition = mOperatorPartitionMask[it->GetDownstream()].find_first();
          downstreamPartition != boost::dynamic_bitset<>::npos;
          downstreamPartition = mOperatorPartitionMask[it->GetDownstream()].find_next(downstreamPartition))
      {
        if (mPartitionDomains[upstreamPartition] == domainNumber)
        {
          if(mPartitionDomains[downstreamPartition] == domainNumber)
          {
            domain->Connect(
              ops[it->GetUpstream()][upstreamPartition], downstreamPort,
              ops[it->GetDownstream()][downstreamPartition], upstreamPort,
              it->GetLocallyBuffered(), true);
          }
          else
          {
            domain->ConnectRemoteWrite(ops[it->GetUpstream()][upstreamPartition], 
                                       downstreamPort,
                                       it->GetMetadata(), downstreamPartition, it->GetTag() + tagOffset,
                                       it->GetLocallyBuffered());
          }
        }
        else if (mPartitionDomains[downstreamPartition] == domainNumber)
        {
          domain->ConnectRemoteRead(ops[it->GetDownstream()][downstreamPartition], upstreamPort,
                                   it->GetMetadata(), upstreamPartition, it->GetTag() + tagOffset);
        }
        tagOffset += 1;
        downstreamPort += 1;
      }
      upstreamPort += 1;
    }
  }
  return domain;
}

ParallelPartition::ParallelPartition(partition_t partition)
  :
  mReactor(NULL),
  mPartition(partition)
{
  mReactor = new BatchScheduler(partition);
}

ParallelPartition::ParallelPartition()
  :
  mReactor(NULL),
  mPartition(0)
{
}

ParallelPartition::~ParallelPartition()
{
  for(std::size_t i=0; i<mActivations.size(); i++)
  {
    delete mActivations[i];
  }
  delete mReactor;
}

void ParallelPartition::InternalStart(ParallelPartitionCompletions& completions)
{
#ifdef WIN32
  SYSTEM_INFO si;
  ::GetSystemInfo(&si);
  ::SetThreadIdealProcessor(GetCurrentThread(), mPartition % si.dwNumberOfProcessors);

//   DWORD_PTR affinity = 1 << (mPartition % si.dwNumberOfProcessors);
//   ::SetThreadAffinityMask(GetCurrentThread(), affinity);
  _set_se_translator(&SEHException::TranslateStructuredExceptionHandlingException);
#endif
  // TODO: Perhaps we should use Boost Test execution_monitor here.  This has some
  // good code for handling MS structured exceptions as well as code for handling
  // signals under Unix (though perhaps not in a multi-threaded environment).
  try
  {
    mReactor->Start(mActivations);

    boost::timed_mutex::scoped_lock lk(completions.guard);
    completions.exitcodes[this] = 0;
    completions.messages[this] = "";
    completions.condvar.notify_all();
  }
  catch(std::exception & e)
  {    
    boost::timed_mutex::scoped_lock lk(completions.guard);
    completions.exitcodes[this] = -1;
    completions.messages[this] = e.what();
    completions.condvar.notify_all();
    MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ParallelPartion]");
    logger->logError("A runtime error occurred executing a MetraFlow script.");
    if (e.what() != NULL)
    {
      logger->logError(e.what());
    }
    return;
  }
#ifdef WIN32
  catch(SEHException & e)
  {    
    boost::timed_mutex::scoped_lock lk(completions.guard);
    completions.exitcodes[this] = -1;
    completions.messages[this] = e.what();
    completions.messages[this] += "\nCall Stack:\n";
    completions.messages[this] += e.callStack();
    completions.condvar.notify_all();
    return;
   }
#endif
  catch(...)
  {
    boost::timed_mutex::scoped_lock lk(completions.guard);
    completions.exitcodes[this] = -1;
    completions.messages[this] = "Unknown exception";
    completions.condvar.notify_all();
    return;
  }
}

void ParallelPartition::Stop()
{
  mReactor->Stop();
}

void ParallelPartition::AddOperator(RunTimeOperator * op,
                                    PartitionActivationMap & ops,
                                    std::size_t partitionIndex)
{
  RunTimeOperatorActivation * activation = op->CreateActivation(mReactor, mPartition);
  activation->SetPartitionIndex(partitionIndex);
  mActivations.push_back(activation);
  ops[mPartition] = activation;
}

void ParallelPartition::DumpStatistics(std::ostream& ostr)
{
  // Report the amount of available memory.
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof(MEMORYSTATUSEX);
  ::GlobalMemoryStatusEx(&statex);
  boost::uint64_t remainingMemory = (100LL*statex.ullAvailVirtual)/statex.ullTotalVirtual;
  
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ParallelPartion]");
  logger->logInfo((boost::format("Amount of available memory remaining for MetraFlow %1% percent.")
                      % remainingMemory).str());

  boost::posix_time::ptime t = boost::posix_time::microsec_clock::local_time();
  ostr << "\nOperator TotalTicks TotalExecutions Time";
  for(std::vector<RunTimeOperatorActivation *>::const_iterator it = mActivations.begin();
      it != mActivations.end();
      ++it)
  {
    std::string utf8Name;
    ::WideStringToUTF8((*it)->GetName(), utf8Name);
    ostr << "\n\"" << utf8Name << "\" " << (*it)->GetOperatorTicks() << " " 
         << (*it)->GetOperatorExecutions() << " " << t;
  }

  GetReactor()->DumpStatistics(ostr);
}

ParallelDomain::ParallelDomain(partition_t partitionStart, partition_t partitionEnd)
  :
  mMessageService(NULL),
  mPartitionStart(partitionStart),
  mPartitionEnd(partitionEnd)
{
  for(partition_t p = mPartitionStart; p<=mPartitionEnd; p++)
  {
    mPartitions[p] = new ParallelPartition(p);
  }
}

ParallelDomain::ParallelDomain()
  :
  mMessageService(NULL),
  mPartitionStart(0),
  mPartitionEnd(0)
{
}

ParallelDomain::~ParallelDomain()
{
  for(std::size_t i=0; i<mChannels.size(); i++)
  {
//     mChannels[i]->DumpStatistics();
    delete mChannels[i];
  }

  if (mMessageService)
    mMessageService->Join();

  //TODO: Is there a race condition on shutdown in which the MPIService can try to
  //access the scheduler after the scheduler has been deleted (that is to say after
  //completeing EOFs but before acks are completely processed?)
  for(std::map<partition_t,ParallelPartition*>::const_iterator it = mPartitions.begin();
    it != mPartitions.end();
    it++)
  {
    delete it->second;
  }
  for(std::size_t i=0; i<mChannelSpecs.size(); i++)
  {
    delete mChannelSpecs[i];
  }
  for(std::size_t i=0; i<mRemoteReadSpecs.size(); i++)
  {
    delete mRemoteReadSpecs[i];
  }
  for(std::size_t i=0; i<mRemoteWriteSpecs.size(); i++)
  {
    delete mRemoteWriteSpecs[i];
  }

  for(std::size_t i=0; i<mMpiRecvEndpoints.size(); i++)
  {
    delete mMpiRecvEndpoints[i];
  }
  
  for(std::size_t i=0; i<mMpiSendEndpoints.size(); i++)
  {
    delete mMpiSendEndpoints[i];
  }
 
  delete mMessageService;
}

void ParallelDomain::Start()
{
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger(
    (boost::format("[ParallelDomain(%1%,%2%)]") % mPartitionStart % mPartitionEnd).str());  

  static time_t lastReportingTime = 0;

  ParallelPartitionCompletions completions;

  if (mPartitions.size() >= 1)
  {
    // Start the message passing service if needed.
    if (mMpiSendEndpoints.size() > 0 || mMpiRecvEndpoints.size() > 0)
    {
      ASSERT(mPartitions.size() == 1);
      ASSERT(mMessageService != NULL);
      mMessageService->Start(mMpiRecvEndpoints, mMpiSendEndpoints);
    }

    std::vector<boost::shared_ptr<boost::thread> > threads;
    
    for(std::map<partition_t,ParallelPartition*>::const_iterator it = mPartitions.begin();
        it != mPartitions.end();
        it++)
    {
      boost::function0<void> threadFunc = boost::bind(&ParallelPartition::InternalStart, it->second, boost::ref(completions));
      // Create delegates for each partition InternalStart method and run in a thread
      threads.push_back(boost::shared_ptr<boost::thread>(new boost::thread(threadFunc)));
    }

    do
    {
      // Print out performance counters.
      std::ostringstream str;
      for(std::map<partition_t,ParallelPartition*>::const_iterator partIt = mPartitions.begin();
          partIt != mPartitions.end();
          partIt++)
      {
        partIt->second->DumpStatistics(str);
      }
      logger->logDebug(str.str());

      // Print out channel sizes.
      std::wstring unknown(L"not set");
      for(std::vector<Channel *>::const_iterator it = mChannels.begin();
          it != mChannels.end();
          ++it)
      {
          boost::wformat fmt(L"Channel(%1%,%2%) : size = %3%; read = %4%; written = %5%; source_priority=%6%; target_priority=%7%");
          fmt % ((*it)->GetSource()->GetOperator() == NULL ? unknown : (*it)->GetSource()->GetOperator()->GetName());
          fmt % ((*it)->GetTarget()->GetOperator() == NULL ? unknown : (*it)->GetTarget()->GetOperator()->GetName());
          fmt % (*it)->GetSize();
          fmt % (*it)->GetNumRead();
          fmt % (*it)->GetNumWritten();
          fmt % (*it)->GetSource()->GetPriority();
          fmt % (*it)->GetTarget()->GetPriority();
          std::string utf8Str;
          ::WideStringToUTF8(fmt.str(), utf8Str);
          logger->logDebug(utf8Str);
      }

      // Print out message about how the amount data processed has changed.
      // This is printed at the info level so the people monitoring
      // MetraFlow can get a sense of how things are progressing.
      if (time(NULL) - lastReportingTime >= TIME_BETWEEN_REPORTS_IN_SEC)
      {
        lastReportingTime = time(NULL);
        for(std::vector<Channel *>::const_iterator channelIt = mChannels.begin();
            channelIt != mChannels.end();
            ++channelIt)
        {
            boost::wformat fmt1(L"Operator %1% finished processing %2% additional records.");
            boost::wformat fmt2(L"Operator %1% received %2% more records.");
  
            if ((*channelIt)->GetNumWritten() - (*channelIt)->GetPreviousNumWritten() > 0)
            {
                fmt1 % ((*channelIt)->GetSource()->GetOperator() == NULL ? unknown : (*channelIt)->GetSource()->GetOperator()->GetName());
                fmt1 % ((*channelIt)->GetNumWritten() -  (*channelIt)->GetPreviousNumWritten());
                std::string utf8Str;
                ::WideStringToUTF8(fmt1.str(), utf8Str);
                logger->logInfo(utf8Str);
            }
  
            if ((*channelIt)->GetNumRead() - (*channelIt)->GetPreviousNumRead() > 0)
            {
                fmt2 % ((*channelIt)->GetTarget()->GetOperator() == NULL ? unknown : (*channelIt)->GetTarget()->GetOperator()->GetName());
                fmt2 % ((*channelIt)->GetNumRead()  - (*channelIt)->GetPreviousNumRead());
                std::string utf8Str;
                ::WideStringToUTF8(fmt2.str(), utf8Str);
                logger->logInfo(utf8Str);
            }
  
            (*channelIt)->SetPreviousStatistics();
        }
      }

      // Print out remote endpoint sizes.
      for(std::vector<MPISendEndpoint *>::const_iterator it = mMpiSendEndpoints.begin();
          it != mMpiSendEndpoints.end();
          ++it)
      {
          boost::wformat fmt(L"MPISend(%1%,%2%,%3%) : size=%4%; written=%5%; priority=%6%");
          fmt % ((*it)->GetOperator() == NULL ? unknown : (*it)->GetOperator()->GetName());
          fmt % (*it)->GetTag();
          fmt % (*it)->GetRemotePartition();
          fmt % (*it)->GetSize();
          fmt % (*it)->GetLocalQueue().GetNumWritten();
          fmt % (*it)->GetPriority();
          std::string utf8Str;
          ::WideStringToUTF8(fmt.str(), utf8Str);
          logger->logDebug(utf8Str);
      }
      for(std::vector<MPIRecvEndpoint *>::const_iterator it = mMpiRecvEndpoints.begin();
          it != mMpiRecvEndpoints.end();
          ++it)
      {
          boost::wformat fmt(L"MPIRecv(%1%,%2%,%3%) : size=%4%; read=%5%; priority=%6%");
          fmt % ((*it)->GetOperator() == NULL ? unknown : (*it)->GetOperator()->GetName());
          fmt % (*it)->GetTag();
          fmt % (*it)->GetRemotePartition();
          fmt % (*it)->GetSize();
          fmt % (*it)->GetLocalQueue().GetNumRead();
          fmt % (*it)->GetPriority();
          std::string utf8Str;
          ::WideStringToUTF8(fmt.str(), utf8Str);
          logger->logDebug(utf8Str);
      }

      // Dump statistics of the message service
      if (mMpiSendEndpoints.size() > 0 || mMpiRecvEndpoints.size() > 0)
      {
        std::ostringstream ostr;
        mMessageService->DumpStatistics(ostr);
        logger->logDebug(ostr.str());
      }
//       //Dump the scheduler queues
//       for(std::map<partition_t, ParallelPartition *>::iterator it = mPartitions.begin();
//           it != mPartitions.end();
//           ++it)
//       {
//         std::wstringstream ss;
//         it->second->GetReactor()->DumpQueues(ss);
//         logger->logInfo(ss.str());
//       }
      

      // Dump slab allocator memory statistics
      /* JAB: Removed with new allocator imple. This should be a hook for
       * the new allocator drop in (1/5/2010)
       */
      //logger->logDebug(SlabAllocator::GetAllStatistics());

      // Check for completion notifications from the threads.  These should probably be timed
      // waits, but I don't quite what to do if we time out.  Essentially one has to determine if 
      // a thread is slow or hung or dead.  Unfortunately, Boost doesn't even allow me to know whether
      // a thread is alive or not :-(  That's the price for portability at this point.
      // Wait for further changes
      boost::timed_mutex::scoped_lock lk(completions.guard);
      for(std::map<ParallelPartition*, boost::int32_t>::iterator it = completions.exitcodes.begin();
          it != completions.exitcodes.end();
          it++)
      {
        if (it->second != 0)
        {
          // One of the threads has failed, signal all of the threads to come down, then go wait on them.  
          // This won't do anything to bring down a thread hung in an operator invocation because it 
          // just tells the scheduler to stop doing stuff (i.e. it's preemptive).
          for(std::map<partition_t,ParallelPartition*>::const_iterator pit = mPartitions.begin();
              pit != mPartitions.end();
              pit++)
          {
            pit->second->Stop();
          }
          if (mMpiSendEndpoints.size() > 0 || mMpiRecvEndpoints.size() > 0)
          {
            mMessageService->Stop();
          }
          break;
        }
      }

      // No errors on any of the threads.  We might be done too!
      if (completions.exitcodes.size() == mPartitions.size()) 
        break;

      // Not done.  Wait for children to complete and notify.
      boost::xtime xt;
      boost::xtime_get(&xt, boost::TIME_UTC);
      xt.sec += 60;
      completions.condvar.timed_wait(lk, xt);
    } while(true);

    // Final cleanup.  These 
    for(std::vector<boost::shared_ptr<boost::thread> >::iterator it = threads.begin();
        it != threads.end();
        it++)
    {
      (*it)->join();
    }
  }
  else
  {
    ASSERT(mPartitions.size() == 1);
    mPartitions.begin()->second->InternalStart(completions);
  }

  // Print out final operator timings
  for(std::map<partition_t,ParallelPartition*>::const_iterator partIt = mPartitions.begin();
      partIt != mPartitions.end();
      partIt++)
  {
    std::ostringstream ostr;
    partIt->second->DumpStatistics(ostr);
    logger->logDebug(ostr.str());
  }

  // Print out channel sizes.
  for(std::vector<Channel *>::const_iterator it = mChannels.begin();
      it != mChannels.end();
      it++)
  {
    boost::wformat fmt(L"Channel(%1%,%2%) : size = %3%; read = %4%; written = %5%");
    fmt % (*it)->GetSource()->GetOperator()->GetName();
    fmt % (*it)->GetTarget()->GetOperator()->GetName();
    fmt % (*it)->GetSize();
    fmt % (*it)->GetNumRead();
    fmt % (*it)->GetNumWritten();
    std::string utf8Str;
    ::WideStringToUTF8(fmt.str(), utf8Str);
    logger->logDebug(utf8Str);
  }

  // Dump slab allocator memory statistics.  All internal lists
  // should be full (except for the thread local caches).
  /* JAB: Removed with new allocator imple. This should be a hook for
   * the new allocator drop in (1/5/2010)
   */
  //logger->logDebug(SlabAllocator::GetAllStatistics());

  // Lastly check to see if any of the threads returned error.
  // If so, throw an exception so the caller knows we failed!
  bool failed(false);
  std::string message;
  for(std::map<ParallelPartition*, boost::int32_t>::iterator it = completions.exitcodes.begin();
      it != completions.exitcodes.end();
      it++)
  {
    if (it->second != 0)
    {
      failed = true;
      message += (boost::format("Partition(%1%) exited with error code %2% and message %3%\n") 
                  % it->first->GetPartition() % it->second % completions.messages[it->first]).str();
    }
  }
  if (failed)
    throw std::runtime_error(message);
}

void ParallelDomain::AddOperator(RunTimeOperator * op, 
                                 const boost::dynamic_bitset<>& partitionMask,
                                 PartitionActivationMap & ops)
{
  // We need to know the index of the partition within the set of partitions in which
  // this operator is being created.  When non-trivial partition constraints are in effect,
  // this value is different from the partition number.
  // Here we the mapping of partition number to bit index.
  std::map<partition_t, std::size_t> partitionToBitIndex;
  std::size_t bitIndex=0;
  for(std::size_t pos = partitionMask.find_first();
      pos != boost::dynamic_bitset<>::npos;
      pos = partitionMask.find_next(pos))
  {
    partitionToBitIndex[pos] = bitIndex++;
  }

  for(std::map<partition_t,ParallelPartition*>::const_iterator it = mPartitions.begin();
      it != mPartitions.end();
      it++)
  {
    if (partitionMask.test(it->first))
      it->second->AddOperator(op, ops, partitionToBitIndex[it->first]);
  }
}

void ParallelDomain::InsertChannel(Channel * c)
{
  mChannels.push_back(c);
} 

void ParallelDomain::CreateChannel(IntraDomainChannelSpec * spec)
{
  ParallelPartition * sourcePartition = mPartitions.find(spec->GetSourceOperator()->GetPartition())->second;
  ParallelPartition * targetPartition = mPartitions.find(spec->GetTargetOperator()->GetPartition())->second;
  Channel * c = new Channel(spec->GetSourceOperator(), spec->GetTargetOperator(), spec->GetLocallyBuffered());
  c->SetBuffering(spec->GetBuffered());
  InsertChannel(c);
  sourcePartition->GetReactor()->Add(c->GetSource());
  targetPartition->GetReactor()->Add(c->GetTarget());      
  spec->GetSourceOperator()->SetOutput(spec->GetSourcePort(), c);
  spec->GetTargetOperator()->SetInput(spec->GetTargetPort(), c);
  c->GetSource()->SetIndex(spec->GetSourcePort());
  c->GetTarget()->SetIndex(spec->GetTargetPort());
}

void ParallelDomain::CreateRemoteReadEndpoint(InterDomainReadEndpointSpec * spec)
{
  ParallelPartition * sourcePartition = mPartitions.find(spec->GetOperator()->GetPartition())->second;
  ASSERT(mPartitions.size() == 1);
  if (mMessageService == NULL)
    mMessageService = new MPIService(sourcePartition->GetReactor());
  MPIRecvEndpoint * re = new MPIRecvEndpoint(spec->GetOperator(),
                                             mMessageService,
                                             mMpiRecvEndpoints.size(),
                                             spec->GetMetadata(), 
                                             spec->GetTag(), 
                                             spec->GetRemotePartition());
  mMpiRecvEndpoints.push_back(re);
  sourcePartition->GetReactor()->Add(re);
  spec->GetOperator()->SetInput(spec->GetPort(), re);
  re->SetIndex(spec->GetPort());
}
void ParallelDomain::CreateRemoteWriteEndpoint(InterDomainWriteEndpointSpec * spec)
{
  ParallelPartition * sourcePartition = mPartitions.find(spec->GetOperator()->GetPartition())->second;
  ASSERT(mPartitions.size() == 1);
  if (mMessageService == NULL)
    mMessageService = new MPIService(sourcePartition->GetReactor());

  MPISendEndpoint * re = new MPISendEndpoint(spec->GetOperator(),
                                             mMessageService,
                                             mMpiSendEndpoints.size(),
                                             spec->GetMetadata(), 
                                             spec->GetTag(), 
                                             spec->GetRemotePartition(),
                                             spec->GetLocallyBuffered());
  mMpiSendEndpoints.push_back(re);
  sourcePartition->GetReactor()->Add(re);
  spec->GetOperator()->SetOutput(spec->GetPort(), re);
  re->SetIndex(spec->GetPort());
}


BatchScheduler::BatchScheduler(partition_t partition)
  :
  LinuxProcessor(partition),
  mPendingSyncs(NULL)
{
}

BatchScheduler::~BatchScheduler()
{
}

void BatchScheduler::ScheduleOperator(RunTimeOperatorActivation * task, Endpoint * ep)
{
  // The scheudler is calling us because either we are being allowed to
  // load our local read channel or store a local write channel.
  ep->SyncLocalQueue(*this);

  // At this point we let the operator run until either it drains a required
  // local read queue or fills a local write queue.
  mEndpoint = ep;
  while(NULL != mEndpoint)
  {
    Endpoint * tmp = mEndpoint;
    mEndpoint = NULL;
    task->HandleEvent(tmp);
  }

  // Do any forced syncs (e.g. EOFs on write channels).
  // Note that we must make a request first!
  // We are bypassing the scheduler!
  while(mPendingSyncs != NULL)
  {
    Endpoint * tmp = mPendingSyncs;
    mPendingSyncs = tmp->Unlink();
    InternalRequestWrite(task, tmp);
    tmp->SyncLocalQueue(*this);
  }
}

void BatchScheduler::RequestRead(RunTimeOperatorActivation * task, Endpoint * ep)
{
  // When performing a non-deterministic read on multiple inputs we have
  // two options.  If the highest priority request (first in the request list)
  // is not locally buffered, we can look for locally buffered data on other requests
  // in the list or we can
  // pass through to the scheduler.  The trick is that it may not be well defined 
  // to do anything but pass the entire list of requests through to the scheduler
  // and this means we may be called back on an endpoint for which we already have
  // data.
  //
  // I don't think that we CAN pass the request through unmodified, we may
  // have an EOF in our local queue that the operator hasn't seen yet!  Passing a request
  // on a channel that is closed will cause the scheduler to hang.
  // So I think a general rule is that we cannot allow read requests on inputs
  // for which any locally buffered messages exist.
  Endpoint * iter = ep;
  do
  {
    if (iter->GetLocalQueue().GetSize() > 0)
    {
      mEndpoint = iter;
      return;
    }
    iter = iter->NextRequest();
  } while(iter != ep);

  // All local queues from the request are empty.  Pass the request
  // through to the scheduler.
  this->InternalRequestRead(task, ep);
  mEndpoint = NULL;
}

void BatchScheduler::RequestWrite(RunTimeOperatorActivation * task, Endpoint * ep)
{
  if(!mIsStarting && ep->GetLocalQueue().GetSize() < METRAFLOW_BATCH_SCHEDULER_GRAIN)
  {
    mEndpoint = ep;
  }
  else
  {
    // Note that we don't sync queues here.  Because 
    // we don't have non-deterministic writes, we queue
    // up this request and exit.  When this operator resumes
    // it is guaranteed to be for a write to this endpoint.
    // At that point we sync queues and resume execution.
    // The reason for doing this is to give the scheduler a chance
    // to schedule the write.
    mEndpoint = NULL;
    this->InternalRequestWrite(task, ep);
  }
}

void BatchScheduler::WriteChannel(Endpoint * ep, MessagePtr m, bool close)
{
  // Once we are in here, none of the endpoints of the operator
  // should be enabled in the scheduler.
  ASSERT(mEndpoint == NULL);
  ASSERT(ep->GetLocalQueue().GetSize() < METRAFLOW_BATCH_SCHEDULER_GRAIN);
  ASSERT(ep->GetPriority() == -1 || ep->GetPriority() == -2);
  ep->GetLocalQueue().Push(m);
  if ((close || false == ep->GetLocallyBuffered()) && ep->GetPriority() == -1)
  {
    // Note that we are able to put this endpoint on the pending syncs
    // queue because it has no request; hence is not on a shared queue.
    InternalUnlinkDisabled(ep);
    ep->SetPriority(-2);
    mPendingSyncs = ep->LinkBefore(mPendingSyncs);
  }
}

void BatchScheduler::ReadChannel(Endpoint * ep, MessagePtr& m)
{
  ASSERT(mEndpoint == NULL);
  ASSERT(ep->GetLocalQueue().GetSize() > 0);
  ep->GetLocalQueue().Pop(m);
}
