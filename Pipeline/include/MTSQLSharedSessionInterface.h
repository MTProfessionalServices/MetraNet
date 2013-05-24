#ifndef _MTSQLSHAREDSESSIONINTERFACE_H_
#define _MTSQLSHAREDSESSIONINTERFACE_H_

//
// This is the interface between a SharedSession and the MTSQL interpreter. 
//

#include <string>
#include <map>
#include <MTSQLInterpreter.h>
#include <errobj.h>
#include <mtdec.h>
#include <MTUtil.h>
#include <MTSQLInterpreterSessionInterface.h>
#include <sharedsess.h>

#import <MTPipelineLib.tlb>

class MTSQLSharedSessionFrame;
class MTSQLSharedSessionWrapper;
class MTSQLSharedSessionFactoryWrapper;
class CMTSessionServerBase;

class MTSQLSharedSessionActivationRecord : public ActivationRecord
{
private:
  MTSQLSharedSessionWrapper * mSessionPtr;
public:
	MTSQLSharedSessionActivationRecord(MTSQLSharedSessionWrapper * aSessionPtr); 

	void getLongValue(const Access * access, RuntimeValue * value);
	void getLongLongValue(const Access * access, RuntimeValue * value);
	void getDoubleValue(const Access * access, RuntimeValue * value);
	void getDecimalValue(const Access * access, RuntimeValue * value);
	void getStringValue(const Access * access, RuntimeValue * value);
	void getWStringValue(const Access * access, RuntimeValue * value);
	void getBooleanValue(const Access * access, RuntimeValue * value);
	void getDatetimeValue(const Access * access, RuntimeValue * value);
	void getTimeValue(const Access * access, RuntimeValue * value);
	void getEnumValue(const Access * access, RuntimeValue * value);
	void getBinaryValue(const Access * access, RuntimeValue * value);
	void setLongValue(const Access * access, const RuntimeValue * value);
	void setLongLongValue(const Access * access, const RuntimeValue * value);
	void setDoubleValue(const Access * access, const RuntimeValue * value);
	void setDecimalValue(const Access * access, const RuntimeValue * value);
	void setStringValue(const Access * access, const RuntimeValue * value);
	void setWStringValue(const Access * access, const RuntimeValue * value);
	void setBooleanValue(const Access * access, const RuntimeValue * value);
	void setDatetimeValue(const Access * access, const RuntimeValue * value);
	void setTimeValue(const Access * access, const RuntimeValue * value);
	void setEnumValue(const Access * access, const RuntimeValue * value);
	void setBinaryValue(const Access * access, const RuntimeValue * value);
	RuntimeValue getLongValue(AccessPtr access);
	RuntimeValue getLongLongValue(AccessPtr access);
	RuntimeValue getDoubleValue(AccessPtr access);
	RuntimeValue getDecimalValue(AccessPtr access);
	RuntimeValue getStringValue(AccessPtr access);
	RuntimeValue getWStringValue(AccessPtr access);
	RuntimeValue getBooleanValue(AccessPtr access);
	RuntimeValue getDatetimeValue(AccessPtr access);
	RuntimeValue getTimeValue(AccessPtr access);
	RuntimeValue getEnumValue(AccessPtr access);
	void setLongValue(AccessPtr access, RuntimeValue val);
	void setLongLongValue(AccessPtr access, RuntimeValue val);
	void setDoubleValue(AccessPtr access, RuntimeValue val);
	void setDecimalValue(AccessPtr access, RuntimeValue val);
	void setStringValue(AccessPtr access, RuntimeValue val);
	void setWStringValue(AccessPtr access, RuntimeValue val);
	void setBooleanValue(AccessPtr access, RuntimeValue val);
	void setDatetimeValue(AccessPtr access, RuntimeValue val);
	void setTimeValue(AccessPtr access, RuntimeValue val);
	void setEnumValue(AccessPtr access, RuntimeValue val);

	ActivationRecord* getStaticLink() 
	{
		// This is always a global environment; can't have a static link.
		return NULL;
	}
};


template <class ActivationRecordType = MTSQLSharedSessionActivationRecord>
class MTSQLSharedSessionRuntimeEnvironment : public GlobalRuntimeEnvironment
{
public:
	MTSQLSharedSessionRuntimeEnvironment(MTPipelineLib::IMTLogPtr aLogger, 
                                       MTSQLSharedSessionWrapper * aSessionPtr,
                                       MTPipelineLib::IMTSessionPtr aFirstSessionPtr) :
		mActivationRecord(aSessionPtr),
    mFirstSessionPtr(aFirstSessionPtr)
	{
		mLogger = aLogger;
		mSession = aSessionPtr;
	}

	ActivationRecord* getActivationRecord()
	{
		return &mActivationRecord;
	}

