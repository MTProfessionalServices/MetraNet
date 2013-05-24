/**************************************************************************
* Copyright 1997-2000 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: 
* $Header$
* 
***************************************************************************/
// Logger.cpp : Implementation of CLogger
#include "StdAfx.h"
#include "COMLogger.h"
#include "Logger.h"

#include <loggerconfig.h>

/////////////////////////////////////////////////////////////////////////////
// CLogger
CLogger::CLogger()
{
}

CLogger::~CLogger()
{
}

STDMETHODIMP CLogger::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ILogger,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     	Init
// Arguments:     apConfigPath - the relative configuration path to 
//                    the logging.xml file
//                apAppTag     - the tag that preceeds logged error messages
// Return Value:      
// Errors Raised: 
// Description:   The Init method initializes the Logger with the logging.xml file
//  in the specified relative configuration path and the application tag. If a 
//  logging.xml file is not present in the relative configuration path the default 
//  logging.xml file (in Logging) is used. The application tag is the tag that is
//  written at the beginning of the log messages in the MetraTech Log.
// ----------------------------------------------------------------
STDMETHODIMP CLogger::Init(BSTR apConfigPath, BSTR apAppTag)
{
  _bstr_t ConfigPath, AppTag ;
  BOOL bRetCode ;
  HRESULT nRetVal=S_OK ;

  // copy the parameters ...
  ConfigPath = apConfigPath ;
  AppTag = apAppTag ;

  // initialize the logger ...
  LoggerConfigReader cfgRdr ;
	bRetCode = mLogger.Init (cfgRdr.ReadConfiguration(ConfigPath), (char*) AppTag) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pErrorObject = mLogger.GetLastError() ;
    nRetVal = pErrorObject->GetCode() ;
  }

	return HRESULT_FROM_WIN32(nRetVal);
}

// ----------------------------------------------------------------
// Name:     	LogThis
// Arguments:     aLogLevel - the log level to log the message at
//                apData    - the data to be logged
// Return Value:  
// Errors Raised: 
// Description:   The LogThis method logs the specified message to the
//  MetraTech log file if the log level is set to the appropriate level. 
// ----------------------------------------------------------------
STDMETHODIMP CLogger::LogThis(MTLogLevel aLogLevel, BSTR apData)
{
  BOOL bRetCode ;
  HRESULT nRetVal=S_OK ;

  // call the logger ...
  bRetCode = mLogger.LogThis (aLogLevel, apData) ;
  if (bRetCode == FALSE)
  {
    const ErrorObject *pErrorObject = mLogger.GetLastError() ;
    nRetVal = pErrorObject->GetCode() ;
  }

	return HRESULT_FROM_WIN32(nRetVal);
}

// ----------------------------------------------------------------
// Name:     	LogEvent
// Arguments:     apData - the data to log to the Windows NT event log
// Return Value:  
// Errors Raised: 
// Description:   The LogEvent method logs the specified message to the
//  Windows NT event log.
// ----------------------------------------------------------------
STDMETHODIMP CLogger::LogEvent (BSTR apData)
{
	BOOL bRetCode ;
  HRESULT nRetVal=S_OK ;
  _bstr_t logData ;

  // call the logger ...
  logData = apData ;
  bRetCode = mLogger.LogEvent (NTEventMsg::EVENT_INFO, (char*)logData) ;
	if (bRetCode == FALSE)
  {
    const ErrorObject *pErrorObject = mLogger.GetLastError() ;
    nRetVal = pErrorObject->GetCode() ;
  }

	return HRESULT_FROM_WIN32(nRetVal);
}
