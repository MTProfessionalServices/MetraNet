#include "MetraFlowQueue.h"
#include "OperatorArg.h"
#include <boost/thread/mutex.hpp>
#include <boost/thread/condition.hpp>

class MetraFlowQueueImpl
{
private:
  RecordMetadata mMetadata;
  MessagePtrQueue mQueue;
  boost::mutex mQueueGuard;
  boost::condition mQueueCondVar;
public:
  /**
   * ISSUE: I had thought about having MF create the output queue metadata.
   * That means that MF must also create the queue.
   * For the case at hand, I don't think I quite know how to make that work
   * correctly, so it does mean having the client create both input and output
   * queues.
   */
  MetraFlowQueueImpl(const RecordMetadata& metadata);
  ~MetraFlowQueueImpl();
  const RecordMetadata& GetMetadata() const;
  void Push(MessagePtr m);
  void Pop(MessagePtr& m);
  MessagePtr Top();
};

MetraFlowQueueImpl::MetraFlowQueueImpl(const RecordMetadata& metadata)
  :
  mMetadata(metadata)
{
}

MetraFlowQueueImpl::~MetraFlowQueueImpl()
{
}


const RecordMetadata& MetraFlowQueueImpl::GetMetadata() const
{
  return mMetadata;
}

void MetraFlowQueueImpl::Push(MessagePtr m)
{
  boost::mutex::scoped_lock lk(mQueueGuard);
  mQueue.Push(m);
}

void MetraFlowQueueImpl::Pop(MessagePtr& m)
{
  // TODO: Implement blocking on empty.
  boost::mutex::scoped_lock lk(mQueueGuard);
  mQueue.Pop(m);
}

MessagePtr MetraFlowQueueImpl::Top()
{
  boost::mutex::scoped_lock lk(mQueueGuard);
  return mQueue.Top();
}

MetraFlowQueue::MetraFlowQueue(const RecordMetadata& metadata)
  :
  mImpl(new MetraFlowQueueImpl(metadata))
{
}

MetraFlowQueue::~MetraFlowQueue()
{
  delete mImpl;
}

const RecordMetadata& MetraFlowQueue::GetMetadata() const
{
  return mImpl->GetMetadata();
}

void MetraFlowQueue::Push(MessagePtr m)
{
  mImpl->Push(m);
}

void MetraFlowQueue::Pop(MessagePtr& m)
{
  mImpl->Pop(m);
}

MessagePtr MetraFlowQueue::Top()
{
  return mImpl->Top();
}

/**
 * A simple singleton queue naming service for queues.
 */
class MetraFlowQueueNamingServiceImpl
{
private:
  std::map<std::wstring, boost::shared_ptr<MetraFlowQueue> > mQueueMap;
  std::map<boost::shared_ptr<MetraFlowQueue>, std::wstring> mQueueIndex;
  boost::mutex mMutex;

public:
  MetraFlowQueueNamingServiceImpl();
  ~MetraFlowQueueNamingServiceImpl();

  /**
   * Create a queue with the given name.  throws if the name is already in use.
   */  
  boost::shared_ptr<MetraFlowQueue> Create(const std::wstring& queueName, const RecordMetadata& metadata);
  /**
   * Open a queue with the given name.  Requires that the queue has been created by a previous call to Create.
   * Returns NULL if a queue with the given name does not exist.
   */  
  boost::shared_ptr<MetraFlowQueue> Open(const std::wstring& queueName);
  /**
   * Removes the queue from the manager.  If there are any outstanding references to 
   * the queue, then the queue instance will not be deleted until those references are nulled out.
   */
  void Delete(const std::wstring& queueName);
};

MetraFlowQueueNamingServiceImpl::MetraFlowQueueNamingServiceImpl()
{
}

MetraFlowQueueNamingServiceImpl::~MetraFlowQueueNamingServiceImpl()
{
}

boost::shared_ptr<MetraFlowQueue> MetraFlowQueueNamingServiceImpl::Create(const std::wstring& queueName, const RecordMetadata& metadata)
{
  boost::mutex::scoped_lock lk(mMutex);
  if (mQueueMap.find(queueName) != mQueueMap.end()) 
    throw std::runtime_error("Queue already exists");
  boost::shared_ptr<MetraFlowQueue> q (new MetraFlowQueue(metadata));
  mQueueMap[queueName] = q;
  mQueueIndex[q] = queueName;

  return q;
}

