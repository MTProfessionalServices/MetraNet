/**************************************************************************
 * @doc MTSESSION
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
 * Created by:  Derek Young
 *				Boris Boruchovich
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"
#include <accessgrant.h>

#include "MTVariantSessionEnumBase.h"
#include "MTSessionServerBaseDef.h"
#include "MTSessionBaseDef.h"

//----- Construction/destruction
CMTVariantSessionEnumBase::CMTVariantSessionEnumBase()
	:	mpMappedView(NULL),
		mpHeader(NULL),
		mpSet(NULL)
{
}

CMTVariantSessionEnumBase::~CMTVariantSessionEnumBase()
{
	//----- Have to release the reference to the shared object
	if (mpSet)
	{
		mpSet->Release(mpHeader);
		mpSet = NULL;
	}
}


void CMTVariantSessionEnumBase::SetServer(CMTSessionServerBase * apServer)
{
	// TODO: do we need to addref?
	mServer = apServer;
}

//----- Shared mem usage
void CMTVariantSessionEnumBase::SetSharedInfo(MappedViewHandle * apHandle,
											  SharedSessionHeader * apHeader,
											  SharedSet * apSet)
{
	mpMappedView = apHandle;

	MT_ASSERT_LOCK_ACCESS()

	mpHeader = apHeader;

	//----- Important to addref and release this shared object
	if (mpSet)
		mpSet->Release(mpHeader);

	mpSet = apSet;
	mpSet->AddRef();
}

//----- Automation methods
bool CMTVariantSessionEnumBase::First(long& lPos, CMTSessionBase** pSessionBase /*= NULL */)
{
	//----- Get the first element.
	const SharedSetNode* pCurrentNode = mpSet->First(mpHeader);
	if (!pCurrentNode)
		return false;

	//----- Get the session object.
	if (pSessionBase)
	{
		*pSessionBase = mServer->GetSession(pCurrentNode->GetID());
		if (*pSessionBase == NULL)
			return false;
	}

	lPos = (long) pCurrentNode;
	return true;
}

bool CMTVariantSessionEnumBase::Next(long& lPos, CMTSessionBase** pSessionBase /*= NULL */)
{
	//----- Get current node.
	const SharedSetNode* pCurrentNode = (SharedSetNode*) lPos;
	if (pCurrentNode == NULL)
		return false;

	//----- Get the next element.
	const SharedSetNode* pNextNode = pCurrentNode->Next(mpHeader);
	if (pNextNode == NULL)
		return false;

	//----- Get the session object.
	if (pSessionBase)
	{
		*pSessionBase = mServer->GetSession(pNextNode->GetID());
		if (*pSessionBase == NULL)
			return NULL;
	}

	lPos = (long) pNextNode;
	return true;
}

CMTSessionBase* CMTVariantSessionEnumBase::GetAt(long lPos)
{
	//----- Get current node.
	const SharedSetNode* pCurrentNode = (SharedSetNode*) lPos;
	if (pCurrentNode == NULL)
		return NULL;

	//----- Get the session object.
	return mServer->GetSession(pCurrentNode->GetID());
}

//-- EOF --