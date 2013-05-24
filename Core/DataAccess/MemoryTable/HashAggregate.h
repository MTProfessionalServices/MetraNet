#ifndef __HASHAGGREGATE_H__
#define __HASHAGGREGATE_H__

#include "Scheduler.h"
#include "Multiplexer.h"
#include "SortMergeCollector.h"
#include "LogAdapter.h"

class CacheConsciousHashTable;
class CacheConsciousHashTableNonUniqueInsertIterator;
class CacheConsciousHashTableIteratorBase;
class CacheConsciousHashTableIterator;
class CacheConsciousHashTableScanIterator;
class MTSQLInterpreter;
class MTSQLExecutable;
class Frame;
class RecordActivationRecord;
class RecordCompileEnvironment;
class RecordRuntimeEnvironment;
class DualCompileEnvironment;
class DualRuntimeEnvironment;
class COdbcIdGenerator;
class COdbcLongIdGenerator;

typedef std::pair<std::wstring,std::wstring> NameMapping;

/**
 * Thrown in the type checking phase to indicate that a port doesn't have the expected record format
 */
class AggregateTableException : public std::logic_error
{
private:
  std::string CreateErrorString(const DesignTimeOperator& op, 
                                const Port& portA,
                                const RecordMetadata& tableMetadata);

public:
  METRAFLOW_DECL AggregateTableException(const DesignTimeOperator& op, 
                                        const Port& portA,
                                        const RecordMetadata& tableMetadata);
  METRAFLOW_DECL ~AggregateTableException();
};

class DesignTimeHashRunningAggregateInputSpec
{
public:
  friend class DesignTimeHashRunningAggregateInputSpecActivation;
  friend class DesignTimeSortRunningAggregateInputSpecActivation;
private:
  std::vector<std::wstring> mGroupByKeyNames;
  std::wstring mUpdateProgram;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_NVP(mGroupByKeyNames);
    ar & BOOST_SERIALIZATION_NVP(mUpdateProgram);
  }  
public:
  METRAFLOW_DECL DesignTimeHashRunningAggregateInputSpec();
  METRAFLOW_DECL DesignTimeHashRunningAggregateInputSpec(const std::vector<std::wstring>& groupByKeyNames,
                                                    const std::wstring& updateProgram);
  METRAFLOW_DECL ~DesignTimeHashRunningAggregateInputSpec();
  METRAFLOW_DECL void AddGroupByKey(const std::wstring& groupByKeyName);
  METRAFLOW_DECL void SetGroupByKeys(const std::vector<std::wstring>& groupByKeyNames);
  METRAFLOW_DECL const std::vector<std::wstring>&  GetGroupByKeys() const;
  METRAFLOW_DECL void SetUpdateProgram(const std::wstring& updateProgram);
  METRAFLOW_DECL const std::wstring&  GetUpdateProgram() const;
};

class DesignTimeHashRunningAggregate : public DesignTimeOperator
{
private:
  std::vector<DesignTimeHashRunningAggregateInputSpec> mInputSpecs;
  std::vector<NameMapping> mSumNames;
  std::vector<std::wstring> mGroupByKeys;
  std::vector<std::wstring> mDedupedGroupByKeys;
  std::wstring mCountName;
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

  static std::wstring GetMTSQLDatatype(DataAccessor * accessor);
  static PhysicalFieldType GetPhysicalFieldType(int ty);
  static void DeduplicateGroupByKeys(const std::vector<std::wstring>& groupByKeys,
                                     std::vector<std::wstring>& dedupedGroupByKeys);
  
public:
  // TODO: Support more general aggregation functions (and expressions).  I have hard coded this
  // to be summation (and avoided a parse).
  METRAFLOW_DECL DesignTimeHashRunningAggregate(int numInputs=1);
  METRAFLOW_DECL ~DesignTimeHashRunningAggregate();
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
  METRAFLOW_DECL void SetSums(const std::vector<NameMapping>& sums);
  METRAFLOW_DECL void SetCountName(const std::wstring& countName);
  METRAFLOW_DECL void AddSortKey(const DesignTimeSortKey& aKey);
  METRAFLOW_DECL void SetPreIncrement(bool preIncrement);
  METRAFLOW_DECL void SetOutputFinalTotals(bool outputFinalTotals);
  METRAFLOW_DECL void SetInitializeTable(bool initializeTable);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeHashRunningAggregate* clone(
                                                const std::wstring& name,
                                                std::vector<OperatorArg*>& args, 
                                                int nInputs, int nOutputs) const;
};

class RunTimeHashRunningAggregateInputSpec
{
public:
  friend class RunTimeHashRunningAggregateInputSpecActivation;
  friend class RunTimeSortRunningAggregateInputSpecActivation;
private:
  RecordMetadata mInput;
  RecordMerge mMerger;
  std::wstring mAccumulatorProgram;
  // Accessors for the input record
  std::vector<std::wstring> mInputGroupByKeyNames;
  // Sort key specifications
  std::vector<RunTimeSortKey> mSortKey;

  void FixupSortKeys();

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mInput);
    ar & BOOST_SERIALIZATION_NVP(mMerger);
    ar & BOOST_SERIALIZATION_NVP(mAccumulatorProgram);
    ar & BOOST_SERIALIZATION_NVP(mInputGroupByKeyNames);
    ar & BOOST_SERIALIZATION_NVP(mSortKey);
  } 

  METRAFLOW_DECL RunTimeHashRunningAggregateInputSpec()
  {
  }

public:
  METRAFLOW_DECL RunTimeHashRunningAggregateInputSpec(const RecordMetadata& input,
                                                 const RecordMerge& merger,
                                                 const std::wstring& accumulatorProgram,
                                                 const std::vector<std::wstring>& inputGroupByKeyNames,
                                                 const std::vector<RunTimeSortKey>& sortKey);
  METRAFLOW_DECL RunTimeHashRunningAggregateInputSpec(const RecordMetadata& input,
                                                 const std::wstring& accumulatorProgram,
                                                 const std::vector<std::wstring>& inputGroupByKeyNames,
                                                 const std::vector<RunTimeSortKey>& sortKey);
  METRAFLOW_DECL RunTimeHashRunningAggregateInputSpec(const RunTimeHashRunningAggregateInputSpec& rhs);
  METRAFLOW_DECL const RunTimeHashRunningAggregateInputSpec& operator=(const RunTimeHashRunningAggregateInputSpec& rhs);
  METRAFLOW_DECL ~RunTimeHashRunningAggregateInputSpec();
};

class RunTimeHashRunningAggregateInputSpecActivation
{
private:
  const RunTimeHashRunningAggregateInputSpec * mInputSpec;
  //
  // Generated stuff. Created in Start().
  //
  // Accessors for the input record
  std::vector<DataAccessor *> mInputGroupByKeys;
  // Hash table iterator
  CacheConsciousHashTableIterator * mIterator;
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
  METRAFLOW_DECL RunTimeHashRunningAggregateInputSpecActivation(const RunTimeHashRunningAggregateInputSpec * inputSpec);
  METRAFLOW_DECL ~RunTimeHashRunningAggregateInputSpecActivation();
  METRAFLOW_DECL void Start(const RecordMetadata& accumulator,                                                  
                            CacheConsciousHashTable& table,
                            MetraFlowLoggerPtr logger);
  METRAFLOW_DECL void Initialize(record_t inputMessage,
                                 record_t accumulator, 
                                 const std::vector<DataAccessor*>& accumulatorGroupByKeys);
  METRAFLOW_DECL void Update(record_t inputMessage, record_t accumulator);
  METRAFLOW_DECL const RecordMetadata& GetMetadata() const;
  METRAFLOW_DECL const RecordMerge& GetMerger() const;
  METRAFLOW_DECL void ExportSortKey(QueueElement& e);
  METRAFLOW_DECL CacheConsciousHashTableIterator* GetIterator();
};

