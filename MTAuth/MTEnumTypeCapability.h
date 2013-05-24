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

#ifndef __MTENUMTYPECAPABILITY_H_
#define __MTENUMTYPECAPABILITY_H_

#include "resource.h"       // main symbols
#include "MTAtomicCapabilityBase.h"



/////////////////////////////////////////////////////////////////////////////
// CMTEnumTypeCapability
class ATL_NO_VTABLE CMTEnumTypeCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumTypeCapability, &CLSID_MTEnumTypeCapability>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTEnumTypeCapability, &IID_IMTEnumTypeCapability, &LIBID_MTAUTHLib>
{
public:
	CMTEnumTypeCapability()
	{
		mParam = NULL;
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMTYPECAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTEnumTypeCapability)
	COM_INTERFACE_ENTRY(IMTEnumTypeCapability)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(IMTAtomicCapability)
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

// IMTEnumTypeCapability
public:
	STDMETHOD(Save)(/*[in]*/IMTPrincipalPolicy* aPolicy);
	STDMETHOD(Implies)(/*[in]*/IMTAtomicCapability* aDemandedCap, /*[out, retval]*/VARIANT_BOOL* apRes);
	STDMETHOD(Remove)(IMTPrincipalPolicy* aPolicy);
	STDMETHOD(GetParameter)(/*[out, retval]*/IMTSimpleCondition** apParam);
	STDMETHOD(SetParameter)(/*[in]*/VARIANT aParam);
  STDMETHOD(ToString)(/*[out, retval]*/BSTR* apString);
	STDMETHOD(InitParams)();
	DEFINE_ATOMIC_FINAL_CONSTRUCT
	IMPLEMENT_BASE_ATOMIC_CAP_METHODS

private:
	DECLARE_ATOMIC_BASE_CLASS_POINTER
	MTAUTHLib::IMTSimpleConditionPtr mParam;
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

};

#endif //__MTENUMTYPECAPABILITY_H_
