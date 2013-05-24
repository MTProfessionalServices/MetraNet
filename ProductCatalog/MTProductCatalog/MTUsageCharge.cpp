/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"

#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalog.h"
#include "MTUsageCharge.h"

/////////////////////////////////////////////////////////////////////////////
// CMTUsageCharge

/******************************************* error interface ***/
STDMETHODIMP CMTUsageCharge::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTUsageCharge,
    &IID_IMTPriceableItem,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/********************************** construction/destruction ***/
CMTUsageCharge::CMTUsageCharge()
{
	mpUnkMarshaler = NULL;
}

HRESULT CMTUsageCharge::FinalConstruct()
{
	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mpUnkMarshaler.p);
		if (FAILED(hr))
			throw _com_error(hr);

		//load meta data
		LoadPropertiesMetaData( PCENTITY_TYPE_USAGE );

		// set kind
		put_Kind( PCENTITY_TYPE_USAGE );

	}	
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

void CMTUsageCharge::FinalRelease()
{
	mpUnkMarshaler.Release();
}

