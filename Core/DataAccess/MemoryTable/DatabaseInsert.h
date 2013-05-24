#ifndef __DATABASE_INSERT_H__
#define __DATABASE_INSERT_H__

#include <boost/shared_ptr.hpp>

#include "MetraFlowConfig.h"
#include "Scheduler.h"
#include "LogAdapter.h"

class COdbcConnection;
class COdbcPreparedBcpStatement;
class COdbcPreparedArrayStatement;
class COdbcColumnMetadata;
class RunTimeTransactionalInstaller;
class InstallerWorkQueue;
class InstallerWorkQueue2;

namespace boost
{
  class thread;
}

class DesignTimeDatabaseInsert : public DesignTimeOperator
{
public:
  class Binding
  {
  private:
    std::wstring mSourceName;
    int mTargetPosition;
    MTPipelineLib::PropValType mColumnType;
    bool mIsRequired;
    //
    // Serialization support
    //
    friend class boost::serialization::access;
    template<class Archive>
    void serialize(Archive & ar, const unsigned int version)
    {
      ar & BOOST_SERIALIZATION_NVP(mSourceName);
      ar & BOOST_SERIALIZATION_NVP(mTargetPosition);
      ar & BOOST_SERIALIZATION_NVP(mColumnType);
      ar & BOOST_SERIALIZATION_NVP(mIsRequired);
    } 
  public:
    Binding()
      :
      mTargetPosition(0),
      mColumnType(MTPipelineLib::PROP_TYPE_INTEGER),
      mIsRequired(false)
    {
    }

    Binding(const std::wstring& sourceName, int targetPosition, MTPipelineLib::PropValType columnType, bool isRequired)
      :
      mSourceName(sourceName),
      mTargetPosition(targetPosition),
      mColumnType(columnType),
      mIsRequired(isRequired)
    {
    }

    const std::wstring& GetSourceName() const { return mSourceName; }
    int GetTargetPosition() const { return mTargetPosition; }
    MTPipelineLib::PropValType GetColumnType() const { return mColumnType; }
    bool IsRequired() const { return mIsRequired; }
  };

private:
  std::wstring mTableName;
  std::wstring mSchemaName;
  boost::int32_t mBatchSize;
  std::map<std::wstring,std::wstring> mSourceTargetMap;
  bool mCreateTable;
  std::wstring mStreamingTransactionKey;
  bool mIsOracle;
  std::wstring mSortHint;

  std::vector<Binding> mBindings;
  static std::wstring GetSQLServerDatatype(DataAccessor * accessor);
  static std::wstring GetOracleDatatype(DataAccessor * accessor);
  static void CheckTypeCompatibility(const DesignTimeOperator& op, const Port& p,
                                     const COdbcColumnMetadata& db, const RecordMember& accessor);
public:
  METRAFLOW_DECL DesignTimeDatabaseInsert();
  METRAFLOW_DECL ~DesignTimeDatabaseInsert();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  std::wstring GetTableName() const 
  {
    return mTableName; 
  }
  void SetTableName(const std::wstring& tableName)  
  {
    mTableName = tableName; 
  }
  std::wstring GetSchemaName() const 
  {
    return mSchemaName; 
  }
  void SetSchemaName(const std::wstring& schemaName)  
  {
    mSchemaName = schemaName; 
  }
  boost::int32_t GetBatchSize() const
  {
    return mBatchSize;
  }
  void SetBatchSize(boost::int32_t batchSize) 
  {
    mBatchSize = batchSize;
  }
  const std::map<std::wstring, std::wstring>& GetSourceTargetMap() const 
  {
    return mSourceTargetMap; 
  }
  METRAFLOW_DECL void SetSourceTargetMap(const std::map<std::wstring, std::wstring>& sourceTargetMap);
  std::wstring GetSortHint() const 
  {
    return mSortHint; 
  }
  void SetSortHint(const std::wstring& sortHint)  
  {
    mSortHint = sortHint; 
  }
  bool GetCreateTable() const
  {
    return mCreateTable;
  }
  void SetCreateTable(bool createTable) 
  {
    mCreateTable = createTable;
  }
  std::wstring GetStreamingTransactionKey() const 
  {
    return mStreamingTransactionKey;
  }
  void SetStreamingTransactionKey(const std::wstring& key)  
  {
    mStreamingTransactionKey = key; 
  }

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeDatabaseInsert* clone(
                                          const std::wstring& name,
                                          std::vector<OperatorArg *>& args, 
                                          int nInputs, int nOutputs) const;
};

