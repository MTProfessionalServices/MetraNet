#include "DesignTimeExpression.h"
#include "RunTimeExpression.h"
#include "BooleanPredicateInterface.h"
#include "LogAdapter.h"
#include "TypeCheckException.h"
#include "OperatorArg.h"

class GeneratorGlobalEnvironment : public ActivationRecord
{
private:
  boost::int64_t mNumRecords;
  boost::int32_t mPartitionNumber;
  boost::int32_t mNumPartitions;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mNumRecords);
    ar & BOOST_SERIALIZATION_NVP(mPartitionNumber);
    ar & BOOST_SERIALIZATION_NVP(mNumPartitions);
  } 
public:
  GeneratorGlobalEnvironment()
    :
    mNumRecords(0),
    mPartitionNumber(-1),
    mNumPartitions(-1)
  {
  }
  GeneratorGlobalEnvironment(boost::int32_t partitionNumber, boost::int32_t numPartitions)
    :
    mNumRecords(0),
    mPartitionNumber(partitionNumber),
    mNumPartitions(numPartitions)
  {
  }
  ~GeneratorGlobalEnvironment()
  {
  }

  void SetNumRecords(boost::int64_t numRecords);
  boost::int64_t GetNumRecords() const;
  void GetNumRecordsValue(RuntimeValue * value);
  void GetPartitionNumberValue(RuntimeValue * value);
  void GetNumPartitionsValue(RuntimeValue * value);

  void getLongValue(const Access * access, RuntimeValue * value);
  void getLongLongValue(const Access * access, RuntimeValue * value);
  void getDoubleValue(const Access * access, RuntimeValue * value);
  void getDecimalValue(const Access * access, RuntimeValue * value);
  void getStringValue(const Access * access, RuntimeValue * value);
  void getWStringValue(const Access * access, RuntimeValue * value);
  void getBooleanValue(const Access * access, RuntimeValue * value);
  void getDatetimeValue(const Access * access, RuntimeValue * value);
  void getTimeValue(const Access * access, RuntimeValue * value);
  void getEnumValue(const Access * access, RuntimeValue * value);
  void getBinaryValue(const Access * access, RuntimeValue * value);
	void setLongValue(const Access * access, const RuntimeValue * value)
	{
    ASSERT(false);
	}
	void setLongLongValue(const Access * access, const RuntimeValue * value)
	{
    ASSERT(false);
	}
	void setDoubleValue(const Access * access, const RuntimeValue * value)
	{
    ASSERT(false);
	}
	void setDecimalValue(const Access * access, const RuntimeValue * value)
	{
    ASSERT(false);
	}
	void setStringValue(const Access * access, const RuntimeValue * value)
	{
    ASSERT(false);
	}
	void setWStringValue(const Access * access, const RuntimeValue * value)
	{
    ASSERT(false);
	}
	void setBooleanValue(const Access * access, const RuntimeValue * value)
	{
    ASSERT(false);
	}
	void setDatetimeValue(const Access * access, const RuntimeValue * value)
	{
    ASSERT(false);
	}
	void setTimeValue(const Access * access, const RuntimeValue * value)
	{
    ASSERT(false);
	}
	void setEnumValue(const Access * access, const RuntimeValue * value)
	{
    ASSERT(false);
	}
	void setBinaryValue(const Access * access, const RuntimeValue * value)
	{
    ASSERT(false);
	}
	ActivationRecord* getStaticLink() 
	{
		// This is always a global environment; can't have a static link.
		return NULL;
	}
};

typedef void (GeneratorGlobalEnvironment::*GlobalEnvironmentGetter) (RuntimeValue *);

class GeneratorGlobalEnvironmentAccess : public Access
{
private:
  GlobalEnvironmentGetter mGetter;
public:
  GeneratorGlobalEnvironmentAccess(GlobalEnvironmentGetter getter)
    :
    mGetter(getter)
  {
  }
  ~GeneratorGlobalEnvironmentAccess()
  {
  }

  GlobalEnvironmentGetter GetGetter() const { return mGetter; }
};

class GeneratorGlobalEnvironmentFrame : public Frame
{
private:
  AccessPtr mNumRecords;
  AccessPtr mPartitionNumber;
  AccessPtr mNumPartitions;

public:
	GeneratorGlobalEnvironmentFrame() 
	{
    mNumRecords = AccessPtr(
      new GeneratorGlobalEnvironmentAccess(&GeneratorGlobalEnvironment::GetNumRecordsValue));
    mPartitionNumber = AccessPtr(
      new GeneratorGlobalEnvironmentAccess(&GeneratorGlobalEnvironment::GetPartitionNumberValue)); 
    mNumPartitions = AccessPtr(
      new GeneratorGlobalEnvironmentAccess(&GeneratorGlobalEnvironment::GetNumPartitionsValue)); 
	}

