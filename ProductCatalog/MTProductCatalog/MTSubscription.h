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
* $Header$
* 
***************************************************************************/

#ifndef __MTSUBSCRIPTION_H_
#define __MTSUBSCRIPTION_H_

#include "resource.h"       // main symbols
#include "PropertiesBase.h"
#include "MTSubscriptionBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTSubscription
class ATL_NO_VTABLE CMTSubscription : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSubscription, &CLSID_MTSubscription>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSubscription, &IID_IMTSubscription, &LIBID_MTPRODUCTCATALOGLib>,
	public MTSubscriptionBase
{
public:
	CMTSubscription()
	{
		SetSubscriptionKind();
		m_pUnkMarshaler = NULL;
	}

DEFINE_MT_PCBASE_METHODS
DEFINE_MT_PROPERTIES_BASE_METHODS
DEFINE_SUBSCRIPTION_BASE_METHODS


DECLARE_REGISTRY_RESOURCEID(IDR_MTSUBSCRIPTION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTSubscription)
	COM_INTERFACE_ENTRY(IMTPCBase)
	COM_INTERFACE_ENTRY(IMTSubscriptionBase)
	COM_INTERFACE_ENTRY(IMTSubscription)
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

// IMTSubscription
public:
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
	STDMETHOD(Save)(VARIANT_BOOL* pDateModified);


protected:

	void SetSubscriptionKind() { mSubKind = SingleSubscription; }
};

#endif //__MTSUBSCRIPTION_H_
