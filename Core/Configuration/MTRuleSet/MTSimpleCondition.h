// MTSimpleCondition.h : Declaration of the CMTSimpleCondition

#ifndef __MTSIMPLECONDITION_H_
#define __MTSIMPLECONDITION_H_

#include "resource.h"       // main symbols

///#include "SimpleCondition.h"

/////////////////////////////////////////////////////////////////////////////
// CMTSimpleCondition
class ATL_NO_VTABLE CMTSimpleCondition : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSimpleCondition, &CLSID_MTSimpleCondition>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSimpleCondition, &IID_IMTSimpleCondition, &LIBID_MTRULESETLib>
{
public:
	CMTSimpleCondition()
	{ }

	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTSIMPLECONDITION)

DECLARE_GET_CONTROLLING_UNKNOWN()
DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTSimpleCondition)
	COM_INTERFACE_ENTRY(IMTSimpleCondition)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTSimpleCondition
public:
	STDMETHOD(get_Value)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_Value)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get_Test)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Test)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_PropertyName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_PropertyName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ValueType)(/*[out, retval]*/ ::PropValType *pVal);
	STDMETHOD(put_ValueType)(/*[in]*/ ::PropValType newVal);
	STDMETHOD(get_EnumType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumType)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_EnumSpace)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EnumSpace)(/*[in]*/ BSTR newVal);

private:
	_bstr_t mPropName;
	_bstr_t mCondition;
	_variant_t mValue;
	::PropValType mType;
	_bstr_t mEnumType;
	_bstr_t mEnumSpace;

	CComPtr<IUnknown> m_pUnkMarshaler;
};

#endif //__MTSIMPLECONDITION_H_
