#ifndef __IMPORTFUNCTION_H__
#define __IMPORTFUNCTION_H__

#include <string>
#include <stdexcept>
#include "MetraFlowConfig.h"
#include "mtprogids.h"
#include "MTUtil.h"
#include "RecordModel.h"

#include <stack>
#include <boost/format.hpp>
#include <boost/cstdint.hpp>

#include "FastDelegate.h"

class PerfectEnumeratorHash
{
private:
  int * mEnumerators;
  int mLength;
protected:
  void Init(int length);
public:
  METRAFLOW_DECL PerfectEnumeratorHash(int length=0);
  METRAFLOW_DECL PerfectEnumeratorHash(const wchar_t * enumNamespace, const wchar_t * enumEnumerator);
  METRAFLOW_DECL PerfectEnumeratorHash(const PerfectEnumeratorHash& rhs);
  METRAFLOW_DECL ~PerfectEnumeratorHash();
  METRAFLOW_DECL PerfectEnumeratorHash& operator=(const PerfectEnumeratorHash& rhs);
  METRAFLOW_DECL void destroy();
  METRAFLOW_DECL int Lookup(const boost::uint8_t * str, int len);
  METRAFLOW_DECL bool Insert(const boost::uint8_t * str, int len, int value);
};


class ImportFunction
{
public:
  virtual ~ImportFunction() {}
  virtual bool Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed,
                      unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)=0;
};

class ExportFunction
{
public:
  virtual ~ExportFunction() {}
  virtual bool Export(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed,
                      unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)=0;
};

class ParseZeroTerminatedUCS2String : public ImportFunction
{
public:
  bool Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed,
              unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    const unsigned char * input = inputBuffer;
    unsigned char * output = outputBuffer;
    const unsigned char * inputEnd = inputBuffer + inputAvailable;
    unsigned char * outputEnd = outputBuffer + outputAvailable;
    while(true)
    {
      if (input+1 >= inputEnd || output+1 >= outputEnd) 
      {
        inputConsumed = input - inputBuffer + 1;
        outputConsumed = output - outputBuffer + 1;
        return false;
      }
      // This may be non-aligned.  Performance penalty on x86; segfault on Sparc.
      *((wchar_t *)output) = *((const wchar_t *)input);
      input += sizeof(wchar_t);
      output += sizeof(wchar_t);
      if (*((const wchar_t *)input) == 0) 
      {
        inputConsumed = input - inputBuffer;
        outputConsumed = output - outputBuffer;
        return true;
      }
    }
  }
};
class ParseBinaryInt32 : public ImportFunction
{
public:
  static bool StaticImport(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed, 
                           unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    // Native format; no endianness conversions.
    inputConsumed = sizeof(int);
    outputConsumed = sizeof(int);
    if (inputAvailable < sizeof(int) || outputAvailable < sizeof(int))
    {
      return false;
    }
    // This may be non-aligned.  Performance penalty on x86; segfault on Sparc.
    *((int *)outputBuffer) = *((const int *)inputBuffer);
    return true;
  }

  bool Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed, 
              unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    return StaticImport(inputBuffer, inputAvailable, inputConsumed, 
                        outputBuffer, outputAvailable, outputConsumed);
  }

};

class ParseBinaryInt16 : public ImportFunction
{
public:
  static bool StaticImport(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed, 
                           unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    // Native format; no endianness conversions.
    inputConsumed = sizeof(short);
    outputConsumed = sizeof(short);
    if (inputAvailable < sizeof(short) || outputAvailable < sizeof(short))
    {
      return false;
    }
    // This may be non-aligned.  Performance penalty on x86; segfault on Sparc.
    *((short *)outputBuffer) = *((const short *)inputBuffer);
    return true;
  }
  bool Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed, 
              unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    return StaticImport(inputBuffer, inputAvailable, inputConsumed, 
                        outputBuffer, outputAvailable, outputConsumed);
  }
};
class ParseBinaryInt8 : public ImportFunction
{
public:
  static bool StaticImport(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed, 
                           unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    inputConsumed = sizeof(char);
    outputConsumed = sizeof(char);
    if (inputAvailable < sizeof(char) || outputAvailable < sizeof(char))
    {
      return false;
    }
    *((char *)outputBuffer) = *((const char *)inputBuffer);
    return true;
  }
  bool Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed, 
              unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    return StaticImport(inputBuffer, inputAvailable, inputConsumed, 
                        outputBuffer, outputAvailable, outputConsumed);
  }
};
class ParseZeroTerminatedUCS2StringEnumeratedValue : public ImportFunction
{
private:
  ParseZeroTerminatedUCS2String * mStringImporter;
public:
  ParseZeroTerminatedUCS2StringEnumeratedValue()
  {
    mStringImporter = new ParseZeroTerminatedUCS2String;
  }
  ~ParseZeroTerminatedUCS2StringEnumeratedValue()
  {
    delete mStringImporter;
  }
  bool Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed, 
              unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    return mStringImporter->Import(inputBuffer, inputAvailable, inputConsumed, outputBuffer, outputAvailable, outputConsumed);
  }
};
class ParsePrefixedUCS2String : public ImportFunction
{
public:
  ParsePrefixedUCS2String()
  {
  }
  ~ParsePrefixedUCS2String()
  {
  }
  bool Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed,
              unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    // First read a 2 byte integer containing the length
    // Do this into a local instead of the output buffer.
    short sz;
    int consumed;
    if (false==ParseBinaryInt16::StaticImport(inputBuffer, inputAvailable, inputConsumed,
                                              (unsigned char *)&sz, 2, consumed)) 
    {
      outputConsumed = 0;
      return false;
    }
    if(-1 == sz)
    {
      outputConsumed = 0;
      return true;
    }
    inputConsumed = sz+2;
    outputConsumed = sz+2;
    if (inputAvailable < sz + 2 || outputAvailable < sz + 2)
    {
      return false;
    }
    // Copy and 0 terminate
    memcpy(outputBuffer, inputBuffer + 2, sz);
    *((short *)(outputBuffer+sz)) = 0;
    return true;
  }
};
class ParsePrefixedUCS2StringEnumeration : public ImportFunction
{
private:
  std::wstring mNamespace;
  std::wstring mEnumeration;
  unsigned char * mBuffer;
  int mBufferLength;
  PerfectEnumeratorHash * mHashTable;
  ParsePrefixedUCS2String * mString;
public:
  METRAFLOW_DECL ParsePrefixedUCS2StringEnumeration(const std::wstring& space, const std::wstring& enumeration);
  METRAFLOW_DECL ~ParsePrefixedUCS2StringEnumeration();
  METRAFLOW_DECL bool Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed,
                        unsigned char * outputBuffer, int outputAvailable, int & outputConsumed);
};
class ParsePrefixedVarbinary : public ImportFunction
{
public:
  ParsePrefixedVarbinary()
  {
  }
  ~ParsePrefixedVarbinary()
  {
  }
  bool Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed,
              unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    // First read a 1 byte integer containing the length
    // Do this into a local instead of the output buffer.
    unsigned char sz;
    int consumed;
    if (false==ParseBinaryInt8::StaticImport(inputBuffer, inputAvailable, inputConsumed,
                               &sz, 1, consumed)) 
    {
      outputConsumed = 0;
      return false;
    }

    
    // Handled SQL Server BCP null indicator
    if (sz==0xff) 
    {
      outputConsumed = 0;
      return true;
    }
    inputConsumed = sz+1;
    outputConsumed = sz;
    if (inputAvailable < inputConsumed || outputAvailable < outputConsumed)
    {
      return false;
    }

    // Copy
    memcpy(outputBuffer, inputBuffer + 1, outputConsumed);
    return true;    
  }
};
class ParseSQLServerDecimal : public ImportFunction
{
public:
  ParseSQLServerDecimal()
  {
  }
  ~ParseSQLServerDecimal()
  {
  }
  bool Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed,
              unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    // First read a 1 byte integer containing the length
    // Do this into a local instead of the output buffer.
    unsigned char sz;
    int consumed;
    if (false==ParseBinaryInt8::StaticImport(inputBuffer, inputAvailable, inputConsumed,
                                             &sz, 1, consumed)) 
    {
      outputConsumed = 0;
      return false;
    }

    
    // Handled SQL Server BCP null indicator
    if (sz==0xff) 
    {
      outputConsumed = 0;
      return true;
    }
    inputConsumed = sz+1;
    outputConsumed = sz;
    if (inputAvailable < inputConsumed || outputAvailable < outputConsumed)
    {
      return false;
    }

    // Our internal representation is an Automation DECIMAL
    DECIMAL * dec = (DECIMAL *)outputBuffer;
    dec->scale = inputBuffer[2];
    dec->sign = inputBuffer[3] != 0 ? 0 : DECIMAL_NEG;
    memcpy(&dec->Lo64, &inputBuffer[4], 8);
    memcpy(&dec->Hi32, &inputBuffer[12], 4);
    return true;    
  }  
};
class ParsePrefixedTimetDatetime : public ImportFunction
{
public:
  ParsePrefixedTimetDatetime()
  {
  }
  ~ParsePrefixedTimetDatetime()
  {
  }
  bool Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed,
              unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
  {
    // First read a 1 byte integer containing the length
    // Do this into a local instead of the output buffer.
    unsigned char sz;
    int consumed;
    if (false==ParseBinaryInt8::StaticImport(inputBuffer, inputAvailable, inputConsumed,
                               &sz, 1, consumed)) 
    {
      outputConsumed = 0;
      return false;
    }

    
    // Handled SQL Server BCP null indicator
    if (sz==0xff) 
    {
      outputConsumed = 0;
      return true;
    }

    if (sz != sizeof(time_t)) 
    {
      throw std::runtime_error((boost::format("Invalid time_t size: %1%") % (int)sz).str());
    }

    inputConsumed = sz+sizeof(unsigned char);
    outputConsumed = sizeof(DATE);
    if (inputAvailable < inputConsumed || outputAvailable < outputConsumed)
    {
      return false;
    }

    time_t buffer;

    memcpy(&buffer, inputBuffer + sizeof(unsigned char), sizeof(time_t));
    ::OleDateFromTimet((DATE *) outputBuffer, buffer);

    return true;    
  }
};

// class PrintFixedWidthInt32 : public ExportFunction
// {
// private:
  
// public:
//   PrintFixedWidthInt32(
//   bool Export(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed,
//               unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
//   {
//     sprintf(outputBuffer, mFormat, inputBuffer);
//   }  
// };

/**
 * A parsing module that is inspired by the PADS project (http://www.padsproj.org) and Mandelbaum's
 * Princeton thesis "The Theory and Practice of Data Description".
 */

class ParseDescriptor 
{
public:
  enum Result { PARSE_OK=0, PARSE_SOURCE_EXHAUSTED, PARSE_TARGET_EXHAUSTED, PARSE_BUFFER_OPEN, PARSE_ERROR };
//   enum Error { SUCCESS, ERROR, FAILURE };
//   boost::int32_t mNumErrors;
//   Error mError;
  //Span mSpan;
};

/**
 * This class implements the output buffer discipline on top of an array of bytes.
 * Requests to open are always granted by doubling the size of the underlying buffer
 * and copying contents.  
 */
class DynamicArrayParseBuffer
{
public:
  typedef std::size_t size_type;
private:
  boost::uint8_t * mBuffer;
  boost::uint8_t * mBufferIt;
  boost::uint8_t * mBufferEnd;

  std::stack<boost::uint8_t *> mMarks;

  void double_buffer(size_type sz)
  {
    // Grow buffer to ensure sz bytes are available and that it has
    // been doubled in size.
    size_type new_sz = (std::max)(sz - size_type(mBufferEnd - mBufferIt), size_type(mBufferEnd-mBuffer));
    new_sz += size_type(mBufferEnd-mBuffer);
    boost::uint8_t * tmp = new boost::uint8_t [new_sz];
    memcpy(tmp, mBuffer, mBufferIt-mBuffer);
    mBufferIt = tmp + (mBufferIt-mBuffer);
    mBufferEnd = tmp + new_sz;
    if (mMarks.size())
    {
      std::stack<boost::uint8_t *> tmpstk;
      while(mMarks.size())
      {
        tmpstk.push(tmp + (mMarks.top()-mBuffer));
        mMarks.pop();
      }
      while(tmpstk.size())
      {
        mMarks.push(tmpstk.top());
        tmpstk.pop();
      }
    }
    delete [] mBuffer;
    mBuffer = tmp;
  }

public:
  DynamicArrayParseBuffer(size_type sz)
    :
    mBuffer(NULL),
    mBufferIt(NULL),
    mBufferEnd(NULL)
  {
    mBuffer = new boost::uint8_t [sz];
    mBufferIt = mBuffer;
    mBufferEnd = mBuffer + sz;
  }

  DynamicArrayParseBuffer(const DynamicArrayParseBuffer& rhs)
    :
    mBuffer(NULL),
    mBufferIt(NULL),
    mBufferEnd(NULL)
  {
    *this = rhs;
  }

  ~DynamicArrayParseBuffer()
  {
    destroy();
  }

  DynamicArrayParseBuffer& operator=(const DynamicArrayParseBuffer& rhs)
  {
    destroy();
    mBuffer = new boost::uint8_t [rhs.mBufferEnd-rhs.mBuffer];
    mBufferIt = mBuffer + (rhs.mBufferIt-rhs.mBuffer);
    mBufferEnd = mBuffer + (rhs.mBufferEnd-rhs.mBuffer);
    return *this;
  };

  void destroy()
  {
    delete [] mBuffer;
    mBuffer = NULL;
  }
  /**
   * Get a value and advance position.
   */
  bool get(boost::uint8_t& value)
  {
    if (mBufferIt == mBufferEnd)
      return false;
    else
    {
      value = *mBufferIt++;
      return true;
    }
  }

  /**
   * Put a value and advance position.
   */
  void put(boost::uint8_t val)
  {
    if (mBufferIt >= mBufferEnd)
    {
      double_buffer(1);
    }
    *mBufferIt++ = val;
  }

  /**
   * Get a pointer to numBytes contiguous bytes.  Do not change the position.
   * If numBytes contiguous bytes could not be obtained, set truncated to true.
   */
  bool open(size_type sz, boost::uint8_t *& buf)
  {
    if (mBufferIt + sz > mBufferEnd)
    {
      double_buffer(sz);
    }
    buf = mBufferIt;
    return true;
  }

  /**
   * Advancing position by the sz bytes.
   */
  void consume(size_type sz)
  {
    mBufferIt += sz;
  }

  /**
   * Place a mark in the buffer.  The mark is released by either calling
   * commit() or rewind().  Note that marks are maintained in a stack, allowing
   * multiple marks to be made.  This allows a client of a buffer to have its
   * commit overruled by another.
   */
  void mark()
  {
    mMarks.push(mBufferIt);
  }

  /**
   * Reset the position of the buffer the last mark.  Release that mark.
   */
  void rewind()
  {
    mBufferIt = mMarks.top();
    mMarks.pop();
  }

  /**
   * Release the previous mark marking all bytes between that mark and position as consumed.
   */
  void commit()
  {
    mMarks.pop();
  } 

  /**
   * Reset position to beginning.
   */
  void clear()
  {
    mBufferIt = mBuffer;
  }

  /**
   * For debugging and not part of the official interface.
   */
  const boost::uint8_t * buffer() const
  {
    return mBuffer;
  }
  size_type size() const
  {
    return size_type(mBufferIt - mBuffer);
  }
  size_type capacity() const
  {
    return size_type(mBufferEnd - mBuffer);
  }
};

/**
 * This class implements the buffer discipline on top of an array of bytes.
 * Requests to open are always granted until the buffer is exhausted.
 */
class FixedArrayParseBuffer
{
public:
  typedef std::size_t size_type;
private:
  boost::uint8_t * mBuffer;
  boost::uint8_t * mBufferIt;
  boost::uint8_t * mBufferEnd;

  std::stack<boost::uint8_t *> mMarks;

public:
  FixedArrayParseBuffer(const std::string& str)
    :
    mBuffer(NULL),
    mBufferIt(NULL),
    mBufferEnd(NULL)
  {
    mBuffer = (boost::uint8_t *) &str[0];
    mBufferIt = mBuffer;
    mBufferEnd = mBuffer + (str.size()+1);
  }
  FixedArrayParseBuffer(const std::wstring& str)
    :
    mBuffer(NULL),
    mBufferIt(NULL),
    mBufferEnd(NULL)
  {
    mBuffer = (boost::uint8_t *) &str[0];
    mBufferIt = mBuffer;
    mBufferEnd = mBuffer + (str.size()+1)*sizeof(wchar_t);
  }
  FixedArrayParseBuffer(boost::uint8_t * bufferBegin, boost::uint8_t * bufferEnd)
    :
    mBuffer(bufferBegin),
    mBufferIt(bufferBegin),
    mBufferEnd(bufferEnd)
  {
  }
  ~FixedArrayParseBuffer()
  {
  }
  /**
   * Get a value and advance position.
   */
  bool get(boost::uint8_t& value)
  {
    if (mBufferIt == mBufferEnd)
      return false;
    else
    {
      value = *mBufferIt++;
      return true;
    }
  }

  /**
   * Put a value and advance position.
   */
  void put(boost::uint8_t val)
  {
    if (mBufferIt >= mBufferEnd)
    {
      throw std::runtime_error("Output buffer overrun");
    }
    *mBufferIt++ = val;
  }

