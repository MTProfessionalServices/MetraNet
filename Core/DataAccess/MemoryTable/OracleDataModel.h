#ifndef __ORACLEDATAMODEL_H__
#define __ORACLEDATAMODEL_H__

#include "MetraFlowConfig.h"
#include "RecordModel.h"

#include <vector>

#include <boost/cstdint.hpp>

#include <oci.h>

class RecordMetadata;

class OracleConnection;
class OracleResultSet;
class OraclePreparedStatement;

/**
 * This adapters the underlying OCI buffer format into accessors that
 * are MetraFlow compatible.
 * TODO: Not sure if this is really what I want to do?
 * For the moment I am leaving the interface as Oracle specific; maybe generic programming to the rescue?
 */
class OCIDataAccessor
{
private:
  ub4 mDataOffset;
  ub4 mIndicatorOffset;
  ub4 mLengthOffset;
public:
  OCIDataAccessor (ub4 dataOffset, ub4 indicatorOffset, ub4 lengthOffset)
    :
    mDataOffset(dataOffset),
    mIndicatorOffset(indicatorOffset),
    mLengthOffset(lengthOffset)
  {}
  

  ~OCIDataAccessor() 
  {}
  
  boost::uint8_t * GetData(boost::uint8_t * buffer) const
  {
    return (buffer + mDataOffset);
  }
  sb2 * GetIndicator(boost::uint8_t * buffer) const
  {
    return ((sb2 *) (buffer + mIndicatorOffset));
  }
  ub2 * GetLength(boost::uint8_t * buffer) const
  {
    return ((ub2 *) (buffer + mLengthOffset));
  }
  const boost::uint8_t * GetData(const boost::uint8_t * buffer) const
  {
    return (buffer + mDataOffset);
  }
  const sb2 * GetIndicator(const boost::uint8_t * buffer) const
  {
    return ((sb2 *) (buffer + mIndicatorOffset));
  }
  const ub2 * GetLength(const boost::uint8_t * buffer) const
  {
    return ((ub2 *) (buffer + mLengthOffset));
  }
};

class OCIParamVisitor
{
public:
  virtual ~OCIParamVisitor() 
  {}
  virtual void Visit(ub4 colCount) =0;
  
  /**
   * colPos - 1-based position of the column in the parameter set.
   * colName - non-zero terminated string holding the column name.
   */
  virtual void Visit(ub4 colPos,
                     text * colName, ub4 colNameLen,
                     ub2 dtype,
                     ub2 colWidth,
                     ub4 charSemantics,
                     sb2 prec,
                     sb1 scale,
                     ub1 nullable,
                     ub2 charset_id,
                     ub1 charset_form
    )=0;
};

class OCIRecordMetadataVisitor : public OCIParamVisitor
{
private:
  RecordMetadata & mMetadata;
public:
  OCIRecordMetadataVisitor(RecordMetadata& metadata);

  ~OCIRecordMetadataVisitor();

  void Visit(ub4 colCount);
  
  void Visit(ub4 colPos,
             text * colName, ub4 colNameLen,
             ub2 dtype,
             ub2 colWidth,
             ub4 charSemantics,
             sb2 prec,
             sb1 scale,
             ub1 nullable,
             ub2 charset_id,
             ub1 charset_form);
};

/**
 * Describes an OCI row buffer.  The assumption is that the row contains
 * all data in a contiguous chunk up front, followed by an indicator array,
 * a length array and lastly an error code array.
 * This is not optimized for non-nullable columns or fixed length stuff.
 * This is the product of the buffer visitor.
 */
class OCIRowBuffer
{
private:
  ub4 mSize;
  ub4 mIndicatorArrayOffset;
  ub4 mLengthArrayOffset;
  ub4 mErrorCodeArrayOffset;
  std::vector<ub4> mDataOffsets;
  std::vector<ub4> mDataLengths;
  std::vector<ub2> mExternalTypes;
  std::vector<ub2> mCharsetIds;
public:
  OCIRowBuffer()
    :
    mSize(0),
    mIndicatorArrayOffset(0),
    mLengthArrayOffset(0),
    mErrorCodeArrayOffset(0)
  {}

  OCIRowBuffer(const std::vector<ub4>& dataOffsets,
               const std::vector<ub4>& dataLengths,
               const std::vector<ub2>& externalTypes,
               const std::vector<ub2>& charsetIds)
    :
    mSize((((((((dataOffsets.back()+dataLengths.back())+1)>>1)<<1) + dataOffsets.size()*sizeof(sb2) + dataOffsets.size()*sizeof(ub2) + dataOffsets.size()*sizeof(ub2))+7)>>3)<<3),
    mIndicatorArrayOffset((((dataOffsets.back()+dataLengths.back()+1)>>1)<<1)),
    mLengthArrayOffset(((((dataOffsets.back()+dataLengths.back())+1)>>1)<<1) + dataOffsets.size()*sizeof(sb2)),
    mErrorCodeArrayOffset(((((dataOffsets.back()+dataLengths.back())+1)>>1)<<1) + dataOffsets.size()*sizeof(sb2) + dataOffsets.size()*sizeof(ub2)),
    mDataOffsets(dataOffsets),
    mDataLengths(dataLengths),
    mExternalTypes(externalTypes),
    mCharsetIds(charsetIds)
  {}
  
  ub4 GetSize() const 
  {
    return mSize;
  }
  ub4 GetColumns() const
  {
    return mDataOffsets.size();
  }
  ub2 GetExternalType(ub4 colPos) const 
  {
    return mExternalTypes[colPos-1];
  }
  ub2 GetCharsetId(ub4 colPos) const 
  {
    return mCharsetIds[colPos-1];
  }
  ub4 GetDataLength(ub4 colPos) const
  {
    return mDataLengths[colPos-1];
  }
  OCIDataAccessor GetDataAccessor(ub4 colPos) const
  {
    return OCIDataAccessor(mDataOffsets[colPos-1],
                           mIndicatorArrayOffset + sizeof(sb2)*(colPos-1),
                           mLengthArrayOffset + sizeof(ub2)*(colPos-1));
  }
  
