/**************************************************************************
 * @doc EXPANDFILELIST
 *
 * Copyright 2000 by MetraTech Corporation
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
#include <expandfilelist.h>

using namespace std;

void ExpandFileList(list<string> & arFilenames, const char * apWildcards)
{
	WIN32_FIND_DATAA fileData;

	HANDLE hFile = FindFirstFileA(apWildcards, &fileData); // ascii version
	if (hFile == INVALID_HANDLE_VALUE)
	{
		FindClose(hFile);
		return;
	}

	char drive[_MAX_DRIVE];
	char dir[_MAX_DIR];
	char fname[_MAX_FNAME];
	char ext[_MAX_EXT];

	_splitpath(apWildcards, drive, dir, fname, ext);
   
	string base(drive);
	base += dir;

	// use while loop to get all the files
	while (TRUE)
	{
		string name = base + fileData.cFileName;
		arFilenames.push_back(name);

		// get next file
		if (!FindNextFileA(hFile, &fileData))
			break;
	}

	FindClose(hFile);
}

