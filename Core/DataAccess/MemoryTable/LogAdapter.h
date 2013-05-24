#ifndef __LOGADAPTER_H__
#define __LOGADAPTER_H__

#include <boost/shared_ptr.hpp>
#include "MTSQLInterpreter.h"

#ifdef WIN32
#include "NTLogger.h"
#include "loggerconfig.h"
// Adapter layer to get to uniform log interface (NTLogger & log4cxx Logger).

class MetraFlowLogger : public Logger
{
private:
  NTLogger mLogger;
public:
  MetraFlowLogger(const std::string& name)
  {
    LoggerConfigReader configReader;
    mLogger.Init(configReader.ReadConfiguration("logging"), name.c_str());
  }
  void logDebug(const std::string& str)
  {
    mLogger.LogThis(LOG_DEBUG, str.c_str());
  }

  void logInfo(const std::string& str)
  {
    mLogger.LogThis(LOG_INFO, str.c_str());
  }

  void logWarning(const std::string& str)
  {
    mLogger.LogThis(LOG_WARNING, str.c_str());
  }

  void logError(const std::string& str)
  {
    mLogger.LogThis(LOG_ERROR, str.c_str());
  }

  void logDebug(const std::wstring& str)
  {
    mLogger.LogThis(LOG_DEBUG, str.c_str());
  }

  void logInfo(const std::wstring& str)
  {
    mLogger.LogThis(LOG_INFO, str.c_str());
  }

  void logWarning(const std::wstring& str)
  {
    mLogger.LogThis(LOG_WARNING, str.c_str());
  }

  void logError(const std::wstring& str)
  {
    mLogger.LogThis(LOG_ERROR, str.c_str());
  }

  bool isOkToLogDebug()
  {
    return TRUE == mLogger.IsOkToLog(LOG_DEBUG);
  }

  bool isOkToLogInfo()
  {
    return TRUE == mLogger.IsOkToLog(LOG_INFO);
  }

  bool isOkToLogWarning()
  {
    return TRUE == mLogger.IsOkToLog(LOG_WARNING);
  }

  bool isOkToLogError()
  {
    return TRUE == mLogger.IsOkToLog(LOG_ERROR);
  }
};

typedef boost::shared_ptr<MetraFlowLogger> MetraFlowLoggerPtr;

class MetraFlowLoggerManager
{
public:
  static MetraFlowLoggerPtr GetLogger(const std::string& name)
  {
    return boost::shared_ptr<MetraFlowLogger>(new MetraFlowLogger(name));
  }
};

#else
#include "log4cxx/logger.h"

// Adapter layer to get to uniform log interface (NTLogger & log4cxx Logger).

class MetraFlowLogger : public Logger
{
private:
  log4cxx::LoggerPtr mLogger;
  
public:
  MetraFlowLogger(log4cxx::LoggerPtr logger)
    :
    mLogger(logger)
  {
  }
  void logDebug(const std::string& str)
  {
    LOG4CXX_DEBUG(mLogger, str.c_str());
  }

  void logInfo(const std::string& str)
  {
    LOG4CXX_INFO(mLogger, str.c_str());
  }

  void logWarning(const std::string& str)
  {
    LOG4CXX_WARN(mLogger, str.c_str());
  }

  void logError(const std::string& str)
  {
    LOG4CXX_ERROR(mLogger, str.c_str());
  }

  bool isOkToLogDebug()
  {
    return mLogger->isDebugEnabled();
  }

  bool isOkToLogInfo()
  {
    return mLogger->isInfoEnabled();
  }

  bool isOkToLogWarning()
  {
    return mLogger->isWarnEnabled();
  }

  bool isOkToLogError()
  {
    return mLogger->isErrorEnabled();
  }
  
};

typedef boost::shared_ptr<MetraFlowLogger> MetraFlowLoggerPtr;

class MetraFlowLoggerManager
{
public:
  static MetraFlowLoggerPtr GetLogger(const std::string& name)
  {
    return boost::shared_ptr<MetraFlowLogger>(new MetraFlowLogger(log4cxx::Logger::getLogger(name)));
  }
};

#endif

#endif
