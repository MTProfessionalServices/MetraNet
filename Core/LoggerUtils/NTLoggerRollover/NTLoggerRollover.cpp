/**************************************************************************
 * @doc 
 * 
 * @module 
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
 * @index | 
 ***************************************************************************/


// ----------------------------------------------------------------
// Name:        ntloggerrollover
// Usage:       ntloggerrollover
// Arguments:   N/A
// Description: Forces a rollover of the log file. Rollover is done
//              by creating a new file, moving the log file contents,
//              and truncating the log file.
// ----------------------------------------------------------------

#include <mtcom.h>
#include <objbase.h>
#include <metra.h>
#include <stdio.h>
#include <NTLogger.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <NTLogMacros.h>

ComInitialize gComInit;

int main(int argc, char *argv[])
{
  NTLogger myLogger ;
  LoggerConfigReader cfgRdr ;
  BOOL bRetCode=FALSE ;

	if (argc != 2)
	{
		printf("Usage: %s <directory>\n\n", argv[0]);
		printf("directory is relative to the config directory\n");
		printf("for example: \"%s logging\" rolls over the main log file\n",
					 argv[0]);
		return 1;
	}

	const char * dir = argv[1];
  bRetCode = myLogger.Init(cfgRdr.ReadConfiguration(dir), "[rollover]") ;
	if (!bRetCode)
	{
		printf("Unable to initialize logger for directory %s\n", dir);
		return -1;
	}

  bRetCode = myLogger.Rollover () ;
	if (!bRetCode)
	{
		printf("Unable to rollover log file\n", dir);
		return -1;
	}

  return 0 ;
}

