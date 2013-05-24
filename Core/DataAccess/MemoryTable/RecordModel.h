#ifndef _RECORDMODEL_H_
#define _RECORDMODEL_H_

#include <string>
#include <vector>
#include <map>
#include <functional>

using std::binary_function;
#include <boost/cstdint.hpp>

#include <metra.h>
#include "MetraFlowConfig.h"
#include "MTSQLException.h"
#include "LogicalRecordModel.h"
#include "HashFunction.h"

// #include <boost/archive/xml_woarchive.hpp>
// #include <boost/archive/xml_wiarchive.hpp>
#include <boost/serialization/serialization.hpp>
#include <boost/serialization/string.hpp>
#include <boost/serialization/vector.hpp>
#include <boost/serialization/map.hpp>

#include <boost/algorithm/string.hpp>

#if defined(WIN32)
#import <MTPipelineLib.tlb> rename("EOF", "EOFX")
#else
class MTPipelineLib
{
public:
  enum PropValType {
    PROP_TYPE_UNKNOWN = 0,
    PROP_TYPE_DEFAULT = 1,
    PROP_TYPE_INTEGER = 2,
    PROP_TYPE_DOUBLE = 3,
    PROP_TYPE_STRING = 4,
    PROP_TYPE_DATETIME = 5,
    PROP_TYPE_TIME = 6,
    PROP_TYPE_BOOLEAN = 7,
    PROP_TYPE_SET = 8,
    PROP_TYPE_OPAQUE = 9,
    PROP_TYPE_ENUM = 10,
    PROP_TYPE_DECIMAL = 11,
    PROP_TYPE_ASCII_STRING = 12,
    PROP_TYPE_UNICODE_STRING = 13,
    PROP_TYPE_BIGINTEGER = 14
  };
  typedef long IMTSQLRowsetPtr;
};
#endif

namespace llvm
{
  class Function;
  class Module;
}

class DecimalConstantPool;
class UTF8StringConstantPool;
class WideStringConstantPool;
class WideStringConstantPool2;
class BigIntegerConstantPool;
class DoubleConstantPool;
class DatetimeConstantPool;

class PhysicalFieldType;
class FieldAccessor;
class RunTimeDataAccessor;
class DataAccessor;
class RecordMetadata;

typedef unsigned char * record_t;
typedef const unsigned char * const_record_t;

typedef void (RunTimeDataAccessor::*FieldAddressFree)(record_t) const;
typedef void (RunTimeDataAccessor::*FieldAddressClone)(const_record_t, record_t) const;

typedef struct tagPrefixedWideString
{
  wchar_t * String;
  boost::int32_t Length;
} PrefixedWideString;

class decimal_traits
{
public:
  typedef DECIMAL value;
  typedef DECIMAL * pointer;
  typedef const DECIMAL * const_pointer;
  typedef DECIMAL& reference;
  typedef const DECIMAL & const_reference;

  static bool eq(const value * lhs, const value * rhs)
  {
    return VARCMP_EQ == ::VarDecCmp(const_cast<value *>(lhs), const_cast<value *>(rhs));
  }
  static int cmp(const value * lhs, const value * rhs)
  {
    HRESULT hr = ::VarDecCmp(const_cast<decimal_traits::pointer>(lhs), const_cast<decimal_traits::pointer>(rhs));
    return VARCMP_LT == hr ? -1 : VARCMP_EQ == hr ? 0 : 1;
  }
  static void to_string(const value * source, std::string& str)
  {
    BSTR bstrVal;
    HRESULT hr = ::VarBstrFromDec(const_cast<value *>(source), LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
    if(FAILED(hr)) throw MTSQLComException(hr);
    // Use a _bstr_t to delete the BSTR
    _bstr_t bstrtVal(bstrVal, false);
    str = (const char *) bstrVal;
  }
  static void from_string(const char * source, value * target)
  {
    _bstr_t bStr(source);
    HRESULT hr = ::VarDecFromStr(bStr, LOCALE_SYSTEM_DEFAULT, 0, target);
    if(FAILED(hr)) throw MTSQLComException(hr);    
  }
  static void to_ustring(const value * source, std::wstring& str)
  {
    BSTR bstrVal;
    HRESULT hr = ::VarBstrFromDec(const_cast<value *>(source), LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
    if(FAILED(hr)) throw MTSQLComException(hr);
    // Use a _bstr_t to delete the BSTR
    _bstr_t bstrtVal(bstrVal, false);
    str = bstrVal;
  }
  static void from_ustring(const wchar_t * source, value * target)
  {
    HRESULT hr = ::VarDecFromStr(const_cast<wchar_t *>(source), LOCALE_SYSTEM_DEFAULT, 0, target);
    if(FAILED(hr)) throw MTSQLComException(hr);
  }
};

class date_time_traits
{
public:
  typedef DATE internal_value;
  typedef DATE value;
  typedef DATE * pointer;
  typedef const DATE * const_pointer;
  typedef DATE& reference;
  typedef const DATE & const_reference;

  static bool eq(const value * lhs, const value * rhs)
  {
    return *lhs == *rhs;
  }
  static int cmp(const value * lhs, const value * rhs)
  {
  }
  static void to_string(const value * source, std::string& str)
  {
    BSTR bstrVal;
    HRESULT hr = ::VarBstrFromDate(*source, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
    if(FAILED(hr)) throw MTSQLComException(hr);
    // Use a _bstr_t to delete the BSTR
    _bstr_t bstrtVal(bstrVal, false);
    str = (const char *) bstrVal;
  }
  static void from_string(const char * source, value * target)
  {
    _bstr_t bStr(source);
    HRESULT hr = ::VarDateFromStr(bStr, LOCALE_SYSTEM_DEFAULT, 0, target);
    if(FAILED(hr)) throw MTSQLComException(hr);    
  }
  static void to_ustring(const value * source, std::wstring& str)
  {
    BSTR bstrVal;
    HRESULT hr = ::VarBstrFromDate(*source, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
    if(FAILED(hr)) throw MTSQLComException(hr);
    // Use a _bstr_t to delete the BSTR
    _bstr_t bstrtVal(bstrVal, false);
    str = bstrVal;
  }
  static void from_ustring(const wchar_t * source, value * target)
  {
    HRESULT hr = ::VarDateFromStr(const_cast<wchar_t *>(source), LOCALE_SYSTEM_DEFAULT, 0, target);
    if(FAILED(hr)) throw MTSQLComException(hr);
  }
};

class SortOrder
{
public:
	METRAFLOW_DECL enum SortOrderEnum {ASCENDING, DESCENDING};
};
class ThreadLocalRegionAllocator
{
public:
  METRAFLOW_DECL static void * malloc(size_t sz);
  METRAFLOW_DECL static void free(void * p);
};


// // A non reference counted pointer
// class PascalWideStringPtr
// {
// private:
//   unsigned char * mPtr;

//   PascalWideStringPtr (unsigned char * ptr)
//     :
//     mPtr(ptr)
//   {
//   }
  
// public:
//   PascalWideStringPtr(const PascalWideStringPtr & ptr)
//     :
//     mPtr(ptr.mPtr)
//   {
//   }
//   ~PascalWideStringPtr() {}
//   static PascalWideStringPtr Create(const wchar_t * val, int len)
//   {
//     unsigned char * ptr = (unsigned char *) ::malloc(sizeof(wchar_t)*(len+1) + sizeof(int));
//     *((int *)ptr) = len;
//     ptr += sizeof(int);
//     memcpy(ptr, val, sizeof(wchar_t)*(len+1));
//     return PascalWideStringPtr(ptr);
//   }
//   static PascalWideStringPtr Create(const wchar_t * val)
//   {
//     return Create(val, wcslen(val));
//   }
//   static void Free(PascalWideStringPtr str)
//   {
//     ::free(&((int *)mPtr)[-1]);
//   }
//   int Length() const
//   {
//     return ((int *)mPtr)[-1];
//   }
//   operator const wchar_t * () const
//   {
//     return (const wchar_t *) mPtr;
//   }
// };

class ConstantPoolFactory
{
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
  }  
public:
  virtual ~ConstantPoolFactory() {}
  // Access to the constant pool.
  virtual decimal_traits::pointer GetDecimalConstant(decimal_traits::const_pointer dec)=0;
  virtual wchar_t * GetWideStringConstant(const wchar_t * val)=0;
  virtual char * GetUTF8StringConstant(const char * val)=0;
  virtual boost::int64_t * GetBigIntegerConstant(boost::int64_t val)=0;
  virtual double * GetDoubleConstant(double val)=0;
  virtual date_time_traits::pointer GetDatetimeConstant(date_time_traits::value dec)=0;
};

class ConstantPoolFactoryBase : public ConstantPoolFactory
{
private:
  DecimalConstantPool * mDecimalConstantPool;
  WideStringConstantPool * mWideStringConstantPool;
  UTF8StringConstantPool * mUTF8StringConstantPool;
  BigIntegerConstantPool * mBigIntegerConstantPool;
  DoubleConstantPool * mDoubleConstantPool;
  DatetimeConstantPool * mDatetimeConstantPool;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    // We really only support serializing empty pools.  Need to refactor
    // code to eliminate this.
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(ConstantPoolFactory);
  }  
public:
  METRAFLOW_DECL ConstantPoolFactoryBase();
  METRAFLOW_DECL virtual ~ConstantPoolFactoryBase();
  // Access to the constant pool.
  METRAFLOW_DECL decimal_traits::pointer GetDecimalConstant(decimal_traits::const_pointer dec);
  METRAFLOW_DECL wchar_t * GetWideStringConstant(const wchar_t * val);
  METRAFLOW_DECL char * GetUTF8StringConstant(const char * val);
  METRAFLOW_DECL boost::int64_t * GetBigIntegerConstant(boost::int64_t val);
  METRAFLOW_DECL double * GetDoubleConstant(double val);
  METRAFLOW_DECL date_time_traits::pointer GetDatetimeConstant(date_time_traits::value dec);
};

class GlobalConstantPoolFactory : public ConstantPoolFactoryBase
{
private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    // Logger is stateless so don't serialize.
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(ConstantPoolFactoryBase);
  }  
public:
  METRAFLOW_DECL GlobalConstantPoolFactory();
  METRAFLOW_DECL ~GlobalConstantPoolFactory();
  METRAFLOW_DECL static GlobalConstantPoolFactory * Get();
};


class SortKeyBuffer
{
private:
  boost::uint8_t * mBuffer;
  boost::int32_t mUsedLength;
  boost::int32_t mAllocatedLength;
  boost::uint8_t * mCurrentPos;
  METRAFLOW_DECL void DoubleBuffer(boost::int32_t minAdditionalLen);
  METRAFLOW_DECL SortKeyBuffer(const SortKeyBuffer& buffer);
  METRAFLOW_DECL SortKeyBuffer& operator=(const SortKeyBuffer& buffer);

public:
  METRAFLOW_DECL SortKeyBuffer();
  METRAFLOW_DECL ~SortKeyBuffer();
  boost::uint8_t * GetWriteableBuffer(boost::int32_t requiredBytes)
  {
    if (AvailableLength() < requiredBytes)
      DoubleBuffer(requiredBytes);
    ASSERT(AvailableLength() >= requiredBytes);
    boost::uint8_t * tmp = mCurrentPos;
    mUsedLength += requiredBytes;
    mCurrentPos += requiredBytes;
    return tmp;
  }

  boost::int32_t AvailableLength()
  {
    return mAllocatedLength - mUsedLength;
  }

  boost::uint8_t * GetKey()
  {
    return mBuffer;
  }

  boost::uint8_t * GetCurrentPosition()
  {
    return mCurrentPos;
  }

  boost::int32_t GetLength()
  {
    return mUsedLength;
  }

  void Clear()
  {
    mUsedLength = 0;
    mCurrentPos = mBuffer;
  }

  static int Compare(const SortKeyBuffer& e1, const SortKeyBuffer& e2)
  {
    return memcmp(e1.mBuffer, e2.mBuffer, e1.mUsedLength < e2.mUsedLength ? e1.mUsedLength : e2.mUsedLength);
  }

  struct Less : public std::binary_function< SortKeyBuffer *, SortKeyBuffer *, bool >
  {
    bool operator()(const SortKeyBuffer * e1, const SortKeyBuffer * e2) const
    {
      return 0 < memcmp(e1->mBuffer, e2->mBuffer, e1->mUsedLength < e2->mUsedLength ? e1->mUsedLength : e2->mUsedLength);
    }
  };

  // Sort Key exporter.
public:
  static void ExportIntegerSortKeyFunction(const void * buffer, bool isNull, SortOrder::SortOrderEnum aSortOrder, SortKeyBuffer& sortKeyBuffer, int maxBytes ) 
  {
    const unsigned char * mBuffer = (const unsigned char *) (buffer);
    if (!isNull)
    {
      boost::uint8_t * outputBuffer = sortKeyBuffer.GetWriteableBuffer(maxBytes+1);
      //reverse the ***bytes*** as the x86 architecture store them in big endian form
      //for descending order, just flip each ***bit***

      // Sort NULLs high
      outputBuffer[0] = 0x00;
      outputBuffer[0] |= (mBuffer[3] >> 1);
      outputBuffer[1] = ((mBuffer[3] & 0x01) << 7); 
      outputBuffer[1] |= (mBuffer[2] >> 1);
      outputBuffer[2] = ((mBuffer[2] & 0x01) << 7); 
      outputBuffer[2] |= (mBuffer[1] >> 1);
      outputBuffer[3] = ((mBuffer[1] & 0x01) << 7); 
      outputBuffer[3] |= (mBuffer[0] >> 1);
      outputBuffer[4] = ((mBuffer[0] & 0x01) << 7);
      // Flip sign bit (bit number 2)
      outputBuffer[0] ^= 0x40;
      if (aSortOrder == SortOrder::DESCENDING)
      {
        // Flip all bits
        *((boost::uint32_t *)outputBuffer) ^= 0xffffffff;
        outputBuffer[4] ^= 0xff;
      }
    }
    else
    {
      // Sort NULLs high
      boost::uint8_t * outputBuffer = sortKeyBuffer.GetWriteableBuffer(1);
      outputBuffer[0] = aSortOrder == SortOrder::ASCENDING ? 0x80 : 0x00;
    }
  }  

  static void ExportBigIntegerSortKeyFunction(const void * buffer, bool isNull, SortOrder::SortOrderEnum aSortOrder, SortKeyBuffer& sortKeyBuffer, int maxBytes ) 
  {
    const unsigned char * mBuffer = (const unsigned char *) (buffer);

    if (!isNull)
    {
      boost::uint8_t * outputBuffer = sortKeyBuffer.GetWriteableBuffer(maxBytes+1);
	
      //reverse the ***bytes*** as the x86 architecture store them in big endian form
      //for descending order, just flip each ***bit***

      if (aSortOrder == SortOrder::ASCENDING)
      {
        // Sort NULLs high
        outputBuffer[0] = 0x00;
        outputBuffer[1] = mBuffer[7];
        outputBuffer[2] = mBuffer[6];
        outputBuffer[3] = mBuffer[5];
        outputBuffer[4] = mBuffer[4];
        outputBuffer[5] = mBuffer[3];
        outputBuffer[6] = mBuffer[2];
        outputBuffer[7] = mBuffer[1];
        outputBuffer[8] = mBuffer[0];
        outputBuffer[1] ^= 0x80;
      }
      else
      {
        // Sort NULLs high
        outputBuffer[0] = 0xff;
        outputBuffer[1] = mBuffer[7];
        outputBuffer[2] = mBuffer[6]^0xff;
        outputBuffer[3] = mBuffer[5]^0xff;
        outputBuffer[4] = mBuffer[4]^0xff;
        outputBuffer[5] = mBuffer[3]^0xff;
        outputBuffer[6] = mBuffer[2]^0xff;
        outputBuffer[7] = mBuffer[1]^0xff;
        outputBuffer[8] = mBuffer[0]^0xff;
        outputBuffer[1] ^= 0x80;
        outputBuffer[1] ^= 0xff;
      }
    }
    else
    {
      // Sort NULLs high
      boost::uint8_t * outputBuffer = sortKeyBuffer.GetWriteableBuffer(1);
      outputBuffer[0] = aSortOrder == SortOrder::ASCENDING ? 0xff : 0x00;
    }
  }

