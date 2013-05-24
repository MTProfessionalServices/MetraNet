#include "LongestPrefixMatch.h"
#include "OperatorArg.h"

DesignTimeLongestPrefixMatch::DesignTimeLongestPrefixMatch()
  :
  mMerger(NULL)
{
  mInputPorts.insert(this, 0, L"table", false);
  mInputPorts.insert(this, 1, L"probe", false);  
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeLongestPrefixMatch::~DesignTimeLongestPrefixMatch()
{
  delete mMerger;
}

void DesignTimeLongestPrefixMatch::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"probeKey", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddProbeKey(arg.getNormalizedString());
  }
  else if (arg.is(L"tableKey", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddTableKey(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeLongestPrefixMatch* DesignTimeLongestPrefixMatch::clone(
                                                              const std::wstring& name,
                                                              std::vector<OperatorArg *>& args, 
                                                              int nInputs, int nOutputs) const
{
  DesignTimeLongestPrefixMatch* result = new DesignTimeLongestPrefixMatch();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeLongestPrefixMatch::type_check()
{
  // Validate that the equijoin keys exist and have matching types.
  for(std::vector<std::wstring>::const_iterator it = mProbeEquiJoinKeys.begin();
      it != mProbeEquiJoinKeys.end();
      ++it)
  {
    if (!mInputPorts[1]->GetMetadata()->HasColumn(*it))
    {
      throw MissingFieldException(*this, *mInputPorts[1], *it);
    }
    ASSERT(mInputPorts[0]->GetMetadata()->HasColumn(mTableEquiJoinKeys[it - mProbeEquiJoinKeys.begin()]));
    if (*mInputPorts[1]->GetMetadata()->GetColumn(*it)->GetPhysicalFieldType() !=
        *mInputPorts[0]->GetMetadata()->GetColumn(mTableEquiJoinKeys[it - mProbeEquiJoinKeys.begin()])->GetPhysicalFieldType())
    {
      throw FieldTypeMismatchException(*this,
                                       *mInputPorts[1], *mInputPorts[1]->GetMetadata()->GetColumn(*it),
                                       *mInputPorts[0], *mInputPorts[0]->GetMetadata()->GetColumn(mTableEquiJoinKeys[it - mProbeEquiJoinKeys.begin()]));
    }
  }

  // Currently we only support a single varchar column.
  if (mProbeEquiJoinKeys.size() > 1) throw std::runtime_error("Longest prefix match only supports a single key");
  if (mTableEquiJoinKeys.size() > 1) throw std::runtime_error("Longest prefix match only supports a single key");
  if (mInputPorts[0]->GetMetadata()->GetColumn(mTableEquiJoinKeys[0])->GetPhysicalFieldType()->GetPipelineType() !=
      MTPipelineLib::PROP_TYPE_STRING)
    throw std::runtime_error("Longest prefix match only supports nvarchar keys");
  // Everything cool.
  mMerger = new RecordMerge(mInputPorts[0]->GetMetadata(), mInputPorts[1]->GetMetadata());
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mMerger->GetRecordMetadata()));
}

RunTimeOperator * DesignTimeLongestPrefixMatch::code_generate(partition_t maxPartition)
{
  std::vector<RunTimeDataAccessor> tableAccessors;
  for(std::vector<std::wstring>::const_iterator it = mTableEquiJoinKeys.begin();
      it != mTableEquiJoinKeys.end();
      ++it)
  {
    tableAccessors.push_back(*mInputPorts[0]->GetMetadata()->GetColumn(*it));
  }
  
  std::vector<RunTimeDataAccessor> probeAccessors;
  for(std::vector<std::wstring>::const_iterator it = mProbeEquiJoinKeys.begin();
      it != mProbeEquiJoinKeys.end();
      ++it)
  {
    probeAccessors.push_back(*mInputPorts[1]->GetMetadata()->GetColumn(*it));
  }

  return new RunTimeLongestPrefixMatch(mName, 
                                       *mInputPorts[0]->GetMetadata(),
                                       *mInputPorts[1]->GetMetadata(),
                                       tableAccessors,
                                       probeAccessors,
                                       *mMerger
                                       );
}

void DesignTimeLongestPrefixMatch::AddProbeKey(const std::wstring& equiJoinKey)
{
  mProbeEquiJoinKeys.push_back(equiJoinKey);
}

void DesignTimeLongestPrefixMatch::AddTableKey(const std::wstring& equiJoinKey)
{
  mTableEquiJoinKeys.push_back(equiJoinKey);
}

RunTimeLongestPrefixMatch::RunTimeLongestPrefixMatch()
{
}

RunTimeLongestPrefixMatch::RunTimeLongestPrefixMatch(const std::wstring& name, 
                                                     const RecordMetadata& tableMetadata,
                                                     const RecordMetadata& probeMetadata,
                                                     const std::vector<RunTimeDataAccessor>& tableKeys,
                                                     const std::vector<RunTimeDataAccessor>& probeKeys,
                                                     const RecordMerge& merger)
  :
  RunTimeOperator(name),
  mTableMetadata(tableMetadata),
  mProbeMetadata(probeMetadata),
  mProbeKeys(probeKeys),
  mTableKeys(tableKeys),
  mMerger(merger)
{
}

RunTimeLongestPrefixMatch::~RunTimeLongestPrefixMatch()
{
}

RunTimeOperatorActivation * RunTimeLongestPrefixMatch::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeLongestPrefixMatchActivation(reactor, partition, this);
}

RunTimeLongestPrefixMatchActivation::RunTimeLongestPrefixMatchActivation(Reactor * reactor, 
                                                                         partition_t partition, 
                                                                         const RunTimeLongestPrefixMatch * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeLongestPrefixMatch>(reactor, partition, runTimeOperator),
  mState(START),
  mTST(NULL)
{
}

RunTimeLongestPrefixMatchActivation::~RunTimeLongestPrefixMatchActivation()
{
  delete mTST;
}

void RunTimeLongestPrefixMatchActivation::Start()
{
  mTST = new TernarySearchTree<wchar_t, boost::uint8_t>();
  mState = START;
  HandleEvent(NULL);
}

void RunTimeLongestPrefixMatchActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(true)
    {
      // Load up the table
      while(true)
      {
        RequestRead(0);
        mState = READ_TABLE;
        return;
      case READ_TABLE:
      {
        Read(mMessage, ep);
        if (!mOperator->mTableMetadata.IsEOF(mMessage))
        {
          // Grab the key and load up the table.
          // TODO: Sort keys and then insert in approximate median order.
          ASSERT(mOperator->mTableKeys.size() == 1);
          ASSERT(mOperator->mTableKeys[0].GetPhysicalFieldType()->GetPipelineType() ==
                 MTPipelineLib::PROP_TYPE_STRING);

          if (mOperator->mTableKeys[0].GetNull(mMessage))
            throw std::runtime_error("Null lookup key in longest prefix match");

          // TODO: Handle duplicates
          const wchar_t * key = mOperator->mTableKeys[0].GetStringValue(mMessage);
          mTST->Insert(key, key + wcslen(key), mMessage);
        }
        else
        {
          mOperator->mTableMetadata.Free(mMessage);
          break;
        }
      }
      }

      while(true)
      {
        RequestRead(1);
        mState = READ_PROBE;
        return;
      case READ_PROBE:
        Read(mMessage, ep);

        if (!mOperator->mProbeMetadata.IsEOF(mMessage))
        {
          {
          const wchar_t * key = mOperator->mProbeKeys[0].GetStringValue(mMessage);
          MessagePtr tmp = mTST->LongestPrefixSearch(key, key + wcslen(key));
          if (NULL == tmp) continue;
          MessagePtr result = mOperator->mMerger.GetRecordMetadata()->Allocate();
          mOperator->mMerger.Merge(tmp, mMessage, result, false, true);
          mOperator->mProbeMetadata.ShallowFree(mMessage);
          mMessage = result;
          }
          RequestWrite(0);
          mState = WRITE;
          return;
        case WRITE:
          Write(mMessage, ep);
        }
        else
        {
          mOperator->mProbeMetadata.Free(mMessage);
          RequestWrite(0);
          mState = WRITE_EOF;
          return;
        case WRITE_EOF:
          Write(mOperator->mMerger.GetRecordMetadata()->AllocateEOF(), ep, true);

          // TODO: Free up TST
          return;
        }
      }
    }
  }
}