	AccessPtr allocateVariable(const std::string& var, int ty)
	{
    static const std::string numRecords("@RECORDCOUNT");
    static const std::string partitionNumber("@PARTITION");
    static const std::string numPartitions("@PARTITIONCOUNT");
    if (var == numRecords && ty == RuntimeValue::TYPE_BIGINTEGER) return mNumRecords;
    if (var == partitionNumber && ty == RuntimeValue::TYPE_INTEGER) return mPartitionNumber;
    if (var == numPartitions && ty == RuntimeValue::TYPE_INTEGER) return mNumPartitions;
    return nullAccess;
	}
	~GeneratorGlobalEnvironmentFrame() 
	{
	}
};

void GeneratorGlobalEnvironment::SetNumRecords(boost::int64_t numRecords)
{
  mNumRecords = numRecords;
}

boost::int64_t GeneratorGlobalEnvironment::GetNumRecords() const
{
  return mNumRecords;
}

void GeneratorGlobalEnvironment::GetNumRecordsValue(RuntimeValue * value)
{
  value->assignLongLong(mNumRecords);
}

void GeneratorGlobalEnvironment::GetPartitionNumberValue(RuntimeValue * value)
{
  value->assignLong(mPartitionNumber);
}

void GeneratorGlobalEnvironment::GetNumPartitionsValue(RuntimeValue * value)
{
  value->assignLong(mNumPartitions);
}

void GeneratorGlobalEnvironment::getLongValue(const Access * access, RuntimeValue * value)
{
  (this->*static_cast<const GeneratorGlobalEnvironmentAccess *>(access)->GetGetter())(value);
}
void GeneratorGlobalEnvironment::getLongLongValue(const Access * access, RuntimeValue * value)
{
  (this->*static_cast<const GeneratorGlobalEnvironmentAccess *>(access)->GetGetter())(value);
}
void GeneratorGlobalEnvironment::getDoubleValue(const Access * access, RuntimeValue * value)
{
  (this->*static_cast<const GeneratorGlobalEnvironmentAccess *>(access)->GetGetter())(value);
}
void GeneratorGlobalEnvironment::getDecimalValue(const Access * access, RuntimeValue * value)
{
  (this->*static_cast<const GeneratorGlobalEnvironmentAccess *>(access)->GetGetter())(value);
}
void GeneratorGlobalEnvironment::getStringValue(const Access * access, RuntimeValue * value)
{
  (this->*static_cast<const GeneratorGlobalEnvironmentAccess *>(access)->GetGetter())(value);
}
void GeneratorGlobalEnvironment::getWStringValue(const Access * access, RuntimeValue * value)
{
  (this->*static_cast<const GeneratorGlobalEnvironmentAccess *>(access)->GetGetter())(value);
}
void GeneratorGlobalEnvironment::getBooleanValue(const Access * access, RuntimeValue * value)
{
  (this->*static_cast<const GeneratorGlobalEnvironmentAccess *>(access)->GetGetter())(value);
}
void GeneratorGlobalEnvironment::getDatetimeValue(const Access * access, RuntimeValue * value)
{
  (this->*static_cast<const GeneratorGlobalEnvironmentAccess *>(access)->GetGetter())(value);
}
void GeneratorGlobalEnvironment::getTimeValue(const Access * access, RuntimeValue * value)
{
  (this->*static_cast<const GeneratorGlobalEnvironmentAccess *>(access)->GetGetter())(value);
}
void GeneratorGlobalEnvironment::getEnumValue(const Access * access, RuntimeValue * value)
{
  (this->*static_cast<const GeneratorGlobalEnvironmentAccess *>(access)->GetGetter())(value);
}
void GeneratorGlobalEnvironment::getBinaryValue(const Access * access, RuntimeValue * value)
{
  (this->*static_cast<const GeneratorGlobalEnvironmentAccess *>(access)->GetGetter())(value);
}

DesignTimeExpression::DesignTimeExpression()
  :
  mProgramOutputMetadata(NULL),
  mMerger(NULL)
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeExpression::~DesignTimeExpression()
{
  delete mProgramOutputMetadata;
  delete mMerger;
}