  static void ExportDatetimeSortKeyFunction(const void * buffer, bool isNull, SortOrder::SortOrderEnum aSortOrder, SortKeyBuffer& sortKeyBuffer,  int maxBytes) 
  {
    const unsigned char * mBuffer = (const unsigned char *) (buffer);

    if (!isNull)
    {
      boost::uint8_t * outputBuffer = sortKeyBuffer.GetWriteableBuffer(maxBytes+1);
	
      //datetimes are stored as doubles.  Doubles are stored using the IEEE format-
      //first bit is sign, 11 bits for exponent, 52 bits for mantissa.
      // IEEE format is designed so that it can by memcmp'd but 
      //On x86 the byte order is reversed cause it is bigendian

      // Sort NULLs high
      outputBuffer[0] = 0x00;
      //reverse the byte order
      outputBuffer[1] = mBuffer[7];
      outputBuffer[2] = mBuffer[6];
      outputBuffer[3] = mBuffer[5];
      outputBuffer[4] = mBuffer[4];
      outputBuffer[5] = mBuffer[3];
      outputBuffer[6] = mBuffer[2];
      outputBuffer[7] = mBuffer[1];
      outputBuffer[8] = mBuffer[0];

      if (outputBuffer[1] & 0x80)
      {
        /* negative -- flip all bits */
        outputBuffer[1] ^= 0xff;
        outputBuffer[2] ^= 0xff;
        outputBuffer[3] ^= 0xff;
        outputBuffer[4] ^= 0xff;
        outputBuffer[5] ^= 0xff;
        outputBuffer[6] ^= 0xff;
        outputBuffer[7] ^= 0xff;
        outputBuffer[8] ^= 0xff;
      }
      else
      {
        /* positive -- flip only the sign bit */
        outputBuffer[1] ^= 0x80;
      }
      if (aSortOrder == SortOrder::DESCENDING)
      {
        outputBuffer[0] = 0xff;      
        //for each byte, flip the bits.
        outputBuffer[1] ^= 0xff;
        outputBuffer[2] ^= 0xff;
        outputBuffer[3] ^= 0xff;
        outputBuffer[4] ^= 0xff;
        outputBuffer[5] ^= 0xff;
        outputBuffer[6] ^= 0xff;
        outputBuffer[7] ^= 0xff;
        outputBuffer[8] ^= 0xff;
      }
    }
    else
    {
      // Sort NULLs high
      boost::uint8_t * outputBuffer = sortKeyBuffer.GetWriteableBuffer(1);
      outputBuffer[0] = aSortOrder == SortOrder::ASCENDING ? 0xff : 0x00;
    }
  }
  static void ExportBooleanSortKeyFunction(const void * buffer, bool isNull, SortOrder::SortOrderEnum aSortOrder, SortKeyBuffer& sortKeyBuffer, int maxBytes ) 
  {
    const bool * mBuffer = (const bool *) (buffer);
    boost::uint8_t * outputBuffer = sortKeyBuffer.GetWriteableBuffer(1);
    // Since we encode NULLs high, we encode false=0, true=1, null=0x02 for ASCENDING
    if (aSortOrder == SortOrder::ASCENDING)
    {
      outputBuffer[0] = isNull ? 0x02 : (*mBuffer ? 0x01 : 0x00);
    }
    else
    {
      outputBuffer[0] = isNull ? 0x00 : (*mBuffer ? 0x01 : 0x02);
    }
  }  
  static void ExportBinarySortKeyFunction(const void * buffer, bool isNull, SortOrder::SortOrderEnum aSortOrder, SortKeyBuffer& sortKeyBuffer, int maxBytes ) 
  {
    const unsigned char * mBuffer = (const unsigned char *) (buffer);

    if (maxBytes != 16)
      throw std::runtime_error("Only BINARY(16) supported");

    if (!isNull)
    {
      boost::uint8_t * outputBuffer = sortKeyBuffer.GetWriteableBuffer(maxBytes+1);
	
      //reverse the ***bytes*** as the x86 architecture store them in big endian form
      //for descending order, just flip each ***bit***

      if (aSortOrder == SortOrder::ASCENDING)
      {
        // Sort NULLs high
        outputBuffer[0] = 0x00;
        memcpy(outputBuffer+1, &mBuffer[0], maxBytes);
      }
      else
      {
        // Sort NULLs high
        outputBuffer[0] = 0xff;
        outputBuffer[1] = mBuffer[0]^0xff;
        outputBuffer[2] = mBuffer[1]^0xff;
        outputBuffer[3] = mBuffer[2]^0xff;
        outputBuffer[4] = mBuffer[3]^0xff;
        outputBuffer[5] = mBuffer[4]^0xff;
        outputBuffer[6] = mBuffer[5]^0xff;
        outputBuffer[7] = mBuffer[6]^0xff;
        outputBuffer[8] = mBuffer[7]^0xff;
        outputBuffer[9] = mBuffer[8]^0xff;
        outputBuffer[10] = mBuffer[9]^0xff;
        outputBuffer[11] = mBuffer[10]^0xff;
        outputBuffer[12] = mBuffer[11]^0xff;
        outputBuffer[13] = mBuffer[12]^0xff;
        outputBuffer[14] = mBuffer[13]^0xff;
        outputBuffer[15] = mBuffer[14]^0xff;
        outputBuffer[16] = mBuffer[15]^0xff;
      }
    }
    else
    {
      // Sort NULLs high
      boost::uint8_t * outputBuffer = sortKeyBuffer.GetWriteableBuffer(1);
      outputBuffer[0] = aSortOrder == SortOrder::ASCENDING ? 0xff : 0x00;
    }
  }
};

class FieldAddress
{
protected:
  // Location of the null bit for this field. It is based on the order of the 
  // condition in the column metadata collection. 
  // Note that this is not the same
  // as that based on column position in the database because of
  // operator row columns.

  // Byte offset (NOT long offset) to the unsigned int containing the bit
  long mNullWord;
  unsigned int mNullFlag;
  // Byte offset relative to the start of the buffer to the const value.  For certain values (decimals & strings),
  // this is a pointer to where the value lives.  In the operator per rule case, this points to the operator.
  long mOffset;
  // For the case in which values are stored by reference, the values are managed in a table
  // that has a unique representative for each value.  Among other things, reference values can be 
  // compared for equality by pointer comparison.
  ConstantPoolFactory * mConstantPool;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    // TODO: Remove this runtime artifact
    ar & BOOST_SERIALIZATION_NVP(mConstantPool);
    ar & BOOST_SERIALIZATION_NVP(mNullWord);
    ar & BOOST_SERIALIZATION_NVP(mNullFlag);
    ar & BOOST_SERIALIZATION_NVP(mOffset);
  }  
protected:
  FieldAddress()
    :
    mNullWord(0),
    mNullFlag(0),
    mOffset(0),
    mConstantPool(NULL)
  {
  }

public:
  FieldAddress(ConstantPoolFactory * constantPool, long position, long offset)
    :
    mNullWord(sizeof(void*) + sizeof(unsigned int)*(position / (sizeof(unsigned int)*8))),
    mNullFlag(1UL << (position % (sizeof(unsigned long)*8))),
    mOffset(offset),
    mConstantPool(constantPool)
  {
  }
  FieldAddress(const FieldAddress& fa)
    :
    mNullWord(fa.mNullWord),
    mNullFlag(fa.mNullFlag),
    mOffset(fa.mOffset),
    mConstantPool(fa.mConstantPool)
  {
  }
  FieldAddress& operator=(const FieldAddress& fa)
  {
    mConstantPool = fa.mConstantPool;
    mNullWord=fa.mNullWord;
    mNullFlag=fa.mNullFlag;
    mOffset=fa.mOffset;
    return *this;
  }
  void Update(long position, long offset)
  {
    mNullWord = sizeof(void*) + sizeof(unsigned int)*(position / (sizeof(unsigned int)*8));
    mNullFlag = 1UL << (position % (sizeof(unsigned long)*8));
    mOffset = offset;
  }
  std::size_t GetNullWord() const
  {
    return std::size_t(mNullWord);
  }
  std::size_t GetNullFlag() const
  {
    return std::size_t(mNullFlag);
  }
  std::size_t GetOffset() const
  {
    return mOffset;
  }
  void InternalSetLongValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    *((boost::int32_t *)(recordBuffer + mOffset)) = *((const boost::int32_t *)input);
  }
  void InternalSetBooleanValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    *((bool *)(recordBuffer + mOffset)) = *((const bool *)input);
  }
  void InternalSetDirectBigIntegerValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    *((boost::int64_t *)(recordBuffer + mOffset)) = *((const boost::int64_t *)input);
  }
  void InternalSetIndirectBigIntegerValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    *((boost::int64_t **)(recordBuffer + mOffset)) = mConstantPool->GetBigIntegerConstant(*((const boost::int64_t *)input));
  }
  void InternalSetDirectDoubleValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    *((double *)(recordBuffer + mOffset)) = *((const double *)input);
  }
  void InternalSetIndirectDoubleValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    *((double **)(recordBuffer + mOffset)) = mConstantPool->GetDoubleConstant(*((const double *)input));
  }
  void InternalSetIndirectStringValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    *((wchar_t **)(recordBuffer + mOffset)) = mConstantPool->GetWideStringConstant(((const wchar_t *)input));
  }
  METRAFLOW_DECL void InternalSetIndirectStringValue2(record_t recordBuffer, const void * input) const;
  void InternalSetDirectStringValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    wcscpy((wchar_t *)(recordBuffer + mOffset), (const wchar_t *)input);
  }
  void InternalSetIndirectUTF8StringValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    *((char **)(recordBuffer + mOffset)) = mConstantPool->GetUTF8StringConstant(((const char *)input));
  }
  void InternalSetIndirectUTF8StringValue2(record_t recordBuffer, const void * input) const
  {
    // TODO: add code to delete previous non-null value
    ClearNull(recordBuffer);
    const char * sourceValue = reinterpret_cast<const char *>(input);
    int len = strlen(sourceValue);
    char * targetValue = new char [len+1];
    memcpy(targetValue, sourceValue, sizeof(char)*(len + 1));
    *((char **)(recordBuffer + mOffset)) = targetValue;
  }
  void InternalSetDirectUTF8StringValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    strcpy((char *)(recordBuffer + mOffset), (const char *)input);
  }
  void InternalSetDirectDatetimeValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    *((date_time_traits::pointer)(recordBuffer + mOffset)) = *((date_time_traits::const_pointer)input);
  }
  void InternalSetIndirectDatetimeValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    *((date_time_traits::pointer*)(recordBuffer + mOffset)) = mConstantPool->GetDatetimeConstant(*((date_time_traits::const_pointer)input));
  }
  void InternalSetDirectDecimalValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    memcpy(recordBuffer + mOffset, input, sizeof(decimal_traits::value));
  }
  void InternalSetIndirectDecimalValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    *((decimal_traits::pointer*)(recordBuffer + mOffset)) = mConstantPool->GetDecimalConstant((decimal_traits::const_pointer)input);
  }
  void InternalSetDirectBinaryValue(record_t recordBuffer, const void * input) const
  {
    ClearNull(recordBuffer);
    memcpy(recordBuffer + mOffset, input, 16);
  }
  void InternalAppendIndirectRecordValue(record_t recordBuffer, const void * input) const;

  void SetNull(record_t recordBuffer) const
  {
    *((unsigned int *)(recordBuffer+mNullWord)) |= mNullFlag;
  }
  void ClearNull(record_t recordBuffer) const
  {
    *((unsigned int *)(recordBuffer+mNullWord)) &= ~mNullFlag;
  }
  const void * GetDirectBuffer(const_record_t recordBuffer) const
  {
    return recordBuffer + mOffset;
  }
  const void * GetIndirectBuffer(const_record_t recordBuffer) const
  {
    return *((const void **)(recordBuffer + mOffset));
  }
  bool GetNull(const_record_t recordBuffer) const
  {
    return (*((unsigned int *)(recordBuffer + mNullWord)) & mNullFlag) != 0;
  }
  void * InternalGetBufferEndLongValue(record_t recordBuffer) const
  {
    return ((long *)(recordBuffer + mOffset)) + 1;
  }
  void * InternalGetBufferEndBooleanValue(record_t recordBuffer) const
  {
    return ((bool *)(recordBuffer + mOffset)) + 1;
  }
  void * InternalGetBufferEndDirectBigIntegerValue(record_t recordBuffer) const
  {
    return ((boost::int64_t *)(recordBuffer + mOffset)) + 1;
  }
  void * InternalGetBufferEndIndirectBigIntegerValue(record_t recordBuffer) const
  {
    return *((boost::int64_t **)(recordBuffer + mOffset)) + 1;
  }
  void * InternalGetBufferEndDirectDoubleValue(record_t recordBuffer) const
  {
    return ((double *)(recordBuffer + mOffset)) + 1;
  }
  void * InternalGetBufferEndIndirectDoubleValue(record_t recordBuffer) const
  {
    return *((double **)(recordBuffer + mOffset)) + 1;
  }
  void * InternalGetBufferEndIndirectStringValue(record_t recordBuffer) const
  {
    PrefixedWideString * pws = (PrefixedWideString *)(recordBuffer+ mOffset);
    return reinterpret_cast<boost::uint8_t *> (pws->String) + pws->Length;
  }
  void * InternalGetBufferEndDirectStringValue(record_t recordBuffer) const
  {
    wchar_t * buf = (wchar_t *)(recordBuffer + mOffset);
    return buf + wcslen(buf) + 1;
  }
  void * InternalGetBufferEndIndirectUTF8StringValue(record_t recordBuffer) const
  {
    char * buf = *((char **)(recordBuffer + mOffset));
    return buf + strlen(buf) + 1;
  }
  void * InternalGetBufferEndDirectUTF8StringValue(record_t recordBuffer) const
  {
    char * buf = (char *)(recordBuffer + mOffset);
    return buf + strlen(buf) + 1;
  }
  void * InternalGetBufferEndDirectDatetimeValue(record_t recordBuffer) const
  {
    return ((date_time_traits::pointer)(recordBuffer + mOffset)) + 1;
  }
  void * InternalGetBufferEndIndirectDatetimeValue(record_t recordBuffer) const
  {
    return *((date_time_traits::pointer*)(recordBuffer + mOffset)) + 1;
  }
  void * InternalGetBufferEndDirectDecimalValue(record_t recordBuffer) const
  {
    return ((decimal_traits::pointer)(recordBuffer + mOffset)) + 1;
  }
  void * InternalGetBufferEndIndirectDecimalValue(record_t recordBuffer) const
  {
    return *((decimal_traits::pointer*)(recordBuffer + mOffset)) + 1;
  }
  void * InternalGetBufferEndDirectBinaryValue(record_t recordBuffer) const
  {
    return recordBuffer + mOffset + 16;
  }
  unsigned int InternalHashLongValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(long), initialValue);
  }
  unsigned int InternalHashBooleanValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(bool), initialValue);
  }
  unsigned int InternalHashDirectBigIntegerValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(boost::int64_t), initialValue);
  }
  unsigned int InternalHashIndirectBigIntegerValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(boost::int64_t), initialValue);
  }
  unsigned int InternalHashDirectDoubleValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(double), initialValue);
  }
  unsigned int InternalHashIndirectDoubleValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(double), initialValue);
  }
  unsigned int InternalHashIndirectStringValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(wchar_t)*(wcslen((const wchar_t *) GetIndirectBuffer(recordBuffer))+1), initialValue);
  }
  unsigned int InternalHashDirectStringValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(wchar_t)*(wcslen((const wchar_t *) GetDirectBuffer(recordBuffer))+1), initialValue);
  }
  unsigned int InternalHashIndirectUTF8StringValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(char)*(strlen((const char *) GetIndirectBuffer(recordBuffer))+1), initialValue);
  }
  unsigned int InternalHashDirectUTF8StringValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(char)*(strlen((const char *) GetDirectBuffer(recordBuffer))+1), initialValue);
  }
  unsigned int InternalHashDirectDatetimeValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(date_time_traits::value), initialValue);
  }
  unsigned int InternalHashIndirectDatetimeValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(date_time_traits::value), initialValue);
  }
  unsigned int InternalHashDirectDecimalValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(decimal_traits::value), initialValue);
  }
  unsigned int InternalHashIndirectDecimalValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(decimal_traits::value), initialValue);
  }
  unsigned int InternalHashDirectBinaryValue(const_record_t recordBuffer, unsigned int initialValue) const
  {
    return __hash((ub1 *)GetDirectBuffer(recordBuffer), 16, initialValue);
  }
};

