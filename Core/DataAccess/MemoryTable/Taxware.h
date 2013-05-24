#ifndef __TAXWARE_H__
#define __TAXWARE_H__

#include "Scheduler.h"
#include "LogAdapter.h"

struct ZIP020_Parm;

/**
 * Forward declarition of the handle to the UTL API. This class is a singleton
 * that manages the loading of the UTL library, and the opening and closing of
 * the tax rules files.
 * Do we need to support reloading of tax rules files without starting and stopping
 * services.  We probably do since this puppy is going to be used in a server for
 * quoting.
 */
class TaxwareUniversalTaxLink
{
private:
  static TaxwareUniversalTaxLink * sInstance;
  static boost::int32_t sRefCount;

  typedef int (_stdcall *CAPITAXROUTINEPROC)(char*, char*, int); 
  typedef BOOLEAN (WINAPI *ZIP020PROC)(struct ZIP020_Parm *); 
  typedef BOOLEAN (WINAPI *ZIPOPENPROC)(int); 
  typedef BOOLEAN (WINAPI *ZIPCLOSEPROC)(void); 
  typedef int (WINAPI *VERIFYZIPPROC)(char *, char *); 
  
  HMODULE mModule;
  HMODULE mVeraZipModule;
  CAPITAXROUTINEPROC mCapiTaxRoutine;
  ZIP020PROC mZIP020;
  ZIPOPENPROC mZipOpen;
  ZIPCLOSEPROC mZipClose;
  VERIFYZIPPROC mVerifyZip;

  MetraFlowLoggerPtr mLogger;
  
  TaxwareUniversalTaxLink();
  ~TaxwareUniversalTaxLink();
public:
  METRAFLOW_DECL static TaxwareUniversalTaxLink* GetInstance();
  METRAFLOW_DECL static void ReleaseInstance(TaxwareUniversalTaxLink*  utl);
  /**
   * Simply calls CapiTaxRoutine.
   */
  METRAFLOW_DECL int TaxRoutine(char * taxinbuffer, char * taxoutbuffer, int length);
  /**
   * Simply calls ZIP020
   */
  METRAFLOW_DECL int VerifyZip(char * stateCode, char * zipCode, char * cityCode);
};

class DesignTimeTaxwareBinding
{
public:
  enum TaxwareType {STRING, INTEGER, BIGINTEGER, DATE};

private:
  boost::int32_t mOffset;
  boost::int32_t mLength;
  TaxwareType mType;
  std::wstring mName;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_NVP(mOffset);
    ar & BOOST_SERIALIZATION_NVP(mLength);
    ar & BOOST_SERIALIZATION_NVP(mType);
    ar & BOOST_SERIALIZATION_NVP(mName);
  } 
public:
  DesignTimeTaxwareBinding()
    :
    mType(STRING),
    mOffset(0),
    mLength(0)
  {
  }

  DesignTimeTaxwareBinding(TaxwareType ty, boost::int32_t offset, boost::int32_t length)
    :
    mType(ty),
    mOffset(offset),
    mLength(length)
  {
  }

  boost::int32_t GetOffset() const { return mOffset; }
  boost::int32_t GetLength() const { return mLength; }
  TaxwareType GetType() const { return mType; }
  const std::wstring& GetName() const { return mName; }
  void SetName(const std::wstring& name) { mName = name; }
};

/**
 * Taxware operator
 * Uses the Taxware Universal Tax Link API to calculate taxes.
 * Currently only supports a subset of the vast number of input parameters.
 */

class DesignTimeTaxware : public DesignTimeOperator
{
private:
  std::wstring mProductCode;
  std::map<std::wstring, DesignTimeTaxwareBinding> mBindings;
  std::map<std::wstring, DesignTimeTaxwareBinding> mOutputBindings;
  std::map<std::wstring, DesignTimeTaxwareBinding> mErrorBindings;

  RecordMetadata * mOutputMetadata;
  RecordMerge * mOutputMerger;
  RecordMetadata * mErrorMetadata;
  RecordMerge * mErrorMerger;
public:
  METRAFLOW_DECL DesignTimeTaxware();
  METRAFLOW_DECL ~DesignTimeTaxware();
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);  

  METRAFLOW_DECL bool IsTaxwareBinding(const std::wstring& taxwareName) const;
  METRAFLOW_DECL void SetTaxwareBinding(const std::wstring& taxwareName, const std::wstring& metraFlowName);
  METRAFLOW_DECL void SetProductCode(const std::wstring& productCode);

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeTaxware* clone(
                                   const std::wstring& name,
                                   std::vector<OperatorArg*>& args, 
                                   int nInputs, int nOutputs) const;
};

class RunTimeTaxwareBinding
{
public:
  typedef void (RunTimeTaxwareBinding::*Setter) (char *, const_record_t) const;
  typedef void (RunTimeTaxwareBinding::*Getter) (const char *, record_t) const;
private:
  boost::int32_t mOffset;
  boost::int32_t mLength;
  RunTimeDataAccessor mAccessor;
  Setter mSetter;
  Getter mGetter;