void DesignTimeExpression::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"program", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetProgram(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeExpression* DesignTimeExpression::clone(
                                              const std::wstring& name,
                                              std::vector<OperatorArg *>& args, 
                                              int nInputs, int nOutputs) const
{
  DesignTimeExpression* result = new DesignTimeExpression();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeExpression::type_check()
{
  const RecordMetadata * inputMetadata = mInputPorts[0]->GetMetadata();
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[DesignTimeExpression]");
  
  // At this point, we don't know what outputs appear in the program.
  // Compile against a special environment that will allow us to extract
  // the outputs and build the output metadata.  Then do a second typecheck
  // against an environment that encapsulates the input and output metadata.
  RecordCompileEnvironment dummyEnvironment(logger, new SimpleFrame());
  MTSQLInterpreter dummyInterpreter(&dummyEnvironment);
  dummyInterpreter.setSupportVarchar(true);
  MTSQLExecutable * dummyExecutable = dummyInterpreter.analyze(mProgram.c_str());

  // Grab the output parameters and construct the output record format.
  const std::vector<MTSQLParam>& params = dummyInterpreter.getProgramParams();
  LogicalRecord outputMembers;
  for(std::vector<MTSQLParam>::const_iterator it = params.begin();
      it != params.end();
      it++)
  {
    if (it->GetDirection() == DIRECTION_OUT)
    {
      std::string nm = it->GetName();
      // Strip off leading @ and convert to Unicode.
      std::wstring outputName;
      ::ASCIIToWide(outputName, nm.substr(1, nm.size()-1));
      if (!inputMetadata->HasColumn(outputName))
      {
        outputMembers.push_back(RecordMember(outputName, 
                                             LogicalFieldType::Get(*it)));
      }
      // TODO: Implement comparison at the level of PhysicalFieldType.
      else if (GetPhysicalFieldType(it->GetType()).GetPipelineType() != 
               inputMetadata->GetColumn(outputName)->GetPhysicalFieldType()->GetPipelineType())
      {
        throw FieldTypeException(*this, 
                                 *mInputPorts[0], 
                                 *inputMetadata->GetColumn(outputName),
                                 GetPhysicalFieldType(it->GetType()));
      }
    }
  }
  mProgramOutputMetadata = new RecordMetadata(outputMembers);
  
  // Now do a typecheck against the merged environment.
  mMerger = new RecordMerge(inputMetadata, mProgramOutputMetadata);
  RecordCompileEnvironment realEnvironment(logger, mMerger->GetRecordMetadata());
  MTSQLInterpreter realInterpreter(&realEnvironment);
  realInterpreter.setSupportVarchar(true);
  MTSQLExecutable  * realExe = realInterpreter.analyze(mProgram.c_str());
  if (NULL == realExe) 
  {
    std::string msg;
    ::WideStringToUTF8((boost::wformat(L"Error compiling MTSQL procedure: %1% on port '%2%' of operator '%3%'") % mProgram % inputMetadata->ToString() % GetName()).str(), msg);
    throw std::runtime_error(msg);
  }

  // Everything cool.  
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mMerger->GetRecordMetadata()));
}

RunTimeOperator * DesignTimeExpression::code_generate(partition_t partition)
{
  return new RunTimeExpression(mName, 
                               *mInputPorts[0]->GetMetadata(),
                               *mProgramOutputMetadata,
                               *mMerger,
                               mProgram);
}

PhysicalFieldType DesignTimeExpression::GetPhysicalFieldType(int ty)
{
  switch(ty)
  {
  case MTSQLParam::TYPE_INVALID: throw std::runtime_error("TYPE_INVALID seen in Expresssion");
  case MTSQLParam::TYPE_INTEGER: return PhysicalFieldType::Integer();
  case MTSQLParam::TYPE_DOUBLE: return PhysicalFieldType::Double();
  case MTSQLParam::TYPE_STRING: return PhysicalFieldType::UTF8StringDomain();
  case MTSQLParam::TYPE_BOOLEAN: return PhysicalFieldType::Boolean();
  case MTSQLParam::TYPE_DECIMAL: return PhysicalFieldType::Decimal();
  case MTSQLParam::TYPE_DATETIME: return PhysicalFieldType::Datetime();
  case MTSQLParam::TYPE_TIME: return PhysicalFieldType::Datetime(); 
  case MTSQLParam::TYPE_ENUM: return PhysicalFieldType::Enum();
  case MTSQLParam::TYPE_WSTRING: return PhysicalFieldType::StringDomain();
  case MTSQLParam::TYPE_NULL: throw std::runtime_error("TYPE_INVALID seen in Expresssion");
  case MTSQLParam::TYPE_BIGINTEGER: return PhysicalFieldType::BigInteger();
  case MTSQLParam::TYPE_BINARY: return PhysicalFieldType::Binary();
  default: throw std::runtime_error("Invalid MTSQL type seen in Expression");
  }
}

RunTimeExpression::RunTimeExpression()
{
}

RunTimeExpression::RunTimeExpression(const std::wstring& name, 
                                       const RecordMetadata& inputMetadata,
                                       const RecordMetadata& outputMetadata,
                                       const RecordMerge& merger,
                                       const std::wstring& program)
  : 
  RunTimeOperator(name),
  mInputMetadata(inputMetadata),
  mOutputMetadata(outputMetadata),
  mMerger(merger),
  mProgram(program)
{
}

