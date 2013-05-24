#include "RecordModel.h"
#include "ConstantPool.h"
#include "SpinLock.h"
#include "MTUtil.h"
#include "autocritical.h"
#include <functional>
#include <algorithm>
#include <stdexcept>
#include <sstream>
#include <boost/format.hpp>

static bool Memcpy_less(const MemcpyOperation& lhs, const MemcpyOperation& rhs)
{
  return lhs.SourceOffset < rhs.SourceOffset || 
    (lhs.SourceOffset == rhs.SourceOffset && lhs.TargetOffset < rhs.TargetOffset );
}

struct Bitcpy_greater : public std::binary_function<BitcpyOperation,BitcpyOperation,bool>
{
  bool operator() (const BitcpyOperation& lhs, const BitcpyOperation& rhs) const
  {
    return lhs.Ty < rhs.Ty ||
      (lhs.Ty == rhs.Ty && lhs.SourceOffset < rhs.SourceOffset) ||
      (lhs.Ty == rhs.Ty && lhs.SourceOffset == rhs.SourceOffset && lhs.TargetOffset < rhs.TargetOffset ) ||
      (lhs.Ty == rhs.Ty && lhs.SourceOffset == rhs.SourceOffset && lhs.TargetOffset == rhs.TargetOffset && lhs.Shift < rhs.Shift);
  }
};

ShallowFreeException::ShallowFreeException()
  :
  std::runtime_error("Must transfer prior to ShallowFree")
{
}

ShallowFreeException::~ShallowFreeException()
{
}

// #include "pstdint.h" /* Replace with <stdint.h> if appropriate */
#undef get16bits
#if (defined(__GNUC__) && defined(__i386__)) || defined(__WATCOMC__) \
  || defined(_MSC_VER) || defined (__BORLANDC__) || defined (__TURBOC__)
#define get16bits(d) (*((const boost::uint16_t *) (d)))
#endif

#if !defined (get16bits)
#define get16bits(d) ((((const boost::uint8_t *)(d))[1] << UINT32_C(8))\
                      +((const boost::uint8_t *)(d))[0])
#endif

boost::uint32_t SuperFastHash (const char * data, int len) {
boost::uint32_t hash = len, tmp;
int rem;

    if (len <= 0 || data == NULL) return 0;

    rem = len & 3;
    len >>= 2;

    /* Main loop */
    for (;len > 0; len--) {
        hash  += get16bits (data);
        tmp    = (get16bits (data+2) << 11) ^ hash;
        hash   = (hash << 16) ^ tmp;
        data  += 2*sizeof (boost::uint16_t);
        hash  += hash >> 11;
    }

    /* Handle end cases */
    switch (rem) {
        case 3: hash += get16bits (data);
                hash ^= hash << 16;
                hash ^= data[sizeof (boost::uint16_t)] << 18;
                hash += hash >> 11;
                break;
        case 2: hash += get16bits (data);
                hash ^= hash << 11;
                hash += hash >> 17;
                break;
        case 1: hash += *data;
                hash ^= hash << 10;
                hash += hash >> 1;
    }

    /* Force "avalanching" of final 127 bits */
    hash ^= hash << 3;
    hash += hash >> 5;
    hash ^= hash << 4;
    hash += hash >> 17;
    hash ^= hash << 25;
    hash += hash >> 6;

    return hash;
}

#ifdef NEVER
extern "C" {

BOOL WINAPI DllMain (HANDLE hinstDLL, DWORD fdwReason, LPVOID lpreserved)
{
  switch (fdwReason) 
  {

//   case DLL_PROCESS_ATTACH:
//     if ((theTLABIndex = ::TlsAlloc()) == TLS_OUT_OF_INDEXES) 
//       return FALSE; 
//     if ((theChunkOffsetIndex = ::TlsAlloc()) == TLS_OUT_OF_INDEXES) 
//       return FALSE; 
//     // No break: Initialize the index for first thread.
  case DLL_THREAD_ATTACH:
  {
//     // Initialize the TLS index for this thread.
//     BOOL fIgnore = ::TlsSetValue(theTLABIndex, NULL); 
//     fIgnore = ::TlsSetValue(theChunkOffsetIndex, 0);

    unsigned int h = __hash((ub1 *) &hinstDLL, sizeof(HANDLE), 0);
    h = (h) % (64*1024);
    h = ((h + 127) >> 7) << 7;
    ::_alloca(h);
    break;
  }

  default:
    return TRUE;
  }

  return TRUE;
}
}
#endif

// For this entire implementation we use a region based allocator.  We never free memory
// because this is going to so efficient we never have to!  We'll allocate memory in
// chunks of 1MB.

RegionAllocator::RegionAllocator()
  :
  mHead(NULL)
{
  mHead = CreateRegion(mHead);
}

RegionAllocator::~RegionAllocator()
{
  while(mHead != NULL)
  {
    struct Region * tmp = mHead;
    mHead = mHead->mNext;
    ::free(tmp);
  }
}

void * RegionAllocator::nonserialized_malloc(size_t sz)
{
  // round up to multiple of 8 for alignment
  sz = ((sz + 7) >> 3) << 3;
  if(sz > (size_t) (mHead->mEnd - mHead->mCommitted))
  {
    mHead = CreateRegion(mHead);

  }
  
  if (sz > (size_t) (mHead->mEnd - mHead->mCommitted))
  {
    return 0;
  }

  mHead->mPreviousCommitted = mHead->mCommitted;
  mHead->mCommitted += sz;
  return mHead->mPreviousCommitted;
}

void * RegionAllocator::malloc(size_t sz)
{
  boost::mutex::scoped_lock cs(mLock);
  return nonserialized_malloc(sz);
}

void RegionAllocator::free(void * )
{
  // no-op.  Hey, this is a region allocator :-)
}

void RegionAllocator::free_last()
{
  mHead->mCommitted = mHead->mPreviousCommitted;
  mHead->mPreviousCommitted = 0;
}

WideStringConstantPool* WideStringConstantPool::GetInstance()
{
  MetraFlow::SpinLock::Guard cs(sLock);
  if (pool == NULL)
  {
    pool = new WideStringConstantPool();
  }
  sNumRefs++;
  return pool;
}
void WideStringConstantPool::ReleaseInstance()
{
  MetraFlow::SpinLock::Guard cs(sLock);
  if(--sNumRefs == 0)
  {
    delete pool;
    pool = NULL;
  }
}
WideStringConstantPool::WideStringConstantPool()
{
  for(int i=0; i<SIZE; i++)
  {
    mTable[i] = NULL;
  }
}
WideStringConstantPool::~WideStringConstantPool()
{
}
unsigned int WideStringConstantPool::hashfunc(const unsigned char * s, int len)
{
  const unsigned char * end = s+len;
  unsigned int n = 0;
  for(; s<end; s++)
  {
    n = 31*n + *s;
  }
  return n % SIZE;
}

wchar_t * WideStringConstantPool::GetWideStringConstant(const wchar_t * val)
{
  return GetWideStringConstant(val, wcslen(val));
}

wchar_t * WideStringConstantPool::GetWideStringConstant(const wchar_t * val, int strLen)
{
//     unsigned int tab = hashfunc((const unsigned char *) val, sizeof(wchar_t)*strLen);
  unsigned int tab = __hash((unsigned char *) val, sizeof(wchar_t)*strLen, 1)%SIZE;
  MetraFlow::SpinLock::Guard cs(sLock);
  struct Node * n = mTable[tab];
  while (n!=NULL)
  {
    if (0 == wcscmp(val, n->GetStringBuffer()))
    {
      return n->GetStringBuffer();
    }
    n = n->mNext;
  }

  // New value must add it.
  n = (struct Node *) mAllocator.malloc(sizeof(struct Node) + (strLen+1)*sizeof(wchar_t));
  n->mNext = mTable[tab];
  wcscpy(n->GetStringBuffer(), val);
  mTable[tab] = n;

  return mTable[tab]->GetStringBuffer();
}


MetraFlow::SpinLock WideStringConstantPool::sLock;
WideStringConstantPool * WideStringConstantPool::pool = NULL;
int WideStringConstantPool::sNumRefs=0;

class UTF8StringConstantPool
{
private:
  struct Node
  {
    struct Node * mNext;
    char * GetStringBuffer()
    {
      return (char *) (this + 1);
    }
  };

  enum { SIZE=1024*128 };

  struct Node * mTable[SIZE];

  static unsigned int hashfunc(const unsigned char * s, int len)
  {
    const unsigned char * end = s+len;
    unsigned int n = 0;
    for(; s<end; s++)
    {
      n = 31*n + *s;
    }
    return n % SIZE;
  }
  
  RegionAllocator mAllocator;

  UTF8StringConstantPool()
  {
    for(int i=0; i<SIZE; i++)
    {
      mTable[i] = NULL;
    }
  }

  static MetraFlow::SpinLock sLock;
  static UTF8StringConstantPool * pool;
  static int sNumRefs;

public:
  static UTF8StringConstantPool* GetInstance()
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    if (pool == NULL)
    {
      pool = new UTF8StringConstantPool();
    }
    sNumRefs++;
    return pool;
  }
  static void ReleaseInstance()
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    if(--sNumRefs == 0)
    {
      delete pool;
      pool = NULL;
    }
  }

  char * GetUTF8StringConstant(const char * val)
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    int strLen = strlen(val);
    unsigned int tab = hashfunc((const unsigned char *) val, strLen);

    struct Node * n = mTable[tab];
    while (n!=NULL)
    {
      if (0 == strcmp(val, n->GetStringBuffer()))
      {
        return n->GetStringBuffer();
      }
      n = n->mNext;
    }

    // New value must add it.
    n = (struct Node *) mAllocator.malloc(sizeof(struct Node) + (strLen+1)*sizeof(char));
    n->mNext = mTable[tab];
    strcpy(n->GetStringBuffer(), val);
    mTable[tab] = n;

    return mTable[tab]->GetStringBuffer();
  }
};

MetraFlow::SpinLock UTF8StringConstantPool::sLock;
UTF8StringConstantPool * UTF8StringConstantPool::pool = NULL;
int UTF8StringConstantPool::sNumRefs=0;

class DecimalConstantPool
{
private:
  struct Node
  {
    struct Node * mNext;
    decimal_traits::value mValue;
  };

  enum { SIZE=1937 };

  struct Node * mTable[SIZE];

  static unsigned int hashfunc(const unsigned char * s, int len)
  {
    const unsigned char * end = s+len;
    unsigned int n = 0;
    for(; s<end; s++)
    {
      n = 31*n + *s;
    }
    return n % SIZE;
  }
  
  RegionAllocator mAllocator;

  DecimalConstantPool()
  {
    for(int i=0; i<SIZE; i++)
    {
      mTable[i] = NULL;
    }
  }

  static MetraFlow::SpinLock sLock;
  static DecimalConstantPool * pool;
  static int sNumRefs;
  
public:
  static DecimalConstantPool* GetInstance()
  {
    MT_Guard<MetraFlow::SpinLock> cs (&sLock);
    // Scope for mutex
    if (pool == NULL)
    {
      pool = new DecimalConstantPool();
    }
    sNumRefs++;
    return pool;
  }
  static void ReleaseInstance()
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    if(--sNumRefs == 0)
    {
      delete pool;
      pool = NULL;
    }
  }

  decimal_traits::pointer GetDecimalConstant(decimal_traits::const_pointer dec)
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    unsigned int tab = hashfunc((const unsigned char *) dec, sizeof(decimal_traits::value));

    struct Node * n = mTable[tab];
    while (n!=NULL)
    {
      if (0 == memcmp(dec, &(n->mValue), sizeof(decimal_traits::value)))
      {
        return &(n->mValue);
      }
      n = n->mNext;
    }

    // New value must add it.
    n = (struct Node *) mAllocator.malloc(sizeof(struct Node));
    n->mNext = mTable[tab];
    n->mValue = *dec;
    mTable[tab] = n;

    return &(mTable[tab]->mValue);
  }
};

