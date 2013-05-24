/**************************************************************************
 * MTZLIB
 *
 * Copyright 1997-2001 by MetraTech Corp.
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

#include <mtzlib.h>

int MTZLib::RecommendCompressedBufferSize(int aUncompressedSize)
{
	// 0.1% (.001) larger than source + 12
	// NOTE: tack on an extra 20 bytes for good measure
	return aUncompressedSize + (int) (aUncompressedSize * 0.001) + 12 + 20;
}


int MTZLib::Compress(unsigned char * apDest, unsigned long * apDestLen,
										 const unsigned char * apSource, unsigned long aSourceLen,
										 int aLevel /* = Z_DEFAULT_COMPRESSION */)
{
	return compress2 (apDest, apDestLen, apSource, aSourceLen, aLevel);
}


int MTZLib::Uncompress(unsigned char * apDest, unsigned long * apDestLen,
											 const unsigned char * apSource, unsigned long aSourceLen)
{
	return uncompress (apDest, apDestLen, apSource, aSourceLen);
}
