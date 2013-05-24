#ifndef __ADAPTERLOGGING_H__
#define __ADAPTERLOGGING_H__
#pragma once

#include <NTLogger.h>
#include <loggerconfig.h>

template <char* pLoggingName>
class MTSkeletonLogger {

public:

MTSkeletonLogger() {
	LoggerConfigReader configReader;
  _bstr_t aProgId("adapter");
	_bstr_t aLoggingName = "[" + _bstr_t(pLoggingName) + "]";
  mLogger.Init(configReader.ReadConfiguration(aProgId),aLoggingName);
}

protected:
	NTLogger mLogger;
};


#endif //__ADAPTERLOGGING_H__
