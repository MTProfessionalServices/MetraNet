#ifndef __DATABASE_SELECT_H__
#define __DATABASE_SELECT_H__

#include "Scheduler.h"
#include "Multiplexer.h"

#include <boost/shared_ptr.hpp>
#include <boost/function.hpp>

class COdbcConnection;
class COdbcPreparedArrayStatement;
class COdbcPreparedBcpStatement;
class COdbcRowArrayResultSet;

class CacheConsciousHashTable;
class CacheConsciousHashTableNonUniqueInsertIterator;
class CacheConsciousHashTableIteratorBase;
class CacheConsciousHashTableIterator;

class AsyncExecuteQueryRowBinding;

class DesignTimeHashJoin;

namespace boost
{
  class thread;
}

typedef boost::shared_ptr<COdbcConnection> COdbcConnectionPtr;
typedef boost::shared_ptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef boost::shared_ptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef boost::shared_ptr<COdbcRowArrayResultSet> COdbcRowArrayResultSetPtr;

class DesignTimeDevNull : public DesignTimeOperator
{
private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
  }  
public:
  DesignTimeDevNull()
  {
    mInputPorts.insert(this, 0, L"input", false);
  }
  ~DesignTimeDevNull()
  {
  }
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);  

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeDevNull* clone(
                                   const std::wstring& name,
                                   std::vector<OperatorArg*>& args, 
                                   int nInputs, int nOutputs) const;
};


class RunTimeDevNull : public RunTimeOperator
{
public:
  friend class RunTimeDevNullActivation;
private:
  RecordMetadata mMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  } 
  METRAFLOW_DECL RunTimeDevNull()
  {
  }
public:
  METRAFLOW_DECL RunTimeDevNull (const std::wstring& name, 
                                 const RecordMetadata& metadata);
  METRAFLOW_DECL ~RunTimeDevNull();
  METRAFLOW_DECL RunTimeOperatorActivation* CreateActivation(Reactor * reactor, partition_t partition);  
};

class RunTimeDevNullActivation : public RunTimeOperatorActivationImpl<RunTimeDevNull>
{
private:
  boost::uint64_t mNumRead;
public:
  METRAFLOW_DECL RunTimeDevNullActivation (Reactor * reactor, 
                                           partition_t partition,
                                           const RunTimeDevNull * runTimeDevNull);
  METRAFLOW_DECL ~RunTimeDevNullActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeDatabaseSelect : public DesignTimeOperator
{
private:
  // The query to execute (may be modified on a per-partition basis).
  std::wstring mBaseQuery;
  bool mRestrictRecordCount;
  boost::uint64_t mMaxRecordCount;
  std::map<std::wstring, std::wstring> mSourceTargetMap;
  std::wstring mSchema;
  static LogicalFieldType GetLogicalType(COdbcColumnMetadata * col);
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mBaseQuery);
    ar & BOOST_SERIALIZATION_NVP(mSourceTargetMap);
    ar & BOOST_SERIALIZATION_NVP(mSchema);
  }  
public:
  DesignTimeDatabaseSelect()
    :
    mSchema(L"NetMeter"),
    mRestrictRecordCount(false),
    mMaxRecordCount(0)
  {
    // No inputs and one output
    mOutputPorts.insert(this, 0, L"output", false);
  }
  ~DesignTimeDatabaseSelect()
  {
  }

  std::wstring GetBaseQuery() const 
  {
    return mBaseQuery; 
  }
  void SetBaseQuery(const std::wstring& baseQuery) 
  {
    mBaseQuery = baseQuery; 
  }
  std::wstring GetSchema() const 
  {
    return mSchema; 
  }
  void SetSchema(const std::wstring& schema) 
  {
    mSchema = schema; 
  }
  const std::map<std::wstring, std::wstring>& GetSourceTargetMap() const 
  {
    return mSourceTargetMap; 
  }
  void SetSourceTargetMap(const std::map<std::wstring, std::wstring>& sourceTargetMap)  
  {
    mSourceTargetMap = sourceTargetMap; 
  }

  void SetMaxRecordCount(boost::uint64_t maxRecordCount)
  {
    mMaxRecordCount = maxRecordCount;
    mRestrictRecordCount = true;
  }

  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeDatabaseSelect* clone(
                                          const std::wstring& name,
                                          std::vector<OperatorArg *>& args, 
                                          int nInputs, int nOutputs) const;
};