class RunTimeHashRunningAggregate : public RunTimeOperator
{
public:
  friend class RunTimeHashRunningAggregateActivation;

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
  METRAFLOW_DECL RunTimeHashRunningAggregate()
    :
    mNumBuckets(0),
    mPreIncrement(false),
    mOutputFinalTotals(false),
    mInitializeTable(false)
  {
  }

public:
  METRAFLOW_DECL RunTimeHashRunningAggregate(const std::wstring& name, 
                                             const std::vector<RunTimeHashRunningAggregateInputSpec>& inputSpecs,
                                             const RecordMetadata& accumulatorMetadata,
                                             const std::vector<std::wstring>& accumulatorGroupByKeys,
                                             const std::wstring & initializerProgram,
                                             boost::int32_t numBuckets,
                                             bool preIncrement,
                                             bool outputFinalTotals,
                                             bool initializeTable);
  METRAFLOW_DECL ~RunTimeHashRunningAggregate();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeHashRunningAggregateActivation : public RunTimeOperatorActivationImpl<RunTimeHashRunningAggregate>
{
public:
  enum State {START, READ_INIT, READ_TABLE, WRITE_0, READ_0, WRITE_FINAL_TOTAL_0, WRITE_EOF_0};

private:
  // Activations for the inputs
  std::vector<RunTimeHashRunningAggregateInputSpecActivation> mInputSpecActivations;

  // Accessors for the output record
  std::vector<DataAccessor *> mAccumulatorGroupByKeys;

  // Hash table for matching input records to accumulators by group by keys 
  CacheConsciousHashTable * mTable;
  CacheConsciousHashTableNonUniqueInsertIterator * mInsertIterator;
  CacheConsciousHashTableScanIterator * mScanIterator;

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
 
  RunTimeHashRunningAggregateInputSpecActivation * mActiveInput;
  std::map<Endpoint *, RunTimeHashRunningAggregateInputSpecActivation *> mEndpointInputIndex;
  std::map<Endpoint *, RunTimeHashRunningAggregateInputSpecActivation *>::iterator mIt;
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
  MessagePtr mAccumulatorMessage;
public:
  METRAFLOW_DECL RunTimeHashRunningAggregateActivation(Reactor * reactor, 
                                                       partition_t partition, 
                                                       const RunTimeHashRunningAggregate * runTimeOperator);
  METRAFLOW_DECL ~RunTimeHashRunningAggregateActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeHashGroupBy : public DesignTimeOperator
{
private:
  std::vector<std::wstring> mGroupByKeyNames;
  std::vector<NameMapping> mGroupByNameMappings;
  std::vector<NameMapping> mSumNames;
  std::wstring mCountName;
  RecordMetadata * mAccumulator;

  int mNumBuckets;
  std::vector<std::wstring> mAccumulateProgram;
  std::wstring mInitializeProgram;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mGroupByKeyNames);
    ar & BOOST_SERIALIZATION_NVP(mGroupByNameMappings);
    ar & BOOST_SERIALIZATION_NVP(mSumNames);
    ar & BOOST_SERIALIZATION_NVP(mCountName);
    ar & BOOST_SERIALIZATION_NVP(mAccumulator);
    ar & BOOST_SERIALIZATION_NVP(mNumBuckets);
    ar & BOOST_SERIALIZATION_NVP(mAccumulateProgram);
    ar & BOOST_SERIALIZATION_NVP(mInitializeProgram);
  }  

  static std::wstring GetMTSQLDatatype(DataAccessor * accessor);
  static PhysicalFieldType GetPhysicalFieldType(int ty);
  
public:
  METRAFLOW_DECL DesignTimeHashGroupBy(boost::int32_t numInputs=1);
  METRAFLOW_DECL ~DesignTimeHashGroupBy();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL void AddGroupByKey(const std::wstring& groupByKey);
  METRAFLOW_DECL void SetGroupByKeys(const std::vector<std::wstring>& groupByKeys);
  METRAFLOW_DECL void SetInitializeProgram(const std::wstring& initializeProgram);
  METRAFLOW_DECL void SetUpdateProgram(const std::wstring& updateProgram);
  METRAFLOW_DECL void AddUpdateProgram(const std::wstring& updateProgram);
  METRAFLOW_DECL void SetNumBuckets(boost::int32_t numBuckets);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeHashGroupBy* clone(
                                       const std::wstring& name,
                                       std::vector<OperatorArg*>& args, 
                                       int nExtraInputs, int nExtraOutputs) const;

  /** Is a single occurrence of an input port named "input", not "input(0)" */
  METRAFLOW_DECL virtual bool isSimplifiedInputNamingUsed() { return true; }
};

class RunTimeHashGroupByInputSpec
{
public: 
  friend class RunTimeHashGroupByInputSpecActivation;
private:
  RecordMetadata mInput;
  std::wstring mAccumulatorProgram;
  // Accessors for the input record
  std::vector<std::wstring> mInputGroupByKeyNames;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mInput);
    ar & BOOST_SERIALIZATION_NVP(mAccumulatorProgram);
    ar & BOOST_SERIALIZATION_NVP(mInputGroupByKeyNames);
  } 

  METRAFLOW_DECL RunTimeHashGroupByInputSpec()
  {
  }

public:
  METRAFLOW_DECL RunTimeHashGroupByInputSpec(const RecordMetadata& input,
                                             const std::wstring& accumulatorProgram,
                                             const std::vector<std::wstring>& inputGroupByKeyNames);
  METRAFLOW_DECL ~RunTimeHashGroupByInputSpec();
};

class RunTimeHashGroupByInputSpecActivation
{
private:
  const RunTimeHashGroupByInputSpec * mInputSpec;
  //
  // Generated stuff. Created in Start().
  //
  // Accessors for the input record
  std::vector<DataAccessor *> mInputGroupByKeys;
  // Hash table iterator
  CacheConsciousHashTableIterator * mIterator;
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
  METRAFLOW_DECL RunTimeHashGroupByInputSpecActivation(const RunTimeHashGroupByInputSpec * inputSpec);
  METRAFLOW_DECL ~RunTimeHashGroupByInputSpecActivation();
  METRAFLOW_DECL void Start(const RecordMetadata& accumulator,                                                  
                            CacheConsciousHashTable& table,
                            MetraFlowLoggerPtr logger);
  METRAFLOW_DECL void Initialize(record_t inputMessage,
                                 record_t accumulator, 
                                 const std::vector<DataAccessor*>& accumulatorGroupByKeys);
  METRAFLOW_DECL void Update(record_t inputMessage, record_t accumulator);
  METRAFLOW_DECL const RecordMetadata& GetMetadata() const;
  METRAFLOW_DECL CacheConsciousHashTableIterator* GetIterator();
};

class RunTimeHashGroupBy : public RunTimeOperator
{
public:
  friend class RunTimeHashGroupByActivation;

private:
  // group by keys for the table.
  std::vector<std::wstring> mGroupByKeys;
  std::vector<RunTimeHashGroupByInputSpec> mInputSpecs;
  RecordMetadata mAccumulator;
  std::wstring mInitializerProgram;
  boost::int32_t mNumBuckets;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mGroupByKeys);
    ar & BOOST_SERIALIZATION_NVP(mInputSpecs);
    ar & BOOST_SERIALIZATION_NVP(mAccumulator);
    ar & BOOST_SERIALIZATION_NVP(mInitializerProgram);
    ar & BOOST_SERIALIZATION_NVP(mNumBuckets);
  } 
  METRAFLOW_DECL RunTimeHashGroupBy()
    :
    mNumBuckets(0)
  {
  }