  dvoid * GetData(boost::uint8_t * buffer, ub4 colPos) const
  {
    return (dvoid *) (buffer + mDataOffsets[colPos-1]);
  }
  dvoid * GetIndicator(boost::uint8_t * buffer, ub4 colPos) const
  {
    return (dvoid *) (buffer + mIndicatorArrayOffset + sizeof(sb2)*(colPos-1));
  }
  ub2 * GetLength(boost::uint8_t * buffer, ub4 colPos) const
  {
    return (ub2 *) (buffer + mLengthArrayOffset + sizeof(ub2)*(colPos-1));
  }
  ub2 * GetCode(boost::uint8_t * buffer, ub4 colPos) const
  {
    return (ub2 *) (buffer + mErrorCodeArrayOffset + sizeof(ub2)*(colPos-1));
  }
};


/**
 * OCIBufferVisitor - computes the row buffer size and offsets from OCI metadata.
 */
class OCIBufferVisitor : public OCIParamVisitor
{
private:
  std::vector<ub4> mDataOffsets;
  std::vector<ub4> mDataLengths;
  std::vector<ub2> mExternalTypes;
  std::vector<ub2> mCharsetIds;
  ub4 mTotalSize;
  
public:
  OCIBufferVisitor()
    :
    mTotalSize(0)
  {}

  ~OCIBufferVisitor()
  {}

  void GetProduct(OCIRowBuffer & buffer)
  {
    buffer = OCIRowBuffer(mDataOffsets, mDataLengths, mExternalTypes, mCharsetIds);
  }
  
  void Visit(ub4 colCount)
  {
  }
  
  void Visit(ub4 colPos,
             text * colName, ub4 colNameLen,
             ub2 dtype,
             ub2 colWidth,
             ub4 charSemantics,
             sb2 prec,
             sb1 scale,
             ub1 nullable,
             ub2 charset_id,
             ub1 charset_form);
};

class OCIRowBindingBase
{
protected:
  boost::uint8_t * mData;
  ub4 mRows;
  OCIRowBuffer mBuffer;
  
public:
  OCIRowBindingBase(const OCIRowBuffer& buffer, ub4 rows)
    :
    mData(NULL),
    mRows(rows),
    mBuffer(buffer)
  {
    mData = new boost::uint8_t [buffer.GetSize()*rows];
    memset(mData, 0, buffer.GetSize()*rows);
  }

  virtual ~OCIRowBindingBase()
  {
    delete [] mData;
  }

  ub4 GetRows() const
  {
    return mRows;
  }

  dvoid * GetData(ub4 row, ub4 colPos)
  {
    return mBuffer.GetData(mData + mBuffer.GetSize()*(row-1), colPos);
  }
  
  ub2& GetLength(ub4 row, ub4 colPos)
  {
    return *mBuffer.GetLength(mData + mBuffer.GetSize()*(row-1), colPos);
  }
  
  sb2& GetIndicator(ub4 row, ub4 colPos)
  {
    return * (sb2 *) (mBuffer.GetIndicator(mData + mBuffer.GetSize()*(row-1), colPos));
  }

  ub2 GetCode(ub4 row, ub4 colPos)
  {
    return *mBuffer.GetCode(mData + mBuffer.GetSize()*(row-1), colPos);
  }
  
  void SetLength(ub4 row, ub4 colPos, ub2 length)
  {
    *mBuffer.GetLength(mData + mBuffer.GetSize()*(row-1), colPos) = length;
  }
  
  void SetIndicator(ub4 row, ub4 colPos, sb2 ind)
  {
    *((sb2 *) mBuffer.GetIndicator(mData + mBuffer.GetSize()*(row-1), colPos)) = ind;
  }

  const boost::uint8_t * GetDataBuffer() const
  {
    return mData;
  }

  boost::uint8_t * GetDataBuffer() 
  {
    return mData;
  }
};

class OCIRowBinding : public OCIRowBindingBase
{
private:
  std::vector<OCIBind *> mBindHandles;
  
public:
  
  OCIRowBinding(OCIStmt * stmt, OCIError * error, OCIRowBuffer& buffer, ub4 rows);
};

class OCIRowDefinition : public OCIRowBindingBase
{
private:
  std::vector<OCIDefine *> mDefineHandles;
  
public:
  
  OCIRowDefinition(OCIStmt * stmt, OCIError * error, OCIRowBuffer& buffer, ub4 rows);
};

/**
 * Some initial thoughts about how to use generic programming
 * to build up import/export functionality.  When the external data
 * model is determined at compile time (as are database interfaces)
 * we can get efficiencies by doing this.
 */

class OCIDataModel
{
public:
  typedef ub2 length_type;
  typedef sb2 indicator_type;

  static const indicator_type is_null = -1;
  static const indicator_type is_not_null = 0;

  // Other policies to be incorporated:
  // walking records in buffer arrays (e.g. fixed length policy, array of pointers policy, terminated policy).
  // representation of primitive MetraFlow types.
  // Conversion buffer policy (this may be different for import and export):
  //   requires pivot (intermediate buffer)
  //   can convert directly into target buffer 
  // Column oriented vs. row oriented (this may be hard)
  

  static void DatetimeToOracleDate(date_time_traits::value val, boost::uint8_t * target, ub2& sz)
  {
#ifdef WIN32
    SYSTEMTIME t;
  
    ::VariantTimeToSystemTime(val, &t);
    WORD tmp = t.wYear/100;
    *target++ = boost::uint8_t(tmp + 100);
    *target++ = boost::uint8_t(t.wYear - 100*tmp + 100);
    *target++ = boost::uint8_t(t.wMonth);
    *target++ = boost::uint8_t(t.wDay);
    *target++ = boost::uint8_t(t.wHour+1);
    *target++ = boost::uint8_t(t.wMinute+1);
    *target++ = boost::uint8_t(t.wSecond+1);

    sz = 7;
#else
#endif
  }


  static void OracleDateToDatetime(const boost::uint8_t * target, date_time_traits::value & val)
  {
#ifdef WIN32
    SYSTEMTIME t;

    t.wYear = (*target++ - 100) * 100;
    t.wYear += (*target++ - 100);
    t.wMonth = *target++;
    t.wDayOfWeek = 0;
    t.wDay = (*target++);
    t.wHour = (*target++) - 1;
    t.wMinute = (*target++) - 1;
    t.wSecond = (*target++) - 1;
    t.wMilliseconds = 0;
    ::SystemTimeToVariantTime(&t, &val);
#else
#endif
  }

