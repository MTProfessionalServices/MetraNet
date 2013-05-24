#ifndef __RECORDPARSER_H__
#define __RECORDPARSER_H__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
# pragma once
#endif

#ifdef WIN32
#include <metra.h>
#else
#include "metralite.h"
#endif
#include <string>
#include <vector>
#include <map>
#include <exception>
#include <stdexcept>
#include <ostream>
#include <limits.h>
#include "MetraFlowConfig.h"
#include "RecordModel.h"
#include "LogAdapter.h"
#include "ImportFunction.h"
#include "Scheduler.h"
#include "StdioBuffer.h"
#define ZLIB_DLL
#include "zlib.h"

class MTSQLInterpreter;
class MTSQLExecutable;
class Frame;
class RecordActivationRecord;
class RecordActivationRecord;
class DualCompileEnvironment;
class DualRuntimeEnvironment;


class MappedFile;
class MappedBuffer;
class COdbcIdGenerator;
class COdbcLongIdGenerator;
class COdbcPreparedBcpStatement;
class COdbcPreparedArrayStatement;
class COdbcPreparedResultSet;
class COdbcConnection;
class COdbcColumnMetadata;
class ImportFunction;
class CacheConsciousHashTable;
class CacheConsciousHashTableIterator;
class CacheConsciousHashTableInsertIteratorBase;
class CacheConsciousHashTableUniqueInsertIterator;
class CacheConsciousHashTableNonUniqueInsertIterator;
class CacheConsciousHashTableScanIterator;
class CacheConsciousHashTablePredicateIterator;

class CacheAlignedMalloc
{
private:
  std::vector<boost::uint8_t *> mAllocatedBuffers;
  std::vector<boost::uint8_t *> mCacheAlignedBuffers;
  std::size_t mSpaceRemaining;
  std::size_t mBufferSpace;
  std::size_t mTotalAllocatedSpace;

  enum { _CacheLineSizeLog2 = 7, 
         _CacheLineSize = 128, 
         _BufferSize = 64*1024 };

public:
  METRAFLOW_DECL CacheAlignedMalloc();
  METRAFLOW_DECL ~CacheAlignedMalloc();
  METRAFLOW_DECL void * malloc(std::size_t sz);
  METRAFLOW_DECL std::size_t GetAllocatedSize() const;
};

#ifdef WIN32
class Win32Exception : public std::runtime_error
{
private:
	DWORD mErr;
  std::string mFile;
  int mLine;
  std::string mWhat;

	static std::string ToString(const char * fun, DWORD dwErr, const char * file, int line);
public:
	METRAFLOW_DECL Win32Exception(const char * msg, DWORD dwErr, const char * file, int line);
};

class SystemInfo
{
public:
  METRAFLOW_DECL static int GetAllocationGranularity();
};

class MappedFile
{
private:
  HANDLE mFile;
  HANDLE mFileMapping;
  boost::int64_t mFileSize;
public:
  METRAFLOW_DECL MappedFile(const std::wstring & filename);
  METRAFLOW_DECL ~MappedFile();
  // I want an API for sequential access to a file that uses
  // memory mapped views.  The sequential access is represented
  // by a stream of mapped views of the file.  One of the tricks
  // is that we want the stream of views to not necessarily be
  // non-overlapping.  This is because a client may be parsing and
  // a token may straddle two views.  The API allows a client of the
  // stream to advance the window on the file making sure that the
  // current position is still available.
  METRAFLOW_DECL void Map(boost::int64_t offset, int size, MappedBuffer * buffer);
  METRAFLOW_DECL boost::int64_t GetFileSize() const
  {
    return mFileSize;
  }
};
#endif

class mapped_file
{
public:
  typedef boost::uint64_t offset;
private:
  HANDLE mFile;
  HANDLE mFileMapping;
  boost::uint64_t mFileSize;
public:
  METRAFLOW_DECL mapped_file(const std::wstring & filename);
  METRAFLOW_DECL ~mapped_file();
  METRAFLOW_DECL void open(boost::uint64_t offset, std::size_t& sz, boost::uint8_t *& view);
  METRAFLOW_DECL void release(boost::uint8_t * view);
  boost::uint64_t size() const
  {
    return mFileSize;
  }
  METRAFLOW_DECL std::size_t granularity() const;
};

// Encapsulates a memory mapped region of a file.  This maintains information about
// the region itself (base pointer and size) as well as a position within the buffer.
class MappedBuffer
{
private:
  unsigned char * mViewBase;
  unsigned char * mViewPosition;
  int mBytesAvailable;
public:
  METRAFLOW_DECL MappedBuffer();
  METRAFLOW_DECL ~MappedBuffer();
  METRAFLOW_DECL void Clear();
  METRAFLOW_DECL void Init(unsigned char * viewBase, int size);
  METRAFLOW_DECL void Init(unsigned char * viewBase, int position, int size);

  // Relative read methods
  // Read from the current view position and increment position
  METRAFLOW_DECL void Read(unsigned char * buffer, int size)
  {
    if (mBytesAvailable < size) 
    {
      throw std::exception("MappedBuffer::Read: Buffer overrun");
    }
    memcpy(buffer, mViewPosition, size);
    mViewPosition += size;
    mBytesAvailable -= size;
  }
  METRAFLOW_DECL int GetPosition() const 
  {
    return mViewPosition - mViewBase;
  }
  int GetAvailable() const
  {
    return mBytesAvailable;
  }
  METRAFLOW_DECL int GetSize() const
  {
    return mBytesAvailable + GetPosition();
  }
  const unsigned char * GetBuffer() const
  {
    return mViewPosition;
  }
  void Advance(int bytes)
  {
    mViewPosition += bytes;
    mBytesAvailable -= bytes;
  }
};

class MappedInputStream
{
private:
  MappedFile * mFileMapping;
  // Minimum size of view window to pass over the file
  int mViewSize;
  // Offset of current view into the file
  boost::int64_t mOffset;
  // Current view
  MappedBuffer mView;
public:
  METRAFLOW_DECL MappedInputStream(MappedFile * fileMapping, int viewSize);
  METRAFLOW_DECL ~MappedInputStream();
  // Guarantees that viewSize bytes starting at current position
  // are currently mapped in.
  METRAFLOW_DECL void OpenWindow(int viewSize);
  const unsigned char * GetBuffer() const
  {
    return mView.GetBuffer();
  }
  int GetAvailable() const
  {
    return mView.GetAvailable();
  }
  METRAFLOW_DECL void OpenWindow()
  {
    OpenWindow(mViewSize);
  }
  METRAFLOW_DECL void Read(unsigned char * buffer, int size)
  {
    if(size <= mView.GetAvailable())
    {
      mView.Read(buffer, size);
      return;
    }
    else
    {
      OpenWindow(size);
      mView.Read(buffer, size);
      return;
    }
  }
  bool IsEOF() const
  {
    return mOffset + mView.GetPosition() == mFileMapping->GetFileSize();
  }
  void Consume(int sz)
  {
    mView.Advance(sz);
  }
};

