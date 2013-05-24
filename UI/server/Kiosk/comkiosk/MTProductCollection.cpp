/**************************************************************************
* Copyright 1997-2000 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Raju Matta 
* $Header$
* 
***************************************************************************/
// ---------------------------------------------------------------------------
// MTProductCollection.cpp : Implementation of CMTProductCollection
// ---------------------------------------------------------------------------
#include "StdAfx.h"
#include "COMKiosk.h"
#include "MTProductCollection.h"

/////////////////////////////////////////////////////////////////////////////
// CMTProductCollection

STDMETHODIMP CMTProductCollection::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTProductCollection
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ---------------------------------------------------------------------------
// Description:   Gets the product view name property
//                (metratech.com/audioconfplayback)
// ---------------------------------------------------------------------------
STDMETHODIMP CMTProductCollection::get_Name(BSTR *pVal)
{
    *pVal = mName.copy();
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Sets the product view name property
//                (metratech.com/audioconfplayback)
// ---------------------------------------------------------------------------
STDMETHODIMP CMTProductCollection::put_Name(BSTR newVal)
{
    mName = newVal;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Gets the link property
//                (products/metratech/audioConfPolling.asp)
// ---------------------------------------------------------------------------
STDMETHODIMP CMTProductCollection::get_Link(BSTR *pVal)
{
    *pVal = mLink.copy();
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Sets the link property
//                (products/metratech/audioConfPolling.asp)
// ---------------------------------------------------------------------------
STDMETHODIMP CMTProductCollection::put_Link(BSTR newVal)
{
    mLink = newVal;
	return S_OK;
}
