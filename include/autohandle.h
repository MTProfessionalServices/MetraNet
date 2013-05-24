/**************************************************************************
 * @doc AUTOHANDLE
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
 * @index | AUTOHANDLE
 ***************************************************************************/

#ifndef _AUTOHANDLE_H
#define _AUTOHANDLE_H

class AutoHANDLE
{
public:
	AutoHANDLE() : mHandle(NULL)
	{ }

	~AutoHANDLE()
	{
		if (mHandle)
		{
			BOOL res = ::CloseHandle(mHandle);
			ASSERT(res);
			mHandle = NULL;
		}
	}

	operator HANDLE () const
	{ return mHandle; }

	AutoHANDLE & operator = (HANDLE aHandle)
	{ return mHandle = aHandle, *this; }

private:
	// copying not allowed
	AutoHANDLE(const AutoHANDLE &);

private:
	HANDLE mHandle;
};

#endif /* _AUTOHANDLE_H */
