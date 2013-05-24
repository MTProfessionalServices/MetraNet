/**************************************************************************
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
 * Created by: Carl Shimer
 * $Header$
 *
 ***************************************************************************/


#ifndef __BUFFERWRITER_H__
#define __BUFFERWRITER_H__

///////////////////////////////////////////////////////////////////////////////
//MTMemBuffer
//
// provides growable buffer
///////////////////////////////////////////////////////////////////////////////

class MTMemBuffer

{
public: 	// ctors, dtors
	MTMemBuffer ()
		: mpData(NULL), mLength(0), mSize(0), mPrettyPrint(FALSE)
	{
		resize(512 * 1024);
	}

	~MTMemBuffer () 
	{
		if (mpData) delete [] mpData;
	}
public: // operators
	operator const char*() const {return mpData;}

	void GetData(const char * * apBuffer, int & arLength) const
	{
		*apBuffer = mpData;
		arLength = mLength;
	}

public:
	void SetPrettyPrint(BOOL aPrettyPrint)
	{
		mPrettyPrint = aPrettyPrint;
	}

	void resize(size_t N) 
	{
		if (N > mSize)
		{
			char * pTemp = mpData;
			mpData = (char *) new char[N];
			///memset ((void *)mpData, ' ', N);
			memcpy ((void *)mpData, (void *)pTemp, mSize);
			mSize = N;
			delete [] pTemp;
		}
	}


public: // implementation of base clase
	
	void append (const char * pData, size_t len)
	{
		if ((len + mLength + 1) > mSize)
			resize (mSize * 2);
		memcpy ((void *)(mpData + mLength), pData, len);
		mLength += len;
		*(mpData + mLength)= '\0';
	}

	void append (const char * pData)
	{
		append (pData, strlen(pData));
	}
	
	void append (const char c) 
	{
		append ((char *)&c, 1);
	}

	void append (const string & arString) 
	{
		append (arString.c_str(), arString.length());
	}

	void append	(const char c, size_t rep) 
	{
		for (size_t count=rep; count; count--) append (c);
	}
	

	void AppendNewLine()
	{
		if (mPrettyPrint)
		{
#ifdef _WIN32
			append("\n");				
#else
			append('\n');
#endif
		}
	}

	void OutputSpaces(int NumSpaces)
	{
		if (mPrettyPrint)
		{
			for(int i=0;i<NumSpaces;i++) {
				append(' ');
			}
		}
	}

private:
	char *	mpData;
	size_t	mLength;
	size_t	mSize;
	BOOL mPrettyPrint;
};

#endif //__BUFFERWRITER_H__
