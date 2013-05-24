#include <sstream>
#include <stdexcept>
#include <limits>
#include <cerrno>
#include <atlenc.h>
#include <map>
#include <OdbcBatchIDWriter.h>
#include <OdbcConnMan.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include "RecordParser.h"
#include "ImportFunction.h"
#include "OperatorArg.h"

#include "LogAdapter.h"

#ifdef WIN32
#import <MTEnumConfig.tlb>
#include <MSIXDefinition.h>
#include <MSIXProperties.h>
#include <ServicesCollection.h>

#endif

// MTSQL stuff
#include "BooleanPredicateInterface.h"

// Importer template
#include "Importer.h"
#include "Exporter.h"

#include <boost/format.hpp>
#include <boost/io/ios_state.hpp>
#include <boost/filesystem/operations.hpp>

CacheAlignedMalloc::CacheAlignedMalloc()
  :
  mSpaceRemaining(0),
  mBufferSpace(0),
  mTotalAllocatedSpace(0)
{
}

CacheAlignedMalloc::~CacheAlignedMalloc()
{
  for(std::vector<boost::uint8_t *>::iterator it =  mAllocatedBuffers.begin();
      it != mAllocatedBuffers.end();
      ++it)
  {
    delete [] *it;
  }
}

void * CacheAlignedMalloc::malloc(std::size_t sz)
{
  if (sz > mSpaceRemaining)
  {
    std::size_t toAllocate((sz < _BufferSize ? _BufferSize : sz) + _CacheLineSize - 1);
    mTotalAllocatedSpace += toAllocate;
    mAllocatedBuffers.push_back(new unsigned char [toAllocate]);
    mCacheAlignedBuffers.push_back(reinterpret_cast<unsigned char *>(((reinterpret_cast<size_t>(mAllocatedBuffers.back()) + _CacheLineSize - 1)>>_CacheLineSizeLog2)<<_CacheLineSizeLog2));
    mBufferSpace = mSpaceRemaining = (toAllocate - (mCacheAlignedBuffers.back() - mAllocatedBuffers.back()));
    memset(mCacheAlignedBuffers.back(), 0, mBufferSpace);
  }

  ASSERT(sz <= mSpaceRemaining);

  boost::uint8_t * ret = mCacheAlignedBuffers.back() + mBufferSpace - mSpaceRemaining;
  mSpaceRemaining -= sz;
  return ret;
}

std::size_t CacheAlignedMalloc::GetAllocatedSize() const
{
  return mTotalAllocatedSpace;
}

#ifdef WIN32
static std::string WideStringToMultiByte(const std::wstring & arWide, UINT aCodePage)
{
    int len;
    
    len = ::WideCharToMultiByte(
        aCodePage,                                  // code page
        0,                                                  // performance and mapping flags
        arWide.c_str(),                   // wide-character string
        arWide.length(),                    // number of chars in string
        NULL,                                               // buffer for new string
        0,                                                  // size of buffer
        NULL,                                               // default for unmappable chars
        NULL);                                          // set when default char used
    
    if (len == 0)
        throw std::exception("Internal Error");
    
    char * out = new char[len];
    len = ::WideCharToMultiByte(
        aCodePage,                                  // code page
        0,                                                  // performance and mapping flags
        arWide.c_str(),                 // wide-character string
        arWide.length(),                    // number of chars in string
        out,                                                // buffer for new string
        len,                                                // size of buffer
        NULL,                                               // default for unmappable chars
        NULL);                                          // set when default char used

    if (len == 0)
    {
        int err = ::GetLastError();
        throw Win32Exception("WideStringToMultiByte", err, __FILE__, __LINE__);
    }

    std::string temp(out, len);

    delete [] out;

    return temp;
}

Win32Exception::Win32Exception(const char * msg, DWORD dwErr, const char * file, int line)
  :
  std::runtime_error(ToString(msg, dwErr, file, line)),
  mErr(dwErr),
  mFile(file),
  mLine(line)
{
}

std::string Win32Exception::ToString(const char * fun, DWORD dwErr, const char * file, int line)
{
    wchar_t buf[1024];
    buf[0] = 0;
  ::FormatMessageW(
    FORMAT_MESSAGE_FROM_SYSTEM,
    NULL,
    dwErr,
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
    buf,
    1024,
    0);

    std::stringstream msg;
    msg << fun << " " << file << "::" << line << ": 0x" << std::ios::hex << dwErr << " " << WideStringToMultiByte(buf, CP_ACP).c_str() << std::ends;
    return msg.str();
}

int SystemInfo::GetAllocationGranularity()
{
  SYSTEM_INFO sysInfo;
  ::GetSystemInfo(&sysInfo);
  return sysInfo.dwAllocationGranularity;
}

