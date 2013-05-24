/**************************************************************************
 * @doc LOGGERCONFIG
 * 
 * @module logger config class |
 *
 * This class is writes data out to the MetraTech file log.
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | LOGGERCONFIG
 ***************************************************************************/

#include <metralite.h>
#include <loggerconfig.h>
#include <NTLogServer.h>
#include <mtglobal_msg.h>

LoggerInfo * LoggerConfigReader::ReadConfiguration(const char * apConfigDir)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  LoggerInfo * pLogInfo = NULL;

	// get an instance to the log server ...
	NTLogServer *pLogServer = NTLogServer::GetInstance() ;
	if (pLogServer == NULL)
	{
		SetError (CORE_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
			"LoggerConfigReader::ReadConfiguration");
		return pLogInfo ;
	}

	// try to find the config path in the log server ...
	BOOL bFound = pLogServer->FindConfigInfo(apConfigDir, &pLogInfo) ;
	if (bFound) {
		pLogServer->ReleaseInstance();
		return pLogInfo;
	}

	pLogInfo = pLogServer->ReadConfiguration (apConfigDir);

	// release the instance we created
	pLogServer->ReleaseInstance();

  return pLogInfo;
}