/** 
 * Small abstraction around ZLIB stdio stuff to make it suitable as a template
 * parameter.
 */
class ZLIBFile
{
private:
  gzFile mFile;
  bool mEOF;
public:
  METRAFLOW_DECL ZLIBFile(const wstring& filename, bool forWriting = false);
  METRAFLOW_DECL ~ZLIBFile();
  METRAFLOW_DECL void read(std::size_t& sz, boost::uint8_t * buffer);
  METRAFLOW_DECL void write(boost::uint8_t * buffer, std::size_t sz);
  METRAFLOW_DECL std::size_t granularity() const;
  METRAFLOW_DECL bool is_eof() const;
};

// A hash table that tries to be cache conscious.
// This is not thread safe.
class CacheConsciousHashTable
{
public:
  friend class CacheConsciousHashTableIterator;
  friend class CacheConsciousHashTablePredicateIterator;
  friend class CacheConsciousHashTableScanIterator;
  friend class CacheConsciousHashTableInsertIteratorBase;

  enum { _CacheLineSizeLog2 = 7, _CacheLineSize = 128, _HashSentinelPosition=_CacheLineSize/(2*sizeof (unsigned int)) - 1 };
  // We store full 32-bit hash values and payloads in nodes.
  // To find out if one really has a match, one has to look at the
  // payload/value.  Given a good hash function one will rarely get a false
  // match (collision) on the full hash value.
  // Invalid TablePairs will have a NULL payload.
  // A node that equals a cache line.
  // A node is filled from front to back.
  class CacheLineNode
  {
  public:
    unsigned int FullHashValues[_CacheLineSize/(2*sizeof (unsigned int))];
    unsigned char * Values[_CacheLineSize/(2*sizeof (unsigned int)) - 1];
    CacheLineNode * Next;
  };
private:
  bool mOwnRecords;
  int mNumBuckets;
  CacheLineNode * mBuckets;
  int mNumRecords;
  int mMaxLoadFactor;
  MetraFlowLoggerPtr mLogger;

  CacheAlignedMalloc * mRegionAllocator;
  CacheLineNode * AllocateNode(int arraySz=1)
  {
    int sz = arraySz * sizeof(CacheLineNode);
    return reinterpret_cast<CacheLineNode *>(mRegionAllocator->malloc(sz));
  }

  
  std::vector<DataAccessor *> mTableKeys;
  const RecordMetadata * mMetadata;
  
public:
  METRAFLOW_DECL CacheConsciousHashTable(const std::vector<DataAccessor *>& tableKeys, 
                                    int numBuckets=32);
  METRAFLOW_DECL CacheConsciousHashTable(const std::vector<DataAccessor *>& tableKeys,
                                    const RecordMetadata& metadata,
                                    bool ownMetadata = true,
                                    int numBuckets=32);
  METRAFLOW_DECL ~CacheConsciousHashTable();
  METRAFLOW_DECL void Find(const_record_t recordBuffer, CacheConsciousHashTableIterator& it);
  METRAFLOW_DECL void Find(const_record_t recordBuffer, CacheConsciousHashTablePredicateIterator& it);
  METRAFLOW_DECL void Insert(record_t recordBuffer, CacheConsciousHashTableInsertIteratorBase& it);
  METRAFLOW_DECL void Scan(const_record_t recordBuffer, CacheConsciousHashTableScanIterator& it);
  METRAFLOW_DECL int GetTotalAllocatedSize() const;
  METRAFLOW_DECL int GetNumRecords() const;
  METRAFLOW_DECL MetraFlowLoggerPtr GetLogger() const { return mLogger; }
};

class CacheConsciousHashTableIteratorBase
{
protected:
  CacheConsciousHashTable& mTable;
  CacheConsciousHashTable::CacheLineNode * mNode;
  bool mStutter;
  unsigned int mFullHashValue;
  unsigned int * mFullHashPtr;
  unsigned int * mStartPtr;
  const unsigned char * mRecordBuffer;

  enum State { START, NEXT, DONE };
  State mState;

  CacheConsciousHashTable::CacheLineNode * GetCurrentNode() const
  {
    return mStutter ? mNode : mNode->Next;
  }

  void AdvanceNode()
  {
    mNode = GetCurrentNode();
    mStutter = false;
  }
public: 
  METRAFLOW_DECL CacheConsciousHashTableIteratorBase(CacheConsciousHashTable& table);
  METRAFLOW_DECL virtual ~CacheConsciousHashTableIteratorBase() {}

  METRAFLOW_DECL void Init(CacheConsciousHashTable::CacheLineNode * node, const_record_t recordBuffer, unsigned int fullHashValue);

  METRAFLOW_DECL bool IsEnd() const;

  METRAFLOW_DECL unsigned char * Get() 
  {
    CacheConsciousHashTable::CacheLineNode * n = GetCurrentNode();
    return n == NULL || *mFullHashPtr == 0 ? NULL : n->Values[mFullHashPtr-mStartPtr];
  }

  unsigned int GetFullHashValue() const
  {
    CacheConsciousHashTable::CacheLineNode * n = GetCurrentNode();
    return n == NULL || *mFullHashPtr == 0 ? 0 : n->FullHashValues[mFullHashPtr-mStartPtr];
  }

  // This is structured as a "Coroutine in C".  For this see http://www.chiark.greenend.org.uk/~sgtatham/coroutines.html
  METRAFLOW_DECL bool GetNext();

  METRAFLOW_DECL virtual void Find(const_record_t recordBuffer);

  virtual bool Equals(const_record_t probeBuffer, const_record_t tableBuffer)=0;
  virtual unsigned int Hash(const_record_t recordBuffer)=0;
};

class CacheConsciousHashTableInsertIteratorBase : public CacheConsciousHashTableIteratorBase
{
protected:
  friend class CacheConsciousHashTable;

