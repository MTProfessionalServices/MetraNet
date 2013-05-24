/**************************************************************************
 * @doc 
 * 
 * @module  Test program for the DBAccess DLL |
 * 
 * This test program ise used to test the error paths of the DBAccess DLL
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
 * @index | 
 ***************************************************************************/

#pragma warning( disable : 4786 )
#include <windows.h>
#include <tchar.h>
#include <iostream>
#include <adoutil.h>
#include <DBServicesCollection.h>
#include <DBService.h>
#include <DBServiceProperty.h>
#include <DBSession.h>
#include <string>

using namespace std ;

void main ()
{
  // local variables 
  DWORD nError=NO_ERROR ;
  BOOL bRetCode=TRUE ;
  DBServicesCollection *pDBSvcList=NULL ;
  unsigned char SessionID[16], ParentSessionID[16] ;
  wstring wstrServiceName, wstrParentServiceName, wstrUpdateID ;
  wstring wstrSourcerID, wstrDelivererID ;
  wstring wstrName, wstrValue ;
  
  // create and initialize a DBServicesCollection ...
  cout << "INFO: Getting collection of services from the Database" << endl ;
  pDBSvcList = DBServicesCollection::GetInstance() ;
  if (pDBSvcList == NULL)
  {
    cout << "ERROR: unable to get an instance of the DBServicesCollection. Error = " 
      << ::GetLastError() << endl ;
    return ;
  }
  // create a test session to test error scenarios ...
  cout << "INFO: creating a test DB session to test error scenarios." << endl ;
  DBSession *pDBTest= NULL ;
  pDBTest = new DBSession ;
  if (pDBTest == NULL)
  {
    cout << "ERROR: Unable to allocate a new DBSession object. Error = "  
      << ::GetLastError() << endl ;
    return ;
  }
  // test the calling of routines before initialization ...
  cout << "INFO: testing the calling of member functions before calling DBSession.Init()"
    << endl ;
  bRetCode = pDBTest->AddSession(TRUE) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_FUNCTION)
    {
      cout << "PASSED: call to AddSession() failed before calling Init()." << endl ;
    }
    else
    {
      cout << "FAILED: call to AddSession() failed before calling Init(). Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: call to AddSession() succeeded before calling Init()." << endl ;
    return ;
  }
  bRetCode = pDBTest->CommitSession() ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_FUNCTION)
    {
      cout << "PASSED: call to CommitSession() failed before calling Init()." << endl ;
    }
    else
    {
      cout << "FAILED: call to CommitSession() failed before calling Init(). Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: call to CommitSession() succeeded before calling Init()." << endl ;
    return ;
  }
  bRetCode = pDBTest->AddProperty(_T("NameID"), _T("12345")) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_FUNCTION)
    {
      cout << "PASSED: call to AddProperty() failed before calling Init()." << endl ;
    }
    else
    {
      cout << "FAILED: call to AddProperty() failed before calling Init(). Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: call to AddProperty() succeeded before calling Init()." << endl ;
    return ;
  }
  // test the passing of NULL parameters to DBSession.Init()
  cout << "INFO: Testing NULL parameter names to DBSession.Init()" << endl ;
  bRetCode = pDBTest->Init (NULL, SessionID, &wstrUpdateID) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_PARAMETER)
    {
      cout << "PASSED: NULL service name test." << endl ;
    }
    else
    {
      cout << "FAILED: NULL service name test. Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: NULL service name accepted as parameter." << endl ;
    return ;
  }
  bRetCode = pDBTest->Init (&wstrServiceName, NULL, &wstrUpdateID) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_PARAMETER)
    {
      cout << "PASSED: NULL session id test." << endl ;
    }
    else
    {
      cout << "FAILED: NULL session id test. Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: NULL session id accepted as parameter." << endl ;
    return ;
  }
  bRetCode = pDBTest->Init (&wstrServiceName, SessionID, NULL) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_PARAMETER)
    {
      cout << "PASSED: NULL update id test." << endl ;
    }
    else
    {
      cout << "FAILED: NULL update id test. Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: NULL update id accepted as parameter." << endl ;
    return ;
  }
  // testing pasing invalid parameter name sizes to DBSession.Init()
  cout << "INFO: Testing pasing invalid parameter name size to DBSession.Init()" << endl ;
  wstrUpdateID = L"FOOBAR" ;
  wstrServiceName = L"1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" ;
  bRetCode = pDBTest->Init (&wstrServiceName, SessionID, &wstrUpdateID) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_PARAMETER)
    {
      cout << "PASSED: invalid service name size test." << endl ;
    }
    else
    {
      cout << "FAILED: invalid service name size test. Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: invalid service name size accepted as parameter." << endl ;
    return ;
  }
  wstrServiceName = L"FOOBAR" ;
  wstrUpdateID = L"1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" ;
  bRetCode = pDBTest->Init (&wstrServiceName, SessionID, &wstrUpdateID) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_PARAMETER)
    {
      cout << "PASSED: invalid update id size test." << endl ;
    }
    else
    {
      cout << "FAILED: invalid update id size test. Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: invalid update id size accepted as parameter." << endl ;
    return ;
  }
  wstrServiceName = L"FOOBAR" ;
  wstrUpdateID = L"FOOBAR" ;
  wstrSourcerID = L"1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" ;
  bRetCode = pDBTest->Init (&wstrServiceName, SessionID, &wstrUpdateID, 
    ParentSessionID, &wstrSourcerID) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_PARAMETER)
    {
      cout << "PASSED: invalid sourcer id size test." << endl ;
    }
    else
    {
      cout << "FAILED: invalid sourcer id size test. Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: invalid sourcer id size accepted as parameter." << endl ;
    return ;
  }
  wstrServiceName = L"FOOBAR" ;
  wstrUpdateID = L"FOOBAR" ;
  wstrSourcerID = L"FOOBAR" ;
  wstrDelivererID = L"1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" ;
  bRetCode = pDBTest->Init (&wstrServiceName, SessionID, &wstrUpdateID, 
    ParentSessionID, &wstrSourcerID, &wstrDelivererID) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_PARAMETER)
    {
      cout << "PASSED: invalid sourcer id size test." << endl ;
    }
    else
    {
      cout << "FAILED: invalid sourcer id size test. Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: invalid sourcer id size accepted as parameter." << endl ;
    return ;
  }
  // testing passing invalid service name to DBSession.Init()
  cout << "INFO: Testing passing invalid service names to DBSession.Init()." << endl ;
  wstrServiceName = L"FOOBARSERVICE" ;
  bRetCode = pDBTest->Init (&wstrServiceName, SessionID, &wstrUpdateID) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_PARAMETER)
    {
      cout << "PASSED: invalid service name test." << endl ;
    }
    else
    {
      cout << "FAILED: invalid service name test. Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: invalid service name accepted as parameter." << endl ;
    return ;
  }
  /*wstrServiceName = L"metratech.com/fax" ;
  wstrParentServiceName = L"FOO" ;
  bRetCode = pDBTest->Init (&wstrServiceName, SessionID, &wstrUpdateID, &wstrParentServiceName) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_PARAMETER)
    {
      cout << "PASSED: invalid parent service name test." << endl ;
    }
    else
    {
      cout << "FAILED: invalid parent service name test. Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: invalid parent name accepted as parameter." << endl ;
    return ;
  }*/
  // testing bad passing bad properties to AddProperty
  cout << "INFO: testing passing invalid properties to DBSession.AddProperty()." << endl ;
  wstrServiceName = L"netcentric.com/fax" ;
  wstrUpdateID = L"FOOBAR" ;
  bRetCode = pDBTest->Init (&wstrServiceName, SessionID, &wstrUpdateID) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_PARAMETER)
    {
      cout << "FAILED: passed valid service name to Init()" << endl ;
      return ;
    }
    else
    {
      cout << "FAILED: passed valid service name to Init(). Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "PASSED: passed valid service name to Init()." << endl ;
  }
  
  wstrName = L"FOO" ;
  wstrValue = L"BAR" ;
  bRetCode = pDBTest->AddProperty(wstrName, wstrValue) ;
  if (bRetCode == FALSE)
  {
    nError = pDBTest->GetLastError() ;
    if (nError == ERROR_INVALID_PARAMETER)
    {
      cout << "PASSED: invalid property name test." << endl ;
    }
    else
    {
      cout << "FAILED: invalid property name test. Error = " << nError << endl ;
      return ;
    }
  }
  else
  {
    cout << "FAILED: invalid property accepted as parameter." << endl ;
    return ;
  }

  // delete allocated memory ...
  delete pDBTest ;
  pDBSvcList->ReleaseInstance() ;

  return ;

}