class FieldAddressOffsetOrder
{
public:
  bool operator ()(const FieldAddress * lhs, const FieldAddress * rhs)
  {
    return lhs->GetOffset() < rhs->GetOffset();
  }
};

typedef void (FieldAddress::*FieldAddressSetter) (record_t, const void *) const;
typedef const void * (FieldAddress::*FieldAddressGetter) (const_record_t) const;
typedef unsigned int (FieldAddress::*HashFunction)(const_record_t, unsigned int) const;
typedef void (*ExportSortKeyFunction)(const void * buff, bool isNull, SortOrder::SortOrderEnum aSortOrder, SortKeyBuffer& sortKeyBuffer, int maxBytes);
typedef void * (FieldAddress::*BufferEndGetter) (record_t) const;
// Binary field methods
typedef bool (*EqualsFunction) (const void * lhs, const void * rhs);
typedef int (*CompareFunction) (const void * lhs, const void * rhs);

class RecordSerializerInstruction
{
public:
  enum Type { DIRECT_MEMCPY, INDIRECT_MEMCPY, INDIRECT_STRCPY, INDIRECT_WCSCPY, NESTED_RECORD_START, NESTED_RECORD_NEXT, NESTED_RECORD_END };
private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(Ty);
    ar & BOOST_SERIALIZATION_NVP(Len);
    ar & boost::serialization::make_nvp("Accessor", const_cast<RunTimeDataAccessor* &>(Accessor));
  }  

  RecordSerializerInstruction(Type ty, boost::int32_t len, const RunTimeDataAccessor * accessor)
    :
    Ty(ty),
    Len(len),
    Accessor(accessor)
  {
  }

public:
  Type Ty;
  boost::int32_t Len;
  const RunTimeDataAccessor * Accessor;

  RecordSerializerInstruction()
    :
    Ty(DIRECT_MEMCPY),
    Len(0),
    Accessor(NULL)
  {
  }
  /**
   * The minimum amount of buffer space required by this instruction.
   */
  boost::int32_t GetMinimumSize() const;
  static RecordSerializerInstruction DirectMemcpy(boost::int32_t len)
  {
    return RecordSerializerInstruction(DIRECT_MEMCPY,len, NULL);
  }
  static RecordSerializerInstruction IndirectMemcpy(boost::int32_t len, const RunTimeDataAccessor * accessor)
  {
    return RecordSerializerInstruction(INDIRECT_MEMCPY,len, accessor);
  }
  static RecordSerializerInstruction IndirectStrcpy(const RunTimeDataAccessor * accessor)
  {
    return RecordSerializerInstruction(INDIRECT_STRCPY,0,accessor);
  }
  static RecordSerializerInstruction IndirectWcscpy(const RunTimeDataAccessor * accessor)
  {
    return RecordSerializerInstruction(INDIRECT_WCSCPY,0,accessor);
  }
  static RecordSerializerInstruction NestedRecordStart(int len, const RunTimeDataAccessor * accessor)
  {
    return RecordSerializerInstruction(NESTED_RECORD_START ,len, accessor);
  }
  static RecordSerializerInstruction NestedRecordNext()
  {
    return RecordSerializerInstruction(NESTED_RECORD_NEXT, 0, NULL);
  }
  static RecordSerializerInstruction NestedRecordEnd(int len)
  {
    return RecordSerializerInstruction(NESTED_RECORD_END, len, NULL);
  }
};

class RecordDeserializerInstruction
{
public:
  enum Type { DIRECT_MEMCPY, ACCESSOR, NESTED_RECORD_START, NESTED_RECORD_END };

private:
  RecordDeserializerInstruction(Type ty, int len, const RunTimeDataAccessor * accessor)
    :
    Ty(ty),
    Len(len),
    Accessor(accessor)
  {
  }
  
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(Ty);
    ar & BOOST_SERIALIZATION_NVP(Len); 
    ar & boost::serialization::make_nvp("Accessor", const_cast<RunTimeDataAccessor* &>(Accessor));
 }  

public:
  Type Ty;
  int Len;
  const RunTimeDataAccessor * Accessor;

  RecordDeserializerInstruction()
    :
    Ty(DIRECT_MEMCPY),
    Len(0),
    Accessor(NULL)
  {
  }
  static RecordDeserializerInstruction DirectMemcpy(int len)
  {
    return RecordDeserializerInstruction(DIRECT_MEMCPY, len, NULL);
  }
  static RecordDeserializerInstruction IndirectSetValue(const RunTimeDataAccessor * accessor)
  {
    return RecordDeserializerInstruction(ACCESSOR, 0, accessor);
  }
  static RecordDeserializerInstruction NestedRecordStart(int len, const RunTimeDataAccessor * accessor)
  {
    return RecordDeserializerInstruction(NESTED_RECORD_START, len, accessor);
  }
  static RecordDeserializerInstruction NestedRecordEnd(int len, const RunTimeDataAccessor * accessor)
  {
    return RecordDeserializerInstruction(NESTED_RECORD_END, len, accessor);
  }
};

// Represents a storage mechanism for a logical data type.
class PhysicalFieldType
{
private:
  MTPipelineLib::PropValType mPipelineType;
  // Is this type stored by value in the buffer or by pointer indirection?
  bool mIsInline;
  // If an array structure, what is the length (this is 1 for scalar types).
  // This does not include terminator if used (e.g. strings).
  int mMaxLength;
  // What is the maximum number of bytes of storage (including terminator if used).
  int mMaxBytes;
  // For a nested record type this is the record format
  RecordMetadata * mNestedRecord;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mPipelineType);
    ar & BOOST_SERIALIZATION_NVP(mIsInline);
    ar & BOOST_SERIALIZATION_NVP(mMaxLength);
    ar & BOOST_SERIALIZATION_NVP(mMaxBytes);
    ar & BOOST_SERIALIZATION_NVP(mNestedRecord);
  }  
  PhysicalFieldType()
    :
    mPipelineType(MTPipelineLib::PROP_TYPE_INTEGER),
    mIsInline(true),
    mMaxLength(sizeof(int)),
    mMaxBytes(sizeof(int)),
    mNestedRecord(NULL)
  {
    // TODO: Enforce restrictions on inline storage (not supported for strings).
  }

  static bool DecimalEquals(const void * lhs, const void * rhs)
  {
    return decimal_traits::eq((decimal_traits::const_pointer)lhs, (decimal_traits::const_pointer)rhs);
  }
  static bool LongEquals(const void * lhs, const void * rhs)
  {
    return *((const boost::int32_t *)lhs) == *((const boost::int32_t *)rhs);
  }
  static bool BooleanEquals(const void * lhs, const void * rhs)
  {
    return *((const bool *)lhs) == *((const bool *)rhs);
  }
  static bool BigIntegerEquals(const void * lhs, const void * rhs)
  {
    return *((const boost::int64_t *)lhs) == *((const boost::int64_t *)rhs);
  }
  static bool DoubleEquals(const void * lhs, const void * rhs)
  {
    return *((const double *)lhs) == *((const double *)rhs);
  }
  static bool DatetimeEquals(const void * lhs, const void * rhs)
  {
    return *((date_time_traits::const_pointer)lhs) == *((date_time_traits::const_pointer)rhs);
  }
  static bool StringEquals(const void * lhs, const void * rhs)
  {
    // TODO: With our current string model, can't this be a pointer
    // comparison?
    return 0 == wcscmp((const wchar_t *)lhs, (const wchar_t *)rhs);
  }
  static bool UTF8StringEquals(const void * lhs, const void * rhs)
  {
    return 0 == strcmp((const char *)lhs, (const char *)rhs);
  }
  static bool BinaryEquals(const void * lhs, const void * rhs)
  {
    return 0 == memcmp(lhs, rhs, 16);
  }
  static int DecimalCompare(const void * lhs, const void * rhs)
  {
    return decimal_traits::cmp((decimal_traits::const_pointer) lhs, (decimal_traits::const_pointer) rhs);
  }
  static int LongCompare(const void * lhs, const void * rhs)
  {
    return *((const boost::int32_t *)lhs) < *((const boost::int32_t *)rhs) ? -1 : *((const boost::int32_t *)lhs) == *((const boost::int32_t *)rhs) ? 0 : 1;
  }
  static int BooleanCompare(const void * lhs, const void * rhs)
  {
    return *((const bool *)lhs) < *((const bool *)rhs) ? -1 : *((const bool *)lhs) == *((const bool *)rhs) ? 0 : 1;
  }
  static int BigIntegerCompare(const void * lhs, const void * rhs)
  {
    return *((const boost::int64_t *)lhs) < *((const boost::int64_t *)rhs) ? -1 : *((const boost::int64_t *)lhs) == *((const boost::int64_t *)rhs) ? 0 : 1;
  }
  static int DoubleCompare(const void * lhs, const void * rhs)
  {
    return *((const double *)lhs) < *((const double *)rhs) ? -1 : *((const double *)lhs) == *((const double *)rhs) ? 0 : 1;
  }
  static int DatetimeCompare(const void * lhs, const void * rhs)
  {
    return *((date_time_traits::const_pointer)lhs) < *((date_time_traits::const_pointer)rhs) ? -1 : *((date_time_traits::const_pointer)lhs) == *((date_time_traits::const_pointer)rhs) ? 0 : 1;
  }
  static int StringCompare(const void * lhs, const void * rhs)
  {
    // TODO: With our current string model, can't this be a pointer
    // comparison?
    return wcscmp((const wchar_t *)lhs, (const wchar_t *)rhs);
  }
  static int UTF8StringCompare(const void * lhs, const void * rhs)
  {
    return strcmp((const char *)lhs, (const char *)rhs);
  }
  static int BinaryCompare(const void * lhs, const void * rhs)
  {
    return memcmp(lhs, rhs, 16);
  }

  PhysicalFieldType(MTPipelineLib::PropValType pipelineType, bool isInline, int maxLength, int maxBytes)
    :
    mPipelineType(pipelineType),
    mIsInline(isInline),
    mMaxLength(maxLength),
    mMaxBytes(maxBytes),
    mNestedRecord(NULL)
  {
    // TODO: Enforce restrictions on inline storage (not supported for strings).
  }

  PhysicalFieldType(const RecordMetadata& nestedRecord, bool isList);
 
public:

  METRAFLOW_DECL PhysicalFieldType(const PhysicalFieldType& pft);
  METRAFLOW_DECL ~PhysicalFieldType();
  METRAFLOW_DECL bool operator==(const PhysicalFieldType & rhs) const;
  METRAFLOW_DECL bool operator!=(const PhysicalFieldType & rhs) const;

  static PhysicalFieldType Integer()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_INTEGER, true, 1, sizeof(int));
    return ty;
  }
  static PhysicalFieldType Enum()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_ENUM, true, 1, sizeof(int));
    return ty;
  }
  static PhysicalFieldType Boolean()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_BOOLEAN, 
                         true, 
                         1, 
                         sizeof(bool) < sizeof(int) ? sizeof(int) : sizeof(bool));
    return ty;
  }
  static PhysicalFieldType Datetime()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_DATETIME, true, 1, sizeof(date_time_traits::value));
    return ty;
  }
  static PhysicalFieldType DatetimeDomain()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_DATETIME, false, 1, sizeof(date_time_traits::value));
    return ty;
  }
  static PhysicalFieldType BigInteger()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_BIGINTEGER, true, 1, sizeof(boost::int64_t));
    return ty;
  }
  static PhysicalFieldType BigIntegerDomain()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_BIGINTEGER, false, 1, sizeof(boost::int64_t));
    return ty;
  }
  static PhysicalFieldType Double()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_DOUBLE, true, 1, sizeof(double));
    return ty;
  }
  static PhysicalFieldType DoubleDomain()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_DOUBLE, false, 1, sizeof(double));
    return ty;
  }
  static PhysicalFieldType String(int maxLength)
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_STRING, true, maxLength, (maxLength + 1)*sizeof(wchar_t));
    return ty;
  }
  static PhysicalFieldType StringDomain()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_STRING, false, (INT_MAX-1)/sizeof(wchar_t), INT_MAX);
    return ty;
  }
  static PhysicalFieldType UTF8String(int maxLength)
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_ASCII_STRING, true, maxLength, (maxLength + 1)*sizeof(char));
    return ty;
  }
  static PhysicalFieldType UTF8StringDomain()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_ASCII_STRING, false, (INT_MAX-1)/sizeof(char), INT_MAX);
    return ty;
  }
  static PhysicalFieldType Decimal()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_DECIMAL, true, 1, sizeof(decimal_traits::value));
    return ty;
  }
  static PhysicalFieldType DecimalDomain()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_DECIMAL, false, 1, sizeof(decimal_traits::value));
    return ty;
  }
  static PhysicalFieldType Binary()
  {
    PhysicalFieldType ty(MTPipelineLib::PROP_TYPE_OPAQUE, true, 16, 16);
    return ty;
  }
  METRAFLOW_DECL static PhysicalFieldType Record(const RecordMetadata& nestedRecord, bool isList=true);

  MTPipelineLib::PropValType GetPipelineType() const
  {
    return mPipelineType;
  }

  bool IsInline() const
  {
    return mIsInline;
  }

  int GetMaxBytes() const
  {
    return mMaxBytes;
  }

  int GetMaxLength() const
  {
    return mMaxLength;
  }

  std::wstring ToString() const;

  const RecordMetadata* GetMetadata() const
  {
    return mNestedRecord;
  }

  /**
   * Is this a list type?
   * Current data model doesn't really support lists of lists, but it isn't
   * hard to fake them out with a list of records with a single field that is a list type.
   */
  bool IsList() const
  {
    return mMaxLength > 1;
  }

  /** Get the MTSQL name for the accessor's physical field type. */
  static std::wstring GetMTSQLDatatype(DataAccessor * accessor);

  /** Get the MTSQL name for the physical field type. */
  static std::wstring GetMTSQLDatatype(MTPipelineLib::PropValType valType);

  METRAFLOW_DECL FieldAddressSetter GetFieldAddressSetter() const;
  METRAFLOW_DECL FieldAddressGetter GetFieldAddressGetter() const;
  METRAFLOW_DECL HashFunction GetHashFunction() const;
  METRAFLOW_DECL EqualsFunction GetEqualsFunction() const;
  METRAFLOW_DECL CompareFunction GetCompareFunction() const;
  METRAFLOW_DECL int GetColumnStorage() const;
  METRAFLOW_DECL ExportSortKeyFunction GetExportSortKeyFunction();
  METRAFLOW_DECL BufferEndGetter GetBufferEndGetter() const;
  METRAFLOW_DECL FieldAddressFree GetFreeFunction() const;
  METRAFLOW_DECL FieldAddressClone GetCloneFunction() const;
};