  /**
   * Get a pointer to numBytes contiguous bytes.  Do not change the position.
   * If numBytes contiguous bytes could not be obtained, set truncated to true.
   */
  bool open(size_type sz, boost::uint8_t *& buf)
  {
    buf = mBufferIt;    
    return (mBufferIt + sz <= mBufferEnd);
  }

  /**
   * Advancing position by the sz bytes.
   */
  void consume(size_type sz)
  {
    mBufferIt += sz;
  }

  /**
   * Place a mark in the buffer.  The mark is released by either calling
   * commit() or rewind().  Note that marks are maintained in a stack, allowing
   * multiple marks to be made.  This allows a client of a buffer to have its
   * commit overruled by another.
   */
  void mark()
  {
    mMarks.push(mBufferIt);
  }

  /**
   * Reset the position of the buffer the last mark.  Release that mark.
   */
  void rewind()
  {
    mBufferIt = mMarks.top();
    mMarks.pop();
  }

  /**
   * Release the previous mark marking all bytes between that mark and position as consumed.
   */
  void commit()
  {
    mMarks.pop();
  } 

  /**
   * Reset position to beginning.
   */
  void clear()
  {
    mBufferIt = mBuffer;
  }

  /**
   * For debugging and not part of the official interface.
   */
  const boost::uint8_t * buffer() const
  {
    return mBuffer;
  }
  size_type size() const
  {
    return size_type(mBufferIt - mBuffer);
  }
  size_type capacity() const
  {
    return size_type(mBufferEnd - mBuffer);
  }
};

/**
 * This is primarily for testing.  It represents a sequence of bytes that enforces
 * allocation on a configured page granularity.  This is intended to mimic the behavior
 * of memory mapped files allocating at a fixed granularity.
 */
class PagedBuffer
{
public:
  typedef boost::uint64_t offset;

private:
  std::string mBuffer;
  std::size_t mAllocationGranularity;

public:
  PagedBuffer(const std::string& buffer, std::size_t allocationGranularity)
    :
    mBuffer(buffer),
    mAllocationGranularity(allocationGranularity)
  {
  }

  ~PagedBuffer()
  {
  }

  /**
   * Grab a view to size contiguous bytes at offset within the buffer.
   * The actual allocated size will be returned.
   */
  void open(boost::uint64_t offset, std::size_t& sz, boost::uint8_t *& view)
  {
    if (offset % mAllocationGranularity)
    {
      throw std::runtime_error("Allocation alignment error");
    }
    if (sz + offset > size()) 
    {
      if (offset > size())
        throw std::runtime_error("Buffer overflow");
      else
        sz = (std::size_t)(size() - offset);
    }
    view = (boost::uint8_t *)(mBuffer.c_str() + offset);
  }
  void release(boost::uint8_t * view)
  {
    // Nop
  }
  boost::uint64_t size() const
  {
    return mBuffer.size();
  }
  std::size_t granularity() const
  {
    return mAllocationGranularity;
  }
};

/**
 * This class implements the buffer discipline on top of a paged buffer.
 * The primary application is sitting on top of a memory mapped file.
 */
template <class _Buffer>
class PagedParseBuffer
{
public:
  typedef std::size_t size_type;
  typedef _Buffer file_type;

private:
  // Our window.
  boost::uint8_t * mBuffer;
  boost::uint8_t * mBufferIt;
  boost::uint8_t * mBufferEnd;
  std::vector<boost::uint8_t *> mMarks;

  _Buffer& mFile;
  typename _Buffer::offset mOffset;
  std::size_t mViewSize;

  void internal_open(std::size_t viewSize)
  {
    // Find out how many "new" bytes must get mapped in (measured in pages).
    std::size_t ag = mFile.granularity();
    // How many new pages are needed based on the current position.
    std::size_t numNewPages = (viewSize - available() + ag - 1)/ag;
    // Find out how many pages in current view haven't been completely read
    // taking both position and marks into consideration.
    boost::uint8_t * low_water = mBufferIt;
    for(std::vector<boost::uint8_t *>::const_iterator it = mMarks.begin();
        it != mMarks.end();
        ++it)
    {
      if (*it < low_water)
        low_water = *it;
    }
    std::size_t numActivePages = ((mBufferEnd - low_water) + ag - 1)/ag;
    // Make sure that view size is at least the minimum
    viewSize = ag * (numNewPages + numActivePages);
    if (viewSize < mViewSize) viewSize = mViewSize;

    // Release old file view.
    mFile.release(mBuffer);
    // Open view size at the beginning of page containing
    // the low water mark.
    std::size_t roundedPosition = ag*((low_water-mBuffer)/ag);
    mOffset += roundedPosition;
    boost::uint8_t * newBuffer;
    std::size_t requestedView = viewSize;
    mFile.open(mOffset, requestedView, newBuffer);

    if (newBuffer)
    {
      // Adjust all buffers and marks to account for the consumed amount
      // and rebasing of view pointers.
      mBufferIt = newBuffer + (mBufferIt - mBuffer - roundedPosition);
      for(std::vector<boost::uint8_t *>::iterator it = mMarks.begin();
          it != mMarks.end();
          ++it)
      {
        *it = newBuffer + (*it - mBuffer - roundedPosition);
      }
      mBufferEnd = newBuffer + requestedView;
      mBuffer = newBuffer;
    }
    else
    {
      // newBuffer == NULL means that we just tried to read past the end of the
      // file or stream.  Note that in the file case, this means that we tried to read
      // bytes with the file pointer at or past the end of file.
      // If true this must mean we have no active pages.
      ASSERT(numActivePages == 0);
      mBufferIt = mBuffer = mBufferEnd = NULL;
    }
  }

public:
  PagedParseBuffer(_Buffer& b, std::size_t viewSize)
    :
    mBuffer(NULL),
    mBufferIt(NULL),
    mBufferEnd(NULL),
    mFile(b),
    mOffset(0),
    mViewSize(b.granularity()*((viewSize + b.granularity() - 1)/b.granularity()))
  {
    // Do the initial open.
    std::size_t requested = mViewSize;
    mFile.open(mOffset, requested, mBuffer);
    mBufferIt = mBuffer;
    mBufferEnd = mBuffer + requested;
  }
  ~PagedParseBuffer()
  {
    destroy();
  }
  void destroy()
  {
    if (mBuffer != NULL)
    {
      mFile.release(mBuffer);
      mBuffer = NULL;
    }
  }
  /**
   * Get a value and advance position.
   */
  bool get(boost::uint8_t& value)
  {
    if (mBufferIt == mBufferEnd)
    {
      internal_open(mViewSize);
      return false;
    }
    else
    {
      value = *mBufferIt++;
      return true;
    }
  }

  /**
   * Put a value and advance position.
   */
  void put(boost::uint8_t val)
  {
    if (mBufferIt >= mBufferEnd)
    {
      internal_open(mViewSize);
    }
    *mBufferIt++ = val;
  }

  /**
   * Get a pointer to numBytes contiguous bytes.  Do not change the position.
   * If numBytes contiguous bytes could not be obtained, set truncated to true.
   */
  bool open(size_type sz, boost::uint8_t *& buf)
  {
    if(mBufferIt + sz > mBufferEnd)
    {
      internal_open(sz);
    }
    buf = mBufferIt;
    return mBufferIt + sz <= mBufferEnd;
  }

  /**
   * Advancing position by the sz bytes.
   */
  void consume(size_type sz)
  {
    if(mBufferIt + sz > mBufferEnd)
    {
      internal_open(sz);
      if (mBufferIt + sz > mBufferEnd)
      {
        throw std::runtime_error("Buffer overrun");
      }
    }
    mBufferIt += sz;
  }

  /**
   * Place a mark in the buffer.  The mark is released by either calling
   * commit() or rewind().  Note that marks are maintained in a stack, allowing
   * multiple marks to be made.  This allows a client of a buffer to have its
   * commit overruled by another.
   */
  void mark()
  {
    mMarks.push_back(mBufferIt);
  }

  /**
   * Reset the position of the buffer the last mark.  Release that mark.
   */
  void rewind()
  {
    mBufferIt = mMarks.back();
    mMarks.pop_back();
  }

  /**
   * Release the previous mark marking all bytes between that mark and position as consumed.
   */
  void commit()
  {
    mMarks.pop_back();
  } 

  /**
   * Reset position to beginning.
   */
  void clear()
  {
    mBufferIt = mBuffer;
  }

  /**
   * Are we finished with the file?
   */
  bool is_eof()
  {
    return mOffset + size() == mFile.size();
  }

  /**
   * For debugging and not part of the official interface.
   */
  const boost::uint8_t * buffer() const
  {
    return mBuffer;
  }
  size_type size() const
  {
    return size_type(mBufferIt - mBuffer);
  }
  size_type capacity() const
  {
    return size_type(mBufferEnd - mBuffer);
  }
  size_type available() const
  {
    return size_type(mBufferEnd - mBufferIt);
  }
};

/**
 * A block stream based on a vector of buffers.  This is for testing.
 */
class StaticArrayBlockStream
{
private:
  std::vector<std::vector<boost::uint8_t> > mBuffers;
  std::vector<std::vector<boost::uint8_t> >::iterator mNextBuffer;
public:
  StaticArrayBlockStream(const std::vector<std::vector<boost::uint8_t> > & buffers, std::size_t blockSize)
    :
    mBuffers(buffers),
    mNextBuffer(mBuffers.begin())
  {
    for(std::size_t i=1; i<mBuffers.size(); i++)
    {
      if (mBuffers[i-1].size() != blockSize)
        throw std::runtime_error("All initial blocks in a StaticArrayBlockStream must be full");
    }
  }

  /**
   * Get the next block of data.
   */
  bool read(boost::uint8_t *& buffer, std::size_t& sz)
  {
    if (mNextBuffer == mBuffers.end()) return false;
    buffer = &(*mNextBuffer)[0];
    sz = mNextBuffer->size();
    mNextBuffer += 1;
    return true;
  }

  /**
   * Release a block (e.g. write it to disk).
   */
  void release (boost::uint8_t * buffer)
  {
  }

  /** 
   * For a read buffer this show the amount unconsumed.
   * For a write buffer this shows the amount written.
   */
  boost::uint64_t size() const
  {
    boost::uint64_t sz = 0;
    for(std::vector<std::vector<boost::uint8_t> >::const_iterator it = mNextBuffer;
        it != mBuffers.end();
        ++it)
    {
      sz += it->size();
    }
    return sz;
  }

  /** 
   * Size of a non-terminal block.
   */
  std::size_t granularity() const
  {
    return mBuffers.begin()->size();
  }  
}; 

/**
 * The following implements an importer that writes directly into a 
 * MetraFlow record field.
 */
template <template <class, class> class _Ty, class _InputBuffer>
class Direct_Field_Importer_2
{
public:
  typedef _Ty<_InputBuffer, FixedArrayParseBuffer> base_importer;
  typedef _InputBuffer input_buffer;
private:
  _Ty<_InputBuffer, FixedArrayParseBuffer> mImporter;
  std::size_t mSize;
protected:
  FieldAddress mAddress;
public:
  Direct_Field_Importer_2(const _Ty<_InputBuffer, FixedArrayParseBuffer> & importer, RunTimeDataAccessor& accessor)
    :
    mImporter(importer),
    mAddress(accessor),
    mSize(accessor.GetPhysicalFieldType()->GetMaxBytes())
  {
    ASSERT(accessor.GetPhysicalFieldType()->IsInline());
  }
  ~Direct_Field_Importer_2()
  {
  }
  void destroy()
  {
    mImporter.destroy();
  }
  ParseDescriptor::Result Import(_InputBuffer& inputBuffer, record_t recordBuffer)
  {
    FixedArrayParseBuffer outputBuffer((boost::uint8_t *) mAddress.GetDirectBuffer(recordBuffer), 
                                       ((boost::uint8_t *) mAddress.GetDirectBuffer(recordBuffer)) + mSize);

    ParseDescriptor::Result r = mImporter.Import(inputBuffer, outputBuffer);
    if (r == ParseDescriptor::PARSE_OK)
      mAddress.ClearNull(recordBuffer);
    return r;
  }
};

/**
 * This guy imports into a temporary buffer and 
 * then invokes an action on the MetraFlow record.
 * Actions may be SetValue or SetNull.
 */
template <template <class, class> class _Ty, class _InputBuffer, class _Action>
class Field_Action_Importer_2
{
public:
  typedef _Ty<_InputBuffer, DynamicArrayParseBuffer> base_importer;
  typedef _InputBuffer input_buffer;
private:
  _Ty<_InputBuffer, DynamicArrayParseBuffer> mImporter;
  _Action mAddress;
  DynamicArrayParseBuffer mInternalBuffer;

public:
  Field_Action_Importer_2(const _Ty<_InputBuffer, DynamicArrayParseBuffer> & importer, const _Action& accessor)
    :
    mImporter(importer),
    mAddress(accessor),
    mInternalBuffer(16)
  {
  }
  ~Field_Action_Importer_2()
  {
    destroy();
  }
  void destroy()
  {
    mImporter.destroy();
    mAddress.destroy();
    mInternalBuffer.destroy();
  }
  ParseDescriptor::Result Import(_InputBuffer& input, record_t recordBuffer)
  {
    mInternalBuffer.clear();
    ParseDescriptor::Result r = mImporter.Import(input, mInternalBuffer);
    if (r != ParseDescriptor::PARSE_OK)
      return r;

    mAddress.Set(recordBuffer, mInternalBuffer.buffer(), mInternalBuffer.size());
    return r;
  }
};

/**
 * The following implements an exporter that reads from an inline 
 * MetraFlow record field.
 */
template <template <class, class> class _Ty, class _OutputBuffer>
class Direct_Field_Exporter_2
{
public:
  typedef _Ty<FixedArrayParseBuffer, _OutputBuffer> base_exporter;
  typedef _OutputBuffer output_buffer;
private:
  _Ty<FixedArrayParseBuffer, _OutputBuffer> mExporter;
  std::size_t mSize;
protected:
  FieldAddress mAddress;
public:
  Direct_Field_Exporter_2(const _Ty<FixedArrayParseBuffer, _OutputBuffer> & exporter, RunTimeDataAccessor& accessor)
    :
    mExporter(exporter),
    mAddress(accessor),
    mSize(accessor.GetPhysicalFieldType()->GetMaxBytes())
  {
    ASSERT(accessor.GetPhysicalFieldType()->IsInline());
  }
  ~Direct_Field_Exporter_2()
  {
  }
  void destroy()
  {
    mExporter.destroy();
  }
  // TODO: Can we make this const correct?
  ParseDescriptor::Result Export(record_t recordBuffer, _OutputBuffer& outputBuffer)
  {
    FixedArrayParseBuffer inputBuffer((boost::uint8_t *) mAddress.GetDirectBuffer(recordBuffer), 
                                      ((boost::uint8_t *) mAddress.GetDirectBuffer(recordBuffer)) + mSize);

    return mExporter.Export(inputBuffer, outputBuffer);
  }
};

/**
 * The following implements an exporter that reads from an indirect
 * MetraFlow record field.
 */
template <template <class, class> class _Ty, class _OutputBuffer>
class Indirect_Field_Exporter_2
{
public:
  typedef _Ty<FixedArrayParseBuffer, _OutputBuffer> base_exporter;
  typedef _OutputBuffer output_buffer;
private:
  _Ty<FixedArrayParseBuffer, _OutputBuffer> mExporter;
protected:
  RunTimeDataAccessor mAddress;
public:
  Indirect_Field_Exporter_2(const _Ty<FixedArrayParseBuffer, _OutputBuffer> & exporter, RunTimeDataAccessor& accessor)
    :
    mExporter(exporter),
    mAddress(accessor)
  {
    ASSERT(!accessor.GetPhysicalFieldType()->IsInline());
  }
  ~Indirect_Field_Exporter_2()
  {
  }
  void destroy()
  {
    mExporter.destroy();
  }
  // TODO: Can we make this const correct?
  ParseDescriptor::Result Export(record_t recordBuffer, _OutputBuffer& outputBuffer)
  {
    FixedArrayParseBuffer inputBuffer((boost::uint8_t *) mAddress.GetIndirectBuffer(recordBuffer), 
                                      ((boost::uint8_t *) mAddress.GetBufferEnd(recordBuffer)));

    return mExporter.Export(inputBuffer, outputBuffer);
  }
};

/**
 * The following implements an exporter that reads from an inline 
 * MetraFlow record field.
 */
template <template <class, class> class _Ty, class _OutputBuffer>
class Literal_Field_Exporter_2
{
public:
  typedef _Ty<FixedArrayParseBuffer, _OutputBuffer> base_exporter;
  typedef _OutputBuffer output_buffer;
private:
  _Ty<FixedArrayParseBuffer, _OutputBuffer> mExporter;

public:
  Literal_Field_Exporter_2(const _Ty<FixedArrayParseBuffer, _OutputBuffer> & exporter)
    :
    mExporter(exporter)
  {
  }
  ~Literal_Field_Exporter_2()
  {
  }
  void destroy()
  {
    mExporter.destroy();
  }
  // TODO: Can we make this const correct?
  ParseDescriptor::Result Export(record_t , _OutputBuffer& outputBuffer)
  {
    FixedArrayParseBuffer inputBuffer(NULL, NULL);
    return mExporter.Export(inputBuffer, outputBuffer);
  }
};

