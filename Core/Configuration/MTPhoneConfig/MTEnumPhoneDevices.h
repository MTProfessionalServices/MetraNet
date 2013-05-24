// MTEnumPhoneDevices.h : Declaration of the CMTEnumPhoneDevices

#ifndef __MTENUMPHONEDEVICES_H_
#define __MTENUMPHONEDEVICES_H_

#include "resource.h"       // main symbols

#include <vector>
using std::vector;

/////////////////////////////////////////////////////////////////////////////
// CMTEnumPhoneDevices
class ATL_NO_VTABLE CMTEnumPhoneDevices : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumPhoneDevices, &CLSID_MTEnumPhoneDevices>,
	public IDispatchImpl<IMTEnumPhoneDevices, &IID_IMTEnumPhoneDevices, &LIBID_PHONELOOKUPLib>
{
public:
	CMTEnumPhoneDevices() : mCount(0)
	{
	}

	virtual ~CMTEnumPhoneDevices()
	{
	}

	
DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMPHONEDEVICES)

BEGIN_COM_MAP(CMTEnumPhoneDevices)
	COM_INTERFACE_ENTRY(IMTEnumPhoneDevices)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IMTEnumPhoneDevices
public:
	STDMETHOD(FindDeviceByName)(/*[in]*/ BSTR bstrName, /*[out]*/LPDISPATCH *lpDev);
	STDMETHOD(Remove)(/*[in]*/ long Index);
	STDMETHOD(Write)();
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ LPDISPATCH *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(Add)(IMTPhoneDevice * pDevice);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(InitFromPropSet )(IDispatch * pSet);
	STDMETHOD(Read )(BSTR bstrHostName, BSTR bstrFileName);
	STDMETHOD(ReadFromDatabase )();

private:
	vector<CComPtr<IMTPhoneDevice> > mDeviceList;
	long	mCount;
	_bstr_t mFileName;
	_bstr_t	mPathName;
	_bstr_t	mHostName;

};

#endif //__MTENUMPHONEDEVICES_H_
