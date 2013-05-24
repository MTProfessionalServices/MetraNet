/**************************************************************************
 * @doc
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
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 */


#include <metra.h>
#include <mtcom.h>
#include <installutil.h>
#include <LoggerEnums.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <SharedDefs.h>
#include <autoinstance.h>
#include <new>
#include <mtprogids.h>
#include <LoggerReaderWriter.h>


BOOL InstallLogger::Init()
{
  LoggerConfigReader cfgRdr;
  return NTLogger::Init(cfgRdr.ReadConfiguration("logging\\install"), INSTALL_TAG);
}

InstallLogger::~InstallLogger()
{
//  ::Sleep(5000);
}


// global logger object
MTAutoInstance<InstallLogger> g_Logger;

BOOL InstCallConvention LogInstallMsg(LPSTR Message,DWORD level)
{
  ASSERT((signed int)level > __LOG_TAG_BEGIN && level < __LOG_TAG_END);
  ASSERT(Message != NULL);

  g_Logger->LogThis((MTLogLevel)level,Message);
  Sleep(100);

	return TRUE;
}

// modify configuration files


/////////////////////////////////////////////////////////////////////////////
// Function name	: ModifyLogFiles
// Description	    : 
// Return type		: BOOL 
// Argument         : LPSTR ConfigTreeHome
// Argument         : LPSTR LogFileLocation
/////////////////////////////////////////////////////////////////////////////

BOOL InstCallConvention ModifyLogFile(LPSTR pFileName,
									 LPSTR LogFileLocation,
									 int aUserLogLevel)
{
	ASSERT(pFileName && LogFileLocation);
	if(!(pFileName && LogFileLocation)) return FALSE;
	BOOL bRetVal = FALSE;

	ComInitialize aInit;

	try {
		// open configfile
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

		MTLoggerReaderWriter aReaderWriter;
		aReaderWriter.Read(_bstr_t(pFileName));

		if(aUserLogLevel != LOG_OFF) {
			aReaderWriter.mLogLevel = (MTLogLevel)aUserLogLevel;
		}

		// muck with the file name
		string aStr = aReaderWriter.mFileName;
		aReaderWriter.mFileName  = LogFileLocation;
		if(aStr.find('\\')!= string::npos) {
			// Remove string up to the last '\\'
			aReaderWriter.mFileName += aStr.substr(0, aStr.find_last_of('\\')).c_str();
		}
		else {
			aReaderWriter.mFileName += DIR_SEP;
			aReaderWriter.mFileName += aStr.c_str();
		}

		aReaderWriter.mVersion = 2;
		aReaderWriter.Write(_bstr_t(pFileName));
		bRetVal = TRUE;
	}
	catch(_com_error e) {
	}
	catch(...) {
	}
	return bRetVal;

}





