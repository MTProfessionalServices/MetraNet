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

	
// MTAccessTypeCapability.h : Declaration of the CMTAccessTypeCapability

#ifndef __MTACCESSTYPECAPABILITY_H_
#define __MTACCESSTYPECAPABILITY_H_

#include "resource.h"       // main symbols
#include "MTAtomicCapabilityBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAccessTypeCapability
class ATL_NO_VTABLE CMTAccessTypeCapability : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccessTypeCapability, &CLSID_MTAccessTypeCapability>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAccessTypeCapability, &IID_IMTAccessTypeCapability, &LIBID_MTAUTHLib>
{
public:
	CMTAccessTypeCapability()
	{
		mAccessType = UNSPECIFIED_ACCESS;
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCESSTYPECAPABILITY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccessTypeCapability)
	COM_INTERFACE_ENTRY(IMTAccessTypeCapability)
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

// IMTAccessTypeCapability
public:
	STDMETHOD(GetParameter)(/*[out, retval]*/ MTAccessType *pVal);
	STDMETHOD(SetParameter)(/*[in]*/ MTAccessType newVal);
	STDMETHOD(InitParams)();
	STDMETHOD(Remove)(IMTPrincipalPolicy* aPolicy);
	STDMETHOD(Implies)(/*[in]*/IMTAtomicCapability* aCapability, /*[out, retval]*/VARIANT_BOOL* aResult);
	STDMETHOD(Save)(/*[in]*/IMTPrincipalPolicy* aPolicy);
	DEFINE_ATOMIC_FINAL_CONSTRUCT
	IMPLEMENT_BASE_ATOMIC_CAP_METHODS

private:
	char* GetStringAccessType(MTAccessType aType);
	MTAccessType GetEnumAccessType(char* aType);
	MTAccessType mAccessType;
	DECLARE_ATOMIC_BASE_CLASS_POINTER
};

#endif //__MTACCESSTYPECAPABILITY_H_