template <class _InsertStmt>
class RunTimeDatabaseInsert : public RunTimeOperator
{
public:
  class RuntimeBinding
  {
  private:
    RunTimeDataAccessor * mSourceAccessor;
    int mTargetPosition;
    MTPipelineLib::PropValType mColumnType;
    bool mIsRequired;
    //
    // Serialization support
    //
    friend class boost::serialization::access;
    template<class Archive>
    void serialize(Archive & ar, const unsigned int version)
    {
      ar & BOOST_SERIALIZATION_NVP(mSourceAccessor);
      ar & BOOST_SERIALIZATION_NVP(mTargetPosition);
      ar & BOOST_SERIALIZATION_NVP(mColumnType);
      ar & BOOST_SERIALIZATION_NVP(mIsRequired);
    } 
  public:
    RuntimeBinding()
      :
      mSourceAccessor(NULL),
      mTargetPosition(0),
      mColumnType(MTPipelineLib::PROP_TYPE_INTEGER),
      mIsRequired(false)
    {
    }

    RuntimeBinding(RunTimeDataAccessor * sourceAccessor, int targetPosition, MTPipelineLib::PropValType columnType, bool isRequired)
      :
      mSourceAccessor(sourceAccessor),
      mTargetPosition(targetPosition),
      mColumnType(columnType),
      mIsRequired(isRequired)
    {
    }

    RunTimeDataAccessor* GetSourceAccessor() const { return mSourceAccessor; }
    int GetTargetPosition() const { return mTargetPosition; }
    MTPipelineLib::PropValType GetColumnType() const { return mColumnType; }
    bool IsRequired() const { return mIsRequired; }
  };
  // TODO: Figure out how to declare a template as a friend
public:
// private:
  std::wstring mTableName;
  std::wstring mSchemaName;
  std::wstring mSortHint;
  boost::int32_t mBatchSize;
  RecordMetadata mMetadata;
  RecordMetadata mOutputMetadata;
  std::vector<RuntimeBinding> mBindings;
  std::wstring mStreamingTransactionKey;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mTableName);
    ar & BOOST_SERIALIZATION_NVP(mSchemaName);
    ar & BOOST_SERIALIZATION_NVP(mSortHint);
    ar & BOOST_SERIALIZATION_NVP(mBatchSize);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
    ar & BOOST_SERIALIZATION_NVP(mOutputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mBindings);
    ar & BOOST_SERIALIZATION_NVP(mStreamingTransactionKey);
  } 
  METRAFLOW_DECL RunTimeDatabaseInsert()
    :
    mBatchSize(0)
  {
  }

public:
  METRAFLOW_DECL RunTimeDatabaseInsert (const std::wstring& name, 
                                   const std::wstring & tableName,
                                   const std::wstring & schemaName,
                                   const std::wstring & sortHint,
                                   boost::int32_t batchSize,
                                   const RecordMetadata& metadata,
                                   const RecordMetadata& outputMetadata,
                                   const std::vector<DesignTimeDatabaseInsert::Binding>& bindings,
                                   const std::wstring& streamingTransactionKey);
  METRAFLOW_DECL ~RunTimeDatabaseInsert();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

template <class _InsertStmt>
class RunTimeDatabaseInsertActivation : public RunTimeOperatorActivationImpl<RunTimeDatabaseInsert<_InsertStmt> >
{
private:
  // Execution parameters
  enum State { START, READ_0, WRITE_0, WRITE_1, WRITE_EOF };
  State mState;
  MessagePtr mInputMessage;
  COdbcConnection * mConnection;
  _InsertStmt * mBcpStatement;
  boost::int32_t mCurrentBatchCount;
  boost::uint64_t mNumRead;
  // For generating random table names in the streaming case.
  std::wstring mCurrentTableName;
  // For accessing the transaction identifier
  DataAccessor * mTransactionId;
  boost::int32_t mCurrentTransaction;
  // We read ahead a batch worth of data
  MessagePtrQueue mQueue;
  // A staging database global queue of temp tables that I can use
  boost::shared_ptr<class TemporaryTableQueue> mTempTableQueue;
  MessagePtr GetTableBuffer();

  void WriteRecord(const_record_t inputMessage);
  void PrepareStatement();
public:
  METRAFLOW_DECL RunTimeDatabaseInsertActivation (Reactor * reactor, 
                                                  partition_t partition,
                                                  const RunTimeDatabaseInsert<_InsertStmt> * runTimeOperator);
  METRAFLOW_DECL ~RunTimeDatabaseInsertActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};


