/**************************************************************************
* @doc
* 
* Copyright 1998 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LISCENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Kevin Fitzgerald
* $Header$
***************************************************************************/

#include <windows.h>
#include <iostream>
#include <NTRegistryIO.h>
#include "ConfigDir.h"

using std::cout;
using std::endl;

#define SAMPLE_DESCRIPTION    _T("Blah BLAH Blah")
#define SAMPLE_DESCRIPTION2   _T("NetMeter Server")

//
//   $Function:: $
// 
// $Parameters:: $
// 
//    $Content:: $
// 
//     $Return:: $
//
void main (int argc, char **argv)
{

	long regFlag = 0;

	if (GetMTIgnoreHooks(regFlag))
	{
		cout << "GetMTIgnoreHooks successfully" << endl;
	}

	cout << regFlag << endl;
#if 0
  // local variables ...
  NTRegistryIO RegWrite ;
  BOOL bRetCode=TRUE ;
  BYTE *pValue;
  DWORD nValNameSize;
  
  // test the NTRegistryIO class ...
  cout << "INFO: Test #1 - OpenRegistryRaw with Read Access testing" << endl << endl ;
  bRetCode = RegWrite.OpenRegistryRaw (NTRegistryIO::NTRegTree::LOCAL_MACHINE, 
    _T("SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion"), RegistryIO::AccessType::READ_ACCESS) ;
  
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to OpenRegistryRaw() failed." << endl ;
    return ;
  }
  cout << "PASSED: OpenRegistryRaw() with Read Access succeeded." << endl ;
  
  nValNameSize = 1024 ;
  pValue = new BYTE[1024] ;
  if (pValue == NULL)
  {
    cout << "FAILED: unable to allocate memory. Error = " << GetLastError() << endl ;
    return ;
  }
  // read the version information out of the registry ...
  bRetCode = RegWrite.ReadRegistryValue(_T("CurrentVersion"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to ReadRegistryValue() failed." << endl ;
    return ;
  }
  // get the version info by calling GetVersionEX so we can verify that nothing got corrupted ...
  OSVERSIONINFO OSVerInfo ;
  OSVerInfo.dwOSVersionInfoSize = sizeof (OSVERSIONINFO) ;
  bRetCode = ::GetVersionEx (&OSVerInfo) ;
  if (bRetCode == 0)
  {
    cout << "FAILED: call to GetVersionEx() failed. Error = " << GetLastError() << endl ;
    return ;
  }
  // build the version string ...
  _TCHAR Version[10] ;
  _stprintf(Version, _T("%d.%d"), OSVerInfo.dwMajorVersion, OSVerInfo.dwMinorVersion) ;
  if ((_tcscmp (Version, (_TCHAR *) pValue)) == 0)
  {
    cout << "PASSED: ReadRegistryValue() succeeded. Verified OS Revision." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() failed. Verification of OS revision failed." << endl ;
    return ;
  }
  // read the service pack information out of the registry ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("CSDVersion"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to ReadRegistryValue() failed." << endl ;
    return ;
  }
  // compare the servic pack strings ...
  if ((_tcscmp (OSVerInfo.szCSDVersion, (_TCHAR *) pValue)) == 0)
  {
    cout << "PASSED: ReadRegistryValue() succeeded. Verified Service Pack." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() failed. Verification of Service Pack failed." << endl ;
    return ;
  }
  // try to write the same registry value ...
  bRetCode = RegWrite.WriteRegistryValue(_T("CurrentVersion"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: WriteRegistryValue() failed when Registry opened with Read Access." << endl ;
  }
  else
  {
    cout << "FAILED: WriteRegistryValue() succeeded when Registry opened with Read Access." << endl ;
    return;
  }
  // read an unknown registry value ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("FooBarVersionABCXYZ"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed when trying to read unknown key." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded when trying to read unknown key." << endl ;
    return ;
  }
  // close the registry ...
  RegWrite.CloseRegistry() ;
  cout << "INFO: CloseRegistry() called." << endl ;
  
  // try to read from the registry ... it shoudl fail ...
  bRetCode = RegWrite.ReadRegistryValue(_T("CurrentVersion"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
  // try to write to the registry ... it should fail ...
  bRetCode = RegWrite.WriteRegistryValue(_T("CurrentVersion"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: WriteRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: WriteRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
  
  // test the writing of registry data ...
  cout << endl << "INFO: Test #2 - OpenRegistryRaw with Write Access testing" << endl << endl ;
  bRetCode = RegWrite.OpenRegistryRaw (NTRegistryIO::NTRegTree::LOCAL_MACHINE, 
    _T("SOFTWARE\\MetraTech\\NetMeter\\CurrentVersion\\Server"), RegistryIO::AccessType::WRITE_ACCESS) ;
  
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to OpenRegistryRaw() failed." << endl ;
    return ;
  }
  cout << "PASSED: OpenRegistryRaw() with Write Access succeeded." << endl ;
   
  // try to write the registry value ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  _tcscpy ((_TCHAR *) pValue, SAMPLE_DESCRIPTION) ;
  nValNameSize = (_tcslen ((_TCHAR *) pValue) * sizeof (_TCHAR)) + 1;
  bRetCode = RegWrite.WriteRegistryValue(_T("Description"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: WriteRegistryValue() failed when Registry opened with Write Access." << endl ;
    return ;
  }
  else
  {
    cout << "PASSED: WriteRegistryValue() succeeded when Registry opened with Write Access." << endl ;
  }
  // read back the registry value we wrote ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("Description"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed when Registry opened with Write Access." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded when Registry opened with Write Access." << endl ;
    return ;
  }
  
  // close the registry ...
  RegWrite.CloseRegistry() ;
  cout << "INFO: CloseRegistry() called." << endl ;
  
  // try to read from the registry ... it shoudl fail ...
  bRetCode = RegWrite.ReadRegistryValue(_T("CurrentVersion"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
  // try to write to the registry ... it should fail ...
  bRetCode = RegWrite.WriteRegistryValue(_T("CurrentVersion"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: WriteRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: WriteRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
  // test the reading and writing of data ...
  cout << endl << "INFO: Test #3 - OpenRegistryRaw with All Access testing" << endl << endl ;
  bRetCode = RegWrite.OpenRegistryRaw (NTRegistryIO::NTRegTree::LOCAL_MACHINE, 
    _T("SOFTWARE\\MetraTech\\NetMeter\\CurrentVersion\\Server"), RegistryIO::AccessType::ALL_ACCESS) ;  
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to OpenRegistryRaw() failed." << endl ;
    return ;
  }
  cout << "PASSED: OpenRegistryRaw() with All Access succeeded." << endl ;
  
  
  // read the description information out of the registry ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("Description"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to ReadRegistryValue() failed." << endl ;
    return ;
  }
  // we know what it should be ... make sure it is ...
  if ((_tcscmp (SAMPLE_DESCRIPTION, (_TCHAR *) pValue)) == 0)
  {
    cout << "PASSED: ReadRegistryValue() succeeded. Verified Description value." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() failed. Unable to verify Description value." << endl ;
    return ;
  }

  // write the original value back ... 
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  _tcscpy ((_TCHAR *) pValue, SAMPLE_DESCRIPTION2) ;
  nValNameSize = (_tcslen ((_TCHAR *) pValue) * sizeof (_TCHAR)) + 1;
  bRetCode = RegWrite.WriteRegistryValue(_T("Description"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to WriteRegistryValue() failed." << endl ;
    return ;
  }
  cout << "PASSED: WriteRegistryValue succeeded. Wrote original description." << endl ;
  // read the description information out of the registry ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("Description"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to ReadRegistryValue() failed." << endl ;
    return ;
  }
  // we know what it should be ... make sure it is ...
  if ((_tcscmp (SAMPLE_DESCRIPTION2, (_TCHAR *) pValue)) == 0)
  {
    cout << "PASSED: ReadRegistryValue() succeeded. Verified Description value." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() failed. Unable to verify Description value." << endl ;
    return ;
  }
  
  // write an unknown registry value ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("FooBarVersionABCXYZ"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed when trying to read unknown key." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded when trying to read unknown key." << endl ;
    return ;
  }

  // close the registry ...
  RegWrite.CloseRegistry() ;
  cout << "INFO: CloseRegistry() called." << endl ;
  
  // try to read from the registry ... it shoudl fail ...
  bRetCode = RegWrite.ReadRegistryValue(_T("Version"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
  // try to write to the registry ... it should fail ...
  bRetCode = RegWrite.WriteRegistryValue(_T("Version"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: WriteRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: WriteRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
  // open something within the MetraTech tree ...
  cout << endl << "INFO: Test #4 - OpenRegistry with Read Access testing" << endl << endl;
  bRetCode = RegWrite.OpenRegistry (_T("NetMeter"), _T("Server"), 
    RegistryIO::AccessType::READ_ACCESS) ;  
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to OpenRegistry() failed." << endl ;
    return ;
  }
  cout << "PASSED: OpenRegistry() with Read Access succeeded." << endl ;
  
  // read the version information out of the registry ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("Version"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to ReadRegistryValue() failed." << endl ;
    return ;
  }
  cout << "PASSED: ReadRegistryValue() succeeded. Version = " << (_TCHAR *) pValue << endl ;
  
  // read the description information out of the registry ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("Description"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to ReadRegistryValue() failed." << endl ;
    return ;
  }
  cout << "PASSED: ReadRegistryValue() succeeded. Description = " << (_TCHAR *) pValue << endl ;
  
  
  // try to write the same registry value ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.WriteRegistryValue(_T("Version"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: WriteRegistryValue() failed when Registry opened with Read Access." << endl ;
  }
  else
  {
    cout << "FAILED: WriteRegistryValue() succeeded when Registry opened with Read Access." << endl ;
    return;
  }
  // read an unknown registry value ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("FooBarVersionABCXYZ"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed when trying to read unknown key." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded when trying to read unknown key." << endl ;
    return ;
  }
  
  // close the registry ...
  RegWrite.CloseRegistry() ;
  cout << "INFO: CloseRegistry() called." << endl ;
  
  // try to read from the registry ... it shoudl fail ...
  bRetCode = RegWrite.ReadRegistryValue(_T("Version"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
  // try to write to the registry ... it should fail ...
  bRetCode = RegWrite.WriteRegistryValue(_T("Version"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: WriteRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: WriteRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
  // test the writing of registry data ...
  cout << endl << "INFO: Test #5 - OpenRegistry with Write Access testing" << endl << endl ;
  bRetCode = RegWrite.OpenRegistry (_T("NetMeter"), _T("Server"), 
    RegistryIO::AccessType::WRITE_ACCESS) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to OpenRegistry() failed." << endl ;
    return ;
  }
  cout << "PASSED: OpenRegistry() with Write Access succeeded." << endl ;
   
  // try to write the registry value ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  _tcscpy ((_TCHAR *) pValue, SAMPLE_DESCRIPTION) ;
  nValNameSize = (_tcslen ((_TCHAR *) pValue) * sizeof (_TCHAR)) + 1;
  bRetCode = RegWrite.WriteRegistryValue(_T("Description"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: WriteRegistryValue() failed when Registry opened with Write Access." << endl ;
    return ;
  }
  else
  {
    cout << "PASSED: WriteRegistryValue() succeeded when Registry opened with Write Access." << endl ;
  }
  // read back the registry value we wrote ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("Description"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed when Registry opened with Write Access." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded when Registry opened with Write Access." << endl ;
    return ;
  }
  
  // close the registry ...
  RegWrite.CloseRegistry() ;
  cout << "INFO: CloseRegistry() called." << endl ;
  
  // try to read from the registry ... it shoudl fail ...
  bRetCode = RegWrite.ReadRegistryValue(_T("Version"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
  // try to write to the registry ... it should fail ...
  bRetCode = RegWrite.WriteRegistryValue(_T("Version"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: WriteRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: WriteRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
  // test the reading and writing of data ...
  cout << endl << "INFO: Test #6 - OpenRegistry with All Access testing" << endl << endl ;
  bRetCode = RegWrite.OpenRegistry (_T("NetMeter"), _T("Server"), 
    RegistryIO::AccessType::ALL_ACCESS) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to OpenRegistry() failed." << endl ;
    return ;
  }
  cout << "PASSED: OpenRegistry() with All Access succeeded." << endl ;
  
  
  // read the description information out of the registry ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("Description"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to ReadRegistryValue() failed." << endl ;
    return ;
  }
  // we know what it should be ... make sure it is ...
  if ((_tcscmp (SAMPLE_DESCRIPTION, (_TCHAR *) pValue)) == 0)
  {
    cout << "PASSED: ReadRegistryValue() succeeded. Verified Description value." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() failed. Unable to verify Description value." << endl ;
    return ;
  }

  // write the original value back ... 
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  _tcscpy ((_TCHAR *) pValue, SAMPLE_DESCRIPTION2) ;
  nValNameSize = (_tcslen ((_TCHAR *) pValue) * sizeof (_TCHAR)) + 1;
  bRetCode = RegWrite.WriteRegistryValue(_T("Description"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to WriteRegistryValue() failed." << endl ;
    return ;
  }
  // read the description information out of the registry ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("Description"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "FAILED: Call to ReadRegistryValue() failed." << endl ;
    return ;
  }
  // we know what it should be ... make sure it is ...
  if ((_tcscmp (SAMPLE_DESCRIPTION2, (_TCHAR *) pValue)) == 0)
  {
    cout << "PASSED: ReadRegistryValue() succeeded. Verified Description value." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() failed. Unable to verify Description value." << endl ;
    return ;
  }
  
  // write an unknown registry value ...
  memset (pValue, 0, 1024) ;
  nValNameSize = 1024 ;
  bRetCode = RegWrite.ReadRegistryValue(_T("FooBarVersionABCXYZ"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed when trying to read unknown key." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded when trying to read unknown key." << endl ;
    return ;
  }

  // close the registry ...
  RegWrite.CloseRegistry() ;
  cout << "INFO: CloseRegistry() called." << endl ;
  
  // try to read from the registry ... it shoudl fail ...
  bRetCode = RegWrite.ReadRegistryValue(_T("Version"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: ReadRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: ReadRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
  // try to write to the registry ... it should fail ...
  bRetCode = RegWrite.WriteRegistryValue(_T("Version"), RegistryIO::ValueType::STRING, 
    pValue, nValNameSize) ;
  if (bRetCode == FALSE)
  {
    cout << "PASSED: WriteRegistryValue() failed after a CloseRegistry()." << endl ;
  }
  else
  {
    cout << "FAILED: WriteRegistryValue() succeeded after CloseRegistry()." << endl ;
    return ;
  }
#endif

  return ;
  }
  
  
  
