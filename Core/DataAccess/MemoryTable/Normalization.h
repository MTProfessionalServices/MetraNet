#ifndef __NORMALIZATION_H__
#define __NORMALIZATION_H__

#include "Scheduler.h"
#include "SortMergeCollector.h"

#include <map>

/**
 * Sorted Nesting operator 
 */
class DesignTimeSortNest : public DesignTimeOperator
{
private:
  std::vector<DesignTimeSortKey> mGroupKeys;
  std::vector<std::wstring> mParentFields;
  std::vector<std::wstring> mRaiseFields;
  std::wstring mRecordName;
  bool mAlwaysUpdateParent;

public:
  METRAFLOW_DECL DesignTimeSortNest();
  METRAFLOW_DECL ~DesignTimeSortNest();
  METRAFLOW_DECL void AddParentField(const std::wstring& parentField);
  METRAFLOW_DECL void AddGroupKey(const std::wstring& key);
  METRAFLOW_DECL void AddGroupKey(const DesignTimeSortKey& key);
  METRAFLOW_DECL void SetRecordName(const std::wstring& recordName);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeSortNest* clone(
    const std::wstring& name,
    std::vector<OperatorArg*>& args, 
    int nInputs, int nOutputs) const;
};

class RunTimeSortNest : public RunTimeOperator
{
public:
  friend class RunTimeSortNestActivation;

private:
  RecordMetadata mInputMetadata;
  RecordMetadata mOutputMetadata;
  RecordMetadata mNestedRecordMetadata;
  std::vector<RunTimeSortKey> mGroupKeys;
  RecordProjection mParentProjection;
  RecordProjection mNestedRecordProjection;
  std::wstring mNestedRecordName;
  bool mAlwaysUpdateParent;

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
    ar & BOOST_SERIALIZATION_NVP(mNestedRecordMetadata);
    ar & BOOST_SERIALIZATION_NVP(mGroupKeys);
    ar & BOOST_SERIALIZATION_NVP(mParentProjection);
    ar & BOOST_SERIALIZATION_NVP(mNestedRecordProjection);
    ar & BOOST_SERIALIZATION_NVP(mNestedRecordName);
  }  

  METRAFLOW_DECL RunTimeSortNest()
  {
  }
  
public:
  METRAFLOW_DECL RunTimeSortNest(const std::wstring& name, 
                                 const RecordMetadata& inputMetadata,
                                 const std::wstring& parentPrefix,
                                 const RecordMetadata& outputMetadata,
                                 const RecordMetadata& childMetadata,
                                 const std::vector<RunTimeSortKey>& groupKeys,
                                 const std::wstring& childRecord,
                                 bool alwaysUpdateParent);
  METRAFLOW_DECL ~RunTimeSortNest();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);

  bool IsAlwaysUpdateParent() const;
};

class RunTimeSortNestActivation : public RunTimeOperatorActivationImpl<RunTimeSortNest>
{
public:
  enum State { START, READ_FIRST_0, READ_0, WRITE_0, WRITE_LAST_0, WRITE_EOF_0 };

private:
  // Two Sort Key buffers. One stores the current
  // key, the other stores the value of the current record.
  // Technically we don't require sortedness of the input,
  // only groupedness.
  SortKeyBuffer* mBuffer[2];
  bool mCurrentBuffer;
  
  State mState;
  boost::int64_t mProcessed;
  MessagePtr mInputMessage;
  MessagePtr mOutputMessage;
  RunTimeDataAccessor * mNestedRecordAccessor;

  void InitializeAccumulator();
  void Accumulate();
  void ExportSortKey(const_record_t buffer, SortKeyBuffer& sortKeyBuffer);
public:
  METRAFLOW_DECL RunTimeSortNestActivation(Reactor * reactor, 
                                           partition_t partition,
                                           const RunTimeSortNest * runTimeOperator);
  METRAFLOW_DECL ~RunTimeSortNestActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

/**
 * Unnesting operator 
 */
class DesignTimeUnnest : public DesignTimeOperator
{
private:
  std::wstring mPrefix;
  std::wstring mRecordName;
  std::map<std::wstring, std::wstring> mParentFieldMap;
public:
  METRAFLOW_DECL DesignTimeUnnest();
  METRAFLOW_DECL ~DesignTimeUnnest();
  METRAFLOW_DECL void SetPrefix(const std::wstring& recordName);
  METRAFLOW_DECL void SetRecordName(const std::wstring& recordName);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeUnnest* clone(
    const std::wstring& name,
    std::vector<OperatorArg*>& args, 
    int nInputs, int nOutputs) const;
};

class RunTimeUnnest : public RunTimeOperator
{
public:
  friend class RunTimeUnnestActivation;

private:
  RecordMetadata mInputMetadata;
  RecordMetadata mOutputMetadata;
  RecordMetadata mNestedRecordMetadata;
  RecordProjection mParentProjection;
  RecordProjection mNestedRecordProjection;
  std::wstring mNestedRecordName;

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
    ar & BOOST_SERIALIZATION_NVP(mNestedRecordMetadata);
    ar & BOOST_SERIALIZATION_NVP(mParentProjection);
    ar & BOOST_SERIALIZATION_NVP(mNestedRecordProjection);
    ar & BOOST_SERIALIZATION_NVP(mNestedRecordName);
  }  
  
  METRAFLOW_DECL RunTimeUnnest()
  {
  }
public:
  METRAFLOW_DECL RunTimeUnnest(const std::wstring& name, 
                               const RecordMetadata& inputMetadata,
                               const RecordMetadata& outputMetadata,
                               const RecordMetadata& childMetadata,
                               const std::wstring& childRecord,
                               const std::map<std::wstring, std::wstring>& parentMemberMap);
  METRAFLOW_DECL ~RunTimeUnnest();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeUnnestActivation : public RunTimeOperatorActivationImpl<RunTimeUnnest>
{
public:
  enum State { START, READ_0, WRITE_0, WRITE_EOF_0 };

private:
  State mState;
  MessagePtr mInputMessage;
  MessagePtr mOutputMessage;
  RunTimeDataAccessor * mNestedRecordAccessor;
  // The end of the nested record collection
  const_record_t mEnd;
  // Iterator over the nested record collection
  const_record_t mIt;

public:
  METRAFLOW_DECL RunTimeUnnestActivation(Reactor * reactor, 
                                         partition_t partition,
                                         const RunTimeUnnest * runTimeOperator);
  METRAFLOW_DECL ~RunTimeUnnestActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

#endif