class BitcpyOperation
{
private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(Ty);
    ar & BOOST_SERIALIZATION_NVP(SourceOffset);
    ar & BOOST_SERIALIZATION_NVP(TargetOffset);
    ar & BOOST_SERIALIZATION_NVP(SourceBitmask);
    ar & BOOST_SERIALIZATION_NVP(Shift);
  }  
public:
  enum Type { BITCPY, BITCPY_R, BITCPY_L };
  Type Ty;
  boost::int32_t SourceOffset;
  boost::int32_t TargetOffset;
  std::size_t SourceBitmask;
  boost::int32_t Shift;
  BitcpyOperation()
    :
    Ty(BITCPY),
    SourceOffset(0),
    TargetOffset(0),
    SourceBitmask(0),
    Shift(0)
  {
  }
  BitcpyOperation(const BitcpyOperation& rhs)
    :
    Ty(rhs.Ty),
    SourceOffset(rhs.SourceOffset),
    TargetOffset(rhs.TargetOffset),
    SourceBitmask(rhs.SourceBitmask),
    Shift(rhs.Shift)
  {
  }
  BitcpyOperation(Type ty, boost::int32_t sourceOffset, boost::int32_t targetOffset, std::size_t sourceBitmask, boost::int32_t shift)
    :
    Ty(ty),
    SourceOffset(sourceOffset),
    TargetOffset(targetOffset),
    SourceBitmask(sourceBitmask),
    Shift(shift)
  {
  }
  BitcpyOperation& operator=(const BitcpyOperation& rhs)
  {
    Ty = rhs.Ty;
    SourceOffset = rhs.SourceOffset;
    TargetOffset = rhs.TargetOffset;
    SourceBitmask = rhs.SourceBitmask;
    Shift = rhs.Shift;
    return *this;
  }
};

class MemcpyOperation
{
private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(SourceOffset);
    ar & BOOST_SERIALIZATION_NVP(TargetOffset);
    ar & BOOST_SERIALIZATION_NVP(Sz);
  }  
public:
  boost::int32_t SourceOffset;
  boost::int32_t TargetOffset;
  boost::int32_t Sz;
  MemcpyOperation()
    :
    SourceOffset(0),
    TargetOffset(0),
    Sz(0)
  {
  }
  MemcpyOperation(const MemcpyOperation& rhs)
    :
    SourceOffset(rhs.SourceOffset),
    TargetOffset(rhs.TargetOffset),
    Sz(rhs.Sz)
  {
  }
  MemcpyOperation(boost::int32_t sourceOffset, boost::int32_t targetOffset, boost::int32_t sz)
    :
    SourceOffset(sourceOffset),
    TargetOffset(targetOffset),
    Sz(sz)
  {
  }
  MemcpyOperation& operator=(const MemcpyOperation& rhs)
  {
    SourceOffset = rhs.SourceOffset;
    TargetOffset = rhs.TargetOffset;
    Sz = rhs.Sz;
    return *this;
  }
};

// Operation for transferring a field between records.
// Note that the concept of transfer semantics is important 
// as it implies a transfer of ownership.  This supports important
// shallow copy optimizations.

class RunTimeDataAccessor : public FieldAddress
{
protected:
  // Essentially we are creating an "inline" v-table using
  // pointers to member functions.  This should save a memory
  // read and a cache line.
  // Yeah, this is a very low level optimization but I've measured
  // this and it matters quite a bit compared to a virtual function call (3x faster).
  FieldAddressSetter mSetter;
  FieldAddressGetter mGetter;
  HashFunction mHashFunction;
  ExportSortKeyFunction mExportSortKeyFunction;
  EqualsFunction mEqualsFunction;
  CompareFunction mCompareFunction;
  BufferEndGetter mBufferEndGetter;
  FieldAddressFree mFreeFunction;
  FieldAddressClone mCloneFunction;
  PhysicalFieldType mPhysicalType;

private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void save(Archive & ar, const unsigned int version) const
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(FieldAddress);
    ar & BOOST_SERIALIZATION_NVP(mPhysicalType);
  }  
  template<class Archive>
  void load(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(FieldAddress);
    ar & BOOST_SERIALIZATION_NVP(mPhysicalType);

    // Set up the "vtable"
    mSetter = mPhysicalType.GetFieldAddressSetter();
    mGetter = mPhysicalType.GetFieldAddressGetter();
    mHashFunction = mPhysicalType.GetHashFunction();
    mEqualsFunction = mPhysicalType.GetEqualsFunction();
    mCompareFunction = mPhysicalType.GetCompareFunction();
    mExportSortKeyFunction = mPhysicalType.GetExportSortKeyFunction();
    mBufferEndGetter = mPhysicalType.GetBufferEndGetter();
    mFreeFunction = mPhysicalType.GetFreeFunction();
    mCloneFunction = mPhysicalType.GetCloneFunction();
  }  
  BOOST_SERIALIZATION_SPLIT_MEMBER()

public:
  METRAFLOW_DECL RunTimeDataAccessor()
    :
    mSetter(NULL),
    mGetter(NULL),
    mHashFunction(NULL),
    mExportSortKeyFunction(NULL),
    mEqualsFunction(NULL),
    mCompareFunction(NULL),
    mBufferEndGetter(NULL),
    mFreeFunction(NULL),
    mCloneFunction(NULL),
    mPhysicalType(PhysicalFieldType::Integer())
  {
  }

  METRAFLOW_DECL RunTimeDataAccessor(ConstantPoolFactory * constantPool, long position, long offset, 
                                const PhysicalFieldType& physicalType);
  METRAFLOW_DECL RunTimeDataAccessor(const RunTimeDataAccessor & da)
    :
    FieldAddress(da),
    mSetter(da.mSetter),
    mGetter(da.mGetter),
    mHashFunction(da.mHashFunction),
    mExportSortKeyFunction(da.mExportSortKeyFunction),
    mEqualsFunction(da.mEqualsFunction),
    mCompareFunction(da.mCompareFunction),
    mBufferEndGetter(da.mBufferEndGetter),
    mFreeFunction(da.mFreeFunction),
    mCloneFunction(da.mCloneFunction),
    mPhysicalType(da.mPhysicalType)
  {
  }    

  RunTimeDataAccessor& operator= (const RunTimeDataAccessor& da)
  {
    this->FieldAddress::operator=(da);
    mSetter=da.mSetter;
    mGetter=da.mGetter;
    mHashFunction=da.mHashFunction;
    mEqualsFunction=da.mEqualsFunction;
    mCompareFunction=da.mCompareFunction;
    mPhysicalType=da.mPhysicalType;
    mExportSortKeyFunction=da.mExportSortKeyFunction;
    mBufferEndGetter=da.mBufferEndGetter;
    mFreeFunction=da.mFreeFunction;
    mCloneFunction=da.mCloneFunction;
    return *this;
  }

  void InternalFreeIndirectRecordValue(record_t recordBuffer) const;
  void InternalFreeIndirectStringValue(record_t recordBuffer) const;
  void InternalFreeIndirectUTF8StringValue(record_t recordBuffer) const;
  void InternalCloneIndirectRecordValue(const_record_t source, record_t target) const;
  void InternalCloneIndirectStringValue(const_record_t source, record_t target) const;
  void InternalCloneIndirectUTF8StringValue(const_record_t source, record_t target) const;

  void SetValue(record_t recordBuffer, const void * val) const
  {
    (this->*mSetter)(recordBuffer, val);
  }
  const void * GetValue(const_record_t recordBuffer) const
  {
    return (this->*mGetter)(recordBuffer);
  }
  unsigned int Hash(const_record_t recordBuffer, unsigned int initialValue) const
  {
    // make sure null hashes consistently
    return this->GetNull(recordBuffer) ? initialValue : (this->*mHashFunction)(recordBuffer, initialValue);
  }
  void ExportSortKey(const_record_t recordBuffer, SortOrder::SortOrderEnum aSortOrder, SortKeyBuffer& sortKeyBuffer) const
  {
	  return (*mExportSortKeyFunction)(this->GetValue(recordBuffer), 
                                     this->GetNull(recordBuffer), 
                                     aSortOrder, 
                                     sortKeyBuffer, 
                                     mPhysicalType.GetMaxBytes());
  }
  bool Equals(const_record_t recordBuffer, const RunTimeDataAccessor * rhs, const_record_t rhsBuffer) const
  {
    return !this->GetNull(recordBuffer) && !rhs->GetNull(rhsBuffer) && (*mEqualsFunction)((this->GetValue(recordBuffer)), rhs->GetValue(rhsBuffer));
  }
  int Compare(const_record_t recordBuffer, const RunTimeDataAccessor * rhs, const_record_t rhsBuffer) const
  {
    return (*mCompareFunction)((this->GetValue(recordBuffer)), rhs->GetValue(rhsBuffer));
  }
  void * GetBufferEnd(record_t recordBuffer) const
  {
    return (this->*mBufferEndGetter)(recordBuffer);
  }
  const PhysicalFieldType * GetPhysicalFieldType() const
  {
    return &mPhysicalType;
  }
  void SetLongValue(record_t recordBuffer, boost::int32_t val) const
  {
    this->SetValue(recordBuffer, &val);
  }
  void SetEnumValue(record_t recordBuffer, boost::int32_t val) const
  {
    this->SetValue(recordBuffer, &val);
  }
  void SetStringValue(record_t recordBuffer, const wchar_t * val) const
  {
    this->SetValue(recordBuffer, val);
  }
  void SetUTF8StringValue(record_t recordBuffer, const char * val) const
  {
    this->SetValue(recordBuffer, val);
  }
  void SetBooleanValue(record_t recordBuffer, bool val) const
  {
    this->SetValue(recordBuffer, &val);
  }
  void SetBigIntegerValue(record_t recordBuffer, boost::int64_t val) const
  {
    this->SetValue(recordBuffer, &val);
  }
  void SetDoubleValue(record_t recordBuffer, double val) const
  {
    this->SetValue(recordBuffer, &val);
  }
  void SetDatetimeValue(record_t recordBuffer, date_time_traits::value val) const
  {
    this->SetValue(recordBuffer, &val);
  }
  void SetDecimalValue(record_t recordBuffer, decimal_traits::const_pointer val) const
  {
    this->SetValue(recordBuffer, val);
  }
  void SetBinaryValue(record_t recordBuffer, const unsigned char * val) const
  {
    this->SetValue(recordBuffer, val);
  }
  boost::int32_t GetLongValue(const_record_t recordBuffer) const
  {
    return *((const boost::int32_t *)(this->GetValue(recordBuffer)));
  }
  boost::int32_t GetEnumValue(const_record_t recordBuffer) const
  {
    return *((const boost::int32_t *)this->GetValue(recordBuffer));
  }
  const wchar_t * GetStringValue(const_record_t recordBuffer) const
  {
    return (const wchar_t *) (this->GetValue(recordBuffer));
  }
  const char * GetUTF8StringValue(const_record_t recordBuffer) const
  {
    return (const char *) (this->GetValue(recordBuffer));
  }
  bool GetBooleanValue(const_record_t recordBuffer) const
  {
    return *((const bool *)this->GetValue(recordBuffer));
  }
  boost::int64_t GetBigIntegerValue(const_record_t recordBuffer) const
  {
    return *((const boost::int64_t *)this->GetValue(recordBuffer));
  }
  double GetDoubleValue(const_record_t recordBuffer) const
  {
    return *((const double *)this->GetValue(recordBuffer));
  }
  date_time_traits::value GetDatetimeValue(const_record_t recordBuffer) const
  {
    return *((date_time_traits::const_pointer)this->GetValue(recordBuffer));
  }
  decimal_traits::const_pointer GetDecimalValue(const_record_t recordBuffer) const
  {
    return (decimal_traits::const_pointer)(this->GetValue(recordBuffer));
  }
  const unsigned char * GetBinaryValue(const_record_t recordBuffer) const
  {
    return (const unsigned char *)(this->GetValue(recordBuffer));
  }
  const_record_t GetRecordValue(const_record_t recordBuffer) const
  {
    return (const_record_t) (this->GetValue(recordBuffer));
  }
  void Free(record_t recordBuffer) const
  {
    (this->*mFreeFunction)(recordBuffer);
  }
  void Clone(const_record_t source, record_t target) const
  {
    (this->*mCloneFunction)(source, target);
  }
  bool IsSortable() const
  {
    return mExportSortKeyFunction != NULL;
  }
  METRAFLOW_DECL RecordSerializerInstruction GetRecordSerializerInstruction() const;
  METRAFLOW_DECL RecordDeserializerInstruction GetRecordDeserializerInstruction() const;

  static METRAFLOW_DECL BitcpyOperation GetBitcpyOperation(const RunTimeDataAccessor& source, const RunTimeDataAccessor& target);
  static METRAFLOW_DECL MemcpyOperation GetMemcpyOperation(const RunTimeDataAccessor& source, const RunTimeDataAccessor& target);
};

// The following operation is a copy of fields.  The source retains
// its reference to the field value.
class FieldCopy
{
private:
  typedef void (FieldCopy::*FieldCopyFunc)(const_record_t, record_t) const;
  RunTimeDataAccessor mSource;
  RunTimeDataAccessor mTarget;
  FieldCopyFunc mCopyFunction;
  METRAFLOW_DECL void SetupCopyFunction();
  METRAFLOW_DECL void InternalCopyIndirectRecordValue(const_record_t source, record_t target) const;
  METRAFLOW_DECL void InternalCopyIndirectStringValue(const_record_t source, record_t target) const;
  METRAFLOW_DECL void InternalCopyIndirectUTF8StringValue(const_record_t source, record_t target) const;
  FieldCopy()
  {
  }

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void save(Archive & ar, const unsigned int version) const
  {
    ar & BOOST_SERIALIZATION_NVP(mSource);
    ar & BOOST_SERIALIZATION_NVP(mTarget);
  }  
  template<class Archive>
  void load(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_NVP(mSource);
    ar & BOOST_SERIALIZATION_NVP(mTarget);

    // Set up the "vtable"
    SetupCopyFunction();
  }  
  BOOST_SERIALIZATION_SPLIT_MEMBER()

public:
  METRAFLOW_DECL FieldCopy(const RunTimeDataAccessor& source, const RunTimeDataAccessor& target);
  METRAFLOW_DECL ~FieldCopy();
  // Can this be optimized to a memcpy (value semantics)?
  METRAFLOW_DECL bool IsMemcpy() const;
  void Copy(const_record_t source, record_t target) const
  {
    (this->*mCopyFunction)(source, target);
  }
};

