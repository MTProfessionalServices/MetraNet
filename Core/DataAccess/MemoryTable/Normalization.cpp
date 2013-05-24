#include <boost/format.hpp>

#include "MTUtil.h"
#include "Normalization.h"
#include "OperatorArg.h"

DesignTimeSortNest::DesignTimeSortNest()
{
  mInputPorts.push_back(this, L"input", false);
  mOutputPorts.push_back(this, L"output", false);
  mAlwaysUpdateParent= false;
}

DesignTimeSortNest::~DesignTimeSortNest()
{
}

void DesignTimeSortNest::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddGroupKey(DesignTimeSortKey(arg.getNormalizedString(),
                                  SortOrder::ASCENDING));
  }
  else if (arg.is(L"recordName", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetRecordName(arg.getNormalizedString());
  }
  else if (arg.is(L"raise", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mRaiseFields.push_back(arg.getNormalizedString());
  }
  else if (arg.is(L"parentKey", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddParentField(arg.getNormalizedString());
  }
  else if (arg.is(L"alwaysUpdateParent", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    mAlwaysUpdateParent = arg.getBoolValue();
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeSortNest* DesignTimeSortNest::clone(
  const std::wstring& name,
  std::vector<OperatorArg *>& args, 
  int nInputs, int nOutputs) const
{
  DesignTimeSortNest* result = new DesignTimeSortNest();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeSortNest::AddParentField(const std::wstring& parentField)
{
  mParentFields.push_back(parentField);
}

void DesignTimeSortNest::AddGroupKey(const std::wstring& key)
{
  mGroupKeys.push_back(DesignTimeSortKey(key, SortOrder::ASCENDING));
}

void DesignTimeSortNest::AddGroupKey(const DesignTimeSortKey& key)
{
  mGroupKeys.push_back(key);
}

void DesignTimeSortNest::SetRecordName(const std::wstring& recordName)
{
  mRecordName = recordName;
}

void DesignTimeSortNest::type_check()
{
  // Validate sort keys
  CheckSortKeys(0, mGroupKeys);
  
  // Make sure that all group keys are in the input schema
  const LogicalRecord& input(mInputPorts[0]->GetLogicalMetadata());

  if (mRecordName.size() == 0 || !RecordMember::IsValidTopLevelName(mRecordName))
  {
    throw std::logic_error("Must specifiy valid record name");
  }

  // Should we enforce that all group keys are in a parent field?
  // If a group key is in a parent field of subrecord type, 
  // does the parent have to come along for the ride?  For now I say yes.
  std::set<std::wstring> parentFields;
  for(std::vector<std::wstring>::const_iterator it = mParentFields.begin();
      it != mParentFields.end();
      ++it)
  {
    parentFields.insert(boost::to_upper_copy(*it));
  }
  for(std::vector<DesignTimeSortKey>::const_iterator it = mGroupKeys.begin();
      it != mGroupKeys.end();
      ++it)
  {
    if (parentFields.end() == parentFields.find(boost::to_upper_copy(input.GetRootColumn(it->GetSortKeyName()))))
      mParentFields.push_back(input.GetRootColumn(it->GetSortKeyName()));
  }

  // Get the child columns
  std::vector<std::wstring> childColumns;
  std::vector<std::wstring> missingColumns;
  input.ColumnComplement(mParentFields, childColumns, missingColumns);

  LogicalRecord nested;
  input.NestColumns(mRecordName, childColumns, true, nested);

  // Raise fields out of subrecords as requested.

  // Set output metadata.
  mOutputPorts[0]->SetMetadata(new RecordMetadata(nested));  
}

RunTimeOperator * DesignTimeSortNest::code_generate(partition_t maxPartition)
{
  // Create run time sort key specs
  std::vector<RunTimeSortKey> runTimeSortKey;
  for(std::vector<DesignTimeSortKey>::iterator it = mGroupKeys.begin();
      it != mGroupKeys.end();
      it++)
  {
    runTimeSortKey.push_back(RunTimeSortKey(it->GetSortKeyName(), it->GetSortOrder(), NULL));
  }
  
  return new RunTimeSortNest(mName, 
                             *mInputPorts[0]->GetMetadata(),
                             // TODO: Fix this
                             L"",
                             *mOutputPorts[0]->GetMetadata(),
                             *mOutputPorts[0]->GetMetadata()->GetColumn(mRecordName)->GetPhysicalFieldType()->GetMetadata(),
                             runTimeSortKey,
                             mRecordName,
                             mAlwaysUpdateParent);
}

RunTimeSortNest::RunTimeSortNest(const std::wstring& name, 
                                 const RecordMetadata& inputMetadata,
                                 const std::wstring& parentPrefix,
                                 const RecordMetadata& outputMetadata,
                                 const RecordMetadata& childMetadata,
                                 const std::vector<RunTimeSortKey>& groupKeys,
                                 const std::wstring& nestedRecordName,
                                 bool alwaysUpdateParent)
  :
  RunTimeOperator(name),
  mInputMetadata(inputMetadata),
  mOutputMetadata(outputMetadata),
  mNestedRecordMetadata(childMetadata),
  mGroupKeys(groupKeys),
  mParentProjection(inputMetadata, outputMetadata),
  mNestedRecordProjection(inputMetadata, childMetadata),
  mNestedRecordName(nestedRecordName),
  mAlwaysUpdateParent(alwaysUpdateParent)
{
  // Extract the accessors for sort keys from our private copy of the input metadata
  for(std::vector<RunTimeSortKey>::iterator it =  mGroupKeys.begin();
      it != mGroupKeys.end();
      it++)
  {
    ASSERT(mInputMetadata.HasColumn(it->GetSortKeyName()));
    it->SetDataAccessor(mInputMetadata.GetColumn(it->GetSortKeyName()));
  }
}

bool RunTimeSortNest::IsAlwaysUpdateParent() const
{
  return mAlwaysUpdateParent;
}

RunTimeSortNest::~RunTimeSortNest()
{
}

RunTimeOperatorActivation * RunTimeSortNest::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeSortNestActivation(reactor, partition, this);
}

RunTimeSortNestActivation::RunTimeSortNestActivation(Reactor * reactor, 
                                                     partition_t partition,
                                                     const RunTimeSortNest * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeSortNest>(reactor, partition, runTimeOperator),
  mState(START),
  mProcessed(0LL),
  mInputMessage(NULL),
  mOutputMessage(NULL),
  mNestedRecordAccessor(NULL)
{
  mBuffer[0] = mBuffer[1] = NULL;
}

RunTimeSortNestActivation::~RunTimeSortNestActivation()
{
  delete mBuffer[0];
  delete mBuffer[1];
}

void RunTimeSortNestActivation::Start()
{
  // Bind the nested record accessor.
  mNestedRecordAccessor = mOperator->mOutputMetadata.GetColumn(mOperator->mNestedRecordName);

  mState = START;
  HandleEvent(NULL);
}

void RunTimeSortNestActivation::InitializeAccumulator()
{
  // Create a new record with the group by keys and initialize accumulators.
  mOutputMessage = mOperator->mOutputMetadata.Allocate();
  // Project group keys onto new output
  mOperator->mParentProjection.Project(mInputMessage, mOutputMessage, true);
  // TODO: Do we have to allocate a new nested collection?
}

void RunTimeSortNestActivation::Accumulate()
{
  // Project non-group keys onto nested record and add to parent.
  record_t childRecord = mOperator->mNestedRecordMetadata.Allocate();
  mOperator->mNestedRecordProjection.Project(mInputMessage, childRecord, true);
  
  // TODO: API for appending record to nested collection.
  mNestedRecordAccessor->SetValue(mOutputMessage, childRecord);

  mOperator->mInputMetadata.Free(mInputMessage);
}

void RunTimeSortNestActivation::ExportSortKey(const_record_t buffer, SortKeyBuffer& sortKeyBuffer)
{
  sortKeyBuffer.Clear();
  for (std::vector<RunTimeSortKey>::const_iterator it = mOperator->mGroupKeys.begin();
       it != mOperator->mGroupKeys.end();
       it++)
  {
    it->GetDataAccessor()->ExportSortKey(buffer, it->GetSortOrder(), sortKeyBuffer);
  } 
}

void RunTimeSortNestActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    RequestRead(0);
    mState = READ_FIRST_0;
    return;
  case READ_FIRST_0:
    Read(mInputMessage, ep);
    if (!mOperator->mInputMetadata.IsEOF(mInputMessage))
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
        if (!mOperator->mInputMetadata.IsEOF(mInputMessage))
        {
          mProcessed++;
          // Export sort key and compare to see if key has changed.
          ExportSortKey(mInputMessage, *mBuffer[mCurrentBuffer]);
          if (0 != SortKeyBuffer::Compare(*mBuffer[mCurrentBuffer], *mBuffer[!mCurrentBuffer]))
          {
            // KeyChange!
            // Reset current sort key.
            mCurrentBuffer = !mCurrentBuffer;
            // output current accumulated values
            RequestWrite(0);
            mState = WRITE_0;
            return;
          case WRITE_0:
            Write(mOutputMessage, ep);
            // Reinitialize accumulator
            InitializeAccumulator();
          }

          if (mOperator->IsAlwaysUpdateParent())
          {
            mOperator->mParentProjection.Project(mInputMessage, mOutputMessage, true);
          }
          Accumulate();
        }
        else
        {
          // Write the last accumulator
          RequestWrite(0);
          mState = WRITE_LAST_0;
          return;
        case WRITE_LAST_0:
          Write(mOutputMessage, ep);
          // Go to write EOF
          break;
        }
      } 
    }

    // Free input EOF message
    mOperator->mInputMetadata.Free(mInputMessage);
    // Write EOF
    RequestWrite(0);
    mState = WRITE_EOF_0;
    return;
  case WRITE_EOF_0:
    Write(mOperator->mOutputMetadata.AllocateEOF(), ep, true);
  }
}

DesignTimeUnnest::DesignTimeUnnest()
{
  mInputPorts.push_back(this, L"input", false);
  mOutputPorts.push_back(this, L"output", false);
}

DesignTimeUnnest::~DesignTimeUnnest()
{
}

void DesignTimeUnnest::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"prefix", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetPrefix(arg.getNormalizedString());
  }
  else if (arg.is(L"recordName", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetRecordName(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeUnnest* DesignTimeUnnest::clone(
  const std::wstring& name,
  std::vector<OperatorArg *>& args, 
  int nInputs, int nOutputs) const
{
  DesignTimeUnnest* result = new DesignTimeUnnest();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeUnnest::SetPrefix(const std::wstring& prefix)
{
  mPrefix = prefix;
}

void DesignTimeUnnest::SetRecordName(const std::wstring& recordName)
{
  mRecordName = recordName;
}

void DesignTimeUnnest::type_check()
{
  const LogicalRecord & input(mInputPorts[0]->GetLogicalMetadata());

  std::vector<std::wstring> unnestColumn;
  std::vector<std::wstring> parentFields;
  std::vector<std::wstring> missingFields;
  unnestColumn.push_back(mRecordName);
  input.ColumnComplement(unnestColumn, parentFields, missingFields);
  if (missingFields.size() > 0)
  {
    throw MissingFieldException(*this, *mInputPorts[0], mRecordName);
  }

  if(input.GetColumn(mRecordName).GetType().GetPipelineType() != MTPipelineLib::PROP_TYPE_SET ||
     !input.GetColumn(mRecordName).GetType().IsList())
  {
    std::string utf8Msg;
    ::WideStringToUTF8((boost::wformat(L"Field %1% of operator %2% must be a list of records") % mRecordName % mName).str(), utf8Msg);
    throw std::logic_error(utf8Msg);
  }

  // All parent fields except the nested collection stay in the parent.
  // All nested collection fields are raised into the parent.
  // Parent fields are placed in a subrecord if requested.  If nesting parent fields,
  // we do this first to avoid spurious name collisions.
  std::map<std::wstring, std::wstring> renaming;
  LogicalRecord parentRecord;
  if (mPrefix.size() > 0)
  {
    // If we have a prefix, set up renaming.  An empty renaming map
    // is interpreted as the identity mapping which is the correct
    // behavior for an empty prefix.
    for(std::vector<std::wstring>::const_iterator it = parentFields.begin();
        it != parentFields.end();
        ++it)
    {
      renaming[*it] = mPrefix + L"." + (*it);
    }
  }
  LogicalRecord parentSubRecord;    
  input.Rename(renaming, parentFields, parentSubRecord, mParentFieldMap);
  parentSubRecord.UnnestColumn(mRecordName, parentRecord, missingFields);
  if (missingFields.size() > 0)
  {
    throw FieldAlreadyExistsException(*this, *mInputPorts[0], missingFields[0]);
  }

  // Set output metadata.
  mOutputPorts[0]->SetMetadata(new RecordMetadata(parentRecord));  
}

RunTimeOperator * DesignTimeUnnest::code_generate(partition_t maxPartition)
{
  return new RunTimeUnnest(mName,  
                           *mInputPorts[0]->GetMetadata(),
                           *mOutputPorts[0]->GetMetadata(),
                           *mInputPorts[0]->GetMetadata()->GetColumn(mRecordName)->GetPhysicalFieldType()->GetMetadata(),
                           mRecordName,
                           mParentFieldMap);
}

RunTimeUnnest::RunTimeUnnest(const std::wstring& name, 
                             const RecordMetadata& inputMetadata,
                             const RecordMetadata& outputMetadata,
                             const RecordMetadata& childMetadata,
                             const std::wstring& nestedRecordName,
                             const std::map<std::wstring, std::wstring>& parentFieldMap)
  :
  RunTimeOperator(name),
  mInputMetadata(inputMetadata),
  mOutputMetadata(outputMetadata),
  mNestedRecordMetadata(childMetadata),
  mParentProjection(inputMetadata, outputMetadata, parentFieldMap),
  mNestedRecordProjection(childMetadata, outputMetadata),
  mNestedRecordName(nestedRecordName)
{
}

RunTimeUnnest::~RunTimeUnnest()
{
}

RunTimeOperatorActivation * RunTimeUnnest::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeUnnestActivation(reactor, partition, this);
}

RunTimeUnnestActivation::RunTimeUnnestActivation(Reactor * reactor, 
                                                 partition_t partition,
                                                 const RunTimeUnnest * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeUnnest>(reactor, partition, runTimeOperator),
  mState(START),
  mInputMessage(NULL),
  mOutputMessage(NULL),
  mNestedRecordAccessor(NULL),
  mEnd(NULL),
  mIt(NULL)
{
}

RunTimeUnnestActivation::~RunTimeUnnestActivation()
{
}

void RunTimeUnnestActivation::Start()
{
  // Bind the nested record accessor.
  mNestedRecordAccessor = mOperator->mInputMetadata.GetColumn(mOperator->mNestedRecordName);

  mState = START;
  HandleEvent(NULL);
}

void RunTimeUnnestActivation::HandleEvent(Endpoint * ep)
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
      if (!mOperator->mInputMetadata.IsEOF(mInputMessage))
      {
        // Iterate over all records in the nested collection
        // and lift
        // Iterate over nested records.
        mEnd = mNestedRecordAccessor->GetNull(mInputMessage) ? NULL : mNestedRecordAccessor->GetRecordValue(mInputMessage);
        if (mEnd)
        {
          mEnd = RecordMetadata::GetNext((record_t) mEnd);
          mIt = mEnd;
          do
          {
            mOutputMessage = mOperator->mOutputMetadata.Allocate();
            mOperator->mNestedRecordProjection.Project(mIt, mOutputMessage, true);
            mIt = RecordMetadata::GetNext((record_t) mIt);
            // If this is the last element of the collection then we can use transfer
            // semantics on the parent record to avoid deep copies.
            mOperator->mParentProjection.Project(mInputMessage, mOutputMessage, mIt==mEnd);
            RequestWrite(0);
            mState = WRITE_0;
            return;
          case WRITE_0:
            Write(mOutputMessage, ep);
          } while (mIt != mEnd);
          // Free input EOF message
          mOperator->mInputMetadata.Free(mInputMessage);
        }
        else
        {
          // TODO: Implement right outer join semantics here
          mOperator->mInputMetadata.Free(mInputMessage);
        }
      }
      else
      {
        // Free input EOF message
        mOperator->mInputMetadata.Free(mInputMessage);
        // Write EOF
        RequestWrite(0);
        mState = WRITE_EOF_0;
        return;
      case WRITE_EOF_0:
        Write(mOperator->mOutputMetadata.AllocateEOF(), ep, true);
        break;
      }
    }
  }
}
