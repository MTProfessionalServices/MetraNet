/**************************************************************************
 * @doc ZIP
 *
 * Copyright 1999 by MetraTech Corporation
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
 ***************************************************************************/

#include <metra.h>
#include <zipdir.h>

#include <process.h>
#include <direct.h>

#include <mtglobal_msg.h>
#include <AutoChangeDir.h>

BOOL ZipUtils::ZipDirectory(const char * apDirName, const char * apZipFile)
{
	const char * functionName = "ZipUtils::ZipDirectory";

	char buffer[256];

  // auto change dir changes to the new dir then back to the old
  AutoChangeDir aAutoChangeDir(apDirName);

	sprintf(buffer, "zip -rq %s .", apZipFile);

	int retVal = system(buffer);

	if (retVal != 0)
	{
		SetError(CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}

BOOL ZipUtils::UnzipDirectory(const char * apDirName, const char * apZipFile)
{
	const char * functionName = "ZipUtils::UnzipDirectory";

	char buffer[256];

	char cwd[MAX_PATH];
	_getcwd(cwd, sizeof(cwd));

	// set working directory
	_chdir(apDirName);

	sprintf(buffer, "unzip -qo %s", apZipFile);

	int retVal = system(buffer);

	_chdir(cwd);

	if (retVal != 0)
	{
		SetError(CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	return TRUE;
}


BOOL ZipUtils::AddOneFileToZip(const char * apDirName, 
															 const char * apZipFile, 
															 const char * apFileName)
{
	const char * functionName = "ZipUtils::AddOneFileToZip";

	char buffer[512];

  // auto change dir changes to the new dir then back to the old
  AutoChangeDir aAutoChangeDir(apDirName);

	sprintf(buffer, "zip -rq %s . -i %s", apZipFile, apFileName);

	int retVal = system(buffer);

	if (retVal != 0)
	{
		SetError(CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}



	return TRUE;
}