/**************************************************************************
 * @doc CRC32
 *
 * Copyright 1998 by MetraTech Corporation
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
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include "installutil.h"
#include <autoinstance.h>
#include <MTUtil.h>
#include <global.h>
#include <mtmd5.h>

extern MTAutoInstance<InstallLogger> g_Logger;

#define PAGE_SIZE 0x1000

string PerformChecksum(HANDLE hFile)
{
  char buffer[PAGE_SIZE];
  MT_MD5_CTX MD5Context;
	char GeneratedChecksum[MT_MD5_DIGEST_LENGTH * 2 + 1];
	unsigned char rawDigest[MT_MD5_DIGEST_LENGTH];

	MT_MD5_Init(&MD5Context);
	memset(&buffer,PAGE_SIZE,0);

  DWORD aBytesRead=0;
	
  while(ReadFile(hFile,(void*)&buffer,PAGE_SIZE,&aBytesRead,NULL) != 0 
    && aBytesRead != 0) {

		MT_MD5_Update(&MD5Context, (unsigned char*) buffer, aBytesRead);

  }

	MT_MD5_Final(rawDigest, &MD5Context);

		// Convert from 16 x 8 bits to 32 hex characters.
	for(int count = 0; count < (MT_MD5_DIGEST_LENGTH); count++)
	{
		sprintf( &GeneratedChecksum[count*2], "%02x", rawDigest[count] );
  }

	
	string aHash = GeneratedChecksum;
	return aHash;
}

// Function name	: PerformChecksumOnFiles
// Description	    : 
// Return type		: 
// Argument         : LPSTR NewFile
// Argument         : LPSTR OldFile
BOOL InstCallConvention PerformChecksumOnFiles(LPSTR NewFile,LPSTR OldFile)
{
	HANDLE hOrigFile, hNewFile;
	BOOL bRetVal(FALSE);
	// step 1: open original file

	do {
		hOrigFile = ::CreateFile(OldFile,
			GENERIC_READ,
			FILE_SHARE_READ,
			NULL,
			OPEN_EXISTING,
			FILE_ATTRIBUTE_NORMAL,
			NULL);

		if(hOrigFile == INVALID_HANDLE_VALUE) {
			g_Logger->LogVarArgs(LOG_ERROR,"Failed to open file %s",NewFile); 
			break;
		}

		// step 2: open new file
		hNewFile = ::CreateFile(NewFile,
			GENERIC_READ,
			FILE_SHARE_READ,
			NULL,
			OPEN_EXISTING,
			FILE_ATTRIBUTE_NORMAL,
			NULL);

		if(hNewFile == INVALID_HANDLE_VALUE) {
			g_Logger->LogVarArgs(LOG_ERROR,"Failed to open file %s",OldFile); 
			break;
		}
		// step 3: perform CRC on original file
    string Orighash = PerformChecksum(hOrigFile);
		::CloseHandle(hOrigFile);
		// step 4: perform CRC on new file
    string aNewHash = PerformChecksum(hNewFile);
		::CloseHandle(hNewFile);

		// step 5: compare results
		bRetVal = Orighash == aNewHash;

	} while(false);

	return bRetVal;
}

BOOL InstCallConvention ComputeChecksumOnFile(const char* pFileName,char* pHash,long aLen)
{
	BOOL bRetVal = TRUE;
	HANDLE hOrigFile;
	ASSERT(pHash && pFileName && aLen > 0);
	if(!(pHash && pFileName && aLen > 0)) return FALSE;

		do {
			hOrigFile = ::CreateFile(pFileName,
			GENERIC_READ,
			FILE_SHARE_READ,
			NULL,
			OPEN_EXISTING,
			FILE_ATTRIBUTE_NORMAL,
			NULL);

		if(hOrigFile == INVALID_HANDLE_VALUE) {
			bRetVal = FALSE;
			break;
		}

		string Orighash = PerformChecksum(hOrigFile);
		strncpy(pHash,Orighash.c_str(),MT_MD5_DIGEST_LENGTH);
		pHash[MT_MD5_DIGEST_LENGTH] = '\0';
		::CloseHandle(hOrigFile);

	}
	while(false);
	return bRetVal;
}
