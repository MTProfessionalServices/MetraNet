#include "SortRunningTotal.h"
// MTSQL stuff
#include "BooleanPredicateInterface.h"
#include "Environment.h"
#include "OperatorArg.h"

DesignTimeSortRunningAggregate::DesignTimeSortRunningAggregate(int numInputs)
  :
  mAccumulator(NULL),
  mPreIncrement(false),
  mOutputFinalTotals(false),
  mInitializeTable(false),
  mMerger(NULL),
  mNumBuckets(32)
{
  if (numInputs == 1)
    mInputPorts.insert(this, 0, L"input", false);
  else
  {
    for(int i=0; i<numInputs; i++)
    {
      mInputPorts.push_back(this, (boost::wformat(L"input(%1%)") % i).str(), false);
    }
  }

  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeSortRunningAggregate::~DesignTimeSortRunningAggregate()
{
  delete mAccumulator;
  delete mMerger;
}

void DesignTimeSortRunningAggregate::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mGroupByKeys.push_back(arg.getNormalizedString());
    AddSortKey(DesignTimeSortKey(arg.getNormalizedString(), 
                                 SortOrder::ASCENDING));
  }
  else if (arg.is(L"sortKey", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddSortKey(DesignTimeSortKey(arg.getNormalizedString(), 
                                 SortOrder::ASCENDING));
  }
  else if (arg.is(L"initialize", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetInitializeProgram(arg.getNormalizedString());
  }
  else if (arg.is(L"update", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    DesignTimeHashRunningAggregateInputSpec spec(mGroupByKeys,
                                                 arg.getNormalizedString());
    AddInputSpec(spec);
  }
  else if (arg.is(L"preIncrement", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    SetPreIncrement(arg.getBoolValue());
  }
  else if (arg.is(L"outputGroupBy", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    SetOutputFinalTotals(arg.getBoolValue());
  }
  else if (arg.is(L"initializeTable", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    SetInitializeTable(arg.getBoolValue());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeSortRunningAggregate* DesignTimeSortRunningAggregate::clone(
                                  const std::wstring& name,
                                  std::vector<OperatorArg *>& args, 
                                  int nExtraInputs, int nExtraOutputs) const
{
  DesignTimeSortRunningAggregate* result = 
      new DesignTimeSortRunningAggregate(mInputPorts.size() + nExtraInputs);

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeSortRunningAggregate::DeduplicateGroupByKeys(const std::vector<std::wstring>& groupByKeys,
                                                            std::vector<std::wstring>& dedupedGroupByKeys)
{
  std::set<std::wstring> keys;
  for(std::vector<std::wstring>::const_iterator it = groupByKeys.begin();
      it != groupByKeys.end();
      ++it)
  {
    if(keys.end() != keys.find(boost::to_upper_copy(*it)))
      continue;
    keys.insert(boost::to_upper_copy(*it));
    dedupedGroupByKeys.push_back(*it);
  }
}

void DesignTimeSortRunningAggregate::type_check()
{
  // Dedup and reset values of group by keys
  DeduplicateGroupByKeys(mGroupByKeys, mDedupedGroupByKeys);
  for(std::vector<DesignTimeHashRunningAggregateInputSpec>::iterator it = mInputSpecs.begin();
      it != mInputSpecs.end();
      ++it)
  {
    it->SetGroupByKeys(mDedupedGroupByKeys);
  }

  // 1 - port per aggregated input + 1 for table (optional)
  ASSERT(mInputPorts.size() == mInputSpecs.size()+(mInitializeTable ? 1 : 0));
  const RecordMetadata * inputMetadata = mInputPorts[0]->GetMetadata();
  const LogicalRecord& input(mInputPorts[0]->GetLogicalMetadata());

  if (mInputSpecs.size() == 1)
  {
    const std::wstring & accumulateProgram(mInputSpecs[0].GetUpdateProgram());

    // First figure out if we have been configured with explicit programs
    // or the ad-hoc summation interface.
    if ((mInitializeProgram.size() == 0 && accumulateProgram.size() > 0) ||
        (mInitializeProgram.size() > 0 && accumulateProgram.size() == 0) )
      throw std::runtime_error("Must specify both InitializeProgram and UpdateProgram to Hash Running Aggregate");
  }

  // Constrain the types of the input group keys to be the same as one another.
  for(std::size_t i=1; i<mInputSpecs.size(); i++)
  {
    if (mInputSpecs[0].GetGroupByKeys().size() != mInputSpecs[i].GetGroupByKeys().size())
    {
      throw std::logic_error("All input key sets must have the same size");
    }
    std::vector<std::wstring> a(mInputSpecs[0].GetGroupByKeys());
    std::vector<std::wstring> b(mInputSpecs[i].GetGroupByKeys());
    const RecordMetadata * aMetadata = inputMetadata;
    const RecordMetadata * bMetadata = mInputPorts[i]->GetMetadata();
    for(std::size_t j=0; j<a.size(); j++)
    {
      if (!aMetadata->HasColumn(a[j])) 
      {
        throw MissingFieldException(*this, *mInputPorts[0], a[j]);
      }
      if (!bMetadata->HasColumn(b[j])) 
      {
        throw MissingFieldException(*this, *mInputPorts[i], b[j]);
      }
      if (*aMetadata->GetColumn(a[j])->GetPhysicalFieldType() != 
          *bMetadata->GetColumn(b[j])->GetPhysicalFieldType()) 
      {
        throw FieldTypeMismatchException(*this, 
                                         *mInputPorts[0], *aMetadata->GetColumn(a[j]),
                                         *mInputPorts[i], *aMetadata->GetColumn(b[j]));
      }      
    }
  }

  // Define the table metadata. We have group keys and "counters".  The counter info may
  // be discovered by looking at the initialize program.  Do a fake compile of the initializer
  // to discover this.  We'll get the key info separately.
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[DesignTimeSortRunningAggregate]");
  RecordCompileEnvironment dummyEnvironment(logger, new SimpleFrame());
  MTSQLInterpreter dummyInterpreter(&dummyEnvironment);
  dummyInterpreter.setSupportVarchar(true);
  MTSQLExecutable * dummyExecutable = dummyInterpreter.analyze(mInitializeProgram.c_str());

  // Grab the output parameters and construct the output record format.
  const std::vector<MTSQLParam>& params = dummyInterpreter.getProgramParams();

  // Copy the group by keys from the first input into an accumulator metadata structure 
  const std::vector<std::wstring> groupByKeyNames(mInputSpecs[0].GetGroupByKeys());
  LogicalRecord accumulatorMembers;
  for(std::vector<std::wstring>::const_iterator it = groupByKeyNames.begin();
      it != groupByKeyNames.end();
      it++)
  {
    // Find out whether this is a group key
    if (!input.HasColumn(*it))
    {
      throw MissingFieldException(*this, *mInputPorts[0], *it);
    }
    std::wstring accumulatorKeyName = *it + std::wstring(L"#");
    mAccumulatorGroupByKeyNames.push_back(accumulatorKeyName);
    // Add to the output record
    // Save accessor for later transfers
    accumulatorMembers.push_back(RecordMember(accumulatorKeyName, 
                                              input.GetColumn(*it).GetType()));
  }

  for(std::vector<MTSQLParam>::const_iterator it = params.begin();
      it != params.end();
      it++)
  {  
    std::string nm = it->GetName();

    // Skip any probe records.
    if (boost::algorithm::iequals("@Probe_", nm.substr(0,7).c_str()))
      continue;

    // Strip off leading @Table_ if necessary and convert to Unicode.
    std::wstring outputName;
    ::ASCIIToWide(outputName, 
                  nm.size() >= 7 && boost::algorithm::iequals("@Table_", nm.substr(0,7).c_str()) ?  nm.substr(7) : nm.substr(1));
    accumulatorMembers.push_back(RecordMember(outputName, 
                                              LogicalFieldType::Get(*it)));
  }

  mAccumulator = new RecordMetadata(accumulatorMembers);
  // Test compile all of the update programs.

  // Check that a configured table input has the same schema as the initializer
  if (mInitializeTable)
  {
    // TODO: Allow unmunged group by key values into the accumulator
    const RecordMetadata * otherMetadata = mInputPorts.back()->GetMetadata();
    if (!mAccumulator->LogicalEquals(*otherMetadata))
      throw AggregateTableException(*this, *mInputPorts.back(), *otherMetadata);
  }

  // Create the merged record and set output metadata.
  mMerger = new RecordMerge(inputMetadata, mAccumulator);
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mMerger->GetRecordMetadata()));
}

RunTimeOperator * DesignTimeSortRunningAggregate::code_generate(partition_t maxPartition)
{
  // Create run time sort key specs
  std::vector<RunTimeSortKey> runTimeSortKey;
  for(std::vector<DesignTimeSortKey>::iterator it = mSortKey.begin();
      it != mSortKey.end();
      it++)
  {
    runTimeSortKey.push_back(RunTimeSortKey(it->GetSortKeyName(), it->GetSortOrder(), NULL));
  }

  // Create the run time input specs
  std::vector<RunTimeHashRunningAggregateInputSpec> runTimeInputSpecs;
  runTimeInputSpecs.push_back(RunTimeHashRunningAggregateInputSpec(*mInputPorts[0]->GetMetadata(),
                                                                   *mMerger,
                                                                   mInputSpecs[0].GetUpdateProgram(),
                                                                   mInputSpecs[0].GetGroupByKeys(),
                                                                   runTimeSortKey));
  for(std::size_t i=1; i<mInputSpecs.size(); i++)
  {
    runTimeInputSpecs.push_back(RunTimeHashRunningAggregateInputSpec(*mInputPorts[i]->GetMetadata(),
                                                                     mInputSpecs[i].GetUpdateProgram(),
                                                                     mInputSpecs[i].GetGroupByKeys(),
                                                                     runTimeSortKey));
  }

  return new RunTimeSortRunningAggregate(GetName(),
                                         runTimeInputSpecs,
                                         *mAccumulator, 
                                         mAccumulatorGroupByKeyNames,
                                         mInitializeProgram,
                                         mNumBuckets,
                                         mPreIncrement,
                                         mOutputFinalTotals,
                                         mInitializeTable);
}

void DesignTimeSortRunningAggregate::AddGroupByKey(const std::wstring& groupByKey)
{
  ASSERT(mInputPorts.size() == 1);
  if (mInputSpecs.size() == 0)
    mInputSpecs.push_back(DesignTimeHashRunningAggregateInputSpec());
  mInputSpecs[0].AddGroupByKey(groupByKey);
}

void DesignTimeSortRunningAggregate::SetGroupByKeys(const std::vector<std::wstring>& groupByKeys)
{
  ASSERT(mInputPorts.size() == 1);
  if (mInputSpecs.size() == 0)
    mInputSpecs.push_back(DesignTimeHashRunningAggregateInputSpec());
  mInputSpecs[0].SetGroupByKeys(groupByKeys);
}

void DesignTimeSortRunningAggregate::SetInitializeProgram(const std::wstring& initializeProgram)
{
  mInitializeProgram = initializeProgram;
}

void DesignTimeSortRunningAggregate::SetUpdateProgram(const std::wstring& updateProgram)
{
  ASSERT(mInputPorts.size() == 1);
  if (mInputSpecs.size() == 0)
    mInputSpecs.push_back(DesignTimeHashRunningAggregateInputSpec());
  mInputSpecs[0].SetUpdateProgram(updateProgram);
}

void DesignTimeSortRunningAggregate::SetInputSpecs(const std::vector<DesignTimeHashRunningAggregateInputSpec>& inputSpecs)
{
  mInputSpecs = inputSpecs;
}

void DesignTimeSortRunningAggregate::AddInputSpec(const DesignTimeHashRunningAggregateInputSpec& inputSpec)
{
  mInputSpecs.push_back(inputSpec);
}

void DesignTimeSortRunningAggregate::AddSortKey(const DesignTimeSortKey& aKey)
{
  mSortKey.push_back(aKey);
}

void DesignTimeSortRunningAggregate::SetPreIncrement(bool preIncrement)
{
  mPreIncrement = preIncrement;
}

void DesignTimeSortRunningAggregate::SetOutputFinalTotals(bool outputFinalTotals)
{
  mOutputFinalTotals = outputFinalTotals;
}

void DesignTimeSortRunningAggregate::SetInitializeTable(bool initializeTable)
{
  mInitializeTable = initializeTable;
}

PhysicalFieldType DesignTimeSortRunningAggregate::GetPhysicalFieldType(int ty)
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
  default: throw std::runtime_error("Invalid MTSQL type seen in Expression");
  }
}

std::wstring DesignTimeSortRunningAggregate::GetMTSQLDatatype(DataAccessor * accessor)
{
  switch(accessor->GetPhysicalFieldType()->GetPipelineType())
  {
  case MTPipelineLib::PROP_TYPE_INTEGER: return L"INTEGER";
	case MTPipelineLib::PROP_TYPE_DOUBLE: return L"DOUBLE PRECISION";
	case MTPipelineLib::PROP_TYPE_STRING: return L"NVARCHAR";
	case MTPipelineLib::PROP_TYPE_DATETIME: return L"DATETIME";
	case MTPipelineLib::PROP_TYPE_TIME: return L"DATETIME";
	case MTPipelineLib::PROP_TYPE_BOOLEAN: return L"BOOLEAN";
	case MTPipelineLib::PROP_TYPE_ENUM: return L"ENUM";
	case MTPipelineLib::PROP_TYPE_DECIMAL: return L"DECIMAL";
  case MTPipelineLib::PROP_TYPE_ASCII_STRING: return L"VARCHAR";
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING: return L"NVARCHAR";
  case MTPipelineLib::PROP_TYPE_BIGINTEGER: return L"BIGINT";
  case MTPipelineLib::PROP_TYPE_OPAQUE: return L"BINARY";
	default: throw std::runtime_error("Unsupported data type");
  }
}

RunTimeSortRunningAggregateInputSpecActivation::RunTimeSortRunningAggregateInputSpecActivation(
  const RunTimeHashRunningAggregateInputSpec * inputSpec)
  :
  mInputSpec(inputSpec),
  mAccumulatorInterpreter(NULL),
  mAccumulatorExe(NULL),
  mAccumulatorProbeFrame(NULL),
  mAccumulatorTableFrame(NULL),
  mAccumulatorProbeActivationRecord(NULL),
  mAccumulatorTableActivationRecord(NULL),
  mAccumulatorEnv(NULL),
  mAccumulatorRuntime(NULL)
{
}

RunTimeSortRunningAggregateInputSpecActivation::~RunTimeSortRunningAggregateInputSpecActivation()
{
  delete mAccumulatorProbeFrame;
  delete mAccumulatorTableFrame;
  delete mAccumulatorEnv;
  delete mAccumulatorInterpreter;
  delete mAccumulatorProbeActivationRecord;
  delete mAccumulatorTableActivationRecord;
  delete mAccumulatorRuntime;
}

void RunTimeSortRunningAggregateInputSpecActivation::Start(const RecordMetadata& accumulator, 
                                                           MetraFlowLoggerPtr logger)
{
  // Extract the accessors for the group by keys 
  for(std::vector<std::wstring>::const_iterator it = mInputSpec->mInputGroupByKeyNames.begin();
      it != mInputSpec->mInputGroupByKeyNames.end();
      it++)
  {
    ASSERT(mInputSpec->mInput.HasColumn(*it));
    mInputGroupByKeys.push_back(RunTimeSortKey(*it, SortOrder::ASCENDING, mInputSpec->mInput.GetColumn(*it)));
  }

  if (mInputSpec->mAccumulatorProgram.size() > 0)
  {
    //
    // The Accumulator
    //
    mAccumulatorProbeFrame = new RecordFrame(&mInputSpec->mInput);
    mAccumulatorTableFrame = new RecordFrame(&accumulator);
    // Variables @Probe_* come from the probe record, @Table_* come from the LUT
    mAccumulatorEnv = new DualCompileEnvironment(logger, 
                                                 mAccumulatorProbeFrame, mAccumulatorTableFrame, "Probe_", "Table_");
    mAccumulatorInterpreter = new MTSQLInterpreter(mAccumulatorEnv);
    mAccumulatorInterpreter->setSupportVarchar(true);
    mAccumulatorExe = mAccumulatorInterpreter->analyze(mInputSpec->mAccumulatorProgram.c_str());
    if (NULL == mAccumulatorExe) 
    {
      std::string utf8Program;
      ::WideStringToUTF8(mInputSpec->mAccumulatorProgram, utf8Program);
      throw std::runtime_error((boost::format("Error compiling counter update procedure: %1%") % 
                            utf8Program).str().c_str());
    }
    mAccumulatorExe->codeGenerate(mAccumulatorEnv);
    mAccumulatorProbeActivationRecord = new RecordActivationRecord(NULL);
    mAccumulatorTableActivationRecord = new RecordActivationRecord(NULL);
    mAccumulatorRuntime = new DualRuntimeEnvironment(logger, 
                                                     mAccumulatorProbeActivationRecord, 
                                                     mAccumulatorTableActivationRecord);
  }
}

void RunTimeSortRunningAggregateInputSpecActivation::Initialize(record_t inputMessage,
                                                      record_t accumulator, 
                                                      const std::vector<RunTimeSortKey>& accumulatorGroupByKeys)
{
  ASSERT(mInputGroupByKeys.size() == accumulatorGroupByKeys.size());
  for(std::size_t i = 0; i<mInputGroupByKeys.size(); i++)
  {
    accumulatorGroupByKeys[i].GetDataAccessor()->SetValue(accumulator, 
                                        mInputGroupByKeys[i].GetDataAccessor()->GetValue(inputMessage));
  }
}

void RunTimeSortRunningAggregateInputSpecActivation::Update(record_t inputMessage, record_t accumulator)
{
  if(mAccumulatorExe != NULL)
  {
    mAccumulatorProbeActivationRecord->SetBuffer(inputMessage);
    mAccumulatorTableActivationRecord->SetBuffer(accumulator);
    mAccumulatorExe->execCompiled(mAccumulatorRuntime);
  }
}

int RunTimeSortRunningAggregateInputSpecActivation::Compare(record_t inputMessage, 
                                                             record_t accumulator, 
                                                             const std::vector<RunTimeSortKey>& accumulatorGroupByKeys)
{
  ASSERT(mInputGroupByKeys.size() == accumulatorGroupByKeys.size());
  std::vector<RunTimeSortKey>::const_iterator leftSortKeyIt = mInputGroupByKeys.begin();
  std::vector<RunTimeSortKey>::const_iterator rightSortKeyIt = accumulatorGroupByKeys.begin();

  int cmp=0;
  while(cmp==0 && leftSortKeyIt != mInputGroupByKeys.end())
  {
    cmp = leftSortKeyIt->GetDataAccessor()->Compare(inputMessage, rightSortKeyIt->GetDataAccessor(), accumulator);

    ++leftSortKeyIt;
    ++rightSortKeyIt;
  }

  return leftSortKeyIt == mInputGroupByKeys.end() || leftSortKeyIt->GetSortOrder() == SortOrder::ASCENDING ? cmp : -cmp;
}

const RecordMetadata& RunTimeSortRunningAggregateInputSpecActivation::GetMetadata() const
{
  return mInputSpec->mInput;
}

const RecordMerge& RunTimeSortRunningAggregateInputSpecActivation::GetMerger() const
{
  return mInputSpec->mMerger;
}

void RunTimeSortRunningAggregateInputSpecActivation::ExportSortKey(QueueElement& e)
{
  for (std::vector<RunTimeSortKey>::const_iterator it = mInputSpec->mSortKey.begin();
       it != mInputSpec->mSortKey.end();
       it++)
  {
    it->GetDataAccessor()->ExportSortKey(e.mMsgPtr, it->GetSortOrder(), e);
  } 
}

RunTimeSortRunningAggregate::RunTimeSortRunningAggregate(const std::wstring& name, 
                                                         const std::vector<RunTimeHashRunningAggregateInputSpec>& inputSpecs,
                                                         const RecordMetadata& accumulatorMetadata,
                                                         const std::vector<std::wstring>& accumulatorGroupByKeys,
                                                         const std::wstring & initializerProgram,
                                                         boost::int32_t numBuckets,
                                                         bool preIncrement,
                                                         bool outputFinalTotals,
                                                         bool initializeTable)
  :
  RunTimeOperator(name),
  mAccumulatorGroupByKeyNames(accumulatorGroupByKeys),
  mInputSpecs(inputSpecs),
  mAccumulator(accumulatorMetadata),
  mInitializerProgram(initializerProgram),
  mNumBuckets(numBuckets),
  mPreIncrement(preIncrement),
  mOutputFinalTotals(outputFinalTotals),
  mInitializeTable(initializeTable)
{
}

RunTimeSortRunningAggregate::~RunTimeSortRunningAggregate()
{
}

RunTimeOperatorActivation * RunTimeSortRunningAggregate::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeSortRunningAggregateActivation(reactor, partition, this);
}

RunTimeSortRunningAggregateActivation::RunTimeSortRunningAggregateActivation(Reactor * reactor, 
                                                                             partition_t partition, 
                                                                             const RunTimeSortRunningAggregate * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeSortRunningAggregate>(reactor, partition, runTimeOperator),
  mInitializerInterpreter(NULL),
  mInitializerExe(NULL),
  mInitializerProbeFrame(NULL),
  mInitializerTableFrame(NULL),
  mInitializerProbeActivationRecord(NULL),
  mInitializerTableActivationRecord(NULL),
  mInitializerEnv(NULL),
  mInitializerRuntime(NULL),
  mActiveInput(NULL),
  mState(READ_0),
  mProcessed(0LL),
  mNullMessage(NULL),
  mOutputMessage(NULL),
  mAccumulatorMessage(NULL)
{
}

RunTimeSortRunningAggregateActivation::~RunTimeSortRunningAggregateActivation()
{
  if (mNullMessage)
    mInputSpecActivations[0].GetMetadata().Free(mNullMessage);
    
  delete mInitializerProbeFrame;
  delete mInitializerTableFrame;
  delete mInitializerEnv;
  delete mInitializerInterpreter;
  delete mInitializerProbeActivationRecord;
  delete mInitializerTableActivationRecord;
  delete mInitializerRuntime;
  for(std::size_t i=0;i<mQueueElements.size();i++)
  {
    delete mQueueElements[i];
  }
}

void RunTimeSortRunningAggregateActivation::Start()
{
  mLogger = MetraFlowLoggerManager::GetLogger((boost::format("[RunTimeSortRunningAggregate(%1%)]") % 
                                               mPartition).str().c_str());
  // Create activations for all input specs
  for(std::vector<RunTimeHashRunningAggregateInputSpec>::const_iterator it = mOperator->mInputSpecs.begin();
      it != mOperator->mInputSpecs.end();
      ++it)
  {
    mInputSpecActivations.push_back(RunTimeSortRunningAggregateInputSpecActivation(&*it));
  }

  // Extract the accessors for the group by keys 
  for(std::vector<std::wstring>::const_iterator it = mOperator->mAccumulatorGroupByKeyNames.begin();
      it != mOperator->mAccumulatorGroupByKeyNames.end();
      it++)
  {
    DatabaseColumn * c = mOperator->mAccumulator.GetColumn(*it);
    ASSERT(c != NULL);
    mAccumulatorGroupByKeys.push_back(RunTimeSortKey(*it, SortOrder::ASCENDING, c));
  }
  
  //
  // The Initializer
  //
  // TODO: Don't really need this probe frame
  mInitializerProbeFrame = new RecordFrame(&mInputSpecActivations[0].GetMetadata());
  mInitializerTableFrame = new RecordFrame(&mOperator->mAccumulator);
  // Variables @Probe_* come from the probe record, @Table_* come from the LUT
  mInitializerEnv = new DualCompileEnvironment(mLogger, 
                                               mInitializerProbeFrame, mInitializerTableFrame, "Probe_", "Table_");
  mInitializerInterpreter = new MTSQLInterpreter(mInitializerEnv);
  mInitializerInterpreter->setSupportVarchar(true);
  mInitializerExe = mInitializerInterpreter->analyze(mOperator->mInitializerProgram.c_str());
  if (NULL == mInitializerExe) 
  {
    std::string utf8Program;
    ::WideStringToUTF8(mOperator->mInitializerProgram, utf8Program);
    throw std::runtime_error((boost::format("Error compiling counter initialization procedure: %1%") % 
                          utf8Program).str().c_str());
  }
  mInitializerExe->codeGenerate(mInitializerEnv);
  mInitializerProbeActivationRecord = new RecordActivationRecord(NULL);
  mInitializerTableActivationRecord = new RecordActivationRecord(NULL);
  mInitializerRuntime = new DualRuntimeEnvironment(mLogger, 
                                                   mInitializerProbeActivationRecord, mInitializerTableActivationRecord);
  
  // Initialize all of the updaters
  for(std::vector<RunTimeSortRunningAggregateInputSpecActivation>::iterator it = mInputSpecActivations.begin();
      it != mInputSpecActivations.end();
      it++)
  {
    it->Start(mOperator->mAccumulator, mLogger);
  }

  // Make sure that can figure out which input we are process on a completed read.
  ASSERT(mInputs.size() == mInputSpecActivations.size() + (mOperator->mInitializeTable ? 1 : 0));
  for(std::size_t i=0; i<mInputSpecActivations.size(); i++)
  {
    mEndpointInputIndex[mInputs[i]] = &mInputSpecActivations[i];
    //Create queue elements, one for each input endpoint.
    mQueueElements.push_back(new QueueElement());
  }

  if (mOperator->mOutputFinalTotals)
  {
    // Create a record of NULLs on the first input.
    mNullMessage = mInputSpecActivations[0].GetMetadata().Allocate();
  }
  
  mTotalProcessed = 0LL;
  mTotalAccumulatorSize = 0;
  // Initialize the the multiplexer and make the first request.
  mState = START;
  HandleEvent(NULL);
}

void RunTimeSortRunningAggregateActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:

    if (mOperator->mInitializeTable)
    {
      // If we have a table initializer, read in initial record
      // because we in effect have to merge this stream with the
      // other inputs.
      mReactor->RequestRead(this, mInputs.back());
      mState = READ_TABLE_INIT;
      return;
    case READ_TABLE_INIT:
      Read(mAccumulatorMessage, mInputs.back());
    }

    // First read from each of the inputs so we can do sorted merge.
    mQueueElementsIt = mQueueElements.begin();
    for (mIt = mEndpointInputIndex.begin();
				 mIt != mEndpointInputIndex.end();
				 mIt++)
    {
      mActiveInput = mIt->second;
      mReactor->RequestRead(this, mIt->first);
      mState = READ_INIT;
      return;			
		case READ_INIT:
      ASSERT(mIt->first == ep);
      Read((*mQueueElementsIt)->mMsgPtr, ep);
      if (!mActiveInput->GetMetadata().IsEOF((*mQueueElementsIt)->mMsgPtr))
      {
        (*mQueueElementsIt)->mEp = ep;
        mActiveInput->ExportSortKey(*(*mQueueElementsIt));
        mPQ.push(*mQueueElementsIt);
      }
      else
      {
        mActiveInput->GetMetadata().Free((*mQueueElementsIt)->mMsgPtr);
        (*mQueueElementsIt)->mMsgPtr = NULL;
      }
      mQueueElementsIt++;
    }
    
    while(mPQ.size() > 0)
    {
      // Find the current input to process by looking
      // at the top of the priority queue.
      mActiveInput = mEndpointInputIndex.find(mPQ.top()->mEp)->second;
      mProcessed++;

      if (mOperator->mInitializeTable)
      {
        while(!mOperator->mAccumulator.IsEOF(mAccumulatorMessage) &&
              0 < mActiveInput->Compare(mPQ.top()->mMsgPtr, mAccumulatorMessage, mAccumulatorGroupByKeys))
        {
          if (mOperator->mOutputFinalTotals)
          {
            mOutputMessage = mInputSpecActivations[0].GetMerger().GetRecordMetadata()->Allocate();
            mInputSpecActivations[0].GetMerger().Merge(mNullMessage, mAccumulatorMessage, mOutputMessage, false, true);
            RequestWrite(0);
            mState = WRITE_TABLE;
            return;
          case WRITE_TABLE:
            Write(mOutputMessage, ep);
            mOutputMessage = NULL;
          }
          mOperator->mAccumulator.Free(mAccumulatorMessage);
          mAccumulatorMessage = NULL;
          mReactor->RequestRead(this, mInputs.back());
          mState = READ_TABLE;
          return;
        case READ_TABLE:
          Read(mAccumulatorMessage, ep);
        }
      }

      if(mPQ.size() > 0)
      {
        if (!mOperator->mAccumulator.IsEOF(mAccumulatorMessage) &&
            0 == mActiveInput->Compare(mPQ.top()->mMsgPtr, mAccumulatorMessage, mAccumulatorGroupByKeys))
        {
          mBuffer = mAccumulatorMessage;
        }
        else
        {
          // Create a new record with the group by keys and initialize accumulators.
          mBuffer = mOperator->mAccumulator.Allocate();
          // Initialize Group Keys
          mActiveInput->Initialize(mPQ.top()->mMsgPtr, mBuffer, mAccumulatorGroupByKeys);
          // Initialize counter values.  TODO: Eliminate Probe activation; it is unneeded.
          mInitializerProbeActivationRecord->SetBuffer(NULL);
          mInitializerTableActivationRecord->SetBuffer(mBuffer);
          mInitializerExe->execCompiled(mInitializerRuntime);
        }

        // Scan the right input for its sort run, computing the cross product
        // with the buffered left input.
        do
        {
          // Find the current input to process by looking
          // at the top of the priority queue.
          mActiveInput = mEndpointInputIndex.find(mPQ.top()->mEp)->second;
          if (0 != mActiveInput->Compare(mPQ.top()->mMsgPtr, mBuffer, mAccumulatorGroupByKeys)) break;

          if (mOperator->mPreIncrement)
          {
            mActiveInput->Update(mPQ.top()->mMsgPtr, mBuffer);
          }

          // Output merged first input 
          if (mActiveInput == &mInputSpecActivations[0])
          {
            // Merge running total statistics and output
            mOutputMessage = mActiveInput->GetMerger().GetRecordMetadata()->Allocate();
            // TODO: Figure out how to implement transfer without preincrement
            mActiveInput->GetMerger().Merge(mPQ.top()->mMsgPtr, mBuffer, mOutputMessage, mOperator->mPreIncrement, false);

            RequestWrite(0);
            mState = WRITE_0;
            return;
          case WRITE_0:
            Write(mOutputMessage, ep);
            mOutputMessage = NULL;
          }

          // Accumulate and free input.  We want the output the pre-incremented amount,
          // so this come after the output.
          if (!mOperator->mPreIncrement)
          {
            mActiveInput->Update(mPQ.top()->mMsgPtr, mBuffer);
          }

          mActiveInput->GetMetadata().Free(mPQ.top()->mMsgPtr);
          mPQ.top()->mMsgPtr = NULL;
      
          mReactor->RequestRead(this, mPQ.top()->mEp);
          mState = READ_0;
          return;
        case READ_0:
          mCurrentQueueElement = mPQ.top();
          Read(mCurrentQueueElement->mMsgPtr,ep);
          mActiveInput = mEndpointInputIndex.find(ep)->second;
          mPQ.pop();
          if (!mActiveInput->GetMetadata().IsEOF(mCurrentQueueElement->mMsgPtr))
          {
            mCurrentQueueElement->mEp = ep;
            mCurrentQueueElement->Clear();
            mActiveInput->ExportSortKey(*mCurrentQueueElement);
            mPQ.push(mCurrentQueueElement);
          }
          else
          {
            mActiveInput->GetMetadata().Free(mCurrentQueueElement->mMsgPtr);
            mCurrentQueueElement->mMsgPtr = NULL;
          }
        } while(mPQ.size() > 0);

        // No more matches.  Time to process a new key value.
        // If we allocated a new accumulator for this set of group
        // keys, finish up processing it here.
        if (mBuffer != mAccumulatorMessage)
        {
          if (mOperator->mOutputFinalTotals)
          {
            mOutputMessage = mInputSpecActivations[0].GetMerger().GetRecordMetadata()->Allocate();
            mInputSpecActivations[0].GetMerger().Merge(mNullMessage, mBuffer, mOutputMessage, false, true);
            RequestWrite(0);
            mState = WRITE_TABLE_BUFFER;
            return;
          case WRITE_TABLE_BUFFER:
            Write(mOutputMessage, ep);
            mOutputMessage = NULL;
          }
          mOperator->mAccumulator.Free(mBuffer);
          mBuffer = NULL;
        }
      }
      else
      {
        // We may have exhausted one side or the other
      }
    }

    if (mOperator->mInitializeTable)
    {
      while(!mOperator->mAccumulator.IsEOF(mAccumulatorMessage))
      {
        if (mOperator->mOutputFinalTotals)
        {
          mOutputMessage = mInputSpecActivations[0].GetMerger().GetRecordMetadata()->Allocate();
          mInputSpecActivations[0].GetMerger().Merge(mNullMessage, mAccumulatorMessage, mOutputMessage, false, true);
          RequestWrite(0);
          mState = WRITE_TABLE_DRAIN;
          return;
        case WRITE_TABLE_DRAIN:
          Write(mOutputMessage, ep);
          mOutputMessage = NULL;
        }
        mOperator->mAccumulator.Free(mAccumulatorMessage);
        mAccumulatorMessage = NULL;
        mReactor->RequestRead(this, mInputs.back());
        mState = READ_TABLE_DRAIN;
        return;
      case READ_TABLE_DRAIN:
        Read(mAccumulatorMessage, ep);
      }
    }

    // All done processing inputs.  Write EOF and we're outta here
    RequestWrite(0);
    mState = WRITE_EOF_0;
    return;
  case WRITE_EOF_0:;
    Write(mInputSpecActivations[0].GetMerger().GetRecordMetadata()->AllocateEOF(), ep, true);
    return;
  }
}
    