class RunTimeDatabaseSelect : public RunTimeOperator
{
public:
  friend class RunTimeDatabaseSelectActivation;
private:
  std::wstring mQuery;
  std::wstring mSchema;
  RecordMetadata mMetadata;
  partition_t mNumPartitions;
  bool mRestrictRecordCount;
  boost::uint64_t mMaxRecordCount;
  
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mQuery);
    ar & BOOST_SERIALIZATION_NVP(mSchema);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
    ar & BOOST_SERIALIZATION_NVP(mNumPartitions);
    ar & BOOST_SERIALIZATION_NVP(mRestrictRecordCount);
    ar & BOOST_SERIALIZATION_NVP(mMaxRecordCount);
  } 
  METRAFLOW_DECL RunTimeDatabaseSelect()
    :
    mNumPartitions(0),
    mRestrictRecordCount(false),
    mMaxRecordCount(0)
  {
  }

public:
  METRAFLOW_DECL RunTimeDatabaseSelect (const std::wstring& name, 
                                        partition_t numPartitions,
                                        const std::wstring & query,
                                        const std::wstring & schema,
                                        const RecordMetadata& metadata,
                                        bool bRestrictRecordCount,
                                        boost::uint64_t maxRecordCount)
    :
    RunTimeOperator(name),
    mQuery(query),
    mSchema(schema),
    mMetadata(metadata),
    mNumPartitions(numPartitions),
    mRestrictRecordCount(bRestrictRecordCount),
    mMaxRecordCount(maxRecordCount)
  {
  }
  METRAFLOW_DECL ~RunTimeDatabaseSelect();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeDatabaseSelectActivation : public RunTimeOperatorActivationImpl<RunTimeDatabaseSelect>
{
private:
  // Execution parameters
  COdbcConnection* mConnection;
  COdbcPreparedArrayStatement* mStatement;
  COdbcRowArrayResultSet* mResultSet;
  // Thread on which we execute the query.
  boost::thread * mExecuteThread;
  AsyncExecuteQueryRowBinding * mExecuteQuery;
  // These delegates import the columns of the rowset into records.
  std::vector<boost::function2<void,COdbcRowArrayResultSet *,record_t> > mDelegates;
  // This buffer holds all of the instances on which the delegates are based.
  boost::uint8_t * mImporterData;
  boost::uint8_t * mImporterCurrent;
  boost::uint8_t * mImporterEnd;
  boost::uint64_t mNumWritten;
  void SetupImport();
  void BuildCopyRun(COdbcRowArrayResultSet * rs,
                    const std::vector<RunTimeDataAccessor*>& dataflowMetadata,
                    boost::int32_t recordLength,
                    std::size_t copyStart,
                    std::size_t copyEnd,
                    std::size_t sourceCopyStart,
                    std::size_t sourceCopyEnd);
  void ImportData(COdbcRowArrayResultSet * rs, record_t buffer);
public:
  METRAFLOW_DECL RunTimeDatabaseSelectActivation (Reactor * reactor, 
                                                  partition_t partition, 
                                                  const RunTimeDatabaseSelect * runTimeOperator)
    :
    RunTimeOperatorActivationImpl<RunTimeDatabaseSelect>(reactor, partition, runTimeOperator),
    mConnection(NULL),
    mStatement(NULL),
    mResultSet(NULL),
    mExecuteThread(NULL),
    mExecuteQuery(NULL),
    mImporterData(NULL),
    mImporterCurrent(NULL),
    mImporterEnd(0),
    mNumWritten(0LL)
  {
  }
  METRAFLOW_DECL ~RunTimeDatabaseSelectActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeHashJoinProbeSpecification
{
public:
  /**
   * RIGHT_OUTER has SQL like behavior in which non-matches are output 
   * with NULLs in place of table values.  RIGHT_OUTER_SPLIT has a separate 
   * output for non-matches.
   */
  enum JoinType { INNER_JOIN, RIGHT_OUTER, RIGHT_OUTER_SPLIT, RIGHT_SEMI, RIGHT_ANTI_SEMI };

private:
  std::vector<std::wstring> mEquiJoinKeys;
  std::wstring mResidual;
  JoinType mJoinType;
  RecordMerge * mMerger;

  // Ports
  boost::shared_ptr<Port> mInputPort;
  boost::shared_ptr<Port> mOutputPort;
  boost::shared_ptr<Port> mOutputNonMatchPort;
  
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_NVP(mEquiJoinKeys);
    ar & BOOST_SERIALIZATION_NVP(mResidual);
    ar & BOOST_SERIALIZATION_NVP(mJoinType);
    ar & BOOST_SERIALIZATION_NVP(mMerger);
    ar & BOOST_SERIALIZATION_NVP(mInputPort);
    ar & BOOST_SERIALIZATION_NVP(mOutputPort);
    ar & BOOST_SERIALIZATION_NVP(mOutputNonMatchPort);
  }  
public:
  METRAFLOW_DECL DesignTimeHashJoinProbeSpecification();
  //METRAFLOW_DECL DesignTimeHashJoinProbeSpecification(
  //                  const DesignTimeHashJoinProbeSpecification &other);
  METRAFLOW_DECL ~DesignTimeHashJoinProbeSpecification();
  METRAFLOW_DECL void SetEquiJoinKeys(const std::vector<std::wstring>& equiJoinKeys);
  METRAFLOW_DECL void AddEquiJoinKey(const std::wstring& equiJoinKey);
  METRAFLOW_DECL const std::vector<std::wstring> & GetEquiJoinKeys() const;
  METRAFLOW_DECL void SetResidual(const std::wstring& residual);
  METRAFLOW_DECL const std::wstring & GetResidual() const;
  METRAFLOW_DECL void SetJoinType(JoinType joinType);
  METRAFLOW_DECL const JoinType GetJoinType() const;
  METRAFLOW_DECL const RecordMerge & GetMerger() const;

  METRAFLOW_DECL void SetInputPort(boost::shared_ptr<Port> inputPort);
  METRAFLOW_DECL const boost::shared_ptr<Port> GetInputPort() const;
  METRAFLOW_DECL void SetOutputPort(boost::shared_ptr<Port> outputPort);
  METRAFLOW_DECL const boost::shared_ptr<Port> GetOutputPort() const;
  METRAFLOW_DECL void SetOutputNonMatchPort(boost::shared_ptr<Port> outputNonMatchPort);
  METRAFLOW_DECL void type_check(const DesignTimeHashJoin& op, 
                            const Port& tablePort,
                            const std::vector<std::wstring>& tableEquiJoinKeys);

  /** Clone the initial configured state of probe specification. */
  METRAFLOW_DECL DesignTimeHashJoinProbeSpecification* clone() const;
};

