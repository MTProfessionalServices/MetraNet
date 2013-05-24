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

#ifndef __MTCREATESUBSCRIPTIONCAPABILITY_H_
#define __MTCREATESUBSCRIPTIONCAPABILITY_H_

#include "resource.h"       // main symbols
#include "MTCompositeCapabilityImpl.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCreateSubscriptionCapability
class ATL_NO_VTABLE CMTCreateSubscriptionCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCreateSubscriptionCapability, &CLSID_MTCreateSubscriptionCapability>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTCompositeCapability, &IID_IMTCompositeCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CMTCreateSubscriptionCapability()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCREATESUBSCRIPTIONCAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCreateSubscriptionCapability)
	COM_INTERFACE_ENTRY(IMTCompositeCapability)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);
  STDMETHOD(Implies)(IMTCompositeCapability* aDemandedCap, VARIANT_BOOL aCheckparameters, VARIANT_BOOL* aResult);

protected:
  MTAUTHLib::IMTCompositeCapabilityTypePtr mViewSubscriptions;
  MTAUTHLib::IMTCompositeCapabilityTypePtr mSelfSubscribe;
};

#endif //__MTCREATESUBSCRIPTIONCAPABILITY_H_
