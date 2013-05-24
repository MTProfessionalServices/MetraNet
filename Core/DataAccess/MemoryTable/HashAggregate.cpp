#include "HashAggregate.h"
#include "RecordParser.h"
#include "TypeCheckException.h"
#include "OperatorArg.h"
#include <boost/format.hpp>
#include <boost/algorithm/string/predicate.hpp>

#include <set>
#include <iostream>

// MTSQL stuff
#include "BooleanPredicateInterface.h"
#include "Environment.h"

#ifdef WIN32
// Id Generator stuff
#include <OdbcIdGenerator.h>
#endif

std::string AggregateTableException::CreateErrorString(const DesignTimeOperator& op, 
                                                           const Port& portA,
                                                           const RecordMetadata& expectedMetadata)
{
  ASSERT(portA.GetMetadata() != NULL);

  boost::wformat fmt(L"On operator '%1%', record format on port %2%(%3%)\nmust be the same as:\n%4%\n");
  fmt % op.GetName() % portA.GetName() % portA.GetMetadata()->ToString() 
    % expectedMetadata.ToString();
  std::string msg;
  ::WideStringToUTF8(fmt.str(), msg);
  return msg;
}

AggregateTableException::AggregateTableException(const DesignTimeOperator& op, 
                                                         const Port& portA,
                                                         const RecordMetadata& expectedMetadata)
  :
  logic_error(CreateErrorString(op, portA, expectedMetadata))
{
}

AggregateTableException::~AggregateTableException()
{
}

class MetraFlowDualRecordInterpreter
{
private:
	MTSQLInterpreter* mAccumulatorInterpreter;
	MTSQLExecutable* mAccumulatorExe;
  Frame * mAccumulatorProbeFrame;
  Frame * mAccumulatorTableFrame;
  RecordActivationRecord * mAccumulatorProbeActivationRecord;
  RecordActivationRecord * mAccumulatorTableActivationRecord;
	DualCompileEnvironment * mAccumulatorEnv;
  DualRuntimeEnvironment * mAccumulatorRuntime;
public:
  MetraFlowDualRecordInterpreter(const std::wstring& program,
                                 const RecordMetadata& lhs, 
                                 const RecordMetadata& rhs, 
                                 MetraFlowLoggerPtr logger);
  ~MetraFlowDualRecordInterpreter();
  void Execute(MessagePtr left, MessagePtr right)
  {
    mAccumulatorProbeActivationRecord->SetBuffer(left);
    mAccumulatorTableActivationRecord->SetBuffer(right);
    mAccumulatorExe->execCompiled(mAccumulatorRuntime);
  }  
  const RuntimeValue * ExecuteFunction(MessagePtr left, MessagePtr right)
  {
    mAccumulatorProbeActivationRecord->SetBuffer(left);
    mAccumulatorTableActivationRecord->SetBuffer(right);
    mAccumulatorExe->execCompiled(mAccumulatorRuntime);
    return mAccumulatorExe->getReturnValue();
  }  
};


