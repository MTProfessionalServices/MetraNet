/**************************************************************************
 * @doc MTSESSIONSETBASE
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
 * Created by: Boris Boruchovich
 *			   Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"
#include <MSIX.h>
#include <accessgrant.h>
#include <mtglobal_msg.h>
#include <errobj.h>
#include "MTSessionBaseDef.h"
#include "MTSessionSetBaseDef.h"
#include "MTSessionServerBaseDef.h"
#include "MTVariantSessionEnumBase.h"

/********************************** construction/destruction ***/
CMTSessionSetBase::CMTSessionSetBase()
	: mpMappedView(NULL),
	  mpSet(NULL),
	  mpHeader(NULL)
{
}
CMTSessionSetBase::CMTSessionSetBase(long lSetHandle)
	: mpMappedView(NULL),
	  mpSet(NULL),
	  mpHeader(NULL)
{
	CMTSessionSetBase* pTmp = (CMTSessionSetBase*) lSetHandle;
	if (!pTmp)
		throw MTException("Inavlid Session Set handle");

	SetServer(pTmp->mServer);

	//------
	// This is necessary since the mpHeader is static and may not come accross in this
	// constructor.
	//------
	if (mServer)
		mServer->SetSharedHeader(pTmp->mpHeader);

	//-----
	SetSharedInfo(pTmp->mpMappedView, pTmp->mpHeader, pTmp->mpSet);
}
CMTSessionSetBase::~CMTSessionSetBase()
{
	MT_ASSERT_LOCK_ACCESS()

	//----- Release the shared object
	if (mpSet)
	{
		mpSet->Release(mpHeader);
		mpSet = NULL;
	}

	if (mServer)
	{
		mServer->Release();
		mServer = NULL;
	}
}

void CMTSessionSetBase::SetServer(CMTSessionServerBase * apServer)
{
	apServer->AddRef();
	mServer = apServer;
}

/****************************************** shared mem usage ***/
void CMTSessionSetBase::SetSharedInfo(MappedViewHandle * apHandle,
									  SharedSessionHeader * apHeader,
									  SharedSet * apSet)
{
	mpMappedView = apHandle;

	MT_ASSERT_LOCK_ACCESS()

	mpHeader = apHeader;

	//----- Release an existing set if there is one
	if (mpSet)
		mpSet->Release(mpHeader);
	mpSet = apSet;

	//----- Important - we must addref on the SharedSet when we get it
	//----- and release after we're done with it.
	apSet->AddRef();
}

/*************************************** session set methods ***/

// ----------------------------------------------------------------
// Description: Add a session to the set.
// Arguments: sessionid - Session ID of the session to add.
//            serviceid - Service ID of the session to add.
// ----------------------------------------------------------------
void CMTSessionSetBase::AddSession(long aSessionId, long aServiceId)
{
	MT_LOCK_ACCESS()
	const SharedSetNode * node = mpSet->AddToSet(mpHeader, aSessionId);
	
  if (!node)
    throw MTException("Unable to add session to set");

	if (node && node->GetID() != aSessionId)
		throw MTException("Node and Session ID's do not match");

	// node->mServiceID = aServiceId;
}

// ----------------------------------------------------------------
// Description: Returns the session set ID.  This ID is an internal ID used
//              by the Pipeline and is not related to any UID.
// Return Value: the ID of the session set.
// ----------------------------------------------------------------
long CMTSessionSetBase::get_ID()
{
	MT_LOCK_ACCESS()
	return mpSet->GetSetID(mpHeader);
}

long CMTSessionSetBase::IncreaseSharedRefCount()
{
	MT_LOCK_ACCESS()
	return mpSet->AddRef();
}

long  CMTSessionSetBase::DecreaseSharedRefCount()
{
	MT_LOCK_ACCESS()
	return mpSet->Release(mpHeader);
}

const unsigned char* CMTSessionSetBase::get_UID(/*[out]*/ unsigned char apUid[])
{
	MT_LOCK_ACCESS()

	const unsigned char * uid = mpSet->GetUID();
	if (uid)
		memcpy(apUid, uid, SharedSession::UID_LENGTH);
	else
		memset(apUid, 0x00, 16);

	return apUid;
}

void CMTSessionSetBase::SetUID(/*[int]*/ unsigned char apUid[])
{
	MT_LOCK_ACCESS()
	mpSet->SetUID(apUid);
}

std::string CMTSessionSetBase::get_UIDAsString()
{
	MT_LOCK_ACCESS()

	//----- Encode it to ASCII
	string asciiUID;
	const unsigned char* uid = mpSet->GetUID();
	if (uid)
		MSIXUidGenerator::Encode(asciiUID, uid);

	//----- Shouldn't be called on sets with no UID
	else throw MTException("get_UIDAsString should not be called on sets with no UID");

	return asciiUID;
}

CMTVariantSessionEnumBase* CMTSessionSetBase::get__NewEnum()
{
	MT_LOCK_ACCESS()

	std::auto_ptr<CMTVariantSessionEnumBase> en(new CMTVariantSessionEnumBase);
	if (!en.get())
		throw MTException("Memory allocation failure!", PIPE_ERR_SHARED_OBJECT_FAILURE);

	//----- SetSharedInfo will do an addref on the shared set object
	en->SetSharedInfo(mpMappedView, mpHeader, mpSet);
	en->SetServer(mServer);
	return en.release();
}

long CMTSessionSetBase::get_Count()
{
	MT_LOCK_ACCESS()
	return mpSet->GetCount();
}

//-- EOF --