  // Oracle stores values of the NUMBER datatype in a variable-length format. The first byte is the exponent and is followed by 1 to 20 mantissa bytes. The high-order bit of the exponent byte is the sign bit; it is set for positive numbers and it is cleared for negative numbers. The lower 7 bits represent the exponent, which is a base-100 digit with an offset of 65.

  // To calculate the decimal exponent, add 65 to the base-100 exponent and add another 128 if the number is positive. If the number is negative, you do the same, but subsequently the bits are inverted. For example, -5 has a base-100 exponent = 62 (0x3e). The decimal exponent is thus (~0x3e) -128 - 65 = 0xc1 -128 -65 = 193 -128 -65 = 0.

  // Each mantissa byte is a base-100 digit, in the range 1..100. For positive numbers, the digit has 1 added to it. So, the mantissa digit for the value 5 is 6. For negative numbers, instead of adding 1, the digit is subtracted from 101. So, the mantissa digit for the number -5 is 96 (101 - 5). Negative numbers have a byte containing 102 appended to the data bytes. However, negative numbers that have 20 mantissa bytes do not have the trailing 102 byte. Because the mantissa digits are stored in base 100, each byte can represent 2 decimal digits. The mantissa is normalized; leading zeroes are not stored.

  // Up to 20 data bytes can represent the mantissa. However, only 19 are guaranteed to be accurate. The 19 data bytes, each representing a base-100 digit, yield a maximum precision of 38 digits for an Oracle NUMBER.

  // If you specify the datatype code 2 in the dty parameter of an OCIDefineByPos() call, your program receives numeric data in this Oracle internal format. The output variable should be a 21-byte array to accommodate the largest possible number. Note that only the bytes that represent the number are returned. There is no blank padding or null termination. If you need to know the number of bytes returned, use the VARNUM external datatype instead of NUMBER. See the description of VARNUM for examples of the Oracle internal number format.

// Import 8 Oracle Number positive digits at a time into a 32-bit quantity
  template <class _IntType>
  static void OracleNumberPositiveChunkToUint32(const boost::uint8_t * source, std::size_t len, _IntType& target)
  {
    ASSERT(len <= 4 && len >= 1);
    target = 0;
    switch(len)
    {
    case 4:
      target = 100*target + ((*source++)-0x01);
    case 3:
      target = 100*target + ((*source++)-0x01);
    case 2:
      target = 100*target + ((*source++)-0x01);
    case 1:
      target = 100*target + ((*source++)-0x01);
    }
  }

  template <class _IntType>
  static void OracleNumberNegativeChunkToUint32(const boost::uint8_t * source, std::size_t len, _IntType& target)
  {
    ASSERT(len <= 4 && len >= 1);
    target = 0;
    switch(len)
    {
    case 4:
      target = 100*target + (0x65 - (*source++));
    case 3:
      target = 100*target + (0x65 - (*source++));
    case 2:
      target = 100*target + (0x65 - (*source++));
    case 1:
      target = 100*target + (0x65 - (*source++));
    }
  }