MetraFlowDualRecordInterpreter::MetraFlowDualRecordInterpreter(const std::wstring& program,
                                                               const RecordMetadata& lhs, 
                                                               const RecordMetadata& rhs, 
                                                               MetraFlowLoggerPtr logger)
  :
  mAccumulatorInterpreter(NULL),
  mAccumulatorExe(NULL),
  mAccumulatorProbeFrame(NULL),
  mAccumulatorTableFrame(NULL),
  mAccumulatorProbeActivationRecord(NULL),
  mAccumulatorTableActivationRecord(NULL),
  mAccumulatorEnv(NULL),
  mAccumulatorRuntime(NULL)  
{
  mAccumulatorProbeFrame = new RecordFrame(&lhs);
  mAccumulatorTableFrame = new RecordFrame(&rhs);
  // Variables @Probe_* come from the probe record, @Table_* come from the LUT
  mAccumulatorEnv = new DualCompileEnvironment(logger, 
                                               mAccumulatorProbeFrame, mAccumulatorTableFrame, "Probe_", "Table_");
  mAccumulatorInterpreter = new MTSQLInterpreter(mAccumulatorEnv);
  mAccumulatorInterpreter->setSupportVarchar(true);
  mAccumulatorExe = mAccumulatorInterpreter->analyze(program.c_str());
  if (NULL == mAccumulatorExe) 
  {
    std::string utf8Program;
    ::WideStringToUTF8(program, utf8Program);
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

MetraFlowDualRecordInterpreter::~MetraFlowDualRecordInterpreter()
{
  delete mAccumulatorInterpreter;
  delete mAccumulatorProbeFrame;
  delete mAccumulatorTableFrame;
  delete mAccumulatorProbeActivationRecord;
  delete mAccumulatorTableActivationRecord;
  delete mAccumulatorEnv;
  delete mAccumulatorRuntime;
}


DesignTimeHashRunningAggregateInputSpec::DesignTimeHashRunningAggregateInputSpec()
{
}

DesignTimeHashRunningAggregateInputSpec::DesignTimeHashRunningAggregateInputSpec(
  const std::vector<std::wstring>& groupByKeyNames,
  const std::wstring& updateProgram)
  :
  mGroupByKeyNames(groupByKeyNames),
  mUpdateProgram(updateProgram)
{
}

DesignTimeHashRunningAggregateInputSpec::~DesignTimeHashRunningAggregateInputSpec()
{
}

void DesignTimeHashRunningAggregateInputSpec::AddGroupByKey(const std::wstring& groupByKeyName)
{
  mGroupByKeyNames.push_back(groupByKeyName);
}

void DesignTimeHashRunningAggregateInputSpec::SetGroupByKeys(const std::vector<std::wstring>& groupByKeyNames)
{
  mGroupByKeyNames = groupByKeyNames;
}

const std::vector<std::wstring>&  DesignTimeHashRunningAggregateInputSpec::GetGroupByKeys() const
{
  return mGroupByKeyNames;
}

void DesignTimeHashRunningAggregateInputSpec::SetUpdateProgram(const std::wstring& updateProgram)
{
  mUpdateProgram = updateProgram;
}

const std::wstring&  DesignTimeHashRunningAggregateInputSpec::GetUpdateProgram() const
{
  return mUpdateProgram;
}

DesignTimeHashRunningAggregate::DesignTimeHashRunningAggregate(int numInputs)
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

void DesignTimeHashRunningAggregate::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mGroupByKeys.push_back(arg.getNormalizedString());
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
    // This makes a copy of the mGroupByKeys that can get out of
    // sync if there is an addition to mGroupByKeys after this argument.
    // Not to worry, we'll fix up later during type_check.
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

DesignTimeHashRunningAggregate* DesignTimeHashRunningAggregate::clone(
                                  const std::wstring& name,
                                  std::vector<OperatorArg *>& args, 
                                  int nExtraInputs, int nExtraOutputs) const
{
  DesignTimeHashRunningAggregate* result = 
    new DesignTimeHashRunningAggregate(mInputPorts.size() + nExtraInputs);

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

DesignTimeHashRunningAggregate::~DesignTimeHashRunningAggregate()
{
  delete mAccumulator;
  delete mMerger;
}

void DesignTimeHashRunningAggregate::DeduplicateGroupByKeys(const std::vector<std::wstring>& groupByKeys,
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

void DesignTimeHashRunningAggregate::type_check()
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
    if ((mInitializeProgram.size() > 0 && accumulateProgram.size() > 0 && mSumNames.size() > 0) ||
        (mInitializeProgram.size() == 0 && accumulateProgram.size() == 0 && mSumNames.size() == 0) )
      throw std::runtime_error("Must specify exactly one of InitializeProgram/UpdateProgram and SumNames");

    // If we don't have programs yet, create them.
    if (mInitializeProgram.size() == 0 && accumulateProgram.size() == 0)
    {
      ASSERT(mInputSpecs.size() == 1);
      std::wstring initializeArgList;
      std::wstring initializeProgramBody;
      std::wstring accumulateArgList;
      std::wstring accumulateProgramBody;
      for(int i = 0; i<inputMetadata->GetNumColumns(); i++)
      {
        // Find out whether this is being summed.
        for(std::vector<std::pair<std::wstring,std::wstring> >::iterator it = mSumNames.begin();
            it != mSumNames.end();
            it++)
        {
          if(inputMetadata->GetColumnName(i) == it->first)
          {
            DatabaseColumn * tmp = inputMetadata->GetColumn(i);
            MTPipelineLib::PropValType ty = tmp->GetPhysicalFieldType()->GetPipelineType();
            if (ty != MTPipelineLib::PROP_TYPE_INTEGER && 
                ty != MTPipelineLib::PROP_TYPE_BIGINTEGER &&
                ty != MTPipelineLib::PROP_TYPE_DECIMAL)
            {
              throw std::runtime_error ("Unsupported aggregation type");
            }

            // Build program for computing aggregate
            initializeArgList += std::wstring(L"@Table_") + it->second + std::wstring(L" ") + GetMTSQLDatatype(tmp);
            initializeProgramBody += std::wstring(L"SET @Table_") + it->second + 
              std::wstring(ty == MTPipelineLib::PROP_TYPE_DECIMAL ? L" = 0.0\n" : ty == MTPipelineLib::PROP_TYPE_INTEGER ? L" = 0\n" : L" = 0LL\n");
            accumulateArgList += std::wstring(L" @Table_") + it->second  + std::wstring(L" ") + GetMTSQLDatatype(tmp)
              + std::wstring(L" @Probe_") + it->first  + std::wstring(L" ") + GetMTSQLDatatype(tmp);
            accumulateProgramBody += std::wstring(L"SET @Table_") + it->second + 
              std::wstring(L" = @Table_") + it->second + 
              std::wstring(L" + @Probe_") + it->first + std::wstring(L"\n");
          }
        }    
      }
      // Build program for computing aggregate
      initializeArgList += std::wstring(L" @Table_") + mCountName + std::wstring(L" INTEGER");
      initializeProgramBody += std::wstring(L"SET @Table_") + mCountName + std::wstring(L" = 0\n");
      accumulateArgList += std::wstring(L" @Table_") + mCountName + std::wstring(L" INTEGER");
      accumulateProgramBody += std::wstring(L"SET @Table_") + mCountName + 
        std::wstring(L" = @Table_") + mCountName + 
        std::wstring(L" + 1\n");

      SetUpdateProgram(std::wstring(L"CREATE PROCEDURE accumulate") + accumulateArgList + 
                       std::wstring(L"\nAS\n") + accumulateProgramBody);
      mInitializeProgram = std::wstring(L"CREATE PROCEDURE initialize") + initializeArgList + 
        std::wstring(L"\nAS\n") + initializeProgramBody;
    }
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
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[DesignTimeHashRunningAggregate]");
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
    accumulatorMembers.push_back(outputName, 
                                 LogicalFieldType::Get(*it));
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

RunTimeOperator * DesignTimeHashRunningAggregate::code_generate(partition_t maxPartition)
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

  return new RunTimeHashRunningAggregate(GetName(),
                                         runTimeInputSpecs,
                                         *mAccumulator, 
                                         mAccumulatorGroupByKeyNames,
                                         mInitializeProgram,
                                         mNumBuckets,
                                         mPreIncrement,
                                         mOutputFinalTotals,
                                         mInitializeTable);
}

void DesignTimeHashRunningAggregate::AddGroupByKey(const std::wstring& groupByKey)
{
  ASSERT(mInputPorts.size() == 1);
  if (mInputSpecs.size() == 0)
    mInputSpecs.push_back(DesignTimeHashRunningAggregateInputSpec());
  mInputSpecs[0].AddGroupByKey(groupByKey);
}

void DesignTimeHashRunningAggregate::SetGroupByKeys(const std::vector<std::wstring>& groupByKeys)
{
  ASSERT(mInputPorts.size() == 1);
  if (mInputSpecs.size() == 0)
    mInputSpecs.push_back(DesignTimeHashRunningAggregateInputSpec());
  mInputSpecs[0].SetGroupByKeys(groupByKeys);
}

void DesignTimeHashRunningAggregate::SetInitializeProgram(const std::wstring& initializeProgram)
{
  mInitializeProgram = initializeProgram;
}

void DesignTimeHashRunningAggregate::SetUpdateProgram(const std::wstring& updateProgram)
{
  ASSERT(mInputPorts.size() == 1);
  if (mInputSpecs.size() == 0)
    mInputSpecs.push_back(DesignTimeHashRunningAggregateInputSpec());
  mInputSpecs[0].SetUpdateProgram(updateProgram);
}

void DesignTimeHashRunningAggregate::SetInputSpecs(const std::vector<DesignTimeHashRunningAggregateInputSpec>& inputSpecs)
{
  mInputSpecs = inputSpecs;
}

void DesignTimeHashRunningAggregate::AddInputSpec(const DesignTimeHashRunningAggregateInputSpec& inputSpec)
{
  mInputSpecs.push_back(inputSpec);
}

void DesignTimeHashRunningAggregate::SetSums(const std::vector<NameMapping>& sums)
{
  mSumNames = sums;
}

void DesignTimeHashRunningAggregate::SetCountName(const std::wstring& countName)
{
  mCountName = countName;
}

void DesignTimeHashRunningAggregate::AddSortKey(const DesignTimeSortKey& aKey)
{
  mSortKey.push_back(aKey);
}

void DesignTimeHashRunningAggregate::SetPreIncrement(bool preIncrement)
{
  mPreIncrement = preIncrement;
}

void DesignTimeHashRunningAggregate::SetOutputFinalTotals(bool outputFinalTotals)
{
  mOutputFinalTotals = outputFinalTotals;
}

void DesignTimeHashRunningAggregate::SetInitializeTable(bool initializeTable)
{
  mInitializeTable = initializeTable;
}

PhysicalFieldType DesignTimeHashRunningAggregate::GetPhysicalFieldType(int ty)
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

std::wstring DesignTimeHashRunningAggregate::GetMTSQLDatatype(DataAccessor * accessor)
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
	default: throw std::runtime_error("Unsupported data type");
  }
}

RunTimeHashRunningAggregateInputSpec::RunTimeHashRunningAggregateInputSpec(
  const RecordMetadata& input,
  const RecordMerge& merger,
  const std::wstring& accumulatorProgram,
  const std::vector<std::wstring>& inputGroupByKeyNames,
  const std::vector<RunTimeSortKey>& sortKey)
  :
  mInput(input),
  mMerger(merger),
  mAccumulatorProgram(accumulatorProgram),
  mInputGroupByKeyNames(inputGroupByKeyNames),
  mSortKey(sortKey)
{
  FixupSortKeys();
}

RunTimeHashRunningAggregateInputSpec::RunTimeHashRunningAggregateInputSpec(
  const RecordMetadata& input,
  const std::wstring& accumulatorProgram,
  const std::vector<std::wstring>& inputGroupByKeyNames,
  const std::vector<RunTimeSortKey>& sortKey)
  :
  mInput(input),
  mAccumulatorProgram(accumulatorProgram),
  mInputGroupByKeyNames(inputGroupByKeyNames),
  mSortKey(sortKey)
{
  FixupSortKeys();
}

RunTimeHashRunningAggregateInputSpec::RunTimeHashRunningAggregateInputSpec(const RunTimeHashRunningAggregateInputSpec& rhs)
  :
  mInput(rhs.mInput),
  mMerger(rhs.mMerger),
  mAccumulatorProgram(rhs.mAccumulatorProgram),
  mInputGroupByKeyNames(rhs.mInputGroupByKeyNames),
  mSortKey(rhs.mSortKey)
{
  FixupSortKeys();
}

const RunTimeHashRunningAggregateInputSpec& RunTimeHashRunningAggregateInputSpec::operator=(const RunTimeHashRunningAggregateInputSpec& rhs)
{
  mInput=rhs.mInput;
  mMerger=rhs.mMerger;
  mAccumulatorProgram=rhs.mAccumulatorProgram;
  mInputGroupByKeyNames=rhs.mInputGroupByKeyNames;
  mSortKey=rhs.mSortKey;
  FixupSortKeys();
  return *this;
}

RunTimeHashRunningAggregateInputSpec::~RunTimeHashRunningAggregateInputSpec()
{
}

void RunTimeHashRunningAggregateInputSpec::FixupSortKeys()
{
  // Extract the accessors for sort keys
  for(std::vector<RunTimeSortKey>::iterator it =  mSortKey.begin();
      it != mSortKey.end();
      it++)
  {
    ASSERT(mInput.HasColumn(it->GetSortKeyName()));
    it->SetDataAccessor(mInput.GetColumn(it->GetSortKeyName()));
  }
}

RunTimeHashRunningAggregateInputSpecActivation::RunTimeHashRunningAggregateInputSpecActivation(
  const RunTimeHashRunningAggregateInputSpec * inputSpec)
  :
  mInputSpec(inputSpec),
  mIterator(NULL),
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

RunTimeHashRunningAggregateInputSpecActivation::~RunTimeHashRunningAggregateInputSpecActivation()
{
  delete mIterator;
  delete mAccumulatorProbeFrame;
  delete mAccumulatorTableFrame;
  delete mAccumulatorEnv;
  delete mAccumulatorInterpreter;
  delete mAccumulatorProbeActivationRecord;
  delete mAccumulatorTableActivationRecord;
  delete mAccumulatorRuntime;
}

void RunTimeHashRunningAggregateInputSpecActivation::Start(const RecordMetadata& accumulator, 
                                                 CacheConsciousHashTable& table,
                                                 MetraFlowLoggerPtr logger)
{
  // Extract the accessors for the group by keys 
  for(std::vector<std::wstring>::const_iterator it = mInputSpec->mInputGroupByKeyNames.begin();
      it != mInputSpec->mInputGroupByKeyNames.end();
      it++)
  {
    ASSERT(mInputSpec->mInput.HasColumn(*it));
    mInputGroupByKeys.push_back(mInputSpec->mInput.GetColumn(*it));
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

  // Hash table iterator for lookups on this input
  mIterator = new CacheConsciousHashTableIterator(table, mInputGroupByKeys);
}

void RunTimeHashRunningAggregateInputSpecActivation::Initialize(record_t inputMessage,
                                                      record_t accumulator, 
                                                      const std::vector<DataAccessor*>& accumulatorGroupByKeys)
{
  ASSERT(mInputGroupByKeys.size() == accumulatorGroupByKeys.size());
  for(std::size_t i = 0; i<mInputGroupByKeys.size(); i++)
  {
    accumulatorGroupByKeys[i]->SetValue(accumulator, 
                                        mInputGroupByKeys[i]->GetValue(inputMessage));
  }
}

void RunTimeHashRunningAggregateInputSpecActivation::Update(record_t inputMessage, record_t accumulator)
{
  if(mAccumulatorExe != NULL)
  {
    mAccumulatorProbeActivationRecord->SetBuffer(inputMessage);
    mAccumulatorTableActivationRecord->SetBuffer(accumulator);
    mAccumulatorExe->execCompiled(mAccumulatorRuntime);
  }
}

const RecordMetadata& RunTimeHashRunningAggregateInputSpecActivation::GetMetadata() const
{
  return mInputSpec->mInput;
}

const RecordMerge& RunTimeHashRunningAggregateInputSpecActivation::GetMerger() const
{
  return mInputSpec->mMerger;
}

void RunTimeHashRunningAggregateInputSpecActivation::ExportSortKey(QueueElement& e)
{
  for (std::vector<RunTimeSortKey>::const_iterator it = mInputSpec->mSortKey.begin();
       it != mInputSpec->mSortKey.end();
       it++)
  {
    it->GetDataAccessor()->ExportSortKey(e.mMsgPtr, it->GetSortOrder(), e);
  } 
}

CacheConsciousHashTableIterator* RunTimeHashRunningAggregateInputSpecActivation::GetIterator() 
{
  return mIterator;
}

RunTimeHashRunningAggregate::RunTimeHashRunningAggregate(const std::wstring& name, 
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

RunTimeHashRunningAggregate::~RunTimeHashRunningAggregate()
{
}

RunTimeOperatorActivation * RunTimeHashRunningAggregate::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeHashRunningAggregateActivation(reactor, partition, this);
}

RunTimeHashRunningAggregateActivation::RunTimeHashRunningAggregateActivation(Reactor * reactor, 
                                                                             partition_t partition, 
                                                                             const RunTimeHashRunningAggregate * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeHashRunningAggregate>(reactor, partition, runTimeOperator),
  mTable(NULL),
  mInsertIterator(NULL),
  mScanIterator(NULL),
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

RunTimeHashRunningAggregateActivation::~RunTimeHashRunningAggregateActivation()
{
  delete mTable;
  delete mInsertIterator;
  delete mScanIterator;
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

void RunTimeHashRunningAggregateActivation::Start()
{
  // Create activations for all input specs
  for(std::vector<RunTimeHashRunningAggregateInputSpec>::const_iterator it = mOperator->mInputSpecs.begin();
      it != mOperator->mInputSpecs.end();
      ++it)
  {
    mInputSpecActivations.push_back(RunTimeHashRunningAggregateInputSpecActivation(&*it));
  }

  // Extract the accessors for the group by keys 
  for(std::vector<std::wstring>::const_iterator it = mOperator->mAccumulatorGroupByKeyNames.begin();
      it != mOperator->mAccumulatorGroupByKeyNames.end();
      it++)
  {
    DatabaseColumn * c = mOperator->mAccumulator.GetColumn(*it);
    ASSERT(c != NULL);
    mAccumulatorGroupByKeys.push_back(c);
  }
  
  //
  // Create the hash table.
  //
  mTable = new CacheConsciousHashTable(mAccumulatorGroupByKeys, mOperator->mAccumulator, true, mOperator->mNumBuckets);
  mInsertIterator = new CacheConsciousHashTableNonUniqueInsertIterator(*mTable);

  //
  // The Initializer
  //
  // TODO: Don't really need this probe frame
  mInitializerProbeFrame = new RecordFrame(&mInputSpecActivations[0].GetMetadata());
  mInitializerTableFrame = new RecordFrame(&mOperator->mAccumulator);
  // Variables @Probe_* come from the probe record, @Table_* come from the LUT
  mInitializerEnv = new DualCompileEnvironment(mTable->GetLogger(), 
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
  mInitializerRuntime = new DualRuntimeEnvironment(mTable->GetLogger(), 
                                                   mInitializerProbeActivationRecord, mInitializerTableActivationRecord);
  
  // Initialize all of the updaters
  for(std::vector<RunTimeHashRunningAggregateInputSpecActivation>::iterator it = mInputSpecActivations.begin();
      it != mInputSpecActivations.end();
      it++)
  {
    it->Start(mOperator->mAccumulator, *mTable, mTable->GetLogger());
  }

  // Make sure that can figure out which input we are process on a completed read.
  ASSERT(mInputs.size() == mInputSpecActivations.size() + (mOperator->mInitializeTable ? 1 : 0));
  for(std::size_t i=0; i<mInputSpecActivations.size(); i++)
  {
    mEndpointInputIndex[mInputs[i]] = &mInputSpecActivations[i];
    //Create queue elements, one for each input endpoint.
    mQueueElements.push_back(new QueueElement());
  }
  
  mTotalProcessed = 0LL;
  mTotalAccumulatorSize = 0;
  mLogger = MetraFlowLoggerManager::GetLogger((boost::format("[RunTimeHashRunningAggregate(%1%)]") % 
                                               mPartition).str().c_str());
  // Initialize the the multiplexer and make the first request.
//   mMultiplexer.Start(mInputs.begin(), mInputs.end() - 1);
  mState = START;
  HandleEvent(NULL);
}

void RunTimeHashRunningAggregateActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:

    if (mOperator->mInitializeTable)
    {
      while(true)
      {
        // If we have a table initializer, read and populate the hash table
        // Assume unique group by keys.
        // TODO: What error for duplicate key?  Maybe a warning instead?
        mReactor->RequestRead(this, mInputs.back());
        mState = READ_TABLE;
        return;
      case READ_TABLE:
        Read(mAccumulatorMessage, mInputs.back());
        if (!mOperator->mAccumulator.IsEOF(mAccumulatorMessage))
        {
          mTable->Insert(mAccumulatorMessage, *mInsertIterator);
          mTotalAccumulatorSize += mOperator->mAccumulator.GetRecordLength();
        }
        else
        {
          break;
        }
      }
    }
    mAccumulatorMessage = NULL;

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
      // Hash the group by keys and look up in the hash table.
      mTable->Find(mPQ.top()->mMsgPtr, *mActiveInput->GetIterator());
      if (mActiveInput->GetIterator()->GetNext())
      {
        mAccumulatorMessage = mActiveInput->GetIterator()->Get();
      }
      else
      {
        // Create a new record with the group by keys and initialize accumulators.
        mAccumulatorMessage = mOperator->mAccumulator.Allocate();
        // Initialize Group Keys
        mActiveInput->Initialize(mPQ.top()->mMsgPtr, mAccumulatorMessage, mAccumulatorGroupByKeys);
        // Initialize counter values.  TODO: Eliminate Probe activation; it is unneeded.
        mInitializerProbeActivationRecord->SetBuffer(NULL);
        mInitializerTableActivationRecord->SetBuffer(mAccumulatorMessage);
        mInitializerExe->execCompiled(mInitializerRuntime);
        mTable->Insert(mAccumulatorMessage, *mInsertIterator);
        mTotalAccumulatorSize += mOperator->mAccumulator.GetRecordLength();
      }

      if (mOperator->mPreIncrement)
      {
        mActiveInput->Update(mPQ.top()->mMsgPtr, mAccumulatorMessage);
      }

      // Output merged first input 
      if (mActiveInput == &mInputSpecActivations[0])
      {
        // Merge running total statistics and output
        mOutputMessage = mActiveInput->GetMerger().GetRecordMetadata()->Allocate();
        mActiveInput->GetMerger().Merge(mPQ.top()->mMsgPtr, mAccumulatorMessage, mOutputMessage);

        RequestWrite(0);
        mState = WRITE_0;
        return;
      case WRITE_0:
        Write(mOutputMessage, ep);
        
        if ((++mTotalProcessed % 50000LL) == 0)
        {
          mLogger->logInfo((boost::format("Wrote %1% records") % mTotalProcessed).str());
        }
      }

      // Accumulate and free input.  We want the output the pre-incremented amount,
      // so this come after the output.
      if (!mOperator->mPreIncrement)
      {
        mActiveInput->Update(mPQ.top()->mMsgPtr, mAccumulatorMessage);
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
    }

    // Request to output the final totals (essentially the group by calculation).
    // We piggyback on the first output to do this setting NULL values for the
    // columns of the corresponding input (kinda like an outer join).  
    // TODO: Perhaps we support sending these values to a different output.
    if (mOperator->mOutputFinalTotals)
    {
      // Output the accumulated values.
      mScanIterator = new CacheConsciousHashTableScanIterator (*mTable);
      // Create a record of NULLs on the first input.
      mNullMessage = mInputSpecActivations[0].GetMetadata().Allocate();
      while(mScanIterator->GetNext())
      {
        // Merge running total statistics and output
        mAccumulatorMessage = mScanIterator->Get();
        mOutputMessage = mInputSpecActivations[0].GetMerger().GetRecordMetadata()->Allocate();
        mInputSpecActivations[0].GetMerger().Merge(mNullMessage, mAccumulatorMessage, mOutputMessage);
      
        RequestWrite(0);
        mState = WRITE_FINAL_TOTAL_0;
        return;
      case WRITE_FINAL_TOTAL_0:
        Write(mOutputMessage, ep);
      }

      mInputSpecActivations[0].GetMetadata().Free(mNullMessage);
      mNullMessage = NULL;
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

DesignTimeFilter::DesignTimeFilter()
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeFilter::~DesignTimeFilter()
{
}

void DesignTimeFilter::handleArg(const OperatorArg& arg)
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

DesignTimeFilter* DesignTimeFilter::clone(
                                      const std::wstring& name,
                                      std::vector<OperatorArg *>& args, 
                                      int nInputs, int nOutputs) const
{
  DesignTimeFilter* result = new DesignTimeFilter();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeFilter::type_check()
{
  const RecordMetadata * inputMetadata = mInputPorts[0]->GetMetadata();
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[DesignTimeFilter]");
  
  // Now do a typecheck against the merged environment.
  RecordCompileEnvironment realEnvironment(logger, inputMetadata);
  MTSQLInterpreter realInterpreter(&realEnvironment);
  realInterpreter.setSupportVarchar(true);
  MTSQLExecutable  * realExe = realInterpreter.analyze(mProgram.c_str());
  if (NULL == realExe) 
  {
    throw std::runtime_error("Error compiling MTSQL procedure");
  }

  // Everything cool.  
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*inputMetadata));
}

RunTimeOperator * DesignTimeFilter::code_generate(partition_t maxPartition)
{
  return new RunTimeFilter(GetName(),
                           *mInputPorts[0]->GetMetadata(),
                           mProgram);
}

RunTimeFilter::RunTimeFilter()
{
}

RunTimeFilter::RunTimeFilter(const std::wstring& name, 
                             const RecordMetadata& inputMetadata,
                             const std::wstring& program)
  : 
  RunTimeOperator(name),
  mInputMetadata(inputMetadata),
  mProgram(program)
{
}

RunTimeFilter::~RunTimeFilter()
{
}

RunTimeOperatorActivation * RunTimeFilter::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeFilterActivation(reactor, partition, this);
}

RunTimeFilterActivation::RunTimeFilterActivation(Reactor * reactor, 
                                                 partition_t partition, 
                                                 const RunTimeFilter * runTimeOperator)
  : 
  RunTimeOperatorActivationImpl<RunTimeFilter>(reactor, partition, runTimeOperator),
  mState(READ_0),
  mInputMessage(NULL),
	mInterpreter(NULL),
	mExe(NULL),
	mEnv(NULL),
  mRuntime(NULL)
{
}

RunTimeFilterActivation::~RunTimeFilterActivation()
{
	delete mInterpreter;
	delete mEnv;
  delete mRuntime;
}

void RunTimeFilterActivation::Start()
{
  mLogger = MetraFlowLoggerManager::GetLogger("[RunTimeFilter]");

	mEnv = new RecordCompileEnvironment(mLogger, &mOperator->mInputMetadata);
	mInterpreter = new MTSQLInterpreter(mEnv);
  mInterpreter->setSupportVarchar(true);
	mExe = mInterpreter->analyze(mOperator->mProgram.c_str());
  ASSERT(mExe);
  mExe->codeGenerate(mEnv);
  mRuntime = new RecordRuntimeEnvironment(mLogger);

  RequestRead(0);
  mState = READ_0;
}

void RunTimeFilterActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case READ_0:
    Read(mInputMessage, ep);
    if (!mOperator->mInputMetadata.IsEOF(mInputMessage))
    {
      mRuntime->SetBuffer(mInputMessage);
      mExe->execCompiled(mRuntime);
      if (mExe->getReturnValue()->isNullRaw() || false == mExe->getReturnValue()->getBool())
      {
        mOperator->mInputMetadata.Free(mInputMessage);
        mInputMessage = NULL;
        RequestRead(0);
        mState = READ_0;
        return;
      }
      else
      {
        RequestWrite(0);
        mState = WRITE_OUTPUT_0;
        return;
      case WRITE_OUTPUT_0:;
        Write(mInputMessage, ep);
        mInputMessage = NULL;
        RequestRead(0);
        mState = READ_0;
        return;
      }
    }
    else
    {
      RequestWrite(0);
      mState = WRITE_EOF_0;
      return;
    case WRITE_EOF_0:;
      Write(mInputMessage, ep, true);
      return;
    }
  }
}

DesignTimeSwitch::DesignTimeSwitch()
  :
  mNumOutputs(0)
{
}

DesignTimeSwitch::DesignTimeSwitch(boost::int32_t numOutputs)
  :
  mNumOutputs(numOutputs)
{
  mInputPorts.insert(this, 0, L"input", false);
  for(boost::int32_t i = 0; i<mNumOutputs; i++)
  {
    mOutputPorts.insert(this, i, (boost::wformat(L"output(%d)") % i).str(), false);
  }
}

DesignTimeSwitch::~DesignTimeSwitch()
{
}

void DesignTimeSwitch::handleArg(const OperatorArg& arg)
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

DesignTimeSwitch* DesignTimeSwitch::clone(
                                      const std::wstring& name,
                                      std::vector<OperatorArg *>& args, 
                                      int nExtraInputs, 
                                      int nExtraOutputs) const
{
  DesignTimeSwitch* result 
    = new DesignTimeSwitch(mOutputPorts.size() + nExtraOutputs);

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeSwitch::type_check()
{
  const RecordMetadata * inputMetadata = mInputPorts[0]->GetMetadata();
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[DesignTimeSwitch]");
  
  // Now do a typecheck against the merged environment.
  RecordCompileEnvironment realEnvironment(logger, inputMetadata);
  MTSQLInterpreter realInterpreter(&realEnvironment);
  realInterpreter.setSupportVarchar(true);
  MTSQLExecutable  * realExe = realInterpreter.analyze(mProgram.c_str());
  if (NULL == realExe) 
  {
    throw std::runtime_error("Error compiling MTSQL procedure");
  }

  if (realExe->getReturnType() != RuntimeValue::TYPE_INTEGER)
  {
    throw std::runtime_error("switch statement must return INTEGER");
  }

  // Everything cool.  Copy output metadata.
  for(PortCollection::const_iterator it = mOutputPorts.begin();
      it != mOutputPorts.end();
      it++)
  {
    (*it)->SetMetadata(new RecordMetadata(*inputMetadata));
  }
}

RunTimeOperator * DesignTimeSwitch::code_generate(partition_t maxPartition)
{
  return new RunTimeSwitch(GetName(),
                           *mInputPorts[0]->GetMetadata(),
                           mProgram, mNumOutputs);
}

RunTimeSwitch::RunTimeSwitch()
  :
  mNumOutputs(0)
{
}

RunTimeSwitch::RunTimeSwitch(const std::wstring& name, 
                             const RecordMetadata& inputMetadata,
                             const std::wstring& program,
                             boost::int32_t numOutputs)
  : 
  RunTimeOperator(name),
  mInputMetadata(inputMetadata),
  mProgram(program),
  mNumOutputs(numOutputs)
{
}

RunTimeSwitch::~RunTimeSwitch()
{
}

RunTimeOperatorActivation * RunTimeSwitch::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeSwitchActivation(reactor, partition, this);
}

RunTimeSwitchActivation::RunTimeSwitchActivation(Reactor * reactor, 
                                                 partition_t partition, 
                                                 const RunTimeSwitch * runTimeOperator)
  : 
  RunTimeOperatorActivationImpl<RunTimeSwitch>(reactor, partition, runTimeOperator),
  mState(READ_0),
  mInputMessage(NULL),
	mInterpreter(NULL),
	mExe(NULL),
	mEnv(NULL),
  mRuntime(NULL)
{
}

RunTimeSwitchActivation::~RunTimeSwitchActivation()
{
	delete mInterpreter;
	delete mEnv;
  delete mRuntime;
}

void RunTimeSwitchActivation::Start()
{
  mLogger = MetraFlowLoggerManager::GetLogger("[RunTimeSwitch]");

	mEnv = new RecordCompileEnvironment(mLogger, &mOperator->mInputMetadata);
	mInterpreter = new MTSQLInterpreter(mEnv);
  mInterpreter->setSupportVarchar(true);
	mExe = mInterpreter->analyze(mOperator->mProgram.c_str());
  ASSERT(mExe);
  mExe->codeGenerate(mEnv);
  mRuntime = new RecordRuntimeEnvironment(mLogger);

  RequestRead(0);
  mState = READ_0;
}

void RunTimeSwitchActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case READ_0:
    Read(mInputMessage, ep);
    if (mOperator->mInputMetadata.IsGroupChange(mInputMessage))
    {
      // Propagate group change events to all outputs
      for(mNextOutput = 0; mNextOutput < mOperator->mNumOutputs; mNextOutput++)
      {
        RequestWrite(mNextOutput);
        mState = WRITE_GROUP_CHANGE_0;
        return;
      case WRITE_GROUP_CHANGE_0:;
        Write(mNextOutput+1 == mOperator->mNumOutputs ? 
              mInputMessage :
              mOperator->mInputMetadata.Clone(mInputMessage), ep);
      }
      RequestRead(0);
      mState = READ_0;
      return;
    }
    else if (!mOperator->mInputMetadata.IsEOF(mInputMessage))
    {
      mRuntime->SetBuffer(mInputMessage);
      mExe->execCompiled(mRuntime);
      ASSERT(!mExe->getReturnValue()->isNullRaw());
      mNextOutput = mExe->getReturnValue()->getLong();
      if (mNextOutput < 0 || mNextOutput >= mOperator->mNumOutputs)
      {
        throw std::runtime_error("Switch value out of bounds");
      }
      RequestWrite(mNextOutput);
      mState = WRITE_OUTPUT_0;
      return;
    case WRITE_OUTPUT_0:;
      Write(mInputMessage, ep);
      mInputMessage = NULL;
      RequestRead(0);
      mState = READ_0;
      return;
    }
    else
    {
      mOperator->mInputMetadata.Free(mInputMessage);
      mInputMessage = NULL;
      
      // Write EOF to all outputs.
      for(mNextOutput = 0; mNextOutput < mOperator->mNumOutputs; mNextOutput++)
      {
        RequestWrite(mNextOutput);
        mState = WRITE_EOF_0;
        return;
      case WRITE_EOF_0:;
        Write(mOperator->mInputMetadata.AllocateEOF(), ep, true);
      }
      return;
    }
  }
}

