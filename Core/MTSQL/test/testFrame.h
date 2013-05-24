#ifndef _TESTFRAME_H_
#define _TESTFRAME_H_

#include <map>
#include <string>
#include <vector>
#include "MTSQLInterpreter.h"
#include "RuntimeValue.h"
#include "MTSQLUnitTest.h"

class VectorActivationRecord : public ActivationRecord
{
private:
	ActivationRecord* mStaticLink;
	std::vector<RuntimeValue> mRuntimeEnv;

public:
	VectorActivationRecord(ActivationRecord* staticLink, std::size_t sz) 
    : 
    mStaticLink(staticLink),
    mRuntimeEnv(sz)
	{
	}

  std::vector<RuntimeValue>& getValues()
  {
    return mRuntimeEnv;
  }

	void getLongValue(const Access * access, RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (thisVal.isNullRaw())
      value->assignNull();
    else
      value->assignLong(thisVal.getLong());
  }
	void getLongLongValue(const Access * access, RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (thisVal.isNullRaw())
      value->assignNull();
    else
      value->assignLongLong(thisVal.getLongLong());
  }
	void getDoubleValue(const Access * access, RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (thisVal.isNullRaw())
      value->assignNull();
    else
      value->assignDouble(thisVal.getDouble());
  }
	void getDecimalValue(const Access * access, RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (thisVal.isNullRaw())
      value->assignNull();
    else
      value->assignDec(thisVal.getDecPtr());
  }
	void getStringValue(const Access * access, RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (thisVal.isNullRaw())
      value->assignNull();
    else
      value->assignString(thisVal.getStringPtr());
  }
	void getWStringValue(const Access * access, RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (thisVal.isNullRaw())
      value->assignNull();
    else
      value->assignWString(thisVal.getWStringPtr());
  }
	void getBooleanValue(const Access * access, RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (thisVal.isNullRaw())
      value->assignNull();
    else
      value->assignBool(thisVal.getBool());
  }
	void getDatetimeValue(const Access * access, RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (thisVal.isNullRaw())
      value->assignNull();
    else
      value->assignDatetime(thisVal.getDatetime());
  }
	void getTimeValue(const Access * access, RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (thisVal.isNullRaw())
      value->assignNull();
    else
      value->assignTime(thisVal.getTime());
  }
	void getEnumValue(const Access * access, RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (thisVal.isNullRaw())
      value->assignNull();
    else
      value->assignEnum(thisVal.getEnum());
  }
	void getBinaryValue(const Access * access, RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (thisVal.isNullRaw())
      value->assignNull();
    else
      value->assignBinary(thisVal.getBinaryPtr(), thisVal.getBinaryPtr()+16);
  }
	void setLongValue(const Access * access, const RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (value->isNullRaw())
      thisVal.assignNull();
    else
      thisVal.assignLong(value->getLong());   
  }
	void setLongLongValue(const Access * access, const RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (value->isNullRaw())
      thisVal.assignNull();
    else
      thisVal.assignLongLong(value->getLongLong());
  }
	void setDoubleValue(const Access * access, const RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (value->isNullRaw())
      thisVal.assignNull();
    else
      thisVal.assignDouble(value->getDouble());
  }
	void setDecimalValue(const Access * access, const RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (value->isNullRaw())
      thisVal.assignNull();
    else
      thisVal.assignDec(value->getDecPtr());
  }
	void setStringValue(const Access * access, const RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (value->isNullRaw())
      thisVal.assignNull();
    else
      thisVal.assignString(value->getStringPtr());
  }
	void setWStringValue(const Access * access, const RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (value->isNullRaw())
      thisVal.assignNull();
    else
      thisVal.assignWString(value->getWStringPtr());
  }
	void setBooleanValue(const Access * access, const RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (value->isNullRaw())
      thisVal.assignNull();
    else
      thisVal.assignBool(value->getBool());
  }
	void setDatetimeValue(const Access * access, const RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (value->isNullRaw())
      thisVal.assignNull();
    else
      thisVal.assignDatetime(value->getDatetime());
  }
	void setTimeValue(const Access * access, const RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (value->isNullRaw())
      thisVal.assignNull();
    else
      thisVal.assignTime(value->getTime());
  }
	void setEnumValue(const Access * access, const RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (value->isNullRaw())
      thisVal.assignNull();
    else
      thisVal.assignEnum(value->getEnum());
  }
	void setBinaryValue(const Access * access, const RuntimeValue * value)
  {
    RuntimeValue& thisVal(mRuntimeEnv[reinterpret_cast<const MTOffsetAccess *>(access)->getAccess()]);
    if (value->isNullRaw())
      thisVal.assignNull();
    else
      thisVal.assignBinary(value->getBinaryPtr(), value->getBinaryPtr()+16);
  }

	ActivationRecord* getStaticLink() 
	{
		return mStaticLink;
	}
};


#endif
