#ifndef _MTSQLINTERPRETERSESSIONINTERFACE_H_
#define _MTSQLINTERPRETERSESSIONINTERFACE_H_

#include <MTSQLException.h>
#include <RuntimeValue.h>

//
// This is the interface between a MTSession and the MTSQL interpreter. 
//

class MTSQLSessionFrame;

class MTSessionAccess : public Access
{
private:
	long mID;
	std::string mName;
	MTSessionAccess(long access, const std::string& name) : mID(access), mName(name) {}
	friend MTSQLSessionFrame;
public:

	long getID() const 
	{
		return mID;
	}

	std::string getName() const 
	{
		return mName;
	}

};

// An exception when setting a NULL value into a session variable.
class MTSQLNullException : public MTSQLRuntimeErrorException
{
public:
	MTSQLNullException(const MTSessionAccess * access)
		:
		MTSQLRuntimeErrorException(std::string("Cannot set NULL value into session variable '") + 
															 access->getName() + 
															 std::string("'"))
	{
	}

	virtual ~MTSQLNullException()
	{
	}
};

class MTSQLSessionFrame : public Frame
{
private:
	MTPipelineLib::IMTNameIDPtr mNameID;
	map<long, AccessPtr> mMap;

	AccessPtr create(long access, const std::string& name)
	{
		AccessPtr mtAccess=mMap[access];
		if (mtAccess == nullAccess)
		{
			mtAccess = AccessPtr(new MTSessionAccess(access, name));
			mMap[access] = mtAccess;
		}
		return mtAccess;
	}

public:
	MTSQLSessionFrame(MTPipelineLib::IMTNameIDPtr aNameID) 
	{
		mNameID = aNameID;
	}

	AccessPtr allocateVariable(const string& var, int ty)
	{
		try {
      // BINARY not supported with pipeline sessions
      if (ty == RuntimeValue::TYPE_BINARY) return AccessPtr();

			// All MTSQL variables begin with @.  Truncate this
			// leading character to make it valid for use as a
			// session variable name.
			long id;
			_bstr_t bstrVar(var.substr(1, var.size()-1).c_str());
			id = mNameID->GetNameID(bstrVar);
			return create(id, var);
		} catch (_com_error e) {
      return AccessPtr();
		}
	}
	~MTSQLSessionFrame() 
	{
	}
};


class MTSQLSessionActivationRecord : public ActivationRecord
{
private:
	MTPipelineLib::IMTSessionPtr mSessionPtr;
public:
	MTSQLSessionActivationRecord(MTPipelineLib::IMTSessionPtr aSessionPtr) 
	{
		mSessionPtr = aSessionPtr;
	}