template <class _IntType, class _InputBuffer, class _OutputBuffer>
class UTF8_Base10_Signed_Integer_2
{
public:
  typedef _InputBuffer input_buffer;
  typedef _OutputBuffer output_buffer;

public:
  UTF8_Base10_Signed_Integer_2()
  {
  }

  ~UTF8_Base10_Signed_Integer_2()
  {
  }

  void destroy()
  {
  }

  ParseDescriptor::Result Import(_InputBuffer& input, _OutputBuffer& output)
  {
    boost::uint8_t * outputBuffer;
    boost::uint8_t * inputBuffer;
    if (!output.open(sizeof(_IntType), outputBuffer))
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;

    *((_IntType *)outputBuffer) = 0;

    if(!input.open(1, inputBuffer))
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;

    _IntType sign = 1;
    if (*((const char *)inputBuffer) == '-')
    {
      sign = -1;
      input.consume(1);
      if (!input.open(1, inputBuffer))
        return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
    }
    else if (*((const char *)inputBuffer) == '+')
    {
      input.consume(1);
      if (!input.open(1, inputBuffer))
        return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
    }

    // Must have at least one digit
    if (*((const char *)inputBuffer) < '0' || *((const char *)inputBuffer) > '9')
      return ParseDescriptor::PARSE_ERROR;

    do
    {
        *((_IntType *)outputBuffer) = *((_IntType *)outputBuffer)*10 + (_IntType) (*((const char *)inputBuffer) - '0');
        input.consume(1);
    } while(input.open(1, inputBuffer) && 
            (*((const char *)inputBuffer) >= '0' && *((const char *)inputBuffer) <= '9'));

    // If we've run out of source or hit a non-digit, we're done and OK.
    output.consume(sizeof(_IntType));

    *((_IntType *)outputBuffer) *= sign;

    return ParseDescriptor::PARSE_OK;
  }

  ParseDescriptor::Result Export(_InputBuffer& input, _OutputBuffer& output)
  {
    static char conversion [] = "0123456789";

    boost::uint8_t * inputBuffer;
    if (!input.open(sizeof(_IntType), inputBuffer))
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
    _IntType value = *((_IntType *)inputBuffer);
    input.consume(sizeof(_IntType));

    boost::uint8_t * outputBuffer;
    if (value < 0)
    {
      if(output.open(1, outputBuffer))
      {
        *((char *)outputBuffer) = '-';
        value *= -1;
        output.consume(1);
      }
      else
      {
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      }
    }

    // With our buffer model this is a little tricky.  We need to write
    // into a contiguous buffer in order to reverse.  To guarantee contiguous
    // we set a mark and then open by an increasing amount.  This is definitely
    // not optimal.
    output.mark();
    typename _OutputBuffer::size_type to_open=0;
    do
    {
      if(output.open(1, outputBuffer))
      {
        *((char*)outputBuffer) = conversion[value % 10];
        output.consume(1);
        value /= 10;
        to_open += 1;
      }
      else
      {
        output.rewind();
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      }
    } while(value != 0);

    // Reverse the digits.
    std::reverse(outputBuffer-to_open+1, outputBuffer+1);
    
    // Commit the mark.
    output.commit();

    // Don't null terminate!  Terminator will be
    // handled elsewhere in the export spec.  In general
    // this won't be null terminated on output.
    return ParseDescriptor::PARSE_OK;
  }
};

template <class _InputBuffer, class _OutputBuffer>
class UTF8_Base10_Signed_Integer_Int32_2 : public UTF8_Base10_Signed_Integer_2<boost::int32_t, _InputBuffer, _OutputBuffer>
{
};

template <class _InputBuffer, class _OutputBuffer>
class UTF8_Base10_Signed_Integer_Int64_2 : public UTF8_Base10_Signed_Integer_2<boost::int64_t, _InputBuffer, _OutputBuffer>
{
};

template <class _InputBuffer, class _OutputBuffer>
class UTF8_Terminated_UTF16_Null_Terminated_2
{
public:
  typedef _InputBuffer input_buffer;
  typedef _OutputBuffer output_buffer;

  typedef boost::uint8_t UTF8;
  typedef boost::uint16_t UTF16;
  typedef boost::uint32_t UTF32;

  enum ConversionFlags {strictConversion = 0, lenientConversion};

private:

  /* Some fundamental constants */
  static const UTF32 UNI_REPLACEMENT_CHAR = (UTF32)0x0000FFFD;
  static const UTF32 UNI_MAX_BMP = (UTF32)0x0000FFFF;
  static const UTF32 UNI_MAX_UTF16 = (UTF32)0x0010FFFF;
  static const UTF32 UNI_MAX_UTF32 = (UTF32)0x7FFFFFFF;
  static const UTF32 UNI_MAX_LEGAL_UTF32 = (UTF32)0x0010FFFF;

  static const int halfShift  = 10; /* used for shifting by 10 bits */
  static const UTF32 halfBase = 0x0010000UL;
  static const UTF32 halfMask = 0x3FFUL;

  /* surrogate ranges */
  static const UTF32 UNI_SUR_HIGH_START =(UTF32)0xD800;
  static const UTF32 UNI_SUR_HIGH_END =(UTF32)0xDBFF;
  static const UTF32 UNI_SUR_LOW_START = (UTF32)0xDC00; 
  static const UTF32 UNI_SUR_LOW_END = (UTF32)0xDFFF;

  boost::uint8_t * mTerminatorStart;
  boost::uint8_t * mTerminatorEnd;
  ConversionFlags mFlags;

  static bool isLegalUTF8(const UTF8 *source, std::size_t length) 
  {
    UTF8 a;
    const UTF8 *srcptr = source+length;
    switch (length) {
    default: return false;
      /* Everything else falls through when "true"... */
    case 4: if ((a = (*--srcptr)) < 0x80 || a > 0xBF) return false;
    case 3: if ((a = (*--srcptr)) < 0x80 || a > 0xBF) return false;
    case 2: if ((a = (*--srcptr)) > 0xBF) return false;

      switch (*source) {
        /* no fall-through in this inner switch */
	    case 0xE0: if (a < 0xA0) return false; break;
	    case 0xED: if (a > 0x9F) return false; break;
	    case 0xF0: if (a < 0x90) return false; break;
	    case 0xF4: if (a > 0x8F) return false; break;
	    default:   if (a < 0x80) return false;
      }

    case 1: if (*source >= 0x80 && *source < 0xC2) return false;
    }
    if (*source > 0xF4) return false;
    return true;
  }

public:
  UTF8_Terminated_UTF16_Null_Terminated_2(const std::string& terminator)
    :
    mTerminatorStart(NULL),
    mTerminatorEnd(NULL),
    mFlags(strictConversion)
  {
    mTerminatorStart = new boost::uint8_t [terminator.size()];
    mTerminatorEnd = mTerminatorStart + terminator.size();
    memcpy(mTerminatorStart, terminator.c_str(), terminator.size());
  }

  UTF8_Terminated_UTF16_Null_Terminated_2(const UTF8_Terminated_UTF16_Null_Terminated_2& rhs)
    :
    mTerminatorStart(NULL),
    mTerminatorEnd(NULL),
    mFlags(strictConversion)
  {
    *this = rhs;
  }

  UTF8_Terminated_UTF16_Null_Terminated_2& operator=(const UTF8_Terminated_UTF16_Null_Terminated_2& rhs)
  {
    destroy();
    mTerminatorStart = new boost::uint8_t [rhs.mTerminatorEnd-rhs.mTerminatorStart];
    mTerminatorEnd = mTerminatorStart + (rhs.mTerminatorEnd-rhs.mTerminatorStart);
    memcpy(mTerminatorStart, rhs.mTerminatorStart, rhs.mTerminatorEnd-rhs.mTerminatorStart);
    return *this;
  }

  ~UTF8_Terminated_UTF16_Null_Terminated_2()
  {
    destroy();
  }

  void destroy()
  {
    delete [] mTerminatorStart;
    mTerminatorStart = NULL;
  }

  ParseDescriptor::Result Import(_InputBuffer& input, _OutputBuffer& output)
  {
    /*
     * Index into the table below with the first byte of a UTF-8 sequence to
     * get the number of trailing bytes that are supposed to follow it.
     * Note that *legal* UTF-8 values can't have 4 or 5-bytes. The table is
     * left as-is for anyone who may want to do such conversion, which was
     * allowed in earlier algorithms.
     */
    static const boost::int8_t trailingBytesForUTF8[256] = {
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
      2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 3,3,3,3,3,3,3,3,4,4,4,4,5,5,5,5
    };

    /*
     * Magic values subtracted from a buffer value during UTF8 conversion.
     * This table contains as many values as there might be trailing bytes
     * in a UTF-8 sequence.
     */
    static const UTF32 offsetsFromUTF8[6] = { 0x00000000UL, 0x00003080UL, 0x000E2080UL, 
                                              0x03C82080UL, 0xFA082080UL, 0x82082080UL };

    /*
     * Once the bits are split out into bytes of UTF-8, this is a mask OR-ed
     * into the first byte, depending on how many bytes follow.  There are
     * as many entries in this table as there are UTF-8 sequence types.
     * (I.e., one byte sequence, two byte... etc.). Remember that sequencs
     * for *legal* UTF-8 will be 4 or fewer bytes total.
     */
    static const UTF8 firstByteMark[7] = { 0x00, 0x00, 0xC0, 0xE0, 0xF0, 0xF8, 0xFC };

    boost::uint8_t * source;
    
    while(input.open(1, source)) 
    {
      UTF32 ch = 0;
      boost::uint16_t extraBytesToRead = trailingBytesForUTF8[*source];

      if (!input.open(1+extraBytesToRead, source))
      {
        return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
      }

      /* Do this check whether lenient or strict */
      if (! isLegalUTF8(source, extraBytesToRead+1)) {
        return ParseDescriptor::PARSE_ERROR;
      }

      /* 
       * Check whether we have satisfied the termination condition.  Do so 
       * after we know we have a valid UTF8 character.
       */

      /* 
       * TODO: Do we have to support escaping of terminator, if so then
       * the interface must change to support the case in which we decode
       * over multiple buffers and the terminator appears as the first code point
       * in a buffer.  We must remember the last (few?) code point(s?) from the previous buffer
       * in order to determine whether the terminator has been escaped or not.
       * Same is true if we have to support terminator strings.
       *
       */

      if (*source == *mTerminatorStart)
      {
        ASSERT((1+extraBytesToRead) <= (mTerminatorEnd-mTerminatorStart));
        // Load up enough to compare the terminator.  If there isn't enough,
        // then there can't be a terminator.
        if (input.open(mTerminatorEnd - mTerminatorStart, source))
        {
          // Matched terminator.  Null terminate target and return without consuming input.
          if (0 == memcmp(source, mTerminatorStart, mTerminatorEnd-mTerminatorStart))
          {
            boost::uint8_t * target;
            if (!output.open(sizeof(UTF16), target))
              return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
            *((UTF16 *)target) = 0;
            output.consume(sizeof(UTF16));
            return ParseDescriptor::PARSE_OK;
          }
          // Not a terminator, just fall through to process this code point.
        }
        else
        {
          // Our input ends with a terminator prefix.  Go back and open
          // up a single code point, then fall through..
          input.open(1+extraBytesToRead, source);
        }
      }

      /*
       * The cases all fall through. See "Note A" below.
       */
      switch (extraBytesToRead) 
      {
      case 5: ch += *source++; ch <<= 6; /* remember, illegal UTF-8 */
      case 4: ch += *source++; ch <<= 6; /* remember, illegal UTF-8 */
      case 3: ch += *source++; ch <<= 6;
      case 2: ch += *source++; ch <<= 6;
      case 1: ch += *source++; ch <<= 6;
      case 0: ch += *source++;
      }
      ch -= offsetsFromUTF8[extraBytesToRead];

      if (ch <= UNI_MAX_BMP) 
      { 
        boost::uint8_t * target;
        /* Target is a character <= 0xFFFF */
        if (!output.open(sizeof(UTF16), target))
          return ParseDescriptor::PARSE_TARGET_EXHAUSTED;

        /* UTF-16 surrogate values are illegal in UTF-32 */
        if (ch >= UNI_SUR_HIGH_START && ch <= UNI_SUR_LOW_END) {
          if (mFlags == strictConversion) {
            return ParseDescriptor::PARSE_ERROR;
          } else {
            *((UTF16 *)target) = UNI_REPLACEMENT_CHAR;
          }
        } else {
          *((UTF16 *)target) = (UTF16)ch; /* normal case */
        }
        output.consume(sizeof(UTF16));
      } 
      else if (ch > UNI_MAX_UTF16) 
      {
        if (mFlags == strictConversion) {
          return ParseDescriptor::PARSE_ERROR;
        } else {
          boost::uint8_t * target;
          if (!output.open(sizeof(UTF16), target))
            return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
          *((UTF16 *)target) = UNI_REPLACEMENT_CHAR;
          output.consume(sizeof(UTF16));
        }
      } else {
        /* target is a character in range 0xFFFF - 0x10FFFF. */
        boost::uint8_t * target;
        if (!output.open(2*sizeof(UTF16), target))
          return ParseDescriptor::PARSE_TARGET_EXHAUSTED;

        ch -= halfBase;
        ((UTF16 *)target)[0] = (UTF16)((ch >> halfShift) + UNI_SUR_HIGH_START);
        ((UTF16 *)target)[1] = (UTF16)((ch & halfMask) + UNI_SUR_LOW_START);
        output.consume(2*sizeof(UTF16));
      }

      // If we get here then we actually used the input.
      input.consume(1+extraBytesToRead);
    }

    // EOS for input.  Null terminate and outta here.
    {
      boost::uint8_t * target;
      if (!output.open(sizeof(UTF16), target))
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      *((UTF16 *)target) = 0;
      output.consume(sizeof(UTF16));
    }

    return ParseDescriptor::PARSE_OK;
  }

  ParseDescriptor::Result Export(_InputBuffer& input, _OutputBuffer& output)
  {
    /*
     * Once the bits are split out into bytes of UTF-8, this is a mask OR-ed
     * into the first byte, depending on how many bytes follow.  There are
     * as many entries in this table as there are UTF-8 sequence types.
     * (I.e., one byte sequence, two byte... etc.). Remember that sequencs
     * for *legal* UTF-8 will be 4 or fewer bytes total.
     */
    static const UTF8 firstByteMark[7] = { 0x00, 0x00, 0xC0, 0xE0, 0xF0, 0xF8, 0xFC };

    boost::uint8_t * source;
    
    while(input.open(sizeof(UTF16), source))
    { 
      UTF32 ch;
      unsigned short bytesToWrite = 0;
      const UTF32 byteMask = 0xBF;
      const UTF32 byteMark = 0x80; 
      ch = *((UTF16 *)source);
      input.consume(sizeof(UTF16));

      if (ch == 0)
      {
        // Null terminated, so we are done.
        // Note that we do NOT write the terminator.
        return ParseDescriptor::PARSE_OK;
      }

      ///////////////////////////////////////////////////
      // TODO: Add logic for properly escaping delimiter.
      ///////////////////////////////////////////////////

      /* If we have a surrogate pair, convert to UTF32 first. */
      if (ch >= UNI_SUR_HIGH_START && ch <= UNI_SUR_HIGH_END) 
      {
        /* If the 16 bits following the high surrogate are in the source buffer... */
        if (input.open(sizeof(UTF16), source))
        {
          UTF32 ch2 = *((UTF16 *)source);
          input.consume(sizeof(UTF16));
          /* If it's a low surrogate, convert to UTF32. */
          if (ch2 >= UNI_SUR_LOW_START && ch2 <= UNI_SUR_LOW_END) 
          {
            ch = ((ch - UNI_SUR_HIGH_START) << halfShift)
              + (ch2 - UNI_SUR_LOW_START) + halfBase; 
          } 
          else 
          {
            /* it's an unpaired high surrogate */
            // TODO: Better indicate where everything went wrong.
            return ParseDescriptor::PARSE_ERROR;
          }
        } 
        else 
        { /* We don't have the 16 bits following the high surrogate. */
          return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
        }
      } 
      else 
      {
        /* UTF-16 surrogate values are illegal in UTF-32 */
        if (ch >= UNI_SUR_LOW_START && ch <= UNI_SUR_LOW_END) 
        {
            // TODO: Better indicate where everything went wrong.
            return ParseDescriptor::PARSE_ERROR;
        }
      }
      /* Figure out how many bytes the result will require */
      if (ch < (UTF32)0x80) {	     bytesToWrite = 1;
      } else if (ch < (UTF32)0x800) {     bytesToWrite = 2;
      } else if (ch < (UTF32)0x10000) {   bytesToWrite = 3;
      } else if (ch < (UTF32)0x110000) {  bytesToWrite = 4;
      } else {			    
        bytesToWrite = 3;
        ch = UNI_REPLACEMENT_CHAR;
      }

      boost::uint8_t * targetTmp;
      if (!output.open(bytesToWrite*sizeof(UTF8), targetTmp)) 
      {
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      }
      // Write it backwards.
      UTF8 * target = (UTF8 *) targetTmp;
      target += bytesToWrite;
      switch (bytesToWrite) { /* note: everything falls through. */
	    case 4: *--target = (UTF8)((ch | byteMark) & byteMask); ch >>= 6;
	    case 3: *--target = (UTF8)((ch | byteMark) & byteMask); ch >>= 6;
	    case 2: *--target = (UTF8)((ch | byteMark) & byteMask); ch >>= 6;
	    case 1: *--target =  (UTF8)(ch | firstByteMark[bytesToWrite]);
      }
      output.consume(bytesToWrite*sizeof(UTF8));
    }

    //We are assuming NULL terminted input, so this is an error.
    return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
  }
};

