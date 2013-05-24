/**************************************************************************
 * @doc GETOBJDIR
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
 * $Header$
 ***************************************************************************/


#include <windows.h>

#include <stdio.h>

int main(int argc, char * argv[])
{
	char dir[1024];

	if (argc < 2)
		GetCurrentDirectory(sizeof(dir), dir);
	else
		strcpy(dir, argv[1]);

	// get the directory part without ROOTDIR
	
	const char * rootdir = getenv("ROOTDIR");
	if (!rootdir || !*rootdir)
	{
		printf("ROOTDIR not set\n");
		return -1;
	}

	if (0 != _strnicmp(dir, rootdir, strlen(rootdir)))
	{
		printf("directory not prefixed by ROOTDIR\n");
		return -1;
	}

	const char * dirpart = dir + strlen(rootdir) + 1;
	dir[1] = '\0';

	const char * debug = getenv("DEBUG");
	if (debug == NULL || *debug == NULL)
		debug = "";

	// call nmake with any additional arguments at the end of the line
	char sysbuffer[1024];
	sprintf(sysbuffer,
					"nmake -nologo -f nt.mak DEBUG=%s MTOUTDIRDRIVE=%s MTCURRDIR=%s",
					debug, dir, dirpart);
	for (int i = 2; i < argc; i++)
	{
		strcat(sysbuffer, " ");
		strcat(sysbuffer, argv[i]);
	}

	return system(sysbuffer);
}