// The following operation is a transfer of ownership of a field
// from one record to another.
class FieldTransfer
{
private:
  typedef void (FieldTransfer::*FieldTransferFunc)(record_t, record_t) const;
  RunTimeDataAccessor mSource;
  RunTimeDataAccessor mTarget;
  FieldTransferFunc mTransferFunction;
  METRAFLOW_DECL void SetupTransferFunction();
  METRAFLOW_DECL void InternalTransferIndirectValue(record_t source, record_t target) const;
  FieldTransfer()
  {
  }

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void save(Archive & ar, const unsigned int version) const
  {
    ar & BOOST_SERIALIZATION_NVP(mSource);
    ar & BOOST_SERIALIZATION_NVP(mTarget);
  }  
  template<class Archive>
  void load(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_NVP(mSource);
    ar & BOOST_SERIALIZATION_NVP(mTarget);

    // Set up the "vtable"
    SetupTransferFunction();
  }  
  BOOST_SERIALIZATION_SPLIT_MEMBER()

public:
  METRAFLOW_DECL FieldTransfer(const RunTimeDataAccessor& source, const RunTimeDataAccessor& target);
  METRAFLOW_DECL ~FieldTransfer();
  // Can this be optimized to a memcpy (value semantics)?
  METRAFLOW_DECL bool IsMemcpy() const;
  void Transfer(record_t source, record_t target) const
  {
    (this->*mTransferFunction)(source, target);
  }
};

class DataAccessor : public RunTimeDataAccessor
{
protected:
  std::wstring mName;

private:
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeDataAccessor);
    ar & BOOST_SERIALIZATION_NVP(mName);
  }  

protected:
  DataAccessor()
    :
    mName(L"")
  {
  }

public:
  METRAFLOW_DECL DataAccessor(ConstantPoolFactory * constantPool, long position, long offset, const PhysicalFieldType& physicalType, const std::wstring& name);
  METRAFLOW_DECL DataAccessor(const DataAccessor & da)
    :
    RunTimeDataAccessor(da),
    mName(da.mName)
  {
  }    
  METRAFLOW_DECL DataAccessor(const DataAccessor & da, const std::wstring& newName)
    :
    RunTimeDataAccessor(da),
    mName(newName)
  {
  }    

  DataAccessor& operator= (const DataAccessor& da)
  {
    this->RunTimeDataAccessor::operator=(da);
    mName=da.mName;
    return *this;
  }
  std::wstring GetName() const
  {
    return mName;
  }
  std::wstring ToString() const;
};





class DatabaseColumn : public DataAccessor
{ 
protected:
  // Is the constant value required.  Used during loading.
  bool mIsRequired;
  // Position of the referenced const data in the database. 
  long mColumnPosition;
  std::wstring mEnumNamespace;
  std::wstring mEnumEnumeration;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DataAccessor);
    ar & BOOST_SERIALIZATION_NVP(mIsRequired);
    ar & BOOST_SERIALIZATION_NVP(mColumnPosition);
    ar & BOOST_SERIALIZATION_NVP(mEnumNamespace);
    ar & BOOST_SERIALIZATION_NVP(mEnumEnumeration);
  }  
  DatabaseColumn()
    :
    mIsRequired(false),
    mColumnPosition(0),
    mEnumNamespace(L""),
    mEnumEnumeration(L"")
  {
  }

public:
  METRAFLOW_DECL DatabaseColumn(ConstantPoolFactory * ruleSet, 
                           const PhysicalFieldType & physicalFieldType,
                           bool isRequired, long position, long columnPosition, long offset, const std::wstring& name);
  METRAFLOW_DECL DatabaseColumn(ConstantPoolFactory * ruleSet, 
                           const std::wstring& enumNamespace, const std::wstring& enumEnumeration,
                           bool isRequired, long position, long columnPosition, long offset, const std::wstring& name);
  METRAFLOW_DECL DatabaseColumn(const DatabaseColumn& dc)
    :
    DataAccessor(dc),
    mIsRequired(dc.mIsRequired),
    mColumnPosition(dc.mColumnPosition),
    mEnumNamespace(dc.mEnumNamespace),
    mEnumEnumeration(dc.mEnumEnumeration)
  {
  }
  METRAFLOW_DECL DatabaseColumn(const DatabaseColumn& dc, const std::wstring& newName)
    :
    DataAccessor(dc, newName),
    mIsRequired(dc.mIsRequired),
    mColumnPosition(dc.mColumnPosition),
    mEnumNamespace(dc.mEnumNamespace),
    mEnumEnumeration(dc.mEnumEnumeration)
  {
  }
  METRAFLOW_DECL virtual ~DatabaseColumn() {}
  METRAFLOW_DECL ConstantPoolFactory * GetConstantPool() const { return mConstantPool; }
  METRAFLOW_DECL const PhysicalFieldType& GetFieldType() const { return mPhysicalType; }
  METRAFLOW_DECL MTPipelineLib::PropValType GetColumnType() const { return mPhysicalType.GetPipelineType(); }
  METRAFLOW_DECL const wchar_t * GetColumnNamespace() const { return mEnumNamespace.c_str(); }
  METRAFLOW_DECL const wchar_t * GetColumnEnumeration() const { return mEnumEnumeration.c_str(); }
  METRAFLOW_DECL bool IsRequired() const { return mIsRequired; }
  METRAFLOW_DECL int GetColumnStorage() const
  {
    return mPhysicalType.GetColumnStorage();
  }
};

class ShallowFreeException : public std::runtime_error
{
public:
  METRAFLOW_DECL ShallowFreeException();
  METRAFLOW_DECL ~ShallowFreeException();
};

template <class _DatabaseColumn>
class MetadataCollection
{
protected:
  std::vector<_DatabaseColumn *> mVector;
  std::map<std::wstring, int> mNameIndex;
  int mRecordLength;
  std::vector<std::size_t> mNestedColumns;
  int mNumColumns;
  LogicalRecord * mLogicalRecord;

  /**
   * GetBitmapLengthWords
   */
  static int GetBitmapLengthWords(int numColumns)
  {
    // One bit for each field
    // One bit for End of Stream
    // One bit for End of Group
    // Round the sum of these up to the next multiple of the number of bits in a long.
    return (numColumns + 1 + 8*sizeof(long))/(8*sizeof(long));
  }

  void Reorder()
  {
    // Change the physical layout so that all direct storage fields are in
    // a leading buffer at the front of the record.
    std::vector<_DatabaseColumn *> directFields;
    std::vector<_DatabaseColumn *> indirectFields;
    for(std::vector<_DatabaseColumn *>::iterator it = mVector.begin();
        it != mVector.end();
        ++it)
    {
      if ((*it)->GetPhysicalFieldType()->IsInline())
      {
        directFields.push_back(*it);
      }
      else
      {
        indirectFields.push_back(*it);
      }
    }
    
    long position=0;
    long offset = GetBitmapLengthBytes()+sizeof(void*);
    for(std::vector<_DatabaseColumn *>::iterator it = directFields.begin();
        it != directFields.end();
        ++it)
    {
      (*it)->Update(position++, offset);
      offset += (*it)->GetColumnStorage();
    }
    for(std::vector<_DatabaseColumn *>::iterator it = indirectFields.begin();
        it != indirectFields.end();
        ++it)
    {
      (*it)->Update(position++, offset);
      offset += (*it)->GetColumnStorage();
    }

    ASSERT(offset == GetRecordLength());
  }

  static unsigned int hashfunc(const unsigned char * s, int len)
  {
    const unsigned char * end = s+len;
    unsigned int n = 0;
    for(; s<end; s++)
    {
      n = 31*n + *s;
    }
    return n;
  }
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void save(Archive & ar, const unsigned int version) const
  {
    ar & BOOST_SERIALIZATION_NVP(mVector);
    ar & BOOST_SERIALIZATION_NVP(mNameIndex);
    ar & BOOST_SERIALIZATION_NVP(mRecordLength);    
    ar & BOOST_SERIALIZATION_NVP(mNumColumns); 
    ar & BOOST_SERIALIZATION_NVP(mNestedColumns);    
    ar & BOOST_SERIALIZATION_NVP(mLogicalRecord);    
  }  
  template<class Archive>
  void load(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_NVP(mVector);
    ar & BOOST_SERIALIZATION_NVP(mNameIndex);
    ar & BOOST_SERIALIZATION_NVP(mRecordLength);    
    ar & BOOST_SERIALIZATION_NVP(mNumColumns); 
    ar & BOOST_SERIALIZATION_NVP(mNestedColumns);    
    ar & BOOST_SERIALIZATION_NVP(mLogicalRecord);    

    // If completely constructed, get the slaballocator
  }  
  BOOST_SERIALIZATION_SPLIT_MEMBER()
//   template<class Archive>
//   void serialize(Archive & ar, const unsigned int version) 
//   {
//     ar & BOOST_SERIALIZATION_NVP(mVector);
//     ar & BOOST_SERIALIZATION_NVP(mNameIndex);
//     ar & BOOST_SERIALIZATION_NVP(mRecordLength);    
//   }  

  void Clear()
  {
    for(typename std::vector<_DatabaseColumn *>::iterator it = mVector.begin();
        it != mVector.end();
        it++)
    {
      delete *it;
    }
    mVector.clear();
    mNameIndex.clear();

    mNestedColumns.clear();
    delete mLogicalRecord;
    mLogicalRecord = NULL;
  }

  void Clear(record_t recordBuffer) const
  {
//     memset(recordBuffer, 0, GetRecordLength());
    SetNext(recordBuffer, NULL);
    memset(recordBuffer + GetBitmapOffset(), 0xff, GetBitmapLength()*sizeof(long)); 
  }

  record_t InternalAllocateRecord() const
  {
      return (record_t) new unsigned char [GetRecordLength()];
  }

  void InternalFreeRecord(record_t recordBuffer) const
  {
      delete [] recordBuffer;
  }

  class PrePhysicalMember
  {
  public:
    PrePhysicalMember(const RecordMember * member,
                      const PhysicalFieldType & pft,
                      const std::wstring& prefix)
      :
      Member(member),
      PhysicalType(pft),
      Name(prefix + member->GetName())
    {
    }
    const RecordMember* Member;
    PhysicalFieldType PhysicalType;
    std::wstring Name;
  };

  void CollectLogicalToPhysical(const LogicalRecord& members,
                                std::vector<PrePhysicalMember*>& fixedLengthMembers,
                                std::vector<PrePhysicalMember*>& variableLengthMembers,
                                const std::wstring& fieldPrefix)
  {
    for(LogicalRecord::const_iterator it=members.begin();
        it != members.end();
        ++it)
    {
      switch(it->GetType().GetPipelineType())
      {
      case MTPipelineLib::PROP_TYPE_INTEGER:
      {
        fixedLengthMembers.push_back(
          new PrePhysicalMember(&(*it),
                                PhysicalFieldType::Integer(),
                                fieldPrefix));
        break;
      }
      case MTPipelineLib::PROP_TYPE_ENUM:
      {
        fixedLengthMembers.push_back(
          new PrePhysicalMember(&(*it),
                                PhysicalFieldType::Enum(),
                                fieldPrefix));
        break;
      }
      case MTPipelineLib::PROP_TYPE_BOOLEAN:
      {
        fixedLengthMembers.push_back(
          new PrePhysicalMember(&(*it),
                                PhysicalFieldType::Boolean(),
                                fieldPrefix));
        break;
      }
      case MTPipelineLib::PROP_TYPE_DATETIME:
      {
        fixedLengthMembers.push_back(
          new PrePhysicalMember(&(*it),
                                PhysicalFieldType::Datetime(),
                                fieldPrefix));
        break;
      }
      case MTPipelineLib::PROP_TYPE_BIGINTEGER:
      {
        fixedLengthMembers.push_back(
          new PrePhysicalMember(&(*it),
                                PhysicalFieldType::BigInteger(),
                                fieldPrefix));
        break;
      }
      case MTPipelineLib::PROP_TYPE_DOUBLE:
      {
        fixedLengthMembers.push_back(
          new PrePhysicalMember(&(*it),
                                PhysicalFieldType::Double(),
                                fieldPrefix));
        break;
      }
      case MTPipelineLib::PROP_TYPE_DECIMAL:
      {
        fixedLengthMembers.push_back(
          new PrePhysicalMember(&(*it),
                                PhysicalFieldType::Decimal(),
                                fieldPrefix));
        break;
      }
      case MTPipelineLib::PROP_TYPE_OPAQUE:
      {
        fixedLengthMembers.push_back(
          new PrePhysicalMember(&(*it),
                                PhysicalFieldType::Binary(),
                                fieldPrefix));
        break;
      }
      case MTPipelineLib::PROP_TYPE_ASCII_STRING:
      {
        variableLengthMembers.push_back(
          new PrePhysicalMember(&(*it),
                                PhysicalFieldType::UTF8StringDomain(),
                                fieldPrefix));
        break;
      }
      case MTPipelineLib::PROP_TYPE_STRING:
      case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
      {
        variableLengthMembers.push_back(
          new PrePhysicalMember(&(*it),
                                PhysicalFieldType::StringDomain(),
                                fieldPrefix));
        break;
      }
      case MTPipelineLib::PROP_TYPE_SET:
      {
        if(it->GetType().IsList())
        {
          RecordMetadata nested(it->GetType().GetMetadata());
          // The nested collection is also represented in the current buffer
          // with a list pointer.
          variableLengthMembers.push_back(
            new PrePhysicalMember(&(*it),
                                  PhysicalFieldType::Record(nested),
                                  fieldPrefix));
          
        }
        else
        {
          // Descend.  No direct representation of the nested record
          // in the buffer; only its fields.
          CollectLogicalToPhysical(it->GetType().GetMetadata(), 
                                   fixedLengthMembers, 
                                   variableLengthMembers,
                                   fieldPrefix + it->GetName() + L".");
        }
        break;
      }
      }
    }
  }                             

public:

  MetadataCollection()
    :
    mRecordLength(0),
    mNumColumns(0),
    mLogicalRecord(NULL)
  {
  }
  MetadataCollection(const MetadataCollection& mc)
    :
    mNameIndex (mc.mNameIndex),
    mRecordLength(mc.mRecordLength),
    mNestedColumns(mc.mNestedColumns),
    mNumColumns(mc.mNumColumns),
    mLogicalRecord(NULL)
  {
    for(typename std::vector<_DatabaseColumn *>::const_iterator it = mc.mVector.begin();
        it != mc.mVector.end();
        it++)
    {
      mVector.push_back(new _DatabaseColumn(**it));
    }
    if (mc.mLogicalRecord)
      mLogicalRecord = new LogicalRecord(*mc.mLogicalRecord);
  }

  // MetadataCollection(const MetadataCollection& mc,
  //                    const std::map<std::wstring,std::wstring>& renaming)
  //   :
  //   mRecordLength(0),
  //   mNumColumns(0),
  //   mLogicalRecord(NULL)
  // {
  //   Init(mc.GetNumColumns());

  //   // Convert renaming to case insensitive.
  //   std::map<std::wstring,std::wstring> ciRenaming;
  //   for(std::map<std::wstring,std::wstring>::const_iterator ciit = renaming.begin();
  //       ciit != renaming.end();
  //       ++ciit)
  //   {
  //     ciRenaming[boost::to_upper_copy<std::wstring>(ciit->first)] = ciit->second;
  //   }
  //   for(int i=0; i<mc.GetNumColumns(); i++)
  //   {
  //     std::map<std::wstring,std::wstring>::const_iterator it = 
  //       ciRenaming.find(boost::to_upper_copy<std::wstring>(mc.GetColumnName(i)));
  //     std::wstring nm = it == ciRenaming.end() ? mc.GetColumnName(i) : it->second;
  //     this->Add(nm, new _DatabaseColumn(*mc.GetColumn(i), nm));
  //   }

  //   if (mc.mLogicalRecord)
  //   {
  //     mLogicalRecord = new LogicalRecord();
  //     std::vector<std::wstring> ignore;
  //     mc.mLogicalRecord->Rename(renaming, *mLogicalRecord, ignore);      
  //   }
  // }