MetraFlow::SpinLock DecimalConstantPool::sLock;
DecimalConstantPool * DecimalConstantPool::pool = NULL;
int DecimalConstantPool::sNumRefs=0;

class BigIntegerConstantPool
{
private:
  struct Node
  {
    struct Node * mNext;
    boost::int64_t mValue;
  };

  enum { SIZE=1937 };

  struct Node * mTable[SIZE];

  static unsigned int hashfunc(const unsigned char * s, int len)
  {
    const unsigned char * end = s+len;
    unsigned int n = 0;
    for(; s<end; s++)
    {
      n = 31*n + *s;
    }
    return n % SIZE;
  }
  
  RegionAllocator mAllocator;

  BigIntegerConstantPool()
  {
    for(int i=0; i<SIZE; i++)
    {
      mTable[i] = NULL;
    }
  }

  static MetraFlow::SpinLock sLock;
  static BigIntegerConstantPool * pool;
  static int sNumRefs;

public:
  static BigIntegerConstantPool* GetInstance()
  {
    MT_Guard<MetraFlow::SpinLock> cs (&sLock);
    if (pool == NULL)
    {
      pool = new BigIntegerConstantPool();
    }
    sNumRefs++;
    return pool;
  }
  static void ReleaseInstance()
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    if(--sNumRefs == 0)
    {
      delete pool;
      pool = NULL;
    }
  }

  boost::int64_t * GetBigIntegerConstant(boost::int64_t dec)
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    unsigned int tab = hashfunc((const unsigned char *) &dec, sizeof(boost::int64_t));

    struct Node * n = mTable[tab];
    while (n!=NULL)
    {
      if (0 == memcmp(&dec, &(n->mValue), sizeof(boost::int64_t)))
      {
        return &(n->mValue);
      }
      n = n->mNext;
    }

    // New value must add it.
    n = (struct Node *) mAllocator.malloc(sizeof(struct Node));
    n->mNext = mTable[tab];
    n->mValue = dec;
    mTable[tab] = n;

    return &(mTable[tab]->mValue);
  }
};

MetraFlow::SpinLock BigIntegerConstantPool::sLock;
BigIntegerConstantPool * BigIntegerConstantPool::pool = NULL;
int BigIntegerConstantPool::sNumRefs=0;

class DoubleConstantPool
{
private:
  struct Node
  {
    struct Node * mNext;
    double mValue;
  };

  enum { SIZE=1024*1024 };

  struct Node * mTable[SIZE];

  static unsigned int hashfunc(const unsigned char * s, int len)
  {
    const unsigned char * end = s+len;
    unsigned int n = 0;
    for(; s<end; s++)
    {
      n = 31*n + *s;
    }
    return n % SIZE;
  }
  
  RegionAllocator mAllocator;

  DoubleConstantPool()
  {
    for(int i=0; i<SIZE; i++)
    {
      mTable[i] = NULL;
    }
  }

  static MetraFlow::SpinLock sLock;
  static DoubleConstantPool * pool;
  static int sNumRefs;

public:
  static DoubleConstantPool* GetInstance()
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    if (pool == NULL)
    {
      pool = new DoubleConstantPool();
    }
    sNumRefs++;
    return pool;
  }
  static void ReleaseInstance()
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    if(--sNumRefs == 0)
    {
      delete pool;
      pool = NULL;
    }
  }

  double * GetDoubleConstant(double dec)
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    unsigned int tab = hashfunc((const unsigned char *) &dec, sizeof(double));

    struct Node * n = mTable[tab];
    while (n!=NULL)
    {
      if (0 == memcmp(&dec, &(n->mValue), sizeof(double)))
      {
        return &(n->mValue);
      }
      n = n->mNext;
    }

    // New value must add it.
    n = (struct Node *) mAllocator.malloc(sizeof(struct Node));
    n->mNext = mTable[tab];
    n->mValue = dec;
    mTable[tab] = n;

    return &(mTable[tab]->mValue);
  }
};

MetraFlow::SpinLock DoubleConstantPool::sLock;
DoubleConstantPool * DoubleConstantPool::pool = NULL;
int DoubleConstantPool::sNumRefs=0;

class DatetimeConstantPool
{
private:
  struct Node
  {
    struct Node * mNext;
    date_time_traits::value mValue;
  };

  enum { SIZE=1024*1024 };

  struct Node * mTable[SIZE];

  static unsigned int hashfunc(const unsigned char * s, int len)
  {
    const unsigned char * end = s+len;
    unsigned int n = 0;
    for(; s<end; s++)
    {
      n = 31*n + *s;
    }
    return n % SIZE;
  }
  
  RegionAllocator mAllocator;

  DatetimeConstantPool()
  {
    for(int i=0; i<SIZE; i++)
    {
      mTable[i] = NULL;
    }
  }

  static MetraFlow::SpinLock sLock;
  static DatetimeConstantPool * pool;
  static int sNumRefs;

public:
  static DatetimeConstantPool* GetInstance()
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    if (pool == NULL)
    {
      pool = new DatetimeConstantPool();
    }
    sNumRefs++;
    return pool;
  }
  static void ReleaseInstance()
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    if(--sNumRefs == 0)
    {
      delete pool;
      pool = NULL;
    }
  }

  date_time_traits::pointer GetDatetimeConstant(date_time_traits::value dec)
  {
    MetraFlow::SpinLock::Guard cs(sLock);
    unsigned int tab = hashfunc((const unsigned char *) &dec, sizeof(date_time_traits::value));

    struct Node * n = mTable[tab];
    while (n!=NULL)
    {
      if (0 == memcmp(&dec, &(n->mValue), sizeof(date_time_traits::value)))
      {
        return &(n->mValue);
      }
      n = n->mNext;
    }

    // New value must add it.
    n = (struct Node *) mAllocator.malloc(sizeof(struct Node));
    n->mNext = mTable[tab];
    n->mValue = dec;
    mTable[tab] = n;

    return &(mTable[tab]->mValue);
  }
};

MetraFlow::SpinLock DatetimeConstantPool::sLock;
DatetimeConstantPool * DatetimeConstantPool::pool = NULL;
int DatetimeConstantPool::sNumRefs=0;

ConstantPoolFactoryBase::ConstantPoolFactoryBase()
{
  mDecimalConstantPool = DecimalConstantPool::GetInstance();
  mWideStringConstantPool = WideStringConstantPool::GetInstance();
  mUTF8StringConstantPool = UTF8StringConstantPool::GetInstance();
  mBigIntegerConstantPool = BigIntegerConstantPool::GetInstance();
  mDoubleConstantPool = DoubleConstantPool::GetInstance();
  mDatetimeConstantPool = DatetimeConstantPool::GetInstance();
}
ConstantPoolFactoryBase::~ConstantPoolFactoryBase()
{
  DecimalConstantPool::ReleaseInstance();
  WideStringConstantPool::ReleaseInstance();
  UTF8StringConstantPool::ReleaseInstance();
  BigIntegerConstantPool::ReleaseInstance();
  DoubleConstantPool::ReleaseInstance();
  DatetimeConstantPool::ReleaseInstance();
}
decimal_traits::pointer ConstantPoolFactoryBase::GetDecimalConstant(decimal_traits::const_pointer dec)
{
  return mDecimalConstantPool->GetDecimalConstant(dec);
}
wchar_t * ConstantPoolFactoryBase::GetWideStringConstant(const wchar_t * val)
{
  return mWideStringConstantPool->GetWideStringConstant(val);
}
char * ConstantPoolFactoryBase::GetUTF8StringConstant(const char * val)
{
  return mUTF8StringConstantPool->GetUTF8StringConstant(val);
}
boost::int64_t * ConstantPoolFactoryBase::GetBigIntegerConstant(boost::int64_t val)
{
  return mBigIntegerConstantPool->GetBigIntegerConstant(val);
}
double * ConstantPoolFactoryBase::GetDoubleConstant(double val)
{
  return mDoubleConstantPool->GetDoubleConstant(val);
}
date_time_traits::pointer ConstantPoolFactoryBase::GetDatetimeConstant(date_time_traits::value dec)
{
  return mDatetimeConstantPool->GetDatetimeConstant(dec);
}

GlobalConstantPoolFactory*  GlobalConstantPoolFactory::Get()
{
  static GlobalConstantPoolFactory sFactory;
  return &sFactory;
}

GlobalConstantPoolFactory::GlobalConstantPoolFactory()
{
}

GlobalConstantPoolFactory::~GlobalConstantPoolFactory()
{
}

void FieldAddress::InternalAppendIndirectRecordValue(record_t recordBuffer, const void * input) const
{
  // Blech! Breaking const-ness.
  // Hell, I'm breaking everything!
  if (!GetNull(recordBuffer) && NULL != *((const_record_t *)(recordBuffer+mOffset)))
  {
    RecordMetadata::SetNext((record_t) input, RecordMetadata::GetNext(*((record_t *)(recordBuffer+mOffset))));
    RecordMetadata::SetNext(*((record_t *)(recordBuffer+mOffset)), (const_record_t) input);
  }
  else
  {
    RecordMetadata::SetNext((record_t) input, (const_record_t) input);
  }
  ClearNull(recordBuffer);
  // Represented as a circular singly linked list with the tail stored in buffer.
  *((const_record_t *)(recordBuffer+mOffset)) = (const_record_t) input;
}

void FieldAddress::InternalSetIndirectStringValue2(record_t recordBuffer, const void * input) const
{
  if (!GetNull(recordBuffer)) 
  {
    wchar_t * ptr = ((PrefixedWideString *)(recordBuffer+mOffset))->String;
    // The need for this check is really cheezy.  The serialization code often
    // memcpy's a bitmap from the source and then uses the accessor to set the
    // actual value.  In those cases we have a NULL flag set but the value is
    // NULL.
    if (ptr != NULL)
    {
      delete [] ptr;
    }
  }
  else
  {
    ClearNull(recordBuffer);
  }

  const wchar_t * sourceValue = reinterpret_cast<const wchar_t *>(input);
  int len = wcslen(sourceValue);

//   wchar_t * targetValue = new wchar_t [len+1];
//   memcpy(targetValue, sourceValue, sizeof(wchar_t)*(len + 1));
//   *((wchar_t **)(recordBuffer + mOffset)) = targetValue;

//   boost::int32_t sz = sizeof(wchar_t)*(len+1) + sizeof(boost::int32_t);
  boost::int32_t sz = sizeof(wchar_t)*(len+1);
  boost::uint8_t * targetValue = NULL;
  targetValue = (boost::uint8_t *) new boost::uint8_t [sz];
  
//   *((boost::int32_t *) targetValue) = sz;
//   memcpy(targetValue + sizeof(boost::int32_t), sourceValue, sizeof(wchar_t)*(len + 1));
//   *((boost::uint8_t **) (recordBuffer + mOffset)) = (targetValue + sizeof(boost::int32_t));  
  memcpy(targetValue, sourceValue, sizeof(wchar_t)*(len + 1));
  ((PrefixedWideString *) (recordBuffer + mOffset))->String = (wchar_t *)targetValue;
  ((PrefixedWideString *) (recordBuffer + mOffset))->Length = sz;
}

