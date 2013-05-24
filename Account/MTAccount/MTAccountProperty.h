	
// MTAccountProperty.h : Declaration of the CMTAccountProperty

#ifndef __MTACCOUNTPROPERTY_H_
#define __MTACCOUNTPROPERTY_H_

#include <comdef.h>
#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTAccountProperty
class ATL_NO_VTABLE CMTAccountProperty : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountProperty, &CLSID_MTAccountProperty>,
	public ISupportErrorInfo,
	public IDispatchImpl<::IMTAccountProperty, &IID_IMTAccountProperty, &LIBID_MTACCOUNTLib>
{
public:
	CMTAccountProperty()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTPROPERTY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountProperty)
	COM_INTERFACE_ENTRY(::IMTAccountProperty)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
	}

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAccountProperty
public:
	STDMETHOD(get_Value)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_Value)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(Add)(BSTR Name, VARIANT Value);

private:
	_bstr_t mName;
	_variant_t mValue;

};

#endif //__MTACCOUNTPROPERTY_H_