DesignTimeProjection::DesignTimeProjection()
{
  mIsComplement = false;
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeProjection::~DesignTimeProjection()
{
}

void DesignTimeProjection::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"column", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddColumn(arg.getNormalizedString());
  }
  else if (arg.is(L"inverse", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    mIsComplement = arg.getBoolValue();
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeProjection* DesignTimeProjection::clone(
                                              const std::wstring& name,
                                              std::vector<OperatorArg *>& args, 
                                              int nInputs, int nOutputs) const
{
  DesignTimeProjection* result = new DesignTimeProjection();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeProjection::type_check()
{
  LogicalRecord outputMembers;
  std::vector<std::wstring> missingColumns;
  mInputPorts[0]->GetLogicalMetadata().Project(mProjection, 
                                               mIsComplement, 
                                               outputMembers, 
                                               missingColumns);
  mOutputPorts[0]->SetMetadata(new RecordMetadata(outputMembers));

  if (missingColumns.size() > 0)
    throw MissingFieldException(*this, *mInputPorts[0], missingColumns[0]);
}

RunTimeOperator * DesignTimeProjection::code_generate(partition_t maxPartition)
{
  return new RunTimeProjection(GetName(),
                               *mInputPorts[0]->GetMetadata(),
                               *mOutputPorts[0]->GetMetadata(),
                               RecordProjection(*mInputPorts[0]->GetMetadata(),
                                                *mOutputPorts[0]->GetMetadata()));
}

void DesignTimeProjection::SetProjection(const std::vector<std::wstring>& projection, bool isComplement)
{
  mProjection = projection;
  mIsComplement = isComplement;
}

void DesignTimeProjection::AddColumn(const std::wstring& col)
{
  mProjection.push_back(col);
}

RunTimeProjection::RunTimeProjection()
{
}

RunTimeProjection::RunTimeProjection(const std::wstring& name, 
                                     const RecordMetadata& inputMetadata,
                                     const RecordMetadata& outputMetadata,
                                     const RecordProjection& projection)
  :
  RunTimeOperator(name),
  mInputMetadata(inputMetadata),
  mOutputMetadata(outputMetadata),
  mProjection(projection)
{
}

RunTimeProjection::~RunTimeProjection()
{
}

RunTimeOperatorActivation * RunTimeProjection::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeProjectionActivation(reactor, partition, this);
}

RunTimeProjectionActivation::RunTimeProjectionActivation(Reactor * reactor, 
                                                         partition_t partition, 
                                                         const RunTimeProjection * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeProjection>(reactor, partition, runTimeOperator),
  mState(READ_0),
  mInputMessage(NULL),
  mOutputMessage(NULL)
{
}

RunTimeProjectionActivation::~RunTimeProjectionActivation()
{
}

void RunTimeProjectionActivation::Start()
{
  RequestRead(0);
}

void RunTimeProjectionActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
    while(true)
    {
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
      Read(mInputMessage, ep);
      if (!mOperator->mInputMetadata.IsEOF(mInputMessage))
      {
        mOutputMessage = mOperator->mOutputMetadata.Allocate();
        mOperator->mProjection.Project(mInputMessage, mOutputMessage, true);
        mOperator->mInputMetadata.Free(mInputMessage);
        mInputMessage = NULL;
        RequestWrite(0);
        mState = WRITE_OUTPUT_0;
        return;
      case WRITE_OUTPUT_0:
        Write(mOutputMessage, ep);
        mOutputMessage = NULL;
      }
      else
      {
        mOperator->mInputMetadata.Free(mInputMessage);
        mInputMessage = NULL;
        RequestWrite(0);
        mState = WRITE_EOF_0;
        return;
      case WRITE_EOF_0:
        Write(mOperator->mOutputMetadata.AllocateEOF(), ep, true);
        mOutputMessage = NULL;
        return;
      }
    }
  }
}

#ifdef WIN32
DesignTimeSessionSetBuilder::DesignTimeSessionSetBuilder()
  :
  mParentMerger(NULL),
  mTargetMessageSize(0),
  mTargetCommitSize(1000000)
{
}

DesignTimeSessionSetBuilder::DesignTimeSessionSetBuilder(boost::int32_t numInputs)
  :
  mParentMerger(NULL),
  mTargetMessageSize(5000),
  mTargetCommitSize(50000)
{
  if (numInputs < 1)
    throw std::logic_error("session_set_builder must have at least one input");

  boost::int32_t numChildren = numInputs - 1;
  mInputPorts.push_back(this, L"parent", false);
  mOutputPorts.push_back(this, L"parent", false);
  for(boost::int32_t i = 0; i<numChildren; i++)
  {
    mInputPorts.push_back(this, (boost::wformat(L"child(%1%)") % i).str(), false);
    mOutputPorts.push_back(this, (boost::wformat(L"child(%1%)") % i).str(), false);
  }
  // Summary counts
  mOutputPorts.push_back(this, L"parentSummary", false);
  for(boost::int32_t i = 0; i<numChildren; i++)
  {
    mOutputPorts.push_back(this, (boost::wformat(L"childSummary(%1%)") % i).str(), false);
  }
  mOutputPorts.push_back(this, L"messageSummary", false);
  mOutputPorts.push_back(this, L"transactionSummary", false);
}

DesignTimeSessionSetBuilder::DesignTimeSessionSetBuilder(boost::int32_t numChildren, boost::int32_t targetMessageSize, boost::int32_t targetCommitSize)
  :
  mParentMerger(NULL),
  mTargetMessageSize(targetMessageSize),
  mTargetCommitSize(targetCommitSize)
{
  mInputPorts.push_back(this, L"parent", false);
  mKeys.push_back(L"id_sess");
  mOutputPorts.push_back(this, L"parent", false);
  for(boost::int32_t i = 0; i<numChildren; i++)
  {
    mKeys.push_back(L"id_parent_sess");
    mInputPorts.push_back(this, (boost::wformat(L"child(%1%)") % i).str(), false);
    mOutputPorts.push_back(this, (boost::wformat(L"child(%1%)") % i).str(), false);
  }
  // Summary counts
  mOutputPorts.push_back(this, L"parentSummary", false);
  for(boost::int32_t i = 0; i<numChildren; i++)
  {
    mOutputPorts.push_back(this, (boost::wformat(L"childSummary(%1%)") % i).str(), false);
  }
  mOutputPorts.push_back(this, L"messageSummary", false);
  mOutputPorts.push_back(this, L"transactionSummary", false);
}

DesignTimeSessionSetBuilder::~DesignTimeSessionSetBuilder()
{
  delete mParentMerger;
}

void DesignTimeSessionSetBuilder::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"parentKey", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetParentKey(arg.getNormalizedString());
  }
  else if (arg.is(L"childKey", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddChildKey(arg.getNormalizedString());
  }
  else if (arg.is(L"targetMessageSize", OPERATOR_ARG_TYPE_INTEGER, GetName()))
  {
    SetTargetMessageSize(arg.getIntValue());
  }
  else if (arg.is(L"targetCommitSize", OPERATOR_ARG_TYPE_INTEGER, GetName()))
  {
    SetTargetCommitSize(arg.getIntValue());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeSessionSetBuilder* DesignTimeSessionSetBuilder::clone(
                                                            const std::wstring& name,
                                                            std::vector<OperatorArg *>& args, 
                                                            int nInputs, int nOutputs) const
{
  // This operator is not currently available in scripting.
  // Therefore it is impossible to use it in a composite.
  // The following code is draft.
  DesignTimeSessionSetBuilder* result = 
    new DesignTimeSessionSetBuilder(mInputPorts.size()-1,
                                    mTargetMessageSize, mTargetCommitSize);

  result->SetName(name);

  result->SetKeys(mKeys);
  result->SetCollectionID(mCollectionID);
  result->SetMode(mMode);

  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeSessionSetBuilder::SetCollectionID(const std::vector<boost::uint8_t>& collectionID)
{
  mCollectionID = collectionID;
}

void DesignTimeSessionSetBuilder::SetParentKey(const std::wstring& parentKey)
{
  mKeys[0] = parentKey;
}

void DesignTimeSessionSetBuilder::SetChildKeys(const std::vector<std::wstring>& childKeys)
{
  if (childKeys.size()+1 != mInputPorts.size())
  {
    throw std::runtime_error("childKeys.size()+1 != mInputPorts.size()");
  }

  for(std::size_t i = 0; i<childKeys.size(); i++)
  {
    mKeys[i+1] = childKeys[i];
  }
}

void DesignTimeSessionSetBuilder::SetKeys(const std::vector<std::wstring>& keys)
{
  for(std::size_t i = 0; i<keys.size(); i++)
  {
    mKeys[i] = keys[i];
  }
}

void DesignTimeSessionSetBuilder::AddChildKey(const std::wstring& childKey)
{
  if (mKeys.size() == 0)
    throw std::logic_error("Must set parentKey before childKeys");
  mKeys.push_back(childKey);
}

void DesignTimeSessionSetBuilder::SetTargetMessageSize(boost::int32_t targetMessageSize)
{
  mTargetMessageSize = targetMessageSize;
}

void DesignTimeSessionSetBuilder::SetTargetCommitSize(boost::int32_t targetCommitSize)
{
  mTargetCommitSize = targetCommitSize;
}

void DesignTimeSessionSetBuilder::type_check()
{
  if (mInputPorts.size() > 1)
  {
    for(std::size_t i = 0; i<mInputPorts.size(); i++)
    {
      // Check for existence of group keys.
      if (!mInputPorts[i]->GetMetadata()->HasColumn(mKeys[i]))
      {
        std::string columnName;;
        ::WideStringToUTF8(mKeys[i], columnName);
        throw std::runtime_error("Missing key column: " + columnName);
      }
    }
  }

  LogicalRecord computedMembers;
  computedMembers.push_back(RecordMember(L"id_source_sess", 
                                         LogicalFieldType::Binary(false)));
  computedMembers.push_back(RecordMember(L"id_parent_source_sess", 
                                         LogicalFieldType::Binary(false)));
  computedMembers.push_back(RecordMember(L"id_ss", 
                                         LogicalFieldType::Integer(false)));
  computedMembers.push_back(RecordMember(L"id_message", 
                                         LogicalFieldType::Integer(false)));
  computedMembers.push_back(RecordMember(L"id_commit_unit", 
                                         LogicalFieldType::Integer(false)));
  computedMembers.push_back(RecordMember(L"c__CollectionID", 
                                         LogicalFieldType::Binary(true)));
  mComputedColumns = RecordMetadata(computedMembers);

  mParentMerger = new RecordMerge(mInputPorts[0]->GetMetadata(), &mComputedColumns);
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mParentMerger->GetRecordMetadata()));
  for(std::size_t i = 1; i<mInputPorts.size(); i++)
  {
    mChildMerger.push_back(RecordMerge(mInputPorts[i]->GetMetadata(), &mComputedColumns));
    mOutputPorts[i]->SetMetadata(new RecordMetadata(*mChildMerger.back().GetRecordMetadata()));
  }

  // Summary metadata is currently hardcoded.
  // Parent and child summaries: (id_commit_unit INTEGER, id_message INTEGER, id_ss INTEGER, size INTEGER)
  // Message summary: (id_commit_unit INTEGER, id_message INTEGER, size_0 INTEGER, ... size_N INTEGER)
  // where size_i is the session_count of the ith parent/child.
  // Transaction summary: (id_commit_unit INTEGER, size_0 INTEGER, ... size_N INTEGER)
  // where size_i is the session_count of the ith parent/child.
  for(std::size_t i = 0; i<mInputPorts.size(); i++)
  {
    LogicalRecord parentChildSummaryMembers;
    parentChildSummaryMembers.push_back(RecordMember(L"id_commit_unit", 
                                                     LogicalFieldType::Integer(false)));
    parentChildSummaryMembers.push_back(RecordMember(L"id_message", 
                                                     LogicalFieldType::Integer(false)));
    parentChildSummaryMembers.push_back(RecordMember(L"id_ss", 
                                                     LogicalFieldType::Integer(false)));
    parentChildSummaryMembers.push_back(RecordMember(L"size", 
                                                     LogicalFieldType::Integer(false)));
    RecordMetadata * parentChildSummary = new RecordMetadata(parentChildSummaryMembers);
    mOutputPorts[mInputPorts.size() + i]->SetMetadata(parentChildSummary);
  }

  LogicalRecord messageSummaryMembers;
  messageSummaryMembers.push_back(RecordMember(L"id_commit_unit", 
                                               LogicalFieldType::Integer(false)));
  messageSummaryMembers.push_back(RecordMember(L"id_message", 
                                               LogicalFieldType::Integer(false)));
  for(std::size_t i = 0; i<mInputPorts.size(); i++)
  {
    messageSummaryMembers.push_back(RecordMember((boost::wformat(L"size_%1%") % i).str(), 
                                                 LogicalFieldType::Integer(false)));
  }
  RecordMetadata * messageSummaryMetadata = new RecordMetadata(messageSummaryMembers);
  mOutputPorts[2*mInputPorts.size()]->SetMetadata(messageSummaryMetadata);

  LogicalRecord transactionSummaryMembers;
  transactionSummaryMembers.push_back(RecordMember(L"id_commit_unit", 
                                                   LogicalFieldType::Integer(false)));
  for(std::size_t i = 0; i<mInputPorts.size(); i++)
  {
    transactionSummaryMembers.push_back(RecordMember((boost::wformat(L"size_%1%") % i).str(), 
                                                     LogicalFieldType::Integer(false)));
  }
  RecordMetadata * transactionSummaryMetadata = new RecordMetadata(transactionSummaryMembers);
  mOutputPorts[2*mInputPorts.size()+1]->SetMetadata(transactionSummaryMetadata);
}

RunTimeOperator * DesignTimeSessionSetBuilder::code_generate(partition_t maxPartition)
{
  std::vector<RecordMetadata> childMetadata;
  for(std::size_t i = 1; i<mInputPorts.size(); i++)
  {
    childMetadata.push_back(*mInputPorts[i]->GetMetadata());
  }  

  return new RunTimeSessionSetBuilder(GetName(),
                                      *mInputPorts[0]->GetMetadata(),
                                      *mParentMerger,
                                      childMetadata,
                                      mChildMerger,
                                      mComputedColumns,
                                      *mOutputPorts[2*mInputPorts.size()-1]->GetMetadata(),
                                      *mOutputPorts[2*mInputPorts.size()]->GetMetadata(),
                                      *mOutputPorts[2*mInputPorts.size()+1]->GetMetadata(),
                                      mTargetMessageSize,
                                      mTargetCommitSize,
                                      mCollectionID,
                                      mKeys);
}

RunTimeSessionSetBuilder::RunTimeSessionSetBuilder()
  :
  mTargetMessageSize(0),
  mTargetCommitSize(0)
{
}

RunTimeSessionSetBuilder::RunTimeSessionSetBuilder(const std::wstring& name, 
                                                   const RecordMetadata& parentMetadata,
                                                   const RecordMerge& parentMerger,
                                                   const std::vector<RecordMetadata>& childMetadata,
                                                   const std::vector<RecordMerge>& childMerger,
                                                   const RecordMetadata& computedColumns,
                                                   const RecordMetadata& parentChildSummaryMetadata,
                                                   const RecordMetadata& messageSummaryMetadata,
                                                   const RecordMetadata& transactionSummaryMetadata,
                                                   boost::int32_t targetMessageSize,
                                                   boost::int32_t targetCommitSize,
                                                   const std::vector<boost::uint8_t>& collectionID,
                                                   const std::vector<std::wstring>& keys)
  :
  RunTimeOperator(name),
  mParentMetadata(parentMetadata),
  mParentMerger(parentMerger),
  mChildMetadata(childMetadata),
  mChildMerger(childMerger),
  mComputedColumns(computedColumns),
  mParentChildSummaryMetadata(parentChildSummaryMetadata),
  mMessageSummaryMetadata(messageSummaryMetadata),
  mTransactionSummaryMetadata(transactionSummaryMetadata),
  mTargetMessageSize(targetMessageSize),
  mTargetCommitSize(targetCommitSize),
  mCollectionID(collectionID),
  mKeys(keys)
{
}

RunTimeSessionSetBuilder::~RunTimeSessionSetBuilder()
{
}

RunTimeOperatorActivation * RunTimeSessionSetBuilder::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeSessionSetBuilderActivation(reactor, partition, this);
}

