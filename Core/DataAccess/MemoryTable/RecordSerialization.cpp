#include "RecordSerialization.h"
#include <boost/format.hpp>
#include <xmmintrin.h>

static const boost::int32_t SERIALIZATION_INPUT_EXHAUSTED(-1);
static const boost::int32_t SERIALIZATION_OK(0);

// // Super has mProgramCounter
// template <int N, class Super>
// class Memcpy : public Super
// {
// private:
//   boost::uint8_t * mBufferIt;
//   boost::uint8_t * mTargetIt;
//   boost::int32_t mMemcpyLength;
  
// public:
  
//   void Init(boost::uint8_t * memcpyTarget, boost::int32_t memcpyLength)
//   {
//     mTargetIt = memcpyTarget;
//     mMemcpyLength = memcpyLength;
//     mProgramCounter = MEMCPY_START;
//   }

//   boost::uint8_t * operator(boost::uint8_t * bufferBegin, boost::uint8_t * bufferEnd)
//   {
//     switch(mProgramCounter & StateMask)
//     {
//     case MEMCPY_START:
//       mBufferIt = bufferBegin;
//       {
//         std::ptrdiff_t to_copy = 
//           mBufferIt + mMemcpyLength < bufferEnd ? 
//           mMemcpyLength : 
//           (bufferEnd - mBufferIt);
//         memcpy(mMemcpyIt, mBufferIt, to_copy);
//         mMemcpyLength -= to_copy;
//         mMemcpyIt += to_copy;
//         mBufferIt += to_copy;
//       }

//       while(mMemcpyLength > 0)
//       {
//         BOOST_ASSERT(mBufferIt == bufferEnd);
//         // Set the part of the state that belongs to us
//         mProgramCounter = SERIALIZE_INPUT_EXHAUSTED;
//         return NULL;
//       case MEMCPY_INPUT_EXHAUSTED:
//         // We have a new buffer, so reset buffer iterator and resume
//         // processing.
//         mBufferIt = bufferBegin;
//         {
//           std::ptrdiff_t to_copy = 
//             mBufferIt + mMemcpyLength < bufferEnd ? 
//             mMemcpyLength : 
//             (bufferEnd - mBufferIt);
//           memcpy(mMemcpyTarget, mBufferIt, to_copy);

//           mMemcpyLength -= to_copy;
//           mMemcpyTarget += to_copy;
//           mBufferIt += to_copy;
//         }
//       }
//       return mBufferIt;
//     }
//   }
// };

RawBufferDearchive::RawBufferDearchive(const RawBufferDearchive& rhs)
  :
  mNumRecords(0),
  mBufferIt(NULL),
  mBufferEnd(NULL),
  mDeserializer(rhs.mDeserializer),
  mIsClosed(rhs.mIsClosed)
{
}
RawBufferDearchive::RawBufferDearchive(const RecordMetadata& metadata)
  :
  mNumRecords(0),
  mBufferIt(NULL),
  mBufferEnd(NULL),
  mDeserializer(metadata),
  mIsClosed(false)
{
}
RawBufferDearchive::~RawBufferDearchive()
{
}
void RawBufferDearchive::Bind(const boost::uint8_t * start, const boost::uint8_t * end)
{
  if ((end > 128*1024+start) || (end < start + sizeof(MessageHeader)))
  {
    throw std::runtime_error((boost::format("Invalid buffer in RawBufferDearchive::Bind.  end-start=%1%") % (end-start)).str());
  }
  if (mIsClosed)
  {
    throw std::runtime_error("Multiple closed messages");
  }
  mNumRecords = reinterpret_cast<const MessageHeader *>(start)->RecordCount;
  mIsClosed = reinterpret_cast<const MessageHeader *>(start)->Closed != 0;
  mBufferIt = start + sizeof(MessageHeader);
  mBufferEnd = end;
}
// Returns:
// Byte after last consumed input.
const boost::uint8_t * RawBufferDearchive::Unbind()
{
  return mBufferIt;
}