public:
  METRAFLOW_DECL RunTimeHashGroupBy(const std::wstring& name, 
                                    const std::vector<RunTimeHashGroupByInputSpec>& inputSpecs,
                                    const RecordMetadata& accumulatorMetadata,
                                    const std::vector<std::wstring>& groupByKeys,
                                    const std::wstring & initializerProgram,
                                    boost::int32_t numBuckets);
  METRAFLOW_DECL ~RunTimeHashGroupBy();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeHashGroupByActivation : public RunTimeOperatorActivationImpl<RunTimeHashGroupBy>
{
public:
  enum State { START, READ_0, WRITE_0, WRITE_EOF_0 };

private:
  // Activations for input specs
  std::vector<RunTimeHashGroupByInputSpecActivation> mInputSpecActivations;
  // Accessors for the output record
  std::vector<DataAccessor *> mAccumulatorGroupByKeys;
//   std::vector<DataAccessor *> mAccumulatorTarget;
//   DataAccessor * mCount;

  // Hash table for matching input records to accumulators by group by keys 
  CacheConsciousHashTable * mTable;
  CacheConsciousHashTableNonUniqueInsertIterator * mInsertIterator;
  CacheConsciousHashTableScanIterator * mScanIterator;

  //
  // The MTSQL programs representing the initializer and accumulator predicate.
  // The MTSQL programs run against an environment that represents the concatenation
  // of the input record (the probe) and the matched accumulator (the table).
  // The initializer is invoked for the first record with a given group by key.
  // The accumulator is invoked for every record with a given group by key.
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

  NonDeterministicInputMultiplexer mMultiplexer;
 
  // Code for binding an input to the aggregate state.
  RunTimeHashGroupByInputSpecActivation * mActiveInput;
  std::map<Endpoint *, RunTimeHashGroupByInputSpecActivation *> mEndpointInputIndex;
  State mState;
  boost::int64_t mProcessed;

  MessagePtr mInputMessage;
  MessagePtr mOutputMessage;
public:
  METRAFLOW_DECL RunTimeHashGroupByActivation(Reactor * reactor, 
                                              partition_t partition, 
                                              const RunTimeHashGroupBy * runTimeOperator);
  METRAFLOW_DECL ~RunTimeHashGroupByActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

/**
 * TODO: Eliminate redundant specification in predicate and generate from
 * input metadata.
 * E.g. should just be able to input a predicate like "@a <> @b" and have
 * the CREATE FUNCTION f (@a INTEGER @b INTEGER) RETURNS BOOLEAN
 * AS
 * RETURN ...
 * automatically generated.  Same is true for switch, hash join residuals (maybe others).
 */
class DesignTimeFilter : public DesignTimeOperator
{
private:
  std::wstring mProgram;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mProgram);
  }  
public:
  METRAFLOW_DECL DesignTimeFilter();
  METRAFLOW_DECL ~DesignTimeFilter();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL const std::wstring& GetProgram() const
  {
    return mProgram;
  }
  METRAFLOW_DECL void SetProgram(const std::wstring& program)
  {
    mProgram = program;
  }

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeFilter* clone(
                                  const std::wstring& name,
                                  std::vector<OperatorArg*>& args, 
                                  int nInputs, int nOutputs) const;
};

class RunTimeFilter : public RunTimeOperator
{
public:
  friend class RunTimeFilterActivation;
private:
  RecordMetadata mInputMetadata;
  std::wstring mProgram;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mInputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mProgram);
  } 
  METRAFLOW_DECL RunTimeFilter();

public:
  METRAFLOW_DECL RunTimeFilter(const std::wstring& name, 
                              const RecordMetadata& inputMetadata,
                              const std::wstring& program);

  METRAFLOW_DECL ~RunTimeFilter();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeFilterActivation : public RunTimeOperatorActivationImpl<RunTimeFilter>
{
private:
  // Runtime values
  enum State { READ_0, WRITE_OUTPUT_0, WRITE_EOF_0 };
  State mState;
  MessagePtr mInputMessage;
  // Program interpreter stuff
	MTSQLInterpreter* mInterpreter;
	MTSQLExecutable* mExe;
	RecordCompileEnvironment * mEnv;
  RecordRuntimeEnvironment * mRuntime;
  MetraFlowLoggerPtr mLogger;
public:
  METRAFLOW_DECL RunTimeFilterActivation(Reactor * reactor, 
                                         partition_t partition, 
                                         const RunTimeFilter * runTimeOperator);

  METRAFLOW_DECL ~RunTimeFilterActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeSwitch : public DesignTimeOperator
{
private:
  std::wstring mProgram;
  boost::int32_t mNumOutputs;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mProgram);
    ar & BOOST_SERIALIZATION_NVP(mNumOutputs);
  }  
  METRAFLOW_DECL DesignTimeSwitch();
public:
  METRAFLOW_DECL DesignTimeSwitch(boost::int32_t numOutputs);
  METRAFLOW_DECL ~DesignTimeSwitch();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL const std::wstring& GetProgram() const
  {
    return mProgram;
  }
  METRAFLOW_DECL void SetProgram(const std::wstring& program)
  {
    mProgram = program;
  }

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeSwitch* clone(
                                  const std::wstring& name,
                                  std::vector<OperatorArg*>& args, 
                                  int nInputs, int nOutputs) const;
};

class RunTimeSwitch : public RunTimeOperator
{
public:
  friend class RunTimeSwitchActivation;
private:
  RecordMetadata mInputMetadata;
  std::wstring mProgram;
  boost::int32_t mNumOutputs;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mInputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mProgram);
    ar & BOOST_SERIALIZATION_NVP(mNumOutputs);
  } 
  METRAFLOW_DECL RunTimeSwitch();

public:
  METRAFLOW_DECL RunTimeSwitch(const std::wstring& name, 
                               const RecordMetadata& inputMetadata,
                               const std::wstring& program,
                               boost::int32_t numOutputs);

  METRAFLOW_DECL ~RunTimeSwitch();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeSwitchActivation : public RunTimeOperatorActivationImpl<RunTimeSwitch>
{
public:
  friend class RunTimeSwitchActivation;
private:
  // Runtime values
  enum State { READ_0, WRITE_OUTPUT_0, WRITE_EOF_0, WRITE_GROUP_CHANGE_0 };
  State mState;
  boost::int32_t mNextOutput;
  MessagePtr mInputMessage;
  // Program interpreter stuff
	MTSQLInterpreter* mInterpreter;
	MTSQLExecutable* mExe;
	RecordCompileEnvironment * mEnv;
  RecordRuntimeEnvironment * mRuntime;
  MetraFlowLoggerPtr mLogger;
public:
  METRAFLOW_DECL RunTimeSwitchActivation(Reactor * reactor, 
                                         partition_t partition, 
                                         const RunTimeSwitch * runTimeOperator);

  METRAFLOW_DECL ~RunTimeSwitchActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeProjection : public DesignTimeOperator
{
private:
  std::vector<std::wstring> mProjection;
  bool mIsComplement;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mProjection);
    ar & BOOST_SERIALIZATION_NVP(mIsComplement);
  }  
public:
  METRAFLOW_DECL DesignTimeProjection();
  METRAFLOW_DECL ~DesignTimeProjection();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL void SetProjection(const std::vector<std::wstring>& projection, bool isComplement=false);
  METRAFLOW_DECL void AddColumn(const std::wstring& col);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeProjection* clone(
                                      const std::wstring& name,
                                      std::vector<OperatorArg*>& args, 
                                      int nInputs, int nOutputs) const;
};

class RunTimeProjection : public RunTimeOperator
{
public:
  friend class RunTimeProjectionActivation;
private:
  RecordMetadata mInputMetadata;
  RecordMetadata mOutputMetadata;
  RecordProjection mProjection;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mInputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mOutputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mProjection);
  } 
  METRAFLOW_DECL RunTimeProjection();

public:
  METRAFLOW_DECL RunTimeProjection(const std::wstring& name, 
                          const RecordMetadata& inputMetadata,
                          const RecordMetadata& outputMetadata,
                          const RecordProjection& projection);

  METRAFLOW_DECL ~RunTimeProjection();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeProjectionActivation : public RunTimeOperatorActivationImpl<RunTimeProjection>
{
private:
  // Runtime values
  enum State { READ_0, WRITE_OUTPUT_0, WRITE_EOF_0 };
  State mState;
  MessagePtr mInputMessage;
  MessagePtr mOutputMessage;
public:
  METRAFLOW_DECL RunTimeProjectionActivation(Reactor * reactor, 
                                             partition_t partition, 
                                             const RunTimeProjection * runTimeOperator);
  METRAFLOW_DECL ~RunTimeProjectionActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

#ifdef WIN32
/**
 * This component is responsible for assigning session set and message identifiers
 * to a stream of compounds.  
 * 
 * Assumes that the parent stream is grouped (not necessarily sorted) on id_sess
 * and that children are compatibly group on id_parent_sess.  In the case in which
 * there are no children, no assumption exists on the parent.
 *
 * The builder also creates "bundles" of messages that are used as units of 
 * transactional commit.
 */
class DesignTimeSessionSetBuilder : public DesignTimeOperator
{
private:
  RecordMerge * mParentMerger;
  std::vector<RecordMerge> mChildMerger;
  RecordMetadata mComputedColumns;
  boost::int32_t mTargetMessageSize;
  boost::int32_t mTargetCommitSize;
  std::vector<boost::uint8_t> mCollectionID;
  std::vector<std::wstring> mKeys;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mParentMerger);
    ar & BOOST_SERIALIZATION_NVP(mChildMerger);
    ar & BOOST_SERIALIZATION_NVP(mComputedColumns);
    ar & BOOST_SERIALIZATION_NVP(mTargetMessageSize);
    ar & BOOST_SERIALIZATION_NVP(mCollectionID);
    ar & BOOST_SERIALIZATION_NVP(mKeys);
  }  
  METRAFLOW_DECL DesignTimeSessionSetBuilder();