RunTimeExpression::~RunTimeExpression()
{
}

RunTimeOperatorActivation * RunTimeExpression::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeExpressionActivation(reactor, partition, this);
}

RunTimeExpressionActivation::RunTimeExpressionActivation(Reactor * reactor, 
                                                         partition_t partition, 
                                                         const RunTimeExpression * runTimeOperator)
  : 
  RunTimeOperatorActivationImpl<RunTimeExpression>(reactor, partition, runTimeOperator),
  mState(READ_0),
  mInputMessage(NULL),
  mOutputMessage(NULL),
  mOutputBuffer(NULL),
	mInterpreter(NULL),
	mEnv(NULL),
  mPipelineRuntime(NULL),
  mRecordRuntime(NULL),
	mExe(NULL)
{
}

RunTimeExpressionActivation::~RunTimeExpressionActivation()
{
  if (mOutputBuffer != NULL) mOperator->mOutputMetadata.Free(mOutputBuffer);

	delete mInterpreter;
	delete mEnv;
  delete mExe;
  delete mRecordRuntime;
  delete mPipelineRuntime;
}

void RunTimeExpressionActivation::Start()
{
  mLogger = MetraFlowLoggerManager::GetLogger("[RunTimeExpression]");

	mEnv = new RecordCompileEnvironment(mLogger, mOperator->mMerger.GetRecordMetadata());
	mInterpreter = new MTSQLInterpreter(mEnv);
  mInterpreter->setSupportVarchar(true);

	mExe = new MTSQLExecutable_T<RecordRuntimeEnvironmentConcrete>(mOperator->mProgram.c_str(),
                                                                 mInterpreter);
  mPipelineRuntime = new PipelineRuntimeEnvironment(mLogger);
  mRecordRuntime = new RecordRuntimeEnvironmentConcrete();

  // Set up a buffer to merge outputs from (just NULL by default)
  mOutputBuffer = mOperator->mOutputMetadata.Allocate();

  RequestRead(0);
  mState = READ_0;
}

void RunTimeExpressionActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case READ_0:
    Read(mInputMessage,ep);
    if (!mOperator->mInputMetadata.IsEOF(mInputMessage))
    {
      // Merge the records with transfer on left and then invoke interpreter to set values.
      mOutputMessage = mOperator->mMerger.GetRecordMetadata()->Allocate();
      mOperator->mMerger.Merge(mInputMessage, mOutputBuffer, mOutputMessage, true, false);
      mOperator->mInputMetadata.ShallowFree(mInputMessage);
      mInputMessage = NULL;
      mRecordRuntime->SetBuffer(mOutputMessage);
      mExe->execCompiled(mRecordRuntime, mPipelineRuntime, mPipelineRuntime);
      RequestWrite(0);
      mState = WRITE_OUTPUT_0;
      return;
    case WRITE_OUTPUT_0:;
      Write(mOutputMessage, ep);
      mOutputMessage = NULL;
      RequestRead(0);
      mState = READ_0;
      return;
    }
    else
    {
      mOperator->mInputMetadata.Free(mInputMessage);
      RequestWrite(0);
      mState = WRITE_EOF_0;
      return;
    case WRITE_EOF_0:;
      Write(mOperator->mMerger.GetRecordMetadata()->AllocateEOF(), ep, true);
      return;
    }
  }
}

DesignTimeExpressionGenerator::DesignTimeExpressionGenerator()
  :
  mProgramOutputMetadata(NULL),
  mMerger(NULL)
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeExpressionGenerator::~DesignTimeExpressionGenerator()
{
  delete mProgramOutputMetadata;
  delete mMerger;
}