RunTimeSessionSetBuilderActivation::RunTimeSessionSetBuilderActivation(Reactor * reactor, 
                                                                       partition_t partition, 
                                                                       const RunTimeSessionSetBuilder * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeSessionSetBuilder>(reactor, partition, runTimeOperator),
  mState(READ_0),
  mNextChild(-1),
  mMessageId(0),
  mCurrentMessageSize(0),
  mCommitId(0),
  mCurrentCommitSize(0),
  mIdGenerator(NULL),
  mLongIdGenerator(NULL),
  mNullBuffer(NULL),
  mOutputMessage(NULL)
{
}

RunTimeSessionSetBuilderActivation::~RunTimeSessionSetBuilderActivation()
{
  if (NULL != mNullBuffer)
  {
    mOperator->mComputedColumns.Free(mNullBuffer);
  }
  if (NULL != mIdGenerator)
  {
    COdbcIdGenerator::ReleaseInstance();
  }
  if (NULL != mLongIdGenerator)
  {
    COdbcLongIdGenerator::ReleaseInstance();
  }
}

void RunTimeSessionSetBuilderActivation::Start()
{
  ASSERT(mOutputs.size() == 2*mInputs.size() + 2);
  mLongIdGenerator = COdbcLongIdGenerator::GetInstance(COdbcConnectionInfo("NetMeter"));
  mIdGenerator = COdbcIdGenerator::GetInstance(COdbcConnectionInfo("NetMeter"));

  mParent.Key = mOperator->mChildMetadata.size() > 0 ? mOperator->mParentMetadata.GetColumn(mOperator->mKeys[0]) : NULL;
  mParent.SourceSessAccessor = mOperator->mParentMerger.GetRecordMetadata()->GetColumn(L"id_source_sess");
  mParent.ParentSourceSessAccessor = mOperator->mParentMerger.GetRecordMetadata()->GetColumn(L"id_parent_source_sess");
  mParent.SessionSetAccessor = mOperator->mParentMerger.GetRecordMetadata()->GetColumn(L"id_ss");
  mParent.MessageAccessor = mOperator->mParentMerger.GetRecordMetadata()->GetColumn(L"id_message");
  mParent.CommitAccessor = mOperator->mParentMerger.GetRecordMetadata()->GetColumn(L"id_commit_unit");
  mParent.CollectionAccessor = mOperator->mParentMerger.GetRecordMetadata()->GetColumn(L"c__CollectionID");
  for(std::size_t i = 0; i<mOperator->mChildMetadata.size(); i++)
  {
    mChildren.push_back(Accessor(
                          mOperator->mChildMetadata[i].GetColumn(mOperator->mKeys[i+1]),
                          mOperator->mChildMerger[i].GetRecordMetadata()->GetColumn(L"id_source_sess"),
                          mOperator->mChildMerger[i].GetRecordMetadata()->GetColumn(L"id_parent_source_sess"),
                          mOperator->mChildMerger[i].GetRecordMetadata()->GetColumn(L"id_ss"),
                          mOperator->mChildMerger[i].GetRecordMetadata()->GetColumn(L"id_message"),
                          mOperator->mChildMerger[i].GetRecordMetadata()->GetColumn(L"id_commit_unit"),
                          mOperator->mChildMerger[i].GetRecordMetadata()->GetColumn(L"c__CollectionID")
                          )
      );
  }

  mNullBuffer = mOperator->mComputedColumns.Allocate();

  mCurrentMessageSize = 0;
  mCurrentCommitSize = 0;

  mState = START;
  HandleEvent(0);
}

void RunTimeSessionSetBuilderActivation::ProcessRecord(const RecordMerge& merger, 
                                                       const RecordMetadata& metadata, 
                                                       RunTimeSessionSetBuilderActivation::Accessor& accessor,
                                                       bool isParent)
{
  // Got a message, increment counts.
  mCurrentMessageSize += 1;
  mCurrentCommitSize += 1;
  accessor.NumMessageRecords += 1;
  accessor.NumTransactionRecords += 1;

  mOutputMessage = merger.GetRecordMetadata()->Allocate();
  merger.Merge(accessor.Message, mNullBuffer, mOutputMessage);

  // attach source sess, session set and message ids and output current record
  // Check if new session set is needed.
  if (-1 == accessor.SessionSetId)
  {
    accessor.SessionSetId = mIdGenerator->GetNext("id_dbqueuess");
  }

  // Set values into merged record.
  accessor.MessageAccessor->SetValue(mOutputMessage, &mMessageId);
  accessor.CommitAccessor->SetValue(mOutputMessage, &mCommitId);
  accessor.SessionSetAccessor->SetValue(mOutputMessage, &accessor.SessionSetId);
  // Convert to binary and set.
  boost::int64_t lng = mLongIdGenerator->GetNext("id_dbqueue");
  boost::uint8_t buf[16];
  memset(buf, 0, 16);
//   buf[0] = mClient;
	buf[8] = ((boost::uint8_t *) &lng)[7];
	buf[9] = ((boost::uint8_t *) &lng)[6];
	buf[10] = ((boost::uint8_t *) &lng)[5];
	buf[11] = ((boost::uint8_t *) &lng)[4];
	buf[12] = ((boost::uint8_t *) &lng)[3];
	buf[13] = ((boost::uint8_t *) &lng)[2];
	buf[14] = ((boost::uint8_t *) &lng)[1];
	buf[15] = ((boost::uint8_t *) &lng)[0];
  accessor.SourceSessAccessor->SetValue(mOutputMessage, buf);
  if (!isParent)
  {
    accessor.ParentSourceSessAccessor->SetValue(mOutputMessage, mParentSourceSess);
  }
  else
  {
    accessor.ParentSourceSessAccessor->SetNull(mOutputMessage);
    memcpy(mParentSourceSess, buf, 16);
  }

  // Lastly set the collection id as appropriate
  if (isParent && mOperator->mCollectionID.size() > 0)
  {
    accessor.CollectionAccessor->SetValue(mOutputMessage, &mOperator->mCollectionID[0]);
  }
  else
  {
    accessor.CollectionAccessor->SetNull(mOutputMessage);
  }
}

MessagePtr RunTimeSessionSetBuilderActivation::OnParentChildChange(boost::int32_t idx)
{
  // Produce a summary record of commit counters and reset counters.
  MessagePtr summary = mOperator->mParentChildSummaryMetadata.Allocate();
  if (idx == 0)
  {
    mOperator->mParentChildSummaryMetadata.GetColumn(0)->SetLongValue(summary, mCommitId);
    mOperator->mParentChildSummaryMetadata.GetColumn(1)->SetLongValue(summary, mMessageId);
    mOperator->mParentChildSummaryMetadata.GetColumn(2)->SetLongValue(summary, mParent.SessionSetId);
    mOperator->mParentChildSummaryMetadata.GetColumn(3)->SetLongValue(summary, mParent.NumMessageRecords);
  }
  else
  {
    mOperator->mParentChildSummaryMetadata.GetColumn(0)->SetLongValue(summary, mCommitId);
    mOperator->mParentChildSummaryMetadata.GetColumn(1)->SetLongValue(summary, mMessageId);
    mOperator->mParentChildSummaryMetadata.GetColumn(2)->SetLongValue(summary, mChildren[idx-1].SessionSetId);
    mOperator->mParentChildSummaryMetadata.GetColumn(3)->SetLongValue(summary, mChildren[idx-1].NumMessageRecords);
  }
  return summary;
}

MessagePtr RunTimeSessionSetBuilderActivation::OnMessageChange()
{
  // Produce a summary record of commit counters and reset counters.
  MessagePtr summary = mOperator->mMessageSummaryMetadata.Allocate();
  mOperator->mMessageSummaryMetadata.GetColumn(0)->SetLongValue(summary, mCommitId);
  mOperator->mMessageSummaryMetadata.GetColumn(1)->SetLongValue(summary, mMessageId);
  mOperator->mMessageSummaryMetadata.GetColumn(2)->SetLongValue(summary, mParent.NumMessageRecords);
  mParent.NumMessageRecords = 0;
  mParent.SessionSetId = -1;
  for(std::size_t i=0; i<mChildren.size(); ++i)
  {
    mOperator->mMessageSummaryMetadata.GetColumn(i+3)->SetLongValue(summary, mChildren[i].NumMessageRecords);    
    mChildren[i].NumMessageRecords = 0;
    mChildren[i].SessionSetId = -1;
  } 
  mCurrentMessageSize = 0;
  mMessageId = mIdGenerator->GetNext("id_dbqueuesch");
  return summary;
}

MessagePtr RunTimeSessionSetBuilderActivation::OnCommitChange()
{
  // Produce a summary record of commit counters and reset counters.
  MessagePtr summary = mOperator->mTransactionSummaryMetadata.Allocate();
  mOperator->mTransactionSummaryMetadata.GetColumn(0)->SetLongValue(summary, mCommitId);
  mOperator->mTransactionSummaryMetadata.GetColumn(1)->SetLongValue(summary, mParent.NumTransactionRecords);
  mParent.NumTransactionRecords = 0;
  for(std::size_t i=0; i<mChildren.size(); ++i)
  {
    mOperator->mTransactionSummaryMetadata.GetColumn(i+2)->SetLongValue(summary, mChildren[i].NumTransactionRecords);    
    mChildren[i].NumTransactionRecords = 0;
  } 
  mCurrentCommitSize = 0;
  mCommitId++;
  return summary;
}

void RunTimeSessionSetBuilderActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    mCurrentMessageSize = 0;
    mMessageId = mIdGenerator->GetNext("id_dbqueuesch");
    mParent.SessionSetId = -1;
    mParent.NumMessageRecords = 0;
    for(mNextChild=0; mNextChild<mChildren.size(); mNextChild++)
    {
      mChildren[mNextChild].SessionSetId = -1;
      mChildren[mNextChild].NumMessageRecords = 0;
    }
      
    while(true)
    {
      // Read the next parent
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
      // Got the parent.
      if (NULL != mParent.Message)
      {
        // Input consumed.  Free it
        mOperator->mParentMetadata.Free(mParent.Message);
        mParent.Message = NULL;
      }
      Read(mParent.Message, ep);

      if (mCurrentMessageSize >= mOperator->mTargetMessageSize)
      {
        // Output the parent/child summary records.
        for(mNextChild=0; mNextChild<mInputs.size(); mNextChild++)
        {
          RequestWrite(mInputs.size()+mNextChild);
          mState = WRITE_PARENTCHILD_SUMMARY_0;
          return;
        case WRITE_PARENTCHILD_SUMMARY_0:
          Write(OnParentChildChange(mNextChild), ep);
        }

        // Output the message summary record.
        RequestWrite(2*mInputs.size());
        mState = WRITE_MESSAGE_SUMMARY_0;
        return;
      case WRITE_MESSAGE_SUMMARY_0:
        Write(OnMessageChange(), ep);

        // At a message boundary, determine whether we have also crossed
        // commit boundary (commit boundaries are require to align with
        // message boundaries).
        if (mCurrentCommitSize >= mOperator->mTargetCommitSize)
        {
          // Output the transaction summary record.
          RequestWrite(2*mInputs.size() + 1);
          mState = WRITE_TRANSACTION_SUMMARY_0;
          return;
        case WRITE_TRANSACTION_SUMMARY_0:
          Write(OnCommitChange(), ep);
        }
      }
          
      if (mOperator->mParentMetadata.IsEOF(mParent.Message))
      {
        // Output parent/child summary records
        // Output message summary record
        // Output the transaction summary record if necessary.
        if (mCurrentCommitSize > 0)
        {
          if (mCurrentMessageSize > 0)
          {
            // Output the parent/child summary records.
            for(mNextChild=0; mNextChild<mInputs.size(); mNextChild++)
            {
              RequestWrite(mInputs.size()+mNextChild);
              mState = WRITE_PARENTCHILD_SUMMARY_1;
              return;
            case WRITE_PARENTCHILD_SUMMARY_1:
              Write(OnParentChildChange(mNextChild), ep);
            }

            // Output the message summary record.
            RequestWrite(2*mInputs.size());
            mState = WRITE_MESSAGE_SUMMARY_1;
            return;
          case WRITE_MESSAGE_SUMMARY_1:
            Write(OnMessageChange(), ep);
          }
          RequestWrite(mOutputs.size() - 1);
          mState = WRITE_TRANSACTION_SUMMARY_1;
          return;
        case WRITE_TRANSACTION_SUMMARY_1:
          Write(OnCommitChange(), ep);
        }
        
        mOperator->mParentMetadata.Free(mParent.Message);
        mParent.Message = NULL;
        RequestWrite(0);
        mState = WRITE_EOF_0;
        return;
      case WRITE_EOF_0:
        Write(mOperator->mParentMerger.GetRecordMetadata()->AllocateEOF(), ep, true);        

        // Read all children to EOF discarding input
        for(mNextChild = 0; mNextChild<mChildren.size(); mNextChild++)
        {
          while (!mChildren[mNextChild].IsEOF)
          {
            // read next record
            RequestRead(mNextChild+1);
            mState = READ_2;
            return;
          case READ_2:
            Read(mChildren[mNextChild].Message, ep);
            if (mOperator->mChildMetadata[mNextChild].IsEOF(mChildren[mNextChild].Message))
            {
              RequestWrite(mNextChild + 1);
              mState = WRITE_EOF_2;
              return;
            case WRITE_EOF_2:
              Write(mOperator->mChildMerger[mNextChild].GetRecordMetadata()->AllocateEOF(), ep, true);        
              mChildren[mNextChild].IsEOF = true;
            }
            mOperator->mChildMetadata[mNextChild].Free(mChildren[mNextChild].Message);
            mChildren[mNextChild].Message = NULL;
          }
        }

        // Output Parent/Child Summary EOFs
        for(mNextChild=0; mNextChild<mInputs.size(); mNextChild++)
        {
          RequestWrite(mInputs.size()+mNextChild);
          mState = WRITE_PARENTCHILD_SUMMARY_EOF;
          return;
        case WRITE_PARENTCHILD_SUMMARY_EOF:
          Write(mOperator->mParentChildSummaryMetadata.AllocateEOF(), ep, true);
        }
        // Output the message summary EOF.
        RequestWrite(2*mInputs.size());
        mState = WRITE_MESSAGE_SUMMARY_EOF;
        return;
      case WRITE_MESSAGE_SUMMARY_EOF:
        Write(mOperator->mMessageSummaryMetadata.AllocateEOF(), ep, true);
        // Output transaction summary EOF.
        RequestWrite(mOutputs.size() - 1);
        mState = WRITE_TRANSACTION_SUMMARY_EOF;
        return;
      case WRITE_TRANSACTION_SUMMARY_EOF:
        Write(mOperator->mTransactionSummaryMetadata.AllocateEOF(), ep, true);
        // Clean up id generators on the same thread that created them.
        COdbcIdGenerator::ReleaseInstance();
        mIdGenerator = NULL;
        COdbcLongIdGenerator::ReleaseInstance();
        mLongIdGenerator = NULL;

        return;
      }

      ProcessRecord(mOperator->mParentMerger, mOperator->mParentMetadata, mParent, true);
      // Write the parent
      RequestWrite(0);
      mState = WRITE_0;
      return;
    case WRITE_0:
      Write(mOutputMessage, ep);

      // WARNING!!!!!!
      // The algorithm below does not assume that the inputs are sorted (only that they are grouped compatibly).
      // This means that it does not handle children with missing parents.
      // When Anagha finishes sort key management then we should probably change this to use sorting
      // to improve robustness.
      for(mNextChild = 0; mNextChild<mChildren.size(); mNextChild++)
      {
        while (!mChildren[mNextChild].IsEOF)
        {
          if (mChildren[mNextChild].Message != NULL &&
              mOperator->mChildMetadata[mNextChild].IsEOF(mChildren[mNextChild].Message)) 
          {
            if (!mChildren[mNextChild].IsEOF)
            {
              mOperator->mChildMetadata[mNextChild].Free(mChildren[mNextChild].Message);
              mChildren[mNextChild].Message = NULL;
              RequestWrite(mNextChild + 1);
              mState = WRITE_EOF_1;
              return;
            case WRITE_EOF_1:
              Write(mOperator->mChildMerger[mNextChild].GetRecordMetadata()->AllocateEOF(), ep, true);        
              mChildren[mNextChild].IsEOF = true;
            }
            break;
          }
      
          // Loop over the child until we get to EOF or an unmatching 
          // input.
          if (mChildren[mNextChild].Message != NULL)
          {
            if(mParent.Key->Equals(mParent.Message, mChildren[mNextChild].Key, mChildren[mNextChild].Message))
            {
              ProcessRecord(mOperator->mChildMerger[mNextChild], mOperator->mChildMetadata[mNextChild], mChildren[mNextChild], false);
              RequestWrite(mNextChild+1);
              mState = WRITE_1;
              return;
            case WRITE_1:
              Write(mOutputMessage, ep);

              mOperator->mChildMetadata[mNextChild].Free(mChildren[mNextChild].Message);
              mChildren[mNextChild].Message = NULL;
            }
            else
            {
              break;
            }
          }

          if (mChildren[mNextChild].Message == NULL)
          {
            // read next record
            RequestRead(mNextChild+1);
            mState = READ_1;
            return;
          case READ_1:
            Read(mChildren[mNextChild].Message, ep);
          }
        }
      }
    }
  }
}
#endif

DesignTimeHashGroupBy::DesignTimeHashGroupBy(boost::int32_t numInputs)
  :
  mAccumulator(NULL),
  mNumBuckets(32)
{
  if(numInputs == 1)
  {
    mInputPorts.insert(this, 0, L"input", false);
  }
  else
  {
    for(boost::int32_t i=0; i<numInputs; i++)
    {
      mInputPorts.insert(this, i, (boost::wformat(L"input(%1%)") % i).str(), false);
    }
  }
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeHashGroupBy::~DesignTimeHashGroupBy()
{
  delete mAccumulator;
}

void DesignTimeHashGroupBy::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddGroupByKey(arg.getNormalizedString());
  }
  else if (arg.is(L"initialize", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetInitializeProgram(arg.getNormalizedString());
  }
  else if (arg.is(L"update", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddUpdateProgram(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeHashGroupBy* DesignTimeHashGroupBy::clone(
                                            const std::wstring& name,
                                            std::vector<OperatorArg *>& args, 
                                            int nExtraInputs, 
                                            int nExtraOutputs) const
{
  DesignTimeHashGroupBy* result = 
    new DesignTimeHashGroupBy(mInputPorts.size() + nExtraInputs);

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeHashGroupBy::type_check()
{
  const LogicalRecord& input(mInputPorts[0]->GetLogicalMetadata());
  if (mInitializeProgram.size() == 0 || mAccumulateProgram.size() == 0)
    throw SingleOperatorException(*this, L"Must specify both InitializeProgram and UpdateProgram to Hash Group By");

  if (mAccumulateProgram.size() != mInputPorts.size())
    throw SingleOperatorException(*this, L"Must specify exactly one update argument for each input port");

  // Define the table metadata. We have group keys and "counters".  The counter info may
  // be discovered by looking at the initialize program.  Do a fake compile of the initializer
  // to discover this.  We'll get the key info separately.
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[DesignTimeHashGroupBy]");
  RecordCompileEnvironment dummyEnvironment(logger, new SimpleFrame());
  MTSQLInterpreter dummyInterpreter(&dummyEnvironment);
  dummyInterpreter.setSupportVarchar(true);
  MTSQLExecutable * dummyExecutable = dummyInterpreter.analyze(mInitializeProgram.c_str());

  // Grab the output parameters and construct the output record format.
  const std::vector<MTSQLParam>& params = dummyInterpreter.getProgramParams();

  // Skip any duplicate group by key specification (case insensitive).
  std::set<std::wstring> uniqueGroupByKeys;

  // Copy the group by keys into an accumulator metadata structure 
  LogicalRecord accumulator;
  for(std::vector<std::wstring>::iterator it = mGroupByKeyNames.begin();
      it != mGroupByKeyNames.end();
      it++)
  {
    if (!input.HasColumn(*it))
    {
      throw MissingFieldException(*this, *mInputPorts[0], *it);
    }

    if(uniqueGroupByKeys.end() != uniqueGroupByKeys.find(boost::to_upper_copy(*it)))
    {
      // TODO: Should we log anything here?
      continue;
    }

    uniqueGroupByKeys.insert(boost::to_upper_copy(*it));
    std::wstring accumulatorKeyName = *it;
    mGroupByNameMappings.push_back(NameMapping(*it, accumulatorKeyName));
    // Add to the output record
    // Save accessor for later transfers
    accumulator.push_back(accumulatorKeyName, input.GetColumn(*it).GetType());
  }

  for(std::vector<MTSQLParam>::const_iterator it = params.begin();
      it != params.end();
      it++)
  {  
    std::string nm = it->GetName();

    // Skip any probe records.
    if (boost::algorithm::iequals("@Probe_", nm.substr(0,7).c_str()))
      continue;

    // Strip off leading @Table_ and convert to Unicode.
    std::wstring outputName;
    ::ASCIIToWide(outputName, 
                  nm.size() >= 7 && 
                  boost::algorithm::iequals("@Table_", 
                                            nm.substr(0,7).c_str()) ?  nm.substr(7) : nm.substr(1));
    accumulator.push_back(outputName, 
                          LogicalFieldType::Get(*it));
  }

  mAccumulator = new RecordMetadata(accumulator);

  // Set output metadata.
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mAccumulator));
}

RunTimeOperator * DesignTimeHashGroupBy::code_generate(partition_t maxPartition)
{
  std::vector<std::wstring> inputGroupKeys;
  std::vector<std::wstring> tableGroupKeys;
  for(std::vector<NameMapping>::const_iterator it = mGroupByNameMappings.begin();
      it != mGroupByNameMappings.end();
      ++it)
  {
    inputGroupKeys.push_back(it->first);
    tableGroupKeys.push_back(it->second);
  }

  std::vector<RunTimeHashGroupByInputSpec> inputSpecs;
  for(std::size_t i=0; i<mInputPorts.size(); i++)
  {
    inputSpecs.push_back(RunTimeHashGroupByInputSpec(*mInputPorts[i]->GetMetadata(), 
                                                     mAccumulateProgram[i], 
                                                     inputGroupKeys));
  }

  return new RunTimeHashGroupBy(GetName(),
                                inputSpecs,
                                *mAccumulator, 
                                tableGroupKeys,
                                mInitializeProgram,
                                mNumBuckets);
                                                                               
                                         
}

void DesignTimeHashGroupBy::AddGroupByKey(const std::wstring& groupByKey)
{
  mGroupByKeyNames.push_back(groupByKey);
}

void DesignTimeHashGroupBy::SetGroupByKeys(const std::vector<std::wstring>& groupByKeys)
{
  mGroupByKeyNames = groupByKeys;
}

void DesignTimeHashGroupBy::SetInitializeProgram(const std::wstring& initializeProgram)
{
  mInitializeProgram = initializeProgram;
}

void DesignTimeHashGroupBy::SetUpdateProgram(const std::wstring& updateProgram)
{
  mAccumulateProgram.clear();
  mAccumulateProgram.push_back(updateProgram);
}

void DesignTimeHashGroupBy::AddUpdateProgram(const std::wstring& updateProgram)
{
  mAccumulateProgram.push_back(updateProgram);
}

void DesignTimeHashGroupBy::SetNumBuckets(boost::int32_t numBuckets)
{
  mNumBuckets = numBuckets;
}

PhysicalFieldType DesignTimeHashGroupBy::GetPhysicalFieldType(int ty)
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
  default: throw std::runtime_error("Invalid MTSQL type seen in Group By");
  }
}

std::wstring DesignTimeHashGroupBy::GetMTSQLDatatype(DataAccessor * accessor)
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
	default: throw std::runtime_error("Unsupported data type");
  }
}

