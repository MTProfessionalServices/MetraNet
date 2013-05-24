#include "metra.h"
#include "ImportFunction.h"
#include "Importer.h"
#include "Exporter.h"
#include "HashFunction.h"
#include "ConvertUTF.h"
#include "RecordModel.h"

#include "FastDelegateBind.h"

// The following for import spec parsing 
#include <sstream>
#include "LogAdapter.h"
#include "RecordFormatLexer.hpp"
#include "RecordFormatParser.hpp"
#include "RecordFormatTreeParser.hpp"
#include "RecordFormatGenerator.hpp"
#include "AST.hpp"
#include "ASTFactory.hpp"
#include "TokenStreamHiddenTokenFilter.hpp"
#include "CommonHiddenStreamToken.hpp"

#import <MTEnumConfig.tlb>

// A simple hash table that demands perfect hashing.  Meant for small tables.
void PerfectEnumeratorHash::Init(int length)
{
  delete [] mEnumerators;
  mLength = length;
  if (mLength > 0)
  {
    mEnumerators = new int [length];
    for(int i=0; i<mLength; i++)
    {
      mEnumerators[i] = -1;
    }
  }
  else
  {
    mEnumerators = NULL;
  }
}
PerfectEnumeratorHash::PerfectEnumeratorHash(int length)
  :
  mLength(0),
  mEnumerators(NULL)
{
  Init(length);
}

PerfectEnumeratorHash::PerfectEnumeratorHash(const wchar_t * enumNamespace, const wchar_t * enumEnumerator)
  :
  mLength(0),
  mEnumerators(NULL)
{
  MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
  MTENUMCONFIGLib::IMTEnumeratorCollectionPtr enumColl = enumConfig->GetEnumerators(enumNamespace, enumEnumerator);
  long numEnumerators = enumColl->Count;

  // The perfect hash construction below doesn't properly detect duplicate values.
  // We use an STL map as an intermediate data structure and perform deduping with this.
  std::map<std::wstring, long> stlMap;

  for(long i=1; i<=numEnumerators; i++)
  {
    MTENUMCONFIGLib::IMTEnumeratorPtr enumerator = enumColl->GetItem(i);
    long numValues = enumerator->NumValues();
    _bstr_t nm = enumerator->name;
    long id_enum_value = enumConfig->GetID(enumNamespace, enumEnumerator, nm);
    stlMap[(const wchar_t *)nm] = id_enum_value;
    for(long j=0; j<numValues; j++)
    {
      _bstr_t val=enumerator->ElementAt(j);
      std::map<std::wstring, boost::int32_t>::const_iterator it = stlMap.find((const wchar_t *)val);
      if (it == stlMap.end())
        stlMap[(const wchar_t *)val] = id_enum_value;
      else if(it->second != id_enum_value)
        throw std::runtime_error("Invalid enum configuration detected");
    }
  }
  
  // Now round up a bit in order for us to get a perfect hash
  std::size_t tableSize = 4*stlMap.size();
  do
  {
  again:
    tableSize += tableSize;
    Init(tableSize);
    for(std::map<std::wstring, boost::int32_t>::const_iterator it = stlMap.begin();
        it != stlMap.end();
        ++it)
    {
      if (!Insert((const unsigned char *)(it->first.c_str()), (it->first.size()+1)<<1, it->second))
        goto again;
    } 
  } while(false);
}

PerfectEnumeratorHash::PerfectEnumeratorHash(const PerfectEnumeratorHash& rhs)
  :
  mEnumerators(NULL),
  mLength(0)
{
  *this = rhs;
}

PerfectEnumeratorHash::~PerfectEnumeratorHash()
{
  destroy();
}

PerfectEnumeratorHash& PerfectEnumeratorHash::operator=(const PerfectEnumeratorHash& rhs)
{
  destroy();
  mEnumerators = new int [rhs.mLength];
  memcpy(mEnumerators, rhs.mEnumerators, rhs.mLength*sizeof(int));
  mLength = rhs.mLength;
  return *this;
}

void PerfectEnumeratorHash::destroy()
{
  delete [] mEnumerators;
  mEnumerators = NULL;
}

int PerfectEnumeratorHash::Lookup(const boost::uint8_t * str, int len)
{
  return mEnumerators[__hash(const_cast<unsigned char *>(str), len, 0) % mLength];
}

bool PerfectEnumeratorHash::Insert(const boost::uint8_t * str, int len, int value)
{
  ASSERT(value >= 0);
  unsigned int idx = __hash(const_cast<unsigned char *>(str), len, 0) % mLength;
  // We don't use chained buckets
  if (mEnumerators[idx] != -1) return false;
  mEnumerators [idx] = value;
  return true;
}