template <class _InputBuffer, class _OutputBuffer>
class UTF8_Terminated_UTF8_Null_Terminated_2
{
public:
  typedef _InputBuffer input_buffer;
  typedef _OutputBuffer output_buffer;

  typedef boost::uint8_t UTF8;

  enum ConversionFlags {strictConversion = 0, lenientConversion};

private:

  boost::uint8_t * mTerminatorStart;
  boost::uint8_t * mTerminatorEnd;
  ConversionFlags mFlags;

  static bool isLegalUTF8(const UTF8 *source, std::size_t length) 
  {
    UTF8 a;
    const UTF8 *srcptr = source+length;
    switch (length) {
    default: return false;
      /* Everything else falls through when "true"... */
    case 4: if ((a = (*--srcptr)) < 0x80 || a > 0xBF) return false;
    case 3: if ((a = (*--srcptr)) < 0x80 || a > 0xBF) return false;
    case 2: if ((a = (*--srcptr)) > 0xBF) return false;

      switch (*source) {
        /* no fall-through in this inner switch */
	    case 0xE0: if (a < 0xA0) return false; break;
	    case 0xED: if (a > 0x9F) return false; break;
	    case 0xF0: if (a < 0x90) return false; break;
	    case 0xF4: if (a > 0x8F) return false; break;
	    default:   if (a < 0x80) return false;
      }

    case 1: if (*source >= 0x80 && *source < 0xC2) return false;
    }
    if (*source > 0xF4) return false;
    return true;
  }

public:
  UTF8_Terminated_UTF8_Null_Terminated_2(const std::string& terminator)
    :
    mTerminatorStart(NULL),
    mTerminatorEnd(NULL),
    mFlags(strictConversion)
  {
    mTerminatorStart = new boost::uint8_t [terminator.size()];
    mTerminatorEnd = mTerminatorStart + terminator.size();
    memcpy(mTerminatorStart, terminator.c_str(), terminator.size());
  }

  UTF8_Terminated_UTF8_Null_Terminated_2(const UTF8_Terminated_UTF8_Null_Terminated_2& rhs)
    :
    mTerminatorStart(NULL),
    mTerminatorEnd(NULL),
    mFlags(strictConversion)
  {
    *this = rhs;
  }

  UTF8_Terminated_UTF8_Null_Terminated_2& operator=(const UTF8_Terminated_UTF8_Null_Terminated_2& rhs)
  {
    destroy();
    mTerminatorStart = new boost::uint8_t [rhs.mTerminatorEnd-rhs.mTerminatorStart];
    mTerminatorEnd = mTerminatorStart + (rhs.mTerminatorEnd-rhs.mTerminatorStart);
    memcpy(mTerminatorStart, rhs.mTerminatorStart, rhs.mTerminatorEnd-rhs.mTerminatorStart);
    return *this;
  }

  ~UTF8_Terminated_UTF8_Null_Terminated_2()
  {
    destroy();
  }

  void destroy()
  {
    delete [] mTerminatorStart;
    mTerminatorStart = NULL;
  }

  ParseDescriptor::Result Import(_InputBuffer& input, _OutputBuffer& output)
  {
    /*
     * Index into the table below with the first byte of a UTF-8 sequence to
     * get the number of trailing bytes that are supposed to follow it.
     * Note that *legal* UTF-8 values can't have 4 or 5-bytes. The table is
     * left as-is for anyone who may want to do such conversion, which was
     * allowed in earlier algorithms.
     */
    static const boost::int8_t trailingBytesForUTF8[256] = {
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
      1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
      2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 3,3,3,3,3,3,3,3,4,4,4,4,5,5,5,5
    };

    boost::uint8_t * source;
    
    while(input.open(1, source)) 
    {
      boost::uint16_t extraBytesToRead = trailingBytesForUTF8[*source];

      if (!input.open(1+extraBytesToRead, source))
      {
        return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
      }

      /* Do this check whether lenient or strict */
      if (! isLegalUTF8(source, extraBytesToRead+1)) {
        return ParseDescriptor::PARSE_ERROR;
      }

      /* 
       * Check whether we have satisfied the termination condition.  Do so 
       * after we know we have a valid UTF8 character.
       */

      /* 
       * TODO: Do we have to support escaping of terminator, if so then
       * the interface must change to support the case in which we decode
       * over multiple buffers and the terminator appears as the first code point
       * in a buffer.  We must remember the last (few?) code point(s?) from the previous buffer
       * in order to determine whether the terminator has been escaped or not.
       * Same is true if we have to support terminator strings.
       *
       */

      if (*source == *mTerminatorStart)
      {
        ASSERT((1+extraBytesToRead) <= (mTerminatorEnd-mTerminatorStart));
        // Load up enough to compare the terminator.  If there isn't enough,
        // then there can't be a terminator.
        if (input.open(mTerminatorEnd - mTerminatorStart, source))
        {
          // Matched terminator.  Null terminate target and return without consuming input.
          if (0 == memcmp(source, mTerminatorStart, mTerminatorEnd-mTerminatorStart))
          {
            boost::uint8_t * target;
            if (!output.open(sizeof(UTF8), target))
              return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
            *((UTF8 *)target) = 0;
            output.consume(sizeof(UTF8));
            return ParseDescriptor::PARSE_OK;
          }
          // Not a terminator, just fall through to process this code point.
        }
        else
        {
          // Our input ends with a terminator prefix.  Go back and open
          // up a single code point, then fall through..
          input.open(1+extraBytesToRead, source);
        }
      }

      boost::uint8_t * target;
      output.open(1+extraBytesToRead, target);
      /*
       * The cases all fall through. See "Note A" below.
       */
      switch (extraBytesToRead) 
      {
      case 5: *target++ = *source++; /* remember, illegal UTF-8 */
      case 4: *target++ = *source++; /* remember, illegal UTF-8 */
      case 3: *target++ = *source++; 
      case 2: *target++ = *source++; 
      case 1: *target++ = *source++; 
      case 0: *target++ = *source++;
      }

      // If we get here then we actually used the input.
      input.consume(1+extraBytesToRead);
      output.consume(1+extraBytesToRead);
    }

    // EOS for input.  Null terminate and outta here.
    {
      boost::uint8_t * target;
      if (!output.open(sizeof(UTF8), target))
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      *((UTF8 *)target) = 0;
      output.consume(sizeof(UTF8));
    }

    return ParseDescriptor::PARSE_OK;
  }
  ParseDescriptor::Result Export(_InputBuffer& input, _OutputBuffer& output)
  {
    // Read input till null terminator copying all the way.
    // TODO: Open up the input till null terminator then memcpy.
    boost::uint8_t * source;
    while(input.open(1, source)) 
    {
      if (0 == *source) 
      {
        input.consume(1);
        return ParseDescriptor::PARSE_OK;
      }

      boost::uint8_t * target;
      if (output.open(1, target))
      {
        *target = *source;
        input.consume(1);
        output.consume(1);
      }
      else
      {
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      }
    }

    return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
  }
};

/**
 * This is worth doing as a special case since the 
 * ISO-8859-1 code page was embedded as the first 256 UTF16 code points.
 */
template <class _InputBuffer, class _OutputBuffer>
class ISO_8859_1_Terminated_UTF16_Null_Terminated_2
{
public:
  typedef _InputBuffer input_buffer;
  typedef _OutputBuffer output_buffer;

  typedef boost::uint16_t UTF16;

  enum ConversionFlags {strictConversion = 0, lenientConversion};

private:

  boost::uint8_t * mTerminatorStart;
  boost::uint8_t * mTerminatorEnd;
  ConversionFlags mFlags;

public:

  /**
   * TODO: Should we assume the terminator is UTF8 or ASCII?
   */
  ISO_8859_1_Terminated_UTF16_Null_Terminated_2(const std::string& terminator)
    :
    mTerminatorStart(NULL),
    mTerminatorEnd(NULL),
    mFlags(strictConversion)
  {
    mTerminatorStart = new boost::uint8_t [terminator.size()];
    mTerminatorEnd = mTerminatorStart + terminator.size();
    memcpy(mTerminatorStart, terminator.c_str(), terminator.size());
  }

  ISO_8859_1_Terminated_UTF16_Null_Terminated_2(const ISO_8859_1_Terminated_UTF16_Null_Terminated_2& rhs)
    :
    mTerminatorStart(NULL),
    mTerminatorEnd(NULL),
    mFlags(strictConversion)
  {
    *this = rhs;
  }

  ISO_8859_1_Terminated_UTF16_Null_Terminated_2& operator=(const ISO_8859_1_Terminated_UTF16_Null_Terminated_2& rhs)
  {
    destroy();
    mTerminatorStart = new boost::uint8_t [rhs.mTerminatorEnd-rhs.mTerminatorStart];
    mTerminatorEnd = mTerminatorStart + (rhs.mTerminatorEnd-rhs.mTerminatorStart);
    memcpy(mTerminatorStart, rhs.mTerminatorStart, rhs.mTerminatorEnd-rhs.mTerminatorStart);
    return *this;
  }

  ~ISO_8859_1_Terminated_UTF16_Null_Terminated_2()
  {
    destroy();
  }

  void destroy()
  {
    delete [] mTerminatorStart;
    mTerminatorStart = NULL;
  }

  ParseDescriptor::Result Import(_InputBuffer& input, _OutputBuffer& output)
  {
    boost::uint8_t * source;
    
    while(input.open(1, source)) 
    {
      /* 
       * Check whether we have satisfied the termination condition.  Do so 
       * after we know we have a valid UTF8 character.
       */

      /* 
       * TODO: Do we have to support escaping of terminator, if so then
       * the interface must change to support the case in which we decode
       * over multiple buffers and the terminator appears as the first code point
       * in a buffer.  We must remember the last (few?) code point(s?) from the previous buffer
       * in order to determine whether the terminator has been escaped or not.
       * Same is true if we have to support terminator strings.
       *
       */

      if (*source == *mTerminatorStart)
      {
        // Load up enough to compare the terminator.  If there isn't enough,
        // then there can't be a terminator.
        if (input.open(mTerminatorEnd - mTerminatorStart, source))
        {
          // Matched terminator.  Null terminate target and return without consuming input.
          if (0 == memcmp(source, mTerminatorStart, mTerminatorEnd-mTerminatorStart))
          {
            boost::uint8_t * target;
            if (!output.open(sizeof(UTF16), target))
              return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
            *((UTF16 *)target) = 0;
            output.consume(sizeof(UTF16));
            return ParseDescriptor::PARSE_OK;
          }
          // Not a terminator, just fall through to process this code point.
        }
      }

      boost::uint8_t * target;
      output.open(sizeof(UTF16), target);
      
      // ISO-8859-1 -> UTF16 is just an embedding.
      *((UTF16 *)target) = (UTF16) *source;

      // If we get here then we actually used the input.
      input.consume(1);
      output.consume(sizeof(UTF16));
    }

    // EOS for input.  Null terminate and outta here.
    {
      boost::uint8_t * target;
      if (!output.open(sizeof(UTF16), target))
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      *((UTF16 *)target) = 0;
      output.consume(sizeof(UTF16));
    }

    return ParseDescriptor::PARSE_OK;
  }
  ParseDescriptor::Result Export(_InputBuffer& input, _OutputBuffer& output)
  {
    boost::uint8_t * source;
    
    while(input.open(sizeof(UTF16), source)) 
    {
      /* 
       * Check whether we have satisfied the termination condition.  Do so 
       * after we know we have a valid UTF8 character.
       */

      /* 
       * TODO: Do we have to support escaping of terminator, if so then
       * the interface must change to support the case in which we decode
       * over multiple buffers and the terminator appears as the first code point
       * in a buffer.  We must remember the last (few?) code point(s?) from the previous buffer
       * in order to determine whether the terminator has been escaped or not.
       * Same is true if we have to support terminator strings.
       *
       */

      if (*((UTF16 *)source) == 0)
      {
        input.consume(sizeof(UTF16));
        return ParseDescriptor::PARSE_OK;
      }

      // Validate that this is a valid ISO-8859-1 codepoint.
      if (*((UTF16 *)source) > 256)
      {
        return ParseDescriptor::PARSE_ERROR;
      }

      boost::uint8_t * target;
      output.open(1, target);
      
      // ISO-8859-1 -> UTF16 is just an embedding.
      *target = (boost::uint8_t) *((UTF16 *)source);

      // If we get here then we actually used the input.
      input.consume(sizeof(UTF16));
      output.consume(1);
    }

    // We assume a null terminator so it we didn't find it, say error.
    return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
  }
};

template <class _InputBuffer, class _OutputBuffer>
class UTF8_String_Literal_UTF8_Null_Terminated_2
{
private:
  boost::uint8_t * mLiteralBegin;
  boost::uint8_t * mLiteralEnd;

public:
  UTF8_String_Literal_UTF8_Null_Terminated_2(const std::string& literal)
    :
    mLiteralBegin(NULL),
    mLiteralEnd(NULL)
  {
    mLiteralBegin = new boost::uint8_t [literal.size()];
    mLiteralEnd = mLiteralBegin + literal.size();
    memcpy(mLiteralBegin, literal.c_str(), literal.size());
  }
  UTF8_String_Literal_UTF8_Null_Terminated_2(const UTF8_String_Literal_UTF8_Null_Terminated_2 & rhs)
    :
    mLiteralBegin(NULL),
    mLiteralEnd(NULL)
  {
    *this = rhs;
  }
  ~UTF8_String_Literal_UTF8_Null_Terminated_2()
  {
    destroy();
  }

  UTF8_String_Literal_UTF8_Null_Terminated_2& operator=(const UTF8_String_Literal_UTF8_Null_Terminated_2 & rhs)
  {
    destroy();
    mLiteralBegin = new boost::uint8_t [rhs.mLiteralEnd-rhs.mLiteralBegin];
    mLiteralEnd = mLiteralBegin + (rhs.mLiteralEnd-rhs.mLiteralBegin);
    memcpy(mLiteralBegin, rhs.mLiteralBegin, rhs.mLiteralEnd-rhs.mLiteralBegin);
    return *this;
  }

  void destroy()
  {
    delete [] mLiteralBegin;
    mLiteralBegin = mLiteralEnd = NULL;
  }

  ParseDescriptor::Result Import(_InputBuffer& input, _OutputBuffer & output)
  {
    std::ptrdiff_t sz = mLiteralEnd-mLiteralBegin;
    boost::uint8_t * inputBuffer;
    boost::uint8_t * outputBuffer;
    if(!input.open(sz, inputBuffer) ||
       !output.open(sz, outputBuffer) ||
       memcmp(inputBuffer, mLiteralBegin, sz))
      return ParseDescriptor::PARSE_ERROR;

    memcpy(outputBuffer, inputBuffer, sz);
    input.consume(sz);
    output.consume(sz);
    return ParseDescriptor::PARSE_OK;
  }
  ParseDescriptor::Result Export(_InputBuffer& input, _OutputBuffer & output)
  {
    //??????? Should we consume anything from the input on export ??????
    //??????? Should we validate that the input conforms to the literal ???????
    std::ptrdiff_t sz = mLiteralEnd-mLiteralBegin;
    boost::uint8_t * outputBuffer;
    if(!output.open(sz, outputBuffer))
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;

    memcpy(outputBuffer, mLiteralBegin, sz);
    output.consume(sz);
    return ParseDescriptor::PARSE_OK;
  }
};

// TODO: Add more general boolean importer that handles multi-character encoding and multi-character delimiters.
template <class _InputBuffer, class _OutputBuffer>
class UTF8_String_Literal_Terminated_Boolean_2
{
private:
  char mTrue;
  char mFalse;
  char mDelimiter[2];
public:
  UTF8_String_Literal_Terminated_Boolean_2(const std::string& trueValue, const std::string& falseValue, const std::string& delimiter)
    :
    mTrue(trueValue[0]),
    mFalse(falseValue[0])
  {
    mDelimiter[0] = delimiter[0];
    ASSERT(trueValue.size() == 1 && falseValue.size() == 1 && delimiter.size() == 1);
  }

  ~UTF8_String_Literal_Terminated_Boolean_2()
  {
    destroy();
  }
  
  void destroy()
  {
  }

