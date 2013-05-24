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

#ifndef __MTACCOUNTTEMPLATESUBSCRIPTIONS_H_
#define __MTACCOUNTTEMPLATESUBSCRIPTIONS_H_

#include "resource.h"       // main symbols
#include <MTCollectionImpl.h>

#define TEMPLATEINFO MTCollectionImplEx<IMTAccountTemplateSubscriptions, &IID_IMTAccountTemplateSubscriptions, &LIBID_MTYAACLib>

/////////////////////////////////////////////////////////////////////////////
// CMTAccountTemplateSubscriptions
class ATL_NO_VTABLE CMTAccountTemplateSubscriptions : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountTemplateSubscriptions, &CLSID_MTAccountTemplateSubscriptions>,
	public ISupportErrorInfo,
	public MTCollectionImplEx<IMTAccountTemplateSubscriptions, &IID_IMTAccountTemplateSubscriptions, &LIBID_MTYAACLib>
{
public:
	CMTAccountTemplateSubscriptions()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTTEMPLATESUBSCRIPTIONS)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountTemplateSubscriptions)
	COM_INTERFACE_ENTRY(IMTAccountTemplateSubscriptions)
	COM_INTERFACE_ENTRY(IMTCollectionReadOnly)
	COM_INTERFACE_ENTRY(IMTCollectionEx)
	COM_INTERFACE_ENTRY(IMTCollection)
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

  MTYAACLib::IMTAccountTemplatePtr mAccountTemplate;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAccountTemplateSubscriptions
public:
	STDMETHOD(RemoveSubscription)(/*[in]*/ long aProductOfferingID);
	STDMETHOD(get_GetItemIndexWithProductOfferingID)(/*[in]*/ long lngPOID, /*[out, retval]*/ long *pVal);
	STDMETHOD(AddSubscription)(/*[out, retval]*/ IMTAccountTemplateSubscription** ppTemplateSub);
  STDMETHOD(get_AccountTemplate)(/*[out, retval]*/IMTAccountTemplate** ppVal);
  STDMETHOD(put_AccountTemplate)(/*[out, retval]*/IMTAccountTemplate* pVal);
};

#endif //__MTACCOUNTTEMPLATESUBSCRIPTIONS_H_
