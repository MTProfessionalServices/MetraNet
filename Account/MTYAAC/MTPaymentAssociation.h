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

#ifndef __MTPAYMENTASSOCIATION_H_
#define __MTPAYMENTASSOCIATION_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTPaymentAssociation
class ATL_NO_VTABLE CMTPaymentAssociation : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPaymentAssociation, &CLSID_MTPaymentAssociation>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPaymentAssociation, &IID_IMTPaymentAssociation, &LIBID_MTYAACLib>
{
public:
	CMTPaymentAssociation()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPAYMENTASSOCIATION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPaymentAssociation)
	COM_INTERFACE_ENTRY(IMTPaymentAssociation)
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

// IMTPaymentAssociation
public:
	STDMETHOD(get_EndDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(get_StartDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(get_PayeeYAAC)(/*[out, retval]*/ IMTYAAC* *pVal);
	STDMETHOD(get_Payee)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_PayerYAAC)(/*[out, retval]*/ IMTYAAC* *pVal);
	STDMETHOD(get_Payer)(/*[out, retval]*/ long *pVal);
	STDMETHOD(Initialize)(/*[in]*/ IMTSessionContext* pCTX,/*[in]*/ long aPayer,
		/*[in]*/ long aPayee,/*[in]*/ DATE StartDate,/*[in]*/ DATE EndDate);
protected:
	MTAUTHLib::IMTSessionContextPtr mCTX;
	long mPayer;
	long mPayee;
	DATE mStartDate;
	DATE mEndDate;
};

#endif //__MTPAYMENTASSOCIATION_H_
