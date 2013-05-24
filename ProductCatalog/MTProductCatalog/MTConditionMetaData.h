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

#ifndef __MTCONDITIONMETADATA_H_
#define __MTCONDITIONMETADATA_H_

#include "resource.h"       // main symbols

#include "PropertiesBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTConditionMetaData
class ATL_NO_VTABLE CMTConditionMetaData : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTConditionMetaData, &CLSID_MTConditionMetaData>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTConditionMetaData, &IID_IMTConditionMetaData, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	DEFINE_MT_PCBASE_METHODS
	DEFINE_MT_PROPERTIES_BASE_METHODS

	CMTConditionMetaData()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCONDITIONMETADATA)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTConditionMetaData)
	COM_INTERFACE_ENTRY(IMTConditionMetaData)
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

// IMTConditionMetaData
public:
	STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DisplayName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ColumnName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ColumnName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Required)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Required)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_Filterable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Filterable)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_EnumType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumType)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EnumSpace)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumSpace)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DisplayOperator)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_DisplayOperator)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_OperatorPerRule)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_OperatorPerRule)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_Operator)(/*[out, retval]*/ MTOperatorType *pVal);
	STDMETHOD(put_Operator)(/*[in]*/ MTOperatorType newVal);
	STDMETHOD(get_DataType)(/*[out, retval]*/ PropValType *pVal);
	STDMETHOD(put_DataType)(/*[in]*/ PropValType newVal);
	STDMETHOD(get_PropertyName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_PropertyName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Length)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Length)(/*[in]*/ long newVal);
	STDMETHOD(get_DefaultValue)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_DefaultValue)(/*[in]*/ VARIANT newVal);

};

#endif //__MTCONDITIONMETADATA_H_