  std::vector<DataAccessor *> mTableKeys;

public:
  METRAFLOW_DECL CacheConsciousHashTableInsertIteratorBase(CacheConsciousHashTable& table);

  unsigned int Hash(const_record_t recordBuffer)
  {
    unsigned int fullHashValue=0;
    for(std::vector<DataAccessor *>::iterator it = mTableKeys.begin();
        it != mTableKeys.end();
        it++)
    {
      fullHashValue = (*it)->Hash(recordBuffer, fullHashValue);
    }
    return fullHashValue;
  }
};

class CacheConsciousHashTableUniqueInsertIterator : public CacheConsciousHashTableInsertIteratorBase
{
public:
  METRAFLOW_DECL CacheConsciousHashTableUniqueInsertIterator(CacheConsciousHashTable& table);

  bool Equals(const_record_t probeBuffer, const_record_t tableBuffer)
  {
    for(std::vector<DataAccessor *>::iterator table = mTableKeys.begin(); 
        table != mTableKeys.end(); 
        table++)
    {
      if (false == (*table)->Equals(probeBuffer, *table, tableBuffer)) return false;
    }
    return true;
  }  
};

class CacheConsciousHashTableNonUniqueInsertIterator : public CacheConsciousHashTableInsertIteratorBase
{
public:
  METRAFLOW_DECL CacheConsciousHashTableNonUniqueInsertIterator(CacheConsciousHashTable& table);

  bool Equals(const_record_t probeBuffer, const_record_t tableBuffer)
  {
    return probeBuffer == tableBuffer;
  }  
};

class CacheConsciousHashTableIterator : public CacheConsciousHashTableIteratorBase
{
private:
  friend class CacheConsciousHashTable;

  std::vector<DataAccessor *> mProbeKeys;
  std::vector<DataAccessor *> mTableKeys;

public:
  METRAFLOW_DECL CacheConsciousHashTableIterator(CacheConsciousHashTable& table, const std::vector<DataAccessor *>& probeKeys);

  METRAFLOW_DECL void Find(const_record_t recordBuffer);

  bool Equals(const_record_t probeBuffer, const_record_t tableBuffer)
  {
    std::vector<DataAccessor *>::iterator probe = mProbeKeys.begin();
    std::vector<DataAccessor *>::iterator table = mTableKeys.begin();
    for(; probe != mProbeKeys.end(); probe++, table++)
    {
      if (false == (*probe)->Equals(probeBuffer, *table, tableBuffer)) return false;
    }
    return true;
  }

  unsigned int Hash(const_record_t recordBuffer)
  {
    unsigned int fullHashValue=0;
    for(std::vector<DataAccessor *>::iterator it = mProbeKeys.begin();
        it != mProbeKeys.end();
        it++)
    {
      fullHashValue = (*it)->Hash(recordBuffer, fullHashValue);
    }
    return fullHashValue;
  }
};

class CacheConsciousHashTableScanIterator
{
private:
  friend class CacheConsciousHashTable;
  const CacheConsciousHashTable * mTable;
  int mCurrentBucket;
  CacheConsciousHashTable::CacheLineNode * mNode;
  bool mStutter;
  unsigned int mFullHashValue;
  unsigned int * mFullHashPtr;
  unsigned int * mStartPtr;

  enum State { START, NEXT, DONE };
  State mState;

  CacheConsciousHashTable::CacheLineNode * GetCurrentNode() const
  {
    return mStutter ? mNode : mNode->Next;
  }

  void AdvanceNode()
  {
    mNode = GetCurrentNode();
    mStutter = false;
  }
  
public:
  METRAFLOW_DECL CacheConsciousHashTableScanIterator(CacheConsciousHashTable& table);

  METRAFLOW_DECL void Init();

  METRAFLOW_DECL unsigned char * Get() 
  {
    CacheConsciousHashTable::CacheLineNode * n = GetCurrentNode();
    return n == NULL || *mFullHashPtr == 0 ? NULL : n->Values[mFullHashPtr-mStartPtr];
  }
  unsigned int GetFullHashValue() 
  {
    CacheConsciousHashTable::CacheLineNode * n = GetCurrentNode();
    return n == NULL || *mFullHashPtr == 0 ? 0 : n->FullHashValues[mFullHashPtr-mStartPtr];
  }

  // This is structured as a "Coroutine in C".  For this see http://www.chiark.greenend.org.uk/~sgtatham/coroutines.html
  METRAFLOW_DECL bool GetNext();
};

class CacheConsciousHashTablePredicateIterator : public CacheConsciousHashTableIteratorBase
{
private:
  friend class CacheConsciousHashTable;

  // The equijoin keys for computing the hash value
  std::vector<DataAccessor *> mProbeKeys;
  std::vector<DataAccessor *> mTableKeys;

  // The MTSQL program representing the residual predicate
	MTSQLInterpreter* mInterpreter;
	MTSQLExecutable* mExe;
  Frame * mProbeFrame;
  Frame * mTableFrame;
  RecordActivationRecord * mProbeActivationRecord;
  RecordActivationRecord * mTableActivationRecord;
	DualCompileEnvironment * mEnv;
  DualRuntimeEnvironment * mRuntime;

public:
  METRAFLOW_DECL CacheConsciousHashTablePredicateIterator(CacheConsciousHashTable& table, 
                                                     const std::vector<DataAccessor *>& probeKeys, 
                                                     const RecordMetadata& probeResidual, 
                                                     const RecordMetadata& tableResidual, 
                                                     const std::wstring& predicate);

  METRAFLOW_DECL ~CacheConsciousHashTablePredicateIterator();

  METRAFLOW_DECL void Find(const_record_t recordBuffer);
  bool Equals(const_record_t probeBuffer, const_record_t tableBuffer);
  unsigned int Hash(const_record_t recordBuffer);

  static void Compile(const RecordMetadata& probeResidual, 
                      const RecordMetadata& tableResidual, 
                      const std::wstring& predicate);
};