// Returns:
// RawBufferDearchive::OK
// RawBufferDearchive::INPUT_EXHAUSTED
//
boost::int32_t RawBufferDearchive::Deserialize(MessagePtr & m)
{
  return mDeserializer.Deserialize(mBufferIt, mBufferEnd, m);
}

// Returns:
// Number of records field from the header of the bound bufer.
boost::int32_t RawBufferDearchive::GetNumRecords() const
{
  return mNumRecords;
}

RawBufferArchive::RawBufferArchive(const RecordMetadata& metadata)
  :
  mStart(NULL),
  mMessageRecords(0),
  mBufferIt(NULL),
  mBufferEnd(NULL),
  mSerializer(metadata),
  mIsClosed(false)
{
}

RawBufferArchive::RawBufferArchive(const RawBufferArchive& rhs)
  :
  mStart(NULL),
  mMessageRecords(rhs.mMessageRecords),
  mBufferIt(NULL),
  mBufferEnd(NULL),
  mSerializer(rhs.mSerializer),
  mIsClosed(rhs.mIsClosed)
{
  if (rhs.mStart != NULL)
    throw std::runtime_error ("Cannot copy construct RawBufferArchive in a bound state");

}

RawBufferArchive::~RawBufferArchive()
{
}

void RawBufferArchive::Bind(boost::uint8_t * start, boost::uint8_t * end)
{
  mStart = start;
  mBufferIt = start + sizeof(MessageHeader);
  mBufferEnd = end;
  mMessageRecords = 0;
}

boost::uint8_t * RawBufferArchive::Unbind()
{
  ((MessageHeader *) mStart)->RecordCount = mMessageRecords;
  ((MessageHeader *) mStart)->Closed = mIsClosed ? 1 : 0;
  mStart = NULL;
  return mBufferIt;
}
  
boost::uint8_t * RawBufferArchive::Serialize(MessagePtr m, bool isEOF)
{
  ASSERT(!mIsClosed);
  boost::uint8_t * nbuf = mSerializer.Serialize(m, mBufferIt, mBufferEnd);
  if (nbuf != NULL)
  {
    mMessageRecords += 1;
    mIsClosed = isEOF;
  }
  return nbuf;
}

bool RawBufferArchive::CanPush() const
{
  // TODO: Any room in here?
  return true;
}

RawRecordSerializer::RawRecordSerializer()
  :
  mMinSize(0),
  mProgramCounter(PC_NEW_RECORD),
  mSourceIncrement(0),
  mOperationBegin(NULL),
  mOperationEnd(NULL),
  mOperationIt(NULL)
{
  mOperationBegin = mOperationEnd = &mOperationBuffer[0];
}

RawRecordSerializer::RawRecordSerializer(const RawRecordSerializer& rhs)
  :
  mPrefetch(rhs.mPrefetch),
  mInstructions(rhs.mInstructions),
  mMinSize(rhs.mMinSize),
  mProgramCounter(PC_NEW_RECORD),
  mSourceIncrement(0),
  mOperationBegin(NULL),
  mOperationEnd(NULL),
  mOperationIt(NULL)
{
  mOperationBegin = mOperationEnd = &mOperationBuffer[0];
}

RawRecordSerializer::RawRecordSerializer(const RecordMetadata& metadata)
  :
  mMinSize(0),
  mProgramCounter(PC_NEW_RECORD),
  mSourceIncrement(0),
  mOperationBegin(NULL),
  mOperationEnd(NULL),
  mOperationIt(NULL)
{
  mOperationBegin = mOperationEnd = &mOperationBuffer[0];

  Generate(metadata);

  // Precalculate the minimum required buffer size.
  for(std::vector<RecordSerializerInstruction>::iterator it = mInstructions.begin();
      it != mInstructions.end();
      it++)
  {
    mMinSize += it->GetMinimumSize();
  }  
}