void DesignTimeExpressionGenerator::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"program", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetProgram(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeExpressionGenerator* DesignTimeExpressionGenerator::clone(
                                                                const std::wstring& name,
                                                                std::vector<OperatorArg *>& args, 
                                                                int nInputs, int nOutputs) const
{
  DesignTimeExpressionGenerator* result = new DesignTimeExpressionGenerator();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeExpressionGenerator::type_check()
{
  const RecordMetadata * inputMetadata = mInputPorts[0]->GetMetadata();
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[DesignTimeExpressionGenerator]");
  
  // Create a list of global variables we support.
  std::map<std::string, int> globalVariables;
  globalVariables["@@RECORDCOUNT"] = RuntimeValue::TYPE_BIGINTEGER;
  globalVariables["@@PARTITION"] = RuntimeValue::TYPE_INTEGER;
  globalVariables["@@PARTITIONCOUNT"] = RuntimeValue::TYPE_INTEGER;

  // At this point, we don't know what outputs appear in the program.
  // Compile against a special environment that will allow us to extract
  // the outputs and build the output metadata.  Then do a second typecheck
  // against an environment that encapsulates the input and output metadata.
  RecordCompileEnvironment dummyEnvironment(logger, new SimpleFrame());
  MTSQLInterpreter dummyInterpreter(&dummyEnvironment, globalVariables);
  dummyInterpreter.setSupportVarchar(true);
  MTSQLExecutable * dummyExecutable = dummyInterpreter.analyze(mProgram.c_str());

  // Grab the output parameters and construct the output record format.
  // Detect use of builtin variables.
  const std::vector<MTSQLParam>& params = dummyInterpreter.getProgramParams();
  LogicalRecord outputMembers;
  for(std::vector<MTSQLParam>::const_iterator it = params.begin();
      it != params.end();
      it++)
  {
    if (globalVariables.end() != globalVariables.find(it->GetName())) 
    {
      ASSERT(it->GetDirection() != DIRECTION_OUT);
    }
    if (it->GetDirection() == DIRECTION_OUT)
    {
      std::string nm = it->GetName();
      // Strip off leading @ and convert to Unicode.
      std::wstring outputName;
      ::ASCIIToWide(outputName, nm.substr(1, nm.size()-1));
      if (!inputMetadata->HasColumn(outputName))
      {
        outputMembers.push_back(RecordMember(outputName, 
                                             LogicalFieldType::Get(*it)));
      }
      // TODO: Implement comparison at the level of PhysicalFieldType.
      else if (GetPhysicalFieldType(it->GetType()).GetPipelineType() != 
               inputMetadata->GetColumn(outputName)->GetPhysicalFieldType()->GetPipelineType())
      {
        throw FieldTypeException(*this, 
                                 *mInputPorts[0], 
                                 *inputMetadata->GetColumn(outputName),
                                 GetPhysicalFieldType(it->GetType()));
      }
    }
  }
  mProgramOutputMetadata = new RecordMetadata(outputMembers);

  // Now do a typecheck against the merged environment.
  mMerger = new RecordMerge(inputMetadata, mProgramOutputMetadata);

  GeneratorGlobalEnvironmentFrame globalFrame;
  RecordFrame outputFrame(mMerger->GetRecordMetadata());
  // Global variables are of the form @@* and these come from the globalFrame
  DualCompileEnvironment realEnvironment(logger, &globalFrame, &outputFrame, "@", "");

  MTSQLInterpreter realInterpreter(&realEnvironment, globalVariables);
  realInterpreter.setSupportVarchar(true);
  MTSQLExecutable  * realExe = realInterpreter.analyze(mProgram.c_str());
  if (NULL == realExe) 
  {
    throw MtsqlCompilationException(*this);
  }

  // Everything cool.  
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mMerger->GetRecordMetadata()));
}

RunTimeOperator * DesignTimeExpressionGenerator::code_generate(partition_t maxPartition)
{
  return new RunTimeExpressionGenerator(mName, maxPartition, 
                                        *mInputPorts[0]->GetMetadata(),
                                        *mProgramOutputMetadata,
                                        *mMerger,
                                        mProgram);
}

PhysicalFieldType DesignTimeExpressionGenerator::GetPhysicalFieldType(int ty)
{
  switch(ty)
  {
  case MTSQLParam::TYPE_INVALID: throw std::runtime_error("TYPE_INVALID seen in Expresssion");
  case MTSQLParam::TYPE_INTEGER: return PhysicalFieldType::Integer();
  case MTSQLParam::TYPE_DOUBLE: return PhysicalFieldType::Double();
  case MTSQLParam::TYPE_STRING: return PhysicalFieldType::UTF8StringDomain();
  case MTSQLParam::TYPE_BOOLEAN: return PhysicalFieldType::Boolean();
  case MTSQLParam::TYPE_DECIMAL: return PhysicalFieldType::Decimal();
  case MTSQLParam::TYPE_DATETIME: return PhysicalFieldType::Datetime();
  case MTSQLParam::TYPE_TIME: return PhysicalFieldType::Datetime(); 
  case MTSQLParam::TYPE_ENUM: return PhysicalFieldType::Enum();
  case MTSQLParam::TYPE_WSTRING: return PhysicalFieldType::StringDomain();
  case MTSQLParam::TYPE_NULL: throw std::runtime_error("TYPE_INVALID seen in Expresssion");
  case MTSQLParam::TYPE_BIGINTEGER: return PhysicalFieldType::BigInteger();
  case MTSQLParam::TYPE_BINARY: return PhysicalFieldType::Binary();
  default: throw std::runtime_error("Invalid MTSQL type seen in Expression");
  }
}

RunTimeExpressionGenerator::RunTimeExpressionGenerator()
{
}