class DesignTimeRecordImporter : public DesignTimeOperator, Import_Format_Error_Sink
{
private:
  std::wstring mFilename;
  std::wstring mFormat;
  bool mCompression;
  bool mIsHeaderPresent;
  std::wstring mCollectionID;

public:
  METRAFLOW_DECL DesignTimeRecordImporter();
  METRAFLOW_DECL ~DesignTimeRecordImporter();
  METRAFLOW_DECL void SetFilename(const std::wstring& filename);
  METRAFLOW_DECL void SetFormat(const std::wstring& format);
  METRAFLOW_DECL void SetCompression(bool compression);
  METRAFLOW_DECL void SetIsHeaderPresent(bool isHeaderPresent);
  METRAFLOW_DECL void SetCollectionID(const std::wstring& collectionID);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);  

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeRecordImporter* clone(
                                          const std::wstring& name,
                                          std::vector<OperatorArg*>& args, 
                                          int nInputs, int nOutputs) const;
  /** Handle an error processing the import format. */
  METRAFLOW_DECL void ThrowError(const std::wstring& err);
};

template <class _Buffer>
class RunTimeRecordImporter : public RunTimeOperator
{
public:
  // TODO: Correct syntax to make the template a friend.  For now just make everything public.
//   friend template <class _T> class RunTimeRecordImporterActivation<_T>;
// private:
  std::wstring mFormat;
  std::wstring mFilename;
  boost::int32_t mViewSize;
  bool mIsHeaderPresent;
  std::wstring mCollectionID;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mFormat);
    ar & BOOST_SERIALIZATION_NVP(mFilename);
    ar & BOOST_SERIALIZATION_NVP(mViewSize);
    ar & BOOST_SERIALIZATION_NVP(mIsHeaderPresent);
    ar & BOOST_SERIALIZATION_NVP(mCollectionID);
  } 
  METRAFLOW_DECL RunTimeRecordImporter();
  
public:
  METRAFLOW_DECL RunTimeRecordImporter (const std::wstring& name, 
                                        const std::wstring& format,
                                        const std::wstring& filename,
                                        boost::int32_t viewSize,
                                        bool isHeaderPresent,
                                        const std::wstring& collectionID);
  METRAFLOW_DECL ~RunTimeRecordImporter();
  
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

template <class _Buffer>
class RunTimeRecordImporterActivation : public RunTimeOperatorActivationImpl<RunTimeRecordImporter<_Buffer> >, Import_Format_Error_Sink
{
private:
  enum State { START, WRITE_0 };
  typename _Buffer::file_type * mFileMapping;
  _Buffer * mStream;
  // Importers for all records
  UTF8_Import_Function_Builder_2<_Buffer> * mImporter;
  State mState;
  // The output message
  MessagePtr mOutputRecord;
  unsigned int mNumberOfImportedRecords;
  
  /** 
   *  If non-zero, indicates number of expected records in the
   *  file being imported as specified by the starting integer
   *  in the file.
   */
  unsigned int mNumberOfExpectedRecords;

  /** 
   *  Read the expected number of records from the top of the file.
   *  This should be an integer followed by carriage return and line feed.
   *  This advances our position in the file.
   *  Return true on success and store the expected number of records
   *  in the result reference parameter.
   */
  METRAFLOW_DECL int GetRowCount(const std::string &fullFileName);

  /** 
   *   Return the total number of existing records in the file.
   */
  METRAFLOW_DECL bool GetInt(const std::string &fullFileName, unsigned int& result);

  /**
   * Insert a t_batch row indicating the number of number
   * of records that are expected in the batch.
   */
  void CreateBatch();

public:
  METRAFLOW_DECL RunTimeRecordImporterActivation (Reactor * reactor, 
                                                  partition_t partition,
                                                  const RunTimeRecordImporter<_Buffer> * runTimeOperator);
  METRAFLOW_DECL ~RunTimeRecordImporterActivation();
  
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
  /** Handle an error processing the import format. */
  METRAFLOW_DECL void ThrowError(const std::wstring& err);
};

class DesignTimeRecordExporter : public DesignTimeOperator, Import_Format_Error_Sink
{
private:
  std::wstring mFilename;
  std::wstring mFormat;
  bool mCompression;

public:
  METRAFLOW_DECL DesignTimeRecordExporter();
  METRAFLOW_DECL ~DesignTimeRecordExporter();
  METRAFLOW_DECL void SetFilename(const std::wstring& filename);
  METRAFLOW_DECL void SetFormat(const std::wstring& format);
  METRAFLOW_DECL void SetCompression(bool compression);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);  

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeRecordExporter* clone(
                                          const std::wstring& name,
                                          std::vector<OperatorArg*>& args, 
                                          int nInputs, int nOutputs) const;
  /** Handle an error processing the import format. */
  METRAFLOW_DECL void ThrowError(const std::wstring& err);
};

template <class _Buffer>
class RunTimeRecordExporter : public RunTimeOperator
{
public:
// TODO: Correct syntax to make the template a friend.
//   friend template <class _T> class RunTimeRecordExporterActivation<_T>;
// private:
  std::wstring mFormat;
  std::wstring mFilename;
  boost::int32_t mViewSize;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mFormat);
    ar & BOOST_SERIALIZATION_NVP(mFilename);
    ar & BOOST_SERIALIZATION_NVP(mViewSize);
  } 
  METRAFLOW_DECL RunTimeRecordExporter();
  
public:
  METRAFLOW_DECL RunTimeRecordExporter (const std::wstring& name, 
                                        const std::wstring& format,
                                        const std::wstring& filename,
                                        boost::int32_t viewSize);
  METRAFLOW_DECL ~RunTimeRecordExporter();
  
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

template <class _Buffer>
class RunTimeRecordExporterActivation : public RunTimeOperatorActivationImpl<RunTimeRecordExporter<_Buffer> >, Import_Format_Error_Sink
{
private:
  enum State { START, READ_0 };
  typename _Buffer::file_type * mFileMapping;
  _Buffer * mStream;
  // Exporters for all records
  UTF8_Export_Function_Builder_2<_Buffer> * mExporter;
  State mState;
  // The output message
  MessagePtr mOutputRecord;
public:
  METRAFLOW_DECL RunTimeRecordExporterActivation (Reactor * reactor, 
                                                  partition_t partition,
                                                  const RunTimeRecordExporter<_Buffer> * runTimeOperator);
  METRAFLOW_DECL ~RunTimeRecordExporterActivation();
  
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
  /** Handle an error processing the import format. */
  METRAFLOW_DECL void ThrowError(const std::wstring& err);
};