  static void IntegerToOracleNumber(boost::int32_t value, boost::uint8_t * target, ub2& sz)
  {
    static const boost::int32_t exponents[5] = {1,100,10000,1000000,100000000};
    if (value>0)
    {
      int exp=4;
      while(value < exponents[exp])
      {
        exp -= 1;
      }

      target[0] = 0xc1 + (boost::uint8_t)(exp);
      // Convert to base-100 keeping track of trailing
      // zeros
      boost::uint8_t * target_it = target+1;
      boost::int32_t zero_run=0;
      switch(exp)
      {
      case 4:
      {
        *target_it = (boost::uint8_t) (value / 100000000);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (100000000*(*target_it));
      
        (*target_it++) += 0x01;
      }
      case 3:
      {
        *target_it = (boost::uint8_t) (value / 1000000);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (1000000*(*target_it));
        (*target_it++) += 0x01;
      }
      case 2:
      {
        *target_it = (boost::uint8_t) (value / 10000);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (10000*(*target_it));
        (*target_it++) += 0x01;
      }
      case 1:
      {
        *target_it = (boost::uint8_t) (value / 100);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (100*(*target_it));
        (*target_it++) += 0x01;
      }
      case 0:
      {
        *target_it = (boost::uint8_t) (value);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        (*target_it++) += 0x01;
      }
      }
      sz = (ub2) (exp + 2 - zero_run);
    }
    else if (value < 0)
    {
      // Make negative
      value *= -1;

      int exp=4;
      while(value < exponents[exp])
      {
        exp -= 1;
      }

      // Add 65 + 128 and invert bits
      target[0] = ~(0xc1 + (boost::uint8_t)(exp));
      // Convert to base-100 keeping track of trailing
      // zeros.
      // Digits of negative numbers are represented as
      // 101 - d
      // Negative numbers also have an additional trailing byte
      // with value 102.
      boost::uint8_t * target_it = target+1;
      boost::int32_t zero_run=0;
      switch(exp)
      {
      case 4:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 100000000);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (100000000*tmp);
      
        (*target_it++) = (0x65 - tmp);
      }
      case 3:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 1000000);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (1000000*tmp);
        (*target_it++) = (0x65 - tmp);
      }
      case 2:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 10000);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (10000*tmp);
        (*target_it++) = (0x65 - tmp);
      }
      case 1:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 100);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (100*tmp);
        (*target_it++) = (0x65 - tmp);
      }
      case 0:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        (*target_it++) = (0x65 - tmp);
      }
      }
      // Put in trailing 102.
      *target_it++ = 0x66;
      sz = (ub2) (exp + 3 - zero_run);    
    }
    else
    {
      target[0] = 0x80;
      sz = 1;
    }
  }

  static void OracleNumberToInteger(const boost::uint8_t * source, std::size_t len, boost::int32_t& target)
  {
    static const boost::int32_t exponents[] = {1,100,10000,1000000,100000000};

    if (source[0] & 0x80)
    {
      switch(len)
      {
      case 6:
      {
        boost::int32_t tmp;
        OracleNumberPositiveChunkToUint32<boost::int32_t>(source+1, 1, tmp);
        target = tmp;
        OracleNumberPositiveChunkToUint32<boost::int32_t>(source+2, 4, tmp);
        target = 100000000*target + tmp;
        break;
      }
      case 5:
      case 4:
      case 3:
      case 2:
      {
        OracleNumberPositiveChunkToUint32<boost::int32_t>(source+1, len-1, target);
        break;
      }
      case 1:
      {
        // Special case: 0 seems to be encoded as a single byte 0x80
        target = 0;
        return;
      }
      default:
        throw std::runtime_error("OracleNumberToInteger out of range");
      }
      target *= exponents[source[0]-0xbf-len];
    }
    else
    {
      // Negative numbers have an extra trailing byte of value
      // 102.
      switch(len)
      {
      case 7:
      {
        boost::int32_t tmp;
        OracleNumberNegativeChunkToUint32<boost::int32_t>(source+1, 1, tmp);
        target = tmp;
        OracleNumberNegativeChunkToUint32<boost::int32_t>(source+2, 4, tmp);
        target = 100000000*target + tmp;
        break;
      }
      default:
      {
        OracleNumberNegativeChunkToUint32<boost::int32_t>(source+1, len-2, target);
        break;
      }
      }
      ASSERT(source[len-1] == 0x66);
      boost::uint8_t idx = (~source[0]) - 0xbe - len;
      target *= -exponents[idx];
    }
  }

  static void Int64ToOracleNumber(boost::int64_t value, boost::uint8_t * target, ub2& sz)
  {
    static const boost::int64_t exponents[10] = {1,100,10000,1000000,100000000, 
                                                 10000000000LL,1000000000000LL,100000000000000LL,10000000000000000LL,1000000000000000000LL };
    if (value>0)
    {
      int exp=9;
      while(value < exponents[exp])
      {
        exp -= 1;
      }

      target[0] = 0xc1 + (boost::uint8_t)(exp);
      // Convert to base-100 keeping track of trailing
      // zeros
      boost::uint8_t * target_it = target+1;
      boost::int32_t zero_run=0;
      switch(exp)
      {
      case 9:
      {
        *target_it = (boost::uint8_t) (value / 1000000000000000000LL);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (1000000000000000000LL*(*target_it));
      
        (*target_it++) += 0x01;
      }
      case 8:
      {
        *target_it = (boost::uint8_t) (value / 10000000000000000LL);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (10000000000000000LL*(*target_it));
      
        (*target_it++) += 0x01;
      }
      case 7:
      {
        *target_it = (boost::uint8_t) (value / 100000000000000LL);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (100000000000000LL*(*target_it));
        (*target_it++) += 0x01;
      }
      case 6:
      {
        *target_it = (boost::uint8_t) (value / 1000000000000LL);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (1000000000000LL*(*target_it));
        (*target_it++) += 0x01;
      }
      case 5:
      {
        *target_it = (boost::uint8_t) (value / 10000000000LL);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (10000000000LL*(*target_it));
        (*target_it++) += 0x01;
      }
      case 4:
      {
        *target_it = (boost::uint8_t) (value / 100000000LL);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (100000000LL*(*target_it));
      
        (*target_it++) += 0x01;
      }
      case 3:
      {
        *target_it = (boost::uint8_t) (value / 1000000LL);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (1000000LL*(*target_it));
        (*target_it++) += 0x01;
      }
      case 2:
      {
        *target_it = (boost::uint8_t) (value / 10000LL);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (10000LL*(*target_it));
        (*target_it++) += 0x01;
      }
      case 1:
      {
        *target_it = (boost::uint8_t) (value / 100LL);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (100LL*(*target_it));
        (*target_it++) += 0x01;
      }
      case 0:
      {
        *target_it = (boost::uint8_t) (value);
        if (*target_it)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        (*target_it++) += 0x01;
      }
      }
      sz = (ub2) (exp + 2 - zero_run);
    }
    else if (value < 0)
    {
      value *= -1LL;
      int exp=9;
      while(value < exponents[exp])
      {
        exp -= 1;
      }

      target[0] = ~(0xc1 + (boost::uint8_t)(exp));
      // Convert to base-100 keeping track of trailing
      // zeros
      boost::uint8_t * target_it = target+1;
      boost::int32_t zero_run=0;
      switch(exp)
      {
      case 9:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 1000000000000000000LL);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (1000000000000000000LL*tmp);
      
        (*target_it++) = (0x65 - tmp);
      }
      case 8:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 10000000000000000LL);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (10000000000000000LL*tmp);
      
        (*target_it++) = (0x65 - tmp);
      }
      case 7:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 100000000000000LL);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (100000000000000LL*tmp);
        (*target_it++) = (0x65 - tmp);
      }
      case 6:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 1000000000000LL);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (1000000000000LL*tmp);
        (*target_it++) = (0x65 - tmp);
      }
      case 5:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 10000000000LL);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (10000000000LL*tmp);
        (*target_it++) = (0x65 - tmp);
      }
      case 4:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 100000000LL);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (100000000LL*tmp);
      
        (*target_it++) = (0x65 - tmp);
      }
      case 3:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 1000000LL);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (1000000LL*tmp);
        (*target_it++) = (0x65 - tmp);
      }
      case 2:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 10000LL);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (10000LL*tmp);
        (*target_it++) = (0x65 - tmp);
      }
      case 1:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value / 100LL);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        value -= (100LL*tmp);
        (*target_it++) = (0x65 - tmp);
      }
      case 0:
      {
        boost::uint8_t tmp = (boost::uint8_t) (value);
        if (tmp)
        {
          zero_run = 0;
        }
        else
        {
          zero_run++;
        }
        (*target_it++) = (0x65 - tmp);
      }
      }
      *target_it++ = 0x66;
      sz = (ub2) (exp + 3 - zero_run);    
    }
    else
    {
      target[0] = 0x80;
      sz = 1;
    }
  }

  static void OracleNumberToInt64(const boost::uint8_t * source, std::size_t len, boost::int64_t& target)
  {
    static const boost::int64_t exponents[10] = {1,100,10000,1000000,100000000, 
                                                 10000000000LL,1000000000000LL,100000000000000LL,
                                                 10000000000000000LL,1000000000000000000LL };

    // Clear
    target = 0LL;
  
    if (source[0] & 0x80)
    {
      const boost::uint8_t * source_it = source+1;
      boost::uint32_t tmp;

      switch(len)
      {
      case 11:
      case 10:
      {
        OracleNumberPositiveChunkToUint32<boost::uint32_t>(source_it, len-9, tmp);
        source_it += (len-9);
        target = tmp;
        OracleNumberPositiveChunkToUint32<boost::uint32_t>(source_it, 4, tmp);
        source_it += 4;
        target = 100000000LL*target + tmp;
        OracleNumberPositiveChunkToUint32<boost::uint32_t>(source_it, 4, tmp);
        target = 100000000LL*target + tmp;
        break;
      }
      case 9:
      case 8:
      case 7:
      case 6:
      {
        OracleNumberPositiveChunkToUint32<boost::uint32_t>(source_it, len-5, tmp);
        source_it += (len-5);
        target = tmp;
        OracleNumberPositiveChunkToUint32<boost::uint32_t>(source_it, 4, tmp);
        target = 100000000LL*target + tmp;
        break;
      }
      case 5:
      case 4:
      case 3:
      case 2:
      {
        OracleNumberPositiveChunkToUint32<boost::uint32_t>(source_it, len-1, tmp);
        target = tmp;
        break;
      }
      case 1:
      {
        target = 0;
        return;
      }
      }
      target *= exponents[source[0]-0xbf-len];
    }
    else
    {
      const boost::uint8_t * source_it = source+1;
      boost::uint32_t tmp;

      switch(len)
      {
      case 12:
      case 11:
      {
        OracleNumberNegativeChunkToUint32<boost::uint32_t>(source_it, len-10, tmp);
        source_it += (len-10);
        target = tmp;
        OracleNumberNegativeChunkToUint32<boost::uint32_t>(source_it, 4, tmp);
        source_it += 4;
        target = 100000000LL*target + tmp;
        OracleNumberNegativeChunkToUint32<boost::uint32_t>(source_it, 4, tmp);
        target = 100000000LL*target + tmp;
        break;
      }
      case 10:
      case 9:
      case 8:
      case 7:
      {
        OracleNumberNegativeChunkToUint32<boost::uint32_t>(source_it, len-6, tmp);
        source_it += (len-6);
        target = tmp;
        OracleNumberNegativeChunkToUint32<boost::uint32_t>(source_it, 4, tmp);
        target = 100000000LL*target + tmp;
        break;
      }
      case 6:
      case 5:
      case 4:
      case 3:
      {
        OracleNumberNegativeChunkToUint32<boost::uint32_t>(source_it, len-2, tmp);
        target = tmp;
        break;
      }
      }
      ASSERT(source[len-1] == 0x66);
      boost::uint8_t idx = (~source[0]) - 0xbe - len;
      target *= -exponents[idx];
    }
  }

  static void DecimalToOracleNumber(decimal_traits::const_pointer value, boost::uint8_t * target, ub2& sz)
  {
#ifdef WIN32
    if (value->Lo64)
    {
      // TODO: Fix to support full 12 bytes.
      // Oracle scale is base 100.
      Int64ToOracleNumber((value->scale & 0x01) ? 10*value->Lo64 : value->Lo64, target, sz);
      target[0] -= (value->scale+1)/2;
    }
    else
    {
      target[0] = 0x80;
      sz = 1;
    }
#else
#endif
  }

  static void OracleNumberToDecimal(const boost::uint8_t * source, std::size_t len, decimal_traits::value& value)
  {
    static boost::uint32_t powers [] = {1, 100, 10000, 1000000, 100000000};
    decimal_traits::zero(&value);
    const boost::uint8_t * sourceIt = source+1;
    
    // Special case handling of zero
    if (len == 1)
    {
      ASSERT(source[0] == 0x80);
      decimal_traits::zero(&value);
      return;
    }

    if (source[0] & 0x80)
    {
      boost::uint32_t tmp;
      const boost::uint8_t * sourceEnd = source + len;
      while((sourceIt + 4) < sourceEnd)
      {
        OracleNumberPositiveChunkToUint32<boost::uint32_t>(sourceIt, 4, tmp);
        decimal_traits::mul(100000000, &value);
        decimal_traits::add(tmp, &value);
        sourceIt += 4;
      }
      if (sourceIt != sourceEnd)
      {
        OracleNumberPositiveChunkToUint32<boost::uint32_t>(sourceIt, sourceEnd-sourceIt, tmp);
        decimal_traits::mul(powers[sourceEnd-sourceIt], &value);
        decimal_traits::add(tmp, &value);
      }
      if (source[0] > 0xbf+len)
      {
        decimal_traits::mul(powers[source[0]-0xbf-len], &value);      
      }
      else
      {
        decimal_traits::scale(2*(0xbf+len-source[0]), &value);
      }
    }
    else
    {
      boost::uint32_t tmp;
      // If it fits, the negative NUMBERS have a trailing value 102.
      std::size_t adjusted_len = len - (len==21 && source[len-1]==0x66 ? 0 : 1);
      const boost::uint8_t * sourceEnd = source + adjusted_len;
      while((sourceIt + 4) < sourceEnd)
      {
        OracleNumberNegativeChunkToUint32<boost::uint32_t>(sourceIt, 4, tmp);
        decimal_traits::mul(100000000, &value);
        decimal_traits::add(tmp, &value);
        sourceIt += 4;
      }
      if (sourceIt != sourceEnd)
      {
        OracleNumberNegativeChunkToUint32<boost::uint32_t>(sourceIt, sourceEnd-sourceIt, tmp);
        decimal_traits::mul(powers[sourceEnd-sourceIt], &value);
        decimal_traits::add(tmp, &value);
      }

      boost::uint8_t adjusted_exp=(~source[0]);
      if (adjusted_exp > boost::uint8_t(0xbf+adjusted_len))
      {
        decimal_traits::mul(powers[adjusted_exp-boost::uint8_t(0xbf+adjusted_len)], &value);      
      }
      else
      {
        decimal_traits::scale(2*(boost::uint8_t(adjusted_len+0xbf)-adjusted_exp), &value);
      }
      decimal_traits::neg(&value);
    }
  }
};