RunTimeExpressionGenerator::RunTimeExpressionGenerator(const std::wstring& name, 
                                                       partition_t maxPartition, 
                                                       const RecordMetadata& inputMetadata,
                                                       const RecordMetadata& outputMetadata,
                                                       const RecordMerge& merger,
                                                       const std::wstring& program)
  : 
  RunTimeOperator(name),
  mInputMetadata(inputMetadata),
  mOutputMetadata(outputMetadata),
  mMerger(merger),
  mProgram(program),
  mNumPartitions(maxPartition)
{
}

RunTimeExpressionGenerator::~RunTimeExpressionGenerator()
{
}

RunTimeOperatorActivation * RunTimeExpressionGenerator::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeExpressionGeneratorActivation(reactor, partition, this);
}

RunTimeExpressionGeneratorActivation::RunTimeExpressionGeneratorActivation(Reactor * reactor, 
                                                                           partition_t partition, 
                                                                           const RunTimeExpressionGenerator * runTimeOperator)
  : 
  RunTimeOperatorActivationImpl<RunTimeExpressionGenerator>(reactor, partition, runTimeOperator),
  mState(READ_0),
  mInputMessage(NULL),
  mOutputMessage(NULL),
  mOutputBuffer(NULL),
	mInterpreter(NULL),
	mExe(NULL),
  mGlobalFrame(NULL),
  mOutputFrame(NULL),
	mEnv(NULL),
  mRecordActivationRecord(NULL),
  mGlobalVariables(NULL),
  mRuntime(NULL)
{
}

RunTimeExpressionGeneratorActivation::~RunTimeExpressionGeneratorActivation()
{
  if (mOutputBuffer != NULL) mOperator->mOutputMetadata.Free(mOutputBuffer);

	delete mInterpreter;
  delete mGlobalFrame;
  delete mOutputFrame;
	delete mEnv;
  delete mRecordActivationRecord;
  delete mGlobalVariables;
  delete mRuntime;
}

void RunTimeExpressionGeneratorActivation::Start()
{
  mLogger = MetraFlowLoggerManager::GetLogger("[RunTimeExpressionGenerator]");

  mGlobalFrame = new GeneratorGlobalEnvironmentFrame;
  mOutputFrame = new RecordFrame(mOperator->mMerger.GetRecordMetadata());
	mEnv = new DualCompileEnvironment(mLogger, mGlobalFrame, mOutputFrame, "@", "");
  std::map<std::string, int> globalVariables;
  globalVariables["@@RECORDCOUNT"] = RuntimeValue::TYPE_BIGINTEGER;
  globalVariables["@@PARTITION"] = RuntimeValue::TYPE_INTEGER;
  globalVariables["@@PARTITIONCOUNT"] = RuntimeValue::TYPE_INTEGER;
	mInterpreter = new MTSQLInterpreter(mEnv, globalVariables);
  mInterpreter->setSupportVarchar(true);
	mExe = mInterpreter->analyze(mOperator->mProgram.c_str());
  ASSERT(mExe);
  mExe->codeGenerate(mEnv);

  mRecordActivationRecord = new RecordActivationRecord(NULL);
  mGlobalVariables = new GeneratorGlobalEnvironment(GetPartition(), mOperator->mNumPartitions);
  mRuntime = new DualRuntimeEnvironment(mLogger, mGlobalVariables, mRecordActivationRecord);

  // Set up a buffer to merge outputs from (just NULL by default)
  mOutputBuffer = mOperator->mOutputMetadata.Allocate();

  RequestRead(0);
  mState = READ_0;
}

void RunTimeExpressionGeneratorActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case READ_0:
    Read(mInputMessage, ep);
    if (!mOperator->mInputMetadata.IsEOF(mInputMessage))
    {
      // Merge the records and then invoke interpreter to set values.
      mOutputMessage = mOperator->mMerger.GetRecordMetadata()->Allocate();
      mOperator->mMerger.Merge(mInputMessage, mOutputBuffer, mOutputMessage, true, false);
      mOperator->mInputMetadata.ShallowFree(mInputMessage);
      mInputMessage = NULL;
      mRecordActivationRecord->SetBuffer(mOutputMessage);
      mExe->execCompiled(mRuntime);
      RequestWrite(0);
      mState = WRITE_OUTPUT_0;
      return;
    case WRITE_OUTPUT_0:;
      Write(mOutputMessage, ep);
      mGlobalVariables->SetNumRecords(mGlobalVariables->GetNumRecords() + 1LL);
      mOutputMessage = NULL;
      RequestRead(0);
      mState = READ_0;
      return;
    }
    else
    {
      mOperator->mInputMetadata.Free(mInputMessage);
      RequestWrite(0);
      mState = WRITE_EOF_0;
      return;
    case WRITE_EOF_0:;
      Write(mOperator->mMerger.GetRecordMetadata()->AllocateEOF(), ep, true);
      return;
    }
  }
}