PhysicalFieldType::PhysicalFieldType(const RecordMetadata& nestedRecord, bool isList)
  :
  mPipelineType(MTPipelineLib::PROP_TYPE_SET),
  mIsInline(false),
  mMaxLength(isList ? std::numeric_limits<boost::int32_t>::max() : 1),
  mMaxBytes(std::numeric_limits<boost::int32_t>::max()),
  mNestedRecord(NULL)
{
  mNestedRecord = new RecordMetadata(nestedRecord);
}

PhysicalFieldType::PhysicalFieldType(const PhysicalFieldType& pft)
  :
  mPipelineType(pft.mPipelineType),
  mIsInline(pft.mIsInline),
  mMaxLength(pft.mMaxLength),
  mMaxBytes(pft.mMaxBytes),
  mNestedRecord(NULL)
{
  if (pft.mNestedRecord)
    mNestedRecord = new RecordMetadata(*pft.mNestedRecord);
}

PhysicalFieldType::~PhysicalFieldType()
{
  delete mNestedRecord;
}

PhysicalFieldType PhysicalFieldType::Record(const RecordMetadata& nestedRecord, bool isList)
{
  PhysicalFieldType ty(nestedRecord, isList);
  return ty;
}

std::wstring PhysicalFieldType::GetMTSQLDatatype(DataAccessor * accessor)

{
  return PhysicalFieldType::GetMTSQLDatatype(
                          accessor->GetPhysicalFieldType()->GetPipelineType());
}

std::wstring PhysicalFieldType::GetMTSQLDatatype(MTPipelineLib::PropValType valType)
{
  switch(valType)
  {
    case MTPipelineLib::PROP_TYPE_INTEGER: return L"INTEGER";

    case MTPipelineLib::PROP_TYPE_DOUBLE: return L"DOUBLE PRECISION";

    case MTPipelineLib::PROP_TYPE_STRING: return L"NVARCHAR";

    case MTPipelineLib::PROP_TYPE_DATETIME: return L"DATETIME";

    case MTPipelineLib::PROP_TYPE_TIME: return L"DATETIME";

    case MTPipelineLib::PROP_TYPE_BOOLEAN: return L"BOOLEAN";

    case MTPipelineLib::PROP_TYPE_ENUM: return L"ENUM";

    case MTPipelineLib::PROP_TYPE_DECIMAL: return L"DECIMAL";

    case MTPipelineLib::PROP_TYPE_ASCII_STRING: return L"VARCHAR";

    case MTPipelineLib::PROP_TYPE_UNICODE_STRING: return L"NVARCHAR";

    case MTPipelineLib::PROP_TYPE_BIGINTEGER: return L"BIGINT";

    case MTPipelineLib::PROP_TYPE_OPAQUE: return L"BINARY";

    default: throw std::runtime_error("Unsupported data type");
  }
}

std::wstring PhysicalFieldType::ToString() const
{
  return GetMTSQLDatatype(mPipelineType);
}

bool PhysicalFieldType::operator==(const PhysicalFieldType & rhs) const
{
  return mPipelineType == rhs.mPipelineType &&
    mIsInline == rhs.mIsInline &&
    mMaxLength == rhs.mMaxLength &&
    mMaxBytes == rhs.mMaxBytes;
}

bool PhysicalFieldType::operator!=(const PhysicalFieldType & rhs) const
{
  return !this->operator==(rhs);
}

FieldAddressSetter PhysicalFieldType::GetFieldAddressSetter() const
{
  switch(mPipelineType)
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    return mIsInline ? 
      &FieldAddress::InternalSetDirectDecimalValue : 
      &FieldAddress::InternalSetIndirectDecimalValue;
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    return &FieldAddress::InternalSetLongValue;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    return &FieldAddress::InternalSetLongValue;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    return &FieldAddress::InternalSetBooleanValue;
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_STRING:
  {
    return mIsInline ? 
      &FieldAddress::InternalSetDirectStringValue : 
      &FieldAddress::InternalSetIndirectStringValue2;
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
  {
    return &FieldAddress::InternalSetIndirectUTF8StringValue2;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    return mIsInline ? 
      &FieldAddress::InternalSetDirectBigIntegerValue : 
      &FieldAddress::InternalSetIndirectBigIntegerValue;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    return mIsInline ? 
      &FieldAddress::InternalSetDirectDoubleValue : 
      &FieldAddress::InternalSetIndirectDoubleValue;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    return mIsInline ? 
      &FieldAddress::InternalSetDirectDatetimeValue : 
      &FieldAddress::InternalSetIndirectDatetimeValue;
  }
  case MTPipelineLib::PROP_TYPE_OPAQUE:
  {
    return &FieldAddress::InternalSetDirectBinaryValue;
  }
  case MTPipelineLib::PROP_TYPE_SET:
  {
    return IsList() ? &FieldAddress::InternalAppendIndirectRecordValue : NULL;
  }
  default:
    throw std::runtime_error("Illegal PropValType");
  }
}

FieldAddressGetter PhysicalFieldType::GetFieldAddressGetter() const
{
  switch(mPipelineType)
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    return mIsInline ? 
      &FieldAddress::GetDirectBuffer : 
      &FieldAddress::GetIndirectBuffer;
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    return &FieldAddress::GetDirectBuffer;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    return &FieldAddress::GetDirectBuffer;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    return &FieldAddress::GetDirectBuffer;
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_STRING:
  {
    return mIsInline ? 
      &FieldAddress::GetDirectBuffer : 
      &FieldAddress::GetIndirectBuffer;
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
  {
    return &FieldAddress::GetIndirectBuffer;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    return mIsInline ? 
      &FieldAddress::GetDirectBuffer : 
      &FieldAddress::GetIndirectBuffer;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    return mIsInline ? 
      &FieldAddress::GetDirectBuffer : 
      &FieldAddress::GetIndirectBuffer;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    return mIsInline ? 
      &FieldAddress::GetDirectBuffer : 
      &FieldAddress::GetIndirectBuffer;
  }
  case MTPipelineLib::PROP_TYPE_OPAQUE:
  {
    return &FieldAddress::GetDirectBuffer;
  }
  case MTPipelineLib::PROP_TYPE_SET:
  {
    return IsList() ? &FieldAddress::GetIndirectBuffer : NULL;
  }
  default:
    throw std::runtime_error("Illegal PropValType");
  }
}

HashFunction PhysicalFieldType::GetHashFunction() const
{
  switch(mPipelineType)
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    return mIsInline ? 
      &FieldAddress::InternalHashDirectDecimalValue : 
      &FieldAddress::InternalHashIndirectDecimalValue;
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    return &FieldAddress::InternalHashLongValue;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    return &FieldAddress::InternalHashLongValue;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    return &FieldAddress::InternalHashBooleanValue;
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_STRING:
  {
    return mIsInline ? 
      &FieldAddress::InternalHashDirectStringValue : 
      &FieldAddress::InternalHashIndirectStringValue;
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
  {
    return &FieldAddress::InternalHashIndirectUTF8StringValue;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    return mIsInline ? 
      &FieldAddress::InternalHashDirectBigIntegerValue : 
      &FieldAddress::InternalHashIndirectBigIntegerValue;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    return mIsInline ? 
      &FieldAddress::InternalHashDirectDoubleValue : 
      &FieldAddress::InternalHashIndirectDoubleValue;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    return mIsInline ? 
      &FieldAddress::InternalHashDirectDatetimeValue : 
      &FieldAddress::InternalHashIndirectDatetimeValue;
  }
  case MTPipelineLib::PROP_TYPE_OPAQUE:
  {
    return &FieldAddress::InternalHashDirectBinaryValue;
  }
  case MTPipelineLib::PROP_TYPE_SET:
  {
    return NULL;
  }
  default:
    throw std::runtime_error("Illegal PropValType");
  }
}

ExportSortKeyFunction PhysicalFieldType::GetExportSortKeyFunction() 
{
  switch(mPipelineType)
  {
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    return &SortKeyBuffer::ExportIntegerSortKeyFunction;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    return &SortKeyBuffer::ExportBigIntegerSortKeyFunction;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    return &SortKeyBuffer::ExportDatetimeSortKeyFunction;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    return &SortKeyBuffer::ExportBooleanSortKeyFunction;
  }
  case MTPipelineLib::PROP_TYPE_OPAQUE:
  {
    return &SortKeyBuffer::ExportBinarySortKeyFunction;
  }
   default:
    return NULL;
  }
}

EqualsFunction PhysicalFieldType::GetEqualsFunction() const
{
  switch(mPipelineType)
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    return DecimalEquals;
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    return LongEquals;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    return LongEquals;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    return BooleanEquals;
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_STRING:
  {
    return StringEquals;
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
  {
    return UTF8StringEquals;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    return BigIntegerEquals;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    return DoubleEquals;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    return DatetimeEquals;
  }
  case MTPipelineLib::PROP_TYPE_OPAQUE:
  {
    return BinaryEquals;
  }
  case MTPipelineLib::PROP_TYPE_SET:
  {
    return NULL;
  }
  default:
    throw std::runtime_error("Illegal PropValType");
  }
}

CompareFunction PhysicalFieldType::GetCompareFunction() const
{
  switch(mPipelineType)
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    return DecimalCompare;
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    return LongCompare;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    return LongCompare;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    return BooleanCompare;
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_STRING:
  {
    return StringCompare;
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
  {
    return UTF8StringCompare;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    return BigIntegerCompare;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    return DoubleCompare;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    return DatetimeCompare;
  }
  case MTPipelineLib::PROP_TYPE_OPAQUE:
  {
    return BinaryCompare;
  }
  case MTPipelineLib::PROP_TYPE_SET:
  {
    return NULL;
  }
  default:
    throw std::runtime_error("Illegal PropValType");
  }
}

BufferEndGetter PhysicalFieldType::GetBufferEndGetter() const
{
  switch(mPipelineType)
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    return mIsInline ? 
      &FieldAddress::InternalGetBufferEndDirectDecimalValue : 
      &FieldAddress::InternalGetBufferEndIndirectDecimalValue;
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    return &FieldAddress::InternalGetBufferEndLongValue;
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    return &FieldAddress::InternalGetBufferEndLongValue;
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    return &FieldAddress::InternalGetBufferEndBooleanValue;
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_STRING:
  {
    return mIsInline ? 
      &FieldAddress::InternalGetBufferEndDirectStringValue : 
      &FieldAddress::InternalGetBufferEndIndirectStringValue;
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
  {
    return &FieldAddress::InternalGetBufferEndIndirectUTF8StringValue;
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    return mIsInline ? 
      &FieldAddress::InternalGetBufferEndDirectBigIntegerValue : 
      &FieldAddress::InternalGetBufferEndIndirectBigIntegerValue;
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    return mIsInline ? 
      &FieldAddress::InternalGetBufferEndDirectDoubleValue : 
      &FieldAddress::InternalGetBufferEndIndirectDoubleValue;
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    return mIsInline ? 
      &FieldAddress::InternalGetBufferEndDirectDatetimeValue : 
      &FieldAddress::InternalGetBufferEndIndirectDatetimeValue;
  }
  case MTPipelineLib::PROP_TYPE_OPAQUE:
  {
    return &FieldAddress::InternalGetBufferEndDirectBinaryValue;
  }
  case MTPipelineLib::PROP_TYPE_SET:
  {
    return NULL;
  }
  default:
    throw std::runtime_error("Illegal PropValType");
  }
}

FieldAddressFree PhysicalFieldType::GetFreeFunction() const
{
  switch(GetPipelineType())
  {
  case MTPipelineLib::PROP_TYPE_SET:
    return IsList() ? &RunTimeDataAccessor::InternalFreeIndirectRecordValue : NULL;
  case MTPipelineLib::PROP_TYPE_STRING:
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
    return &RunTimeDataAccessor::InternalFreeIndirectStringValue; 
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
    return &RunTimeDataAccessor::InternalFreeIndirectUTF8StringValue;
  default:
    return NULL;
  }
}

