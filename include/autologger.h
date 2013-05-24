/**************************************************************************
 *
 * Copyright 1997-2000 by MetraTech Corporation
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
 * $Header$
 ***************************************************************************/

#ifndef __AUTOLOGGER_H__
#define __AUTOLOGGER_H__
#pragma once

#include <NTLogger.h>
#include <autoinstance.h>
#include <loggerconfig.h>

template <char* pLogMsg,char* pLogDir = pLogMsg>
class MTAutoLoggerImpl : public NTLogger {
public:
  BOOL Init();
};

template <char* pLogMsg,char* pLogDir> BOOL MTAutoLoggerImpl<pLogMsg,pLogDir>::Init()
{
  LoggerConfigReader cfgRdr;
	char buff[1024];
	sprintf(buff,"[%s]",pLogMsg);
  return NTLogger::Init(cfgRdr.ReadConfiguration(pLogDir), buff);
}

#endif //__AUTOLOGGER_H__