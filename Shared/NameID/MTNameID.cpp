/**************************************************************************
 * @doc MTNAMEID
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
 ***************************************************************************/

#include "StdAfx.h"

#include "MTNameIDDef.h"

// TODO: import not needed.  only here to avoid a compile problem
#import <MTConfigLib.tlb>

#include <CodeLookup.h>

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
	mpCodeLookup = CCodeLookup::GetInstance();
	if (!mpCodeLookup)
		return E_FAIL;

  return CoCreateFreeThreadedMarshaler( GetControllingUnknown(), &mpUnkMarshaler.p );
}

void CMTNameID::FinalRelease()
{
	mpCodeLookup->ReleaseInstance();
	mpCodeLookup = 0;

  mpUnkMarshaler.Release();
}


/*
 * NameID methods
 */

// ----------------------------------------------------------------
// Description: Retrieve a property ID for a given property name.
// Arguments: name - Property name
// Return Value: ID of the property name
// ----------------------------------------------------------------
STDMETHODIMP CMTNameID::GetNameID(BSTR name, long * id)
{
	if (!id)
		return E_POINTER;

	if (!name || !*name)
		return Error("NULL or empty string passed into GetNameID", GUID_NULL,
								 E_INVALIDARG);

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


// ----------------------------------------------------------------
// Description: Retrieve a property name for a given property ID.
//              This method is inefficient and should be used sparingly.
// Arguments: id - ID of the property name
// Return Value: Property name
// ----------------------------------------------------------------
STDMETHODIMP CMTNameID::GetName(long id, BSTR * name)
{
	if (!id)
		return E_POINTER;

	// -- enter the critical section
	mNamePoolLock.Lock();

	wstring wstr;
	// TODO: is this right?
	mpCodeLookup->GetValue((int) id, wstr);

	// -- leave the critical section
	mNamePoolLock.Unlock();

	if (wstr.length() > 0)
	{
		*name = ::SysAllocString(wstr.c_str());
		return S_OK;
	}
	else
	{
		return E_INVALIDARG;
	}
}