FieldAddressClone PhysicalFieldType::GetCloneFunction() const
{
  switch(GetPipelineType())
  {
  case MTPipelineLib::PROP_TYPE_SET:
    return IsList() ? &RunTimeDataAccessor::InternalCloneIndirectRecordValue : NULL;
  case MTPipelineLib::PROP_TYPE_STRING:
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
    return &RunTimeDataAccessor::InternalCloneIndirectStringValue; 
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
    return &RunTimeDataAccessor::InternalCloneIndirectUTF8StringValue;
  default:
    return NULL;
  }
}

int PhysicalFieldType::GetColumnStorage() const
{
  switch(mPipelineType)
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    return mIsInline ? sizeof(decimal_traits::value) : sizeof(void*);
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    return sizeof(long);
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    return sizeof(long);
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    // Don't want to store anything smaller than a machine word (offsets).
    // TODO: Be smart about the layout and packing.
    return sizeof(bool) < sizeof(int) ? sizeof(int) : sizeof(bool);
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_STRING:
  {
//     return mIsInline ? mMaxBytes : sizeof(void *);
    return mIsInline ? mMaxBytes : sizeof(PrefixedWideString);
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
  {
    return sizeof(void *);
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    return mIsInline ? sizeof(boost::int64_t) : sizeof(void*);
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    return mIsInline ? sizeof(double) : sizeof(void*);
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    return mIsInline ? sizeof(date_time_traits::value) : sizeof(void*);
  }
  case MTPipelineLib::PROP_TYPE_OPAQUE:
  {
    return 16;
  }
  case MTPipelineLib::PROP_TYPE_SET:
  {
    if (IsList())
    {
      return sizeof(record_t);
    }
    else
    {
      int sz = 0;
      for(int i = 0; mNestedRecord->GetNumColumns(); i++)
      {
        sz += mNestedRecord->GetColumn(i)->GetPhysicalFieldType()->GetColumnStorage();
      }
      return sz;
    }
  }
  default:
    throw std::runtime_error("Illegal PropValType");
  }
}

SortKeyBuffer::SortKeyBuffer()
{
  mBuffer = new boost::uint8_t[64];
  mAllocatedLength = 64;
  mUsedLength = 0;
  mCurrentPos = mBuffer;
}

SortKeyBuffer::SortKeyBuffer(const SortKeyBuffer& buffer)
  :
  mBuffer(new boost::uint8_t[buffer.mAllocatedLength]),
  mUsedLength(buffer.mUsedLength),
  mAllocatedLength(buffer.mAllocatedLength),
  mCurrentPos(NULL)
{
  memcpy(mBuffer, buffer.mBuffer, mAllocatedLength);
  mCurrentPos = mBuffer + mUsedLength;
}

SortKeyBuffer::~SortKeyBuffer()
{
  delete [] mBuffer;
}

SortKeyBuffer& SortKeyBuffer::operator=(const SortKeyBuffer& buffer)
{
  delete [] mBuffer;
  mBuffer = new boost::uint8_t[buffer.mAllocatedLength];
  mAllocatedLength = buffer.mAllocatedLength;
  mUsedLength = buffer.mUsedLength;
  memcpy(mBuffer, buffer.mBuffer, mAllocatedLength);
  mCurrentPos = mBuffer + mUsedLength;
  return *this;
}

void SortKeyBuffer::DoubleBuffer(boost::int32_t minAdditionalLen)
{
  mAllocatedLength = mAllocatedLength * 2;
  mAllocatedLength = mAllocatedLength < (minAdditionalLen + mUsedLength) ?
    (minAdditionalLen + mUsedLength) : mAllocatedLength;
  boost::uint8_t * tmpBuffer = new boost::uint8_t[mAllocatedLength];
  memcpy(tmpBuffer, mBuffer, mUsedLength);
  delete [] mBuffer;
  mBuffer = tmpBuffer;
  mCurrentPos = mBuffer + mUsedLength;
}