RunTimeHashGroupByInputSpec::RunTimeHashGroupByInputSpec(
  const RecordMetadata& input,
  const std::wstring& accumulatorProgram,
  const std::vector<std::wstring>& inputGroupByKeyNames)
  :
  mInput(input),
  mAccumulatorProgram(accumulatorProgram),
  mInputGroupByKeyNames(inputGroupByKeyNames)
{
}

RunTimeHashGroupByInputSpec::~RunTimeHashGroupByInputSpec()
{
}

RunTimeHashGroupByInputSpecActivation::RunTimeHashGroupByInputSpecActivation(const RunTimeHashGroupByInputSpec * inputSpec)
  :
  mInputSpec(inputSpec),
  mIterator(NULL),
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

RunTimeHashGroupByInputSpecActivation::~RunTimeHashGroupByInputSpecActivation()
{
  delete mIterator;
  delete mAccumulatorProbeFrame;
  delete mAccumulatorTableFrame;
  delete mAccumulatorEnv;
  delete mAccumulatorInterpreter;
  delete mAccumulatorProbeActivationRecord;
  delete mAccumulatorTableActivationRecord;
  delete mAccumulatorRuntime;
}

void RunTimeHashGroupByInputSpecActivation::Start(const RecordMetadata& accumulator, 
                                                  CacheConsciousHashTable& table,
                                                  MetraFlowLoggerPtr logger)
{
  // Extract the accessors for the group by keys 
  for(std::vector<std::wstring>::const_iterator it = mInputSpec->mInputGroupByKeyNames.begin();
      it != mInputSpec->mInputGroupByKeyNames.end();
      it++)
  {
    ASSERT(mInputSpec->mInput.HasColumn(*it));
    mInputGroupByKeys.push_back(mInputSpec->mInput.GetColumn(*it));
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

  // Hash table iterator for lookups on this input
  mIterator = new CacheConsciousHashTableIterator(table, mInputGroupByKeys);
}

void RunTimeHashGroupByInputSpecActivation::Initialize(record_t inputMessage,
                                             record_t accumulator, 
                                             const std::vector<DataAccessor*>& accumulatorGroupByKeys)
{
  ASSERT(mInputGroupByKeys.size() == accumulatorGroupByKeys.size());
  for(std::size_t i = 0; i<mInputGroupByKeys.size(); i++)
  {
    if (!mInputGroupByKeys[i]->GetNull(inputMessage))
    {
      accumulatorGroupByKeys[i]->SetValue(accumulator, 
                                          mInputGroupByKeys[i]->GetValue(inputMessage));
    }
    else
    {
      accumulatorGroupByKeys[i]->SetNull(accumulator);
    }
  }
}

void RunTimeHashGroupByInputSpecActivation::Update(record_t inputMessage, record_t accumulator)
{
  if(mAccumulatorExe != NULL)
  {
    mAccumulatorProbeActivationRecord->SetBuffer(inputMessage);
    mAccumulatorTableActivationRecord->SetBuffer(accumulator);
    mAccumulatorExe->execCompiled(mAccumulatorRuntime);
  }
}

const RecordMetadata& RunTimeHashGroupByInputSpecActivation::GetMetadata() const
{
  return mInputSpec->mInput;
}

CacheConsciousHashTableIterator* RunTimeHashGroupByInputSpecActivation::GetIterator() 
{
  return mIterator;
}

RunTimeHashGroupBy::RunTimeHashGroupBy(const std::wstring& name, 
                                       const std::vector<RunTimeHashGroupByInputSpec>& inputSpecs,
                                       const RecordMetadata& accumulatorMetadata,
                                       const std::vector<std::wstring>& groupByKeys,
                                       const std::wstring & initializerProgram,
                                       boost::int32_t numBuckets)
  :
  RunTimeOperator(name),
  mGroupByKeys(groupByKeys),
  mInputSpecs(inputSpecs),
  mAccumulator(accumulatorMetadata),
  mInitializerProgram(initializerProgram),
  mNumBuckets(numBuckets)
{
}

RunTimeHashGroupBy::~RunTimeHashGroupBy()
{
}

RunTimeOperatorActivation * RunTimeHashGroupBy::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeHashGroupByActivation(reactor, partition, this);
}

RunTimeHashGroupByActivation::RunTimeHashGroupByActivation(Reactor * reactor, 
                                                           partition_t partition, 
                                                           const RunTimeHashGroupBy * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeHashGroupBy>(reactor, partition, runTimeOperator),
  mTable(NULL),
  mInsertIterator(NULL),
  mScanIterator(NULL),
  mInitializerInterpreter(NULL),
  mInitializerExe(NULL),
  mInitializerProbeFrame(NULL),
  mInitializerTableFrame(NULL),
  mInitializerProbeActivationRecord(NULL),
  mInitializerTableActivationRecord(NULL),
  mInitializerEnv(NULL),
  mInitializerRuntime(NULL),
  mActiveInput(NULL),
  mState(START),
  mProcessed(0LL),
  mInputMessage(NULL),
  mOutputMessage(NULL)
{
}

RunTimeHashGroupByActivation::~RunTimeHashGroupByActivation()
{
  delete mTable;
  delete mInsertIterator;
  delete mScanIterator;
  delete mInitializerInterpreter;
  delete mInitializerProbeFrame;
  delete mInitializerTableFrame;
  delete mInitializerProbeActivationRecord;
  delete mInitializerTableActivationRecord;
  delete mInitializerEnv;
  delete mInitializerRuntime;
}

void RunTimeHashGroupByActivation::Start()
{
  // Create activations for all input specs
  for(std::vector<RunTimeHashGroupByInputSpec>::const_iterator it = mOperator->mInputSpecs.begin();
      it != mOperator->mInputSpecs.end();
      ++it)
  {
    mInputSpecActivations.push_back(RunTimeHashGroupByInputSpecActivation(&*it));
  }

  // Extract the accessors for the group by keys 
  for(std::vector<std::wstring>::const_iterator it = mOperator->mGroupByKeys.begin();
      it != mOperator->mGroupByKeys.end();
      it++)
  {
    DatabaseColumn * c = mOperator->mAccumulator.GetColumn(*it);
    ASSERT(c != NULL);
    mAccumulatorGroupByKeys.push_back(c);
  }

  //
  // Create the hash table.
  //
  mTable = new CacheConsciousHashTable(mAccumulatorGroupByKeys, mOperator->mNumBuckets);
  mInsertIterator = new CacheConsciousHashTableNonUniqueInsertIterator(*mTable);

  //
  // The Initializer
  //
  mInitializerProbeFrame = new RecordFrame(&mInputSpecActivations[0].GetMetadata());
  mInitializerTableFrame = new RecordFrame(&mOperator->mAccumulator);
  // Variables @Probe_* come from the probe record, @Table_* come from the LUT
  mInitializerEnv = new DualCompileEnvironment(mTable->GetLogger(), 
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
  mInitializerRuntime = new DualRuntimeEnvironment(mTable->GetLogger(), 
                                                   mInitializerProbeActivationRecord, mInitializerTableActivationRecord);
  

  // Initialize all of the updaters
  for(std::vector<RunTimeHashGroupByInputSpecActivation>::iterator it = mInputSpecActivations.begin();
      it != mInputSpecActivations.end();
      it++)
  {
    it->Start(mOperator->mAccumulator, *mTable, mTable->GetLogger());
  }

  // Make sure that can figure out which input we are process on a completed read.
  ASSERT(mInputs.size() == mInputSpecActivations.size());
  for(std::size_t i=0; i<mInputSpecActivations.size(); i++)
  {
    mEndpointInputIndex[mInputs[i]] = &mInputSpecActivations[i];
  }
  
  // Initialize the the multiplexer.
  mMultiplexer.Start(mInputs.begin(), mInputs.end());

  // In special case in which there are no keys make sure that we create and initialize
  // record for the hash table (we want there to be a single output even if the input streams
  // are all empty).
  if (mOperator->mGroupByKeys.size() == 0)
  {
    // Create a new record with the group by keys and initialize accumulators.
    MessagePtr accumulator = mOperator->mAccumulator.Allocate();
    // A subtle point is that we don't support initializing with a valid input record,
    // rather we assume all NULLs.
    MessagePtr inputMessage = mInputSpecActivations[0].GetMetadata().Allocate();
    mInitializerProbeActivationRecord->SetBuffer(inputMessage);
    mInitializerTableActivationRecord->SetBuffer(accumulator);
    mInitializerExe->execCompiled(mInitializerRuntime);
    mTable->Insert(accumulator, *mInsertIterator);
    mInputSpecActivations[0].GetMetadata().Free(inputMessage);
  }
  
  // Start the event loop.
  mState = START;
  HandleEvent(NULL);
}

void RunTimeHashGroupByActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(!mMultiplexer.IsEOF())
    {
      mMultiplexer.RequestRead(mReactor, this);
      mState = READ_0;
      return;
    case READ_0:
      Read(mInputMessage,ep);
      mActiveInput = mEndpointInputIndex.find(ep)->second;
      if (!mActiveInput->GetMetadata().IsEOF(mInputMessage))
      {
        mMultiplexer.OnRead(ep);
        mProcessed++;
        // Hash the group by keys and look up in the hash table.
        mTable->Find(mInputMessage, *mActiveInput->GetIterator());
        record_t accumulator=NULL;
        if (mActiveInput->GetIterator()->GetNext())
        {
          accumulator = mActiveInput->GetIterator()->Get();
        }
        else
        {
          // Create a new record with the group by keys and initialize accumulators.
          accumulator = mOperator->mAccumulator.Allocate();
          // Initialize Group Keys
          mActiveInput->Initialize(mInputMessage, accumulator, mAccumulatorGroupByKeys);
          mInitializerProbeActivationRecord->SetBuffer(mInputMessage);
          mInitializerTableActivationRecord->SetBuffer(accumulator);
          mInitializerExe->execCompiled(mInitializerRuntime);
          mTable->Insert(accumulator, *mInsertIterator);
        }
        // Accumulate and free.
        mActiveInput->Update(mInputMessage, accumulator);
        mActiveInput->GetMetadata().Free(mInputMessage);
      }
      else
      {
        mMultiplexer.OnEOF(ep);
        mActiveInput->GetMetadata().Free(mInputMessage);
      }
    }
    
    // Output the accumulated values.
    mScanIterator = new CacheConsciousHashTableScanIterator (*mTable);
    // Got EOF on input.  Output the hash table.
    while(mScanIterator->GetNext())
    {
      mOutputMessage = mScanIterator->Get();
      
      RequestWrite(0);
      mState = WRITE_0;
      return;
    case WRITE_0:
      Write(mOutputMessage, ep);
    }

    RequestWrite(0);
    mState = WRITE_EOF_0;
    return;
  case WRITE_EOF_0:
    Write(mOperator->mAccumulator.AllocateEOF(), ep, true);
  }
}

DesignTimePrint::DesignTimePrint()
  :
  mNumToPrint(5LL),
  mLabel(L""),
  mFieldSeparator(L", "),
  mValueSeparator(L":"),
  mLogFileOnly(false)
{
  mInputPorts.push_back(this, L"input", false);
  mOutputPorts.push_back(this, L"output", false);  
}

DesignTimePrint::~DesignTimePrint()
{
}

void DesignTimePrint::SetNumToPrint(boost::int64_t numToPrint)
{
  mNumToPrint= numToPrint;
}

void DesignTimePrint::type_check()
{
  // Type check the filter if applicable
  if (mProgram.size() > 0)
  {
    MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[DesignTimeFilter]");
    RecordCompileEnvironment realEnvironment(logger, mInputPorts[0]->GetMetadata());
    MTSQLInterpreter realInterpreter(&realEnvironment);
    realInterpreter.setSupportVarchar(true);
    MTSQLExecutable  * realExe = realInterpreter.analyze(mProgram.c_str());
    if (NULL == realExe) 
    {
      throw std::runtime_error("Error compiling MTSQL procedure");
    }
  }
    
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mInputPorts[0]->GetMetadata()));
}

