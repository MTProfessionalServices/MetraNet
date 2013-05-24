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

#ifndef __MTATOMICCAPABILITYTYPE_H_
#define __MTATOMICCAPABILITYTYPE_H_

#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTAtomicCapabilityType
class ATL_NO_VTABLE CMTAtomicCapabilityType : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAtomicCapabilityType, &CLSID_MTAtomicCapabilityType>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAtomicCapabilityType, &IID_IMTAtomicCapabilityType, &LIBID_MTAUTHLib>
{
public:
	CMTAtomicCapabilityType()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTATOMICCAPABILITYTYPE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAtomicCapabilityType)
	COM_INTERFACE_ENTRY(IMTAtomicCapabilityType)
  COM_INTERFACE_ENTRY(IMTCapabilityType)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		mID = -1;
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

// IMTAtomicCapabilityType
public:
	STDMETHOD(get_ParameterName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ParameterName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_CompositionDescription)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_CompositionDescription)(/*[in]*/ BSTR newVal);
	STDMETHOD(Save)();
	STDMETHOD(CreateInstance)(/*[out, retval]*/IMTAtomicCapability** apNewInstance);
	STDMETHOD(get_Editor)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Editor)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ProgID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ProgID)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
  STDMETHOD(get_GUID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_GUID)(/*[in]*/ BSTR newVal);
	
private:
	_bstr_t mName;
	_bstr_t mDesc;
	_bstr_t mProgID;
	_bstr_t mEditor;
	_bstr_t mCompDesc;
	_bstr_t mParamName;
  _bstr_t mGUID;
	long mID;

};

#endif //__MTATOMICCAPABILITYTYPE_H_
