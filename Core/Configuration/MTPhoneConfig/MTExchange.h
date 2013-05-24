// MTExchange.h : Declaration of the CMTExchange

#ifndef __MTEXCHANGE_H_
#define __MTEXCHANGE_H_

#include "resource.h"       // main symbols
#include <comutil.h>

/////////////////////////////////////////////////////////////////////////////
// CMTExchange
class ATL_NO_VTABLE CMTExchange : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTExchange, &CLSID_MTExchange>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTExchange, &IID_IMTExchange, &LIBID_PHONELOOKUPLib>
{
public:
	CMTExchange()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTEXCHANGE)

BEGIN_COM_MAP(CMTExchange)
	COM_INTERFACE_ENTRY(IMTExchange)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTExchange
public:
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Code)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Code)(/*[in]*/ BSTR newVal);

private:
	_bstr_t mCode;
	_bstr_t mDescription;
};

#endif //__MTEXCHANGE_H_
