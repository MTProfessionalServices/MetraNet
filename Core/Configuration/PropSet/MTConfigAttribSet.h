// MTConfigAttribSet.h : Declaration of the CMTConfigAttribSet

#ifndef __MTCONFIGATTRIBSET_H_
#define __MTCONFIGATTRIBSET_H_

#include "resource.h"       // main symbols
#include "XMLParser.h"

/////////////////////////////////////////////////////////////////////////////
// CMTConfigAttribSet
class ATL_NO_VTABLE CMTConfigAttribSet : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTConfigAttribSet, &CLSID_MTConfigAttribSet>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTConfigAttribSet, &IID_IMTConfigAttribSet, &LIBID_MTConfigPROPSETLib>
{
public:
	CMTConfigAttribSet() : mpAttributes(NULL)
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCONFIGATTRIBSET)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTConfigAttribSet)
	COM_INTERFACE_ENTRY(IMTConfigAttribSet)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTConfigAttribSet
public:
	STDMETHOD(GetAttrItem)(/*[in] */ long aIndex,/* out */ BSTR* pKey, /* [out,retval*/ BSTR* pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_AttrValue)(/*[in]*/ BSTR bstrKey, /*[out, retval]*/ BSTR *pVal);
	STDMETHOD(AddPair)(/*[in]*/ BSTR bstrKey, /*[in]*/ BSTR pVal);
	STDMETHOD(Initialize)();
	
public: // non COM methods
	STDMETHOD(RemoveAttr)(/*[in]*/ BSTR key);
	
	void SetMap(XMLNameValueMap& aAttrs) { mpAttributes = aAttrs; }
	XMLNameValueMap& GetMap() { return mpAttributes; }

protected:
	XMLNameValueMap  mpAttributes;
};

#endif //__MTCONFIGATTRIBSET_H_