class DesignTimeHashJoin : public DesignTimeOperator
{
private:
  /** First is table, second is probe */
  std::vector<std::wstring> mTableEquiJoinKeys;

  /** Vector of probes, one for each input/output port pair. */
  std::vector<DesignTimeHashJoinProbeSpecification> mProbes;

  boost::int32_t mTableSize;

  /**
   * True if being used for a multiHashJoin (rather than a innerHashJoin
   * or rightOuterHashJoin).
   */
  bool mIsMultiHashJoin;

  /** Handle the given multi hash operator argument specifying behavior. */
  void handleArgForMultiHashJoin(const OperatorArg& arg);

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mTableEquiJoinKeys);
    ar & BOOST_SERIALIZATION_NVP(mProbes);
    ar & BOOST_SERIALIZATION_NVP(mTableSize);
  }  
public:
  METRAFLOW_DECL DesignTimeHashJoin();
  METRAFLOW_DECL ~DesignTimeHashJoin();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL void SetTableEquiJoinKeys(const std::vector<std::wstring>& tableEquiJoinKeys);
  METRAFLOW_DECL void AddTableEquiJoinKey(const std::wstring& tableEquiJoinKey);
  METRAFLOW_DECL const std::vector<std::wstring>& GetTableEquiJoinKeys() const;

  METRAFLOW_DECL void SetTableSize(boost::int32_t tableSize);
  METRAFLOW_DECL boost::int32_t GetTableSize() const;

  /** Set the join type for the current probe specification (mProbeSpec) */
  METRAFLOW_DECL void  SetProbeSpecificationType(
                      DesignTimeHashJoinProbeSpecification::JoinType joinType);
  /** 
   * Add the given probe specification (mProbeSpec) to the list
   * of probe specifications associated with the input/output ports.
   */
  METRAFLOW_DECL void AddProbeSpecification(
                          DesignTimeHashJoinProbeSpecification& probeSpec);

  /**
   * Given the number of input ports, creates this number of inputs
   * and also matching output ports.   If join type is RIGHT_OUTER_SPLIT
   * also creates matching "right()" ports.
   */
  METRAFLOW_DECL void CreatePorts(int nInputPorts);

  /** 
   * Given the number of an already existing input port (zero-based),
   * set probe information for the port.
   */
  METRAFLOW_DECL void AddProbeSpecification(int portNumber);

  /** Set that this is being used for multiHashJoin */
  METRAFLOW_DECL void SetIsMultiHashJoin();

  /** Get the number of probe specifications that have been specified. */
  METRAFLOW_DECL int GetNumberOfProbeSpecifications() const;

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeHashJoin* clone(
                                    const std::wstring& name,
                                    std::vector<OperatorArg *>& args, 
                                    int nInputs, int nOutputs) const;
};

