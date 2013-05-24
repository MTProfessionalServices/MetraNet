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

#include <metra.h>
#include <NTEventArgs.h>

//
//	@mfunc
//	The default constructor. Initialize the data members by calling ClearArgs()
//  @rdesc 
//  No return value
// 
NTEventArgs::NTEventArgs()
{
  // initialize the data members ...
  ClearArgs() ;
}

//
//	@mfunc
//	Constructore with a numerical argument. Initializes the class by calling ClearArgs() then
//  adds the argument.
//	@parm The numerical argument
//  @parm The base of the argument
//  @rdesc 
//  No return value
// 
NTEventArgs::NTEventArgs(const DWORD aArg, const ArgBase aArgBase)
{
  // initialize the data members ...
  ClearArgs() ;

  // add the argument to the list ...
  Add (aArg, aArgBase) ;
}

//
//	@mfunc
//	Constructor with a string argument. Initializes the class by calling ClearArgs() then
//  adds the argument.
//	@parm The string argument
//  @rdesc 
//  No return value
// 
NTEventArgs::NTEventArgs(const char *apArg)
{
  // initialize the data members ...
  ClearArgs() ;
  
  // add the argument to the list ...
  Add (apArg) ;
}

//
//	@mfunc
//	Destructor.
//  @rdesc 
//  No return value
// 
NTEventArgs::~NTEventArgs()
{
  // call clear args
  ClearArgs() ;
}

//
//	@mfunc
//	Clear the argument list and number of arguments
//  @rdesc 
//  No return value
//  @devnote
//  Users of this class can allocate one NTEventArgs object and reuse it by calling this
//  function in between calls to log the data.
// 
void NTEventArgs::ClearArgs()
{
  // local variables ...
  DWORD i ;

  // reinitialize data members ...
  mCount = 0 ;
  for (i=0; i < MAX_ARGS ; i++)
  {
    mpArgs[i] = NULL ;
  }
}

//
//	@mfunc
//	Add the numerical value to the argument list
//	@parm The numerical value
//  @parm The base of the numerical value
//  @rdesc 
//  Returns TRUE if the argument was added. Otherwise, FALSE is returned.
// 
BOOL NTEventArgs::Add (const DWORD aArg, const ArgBase aArgBase)
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // if we havent reached the maximum number of arguments ... add it 
  if (mCount != MAX_ARGS)
  {
    // convert the number to a string ...
    _ultoa (aArg, mArgArray[mCount], aArgBase) ;
    
    // update mpArgs and mCount ...
    mpArgs[mCount] = mArgArray[mCount] ;
    mCount++ ;
  }
  else
  {
    bRetCode = FALSE ;
  }
  
  return bRetCode ;  
}

//
//	@mfunc
//	Add the string value to the argument list
//	@parm The string value
//  @rdesc 
//  Returns TRUE if the argument was added. Otherwise, FALSE is returned.
// 
BOOL NTEventArgs::Add (const char *apArg)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  DWORD nLength ;

  // if we havent reached the maximum number of arguments ... add it
  if (mCount != MAX_ARGS)
  {
    // make sure apArg is less than MAX_ARG_LENGTH ...
    nLength = strlen (apArg) ;
    if (nLength >= MAX_ARG_LENGTH)
    {
      bRetCode = FALSE ;
    }
    // otherwise ... copy the string into the appropriate arg ...
    else
    {
      strcpy (mArgArray[mCount], apArg) ;
      mpArgs[mCount] = mArgArray[mCount] ;
      mCount++ ;
    }
  }
  else
  {
    bRetCode = FALSE ;
  }

  return bRetCode ;  
}