protected:
  METRAFLOW_DECL void SetKeys(const std::vector<std::wstring>& keys);

public:
  METRAFLOW_DECL DesignTimeSessionSetBuilder(boost::int32_t numChildren);
  METRAFLOW_DECL DesignTimeSessionSetBuilder(boost::int32_t numChildren, boost::int32_t targetMessageSize, boost::int32_t targetCommitSize=1000000);
  METRAFLOW_DECL ~DesignTimeSessionSetBuilder();
  // HACK: Only here because MTSQL doesn't support BINARY.
  METRAFLOW_DECL void SetCollectionID(const std::vector<boost::uint8_t>& collectionID);
  METRAFLOW_DECL void SetParentKey(const std::wstring& parentKey);
  METRAFLOW_DECL void SetChildKeys(const std::vector<std::wstring>& childKeys);
  METRAFLOW_DECL void AddChildKey(const std::wstring& childKey);
  METRAFLOW_DECL void SetTargetMessageSize(boost::int32_t targetMessageSize);
  METRAFLOW_DECL void SetTargetCommitSize(boost::int32_t targetCommitSize);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeSessionSetBuilder* clone(
                                             const std::wstring& name,
                                             std::vector<OperatorArg*>& args, 
                                             int nInputs, int nOutputs) const;
};

class RunTimeSessionSetBuilder : public RunTimeOperator
{
public:
  friend class RunTimeSessionSetBuilderActivation;
private:
  RecordMetadata mParentMetadata;
  std::vector<RecordMetadata> mChildMetadata;
  RecordMerge mParentMerger;
  std::vector<RecordMerge> mChildMerger;
  RecordMetadata mComputedColumns;
  RecordMetadata mParentChildSummaryMetadata;
  RecordMetadata mMessageSummaryMetadata;
  RecordMetadata mTransactionSummaryMetadata;
  boost::int32_t mTargetMessageSize;
  boost::int32_t mTargetCommitSize;
  std::vector<boost::uint8_t> mCollectionID;
  std::vector<std::wstring> mKeys;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mParentMetadata);
    ar & BOOST_SERIALIZATION_NVP(mChildMetadata);
    ar & BOOST_SERIALIZATION_NVP(mParentMerger);
    ar & BOOST_SERIALIZATION_NVP(mChildMerger);
    ar & BOOST_SERIALIZATION_NVP(mComputedColumns);
    ar & BOOST_SERIALIZATION_NVP(mParentChildSummaryMetadata);
    ar & BOOST_SERIALIZATION_NVP(mMessageSummaryMetadata);
    ar & BOOST_SERIALIZATION_NVP(mTransactionSummaryMetadata);
    ar & BOOST_SERIALIZATION_NVP(mTargetMessageSize);
    ar & BOOST_SERIALIZATION_NVP(mTargetCommitSize);
    ar & BOOST_SERIALIZATION_NVP(mCollectionID);
    ar & BOOST_SERIALIZATION_NVP(mKeys);
  } 
  METRAFLOW_DECL RunTimeSessionSetBuilder();

public:
  METRAFLOW_DECL RunTimeSessionSetBuilder(const std::wstring& name, 
                                     const RecordMetadata& parentMetadata,
                                     const RecordMerge& parentMerger,
                                     const std::vector<RecordMetadata>& childMetadata,
                                     const std::vector<RecordMerge>& childMerger,
                                     const RecordMetadata & computedColumns,
                                     const RecordMetadata & parentChildSummaryMetadata,
                                     const RecordMetadata & messageSummaryMetadata,
                                     const RecordMetadata & transactionSummaryMetadata,
                                     boost::int32_t targetMessageSize,
                                     boost::int32_t targetCommitSize,
                                     const std::vector<boost::uint8_t>& collectionID,
                                     const std::vector<std::wstring>& keys);

  METRAFLOW_DECL ~RunTimeSessionSetBuilder();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};
class RunTimeSessionSetBuilderActivation : public RunTimeOperatorActivationImpl<RunTimeSessionSetBuilder>
{
private:
  // Runtime values
  struct Accessor
  {
    // Key accessor into input record
    DataAccessor * Key;
    // Data accessors into output/merged record
    DataAccessor * SourceSessAccessor;
    DataAccessor * ParentSourceSessAccessor;
    DataAccessor * SessionSetAccessor;
    DataAccessor * MessageAccessor;
    DataAccessor * CommitAccessor;
    DataAccessor * CollectionAccessor;
  
    boost::int32_t SessionSetId;
    boost::int32_t NumMessageRecords;
    boost::int32_t NumTransactionRecords;
    MessagePtr Message;
    bool IsEOF;
    Accessor()
      :
      Key(NULL),
      SourceSessAccessor(NULL),
      ParentSourceSessAccessor(NULL),
      SessionSetAccessor(NULL),
      MessageAccessor(NULL),
      CommitAccessor(NULL),
      CollectionAccessor(NULL),
      SessionSetId(-1),
      NumMessageRecords(0),
      NumTransactionRecords(0),
      Message(NULL),
      IsEOF(false)
    {
    }
    Accessor(DataAccessor * key,
             DataAccessor * sourceSessAccessor,
             DataAccessor * parentSourceSessAccessor,
             DataAccessor * sessionSetAccessor,
             DataAccessor * messageAccessor,
             DataAccessor * commitAccessor,
             DataAccessor * collectionAccessor
      )
      :
      Key(key),
      SourceSessAccessor(sourceSessAccessor),
      ParentSourceSessAccessor(parentSourceSessAccessor),
      SessionSetAccessor(sessionSetAccessor),
      MessageAccessor(messageAccessor),
      CommitAccessor(commitAccessor),
      CollectionAccessor(collectionAccessor),
      SessionSetId(-1),
      NumMessageRecords(0),
      NumTransactionRecords(0),
      Message(NULL),
      IsEOF(false)
    {
    }
  };

  enum State { START, READ_0, WRITE_0, WRITE_EOF_0, READ_1, WRITE_1, WRITE_EOF_1, READ_2, WRITE_EOF_2, 
               WRITE_PARENTCHILD_SUMMARY_0, WRITE_PARENTCHILD_SUMMARY_1, WRITE_PARENTCHILD_SUMMARY_EOF, 
               WRITE_MESSAGE_SUMMARY_0, WRITE_MESSAGE_SUMMARY_1, WRITE_MESSAGE_SUMMARY_EOF,
               WRITE_TRANSACTION_SUMMARY_0, WRITE_TRANSACTION_SUMMARY_1, WRITE_TRANSACTION_SUMMARY_EOF 
  };
  State mState;
  std::size_t mNextChild;
  Accessor mParent;
  std::vector<Accessor> mChildren;
  boost::int32_t mMessageId;
  boost::int32_t mCurrentMessageSize;
  boost::int32_t mCommitId;
  boost::int32_t mCurrentCommitSize;
  COdbcLongIdGenerator * mLongIdGenerator;
  COdbcIdGenerator * mIdGenerator;
  MessagePtr mNullBuffer;
  MessagePtr mOutputMessage;
  boost::uint8_t mParentSourceSess[16];

  MessagePtr OnParentChildChange(boost::int32_t idx);
  MessagePtr OnMessageChange();
  MessagePtr OnCommitChange();
  void ProcessRecord(const RecordMerge& merger, 
                     const RecordMetadata& metadata, 
                     RunTimeSessionSetBuilderActivation::Accessor& accessor,
                     bool isParent);

public:
  METRAFLOW_DECL RunTimeSessionSetBuilderActivation(Reactor * reactor, 
                                                    partition_t partition, 
                                                    const RunTimeSessionSetBuilder * runTimeOperator);

  METRAFLOW_DECL ~RunTimeSessionSetBuilderActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};
#endif

class DesignTimePrint : public DesignTimeOperator
{
private:
  /** Limit printing to this many records */
  boost::int64_t mNumToPrint;

  /** Restrict printing to these items */
  std::wstring mProgram;

  /** Label before each record printed. */
  std::wstring mLabel;

  /** Separates fields */
  std::wstring mFieldSeparator;

