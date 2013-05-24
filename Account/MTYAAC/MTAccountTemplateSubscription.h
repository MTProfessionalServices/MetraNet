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

#ifndef __MTACCOUNTTEMPLATESUBSCRIPTION_H_
#define __MTACCOUNTTEMPLATESUBSCRIPTION_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTAccountTemplateSubscription
class ATL_NO_VTABLE CMTAccountTemplateSubscription : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountTemplateSubscription, &CLSID_MTAccountTemplateSubscription>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAccountTemplateSubscription, &IID_IMTAccountTemplateSubscription, &LIBID_MTYAACLib>
{
public:
	CMTAccountTemplateSubscription() :
		mProductOfferingID(-1),
    mGroupID(-1),
		mSubscriptionProductOfferingID(-1),
		mStartDate(0),
		mEndDate(0)
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTTEMPLATESUBSCRIPTION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountTemplateSubscription)
	COM_INTERFACE_ENTRY(IMTAccountTemplateSubscription)
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

// IMTAccountTemplateSubscription
public:
	STDMETHOD(ToString)(/*[out, retval]*/ BSTR* pVal);
	STDMETHOD(get_EndDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_EndDate)(/*[in]*/ DATE newVal);
	STDMETHOD(get_StartDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_StartDate)(/*[in]*/ DATE newVal);
	STDMETHOD(get_GroupSubName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_GroupSubName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_GroupSubscription)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_ProductOfferingID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ProductOfferingID)(/*[in]*/ long newVal);
	STDMETHOD(get_SubscriptionProductOfferingID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_SubscriptionProductOfferingID)(/*[in]*/ long newVal);
  STDMETHOD(get_GroupID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_GroupID)(/*[in]*/ long newVal);
	STDMETHOD(Save)(/*[in]*/ long lngTemplateID,/*[out, retval]*/ VARIANT_BOOL* pSuccess);
	STDMETHOD(Initialize)(/*[in]*/ IMTSessionContext* pCTX,/*[in]*/ IMTSQLRowset* pRowset);
protected:
	DATE mStartDate;
	DATE mEndDate;
	_bstr_t mGroupSubName;
	long mProductOfferingID;
  long mGroupID;
	long mSubscriptionProductOfferingID;
};

#endif //__MTACCOUNTTEMPLATESUBSCRIPTION_H_