  ParseDescriptor::Result Import(_InputBuffer& input, _OutputBuffer & output)
  {
    boost::uint8_t * inputBuffer;
    boost::uint8_t * outputBuffer;
    if(!input.open(2, inputBuffer) ||
       !output.open(sizeof(bool), outputBuffer))
      return ParseDescriptor::PARSE_ERROR;

    if (((char *)inputBuffer)[0] == mTrue && ((char *)inputBuffer)[1] == mDelimiter[0])
      *((bool *)outputBuffer) = true;
    else if (((char *)inputBuffer)[0] == mFalse && ((char *)inputBuffer)[1] == mDelimiter[0])
      *((bool *)outputBuffer) = false;
    else
      return ParseDescriptor::PARSE_ERROR;

    input.consume(1);
    output.consume(sizeof(bool));
    return ParseDescriptor::PARSE_OK;
  }
  ParseDescriptor::Result Export(_InputBuffer& input, _OutputBuffer & output)
  {
    boost::uint8_t * inputBuffer;
    boost::uint8_t * outputBuffer;
    if(!input.open(sizeof(bool), inputBuffer) ||
       !output.open(1, outputBuffer))
      return ParseDescriptor::PARSE_ERROR;

    *((char *)outputBuffer) = *((bool *)inputBuffer) ? mTrue : mFalse;

    input.consume(sizeof(bool));
    output.consume(1);
    return ParseDescriptor::PARSE_OK;
  }
};

// TODO: Add more general binary importer including the variable length/delimited case and more general prefixes.
template <class _InputBuffer, class _OutputBuffer>
class UTF8_Fixed_Length_Hex_Binary_2
{
public:
  UTF8_Fixed_Length_Hex_Binary_2()
  {
  }

  ~UTF8_Fixed_Length_Hex_Binary_2()
  {
    destroy();
  }
  
  void destroy()
  {
  }

  ParseDescriptor::Result Import(_InputBuffer& input, _OutputBuffer & output)
  {
    boost::uint8_t * inputBuffer;
    boost::uint8_t * outputBuffer;
    if(!input.open(34, inputBuffer))
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;

    if(!output.open(16, outputBuffer))
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;

    if (((char *)inputBuffer)[0] != '0' || ((char *)inputBuffer)[1] != 'x')
      return ParseDescriptor::PARSE_ERROR;

    boost::uint8_t * inputBufferEnd=inputBuffer + 34;
    inputBuffer += 2;
    while(inputBuffer < inputBufferEnd)
    {
      boost::uint8_t tmp;
      if (*((char *)inputBuffer) >= '0' && *((char *)inputBuffer) <= '9')
      {
        tmp = (boost::uint8_t)(*((char *)inputBuffer) - '0');
      }
      else if (*((char *)inputBuffer) >= 'a' && *((char *)inputBuffer) <= 'f')
      {
        tmp = 0x0a + (boost::uint8_t)(*((char *)inputBuffer) - 'a');
      }
      else if (*((char *)inputBuffer) >= 'A' && *((char *)inputBuffer) <= 'F')
      {
        tmp = 0x0a + (boost::uint8_t)(*((char *)inputBuffer) - 'A');
      }
      else
      {
        return ParseDescriptor::PARSE_ERROR;
      }
      inputBuffer++;
      if (*((char *)inputBuffer) >= '0' && *((char *)inputBuffer) <= '9')
      {
        *outputBuffer++ = (tmp<<4) + (boost::uint8_t)(*((char *)inputBuffer) - '0');
      }
      else if (*((char *)inputBuffer) >= 'a' && *((char *)inputBuffer) <= 'f')
      {
        *outputBuffer++ = (tmp<<4) + 0x0a + (boost::uint8_t)(*((char *)inputBuffer) - 'a');
      }
      else if (*((char *)inputBuffer) >= 'A' && *((char *)inputBuffer) <= 'F')
      {
        *outputBuffer++ = (tmp<<4) + 0x0a + (boost::uint8_t)(*((char *)inputBuffer) - 'A');
      }
      else
      {
        return ParseDescriptor::PARSE_ERROR;
      }
      inputBuffer++;
    }

    input.consume(34);
    output.consume(16);
    return ParseDescriptor::PARSE_OK;
  }
  ParseDescriptor::Result Export(_InputBuffer& input, _OutputBuffer & output)
  {
    static const char hexDigits[] = "0123456789abcdef";
    boost::uint8_t * inputBuffer;
    if(!input.open(16, inputBuffer))
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;

    boost::uint8_t * rawOutputBuffer;
    if(!output.open(34, rawOutputBuffer))
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
    
    char * outputBuffer = (char *)rawOutputBuffer;
    
    *outputBuffer++ = '0';
    *outputBuffer++ = 'x';

    // TODO: Worth unrolling the loop?
    boost::uint8_t * inputBufferEnd=inputBuffer + 16;
    while(inputBuffer < inputBufferEnd)
    {
      *outputBuffer++ = hexDigits[(*inputBuffer & 0xf0)>>4];
      *outputBuffer++ = hexDigits[(*inputBuffer++ & 0x0f)];
    }

    input.consume(16);
    output.consume(34);
    return ParseDescriptor::PARSE_OK;
  }
};

template <class _InputBuffer, class _OutputBuffer>
class UTF8_String_Literal_Terminated_UTF8_Null_Terminated_2
{
private:
  boost::uint8_t * mLiteralBegin;
  boost::uint8_t * mLiteralEnd;
  boost::uint8_t * mDelimiterEnd;

public:
  UTF8_String_Literal_Terminated_UTF8_Null_Terminated_2(const std::string& literal, const std::string& delimiter)
    :
    mLiteralBegin(NULL),
    mLiteralEnd(NULL),
    mDelimiterEnd(NULL)
  {
    mLiteralBegin = new boost::uint8_t [literal.size()+delimiter.size()];
    mLiteralEnd = mLiteralBegin + literal.size();
    mDelimiterEnd = mLiteralBegin + literal.size() + delimiter.size();
    memcpy(mLiteralBegin, literal.c_str(), literal.size());
    memcpy(mLiteralBegin+literal.size(), delimiter.c_str(), delimiter.size());
  }
  UTF8_String_Literal_Terminated_UTF8_Null_Terminated_2(const UTF8_String_Literal_Terminated_UTF8_Null_Terminated_2 & rhs)
    :
    mLiteralBegin(NULL),
    mLiteralEnd(NULL),
    mDelimiterEnd(NULL)
  {
    *this = rhs;
  }
  ~UTF8_String_Literal_Terminated_UTF8_Null_Terminated_2()
  {
    destroy();
  }

  UTF8_String_Literal_Terminated_UTF8_Null_Terminated_2& operator=(const UTF8_String_Literal_Terminated_UTF8_Null_Terminated_2 & rhs)
  {
    destroy();
    mLiteralBegin = new boost::uint8_t [rhs.mDelimiterEnd-rhs.mLiteralBegin];
    mLiteralEnd = mLiteralBegin + (rhs.mLiteralEnd-rhs.mLiteralBegin);
    mDelimiterEnd = mLiteralBegin + (rhs.mDelimiterEnd-rhs.mLiteralBegin);
    memcpy(mLiteralBegin, rhs.mLiteralBegin, rhs.mDelimiterEnd-rhs.mLiteralBegin);
    return *this;
  }

  void destroy()
  {
    delete [] mLiteralBegin;
    mLiteralBegin = mLiteralEnd = mDelimiterEnd = NULL;
  }

  ParseDescriptor::Result Import(_InputBuffer& input, _OutputBuffer & output)
  {
    std::ptrdiff_t sz = mDelimiterEnd-mLiteralBegin;
    boost::uint8_t * inputBuffer;
    boost::uint8_t * outputBuffer;
    if(!input.open(mDelimiterEnd-mLiteralBegin, inputBuffer) ||
       !output.open(mLiteralEnd-mLiteralBegin, outputBuffer) ||
       memcmp(inputBuffer, mLiteralBegin, mDelimiterEnd-mLiteralBegin))
      return ParseDescriptor::PARSE_ERROR;

    memcpy(outputBuffer, inputBuffer, mLiteralEnd-mLiteralBegin);
    input.consume(mLiteralEnd-mLiteralBegin);
    output.consume(mLiteralEnd-mLiteralBegin);
    return ParseDescriptor::PARSE_OK;
  }
};

template <class _InputBuffer, class _OutputBuffer>
class UTF8_Terminated_Enum_2
{
private:
  DynamicArrayParseBuffer mInternalBuffer;
  UTF8_Terminated_UTF16_Null_Terminated_2<_InputBuffer, DynamicArrayParseBuffer> mImporter;
  PerfectEnumeratorHash mHashTable;
public:
  UTF8_Terminated_Enum_2(const std::string& terminator, const std::wstring& enumspace, const std::wstring& enumerator)
    :
    mInternalBuffer(16),
    mImporter(terminator),
    mHashTable(enumspace.c_str(), enumerator.c_str())
  {
  }

  ~UTF8_Terminated_Enum_2()
  {
  }

  void destroy()
  {
    mInternalBuffer.destroy();
    mImporter.destroy();
    mHashTable.destroy();
  }

  ParseDescriptor::Result Import(_InputBuffer& input, _OutputBuffer& output)
  {
    boost::uint8_t * target;
    if (!output.open(sizeof(boost::int32_t), target))
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;

    ParseDescriptor::Result r = mImporter.Import(input, mInternalBuffer);
    if (r != ParseDescriptor::PARSE_OK)
    {
      return r;
    }

    // Lookup the enum value.
    *((boost::int32_t *)target) = mHashTable.Lookup(mInternalBuffer.buffer(), mInternalBuffer.size());
    mInternalBuffer.clear();
    if (*((boost::int32_t *)target) != -1)
    {
      output.consume(sizeof(boost::int32_t));
      return ParseDescriptor::PARSE_OK;
    }
    else
    {
      return ParseDescriptor::PARSE_ERROR;
    }
  }  
  ParseDescriptor::Result Export(_InputBuffer& input, _OutputBuffer& output)
  {
    // TODO: IMPLEMENT ME!
    std::string foo("Not yet implemented");
    boost::uint8_t * outputBuffer;
    if(output.open(foo.size(), outputBuffer))
    {
      memcpy(outputBuffer, foo.c_str(), foo.size());
      output.consume(foo.size());
      return ParseDescriptor::PARSE_OK;
    }
    else
    {
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
    }
  }
};

template <class _InputBuffer, class _OutputBuffer>
class ISO8601_DateTime_2
{
public:
  ISO8601_DateTime_2()
  {
  }

  void destroy()
  {
  }

  ParseDescriptor::Result Import(_InputBuffer & input, _OutputBuffer& output)
  {
    // Example "2007-10-17 12:30:00 AM"
    // Technically not ISO8601 since it uses a 12 hour clock.
    boost::uint8_t * inputBuffer;
    if (!input.open(22, inputBuffer))
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
    
    boost::uint8_t * outputBuffer;
    if (!output.open(sizeof(date_time_traits::value), outputBuffer))
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;

    // TODO: Put into date_time_traits
#ifdef WIN32
    // Initialize
    SYSTEMTIME t;

    memset(&t, 0, sizeof(SYSTEMTIME));

    const char * inputBufferIt = (const char *)inputBuffer;
    MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RecordDateFormat]");

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wYear = 1000*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wYear += 100*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wYear += 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wYear += (*inputBufferIt++ - '0');

    if (*inputBufferIt++ != '-') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wMonth = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wMonth += (*inputBufferIt++ - '0');

    if (*inputBufferIt++ != '-') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wDay = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wDay += (*inputBufferIt++ - '0');

    if (*inputBufferIt++ != ' ') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wHour = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wHour += (*inputBufferIt++ - '0');

    if (*inputBufferIt++ != ':') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wMinute = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wMinute += (*inputBufferIt++ - '0');

    if (*inputBufferIt++ != ':') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wSecond = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wSecond += (*inputBufferIt++ - '0');

    //if (*inputBufferIt++ != ' ') return ParseDescriptor::PARSE_ERROR;
    if (*inputBufferIt++ == ' ') //return ParseDescriptor::PARSE_ERROR;
    {

      if (*inputBufferIt == 'P') 
    {
      if (t.wHour < 12)
      {
        t.wHour += 12;
      }
    }
    else if (*inputBufferIt == 'A')
    {
      if (t.wHour == 12)
      {
        t.wHour = 0;
      }
    }
    else
    {
      return ParseDescriptor::PARSE_ERROR;
    }
    inputBufferIt += 1;

    input.consume(22);

    if (*inputBufferIt++ != 'M') return ParseDescriptor::PARSE_ERROR;
    }
    else
    {

    input.consume(19);
    }
    
    ::SystemTimeToVariantTime(&t, (date_time_traits::pointer) outputBuffer);
      
    output.consume(sizeof(date_time_traits::value));
    return ParseDescriptor::PARSE_OK;
#else
    // Initialize
    struct tm t;

    const char * inputBufferIt = (const char *)inputBuffer;

    MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[RecordDateFormat]");

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_year = 1000*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_year += 100*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_year += 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_year += (*inputBufferIt++ - '0');
    t.tm_year -= 1900;

    if (*inputBufferIt++ != '-') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_mon = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_mon += (*inputBufferIt++ - '0');
    t.tm_mon -= 1;

    if (*inputBufferIt++ != '-') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_mday = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_mday += (*inputBufferIt++ - '0');

    t.tm_wday = 0;
    t.tm_yday = 0;

    if (*inputBufferIt++ != ' ') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_hour = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_hour += (*inputBufferIt++ - '0');

    if (*inputBufferIt++ != ':') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_min = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_min += (*inputBufferIt++ - '0');

    if (*inputBufferIt++ != ':') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_sec = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_sec += (*inputBufferIt++ - '0');

    if (*inputBufferIt++ != ' ') //return ParseDescriptor::PARSE_ERROR;
    //if (*inputBufferIt++ != ' ') return ParseDescriptor::PARSE_ERROR;
    {

      if (*inputBufferIt == 'P') 
    {
      t.tm_hour += 12;
    }
    else if (*inputBufferIt != 'A')
    {
      return ParseDescriptor::PARSE_ERROR;
    }
    inputBufferIt += 1;

    input.consume(22);

    if (*inputBufferIt++ != 'M') return ParseDescriptor::PARSE_ERROR;
    }
    else
    {

      input.consume(19);
    }
    
    *((date_time_traits::pointer) outputBuffer) = boost::date_time::date_from_tm(&t);
    
    output.consume(sizeof(date_time_traits::value));
    return ParseDescriptor::PARSE_OK;
#endif
  }
  ParseDescriptor::Result Export(_InputBuffer & input, _OutputBuffer& output)
  {
    const char decimal_digits [] = "0123456789";
    // Example "2007-10-17 12:30:00 AM"
    // Technically not ISO8601 since it uses a 12 hour clock.
    boost::uint8_t * inputBuffer;
    if (!input.open(sizeof(date_time_traits::value), inputBuffer))
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;

    boost::uint8_t * outputBuffer;
    if (!output.open(22, outputBuffer))
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
    
    // TODO: Put into date_time_traits
#ifdef WIN32
    // Initialize
    SYSTEMTIME t;
    ::VariantTimeToSystemTime(*((date_time_traits::pointer) inputBuffer), &t);
    
    char * outputBufferIt = (char *)outputBuffer;
    // Go backwards

    outputBufferIt += 22;
    *--outputBufferIt = 'M';

    if (t.wHour >= 12)
    {
      *--outputBufferIt = 'P';
      if (t.wHour > 12)
      {
        t.wHour -= 12;
      }
    }
    else
    {
      if (t.wHour == 0)
      {
        t.wHour = 12;
      }
      *--outputBufferIt = 'A';
    }

    *--outputBufferIt = ' ';

    *--outputBufferIt = decimal_digits[t.wSecond % 10];
    t.wSecond /= 10;
    *--outputBufferIt = decimal_digits[t.wSecond % 10];
    t.wSecond /= 10;

    *--outputBufferIt = ':';

    *--outputBufferIt = decimal_digits[t.wMinute % 10];
    t.wMinute /= 10;
    *--outputBufferIt = decimal_digits[t.wMinute % 10];
    t.wMinute /= 10;

    *--outputBufferIt = ':';

    *--outputBufferIt = decimal_digits[t.wHour % 10];
    t.wHour /= 10;
    *--outputBufferIt = decimal_digits[t.wHour % 10];
    t.wHour /= 10;

    *--outputBufferIt = ' ';

    *--outputBufferIt = decimal_digits[t.wDay % 10];
    t.wDay /= 10;
    *--outputBufferIt = decimal_digits[t.wDay % 10];
    t.wDay /= 10;

    *--outputBufferIt = '-';

    *--outputBufferIt = decimal_digits[t.wMonth % 10];
    t.wMonth /= 10;
    *--outputBufferIt = decimal_digits[t.wMonth % 10];
    t.wMonth /= 10;

    *--outputBufferIt = '-';

    *--outputBufferIt = decimal_digits[t.wYear % 10];
    t.wYear /= 10;
    *--outputBufferIt = decimal_digits[t.wYear % 10];
    t.wYear /= 10;
    *--outputBufferIt = decimal_digits[t.wYear % 10];
    t.wYear /= 10;
    *--outputBufferIt = decimal_digits[t.wYear % 10];
    t.wYear /= 10;

    
    input.consume(sizeof(date_time_traits::value));
    output.consume(22);
    return ParseDescriptor::PARSE_OK;
#else
#endif
  }
};

template <class _InputBuffer, class _OutputBuffer>
class DateString_DateTime_2
{
public:
  DateString_DateTime_2()
  {
  }

  void destroy()
  {
  }

