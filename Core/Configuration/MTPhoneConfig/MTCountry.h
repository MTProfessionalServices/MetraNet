// MTCountry.h : Declaration of the CMTCountry

#ifndef __MTCOUNTRY_H_
#define __MTCOUNTRY_H_

#include <comutil.h>
#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTCountry
class ATL_NO_VTABLE CMTCountry : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCountry, &CLSID_MTCountry>,
	public IDispatchImpl<IMTCountry, &IID_IMTCountry, &LIBID_PHONELOOKUPLib>
{
public:
	CMTCountry()
	{
	}

	virtual ~CMTCountry()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTRY)

BEGIN_COM_MAP(CMTCountry)
	COM_INTERFACE_ENTRY(IMTCountry)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IMTCountry
public:
	STDMETHOD(get_Primary)(/*[out, retval]*/ BOOL *pVal);
	STDMETHOD(put_Primary)(/*[in]*/ BOOL newVal);
	STDMETHOD(get_NationalCodeTable)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_NationalCodeTable)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_NationalAccessCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_NationalAccessCode)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_InternationalAccessCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_InternationalAccessCode)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_CountryCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_CountryCode)(/*[in]*/ BSTR newVal);

private:
	CComBSTR	mCountryCode;
	CComBSTR	mName;
	CComBSTR	mDescription;
	CComBSTR	mInternationalAccessCode;
	CComBSTR	mNationalAccessCode;
	CComBSTR	mNationalCodeTable;
	BOOL		mPrimary;
};

#endif //__MTCOUNTRY_H_
