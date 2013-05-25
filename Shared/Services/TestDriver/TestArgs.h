/**************************************************************************
 * @doc 
 * 
 * @module  Test class that abstracts a session thread |
 * 
 * This class is used to test an individual session.
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
 * Modified by: Raju Matta
 * $Header$
 *
 * @index | 
 ***************************************************************************/

#ifndef _TESTARGS_H_
#define _TESTARGS_H_

#include <wtypes.h>
#include <tchar.h>
#include <string>

// Defines for test names, thread modes, etc 
#define SERVICES_TEST       L"svc"
#define SINGLE_THREAD_MODE  L"single"
#define MULTI_THREAD_MODE   L"multi"

class TestArgs
{
	public:
  		TestArgs() ;
  		virtual ~TestArgs() ;

  		BOOL ParseArgs (int argc, _TCHAR * argv[]) ;
  		void PrintUsage() ;

  		BOOL IsSingleThreadTest() const ;
  		BOOL IsMultiThreadTest() const ;
  		std::wstring GetTestName() const ;
  		std::wstring GetFileName() const ;
  		DWORD GetNumThreads() const ;

	private:
  		DWORD         mNumThreads ;
  		std::wstring  mTestName ;
  		std::wstring  mFileName ;
  		BOOL          mIsMultiThreaded ;

};

BOOL TestArgs::IsSingleThreadTest() const
{
  	return (mIsMultiThreaded == FALSE) ;
}

BOOL TestArgs::IsMultiThreadTest() const
{
  	return (mIsMultiThreaded == TRUE) ;
}

std::wstring TestArgs::GetFileName() const
{
  	return mFileName ;
}

std::wstring TestArgs::GetTestName() const 
{
  	return mTestName ;
}

DWORD TestArgs::GetNumThreads() const 
{
  	return mNumThreads ;
}

#endif // _TESTARGS_H_
