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

#ifndef __CMTCREATECORPORATEACCOUNTCAPABILITY_H_
#define __CMTCREATECORPORATEACCOUNTCAPABILITY_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CCMTCreateCorporateAccountCapability
class ATL_NO_VTABLE CCMTCreateCorporateAccountCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCMTCreateCorporateAccountCapability, &CLSID_CMTCreateCorporateAccountCapability>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTCompositeCapability, &IID_IMTCompositeCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CCMTCreateCorporateAccountCapability()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_CMTCREATECORPORATEACCOUNTCAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CCMTCreateCorporateAccountCapability)
	COM_INTERFACE_ENTRY(IMTCompositeCapability)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTCompositeCapability
public:
};

#endif //__CMTCREATECORPORATEACCOUNTCAPABILITY_H_
