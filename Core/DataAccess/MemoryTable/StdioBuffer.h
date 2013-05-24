#ifndef __STDIOBUFFER_H__
#define __STDIOBUFFER_H__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
# pragma once
#endif

#include <string>
#include <cstdio>
#include <boost/cstdint.hpp>

/** 
 * Small abstraction around stdio stuff to make it suitable as a template
 * parameter.
 */
class StdioFile
{
private:
  FILE* mFile;
  bool mEOF;
public:
  METRAFLOW_DECL StdioFile(const std::wstring& filename, bool forWriting = false);
  METRAFLOW_DECL ~StdioFile();
  METRAFLOW_DECL void read(std::size_t& sz, boost::uint8_t * buffer);
  METRAFLOW_DECL void write(const boost::uint8_t * buffer, std::size_t sz);
  METRAFLOW_DECL std::size_t granularity() const;
  METRAFLOW_DECL bool is_eof() const;
};

/** 
 * Small abstraction around Win32 file API stuff to make it suitable as a template
 * parameter.
 */
class Win32File
{
private:
  HANDLE mFile;
  bool mEOF;
public:
  METRAFLOW_DECL Win32File(const std::wstring& filename, bool forWriting = false);
  METRAFLOW_DECL ~Win32File();
  METRAFLOW_DECL void read(std::size_t& sz, boost::uint8_t * buffer);
  METRAFLOW_DECL void write(const boost::uint8_t * buffer, std::size_t sz);
  METRAFLOW_DECL std::size_t granularity() const;
  METRAFLOW_DECL bool is_eof() const;
};

/**
 * This class implements the read buffer discipline on top of stdio.
 * The primary application is sitting on top of a memory mapped file.
 */
template <class _Buffer>
class StdioReadBuffer
{
public:
  typedef std::size_t size_type;
  typedef _Buffer file_type;
private:
  // Our window.
  boost::uint8_t * mBuffer;
  // The current position (mBufferIt <= mBufferEnd).
  boost::uint8_t * mBufferIt;
  // The end of valid data (mBufferEnd <= mBufferCapacity).
  boost::uint8_t * mBufferEnd;
  // The end of the allocated buffer.
  boost::uint8_t * mBufferCapacity;
  std::vector<boost::uint8_t *> mMarks;

  _Buffer& mFile;
  std::size_t mViewSize;

  void internal_open(std::size_t viewSize)
  {
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
    // Make sure that view size is at least the minimum
    if (viewSize < mViewSize) viewSize = mViewSize;

    std::ptrdiff_t bufferDelta = 0;

    // Do we need a new memory buffer to fit everything or can we
    // make do with the current one by reshuffling data?
    if (viewSize + std::size_t(mBufferEnd-low_water) > std::size_t(mBufferCapacity - mBuffer))
    {
      boost::uint8_t * newBuffer = new boost::uint8_t [viewSize + std::size_t(mBufferEnd-low_water)];
      bufferDelta = (newBuffer - low_water);
      if (mBufferEnd != low_water)
        memcpy(newBuffer, low_water, mBufferEnd - low_water);
      delete [] mBuffer;

      mBuffer = newBuffer;
      mBufferCapacity = mBuffer + viewSize + std::size_t(mBufferEnd-low_water);
      mBufferEnd += bufferDelta;
    }
    else
    {
      bufferDelta = mBuffer - low_water;
      memmove(mBuffer, low_water, mBufferEnd - low_water);
      mBufferEnd += bufferDelta;
    }

    mFile.read(viewSize, mBufferEnd);
    mBufferEnd += viewSize;

    // Adjust all remaining buffers and marks to account for the consumed amount
    // and rebasing of view pointers.
    mBufferIt += bufferDelta;
    for(std::vector<boost::uint8_t *>::iterator it = mMarks.begin();
        it != mMarks.end();
        ++it)
    {
      *it += bufferDelta;
    }
  }

public:
  StdioReadBuffer(_Buffer& b, std::size_t viewSize)
    :
    mBuffer(NULL),
    mBufferIt(NULL),
    mBufferEnd(NULL),
    mBufferCapacity(NULL),
    mFile(b),
    mViewSize(b.granularity()*((viewSize + b.granularity() - 1)/b.granularity()))
  {
    // Do the initial open.
    mBuffer = new boost::uint8_t [mViewSize];
    mBufferIt = mBufferEnd = mBuffer;
    mBufferCapacity = mBuffer + mViewSize;
    
    std::size_t requested = mViewSize;
    mFile.read(requested, mBuffer);
    mBufferEnd = mBuffer + requested;
  }
  ~StdioReadBuffer()
  {
    destroy();
  }
  void destroy()
  {
    if (mBuffer != NULL)
    {
      delete [] mBuffer;
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
    return mFile.is_eof();
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
    return size_type(mBufferCapacity - mBuffer);
  }
  size_type available() const
  {
    return size_type(mBufferEnd - mBufferIt);
  }
};


/**
 * This class implements the write buffer discipline on top of stdio.
 * The primary application is sitting on top of a memory mapped file.
 */
template <class _Buffer>
class StdioWriteBuffer
{
public:
  typedef std::size_t size_type;
  typedef _Buffer file_type;
private:
  // Our window.
  boost::uint8_t * mBuffer;
  // The current position (mBufferIt <= mBufferEnd).
  boost::uint8_t * mBufferIt;
  // The end of valid data (mBufferEnd <= mBufferCapacity).
  boost::uint8_t * mBufferEnd;
  // The end of the allocated buffer.
  boost::uint8_t * mBufferCapacity;
  std::vector<boost::uint8_t *> mMarks;