// This performs "update" queries parametrized by table variables that are
// passed into its inputs.  These input queries are performed in a 
// single transaction.  In order that the operator doesn't wait for
// updates that may not need to be performed in a given transaction
// (for us think of a compound for which a particular child service
// definition is almost never used) we pass a "control" record that tells
// this operator which inputs are going to be giving it data.
//
// This whole operator is a bit of a classic dataflow hack to deal
// the fact that control flow may exist even in the abscence of data.
class DesignTimeTransactionalInstall : public DesignTimeOperator
{
private:
  std::vector<std::vector<std::wstring> > mPreTransactionQueries;
  std::vector<std::vector<std::wstring> > mQueries;
  std::vector<std::vector<std::wstring> > mPostTransactionQueries;
public:
  METRAFLOW_DECL DesignTimeTransactionalInstall(boost::int32_t tableInputs);
  METRAFLOW_DECL ~DesignTimeTransactionalInstall();
  METRAFLOW_DECL void SetPreTransactionQueries(const std::vector<std::vector<std::wstring> >& queries);
  METRAFLOW_DECL void SetQueries(const std::vector<std::vector<std::wstring> >& queries);
  METRAFLOW_DECL void SetPostTransactionQueries(const std::vector<std::vector<std::wstring> >& queries);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeTransactionalInstall* clone(
                                               const std::wstring& name,
                                               std::vector<OperatorArg*>& args,
                                               int nInputs, int nOutputs) const;
};

class RunTimeTransactionalInstall : public RunTimeOperator
{
public:
  friend class RunTimeTransactionalInstallActivation;
private:
  std::vector<std::vector<std::wstring> > mUntransformedPreTransactionQueries;
  std::vector<std::vector<std::wstring> > mUntransformedQueries;
  std::vector<std::vector<std::wstring> > mUntransformedPostTransactionQueries;
  std::vector<RecordMetadata> mMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mUntransformedPreTransactionQueries);
    ar & BOOST_SERIALIZATION_NVP(mUntransformedQueries);
    ar & BOOST_SERIALIZATION_NVP(mUntransformedPostTransactionQueries);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  }  

  METRAFLOW_DECL RunTimeTransactionalInstall();

public:
  METRAFLOW_DECL RunTimeTransactionalInstall(const std::wstring& name, 
                                        const std::vector<std::vector<std::wstring> >& preTransactionQueries,
                                        const std::vector<std::vector<std::wstring> >& queries,
                                        const std::vector<std::vector<std::wstring> >& postTransactionQueries,
                                        const std::vector<const RecordMetadata*>& metadata);
  METRAFLOW_DECL ~RunTimeTransactionalInstall();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeTransactionalInstallActivation : public RunTimeOperatorActivationImpl<RunTimeTransactionalInstall>
{
private:
  // Runtime state stuff.
  enum State { START, READ_0, READ_1, READ_EOF };
  State mState;
  MessagePtr mControlMessage;
  MessagePtr mInputMessage;
  std::vector<DataAccessor*> mControlAccessors;
  std::vector<DataAccessor*> mTableAccessors;
  std::vector<DataAccessor*> mSchemaAccessors;
  std::size_t mNextInput;
  std::vector<std::wstring>::iterator mQueryIterator;

  std::vector<boost::shared_ptr<boost::thread> > mThreadPool;
  boost::shared_ptr<RunTimeTransactionalInstaller> mInstaller;
  InstallerWorkQueue * mWorkQueue;
  MetraFlowLoggerPtr mLogger;
  std::vector<std::vector<std::wstring> > mPreTransactionQueries;
  std::vector<std::vector<std::wstring> > mQueries;
  std::vector<std::vector<std::wstring> > mPostTransactionQueries;

  void StartTransaction(boost::int32_t txnId);
  void EnqueuePreTransaction(boost::int32_t txnId, const std::wstring& query);
  void EnqueueTransaction(boost::int32_t txnId, const std::wstring& query);
  void EnqueuePostTransaction(boost::int32_t txnId, const std::wstring& query);
  void CompleteTransaction(boost::int32_t txnId);
  std::wstring TransformQuery(const std::wstring& query);

public:
  METRAFLOW_DECL RunTimeTransactionalInstallActivation(Reactor * reactor, 
                                                       partition_t partition, 
                                                       const RunTimeTransactionalInstall * runTimeOperator);
  METRAFLOW_DECL ~RunTimeTransactionalInstallActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
  METRAFLOW_DECL void Complete();
};

