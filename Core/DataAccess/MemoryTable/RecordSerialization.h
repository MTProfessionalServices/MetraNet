#ifndef __RECORDSERIALIZATION_H__
#define __RECORDSERIALIZATION_H__

#include "MetraFlowConfig.h"
#include "RecordModel.h"
#include "Scheduler.h"
#define ZLIB_DLL
#include "zlib.h"

#include <stack>

typedef struct tagMessageHeader
{
  boost::int32_t RecordCount;
  boost::int32_t Closed;
} MessageHeader;

class ZLibRecordSerializer
{
private:  
  std::vector<RecordSerializerInstruction> mInstructions;
  boost::int32_t mMinSize;
  
  //
  // ZLibRecordSerializer iterator state
  //
  static const boost::int32_t inPlaceNull=-1;
  enum State {PC_NEW_RECORD, 
              PC_SERIALIZE_DIRECT_OUTPUT_EXHAUSTED,
              PC_SERIALIZE_INDIRECT_OUTPUT_LENGTH_EXHAUSTED, PC_SERIALIZE_INDIRECT_OUTPUT_DATA_EXHAUSTED, 
              PC_SERIALIZE_NULL_OUTPUT_EXHAUSTED};

  enum Action { ACTION_SERIALIZE_DIRECT, ACTION_SERIALIZE_INDIRECT, ACTION_SERIALIZE_NULL };

  Action mAction;
  State mProgramCounter;
  const_record_t mSource;
  boost::int32_t mIndirectBufferLength;
  const boost::uint8_t * mIndirectBuffer;
  int mResult;
  std::vector<RecordSerializerInstruction>::const_iterator mIt;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mInstructions);
    ar & BOOST_SERIALIZATION_NVP(mMinSize);
  }  
  METRAFLOW_DECL ZLibRecordSerializer();
public:
  METRAFLOW_DECL ZLibRecordSerializer(const RecordMetadata & metadata);
  METRAFLOW_DECL ZLibRecordSerializer(const ZLibRecordSerializer & rhs);
  boost::int32_t GetMinimumSize() const
  {
    return mMinSize;
  }
  /**
   * Serialize the recordBuffer into the target serializationBuffer.  If the serializationBuffer
   * is not big enough then return -1.  Note that in this case the serializationBuffer may have been modified.
   */
  METRAFLOW_DECL boost::uint8_t * Serialize(const_record_t recordBuffer, z_stream& compressedStream);
};

class ZLibRecordDeserializer
{
private:  
  std::vector<RecordDeserializerInstruction> mInstructions;
  boost::uint8_t * mTemp;
  boost::int32_t mTempSize;
  
  //
  // Execution iterator state
  //

  // Possible program counter values
  enum State { PC_NEW_RECORD, PC_DIRECT_MEMCPY, PC_INDIRECT_MEMCPY_LENGTH, PC_INDIRECT_MEMCPY };
  State mProgramCounter;
  // Output record buffer byte Iterator
  boost::uint8_t * mTarget;
  // Size of a variable length buffer
  boost::int32_t mIndirectBufferSize;
  // Iterator over deserialization instructions
  std::vector<RecordDeserializerInstruction>::iterator mIt;
  // ZLib Result 
  int mResult;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mInstructions);
    ar & BOOST_SERIALIZATION_NVP(mTemp);
  }  
  METRAFLOW_DECL ZLibRecordDeserializer();
public:
  METRAFLOW_DECL ZLibRecordDeserializer(const RecordMetadata & metadata);
  METRAFLOW_DECL ZLibRecordDeserializer(const ZLibRecordDeserializer & rhs);
  METRAFLOW_DECL ~ZLibRecordDeserializer();
  // Returns the amount of the serializationBuffer consumed.
  METRAFLOW_DECL int Deserialize(z_stream& compressedStream, record_t recordBuffer);
};

class ZLibBufferDearchive
{
private:
  boost::int32_t mNumRecords;
  z_stream mCompressedStream;
  ZLibRecordDeserializer mDeserializer;
public:
  METRAFLOW_DECL ZLibBufferDearchive(const RecordMetadata& metadata);
  METRAFLOW_DECL ZLibBufferDearchive(const ZLibBufferDearchive& rhs);
  METRAFLOW_DECL ~ZLibBufferDearchive();
  METRAFLOW_DECL void Bind(boost::uint8_t * start, boost::uint8_t * end);
  METRAFLOW_DECL boost::uint8_t * Unbind();
  METRAFLOW_DECL boost::int32_t Deserialize(MessagePtr & m);
  METRAFLOW_DECL boost::int32_t GetNumRecords() const;
};

class ZLibBufferArchive
{
private:
  boost::uint8_t * mStart;
  boost::int32_t mMessageRecords;
  z_stream mCompressedStream;
  ZLibRecordSerializer mSerializer;
  bool mCompressorState;
public:
  METRAFLOW_DECL ZLibBufferArchive(const RecordMetadata& metadata);
  METRAFLOW_DECL ZLibBufferArchive(const ZLibBufferArchive& rhs);
  METRAFLOW_DECL ~ZLibBufferArchive();
  METRAFLOW_DECL void Bind(boost::uint8_t * start, boost::uint8_t * end);
  METRAFLOW_DECL boost::uint8_t * Unbind();
  METRAFLOW_DECL boost::uint8_t * Serialize(MessagePtr m);
  METRAFLOW_DECL bool CanPush() const;
};

class RawRecordSerializer
{
private:  
  std::vector<FieldAddress> mPrefetch;
  std::vector<RecordSerializerInstruction> mInstructions;
  boost::int32_t mMinSize;
  