  /** Separates field name from field value*/
  std::wstring mValueSeparator;

  /** If true, only logs to file not to standard out */
  bool mLogFileOnly;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mNumToPrint);
    ar & BOOST_SERIALIZATION_NVP(mProgram);
    ar & BOOST_SERIALIZATION_NVP(mLabel);
    ar & BOOST_SERIALIZATION_NVP(mFieldSeparator);
    ar & BOOST_SERIALIZATION_NVP(mValueSeparator);
    ar & BOOST_SERIALIZATION_NVP(mLogFileOnly);
  }  
public:
  METRAFLOW_DECL DesignTimePrint();
  METRAFLOW_DECL ~DesignTimePrint();
  METRAFLOW_DECL void SetNumToPrint(boost::int64_t numToPrint);

  /**
   * Get filter program used to select records for printing. 
   */
  METRAFLOW_DECL const std::wstring& GetProgram() const
  {
    return mProgram;
  }
  /**
   * Set filter program used to select records for printing. 
   */
  METRAFLOW_DECL void SetProgram(const std::wstring& program)
  {
    mProgram = program;
  }

  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimePrint* clone(
                                 const std::wstring& name,
                                 std::vector<OperatorArg*>& args, 
                                 int nInputs, int nOutputs) const;
};

class RunTimePrint : public RunTimeOperator
{
public:
  friend class RunTimePrintActivation;
private:
  RecordMetadata mMetadata;
  boost::int64_t mNumToPrint;
  std::wstring mProgram;
  std::string mLabel;
  std::wstring mFieldSeparator;
  std::wstring mValueSeparator;
  bool mLogFileOnly;
  RecordPrinter mPrinter;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
    ar & BOOST_SERIALIZATION_NVP(mNumToPrint);
    ar & BOOST_SERIALIZATION_NVP(mProgram);
    ar & BOOST_SERIALIZATION_NVP(mPrinter);
  } 
  METRAFLOW_DECL RunTimePrint()
    :
    mNumToPrint(0LL)
  {
  }
public:
  METRAFLOW_DECL RunTimePrint(const std::wstring& name, 
                              const LogicalRecord& logicalRecord,
                              const RecordMetadata& metadata,
                              boost::int64_t numToPrint,
                              const std::string& label,
                              const std::wstring& fieldSeparator,
                              const std::wstring& valueSepartor,
                              bool logFileOnly,
                              const std::wstring& program);

  METRAFLOW_DECL ~RunTimePrint();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimePrintActivation : public RunTimeOperatorActivationImpl<RunTimePrint>
{
private:
  // Runtime values
  enum State { START, READ_0, WRITE_0 };
  State mState;
  MessagePtr mMessage;
  boost::int64_t mNumPrinted;

  // Program interpreter stuff
	MTSQLInterpreter* mInterpreter;
	MTSQLExecutable* mExe;
	RecordCompileEnvironment * mEnv;
  RecordRuntimeEnvironment * mRuntime;
  MetraFlowLoggerPtr mLogger;
public:
  METRAFLOW_DECL RunTimePrintActivation(Reactor * reactor, 
                                        partition_t partition, 
                                        const RunTimePrint * runTimeOperator);

  METRAFLOW_DECL ~RunTimePrintActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeSortMerge : public DesignTimeOperator
{
public:
  METRAFLOW_DECL DesignTimeSortMerge(boost::int32_t numInputs);
  METRAFLOW_DECL ~DesignTimeSortMerge();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL void AddSortKey(const DesignTimeSortKey & aKey);
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeSortMerge* clone(
                                     const std::wstring& name,
                                     std::vector<OperatorArg*>& args, 
                                     int nInputs, int nOutputs) const;
		
private: 
  //datastructure to store the keys
  std::vector<DesignTimeSortKey> mSortKey;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mSortKey);
  }  
  METRAFLOW_DECL DesignTimeSortMerge();
};

class DesignTimeUnroll : public DesignTimeOperator
{
private:
  std::wstring mCountColumn;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mCountColumn);
  }  

public:
  METRAFLOW_DECL DesignTimeUnroll();
  METRAFLOW_DECL ~DesignTimeUnroll();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL const std::wstring& GetCount() const
  {
    return mCountColumn;
  }
  METRAFLOW_DECL void SetCount(const std::wstring& countColumn)
  {
    mCountColumn = countColumn;
  }

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeUnroll* clone(
                                  const std::wstring& name,
                                  std::vector<OperatorArg*>& args, 
                                  int nInputs, int nOutputs) const;
};

class RunTimeUnroll : public RunTimeOperator
{
public:
  friend class RunTimeUnrollActivation;
private:
  RecordMetadata mInputMetadata;
  std::wstring mCountColumn;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mInputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mCountColumn);
  } 
  METRAFLOW_DECL RunTimeUnroll();

public:
  METRAFLOW_DECL RunTimeUnroll(const std::wstring& name, 
                          const RecordMetadata& inputMetadata,
                          const std::wstring& countColumn);

  METRAFLOW_DECL ~RunTimeUnroll();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeUnrollActivation : public RunTimeOperatorActivationImpl<RunTimeUnroll>
{
private:
  // Runtime values
  enum State { READ_0, WRITE_OUTPUT_0, WRITE_EOF_0 };
  State mState;
  MessagePtr mInputMessage;
  MessagePtr mOutputMessage;
  DataAccessor * mCountAccessor;
  boost::int32_t mOutputCount;
public:
  METRAFLOW_DECL RunTimeUnrollActivation(Reactor * reactor, 
                                         partition_t partition, 
                                         const RunTimeUnroll * runTimeOperator);

  METRAFLOW_DECL ~RunTimeUnrollActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeAssertSortOrder : public DesignTimeOperator
{
	public:
		METRAFLOW_DECL DesignTimeAssertSortOrder();
		METRAFLOW_DECL ~DesignTimeAssertSortOrder();
		METRAFLOW_DECL void type_check();
		METRAFLOW_DECL void AddSortKey(const DesignTimeSortKey& aKey);
		METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

    /** Handle the given operator argument specifying operator behavior. */
    METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

    /** Clone the initial configured state of an operator. */
    METRAFLOW_DECL virtual DesignTimeAssertSortOrder* clone(
                                             const std::wstring& name,
                                             std::vector<OperatorArg*>& args, 
                                             int nInputs, int nOutputs) const;
		
	private: 
		//datastructure to store the keys
		std::vector<DesignTimeSortKey> mSortKey;

		//
		// Serialization support
		//
		friend class boost::serialization::access;
		template<class Archive>
		void serialize(Archive & ar, const unsigned int version) 
		{
			ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
			ar & BOOST_SERIALIZATION_NVP(mSortKey);
		}  
};

class RunTimeAssertSortOrder : public RunTimeOperator
{
public:
  friend class RunTimeAssertSortOrderActivation;
private:
  RecordMetadata mInput;
  std::vector<RunTimeSortKey> mSortKey;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mInput);
    ar & BOOST_SERIALIZATION_NVP(mSortKey);
  } 
  METRAFLOW_DECL RunTimeAssertSortOrder();