class RunTimeHashJoinProbeSpecification
{
public:
  friend class RunTimeHashJoinProbeSpecificationActivation;
private:
  std::vector<std::wstring> mEquiJoinKeys;
  std::wstring mResidual;
  RecordMetadata mProbeMetadata;
  RecordMerge mMerger;
  DesignTimeHashJoinProbeSpecification::JoinType mJoinType;

  // Do we store indices or can we store endpoints?

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mEquiJoinKeys);
    ar & BOOST_SERIALIZATION_NVP(mResidual);
    ar & BOOST_SERIALIZATION_NVP(mProbeMetadata);
    ar & BOOST_SERIALIZATION_NVP(mMerger);
    ar & BOOST_SERIALIZATION_NVP(mJoinType);
  } 

public:
  METRAFLOW_DECL RunTimeHashJoinProbeSpecification();
  METRAFLOW_DECL RunTimeHashJoinProbeSpecification(const RunTimeHashJoinProbeSpecification& rhs);
  METRAFLOW_DECL RunTimeHashJoinProbeSpecification(const std::vector<std::wstring>& equiJoinKeys,
                                                   const std::wstring& residual,
                                                   const RecordMetadata& probeMetadata,
                                                   const RecordMerge& merger,
                                                   DesignTimeHashJoinProbeSpecification::JoinType joinType);

  METRAFLOW_DECL ~RunTimeHashJoinProbeSpecification();

  METRAFLOW_DECL const RunTimeHashJoinProbeSpecification& operator=(const RunTimeHashJoinProbeSpecification& rhs);
  
  const RecordMetadata& GetProbeMetadata() const
  {
    return mProbeMetadata;
  }

  const RecordMerge& GetMerger() const
  {
    return mMerger;
  }

  DesignTimeHashJoinProbeSpecification::JoinType GetJoinType() const
  {
    return mJoinType;
  }
};

class RunTimeHashJoinProbeSpecificationActivation
{
private:
  const RunTimeHashJoinProbeSpecification * mProbeSpecification;
  CacheConsciousHashTableIteratorBase * mPredicateIterator;
  port_t mOutput;
  port_t mOutputNonMatch;

public:
  METRAFLOW_DECL RunTimeHashJoinProbeSpecificationActivation(); 
  METRAFLOW_DECL RunTimeHashJoinProbeSpecificationActivation(const RunTimeHashJoinProbeSpecificationActivation& rhs); 
  METRAFLOW_DECL RunTimeHashJoinProbeSpecificationActivation(const RunTimeHashJoinProbeSpecification* spec); 
  METRAFLOW_DECL ~RunTimeHashJoinProbeSpecificationActivation(); 
  METRAFLOW_DECL const RunTimeHashJoinProbeSpecificationActivation& operator=(const RunTimeHashJoinProbeSpecificationActivation& rhs);

  METRAFLOW_DECL void Start(CacheConsciousHashTable& table,
                            const RecordMetadata& tableMetadata);

  const RecordMetadata& GetProbeMetadata() const
  {
    return mProbeSpecification->mProbeMetadata;
  }

  const RecordMerge& GetMerger() const
  {
    return mProbeSpecification->mMerger;
  }

  DesignTimeHashJoinProbeSpecification::JoinType GetJoinType() const
  {
    return mProbeSpecification->mJoinType;
  }

  CacheConsciousHashTableIteratorBase * GetPredicateIterator() const
  {
    return mPredicateIterator;
  }
  port_t GetOutput() const 
  {
    return mOutput;
  }
  void SetOutput(port_t output)
  {
    mOutput = output;
  }
  port_t GetOutputNonMatch() const 
  {
    return mOutputNonMatch;
  }
  void SetOutputNonMatch(port_t outputNonMatch)
  {
    mOutputNonMatch = outputNonMatch;
  }
};

