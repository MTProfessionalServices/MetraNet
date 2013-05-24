/**************************************************************************
 * @doc MSGUTILS
 *
 * @module |
 *
 *
 * Copyright 2002 by MetraTech Corporation
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | MSGUTILS
 ***************************************************************************/

#ifndef _MSGUTILS_H
#define _MSGUTILS_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include <mtcryptoapi.h>
#include <errobj.h>
#include <vector>

using std::vector;

class MTMSIXBatchHelper;
class MTMSIXMessageHelper;

class PipelineMessageUtils : public ObjectWithError
{
public:
	PipelineMessageUtils();

	BOOL Init(const char * apContainerName,
						const char * apSource);

	// possibly decrypt and/or decompress a stream of data
	// set *apBuffer to the pointer to the decompressed/decrypted stream.
	// if arDeleteBuffer is set to true, this buffer must be deleted after use.
	BOOL DecodeStream(MTMSIXBatchHelper * apBatch,
										unsigned char * * apBuffer,
										BOOL & arDeleteBuffer);

	// encrypt and or compress an XML stream.
	// apNewBatch must be deleted like
	//   			delete [] (unsigned char *) newBatch
	BOOL EncodeMessage(
		const char * apXMLMessage,
		MTMSIXBatchHelper * * apNewBatch,
		long * apNewBatchLen,
		BOOL aCompress,
		BOOL aEncrypt);

	// encrypt and or compress a group of XML stream.
	// apNewBatch must be deleted like
	//   			delete [] (unsigned char *) newBatch
	BOOL EncodeMessages(
		vector<MTMSIXMessageHelper *> & arMessages,
		MTMSIXBatchHelper * * apNewBatch,
		long * apNewBatchLen,
		BOOL aCompress,
		BOOL aEncrypt);

private:
	BOOL InitializeCrypto();

private:
  CMTCryptoAPI mCrypto;

	std::string mContainerName;
	std::string mSource;
	BOOL mCryptoInitialized;
};


#endif /* _MSGUTILS_H */