void DesignTimePrint::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"numToPrint", OPERATOR_ARG_TYPE_INTEGER, GetName()))
  {
    SetNumToPrint(arg.getIntValue());
  }
  else if (arg.is(L"program", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetProgram(arg.getNormalizedString());
  }
  else if (arg.is(L"label", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mLabel = arg.getNormalizedString();
    OperatorArg::repairNewLines(mLabel);
  }
  else if (arg.is(L"fieldSeparator", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mFieldSeparator = arg.getNormalizedString();
    OperatorArg::repairNewLines(mFieldSeparator);
  }
  else if (arg.is(L"valueSeparator", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mValueSeparator = arg.getNormalizedString();
    OperatorArg::repairNewLines(mValueSeparator);
  }
  else if (arg.is(L"logFileOnly", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    mLogFileOnly = arg.getBoolValue();
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimePrint* DesignTimePrint::clone(
                                    const std::wstring& name,
                                    std::vector<OperatorArg *>& args, 
                                    int nInputs, int nOutputs) const
{
  DesignTimePrint* result = new DesignTimePrint();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

RunTimeOperator * DesignTimePrint::code_generate(partition_t maxPartition)
{
  std::string sLabel;
  ::WideStringToUTF8(mLabel, sLabel);

  return new RunTimePrint(GetName(), 
                          mInputPorts[0]->GetLogicalMetadata(),
                          *mInputPorts[0]->GetMetadata(), 
                          mNumToPrint, 
                          sLabel,
                          mFieldSeparator,
                          mValueSeparator,
                          mLogFileOnly,
                          mProgram);
}

RunTimePrint::RunTimePrint(const std::wstring& name, 
                           const LogicalRecord& logicalRecord,
                           const RecordMetadata& metadata,
                           boost::int64_t numToPrint,
                           const std::string& label,
                           const std::wstring& fieldSeparator,
                           const std::wstring& valueSepartor,
                           bool logFileOnly,
                           const std::wstring& program)
  :
  RunTimeOperator(name),
  mMetadata(metadata),
  mNumToPrint(numToPrint),
  mLabel(label),
  mFieldSeparator(fieldSeparator),
  mValueSeparator(valueSepartor),
  mLogFileOnly(logFileOnly),
  mProgram(program),
  mPrinter(logicalRecord, mMetadata)
{
}

RunTimePrint::~RunTimePrint()
{
}

RunTimeOperatorActivation * RunTimePrint::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimePrintActivation(reactor, partition, this);
}

RunTimePrintActivation::RunTimePrintActivation(Reactor * reactor, 
                                               partition_t partition, 
                                               const RunTimePrint * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimePrint>(reactor, partition, runTimeOperator),
  mState(START),
  mMessage(NULL),
  mNumPrinted(0LL),
	mInterpreter(NULL),
	mExe(NULL),
	mEnv(NULL),
  mRuntime(NULL)
{
}

RunTimePrintActivation::~RunTimePrintActivation()
{
	delete mInterpreter;
	delete mEnv;
  delete mRuntime;
}

void RunTimePrintActivation::Start()
{
  ASSERT(mInputs.size() == 1);
  ASSERT(mOutputs.size() == 1);


  if (mOperator->mProgram.size() > 0)
  {
    mLogger = MetraFlowLoggerManager::GetLogger("[RunTimePrint]");
    mEnv = new RecordCompileEnvironment(mLogger, &mOperator->mMetadata);
    mInterpreter = new MTSQLInterpreter(mEnv);
    mInterpreter->setSupportVarchar(true);
    mExe = mInterpreter->analyze(mOperator->mProgram.c_str());
    ASSERT(mExe);
    mExe->codeGenerate(mEnv);
    mRuntime = new RecordRuntimeEnvironment(mLogger);
  }

  mNumPrinted = 0LL;
  mState = START;
  HandleEvent(NULL);
}

void RunTimePrintActivation::HandleEvent(Endpoint * ep)
{
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RunTimePrint]");

  switch(mState)
  {
  case START:
    while(true)
    {
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
      Read(mMessage, ep);

      if (!mOperator->mMetadata.IsEOF(mMessage) && 
          (mNumPrinted < mOperator->mNumToPrint))
      {
        bool printme = true;
        if (mExe != NULL)
        {
          mRuntime->SetBuffer(mMessage);
          mExe->execCompiled(mRuntime);
          if (mExe->getReturnValue()->isNullRaw() || false == mExe->getReturnValue()->getBool())
          {
            printme = false;
          }
        }
        
        if (printme)
        {
          mNumPrinted += 1;
          // Hack: casting away constness because I can't figure out how
          // to declare RecordPrinter with const correctness due to
          // issues with Boost serialization of const pointers.
          if (! (const_cast<RunTimePrint*> (mOperator)->mLogFileOnly))
          {
            std::cout
            << const_cast<RunTimePrint*> (mOperator)->mLabel  
            << const_cast<RunTimePrint*> (mOperator)->mPrinter. PrintMessage(
                mMessage,
                const_cast<RunTimePrint*> (mOperator)->mFieldSeparator,
                const_cast<RunTimePrint*> (mOperator)->mValueSeparator) .c_str() 
            << std::endl;
          }

          logger->logDebug(
                     const_cast<RunTimePrint*>
                        (mOperator)->mPrinter.PrintMessage(mMessage).c_str());
        }
      }

      RequestWrite(0);
      mState = WRITE_0;
      return;
    case WRITE_0:
      Write(mMessage, ep, mOperator->mMetadata.IsEOF(mMessage));
      if (mOperator->mMetadata.IsEOF(mMessage))
      {
        break;
      }
    }
  }
}

DesignTimeSortMerge::DesignTimeSortMerge(boost::int32_t numInputs)
{
  for(boost::int32_t i=0; i<numInputs; i++)
  {
    mInputPorts.push_back(this, (boost::wformat(L"input(%1%)") % i).str(), false);
  }
  mOutputPorts.push_back(this, L"output", false);  
}

DesignTimeSortMerge::~DesignTimeSortMerge()
{
}

void DesignTimeSortMerge::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddSortKey(DesignTimeSortKey(arg.getNormalizedString(), 
                                 SortOrder::ASCENDING));
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeSortMerge* DesignTimeSortMerge::clone(
                                            const std::wstring& name,
                                            std::vector<OperatorArg *>& args, 
                                            int nExtraInputs, 
                                            int nExtraOutputs) const
{
  DesignTimeSortMerge* result = 
    new DesignTimeSortMerge(mInputPorts.size() + nExtraInputs);

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeSortMerge::type_check()
{
  const RecordMetadata * inputMetadata = mInputPorts[0]->GetMetadata();
  // Validate that all inputs have the same schema.
  for(PortCollection::iterator it = mInputPorts.begin() + 1;
      it != mInputPorts.end();
      it++)
  {
    CheckMetadataSameType(0, it - mInputPorts.begin());
  }

  // Validate that the first input has the sort key.
  CheckSortKeys(0, mSortKey);

  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mInputPorts[0]->GetMetadata()));  
}

void DesignTimeSortMerge::AddSortKey(const DesignTimeSortKey& aKey)
{
  mSortKey.push_back(aKey);
}

RunTimeOperator * DesignTimeSortMerge::code_generate(partition_t maxPartition)
{
  // We can just use sort merge collector.
  std::vector<RunTimeSortKey> runTimeSortKey;
  for(std::vector<DesignTimeSortKey>::iterator it = mSortKey.begin();
      it != mSortKey.end();
      it++)
  {
    runTimeSortKey.push_back(RunTimeSortKey(it->GetSortKeyName(), 
                                            it->GetSortOrder(), 
                                            mInputPorts[0]->GetMetadata()->GetColumn(it->GetSortKeyName())));
  }

  return new RunTimeSortMergeCollector(GetName(), 
                                       *mInputPorts[0]->GetMetadata(),
                                       runTimeSortKey);
}

DesignTimeUnroll::DesignTimeUnroll()
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeUnroll::~DesignTimeUnroll()
{
}

void DesignTimeUnroll::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"count", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetCount(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeUnroll* DesignTimeUnroll::clone(
                                          const std::wstring& name,
                                          std::vector<OperatorArg *>& args, 
                                          int nInputs, int nOutputs) const
{
  DesignTimeUnroll* result = new DesignTimeUnroll();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeUnroll::type_check()
{
  const RecordMetadata * inputMetadata = mInputPorts[0]->GetMetadata();
  
  if (!inputMetadata->HasColumn(mCountColumn))
  {
    throw MissingFieldException(*this, *mInputPorts[0], mCountColumn);
  }
  if (*inputMetadata->GetColumn(mCountColumn)->GetPhysicalFieldType() != PhysicalFieldType::Integer())
  {
    throw MissingFieldException(*this, *mInputPorts[0], mCountColumn);
  }

  // Everything cool.  
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*inputMetadata));
}

RunTimeOperator * DesignTimeUnroll::code_generate(partition_t maxPartition)
{
  return new RunTimeUnroll(GetName(),
                           *mInputPorts[0]->GetMetadata(),
                           mCountColumn);
}

RunTimeUnroll::RunTimeUnroll()
{
}

RunTimeUnroll::RunTimeUnroll(const std::wstring& name, 
                             const RecordMetadata& inputMetadata,
                             const std::wstring& countColumn)
  : 
  RunTimeOperator(name),
  mInputMetadata(inputMetadata),
  mCountColumn(countColumn)
{
}

RunTimeUnroll::~RunTimeUnroll()
{
}

RunTimeOperatorActivation * RunTimeUnroll::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeUnrollActivation(reactor, partition, this);
}

RunTimeUnrollActivation::RunTimeUnrollActivation(Reactor * reactor, 
                                                 partition_t partition, 
                                                 const RunTimeUnroll * runTimeOperator)
  : 
  RunTimeOperatorActivationImpl<RunTimeUnroll>(reactor, partition, runTimeOperator),
  mInputMessage(NULL),
  mOutputMessage(NULL),
  mCountAccessor(NULL),
  mOutputCount(0)
{
}

RunTimeUnrollActivation::~RunTimeUnrollActivation()
{
}

void RunTimeUnrollActivation::Start()
{
  mCountAccessor = mOperator->mInputMetadata.GetColumn(mOperator->mCountColumn);
  ASSERT(mCountAccessor);
  RequestRead(0);
  mState = READ_0;
}

void RunTimeUnrollActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case READ_0:
    Read(mInputMessage,ep);
    if (!mOperator->mInputMetadata.IsEOF(mInputMessage))
    {
      if (0 == mCountAccessor->GetLongValue(mInputMessage))
      {
        mOperator->mInputMetadata.Free(mInputMessage);
        mInputMessage = NULL;
      }
      else
      {
        // Get the configured count and generate the request number of outputs.
        for(mOutputCount = 0; mOutputCount < mCountAccessor->GetLongValue(mInputMessage); mOutputCount++)
        {
          mOutputMessage = 
            mOutputCount + 1 == mCountAccessor->GetLongValue(mInputMessage) ?
            mInputMessage :
            mOperator->mInputMetadata.Clone(mInputMessage);
          mCountAccessor->SetLongValue(mOutputMessage, mOutputCount);
          RequestWrite(0);
          mState = WRITE_OUTPUT_0;
          return;
        case WRITE_OUTPUT_0:;
          Write(mOutputMessage, ep);
          mOutputMessage = NULL;
        }
      }

      RequestRead(0);
      mState = READ_0;
      return;
    }
    else
    {
      RequestWrite(0);
      mState = WRITE_EOF_0;
      return;
    case WRITE_EOF_0:;
      Write(mInputMessage, ep, true);
      return;
    }
  }
}

DesignTimeAssertSortOrder::DesignTimeAssertSortOrder()
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeAssertSortOrder::~DesignTimeAssertSortOrder()
{
}

void DesignTimeAssertSortOrder::type_check()
{
  // Validate that the first input has the sort key.
  CheckSortKeys(0, mSortKey);

  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mInputPorts[0]->GetMetadata()));  
}

void DesignTimeAssertSortOrder::AddSortKey(const DesignTimeSortKey& aKey)
{
  mSortKey.push_back(aKey);
}

void DesignTimeAssertSortOrder::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddSortKey(DesignTimeSortKey(arg.getNormalizedString(),
                                 SortOrder::ASCENDING));
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeAssertSortOrder* DesignTimeAssertSortOrder::clone(
                                                          const std::wstring& name,
                                                          std::vector<OperatorArg *>& args, 
                                                          int nInputs, int nOutputs) const
{
  DesignTimeAssertSortOrder* result = new DesignTimeAssertSortOrder();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

RunTimeOperator * DesignTimeAssertSortOrder::code_generate(partition_t maxPartition)
{
  // Create run time sort key specs
  std::vector<RunTimeSortKey> runTimeSortKey;
  for(std::vector<DesignTimeSortKey>::iterator it = mSortKey.begin();
      it != mSortKey.end();
      it++)
  {
    runTimeSortKey.push_back(RunTimeSortKey(it->GetSortKeyName(), it->GetSortOrder(), NULL));
  }

  return new RunTimeAssertSortOrder(GetName(), 
                                    *mInputPorts[0]->GetMetadata(),
                                    runTimeSortKey);
}


RunTimeAssertSortOrder::RunTimeAssertSortOrder()
{
}

RunTimeAssertSortOrder::RunTimeAssertSortOrder(const std::wstring& name, 
                                               const RecordMetadata& inputMetadata,
                                               const std::vector<RunTimeSortKey>& sortKey)
  :
  RunTimeOperator(name),
  mInput(inputMetadata),
  mSortKey(sortKey)
{
  // Extract the accessors for sort keys
  for(std::vector<RunTimeSortKey>::iterator it =  mSortKey.begin();
      it != mSortKey.end();
      it++)
  {
    ASSERT(mInput.HasColumn(it->GetSortKeyName()));
    it->SetDataAccessor(mInput.GetColumn(it->GetSortKeyName()));
  }
}

RunTimeAssertSortOrder::~RunTimeAssertSortOrder()
{
}

RunTimeOperatorActivation * RunTimeAssertSortOrder::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeAssertSortOrderActivation(reactor, partition, this);
}

RunTimeAssertSortOrderActivation::RunTimeAssertSortOrderActivation(Reactor * reactor, 
                                                                   partition_t partition, 
                                                                   const RunTimeAssertSortOrder * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeAssertSortOrder>(reactor,partition, runTimeOperator),
  mState(START),
  mGroupChangeMessage(NULL),
  mInputMessage(NULL),
  mCurrentBuffer(false),
  mNextGroupChange(1000)
{
  mBuffers[0] = mBuffers[1] = NULL;
}

RunTimeAssertSortOrderActivation::~RunTimeAssertSortOrderActivation()
{
  delete mBuffers[0];
  delete mBuffers[1];
}

void RunTimeAssertSortOrderActivation::Start()
{
  // These will be set up in the HandleEvent call.
  mBuffers[0] = mBuffers[1] = NULL;
  mState = START;
  HandleEvent(NULL);
}

void RunTimeAssertSortOrderActivation::ExportSortKey(const_record_t buffer, SortKeyBuffer& sortKeyBuffer)
{
  sortKeyBuffer.Clear();
  for (std::vector<RunTimeSortKey>::const_iterator it = mOperator->mSortKey.begin();
       it != mOperator->mSortKey.end();
       it++)
  {
    it->GetDataAccessor()->ExportSortKey(buffer, it->GetSortOrder(), sortKeyBuffer);
  } 
}

void RunTimeAssertSortOrderActivation::CreateGroupChangeRecord(const_record_t buffer, record_t groupChangeBuffer)
{
  // TODO: Use a projection for this.  Make sure projection into a group change record doesn't
  // muck with the group change bit.
  for (std::vector<RunTimeSortKey>::const_iterator it = mOperator->mSortKey.begin();
       it != mOperator->mSortKey.end();
       it++)
  {
    const RunTimeDataAccessor * a = it->GetDataAccessor(); 
    a->SetValue(groupChangeBuffer, a->GetValue(buffer));
  } 
}

void RunTimeAssertSortOrderActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(true)
    {
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
      Read(mInputMessage, ep);
      if (!mOperator->mInput.IsEOF(mInputMessage))
      {
        if (NULL == mBuffers[0])
        {
          // first time around, just initialize
          mBuffers[0] = new SortKeyBuffer();
          mBuffers[1] = new SortKeyBuffer();
          ExportSortKey(mInputMessage, *mBuffers[false]);
          mCurrentBuffer = false;
        }
        else
        {
          ExportSortKey(mInputMessage, *mBuffers[!mCurrentBuffer]);
          mCompareResult = SortKeyBuffer::Compare(*mBuffers[!mCurrentBuffer], *mBuffers[mCurrentBuffer]);
          if (0 > mCompareResult)
          {
            throw std::runtime_error("Stream not sorted!");
          }
          else if (mGroupChangeMessage != NULL && 0 < mCompareResult)
          {
            RequestWrite(0);
            mState = WRITE_GROUP_CHANGE_0;
            return;
          case WRITE_GROUP_CHANGE_0:
            Write(mGroupChangeMessage, ep);
            mGroupChangeMessage = NULL;
            mNextGroupChange = 1000;
          }
          mCurrentBuffer = !mCurrentBuffer;
        }

        // if (mGroupChangeMessage == NULL && --mNextGroupChange==0)
        // {
        //   // Create a group change message from this record.  When the
        //   // this key group closes out we'll output the message.
        //   mGroupChangeMessage = mOperator->mInput.AllocateGroupChange();
        //   CreateGroupChangeRecord(mInputMessage, mGroupChangeMessage);
        // }
        RequestWrite(0);
        mState = WRITE_0;
        return;
      case WRITE_0:;
        Write(mInputMessage, ep);
      }
      else
      {
        RequestWrite(0);
        mState = WRITE_EOF_0;
        return;
      case WRITE_EOF_0:;
        Write(mInputMessage, ep, true);
        return;
      }
    }
  }
}

DesignTimeSortGroupBy::DesignTimeSortGroupBy()
  :
  mAccumulator(NULL),
  mMerger(NULL),
  mProjection(NULL),
  mAccumulatorNoGroupByKeys(NULL),
  mCopyToAll(false)
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeSortGroupBy::~DesignTimeSortGroupBy()
{
  delete mAccumulator;
  delete mMerger;
  delete mProjection;
  delete mAccumulatorNoGroupByKeys;
}

void DesignTimeSortGroupBy::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddGroupByKey(DesignTimeSortKey(arg.getNormalizedString(),
                                    SortOrder::ASCENDING));
  }
  else if (arg.is(L"initialize", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetInitializeProgram(arg.getNormalizedString());
  }
  else if (arg.is(L"update", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetUpdateProgram(arg.getNormalizedString());
  }
  else if (arg.is(L"copyToAll", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    mCopyToAll = arg.getBoolValue();
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeSortGroupBy* DesignTimeSortGroupBy::clone(const std::wstring& name,
                                                    std::vector<OperatorArg *>& args, 
                                                    int nInputs, int nOutputs) const
{
  DesignTimeSortGroupBy* result = new DesignTimeSortGroupBy();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeSortGroupBy::type_check()
{
  const LogicalRecord& input(mInputPorts[0]->GetLogicalMetadata());
  const RecordMetadata * inputMetadata = mInputPorts[0]->GetMetadata();

  if (mInitializeProgram.size() == 0 || mAccumulateProgram.size() == 0)
    throw std::runtime_error("Must specify both InitializeProgram and UpdateProgram to Hash Group By");

  // Validate that the first input has the sort key.
  CheckSortKeys(0, mGroupByKeys);

  // Define the table metadata. We have group keys and "counters".  The counter info may
  // be discovered by looking at the initialize program.  Do a fake compile of the initializer
  // to discover this.  We'll get the key info separately.
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[DesignTimeSortGroupBy]");
  RecordCompileEnvironment dummyEnvironment(logger, new SimpleFrame());
  MTSQLInterpreter dummyInterpreter(&dummyEnvironment);
  dummyInterpreter.setSupportVarchar(true);
  MTSQLExecutable * dummyExecutable = dummyInterpreter.analyze(mInitializeProgram.c_str());

  // Grab the output parameters and keys and construct the output record format.
  const std::vector<MTSQLParam>& params = dummyInterpreter.getProgramParams();

  LogicalRecord accumulatorNoGroupByKeys;
  LogicalRecord accumulator;
  for(std::vector<DesignTimeSortKey>::iterator it = mGroupByKeys.begin();
      it != mGroupByKeys.end();
      it++)
  {
    // Add to the output record
    // Save accessor for later transfers
    accumulator.push_back(input.GetColumn(it->GetSortKeyName()));
  }

  for(std::vector<MTSQLParam>::const_iterator it = params.begin();
      it != params.end();
      it++)
  {  
    std::string nm = it->GetName();

    // Skip any probe records.
    if (boost::algorithm::iequals("@Probe_", nm.substr(0,7).c_str()))
      continue;

    // Strip off leading @Table_ and convert to Unicode.
    std::wstring outputName;
    ::ASCIIToWide(outputName, 
                  nm.size() >= 7 && 
                  boost::algorithm::iequals("@Table_", 
                                            nm.substr(0,7).c_str()) ?  nm.substr(7) : nm.substr(1));
    accumulator.push_back(outputName, 
                          LogicalFieldType::Get(*it));

    if (mCopyToAll)
      accumulatorNoGroupByKeys.push_back(outputName, 
                                         LogicalFieldType::Get(*it));
  }

  // Copy the outputs of the program into an accumulator metadata structure 
  mAccumulatorNoGroupByKeys = new RecordMetadata(accumulatorNoGroupByKeys);
  mAccumulator = new RecordMetadata(accumulator);

  if (mCopyToAll)
  {
    mMerger = new RecordMerge(inputMetadata, mAccumulatorNoGroupByKeys);
    mProjection = new RecordProjection(*mAccumulator, *mAccumulatorNoGroupByKeys);
    mOutputPorts[0]->SetMetadata(new RecordMetadata(*mMerger->GetRecordMetadata()));
  }
  else
  {
    // Set output metadata.
    mOutputPorts[0]->SetMetadata(new RecordMetadata(*mAccumulator));
  }
}

RunTimeOperator * DesignTimeSortGroupBy::code_generate(partition_t maxPartition)
{
  // Create run time sort key specs
  std::vector<RunTimeSortKey> runTimeSortKey;
  for(std::vector<DesignTimeSortKey>::iterator it = mGroupByKeys.begin();
      it != mGroupByKeys.end();
      it++)
  {
    runTimeSortKey.push_back(RunTimeSortKey(it->GetSortKeyName(), it->GetSortOrder(), NULL));
  }

  return new RunTimeSortGroupBy(GetName(),
                                *mAccumulator, 
                                *mInputPorts[0]->GetMetadata(),
                                runTimeSortKey,
                                mInitializeProgram,
                                mAccumulateProgram,
                                mCopyToAll,
                                mCopyToAll ? *mAccumulatorNoGroupByKeys : RecordMetadata(),
                                mCopyToAll ? *mMerger : RecordMerge(),
                                mCopyToAll ? *mProjection : RecordProjection());
}

void DesignTimeSortGroupBy::SetGroupByKeys(const std::vector<std::wstring>& groupByKeys)
{
  mGroupByKeys.clear();
  for(std::vector<std::wstring>::const_iterator it = groupByKeys.begin();
      it != groupByKeys.end();
      ++it)
  {
    mGroupByKeys.push_back(DesignTimeSortKey(*it, SortOrder::ASCENDING));
  }
}

void DesignTimeSortGroupBy::AddGroupByKey(const DesignTimeSortKey& groupByKey)
{
  mGroupByKeys.push_back(groupByKey);
}

void DesignTimeSortGroupBy::SetInitializeProgram(const std::wstring& initializeProgram)
{
  mInitializeProgram = initializeProgram;
}

void DesignTimeSortGroupBy::SetUpdateProgram(const std::wstring& updateProgram)
{
  mAccumulateProgram = updateProgram;
}

PhysicalFieldType DesignTimeSortGroupBy::GetPhysicalFieldType(int ty)
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
  default: throw std::runtime_error("Invalid MTSQL type seen in Group By");
  }
}

std::wstring DesignTimeSortGroupBy::GetMTSQLDatatype(DataAccessor * accessor)
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
	default: throw std::runtime_error("Unsupported data type");
  }
}

RunTimeSortGroupBy::RunTimeSortGroupBy()
{
}

RunTimeSortGroupBy::RunTimeSortGroupBy(const std::wstring& name, 
                                       const RecordMetadata& accumulatorMetadata,
                                       const RecordMetadata& inputMetadata,
                                       const std::vector<RunTimeSortKey>& groupByKeys,
                                       const std::wstring & initializerProgram,
                                       const std::wstring & accumulatorProgram,
                                       bool copyToAll,
                                       const RecordMetadata& accumulatorNoGroupByKeys,
                                       const RecordMerge & merger,
                                       const RecordProjection & projection)
  :
  RunTimeOperator(name),
  mGroupByKeys(groupByKeys),
  mInput(inputMetadata),
  mAccumulator(accumulatorMetadata),
  mInitializerProgram(initializerProgram),
  mAccumulatorProgram(accumulatorProgram),
  mCopyToAll(copyToAll),
  mAccumulatorNoGroupByKeys(accumulatorNoGroupByKeys),
  mMerger(merger),
  mProjection(projection)
{
  // Extract the accessors for sort keys 
  for(std::vector<RunTimeSortKey>::iterator it =  mGroupByKeys.begin();
      it != mGroupByKeys.end();
      it++)
  {
    ASSERT(mInput.HasColumn(it->GetSortKeyName()));
    it->SetDataAccessor(mInput.GetColumn(it->GetSortKeyName()));
  }
}

RunTimeSortGroupBy::~RunTimeSortGroupBy()
{
}

RunTimeOperatorActivation * RunTimeSortGroupBy::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeSortGroupByActivation(reactor, partition, this);
}