class RunTimeHashJoin : public RunTimeOperator
{
public:
  friend class RunTimeHashJoinActivation;
private:
  // first is probe, second is table
  std::vector<std::wstring> mTableEquiJoinKeys;
  RecordMetadata mTableMetadata;
  std::vector<RunTimeHashJoinProbeSpecification> mProbes;
  boost::int32_t mTableSize;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mTableEquiJoinKeys);
    ar & BOOST_SERIALIZATION_NVP(mTableMetadata);
    ar & BOOST_SERIALIZATION_NVP(mProbes);
    ar & BOOST_SERIALIZATION_NVP(mTableSize);
  } 
  METRAFLOW_DECL RunTimeHashJoin()
    :
    mTableSize(0)
  {
  }

public:
  METRAFLOW_DECL RunTimeHashJoin(const std::wstring& name, 
                                 const RecordMetadata& tableMetadata,
                                 const std::vector<std::wstring>& tableEquiJoinKeys,
                                 const std::vector<RunTimeHashJoinProbeSpecification>& probes,
                                 boost::int32_t tableSize);
  METRAFLOW_DECL ~RunTimeHashJoin();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeHashJoinActivation : public RunTimeOperatorActivationImpl<RunTimeHashJoin>
{
private:
  // Runtime volatile variables
  enum State { START, READ_TABLE, READ_PROBE, WRITE_OUTPUT, WRITE_EOF, WRITE_RIGHT_OUTER_OUTPUT, WRITE_RIGHT_OUTER_EOF, WRITE_OUTPUT_NONMATCH, WRITE_SEMI_OUTPUT, WRITE_ANTI_SEMI_OUTPUT_NONMATCH };
  State mState;
  RunTimeHashJoinProbeSpecificationActivation * mActiveProbe;
  bool mMoreMatches;
  std::map<Endpoint *, RunTimeHashJoinProbeSpecificationActivation *> mEndpointProbeIndex;
  NonDeterministicInputMultiplexer mMultiplexer;
  record_t mOutputBuffer;
  record_t mNullTableBuffer;
  record_t mBuffer;
  CacheConsciousHashTable * mTable;
  CacheConsciousHashTableNonUniqueInsertIterator * mInsertIterator;
  RunTimeHashJoinProbeSpecificationActivation * mProbeActivations;
public:
  METRAFLOW_DECL RunTimeHashJoinActivation(Reactor * reactor, 
                                           partition_t partition, 
                                           const RunTimeHashJoin * runTimeOperator);
  METRAFLOW_DECL ~RunTimeHashJoinActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeHashPartitioner : public DesignTimeOperator
{
private:
  // first is table, second is probe
  std::vector<std::wstring > mHashKeys;
  std::vector<DataAccessor *> mHashAccessors;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mHashKeys);
    ar & BOOST_SERIALIZATION_NVP(mHashAccessors);
  }  
public:
  METRAFLOW_DECL DesignTimeHashPartitioner();
  METRAFLOW_DECL ~DesignTimeHashPartitioner();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL void SetHashKeys(const std::vector<std::wstring>& hashKeys);
  METRAFLOW_DECL void AddHashKey(const std::wstring& hashKey);
  METRAFLOW_DECL const std::vector<std::wstring>& GetHashKeys() const;

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeHashPartitioner* clone(
                                           const std::wstring& name,
                                           std::vector<OperatorArg *>& args, 
                                           int nInputs, int nOutputs) const;
};

class RunTimeHashPartitioner : public RunTimeOperator
{
public:
  friend class RunTimeHashPartitionerActivation;
private:
  std::vector<DataAccessor* > mHashKeys;
  RecordMetadata mMetadata;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mHashKeys);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  } 
  METRAFLOW_DECL RunTimeHashPartitioner()
  {
  }

