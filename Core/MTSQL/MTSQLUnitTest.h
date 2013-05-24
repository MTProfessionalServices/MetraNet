#ifndef __MTSQLUNITTEST_H__
#define __MTSQLUNITTEST_H__

#include "MTSQLConfig.h"
#include "MTSQLInterpreter.h"
#include "RuntimeValue.h"
#include <string>
#include <iostream>
#include <vector>
#include <map>

class StdioLogger : public Logger
{
public:
	bool isOkToLogError()
	{
		return true;
	}
	bool isOkToLogWarning()
	{
		return true;
	}
	bool isOkToLogInfo()
	{
		return true;
	}
	bool isOkToLogDebug()
	{
		return true;
	}
	void logError(const std::string& s)
  {
    std::cerr << s.c_str() << std::endl;
  }
	void logWarning(const std::string& s)
  {
    std::cout << s.c_str() << std::endl;
  }
	void logInfo(const std::string& s)
  {
    std::cout << s.c_str() << std::endl;
  }
	void logDebug(const std::string& s)
  {
    std::cout << s.c_str() << std::endl;
  }
};

class MTFrame;

class MTOffsetAccess : public Access
{
	friend class MTFrame;

private:
	std::vector<RuntimeValue>::size_type mAccess;
	MTOffsetAccess(std::vector<RuntimeValue>::size_type access) : mAccess(access) {}
public:

	std::vector<RuntimeValue>::size_type getAccess() const 
	{
		return mAccess;
	}
};

class MTFrame : public Frame
{
private:
	int mLastOffset;
	std::map<std::vector<RuntimeValue>::size_type, AccessPtr> mMap;
public:
	MTFrame() : mLastOffset(0)
	{
	}

	AccessPtr getVariable(int access)
	{
		AccessPtr mtAccess=mMap[access];
		if (mtAccess == nullAccess)
		{
			mtAccess = AccessPtr(new MTOffsetAccess(access));
			mMap[access] = mtAccess;
		}
		return mtAccess;
	}

	AccessPtr allocateVariable(const std::string& var, int )
	{
		return getVariable(mLastOffset++);
	}

	AccessPtr getAccess(std::vector<RuntimeValue>::size_type i)
	{
		return mMap[i];
	}

	~MTFrame() 
	{
	}
};

class MTSQLUnitTest
{
public:
  MTSQL_DECL static bool ParseProgram(const std::string& str);
	MTSQL_DECL static void AnalyzeProgram(const std::string& str, std::vector<MTSQLParam>& params);
};

#endif