  //
  // RawRecordSerializer iterator state
  //
  static const boost::int32_t inPlaceNull=-1;
  enum State {PC_NEW_RECORD, PC_SERIALIZE_OUTPUT_EXHAUSTED, PC_SERIALIZE_NOT_NULL_MARKER, PC_SERIALIZE_NULL_MARKER};

  State mProgramCounter;
  std::stack<std::pair<const_record_t, const_record_t> > mSource;
  std::stack<std::pair<const_record_t, const_record_t> > mIteration;
  // Amount of source consumed
  boost::int32_t mSourceIncrement;
  // Input buffer(s) to memcpy into output buffer
  struct MemcpyOperation
  {
    const boost::uint8_t * Buffer;
    boost::int32_t BufferLength;
  };
  MemcpyOperation mOperationBuffer[2];
  MemcpyOperation * mOperationBegin;
  MemcpyOperation * mOperationEnd;
  MemcpyOperation * mOperationIt;

  std::vector<RecordSerializerInstruction>::const_iterator mIt;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mPrefetch);
    ar & BOOST_SERIALIZATION_NVP(mInstructions);
    ar & BOOST_SERIALIZATION_NVP(mMinSize);
  }  
  METRAFLOW_DECL RawRecordSerializer();

  void Generate(const RecordMetadata & metadata);
public:
  METRAFLOW_DECL RawRecordSerializer(const RecordMetadata & metadata);
  METRAFLOW_DECL RawRecordSerializer(const RawRecordSerializer & rhs);
  boost::int32_t GetMinimumSize() const
  {
    return mMinSize;
  }
  /**
   * Serialize the recordBuffer into the target serializationBuffer.  If the serializationBuffer
   * is not big enough then return -1.  Note that in this case the serializationBuffer may have been modified.
   */
  METRAFLOW_DECL boost::uint8_t * Serialize(const_record_t recordBuffer, boost::uint8_t *& bufferBegin, boost::uint8_t * bufferEnd);
};

class RawRecordDeserializer
{
private:  
  std::vector<RecordDeserializerInstruction> mInstructions;
  boost::uint8_t * mTemp;
  boost::int32_t mTempSize;
  
  //
  // Execution iterator state
  //

  // Possible program counter values
  enum State { PC_NEW_RECORD, PC_DIRECT_MEMCPY, PC_INDIRECT_MEMCPY_LENGTH, PC_INDIRECT_MEMCPY, NESTED_RECORD_START_NULL_MARKER};
  State mProgramCounter;
  // Output record buffer byte Iterator
  std::stack<std::pair<boost::uint8_t *, boost::uint8_t *> > mTarget;
  // Size of a variable length buffer
  boost::int32_t mIndirectBufferSize;
  // Iterator over deserialization instructions
  std::vector<RecordDeserializerInstruction>::iterator mIt;
  // "Stack" for memcpy iterators
  // Destination of memcpy (source is the buffer argument)
  boost::uint8_t * mMemcpyTarget;
  // Length of memcpy
  boost::int32_t mMemcpyLength;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mInstructions);
    ar & BOOST_SERIALIZATION_NVP(mTemp);
  }  
  METRAFLOW_DECL RawRecordDeserializer();

  void Generate(const RecordMetadata& metadata);
public:
  METRAFLOW_DECL RawRecordDeserializer(const RecordMetadata & metadata);
  METRAFLOW_DECL RawRecordDeserializer(const RawRecordDeserializer & rhs);
  METRAFLOW_DECL ~RawRecordDeserializer();
  // Returns the amount of the serializationBuffer consumed.
  METRAFLOW_DECL int Deserialize(const boost::uint8_t *& bufferBegin, const boost::uint8_t * bufferEnd, record_t recordBuffer);
};

class RawBufferDearchive
{
private:
  boost::int32_t mNumRecords;
  const boost::uint8_t * mBufferIt;
  const boost::uint8_t * mBufferEnd;
  RawRecordDeserializer mDeserializer;
  bool mIsClosed;
public:
  METRAFLOW_DECL RawBufferDearchive(const RecordMetadata& metadata);
  METRAFLOW_DECL RawBufferDearchive(const RawBufferDearchive& rhs);
  METRAFLOW_DECL ~RawBufferDearchive();
  METRAFLOW_DECL void Bind(const boost::uint8_t * start, const boost::uint8_t * end);
  METRAFLOW_DECL const boost::uint8_t * Unbind();
  METRAFLOW_DECL boost::int32_t Deserialize(MessagePtr & m);
  METRAFLOW_DECL boost::int32_t GetNumRecords() const;
};

class RawBufferArchive
{
private:
  boost::uint8_t * mStart;
  boost::int32_t mMessageRecords;
  boost::uint8_t * mBufferIt;
  boost::uint8_t * mBufferEnd;
  RawRecordSerializer mSerializer;
  bool mIsClosed;
public:
  METRAFLOW_DECL RawBufferArchive(const RecordMetadata& metadata);
  METRAFLOW_DECL RawBufferArchive(const RawBufferArchive& rhs);
  METRAFLOW_DECL ~RawBufferArchive();
  METRAFLOW_DECL void Bind(boost::uint8_t * start, boost::uint8_t * end);
  METRAFLOW_DECL boost::uint8_t * Unbind();
  METRAFLOW_DECL boost::uint8_t * Serialize(MessagePtr m, bool isEOF);
  METRAFLOW_DECL bool CanPush() const;
};

#endif
