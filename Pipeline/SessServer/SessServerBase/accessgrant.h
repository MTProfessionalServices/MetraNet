/**************************************************************************
 * @doc ACCESSGRANT
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
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
 * @index | ACCESSGRANT
 ***************************************************************************/

#ifndef _ACCESSGRANT_H
#define _ACCESSGRANT_H

#include <sharedsess.h>

#include <errobj.h>

//#define USE_SHARED_ACCESS_MUTEX

class SharedAccess : public virtual ObjectWithError
{
public:
	SharedAccess(MappedViewHandle * apHandle)
		: mpHandle(apHandle), mAccessGranted(FALSE)
	{
		mAccessGranted = GainAccess();
	}

	~SharedAccess()
	{
		if (mAccessGranted)
			mpHandle->ReleaseAccess();
	}

	BOOL operator()()
	{ return mAccessGranted; }

private:
	BOOL GainAccess();

	BOOL mAccessGranted;
	MappedViewHandle * mpHandle;
};

#ifdef USE_SHARED_ACCESS_MUTEX

#define MT_LOCK_ACCESS()												\
	SharedAccess access(GetViewHandle());					\
	if (!access())																\
		return access.GetLastError()->GetCode();

#define MT_ASSERT_LOCK_ACCESS()									\
	SharedAccess access(GetViewHandle());					\
	if (!access())																\
		ASSERT(0);

#else

#define MT_LOCK_ACCESS()
#define MT_ASSERT_LOCK_ACCESS()

#endif

#endif /* _ACCESSGRANT_H */