void RawRecordSerializer::Generate(const RecordMetadata& metadata)
{
  std::vector<RunTimeDataAccessor*> physicalOrder;
  for(boost::int32_t i=0;i<metadata.GetNumColumns();i++)
  {
    physicalOrder.push_back(metadata.GetColumn(i));
  }  
  std::sort(physicalOrder.begin(), physicalOrder.end(), FieldAddressOffsetOrder());

  mInstructions.push_back(RecordSerializerInstruction::DirectMemcpy(metadata.GetDataOffset()));
  for(boost::int32_t i=0; i < (boost::int32_t) physicalOrder.size();i++)
  {
    if (physicalOrder[i]->GetPhysicalFieldType()->GetPipelineType() == MTPipelineLib::PROP_TYPE_SET &&
        physicalOrder[i]->GetPhysicalFieldType()->IsList())
    {
      std::size_t label = mInstructions.size();
      mInstructions.push_back(RecordSerializerInstruction());
      mInstructions.push_back(RecordSerializerInstruction::NestedRecordNext());
      Generate(*physicalOrder[i]->GetPhysicalFieldType()->GetMetadata());
      mInstructions.push_back(RecordSerializerInstruction::NestedRecordEnd(mInstructions.size() - label - 1));
      mInstructions[label] = RecordSerializerInstruction::NestedRecordStart(mInstructions.size() - label, physicalOrder[i]);
    }
    else
    {
      RecordSerializerInstruction rsi = physicalOrder[i]->GetRecordSerializerInstruction();
      if (rsi.Ty == RecordSerializerInstruction::DIRECT_MEMCPY &&
          mInstructions.back().Ty == RecordSerializerInstruction::DIRECT_MEMCPY)
      {
        // Merge adjacent memcpy's into a single instruction for efficiency.
        mInstructions.back().Len += rsi.Len;
      }
      else
      {
        mInstructions.push_back(rsi);
      }
      if (rsi.Ty == RecordSerializerInstruction::INDIRECT_WCSCPY)
      {
        mPrefetch.push_back(*rsi.Accessor);
      }
    }
  }

}