public:
  METRAFLOW_DECL RunTimeHashPartitioner(const std::wstring& name, 
                                        const RecordMetadata& metadata,
                                        const std::vector<DataAccessor*>& hashKeys);

  METRAFLOW_DECL ~RunTimeHashPartitioner();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeHashPartitionerActivation : public RunTimeOperatorActivationImpl<RunTimeHashPartitioner>
{
private:
  // Runtime values
  enum State { START, WRITE_OUTPUT, WRITE_EOF };
  State mState;
  MessagePtr mBuffer;
  port_t mOutputPort;
public:
  METRAFLOW_DECL RunTimeHashPartitionerActivation(Reactor * reactor, 
                                                  partition_t partition, 
                                                  RunTimeHashPartitioner * runTimeOperator);
  METRAFLOW_DECL ~RunTimeHashPartitionerActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeBroadcastPartitioner : public DesignTimeOperator
{
private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
  }  
public:
  METRAFLOW_DECL DesignTimeBroadcastPartitioner();
  METRAFLOW_DECL ~DesignTimeBroadcastPartitioner();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeBroadcastPartitioner* clone(
                                                const std::wstring& name,
                                                std::vector<OperatorArg *>& args, 
                                                int nInputs, int nOutputs) const;
};

class RunTimeBroadcastPartitioner : public RunTimeOperator
{
public:
  friend class RunTimeBroadcastPartitionerActivation;
private:
  RecordMetadata mMetadata;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  } 
  METRAFLOW_DECL RunTimeBroadcastPartitioner()
  {
  }

public:
  METRAFLOW_DECL RunTimeBroadcastPartitioner(const std::wstring& name, 
                                             const RecordMetadata& metadata);

  METRAFLOW_DECL ~RunTimeBroadcastPartitioner();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeBroadcastPartitionerActivation : public RunTimeOperatorActivationImpl<RunTimeBroadcastPartitioner>
{
private:
  // Runtime values
  enum State { START, WRITE_OUTPUT, WRITE_EOF };
  State mState;
  MessagePtr mBuffer;
  port_t mOutputPort;
public:
  METRAFLOW_DECL RunTimeBroadcastPartitionerActivation(Reactor * reactor, 
                                                       partition_t partition, 
                                                       RunTimeBroadcastPartitioner * runTimeOperator);

  METRAFLOW_DECL ~RunTimeBroadcastPartitionerActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeRoundRobinPartitioner : public DesignTimeOperator
{
private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
  }  
public:
  METRAFLOW_DECL DesignTimeRoundRobinPartitioner();
  METRAFLOW_DECL ~DesignTimeRoundRobinPartitioner();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeRoundRobinPartitioner* clone(
                                                 const std::wstring& name,
                                                 std::vector<OperatorArg *>& args, 
                                                 int nInputs, int nOutputs) const;
};

class RunTimeRoundRobinPartitioner : public RunTimeOperator
{
public:
  friend class RunTimeRoundRobinPartitionerActivation;
private:
  RecordMetadata mMetadata;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  } 
  METRAFLOW_DECL RunTimeRoundRobinPartitioner()
  {
  }

public:
  METRAFLOW_DECL RunTimeRoundRobinPartitioner(const std::wstring& name, 
                                              const RecordMetadata& metadata);

  METRAFLOW_DECL ~RunTimeRoundRobinPartitioner();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeRoundRobinPartitionerActivation : public RunTimeOperatorActivationImpl<RunTimeRoundRobinPartitioner>
{
private:
  // Runtime values
  enum State { START, WRITE_OUTPUT, WRITE_EOF };
  State mState;
  MessagePtr mBuffer;
  port_t mOutputPort;
public:
  METRAFLOW_DECL RunTimeRoundRobinPartitionerActivation(Reactor * reactor, 
                                                        partition_t partition, 
                                                        RunTimeRoundRobinPartitioner * runTimeOperator);
  METRAFLOW_DECL ~RunTimeRoundRobinPartitionerActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeNondeterministicCollector : public DesignTimeOperator
{
private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
  }  
public:
  METRAFLOW_DECL DesignTimeNondeterministicCollector();
  METRAFLOW_DECL ~DesignTimeNondeterministicCollector();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeNondeterministicCollector* clone(
                                                     const std::wstring& name,
                                                     std::vector<OperatorArg *>& args, 
                                                     int nInputs, int nOutputs) const;
};

class RunTimeNondeterministicCollector : public RunTimeOperator
{
public:
  friend class RunTimeNondeterministicCollectorActivation;
private:
  RecordMetadata mMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  } 
  METRAFLOW_DECL RunTimeNondeterministicCollector()
  {
  }