DesignTimeGenerator::DesignTimeGenerator()
  :
  mProgramOutputMetadata(NULL),
  mNumRecords(1LL)
{
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeGenerator::~DesignTimeGenerator()
{
  delete mProgramOutputMetadata;
}

void DesignTimeGenerator::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"program", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetProgram(arg.getNormalizedString());
  }
  else if (arg.is(L"numRecords", OPERATOR_ARG_TYPE_INTEGER, GetName()))
  {
    SetNumRecords(arg.getIntValue());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeGenerator* DesignTimeGenerator::clone(
                                            const std::wstring& name,
                                            std::vector<OperatorArg *>& args, 
                                            int nInputs, int nOutputs) const
{
  DesignTimeGenerator* result = new DesignTimeGenerator();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeGenerator::type_check()
{
  // The generator uses a kind of hacky concept of global variables in MTSQL.
  // There are two points to make about global variables.  First is that they
  // come from class member variables of the RunTimeGenerator.  The second is
  // that they don't need to be declared in a program.
  // The first aspect is handled by using a dual compile environment.
  // The second is handled by manually whacking the compile environment prior
  // to compilation and inserting the global variables into the symbol table.
  
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[DesignTimeGenerator]");
  
  // Create a list of global variables we support.
  std::map<std::string, int> globalVariables;
  globalVariables["@@RECORDCOUNT"] = RuntimeValue::TYPE_BIGINTEGER;
  globalVariables["@@PARTITION"] = RuntimeValue::TYPE_INTEGER;
  globalVariables["@@PARTITIONCOUNT"] = RuntimeValue::TYPE_INTEGER;

  // At this point, we don't know what outputs appear in the program.
  // Compile against a special environment that will allow us to extract
  // the outputs and build the output metadata.  Then do a second typecheck
  // against an environment that encapsulates the input and output metadata.
  RecordCompileEnvironment dummyEnvironment(logger, new SimpleFrame());
  MTSQLInterpreter dummyInterpreter(&dummyEnvironment, globalVariables);
  dummyInterpreter.setSupportVarchar(true);
  MTSQLExecutable * dummyExecutable = dummyInterpreter.analyze(mProgram.c_str());

  // Grab the output parameters and construct the output record format.
  const std::vector<MTSQLParam>& params = dummyInterpreter.getProgramParams();
  LogicalRecord outputMembers;
  for(std::vector<MTSQLParam>::const_iterator it = params.begin();
      it != params.end();
      it++)
  {
    std::string nm = it->GetName();
    if (globalVariables.end() != globalVariables.find(nm)) continue;
    // Strip off leading @ and convert to Unicode.
    std::wstring outputName;
    ::ASCIIToWide(outputName, nm.substr(1, nm.size()-1));
    outputMembers.push_back(RecordMember(outputName, 
                                         LogicalFieldType::Get(*it)));
  }
  mProgramOutputMetadata = new RecordMetadata(outputMembers);
  
  // Now do a typecheck against a real environment comprising
  // the global variables and the calculated record format.
  GeneratorGlobalEnvironmentFrame globalFrame;
  RecordFrame outputFrame(mProgramOutputMetadata);
  // Global variables are of the form @@* and these come from the globalFrame
  DualCompileEnvironment realEnvironment(logger, &globalFrame, &outputFrame, "@", "");

  MTSQLInterpreter realInterpreter(&realEnvironment, globalVariables);
  realInterpreter.setSupportVarchar(true);
  MTSQLExecutable  * realExe = realInterpreter.analyze(mProgram.c_str());
  if (NULL == realExe) 
  {
    throw MtsqlCompilationException(*this);
  }

  // Everything cool.  
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mProgramOutputMetadata));
}

RunTimeOperator * DesignTimeGenerator::code_generate(partition_t maxPartition)
{
  return new RunTimeGenerator(mName, maxPartition,
                              *mOutputPorts[0]->GetMetadata(),
                              mProgram,
                              mNumRecords);
}

