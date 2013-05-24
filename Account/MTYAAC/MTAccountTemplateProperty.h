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

#ifndef __MTACCOUNTTEMPLATEPROPERTY_H_
#define __MTACCOUNTTEMPLATEPROPERTY_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTAccountTemplateProperty
class ATL_NO_VTABLE CMTAccountTemplateProperty : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountTemplateProperty, &CLSID_MTAccountTemplateProperty>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAccountTemplateProperty, &IID_IMTAccountTemplateProperty, &LIBID_MTYAACLib>
{
public:
	CMTAccountTemplateProperty()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTTEMPLATEPROPERTY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountTemplateProperty)
	COM_INTERFACE_ENTRY(IMTAccountTemplateProperty)
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

// IMTAccountTemplateProperty
public:
	STDMETHOD(get_Class)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Class)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Value)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Value)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_Type)(/*[out, retval]*/ PropValType *pVal);
	STDMETHOD(put_Type)(/*[in]*/ PropValType newVal);

  /* Hidden */
  STDMETHOD(get_InternalValue)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_InternalValue)(/*[in]*/ BSTR newVal);
	

	STDMETHOD(Initialize)(BSTR aClass,BSTR aName,BSTR aValue);
	STDMETHOD(get_ToString)(/*[out, retval]*/ BSTR *pVal);
protected:
	_bstr_t mName;
	_bstr_t mClass;
	_bstr_t mValue;
  _bstr_t mInternalValue;
  PropValType mType;
};

#endif //__MTACCOUNTTEMPLATEPROPERTY_H_
