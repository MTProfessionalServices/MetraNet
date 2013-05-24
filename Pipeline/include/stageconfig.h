/**************************************************************************
 * @doc STAGECONFIG
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
 * @index | STAGECONFIG
 ***************************************************************************/

#ifndef _STAGECONFIG_H
#define _STAGECONFIG_H

#include <errobj.h>

#include <processor.h>

class StageInfo;

class StageInfoReader : public virtual ObjectWithError
{
public:
	BOOL ReadConfiguration(MTPipelineLib::IMTConfigPtr & arReader,
												 const char * apFilename, StageInfo & arInfo);

	BOOL ReadConfiguration(MTPipelineLib::IMTConfigPropSetPtr & arTop, StageInfo & arInfo);

	BOOL ReadDependencies(MTPipelineLib::IMTConfigPropSetPtr & arDependencies,
												StageInfo & arInfo);
};

#endif /* _STAGECONFIG_H */
