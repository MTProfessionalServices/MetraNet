/**************************************************************************
 * @doc BATCHSUPPORT
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 * @index | BATCHSUPPORT
 ***************************************************************************/

#ifndef _BATCHSUPPORT_H
#define _BATCHSUPPORT_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include <pipemessages.h>


// wrapper around MTMSIXMessageHeader that encapsulates most of the functionality
class MTMSIXMessageHelper : private MTMSIXMessageHeader
{
public:
	// verify the signature in the data and return a Helper object if it matches
	static MTMSIXMessageHelper * VerifyHeader(const unsigned char * apMessage)
	{ 
		MTMSIXMessageHelper * header = (MTMSIXMessageHelper *) apMessage;
		if (header->mMagic != MTMSIXMessageHeader::MAGIC)
			return NULL;
		else
			return header;
	}

	long GetOriginalSize() const
	{ return mOriginalSize; }

	long GetCompressedSize() const
	{ return mCompressedSize; }

	long GetEncryptedSize() const
	{ return mEncryptedSize; }

	// total size of the message (the header and the data)
	long GetMessageSize() const
	{ return mHeaderSize + mCompressedSize; }

	// NOTE: these all do the same things but the names
	// make it clear what's intended
	const unsigned char * GetCompressedStream() const
	{ return ((unsigned char *) this) + mHeaderSize; }
	const unsigned char * GetEncryptedStream() const
	{ return ((unsigned char *) this) + mHeaderSize; }
	const unsigned char * GetDataStream() const
	{ return ((unsigned char *) this) + mHeaderSize; }


	// 1 = zlib, 2 = lzo
	int GetCompression() const
	{ return mCompression; }

	BOOL IsEncrypted() const
	{ return mEncrypted; }

	// initialize a message header
	static MTMSIXMessageHelper * InitializeHeader(unsigned char * apBuffer,
																								long aOriginalSize, long aCompressedSize,
																								int aCompression, BOOL aEncrypted)
	{
		MTMSIXMessageHeader * messageHeader = (MTMSIXMessageHeader *) apBuffer;
		messageHeader->mMagic = MAGIC;
		messageHeader->mHeaderSize = sizeof(MTMSIXMessageHeader);
		messageHeader->mOriginalSize = aOriginalSize;
		messageHeader->mCompressedSize = aCompressedSize;
		messageHeader->mCompression = (char) aCompression;
		messageHeader->mEncrypted = (char) aEncrypted;
		return (MTMSIXMessageHelper *) messageHeader;
	}

};

// wrapper around MTMSIXBatchHeader that encapsulates most of the functionality
class MTMSIXBatchHelper : private MTMSIXBatchHeader
{
public:
	// verify the signature in the data and return a Helper object if it matches
	static MTMSIXBatchHelper * VerifyHeader(const unsigned char * apMessage)
	{ 
		MTMSIXBatchHelper * header = (MTMSIXBatchHelper *) apMessage;
		if (header->mMagic != MTMSIXBatchHeader::MAGIC)
			return NULL;
		else
			return header;
	}

	// return TRUE if client requested validation on this batch
	BOOL ValidationRequested() const
	{ return mValidate; }

	// return a read only pointer to the batch's UID
	const unsigned char * GetUID() const
	{ return mBatchUID; }

	// get a pointer to the buffer that holds the UID
	unsigned char * GetUIDBuffer()
	{ return mBatchUID; }

	// copy the batch UID to a buffer
	void CopyUID(unsigned char * apBuffer) const
	{
		memcpy(apBuffer, GetUID(), 16);
	}

	int GetMessageCount() const
	{ return mMessages; }

	// 1 = zlib, 2 = lzo
	int GetCompression() const
	{ return mCompression; }

	BOOL IsEncrypted() const
	{ return mEncrypted; }

	long GetOriginalSize() const
	{ return mOriginalSize; }

	long GetCompressedSize() const
	{ return mCompressedSize; }

	long GetEncryptedSize() const
	{ return mEncryptedSize; }

	void SetOriginalSize(long aOriginalSize)
	{ mOriginalSize = aOriginalSize; }

	void SetCompressedSize(long aCompressedSize)
	{ mCompressedSize = aCompressedSize; }

	// pointer to the first message in the batch
	const MTMSIXMessageHelper * GetFirstMessage() const
	{
		return (const MTMSIXMessageHelper *)
			(((const unsigned char *) this) + mHeaderSize);
	}

	MTMSIXMessageHelper * GetFirstMessage()
	{
		return (MTMSIXMessageHelper *)
			(((unsigned char *) this) + mHeaderSize);
	}

	const unsigned char * GetData() const
	{
		return (((const unsigned char *) this) + mHeaderSize);
	}

	unsigned char * GetData()
	{
		return (((unsigned char *) this) + mHeaderSize);
	}


	// pointer to the next message in the batch
	MTMSIXMessageHelper * GetNextMessage(MTMSIXMessageHelper * apMessage)
	{
		return (MTMSIXMessageHelper *)
			(((unsigned char *) apMessage) + apMessage->GetMessageSize());
	}

	const MTMSIXMessageHelper * GetNextMessage(const MTMSIXMessageHelper * apMessage) const
	{
		return (const MTMSIXMessageHelper *)
			(((const unsigned char *) apMessage) + apMessage->GetMessageSize());
	}

	// intialize a batch header
	static MTMSIXBatchHelper * InitializeHeader(unsigned char * apBuffer, int aMessageCount)
	{
		// initialize the header
		MTMSIXBatchHeader * header = (MTMSIXBatchHeader *) apBuffer;

		header->mMagic = MAGIC;
		header->mHeaderSize = sizeof(MTMSIXBatchHeader);
		header->mMessages = aMessageCount;
		header->mClientVersion = 0;
		header->mCompression = MTMSIX_COMPRESS_NONE;
		header->mEncrypted = FALSE;
		header->mOriginalSize = -1;
		header->mCompressedSize = -1;
		header->mEncryptedSize = -1;
		return (MTMSIXBatchHelper *) header;
	}

	void SetFormatInfo(int aCompression, BOOL aEncrypted,
										 long aOriginalSize, long aCompressedSize,
										 long aEncryptedSize)
	{
		mCompression = aCompression;
		mEncrypted = aEncrypted;
		mOriginalSize = aOriginalSize;
		mCompressedSize = aCompressedSize;
		mEncryptedSize = aEncryptedSize;
	}
};



#endif /* _BATCHSUPPORT_H */