// I should be shot for this monstrosity.
// Obviously, I don't know how to write a coherent efficient state machine/iterator.
boost::uint8_t* RawRecordSerializer::Serialize(const_record_t recordBuffer, boost::uint8_t *& bufferBegin, boost::uint8_t * bufferEnd)
{
  switch(mProgramCounter)
  {
    while(true)
    {
      mProgramCounter = PC_NEW_RECORD;
      return bufferBegin;
    case PC_NEW_RECORD:
    {
      ASSERT(mSource.size() == 0);
      mSource.push(std::make_pair(recordBuffer, recordBuffer));
      {
        for(std::vector<FieldAddress>::const_iterator prefetchIt = mPrefetch.begin();
            prefetchIt != mPrefetch.end();
            ++prefetchIt)
        {
          if (!prefetchIt->GetNull(recordBuffer))
          {
            _mm_prefetch((const char *)prefetchIt->GetIndirectBuffer(recordBuffer), _MM_HINT_NTA);
          }
        }
      }
      for(mIt = mInstructions.begin();
          mIt != mInstructions.end();
          mIt++)
      {
        if (mIt->Ty==RecordSerializerInstruction::DIRECT_MEMCPY)
        {
          mOperationBegin[0].BufferLength = mIt->Len;
          mOperationBegin[0].Buffer = mSource.top().second;
          mOperationEnd = mOperationBegin + 1;
          mSourceIncrement = mIt->Len;
        }
        else if(mIt->Ty==RecordSerializerInstruction::INDIRECT_MEMCPY)
        {
          if (!mIt->Accessor->GetNull(mSource.top().first))
          {
            mOperationBegin[0].BufferLength = sizeof(boost::int32_t);
            mOperationBegin[0].Buffer = reinterpret_cast<const boost::uint8_t *>(&mOperationBegin[1].BufferLength);
            mOperationBegin[1].BufferLength = mIt->Len;
            mOperationBegin[1].Buffer = *((boost::uint8_t **)mSource.top().second);
            mOperationEnd = mOperationBegin + 2;
          }
          mSourceIncrement = sizeof(void*);
        }
        else if (mIt->Ty==RecordSerializerInstruction::INDIRECT_STRCPY)
        {
          if (!mIt->Accessor->GetNull(mSource.top().first))
          {
            mOperationBegin[0].BufferLength = sizeof(boost::int32_t);
            mOperationBegin[0].Buffer = reinterpret_cast<const boost::uint8_t *>(&mOperationBegin[1].BufferLength);
            const char * str = *((const char **) mSource.top().second);
            mOperationBegin[1].BufferLength = strlen(str) + 1;
            mOperationBegin[1].Buffer = reinterpret_cast<const boost::uint8_t *>(str);
            mOperationEnd = mOperationBegin + 2;
          }
          mSourceIncrement = sizeof(void*);
        }
        else if(mIt->Ty==RecordSerializerInstruction::INDIRECT_WCSCPY)
        {
          if (!mIt->Accessor->GetNull(mSource.top().first))
          {
            mOperationBegin[0].BufferLength = sizeof(boost::int32_t);
            mOperationBegin[0].Buffer = reinterpret_cast<const boost::uint8_t *>(&mOperationBegin[1].BufferLength);
//             const wchar_t * str = *((const wchar_t **) mSource.top().second);
//             mOperationBegin[1].BufferLength = (wcslen(str) + 1) * sizeof(wchar_t);
//             mOperationBegin[1].Buffer = reinterpret_cast<const boost::uint8_t *>(str);
            const PrefixedWideString * prefixed = ((const PrefixedWideString *) mSource.top().second);
            mOperationBegin[1].BufferLength = prefixed->Length;
            mOperationBegin[1].Buffer = reinterpret_cast<const boost::uint8_t *>(prefixed->String);
            mOperationEnd = mOperationBegin + 2;
          }
//           mSourceIncrement = sizeof(void*);
          mSourceIncrement = mIt->Accessor->GetPhysicalFieldType()->GetColumnStorage();
        }
        else if(mIt->Ty==RecordSerializerInstruction::NESTED_RECORD_START)
        {
          if (!mIt->Accessor->GetNull(mSource.top().first))
          {
            // Get iterator over nested records set up
            const_record_t end = mIt->Accessor->GetRecordValue(mSource.top().first);
            ASSERT(end != NULL);
            end = RecordMetadata::GetNext((record_t) end);
            mIteration.push(std::make_pair(end,end));
          }
          else
          {
            mIt += mIt->Len;
          }
          mSourceIncrement = sizeof(void*);
        }
        else if(mIt->Ty==RecordSerializerInstruction::NESTED_RECORD_NEXT)
        {
          // Write out a marker
          if (bufferBegin == bufferEnd)
          {
            mProgramCounter = PC_SERIALIZE_NULL_MARKER;
            return NULL;
          case PC_SERIALIZE_NOT_NULL_MARKER:;
          }
          *bufferBegin++ = 0x00;
          mSource.push(std::make_pair(mIteration.top().second,mIteration.top().second));
          mSourceIncrement = 0;
        }
        else if(mIt->Ty==RecordSerializerInstruction::NESTED_RECORD_END)
        {
          mSource.pop();
          mIteration.top().second = RecordMetadata::GetNext((record_t) mIteration.top().second);
          if (mIteration.top().second != mIteration.top().first)
          {
            // go back to top of loop
            mIt -= mIt->Len;
          }
          else
          {
            // Gotta write out a null marker for the end of collection
            mIteration.pop();
            if (bufferBegin == bufferEnd)
            {
              mProgramCounter = PC_SERIALIZE_NULL_MARKER;
              return NULL;
            case PC_SERIALIZE_NULL_MARKER:;
            }
            *bufferBegin++ = 0x01;
          }
          mSourceIncrement = 0;
        }

        // We have some number of memcpys to perform; do them
        // while supporting yield on buffer exhaustion.
        for(mOperationIt = mOperationBegin;
            mOperationIt != mOperationEnd;
            ++mOperationIt)
        {
          {
            std::ptrdiff_t to_copy = 
              bufferBegin + mOperationIt->BufferLength < bufferEnd ? 
              mOperationIt->BufferLength : 
              (bufferEnd - bufferBegin);
            memcpy(bufferBegin, mOperationIt->Buffer, to_copy);
            mOperationIt->BufferLength -= to_copy;
            mOperationIt->Buffer += to_copy;
            bufferBegin += to_copy;
          }

          while(mOperationIt->BufferLength > 0)
          {
            BOOST_ASSERT(bufferBegin == bufferEnd);
            mProgramCounter = PC_SERIALIZE_OUTPUT_EXHAUSTED;
            return NULL;
          case PC_SERIALIZE_OUTPUT_EXHAUSTED:
            // We have a new buffer, so reset buffer iterator and resume
            // processing.
            {
              std::ptrdiff_t to_copy = 
                bufferBegin + mOperationIt->BufferLength < bufferEnd ? 
                mOperationIt->BufferLength : 
                (bufferEnd - bufferBegin);
              memcpy(bufferBegin, mOperationIt->Buffer, to_copy);
              mOperationIt->BufferLength -= to_copy;
              mOperationIt->Buffer += to_copy;
              bufferBegin += to_copy;
            }
          }
        }
        // Consume the source
        mSource.top().second += mSourceIncrement;
        // Clear the requested operations
        mOperationEnd = mOperationBegin;
      }

      mSource.pop();
    }
    }
  }
  return bufferBegin;
}