RunTimeSortGroupByActivation::RunTimeSortGroupByActivation(Reactor * reactor, 
                                                           partition_t partition, 
                                                           const RunTimeSortGroupBy * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeSortGroupBy>(reactor, partition, runTimeOperator),
  mAccumulatorInterpreter(NULL),
  mAccumulatorExe(NULL),
  mAccumulatorProbeFrame(NULL),
  mAccumulatorTableFrame(NULL),
  mAccumulatorProbeActivationRecord(NULL),
  mAccumulatorTableActivationRecord(NULL),
  mAccumulatorEnv(NULL),
  mAccumulatorRuntime(NULL),
  mInitializerInterpreter(NULL),
  mInitializerExe(NULL),
  mInitializerProbeFrame(NULL),
  mInitializerTableFrame(NULL),
  mInitializerProbeActivationRecord(NULL),
  mInitializerTableActivationRecord(NULL),
  mInitializerEnv(NULL),
  mInitializerRuntime(NULL),
  mState(READ_0),
  mProcessed(0LL),
  mInputMessage(NULL),
  mOutputMessage(NULL),
  mMergedMessage(NULL)
{
  mBuffer[0] = mBuffer[1] = NULL;
}

RunTimeSortGroupByActivation::~RunTimeSortGroupByActivation()
{
  delete mAccumulatorInterpreter;
  delete mAccumulatorProbeFrame;
  delete mAccumulatorTableFrame;
  delete mAccumulatorProbeActivationRecord;
  delete mAccumulatorTableActivationRecord;
  delete mAccumulatorEnv;
  delete mAccumulatorRuntime;
  delete mInitializerInterpreter;
  delete mInitializerProbeFrame;
  delete mInitializerTableFrame;
  delete mInitializerProbeActivationRecord;
  delete mInitializerTableActivationRecord;
  delete mInitializerEnv;
  delete mInitializerRuntime;

  delete mBuffer[0];
  delete mBuffer[1];
}

void RunTimeSortGroupByActivation::Start()
{
  // Extract the accessors for sort keys 
  for(std::vector<RunTimeSortKey>::const_iterator it =  mOperator->mGroupByKeys.begin();
      it != mOperator->mGroupByKeys.end();
      it++)
  {
    ASSERT(mOperator->mInput.HasColumn(it->GetSortKeyName()));
    ASSERT(mOperator->mAccumulator.HasColumn(it->GetSortKeyName()));
    mInputGroupByKeys.push_back(mOperator->mInput.GetColumn(it->GetSortKeyName()));
    mAccumulatorGroupByKeys.push_back(mOperator->mAccumulator.GetColumn(it->GetSortKeyName()));
  }

  // These will be set up in the HandleEvent call.
  mBuffer[0] = mBuffer[1] = NULL;

  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RunTimeSortGroupBy]");

  //
  // The Accumulator
  //
  mAccumulatorProbeFrame = new RecordFrame(&mOperator->mInput);
  mAccumulatorTableFrame = new RecordFrame(&mOperator->mAccumulator);
  // Variables @Probe_* come from the probe record, @Table_* come from the LUT
  mAccumulatorEnv = new DualCompileEnvironment(logger, 
                                               mAccumulatorProbeFrame, mAccumulatorTableFrame, "Probe_", "Table_");
  mAccumulatorInterpreter = new MTSQLInterpreter(mAccumulatorEnv);
  mAccumulatorInterpreter->setSupportVarchar(true);
  mAccumulatorExe = mAccumulatorInterpreter->analyze(mOperator->mAccumulatorProgram.c_str());
  if (NULL == mAccumulatorExe) 
  {
    std::string utf8Program;
    ::WideStringToUTF8(mOperator->mAccumulatorProgram, utf8Program);
    throw std::runtime_error((boost::format("Error compiling counter update procedure: %1%") % 
                          utf8Program).str().c_str());
  }
  mAccumulatorExe->codeGenerate(mAccumulatorEnv);
  mAccumulatorProbeActivationRecord = new RecordActivationRecord(NULL);
  mAccumulatorTableActivationRecord = new RecordActivationRecord(NULL);
  mAccumulatorRuntime = new DualRuntimeEnvironment(logger, 
                                                   mAccumulatorProbeActivationRecord, mAccumulatorTableActivationRecord);

  //
  // The Initializer
  //
  mInitializerProbeFrame = new RecordFrame(&mOperator->mInput);
  mInitializerTableFrame = new RecordFrame(&mOperator->mAccumulator);
  // Variables @Probe_* come from the probe record, @Table_* come from the LUT
  mInitializerEnv = new DualCompileEnvironment(logger, 
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
  mInitializerRuntime = new DualRuntimeEnvironment(logger, 
                                                   mInitializerProbeActivationRecord, mInitializerTableActivationRecord);
  

  mState = START;
  HandleEvent(NULL);
}

void RunTimeSortGroupByActivation::InitializeAccumulator()
{
  // Create a new record with the group by keys and initialize accumulators.
  mOutputMessage = mOperator->mAccumulator.Allocate();
  for(std::size_t i = 0; i<mInputGroupByKeys.size(); i++)
  {
    mAccumulatorGroupByKeys[i]->SetValue(mOutputMessage, 
                                         mInputGroupByKeys[i]->GetValue(mInputMessage));
  }
  mInitializerProbeActivationRecord->SetBuffer(mInputMessage);
  mInitializerTableActivationRecord->SetBuffer(mOutputMessage);
  mInitializerExe->execCompiled(mInitializerRuntime);
}

void RunTimeSortGroupByActivation::Accumulate()
{
  // Accumulate
  mAccumulatorProbeActivationRecord->SetBuffer(mInputMessage);
  mAccumulatorTableActivationRecord->SetBuffer(mOutputMessage);
  mAccumulatorExe->execCompiled(mAccumulatorRuntime); 
  if (mOperator->mCopyToAll)
  {
    mGroupByRecords.Push(mInputMessage);
    mInputMessage = NULL;
  }
  else
  {
    mOperator->mInput.Free(mInputMessage);
    mInputMessage = NULL;
  }
}

void RunTimeSortGroupByActivation::ExportSortKey(const_record_t buffer, SortKeyBuffer& sortKeyBuffer)
{
  sortKeyBuffer.Clear();
  for (std::vector<RunTimeSortKey>::const_iterator it = mOperator->mGroupByKeys.begin();
       it != mOperator->mGroupByKeys.end();
       it++)
  {
    it->GetDataAccessor()->ExportSortKey(buffer, it->GetSortOrder(), sortKeyBuffer);
  } 
}

bool RunTimeSortGroupByActivation::ProcessGroupByKeys()
{
  if (!mOperator->mInput.IsEOF(mInputMessage))
  {
    ExportSortKey(mInputMessage, *mBuffer[mCurrentBuffer]);
    if (0 != SortKeyBuffer::Compare(*mBuffer[mCurrentBuffer], *mBuffer[!mCurrentBuffer]))
    {
      // KeyChange!
      // Reset current sort key.
      mCurrentBuffer = !mCurrentBuffer;
      return true;
    }
    else 
      return false;
  }
  return true;
}

void RunTimeSortGroupByActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    RequestRead(0);
    mState = READ_FIRST_0;
    return;
  case READ_FIRST_0:
    Read(mInputMessage, ep);
    if (!mOperator->mInput.IsEOF(mInputMessage))
    {
      // First record
      mProcessed = 1LL;
      mBuffer[0] = new SortKeyBuffer();
      mBuffer[1] = new SortKeyBuffer();
      ExportSortKey(mInputMessage, *mBuffer[0]);
      ExportSortKey(mInputMessage, *mBuffer[1]);
      mCurrentBuffer = false;
        
      // Create a new record with the group by keys and initialize accumulators.
      InitializeAccumulator();
      Accumulate();
      // Read all records
      while(true)
      {
        RequestRead(0);
        mState = READ_0;
        return;
      case READ_0:
        Read(mInputMessage, ep);

        // First process input to figure out whether we have a key change event
        if(ProcessGroupByKeys())
        {
          // Output active group
          if (mOperator->mCopyToAll)
          {
            {
              // Project out group by keys from accumulator
              MessagePtr tmp = mOperator->mAccumulatorNoGroupByKeys.Allocate();
              mOperator->mProjection.Project(mOutputMessage, tmp);
              mOperator->mAccumulator.Free(mOutputMessage);
              mOutputMessage = tmp;
            }
            while(mGroupByRecords.GetSize())
            {
              MessagePtr inputMessage;
              mGroupByRecords.Pop(inputMessage);
              mMergedMessage = mOperator->mMerger.GetRecordMetadata()->Allocate();
              // Merge using transfer semantics with the input message.
              mOperator->mMerger.Merge(inputMessage, mOutputMessage, mMergedMessage, true, false);
              mOperator->mInput.Free(inputMessage);
              RequestWrite(0);
              mState = WRITE_COPY_ALL_0;
              return;
            case WRITE_COPY_ALL_0:
              Write(mMergedMessage, ep);
              mMergedMessage = NULL;
            }
              
            // All done with the projected accumulator
            mOperator->mAccumulatorNoGroupByKeys.Free(mOutputMessage);
            mOutputMessage = NULL;
          }
          else
          {
            // output current accumulated values
            RequestWrite(0);
            mState = WRITE_0;
            return;
          case WRITE_0:
            Write(mOutputMessage, ep);
            mOutputMessage = NULL;
          }
        }

        // Manipulate aggregates
        if (!mOperator->mInput.IsEOF(mInputMessage))
        {
          mProcessed++;
          if (mOutputMessage == NULL)
          {
            // Reinitialize accumulator
            InitializeAccumulator();
          }
          Accumulate();
        }
        else
        {
          break;
        }
      }       
    }

    // Free input EOF message
    mOperator->mInput.Free(mInputMessage);
    // Write EOF
    RequestWrite(0);
    mState = WRITE_EOF_0;
    return;
  case WRITE_EOF_0:
    Write(mOperator->mCopyToAll ? 
          mOperator->mMerger.GetRecordMetadata()->AllocateEOF() : 
          mOperator->mAccumulator.AllocateEOF(), ep, 
          true);
  }
}

