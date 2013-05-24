	
// MTCharge.h : Declaration of the CMTCharge

#ifndef __MTCHARGE_H_
#define __MTCHARGE_H_

#include "resource.h"       // main symbols
#include "PropertiesBase.h"
#include <comutil.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCharge
class ATL_NO_VTABLE CMTCharge : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCharge, &CLSID_MTCharge>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCharge, &IID_IMTCharge, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	CMTCharge();

	DEFINE_MT_PCBASE_METHODS
	DEFINE_MT_PROPERTIES_BASE_METHODS

DECLARE_REGISTRY_RESOURCEID(IDR_MTCHARGE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCharge)
	COM_INTERFACE_ENTRY(IMTCharge)
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

// IMTCharge
public:
	STDMETHOD(get_SessionName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_AmountName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_PITypeID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PITypeID)(/*[in]*/ long newVal);
	STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DisplayName)(/*[in]*/ BSTR newVal);
	STDMETHOD(Save)(/*[out, retval]*/ long* apDBID);
	STDMETHOD(get_AmountPropertyID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AmountPropertyID)(/*[in]*/ long newVal);
	STDMETHOD(CreateChargeProperty)(/*[out, retval]*/ IMTChargeProperty** apChargeProperty);
	STDMETHOD(RemoveChargeProperty)(/*[in]*/ long aChargePropertyID);
	STDMETHOD(GetChargeProperties)(/*[out, retval]*/ IMTCollection** apColl);
	STDMETHOD(GetAmountProperty)(/*[out, retval]*/ IProductViewProperty* *apPVProp);

private:
};

#endif //__MTCHARGE_H_