RawRecordDeserializer::RawRecordDeserializer()
  :
  mTemp(NULL),
  mTempSize(0),
  mProgramCounter(PC_NEW_RECORD),
  mIndirectBufferSize(0)
{
}

RawRecordDeserializer::RawRecordDeserializer(const RawRecordDeserializer& rhs)
  :
  mInstructions(rhs.mInstructions),
  mTemp(NULL),
  mTempSize(0),
  mProgramCounter(PC_NEW_RECORD),
  mIndirectBufferSize(0)
{
}

RawRecordDeserializer::RawRecordDeserializer(const RecordMetadata & metadata)
  :
  mTemp(NULL),
  mTempSize(0),
  mProgramCounter(PC_NEW_RECORD),
  mIndirectBufferSize(0)
{
  Generate(metadata);
}

RawRecordDeserializer::~RawRecordDeserializer()
{
  delete [] mTemp;
}

void RawRecordDeserializer::Generate(const RecordMetadata& metadata)
{
  std::vector<RunTimeDataAccessor*> physicalOrder;
  for(boost::int32_t i=0;i<metadata.GetNumColumns();i++)
  {
    physicalOrder.push_back(metadata.GetColumn(i));
  }  
  std::sort(physicalOrder.begin(), physicalOrder.end(), FieldAddressOffsetOrder());

  mInstructions.push_back(RecordDeserializerInstruction::DirectMemcpy(metadata.GetDataOffset()));
  for(boost::int32_t i=0;i<metadata.GetNumColumns();i++)
  {
    // TODO: The deserializer factory patterns that exist right now are insufficient to handle
    // nested collections.  Seems like a job for the vistor pattern.
    if (physicalOrder[i]->GetPhysicalFieldType()->GetPipelineType() == MTPipelineLib::PROP_TYPE_SET &&
        physicalOrder[i]->GetPhysicalFieldType()->IsList())
    {
      // The nested record is really a for loop.  There is a branching instruction implicit in
      // the start and an implict goto in the end instruction.  We don't know the branch target until
      // after the instructions for child record are generated. So we put a dummy instruction in and then
      // go back to fix up
      std::size_t label = mInstructions.size();
      mInstructions.push_back(RecordDeserializerInstruction());
      Generate(*physicalOrder[i]->GetPhysicalFieldType()->GetMetadata());
      mInstructions.push_back(RecordDeserializerInstruction::NestedRecordEnd(mInstructions.size()-label+1, physicalOrder[i]));
      mInstructions[label] = RecordDeserializerInstruction::NestedRecordStart(mInstructions.size()-label-1, physicalOrder[i]);
    }
    else
    {
      RecordDeserializerInstruction rsi = physicalOrder[i]->GetRecordDeserializerInstruction();
      if (rsi.Ty == RecordDeserializerInstruction::DIRECT_MEMCPY &&
          mInstructions.back().Ty == RecordDeserializerInstruction::DIRECT_MEMCPY)
      {
        // Merge adjacent memcpy's into a single instruction for efficiency.
        mInstructions.back().Len += rsi.Len;
      }
      else
      {
        mInstructions.push_back(rsi);
      }
    }
  }
}

