/**************************************************************************
 * @doc ERROBJ
 *
 * @module Error object |
 *
 * Hold error codes and lookup error strings.
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
 *
 * @index | ERROBJ
 ***************************************************************************/

#ifndef _MTFUTIL_H
#define _MTFUTIL_H

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef UNIX
#include <sys/types.h>
#include <dirent.h>

#include <metraunix.h>

typedef DIR* MTDIR;
#define MTDIR_FAILURE NULL

#endif

#ifdef WIN32

#include <windows.h>

typedef HANDLE MTDIR;
#define MTDIR_FAILURE INVALID_HANDLE_VALUE
void cf_slash_bash(char *path);

#endif

#define MTFILE_PATHSIZE 256

BOOL MTFileExists(char *path);

int MTFileSize(char *path);

MTDIR MTFileOpenDir(char *path, char *first);
int MTFileReadDir(MTDIR mtdir, char *path);
void MTFileCloseDir(MTDIR mtdir);

int MTFileExists(char *path);
int MTFileCopy(char *src, char *dst, int perm);
void MTFileDelete(char *path);

void MTFileMakeDir(char *path);
void MTFileRemoveDir(char *path);

#ifdef __cplusplus
}
#endif

#endif // _MTFUTIL_H