  void GetInt64(const char * taxwareBuffer, record_t metraFlowBuffer) const
  {
    boost::int64_t value=0;

    const char * inputBuffer = taxwareBuffer + mOffset;
    const char * inputBufferEnd = inputBuffer + mLength;

    // Must have at least one digit
    if (*((const char *)inputBuffer) < '0' && *((const char *)inputBuffer) > '9')
      throw std::runtime_error("Invalid Taxware output buffer");

    while(inputBuffer != inputBufferEnd)
    {
        value = value*10 + (boost::int64_t) (*((const char *)inputBuffer) - '0');
        inputBuffer += 1;
    } 

    mAccessor.SetValue(metraFlowBuffer, &value);
  }

  void GetString(const char * taxwareBuffer, record_t metraFlowBuffer) const
  {
    // TODO: Woefully inefficient
    char * buf = new char [mLength + 1];
    memcpy(buf, taxwareBuffer+mOffset, mLength);
    buf[mLength] = 0;
    mAccessor.SetValue(metraFlowBuffer, buf);
    delete [] buf;
  }

  void SetInt32(char * outputBuffer, const_record_t metraFlowBuffer) const
  {
    static char conversion [] = "0123456789";
    char * outputBufferIt = outputBuffer + mOffset;
    char * outputBufferEnd = outputBufferIt + mLength;

    // NULL is always interpreted as spaces.
    if (mAccessor.GetNull(metraFlowBuffer))
    {
      memset(outputBufferIt, ' ', mLength);
      return;
    }
    
    boost::int32_t value = *((boost::int32_t *)mAccessor.GetValue(metraFlowBuffer));
    while (value != 0 && outputBufferIt != outputBufferEnd)
    {
      *((char*)outputBufferIt) = conversion[value % 10];
      outputBufferIt += 1;
      value /= 10;
    }

    // We have an overflow.
    if (value != 0) 
      throw std::runtime_error("Taxware export overflow");

    // Pad with 0's if necessary
    while (outputBufferIt != outputBufferEnd)
    {
      *((char*)outputBufferIt) = '0';
      outputBufferIt += 1;
    }

    // Reverse the digits.
    std::reverse(outputBuffer + mOffset, outputBufferEnd);        
  }

  void SetInt64(char * outputBuffer, const_record_t metraFlowBuffer) const
  {
    static char conversion [] = "0123456789";
    char * outputBufferIt = outputBuffer + mOffset;
    char * outputBufferEnd = outputBufferIt + mLength;

    // NULL is always interpreted as spaces.
    if (mAccessor.GetNull(metraFlowBuffer))
    {
      memset(outputBufferIt, ' ', mLength);
      return;
    }
    
    boost::int64_t value = *((boost::int64_t *)mAccessor.GetValue(metraFlowBuffer));
    while (value != 0 && outputBufferIt != outputBufferEnd)
    {
      *((char*)outputBufferIt) = conversion[value % 10LL];
      outputBufferIt += 1;
      value /= 10LL;
    }

    // We have an overflow.
    if (value != 0LL) 
      throw std::runtime_error("Taxware export overflow");

    // Pad with 0's if necessary
    while (outputBufferIt != outputBufferEnd)
    {
      *((char*)outputBufferIt) = '0';
      outputBufferIt += 1;
    }

    // Reverse the digits.
    std::reverse(outputBuffer + mOffset, outputBufferEnd);        
  }

  void SetString(char * outputBuffer, const_record_t metraFlowBuffer) const
  {
    // NULL is always interpreted as spaces.
    if (mAccessor.GetNull(metraFlowBuffer))
    {
      memset(outputBuffer+mOffset, ' ', mLength);
      return;
    }
    
    const char * value = (const char *) mAccessor.GetValue(metraFlowBuffer);
    boost::int32_t l = strlen(value);
    if (l > mLength)
      throw std::runtime_error("Taxware export overflow");

    memcpy(outputBuffer + mOffset, value, l);
    if (l < mLength)
      memset(outputBuffer + mOffset + l, ' ', mLength - l);
  }

