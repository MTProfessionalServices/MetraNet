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

#ifndef __MTDECIMALCAPABILITY_H_
#define __MTDECIMALCAPABILITY_H_

#include "resource.h"       // main symbols
#include "MTAtomicCapabilityBase.h"


/////////////////////////////////////////////////////////////////////////////
// CMTDecimalCapability
class ATL_NO_VTABLE CMTDecimalCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTDecimalCapability, &CLSID_MTDecimalCapability>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTDecimalCapability, &IID_IMTDecimalCapability, &LIBID_MTAUTHLib>
{
public:
	CMTDecimalCapability()
	{
		mParam = NULL;
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTDECIMALCAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTDecimalCapability)
	COM_INTERFACE_ENTRY(IMTDecimalCapability)
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
public:
	STDMETHOD(Save)(/*[in]*/IMTPrincipalPolicy* aPolicy);
	STDMETHOD(Implies)(/*[in]*/IMTAtomicCapability* aDemandedCap, /*[out, retval]*/VARIANT_BOOL* apRes);
	STDMETHOD(Remove)(IMTPrincipalPolicy* aPolicy);
	STDMETHOD(GetParameter)(/*[out, retval]*/IMTSimpleCondition** apParam);
	STDMETHOD(SetParameter)(/*[in]*/VARIANT aParam, MTOperatorType aOp);
	STDMETHOD(InitParams)();
  STDMETHOD(ToString)(/*[out, retval]*/BSTR* apString);

	DEFINE_ATOMIC_FINAL_CONSTRUCT
	
	IMPLEMENT_BASE_ATOMIC_CAP_METHODS

private:
	DECLARE_ATOMIC_BASE_CLASS_POINTER

	//MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
	MTAUTHLib::IMTSimpleConditionPtr mParam;

};

#endif //__MTDECIMALCAPABILITY_H_
