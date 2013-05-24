#ifndef _BOOLEANPREDICATEINTERFACE_H_
#define _BOOLEANPREDICATEINTERFACE_H_

#include <string>
#include <map>
#include <vector>
#include "MTSQLInterpreter.h"
#include "RecordModel.h"
#include "MTUtil.h"
#include "RuntimeValue.h"
#include "LogAdapter.h"

#include <boost/algorithm/string.hpp>
#include <boost/format.hpp>

//
// This is the interface between a Record and the MTSQL interpreter. 
//

class RecordFrame;

class RecordAccess : public Access
{
private:
  RunTimeDataAccessor * mAccessor;
	RecordAccess(RunTimeDataAccessor * accessor) : mAccessor(accessor) {}
	friend RecordFrame;
public:

	RunTimeDataAccessor* getRunTimeDataAccessor() const 
	{
		return mAccessor;
	}

};

class RecordFrame : public Frame
{
private:
	std::map<std::string, AccessPtr> mMap;
  const RecordMetadata * mMetadata;

	AccessPtr create(const std::string& name, RunTimeDataAccessor* accessor)
	{
		AccessPtr mtAccess=mMap[name];
		if (mtAccess == nullAccess)
		{
			mtAccess = AccessPtr(new RecordAccess(accessor));
			mMap[name] = mtAccess;
		}
		return mtAccess;
	}

public:
	RecordFrame(const RecordMetadata * metadata) 
    :
    mMetadata(metadata)
	{
	}

	AccessPtr allocateVariable(const std::string& var, int ty)
	{
		try {
			// All MTSQL variables begin with @.  Truncate this
			// leading character to make it valid for use as a
			// session variable name.
      std::wstring wstrVar;
      ::ASCIIToWide(wstrVar, var.substr(1, var.size()-1));
      if (!mMetadata->HasColumn(wstrVar))
      {
        return nullAccess;
      }
      // Make sure types are compatible.
      switch(mMetadata->GetColumn(wstrVar)->GetPhysicalFieldType()->GetPipelineType())
      {
      case MTPipelineLib::PROP_TYPE_DECIMAL:
      {
        if (ty != RuntimeValue::TYPE_DECIMAL) return nullAccess;
        break;
      }
      case MTPipelineLib::PROP_TYPE_ENUM:
      {
        if (ty != RuntimeValue::TYPE_ENUM) return nullAccess;
        break;
      }
      case MTPipelineLib::PROP_TYPE_INTEGER:
      {
        if (ty != RuntimeValue::TYPE_INTEGER) return nullAccess;
        break;
      }
      case MTPipelineLib::PROP_TYPE_BOOLEAN:
      {
        if (ty != RuntimeValue::TYPE_BOOLEAN) return nullAccess;
        break;
      }
      case MTPipelineLib::PROP_TYPE_UNICODE_STRING:
      case MTPipelineLib::PROP_TYPE_STRING:
      {
        if (ty != RuntimeValue::TYPE_WSTRING) return nullAccess;
        break;
      }
      case MTPipelineLib::PROP_TYPE_ASCII_STRING:
      {
        if (ty != RuntimeValue::TYPE_STRING) return nullAccess;
        break;
      }
      case MTPipelineLib::PROP_TYPE_BIGINTEGER:
      {
        if (ty != RuntimeValue::TYPE_BIGINTEGER) return nullAccess;
        break;
      }
      case MTPipelineLib::PROP_TYPE_DOUBLE:
      {
        if (ty != RuntimeValue::TYPE_DOUBLE) return nullAccess;
        break;
      }
      case MTPipelineLib::PROP_TYPE_DATETIME:
      {
        if (ty != RuntimeValue::TYPE_DATETIME) return nullAccess;
        break;
      }
      case MTPipelineLib::PROP_TYPE_OPAQUE:
      {
        if (ty != RuntimeValue::TYPE_BINARY) return nullAccess;
        break;
      }
      }
      RunTimeDataAccessor * accessor = mMetadata->GetColumn(wstrVar);
      ASSERT(accessor != NULL);
			return create(var, accessor);
		} 
    catch (std::exception & ) 
    {
      return nullAccess;
		}
	}
	~RecordFrame() 
	{
	}
};


class RecordActivationRecord : public ActivationRecord
{
private:
  record_t mRecordBuffer;

public:
	RecordActivationRecord(record_t recordBuffer) 
    :
    mRecordBuffer(recordBuffer)
	{
	}

