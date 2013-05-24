/**************************************************************************
* Copyright 1997-2000 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

#include <metra.h>
#include <stdutils.h>
#include <global.h>
#include <mtmd5.h>


BOOL ConvertStringToMD5 (const char* apString, string& arHash)
{
	char GeneratedChecksum[MT_MD5_DIGEST_LENGTH * 2 + 1];
	MT_MD5_CTX MD5Context;

	// Initialize MD5
	MT_MD5_Init(&MD5Context);

	// update
	MT_MD5_Update(&MD5Context, (unsigned char*) apString, strlen((char*)apString));

	// 128 bits as 16 x 8 bit bytes.
	unsigned char rawDigest[MT_MD5_DIGEST_LENGTH];

	// final
	MT_MD5_Final(rawDigest, &MD5Context);

	// Convert from 16 x 8 bits to 32 hex characters.
	for(int count = 0; count < MT_MD5_DIGEST_LENGTH; count++)
	{
	    sprintf( &GeneratedChecksum[count*2], "%02x", rawDigest[count] );
  }

	// set arHash
	arHash = GeneratedChecksum;
	return TRUE;
}

