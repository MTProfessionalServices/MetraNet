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
#include "MTProductCatalog.h"
#include "MTNonRecurringCharge.h"
#include <mtcomerr.h>

/////////////////////////////////////////////////////////////////////////////
// CMTNonRecurringCharge

STDMETHODIMP CMTNonRecurringCharge::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTNonRecurringCharge,
    &IID_IMTPriceableItem,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTNonRecurringCharge::get_NonRecurringChargeEvent(MTNonRecurringEventType *pVal)
{
	return GetPropertyValue("NonRecurringChargeEvent", reinterpret_cast<long*>(pVal));
}

STDMETHODIMP CMTNonRecurringCharge::put_NonRecurringChargeEvent(MTNonRecurringEventType newVal)
{
	return PutPropertyValue("NonRecurringChargeEvent", static_cast<long>(newVal));
}

// ----------------------------------------------------------------
// Name:          CopyNonBaseMembersTo
// Arguments:     apPrcItemTarget - PI template or instanc
//                
// Errors Raised: _com_error
// Description:   copy the members that are not in the base class
//                this method can be called for templates or instances
// ----------------------------------------------------------------
void CMTNonRecurringCharge::CopyNonBaseMembersTo(IMTPriceableItem* apPrcItemTarget)
{
	MTPRODUCTCATALOGLib::IMTNonRecurringChargePtr source = this;
	MTPRODUCTCATALOGLib::IMTNonRecurringChargePtr target = apPrcItemTarget;

	target->NonRecurringChargeEvent = source->NonRecurringChargeEvent;
}


HRESULT CMTNonRecurringCharge::FinalConstruct()
{
	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &m_pUnkMarshaler.p);
		if (FAILED(hr))
			throw _com_error(hr);

		//load meta data
		LoadPropertiesMetaData( PCENTITY_TYPE_NON_RECURRING );

		// set kind
		put_Kind( PCENTITY_TYPE_NON_RECURRING );

	}	
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

