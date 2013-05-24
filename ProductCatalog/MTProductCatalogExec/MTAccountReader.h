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


#ifndef __MTACCOUNTREADER_H_
#define __MTACCOUNTREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTAccountReader
class ATL_NO_VTABLE CMTAccountReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAccountReader, &CLSID_MTAccountReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTAccountReader, &IID_IMTAccountReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTAccountReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTAccountReader)

BEGIN_COM_MAP(CMTAccountReader)
	COM_INTERFACE_ENTRY(IMTAccountReader)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTAccountReader
public:
	STDMETHOD(GetDefaultPriceList)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID,/*[out, retval]*/ IMTPriceList** ppVal);
	STDMETHOD(GetNextBillingIntervalEndDate)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long accountID, /*[in]*/ DATE datecheck, /*[out, retval]*/ VARIANT *pVal);
};

#endif //__MTACCOUNTREADER_H_