DesignTimeSortMergeJoin::DesignTimeSortMergeJoin()
  :
  mMerger(NULL),
  mProjection(NULL),
  mJoinType(INNER_JOIN)
{
  mInputPorts.insert(this, 0, L"left", false);
  mInputPorts.insert(this, 1, L"right", false);
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeSortMergeJoin::~DesignTimeSortMergeJoin()
{
  delete mMerger;
  delete mProjection;
}

void DesignTimeSortMergeJoin::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"leftKey", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddLeftEquiJoinKey(DesignTimeSortKey(arg.getNormalizedString(), 
                                         SortOrder::ASCENDING));
  }
  else if (arg.is(L"rightKey", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddRightEquiJoinKey(DesignTimeSortKey(arg.getNormalizedString(), 
                                          SortOrder::ASCENDING));
  }
  else if (arg.is(L"residual", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetResidual(arg.getNormalizedString());
  }
  else if (arg.is(L"nest", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetNest(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeSortMergeJoin* DesignTimeSortMergeJoin::clone(
                                                        const std::wstring& name,
                                                        std::vector<OperatorArg *>& args, 
                                                        int nInputs, int nOutputs) const
{
  DesignTimeSortMergeJoin* result = new DesignTimeSortMergeJoin();

  // This clone is different from most operator clones.
  // See dataflow_generate.g and look for DesignTimeSortMerge to see why.
  // To summarize, multiple opertor types map to DesignTimeSortMerge.
  // These means that not all of the properties come soley from arguments.

  result->SetName(name);

  result->SetJoinType(mJoinType);

  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeSortMergeJoin::type_check()
{
  if (mLeftEquiJoinKeys.size() == 0)
  {
    throw MissingKeyException(*this, *mInputPorts[0]);
  }

  if (mRightEquiJoinKeys.size() == 0)
  {
    throw MissingKeyException(*this, *mInputPorts[1]);
  }

  if (mLeftEquiJoinKeys.size() != mRightEquiJoinKeys.size())
  {
    throw KeySizeMismatchException(*this, *mInputPorts[0], *mInputPorts[1]);
  }

  // Validate that the equijoin keys exist and have matching types.
  for(std::vector<DesignTimeSortKey>::const_iterator it = mRightEquiJoinKeys.begin();
      it != mRightEquiJoinKeys.end();
      ++it)
  {
    if (!mInputPorts[1]->GetMetadata()->HasColumn(it->GetSortKeyName()))
    {
      throw MissingFieldException(*this, *mInputPorts[1], it->GetSortKeyName());
    }
  }
  for(std::vector<DesignTimeSortKey>::const_iterator it = mLeftEquiJoinKeys.begin();
      it != mLeftEquiJoinKeys.end();
      ++it)
  {
    if (!mInputPorts[0]->GetMetadata()->HasColumn(it->GetSortKeyName()))
    {
      throw MissingFieldException(*this, *mInputPorts[0], it->GetSortKeyName());
    }
    if (*mInputPorts[0]->GetMetadata()->GetColumn(it->GetSortKeyName())->GetPhysicalFieldType() !=
        *mInputPorts[1]->GetMetadata()->GetColumn(mRightEquiJoinKeys[it - mLeftEquiJoinKeys.begin()].GetSortKeyName())->GetPhysicalFieldType())
    {
      throw FieldTypeMismatchException(*this,
                                       *mInputPorts[0], *mInputPorts[0]->GetMetadata()->GetColumn(it->GetSortKeyName()),
                                       *mInputPorts[1], *mInputPorts[1]->GetMetadata()->GetColumn(mRightEquiJoinKeys[it - mLeftEquiJoinKeys.begin()].GetSortKeyName()));
    }
  }


  // Test compile the residual if necessary.
  if (mResidual.size())
  {
    CacheConsciousHashTablePredicateIterator::Compile(*mInputPorts[0]->GetMetadata(),
                                                      *mInputPorts[1]->GetMetadata(), 
                                                      mResidual);
  }

  // Check that nest doesn't collide with any field in the right input
  if (mNest.size() && mInputPorts[1]->GetMetadata()->HasColumn(mNest))
  {
    
  }

  // Nest joins only work with INNER and RIGHT_OUTER
  if (mNest.size() && (mJoinType == RIGHT_SEMI || mJoinType == RIGHT_ANTI_SEMI || mJoinType == RIGHT_OUTER_SPLIT))
  {
  }

  // Everything cool, create the merger and set the metadata.
  if (mJoinType == RIGHT_SEMI || mJoinType == RIGHT_ANTI_SEMI)
  {
    RecordMetadata empty(LogicalRecord::Get());
    mMerger = new RecordMerge(&empty, mInputPorts[1]->GetMetadata());
    mOutputPorts[0]->SetMetadata(new RecordMetadata(*mInputPorts[1]->GetMetadata()));    
  }
  else if (mNest.size())
  {
    LogicalRecord parentMembers;
    if(!mInputPorts[1]->GetLogicalMetadata().NestCollection(mNest,
                                                            mInputPorts[0]->GetLogicalMetadata(),
                                                            parentMembers))
      throw FieldAlreadyExistsException(*this, *mInputPorts[1], mNest);
    RecordMetadata * parentRecord = new RecordMetadata(parentMembers);
    mProjection = new RecordProjection(*mInputPorts[1]->GetMetadata(), *parentRecord);
    mOutputPorts[0]->SetMetadata(parentRecord);
  }
  else
  {
    mMerger = new RecordMerge(mInputPorts[0]->GetMetadata(), mInputPorts[1]->GetMetadata());
    mOutputPorts[0]->SetMetadata(new RecordMetadata(*mMerger->GetRecordMetadata()));
  }
}

RunTimeOperator * DesignTimeSortMergeJoin::code_generate(partition_t maxPartition)
{
  // Create run time sort key specs
  std::vector<RunTimeSortKey> leftRunTimeSortKey;
  for(std::vector<DesignTimeSortKey>::iterator it = mLeftEquiJoinKeys.begin();
      it != mLeftEquiJoinKeys.end();
      it++)
  {
    leftRunTimeSortKey.push_back(RunTimeSortKey(it->GetSortKeyName(), it->GetSortOrder(), NULL));
  }
  std::vector<RunTimeSortKey> rightRunTimeSortKey;
  for(std::vector<DesignTimeSortKey>::iterator it = mRightEquiJoinKeys.begin();
      it != mRightEquiJoinKeys.end();
      it++)
  {
    rightRunTimeSortKey.push_back(RunTimeSortKey(it->GetSortKeyName(), it->GetSortOrder(), NULL));
  }

  if (mNest.size())
  {
    return new RunTimeSortMergeJoin(GetName(),
                                    *mInputPorts[0]->GetMetadata(),
                                    *mInputPorts[1]->GetMetadata(),
                                    leftRunTimeSortKey,
                                    rightRunTimeSortKey,
                                    mResidual,
                                    mJoinType,
                                    *mOutputPorts[0]->GetMetadata(),
                                    mNest,
                                    *mProjection);
  }
  else
  {
    return new RunTimeSortMergeJoin(GetName(),
                                    *mInputPorts[0]->GetMetadata(),
                                    *mInputPorts[1]->GetMetadata(),
                                    leftRunTimeSortKey,
                                    rightRunTimeSortKey,
                                    *mMerger,
                                    mResidual,
                                    mJoinType);
  }
}

void DesignTimeSortMergeJoin::SetLeftEquiJoinKeys(const std::vector<DesignTimeSortKey>& equiJoinKeys)
{
  mLeftEquiJoinKeys = equiJoinKeys;
}

void DesignTimeSortMergeJoin::SetRightEquiJoinKeys(const std::vector<DesignTimeSortKey>& equiJoinKeys)
{
  mRightEquiJoinKeys = equiJoinKeys;
}

void DesignTimeSortMergeJoin::AddLeftEquiJoinKey(const DesignTimeSortKey& equiJoinKey)
{
  mLeftEquiJoinKeys.push_back(equiJoinKey);
}

void DesignTimeSortMergeJoin::AddRightEquiJoinKey(const DesignTimeSortKey& equiJoinKey)
{
  mRightEquiJoinKeys.push_back(equiJoinKey);
}

void DesignTimeSortMergeJoin::SetResidual(const std::wstring& residual)
{
  mResidual = residual;
}

void DesignTimeSortMergeJoin::SetJoinType(DesignTimeSortMergeJoin::JoinType joinType)
{
  mJoinType = joinType;
}

void DesignTimeSortMergeJoin::SetNest(const std::wstring& nest)
{
  mNest = nest;
}

RunTimeSortMergeJoin::RunTimeSortMergeJoin()
  :
  mJoinType(DesignTimeSortMergeJoin::INNER_JOIN),
  mNestedRecordAccessor(NULL)
{
}

RunTimeSortMergeJoin::RunTimeSortMergeJoin(const std::wstring& name, 
                                           const RecordMetadata& leftMetadata,
                                           const RecordMetadata& rightMetadata,
                                           const std::vector<RunTimeSortKey>& leftEquiJoinKeys,
                                           const std::vector<RunTimeSortKey>& rightEquiJoinKeys,
                                           const RecordMerge& merger,
                                           const std::wstring& residual,
                                           DesignTimeSortMergeJoin::JoinType joinType)
  :
  RunTimeOperator(name),
  mLeftMetadata(leftMetadata),
  mRightMetadata(rightMetadata),
  mLeftEquiJoinKeys(leftEquiJoinKeys),
  mRightEquiJoinKeys(rightEquiJoinKeys),
  mMerger(merger),
  mResidual(residual),
  mJoinType(joinType),
  mNestedRecordAccessor(NULL)
{
  // Extract the accessors for equijoin keys 
  for(std::vector<RunTimeSortKey>::iterator it =  mLeftEquiJoinKeys.begin();
      it != mLeftEquiJoinKeys.end();
      it++)
  {
    ASSERT(mLeftMetadata.HasColumn(it->GetSortKeyName()));
    it->SetDataAccessor(mLeftMetadata.GetColumn(it->GetSortKeyName()));
  }
  for(std::vector<RunTimeSortKey>::iterator it =  mRightEquiJoinKeys.begin();
      it != mRightEquiJoinKeys.end();
      it++)
  {
    ASSERT(mRightMetadata.HasColumn(it->GetSortKeyName()));
    it->SetDataAccessor(mRightMetadata.GetColumn(it->GetSortKeyName()));
  }
}

RunTimeSortMergeJoin::RunTimeSortMergeJoin(const std::wstring& name, 
                                           const RecordMetadata& leftMetadata,
                                           const RecordMetadata& rightMetadata,
                                           const std::vector<RunTimeSortKey>& leftEquiJoinKeys,
                                           const std::vector<RunTimeSortKey>& rightEquiJoinKeys,
                                           const std::wstring& residual,
                                           DesignTimeSortMergeJoin::JoinType joinType,
                                           const RecordMetadata& outputMetadata,
                                           const std::wstring& nestedRecord,
                                           const RecordProjection& projection)

  :
  RunTimeOperator(name),
  mLeftMetadata(leftMetadata),
  mRightMetadata(rightMetadata),
  mLeftEquiJoinKeys(leftEquiJoinKeys),
  mRightEquiJoinKeys(rightEquiJoinKeys),
  mResidual(residual),
  mJoinType(joinType),
  mOutputMetadata(outputMetadata),
  mNestedRecordAccessor(NULL),
  mProjection(projection)
{
  // Extract the accessors for equijoin keys 
  for(std::vector<RunTimeSortKey>::iterator it =  mLeftEquiJoinKeys.begin();
      it != mLeftEquiJoinKeys.end();
      it++)
  {
    ASSERT(mLeftMetadata.HasColumn(it->GetSortKeyName()));
    it->SetDataAccessor(mLeftMetadata.GetColumn(it->GetSortKeyName()));
  }
  for(std::vector<RunTimeSortKey>::iterator it =  mRightEquiJoinKeys.begin();
      it != mRightEquiJoinKeys.end();
      it++)
  {
    ASSERT(mRightMetadata.HasColumn(it->GetSortKeyName()));
    it->SetDataAccessor(mRightMetadata.GetColumn(it->GetSortKeyName()));
  }

  if (nestedRecord.size())
  {
    ASSERT(mOutputMetadata.HasColumn(nestedRecord));
    mNestedRecordAccessor = mOutputMetadata.GetColumn(nestedRecord);
  }
}

RunTimeSortMergeJoin::~RunTimeSortMergeJoin()
{
}

RunTimeOperatorActivation * RunTimeSortMergeJoin::CreateActivation(Reactor * reactor, partition_t partition)
{
  if (mNestedRecordAccessor)
  {
    return new RunTimeNestedSortMergeJoinActivation(reactor, partition, this);
  }
  else
  {
    return new RunTimeRelationalSortMergeJoinActivation(reactor, partition, this);
  }
}

RunTimeSortMergeJoinActivation::RunTimeSortMergeJoinActivation(Reactor * reactor, 
                                                               partition_t partition, 
                                                               const RunTimeSortMergeJoin * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeSortMergeJoin>(reactor, partition, runTimeOperator),
  mLeftMessage(NULL),
  mRightMessage(NULL),
  mOutputMessage(NULL),
  mLeftIterator(NULL),
  mResidualInterpreter(NULL),
  mMatchFound(true),
  mLeftBuffer(NULL)
{
}

RunTimeSortMergeJoinActivation::~RunTimeSortMergeJoinActivation()
{
  delete mResidualInterpreter;
}

int RunTimeSortMergeJoinActivation::Compare(record_t lhs, record_t rhs)
{
  std::vector<RunTimeSortKey>::const_iterator leftSortKeyIt = mOperator->mLeftEquiJoinKeys.begin();
  std::vector<RunTimeSortKey>::const_iterator rightSortKeyIt = mOperator->mRightEquiJoinKeys.begin();

  int cmp=0;
  while(cmp==0 && leftSortKeyIt != mOperator->mLeftEquiJoinKeys.end())
  {
    cmp = leftSortKeyIt->GetDataAccessor()->Compare(lhs, rightSortKeyIt->GetDataAccessor(), rhs);

    ++leftSortKeyIt;
    ++rightSortKeyIt;
  }

  return leftSortKeyIt == mOperator->mLeftEquiJoinKeys.end() || leftSortKeyIt->GetSortOrder() == SortOrder::ASCENDING ? cmp : -cmp;
}

void RunTimeSortMergeJoinActivation::Start()
{
  InternalStart();

  // Residual 
  if (mOperator->mResidual.size() > 0)
  {
    MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RunTimeSortMergeJoin]");
    mResidualInterpreter = new MetraFlowDualRecordInterpreter(mOperator->mResidual, mOperator->mLeftMetadata, mOperator->mRightMetadata, logger);
  }

  mState = START;
  HandleEvent(NULL);
}

void RunTimeSortMergeJoinActivation::HandleEvent(Endpoint * ep)
{
  // TODO: We assume that the left input has the shorter
  // sort runs.  Improve the algorithm so that we adapt
  // if the right side has shorter runs.
  switch(mState) 
  {
  case START:
    RequestRead(0);
    mState = READ_LEFT_INIT;
    return;
  case READ_LEFT_INIT:
    Read(mLeftMessage, ep);

    RequestRead(1);
    mState = READ_RIGHT_INIT;
    return;
  case READ_RIGHT_INIT:
    Read(mRightMessage, ep);

    while(!mOperator->mLeftMetadata.IsEOF(mLeftMessage) &&
          !mOperator->mRightMetadata.IsEOF(mRightMessage))
    {
      while(0 > Compare(mLeftMessage, mRightMessage))
      {
        mOperator->mLeftMetadata.Free(mLeftMessage);
        RequestRead(0);
        mState = READ_LEFT_ADVANCE_LT;
        return;
      case READ_LEFT_ADVANCE_LT:
        Read(mLeftMessage, ep);

        if (mOperator->mLeftMetadata.IsEOF(mLeftMessage))
          break;
      }

      if(!mOperator->mLeftMetadata.IsEOF(mLeftMessage) && 
         !mOperator->mRightMetadata.IsEOF(mRightMessage) &&
         0 == Compare(mLeftMessage, mRightMessage))
      {
        // Read and buffer a matching sort run for the left input.
        while(!mOperator->mLeftMetadata.IsEOF(mLeftMessage) && 0 == Compare(mLeftMessage, mRightMessage))
        {
          mBuffer.Push(mLeftMessage);
          RequestRead(0);
          mState = READ_LEFT_ADVANCE_EQ;
          return;
        case READ_LEFT_ADVANCE_EQ:
          Read(mLeftMessage, ep);
        } 

        // Scan the right input for its sort run, computing the cross product
        // with the buffered left input.
        while(!mOperator->mRightMetadata.IsEOF(mRightMessage) && 
              0 == Compare(mBuffer.Top(), mRightMessage))
        {
          mMatchFound = false;
          mLastMatch = NULL;
          // Output all matches for inner and outer.
          // Output a single record for match on semi
          // Output on no match on anti semi
          mLeftIterator = mBuffer.Head();
          while(true)
          {
            if(NULL == mResidualInterpreter ||
               mResidualInterpreter->ExecuteFunction(mLeftIterator, mRightMessage)->getBool())
            {
              mMatchFound = true;
              if (mOperator->mJoinType == DesignTimeSortMergeJoin::INNER_JOIN ||
                  mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_OUTER ||
                  mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_OUTER_SPLIT)
              {
                // When processing a matches, we keep track of when we have the last match
                // in a run because for that match we can use transfer semantics.
                if (mLastMatch)
                {
                  ProcessMatch(false);
                  if (NULL == mOperator->mNestedRecordAccessor)
                  {
                    RequestWrite(0);
                    mState = WRITE_MATCH;
                    return;
                  case WRITE_MATCH:
                    Write(mOutputMessage, ep);
                    mOutputMessage = NULL;
                  }
                }
                mLastMatch = mLeftIterator;
              }
              else if (mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_SEMI)
              {
                mOutputMessage = mRightMessage;
                RequestWrite(0);
                mState = WRITE_SEMI_MATCH;
                return;
              case WRITE_SEMI_MATCH:
                Write(mOutputMessage, ep);
                mOutputMessage = NULL;
                // Make sure this doesn't get freed.
                mRightMessage = NULL;
                // Break outta here cause we're done with this message
                break;
              }
            }
            if (mLeftIterator == mBuffer.Tail()) 
            {
              if (mLastMatch && (
                    mOperator->mJoinType == DesignTimeSortMergeJoin::INNER_JOIN ||
                    mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_OUTER ||
                    mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_OUTER_SPLIT))
              {
                ProcessMatch(true);
                RequestWrite(0);
                mState = WRITE_LAST_MATCH;
                return;
              case WRITE_LAST_MATCH:
                Write(mOutputMessage, ep);
                mOutputMessage = NULL;
              }
              else if (!mMatchFound && mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_ANTI_SEMI)
              {
                mOutputMessage = mRightMessage;
                RequestWrite(0);
                mState = WRITE_ANTI_SEMI_NO_MATCH;
                return;
              case WRITE_ANTI_SEMI_NO_MATCH:
                Write(mOutputMessage, ep);
                mOutputMessage = NULL;
                // Make sure this doesn't get freed.
                mRightMessage = NULL;
              }
              else if (!mMatchFound && mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_OUTER)
              {
                ProcessNonMatch();
                RequestWrite(0);
                mState = WRITE_RIGHT_OUTER_NO_MATCH;
                return;
              case WRITE_RIGHT_OUTER_NO_MATCH:
                Write(mOutputMessage, ep);
                mOutputMessage = NULL;
              }
              break;
            }
            mLeftIterator = RecordMetadata::GetNext(mLeftIterator);
          }

          // mRightMessage has been NULLed out if it has been
          // output by semi join processing.
          if (mRightMessage != NULL) 
            mOperator->mRightMetadata.Free(mRightMessage);
          RequestRead(1);
          mState = READ_RIGHT_ADVANCE_EQ;
          return;
        case READ_RIGHT_ADVANCE_EQ:
          Read(mRightMessage, ep);
        }

        // Free buffered messages
        while(mBuffer.GetSize() > 0)
        {
          record_t tmp;
          mBuffer.Pop(tmp);
          mOperator->mLeftMetadata.Free(tmp);
        }
      }

      // If we didn't have a match, right input may still be lagging,
      // so we advance it.
      while(!mOperator->mLeftMetadata.IsEOF(mLeftMessage) && 
            !mOperator->mRightMetadata.IsEOF(mRightMessage) && 
            0 < Compare(mLeftMessage, mRightMessage))
      {
        if (mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_ANTI_SEMI)
        {
          mOutputMessage = mRightMessage;
          RequestWrite(0);
          mState = WRITE_ANTI_SEMI_NO_MATCH_ADVANCE_LT;
          return;
        case WRITE_ANTI_SEMI_NO_MATCH_ADVANCE_LT:
          Write(mOutputMessage, ep);
          mOutputMessage = NULL;
          // Make sure this doesn't get freed.
          mRightMessage = NULL;
        }
        else if (mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_OUTER)
        {
          ProcessNonMatch();
          RequestWrite(0);
          mState = WRITE_RIGHT_OUTER_NO_MATCH_ADVANCE_LT;
          return;
        case WRITE_RIGHT_OUTER_NO_MATCH_ADVANCE_LT:
          Write(mOutputMessage, ep);
          mOutputMessage = NULL;
        }
        if (mRightMessage != NULL)
          mOperator->mRightMetadata.Free(mRightMessage);
        RequestRead(1);
        mState = READ_RIGHT_ADVANCE_LT;
        return;
      case READ_RIGHT_ADVANCE_LT:
        Read(mRightMessage, ep);
        if (mOperator->mRightMetadata.IsEOF(mRightMessage))
          break;
      }
    }

    while(!mOperator->mLeftMetadata.IsEOF(mLeftMessage))
    {
      mOperator->mLeftMetadata.Free(mLeftMessage);
      RequestRead(0);
      mState = READ_LEFT_DRAIN;
      return;
    case READ_LEFT_DRAIN:
      Read(mLeftMessage, ep);
    }

    // Free EOF record
    mOperator->mLeftMetadata.Free(mLeftMessage);

    while(!mOperator->mRightMetadata.IsEOF(mRightMessage))
    {
      if (mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_ANTI_SEMI)
      {
        mOutputMessage = mRightMessage;
        RequestWrite(0);
        mState = WRITE_ANTI_SEMI_NO_MATCH_DRAIN;
        return;
      case WRITE_ANTI_SEMI_NO_MATCH_DRAIN:
        Write(mOutputMessage, ep);
        mOutputMessage = NULL;
        // Make sure this doesn't get freed.
        mRightMessage = NULL;
      }
      else if (mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_OUTER)
      {
        ProcessNonMatch();
        RequestWrite(0);
        mState = WRITE_RIGHT_OUTER_NO_MATCH_DRAIN;
        return;
      case WRITE_RIGHT_OUTER_NO_MATCH_DRAIN:
        Write(mOutputMessage, ep);
        mOutputMessage = NULL;
      }
      if (mRightMessage != NULL)
        mOperator->mRightMetadata.Free(mRightMessage);
      RequestRead(1);
      mState = READ_RIGHT_DRAIN;
      return;
    case READ_RIGHT_DRAIN:
      Read(mRightMessage, ep);
    }

    // Free EOF record
    mOperator->mRightMetadata.Free(mRightMessage);

    // Write output and flush
    RequestWrite(0);
    mState = WRITE_EOF;
    return;
  case WRITE_EOF:
    if (mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_SEMI ||
        mOperator->mJoinType == DesignTimeSortMergeJoin::RIGHT_ANTI_SEMI)
    {
      Write(mOperator->mRightMetadata.AllocateEOF(), ep, true);
    }
    else
    {
      ProcessEOF(ep);
    }
  }
}

RunTimeRelationalSortMergeJoinActivation::RunTimeRelationalSortMergeJoinActivation(Reactor * reactor, 
                                                                                   partition_t partition, 
                                                                                   const RunTimeSortMergeJoin * runTimeOperator)
  :
  RunTimeSortMergeJoinActivation(reactor, partition, runTimeOperator)
{
}

RunTimeRelationalSortMergeJoinActivation::~RunTimeRelationalSortMergeJoinActivation()
{
  if (mLeftBuffer != NULL) mOperator->mLeftMetadata.Free(mLeftBuffer);
  mLeftBuffer = NULL;
}

void RunTimeRelationalSortMergeJoinActivation::ProcessMatch(bool lastMatch)
{
  mOutputMessage = mOperator->mMerger.GetRecordMetadata()->Allocate();
  mOperator->mMerger.Merge(mLastMatch, mRightMessage, mOutputMessage, false, lastMatch);
  if (lastMatch)
  {
    mOperator->mRightMetadata.ShallowFree(mRightMessage);
    mRightMessage = NULL;
  }
}

void RunTimeRelationalSortMergeJoinActivation::ProcessNonMatch()
{
  mOutputMessage = mOperator->mMerger.GetRecordMetadata()->Allocate();
  mOperator->mMerger.Merge(mLeftBuffer, mRightMessage, mOutputMessage);
  // TODO: I am pretty sure we can use transfer semantics on right and shallow free here.
}

void RunTimeRelationalSortMergeJoinActivation::InternalStart()
{
  // Allocate a NULL for left input for use in outer join processing.
  mLeftBuffer = mOperator->mLeftMetadata.Allocate();
}

void RunTimeRelationalSortMergeJoinActivation::ProcessEOF(Endpoint * ep)
{
  Write(mOperator->mMerger.GetRecordMetadata()->AllocateEOF(), ep, true);
}

RunTimeNestedSortMergeJoinActivation::RunTimeNestedSortMergeJoinActivation(Reactor * reactor, 
                                                                           partition_t partition, 
                                                                           const RunTimeSortMergeJoin * runTimeOperator)
  :
  RunTimeSortMergeJoinActivation(reactor, partition, runTimeOperator)
{
}

RunTimeNestedSortMergeJoinActivation::~RunTimeNestedSortMergeJoinActivation()
{
}

void RunTimeNestedSortMergeJoinActivation::ProcessMatch(bool /*lastMatch*/)
{
  // Check if this is first match; if so we need a new output.
  if (!mOutputMessage)
  {
    mOutputMessage = mOperator->mOutputMetadata.Allocate();
    mOperator->mProjection.Project(mRightMessage, mOutputMessage, true);
    mOperator->mRightMetadata.ShallowFree(mRightMessage);
    mRightMessage = NULL;
  }

  // TODO: Add lookahead on the right so we know whether we can use transfer here.
  record_t tmp = mOperator->mLeftMetadata.Clone(mLastMatch);
  mOperator->mNestedRecordAccessor->SetValue(mOutputMessage, tmp);
}

void RunTimeNestedSortMergeJoinActivation::ProcessNonMatch()
{
  mOutputMessage = mOperator->mOutputMetadata.Allocate();
  mOperator->mProjection.Project(mRightMessage, mOutputMessage, true);
  mOperator->mRightMetadata.ShallowFree(mRightMessage);
  mRightMessage = NULL;
}

void RunTimeNestedSortMergeJoinActivation::InternalStart()
{
}

void RunTimeNestedSortMergeJoinActivation::ProcessEOF(Endpoint * ep)
{
  Write(mOperator->mOutputMetadata.AllocateEOF(), ep, true);
}


