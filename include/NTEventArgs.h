/**************************************************************************
 * @doc NTEVENTARGS
 * 
 * @module Windows NT event arguments encapsulation |
 * 
 * This class encapsulates the substitution strings that are used in some
 * Windows NT events and errors.
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | NTEVENTARGS
 ***************************************************************************/

#ifndef __NTEVENTARGS_H
#define __NTEVENTARGS_H

#include <MTUtil.h>

// @class NTEventArgs
class NTEventArgs
{
// @access Public:
public:
  // @cmember,menum The maximum number of arguments and argument length
  enum 
  { 
    // @@emem The maximum number of arguments
    MAX_ARGS=10, 
    // @@emem The maximum argument length
    MAX_ARG_LENGTH=80
  } ;
  // @cmember,menum The base of the numerical argument
  enum ArgBase 
  {
    // @@emem Base 2
    BINARY=2, 
    // @@emem Base 8
    OCTAL=8, 
    // @@emem Base 10
    DECIMAL=10, 
    // @@emem Base 16
    HEX=16
  } ;
  // @cmember Constructor
  DLL_EXPORT NTEventArgs() ;
  // @cmember Constructor with numerical argument
  DLL_EXPORT NTEventArgs(const DWORD aArg, const ArgBase aArgBase=DECIMAL) ;
  // @cmember Constructor with string argument
  DLL_EXPORT NTEventArgs(const char *apArg) ;
  // @cmember Destructor
  DLL_EXPORT ~NTEventArgs() ;

  // @cmember Clear the arguments.
  void ClearArgs() ;
  // @cmember Add a numerical argument
  BOOL Add (const DWORD aArg, const ArgBase aArgBase=DECIMAL) ;
  // @cmember Add a string argument
  BOOL Add (const char *apArg) ;
  // @cmember Get the argument list
  char ** GetArgList() ;
  // @cmember Get the number of arguments
  WORD GetNumArgs() const ;
// @access Private:
private:
  // @cmember The number of arguments
  WORD      mCount ;
  // @cmember An array of pointers to the arguments
  char *  mpArgs[MAX_ARGS] ;
  // @cmember The argument array
  char    mArgArray[MAX_ARGS][MAX_ARG_LENGTH] ;
} ;

//
//	@mfunc
//	Get the argument list
//  @rdesc 
//  Returns the argument list.
// 
inline char **NTEventArgs::GetArgList()  
{
  return mpArgs ;
}

//
//	@mfunc
//	Get the number of arguments
//  @rdesc 
//  Returns the number of arguments
// 
inline WORD NTEventArgs::GetNumArgs() const
{
  return mCount ;
}

#endif // __NTEVENTARGS_H