public:
  METRAFLOW_DECL RunTimeAssertSortOrder(const std::wstring& name, 
                          const RecordMetadata& inputMetadata,
                          const std::vector<RunTimeSortKey>& sortKey);

  METRAFLOW_DECL ~RunTimeAssertSortOrder();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeAssertSortOrderActivation : public RunTimeOperatorActivationImpl<RunTimeAssertSortOrder>
{
private:
  void ExportSortKey(const_record_t buffer, SortKeyBuffer& sortKeyBuffer);
  void CreateGroupChangeRecord(const_record_t buffer, record_t groupChangeBuffer);
  
  // Runtime values
  enum State { START, READ_0, WRITE_0, WRITE_GROUP_CHANGE_0, WRITE_EOF_0 };
  State mState;
  MessagePtr mGroupChangeMessage;
  MessagePtr mInputMessage;
  SortKeyBuffer * mBuffers[2];
  boost::int32_t mCurrentBuffer;
  // Counter till the next group change message to be generated.
  boost::int32_t mNextGroupChange;
  // Since we can't use stack, put compare result here
  boost::int32_t mCompareResult;
public:
  METRAFLOW_DECL RunTimeAssertSortOrderActivation(Reactor * reactor, 
                                                  partition_t partition, 
                                                  const RunTimeAssertSortOrder * runTimeOperator);
  METRAFLOW_DECL ~RunTimeAssertSortOrderActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

/**
 * Computes aggregate functions over a sorted stream of records.
 * The SortGroupBy operator calculates aggregate functions over a single
 * input record stream.  It produces an output record stream whose field content comprises
 * the configured group by keys and the computed aggregate expressions.
 */
class DesignTimeSortGroupBy : public DesignTimeOperator
{
private:
  std::vector<DesignTimeSortKey> mGroupByKeys;
  RecordMetadata * mAccumulator;
  RecordMerge * mMerger;
  RecordProjection * mProjection;
  RecordMetadata * mAccumulatorNoGroupByKeys;
  std::wstring mAccumulateProgram;
  std::wstring mInitializeProgram;

  /**
   * Controls the mode whereby the operator buffers all contributions to the
   * group by calculation and then joins the aggregate function values to each
   * of the contributors.
   */
  bool mCopyToAll;

  static std::wstring GetMTSQLDatatype(DataAccessor * accessor);
  static PhysicalFieldType GetPhysicalFieldType(int ty);
  
public:
  /**
   * Default constructor 
   */
  METRAFLOW_DECL DesignTimeSortGroupBy();
  /**
   * Destructor
   */
  METRAFLOW_DECL ~DesignTimeSortGroupBy();
  /**
   * Type check operator.  
   * Output of the operator includes the group by keys and the aggregate expression values.
   * @exception MissingFieldException Thrown if group by keys do not exist in the input.
   * @exception MTSQLException Thrown if initializer program or update program have syntax errors.
   */
  METRAFLOW_DECL void type_check();
  /**
   * Create a run time operator for the physical plan.
   * @return A RunTimeSortGroupBy operator.
   */
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /**
   * Set the group by keys for the operator.
   * Overwrites any existing group by key configuration.
   * Group by keys must support sorting.
   * @param groupByKeys The set of names of key fields to group by.
   */
  METRAFLOW_DECL void SetGroupByKeys(const std::vector<std::wstring>& groupByKeys);
  /**
   * Add a group by key to the current group by key list.
   * @todo Throw an exception if there are duplicate key names in the group by list?
   */
  METRAFLOW_DECL void AddGroupByKey(const DesignTimeSortKey& groupByKey);
  /**
   * Set an MTSQL program used to initialize aggregate variables when a new group by key is seen.
   * @todo Support configuration by specification of aggregate function expressions.
   */
  METRAFLOW_DECL void SetInitializeProgram(const std::wstring& initializeProgram);
  /**
   * Set an MTSQL program used to update aggregate variables from an input record.
   * @todo Support configuration by specification of aggregate function expressions.
   */
  METRAFLOW_DECL void SetUpdateProgram(const std::wstring& updateProgram);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeSortGroupBy* clone(
                                       const std::wstring& name,
                                       std::vector<OperatorArg*>& args, 
                                       int nInputs, int nOutputs) const;
};

class RunTimeSortGroupBy : public RunTimeOperator
{
public:
  friend class RunTimeSortGroupByActivation;

private:
  // first is probe, second is table
  std::vector<RunTimeSortKey> mGroupByKeys;
  RecordMetadata mInput;
  RecordMetadata mAccumulator;
  std::wstring mInitializerProgram;
  std::wstring mAccumulatorProgram;
  bool mCopyToAll;
  /**
   * If mCopyToAll is true then we need to strip off the group by keys
   * from the accumulator.
   */
  RecordMetadata mAccumulatorNoGroupByKeys;
  /**
   * If mCopyToAll is true then our output is a join of the group by 
   * and the input that contributed to it.
   */
  RecordMerge mMerger;
  /**
   * If mCopyToAll is true then we need to project the accumulator (which has group by keys)
   * onto the aggregate outputs without the group by fields.
   */
  RecordProjection mProjection;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mInput);
    ar & BOOST_SERIALIZATION_NVP(mAccumulator);
    // Serialize group by keys to avoid pointer conflict since
    // these keys contain pointers to data allocated in the metadata objects
    ar & BOOST_SERIALIZATION_NVP(mGroupByKeys);
    ar & BOOST_SERIALIZATION_NVP(mInitializerProgram);
    ar & BOOST_SERIALIZATION_NVP(mAccumulatorProgram);
    ar & BOOST_SERIALIZATION_NVP(mCopyToAll);
    ar & BOOST_SERIALIZATION_NVP(mAccumulatorNoGroupByKeys);
    ar & BOOST_SERIALIZATION_NVP(mMerger);
    ar & BOOST_SERIALIZATION_NVP(mProjection);
  } 
  METRAFLOW_DECL RunTimeSortGroupBy();

public:
  METRAFLOW_DECL RunTimeSortGroupBy(const std::wstring& name, 
                                    const RecordMetadata& accumulatorMetadata,
                                    const RecordMetadata& inputMetadata,
                                    const std::vector<RunTimeSortKey>& groupByKeys,
                                    const std::wstring & initializerProgram,
                                    const std::wstring & accumulatorProgram,
                                    bool copyToAll,
                                    const RecordMetadata& accumulatorNoGroupByKeys,
                                    const RecordMerge & recordMerger,
                                    const RecordProjection & projection);
  METRAFLOW_DECL ~RunTimeSortGroupBy();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeSortGroupByActivation : public RunTimeOperatorActivationImpl<RunTimeSortGroupBy>
{
public:
  enum State { START, READ_FIRST_0, READ_0, WRITE_0, WRITE_LAST_0, WRITE_COPY_ALL_0, WRITE_EOF_0 };

private:
  // Accessors for the input record
  std::vector<DataAccessor *> mInputGroupByKeys;
//   std::vector<DataAccessor *> mAccumulatorSource;
  // Accessors for the output record
  std::vector<DataAccessor *> mAccumulatorGroupByKeys;
//   std::vector<DataAccessor *> mAccumulatorTarget;
//   DataAccessor * mCount;

  // Two Sort Key buffers. One stores the current
  // key, the other stores the value of the current record.
  // Technically we don't require sortedness of the input,
  // only groupedness.
  SortKeyBuffer* mBuffer[2];
  bool mCurrentBuffer;

  //
  // The MTSQL programs representing the initializer and accumulator predicate.
  // The MTSQL programs run against an environment that represents the concatenation
  // of the input record (the probe) and the matched accumulator (the table).
  // The initializer is invoked for the first record with a given group by key.
  // The accumulator is invoked for every record with a given group by key.
  //
  // Accumulator
	MTSQLInterpreter* mAccumulatorInterpreter;
	MTSQLExecutable* mAccumulatorExe;
  Frame * mAccumulatorProbeFrame;
  Frame * mAccumulatorTableFrame;
  RecordActivationRecord * mAccumulatorProbeActivationRecord;
  RecordActivationRecord * mAccumulatorTableActivationRecord;
	DualCompileEnvironment * mAccumulatorEnv;
  DualRuntimeEnvironment * mAccumulatorRuntime;
  // Initializer
	MTSQLInterpreter* mInitializerInterpreter;
	MTSQLExecutable* mInitializerExe;
  Frame * mInitializerProbeFrame;
  Frame * mInitializerTableFrame;
  RecordActivationRecord * mInitializerProbeActivationRecord;
  RecordActivationRecord * mInitializerTableActivationRecord;
	DualCompileEnvironment * mInitializerEnv;
  DualRuntimeEnvironment * mInitializerRuntime;
 
  State mState;
  boost::int64_t mProcessed;
  MessagePtr mInputMessage;
  MessagePtr mOutputMessage;

  // A FIFO of contributors to the group. Used only when copyToAll is specified.
  MessagePtrQueue mGroupByRecords;
  MessagePtr mMergedMessage;
  /**
   * Ingest of input record with group keys.  Return true if this
   * represents a group change (either new group keys or end of stream).
   */
  bool ProcessGroupByKeys();
  void InitializeAccumulator();
  void Accumulate();
  void ExportSortKey(const_record_t buffer, SortKeyBuffer& sortKeyBuffer);

public:
  METRAFLOW_DECL RunTimeSortGroupByActivation(Reactor * reactor, 
                                              partition_t partition, 
                                              const RunTimeSortGroupBy * runTimeOperator);
  METRAFLOW_DECL ~RunTimeSortGroupByActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};