// TODO: Shouldn't the STL provide this?
template <class _T>
class ReverseArrayIterator : public std::iterator_traits<_T*>
{
private:
  typename std::iterator_traits<_T*>::pointer mPtr;
public:
  ReverseArrayIterator()
    :
    mPtr(NULL)
  {
  }
  ReverseArrayIterator(typename std::iterator_traits<_T*>::pointer p)
    :
    mPtr(p)
  {
  }
  ReverseArrayIterator(const ReverseArrayIterator& rhs)
    :
    mPtr(rhs.mPtr)
  {
  }
  ReverseArrayIterator& operator= (const ReverseArrayIterator& rhs)
  {
    mPtr = rhs.mPtr;
    return *this;
  }
  typename std::iterator_traits<_T*>::reference operator* () const
  {
    return *mPtr;
  }
  typename std::iterator_traits<_T*>::pointer operator-> () const
  {
    return mPtr;
  }
  ReverseArrayIterator operator+ (typename std::iterator_traits<_T*>::difference_type n) const
  {
    return ReverseArrayIterator(mPtr - n);
  }
  ReverseArrayIterator& operator+= (typename std::iterator_traits<_T*>::difference_type n)
  {
    mPtr -= n;
    return *this;
  }
  ReverseArrayIterator& operator++( )
  {
    mPtr--;
    return *this;
  } 
  ReverseArrayIterator operator++( int )
  {
    ReverseArrayIterator tmp(mPtr--);
    return tmp;
  }
  // I haven't yet made the above iterator in an STL conforming
  // one, so I'll provide the subtraction.  TODO: I think I can eliminate
  // this now?
  typename std::iterator_traits<_T*>::difference_type operator- (const ReverseArrayIterator& rhs) const
  {
    return rhs.mPtr - mPtr;
  }

  ReverseArrayIterator operator- (typename std::iterator_traits<_T*>::difference_type n) const
  {
    return ReverseArrayIterator(mPtr + n);
  }
  ReverseArrayIterator& operator-= (typename std::iterator_traits<_T*>::difference_type n)
  {
    mPtr += n;
    return *this;
  }
  ReverseArrayIterator& operator--( )
  {
    mPtr++;
    return *this;
  } 
  ReverseArrayIterator operator--( int )
  {
    ReverseArrayIterator tmp(mPtr++);
    return tmp;
  }
  bool operator<= (const ReverseArrayIterator& rhs) const
  {
    return mPtr >= rhs.mPtr;
  }
  bool operator< (const ReverseArrayIterator& rhs) const
  {
    return mPtr > rhs.mPtr;
  }
  bool operator>= (const ReverseArrayIterator& rhs) const
  {
    return mPtr <= rhs.mPtr;
  }
  bool operator> (const ReverseArrayIterator& rhs) const
  {
    return mPtr < rhs.mPtr;
  }
  bool operator== (const ReverseArrayIterator& rhs) const
  {
    return mPtr == rhs.mPtr;
  }
  bool operator!= (const ReverseArrayIterator& rhs) const
  {
    return mPtr != rhs.mPtr;
  }
};

template <class _Iterator>
class PointerBaseTraits
{
public:
  typedef _Iterator iterator;
  typedef boost::uint8_t value_type;
  typedef boost::uint8_t& reference;
  typedef boost::uint8_t* pointer;
  typedef boost::uint8_t * base_type;

  reference dereference(base_type const b, const _Iterator& it) const
  {
    return *reinterpret_cast<pointer>(b + *it);
  }
  pointer get_pointer(base_type const b, const _Iterator& it) const
  {
    return reinterpret_cast<pointer>(b + *it);
  }
};

template <class _Iterator, class _T>
class PointerBaseOffsetTraits 
{
public:
  typedef _Iterator iterator;
  typedef _T  value_type;
  typedef _T& reference;
  typedef _T* pointer;
  typedef boost::uint8_t * base_type;

private:
  std::size_t mOffset;
public:
  PointerBaseOffsetTraits(std::size_t offset=0)
    :
    mOffset(offset)
  {
  }

  reference dereference(base_type const b, const _Iterator& it) const
  {
    return *reinterpret_cast<pointer>(b + *it + mOffset);
  }
  pointer get_pointer(base_type const b, const _Iterator& it) const
  {
    return reinterpret_cast<pointer>(b + *it + mOffset);
  }
};

template <class _Base, class _BaseTraitsType>
class BaseOffsetIterator
{
public:
  typedef typename _BaseTraitsType::iterator base_iterator;

  typedef std::random_access_iterator_tag iterator_category;
  typedef typename _BaseTraitsType::value_type value_type;
  typedef typename _BaseTraitsType::iterator::difference_type difference_type;
  typedef typename _BaseTraitsType::pointer pointer;
  typedef typename _BaseTraitsType::reference reference;

  typedef _Base base_type;
  typedef _BaseTraitsType base_traits_type;
private:
  base_type mPage;
  base_iterator mIterator;
  base_traits_type mTraits;
public:
  BaseOffsetIterator(const base_traits_type& traits = _BaseTraitsType())
    :
    mTraits(traits)
  {
  }
  BaseOffsetIterator(const base_type& page, const base_iterator& p, const base_traits_type& traits = _BaseTraitsType())
    :
    mPage(page),
    mIterator(p),
    mTraits(traits)
  {
  }
  BaseOffsetIterator(const BaseOffsetIterator& rhs)
    :
    mPage(rhs.mPage),
    mIterator(rhs.mIterator),
    mTraits(rhs.mTraits)
  {
  }
  BaseOffsetIterator& operator= (const BaseOffsetIterator& rhs)
  {
    mPage = rhs.mPage;
    mIterator = rhs.mIterator;
    mTraits = rhs.mTraits;
    return *this;
  }
  reference operator* () const
  {
    return mTraits.dereference(mPage, mIterator);
  }
  pointer operator-> () const
  {
    return mTraits.get_pointer(mPage, mIterator);
  }
  BaseOffsetIterator operator+ (difference_type n) const
  {
    return BaseOffsetIterator(mPage, mIterator + n);
  }
  BaseOffsetIterator& operator+= (difference_type n)
  {
    mIterator += n;
    return *this;
  }
  BaseOffsetIterator& operator++( )
  {
    ++mIterator;
    return *this;
  } 
  BaseOffsetIterator operator++( int )
  {
    BaseOffsetIterator tmp(mPage, mIterator++, mTraits);
    return tmp;
  }
  // I haven't yet made the above iterator in an STL conforming
  // one, so I'll provide the subtraction.  TODO: I think I can eliminate
  // this now?
  difference_type operator- (const BaseOffsetIterator& rhs) const
  {
    ASSERT(mPage == rhs.mPage);
    return mIterator - rhs.mIterator;
  }
  BaseOffsetIterator operator- (difference_type n) const
  {
    return BaseOffsetIterator(mPage, mIterator - n, mTraits);
  }
  BaseOffsetIterator& operator-= (difference_type n)
  {
    mIterator += n;
    return *this;
  }
  BaseOffsetIterator& operator--( )
  {
    --mIterator;
    return *this;
  } 
  BaseOffsetIterator operator--( int )
  {
    BaseOffsetIterator tmp(mPage, mIterator--, mTraits);
    return tmp;
  }
  bool operator<= (const BaseOffsetIterator& rhs) const
  {
    ASSERT(mPage == rhs.mPage);
    return mIterator <= rhs.mIterator;
  }
  bool operator< (const BaseOffsetIterator& rhs) const
  {
    ASSERT(mPage == rhs.mPage);
    return mIterator < rhs.mIterator;
  }
  bool operator>= (const BaseOffsetIterator& rhs) const
  {
    ASSERT(mPage == rhs.mPage);
    return mIterator >= rhs.mIterator;
  }
  bool operator> (const BaseOffsetIterator& rhs) const
  {
    ASSERT(mPage == rhs.mPage);
    return mIterator > rhs.mIterator;
  }
  bool operator== (const BaseOffsetIterator& rhs) const
  {
    ASSERT(mPage == rhs.mPage);
    return mIterator == rhs.mIterator;
  }
  bool operator!= (const BaseOffsetIterator& rhs) const
  {
    ASSERT(mPage == rhs.mPage);
    return mIterator != rhs.mIterator;
  }    
};


