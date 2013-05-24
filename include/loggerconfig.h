/**************************************************************************
 * @doc LOGGERCONFIG
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
 * @index | LOGGERCONFIG
 ***************************************************************************/

#ifndef _LOGGERCONFIG_H
#define _LOGGERCONFIG_H

#include <errobj.h>
#include <loggerinfo.h>

#if defined(DEFINING_CONFIGREADERS) && !defined(DLL_EXPORT_READERS) 
#define DLL_EXPORT_READERS __declspec( dllexport )
#else
#define DLL_EXPORT_READERS //__declspec( dllimport )
#endif

class LoggerConfigReader : public virtual ObjectWithError
{
public:
	DLL_EXPORT_READERS LoggerInfo * ReadConfiguration(const char * apConfigDir);
};

#endif