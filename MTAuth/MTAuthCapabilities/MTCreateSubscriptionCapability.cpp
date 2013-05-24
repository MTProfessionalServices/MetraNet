/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"
#include "MTAuthCapabilities.h"
#include "MTCreateSubscriptionCapability.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCreateSubscriptionCapability

STDMETHODIMP CMTCreateSubscriptionCapability::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCompositeCapability
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCreateSubscriptionCapability::FinalConstruct()	
{
  try
  {
    MTAUTHLib::IMTSecurityPtr mSec(__uuidof(MTAUTHLib::MTSecurity));
    mViewSubscriptions = mSec->GetCapabilityTypeByName(VIEW_SUBCAP);
    mSelfSubscribe = mSec->GetCapabilityTypeByName(SELF_SUBSCRIBE);
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }

	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}


STDMETHODIMP CMTCreateSubscriptionCapability::Implies(IMTCompositeCapability* aDemandedCap, 
                                                       VARIANT_BOOL aCheckparameters,
                                                       VARIANT_BOOL* aResult)
{
  try
  {
    MTAUTHLib::IMTCompositeCapabilityPtr check(aDemandedCap);
    
    if(mViewSubscriptions->Equals(check->GetCapabilityType()) == VARIANT_TRUE) {
      *aResult = VARIANT_TRUE;
      return S_OK;
    }
    if(mSelfSubscribe->Equals(check->GetCapabilityType()) == VARIANT_TRUE) {
      *aResult = VARIANT_TRUE;
      return S_OK;
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return CAPBASE::Implies(aDemandedCap,aCheckparameters,aResult);
}
