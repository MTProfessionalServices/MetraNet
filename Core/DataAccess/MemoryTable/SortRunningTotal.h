#ifndef __SORTRUNNINGTOTAL_H__
#define __SORTRUNNINGTOTAL_H__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
# pragma once
#endif

// Perhaps cleaner would be to add varargs support to MTSQL and then
// implement this as a function.

#include "MetraFlowConfig.h"
#include "Scheduler.h"
#include "HashAggregate.h"

class DesignTimeSortRunningAggregate : public DesignTimeOperator
{
private:
  std::vector<DesignTimeHashRunningAggregateInputSpec> mInputSpecs;
  RecordMetadata * mAccumulator;
  std::vector<std::wstring> mAccumulatorGroupByKeyNames;
  std::vector<DesignTimeSortKey> mSortKey;
  bool mPreIncrement;
  bool mOutputFinalTotals;
  bool mInitializeTable;

  // For the moment, we only output the first input
  RecordMerge * mMerger;

  int mNumBuckets;
  std::wstring mInitializeProgram;

  /** The key arguments specified */
  std::vector<std::wstring> mGroupByKeys;
  /**
   * Deduplicated group by keys
   */
  std::vector<std::wstring> mDedupedGroupByKeys;

  static std::wstring GetMTSQLDatatype(DataAccessor * accessor);
  static PhysicalFieldType GetPhysicalFieldType(int ty);
  static void DeduplicateGroupByKeys(const std::vector<std::wstring>& groupByKeys,
                                     std::vector<std::wstring>& dedupedGroupByKeys);
    
public:
  // TODO: Support more general aggregation functions (and expressions).  I have hard coded this
  // to be summation (and avoided a parse).
  METRAFLOW_DECL DesignTimeSortRunningAggregate(int numInputs=1);
  METRAFLOW_DECL ~DesignTimeSortRunningAggregate();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL void AddGroupByKey(const std::wstring& groupByKeys);
  METRAFLOW_DECL void SetGroupByKeys(const std::vector<std::wstring>& groupByKeys);
  // Right now we support two different interfaces.  Either one can stick in
  // two arbitrary MTSQL programs or one can use this silly ad-hoc summation interface.
  METRAFLOW_DECL void SetInitializeProgram(const std::wstring& initializeProgram);
  METRAFLOW_DECL void SetUpdateProgram(const std::wstring& updateProgram);
  METRAFLOW_DECL void SetInputSpecs(const std::vector<DesignTimeHashRunningAggregateInputSpec>& inputSpecs);
  METRAFLOW_DECL void AddInputSpec(const DesignTimeHashRunningAggregateInputSpec& inputSpec);
  METRAFLOW_DECL void AddSortKey(const DesignTimeSortKey& aKey);
  METRAFLOW_DECL void SetPreIncrement(bool preIncrement);
  METRAFLOW_DECL void SetOutputFinalTotals(bool outputFinalTotals);
  METRAFLOW_DECL void SetInitializeTable(bool initializeTable);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeSortRunningAggregate* clone(
                                                const std::wstring& name,
                                                std::vector<OperatorArg*>& args, 
                                                int nInputs, int nOutputs) const;
};

class RunTimeSortRunningAggregateInputSpecActivation
{
private:
  const RunTimeHashRunningAggregateInputSpec * mInputSpec;
  //
  // Generated stuff. Created in Start().
  //
  // Accessors for the input record
  std::vector<RunTimeSortKey> mInputGroupByKeys;
  // Accumulator program
	MTSQLInterpreter* mAccumulatorInterpreter;
	MTSQLExecutable* mAccumulatorExe;
  Frame * mAccumulatorProbeFrame;
  Frame * mAccumulatorTableFrame;
  RecordActivationRecord * mAccumulatorProbeActivationRecord;
  RecordActivationRecord * mAccumulatorTableActivationRecord;
	DualCompileEnvironment * mAccumulatorEnv;
  DualRuntimeEnvironment * mAccumulatorRuntime;
  
public:
  METRAFLOW_DECL RunTimeSortRunningAggregateInputSpecActivation(const RunTimeHashRunningAggregateInputSpec * inputSpec);
  METRAFLOW_DECL ~RunTimeSortRunningAggregateInputSpecActivation();
  METRAFLOW_DECL void Start(const RecordMetadata& accumulator,                                                  
                            MetraFlowLoggerPtr logger);
  METRAFLOW_DECL void Initialize(record_t inputMessage,
                                 record_t accumulator, 
                                 const std::vector<RunTimeSortKey>& accumulatorGroupByKeys);
  METRAFLOW_DECL void Update(record_t inputMessage, record_t accumulator);
  METRAFLOW_DECL int Compare(record_t inputMessage, record_t accumulator, const std::vector<RunTimeSortKey>& accumulatorGroupByKeys);
  METRAFLOW_DECL const RecordMetadata& GetMetadata() const;
  METRAFLOW_DECL const RecordMerge& GetMerger() const;
  METRAFLOW_DECL void ExportSortKey(QueueElement& e);
};

