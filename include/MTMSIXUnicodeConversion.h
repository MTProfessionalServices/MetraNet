#ifndef __UNICODEMSIXCONVERSION_H__
#define __UNICODEMSIXCONVERSION_H__
#pragma once

class MTMSIXUnicodeConversion {

public:
	MTMSIXUnicodeConversion(const char* pOriginalStr,unsigned long aSize = 0,bool bRawUnicodeBytes = false) : 
			mOriginalStr(pOriginalStr), mOriginalSize(aSize),mBufferSize(0),mAllocatedBuffer(NULL),mRawUnicodeBytes(bRawUnicodeBytes)
		{}
	~MTMSIXUnicodeConversion()
	{
		// will work even if NULL
		delete[] mAllocatedBuffer;
	}

	inline bool HasUnicodeMarker()
	{
		// is the opening tag Unicode?
		return (unsigned char)mOriginalStr[0] == 0xFF && (unsigned char)mOriginalStr[1] == 0xFE;
	}

	inline bool IsUnicodeBuffer()
	{
		return mOriginalStr[1] == '\0' && mOriginalStr[3] == '\0';
	}


	inline unsigned long GetBufferSize()
	{ 
		return mAllocatedBuffer != NULL ? mBufferSize : mOriginalSize;
	} 

	inline unsigned long GetOriginalSize() {
		return mRawUnicodeBytes ? mOriginalSize >> 1 : mOriginalSize;
	}

	
	const char* ConvertToASCII();

protected:
	const char* mOriginalStr;
	char* mAllocatedBuffer;
	unsigned long mBufferSize;
	unsigned long mOriginalSize;
	bool mRawUnicodeBytes;
};




#endif //__UNICODEMSIXCONVERSION_H__
