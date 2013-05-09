// MTRequiredAttrs.h : Declaration of the CMTRequiredAttrs

#ifndef __MTREQUIREDATTRS_H_
#define __MTREQUIREDATTRS_H_

#include "resource.h"       // main symbols
#include <SchemaObjects.h>

/////////////////////////////////////////////////////////////////////////////
// CMTRequiredAttrs
class ATL_NO_VTABLE CMTRequiredAttrs : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRequiredAttrs, &CLSID_MTRequiredAttrs>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTRequiredAttrs, &IID_IMTRequiredAttrs, &LIBID_SCHEMAREADERLib>
{
public:
	CMTRequiredAttrs() : mAttrList(NULL)
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTREQUIREDATTRS)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTRequiredAttrs)
	COM_INTERFACE_ENTRY(IMTRequiredAttrs)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTRequiredAttrs
public:
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);

public:
	STDMETHOD(get_AttrType)(/*[in]*/ long aIndex, /*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_AttrValue)(/*[in]*/ long aIndex, /*[out, retval]*/ BSTR *pVal);
	
	void PutAttrList(AutoAttrList& aAttrList) { mAttrList = aAttrList; }

protected:
	AutoAttrList mAttrList;
};

#endif //__MTREQUIREDATTRS_H_