class RunTimeSortRunningAggregate : public RunTimeOperator
{
public:
  friend class RunTimeSortRunningAggregateActivation;

private:
  // first is probe, second is table
  std::vector<std::wstring> mAccumulatorGroupByKeyNames;
  std::vector<RunTimeHashRunningAggregateInputSpec> mInputSpecs;
  RecordMetadata mAccumulator;
  std::wstring mInitializerProgram;
  boost::int32_t mNumBuckets;
  bool mPreIncrement;
  bool mOutputFinalTotals;
  bool mInitializeTable;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mAccumulatorGroupByKeyNames);
    ar & BOOST_SERIALIZATION_NVP(mInputSpecs);
    ar & BOOST_SERIALIZATION_NVP(mAccumulator);
    ar & BOOST_SERIALIZATION_NVP(mInitializerProgram);
    ar & BOOST_SERIALIZATION_NVP(mNumBuckets);
    ar & BOOST_SERIALIZATION_NVP(mPreIncrement);
    ar & BOOST_SERIALIZATION_NVP(mOutputFinalTotals);
    ar & BOOST_SERIALIZATION_NVP(mInitializeTable);
  } 
  METRAFLOW_DECL RunTimeSortRunningAggregate()
    :
    mNumBuckets(0),
    mPreIncrement(false),
    mOutputFinalTotals(false),
    mInitializeTable(false)
  {
  }

public:
  METRAFLOW_DECL RunTimeSortRunningAggregate(const std::wstring& name, 
                                             const std::vector<RunTimeHashRunningAggregateInputSpec>& inputSpecs,
                                             const RecordMetadata& accumulatorMetadata,
                                             const std::vector<std::wstring>& accumulatorGroupByKeys,
                                             const std::wstring & initializerProgram,
                                             boost::int32_t numBuckets,
                                             bool preIncrement,
                                             bool outputFinalTotals,
                                             bool initializeTable);
  METRAFLOW_DECL ~RunTimeSortRunningAggregate();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeSortRunningAggregateActivation : public RunTimeOperatorActivationImpl<RunTimeSortRunningAggregate>
{
public:
  enum State {START, READ_INIT, READ_TABLE_INIT, READ_TABLE, WRITE_TABLE, READ_TABLE_DRAIN, WRITE_TABLE_DRAIN, WRITE_TABLE_BUFFER, WRITE_0, READ_0, WRITE_EOF_0};

private:
  // Activations for the inputs
  std::vector<RunTimeSortRunningAggregateInputSpecActivation> mInputSpecActivations;

  // Accessors for the output record
  std::vector<RunTimeSortKey> mAccumulatorGroupByKeys;

  // Accessors for the initialization table if it exists.
  std::vector<DataAccessor *> mInitializerAccessors;

  //
  // The MTSQL programs representing the initializer.
  // The MTSQL programs run against an environment that represents the concatenation
  // of the input record (the probe) and the matched accumulator (the table).
  // The initializer is invoked for the first record with a given group by key.
  // The accumulator is invoked for every record with a given group by key.
  // There are different accumulator programs for each input.
  //
  // Initializer
	MTSQLInterpreter* mInitializerInterpreter;
	MTSQLExecutable* mInitializerExe;
  Frame * mInitializerProbeFrame;
  Frame * mInitializerTableFrame;
  RecordActivationRecord * mInitializerProbeActivationRecord;
  RecordActivationRecord * mInitializerTableActivationRecord;
	DualCompileEnvironment * mInitializerEnv;
  DualRuntimeEnvironment * mInitializerRuntime;
 
  RunTimeSortRunningAggregateInputSpecActivation * mActiveInput;
  std::map<Endpoint *, RunTimeSortRunningAggregateInputSpecActivation *> mEndpointInputIndex;
  std::map<Endpoint *, RunTimeSortRunningAggregateInputSpecActivation *>::iterator mIt;
  State mState;
  boost::int64_t mProcessed;

  // Code for reading inputs in sorted order.
  PriorityQueue mPQ;
  std::vector<RunTimeSortKey>::iterator mSortKeyIt;
  std::vector<QueueElement *> mQueueElements;
  std::vector<QueueElement *>::iterator mQueueElementsIt;
  QueueElement * mCurrentQueueElement;

  // Debug monitoring
  MetraFlowLoggerPtr mLogger;
  boost::int64_t mTotalProcessed;
  boost::int32_t mTotalAccumulatorSize;

//   NonDeterministicInputMultiplexer mMultiplexer;
  MessagePtr mNullMessage;
  MessagePtr mOutputMessage;
  // Accumulator message either comes from an initializer table
  // or is newly created.
  MessagePtr mBuffer;
  // Last message read from table initialization input if any.
  MessagePtr mAccumulatorMessage;
public:
  METRAFLOW_DECL RunTimeSortRunningAggregateActivation(Reactor * reactor, 
                                                       partition_t partition, 
                                                       const RunTimeSortRunningAggregate * runTimeOperator);
  METRAFLOW_DECL ~RunTimeSortRunningAggregateActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

#endif