  ParseDescriptor::Result Import(_InputBuffer & input, _OutputBuffer& output)
  {
    boost::int32_t formatLength=10;
    // TODO: Build out the general configuration of date time parsing
    // using templates such as "YYYY-MM-DD", "HH:MM:SS" etc.
    
    // For the moment we are hard coding a simple case.
    // Example "10-17-2007"
    boost::uint8_t * inputBuffer;
    if (!input.open(formatLength, inputBuffer))
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
    
    boost::uint8_t * outputBuffer;
    if (!output.open(sizeof(date_time_traits::value), outputBuffer))
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;

    // TODO: Put into date_time_traits
#ifdef WIN32
    // Initialize
    SYSTEMTIME t;

    const char * inputBufferIt = (const char *)inputBuffer;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wMonth = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wMonth += (*inputBufferIt++ - '0');

    if (*inputBufferIt++ != '-') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wDay = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wDay += (*inputBufferIt++ - '0');

    if (*inputBufferIt++ != '-') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wYear = 1000*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wYear += 100*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wYear += 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.wYear += (*inputBufferIt++ - '0');

    t.wHour = 0;
    t.wMinute = 0;
    t.wSecond = 0;

    ::SystemTimeToVariantTime(&t, (date_time_traits::pointer) outputBuffer);
  
    input.consume(formatLength);
    output.consume(sizeof(date_time_traits::value));
    return ParseDescriptor::PARSE_OK;
#else
    // Initialize
    struct tm t;

    const char * inputBufferIt = (const char *)inputBuffer;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_mon = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_mon += (*inputBufferIt++ - '0');
    t.tm_mon -= 1;

    if (*inputBufferIt++ != '-') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_mday = 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_mday += (*inputBufferIt++ - '0');

    if (*inputBufferIt++ != '-') return ParseDescriptor::PARSE_ERROR;

    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_year = 1000*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_year += 100*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_year += 10*(*inputBufferIt++ - '0');
    if (*inputBufferIt < '0' || *inputBufferIt > '9') return ParseDescriptor::PARSE_ERROR;
    t.tm_year += (*inputBufferIt++ - '0');
    t.tm_year -= 1900;

    t.tm_wday = 0;
    t.tm_yday = 0;
    t.tm_hour = 0;
    t.tm_min = 0;
    t.tm_sec = 0;

    *((date_time_traits::pointer) outputBuffer) = boost::date_time::date_from_tm(&t);
  
    input.consume(22);
    output.consume(sizeof(date_time_traits::value));
    return ParseDescriptor::PARSE_OK;
#endif
  }
  ParseDescriptor::Result Export(_InputBuffer & input, _OutputBuffer& output)
  {
    boost::int32_t formatLength = 10;
    const char decimal_digits [] = "0123456789";
    // Example "2007-10-17 12:30:00 AM"
    // Technically not DateString since it uses a 12 hour clock.
    boost::uint8_t * inputBuffer;
    if (!input.open(sizeof(date_time_traits::value), inputBuffer))
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;

    boost::uint8_t * outputBuffer;
    if (!output.open(formatLength, outputBuffer))
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
    
    // TODO: Put into date_time_traits
#ifdef WIN32
    // Initialize
    SYSTEMTIME t;
    ::VariantTimeToSystemTime(*((date_time_traits::pointer) inputBuffer), &t);
    
    char * outputBufferIt = (char *)outputBuffer;
    // Go backwards
    outputBufferIt += formatLength;

    *--outputBufferIt = decimal_digits[t.wYear % 10];
    t.wYear /= 10;
    *--outputBufferIt = decimal_digits[t.wYear % 10];
    t.wYear /= 10;
    *--outputBufferIt = decimal_digits[t.wYear % 10];
    t.wYear /= 10;
    *--outputBufferIt = decimal_digits[t.wYear % 10];
    t.wYear /= 10;

    *--outputBufferIt = '-';

    *--outputBufferIt = decimal_digits[t.wDay % 10];
    t.wDay /= 10;
    *--outputBufferIt = decimal_digits[t.wDay % 10];
    t.wDay /= 10;

    *--outputBufferIt = '-';

    *--outputBufferIt = decimal_digits[t.wMonth % 10];
    t.wMonth /= 10;
    *--outputBufferIt = decimal_digits[t.wMonth % 10];
    t.wMonth /= 10;
    
    input.consume(sizeof(date_time_traits::value));
    output.consume(formatLength);
    return ParseDescriptor::PARSE_OK;
#else
#endif
  }
};

#ifdef WIN32
/**
 * Basic idea is to try to maximize the amount of 32-bit arithmetic
 * being done.
 * To support this we leverage the fact that 9 decimal digits will
 * always fit into a boost::uint32_t.  So we import 9 digits at a time
 * into a boost::uint32_t and then we multiply by the appropriate
 * decimal factor (10^(9*N) for N=0..4) to convert into DECIMAL.
 */
template <class _InputBuffer, class _OutputBuffer>
class UTF8_Base10_Decimal_DECIMAL_2
{
private:
  /**
   * We use 64-bit multiplication to implement multiprecision multiplication as follows.
   * Treat a positive multiprecision number as a vector of 32 bit numbers:
   * boost::uint32_t x[M+1];  (x = x[0] + 2^32*x[1] + ... + 2^(32*M)*x[M])
   * boost::uint32_t y[N+1];  (y = y[0] + 2^32*y[1] + ... + 2^(32*N)*y[N])
   * boost::uint32_t x_y[M+N+1]; (x_y = sum_{j=0..(M+N)} (sum_{i=0..j} x[i]*y[j-i])*2^(32*j)
   * 
   * The only trick is that each term x[i]*y[j-i] is actually a 64-bit quantity hence
   * must be broken down into two 32-bit components: x[i]*y[j-i] = (x[i]*y[j-i])_0 + 2^32 * (x[i]*y[j-i])_1.
   * This yields the corrected formula:
   * x_y = sum_{j=0..(M+N)} (sum_{i=0..j} (x[i]*y[j-i])_0 + sum_{i=0..j-1}(x[i]*y[j-i-1])_1) *2^(32*j)
   *
   * Oops.  I was wrong!  There is another trick which is that the sum_{i=0..j} (x[i]*y[j-i])_0
   * and sum_{i=0..j-1}(x[i]*y[j-i-1])_1) also may overflow 32-bits and that needs to be handled.
   *
   * All I need right now is multiplication of 12-byte integers by 4 byte integers to support OLE DECIMAL.
   * The code below are appropriate specializations.
   */
  static void decimal_mul(boost::uint32_t x, DECIMAL * result)
  {
    // Use stack without regard for space, assume the optimizer takes
    // out everything unecessary.
    boost::uint64_t tmp1 = boost::uint64_t(x) * boost::uint64_t(result->Lo32);
    boost::uint64_t tmp2 = boost::uint64_t(x) * boost::uint64_t(result->Mid32);
    boost::uint64_t tmp3 = boost::uint64_t(x) * boost::uint64_t(result->Hi32);
    if (tmp3 & 0xffffffff00000000)
      throw std::runtime_error("Decimal overflow");
    boost::uint64_t tmp5 = 
      ((tmp1 & 0xffffffff00000000)>>32) + 
      (tmp2 & 0x00000000ffffffff);
    boost::uint64_t tmp6 = 
      ((tmp2 & 0xffffffff00000000)>>32) + 
      (tmp3 & 0x00000000ffffffff) + 
      ((tmp5 & 0xffffffff00000000)>>32);

    if (tmp6 & 0xffffffff00000000)
      throw std::runtime_error("Decimal overflow");

    result->Lo32 = boost::uint32_t(tmp1 & 0x00000000ffffffff);
    result->Mid32 = boost::uint32_t(tmp5 & 0x00000000ffffffff);
    result->Hi32 = boost::uint32_t(tmp6 & 0x00000000ffffffff);
  }
  static void decimal_add(boost::uint32_t x, DECIMAL * result)
  {
    // Use stack without regard for space, assume the optimizer takes
    // out everything unecessary.
    boost::uint64_t tmp = boost::uint64_t(x) + result->Lo32;
    result->Lo32 = boost::uint32_t(tmp & 0x00000000ffffffff);
    tmp = ((tmp & 0xffffffff00000000)>>32) + result->Mid32;
    result->Mid32 = boost::uint32_t(tmp & 0x00000000ffffffff);
    tmp = ((tmp & 0xffffffff00000000)>>32) + result->Hi32;
    if (tmp & 0xffffffff00000000)
      throw std::runtime_error("Decimal overflow");
    result->Hi32 = boost::uint32_t(tmp & 0x00000000ffffffff);
  }
public:
  UTF8_Base10_Decimal_DECIMAL_2()
  {
  }

  ~UTF8_Base10_Decimal_DECIMAL_2()
  {
  }

  void destroy()
  {
  }

  static void PostAccumulator(boost::uint8_t * outputBuffer, boost::int32_t p, boost::int32_t blockIt, boost::uint32_t accumulator)
  {
    static const boost::uint32_t powers [] = {1, 10, 100, 1000, 10000, 100000, 
                                              1000000, 10000000, 100000000, 1000000000};
    switch(blockIt)
    {
    case 0:
      ((DECIMAL *)outputBuffer)->Lo32 = accumulator;
      break;
    case 1:
      ((DECIMAL *)outputBuffer)->Lo64 = (((DECIMAL *)outputBuffer)->Lo64*powers[p])+accumulator;
      break;
    default:
    {
      // TODO: Add overflow checking.
//       DECIMAL tmp1;
//       memset(&tmp1, 0, sizeof(DECIMAL));
//       tmp1.Lo32 = powers[p];
//       DECIMAL tmp2;
//       memset(&tmp2, 0, sizeof(DECIMAL));
//       HRESULT hr = ::VarDecMul((DECIMAL *)outputBuffer, &tmp1, &tmp2);
//       if (FAILED(hr))
//         throw std::runtime_error("DECIMAL overflow");
//       tmp1.Lo32 = mAccumulator;
//       hr = ::VarDecAdd(&tmp1, &tmp2, (DECIMAL *)outputBuffer);
//       if (FAILED(hr))
//         throw std::runtime_error("DECIMAL overflow");
      decimal_mul(powers[p], (DECIMAL *) outputBuffer);
      decimal_add(accumulator, (DECIMAL *) outputBuffer); 
      break;
    }
    }
  }

  ParseDescriptor::Result Import(_InputBuffer& input, _OutputBuffer& output)
  {
    boost::uint8_t * outputBuffer;
    if (!output.open(sizeof(decimal_traits::value), outputBuffer))
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;

    // Buffer initialization
    memset((decimal_traits::pointer)outputBuffer, 0, sizeof(decimal_traits::value));

    // Parser state setup
    boost::uint16_t scaleFlag=0;
    boost::uint16_t scaleAccumulator=0;

    boost::uint8_t * inputBuffer;
    if (!input.open(1, inputBuffer))
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;

    // Start parsing....
    if (*((char *)inputBuffer) == '-' || *((char *)inputBuffer) == '+')
    {
      ((decimal_traits::pointer)outputBuffer)->sign = *((char *)inputBuffer) == '-' ? 0x80 : 0x00;
      input.consume(1);
      if (!input.open(1, inputBuffer))
      {
        return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
      }
    }

    // TODO: Modify to handle numbers of the form
    // (+-).NNNN

    if (*((char *)inputBuffer) < '0' || *((char *)inputBuffer) > '9')
    {
      return ParseDescriptor::PARSE_ERROR;
    }

    for(boost::int32_t blockIt=0; blockIt<4; blockIt++)
    {
      boost::uint32_t accumulator = 0;
      for(boost::int32_t digitIt=0; digitIt<9; )
      {
        // TODO: Is it worth unrolling this loop?

        // TODO: Is it worth converting these if statements
        // into a switch.
        if (*((char *)inputBuffer) >= '0' && *((char *)inputBuffer) <= '9')
        {
          accumulator = accumulator*10 + (boost::uint32_t) (*((char *)inputBuffer) - '0');
          scaleAccumulator += scaleFlag;
          input.consume(1);
          digitIt += 1;
          // TODO: Handle EOS terminated input
          input.open(1, inputBuffer);
        }
        else if (*((char *)inputBuffer) == '.')
        {
          scaleFlag = 1;
          input.consume(1);
          input.open(1, inputBuffer);
          // TODO: Handle EOS terminated input.  Is this valid?
          input.open(1, inputBuffer);
        }
        else
        {
          if (digitIt>0)
          {
            PostAccumulator(outputBuffer, digitIt, blockIt, accumulator);
          }
          ((DECIMAL *)outputBuffer)->scale += (BYTE) scaleAccumulator;
          output.consume(sizeof(decimal_traits::value));
          return ParseDescriptor::PARSE_OK;
        }
      }
      PostAccumulator(outputBuffer, digitIt, blockIt, accumulator);
    }
    // Overflow
    return ParseDescriptor::PARSE_ERROR;
  }
  ParseDescriptor::Result Export(_InputBuffer& input, _OutputBuffer& output)
  {
    static const char conversion [] = "0123456789";

    boost::uint8_t * inputBuffer;
    if (!input.open(sizeof(decimal_traits::value), inputBuffer))
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;

    // Handle the 64-bit case separately since it is much more efficient.
    decimal_traits::pointer value = (decimal_traits::pointer) inputBuffer;

    boost::uint8_t * outputBuffer;

    if (value->sign == 0x80)
    {
      if (!output.open(1, outputBuffer))
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      *((char *)outputBuffer) = '-';
      output.consume(1);
      value->sign = 0x00;
    }
    
    output.mark();
    typename _OutputBuffer::size_type to_open = 0;

    // First handle the case in which we have to do DECIMAL calcs
    while(value->Hi32 != 0)
    {
      throw std::runtime_error("Not yet implemented");
    }

    // Now we can just do integer arithmetic.
    do
    {
      if(output.open(1, outputBuffer))
      {
        *((char*)outputBuffer) = conversion[value->Lo64 % 10];
        output.consume(1);
        value->Lo64 /= 10;
        to_open += 1;
      }
      else
      {
        output.rewind();
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      }
    } while(value->Lo64 != 0);
    
    // Reverse the digits. 
    std::size_t scale_offset = 0;

    // Note that is entirely possible that we have
    // fewer than value->scale digits written.  If
    // so we'll need some extra 0s (which will become
    // leading zeros when we reverse.
    if (value->scale >= to_open)
    {
      typename _OutputBuffer::size_type zeros_to_add = value->scale+1-to_open;
      if(output.open(zeros_to_add, outputBuffer))
      {
        for(std::size_t i=0; i<zeros_to_add; i++)
        {
          ((char *)outputBuffer)[i] = '0';
        }
        output.consume(zeros_to_add);
        to_open = value->scale+1;
      }
      else
      {
        output.rewind();
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      }            
    }

    // Make room for the decimal point.
    if (value->scale != 0)
    {
      if(output.open(1, outputBuffer))
      {
        output.consume(1);
        scale_offset = 1;
        to_open += 1;
      }
      else
      {
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      }      
    }

    char * begin = (char *)outputBuffer - to_open + 1;
    char * last = (char *)outputBuffer - scale_offset;
    char * last_before_point = (char *)begin + value->scale;
    if (value->scale != 0)
    {
      // Write until we hit the location of the decimal point.
      // Note that we may hit either from the left (e.g. 9.23432) or the right (e.g. 9993.2).
      while(last >= last_before_point && begin < last_before_point)
      {
        char tmp = *begin;
        *begin++ = *last;
        last[1] = tmp;
        last -= 1;
      }
      if (last < last_before_point)
      {
        char tmp1 = *begin;
        last[1] = tmp1;
        *begin++ = '.';
      }
      else
      {
        last[1] = '.';
      }
    }
    // Reverse the remaining stuff to the right or left of the decimal point.
    while(begin < last)
    {
      char tmp = *begin;
      *begin++ = *last;
      *last-- = tmp;
    }

    // Commit the mark.
    output.commit();

    return ParseDescriptor::PARSE_OK;
  }
};

#endif
class ISO8601_DateTime
{
public:
  METRAFLOW_DECL ISO8601_DateTime();
  METRAFLOW_DECL void destroy();
  METRAFLOW_DECL ParseDescriptor::Result Import(const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
                                                boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed);
};

class UTF8_String_Literal_UTF8_Null_Terminated
{
private:
  char * mLiteralBegin;
  char * mLiteralEnd;
  char * mLiteralIt;

public:
  METRAFLOW_DECL UTF8_String_Literal_UTF8_Null_Terminated(const std::string& literal);
  METRAFLOW_DECL UTF8_String_Literal_UTF8_Null_Terminated(const UTF8_String_Literal_UTF8_Null_Terminated & );
  METRAFLOW_DECL ~UTF8_String_Literal_UTF8_Null_Terminated();
  METRAFLOW_DECL void destroy();
  METRAFLOW_DECL UTF8_String_Literal_UTF8_Null_Terminated& operator=(const UTF8_String_Literal_UTF8_Null_Terminated &);
  METRAFLOW_DECL ParseDescriptor::Result Import(const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
                                                boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed);
};

template <class _IntType>
class UTF8_Base10_Signed_Integer
{
private:
  enum State { STATE_START, STATE_FIRST_DIGIT, STATE_INPUT };
  State mState;
  boost::int32_t mSign;

public:
  UTF8_Base10_Signed_Integer()
    :
    mState(STATE_START),
    mSign (1)
  {
  }

  ~UTF8_Base10_Signed_Integer()
  {
  }

  void destroy()
  {
  }

