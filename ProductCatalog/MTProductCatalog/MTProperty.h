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
* $Header: MTProperty.h, 10, 3/12/2002 2:43:21 PM, Derek Young$
* 
***************************************************************************/

#ifndef __MTPROPERTY_H_
#define __MTPROPERTY_H_

#include "resource.h"       // main symbols

#include <mtprogids.h>

/////////////////////////////////////////////////////////////////////////////
// CMTProperty
class ATL_NO_VTABLE CMTProperty : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTProperty, &CLSID_MTProperty>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTProperty, &IID_IMTProperty, &LIBID_MTPRODUCTCATALOGLib>
{
public:
	CMTProperty();
	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPROPERTY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTProperty)
	COM_INTERFACE_ENTRY(IMTProperty)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTProperty
public:
	STDMETHOD(get_Value)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_Value)(/*[in]*/ VARIANT newVal);
	STDMETHOD(GetMetaData)(/*[out, retval]*/ IMTPropertyMetaData** apMetaData);
	STDMETHOD(SetMetaData)(/*[in]*/ IMTPropertyMetaData* apMetaData);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_DataType)(/*[out, retval]*/ PropValType *pVal);
	STDMETHOD(get_DataTypeAsString)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Length)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_EnumSpace)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_EnumType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Required)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_Extended)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_PropertyGroup)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Attributes)(/*[out, retval]*/ IMTAttributes* *pVal);
	STDMETHOD(get_Overrideable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_SummaryView)(/*[out, retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(get_Empty)(/*[out, retval]*/ VARIANT_BOOL *pVal);

//data
private:
	CComPtr<IUnknown> mUnkMarshalerPtr;
	CComPtr<IMTPropertyMetaData> mMetaDataPtr;
	_variant_t mValue;
};

#endif //__MTPROPERTY_H_