  _Buffer& mFile;
  std::size_t mViewSize;

  void internal_open(std::size_t viewSize)
  {
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

    // Write accumulated data up to mark.
    mFile.write(mBuffer, low_water - mBuffer);

    std::ptrdiff_t bufferDelta = 0;

    // Do we need a new memory buffer to fit everything or can we
    // make do with the current one by reshuffling data?
    if (viewSize + std::size_t(mBufferIt-low_water) > std::size_t(mBufferCapacity - mBuffer))
    {
      std::size_t newSize = viewSize + std::size_t(mBufferIt-low_water);
      // Make sure we are least doubling the buffer
      if (newSize < 2*std::size_t(mBufferCapacity-mBuffer))
      {
        newSize = 2*std::size_t(mBufferCapacity-mBuffer);
      }
      boost::uint8_t * newBuffer = new boost::uint8_t [newSize];
      bufferDelta = (newBuffer - low_water);
      if (mBufferIt != low_water)
        memcpy(newBuffer, low_water, mBufferIt - low_water);
      delete [] mBuffer;

      mBuffer = newBuffer;
      mBufferCapacity = mBuffer + newSize;
      mBufferEnd = mBufferCapacity;
    }
    else
    {
      bufferDelta = mBuffer - low_water;
      memmove(mBuffer, low_water, mBufferIt - low_water);
    }

    // Adjust all remaining buffers and marks to account for the consumed amount
    // and rebasing of view pointers.
    mBufferIt += bufferDelta;
    for(std::vector<boost::uint8_t *>::iterator it = mMarks.begin();
        it != mMarks.end();
        ++it)
    {
      *it += bufferDelta;
    }
  }

public:
  StdioWriteBuffer(_Buffer& b, std::size_t viewSize)
    :
    mBuffer(NULL),
    mBufferIt(NULL),
    mBufferEnd(NULL),
    mBufferCapacity(NULL),
    mFile(b),
    mViewSize(b.granularity()*((viewSize + b.granularity() - 1)/b.granularity()))
  {
    // Do the initial open.
    mBuffer = new boost::uint8_t [mViewSize];
    mBufferIt = mBuffer;
    mBufferCapacity = mBuffer + mViewSize;    
    mBufferEnd = mBuffer + mViewSize;
  }
  ~StdioWriteBuffer()
  {
    destroy();
  }
  void destroy()
  {
    if (mBufferIt != mBuffer)
    {
      mFile.write(mBuffer, mBufferIt - mBuffer);
    }

    if (mBuffer != NULL)
    {
      delete [] mBuffer;
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
    return mFile.is_eof();
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
    return size_type(mBufferCapacity - mBuffer);
  }
  size_type available() const
  {
    return size_type(mBufferEnd - mBufferIt);
  }
};


#endif
