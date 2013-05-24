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
* Created by: Boris Partensky
* 
***************************************************************************/
	
// MTPathCapability.h : Declaration of the CMTPathCapability

#ifndef __MTPATHCAPABILITY_H_
#define __MTPATHCAPABILITY_H_

#include "resource.h"       // main symbols
#include "MTAtomicCapabilityBase.h"


/////////////////////////////////////////////////////////////////////////////
// CMTPathCapability
class ATL_NO_VTABLE CMTPathCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPathCapability, &CLSID_MTPathCapability>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPathCapability, &IID_IMTPathCapability, &LIBID_MTAUTHLib>
{
public:
	CMTPathCapability()
	{
		mPathParameter = NULL;
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPATHCAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPathCapability)
	COM_INTERFACE_ENTRY(IMTPathCapability)
	COM_INTERFACE_ENTRY(IMTAtomicCapability)
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

// IMTPathCapability
public:
	STDMETHOD(GetParameter)(/*[out, retval]*/ IMTPathParameter* *pVal);
	STDMETHOD(SetParameter)(/*[in]*/BSTR aPath, /*[in]*/MTHierarchyPathWildCard aWildCard);
	STDMETHOD(InitParams)();
	STDMETHOD(Remove)(IMTPrincipalPolicy* aPolicy);
	STDMETHOD(Implies)(/*[in]*/IMTAtomicCapability* aCapability, /*[out, retval]*/VARIANT_BOOL* aResult);
	STDMETHOD(Save)(/*[in]*/IMTPrincipalPolicy* aPolicy);
  STDMETHOD(ToString)(/*[out, retval]*/BSTR* apString);
	DEFINE_ATOMIC_FINAL_CONSTRUCT
	IMPLEMENT_BASE_ATOMIC_CAP_METHODS

private:
	DECLARE_ATOMIC_BASE_CLASS_POINTER

	MTAUTHLib::IMTPathParameterPtr mPathParameter;
	_bstr_t GetFullPath(IMTPathParameter* aParam);
};

#endif //__MTPATHCAPABILITY_H_
