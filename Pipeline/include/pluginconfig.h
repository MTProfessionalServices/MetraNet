/**************************************************************************
 * @doc PLUGINCONFIG
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | PLUGINCONFIG
 ***************************************************************************/

#ifndef _PLUGINCONFIG_H
#define _PLUGINCONFIG_H

#include <errobj.h>

#include <processor.h>

#include <string>

using std::wstring;

class PlugInInfoReader : public virtual ObjectWithError
{
public:
	BOOL ReadConfiguration(MTPipelineLib::IMTConfigPtr & arReader,
												 const char * apConfigDir,
												 const char * apStageName,
												 const char * apPlugInName,
												 PlugInConfig & arInfo);

	BOOL ReadConfiguration(MTPipelineLib::IMTConfigPtr & arReader,
												 const char * apFullName,
												 PlugInConfig & arInfo);

	BOOL GetFileName(const char * apConfigDir,
									 const char * apStageName,
									 const char * apPlugInName,
									 string & arStageConfig);

	BOOL ReadConfiguration(MTPipelineLib::IMTConfigPtr & arReader,
												 MTPipelineLib::IMTConfigPropSetPtr & arTop,
												 PlugInConfig & arInfo);

private:
	static BOOL PlugInInfoReader::AllWhiteSpace(wstring & arStr);
};



#endif /* _PLUGINCONFIG_H */