RunTimeDataAccessor::RunTimeDataAccessor(ConstantPoolFactory * constantPool, long position, long offset, const PhysicalFieldType& physicalType)
  :
  FieldAddress(constantPool, position, offset),
  mPhysicalType(physicalType)
{
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

void RunTimeDataAccessor::InternalFreeIndirectRecordValue(record_t recordBuffer) const
{
  if (GetNull(recordBuffer) || NULL == *((record_t *)(recordBuffer+mOffset))) return;
  // Iterate over all records and call RecordMetadata::Free
  record_t end = *((record_t *)(recordBuffer+mOffset));
  record_t it = end;
  do
  {
    record_t tmp = RecordMetadata::GetNext(it);
    mPhysicalType.GetMetadata()->Free(it);
    it = tmp;
  } while(it != end);
}

void RunTimeDataAccessor::InternalFreeIndirectStringValue(record_t recordBuffer) const
{
  if (GetNull(recordBuffer)) return;

  wchar_t * ptr = ((PrefixedWideString *)(recordBuffer+mOffset))->String;

  delete [] ptr;
}

void RunTimeDataAccessor::InternalFreeIndirectUTF8StringValue(record_t recordBuffer) const
{
  if (GetNull(recordBuffer)) return;
  delete [] reinterpret_cast<const char *>(GetIndirectBuffer(recordBuffer));
}

void RunTimeDataAccessor::InternalCloneIndirectRecordValue(const_record_t source, record_t target) const
{
  SetNull(target);
  *((record_t *)(target+mOffset)) = NULL;

  if (GetNull(source) || NULL == *((record_t *)(source+mOffset))) 
  {
    return;
  }

  // Iterate over all records, clone and add
  const RecordMetadata * metadata = mPhysicalType.GetMetadata();
  ASSERT(metadata != NULL);
  record_t end = RecordMetadata::GetNext(*((record_t *)(source+mOffset)));
  ASSERT(end != NULL);
  record_t it = end;
  do
  {
    record_t tmp = metadata->Clone(it);
    InternalAppendIndirectRecordValue(target, tmp);
    it = RecordMetadata::GetNext(it);
  } while(it != end);
}

void RunTimeDataAccessor::InternalCloneIndirectStringValue(const_record_t source, record_t target) const
{
  SetNull(target);
  *((wchar_t **)(target+mOffset)) = NULL;

  if (GetNull(source) || NULL == GetIndirectBuffer(source)) 
  {
    return;
  }

  InternalSetIndirectStringValue2(target, GetIndirectBuffer(source));
}

void RunTimeDataAccessor::InternalCloneIndirectUTF8StringValue(const_record_t source, record_t target) const
{
  SetNull(target);
  *((char **)(target+mOffset)) = NULL;

  if (GetNull(source) || NULL == GetIndirectBuffer(source)) 
  {
    return;
  }

  InternalSetIndirectUTF8StringValue2(target, GetIndirectBuffer(source));
}

RecordSerializerInstruction RunTimeDataAccessor::GetRecordSerializerInstruction() const
{
  switch(GetPhysicalFieldType()->GetPipelineType())
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    return GetPhysicalFieldType()->IsInline() ? 
      RecordSerializerInstruction::DirectMemcpy(sizeof(decimal_traits::value)) : 
      RecordSerializerInstruction::IndirectMemcpy(sizeof(decimal_traits::value), this);
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    return RecordSerializerInstruction::DirectMemcpy(sizeof(long));
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    return RecordSerializerInstruction::DirectMemcpy(sizeof(long));
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    // Don't want to store anything smaller than a machine word (offsets).
    // TODO: Be smart about the layout and packing.
    return RecordSerializerInstruction::DirectMemcpy(sizeof(bool) < sizeof(int) ? sizeof(int) : sizeof(bool));
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_STRING:
  {
    return GetPhysicalFieldType()->IsInline() ? 
      RecordSerializerInstruction::DirectMemcpy(GetPhysicalFieldType()->GetMaxBytes()) : 
      RecordSerializerInstruction::IndirectWcscpy(this);
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
  {
    return RecordSerializerInstruction::IndirectStrcpy(this);
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    return GetPhysicalFieldType()->IsInline() ? 
      RecordSerializerInstruction::DirectMemcpy(sizeof(boost::int64_t)) : 
      RecordSerializerInstruction::IndirectMemcpy(sizeof(boost::int64_t), this);
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    return GetPhysicalFieldType()->IsInline() ? 
      RecordSerializerInstruction::DirectMemcpy(sizeof(double)) : 
      RecordSerializerInstruction::IndirectMemcpy(sizeof(double), this);
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    return GetPhysicalFieldType()->IsInline() ? 
      RecordSerializerInstruction::DirectMemcpy(sizeof(date_time_traits::value)) : 
      RecordSerializerInstruction::IndirectMemcpy(sizeof(date_time_traits::value), this);
  }
  case MTPipelineLib::PROP_TYPE_OPAQUE:
  {
    return RecordSerializerInstruction::DirectMemcpy(16);
  }
  default:
    throw std::runtime_error("Illegal PropValType");
  }
}

RecordDeserializerInstruction RunTimeDataAccessor::GetRecordDeserializerInstruction() const
{
  switch(GetPhysicalFieldType()->GetPipelineType())
  {
  case MTPipelineLib::PROP_TYPE_DECIMAL:
  {
    return GetPhysicalFieldType()->IsInline() ? 
      RecordDeserializerInstruction::DirectMemcpy(sizeof(decimal_traits::value)) : 
      RecordDeserializerInstruction::IndirectSetValue(this);
  }
  case MTPipelineLib::PROP_TYPE_ENUM:
  {
    return RecordDeserializerInstruction::DirectMemcpy(sizeof(long));
  }
  case MTPipelineLib::PROP_TYPE_INTEGER:
  {
    return RecordDeserializerInstruction::DirectMemcpy(sizeof(long));
  }
  case MTPipelineLib::PROP_TYPE_BOOLEAN:
  {
    // Don't want to store anything smaller than a machine word (offsets).
    // TODO: Be smart about the layout and packing.
    return RecordDeserializerInstruction::DirectMemcpy(sizeof(bool) < sizeof(int) ? sizeof(int) : sizeof(bool));
  }
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_STRING:
  {
    return GetPhysicalFieldType()->IsInline() ? 
      RecordDeserializerInstruction::DirectMemcpy(GetPhysicalFieldType()->GetMaxBytes()) : 
      RecordDeserializerInstruction::IndirectSetValue(this);
  }
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
  {
    return RecordDeserializerInstruction::IndirectSetValue(this);
  }
  case MTPipelineLib::PROP_TYPE_BIGINTEGER:
  {
    return GetPhysicalFieldType()->IsInline() ? 
      RecordDeserializerInstruction::DirectMemcpy(sizeof(boost::int64_t)) : 
      RecordDeserializerInstruction::IndirectSetValue(this);
  }
  case MTPipelineLib::PROP_TYPE_DOUBLE:
  {
    return GetPhysicalFieldType()->IsInline() ? 
      RecordDeserializerInstruction::DirectMemcpy(sizeof(double)) : 
      RecordDeserializerInstruction::IndirectSetValue(this);
  }
  case MTPipelineLib::PROP_TYPE_DATETIME:
  {
    return GetPhysicalFieldType()->IsInline() ? 
      RecordDeserializerInstruction::DirectMemcpy(sizeof(date_time_traits::value)) : 
      RecordDeserializerInstruction::IndirectSetValue(this);
  }
  case MTPipelineLib::PROP_TYPE_OPAQUE:
  {
    return RecordDeserializerInstruction::DirectMemcpy(16);
  }
  default:
    throw std::runtime_error("Illegal PropValType");
  }
}

BitcpyOperation RunTimeDataAccessor::GetBitcpyOperation(const RunTimeDataAccessor& source, const RunTimeDataAccessor& target)
{
  // Figure out whether we need shift right, left or none.
  if (source.mNullFlag < target.mNullFlag)
  {
    boost::uint32_t flag = source.mNullFlag;
    boost::int32_t shift=0;
    do
    {
      shift += 1;
      flag <<= 1;
    } while(flag != target.mNullFlag);
    
    return BitcpyOperation(BitcpyOperation::BITCPY_R, 
                           source.mNullWord, 
                           target.mNullWord, 
                           source.mNullFlag, 
                           shift);
  }
  else if (source.mNullFlag > target.mNullFlag)
  {
    boost::uint32_t flag = source.mNullFlag;
    boost::int32_t shift=0;
    do
    {
      shift += 1;
      flag >>= 1;
    } while(flag != target.mNullFlag);
    
    return BitcpyOperation(BitcpyOperation::BITCPY_L, 
                           source.mNullWord, 
                           target.mNullWord, 
                           source.mNullFlag, 
                           shift);
  }
  else
  {
    return BitcpyOperation(BitcpyOperation::BITCPY, 
                           source.mNullWord, 
                           target.mNullWord, 
                           source.mNullFlag, 
                           0);
   }
}

MemcpyOperation RunTimeDataAccessor::GetMemcpyOperation(const RunTimeDataAccessor& source, const RunTimeDataAccessor& target)
{
  if (*source.GetPhysicalFieldType() != *target.GetPhysicalFieldType())
  {
    throw std::runtime_error("Memcpy between different physical types not supported");
  }
  return MemcpyOperation(source.mOffset, target.mOffset, source.GetPhysicalFieldType()->GetColumnStorage());
}

FieldCopy::FieldCopy(const RunTimeDataAccessor& source, const RunTimeDataAccessor& target)
  :
  mSource(source),
  mTarget(target)
{
  SetupCopyFunction();
}

FieldCopy::~FieldCopy()
{
}

void FieldCopy::SetupCopyFunction()
{
  switch(mSource.GetPhysicalFieldType()->GetPipelineType())
  {
  case MTPipelineLib::PROP_TYPE_SET:
    mCopyFunction = &FieldCopy::InternalCopyIndirectRecordValue;
    break;
  case MTPipelineLib::PROP_TYPE_STRING:
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
    mCopyFunction = &FieldCopy::InternalCopyIndirectStringValue;
    break;
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
    mCopyFunction = &FieldCopy::InternalCopyIndirectUTF8StringValue;
    break;
  default:
    mCopyFunction = NULL;
    break;
  }
}

bool FieldCopy::IsMemcpy() const
{
  return mCopyFunction == NULL;
}

void FieldCopy::InternalCopyIndirectRecordValue(const_record_t source, record_t target) const
{
  mTarget.SetNull(target);
  *((record_t *)(target+mTarget.GetOffset())) = NULL;

  if (mSource.GetNull(source) || NULL == *((record_t *)(source+mSource.GetOffset()))) 
  {
    return;
  }

  // Iterate over all records, clone and add
  const RecordMetadata * metadata = mSource.GetPhysicalFieldType()->GetMetadata();
  ASSERT(metadata != NULL);
  record_t end = RecordMetadata::GetNext(*((record_t *)(source+mSource.GetOffset())));
  ASSERT(end != NULL);
  record_t it = end;
  do
  {
    record_t tmp = metadata->Clone(it);
    mTarget.InternalAppendIndirectRecordValue(target, tmp);
    it = RecordMetadata::GetNext(it);
  } while(it != end);
}

void FieldCopy::InternalCopyIndirectStringValue(const_record_t source, record_t target) const
{
  mTarget.SetNull(target);
  *((record_t *)(target+mTarget.GetOffset())) = NULL;

  if (mSource.GetNull(source) || NULL == mSource.GetIndirectBuffer(source)) 
  {
    return;
  }
  
  mTarget.InternalSetIndirectStringValue2(target, mSource.GetIndirectBuffer(source));
}

void FieldCopy::InternalCopyIndirectUTF8StringValue(const_record_t source, record_t target) const
{
  mTarget.SetNull(target);
  *((record_t *)(target+mTarget.GetOffset())) = NULL;

  if (mSource.GetNull(source) || NULL == mSource.GetIndirectBuffer(source)) 
  {
    return;
  }
  
  mTarget.InternalSetIndirectUTF8StringValue2(target, mSource.GetIndirectBuffer(source));
}

FieldTransfer::FieldTransfer(const RunTimeDataAccessor& source, const RunTimeDataAccessor& target)
  :
  mSource(source),
  mTarget(target)
{
  SetupTransferFunction();
}

FieldTransfer::~FieldTransfer()
{
}

void FieldTransfer::SetupTransferFunction()
{
  switch(mSource.GetPhysicalFieldType()->GetPipelineType())
  {
  case MTPipelineLib::PROP_TYPE_SET:
  case MTPipelineLib::PROP_TYPE_STRING:
  case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
  case MTPipelineLib::PROP_TYPE_ASCII_STRING:
    mTransferFunction = &FieldTransfer::InternalTransferIndirectValue;
    break;
  default:
    mTransferFunction = NULL;
    break;
  }
}

bool FieldTransfer::IsMemcpy() const
{
  return mTransferFunction == NULL;
}

void FieldTransfer::InternalTransferIndirectValue(record_t source, record_t target) const
{
  if (mSource.GetNull(source) || NULL == mSource.GetIndirectBuffer(source)) 
  {
    mTarget.SetNull(target);
    *((record_t *)(target+mTarget.GetOffset())) = NULL;
  }
  else
  {
    mTarget.ClearNull(target);
    *((void **) (target + mTarget.GetOffset())) = *((void **) (source + mSource.GetOffset()));
    mSource.SetNull(source);
    *((void **) (source + mSource.GetOffset())) = NULL;
  }
}

DataAccessor::DataAccessor(ConstantPoolFactory * constantPool, long position, long offset, const PhysicalFieldType& physicalType, const std::wstring& name)
  :
  RunTimeDataAccessor(constantPool, position, offset, physicalType),
  mName(name)
{
}

std::wstring DataAccessor::ToString() const
{
  return mName + L" " + mPhysicalType.ToString();
}

DatabaseColumn::DatabaseColumn(ConstantPoolFactory * constantPool, const PhysicalFieldType& physicalFieldType, bool isRequired, 
                               long position, long columnPosition, long offset, const std::wstring& name)
  :
  DataAccessor(constantPool, position, offset, physicalFieldType, name),
  mIsRequired(isRequired),
  mColumnPosition(columnPosition)
{
}

DatabaseColumn::DatabaseColumn(ConstantPoolFactory * constantPool, const std::wstring& enumNamespace, 
                               const std::wstring& enumEnumeration, bool isRequired, 
                               long position, long columnPosition, long offset, const std::wstring& name)
  :
  DataAccessor(constantPool, position, offset, PhysicalFieldType::Enum(), name),
  mIsRequired(isRequired),
  mColumnPosition(columnPosition),
  mEnumNamespace(enumNamespace),
  mEnumEnumeration(enumEnumeration)
{
}

RecordMetadata::RecordMetadata(const std::vector<const RecordMetadata*> & toConcat)
{
  std::vector<const LogicalRecord *> records;
  for(std::vector<const RecordMetadata*>::const_iterator it = toConcat.begin();
      it != toConcat.end();
      it++)
  {
    records.push_back(&(*it)->GetLogicalRecord());
  }
  LogicalRecord lr(records);

  this->operator=(RecordMetadata(lr));
}

RecordMetadata::RecordMetadata(const LogicalRecord & members)
  :
  MetadataCollection<DatabaseColumn>(members)
{
}

RecordMetadata& RecordMetadata::operator=(const RecordMetadata& lhs)
{
  MetadataCollection<DatabaseColumn>::operator=(lhs);
  return *this;
};

// void RecordMetadata::Add(const std::wstring& name, ConstantPoolFactory * ruleSet, 
//                          const PhysicalFieldType& sessionType, 
//                          bool isRequired, long position, long columnPosition)
// {
//   DatabaseColumn * db = new DatabaseColumn(ruleSet, sessionType, isRequired, position, columnPosition, GetRecordLength(), name);
//   MetadataCollection<DatabaseColumn>::Add(name, db);
// }

// void RecordMetadata::Add(const std::wstring& name, ConstantPoolFactory * ruleSet, 
//                          const std::wstring& enumNamespace, const std::wstring& enumEnumeration, 
//                          bool isRequired, long position, long columnPosition)
// {
//   DatabaseColumn * db = new DatabaseColumn(ruleSet, enumNamespace, enumEnumeration, isRequired, position, columnPosition, GetRecordLength(), name);
//   MetadataCollection<DatabaseColumn>::Add(name, db);
// }

std::string RecordMetadata::PrintMessage(const_record_t recordBuffer) const
{
  std::wstring out;
  wchar_t buf[1000];
  static const wchar_t hexDigits[16] = {L'0', L'1', L'2', L'3', L'4', L'5', L'6', L'7', L'8', L'9', L'A', L'B', L'C', L'D', L'E', L'F'};

  // TODO: Add printing to DataAccessor.
  for(int i=0; i<GetNumColumns(); i++)
  {
    DataAccessor * accessor = GetColumn(i);
    if (i>0) out += L", ";
    out += accessor->GetName();
    out += L":";
    if (accessor->GetNull(recordBuffer))
    {
      out += L"<NULL>";
      continue;
    }
    switch(accessor->GetPhysicalFieldType()->GetPipelineType())
    {
    case MTPipelineLib::PROP_TYPE_INTEGER: 
    {
      swprintf(buf, L"%d", accessor->GetLongValue(recordBuffer)); 
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_DOUBLE: 
    {
      swprintf(buf, L"%E", accessor->GetDoubleValue(recordBuffer));      
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_DATETIME: 
    case MTPipelineLib::PROP_TYPE_TIME: 
    {
      BSTR bstrVal;
      HRESULT hr = VarBstrFromDate(accessor->GetDatetimeValue(recordBuffer), LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
      ASSERT(!FAILED(hr));
      // Use a _bstr_t to delete the BSTR
      _bstr_t bstrtVal(bstrVal);
      out += bstrVal;
      break;
    }
    case MTPipelineLib::PROP_TYPE_BOOLEAN: 
    {
      swprintf(buf, L"%s", accessor->GetBooleanValue(recordBuffer) ? L"TRUE" : L"FALSE");      
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_ENUM: 
    {
      swprintf(buf, L"%d", accessor->GetEnumValue(recordBuffer));      
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_DECIMAL: 
    {
      BSTR bstrVal;
      LPDECIMAL decPtr = const_cast<DECIMAL *>(accessor->GetDecimalValue(recordBuffer));
      HRESULT hr = VarBstrFromDec(decPtr, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
      ASSERT(!FAILED(hr));
      // Use a _bstr_t to delete the BSTR
      _bstr_t bstrtVal(bstrVal, false);
      out += bstrVal;
      break;
    }
    case MTPipelineLib::PROP_TYPE_ASCII_STRING: 
    {
      wstring tmp;
      ::ASCIIToWide(tmp, accessor->GetUTF8StringValue(recordBuffer));
      out += tmp;
      break;
    }
    case MTPipelineLib::PROP_TYPE_STRING: 
    case MTPipelineLib::PROP_TYPE_UNICODE_STRING: 
    {
      out += accessor->GetStringValue(recordBuffer);
      break;
    }
    case MTPipelineLib::PROP_TYPE_BIGINTEGER: 
    {
      swprintf(buf, L"%I64d", accessor->GetBigIntegerValue(recordBuffer));      
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_OPAQUE: 
    {
      const boost::uint8_t * val = accessor->GetBinaryValue(recordBuffer);
      wchar_t * bufit = buf;
      *bufit++ = L'0';
      *bufit++ = L'x';
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      // Null terminate
      *bufit++ = 0;
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_SET: 
    {
      out += L"[\n";
      const RecordMetadata * nestedMetadata = accessor->GetPhysicalFieldType()->GetMetadata();
      // Iterate over nested records.
      const_record_t end = accessor->GetRecordValue(recordBuffer);
      if (end)
      {
        end = RecordMetadata::GetNext((record_t) end);
        const_record_t it = end;
        do
        {
          out += L"\t[";
          std::string tmp = nestedMetadata->PrintMessage(it);
          std::wstring wtmp;
          ::ASCIIToWide(wtmp, tmp);
          out += wtmp;
          // TODO: Investigate putting in const-correct RecordMetadata::GetNext
          out += L"]";
          it = RecordMetadata::GetNext((record_t) it);
          if (it != end) out += L", ";
          out += L"\n";
        } while (it != end);
      }
      out += L"]";
      break;
    }
    default:          
      throw std::logic_error("Unsupported data type");
    }
  }

  std::string utf8Out;
  ::WideStringToUTF8(out, utf8Out);
  return utf8Out;
}

std::wstring RecordMetadata::getDescription() const
{
  std::wstringstream out;
  std::map<std::wstring, std::wstring> fieldMap;

  for (int i=0; i<GetNumColumns(); i++)
  {
    DataAccessor *accessor = GetColumn(i);
    if (accessor == NULL)
    {
      continue;
    }
        
    std::wstringstream fieldOut;
    fieldOut << PhysicalFieldType::GetMTSQLDatatype(accessor) << L" " << i+1;    
    fieldMap[accessor->GetName()] = fieldOut.str();
  }

  out << L"{\n";
  unsigned int j=0;
  for (std::map<std::wstring, std::wstring>::const_iterator
       it = fieldMap.begin(); it != fieldMap.end(); it++)
  {
    out << L"  " << (*it).first << L" " << (*it).second;

    if (j != fieldMap.size()-1)
    {
      out << L",\n";
    }
    else
    {
      out << L"\n";
    }

    j++;
  }
  out << L"}";

  return out.str();
}

// void RecordMetadata::Project(const std::vector<std::wstring>& projectionColumns,
//                              bool takeComplement,
//                              RecordMetadata& result,
//                              std::vector<std::wstring>& missingColumns) const
// {
//   // Blank slate.
//   missingColumns.clear();

//   if (takeComplement)
//   {
//     std::set<std::wstring> exclusionSet;
//     for(std::vector<std::wstring>::const_iterator it = projectionColumns.begin();
//         it != projectionColumns.end();
//         it++)
//     {
//       exclusionSet.insert(boost::to_upper_copy(*it));
//     }

//     std::vector<DatabaseColumn*> complementaryColumns;
//     for(int i=0; i<this->GetNumColumns(); i++)
//     {
//       std::wstring colName = boost::to_upper_copy(this->GetColumn(i)->GetName());
//       // Make sure that the column is not in the projection list.
//       if (exclusionSet.end() == exclusionSet.find(colName))
//       {
//         complementaryColumns.push_back(this->GetColumn(i));
//       }
//     }
//     result.Init(complementaryColumns.size());
//     for(std::vector<DatabaseColumn*>::const_iterator it = complementaryColumns.begin();
//         it != complementaryColumns.end();
//         it++)
//     {
//       result.Add((*it)->GetName(), 
//                  (*it)->GetConstantPool(),
//                  *(*it)->GetPhysicalFieldType(),
//                  (*it)->IsRequired(), 
//                  it - complementaryColumns.begin(), 
//                  it - complementaryColumns.begin());
//     }    
//   }
//   else
//   {
//     result.Init(projectionColumns.size());

//     boost::int32_t pos(0);
//     for(std::vector<std::wstring>::const_iterator it = projectionColumns.begin();
//         it != projectionColumns.end();
//         it++)
//     {
//       if (!this->HasColumn(*it))
//       {
//         missingColumns.push_back(*it);
//         continue;
//       }
    
//       DatabaseColumn * col = this->GetColumn(*it);
//       result.Add(*it, 
//                  col->GetConstantPool(),
//                  *col->GetPhysicalFieldType(),
//                  col->IsRequired(), pos, pos);
//       pos += 1;
//     }
//   }  
// }

// bool RecordMetadata::NestCollection(const std::wstring& nestColumn,
//                                     const RecordMetadata& nestedRecord,
//                                     RecordMetadata& result) const
// {
//   bool ret = true;
//   if (this->HasColumn(nestColumn))
//   {
//     // Let everyone know that the result can't be trusted.
//     // Still do our best so that a type check can continue if it wants to.
//     // Create a unique name and use that as the nest column.
//     boost::int32_t i = 1;
//     while(true)
//     {
//       if (!this->HasColumn((boost::wformat(L"%1%%2%") % nestColumn % i).str()))
//       {
//         break;
//       }
//       i += 1;
//     }
//     ret = false;
//   }

//   result.Init(this->GetNumColumns()+1);
//   int parentField = 0;
//   for(int i = 0; i<this->GetNumColumns(); i++)
//   {
//     DatabaseColumn * col = this->GetColumn(i);

//     result.Add(col->GetName(), 
//                GlobalConstantPoolFactory::Get(), 
//                *col->GetPhysicalFieldType(), 
//                col->IsRequired(), 
//                parentField, 
//                parentField);
//     parentField += 1;
//   }

//   // Add the nested record to the parent
//   result.Add(nestColumn, 
//              GlobalConstantPoolFactory::Get(), 
//              PhysicalFieldType::Record(nestedRecord), 
//              false, parentField, parentField); 
//   return ret;
// }

// bool RecordMetadata::NestColumns(const std::wstring& nestColumn,
//                                   const std::vector<std::wstring>& childColumns,
//                                   bool nestCollection,
//                                   RecordMetadata& result) const
// {
//   std::set<std::wstring> groupSet;
//   // Make child lookup case insensitive and faster.
//   for(std::vector<std::wstring>::const_iterator it = childColumns.begin();
//       it != childColumns.end();
//       ++it)
//   {
//     groupSet.insert(boost::to_upper_copy(*it));
//   }

//   RecordMetadata childRecord;
//   childRecord.Init(childColumns.size());
//   int childField = 0;
//   result.Init(this->GetNumColumns()-childColumns.size()+1);
//   int parentField = 0;
//   for(int i = 0; i<this->GetNumColumns(); i++)
//   {
//     DatabaseColumn * col = this->GetColumn(i);

//     if(groupSet.find(boost::to_upper_copy<std::wstring>(col->GetName())) == groupSet.end())
//     {
//       result.Add(col->GetName(), GlobalConstantPoolFactory::Get(), *col->GetPhysicalFieldType(), col->IsRequired(), parentField, parentField);
//       parentField += 1;
//     }
//     else
//     {
//       childRecord.Add(col->GetName(), GlobalConstantPoolFactory::Get(), *col->GetPhysicalFieldType(), col->IsRequired(), childField, childField);
//       childField += 1;
//     }
//   }

//   // Add the record to the parent; nested or not depending on configuration.
//   result.Add(nestColumn, 
//              GlobalConstantPoolFactory::Get(), 
//              PhysicalFieldType::Record(childRecord, nestCollection), 
//              false, 
//              parentField, 
//              parentField);

//   return true;
// }

// void RecordMetadata::UnnestColumn(const std::wstring& nestColumn,
//                                   RecordMetadata& result,
//                                   std::vector<std::wstring>& columnCollisions) const
// {
//   columnCollisions.clear();

//   if(!this->HasColumn(nestColumn))
//   {
//     result = *this;
//     // throw MissingFieldException(*this, *mInputPorts[0], nestColumn);
//   }

//   if(this->GetColumn(nestColumn)->GetPhysicalFieldType()->GetPipelineType() != MTPipelineLib::PROP_TYPE_SET ||
//      !this->GetColumn(nestColumn)->GetPhysicalFieldType()->IsList())
//   {
//     // std::string utf8Msg;
//     // ::WideStringToUTF8((boost::wformat(L"Field %1% of operator %2% must be a list of records") % nestColumn % mName).str(), utf8Msg);
//     // throw std::logic_error(utf8Msg);
//   }

//   // All parent fields except the nested collection stay in the parent.
//   // All nested collection fields are raised into the parent.
//   // Parent fields have prefix applied.
//   result.Init(this->GetNumColumns() + 
//               this->GetColumn(nestColumn)->GetPhysicalFieldType()->GetMetadata()->GetNumColumns() - 
//               1);
//   int parentField = 0;
//   for(int i=0; i<this->GetNumColumns(); i++)
//   {
//     DatabaseColumn * col = this->GetColumn(i);
//     if (boost::algorithm::iequals(col->GetName(), nestColumn)) continue;
//     result.Add(col->GetName(), GlobalConstantPoolFactory::Get(), *col->GetPhysicalFieldType(), col->IsRequired(), parentField, parentField);
//     parentField += 1;
//   }

//   for(int i=0; i<this->GetColumn(nestColumn)->GetPhysicalFieldType()->GetMetadata()->GetNumColumns(); i++)
//   {
//     DatabaseColumn * col = this->GetColumn(nestColumn)->GetPhysicalFieldType()->GetMetadata()->GetColumn(i);
//     if (result.HasColumn(col->GetName()))
//     {
//       columnCollisions.push_back(col->GetName());
//     }
//     else
//     {
//       result.Add(col->GetName(), 
//                  GlobalConstantPoolFactory::Get(), 
//                  *col->GetPhysicalFieldType(), 
//                  col->IsRequired(), 
//                  parentField, 
//                  parentField);
//       parentField += 1;
//     }
//   }
// }

// void RecordMetadata::ColumnComplement(const std::vector<std::wstring>& columns,
//                                       std::vector<std::wstring>& columnComplement,
//                                       std::vector<std::wstring>& missingColumns) const
// {
//   columnComplement.clear();
//   missingColumns.clear();

//   std::map<std::wstring, bool> groupMap;
//   // Make column lookup case insensitive and faster.  Also detect whether
//   // there are names in the columns collection that are missing from this record structure.
//   for(std::vector<std::wstring>::const_iterator it = columns.begin();
//       it != columns.end();
//       ++it)
//   {
//     // Inidicate that we have not yet matched by a column in this.
//     groupMap[boost::to_upper_copy(*it)] = false;
//   }

//   for(int i = 0; i<this->GetNumColumns(); i++)
//   {
//     DatabaseColumn * col = this->GetColumn(i);
//     std::wstring upperCol = boost::to_upper_copy<std::wstring>(col->GetName());
//     if(groupMap.find(upperCol) == groupMap.end())
//     {
//       columnComplement.push_back(col->GetName());
//     }
//     else
//     {
//       groupMap[upperCol] = true;
//     }
//   }

//   for(std::map<std::wstring, bool>::const_iterator mapIt = groupMap.begin();
//       mapIt != groupMap.end();
//       ++mapIt)
//   {
//     if (!mapIt->second)
//       missingColumns.push_back(mapIt->first);
//   }
// }


// std::string RecordResultSet::GetString(int aPos)
// {
//   mLast = aPos;
//   std::string asciiString;
//   ::WideStringToUTF8(mMetadata->GetStringValue(mBuffer, aPos), asciiString);
//   return asciiString;
// }
// COdbcTimestamp RecordResultSet::GetTimestamp(int aPos)
// {
//   mLast = aPos;
//   date_time_traits::value dt = mMetadata->GetDatetimeValue(mBuffer, aPos-1);
//   COdbcTimestamp ts;
//   ::OLEDateToOdbcTimestamp(&dt, (TIMESTAMP_STRUCT *) ts.GetBuffer());
//   return ts;
// }
// COdbcDecimal RecordResultSet::GetDecimal(int aPos)
// {
//   mLast = aPos;
//   COdbcDecimal dec;
//   ::DecimalToOdbcNumeric(mMetadata->GetDecimalValue(mBuffer, aPos), 
//                          (SQL_NUMERIC_STRUCT *) dec.GetBuffer());
//   return dec;
// }

RecordMerge::RecordMerge(const RecordMetadata * lhs, 
                         const RecordMetadata * rhs,
                         const std::wstring &lhsName,
                         const std::wstring &rhsName)
{
  std::vector<const LogicalRecord *> records;
  records.push_back(&lhs->GetLogicalRecord());
  records.push_back(&rhs->GetLogicalRecord());

  // Try to merge the two record types together.
  // This might not work because column names
  // might collide.
  
  try
  {
    LogicalRecord lr(records);
    mMergedMetadata = new RecordMetadata(lr);
  }
  catch (std::exception e)
  {
    std::string err = "";
    if (e.what() != NULL)
    {
      err = e.what();
    }

    std::string left;
    ::WideStringToUTF8(lhsName, left);
    std::string right;
    ::WideStringToUTF8(rhsName, right);

    // Report the names of the ports involved.
    if (left.length() > 0)
    {
      err += " (1) " + left;
    }

    if (right.length() > 0)
    {
      err += " (2) " + right;
    }
    throw std::logic_error(err);
  }


  mLeftBitmapLength = lhs->GetBitmapLength();
  mRightBitmapLength = rhs->GetBitmapLength();

  GenerateInstructions(*mMergedMetadata, *lhs, mLeftBitcpy, mLeftMemcpy);
  GenerateInstructions(*mMergedMetadata, *rhs, mRightBitcpy, mRightMemcpy);
  // Extract out the nested records
  for(int i=0; i<lhs->GetNumColumns(); i++)
  {
    FieldCopy fc(*lhs->GetColumn(i), *mMergedMetadata->GetColumn(lhs->GetColumn(i)->GetName()));
    if (!fc.IsMemcpy())
      mLeftNestedColumns.push_back(fc);
//     FieldTransfer ft(*lhs->GetColumn(i), *mMergedMetadata->GetColumn(lhs->GetColumn(i)->GetName()));
//     if (!ft.IsMemcpy())
//       mLeftTransferColumns.push_back(ft);
  }
  for(int i=0; i<rhs->GetNumColumns(); i++)
  {
    FieldCopy fc(*rhs->GetColumn(i), *mMergedMetadata->GetColumn(rhs->GetColumn(i)->GetName()));
    if (!fc.IsMemcpy())
      mRightNestedColumns.push_back(fc);
//     FieldTransfer ft(*rhs->GetColumn(i), *mMergedMetadata->GetColumn(rhs->GetColumn(i)->GetName()));
//     if (!ft.IsMemcpy())
//       mRightTransferColumns.push_back(ft);
  }
}

RecordMerge::RecordMerge(const RecordMerge& rm)
  :
  mLeftBitmapLength(rm.mLeftBitmapLength),
  mRightBitmapLength(rm.mRightBitmapLength),
  mLeftBitcpy(rm.mLeftBitcpy),
  mLeftMemcpy(rm.mLeftMemcpy),
  mRightBitcpy(rm.mRightBitcpy),
  mRightMemcpy(rm.mRightMemcpy),
  mLeftNestedColumns(rm.mLeftNestedColumns),
  mRightNestedColumns(rm.mRightNestedColumns),
  mLeftTransferColumns(rm.mLeftTransferColumns),
  mRightTransferColumns(rm.mRightTransferColumns)
{
  mMergedMetadata = rm.mMergedMetadata != NULL ? new RecordMetadata(*rm.mMergedMetadata) : NULL;
}

RecordMerge::RecordMerge()
  :
  mMergedMetadata(NULL)
{
}

const RecordMerge& RecordMerge::operator=(const RecordMerge& rm)
{
  mLeftBitmapLength = rm.mLeftBitmapLength;
  mRightBitmapLength = rm.mRightBitmapLength;
  mLeftBitcpy = rm.mLeftBitcpy;
  mLeftMemcpy = rm.mLeftMemcpy;
  mRightBitcpy = rm.mRightBitcpy;
  mRightMemcpy = rm.mRightMemcpy;
  mLeftNestedColumns = rm.mLeftNestedColumns;
  mRightNestedColumns = rm.mRightNestedColumns;
  mLeftTransferColumns = rm.mLeftTransferColumns;
  mRightTransferColumns = rm.mRightTransferColumns;
  return *this;
}

RecordMerge::~RecordMerge()
{
  delete mMergedMetadata;
}

void RecordMerge::GenerateInstructions(const RecordMetadata& target,
                                       const RecordMetadata& source,
                                       std::vector<BitcpyOperation>& bitcpyOperations,
                                       std::vector<MemcpyOperation>& memcpyOperations)
{
  std::vector<BitcpyOperation> rawBitcpy;
  std::vector<MemcpyOperation> rawMemcpy;
  for(boost::int32_t i = 0; i < target.GetNumColumns(); i++)
  {
    DataAccessor * t = target.GetColumn(i);
    if (!source.HasColumn(target.GetColumnName(i)))
    {
      // Perhaps should be configurable whether this should 
      // be allowed or throw.
      continue;
    }
    DataAccessor * s = source.GetColumn(target.GetColumnName(i));
    
    // For the moment we don't support any conversions, the types
    // must be the same.
    if (*s->GetPhysicalFieldType() != *t->GetPhysicalFieldType())
    {
      throw std::runtime_error("Type mismatch in RecordProjection");
    }

    // Now generate the bitcpy instructions
    rawBitcpy.push_back(DataAccessor::GetBitcpyOperation(*s, *t));
    rawMemcpy.push_back(DataAccessor::GetMemcpyOperation(*s, *t));
  }

  // Now optimize by applying the above rules.  For the moment, skip 5) since
  // our code generation doesn't need it.

  // Apply rules 3) and 4).
  std::map<BitcpyOperation, BitcpyOperation, Bitcpy_greater> consolidate;
  for(std::vector<BitcpyOperation>::iterator it = rawBitcpy.begin();
      it != rawBitcpy.end();
      it++)
  {
    std::map<BitcpyOperation, BitcpyOperation, Bitcpy_greater>::iterator mapit = consolidate.find(*it);
    if (mapit == consolidate.end())
    {
      consolidate[*it] = *it;
    }
    else
    {
      mapit->second.SourceBitmask |= it->SourceBitmask;
    }
  }

  // Apply rule 2)
  for(std::map<BitcpyOperation, BitcpyOperation, Bitcpy_greater>::iterator it = consolidate.begin();
      it != consolidate.end();
      it++)
  {
    if (it->second.Ty == BitcpyOperation::BITCPY &&
        it->second.SourceBitmask == std::size_t (-1))
    {
      rawMemcpy.push_back(MemcpyOperation(it->second.SourceOffset,
                                          it->second.TargetOffset,
                                          sizeof(it->second.SourceBitmask)));
    }
    else
    {
      bitcpyOperations.push_back(it->second);
    }
  }

  // Apply rule 1)
  if (rawMemcpy.size() > 0)
  {
    std::sort(rawMemcpy.begin(), rawMemcpy.end(), Memcpy_less);
    memcpyOperations.push_back(rawMemcpy.front());
    for(std::vector<MemcpyOperation>::iterator it = rawMemcpy.begin()+1;
        it != rawMemcpy.end();
        it++)
    {
      if (it->SourceOffset == memcpyOperations.back().SourceOffset + memcpyOperations.back().Sz &&
          it->TargetOffset == memcpyOperations.back().TargetOffset + memcpyOperations.back().Sz)
      {
        memcpyOperations.back().Sz += it->Sz;
      }
      else
      {
        memcpyOperations.push_back(*it);
      }
    }
  }
}

boost::int32_t RecordSerializerInstruction::GetMinimumSize() const
{
  switch (Ty)
  {
  case DIRECT_MEMCPY:
    return Len;
  case INDIRECT_MEMCPY:
    return Len+sizeof(boost::int32_t);
  case INDIRECT_STRCPY:
    return sizeof(boost::int32_t) + sizeof(char);
  case INDIRECT_WCSCPY:
    return sizeof(boost::int32_t) + sizeof(wchar_t);
  }
  return -1;
}

RecordProjection::RecordProjection()
  :
  mIsIdentity(false)
{
}

RecordProjection::RecordProjection(const RecordProjection& rhs)
  :
  mBitcpy(rhs.mBitcpy),
  mMemcpy(rhs.mMemcpy),
  mCopy(rhs.mCopy),
  mTransfer(rhs.mTransfer),
  mIsIdentity(rhs.mIsIdentity)
{
}

RecordProjection::RecordProjection(const RecordMetadata & source, 
                                   const RecordMetadata & target)
  :
  mIsIdentity(false)
{
  // First check if we have an identity transformation
  if (source.GetNumColumns() == target.GetNumColumns())
  {
    mIsIdentity = true;
    for(boost::int32_t i = 0; i < target.GetNumColumns(); i++)
    {
      DataAccessor * t = target.GetColumn(i);
      DataAccessor * s = source.GetColumn(i);

      if (boost::to_upper_copy<std::wstring>(t->GetName()) != boost::to_upper_copy<std::wstring>(s->GetName()))
      {
        mIsIdentity = false;
        break;
      }
    
      if (*s->GetPhysicalFieldType() != *t->GetPhysicalFieldType())
      {
        mIsIdentity = false;
        break;
      }
    }
  }
  // Default mapping logic is to map all target columns that match 
  // a source column (case-insensitive equality).
  std::map<std::wstring, std::wstring> sourceTargetMap;
  for(boost::int32_t i = 0; i < target.GetNumColumns(); i++)
  {
    if (source.HasColumn(target.GetColumnName(i)))
    {
      sourceTargetMap[source.GetColumn(target.GetColumnName(i))->GetName()] = target.GetColumnName(i);
    }
  }
  Init(source, target, sourceTargetMap);
}

RecordProjection::RecordProjection(const RecordMetadata & source, 
                                   const RecordMetadata & target,
                                   const std::map<std::wstring,std::wstring> & sourceTargetMap)
  :
  mIsIdentity(false)
{
  Init(source, target, sourceTargetMap);
}

void RecordProjection::Init(const RecordMetadata & source, 
                            const RecordMetadata & target,
                            const std::map<std::wstring, std::wstring>& sourceTargetMap)
{ 
  // Basic Instructions:
  // 1) memcpy sourceOffset, targetOffset, sz
  // 2) bitcpy_l sourceOffset, targetOffset, sourceBitmask, rotate
  // 3) bitcpy_r sourceOffset, targetOffset, sourceBitmask, rotate
  // 4) bitcpy sourceOffset, targetOffset, sourceBitmask
  //
  // The above instruction set supports some important optimizations.
  // Available optimizations:
  // 1)
  // Two instructions:
  // memcpy sourceOffset, targetOffset, sz1
  // memcpy sourceOffset + sz1, targetOffset + sz1, sz2
  // can be replaced with one:
  // memcpy sourceOffset, targetOffset, sz1+sz2
  // 2)
  // A full word bit copy: 
  // bitcpy sourceOffset, targetOffset, 0xffffffff, 0
  // can be replaced with a memcpy 
  // memcpy sourceOffset, targetOffset, sizeof(int)
  // 3)
  // Two instructions:
  // bitcpy_{l,r} sourceOffset, targetOffset, sourceBitmask1, rotate
  // bitcpy_{l,r} sourceOffset, targetOffset, sourceBitmask2, rotate
  // can be replaced by one
  // bitcpy_{l,r} sourceOffset, targetOffset, sourceBitmask1 | sourceBitmask2, rotate
  // 4)
  // Two instructions:
  // bitcpy sourceOffset, targetOffset, sourceBitmask1
  // bitcpy sourceOffset, targetOffset, sourceBitmask2
  // can be replaced by:
  // bitcpy sourceOffset, targetOffset, sourceBitmask1 | sourceBitmask2
  // 5)
  // Any instructions:
  // bitcpy_{r,l} sourceOffset, targetOffset, sourceBitmask, 0
  // can be replaced by:
  // bitcpy sourceOffset, targetOffset, sourceBitmask
  //
  // A reasonable optimization algorithm is to run the above optimizations
  // in reverse order 5) to 1).

  // First generate the basic program based on the projection

  std::vector<BitcpyOperation> rawBitcpy;
  std::vector<MemcpyOperation> rawMemcpy;
  for(std::map<std::wstring, std::wstring>::const_iterator mappingIt = sourceTargetMap.begin();
      mappingIt != sourceTargetMap.end();
      ++mappingIt)
  {
    DataAccessor * t = target.GetColumn(mappingIt->second);
    DataAccessor * s = source.GetColumn(mappingIt->first);
    
    // For the moment we don't support any conversions, the types
    // must be the same.
    if (*s->GetPhysicalFieldType() != *t->GetPhysicalFieldType())
    {
      throw std::runtime_error("Type mismatch in RecordProjection");
    }

    // Now generate the bitcpy instructions
    rawBitcpy.push_back(DataAccessor::GetBitcpyOperation(*s, *t));
    rawMemcpy.push_back(DataAccessor::GetMemcpyOperation(*s, *t));
  }

  // Now optimize by applying the above rules.  For the moment, skip 5) since
  // our code generation doesn't need it.

  // Apply rules 3) and 4).
  std::map<BitcpyOperation, BitcpyOperation, Bitcpy_greater> consolidate;
  for(std::vector<BitcpyOperation>::iterator it = rawBitcpy.begin();
      it != rawBitcpy.end();
      it++)
  {
    std::map<BitcpyOperation, BitcpyOperation, Bitcpy_greater>::iterator mapit = consolidate.find(*it);
    if (mapit == consolidate.end())
    {
      consolidate[*it] = *it;
    }
    else
    {
      mapit->second.SourceBitmask |= it->SourceBitmask;
    }
  }

  // Apply rule 2)
  for(std::map<BitcpyOperation, BitcpyOperation, Bitcpy_greater>::iterator it = consolidate.begin();
      it != consolidate.end();
      it++)
  {
    if (it->second.Ty == BitcpyOperation::BITCPY &&
        it->second.SourceBitmask == std::size_t (-1))
    {
      rawMemcpy.push_back(MemcpyOperation(it->second.SourceOffset,
                                          it->second.TargetOffset,
                                          sizeof(it->second.SourceBitmask)));
    }
    else
    {
      mBitcpy.push_back(it->second);
    }
  }

  // Apply rule 1)
  std::sort(rawMemcpy.begin(), rawMemcpy.end(), Memcpy_less);
  mMemcpy.push_back(rawMemcpy.front());
  for(std::vector<MemcpyOperation>::iterator it = rawMemcpy.begin()+1;
      it != rawMemcpy.end();
      it++)
  {
    if (it->SourceOffset == mMemcpy.back().SourceOffset + mMemcpy.back().Sz &&
        it->TargetOffset == mMemcpy.back().TargetOffset + mMemcpy.back().Sz)
    {
      mMemcpy.back().Sz += it->Sz;
    }
    else
    {
      mMemcpy.push_back(*it);
    }
  }

  // Handle fields that cannot be memcpy'd
  for(std::map<std::wstring, std::wstring>::const_iterator mappingIt = sourceTargetMap.begin();
      mappingIt != sourceTargetMap.end();
      ++mappingIt)
  {
    FieldCopy fc(*source.GetColumn(mappingIt->first), *target.GetColumn(mappingIt->second));      
    if (!fc.IsMemcpy())
      mCopy.push_back(fc);
    FieldTransfer ft(*source.GetColumn(mappingIt->first), *target.GetColumn(mappingIt->second));      
    if (!ft.IsMemcpy())
      mTransfer.push_back(ft);
  }
}

RecordProjection::~RecordProjection()
{
}

RecordProjection& RecordProjection::operator=(const RecordProjection& rhs)
{
  mBitcpy = rhs.mBitcpy;
  mMemcpy = rhs.mMemcpy;
  mCopy = rhs.mCopy;
  mTransfer = rhs.mTransfer;
  mIsIdentity = rhs.mIsIdentity;
  return *this;
}

bool RecordProjection::IsIdentity() const
{
  return mIsIdentity;
}

RecordPrinter::RecordPrinter()
{
}

RecordPrinter::RecordPrinter(const LogicalRecord& logicalRecord,
                             const RecordMetadata& physicalRecord)
{
  ProcessSubrecord(L"", logicalRecord, physicalRecord);
}

RecordPrinter::~RecordPrinter()
{
}

void RecordPrinter::ProcessSubrecord(const std::wstring& context,
                                     const LogicalRecord& logicalRecord,
                                     const RecordMetadata& physicalRecord)
{
  // Walk and print data in logical order
  for(LogicalRecord::const_iterator it = logicalRecord.begin();
      it != logicalRecord.end();
      ++it)
  {
    if(it->GetType().GetPipelineType() == MTPipelineLib::PROP_TYPE_SET)
    {
      if (it->GetType().IsList())
      {
        mFields.push_back(std::make_pair<
                          DataAccessor*, 
                          RecordPrinter*>(physicalRecord.GetColumn(context + it->GetName()), 
                                          new RecordPrinter(it->GetType().GetMetadata(),
                                                            *physicalRecord.GetColumn(it->GetName())->GetPhysicalFieldType()->GetMetadata())));
      }
      else
      {
        ProcessSubrecord(context + it->GetName() + LogicalRecord::GetFieldSeparator(),
                         it->GetType().GetMetadata(),
                         physicalRecord);
      }
    }
    else
    {
      mFields.push_back(std::make_pair<
                        DataAccessor*, 
                        RecordPrinter*>(physicalRecord.GetColumn(context + it->GetName()), 
                                        NULL));
    }
  }
}

std::string RecordPrinter::PrintMessage(const_record_t recordBuffer) 
{
  return PrintMessage(recordBuffer, L", ", L":");
}

std::string RecordPrinter::PrintMessage(const_record_t recordBuffer,
                                        std::wstring fieldSeparator,
                                        std::wstring valueSeparator) 
{
  std::wstring out;
  wchar_t buf[1000];
  static const wchar_t hexDigits[16] = {L'0', L'1', L'2', L'3', L'4', L'5', L'6', L'7', L'8', L'9', L'A', L'B', L'C', L'D', L'E', L'F'};

  // TODO: Add printing to DataAccessor.
  for(std::vector<std::pair<DataAccessor*, RecordPrinter *> >::const_iterator vit = mFields.begin();
      vit != mFields.end();
      ++vit)
  {
    const DataAccessor * accessor = vit->first;

    // Put a separater between the fields.
    if (vit != mFields.begin()) 
    {
      out += fieldSeparator;
    }

    out += accessor->GetName();
    out += valueSeparator;

    if (accessor->GetNull(recordBuffer))
    {
      out += L"<NULL>";
      continue;
    }
    switch(accessor->GetPhysicalFieldType()->GetPipelineType())
    {
    case MTPipelineLib::PROP_TYPE_INTEGER: 
    {
      swprintf(buf, L"%d", accessor->GetLongValue(recordBuffer)); 
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_DOUBLE: 
    {
      swprintf(buf, L"%E", accessor->GetDoubleValue(recordBuffer));      
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_DATETIME: 
    case MTPipelineLib::PROP_TYPE_TIME: 
    {
      BSTR bstrVal;
      HRESULT hr = VarBstrFromDate(accessor->GetDatetimeValue(recordBuffer), LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
      ASSERT(!FAILED(hr));
      // Use a _bstr_t to delete the BSTR
      _bstr_t bstrtVal(bstrVal);
      out += bstrVal;
      break;
    }
    case MTPipelineLib::PROP_TYPE_BOOLEAN: 
    {
      swprintf(buf, L"%s", accessor->GetBooleanValue(recordBuffer) ? L"TRUE" : L"FALSE");      
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_ENUM: 
    {
      swprintf(buf, L"%d", accessor->GetEnumValue(recordBuffer));      
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_DECIMAL: 
    {
      BSTR bstrVal;
      LPDECIMAL decPtr = const_cast<DECIMAL *>(accessor->GetDecimalValue(recordBuffer));
      HRESULT hr = VarBstrFromDec(decPtr, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
      ASSERT(!FAILED(hr));
      // Use a _bstr_t to delete the BSTR
      _bstr_t bstrtVal(bstrVal, false);
      out += bstrVal;
      break;
    }
    case MTPipelineLib::PROP_TYPE_ASCII_STRING: 
    {
      wstring tmp;
      ::ASCIIToWide(tmp, accessor->GetUTF8StringValue(recordBuffer));
      out += tmp;
      break;
    }
    case MTPipelineLib::PROP_TYPE_STRING: 
    case MTPipelineLib::PROP_TYPE_UNICODE_STRING: 
    {
      out += accessor->GetStringValue(recordBuffer);
      break;
    }
    case MTPipelineLib::PROP_TYPE_BIGINTEGER: 
    {
      swprintf(buf, L"%I64d", accessor->GetBigIntegerValue(recordBuffer));      
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_OPAQUE: 
    {
      const boost::uint8_t * val = accessor->GetBinaryValue(recordBuffer);
      wchar_t * bufit = buf;
      *bufit++ = L'0';
      *bufit++ = L'x';
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      *bufit++ = hexDigits[(*val & 0xF0)>>4];
      *bufit++ = hexDigits[(*val++ & 0x0F)];
      // Null terminate
      *bufit++ = 0;
      out += buf;
      break;
    }
    case MTPipelineLib::PROP_TYPE_SET: 
    {
      out += L"[\n";
      RecordPrinter * nestedMetadata = vit->second;
      // Iterate over nested records.
      const_record_t end = accessor->GetRecordValue(recordBuffer);
      if (end)
      {
        end = RecordMetadata::GetNext((record_t) end);
        const_record_t it = end;
        do
        {
          out += L"\t[";
          std::string tmp = nestedMetadata->PrintMessage(it);
          std::wstring wtmp;
          ::ASCIIToWide(wtmp, tmp);
          out += wtmp;
          // TODO: Investigate putting in const-correct RecordMetadata::GetNext
          out += L"]";
          it = RecordMetadata::GetNext((record_t) it);
          if (it != end) out += L", ";
          out += L"\n";
        } while (it != end);
      }
      out += L"]";
      break;
    }
    default:          
      throw std::logic_error("Unsupported data type");
    }
  }

  std::string utf8Out;
  ::WideStringToUTF8(out, utf8Out);
  return utf8Out;
}

