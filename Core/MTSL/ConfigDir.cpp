/**************************************************************************
 * @doc CONFIGDIR
 *
 * Copyright 1999 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <comdef.h>
#include <MTUtil.h>
#include <NTRegistryIO.h>
#include <ConfigDir.h>

// MetraNet keys
#define REG_BRANCH_METRANET  _T("SOFTWARE\\MetraTech\\MetraNet\\")

#define REG_VALUE_CONFIG     _T("ConfigDir")
#define REG_VALUE_INSTALL    _T("InstallDir")
#define REG_VALUE_EXTENSIONS _T("ExtensionsDir")

// MetraConnect keys
#define REG_BRANCH_METRACONNECT            _T("SOFTWARE\\MetraTech\\MetraConnect\\")
#define REG_VALUE_DISABLE_MSIX_COMPRESSION _T("DisableCompression")

static BOOL GetMTRegistryValue(std::string & arDir, wchar_t * achrBranch, wchar_t * achrValue, bool abTrailingSlash = true);
static BOOL GetMTRegistryLongValue(long & arVal, wchar_t * achrBranch, wchar_t * achrValue);

BOOL
GetMTConfigDir(std::string & arConfigDir)
{
  return GetMTRegistryValue(arConfigDir, REG_BRANCH_METRANET, REG_VALUE_CONFIG);
}

BOOL GetExtensionsDir(std::string & arExtensionsDir)
{
  // inconsistent but, for backwards-compatibility, no trailing slash on Extensions dir
  return GetMTRegistryValue(arExtensionsDir, REG_BRANCH_METRANET, REG_VALUE_EXTENSIONS, false);
}

BOOL
GetMTInstallDir(std::string & arInstallDir)
{
  return GetMTRegistryValue(arInstallDir, REG_BRANCH_METRANET, REG_VALUE_INSTALL);
}

// the SDK will always use compression unless the
// 'DisableCompression' key is present and set to non-zero
// if the key is missing, it is assumed that compression is enabled (the default)
bool IsMSIXCompressionEnabled()
{
	long disableCompression;
  if (GetMTRegistryLongValue(disableCompression, REG_BRANCH_METRACONNECT, REG_VALUE_DISABLE_MSIX_COMPRESSION))
		return (disableCompression == 0) ? true : false;

	return true;
}

void SetNameSpace(std::string & arDir)
{
	// stubbed out -- obolete functionality
}

static
BOOL
GetMTRegistryValue(std::string & arDir, wchar_t * achrBranch, wchar_t * achrValue, bool abTrailingSlash)
{
	NTRegistryIO registry;
	BYTE buffer[1024];
	DWORD size = sizeof(buffer);
	BYTE * pBuffer = buffer;

	if (arDir.length() != 0)
	{
		// FIXME used to update MTNameSpace here and return; leaving the return in just
		// in case anything depends on not updating arDir if it is initially non-empty
		return TRUE;
	}

	if (!registry.OpenRegistryRaw(NTRegistryIO::LOCAL_MACHINE,
																achrBranch, RegistryIO::READ_ACCESS))
		return FALSE;


	if (!registry.ReadRegistryValue(achrValue, RegistryIO::STRING,
																	pBuffer, size))
		return FALSE;
  
  registry.CloseRegistry() ;

  _bstr_t bstrDir ;
  
  bstrDir = (_TCHAR *) pBuffer;

	arDir = (const char *) bstrDir ;
	if (arDir.length() == 0)
		return FALSE;

	if (abTrailingSlash && arDir[arDir.length() - 1] != '\\')
		arDir += '\\';

	return TRUE;
}


static
BOOL
GetMTRegistryLongValue(long & arVal, wchar_t * achrBranch, wchar_t * achrValue)
{
	NTRegistryIO registry;
	BYTE buffer[1024];
	DWORD size = sizeof(buffer);
	BYTE * pBuffer = buffer;

	if (!registry.OpenRegistryRaw(NTRegistryIO::LOCAL_MACHINE,
																achrBranch, RegistryIO::READ_ACCESS))
		return FALSE;


  memset (buffer, 0, sizeof(pBuffer)) ;
	if (!registry.ReadRegistryValue(achrValue, RegistryIO::ULONG,
																	pBuffer, size))
		return FALSE;

	DWORD val;
  memcpy ((void *) &val, pBuffer, size) ;
  
  registry.CloseRegistry() ;

	arVal = (long)val;

	return TRUE;
}