  ParseDescriptor::Result Import(
    const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
    boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed)
  {
    switch(mState)
    {
    case STATE_START:
      if (outputAvailable < sizeof(_IntType))
      {
        inputConsumed = inputAvailable;
        outputConsumed = sizeof(_IntType);
        return ParseDescriptor::PARSE_BUFFER_OPEN;
      }
      *((_IntType *)outputBuffer) = 0;

      if (*inputBuffer == '-' || *inputBuffer == '+')
      {
        mSign = *inputBuffer == '-' ? -1 : 1;
        inputBuffer += 1;
        inputAvailable -= 1;
        inputConsumed = 1;
        if (inputAvailable == 0)
        {
          mState = STATE_FIRST_DIGIT;
          outputConsumed = 0;
          return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
        case STATE_FIRST_DIGIT:
          inputConsumed = 0;
        }
      }
      else
      {
        mSign = 1;
        inputConsumed = 0;
      }

      ASSERT(inputAvailable > 0);

      if (*inputBuffer < '0' || *inputBuffer > '9')
      {
        outputConsumed = 0;
        mState = STATE_START;
        return ParseDescriptor::PARSE_ERROR;
      }

      do
      {
        {
          const char * inputBufferIt = (const char *)inputBuffer;
          const char * inputBufferEnd = (const char *)(inputBuffer + inputAvailable);
          _IntType * outputValue = (_IntType *)outputBuffer;
          while(inputBufferIt != inputBufferEnd)
          {
            if (*inputBufferIt >= '0' && *inputBufferIt <= '9')
              *outputValue = *outputValue*10 + (_IntType) (*inputBufferIt - '0');
            else
              break;

            inputBufferIt += 1;
          }

          inputConsumed += (inputBufferIt - (const char *)inputBuffer);

          if (inputBufferIt != inputBufferEnd)
          {
            outputConsumed = sizeof(_IntType);
            // Correct sign.
            *outputValue *= mSign;
            // Reset state
            mState = STATE_START;
            return ParseDescriptor::PARSE_OK;
          }
          else
          {
            mState = STATE_INPUT;
            outputConsumed = 0;
            return ParseDescriptor::PARSE_SOURCE_EXHAUSTED; 
          }
        }
      case STATE_INPUT:
        inputConsumed = outputConsumed = 0;
      } while(true);
    }

    return ParseDescriptor::PARSE_ERROR;
  }
};

typedef UTF8_Base10_Signed_Integer<boost::int32_t> UTF8_Base10_Signed_Integer_Int32;
typedef UTF8_Base10_Signed_Integer<boost::int64_t> UTF8_Base10_Signed_Integer_Int64;

#ifdef WIN32
/**
 * Basic idea is to try to maximize the amount of 32-bit arithmetic
 * being done.
 * To support this we leverage the fact that 9 decimal digits will
 * always fit into a boost::uint32_t.  So we import 9 digits at a time
 * into a boost::uint32_t and then we multiply by the appropriate
 * decimal factor (10^(9*N) for N=0..4) to convert into DECIMAL.
 */
class UTF8_Base10_Decimal_DECIMAL
{
private:
  enum State { STATE_START, STATE_FIRST_DIGIT, STATE_INPUT, STATE_INPUT_DOT };
  State mState;
  boost::uint32_t mAccumulator;
  boost::int32_t mDigitIt;
  boost::int32_t mBlockIt;
  boost::uint16_t mScaleFlag;
  boost::uint16_t mScaleAccumulator;

  /**
   * We use 64-bit multiplication to implement multiprecision multiplication as follows.
   * Treat a positive multiprecision number as a vector of 32 bit numbers:
   * boost::uint32_t x[M+1];  (x = x[0] + 2^32*x[1] + ... + 2^(32*M)*x[M])
   * boost::uint32_t y[N+1];  (y = y[0] + 2^32*y[1] + ... + 2^(32*N)*y[N])
   * boost::uint32_t x_y[M+N+1]; (x_y = sum_{j=0..(M+N)} (sum_{i=0..j} x[i]*y[j-i])*2^(32*j)
   * 
   * The only trick is that each term x[i]*y[j-i] is actually a 64-bit quantity hence
   * must be broken down into two 32-bit components: x[i]*y[j-i] = (x[i]*y[j-i])_0 + 2^32 * (x[i]*y[j-i])_1.
   * This yields the corrected formula:
   * x_y = sum_{j=0..(M+N)} (sum_{i=0..j} (x[i]*y[j-i])_0 + sum_{i=0..j-1}(x[i]*y[j-i-1])_1) *2^(32*j)
   *
   * Oops.  I was wrong!  There is another trick which is that the sum_{i=0..j} (x[i]*y[j-i])_0
   * and sum_{i=0..j-1}(x[i]*y[j-i-1])_1) also may overflow 32-bits and that needs to be handled.
   *
   * All I need right now is multiplication of 12-byte integers by 4 byte integers to support OLE DECIMAL.
   * The code below are appropriate specializations.
   */
  static void decimal_mul(boost::uint32_t x, DECIMAL * result)
  {
    // Use stack without regard for space, assume the optimizer takes
    // out everything unecessary.
    boost::uint64_t tmp1 = boost::uint64_t(x) * boost::uint64_t(result->Lo32);
    boost::uint64_t tmp2 = boost::uint64_t(x) * boost::uint64_t(result->Mid32);
    boost::uint64_t tmp3 = boost::uint64_t(x) * boost::uint64_t(result->Hi32);
    if (tmp3 & 0xffffffff00000000)
      throw std::runtime_error("Decimal overflow");
    boost::uint64_t tmp5 = 
      ((tmp1 & 0xffffffff00000000)>>32) + 
      (tmp2 & 0x00000000ffffffff);
    boost::uint64_t tmp6 = 
      ((tmp2 & 0xffffffff00000000)>>32) + 
      (tmp3 & 0x00000000ffffffff) + 
      ((tmp5 & 0xffffffff00000000)>>32);

    if (tmp6 & 0xffffffff00000000)
      throw std::runtime_error("Decimal overflow");

    result->Lo32 = boost::uint32_t(tmp1 & 0x00000000ffffffff);
    result->Mid32 = boost::uint32_t(tmp5 & 0x00000000ffffffff);
    result->Hi32 = boost::uint32_t(tmp6 & 0x00000000ffffffff);
  }
  static void decimal_add(boost::uint32_t x, DECIMAL * result)
  {
    // Use stack without regard for space, assume the optimizer takes
    // out everything unecessary.
    boost::uint64_t tmp = boost::uint64_t(x) + result->Lo32;
    result->Lo32 = boost::uint32_t(tmp & 0x00000000ffffffff);
    tmp = ((tmp & 0xffffffff00000000)>>32) + result->Mid32;
    result->Mid32 = boost::uint32_t(tmp & 0x00000000ffffffff);
    tmp = ((tmp & 0xffffffff00000000)>>32) + result->Hi32;
    if (tmp & 0xffffffff00000000)
      throw std::runtime_error("Decimal overflow");
    result->Hi32 = boost::uint32_t(tmp & 0x00000000ffffffff);
  }
public:
  UTF8_Base10_Decimal_DECIMAL()
    :
    mState(STATE_START),
    mAccumulator(0),
    mDigitIt(0),
    mBlockIt(0),
    mScaleFlag(0),
    mScaleAccumulator(0)
  {
  }

  ~UTF8_Base10_Decimal_DECIMAL()
  {
  }

  void destroy()
  {
  }

  void PostAccumulator(boost::uint8_t * outputBuffer, boost::int32_t p)
  {
    static const boost::uint32_t powers [] = {1, 10, 100, 1000, 10000, 100000, 
                                              1000000, 10000000, 100000000, 1000000000};
    switch(mBlockIt)
    {
    case 0:
      ((DECIMAL *)outputBuffer)->Lo32 = mAccumulator;
      break;
    case 1:
      ((DECIMAL *)outputBuffer)->Lo64 = (((DECIMAL *)outputBuffer)->Lo64*powers[p])+mAccumulator;
      break;
    default:
    {
      // TODO: Add overflow checking.
//       DECIMAL tmp1;
//       memset(&tmp1, 0, sizeof(DECIMAL));
//       tmp1.Lo32 = powers[p];
//       DECIMAL tmp2;
//       memset(&tmp2, 0, sizeof(DECIMAL));
//       HRESULT hr = ::VarDecMul((DECIMAL *)outputBuffer, &tmp1, &tmp2);
//       if (FAILED(hr))
//         throw std::runtime_error("DECIMAL overflow");
//       tmp1.Lo32 = mAccumulator;
//       hr = ::VarDecAdd(&tmp1, &tmp2, (DECIMAL *)outputBuffer);
//       if (FAILED(hr))
//         throw std::runtime_error("DECIMAL overflow");
      decimal_mul(powers[p], (DECIMAL *) outputBuffer);
      decimal_add(mAccumulator, (DECIMAL *) outputBuffer); 
      break;
    }
    }
  }

  ParseDescriptor::Result Import(
    const boost::uint8_t * inputBuffer, const boost::uint8_t * inputBufferEnd, std::size_t & inputConsumed,
    boost::uint8_t * outputBuffer, boost::uint8_t * outputBufferEnd, std::size_t & outputConsumed)
  {
    switch(mState)
    {
    case STATE_START:
      if ((outputBufferEnd-outputBuffer) < sizeof(decimal_traits::value))
      {
        inputConsumed = (inputBufferEnd-inputBuffer);
        outputConsumed = sizeof(decimal_traits::value);
        return ParseDescriptor::PARSE_BUFFER_OPEN;
      }
      // Parser state setup
      mScaleFlag = 0;
      mScaleAccumulator = 0;
      // Buffer initialization
      memset((decimal_traits::pointer)outputBuffer, 0, sizeof(decimal_traits::value));
      // Start parsing....
      if (*inputBuffer == '-' || *inputBuffer == '+')
      {
        ((decimal_traits::pointer)outputBuffer)->sign = *inputBuffer == '-' ? 0x80 : 0x00;
        inputBuffer += 1;
        inputConsumed = 1;
        if (inputBuffer == inputBufferEnd)
        {
          mState = STATE_FIRST_DIGIT;
          outputConsumed = 0;
          return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
        case STATE_FIRST_DIGIT:
          inputConsumed = 0;
        }
      }
      else
      {
        ((decimal_traits::pointer)outputBuffer)->sign = 0;
        inputConsumed = 0;
      }

      // TODO: Modify to handle numbers of the form
      // (+-).NNNN
      ASSERT(inputBufferEnd > inputBuffer);

      if (*inputBuffer < '0' || *inputBuffer > '9')
      {
        outputConsumed = 0;
        mState = STATE_START;
        return ParseDescriptor::PARSE_ERROR;
      }

      for(mBlockIt=0; mBlockIt<4; mBlockIt++)
      {
        mAccumulator = 0;
        for(mDigitIt=0; mDigitIt<9; )
        {
          // TODO: Is it worth unrolling this loop?

          // TODO: Is it worth converting these if statements
          // into a switch.
          if (*inputBuffer >= '0' && *inputBuffer <= '9')
          {
            mAccumulator = mAccumulator*10 + (boost::uint32_t) (*inputBuffer - '0');
            mScaleAccumulator += mScaleFlag;
            inputBuffer += 1;
            inputConsumed += 1;
            mDigitIt += 1;
            if(inputBuffer == inputBufferEnd)
            {
              mState = STATE_INPUT;
              outputConsumed = 0;
              return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
            case STATE_INPUT:
              inputConsumed = 0;
            }
          }
          else if (*inputBuffer == '.')
          {
            inputBuffer += 1;
            inputConsumed += 1;
            mScaleFlag = 1;
            if(inputBuffer == inputBufferEnd)
            {
              mState = STATE_INPUT_DOT;
              outputConsumed = 0;
              return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
            case STATE_INPUT_DOT:
              inputConsumed = 0;
            }
          }
          else
          {
            if (mDigitIt>0)
            {
              PostAccumulator(outputBuffer, mDigitIt);
            }
            ((DECIMAL *)outputBuffer)->scale += (BYTE) mScaleAccumulator;
            outputConsumed = sizeof(decimal_traits::value);
            mState = STATE_START;
            return ParseDescriptor::PARSE_OK;
          }
        }
        PostAccumulator(outputBuffer, mDigitIt);
      }
    }
    return ParseDescriptor::PARSE_ERROR;
  }

  ParseDescriptor::Result Import(
    const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
    boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed)
  {
    return Import(inputBuffer, inputBuffer+inputAvailable, inputConsumed,
                  outputBuffer, outputBuffer+outputAvailable, outputConsumed);
  }
};

#endif
/**
 * This class represents reading UTF8 external data into a UTF16 data buffer.
 */

class UTF8_FixedLength_UTF16_Null_Terminated
{
private:
  boost::int32_t mLength;
public:
  METRAFLOW_DECL UTF8_FixedLength_UTF16_Null_Terminated(boost::int32_t length);
  METRAFLOW_DECL void destroy();
  METRAFLOW_DECL ParseDescriptor::Result Import(const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
                                                boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed);
};

class UTF8_Terminated_UTF16_Null_Terminated
{
private:
  const static boost::uint8_t IMPORTING=0;
  const static boost::uint8_t TERMINATING=1;
  // Valid UTF8 characters have no more that 4 characters.
  char mTerminator[4];
  boost::uint8_t mState;
  boost::uint8_t mUTF16TerminatorLength;
  boost::uint8_t mTerminatorLength;
  boost::uint8_t mTerminatorIt;
public:
  /*
   * A parser of UTF8 string terminated by the code point terminator.
   */
  METRAFLOW_DECL UTF8_Terminated_UTF16_Null_Terminated(const std::string& terminator);
  METRAFLOW_DECL void destroy();
  METRAFLOW_DECL ParseDescriptor::Result Import(const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
                                                boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed);
};

class UTF8_Terminated_UTF8_Null_Terminated
{
private:
  const static boost::uint16_t IMPORTING=0;
  const static boost::uint16_t TERMINATING=1;
  // Valid UTF8 characters have no more that 4 characters.
  char mTerminator[4];
  // Store 2 bytes for TerminatorLength even though we don't need them because this
  // makes an 8 byte structure.
  boost::uint16_t mTerminatorLength;
  boost::uint16_t mState;
public:
  /*
   * A parser of UTF8 string terminated by the code point terminator.
   */
  METRAFLOW_DECL UTF8_Terminated_UTF8_Null_Terminated(const std::string& terminator);
  METRAFLOW_DECL void destroy();
  METRAFLOW_DECL ParseDescriptor::Result Import(const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
                                                boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed);
};

/**
 * The following implements an importer that writes directly into a 
 * MetraFlow record field.
 */
template <class _Ty>
class Direct_Field_Importer
{
private:
  _Ty mImporter;
  FieldAddress mAddress;
  std::size_t mSize;

public:
  Direct_Field_Importer(const _Ty & importer, RunTimeDataAccessor& accessor)
    :
    mImporter(importer),
    mAddress(accessor),
    mSize(accessor.GetPhysicalFieldType()->GetMaxBytes())
  {
    ASSERT(accessor.GetPhysicalFieldType()->IsInline());
  }
  ~Direct_Field_Importer()
  {
  }
  void destroy()
  {
    mImporter.destroy();
  }
  ParseDescriptor::Result Import(
    const boost::uint8_t *& inputBuffer, const boost::uint8_t * inputBufferEnd, std::size_t & inputRequired,
    record_t recordBuffer)
  {
    std::size_t inputConsumed;
    std::size_t outputConsumed;
    ParseDescriptor::Result r = mImporter.Import(inputBuffer, inputBufferEnd-inputBuffer, inputConsumed,
                                                 (boost::uint8_t *) mAddress.GetDirectBuffer(recordBuffer), mSize, outputConsumed); 

    switch(r)
    {
    case ParseDescriptor::PARSE_OK:
      mAddress.ClearNull(recordBuffer);
      // Intential fall through
    case ParseDescriptor::PARSE_SOURCE_EXHAUSTED:
      inputBuffer += inputConsumed;
      return r;
    case ParseDescriptor::PARSE_BUFFER_OPEN:
      // This can only happen because of the source
      ASSERT(outputConsumed <= mSize && (inputConsumed+inputBuffer) > inputBufferEnd);
      inputRequired = inputConsumed;
      // Intentional fall through
    case ParseDescriptor::PARSE_ERROR:
      return r;
    default:
      ASSERT(false);
      throw std::runtime_error("Illegal case");
    }
  }
};

class Null_Indicator_Action_Type
{
private:
  FieldAddress mAddress;
public:
  Null_Indicator_Action_Type(const FieldAddress& address)
    :
    mAddress(address)
  {
  }
  void destroy()
  {
  }
  void Set(record_t recordBuffer, const boost::uint8_t *, std::ptrdiff_t)
  {
    mAddress.SetNull(recordBuffer);
  }
};

class Set_Value_Action_Type
{
private:
  RunTimeDataAccessor mAddress;
public:
  Set_Value_Action_Type(const RunTimeDataAccessor& address)
    :
    mAddress(address)
  {
  }
  void destroy()
  {
  }
  void Set(record_t recordBuffer, const boost::uint8_t * valueBuffer, std::ptrdiff_t)
  {
    mAddress.SetValue(recordBuffer, valueBuffer);
  }
};

