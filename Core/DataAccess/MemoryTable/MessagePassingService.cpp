#include "MessagePassingService.h"
#include <iostream>
#include <boost/format.hpp>

static const boost::int32_t SERIALIZATION_INPUT_EXHAUSTED(-1);
static const boost::int32_t SERIALIZATION_OK(0);

#define DO_TIMING

#ifdef DO_TIMING
#define TIMER_TICK() \
    __asm { rdtsc }; \
    __asm { mov dword ptr [tick], eax }; \
    __asm { mov dword ptr [tick+4], edx }

#define TIMER_TOCK() \
    __asm { rdtsc }; \
    __asm { mov dword ptr [tock], eax }; \
    __asm { mov dword ptr [tock+4], edx }
#else
#define TIMER_TICK() tick = 0LL
#define TIMER_TOCK() tock = 0LL
#endif

ZLibBufferDearchive::ZLibBufferDearchive(const ZLibBufferDearchive& rhs)
  :
  mNumRecords(0),
  mDeserializer(rhs.mDeserializer)
{
  mCompressedStream.zalloc = (alloc_func)0;
  mCompressedStream.zfree = (free_func)0;
  mCompressedStream.opaque = (voidpf)0;
  mCompressedStream.next_in = NULL;
  mCompressedStream.avail_in = 0;
  mCompressedStream.next_out = NULL;
  mCompressedStream.avail_out = 0;

  int zresult = inflateInit(&mCompressedStream);
  if (zresult != Z_OK)
  {
    throw runtime_error("Failed to initialize decompression");
  }
}
ZLibBufferDearchive::ZLibBufferDearchive(const RecordMetadata& metadata)
  :
  mNumRecords(0),
  mDeserializer(metadata)
{
  mCompressedStream.zalloc = (alloc_func)0;
  mCompressedStream.zfree = (free_func)0;
  mCompressedStream.opaque = (voidpf)0;
  mCompressedStream.next_in = NULL;
  mCompressedStream.avail_in = 0;
  mCompressedStream.next_out = NULL;
  mCompressedStream.avail_out = 0;

  int zresult = inflateInit(&mCompressedStream);
  if (zresult != Z_OK)
  {
    throw runtime_error("Failed to initialize decompression");
  }
}
ZLibBufferDearchive::~ZLibBufferDearchive()
{
  // We really don't expect anything to be available here,
  // so probably no sense in calling Z_FINISH.
  inflate(&mCompressedStream, Z_FINISH);
  inflateEnd(&mCompressedStream);
}
void ZLibBufferDearchive::Bind(boost::uint8_t * start, boost::uint8_t * end)
{
  if ((end >= 128*1024+start) || (end < start + sizeof(boost::int32_t)))
  {
    throw std::runtime_error((boost::format("Invalid buffer in ZLibBufferDearchive::Bind.  end-start=%1%") % (end-start)).str());
  }
  mNumRecords = *((boost::int32_t *)start);  
  mCompressedStream.next_in = start + sizeof(boost::int32_t);
  mCompressedStream.avail_in = end - start - sizeof(boost::int32_t);
}
// Returns:
// Byte after last consumed input.
boost::uint8_t * ZLibBufferDearchive::Unbind()
{
  boost::uint8_t * last = mCompressedStream.next_in;
  return last;
}

// Returns:
// ZLibBufferDearchive::OK
// ZLibBufferDearchive::INPUT_EXHAUSTED
//
boost::int32_t ZLibBufferDearchive::Deserialize(MessagePtr & m)
{
  return mDeserializer.Deserialize(mCompressedStream, m);
}

// Returns:
// Number of records field from the header of the bound bufer.
boost::int32_t ZLibBufferDearchive::GetNumRecords() const
{
  return mNumRecords;
}

ZLibBufferArchive::ZLibBufferArchive(const RecordMetadata& metadata)
  :
  mStart(NULL),
  mMessageRecords(0),
  mSerializer(metadata),
  mCompressorState(false)
{
  mCompressedStream.zalloc = (alloc_func)0;
  mCompressedStream.zfree = (free_func)0;
  mCompressedStream.opaque = (voidpf)0;
  mCompressedStream.next_in = NULL;
  mCompressedStream.avail_in = 0;
  mCompressedStream.next_out = NULL;
  mCompressedStream.avail_out = 0;

  int zresult = deflateInit(&mCompressedStream, Z_BEST_SPEED);
  if (zresult != Z_OK)
  {
    throw runtime_error("Failed to initialize decompression");
  }
}

ZLibBufferArchive::ZLibBufferArchive(const ZLibBufferArchive& rhs)
  :
  mStart(NULL),
  mMessageRecords(rhs.mCompressorState),
  mSerializer(rhs.mSerializer),
  mCompressorState(rhs.mCompressorState)
{
  if (rhs.mStart != NULL)
    throw std::runtime_error ("Cannot copy construct ZLibBufferArchive in a bound state");

  mCompressedStream.zalloc = (alloc_func)0;
  mCompressedStream.zfree = (free_func)0;
  mCompressedStream.opaque = (voidpf)0;
  mCompressedStream.next_in = NULL;
  mCompressedStream.avail_in = 0;
  mCompressedStream.next_out = NULL;
  mCompressedStream.avail_out = 0;

  int zresult = deflateInit(&mCompressedStream, Z_BEST_SPEED);
  if (zresult != Z_OK)
  {
    throw runtime_error("Failed to initialize decompression");
  }
}

ZLibBufferArchive::~ZLibBufferArchive()
{
  deflate(&mCompressedStream, Z_FINISH);
  deflateEnd(&mCompressedStream);
}

void ZLibBufferArchive::Bind(boost::uint8_t * start, boost::uint8_t * end)
{
  mStart = start;
  mCompressedStream.next_out = start + sizeof(boost::int32_t);
  mCompressedStream.avail_out = end - start - sizeof(boost::int32_t);
  mMessageRecords = 0;
}

boost::uint8_t * ZLibBufferArchive::Unbind()
{
  // Flush to the buffer.  This is currently assuming
  // that our output buffers are large enough that we aren't
  // creating a performance issue.  The real reason that I am doing this
  // is that we want to know if there is any internal state in the compressor
  // that is left over.  Reading the documentation in the zlib.h header carefully it seems that
  // any call to deflate might let us know when there is buffering in the
  // state of the compressor by returning avail_out = 0.
  // My experiments indicate that we can only rely on this by trying to flush.
  int result = deflate(&mCompressedStream, Z_SYNC_FLUSH);
  if (result == Z_OK && mCompressedStream.avail_out == 0)
    mCompressorState = true;
  else
    mCompressorState = false;

  // Place number of records at front of buffer (may be zero for partial records).
  *((boost::int32_t *) mStart) = mMessageRecords;
  boost::uint8_t * last = mCompressedStream.next_out;
  mCompressedStream.next_out = NULL;
  mCompressedStream.avail_out = 0;
  return last;
}
  
boost::uint8_t * ZLibBufferArchive::Serialize(MessagePtr m)
{
  boost::uint8_t * nbuf = mSerializer.Serialize(m, mCompressedStream);
  if (nbuf != NULL)
  {
    mMessageRecords += 1;
  }
  return nbuf;
}

bool ZLibBufferArchive::CanPush() const
{
  return !mCompressorState;
}

ZLibRecordSerializer::ZLibRecordSerializer()
  :
  mMinSize(0),
  mAction(ACTION_SERIALIZE_DIRECT),
  mProgramCounter(PC_NEW_RECORD),
  mSource(NULL),
  mIndirectBufferLength(0),
  mIndirectBuffer(NULL),
  mResult(0)
{
}

