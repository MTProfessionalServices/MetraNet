// MTRegion.h : Declaration of the CMTRegion

#ifndef __MTREGION_H_
#define __MTREGION_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTRegion
class ATL_NO_VTABLE CMTRegion : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRegion, &CLSID_MTRegion>,
	public IDispatchImpl<IMTRegion, &IID_IMTRegion, &LIBID_PHONELOOKUPLib>
{
public:
	CMTRegion()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTREGION)

BEGIN_COM_MAP(CMTRegion)
	COM_INTERFACE_ENTRY(IMTRegion)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IMTRegion
public:
	STDMETHOD(get_TollFree)(/*[out, retval]*/ BOOL *pVal);
	STDMETHOD(put_TollFree)(/*[in]*/ BOOL newVal);
	STDMETHOD(get_International)(/*[out, retval]*/ BOOL *pVal);
	STDMETHOD(put_International)(/*[in]*/ BOOL newVal);
	STDMETHOD(get_LocalCodeTable)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_LocalCodeTable)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_CountryName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_CountryName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DestinationCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DestinationCode)(/*[in]*/ BSTR newVal);

private:
	CComBSTR	mDestinationCode;
	CComBSTR	mCountryName;
	CComBSTR	mDescription;
	BOOL		mInternational;
	BOOL		mTollFree;
	CComBSTR	mLocalCodeTable;
};

#endif //__MTREGION_H_