template<class _T>
class FixedSizeRecordLengthPolicy 
{
private:
  boost::uint16_t mKeySize;
  boost::uint16_t mValueSize;
public:
  FixedSizeRecordLengthPolicy(boost::uint16_t keySize, boost::uint16_t valueSize)
    :
    mKeySize(keySize),
    mValueSize(valueSize)
  {
  }
  boost::uint16_t GetCompressedRecordSize(const boost::uint8_t *, const _T& p)
  {
    return mKeySize + mValueSize - p.GetPrefixLength();
  }

  boost::uint16_t GetCompressedKeySize(const boost::uint8_t *, const _T& p)
  {
    return mKeySize - p.GetPrefixLength();
  }
};

// Key format can be optimized for fixed length
// keys by not storing the length of the key.
class BPlusTreeParameters
{
public:
  enum { PAGE_SIZE=1024 };
  enum { EMPTY=0x01, VARIABLE_KEYS=0x02, LEAF=0x04, PARENT_OF_LEAF=0x08 };
};

// A non leaf page that is not "under construction" should always
// have at least two children.  The last of the child pointers is stored
// without a corresponding key (the so-called last page).
// Non leaf pages may be created in one of two ways:
// 1) Splitting an existing non leaf page.
// 2) Creating a non leaf root page based on splitting a 
// split root leaf page (splitting a single page b-tree).
//
// The latter case unfolds by starting with a leaf page at
// the root.  The root splits resulting in two leaf pages.
// A new leaf page is allocated and is the split root state
// is copied into it.  The state of the root page is reset with
// the root becoming a non leaf with the right page as last page,
// and the new copy of the root as the <key,ptr> pair.
//
// Subsequent increases in the depth of the tree happen in a similar
// way except the root tree was a non-leaf to begin with (this may
// result in the root having its ParentOfLeaf bit cleared).
class BPlusTreeNonLeafPage
{
public:
  typedef void * pageid_t;
  typedef ReverseArrayIterator<boost::uint16_t> iterator;

  iterator begin() { return iterator(&mSlot); }
  iterator end() { return iterator(&mSlot - std::size_t(mNumRecords)); }

  class Keys
  {
  public:
    typedef BaseOffsetIterator<boost::uint8_t *, PointerBaseTraits<ReverseArrayIterator<boost::uint16_t> > > iterator;

  private:
    BPlusTreeNonLeafPage& mPage;
  public:
    Keys(BPlusTreeNonLeafPage& page)
      :
      mPage(page)
    {
    }
    iterator begin() const
    {
      return iterator(reinterpret_cast<boost::uint8_t *>(&mPage), mPage.begin());
    }
    iterator end() const
    {
      return iterator(reinterpret_cast<boost::uint8_t *>(&mPage), mPage.end());
    }
  };

  Keys GetKeys() 
  {
    return Keys(*this);
  }

  class Values
  {
  public:
    typedef BaseOffsetIterator<boost::uint8_t *, PointerBaseOffsetTraits<ReverseArrayIterator<boost::uint16_t>, pageid_t> > iterator;

  private:
    BPlusTreeNonLeafPage& mPage;
    boost::uint16_t mKeySize;
  public:
    Values(BPlusTreeNonLeafPage& page, boost::uint16_t keySize)
      :
      mPage(page),
      mKeySize(keySize - page.GetPrefixLength())
    {
    }
    iterator begin()
    {
      return iterator(reinterpret_cast<boost::uint8_t *>(&mPage), 
                      mPage.begin(), 
                      PointerBaseOffsetTraits<ReverseArrayIterator<boost::uint16_t>, pageid_t> (mKeySize));
    }
    iterator end()
    {
      return iterator(reinterpret_cast<boost::uint8_t *>(&mPage), 
                      mPage.end(), 
                      PointerBaseOffsetTraits<ReverseArrayIterator<boost::uint16_t>, pageid_t> (mKeySize));
    }
  };

  Values GetValues(boost::uint16_t keySize) 
  {
    return Values(*this, keySize);
  }

  const boost::uint8_t * GetKey(const iterator& it) 
  {
    ASSERT(it != end());
    return reinterpret_cast<const boost::uint8_t *>(this) + *it;
  }
  pageid_t GetPage(boost::uint16_t keySize, const iterator& it) 
  { 
    return it == end() ? 
      GetLastPage() : 
      *reinterpret_cast<const pageid_t *>(reinterpret_cast<const boost::uint8_t *>(this) + *it + keySize - mPrefixLength);
  }

private:
  boost::uint16_t mFreeBytes;
  boost::uint16_t mFreeStart;
  boost::uint16_t mNumRecords;
  boost::uint8_t mPageFlags;
  boost::uint8_t mPrefixLength;
  pageid_t mLastPage;
  boost::uint8_t mData[BPlusTreeParameters::PAGE_SIZE - 
                sizeof(boost::uint16_t) - 
                sizeof(boost::uint16_t) - 
                sizeof(boost::uint16_t) - 
                sizeof(boost::uint8_t) - 
                sizeof(boost::uint8_t) - 
                sizeof(pageid_t) -
                sizeof(boost::uint16_t)
                ];
  boost::uint16_t mSlot;

