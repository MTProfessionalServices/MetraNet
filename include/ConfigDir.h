/****************************************************************************
**
**	FILENAME:		MTUtil.h
**
**	MODULE:			MTUtil
**
**	CREATED BY:		Derek Young, Raju Matta
**
**	MODIFIED BY:	
**
**	DATE CREATED:	24-Apr-1997
**
**	DESCRIPTION:
**
**	This class only has STATIC functions.  Do NOT instantiate, it 
**	will not work.
**
**	Misc Utility functions
**  - utilities to get and set environment variables
** 	- utilities to convert RWWString <--> ints/longs/doubles
**	- static wrappers around hash functions, needed by Rogue Dictionaries etc.
**
**	NOTES:
**	
**	The putEnv method should be used with care.  Most of the time, you 
**  don't want to change env. variables.
**	Some functions throw exceptions.  Look at the individual function specs.
**
**	Some of these functions and ideas were "stolen" and modified from 
**	the CTP AT&T project (dimitri).
**
****************************************************************************/

#if !defined _CONFIGDIR_H
#define _CONFIGDIR_H

// why??
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0500
#endif
#include <MTSL_DLL.h>

#include <string>

// STL methods
MTSL_DLL_EXPORT BOOL GetMTConfigDir(std::string & arConfigDir);
MTSL_DLL_EXPORT BOOL GetExtensionsDir(std::string & arExtensionsDir);
MTSL_DLL_EXPORT BOOL GetMTInstallDir(std::string & arInstallDir);
MTSL_DLL_EXPORT void SetNameSpace(std::string & arConfigDir);
MTSL_DLL_EXPORT bool IsMSIXCompressionEnabled();


#endif