ParsePrefixedUCS2StringEnumeration::ParsePrefixedUCS2StringEnumeration(const std::wstring& space, const std::wstring& enumeration)
  :
  mNamespace(space),
  mEnumeration(enumeration),
  mBuffer(NULL),
  mBufferLength(128)
{
  mString = new ParsePrefixedUCS2String;
  mBuffer = new unsigned char [mBufferLength];
  mHashTable = new PerfectEnumeratorHash(space.c_str(), enumeration.c_str());
}

ParsePrefixedUCS2StringEnumeration::~ParsePrefixedUCS2StringEnumeration()
{
  delete mString;
  delete [] mBuffer;
  delete mHashTable;
}

bool ParsePrefixedUCS2StringEnumeration::Import(const unsigned char * inputBuffer, int inputAvailable, int & inputConsumed,
                                                unsigned char * outputBuffer, int outputAvailable, int & outputConsumed)
{
  if (outputAvailable < 4) 
  {
    inputConsumed = 0;
    outputConsumed = 4;
    return false;
  }
  int localOutputConsumed;
  while(true)
  {
    bool ret = mString->Import(inputBuffer, inputAvailable, inputConsumed,
                               mBuffer, mBufferLength, localOutputConsumed);
    if (ret) break;
    if (localOutputConsumed > mBufferLength)
    {
      delete [] mBuffer;
      mBufferLength = localOutputConsumed;
      mBuffer = new unsigned char [localOutputConsumed];
    }
    if (inputConsumed > inputAvailable)
    {
      outputConsumed = 4;
      return false;      
    }
  }
  if (localOutputConsumed == 0) 
  {
    outputConsumed = 0;
    return true;
  }
  else
  {
    *((long *)outputBuffer) = mHashTable->Lookup(mBuffer, localOutputConsumed);
    if (-1 == *((long *)outputBuffer) ) throw std::exception("Enumerator lookup failed");
    outputConsumed = 4;
    return true;
  }
}

// Policy objects
//
// DirectDataAccessor output: Encapsulates a MetraFlow data accessor whose storage is inline
// in a MetraFlow record.
// IndirectDataAccessor output: Encapsulates a MetraFlow data accessor whose storage is indirect
// (only a pointer in the MetraFlow records).
//

ISO8601_DateTime::ISO8601_DateTime()
{
}

void ISO8601_DateTime::destroy()
{
}

ParseDescriptor::Result ISO8601_DateTime::Import(
  const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
  boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed)
{
  // Example "2007-10-17 12:30:00 AM"
  // Technically not ISO8601 since it uses a 12 hour clock.
  if (inputAvailable < 22 || outputAvailable < sizeof(date_time_traits::value))
  {
    inputConsumed = 22;
    outputConsumed = sizeof(date_time_traits::value);
    return ParseDescriptor::PARSE_BUFFER_OPEN;
  }

  inputConsumed = 0;
  outputConsumed = 0;

  // TODO: Put into date_time_traits
#ifdef WIN32
  // Initialize
  SYSTEMTIME t;

  const char * inputBufferIt = (const char *)inputBuffer;

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

  if (*inputBufferIt++ != ' ') return ParseDescriptor::PARSE_ERROR;
  if (*inputBufferIt == 'P') 
  {
    t.wHour += 12;
  }
  else if (*inputBufferIt != 'A')
  {
    return ParseDescriptor::PARSE_ERROR;
  }
  inputBufferIt += 1;

  if (*inputBufferIt++ != 'M') return ParseDescriptor::PARSE_ERROR;

  ::SystemTimeToVariantTime(&t, (date_time_traits::pointer) outputBuffer);
  
  inputConsumed = 22;
  outputConsumed = sizeof(date_time_traits::value);
  return ParseDescriptor::PARSE_OK;
#else
  // Initialize
  struct tm t;

  const char * inputBufferIt = (const char *)inputBuffer;

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

  if (*inputBufferIt++ != ' ') return ParseDescriptor::PARSE_ERROR;
  if (*inputBufferIt == 'P') 
  {
    t.tm_hour += 12;
  }
  else if (*inputBufferIt != 'A')
  {
    return ParseDescriptor::PARSE_ERROR;
  }
  inputBufferIt += 1;

  if (*inputBufferIt++ != 'M') return ParseDescriptor::PARSE_ERROR;

  *((date_time_traits::pointer) outputBuffer) = boost::date_time::date_from_tm(&t);
  
  inputConsumed = 22;
  outputConsumed = sizeof(date_time_traits::value);
  return ParseDescriptor::PARSE_OK;
#endif

}