  MetadataCollection(const LogicalRecord& members)
    :
    mLogicalRecord(NULL)
  {
    // Make a copy of the logical record.
    mLogicalRecord = new LogicalRecord(members);

    // Algorithm for creating physical record/buffer format is:
    // Nested record (or fixed length collections when supported) are lifted into parent buffer.
    // Strings are stored in their own buffers and parent buffer has a pointer and length field.
    // Nested record collections get their own buffer and parent buffer has a pointer
    // to nested collection buffer. (Should we add a length/count field to the parent?)
    // All fixed length fields are stored contiguously, all variable length stored after.
    // For example,
    // Record(a INTEGER, b RECORD(c NVARCHAR, d INTEGER), e NVARCHAR, f INTEGER)
    // is stored as
    // Buffer(a,b.d,f,b.c,e) 
    std::vector<PrePhysicalMember*> fixedLengthMembers;
    std::vector<PrePhysicalMember*> variableLengthMembers;
    CollectLogicalToPhysical(members, fixedLengthMembers, variableLengthMembers, L"");

    boost::int32_t i = 0;
    Init(fixedLengthMembers.size() + variableLengthMembers.size());
    for(std::vector<PrePhysicalMember*>::const_iterator it = fixedLengthMembers.begin();
        it != fixedLengthMembers.end();
        ++it)
    {
      _DatabaseColumn * db = new _DatabaseColumn(GlobalConstantPoolFactory::Get(), 
                                                 (*it)->PhysicalType, 
                                                 false, 
                                                 i, 
                                                 i, 
                                                 GetRecordLength(), 
                                                 (*it)->Name);
      Add((*it)->Name, db);
      i += 1;
    }
    for(std::vector<PrePhysicalMember*>::const_iterator it = variableLengthMembers.begin();
        it != variableLengthMembers.end();
        ++it)
    {
      _DatabaseColumn * db = new _DatabaseColumn(GlobalConstantPoolFactory::Get(), 
                                                 (*it)->PhysicalType, 
                                                 false, 
                                                 i, 
                                                 i, 
                                                 GetRecordLength(), 
                                                 (*it)->Name);
      Add((*it)->Name, db);
      i += 1;
    }
  }

  virtual ~MetadataCollection()
  {
    Clear();
  }

  MetadataCollection& operator=(const MetadataCollection& mc)
  {
    Clear();
    mNameIndex=mc.mNameIndex;
    mRecordLength=mc.mRecordLength;
    mNumColumns=mc.mNumColumns;
    for(typename std::vector<_DatabaseColumn *>::const_iterator it = mc.mVector.begin();
        it != mc.mVector.end();
        it++)
    {
      mVector.push_back(new _DatabaseColumn(**it));
    }
    mNestedColumns = mc.mNestedColumns;
    if (mc.mLogicalRecord)
      mLogicalRecord = new LogicalRecord(*mc.mLogicalRecord);
    return *this;
  }

  /**
   * Returns true if the two collections have same fields with the same
   * physical type in the same logical order.
   * Note that this not the same as having the same physical layout since
   * two records which differ by a variable length field may have the same
   * physical layout but will not pass the LogicalEquals test.
   */
  bool LogicalEquals(const MetadataCollection& rhs) const
  {
    if (GetNumColumns() != rhs.GetNumColumns())
    {
      return false;
    }

    for(int i =0; i<GetNumColumns(); i++)
    {
      if ((boost::to_upper_copy(GetColumn(i)->GetName()) !=
           boost::to_upper_copy(rhs.GetColumn(i)->GetName())) ||
          (*GetColumn(i)->GetPhysicalFieldType() != 
           *rhs.GetColumn(i)->GetPhysicalFieldType()))
      {
        return false;
      }
    }
    return true;
  }

  // The record metadata starts with a linked list pointer and a null bitmap
  // with one bit per column.  A set bit indicates a null value for the column.
  // At the end of the bit-map is an additional EOF indicator bit and an additional GroupChange bit.
  // For EOF bit:
  // If 0, then EOF.  This Not-EOF bit is initially 1 and is only cleared 
  // by AllocateEOF().   
  // For GroupChange bit:
  // If 0, then GroupChange message.  The not-GroupChange bit is initially 1 and is cleared
  // by AllocateGroupChange().  Note that a group change message will carry key values.
  // Initialize record length to make room for these.
protected:
  void Init(int numColumns)
  {
    ASSERT(mVector.size() == 0);
    mRecordLength = GetBitmapLengthWords(numColumns)*sizeof(long)+sizeof(void*);
    mNumColumns = numColumns;
    // If completely constructed, get the slaballocator
    // if (mNumColumns == mVector.size())
    // {
    //   Reorder();
    // }
  }
public:
  
  /**
   * Returns the logical record format from which this record was created.
   * If this record is uninitialized, returns empty LogicalRecord.
   */
  const LogicalRecord& GetLogicalRecord() const
  {
    return mLogicalRecord != NULL ? *mLogicalRecord : LogicalRecord::Get();
  }

  void Add(const std::wstring& name, _DatabaseColumn * db)
  {
    if(db->GetPhysicalFieldType()->GetPipelineType() == MTPipelineLib::PROP_TYPE_SET &&
       !db->GetPhysicalFieldType()->IsList())
    {
      const RecordMetadata * rec = db->GetPhysicalFieldType()->GetMetadata();
      for(int i=0; i<rec->GetNumColumns(); i++)
      {
        std::wstring newName = name + L"." + rec->GetColumn(i)->GetName();
        Add(newName, new _DatabaseColumn (*rec->GetColumn(i), newName));
      }
    }
    else
    {
      mVector.push_back(db);
      // We want case insensitive indexing.
      mNameIndex[boost::to_upper_copy<std::wstring>(name)] = mVector.size() - 1;
      mRecordLength += db->GetColumnStorage();
      if (db->GetPhysicalFieldType()->GetPipelineType() == MTPipelineLib::PROP_TYPE_SET 
          || db->GetPhysicalFieldType()->GetPipelineType() == MTPipelineLib::PROP_TYPE_STRING
          || db->GetPhysicalFieldType()->GetPipelineType() == MTPipelineLib::PROP_TYPE_UNICODE_STRING
          || db->GetPhysicalFieldType()->GetPipelineType() == MTPipelineLib::PROP_TYPE_ASCII_STRING
        )
      {
        mNestedColumns.push_back(mVector.size() - 1);
      }
      // If completely constructed, get the slaballocator
      // if (mNumColumns == mVector.size())
      // {
      //   Reorder();
      // }
    }
  }
  int GetRecordLength() const
  {
    return mRecordLength;
  }

  /** Return an allocated record.  Null bits cleared and marked as not-EOF. */
  record_t Allocate() const
  {
    record_t tmp = InternalAllocateRecord();
    Clear(tmp);
    return tmp;
  }
  
  /** Return a record indicating EOF.  */
  record_t AllocateEOF() const
  {
    record_t tmp = InternalAllocateRecord();
    Clear(tmp);
    // The EOF Change bit is in the bit position GetNumColumns();
    boost::uint32_t nullWord = (mNumColumns / 32);
    boost::uint32_t nullFlag = (1UL << (mNumColumns % 32));
    boost::uint32_t * bm = reinterpret_cast<boost::uint32_t *>(tmp + GetBitmapOffset());
    bm[nullWord] &= ~nullFlag;
    return tmp;
  }

  /** Return true if the given record indicates EOF */
  bool IsEOF(const_record_t recordBuffer) const
  {
    // The EOF bit is in the bit position GetNumColumns();
    boost::uint32_t nullWord = (mNumColumns / 32);
    boost::uint32_t nullFlag = (1UL << (mNumColumns % 32));    
    const boost::uint32_t * bm = reinterpret_cast<const boost::uint32_t *>(recordBuffer + GetBitmapOffset());
    // We just need to check if the not-EOF bit has been cleared.
    return (bm[nullWord] & nullFlag) == 0;
  }

  /** Create a Group Change record */
  record_t AllocateGroupChange() const
  {
    record_t tmp = InternalAllocateRecord();
    Clear(tmp);
    
    // The Group Change bit is in the bit position GetNumColumns()+1;
    boost::uint32_t nullWord = (mNumColumns+1) / 32;
    boost::uint32_t nullFlag = (1UL << ((mNumColumns+1) % 32));
    boost::uint32_t * bm = reinterpret_cast<boost::uint32_t *>(tmp + GetBitmapOffset());
    bm[nullWord] &= ~nullFlag;

    return tmp;
  }

  /** Return true if the given record indicates a group change record */
  bool IsGroupChange(const_record_t recordBuffer) const
  {
    // The Group Change bit is in the bit position GetNumColumns();
    boost::uint32_t nullWord = (mNumColumns+1) / 32;
    boost::uint32_t nullFlag = (1UL << ((mNumColumns+1) % 32));    
    const boost::uint32_t * bm = reinterpret_cast<const boost::uint32_t *>(recordBuffer + GetBitmapOffset());

    // We just need to check if the not-Group Change bit has been cleared.
    return (bm[nullWord] & nullFlag) == 0;
  }

  void Free(record_t recordBuffer) const 
  {
    for(std::vector<std::size_t>::const_iterator it = mNestedColumns.begin();
        it != mNestedColumns.end();
        ++it)
    {
      mVector[*it]->Free(recordBuffer);
    }
    InternalFreeRecord(recordBuffer);
  }
  void ShallowFree(record_t recordBuffer) const 
  {
    // We should only apply this if the record has been nulled out
//     int l = GetBitmapLength();
//     const unsigned int * bm = reinterpret_cast<const unsigned int *>(recordBuffer + GetBitmapOffset());
//     for(int i=0; i<l; i++)
//     {
//       if (bm[i] != 0xffffffff) 
//       {
//         throw ShallowFreeException();
//       }
//     }
    InternalFreeRecord(recordBuffer);
  }
  record_t Clone(const_record_t recordBuffer) const
  {
    record_t tmp = InternalAllocateRecord();

    memcpy(tmp, recordBuffer, mRecordLength);
    for(std::vector<std::size_t>::const_iterator it = mNestedColumns.begin();
        it != mNestedColumns.end();
        ++it)
    {
      mVector[*it]->Clone(recordBuffer, tmp);
    }
    return tmp;
  }
  int GetNumColumns() const
  {
    return (int) mVector.size();
  }
  DatabaseColumn * GetColumn(int pos) const
  {
    return mVector[pos];
  }
  bool HasColumn(const std::wstring & name) const
  {
    return mNameIndex.find(boost::to_upper_copy<std::wstring>(name)) != mNameIndex.end();
  }
  DatabaseColumn * GetColumn(const std::wstring & name) const
  {
    return mVector[GetPosition(name)];
  }
  std::wstring GetColumnName(int pos) const
  {
    return mVector[pos]->GetName();
  }
  // MTPipelineLib::PropValType GetColumnType(int pos) const
  // {
  //   return mVector[pos]->GetColumnType();
  // }
  // const wchar_t * GetColumnNamespace(int pos) const
  // {
  //   return mVector[pos]->GetColumnNamespace();
  // }
  // const wchar_t * GetColumnEnumeration(int pos) const
  // {
  //   return mVector[pos]->GetColumnEnumeration();
  // }
  int GetBitmapOffset() const
  {
    return sizeof(void *);
  }
  // Size of the bitmap in double words
  int GetBitmapLength() const
  {
    return GetBitmapLengthWords(GetNumColumns());
  }
  // Size of the bitmap in bytes
  int GetBitmapLengthBytes() const
  {
    return GetBitmapLength()*sizeof(long);
  }
  // Byte offset to data
  int GetDataOffset() const
  {
    return GetBitmapLengthBytes() + sizeof(void *);
  }
  // Intrusive List 
  static void SetNext(record_t recordBuffer, const_record_t next)
  {
    *((const_record_t *) recordBuffer) = next;
  }
  static record_t GetNext(record_t recordBuffer)
  {
    return *((record_t *) recordBuffer);
  }
  unsigned int Hash(record_t recordBuffer)
  {
    return hashfunc(recordBuffer, mRecordLength);
  }
private:
  int GetPosition(const std::wstring& name) const
  {
    return mNameIndex.find(boost::to_upper_copy<std::wstring>(name))->second;
  }
public:
  // void SetValue(record_t recordBuffer, int pos, const void * val) const
  // {
  //   mVector[pos]->SetValue(recordBuffer, val);
  // }
  // unsigned int Hash(const_record_t recordBuffer, int pos, unsigned int initialValue) const
  // {
  //   return mVector[pos]->Hash(recordBuffer, initialValue);
  // }
  // void SetNull(record_t recordBuffer, int pos) const
  // {
  //   mVector[pos]->SetNull(recordBuffer);
  // }
  // void SetLongValue(record_t recordBuffer, int pos, boost::int32_t val) const
  // {
  //   mVector[pos]->SetValue(recordBuffer, &val);
  // }
  // void SetEnumValue(record_t recordBuffer, int pos, boost::int32_t val) const
  // {
  //   mVector[pos]->SetValue(recordBuffer, &val);
  // }
  // void SetStringValue(record_t recordBuffer, int pos, const wchar_t * val) const
  // {
  //   mVector[pos]->SetValue(recordBuffer, val);
  // }
  // void SetUTF8StringValue(record_t recordBuffer, int pos, const char * val) const
  // {
  //   mVector[pos]->SetValue(recordBuffer, val);
  // }
  // void SetBooleanValue(record_t recordBuffer, int pos, bool val) const
  // {
  //   mVector[pos]->SetValue(recordBuffer, &val);
  // }
  // void SetBigIntegerValue(record_t recordBuffer, int pos, boost::int64_t val) const
  // {
  //   mVector[pos]->SetValue(recordBuffer, &val);
  // }
  // void SetDoubleValue(record_t recordBuffer, int pos, double val) const
  // {
  //   mVector[pos]->SetValue(recordBuffer, &val);
  // }
  // void SetDatetimeValue(record_t recordBuffer, int pos, date_time_traits::value val) const
  // {
  //   mVector[pos]->SetValue(recordBuffer, &val);
  // }
  // void SetDecimalValue(record_t recordBuffer, int pos, decimal_traits::const_pointer val) const
  // {
  //   mVector[pos]->SetValue(recordBuffer, val);
  // }
  // void SetBinaryValue(record_t recordBuffer, int pos, const unsigned char * val) const
  // {
  //   mVector[pos]->SetValue(recordBuffer, val);
  // }
  // bool GetNull(const_record_t recordBuffer, int pos) const
  // {
  //   return mVector[pos]->GetNull(recordBuffer);
  // }
  // boost::int32_t GetLongValue(const_record_t recordBuffer, int pos) const
  // {
  //   return *((const boost::int32_t *)(mVector[pos]->GetValue(recordBuffer)));
  // }
  // boost::int32_t GetEnumValue(const_record_t recordBuffer, int pos) const
  // {
  //   return *((const boost::int32_t *)mVector[pos]->GetValue(recordBuffer));
  // }
  // const wchar_t * GetStringValue(const_record_t recordBuffer, int pos) const
  // {
  //   return (const wchar_t *) (mVector[pos]->GetValue(recordBuffer));
  // }
  // const char * GetUTF8StringValue(const_record_t recordBuffer, int pos) const
  // {
  //   return (const char *) (mVector[pos]->GetValue(recordBuffer));
  // }
  // bool GetBooleanValue(const_record_t recordBuffer, int pos) const
  // {
  //   return *((const bool *)mVector[pos]->GetValue(recordBuffer));
  // }
  // boost::int64_t GetBigIntegerValue(const_record_t recordBuffer, int pos) const
  // {
  //   return *((const boost::int64_t *)mVector[pos]->GetValue(recordBuffer));
  // }
  // double GetDoubleValue(const_record_t recordBuffer, int pos) const
  // {
  //   return *((const double *)mVector[pos]->GetValue(recordBuffer));
  // }
  // date_time_traits::value GetDatetimeValue(const_record_t recordBuffer, int pos) const
  // {
  //   return *((date_time_traits::const_pointer)mVector[pos]->GetValue(recordBuffer));
  // }
  // decimal_traits::const_pointer GetDecimalValue(const_record_t recordBuffer, int pos) const
  // {
  //   return (decimal_traits::const_pointer)(mVector[pos]->GetValue(recordBuffer));
  // }
  // const unsigned char * GetBinaryValue(const_record_t recordBuffer, int pos) const
  // {
  //   return (const unsigned char *)(mVector[pos]->GetValue(recordBuffer));
  // }
  std::wstring ToString() const
  {
    std::wstring buf;
    for(typename std::vector<_DatabaseColumn *>::const_iterator it = mVector.begin();
        it != mVector.end();
        it++)
    {
      if (it != mVector.begin()) 
        buf += L", ";
      buf += (*it)->GetName();
      buf += L" ";
      switch((*it)->GetColumnType())
      {
      case MTPipelineLib::PROP_TYPE_INTEGER: buf += L"INTEGER"; break;
      case MTPipelineLib::PROP_TYPE_DOUBLE: buf += L"DOUBLE PRECISION"; break;
      case MTPipelineLib::PROP_TYPE_STRING: buf += L"NVARCHAR"; break;
      case MTPipelineLib::PROP_TYPE_DATETIME: buf += L"DATETIME"; break;
      case MTPipelineLib::PROP_TYPE_TIME: buf += L"DATETIME"; break;
      case MTPipelineLib::PROP_TYPE_BOOLEAN: buf += L"BOOLEAN"; break;
      case MTPipelineLib::PROP_TYPE_ENUM: buf += L"ENUM"; break;
      case MTPipelineLib::PROP_TYPE_DECIMAL: buf += L"DECIMAL"; break;
      case MTPipelineLib::PROP_TYPE_ASCII_STRING: buf += L"VARCHAR"; break;
      case MTPipelineLib::PROP_TYPE_UNICODE_STRING: buf += L"NVARCHAR(255)"; break;
      case MTPipelineLib::PROP_TYPE_BIGINTEGER: buf += L"BIGINT"; break;
      case MTPipelineLib::PROP_TYPE_OPAQUE: buf += L"BINARY"; break;
      case MTPipelineLib::PROP_TYPE_SET: buf += L"["; buf += (*it)->GetPhysicalFieldType()->GetMetadata()->ToString(); buf += L"]"; break;
      default: throw std::logic_error("Unsupported column type");
      }
    }
    return buf;
  }
};

