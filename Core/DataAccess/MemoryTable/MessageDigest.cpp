#include "MessageDigest.h"
#include "OperatorArg.h"
#include "global.h"
#include "mtmd5.h"
#include "MTUtil.h"
#include <boost/format.hpp>

DesignTimeMD5Hash::DesignTimeMD5Hash()
{
  mInputPorts.push_back(this, L"input", false);
  mOutputPorts.push_back(this, L"output", false);
}

DesignTimeMD5Hash::~DesignTimeMD5Hash()
{
}

void DesignTimeMD5Hash::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddHashKey(arg.getNormalizedString());
  }
  else if (arg.is(L"output", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetOutputKey(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeMD5Hash* DesignTimeMD5Hash::clone(
                                        const std::wstring& name,
                                        std::vector<OperatorArg *>& args, 
                                        int nInputs, int nOutputs) const
{
  DesignTimeMD5Hash* result = new DesignTimeMD5Hash();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeMD5Hash::AddHashKey(const std::wstring& hashKey)
{
  mHashKeys.push_back(hashKey);
}

void DesignTimeMD5Hash::SetOutputKey(const std::wstring& outputKey)
{
  mOutputKey = outputKey;
}

void DesignTimeMD5Hash::type_check()
{  
  for(std::size_t j=0; j<mHashKeys.size(); j++)
  {
    if (!mInputPorts[0]->GetMetadata()->HasColumn(mHashKeys[j])) 
    {
      throw MissingFieldException(*this, *mInputPorts[0], mHashKeys[j]);
    }
  }

  if (mInputPorts[0]->GetMetadata()->HasColumn(mOutputKey)) 
  {
    throw FieldAlreadyExistsException(*this, *mInputPorts[0], mHashKeys[j]);
  }
  

  LogicalRecord hashFieldMembers;
  hashFieldMembers.push_back(RecordMember(mOutputKey, LogicalFieldType::Binary(false)));
  RecordMetadata hashField(hashFieldMembers);

  RecordMerge merge(mInputPorts[0]->GetMetadata(), &hashField);
  mOutputPorts[0]->SetMetadata(new RecordMetadata(*merge.GetRecordMetadata()));
}

RunTimeOperator * DesignTimeMD5Hash::code_generate(partition_t maxPartition)
{
  return new RunTimeMD5Hash(*mInputPorts[0]->GetMetadata(), 
                            *mOutputPorts[0]->GetMetadata(),
                            mHashKeys,
                            mOutputKey);
}


RunTimeMD5Hash::RunTimeMD5Hash()
{
}
  
RunTimeMD5Hash::RunTimeMD5Hash (const RecordMetadata& inputMetadata,
                                const RecordMetadata& outputMetadata,
                                const std::vector<std::wstring>& hashKeys,
                                const std::wstring& outputName)
  :
  mInputMetadata(inputMetadata),
  mOutputMetadata(outputMetadata),
  mProjection(inputMetadata, outputMetadata),
  mOutputKey(NULL)
{
  for(std::vector<std::wstring>::const_iterator it = hashKeys.begin();
      it != hashKeys.end();
      ++it)
  {
    mHashKeys.push_back(mInputMetadata.GetColumn(*it));
  }
  mOutputKey = mOutputMetadata.GetColumn(outputName);
}

RunTimeMD5Hash::~RunTimeMD5Hash()
{
}

RunTimeOperatorActivation * RunTimeMD5Hash::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeMD5HashActivation(reactor, partition, this);
}
 

RunTimeMD5HashActivation::RunTimeMD5HashActivation(Reactor * reactor, 
                                                   partition_t partition, 
                                                   RunTimeMD5Hash * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeMD5Hash>(reactor, partition, runTimeOperator),
  mState(START),
  mBuffer(NULL)
{
}

RunTimeMD5HashActivation::~RunTimeMD5HashActivation()
{
  if (mBuffer)
    mOperator->mOutputMetadata.Free(mBuffer);
}

void RunTimeMD5HashActivation::Start()
{
  mState = START;
  HandleEvent(NULL);
}

void RunTimeMD5HashActivation::HandleEvent(Endpoint * ep)
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
    {
      MessagePtr inputMessage;
      Read(inputMessage, ep);
      if (false == mOperator->mInputMetadata.IsEOF(inputMessage))
      {
        MT_MD5_CTX ctx;
        ::MT_MD5_Init(&ctx);
        for(std::vector<RunTimeDataAccessor*>::const_iterator it = mOperator->mHashKeys.begin();
            it != mOperator->mHashKeys.end();
            ++it)
        {
          if(!(*it)->GetNull(inputMessage))
          {
            static boost::uint8_t flag(0x01);
            ::MT_MD5_Update(&ctx, &flag, sizeof(boost::uint8_t));
            boost::uint8_t * bufferStart = (boost::uint8_t*) ((*it)->GetValue(inputMessage));
            boost::uint8_t * bufferEnd = (boost::uint8_t*) ((*it)->GetBufferEnd(inputMessage));
            ::MT_MD5_Update(&ctx, bufferStart, bufferEnd-bufferStart);
          }
          else
          {
            static boost::uint8_t flag(0xff);
            ::MT_MD5_Update(&ctx, &flag, sizeof(boost::uint8_t));
          }
        }
        boost::uint8_t tmp[16];
        ::MT_MD5_Final(&tmp[0], &ctx);
        mBuffer = mOperator->mOutputMetadata.Allocate();
        mOperator->mProjection.Project(inputMessage, mBuffer, true);
        mOperator->mOutputKey->SetValue(mBuffer, tmp);        
        mOperator->mInputMetadata.Free(inputMessage);
        inputMessage = NULL;
        RequestWrite(0);
        mState = WRITE_0;
        return;
      case WRITE_0:
        Write(mBuffer, ep);
        mBuffer = NULL;
      }
      else
      {
        RequestWrite(0);
        mState = WRITE_EOF_0;
        return;
      case WRITE_EOF_0:
        Write(mOperator->mOutputMetadata.AllocateEOF(), ep, true);
        return;
      }
    }
    }
  }
}

