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

#ifndef __MTPAYMENTSLICE_H_
#define __MTPAYMENTSLICE_H_

#include "resource.h"       // main symbols
#include <StdAfx.h>
#include <MTCollectionImpl.h>

/////////////////////////////////////////////////////////////////////////////
// CMTPaymentSlice
class ATL_NO_VTABLE CMTPaymentSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPaymentSlice, &CLSID_MTPaymentSlice>,
	public ISupportErrorInfo,
	public MTCollectionReadOnlyImpl<IMTPaymentSlice, &IID_IMTPaymentSlice, &LIBID_MTYAACLib>
{
public:
	CMTPaymentSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPAYMENTSLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPaymentSlice)
	COM_INTERFACE_ENTRY(IMTCollectionReadOnly)
	COM_INTERFACE_ENTRY(IMTPaymentSlice)
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

// IMTPaymentSlice
public:
	STDMETHOD(InitializeAll)(IMTSessionContext* pCTX,IMTYAAC* pPayer);
	STDMETHOD(InitializeBitemporal)(/*[in]*/ IMTSessionContext* pCTX,/*[in]*/ IMTYAAC* pPayer,/*[in]*/ DATE RefDate,/*[in]*/ DATE SystemDate);
	STDMETHOD(Initialize)(/*[in]*/ IMTSessionContext* pCTX,/*[in]*/ IMTYAAC* pPayer,/*[in]*/ DATE RefDate);
	STDMETHOD(PayeesAsRowset)(IMTSQLRowset** ppRowset);
protected:
	HRESULT LoadData();
	HRESULT LoadDataNoTime();
	void PopulateCollection();
protected: //data
	ROWSETLib::IMTSQLRowsetPtr mRowset;
	MTYAACLib::IMTYAACPtr mPayerYAAC;
	MTAUTHLib::IMTSessionContextPtr mCTX;
	_variant_t mRefDate;
	_variant_t mSystemDate;
};

#endif //__MTPAYMENTSLICE_H_