  boost::uint8_t * GetData(const iterator& it)
  {
    return reinterpret_cast<boost::uint8_t *>(this) + *it;
  }

  static boost::uint8_t GetPrefixSize(const boost::uint8_t * a, boost::uint16_t a_len,
                               const boost::uint8_t * b, boost::uint16_t b_len);

  //
  // Page flag modifiers
  //
  void SetEmpty() 
  {
    mPageFlags |= BPlusTreeParameters::EMPTY;
  }
  void ClearEmpty() 
  {
    mPageFlags &= ~BPlusTreeParameters::EMPTY;
  }

  void SetLeaf() 
  {
    mPageFlags |= BPlusTreeParameters::LEAF;
  }
  void ClearLeaf() 
  {
    mPageFlags &= ~BPlusTreeParameters::LEAF;
  }

  void SetParentOfLeaf() 
  {
    mPageFlags |= BPlusTreeParameters::PARENT_OF_LEAF;
  }
  void ClearParentOfLeaf() 
  {
    mPageFlags &= ~BPlusTreeParameters::PARENT_OF_LEAF;
  }

  void Compress(boost::uint16_t keySize, boost::uint16_t valueSize);
public:
  class SearchState
  {
  public:
    iterator Iterator;
    boost::int32_t Comparison;
  };

  bool Insert(FixedSizeRecordLengthPolicy<BPlusTreeNonLeafPage>& recordPolicy,
              iterator& it, 
              const boost::uint8_t * key, 
              boost::uint16_t keyLength, 
              pageid_t value);
public:
  METRAFLOW_DECL BPlusTreeNonLeafPage();
  METRAFLOW_DECL ~BPlusTreeNonLeafPage();
  // Initialize with fixed length keys to calculate prefix.
  METRAFLOW_DECL void Init(const boost::uint8_t * lo, const boost::uint8_t * hi, boost::uint16_t keyLength, pageid_t child);
//   // Initialize with variable length keys and prefix.
//   void Init(const boost::uint8_t * lo, boost::uint16_t loKeyLength, const boost::uint8_t * hi, boost::uint16_t hiKeyLength);
  // Search for a fixed length key.
  METRAFLOW_DECL void Search(const boost::uint8_t * key, boost::uint16_t keyLength, SearchState& search);
  // Append a fixed length key/ptr pair (due a split child).
  METRAFLOW_DECL bool Insert(const boost::uint8_t * key, boost::uint16_t keyLength, pageid_t rightPage);
  // Insert at a particular position.
  METRAFLOW_DECL bool Insert(BPlusTreeNonLeafPage::iterator& it, const boost::uint8_t * key, boost::uint16_t keyLength, pageid_t value);
  // Insert into split
  METRAFLOW_DECL bool InsertWithNewKey(BPlusTreeNonLeafPage::iterator& it, const boost::uint8_t * key, boost::uint16_t keyLength, pageid_t value);  
  // Split into a new page
  METRAFLOW_DECL void SplitRight(BPlusTreeNonLeafPage& rightPage, 
                            boost::uint8_t * keyToInsert, boost::uint16_t keySize, boost::uint16_t valueSize, 
                            const boost::uint8_t * oldLoKey, const boost::uint8_t * oldHiKey,
                            boost::uint8_t * newHiKey, BPlusTreeNonLeafPage::iterator& insertPosition, 
                            bool& insertOnRight, bool& insertWithNewKey);

  // Requires:
  // GetValue(splitChildPosition) == splitChild.
  // begin() <= splitChildPosition <= end()
  // splitChildPosition == end() means that we have split the last page.
  METRAFLOW_DECL void PropagateSplit(BPlusTreeNonLeafPage& rightNonLeafPage,
                                iterator& splitChildPosition, pageid_t splitChild, pageid_t splitChildRight,
                                const boost::uint8_t * oldLoKey, const boost::uint8_t * oldHiKey, boost::uint8_t * newHiKey,
                                bool & wasThisSplit);

  // Getters (primarily for testing)
  static boost::uint16_t GetHeaderLength() 
  { 
    return sizeof(boost::uint16_t) + 
      sizeof(boost::uint16_t) +
      sizeof(boost::uint16_t) +
      sizeof(boost::uint8_t) +
      sizeof(boost::uint8_t) +
      sizeof(pageid_t); 
  }
  boost::uint16_t GetFreeBytes() const { return mFreeBytes; }
  boost::uint16_t GetFreeStart() const { return mFreeStart; }
  boost::uint16_t GetNumRecords() const { return mNumRecords; }
  boost::uint8_t GetPageFlags() const { return mPageFlags; }
  boost::uint8_t GetPrefixLength() const { return mPrefixLength; }
  pageid_t GetLastPage() const { return mLastPage; }
  bool IsEmpty() const
  {
    return (mPageFlags & BPlusTreeParameters::EMPTY) != 0;
  }
  bool IsLeaf() const
  {
    return (mPageFlags & BPlusTreeParameters::LEAF) != 0;
  }
  bool IsParentOfLeaf() const
  {
    return (mPageFlags & BPlusTreeParameters::PARENT_OF_LEAF) != 0;
  }
};

// For the moment we don't need deletion in pages,
// so we can have relatively simple insert algorithms
// that simply check the amount of free space.
class BPlusTreePage
{
public:
  typedef ReverseArrayIterator<boost::uint16_t> iterator;
  typedef void * pageid_t;

  iterator begin() { return iterator(&mSlot); }
  iterator end() { return iterator(&mSlot - std::size_t(mNumRecords)); }
private:
  boost::uint16_t mFreeBytes;
  boost::uint16_t mFreeStart;
  boost::uint16_t mNumRecords;
  boost::uint8_t mPageFlags;
  boost::uint8_t mPrefixLength;
  pageid_t mPrevious;
  pageid_t mNext;

  boost::uint8_t mData[BPlusTreeParameters::PAGE_SIZE - 
                sizeof(boost::uint16_t) - 
                sizeof(boost::uint16_t) - 
                sizeof(boost::uint16_t) - 
                sizeof(boost::uint8_t) - 
                sizeof(boost::uint8_t) - 
                sizeof(pageid_t) - 
                sizeof(pageid_t) - 
                sizeof(boost::uint16_t)];
  boost::uint16_t mSlot;

