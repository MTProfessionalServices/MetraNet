#include "IdGeneratorOperator.h"
#include "OperatorArg.h"
#include "OdbcConnMan.h"
#include "OdbcConnection.h"
#include "OdbcPreparedArrayStatement.h"
#include "OdbcResultSet.h"

#include <boost/format.hpp>


DesignTimeIdGenerator::DesignTimeIdGenerator()
{
  mInputPorts.push_back(this, L"input", false);
  mOutputPorts.push_back(this, L"output", false);
}

DesignTimeIdGenerator::~DesignTimeIdGenerator()
{
}

void DesignTimeIdGenerator::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"idName", OPERATOR_ARG_TYPE_STRING, GetName()) ||
      arg.is(L"id", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetIdName(arg.getNormalizedString());
  }
  else if (arg.is(L"sequence", OPERATOR_ARG_TYPE_STRING, GetName()) ||
           arg.is(L"sequenceName", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetSequenceName(arg.getNormalizedString());
  }
  else if (arg.is(L"blockSize", OPERATOR_ARG_TYPE_INTEGER, GetName()))
  {
    SetBlockSize(arg.getIntValue());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeIdGenerator* DesignTimeIdGenerator::clone(
                                                    const std::wstring& name,
                                                    std::vector<OperatorArg *>& args, 
                                                    int nInputs, int nOutputs) const
{
  DesignTimeIdGenerator* result = new DesignTimeIdGenerator();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeIdGenerator::type_check()
{
  // TODO: Validate that we have a valid id.

  // TODO:  Validate no name collision with the output field.
  
  // Check for existence of the sequence in the database.  From this infer
  // the data type of the id (INT or BIGINT).
  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcPreparedArrayStatement> stmt(conn->PrepareStatement("SELECT id_current FROM t_current_id WHERE nm_current=?"));
  stmt->SetWideString(1, mSequenceName);
  stmt->AddBatch();
  boost::shared_ptr<COdbcPreparedResultSet> rs(stmt->ExecuteQuery());
  if (!rs->Next())
  {
    rs = boost::shared_ptr<COdbcPreparedResultSet>();
    stmt =  boost::shared_ptr<COdbcPreparedArrayStatement>();
    // Try again to find an int64 sequence.
    stmt =  boost::shared_ptr<COdbcPreparedArrayStatement>(conn->PrepareStatement("SELECT id_current FROM t_current_long_id WHERE nm_current=?"));
    stmt->SetWideString(1, mSequenceName);
    stmt->AddBatch();
    rs = boost::shared_ptr<COdbcPreparedResultSet>(stmt->ExecuteQuery());
    if (!rs->Next())
    {
      std::string msg;
      ::WideStringToUTF8((boost::wformat(L"Could not find id sequence with name %1%") % mSequenceName).str(), msg);
      throw std::logic_error(msg);
    }
    else
    {
      LogicalRecord outputMembers;
      outputMembers.push_back(mIdName, 
                              LogicalFieldType::BigInteger(true));
      mOutputMetadata = new RecordMetadata(outputMembers);
      mMerger = new RecordMerge(mInputPorts[0]->GetMetadata(), mOutputMetadata);
    }
  }
  else
  {
    LogicalRecord outputMembers;
    outputMembers.push_back(mIdName, 
                            LogicalFieldType::Integer(true));
    mOutputMetadata = new RecordMetadata(outputMembers);
    mMerger = new RecordMerge(mInputPorts[0]->GetMetadata(), mOutputMetadata);
  }

  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mMerger->GetRecordMetadata()));
}

RunTimeOperator * DesignTimeIdGenerator::code_generate(partition_t maxPartition)
{
  return new RunTimeIdGenerator(mName, 
                                *mInputPorts[0]->GetMetadata(),
                                *mOutputMetadata,
                                *mMerger,
                                mIdName,
                                mSequenceName,
                                mBlockSize);
}
  
void DesignTimeIdGenerator::SetIdName(const std::wstring& idName)
{
  mIdName = idName;
}

void DesignTimeIdGenerator::SetSequenceName(const std::wstring& sequenceName)
{
  mSequenceName = sequenceName;
}

void DesignTimeIdGenerator::SetBlockSize(boost::int32_t blockSize)
{
  mBlockSize = blockSize;
}

RunTimeIdGenerator::RunTimeIdGenerator()
  :
  mBlockSize(0)
{
}

RunTimeIdGenerator::RunTimeIdGenerator(const std::wstring& name, 
                                       const RecordMetadata& inputMetadata,
                                       const RecordMetadata& outputMetadata,
                                       const RecordMerge& merge,
                                       const std::wstring& idName,
                                       const std::wstring& sequenceName,
                                       boost::int32_t blockSize)
  :
  RunTimeOperator(name),
  mInputMetadata(inputMetadata),
  mOutputMetadata(outputMetadata),
  mMerger(merge),
  mIdName(idName),
  mSequenceName(sequenceName),
  mBlockSize(blockSize)
{
}

RunTimeIdGenerator::~RunTimeIdGenerator()
{
}

RunTimeOperatorActivation * RunTimeIdGenerator::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeIdGeneratorActivation(reactor, partition, this);
}