int RawRecordDeserializer::Deserialize(const boost::uint8_t *& bufferBegin, const boost::uint8_t * bufferEnd, record_t recordBuffer)
{
  switch(mProgramCounter)
  {
    while(true)
    {
      mProgramCounter = PC_NEW_RECORD;
      return SERIALIZATION_OK;
    case PC_NEW_RECORD:

      ASSERT(mTarget.size() == 0);
      mTarget.push(std::make_pair(recordBuffer, recordBuffer));

      for(mIt = mInstructions.begin();
          mIt != mInstructions.end();
          mIt++)
      {
        if(mIt->Ty == RecordDeserializerInstruction::DIRECT_MEMCPY)
        {
          mMemcpyTarget = mTarget.top().second;
          mMemcpyLength = mIt->Len;
          {
            std::ptrdiff_t to_copy = 
              bufferBegin + mMemcpyLength < bufferEnd ? 
              mMemcpyLength : 
              (bufferEnd - bufferBegin);
            memcpy(mMemcpyTarget, bufferBegin, to_copy);
            // TODO: account for work done.
            mMemcpyLength -= to_copy;
            mMemcpyTarget += to_copy;
            bufferBegin += to_copy;
          }

          while(mMemcpyLength > 0)
          {
            BOOST_ASSERT(bufferBegin == bufferEnd);
            mProgramCounter = PC_DIRECT_MEMCPY;
            return SERIALIZATION_INPUT_EXHAUSTED;
          case PC_DIRECT_MEMCPY:
            // We have a new buffer, so reset buffer iterator and resume
            // processing.
            {
              std::ptrdiff_t to_copy = 
                bufferBegin + mMemcpyLength < bufferEnd ? 
                mMemcpyLength : 
                (bufferEnd - bufferBegin);
              memcpy(mMemcpyTarget, bufferBegin, to_copy);

              mMemcpyLength -= to_copy;
              mMemcpyTarget += to_copy;
              bufferBegin += to_copy;
            }
          }
          // Consume target buffer
          mTarget.top().second += mIt->Len;
        }
        else if (mIt->Ty==RecordDeserializerInstruction::ACCESSOR)
        {
          if (!mIt->Accessor->GetNull(mTarget.top().first))
          {
            // Grab the 4 byte size.
            mMemcpyTarget = reinterpret_cast<boost::uint8_t *>(&mIndirectBufferSize);
            mMemcpyLength = sizeof(mIndirectBufferSize);
            {
              std::ptrdiff_t to_copy = 
                bufferBegin + mMemcpyLength < bufferEnd ? 
                mMemcpyLength : 
                (bufferEnd - bufferBegin);
              memcpy(mMemcpyTarget, bufferBegin, to_copy);
              // TODO: account for work done.
              mMemcpyLength -= to_copy;
              mMemcpyTarget += to_copy;
              bufferBegin += to_copy;
            }

            while(mMemcpyLength > 0)
            {
              BOOST_ASSERT(bufferBegin == bufferEnd);
              mProgramCounter = PC_INDIRECT_MEMCPY_LENGTH;
              return SERIALIZATION_INPUT_EXHAUSTED;
            case PC_INDIRECT_MEMCPY_LENGTH:
              // We have a new buffer, so reset buffer iterator and resume
              // processing.
              {
                std::ptrdiff_t to_copy = 
                  bufferBegin + mMemcpyLength < bufferEnd ? 
                  mMemcpyLength : 
                  (bufferEnd - bufferBegin);
                memcpy(mMemcpyTarget, bufferBegin, to_copy);

                mMemcpyLength -= to_copy;
                mMemcpyTarget += to_copy;
                bufferBegin += to_copy;
              }
            }
            // TODO: Fix this temporary hack.  What we are doing is
            // prevent an attempt to free a bogus ptr vaue that is in the
            // uninitialized record buffer from being freed.  The null flag
            // will be recleared by the SetValue call below.
            mIt->Accessor->SetNull(mTarget.top().first);
            // Special case handling of the common case when we have the field in 
            // a contiguous buffer because we eliminate a copy.
            if (mIndirectBufferSize + bufferBegin < bufferEnd)
            {
              mIt->Accessor->SetValue(mTarget.top().first, bufferBegin);
              bufferBegin += mIndirectBufferSize;
            }
            else
            {
              if (mTempSize < mIndirectBufferSize)
              {
                delete [] mTemp;
                mTemp = new boost::uint8_t [mIndirectBufferSize];
                mTempSize = mIndirectBufferSize;
              }
              mMemcpyTarget = mTemp;
              mMemcpyLength = mIndirectBufferSize;

              {
                std::ptrdiff_t to_copy = 
                  bufferBegin + mMemcpyLength < bufferEnd ? 
                  mMemcpyLength : 
                  (bufferEnd - bufferBegin);
                memcpy(mMemcpyTarget, bufferBegin, to_copy);
                // TODO: account for work done.
                mMemcpyLength -= to_copy;
                mMemcpyTarget += to_copy;
                bufferBegin += to_copy;
              }

              while(mMemcpyLength > 0)
              {
                BOOST_ASSERT(bufferBegin == bufferEnd);
                mProgramCounter = PC_INDIRECT_MEMCPY;
                return SERIALIZATION_INPUT_EXHAUSTED;
              case PC_INDIRECT_MEMCPY:
                // We have a new buffer, so reset buffer iterator and resume
                // processing.
                {
                  std::ptrdiff_t to_copy = 
                    bufferBegin + mMemcpyLength < bufferEnd ? 
                    mMemcpyLength : 
                    (bufferEnd - bufferBegin);
                  memcpy(mMemcpyTarget, bufferBegin, to_copy);

                  mMemcpyLength -= to_copy;
                  mMemcpyTarget += to_copy;
                  bufferBegin += to_copy;
                }
              }
              // memcpy into temporary buffer.
              mIt->Accessor->SetValue(mTarget.top().first, mTemp);
            }
          }

          // Always consume target buffer
          mTarget.top().second += mIt->Accessor->GetPhysicalFieldType()->GetColumnStorage();
        }
        else if (mIt->Ty==RecordDeserializerInstruction::NESTED_RECORD_START)
        {
          // Grab a single byte end of list indicator
          if (bufferBegin == bufferEnd)
          {
            mProgramCounter = NESTED_RECORD_START_NULL_MARKER;
            return SERIALIZATION_INPUT_EXHAUSTED;
          case NESTED_RECORD_START_NULL_MARKER:;
          }
          if (*bufferBegin)
          {
            bufferBegin += 1;
            mIt += mIt->Len;
          }
          else
          {
            bufferBegin += 1;
            record_t tmp = mIt->Accessor->GetPhysicalFieldType()->GetMetadata()->Allocate();
            mTarget.push(std::make_pair(tmp, tmp));
          }
        }
        else if (mIt->Ty==RecordDeserializerInstruction::NESTED_RECORD_END)
        {
          record_t tmp = mTarget.top().first;
          mTarget.pop();
          mIt->Accessor->InternalAppendIndirectRecordValue(mTarget.top().first, tmp);
          mIt -= mIt->Len;
        }
      }

      mTarget.pop();
    }
  }
  return SERIALIZATION_OK;
}

