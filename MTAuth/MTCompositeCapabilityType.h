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

#ifndef __MTCOMPOSITECAPABILITYTYPE_H_
#define __MTCOMPOSITECAPABILITYTYPE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTCompositeCapabilityType
class ATL_NO_VTABLE CMTCompositeCapabilityType : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCompositeCapabilityType, &CLSID_MTCompositeCapabilityType>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCompositeCapabilityType, &IID_IMTCompositeCapabilityType, &LIBID_MTAUTHLib>
//	public PropertiesBase
{
public:
	CMTCompositeCapabilityType()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOMPOSITECAPABILITYTYPE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

//DEFINE_MT_PROPERTIES_BASE_METHODS

BEGIN_COM_MAP(CMTCompositeCapabilityType)
	COM_INTERFACE_ENTRY(IMTCompositeCapabilityType)
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

// IMTCompositeCapabilityType
public:
	STDMETHOD(get_UmbrellaSensitive)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_UmbrellaSensitive)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(Equals)(/*[in]*/IMTCompositeCapabilityType* aType, /*[out, retval]*/VARIANT_BOOL* apResult);
	STDMETHOD(AddAtomicCapabilityType)(/*[in]*/IMTAtomicCapabilityType* apAtomicType);
	STDMETHOD(GetAtomicCapabilityTypes)(/*[in]*/IMTCollection** apAtomicTypes);
	STDMETHOD(InitByInstanceID)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/long aInstanceID);
	STDMETHOD(Init)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/long aTypeID);
	STDMETHOD(get_Editor)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Editor)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_AllowMultipleInstances)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_AllowMultipleInstances)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_NumAtomic)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_SubscriberAssignable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_SubscriberAssignable)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_CSRAssignable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_CSRAssignable)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(CreateInstance)(/*[out, retval]*/IMTCompositeCapability** apNewInstance);
	STDMETHOD(get_GUID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_GUID)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ProgID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ProgID)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(Save)();
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);

private:
	MTObjectCollection<IMTAtomicCapabilityType> mAtomicTypes;

	_bstr_t mName;
	_bstr_t mDesc;
	_bstr_t mProgID;
	_bstr_t mEditor;
	_bstr_t mGUID;
	VARIANT_BOOL mAllowMultipleInstances;
	VARIANT_BOOL mCSRAssignable;
	VARIANT_BOOL mSubscriberAssignable;
  VARIANT_BOOL mUmbrellaSensitive;
	long mID;


};

#endif //__MTCOMPOSITECAPABILITYTYPE_H_