UTF8_String_Literal_UTF8_Null_Terminated::UTF8_String_Literal_UTF8_Null_Terminated(const std::string& literal)
  :
  mLiteralBegin(NULL),
  mLiteralEnd(NULL),
  mLiteralIt(NULL)
{
  mLiteralBegin = new char [literal.size()];
  memcpy(mLiteralBegin, literal.c_str(), literal.size());
  mLiteralEnd = mLiteralBegin + literal.size();
  mLiteralIt = mLiteralBegin;
}

UTF8_String_Literal_UTF8_Null_Terminated::~UTF8_String_Literal_UTF8_Null_Terminated()
{
  destroy();
}

void UTF8_String_Literal_UTF8_Null_Terminated::destroy()
{
  delete [] mLiteralBegin;
  mLiteralBegin = mLiteralEnd = mLiteralIt = NULL;
}

UTF8_String_Literal_UTF8_Null_Terminated::UTF8_String_Literal_UTF8_Null_Terminated(const UTF8_String_Literal_UTF8_Null_Terminated & rhs)
  :
  mLiteralBegin(NULL),
  mLiteralEnd(NULL),
  mLiteralIt(NULL)
{
  mLiteralBegin = new char [rhs.mLiteralEnd - rhs.mLiteralBegin];
  memcpy(mLiteralBegin, rhs.mLiteralBegin, rhs.mLiteralEnd - rhs.mLiteralBegin);
  mLiteralEnd = mLiteralBegin + (rhs.mLiteralEnd - rhs.mLiteralBegin);
  mLiteralIt = mLiteralBegin;
}

UTF8_String_Literal_UTF8_Null_Terminated& UTF8_String_Literal_UTF8_Null_Terminated::operator=(const UTF8_String_Literal_UTF8_Null_Terminated & rhs)
{
  delete [] mLiteralBegin;
  mLiteralBegin = mLiteralIt = mLiteralEnd = NULL;

  if (rhs.mLiteralBegin)
  {
    mLiteralBegin = new char [rhs.mLiteralEnd - rhs.mLiteralBegin];
    memcpy(mLiteralBegin, rhs.mLiteralBegin, rhs.mLiteralEnd - rhs.mLiteralBegin);
    mLiteralEnd = mLiteralBegin + (rhs.mLiteralEnd - rhs.mLiteralBegin);
    mLiteralIt = mLiteralBegin;
  }
  return *this;
}

ParseDescriptor::Result UTF8_String_Literal_UTF8_Null_Terminated::Import(
  const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
  boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed)
{
  const char * inputBufferIt = (const char *)inputBuffer;
  const char * inputBufferEnd = (const char *) (inputBuffer + inputAvailable);

  char * outputBufferIt = (char *)outputBuffer;
  char * outputBufferEnd = (char *) (outputBuffer + outputAvailable);

  while(mLiteralIt != mLiteralEnd &&
    inputBufferIt != inputBufferEnd &&
    outputBufferIt != outputBufferEnd)
  {
    if (*mLiteralIt != *inputBufferIt)
    {
      // Should we consume on error?
      inputConsumed = 0;
      outputConsumed = 0;
      // Reset state so we can start again.
      mLiteralIt = mLiteralBegin;
      return ParseDescriptor::PARSE_ERROR;
    }

    *outputBufferIt = *inputBufferIt;

    mLiteralIt += 1;
    inputBufferIt += 1;
    outputBufferIt += 1;
  }

  inputConsumed = (inputBufferIt - (const char *) inputBuffer);
  outputConsumed = (outputBufferIt - (const char *) outputBuffer);
  if (mLiteralIt == mLiteralEnd)
  {
    mLiteralIt = mLiteralBegin;
    return ParseDescriptor::PARSE_OK;
  }
  else if (inputBufferIt == inputBufferEnd)
  {
    return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
  }
  else 
  {
    ASSERT(outputBufferIt == outputBufferEnd);
    return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
  }
}

UTF8_FixedLength_UTF16_Null_Terminated::UTF8_FixedLength_UTF16_Null_Terminated(boost::int32_t length)
  :
  mLength(length)
{
}

void UTF8_FixedLength_UTF16_Null_Terminated::destroy()
{
}

ParseDescriptor::Result UTF8_FixedLength_UTF16_Null_Terminated::Import(
  const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
  boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed)
{
  return ParseDescriptor::PARSE_ERROR;
}

