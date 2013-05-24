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

#ifndef __MTAPPLICATIONLOGONCAPABILITY_H_
#define __MTAPPLICATIONLOGONCAPABILITY_H_

#include "resource.h"       // main symbols
#include "MTCompositeCapabilityImpl.h"


/////////////////////////////////////////////////////////////////////////////
// CMTApplicationLogOnCapability
class ATL_NO_VTABLE CMTApplicationLogOnCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTApplicationLogOnCapability, &CLSID_MTApplicationLogOnCapability>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTApplicationLogOnCapability, &IID_IMTApplicationLogOnCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CMTApplicationLogOnCapability()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTAPPLICATIONLOGONCAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTApplicationLogOnCapability)
	COM_INTERFACE_ENTRY(IMTApplicationLogOnCapability)
	COM_INTERFACE_ENTRY(IMTCompositeCapability)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

};

#endif //__MTAPPLICATIONLOGONCAPABILITY_H_