	MTPipelineLib::IMTSQLRowsetPtr getRowset()
	{
    // We are not using query tags, so it really doesn't matter what
    // config dir to use.
    return mFirstSessionPtr->GetRowset(L"config\\ProductCatalog");
	}

	void logDebug(const std::string& str)
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, str.c_str());
	}

	void logInfo(const std::string& str)
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, str.c_str());
	}

	void logWarning(const std::string& str)
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, str.c_str());
	}

	void logError(const std::string& str)
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, str.c_str());
	}

	bool isOkToLogDebug()
	{
		return VARIANT_TRUE == mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);
	}

	bool isOkToLogInfo()
	{
		return VARIANT_TRUE == mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_INFO);
	}

	bool isOkToLogWarning()
	{
		return VARIANT_TRUE == mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_WARNING);
	}

	bool isOkToLogError()
	{
		return VARIANT_TRUE == mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_ERROR);
	}
protected:
	MTPipelineLib::IMTLogPtr mLogger;
	MTSQLSharedSessionWrapper * mSession;
	ActivationRecordType mActivationRecord;
  // This guy carries the rowset.
  MTPipelineLib::IMTSessionPtr mFirstSessionPtr;
};

class SessionPropertyAllocationFailure : public std::exception
{
public:
  SessionPropertyAllocationFailure() : std::exception("Failure allocating shared memory") {}
};

class MTSQLSharedSessionFactoryWrapper : public ObjectWithError
{
private:
  SharedSessionHeader * mpHeader;
  CMTSessionServerBase * mpSessServer;
public:
  MTSQLSharedSessionFactoryWrapper();
  ~MTSQLSharedSessionFactoryWrapper();
  bool InitSession(const unsigned char * uid, const unsigned char * parentUid, int serviceID, MTSQLSharedSessionWrapper * wrapper);
  bool InitSession(long id, MTSQLSharedSessionWrapper * wrapper);
  MTSQLSharedSessionWrapper * CreateSession(const unsigned char * uid, const unsigned char * parentUid, int serviceID);
  MTSQLSharedSessionWrapper * GetSession(long id);
};

class MTSQLSharedSessionWrapper
{
private:
  SharedSession * mpSession;  
  SharedSessionHeader * mpHeader;
  long mSessionID;
  SharedPropVal * CreateSharedProp(long aPropId)
  {
    // NOTE: we know that we're always creating properties since it's a new
    // session object.  therefore we don't need to see if the property already exists.
    // property reference ID is ignored
    long ref;
    SharedPropVal * prop = mpSession->GetWriteablePropertyWithID(mpHeader, aPropId);
    if(prop == NULL)
      prop = mpSession->AddProperty(mpHeader, ref, aPropId);
    if (!prop)
      // If prop is null, the shared area is out of memory
      throw SessionPropertyAllocationFailure();

    prop->Clear(mpHeader);

    ASSERT(prop->GetType() == SharedPropVal::FREE_PROPERTY);
    return prop;
  }

public:

  MTSQLSharedSessionWrapper()
    :
    mpSession(NULL),
    mpHeader(NULL),
    mSessionID(-1)
  {
  }

  MTSQLSharedSessionWrapper(SharedSession * apSession, SharedSessionHeader * apHeader, long aSessionID)
    :
    mpSession(apSession),
    mpHeader(apHeader),
    mSessionID(aSessionID)
  {
    ASSERT(apSession);
    ASSERT(apHeader);
  }

  ~MTSQLSharedSessionWrapper()
  {
    // Clean up if not detached
    if (mpSession != NULL)
    {
      mpSession->Release(mpHeader);
    }
  }

  void Init(SharedSession * apSession, SharedSessionHeader * apHeader, long aSessionID)
  {
    if (mpSession != NULL)
    {
      mpSession->Release(mpHeader);
    }
    mpSession = apSession;
    mpHeader = apHeader;
    mSessionID = aSessionID;
  }

  SharedSession * Detach()
  {
    mpSession->Release(mpHeader);
    SharedSession * tmp = mpSession;
    mpSession = NULL;
    return tmp;
  }

  int GetSessionID()
  {
    return mpSession->GetSessionID(mpHeader);
  }

