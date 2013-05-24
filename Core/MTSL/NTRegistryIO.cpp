/**************************************************************************
 * @doc NTREGISTRYIO
 * 
 * @module Registry I/O encapsulation |
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
 * @index | NTREGISTRYIO
 ***************************************************************************/

#include "MTSL_PCH.h"
#include <NTRegistryIO.h>
#include <stdio.h>

//
//	@mfunc
//	Initialize the data members to invalid values.
//  @rdesc 
//  No return value
// 
NTRegistryIO::NTRegistryIO()
: mIOKey(0), mAccessType (NO_ACCESS), mLastError (NO_ERROR)
{
}

//
//	@mfunc
//	Call the CloseRegistry() function to close the registry key
//  @rdesc 
//  No return value
// 
NTRegistryIO::~NTRegistryIO()
{
  // call CloseRegistry()
  CloseRegistry() ;
}

//
//	@mfunc
//	Open the specified registry key in the MetraTech registry hierarchy with the
//  specified access
//	@parm The tree within the MetraTech hierarchy (e.g. NetMeter)
//  @parm The subtree within the MetraTech hierarchy (e.g. NTService)
//  @parm The access type to open the key with
//  @parmopt The version of the registry hierarchy to open. Defaults to "CurrentVersion"
//  @rdesc 
//  Returns TRUE if the key was opened successfully. Otherwise, FALSE is returned and the
//  error code is put in the mLastError data member.
//  @devnote
//  This routine should be called before calls to ReadRegistryValue() and WriteRegistryValue().
//  This is a convienience function to open a key within the MetraTech registry. If access
//  to other registry keys is needed use the OpenRegistryRaw() function. 
// 
BOOL NTRegistryIO::OpenRegistry(const _TCHAR *apTreeName, const _TCHAR *apSubTree, 
    const AccessType aAccessType, const _TCHAR *apVersion)
{
  BOOL bRetCode=TRUE ;
  _TCHAR keyName[1024] ;
  LONG nRetVal = ERROR_SUCCESS ;

  // make sure the registry is closed before we try to open it ...
  CloseRegistry() ;

  // create the registry key to open ...
  _stprintf (keyName, _T("SOFTWARE\\MetraTech\\%s\\%s\\%s"), apTreeName, apVersion, apSubTree) ;

  // open the appropriate key in HKEY_LOCAL_MACHINE ...
  switch (aAccessType)
  {
  case ALL_ACCESS:
    nRetVal = ::RegOpenKeyEx (HKEY_LOCAL_MACHINE, keyName, 0, KEY_ALL_ACCESS, &mIOKey) ;
    break ;

  case READ_ACCESS:
    nRetVal = ::RegOpenKeyEx (HKEY_LOCAL_MACHINE, keyName, 0, KEY_READ, &mIOKey) ;
    break ;

  case WRITE_ACCESS:
    nRetVal = ::RegOpenKeyEx (HKEY_LOCAL_MACHINE, keyName, 0, KEY_WRITE, &mIOKey) ;
    break ;

  default:
    nRetVal = ERROR_INVALID_PARAMETER ;
    break ;
  }

  // check the return value ...
  if (nRetVal != ERROR_SUCCESS)
  {
    bRetCode = FALSE;
    mIOKey = 0 ;
    mAccessType = NO_ACCESS ;
    mLastError = nRetVal ;
  }
  // we opened the registry ... set the appropriate access type ...
  else
  {
    mAccessType = aAccessType ;
  }

  return bRetCode ;
}


//
//	Create the given registry key.
// 

BOOL NTRegistryIO::CreateKey(const NTRegTree aRootKey, const _TCHAR *apKey,
														 const AccessType aAccessType)
{
  BOOL bRetCode=TRUE ;
  REGSAM regAccessType ;
  DWORD nRetVal = ERROR_SUCCESS ;

  // make sure the registry is closed before we try to open it ...
  CloseRegistry();


  switch (aAccessType)
  {
  case ALL_ACCESS:
		regAccessType = KEY_ALL_ACCESS;
    break ;
  case READ_ACCESS:
		regAccessType = KEY_READ;
    break ;

  case WRITE_ACCESS:
		regAccessType = KEY_WRITE;
    break ;

  default:
    mLastError = ERROR_INVALID_PARAMETER;
		return FALSE;
  }


	// get the handle to the correct root
	HKEY root;
	switch (aRootKey)
	{
	case CLASSES_ROOT:
		root = HKEY_CLASSES_ROOT;
		break ;

	case CURRENT_CONFIG:
		root = HKEY_CURRENT_CONFIG;
		break ;

	case CURRENT_USER:
		root = HKEY_CURRENT_USER;
		break ;

	case LOCAL_MACHINE:
		root = HKEY_LOCAL_MACHINE;
		break ;
    
	case USERS:
		root = HKEY_USERS;
		break ;

	case PERF_DATA:
		root = HKEY_PERFORMANCE_DATA;
		break ;

	default:
    mLastError = ERROR_INVALID_PARAMETER;
		return FALSE;
	}

	// create and open the key
	nRetVal = ::RegCreateKeyEx(
		root,												// handle to open key
		apKey,											// subkey name
		0,													// reserved
		NULL,												// class string
		REG_OPTION_NON_VOLATILE,		// special options
		regAccessType,							// desired security access
		NULL,												// inheritance
		&mIOKey,										// key handle 
		NULL);											// disposition value buffer


	nRetVal = ::RegCreateKey(root, apKey, &mIOKey);
	if (nRetVal != ERROR_SUCCESS)
	{
		mLastError = nRetVal;
		return FALSE;
	}

	
	mAccessType = aAccessType;

  return bRetCode ;
}



