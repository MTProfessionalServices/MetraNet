	
// MTProductCollection.h : Declaration of the CMTProductCollection

#ifndef __MTPRODUCTCOLLECTION_H_
#define __MTPRODUCTCOLLECTION_H_

#include "resource.h"       // main symbols
#include <comdef.h>


/////////////////////////////////////////////////////////////////////////////
// CMTProductCollection
class ATL_NO_VTABLE CMTProductCollection : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTProductCollection, &CLSID_MTProductCollection>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTProductCollection, &IID_IMTProductCollection, &LIBID_COMKIOSKLib>
{
public:
	CMTProductCollection() {}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTCOLLECTION)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTProductCollection)
	COM_INTERFACE_ENTRY(IMTProductCollection)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTProductCollection
public:
	STDMETHOD(get_Link)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Link)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);

private:
    _bstr_t mName;
    _bstr_t mLink;
};

#endif //__MTPRODUCTCOLLECTION_H_
