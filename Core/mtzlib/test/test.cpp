/**************************************************************************
 * TEST
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

#include <metra.h>
#include <mtzlib.h>
#include <errobj.h>
#include <pipemessages.h>
#include <perf.h>

#include <lzo1x.h>

#include <stdio.h>
#include <iostream>
using std::cout;
using std::endl;
using std::hex;
using std::dec;

struct MTCompressHeader
{
	DWORD mMagic;								// = 0xABCDEFFF
	DWORD mHeaderSize;					// number of bytes in the header
	DWORD mOriginalSize;				// original size of the data
	DWORD mCompressedSize;			// size of compressed data
};


int CompressTest(const char * apFile1, const char * apFile2, int aCount)
{
	// compression test

	HANDLE fileHandle =
		::CreateFile(apFile1,
								 GENERIC_READ | GENERIC_WRITE,	// access
								 FILE_SHARE_READ | FILE_SHARE_WRITE,	// share
								 NULL,					// security
								 OPEN_EXISTING, // creation distribution
								 FILE_ATTRIBUTE_NORMAL | FILE_FLAG_RANDOM_ACCESS, // flags
								 NULL); // template
	if (fileHandle == (HANDLE)0xFFFFFFFF)
	{
		DWORD err = ::GetLastError();
		cout << "Unable to open file: " << hex << err << dec << endl;
		return err;
	}


	BY_HANDLE_FILE_INFORMATION fileInfo;
	if (!GetFileInformationByHandle(
		fileHandle,									// handle to file 
		&fileInfo)) // buffer
	{
		DWORD err = ::GetLastError();
		cout << "Unable to get file info: " << hex << err << dec << endl;
		return -1;
	}


	HANDLE fileMapping =
		::CreateFileMapping(fileHandle,	// handle to file to map
												NULL,		// optional security attributes
												PAGE_READONLY, // protection
												0, // max size high (assume always 0)
												0,
												NULL);

	if (!fileHandle)
	{
		DWORD err = ::GetLastError();
		cout << "Unable to map file: " << hex << err << dec << endl;
		return -1;
	}

	// map the file into memory
	unsigned char * start = (unsigned char *)
		::MapViewOfFile(fileMapping,	// mapping object
										FILE_MAP_READ, // access mode
										0,			// offset high
										0,			// offset low
										0);		// number of bytes (0 = all)

	if (start == NULL)
	{
		DWORD err = ::GetLastError();
		cout << "Unable to map file: " << hex << err << dec << endl;
		return -1;
	}


	//
	// do the real compression now
	//

	int originalSize = fileInfo.nFileSizeLow;

#if 0
	unsigned char * dest;
	unsigned long destLen = MTZLib::RecommendCompressedBufferSize(originalSize);

	dest = new unsigned char[destLen];

	int ret = MTZLib::Compress(dest, &destLen, start, originalSize);
	if (ret != Z_OK)
	{
		cout << "Unable to compress: " << ret << endl;
		return -1;
	}
#else
	if (lzo_init() != LZO_E_OK)
	{
		printf("lzo_init() failed !!!\n");
		return 4;
	}
	unsigned char * wrkmem = new unsigned char[LZO1X_1_MEM_COMPRESS];


	unsigned char * dest;
// #define OUT_LEN		(IN_LEN + IN_LEN / 64 + 16 + 3)
	unsigned int destLen = originalSize + originalSize / 64 + 16 + 3;
	dest = new unsigned char[destLen];

	int r = lzo1x_1_compress(start,originalSize,dest,&destLen,wrkmem);
	if (r != LZO_E_OK)
	{
		cout << "unable to compress" << endl;
		return -1;
	}
#endif

	cout << "compression ratio: " << (destLen * 100) / originalSize << "%" << endl;

	FILE * out = fopen(apFile2, "wb");
	if (!out)
	{
		perror(apFile2);
		return -1;
	}

	// first write the header structure
#if 1
//	const int repeatCount = 10000;

	MTMSIXBatchHeader header;
	MTMSIXMessageHeader messageHeader;

	header.mMagic = MTMSIXBatchHeader::MAGIC;
	header.mHeaderSize = sizeof(header);
	header.mMessages = aCount;
	header.mClientVersion = 0;
	header.mValidate = FALSE;

	// generate a unique batch ID
	//std::string uidString;
	//MSIXUidGenerator::Generate(uidString);
	//MSIXUidGenerator::Decode(header.mBatchUID, uidString);

	messageHeader.mMagic = MTMSIXMessageHeader::MAGIC;
	messageHeader.mHeaderSize = sizeof(messageHeader);
	messageHeader.mOriginalSize = originalSize;
	messageHeader.mCompressedSize = destLen;
	// 1 = zlib, 2 = lzo
	messageHeader.mCompression = 2;

	// write the master header
	if (fwrite(&header, sizeof(header), 1, out) != 1)
	{
		perror(apFile2);
		return -1;
	}

	for (int i = 0; i < aCount; i++)
	{
		// write the message header
		if (fwrite(&messageHeader, sizeof(messageHeader), 1, out) != 1)
		{
			perror(apFile2);
			return -1;
		}

		// write the data
		if (fwrite(dest, messageHeader.mCompressedSize, 1, out) != 1)
		{
			perror(apFile2);
			return -1;
		}
	}

#else
	MTCompressHeader header;
	header.mMagic = 0xABCDEFFF;
	header.mHeaderSize = sizeof(header);
	header.mOriginalSize = originalSize;
	header.mCompressedSize = destLen;

	// write the header
	if (fwrite(&header, sizeof(header), 1, out) != 1)
	{
		perror(apFile2);
		return -1;
	}

	// write the data
	if (fwrite(dest, header.mCompressedSize, 1, out) != 1)
	{
		perror(apFile2);
		return -1;
	}
#endif

	fclose(out);

	::CloseHandle(fileMapping);
	::CloseHandle(fileHandle);


	return 0;
}


int DecompressionTest(const char * apFile1, const char * apFile2)
{
	// decompression test

	HANDLE fileHandle =
		::CreateFile(apFile1,
								 GENERIC_READ | GENERIC_WRITE,	// access
								 FILE_SHARE_READ | FILE_SHARE_WRITE,	// share
								 NULL,					// security
								 OPEN_EXISTING, // creation distribution
								 FILE_ATTRIBUTE_NORMAL | FILE_FLAG_RANDOM_ACCESS, // flags
								 NULL); // template
	if (fileHandle == (HANDLE)0xFFFFFFFF)
	{
		DWORD err = ::GetLastError();
		cout << "Unable to open file: " << hex << err << dec << endl;
		return err;
	}


	BY_HANDLE_FILE_INFORMATION fileInfo;
	if (!GetFileInformationByHandle(
		fileHandle,									// handle to file 
		&fileInfo)) // buffer
	{
		DWORD err = ::GetLastError();
		cout << "Unable to get file info: " << hex << err << dec << endl;
		return -1;
	}


	HANDLE fileMapping =
		::CreateFileMapping(fileHandle,	// handle to file to map
												NULL,		// optional security attributes
												PAGE_READONLY, // protection
												0, // max size high (assume always 0)
												0,
												NULL);

	if (!fileHandle)
	{
		DWORD err = ::GetLastError();
		cout << "Unable to map file: " << hex << err << dec << endl;
		return -1;
	}

	// map the file into memory
	unsigned char * start = (unsigned char *)
		::MapViewOfFile(fileMapping,	// mapping object
										FILE_MAP_READ, // access mode
										0,			// offset high
										0,			// offset low
										0);		// number of bytes (0 = all)

	if (start == NULL)
	{
		DWORD err = ::GetLastError();
		cout << "Unable to map file: " << hex << err << dec << endl;
		return -1;
	}


	//
	// do the real decompression now
	//

	MTMSIXBatchHeader * batchHeader = (MTMSIXBatchHeader *) start;
	MTMSIXMessageHeader * header;

	header = (MTMSIXMessageHeader *)
		(((unsigned char *) batchHeader) + batchHeader->mHeaderSize);

	unsigned char * dest;
	unsigned long destLen = header->mOriginalSize;

	unsigned char * compressed = ((unsigned char *) header) + 
		header->mHeaderSize;
	unsigned long compressedSize = header->mCompressedSize;

	dest = new unsigned char[destLen];


#if 1
	if (lzo_init() != LZO_E_OK)
	{
		printf("lzo_init() failed !!!\n");
		return 4;
	}
#endif

	long frequency;
	GetPerformanceTickCountFrequency(frequency);

	PerformanceTickCount initialTicks;
	GetCurrentPerformanceTickCount(&initialTicks);

	const int REPEAT_COUNT = 1000;
	for (int i = 0; i < REPEAT_COUNT; i++)
	{
#if 1
		unsigned int lzoDestLen;
		int r = lzo1x_decompress(compressed, compressedSize, dest, &lzoDestLen, NULL);
		if (r != LZO_E_OK)
		{
			cout << "Unable to uncompress: " << endl;
			return -1;
		}
		destLen = lzoDestLen;
#else

		int ret = MTZLib::Uncompress(dest, &destLen, compressed, compressedSize);
		if (ret != Z_OK)
		{
			cout << "Unable to uncompress: " << ret << endl;
			return -1;
		}
#endif
	}

	PerformanceTickCount finalTicks;
	GetCurrentPerformanceTickCount(&finalTicks);
	__int64 ticks = PerformanceCountTicks(&initialTicks, &finalTicks);
	printf("transactions: %d\n", REPEAT_COUNT);
	printf("ticks: %d\n", ticks);
	printf("TPS: %f\n", ((double)(REPEAT_COUNT / ticks) * (double) frequency));


	FILE * out = fopen(apFile2, "wb");
	if (!out)
	{
		perror(apFile2);
		return -1;
	}

	// write the data
	if (fwrite(dest, destLen, 1, out) != 1)
	{
		perror(apFile2);
		return -1;
	}

	fclose(out);

	::CloseHandle(fileMapping);
	::CloseHandle(fileHandle);


	return 0;
}




int main(int argc, char * argv[])
{
	// 0        1  2        3
	// zlibtest -c original output
	// zlibtest -u compressed original

	if (argc < 4)
	{
		cout << "usage:" << endl;
		cout << "zlibtest -c original output [count]" << endl;
		cout << "zlibtest -u compressed original" << endl;
		return 1;
	}

	const char * op = argv[1];
	const char * file1 = argv[2];
	const char * file2 = argv[3];
	int count;
	if (argc > 4)
	{
		const char * countstr = argv[4];
		count = atoi(countstr);
	}
	else
		count = 1;

	if (0 == strcmp(op, "-c"))
		return CompressTest(file1, file2, count);
	else if (0 == strcmp(op, "-u"))
		return DecompressionTest(file1, file2);
				
	return 0;
}
