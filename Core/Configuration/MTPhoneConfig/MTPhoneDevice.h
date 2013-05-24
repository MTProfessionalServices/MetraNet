// MTPhoneDevice.h : Declaration of the CMTPhoneDevice

#ifndef __MTPHONEDEVICE_H_
#define __MTPHONEDEVICE_H_

#include <comutil.h>
#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTPhoneDevice
class ATL_NO_VTABLE CMTPhoneDevice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPhoneDevice, &CLSID_MTPhoneDevice>,
	public IDispatchImpl<IMTPhoneDevice, &IID_IMTPhoneDevice, &LIBID_PHONELOOKUPLib>
{
public:
	CMTPhoneDevice()
	{
	}

	~CMTPhoneDevice()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPHONEDEVICE)

BEGIN_COM_MAP(CMTPhoneDevice)
	COM_INTERFACE_ENTRY(IMTPhoneDevice)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IMTPhoneDevice
public:
	STDMETHOD(get_NationalDestinationCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_NationalDestinationCode)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_CountryName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_CountryName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_LineAccessCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LineAccessCode)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);

private:
	_bstr_t	mName;
	_bstr_t	mDescription;
	_bstr_t	mLineAccessCode;
	_bstr_t	mCountryName;
	_bstr_t	mNationalDestinationCode;

};

#endif //__MTPHONEDEVICE_H_