  boost::uint8_t * GetData(const iterator& it)
  {
    return reinterpret_cast<boost::uint8_t *>(this) + *it;
  }

  static boost::uint8_t GetPrefixSize(const boost::uint8_t * a, boost::uint16_t a_len,
                               const boost::uint8_t * b, boost::uint16_t b_len);

  //
  // Page flag modifiers
  //
  void SetEmpty() 
  {
    mPageFlags |= BPlusTreeParameters::EMPTY;
  }
  void ClearEmpty() 
  {
    mPageFlags &= ~BPlusTreeParameters::EMPTY;
  }

  void Compress(boost::uint16_t keySize, boost::uint16_t valueSize);
public:
  class SearchState
  {
  public:
    iterator Iterator;
    boost::int32_t Comparison;
  };

public:
  METRAFLOW_DECL BPlusTreePage();
  METRAFLOW_DECL ~BPlusTreePage();
  // Initialize empty/root with no prefix.
  METRAFLOW_DECL void Init();
  // Initialize with fixed length keys to calculate prefix.
  METRAFLOW_DECL void Init(const boost::uint8_t * lo, const boost::uint8_t * hi, boost::uint16_t keyLength);
//   // Initialize with variable length keys and prefix.
//   void Init(const boost::uint8_t * lo, boost::uint16_t loKeyLength, const boost::uint8_t * hi, boost::uint16_t hiKeyLength);
  // Search for a fixed length key.
  METRAFLOW_DECL void Search(const boost::uint8_t * key, boost::uint16_t keyLength, SearchState& search);
  // Insert a new key/pointer as a result of a page split below.
  METRAFLOW_DECL bool InsertNonLeaf(const boost::uint8_t * key, boost::uint16_t keyLength, const boost::uint8_t * value, boost::uint16_t valueLength);
  // Append a fixed length key/value pair.
  METRAFLOW_DECL bool Insert(const boost::uint8_t * key, boost::uint16_t keyLength, const boost::uint8_t * value, boost::uint16_t valueLength);
  // Split into a new page
  METRAFLOW_DECL void SplitLeafRight(BPlusTreePage& rightPage, 
                                const boost::uint8_t * keyToInsert, boost::uint16_t keySize, boost::uint16_t valueSize, 
                                const boost::uint8_t * oldLoKey, const boost::uint8_t * oldHiKey,
                                boost::uint8_t * newHiKey, BPlusTreePage::iterator& insertPosition, bool& insertOnRight);

  // Getters (primarily for testing)
  boost::uint16_t GetHeaderLength() const 
  { 
    return sizeof(boost::uint16_t) + 
      sizeof(boost::uint16_t) +
      sizeof(boost::uint16_t) +
      sizeof(boost::uint8_t) +
      sizeof(boost::uint8_t) +
      sizeof(pageid_t) +
      sizeof(pageid_t); 
  }
  boost::uint16_t GetFreeBytes() const { return mFreeBytes; }
  boost::uint16_t GetFreeStart() const { return mFreeStart; }
  boost::uint16_t GetNumRecords() const { return mNumRecords; }
  boost::uint8_t GetPageFlags() const { return mPageFlags; }
  boost::uint8_t GetPrefixLength() const { return mPrefixLength; }
  pageid_t GetNext() const { return mNext; }
  pageid_t GetPrevious() const { return mPrevious; }
  bool IsEmpty() const
  {
    return (mPageFlags & BPlusTreeParameters::EMPTY) != 0;
  }
  const boost::uint8_t * GetKey(const iterator& it) 
  {
    ASSERT(it != end());
    return reinterpret_cast<const boost::uint8_t *>(this) + *it;
  }
  const boost::uint8_t * GetValue(boost::uint16_t keySize, const iterator& it) 
  { 
    ASSERT(it != end());
    return reinterpret_cast<const boost::uint8_t *>(reinterpret_cast<const boost::uint8_t *>(this) + *it + keySize - mPrefixLength);
  }

};

class BPlusTree
{
public:
  class SearchState
  {
  private:
    BPlusTreePage * Page;
    BPlusTreePage::SearchState State;
  public:
    SearchState()
      :
      Page(NULL)
    {
    }
    ~SearchState() {}
    void SetPage(BPlusTreePage * page) { Page = page; }
    BPlusTreePage * GetPage() const { return Page; }
    BPlusTreePage::SearchState& GetState() { return State; }
    boost::int32_t GetComparison() const { return State.Comparison; }
    BPlusTreePage::iterator GetIterator() const { return State.Iterator; }

  };

private:
  BPlusTreeNonLeafPage * mRoot;
  std::vector<boost::uint8_t> mMinKey;
  std::vector<boost::uint8_t> mMaxKey;
  CacheAlignedMalloc mMalloc;
  boost::int32_t mLevels;
  void GetBoundingKeys(
    std::vector<std::pair<BPlusTreeNonLeafPage*,BPlusTreeNonLeafPage::SearchState> >::reverse_iterator begin,
    std::vector<std::pair<BPlusTreeNonLeafPage*,BPlusTreeNonLeafPage::SearchState> >::reverse_iterator end,
    const boost::uint8_t *& oldLoKey, const boost::uint8_t *& oldHiKey);
  void Dump(std::ostream& ostr, BPlusTreeNonLeafPage& leafPage, int level, std::size_t truncateKey);
  void Dump(std::ostream& ostr, BPlusTreePage& leafPage, int level, std::size_t truncateKey);
public:
  METRAFLOW_DECL BPlusTree(boost::uint16_t fixedKeySize);
  METRAFLOW_DECL ~BPlusTree();
  METRAFLOW_DECL void Insert(const boost::uint8_t * key, boost::uint16_t keyLength, const boost::uint8_t * value, boost::uint16_t valueLength);
  METRAFLOW_DECL void Search(const boost::uint8_t * key, boost::uint16_t keyLength, SearchState& search);
  METRAFLOW_DECL void SearchNext(const boost::uint8_t * key, boost::uint16_t keyLength, SearchState& search);
  METRAFLOW_DECL const boost::uint8_t * GetKey(const SearchState& search);
  METRAFLOW_DECL const boost::uint8_t * GetValue(const SearchState& search);
  METRAFLOW_DECL boost::int32_t GetLevels();
  METRAFLOW_DECL void Dump(std::ostream& ostr, std::size_t truncateKey);
};

#endif