class RecordMetadata : public MetadataCollection<DatabaseColumn>
{
public:
  METRAFLOW_DECL RecordMetadata()
  {
  }
  METRAFLOW_DECL RecordMetadata(const RecordMetadata& rm)
    :
    MetadataCollection<DatabaseColumn>(rm)
  {
  }
  // METRAFLOW_DECL RecordMetadata(const RecordMetadata& rm,
  //                               const std::map<std::wstring, std::wstring>& renaming)
  //   :
  //   MetadataCollection<DatabaseColumn>(rm, renaming)
  // {
  // }
  METRAFLOW_DECL RecordMetadata(const std::vector<const RecordMetadata*> & toConcat);
  METRAFLOW_DECL RecordMetadata(const LogicalRecord & members);
  METRAFLOW_DECL RecordMetadata& operator=(const RecordMetadata& lhs);
  // METRAFLOW_DECL void Add(const std::wstring& name, ConstantPoolFactory * ruleSet, 
  //                         const PhysicalFieldType& sessionType, 
  //                         bool isRequired, long position, long columnPosition);
  // METRAFLOW_DECL void Add(const std::wstring& name, ConstantPoolFactory * ruleSet, 
  //                         const std::wstring& enumNamespace, const std::wstring& enumEnumeration,
  //                         bool isRequired, long position, long columnPosition);
  METRAFLOW_DECL std::string PrintMessage(const_record_t recordBuffer) const;

  // /** 
  //  * If takeComplement is false, project metadata onto the list of columns.
  //  * If takeComplement is false, project metadata not in the list of columns.
  //  * Column names are case insensitive.
  //  * If a column name is not found, then returns list of unresolved columns
  //  * in the output array.
  //  */
  // METRAFLOW_DECL void Project(const std::vector<std::wstring>& columns,
  //                             bool takeComplement,
  //                             RecordMetadata& result,
  //                             std::vector<std::wstring>& missingColumns) const;

  // /** 
  //  * Nest the record nestedRecord under a new column nestColumn in the current
  //  * record.  If nestColumn already exists in this, return false;
  //  */
  // METRAFLOW_DECL bool NestCollection(const std::wstring& nestColumn,
  //                                    const RecordMetadata& nestedRecord,
  //                                    RecordMetadata& result) const;
  
  // /** 
  //  * Nest the listed child columns in a new nest.  If nestCollection is true
  //  * make the children into a collection of subrecords, otherwise just make a subrecord.
  //  */
  // METRAFLOW_DECL bool NestColumns(const std::wstring& nestColumn,
  //                                 const std::vector<std::wstring>& childColumns,
  //                                 bool nestCollection,
  //                                 RecordMetadata& result) const;

  // /** 
  //  * Unnest the named column.  The named column is either a subrecord or a collection of subrecords.
  //  * Returns all column name collisions from the nested record in columnCollisions.
  //  */
  // METRAFLOW_DECL void UnnestColumn(const std::wstring& nestColumn,
  //                                  RecordMetadata& result,
  //                                  std::vector<std::wstring>& columnCollisions) const;
  // /**
  //  * Calculate the list of columns from this metadata that are not in the input
  //  * list. Also outputs the list of any columns in the input that are not in the 
  //  * metadata. TODO: Make this a bit more STL generic by using iterators or ranges.
  //  */
  // METRAFLOW_DECL void ColumnComplement(const std::vector<std::wstring>& columns,
  //                                      std::vector<std::wstring>& columnComplement,
  //                                      std::vector<std::wstring>& missingColumns) const;

  /** 
   * Return a printable description of the metadata. This description is
   * used in the --typecheck output describing the dataflow.
   */
  METRAFLOW_DECL std::wstring getDescription() const;
};

// // A "self-describing record" that looks like a COdbcResultSet.
// // This has some nasty inefficiencies due to the use of ODBC datatypes
// // in the interface (decimal and timestamp).
// class RecordResultSet
// {
// protected:
//   record_t mBuffer;
//   RecordMetadata * mMetadata;
//   int mLast;
//   RecordResultSet()
//     :
//     mBuffer(NULL),
//     mMetadata(NULL)
//   {
//   }
// public:
// 	METRAFLOW_DECL int GetInteger(int aPos)
//   {
//     mLast = aPos;
//     return mMetadata->GetLongValue(mBuffer, aPos-1);
//   }
// 	boost::int64_t GetBigInteger(int aPos)
//   {
//     mLast = aPos;
//     return mMetadata->GetBigIntegerValue(mBuffer, aPos-1);
//   }
// 	METRAFLOW_DECL std::string GetString(int aPos);
// 	METRAFLOW_DECL double GetDouble(int aPos)
//   {
//     mLast = aPos;
//     return mMetadata->GetDoubleValue(mBuffer, aPos-1);
//   }
// 	METRAFLOW_DECL COdbcTimestamp GetTimestamp(int aPos);
//   METRAFLOW_DECL date_time_traits::value GetDatetime(int aPos)
//   {
//     mLast = aPos;
//     return mMetadata->GetDatetimeValue(mBuffer, aPos-1);
//   }
// 	METRAFLOW_DECL COdbcDecimal GetDecimal(int aPos);
// 	METRAFLOW_DECL std::vector<unsigned char> GetBinary(int aPos)
//   {
//     ASSERT(FALSE);
//     return std::vector<unsigned char>();
//   }
// 	METRAFLOW_DECL std::wstring GetWideString(int aPos)
//   {
//     mLast = aPos;
//     return mMetadata->GetStringValue(mBuffer, aPos-1);
//   }
// 	METRAFLOW_DECL const wchar_t* GetWideStringBuffer(int aPos)
//   {
//     mLast = aPos;
//     return mMetadata->GetStringValue(mBuffer, aPos-1);
//   }
// 	METRAFLOW_DECL const unsigned char* GetBinaryBuffer(int aPos)
//   {
//     mLast = aPos;
//     return mMetadata->GetBinaryValue(mBuffer, aPos-1);
//   }
// 	METRAFLOW_DECL bool WasNull() const
//   {
//     return mMetadata->GetNull(mBuffer, mLast-1);
//   } 
// };

// Record Operation to concatenate two records.
class RecordMerge
{
private:
  RecordMetadata * mMergedMetadata;
  // Null bitmap sizes measured in machine words
  boost::int32_t mLeftBitmapLength;
  boost::int32_t mRightBitmapLength;
  // Operations for performing the merge.
  std::vector<BitcpyOperation> mLeftBitcpy;
  std::vector<MemcpyOperation> mLeftMemcpy;
  std::vector<BitcpyOperation> mRightBitcpy;
  std::vector<MemcpyOperation> mRightMemcpy;
  std::vector<FieldCopy> mLeftNestedColumns;
  std::vector<FieldCopy> mRightNestedColumns;
  std::vector<FieldTransfer> mLeftTransferColumns;
  std::vector<FieldTransfer> mRightTransferColumns;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version) 
  {
    ar & BOOST_SERIALIZATION_NVP(mMergedMetadata);
    ar & BOOST_SERIALIZATION_NVP(mLeftBitmapLength);
    ar & BOOST_SERIALIZATION_NVP(mRightBitmapLength);
    ar & BOOST_SERIALIZATION_NVP(mLeftBitcpy);
    ar & BOOST_SERIALIZATION_NVP(mLeftMemcpy);
    ar & BOOST_SERIALIZATION_NVP(mRightBitcpy);
    ar & BOOST_SERIALIZATION_NVP(mRightMemcpy);
    ar & BOOST_SERIALIZATION_NVP(mLeftNestedColumns);
    ar & BOOST_SERIALIZATION_NVP(mRightNestedColumns);
    ar & BOOST_SERIALIZATION_NVP(mLeftTransferColumns);
    ar & BOOST_SERIALIZATION_NVP(mRightTransferColumns);
  }  

  void GenerateInstructions(const RecordMetadata& targetMetadata,
                            const RecordMetadata& sourceMetadata,
                            std::vector<BitcpyOperation>& bitcopyOperations,
                            std::vector<MemcpyOperation>& memcpyOperations);
public:
  METRAFLOW_DECL RecordMerge(const RecordMetadata * lhs, 
                             const RecordMetadata * rhs,
                             const std::wstring& nameOfLhs=L"", 
                             const std::wstring& nameOfRhs=L"");
  METRAFLOW_DECL RecordMerge(const RecordMerge& rm);
  METRAFLOW_DECL RecordMerge();
  METRAFLOW_DECL ~RecordMerge();
  METRAFLOW_DECL const RecordMerge& operator=(const RecordMerge& rm);

  METRAFLOW_DECL RecordMetadata * GetRecordMetadata()
  {
    return mMergedMetadata;
  }
  METRAFLOW_DECL const RecordMetadata * GetRecordMetadata() const
  {
    return mMergedMetadata;
  }
  METRAFLOW_DECL void Merge(const_record_t lhs, const_record_t rhs, record_t result) const
  {
    // Kinda hacky.  We actually know that we are const in the Copy case.
    // Not sure how to fix the case without copying code (maybe template).
    Merge(const_cast<record_t>(lhs), const_cast<record_t>(rhs), result, false, false);
  }
  METRAFLOW_DECL void Merge(record_t lhs, record_t rhs, record_t result, bool transferLeft, bool transferRight) const
  {
    for (std::vector<BitcpyOperation>::const_iterator it = mLeftBitcpy.begin();
         it != mLeftBitcpy.end();
         it++)
    {
      // There is some subtle code in the shift cases.  Because >> and << extend and we want
      // extending by 1, we need to
      // rewrite (x | ~y) >>  as ~((~x & y) >>).
      switch(it->Ty)
      {
      case BitcpyOperation::BITCPY:
        *reinterpret_cast<std::size_t *>(result + it->TargetOffset) = 
          ((*reinterpret_cast<const std::size_t *>(lhs + it->SourceOffset)) & (it->SourceBitmask))
          |
          ((*reinterpret_cast<const std::size_t *>(result + it->TargetOffset)) & (~it->SourceBitmask));
        break;
      case BitcpyOperation::BITCPY_R:
        *reinterpret_cast<std::size_t *>(result + it->TargetOffset) = 
          (((*reinterpret_cast<const std::size_t *>(lhs + it->SourceOffset)) & it->SourceBitmask) << it->Shift)
          |
          ((*reinterpret_cast<const std::size_t *>(result + it->TargetOffset)) & (~(it->SourceBitmask << it->Shift)));
        break;
      case BitcpyOperation::BITCPY_L:
        *reinterpret_cast<std::size_t *>(result + it->TargetOffset) = 
          (((*reinterpret_cast<const std::size_t *>(lhs + it->SourceOffset)) & it->SourceBitmask) >> it->Shift)
          |
          ((*reinterpret_cast<const std::size_t *>(result + it->TargetOffset)) & (~(it->SourceBitmask >> it->Shift)));
        break;
      }
    }
    for (std::vector<BitcpyOperation>::const_iterator it = mRightBitcpy.begin();
         it != mRightBitcpy.end();
         it++)
    {
      switch(it->Ty)
      {
      case BitcpyOperation::BITCPY:
        *reinterpret_cast<std::size_t *>(result + it->TargetOffset) = 
          ((*reinterpret_cast<const std::size_t *>(rhs + it->SourceOffset)) & (it->SourceBitmask))
          |
          ((*reinterpret_cast<const std::size_t *>(result + it->TargetOffset)) & (~it->SourceBitmask));
        break;
      case BitcpyOperation::BITCPY_R:
        *reinterpret_cast<std::size_t *>(result + it->TargetOffset) = 
          (((*reinterpret_cast<const std::size_t *>(rhs + it->SourceOffset)) & it->SourceBitmask) << it->Shift)
          |
          ((*reinterpret_cast<const std::size_t *>(result + it->TargetOffset)) & (~(it->SourceBitmask << it->Shift)));
        break;
      case BitcpyOperation::BITCPY_L:
        *reinterpret_cast<std::size_t *>(result + it->TargetOffset) = 
          (((*reinterpret_cast<const std::size_t *>(rhs + it->SourceOffset)) & it->SourceBitmask) >> it->Shift)
          |
          ((*reinterpret_cast<const std::size_t *>(result + it->TargetOffset)) & (~(it->SourceBitmask >> it->Shift)));
        break;
      }
    }
    for (std::vector<MemcpyOperation>::const_iterator it = mLeftMemcpy.begin();
         it != mLeftMemcpy.end();
         it++)
    {
      memcpy(result + it->TargetOffset, lhs + it->SourceOffset, it->Sz);
    }
    for (std::vector<MemcpyOperation>::const_iterator it = mRightMemcpy.begin();
         it != mRightMemcpy.end();
         it++)
    {
      memcpy(result + it->TargetOffset, rhs + it->SourceOffset, it->Sz);
    }

    if (transferLeft)
    {
      // Perform any explicit transfers necessary.
      for(std::vector<FieldTransfer>::const_iterator it = mLeftTransferColumns.begin();
          it != mLeftTransferColumns.end();
          ++it)
      {
        it->Transfer(lhs, result);
      }
      // Null out left bitmap
      memset(lhs + sizeof(void*), 0xff, mLeftBitmapLength*sizeof(unsigned int));
    }
    else
    {
      for(std::vector<FieldCopy>::const_iterator it = mLeftNestedColumns.begin();
          it != mLeftNestedColumns.end();
          ++it)
      {
        it->Copy(lhs, result);
      }
    }
    if (transferRight)
    {
      // Perform any explicit transfers necessary.
      for(std::vector<FieldTransfer>::const_iterator it = mRightTransferColumns.begin();
          it != mRightTransferColumns.end();
          ++it)
      {
        it->Transfer(rhs, result);
      }
      // Null out right bitmap
      memset(rhs + sizeof(void*), 0xff, mRightBitmapLength*sizeof(unsigned int));
    }
    else
    {
      for(std::vector<FieldCopy>::const_iterator it = mRightNestedColumns.begin();
          it != mRightNestedColumns.end();
          ++it)
      {
        it->Copy(rhs, result);
      }
    }
  }
  METRAFLOW_DECL llvm::Function * RecordMerge::Compile(llvm::Module * m);
};