//
//	@mfunc
//	Open the registry key within the specified Windows NT registry root with the 
//  appropriate access
//	@parm The Windows NT Registry root 
//  @parm The key to open
//  @parm The access type to open the key with
//  @rdesc 
//  Returns TRUE if the key was opened successfully. Otherwise, FALSE is returned and the
//  error code is put in the mLastError data member.
//  @devnote
//  This routine should be called before calls to ReadRegistryValue() and WriteRegistryValue().
// 
BOOL NTRegistryIO::OpenRegistryRaw(const NTRegTree aRootKey, const _TCHAR *apKey, 
    const AccessType aAccessType)
{
  BOOL bRetCode=TRUE ;
  REGSAM regAccessType ;
  DWORD nRetVal = ERROR_SUCCESS ;

  // make sure the registry is closed before we try to open it ...
  CloseRegistry() ;

  // start the try ...
  try
  {
    // set the appropriate access ...
    switch (aAccessType)
    {
    case ALL_ACCESS:
      regAccessType = KEY_ALL_ACCESS ;
      break ;
      
    case READ_ACCESS:
      regAccessType = KEY_READ ;
      break ;
      
    case WRITE_ACCESS:
      regAccessType = KEY_WRITE ;
      break ;
      
    default:
      nRetVal = ERROR_INVALID_PARAMETER ;
      break ;
    }
    if (nRetVal != ERROR_SUCCESS)
    {
      throw nRetVal ;
    }

    // open the appropriate key ...
    switch (aRootKey)
    {
    case CLASSES_ROOT:
      nRetVal = ::RegOpenKeyEx (HKEY_CLASSES_ROOT, apKey, 0, regAccessType, &mIOKey) ;
      break ;

    case CURRENT_CONFIG:
      nRetVal = ::RegOpenKeyEx (HKEY_CURRENT_CONFIG, apKey, 0, regAccessType, &mIOKey) ;
      break ;

    case CURRENT_USER:
      nRetVal = ::RegOpenKeyEx (HKEY_CURRENT_USER, apKey, 0, regAccessType, &mIOKey) ;
      break ;

    case LOCAL_MACHINE:
      nRetVal = ::RegOpenKeyEx (HKEY_LOCAL_MACHINE, apKey, 0, regAccessType, &mIOKey) ;
      break ;
    
    case USERS:
      nRetVal = ::RegOpenKeyEx (HKEY_USERS, apKey, 0, regAccessType, &mIOKey) ;
      break ;

    case PERF_DATA:
      nRetVal = ::RegOpenKeyEx (HKEY_PERFORMANCE_DATA, apKey, 0, regAccessType, &mIOKey) ;
      break ;

    default:
      nRetVal = ERROR_INVALID_PARAMETER ;
      break ;
    }
    if (nRetVal != ERROR_SUCCESS)
    {
      throw nRetVal ;
    }
    // assign the access type for the registry ...
    mAccessType = aAccessType ;
  }
  catch (DWORD nStatus) 
  {
    bRetCode = FALSE ;
    mIOKey = 0 ;
    mAccessType = NO_ACCESS ;
    mLastError = nStatus ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	This function reads the specified registry value and puts the data in the specified
//  data buffer.
//	@parm The registry value to read
//  @parm The type of registry value 
//  @parm The buffer to read the data into
//  @parm The size of the data buffer
//  @rdesc 
//  Returns TRUE if the key was read successfully. Otherwise, FALSE is returned and the
//  error code is put in the mLastError data member.
//  @devnote
//  This routine returns ERROR_INVALID_FUNCTION if the registry was not opened properly or
//  the registry was opened but without the correct access.
// 
BOOL NTRegistryIO::ReadRegistryValue(const _TCHAR *apValueName, const ValueType aValueType, 
    BYTE * &arpDataBuffer, DWORD &arDataBufferSize)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  DWORD nRetVal = ERROR_SUCCESS ;
  DWORD nValType ;

  // start the try 
  try
  {
    // check to make sure the user has the right access to read the registry ...
    if ((mAccessType != ALL_ACCESS) && (mAccessType != READ_ACCESS))
    {
      nRetVal = ERROR_INVALID_FUNCTION ;
      throw nRetVal ;
    }

    // we have correct access ...switch on the value type ...
    switch (aValueType)
    {
     case BINARY:
      nValType = REG_BINARY ;
      nRetVal = ::RegQueryValueEx (mIOKey, apValueName, 0, &nValType, arpDataBuffer, &arDataBufferSize) ;
      break ;
      
    case ULONG:
      nValType = REG_DWORD ;
      nRetVal = ::RegQueryValueEx (mIOKey, apValueName, 0, &nValType, arpDataBuffer, &arDataBufferSize) ;
      break ;
      
    case STRING:
      nValType = REG_SZ ;
      nRetVal = ::RegQueryValueEx (mIOKey, apValueName, 0, &nValType, arpDataBuffer, &arDataBufferSize) ;
      break ;

    case MULTI_STRING:
      nValType = REG_MULTI_SZ ;
      nRetVal = ::RegQueryValueEx (mIOKey, apValueName, 0, &nValType, arpDataBuffer, &arDataBufferSize) ;
      break ;

      
    default:
      nRetVal = ERROR_INVALID_FUNCTION ;
      break ;
    }
    // check the error code ...
    if (nRetVal != ERROR_SUCCESS)
    {
      throw nRetVal ;
    }
  }
  catch (DWORD nStatus)
  {
    bRetCode = FALSE ;
    mLastError = nStatus ;
  }

  return bRetCode ;
}

BOOL NTRegistryIO::WriteRegistryValue (const _TCHAR *apValueName,
																			 const _TCHAR * apValue)
{
	BYTE * data = (BYTE *) apValue;
	DWORD len = _tcslen(apValue) * sizeof(apValue[0]);

	return WriteRegistryValue(apValueName, STRING, data, len);
}


//
//	@mfunc
//	This function writes data from the buffer passed to the specified registry value .
//	@parm The registry value to write
//  @parm The type of registry value 
//  @parm The buffer write the data from
//  @parm The size of the data buffer
//  @rdesc 
//  Returns TRUE if the key was written successfully. Otherwise, FALSE is returned and the
//  error code is put in the mLastError data member.
//  @devnote
//  This routine returns ERROR_INVALID_FUNCTION if the registry was not opened properly or
//  the registry was opened but without the correct access.
// 
BOOL NTRegistryIO::WriteRegistryValue(const _TCHAR *apValueName, const ValueType aValueType, 
    BYTE * &arpDataBuffer, DWORD &arDataBufferSize)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  DWORD nRetVal = ERROR_SUCCESS ;
  DWORD nValType ;

  // start the try 
  try
  {
    // check to make sure the user has the right access to read the registry ...
    if ((mAccessType != ALL_ACCESS) && (mAccessType != WRITE_ACCESS))
    {
      nRetVal = ERROR_INVALID_FUNCTION ;
      throw nRetVal ;
    }

    // we have correct access ...switch on the value type ...
    switch (aValueType)
    {
    case BINARY:
      nValType = REG_BINARY ;
      nRetVal = ::RegSetValueEx (mIOKey, apValueName, 0, nValType, arpDataBuffer, arDataBufferSize) ;
      break ;
      
    case ULONG:
      nValType = REG_DWORD ;
      nRetVal = ::RegSetValueEx (mIOKey, apValueName, 0, nValType, arpDataBuffer, arDataBufferSize) ;
      break ;
      
    case STRING:
      nValType = REG_SZ ;
      nRetVal = ::RegSetValueEx (mIOKey, apValueName, 0, nValType, arpDataBuffer, arDataBufferSize) ;
      break ;
      
    case MULTI_STRING:
      nValType = REG_MULTI_SZ ;
      nRetVal = ::RegSetValueEx (mIOKey, apValueName, 0, nValType, arpDataBuffer, arDataBufferSize) ;
      break ;

    default:
      nRetVal = ERROR_INVALID_PARAMETER ;
      break ;
    }
    
    // check the error code ...
    if (nRetVal != ERROR_SUCCESS)
    {
      throw nRetVal ;
    }
  }
  catch (DWORD nStatus)
  {
    mLastError = nStatus ;
    bRetCode = FALSE ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	Close the registry
//  @rdesc 
//  No return value
//  @devnote
//  This routine closes the registry key if it is open.
// 
void NTRegistryIO::CloseRegistry()
{
  // local variables ...
  LONG nRetVal=ERROR_SUCCESS ;

  if (mIOKey != 0)
  {
    nRetVal = ::RegCloseKey (mIOKey) ;
    mIOKey = 0 ;
    mAccessType = NO_ACCESS ;
  }
  return  ;
}

