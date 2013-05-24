/**************************************************************************
 * @doc MTNAMEID
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
 ***************************************************************************/
#include "StdAfx.h"
#include "SysContext.h"
#include "ClassMTNameID.h"
#include <comutil.h>



/////////////////////////////////////////////////////////////////////////////
// CMTNameID

STDMETHODIMP CMTNameID::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTNameID,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTNameID::CMTNameID()
{ }

CMTNameID::~CMTNameID()
{ }

HRESULT CMTNameID::FinalConstruct()
{
#ifdef DEBUG
	mLeakDetector = new int[123];
#endif

	mpCodeLookup = CCodeLookup::GetInstance();
	if (!mpCodeLookup)
		return E_FAIL;

	return S_OK;
}

void CMTNameID::FinalRelease()
{
#ifdef DEBUG
	delete [] mLeakDetector;
#endif

	CCodeLookup::ReleaseInstance();
}


/*
 * NameID methods
 */

STDMETHODIMP CMTNameID::GetNameID(BSTR name, long * id)
{
	if (!id)
		return E_POINTER;

	HRESULT errCode = S_OK;
	int code;

	// -- enter the critical section
	// TODO: is critical section needed?
	mNamePoolLock.Lock();

	// we can use the BSTR directly here since it's a wchar_t *

	BOOL retval = mpCodeLookup->GetEnumDataCode(name, code);

	if (!retval)
	{
		const ErrorObject * err = mpCodeLookup->GetLastError();
		if (err)
			errCode = HRESULT_FROM_WIN32(err->GetCode());
		else
			errCode = E_FAIL;
	}

	// -- leave the critical section
	mNamePoolLock.Unlock();

	*id = code;

	// TODO: use com->error integration

	return errCode;
}


STDMETHODIMP CMTNameID::GetName(long id, BSTR * name)
{
	if (!id)
		return E_POINTER;

	// -- enter the critical section
	mNamePoolLock.Lock();

	std::wstring wstr;
	// TODO: is this right?
	mpCodeLookup->GetValue((int) id, wstr.c_str());

	// -- leave the critical section
	mNamePoolLock.Unlock();

	if (wstr.length() > 0)
	{
		*name = ::SysAllocString((const wchar_t *) wstr);
		return S_OK;
	}
	else
	{
		return E_INVALIDARG;
	}
}
