// MTLog.cpp : Implementation of CMTLog
#include "StdAfx.h"
#include "SysContext.h"

#include "MTLogDef.h"

#include <stdio.h>

#include <comutil.h>
#include <mtcomerr.h>
#include <loggerconfig.h>
#include <mtglobal_msg.h>

/////////////////////////////////////////////////////////////////////////////
// CMTLog

STDMETHODIMP CMTLog::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTLog,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

BOOL CMTLog::MTFromPlugInLogLevel(PlugInLogLevel aLevel, MTLogLevel & arMTLevel)
{
	switch (aLevel)
	{
	case PLUGIN_LOG_OFF:
		arMTLevel = LOG_OFF;
		break;
	case PLUGIN_LOG_FATAL:
		arMTLevel = LOG_FATAL;
		break;
	case PLUGIN_LOG_ERROR:
		arMTLevel = LOG_ERROR;
		break;
	case PLUGIN_LOG_WARNING:
		arMTLevel = LOG_WARNING;
		break;
	case PLUGIN_LOG_INFO:
		arMTLevel = LOG_INFO;
		break;
	case PLUGIN_LOG_DEBUG:
		arMTLevel = LOG_DEBUG;
		break;
	case PLUGIN_LOG_TRACE:
		arMTLevel = LOG_TRACE;
		break;
	default:
		return FALSE;
	};
	return TRUE;
}

// ----------------------------------------------------------------
// Description: Initialize the logging object.
// Arguments: configPath - Path to configuration file.
//            appTag - Tag written out with each string
// ----------------------------------------------------------------
STDMETHODIMP CMTLog::Init(BSTR aConfigPath, BSTR aAppTag)
{
	_bstr_t configPath(aConfigPath);
	_bstr_t appTag(aAppTag);

	LoggerConfigReader configReader;
	try
	{
		if (!mLogger.Init(configReader.ReadConfiguration(configPath), appTag))
		{
			DWORD err = mLogger.GetLastError()->GetCode();
			HRESULT hr = HRESULT_FROM_WIN32(err);
			MT_THROW_COM_ERROR (hr);
		}
		else
			return S_OK;
	}
	catch(_com_error& e)
	{
		return (ReturnComError(e));
	}


}



// ----------------------------------------------------------------
// Description: log a string to a system defined log, using the given
//              log level
// Arguments: level - Level at which to log the string.
//            string - String to log.
// ----------------------------------------------------------------
STDMETHODIMP CMTLog::LogString(PlugInLogLevel aLevel, BSTR aString)
{
	_bstr_t bstr(aString);

	MTLogLevel level;
	if (!MTFromPlugInLogLevel(aLevel, level))
		return Error("Invalid log level");

	// TODO: should this log wide characters?
	const char * logstring = bstr;
	if (!logstring)
		return S_FALSE;							// TODO: what should be done in this case?

	if (!mLogger.LogThis(level, logstring))
		return S_FALSE;							// they can detect this if they need to
	return S_OK;
}

// ----------------------------------------------------------------
// Description: return TRUE if a message logged at the given level would
//              be entered into the log or not
// Arguments: level - Level at which a string would be logged.
// Return Value: True if a string logged at this level would be written to the log.
// ----------------------------------------------------------------
STDMETHODIMP CMTLog::OKToLog(PlugInLogLevel aLevel, VARIANT_BOOL * apWouldLog)
{
	MTLogLevel level;
	if (!MTFromPlugInLogLevel(aLevel, level))
		return Error("Invalid log level");

	*apWouldLog = (mLogger.IsOkToLog(level)) ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP CMTLog::get_ApplicationTag(BSTR *pVal)
{
	*pVal = bstr_t(mLogger.GetApplicationTag()).copy();

	return S_OK;
}

STDMETHODIMP CMTLog::put_ApplicationTag(BSTR newVal)
{
	mLogger.SetApplicationTag(bstr_t(newVal));

	return S_OK;
}
