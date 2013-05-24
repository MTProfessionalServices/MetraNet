	
// MTLanguage.h : Declaration of the CMTLanguage

#ifndef __MTLANGUAGE_H_
#define __MTLANGUAGE_H_

#include "resource.h"       // main symbols
#include <comdef.h>

/////////////////////////////////////////////////////////////////////////////
// CMTLanguage
class ATL_NO_VTABLE CMTLanguage : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTLanguage, &CLSID_MTLanguage>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTLanguage, &IID_IMTLanguage, &LIBID_MTSITECONFIGLib>
{
public:
	CMTLanguage()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTLANGUAGE)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTLanguage)
	COM_INTERFACE_ENTRY(IMTLanguage)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTLanguage
public:
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(Initialize)(/*[in]*/ BSTR aName, /*[in]*/ BSTR aDescription);
private:
  _bstr_t mName ; 
  _bstr_t mDescription ;
};

#endif //__MTLANGUAGE_H_