	void getLongValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignLong(mSessionPtr->GetLongProperty(id));
	}
	void getLongLongValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_LONGLONG) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignLongLong(mSessionPtr->GetLongLongProperty(id));
	}
	void getDoubleValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_DOUBLE) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignDouble(mSessionPtr->GetDoubleProperty(id));
	}
	void getDecimalValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_DECIMAL) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignDec(&DECIMAL(mSessionPtr->GetDecimalProperty(id)));
	}
	void getStringValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignString((const char *)(mSessionPtr->GetBSTRProperty(id)));
	}
	void getWStringValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignWString((const wchar_t *)(mSessionPtr->GetBSTRProperty(id)));
	}
	void getBooleanValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_BOOL) == VARIANT_FALSE) 
			value->assignNull();
    else
			(value->assignBool(VARIANT_TRUE==mSessionPtr->GetBoolProperty(id) ?
																true : 
																false));
	}
	void getDatetimeValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignDatetime(mSessionPtr->GetOLEDateProperty(id));
	}
	void getTimeValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_TIME) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignTime(mSessionPtr->GetTimeProperty(id));
	}
	void getEnumValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_ENUM) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignEnum(mSessionPtr->GetEnumProperty(id));
	}
	void getBinaryValue(const Access * access, RuntimeValue * value)
	{
    throw MTSQLRuntimeErrorException("BINARY properties not supported");
	}
	void setLongValue(const Access * access, const RuntimeValue * value)
	{
		if (false == value->isNullRaw())
		{
			mSessionPtr->SetLongProperty((static_cast<const MTSessionAccess *>(access))->getID(), value->getLong());
		}
		else
		{
			throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
		}
	}
	void setLongLongValue(const Access * access, const RuntimeValue * value)
	{
		if (false == value->isNullRaw())
		{
			mSessionPtr->SetLongLongProperty((static_cast<const MTSessionAccess *>(access))->getID(), value->getLongLong());
		}
		else
		{
			throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
		}
	}
	void setDoubleValue(const Access * access, const RuntimeValue * value)
	{
		if (false == value->isNullRaw())
		{
			mSessionPtr->SetDoubleProperty((static_cast<const MTSessionAccess *>(access))->getID(), value->getDouble());
		}
		else
		{
			throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
		}
	}
	void setDecimalValue(const Access * access, const RuntimeValue * value)
	{
		if (false == value->isNullRaw())
		{
			mSessionPtr->SetDecimalProperty((static_cast<const MTSessionAccess *>(access))->getID(), MTDecimal(value->getDec()));
		}
		else
		{
			throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
		}
	}
	void setStringValue(const Access * access, const RuntimeValue * value)
	{
		if (false == value->isNullRaw())
		{
			_bstr_t bstrVal(value->getStringPtr());
			mSessionPtr->SetBSTRProperty((static_cast<const MTSessionAccess *>(access))->getID(), bstrVal);
		}
		else
		{
			throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
		}
	}
	void setWStringValue(const Access * access, const RuntimeValue * value)
	{
		if (false == value->isNullRaw())
		{
			_bstr_t bstrVal(value->getWStringPtr());
			mSessionPtr->SetBSTRProperty((static_cast<const MTSessionAccess *>(access))->getID(), bstrVal);
		}
		else
		{
			throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
		}
	}
	void setBooleanValue(const Access * access, const RuntimeValue * value)
	{
		if (false == value->isNullRaw())
		{
			mSessionPtr->SetBoolProperty((static_cast<const MTSessionAccess *>(access))->getID(), value->getBool() ? VARIANT_TRUE : VARIANT_FALSE);
		}
		else
		{
			throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
		}
	}
	void setDatetimeValue(const Access * access, const RuntimeValue * value)
	{
		if (false == value->isNullRaw())
		{
			mSessionPtr->SetOLEDateProperty((static_cast<const MTSessionAccess *>(access))->getID(), value->getDatetime());
		}
		else
		{
			throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
		}
	}
	void setTimeValue(const Access * access, const RuntimeValue * value)
	{
		if (false == value->isNullRaw())
		{
			mSessionPtr->SetTimeProperty((static_cast<const MTSessionAccess *>(access))->getID(), value->getTime());
		}
		else
		{
			throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
		}
	}
	void setEnumValue(const Access * access, const RuntimeValue * value)
	{
		if (false == value->isNullRaw())
		{
			mSessionPtr->SetEnumProperty((static_cast<const MTSessionAccess *>(access))->getID(), value->getEnum());
		}
		else
		{
			throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
		}
	}
	void setBinaryValue(const Access * access, const RuntimeValue * value)
	{
    throw MTSQLRuntimeErrorException("BINARY properties not supported");
	}

	ActivationRecord* getStaticLink() 
	{
		// This is always a global environment; can't have a static link.
		return NULL;
	}
};


class MTSQLSessionCompileEnvironment : public GlobalCompileEnvironment
{
public:
	MTSQLSessionCompileEnvironment(MTPipelineLib::IMTLogPtr aLogger, MTPipelineLib::IMTNameIDPtr aNameID)
	{
		mLogger = aLogger;
		mNameID = aNameID;
		mFrame = new MTSQLSessionFrame(mNameID);
	}
	
	~MTSQLSessionCompileEnvironment()
	{
		delete mFrame;
		mFrame = NULL;
	}

	Frame* createFrame()
	{
		return mFrame;
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
private:
	Frame* mFrame;
	MTPipelineLib::IMTLogPtr mLogger;
	MTPipelineLib::IMTNameIDPtr mNameID;
};


template <class ActivationRecordType = MTSQLSessionActivationRecord>
class MTSQLSessionRuntimeEnvironment : public GlobalRuntimeEnvironment
{
public:
	MTSQLSessionRuntimeEnvironment(MTPipelineLib::IMTLogPtr aLogger, 
																 MTPipelineLib::IMTSessionPtr aSessionPtr,
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
	MTPipelineLib::IMTSessionPtr mSession;
	ActivationRecordType mActivationRecord;
  // This guy carries the rowset.
  MTPipelineLib::IMTSessionPtr mFirstSessionPtr;
};

#endif
