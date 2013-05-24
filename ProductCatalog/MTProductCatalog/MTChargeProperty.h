	
// MTChargeProperty.h : Declaration of the CMTChargeProperty

#ifndef __MTCHARGEPROPERTY_H_
#define __MTCHARGEPROPERTY_H_

#include "resource.h"       // main symbols
#include "PropertiesBase.h"
#include <comutil.h>

/////////////////////////////////////////////////////////////////////////////
// CMTChargeProperty
class ATL_NO_VTABLE CMTChargeProperty : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTChargeProperty, &CLSID_MTChargeProperty>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTChargeProperty, &IID_IMTChargeProperty, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	CMTChargeProperty();

	DEFINE_MT_PCBASE_METHODS
	DEFINE_MT_PROPERTIES_BASE_METHODS

DECLARE_REGISTRY_RESOURCEID(IDR_MTCHARGEPROPERTY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTChargeProperty)
	COM_INTERFACE_ENTRY(IMTChargeProperty)
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

// IMTChargeProperty
public:
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_ProductViewPropertyID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ProductViewPropertyID)(/*[in]*/ long newVal);
	STDMETHOD(get_ChargeID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ChargeID)(/*[in]*/ long newVal);
	STDMETHOD(Save)(/*[out, retval]*/ long* apDBID);
	STDMETHOD(GetProductViewProperty)(/*[out, retval]*/ IProductViewProperty* *apPVProp);

private:
};

#endif //__MTCHARGEPROPERTY_H_