MappedFile::MappedFile(const std::wstring& filename)
  :
  mFile(INVALID_HANDLE_VALUE),
  mFileMapping(NULL)
{
  mFile = ::CreateFileW(filename.c_str(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  if (mFile == INVALID_HANDLE_VALUE)
  {
    throw Win32Exception("MappedFile::MappedFile", ::GetLastError(), __FILE__, __LINE__);
  }
  mFileMapping = ::CreateFileMapping(mFile, NULL, PAGE_READONLY, 0, 0, NULL);
  if (mFileMapping == NULL) 
  {
    throw Win32Exception("MappedFile::MappedFile", ::GetLastError(), __FILE__, __LINE__);
  }
  // We can cache the file size because we don't allow writers to open the file.
  LARGE_INTEGER fileSize;
  BOOL ret = ::GetFileSizeEx(mFile, &fileSize);
  if (ret == FALSE)
  {
    throw Win32Exception("MappedFile::MappedFile", ::GetLastError(), __FILE__, __LINE__);
  }
  mFileSize = fileSize.QuadPart;
}

MappedFile::~MappedFile()
{
  if (mFileMapping) ::CloseHandle(mFileMapping);
  if (mFile != INVALID_HANDLE_VALUE) ::CloseHandle(mFile);
}

void MappedFile::Map(boost::int64_t offset, int size, MappedBuffer * buffer)
{
  // When mapping the end of the file, make sure that we don't go past it!
  // TODO: make the size a reference parameter so callers know that we've truncated.
  if (offset+size > GetFileSize()) size = (int) (GetFileSize()-offset);

  LPVOID lpMap = ::MapViewOfFile(mFileMapping, FILE_MAP_READ, (DWORD) ((offset & 0xffffffff00000000) >> 32),
                                 (DWORD) (offset & 0x00000000ffffffff), size);
  if (lpMap == NULL) 
  {
    throw Win32Exception("MappedFile::Map", ::GetLastError(), __FILE__, __LINE__);
  }
  buffer->Init((unsigned char *)lpMap, size);
}

mapped_file::mapped_file(const std::wstring& filename)
  :
  mFile(INVALID_HANDLE_VALUE),
  mFileMapping(NULL)
{
  mFile = ::CreateFileW(filename.c_str(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  if (mFile == INVALID_HANDLE_VALUE)
  {
    std::string utf8Filename;
    ::WideStringToUTF8(filename, utf8Filename);
    throw Win32Exception((boost::format("Error opening file %1% for reading.")%utf8Filename).str().c_str(), ::GetLastError(), __FILE__, __LINE__);
  }
  mFileMapping = ::CreateFileMapping(mFile, NULL, PAGE_READONLY, 0, 0, NULL);
  if (mFileMapping == NULL) 
  {
    throw Win32Exception("mapped_file::mapped_file", ::GetLastError(), __FILE__, __LINE__);
  }
  // We can cache the file size because we don't allow writers to open the file.
  LARGE_INTEGER fileSize;
  BOOL ret = ::GetFileSizeEx(mFile, &fileSize);
  if (ret == FALSE)
  {
    throw Win32Exception("mapped_file::mapped_file", ::GetLastError(), __FILE__, __LINE__);
  }
  mFileSize = fileSize.QuadPart;
}

mapped_file::~mapped_file()
{
  if (mFileMapping) ::CloseHandle(mFileMapping);
  if (mFile != INVALID_HANDLE_VALUE) ::CloseHandle(mFile);
}

void mapped_file::open(boost::uint64_t offset, std::size_t& sz, boost::uint8_t *& view)

{
  // Can't open with invalid offset
  if (offset >= size()) 
  {
    view = NULL;
    return;
  }
  // When mapping the end of the file, make sure that we don't go past it!
  if (offset+sz > size()) sz = (std::size_t) (size()-offset);
  
  LPVOID lpMap = ::MapViewOfFile(mFileMapping, FILE_MAP_READ, (DWORD) ((offset & 0xffffffff00000000) >> 32),
                                 (DWORD) (offset & 0x00000000ffffffff), sz);
  if (lpMap == NULL) 
  {
    DWORD dwError = ::GetLastError();
    throw Win32Exception((boost::format("mapped_file::open(%1%, %2%, %3%)") % offset % sz % view).str().c_str(), 
                         dwError, 
                         __FILE__, 
                         __LINE__);
  }

  view = (boost::uint8_t *)lpMap;
}

void mapped_file::release(boost::uint8_t * view)
{
  if (NULL != view)
  {
    ::UnmapViewOfFile(view);
  }
}

std::size_t mapped_file::granularity() const
{
  SYSTEM_INFO sysInfo;
  ::GetSystemInfo(&sysInfo);
  return sysInfo.dwAllocationGranularity;
}

MappedBuffer::MappedBuffer()
  :
  mViewBase(NULL),
  mViewPosition(NULL),
  mBytesAvailable(0)

{
}

MappedBuffer::~MappedBuffer()
{
  Clear();
}

void MappedBuffer::Clear()
{
  if (mViewBase)
  {
    ::UnmapViewOfFile(mViewBase);
  }
  mViewBase = NULL;
  mViewPosition = NULL;
  mBytesAvailable = 0;
}

void MappedBuffer::Init(unsigned char * viewBase, int size)
{
  Clear();
  mViewBase = viewBase;
  mViewPosition = viewBase;
  mBytesAvailable = size;
}

void MappedBuffer::Init(unsigned char * viewBase, int position, int size)
{
  Clear();
  mViewBase = viewBase;
  mViewPosition = viewBase+position;
  mBytesAvailable = size-position;
}

MappedInputStream::MappedInputStream(MappedFile * fileMapping, int viewSize)
  :
  mFileMapping(fileMapping)
{
  // Round up view size to next multiple of allocation granularity
  int ag = SystemInfo::GetAllocationGranularity();
  mViewSize = ag * ((viewSize + ag - 1)/ag);
  mOffset = 0;
  mFileMapping->Map(mOffset, mViewSize, &mView);
}

MappedInputStream::~MappedInputStream()
{
}

void MappedInputStream::OpenWindow(int viewSize)
{
  // Find out how many "new" bytes must get mapped in (measured in pages).
  int ag =SystemInfo::GetAllocationGranularity();
  int numNewPages = (viewSize - mView.GetAvailable() + ag - 1)/ag;
  // Find out how many pages in current view haven't been completely read.
  int numActivePages = (mView.GetAvailable() + ag - 1)/ag;
  // Find offset to the first active page and offset of position within it.
  int roundedPosition = ag*(mView.GetPosition()/ag);
  int remainderPosition = mView.GetPosition() - roundedPosition;
  // Make sure that view size is at least the minimum
  viewSize = ag * (numNewPages + numActivePages);
  if (viewSize < mViewSize) viewSize = mViewSize;
  mOffset += roundedPosition;
  mFileMapping->Map(mOffset, viewSize, &mView);
  Consume(remainderPosition);
}

#endif

CacheConsciousHashTableIteratorBase::CacheConsciousHashTableIteratorBase(CacheConsciousHashTable& table)
  :
  mTable(table),
  mNode(NULL),
  mStutter(true),
  mFullHashValue(0),
  mFullHashPtr(NULL),
  mStartPtr(NULL),
  mRecordBuffer(NULL),
  mState(START)
{
}

void CacheConsciousHashTableIteratorBase::Init(CacheConsciousHashTable::CacheLineNode * node, 
                                           const_record_t recordBuffer, 
                                           unsigned int fullHashValue)
{
  mNode = node;
  mRecordBuffer = recordBuffer;
  mFullHashValue = fullHashValue;
  mState = START;
  mStutter = true;
}

bool CacheConsciousHashTableIteratorBase::IsEnd() const
{
  return mNode == NULL || *mFullHashPtr == 0;
}

// This is structured as a "Coroutine in C".  For this see http://www.chiark.greenend.org.uk/~sgtatham/coroutines.html
bool CacheConsciousHashTableIteratorBase::GetNext()
{
  CacheConsciousHashTable::CacheLineNode * node = GetCurrentNode();
  switch(mState)
  {
  case START:
    while(node != NULL)
    {
      mFullHashPtr = &node->FullHashValues[0];
      mStartPtr = mFullHashPtr;
      while(*mFullHashPtr != 0)
      {
        if(*mFullHashPtr == mFullHashValue && 
           Equals(mRecordBuffer, node->Values[mFullHashPtr-mStartPtr]))
        {
          mState = NEXT;
          return true;
        case NEXT:;
        } 
        mFullHashPtr++;
      }

      if (CacheConsciousHashTable::_HashSentinelPosition == mFullHashPtr - mStartPtr)
      {
        // We hit the end of the current (full) node.  Look to the next.  
        AdvanceNode();
        node = GetCurrentNode();
        continue;
      }
      else
      {
        // We hit the end of a non-full node.  The next pointer is guaranteed 
        // to be NULL.  Leave the node value in place so that we have a valid position
        // in case someone wants to insert here.
        break;
      }
    }

    do
    {
      mState = DONE;
      return false;
    case DONE:;
    } while(true);
  }
  // Should never get here
  ASSERT(FALSE);
  return false;
}

void CacheConsciousHashTableIteratorBase::Find(const_record_t recordBuffer)
{
}

CacheConsciousHashTableIterator::CacheConsciousHashTableIterator(CacheConsciousHashTable& table, const std::vector<DataAccessor *>& probeKeys)
  :
  CacheConsciousHashTableIteratorBase(table),
  mProbeKeys(probeKeys),
  mTableKeys(table.mTableKeys)
{
}

void CacheConsciousHashTableIterator::Find(const_record_t recordBuffer)
{
  mTable.Find(recordBuffer, *this);
}

CacheConsciousHashTableInsertIteratorBase::CacheConsciousHashTableInsertIteratorBase(CacheConsciousHashTable& table)
  :
  CacheConsciousHashTableIteratorBase(table),
  mTableKeys(table.mTableKeys)
{
}

CacheConsciousHashTableUniqueInsertIterator::CacheConsciousHashTableUniqueInsertIterator(CacheConsciousHashTable& table)
  :
  CacheConsciousHashTableInsertIteratorBase(table)
{
}

CacheConsciousHashTableNonUniqueInsertIterator::CacheConsciousHashTableNonUniqueInsertIterator(CacheConsciousHashTable& table)
  :
  CacheConsciousHashTableInsertIteratorBase(table)
{
}

CacheConsciousHashTablePredicateIterator::CacheConsciousHashTablePredicateIterator(CacheConsciousHashTable& table, const std::vector<DataAccessor *>& probeKeys, const RecordMetadata& probeResidual, const RecordMetadata& tableResidual, const std::wstring& predicate)
  :
  CacheConsciousHashTableIteratorBase(table),
  mProbeKeys(probeKeys),
  mTableKeys(table.mTableKeys)
{
  mProbeFrame = new RecordFrame(&probeResidual);
  mTableFrame = new RecordFrame(&tableResidual);
  // Variables @Probe_* come from the probe record, @Table_* come from the LUT
  mEnv = new DualCompileEnvironment(table.GetLogger(), mProbeFrame, mTableFrame, "Probe_", "Table_");
  mInterpreter = new MTSQLInterpreter(mEnv);
  mInterpreter->setSupportVarchar(true);
  mExe = mInterpreter->analyze(predicate.c_str());
  if (NULL == mExe) 
  {
//     throw MTErrorObjectException(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE,
//                                  "CacheConsciousHashTablePredicateIterator::CacheConsciousHashTablePredicateIterator", 
//                                  "Error compiling predicate");
    std::wstring msg (L"Error compiling predicate: ");
    msg += predicate;
    std::string utf8Msg;
    ::WideStringToUTF8(msg, utf8Msg);
    throw std::runtime_error(utf8Msg.c_str());
  }
  mExe->codeGenerate(mEnv);

  mProbeActivationRecord = new RecordActivationRecord(NULL);
  mTableActivationRecord = new RecordActivationRecord(NULL);
  mRuntime = new DualRuntimeEnvironment(table.GetLogger(), mProbeActivationRecord, mTableActivationRecord);
}

CacheConsciousHashTablePredicateIterator::~CacheConsciousHashTablePredicateIterator()
{
  delete mRuntime;
  delete mTableActivationRecord;
  delete mProbeActivationRecord;
  delete mInterpreter;
  delete mEnv;
  delete mTableFrame;
  delete mProbeFrame;
}

bool CacheConsciousHashTablePredicateIterator::Equals(const_record_t probeBuffer, const_record_t tableBuffer)
{
  // We have a hash match on keys; check for key equality and residual against values
  std::vector<DataAccessor *>::iterator probe = mProbeKeys.begin();
  std::vector<DataAccessor *>::iterator table = mTableKeys.begin();
  for(; probe != mProbeKeys.end(); probe++, table++)
  {
    if (false == (*probe)->Equals(probeBuffer, *table, tableBuffer)) return false;
  }
 
  mProbeActivationRecord->SetBuffer(const_cast<record_t>(probeBuffer));
  mTableActivationRecord->SetBuffer(const_cast<record_t>(tableBuffer));
  mExe->execCompiled(mRuntime);
  return mExe->getReturnValue()->getBool();
}

unsigned int CacheConsciousHashTablePredicateIterator::Hash(const_record_t recordBuffer)
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

void CacheConsciousHashTablePredicateIterator::Find(const_record_t recordBuffer)
{
  mTable.Find(recordBuffer, *this);
}

void CacheConsciousHashTablePredicateIterator::Compile(const RecordMetadata& probeResidual, 
                                                       const RecordMetadata& tableResidual, 
                                                       const std::wstring& predicate)
{
  RecordFrame probeFrame(&probeResidual);
  RecordFrame tableFrame(&tableResidual);
  // Variables @Probe_* come from the probe record, @Table_* come from the LUT
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[CacheConsciousHashTablePredicateIterator]");
  DualCompileEnvironment env(logger, &probeFrame, &tableFrame, "Probe_", "Table_");
  MTSQLInterpreter interpreter(&env);
  interpreter.setSupportVarchar(true);
  MTSQLExecutable * exe = interpreter.analyze(predicate.c_str());
  if (NULL == exe) 
  {
    std::wstring msg (L"Error compiling predicate: ");
    msg += predicate;
    std::string utf8Msg;
    ::WideStringToUTF8(msg, utf8Msg);
    throw std::runtime_error(utf8Msg.c_str());
  }
}

CacheConsciousHashTableScanIterator::CacheConsciousHashTableScanIterator(CacheConsciousHashTable& table)
  :
  mTable(&table),
  mCurrentBucket(0),
  mNode(NULL),
  mStutter(true),
  mFullHashValue(0),
  mFullHashPtr(NULL),
  mStartPtr(NULL),
  mState(START)
{
}

void CacheConsciousHashTableScanIterator::Init()
{
  mCurrentBucket = 0;
  mState = START;
  mStutter = true;
}

// This is structured as a "Coroutine in C".  For this see http://www.chiark.greenend.org.uk/~sgtatham/coroutines.html
bool CacheConsciousHashTableScanIterator::GetNext()
{
  CacheConsciousHashTable::CacheLineNode * node = NULL;
  switch(mState)
  {
  case START:
    while (mCurrentBucket < mTable->mNumBuckets)
    {
      mNode = &mTable->mBuckets[mCurrentBucket++];
      mStutter = true;
      node = GetCurrentNode();
      while(node != NULL)
      {
        mFullHashPtr = &node->FullHashValues[0];
        mStartPtr = mFullHashPtr;
        while(*mFullHashPtr != 0)
        {
          mState = NEXT;
          return true;
        case NEXT:
          node = GetCurrentNode();
          mFullHashPtr++;
        }

        if (CacheConsciousHashTable::_HashSentinelPosition == mFullHashPtr - mStartPtr)
        {
          // We hit the end of the current (full) node.  Look to the next.  
          AdvanceNode();
          node = GetCurrentNode();
          continue;
        }
        else
        {
          // We hit the end of a non-full node.  The next pointer is guaranteed 
          // to be NULL.  Leave the node value in place so that we have a valid position
          // in case someone wants to insert here.
          break;
        }
      }
    }
    do
    {
      mState = DONE;
      return false;
    case DONE:
      node = GetCurrentNode();
    } while(true);
  }
  // Should never get here
  ASSERT(FALSE);
  return false;
}

CacheConsciousHashTable::CacheConsciousHashTable(const std::vector<DataAccessor *>& tableKeys, int numBuckets)
  :
  mOwnRecords(false),
  mNumBuckets(numBuckets),
  mBuckets(NULL),
  mNumRecords(0),
  mMaxLoadFactor(32),
  mRegionAllocator(NULL),
  mTableKeys(tableKeys),
  mMetadata(NULL)
{
  mRegionAllocator = new CacheAlignedMalloc();
  mBuckets = AllocateNode(mNumBuckets);
  mLogger = MetraFlowLoggerManager::GetLogger("[CacheConsciousHashTable]");
}

CacheConsciousHashTable::CacheConsciousHashTable(const std::vector<DataAccessor *>& tableKeys, 
                                                 const RecordMetadata& metadata,
                                                 bool ownRecords,
                                                 int numBuckets)
  :
  mOwnRecords(ownRecords),
  mNumBuckets(numBuckets),
  mBuckets(NULL),
  mNumRecords(0),
  mMaxLoadFactor(32),
  mRegionAllocator(NULL),
  mTableKeys(tableKeys),
  mMetadata(&metadata)
{
  mRegionAllocator = new CacheAlignedMalloc();
  mBuckets = AllocateNode(mNumBuckets);
  mLogger = MetraFlowLoggerManager::GetLogger("[CacheConsciousHashTable]");
}

CacheConsciousHashTable::~CacheConsciousHashTable()
{
  if (mOwnRecords)
  {
    CacheConsciousHashTableScanIterator scan(*this);
    while(scan.GetNext())
    {
      mMetadata->Free(scan.Get());
    }
  }

  delete mRegionAllocator;
}

void CacheConsciousHashTable::Find(const_record_t recordBuffer, CacheConsciousHashTableIterator & iter)
{
  unsigned int fullHashValue = iter.Hash(recordBuffer);
  // Disallow hash value of 0 since we use it as a sentinel.
  fullHashValue = fullHashValue != 0 ? fullHashValue : 0xffffffff;

  unsigned int hashValue = fullHashValue % mNumBuckets;
  CacheLineNode * node = &mBuckets[hashValue];
  iter.Init(node, recordBuffer, fullHashValue);
}

void CacheConsciousHashTable::Find(const_record_t recordBuffer, CacheConsciousHashTablePredicateIterator & iter)
{
  unsigned int fullHashValue = iter.Hash(recordBuffer);
  // Disallow hash value of 0 since we use it as a sentinel.
  fullHashValue = fullHashValue != 0 ? fullHashValue : 0xffffffff;

  unsigned int hashValue = fullHashValue % mNumBuckets;
  CacheLineNode * node = &mBuckets[hashValue];
  iter.Init(node, recordBuffer, fullHashValue);
}

void CacheConsciousHashTable::Insert(record_t recordBuffer, CacheConsciousHashTableInsertIteratorBase & iter)
{
  unsigned int fullHashValue=iter.Hash(recordBuffer);

  // Disallow hash value of 0 since we use it as a sentinel.
  fullHashValue = fullHashValue != 0 ? fullHashValue : 0xffffffff;

again:

  unsigned int hashValue = fullHashValue % mNumBuckets;
  CacheLineNode * node = &mBuckets[hashValue];
  iter.Init(node, recordBuffer, fullHashValue);
  iter.GetNext();
  // Already there
  if (iter.mState != CacheConsciousHashTableIterator::DONE) return;

  // Check to see if we need to resize the hash table.  If required 
  // do it now.
  if (mNumRecords >= mMaxLoadFactor*mNumBuckets)
  {
    // Create new bucket array.
    int newNumBuckets = mNumBuckets * 2;
    mLogger->logDebug((boost::format("Resizing to %1% buckets") % newNumBuckets).str());
    CacheAlignedMalloc * newRegion = new CacheAlignedMalloc();
    CacheLineNode * newBuckets = (CacheLineNode *) newRegion->malloc(sizeof(CacheLineNode)*newNumBuckets);
    // Rip through existing records and reassign to new bucket.
    CacheConsciousHashTableScanIterator scanIt(*this);
    while(scanIt.GetNext())
    {
      unsigned int existingFullHashValue = scanIt.GetFullHashValue();
      record_t existingRecordBuffer = scanIt.Get();
      unsigned int newBucket = existingFullHashValue % newNumBuckets;
      // Reuse passed in insert iterator to find position on new node.
      iter.Init(newBuckets + newBucket, existingRecordBuffer, existingFullHashValue);
      iter.GetNext();
      ASSERT(iter.mState == CacheConsciousHashTableIterator::DONE);
      
      // Should be positioned at the end 
      if (iter.GetCurrentNode() == NULL)
      {
        CacheLineNode * n = (CacheLineNode *) newRegion->malloc(sizeof(CacheLineNode));
        n->FullHashValues[0] = existingFullHashValue;
        n->Values[0] = existingRecordBuffer;
        n->Next = NULL;
        iter.mNode->Next = n;
      }
      else
      {
        *iter.mFullHashPtr = iter.mFullHashValue;
        iter.GetCurrentNode()->Values[iter.mFullHashPtr - iter.mStartPtr] = existingRecordBuffer;
      }
    }

    // Everything in the new storage.  Swap out.
    delete mRegionAllocator;
    mRegionAllocator = newRegion;
    mNumBuckets = newNumBuckets;
    mBuckets = newBuckets;

    // Try again from the top.
    goto again;
  }

  // Increment record count.
  mNumRecords += 1;

  // Should be positioned at the end 
  if (iter.GetCurrentNode() == NULL)
  {
    CacheLineNode * n = AllocateNode();
    n->FullHashValues[0] = iter.mFullHashValue;
    n->Values[0] = recordBuffer;
    n->Next = NULL;
    iter.mNode->Next = n;
  }
  else
  {
    *iter.mFullHashPtr = iter.mFullHashValue;
    iter.GetCurrentNode()->Values[iter.mFullHashPtr - iter.mStartPtr] = recordBuffer;
  }
}

void CacheConsciousHashTable::Scan(const_record_t recordBuffer, CacheConsciousHashTableScanIterator & iter)
{
  iter.Init();
}

int CacheConsciousHashTable::GetTotalAllocatedSize() const
{
  return mRegionAllocator->GetAllocatedSize();
}

int CacheConsciousHashTable::GetNumRecords() const
{
  return mNumRecords;
}

DesignTimeRecordImporter::DesignTimeRecordImporter()
  :
  mCompression(false),
  mIsHeaderPresent(false),
  mCollectionID(L"")
{
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeRecordImporter::~DesignTimeRecordImporter()
{
}

void DesignTimeRecordImporter::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"filename", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetFilename(arg.getNormalizedString());
  }
  else if (arg.is(L"format", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetFormat(arg.getNormalizedString());
  }
  else if (arg.is(L"uncompress", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    SetCompression(arg.getBoolValue());
  }
  else if (arg.is(L"header", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    SetIsHeaderPresent(arg.getBoolValue());
  }
  else if (arg.is(L"collectionIDEncoded", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    // Validate the encoded collection ID
    std::wstring encodedWide = arg.getNormalizedString();
    std::string encoded;
    ::WideStringToUTF8(encodedWide, encoded);

    BYTE decoded[32];
    int byteLength = 32;

    // Make sure we can decode the given string
    if (!Base64Decode(encoded.c_str(), encoded.size(), decoded, &byteLength))
    {
      throw DataflowInvalidArgumentException(
                                       arg.getValueLine(), 
                                       arg.getValueColumn(),
                                       arg.getFilename(),
                                       GetName(), 
                                       L"Could not decode the base64 encoded string.");
      
    }

    // We expect that the decoded length is 16 bytes
    if (byteLength != 16)
    {
      throw DataflowInvalidArgumentException(
                                       arg.getValueLine(), 
                                       arg.getValueColumn(),
                                       arg.getFilename(),
                                       GetName(), 
                                       L"The decoded string was not 16 bytes long.");
    }

    SetCollectionID(encodedWide);
  } 
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeRecordImporter* DesignTimeRecordImporter::clone(
                                                      const std::wstring& name,
                                                      std::vector<OperatorArg *>& args, 
                                                      int nInputs, int nOutputs) const
{
  DesignTimeRecordImporter* result = new DesignTimeRecordImporter();

  result->SetName(name);
  result->SetIsHeaderPresent(mIsHeaderPresent);
  result->SetCollectionID(mCollectionID);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeRecordImporter::SetFilename(const std::wstring& filename)
{
  mFilename = filename;
}

void DesignTimeRecordImporter::SetFormat(const std::wstring& format)
{
  mFormat = format;
}

void DesignTimeRecordImporter::SetCompression(bool compression)
{
  mCompression = compression;
}

void DesignTimeRecordImporter::SetIsHeaderPresent(bool isHeaderPresent)
{
  mIsHeaderPresent = isHeaderPresent;
}

void DesignTimeRecordImporter::SetCollectionID(const std::wstring& collectionID)
{
  mCollectionID = collectionID;
}

void DesignTimeRecordImporter::type_check()
{
  if (GetMode() != SEQUENTIAL) throw SingleOperatorException(*this, L"RecordImporter must run in sequential mode");

  // Test for existence of file can only be performed in type check when running
  // in sequential mode where we know that the file is accessible from the primary partition.
  if (!boost::filesystem::exists(boost::filesystem::wpath(mFilename, boost::filesystem::native)))
  {
    throw SingleOperatorException(*this, (boost::wformat(L"Import file '%1%' does not exist") % mFilename).str());
  }
  UTF8_Import_Function_Builder_2<StdioReadBuffer<StdioFile> > tmp(*this, mFormat);

  mOutputPorts[0]->SetMetadata(new RecordMetadata(tmp.GetMetadata()));
}

RunTimeOperator * DesignTimeRecordImporter::code_generate(partition_t maxPartition)
{
#ifdef WIN32
  if (mCompression)
    return new RunTimeRecordImporter<StdioReadBuffer<ZLIBFile> >(mName, mFormat, mFilename, 64*1024, mIsHeaderPresent, mCollectionID);
  else
    return new RunTimeRecordImporter<PagedParseBuffer<mapped_file> >(mName, mFormat, mFilename, 1024*1024, mIsHeaderPresent, mCollectionID);
#else
  return new RunTimeRecordImporter<StdioReadBuffer<StdioFile> >(mName, mFormat, mFilename, 64*1024, mIsHeaderPresent, mCollectionID);
#endif
}

void DesignTimeRecordImporter::ThrowError(const std::wstring& err)
{
  throw SingleOperatorException(*this, err);
}

ZLIBFile::ZLIBFile(const wstring& filename, bool forWriting)
  :
  mFile(0),
  mEOF(false)
{
  std::string utf8Filename;
  ::WideStringToUTF8(filename, utf8Filename);
  mFile = gzopen(utf8Filename.c_str(), forWriting ? "wb" : "rb");
  if (mFile == NULL)
  {
    if (errno != 0)
    {
      throw runtime_error((boost::format("Failed to open file; errno= %1%") % errno).str());
    }
    else
    {
      throw runtime_error("Memory allocation failure opening compressed file");
    }
  }
}

ZLIBFile::~ZLIBFile()
{
  if (mFile != NULL)
    gzclose(mFile);
}

void ZLIBFile::read(std::size_t& sz, boost::uint8_t * buffer)
{
  int e = gzread(mFile, buffer, sz);
  if (e == -1)
  {
    throw runtime_error((boost::format("gzread returned %1%") % e).str());
  }
  else if (e == 0)
  {
    mEOF = true;
  }
  sz = (std::size_t) e;
}

void ZLIBFile::write(boost::uint8_t * buffer, std::size_t sz)
{
  int e = gzwrite(mFile, buffer, sz);
  if (e == -1)
  {
    throw runtime_error((boost::format("gzwrite returned %1%") % e).str());
  }
  else if (e != sz)
  {
    // Short write.  
    // TODO: WHAT TO DO?
  }
}

std::size_t ZLIBFile::granularity() const
{
  return 1;
}

bool ZLIBFile::is_eof() const
{
  return mEOF;
}

StdioFile::StdioFile(const wstring& filename, bool forWriting)
  :
  mFile(0),
  mEOF(false)
{
  wstring mode(forWriting ? L"wb" : L"rb");
  mFile = _wfopen(filename.c_str(), mode.c_str());
  if (mFile == NULL)
  {
    if (errno != 0)
    {
      throw runtime_error((boost::format("Failed to open file; errno= %1%") % errno).str());
    }
    else
    {
      throw runtime_error("Memory allocation failure opening compressed file");
    }
  }
}

StdioFile::~StdioFile()
{
  if (mFile != NULL)
    fclose(mFile);
}

void StdioFile::read(std::size_t& sz, boost::uint8_t * buffer)
{
  size_t e = fread(buffer, 1, sz, mFile);

  mEOF = feof(mFile)!=0;

  if (!mEOF && e != sz)
  {
    int err = ferror(mFile);
    
    if(err != 0)
    {
      throw runtime_error((boost::format("StdioFile::read ferror returned %1%: %2%") % err % strerror(err)).str());
    }
  }
  
  sz = (std::size_t) e;
}

void StdioFile::write(const boost::uint8_t * buffer, std::size_t sz)
{
  int e = fwrite(buffer, 1, sz, mFile);
  if (e != sz)
  {
    int err = ferror(mFile);
    
    if(err != 0)
    {
      throw runtime_error((boost::format("StdioFile::write ferror returned %1%: %2%") % err % strerror(err)).str());
    }
  }
}

std::size_t StdioFile::granularity() const
{
  return 1;
}

bool StdioFile::is_eof() const
{
  return mEOF;
}

Win32File::Win32File(const std::wstring& filename, bool forWriting)
  :
  mFile(INVALID_HANDLE_VALUE)
{
  DWORD desiredAccess = forWriting ? GENERIC_WRITE | GENERIC_READ : GENERIC_READ;
  // For now don't allow anyone to modify while we are reading; we want a snapshot.
  DWORD sharedMode = FILE_SHARE_READ;
  DWORD creation = OPEN_ALWAYS;
  mFile = ::CreateFileW(filename.c_str(), 
                          desiredAccess, 
                          sharedMode, 
                          NULL, 
                          creation, 
                          FILE_ATTRIBUTE_NORMAL, 
                          NULL);
  if (mFile == INVALID_HANDLE_VALUE)
  {
    DWORD dwErr = ::GetLastError();
    std::string utf8Filename;
    ::WideStringToUTF8(filename, utf8Filename);
    throw Win32Exception((boost::format("Error opening file %1% for reading.")%utf8Filename).str().c_str(), dwErr, __FILE__, __LINE__);
  }
}

Win32File::~Win32File()
{
  if (INVALID_HANDLE_VALUE != mFile)
    ::CloseHandle(mFile);
}

void Win32File::read(std::size_t& sz, boost::uint8_t * buffer)
{
  DWORD bytes_to_read = sz;
  DWORD bytes_read; 
  BOOL ret = ::ReadFile(mFile, buffer, bytes_to_read, &bytes_read, 0);
  if(FALSE == ret) 
  {
    DWORD dwErr = ::GetLastError();
    throw Win32Exception("Error reading file.", dwErr, __FILE__, __LINE__);    
  }
  sz = bytes_read;
}

void Win32File::write(const boost::uint8_t * buffer, std::size_t sz)
{
  DWORD bytes_to_write = sz;
  DWORD bytes_written; 
  while(bytes_to_write)
  {
    BOOL ret = ::WriteFile(mFile, buffer, bytes_to_write, &bytes_written, 0);
    if(FALSE == ret) 
    {
      DWORD dwErr = ::GetLastError();
      throw Win32Exception("Error reading file.", dwErr, __FILE__, __LINE__);    
    }
    bytes_to_write -= bytes_written;
    buffer += bytes_written;
  }
}

std::size_t Win32File::granularity() const
{
  return 1;
}

bool Win32File::is_eof() const
{
  return mEOF;
}

template <class _Buffer>
RunTimeRecordImporter<_Buffer>::RunTimeRecordImporter()
  :
  mViewSize(0)
{
}

template <class _Buffer>
RunTimeRecordImporter<_Buffer>::RunTimeRecordImporter(const std::wstring& name, 
                                                      const std::wstring& format,
                                                      const std::wstring& filename,
                                                      boost::int32_t viewSize,
                                                      bool isHeaderPresent,
                                                      const std::wstring& collectionID)
  :
  RunTimeOperator(name),
  mFormat(format),
  mFilename(filename),
  mViewSize(viewSize),
  mIsHeaderPresent(isHeaderPresent),
  mCollectionID(collectionID)
{
}

template <class _Buffer>
RunTimeRecordImporter<_Buffer>::~RunTimeRecordImporter()
{
}

template <class _Buffer>
RunTimeOperatorActivation * RunTimeRecordImporter<_Buffer>::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeRecordImporterActivation<_Buffer>(reactor, partition, this);
}

template <class _Buffer>
RunTimeRecordImporterActivation<_Buffer>::RunTimeRecordImporterActivation(Reactor * reactor, 
                                                                          partition_t partition,
                                                                          const RunTimeRecordImporter<_Buffer> * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeRecordImporter<_Buffer> > (reactor, partition, runTimeOperator),
  mFileMapping(NULL),
  mStream(NULL),
  mImporter(NULL),
  mState(START),
  mOutputRecord(NULL)
{
}

template <class _Buffer>
RunTimeRecordImporterActivation<_Buffer>::~RunTimeRecordImporterActivation()
{
  delete mStream;
  delete mFileMapping;
  delete mImporter;
}

template <class _Buffer>
void RunTimeRecordImporterActivation<_Buffer>::Start()
{
#ifdef WIN32
  // Get an instance of enum config to prevent reloading
  MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
#endif
  
  // Open for reading.  First test for an empty file since an attempt to
  // create a file mapping for an empty file will fail.  In this case, leave
  // mStream NULL since that will signal that we should write an EOF and exit.
  if (!boost::filesystem::exists(boost::filesystem::wpath(mOperator->mFilename, boost::filesystem::native)))
  {
    std::string utf8Msg;
    ::WideStringToUTF8((boost::wformat(L"Import file '%1%' does not exist") % mOperator->mFilename).str(), utf8Msg);
    throw std::runtime_error(utf8Msg);
  }
  if (!boost::filesystem::is_empty(boost::filesystem::wpath(mOperator->mFilename, boost::filesystem::native)))
  {
    mFileMapping = new typename _Buffer::file_type(mOperator->mFilename);
    mStream = new _Buffer(*mFileMapping, mOperator->mViewSize);
  }
  mImporter = new UTF8_Import_Function_Builder_2<_Buffer >(*this, mOperator->mFormat);
  mState = START;
  HandleEvent(NULL);
}

template <class _Buffer>
void RunTimeRecordImporterActivation<_Buffer>::HandleEvent(Endpoint * ep)
{
  std::string filename;
  ::WideStringToUTF8(mOperator->mFilename, filename);

  switch(mState)
  {
  case START:
    mNumberOfImportedRecords = 0;
    mNumberOfExpectedRecords = 0;

    // We may have a header at the front of the file telling
    // the expected number of records.
    if (mOperator->mIsHeaderPresent)
    {
      if (mStream == NULL || !GetInt(filename, mNumberOfExpectedRecords))
      {
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RecordImport]");
        std::string errMessage = 
          (boost::format("FILE: %1%:  Unexpected format.  Because the MetraFlow script contains \"header=true\", "
                         "this file should begin with an integer indicating the number of records in the file, "
                         "followed by carriage return and line feed.")
            % filename).str();

        logger->logError(errMessage);
        throw std::runtime_error(errMessage);
      }
      int totalNumberOfRecords = GetRowCount(filename) - 1;
      if (totalNumberOfRecords != mNumberOfExpectedRecords)
      {
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RecordImport]");
        std::string errMessage = 
          (boost::format("FILE: %1%:  Records count mismatch. %2% records expected, but %3% records found.")
            % filename
            % mNumberOfExpectedRecords
            % totalNumberOfRecords).str();

        logger->logError(errMessage);
        throw std::runtime_error(errMessage);
      }
    }

    // If we have a header telling us the expected number of records
    // and we have a collectionID, then the Metraflow script writer wants
    // us to create a record in t_batch with the expected number of
    // records.
    if (mOperator->mIsHeaderPresent && mOperator->mCollectionID.size() != 0)
    {
      CreateBatch();
    }

    // If we have the header, but not the collection ID, this might be
    // we will warn the user that we cannot set the expected number of
    // records.
    if (mOperator->mIsHeaderPresent && mOperator->mCollectionID.size() == 0)
    {
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RecordImport]");
        std::string errMessage = (boost::format("Caution. The Metraflow import operator "
                          "for file %1% specifies a header but not a collection ID. "
                          "Without the collection ID, MetraFlow cannot store the "
                          "expected number of records in the batch.") 
                          % filename).str();

        logger->logWarning(errMessage);
    }

    while(true)
    {
      RequestWrite(0);
      mState = WRITE_0;
      return;
    case WRITE_0:
    {
      // Check for EOF by trying to open a window of size 1.
      // Handle the case of an empty file which will result in
      // mStream being NULL.
      boost::uint8_t * dummy;
      if (mStream == NULL || !mStream->open(1, dummy)) 
      {
        Write(mImporter->GetMetadata().AllocateEOF(), ep, true);
        return;
      }
    }
      std::string errMessage;
      record_t tmp = mImporter->Import(*mStream, errMessage);
      mNumberOfImportedRecords++;
      if (tmp)
      {
        Write(tmp, ep);
      }
      else
      {
        MetraFlowLoggerPtr logger;
        logger = MetraFlowLoggerManager::GetLogger("[RecordImport]");

        errMessage = (boost::format("FILE: %1%; RECORD: %2% (1-based):  %3%") 
                      % filename
                      % mNumberOfImportedRecords
                      % errMessage
                      ).str();
        logger->logError(errMessage);
        throw std::runtime_error(errMessage);
      }
    }
  }
}
 
template <class _Buffer>
void RunTimeRecordImporterActivation<_Buffer>::ThrowError(const std::wstring& err)
{
  std::string utf8Err;
  ::WideStringToUTF8(err, utf8Err);
  throw std::runtime_error(utf8Err);
}

template <class _Buffer>
void RunTimeRecordImporterActivation<_Buffer>::CreateBatch()
{
  MetraFlowLoggerPtr logger;
  logger = MetraFlowLoggerManager::GetLogger("[RecordImport]");

  try
  {
    // Open database connection
    COdbcConnectionInfo 
        netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter");
    COdbcConnection connection(netMeter);
    connection.SetAutoCommit(true);

    // Create the batch writer
    COdbcBatchIDWriter batchWriter(netMeter);

    // Create the batch record (if not already present)
    batchWriter.WriteBatchID(mOperator->mCollectionID);
    logger->logDebug(L"Created batch record for: " + mOperator->mCollectionID);

    // Update the n_expected column of the entry
    boost::wformat updateStmt(
      L"UPDATE t_batch "
      L"SET n_expected=%1% "
      L"WHERE tx_name=N'%2%' AND tx_namespace='pipeline'");

    boost::shared_ptr<COdbcStatement> statement(connection.CreateStatement());
    statement->ExecuteUpdateW((updateStmt % mNumberOfExpectedRecords % mOperator->mCollectionID).str());
    logger->logDebug((boost::format("Updated batch record with expected number of records: %1%") % mNumberOfExpectedRecords).str());
  }
  catch (...)
  {
    logger->logError(L"An error occurred attempting to write the expected number "
                     L"of records for the batch " + mOperator->mCollectionID);
  }
}

/** 
 *  Return the total number of existing records in the file.
 */
template <class _Buffer>
int RunTimeRecordImporterActivation<_Buffer>::GetRowCount(const std::string &fullFileName)
{
  int result = 0;
  ifstream ifs(fullFileName);
  string s;
  while( getline( ifs, s ) ) {
    result++;
  }
  return result;
}


/** 
 *  Read the expected number of records from the top of the file.
 *  This should be an integer followed by carriage return and line feed.
 *  This advances our position in the file.
 *  Return true on success and store the expected number of records
 *  in the result reference parameter.
 */
template <class _Buffer>
bool RunTimeRecordImporterActivation<_Buffer>::GetInt(const std::string &fullFileName, unsigned int &result)
{
    result = 0;
    bool weAreExpectingLineFeed = false;

    while (true)
    {
      boost::uint8_t c;

      // Read a character
      if (!mStream->get(c))
      {
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RecordImport]");
        logger->logError((boost::format("FILE: %1%:  Unable to read digits from header line of import file.")
                            % fullFileName).str());
        return false;
      }
      
      // If we were expecteding a linefeed, did we see it (meaning we're all done)?
      if (weAreExpectingLineFeed && c==10)
      {
        return true;
      }

      // Did we expected the line feed, but didn't see it?
      if (weAreExpectingLineFeed)
      {
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RecordImport]");
        logger->logError((boost::format("FILE: %1%:  Missing line feed after carriage return in header line of import file.")
                            % fullFileName).str());
        return false;
      }

      // Did we see a carriage return? If so, we expect a linefeed next.
      if (c==13)
      {
        weAreExpectingLineFeed = true;
        continue;
      }

      // Did we see a digit?
      if (c<'0' || c>'9')
      {
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RecordImport]");
        logger->logError((boost::format("FILE: %1%:  Can't find digits in header line of import file.")
                            % fullFileName).str());
        return false;
      }

      result = result * 10 + (c-'0');

      // Is our result larger than maximum allowed value?
      if (result > 1000000)
      {
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RecordImport]");
        logger->logError((boost::format("FILE: %1%:  Value found in header line (%2%) exceeds maximum supported number of records (1000000).")
                            % fullFileName % result).str());
        return false;
      }
    }

    return false;
}


DesignTimeRecordExporter::DesignTimeRecordExporter()
  :
  mCompression(false)
{
  mInputPorts.insert(this, 0, L"input", false);
}

DesignTimeRecordExporter::~DesignTimeRecordExporter()
{
}

void DesignTimeRecordExporter::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"filename", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetFilename(arg.getNormalizedString());
  }
  else if (arg.is(L"format", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetFormat(arg.getNormalizedString());
  }
  else if (arg.is(L"uncompress", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    SetCompression(arg.getBoolValue());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeRecordExporter* DesignTimeRecordExporter::clone(
                                                      const std::wstring& name,
                                                      std::vector<OperatorArg *>& args, 
                                                      int nInputs, int nOutputs) const
{
  DesignTimeRecordExporter* result = new DesignTimeRecordExporter();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeRecordExporter::SetFilename(const std::wstring& filename)
{
  mFilename = filename;
}

void DesignTimeRecordExporter::SetFormat(const std::wstring& format)
{
  mFormat = format;
}

void DesignTimeRecordExporter::SetCompression(bool compression)
{
  mCompression = compression;
}

class ExportRecordTypeMismatchException : public std::logic_error
{
private:
  std::string CreateErrorString(const DesignTimeOperator& op, const Port& port,
                                const RecordMetadata& exportMetadata);
  std::string CreateErrorString(const DesignTimeOperator& op, const Port& port,
                                const RecordMetadata& exportMetadata, const std::vector<boost::int32_t>& positions);
public:
  METRAFLOW_DECL ExportRecordTypeMismatchException(const DesignTimeOperator& op, const Port& port,
                                                   const RecordMetadata& exportMetadata);
  METRAFLOW_DECL ExportRecordTypeMismatchException(const DesignTimeOperator& op, const Port& port,
                                                   const RecordMetadata& exportMetadata,
                                                   const std::vector<boost::int32_t>& positions);
  METRAFLOW_DECL ~ExportRecordTypeMismatchException();
};

std::string ExportRecordTypeMismatchException::CreateErrorString(const DesignTimeOperator& op, const Port& port,
                                                                 const RecordMetadata& exportMetadata)
{
  // Get the list of extra and missing fields from the export
  // At this point, we require that the export schema and input match exactly.
  for(boost::int32_t i=0; i<exportMetadata.GetNumColumns(); i++)
  {
    if (i>= port.GetMetadata()->GetNumColumns())
    {
      boost::wformat fmt(L"Export column %1% missing from input port %2%(%3%) of operator %4%");
      fmt % exportMetadata.GetColumn(i)->ToString() % port.GetName() % port.GetMetadata()->ToString() % op.GetName();
      std::string msg;
      ::WideStringToUTF8(fmt.str(), msg);
      return msg;
    }

    if (!boost::algorithm::iequals(exportMetadata.GetColumnName(i), port.GetMetadata()->GetColumnName(i)))
    {
      boost::wformat fmt(L"Export column %1% at position %6% of export format \n%7%\n doesn't match input field %5% at position %8% from input port \n%2%(%3%)\n of operator %4%");
      fmt % exportMetadata.GetColumn(i)->ToString() % port.GetName() % port.GetMetadata()->ToString() % op.GetName() % port.GetMetadata()->GetColumn(i)->ToString() % i % exportMetadata.ToString() % i;
      std::string msg;
      ::WideStringToUTF8(fmt.str(), msg);
      return msg;      
    }
  }
      
  boost::wformat fmt(L"Type mismatch between export metadata '%4%' and input port %1%(%2%) of operator '%3%\n");
  fmt % port.GetName() % port.GetMetadata()->ToString() % op.GetName() % exportMetadata.ToString();
  std::string msg;
  ::WideStringToUTF8(fmt.str(), msg);
  return msg;
}

std::string ExportRecordTypeMismatchException::CreateErrorString(const DesignTimeOperator& op, const Port& port,
                                                                 const RecordMetadata& exportMetadata,
                                                                 const std::vector<boost::int32_t>& positions)
{
  std::wstring fieldMismatchMessage;
  // Give field level mismatch information
  for(std::vector<boost::int32_t>::const_iterator it = positions.begin();
      it != positions.end();
      ++it)
  {
    fieldMismatchMessage += (boost::wformat(L"field %1% and field %2%\n") % exportMetadata.GetColumn(*it)->ToString() % port.GetMetadata()->GetColumn(*it)->ToString()).str();
  }
  boost::wformat fmt(L"Type mismatch between %5% on export metadata '%4%' and input port %1%(%2%) of operator '%3%\n");
  fmt % port.GetName() % port.GetMetadata()->ToString() % op.GetName() % exportMetadata.ToString() % fieldMismatchMessage;
  std::string msg;
  ::WideStringToUTF8(fmt.str(), msg);
  return msg;
}

ExportRecordTypeMismatchException::ExportRecordTypeMismatchException(const DesignTimeOperator& op, const Port& port,
                                                                     const RecordMetadata& exportMetadata)
  :
  logic_error(CreateErrorString(op,port, exportMetadata))
{
}

ExportRecordTypeMismatchException::ExportRecordTypeMismatchException(const DesignTimeOperator& op, const Port& port,
                                                                     const RecordMetadata& exportMetadata,
                                                                     const std::vector<boost::int32_t>& positions)
  :
  logic_error(CreateErrorString(op,port, exportMetadata, positions))
{
}

ExportRecordTypeMismatchException::~ExportRecordTypeMismatchException()
{
}

void DesignTimeRecordExporter::type_check()
{
  if (GetMode() != SEQUENTIAL) throw SingleOperatorException(*this, L"RecordExporter must run in sequential mode");

  // Check for existence of directory
  boost::filesystem::wpath parentPath = boost::filesystem::system_complete(mFilename).parent_path();
  if (!boost::filesystem::exists(parentPath))
  {
    throw SingleOperatorException(*this, (boost::wformat(L"Directory '%1%' does not exist") % 
                                          parentPath).str());
  }

  // This has the side effect of creating an empty file.  Should we do this?
  StdioFile file(mFilename, true);
  StdioWriteBuffer<StdioFile> stream(file, 1);
  UTF8_Export_Function_Builder_2<StdioWriteBuffer<StdioFile> > tmp(*this, mFormat);

  // Check that the metadata on the export is compatible with the input.
  const RecordMetadata * metadata = mInputPorts[0]->GetMetadata();
  const RecordMetadata& exportMetadata(tmp.GetMetadata());

  // TODO: Support exporting a projection of the input schema.
  if (metadata->GetNumColumns() != exportMetadata.GetNumColumns())
    throw ExportRecordTypeMismatchException(*this, *mInputPorts[0], exportMetadata);

  // Now check each column.
  std::vector<boost::int32_t> errors;
  for (boost::int32_t i=0; i<metadata->GetNumColumns(); i++)
  {
    if (*metadata->GetColumn(i)->GetPhysicalFieldType() != *exportMetadata.GetColumn(i)->GetPhysicalFieldType())
      errors.push_back(i);
  }
  if (errors.size() > 0)
    throw ExportRecordTypeMismatchException(*this, *mInputPorts[0], exportMetadata, errors);
}

RunTimeOperator * DesignTimeRecordExporter::code_generate(partition_t maxPartition)
{
  if (mCompression)
    return new RunTimeRecordExporter<StdioWriteBuffer<ZLIBFile> >(mName, mFormat, mFilename, 64*1024);
  else
    return new RunTimeRecordExporter<StdioWriteBuffer<StdioFile> >(mName, mFormat, mFilename, 64*1024);
}

void DesignTimeRecordExporter::ThrowError(const std::wstring& err)
{
  throw SingleOperatorException(*this, err);
}

template <class _Buffer>
RunTimeRecordExporter<_Buffer>::RunTimeRecordExporter()
  :
  mViewSize(0)
{
}

template <class _Buffer>
RunTimeRecordExporter<_Buffer>::RunTimeRecordExporter(const std::wstring& name, 
                                                      const std::wstring& format,
                                                      const std::wstring& filename,
                                                      boost::int32_t viewSize)
  :
  RunTimeOperator(name),
  mFormat(format),
  mFilename(filename),
  mViewSize(viewSize)
{
}

template <class _Buffer>
RunTimeRecordExporter<_Buffer>::~RunTimeRecordExporter()
{
}

template <class _Buffer>
RunTimeOperatorActivation * RunTimeRecordExporter<_Buffer>::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeRecordExporterActivation<_Buffer>(reactor, partition, this);
}

template <class _Buffer>
RunTimeRecordExporterActivation<_Buffer>::RunTimeRecordExporterActivation(Reactor * reactor, 
                                                                          partition_t partition,
                                                                          const RunTimeRecordExporter<_Buffer> * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeRecordExporter<_Buffer> >(reactor, partition, runTimeOperator),
  mFileMapping(NULL),
  mStream(NULL),
  mExporter(NULL),
  mState(START),
  mOutputRecord(NULL)
{
}

template <class _Buffer>
RunTimeRecordExporterActivation<_Buffer>::~RunTimeRecordExporterActivation()
{
  delete mStream;
  delete mFileMapping;
  delete mExporter;
}

template <class _Buffer>
void RunTimeRecordExporterActivation<_Buffer>::Start()
{
  // Get an instance of enum config to prevent reloading
  MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
  
  // Open for writing.
  mFileMapping = new typename _Buffer::file_type(mOperator->mFilename, true);
  mStream = new _Buffer(*mFileMapping, mOperator->mViewSize);
  mExporter = new UTF8_Export_Function_Builder_2<_Buffer >(*this, mOperator->mFormat);

  mState = START;
  HandleEvent(NULL);
}

template <class _Buffer>
void RunTimeRecordExporterActivation<_Buffer>::HandleEvent(Endpoint * ep)
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
      record_t tmp;
      Read(tmp, ep);
      if (!mExporter->GetMetadata().IsEOF(tmp))
      {
        // TODO: Handle errors.
        try
        {
          mExporter->Export(tmp, *mStream);
        }
        catch(NullFieldExportException & nfee)
        {
          // Find the associated field and give an informative user level message
          for(boost::int32_t i=0; i<mExporter->GetMetadata().GetNumColumns(); i++)
          {
            if(nfee.GetFieldAddress().GetOffset() == mExporter->GetMetadata().GetColumn(i)->GetOffset())
            {
              std::string utf8OperatorName;
              ::WideStringToUTF8(GetName(), utf8OperatorName);
              std::string utf8ColumnName;
              ::WideStringToUTF8(mExporter->GetMetadata().GetColumnName(i), utf8ColumnName);
              throw std::runtime_error(
                (boost::format("In operator '%1%', unexpected null value on field '%2%' of record:\n%3%\nAdd null value specification to exporter to encode null") % 
                 utf8OperatorName % 
                 utf8ColumnName % 
                 mExporter->GetMetadata().PrintMessage(tmp)).str());
            }
          }

          // Should never get here, but throw something vaguely descriptive just in case.
          throw std::runtime_error("Null value encountered on field without null handling configured");
        }

        mExporter->GetMetadata().Free(tmp);
      }
      else
      {
        // Done.  Close up shop.
        delete mStream;
        mStream = NULL;
        delete mFileMapping;
        mFileMapping = NULL;
        delete mExporter;
        mExporter = NULL;
        return;
      }
    }
    }
  }
}
 
template <class _Buffer>
void RunTimeRecordExporterActivation<_Buffer>::ThrowError(const std::wstring& err)
{
  std::string utf8Err;
  ::WideStringToUTF8(err, utf8Err);
  throw std::runtime_error(utf8Err);
}

// class SkipListNode
// {
//   _T Key;
//   // Next in the list at a particular level
//   SkipListNode * Right;
//   // Point down to the node preceeding the gap this node
//   // covers.
//   SkipListNode * Down;
// };

// class SkipList
// {
// private:
//   SkipListNode * mHead;
//   SkipListNode * mBottom;
//   SkipListNode * mTail;
// public:
//   SkipList()
//   {
//     mBottom = new SkipListNode();
//     mBottom->Right = mBottom;
//     mBottom->Down = mBottom;
//   }

//   ~SkipList()
//   {
//     delete mBottom;
//   }
//   bool Insert(const _T & key)
//   {
//     SkipListNode * x(mHead);

//     mBottom->Key = key;
//     for(; x!=mBottom; x = x->Down)
//     {
//       while(key > x->Key)
//         x = x->Right;

//       // We already have the key. No duplicates allowed.
//       if(x->Down == mBottom &&
//          key == x->Key)
//         return false;

//       // At this point, key <= x->Key
//       // Two cases.
//       // 1) We are at the lowest level and by the above we are positioned right
//       // behind where we want to insert.
//       // 2) We are not at the lowest level, but need to check the gap below us.
//       // In this 1-2-3 skip list, we allow no more than 3 elements below us.
//       // The case in which there are 3 can be checked by looking comparing keys as below.
//       if(x->Down == mBottom ||
//          x->Key == x->Down->Right->Right->Right->Key)
//       {
//         SkipListNode * t = new SkipListNode();
//         t->Right = x->Right;
//         t->Down = x->Down->Right->Right;
//         x->Right = t;
//         t->Key = x->Key;
//         x->Key = x->Down->Right->Key;
//       }
//     }
    
//     if (mHead->Right != mTail)
//     {
//       SkipListNode * t = new SkipListNode();
//       t->Down = mHead;
//       t->Right = mTail;
//       t->Key = mMax;
//       mHead = t;
//     }

//     return true;
//   }

//   SkipListNode * Search(const _T& key)
//   {
//     SkipListNode * x = mHead;
//     mBottom->Key = key;
//     while(key != x->Key)
//       x = key < x->Key ? x->Down : x->Right;
//     return x;
//   }
// };

BPlusTreeNonLeafPage::BPlusTreeNonLeafPage()
{
  // This is OK because we have no virutal function table
  // and no inheritence.
  memset(this, 0, sizeof(BPlusTreeNonLeafPage));
}

BPlusTreeNonLeafPage::~BPlusTreeNonLeafPage()
{
}

// This search positions one at the first entry greater than the key argument.
void BPlusTreeNonLeafPage::Search(const boost::uint8_t * key, boost::uint16_t keyLength, SearchState& search)
{
  if (mPrefixLength > 0)
  {
    if (mPrefixLength >= keyLength)
      throw std::runtime_error("Key length smaller than key prefix");
    if (0 != memcmp(key, mData, mPrefixLength))
      throw std::runtime_error("Key doesn't share page's prefix");
    key += mPrefixLength;
    keyLength -= mPrefixLength;
  }

  // TODO: Make this binary search.
  // Coming out of here, it points to the slot number we will
  // descend into.
  for(search.Iterator=begin(); search.Iterator != end(); search.Iterator += 1)
  {
    search.Comparison = memcmp(GetData(search.Iterator), key, keyLength);
    if (0 < search.Comparison)
    {
      break;
    }
  }
}

// Inserting only happens in response to a split.  The API here doesn't really reflect 
// that.
bool BPlusTreeNonLeafPage::Insert(FixedSizeRecordLengthPolicy<BPlusTreeNonLeafPage>& recordPolicy,
                                  BPlusTreeNonLeafPage::iterator& it, 
                                  const boost::uint8_t * key, 
                                  boost::uint16_t keyLength, 
                                  pageid_t value)
{
  pageid_t * pg=NULL;
  if(it != end())
  {
    // "it" is the <key,ptr> pair referencing the page that was split.
    // The existing key needs to point to the new page.  The page is
    // currently points to needs to be inserted with the new hi key.
    pg = (reinterpret_cast<pageid_t *>(GetData(it) + recordPolicy.GetCompressedKeySize(GetData(it), *this)));
    // Slide slots over one space. This is a little
    // tricky because slots are numbered backwards
    // relative to memory.  Set the new <key,oldPage> pair.
    memmove(end().operator->(), (end()-1).operator->(), sizeof(mSlot)*(end()-it));
  }
  else
  {
    pg = &mLastPage;
  }
  pageid_t oldPage = *pg;
  *pg = value;
  *it = mFreeStart;
  memcpy(reinterpret_cast<boost::uint8_t *>(this) + mFreeStart, key, keyLength);
  mFreeStart += keyLength;
  memcpy(reinterpret_cast<boost::uint8_t *>(this) + mFreeStart, &oldPage, sizeof(pageid_t));
  mFreeStart += sizeof(pageid_t);
  mFreeBytes -= (keyLength + sizeof(pageid_t) + sizeof(mSlot));
  mNumRecords += 1;
  return true;
}

// Inserting only happens in response to a split.  The API here doesn't really reflect 
// that.
bool BPlusTreeNonLeafPage::InsertWithNewKey(BPlusTreeNonLeafPage::iterator& it, const boost::uint8_t * key, boost::uint16_t keyLength, pageid_t value)
{
  static const boost::uint16_t valueLength(sizeof(pageid_t));
  FixedSizeRecordLengthPolicy<BPlusTreeNonLeafPage> recordPolicy(keyLength, valueLength);

  // Since we split to the right, in the non leaf case we are always inserting
  // to the left.  The insert results an existing <key,ptr> pair being modified
  // point to the right page, <key, value> and a new key ptr pair <key,ptr> being
  // inserted pointing to the old (split) page.  Note that it is possible for the
  // split page to be the last page in which case there is no key but just a pointer.
  // That pointer will be updated and a new <key,ptr> pair will be appended to the
  // end of the slot array.
  if (mPrefixLength > 0)
  {
    if (mPrefixLength >= keyLength)
      throw std::runtime_error("Key length smaller than key prefix");
    if (0 != memcmp(key, mData, mPrefixLength))
      throw std::runtime_error("Key doesn't share page's prefix");
    key += mPrefixLength;
    keyLength -= mPrefixLength;
  }
  
  // Make sure we have room for this key.  Right now, this is position
  // independent.
  if (mFreeBytes < sizeof(mSlot) + keyLength + valueLength)
  {
    return false;
  }

  if(it != end())
  {
    // Slide slots over one space. This is a little
    // tricky because slots are numbered backwards
    // relative to memory.  Set the new <key,oldPage> pair.
    memmove(end().operator->(), (end()-1).operator->(), sizeof(mSlot)*(end()-it));
  }
  *it = mFreeStart;
  memcpy(reinterpret_cast<boost::uint8_t *>(this) + mFreeStart, key, keyLength);
  mFreeStart += keyLength;
  memcpy(reinterpret_cast<boost::uint8_t *>(this) + mFreeStart, &value, sizeof(pageid_t));
  mFreeStart += sizeof(pageid_t);
  mFreeBytes -= (keyLength + sizeof(pageid_t) + sizeof(mSlot));
  mNumRecords += 1;
  return true;  
}

// Inserting only happens in response to a split.  The API here doesn't really reflect 
// that.
bool BPlusTreeNonLeafPage::Insert(BPlusTreeNonLeafPage::iterator& it, const boost::uint8_t * key, boost::uint16_t keyLength, pageid_t value)
{
  static const boost::uint16_t valueLength(sizeof(pageid_t));
  FixedSizeRecordLengthPolicy<BPlusTreeNonLeafPage> recordPolicy(keyLength, valueLength);

  // Since we split to the right, in the non leaf case we are always inserting
  // to the left.  The insert results an existing <key,ptr> pair being modified
  // point to the right page, <key, value> and a new key ptr pair <key,ptr> being
  // inserted pointing to the old (split) page.  Note that it is possible for the
  // split page to be the last page in which case there is no key but just a pointer.
  // That pointer will be updated and a new <key,ptr> pair will be appended to the
  // end of the slot array.
  if (mPrefixLength > 0)
  {
    if (mPrefixLength >= keyLength)
      throw std::runtime_error("Key length smaller than key prefix");
    if (0 != memcmp(key, mData, mPrefixLength))
      throw std::runtime_error("Key doesn't share page's prefix");
    key += mPrefixLength;
    keyLength -= mPrefixLength;
  }
  
  // Make sure we have room for this key.  Right now, this is position
  // independent.
  if (mFreeBytes < sizeof(mSlot) + keyLength + valueLength)
  {
    return false;
  }

  return Insert(recordPolicy, it, key, keyLength, value);
}

// Inserting only happens in response to a split.  The API here doesn't really reflect 
// that.
bool BPlusTreeNonLeafPage::Insert(const boost::uint8_t * key, boost::uint16_t keyLength, pageid_t value)
{
  static const boost::uint16_t valueLength(sizeof(pageid_t));
  FixedSizeRecordLengthPolicy<BPlusTreeNonLeafPage> recordPolicy(keyLength, valueLength);

  // Since we split to the right, in the non leaf case we are always inserting
  // to the left.  The insert results an existing <key,ptr> pair being modified
  // point to the right page, <key, value> and a new key ptr pair <key,ptr> being
  // inserted pointing to the old (split) page.  Note that it is possible for the
  // split page to be the last page in which case there is no key but just a pointer.
  // That pointer will be updated and a new <key,ptr> pair will be appended to the
  // end of the slot array.
  if (mPrefixLength > 0)
  {
    if (mPrefixLength >= keyLength)
      throw std::runtime_error("Key length smaller than key prefix");
    if (0 != memcmp(key, mData, mPrefixLength))
      throw std::runtime_error("Key doesn't share page's prefix");
    key += mPrefixLength;
    keyLength -= mPrefixLength;
  }

  // Special case to handle empty leaf (not a real case but convenient for
  // testing).
  ASSERT(!IsEmpty());

  // Make sure we have room for this key.  Right now, this is position
  // independent.
  if (mFreeBytes < sizeof(mSlot) + keyLength + valueLength)
  {
    return false;
  }

  // Search to find insert position.
  // TODO: Make this binary search.
  // Coming out of here, i is slot number we will
  // insert into.  
  iterator it;
  for(it=begin(); it != end(); it += 1)
  {
    boost::int32_t cmp = memcmp(GetData(it), key, keyLength);
    if (0 < cmp)
      break;
  }

  return Insert(recordPolicy, it, key, keyLength, value);

//   pageid_t * pg=NULL;
//   if(it != end())
//   {
//     // "it" is the <key,ptr> pair referencing the page that was split.
//     // The existing key needs to point to the new page.  The page is
//     // currently points to needs to be inserted with the new hi key.
//     pg = (reinterpret_cast<pageid_t *>(GetData(it) + recordPolicy.GetCompressedKeySize(GetData(it), *this)));
//     // Slide slots over one space. This is a little
//     // tricky because slots are numbered backwards
//     // relative to memory.  Set the new <key,oldPage> pair.
//     memmove(end().operator->(), (end()-1).operator->(), sizeof(mSlot)*(end()-it));
//   }
//   else
//   {
//     pg = &mLastPage;
//   }
//   pageid_t oldPage = *pg;
//   *pg = value;
//   *it = mFreeStart;
//   memcpy(reinterpret_cast<boost::uint8_t *>(this) + mFreeStart, key, keyLength);
//   mFreeStart += keyLength;
//   memcpy(reinterpret_cast<boost::uint8_t *>(this) + mFreeStart, &oldPage, valueLength);
//   mFreeStart += valueLength;
//   mFreeBytes -= (keyLength + valueLength + sizeof(mSlot));
//   mNumRecords += 1;
//   return true;
}

void BPlusTreeNonLeafPage::Init(const boost::uint8_t * lo, const boost::uint8_t * hi, boost::uint16_t keyLength, pageid_t child)
{
  mFreeBytes = BPlusTreeParameters::PAGE_SIZE - GetHeaderLength();
  mFreeStart = GetHeaderLength();

  mNumRecords = 0;
  mPageFlags = 0;
  mPrefixLength = GetPrefixSize(lo, keyLength, hi, keyLength);
  mFreeBytes -= mPrefixLength;
  memcpy(reinterpret_cast<boost::uint8_t *>(this) + mFreeStart, lo, mPrefixLength);
  mFreeStart += mPrefixLength;
  mLastPage = child;
}

boost::uint8_t BPlusTreeNonLeafPage::GetPrefixSize(const boost::uint8_t * a, boost::uint16_t a_len,
                                            const boost::uint8_t * b, boost::uint16_t b_len)
{
  boost::uint32_t min_arg_len = std::max<boost::uint16_t>(a_len, b_len);
  boost::uint32_t max_possible = std::max<boost::uint32_t>(min_arg_len, std::numeric_limits<boost::uint8_t>::max());

  const boost::uint8_t * a_begin = a;
  const boost::uint8_t * a_end = a + max_possible + 1;
  while(a != a_end)
  {
    if (*a++ != *b++) break;
  }

  return a - a_begin - 1;
}

void BPlusTreeNonLeafPage::Compress(boost::uint16_t keySize, boost::uint16_t valueSize)
{
  ASSERT(valueSize == sizeof(pageid_t));
  FixedSizeRecordLengthPolicy<BPlusTreeNonLeafPage> recordPolicy(keySize, valueSize);
  // TODO: Optimize this.
  // Make a copy of the slot array.  Then sort it.
  // Walk through in sorted order and eliminate gaps.
  // Store the permutation of the sort by putting the offset
  // and slot index in the sorted array.
  std::vector<boost::uint32_t> orderedSlots;
  orderedSlots.reserve(end() - begin());
  for(iterator slotIt = begin(); slotIt != end(); ++slotIt)
  {
    orderedSlots.push_back((boost::uint32_t(*slotIt) << 16) | (slotIt - begin()));
  }
  std::sort(orderedSlots.begin(), orderedSlots.end());

  boost::uint8_t * buffer = reinterpret_cast<boost::uint8_t *>(this) + GetHeaderLength() + GetPrefixLength();
  for(std::vector<boost::uint32_t>::iterator it = orderedSlots.begin();
      orderedSlots.end() != it;
      ++it)
  {
    boost::uint32_t dataOffset = (*it & 0xffff0000) >> 16;
    boost::uint32_t slotNumber = (*it & 0x0000ffff);
    const boost::uint8_t * data = reinterpret_cast<boost::uint8_t *>(this) + dataOffset;
    boost::uint16_t dataLength = recordPolicy.GetCompressedRecordSize(data, *this);
    if (buffer != data)
    {
      memmove(buffer, data, dataLength);
      *(begin() + slotNumber) = buffer - reinterpret_cast<boost::uint8_t *>(this);
    }
    buffer += dataLength;
  }
  mFreeStart = buffer - reinterpret_cast<boost::uint8_t *>(this);
}

// Split a b-tree leaf page 50% with the new page being to the right (higher keys).
// Return the new high key for "this" page (the new page gets the old high key).
// NOTE: The caller must provide a buffer for newHiKey!  This is because the key may
// not be contiguous in this page due to prefixing.
void BPlusTreeNonLeafPage::SplitRight(BPlusTreeNonLeafPage& rightPage, 
                                      boost::uint8_t * keyToInsert, boost::uint16_t keySize, boost::uint16_t valueSize, 
                                      const boost::uint8_t * oldLoKey, const boost::uint8_t * oldHiKey,
                                      boost::uint8_t * newHiKey, BPlusTreeNonLeafPage::iterator& insertPosition, 
                                      bool& insertOnRight, bool& insertWithNewKey)
{
  insertWithNewKey = false;
  // Our prefix must be a prefix of the old high key.
  ASSERT(0 == memcmp(mData, oldHiKey, mPrefixLength));
  boost::uint16_t adjustedKeySize = keySize - mPrefixLength;
  FixedSizeRecordLengthPolicy<BPlusTreeNonLeafPage> recordPolicy(keySize, valueSize);

  // We want to keep 50% of the data in this page.  Make the calculation
  // assuming the data has already been inserted.  Assume current prefix (can be no worse).
  // The goal of 50% of the data is approximate.  There are also constraints to be obeyed.
  // We must guarantee that we don't overflow the new page.  The new page can't be any
  // bigger than the original size of the current page unless the new key is bigger than
  // the original page.
  boost::uint16_t additional = adjustedKeySize + valueSize + sizeof(mSlot);
  boost::uint16_t originalSize = sizeof(BPlusTreeNonLeafPage);
  originalSize -= GetHeaderLength();
  originalSize -= GetPrefixLength();
  originalSize -= GetFreeBytes();
  // For this non-leaf case, we start with assumption that we will always move
  // the last page pointer to the rightPage (independently of the result of
  // simulation calculation below that is used to pick the split key).  This allows
  // us to convert a <key,ptr> pair into last ptr and hence save the size of a key, value and a slot.
  // The line below simulates that operation.
  originalSize -= adjustedKeySize + valueSize + sizeof(mSlot);
  boost::uint16_t leftSize = originalSize + additional;
  boost::uint16_t rightSize = 0;
  boost::uint16_t keep = leftSize/2;

  // The idea here is reverse iterate over entries to calculate amount of
  // data to be moved into the new right child and to keep in the left child.
  // The iteration logic is a bit strange, because we want to pretend that there
  // is an additional entry in the list.  This is handled by starting the iteration
  // at end() instead of end()-1 and then using the new_entry_flag to keep track of
  // whether we have consumed the (pretend) additional entry.
  //
  // Because of the above argument about always moving last page, we assume that
  // the last slot has already been removed/converted to last page.  Thus here
  // we start iteration at end()-1.
  ReverseArrayIterator<boost::uint16_t>::difference_type new_entry_flag = insertPosition == end() ? 0 : 1;
  ReverseArrayIterator<boost::uint16_t> it = end()-1;
  while(true)
  {
    boost::uint16_t c;
    if (it == insertPosition)
    {
      c = additional;
      new_entry_flag = 0;
    }
    else
    {
      c = recordPolicy.GetCompressedRecordSize(GetData(it-new_entry_flag), *this) + sizeof(mSlot);
    }
    leftSize -= c;
    rightSize += c;

    if ((leftSize < keep && leftSize + c <= originalSize) ||
        rightSize > originalSize)
    {
      // Gone too far.  
      leftSize += c;
      rightSize -= c;
      // Put back the fake entry
      // if we just consumed it.
      // Also, take account of the fact that "it" is
      // actually pointing 1 position to the right if
      // new_entry_flag = 1 and adjust for this.
      if (it == insertPosition)
      {
        new_entry_flag = 1;
      }
      else
      {
        // Position "it" on the entry to move.
        it = it + (1 - new_entry_flag);
      }
      break;
    }
    
    if (it == begin())
    {
      // Can we get here?????  At this point, leftSize == 0
      // and rightSize = originalSize + additional;
      // In any case, we can't leave an empty left page as a result of 
      // a split, so increment.
      it += 1;
      break;
    }
    else
      it -=1;
  }

  // Coming out of the above, "it" is positioned on the key of the current
  // page that will be the new "last child page" of this.  The associated page will become 
  // mLastPage.

  // Here "insertPosition" is positioned on a page that has been split
  // and our goal is to make space for the new page pointer.
  // We take the approach that we are going to reuse any existing key
  // and modify its page pointer to point to the new right page.
  //
  // The $64K question: the split of this page is triggered by the split
  // of a child.  Do we allow the left and right sides of the split child
  // to go onto the left and right of this split non leaf?
  //
  // Take the key we are splitting on and the key prior to it and generate
  // the new hi key for the split page.  If the key to insert is the first
  // key on the right page, then we must use it get the correct hi key
  // for the split page.  Similarly if the new last key on the split page is
  // the key to insert then we use it.
  // TODO: Implement suffix compression.
  if (it == insertPosition && 0 == new_entry_flag)
  {
    if (0 == new_entry_flag)
    {
      memcpy(newHiKey, keyToInsert, keySize);
      // HACK: I really don't see how else to handle this right now. 
      // When I am splitting right at the insert position, I may want
      // put the right page of the child split on the right of this split
      // but leave the old split child page on the left of this split.  
      // In that case the new split key (keyToInsert) becomes
      // the new high key for the page, but we want the OLD high key for
      // split page to be the new high key for right page of the split.
      // The issue is that OLD high key is about to be removed from 
      // the face of the planet because its page becomes last page and
      // the split key becomes the new high key.  The hack is that
      // we MODIFY the keyToInsert at this point to be the OLD high key.
      // This will be the right thing to do when we go back to insert
      // the right page of the child split in the new right page here
      // but the code is very difficult to understand.
      memcpy(keyToInsert + mPrefixLength, GetData(it), adjustedKeySize);
    }
  }
  else
  {
    memcpy(newHiKey, mData, mPrefixLength);
    memcpy(newHiKey + mPrefixLength, GetData(it), adjustedKeySize);
  }

  // Create the new page using the calculated keys as prefixes and current
  // last page as last page.
  rightPage.Init(newHiKey, oldHiKey, keySize, mLastPage);
  rightPage.mNumRecords = end() - it - 1;

  // Correct insert position.
  if (it == insertPosition && 0 == new_entry_flag)
  {
    if (0 == new_entry_flag)
    {
      // Split child page remains on left, right child page goes on the right.
      insertPosition = rightPage.begin();
      insertOnRight = true;
      insertWithNewKey = true;
    }
    else
    {
      // Split child page and right child page remain on left.
      //insertPosition = it;
      insertOnRight = false;
    }
  }
  else
  {
    if (insertPosition > it)
    {
      insertOnRight = true;
      insertPosition = rightPage.begin() + (insertPosition - it) - 1;
    }
    else
    {
      insertOnRight = false;
      // insertPosition = insertPosition;
    }
  }

  // Here, "it" just behind the <ptr,key> pairs to be moved.
  iterator current_end(end());
  if (it+1 != current_end)
  {
    // Split the current entries
    iterator target_it = rightPage.begin();
    iterator copy_it = it+1;
    boost::uint16_t offset = rightPage.GetPrefixLength() - mPrefixLength;
    while(copy_it != current_end)
    {
      boost::uint16_t to_copy = recordPolicy.GetCompressedRecordSize(GetData(copy_it), *this) - offset;
      *target_it = rightPage.mFreeStart;
      memcpy(rightPage.GetData(target_it), 
             GetData(copy_it) + offset, 
             to_copy);
      rightPage.mFreeStart += to_copy;
      rightPage.mFreeBytes -= (to_copy + sizeof(mSlot));
      mFreeBytes += to_copy + sizeof(mSlot);
      target_it += 1; 
      copy_it += 1;
    }    
    // TODO: Recalculate the prefix for existing page, splitting a page can result in 
    // an increase in the length of the prefix of the existing page too.
    mNumRecords -= (current_end - it - 1);
  }
  
  ASSERT(end() == it + 1);
  // Convert last page pointer of split page to special location.  Do a memcpy
  // because we cannont guarantee alignment of the source.
  memcpy(&mLastPage, 
         reinterpret_cast<const boost::uint8_t *>(this) + *(it) + adjustedKeySize, 
         valueSize);
  mNumRecords -= 1;
  ASSERT(end() == it);

  // Compress the current page.
  Compress(keySize, valueSize);
}

BPlusTreePage::BPlusTreePage()
{
  // This is OK because we have no virutal function table
  // and no inheritence.
  memset(this, 0, sizeof(BPlusTreePage));
}

BPlusTreePage::~BPlusTreePage()
{
}

// This search positions one at the first entry greater than or equal to 
// the argument.
void BPlusTreePage::Search(const boost::uint8_t * key, boost::uint16_t keyLength, SearchState& search)
{
  if (mPrefixLength > 0)
  {
    if (mPrefixLength >= keyLength)
      throw std::runtime_error("Key length smaller than key prefix");
    if (0 != memcmp(key, mData, mPrefixLength))
      throw std::runtime_error("Key doesn't share page's prefix");
    key += mPrefixLength;
    keyLength -= mPrefixLength;
  }

  // Search to find insert position.
  // TODO: Make this binary search.
  // Coming out of here, it points to the slot number we will
  // insert into.
  for(search.Iterator=begin(); search.Iterator != end(); search.Iterator += 1)
  {
    search.Comparison = memcmp(GetData(search.Iterator), key, keyLength);
    if (0 <= search.Comparison)
      break;
  }
}

bool BPlusTreePage::Insert(const boost::uint8_t * key, boost::uint16_t keyLength, const boost::uint8_t * value, boost::uint16_t valueLength)
{
  if (mPrefixLength > 0)
  {
    if (mPrefixLength >= keyLength)
      throw std::runtime_error("Key length smaller than key prefix");
    if (0 != memcmp(key, mData, mPrefixLength))
      throw std::runtime_error("Key doesn't share page's prefix");
    key += mPrefixLength;
    keyLength -= mPrefixLength;
  }

  // Make sure we have room for this key.  Right now, this is position
  // independent.
  if (mFreeBytes < sizeof(mSlot) + keyLength + valueLength)
  {
    return false;
  }

  // Search to find insert position.
  // TODO: Make this binary search.
  // Coming out of here, i is slot number we will
  // insert into.
  iterator it;
  for(it=begin(); it != end(); it += 1)
  {
    boost::int32_t cmp = memcmp(GetData(it), key, keyLength);
    if (0 == cmp)
    {
      throw std::runtime_error("Not handling non-unique btree's yet");
    }
    if (0 < cmp)
      break;
  }
  if(it != end())
  {
    // Slide slots over one space. This is a little
    // tricky because slots are numbered backwards
    // relative to memory.
    memmove(end().operator->(), (end()-1).operator->(), sizeof(mSlot)*(end()-it));
  }
  *it = mFreeStart;
  memcpy(reinterpret_cast<boost::uint8_t *>(this) + mFreeStart, key, keyLength);
  mFreeStart += keyLength;
  memcpy(reinterpret_cast<boost::uint8_t *>(this) + mFreeStart, value, valueLength);
  mFreeStart += valueLength;
  mFreeBytes -= (keyLength + valueLength + sizeof(mSlot));
  mNumRecords += 1;

  // Clear the empty bit if needed.
  ClearEmpty();

  return true;
}

void BPlusTreePage::Init()
{
  mFreeBytes = BPlusTreeParameters::PAGE_SIZE - GetHeaderLength();

  mFreeStart = GetHeaderLength();

  mNumRecords = 0;
  // Assume fixed length for the moment;
  mPageFlags = BPlusTreeParameters::LEAF | BPlusTreeParameters::EMPTY;
  mPrefixLength = 0;
  mPrevious = NULL;
  mNext = NULL;
}

void BPlusTreePage::Init(const boost::uint8_t * lo, const boost::uint8_t * hi, boost::uint16_t keyLength)
{
  mFreeBytes = BPlusTreeParameters::PAGE_SIZE - GetHeaderLength();
  mFreeStart = GetHeaderLength();

  mNumRecords = 0;
  mPageFlags = BPlusTreeParameters::LEAF | BPlusTreeParameters::EMPTY;
  mPrefixLength = GetPrefixSize(lo, keyLength, hi, keyLength);
  mFreeBytes -= mPrefixLength;
  memcpy(reinterpret_cast<boost::uint8_t *>(this) + mFreeStart, lo, mPrefixLength);
  mFreeStart += mPrefixLength;
  mPrevious = NULL;
  mNext = NULL;
}

boost::uint8_t BPlusTreePage::GetPrefixSize(const boost::uint8_t * a, boost::uint16_t a_len,
                                     const boost::uint8_t * b, boost::uint16_t b_len)
{
  boost::uint32_t min_arg_len = std::max<boost::uint16_t>(a_len, b_len);
  boost::uint32_t max_possible = std::max<boost::uint32_t>(min_arg_len, std::numeric_limits<boost::uint8_t>::max());

  const boost::uint8_t * a_begin = a;
  const boost::uint8_t * a_end = a + max_possible + 1;
  while(a != a_end)
  {
    if (*a++ != *b++) break;
  }

  return a - a_begin - 1;
}

void BPlusTreePage::Compress(boost::uint16_t keySize, boost::uint16_t valueSize)
{
  FixedSizeRecordLengthPolicy<BPlusTreePage> recordPolicy(keySize, valueSize);
  // TODO: Optimize this.
  // Make a copy of the slot array.  Then sort it.
  // Walk through in sorted order and eliminate gaps.
  // Store the permutation of the sort by putting the offset
  // and slot index in the sorted array.
  std::vector<boost::uint32_t> orderedSlots;
  orderedSlots.reserve(end() - begin());
  for(iterator slotIt = begin(); slotIt != end(); ++slotIt)
  {
    orderedSlots.push_back((boost::uint32_t(*slotIt) << 16) | (slotIt - begin()));
  }
  std::sort(orderedSlots.begin(), orderedSlots.end());

  boost::uint8_t * buffer = reinterpret_cast<boost::uint8_t *>(this) + GetHeaderLength() + GetPrefixLength();
  for(std::vector<boost::uint32_t>::iterator it = orderedSlots.begin();
      orderedSlots.end() != it;
      ++it)
  {
    boost::uint32_t dataOffset = (*it & 0xffff0000) >> 16;
    boost::uint32_t slotNumber = (*it & 0x0000ffff);
    const boost::uint8_t * data = reinterpret_cast<boost::uint8_t *>(this) + dataOffset;
    boost::uint16_t dataLength = recordPolicy.GetCompressedRecordSize(data, *this);
    if (buffer != data)
    {
      memmove(buffer, data, dataLength);
      *(begin() + slotNumber) = buffer - reinterpret_cast<boost::uint8_t *>(this);
    }
    buffer += dataLength;
  }
  mFreeStart = buffer - reinterpret_cast<boost::uint8_t *>(this);
}

// Split a b-tree leaf page 50% with the new page being to the right (higher keys).
// Return the new high key for "this" page (the new page gets the old high key).
// NOTE: The caller must provide a buffer for newHiKey!  This is because the key may
// not be contiguous in this page due to prefixing.
void BPlusTreePage::SplitLeafRight(BPlusTreePage& rightPage, 
                                   const boost::uint8_t * keyToInsert, boost::uint16_t keySize, boost::uint16_t valueSize, 
                                   const boost::uint8_t * oldLoKey, const boost::uint8_t * oldHiKey,
                                   boost::uint8_t * newHiKey, BPlusTreePage::iterator& insertPosition, bool& insertOnRight)
{
  // Our prefix must be a prefix of the old high key.
  ASSERT(0 == memcmp(mData, oldHiKey, mPrefixLength));
  boost::uint16_t adjustedKeySize = keySize - mPrefixLength;
  FixedSizeRecordLengthPolicy<BPlusTreePage> recordPolicy(keySize, valueSize);

  // We want to keep 50% of the data in this page.  Make the calculation
  // assuming the data has already been inserted.  Assume current prefix (can be no worse).
  // The goal of 50% of the data is approximate.  There are also constraints to be obeyed.
  // We must guarantee that we don't overflow the new page.  The new page can't be any
  // bigger than the original size of the current page unless the new key is bigger than
  // the original page.
  boost::uint16_t additional = adjustedKeySize + valueSize + sizeof(mSlot);
  boost::uint16_t originalSize = sizeof(BPlusTreePage);
  originalSize -= GetHeaderLength();
  originalSize -= GetPrefixLength();
  originalSize -= GetFreeBytes();
  boost::uint16_t leftSize = originalSize + additional;
  boost::uint16_t rightSize = 0;
  boost::uint16_t keep = leftSize/2;

  // The idea here is reverse iterate over entries to calculate amount of
  // data to be moved into the new right child and to keep in the left child.
  // The iteration logic is a bit strange, because we want to pretend that there
  // is an additional entry in the list.  This is handled by starting the iteration
  // at end() instead of end()-1 and then using the new_entry_flag to keep track of
  // whether we have consumed the (pretend) additional entry.
  ReverseArrayIterator<boost::uint16_t>::difference_type new_entry_flag = 1;
  ReverseArrayIterator<boost::uint16_t> it = end();
  while(true)
  {
    boost::uint16_t c;
    if (it == insertPosition)
    {
      c = additional;
      new_entry_flag = 0;
    }
    else
    {
      c = recordPolicy.GetCompressedRecordSize(GetData(it-new_entry_flag), *this) + sizeof(mSlot);
    }
    leftSize -= c;
    rightSize += c;

    if ((leftSize < keep && leftSize + c <= originalSize) ||
        rightSize > originalSize)
    {
      // Gone too far.  
      leftSize += c;
      rightSize -= c;
      // Put back the fake entry
      // if we just consumed it.
      // Also, take account of the fact that "it" is
      // actually pointing 1 position to the right if
      // new_entry_flag = 1 and adjust for this.
      if (it == insertPosition)
      {
        new_entry_flag = 1;
      }
      else
      {
        // Position "it" on the entry to move.
        it = it + (1 - new_entry_flag);
      }
      break;
    }
    
    if (it == begin())
    {
      // Can we get here?????  At this point, leftSize == 0
      // and rightSize = originalSize + additional;
      // In any case, we can't leave an empty left page as a result of 
      // a split, so increment.
      it += 1;
      break;
    }
    else
      it -=1;
  }

  // Take the key we are splitting on and the key prior to it and generate
  // the new hi key for the split page.  If the key to insert is the first
  // key on the right page, then we must use it get the correct hi key
  // for the split page.  Similarly if the new last key on the split page is
  // the key to insert then we use it.
  memcpy(newHiKey, mData, mPrefixLength);
  const boost::uint8_t * newLastKeyLeft=NULL;
  boost::uint16_t newLastKeyLeftSize=0;
  const boost::uint8_t * newFirstKeyRight=NULL;
  boost::uint16_t newFirstKeyRightSize=0;
  if (it == insertPosition && 0 == new_entry_flag)
  {
    newFirstKeyRight = keyToInsert + mPrefixLength;
    newFirstKeyRightSize = keySize - mPrefixLength;
  }
  else
  {
    newFirstKeyRight = GetData(it);
    newFirstKeyRightSize = recordPolicy.GetCompressedKeySize(newFirstKeyRight, *this);
  }
  if (it == insertPosition && 1 == new_entry_flag)
  {
    newLastKeyLeft = keyToInsert + mPrefixLength;
    newLastKeyLeftSize = keySize - mPrefixLength;
  }
  else
  {
    newLastKeyLeft = GetData(it-1);
    newLastKeyLeftSize = recordPolicy.GetCompressedKeySize(newLastKeyLeft, *this);
  }

  // Find the common prefix of the last key on the left page
  // and the first key on the right page.  Add 1 and extract
  // from the first key on the right page to get the new hi key for
  // the split page.
//   boost::uint32_t newHiKeyPrefix = GetPrefixSize(newLastKeyLeft, newLastKeyLeftSize, newFirstKeyRight, newFirstKeyRightSize);
  // DANGER.  Not prepared to handle variable length keys yet!!!!!!!!!  So take
  // the full newFirstKeyRight as the new high key for the split page.
  boost::uint32_t newHiKeyPrefix = newFirstKeyRightSize - 1; 
  memcpy(newHiKey+mPrefixLength, newFirstKeyRight, newHiKeyPrefix + 1);

  // Create the new page using the calculated keys as prefixes.
  rightPage.Init(newHiKey, oldHiKey, keySize);
  rightPage.mNumRecords = end() - it;
  rightPage.ClearEmpty();

  // Insert into doubly linked list
  rightPage.mNext = mNext;
  rightPage.mPrevious = this;
  if (mNext != NULL)
    reinterpret_cast<BPlusTreePage *>(mNext)->mPrevious = &rightPage;
  mNext = &rightPage;

  // Here, "it" is positioned on the first entry to move (if any).
  if (it != end())
  {
    // Split the current entries

    iterator target_it = rightPage.begin();
    iterator copy_it = it;
    boost::uint16_t offset = rightPage.GetPrefixLength() - mPrefixLength;
    while(copy_it != end())
    {
      boost::uint16_t to_copy = recordPolicy.GetCompressedRecordSize(GetData(copy_it), *this) - offset;
      *target_it = rightPage.mFreeStart;
      memcpy(rightPage.GetData(target_it), 
             GetData(copy_it) + offset, 
             to_copy);
      rightPage.mFreeStart += to_copy;
      rightPage.mFreeBytes -= (to_copy + sizeof(mSlot));
      mFreeBytes += to_copy + sizeof(mSlot);
      target_it += 1; 
      copy_it += 1;
    }    
    // TODO: Recalculate the prefix for existing page, splitting a page can result in 
    // an increase in the length of the prefix of the existing page too.
    mNumRecords -= end() - it;

    // Compress the current page.
    Compress(keySize, valueSize);
  }

  // Now we have to communicate whether the additional
  // record should go in the right or left page.
  // N.B. end() of the current page has changed as a result 
  // of having been split!
  if (end() == insertPosition)
  {
    insertOnRight = new_entry_flag == 0;
  }
  else
  {
    insertOnRight = insertPosition >= end();
  }

  if (insertOnRight)
  {
    insertPosition = rightPage.begin() + (insertPosition - end());
  }
}

// void BPlusTreePage::Init(const boost::uint8_t * lo, boost::uint16_t loKeyLength, const boost::uint8_t * hi, boost::uint16_t hiKeyLength)
// {
//   mFreeBytes = PAGE_SIZE - 
//     sizeof(mFreeBytes) - 
//     sizeof(mFreeStart) - 
//     sizeof(mNumRecords) - 
//     sizeof(mPageFlags) - 
//     sizeof(mPrefixLength);

//   mFreeStart = sizeof(mFreeBytes) + 
//     sizeof(mFreeStart) + 
//     sizeof(mNumRecords) + 
//     sizeof(mPageFlags) +
//     sizeof(mPrefixLength);

//   mPageFlags = 1;
//   mPrefixLength = GetPrefixSize(lo, loKeyLength, hi, hiKeyLength);
//   mFreeBytes -= mPrefixLength;
//   memcpy(mFreeStart, lo, mPrefixLength);
//   mFreeStart += mPrefixLength;
// }

// class BPlusTree
// {
// public:
//   class BPlusInsertIterator
//   {
//   private:
//     BPlusTreePage * mNode;
//     _K * mSeparator;
//   public:
//     BPlusInsertIterator()
//       :
//       mNode(NULL),
//       mSeparator(NULL)
//     {
//     }
//     bool empty() const
//     {
//       return mNode == NULL;
//     }
//     void init(BPlusTreePage * node, _K * separator)
//     {
//       mNode = node;
//       mSeparator = separator;
//     }
//     BPlusTreePage * node() const
//     {
//       return mNode;
//     }
//     const _K & separator() const
//     {
//       return *mSeparator;
//     }
//   };

// private:
//   boost::int64_t mTreeSize;
//   BPlusTreePage * mRoot;

//   void insert(BPlusTreePage& node, const _K & key, const _T & entry, BPlusInsert& insertIterator);

// public:

//   BPlusTree();

//   void insert(const _K & key, const _T & entry);

//   boost::int32_t max_entries() const
//   {
//     return _MaxSize;
//   }

//   boost::int64_t size() const
//   {
//     return mTreeSize;
//   }

//   bool empty() const
//   {
//     return mTreeSize == 0LL;
//   }
// };

// BPlusTree::BPlusTree()
//   :
//   mTreeSize(0LL)
// {
//   mRoot = new BPlusTreePage(NULL, true);
// }

// void BPlusTree::insert(const _K & key, const _T & entry)
// {
//   BPlusInsertIterator it;
//   insert(*mRoot, entry, it);
//   if (!it.empty())
//   {
//     // Handle a splitting of the root node.
//     BPlusNode * new_root = new BPlusNode(NULL, false);
//     new_root.children().push_back(mRoot);
//     new_root.children().back().set_parent(new_root);
//     new_root.children().push_back(it.node());
//     new_root.children().back().set_parent(new_root);
//     new_root.separators().push_back(it.separator());
//     new_root.set_size(1);
//     mRoot = new_root;
//   }
// }

// void BPlusTree::insert(BPlusTreePage& node, const _K & key, const _T & entry, BPlusInsert& insertIterator)
// {
//   if (node.leaf())
//   {
//     // Find where to insert
//     BPlusLeafNodeInsertIterator it;
//     find(node, entry, it);
//     // The equals test memoizes the result of 
//     // comparing the key with the separator we are positioned at.
//     // For the moment, we are only considering unique indexes.
//     if (it != node.end() && it.equals())
//       return;

//     // Now figure out whether we need to split.
//     if (!it.must_split())
//     {
//     }
//     else
//     {
//       // Create a new leaf and distribute key value pairs
//     }
//   }
//   else
//   {
//     // Search to find child and recurse.  
//     BPlusInternalNodeInsertIterator nodeIt;
//     find(node, key, nodeIt);
    
//     insert(*it.node(), key, entry, insertIterator);
//     if (insertIterator.empty())
//       return;

//     // There was a split beneath us.
//     it.clear();
//     find.(node, it.separator(), nodeIt);
    
//     if (!it.must_split())
//     {
//       insertIterator.clear();
//     }
//     else
//     {
//       // Create a new leaf and distribute key pointer pairs
//       insertIterator.init();
//     }
//   }
// }

BPlusTree::BPlusTree(boost::uint16_t keySize)
  :
  mRoot(NULL),
  mMinKey(keySize, std::numeric_limits<boost::uint8_t>::min()),
  mMaxKey(keySize, std::numeric_limits<boost::uint8_t>::max()),
  mLevels(1)
{
  BPlusTreePage * tmp = reinterpret_cast<BPlusTreePage *>(mMalloc.malloc(sizeof(BPlusTreePage)));
  tmp->Init();
  mRoot = reinterpret_cast<BPlusTreeNonLeafPage *>(tmp);
}

BPlusTree::~BPlusTree()
{
}

void BPlusTree::GetBoundingKeys(
  std::vector<std::pair<BPlusTreeNonLeafPage*,BPlusTreeNonLeafPage::SearchState> >::reverse_iterator begin,
  std::vector<std::pair<BPlusTreeNonLeafPage*,BPlusTreeNonLeafPage::SearchState> >::reverse_iterator end,
  const boost::uint8_t *& oldLoKey, const boost::uint8_t *& oldHiKey)
{
  // Initialize
  oldLoKey = NULL;
  oldHiKey = NULL;

  // Walk back up the tree to find bounding keys.  If we descended through the last page of
  // a non-leaf then we need to appeal to the parent of that page to find a high key. Similarly,
  // if we descended through a first page of non-leaf we need to appeal to a parent to find a 
  // lo key.
  for(std::vector<std::pair<BPlusTreeNonLeafPage*,BPlusTreeNonLeafPage::SearchState> >::reverse_iterator it = begin;
      it != end;
      it++)
  {
    if (oldHiKey == NULL && it->first->end() != it->second.Iterator)
    {
      oldHiKey = it->first->GetKey(it->second.Iterator);
    }
    if (oldLoKey == NULL && it->first->begin() != it->second.Iterator)
    {
      oldLoKey = it->first->GetKey(it->second.Iterator - 1);
    }

    if (NULL != oldLoKey && NULL != oldHiKey)
    {
      break;
    }
  }

  if (oldLoKey == NULL)
    oldLoKey = &mMinKey[0];
  if (oldHiKey == NULL)
    oldHiKey = &mMaxKey[0];
}


void BPlusTree::Insert(const boost::uint8_t * key, boost::uint16_t keyLength, const boost::uint8_t * value, boost::uint16_t valueLength)
{
  std::vector<std::pair<BPlusTreeNonLeafPage*,BPlusTreeNonLeafPage::SearchState> > traversal;
  BPlusTreeNonLeafPage * node = mRoot;
  // Walk down the tree
  while(!node->IsLeaf())
  {
    traversal.push_back(std::pair<BPlusTreeNonLeafPage*,BPlusTreeNonLeafPage::SearchState> (node, BPlusTreeNonLeafPage::SearchState()));
    traversal.back().first->Search(key, keyLength, traversal.back().second);
    node = reinterpret_cast<BPlusTreeNonLeafPage*>(traversal.back().first->GetPage(keyLength, traversal.back().second.Iterator));
  }
  
  BPlusTreePage * leaf(reinterpret_cast<BPlusTreePage*>(node));
  bool result = leaf->Insert(key, keyLength, value, valueLength);
  if (result) return;

  std::vector<boost::uint8_t> newHiKey(keyLength);
  BPlusTreePage * rightLeaf= reinterpret_cast<BPlusTreePage *>(mMalloc.malloc(sizeof(BPlusTreePage)));
  bool insertOnRight;

  // Get the old lo and hi key from the parent in the traversal
  // or ancestors if necessary.
  const boost::uint8_t * oldLoKey = NULL;
  const boost::uint8_t * oldHiKey = NULL;
  GetBoundingKeys(traversal.rbegin(), traversal.rend(), oldLoKey, oldHiKey);
//   for(std::vector<std::pair<BPlusTreeNonLeafPage*,BPlusTreeNonLeafPage::SearchState> >::reverse_iterator it = traversal.rbegin();
//       it != traversal.rend();
//       it++)
//   {
//     if (oldHiKey == NULL && it->first->end() != it->second.Iterator)
//     {
//       oldHiKey = it->first->GetKey(it->second.Iterator);
//     }
//     if (oldLoKey == NULL && it->first->begin() != it->second.Iterator)
//     {
//       oldHiKey = it->first->GetKey(it->second.Iterator - 1);
//     }

//     if (NULL != oldLoKey && NULL != oldHiKey)
//     {
//       break;
//     }
//   }

//   if (oldLoKey == NULL)
//     oldLoKey = &mMinKey[0];
//   if (oldHiKey == NULL)
//     oldHiKey = &mMaxKey[0];
    
  BPlusTreePage::SearchState leafSearchState;
  leaf->Search(key, keyLength, leafSearchState);
  leaf->SplitLeafRight(*rightLeaf, key, keyLength, valueLength, oldLoKey, oldHiKey,
                       &newHiKey[0], leafSearchState.Iterator, insertOnRight);
  // TODO: Save the cost of another binary search since we already have the 
  // position into which to insert.
  if (insertOnRight)
  {
    rightLeaf->Insert(key, keyLength, value, valueLength);
  }
  else
  {
    leaf->Insert(key, keyLength, value, valueLength);
  }

  BPlusTreeNonLeafPage::pageid_t rightChild(rightLeaf);
  std::vector<boost::uint8_t> newNonLeafHiKey(keyLength);
  
  if (reinterpret_cast<BPlusTreeNonLeafPage*>(leaf) == mRoot)
  {
    // Create a new page with the state of the split root.
    BPlusTreePage * newChildOfRoot = reinterpret_cast<BPlusTreePage *>(mMalloc.malloc(sizeof(BPlusTreePage)));
    *newChildOfRoot = *leaf;
    // Reinitialize the root as a non leaf and pretend that we traversed through it.
    mRoot->Init(&mMinKey[0], &mMaxKey[0], mMinKey.size(), newChildOfRoot);
    BPlusTreeNonLeafPage::SearchState rootSearchState;
    rootSearchState.Iterator = mRoot->end();
    traversal.push_back(std::pair<BPlusTreeNonLeafPage*,BPlusTreeNonLeafPage::SearchState> (node, rootSearchState));

    mLevels += 1;
  }
  
  // Propagate up until no more splits.
  while(traversal.size() > 0)
  {
    result = traversal.back().first->Insert(traversal.back().second.Iterator, &newHiKey[0], keyLength, rightChild);
    if (result) break;
      
    // Find previous bounding keys.
    GetBoundingKeys(traversal.rbegin()+1, traversal.rend(), oldLoKey, oldHiKey);
    // Split the non-leaf page.
    bool insertWithNewKey = false;
    BPlusTreeNonLeafPage * rightNonLeaf = reinterpret_cast<BPlusTreeNonLeafPage*>(mMalloc.malloc(sizeof(BPlusTreeNonLeafPage)));
    BPlusTreeNonLeafPage::SearchState state;
    traversal.back().first->Search(&newHiKey[0], keyLength, state);
    traversal.back().first->SplitRight(*rightNonLeaf, &newHiKey[0], keyLength, sizeof(BPlusTreeNonLeafPage::pageid_t),
                          oldLoKey, oldHiKey, &newNonLeafHiKey[0], state.Iterator, insertOnRight, insertWithNewKey);

    if(insertOnRight)
    {
      if (insertWithNewKey)
      {
        rightNonLeaf->InsertWithNewKey(state.Iterator, &newHiKey[0], keyLength, rightChild);
      }
      else
      {
        rightNonLeaf->Insert(state.Iterator, &newHiKey[0], keyLength, rightChild);
      }
    }
    else
    {
      if (insertWithNewKey)
      {
        traversal.back().first->InsertWithNewKey(state.Iterator, &newHiKey[0], keyLength, rightChild);
      }
      else
      {
        traversal.back().first->Insert(state.Iterator, &newHiKey[0], keyLength, rightChild);
      }
    }
      
    rightChild = rightNonLeaf;
    std::swap(newHiKey, newNonLeafHiKey);

    traversal.pop_back();
    if (traversal.size() == 0)
    {
      // We just split the root.  
      // Create a new page with the state of the split root.
      BPlusTreeNonLeafPage * newChildOfRoot = reinterpret_cast<BPlusTreeNonLeafPage *>(mMalloc.malloc(sizeof(BPlusTreeNonLeafPage)));
      *newChildOfRoot = *mRoot;
      // Reinitialize the root as a non leaf and pretend that we traversed through it.
      mRoot->Init(&mMinKey[0], &mMaxKey[0], mMinKey.size(), newChildOfRoot);
      BPlusTreeNonLeafPage::SearchState rootSearchState;
      rootSearchState.Iterator = mRoot->end();
      // Put this back into the work list so we complete the propagation of the root split.
      traversal.push_back(std::pair<BPlusTreeNonLeafPage*,BPlusTreeNonLeafPage::SearchState> (mRoot, rootSearchState));
      
      mLevels += 1;
    }
  }
}

void BPlusTree::Search(const boost::uint8_t * key, boost::uint16_t keyLength, BPlusTree::SearchState& search)
{
  BPlusTreeNonLeafPage::SearchState nonLeafSearch;
  BPlusTreeNonLeafPage * node = mRoot;
  // Walk down the tree
  while(!node->IsLeaf())
  {
    node->Search(key, keyLength, nonLeafSearch);
    node = reinterpret_cast<BPlusTreeNonLeafPage*>(node->GetPage(keyLength, nonLeafSearch.Iterator));
  }
  
  BPlusTreePage * leaf(reinterpret_cast<BPlusTreePage*>(node));
  leaf->Search(key, keyLength, search.GetState());
  search.SetPage(leaf);
}

void BPlusTree::SearchNext(const boost::uint8_t * key, boost::uint16_t keyLength, BPlusTree::SearchState& search)
{
  BPlusTreeNonLeafPage::SearchState nonLeafSearch;
  BPlusTreeNonLeafPage * node = mRoot;
  // Walk down the tree
  while(!node->IsLeaf())
  {
    node->Search(key, keyLength, nonLeafSearch);
    node = reinterpret_cast<BPlusTreeNonLeafPage*>(node->GetPage(keyLength, nonLeafSearch.Iterator));
  }
  
  BPlusTreePage * leaf(reinterpret_cast<BPlusTreePage*>(node));
  while(true)
  {
    leaf->Search(key, keyLength, search.GetState());
    if (search.GetComparison() != -1 || leaf->GetNext() == NULL)
      break;
    leaf = reinterpret_cast<BPlusTreePage *>(leaf->GetNext());
  }
  search.SetPage(leaf);
}

const boost::uint8_t * BPlusTree::GetKey(const BPlusTree::SearchState& search)
{
  return search.GetPage()->GetKey(search.GetIterator());
}

const boost::uint8_t * BPlusTree::GetValue(const BPlusTree::SearchState& search)
{
  return search.GetPage()->GetValue(mMaxKey.size(), search.GetIterator());
}

boost::int32_t BPlusTree::GetLevels()
{
  return mLevels;
}

void BPlusTree::Dump(std::ostream& ostr, std::size_t truncateKey)
{
  if (mRoot->IsLeaf())
  {
    Dump(ostr, *reinterpret_cast<BPlusTreePage*>(mRoot), 0, truncateKey);
  }
  else
  {
    Dump(ostr, *mRoot, 0, truncateKey);
  }
}

void BPlusTree::Dump(std::ostream& ostr, BPlusTreePage& leafPage, int level, std::size_t truncateKey)
{
  // Walk the keys/values and print the corresponding child pages.
  for(BPlusTreePage::iterator it = leafPage.begin(); 
      it != leafPage.end();
      it++)
  {
    boost::io::ios_flags_saver  ifs( ostr );
    for (int i=0; i<level; i++) ostr << "\t";
    const boost::uint8_t * key = leafPage.GetKey(it);
    std::size_t toPrint (std::min(truncateKey, mMaxKey.size()-leafPage.GetPrefixLength()));

    ostr << std::hex;
    for (std::size_t i=0; i<toPrint; i++)
      ostr << (unsigned) key[i];
    ostr << std::endl;
  }
}

void BPlusTree::Dump(std::ostream& ostr, BPlusTreeNonLeafPage& nonLeafPage, int level, std::size_t truncateKey)
{
  // Walk the high keys and print the corresponding child pages.
  for(BPlusTreeNonLeafPage::iterator it = nonLeafPage.begin(); 
      it != nonLeafPage.end();
      it++)
  {
    BPlusTreeNonLeafPage * child = reinterpret_cast<BPlusTreeNonLeafPage *>(nonLeafPage.GetPage(mMaxKey.size(), it));
    if (child->IsLeaf())
    {
      Dump(ostr, *reinterpret_cast<BPlusTreePage*>(child), level+1, truncateKey);
    }
    else
    {
      Dump(ostr, *child, level+1, truncateKey);
    }
    {
      boost::io::ios_flags_saver  ifs( ostr );
      
      for (int i=0; i<level; i++) ostr << "\t";
      const boost::uint8_t * key = nonLeafPage.GetKey(it);
      std::size_t toPrint (std::min(truncateKey, mMaxKey.size()-nonLeafPage.GetPrefixLength()));

      ostr << std::hex;
      for (std::size_t i=0; i<toPrint; i++)
        ostr << (unsigned) key[i];
      ostr << std::endl;
    }
  }

  // Dump last page
  {
    BPlusTreeNonLeafPage * child = reinterpret_cast<BPlusTreeNonLeafPage *>(nonLeafPage.GetLastPage());
    if (child->IsLeaf())
    {
      Dump(ostr, *reinterpret_cast<BPlusTreePage*>(child), level+1, truncateKey);
    }
    else
    {
      Dump(ostr, *child, level+1, truncateKey);
    }
  }
}

// explicit instantiation - so all the impl doesn't have to be in the header
template class RunTimeRecordImporter<PagedParseBuffer<mapped_file> >;
template class RunTimeRecordImporter<StdioReadBuffer<StdioFile> >;
template class RunTimeRecordImporter<StdioReadBuffer<ZLIBFile> >;
template class RunTimeRecordExporter<StdioWriteBuffer<ZLIBFile> >;
template class RunTimeRecordExporter<StdioWriteBuffer<StdioFile> >;
template class RunTimeRecordImporterActivation<PagedParseBuffer<mapped_file> >;
template class RunTimeRecordImporterActivation<StdioReadBuffer<StdioFile> >;
template class RunTimeRecordImporterActivation<StdioReadBuffer<ZLIBFile> >;
template class RunTimeRecordExporterActivation<StdioWriteBuffer<ZLIBFile> >;
template class RunTimeRecordExporterActivation<StdioWriteBuffer<StdioFile> >;
