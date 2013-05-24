#ifndef __IDGENERATOROPERATOR_H__
#define __IDGENERATOROPERATOR_H__

#include "Scheduler.h"

class DesignTimeIdGenerator : public DesignTimeOperator
{
private:
  std::wstring mIdName;
  std::wstring mSequenceName;
  boost::int32_t mBlockSize;

  RecordMetadata * mOutputMetadata;
  RecordMerge * mMerger;

public:
  METRAFLOW_DECL DesignTimeIdGenerator();
  METRAFLOW_DECL ~DesignTimeIdGenerator();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);
  
  METRAFLOW_DECL void SetIdName(const std::wstring& idName);
  METRAFLOW_DECL void SetSequenceName(const std::wstring& sequenceName);
  METRAFLOW_DECL void SetBlockSize(boost::int32_t blockSize);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeIdGenerator* clone(
                                       const std::wstring& name,
                                       std::vector<OperatorArg*>& args, 
                                       int nInputs, int nOutputs) const;
};

class RunTimeIdGenerator : public RunTimeOperator
{
public:
  friend class RunTimeIdGeneratorActivation;
private:
  RecordMetadata mInputMetadata;
  RecordMetadata mOutputMetadata;
  RecordMerge mMerger;
  std::wstring mIdName;
  std::wstring mSequenceName;
  boost::int32_t mBlockSize;

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
    ar & BOOST_SERIALIZATION_NVP(mMerger);
    ar & BOOST_SERIALIZATION_NVP(mIdName);
    ar & BOOST_SERIALIZATION_NVP(mSequenceName);
    ar & BOOST_SERIALIZATION_NVP(mBlockSize);
  } 
  METRAFLOW_DECL RunTimeIdGenerator();

public:
  METRAFLOW_DECL RunTimeIdGenerator(const std::wstring& name, 
                                    const RecordMetadata& inputMetadata,
                                    const RecordMetadata& outputMetadata,
                                    const RecordMerge& merge,
                                    const std::wstring& idName,
                                    const std::wstring& sequenceName,
                                    boost::int32_t blockSize);

  METRAFLOW_DECL ~RunTimeIdGenerator();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeIdGeneratorActivation : public RunTimeOperatorActivationImpl<RunTimeIdGenerator>
{
private:
  // Runtime values
  RunTimeDataAccessor * mIdAccessor;
  enum State { READ_0, WRITE_OUTPUT_0, WRITE_EOF_0 };
  State mState;
  MessagePtr mInputMessage;
  MessagePtr mOutputMessage;
  MessagePtr mOutputBuffer;
  // Id Generator state
  boost::int64_t mBlockIt;
  boost::int64_t mBlockEnd;
public:
  METRAFLOW_DECL RunTimeIdGeneratorActivation(Reactor * reactor, 
                                              partition_t partition, 
                                              const RunTimeIdGenerator * runTimeOperator);
  METRAFLOW_DECL ~RunTimeIdGeneratorActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

#endif
