/**************************************************************************
 * @doc NTFUTIL
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
 * Created by: billo
 * $Header$
 ***************************************************************************/

#undef UNICODE  // FIXME - sorry.
#undef _UNICODE  // FIXME - sorry.

#include <mtfutil.h>
#include <assert.h>
#include <stdio.h>
#include <errno.h>
#include <direct.h>
#include <fcntl.h>
#include <sys/stat.h>


BOOL MTFileExists(char *path)
{
    DWORD attrs;

    attrs = GetFileAttributes(path);

    if (attrs == 0xffffffff)
    {
	DWORD 	error = GetLastError();
	DWORD	retval;
	char	msg[256];
	
	retval = FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 
			       NULL, error, 0, 
			       msg, 256, NULL);
	return FALSE;
    } else {
	return TRUE;
    }
}

void MTFileDelete(char *path)
{
    DeleteFile(path);
}

int MTFileCopy(char *src, char *dst, int perm)
{
    BOOL	result;
    
    assert((src != NULL && dst != NULL));

    result = CopyFile(src, dst, FALSE);

    return (int)result;
}

int MTFileSize(char *path)
{
    struct _stat 	statbuf;
    int 		result;

    result = _stat(path, &statbuf );
    if( result != 0 )
    {
	return -1;
    } else {
	return statbuf.st_size;
    }
}

MTDIR MTFileOpenDir(char *path, char *first)
{
    char 		dirspec[MTFILE_PATHSIZE];
    MTDIR		result;
    WIN32_FIND_DATA	find_data;

    sprintf(dirspec, "%s/*", path);

    result = FindFirstFile(dirspec, &find_data);

    if (result == MTDIR_FAILURE)
    {
	*first = 0x00;
	return result;
    }

    strcpy(first, find_data.cFileName);
    return result;
}

void MTFileCloseDir(MTDIR mtdir)
{
    FindClose(mtdir);
}

int MTFileReadDir(MTDIR mtdir, char *path)
{
    WIN32_FIND_DATA	find_data;

    if (FindNextFile(mtdir, &find_data))
    {
	strcpy(path, find_data.cFileName);
	return (strlen(path));
    } else {
	*path = 0x00;
	return 0;
    }
}
    
void MTFileMakeDir(char *path)
{
    CreateDirectory(path, NULL);
}

void MTFileRemoveDir(char *path)
{
    char 		dirspec[MTFILE_PATHSIZE];
    MTDIR		mtdir;
    WIN32_FIND_DATA	find_data;
    char 		filespec[MTFILE_PATHSIZE];
    char 		target[MTFILE_PATHSIZE];
    int			done_with_files = 0;

    sprintf(dirspec, "%s/*", path);

    mtdir = FindFirstFile(dirspec, &find_data);

    if (mtdir == MTDIR_FAILURE)
    {
	done_with_files = 1;
    }

    while (!done_with_files)
    {
	strcpy(filespec, find_data.cFileName);

	if (strcmp(filespec, ".") && 
	    strcmp(filespec, ".."))
	{
	    sprintf(target, "%s\\%s", path, filespec);
	    DeleteFile(target);
	}
	    
	if (!FindNextFile(mtdir, &find_data))
	{
	    done_with_files = 1;
	}
    }
    FindClose(mtdir);

    if (rmdir (path) < 0)
    {
	fprintf(stderr, "rmdir error: %d", errno);
    }
}


