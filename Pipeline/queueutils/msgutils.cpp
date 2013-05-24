/**************************************************************************
 * MSGUTILS
 *
 * Copyright 1997-2002 by MetraTech Corp.
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
 * $Date: 10/9/2002 5:22:58 PM$
 * $Author: Derek Young$
 * $Revision: 5$
 ***************************************************************************/


#include <metra.h>
#include <msgutils.h>
#include <pipemessages.h>
#include <batchsupport.h>
#include <mtglobal_msg.h>
#include <mtzlib.h>

PipelineMessageUtils::PipelineMessageUtils()
	: mCryptoInitialized(FALSE)
{ }

BOOL PipelineMessageUtils::Init(const char * apContainerName,
																const char * apSource)
{
	mContainerName = apContainerName;
	mSource = apSource;
	mCryptoInitialized = FALSE;
	return TRUE;
}

BOOL PipelineMessageUtils::InitializeCrypto()
{
	const char * functionName = "PipelineMessageUtils::InitializeCrypto";

	if (mCryptoInitialized)
		return TRUE;

	int result = mCrypto.CreateKeys(mContainerName,
																	TRUE,
																	mSource);
	if (result == 0)
		result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_ServiceDefProp, mContainerName, TRUE, mSource);

	if (result != 0)
	{
//		mLogger.LogVarArgs(LOG_ERROR,
//											 "Unable to initialize crypto functions: %x: %s",
//											 result,
//											 CMTCryptoAPI::GetCryptoApiErrorString());
		// NOTE: this "result" code is not very useful so override it
		// with the crypto specific code
		SetError(CORE_ERR_CRYPTO_FAILURE, ERROR_MODULE, ERROR_LINE, functionName,
						 mCrypto.GetCryptoApiErrorString());
		return FALSE;
	}
	return TRUE;
}

// possibly decrypt and/or decompress a stream of data
BOOL PipelineMessageUtils::DecodeStream(MTMSIXBatchHelper * apBatch,
																				unsigned char * * apBuffer,
																				BOOL & arDeleteBuffer)
{
	const char * functionName = "PipelineObjectGenerator::DecodeStream";

	arDeleteBuffer = FALSE;
	*apBuffer = apBatch->GetData();

	// first decrypt
	if (apBatch->IsEncrypted())
	{
		if (!InitializeCrypto())
			return FALSE;

		// the batch can be decrypted in place so we don't need to allocate a new
		// buffer
		long dataLen = apBatch->GetEncryptedSize();
		char * data = (char *) *apBuffer;
		int result = mCrypto.Decrypt(data, &dataLen);
		if (result != 0)
		{
			SetError(HRESULT_FROM_WIN32(result), ERROR_MODULE, ERROR_LINE, functionName,
							 "unable to decrypt message");
			return FALSE;
		}

		arDeleteBuffer = FALSE;
	}

	// decompress
	if (apBatch->GetCompression() != MTMSIX_COMPRESS_NONE)
	{
		// create the buffer to hold the output
		unsigned char * decompressed = new unsigned char[apBatch->GetOriginalSize() + 1];

		unsigned char * dest = decompressed;
		unsigned long destLen = apBatch->GetOriginalSize();
		const unsigned char * compressed = *apBuffer;
		unsigned long compressedSize = apBatch->GetCompressedSize();

		BOOL decompressSuccess;
		int ret;
		switch (apBatch->GetCompression())
		{
		case MTMSIX_COMPRESS_NONE:
			// zlib compression
			memcpy(dest, compressed, compressedSize);
			destLen = compressedSize;		// no compression so the size remains the same
			decompressSuccess = TRUE;
			break;

		case MTMSIX_COMPRESS_ZLIB:
			// zlib compression
			ret = MTZLib::Uncompress(dest, &destLen, compressed, compressedSize);
			decompressSuccess = (ret == Z_OK);
			break;

		default:
			ASSERT(0);
		}

		if (!decompressSuccess)
		{
			// TODO: use a better error?
			SetError(MT_ERR_PARSE_ERROR, ERROR_MODULE, ERROR_LINE, functionName);

			delete [] decompressed;
			return FALSE;
		}

		*apBuffer = decompressed;
		arDeleteBuffer = TRUE;
	}

	return TRUE;
}


BOOL PipelineMessageUtils::EncodeMessage(
	const char * apXMLMessage,
	MTMSIXBatchHelper * * apNewBatch,
	long * apNewBatchLen,
	BOOL aCompress,
	BOOL aEncrypt)
{
	ASSERT(aCompress || aEncrypt);

	int originalSize = strlen(apXMLMessage);

	unsigned char * buffer =
		new unsigned char[originalSize + sizeof(MTMSIXMessageHelper)];

	MTMSIXMessageHelper * messageHeader =
		MTMSIXMessageHelper::InitializeHeader(buffer,
																					originalSize, // original size
																					originalSize, // compressed size
																					MTMSIX_COMPRESS_NONE,
																					FALSE);	// not encrypted

	unsigned char * destination = buffer + sizeof(MTMSIXMessageHeader);
	memcpy(destination, apXMLMessage, originalSize);

	vector<MTMSIXMessageHelper *> messages;
	messages.push_back(messageHeader);

	BOOL success = EncodeMessages(messages, apNewBatch, apNewBatchLen,
																aCompress, aEncrypt);
	delete [] buffer;
	return success;
}


