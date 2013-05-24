/**************************************************************************
 * MCOBJECTOWNER
 *
 * Copyright 2004 by MetraTech Corp.
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
 * Created by: Boris Boruchovich
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"

//----- Managed headers
#include "MCObjectOwner.h"

//----- Managed Session Server namespace.
namespace MetraTech
{
	namespace Pipeline
	{
		ObjectOwner::ObjectOwner()
			:	mpUnmanagedObjectOwner(NULL)
		{
		}

		ObjectOwner::~ObjectOwner()
		{
			if (mpUnmanagedObjectOwner)
			{
				delete mpUnmanagedObjectOwner;
				mpUnmanagedObjectOwner = NULL;
			}
		}

		bool ObjectOwner::DecrementWaitingCount()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedObjectOwner->DecrementWaitingCount();
			END_TRY_UNMANAGED_BLOCK()
		}

		int ObjectOwner::IncreaseSharedRefCount()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedObjectOwner->IncreaseSharedRefCount();
			END_TRY_UNMANAGED_BLOCK()
		}

		int ObjectOwner::DecreaseSharedRefCount()
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			return mpUnmanagedObjectOwner->DecreaseSharedRefCount();
			END_TRY_UNMANAGED_BLOCK()
		}

		void ObjectOwner::InitForNotifyStage(int aTotalCount, int aOwnerStage)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedObjectOwner->InitForNotifyStage(aTotalCount, aOwnerStage);
			END_TRY_UNMANAGED_BLOCK()
		}

		void ObjectOwner::InitForSendFeedback(int aTotalCount, int aSessionSetID)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedObjectOwner->InitForSendFeedback(aTotalCount, aSessionSetID);
			END_TRY_UNMANAGED_BLOCK()
		}

		void ObjectOwner::InitForCompleteProcessing(int aTotalCount, int aSessionSetID)
		{
			BEGIN_TRY_UNMANAGED_BLOCK()
			mpUnmanagedObjectOwner->InitForCompleteProcessing(aTotalCount, aSessionSetID);
			END_TRY_UNMANAGED_BLOCK()
		}
	};
};

//-- EOF --