class OCIImporter
{
public:
  typedef void (OCIImporter::*ImportFunction) (const boost::uint8_t * ociRowBuffer, record_t metraFlowRecord);
  
private:
  RunTimeDataAccessor mMetraFlowColumn;
  OCIDataAccessor mOCIColumn;
  ImportFunction mImporter;
public:
  void ImportIntegerNumber(const boost::uint8_t * ociRowBuffer, record_t metraFlowRecord)
  {
    if (OCIDataModel::is_not_null == *mOCIColumn.GetIndicator(ociRowBuffer))
    {
      boost::int32_t tmp;
      OCIDataModel::OracleNumberToInteger(mOCIColumn.GetData(ociRowBuffer), *mOCIColumn.GetLength(ociRowBuffer), tmp);
      mMetraFlowColumn.SetValue(metraFlowRecord, &tmp);
    }
    else
    {
      mMetraFlowColumn.SetNull(metraFlowRecord);
      return;
    }
  }
  void ImportInt64Number(const boost::uint8_t * ociRowBuffer, record_t metraFlowRecord)
  {
    if (OCIDataModel::is_not_null == *mOCIColumn.GetIndicator(ociRowBuffer))
    {
      boost::int64_t tmp;
      OCIDataModel::OracleNumberToInt64(mOCIColumn.GetData(ociRowBuffer), *mOCIColumn.GetLength(ociRowBuffer), tmp);
      mMetraFlowColumn.SetValue(metraFlowRecord, &tmp);
    }
    else
    {
      mMetraFlowColumn.SetNull(metraFlowRecord);
      return;
    }
  }
  void ImportDecimalNumber(const boost::uint8_t * ociRowBuffer, record_t metraFlowRecord)
  {
    if (OCIDataModel::is_not_null == *mOCIColumn.GetIndicator(ociRowBuffer))
    {
      decimal_traits::value tmp;
      OCIDataModel::OracleNumberToDecimal(mOCIColumn.GetData(ociRowBuffer), *mOCIColumn.GetLength(ociRowBuffer), tmp);
      mMetraFlowColumn.SetValue(metraFlowRecord, &tmp);
    }
    else
    {
      mMetraFlowColumn.SetNull(metraFlowRecord);
      return;
    }
  }
  void ImportDatetimeDate(const boost::uint8_t * ociRowBuffer, record_t metraFlowRecord)
  {
    if (OCIDataModel::is_not_null == *mOCIColumn.GetIndicator(ociRowBuffer))
    {
      date_time_traits::value tmp;
      OCIDataModel::OracleDateToDatetime(mOCIColumn.GetData(ociRowBuffer), tmp);
      mMetraFlowColumn.SetValue(metraFlowRecord, &tmp);
    }
    else
    {
      mMetraFlowColumn.SetNull(metraFlowRecord);
      return;
    }
  }
  void ImportStringNVarchar(const boost::uint8_t * ociRowBuffer, record_t metraFlowRecord)
  {
    if (OCIDataModel::is_not_null == *mOCIColumn.GetIndicator(ociRowBuffer))
    {
      // TODO: Should we have to null terminate?
      ((UChar *)mOCIColumn.GetData(ociRowBuffer))[*mOCIColumn.GetLength(ociRowBuffer)/sizeof(UChar)] = 0;
      mMetraFlowColumn.SetValue(metraFlowRecord, mOCIColumn.GetData(ociRowBuffer));
    }
    else
    {
      mMetraFlowColumn.SetNull(metraFlowRecord);
      return;
    }
  }
  void ImportUTF8StringVarchar(const boost::uint8_t * ociRowBuffer, record_t metraFlowRecord)
  {
    if (OCIDataModel::is_not_null == *mOCIColumn.GetIndicator(ociRowBuffer))
    {
      // TODO: Should we have to null terminate?
      ((char *)mOCIColumn.GetData(ociRowBuffer))[*mOCIColumn.GetLength(ociRowBuffer)/sizeof(char)] = 0;
      mMetraFlowColumn.SetValue(metraFlowRecord, mOCIColumn.GetData(ociRowBuffer));
    }
    else
    {
      mMetraFlowColumn.SetNull(metraFlowRecord);
      return;
    }
  }
  void ImportDoubleBFloat(const boost::uint8_t * ociRowBuffer, record_t metraFlowRecord)
  {
    // Copyable
    if (OCIDataModel::is_not_null == *mOCIColumn.GetIndicator(ociRowBuffer))
    {
      mMetraFlowColumn.SetValue(metraFlowRecord, mOCIColumn.GetData(ociRowBuffer));
    }
    else
    {
      mMetraFlowColumn.SetNull(metraFlowRecord);
      return;
    }
  }
  void ImportBinaryRaw(const boost::uint8_t * ociRowBuffer, record_t metraFlowRecord)
  {
    // Copyable
    if (OCIDataModel::is_not_null == *mOCIColumn.GetIndicator(ociRowBuffer))
    {
      mMetraFlowColumn.SetValue(metraFlowRecord, mOCIColumn.GetData(ociRowBuffer));
    }
    else
    {
      mMetraFlowColumn.SetNull(metraFlowRecord);
      return;
    }
  }
  void Init(const RunTimeDataAccessor& metraFlowColumn, const OCIDataAccessor& ociColumn, ImportFunction importer)
  {
    mMetraFlowColumn = metraFlowColumn;
    mOCIColumn = ociColumn;
    mImporter = importer;
  }
  void Import(const boost::uint8_t * ociRowBuffer, record_t metraFlowRecord)
  {
    (this->*mImporter)(ociRowBuffer, metraFlowRecord);
  }
};

