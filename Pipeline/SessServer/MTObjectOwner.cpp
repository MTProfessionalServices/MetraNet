/**************************************************************************
 * MTOBJECTOWNER
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
 * Created by: Derek Young
 *			   Boris Boruchovich
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"

#include "SessServer.h"
#include "MTObjectOwnerDef.h"
#include "MTExceptionMacros.h"

#include <metra.h>
#include <comdef.h>
#include <errobj.h>

/******************************************* error interface ***/
STDMETHODIMP CMTObjectOwner::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTObjectOwner,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTObjectOwner::CMTObjectOwner()
	:	mpObjectOwnerBase(NULL)
{
}

HRESULT CMTObjectOwner::FinalConstruct()
{
	return S_OK;
}

void CMTObjectOwner::FinalRelease()
{
	ASSERT(mpObjectOwnerBase);
	if (mpObjectOwnerBase)
	{
		delete mpObjectOwnerBase;
		mpObjectOwnerBase = NULL;
	}
}

STDMETHODIMP CMTObjectOwner::get_ID(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->get_ID();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_StageID(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->get_StageID();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_SessionSetID(/*[out, retval]*/ long *pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->get_SessionSetID();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_NotifyStage(/*[out, retval]*/ VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->get_NotifyStage() ? VARIANT_TRUE : VARIANT_FALSE;
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_CompleteProcessing(/*[out, retval]*/ VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->get_CompleteProcessing()	? VARIANT_TRUE : VARIANT_FALSE;
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_SendFeedback(/*[out, retval]*/ VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->get_SendFeedback() ? VARIANT_TRUE : VARIANT_FALSE;
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_TotalCount(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->get_TotalCount();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_WaitingCount(/*[out, retval]*/ long *pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->get_WaitingCount();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_IsComplete(/*[out, retval]*/ VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->get_IsComplete() ? VARIANT_TRUE : VARIANT_FALSE;
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}
	
STDMETHODIMP CMTObjectOwner::DecrementWaitingCount(/*[out, retval]*/ VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->DecrementWaitingCount() ? VARIANT_TRUE : VARIANT_FALSE;
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_NextObjectOwnerID(/*[out, retval]*/ long *pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->get_NextObjectOwnerID();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::put_NextObjectOwnerID(long val)
{
	MT_BEGIN_TRY_BLOCK()
	mpObjectOwnerBase->put_NextObjectOwnerID(val);
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::FlagError()
{
	MT_BEGIN_TRY_BLOCK()
	mpObjectOwnerBase->FlagError();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_ErrorFlag(/*[out, retval]*/ VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;
	
	MT_BEGIN_TRY_BLOCK()
	*pVal = mpObjectOwnerBase->get_ErrorFlag() ? VARIANT_TRUE : VARIANT_FALSE;
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::InitForNotifyStage(int aTotalCount, int aOwnerStage)
{
	MT_BEGIN_TRY_BLOCK()
	mpObjectOwnerBase->InitForNotifyStage(aTotalCount, aOwnerStage);
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::InitForSendFeedback(int aTotalCount, int aSessionSetID)
{
	MT_BEGIN_TRY_BLOCK()
	mpObjectOwnerBase->InitForSendFeedback(aTotalCount, aSessionSetID);
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::InitForCompleteProcessing(int aTotalCount, int aSessionSetID)
{
	MT_BEGIN_TRY_BLOCK()
	mpObjectOwnerBase->InitForCompleteProcessing(aTotalCount, aSessionSetID);
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::IncreaseSharedRefCount(long * apNewCount)
{
	if (!apNewCount)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apNewCount = mpObjectOwnerBase->IncreaseSharedRefCount();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::DecreaseSharedRefCount(long * apNewCount)
{
	if (!apNewCount)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apNewCount = mpObjectOwnerBase->DecreaseSharedRefCount();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_TransactionID(/*[out, retval]*/ BSTR * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	const char* txnID = mpObjectOwnerBase->get_TransactionID();
	if (!txnID)
		txnID = "";

	_bstr_t transactionID(txnID);
	*pVal = transactionID.copy();
	MT_END_TRY_BLOCK_RETVAL(IID_IMTObjectOwner, *pVal);
}

STDMETHODIMP CMTObjectOwner::put_TransactionID(/*[in]*/ BSTR newVal)
{
	MT_BEGIN_TRY_BLOCK()
	_bstr_t transactionID(newVal);
	mpObjectOwnerBase->put_TransactionID(transactionID);
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_Transaction(/*[out, retval]*/ IMTTransaction** apTran)
{
	if (!apTran)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apTran = reinterpret_cast<IMTTransaction*>(mpObjectOwnerBase->get_Transaction());
	MT_END_TRY_BLOCK_RETVAL(IID_IMTObjectOwner, *apTran);
}

STDMETHODIMP CMTObjectOwner::put_Transaction(/*[in]*/ IMTTransaction * apTran)
{
	MT_BEGIN_TRY_BLOCK()
	mpObjectOwnerBase->put_Transaction(reinterpret_cast<MTPipelineLib::IMTTransaction*>(apTran));
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::put_SerializedSessionContext(/*[in]*/ BSTR newVal)
{
	MT_BEGIN_TRY_BLOCK()
	_bstr_t temp(newVal);
	mpObjectOwnerBase->put_SerializedSessionContext(temp);
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_SerializedSessionContext(/*[out, retval]*/ BSTR * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	const wchar_t* temp = mpObjectOwnerBase->get_SerializedSessionContext();
	if (!temp)
		temp = L"";

	_bstr_t bstrOut(temp);
	delete [] temp;
	*pVal = bstrOut.copy();
	MT_END_TRY_BLOCK_RETVAL(IID_IMTObjectOwner, *pVal);
}

STDMETHODIMP CMTObjectOwner::put_SessionContextUserName(/*[in]*/ BSTR newVal)
{
	MT_BEGIN_TRY_BLOCK()
	_bstr_t temp(newVal);
	mpObjectOwnerBase->put_SessionContextUserName(temp);
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_SessionContextUserName(/*[out, retval]*/ BSTR * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	const char* temp = mpObjectOwnerBase->get_SessionContextUserName();
	if (!temp)
		temp = "";

	_bstr_t bstrOut(temp);
	*pVal = bstrOut.copy();

	MT_END_TRY_BLOCK_RETVAL(IID_IMTObjectOwner, *pVal);
}

STDMETHODIMP CMTObjectOwner::put_SessionContextPassword(/*[in]*/ BSTR newVal)
{
	MT_BEGIN_TRY_BLOCK()
	_bstr_t temp(newVal);
	mpObjectOwnerBase->put_SessionContextPassword(temp);
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_SessionContextPassword(/*[out, retval]*/ BSTR * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	const char* temp = mpObjectOwnerBase->get_SessionContextPassword();
	if (!temp)
		temp = "";

	_bstr_t bstrOut(temp);
	*pVal = bstrOut.copy();

	MT_END_TRY_BLOCK_RETVAL(IID_IMTObjectOwner, *pVal);
}

STDMETHODIMP CMTObjectOwner::put_SessionContextNamespace(/*[in]*/ BSTR newVal)
{
	MT_BEGIN_TRY_BLOCK()
	_bstr_t temp(newVal);
	mpObjectOwnerBase->put_SessionContextNamespace(temp);
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_SessionContextNamespace(/*[out, retval]*/ BSTR * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	const char* temp = mpObjectOwnerBase->get_SessionContextNamespace();
	if (!temp)
		temp = "";

	_bstr_t bstrOut(temp);
	*pVal = bstrOut.copy();

	MT_END_TRY_BLOCK_RETVAL(IID_IMTObjectOwner, *pVal);
}

STDMETHODIMP CMTObjectOwner::get_SessionContext(/*[out, retval]*/ IMTSessionContext** apSC)
{
	if (!apSC)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apSC = reinterpret_cast<IMTSessionContext*>(mpObjectOwnerBase->get_SessionContext());
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::put_SessionContext(/*[in]*/ IMTSessionContext * apSC)
{
	MT_BEGIN_TRY_BLOCK()
	mpObjectOwnerBase->put_SessionContext(reinterpret_cast<MTPipelineLibExt::IMTSessionContext*>(apSC));
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::get_RSIDCache(	/*[out, retval]*/ IUnknown * * apCache)
{
	if (!apCache)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apCache = mpObjectOwnerBase->get_RSIDCache();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::put_RSIDCache(/*[in]*/ IUnknown * apCache)
{
	MT_BEGIN_TRY_BLOCK()
	mpObjectOwnerBase->put_RSIDCache(apCache);
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::InitLock()
{
	MT_BEGIN_TRY_BLOCK()
	mpObjectOwnerBase->InitLock();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::Lock()
{
	MT_BEGIN_TRY_BLOCK()
	mpObjectOwnerBase->Lock();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

STDMETHODIMP CMTObjectOwner::Unlock()
{
	MT_BEGIN_TRY_BLOCK()
	mpObjectOwnerBase->Unlock();
	MT_END_TRY_BLOCK(IID_IMTObjectOwner);
}

//-- EOF --
