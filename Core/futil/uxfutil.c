/**************************************************************************
 * @doc UXFUTIL
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

////////////////////
// mef: override time and size definitions
#define USE_TIME
#define USE_SIZE
#include "unix_hacks.h"
// mef: override time and size definitions
////////////////////


#include "mtfutil.h"
#include <stdio.h>
#include <sys/errno.h>
#undef EDOM
#undef ERANGE
#undef EILSEQ
#include <errno.h>
#include <fcntl.h>


BOOL MTFileExists(char *path)
{
    int fd;

    fd = open(path, O_RDONLY);

    if (fd > 0) 
    {
	close(fd);
	return TRUE;
    } else {
	if (errno == ENOENT) 
	    return FALSE;
	else if (errno == EACCES)
	    return FALSE;
	else
	    return FALSE;
    }
}

void MTFileDelete(char *path)
{
    unlink(path);
}

int MTFileCopy(char *src, char *dst, int perm)
{
    int         fd1, fd2, n, wrote;
    int		total = 0;
    char        buf[4096];
    
    assert((src != NULL && dst != NULL));

    if ((fd1 = open(src, O_RDONLY)) < 0)
      return FALSE;
    if ((fd2 = open(dst, O_WRONLY | O_CREAT, perm)) < 0)
    {
        close (fd1);
        return 0;
    }

    while ((n = read(fd1, buf, 4096)) > 0)
    {
        if ((wrote = write(fd2, buf, n)) != n)
        {
            total += wrote;
            close(fd1);
            close(fd2);
            return total;;
        }
        total += wrote;
    }
    close(fd1);
    close(fd2);
    return total;
}


MTDIR MTFileOpenDir(char *path, char *first)
{       
    MTDIR result = opendir((const char *)path);

    /* this wierdness is so that NT and unix 
       can use the same semantics; opening a dir 
       also returns the first file entry. */
    if (result != NULL)
    {
        MTFileReadDir(result, first);
    }
    return result;
}

void MTFileCloseDir(MTDIR mtdir)
{
    closedir((DIR *)mtdir);
}

int MTFileReadDir(MTDIR mtdir, char *path)
{
    struct dirent *entry;
    
    entry = readdir((DIR *)mtdir);

    if (entry == NULL) 
    {
        *path = 0x00;
        return 0;
    } else {
        strcpy(path, entry->d_name);
        return strlen(path);
    }
}
    
void MTFileMakeDir(char *path)
{
    mkdir(path, 0777);
}

void MTFileRemoveDir(char *path)
{
    rmdir (path);
}


