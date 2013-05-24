/**************************************************************************
 * @doc SESSIONITERATE
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
 * @index | SESSIONITERATE
 ***************************************************************************/

#ifndef _SESSIONITERATE_H
#define _SESSIONITERATE_H


#include <SetIterate.h>

typedef SetIterator<MTPipelineLib::IMTSessionSetPtr,
																	 MTPipelineLib::IMTSessionPtr> PrivateSessionIterator;

class SessionIterator
	: public PrivateSessionIterator
{
public:
	SessionIterator()
		: mServiceID(-1)
	{ }

	inline HRESULT Init(MTPipelineLib::IMTSessionSetPtr aSet, int aServiceID);

	virtual inline MTPipelineLib::IMTSessionPtr GetNext();

	int mServiceID;
};

HRESULT
SessionIterator::Init(MTPipelineLib::IMTSessionSetPtr aSet, int aServiceID)
{
	mServiceID = aServiceID;
	return PrivateSessionIterator::Init(aSet);
}


MTPipelineLib::IMTSessionPtr
SessionIterator::GetNext()
{
	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = PrivateSessionIterator::GetNext();
		if (session == NULL)
			return NULL;

		// -1 allows any type of session to pass through
		if (mServiceID == -1 || session->GetServiceID() == mServiceID)
			return session;
	}

	// never reached
	ASSERT(0);
	return NULL;
}


#endif /* _SESSIONITERATE_H */