UTF8_Terminated_UTF16_Null_Terminated::UTF8_Terminated_UTF16_Null_Terminated(const std::string& terminator)
  :
  mState(IMPORTING),
  mTerminatorLength(0),
  mTerminatorIt(0)
{
  if (terminator.size() > 4)
    throw std::runtime_error("Invalid terminator");

  // We don't want the terminating 0 of the string
  memcpy(mTerminator, terminator.c_str(), terminator.size());
  mTerminatorLength = boost::uint8_t(terminator.size());

  // We calculate and store the size of the UTF16 converted terminator.  This is to
  // facilitate backing up the target buffer when the terminator is recognized.
  const UTF8 * source = (const UTF8 *)mTerminator;
  const UTF8 * sourceEnd = source + terminator.size();
  UTF16 targetBuffer[4];
  UTF16 * target = &targetBuffer[0];
  ConversionResult r = ::ConvertUTF8toUTF16(&source, sourceEnd, &target, &targetBuffer[4], strictConversion);
  // TODO: Better error reporting.
  if (r != conversionOK)
    throw std::runtime_error("Invalid terminator specification");
  mUTF16TerminatorLength = (boost::uint8_t) (target - &targetBuffer[0]);
}

void UTF8_Terminated_UTF16_Null_Terminated::destroy()
{
}

ParseDescriptor::Result UTF8_Terminated_UTF16_Null_Terminated::Import(
  const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
  boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed)
{
  switch(mState)
  {
  case IMPORTING:
  {
    const UTF8 * source = (const UTF8 *) inputBuffer;
    const UTF8 * sourceEnd = (const UTF8 *)(source + inputAvailable);
    UTF16 * target = (UTF16 *) outputBuffer;
    UTF16 * targetEnd = (UTF16 *) (outputBuffer + outputAvailable);
    const UTF8 * terminator = (const UTF8 *) (mTerminator+mTerminatorIt);

    ConversionResult r = ::ConvertUTF8toUTF16_Terminated(&source, sourceEnd, 
                                                         &target, targetEnd, strictConversion, 
                                                         (const UTF8 **) &terminator, 
                                                         (const UTF8 *) mTerminator,
                                                         (const UTF8 *) (mTerminator+mTerminatorLength),
                                                         mUTF16TerminatorLength);
    mTerminatorIt = (boost::uint8_t)(terminator- (const UTF8 *)mTerminator);

    inputConsumed = (const boost::uint8_t *)source - inputBuffer;
    outputConsumed = (boost::uint8_t *)target - outputBuffer;
    if( r==conversionOK)
    {
      if(inputConsumed==inputAvailable) 
      {
        return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
      }
      else if (targetEnd == target)
      {
        mState = TERMINATING;
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      }
      else
      {
        // Add null terminator
        *target = 0;
        outputConsumed += sizeof(UTF16);
        mTerminatorIt = 0;
        return ParseDescriptor::PARSE_OK;
      }
    }
    else if (r==sourceExhausted)
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
    else if (r==targetExhausted)
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
    else
      return ParseDescriptor::PARSE_ERROR;
  }
  case TERMINATING:
  {
    mState = IMPORTING;
    *((UTF16 *)outputBuffer) = 0;
    inputConsumed = 0;
    outputConsumed = sizeof(UTF16);
    return ParseDescriptor::PARSE_OK;
  }
  default:
    throw std::runtime_error("Invalid case");
  }
}

UTF8_Terminated_UTF8_Null_Terminated::UTF8_Terminated_UTF8_Null_Terminated(const std::string& terminator)
  :
  mState(IMPORTING)
{
  if (terminator.size() > 4)
    throw std::runtime_error("Invalid UTF8 encoded character");

  // TODO: Further checks that the terminator is a single valid UTF8 encoded code point.

  // We don't want the terminating 0 of the string
  memcpy(mTerminator, terminator.c_str(), terminator.size());
  mTerminatorLength = boost::uint16_t(terminator.size());
}

void UTF8_Terminated_UTF8_Null_Terminated::destroy()
{
}