BOOL PipelineMessageUtils::EncodeMessages(
	vector<MTMSIXMessageHelper *> & arMessages,
	MTMSIXBatchHelper * * apNewBatch,
	long * apNewBatchLen,
	BOOL aCompress,
	BOOL aEncrypt)
{
	const char * functionName = "MeterHandler::CompressMessages";

	ASSERT(aCompress || aEncrypt);

	long payloadLen = 0;
	unsigned char * payload;

	unsigned char * newBatchBuffer = NULL;

	long messagesSize = 0;
	int i;
	for (i = 0; i < (int) arMessages.size(); i++)
		messagesSize += arMessages[i]->GetMessageSize();

	// memory for the original data
	unsigned char * source = new unsigned char[messagesSize];

	unsigned char * pointer = source;

	// copy all the uncompressed messages in
	for (i = 0; i < (int) arMessages.size(); i++)
	{
		memcpy(pointer, arMessages[i], arMessages[i]->GetMessageSize());
		pointer += arMessages[i]->GetMessageSize();
	}

	payload = source;
	payloadLen = messagesSize;

	unsigned long compressedLen;
	if (aCompress)
	{
		unsigned char * uncompressed = payload;

		// memory for the uncompressed data
		compressedLen = MTZLib::RecommendCompressedBufferSize(messagesSize);
		// leave room for the header and the compressed messages
		newBatchBuffer = new unsigned char[sizeof(MTMSIXBatchHeader) + compressedLen];
		payload = newBatchBuffer + sizeof(MTMSIXBatchHeader);


		int originalSize = payloadLen;
		int ret = MTZLib::Compress(payload, &compressedLen, uncompressed, originalSize);

		// clear the source data
		delete [] uncompressed;

		if (ret != Z_OK)
		{
			// this should never happen
			SetError(PIPE_ERR_INTERNAL_ERROR, ERROR_MODULE, ERROR_LINE,
							 functionName);
			// TODO: this could cause leaks
			return FALSE;
		}

		payloadLen = compressedLen;
	}
	else
		compressedLen = -1;

	BOOL encrypt = aEncrypt;
	long encryptedLen;
	if (encrypt)
	{
		if (!InitializeCrypto())
			return FALSE;

		int cleartextLen = payloadLen;
		encryptedLen = cleartextLen;

		// figure out what the length of the encrypted data will be
		int result = mCrypto.Encrypt(NULL, &encryptedLen, cleartextLen);
		if (result != 0)
		{
//			mLogger.LogVarArgs(LOG_ERROR,
//												 "Unable to determine encrypted buffer length: %x: %s",
//												 result,
//												 mCrypto.GetCryptoApiErrorString());
			SetError(HRESULT_FROM_WIN32(result), ERROR_MODULE, ERROR_LINE, functionName,
							 mCrypto.GetCryptoApiErrorString());
			return FALSE;
		}

		unsigned char * buffer =
			new unsigned char[encryptedLen + sizeof(MTMSIXBatchHeader)];
		unsigned char * data = buffer + sizeof(MTMSIXBatchHeader);

		// the encryption API encrypts in place - copy the data into the buffer before
		// encrypting
		memcpy(data, payload, payloadLen);

		long dataLen = cleartextLen;
		result = mCrypto.Encrypt((char *) data, &dataLen, encryptedLen);

		ASSERT(encryptedLen == dataLen);

		delete [] newBatchBuffer;
		newBatchBuffer = buffer;

		if (result != 0)
		{
//			mLogger.LogVarArgs(LOG_ERROR,
//												 "Unable to encrypt message: %x: %s",
//												 result,
//												 mCrypto.GetCryptoApiErrorString());
			SetError(HRESULT_FROM_WIN32(result), ERROR_MODULE, ERROR_LINE, functionName,
							 mCrypto.GetCryptoApiErrorString());
			return FALSE;
		}

		payloadLen = encryptedLen;
	}
	else
		encryptedLen = -1;

	MTMSIXBatchHelper * newBatch = MTMSIXBatchHelper::InitializeHeader(newBatchBuffer,
																																		 arMessages.size());

	int compressionType;
	if (aCompress)
		compressionType = MTMSIX_COMPRESS_ZLIB;
	else
		compressionType = MTMSIX_COMPRESS_NONE;

	newBatch->SetFormatInfo(compressionType,	// compression
													encrypt, // encrypted
													messagesSize,	// original size
													compressedLen, // compressed size
													encryptedLen); // encrypted size

	*apNewBatch = newBatch;
	*apNewBatchLen = sizeof(MTMSIXBatchHeader) + payloadLen;
	return TRUE;
}
