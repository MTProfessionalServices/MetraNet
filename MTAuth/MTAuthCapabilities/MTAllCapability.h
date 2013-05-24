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

#ifndef __MTALLCAPABILITY_H_
#define __MTALLCAPABILITY_H_

#include "resource.h"       // main symbols

#include "MTCompositeCapabilityImpl.h"


/////////////////////////////////////////////////////////////////////////////
// CMTAllCapability
class ATL_NO_VTABLE CMTAllCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAllCapability, &CLSID_MTAllCapability>,
	public ISupportErrorInfo,
	public MTCompositeCapabilityImpl<IMTAllCapability, &IID_IMTAllCapability, &LIBID_MTAUTHCAPABILITIESLib>
{
public:
	CMTAllCapability()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTALLCAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAllCapability)
	COM_INTERFACE_ENTRY(IMTAllCapability)
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

// IMTAllCapability
public:
//DEFINE_COMPOSITE_FINAL_CONSTRUCT

//IMPLEMENT_BASE_COMPOSITE_CAP_METHODS
///don't want to implement a base class Imply -
//this class is special
// IMPLEMENT_BASE_IMPLY
STDMETHOD(Implies)(IMTCompositeCapability* aDemandedCap, VARIANT_BOOL aCheckparameters, VARIANT_BOOL* aResult);


private:
	//DECLARE_COMPOSITE_BASE_CLASS_POINTER

};

#endif //__MTALLCAPABILITY_H_