RunTimeIdGeneratorActivation::RunTimeIdGeneratorActivation(Reactor * reactor, 
                                                           partition_t partition, 
                                                           const RunTimeIdGenerator * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeIdGenerator>(reactor, partition, runTimeOperator),
  mIdAccessor(NULL),
  mState(READ_0),
  mInputMessage(NULL),
  mOutputMessage(NULL),
  mOutputBuffer(NULL),
  mBlockIt(0LL),
  mBlockEnd(0LL)
{
}

RunTimeIdGeneratorActivation::~RunTimeIdGeneratorActivation()
{
}

void RunTimeIdGeneratorActivation::Start()
{
  // Get the accessor from the output
  mIdAccessor = mOperator->mMerger.GetRecordMetadata()->GetColumn(mOperator->mIdName);
  // Set up a buffer to merge outputs from (just NULL by default)
  mOutputBuffer = mOperator->mOutputMetadata.Allocate();
  // Start pumping
  RequestRead(0);
  mState = READ_0;
}

void RunTimeIdGeneratorActivation::HandleEvent(Endpoint * ep)
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
      
      if (mBlockIt == mBlockEnd)
      {
        boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
        conn->SetAutoCommit(false);
        if (mIdAccessor->GetPhysicalFieldType()->GetPipelineType() == MTPipelineLib::PROP_TYPE_INTEGER)
        {
          boost::shared_ptr<COdbcPreparedArrayStatement> stmt(conn->PrepareStatement("SELECT id_current FROM t_current_id WITH(UPDLOCK) WHERE nm_current=?"));
          stmt->SetWideString(1, mOperator->mSequenceName);
          stmt->AddBatch();
          boost::shared_ptr<COdbcPreparedResultSet> rs(stmt->ExecuteQuery());
          rs->Next();
          mBlockIt = rs->GetInteger(1);
          mBlockEnd = mBlockIt + mOperator->mBlockSize;
          rs = boost::shared_ptr<COdbcPreparedResultSet>();
          stmt = boost::shared_ptr<COdbcPreparedArrayStatement>(conn->PrepareStatement((boost::format("UPDATE t_current_id SET id_current=id_current+%1% WHERE nm_current=?") % mOperator->mBlockSize).str()));
          stmt->SetWideString(1, mOperator->mSequenceName);
          stmt->AddBatch();
          stmt->ExecuteBatch();
        }
        else if (mIdAccessor->GetPhysicalFieldType()->GetPipelineType() == MTPipelineLib::PROP_TYPE_BIGINTEGER)
        {
          boost::shared_ptr<COdbcPreparedArrayStatement> stmt(conn->PrepareStatement("SELECT id_current FROM t_current_long_id WITH(UPDLOCK) WHERE nm_current=?"));
          stmt->SetWideString(1, mOperator->mSequenceName);
          stmt->AddBatch();
          boost::shared_ptr<COdbcPreparedResultSet> rs(stmt->ExecuteQuery());
          rs->Next();
          mBlockIt = rs->GetBigInteger(1);
          mBlockEnd = mBlockIt + mOperator->mBlockSize;
          rs = boost::shared_ptr<COdbcPreparedResultSet>();
          stmt = boost::shared_ptr<COdbcPreparedArrayStatement>(conn->PrepareStatement((boost::format("UPDATE t_current_long_id SET id_current=id_current+%1% WHERE nm_current=?") % mOperator->mBlockSize).str()));
          stmt->SetWideString(1, mOperator->mSequenceName);
          stmt->AddBatch();
          stmt->ExecuteBatch();
        }
        conn->CommitTransaction();
      }
      
      if (mIdAccessor->GetPhysicalFieldType()->GetPipelineType() == MTPipelineLib::PROP_TYPE_INTEGER)
      {
        mIdAccessor->SetLongValue(mOutputMessage, (boost::int32_t) mBlockIt++);
      }
      else if (mIdAccessor->GetPhysicalFieldType()->GetPipelineType() == MTPipelineLib::PROP_TYPE_BIGINTEGER)
      { 
        mIdAccessor->SetBigIntegerValue(mOutputMessage, mBlockIt++);
      }      

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
