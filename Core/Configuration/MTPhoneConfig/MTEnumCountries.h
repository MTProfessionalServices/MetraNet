// MTEnumCountries.h : Declaration of the CMTEnumCountries

#ifndef __MTENUMCOUNTRIES_H_
#define __MTENUMCOUNTRIES_H_

#include "resource.h"       // main symbols

#include <vector>
using std::vector;

/////////////////////////////////////////////////////////////////////////////
// CMTEnumCountries
class ATL_NO_VTABLE CMTEnumCountries : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumCountries, &CLSID_MTEnumCountries>,
	public IDispatchImpl<IMTEnumCountries, &IID_IMTEnumCountries, &LIBID_PHONELOOKUPLib>
{
public:
	CMTEnumCountries() : mCount(0)
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMCOUNTRIES)

BEGIN_COM_MAP(CMTEnumCountries)
	COM_INTERFACE_ENTRY(IMTEnumCountries)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IMTEnumCountries
public:
	STDMETHOD(GetCountryCodeOwner)(/*[in]*/BSTR bstrCountryCode, /*[out,retval]*/IMTCountry **pCountry);
	STDMETHOD(FindByCountryName)(/*[in]*/BSTR CountryName, /*[out,retval]*/ long * Idx);
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ LPDISPATCH *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(Add)(IMTCountry * pItem);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(InitFromPropSet )(IDispatch * pSet);
	STDMETHOD(Read )(BSTR bstrHostName, BSTR bstrFileName);
	STDMETHOD(ReadFromDatabase )();

private:
	vector<CComPtr<IMTCountry> > mCountryList;
	long	mCount;	
};

#endif //__MTENUMCOUNTRIES_H_
