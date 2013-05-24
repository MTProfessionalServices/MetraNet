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
* $Header: 
* 
***************************************************************************/


#ifndef __MTCOUNTERPROPERTYDEFINITION_H_
#define __MTCOUNTERPROPERTYDEFINITION_H_

#include "resource.h"       // main symbols

#include <PropertiesBase.h>
#include <mtglobal_msg.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCounterPropertyDefinition
class ATL_NO_VTABLE CMTCounterPropertyDefinition : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCounterPropertyDefinition, &CLSID_MTCounterPropertyDefinition>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCounterPropertyDefinition, &IID_IMTCounterPropertyDefinition, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	CMTCounterPropertyDefinition()
	{
		mUnkMarshalerPtr = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERPROPERTYDEFINITION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCounterPropertyDefinition)
	COM_INTERFACE_ENTRY(IMTCounterPropertyDefinition)
	COM_INTERFACE_ENTRY(IMTPCBase)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()

	HRESULT FinalConstruct();
	
	void FinalRelease()
	{
		mUnkMarshalerPtr.Release();
	}

	CComPtr<IUnknown> mUnkMarshalerPtr;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTCounterPropertyDefinition
public:
	DEFINE_MT_PCBASE_METHODS
	DEFINE_MT_PROPERTIES_BASE_METHODS
	STDMETHOD(Load)(/*[in]*/long aDBID);
	STDMETHOD(Save)(/*[out, retval]*/long* apDBID);
	STDMETHOD(get_PITypeID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PITypeID)(/*[in]*/ long newVal);
	STDMETHOD(get_PreferredCounterTypeName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_PreferredCounterTypeName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DisplayName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Order)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Order)(/*[in]*/ long newVal);
	STDMETHOD(get_ServiceDefProperty)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ServiceDefProperty)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
private:
	CComPtr<IMTProductCatalog> mpPC;
	long mlPITypeID;
};

#endif //__MTCOUNTERPROPERTYDEFINITION_H_