  void SetBuffer(record_t recordBuffer)
  {
    mRecordBuffer = recordBuffer;
  }

	void getLongValue(const Access * access, RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(accessor->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignLong(accessor->GetLongValue(mRecordBuffer));
	}
	void getLongLongValue(const Access * access, RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(accessor->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignLongLong(accessor->GetBigIntegerValue(mRecordBuffer));
	}
	void getDoubleValue(const Access * access, RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(accessor->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignDouble(accessor->GetDoubleValue(mRecordBuffer));
	}
	void getDecimalValue(const Access * access, RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(accessor->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignDecimal(accessor->GetDecimalValue(mRecordBuffer));
	}
	void getStringValue(const Access * access, RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(accessor->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignString(accessor->GetUTF8StringValue(mRecordBuffer));
	}
	void getWStringValue(const Access * access, RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(accessor->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignWString(accessor->GetStringValue(mRecordBuffer));
	}
	void getBooleanValue(const Access * access, RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(accessor->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignBool(accessor->GetBooleanValue(mRecordBuffer));
	}
	void getDatetimeValue(const Access * access, RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(accessor->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignDatetime(accessor->GetDatetimeValue(mRecordBuffer));
	}
	void getTimeValue(const Access * access, RuntimeValue * value)
	{
    ASSERT(FALSE);
	}
	void getEnumValue(const Access * access, RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(accessor->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignEnum(accessor->GetEnumValue(mRecordBuffer));
	}
	void getBinaryValue(const Access * access, RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(accessor->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
    {
      const boost::uint8_t * val = accessor->GetBinaryValue(mRecordBuffer);
			value->assignBinary(val, val+16);
    }
	}
	void setLongValue(const Access * access, const RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(value->isNullRaw()) 
			accessor->SetNull(mRecordBuffer);
    else
			accessor->SetValue(mRecordBuffer, value->getLongPtr());
	}
	void setLongLongValue(const Access * access, const RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(value->isNullRaw()) 
			accessor->SetNull(mRecordBuffer);
    else
			accessor->SetValue(mRecordBuffer, value->getLongLongPtr());
	}
	void setDoubleValue(const Access * access, const RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(value->isNullRaw()) 
			accessor->SetNull(mRecordBuffer);
    else
			accessor->SetValue(mRecordBuffer, value->getDoublePtr());
	}
	void setDecimalValue(const Access * access, const RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(value->isNullRaw()) 
			accessor->SetNull(mRecordBuffer);
    else
			accessor->SetValue(mRecordBuffer, value->getDecPtr());
	}
	void setStringValue(const Access * access, const RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(value->isNullRaw()) 
			accessor->SetNull(mRecordBuffer);
    else
			accessor->SetValue(mRecordBuffer, value->getStringPtr());
	}
	void setWStringValue(const Access * access, const RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(value->isNullRaw()) 
			accessor->SetNull(mRecordBuffer);
    else
			accessor->SetValue(mRecordBuffer, value->getWStringPtr());
	}
	void setBooleanValue(const Access * access, const RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(value->isNullRaw()) 
			accessor->SetNull(mRecordBuffer);
    else
			accessor->SetValue(mRecordBuffer, value->getBoolPtr());
	}
	void setDatetimeValue(const Access * access, const RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(value->isNullRaw()) 
			accessor->SetNull(mRecordBuffer);
    else
			accessor->SetValue(mRecordBuffer, value->getDatetimePtr());
	}
	void setTimeValue(const Access * access, const RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(value->isNullRaw()) 
			accessor->SetNull(mRecordBuffer);
    else
			accessor->SetValue(mRecordBuffer, value->getTimePtr());
	}
	void setEnumValue(const Access * access, const RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(value->isNullRaw()) 
			accessor->SetNull(mRecordBuffer);
    else
			accessor->SetValue(mRecordBuffer, value->getEnumPtr());
	}
	void setBinaryValue(const Access * access, const RuntimeValue * value)
	{
		RunTimeDataAccessor * accessor = (static_cast<const RecordAccess *>(access))->getRunTimeDataAccessor();
		if(value->isNullRaw()) 
			accessor->SetNull(mRecordBuffer);
    else
			accessor->SetValue(mRecordBuffer, value->getBinaryPtr());
	}

	ActivationRecord* getStaticLink() 
	{
		// This is always a global environment; can't have a static link.
		return NULL;
	}
};

class PipelineCompileEnvironment : public GlobalCompileEnvironment
{
private:
  MetraFlowLoggerPtr mLogger;
public:
	PipelineCompileEnvironment(MetraFlowLoggerPtr aLogger)
	{
		mLogger = aLogger;
  }
	void logDebug(const std::string& str)
	{
		mLogger->logDebug(str);
	}

	void logInfo(const std::string& str)
	{
		mLogger->logInfo(str);
	}

	void logWarning(const std::string& str)
	{
		mLogger->logWarning(str);
	}

	void logError(const std::string& str)
	{
		mLogger->logError(str);
	}

	bool isOkToLogDebug()
	{
		return mLogger->isOkToLogDebug();
	}

	bool isOkToLogInfo()
	{
		return mLogger->isOkToLogInfo();
	}

	bool isOkToLogWarning()
	{
		return mLogger->isOkToLogWarning();
	}

	bool isOkToLogError()
	{
		return mLogger->isOkToLogError();
	}
};


class RecordCompileEnvironment : public PipelineCompileEnvironment
{
public:
	RecordCompileEnvironment(MetraFlowLoggerPtr aLogger, const RecordMetadata * metadata)
    :
    PipelineCompileEnvironment(aLogger)
	{
		mFrame = new RecordFrame(metadata);
	}
	
	RecordCompileEnvironment(MetraFlowLoggerPtr aLogger, Frame * frame)
    :
    PipelineCompileEnvironment(aLogger),
    mFrame(frame)
  {
  }
	
	~RecordCompileEnvironment()
	{
		delete mFrame;
		mFrame = NULL;
	}

	Frame* createFrame()
	{
		return mFrame;
	}

private:
	Frame* mFrame;
};

class PipelineRuntimeEnvironment : public GlobalRuntimeEnvironment
{
private:
  MetraFlowLoggerPtr mLogger;
public:
	PipelineRuntimeEnvironment(MetraFlowLoggerPtr aLogger)
  {
    mLogger = aLogger;
  }
	void logDebug(const std::string& str)
	{
		mLogger->logDebug(str);
	}

	void logInfo(const std::string& str)
	{
		mLogger->logInfo(str);
	}

	void logWarning(const std::string& str)
	{
		mLogger->logWarning(str);
	}

	void logError(const std::string& str)
	{
		mLogger->logError(str);
	}

	bool isOkToLogDebug()
	{
		return mLogger->isOkToLogDebug();
	}

	bool isOkToLogInfo()
	{
		return mLogger->isOkToLogInfo();
	}

	bool isOkToLogWarning()
	{
		return mLogger->isOkToLogWarning();
	}

	bool isOkToLogError()
	{
		return mLogger->isOkToLogError();
	}

	MTPipelineLib::IMTSQLRowsetPtr getRowset()
	{
    // We are not using query tags, so it really doesn't matter what
    // config dir to use.
    return NULL;
	}

	ActivationRecord* getActivationRecord()
	{
		return NULL;
	}
};


class RecordRuntimeEnvironment : public PipelineRuntimeEnvironment
{
public:
	RecordRuntimeEnvironment(MetraFlowLoggerPtr aLogger) :
    PipelineRuntimeEnvironment(aLogger),
		mActivationRecord(NULL)
	{
	}

	ActivationRecord* getActivationRecord()
	{
		return &mActivationRecord;
	}

  void SetBuffer(record_t recordBuffer)
  {
    mActivationRecord.SetBuffer(recordBuffer);
  }

protected:
	RecordActivationRecord mActivationRecord;
};

class DualAccess : public Access
{
private:
  std::size_t mIndex;
  AccessPtr mAccess;
public:
  const Access * getAccess() const
  {
    return mAccess.get();
  }
  std::size_t getIndex() const
  {
    return mIndex; 
  }

  DualAccess(AccessPtr left, AccessPtr right)
  {
    ASSERT((left.get() != NULL && right.get() == NULL) ||
      (left.get() == NULL && right.get() != NULL));
    if (left.get() != NULL)
    {
      mAccess=left;
      mIndex = 0;
    }
    else
    {
      mAccess = right;
      mIndex = 1;
    }
  }
};

class DualFrame : public Frame
{
private:
  
  Frame * mFrame[2];
  std::string mLeftPrefix;
  std::string mRightPrefix;
  unsigned int mLeftLength;
  unsigned int mRightLength;
	std::map<std::string, AccessPtr> mMap;
  

public:
	DualFrame(Frame * left, Frame * right, const std::string& leftPrefix, const std::string& rightPrefix) 
    :
    mLeftPrefix(leftPrefix),
    mRightPrefix(rightPrefix)
	{
    mFrame[0] = left;
    mFrame[1] = right;
    mLeftLength = mLeftPrefix.size();
    mRightLength = mRightPrefix.size();
	}

	AccessPtr allocateVariable(const std::string& var, int ty)
	{
    std::map<std::string, AccessPtr>::iterator it = mMap.find(var);
    if (mMap.end() != it) return it->second;

    unsigned int sz = var.size();
    std::string strip = var.substr(1, sz-1);
    if (mLeftPrefix == strip.substr(0, mLeftLength))
    {
      AccessPtr ptr = mFrame[0]->allocateVariable("@" + strip.substr(mLeftLength), ty);
      if (ptr.get() == NULL) 
        throw MTSQLException((boost::format("Undefined variable : %1%") % var).str());
      ptr = AccessPtr(new DualAccess(ptr, nullAccess));
      mMap[var] = ptr;
      return ptr;
    }
    else if (mRightPrefix == strip.substr(0,mRightLength))
    {
      AccessPtr ptr = mFrame[1]->allocateVariable("@" + strip.substr(mRightLength), ty);
      if (ptr.get() == NULL) 
        throw MTSQLException((boost::format("Undefined variable : %1%") % var).str());        
      ptr = AccessPtr(new DualAccess(nullAccess, ptr));
      mMap[var] = ptr;
      return ptr;
    }
    else
    {
      AccessPtr leftPtr = mFrame[0]->allocateVariable(var, ty);
      AccessPtr rightPtr = mFrame[1]->allocateVariable(var, ty);
      if (leftPtr.get() != NULL && rightPtr.get() != NULL)
        throw MTSQLException((boost::format("Ambiguous variable name: %1%") % var).str());
      if (leftPtr.get() == NULL && rightPtr.get() == NULL)
        throw MTSQLException((boost::format("Undefined variable : %1%") % var).str());
      AccessPtr ptr(leftPtr.get() != NULL ? new DualAccess(leftPtr, nullAccess) : new DualAccess(nullAccess, rightPtr));
      mMap[var] = ptr;
      return ptr;      
    }
	}
	~DualFrame() 
	{
	}

};

class DualCompileEnvironment : public PipelineCompileEnvironment
{
public:
	DualCompileEnvironment(MetraFlowLoggerPtr aLogger, Frame * left, Frame * right, const std::string& leftPrefix, const std::string& rightPrefix)
    :
    PipelineCompileEnvironment(aLogger)
	{
		mFrame = new DualFrame(left, right, leftPrefix, rightPrefix);
	}
	
	~DualCompileEnvironment()
	{
		delete mFrame;
		mFrame = NULL;
	}

	Frame* createFrame()
	{
		return mFrame;
	}

private:
	Frame* mFrame;
};


class DualActivationRecord : public ActivationRecord
{
private:
  ActivationRecord * mRecord[2];

public:
	DualActivationRecord(ActivationRecord * left, ActivationRecord * right) 
	{
    mRecord[0] = left;
    mRecord[1] = right;
	}

	void getLongValue(const Access * access, RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->getLongValue(dual->getAccess(), value);
	}
	void getLongLongValue(const Access * access, RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->getLongLongValue(dual->getAccess(), value);
	}
	void getDoubleValue(const Access * access, RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->getDoubleValue(dual->getAccess(), value);
	}
	void getDecimalValue(const Access * access, RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->getDecimalValue(dual->getAccess(), value);
	}
	void getStringValue(const Access * access, RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->getStringValue(dual->getAccess(), value);
	}
	void getWStringValue(const Access * access, RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->getWStringValue(dual->getAccess(), value);
	}
	void getBooleanValue(const Access * access, RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->getBooleanValue(dual->getAccess(), value);
	}
	void getDatetimeValue(const Access * access, RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->getDatetimeValue(dual->getAccess(), value);
	}
	void getTimeValue(const Access * access, RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->getTimeValue(dual->getAccess(), value);
	}
	void getEnumValue(const Access * access, RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->getEnumValue(dual->getAccess(), value);
	}
	void getBinaryValue(const Access * access, RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->getBinaryValue(dual->getAccess(), value);
	}
	void setLongValue(const Access * access, const RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->setLongValue(dual->getAccess(), value);
	}
	void setLongLongValue(const Access * access, const RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->setLongLongValue(dual->getAccess(), value);
	}
	void setDoubleValue(const Access * access, const RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->setDoubleValue(dual->getAccess(), value);
	}
	void setDecimalValue(const Access * access, const RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->setDecimalValue(dual->getAccess(), value);
	}
	void setStringValue(const Access * access, const RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->setStringValue(dual->getAccess(), value);
	}
	void setWStringValue(const Access * access, const RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->setWStringValue(dual->getAccess(), value);
	}
	void setBooleanValue(const Access * access, const RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->setBooleanValue(dual->getAccess(), value);
	}
	void setDatetimeValue(const Access * access, const RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->setDatetimeValue(dual->getAccess(), value);
	}
	void setTimeValue(const Access * access, const RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->setTimeValue(dual->getAccess(), value);
	}
	void setEnumValue(const Access * access, const RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->setEnumValue(dual->getAccess(), value);
	}
	void setBinaryValue(const Access * access, const RuntimeValue * value)
	{
		const DualAccess * dual = static_cast<const DualAccess *>(access);
    mRecord[dual->getIndex()]->setBinaryValue(dual->getAccess(), value);
	}

	ActivationRecord* getStaticLink() 
	{
		// This is always a global environment; can't have a static link.
		return NULL;
	}
};

class DualRuntimeEnvironment : public PipelineRuntimeEnvironment
{
public:
	DualRuntimeEnvironment(MetraFlowLoggerPtr aLogger, ActivationRecord * left, ActivationRecord * right) 
    :
    PipelineRuntimeEnvironment(aLogger),
		mActivationRecord(left, right)
	{
	}

	ActivationRecord* getActivationRecord()
	{
		return &mActivationRecord;
	}

protected:
  DualActivationRecord mActivationRecord;
};

template <class _L, class _R>
class DualAccess_T : public Access
{
private:
  bool mIsLeft;
  AccessPtr mLeft;
  AccessPtr mRight;
public:
  const _L * getLeft() const
  {
    return (const _L *) mLeft.get();
  }
  const _R * getRight() const
  {
    return (const _R *) mRight.get();
  }
  bool isLeft() const
  {
    return mIsLeft;
  }

  DualAccess_T(AccessPtr left, AccessPtr right)
    :
    mLeft(left),
    mRight(right)
  {
    ASSERT((left.get() != NULL && right.get() == NULL) ||
      (left.get() == NULL && right.get() != NULL));
    mIsLeft = (NULL != left.get());
  }
};

template <class _L, class _R>
class DualFrame_T : public Frame
{
private:
  
  Frame * mFrame[2];
  std::string mLeftPrefix;
  std::string mRightPrefix;
  unsigned int mLeftLength;
  unsigned int mRightLength;
	std::map<std::string, AccessPtr> mMap;
  

public:
	DualFrame_T(Frame * left, Frame * right, const std::string& leftPrefix, const std::string& rightPrefix) 
    :
    mLeftPrefix(leftPrefix),
    mRightPrefix(rightPrefix)
	{
    mFrame[0] = left;
    mFrame[1] = right;
    mLeftLength = mLeftPrefix.size();
    mRightLength = mRightPrefix.size();
	}

	AccessPtr allocateVariable(const std::string& var, int ty)
	{
    std::map<std::string, AccessPtr>::iterator it = mMap.find(var);
    if (mMap.end() != it) return it->second;

    unsigned int sz = var.size();
    std::string strip = var.substr(1, sz-1);
    if (mLeftPrefix == strip.substr(0, mLeftLength))
    {
      AccessPtr ptr = mFrame[0]->allocateVariable("@" + strip.substr(mLeftLength), ty);
      if (ptr.get() == NULL) return nullAccess;
      ptr = AccessPtr(new DualAccess<_L,_R>(ptr, nullAccess));
      mMap[var] = ptr;
      return ptr;
    }
    else if (mRightPrefix == strip.substr(0,mRightLength))
    {
      AccessPtr ptr = mFrame[1]->allocateVariable("@" + strip.substr(mRightLength), ty);
      if (ptr.get() == NULL) return nullAccess;
      ptr = AccessPtr(new DualAccess<_L,_R>(nullAccess, ptr));
      mMap[var] = ptr;
      return ptr;
    }
    else
    {
      return nullAccess;
    }
	}
	~DualFrame_T() 
	{
	}

};

template <class _L, class _R>
class DualCompileEnvironment_T : public PipelineCompileEnvironment
{
public:
	DualCompileEnvironment_T(MetraFlowLoggerPtr aLogger, Frame * left, Frame * right, const std::string& leftPrefix, const std::string& rightPrefix)
    :
    PipelineCompileEnvironment(aLogger)
	{
		mFrame = new DualFrame<_L,_R>(left, right, leftPrefix, rightPrefix);
	}
	
	~DualCompileEnvironment_T()
	{
		delete mFrame;
		mFrame = NULL;
	}

	Frame* createFrame()
	{
		return mFrame;
	}

private:
	Frame* mFrame;
};


template <class _L, class _R>
class DualActivationRecord_T
{
public:
  typedef DualAccess_T<typename _L::access,typename _R::access> access;
private:
  _L * mLeft;
  _R * mRight;

public:
	DualActivationRecord_T(_L * left, _R * right) 
    :
    mLeft(left),
    mRight(right)
	{
	}
  ~DualActivationRecord_T()
  {
  }
	void getLongValue(const access * dual, RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->getLongValue(dual->getLeft(), value);
    else
      mRight->getLongValue(dual->getRight(), value);
	}
	void getLongLongValue(const access * dual, RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->getLongLongValue(dual->getLeft(), value);
    else
      mRight->getLongLongValue(dual->getRight(), value);
	}
	void getDoubleValue(const access * dual, RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->getDoubleValue(dual->getLeft(), value);
    else
      mRight->getDoubleValue(dual->getRight(), value);
	}
	void getDecimalValue(const access * dual, RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->getDecimalValue(dual->getLeft(), value);
    else
      mRight->getDecimalValue(dual->getRight(), value);
	}
	void getStringValue(const access * dual, RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->getStringValue(dual->getLeft(), value);
    else
      mRight->getStringValue(dual->getRight(), value);
	}
	void getWStringValue(const access * dual, RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->getWStringValue(dual->getLeft(), value);
    else
      mRight->getWStringValue(dual->getRight(), value);
	}
	void getBooleanValue(const access * dual, RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->getBooleanValue(dual->getLeft(), value);
    else
      mRight->getBooleanValue(dual->getRight(), value);
	}
	void getDatetimeValue(const access * dual, RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->getDatetimeValue(dual->getLeft(), value);
    else
      mRight->getDatetimeValue(dual->getRight(), value);
	}
	void getTimeValue(const access * dual, RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->getTimeValue(dual->getLeft(), value);
    else
      mRight->getTimeValue(dual->getRight(), value);
	}
	void getEnumValue(const access * dual, RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->getEnumValue(dual->getLeft(), value);
    else
      mRight->getEnumValue(dual->getRight(), value);
	}
	void getBinaryValue(const access * dual, RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->getBinaryValue(dual->getLeft(), value);
    else
      mRight->getBinaryValue(dual->getRight(), value);
	}
	void setLongValue(const access * dual, const RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->setLongValue(dual->getLeft(), value);
    else
      mRight->setLongValue(dual->getRight(), value);
	}
	void setLongLongValue(const access * dual, const RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->setLongLongValue(dual->getLeft(), value);
    else
      mRight->setLongLongValue(dual->getRight(), value);
	}
	void setDoubleValue(const access * dual, const RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->setDoubleValue(dual->getLeft(), value);
    else
      mRight->setDoubleValue(dual->getRight(), value);
	}
	void setDecimalValue(const access * dual, const RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->setDecimalValue(dual->getLeft(), value);
    else
      mRight->setDecimalValue(dual->getRight(), value);
	}
	void setStringValue(const access * dual, const RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->setStringValue(dual->getLeft(), value);
    else
      mRight->setStringValue(dual->getRight(), value);
	}
	void setWStringValue(const access * dual, const RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->setWStringValue(dual->getLeft(), value);
    else
      mRight->setWStringValue(dual->getRight(), value);
	}
	void setBooleanValue(const access * dual, const RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->setBooleanValue(dual->getLeft(), value);
    else
      mRight->setBooleanValue(dual->getRight(), value);
	}
	void setDatetimeValue(const access * dual, const RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->setDatetimeValue(dual->getLeft(), value);
    else
      mRight->setDatetimeValue(dual->getRight(), value);
	}
	void setTimeValue(const access * dual, const RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->setTimeValue(dual->getLeft(), value);
    else
      mRight->setTimeValue(dual->getRight(), value);
	}
	void setEnumValue(const access * dual, const RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->setEnumValue(dual->getLeft(), value);
    else
      mRight->setEnumValue(dual->getRight(), value);
	}
	void setBinaryValue(const access * dual, const RuntimeValue * value)
	{
		if(dual->isLeft()) 
      mLeft->setBinaryValue(dual->getLeft(), value);
    else
      mRight->setBinaryValue(dual->getRight(), value);
	}
};

template <class _L, class _R>
class DualRuntimeEnvironment_T
{
public:
  typedef DualActivationRecord_T<_L,_R> activation_record;

public:
	DualRuntimeEnvironment_T(_L * left, _R * right) 
    :
		mActivationRecord(left, right)
	{
	}

	activation_record& getActivationRecord()
	{
		return mActivationRecord;
	}

protected:
  activation_record mActivationRecord;
};

class RecordActivationRecordConcrete
{
public:
  typedef RecordAccess access;

private:
  record_t mRecordBuffer;

public:
	RecordActivationRecordConcrete(record_t recordBuffer) 
    :
    mRecordBuffer(recordBuffer)
	{
	}

  void SetBuffer(record_t recordBuffer)
  {
    mRecordBuffer = recordBuffer;
  }

	void getLongValue(const RecordAccess * accessor, RuntimeValue * value)
	{
		if(accessor->getRunTimeDataAccessor()->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignLong(accessor->getRunTimeDataAccessor()->GetLongValue(mRecordBuffer));
	}
	void getLongLongValue(const RecordAccess * accessor, RuntimeValue * value)
	{
		if(accessor->getRunTimeDataAccessor()->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignLongLong(accessor->getRunTimeDataAccessor()->GetBigIntegerValue(mRecordBuffer));
	}
	void getDoubleValue(const RecordAccess * accessor, RuntimeValue * value)
	{
		if(accessor->getRunTimeDataAccessor()->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignDouble(accessor->getRunTimeDataAccessor()->GetDoubleValue(mRecordBuffer));
	}
	void getDecimalValue(const RecordAccess * accessor, RuntimeValue * value)
	{
		if(accessor->getRunTimeDataAccessor()->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignDecimal(accessor->getRunTimeDataAccessor()->GetDecimalValue(mRecordBuffer));
	}
	void getStringValue(const RecordAccess * accessor, RuntimeValue * value)
	{
		if(accessor->getRunTimeDataAccessor()->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignString(accessor->getRunTimeDataAccessor()->GetUTF8StringValue(mRecordBuffer));
	}
	void getWStringValue(const RecordAccess * accessor, RuntimeValue * value)
	{
		if(accessor->getRunTimeDataAccessor()->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignWString(accessor->getRunTimeDataAccessor()->GetStringValue(mRecordBuffer));
	}
	void getBooleanValue(const RecordAccess * accessor, RuntimeValue * value)
	{
		if(accessor->getRunTimeDataAccessor()->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignBool(accessor->getRunTimeDataAccessor()->GetBooleanValue(mRecordBuffer));
	}
	void getDatetimeValue(const RecordAccess * accessor, RuntimeValue * value)
	{
		if(accessor->getRunTimeDataAccessor()->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignDatetime(accessor->getRunTimeDataAccessor()->GetDatetimeValue(mRecordBuffer));
	}
	void getTimeValue(const RecordAccess * accessor, RuntimeValue * value)
	{
    ASSERT(FALSE);
	}
	void getEnumValue(const RecordAccess * accessor, RuntimeValue * value)
	{
		if(accessor->getRunTimeDataAccessor()->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
			value->assignEnum(accessor->getRunTimeDataAccessor()->GetEnumValue(mRecordBuffer));
	}
	void getBinaryValue(const RecordAccess * accessor, RuntimeValue * value)
	{
		if(accessor->getRunTimeDataAccessor()->GetNull(mRecordBuffer)) 
			value->assignNull();
    else
    {
      const boost::uint8_t * val = accessor->getRunTimeDataAccessor()->GetBinaryValue(mRecordBuffer);
			value->assignBinary(val, val+16);
    }
	}
	void setLongValue(const RecordAccess * accessor, const RuntimeValue * value)
	{
		if(value->isNullRaw()) 
			accessor->getRunTimeDataAccessor()->SetNull(mRecordBuffer);
    else
			accessor->getRunTimeDataAccessor()->SetValue(mRecordBuffer, value->getLongPtr());
	}
	void setLongLongValue(const RecordAccess * accessor, const RuntimeValue * value)
	{
		if(value->isNullRaw()) 
			accessor->getRunTimeDataAccessor()->SetNull(mRecordBuffer);
    else
			accessor->getRunTimeDataAccessor()->SetValue(mRecordBuffer, value->getLongLongPtr());
	}
	void setDoubleValue(const RecordAccess * accessor, const RuntimeValue * value)
	{
		if(value->isNullRaw()) 
			accessor->getRunTimeDataAccessor()->SetNull(mRecordBuffer);
    else
			accessor->getRunTimeDataAccessor()->SetValue(mRecordBuffer, value->getDoublePtr());
	}
	void setDecimalValue(const RecordAccess * accessor, const RuntimeValue * value)
	{
		if(value->isNullRaw()) 
			accessor->getRunTimeDataAccessor()->SetNull(mRecordBuffer);
    else
			accessor->getRunTimeDataAccessor()->SetValue(mRecordBuffer, value->getDecPtr());
	}
	void setStringValue(const RecordAccess * accessor, const RuntimeValue * value)
	{
		if(value->isNullRaw()) 
			accessor->getRunTimeDataAccessor()->SetNull(mRecordBuffer);
    else
			accessor->getRunTimeDataAccessor()->SetValue(mRecordBuffer, value->getStringPtr());
	}
	void setWStringValue(const RecordAccess * accessor, const RuntimeValue * value)
	{
		if(value->isNullRaw()) 
			accessor->getRunTimeDataAccessor()->SetNull(mRecordBuffer);
    else
			accessor->getRunTimeDataAccessor()->SetValue(mRecordBuffer, value->getWStringPtr());
	}
	void setBooleanValue(const RecordAccess * accessor, const RuntimeValue * value)
	{
		if(value->isNullRaw()) 
			accessor->getRunTimeDataAccessor()->SetNull(mRecordBuffer);
    else
			accessor->getRunTimeDataAccessor()->SetValue(mRecordBuffer, value->getBoolPtr());
	}
	void setDatetimeValue(const RecordAccess * accessor, const RuntimeValue * value)
	{
		if(value->isNullRaw()) 
			accessor->getRunTimeDataAccessor()->SetNull(mRecordBuffer);
    else
			accessor->getRunTimeDataAccessor()->SetValue(mRecordBuffer, value->getDatetimePtr());
	}
	void setTimeValue(const RecordAccess * accessor, const RuntimeValue * value)
	{
		if(value->isNullRaw()) 
			accessor->getRunTimeDataAccessor()->SetNull(mRecordBuffer);
    else
			accessor->getRunTimeDataAccessor()->SetValue(mRecordBuffer, value->getTimePtr());
	}
	void setEnumValue(const RecordAccess * accessor, const RuntimeValue * value)
	{
		if(value->isNullRaw()) 
			accessor->getRunTimeDataAccessor()->SetNull(mRecordBuffer);
    else
			accessor->getRunTimeDataAccessor()->SetValue(mRecordBuffer, value->getEnumPtr());
	}
	void setBinaryValue(const RecordAccess * accessor, const RuntimeValue * value)
	{
		if(value->isNullRaw()) 
			accessor->getRunTimeDataAccessor()->SetNull(mRecordBuffer);
    else
			accessor->getRunTimeDataAccessor()->SetValue(mRecordBuffer, value->getBinaryPtr());
	}
};

class RecordRuntimeEnvironmentConcrete 
{
public:
  typedef RecordActivationRecordConcrete activation_record;
public:
	RecordRuntimeEnvironmentConcrete()
    :
		mActivationRecord(NULL)
	{
	}

	RecordActivationRecordConcrete * getActivationRecord()
	{
		return &mActivationRecord;
	}

  void SetBuffer(record_t recordBuffer)
  {
    mActivationRecord.SetBuffer(recordBuffer);
  }

protected:
	RecordActivationRecordConcrete mActivationRecord;
};

#endif