/**
 * Computes a merge equijoin of two sorted data streams.
 *
 * The SortMergeJoin takes two input streams and produces a single output stream that is the equijoin of the underlying sets.
 * The input streams are required to be sorted on the configured equijoin keys.  Failure to do will not result in a runtime failure
 * but will result in incorrect results.
 * The two input ports of the operator have labels "left" and "right".
 *
 */
class DesignTimeSortMergeJoin : public DesignTimeOperator
{
public:

  enum JoinType { INNER_JOIN, RIGHT_SEMI, RIGHT_ANTI_SEMI, RIGHT_OUTER, RIGHT_OUTER_SPLIT };

private:
  std::vector<DesignTimeSortKey> mLeftEquiJoinKeys;
  std::vector<DesignTimeSortKey> mRightEquiJoinKeys;
  RecordMerge * mMerger;
  RecordProjection * mProjection;
  std::wstring mResidual;
  JoinType mJoinType;
  std::wstring mNest;

public:
  /**
   * Default constructor 
   */
  METRAFLOW_DECL DesignTimeSortMergeJoin();
  /**
   * Destructor
   */
  METRAFLOW_DECL ~DesignTimeSortMergeJoin();
  /**
   * Type check operator.  
   * Output of the operator includes the concatenation of the input records of its two inputs.
   * @exception MissingKeyException Thrown if the equijoin keys are not configured on either the left or right input.
   * @exception KeySizeMismatchException Thrown if the number of keys on the left and right inputs are not the same.
   * @exception MissingFieldException Thrown if the equijoin keys do not exist in the input.
   * @exception TypeMismatchException Thrown if copositioned equijoin keys from the two inputs have different data types.
   * @exception MTSQLException Thrown if the residual predicate has syntax errors.
   */
  METRAFLOW_DECL void type_check();
  /**
   * Create a run time operator for the physical plan.
   * @return A RunTimeSortMergeJoin operator.  
   */
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /**
   * Set the equijoin keys for the left input of the operator.
   * Overwrites any existing equijoin key configuration.
   * Group by keys must support sorting.
   * @param equiJoinKeys The set of names of key fields to group by.
   */
  METRAFLOW_DECL void SetLeftEquiJoinKeys(const std::vector<DesignTimeSortKey>& equiJoinKeys);
  /**
   * Set the equijoin keys for the right input of the operator.
   * Overwrites any existing equijoin key configuration.
   * Group by keys must support sorting.
   * @param equiJoinKeys The set of names of key fields to group by.
   */
  METRAFLOW_DECL void SetRightEquiJoinKeys(const std::vector<DesignTimeSortKey>& equiJoinKeys);
  /**
   * Add an equijoin key to the current equijoin key list for the left input.
   * @todo Throw an exception if there are duplicate key names in the key list?
   */
  METRAFLOW_DECL void AddLeftEquiJoinKey(const DesignTimeSortKey& equiJoinKey);
  /**
   * Add an equijoin key to the current equijoin key list for the right input.
   * @todo Throw an exception if there are duplicate key names in the key list?
   */
  METRAFLOW_DECL void AddRightEquiJoinKey(const DesignTimeSortKey& equiJoinKey);
  /**
   * Set an MTSQL function that defines a residual predicate.
   */
  METRAFLOW_DECL void SetResidual(const std::wstring& residual);
  /**
   * Set the join type. 
   */
  METRAFLOW_DECL void SetJoinType(JoinType joinType);
  /** 
   * Configure nested join behavior.
   */
  METRAFLOW_DECL void SetNest(const std::wstring& nest);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeSortMergeJoin* clone(
                                         const std::wstring& name,
                                         std::vector<OperatorArg*>& args, 
                                         int nInputs, int nOutputs) const;
};

class RunTimeSortMergeJoin : public RunTimeOperator
{
public:
  friend class RunTimeSortMergeJoinActivation;
  friend class RunTimeRelationalSortMergeJoinActivation;
  friend class RunTimeNestedSortMergeJoinActivation;
private:
  RecordMetadata mLeftMetadata;
  RecordMetadata mRightMetadata;
  std::vector<RunTimeSortKey> mLeftEquiJoinKeys;
  std::vector<RunTimeSortKey> mRightEquiJoinKeys;
  RecordMerge mMerger;
  std::wstring mResidual;
  DesignTimeSortMergeJoin::JoinType mJoinType;
  RunTimeDataAccessor * mNestedRecordAccessor;
  RecordProjection mProjection;
  RecordMetadata mOutputMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mLeftMetadata);
    ar & BOOST_SERIALIZATION_NVP(mRightMetadata);
    ar & BOOST_SERIALIZATION_NVP(mLeftEquiJoinKeys);
    ar & BOOST_SERIALIZATION_NVP(mRightEquiJoinKeys);
    ar & BOOST_SERIALIZATION_NVP(mMerger);
    ar & BOOST_SERIALIZATION_NVP(mResidual);
    ar & BOOST_SERIALIZATION_NVP(mJoinType);
    ar & BOOST_SERIALIZATION_NVP(mNestedRecordAccessor);
    ar & BOOST_SERIALIZATION_NVP(mProjection);
    ar & BOOST_SERIALIZATION_NVP(mOutputMetadata);
  }  
  METRAFLOW_DECL RunTimeSortMergeJoin();