class OCIExporter
{
public:
  typedef void (OCIExporter::*ExportFunction) (boost::uint8_t * ociRowBuffer, const_record_t metraFlowRecord);
  
private:
  RunTimeDataAccessor mMetraFlowColumn;
  OCIDataAccessor mOCIColumn;
  ExportFunction mExporter;
public:
  void ExportIntegerNumber(boost::uint8_t * ociRowBuffer, const_record_t metraFlowRecord)
  {
    if (!mMetraFlowColumn.GetNull(metraFlowRecord))
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_not_null;
      OCIDataModel::IntegerToOracleNumber(mMetraFlowColumn.GetLongValue(metraFlowRecord), 
                                          mOCIColumn.GetData(ociRowBuffer), 
                                          *mOCIColumn.GetLength(ociRowBuffer));
    }
    else
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_null;
    }
  }
  void ExportInt64Number(boost::uint8_t * ociRowBuffer, const_record_t metraFlowRecord)
  {
    if (!mMetraFlowColumn.GetNull(metraFlowRecord))
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_not_null;
      OCIDataModel::Int64ToOracleNumber(mMetraFlowColumn.GetBigIntegerValue(metraFlowRecord), 
                                        mOCIColumn.GetData(ociRowBuffer), 
                                        *mOCIColumn.GetLength(ociRowBuffer));
    }
    else
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_null;
    }
  }
  void ExportDecimalNumber(boost::uint8_t * ociRowBuffer, const_record_t metraFlowRecord)
  {
    if (!mMetraFlowColumn.GetNull(metraFlowRecord))
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_not_null;
      OCIDataModel::DecimalToOracleNumber(mMetraFlowColumn.GetDecimalValue(metraFlowRecord), 
                                          mOCIColumn.GetData(ociRowBuffer), 
                                          *mOCIColumn.GetLength(ociRowBuffer));
    }
    else
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_null;
    }
  }
  void ExportDatetimeDate(boost::uint8_t * ociRowBuffer, const_record_t metraFlowRecord)
  {
    if (!mMetraFlowColumn.GetNull(metraFlowRecord))
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_not_null;
      OCIDataModel::DatetimeToOracleDate(mMetraFlowColumn.GetDatetimeValue(metraFlowRecord), 
                                         mOCIColumn.GetData(ociRowBuffer), 
                                         *mOCIColumn.GetLength(ociRowBuffer));
    }
    else
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_null;
    }
  }
  void ExportStringNVarchar(boost::uint8_t * ociRowBuffer, const_record_t metraFlowRecord)
  {
    if (!mMetraFlowColumn.GetNull(metraFlowRecord))
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_not_null;
      *mOCIColumn.GetLength(ociRowBuffer) = (ub2) (u_strlen(mMetraFlowColumn.GetStringValue(metraFlowRecord))*sizeof(UChar));
      memcpy(mOCIColumn.GetData(ociRowBuffer), 
             mMetraFlowColumn.GetStringValue(metraFlowRecord), 
             *mOCIColumn.GetLength(ociRowBuffer));
    }
    else
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_null;
    }
  }
  void ExportUTF8StringVarchar(boost::uint8_t * ociRowBuffer, const_record_t metraFlowRecord)
  {
    if (!mMetraFlowColumn.GetNull(metraFlowRecord))
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_not_null;
      *mOCIColumn.GetLength(ociRowBuffer) = (ub2) strlen(mMetraFlowColumn.GetUTF8StringValue(metraFlowRecord));
      memcpy(mOCIColumn.GetData(ociRowBuffer), 
             mMetraFlowColumn.GetUTF8StringValue(metraFlowRecord), 
             *mOCIColumn.GetLength(ociRowBuffer));
    }
    else
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_null;
    }
  }
  void ExportDoubleBFloat(boost::uint8_t * ociRowBuffer, const_record_t metraFlowRecord)
  {
    if (!mMetraFlowColumn.GetNull(metraFlowRecord))
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_not_null;
      *((double *)mOCIColumn.GetData(ociRowBuffer)) = mMetraFlowColumn.GetDoubleValue(metraFlowRecord);
      *mOCIColumn.GetLength(ociRowBuffer) = sizeof(double);
    }
    else
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_null;
    }
  }
  void ExportBinaryRaw(boost::uint8_t * ociRowBuffer, const_record_t metraFlowRecord)
  {
    if (!mMetraFlowColumn.GetNull(metraFlowRecord))
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_not_null;
      memcpy(mOCIColumn.GetData(ociRowBuffer), mMetraFlowColumn.GetBinaryValue(metraFlowRecord), 16);
      *mOCIColumn.GetLength(ociRowBuffer) = 16;
    }
    else
    {
      *mOCIColumn.GetIndicator(ociRowBuffer) = OCIDataModel::is_null;
    }
  }
  void Init(const RunTimeDataAccessor& metraFlowColumn, const OCIDataAccessor& ociColumn, ExportFunction exporter)
  {
    mMetraFlowColumn = metraFlowColumn;
    mOCIColumn = ociColumn;
    mExporter = exporter;
  }
  void Export(boost::uint8_t * ociRowBuffer, const_record_t metraFlowRecord)
  {
    (this->*mExporter)(ociRowBuffer, metraFlowRecord);
  }
};