ZLibRecordSerializer::ZLibRecordSerializer(const ZLibRecordSerializer& rhs)
  :
  mInstructions(rhs.mInstructions),
  mMinSize(rhs.mMinSize),
  mAction(ACTION_SERIALIZE_DIRECT),
  mProgramCounter(PC_NEW_RECORD),
  mSource(NULL),
  mIndirectBufferLength(0),
  mIndirectBuffer(NULL),
  mResult(0)
{
}

ZLibRecordSerializer::ZLibRecordSerializer(const RecordMetadata& metadata)
  :
  mMinSize(0),
  mAction(ACTION_SERIALIZE_DIRECT),
  mProgramCounter(PC_NEW_RECORD),
  mSource(NULL),
  mIndirectBufferLength(0),
  mIndirectBuffer(NULL),
  mResult(0)
{
  std::vector<RunTimeDataAccessor*> physicalOrder;
  for(boost::int32_t i=0;i<metadata.GetNumColumns();i++)
  {
    physicalOrder.push_back(metadata.GetColumn(i));
  }  
  std::sort(physicalOrder.begin(), physicalOrder.end(), FieldAddressOffsetOrder());

  mInstructions.push_back(RecordSerializerInstruction::DirectMemcpy(metadata.GetDataOffset()));
  for(std::size_t i=0;i<physicalOrder.size();i++)
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
  }

  // Precalculate the minimum required buffer size.
  for(std::vector<RecordSerializerInstruction>::iterator it = mInstructions.begin();
      it != mInstructions.end();
      it++)
  {
    mMinSize += it->GetMinimumSize();
  }  
}

// I should be shot for this monstrosity.
// Obviously, I don't know how to write a coherent efficient state machine/iterator.
boost::uint8_t* ZLibRecordSerializer::Serialize(const_record_t recordBuffer, z_stream& compressedStream)
{
  switch(mProgramCounter)
  {
    while(true)
    {
      mProgramCounter = PC_NEW_RECORD;
      return compressedStream.next_out;
    case PC_NEW_RECORD:
    {
      mSource = recordBuffer;

      for(mIt = mInstructions.begin();
          mIt != mInstructions.end();
          mIt++)
      {
        if (mIt->Ty==RecordSerializerInstruction::DIRECT_MEMCPY)
        {
          mIndirectBufferLength = mIt->Len;
          mIndirectBuffer = mSource;
          mAction = ACTION_SERIALIZE_DIRECT;
        }
        else if(mIt->Ty==RecordSerializerInstruction::INDIRECT_MEMCPY)
        {
          if (!mIt->Accessor->GetNull(recordBuffer))
          {
            mIndirectBufferLength = mIt->Len;
            mIndirectBuffer = *((boost::uint8_t **)mSource);
            mAction = ACTION_SERIALIZE_INDIRECT;
          }
          else
          {
            mAction = ACTION_SERIALIZE_NULL;
          }
        }
        else if (mIt->Ty==RecordSerializerInstruction::INDIRECT_STRCPY)
        {
          if (!mIt->Accessor->GetNull(recordBuffer))
          {
            const char * str = *((const char **) mSource);
            mIndirectBufferLength = strlen(str) + 1;
            mIndirectBuffer = reinterpret_cast<const boost::uint8_t *>(str);
            mAction = ACTION_SERIALIZE_INDIRECT;
          }
          else
          {
            mAction = ACTION_SERIALIZE_NULL;
          }
        }
        else if(mIt->Ty==RecordSerializerInstruction::INDIRECT_WCSCPY)
        {
          if (!mIt->Accessor->GetNull(recordBuffer))
          {
            const wchar_t * str = *((const wchar_t **) mSource);
            mIndirectBufferLength = (wcslen(str) + 1) * sizeof(wchar_t);
            mIndirectBuffer = reinterpret_cast<const boost::uint8_t *>(str);
            mAction = ACTION_SERIALIZE_INDIRECT;
          }
          else
          {
            mAction = ACTION_SERIALIZE_NULL;
          }
        }

        // Process the field actions in "subiterators"
        if (mAction == ACTION_SERIALIZE_DIRECT)
        {
          compressedStream.next_in = (Bytef *) mIndirectBuffer;
          compressedStream.avail_in = mIndirectBufferLength;
          while(compressedStream.avail_in > 0)
          {
            mResult = deflate(&compressedStream, Z_NO_FLUSH);
            if (Z_OK != mResult)
            {
              mProgramCounter = PC_SERIALIZE_DIRECT_OUTPUT_EXHAUSTED;
              return NULL;
            case PC_SERIALIZE_DIRECT_OUTPUT_EXHAUSTED:;
            }
          }
          mSource += mIndirectBufferLength;
        }
        else if (mAction == ACTION_SERIALIZE_INDIRECT)
        {
          compressedStream.next_in = (Bytef *) &mIndirectBufferLength;
          compressedStream.avail_in = sizeof(boost::int32_t);
          while(compressedStream.avail_in > 0)
          {
            mResult = deflate(&compressedStream, Z_NO_FLUSH);
            if (Z_OK != mResult)
            {
              mProgramCounter = PC_SERIALIZE_INDIRECT_OUTPUT_LENGTH_EXHAUSTED;
              return NULL;
            case PC_SERIALIZE_INDIRECT_OUTPUT_LENGTH_EXHAUSTED:;
            }  
          }        
          compressedStream.next_in = (Bytef *)mIndirectBuffer;
          compressedStream.avail_in = mIndirectBufferLength;
          while(compressedStream.avail_in > 0)
          {
            mResult = deflate(&compressedStream, Z_NO_FLUSH);
            if (Z_OK != mResult)
            {
              mProgramCounter = PC_SERIALIZE_INDIRECT_OUTPUT_DATA_EXHAUSTED;
              return NULL;
            case PC_SERIALIZE_INDIRECT_OUTPUT_DATA_EXHAUSTED:;
            }  
          }        
          mSource += sizeof(void*);
        }
        else if (mAction == ACTION_SERIALIZE_NULL)
        {
          compressedStream.next_in = (Bytef *) &inPlaceNull;
          compressedStream.avail_in = sizeof(boost::int32_t);
          while(compressedStream.avail_in > 0)
          {
            mResult = deflate(&compressedStream, Z_NO_FLUSH);
            if (Z_OK != mResult)
            {
              mProgramCounter = PC_SERIALIZE_NULL_OUTPUT_EXHAUSTED;
              return NULL;
            case PC_SERIALIZE_NULL_OUTPUT_EXHAUSTED:;
            }
          }          
          mSource += sizeof(void*);
        }
      }
      // Make sure we are flushed to the output, and aligned to byte boundary.
      // We may not have to do this, because if for some reason some state
      // isn't flushed, this will just appear to the receiving end like a partial 
      // record.
//       mResult = deflate(&compressedStream, Z_SYNC_FLUSH);
    }
    }
  }
  return compressedStream.next_out;
}

ZLibRecordDeserializer::ZLibRecordDeserializer()
  :
  mTemp(NULL),
  mTempSize(0),
  mProgramCounter(PC_NEW_RECORD),
  mTarget(NULL),
  mIndirectBufferSize(0),
  mResult(Z_OK)
{
}

ZLibRecordDeserializer::ZLibRecordDeserializer(const ZLibRecordDeserializer& rhs)
  :
  mInstructions(rhs.mInstructions),
  mTemp(NULL),
  mTempSize(0),
  mProgramCounter(PC_NEW_RECORD),
  mTarget(NULL),
  mIndirectBufferSize(0),
  mResult(Z_OK)
{
}