public:
  METRAFLOW_DECL RunTimeNondeterministicCollector(const std::wstring& name, 
                                                  const RecordMetadata& metadata);

  METRAFLOW_DECL ~RunTimeNondeterministicCollector();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeNondeterministicCollectorActivation : public RunTimeOperatorActivationImpl<RunTimeNondeterministicCollector>
{
private:
  // Runtime values
  enum State { START, WRITE_OUTPUT, WRITE_EOF };
  State mState;
  MessagePtr mBuffer;
  Endpoint * mNextRead;
public:
  METRAFLOW_DECL RunTimeNondeterministicCollectorActivation(Reactor * reactor, 
                                                            partition_t partition, 
                                                            const RunTimeNondeterministicCollector * runTimeOperator);
  METRAFLOW_DECL ~RunTimeNondeterministicCollectorActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeUnionAll : public DesignTimeOperator
{
private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
  }  
public:
  METRAFLOW_DECL DesignTimeUnionAll();
  METRAFLOW_DECL DesignTimeUnionAll(boost::int32_t numInputs);
  METRAFLOW_DECL ~DesignTimeUnionAll();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeUnionAll* clone(
                                    const std::wstring& name,
                                    std::vector<OperatorArg *>& args, 
                                    int nInputs, int nOutputs) const;
};

class RunTimeUnionAll : public RunTimeOperator
{
public:
  friend class RunTimeUnionAllActivation;
private:
  RecordMetadata mMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  } 
  METRAFLOW_DECL RunTimeUnionAll()
  {
  }

public:
  METRAFLOW_DECL RunTimeUnionAll(const std::wstring& name, 
                                 const RecordMetadata& metadata);
  METRAFLOW_DECL ~RunTimeUnionAll();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeUnionAllActivation : public RunTimeOperatorActivationImpl<RunTimeUnionAll>
{
private:
  // Runtime values
  enum State { START, WRITE_OUTPUT, WRITE_EOF };
  State mState;
  MessagePtr mBuffer;
  Endpoint * mNextRead;
public:
  METRAFLOW_DECL RunTimeUnionAllActivation(Reactor * reactor, 
                                           partition_t partition, 
                                           const RunTimeUnionAll * runTimeOperator);

  METRAFLOW_DECL ~RunTimeUnionAllActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeRename : public DesignTimeOperator
{
private:
  std::map<std::wstring, std::wstring> mRenaming;
  std::map<std::wstring, std::wstring> mPrimitiveTypeRemapping;

  /** Holds from arguments specified */
  std::vector<std::wstring> mFromArgs;

  /** Holds to arguments specified */
  std::vector<std::wstring> mToArgs;

public:
  METRAFLOW_DECL DesignTimeRename();
  METRAFLOW_DECL ~DesignTimeRename();
  METRAFLOW_DECL void AddRename(const std::wstring& from, const std::wstring& to);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** 
   * Handle all to/from arguments specified.
   * Should be called after handleArg() has been called for all arguments. 
   */
  METRAFLOW_DECL void handleToFromArgs();

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeRename* clone(
                                  const std::wstring& name,
                                  std::vector<OperatorArg *>& args, 
                                  int nInputs, int nOutputs) const;
};

class DesignTimeCopy : public DesignTimeOperator
{
private:
  std::vector<std::vector<std::wstring> > mProjections;

  METRAFLOW_DECL DesignTimeCopy();
public:
  METRAFLOW_DECL DesignTimeCopy(boost::int32_t numCopies);
  METRAFLOW_DECL ~DesignTimeCopy();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);
  METRAFLOW_DECL void AddProjection(const std::vector<std::wstring>& projectionList);

  /** Handle the given operator argument specifying operator behavior. */
  virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeCopy* clone(const std::wstring& name,
                                               std::vector<OperatorArg*>& args,
                                               int nInputs, int nOutputs) const;
};

class RunTimeCopy : public RunTimeOperator
{
public:
  friend class RunTimeCopyActivation;
private:
  RecordMetadata mMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  } 
  METRAFLOW_DECL RunTimeCopy()
  {
  }

