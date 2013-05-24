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

#ifndef __MTACTIONMETADATA_H_
#define __MTACTIONMETADATA_H_

#include "resource.h"       // main symbols

#include "PropertiesBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTActionMetaData
class ATL_NO_VTABLE CMTActionMetaData : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTActionMetaData, &CLSID_MTActionMetaData>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTActionMetaData, &IID_IMTActionMetaData, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	DEFINE_MT_PCBASE_METHODS
	DEFINE_MT_PROPERTIES_BASE_METHODS

	CMTActionMetaData()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACTIONMETADATA)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTActionMetaData)
	COM_INTERFACE_ENTRY(IMTActionMetaData)
	COM_INTERFACE_ENTRY(IMTPCBase)
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

// IMTActionMetaData
public:
	STDMETHOD(get_Editable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Editable)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DisplayName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ColumnName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ColumnName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EnumType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumType)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EnumSpace)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumSpace)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DefaultValue)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_DefaultValue)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get_DataType)(/*[out, retval]*/ PropValType *pVal);
	STDMETHOD(put_DataType)(/*[in]*/ PropValType newVal);
	STDMETHOD(get_Kind)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Kind)(/*[in]*/ long newVal);
	STDMETHOD(get_PropertyName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_PropertyName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Required)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Required)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_Length)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Length)(/*[in]*/ long newVal);

private:
	_bstr_t mPropertyName;
	long mKind;
	PropValType mDataType;
	_variant_t mDefaultValue;
	_bstr_t mEnumSpace;
	_bstr_t mEnumType;
};

#endif //__MTACTIONMETADATA_H_