public:
  METRAFLOW_DECL RunTimeSortMergeJoin(const std::wstring& name, 
                                      const RecordMetadata& leftMetadata,
                                      const RecordMetadata& rightMetadata,
                                      const std::vector<RunTimeSortKey>& leftEquiJoinKeys,
                                      const std::vector<RunTimeSortKey>& rightEquiJoinKeys,
                                      const RecordMerge& merger,
                                      const std::wstring& mResidual,
                                      DesignTimeSortMergeJoin::JoinType joinType);
  METRAFLOW_DECL RunTimeSortMergeJoin(const std::wstring& name, 
                                      const RecordMetadata& leftMetadata,
                                      const RecordMetadata& rightMetadata,
                                      const std::vector<RunTimeSortKey>& leftEquiJoinKeys,
                                      const std::vector<RunTimeSortKey>& rightEquiJoinKeys,
                                      const std::wstring& mResidual,
                                      DesignTimeSortMergeJoin::JoinType joinType,
                                      const RecordMetadata& outputMetadata,
                                      const std::wstring& nestedRecord,
                                      const RecordProjection& projection);
  METRAFLOW_DECL ~RunTimeSortMergeJoin();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeSortMergeJoinActivation : public RunTimeOperatorActivationImpl<RunTimeSortMergeJoin>
{
protected:
  enum State {START, READ_LEFT_INIT, READ_RIGHT_INIT,
              READ_LEFT_ADVANCE_LT, READ_RIGHT_ADVANCE_LT,
              READ_LEFT_ADVANCE_EQ, READ_RIGHT_ADVANCE_EQ,
              READ_LEFT_DRAIN, READ_RIGHT_DRAIN,
              WRITE_MATCH, WRITE_SEMI_MATCH, WRITE_LAST_MATCH, 
              WRITE_ANTI_SEMI_NO_MATCH_ADVANCE_LT, WRITE_RIGHT_OUTER_NO_MATCH_ADVANCE_LT,
              WRITE_ANTI_SEMI_NO_MATCH, WRITE_RIGHT_OUTER_NO_MATCH, 
              WRITE_ANTI_SEMI_NO_MATCH_DRAIN, WRITE_RIGHT_OUTER_NO_MATCH_DRAIN, 
              WRITE_EOF};

  State mState;
  record_t mLeftMessage;
  record_t mRightMessage;
  record_t mOutputMessage;
  record_t mLeftIterator;
  MessagePtrQueue mBuffer;

  // Residual
  class MetraFlowDualRecordInterpreter * mResidualInterpreter;

  // Match flag for outer join and anti semi join processing
  bool mMatchFound;

  // Save a matched record to enable transfer optimization
  MessagePtr mLastMatch;

  // Left NULL buffer for outer join processing.
  MessagePtr mLeftBuffer;

  int Compare(record_t lhs, record_t rhs);

  /**
   * This operator supports two modes of how to process a match.
   * The first mode is the standard relational semantics of a join
   * in which the output record is the concatenation of the fields in
   * the two inputs.  In this first mode, there is one output per matching
   * pair of inputs.
   * The second mode is the nested record semantics.  In this mode,
   * there is a distinguished input (here the right input) and for each
   * record on the distinguished input, we output that record plus a new
   * field which is the nested collection of matching records from the 
   * other input.  In the case of this second mode, there are two 
   * choices about what to do when there are no matches in the second input.
   * The first choice is to drop the record on the distinguished input.
   * The second choice is to output the record on the distinguished input
   * with an empty collection.  In this implementation we make the first choice
   * when INNER_JOIN is configured and the second choice when RIGHT_OUTER is
   * configured.  This is more or less consistent with the fact that this second mode
   * is essentially implementing a composition of merge_join with sort_nest.
   */

  virtual void ProcessMatch(bool lastMatch) = 0;
  virtual void ProcessNonMatch() = 0;
  virtual void InternalStart() =0;
  virtual void ProcessEOF(Endpoint * ep) =0;
public:
  METRAFLOW_DECL RunTimeSortMergeJoinActivation(Reactor * reactor, 
                                                partition_t partition, 
                                                const RunTimeSortMergeJoin * runTimeOperator);
  METRAFLOW_DECL ~RunTimeSortMergeJoinActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class RunTimeRelationalSortMergeJoinActivation : public RunTimeSortMergeJoinActivation
{
protected:
  void ProcessMatch(bool lastMatch);
  void ProcessNonMatch();
  void InternalStart();
  void ProcessEOF(Endpoint * ep);
public:
  METRAFLOW_DECL RunTimeRelationalSortMergeJoinActivation(Reactor * reactor,
                                                          partition_t partition,
                                                          const RunTimeSortMergeJoin * runTimeOperator);
  METRAFLOW_DECL ~RunTimeRelationalSortMergeJoinActivation();
};

class RunTimeNestedSortMergeJoinActivation : public RunTimeSortMergeJoinActivation
{
protected:
  void ProcessMatch(bool lastMatch);
  void ProcessNonMatch();
  void InternalStart();
  void ProcessEOF(Endpoint * ep);
public:
  METRAFLOW_DECL RunTimeNestedSortMergeJoinActivation(Reactor * reactor,
                                                      partition_t partition,
                                                      const RunTimeSortMergeJoin * runTimeOperator);
  METRAFLOW_DECL ~RunTimeNestedSortMergeJoinActivation();
};


/**
 * Selects a single record from a group of records based on max, min, first, last criteria.
 * 
 * Selection criteria are determined by the order statistics min() and max() as well as the 
 * "sort order" statistics first() and last().  The min() and max() order statistics take a single
 * argument which is a general MTSQL expression of type INTEGER, BIGINT, DECIMAL, DATETIME or DOUBLE PRECISION.
 * The sort order statistics take no argument.
 * The operator is configured by specifying a list of statistics and the operator interprets lexicographically:
 * which is to say the first statistic is applied and the second is applied only to break ties and so forth.
 * Absent a tie breaker/subordinate statistic, an arbitrary record will be selected from among those satisfying
 * the configured statistics.
 *
 * The configured statistics are transformed into two MTSQL program for run time execution.  These MTSQL programs
 * are passed a (generated) accumulator record that contains the current state of the statistics as well as the 
 * record in the input stream of the operator.  The first program is responsible for initializing the accumulator
 * values.  The second program is responsible for updating the statistics and returning a BOOLEAN value indicating
 * whether the current record should be selected or not.  
 *
 * For example:
 * The order statistic @a INTEGER @b INTEGER AS min(@a + @b) requires a single accumulator variable @acc1 (same type as the expression @a+@b).
 *
 * The accumulator variable is initialized to maximum value of the type (uh. what about strings):
 * CREATE PROCEDURE i @acc1 INTEGER 
 * AS
 * SET @acc1 = 2147483647
 *
 * The accumulator update is the program:
 * CREATE PROCEDURE u @a INTEGER @b INTEGER @acc1 INTEGER RETURNS BOOLEAN
 * AS 
 * DECLARE @tmp1 INTEGER
 * SET @tmp1 = @a + @b 
 * IF @tmp1 < @acc1
 * BEGIN
 *   SET @acc1 = @tmp1
 *   RETURN TRUE
 * END
 * ELSE IF @tmp1 = @acc1
 *   RETURN FALSE
 * ELSE
 *   RETURN FALSE
 * 
 * To see why we have written the program as above instead of optimizing it, let's look at how multiple order statistics interact. Consider
 * @a INTEGER @b INTEGER AS min(@a + @b)
 * @c DECIMAL AS MAX(@c)
 * Each order statistic gets a variable to track the "current" value: @acc1 INTEGER, @acc2 DECIMAL.
 *
 * The accumulator variables are initialized:
 * CREATE PROCEDURE i @acc1 INTEGER @acc2 DECIMAL
 * AS
 * SET @acc1 = 2147483647
 * SET @acc2 = -9999999999.999999
 *
 * The accumulators are updated:
 * CREATE PROCEDURE u @a INTEGER @b INTEGER @acc1 INTEGER @c DECIMAL @acc2 DECIMAL RETURNS BOOLEAN
 * AS 
 * DECLARE @tmp1 INTEGER
 * DECLARE @tmp2 DECIMAL
 * SET @tmp1 = @a + @b 
 * IF @tmp1 < @acc1 
 * BEGIN
 *   SET @acc1 = @tmp1
 *   SET @acc2 = @c
 *   RETURN TRUE
 * END  
 * ELSE IF @tmp1 = @acc1
 * BEGIN
 *   -- Need to do the nested check of second accumulator.
     SET @tmp2 = @c
 *   IF @tmp2 > @acc2 
 *   BEGIN
 *     SET @acc2 = @tmp2
 *     RETURN TRUE
 *   END
 *   ELSE IF @tmp2 = @acc2
 *     RETURN FALSE
 *   ELSE
 *     RETURN FALSE
 * END
 * ELSE
 *   RETURN FALSE
 * 
 * @todo Perhaps we should solve the type inference problem with MTSQL.  It is on the roadmap and it would be useful here.
 *
 * @todo We have to do type calculations to figure out the correct type for the accumulator variable.  This may
 * mean it should be done as an ANTLR tree transformation after all?
 *
 * @todo Could also be interesting to add median (or more general quantile) capability.
 */
class DesignTimeHashGroupSelection : public DesignTimeOperator
{
private:
  std::vector<std::wstring> mGroupByKeys;

  std::wstring mInitializeProgram;
  std::wstring mSelectionProgram;

  /**
   * Metadata of the accumlator used to compute the aggregate functions.
   */
  RecordMetadata * mMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mGroupByKeys);
    ar & BOOST_SERIALIZATION_NVP(mInitializeProgram);
    ar & BOOST_SERIALIZATION_NVP(mSelectionProgram);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  }  

public:
  /**
   * Default constructor 
   */
  METRAFLOW_DECL DesignTimeHashGroupSelection();
  /**
   * Destructor
   */
  METRAFLOW_DECL ~DesignTimeHashGroupSelection();
  /**
   * Type check operator.  
   * Output of the operator is the same as its input.
   * @exception MissingFieldException Thrown if group by keys do not exist in the input.
   * @exception MTSQLException Thrown if initializer program or update program have syntax errors.
   */
  METRAFLOW_DECL void type_check();
  /**
   * Create a run time operator for the physical plan.
   * @return A RunTimeHashGroupSelection operator.
   */
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /**
   * Set the group by keys for the operator.
   * Overwrites any existing group by key configuration.
   * Group by keys must support sorting.
   * @param groupByKeys The set of names of key fields to group by.
   */
  METRAFLOW_DECL void SetGroupByKeys(const std::vector<std::wstring>& groupByKeys);
  /**
   * Add a group by key to the current group by key list.
   * @todo Throw an exception if there are duplicate key names in the group by list?
   */
  METRAFLOW_DECL void AddGroupByKey(const DesignTimeSortKey& groupByKey);
  /**
   * Set an MTSQL program used to initialize aggregate variables when a new group by key is seen.
   * @todo Support configuration by specification of aggregate function expressions.
   */
  METRAFLOW_DECL void SetInitializeProgram(const std::wstring& initializeProgram);
  /**
   * Set an MTSQL program used to update aggregate variables from an input record and to copy
   * currently selected record.
   * @todo Support configuration by specification of aggregate function expressions.
   */
  METRAFLOW_DECL void SetSelectionProgram(const std::wstring& updateProgram);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeHashGroupSelection* clone( 
                                              const std::wstring& name,
                                              std::vector<OperatorArg*>& args, 
                                              int nInputs, int nOutputs) const;
};

#endif
