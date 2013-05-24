/**************************************************************************
 * @doc REGISTRYIO
 * 
 * @module Registry I/O encapsulation |
 * 
 * This is an encapsulation for access to the Registry.
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
 * @index | REGISTRYIO
 ***************************************************************************/

#ifndef __REGISTRYIO_H
#define __REGISTRYIO_H

#include "MTSL_DLL.h"
#include <tchar.h>
// @class Threader (abstract class)
class MTSL_DLL_EXPORT RegistryIO
{
// @access Public:
public:
  // @cmember,menum Type of access wanted when opening registry
  enum AccessType
  {
    // @@emem Full access to the registry
    ALL_ACCESS=0x00,
    // @@emem Read access to the registry
    READ_ACCESS=0x01,
    // @@emem Write access to the registry
    WRITE_ACCESS=0x02,
    // @@emem No access to the registry
    NO_ACCESS=0x03
  } ;
  
  // @cmember,menum Type to read or write 
  enum ValueType 
  {
    // @@emem binary value
    BINARY=0x00,
    // @@emem unsigned long value
    ULONG=0x01,
    // @@emem string value
    STRING=0x02,
    // @@emem multi-string value
    MULTI_STRING=0x03
  } ;
  // @cmember Constructor
  RegistryIO() {} ;
  // @cmember Destructor
  virtual ~RegistryIO() {};

  // @cmember,mfunc This function will open the specified key with the appropriate access.
  //  @@parm The tree to open within the MetraTech registry
  //  @@parm The subtree to open within the MetraTech registry
  //  @@parm The access to open the registry with
  //  @@parm The version of the tree to open
	//  @@rdesc
	//  Returns TRUE if the was opened. Otherwise, FALSE is returned.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
  virtual BOOL OpenRegistry(const _TCHAR *apTreeName, const _TCHAR *apSubTree, 
    const AccessType aAccessType, const _TCHAR *apVersion) =0;
  // @cmember,mfunc This function will read the specified value from the registry.
	//  @@rdesc
	//  Returns TRUE if the value was read successfully. Otherwise, FALSE is returned.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
	//  @@xref <c RegistryIO>
  virtual BOOL ReadRegistryValue (const _TCHAR *apValueName, const ValueType aValueType, 
    BYTE * &arpDataBuffer, DWORD &arDataBufferSize) =0;
  // @cmember,mfunc This function will write the specified value from the registry.
	//  @@rdesc
	//  Returns TRUE if the value was written successfully. Otherwise, FALSE is returned.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
	//  @@xref <c RegistryIO>
  virtual BOOL WriteRegistryValue (const _TCHAR *apValueName, const ValueType aValueType, 
    BYTE * &arpDataBuffer, DWORD &arDataBufferSize) =0;
  // @cmember,mfunc This function will close the registry.
	//  @@rdesc
	//  No return value.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
  virtual void CloseRegistry() =0;
  // @cmember,mfunc This function will return the last error for the registry class.
	//  @@rdesc
	//  The last error encountered in the registry class.
  //  @@devnote
  //  This is a pure virtual function that is implemented by the inheritor
  //  of this class. 
  virtual DWORD GetLastError() const =0 ;
} ;

#endif // __REGISTRYIO_H