class Nop_Action_Type
{
public:
  Nop_Action_Type(const FieldAddress& address)
  {
  }
  void destroy()
  {
  }
  void Set(record_t , const boost::uint8_t * , std::ptrdiff_t )
  {
  }
};

class Enum_Lookup_Action_Type
{
private:
  FieldAddress mAddress;
  PerfectEnumeratorHash * mHashTable;
public:
  METRAFLOW_DECL Enum_Lookup_Action_Type(const FieldAddress& address, const std::string& space, const std::string& enumerator);
  METRAFLOW_DECL void destroy();
  METRAFLOW_DECL void Set(record_t recordBuffer, const boost::uint8_t * valueBuffer, std::ptrdiff_t len);
};

/**
 * This guy imports into a temporary buffer and 
 * then invokes an action on the MetraFlow record.
 * Actions may be SetValue or SetNull.
 */
template <class _Ty, class _Action>
class Field_Action_Importer
{
private:
  _Ty mImporter;
  _Action mAddress;
  boost::uint8_t * mBuffer;
  boost::uint8_t * mBufferIt;
  boost::uint8_t * mBufferEnd;

  void DoubleBuffer()
  {
    boost::uint8_t * tmp = new boost::uint8_t [2*(mBufferEnd-mBuffer)];
    memcpy(tmp, mBuffer, mBufferIt-mBuffer);
    mBufferIt = tmp + (mBufferIt-mBuffer);
    mBufferEnd = tmp + 2*(mBufferEnd-mBuffer);
    delete [] mBuffer;
    mBuffer = tmp;
  }

public:
  Field_Action_Importer(const _Ty & importer, const _Action& accessor)
    :
    mImporter(importer),
    mAddress(accessor),
    mBuffer(NULL),
    mBufferIt(NULL),
    mBufferEnd(NULL)
  {
    mBuffer = new boost::uint8_t [32];
    mBufferIt = mBuffer;
    mBufferEnd = mBuffer + 32;
  }
  ~Field_Action_Importer()
  {
    delete [] mBuffer;
  }
  void destroy()
  {
    mImporter.destroy();
    mAddress.destroy();
    delete [] mBuffer;
    mBuffer = mBufferIt = mBufferEnd = NULL;
  }
  ParseDescriptor::Result Import(
    const boost::uint8_t *& inputBuffer, const boost::uint8_t * inputBufferEnd, std::size_t & inputRequired,
    record_t recordBuffer)
  {
    while(true)
    {
      std::size_t inputConsumed;
      std::size_t outputConsumed;
      ParseDescriptor::Result r = mImporter.Import(inputBuffer, inputBufferEnd-inputBuffer, inputConsumed,
                                                   mBufferIt, mBufferEnd - mBufferIt, outputConsumed); 
      
      switch (r)
      {
      case ParseDescriptor::PARSE_OK:
        // Advance input and output buffer to account for consumption.
        inputBuffer += inputConsumed;
        mBufferIt += outputConsumed;
        // Reset output buffer state and set value.
        mAddress.Set(recordBuffer, mBuffer, mBufferIt-mBuffer);
        mBufferIt = mBuffer;
        return r;
      case ParseDescriptor::PARSE_SOURCE_EXHAUSTED:
        // Account for input and output used, pass problem onto caller that owns the source
        // buffer.
        inputBuffer += inputConsumed;
        mBufferIt += outputConsumed;
        return r;
      case ParseDescriptor::PARSE_TARGET_EXHAUSTED:
      {
        // Account for input used, double buffer, copy contents of current buffer, increment buffer iterator,
        // try again.
        inputBuffer += inputConsumed;
        mBufferIt += outputConsumed;
        DoubleBuffer();
        break;
      }
      case ParseDescriptor::PARSE_BUFFER_OPEN:
      {
        if (outputConsumed+mBufferIt > mBufferEnd)
        {
          DoubleBuffer();
        }
        if (inputConsumed+inputBuffer > inputBufferEnd)
        {
          // Translate to tell caller how much is really needed.
          inputRequired = inputConsumed;
          return r;
        }
        break;
      }
      case ParseDescriptor::PARSE_ERROR:
        return r;
      }
    }
    // Should never get here.
    ASSERT(false);
    return ParseDescriptor::PARSE_ERROR; 
  }
};


/**
 * This guy creates an importer for a nullable type with in-band
 * null values.  
 * Policy is that we try to match the value first, then
 * if there is a parse failure, we try to match the null
 * indicator.
 * Is this the right policy?  Isn't it entirely possible
 * that the null indicator can be a valid value (e.g. empty string).
 */
template <class _Ty1, class _Ty2> 
class Disjoint_Union_Field_Importer
{
private:
  _Ty1 mTy1;
  _Ty2 mTy2;
  const boost::uint8_t * mInputBuffer;
  bool mType1;
public:
  Disjoint_Union_Field_Importer(const _Ty1 & ty1, const _Ty2 & ty2)
    :
    mTy1(ty1),
    mTy2(ty2),
    mInputBuffer(0),
    mType1(true)
  {
  }
  void destroy()
  {
    mTy1.destroy();
    mTy2.destroy();
  }
  ParseDescriptor::Result Import(
    const boost::uint8_t *& inputBuffer, const boost::uint8_t * inputBufferEnd, std::size_t & inputRequired,
    record_t recordBuffer)
  {
    if (mType1)
    {
      // We can't let Ty1 consume characters until we know it has succeeded.  If it fails
      // we need to back up and give the alternative a chance to parse.
      // Thus we must convert all exhaustion return codes into appropriate buffer open codes,
      // Then we need to track offsets into the buffers to account for the fact that Ty1 thinks
      // it has consumed tokens.

      std::size_t tmpInputRequired=0;
      if (NULL == mInputBuffer) mInputBuffer=inputBuffer;
      ParseDescriptor::Result r = mTy1.Import(mInputBuffer, inputBufferEnd, tmpInputRequired,
                                              recordBuffer);
      switch(r)
      {
      case ParseDescriptor::PARSE_OK:
        // We've succeeded, so we consume all the tokens all at once
        // and restore state so we can parse again.
        inputBuffer = tmpInputBuffer;
        mInputBuffer = NULL;
        return ParseDescriptor::PARSE_OK;
      case ParseDescriptor::PARSE_SOURCE_EXHAUSTED:
        // Don't actually consume the tokens, just open the window.
        // TODO: Assume that opening 1 byte at a time won't be horrible (in general
        // buffer windows are extended by memory pages).
        inputRequired = (inputBufferEnd - inputBuffer) + 1;
        return ParseDescriptor::PARSE_BUFFER_OPEN;
      case ParseDescriptor::PARSE_BUFFER_OPEN:
        // Adjust buffer open request by the current position within the buffer.
        inputRequired = tmpInputRequired + (mInputBuffer - inputBuffer);
        return ParseDescriptor::PARSE_BUFFER_OPEN;
      case ParseDescriptor::PARSE_ERROR:
        // Failure, fall through to the second type.
        mType1 = false;
        mInputBuffer = NULL;
        break;
      case ParseDescriptor::PARSE_TARGET_EXHAUSTED:
      default:
        throw std::runtime_error("Invalid case");
      }
    }

    if (!mType1)
    {
      // Just run the second importer until success or failure
      ParseDescriptor::Result r = mTy2.Import(inputBuffer, inputBufferEnd, inputRequired,
                                              recordBuffer);
      mType1 = (r == ParseDescriptor::PARSE_ERROR || r == ParseDescriptor::PARSE_OK);
      return r;
    }
  }
};


template <class _Ty1, class _Ty2> 
class Disjoint_Union_Type_Importer
{
private:
  _Ty1 mTy1;
  _Ty2 mTy2;
  std::size_t mInputConsumed;
  std::size_t mOutputConsumed;
  bool mType1;
public:
  Disjoint_Union_Type_Importer(const _Ty1 & ty1, const _Ty2 & ty2)
    :
    mTy1(ty1),
    mTy2(ty2),
    mInputConsumed(0),
    mOutputConsumed(0),
    mType1(true)
  {
  }
  ParseDescriptor::Result Import(
    const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
    boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed)
  {
    if (mType1)
    {
      // We can't let Ty1 consume characters until we know it has succeeded.  If it fails
      // we need to give the alternative a chance to parse.
      // Thus we must convert all exhaustion return codes into appropriate buffer open codes,
      // Then we need to track offsets into the buffers to account for the fact that Ty1 thinks
      // it has consumed tokens.

      std::size_t tmpInputConsumed=0;
      std::size_t tmpOutputConsumed=0;
      ParseDescriptor::Result r = mTy1.Import(inputBuffer+mInputConsumed, inputAvailable-mInputConsumed, tmpInputConsumed,
                                              outputBuffer+mOutputConsumed, outputAvailable-mOutputConsumed, tmpOutputConsumed);
      switch(r)
      {
      case ParseDescriptor::PARSE_OK:
        // We've succeeded, so we consume all the tokens all at once.
        inputConsumed = mInputConsumed + tmpInputConsumed;
        outputConsumed = mOutputConsumed + tmpOutputConsumed;

        mInputConsumed = 0;
        mOutputConsumed = 0;
        return ParseDescriptor::PARSE_OK;
      case ParseDescriptor::PARSE_SOURCE_EXHAUSTED:
      case ParseDescriptor::PARSE_TARGET_EXHAUSTED:
        mInputConsumed += tmpInputConsumed;
        mOutputConsumed += tmpOutputConsumed;
        // Don't actually consume the tokens, just open the window.
        inputConsumed = mInputConsumed;
        outputConsumed = mOutputConsumed;
        return ParseDescriptor::PARSE_BUFFER_OPEN;
      case ParseDescriptor::PARSE_BUFFER_OPEN:
        inputConsumed = mInputConsumed + tmpInputConsumed;
        outputConsumed = mOutputConsumed + tmpOutputConsumed;
        return ParseDescriptor::PARSE_BUFFER_OPEN;
      case ParseDescriptor::PARSE_ERROR:
        // Failure, fall through to the second type.
        mType1 = false;
        break;
      }
    }

    if (!mType1)
    {
      mInputConsumed = 0;
      mOutputConsumed = 0;

      // Just run the second importer until success or failure
      ParseDescriptor::Result r = mTy2.Import(inputBuffer, inputAvailable, inputConsumed,
                                              outputBuffer, outputAvailable, outputConsumed);
      mType1 = (r == ParseDescriptor::PARSE_ERROR || r == ParseDescriptor::PARSE_OK);
      return r;
    }
  }
};

/**
 * "Combinator" for making a nullable importer for delimited fields.
 */
template <class _Ty>
class UTF8_Nullable_Terminated_Field_Importer_2
{
public:
  typedef typename _Ty::input_buffer input_buffer;
  typedef UTF8_String_Literal_Terminated_UTF8_Null_Terminated_2<input_buffer, DynamicArrayParseBuffer> null_marker_importer;
  typedef _Ty field_importer;
private:
  // Null indicator is tested first.
  Field_Action_Importer_2<UTF8_String_Literal_Terminated_UTF8_Null_Terminated_2, input_buffer, Null_Indicator_Action_Type> mNullImport;
  // The field importer for non-nullable.
  _Ty mImporter;
public:
  UTF8_Nullable_Terminated_Field_Importer_2(const std::string& nullMarker, 
                                            const std::string& terminator, 
                                            const FieldAddress& address,
                                            const _Ty& importer)
    :
    mNullImport(null_marker_importer(nullMarker, terminator), Null_Indicator_Action_Type(address)),
    mImporter(importer)
  {
  }
  ~UTF8_Nullable_Terminated_Field_Importer_2()
  {
    destroy();
  }

  void destroy()
  {
    mNullImport.destroy();
    mImporter.destroy();
  }

  ParseDescriptor::Result Import(input_buffer& input, record_t recordBuffer)
  {
    input.mark();
    ParseDescriptor::Result r = mNullImport.Import(input, recordBuffer);
    if (r == ParseDescriptor::PARSE_OK)
    {
      input.commit();
      return r;
    }
    else
    {
      input.rewind();
      return mImporter.Import(input, recordBuffer);
    }
  }  
};

/**
 * "Combinator" for making a nullable exporter for delimited fields.
 */
template <class _Ty>
class UTF8_Nullable_Field_Exporter_2
{
public:
  typedef typename _Ty::output_buffer output_buffer;
  typedef UTF8_String_Literal_UTF8_Null_Terminated_2<FixedArrayParseBuffer, output_buffer> null_marker_exporter;
  typedef _Ty field_exporter;
private:
  // The field exporter for nullable.
  null_marker_exporter mNullExport;
  // The field importer for non-nullable.
  _Ty mExporter;
  // For checking if nullable
  FieldAddress mFieldAddress;
public:
  UTF8_Nullable_Field_Exporter_2(const std::string& nullMarker, 
                                 const std::string& terminator, 
                                 const FieldAddress& address,
                                 const _Ty& exporter)
    :
    mNullExport(nullMarker),
    mExporter(exporter),
    mFieldAddress(address)
  {
  }
  ~UTF8_Nullable_Field_Exporter_2()
  {
    destroy();
  }

  void destroy()
  {
    mNullExport.destroy();
    mExporter.destroy();
  }

  ParseDescriptor::Result Export(record_t recordBuffer, output_buffer& output)
  {
    if (mFieldAddress.GetNull(recordBuffer))
    {
      FixedArrayParseBuffer dummy(NULL, NULL);
      return mNullExport.Export(dummy, output);
    }
    else
    {
      return mExporter.Export(recordBuffer, output);
    }
  }  
};

/**
 * Thrown by exporters when a null value is found without
 * null value handling in the exporter.  Due to the compactness
 * of field exporter classes, they don't have enough context to create a nice
 * error message when this occurs so it is up to the calling context
 * to catch this and create a more user friendly notification.
 */
class NullFieldExportException : public std::runtime_error
{
private:
  FieldAddress mAddress;
public:
  NullFieldExportException(const FieldAddress& address)
    :
    std::runtime_error("Null value in export"),
    mAddress(address)
  {
  }

  const FieldAddress& GetFieldAddress() const
  {
    return mAddress;
  }
};

/** 
 * "Combinator" for making a non-nullable exporter for delimited fields.
 */
template <class _Ty>
class UTF8_Non_Nullable_Field_Exporter_2 : public _Ty
{
public:
  typedef typename _Ty::output_buffer output_buffer;
  typedef _Ty field_exporter;
public:
  UTF8_Non_Nullable_Field_Exporter_2(const _Ty& exporter)
    :
    _Ty(exporter)
  {
  }
  ~UTF8_Non_Nullable_Field_Exporter_2()
  {
    destroy();
  }

  void destroy()
  {
    _Ty::destroy();
  }

  ParseDescriptor::Result Export(record_t recordBuffer, output_buffer& output)
  {
    if (!mAddress.GetNull(recordBuffer))
    {
      return _Ty::Export(recordBuffer, output);
    }
    else
    {
      throw NullFieldExportException(mAddress);
    }
  }  
};

class Import_Format_Error_Sink
{
public:
  virtual ~Import_Format_Error_Sink() {}
  virtual void ThrowError(const std::wstring& err) =0;
};

/**
 * We can't add template parameters to an ANTLR parser, so we
 * use inheritance to allow the ANTLR tree generator to build our
 * importer for different input buffer types.
 */
class Import_Function_Builder 
{
public:
  virtual ~Import_Function_Builder() {}
  virtual void add_base_type(const std::wstring& fieldName,
                             const std::string& baseType, 
                             bool isRequired,
                             const std::string& nullValue,
                             const std::string& delimiter,
                             const std::string& enum_space,
                             const std::string& enum_type,
                             const std::string& true_value,
                             const std::string& false_value) = 0;
};

class Record_Metadata_Builder 
{
public:
  virtual ~Record_Metadata_Builder() {}
  virtual void add_field(const std::wstring& fieldName, const std::string& baseType, bool isRequired) =0;
};

/**
 * This is primarily for testing.  We use pimpl idiom to hide implementation
 * since the implementation is a template that has a bunch of ANTLR stuff in it.
 */
template <class _InputBuffer> class UTF8_Import_Function_Builder_2;
template <class _OutputBuffer> class UTF8_Export_Function_Builder_2;

class UTF8StringBufferImporter : Import_Format_Error_Sink
{
private:
  UTF8_Import_Function_Builder_2<PagedParseBuffer<PagedBuffer> > * mImpl;
  
public:
  METRAFLOW_DECL UTF8StringBufferImporter(const std::wstring& importSpec);
  METRAFLOW_DECL ~UTF8StringBufferImporter();
  METRAFLOW_DECL record_t Import(PagedParseBuffer<PagedBuffer> & input, std::string& outErrMessage);
  METRAFLOW_DECL const RecordMetadata& GetMetadata() const;
  METRAFLOW_DECL void ThrowError(const std::wstring& err);
};

class UTF8StringBufferExporter : Import_Format_Error_Sink
{
private:
  UTF8_Export_Function_Builder_2<DynamicArrayParseBuffer > * mImpl;
  
public:
  METRAFLOW_DECL UTF8StringBufferExporter(const std::wstring& importSpec);
  METRAFLOW_DECL ~UTF8StringBufferExporter();
  METRAFLOW_DECL void Export(record_t recordBuffer, DynamicArrayParseBuffer & output);
  METRAFLOW_DECL const RecordMetadata& GetMetadata() const;
  METRAFLOW_DECL void ThrowError(const std::wstring& err);
};

#endif