  void SetDatetime(char * outputBuffer, const_record_t metraFlowBuffer) const
  {
    static char conversion [] = "0123456789";
    // NULL is always interpreted as spaces.
    if (mAccessor.GetNull(metraFlowBuffer))
    {
      memset(outputBuffer+mOffset, ' ', mLength);
      return;
    }
    
    date_time_traits::pointer value = (date_time_traits::pointer) mAccessor.GetValue(metraFlowBuffer);
    SYSTEMTIME t;
    ::VariantTimeToSystemTime(*value, &t);
    if (t.wYear < 1000 || t.wYear > 9999)
      throw std::runtime_error("Unsupported year");

    char * outputBufferIt = outputBuffer + mOffset + 4;
    while (t.wYear != 0)
    {
      *((char*)--outputBufferIt) = conversion[t.wYear % 10];
      t.wYear /= 10;
    }
    outputBufferIt += 4;

    if (t.wMonth < 10)
    {
      *outputBufferIt++ = '0';
      *outputBufferIt++ = conversion[t.wMonth];
    }
    else
    {
      *outputBufferIt++ = '1';
      *outputBufferIt++ = conversion[t.wMonth % 10];
    }
    if (t.wDay < 10)
    {
      *outputBufferIt++ = '0';
      *outputBufferIt++ = conversion[t.wDay];
    }
    else
    {
      *outputBufferIt++ = conversion[t.wDay/10];
      *outputBufferIt++ = conversion[t.wDay % 10];
    }
  }
public:
  RunTimeTaxwareBinding(const DesignTimeTaxwareBinding& binding, const RecordMetadata& metadata)
    :
    mOffset(binding.GetOffset()),
    mLength(binding.GetLength()),
    mAccessor(*metadata.GetColumn(binding.GetName())),
    mSetter(NULL),
    mGetter(NULL)
  {
    if (binding.GetType() == DesignTimeTaxwareBinding::INTEGER)
    {
      mSetter = &RunTimeTaxwareBinding::SetInt32;
    }
    else if (binding.GetType() == DesignTimeTaxwareBinding::DATE)
    {
      mSetter = &RunTimeTaxwareBinding::SetDatetime;
    }
    else if (binding.GetType() == DesignTimeTaxwareBinding::BIGINTEGER)
    {
      mSetter = &RunTimeTaxwareBinding::SetInt64;
      mGetter = &RunTimeTaxwareBinding::GetInt64;
    }
    else
    {
      mSetter = &RunTimeTaxwareBinding::SetString;
      mGetter = &RunTimeTaxwareBinding::GetString;
    }
  }
  void Set(char * taxwareBuffer, const_record_t metraFlowBuffer) const
  {
    (this->*mSetter)(taxwareBuffer, metraFlowBuffer);
  }
  void Get(const char * taxwareBuffer, record_t metraFlowBuffer) const
  {
    (this->*mGetter)(taxwareBuffer, metraFlowBuffer);
  }
};


class RunTimeTaxware : public RunTimeOperator
{
public:
  friend class RunTimeTaxwareActivation;
private:
  RecordMetadata mMetadata;
  RecordMetadata mOutputMetadata;
  RecordMetadata mErrorMetadata;
  RecordMerge mOutputMerger;
  RecordMerge mErrorMerger;
  std::vector<DesignTimeTaxwareBinding> mDesignTimeBindings;
  std::vector<DesignTimeTaxwareBinding> mDesignTimeOutputBindings;
  std::vector<DesignTimeTaxwareBinding> mDesignTimeErrorBindings;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
    ar & BOOST_SERIALIZATION_NVP(mOutputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mErrorMetadata);
    ar & BOOST_SERIALIZATION_NVP(mOutputMerger);
    ar & BOOST_SERIALIZATION_NVP(mErrorMerger);
    ar & BOOST_SERIALIZATION_NVP(mDesignTimeBindings);
    ar & BOOST_SERIALIZATION_NVP(mDesignTimeOutputBindings);
    ar & BOOST_SERIALIZATION_NVP(mDesignTimeErrorBindings);
  } 
  METRAFLOW_DECL RunTimeTaxware()
  {
  }

public:
  METRAFLOW_DECL RunTimeTaxware (const std::wstring& name, 
                                 const RecordMetadata& metadata,
                                 const RecordMetadata& outputMetadata,
                                 const RecordMerge& outputMerger,
                                 const RecordMetadata& errorMetadata,
                                 const RecordMerge& errorMerger,
                                 const std::vector<DesignTimeTaxwareBinding>& designTimeBindings,
                                 const std::vector<DesignTimeTaxwareBinding>& designTimeOutputBindings,
                                 const std::vector<DesignTimeTaxwareBinding>& designTimeErrorBindings);
  METRAFLOW_DECL ~RunTimeTaxware();
  
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeTaxwareActivation : public RunTimeOperatorActivationImpl<RunTimeTaxware>
{
private:
  enum State { START, READ_0, WRITE_0, WRITE_EOF_0, WRITE_1, WRITE_EOF_1 };

  TaxwareUniversalTaxLink *mUTL;
  char * mInBuffer;
  char * mOutBuffer;
  MessagePtr mInputMessage;
  MessagePtr mOutputMessage;
  MessagePtr mErrorMessage;
  MessagePtr mOutputBuffer;
  MessagePtr mErrorBuffer;
  State mState;
  std::vector<RunTimeTaxwareBinding> mRunTimeBindings;
  std::vector<RunTimeTaxwareBinding> mRunTimeOutputBindings;
  std::vector<RunTimeTaxwareBinding> mRunTimeErrorBindings;
  MetraFlowLoggerPtr mLogger;
  boost::int32_t mReturn;
public:
  METRAFLOW_DECL RunTimeTaxwareActivation (Reactor * reactor, 
                                           partition_t partition,
                                           const RunTimeTaxware * runTimeOperator);
  METRAFLOW_DECL ~RunTimeTaxwareActivation();
  
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

#endif