	void SetInt32Value(int index, int value)
  {
		CreateSharedProp(index)->SetLongValue(value);
  }
	void SetInt64Value(int index, __int64 value)
  {
		CreateSharedProp(index)->SetLongLongValue(value);
  }
	void SetStringValue(int index, const wchar_t * value)
  {
    int sz = wcslen(value);
    // is the string small enough to go into the SharedPropVal directly
    if (sz * sizeof(wchar_t) < SharedSessionHeader::TINY_STRING_MAX)
    {
      CreateSharedProp(index)->SetTinyStringValue(value);
    }
    else if (sz * sizeof(wchar_t) < SharedSessionHeader::LARGE_STRING_MAX)
    {
      long ref;
      const wchar_t * wideStr = mpHeader->AllocateWideString(value, ref);
      if (!wideStr)
        // TODO:
        throw SessionPropertyAllocationFailure();

      // set the value
      CreateSharedProp(index)->SetUnicodeIDValue(ref);
    }
    else
    {
      if (FALSE == CreateSharedProp(index)->SetExtraLargeStringValue(mpHeader, value))
        throw SessionPropertyAllocationFailure();
    }
  }
	void SetDecimalValue(int index, const DECIMAL * value)
  {
		CreateSharedProp(index)->SetDecimalValue((const unsigned char *) value);
  }
	void SetDateTimeValue(int index, time_t value)
  {
		CreateSharedProp(index)->SetDateTimeValue(value);
  }
	void SetDateTimeValue(int index, double value)
  {
		CreateSharedProp(index)->SetOLEDateValue(value);
  }
	void SetBoolValue(int index, bool value)
  {
		CreateSharedProp(index)->SetBooleanValue(value);
  }
	void SetDoubleValue(int index, double value)
  {
		CreateSharedProp(index)->SetDoubleValue(value);
  }
	void SetTimeValue(int index, int value)
  {
		CreateSharedProp(index)->SetTimeValue(value);
  }
	void SetEnumValue(int index, int value)  
  {
		CreateSharedProp(index)->SetEnumValue(value);
  }

	void SetInt32Value(int index, const RuntimeValue * value)
  {
		CreateSharedProp(index)->SetLongValue(value->getLong());
  }
	void SetInt64Value(int index, const RuntimeValue * value)
  {
		CreateSharedProp(index)->SetLongLongValue(value->getLongLong());
  }
	void SetStringValue(int index, const RuntimeValue * val)
  {
    const wchar_t * value = val->getWStringPtr();
    unsigned int sz = wcslen(value);
    // is the string small enough to go into the SharedPropVal directly
    if (sz * sizeof(wchar_t) < SharedSessionHeader::TINY_STRING_MAX)
    {
      CreateSharedProp(index)->SetTinyStringValue(value);
    }
    else if (sz * sizeof(wchar_t) < SharedSessionHeader::LARGE_STRING_MAX)
    {
      long ref;
      const wchar_t * wideStr = mpHeader->AllocateWideString(value, ref);
      if (!wideStr)
        // TODO:
        throw SessionPropertyAllocationFailure();

      // set the value
      CreateSharedProp(index)->SetUnicodeIDValue(ref);
    }
    else
    {
      if (FALSE == CreateSharedProp(index)->SetExtraLargeStringValue(mpHeader, value))
        throw SessionPropertyAllocationFailure();
    }
  }
	void SetDecimalValue(int index, const RuntimeValue * value)
  {
		CreateSharedProp(index)->SetDecimalValue((const unsigned char *) value->getDecPtr());
  }
	void SetDateTimeValueFromTime(int index, const RuntimeValue * value)
  {
		CreateSharedProp(index)->SetDateTimeValue(value->getTime());
  }
	void SetDateTimeValue(int index, const RuntimeValue * value)
  {
		CreateSharedProp(index)->SetOLEDateValue(value->getDatetime());
  }
	void SetBoolValue(int index, const RuntimeValue * value)
  {
		CreateSharedProp(index)->SetBooleanValue(value->getBool());
  }
	void SetDoubleValue(int index, const RuntimeValue * value)
  {
		CreateSharedProp(index)->SetDoubleValue(value->getDouble());
  }
	void SetTimeValue(int index, const RuntimeValue * value)
  {
		CreateSharedProp(index)->SetTimeValue(value->getTime());
  }
	void SetEnumValue(int index, const RuntimeValue * value)  
  {
		CreateSharedProp(index)->SetEnumValue(value->getEnum());
  }