ZLibRecordDeserializer::ZLibRecordDeserializer(const RecordMetadata & metadata)
  :
  mTemp(NULL),
  mTempSize(0),
  mProgramCounter(PC_NEW_RECORD),
  mTarget(NULL),
  mIndirectBufferSize(0),
  mResult(Z_OK)
{
  std::vector<RunTimeDataAccessor*> physicalOrder;
  for(boost::int32_t i=0;i<metadata.GetNumColumns();i++)
  {
    physicalOrder.push_back(metadata.GetColumn(i));
  }  
  std::sort(physicalOrder.begin(), physicalOrder.end(), FieldAddressOffsetOrder());

  mInstructions.push_back(RecordDeserializerInstruction::DirectMemcpy(metadata.GetDataOffset()));
  for(std::size_t i=0;i<physicalOrder.size();i++)
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

ZLibRecordDeserializer::~ZLibRecordDeserializer()
{
  delete [] mTemp;
}

class ZLibException : public std::exception
{
private:
  int mResult;
  std::string mMessage;
public:
  ZLibException(const char * file, int line, int result, z_stream& z)
    :
    mResult(result)
  {
    mMessage = (boost::format("Result: %1%; Stream.avail_in=%2%, Stream.total_in=%3%, Stream.avail_out=%4%, Stream.total_out=%5%, Stream.msg=%6%; File=%7%; Line=%8%") % mResult % z.avail_in % z.total_in % z.avail_out % z.total_out % (z.msg != NULL ? z.msg : "") % file % line).str();
  }

  virtual ~ZLibException() throw() {}

  virtual const char * what() const throw()
  {
    return mMessage.c_str();
  }
};

int ZLibRecordDeserializer::Deserialize(z_stream& compressedStream, record_t recordBuffer)
{
  switch(mProgramCounter)
  {
    while(true)
    {
      mProgramCounter = PC_NEW_RECORD;
      return SERIALIZATION_OK;
    case PC_NEW_RECORD:
      mTarget = recordBuffer;

      for(mIt = mInstructions.begin();
          mIt != mInstructions.end();
          mIt++)
      {
        if(mIt->Ty == RecordDeserializerInstruction::DIRECT_MEMCPY)
        {
          compressedStream.next_out = mTarget;
          compressedStream.avail_out = mIt->Len;
          while(compressedStream.avail_out > 0)
          {
            mResult = inflate(&compressedStream, Z_NO_FLUSH);
            if ((mResult == Z_OK && compressedStream.avail_in == 0 && compressedStream.avail_out > 0) ||
                (mResult == Z_BUF_ERROR && compressedStream.avail_in == 0))
            {
              mProgramCounter = PC_DIRECT_MEMCPY;
              return SERIALIZATION_INPUT_EXHAUSTED;
            case PC_DIRECT_MEMCPY:;
            }
            else if (mResult != Z_OK && (mResult != Z_STREAM_END || compressedStream.avail_out > 0 || mIt+1 != mInstructions.end()))
            {
              // How to reset state here?
              //return -2;
              throw ZLibException(__FILE__, __LINE__, mResult, compressedStream);
            }
          }
          mTarget += mIt->Len;
        }
        else if (mIt->Ty==RecordDeserializerInstruction::ACCESSOR)
        {
          compressedStream.next_out = (Bytef *) &mIndirectBufferSize;
          compressedStream.avail_out = sizeof(int);
          while(compressedStream.avail_out > 0)
          {
            mResult = inflate(&compressedStream, Z_NO_FLUSH);
            if ((mResult == Z_OK && compressedStream.avail_in == 0 && compressedStream.avail_out > 0) ||
                (mResult == Z_BUF_ERROR && compressedStream.avail_in == 0))
            {
              mProgramCounter = PC_INDIRECT_MEMCPY_LENGTH;
              return SERIALIZATION_INPUT_EXHAUSTED;
            case PC_INDIRECT_MEMCPY_LENGTH:;
            }
            else if (mResult != Z_OK)
            {
              // How to reset state here?
              //return -2;
              throw ZLibException(__FILE__, __LINE__, mResult, compressedStream);
            }
          }
          if (-1 != mIndirectBufferSize)
          {
            if (mTempSize < mIndirectBufferSize)
            {
              delete [] mTemp;
              mTemp = new boost::uint8_t [mIndirectBufferSize];
              mTempSize = mIndirectBufferSize;
            }
            compressedStream.next_out = (Bytef *) mTemp;
            compressedStream.avail_out = mIndirectBufferSize;
            while(compressedStream.avail_out > 0)
            {
              mResult = inflate(&compressedStream, Z_NO_FLUSH);
              if ((mResult == Z_OK && compressedStream.avail_in == 0 && compressedStream.avail_out > 0) ||
                  (mResult == Z_BUF_ERROR && compressedStream.avail_in == 0))
              {
                mProgramCounter = PC_INDIRECT_MEMCPY;
                return SERIALIZATION_INPUT_EXHAUSTED;
              case PC_INDIRECT_MEMCPY:;
              }
              else if (mResult != Z_OK && (mResult != Z_STREAM_END || compressedStream.avail_out > 0 || mIt+1 != mInstructions.end()))
              {
                // How to reset state here?
                //return -2;
                throw ZLibException(__FILE__, __LINE__, mResult, compressedStream);
              }
            }
            mIt->Accessor->SetValue(recordBuffer, mTemp);
            // Increment for the next memcpy (if there is one).
            mTarget += mIt->Accessor->GetPhysicalFieldType()->GetColumnStorage();
          }
          else
          {
            mIt->Accessor->SetNull(recordBuffer);
            // Increment for the next memcpy (if there is one).
            mTarget += mIt->Accessor->GetPhysicalFieldType()->GetColumnStorage();
          }
        }
      }
    }
  }
  return SERIALIZATION_OK;
}



RecordReadDataModel::RecordReadDataModel(const RecordMetadata& metadata)
  :
  mMetadata(metadata),
  mArchive(metadata),
  mMessage(NULL),
  mIsClosed(false)
{
}

RecordReadDataModel::~RecordReadDataModel()
{
  if (mMessage != NULL) mMetadata.Free(mMessage);
}

bool RecordReadDataModel::IsClosed() const
{
  return mIsClosed;
}

void RecordReadDataModel::Deserialize(boost::uint8_t * start, boost::uint8_t * end, RecordReadDataModel::internal_message_queue & target)
{
  mArchive.Bind(start, end);
//   if (mMessage)
//   {
//     // Try to complete partial message.  It will not be counted as a record
//     // in the archive.
//     if(SERIALIZATION_INPUT_EXHAUSTED == mArchive.Deserialize(mMessage))
//     {
//       mArchive.Unbind();
//       return;
//     }
//     // Make sure we don't get hosed from a linked list pointer
//     // from the outside world!
//     RecordMetadata::SetNext(mMessage, NULL);
//     if (mMetadata.IsEOF(mMessage))
//     {
//       mIsClosed = true;
//     }
//     target.Push(mMessage);    
//     mMessage = NULL;
//   }
//   for (boost::int32_t i = 0; i < mArchive.GetNumRecords(); i++)
  while(true)
  {
    // We can be coming through here to process a partial message or a new message
    if (mMessage == NULL)
      mMessage = mMetadata.Allocate();

    int result = mArchive.Deserialize(mMessage);
    if(SERIALIZATION_INPUT_EXHAUSTED == result)
    {
      break;
    }
    else if (SERIALIZATION_OK != result)
    {
      throw std::runtime_error((boost::format("Serialization error: %1%") % result).str());
    }
    ASSERT(false == mIsClosed);

    // Make sure we don't get hosed from a linked list pointer
    // from the outside world!
    RecordMetadata::SetNext(mMessage, NULL);
    if (mMetadata.IsEOF(mMessage))
    {
      mIsClosed = true;
    }
    target.Push(mMessage);
    mMessage = NULL;
  }
  mArchive.Unbind();
}

boost::int32_t RecordReadDataModel::RecordCount(const boost::uint8_t * buf) const
{
  return *((const boost::uint32_t *)buf);
}

RecordWriteDataModel::RecordWriteDataModel(const RecordMetadata& metadata)
  :
  mMetadata(metadata),
  mArchive(metadata),
  mIsClosed(false)
{
}

RecordWriteDataModel::~RecordWriteDataModel()
{
}

bool RecordWriteDataModel::IsClosed() const
{
  return mIsClosed;
}

bool RecordWriteDataModel::CanPush() const
{
  // I am ambivalent of exposing buffering in the compressor
  // using the CanPush predicate.  On the one hand, I want
  // to make sure that we try to write out the state, on the other
  // I'm not sure I want to block writers to the send queue.
  return mSendQueue.GetSize() == 0 && mArchive.CanPush();
}

void RecordWriteDataModel::Push(shared_message_queue& q)
{
  mSendQueue.Push(q);
}

// Must return the byte after the last byte written by the serialization.
// returned value is guaranteed to be > start and <= end.
// Requires: end >= start + 2*sizeof(int32_t)
// Note that it may be possible for Serialize to write partial records, however in those
// cases it is assumed that RecordWriteDataModel::RecordCount(start) will not include
// the partially written record.  In particular, if a buffer only contains a portion of a 
// large record, it may have a record count of 0.
// The net effect of this is that a partially written record remains in the send queue and 
// this triggers resending until it is completely processed.
// 
// Issue: use of partial records raises an issue.  A client of DataModel uses the CanPush predicate
// to determine whether or not there is more data in the data model's buffers to be flushed.
// Right now the implementation of serialization is in terms of record counts in the send queue
// and doesn't allow for buffering in the serializer itself.  This must be addressed by the technique above.
//
// Subtler is the effect of hidden buffering in the RecordSerializer underlying the data model (e.g. zlib compressed serializer).
// In this case, the record may report back as being completely written however it is not.  How does this fact get recognized
// and how does the flushing of that state occur in the absence of new records that arrive in the send queue?
boost::uint8_t * RecordWriteDataModel::Serialize(boost::uint8_t * start, boost::uint8_t * end)
{
  mArchive.Bind(start, end);
  internal_message_queue & q(mSendQueue);
  // It is possible to enter here with an empty queue if there
  // is buffer in the underlying serializer.  The API assumption
  // that Bind/Unbind call pairs will flush the internal buffers of 
  // the serializer.
  ASSERT(q.GetSize() >= 0);
  boost::int32_t queueSize = q.GetSize();
  boost::uint8_t * used = start;
  for (boost::int32_t i = 0; i<queueSize; i++)
  {
    ASSERT(!mIsClosed);
    if (mMetadata.IsEOF(q.Top()))
    {
      mIsClosed = true;
    }
    boost::uint8_t * nbuf = mArchive.Serialize(q.Top(), mIsClosed);
    if (nbuf != NULL)
    {
      used = nbuf;
      MessagePtr m;
      q.Pop(m);
      mMetadata.Free(m);
    }
    else
    {
      break;
    }
  }
  return mArchive.Unbind();
}

boost::int32_t RecordWriteDataModel::RecordCount(const boost::uint8_t * buf) const
{
  return *((const boost::uint32_t *)buf);
}

MessagePassingReadEndpoint::MessagePassingReadEndpoint(const RecordDataModel::read_model& metadata, 
                                                         MPI_Request& request,
                                                         MPI_Request& ackRequest,
                                                         std::size_t idx, 
                                                         boost::int32_t tag, 
                                                         boost::int32_t dest)
  :
  mIndex(idx),
  mTag(tag),
  mPartition(dest),
  mBuffer(NULL),
  mBufferLength(0),
  mRequest(request),
  mAckRequest(ackRequest),
  mAckBuffer(0),
  mUnacked(0),
  mLastMessageSeen(false),
  mDataModel(metadata),
  mDeserializeTicks(0LL),
  mDeserializeExecutions(0LL),
  mRecvTicks(0LL),
  mRecvExecutions(0LL)
{
  mBufferLength = 128*1024;
#ifdef DEBUG
  mBuffer = new boost::uint8_t [mBufferLength + 64];
  memset(mBuffer + mBufferLength, 0xdb, 64);
#else
  mBuffer = new boost::uint8_t [mBufferLength];
#endif
}

MessagePassingReadEndpoint::~MessagePassingReadEndpoint()
{
}

void MessagePassingReadEndpoint::Start()
{
  ASSERT(mRequest == MPI_REQUEST_NULL && false == mLastMessageSeen);
  int ret = MPI_Irecv(mBuffer, mBufferLength, MPI_BYTE, mPartition, GetTag(), MPI_COMM_WORLD, &mRequest);
}

void MessagePassingReadEndpoint::CompleteRemoteRequest(RecordDataModel::read_model::internal_message_queue& q, MPI_Status& status)
{
  // This should have been cleared by MPI_Testsome
  ASSERT(mRequest == MPI_REQUEST_NULL);
  // Check that this read matches our expected tag and source values.
  if (mPartition != status.MPI_SOURCE || GetTag() != status.MPI_TAG)
  {
    throw std::runtime_error((boost::format("MessagePassingReadEndpoint received unexpected message: status.MPI_SOURCE=%1%; status.MPI_TAG=%2%; this->mPartition=%3%; this->GetTag()=%4%") % status.MPI_SOURCE % status.MPI_TAG % mPartition % GetTag()).str());
  }
  int cnt=0;
  int ret = MPI_Get_count(&status, MPI_BYTE, &cnt);
  if (cnt <= 0)
  {
    throw std::runtime_error((boost::format("MessagePassingReadEndpoint received invalid message length: %1%; MPI_Get_count returned %2%; status.MPI_SOURCE=%3%; status.MPI_TAG=%4%; status.MPI_ERROR=%5%; status.cancelled=%6%; status.count=%7%") % cnt % ret % status.MPI_SOURCE % status.MPI_TAG % status.MPI_ERROR % status.cancelled % status.count).str());
  }
  mDataModel.Deserialize(mBuffer, mBuffer+cnt, q);
  mUnacked += reinterpret_cast<const MessageHeader *>(mBuffer)->RecordCount;
  mLastMessageSeen = reinterpret_cast<const MessageHeader *>(mBuffer)->Closed != 0;

//   int32_t prevCapacity=GetSize();
//   int32_t initialSize = mReceiveQueueSize;
//   mReceiveQueueSize += tmpQueue.GetSize();
//   mReceiveQueue.push_front(tmpQueue);
//   ASSERT(mReceiveQueueSize > initialSize);

  if (0 == mLastMessageSeen && mRequest == MPI_REQUEST_NULL)
  {
    int ret = MPI_Irecv(mBuffer, mBufferLength, MPI_BYTE, mPartition, GetTag(), MPI_COMM_WORLD, &mRequest);
  } 
  else if (0 != mLastMessageSeen)
  {
    delete [] mBuffer;
    mBuffer = NULL;
  }
}

void MessagePassingReadEndpoint::CompleteAckRequest(bool& isClosed)
{
  // This should have been cleared by MPI_Testsome
  ASSERT(mAckRequest == MPI_REQUEST_NULL);
  // We require that the caller passes in the closed flag. TODO: Maintain this internally.
  // In any case we should have a unique closure event: the last ack we will receive.
  ASSERT(!isClosed);
  // Ack done.  Decrement count (we just got the ack buffer back from MPI so it should
  // still have a valid value).
  mUnacked -= mAckBuffer;
  // Keep pumping or check for closure?
  if (mAcks.size() > 0)
  {
    // Is there a pending ack to be sent?
    mAckBuffer = mAcks.back();
    mAcks.pop_back();
    int ret = MPI_Isend(&mAckBuffer, sizeof(mAckBuffer), MPI_BYTE, mPartition, GetAckTag(), MPI_COMM_WORLD, &mAckRequest);
    isClosed = false;
  }
  else
  {
    // The endpoint is closed for business when EOF is seen and all acks are sent.
    isClosed = mLastMessageSeen && mUnacked==0;
    if (isClosed)
    {
      // Just here so I can set a break;
      isClosed = true;
    }
  }
}

void MessagePassingReadEndpoint::DumpStatistics(std::ostream& ostr)
{
}

void MessagePassingReadEndpoint::ProcessAckRequest(boost::int32_t credit)
{
  if (mAckRequest != MPI_REQUEST_NULL)
  {
    mAcks.push_front(credit);
  }
  else
  {
    mAckBuffer = credit;
    int ret = MPI_Isend(&mAckBuffer, sizeof(mAckBuffer), MPI_BYTE, mPartition, GetAckTag(), MPI_COMM_WORLD, &mAckRequest);
  }
}

MessagePassingWriteEndpoint::MessagePassingWriteEndpoint(const RecordDataModel::write_model& metadata, 
                                                         MPI_Request& request,
                                                         MPI_Request& ackRequest,
                                                         std::size_t idx, 
                                                         boost::int32_t tag, 
                                                         boost::int32_t dest)
  :
  mNext(NULL),
  mIndex(idx),
  mTag(tag),
  mPartition(dest),
  mWireRecords(0),
  mBuffer(NULL),
  mBufferLength(0),
  mRequest(request),
  mAckRequest(ackRequest),
  mAckBuffer(-1),
  mLastMessageSeen(false),
  mDataModel(metadata),
  mSerializeTicks(0LL),
  mSerializeExecutions(0LL),
  mSendTicks(0LL),
  mSendExecutions(0LL)
{
  mBufferLength = 128*1024;
#ifdef DEBUG
  mBuffer = new boost::uint8_t [mBufferLength + 64];
  memset(mBuffer + mBufferLength, 0xdb, 64);
#else
  mBuffer = new boost::uint8_t [mBufferLength];
#endif
}

MessagePassingWriteEndpoint::~MessagePassingWriteEndpoint()
{
  delete [] mBuffer;
}

void MessagePassingWriteEndpoint::OnWriteRequest(RecordDataModel::write_model::shared_message_queue& q)
{
  ASSERT(mRequest == MPI_REQUEST_NULL);
  ASSERT(mDataModel.CanPush());
  mDataModel.Push(q);
}

void MessagePassingWriteEndpoint::ProcessWriteRequest()
{
  ASSERT(mRequest == MPI_REQUEST_NULL);

  boost::uint8_t * buf = mDataModel.Serialize(mBuffer, mBuffer + mBufferLength);

  // Make a note of more stuff on the wire, decrement when ACK'd
  // TODO: Perhaps make type of count a metafunction?
  mWireRecords += reinterpret_cast<const MessageHeader *>(mBuffer)->RecordCount;
  ASSERT(!mLastMessageSeen);
  mLastMessageSeen = reinterpret_cast<const MessageHeader *>(mBuffer)->Closed != 0;

#ifdef DEBUG
  for(int i=0; i<64; i++)
  {
    if (mBuffer[mBufferLength + i] != 0xdb)
      throw std::runtime_error("Buffer overrun");
  }
#endif

  // TODO: Currently we don't handle records bigger than a single buffer.
  // TODO: Support fragmenting a record into multiple messages.
//   ASSERT(mWireRecords > 0);
  ASSERT(buf <= mBuffer + mBufferLength);
  ASSERT(buf > mBuffer);
  ASSERT(mRequest == MPI_REQUEST_NULL);

  if(buf <= mBuffer)
  {
    throw std::runtime_error((boost::format("Invalid serialization output buffer of length: %1%") % (buf-mBuffer)).str());
  }

  int ret = MPI_Isend(mBuffer, buf-mBuffer, MPI_BYTE, mPartition, GetTag(), MPI_COMM_WORLD, &mRequest);

  // Start pumping ACKs if not already done.
  // Make sure we don't process a completed ack that 
  // needs to go through CompleteAckRequest.
  if (MPI_REQUEST_NULL == mAckRequest && -1 == mAckBuffer)
  {
    ret = MPI_Irecv(&mAckBuffer, sizeof(mAckBuffer), MPI_BYTE, mPartition, GetAckTag(), MPI_COMM_WORLD, &mAckRequest);    
  }
}

void MessagePassingWriteEndpoint::CompleteAckRequest(bool& isClosed)
{
  // Should have been cleared by MPI_Testsome.
  ASSERT(mAckRequest == MPI_REQUEST_NULL);
  // Must have been something to ack.
  ASSERT(mWireRecords > 0);
  // Mustn't be acking something we haven't sent.
  ASSERT(mWireRecords >= mAckBuffer);
  
  mWireRecords -= mAckBuffer;
  if (mWireRecords > 0)
  {
    int ret = MPI_Irecv(&mAckBuffer, sizeof(mAckBuffer), MPI_BYTE, mPartition, GetAckTag(), MPI_COMM_WORLD, &mAckRequest);    
    isClosed = false;
  }
  else
  {
    // We are closed when all acks are received and EOF has been seen.
    isClosed = mLastMessageSeen;
    if(isClosed)
    {
      // TODO: Remove.  Just here for me to set a breakpoint.
      isClosed = true;
    }
    // Mark state flag so that we will
    // generate an ack request on the next write.
    mAckBuffer = -1;
  }
}

void MessagePassingWriteEndpoint::CompleteRemoteRequest(bool & stillWorking)
{
  // We may have more to pump over if there is anything left in
  // our send queue.  Otherwise complete and signal empty send queue.
  // This should have been cleared by MPI_Testsome
  ASSERT(mRequest == MPI_REQUEST_NULL);
  if (!mDataModel.CanPush())
  {
    ProcessWriteRequest();
    stillWorking = true;
  }
  else
  {
    // Signal to unblock writer.
    stillWorking = false;
    if (mLastMessageSeen)
    {
      delete [] mBuffer;
      mBuffer = NULL;
    }
  }
}

int query_fn(void * extra_state, MPI_Status * status)
{
  MPI_Status_set_elements(status, MPI_INT, 1);
  MPI_Status_set_cancelled(status, 0);
  status->MPI_SOURCE = MPI_UNDEFINED;
  status->MPI_TAG = MPI_UNDEFINED;
  return MPI_SUCCESS;
}

int free_fn(void * extra_state)
{
  return MPI_SUCCESS;
}

int cancel_fn(void * extra_state, int complete)
{
  if (!complete)
  {
    MPI_Abort(MPI_COMM_WORLD, 99);
  }
  return MPI_SUCCESS;
}

/**
 * A message request is a fifo queue of MessagePtr together with
 * a target endpoint.
 */
class MessageReadRequest : public RecordDataModel::read_model::internal_message_queue
{
public:
  MessageReadRequest * Next;
  boost::int32_t Endpoint;
  MessageReadRequest()
    :
    Next(NULL),
    Endpoint(-1)
  {
  }
  ~MessageReadRequest()
  {
  }
};

MessagePassingService::MessagePassingService(const std::vector<ReadEndpointDescriptor>& readEndpoints, 
                                             const std::vector<WriteEndpointDescriptor>& writeEndpoints)
  :
  mWriteRequest(NULL),
  mReadAckBuffer(readEndpoints.size()),
  mReadRequest(readEndpoints.size()),
  mReadClosedMask(readEndpoints.size()),
  mWriteClosedMask(writeEndpoints.size()),
//   requests(3*readEndpoints.size() + 3*writeEndpoints.size(), MPI_REQUEST_NULL),
//   indices(3*readEndpoints.size() + 3*writeEndpoints.size()),
//   status(3*readEndpoints.size() + 3*writeEndpoints.size()),
  requests(2*readEndpoints.size() + 2*writeEndpoints.size() + 1, MPI_REQUEST_NULL),
  indices(2*readEndpoints.size() + 2*writeEndpoints.size() + 1),
  status(2*readEndpoints.size() + 2*writeEndpoints.size() + 1),
  mStopRequest(false),
  mTestsomeTicks(0LL),
  mTestsomeRequests(0LL),
  mTestsomeExecutions(0LL),
  mWaitsomeTicks(0LL),
  mWaitsomeRequests(0LL),
  mWaitsomeExecutions(0LL),
  mCompletionTicks(0LL),
  mCompletionExecutions(0LL),
  mTransferRequestsTicks(0LL),
  mTransferRequestsExecutions(0LL),
  mProcessWriteRequestTicks(0LL),
  mProcessWriteRequestExecutions(0LL),
  mProcessReadAckRequestTicks(0LL),
  mProcessReadAckRequestExecutions(0LL),
  mMoveToSharedQueuesTicks(0LL),
  mMoveToSharedQueuesExecutions(0LL),
  mSendQueueWaitTicks(0LL),
  mSendQueueWaitExecutions(0LL)
{
  // Set flags to 1.  We'll clear them when
  // an endpoint closes.
  mReadClosedMask.flip();
  mWriteClosedMask.flip();

  // Set up the read and write endpoints (buffers, serializers, etc)
  for(std::vector<ReadEndpointDescriptor>::const_iterator it = readEndpoints.begin();
      it != readEndpoints.end();
      ++it)
  {
    std::size_t idx = it - readEndpoints.begin();
    mReadEndpoints.push_back(new MessagePassingReadEndpoint(it->Metadata,
                                                            requests[idx],
                                                            requests[idx + readEndpoints.size()],
                                                            idx,
                                                            it->Tag,
                                                            it->Partition));
  }
  for(std::vector<WriteEndpointDescriptor>::const_iterator it = writeEndpoints.begin();
      it != writeEndpoints.end();
      ++it)
  {
    std::size_t idx = it - writeEndpoints.begin();
    mWriteEndpoints.push_back(new MessagePassingWriteEndpoint(it->Metadata,
                                                              requests[idx + 2*readEndpoints.size()],
                                                              requests[idx + 2*readEndpoints.size() + writeEndpoints.size()],
                                                              idx,
                                                              it->Tag,
                                                              it->Partition));
    mWriteRequests.push_back(new MessageRequest());
  }

  // Initialize requests for client doorbells: message writes and read acks.
  for(size_t i = 0; i < 1; i++)
//   for(size_t i = 0; i < readEndpoints.size() + writeEndpoints.size(); i++)
  {
    int ret = MPI_Grequest_start(query_fn, free_fn, cancel_fn, NULL, &requests[i+2*readEndpoints.size()+2*writeEndpoints.size()]);
    if (MPI_SUCCESS != ret)
    {
      throw std::runtime_error((boost::format("Error MPI_Grequest_start: %1%") % ret).str());
    }    
  }
  mWakeupRequired = true;
}

MessagePassingService::~MessagePassingService()
{
}

void MessagePassingService::Run(MessagePassingServiceHandler& ackHandler)
{
  boost::uint64_t tick;
  boost::uint64_t tock;

  boost::int32_t readRequestEnd = mReadEndpoints.size();
  boost::int32_t readAckRequestEnd = readRequestEnd + mReadEndpoints.size();
  boost::int32_t writeRequestEnd = readAckRequestEnd + mWriteEndpoints.size();
  boost::int32_t writeAckRequestEnd = writeRequestEnd + mWriteEndpoints.size();

  // Local copy of requested read acks.
  std::vector<boost::int32_t> localReadAckBuffer(mReadEndpoints.size());

  // Complete and deserialize into these buffers that we exclusively
  // own.  At sync time, move into shared buffers.
  std::vector<MessageReadRequest> localReadBuffer(mReadEndpoints.size());
  for(std::size_t i=0; i<localReadBuffer.size(); ++i)
  {
    localReadBuffer[i].Endpoint = i;
  }
  IntrusiveFifo<MessageReadRequest> localReadQueue;

  for(std::vector<MessagePassingReadEndpoint*>::iterator it=mReadEndpoints.begin();
      it != mReadEndpoints.end();
      ++it)
  {
    (*it)->Start();
  }

  while((!mWriteClosedMask.none() || !mReadClosedMask.none()) && !mStopRequest)
  {
    MessagePassingWriteEndpoint * todoList = NULL;

    TIMER_TICK();
    {
      // Pull from shared write request queues into service owned send queues.
      // Protect with guard since the request queues are shared.
      MetraFlow::SpinLockGuard lk(mQueueGuard);
//       boost::timed_mutex::scoped_lock lk(mQueueGuard);
      for (;mWriteRequest != NULL; mWriteRequest = mWriteRequest->Next)
      {
        // Move request from shared queue.
        mWriteEndpoints[mWriteRequest->Endpoint]->OnWriteRequest(*mWriteRequest);
        // We must process these.  We want to do it without holding
        // the lock so queue up.
        mWriteEndpoints[mWriteRequest->Endpoint]->SetNext(todoList);
        todoList = mWriteEndpoints[mWriteRequest->Endpoint];
      }
      if (mReadAckBuffer.size() != 0)
      {
        // Move read ack requests into local buffer and clear.
        memcpy(&localReadAckBuffer[0], &mReadAckBuffer[0], mReadAckBuffer.size()*sizeof(boost::int32_t));
        memset(&mReadAckBuffer[0], 0, mReadAckBuffer.size()*sizeof(boost::int32_t));
      }
    }
    TIMER_TOCK();
    mTransferRequestsTicks += (tock - tick);
    mTransferRequestsExecutions += 1;

    // Process newly arrived write requests.  For example,
    // serialize any newly arrived write requests into
    // buffer then do a non-blocking send.
    TIMER_TICK();
    for(;todoList != NULL; todoList = todoList->GetNext())
    {
      todoList->ProcessWriteRequest();
    }
    TIMER_TOCK();
    mProcessWriteRequestTicks += (tock - tick);
    mProcessWriteRequestExecutions += 1;

    // Process newly arrived acks.
    TIMER_TICK();
    for(std::vector<boost::int32_t>::iterator it = localReadAckBuffer.begin();
        it != localReadAckBuffer.end();
        ++it)
    {
      if (*it != 0)
      {
        mReadEndpoints[it - localReadAckBuffer.begin()]->ProcessAckRequest(*it);
      }
    }
    TIMER_TOCK();
    mProcessReadAckRequestTicks += (tock - tick);
    mProcessReadAckRequestExecutions += 1;

    // test for progress
    // TODO: Optimize for the (I think) common case in which
    // we have a write request an every endpoint.  In this
    // case we can wait instead of test since there is
    // there can't by any new write requests arriving (the only
    // other thing we do).
    bool wait = true;
    // If there all write requests are non-null then wait.
    for(boost::int32_t i=readAckRequestEnd; i<writeRequestEnd; i++)
    {
      if(requests[i] == MPI_REQUEST_NULL)
      {
        wait = false;
        break;
      }
    }
    int num=0;

    if (false /*!wait*/)
    {
      TIMER_TICK();
      int ret = MPI_Testsome(requests.size(), &requests[0], &num, &indices[0], &status[0]);
      TIMER_TOCK();
      if (ret != MPI_SUCCESS)
      {
        if (ret == MPI_ERR_IN_STATUS)
        {
          std::string msg("MPI_Testsome failed.");
          for(int i=0; i<num; i++)
          {
            MPI_Status & s(status[i]);
            if (s.MPI_ERROR != 0)
            {
              msg += (boost::format("MPI Error: Source=%1%; Tag=%2%; Error=%3%") % s.MPI_SOURCE % s.MPI_TAG % s.MPI_ERROR).str();
            }
          }

          throw std::runtime_error(msg);
        }
        else
        {
          throw std::runtime_error((boost::format("MPI_Testsome failed: %1%") % ret).str());
        }
      }
      mTestsomeTicks += (tock - tick);
      mTestsomeRequests += num;
      mTestsomeExecutions += 1;
    }
    else
    {
      TIMER_TICK();
      int ret = MPI_Waitsome(requests.size(), &requests[0], &num, &indices[0], &status[0]);
      TIMER_TOCK();
      if (ret != MPI_SUCCESS)
      {
        if (ret == MPI_ERR_IN_STATUS)
        {
          std::string msg("MPI_Waitsome failed.");
          for(int i=0; i<num; i++)
          {
            MPI_Status & s(status[i]);
            if (s.MPI_ERROR != 0)
            {
              msg += (boost::format("MPI Error: Source=%1%; Tag=%2%; Error=%3%") % s.MPI_SOURCE % s.MPI_TAG % s.MPI_ERROR).str();
            }
          }

          throw std::runtime_error(msg);
        }
        else
        {
          throw std::runtime_error((boost::format("MPI_Waitsome failed: %1%") % ret).str());
        }
      }
      mWaitsomeTicks += (tock - tick);
      mWaitsomeRequests += num;
      mWaitsomeExecutions += 1;
    }
      
    // For completed acks receives update count.
    TIMER_TICK();
    for(int i=0; i<num; i++)
    {
      boost::int32_t idx = indices[i];

      if (indices[i] < readRequestEnd)
      {
        // Careful!  The requests are indexed indirectly through the indices array,
        // but status is indexed directly (MPI1 spec, page 49, line 2).
        mReadEndpoints[idx]->CompleteRemoteRequest(localReadBuffer[idx], status[i]);
        if (localReadBuffer[idx].Next == NULL)
        {
          localReadQueue.Push(&localReadBuffer[idx]);
        }
        // This should call LinuxProcessor::OnWriteCompletion()
        // to reprioritize any pending read on the endpoint.
      }
      else if (indices[i] < readAckRequestEnd)
      {
        bool isClosed = !mReadClosedMask.test(idx-readRequestEnd);
        mReadEndpoints[idx-readRequestEnd]->CompleteAckRequest(isClosed);
        if (isClosed)
        {
          mReadClosedMask.set(idx-readRequestEnd, false);
        }
      }
      else if (indices[i] < writeRequestEnd)
      {
        bool stillSending;
        mWriteEndpoints[idx-readAckRequestEnd]->CompleteRemoteRequest(stillSending);
        if (!stillSending)
        {
          // Queue up to clear flags under protection of a single mutex acquire.
          mWriteEndpoints[idx-readAckRequestEnd]->SetNext(todoList);
          todoList = mWriteEndpoints[idx-readAckRequestEnd];
        }
      }
      else if (indices[i] < writeAckRequestEnd)
      {
        bool isClosed = !mWriteClosedMask.test(idx-writeRequestEnd);
        boost::int32_t prevCapacity=mWriteEndpoints[idx-writeRequestEnd]->GetWireRecords();
        mWriteEndpoints[idx-writeRequestEnd]->CompleteAckRequest(isClosed);
        // Attention: Between This point and the end of the OnReadCompletion call
        // a client will see a size that is higher than the last value it received
        // from the event handler.
        if (isClosed)
        {
          mWriteClosedMask.set(idx-writeRequestEnd, false);
        }        
        boost::int32_t newCapacity=mWriteEndpoints[idx-writeRequestEnd]->GetWireRecords();
        // We are making MPISend channels finite capacity of 1000 records.
        ackHandler.OnReadCompletion(prevCapacity > 1000 ? std::numeric_limits<boost::int32_t>::max() : prevCapacity, 
                                    newCapacity > 1000 ? std::numeric_limits<boost::int32_t>::max() : newCapacity, 
                                    idx-writeRequestEnd);
      }
      else
      {
        ASSERT(!mWakeupRequired);
        // Else this is an external client waking us up because of
        // new records.  Not too much to do here, we'll handle this when we
        // process write requests or read acks above.  We do reset the event here.  Note that
        // clients won't get to trigger the event until we actually complete the MPI_Send
        // of the new record we were just signaled for.
        MPI_Grequest_start(query_fn, free_fn, cancel_fn, NULL, &requests[indices[i]]);        
        // memory barrier required?  I don't think so because Grequest handling uses
        // locks.  Also checking for read acks and writes will take a lock prior to actually waiting and that will
        // guarantee that other threads will see the correct value of the flag prior to this
        // thread going to sleep.
        mWakeupRequired = true;
      }
    }
    TIMER_TOCK();
    mCompletionTicks += (tock - tick);
    mCompletionExecutions += 1;

    // deserialize any completed receives and place into 
    // request queues.  If not closed make another non-blocking
    // receive.
    // for completed sends, if there is more in the queue send
    // it otherwise signal the client in case they're waiting.
    TIMER_TICK();
    if(todoList != NULL || localReadQueue.GetSize() > 0)
    {
//       boost::timed_mutex::scoped_lock lk(mQueueGuard);
      MetraFlow::SpinLockGuard lk(mQueueGuard);
      // Propagate to shared read queues.
      while(localReadQueue.GetSize() > 0)
      {
        MessageReadRequest* readRequest;
        localReadQueue.Pop(readRequest);
        ASSERT(readRequest != NULL);
        boost::int32_t prevCapacity=mReadRequest[readRequest->Endpoint].GetSize();
        readRequest->Pop(mReadRequest[readRequest->Endpoint]);
        // Attention: Between This point and the end of the OnWriteCompletion call
        // a client will see a size that is lower than the last value it received
        // from the event handler.
        boost::int32_t newCapacity=mReadRequest[readRequest->Endpoint].GetSize();
        ackHandler.OnWriteCompletion(prevCapacity, newCapacity, readRequest->Endpoint);
      }
      // Deferred clearing of requests.  Notify writers when
      // done.
      if (todoList)
      {      
        for(; todoList != NULL; todoList = todoList->GetNext())
        {
          ReleaseRequest(mWriteRequests[todoList->GetIndex()]);
        }
//         mQueueCondVar.notify_all();
      }
    }
    TIMER_TOCK();
    mMoveToSharedQueuesTicks += (tock - tick);
    mMoveToSharedQueuesExecutions += 1;
  }
}

void MessagePassingService::Stop()
{
  mStopRequest = true;
}

MessageRequest * MessagePassingService::GetRequest(boost::int32_t source)
{
  // Request policy here.  Current implementation is
  // a single outstanding write request.  Where the
  // the request is considered active from the moment
  // that it is submitted by the client till the moment
  // that the last write has completed.
  // Note that we potentially could be a bit more permissive
  // and pipeline writes between the intermediate queue,
  // the send queue and the MPI buffer.  What we want to
  // avoid is behavior related to sender side queuing in which
  // a sender proceeds without a consumer seeing the real
  // channel size.  
  MessageRequest * r = mWriteRequests[source];
  return r->Endpoint == -1 ? r : NULL;
}

void MessagePassingService::ReleaseRequest(MessageRequest * r)
{
  // Request policy here.
  ASSERT(r->Endpoint != -1);
  r->Endpoint = -1;
}

void MessagePassingService::Send(boost::int32_t source, 
                                 RecordDataModel::write_model::client_message_queue& data,
                                 MessagePassingServiceHandler & handler)
{
  boost::uint64_t tick;
  boost::uint64_t tock;
  boost::int32_t wait=0;
  while(true)
  {
    {
      MessageRequest * r;
      MetraFlow::SpinLockGuard lk(mQueueGuard);
      if((r = GetRequest(source))!= NULL)
      {
        if (0 != wait)
        {
          TIMER_TOCK();
          mSendQueueWaitTicks += (tock - tick);
          mSendQueueWaitExecutions += 1;
        }

        ASSERT(r->Endpoint == -1);
        // We're cool to enqueue request to the intermediate shared queue.
        r->Push(data);
        r->Endpoint = source;
        // Enqueue request for service.
        r->Next = mWriteRequest;
        mWriteRequest = r;
        // This should call LinuxProcessor::OnWrite() to clear the
        // write request to this endpoint (the one in the producer of data).
        // Note that OnWrite must be called from within the Service because
        // the service lock protecting the shared queues (mQueueGuard) must be taken
        // before the handler locks.
        handler.OnWrite(source);
        // Wake up service to let it know that we have dropped of some
        // data.
        if (mWakeupRequired)
        {
          mWakeupRequired = false;
          ASSERT(requests[2*mReadEndpoints.size() + 2*mWriteEndpoints.size()] != MPI_REQUEST_NULL);
          MPI_Grequest_complete(requests[2*mReadEndpoints.size() + 2*mWriteEndpoints.size()]);
        }
//         MPI_Grequest_complete(requests[source + 2*mReadEndpoints.size() + 2*mWriteEndpoints.size()]);
        return;
      }  
    }
    if (0 == wait)
    {
      TIMER_TICK();
      wait = 1;
    }
    ::Sleep(wait);
    if (wait < 1024)
      wait <<= 1;
  }
//   boost::timed_mutex::scoped_lock lk(mQueueGuard);
//   // Check to see if we can access, otherwise wait.
//   MessageRequest * r;
//   while((r = GetRequest(source)) == NULL)
//   {
//     TIMER_TICK();
//     mQueueCondVar.wait(lk);
//     TIMER_TOCK();
//     mSendQueueWaitTicks += (tock - tick);
//     mSendQueueWaitExecutions += 1;
//   }

//   ASSERT(r->Endpoint == -1);
//   // We're cool to enqueue request to the intermediate shared queue.
//   r->Push(data);
//   r->Endpoint = source;
//   // Enqueue request for service.
//   r->Next = mWriteRequest;
//   mWriteRequest = r;
//   // This should call LinuxProcessor::OnWrite() to clear the
//   // write request to this endpoint (the one in the producer of data).
//   // Note that OnWrite must be called from within the Service because
//   // the service lock protecting the shared queues (mQueueGuard) must be taken
//   // before the handler locks.
//   handler.OnWrite(source);
}

void MessagePassingService::Recv(boost::int32_t source, 
                                 RecordDataModel::read_model::client_message_queue& data,
                                 MessagePassingServiceHandler & handler)
{
  // SINGLE THREADED ASSUMPTION
  // If we have to, spin waiting for a valid generalized request.  If we get
  // one we have it for good since we are the only place it will be completed.
  // This is yet another place we have assumed a single worker thread.
  MPI_Request * request = &requests[2*mReadEndpoints.size() + 2*mWriteEndpoints.size()];
//   MPI_Request * request = &requests[source + 2*mReadEndpoints.size() + 3*mWriteEndpoints.size()];
//   while(*request == MPI_REQUEST_NULL)
//   {
//     // TODO: Add logging and some kind of abort logic.
//     // We should only be here if we arrive in the short window
//     // between when another Recv on the same endpoint happened and
//     // the service processing hasn't gotten around to creating a new Grequest.
//   }

  MetraFlow::SpinLockGuard lk(mQueueGuard);
//   boost::timed_mutex::scoped_lock lk(mQueueGuard);
  boost::int32_t qSize = mReadRequest[source].GetSize();
  if (qSize > 0)
  {
    boost::int32_t prevSize = data.GetSize();
    mReadRequest[source].PopSome(data, METRAFLOW_BATCH_SCHEDULER_GRAIN);
    mReadAckBuffer[source] += (data.GetSize() - prevSize);
  }
  // This should call LinuxProcessor::OnRead() to clear the
  // read request from this endpoint (the one consuming the data).
  // Note that OnRead must be called from within the Service because
  // the service lock protecting the shared queues (mQueueGuard) must be taken
  // before the handler locks.
  handler.OnRead(source);
  if (mWakeupRequired)
  {
    mWakeupRequired = false;
    ASSERT(*request != MPI_REQUEST_NULL);
    MPI_Grequest_complete (*request);
  }
//   MPI_Grequest_complete (*request);
}

void MessagePassingService::DumpStatistics(std::ostream & ostr)
{
  // Performance counters
  ostr << "\nTestsomeTicks TestsomeExecutions AvgTestomeRequests TotalRequests WaitsomeTicks WaitsomeExecutions CompletionTicks CompletionExecutions TransferRequestsTicks TransferRequestsExecutions ProcessWriteRequestTicks ProcessWriteRequestExecutions ProcessReadAckRequestTicks ProcessReadAckRequestExecutions MoveToSharedQueuesTicks MoveToSharedQueuesExecutions SendQueueWaitTicks SendQueueWaitExecutions";

  ostr << "\n" << mTestsomeTicks;
  ostr << " " << mTestsomeExecutions;
  ostr << " " << (1.0*mTestsomeRequests)/mTestsomeExecutions;
  ostr << " " << mTestsomeRequests+mWaitsomeRequests;
  ostr << " " << mWaitsomeTicks;
  ostr << " " << mWaitsomeExecutions;
  ostr << " " << mCompletionTicks;
  ostr << " " << mCompletionExecutions;
  ostr << " " << mTransferRequestsTicks;
  ostr << " " << mTransferRequestsExecutions;
  ostr << " " << mProcessWriteRequestTicks;
  ostr << " " << mProcessWriteRequestExecutions;
  ostr << " " << mProcessReadAckRequestTicks;
  ostr << " " << mProcessReadAckRequestExecutions;
  ostr << " " << mMoveToSharedQueuesTicks;
  ostr << " " << mMoveToSharedQueuesExecutions;
  ostr << " " << mSendQueueWaitTicks;
  ostr << " " << mSendQueueWaitExecutions;
  ostr << std::endl;
  
}