boost::shared_ptr<MetraFlowQueue> MetraFlowQueueNamingServiceImpl::Open(const std::wstring& queueName)
{
  boost::mutex::scoped_lock lk(mMutex);
  std::map<std::wstring, boost::shared_ptr<MetraFlowQueue> >::iterator it = mQueueMap.find(queueName);
  if (it == mQueueMap.end()) 
    return boost::shared_ptr<MetraFlowQueue>();

  return it->second;
}

void MetraFlowQueueNamingServiceImpl::Delete(const std::wstring& queueName)
{
  boost::mutex::scoped_lock lk(mMutex);
  std::map<std::wstring, boost::shared_ptr<MetraFlowQueue> >::iterator it = mQueueMap.find(queueName);
  if (it == mQueueMap.end()) 
    return;

  mQueueIndex.erase(it->second);
  mQueueMap.erase(it->first);
}

// NamingService Singleton interface.
MetraFlowQueueNamingService * sService = NULL;
boost::int32_t sRefCount = 0;
boost::mutex sMutex;

MetraFlowQueueNamingService& MetraFlowQueueNamingService::Get()
{
  boost::mutex::scoped_lock lk(sMutex);
  if (sRefCount++ == 0)
  {
    sService = new MetraFlowQueueNamingService();
  }
  return *sService;
}

void MetraFlowQueueNamingService::Release(MetraFlowQueueNamingService& mfqm)
{
  boost::mutex::scoped_lock lk(sMutex);
  if (--sRefCount == 0)
  {
    delete sService;
    sService = NULL;
  }
}

MetraFlowQueueNamingService::MetraFlowQueueNamingService()
  :
  mImpl(new MetraFlowQueueNamingServiceImpl())
{
}

MetraFlowQueueNamingService::~MetraFlowQueueNamingService()
{
  delete mImpl;
}

boost::shared_ptr<MetraFlowQueue> MetraFlowQueueNamingService::Create(const std::wstring& queueName, const RecordMetadata& metadata)
{
  return mImpl->Create(queueName, metadata);
}

boost::shared_ptr<MetraFlowQueue> MetraFlowQueueNamingService::Open(const std::wstring& queueName)
{
  return mImpl->Open(queueName);
}

void MetraFlowQueueNamingService::Delete(const std::wstring& queueName)
{
  mImpl->Delete(queueName);
}

DesignTimeQueueImport::DesignTimeQueueImport()
{
  mOutputPorts.insert(this, 0, L"output", false);  
}

DesignTimeQueueImport::~DesignTimeQueueImport()
{
}

void DesignTimeQueueImport::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"queuename", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetQueueName(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeQueueImport* DesignTimeQueueImport::clone(
                          const std::wstring& name,
                          std::vector<OperatorArg *>& args, 
                          int nInputs, int nOutputs) const
{
  DesignTimeQueueImport* result = new DesignTimeQueueImport();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeQueueImport::type_check()
{
  MetraFlowQueueNamingService& service = MetraFlowQueueNamingService::Get();
  boost::shared_ptr<MetraFlowQueue> q = service.Open(mQueueName);
  if (NULL == q.get())
    throw std::runtime_error("Queue doesn't exist");

  mOutputPorts[0]->SetMetadata(new RecordMetadata(q->GetMetadata()));  
}

RunTimeOperator * DesignTimeQueueImport::code_generate(partition_t maxPartition)
{
  return new RunTimeQueueImport(mName, mQueueName);
}

void DesignTimeQueueImport::SetQueueName(const std::wstring& queueName)
{
  mQueueName = queueName;
}

RunTimeQueueImport::RunTimeQueueImport(const std::wstring& name, 
                                       const std::wstring& queueName)
  :
  RunTimeOperator(name),
  mQueueName(queueName)
{
}

RunTimeQueueImport::~RunTimeQueueImport()
{
}

RunTimeOperatorActivation * RunTimeQueueImport::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeQueueImportActivation(reactor, partition, this);
}

RunTimeQueueImportActivation::RunTimeQueueImportActivation(Reactor * reactor, 
                                                           partition_t partition, 
                                                           const RunTimeQueueImport * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeQueueImport>(reactor, partition, runTimeOperator),
  mState(START),
  mMessage(NULL)
{
}

RunTimeQueueImportActivation::~RunTimeQueueImportActivation()
{
}

void RunTimeQueueImportActivation::Start()
{
  mQueue = MetraFlowQueueNamingService::Get().Open(mOperator->mQueueName);
  if (NULL == mQueue.get())
  {
    throw std::runtime_error("Queue doesn't exist");
  }
  mMessage = NULL;
  mState = START;
  HandleEvent(NULL);
}

void RunTimeQueueImportActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(true)
    {
      mQueue->Pop(mMessage);
      RequestWrite(0);
      mState = WRITE_0;
      return;
    case WRITE_0:
      if (!mQueue->GetMetadata().IsEOF(mMessage))
      {
        Write(mMessage, ep);
      }
      else
      {
        Write(mMessage, ep, true);
        return;
      }
    }
  }
}

