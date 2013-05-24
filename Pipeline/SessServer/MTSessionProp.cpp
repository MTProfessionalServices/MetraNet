/**************************************************************************
 * @doc MTSESSIONPROP
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

#include "SessServer.h"
#include "MTSessionPropDef.h"

#include <comutil.h>

#include <metra.h>

/******************************************* error interface ***/

STDMETHODIMP CMTSessionProp::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSessionProp,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


/********************************** construction/destruction ***/

CMTSessionProp::CMTSessionProp()
{
}

HRESULT CMTSessionProp::FinalConstruct()
{
	return S_OK;
}

void CMTSessionProp::FinalRelease()
{
}

/********************************************* direct access ***/

void CMTSessionProp::SetPropInfo(MTSessionPropType aType, _bstr_t aName, long aNameID)
{
	mType = aType;
	mName = aName;
	mNameID = aNameID;
}

/************************************************ properties ***/

// ----------------------------------------------------------------
// Description: Name of property
// Return Value: the name of the property
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionProp::get_Name(BSTR * apName)
{
	if (!apName)
		return E_POINTER;

	*apName = mName.copy();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Name ID of property.  This is exactly as if GetNameID was called
//              on the name property.
// Return Value: the property's name ID
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionProp::get_NameID(long * apNameID)
{
	if (!apNameID)
		return E_POINTER;

	*apNameID = mNameID;

	return S_OK;
}

// ----------------------------------------------------------------
// Description: The type of the property.
// Return Value: the property's type
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionProp::get_Type(MTSessionPropType * apType)
{
	if (!apType)
		return E_POINTER;

	*apType = mType;

	return S_OK;
}