// This performs "update" queries parametrized by table variables that are
// passed into its inputs.  These input queries are performed in a 
// single transaction.  In order that the operator doesn't wait for
// updates that may not need to be performed in a given transaction
// (for us think of a compound for which a particular child service
// definition is almost never used) we pass a "control" record that tells
// this operator which inputs are going to be giving it data.
//
// This whole operator is a bit of a classic dataflow hack to deal
// the fact that control flow may exist even in the abscence of data.
class DesignTimeTransactionalInstall2 : public DesignTimeOperator
{
private:
  std::vector<std::vector<std::wstring> > mPreTransactionQueries;
  std::vector<std::vector<std::wstring> > mQueries;
  std::vector<std::vector<std::wstring> > mPostTransactionQueries;
public:
  METRAFLOW_DECL DesignTimeTransactionalInstall2(boost::int32_t tableInputs);
  METRAFLOW_DECL ~DesignTimeTransactionalInstall2();
  METRAFLOW_DECL void SetPreTransactionQueries(const std::vector<std::vector<std::wstring> >& queries);
  METRAFLOW_DECL void SetQueries(const std::vector<std::vector<std::wstring> >& queries);
  METRAFLOW_DECL void SetPostTransactionQueries(const std::vector<std::vector<std::wstring> >& queries);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeTransactionalInstall2* clone(
                                               const std::wstring& name,
                                               std::vector<OperatorArg*>& args,
                                               int nInputs, int nOutputs) const;
};

class RunTimeTransactionalInstall2 : public RunTimeOperator
{
public:
  friend class RunTimeTransactionalInstall2Activation;
private:
  std::vector<std::vector<std::wstring> > mUntransformedPreTransactionQueries;
  std::vector<std::vector<std::wstring> > mUntransformedQueries;
  std::vector<std::vector<std::wstring> > mUntransformedPostTransactionQueries;
  std::vector<RecordMetadata> mMetadata;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mUntransformedPreTransactionQueries);
    ar & BOOST_SERIALIZATION_NVP(mUntransformedQueries);
    ar & BOOST_SERIALIZATION_NVP(mUntransformedPostTransactionQueries);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
  }  

  METRAFLOW_DECL RunTimeTransactionalInstall2();

public:
  METRAFLOW_DECL RunTimeTransactionalInstall2(const std::wstring& name, 
                                        const std::vector<std::vector<std::wstring> >& preTransactionQueries,
                                        const std::vector<std::vector<std::wstring> >& queries,
                                        const std::vector<std::vector<std::wstring> >& postTransactionQueries,
                                        const std::vector<const RecordMetadata*>& metadata);
  METRAFLOW_DECL ~RunTimeTransactionalInstall2();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeTransactionalInstall2Activation : public RunTimeOperatorActivationImpl<RunTimeTransactionalInstall2>
{
private:
  // Runtime state stuff.
  enum State { START, READ_0, READ_1, READ_EOF };
  State mState;
  MessagePtr mInputMessage;
  DataAccessor* mPriorityAccessor;
  std::vector<DataAccessor*> mTableAccessors;
  std::vector<DataAccessor*> mSchemaAccessors;
  std::vector<DataAccessor*> mTargetSchemaAccessors;
  std::vector<std::wstring>::iterator mQueryIterator;

  std::vector<boost::shared_ptr<boost::thread> > mThreadPool;
  boost::shared_ptr<RunTimeTransactionalInstaller> mInstaller;
  InstallerWorkQueue2 * mWorkQueue;
  MetraFlowLoggerPtr mLogger;
  std::vector<std::vector<std::wstring> > mPreTransactionQueries;
  std::vector<std::vector<std::wstring> > mQueries;
  std::vector<std::vector<std::wstring> > mPostTransactionQueries;

  void StartTransaction(boost::int32_t txnId, const std::wstring& tag);
  void EnqueuePreTransaction(boost::int32_t txnId, const std::wstring& query);
  void EnqueueTransaction(boost::int32_t txnId, const std::wstring& query);
  void EnqueuePostTransaction(boost::int32_t txnId, const std::wstring& query);
  void CompleteTransaction(boost::int32_t txnId);
  std::wstring TransformQuery(const std::wstring& query);
  std::wstring TransformQuery(const std::wstring& query,
                              const std::wstring& table,
                              const std::wstring& schema,
                              const std::wstring& targetSchema);

public:
  METRAFLOW_DECL RunTimeTransactionalInstall2Activation(Reactor * reactor, 
                                                       partition_t partition, 
                                                       const RunTimeTransactionalInstall2 * runTimeOperator);
  METRAFLOW_DECL ~RunTimeTransactionalInstall2Activation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
  METRAFLOW_DECL void Complete();
};

#endif