class OCIRecordExporter
{
private:
  OCIExporter * mExporters;
  OCIExporter * mExportersEnd;
  
public:
  /**
   * Create an exporter from source format inputMetraFlowRecord to 
   * target table described by tableMetraFlowRecord.
   */
  OCIRecordExporter(const RecordMetadata& inputMetraFlowRecord, 
                    const RecordMetadata& tableMetraFlowRecord, 
                    const OCIRowBuffer& ociBuffer);

  ~OCIRecordExporter();

  void Export(boost::uint8_t * ociBuffer, const_record_t metraFlowRecord)
  {
    for(OCIExporter * it = mExporters; it != mExportersEnd; ++it)
    {
      it->Export(ociBuffer, metraFlowRecord);
    }
  }
  
};

   
class OCIRecordImporter
{
private:
  OCIImporter * mImporters;
  OCIImporter * mImportersEnd;
  
public:
  OCIRecordImporter(const RecordMetadata& metraFlowRecord, const OCIRowBuffer& ociBuffer);
  ~OCIRecordImporter();

  void Import(const boost::uint8_t * ociBuffer, record_t metraFlowRecord)
  {
    for(OCIImporter * it = mImporters; it != mImportersEnd; ++it)
    {
      it->Import(ociBuffer, metraFlowRecord);
    }
  }  
};

/**
 * When doing a select, the select list is described by the database and can be transformed into a RecordMetadata instance.
 * When doing a single table insert, the insert/bind variables can be taken from the database and transformed into a RecordMetadata instance for binding.
 * When doing a general parameterized query, the insert/bind variables cannot be inferred from the database and either must be
 * specified externally or translated from a RecordMetadata instance.
 */

class OracleConnection
{
private:
  OCIEnv           *p_env;
  OCIError         *p_err;
  OCISvcCtx        *p_svc;

