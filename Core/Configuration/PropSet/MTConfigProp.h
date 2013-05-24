	
// MTConfigProp.h : Declaration of the CMTConfigProp

#ifndef __MTCONFIGPROP_H_
#define __MTCONFIGPROP_H_

#include "resource.h"       // main symbols

#include <xmlconfig.h>
#include <autoinstance.h>

HRESULT WINAPI _This(void*,REFIID,void**,DWORD);

/////////////////////////////////////////////////////////////////////////////
// CMTConfigProp
class ATL_NO_VTABLE CMTConfigProp : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTConfigProp, &CLSID_MTConfigProp>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTConfigProp, &IID_IMTConfigProp, &LIBID_MTConfigPROPSETLib>
{
public:
	CMTConfigProp()
	{ }

DECLARE_REGISTRY_RESOURCEID(IDR_MTCONFIGPROP)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTConfigProp)
	COM_INTERFACE_ENTRY(IMTConfigProp)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_FUNC(IID_NULL,0,_This)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTConfigProp
public:
	STDMETHOD(get_Value)(/*[out]*/ PropValType * apType,
											 /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_PropValue)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_PropType)(/*[out]*/ PropValType * apType);
	STDMETHOD(get_ValueAsString)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR pVal);
	STDMETHOD(get_AttribSet)(/*[out, retval]*/ IMTConfigAttribSet** ppAttribSet);
	STDMETHOD(put_AttribSet)(/*[in]*/ IMTConfigAttribSet* pAttribSet);
	STDMETHOD(AddProp)( /* [in] */ PropValType aType,/* [in] */ VARIANT aVal);

public:
	void SetNameValue(XMLConfigNameVal * apNameVal);
	void SetPropSet(XMLConfigPropSet * apPropSet);
	XMLConfigNameVal* GetNewNameVal(); 

	BOOL IsNameVal() const
	{ return mpObject->IsNameVal(); }

	XMLConfigNameVal * GetNameVal()
	{
		if(mNewXMLObject) {
			return mNewXMLObject;
		}
		else {
			ASSERT(IsNameVal());
			return static_cast<XMLConfigNameVal *>(mpObject);
		}
	}

	XMLConfigPropSet * GetSet()
	{
		ASSERT(!IsNameVal());
		return static_cast<XMLConfigPropSet *>(mpObject);
	}

private:
	XMLConfigObject * mpObject;
	MTAutoCreatePtr<XMLConfigNameVal> mNewXMLObject;
};


#endif //__MTCONFIGPROP_H_