ParseDescriptor::Result UTF8_Terminated_UTF8_Null_Terminated::Import(
  const boost::uint8_t * inputBuffer, std::size_t inputAvailable, std::size_t & inputConsumed,
  boost::uint8_t * outputBuffer, std::size_t outputAvailable, std::size_t & outputConsumed)
{
  switch(mState)
  {
  case IMPORTING:
  {
    const UTF8 * source = (const UTF8 *) inputBuffer;
    const UTF8 * sourceEnd = (const UTF8 *)(source + inputAvailable);
    UTF8 * target = (UTF8 *) outputBuffer;
    UTF8 * targetEnd = (UTF8 *) (outputBuffer + outputAvailable);
    ConversionResult r = ::ConvertUTF8toUTF8_Terminated(&source, sourceEnd, &target, targetEnd, strictConversion, 
                                                        (const UTF8 *)mTerminator, (const UTF8 *)(mTerminator+mTerminatorLength));

    inputConsumed = (const boost::uint8_t *)source - inputBuffer;
    outputConsumed = (boost::uint8_t *)target - outputBuffer;
    if( r==conversionOK)
    {
      if(inputConsumed==inputAvailable) 
      {
        return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
      }
      else if (targetEnd == target)
      {
        mState = TERMINATING;
        return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
      }
      else
      {
        // Add null terminator
        *target = 0;
        outputConsumed += sizeof(UTF8);
        return ParseDescriptor::PARSE_OK;
      }
    }
    else if (r==sourceExhausted)
      return ParseDescriptor::PARSE_SOURCE_EXHAUSTED;
    else if (r==targetExhausted)
      return ParseDescriptor::PARSE_TARGET_EXHAUSTED;
    else
      return ParseDescriptor::PARSE_ERROR;
  }
  case TERMINATING:
  {
    mState = IMPORTING;
    *((UTF8 *)outputBuffer) = 0;
    inputConsumed = 0;
    outputConsumed = sizeof(UTF8);
    return ParseDescriptor::PARSE_OK;
  }
  default:
    throw std::runtime_error("Invalid case");
  }
}

Enum_Lookup_Action_Type::Enum_Lookup_Action_Type(const FieldAddress& address, const std::string& space, const std::string& enumerator)
  :
  mAddress(address),
  mHashTable(NULL)
{
  std::wstring wstrSpace;
  std::wstring wstrEnumerator;
  ::ASCIIToWide(wstrSpace, space);
  ::ASCIIToWide(wstrEnumerator, enumerator);

  mHashTable = new PerfectEnumeratorHash(wstrSpace.c_str(), wstrEnumerator.c_str());
}

void Enum_Lookup_Action_Type::destroy()
{
  delete mHashTable;
}

void Enum_Lookup_Action_Type::Set(record_t recordBuffer, const boost::uint8_t * valueBuffer, std::ptrdiff_t len)
{
  long val = mHashTable->Lookup(valueBuffer, len);
  if (-1 == val) throw std::runtime_error("Enumerator lookup failed");  
  *((long *)mAddress.GetDirectBuffer(recordBuffer)) = val;
  mAddress.ClearNull(recordBuffer);
}

UTF8StringBufferImporter::UTF8StringBufferImporter(const std::wstring& importSpec)
  :
  mImpl(NULL)
{
  mImpl = new UTF8_Import_Function_Builder_2<PagedParseBuffer<PagedBuffer> >(*this, importSpec);
}

UTF8StringBufferImporter::~UTF8StringBufferImporter()
{
  delete mImpl;
}

record_t UTF8StringBufferImporter::Import(PagedParseBuffer<PagedBuffer> & input, std::string& outErrMessage)
{
  return mImpl->Import(input, outErrMessage);
}

const RecordMetadata& UTF8StringBufferImporter::GetMetadata() const
{
  return mImpl->GetMetadata();
}

void UTF8StringBufferImporter::ThrowError(const std::wstring& err)
{
  std::string utf8Msg;
  ::WideStringToUTF8(err, utf8Msg);
  throw std::runtime_error(utf8Msg);
}

UTF8StringBufferExporter::UTF8StringBufferExporter(const std::wstring& importSpec)
  :
  mImpl(NULL)
{
  mImpl = new UTF8_Export_Function_Builder_2<DynamicArrayParseBuffer >(*this, importSpec);
}

UTF8StringBufferExporter::~UTF8StringBufferExporter()
{
  delete mImpl;
}

void UTF8StringBufferExporter::Export(record_t recordBuffer, DynamicArrayParseBuffer & output)
{
  mImpl->Export(recordBuffer, output);
}

const RecordMetadata& UTF8StringBufferExporter::GetMetadata() const
{
  return mImpl->GetMetadata();
}

void UTF8StringBufferExporter::ThrowError(const std::wstring& err)
{
  std::string utf8Msg;
  ::WideStringToUTF8(err, utf8Msg);
  throw std::runtime_error(utf8Msg);
}