PhysicalFieldType DesignTimeGenerator::GetPhysicalFieldType(int ty)
{
  switch(ty)
  {
  case MTSQLParam::TYPE_INVALID: throw std::runtime_error("TYPE_INVALID seen in Expresssion");
  case MTSQLParam::TYPE_INTEGER: return PhysicalFieldType::Integer();
  case MTSQLParam::TYPE_DOUBLE: return PhysicalFieldType::Double();
  case MTSQLParam::TYPE_STRING: return PhysicalFieldType::UTF8StringDomain();
  case MTSQLParam::TYPE_BOOLEAN: return PhysicalFieldType::Boolean();
  case MTSQLParam::TYPE_DECIMAL: return PhysicalFieldType::Decimal();
  case MTSQLParam::TYPE_DATETIME: return PhysicalFieldType::Datetime();
  case MTSQLParam::TYPE_TIME: return PhysicalFieldType::Datetime(); 
  case MTSQLParam::TYPE_ENUM: return PhysicalFieldType::Enum();
  case MTSQLParam::TYPE_WSTRING: return PhysicalFieldType::StringDomain();
  case MTSQLParam::TYPE_NULL: throw std::runtime_error("TYPE_INVALID seen in Expresssion");
  case MTSQLParam::TYPE_BIGINTEGER: return PhysicalFieldType::BigInteger();
  case MTSQLParam::TYPE_BINARY: return PhysicalFieldType::Binary();
  default: throw std::runtime_error("Invalid MTSQL type seen in Generator");
  }
}

RunTimeGenerator::RunTimeGenerator()
  :
  mNumRecords(0LL)
{
}

RunTimeGenerator::RunTimeGenerator(const std::wstring& name, 
                                   partition_t maxPartition,
                                   const RecordMetadata& outputMetadata,
                                   const std::wstring& program,
                                   boost::int64_t numRecords)
  : 
  RunTimeOperator(name),
  mOutputMetadata(outputMetadata),
  mProgram(program),
  mNumRecords(numRecords),
  mNumPartitions(maxPartition)
{
}
RunTimeGenerator::~RunTimeGenerator()
{
}

RunTimeOperatorActivation * RunTimeGenerator::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeGeneratorActivation(reactor, partition, this);
}

RunTimeGeneratorActivation::RunTimeGeneratorActivation(Reactor * reactor, 
                                                       partition_t partition,
                                                       const RunTimeGenerator * runTimeOperator)
  : 
  RunTimeOperatorActivationImpl<RunTimeGenerator>(reactor, partition, runTimeOperator),
  mState(START),
  mOutputMessage(NULL),
	mInterpreter(NULL),
	mExe(NULL),
  mGlobalFrame(NULL),
  mOutputFrame(NULL),
	mEnv(NULL),
  mRecordActivationRecord(NULL),
  mGlobalVariables(NULL),
  mRuntime(NULL)
{
}
RunTimeGeneratorActivation::~RunTimeGeneratorActivation()
{
	delete mInterpreter;
  delete mGlobalFrame;
  delete mOutputFrame;
	delete mEnv;
  delete mRecordActivationRecord;
  delete mGlobalVariables;
  delete mRuntime;
}

void RunTimeGeneratorActivation::Start()
{
  mLogger = MetraFlowLoggerManager::GetLogger("[RunTimeGenerator]");

  mGlobalFrame = new GeneratorGlobalEnvironmentFrame;
  mOutputFrame = new RecordFrame(&mOperator->mOutputMetadata);
	mEnv = new DualCompileEnvironment(mLogger, mGlobalFrame, mOutputFrame, "@", "");
  std::map<std::string, int> globalVariables;
  globalVariables["@@RECORDCOUNT"] = RuntimeValue::TYPE_BIGINTEGER;
  globalVariables["@@PARTITION"] = RuntimeValue::TYPE_INTEGER;
  globalVariables["@@PARTITIONCOUNT"] = RuntimeValue::TYPE_INTEGER;
	mInterpreter = new MTSQLInterpreter(mEnv, globalVariables);
  mInterpreter->setSupportVarchar(true);
	mExe = mInterpreter->analyze(mOperator->mProgram.c_str());
  ASSERT(mExe);
  mExe->codeGenerate(mEnv);

  mRecordActivationRecord = new RecordActivationRecord(NULL);
  mGlobalVariables = new GeneratorGlobalEnvironment(GetPartition(), mOperator->mNumPartitions);
  mRuntime = new DualRuntimeEnvironment(mLogger, mGlobalVariables, mRecordActivationRecord);

  mState = START;
  HandleEvent(NULL);
}

void RunTimeGeneratorActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(mGlobalVariables->GetNumRecords() < mOperator->mNumRecords)
    {
      mOutputMessage = mOperator->mOutputMetadata.Allocate();
      mRecordActivationRecord->SetBuffer(mOutputMessage);
      mExe->execCompiled(mRuntime);
      mGlobalVariables->SetNumRecords(mGlobalVariables->GetNumRecords() + 1LL);
      RequestWrite(0);
      mState = WRITE_OUTPUT_0;
      return;
  case WRITE_OUTPUT_0:
      Write(mOutputMessage, ep);
      mOutputMessage = NULL;
    }

    // All done, write EOF
    RequestWrite(0);
    mState = WRITE_EOF_0;
    return;
  case WRITE_EOF_0:
    Write(mOperator->mOutputMetadata.AllocateEOF(), ep, true);
    return;
  }
}

