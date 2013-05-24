// MTDeleteSubscriptionCapability.cpp : Implementation of CMTDeleteSubscriptionCapability
#include "StdAfx.h"
#include "MTAuthCapabilities.h"
#include "MTDeleteSubscriptionCapability.h"

/////////////////////////////////////////////////////////////////////////////
// CMTDeleteSubscriptionCapability

STDMETHODIMP CMTDeleteSubscriptionCapability::InterfaceSupportsErrorInfo(REFIID riid)
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

HRESULT CMTDeleteSubscriptionCapability::FinalConstruct()	
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


STDMETHODIMP CMTDeleteSubscriptionCapability::Implies(IMTCompositeCapability* aDemandedCap, 
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