DesignTimeQueueExport::DesignTimeQueueExport()
{
  mInputPorts.insert(this, 0, L"input", false);
}

DesignTimeQueueExport::~DesignTimeQueueExport()
{
}


void DesignTimeQueueExport::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"queuename", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetQueueName(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeQueueExport* DesignTimeQueueExport::clone(
                                                const std::wstring& name,
                                                std::vector<OperatorArg *>& args, 
                                                int nInputs, int nOutputs) const
{
  DesignTimeQueueExport* result = new DesignTimeQueueExport();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeQueueExport::type_check()
{
  MetraFlowQueueNamingService& service = MetraFlowQueueNamingService::Get();
  boost::shared_ptr<MetraFlowQueue> q = service.Open(mQueueName);
  if (NULL == q.get())
    throw std::runtime_error("Queue doesn't exist");

  // Validate that the queue format is a projection of the available records.
}

RunTimeOperator * DesignTimeQueueExport::code_generate(partition_t maxPartition)
{
  MetraFlowQueueNamingService& service = MetraFlowQueueNamingService::Get();
  boost::shared_ptr<MetraFlowQueue> q = service.Open(mQueueName);
  return new RunTimeQueueExport(mName, mQueueName, 
                                *mInputPorts[0]->GetMetadata(), 
                                RecordProjection(*mInputPorts[0]->GetMetadata(), q->GetMetadata()));
}

void DesignTimeQueueExport::SetQueueName(const std::wstring& queueName)
{
  mQueueName = queueName;
}

RunTimeQueueExport::RunTimeQueueExport(const std::wstring& name, 
                                       const std::wstring& queueName,
                                       const RecordMetadata & inputMetadata,
                                       const RecordProjection & projection)
  :
  RunTimeOperator(name),
  mQueueName(queueName),
  mProjection(projection),
  mInputMetadata(inputMetadata)
{
}

RunTimeQueueExport::~RunTimeQueueExport()
{
}

RunTimeOperatorActivation * RunTimeQueueExport::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeQueueExportActivation(reactor, partition, this);
}

RunTimeQueueExportActivation::RunTimeQueueExportActivation(Reactor * reactor, 
                                                           partition_t partition, 
                                                           const RunTimeQueueExport * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeQueueExport>(reactor, partition, runTimeOperator)
{
}

RunTimeQueueExportActivation::~RunTimeQueueExportActivation()
{
}

void RunTimeQueueExportActivation::Start()
{
  mQueue = MetraFlowQueueNamingService::Get().Open(mOperator->mQueueName);
  if (NULL == mQueue.get())
  {
    throw std::runtime_error("Queue doesn't exist");
  }

  mState = START;
  HandleEvent(NULL);
}

void RunTimeQueueExportActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(true)
    {
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
    {
      MessagePtr tmp;
      Read(tmp, ep);
      if (!mQueue->GetMetadata().IsEOF(tmp))
      {
        MessagePtr output = mQueue->GetMetadata().Allocate();
        mOperator->mProjection.Project(tmp, output);
        mQueue->Push(output);
        mOperator->mInputMetadata.Free(tmp);
      }
      else
      {
        mQueue->Push(mQueue->GetMetadata().AllocateEOF());
        mOperator->mInputMetadata.Free(tmp);
        return;
      }
    }
    }
  }
}
