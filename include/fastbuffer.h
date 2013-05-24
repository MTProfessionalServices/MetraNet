/**************************************************************************
 * @doc FASTBUFFER
 *
 * @module |
 *
 *
 * Copyright 2000 by MetraTech Corporation
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
 *
 * @index | FASTBUFFER
 ***************************************************************************/

#ifndef _FASTBUFFER_H
#define _FASTBUFFER_H

/************************************************ FastBuffer ***/

// buffer designed to be very quick for small values, slower for larger ones
// this class attempts to avoid calls to new and is useful for holding
// names or other strings in objects that are allocated frequently.

template<class T, int N>
class FastBuffer
{
private:
	enum
	{
		UNDEFINED_STORAGE = 0,
		ARRAY_STORAGE = 1,
		HEAP_STORAGE = 2
	};

public:
	// constructors
	FastBuffer() : mStorageType(UNDEFINED_STORAGE)
	{ }

	FastBuffer(const T * apData) : mStorageType(UNDEFINED_STORAGE)
	{ *this = apData; }

	FastBuffer(const FastBuffer<T, N> & arBuffer) : mStorageType(UNDEFINED_STORAGE)
	{ *this = arBuffer.GetBuffer(); }

	// destructor
	~FastBuffer()
	{	
		if (mStorageType == HEAP_STORAGE && mpBuffer)
		{
			delete [] mpBuffer;
			mpBuffer = NULL;
		}
	}

	// set buffer
	void SetBuffer(const T * apData);

	FastBuffer & operator = (const T * apStr)
	{
		SetBuffer(apStr);
		return *this;
	}

	// buffer retrieval
	const T * GetBuffer() const
	{
		switch (mStorageType)
		{
		case ARRAY_STORAGE:
			return mBuffer;
		case HEAP_STORAGE:
			return mpBuffer;
		case UNDEFINED_STORAGE:
			return NULL;
		default:
			ASSERT(0);
		}
		return NULL;
	}

	int BufferSize()
	{
		// size in characters
		return N;
	}

	// allow direct manipulation of the internal buffer
	T * DirectSetup();

	// attach a buffer
	void Attach(T * apBuffer);

private:
	char mStorageType;
	union
	{
		T mBuffer[N];
		T * mpBuffer;
	};

	// strlen implementations for both data types
	static int StrLen(const char * apData)
	{ return strlen(apData); }

	static int StrLen(const wchar_t * apData)
	{ return wcslen(apData); }

	// strcpy implementations for both data types
	static void StrCpy(char * apBuffer, const char * apData)
	{ strcpy(apBuffer, apData); }

	static void StrCpy(wchar_t * apBuffer, const wchar_t * apData)
	{ wcscpy(apBuffer, apData); }
};



template<class T, int N>
void FastBuffer<T, N>::SetBuffer(const T * apData)
{
	ASSERT(apData);

	int len = StrLen(apData);

	if (mStorageType == HEAP_STORAGE)
		delete [] mpBuffer;

	if (StrLen(apData) + 1 > (sizeof(mBuffer) / sizeof(mBuffer[0])))
	{
		mStorageType = HEAP_STORAGE;
		mpBuffer = new T[len + 1];
		StrCpy(mpBuffer, apData);
	}
	else
	{
		mStorageType = ARRAY_STORAGE;
		StrCpy(mBuffer, apData);
	}
}

template<class T, int N>
T * FastBuffer<T, N>::DirectSetup()
{
	if (mStorageType == HEAP_STORAGE)
		delete [] mpBuffer;

	mStorageType = ARRAY_STORAGE;
	return mBuffer;
}

// attach a buffer
template<class T, int N>
void FastBuffer<T, N>::Attach(T * apBuffer)
{
	if (mStorageType == HEAP_STORAGE)
		delete [] mpBuffer;

	mStorageType = HEAP_STORAGE;
	mpBuffer = apBuffer;
}

#endif /* _FASTBUFFER_H */
