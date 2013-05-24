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

#ifndef __NTREGISTRYIO_H
#define __NTREGISTRYIO_H

// #include files ...
#include "RegistryIO.h"
#include "MTSL_DLL.h"

// @class NTRegistryIO (inherited from RegistryIO)
class MTSL_DLL_EXPORT NTRegistryIO : public RegistryIO
{
// @access Public:
public:
  // @cmember,menum NT Registry tree to open when opening a specific key
  enum NTRegTree
  {
    // @@emem HKEY_CLASSES_ROOT tree
    CLASSES_ROOT=0x00,
    // @@emem HKEY_CURRENT_CONFIG tree
    CURRENT_CONFIG=0x01,
    // @@emem HKEY_CURRENT_USER tree
    CURRENT_USER=0x02,
    // @@emem HKEY_LOCAL_MACHINE tree
    LOCAL_MACHINE=0x03,
    // @@emem HKEY_USERS tree
    USERS=0x04,
    // @@emem HKEY_PERF_DATA tree
    PERF_DATA=0x05
  } ;
  // @cmember Constructor
  NTRegistryIO() ;
  // @cmember Destructor
  virtual ~NTRegistryIO() ;

  // @cmember Open the MetraTech registry key with the specified access.
  virtual BOOL OpenRegistry(const _TCHAR *apTreeName, const _TCHAR *apSubTree, 
    const AccessType aAccessType, const _TCHAR *apVersion=_T("CurrentVersion")) ;
  // @cmember Read the specified registry value 
  virtual BOOL ReadRegistryValue (const _TCHAR *apValueName, const ValueType aValueType, 
    BYTE * &arpDataBuffer, DWORD &arDataBufferSize) ;
  // @cmember Write data to the specified registry value
  virtual BOOL WriteRegistryValue (const _TCHAR *apValueName, const ValueType aValueType, 
    BYTE * &arpDataBuffer, DWORD &arDataBufferSize) ;
	// write a string value to the registry (helper function)
	virtual BOOL WriteRegistryValue (const _TCHAR *apValueName, const _TCHAR * apValue);

	// create the given key
	virtual BOOL CreateKey(const NTRegTree aRootKey, const _TCHAR *apKey,
												 const AccessType aAccessType);
  // @cmember Close the registry key
  virtual void CloseRegistry() ;

  // @cmember Open the specified Windows NT registry key with the specified access
  BOOL OpenRegistryRaw (const NTRegTree aRootKey, const _TCHAR *apKey, 
    const AccessType aAccessType) ;
  // @cmember Get the last error 
  DWORD GetLastError() const ;
// @access Private:
private:
  // @cmember handle to the specified registry key
  HKEY        mIOKey ;
  // @cmember the access type
  AccessType    mAccessType ;
  // @cmember the last error 
  DWORD         mLastError ;
} ;

//
//	@mfunc
//	Get the last error
//  @rdesc 
//  Returns the mLastError data member
// 
inline DWORD NTRegistryIO::GetLastError() const
{
  return mLastError ;
}

#endif // __NTREGISTRYIO_H

