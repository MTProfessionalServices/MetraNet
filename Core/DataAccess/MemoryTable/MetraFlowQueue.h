#ifndef __METRAFLOWQUEUE_H__
#define __METRAFLOWQUEUE_H__

#include "MetraFlowConfig.h"
#include "RecordModel.h"
#include "Scheduler.h"

// Using Pimpl pattern to hide implementation details such as Boost threads
class MetraFlowQueueImpl;
class MetraFlowQueueNamingServiceImpl;

/**
 * A non-persistent, non-recoverable, concurrent queue of MetraFlow records.
 */
class MetraFlowQueue
{
private:
  MetraFlowQueueImpl * mImpl;
public:
  /**
   * ISSUE: I had thought about having MF create the output queue metadata.
   * That means that MF must also create the queue.
   * For the case at hand, I don't think I quite know how to make that work
   * correctly, so it does mean having the client create both input and output
   * queues.
   */
  METRAFLOW_DECL MetraFlowQueue(const RecordMetadata& metadata);
  METRAFLOW_DECL ~MetraFlowQueue();
  METRAFLOW_DECL const RecordMetadata& GetMetadata() const;
  METRAFLOW_DECL void Push(MessagePtr m);
  METRAFLOW_DECL void Pop(MessagePtr& m);
  METRAFLOW_DECL MessagePtr Top();
};

/**
 * A simple singleton queue naming service for queues.
 */
class MetraFlowQueueNamingService
{
private:
  METRAFLOW_DECL MetraFlowQueueNamingService();
  METRAFLOW_DECL ~MetraFlowQueueNamingService();

  MetraFlowQueueNamingServiceImpl * mImpl;
public:
  // Singleton interface.
  METRAFLOW_DECL static MetraFlowQueueNamingService& Get();
  METRAFLOW_DECL static void Release(MetraFlowQueueNamingService& mfqm);

  /**
   * Create a queue with the given name.  throws if the name is already in use.
   */  
  METRAFLOW_DECL boost::shared_ptr<MetraFlowQueue> Create(const std::wstring& queueName, const RecordMetadata& metadata);
  /**
   * Open a queue with the given name.  Requires that the queue has been created by a previous call to Create.
   * Returns NULL if a queue with the given name does not exist.
   */  
  METRAFLOW_DECL boost::shared_ptr<MetraFlowQueue> Open(const std::wstring& queueName);
  /**
   * Removes the queue from the manager.  If there are any outstanding references to 
   * the queue, then the queue instance will not be deleted until those references are nulled out.
   */
  METRAFLOW_DECL void Delete(const std::wstring& queueName);
};

/**
 * A MetraFlow operator for importing data from a MetraFlowQueue into a MetraFlow program.  The queue is assumed to be created outside of the
 * context of the MetraFlow program.  The queue is assumed to have been registered with the global/single QueueNamingService.
 */
class DesignTimeQueueImport : public DesignTimeOperator
{
private:
  std::wstring mQueueName;

public:
  METRAFLOW_DECL DesignTimeQueueImport();
  METRAFLOW_DECL ~DesignTimeQueueImport();
  /**
   * Validates that the named queue exists.  Output metadata of the import operator is taken from the queue.
   */  
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);
  /**
   * The name of the queue from which to import/read.  
   */
  METRAFLOW_DECL void SetQueueName(const std::wstring& updateProgram);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeQueueImport* clone(
                                       const std::wstring& name,
                                       std::vector<OperatorArg*>& args, 
                                       int nInputs, int nOutputs) const;
};

class RunTimeQueueImport : public RunTimeOperator
{
public:
  friend class RunTimeQueueImportActivation;
private:
  std::wstring mQueueName;

  //
  // Serialization support - not actually supported since current queue implementation is intraprocess
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    throw std::logic_error("Queue import operator does not support cluster execution");
  }

public:
  METRAFLOW_DECL RunTimeQueueImport(const std::wstring& name, 
                                    const std::wstring& queueName);
  METRAFLOW_DECL ~RunTimeQueueImport();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeQueueImportActivation : public RunTimeOperatorActivationImpl<RunTimeQueueImport>
{
private:
  enum State { START, WRITE_0 };
  // Class variables that the make up the "stack".
  boost::shared_ptr<MetraFlowQueue> mQueue;
  State mState;
  MessagePtr mMessage;
public:
  METRAFLOW_DECL RunTimeQueueImportActivation(Reactor * reactor, 
                                              partition_t partition, 
                                              const RunTimeQueueImport * runTimeOperator);
  METRAFLOW_DECL ~RunTimeQueueImportActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

/**
 * A MetraFlow operator for exporting data from a MetraFlow program into a MetraFlowQueue.  The queue is assumed to be created outside of the
 * context of the MetraFlow program.  The queue is assumed to have been registered with the global/single QueueNamingService.
 */
class DesignTimeQueueExport : public DesignTimeOperator
{
private:
  std::wstring mQueueName;

public:
  METRAFLOW_DECL DesignTimeQueueExport();
  METRAFLOW_DECL ~DesignTimeQueueExport();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL void SetQueueName(const std::wstring& updateProgram);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeQueueExport* clone(
                                       const std::wstring& name,
                                       std::vector<OperatorArg*>& args, 
                                       int nInputs, int nOutputs) const;
};

class RunTimeQueueExport : public RunTimeOperator
{
public:
  friend class RunTimeQueueExportActivation;
private:
  std::wstring mQueueName;
  RecordProjection mProjection;
  RecordMetadata mInputMetadata;

  //
  // Serialization support - not actually supported since current queue implementation is intraprocess
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    throw std::logic_error("Queue export operator does not support cluster execution");
  }

public:
  METRAFLOW_DECL RunTimeQueueExport(const std::wstring& name, 
                                    const std::wstring& queueName,
                                    const RecordMetadata & inputMetadata,
                                    const RecordProjection & projection);
  METRAFLOW_DECL ~RunTimeQueueExport();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeQueueExportActivation : public RunTimeOperatorActivationImpl<RunTimeQueueExport>
{
private:
  enum State { START, READ_0 };

  // Class variables that the make up the "stack".
  boost::shared_ptr<MetraFlowQueue> mQueue;
  State mState;
public:
  METRAFLOW_DECL RunTimeQueueExportActivation(Reactor * reactor, 
                                              partition_t partition, 
                                              const RunTimeQueueExport * runTimeOperator);
  METRAFLOW_DECL ~RunTimeQueueExportActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

#endif
