/**************************************************************************
 * @doc MTSESSIONSET
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
 *			   Boris Boruchovich
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"
#include <comdef.h>
#include "SessServer.h"
#include "MTSessionSetDef.h"
#include "MTVariantSessionEnum.h"
#include "MTExceptionMacros.h"
#include <MSIX.h>
#include <errobj.h>

/******************************************* error interface ***/
STDMETHODIMP CMTSessionSet::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSessionSet,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// method used when querying for IID_NULL
//If iid matches the IID of the interface queried for, 
//then the function specified by func is called. The declaration for the function should be:
//HRESULT WINAPI func(void* pv, REFIID riid, LPVOID* ppv, DWORD dw);
HRESULT WINAPI _This(void* pv,REFIID iid,void** ppvObject,DWORD)
{
  ATLASSERT(iid == IID_NULL);
  *ppvObject = pv;
  return S_OK;
}

/********************************** construction/destruction ***/
CMTSessionSet::CMTSessionSet()
	:	mpSessionSetBase(NULL)
{
}

HRESULT CMTSessionSet::FinalConstruct()
{
	return S_OK;
}

void CMTSessionSet::FinalRelease()
{
	ASSERT(mpSessionSetBase);
	if (mpSessionSetBase)
	{
		delete mpSessionSetBase;
		mpSessionSetBase = NULL;
	}
}

/*************************************** session set methods ***/
// ----------------------------------------------------------------
// Description: Add a session to the set.
// Arguments: sessionid - Session ID of the session to add.
//            serviceid - Service ID of the session to add.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionSet::AddSession(long aSessionId, long aServiceId)
{
	MT_BEGIN_TRY_BLOCK()
	mpSessionSetBase->AddSession(aSessionId, aServiceId);
	MT_END_TRY_BLOCK(IID_IMTSessionSet);
}

// ----------------------------------------------------------------
// Description: Returns the session set ID.  This ID is an internal ID used
//              by the Pipeline and is not related to any UID.
// Return Value: the ID of the session set.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionSet::get_ID(long * apID)
{
	if (!apID)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apID = mpSessionSetBase->get_ID();
	MT_END_TRY_BLOCK(IID_IMTSessionSet);
}

STDMETHODIMP CMTSessionSet::get_UID(/*[out]*/ unsigned char apUid[])
{
	if (!apUid)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	mpSessionSetBase->get_UID(apUid);
	MT_END_TRY_BLOCK(IID_IMTSessionSet);
}

STDMETHODIMP CMTSessionSet::SetUID(/*[int]*/ unsigned char apUid[])
{
	if (!apUid)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	mpSessionSetBase->SetUID(apUid);
	MT_END_TRY_BLOCK(IID_IMTSessionSet);
}

STDMETHODIMP CMTSessionSet::get_UIDAsString(/*[out, retval]*/ BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	string strUid = mpSessionSetBase->get_UIDAsString();
	_bstr_t bstr(strUid.c_str());
	*pVal = bstr.copy();
	MT_END_TRY_BLOCK(IID_IMTSessionSet);
}

//----- Automation methods
STDMETHODIMP CMTSessionSet::get__NewEnum(LPUNKNOWN* pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()

	std::auto_ptr<CMTVariantSessionEnumBase> pVariantSessionEnumBase(mpSessionSetBase->get__NewEnum());
	if (!pVariantSessionEnumBase.get())
		return E_FAIL;

	CComObject<CMTVariantSessionEnum>* en;
	HRESULT hr = CComObject<CMTVariantSessionEnum>::CreateInstance(&en);
	if (FAILED(hr))
		return hr;

	//----- Set the enum object into COM wrapper.
	en->SetVariantSessionEnum(pVariantSessionEnumBase.release());

	//----- This QueryInterface will AddRef
	hr = en->QueryInterface(IID_IUnknown, (void**) pVal);
	if (FAILED(hr))
	{
		en->Release();
		return hr;
	}

	MT_END_TRY_BLOCK_RETVAL(IID_IMTSessionSet, *pVal);
}

STDMETHODIMP CMTSessionSet::get_Count(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*pVal = mpSessionSetBase->get_Count();
	MT_END_TRY_BLOCK(IID_IMTSessionSet);
}

STDMETHODIMP CMTSessionSet::get_Item(long aIndex, VARIANT * pVal)
{
	return E_NOTIMPL;
}

//----- Use this method with caution - increasing the ref count will
//----- cause the object to stay in shared memory even after the COM object is deleted
STDMETHODIMP CMTSessionSet::IncreaseSharedRefCount(long * apNewCount)
{
	if (!apNewCount)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apNewCount = mpSessionSetBase->IncreaseSharedRefCount();
	MT_END_TRY_BLOCK(IID_IMTSessionSet);
}

//----- Use this method with caution - decreasing the ref count
//----- could cause the shared session to be deleted prematurely
STDMETHODIMP CMTSessionSet::DecreaseSharedRefCount(long * apNewCount)
{
	if (!apNewCount)
		return E_POINTER;

	MT_BEGIN_TRY_BLOCK()
	*apNewCount = mpSessionSetBase->DecreaseSharedRefCount();
	MT_END_TRY_BLOCK(IID_IMTSessionSet);
}

STDMETHODIMP CMTSessionSet::GetInternalSetHandle(long * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	*apVal = (long) mpSessionSetBase;
	return S_OK;
}

//-- EOF --
