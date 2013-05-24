/**************************************************************************
 * MTOBJECTOWNERBASE
 *
 * Copyright 1997-2004 by MetraTech Corp.
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"

#include <metra.h>
#include <comdef.h>
#include <sharedsess.h>

#include <errobj.h>
#include "MTObjectOwnerBaseDef.h"

CMTObjectOwnerBase::CMTObjectOwnerBase()
	:	mpObjectOwner(NULL),
		mpHeader(NULL)
{
}

CMTObjectOwnerBase::~CMTObjectOwnerBase()
{
	//----- Important to release the shared object when the COM object goes away
	if (mpObjectOwner)
	{
		mpObjectOwner->Release(mpHeader);
		mpObjectOwner = NULL;
	}
}

void CMTObjectOwnerBase::SetSharedInfo(SharedSessionHeader * apHeader, SharedObjectOwner * apObjectOwner)
{
	mpObjectOwner = apObjectOwner;
	mpHeader = apHeader;
	int newCount = mpObjectOwner->AddRef();
}

long CMTObjectOwnerBase::get_ID()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->GetID(mpHeader);
}

long CMTObjectOwnerBase::get_StageID()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->GetOwnerStageID();
}

long CMTObjectOwnerBase::get_SessionSetID()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->GetSessionSetID();
}

bool CMTObjectOwnerBase::get_NotifyStage()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->GetActionType() == SharedObjectOwner::OBJECT_OWNER_NOTIFY_STAGE;
}

bool CMTObjectOwnerBase::get_CompleteProcessing()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->GetActionType() == SharedObjectOwner::OBJECT_OWNER_COMPLETE_PROCESSING;
}

bool CMTObjectOwnerBase::get_SendFeedback()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->GetActionType() == SharedObjectOwner::OBJECT_OWNER_SEND_FEEDBACK;
}

long CMTObjectOwnerBase::get_TotalCount()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->GetTotalCount();
}

long CMTObjectOwnerBase::get_WaitingCount()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->GetWaitingCount();
}

bool CMTObjectOwnerBase::get_IsComplete()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->IsComplete() ? true : false;
}
	
bool CMTObjectOwnerBase::DecrementWaitingCount()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->DecrementWaitingCount() ? true : false;
}

long CMTObjectOwnerBase::get_NextObjectOwnerID()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->GetNextObjectOwnerID();
}

void CMTObjectOwnerBase::put_NextObjectOwnerID(long val)
{
	ASSERT(mpObjectOwner);
	mpObjectOwner->SetNextObjectOwnerID(mpHeader, val);
}

void CMTObjectOwnerBase::FlagError()
{
	ASSERT(mpObjectOwner);
	mpObjectOwner->FlagError();
}

bool CMTObjectOwnerBase::get_ErrorFlag()
{
	ASSERT(mpObjectOwner);
	return mpObjectOwner->GetErrorFlag() ? true : false;
}

void CMTObjectOwnerBase::InitForNotifyStage(int aTotalCount, int aOwnerStage)
{
	ASSERT(mpObjectOwner);
	mpObjectOwner->InitForNotifyStage(aTotalCount, aOwnerStage);
}

void CMTObjectOwnerBase::InitForSendFeedback(int aTotalCount, int aSessionSetID)
{
	ASSERT(mpObjectOwner);
	mpObjectOwner->InitForSendFeedback(mpHeader, aTotalCount, aSessionSetID);
}

void CMTObjectOwnerBase::InitForCompleteProcessing(int aTotalCount, int aSessionSetID)
{
	ASSERT(mpObjectOwner);
	mpObjectOwner->InitForCompleteProcessing(mpHeader, aTotalCount, aSessionSetID);
}

long CMTObjectOwnerBase::IncreaseSharedRefCount()
{
	// NOTE: use this method with caution - increasing the ref count will
	// cause the object to stay in shared memory even after the COM object is deleted
	return mpObjectOwner->AddRef();
}

long CMTObjectOwnerBase::DecreaseSharedRefCount()
{
	// NOTE: use this method with caution - decreasing the ref count
	// could cause the shared session to be deleted prematurely
	return mpObjectOwner->Release(mpHeader);
}

const char* CMTObjectOwnerBase::get_TransactionID()
{
	return mpObjectOwner->GetTransactionID(mpHeader);
}

void CMTObjectOwnerBase::put_TransactionID(const char* pszVal)
{
	if (!mpObjectOwner->SetTransactionID(mpHeader, pszVal))
		throw MTException("Unable to set transaction ID - might be set already");
}

MTPipelineLib::IMTTransaction* CMTObjectOwnerBase::get_Transaction()
{
	IUnknown * tran = NULL;
	mpObjectOwner->GetTransaction(&tran);
	if (tran)
	{
		MTPipelineLib::IMTTransaction* apTran = NULL;
		HRESULT hr = tran->QueryInterface(__uuidof(MTPipelineLib::IMTTransaction), (void **) &apTran);
		tran->Release();
    if (FAILED(hr))
  		throw MTException("Unable to QI for transaction", hr);

    return apTran;
	}
	else
		return NULL;
}

void CMTObjectOwnerBase::put_Transaction(MTPipelineLib::IMTTransaction * apTran)
{
	if (!mpObjectOwner->SetTransaction(apTran))
		throw MTException("Unable to set transaction object - might be set already");
}

void CMTObjectOwnerBase::put_SerializedSessionContext(const wchar_t* pszVal)
{
	if (!mpObjectOwner->SetSerializedSessionContext(mpHeader, pszVal))
		throw MTException("Unable to set Serialized session context - might be set already");
}

const wchar_t* CMTObjectOwnerBase::get_SerializedSessionContext()
{
	return mpObjectOwner->CopySerializedSessionContext(mpHeader);
}

void CMTObjectOwnerBase::put_SessionContextUserName(const char* pszVal)
{
	if (!mpObjectOwner->SetSessionContextUserName(mpHeader, pszVal))
		throw MTException("Unable to set session context user name - might be set already");
}

const char* CMTObjectOwnerBase::get_SessionContextUserName()
{
	return mpObjectOwner->GetSessionContextUserName(mpHeader);
}

void CMTObjectOwnerBase::put_SessionContextPassword(const char* pszVal)
{
	if (!mpObjectOwner->SetSessionContextPassword(mpHeader, pszVal))
		throw MTException("Unable to set session context password - might be set already");
}

const char* CMTObjectOwnerBase::get_SessionContextPassword()
{
	return mpObjectOwner->GetSessionContextPassword(mpHeader);
}

void CMTObjectOwnerBase::put_SessionContextNamespace(const char* pszVal)
{
	if (!mpObjectOwner->SetSessionContextNamespace(mpHeader, pszVal))
		throw MTException("Unable to set session context namespace - might be set already");
}

const char* CMTObjectOwnerBase::get_SessionContextNamespace()
{
	return mpObjectOwner->GetSessionContextNamespace(mpHeader);
}

MTPipelineLibExt::IMTSessionContext* CMTObjectOwnerBase::get_SessionContext()
{
	IUnknown * sc = NULL;
	mpObjectOwner->GetSessionContext(&sc);
	if (sc)
	{
		MTPipelineLibExt::IMTSessionContext* apSC = NULL;
		HRESULT hr = sc->QueryInterface(__uuidof(MTPipelineLibExt::IMTSessionContext), (void **) &apSC);
		sc->Release();
		if (FAILED(hr))
			throw MTException("Unable to QI for session context", hr);

		return apSC;
	}
	else
		return NULL;
}

void CMTObjectOwnerBase::put_SessionContext(/*[in]*/ MTPipelineLibExt::IMTSessionContext * apSC)
{
	if (!mpObjectOwner->SetSessionContext(apSC))
		throw MTException("Unable to set session context object - might be set already");
}

IUnknown* CMTObjectOwnerBase::get_RSIDCache()
{
	IUnknown* apCache = NULL;
	mpObjectOwner->GetRSIDCache(&apCache);
	return apCache;
}

void CMTObjectOwnerBase::put_RSIDCache(/*[in]*/ IUnknown * apCache)
{
	if (!mpObjectOwner->SetRSIDCache(apCache))
		throw MTException("Unable to set RSIDCache object");
}

void CMTObjectOwnerBase::InitLock()
{
  if(!mpObjectOwner->InitLock())
    throw MTException("Unable to initial object owner lock");
}

void CMTObjectOwnerBase::Lock()
{
  mpObjectOwner->Lock();
}

void CMTObjectOwnerBase::Unlock()
{
  mpObjectOwner->Unlock();
}

//-- EOF --