public:
  METRAFLOW_DECL RunTimeCopy(const std::wstring& name, 
                             const RecordMetadata& metadata);
  METRAFLOW_DECL ~RunTimeCopy();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeCopyActivation : public RunTimeOperatorActivationImpl<RunTimeCopy>
{
private:
  // Runtime values
  enum State { START, WRITE_OUTPUT, WRITE_EOF };
  State mState;
  MessagePtr mBuffer;
  std::size_t mNextOutput;
public:
  METRAFLOW_DECL RunTimeCopyActivation(Reactor * reactor, 
                                       partition_t partition, 
                                       const RunTimeCopy * runTimeOperator);

  METRAFLOW_DECL ~RunTimeCopyActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class RunTimeCopy2 : public RunTimeOperator
{
public:
  friend class RunTimeCopy2Activation;
private:
  RecordMetadata mInputMetadata;
  std::vector<RecordMetadata> mOutputMetadata;
  std::vector<RecordProjection> mProjection;
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
  METRAFLOW_DECL RunTimeCopy2()
  {
  }

public:
  METRAFLOW_DECL RunTimeCopy2(const std::wstring& name, 
                              const RecordMetadata& inputMetadata,
                              const std::vector<RecordMetadata>& outputMetadata);

  METRAFLOW_DECL ~RunTimeCopy2();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeCopy2Activation : public RunTimeOperatorActivationImpl<RunTimeCopy2>
{
private:
  // Runtime values
  enum State { START, WRITE_OUTPUT, WRITE_EOF };
  State mState;
  MessagePtr mBuffer;
  std::size_t mNextOutput;
public:
  METRAFLOW_DECL RunTimeCopy2Activation(Reactor * reactor, 
                                        partition_t partition, 
                                        const RunTimeCopy2 * runTimeOperator);
  METRAFLOW_DECL ~RunTimeCopy2Activation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeRangePartitioner : public DesignTimeOperator
{
private:
  std::vector<std::wstring > mRangeKeys;
  std::vector<RunTimeDataAccessor> mRangeAccessors;
  std::vector<boost::int32_t> mRangeMap;

public:
  METRAFLOW_DECL DesignTimeRangePartitioner();
  METRAFLOW_DECL ~DesignTimeRangePartitioner();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  METRAFLOW_DECL void AddRangeValue(boost::int32_t rangeValue);
  METRAFLOW_DECL void SetRangeKeys(const std::vector<std::wstring>& rangeKeys);
  METRAFLOW_DECL void AddRangeKey(const std::wstring& rangeKey);
  METRAFLOW_DECL const std::vector<std::wstring>& GetRangeKeys() const;

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeRangePartitioner* clone(
                                            const std::wstring& name,
                                            std::vector<OperatorArg *>& args, 
                                            int nInputs, int nOutputs) const;
};

template <class _FieldType>
class RunTimeRangePartitioner : public RunTimeOperator
{
public:
//   friend class RunTimeRangePartitionerActivation;
// private:
  std::vector<RunTimeDataAccessor> mRangeKeys;
  std::vector<_FieldType> mRangeMap;
  RecordMetadata mMetadata;

  // These are optional
  RecordMetadata mRangeMapMetadata;
  RunTimeDataAccessor mRangeMapValueAccessor;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mRangeKeys);
    ar & BOOST_SERIALIZATION_NVP(mRangeMap);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
    ar & BOOST_SERIALIZATION_NVP(mRangeMapMetadata);
    ar & BOOST_SERIALIZATION_NVP(mRangeMapValueAccessor);
  } 
  METRAFLOW_DECL RunTimeRangePartitioner()
  {
  }

public:
  METRAFLOW_DECL RunTimeRangePartitioner(const std::wstring& name, 
                                          const RecordMetadata& metadata,
                                          const std::vector<RunTimeDataAccessor>& rangeKeys,
                                          const std::vector<_FieldType>& rangeMap);
  METRAFLOW_DECL RunTimeRangePartitioner(const std::wstring& name, 
                                         const RecordMetadata& metadata,
                                         const std::vector<RunTimeDataAccessor>& rangeKeys,
                                         const RecordMetadata& rangeMapMetadata,
                                         const RunTimeDataAccessor& rangeMapValueAccessor);

  METRAFLOW_DECL ~RunTimeRangePartitioner();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

template <class _FieldType>
class RunTimeRangePartitionerActivation : public RunTimeOperatorActivationImpl<RunTimeRangePartitioner<_FieldType> >
{
private:
  // Runtime values
  enum State { START, READ_0, READ_RANGE_MAP, WRITE_OUTPUT, WRITE_EOF };
  State mState;
  MessagePtr mBuffer;
  port_t mOutputPort;
  std::vector<_FieldType> mActivationRangeMap;
public:
  METRAFLOW_DECL RunTimeRangePartitionerActivation(Reactor * reactor, 
                                                   partition_t partition, 
                                                   const RunTimeRangePartitioner<_FieldType> * runTimeOperator);

  METRAFLOW_DECL ~RunTimeRangePartitionerActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

#endif
