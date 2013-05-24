#ifndef __RUNTIMEEXPRESSION_H__
#define __RUNTIMEEXPRESSION_H__

#include "Scheduler.h"
#include "LogAdapter.h"
#include "MTSQLInterpreter_T.h"

class MTSQLInterpreter;
class RecordCompileEnvironment;
class PipelineRuntimeEnvironment;
class RecordRuntimeEnvironmentConcrete;
class MTSQLExecutable;
class Frame;
class DualCompileEnvironment;
class RecordActivationRecord;
class GeneratorGlobalEnvironment;
class DualRuntimeEnvironment;

class RunTimeExpression : public RunTimeOperator
{
public:
  friend class RunTimeExpressionActivation;
private:
  RecordMetadata mInputMetadata;
  RecordMetadata mOutputMetadata;
  RecordMerge mMerger;
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
    ar & BOOST_SERIALIZATION_NVP(mOutputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mMerger);
    ar & BOOST_SERIALIZATION_NVP(mProgram);
  } 
  METRAFLOW_DECL RunTimeExpression();

public:
  METRAFLOW_DECL RunTimeExpression(const std::wstring& name, 
                               const RecordMetadata& inputMetadata,
                               const RecordMetadata& outputMetadata,
                               const RecordMerge& merge,
                               const std::wstring& program);

  METRAFLOW_DECL ~RunTimeExpression();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeExpressionActivation : public RunTimeOperatorActivationImpl<RunTimeExpression>
{
private:
  // Runtime values
  enum State { READ_0, WRITE_OUTPUT_0, WRITE_EOF_0 };
  State mState;
  MessagePtr mInputMessage;
  MessagePtr mOutputMessage;
  MessagePtr mOutputBuffer;
  // Program interpreter stuff
	MTSQLInterpreter* mInterpreter;
	RecordCompileEnvironment * mEnv;
  PipelineRuntimeEnvironment * mPipelineRuntime;
  RecordRuntimeEnvironmentConcrete * mRecordRuntime;
	MTSQLExecutable_T<RecordRuntimeEnvironmentConcrete> * mExe;
  MetraFlowLoggerPtr mLogger;
public:
  METRAFLOW_DECL RunTimeExpressionActivation(Reactor * reactor, 
                                             partition_t partition, 
                                             const RunTimeExpression * runTimeOperator);
  METRAFLOW_DECL ~RunTimeExpressionActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

// This run time operator is like both expression and generator
// in that it modifies an input record with MTSQL expressions, but
// like generator it has built in variables @@RECORDCOUNT, @@NUMPARTITIONS,
// and @@PARTITION.  @@RECORDCOUNT is a count of input records that
// have been written (so the first value is 0).
// The only reason to have this and expression is the performance impact
// of using the dual compile environment.
class RunTimeExpressionGenerator : public RunTimeOperator
{
public:
  friend class RunTimeExpressionGeneratorActivation;
private:
  RecordMetadata mInputMetadata;
  RecordMetadata mOutputMetadata;
  RecordMerge mMerger;
  std::wstring mProgram;
  boost::int32_t mNumPartitions;
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
    ar & BOOST_SERIALIZATION_NVP(mProgram);
    ar & BOOST_SERIALIZATION_NVP(mNumPartitions);
  } 
  METRAFLOW_DECL RunTimeExpressionGenerator();

public:
  METRAFLOW_DECL RunTimeExpressionGenerator(const std::wstring& name, 
                                       partition_t maxPartition,
                                       const RecordMetadata& inputMetadata,
                                       const RecordMetadata& outputMetadata,
                                       const RecordMerge& merge,
                                       const std::wstring& program);

  METRAFLOW_DECL ~RunTimeExpressionGenerator();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeExpressionGeneratorActivation : public RunTimeOperatorActivationImpl<RunTimeExpressionGenerator>
{
private:
  // Runtime values
  enum State { READ_0, WRITE_OUTPUT_0, WRITE_EOF_0 };
  State mState;
  MessagePtr mInputMessage;
  MessagePtr mOutputMessage;
  MessagePtr mOutputBuffer;
  // Program interpreter stuff
	MTSQLInterpreter* mInterpreter;
	MTSQLExecutable* mExe;
  Frame * mGlobalFrame;
  Frame * mOutputFrame;
	DualCompileEnvironment * mEnv;
  RecordActivationRecord * mRecordActivationRecord;
  GeneratorGlobalEnvironment * mGlobalVariables;
  DualRuntimeEnvironment * mRuntime;
  MetraFlowLoggerPtr mLogger;
public:
  METRAFLOW_DECL RunTimeExpressionGeneratorActivation(Reactor * reactor, 
                                                      partition_t partition,
                                                      const RunTimeExpressionGenerator * runTimeOperator);
  METRAFLOW_DECL ~RunTimeExpressionGeneratorActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class RunTimeGenerator : public RunTimeOperator
{
public:
  friend class RunTimeGeneratorActivation;
private:
  RecordMetadata mOutputMetadata;
  std::wstring mProgram;
  boost::int64_t mNumRecords;
  boost::int32_t mNumPartitions;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mOutputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mProgram);
    ar & BOOST_SERIALIZATION_NVP(mNumRecords);
    ar & BOOST_SERIALIZATION_NVP(mNumPartitions);
  } 
  METRAFLOW_DECL RunTimeGenerator();

public:
  METRAFLOW_DECL RunTimeGenerator(const std::wstring& name, 
                                  partition_t maxPartition,
                                  const RecordMetadata& outputMetadata,
                                  const std::wstring& program,
                                  boost::int64_t numRecords);

  METRAFLOW_DECL ~RunTimeGenerator();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeGeneratorActivation : public RunTimeOperatorActivationImpl<RunTimeGenerator>
{
private:
  // Runtime values
  enum State { START, WRITE_OUTPUT_0, WRITE_EOF_0 };
  State mState;
  MessagePtr mOutputMessage;
  // Program interpreter stuff
	MTSQLInterpreter* mInterpreter;
	MTSQLExecutable* mExe;
  Frame * mGlobalFrame;
  Frame * mOutputFrame;
	DualCompileEnvironment * mEnv;
  RecordActivationRecord * mRecordActivationRecord;
  GeneratorGlobalEnvironment * mGlobalVariables;
  DualRuntimeEnvironment * mRuntime;
  MetraFlowLoggerPtr mLogger;
public:
  METRAFLOW_DECL RunTimeGeneratorActivation(Reactor * reactor, 
                             partition_t partition, 
                                            const RunTimeGenerator * runTimeOperator);
  METRAFLOW_DECL ~RunTimeGeneratorActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};
#endif
