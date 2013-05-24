	
// MTSite.h : Declaration of the CMTSite

#ifndef __MTSITE_H_
#define __MTSITE_H_

#include "resource.h"       // main symbols
#include <comdef.h>

/////////////////////////////////////////////////////////////////////////////
// CMTSite
class ATL_NO_VTABLE CMTSite : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSite, &CLSID_MTSite>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSite, &IID_IMTSite, &LIBID_MTSITECONFIGLib>
{
public:
	CMTSite()
	{
    mNewSiteFlag = VARIANT_FALSE ;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSITE)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTSite)
	COM_INTERFACE_ENTRY(IMTSite)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTSite
public:
	STDMETHOD(get_NewSite)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_RelativeURL)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_RelativeURL)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ProviderName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ProviderName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(Initialize)(/*[in]*/ BSTR aName, /*[in]*/ BSTR aProviderName, 
    /*[in]*/ BSTR aRelativeURL, VARIANT_BOOL aNewSiteFlag);
private:
  _bstr_t mName ; 
  _bstr_t mProviderName ;
  _bstr_t mRelativeURL ;
  VARIANT_BOOL mNewSiteFlag ;
};

#endif //__MTSITE_H_