  void GetInt32Value(int index, RuntimeValue * value)
  {
    const SharedPropVal * prop = mpSession->GetReadablePropertyWithID(mpHeader, index);
    if (prop == NULL)
    {
      value->assignNull();
      return;
    }
    
    switch(prop->GetType())
    {
    case SharedPropVal::LONG_PROPERTY:
    {
      value->assignLong(prop->GetLongValue());
      break;
    }
    case SharedPropVal::ENUM_PROPERTY:
    {
      value->assignLong(prop->GetEnumValue());
      break;
    }
    default:
    {
      value->assignNull();
      break;
    }
    }
  }
  void GetInt64Value(int index, RuntimeValue * value)
  {
    const SharedPropVal * prop = mpSession->GetReadablePropertyWithID(mpHeader, index);
    if (prop == NULL)
    {
      value->assignNull();
      return;
    }
    
    switch(prop->GetType())
    {
    case SharedPropVal::LONGLONG_PROPERTY:
    {
      value->assignLongLong(prop->GetLongLongValue());
      break;
    }
    case SharedPropVal::LONG_PROPERTY:
    {
      value->assignLongLong(prop->GetLongValue());
      break;
    }
    case SharedPropVal::ENUM_PROPERTY:
    {
      value->assignLongLong(prop->GetEnumValue());
      break;
    }
    default:
    {
      value->assignNull();
      break;
    }
    }
  }
  void GetStringValue(int index, RuntimeValue * value)
  {
    const SharedPropVal * prop = mpSession->GetReadablePropertyWithID(mpHeader, index);
    if (prop == NULL)
    {
      value->assignNull();
      return;
    }
    
    switch(prop->GetType())
    {
    case SharedPropVal::TINYSTRING_PROPERTY:
    {
      value->assignWString(prop->GetTinyStringValue());
      break;
    }
    case SharedPropVal::UNICODE_PROPERTY:
    {
      long id = prop->GetUnicodeIDValue();
      value->assignWString(mpHeader->GetWideString(id));
      break;
    }
    case SharedPropVal::EXTRA_LARGE_STRING_PROPERTY:
    {
      wchar_t * str = prop->CopyExtraLargeStringValue(mpHeader);
      value->assignWString(str);
      delete [] str;
      break;
    }
    default:
    {
      value->assignNull();
      break;
    }
    }
  }
  void GetDoubleValue(int index, RuntimeValue * value)
  {
    const SharedPropVal * prop = mpSession->GetReadablePropertyWithID(mpHeader, index);
    if (prop == NULL)
    {
      value->assignNull();
      return;
    }
    
    switch(prop->GetType())
    {
    case SharedPropVal::DOUBLE_PROPERTY:
    {
      value->assignDouble(prop->GetDoubleValue());
      break;
    }
    default:
    {
      value->assignNull();
      break;
    }
    }
  }

  void GetDecimalValue(int index, RuntimeValue * value)
  {
    const SharedPropVal * prop = mpSession->GetReadablePropertyWithID(mpHeader, index);
    if (prop == NULL)
    {
      value->assignNull();
      return;
    }
    
    switch(prop->GetType())
    {
    case SharedPropVal::DECIMAL_PROPERTY:
    {
      value->assignDecimal((LPDECIMAL) prop->GetDecimalValue());
      break;
    }
    default:
    {
      value->assignNull();
      break;
    }
    }
  }

  void GetBooleanValue(int index, RuntimeValue * value)
  {
    const SharedPropVal * prop = mpSession->GetReadablePropertyWithID(mpHeader, index);
    if (prop == NULL)
    {
      value->assignNull();
      return;
    }
    
    switch(prop->GetType())
    {
    case SharedPropVal::BOOL_PROPERTY:
    {
      value->assignBool(prop->GetBooleanValue() ? true : false);
      break;
    }
    default:
    {
      value->assignNull();
      break;
    }
    }
  }

  void GetDatetimeValue(int index, RuntimeValue * value)
  {
    const SharedPropVal * prop = mpSession->GetReadablePropertyWithID(mpHeader, index);
    if (prop == NULL)
    {
      value->assignNull();
      return;
    }
    
    switch(prop->GetType())
    {
    case SharedPropVal::OLEDATE_PROPERTY:
    {
      value->assignDatetime(prop->GetOLEDateValue());
      break;
    }
    case SharedPropVal::TIMET_PROPERTY:
    {
      time_t timeT = prop->GetDateTimeValue();
      DATE date;
      ::OleDateFromTimet(&date, timeT);
      value->assignDatetime(date);
      break;
    }
    default:
    {
      value->assignNull();
      break;
    }
    }
  }

  void GetTimeValue(int index, RuntimeValue * value)
  {
    const SharedPropVal * prop = mpSession->GetReadablePropertyWithID(mpHeader, index);
    if (prop == NULL)
    {
      value->assignNull();
      return;
    }
    
    switch(prop->GetType())
    {
    case SharedPropVal::TIME_PROPERTY:
    {
      value->assignTime(prop->GetTimeValue());
      break;
    }
    default:
    {
      value->assignNull();
      break;
    }
    }
  }
  void GetEnumValue(int index, RuntimeValue * value)
  {
    const SharedPropVal * prop = mpSession->GetReadablePropertyWithID(mpHeader, index);
    if (prop == NULL)
    {
      value->assignNull();
      return;
    }
    
    switch(prop->GetType())
    {
    case SharedPropVal::ENUM_PROPERTY:
    {
      value->assignEnum(prop->GetEnumValue());
      break;
    }
    default:
    {
      value->assignNull();
      break;
    }
    }
  }
};

#endif
