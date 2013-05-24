/**************************************************************************
 * @doc INFINITE
 *
 * @module |
 *
 *
 * Copyright 1999 by MetraTech Corporation
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
 * @index | INFINITE
 ***************************************************************************/

#ifndef _INFINITE_H
#define _INFINITE_H

class InfiniteBuffer
{
public:
	InfiniteBuffer();
	virtual ~InfiniteBuffer();

	// default arg is a 10 meg max buffer
	BOOL Setup(int aInitialPages, int aMaxPages = 2560);

	BOOL Clear();

	int GetMaxPages() const
	{ return mMaxPages; }

	int GetMaxBufferSize() const
	{ return GetMaxPages() * GetPageSize(); }

	int GetCurrentPages() const
	{ return mPages; }

	int GetCurrentBufferSize() const
	{ return GetCurrentPages() * GetPageSize(); }
	
	unsigned char * GetBase()
	{ return mpBase; }


	static int __cdecl PageFaultExceptionFilter(InfiniteBuffer * apBuffer, DWORD dwCode);

private:
	void AddPage();

	static int GetPageSize();

	unsigned char * GetNextPage() const
	{ return mpNextPage; }

private:
	int mPages;
	int mMaxPages;
	unsigned char * mpNextPage;
	unsigned char * mpBase;

private:
	static int mPageSize;
};


#endif /* _INFINITE_H */