class RecordProjection
{
private:
  // Null bitmap sizes measured in machine words
  std::vector<BitcpyOperation> mBitcpy;
  std::vector<MemcpyOperation> mMemcpy;
  // Nested record transfers
  std::vector<FieldCopy> mCopy;
  std::vector<FieldTransfer> mTransfer;
  // Is this an identity projection
  bool mIsIdentity;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mBitcpy);
    ar & BOOST_SERIALIZATION_NVP(mMemcpy);
    ar & BOOST_SERIALIZATION_NVP(mCopy);
    ar & BOOST_SERIALIZATION_NVP(mTransfer);
    ar & BOOST_SERIALIZATION_NVP(mIsIdentity);
  }

  void Init(const RecordMetadata & source, 
            const RecordMetadata & target,
            const std::map<std::wstring, std::wstring>& sourceTargetMap);

public:
  METRAFLOW_DECL RecordProjection();
  METRAFLOW_DECL RecordProjection(const RecordMetadata & source, 
                                  const RecordMetadata & target);
  METRAFLOW_DECL RecordProjection(const RecordMetadata & source, 
                                  const RecordMetadata & target,
                                  const std::map<std::wstring, std::wstring>& sourceTargetMap);
  METRAFLOW_DECL ~RecordProjection();
  METRAFLOW_DECL RecordProjection(const RecordProjection& rm);
  METRAFLOW_DECL RecordProjection& operator=(const RecordProjection& rm);
  METRAFLOW_DECL bool IsIdentity() const;
  METRAFLOW_DECL void Project(const_record_t source, record_t result, bool isTransfer=false) const
  {
    for (std::vector<BitcpyOperation>::const_iterator it = mBitcpy.begin();
         it != mBitcpy.end();
         it++)
    {
      // There is some subtle code in the shift cases.  Because >> and << extend and we want
      // extending by 1, we need to
      // rewrite (x | ~y) >>  as ~((~x & y) >>).
      switch(it->Ty)
      {
      case BitcpyOperation::BITCPY:
        *reinterpret_cast<std::size_t *>(result + it->TargetOffset) &= 
          (*reinterpret_cast<const std::size_t *>(source + it->SourceOffset)) | (~it->SourceBitmask);
        break;
      case BitcpyOperation::BITCPY_R:
        *reinterpret_cast<std::size_t *>(result + it->TargetOffset) &= 
          ~((~(*reinterpret_cast<const std::size_t *>(source + it->SourceOffset)) & (it->SourceBitmask)) << it->Shift);
        break;
      case BitcpyOperation::BITCPY_L:
        *reinterpret_cast<std::size_t *>(result + it->TargetOffset) &= 
          ~((~(*reinterpret_cast<const std::size_t *>(source + it->SourceOffset)) & (it->SourceBitmask)) >> it->Shift);
        break;
      }
    }
    for (std::vector<MemcpyOperation>::const_iterator it = mMemcpy.begin();
         it != mMemcpy.end();
         it++)
    {
      memcpy(result + it->TargetOffset, source + it->SourceOffset, it->Sz);
    }
    if (isTransfer)
    {
      for (std::vector<FieldTransfer>::const_iterator it = mTransfer.begin();
           it != mTransfer.end();
           it++)
      {
        it->Transfer(const_cast<record_t>(source), result);
      }
    }
    else
    {
      for (std::vector<FieldCopy>::const_iterator it = mCopy.begin();
           it != mCopy.end();
           it++)
      {
        it->Copy(source, result);
      }
    }
  }
};

class RecordPrinter
{
private:
  std::vector<std::pair<DataAccessor*, RecordPrinter*> > mFields;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mFields);
  }  

  void ProcessSubrecord(const std::wstring& context,
                        const LogicalRecord& logicalRecord,
                        const RecordMetadata& physicalRecord);

public:
  METRAFLOW_DECL RecordPrinter();
  METRAFLOW_DECL ~RecordPrinter();
  METRAFLOW_DECL RecordPrinter(const LogicalRecord& logicalRecord,
                               const RecordMetadata& physicalRecord);

  /**
   * Return a printable version of the record.
   *
   * @isMultiLine   if true, put a line feed between fields else
   *                put a comma between fields
   */
  METRAFLOW_DECL std::string PrintMessage(const_record_t recordBuffer,
                                          std::wstring fieldSeparator,
                                          std::wstring valueSeparator);

  /**
   * Return a printable version of the record.
   * Separate fields with commas.
   */
  METRAFLOW_DECL std::string PrintMessage(const_record_t recordBuffer);
};

// Nested Collection Types
// 
// Assume that we have nested collections (lists/bags) of records.
// E.g. Type Conference_Participant(participant String, duration Integer)
//      Type Conference_Call (leader String, duration Integer, participants [Participants])
//
// At this point, I have been convinced that the only natural algebra for manipulating
// nested collections is the monadic/comprehension model (see Wong's Querying Nested Collections
// and to some extent Grust's Comprehending Queries).
// The critical generalization of joins that seems to be required for processing nested collections
// is the nestjoin that has a comprehension syntax like:
// [(x.a, x.b, [(y.d, y.e, z.f) | y <- x.d, z <- Z, q(x,y,z)]) | x <- X]
//
// There are a few different problems that need to be solved to efficiently compute these.
// 1) Identifying the iteration paradigm for streams of nested records.
// 2) Building efficient restructuring operators (at least binary ones) that generalize 
// cartesian product (and projection?)
// 3) Generalizing matching algorithms (e.g. hash join) to deal with nesting.
// Question: what are the restrictions on the nested relational join (e.g. must the join
// essentially be along a "line" or may the join work across of a subtree of the schema).
// E.g. Given A = (a,b,[c],[d]), is there a valid notion of binary nest-joining on a,c and d?  Does
// this kind of joining require unnesting?
// Clearly, unnesting allows this:
// [(x.a,x.b,c,d,e) | x <- A, c <- A.c, d <- A.d, e <- E, p(a,c,d,e)]
// I suppose that one can make an argument that two isomorphic trees should be joinable in 
// a "single operation".
// Given A = (a, [b], [c]), B=(a, d, [(b, e)], [(c, f)]), the following nest join is interesting:
// [(x.a, y.d, [(x_b.b, y_b.e) | x_b <- x.b, y_b <- y_b, r(x_b.b, y_b.b)], [(x_c.c, y_c.f) | x_c <- x.c, y_c <- y.c, q(x_c.c, y_c.c)]) | x <- A, y <- B, p(x.a,y.a)]
// Note that this could be done as two binary nest joins.  If the cost of record construction is high, then it is
// entirely possible that one would want to support this as a monolithic operation rather than decomposing it
// into two nest joins (one on the "b" branch and one on the "c" branch).
// I guess the general picture is that given two different trees A, B, there is a third tree C with an
// injection C->A, C->B such that it is possible to place predicates at each node of C and define a nest join
// between A and B on C.

// Abstractions:
// A single tuple/record (at any level, and possibly with complex type fields)
// Atomic type value accessors
// Collection type value iterator (cabable of iterating over a single list, set, bag, etc.)
// Path tuple/record encapsulates a tuple (nested in general) with all of its parent tuple properties
// Path iterator encapsulates iterating over a nested collection type generating all path tuples

//Column store
//Inspired by Monet/X100
// namespace ColumnListStore
// {
//   // Structure of the column list store
//   // TODO: Eliminate assumption that we store a null bitmap for non-nullable columns
//   // Null Bitmap Column 1
//   // Column 1 data
//   // ...
//   // Null Bitmap Column N
//   // Column N data

//   // Address of the start of a list of field values
//   // Design decision: Should we hard code the list length
//   // to enable precomputation of the offset or is this really
//   // irrelevant?  For the moment, the offset can be computed
//   // as linear function of list length, so it is false economy
//   // to save an integer multiply.  I suppose we should be aware
//   // of the time to read that integer from memory (into cache).
//   class VectorizedFieldAddress
//   {
//   protected:
//     ConstantPoolFactory * mConstantPool;
//     // Byte offset relative to the start of the buffer to the const value.  For certain values (decimals & strings),
//     // this is a pointer to where the value lives.  In the operator per rule case, this points to the operator.
//     long mValueOffset;
//     long mNullBitmapOffset;
// public:
//   VectorizedFieldAddress(ConstantPoolFactory * constantPool, long position, long offset)
//     :
//     mConstantPool(constantPool),
//     mNullWord(position / (sizeof(unsigned long)*8)),
//     mNullFlag(1UL << (position % (sizeof(unsigned long)*8))),
//     mOffset(offset)
//   {
//   }
//   void InternalSetNullableLongValue(record_t recordBuffer, const void * input, int len)
//   {
//     boost::int32_t * target = reinterpret_cast<boost::int32_t *>(recordBuffer + len*mValueOffset);
//     boost::int32_t * source = reinterpret_cast<boost::int32_t *>(input);
//     memcpy(target, source, len * sizeof(long));
//     unsigned int * nullBitmap = reinterpret_cast<unsigned int *>(recordBuffer + len*mNullBitmapOffset);
//   }
//   void InternalSetNullableBooleanValue(record_t recordBuffer, const void * input)
//   {
//     ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//     *((bool *)(recordBuffer + mOffset)) = *((const bool *)input);
//   }
//   void InternalSetNullableDirectBigIntegerValue(record_t recordBuffer, const void * input)
//   {
//     ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//     *((boost::int64_t *)(recordBuffer + mOffset)) = *((const boost::int64_t *)input);
//   }
//   void InternalSetNullableIndirectBigIntegerValue(record_t recordBuffer, const void * input)
//   {
//     ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//     *((boost::int64_t **)(recordBuffer + mOffset)) = mConstantPool->GetBigIntegerConstant(*((const boost::int64_t *)input));
//   }
//   void InternalSetNullableDirectDoubleValue(record_t recordBuffer, const void * input)
//   {
//     ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//     *((double *)(recordBuffer + mOffset)) = *((const double *)input);
//   }
//   void InternalSetNullableIndirectDoubleValue(record_t recordBuffer, const void * input)
//   {
//     ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//     *((double **)(recordBuffer + mOffset)) = mConstantPool->GetDoubleConstant(*((const double *)input));
//   }
//     void InternalSetNullableIndirectStringValue(record_t recordBuffer, const void * input)
//     {
//       ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//       *((wchar_t **)(recordBuffer + mOffset)) = mConstantPool->GetWideStringConstant(((const wchar_t *)input));
//     }
//     void InternalSetNullableDirectStringValue(record_t recordBuffer, const void * input)
//     {
//       ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//       wcscpy((wchar_t *)(recordBuffer + mOffset), (const wchar_t *)input);
//     }
//     void InternalSetNullableIndirectUTF8StringValue(record_t recordBuffer, const void * input)
//     {
//       ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//       *((char **)(recordBuffer + mOffset)) = mConstantPool->GetUTF8StringConstant(((const char *)input));
//     }
//     void InternalSetNullableDirectDatetimeValue(record_t recordBuffer, const void * input)
//     {
//       ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//       *((date_time_traits::pointer)(recordBuffer + mOffset)) = *((date_time_traits::const_pointer)input);
//     }
//     void InternalSetNullableIndirectDatetimeValue(record_t recordBuffer, const void * input)
//     {
//       ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//       *((date_time_traits::pointer*)(recordBuffer + mOffset)) = mConstantPool->GetDoubleConstant(*((date_time_traits::const_pointer)input));
//     }
//     void InternalSetNullableDirectDecimalValue(record_t recordBuffer, const void * input)
//     {
//       ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//       memcpy(recordBuffer + mOffset, input, sizeof(DECIMAL));
//     }
//     void InternalSetNullableIndirectDecimalValue(record_t recordBuffer, const void * input)
//     {
//       ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//       *((decimal_traits::pointer*)(recordBuffer + mOffset)) = mConstantPool->GetDecimalConstant((decimal_traits::const_pointer)input);
//     }
//     void InternalSetNullableDirectBinaryValue(record_t recordBuffer, const void * input)
//     {
//       ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
//       memcpy(recordBuffer + mOffset, input, 16);
//     }
//     METRAFLOW_DECL void SetNull(record_t recordBuffer)
//     {
//       ((unsigned int *)recordBuffer)[mNullWord] |= mNullFlag;
//     }
//     const void * GetDirectBuffer(const_record_t recordBuffer)
//     {
//       return recordBuffer + mOffset;
//     }
//     const void * GetIndirectBuffer(const_record_t recordBuffer)
//     {
//       return *((const void **)(recordBuffer + mOffset));
//     }
//     METRAFLOW_DECL bool GetNull(record_t recordBuffer)
//     {
//       return (((unsigned int *)recordBuffer)[mNullWord] & mNullFlag) != 0;
//     }
//     unsigned int InternalHashLongValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(long), initialValue);
//     }
//     unsigned int InternalHashBooleanValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(bool), initialValue);
//     }
//     unsigned int InternalHashDirectBigIntegerValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(boost::int64_t), initialValue);
//     }
//     unsigned int InternalHashIndirectBigIntegerValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(boost::int64_t), initialValue);
//     }
//     unsigned int InternalHashDirectDoubleValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(double), initialValue);
//     }
//     unsigned int InternalHashIndirectDoubleValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(double), initialValue);
//     }
//     unsigned int InternalHashIndirectStringValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(wchar_t)*(wcslen((const wchar_t *) GetIndirectBuffer(recordBuffer))+1), initialValue);
//     }
//     unsigned int InternalHashDirectStringValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(wchar_t)*(wcslen((const wchar_t *) GetDirectBuffer(recordBuffer))+1), initialValue);
//     }
//     unsigned int InternalHashIndirectUTF8StringValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(char)*(strlen((const char *) GetIndirectBuffer(recordBuffer))+1), initialValue);
//     }
//     unsigned int InternalHashDirectDatetimeValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(date_time_traits::value), initialValue);
//     }
//     unsigned int InternalHashIndirectDatetimeValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(date_time_traits::value), initialValue);
//     }
//     unsigned int InternalHashDirectDecimalValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetDirectBuffer(recordBuffer), sizeof(DECIMAL), initialValue);
//     }
//     unsigned int InternalHashIndirectDecimalValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetIndirectBuffer(recordBuffer), sizeof(DECIMAL), initialValue);
//     }
//     unsigned int InternalHashDirectBinaryValue(const_record_t recordBuffer, unsigned int initialValue)
//     {
//       return __hash((ub1 *)GetDirectBuffer(recordBuffer), 16, initialValue);
//     }
//   };
// };

#endif