  void Init(const std::string& username,
            const std::string& password,
            const std::string& server,
            const std::string& trace);

public:
  METRAFLOW_DECL OracleConnection(const std::string& username,
                                  const std::string& password,
                                  const std::string& server,
                                  const std::string& trace);

  METRAFLOW_DECL OracleConnection(const std::string& username,
                                  const std::string& password,
                                  const std::string& server);

  METRAFLOW_DECL ~OracleConnection();

  /**
   * Execute a DML with no bind variables.
   */
  METRAFLOW_DECL void ExecuteNonQuery(const std::string& query);

  /**
   * Describe query using MetraFlow record.
   */
  METRAFLOW_DECL void DescribeQuery(const std::string& query, RecordMetadata& metadata);

  /**
   * Prepare an array insert into a table.
   */
  METRAFLOW_DECL OraclePreparedStatement * PrepareInsertStatement(const std::string& table, const RecordMetadata& parameters);

  /**
   * Execute a query
   */
  METRAFLOW_DECL OracleResultSet * ExecuteQuery(const std::string& query);

  /**
   * Commit a transaction
   */
  METRAFLOW_DECL void CommitTransaction();
};

class OracleResultSet
{
private:
  // Pointers into the data buffer
  const boost::uint8_t * mMaxRow;
  const boost::uint8_t * mCurrentRow;
  // The data buffer
  const boost::uint8_t * mData;
  ub4 mRowSize;
  // Have we fetched our last array?
  bool mCanFetch;
  // MetraFlow importer to convert from OCI buffer to MetraFlow record
  OCIRecordImporter mImporter;
  // Handles
  OCIStmt * mStmt;
  OCIError * mError;
  // MetraFlow record format
  RecordMetadata mMetadata;
  // OCI Buffer and descriptor
  OCIRowDefinition mDefinition;
public:

  METRAFLOW_DECL OracleResultSet(OCISvcCtx * svc,
                  OCIStmt * stmt, 
                  OCIError * error, 
                  const RecordMetadata& metadata, 
                  OCIRowBuffer& buffer,
                  ub4 rows);
  METRAFLOW_DECL ~OracleResultSet();
  METRAFLOW_DECL const RecordMetadata& Describe() const;
  METRAFLOW_DECL record_t Next();
};

class OraclePreparedStatement
{
private:
  // Pointers into the data buffer
  boost::uint8_t * mMaxRow;
  boost::uint8_t * mCurrentRow;
  // The data buffer
  boost::uint8_t * mData;
  ub4 mRowSize;
  // MetraFlow exporter to convert from MetraFlow record to OCI buffer 
  OCIRecordExporter mExporter;
  // Handles
  OCISvcCtx * mSvc;
  OCIStmt * mStmt;
  OCIError * mError;
  // OCI Buffer and descriptor
  OCIRowBinding mBinding;

  void InternalExecuteBatch();
public:

  /**
   * parameterMetadata must be a superset of tableMetadata.
   */
  METRAFLOW_DECL OraclePreparedStatement(OCISvcCtx * svc,
                          OCIStmt * stmt, 
                          OCIError * error, 
                          const RecordMetadata& parameterMetadata, 
                          const RecordMetadata& tableMetadata, 
                          OCIRowBuffer& buffer,
                          ub4 rows);
  METRAFLOW_DECL ~OraclePreparedStatement();
  METRAFLOW_DECL void AddBatch(const_record_t metraFlowRecord);
  METRAFLOW_DECL void ExecuteBatch();
};

class DesignTimeOCIDatabaseInsert : public DesignTimeOperator
{
private:
  std::vector<std::wstring> mTableNames;
  boost::int32_t mBatchSize;
  boost::int32_t mCommitSize;
  std::string mTracePrefix;

  static void CheckTypeCompatibility(const DesignTimeOperator& op, const Port& p,
                                     const COdbcColumnMetadata& db, const DataAccessor& accessor);
public:
  METRAFLOW_DECL DesignTimeOCIDatabaseInsert();
  METRAFLOW_DECL ~DesignTimeOCIDatabaseInsert();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(Reactor * reactor, partition_t partition, partition_t maxPartition);

  const std::vector<std::wstring>& GetTableNames() const 
  {
    return mTableNames; 
  }
  void AddTableName(const std::wstring& tableName)  
  {
    mTableNames.push_back(tableName);
  }
  boost::int32_t GetBatchSize() const
  {
    return mBatchSize;
  }
  void SetBatchSize(boost::int32_t batchSize) 
  {
    mBatchSize = batchSize;
  }
  boost::int32_t GetCommitSize() const
  {
    return mCommitSize;
  }
  void SetCommitSize(boost::int32_t commitSize) 
  {
    mCommitSize = commitSize;
  }
  void SetTracePrefix(const std::string& tracePrefix)
  {
    mTracePrefix = tracePrefix;
  }
};

class RunTimeOCIDatabaseInsert : public RunTimeOperator
{
private:
  std::vector<std::wstring> mTableNames;
  boost::int32_t mBatchSize;
  boost::int32_t mCommitSize;
  RecordMetadata mMetadata;
  std::string mTracePrefix;


  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mTableNames);
    ar & BOOST_SERIALIZATION_NVP(mBatchSize);
    ar & BOOST_SERIALIZATION_NVP(mCommitSize);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
    ar & BOOST_SERIALIZATION_NVP(mTracePrefix);
  } 

  enum State { START, READ_0 };
  State mState;
  record_t mInputMessage;
  OracleConnection * mConnection;
  std::vector<OraclePreparedStatement *> mStatements;
  boost::int32_t mCurrentBatchCount;
  boost::int32_t mCurrentTransactionCount;
  boost::int64_t mNumRead;

  void Close();
  METRAFLOW_DECL RunTimeOCIDatabaseInsert ();
public:
  METRAFLOW_DECL RunTimeOCIDatabaseInsert (Reactor * reactor, 
                                           const std::wstring& name, 
                                           partition_t partition, 
                                           const std::vector<std::wstring> & tableNames,
                                           boost::int32_t batchSize,
                                           boost::int32_t commitSize,
                                           const std::string& tracePrefix,
                                           const RecordMetadata& metadata);
  METRAFLOW_DECL ~RunTimeOCIDatabaseInsert();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

BOOST_CLASS_EXPORT(RunTimeOCIDatabaseInsert);
#endif
