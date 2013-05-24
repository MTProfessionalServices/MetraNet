/**************************************************************************
 * @doc LOGGERINFO
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | LOGGERINFO
 ***************************************************************************/

#ifndef _LOGGERINFO_H
#define _LOGGERINFO_H

#include <comdef.h>
#include <LoggerEnums.h>
class NTLogFile;

class LoggerInfo
{
public:
  LoggerInfo() {} ;
  ~LoggerInfo() {} ;

	
	LoggerInfo(const LoggerInfo& aIn)
	{
		mLogLevel = aIn.mLogLevel;
		mFilename = aIn.mFilename;

    mLogSocketLevel = aIn.mLogSocketLevel;
    mLogSocketPort = aIn.mLogSocketPort;
    mLogSocketServerName = aIn.mLogSocketServerName;
    mLogSocketConnectionType = aIn.mLogSocketConnectionType;
    mLogSocketFacility = aIn.mLogSocketFacility;
    mLogSocketTag = aIn.mLogSocketTag;

		mConfigPath = aIn.mConfigPath;
		mLogRolloverAge= aIn.mLogRolloverAge;
		mLogCircularBufferSize = aIn.mLogCircularBufferSize;
		mLogFilterLevel = aIn.mLogFilterLevel;
		mLogFilterTag = aIn.mLogFilterTag;
	}
	


  void SetLogSocketPort(const DWORD arLogSocketPort) 
    { mLogSocketPort = arLogSocketPort; }
  void SetLogSocketServer(const char *apServerName) 
    { mLogSocketServerName = apServerName;  }
  void SetLogSocketConnectionType(const char *apConnectionType) 
    { mLogSocketConnectionType = apConnectionType;  }
  void SetLogSocketFacility(const DWORD arLogSocketFacility) 
    {
      if (arLogSocketFacility>23)
        mLogSocketFacility=0;
      else
        mLogSocketFacility = arLogSocketFacility;
    }
  void SetLogSocketTag(const char *apLogSocketTag) 
    {
      if (strlen(apLogSocketTag)<=32)
      {
        mLogSocketTag = apLogSocketTag;
      }
      else
      {
		char buffer[33];
		strncpy_s(buffer, sizeof(buffer), apLogSocketTag, _TRUNCATE); 
        mLogSocketTag=buffer;
      }
    }
  void SetLogRolloverAge(const DWORD arLogRolloverAge) 
    { mLogRolloverAge = arLogRolloverAge; }

  void SetLogCircularBufferSize(const DWORD aLogCircularBufferSize) 
    { mLogCircularBufferSize = aLogCircularBufferSize; }

  void SetLogFilterLevel(const MTLogLevel arLogFilterLevel) 
    { mLogFilterLevel = arLogFilterLevel; }
  void SetLogLevel(const MTLogLevel arLogLevel) 
    { mLogLevel = arLogLevel; }
  void SetLogSocketLevel(const MTLogLevel arLogSocketLevel) 
    { mLogSocketLevel = arLogSocketLevel; }
  void SetLogFilterTag(const char * arLogFilterTag) 
    {
      mLogFilterTag = arLogFilterTag; 
    }
  void SetFilename (const char *apFilename)
    {
      mFilename = apFilename; 
    }
  void SetConfigPath (const char *apConfigPath)
    {
	  mConfigPath = apConfigPath; 
	}
  MTLogLevel GetLogLevel() const 
    {return mLogLevel ;}
  MTLogLevel GetLogSocketLevel() const 
    {return mLogSocketLevel ;}
  _bstr_t GetFilename() const 
    {return mFilename;}
  _bstr_t GetConfigPath() const 
    {return mConfigPath;}
  DWORD GetLogSocketPort() const 
    {return mLogSocketPort ; }
  _bstr_t GetLogSocketServer() const 
    {return mLogSocketServerName;}
  _bstr_t GetLogSocketConnectionType() const 
    {return mLogSocketConnectionType;}
  DWORD GetLogSocketFacility() const 
    {return mLogSocketFacility ; }
  _bstr_t GetLogSocketTag() const 
    {return mLogSocketTag;}

  DWORD GetLogRolloverAge() const 
    {return mLogRolloverAge ; }
  DWORD GetLogCircularBufferSize() const 
    {return  mLogCircularBufferSize;}
  MTLogLevel GetLogFilterLevel() const 
    {return mLogFilterLevel ; }
  _bstr_t GetLogFilterTag() const
    {return mLogFilterTag ;   }
private:
  MTLogLevel    mLogLevel ;
  _bstr_t     mFilename ;
  _bstr_t     mConfigPath ;

  MTLogLevel    mLogSocketLevel ; 
  DWORD mLogSocketPort; // port for syslog remote logging
  _bstr_t     mLogSocketServerName;
  _bstr_t     mLogSocketConnectionType;
  DWORD mLogSocketFacility;
  _bstr_t mLogSocketTag;

  DWORD mLogRolloverAge;  // number of days to log to file before rolling over
	DWORD mLogCircularBufferSize; // the number of messages in the circular buffer
  MTLogLevel mLogFilterLevel; // log level that will trigger messages to be flushed from buffer
  _bstr_t mLogFilterTag;  // application tag that triggers a flush
} ;

#endif
