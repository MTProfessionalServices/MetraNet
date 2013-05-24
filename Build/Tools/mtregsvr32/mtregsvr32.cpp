/**************************************************************************
 * MTREGSVR32
 *
 * Copyright 1997-2002 by MetraTech Corp.
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

#include <stdio.h>
#include <stdlib.h>
#include <direct.h>

ComInitialize gComInit;

void Usage(const char * progname)
{
	printf("usage: %s [-d] mydll.dll\n", progname);
	printf("  -d - debug DLL load problems\n");
}


int main(int argc, char * argv[])
{
	bool suppressPopup = true;
	const char * dllname = argv[1];

	if (argc == 3)
	{
		if (0 == strcmp(argv[1], "-d"))
		{
			suppressPopup = false;
			dllname = argv[2];
		}
		else if (0 == strcmp(argv[2], "-d"))
		{
			suppressPopup = false;
			dllname = argv[1];
		}
		else
		{
			Usage(argv[0]);
			return 1;
		}
	}
	else if (argc == 2)
	{
		dllname = argv[1];
	}
	else
	{
		Usage(argv[0]);
		return 1;
	}

	char workingDir[_MAX_PATH];
	if (!_getcwd(workingDir, sizeof(workingDir)))
	{
		fprintf(stderr, "%s: Unable to get current working directory\n", argv[0]);
		return -1;
	}

  char path_buffer[_MAX_PATH];
	char drive[_MAX_DRIVE];
	char dir[_MAX_DIR];
	char fname[_MAX_FNAME];
	char ext[_MAX_EXT];

	_fullpath(path_buffer, dllname, sizeof(path_buffer));
	_splitpath(path_buffer, drive, dir, fname, ext);

	char dllPath[_MAX_PATH];
	sprintf(dllPath, "%s%s", drive, dir);

	// remove the tailing backslash
	dllPath[strlen(dllPath) - 1] = '\0';

	if (_chdir(dllPath) != 0)
	{
		fprintf(stderr, "%s: Unable to set working directory to %s\n", argv[0], dllPath);
		return -1;
	}

	// this suppresses the error popup that would normally occur if
	// LoadLibary fails to load implicit errors
	if (suppressPopup)
		SetErrorMode(SEM_FAILCRITICALERRORS);

	HINSTANCE hLib = LoadLibrary(dllname);

	if (hLib < (HINSTANCE)HINSTANCE_ERROR)
	{
		fprintf(stderr, "%s: Unable to load DLL: %x\n", argv[0], GetLastError());
		return -1;
	}

	// Find the entry point.
	FARPROC lpDllEntryPoint;
	lpDllEntryPoint = GetProcAddress(hLib, "DllRegisterServer");

	int returnValue = -1;
	if (lpDllEntryPoint != NULL)
	{
		HRESULT hr = (*lpDllEntryPoint)();
		if (FAILED(hr))
		{
			fprintf(stderr, "%s: Unable to register server: %x\n", argv[0], hr);
			returnValue = -1;
		}
		else
		{
			printf("%s: registration successful.\n", argv[0]);
			returnValue = 0;
		}
	}
	else
	{
		DWORD err = GetLastError();
		if (err == ERROR_PROC_NOT_FOUND)
		{
			// Unable to locate entry point
			printf("%s: DLL does not contain any COM classes: OK.\n", argv[0]);
			returnValue = 0;
		}
		else
		{
			// some other error - could be bad
			fprintf(stderr, "%s: GetProcAddress failed: %d\n", argv[0], err);
			returnValue = -1;
		}
	}

	if (_chdir(workingDir) != 0)
	{
		fprintf(stderr, "%s: Unable to set working directory back to %s\n", argv[0], workingDir);
		returnValue = -1;
	}

	return returnValue;
}


